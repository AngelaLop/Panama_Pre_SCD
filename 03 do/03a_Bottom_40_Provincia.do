/* 	=======================================================================================
	Project:            Poverty and Inequality Indicators: Inequality Indicators
	Author:             By Kiyomi Cadena
	Organization:       The World Bank-ELCPV
	---------------------------------------------------------------------------------------
	Creation Date:       January 24, 2022
	Modification Date:   
	Output:             Poverty_Indicators_PAN       
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
	foreach yr of numlist 2015/2019 {
	
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
		
		* Regions
		gen region=substr( region_est2 ,1,2)
		destring region, replace

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
			
			
		* Provincia
			forvalues zone = 1(1)13 {
				
			*Mean
			sum ipcf_ppp11 [aw=pondera] if region==`zone', d 
			post `tn3' ("`b'") ("`yr'") ("`period'") ("Mean Income")  ("`zone'") ("`r(mean)'") ("`r(N)'")
			post `tn3' ("`b'") ("`yr'") ("`period'") ("Median Income") ("`zone'") ("`r(p50)'") ("`r(N)'")
			
			*Botom 40
			cap drop b40
			b40 ipcf_ppp11 [aw=pondera] if region==`zone', generate(b40) 
			sum ipcf_ppp11 [aw=pondera] if region==`zone' & b40==1 , meanonly
			post `tn3' ("`b'") ("`yr'") ("`period'") ("b40 Mean Income")  ("`zone'") ("`r(mean)'") ("`r(N)'")	
				
			}	
		
		* Comarcas 
			*Mean			
			sum ipcf_ppp11 [aw=pondera] if (region==10|region==11|region==12), d
			post `tn3' ("`b'") ("`yr'") ("`period'") ("Mean Income")  ("Comarcas") ("`r(mean)'") ("`r(N)'")
			post `tn3' ("`b'") ("`yr'") ("`period'") ("Median Income") ("Comarcas") ("`r(p50)'") ("`r(N)'")
			
			*Botom 40
			cap drop b40
			b40 ipcf_ppp11 [aw=pondera] if (region==10|region==11|region==12), generate(b40) 
			sum ipcf_ppp11 [aw=pondera] if b40==1 , meanonly
			post `tn3' ("`b'") ("`yr'") ("`period'") ("b40 Mean Income")  ("Comarcas") ("`r(mean)'") ("`r(N)'")
		
		
		} // end type  of year
} // end type  of survey 

postclose `tn3' 
use `tf_postfile3', clear 

	* Labels
	replace zone="0" if zone=="all"
	replace zone="99" if zone=="rural"
	replace zone="98" if zone=="urban"
	replace zone="97" if zone=="Comarcas"
	destring zone, replace
	label define zone  0"National" 1 "Bocas del Toro" 2"Cocle" 3"Colon" 4"Chiriqui" 5"Darien" 6"Herrera" 7 "Los Santos" 8"Panama" 9 "Veraguas" 10 "Comarca Kuna Yala" 11"Comarca Embera" 12"Comarca Ngobe Bugle" 13 "Panama Oeste" 99"rural" 98"urban" 97"Comarcas"
	label value zone zone

export excel "${out}\Poverty_Indicators_PAN.xlsx", sheetreplace firstrow(variables) sheet("Mean_Botom40")  


exit
/* End of do-file */
*><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><