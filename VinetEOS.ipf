#pragma rtGlobals=1		// Use modern global access method.

Function VinetEquationOfState(B0, B0p, VolumeRatio)
	// Calculate pressure from the Vinet Equation of State
	Variable B0, B0p, VolumeRatio //  =V/V0
	
	Variable Pressure
	Pressure = 3*B0*VolumeRatio^(-2.0/3.0)*(1-VolumeRatio^(1.0/3.0))*exp(1.5*(B0p-1)*(1-VolumeRatio^(1.0/3.0)))
	
	return Pressure
End

Function CalcVinetVolume(B0, B0p, V0, pressure)
	// Calculate Volume from the Birch_Murnaghan Equation of State
	// INPUT:
	//		B0 -> bulk modulus
	//		B0p -> pressure derivative of bulk modulus
	//		density0 -> zero pressure density
	//		pressure -> pressure
	// OUTPUT:
	//		density -> density of the material at pressure = pressure
	Variable B0, B0p, pressure, V0		// B0 = bulk modulus; B0p = pressure derivative of bulk modulus
	
	Variable V, VolumeRatio // densityRatio is rho/rho0; density0 is rho0
	Variable pressure_try, n = 1 // pressure calculated from a trial density ratio
	Variable tol = 1e-9, nmax = 1e4 // tol = tolerance; nmax = max iterations
	
	// Use iteration to calculate the volume ratio or density ratio from the BM EOS
	VolumeRatio =  (1 + pressure*B0p/B0)^(-1/B0p)
	Do
		pressure_try = VinetEquationOfState(B0, B0p, VolumeRatio)
		VolumeRatio += (pressure_try-pressure)/(B0+B0p*pressure)*VolumeRatio
		n +=1
		if (n == nmax)
			VolumeRatio = 0						// Mark the density to be zero, if the iteraction does not converge
		endif
	While ((n<nmax) && (cabs(pressure_try - pressure) > tol))
	
	V =  V0*VolumeRatio
	
	return V
End	