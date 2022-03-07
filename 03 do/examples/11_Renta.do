
tempname pob 
tempfile aux  
postfile `pob' str45(Area Ano Valor) using `aux', replace

foreach n of numlist 2001/2019 {
	datalib, count(hnd) year(`n') mod(all) clear 
	keep if jefe==1 
	gen share_renta = (renta_imp/itf)*100
	
	*** AVG share of  imputed rent/total housheold income 
	su share_renta [w=pondera]
	post `pob' ("All") ("`n'") ("`r(mean)'")
	
	su share_renta if urbano==1 [w=pondera]
	post `pob' ("Urban") ("`n'") ("`r(mean)'")
	
	su share_renta if urbano==0 [w=pondera]
	post `pob' ("Rural") ("`n'") ("`r(mean)'")
	
	collapse (sum) itf renta_imp [pw=pondera], by(urbano)
	gen share_renta = (renta_imp/itf)*100
	gen ano = `n'
	tempfile temp`n'
	save `temp`n'', replace 
}

foreach n of numlist 2001/2018 {
	append using `temp`n''
}

su share_renta //11.8 %
su share_renta if inrange(ano,2011,2019) // 11.9 %

su share_renta if inrange(ano,2011,2019) & urbano==1 // 11.9 %
su share_renta if inrange(ano,2011,2019) & urbano==0 // 11.9 %

postclose `pob'
use `aux', clear
destring, replace 

*** AVG share of  imputed rent/total housheold income 
su Valor //15.8%
su Valor if inrange(Ano,2011,2019) //17.2%

su Valor if inrange(Ano,2011,2019) & Area=="Urban" //17.2%
su Valor if inrange(Ano,2011,2019) & Area=="Rural" //17.2%