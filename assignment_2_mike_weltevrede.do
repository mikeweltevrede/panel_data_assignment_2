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
JOB_SAT and INCOME, we have 90,056 observations, but for INCOME we have 88,750
observations. For the missing values in INCOME, we tabulate the EMPL variable.
We would expect that INCOME is missing when EMPL==0, since perhaps respondents
do not fill in INCOME as 0 but rather leave it blank. However, in the output we
see that INCOME is only missing if EMPL==1.*/
tab EMPL if missing(INCOME)

/* For JOB_SAT, we have only 48,824 observations. Using the tab commands as
below shows that there are 48,824 observations for EMPL equal to 1. JOB_SAT is
missing for all cases where EMPL equal 0.*/
tab JOB_SAT if EMPL==1
tab JOB_SAT if EMPL==0 // no observations

/* Vice versa, we see that EMPL can be both 0 and 1 for missing JOB_SAT, but
that in 99.14 percent of the cases it is only missing for EMPL equal to 0.
*/
tab EMPL if missing(JOB_SAT)

/* NUM_CH has a maximum of 11, which seems high. We see that there are indeed
quite a few observations for high NUM\_CH but that this is minimal in the face
of a total of 90,056 observations, especially given that the time aspect (i.e.
repetition of the same individual) is not taken into account yet. */
tab NUM_CH

/* SP_INC has a higher maximum, but a lower mean than INCOME. We see that almost
70% has SP_INC equal to 0 while INCOME is 0 in only 47\% of the cases. */
gen SP_INC_TAB = 0
replace SP_INC_TAB = 1 if SP_INC > 0
tab SP_INC_TAB

gen INCOME_TAB = 0
replace INCOME_TAB = 1 if INCOME > 0
tab INCOME_TAB if !missing(INCOME)

/* To confirm current societal suspicions, note that mean INCOME for SEX==0
(men) is substantially higher than for SEX==1 (women) and that mean SP_INC for
men is lower than for women, assuming a dominance of heterosexual couples and
that men earn more than women, on average. */
sum INCOME if SEX==1
sum INCOME if SEX==0
sum SP_INC if SEX==1
sum SP_INC if SEX==0

/* 2.
Use a static pooled logit model to explain employment (EMPL) from age, marital
status, presence of young children, number of children, education, and a dummy
for white people. Use people with at most a high school degree as the reference
group for the education dummies. Comment on the results. */

logit EMPL AGE MARRIED YOUNG_CH NUM_CH EDU_13_15 EDU_15 WHITE
est store pooled_logit

/*
1) All results are significant at a significance level of 0.001
2) The dummy WHITE has a negative coefficient, referring to a negative log-odds,
which seems unlikely in and of itself given possible discriminatory tendencies
in society when hiring new people.
*/

/* 3.
Estimate a static random effects logit model using the same specification as in
the previous question and comment on the results. What are the main differences
compared to the results of the pooled model?
*/
xtset ID WAVE
xtlogit EMPL AGE MARRIED YOUNG_CH NUM_CH EDU_13_15 EDU_15 WHITE, re
est store re_logit

estout *,cells(b(star fmt(%9.4f)) se(par fmt(%9.4f))) style(smcl) ///
starlevels(* 0.1 ** 0.05 *** 0.01) varwidth(16) modelwidth(12)

/*
1) All effects apart from AGE are more pronounced (deviating more from zero)
2) All standard errors are higher
*/


/* 4.
Which of the two models estimated so far is more appropriate? Support your 
answer using a statistical test. Mention all steps of your test.
*/

/* Note, rho is 71%, so there is a large portion of unobserved heterogeneity
in the individual effects, so RE will be the better model. We see this due to
0 not being included in the confidence interval of rho. We reject the hypothesis
that rho=0 (pooled logit) in favour of the RE model. */

/* We use a LRT.
- Loglikelihood pooled = -49944.725
- Loglikelihood RE = -36144.325
- 2*(-36144.325 - (-49944.725)) = 27600.802
- chi2_df;0.95 <= 150 < 27600.802 so we reject H0: pooled logit in favour of
  the RE model
*/

/* 5.
Start from the model that you selected in the previous question. Investigate
whether there is a non-monotonic effect of age on employment status using a
formal test.
*/
gen AGE2 = AGE^2
xtlogit EMPL AGE AGE2 MARRIED YOUNG_CH NUM_CH EDU_13_15 EDU_15 WHITE, re
est store re_logit_age_squared

/* We see that AGE2 has a p-value of 0.035, so we find statistical evidence at
a significance level of 0.05 that there is a non-monotonic effect of age on
employment status, ceteris paribus.
*/

/* 6.
Using the model of the previous question, compute the marginal effect of a one
year increase in age on the probability to be employed for an observation with
probability 0.5 to be employed and age 40 years old.
- We get -0.0252.

At which age would the marginal effect be equal to zero?
- AGE = - \beta_{AGE} / 2 \beta_{AGE2} = 76.96
*/


/* 
*/


/* 7.

*/

/* 8. 


egen x_m=mean(x), by(ID)
*/

/* 9.

*/

/* 10.


Generate Y_init = Y; replace Y_init=l.Y if WAVE==2; replace Y_init=l2.Y if WAVE==3; ….; replace Y_init=l11.Y if WAVE==12.
*/

// For LaTeX file
/*
estout *,cells(b(star fmt(%9.4f)) se(par fmt(%9.4f))) style(tex) ///
starlevels(* 0.1 ** 0.05 *** 0.01) varwidth(16) modelwidth(12)
*/
