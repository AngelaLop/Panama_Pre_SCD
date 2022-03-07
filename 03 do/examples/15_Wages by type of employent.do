
global rootdatalib "\\gpvdrlac\DATALIB\Datalib"
global excel "\\GPVDRLAC\lcspp\public\Honduras\02_Projects\28_SCD_Update_2021\excel"
 
tempname pob 
tempfile aux 
postfile `pob' str100(Year Group Value) using `aux', replace

datalib, count(hnd) year(2019) mod(all) clear
su ipc_sedlac
local ipc_2019 = r(mean)

foreach y of numlist 2011/2019 {
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
		
		* Wages in real terms and logs:
		gen double real_wage= ytrab_obs2*(`ipc_2019'/ipc_sedlac)
		replace real_wage=. if relab==4
		
		gen pubsector = .
		replace pubsector =1 if empresa == 3 // 0 = small and large firms relative to FORMAL private sector 
		replace pubsector=0 if inrange(empresa,1,2) & social_security==1
		
		gen pubsector2 = .
		replace pubsector2 =1 if empresa == 3 // 0 = small and large firms, relative to ALL private sector (excluding self-employed) 
		replace pubsector2=0 if inrange(empresa,1,2) & relab!=3
		
		*** Private sector, wage earner, pays into SS / sindicato = 1 *** 
		gen private_salaried_ss = 0
		replace private_salaried_ss = 1 if inrange(empresa,1,2) & social_security == 1 & relab == 2
		
		*** Private sector, wage earner, does not pay into SS ***  	
		gen private_salaried = 0
		replace private_salaried = 1 if inrange(empresa,1,2) & social_security == 0 & relab == 2
		
		*** Private , self-employed***
		gen private_self = 0
		replace private_self = 1 if inrange(empresa,1,2) & relab == 3
		
		su real_wage [w=pondera] if ocupado==1 & inrange(edad,15,65) & relab==3		
		post `pob' ("`y'")  ("Self-employed") ("`r(mean)'")	
		
		su real_wage [w=pondera] if ocupado==1 & inrange(edad,15,65) & empresa==3		
		post `pob' ("`y'")  ("Public sector") ("`r(mean)'")	
		
		su real_wage [w=pondera] if ocupado==1 & inrange(edad,15,65) &  inrange(empresa,1,2)  & social_security==1	
		post `pob' ("`y'")  ("Private sector-formal") ("`r(mean)'")	
		
		su real_wage [w=pondera] if ocupado==1 & inrange(edad,15,65) &  inrange(empresa,1,2)  & social_security==0
		post `pob' ("`y'")  ("Private sector-informal") ("`r(mean)'")	
		
		su real_wage [w=pondera] if ocupado==1 & inrange(edad,15,65) & sector1d==16
		post `pob' ("`y'")  ("Domestic") ("`r(mean)'")	
}
				
postclose `pob'
use `aux', clear

destring, replace 

export excel using "${excel}\wages_types.xlsx", sheet("dta") sheetreplace firstrow(variables)

