*===============================================================================
* ols_nlsw88_exemplar.do — 基础 OLS 实证规范教学范本（Stata 18 纯内置命令）
* 数据来源：Stata 内置 nlsw88.dta（1988 年美国年轻女性调查截面数据）
* 注意：须在无 BOM 的 UTF-8 或 ASCII 编码下运行；批处理日志勿与 .do 同名
*===============================================================================
version 18.0
clear all
set more off
set seed 20261126

capture log close _all
log using "01_ols_run.log", replace text

* 1. 读取内置数据与结构核验
sysuse nlsw88, clear
isid idcode
assert !missing(idcode, wage)
assert wage > 0

* 审计变量缺失，并检验 union 缺失组是否存在系统性工资差异
misstable summarize wage union grade ttl_exp race south smsa occupation
gen byte union_miss = missing(union)
ttest wage, by(union_miss) unequal

* 2. 变量构造与锁定共同分析样本
gen double ln_wage = ln(wage)
label variable ln_wage "Log hourly wage"
label define union_lbl 0 "Nonunion" 1 "Union", replace
label values union union_lbl

gen byte sample_ok = !missing(ln_wage, union, grade, ttl_exp, race, south, smsa, occupation)
count
local N_raw : display %9.0fc r(N)
local N_raw = strtrim("`N_raw'")
count if sample_ok == 1
keep if sample_ok == 1
save "nlsw88_clean.dta", replace

* 动态提取分析样本量与全样本因变量均值，避免任何硬编码
local N_obs : display %9.0fc _N
local N_obs = strtrim("`N_obs'")
summarize ln_wage, meanonly
local mean_y : display %6.3f r(mean)
local mean_y = strtrim("`mean_y'")
display "AUDIT: N_raw=`N_raw' | N_obs=`N_obs' | Mean(ln_wage)=`mean_y'"

* 3. 描述统计（dtable 导表 + Welch 不等方差 t 检验补充核验）
foreach v of varlist ln_wage wage grade ttl_exp {
    display "=== Welch unequal-variance t-test for `v' ==="
    ttest `v', by(union) unequal
}

dtable ln_wage wage grade ttl_exp i.south i.smsa i.race, by(union, tests) ///
    continuous(ln_wage wage grade ttl_exp, statistics(mean sd)) ///
    factor(south smsa race, statistics(fvfrequency fvpercent)) ///
    nformat(%9.3f mean sd) ///
    title("Table 1. Descriptive Statistics by Union Status (NLSW 1988)") ///
    note("Sample: Working women with complete baseline covariates (N = `N_obs'). Tests use linear regression / Pearson chi-squared; Welch unequal-variance t-tests are verified in log.") ///
    export("Table1_Descriptive.txt", replace)

dtable ln_wage wage grade ttl_exp i.south i.smsa i.race, by(union, tests) ///
    continuous(ln_wage wage grade ttl_exp, statistics(mean sd)) ///
    factor(south smsa race, statistics(fvfrequency fvpercent)) ///
    nformat(%9.3f mean sd) ///
    title("Table 1. Descriptive Statistics by Union Status (NLSW 1988)") ///
    note("Sample: Working women with complete baseline covariates (N = `N_obs'). Tests use linear regression / Pearson chi-squared; Welch unequal-variance t-tests are verified in log.") ///
    export("Table1_Descriptive.tex", tableonly replace)

* 4. 图形一：工会与非工会成员对数工资核密度分布对比
summarize ln_wage if union == 0, meanonly
local m0 : display %5.3f r(mean)
summarize ln_wage if union == 1, meanonly
local m1 : display %5.3f r(mean)

twoway (kdensity ln_wage if union == 0, lcolor(navy) lwidth(medthick)) ///
       (kdensity ln_wage if union == 1, lcolor(cranberry) lwidth(medthick) lpattern(dash)), ///
    xline(`m0', lcolor(navy%60) lpattern(dot)) ///
    xline(`m1', lcolor(cranberry%60) lpattern(dot)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    ylabel(0(0.2)1.0, format(%3.1f) angle(horizontal) grid glcolor(gs14) glpattern(solid)) ///
    xlabel(0(1)4, nogrid) ///
    xtitle("Log Hourly Wage (ln USD)", margin(top)) ytitle("Kernel Density") ///
    title("Figure 1. Distribution of Log Hourly Wages by Union Status", size(medsmall) color(black)) ///
    legend(order(1 "Nonunion (mean = `m0')" 2 "Union (mean = `m1')") rows(1) position(6) region(lcolor(none))) ///
    note("Source: Stata built-in nlsw88.dta (common sample, N = `N_obs'). Dotted vertical lines mark group means.", size(vsmall))
graph export "Fig1_Wage_Distribution.png", width(2000) replace

* 5. 主估计：按理论与前定顺序递进纳入控制变量（异方差稳健标准误）
* 注：Model (3) 纳入 i.occupation 作为职业内部条件比较。因工会加入与职业选择可能联立决定，
*     i.occupation 存在潜在“处理后/联立坏控制”张力，故 Model (3) 应解读为组内条件相关而非纯外生因果。
estimates clear
regress ln_wage i.union, vce(robust)
estimates store m1

regress ln_wage i.union grade c.ttl_exp##c.ttl_exp i.race i.south i.smsa, vce(robust)
estimates store m2

regress ln_wage i.union grade c.ttl_exp##c.ttl_exp i.race i.south i.smsa i.occupation, vce(robust)
estimates store m3

* 构建并导出含 Occupation FE 勾选行与因变量均值行的顶刊规范表（.txt 与 .tex）
etable, estimates(m1 m2 m3) ///
    keep(1.union grade ttl_exp c.ttl_exp#c.ttl_exp 2.race 3.race 1.south 1.smsa) ///
    stars(.10 "*" .05 "**" .01 "***", attach(_r_b)) ///
    showstars showstarsnote ///
    column(index) ///
    mstat(N, nformat(%9.0fc) label("Observations")) ///
    mstat(r2_a, nformat(%6.3f) label("Adj. R-squared"))

collect get occ_fe = "No", tags(cmdset[1])
collect get occ_fe = "No", tags(cmdset[2])
collect get occ_fe = "Yes", tags(cmdset[3])
collect label levels result occ_fe "Occupation FE", modify

collect get dep_mean = `mean_y', tags(cmdset[1])
collect get dep_mean = `mean_y', tags(cmdset[2])
collect get dep_mean = `mean_y', tags(cmdset[3])
collect label levels result dep_mean "Dep. var. mean", modify
collect style cell result[dep_mean], nformat(%6.3f)

collect layout (coleq#colname[1.union grade ttl_exp c.ttl_exp#c.ttl_exp 2.race 3.race 1.south 1.smsa _cons]#result[_r_b _r_se] result[occ_fe dep_mean N r2_a]) (cmdset#stars)
collect title "Table 2. OLS Estimates of the Union Log-Wage Differential"
collect notes "Robust standard errors in parentheses. Dep. var. is ln(hourly wage). Model (3) is a within-occupation conditional comparison (13 occupation indicators); interpret cautiously due to potential simultaneous sorting between union status and occupation."
collect export "Table2_OLS.txt", replace
collect export "Table2_OLS.tex", tableonly replace

* 6. 图形二：不同设定下工会估计系数与 95% 置信区间对比图
matrix coef_mat = J(3, 4, .)
estimates restore m1
matrix coef_mat[1,1] = 1, _b[1.union], _b[1.union]-invttail(e(df_r),0.025)*_se[1.union], _b[1.union]+invttail(e(df_r),0.025)*_se[1.union]
estimates restore m2
matrix coef_mat[2,1] = 2, _b[1.union], _b[1.union]-invttail(e(df_r),0.025)*_se[1.union], _b[1.union]+invttail(e(df_r),0.025)*_se[1.union]
estimates restore m3
matrix coef_mat[3,1] = 3, _b[1.union], _b[1.union]-invttail(e(df_r),0.025)*_se[1.union], _b[1.union]+invttail(e(df_r),0.025)*_se[1.union]

preserve
clear
svmat coef_mat, names(c)
rename (c1 c2 c3 c4) (spec beta ci_lo ci_hi)
list, clean noobs
label define spec_lbl 1 "(1) Raw Gap" 2 "(2) + Human Capital" 3 "(3) + Occupation FE"
label values spec spec_lbl

twoway (rcap ci_lo ci_hi spec, lcolor(navy) lwidth(medthick)) ///
       (scatter beta spec, mcolor(navy) msymbol(circle) msize(medium)), ///
    yline(0, lcolor(gs8) lpattern(dash)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    ylabel(0(0.05)0.30, format(%4.2f) angle(horizontal) grid glcolor(gs14)) ///
    xlabel(1 2 3, valuelabel noticks nogrid) xscale(range(0.6 3.4)) ///
    xtitle("Model Specification", margin(top)) ytitle("Union Coefficient (Log Points)") ///
    title("Figure 2. Union Wage Differential Across Specifications (95% CI)", size(medsmall) color(black)) ///
    legend(off) ///
    note("Note: Point estimates and 95% CIs from robust OLS regressions on the common sample (N = `N_obs').", size(vsmall))
graph export "Fig2_Union_Coef.png", width(2000) replace
restore

* 7. 输出对数模型精确百分比换算核对
foreach m in m1 m2 m3 {
    estimates restore `m'
    local pval = 2*ttail(e(df_r), abs(_b[1.union]/_se[1.union]))
    local pct = (exp(_b[1.union]) - 1) * 100
    local ci_l = _b[1.union] - invttail(e(df_r),0.025)*_se[1.union]
    local ci_h = _b[1.union] + invttail(e(df_r),0.025)*_se[1.union]
    display "`m' union coef=" %7.4f _b[1.union] " se=" %7.4f _se[1.union] " t=" %6.2f (_b[1.union]/_se[1.union]) " p=" %7.5f `pval' " ci=[" %6.4f `ci_l' ", " %6.4f `ci_h' "] pct=" %5.2f `pct' "% r2_a=" %5.3f e(r2_a)
}

log close
