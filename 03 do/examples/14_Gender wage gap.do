/*===========================================================================
project:          Gender gap for Honduras SDC
---------------------------------------------------------------------------
Creation Date:    September 22, 2021 
Ouput:            This do-files produces mincer regressions for gender premium
===========================================================================*/

global rootdatalib "\\gpvdrlac\DATALIB\Datalib"
global excel "\\GPVDRLAC\lcspp\public\Honduras\02_Projects\28_SCD_Update_2021\excel"

tempname pob 
tempfile aux 
postfile `pob' str100(Year Group Value) using `aux', replace

datalib, count(hnd) year(2019) mod(all) clear
su ipc_sedlac
local ipc_2019 = r(mean)

foreach n of numlist 2011/2019 {
	datalib, country(hnd) year(`n') mod(all) nocohh clear

	* Wages in real terms and logs:
	gen double real_wage= ytrab_obs2*(`ipc_2019'/ipc_sedlac)
	gen wage_ppp=real_wage/(hstrt*4.33) //hourly wages
	replace wage_ppp=. if relab==4

	/* 1 Agricultura, Ganadería, Caza y Silvicultura
           2 Pesca
           3 Explotación de Minas y Canteras
           4 Industrias Manufactureras
           5 Suministro de Electricidad, Gas y Agua
           6 Construcción
           7 Comercio
           8 Hoteles y Restaurantes
           9 Transporte, Almacenamiento y Comunicaciones
          10 Intermediación Financiera
          11 Actividades Inmobiliarias, Empresariales y de Alquiler
          12 Administración Pública y Defensa
          13 Enseñanza
          14 Servicios Sociales y de Salud
          15 Otras Actividades de Servicios Comunitarios, Sociales y Personales
          16 Hogares Privados con Servicio Doméstico
          17 Organizaciones y Órganos Extraterritoriales */
		  
	gen sector_4 = .		
	replace sector_4 = 1 if inrange(sector1d,1,3) // Primary
	replace sector_4 = 2 if (sector1d == 4) // Industry
	replace sector_4 = 3 if (sector1d == 5 | sector1d == 6 | sector1d==9) //Transport, Construction & Utilities
	replace sector_4 = 4 if (sector1d == 7 ) // Retail
	replace sector_4 = 5 if (sector1d==8 | sector1d>9) // Services 
	replace sector_4=. if sector1d==. 
	
	su real_wage [w=pondera] if ocupado==1 & inrange(edad,15,65) & hombre==1  
	local value = r(mean)
	
	su real_wage [w=pondera] if ocupado==1 & inrange(edad,15,65) & hombre==0  
	local gap = (`value'/`r(mean)')-1
	post `pob' ("`n'") ("Gender")  ("`gap'")	
	
	foreach x of numlist 1/5 {
		su real_wage [w=pondera] if ocupado==1 & inrange(edad,15,65) & hombre==1  & sector_4==`x'
		local value = r(mean)	
		
		su real_wage [w=pondera] if ocupado==1 & inrange(edad,15,65) & hombre==0  & sector_4==`x'
		local gap = (`value'/`r(mean)')-1
		
		post `pob' ("`n'")  ("`x'") ("`gap'")	
	}
				
}


postclose `pob'
use `aux', clear

destring, replace 

replace Group = "Primary" if Group=="1"
replace Group = "Industry" if Group=="2"
replace Group = "Transport, Construction & Utilities" if Group=="3"
replace Group = "Retail" if Group=="4"
replace Group = "Services" if Group=="5"

export excel using "${excel}\gender_wage_gap.xlsx", sheet("dta") sheetreplace firstrow(variables)


