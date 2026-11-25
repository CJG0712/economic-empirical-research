*===============================================================================
* 00_master.do — 因果识别模块化复现总控范本（Stata 18 纯内置命令）
* 用途：示范 AEA / 顶刊标准相对路径复现入口，依次运行交错 DID 与 IV/2SLS 模块
* 说明：内部两个子脚本均采用明确标示的“教学模拟数据”，不得当作真实政策或研究证据
*===============================================================================
version 18.0
clear all
set more off

global root "."

capture log close _all
log using "$root/00_master_run.log", replace text

display "=== Running Module 1: Staggered DID vs Naive TWFE ==="
do "$root/01_did_staggered.do"

display "=== Running Module 2: IV / 2SLS with First-Stage & Weak-IV Checks ==="
do "$root/02_iv_2sls.do"

display "=== Master Replication Completed Successfully ==="
log close
