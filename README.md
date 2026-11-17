# Economic Empirical Research (`v0.1`)

面向经济学全研究周期的 Agent Skill 体系，遵循现代应用计量与顶刊（*AER*、*QJE*、*JPE*、*Econometrica* 及《经济研究》《管理世界》《经济学（季刊）》等）的规范标准，覆盖 **选题立意、30 篇以上文献精读与可投稿综述、主流计量方法选型、Stata 规范代码工作流、顶刊级三线表与图形整理，以及论文撰写与审稿自查**。

> An end-to-end AI Agent Skill for rigorous economics research—covering topic formulation, 30+ paper literature synthesis, econometric identification & method mapping, reproducible Stata workflows, publication-grade tables/figures, and manuscript auditing.

---

## 核心特色与设计准则

1. **估计量与识别优先于模型堆砌**：先依据理论框架与制度背景界定目标参数（描述分布、条件关联、ATE、ATT、ITT、LATE 或结构反事实），再匹配研究设计、估计器与聚类推断层级。
2. **反机械检验与坏控制变量禁令**：禁止将 OLS、逐步加控制变量、相关矩阵、VIF、Hausman、单位根、PSM、中介检验、异质性与安慰剂列为所有论文的“必做八股”；控制变量须严格按理论、制度与时间先后选定。
3. **高标准经济学文献综述规程**：区别工作论文（NBER、CEPR、IZA、SSRN）与正式发表版本以防重复计票，禁止将“换地区、换年份、换样本、换模型名”直接包装为创新，并严格区分“预期拟实现的贡献”与“已获实证支持的贡献”。
4. **学科方法边界清晰**：吸收问卷回译、答题时长筛查与测量等值性校验做法，但严禁将横截面量表或结构方程模型（SEM）路径系数直接解读为因果效应。
5. **纯内置 Stata 可复刻范本与五要素解读**：配套基于 Stata 内置 `nlsw88.dta` 的零外部依赖教学脚本，已在 **Stata/MP 18.0** 实测跑通，并按“回答了什么—对应表列或图形—关键估计和单位—不确定性—必要边界”五要素做定量解读。

---

## 目录结构

```text
economic-empirical-research/
├── SKILL.md                                     # 总控路由、核心学术底线与跨阶段交接规则
├── README.md                                    # 仓库说明与安装指南
├── LICENSE                                      # MIT License
├── .gitignore                                   # 忽略本地实跑生成的临时数据、日志与图片
├── references/
│   ├── 01-topic-and-theory.md                   # 阶段一：选题切入、估计量先行与饱和度评估（基线）
│   ├── 02-literature-review.md                  # 阶段二：文献精读编码与可投稿综述十节完整规范
│   ├── 03-econometrics-and-stata.md             # 阶段三 A：八大家族方法地图、十步实证流与代码铁律
│   ├── 04-design-branches-and-displays.md       # 阶段三 B：DID/DDD/RD/IV/RCT/SCM 诊断与表图规范
│   └── 05-writing-and-revision-baseline.md      # 阶段四/五：论文展陈结构、去 AI 味与五项自查清单（基线）
└── examples/
    ├── ols_nlsw88_exemplar.do                   # 纯内置命令 OLS 完整可执行范本（无 BOM UTF-8）
    └── ols_nlsw88_verified_output.md            # Stata/MP 18.0 实跑输出记录与五要素解读示范
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

### 实证范本复现

打开 Stata 17/18（建议无 BOM UTF-8 环境），切换工作目录至 `examples/` 后执行：

```stata
do ols_nlsw88_exemplar.do
```

脚本将自动核验 `nlsw88.dta` 主键与缺失偏误、锁定共同分析样本（$N = 1,867$）、导出描述统计表 `Table1_Descriptive.txt` 与三档星号 OLS 回归表 `Table2_OLS.txt`，并生成两幅白底极简风格 PNG 图形。

---

## 版本状态与路线图

- **v0.1（当前版本）**：完成总控路由、文献综述（v2.0 完整版）、八大家族计量方法地图、十步实证流程、六大因果设计分支诊断、表图与五要素解读规范，以及经 Stata/MP 18.0 验证的纯内置教学范本。
- **后续迭代计划**：补充微观理论数理推导与比较静态规范、扩充中英文顶刊各章节细化写作模板、增加审稿意见逐条回复（Rebuttal）工作流及常见政策评估（交错 DID / 工具变量 / 断点回归）补充范本。

---

## License

本项目采用 [MIT License](LICENSE) 开源。
