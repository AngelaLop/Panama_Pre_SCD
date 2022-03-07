/* 	=======================================================================================
	Project:            Panama: Labor profile
	Author:             By Angela Lopez
	Organization:       The World Bank-ELCPV
	---------------------------------------------------------------------------------------
	Creation Date:       Jan 24 ,2022 
	Modification Date:   
	Output:             
	======================================================================================= */

/*===============================================================================================
                                  0: Program set up
===============================================================================================*/


cap restore 
clear all                   

* Directory Paths
global proj   "C:\Users\WB585318\WBG\Javier Romero - Panama\Pre-SCD"
global do     "${proj}\03 do\labor market"
global out    "${proj}\04 results"
global data   "C:\Users\WB585318\WBG\Javier Romero - Panama\data\EML 2020 v2"



*Tempfiles
tempfile tf_postfile3 
tempname tn3
postfile `tn3' str50(iso country year variable indicator sex cut labels rate population) using `tf_postfile3', replace

use "$data\EML_completa.dta"

/*===============================================================================================
                                  0: Constructing variables
===============================================================================================*/

*Age range
*if "`lfage'" == "" local lfage "18,65"
if "`lfage'" == "" local lfage "15,65"


		* Country Names and ISO
		local ind 	 "pan"
		local ind_lb "Panama"
		*local yr "19"
		
*Generating variables


g total =1
g pais = "PAN"
g ano = 2020
g id = llave_sec
g pondera = fac15_e
g relacion = p1
g jefe = inlist(p1,1)
g jefe_h=sexo_jefe
replace jefe_h =0 if jefe_h==2
g ocupacion = p28reco
g jefa = 1 if jefe_h==0 & jefe==1
replace jefa= 0 if jefe_h==1 & jefe==1



* nivel educativo 
	g e_ninguno = inlist(p8,1,2,3,11,12,13,14,15)  
	g e_primaria = inlist(p8,16,21,22,31,32,33,34,35)  
	g e_secundaria  = inlist(p8,23,36,41,42,51,52,53,54) 
	g e_terciaria  = inlist(p8,55,56,61,71,72,82,83,84)  


*grupos de edad

encode edad_reco, gen(edad_rango) 
g gedad1 = 1 if inlist(edad_rango, 1, 8) // 0-9
replace gedad1 = 2 if inlist(edad_rango, 2) //10-14
replace gedad1 = 3 if inlist(edad_rango, 3,4) //15-24
replace gedad1 = 4 if inlist(edad_rango, 5,6) //25-39
replace gedad1 = 5 if inlist(edad_rango, 7,9) //40-59
replace gedad1 = 6 if inlist(edad_rango, 10,11) // 60

label var gedad1 "Grupos de edad"
label define grupos_e 1 "0-09" 2 "10-14" 3 "15-24" 4 "25-39" 5 "40-59" 6 "60+", replace
label values gedad1 grupos_e

* etnias
g indig = 1
replace indig = 0 if p4d_indige == 11

g afrod = 1
replace afrod = 0 if p4f_afrod == 8








gen posicion = p33
replace posicion = 2 if inlist(posicion,2,3,4,9)
label var posicion "Posicion ocupacional"
label define grupos_p ///
1 "Empleado(a) del Gobierno" ///
2 "Empleado(a) empersa priv" ///
5 "Empleado(a) sericio domestico"  ///
7 "Indep. Por cuenta propia" ///
8 "Indep. Patrono(a) dueño(a)" ///
9 "Miembro de una cooperativa de producción"  ///
10 "Trabajador(a) familiar" , replace 
label values posicion grupos_p

*=====================================================================
* 		Ingresos 
*==============================================================================

* ingreso laboral 
egen ip = rsum(p421 p423), missing
egen ila = rsum(ip p422 p424 p425)



cap gen total = 1
gen hombre = (p2=="1")
gen mujer = (p2=="2")
gen e_15_mas = inlist(gedad,3,4,5,6)
gen ocupado_1 = ocu_des=="Ocupados" if e_15_mas==1
gen desocupado_1 =  ocu_des=="Desocupados" if e_15_mas==1
gen pea_1 = (desocupado_1==1)| (ocupado_1==1)
gen ipc11_sedlac = 105.8758
gen ppp11 = 0.55323857
g conversion =1
*Labor Income percapita
g ipc = 2.3723976671893 // julio 2020
g ipc_sedlac= 125.3497
gen factor_ppp11=(ipc11_sedlac/ipc_sedlac)/(ppp11*conversion)
gen ila_ppp11= ila*factor_ppp11


	destring  p28reco, g(ocupacion_1)

	replace posicion = 2 if inlist(posicion,2,3,4,9)
	g ocupados_no_prof = ocupado_1 ==1
	replace ocupados_no_prof = 0 if inlist(posicion,7,8) & (inlist(ocupacion_1, 1,2))
	

*sector economico

destring p30reco, gen(rama)

/*
* Dummies of Sector (3 Macro Sectors)
gen _s10301 = (sector_3 == 1)		          // Agriculture
gen _s10302 = (sector_3 == 2)		          // Industry
gen _s10303 = (sector_3 == 3)		          // Services
*/
*Dummies of sectors (10 Categories)
gen _s1001 = inlist(rama, 1,2)                // Agricultural, primary activities
gen _s1002 = .			                      // low-tech industries
gen _s1003 = inlist(rama, 3)                 // rest of manufacturing industry
gen _s1004 = inlist(rama, 6)                                      // Construction
gen _s1005 = inlist(rama, 7,9)                                      // retail and wholesale, restaurants, hotels, repairs
gen _s1006 = inlist(rama, 4,5,8,10)                                 // electricity, gas, water, transport, communications
gen _s1007 = inlist(rama, 11,12,13,14)                              // banks, finance, insurance, professional services
gen _s1008 = inlist(rama, 15,21)                                    // public administration and defense
gen _s1009 = inlist(rama, 16,17,18,19)                              // education, health, personal services
gen _s1010 = inlist(rama, 20)                                     // domestic service
gen _s1099 = (rama == . & ocupado_1==1 )        // Unknown sector


*---------------------------------Formal/ Informal -------------------------------------------------*
/*gen     d_informal=(djubila!=1 & dsegsale!=1 & daguinaldo!=1 & dvacaciones!=1) 
replace d_informal=0 if empresa==3 
replace d_informal=. if ocupado!=1 

gen _i601 = (d_informal == 1) // Informal
gen _i602 = (d_informal == 0) // Formal 


*Informality 1 (SEDLAC Definition)
* All employed that are informal (according with SEDLAC definition) ages 15-65
*(% of total employed)

gen     informal_size =categ_lab==2
replace informal_size=. if (edad<15 | edad>65) | ocupado!=1 | inrange(relab,1,4)!=1

gen _i701 = (informal_size == 1) // Informal
gen _i702 = (informal_size == 0) // Formal 


*Informality 2 (Labor benefits)
* All employed that DON'T receive pension, health insurance, aguinaldo and  vacations benefits and DONT work in a public company ages 15-65
*(% of total employed)
gen informal_labor=(djubila!=1 & dsegsale!=1 & daguinaldo!=1 & dvacaciones!=1)
replace informal_labor=0 if empresa==3
replace informal_labor=. if (edad<15 | edad>65) | ocupado!=1 | inrange(relab,1,4)!=1

gen _i801 = (informal_labor == 1) // Informal
gen _i802 = (informal_labor == 0) // Formal 

*Salaried workers and Self-employment that are informal
*All Informal (SEDLAC Definition) that are Salaried worker OR self employed  ages 15-65
*(% of total employed)
gen     informal_sala_self=categ_lab==2 & (relab==2 | relab==3) 
replace informal_sala_self=. if (edad<15 | edad>65) | ocupado!=1 | inrange(relab,1,4)!=1

gen _i901 = (informal_sala_self == 1) // Informal
gen _i902 = (informal_sala_self == 0) // Formal 
*/
* informalidad
	*informalidad
	g formal = (form_infor=="Formal") if rama!=1 & ocupado_1==1
	g informal = (form_infor=="Informal") if rama!=1 & ocupado_1==1

	g informal3 =0 if ocupado_1 ==1
	replace informal3 =1 if p4!=1 & ocupado_1 ==1	
	replace informal3 =1 if p34==5
	replace informal3 =0 if p4==1 | p4 == 4 & ocupado_1 ==1	
	replace informal3 =. if rama==1 //  ocupados exuyendo ocupaciones agricultura
	replace informal3 =. if ocupados_no_prof==0 //* ocupados exuyendo  profecionales y tecnicos cuenta propia o patrono

/*===============================================================================================
                            1: labor Market Indicators
===============================================================================================*/

	dis "*----------calculating labor Market indicators of `b' by Total sector and sex ---------------*"
	local sexs total hombre mujer
	local cuts total _s1001 _s1002 _s1003 _s1004 _s1005 _s1006 _s1007 _s1008 _s1009 _s1010 e_ninguno e_primaria e_secundaria e_terciaria 

foreach sex of local sexs {
	foreach cut of local cuts{

		local lfps pea_1 ocupado_1
			
		foreach lfp of local lfps {
			include "$do\labels iml.do"
		* Labor force participation
	
		sum `lfp' [iw = pondera] if e_15_mas==1 & `cut'==1
		local rate = r(mean)*100
		local pop = r(sum)
		post `tn3' ("`ind'") ("`ind_lb'") ("20`yr'") ("`lfp'") ("`indicator'") ("`sex'") ("`cut'") ("`labels'") ("`rate'") ("`pop'")
		
		}
		
		*Employment/unemployment (over Labor force participation)
		local imls ocupado_1 desocupado_1
			
		foreach iml of local imls {
			include "$do\labels iml.do"
		sum `iml' [iw=pondera] if e_15_mas==1 & pea_1==1 & `cut'==1
		local share = r(mean)*100
		local pop = r(sum)
		post `tn3' ("`ind'") ("`ind_lb'") ("20`yr'") ("`iml'") ("`indicator'") ("`sex'") ("`cut'") ("`labels'") ("`share'") ("`pop'")
		}
		
		* Employment Characteristics 
		local ocupado_chs formal informal

		foreach ocupado_ch of local ocupado_chs {
				include "$do\labels iml.do"
		* Informal Workers
		sum `ocupado_ch' [iw=pondera] if e_15_mas==1  & ocupado_1==1 & `cut'==1
		local share = r(mean)*100
		local pop = r(sum)
		post `tn3' ("`ind'") ("`ind_lb'") ("20`yr'") ("`ocupado_ch'") ("`indicator'") ("`sex'") ("`cut'") ("`labels'") ("`share'") ("`pop'")
		}
		
		* Labour income - mean-median  
		
		cap sum ila_ppp11 [w=pondera] if e_15_mas==1  & ocupado_1==1 & `cut'==1, detail
		local share = r(p50) 
		di `share'
		local pop = r(N)
		post `tn3' ("`ind'") ("`ind_lb'") ("20`yr'") ("ila_ppp11") ("Median labor income ppp11") ("`sex'") ("`cut'") ("`labels'") ("`share'") ("`pop'")
		
		cap sum ila_ppp11 [iw=pondera] if e_15_mas==1  & ocupado_1==1 & `cut'==1
		local share = r(mean) 
		di `share'
		local pop = r(N)
		post `tn3' ("`ind'") ("`ind_lb'") ("20`yr'") ("ila_ppp11") ("Mean labor income ppp11") ("`sex'") ("`cut'") ("`labels'") ("`share'") ("`pop'")
	}/* cuts */
}
	

postclose `tn3' 
use `tf_postfile3', clear 
destring year rate population, replace
export excel "${out}\Employment_Indicators_PAN_2020.xlsx", sheetreplace firstrow(variables) sheet("Labor") 

exit
		