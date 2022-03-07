* labels 

 if  "`lfp'"=="pea_1" 	 local indicator "Labor Force Participation"
 if  "`lfp'"=="ocupado_1"  local indicator "Employment rate"
 
 if  "`iml'"=="ocupado_1"  local indicator "Employment (share of lfp)"
 if  "`iml'"=="desocupado_1" local indicator "Unemployment (share of lfp)"
 
 if "`ocupado_ch'"=="d_informal" 		local indicator "Informal Workers"
 if "`ocupado_ch'"=="_i602" 	 		local indicator "Formal Workers" 
 if "`ocupado_ch'"=="informal_size" 	local indicator "Informal Workers SEDLAC"
 if "`ocupado_ch'"=="_i702" 			local indicator "Formal Workers SEDLAC"
 if "`ocupado_ch'"=="informal_labor" 	local indicator "Informal Workers Benefits"
 if "`ocupado_ch'"=="_i802" 			local indicator "Formal Workers Benefits"
 if "`ocupado_ch'"=="informal_sala_self" local indicator "Informal Workers Salaried or Self"
 if "`ocupado_ch'"=="_i902" 			local indicator "Formal Workers Salaried or Self"
 if "`ocupado_ch'"== "formal"			local indicator "Formal Workers (1)"
 if "`ocupado_ch'"== "informal"			local indicator "Inormal Workers (1)"
 if "`ocupado_ch'"== "formal3"			local indicator "Formal Workers (national)"
 if "`ocupado_ch'"== "informal3"		local indicator "Inormal Workers (national)"
 
 
 
 if "`cut'" == "_s1001"  local labels "Agricultural, primary activities" 
 if "`cut'" == "_s1002"  local labels "Low-tech industries" 
 if "`cut'" == "_s1003"  local labels "Rest of manufacturing industry" 
 if "`cut'" == "_s1004"  local labels "Construction" 
 if "`cut'" == "_s1005"  local labels "Retail and wholesale, restaurants, hotels, repairs" 
 if "`cut'" == "_s1006"  local labels "Electricity, gas, water, transport, communications" 
 if "`cut'" == "_s1007"  local labels "Banks, finance, insurance, professional services" 
 if "`cut'" == "_s1008"  local labels "Public administration and defense" 
 if "`cut'" == "_s1009"  local labels "Education, health, personal services" 
 if "`cut'" == "_s1010"  local labels "Domestic service" 
 if "`cut'" == "hombre"  local labels "Hombre" 
 if "`cut'" == "mujer"   local labels "Mujer" 
 if "`cut'" == "total"   local labels "Total" 
 
