/* 	=======================================================================================
	Project:            Poverty and Inequality Indicators: Inequality Indicators
	Author:             By Kiyomi Cadena
	Organization:       The World Bank-ELCPV
	---------------------------------------------------------------------------------------
	Creation Date:       December 21, 2021
	Modification Date:   
	Output:             
	======================================================================================= */

/* 	=========================================================================================
									  0: Program set up                                      
=========================================================================================== */

*Setting countries
local countries "pan"
local period=""
local survey=""

*Tempfiles
tempfile tf_postfile3 
tempname tn3
postfile `tn3' str50(country year period indicators zone value obs) using `tf_postfile3', replace

local i=0
foreach b of local countries  {
	foreach yr of numlist 2011/2019 {
	
	dis "*----------calculating Mean and Botom 40 of year `yr' in `b'---------------*"
	local ++i
		
		datalibweb, country(`b') year(`yr') type(sedlac-03) mod(all) clear

		keep if cohh==1 
/* 	=========================================================================================
									1: Mean and Botom 40                                     
=========================================================================================== */
		
*Creating  ipcf_ppp11
		cap	gen factor11=ipc11_sedlac/ipc_sedlac 
		cap	gen factorppp11=factor11/ppp11 
		gen ipcf_ppp11=(ipcf*factorppp11) 

		* National 
		*Mean
		drop if hogarsec==1
		
		sum ipcf_ppp11 [aw=pondera], d
		post `tn3' ("`b'") ("`yr'") ("`period'") ("Mean Income")  ("all") ("`r(mean)'") ("`r(N)'")
		post `tn3' ("`b'") ("`yr'") ("`period'") ("Median Income") ("all") ("`r(p50)'") ("`r(N)'")
		
		*Botom 40
		cap drop b40
		b40 ipcf_ppp11 [aw=pondera], generate(b40) 
		sum ipcf_ppp11 [aw=pondera] if b40==1 , meanonly
		post `tn3' ("`b'") ("`yr'") ("`period'") ("b40 Mean Income")  ("all") ("`r(mean)'") ("`r(N)'")
			
		* Urban and Rural 
		foreach zone in 0 1  {
			
			if "`zone'"=="0" local lbl_zone "rural"
			else if   "`zone'"=="1" local lbl_zone "urban"
			
		*Mean
		sum ipcf_ppp11 [aw=pondera] if urbano==`zone', d 
		post `tn3' ("`b'") ("`yr'") ("`period'") ("Mean Income")  ("`lbl_zone'") ("`r(mean)'") ("`r(N)'")
		post `tn3' ("`b'") ("`yr'") ("`period'") ("Median Income") ("`lbl_zone'") ("`r(p50)'") ("`r(N)'")
		
		*Botom 40
		cap drop b40
		b40 ipcf_ppp11 [aw=pondera] if urbano==`zone', generate(b40) 
		sum ipcf_ppp11 [aw=pondera] if urbano==`zone' & b40==1 , meanonly
		post `tn3' ("`b'") ("`yr'") ("`period'") ("b40 Mean Income")  ("`lbl_zone'") ("`r(mean)'") ("`r(N)'")	
			
			}
		
		} // end type  of year
} // end type  of survey 

postclose `tn3' 
use `tf_postfile3', clear 
export excel "${out}\Poverty_Indicators_PAN.xlsx", sheetreplace firstrow(variables) sheet("Mean_Botom40")  


exit
/* End of do-file */
*><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><