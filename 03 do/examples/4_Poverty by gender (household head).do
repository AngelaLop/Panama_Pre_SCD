
global rootdatalib "\\gpvdrlac\DATALIB\Datalib"
global path "\\GPVDRLAC\lcspp\public\Honduras\02_Projects\23_Poverty Update\Resultados Finales\bases_nuevas"
global excel "\\GPVDRLAC\lcspp\public\Honduras\02_Projects\28_SCD_Update_2021\excel"

tempname pob 
tempfile aux  
postfile `pob' str45(Ano Area Linea Grupo Valor) using `aux', replace

foreach n of numlist 2011/2019 {
	
	if `n' == 2014 | `n' == 2015 {
		use "$path/Nueva Hogar`n'_clean2.dta", clear
		bys hogar: egen aux2 = max(yperhg) 
		bys hogar: egen aux_nueva = max(yperhg_obs5) 	
	}
	
	if `n' == 2018 | `n' == 2019 {
		use "$path/Nueva Hogar`n'_clean_v2.dta", clear
		bys hogar: egen aux2 = max(yperhg) 
		bys hogar: egen aux_nueva = max(yperhg_obs5_alt) 	
	}
	
	if `n' == 2016 | `n' == 2017 | `n' == 2012 | `n' == 2013  | `n' == 2011 {
		use "$path/Nueva Hogar`n'_clean.dta", clear
		bys hogar: egen aux2 = max(yperhg) 
		bys hogar: egen aux_nueva = max(yperhg_obs5) 	
	}
	
	gen male_head = (sexo==1 & rela_j==1)
	gen female_head = (sexo==2 & rela_j==1)
	gen all_hh = (rela_j==1)
	gen age_15_25 = (rela_j==1 & inrange(edad,15,25))
	gen age_25_65 = (rela_j==1 & inrange(edad,25,65))
	gen more_65 = (rela_j==1 & edad>65)
	
	local groups male_head female_head all  age_15_25 age_25_65 more_65
	
	foreach g of local groups {
		***Replicar pobreza oficial (metodologia nueva)
		apoverty aux_nueva [w=factor] if `g'==1, varpl(l_total_nueva) 
		post `pob' ("`n'") ("National") ("Moderate") ("`g'") ("`r(head_1)'")	

		apoverty aux_nueva [w=factor] if `g'==1, varpl(l_extrema_nueva) 
		post `pob' ("`n'") ("National") ("Extreme") ("`g'") ("`r(head_1)'")	

		**Pobreza Total por Area
		apoverty aux_nueva [w=factor] if ur==1 & `g'==1, varpl(l_total_nueva) //Urbano
		post `pob' ("`n'") ("Urban") ("Moderate") ("`g'") ("`r(head_1)'")	

		apoverty aux_nueva [w=factor] if ur==2 & `g'==1, varpl(l_total_nueva) //Rural
		post `pob' ("`n'") ("Rural") ("Moderate") ("`g'") ("`r(head_1)'")	

		**Extrema por Area
		apoverty aux_nueva [w=factor] if ur==2 & `g'==1, varpl(l_extrema_nueva) //Rural
		post `pob' ("`n'") ("Rural") ("Extreme") ("`g'") ("`r(head_1)'")	

		apoverty aux_nueva [w=factor] if ur==1 & `g'==1, varpl(l_extrema_nueva) //Urbano
		post `pob' ("`n'") ("Urban") ("Extreme") ("`g'") ("`r(head_1)'")	

	}
}

postclose `pob'
use `aux', clear
destring, replace 

export excel using "${excel}\hnd_pob_gender.xlsx", sheet("dta") sheetreplace firstrow(variables)

	