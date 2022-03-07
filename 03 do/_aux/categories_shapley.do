
cap drop area
gen area=.
replace area=1 if urbano==0 // rural
replace area=2 if urbano==1 // urban
label var area "Urban/Rural Area"
label de larea 1 "Rural" 2 "Urban"

local larea1 "Rural"
local larea2 "Urban"

/*
cap drop state
gen byte state = region_est2
label var state "Region at 1 digit (ADMN1)"
label de lstate 1 "Aguascalientes" 2 "Baja_California" 3 "Baja_California_Sur" ///
4 "Campeche" 5 "Cohauila" 6 "Colima" 7 "Chiapas" 8 "Chihuahua" 9 "Distrito_Federal"	/// 
10 "Durango" 11 "Guanajuato" 12 "Guerrero" 13 "Hidalgo" 14 "Jalisco" 15 "Edo_Mexico" ///
16 "Michoacan" 17 "Morelos" 18 "Nayarit" 19 "Nuevo_Leon" 20 "Oaxaca" 21 "Puebla" ///
22 "Queretaro" 23 "Quintana_Roo" 24 "San Luis Potosi" 25 "Sinaloa" 	///
26 "Sonora" 27 "Tabasco" 28 "Tamaulipas" 29 "Tlaxcala" 30 "Veracruz" ///
31 "Yucatan" 32 "Zacatecas"
label values state lstate

local lstate1 "Aguascalientes" 
local lstate2 "Baja_California"
local lstate3 "Baja_California_Sur" 
local lstate4 "Campeche" 
local lstate5 "Cohauila" 
local lstate6 "Colima" 
local lstate7 "Chiapas" 
local lstate8 "Chihuahua" 
local lstate9 "Distrito_Federal"	
local lstate10 "Durango" 
local lstate11 "Guanajuato" 
local lstate12 "Guerrero" 
local lstate13 "Hidalgo" 
local lstate14 "Jalisco" 
local lstate15 "Edo_Mexico" 
local lstate16 "Michoacan" 
local lstate17 "Morelos" 
local lstate18 "Nayarit" 
local lstate19 "Nuevo_Leon" 
local lstate20 "Oaxaca" 
local lstate21 "Puebla" 
local lstate22 "Queretaro" 
local lstate23 "Quintana_Roo" 
local lstate24 "San Luis Potosi" 
local lstate25 "Sinaloa" 	
local lstate26 "Sonora" 
local lstate27 "Tabasco" 
local lstate28 "Tamaulipas" 
local lstate29 "Tlaxcala" 
local lstate30 "Veracruz" 
local lstate31 "Yucatan" 
local lstate32 "Zacatecas"	
*/

********************************************************************************
