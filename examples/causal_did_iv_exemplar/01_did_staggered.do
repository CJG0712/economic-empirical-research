*===============================================================================
* 01_did_staggered.do — 交错 DID 与事件研究规范范本（Stata 18 内置 xthdidregress）
* [教学模拟数据声明]：本脚本生成教学用模拟面板数据，旨在对比传统 TWFE 在动态
* 异质性处理效应下的偏误与现代异质性稳健估计器（xthdidregress），严禁作为真实政策证据。
*===============================================================================
version 18.0
clear all
set more off
set seed 20261126

capture log close did_log
log using "01_did_run.log", replace text name(did_log)

* 1. 生成教学模拟面板数据（300 个个体 x 10 期，交错处理与动态增长效应）
set obs 300
gen int id = _n
gen double alpha_i = rnormal(0, 1.0)
gen int cohort = 0
replace cohort = 5 if id <= 75
replace cohort = 7 if id > 75 & id <= 150
replace cohort = 9 if id > 150 & id <= 210
* id > 210 为永不处理组（cohort == 0），提供纯净对照组

expand 10
bysort id: gen int t = _n
isid id t
xtset id t

gen byte treat = (cohort > 0 & t >= cohort)
gen int event_time = cond(cohort > 0, t - cohort, .)

* 外生前定协变量（时变干扰项）与时间固定效应
gen double x = rnormal(0, 1)
gen double gamma_t = 0.25 * t + 0.05 * sin(t)

* 真实处理效应随暴露期数 k = t - cohort 递增（典型异质性动态处理效应）
gen double true_te = 0
replace true_te = 0.50 * (event_time + 1) if treat == 1 & event_time >= 0
replace true_te = 2.50 if treat == 1 & event_time > 4

gen double eps = rnormal(0, 0.8)
gen double y = 2.0 + alpha_i + gamma_t + 0.40 * x + true_te + eps

label variable y "Simulated Outcome"
label variable treat "Post-Adoption Indicator"
label variable x "Exogenous Covariate"

* 计算模拟数据的真实 ATT（用于教学对照检验）
summarize true_te if treat == 1
local true_att : display %6.4f r(mean)
local N_obs : display %9.0fc _N
local N_obs = strtrim("`N_obs'")
display "TEACHING SIM TRUTH: Overall Treated ATT = `true_att' | N = `N_obs'"

* 2. 反面示范：传统静态双向固定效应 TWFE（因已处理组充当坏对照产生向下偏误）
xtreg y treat x i.t, fe vce(cluster id)
estimates store twfe_naive
local b_twfe : display %6.4f _b[treat]
local se_twfe : display %6.4f _se[treat]
display "NAIVE TWFE: coef = `b_twfe' (SE = `se_twfe') vs True ATT = `true_att'"

* 3. 正面示范：Stata 18 内置异质性稳健 DID（Callaway-Sant'Anna 型回归调整）
xthdidregress ra (y x) (treat), group(id)
estat aggregation, overall
matrix b_ov = r(table)
local att_ov : display %6.4f b_ov[1,1]
local se_ov : display %6.4f b_ov[2,1]
display "XTHDIDREGRESS OVERALL ATT: `att_ov' (SE = `se_ov') vs True ATT = `true_att'"

* 动态事件研究聚合与白底规范事件研究图（用 r(table) 显式绘制逐点 95% 置信区间）
estat aggregation, dynamic
matrix dyn_tab = r(table)
local ncols = colsof(dyn_tab)
local cnames : colnames dyn_tab

preserve
clear
set obs `ncols'
gen int k = .
gen double att = .
gen double ci_lo = .
gen double ci_hi = .
local j = 1
foreach cn of local cnames {
    quietly replace k = real("`cn'") in `j'
    quietly replace att = dyn_tab[1, `j'] in `j'
    quietly replace ci_lo = dyn_tab[5, `j'] in `j'
    quietly replace ci_hi = dyn_tab[6, `j'] in `j'
    local ++j
}
list, clean noobs

twoway (rcap ci_lo ci_hi k, lcolor(navy) lwidth(medium)) ///
       (connected att k, lcolor(navy) lwidth(medthick) mcolor(navy) msymbol(circle) msize(small)), ///
    yline(0, lcolor(gs8) lpattern(dash)) ///
    xline(-0.5, lcolor(cranberry) lpattern(shortdash)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    ylabel(, format(%3.1f) angle(horizontal) grid glcolor(gs14)) ///
    xlabel(-7(1)5, nogrid) ///
    xtitle("Periods Relative to Treatment Adoption (k)", margin(top)) ///
    ytitle("Estimated Dynamic ATET (with 95% Pointwise CI)") ///
    title("Figure A1. Event-Study Estimates via xthdidregress [Simulated Teaching Data]", size(medsmall) color(black)) ///
    legend(off) ///
    note("Note: Simulated balanced panel (300 units x 10 periods, N = `N_obs'). Pre-treatment k < 0 stays near zero; post-treatment grows with k.", size(vsmall))
graph export "Fig_DID_EventStudy.png", width(2000) replace
restore

* 导出简洁静态对比汇总文本与 LaTeX 表格
file open didtbl using "Table_DID_Comparison.txt", write replace
file write didtbl "Table A1. Staggered DID Estimator Comparison [Simulated Teaching Data]" _n
file write didtbl "------------------------------------------------------------------------" _n
file write didtbl "True DGP Overall Treated ATT        : `true_att'" _n
file write didtbl "Naive Static TWFE (biased)          : `b_twfe' (SE = `se_twfe')" _n
file write didtbl "Stata 18 xthdidregress (RA) Overall : `att_ov' (SE = `se_ov')" _n
file write didtbl "Panel Size                          : 300 units x 10 periods (N = `N_obs')" _n
file write didtbl "------------------------------------------------------------------------" _n
file close didtbl

file open didtex using "Table_DID_Comparison.tex", write replace
file write didtex "\begin{tabular}{lcc}" _n
file write didtex "\toprule" _n
file write didtex "Estimator & Overall ATT & Clustered SE \\" _n
file write didtex "\midrule" _n
file write didtex "True DGP Overall ATT (Benchmark) & `true_att' & --- \\" _n
file write didtex "Naive Static TWFE (Biased Control Weights) & `b_twfe' & (`se_twfe') \\" _n
file write didtex "Stata 18 \texttt{xthdidregress} (RA, Robust) & `att_ov' & (`se_ov') \\" _n
file write didtex "\midrule" _n
file write didtex "Observations / Units & \multicolumn{2}{c}{`N_obs' / 300 units} \\" _n
file write didtex "\bottomrule" _n
file write didtex "\end{tabular}" _n
file close didtex

log close did_log
