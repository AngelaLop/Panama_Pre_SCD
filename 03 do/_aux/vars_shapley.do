/*====================================================================
project:       Shapley vars
Author:        Natalia Garcia-Peña
Dependencies:  The World Bank

----------------------------------------------------------------------
Creation Date:    02/07/2019
Modified:         08-Oct-2019     (Sandra Segovia)
=====================================================================*/


egen itranext = rowtotal(itranext_m itranext_nm), m

drop if miembros ==.
gen non_dep=(15<=edad & edad<=69)


	
* Share of occupied by gender
gen byte ocupado2=0
replace ocupado2=1 if (ila_ppp11>0 & ila_ppp11!=.) & non_dep==1
gen ocup_man = ocupado2 if hombre==1 & non_dep==1
gen ocup_woman = ocupado2 if hombre==0	& non_dep==1
gen ocup_all = ocupado2 if non_dep==1

recode ocup_woman .=0  // for hh that does not have male members
recode ocup_man   .=0  // for hh that does not have female members
recode ocup_all	  .=0

local incsources "itranext itrane ijubi"

foreach var in `incsources' {
	cap drop `var'_ppp11
	gen `var'_ppp11 = ((`var'*ipc11_sedlac)/ipc_sedlac)/(conversion*ppp11)
	local incs_ppp "`incs_ppp' `var'_ppp11" // list of non-labor income sources in ppp
}
	
* Totals  at the household
foreach var in ocup_man ocup_woman ocup_all ila_ppp11 non_dep {
	egen double t_`var' = total(`var') , by(pais year id)
}
noi di "incs_ppp: `incs_ppp'"

* Total for other sources of income (to generate local with totals)
foreach var in `incs_ppp'  {
	egen double t_`var' = total(`var') , by(pais year id)
	local tot_vars "`tot_vars' t_`var'"
	local minus_tot_vars "`minus_tot_vars' - t_`var'" // for non labor income residual calculation
}
*	
	

** Generate Labor income by gender
egen double t_ila_man_ppp11= total(ila_ppp11) ///
	if (miembros != . & hombre==1 & non_dep==1), by(pais year id)
egen double t_ila_woman_ppp11= total(ila_ppp11) ///
	if (miembros != . & hombre==0 & non_dep==1), by(pais year id)
egen double t_ila_all_ppp11= total(ila_ppp11) ///
	if (miembros != . & non_dep==1), by(pais year id)

	
* Fixes missings (possible dependants who have possitive labor income)
	local genders "man woman all"
	foreach i of local genders {	
		rename t_ila_`i'_ppp11 aux
		egen double t_ila_`i'_ppp11 = mean(aux), by(pais year id)
		replace t_ila_`i'_ppp11 = 0 if t_ila_`i'_ppp11== .   
		drop aux
	}		
		
		
	* Share of occupied
	
	gen double pocup_man = t_ocup_man/t_non_dep
	gen double pocup_woman = t_ocup_woman/t_non_dep
	gen double pocup_all = t_ocup_all/t_non_dep
	
	
	***************************
	************************
	replace pocup_all = 0 if t_non_dep == 0    // agregar a autolel
	***********************
	***************************
	
	
	
	* Labor income from occupied
	gen double ila_man_ocup = t_ila_man_ppp/t_ocup_man
	gen double ila_woman_ocup = t_ila_woman_ppp/t_ocup_woman
	gen double ila_all_ocup = t_ila_all_ppp/t_ocup_all
	
	replace ila_woman_ocup = 0 if  ila_woman_ocup == . // for hh that does not have male members
	replace ila_man_ocup=  0 if  ila_man_ocup == .   // for hh that does not have female members
	replace ila_all_ocup=  0 if  ila_all_ocup == .   
	
	** Other Non labor income - Gender 
	gen double t_otinla_g = ipcf_ppp11*miembros - t_ila_all_ppp11    // otro ingreso no laborales en la poblacion 15-69.


	** Other Non labor income - Income source
	gen double t_otinla_ic = ipcf_ppp11*miembros - t_ila_all_ppp11 `minus_tot_vars'    // otro ingreso no laborales en la poblacion 15-69 (Only labor and non labor components)


	replace t_otinla_g=0 if t_otinla_g<0
	replace t_otinla_ic=0 if t_otinla_ic<0
	
	** Convert in per capita terms
	foreach var in `incs_ppp' otinla_g otinla_ic {    // per capita name
		gen double pc_`var' = t_`var'/miembros
	}  // end of per-capita loop


	gen dependency=t_non_dep/miembros


*br edad ipcf_check ipcf_ppp11 t_ocup_all t_non_dep pocup_all ila_all_ocup dependency pc_itranext_ppp11 pc_itrane_ppp11 pc_itrane_ppp11 pc_otinla_ic if ipcf_ppp11!=ipcf_check

