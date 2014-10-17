#pragma rtGlobals=1		// Use modern global access method.

Function FitTwoGauss()

	string current_folder, fitting_folder
	current_folder = GetDataFolder(1)
	fitting_folder = "root:GaussFits"
	if (DataFolderExists(fitting_folder)==1)
		SetDataFolder fitting_folder
	Else
		NewDataFolder/S $(fitting_folder)
	endif

	Prepare_XY_Data_for_Fit(current_folder)	
	Wave ywave, xwave // These are established by the Prepare_XY_Data_for_Fit function
	TwoGauss_AutoInitialValues(ywave, xwave)
	Wave W_coef, W_sigma
	FuncFit/Q/N/M=0 DblGauss W_coef  ywave[pcsr(A),pcsr(B)] /X=xwave
	MakeTwoGaussPeaks(W_coef)
	AppendGaussPeaks()
	Print "Peak 1 Position: " + num2str(W_coef[3]) + " ± " + num2str(W_sigma[3])
	Print "Peak 2 Position: " + num2str(W_coef[4]) + " ± " + num2str(W_sigma[4])
	Print "Complete fitting parameters can be found in " + GetWavesDataFolder(W_coef, 2) + " and " + NameofWave(W_sigma)
	Print "Coefficients ordered as follows: Baseline; Amp_P1; Amp_P2; Pos_P1; Pos_P2; Width_P1; Width_P2"
	Print "Note: each new fit overwrites previous results"
	
	Killwaves ywave, xwave
	
	SetDataFolder current_folder

End


Function DblGauss(w,x) : FitFunc // The Fit Function that Igor will use for two Gaussians
	Wave w
	Variable x
	return w[0]+w[1]*exp(-1*((x-w[3])/w[5])^2) + w[2]*exp(-1*((x-w[4])/w[6])^2)
End	


Function Prepare_XY_Data_for_Fit(current_folder)
// This makes the fitting work for either X-Y or waveform data without user input
	String current_folder
	If (cmpstr(NameofWave(CsrWaveRef(A)),NameofWave(CsrWaveRef(B))) != 0)
		SetDataFolder current_folder
		Abort "Error: Are BOTH cursors on the SAME trace?"
	EndIf

	Wave ydata = CsrWaveRef(A)
	Wave xdata = CsrxWaveRef(A)
	
	Duplicate/O ydata xwave,ywave
	
	If (cmpstr(NameofWave(ydata),"")==0)
		SetDataFolder current_folder
		Abort "Error: Are BOTH cursors on the SAME trace?"
	EndIf
	
	If (cmpstr(NameofWave(xdata),"") ==0)
		Print "Fitting to Waveform Data: " + NameofWave(ydata)
		xwave = x
	Else
		Print "Fitting to X-Y Data: " + NameofWave(ydata) + " vs " + NameofWave(xdata)
		xwave  = xdata
	EndIf
End

Function TwoGauss_AutoInitialValues(ywave,xwave) // Funciton to estimate initial Gauss parameters
	// These are crude estimates.
	Wave ywave, xwave
	Make /O/N=7 W_coef, W_sigma
	Variable A_Cursor_x = xcsr(A)
	Variable B_Cursor_x = xcsr(B)
	Variable A_Cursor_y = vcsr(A)
	Variable B_Cursor_y = vcsr(B)
	Variable Low_Cursor_x = min(A_Cursor_x, B_Cursor_x)
	Variable High_Cursor_x = max(A_Cursor_x, B_Cursor_x)
	Variable Average_Cursor_x = (A_Cursor_x + B_Cursor_x) / 2
	Wavestats /Q/R = (Low_Cursor_x, High_Cursor_x) ywave 
	Variable i_Amplitude = V_max // use maximum y-value between the two cursors
	Variable i_Pos1 = (Low_Cursor_x + Average_Cursor_x) / 2 
	Variable i_Pos2 = (High_Cursor_x + Average_Cursor_x) / 2
	Variable i_Baseline = (A_Cursor_y + B_Cursor_y)/2
	Variable i_Width = (High_Cursor_x - Low_Cursor_x) / 7 // Pulled out  of ass... 
	W_coef  = {i_Baseline,i_Amplitude,i_Amplitude,i_Pos1,i_Pos2,i_Width,i_Width}
	// Initial values assume same amplitudes and widths for both peaks
End

Function MakeTwoGaussPeaks(w)
	Wave w
	Make/O Peak1,Peak2,BothPeaks
	Variable A_Cursor_x = xcsr(A)
	Variable B_Cursor_x = xcsr(B)
	Variable Low_Cursor_x = min(A_Cursor_x, B_Cursor_x)
	Variable High_Cursor_x = max(A_Cursor_x, B_Cursor_x)
	SetScale/I x Low_Cursor_x,High_Cursor_x,"", Peak1,Peak2,BothPeaks
	Variable Offset = Imag(GetWaveOffset(CsrWaveRef(A)))
	Peak1 = w[0] + w[1]*exp(-1*((x-w[3])/w[5])^2) + Offset
	Peak2 = w[0] + w[2]*exp(-1*((x-w[4])/w[6])^2) + Offset
	BothPeaks = w[0]+w[1]*exp(-1*((x-w[3])/w[5])^2) + w[2]*exp(-1*((x-w[4])/w[6])^2) + Offset
End

Function AppendGaussPeaks()
	Wave w // w is the coefficient wave
	RemoveFromGraph/Z Peak1, Peak2, BothPeaks
	AppendToGraph Peak1, Peak2, BothPeaks
	ModifyGraph lstyle(Peak1)=1,rgb(Peak1)=(0,0,0),lstyle(Peak2)=1
	ModifyGraph rgb(Peak2)=(0,0,0)
	ModifyGraph lstyle(BothPeaks)=1,lsize(BothPeaks)=2;DelayUpdate
	ModifyGraph rgb(BothPeaks)=(0,0,0)
End

Function/C GetWaveOffset(w)  // From Igor Mailing List... this is necessary for 
// stacked waves so the plotted peaks line up appropriately
	Wave w
	String s= TraceInfo("",NameOfWave (w),0)
	if( strlen(s) == 0 )
		return NaN
	endif
	String subs= "offset(x)={"
	Variable v1= StrSearch(s,subs,0)
	if( v1 == -1 )
		return NaN
	endif
	v1 += strlen(subs)
	Variable xoff= str2num(s[v1,1e6])
	v1= StrSearch(s,",",v1)
	Variable yoff= str2num(s[v1+1,1e6])
	return cmplx(xoff,yoff)
end