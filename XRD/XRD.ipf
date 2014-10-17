#pragma rtGlobals=1		// Use modern global access method.
#include "DiffractionCalc_DataEditor"
#include "DiffractionCalc" 
#include "getHKLfrom1dwave"
#include "DoubleGaussFit"
#include  <Split Axis>
#include  <SaveGraph>
//#include "HS_DblGauss"

Function Henry_Load_Chi()
       string name
       LoadWave/G/A
       name = (S_fileName[0,strlen(S_fileName)-5])
       Rename wave1, $name //wave1 is intensity
       ScaleChi(wave0,$name) //creates evenly spaced x-ray intensity data and scaled two theta values
       Killwaves wave0 //kills two theta because it can be calculated if intensity is used as a waveform
End

Function ScaleChi(x,y)
       wave x, y
       variable startx, endx
        startx = x[0]
        endx = x[numpnts(x)-1]
        SetScale/I x startx, endx, "", y
end

Function Henry_TwoTheta_to_Dsp(wTwoTheta, Wavelength)
// This function takes waveform X-ray intensity data that is evenly spaced
// and scaled for two theta values and produces a new wave in that is waveform
// and evenly spaced and scaled for d-spacing values by interpolation
       Wave wTwoTheta // waveform TwoTheta data (TT values are the scaling)
       Variable Wavelength // in Angstroms!
       String output_wave_name = NameofWave(wTwoTheta)+"_DSP"
       Duplicate/O wTwoTheta $output_wave_name, xdata, ydata
// the xdata and ydata are temporary representations of the waveform data as x-y
       Wave wrDsp = $output_wave_name // wave reference to newly created wave
       xdata = x // the x-data wave is its own scaling values, initially in two theta
       xdata = Wavelength / (2 * sin((xdata/2)*(Pi/180))) // convert the x-data to dspacing
       MakeWaveForm(xdata,ydata,wrDsp)
       Killwaves xdata, ydata
End

Function MakeWaveForm(xdata,ydata,wf)
       Wave xdata,ydata,wf
       SetScale/I x xdata[0], xdata[numpnts(xdata)-1], wf
       wf = interp(x, xdata, ydata)
End

Function SaraNormalize(spectrum)
	Wave spectrum
	WaveStats spectrum
	//Variable V_max
	spectrum = spectrum/V_max*100
End 

Function Sara_Load_Chi()
       string name
       LoadWave/G/A
       SaraNormalize(wave1)
       name = (S_fileName[0,strlen(S_fileName)-5])
       Rename wave1, $name+"_Intensity"
       Rename wave0, $name+"_TwoTheta"
End

Function Make2ThetaWaves(Wavelength)
	Variable Wavelength
	String List = WaveList("*TwoTheta", ";", "")
	Print 'List'
End

//Function Convert_TT_to_Dsp(TT_Wave,Wavelength)
//// this function does not make use of waveforms, it uses Excel type data, ie one set of data for each "x" and "y"
//	Variable Wavelength
//	Wave TT_Wave
//	string output_wave_name
//	string List = WaveList ("*TwoTheta", ";", "")
//	variable i = 0
//	Do
//	output_wave_name = StringFromList (i, List)
//	output_wave_name[(strlen(output_wave_name)-8),(strlen(output_wave_name))] = "Dsp"
//	Print 'output_wave_name'
//	//Duplicate/O/D  TT_Wave $output_wave_name
//	//wave wr_output_wave_name = $output_wave_name
//	//Wavelength = 12.407 / Wavelength // convert from keV to Å
//	// print wavelength
//	//wr_output_wave_name = Wavelength/(2*sin(TT_Wave*Pi/180/2))
//End

Function Convert_TT_to_Dsp(TT_Wave,Wavelength)
// this function does not make use of waveforms, it uses Excel type data, ie one set of data for each "x" and "y"
	Variable Wavelength
	Wave TT_Wave
	string output_wave_name=NameofWave(TT_Wave)
	output_wave_name[(strlen(output_wave_name)-8),(strlen(output_wave_name))] = "Dsp"
	Duplicate/O/D  TT_Wave $output_wave_name
	wave wr_output_wave_name = $output_wave_name
	//Wavelength = 12.407 / Wavelength // convert from keV to Å
	// print wavelength
	wr_output_wave_name = Wavelength/(2*sin(TT_Wave*Pi/180/2))
End

Function AutoOffset(Amount)  // Sequentially offsets all traces on the top graph by "Amount"
Variable Amount
ModifyGraph offset = {0,0}
String ListOfTraces =TraceNameList("",";",1)
Variable NumberOfTraces = itemsinlist(ListOfTraces)
Variable i = 0
Do 
String ithTrace = stringfromlist(i,ListOfTraces)
ModifyGraph offset($ithTrace)={0,Amount*(i)}
i+=1
While (i<NumberOfTraces)
End

Function QuickGaussStore(peakwave,s_peakwave)
	Wave peakwave, s_peakwave
       Wave W_coef, W_sigma
       Variable currentsize = numpnts(peakwave)
       InsertPoints currentsize, 1,  peakwave, s_peakwave
       CurveFit /Q gauss CsrWaveRef(A) (xcsr(A),xcsr(B)) /D
       peakwave[currentsize] = W_coef[2]
       s_peakwave[currentsize] = W_sigma[2]
	GaussLabel()
End

Function QuickGauss()
	Wave peakwave, s_peakwave
       Wave W_coef, W_sigma
       CurveFit /Q gauss CsrWaveRef(A) (xcsr(A),xcsr(B)) /D
       Make/N=1/D/O PeakFit, s_PeakFit
       PeakFit = W_coef[2]
       s_PeakFit = W_sigma[2]
	GaussLabel()
End

Function GaussLabel()
       Wave W_coef, W_sigma
       String Plot2Label = CsrWave(A)
       String tmpString
       sprintf tmpString, "\K(1,3,39321)\Z12%8.6f ± %8.6f", W_coef[2], W_sigma[2]
       Tag/O=90/F=2 $Plot2Label, W_coef[2], tmpString
End

Function ExcelQuickGauss(Intensity, DSP)
   
    Wave Intensity, DSP
    Make/D/O Fit
    Wave peakwave, s_peakwave
       Wave W_coef, W_sigma
       CurveFit /Q gauss Intensity[pcsr(A), pcsr(B)]/X = DSP/D
       Make/N=1/D/O PeakFit, s_PeakFit
       PeakFit = W_coef[2]
       s_PeakFit = W_sigma[2]
    ExcelGaussLabel()
End

Function ExcelGaussLabel()
       Wave W_coef, W_sigma
       String tmpString
       string name = WaveName("",0,1)
       sprintf tmpString, "\K(1,3,39321)\Z12%8.6f ± %8.6f", W_coef[2], W_sigma[2]
       Tag/O=90/F=2 $name, (pcsr(A)+pcsr(B))/2, tmpString
End

Function ExcelQuickGaussStore(peakwave,s_peakwave, Intensity, DSP)
    Wave Intensity, DSP
    Wave peakwave, s_peakwave
       Wave W_coef, W_sigma
       Variable currentsize = numpnts(peakwave)
       InsertPoints currentsize, 1,  peakwave, s_peakwave
       CurveFit /Q gauss Intensity[pcsr(A), pcsr(B)]/X = DSP/D
       peakwave[currentsize] = W_coef[2]
       s_peakwave[currentsize] = W_sigma[2]
       Print W_coef[2], "+/-",W_sigma[2]
    ExcelGaussLabel()
End

Window ZeroPressureHKLs() : Table
	PauseUpdate; Silent 1		// building window...
	Edit/W=(5.25,42.5,533.25,236) '1hkl',h,k,l,HKL_217,HKL_s_217,HKL_216,HKL_s_216,HKL_215
	AppendToTable HKL_s_215,HKL_214,HKL_s_214,HKL_213,HKL_s_213,HKL_212,HKL_s_212,HKL_211
	AppendToTable HKL_s_211,HKL_210,HKL_s_210,HKL_209,HKL_s_209,HKL_95,HKL_s_95,HKL_94
	AppendToTable HKL_s_94,HKL_93,HKL_s_93,HKL_92,HKL_s_92,HKL_91,HKL_s_91,HKL_90,HKL_s_90
	AppendToTable HKL_89,HKL_s_89,HKL_88,HKL_s_88,HKL_85,HKL_s_85,HKL_84,HKL_s_84
EndMacro

#pragma rtGlobals=1		// Use modern global access method.
//		Add the Lattice_Parameters macro to the Macros menu
Menu "Macros"
	"Lattice_Parameters"
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
killwaves ydata, s_ydata, W_sigma, W_coef, fit_ydata, W_ParamConfidenceInterval

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
