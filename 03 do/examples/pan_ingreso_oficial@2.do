*-----------------------------------------------------------------------------*
* Date: May 06,2013
* Kiyomi Cadena 
* Stata 12
* Comments: Shapley Decomposition for Panama 2007-2011
*-----------------------------------------------------------------------------*
clear
clear matrix
set more off
set mem 500m
set matsize 5000
capture log close

cd "C:\Users\wb343674\Documents\Policy Notes\Panama\Data"

local yearlist "02 03 04 05 06 07 08 09 10 11"

*--------------------------------- Include 2011 --------------------------------*
datalib, country(pan) years(2011) type(base) clear append
rename nper com
destring com, replace force
keep id com p421-p56_g5_a 
sort id com

merge 1:1 id com using EH11
drop _m

foreach i of varlist p56_a p56_b p56_c1 p56_c2 p56_c3 p56_c4 p56_c5 p56_d p56_f1 p56_f2 p56_f3 p56_g1 p56_g2 p56_g3 p56_g4 p56_g5 p56_j p56_k p56_l {
replace `i'=. if `i'>=99998 
}

replace p49=. if p49==99999
replace p49=. if p49==99998

sort id
save EH11, replace

*--------------------------------- Include 2007 --------------------------------*
datalib, country(pan) years(2007) type(base) clear append

sort  prov estra unidad cuest divi_reco hogar nper p1
gen id1 = _n if p1==1
egen aux=group(id1)
sort prov estra unidad cuest divi_reco hogar aux
gen id = aux
replace id = id[_n-1] if id==.
drop id1 aux
label var id "identificación única del hogar"

rename nper com
destring com, replace force

keep id com p421-p57
sort id com

merge 1:1 id com using EH07
drop _m


foreach i of varlist p55a p55b p55c1 p55c2 p55c3 p55c4 p55c5 p55d p55f p55g p55j p55k p55l {
replace `i'=. if `i'>=9999
}

replace p49=. if p49>=99999


sort id
save EH07, replace

*--------------------------------- Include 2008 --------------------------------*
datalib, country(pan) years(2008) type(base) clear append

sort prov dist unidad cuest hogar
egen id_aux=group(prov dist unidad cuest hogar)

destring personas, replace
destring nper, replace

* Indicador de individuos en la encuesta
gen a=1

* Indicador de Hogares en la encuesta
gen b=1 if p1==1

* Indica cuántas veces más se debe repetir el número de hogar en cada id_aux (personas está definido para el jefe)
gen repeat=personas-1

* aux=enumero los hogares en cada id_aux (definido sólo para los jefes de hogar) 
sort id_aux nper fac15_e 
by id_aux: gen aux=sum(b)
replace aux=. if p1!=1

* cc_h identifica el hogar en cada id_aux (para el resto de los individuos distintos del jefe)
by id_aux nper: gen cc_h=sum(a) if aux==.

* Incorporo al jefe de hogar en la variable cc_h
gsort id_aux nper -personas
bysort id_aux nper: replace cc_h=sum(a) if aux!=. & repeat!=0
replace cc_h=99 if cc_h==.
by id_aux: gen prueba=sum(cc_h) if cc_h==99
replace cc_h=999 if cc_h==99 & prueba==198
replace cc_h=9999 if cc_h==99 & prueba==297

* Genero la variable id 
sort id_aux nper fac15_e 
egen id =group(id_aux cc_h)
label var id "identificación única del hogar"

drop id_aux a b repeat aux cc_h prueba 

rename nper com
destring com, replace force

keep id com p421-p55m
sort id com

merge 1:1 id com using EH08
drop _m


foreach i of varlist p55a p55b p55c1 p55c2 p55c3 p55c4 p55c5 p55d p55f p55g p55j p55k p55l {
replace `i'=. if `i'>=9999
}

replace p49=. if p49>=99999


sort id
save EH08, replace

*-----------------------Harmonize variables from EHPM--------------------------*

foreach year in `yearlist'{
use EH`year',clear

*Indigenas
*destring indi_rec, replace


*Nuevo Sector;
gen sector6=.
replace sector6=1 if sector==1
replace sector6=2 if sector==2 | sector==3 
replace sector6=3 if sector==4 
replace sector6=4 if sector==5
replace sector6=5 if sector==6
replace sector6=6 if sector==7 | sector==8 | sector==9
replace sector6=7 if sector==10


label values sector6 sector6bl
label define sector6bl 1"Agriculture" 2"Manufacture" 3"Construction" 4"Retail" 5"Utilities" 6"Services" 7"Domestic Services"


*Labor income - main

if year == 2009 {
	ren p4220 p422
}

if year == 2007| year == 2006 | year == 2005 | year == 2004 |year == 2003 | year == 2002{
	gen p424 = .
}

if year == 2003 {
	ren p371 p421
	ren p372 p423
	ren p373 p422
	ren p44 p49
}

if year == 2002 {
	ren p351 p421
	ren p352 p423
	ren p353 p422
	ren p42 p49
}

replace p421 = . if p421 >= 99998
replace p422 = . if p422 >= 99998
replace p423 = . if p423 >= 99998
replace p424 = . if p424 >= 99998

egen ip_m_orig = rsum(p421 p423)
replace ip_m_orig = . if (p421 == . & p423 == .)

egen ip_orig = rsum(p421 p423 p422 p424)
replace ip_orig = . if (p421 == . & p423 == . & p422 == . & p424 == .)

label var ip_orig  "Labor Income - Main"

*Labor income - secondary

replace p49 = . if p49 >= 99999
gen is_orig = p49 
label var is_orig  "Labor Income - Secondary"

*Total labor income

egen ila_orig=rsum(p421 p422 p423 p49 p424)
replace ila_orig=. if (p421==. & p422==. & p423==. & p49==. & p424 == .)
label var ila_orig "Total Labor Income"


*Capital income 

if year == 2011{
	ren p56_d p55d
}

if year == 2010{
	ren p56d p55d
}
if year == 2005 | year == 2004{
	ren p54c p55d
}

if year == 2003{
	ren p49c p55d
}

if year == 2002{
	ren p47c p55d
}

gen inolab_cap_orig = p55d 
label var inolab_cap_orig "Capital Income"

*Pension
if year == 2011 {
	ren p56_a p55a 
	ren p56_b p55b
	ren p56_c1 p55c1
}

if year == 2010 {
	ren p56a p55a 
	ren p56b p55b
	ren p56c1 p55c1
}
if year == 2005 | year == 2004 {
	ren p54a p55a 
	gen p55b=. 
	gen p55c1=. 
}

if year == 2003 {
	ren p49a p55a 
	gen p55b=. 
	gen p55c1=. 
}

if year == 2002 {
	ren p47a p55a 
	gen p55b=. 
	gen p55c1=. 
}
egen inolab_ju_orig=rsum(p55a p55b p55c1)
replace inolab_ju_orig=. if p55a==. & p55b==. & p55c1==.
label var inolab_ju_orig "Pension"

*Government Transfers

if year == 2011 {
	    ren  p56_c2 p55c2
		ren  p56_c3 p55c3
		ren  p56_c4 p55c4
		ren  p56_c5 p55c5
		ren  p56_g1 p55g1
		ren  p56_g2 p55g2
		ren  p56_g3 p55g3
		ren  p56_j p55j
		ren  p56_k p55k
		
		egen p55f1=rsum(p56_f1 p56_f2), missing
		egen p55g4=rsum(p56_g4 p56_g5), missing		
		}

if year == 2010 {
	    ren  p56c2 p55c2
		ren  p56c3 p55c3
		ren  p56c4 p55c4
		ren  p56c5 p55c5
		ren  p56f1 p55f1
		ren  p56g1 p55g1
		ren  p56g2 p55g2
		ren  p56g3 p55g3
		ren  p56g4 p55g4
		ren  p56j p55j
		ren  p56k p55k
		}

if year == 2006 {
	gen p55f1 = .
	gen p55g4 = .
	rename p55j p55l
	gen p55j=.
	ren p55f p55f2
	replace p55k=. if p55k~=. 
	}

if year == 2005 | year == 2004 {
    ren p54b1 p55c2
    ren p54b2 p55c3
	ren p54b3 p55c4
	ren p54b4 p55c5
	ren p54e  p55f1
	ren p54h  p55l
	
	    foreach var in p55g1 p55g2 p55g3 p55g4 p55j p55k p55f2{
		gen `var' = .
		}
}

if year == 2003 {
    ren p49b p55c2
    ren p49e p55c3
	ren p49h  p55l
	
	    foreach var in p55g1 p55g2 p55g3 p55g4 p55j p55k p55f2 p55c4 p55c5 p55f1{
		gen `var' = .
		}
}

if year == 2002 {
    ren p47b p55c2
    ren p47e p55c3
	ren p47h  p55l
	
	    foreach var in p55g1 p55g2 p55g3 p55g4 p55j p55k p55f2 p55c4 p55c5 p55f1{
		gen `var' = .
		}
}



if year == 2007 | year == 2008{
    ren p55g  p55g1
	ren p55f  p55f2
	
	    foreach var in p55f1 p55g2 p55g3 p55g4{
		gen `var' = .
		}
}


if year == 2011 {
	    ren p56_f3 p55f2
		ren p56_l p55l 
}


if year == 2010 {
	    ren p56f2 p55f2
		ren p56l p55l 
}
	
egen inolab_gov_orig=rsum(p55f1 p55g1 p55g2 p55g3 p55g4 p55j p55k)
replace inolab_gov_orig=. if (p55f1==. & p55g1==. & p55g2==. & p55g3==. & p55g4==. & p55j==. & p55k==.)
label var inolab_gov_orig "Government Transfers"

egen inolab_tran_orig=rsum(p55c2 p55c3 p55c4 p55c5 p55f2)
replace inolab_tran_orig=. if (p55c2==. & p55c3==. & p55c4==. & p55c5==. & p55f2==.)
label var inolab_tran_orig "Private Transfers"

*Others non-labor income
	
egen inolab_otr_orig=rsum(p55l)
replace inolab_otr_orig=. if p55l==. 
label var inolab_otr_orig "Others"

*Total non-labor

egen inola_orig = rsum(inolab_ju_orig inolab_cap_orig inolab_gov_orig inolab_tran_orig inolab_otr_orig ), missing
label var inola_orig "Non-labor Income"

*Total income

egen ii_orig=rsum(ila_orig inola_orig)
replace ii_orig = . if ila_orig == . & inola_orig == . 
label var ii_orig "Individual Total Income"

*Ingreso total Familiar
gen renta_imp_orig=renta_imp if urban==1
replace renta_imp_orig=renta_imp/1.15 if urban==0

egen itf_sin_ri_orig=sum(ii_orig) if hogarsec==0, by(id)
egen itf_orig=rsum(itf_sin_ri_orig renta_imp_orig)
replace itf_orig=. if itf_sin_ri_orig==. & renta_imp_orig==.

*Ingreso total Familiar per capital
gen ipcf_aux=itf_orig/miembros

*Variables por familia per capita
foreach fuente in ila inolab_cap inolab_ju inolab_gov inolab_tran inolab_otr inola{
egen `fuente'_hh=total(`fuente'_orig) if hogarsec==0, by(id)
gen `fuente'_pc=`fuente'_hh/miembros
}

gen renta_pc=renta_imp_orig/miembros

keep id year urbano pondera ipc ipcf_orig ipcf_aux ila_pc inola_pc inolab_cap_pc inolab_ju_pc inolab_gov_pc inolab_tran_pc inolab_otr_pc renta_pc itf_sin_ri_orig itf_orig itf lp_extrema_mef lp_moderada_mef ipcf_orig sector6 ocupado edad miembros ila_orig
order id year urbano pondera ipc ipcf_orig ipcf_aux ila_pc inola_pc inolab_cap_pc inolab_ju_pc inolab_gov_pc inolab_tran_pc inolab_otr_pc renta_pc itf_sin_ri_orig itf_orig itf lp_extrema_mef lp_moderada_mef ipcf_orig sector6 ocupado edad miembros ila_orig

save pan_`year', replace

}
*--------------------------Create one Dataset----------------------------------*
use pan_02, clear
foreach year in 03 04 05 06 07 08 09 10 11{
append using pan_`year'
} 

drop if ipcf_aux==.

*foreach year in `yearlist'{
*erase pan_`year'.dta
*}
*--------------------------Income Official Income------------------------------------------*

egen ipcf_off=rsum(ila_pc inolab_ju_pc inolab_cap_pc inolab_gov_pc inolab_tran_pc inolab_otr_pc), missing

save pan_ingreso_oficial@2, replace
