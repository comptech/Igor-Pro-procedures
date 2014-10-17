#pragma rtGlobals=1		// Use modern global access method.

Function Tm_Lindeman(Tm0, gamma0, V, V0)
	Variable Tm0, gamma0, V, V0
	Variable ratio
	Variable Tm
	
	ratio = V/V0
	
	Tm = Tm0 * exp(2*gamma0*(1-ratio) + 2/3*log(ratio))
	
	return Tm
End