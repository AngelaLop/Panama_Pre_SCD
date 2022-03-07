/* 	=======================================================================================
	Project:            PAN Poverty and Inequality Indicators: Master Do
	Author:             By Kiyomi Cadena
	Organization:       The World Bank-ELCPV
	---------------------------------------------------------------------------------------
	Creation Date:       December  21, 2021 
	Modification Date:   
	Output:             
	======================================================================================= */

/* 	=========================================================================================
									  0: Program set up                                      
=========================================================================================== */

cap restore 
clear all                   

* Directory Paths
global proj   "C:\Users\wb343674\WBG\Javier Romero - Panama\Pre-SCD"
global do     "${proj}\03 do"
global out    "${proj}\04 results"

/* 	=========================================================================================
									 1: Running Do-files                                     
=========================================================================================== */

*include "${do}/01_Poverty_Indicators.do"    

include "${do}/01a_Poverty_Indicators_Provincia.do"     

*include "${do}/02_Inequality_Indicators.do" 

*include "${do}/03_Bottom_40.do" 

*include "${do}/03a_Bottom_40_Provincia.do"

*include "${do}/04_GIC_SEDLAC.do" 

exit
/* End of do-file */
*><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><