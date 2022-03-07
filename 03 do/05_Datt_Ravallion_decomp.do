/* 	=======================================================================================
	Project:            PAN Poverty Indicators
	Author:             By Kiyomi Cadena
	Organization:       The World Bank-ELCPV
	---------------------------------------------------------------------------------------
	Creation Date:       January 30, 2022
	Modification Date:   
	Output:              Datt_Ravallion_decompositions.xls        
	======================================================================================= */

/* 	=========================================================================================
									  0: Program set up                                      
=========================================================================================== */

* Directory Paths
global proj   "C:\Users\wb343674\WBG\Javier Romero - Panama\Pre-SCD"
global do     "${proj}\03 do"
global out    "${proj}\04 results"

*Setting country
local countries "pan"


local i=0
foreach b of local countries  {

	foreach yr in 2011 2014 2015 2019{
	
	dis "*----------------calculating Poverty Indicators of year `yr' in `b'---------------*"
	local ++i
		
		*----------------------- loading and Harmonization Data -----------------------*
		
		datalibweb, country(`b') year(`yr') type(sedlac-03) mod(all) clear

		local version=  "`r(surveyid)'"
		
		keep if cohh==1 
		
		* Regions
		gen region=substr( region_est2 ,1,2)
		destring region, replace
/* 	=========================================================================================
									  1: Poverty indicators                                  
=========================================================================================== */
		
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
		

	/*Keep variables needed for Analysis*/
	keep ipcf_ppp11 pondera lp_*_ppp urbano year region*
	gen zone="urbano" if urbano==1
	replace zone="rural" if urbano==0
	
	tempfile pan`yr'
	save  `pan`yr'', replace	
}
}	
	
use `pan2019', clear 
append using `pan2015'
append using `pan2011'
append using `pan2014'

 
cap mat drop Final
local y = 0

foreach years in  "2011 2014" "2011 2015" "2014 2019" "2015 2019" {
	local ++y
	local year1: word 1 of `years'
	local year2: word 2 of `years'
	mat Year = J(9,1,`y')			// define year matriz
	mat decomp=1\2\3\1\2\3\1\2\3		// decomposition part matrix
	mat Zone = 1\1\1\2\2\2\3\3\3 		// Zone matrix
   
	local plaux = 0
		foreach pl in lp_550usd_ppp lp_320usd_ppp {
    
			mat pl = J(9,1,`++plaux')		// matriz to identify poverty line
			cap mat drop stats
			local if ""
			foreach zone in "total" "urbano" "rural" {
    
				if ( "`zone'" != "total") local if `"& zone == "`zone'" "'
				drdecomp ipcf_ppp11  [w=pondera] if ((year == `year1' | year == `year2') `if'), by(year) varpl(`pl') 						// Datt-Ravallion decomposition
				matselrc r(b) D , row(1/3) col(3)
				mat stats = nullmat(stats) \ D
			}
			mat Final = nullmat(Final) \ Year,Zone,pl,decomp,stats
		}
}

mat list Final

mat colnames Final = year zone pl component value
drop _all
svmat double Final, n(col)

label define zone 1 "National" 2 "Urban" 3 "Rural" , modify
label values zone zone
label define pl 1 Moderate 2 Extreme, modify
label values pl pl 

label define component 1 Growth 2 Distribution 3 "Total change", modify
label values component component 

label define year 1 "2011 2014" 2 "2011 2015" 3 "2014 2019" 4"2015-2019", modify
label values year year
codebook

export excel using "$out\Datt_Ravallion_decompositions.xlsx" , sheetreplace sheet("dta") first(variable)

