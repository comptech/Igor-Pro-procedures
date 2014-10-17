#pragma rtGlobals=1	// Use modern global access method.

Function DebyeT(DebyeT0, gamma0, gammap, q)
// Calculate Debye T
	Variable DebyeT0, gamma0, gammap, q
	Variable DebyeT
	
	DebyeT = DebyeT0*exp((gamma0 - gammap)/q)
	
	return DebyeT
End

Function GammaP(gamma0, q, VRatio)
	// Calculate GammaP
	// VRatio = V / V0
	Variable gamma0, VRatio, q
	Variable gammap
	
	gammap = gamma0*VRatio^q
	
	return gammap
End

Function EThermalIntegral(up)
	//up in integral upper limit
	Variable up
	Variable npnts = 1000, temp = 0, x = 0 // numerically integrate, devide x by 1000
	Variable EIntegral
	
	Do
		x=x+1
		temp += up/npnts*(x*up/npnts)^3/(exp(x*up/npnts)-1)
	While (x<=npnts)
	
	EIntegral = temp
	
	return EIntegral
End

Function PThermal(DebyeT0, gamma0, q, n, T, VRatio, V0)
	//Calculate E_thermal - E_0
	Variable DebyeT0, gamma0, q, n, T, VRatio, V0 // V0 -cm3/mol, n-number of atoms in formula unit, VRatio = V/V0, 
	Variable R = 0.00831447 //cm^3 GPa/K/mole
	Variable PThermal // GPa

	Variable DE
	Variable ET, E0, DebyeTT, gammapp
	gammapp = GammaP(gamma0, q, VRatio)
	DebyeTT = DebyeT(DebyeT0, gamma0, gammapp, q)
	ET = 9*n*R*T/(DebyeTT/T)^3*EThermalIntegral(DebyeTT/T)
	E0 = 9*n*R*300/(DebyeTT/300)^3*EThermalIntegral(DebyeTT/300)
	
	PThermal = gammapp / (V0 * VRatio) * (ET-E0)
	
	return PThermal // GPa
End

Function P_MGD(B0, B0p, V0, gamma0, q, theta0, n, pressure, temperature)
	Variable B0, B0p, V0, theta0, gamma0, q, n, pressure, temperature
	Variable P_HT
	
	Variable VRatio // V/V0
	VRatio =  CalcEOSVolume(B0, B0p, V0, pressure)/V0
	//print "V/V0 = " + num2str(VRatio)
	
	P_HT = pressure + PThermal(theta0, gamma0, q, n, temperature, VRatio, V0)
	//print "P_HT = " + num2str(P_HT)
	
	return P_HT
End
	
//Function Am_ccmole(A, Z)
	// convert Am to cc/mole
	// Z - Z number
	// A - unit: A^3
	// ccmole - unit: cm^3/mole
	//Variable A, Z
	//Variable ccmole
	
	//ccmole = A*0.60221415/Z
	//return ccmole
//End

Function CalcMGDVolume(B0, B0p, V0, gamma0, q, theta0, n, pressure, temperature)
	// input: pressure , temperature
	// output: volume in cm^3/mole
	Variable B0, B0p, V0, theta0, gamma0, q, n, pressure, temperature
	Variable VRatio
	Variable V   // unit: cm^3/mole
	
	Variable tol = 1e-9, nmax = 1e4, i=1
	Variable pressure_try

	VRatio =  (1 + pressure*B0p/B0)^(-1/B0p)
	//print "V/V0 = " + num2str(VRatio)	
	Do
		pressure_try = BMEquationOfState(B0, B0p, 1/VRatio) + PThermal(theta0, gamma0, q, n, temperature, VRatio, V0)
		VRatio += (pressure_try-pressure)/(B0 + B0p*pressure)*VRatio
		i += 1
		if (i==nmax)
			VRatio = 0
		endif
	While ((n<nmax) && (cabs(pressure_try - pressure) > tol))
	V = V0 * VRatio
	//print V
	return V	
End