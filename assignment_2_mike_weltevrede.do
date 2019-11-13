clear
set more off
set mem 10m

cd "C:\Users\mikew\Desktop\University\TilburgUniversity\Master\panel_data_analysis\nonlinear_models\assignment"
global datapath "data"
global output "output"

// Load data
use "$datapath\data.dta", clear

// My SNR is 1257560, so I use waves 1 to 8 (45028 observations deleted)
keep if WAVE <= 8

// Binary Choice Models
/* 1.
Present a table with descriptive statistics of the variables of interest (not
ID, YEAR, WAVE) and briefly comment on what you think are the most interesting
numbers in the table (1 page max). */
sum

/* There is unbalancedness in the INCOME variable. For all variables, except for
JOB_SAT and INCOME, we have 90056 observations, but for INCOME we have 88750
observations. */

/* Number of children has a maximum of 11, this seems high. We see that there
are indeed quite a few high numbers of children but that this is minimal in the
face of a total of 90,056 observations. */
tab NUM_CH

/* SP_INC has a higher maximum, but a lower mean than INCOME. We see that almost
70% has SP_INC equal to 0 while only 47% has no INCOME.*/
tab SP_INC if SP_INC == 0 // 62,416 / 90,056 = 69.31 percent
tab INCOME if INCOME == 0 // 42,123 / 88,750 = 47.46 percent

/* To confirm current societal suspicions, note that mean INCOME for SEX==0
(men) is substantially higher than for SEX==1 (women) and that mean SP_INC for
men is lower than for women, assuming a dominance of heterosexual couples and
that men earn more than women, on average.*/
sum INCOME if SEX==1
sum INCOME if SEX==0
sum SP_INC if SEX==1
sum SP_INC if SEX==0
