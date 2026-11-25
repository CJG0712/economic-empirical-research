#!/usr/bin/env python3
"""Check an economics replication directory for AEA / top-journal reproducibility hygiene."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

VERSION_RE = re.compile(r"^\s*version\s+\d+(?:\.\d+)?", re.MULTILINE)
CAPTURE_EST_RE = re.compile(
    r"^\s*capture\s+(?:quietly\s+)?(?:reg|regress|reghdfe|xtreg|ivregress|ivreghdfe|didregress|xthdidregress|csdid|ppmlhdfe|logit|probit)\b",
    re.MULTILINE | re.IGNORECASE,
)
ABS_PATH_RE = re.compile(r"(?:[A-Za-z]:\\[^\s\"']+|/Users/[^\s\"']+|/home/[^\s\"']+)")


def inspect_do_file(path: Path, strict: bool) -> tuple[list[str], list[str]]:
    fails: list[str] = []
    warns: list[str] = []
    raw = path.read_bytes()

    if raw.startswith(b"\xef\xbb\xbf"):
        fails.append("UTF-8 BOM detected (breaks Stata line 1 with r(199))")

    text = raw.decode("utf-8", errors="replace")
    if not VERSION_RE.search(text):
        msg = "Missing explicit 'version' header"
        (fails if strict else warns).append(msg)

    if CAPTURE_EST_RE.search(text):
        fails.append("Forbidden 'capture' masking an estimation command")

    abs_hits = sorted(set(ABS_PATH_RE.findall(text)))
    if abs_hits:
        msg = f"Hardcoded absolute path(s): {', '.join(abs_hits[:3])}"
        (fails if strict else warns).append(msg)

    return fails, warns


def main() -> int:
    parser = argparse.ArgumentParser(description="Audit Stata replication folder hygiene.")
    parser.add_argument("target_dir", type=Path, help="Directory containing .do scripts or replication package")
    parser.add_argument("--strict", action="store_true", help="Promote warnings (missing version/paths) to FAIL")
    args = parser.parse_args()

    if not args.target_dir.is_dir():
        print(f"ERROR: Directory not found: {args.target_dir}", file=sys.stderr)
        return 2

    do_files = sorted(args.target_dir.rglob("*.do"))
    if not do_files:
        print(f"ERROR: No .do files found under {args.target_dir}", file=sys.stderr)
        return 2

    total_fails = 0
    total_warns = 0
    print(f"Auditing {len(do_files)} .do file(s) in {args.target_dir} (strict={args.strict})")

    for df in do_files:
        rel = df.relative_to(args.target_dir)
        fails, warns = inspect_do_file(df, args.strict)
        total_fails += len(fails)
        total_warns += len(warns)
        status = "FAIL" if fails else ("WARN" if warns else "PASS")
        print(f"  [{status}] {rel}")
        for f in fails:
            print(f"     FAIL: {f}")
        for w in warns:
            print(f"     WARN: {w}")

    has_readme_or_doc = any(
        (args.target_dir / name).exists()
        for name in ("README.md", "00_master.do", "ols_nlsw88_verified_output.md")
    )
    if not has_readme_or_doc:
        total_warns += 1
        print("  [WARN] No top-level README.md / 00_master.do / verified_output documentation found.")

    print(f"Summary: {len(do_files)} checked | fails={total_fails} | warns={total_warns}")
    return 1 if total_fails > 0 else 0


if __name__ == "__main__":
    raise SystemExit(main())
