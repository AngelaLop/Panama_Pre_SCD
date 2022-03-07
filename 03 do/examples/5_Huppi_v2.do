/*===========================================================================
project:       Estimate Huppi-Ravallion
Author:        Laura Moreno 
Dependencies:  WB
---------------------------------------------------------------------------
Creation Date:     December 7, 2014 
Modification Date:   
Do-file version:    01
References:          
Output:             Excel, database. Using pivot table figure 2.10
===========================================================================*/

/*===============================================================================================
                                  0: Program set up
===============================================================================================*/
global excel "\\GPVDRLAC\lcspp\public\Honduras\02_Projects\28_SCD_Update_2021\excel"
global rootdatalib "\\gpvdrlac\DATALIB\Datalib"

clear all

global zone "3"
* 1: unskill 2: low-skill 3: skilled
global skillevel "1"

*** Append datasets 
datalib, count(hnd) year(2019) mod(all) clear
su ipc_sedlac
local ipc_2019 = r(mean)
	
keep id pondera nivel jefe miembros yperhg_obs5_alt sector sector1d relab ytrab_obs2 urbano aedu ano l_total_nueva l_extrema_nueva lp_550usd_ppp lp_320usd_ppp ila_ppp11
bys id: egen ipcf_oficial = max(yperhg_obs5_alt)
drop yperhg_obs5_alt

tempfile temp_2019
rename ytrab_obs2 ila_ppp
save `temp_2019', replace

datalib, count(hnd) year(2014) mod(all) clear
keep id pondera nivel jefe miembros yperhg_obs5 sector sector1d relab ytrab_obs2 urbano aedu ano l_total_nueva l_extrema_nueva ipc_sedlac lp_550usd_ppp lp_320usd_ppp ila_ppp11
bys id: egen ipcf_oficial = max(yperhg_obs5)
drop yperhg_obs5

foreach v of varlist ytrab_obs2 ipcf_oficial l_total_nueva l_extrema_nueva {
		replace `v' = `v'*(`ipc_2019'/ipc_sedlac)
	}

replace ytrab_obs2=round(ytrab_obs2)
rename ytrab_obs2 ila_ppp

tempfile temp_2014
save `temp_2014', replace

datalib, count(hnd) year(2011) mod(all) clear
keep id pondera nivel jefe miembros yperhg_obs5 sector sector1d relab ytrab_obs2 urbano aedu ano l_total_nueva l_extrema_nueva ipc_sedlac lp_550usd_ppp lp_320usd_ppp ila_ppp11
bys id: egen ipcf_oficial = max(yperhg_obs5)
drop yperhg_obs5

foreach v of varlist ytrab_obs2 ipcf_oficial l_total_nueva l_extrema_nueva {
	replace `v' = `v'*(`ipc_2019'/ipc_sedlac)
}
	
tempfile temp_2011
rename ytrab_obs2 ila_ppp
save `temp_2011', replace

/*=============================================================================================
                                  1: Loops: creare locals and open loops
==============================================================================================*/

*------------------------------------1.2: loops by year ------------------------------------
foreach c in 2011 2014 2019 {
		use `temp_`c'', clear
		drop ila_ppp 
		rename ila_ppp11 ila_ppp
		
/*=============================================================================================
                                  2: Create variables
==============================================================================================*/		
	* 2. Education by household head		
		gen aux_edu_hh=nivel if jefe==1
		bys ano id: egen edu_hh=total(aux_edu_hh)
			
	* 3. Sector by household head.	
		gen gsector=.
		replace gsector=1 if sector1d==2  & jefe==1
		replace gsector=1 if sector1d==1  & jefe==1
		replace gsector=1 if sector1d==16 & jefe==1
		replace gsector=1 if sector1d==6  & jefe==1
		replace gsector=2 if sector1d==8  & jefe==1
		replace gsector=2 if sector1d==4  & jefe==1
		replace gsector=2 if sector1d==7  & jefe==1
		replace gsector=2 if sector1d==9  & jefe==1
		replace gsector=2 if sector1d==15 & jefe==1
		replace gsector=3 if sector1d==3  & jefe==1
		replace gsector=3 if sector1d==5  & jefe==1
		replace gsector=4 if sector1d==13 & jefe==1
		replace gsector=4 if sector1d==12 & jefe==1
		replace gsector=4 if sector1d==11 & jefe==1
		replace gsector=4 if sector1d==14 & jefe==1
		replace gsector=4 if sector1d==10 & jefe==1
		replace gsector=4 if sector1d==17 & jefe==1
		replace gsector=5 if sector1d==.  & jefe==1
	
		bys ano id: egen sector_jefe=max(gsector)
		
		label def lgsector 1 "Agricultura, fishing, contruction and household as employers" 2 "Manufacuring, whole sale, transport, hotels and services" 3 "Mining and, electricity, gas and water supply" 4 "High skilled services"
		label val gsector lgsector
		
	* 4. Principal labor income by household
		*gen ila_ppp_aj=ila_ppp*factor_aj
		bys ano id: egen max_ila=max(ila_ppp)
		gen principal_income=(ila_ppp==max_ila)
		sort ano id ila_ppp
		replace principal_income=0 if ano[_n]==ano[_n-1] & ila_ppp[_n]==ila_ppp[_n-1] & id[_n]==id[_n-1]
	
	* 5. Education by household, using principal labor income.
		gen gedu=1
		replace gedu=1 if (nivel==0 | nivel==1) & principal_income==1  // Everybody who did not complete primary school (no schooling or less than primary)
		replace gedu=2 if (nivel==2 | nivel==3) & principal_income==1	// Everybody who completed primary but did not complete secondary 
		replace gedu=3 if (nivel==4 | nivel==5 | nivel==6) & principal_income==1    // Everybody who completed secondary (including those with tertiary)
		replace gedu=3 if (nivel==4 | nivel==5 | nivel==6) & principal_income==1    // Everybody who completed secondary (including those with tertiary)
		replace gedu=1 if gedu==. & aedu<5 & principal_income==1
		replace gedu=2 if gedu==. & aedu>=5 & aedu<12 & principal_income==1
		replace gedu=3 if gedu==. & aedu>=12 & aedu<. & principal_income==1
		replace gedu=9 if gedu==. & nivel==. & aedu==. & principal_income==1
		
		bys ano id: egen edu_hogar=max(gedu)
	
	* 6. Sector using principal labor income by household
		gen gsector2=.		
		replace gsector2=1 if sector1d==2  & principal_income==1
		replace gsector2=1 if sector1d==1  & principal_income==1
		replace gsector2=8 if sector1d==16 & principal_income==1	//
		replace gsector2=2 if sector1d==6  & principal_income==1
		replace gsector2=3 if sector1d==8  & principal_income==1
		replace gsector2=4 if sector1d==4  & principal_income==1
		replace gsector2=3 if sector1d==7  & principal_income==1
		replace gsector2=5 if sector1d==9  & principal_income==1
		replace gsector2=8 if sector1d==15 & principal_income==1 	//
		replace gsector2=6 if sector1d==3  & principal_income==1
		replace gsector2=6 if sector1d==5  & principal_income==1
		replace gsector2=7 if sector1d==13 & principal_income==1
		replace gsector2=7 if sector1d==12 & principal_income==1
		replace gsector2=7 if sector1d==11 & principal_income==1
		replace gsector2=7 if sector1d==14 & principal_income==1
		replace gsector2=7 if sector1d==10 & principal_income==1
		replace gsector2=7 if sector1d==17 & principal_income==1
		replace gsector2=98 if sector1d==. & principal_income==1 & (ila_ppp==. | ila_ppp==0)  // non labor income. no sector.
		replace gsector2=99 if sector1d==. & principal_income==1 & (ila_ppp!=. & ila_ppp>0)  // labor income but no sector.
	
		bys ano id: egen sector_hogar=max(gsector2)
		drop if sector_hogar==99	
		
	* 7. Relab using principal labor income by household
		gen grelab=.
		replace grelab=1 if relab==1 & principal_income==1
		replace grelab=2 if relab==2 & principal_income==1
		replace grelab=3 if relab==3 & principal_income==1
		replace grelab=4 if relab==5 & principal_income==1
		replace grelab=5 if relab==5 & principal_income==1
		replace grelab=6 if relab==. & principal_income==1
		bys ano id: egen relab_hogar=max(grelab)
		
	* 8. hila_ppp
		bys id ano: egen hila_ppp=total(ila_ppp)
		replace hila_ppp=hila_ppp/miembros
		
		tempfile hr_`c'
		save `hr_`c'', replace	
		save "${excel}/basehuppi`c'_2.dta", replace
		tab sector_hogar edu_hogar
	}	
	
/*===============================================================================================
                                  3: Decomposition
===============================================================================================*/	

*** moderate poverty
	use "${excel}\basehuppi2014_2.dta", clear
		sedecomposition using "\${excel}\basehuppi2019_2.dta" if hila_ppp!=.    /// 
		[w=pondera], sector(sector_hogar) var1(hila_ppp)      /// 
		var2(hila_ppp) pline1(lp_550usd_ppp) pline2(lp_550usd_ppp)
s
*** extreme poverty	
	use "${excel}\basehuppi2014_2.dta", clear
		sedecomposition using "\${excel}\basehuppi2019_2.dta" if hila_ppp!=.    /// 
		[w=pondera], sector(sector_hogar) var1(hila_ppp)      /// 
		var2(hila_ppp) pline1(lp_320usd_ppp) pline2(lp_320usd_ppp)

*** moderate poverty
	use "${excel}\basehuppi2014_2.dta", clear
		sedecomposition using "\${excel}\basehuppi2019_2.dta" if hila_ppp!=.    /// 
		[w=pondera], sector(sector_hogar) var1(hila_ppp)      /// 
		var2(hila_ppp) pline1(l_total_nueva) pline2(l_total_nueva)

*** extreme poverty	
	use "${excel}\basehuppi2014_2.dta", clear
		sedecomposition using "\${excel}\basehuppi2019_2.dta" if hila_ppp!=.    /// 
		[w=pondera], sector(sector_hogar) var1(hila_ppp)      /// 
		var2(hila_ppp) pline1(l_extrema_nueva) pline2(l_extrema_nueva)

		
		 
	/*use "${excel}\basehuppi2011.dta", clear
		sedecomposition using "\${excel}\basehuppi2014.dta" if hila_ppp!=.    /// 
		[w=pondera], sector(sector_hogar) var1(hila_ppp)      /// 
		var2(hila_ppp) pline1(l_total_nueva) pline2(l_total_nueva)
		
	use "${excel}\basehuppi2011.dta", clear
		sedecomposition using "\${excel}\basehuppi2014.dta" if hila_ppp!=.    /// 
		[w=pondera], sector(sector_hogar) var1(hila_ppp)      /// 
		var2(hila_ppp) pline1(l_extrema_nueva) pline2(l_extrema_nueva)
		
		*** Export manually pending update matrix export
		
		/*
		mat rtotal=r(b_tot)
		mat rsector=r(b_sec)
	
		mat codetotal=(100\200\300\400)
		mat codesector=(1\2\3\4\5\6\7\8\98)
		mat povertyr = (9,500,0,0,${llmh_p1}\ 9,600,0,0,${llmh_p2})
	
		mat final = nullmat(final) \ J(rowsof(rsector),1,`x'), J(rowsof(rsector),1, `sk'), J(rowsof(rsector),1,0), codesector, rsector \  J(rowsof(rtotal),1,0), rtotal  \  J(rowsof(povertyr),1,`x'), J(rowsof(povertyr),1, `sk'), povertyr
		
		mat colnames  final = zona clase effect pop_share_circa1 abs_change per_change 
		
/*===============================================================================================
                                  4: Save and export
===============================================================================================*/

*------------------------------------4.1: Matrix to database------------------------------------

		drop _all
		svmat final, n(col)
		mat drop final
*------------------------------------4.2: labels ------------------------------------		
		gen intervalo="`intervalo'"
		label def lclase 0 "Intra-sectoral" 1 "Total", replace
		label val clase lclase
		
		label def leffect 1 "Agriculture and Fishing" 2 "Construction" 3 "Commerce and Hospitality" 4 "Manufacturing" 5 "Transport" 6 "Mining and utilities" 7 "Other services" 8 "Household services" 98 "Non labor income" 99 "Missing" 100 "Poverty Change" 200 "Total intra-sectoral" 300 "Population shift" 400 "Interaction effect" 500 "pov 1" 600 "pov 2", replace
		label val effect leffect
				

* Your Huppi is done. Smile.


/*===============================================================================================
                                  4: Export to excel
===============================================================================================*/


*------------------------------------4.1: <Describe> ------------------------------------

export excel "${excel}/Huppi.xlsx",  sheet("dta") sheetreplace firstrow(variables) */




exit
/* End of do-file */
