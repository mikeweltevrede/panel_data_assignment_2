clear
est clear
set more off
set mem 10m

cd "C:\Users\mikew\Desktop\University\TilburgUniversity\Master\panel_data_analysis\nonlinear_models\assignment"
global datapath "data"

use "$datapath\data.dta", clear // Load data
keep if WAVE <= 8 // My SNR is 1257560, so I use waves 1 to 8

// Binary Choice Models
// 1.
sum

// Checking unbalancedness in the INCOME and JOB_SAT variables
tab EMPL if missing(INCOME)

tab JOB_SAT if EMPL==1
tab JOB_SAT if EMPL==0 // no observations

tab EMPL if missing(JOB_SAT)

// High number of children; check distribution of NUM_CH:
tab NUM_CH

// Distribution of 0 INCOME/SP_INC:
gen SP_INC_TAB = 0
replace SP_INC_TAB = 1 if SP_INC > 0
tab SP_INC_TAB

gen INCOME_TAB = 0
replace INCOME_TAB = 1 if INCOME > 0
tab INCOME_TAB if !missing(INCOME)

// Income of men versus women:
sum INCOME if SEX==1
sum INCOME if SEX==0
sum SP_INC if SEX==1
sum SP_INC if SEX==0

// 2.
global predictors_bc AGE MARRIED YOUNG_CH NUM_CH EDU_13_15 EDU_15 WHITE

logit EMPL $predictors_bc
est store pooled_logit

// 3.
xtset ID WAVE
xtlogit EMPL $predictors_bc, re
est store re_logit

// 5.
gen AGE2 = AGE^2
xtlogit EMPL $predictors_bc AGE2, re
est store re_logit_age_squared

// 7.
xtlogit EMPL $predictors_bc, fe
est store fe_logit

// 8.
egen MEAN_EDU_13_15 = mean(EDU_13_15), by(ID)
egen MEAN_EDU_15 = mean(EDU_15), by(ID)

xtlogit EMPL $predictors_bc MEAN_EDU_13_15 MEAN_EDU_15 WHITE, re
est store qfe_logit

// 10.
gen EMPL_INIT = EMPL
by ID, sort: replace EMPL_INIT = EMPL[1]

xtlogit EMPL $predictors_bc EMPL_INIT if WAVE > 1, re
est store dynamic_re_logit

estout *,cells(b(star fmt(%9.4f)) se(par fmt(%9.4f))) style(smcl) ///
starlevels(* 0.1 ** 0.05 *** 0.01) varwidth(16) modelwidth(12)

// Tobit Models
est clear

// 1.
global predictors_tobit SEX AGE WHITE MARRIED EDU_13_15 EDU_15
xttobit INCOME $predictors_tobit, ll(0)
est store tobit_out

// 3.
gen MARRIED_SEX = MARRIED*SEX
xttobit INCOME $predictors_tobit MARRIED_SEX, ll(0)
est store tobit_sex_married

// 4.
gen INCOME_INIT = INCOME
by ID, sort: replace INCOME_INIT = INCOME[1]

xttobit INCOME $predictors_tobit INCOME_INIT if WAVE > 1, ll(0)
est store dynamic_tobit

estout *,cells(b(star fmt(%9.4f)) se(par fmt(%9.4f))) style(smcl) ///
starlevels(* 0.1 ** 0.05 *** 0.01) varwidth(16) modelwidth(12)

// Ordered Response Models
est clear

// 1.
xtoprobit JOB_SAT AGE INCOME EDU_13_15 EDU_15 if EMPL==1
est store ordered_probit

estout *,cells(b(star fmt(%9.4f)) se(par fmt(%9.4f))) style(smcl) ///
starlevels(* 0.1 ** 0.05 *** 0.01) varwidth(16) modelwidth(12)
