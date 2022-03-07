/* 	=======================================================================================
	Project:            PAN Poverty ndicators
	Author:             By Kiyomi Cadena
	Organization:       The World Bank-ELCPV
	---------------------------------------------------------------------------------------
	Creation Date:       January 04, 2021 
	Modification Date:   
	Output:              Poverty_Indicators_PAN         
	======================================================================================= */

/* 	=========================================================================================
									  0: Program set up                                      
=========================================================================================== */

*Setting country
local countries "hnd"

*Tempfiles
tempfile tf_postfile1 
tempname tn1
postfile `tn1' str50(country year indicators zone value obs version) using `tf_postfile1', replace

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
									  1: Poverty indicators                                  
=========================================================================================== */
		
	* Regions
		gen region=substr( region_est2 ,1,2)
		destring region, replace
	
	* Poverty Lines
	
		local days "30.42"  
		
		gen lp_190usd_ppp = `days'*1.9 
		gen lp_320usd_ppp = `days'*3.2
		gen lp_550usd_ppp = `days'*5.5
		gen lp_1300usd_ppp = `days'*13
		gen lp_7000usd_ppp = `days'*70
		
		cap	gen factor11=ipc11_sedlac/ipc_sedlac 
		cap	gen factorppp11=factor11/ppp11 

		gen ipcf_ppp11=(ipcf*factorppp11) 		
	
	
		local inc "ipcf_ppp11"
		
		gen p_19=     `inc'<lp_190usd_ppp 
		gen p_32=     `inc'<lp_320usd_ppp 
		gen p_55=     `inc'<lp_550usd_ppp 
		gen p_13=     `inc'>=lp_550usd_ppp & `inc'<lp_1300usd_ppp 
		gen p_70=     `inc'>=lp_1300usd_ppp & `inc'<lp_7000usd_ppp 
		gen p_70_plus=`inc'>=lp_7000usd_ppp
		
		*Missing when income is missing
		foreach v in p_19 p_32 p_55 p_13 p_70 p_70_plus {
			
			replace `v'=. if `inc'==.
			replace `v'=`v'*100
		}
		
		
		* Poverty classes 
		local ind 	 "p_19 p_32 p_55 p_13 p_70 p_70_plus"
		local ind_lb "poverty_190_usd_ppp11 poverty_320_usd_ppp11 poverty_550_usd_ppp11 vulnerable middle_class rich "
		
		* Poverty 
		local cl=0
		foreach l of local ind {
		local ++cl
			local lbl: word `cl' of `ind_lb'
			
			* National
			sum `l'  [w=pondera] 
			post `tn1' ("`b'") ("`yr'") ("`lbl'") ("National") ("`r(mean)'") ("`r(sum)'") ("`version'") 
			
			
			* Region 
			forvalues zone = 1(1)13 {
				
				sum `l'  [w=pondera] if region==`zone'
				post `tn1' ("`b'") ("`yr'") ("`lbl'") ("`zone'") ("`r(mean)'") ("`r(sum)'") ("`version'") 
				} // end type region
				
			* Comarcas 
			sum `l'  [w=pondera] if  (region==10|region==11 | region==12)
			post `tn1' ("`b'") ("`yr'") ("`lbl'") ("comarcas") ("`r(mean)'") ("`r(sum)'") ("`version'") 
				
	
		} //end type indicator

		
	} // end type  of year
} // end type  of survey 

postclose `tn1' 
use `tf_postfile1', clear 

	* Labels
	replace zone="0" if zone=="National"
	replace zone="14" if zone=="comarcas"
	destring zone, replace
	label define zone  0"National" 1 "Bocas del Toro" 2"Cocle" 3"Colon" 4"Chiriqui" 5"Darien" 6"Herrera" 7 "Los Santos" 8"Panama" 9 "Veraguas" 10 "Comarca Kuna Yala" 11"Comarca Embera" 12"Comarca Ngobe Bugle" 13 "Panama Oeste" 14"Comarcas"
	label value zone zone

export excel "${out}\Poverty_Indicators_PAN.xlsx", sheetreplace firstrow(variables) sheet("Provincia") 

exit
/* End of do-file */
*><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
