#pragma rtGlobals=1		// Use modern global access method.

Function BMEquationOfState(B0, B0p, DensityRatio)
	// Calculate pressure from the Birch-Murnaghan Equation of State
	Variable B0, B0p, DensityRatio // DensityRatio = rho/rho0
	
	Variable Pressure
	
	//Calculate pressure from Birch-Murnaghan Equation of State
	// 	P(V) = 1.5*B0*(DensityRatio^(7.0/3.0)-(DensityRatio(^5.0/3.0))
	//			*(1+0.75*(B0P-4)*(Density^(2/3)-1))
	Pressure = 1.5*B0*(DensityRatio^(7.0/3.0)-DensityRatio^(5.0/3.0))*(1+0.75*(B0p-4)*(DensityRatio^(2.0/3.0)-1))

	return Pressure
End

Function CalcEOSDensity(B0, B0p, density0, pressure)
	// Calculate density from the Birch_Murnaghan Equation of State
	// INPUT:
	//		B0 -> bulk modulus
	//		B0p -> pressure derivative of bulk modulus
	//		density0 -> zero pressure density
	//		pressure -> pressure
	// OUTPUT:
	//		density -> density of the material at pressure = pressure
	Variable B0, B0p, pressure, density0		// B0 = bulk modulus; B0p = pressure derivative of bulk modulus
	
	Variable density, densityRatio // densityRatio is rho/rho0; density0 is rho0
	Variable pressure_try, n = 1 // pressure calculated from a trial density ratio
	Variable tol = 1e-9, nmax = 1e4 // tol = tolerance; nmax = max iterations
	
	// Use iteration to calculate the volume ratio or density ratio from the BM EOS
	densityRatio = (1 + pressure*B0p/B0)^(1/B0p)
	Do
		pressure_try = BMEquationOfState(B0, B0p, densityRatio)
		densityRatio += (pressure - pressure_try)/(B0+B0p*pressure)*densityRatio
		n +=1
		if (n == nmax)
			densityRatio = 0						// Mark the density to be zero, if the iteraction does not converge
		endif
	While ((n<nmax) && (cabs(pressure_try - pressure) > tol))
	
	density = densityRatio * density0
	
	return density
End	

Function CalcEOSVolume(B0, B0p, V0, pressure)
	// Calculate Volume from the Birch_Murnaghan Equation of State
	// INPUT:
	//		B0 -> bulk modulus
	//		B0p -> pressure derivative of bulk modulus
	//		density0 -> zero pressure density
	//		pressure -> pressure
	// OUTPUT:
	//		density -> density of the material at pressure = pressure
	Variable B0, B0p, pressure, V0		// B0 = bulk modulus; B0p = pressure derivative of bulk modulus
	
	Variable V, densityRatio // densityRatio is rho/rho0; density0 is rho0
	Variable pressure_try, n = 1 // pressure calculated from a trial density ratio
	Variable tol = 1e-9, nmax = 1e4 // tol = tolerance; nmax = max iterations
	
	// Use iteration to calculate the volume ratio or density ratio from the BM EOS
	densityRatio = (1 + pressure*B0p/B0)^(1/B0p)
	Do
		pressure_try = BMEquationOfState(B0, B0p, densityRatio)
		densityRatio += (pressure - pressure_try)/(B0+B0p*pressure)*densityRatio
		n +=1
		if (n == nmax)
			densityRatio = 0						// Mark the density to be zero, if the iteraction does not converge
		endif
	While ((n<nmax) && (cabs(pressure_try - pressure) > tol))
	
	V =  V0/densityRatio
	
	return V
End	