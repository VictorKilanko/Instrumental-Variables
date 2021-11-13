clear

if c(username)=="victo"{
	global raw_dta "C:\Users\victo\OneDrive\Documents\Econometrics_2\Raw_data\PS3"
	global analytical_dta "C:\Users\victo\OneDrive\Documents\Econometrics_2\Analytical_data"
	global do_file "C:\Users\victo\OneDrive\Documents\Econometrics_2\Do_file"
	global logs "C:\Users\victo\OneDrive\Documents\Econometrics_2\Log_file"
	global tables "C:\Users\victo\OneDrive\Documents\Econometrics_2\Tables\PS3"
}

cd "${raw_dta}"
use "coalIV.dta", clear

***OLS Estimation- First difference
keep if state== 1 | state== 2 | state== 3 |state== 4 
gen l_afdc=log(afdc/afdc[_n-1])
gen l_earn=log(earn/earn[_n-1])
gen l_pop=log(pop/pop[_n-1])
gen l_coalres = log(coalres/coalres[_n-1])
gen l_coalprice = log(coalprice/coalprice[_n-1]) 
gen state_year = state*year
gen coal_IV = l_coalres*l_coalprice // my IV
reg l_afdc l_earn l_pop state_year  // 
eststo est1
outreg2 using "Table2d.tex", replace title (Earnings on AFDC) cti(OLS)

***2SLS Estimation without standard error
*FIRST STAGE
reg l_earn coal_IV 

*predicting my x-hat next
predict x_hat, xb
outreg2 using "Table2d.tex", append cti(First Stage)

*Second Stage
reg l_afdc x_hat
outreg2 using "Table2d.tex", append cti(2SLS)

***2SLS with bootstrapped standard errors
bootstrap: reg l_afdc x_hat, r 
outreg2 using "Table2d.tex", append cti(2SLS-Btsp)

***2SLS with control functions
reg l_earn coal_IV, r 
predict hat_x, res
reg l_afdc l_earn hat_x, r
outreg2 using "Table2d.tex", append cti(2SLS-Control)

***2SLS with controls and bootstrapped standard errors
bootstrap: reg l_afdc l_earn hat_x, r 
outreg2 using "Table2d.tex", append cti(2SLS-Btsp-cont)

****IV with single regression
ivregress 2sls l_afdc (l_earn=coal_IV)
eststo est2
predict resid, res
outreg2 using "Table2d.tex", append cti(IV)

hausman est1

estat firststage

************If I were to include lags in my estimations
gen int effyear = 1979
gen postyear = year-effyear 
replace postyear = 0 if postyear == .

gen lag1=0
replace lag1=1 if postyear ==-2

gen lag2=0
replace lag2=1 if postyear ==-1 
reg l_afdc l_earn l_pop lag1 lag2 state_year  // First difference OLS with lags
