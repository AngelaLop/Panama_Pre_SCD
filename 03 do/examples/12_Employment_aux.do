
datalib, count(hnd) year(2017 2019) mod(all) nocohh clear

bys id ano: egen ipcf_aux = max(yperhg_obs5)
bys id ano: egen ipcf_aux2 = max(yperhg_obs5_alt)

gen ipcf_oficial = ipcf_aux if ano==2017
replace ipcf_oficial = ipcf_aux2 if ano==2019 

apoverty ipcf_oficial [w=pondera], varpl(l_total_nueva) gen(poor)
rename poor1 poor 

su ipc_sedlac if ano==2019 
local ipc_2019 = r(mean)

su ipc_sedlac if ano==2017
local ipc_2017 = r(mean)

gen ila_oficial = ytrab_obs2 if ano==2019 
replace ila_oficial = ytrab_obs2*(`ipc_2019'/`ipc_2017') if ano==2017

apoverty ipcf_oficial [w=pondera], varpl(l_extrema_nueva) gen(poorex)
rename poorex1 poorex

gen sector_3 = sector1d
recode sector_3 (2=1) (3/6=2) (7/17=3) if sector1d!=. 
replace sector_3=. if sector1d==999

label define sector_3 1 "Agriculture" 2 "Industry" 3 "Services", modify
label values sector_3 sector_3

**Empleo por sector 2017-2019 (nacional/urbano/rural)
ta sector_3 ano [w=pondera] if urbano==1 & ocupado==1
ta sector_3 ano [w=pondera] if urbano==1 & ocupado==1 & poorex==1

tabstat ila_oficial if ano==2017 & ocupado==1 & urbano==1  & poorex==1 [w=pondera], by(sector_3)
tabstat ila_oficial if ano==2019 & ocupado==1 & urbano==1  & poorex==1 [w=pondera], by(sector_3)

tabstat ila_oficial if ano==2017 & ocupado==1 & urbano==1 [w=pondera], by(sector_3)
tabstat ila_oficial if ano==2019 & ocupado==1 & urbano==1  [w=pondera], by(sector_3)

**Empleo por sector 2017-2019 (nacional/urbano/rural)
ta sector1d ano [w=pondera] if urbano==1 & ocupado==1
ta sector1d ano [w=pondera] if urbano==1 & ocupado==1 & poorex==1

tabstat ila_oficial if ano==2017 & ocupado==1 & urbano==1  & poorex==1 [w=pondera], by(sector1d)
tabstat ila_oficial if ano==2019 & ocupado==1 & urbano==1  & poorex==1 [w=pondera], by(sector1d)


********
datalib, count(hnd) year(2014 2019) mod(all)  nocohh clear

bys id ano: egen ipcf_aux = max(yperhg_obs5)
bys id ano: egen ipcf_aux2 = max(yperhg_obs5_alt)

gen ipcf_oficial = ipcf_aux if ano==2014
replace ipcf_oficial = ipcf_aux2 if ano==2019 

apoverty ipcf_oficial [w=pondera], varpl(l_total_nueva) gen(poor)
rename poor1 poor 

su ipc_sedlac if ano==2019 
local ipc_2019 = r(mean)

su ipc_sedlac if ano==2014
local ipc_2014 = r(mean)

gen ipcf_oficial_rel = ipcf_oficial if ano==2019 
replace ipcf_oficial_rel = ipcf_oficial*(`ipc_2019'/`ipc_2014') if ano==2014 

apoverty ipcf_oficial [w=pondera], varpl(l_extrema_nueva) gen(poorex)
rename poorex1 poorex

gen ila_oficial = ytrab_obs2 if ano==2019 
replace ila_oficial = ytrab_obs2*(`ipc_2019'/`ipc_2014') if ano==2014 

**Empleo por sector 2014-2019 (nacional/urbano/rural)
ta sector1d ano [w=pondera] if ocupado==1
ta sector1d ano [w=pondera] if urbano==0 & ocupado==1
ta sector1d ano [w=pondera] if urbano==1 & ocupado==1

ta sector1d ano [w=pondera] if ocupado==1 & poor==1
ta sector1d ano [w=pondera] if urbano==0 & ocupado==1 & poor==1
ta sector1d ano [w=pondera] if urbano==1 & ocupado==1 & poor==1

*Average labor income (real)
tabstat ila_oficial if ano==2014 & ocupado==1 [w=pondera], by(sector1d)
tabstat ila_oficial if ano==2019 & ocupado==1 [w=pondera], by(sector1d)

tabstat ila_oficial if ano==2014 & ocupado==1 & urbano==0 [w=pondera], by(sector1d)
tabstat ila_oficial if ano==2019 & ocupado==1 & urbano==0 [w=pondera], by(sector1d)

tabstat ila_oficial if ano==2014 & ocupado==1 & urbano==1 [w=pondera], by(sector1d)
tabstat ila_oficial if ano==2019 & ocupado==1 & urbano==1 [w=pondera], by(sector1d)

*Poor
tabstat ila_oficial if ano==2014 & ocupado==1 & poor==1 [w=pondera], by(sector1d)
tabstat ila_oficial if ano==2019 & ocupado==1 & poor==1 [w=pondera], by(sector1d)

tabstat ila_oficial if ano==2014 & ocupado==1 & urbano==0 & poor==1 [w=pondera], by(sector1d)
tabstat ila_oficial if ano==2019 & ocupado==1 & urbano==0 & poor==1 [w=pondera], by(sector1d)

tabstat ila_oficial if ano==2014 & ocupado==1 & urbano==1 & poor==1 [w=pondera], by(sector1d)
tabstat ila_oficial if ano==2019 & ocupado==1 & urbano==1 & poor==1 [w=pondera], by(sector1d)


gen sector_3 = sector1d
recode sector_3 (2=1) (3/6=2) (7/17=3) if sector1d!=. 
replace sector_3=. if sector1d==999

label define sector_3 1 "Agriculture" 2 "Industry" 3 "Services", modify
label values sector_3 sector_3

*** 3 sectors ***
*Average labor income (real)
tabstat ila_oficial if ano==2014 & ocupado==1 [w=pondera], by(sector_3)
tabstat ila_oficial if ano==2019 & ocupado==1 [w=pondera], by(sector_3)

tabstat ila_oficial if ano==2014 & ocupado==1 & urbano==0 [w=pondera], by(sector_3)
tabstat ila_oficial if ano==2019 & ocupado==1 & urbano==0 [w=pondera], by(sector_3)

tabstat ila_oficial if ano==2014 & ocupado==1 & urbano==1 [w=pondera], by(sector_3)
tabstat ila_oficial if ano==2019 & ocupado==1 & urbano==1 [w=pondera], by(sector_3)

*Poor
tabstat ila_oficial if ano==2014 & ocupado==1 & poor==1 [w=pondera], by(sector_3)
tabstat ila_oficial if ano==2019 & ocupado==1 & poor==1 [w=pondera], by(sector_3)

tabstat ila_oficial if ano==2014 & ocupado==1 & urbano==0 & poor==1 [w=pondera], by(sector_3)
tabstat ila_oficial if ano==2019 & ocupado==1 & urbano==0 & poor==1 [w=pondera], by(sector_3)

tabstat ila_oficial if ano==2014 & ocupado==1 & urbano==1 & poor==1 [w=pondera], by(sector_3)
tabstat ila_oficial if ano==2019 & ocupado==1 & urbano==1 & poor==1 [w=pondera], by(sector_3)

*Average IPCF (real)
tabstat ipcf_oficial_rel if ano==2014 & ocupado==1 [w=pondera], by(sector_3)
tabstat ipcf_oficial_rel if ano==2019 & ocupado==1 [w=pondera], by(sector_3)

tabstat ipcf_oficial_rel if ano==2014 & ocupado==1 & urbano==0 [w=pondera], by(sector_3)
tabstat ipcf_oficial_rel if ano==2019 & ocupado==1 & urbano==0 [w=pondera], by(sector_3)

tabstat ipcf_oficial_rel if ano==2014 & ocupado==1 & urbano==1 [w=pondera], by(sector_3)
tabstat ipcf_oficial_rel if ano==2019 & ocupado==1 & urbano==1 [w=pondera], by(sector_3)

*Poor
tabstat ipcf_oficial_rel if ano==2014 & ocupado==1 & poor==1 [w=pondera], by(sector_3)
tabstat ipcf_oficial_rel if ano==2019 & ocupado==1 & poor==1 [w=pondera], by(sector_3)

tabstat ipcf_oficial_rel if ano==2014 & ocupado==1 & urbano==0 & poor==1 [w=pondera], by(sector_3)
tabstat ipcf_oficial_rel if ano==2019 & ocupado==1 & urbano==0 & poor==1 [w=pondera], by(sector_3)

tabstat ipcf_oficial_rel if ano==2014 & ocupado==1 & urbano==1 & poor==1 [w=pondera], by(sector_3)
tabstat ipcf_oficial_rel if ano==2019 & ocupado==1 & urbano==1 & poor==1 [w=pondera], by(sector_3)


*** Rural extreme poor1
ta sector_3 ano [w=pondera] if urbano==0 & ocupado==1 & poorex==1

tabstat ila_oficial if ano==2014 & ocupado==1 & urbano==0  & poorex==1 [w=pondera], by(sector_3)
tabstat ila_oficial if ano==2019 & ocupado==1 & urbano==0  & poorex==1 [w=pondera], by(sector_3)


** Type of employment and sector by urban/rural 
datalib, count(hnd) year(2019) mod(all) clear


gen sector_3 = sector1d
recode sector_3 (2=1) (3/6=2) (7/17=3) if sector1d!=. 
replace sector_3=. if sector1d==999

label define sector_3 1 "Agriculture" 2 "Industry" 3 "Services", modify
label values sector_3 sector_3
ta relab urbano if ocupado==1 & inrange(edad,15,65) [w=pondera], col nofreq
ta sector_3 urbano if ocupado==1 & inrange(edad,15,65) [w=pondera], col nofreq