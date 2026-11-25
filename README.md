# Economic Empirical Research (`v1.0`)

面向经济学全研究周期的 Agent Skill 体系，遵循现代应用计量与国际顶刊（*AER*、*QJE*、*JPE*、*Econometrica*、*REStud*）及中文权威期刊（《经济研究》《管理世界》《经济学（季刊）》《中国工业经济》）的规范标准，覆盖 **选题理论建模与功效预审、30 篇以上分层精读与可投稿综述、2020+ 前沿计量识别选型、Stata 规范工作流与自动审计、中英文双轨论文撰写，以及四角色模拟审稿与 Rebuttal 修回**。

> An end-to-end AI Agent Skill for rigorous economics research—covering formal theoretical modeling & pre-study power audit, stratified 30+ paper literature synthesis with effect-size normalization, frontier econometric identification & inference (staggered DID, `honestdid`, Lee et al. *tF*, shift-share IV, Chen-Roth zero-outcome rules), reproducible Stata pipelines, dual English/Chinese venue formatting, and multi-role peer review & rebuttal workflows.

---

## 核心特色与设计准则

1. **估计量与正式建模先行**：先通过五要素微/宏观建模生成可证伪预测，完成四支柱事前可行性与 $\text{MDE}$ 统计功效审查，界定目标参数（ATE、ATT、ITT、LATE、MVPF 或结构反事实），再匹配识别策略。
2. **反机械检验与 2020+ 计量前沿对齐**：禁止将基础 OLS、逐步加控、VIF、Hausman、三步法中介、PSM 等机械化为必做清单；明确纳入 Chen & Roth（2024）含零变量规程、Abadie et al.（2023）设计层级聚类、Rambachan & Roth（2023）`honestdid` 灵敏度、Lee et al.（2022）$tF$ 弱工具标尺、Bartik IV 双路线以及四类正面机制验证框架。
3. **分层文献编码与效果量归一化**：区分工作论文（NBER/CEPR/IZA/SSRN）与正式发表版本防重复计票；要求在编码矩阵中对异质口径效果量做归一化换算，严格区分“预期拟实现贡献”与“已获实证支持贡献”。
4. **EN-Top5 / CN-Top 双轨制与四角色审稿**：内建英文国际顶刊与中文核心刊物双轨体例切换，配备 AI 套话黑名单、Co-Editor / 计量 / 领域 / 数据编辑四角色攻击清单及 Rebuttal 回复模板。
5. **纯内置 Stata 双范本 + Python 自动化审计工具**：配套基于 `nlsw88.dta` 的 OLS 规范范本，以及基于明确标注教学模拟数据的模块化 `xthdidregress` 交错 DID 与 `ivregress` 2SLS 范本（全部在 **Stata/MP 18.0** 实测跑通），并提供 `audit_stata_log.py` 与 `check_replication_package.py` 自动巡检工具。

---

## 目录结构

```text
economic-empirical-research/
├── SKILL.md                                     # 总控路由、核心底线、双轨切换与交接闸门
├── README.md                                    # 仓库说明、安装指南与版本变更记录
├── LICENSE                                      # MIT License
├── .gitignore                                   # 忽略本地实跑生成的临时数据、日志与表图文件
├── references/
│   ├── 01-topic-and-theory.md                   # 阶段一：选题张力、正式建模、四支柱与 MDE 预审
│   ├── 02-literature-review.md                  # 阶段二：检索层级、30+ 分层配额、归一化与嵌入式综述
│   ├── 03-econometrics-and-stata.md             # 阶段三 A：八大家族地图、十步流、零值/聚类/正面机制
│   ├── 04-design-branches-and-displays.md       # 阶段三 B：前沿 DID/IV/RD/RCT/SCM 诊断、子学科与表图规范
│   ├── 05-writing-and-venues.md                 # 阶段四：EN-Top5/CN-Top 双轨体例、引言蓝图与去 AI 味
│   └── 06-peer-review-and-rebuttal.md           # 阶段五：四角色审稿攻击、Rebuttal 模板与复现包终审
├── resources/
│   ├── research_contract_template.md            # 跨阶段状态契约与正文-日志数字对齐台账
│   └── literature_coding_matrix_template.csv    # 30+ 篇文献精读与归一化效果量编码矩阵模板
├── scripts/
│   ├── audit_stata_log.py                       # 零依赖 Python：检查 Stata .log 报错、N 与导出产物
│   └── check_replication_package.py             # 零依赖 Python：排查 UTF-8 BOM、capture 掩盖与硬编码路径
└── examples/
    ├── ols_nlsw88_exemplar.do                   # 纯内置命令 OLS 范本（无 BOM UTF-8，含 FE/均值行与 .tex）
    ├── ols_nlsw88_verified_output.md            # Stata/MP 18.0 实跑输出记录与五要素解读示范
    └── causal_did_iv_exemplar/                  # 模块化因果识别教学复现范本（明确标注教学模拟数据）
        ├── 00_master.do                         # 相对路径复现总控脚本
        ├── 01_did_staggered.do                  # 交错 DID（xthdidregress）对比有偏 TWFE 示范
        ├── 02_iv_2sls.do                        # IV/2SLS（OLS/一阶段/简约式/2SLS + tF/AR 诊断）
        └── verified_output.md                   # Stata/MP 18.0 实跑真值对照与五要素解读
```

---

## 安装与使用

### 全局安装（推荐）

将仓库克隆到用户级全局 Skill 目录（以 Antigravity / `~/.gemini/config/skills/` 为例）：

```bash
git clone https://github.com/CJG0712/economic-empirical-research.git ~/.gemini/config/skills/economic-empirical-research
```

Windows PowerShell 示例：

```powershell
git clone https://github.com/CJG0712/economic-empirical-research.git "$env:USERPROFILE\.gemini\config\skills\economic-empirical-research"
```

### 项目级安装

若仅在单个研究项目中使用，可克隆至项目根目录的 `.agents/skills/` 下：

```bash
git clone https://github.com/CJG0712/economic-empirical-research.git .agents/skills/economic-empirical-research
```

### 实证范本复现与 Python 自动化审计

打开 Stata 18（无 BOM UTF-8 环境），切换工作目录至对应示例文件夹执行：

```stata
* 基础 OLS 范本
do ols_nlsw88_exemplar.do

* 或运行模块化因果识别范本（模拟教学数据）
cd causal_did_iv_exemplar
do 00_master.do
```

完成运行后，使用仓库内置 Python 3 脚本进行复现与日志自检（无需额外安装第三方库）：

```bash
python scripts/audit_stata_log.py path/to/01_ols_run.log --do examples/ols_nlsw88_exemplar.do
python scripts/check_replication_package.py examples --strict
```

---

## 版本演进记录（Changelog）

- **v1.0（当前版本）**：
  - 修复 `v0.1` 错别字、硬编码样本量、OLS 表格缺少 `Occupation FE` 与因变量均值行、`dtable` 测试说明及 `i.occupation` 联立张力提示；新增 `.tex` 直出示范。
  - 全面补全阶段一（正式微观建模五要素、可证伪对照与四支柱 $\text{MDE}$ 功效预审）、阶段二（检索源分级、30+ 篇分层配额、嵌入式短述评与效果量归一化）与阶段四/五（EN-Top5/CN-Top 双轨路由、AI 套话黑名单、四角色审稿攻击、Rebuttal 模板与复现包清单）。
  - 补齐 2020–2025 前沿计量盲区：`honestdid`、Roth 事前偏误、连续与进出切换 DID、Lee et al. (2022) $tF$ 标尺、Shift-Share IV 双路线、法官宽严设计、Chen & Roth (2024) 含零规程、Abadie et al. (2023) 聚类法则、Oster 敏感性、四类正面机制路径，以及宏观 LP/贸易引力与劳动/AI/环境子学科要点。
  - 新增跨阶段研究契约与文献编码 CSV 模板、模块化 `causal_did_iv_exemplar` Stata 18 教学复现包，以及两款零依赖 Python 审计脚本。
- **v0.1**：初始基线版本（建立总控框架、文献综述基础规范、八大家族地图与 `nlsw88` OLS 初版范本）。

---

## License

本项目采用 [MIT License](LICENSE) 开源。
