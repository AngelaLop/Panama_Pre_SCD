/*================================================================================
Project:          Public sector premium figure for Honduras: Oaxaca Blinder       
----------------------------------------------------------------------------------
Creation Date:    June 6, 2017                                                    
Update: 		  sep 22, 2021                                              
Ouput:            This do-files produces Oaxaca-blinder for Public sector premium 
using IMF specification                                                           
http://www.mh.gob.sv/portal/page/portal/PMH/Documentos_O_M/Fondo_Monetario_Internacional/Documentos/2016/GASTOS_EN_SALARIOS_GUBERNAMENTALES_ANALISIS_Y_DESAFIOS_2016.PDF)
Note: Uses new methodology labor income variable 2011-2019                        
=================================================================================*/

global rootdatalib "\\gpvdrlac\DATALIB\Datalib"
global excel "\\GPVDRLAC\lcspp\public\Honduras\02_Projects\28_SCD_Update_2021\excel"
 
local n_c 0
foreach y of numlist 2011/2019 {
	local ++n_c
	di in y "`y'"
	if ("`y'" == "2016" ) {
			cap datalib, count(hnd) year(`y') module(all) clear
			gen social_security=.
			replace social_security = 0 if ocupado == 1
			replace social_security = 1 if ocupado == 1 & (ce423_1==1 | ce423_2==2 | ce423_3==3 | ce423_4==4 | ce423_5==5 | ce423_6==6 | ce423_8==8 | ce423_9==9) 			
		}
	
		else if ("`y'" == "2011" ) {
			cap datalib, count(hnd) year(`y') module(all) clear
			gen social_security=.
			replace social_security = 0 if ocupado == 1
			replace social_security = 1 if ocupado == 1 & (ce23_1==1 | ce23_2==2 | ce23_3==3 | ce23_4==4 | ce23_5==5 | ce23_6==6 | ce23_8==8 | ce23_9==9) 
		}
		
		else if ("`y'" == "2012" ) {
			cap datalib, count(hnd) year(`y') module(all) clear
			gen social_security=.
			replace social_security = 0 if ocupado == 1
			replace social_security = 1 if ocupado == 1 & (ce423_1==1 | ce423_2==2 | ce423_3==3 | ce423_4==4 | ce423_5==5 | ce423_6==6 | ce423_8==8 | ce423_9==9) 
		}
			  
		else if ("`y'" == "2013" ) {
			cap datalib, count(hnd) year(`y') module(all) clear
			gen social_security=.
			replace social_security = 0 if ocupado == 1
			replace social_security = 1 if ocupado == 1 & (ce23_1==1 | ce23_2==2 | ce23_3==3 | ce23_4==4 | ce23_5==5 | ce23_6==6 | ce23_8==8 | ce23_9==9) 
		}
		
		else if ("`y'" == "2014" ) {
			cap datalib, count(hnd) year(`y') module(all) clear
			gen social_security=.
			replace social_security = 0 if ocupado == 1
			replace social_security = 1 if ocupado == 1 & (ce423_1==1 | ce423_2==2 | ce423_3==3 | ce423_4==4 | ce423_5==5 | ce423_6==6 | ce423_8==8 | ce423_9==9) 
		}
			  
		else if ("`y'" == "2015" ) {
			cap datalib, count(hnd) year(`y') module(all) clear
			gen social_security=.
			replace social_security = 0 if ocupado == 1
			replace social_security = 1 if ocupado == 1 & (ce423_1==1 | ce423_2==2 | ce423_3==3 | ce423_4==4 | ce423_5==5 | ce423_6==6 | ce423_8==8 | ce423_9==9) 
		}
		
		else if ("`y'" == "2016" ) {
			cap datalib, count(hnd) year(`y') module(all) clear
			gen social_security=.
			replace social_security = 0 if ocupado == 1
			replace social_security = 1 if ocupado == 1 & (ce423_1==1 | ce423_2==2 | ce423_3==3 | ce423_4==4 | ce423_5==5 | ce423_6==6 | ce423_8==8) 
		}
		
		else if ("`y'" == "2017" ) {
			cap datalib, count(hnd) year(`y') module(all) clear
			gen social_security=.
			replace social_security = 0 if ocupado == 1
			replace social_security = 1 if ocupado == 1 & (ce433_1==1 | ce433_2==1 | ce433_3==1 | ce433_4==1 | ce433_5==1 | ce433_6==1 | ce433_8==1) 
		}
		
		else if ("`y'" == "2018" ) {
			cap datalib, count(hnd) year(`y') module(all) clear
			gen social_security=.
			replace social_security = 0 if ocupado == 1
			replace social_security = 1 if ocupado == 1 & (cp517_1>0 & cp517_1!=. & cp517_1!=8 & cp517_1!=9) 
			replace	social_security = 1	if ocupado == 1 & (cp517_2>0 & cp517_2!=. & cp517_2!=8 & cp517_2!=9) 
			replace	social_security = 1	if ocupado == 1 & (cp517_3>0 & cp517_3!=. & cp517_3!=8 & cp517_3!=9) 
			replace	social_security = 1	if ocupado == 1 & (cp517_4>0 & cp517_4!=. & cp517_4!=8 & cp517_4!=9) 
			replace	social_security = 1	if ocupado == 1 & (cp517_5>0 & cp517_5!=. & cp517_5!=8 & cp517_5!=9) 
			replace	social_security = 1	if ocupado == 1 & (cp517_7>0 & cp517_7!=. & cp517_7!=8 & cp517_7!=9) 
		}
		
		else if ("`y'" == "2019" ) {
			cap datalib, count(hnd) year(`y') module(all) clear
			gen social_security=.
			replace social_security = 0 if ocupado == 1
			replace social_security = 1 if ocupado == 1 &  (cp517_1>0 & cp517_1!=. & cp517_1!=8 & cp517_1!=9) 
			replace	social_security = 1	if ocupado == 1 &  (cp517_2>0 & cp517_2!=. & cp517_2!=8 & cp517_2!=9) 
			replace	social_security = 1	if ocupado == 1 &  (cp517_3>0 & cp517_3!=. & cp517_3!=8 & cp517_3!=9) 
			replace	social_security = 1	if ocupado == 1 &  (cp517_4>0 & cp517_4!=. & cp517_4!=8 & cp517_4!=9) 
			replace	social_security = 1	if ocupado == 1 &  (cp517_5>0 & cp517_5!=. & cp517_5!=8 & cp517_5!=9) 
			replace	social_security = 1	if ocupado == 1 &  (cp517_7>0 & cp517_7!=. & cp517_7!=8 & cp517_7!=9) 
		}
	
		*Education level
		recode nivel (0/3 = 1) (4/5 = 2) (6=3), gen(skill_level)
		lab define skill_level 1"Incomplete Secondary & Less" 2 "Complete secondary & incomplete tertiary" 3"Complete tertiary", modify
		lab val skill_level skill_level

		gen expsq = exp^2

		gen exp_categ_1 = (exp<5)
		gen exp_categ_2=inrange(exp,5,9)
		gen exp_categ_3=(exp>=10 & exp<99) 
		
		foreach x of varlist exp_categ_* {
			replace `x'=. if exp==. 
		}
		
		la var exp_categ_1 "Exp <5" 
		la var exp_categ_2 "Exp 5-9" 
		la var exp_categ_3 "Exp>=10"
		
		***Labor income***
		gen ytrab_real = (ytrab_obs2*ipc11_sedlac)/ipc_sedlac
		replace ytrab_real=0 if ytrab_obs2==.
		gen lila = ln(ytrab_real) // log of labor income 

		gen wage_ppp=ytrab_real/(hstrt*4.33) //hourly wages
		replace wage_ppp=. if relab==4
		gen lnwage = ln(wage_ppp) //log hourly wages
		
		gen pubsector = .
		replace pubsector =1 if empresa == 3 // 0 = small and large firms relative to FORMAL private sector 
		replace pubsector=0 if inrange(empresa,1,2) & social_security==1
		
		gen pubsector2 = .
		replace pubsector2 =1 if empresa == 3 // 0 = small and large firms, relative to ALL private sector (excluding self-employed) 
		replace pubsector2=0 if inrange(empresa,1,2) & relab!=3
		
		gen aedu2 = aedu^2
		
		gen male = (hombre==1)
		gen female = (hombre==0)
		
		gen part_time =.
		replace part_time = 1 if hstrp <30 
		replace part_time = 0 if inrange(hstrp,30,144)

		*** Private sector, wage earner, pays into SS / sindicato = 1 *** 
		gen private_salaried_ss = 0
		replace private_salaried_ss = 1 if inrange(empresa,1,2) & social_security == 1 & relab == 2
		
		*** Private sector, wage earner, does not pay into SS ***  	
		gen private_salaried = 0
		replace private_salaried = 1 if inrange(empresa,1,2) & social_security == 0 & relab == 2
		
		*** Private , self-employed***
		gen private_self = 0
		replace private_self = 1 if inrange(empresa,1,2) & relab == 3
		
		* ta region, gen(r)
	
	ta sector1d pubsector2 if (sector1d==13 | sector1d==14)
	ta sector1d pubsector2 if (sector1d==13 | sector1d==14) [w=pondera]

	************************************
	**** (1) Formality Control (all)****
	************************************
	
	local controls "aedu aedu2 exp expsq hombre urbano part_time"  
	*qui: oaxaca lnwage `controls'  if inrange(edad,18,65) & ocupado == 1 & ytrab_real>0 [w=pondera], by(pubsector)
	qui: oaxaca lnwage `controls'  if inrange(edad,18,65) & ocupado == 1 & ytrab_real>0 [w=pondera], by(pubsector2)
	
	*Export results to excel
	*qui: putexcel set "${excel}\HND_public_premium_oaxaca_formal.xlsx", sheet("all") modify	
	qui: putexcel set "${excel}\HND_public_premium_oaxaca.xlsx", sheet("all") modify	
	
	local j = `n_c'+1
	putexcel A1=("Year")
	putexcel A`j'=("`y'")
	putexcel B`j'=matrix(e(b))
	putexcel B1=("Private") 
	putexcel C1=("Public")
	putexcel D1=("Differences")
	putexcel E1=("Endowment")
	putexcel F1=("Coefficient")
	putexcel G1=("Interaction")
	putexcel H1=("Years of Education")
	putexcel I1=("Years of Education squared")
	putexcel J1=("Experience")
	putexcel K1=("Exp. squared")
	putexcel L1=("Male")
	putexcel M1=("Urban")
	putexcel N1=("Part Time")
	
	preserve
	*qui: import excel using "${excel}\HND_public_premium_oaxaca_formal.xlsx", sheet("all") firstrow clear
	qui: import excel using "${excel}\HND_public_premium_oaxaca.xlsx", sheet("all") firstrow clear

	drop O-AC
	*qui: export excel using "${excel}\HND_public_premium_oaxaca_formal.xlsx", sheet("all") sheetreplace firstrow(varlab)
	qui: export excel using "${excel}\HND_public_premium_oaxaca.xlsx", sheet("all") sheetreplace firstrow(varlab)

	restore 
	
	**********************************************************************
	**** (2) Compare Skill levels in FORMAL Private sector (pubsector)****
	**********************************************************************
	foreach v in 1 2 3 { 
		local controls "aedu aedu2 exp expsq hombre urbano part_time"  
		*qui: oaxaca lnwage `controls' if inrange(edad,18,65) & ocupado == 1 & ytrab_real>0 & skill_level==`v' [w=pondera], by(pubsector) //pubsector vs private social_security
		qui: oaxaca lnwage `controls' if inrange(edad,18,65) & ocupado == 1 & ytrab_real>0 & skill_level==`v' [w=pondera], by(pubsector2) //pubsector vs private social_security

		
		*Export results to excel
		*qui: putexcel set "${excel}\HND_public_premium_oaxaca_formal.xlsx", sheet("skill_`v'") modify	
		qui: putexcel set "${excel}\HND_public_premium_oaxaca.xlsx", sheet("skill_`v'") modify	
		
		local j = `n_c'+1
		putexcel A1=("Year")
		putexcel A`j'=("`y'")
		putexcel B`j'=matrix(e(b))
		putexcel B1=("Private") 
		putexcel C1=("Public")
		putexcel D1=("Differences")
		putexcel E1=("Endowment")
		putexcel F1=("Coefficient")
		putexcel G1=("Interaction")
		putexcel H1=("Years of Education")
		putexcel I1=("Years of Education squared")
		putexcel J1=("Experience")
		putexcel K1=("Exp. squared")
		putexcel L1=("Male")
		putexcel M1=("Urban")
		putexcel N1=("Part Time")
		
		preserve
		*qui: import excel using "${excel}\HND_public_premium_oaxaca_formal.xlsx", sheet("skill_`v'") firstrow clear
		qui: import excel using "${excel}\HND_public_premium_oaxaca.xlsx", sheet("skill_`v'") firstrow clear
		
		drop O-AC
		*qui: export excel using "${excel}\HND_public_premium_oaxaca_formal.xlsx", sheet("skill_`v'") sheetreplace firstrow(varlab)
		qui: export excel using "${excel}\HND_public_premium_oaxaca.xlsx", sheet("skill_`v'") sheetreplace firstrow(varlab)
		
		restore
	} //close skill loop

	
} //close year loop

exit

/* 

	*********************************
	**** (3) Health and Education****
	*********************************
	/*
	qui: oaxaca lnwage `controls'  if inrange(edad,18,65) & ocupado == 1 & ytrab_real>0 & (sector1d==13 | sector1d==14) [w=pondera], by(pubsector) //pubsector vs private social_security EDUCATION
	
	*Export results to excel
	qui: putexcel set "${excel}\HND_public_premium_oaxaca_formal.xlsx", sheet("health_edu") modify	
	
	local j = `n_c'+1
	putexcel A1=("Year")
	putexcel A`j'=("`y'")
	putexcel B`j'=matrix(e(b))
	putexcel B1=("Private") 
	putexcel C1=("Public")
	putexcel D1=("Differences")
	putexcel E1=("Endowment")
	putexcel F1=("Coefficient")
	putexcel G1=("Interaction")
	putexcel H1=("Years of Education")
	putexcel I1=("Years of Education squared")
	putexcel J1=("Experience")
	putexcel K1=("Exp. squared")
	putexcel L1=("Male")
	putexcel M1=("Urban")
	putexcel N1=("Part Time")
	
	preserve
	qui: import excel using "${excel}\HND_public_premium_oaxaca_formal.xlsx", sheet("health_edu") firstrow clear
	drop O-AC
	qui: export excel using "${excel}\HND_public_premium_oaxaca_formal.xlsx", sheet("health_edu") sheetreplace firstrow(varlab)
	restore 
	
	foreach x of numlist 13 14 {
		local n: label (sector1d) `x'
		local controls "aedu aedu2 exp expsq hombre urbano part_time"  
		qui: oaxaca lnwage `controls'  if inrange(edad,18,65) & ocupado == 1 & ytrab_real>0 & (sector1d==`x') [w=pondera], by(pubsector) //pubsector vs private social_security EDUCATION
		*Export results to excel
		qui: putexcel set "${excel}\HND_public_premium_oaxaca_formal.xlsx", sheet("`n'") modify	
		
		local j = `n_c'+1
		putexcel A1=("Year")
		putexcel A`j'=("`y'")
		putexcel B`j'=matrix(e(b))
		putexcel B1=("Private") 
		putexcel C1=("Public")
		putexcel D1=("Differences")
		putexcel E1=("Endowment")
		putexcel F1=("Coefficient")
		putexcel G1=("Interaction")
		putexcel H1=("Years of Education")
		putexcel I1=("Years of Education squared")
		putexcel J1=("Experience")
		putexcel K1=("Exp. squared")
		putexcel L1=("Male")
		putexcel M1=("Urban")
		putexcel N1=("Part Time")
		
		preserve
		qui: import excel using "${excel}\HND_public_premium_oaxaca_formal.xlsx", sheet("`n'") firstrow clear
		drop O-AC
		qui: export excel using "${excel}\HND_public_premium_oaxaca_formal.xlsx", sheet("`n'") sheetreplace firstrow(varlab)
		restore
		
	}
	*/
