*===============================================================================
* 02_iv_2sls.do — 工具变量（IV/2SLS）与弱工具诊断规范范本（Stata 18 纯内置命令）
* [教学模拟数据声明]：本脚本生成教学用模拟横截面数据（真实 LATE = 1.50，存在正向
* 遗漏变量混杂导致 OLS 向上偏误），仅用于演示第一阶段、简约式、2SLS 及 Lee et al.
* (2022) tF 标尺与 Anderson-Rubin 诊断流程，严禁作为真实实证结论。
*===============================================================================
version 18.0
clear all
set more off
set seed 20261126

capture log close iv_log
log using "02_iv_run.log", replace text name(iv_log)

* 1. 生成含内生混杂 U 与外生工具 Z 的教学模拟数据（N = 2,000）
set obs 2000
gen int id = _n
isid id

gen double x = rnormal(0, 1)
gen double u = rnormal(0, 1)
gen double z = rnormal(0, 1)

* 第一阶段：D 受有效工具 Z 与不可观测混杂 U 共同驱动
gen double d = 0.5 + 0.65 * z + 0.30 * x + 0.70 * u + rnormal(0, 0.7)
* 结构方程：真实因果效应为 1.50 * d；因 U 同时正向进入 d 与 y，OLS 将严重高估
gen double y = 1.0 + 1.50 * d + 0.80 * x + 1.10 * u + rnormal(0, 0.8)

label variable y "Simulated Outcome (Y)"
label variable d "Endogenous Treatment (D)"
label variable z "Exogenous Instrument (Z)"
label variable x "Exogenous Covariate (X)"

local N_obs : display %9.0fc _N
local N_obs = strtrim("`N_obs'")
summarize y, meanonly
local mean_y : display %6.3f r(mean)
local mean_y = strtrim("`mean_y'")
summarize d, meanonly
local mean_d : display %6.3f r(mean)
local mean_d = strtrim("`mean_d'")

* 2. 完整汇报四联模型：OLS / First Stage / Reduced Form / 2SLS
estimates clear

* (1) OLS（受 U 污染向上偏误）
regress y d x, vce(robust)
estimates store iv_ols

* (2) 第一阶段（First Stage）
regress d z x, vce(robust)
estimates store iv_fs
test z
local fs_f : display %7.2f r(F)
local fs_f = strtrim("`fs_f'")

* (3) 简约式（Reduced Form）与 Anderson-Rubin 弱工具稳健检验（恰识别单工具下等价）
regress y z x, vce(robust)
estimates store iv_rf
test z
local ar_f : display %7.2f r(F)
local ar_p : display %6.4f r(p)
display "ANDERSON-RUBIN WEAK-IV ROBUST TEST (Reduced Form F on Z): F=`ar_f', p=`ar_p'"

* (4) 2SLS 主估计
ivregress 2sls y x (d = z), vce(robust)
estimates store iv_2sls
estat firststage
estat endogenous

* 核对 Lee et al. (2022, AER) 无需膨胀标准误的 F >= 104.7 阈值
display "LEE ET AL. (2022) CHECK: First-stage robust F = `fs_f' (threshold for unadjusted 5% t-test = 104.7)"

* 3. 导出规范回归对比表（.txt 与 .tex）
etable, estimates(iv_ols iv_fs iv_rf iv_2sls) ///
    keep(d z x) ///
    stars(.10 "*" .05 "**" .01 "***", attach(_r_b)) ///
    showstars showstarsnote ///
    column(index) ///
    mstat(N, nformat(%9.0fc) label("Observations")) ///
    mstat(r2, nformat(%6.3f) label("R-squared"))

collect get dep_name = "Y (OLS)", tags(cmdset[1])
collect get dep_name = "D (FS)", tags(cmdset[2])
collect get dep_name = "Y (RF)", tags(cmdset[3])
collect get dep_name = "Y (2SLS)", tags(cmdset[4])
collect label levels result dep_name "Outcome / Model", modify

collect get dep_m = "`mean_y'", tags(cmdset[1])
collect get dep_m = "`mean_d'", tags(cmdset[2])
collect get dep_m = "`mean_y'", tags(cmdset[3])
collect get dep_m = "`mean_y'", tags(cmdset[4])
collect label levels result dep_m "Dep. var. mean", modify

collect get fs_stat = "---", tags(cmdset[1])
collect get fs_stat = "`fs_f'", tags(cmdset[2])
collect get fs_stat = "---", tags(cmdset[3])
collect get fs_stat = "`fs_f'", tags(cmdset[4])
collect label levels result fs_stat "First-stage robust F", modify

collect layout (coleq#colname[d z x _cons]#result[_r_b _r_se] result[dep_name dep_m fs_stat N r2]) (cmdset#stars)
collect title "Table A2. OLS, First Stage, Reduced Form, and 2SLS [Simulated Teaching Data]"
collect notes "Simulated cross-sectional data (True LATE = 1.500, N = `N_obs'). Robust standard errors in parentheses. Anderson-Rubin reduced-form F = `ar_f' (p = `ar_p')."
collect export "Table_IV_2SLS.txt", replace
collect export "Table_IV_2SLS.tex", tableonly replace

log close iv_log
