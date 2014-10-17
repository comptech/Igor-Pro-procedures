#pragma rtGlobals=1		// Use modern global access method.

Function FitTwoGauss()
	Make/O Peak1,Peak2,BothPeaks
	Wave/z ywave=CsrWaveRef(A)
	Wave/z xwave=CsrXWaveRef(A)
	Make /O/N=7 W_coef, W_sigma
	Variable CsrAvg = (xwave[pcsr(A)] + xwave[pcsr(B)]) / 2
	Variable Initial_x1 = (xwave[pcsr(A)] + CsrAvg) / 2
	Variable Initial_x2 = (xwave[pcsr(B)] + CsrAvg) / 2
	Variable Initial_Baseline = (ywave[pcsr(A)] + ywave[pcsr(B)])/2
	Wavestats /Q/R = (min(xcsr(A),xcsr(B)), max(xcsr(A),xcsr(B))) ywave 
	Variable Initial_Amplitude = V_max
	Variable Initial_Width = (max(xwave[pcsr(A)],xwave[pcsr(B)]) - min(xwave[pcsr(A)],xwave[pcsr(B)])) / 7 // Pulled out  of ass.
	W_coef  = {Initial_Baseline,Initial_Amplitude,Initial_Amplitude,Initial_x1,Initial_x2,Initial_Width,Initial_Width}
	FuncFit/Q/N/M=0 DblGauss W_coef  ywave[pcsr(A),pcsr(B)] /X=xwave
	//LRGw = max(W_coef[3], W_coef[4])
	TwoGaussPlot(ywave, xwave, W_coef)
	Print "Peak 1 Position: " + num2str(W_coef[3]) + " ± " + num2str(W_sigma[3])
	Print "Peak 2 Position: " + num2str(W_coef[4]) + " ± " + num2str(W_sigma[4])
	//Killwaves W_coef, W_sigma
End

Function TwoGaussPlot(ywave, xwave,w)
	Wave ywave, xwave, w // w is the coefficient wave
	Wave Peak1 = Peak1
	Wave Peak2 = Peak2
	Wave BothPeaks = BothPeaks
	SetScale/I x min(xwave[pcsr(A)],xwave[pcsr(B)]),max(xwave[pcsr(A)],xwave[pcsr(B)]),"", Peak1,Peak2,BothPeaks
	Variable Offset = Imag(GetWaveOffset(ywave))
	Peak1 = w[0]+w[1]*exp(-1*((x-w[3])/w[5])^2) + Offset
	Peak2 = w[0] + w[2]*exp(-1*((x-w[4])/w[6])^2) + Offset
	BothPeaks = w[0]+w[1]*exp(-1*((x-w[3])/w[5])^2) + w[2]*exp(-1*((x-w[4])/w[6])^2) + Offset
	RemoveFromGraph/Z Peak1, Peak2, BothPeaks
	AppendToGraph Peak1, Peak2, BothPeaks
	ModifyGraph lstyle(Peak1)=1,rgb(Peak1)=(0,0,0),lstyle(Peak2)=1
	ModifyGraph rgb(Peak2)=(0,0,0)
	ModifyGraph lstyle(BothPeaks)=1,lsize(BothPeaks)=2;DelayUpdate
	ModifyGraph rgb(BothPeaks)=(0,0,0)
End

Function DblGauss(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = B0+A1*exp(-1*((x-x1)/w1)^2) + A2*exp(-1*((x-x2)/w2)^2)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 7
	//CurveFitDialog/ w[0] = B0
	//CurveFitDialog/ w[1] = A1
	//CurveFitDialog/ w[2] = A2
	//CurveFitDialog/ w[3] = x1
	//CurveFitDialog/ w[4] = x2
	//CurveFitDialog/ w[5] = w1
	//CurveFitDialog/ w[6] = w2

	return w[0]+w[1]*exp(-1*((x-w[3])/w[5])^2) + w[2]*exp(-1*((x-w[4])/w[6])^2)
End	

Function/C GetWaveOffset(w)  // From Igor Mailing List
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