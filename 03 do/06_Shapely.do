/* 	=======================================================================================
	Project:            PAN Poverty Indicators
	Author:             By Kiyomi Cadena
	Organization:       The World Bank-ELCPV
	---------------------------------------------------------------------------------------
	Creation Date:       January 30, 2022
	Modification Date:   
	Output:              Shapley_decomp.xls        
	======================================================================================= */
/*==================================================
              0: Program set up
==================================================*/
clear all
set checksum off, permanently 
set matsize 10000

global mainpath  	"C:\Users\wb343674\WBG\Javier Romero - Panama\Pre-SCD"
global dofiles   	"${mainpath}\03 do"
global dtas   		"${mainpath}\02 data"
global excel		"${mainpath}\04 results"

/*==================================================
              1: Load data
==================================================*/


clear
tempfile c
save `c', emptyok

local country "PAN"
local year1	  "2015"
local year2	  "2019"

// Year 1: open, and save in tempfile
		datalibweb, country(`country') year(`year1') type(sedlac-03) mod(all) clear
				
save `c', replace

// Year 2: open, and save in tempfile
		datalibweb, country(`country') year(`year2') type(sedlac-03) mod(all) clear
					
append using `c', force		// append year2
save `c', replace

/*==================================================
              1a: Variables
==================================================*/

	* Poverty Lines
	
		local days "30.42"  
		
		gen lp_190usd_ppp = `days'*1.9 
		gen lp_320usd_ppp = `days'*3.2
		gen lp_550usd_ppp = `days'*5.5
		gen lp_1300usd_ppp = `days'*13
		gen lp_7000usd_ppp = `days'*70
		
		cap	gen factor11=ipc11_sedlac/ipc_sedlac 
		cap	gen factorppp11=factor11/ppp11 

		foreach var in  ipcf ila{
		gen `var'_ppp11=(`var'*factorppp11) 
		}

/*==================================================
              2: Create relevant variables for Shapley
==================================================*/

include "${dofiles}\_aux\vars_shapley.do"

include "${dofiles}\_aux\categories_shapley.do"


/*==================================================
              2: Calculate Shapley
==================================================*/

* Save appended results
preserve
	drop _all
	tempfile c
	save `c', emptyok
restore


*local types "gender incsource"

local types "incsource"
local pls 190 320 550 
*local pls 550


local welfarevars		ipcf_ppp11   
  


local components 		pocup_all 				///
						ila_all_ocup 			///
						dependency 				///
						pc_itranext_ppp11 		///
						pc_itrane_ppp11 		///
						pc_ijubi_ppp11 			///
						pc_otinla_ic

local componentsg       pocup_man 				///
						ila_man_ocup 			///
						pocup_woman 			///
						ila_woman_ocup  		///
						pc_otinla_g  			///
						dependency
						
						
local weight 			pondera
local comp_ind 			year
local equation 			"(c1*c2*c3)+c4+c5+c6+c7"
local equationg			"c6*((c1*c2)+(c3*c4))+c5"
local ind 				"fgt0 fgt1 fgt2 gini"


***Check vars********************************************************************
*gen ipcf_check = (pocup_all*ila_all_ocup*dependency )+ pc_itranext_ppp11 +pc_itrane_ppp11 + pc_ijubi_ppp11 + pc_otinla_ic

*br edad ipcf_ppp11 ipcf_check t_ocup_all t_non_dep pocup_all ila_all_ocup dependency pc_itranext_ppp11 pc_itrane_ppp11 pc_ijubi_ppp11 pc_otinla_ic if ipcf_ppp11!=ipcf_check
********************************************************************************

local national_aux="yes"
local area_aux="yes"
local state_aux="no"



*if ("`national_aux'"=="yes") {

*foreach state of numlist 1/32{
foreach area of numlist 1/2{
foreach type of local types {
	foreach pl of local pls {
		

*********** By gender **********************************************************

	noi di in white "Running - pov line `pl'"
	if strpos("`type'","gender")!=0 {
		noi di in white "Running adecomp by `type', for pov line `pl'"
		noi adecomp `welfarevars' `componentsg' [w=`weight'], by(`comp_ind') ///
		eq(`equationg') varpl(lp_`pl'usd_ppp) in(`ind')
		
		* Matrix
		mat A = r(b)
		preserve // temp
			drop _all
			svmat double A
			
			sum A2
			local max = r(max)
			gen type = 1
			gen pline = `pl'
			append using `c'
			save `c', replace
		restore	
		} // end if gender
		
	
*********** By income source ***************************************************

	if strpos("`type'","incsource")!=0 {
		noi di in white "Running adecomp by `type', for pov line `pl'"
		noi	adecomp `welfarevars' `components' [w=`weight'] if area==`area', by(`comp_ind') ///
		eq(`equation') varpl(lp_`pl'usd_ppp) in(`ind')
		
		*noi	adecomp `welfarevars' `components' [w=`weight'], by(`comp_ind') ///
		*eq(`equation') varpl(lp_`pl'usd_ppp) in(`ind')
			
		* Matrix
		preserve
			mat A = r(b)
			drop _all
			svmat double A
			if strpos("`type'","gender")!=0 {
				replace A2 = A2 + `max' // for distinct value labels of components
			}
			else {
				replace A2 = A2 + 7
			}
			gen type = 2
			gen pline = `pl'
			gen zone = `area'
			*gen zone = 999
			append using `c'
			save `c', replace
		restore
		} // end if income source
	
} // end pls
} // end area loop
} // end types			



drop _all
use `c'


gen country = 1
gen year1 = 2015
gen year2 = 2019

local varlist "country year1 year2 type zone pline A1 A2 A3"

order `varlist'

* Temp matrices not working
* tempname _main_mat_bde
* mkmat `varlist', mat(`main_mat_bde') 
* cap return matrix _main_mat_bde = `main_mat_bde'

local varlist "country year1 year2 type zone pline A1 A2 A3"
mkmat `varlist', mat(main_mat_bde2) 
rename A1 pov_ind
rename A2 component
rename A3 rate
rename zone dzone
rename type dtype
* mat list main_mat_bde2

/*==================================================
              3: Labels Shapley
==================================================*/
/*
gen gender="Other components"
replace gender="Men" 		if inlist(component,1,2)
replace gender="Women" 		if inlist(component,3,4)
*/


gen indicator=""
replace indicator="Share who are employed" if inlist(component,1,3,8)
replace indicator="Labor earnings" if inlist(component,2,4,9)
replace indicator="Other non-labor income" if inlist(component,5,14) 
replace indicator="Share of individuals 15-69 years of age" if inlist(component,6,10)
replace indicator="Total" if inlist(component,7,15)

replace indicator = "Remittances" if component == 11
replace indicator = "Public transfers" if component == 12
replace indicator = "Retirement and pensions" if component == 13

clonevar component_n = component
*clonevar dtype_sp = dtype
local renvars component pov_ind pline

label define pline                           ///
125     "Poverty $1.25 (2005 PPP)"           ///
190     "Poverty $1.9 (2011 PPP)"            ///
320     "Poverty $3.2 (2011 PPP)"            ///
550     "Poverty $5.5 (2011 PPP)"            ///
250     "Poverty $2.5 (2005 PPP)"            ///
400     "Poverty $4 (2005 PPP)"              ///
1000	 "Poverty $10 (2011 PPP)" 			 ///
4001000  "Vulnerable $4-$10 (2005 PPP)"      ///
10005000 "Middle Class $10-$50 (2005 PPP)"   ///
5501300  "Vulnerable $5.5-$13 (2011 PPP)"    ///
13007000 "Middle Class $13-$70 (2011 PPP)", modify

label values pline pline
label var pline "Poverty Status"

		
label define pov_ind 			///
0 "Poverty rate" 				///
1 "Poverty gap"					///
2 "Poverty severity"			///	
3 "Gini", modify			
label values pov_ind pov_ind


label define component  ///
1 "Men employed" ///
2 "Men labor earnings" ///
3 "Women employed" ///
4 "Women labor earnings" ///
5 "Other income" ///
6 "Dependency ratio" ///
7 "Total" ///
8 "Employed individuals" ///
9 "Labor earnings" ///
10 "Dependency ratio" ///
11 "Remittances"	///
12 "Public transfers" ///
13 "Retirement and Pensions" ///
14 "Other non-labor income" ///
15 "Total", modify
label values component component


label define dzone ///
1 "Rural" ///
2 "Urban", modify
label values dzone dzone


export excel using "${excel}\Shapley_decomp.xlsx", sheet("shapley_area") sheetreplace firstrow(variables) cell(A3) 





