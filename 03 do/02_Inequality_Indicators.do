/* 	=======================================================================================
	Project:            PAN Inequality Indicators
	Author:             By Kiyomi Cadena
	Organization:       The World Bank-ELCPV
	---------------------------------------------------------------------------------------
	Creation Date:       December 21, 2020 
	Modification Date:   
	Output:             
	======================================================================================= */

/* 	=========================================================================================
									  0: Program set up                                      
=========================================================================================== */

*Setting countries
local countries "pan"

*Tempfiles
tempfile tf_postfile2 
tempname tn2
postfile `tn2' str50(country year indicators zone value obs version) using `tf_postfile2', replace

local i=0
foreach b of local countries  {
	foreach yr of numlist 2011/2019 {
	
	dis "*----------------calculating Poverty Indicators of year `yr' in `b'---------------*"
	local ++i
		
		*----------------------- loading and Harmonization Data -----------------------*
		
		
		datalibweb, country(`b') year(`yr') type(sedlac-03) mod(all) clear
		local version=  "`r(surveyid)'"
		keep if cohh==1
/* 	=========================================================================================
									  1: Inequality indicators                               
=========================================================================================== */

			cap	gen factor11=ipc11_sedlac/ipc_sedlac 
			cap	gen factorppp11=factor11/ppp11 
			gen ipcf_ppp11=(ipcf*factorppp11) 	

			* National
				*Gini
				ainequal ipcf_ppp11  [w=pondera]
				local gini=`r(gini_1)'*100
				local theil=`r(theil_1)'*100
				post `tn2' ("`b'") ("`yr'") ("Gini") ("all") ("`gini'") ("`r(N)'") ("`version'") 
				post `tn2' ("`b'") ("`yr'") ("Theil") ("all") ("`theil'") ("`r(N)'") ("`version'") 
					
				*Gini (sin ceros)
				ainequal ipcf_ppp11  [w=pondera] if ipcf_ppp11!=0
				local gini=`r(gini_1)'*100
				post `tn2' ("`b'") ("`yr'") ("Gini sin ceros") ("all") ("`gini'") ("`r(N)'") ("`version'") 
				
				
			* Urban/Rural
				foreach zone in 0 1  {
				
				if "`zone'"=="0" local lbl_zone "rural"
				else if   "`zone'"=="1" local lbl_zone "urban"
			
				*Gini
				ainequal ipcf_ppp11  [w=pondera] if urbano==`zone'
				local gini=`r(gini_1)'*100
				local theil=`r(theil_1)'*100
				post `tn2' ("`b'") ("`yr'") ("Gini") ("`lbl_zone'") ("`gini'") ("`r(N)'") ("`version'") 
				post `tn2' ("`b'") ("`yr'") ("Theil") ("`lbl_zone'") ("`theil'") ("`r(N)'") ("`version'") 
					
				*Gini (sin ceros)
				ainequal ipcf_ppp11  [w=pondera] if ipcf_ppp11!=0 & urbano==`zone'
				local gini=`r(gini_1)'*100
				post `tn2' ("`b'") ("`yr'") ("Gini sin ceros") ("`lbl_zone'") ("`gini'") ("`r(N)'") ("`version'") 
				}
			
	
		} // end type  of year
} // end type  of survey 

postclose `tn2' 
use `tf_postfile2', clear 
export excel "${out}\Poverty_Indicators_PAN.xlsx", sheetreplace firstrow(variables) sheet("Inequality")  

exit
/* End of do-file */
*><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><