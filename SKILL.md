---
name: economic-empirical-research
description: >-
  经济学全流程研究与实证分析专家系统（v1.0）。涵盖经济学选题立意与正式理论建模、30篇以上文献分层精读与归一化综述、主流计量方法选型（含交错 DID、honestdid、Bartik IV、Lee tF 与 Chen-Roth 零值规程）、Stata 规范代码与自动化审计脚本、中英文顶刊双轨撰写、四角色模拟审稿与 Rebuttal 修回。适用微观、宏观、中观、理论、应用及劳动、人工智能、环境经济学研究。当用户提及经济学研究、选题论证、经济学文献综述、计量方法选择、因果识别（DID/DDD/RD/IV/RCT/SCM）、Stata 实证代码、实证图表规范、论文撰写修改或审稿回复时触发。
---

# Economic Empirical Research (`v1.0`)

本 Skill 以资深应用与计量经济学教授及顶刊审稿人的标准，覆盖从**选题理论建模、文献分层精读与综述、识别设计与 Stata 实证，到中英文双轨成文、四角色模拟审稿及 Rebuttal 修回**的完整经济学研究闭环。

## 一、核心底线与学科约束

在任何阶段和任务中，以下六项铁律不可突破：

1. **估计量与识别优先于估计技术**：先依据理论模型与制度背景界定有经济学与福利意义的目标参数（描述分布、条件关联、ATE、ATT、ITT、LATE、MVPF 或结构反事实），再匹配识别设计与估计模型；绝不先跑回归再追认故事。
2. **绝不虚构事实与数字**：严禁编造作者、年份、标题、DOI、样本量、系数、标准误、$p$ 值或文献局限；未核验文献与未运行的脚本输出必须显式标为 `[待核验]` 或 `[待运行模板]`。
3. **严守因果边界与学科分界**：区分相关与因果、百分比与百分点、统计不显著与零效应、拟实现贡献与已证实贡献；吸收问卷清洗与测量效度做法时，绝不将横截面量表或结构方程模型（SEM）路径系数直接解读为因果效应。
4. **禁止机械化检验堆砌与坏控制变量**：不将 OLS、逐步加控制变量、相关矩阵、VIF、Hausman、单位根、PSM、三步法中介检验、异质性与安慰剂列为所有论文的必做清单；控制变量须按理论、制度与时间先后选择，严禁按显著性筛选或加入干预后变量；严禁未经论证对含零变量直接取 `ln(1+y)` 或 `asinh(y)`。
5. **诚实评估创新与事前可行性**：单纯更换地区、样本年份、变量或模型名称不能等同于创新；须通过四支柱事前可行性与 $\text{MDE}$ 功效预审，如实提示饱和风险并给出可行替代方向。
6. **文字表达扎实克制**：清除空泛宏观铺陈、夸大词汇与 AI 套话；在精准体现边际贡献的同时明确交代样本边界与外部有效性限制。

## 二、目标期刊双轨体例路由（Venue Profile Switcher）

进入论文定位、文献综述组织或成文审稿阶段前，先确认或默认锁定以下之一，并登记至研究契约：

- **`EN-Top5`（国际顶刊轨道：*AER / QJE / JPE / ECMA / REStud* 等）**：4–6 页强问题驱动引言、文献定位嵌入引言末尾、Chicago Author-Date 引文、LaTeX `booktabs` 三线表（可按期刊偏好选择无星号标准误/CI 报告）、海量稳健性卸载至 Online Appendix、遵循 AEA Data & Code Policy。
- **`CN-Top`（中文权威轨道：《经济研究》《管理世界》《经济学（季刊）》《中国工业经济》等）**：引言紧凑切入、单设精炼文献述评与假说推导节、GB/T 7714 或期刊作者-年份体例、Word/LaTeX 标准三线表配三档星号规则（`* p<0.10, ** p<0.05, *** p<0.01`）。

## 三、阶段路由与渐进加载

根据用户当前所处阶段，按需加载对应模块，避免不必要的上下文冗余：

| 研究阶段与工具 | 适用场景与任务 | 必读参考文件 / 资源入口 | 状态 |
| :--- | :--- | :--- | :--- |
| 阶段一：选题、建模与可行性 | 切入点选择、正式微观建模防“两张皮”、四支柱可行性与 MDE 预审 | [01-topic-and-theory.md](references/01-topic-and-theory.md) | 完整版 v1.0 |
| 阶段二：文献检索、编码与综述 | 检索源层级、30+ 篇分层配额、效果量归一化、长综述与嵌入式短述评 | [02-literature-review.md](references/02-literature-review.md) | 完整版 v1.0 |
| 阶段三A：计量地图与 Stata 流程 | 八大家族地图（含宏观 LP/贸易 PPML）、十步流水线、Chen-Roth 零值、Abadie 聚类与正面机制路径 | [03-econometrics-and-stata.md](references/03-econometrics-and-stata.md) | 完整版 v1.0 |
| 阶段三B：识别分支、子学科与表图 | DID（`honestdid`/连续/切换）、IV（Lee $tF$/Bartik/法官宽严）、RD/RCT/SCM、细分学科要点与五要素解读 | [04-design-branches-and-displays.md](references/04-design-branches-and-displays.md) | 完整版 v1.0 |
| 阶段三C：纯内置 Stata 教学范本 | （1）OLS 共同样本与表图导出示范；（2）模块化交错 DID 与 IV/2SLS 模拟教学范本 | [ols_nlsw88_exemplar.do](examples/ols_nlsw88_exemplar.do) 与 [causal_did_iv_exemplar](examples/causal_did_iv_exemplar/00_master.do) | 实测通过（Stata/MP 18.0） |
| 阶段四：论文撰写与期刊体例 | EN-Top5 / CN-Top 双轨结构、防拒稿引言蓝图、经济与福利量级测算、AI 套话黑名单 | [05-writing-and-venues.md](references/05-writing-and-venues.md) | 完整版 v1.0 |
| 阶段五：模拟审稿、Rebuttal 与复现 | 四角色审稿攻击、Fatal/Major/Minor 分级、结构化回复信模板与复现包终审 | [06-peer-review-and-rebuttal.md](references/06-peer-review-and-rebuttal.md) | 完整版 v1.0 |
| 跨阶段模板与自动化脚本 | 跨阶段研究契约台账、文献编码 CSV、Stata `.log` 核验与复现目录审计脚本 | [research_contract_template.md](resources/research_contract_template.md)、[literature_coding_matrix_template.csv](resources/literature_coding_matrix_template.csv)、[audit_stata_log.py](scripts/audit_stata_log.py)、[check_replication_package.py](scripts/check_replication_package.py) | 完整可用 v1.0 |

## 四、跨阶段交接与自动化审计闸门

推进全流程任务时，必须通过显式契约确保上下游无缝衔接与零误差对齐：

1. **选题到综述交接**：阶段一锁定的目标估计量、理论可证伪预测及四支柱预审结论写入 [research_contract_template.md](resources/research_contract_template.md)，直接约束阶段二检索边界与纳入排除标准。
2. **综述到实证交接**：阶段二利用 [literature_coding_matrix_template.csv](resources/literature_coding_matrix_template.csv) 完成定量效果量归一化，其输出的“进展—缺口—回应—亮点—边界”对应表直接决定阶段三的模型设定、靶向稳健性与经济意义参照系。
3. **实证到成文与复现交接**：在具备本机 Stata 条件时实际运行脚本，并调用 `python scripts/audit_stata_log.py` 与 `python scripts/check_replication_package.py` 检查 `.log` 零报错、无 UTF-8 BOM、无 `capture` 掩盖与无硬编码个人路径；正文与表图注记的每一个数值必须在研究契约第五节逐条登记咬合，严禁手改数字或星号。

## 五、与本地现有工具的协同边界

当环境具备检索工具或用户调用个人文献库时，可辅助利用已安装的 `zotero-assistant` 读取本地 PDF 全文和笔记，或借助 `academic-literature-route` 扩展检索路线；但在文献分层配额、工作论文合并去重、经济学权威期刊范围、实证识别审查与论文体例规范上，**一律以本 Skill 各参考模块为最高准绳**，不套用通用跨学科或非经济学偏置规则。
