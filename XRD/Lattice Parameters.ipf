#pragma rtGlobals=1		// Use modern global access method.
//		Add the Lattice_Parameters macro to the Macros menu
Menu "Macros"
	"Lattice_Parameters/6"
End

//		The Lattice_Parameters macro: collect user input and call the function that calls the fits

Macro Lattice_Parameters(h, dsp,k,s_dsp,l,XLSystem)
	String h, k, l, dsp, s_dsp
	Variable XLSystem
	Prompt XLSystem, "Crystal System: ", popup, "Cubic; Hexagonal; Tetragonal; Orthorhombic;Monoclinic"
	Prompt dsp,"Input dsp-Wave",popup,WaveList("*",";","")
	Prompt s_dsp,"Input sigma-Wave for dsp-Wave",popup, "_none_;" + WaveList("*",";","")
	Prompt h,"Input h-Wave",popup,WaveList("*",";","")
	Prompt k,"Input k-Wave",popup,WaveList("*",";","")
	Prompt l,"Input l-Wave",popup,WaveList("*",";","")
	System_Fit($dsp,$s_dsp,$h,$k,$l,XLSystem)
End

//		This function just calls the Igor curve fits.  All it does is make the y-data (1/dsp^2),
//		and display the results in terms of  the lattice parameters
Function System_Fit(dsp,s_dsp,h,k,l,XLSystem)
	Wave dsp,s_dsp,h,k,l
	Variable XLSystem
	Variable a_init = 5, b_init = 5, c_init = 5, beta_init = 90
	Variable a, s_a, b, s_b, c, s_c, beta = 90, s_beta = 0, V, s_V
	variable t1,t2,t3,t4

	Make/D/N=(numpnts(dsp))/O ydata = 1/dsp^2
	//	If the user selected "_none_" as the s_dsp wave then the weights should all be set
	//	to 1.  I did this in what is probably an awkward way: if  s_dsp was not matched up with
	//	a wave it will still be text, and not the same size as the dsp wave....there must be a 
	// better way to do this!!

	if (numpnts(s_dsp) == numpnts(dsp))
		Make/D/N=(numpnts(dsp))/O s_ydata = 2 * dsp^-3 * s_dsp
	else
		Make/D/N=(numpnts(dsp))/O s_ydata = 1
	endif

	Make/D/O W_sigma

	if (XLSystem == 1) 		// Cubic System
		Make/D/O W_coef = {a_init}
		FuncFit/Q Cubic W_coef ydata /X={h,k,l} /W=s_ydata /I=1 /D
		a = W_coef[0]
		s_a = W_sigma[0] * sqrt(V_Chisq/(V_npnts-V_nterms))
		V = a^3
		s_V = 3 * a^2 * s_a

	elseif (XLSystem == 2)	// Hexagonal System
		Make/D/O W_coef = {a_init, c_init}
		FuncFit/Q Hexagonal W_coef ydata /X={h,k,l} /W=s_ydata /I=1 /D
		a = W_coef[0]
		s_a = W_sigma[0] * sqrt(V_Chisq/(V_npnts-V_nterms))
		c = W_coef[1]
		s_c = W_sigma[1] * sqrt(V_Chisq/(V_npnts-V_nterms))
		V = (sqrt(3)/2) * a^2 * c
		s_V = (((sqrt(3)/2) * 2*a*c*s_a)^2 + ( (sqrt(3)/2) * a^2*s_c)^2)^(1/2)

	elseif (XLSystem == 3)  // Tetragonal System
		Make/D/O W_coef = {a_init, c_init}
		FuncFit/Q Tetragonal W_coef ydata /X={h,k,l} /W=s_ydata /I=1 /D
		a = W_coef[0]
		s_a = W_sigma[0] * sqrt(V_Chisq/(V_npnts-V_nterms))
		c = W_coef[1]
		s_c = W_sigma[1] * sqrt(V_Chisq/(V_npnts-V_nterms))
		V = a^2 * c
		s_V = ((2*a*c*s_a)^2 + (a^2*s_c)^2)^(1/2)
	elseif (XLSystem == 4)	// Orthorhombic System
		Make/D/O W_coef = {a_init, b_init, c_init}
		FuncFit/Q Orthorhombic W_coef ydata /X={h,k,l} /W=s_ydata /I=1 /D
		a = W_coef[0]
		s_a = W_sigma[0] * sqrt(V_Chisq/(V_npnts-V_nterms))
		b = W_coef[1]
		s_b = W_sigma[1] * sqrt(V_Chisq/(V_npnts-V_nterms))
		c = W_coef[2]
		s_c = W_sigma[2] * sqrt(V_Chisq/(V_npnts-V_nterms))
		V = a * b * c
		s_V = ((b*c*s_a)^2 + (a*c*s_b)^2 + (a*b*s_c)^2)^(1/2)
		
	elseif(XLSystem == 5) // Monoclinic System
		Make/D/O W_coef = {a_init, b_init, c_init, beta_init}
		FuncFit/Q Monoclinic W_Coef ydata /X={h,k,l} /W=s_ydata /I=1 /D
		a = W_coef[0]
		s_a = W_sigma[0] * sqrt(V_Chisq/(V_npnts-V_nterms))
		b = W_coef[1]
		s_b = W_sigma[1] * sqrt(V_Chisq/(V_npnts-V_nterms))
		c = W_coef[2]
		s_c = W_sigma[2] * sqrt(V_Chisq/(V_npnts-V_nterms))
		beta = W_coef[3]

		s_beta = W_sigma[3] * sqrt(V_Chisq/(V_npnts-V_nterms))
		V = a * b * c * sin(beta * Pi/180)
		t1 = b*c*sin(beta * Pi/180)*s_a
		t2 = a*c*sin(beta * Pi/180)*s_b
		t3 = a*b*sin(beta * Pi/180)*s_c
		t4 = a*b*c*cos(beta * Pi/180)*(Pi/180)*s_beta
		s_V = (t1^2 + t2^2 + t3^2 + t4^2)^(1/2)

	endif

		Print "a =" , a, "±",s_a, "Å"
		Print "b =" , b, "±",s_b, "Å"
		Print "c =" , c, "±",s_c, "Å"
		Print "Beta =", beta, "±",s_beta, "°"
		Print "V =", V, "±", s_V, "Å^3"
		
		make/D/O params = {a,s_a,b,s_b,c,s_c,beta,s_beta,V,s_V}
//		Cleanup
killwaves ydata, s_ydata, W_sigma, W_coef, fit_ydata//, W_ParamConfidenceInterval

make/D/O params = {a,s_a,b,s_b,c,s_c,beta,s_beta,V,s_V}

End

// 		These are the curvefitting routines.  I made these just by using the curve fit 
//		dialog from the analysis menu, and pasting the results here.  I deleted some
//		comment statements that Igor inserted.

Function Cubic(w,h,k,l) : FitFunc
	Wave w
	Variable h
	Variable k
	Variable l
	return (h^2+k^2+l^2)/w[0]^2
End

Function Hexagonal(w,h,k,l) : FitFunc
	Wave w
	Variable h
	Variable k
	Variable l
	return (4/3) * (h^2 + h*k + k^2) / w[0]^2 + l^2 / w[1]^2
End

Function Tetragonal(w,h,k,l) : FitFunc
	Wave w
	Variable h
	Variable k
	Variable l
	return (h^2 + k^2) / w[0]^2 + l^2/w[1]^2
End

Function Orthorhombic(w,h,k,l) : FitFunc
	Wave w
	Variable h
	Variable k
	Variable l

	return h^2/w[0]^2  + k^2/w[1]^2 + l^2/w[2]^2
End

Function Monoclinic(w,h,k,l) : FitFunc
	Wave w
	Variable h
	Variable k
	Variable l

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(h,k,l) = (1/(sin(Pi*beta/180))^2)*(h^2/a^2 + k^2*(sin(Pi*beta/180))^2/b^2 + l^2/c^2 - 2*h*l*cos(Pi*beta/180)/(a*c))
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 3
	//CurveFitDialog/ h
	//CurveFitDialog/ k
	//CurveFitDialog/ l
	//CurveFitDialog/ Coefficients 4
	//CurveFitDialog/ w[0] = a
	//CurveFitDialog/ w[1] = b
	//CurveFitDialog/ w[2] = c
	//CurveFitDialog/ w[3] = beta

	return (1/(sin(Pi*w[3]/180))^2)*(h^2/w[0]^2 + k^2*(sin(Pi*w[3]/180))^2/w[1]^2 + l^2/w[2]^2 - 2*h*l*cos(Pi*w[3]/180)/(w[0]*w[2]))
End