#!/usr/bin/env python3
"""Audit a Stata .log file (and optional .do script) for runtime errors and reproducibility hygiene."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

STATA_ERROR_RE = re.compile(r"^r\((\d+)\);\s*$", re.MULTILINE)
OBS_RE = re.compile(r"Number of obs\s*=\s*([\d,]+)")
EXPORT_RE = re.compile(r"\b(?:file|graph)\s+([^\s]+\.(?:txt|tex|png|pdf|dta))\s+(?:written|saved)", re.IGNORECASE)
ABS_PATH_RE = re.compile(r"(?:[A-Za-z]:\\Users\\[^\s\"']+|/Users/[^\s\"']+|/home/[^\s\"']+)")
VERSION_RE = re.compile(r"^\s*version\s+\d+(?:\.\d+)?", re.MULTILINE)
CAPTURE_EST_RE = re.compile(
    r"^\s*capture\s+(?:quietly\s+)?(?:reg|regress|reghdfe|xtreg|ivregress|ivreghdfe|didregress|xthdidregress|csdid|ppmlhdfe|logit|probit)\b",
    re.MULTILINE | re.IGNORECASE,
)


def audit_log(log_path: Path, do_path: Path | None = None) -> dict:
    log_text = log_path.read_text(encoding="utf-8", errors="replace")
    fatal_errors: list[str] = []
    warnings: list[str] = []

    err_codes = STATA_ERROR_RE.findall(log_text)
    if err_codes:
        fatal_errors.append(f"Stata runtime error code(s) detected in log: r({'), r('.join(err_codes)})")

    if "log close" not in log_text and "end of do-file" not in log_text:
        warnings.append("Neither 'log close' nor 'end of do-file' marker found; verify script did not terminate early.")

    # Strip Stata's own log-file header lines so running in a user working directory does not raise a false warning
    filtered_lines: list[str] = []
    skip_wrapped_log = False
    for line in log_text.splitlines():
        if re.match(r"^\s*log:\s+", line):
            skip_wrapped_log = True
            continue
        if skip_wrapped_log and line.lstrip().startswith("> "):
            continue
        skip_wrapped_log = False
        if re.match(r"^\s*log type:\s+", line):
            continue
        filtered_lines.append(line)
    abs_paths = sorted(set(ABS_PATH_RE.findall("\n".join(filtered_lines))))
    if abs_paths:
        warnings.append(f"Personal absolute path(s) appeared in log body: {', '.join(abs_paths[:5])}")

    if do_path is not None:
        raw_bytes = do_path.read_bytes()
        if raw_bytes.startswith(b"\xef\xbb\xbf"):
            fatal_errors.append(f"UTF-8 BOM detected in {do_path.name}; Stata fails on line 1 with r(199).")
        do_text = raw_bytes.decode("utf-8", errors="replace")
        if not VERSION_RE.search(do_text):
            warnings.append(f"No explicit 'version' statement found in {do_path.name}.")
        if CAPTURE_EST_RE.search(do_text):
            fatal_errors.append(f"Forbidden 'capture' masking an estimation command in {do_path.name}.")
        do_abs = sorted(set(ABS_PATH_RE.findall(do_text)))
        if do_abs:
            warnings.append(f"Hardcoded user path(s) in {do_path.name}: {', '.join(do_abs[:5])}")

    obs_counts = OBS_RE.findall(log_text)
    exports = sorted(set(EXPORT_RE.findall(log_text)))

    return {
        "log_file": str(log_path),
        "do_file": str(do_path) if do_path else None,
        "status": "FAIL" if fatal_errors else ("WARN" if warnings else "PASS"),
        "fatal_errors": fatal_errors,
        "warnings": warnings,
        "observed_N_values": obs_counts,
        "exported_artifacts": exports,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Audit Stata .log (and optional .do) for errors and hygiene.")
    parser.add_argument("log_path", type=Path, help="Path to Stata text .log file")
    parser.add_argument("--do", type=Path, default=None, help="Optional path to corresponding .do file")
    parser.add_argument("--json", action="store_true", help="Output machine-readable JSON")
    args = parser.parse_args()

    if not args.log_path.is_file():
        print(f"ERROR: Log file not found: {args.log_path}", file=sys.stderr)
        return 2
    if args.do is not None and not args.do.is_file():
        print(f"ERROR: .do file not found: {args.do}", file=sys.stderr)
        return 2

    report = audit_log(args.log_path, args.do)
    if args.json:
        print(json.dumps(report, ensure_ascii=False, indent=2))
    else:
        print(f"[{report['status']}] {report['log_file']}")
        if report["observed_N_values"]:
            print(f"  Observed N mentions : {', '.join(report['observed_N_values'])}")
        if report["exported_artifacts"]:
            print(f"  Exported files      : {', '.join(report['exported_artifacts'])}")
        for w in report["warnings"]:
            print(f"  WARN: {w}")
        for e in report["fatal_errors"]:
            print(f"  FAIL: {e}")

    return 1 if report["fatal_errors"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
