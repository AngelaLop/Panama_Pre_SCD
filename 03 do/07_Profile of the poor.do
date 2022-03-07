/* 	=======================================================================================
	Project:            PAN Profile of Poor
	Author:             By Kiyomi Cadena
	Organization:       The World Bank-ELCPV
	---------------------------------------------------------------------------------------
	Creation Date:       Febrero 02, 2021 
	Modification Date:   
	Output:              Profile_poor_PAN         
	======================================================================================= */

/* 	=========================================================================================
									  0: Program set up                                      
=========================================================================================== */

* Directory Paths
global proj   "C:\Users\wb343674\WBG\Javier Romero - Panama\Pre-SCD"
global do     "${proj}\03 do"
global out    "${proj}\04 results"

*Tempfiles
tempname pob 
tempfile aux 
postfile `pob' str100(Year Group Variable Value) using `aux', replace

foreach n of numlist 2015/2019 {
	datalibweb, country(pan) year(`n') type(sedlac-03) mod(all) clear

	cap keep if cohh==1 
	
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
	
	apoverty ipcf_ppp11 [w=pondera], varpl(lp_550usd_ppp) gen(pob)
	rename pob1 pob
	
	gen vul=p_13/100
	gen mid=p_70/100
	
	gen all = 1
	gen non_poor = (pob!=1)
	
	gen age_0_12 = inrange(edad,0,12)
	gen age_13_18 = inrange(edad,13,18)
	gen age_19_70 = inrange(edad,19,70)
	gen age_70= (edad>70) 
	
	gen daily_inc = ipcf_ppp11/30.5 
	gen female = (hombre==0)
	
	* nivel educativo 
	g e_ninguno = inlist(nivel,0,1)
	g e_primaria = inlist(nivel,2,3)  
	g e_secundaria  = inlist(nivel,4,5) 
	g e_terciaria  = inlist(nivel,6)  
	
	gen informal_labor=(djubila!=1) 
	replace informal_labor=. if (edad<15 | edad>65) | ocupado!=1 | inrange(relab,1,4)!=1
	
	* Regions
	gen region=substr( region_est2 ,1,2)
	destring region, replace
	
	gen comarca=0
	replace comarca=1 if region==10|region==11| region==12

	
	gen ocupado_1 = ocu_des=="Ocupados" if edad>=15
	gen desocupado_1 =  ocu_des=="Desocupados" if edad>=15
	gen pea_1 = (desocupado_1==1)| (ocupado_1==1)
	g horas_1 = p40
	
	destring  p28reco, g(ocupacion_1)
	gen posicion = p33
	replace posicion = 2 if inlist(posicion,2,3,4,9)
	g ocupados_no_prof = ocupado_1 ==1
	replace ocupados_no_prof = 0 if inlist(posicion,7,8) & (inlist(ocupacion_1, 1,2))
	
	g informal3 =0 if ocupado_1 ==1
	replace informal3 =1 if p4!=1 & ocupado_1 ==1	
	replace informal3 =1 if p34==5
	replace informal3 =0 if p4==1 | p4 == 4 & ocupado_1 ==1	
	replace informal3 =. if rama==1 //  ocupados exuyendo ocupaciones agricultura
	replace informal3 =. if ocupados_no_prof==0 //* ocupados exuyendo  profecionales y tecnicos cuenta propia o patronos
	
	
	
	foreach v of varlist all mid vul pob {
				
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
		
		su comarca [w=pondera] if  `v'==1 
		local value = r(mean)*100
		post `pob' ("`n'") ("`v'") ("Living in a comarca (%)") ("`value'")	
		
		su aedu [w=pondera] if  `v'==1 & jefe==1
		local value = r(mean)*100
		post `pob' ("`n'") ("`v'") ("Average years of education of household head") ("`value'")	
		
		su e_ninguno [w=pondera] if  `v'==1 & jefe==1
		local value = r(mean)*100
		post `pob' ("`n'") ("`v'") ("No education (%)") ("`value'")	
		
		su e_primaria [w=pondera] if  `v'==1 & jefe==1
		local value = r(mean)*100
		post `pob' ("`n'") ("`v'") ("Primary education (%)") ("`value'")	
		
		su e_secundaria [w=pondera] if  `v'==1 & jefe==1
		local value = r(mean)*100
		post `pob' ("`n'") ("`v'") ("Secondary secondary (%)") ("`value'")	
		
		su e_terciaria [w=pondera] if  `v'==1  & jefe==1
		local value = r(mean)*100
		post `pob' ("`n'") ("`v'") ("Tertiary secondary (%)") ("`value'")
		
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
			
		*su pea_1 [w=pondera] if  `v'==1 & inrange(edad,15,65)
		su pea_1 [w=pondera] if  `v'==1 & edad>=15
		local value = r(mean)*100
		post `pob' ("`n'") ("`v'") ("Labor force participation (%)") ("`value'")	
		
		*su pea_1 [w=pondera] if  `v'==1 & inrange(edad,15,65) & hombre==0
		su pea_1 [w=pondera] if  `v'==1 & edad>=15 & hombre==0
		local value = r(mean)*100
		post `pob' ("`n'") ("`v'") ("Female labor force participation (%)") ("`value'")	
		
		*su pea_1 [w=pondera] if  `v'==1 & inrange(edad,15,65) & hombre==1
		su pea_1 [w=pondera] if  `v'==1 & edad>=15 & hombre==1
		local value = r(mean)*100
		post `pob' ("`n'") ("`v'") ("Male labor force participation (%)") ("`value'")	
		
		*su desocupado_1 [w=pondera] if  `v'==1 & inrange(edad,15,65) & pea_1==1
		su desocupado_1 [w=pondera] if  `v'==1 & edad>=15 & pea_1==1
		local total = r(sum_w)
		
		*su desocupado_1 [w=pondera] if  `v'==1 & inrange(edad,15,65) & pea_1==1 & desocupado_1==1 
		su desocupado_1 [w=pondera] if  `v'==1 & edad>=19 & pea_1==1 & desocupado_1==1 
		local value = (r(sum_w)/`total')*100
		post `pob' ("`n'") ("`v'") ("Unemployment rate (%)") ("`value'")	
		
		*su desocupado_1 [w=pondera] if  `v'==1 & inrange(edad,15,65) & hombre==0 & pea_1==1 & desocupado_1==1 
		su desocupado_1 [w=pondera] if  `v'==1 & edad>=15 & hombre==0 & pea_1==1 & desocupado_1==1
		local value = (r(sum_w)/`total')*100
		post `pob' ("`n'") ("`v'") ("Female unemployment rate (%)") ("`value'")	
		
		*su desocupado_1 [w=pondera] if  `v'==1 & inrange(edad,15,65) & hombre==1 & pea_1==1 & desocupado_1==1 
		su desocupado_1 [w=pondera] if  `v'==1 & edad>15 & hombre==1 & pea_1==1 & desocupado_1==1 
		local value = (r(sum_w)/`total')*100
		post `pob' ("`n'") ("`v'") ("Male unemployment rate (%)") ("`value'")	
		
		su informal3 [w=pondera] if  `v'==1 & inrange(edad,15,65) & pea_1==1
		local value = r(mean)*100
		post `pob' ("`n'") ("`v'") ("Informality (%)") ("`r(mean)'")	
	}
}

postclose `pob'
use `aux', clear
destring, replace 

export excel using "${out}\Profile_poor_PAN.xlsx", sheet("dta") sheetreplace firstrow(variables)

exit
