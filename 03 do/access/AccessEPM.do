/* 	=======================================================================================
	Project:            Panama: populations access to basic services
	Author:             By Angela Lopez
	Organization:       The World Bank-ELCPV
	---------------------------------------------------------------------------------------
	Creation Date:       Feb 07 ,2022 
	Modification Date:   
	Output:             
	======================================================================================= */

/*===============================================================================================
                                  0: Program set up
===============================================================================================*/

clear 
global path "C:\Users\WB585318\WBG\Javier Romero - Panama\data\EPM 2019"

local bases vivienda hogar persona

foreach base of local bases {
	
import dbase using "${path}\\`base'.dbf"
sort LLAVE_SEC
save "${path}\\`base'.dta", replace 
clear 
}

use "${path}\hogar.dta", replace
merge m:m LLAVE_SEC using "${path}\vivienda.dta"
drop _merge
merge m:m LLAVE_SEC using "${path}\persona.dta"


save "${path}\\EPM2019.dta", replace 


use "${path}\EPM2019.dta", replace 

foreach v of varlist _all {
      capture rename `v' `=lower("`v'")'
   }
   
   		local ind 	 "pan"
		local ind_lb "Panama"
		local yr 19

	*Ind and hh counter
	g total =1
	*gen hhhead_count = 1 if relacion == 1
	gen mujer = (p2==2)
	gen hombre = (p2==1)
	* PET >18 calificada 
	
	gen ocupado = (ocu_des=="Ocupados")
	gen desocupado = (ocu_des=="Desocupados")
	
	g rama = p28reco
	destring rama, replace 
	*rama agregada
	cap gen rama_a =1 if inlist(rama,1)  // Agricultura
	replace rama_a =2 if inlist(rama,3) // industria  	
	replace rama_a =3 if inlist(rama,2,4,5) // otras 	
	replace rama_a =4 if inlist(rama,6) // Construcción
	replace rama_a =5 if inlist(rama,7) // Comercio
	replace rama_a =6 if inlist(rama,8) // Transporte
	replace rama_a =7 if inlist(rama,9) // hotles restaur
	replace rama_a =8 if inlist(rama,13,14,16,17,19,18,21,20) // Servicios comunales, sociales y personales
	replace rama_a =9 if inlist(rama,15) //Adm. Pública y Defensa
	replace rama_a =10 if inlist(rama,10,11,12) //financieras, inmobiliarias y de comunicacion
	
	*rama agregada sectores
	
	 gen rama_sec =1 if inlist(rama,1)  // Agricultura
	replace rama_sec =2 if inlist(rama,2,3,4,5,6) // industria  	
	replace rama_sec =3 if rama > 6 // industria  	
	
	cap gen rama_s =1 if inlist(rama,1)  // Agricultura
	replace rama_s =2 if inlist(rama,2,3,4,5,6) // industria  		
	replace rama_s =3 if inlist(rama,7) // comercio
	replace rama_s =4 if rama>7 // servicios
	
	* posicion ocupacional 
	
	gen posicion=p31
	replace posicion = 2 if inlist(posicion,2,3,4,9)
		label var posicion "Posicion ocupacional"
		label define grupos_p ///
		1 "Empleado(a) del Gobierno" ///
		2 "Empleado(a) empersa priv" ///
		5 "Empleado(a) servicio domestico"  ///
		7 "Indep. Por cuenta propia" ///
		8 "Indep. Patrono(a) dueño(a)" ///
		9 "Miembro de una cooperativa de producción"  ///
		10 "Trabajador(a) familiar" , replace 
		label values posicion grupos_p	
	
	
	
	*area 
	g urbano_ = (areareco=="Urbana")
	g rural_=	(areareco=="Rural")
	
	* regiones
	encode provincia, g(region)
	
	g Bocas_del_Toro 	= (region==1)
	g Cocle 			= (region==2)
	g Colon 			= (region==3)
	g Chiriqui 			= (region==4)
	g Darien 			= (region==5)
	g Herrera 			= (region==6)
	g Los_Santos		= (region==7)
	g Panama 			= (region==8)
	g Veraguas 			= (region==9)
	g Comarca_Kuna_Yala = (region==10)
	g Comarca_Embera 	= (region==11)
	g Comarca_Ngobe_Bugle = (region==12)
	g Panama_Oeste 		= (region==13)
	
	g comarcas = inlist(region,10,11,12)
	g provincias = (comarcas==0)
	
	*poor_550ppp1
	gen pondera = fac15_e
	*indig
	*afrod

		
	*Age:
	gen edad = p3	
	tab edad, miss
	gen edad_grp_65plus = (edad>=65)
		

// Indigenous
	
	gen indig = (p4d!=11)
	replace indig = . if p4d==.
	

// Afro-decendants


	gen afrod = (p4f!=8)
	replace afrod = . if p4f==.
	
* saneamiento 
destring v1m_basura, replace
g trash = 1
replace trash = 0 if urbano==1 & inlist(v1m_basura, 3,4,5,6,7)
replace trash = 0 if urbano==0 & inlist(v1m_basura, 3,4,6,7)

* Adequate sanitation facilities
* definition: not adequate: Urban areas: the dweling 


destring v1k_servic v1l_uso_sa, replace
g sanitation = 1
replace sanitation = 0 if inlist(v1k_servic,1,4)
replace sanitation = 0 if inlist(v1k_servic,2,3) & v1l_uso_sa==2

* water facilities 
destring v1i_agua_b v1j1_veran v1j1_invie v1j2_veran v1j2_invie, replace 
g water = 1
replace water = 0 if inlist(v1i_agua_b,5,6,7,8,9,11)
replace water = 0 if inlist(v1i_agua_b, 1,2,3,4) & ((v1j1_veran<7 | v1j1_invie<7) |  (v1j2_veran<12 | v1j2_invie<12) )

* electricity:
 
destring v1o_luz, replace 
g electricity = 1
replace electricity = 0 if inlist(v1o_luz,4,5,6,8) 

* movil phone 
destring h2b_celula, replace 
g phone = 1
replace phone =0 if h2b_celula==2
* internet 
destring h5_int_mov h5_serv_in, replace 
g internet = 1 
replace internet = 0 if h5_int_mov==2 & h5_serv_in==2
* housing 
destring v1f_materi v1e_materi v1d_materi, replace
g housing = 1
replace housing = 0 if urbano_==1 & inlist(v1d_materi,2,3,4,5,6,7) | inlist(v1f_materi,4,5,6) | inlist(v1d_materi,5,6,7)
replace housing = 0 if rural_==1 & comarcas==0 & inlist(v1d_materi,4,5,6,7) | inlist(v1f_materi,5,6) | inlist(v1d_materi,5,6,7)
replace housing = 0 if comarcas==1 & inlist(v1d_materi,4,6,7) | inlist(v1f_materi,5,6) | inlist(v1d_materi,5,7)

tempfile tf_postfile3 
tempname tn3
postfile `tn3' str50(iso country year variable cut rate population) using `tf_postfile3', replace

local cuts total hombre mujer indig afrod urbano_ rural_ comarcas provincias

	foreach cut of local cuts{

		local lfps trash sanitation water electricity phone internet housing
			
		foreach lfp of local lfps {
	
		* Access to basic services 
	
		sum `lfp' [iw = pondera] if p1==1 & `cut'==1 
		local rate = r(mean)*100
		local pop = r(sum)
		post `tn3' ("`ind'") ("`ind_lb'") ("20`yr'") ("`lfp'") ("`cut'") ("`rate'") ("`pop'")
		
		}
		

	
	}/* cuts */

	

postclose `tn3' 
use `tf_postfile3', clear 
destring year rate population, replace
export excel "${out}\Access_Indicators_PAN.xlsx", sheetreplace firstrow(variables) sheet("Access") 

exit

