/* 	=======================================================================================
	Project:            PAN Growth Incidence Curve
	Author:             By Kiyomi Cadena
	Organization:       The World Bank-ELCPV
	---------------------------------------------------------------------------------------
	Creation Date:       January 4, 2021 
	Modification Date:   
	Output:              GIC_100_SEDLAC         
	======================================================================================= */

/* 	=========================================================================================
									  0: Program set up                                      
=========================================================================================== */

global excel "C:\Users\wb343674\WBG\Javier Romero - Panama\Pre-SCD\04 results"

*Setting country
local countries "pan"

*** NATIONAL 
foreach n of numlist 2015 2019 {

	datalibweb, country(`countries') year(`n') type(sedlac-03) mod(all) clear
	keep if cohh==1
	
	cap	gen factor11=ipc11_sedlac/ipc_sedlac 
	cap	gen factorppp11=factor11/ppp11 
	gen ipcf_ppp11=(ipcf*factorppp11) 	
	
	sum ipcf_ppp11 [aw=pondera], d
	local total_mean = r(mean)
	local total_median = r(p50)
	
	quantiles ipcf_ppp11  [aw=pondera], n(100) gen(pctiles) stable
	keep ipcf_ppp11 pctiles pondera 
	collapse (mean) ipcf_ppp11 [w = pondera], by(pctiles)

	rename ipcf_ppp11 Mean`n'      // Ingreso promedio por percentiles
	gen Total`n' = `total_mean'
	gen Median`n' = `total_median'

	tempfile temp`n'
	save `temp`n'', replace 
}


merge 1:1 pctiles using `temp2015', nogen

*** 2015 - 2019 
gen GIC_15_19   = 100*((Mean2019/Mean2015)^(1/(2019-2015))-1)  	// GIC 2015-2019
gen Total_15_19 = 100* ((Total2019/Total2015)^(1/(2019-2015))-1)	// Mean Growth 2015-2019
gen Median_15_19 = 100* ((Median2019/Median2015)^(1/(2019-2015))-1)	// Median Growth 2015-2019

keep pctiles GIC* Total_* Median_*

export excel using "$excel\GIC_100_SEDLAC.xlsx", sheet(national_cohh==1) sheetreplace keepcellfmt first(var)  


*** URBAN 
foreach n of numlist 2015 2019 {
	datalibweb, country(`countries') year(`n') type(sedlac-03) mod(all) clear
	keep if urbano==1

	cap	gen factor11=ipc11_sedlac/ipc_sedlac 
	cap	gen factorppp11=factor11/ppp11 
	gen ipcf_ppp11=(ipcf*factorppp11) 	
	
	sum ipcf_ppp11 [aw=pondera], d
	local total_mean = r(mean)
	local total_median = r(p50)
	
	quantiles ipcf_ppp11  [aw=pondera], n(100) gen(pctiles) stable
	keep ipcf_ppp11 pctiles pondera 
	collapse (mean) ipcf_ppp11 [w = pondera], by(pctiles)

	rename ipcf_ppp11 Mean`n'      // Ingreso promedio por percentiles
	gen Total`n' = `total_mean'
	gen Median`n' = `total_median'
	
	tempfile temp`n'
	save `temp`n'', replace 
}

merge 1:1 pctiles using `temp2015', nogen

*** 2015 - 2019 
gen GIC_15_19   = 100*((Mean2019/Mean2015)^(1/(2019-2015))-1)  	// GIC 2015-2019
gen Total_15_19 = 100* ((Total2019/Total2015)^(1/(2019-2015))-1)	// Mean Growth 2015-2019
gen Median_15_19 = 100* ((Median2019/Median2015)^(1/(2019-2015))-1)	// Median Growth 2015-2019

keep pctiles GIC* Total_* Median_*

export excel using "$excel\GIC_100_SEDLAC.xlsx", sheet(urban) sheetreplace keepcellfmt first(var) 

*** RURAL 
foreach n of numlist 2015 2019 {
	datalibweb, country(`countries') year(`n') type(sedlac-03) mod(all) clear
	keep if urbano==0

	cap	gen factor11=ipc11_sedlac/ipc_sedlac 
	cap	gen factorppp11=factor11/ppp11 
	gen ipcf_ppp11=(ipcf*factorppp11) 	
	
	sum ipcf_ppp11 [aw=pondera], d
	local total_mean = r(mean)
	local total_median = r(p50)
	
	quantiles ipcf_ppp11  [aw=pondera], n(100) gen(pctiles) stable
	keep ipcf_ppp11 pctiles pondera 
	collapse (mean) ipcf_ppp11 [w = pondera], by(pctiles)

	rename ipcf_ppp11 Mean`n'      // Ingreso promedio por percentiles
	gen Total`n' = `total_mean'
	gen Median`n' = `total_median'
	
	tempfile temp`n'
	save `temp`n'', replace 
}

merge 1:1 pctiles using `temp2015', nogen

*** 2015 - 2019 
gen GIC_15_19   = 100*((Mean2019/Mean2015)^(1/(2019-2015))-1)  	// GIC 2015-2019
gen Total_15_19 = 100* ((Total2019/Total2015)^(1/(2019-2015))-1)	// Mean Growth 2015-2019
gen Median_15_19 = 100* ((Median2019/Median2015)^(1/(2019-2015))-1)	// Median Growth 2015-2019

keep pctiles GIC* Total_* Median_*

export excel using "$excel\GIC_100_SEDLAC.xlsx", sheet(rural) sheetreplace keepcellfmt first(var) 

exit
/* End of do-file */
*><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
