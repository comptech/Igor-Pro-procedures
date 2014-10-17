#pragma rtGlobals=1		// Use modern global access method.
Function Am_ccmole(A, Z)
	// convert Am to cc/mole
	// Z - Z number
	// A - unit: A^3
	// ccmole - unit: cm^3/mole
	Variable A, Z
	Variable ccmole
	
	ccmole = A*0.60221415/Z
	return ccmole
End

Function ccmole_A(ccmole, Z)
	// convert Am to cc/mole
	// Z - Z number
	// A - unit: A^3
	// ccmole - unit: cm^3/mole
	Variable ccmole, Z
	Variable A
	
	A = ccmole * Z / 0.60221415
	return A
End