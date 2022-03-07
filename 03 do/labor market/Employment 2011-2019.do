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



*Tempfiles
tempfile tf_postfile3 
tempname tn3
postfile `tn3' str50(iso country year variable indicator sex cut labels rate population) using `tf_postfile3', replace

forvalues yr = 15(1)19 {

		*----------------------- loading and Harmonization Data -----------------------*
		
		datalibweb, country(pan) year(20`yr') type(sedlac-03) mod(all) clear
		
		cap keep if cohh==1 

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
cap drop total 
gen total = 1
gen mujer = (hombre==0)
gen e_15_mas = edad>=15

* regiones

	encode region_est2, g(region)
	
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


	
* nivel educativo 
g e_ninguno = inlist(nivel,0,1)
g e_primaria = inlist(nivel,2,3)  
g e_secundaria  = inlist(nivel,4,5) 
g e_terciaria  = inlist(nivel,6)  


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


*Labor Income percapita
gen factor_ppp11=(ipc11_sedlac/ipc_sedlac)/(ppp11*conversion)
gen ila_ppp11= ila*factor_ppp11
bysort id: egen ila_pc= total(ila_ppp11*1/miembros) 
gen ila_ppp11_hora = ila_ppp11/horas_1
* Sector
recode sector1d (2=1) (3/6=2) (7/17=3) if sector1d!=. , gen(sector_3)
replace sector_3=. if sector1d==999

* Dummies of Sector (3 Macro Sectors)
gen _s10301 = (sector_3 == 1)		          // Agriculture
gen _s10302 = (sector_3 == 2)		          // Industry
gen _s10303 = (sector_3 == 3)		          // Services

*Dummies of sectors (10 Categories)
gen _s1001 = (sector == 1)                      // Agricultural, primary activities
gen _s1002 = (sector == 2)                      // low-tech industries
gen _s1003 = (sector == 3)                      // rest of manufacturing industry
gen _s1004 = (sector == 4)                      // Construction
gen _s1005 = (sector == 5)                      // retail and wholesale, restaurants, hotels, repairs
gen _s1006 = (sector == 6)                      // electricity, gas, water, transport, communications
gen _s1007 = (sector == 7)                      // banks, finance, insurance, professional services
gen _s1008 = (sector == 8)                      // public administration and defense
gen _s1009 = (sector == 9)                      // education, health, personal services
gen _s1010 = (sector == 10)                     // domestic service
gen _s1099 = (sector == . & ocupado==1 )        // Unknown sector

tab rama, g(rama_)
*---------------------------------Formal/ Informal -------------------------------------------------*
gen     d_informal=(djubila!=1 & dsegsale!=1 & daguinaldo!=1 & dvacaciones!=1) 
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

* informalidad
	*informalidad
	g formal = (categ_lab==1)
	g informal = (categ_lab==2)
* infoemalidad ofical nacional 
	g formal3 = (informal3==0)
* area
g rural = (urbano==0)
g rural_agro = (_s1001==1) & (rural==1) 	

/* 	=========================================================================================
									  1: Poverty indicators                                  
=========================================================================================== */
		
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
	
	
		local inc ipcf_ppp11
		
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
		
		


/*===============================================================================================
                            1: labor Market Indicators
===============================================================================================*/

	dis "*----------calculating labor Market indicators of `b' by Total sector and sex ---------------*"

	local sexs total p_19 p_32 p_55 p_13 p_70 p_70_plus
	*local sexs total hombre mujer  Bocas_del_Toro Cocle Colon Chiriqui Darien Herrera Los_Santos Panama Veraguas Comarca_Kuna_Yala Comarca_Embera Comarca_Ngobe_Bugle Panama_Oeste e_ninguno e_primaria e_secundaria e_terciaria
	 local cuts rama_1 rama_2 rama_3 rama_4 rama_5 rama_6 rama_7 rama_8 rama_9 rama_10 rama_11 rama_12 rama_13 rama_14 rama_15 rama_16 rama_17 rama_18 rama_19 rama_20 rama_21 
	*local cuts total _s1001 _s1002 _s1003 _s1004 _s1005 _s1006 _s1007 _s1008 _s1009 _s1010 rural_agro rural urbano

foreach sex of local sexs {
	foreach cut of local cuts{

		local lfps pea_1 ocupado_1 e_15_mas total 
			
		foreach lfp of local lfps {
			include "$do\labels iml.do"
		* Labor force participation
	
		sum `lfp' [iw = pondera] if e_15_mas==1 & `cut'==1 & `sex'==1
		local rate = r(mean)*100
		local pop = r(sum)
		post `tn3' ("`ind'") ("`ind_lb'") ("20`yr'") ("`lfp'") ("`indicator'") ("`sex'") ("`cut'") ("`labels'") ("`rate'") ("`pop'")
		
		}
		
		sum e_15_mas [iw = pondera] if  `cut'==1 & `sex'==1
		local rate = r(mean)*100
		local pop = r(sum)
		post `tn3' ("`ind'") ("`ind_lb'") ("20`yr'") ("e_15_mas") ("PET") ("`sex'") ("`cut'") ("PET") ("`rate'") ("`pop'")
		
		*Employment/unemployment (over Labor force participation)
		local imls ocupado_1 desocupado_1
			
		foreach iml of local imls {
			include "$do\labels iml.do"
		sum `iml' [iw=pondera] if e_15_mas==1 & pea_1==1 & `cut'==1 & `sex'==1
		local share = r(mean)*100
		local pop = r(sum)
		post `tn3' ("`ind'") ("`ind_lb'") ("20`yr'") ("`iml'") ("`indicator'") ("`sex'") ("`cut'") ("`labels'") ("`share'") ("`pop'")
		}
/*		
		* Employment Characteristics 
		local ocupado_chs d_informal _i602 informal_size _i702 informal_labor _i802 informal_sala_self _i902 formal informal informal3 formal3

		foreach ocupado_ch of local ocupado_chs {
				include "$do\labels iml.do"
		* Informal Workers
		sum `ocupado_ch' [iw=pondera] if e_15_mas==1  & ocupado_1==1 & `cut'==1 & `sex'==1
		local share = r(mean)*100
		local pop = r(sum)
		post `tn3' ("`ind'") ("`ind_lb'") ("20`yr'") ("`ocupado_ch'") ("`indicator'") ("`sex'") ("`cut'") ("`labels'") ("`share'") ("`pop'")
		}
		
		* Labour income - mean-median  
		
		cap sum ila_ppp11 [w=pondera] if e_15_mas==1  & ocupado_1==1 & `cut'==1 & `sex'==1, detail
		local share = r(p50) 
		di `share'
		local pop = r(N)
		post `tn3' ("`ind'") ("`ind_lb'") ("20`yr'") ("ila_ppp11") ("Median labor income ppp11") ("`sex'") ("`cut'") ("`labels'") ("`share'") ("`pop'")
		
		cap sum ila_ppp11 [iw=pondera] if e_15_mas==1  & ocupado_1==1 & `cut'==1 & `sex'==1
		local share = r(mean) 
		di `share'
		local pop = r(N)
		post `tn3' ("`ind'") ("`ind_lb'") ("20`yr'") ("ila_ppp11") ("Mean labor income ppp11") ("`sex'") ("`cut'") ("`labels'") ("`share'") ("`pop'")
		
		cap sum ila_ppp11_hora [w=pondera] if e_15_mas==1  & ocupado_1==1 & `cut'==1 & `sex'==1, detail
		local share = r(p50) 
		di `share'
		local pop = r(N)
		post `tn3' ("`ind'") ("`ind_lb'") ("20`yr'") ("ila_ppp11_hora") ("Median labor income hour ppp11") ("`sex'") ("`cut'") ("`labels'") ("`share'") ("`pop'")
		
		cap sum ila_ppp11_hora [iw=pondera] if e_15_mas==1  & ocupado_1==1 & `cut'==1 & `sex'==1
		local share = r(mean) 
		di `share'
		local pop = r(N)
		post `tn3' ("`ind'") ("`ind_lb'") ("20`yr'") ("ila_ppp11_hora") ("Mean labor income hour ppp11") ("`sex'") ("`cut'") ("`labels'") ("`share'") ("`pop'")
		
	*/
	}/* cuts */
 }/*sexs*/
}
	

postclose `tn3' 
use `tf_postfile3', clear 
destring year rate population, replace
export excel "${out}\Employment_Indicators_PAN_dis.xlsx", sheetreplace firstrow(variables) sheet("Labor") 

exit
		