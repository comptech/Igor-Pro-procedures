#pragma rtGlobals=1		// Use modern global access method.

Function yfunc(energy,intensity,T)
	variable energy, intensity
	variable T // T, K
	variable y,result
	Variable kt
	kt = 8.617343e-2*T // meV
	//kt = T
	y = energy/kt
	result = y^2 * exp(y)/(exp(y)-1)^2 * intensity * 0.41357
	//result = intensity * 0.41357
	return result
End

Function SpecificHeatCapacity(energy, intensity, T)
	wave energy, intensity
	variable T
	variable temp2 = 0, tempp
	variable Cv, i
	
	for (i =0; i < numpnts(energy); i +=1)
		tempp = yfunc(energy[i], intensity[i],T)*3*8.3144 	//Unit: J/mole/K 
		temp2 += tempp
	endfor
	Cv = temp2
	return Cv
End