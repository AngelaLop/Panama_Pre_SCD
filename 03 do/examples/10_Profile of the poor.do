
global rootdatalib "\\gpvdrlac\DATALIB\Datalib"
global path "\\GPVDRLAC\lcspp\public\Honduras\02_Projects\23_Poverty Update\Resultados Finales\bases_nuevas"
global excel "\\GPVDRLAC\lcspp\public\Honduras\02_Projects\28_SCD_Update_2021\excel"

tempname pob 
tempfile aux 
postfile `pob' str100(Year Group Variable Value) using `aux', replace

foreach n of numlist 2011/2019 {
	datalib, count(hnd) year(`n') mod(all) nocohh clear	

	if  `n' == 2019 | `n'==2018 {
		bys id: egen aux_nueva = max(yperhg_obs5_alt) 	
	}
	
	if  `n' == 2014 | `n'==2015  {
		bys id: egen aux_nueva = max(yperhg_obs5) 	
	}
	
	if `n' == 2016 | `n' == 2017 | `n' == 2012 | `n' == 2013  | `n' == 2011 {
		bys id: egen aux_nueva = max(yperhg_obs5) 	
	}
		
	apoverty aux_nueva [w=pondera], varpl(l_total_nueva) gen(pob)
	rename pob1 pob
	apoverty aux_nueva [w=pondera], varpl(l_extrema_nueva) gen(pobex)
	rename pobex1 pobex
	
	gen all = 1
	gen non_poor = (pob!=1)
	
	gen age_0_12 = inrange(edad,0,12)
	gen age_13_18 = inrange(edad,13,18)
	gen age_19_70 = inrange(edad,19,70)
	gen age_70= (edad>70) 
	
	gen daily_inc = ipcf_ppp11/30.5 
	gen female = (hombre==0)
	
	*Water Recommended
	gen     no_water=     imp_wat_rec==0
	replace no_water=. if imp_wat_rec==.

	*Sanitation Recommended 
	gen no_sanitation =  imp_san_rec==0
	replace no_sanitation = . if imp_san_rec==.

	gen informal_labor=(djubila!=1) 
	replace informal_labor=. if (edad<15 | edad>65) | ocupado!=1 | inrange(relab,1,4)!=1

	foreach l of varlist informal_labor no_sanitation no_water elect internet_casa uso_internet  {
		replace `l'=`l'*100
	}
	
	foreach v of varlist all non_poor pob pobex {
		su internet_casa [w=pondera] if  `v'==1
		post `pob' ("`n'") ("`v'") ("Internet at home (%)") ("`r(mean)'")	
		
		su uso_internet [w=pondera] if  `v'==1
		post `pob' ("`n'") ("`v'") ("Internet use (%)") ("`r(mean)'")	
		
		su informal_labor [w=pondera] if  `v'==1
		post `pob' ("`n'") ("`v'") ("Informality (%)") ("`r(mean)'")	
		
		su elect [w=pondera] if  `v'==1
		post `pob' ("`n'") ("`v'") ("HH with access to electricity (%)") ("`r(mean)'")	
		
		su no_water [w=pondera] if  `v'==1
		post `pob' ("`n'") ("`v'") ("HH without access to water (%)") ("`r(mean)'")	
		
		su no_sanitation [w=pondera] if  `v'==1
		post `pob' ("`n'") ("`v'") ("HH without access to sanitation (%)") ("`r(mean)'")	
		
		su daily_inc [w=pondera] if  `v'==1
		post `pob' ("`n'") ("`v'") ("Daily per capita income 2011 USD PPP") ("`r(mean)'")	
		
		su `v' [w=pondera] 
		local value = r(mean)*100
		post `pob' ("`n'") ("`v'") ("Percentage in each category") ("`value'")	
		
		su miembros [w=pondera] if  `v'==1
		local value = r(mean)*100
		post `pob' ("`n'") ("`v'") ("Average household size") ("`r(mean)'")	
		
		su edad [w=pondera] if  `v'==1 & jefe==1
		post `pob' ("`n'") ("`v'") ("Average age of household head") ("`r(mean)'")	
		
		su female [w=pondera] if  `v'==1 & jefe==1
		local value = r(mean)*100
		post `pob' ("`n'") ("`v'") ("Households with female head (%)") ("`value'")
		
		su urbano [w=pondera] if  `v'==1 
		local value = r(mean)*100
		post `pob' ("`n'") ("`v'") ("Living in urban area (%)") ("`value'")	
		
		su aedu [w=pondera] if  `v'==1 & jefe==1
		local value = r(mean)*100
		post `pob' ("`n'") ("`v'") ("Average years of education of household head") ("`value'")	
		
		su asiste [w=pondera] if  `v'==1 & inrange(edad,6,12)
		local value = r(mean)*100
		post `pob' ("`n'") ("`v'") ("School enrollment (% ages 6-12)") ("`value'")	
		
		su asiste [w=pondera] if  `v'==1 & inrange(edad,12,18)
		local value = r(mean)*100
		post `pob' ("`n'") ("`v'") ("School enrollment (% ages 12-18)") ("`value'")	
		
		su age_0_12 [w=pondera] if  `v'==1 
		local value = r(mean)*100
		post `pob' ("`n'") ("`v'") ("Proportion of members 0-12 years old (%)") ("`value'")	
		
		su age_13_18 [w=pondera] if  `v'==1 
		local value = r(mean)*100
		post `pob' ("`n'") ("`v'") ("Proportion of members 13-18 years old (%)") ("`value'")	
		
		su age_19_70 [w=pondera] if  `v'==1 
		local value = r(mean)*100
		post `pob' ("`n'") ("`v'") ("Proportion of members 19-70 years old (%)") ("`value'")	
		
		su age_70 [w=pondera] if  `v'==1 
		local value = r(mean)*100
		post `pob' ("`n'") ("`v'") ("Proportion of members 70+ years old (%)") ("`value'")	
		
		su pea [w=pondera] if  `v'==1 & inrange(edad,15,65)
		local value = r(mean)*100
		post `pob' ("`n'") ("`v'") ("Labor force participation (%)") ("`value'")	
		
		su pea [w=pondera] if  `v'==1 & inrange(edad,15,65) & hombre==0
		local value = r(mean)*100
		post `pob' ("`n'") ("`v'") ("Female labor force participation (%)") ("`value'")	
		
		su pea [w=pondera] if  `v'==1 & inrange(edad,15,65) & hombre==1
		local value = r(mean)*100
		post `pob' ("`n'") ("`v'") ("Male labor force participation (%)") ("`value'")	
		
		su desocupa [w=pondera] if  `v'==1 & inrange(edad,15,65) & pea==1
		local total = r(sum_w)
		
		su desocupa [w=pondera] if  `v'==1 & inrange(edad,15,65) & pea==1 & desocupa==1 
		local value = (r(sum_w)/`total')*100
		post `pob' ("`n'") ("`v'") ("Unemployment rate (%)") ("`value'")	
		
		su desocupa [w=pondera] if  `v'==1 & inrange(edad,15,65) & hombre==0 & pea==1 & desocupa==1 
		local value = (r(sum_w)/`total')*100
		post `pob' ("`n'") ("`v'") ("Female unemployment rate (%)") ("`value'")	
		
		su desocupa [w=pondera] if  `v'==1 & inrange(edad,15,65) & hombre==1 & pea==1 & desocupa==1 
		local value = (r(sum_w)/`total')*100
		post `pob' ("`n'") ("`v'") ("Male unemployment rate (%)") ("`value'")	
	}
}

postclose `pob'
use `aux', clear
destring, replace 

export excel using "${excel}\pov_profile.xlsx", sheet("dta") sheetreplace firstrow(variables)

exit
