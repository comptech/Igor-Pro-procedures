#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.01

//version 2.01 adds evaluation of special cases for Unified. 


//This fit uses the function described in 
//  http://www.eng.uc.edu/~gbeaucag/PDFPapers/Beaucage2.pdf
//http://www.eng.uc.edu/~gbeaucag/PDFPapers/Beaucage1.pdf
//http://www.eng.uc.edu/~gbeaucag/PDFPapers/ma970373t.pdf
//
//The basic function is composed of a series of structural levels, each with the possibility to be 
//a) associated with the previous smaller size level (Rcutoff2 = Rg1 in
//	I2highq=B2q^(-p2)exp(-q^2Rg1^2/3) for the power-law region of 2)
//b) to follow mass fractal restrictions (calculate B for the mass fractal power law
//		I = B q^(-p)
//c) to display spherical Corelations as described by I(q) = I(q)/(1+p f(q etai)) where
//		p is a packing factor 8*vH/vO for vH = hard sphere volume and vO is occupied volume
//		and f(q eta) is the sphere amplitude function for spherical Corelations
//
//The intensity from each level is summed and the intensity from one level, i, is given by:
//Ii(q) = Gi exp(-q^2Rgi^2/3) + exp(-q^2Rg(i-1)^2/3)Bi {[erf(q Rgi/sqrt(6))]^3/q}^Pi
//
//This equation includes a) above if Rg(i-1) is the previous smaller Rg e.g. the primary
//		particles from a mass fractal level.
//		If there is no such dependence Rg(i-1) is set to 0 or it could be set to an independent 
//		size under unsual circumstances
//
//This equation can include b) if Bi is calculated using Bi = (G df/Rg^df) GammaFun(df/2) 
//		and the erf argument includes kqRgi/sqrt(6) where k is 1.06.  The latter can be included or
//		 ignored for high dimension mass fractals but becomes more important for dimensions less
//		than 2.
//		
//The equation can include c) by multiplying the entire level Ii(q) by a function that follows the 
//		the Born-Green approximation for Corelations (multiple particle Corelations) and this
//		works well for weak Corelations of any type but becomes more restricted to spherical 
//		Corelations as the Corelations become stronger.  The measure of the strength of the Corelations
//		is the packing factor p = 8 vH/vO as described above and for spherical particles this value
//		 can be 0 (no Corelations) to about 5.6 (calculate for FCC or HCP packing).  If assymetric 
//		particles (rods or sheets) are packing the number can be much higher and the spherical function
//		becomes less appropriate although it can be used in a pinch for weak Corelations.  The 
//		interpretation of p and eta become complicated in these cases.  As a general rule etai has to be
//		larger than Rgi as common sense would dictate.  The correlation function follows closely the
//		development of Fournet in Guinier and Fournet and in Fournet's PhD dissertation where it is 
//		better described but is in French...

//So the Unified needs to accomodate multiple levels each of which can potentially have 8 parameters
//		(including spherical Corelations): Rgi, Gi, Pi, Bi, etai, packi, RgCOi,k
//		where RCOi is usually Rg(i-1), as shown above, for hierarchical structures
//		(k is 1.06 for mass fractals and 1 for others)
//		Each level must also have the answer to at least three questions:
//		Are there Corelations:  qCori
//		Is this a Mass Fractal:  qMFi
//		Does this level terminate at high-q in the next lower level Rg:  qPL (PowerLimit)
//			That is, is this a hierarchical structure build from the previous smaller level.
//			a third option is to let the power law limit float as a free parameter although this is
//			rarely appropriate.
//
//Then we have several options for coding the unified function.
//		a) Write a dedicated code for a specific morphological model where all of the parameters are 
//			defined in terms of the model.  We have done this for corellated lamellae, rods, mass-fractals,
//			spheres, correlated spheres, RPA based polymer blends of arbitrary fractal dimension, polymer
//			gels among others.
//		b)  Write a generic unified code that allows a high degree of flexibility but which is naturally complex.
//
//For cases where you deal with a fairly complex and limited structural model option a) is most appropriate
//		and is easiest to understand.  We can't however write such code for each and every case.  Several of our
//		publications indicate how to go about calculating the unified parameters, for instance for a sheet structure 
//		8 parameters in the unified equation (for 2 levels) reduce to 3 free parameters, the contrast, 
//		thickness and diameter of the sheets.   Similarly rods can be described by 3 parameters the length, diameter 
//		and contrast.  Corelations in both systems add 2 other parameters although the spherical correlation function
//		can not be rigorously used except at extremely weak levels of correlation.
//
//This code deals with approach b) where only spherical correlatoins are dealt with but including an optional
//		mass fractal limitation (strictly limited to linear chains but useful for branched structures in application).
//
//The code begins with a panel to obtain fit parameters for 4 levels (28) and 12 questions.  We have fit wide q-range data
//		with up to 4 levels by combining USALS, SALS, USAXS, SAXS and XRD data.  The function could be extended to an
//		unlimited number of levels theoretically.
//
//List of parameters for each level:

//	 Level1Rg   
//	 Level1FitRg   
//	 Level1RgLowLimit   
//	 Level1RgHighLimit   
//	 Level1G   
//	 Level1FitG   
//	 Level1GLowLimit   
//	 Level1GHighLimit   
//	 Level1RgStep   
//	 Level1GStep   
//	 Level1PStep   
//	 Level1BStep   
//	 Level1EtaStep   
//	 Level1PackStep   
//	 Level1P   
//	 Level1FitP   
//	 Level1PLowLimit   
//	 Level1PHighLimit   
//	 Level1B   
//	 Level1FitB   
//	 Level1BLowLimit   
//	 Level1BHighLimit   
//	 Level1ETA   
//	 Level1FitETA   
//	 Level1ETALowLimit   
//	 Level1ETAHighLimit   
//	 Level1PACK   
//	 Level1FitPACK   
//	 Level1PACKLowLimit   
//	 Level1PACKHighLimit   
//	 Level1RgCO   
//	 Level1LinkRgCO   
//	 Level1FitRgCO   
//	 Level1RgCOLowLimit   
//	 Level1RgCOHighLimit   
//	 Level1K   
//	 Level1Corelations   
//	 Level1MassFractal   
//	 Level1DegreeOfAggreg   
//	 Level1SurfaceToVolRat   
//	 Level1Invariant   
//	 Level1RgError   
//	 Level1GError   
//	 Level1PError   
//	 Level1BError   
//	 Level1ETAError   
//	 Level1PACKError   
//	 Level1RGCOError



Function IR1A_UnifiedCalculateIntensity()

	setDataFolder root:Packages:Irena_UnifFit

	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels
	NVAR UseSMRData=root:Packages:Irena_UnifFit:UseSMRData
	NVAR SlitLengthUnif=root:Packages:Irena_UnifFit:SlitLengthUnif
	Wave OriginalIntensity
	Duplicate/O OriginalIntensity, UnifiedFitIntensity, UnifiedIQ4
	Redimension/D UnifiedFitIntensity, UnifiedIQ4
	Wave OriginalQvector
	Duplicate/O OriginalQvector, UnifiedFitQvector, UnifiedQ4
	Redimension/D UnifiedFitQvector, UnifiedQ4
	UnifiedQ4=UnifiedFitQvector^4
	
	
	UnifiedFitIntensity=0
	
	variable i
	
	for(i=1;i<=NumberOfLevels;i+=1)	// initialize variables;continue test
		IR1A_UnifiedCalcIntOne(i)
		Wave TempUnifiedIntensity
		UnifiedFitIntensity+=TempUnifiedIntensity
	endfor								
	NVAR SASBackground=root:Packages:Irena_UnifFit:SASBackground
	UnifiedFitIntensity+=SASBackground	
	
	if(UseSMRData)
		duplicate/O  UnifiedFitIntensity, UnifiedFitIntensitySM
		IR1B_SmearData(UnifiedFitIntensity, UnifiedFitQvector, SlitLengthUnif, UnifiedFitIntensitySM)
		UnifiedFitIntensity=UnifiedFitIntensitySM
		KillWaves UnifiedFitIntensitySM
	endif
	
	UnifiedIQ4=UnifiedFitIntensity*UnifiedQ4
end

//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************

Function IR1A_UnifiedCalcIntOne(level)
	variable level
	
	setDataFolder root:Packages:Irena_UnifFit
	Wave OriginalIntensity
	Wave OriginalQvector
	
	Duplicate/O OriginalIntensity, TempUnifiedIntensity
	Duplicate /O OriginalQvector, QstarVector
	Redimension/D TempUnifiedIntensity, QstarVector
	
	NVAR Rg=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"Rg")
	NVAR G=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"G")
	NVAR P=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"P")
	NVAR B=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"B")
	NVAR ETA=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"ETA")
	NVAR PACK=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"PACK")
	NVAR RgCO=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"RgCO")
	NVAR K=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"K")
	NVAR Corelations=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"Corelations")
	NVAR MassFractal=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"MassFractal")
	NVAR LinkRGCO=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"LinkRGCO")
	if (LinkRGCO==1 && level>=2)
		NVAR RgLowerLevel=$("root:Packages:Irena_UnifFit:Level"+num2str(level-1)+"Rg")	
		RGCO=RgLowerLevel
	endif
	QstarVector=OriginalQvector/(erf(K*OriginalQvector*Rg/sqrt(6)))^3
	if (MassFractal)
		B=(G*P/Rg^P)*exp(gammln(P/2))
	endif
	
	TempUnifiedIntensity=G*exp(-OriginalQvector^2*Rg^2/3)+(B/QstarVector^P) * exp(-RGCO^2 * OriginalQvector^2/3)
	
	if (Corelations)
		TempUnifiedIntensity/=(1+pack*IR1A_SphereAmplitude(OriginalQvector,ETA))
	//	TempUnifiedIntensity*=(1-pack*IR1A_SphereAmplitude(OriginalQvector,ETA)) 	//changed 6/24/2006 to agree with Standard formula from Ryong-Joon
	endif
end


//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************


Function IR1A_SphereAmplitude(qval, eta)
		variable qval, eta
		
		return (3*(sin(qval*eta)-qval*eta*cos(qval*eta))/(qval*eta)^3)
end

//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************


Function IR1A_FitLocalPorod(Level)
	variable level
	string oldDf=GetDataFolder(1)
	
	setDataFolder root:Packages:Irena_UnifFit
	
	Wave OriginalIntensity
	Wave OriginalQvector

	Duplicate/O OriginalIntensity, $("FitLevel"+num2str(Level)+"Porod")

	Wave FitInt=$("FitLevel"+num2str(Level)+"Porod")
	string FitIntName="FitLevel"+num2str(Level)+"Porod"
	
	NVAR Pp=$("Level"+num2str(level)+"P")
	NVAR B=$("Level"+num2str(level)+"B")
	NVAR G=$("Level"+num2str(level)+"G")
	NVAR Rg=$("Level"+num2str(level)+"Rg")
	NVAR MassFractal=$("Level"+num2str(level)+"MassFractal")
	
	NVAR FitP=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"FitP")
	NVAR PLowLimit=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"PLowLimit")
	NVAR PHighLimit=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"PHighLimit")
	NVAR FitB=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"FitB")
	NVAR BLowLimit=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"BLowLimit")
	NVAR BHighLimit=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"BHighLimit")

		
	variable LocalB
	if (MassFractal)
		LocalB=(G*Pp/Rg^P)*exp(gammln(Pp/2))
	else
		LocalB=B
	endif
	
	if (!FitB && !FitP)
		beep
		abort "No fitting parameter allowed to vary, select parameters to vary and set fitting limits"
	endif

	IR1A_SetErrorsToZero()
	Make/D/O/N=2 CoefficientInput, New_FitCoefficients, LocalEwave
	Make/O/T/N=2 CoefNames
	CoefficientInput[0]=LocalB
	CoefficientInput[1]=Pp
	LocalEwave[0]=LocalB/20
	LocalEwave[1]=Pp/20
	CoefNames={"Level"+num2str(level)+"B","Level"+num2str(level)+"P"}
	
	Make/D/O/N=2 New_FitCoefficients
	New_FitCoefficients[0] = {LocalB,Pp}
	Make/O/T/N=2 T_Constraints
	T_Constraints = {"K1 > 1","K1 < 4.2"}

	Variable V_FitError=0			//This should prevent errors from being generated
	//FuncFit fails if contraints are applied to parameter, which is held....
	//therefore we need to make sure, that if user helds the Porod constant, he/she does not run FuncFit with Constaraints..
	//modifed 12 20 2004 to use fit at once function to allow use on smeared data
	DoWindow IR1_LogLogPlotU
	if(V_Flag)
		DoWindow/F IR1_LogLogPlotU
	else
		abort
	endif
	if(strlen(CsrWave(A))<1 || strlen(CsrWave(B))<1)
		beep
		SetDataFolder oldDf
		abort "Set both cursors before fitting"
	endif
	
	if (FitP)
		FuncFit/H=(num2str(abs(FitB-1))+num2str(abs(FitP-1)))/N IR1_PowerLawFitAllATOnce New_FitCoefficients OriginalIntensity[pcsr(A),pcsr(B)] /X=OriginalQvector /W=OriginalError /I=1 /E=LocalEwave  /C=T_Constraints 
		//FuncFit/H=(num2str(abs(FitB-1))+num2str(abs(FitP-1)))/N IR1_PowerLawFit New_FitCoefficients OriginalIntensity[pcsr(A),pcsr(B)] /X=OriginalQvector /W=OriginalError /I=1 /E=LocalEwave  /C=T_Constraints 
	else
		FuncFit/H=(num2str(abs(FitB-1))+num2str(abs(FitP-1)))/N IR1_PowerLawFitAllATOnce New_FitCoefficients OriginalIntensity[pcsr(A),pcsr(B)] /X=OriginalQvector /W=OriginalError /I=1 /E=LocalEwave 
		//FuncFit/H=(num2str(abs(FitB-1))+num2str(abs(FitP-1)))/N IR1_PowerLawFit New_FitCoefficients OriginalIntensity[pcsr(A),pcsr(B)] /X=OriginalQvector /W=OriginalError /I=1 /E=LocalEwave 
	endif
	
//	FuncFit/H=(num2str(abs(FitB-1))+num2str(abs(FitP-1)))/N IR1_PowerLawFit New_FitCoefficients OriginalIntensity[pcsr(A),pcsr(B)] /X=OriginalQvector /W=OriginalError /I=1 /C=T_Constraints 

	if (V_FitError!=0)	//there was error in fitting
		beep
		IR1A_UpdatePorodFit(level,0)
		Abort "Fitting error, check starting parameters and fitting limits" 
	endif
	
	B=abs(New_FitCoefficients[0])
	Pp=abs(New_FitCoefficients[1])
	PlowLimit=1
	if (MassFractal)
		PHighLimit=3
	else
		PHighLimit=4
	endif
	BLowLimit=B/5
	BHighLimit=B*5
	
	IR1A_RecordErrorsAfterFit()
	IR1A_UpdatePorodFit(level,0)
	IR1A_UpdateUnifiedLevels(level, 0)
	SetDataFolder oldDf
end


//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************


Function IR1A_FitLocalGuinier(Level)
	variable level
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_UnifFit

	//first set to display local fits
		NVAR DisplayLocalFits=root:Packages:Irena_UnifFit:DisplayLocalFits
		DisplayLocalFits=1
		Checkbox DisplayLocalFits, value=DisplayLocalFits
	
	Wave OriginalIntensity
	Wave OriginalQvector

	Duplicate/O OriginalIntensity, $("FitLevel"+num2str(Level)+"Guinier")

	Wave FitInt=$("FitLevel"+num2str(Level)+"Guinier")
	string FitIntName="FitLevel"+num2str(Level)+"Guinier"
	
	NVAR Rg=$("Level"+num2str(level)+"Rg")
	NVAR G=$("Level"+num2str(level)+"G")
	
	NVAR FitRg=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"FitRg")
	NVAR RgLowLimit=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"RgLowLimit")
	NVAR RgHighLimit=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"RgHighLimit")
	NVAR FitG=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"FitG")
	NVAR GLowLimit=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"GLowLimit")
	NVAR GHighLimit=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"GHighLimit")

	if (!FitG && !FitRg)
		beep
		abort "No fitting parameter allowed to vary, select parameters to vary and set fitting limits"
	endif
//	if ((FitRg && (RgLowLimit > Rg || RgHighLimit < Rg)) || (FitG && (GLowLimit > G || GHighLimit < G)))
//			abort "Fitting limits set incorrectly, fix the limits before fitting"
//	endif
	DoWIndow/F IR1_LogLogPlotU
	if (strlen(CsrWave(A))==0 || strlen(CsrWave(B))==0)
		beep
		abort "Both Cursors Need to be set in Log-log graph on wave OriginalIntensity"
	endif
	IR1A_SetErrorsToZero()
//	Wave w=root:Packages:Irena_UnifFit:CoefficientInput
//	Wave/T CoefNames=root:Packages:Irena_UnifFit:CoefNames		//text wave with names of parameters

	Make/D/O/N=2 New_FitCoefficients, CoefficientInput, LocalEwave
	Make/O/T/N=2 CoefNames
	New_FitCoefficients[0] = G
	New_FitCoefficients[1] = Rg
	LocalEwave[0]=(G/20)
	LocalEwave[1]=(Rg/20)
	CoefficientInput[0]={G,Rg}
	CoefNames={"Level"+num2str(level)+"G","Level"+num2str(level)+"Rg"}
//	Make/O/T/N=0 T_Constraints
//	T_Constraints=""
	variable tempLength
	DoWIndow/F IR1_LogLogPlotU

	if(strlen(CsrWave(A))<1 || strlen(CsrWave(B))<1)
		beep
		SetDataFolder oldDf
		abort "Set both cursors before fitting"
	endif
	Variable V_FitError=0			//This should prevent errors from being generated
	//modifed 12 20 2004 to use fit at once function to allow use on smeared data

	FuncFit/Q/H=(num2str(abs(FitG-1))+num2str(abs(FitRg-1)))/N IR1_GuinierFitAllAtOnce New_FitCoefficients OriginalIntensity[pcsr(A),pcsr(B)] /X=OriginalQvector /W=OriginalError /I=1 /E=LocalEwave 
//	FuncFit/H=(num2str(abs(FitG-1))+num2str(abs(FitRg-1)))/N IR1_GuinierFit New_FitCoefficients OriginalIntensity[pcsr(A),pcsr(B)] /X=OriginalQvector /W=OriginalError /I=1 /E=LocalEwave 

	if (V_FitError!=0)	//there was error in fitting
		beep
		Abort "Fitting error, check starting parameters and fitting limits" 
	endif
	
	G=abs(New_FitCoefficients[0])
	Rg=abs(New_FitCoefficients[1])
	RgLowLImit=Rg/5
	RgHighLimit=Rg*5
	GLowLimit=G/5
	GhighLimit=G*5
	
	IR1A_RecordErrorsAfterFit()
	IR1A_UpdateGuinierFit(level,0)
	IR1A_UpdateUnifiedLevels(level, 0)
		SetDataFolder oldDf
end

//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************


Function IR1A_DisplayLocalFits(level, overwrite)
	variable level, overwrite
	
	DoWindow IR1_LogLogPlotU
	if (V_Flag)
//		RemoveFromGraph /W=IR1_LogLogPlotU /Z FitLevel1Porod,FitLevel2Porod,FitLevel3Porod,FitLevel4Porod,FitLevel5Porod
//		RemoveFromGraph /W=IR1_LogLogPlotU /Z FitLevel1Guinier,FitLevel2Guinier,FitLevel3Guinier,FitLevel4Guinier,FitLevel5Guinier
//		RemoveFromGraph /W=IR1_LogLogPlotU /Z Level1Unified,Level2Unified,Level3Unified,Level4Unified,Level5Unified
		
		NVAR NmbLevels=root:Packages:Irena_UnifFit:NumberOfLevels
		
		if(level>0&&level<=NmbLevels)
			IR1A_UpdateGuinierFit(level, overwrite)
			IR1A_UpdateUnifiedLevels(level, overwrite)
			IR1A_UpdatePorodFit(level, overwrite)
		endif
	endif
end

//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************


Function IR1A_UpdateLocalFitsIfSelected()

		NVAR UpdateAutomatically=root:Packages:Irena_UnifFit:UpdateAutomatically
		NVAR ActiveTab=root:Packages:Irena_UnifFit:ActiveTab
		
		DoWIndow IR1_LogLogPlotU
		if(V_Flag)
			RemoveFromGraph /W=IR1_LogLogPlotU /Z FitLevel1Porod,FitLevel2Porod,FitLevel3Porod,FitLevel4Porod,FitLevel5Porod
			RemoveFromGraph /W=IR1_LogLogPlotU /Z Level1Unified,Level2Unified,Level3Unified,Level4Unified,Level5Unified
			RemoveFromGraph /W=IR1_LogLogPlotU /Z FitLevel1Guinier,FitLevel2Guinier,FitLevel3Guinier,FitLevel4Guinier,FitLevel5Guinier
		endif

		DoWIndow IR1_IQ4_Q_PlotU
		if(V_Flag)
			RemoveFromGraph /W=IR1_IQ4_Q_PlotU /Z FitLevel1GuinierIQ4,FitLevel2GuinierIQ4,FitLevel3GuinierIQ4,FitLevel4GuinierIQ4,FitLevel5GuinierIQ4
			RemoveFromGraph /W=IR1_IQ4_Q_PlotU /Z Level1UnifiedIQ4,Level2UnifiedIQ4,Level3UnifiedIQ4,Level4UnifiedIQ4,Level5UnifiedIQ4
			RemoveFromGraph /W=IR1_IQ4_Q_PlotU /Z FitLevel1PorodIQ4,FitLevel2PorodIQ4,FitLevel3PorodIQ4,FitLevel4PorodIQ4,FitLevel5PorodIQ4
		endif
		if (UpdateAutomatically)
			IR1A_DisplayLocalFits(ActiveTab,0)
		endif

end

//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************


Function IR1A_UpdateLocalFitsForOutput()

		NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels
		NVAR UpdateAutomatically=root:Packages:Irena_UnifFit:UpdateAutomatically
		NVAR ActiveTab=root:Packages:Irena_UnifFit:ActiveTab
		NVAR ExportLocalFits=root:Packages:Irena_UnifFit:ExportLocalFits
		
		variable i
		if(ExportLocalFits)
			For(i=1;i<=5;i+=1)
				IR1A_DisplayLocalFits(i,1)
			endfor
	
			RemoveFromGraph /W=IR1_LogLogPlotU /Z FitLevel1Porod,FitLevel2Porod,FitLevel3Porod,FitLevel4Porod,FitLevel5Porod
			RemoveFromGraph /W=IR1_IQ4_Q_PlotU /Z FitLevel1PorodIQ4,FitLevel2PorodIQ4,FitLevel3PorodIQ4,FitLevel4PorodIQ4,FitLevel5PorodIQ4
			RemoveFromGraph /W=IR1_LogLogPlotU /Z Level1Unified,Level2Unified,Level3Unified,Level4Unified,Level5Unified
			RemoveFromGraph /W=IR1_IQ4_Q_PlotU /Z Level1UnifiedIQ4,Level2UnifiedIQ4,Level3UnifiedIQ4,Level4UnifiedIQ4,Level5UnifiedIQ4
			RemoveFromGraph /W=IR1_LogLogPlotU /Z FitLevel1Guinier,FitLevel2Guinier,FitLevel3Guinier,FitLevel4Guinier,FitLevel5Guinier
			RemoveFromGraph /W=IR1_IQ4_Q_PlotU /Z FitLevel1GuinierIQ4,FitLevel2GuinierIQ4,FitLevel3GuinierIQ4,FitLevel4GuinierIQ4,FitLevel5GuinierIQ4
				
			if (UpdateAutomatically)
				IR1A_DisplayLocalFits(ActiveTab,0)
			endif
		endif
end

//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************

Function IR1A_UpdatePorodFit(level, overwride)
	variable level, overwride
	
	setDataFolder root:Packages:Irena_UnifFit

	RemoveFromGraph /W=IR1_LogLogPlotU /Z FitLevel1Porod,FitLevel2Porod,FitLevel3Porod,FitLevel4Porod,FitLevel5Porod
	RemoveFromGraph /W=IR1_IQ4_Q_PlotU /Z FitLevel1PorodIQ4,FitLevel2PorodIQ4,FitLevel3PorodIQ4,FitLevel4PorodIQ4,FitLevel5PorodIQ4

	NVAR DisplayLocalFits
	
	if (DisplayLocalFits || overwride)	
		Wave OriginalIntensity
		Wave OriginalQvector
	
		Duplicate/O OriginalIntensity, $("FitLevel"+num2str(Level)+"Porod"), $("FitLevel"+num2str(Level)+"PorodIQ4")
	
		Wave FitInt=$("FitLevel"+num2str(Level)+"Porod")
		string FitIntName="FitLevel"+num2str(Level)+"Porod"
		Wave FitIntIQ4=$("FitLevel"+num2str(Level)+"PorodIQ4")
		string FitIntNameIQ4="FitLevel"+num2str(Level)+"PorodIQ4"
		
		NVAR P=$("Level"+num2str(level)+"P")
		NVAR B=$("Level"+num2str(level)+"B")
		NVAR G=$("Level"+num2str(level)+"G")
		NVAR Rg=$("Level"+num2str(level)+"Rg")
		NVAR MassFractal=$("Level"+num2str(level)+"MassFractal")
		
		variable LocalB
		if (MassFractal)
			LocalB=(G*P/Rg^P)*exp(gammln(P/2))
		else
			LocalB=B
		endif
		
		FitInt=LocalB*OriginalQvector^(-P)
		NVAR UseSMRData=root:Packages:Irena_UnifFit:UseSMRData
		NVAR SlitLengthUnif=root:Packages:Irena_UnifFit:SlitLengthUnif
		if(UseSMRData)
			duplicate/O  FitInt, UnifiedFitIntensitySM
			IR1B_SmearData(FitInt, OriginalQvector, SlitLengthUnif, UnifiedFitIntensitySM)
			FitInt=UnifiedFitIntensitySM
			KillWaves UnifiedFitIntensitySM
		endif
		FitIntIQ4=FitInt*OriginalQvector^4
			
		GetAxis /W=IR1_LogLogPlotU /Q left
		AppendToGraph /W=IR1_LogLogPlotU FitInt vs OriginalQvector
		ModifyGraph /W=IR1_LogLogPlotU lsize($(FitIntName))=1,rgb($(FitIntName))=(0,65280,0)
		SetAxis /W=IR1_LogLogPlotU left V_min, V_max

		GetAxis /W=IR1_IQ4_Q_PlotU /Q left
		AppendToGraph /W=IR1_IQ4_Q_PlotU FitIntIQ4 vs OriginalQvector
		ModifyGraph /W=IR1_IQ4_Q_PlotU lsize($(FitIntNameIQ4))=1,rgb($(FitIntNameIQ4))=(0,65280,0)
		SetAxis /W=IR1_IQ4_Q_PlotU left V_min, V_max
	endif	
end

//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************

Function IR1A_UpdateGuinierFit(level, overwride)
	variable level, overwride
	
	setDataFolder root:Packages:Irena_UnifFit

	RemoveFromGraph /W=IR1_LogLogPlotU /Z FitLevel1Guinier,FitLevel2Guinier,FitLevel3Guinier,FitLevel4Guinier,FitLevel5Guinier
	RemoveFromGraph /W=IR1_IQ4_Q_PlotU /Z FitLevel1GuinierIQ4,FitLevel2GuinierIQ4,FitLevel3GuinierIQ4,FitLevel4GuinierIQ4,FitLevel5GuinierIQ4

	NVAR DisplayLocalFits
	
	if (DisplayLocalFits || overwride)	
	
		Wave OriginalIntensity
		Wave OriginalQvector
	
		Duplicate/O OriginalIntensity, $("FitLevel"+num2str(Level)+"Guinier"),$("FitLevel"+num2str(Level)+"GuinierIQ4") 
	
		Wave FitInt=$("FitLevel"+num2str(Level)+"Guinier")
		string FitIntName="FitLevel"+num2str(Level)+"Guinier"
		Wave FitIntIQ4=$("FitLevel"+num2str(Level)+"GuinierIQ4")
		string FitIntNameIQ4="FitLevel"+num2str(Level)+"GuinierIQ4"
		
		NVAR G=$("Level"+num2str(level)+"G")
		NVAR Rg=$("Level"+num2str(level)+"Rg")
	
		
		FitInt=G*exp(-OriginalQvector^2*Rg^2/3)

		NVAR UseSMRData=root:Packages:Irena_UnifFit:UseSMRData
		NVAR SlitLengthUnif=root:Packages:Irena_UnifFit:SlitLengthUnif
		if(UseSMRData)
			duplicate/O  FitInt, UnifiedFitIntensitySM
			IR1B_SmearData(FitInt, OriginalQvector, SlitLengthUnif, UnifiedFitIntensitySM)
			FitInt=UnifiedFitIntensitySM
			KillWaves UnifiedFitIntensitySM
		endif

		FitIntIQ4=FitInt*OriginalQvector^4
			
		DoUpdate
		GetAxis /W=IR1_LogLogPlotU /Q left
		AppendToGraph /W=IR1_LogLogPlotU FitInt vs OriginalQvector
		ModifyGraph /W=IR1_LogLogPlotU lsize($(FitIntName))=1,rgb($(FitIntName))=(0,0,65280),lstyle($(FitIntName))=3
		SetAxis /W=IR1_LogLogPlotU left V_min, V_max

		GetAxis /W=IR1_IQ4_Q_PlotU /Q left
		AppendToGraph /W=IR1_IQ4_Q_PlotU FitIntIQ4 vs OriginalQvector
		ModifyGraph /W=IR1_IQ4_Q_PlotU lsize($(FitIntNameIQ4))=1,rgb($(FitIntNameIQ4))=(0,0,65280),lstyle($(FitIntNameIQ4))=3
		SetAxis /W=IR1_IQ4_Q_PlotU left V_min, V_max
	endif	
end

//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************

Function IR1A_UpdateUnifiedLevels(level, overwride)
	variable level, overwride
	
	setDataFolder root:Packages:Irena_UnifFit

	RemoveFromGraph /W=IR1_LogLogPlotU /Z Level1Unified,Level2Unified,Level3Unified,Level4Unified,Level5Unified
	RemoveFromGraph /W=IR1_IQ4_Q_PlotU /Z Level1UnifiedIQ4,Level2UnifiedIQ4,Level3UnifiedIQ4,Level4UnifiedIQ4,Level5UnifiedIQ4

	NVAR DisplayLocalFits
	
	if (DisplayLocalFits || overwride)	
	
		Wave OriginalIntensity
		Wave OriginalQvector
	
		Duplicate/O OriginalIntensity, $("Level"+num2str(Level)+"Unified"),$("Level"+num2str(Level)+"UnifiedIQ4") 
	
		Wave FitInt=$("Level"+num2str(Level)+"Unified")
		string FitIntName="Level"+num2str(Level)+"Unified"
		Wave FitIntIQ4=$("Level"+num2str(Level)+"UnifiedIQ4")
		string FitIntNameIQ4="Level"+num2str(Level)+"UnifiedIQ4"
		
		//NVAR G=$("Level"+num2str(level)+"G")
		//NVAR Rg=$("Level"+num2str(level)+"Rg")
	
		
		//FitInt=G*exp(-OriginalQvector^2*Rg^2/3)
		//FitIntIQ4=FitInt*OriginalQvector^4
		IR1A_UnifiedCalcIntOne(level)
		Wave TempUnifiedIntensity=root:Packages:Irena_UnifFit:TempUnifiedIntensity
		NVAR UseSMRData=root:Packages:Irena_UnifFit:UseSMRData
		NVAR SlitLengthUnif=root:Packages:Irena_UnifFit:SlitLengthUnif
		if(UseSMRData)
			duplicate/O  TempUnifiedIntensity, UnifiedFitIntensitySM
			IR1B_SmearData(TempUnifiedIntensity, OriginalQvector, SlitLengthUnif, UnifiedFitIntensitySM)
			TempUnifiedIntensity=UnifiedFitIntensitySM
			KillWaves UnifiedFitIntensitySM
		endif
		FitInt=TempUnifiedIntensity
		FitIntIQ4=FitInt*OriginalQvector^4
		
		DoUpdate
		GetAxis /W=IR1_LogLogPlotU /Q left        
		AppendToGraph /W=IR1_LogLogPlotU FitInt vs OriginalQvector  
		ModifyGraph /W=IR1_LogLogPlotU lsize($(FitIntName))=1,rgb($(FitIntName))=(52224,0,41728),lstyle($(FitIntName))=13
		ModifyGraph /W=IR1_LogLogPlotU mode($(FitIntName))=4,marker($(FitIntName))=23,msize($(FitIntName))=1
		SetAxis /W=IR1_LogLogPlotU left V_min, V_max

		GetAxis /W=IR1_IQ4_Q_PlotU /Q left
		AppendToGraph /W=IR1_IQ4_Q_PlotU FitIntIQ4 vs OriginalQvector
		ModifyGraph /W=IR1_IQ4_Q_PlotU lsize($(FitIntNameIQ4))=1,rgb($(FitIntNameIQ4))=(52224,0,41728),lstyle($(FitIntNameIQ4))=13
		ModifyGraph /W=IR1_IQ4_Q_PlotU mode($(FitIntNameIQ4))=4,marker($(FitIntNameIQ4))=23,msize($(FitIntNameIQ4))=1
		SetAxis /W=IR1_IQ4_Q_PlotU left V_min, V_max
	endif	
end

//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************


Function IR1_GuinierFit(w,q) : FitFunc
	Wave w
	Variable q

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ Prefactor=abs(Prefactor)
	//CurveFitDialog/ Rg=abs(Rg)
	//CurveFitDialog/ f(q) = Prefactor*exp(-q^2*Rg^2/3))
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ q
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = Prefactor
	//CurveFitDialog/ w[1] = Rg

	w[0]=abs(w[0])
	w[1]=abs(w[1])
	return w[0]*exp(-q^2*w[1]^2/3)
End
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************


Function IR1_GuinierFitAllAtOnce(parwave,ywave,xwave) : FitFunc
	Wave parwave,xwave,ywave

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ Prefactor=abs(Prefactor)
	//CurveFitDialog/ Rg=abs(Rg)
	//CurveFitDialog/ f(q) = Prefactor*exp(-q^2*Rg^2/3))
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ q
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = Prefactor
	//CurveFitDialog/ w[1] = Rg

	variable Prefactor=abs(parwave[0])
	variable Rg=abs(parwave[1])

	NVAR UseSMRData=root:Packages:Irena_UnifFit:UseSMRData
	NVAR SlitLengthUnif=root:Packages:Irena_UnifFit:SlitLengthUnif
	Wave OriginalQvector =root:Packages:Irena_UnifFit:OriginalQvector
	Duplicate/O OriginalQvector, tempGunInt
	//w[0]*exp(-q^2*w[1]^2/3)
	tempGunInt = Prefactor * exp(-OriginalQvector^2 * Rg^2/3)
	if(UseSMRData)
		duplicate/O  tempGunInt, tempGunIntSM
		IR1B_SmearData(tempGunInt, OriginalQvector, SlitLengthUnif, tempGunIntSM)
		tempGunInt=tempGunIntSM
	endif
	
	ywave = tempGunInt[binarysearch(OriginalQvector,xwave[0])+p]
	KillWaves/Z tempGunIntSM, tempGunInt
	
	return 1
End

//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************

Function IR1_PowerLawFitAllATOnce(parwave,ywave,xwave) : FitFunc
	Wave parwave,xwave,ywave

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ Prefactor=abs(Prefactor)
	//CurveFitDialog/ Slope=abs(slope)
	//CurveFitDialog/ f(q) = Prefactor*q^(-Slope)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ q
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = Prefactor
	//CurveFitDialog/ w[1] = Slope

	variable Prefactor=abs(parwave[0])
	variable slope=abs(parwave[1])
	

	NVAR UseSMRData=root:Packages:Irena_UnifFit:UseSMRData
	NVAR SlitLengthUnif=root:Packages:Irena_UnifFit:SlitLengthUnif
	Wave OriginalQvector =root:Packages:Irena_UnifFit:OriginalQvector
	Duplicate/O OriginalQvector, tempPowerLawInt
	// w[0]*q^(-w[1])
	tempPowerLawInt = Prefactor * OriginalQvector^(-slope)
	if(UseSMRData)
		duplicate/O  tempPowerLawInt, tempPowerLawIntSM
		IR1B_SmearData(tempPowerLawInt, OriginalQvector, SlitLengthUnif, tempPowerLawIntSM)
		tempPowerLawInt=tempPowerLawIntSM
	endif
	
	ywave = tempPowerLawInt[binarysearch(OriginalQvector,xwave[0])+p]
	KillWaves/Z tempGunIntSM, tempGunInt
End

//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************

Function IR1_PowerLawFit(w,q) : FitFunc
	Wave w
	Variable q

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ Prefactor=abs(Prefactor)
	//CurveFitDialog/ Slope=abs(slope)
	//CurveFitDialog/ f(q) = Prefactor*q^(-Slope)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ q
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = Prefactor
	//CurveFitDialog/ w[1] = Slope

	w[0]=abs(w[0])
	w[1]=abs(w[1])
	return w[0]*q^(-w[1])
End

//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************

Function IR1A_UpdateMassFractCalc()
	//here I update mass fractal calculations

	variable i
	
	For (i=2;i<=5;i+=1)
		NVAR IsMassFract=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"MassFractal")
		NVAR PrevRg=$("root:Packages:Irena_UnifFit:Level"+num2str(i-1)+"Rg")
		NVAR CurrentRg=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"Rg")
		NVAR DegreeOfAggreg=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"DegreeOfAggreg")
		if (IsMassFract)
			DegreeOfAggreg=CurrentRg/PrevRg
		else
			DegreeOfAggreg=0
		endif
	endfor

end


//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************

Function IR1A_UpdatePorodSurface()
	//here I update Porod surface calculations

	variable i
	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels
	
	For (i=1;i<=NumberOfLevels;i+=1)
		NVAR Porod=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"P")
		NVAR B=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"B")
		NVAR Rg=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"Rg")
		NVAR SurfaceToVolRat=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"SurfaceToVolRat")
		NVAR Invariant=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"Invariant")

		Wave OriginalQvector
		variable maxQ=2*pi/(Rg/10)
		variable Newnumpnts=2000
		Make/O/D/N=(Newnumpnts) SurfToVolQvec, SurfToVolInt, SurfToVolInvariant
		SurfToVolQvec=(maxQ/Newnumpnts)*p
		IR1A_SurfToVolCalcInvarVec(i, SurfToVolQvec, SurfToVolInt)
		SurfToVolInt[0]=SurfToVolInt[1]
		SurfToVolInvariant=SurfToVolInt*SurfToVolQvec^2		// Int * Q^2 wave
		
		Invariant=areaXY(SurfToVolQvec, SurfToVolInvariant, 0, maxQ )		//invariant, need to add "Porod tail"
		Invariant+=abs(B*maxQ^(3-abs(Porod))/2)							//Ok, this should be Porod tail 
		//Invariant is at this time in cm^-1 * A^-3  (Gregg Beaucage)
		if (Porod>=3.95 && Porod<=4.05)
			SurfaceToVolRat=1e4*pi*B/Invariant
		//	print "Invariant =   "+num2str(Invariant)
			//Surface to Volume ratio should be in m^2/cm^3 (Gregg Beaucage)
		else
			SurfaceToVolRat=NaN
		endif
		Invariant = Invariant * 10^24		//and now it is in cm-4
	endfor
	
	KillWaves/Z SurfToVolQvec, SurfToVolInt, SurfToVolInvariant
end

Function IR1A_SurfToVolCalcInvarVec(level, Qvector, IntensityVector)
	variable level
	Wave Qvector, IntensityVector
	
	setDataFolder root:Packages:Irena_UnifFit

	Duplicate /O Qvector, QstarVector
	
	NVAR Rg=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"Rg")
	NVAR G=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"G")
	NVAR P=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"P")
	NVAR B=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"B")
	NVAR ETA=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"ETA")
	NVAR PACK=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"PACK")
	NVAR RgCO=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"RgCO")
	NVAR K=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"K")
	NVAR Corelations=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"Corelations")
	NVAR MassFractal=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"MassFractal")
	NVAR LinkRGCO=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"LinkRGCO")
	if (LinkRGCO==1 && level>=2)
		NVAR RgLowerLevel=$("root:Packages:Irena_UnifFit:Level"+num2str(level-1)+"Rg")	
		RGCO=RgLowerLevel
	endif
	QstarVector=Qvector/(erf(K*Qvector*Rg/sqrt(6)))^3
	if (MassFractal)
		B=(G*P/Rg^P)*exp(gammln(P/2))
	endif
	
	IntensityVector=G*exp(-Qvector^2*Rg^2/3)+(B/QstarVector^P) * exp(-RGCO^2 * Qvector^2/3)
	
	if (Pack>0.01)
		IntensityVector/=(1+pack*IR1A_SphereAmplitude(Qvector,ETA))
	endif
	
	KillWaves QstarVector
End

//***********************************************************
//***********************************************************
//***********************************************************

Function IR2U_EvaluateUnifiedData()

	DoWindow UnifiedEvaluationPanel
	
	if(V_Flag)
		DoWIndow/F UnifiedEvaluationPanel
	else
		IR2U_InitUnifAnalysis()
		IR2U_UnifiedEvaPanelFnct() 
	endif
	DoWIndow/K/Z IR2U_UnifLogNormalSizeDist
end

//***********************************************************
//***********************************************************
//***********************************************************

Function IR2U_UnifiedEvaPanelFnct() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1/W=(311,63,686,470) as "Unified fit data evaluation"
	DoWindow/C UnifiedEvaluationPanel
	SetDrawLayer UserBack
	SetDrawEnv fsize= 18,fstyle= 3,textrgb= (1,4,52428)
	DrawText 26,27,"Special Case Data analysis"
	SetDrawEnv fsize= 18,fstyle= 3,textrgb= (1,4,52428)
	DrawText 117,54,"using Unified Fit results"

	Checkbox  CurrentResults, pos={10,63}, size={50,15}, variable =root:packages:Irena_AnalUnifFit:CurrentResults
	Checkbox  CurrentResults, title="Current Unified Fit",mode=1,proc=IR2U_CheckProc
	Checkbox  CurrentResults, help={"Select of you want to analyze current results in Unified Fit tool"}
	Checkbox StoredResults, pos={150,63}, size={50,15}, variable =root:packages:Irena_AnalUnifFit:StoredResults
	Checkbox  StoredResults, title="Stored Unified Fit results",mode=1, proc=IR2U_CheckProc
	Checkbox  StoredResults, help={"Select of you want to analyze Stored Unified fit data"}

	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup=""
	string EUserLookup=""
	IR2C_AddDataControls("Irena_AnalUnifFit","UnifiedEvaluationPanel","","UnifiedFitIntensity",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 1,1)
	NVAR UseResults = root:Packages:Irena_AnalUnifFit:UseResults
	UseResults=1
	STRUCT WMCheckboxAction CB_Struct
	CB_Struct.ctrlName="UseResults"
	CB_Struct.checked=1
	CB_Struct.win="UnifiedEvaluationPanel"
	CB_Struct.eventcode=2
	
	IR2C_InputPanelCheckboxProc(CB_Struct)
	Checkbox  UseResults, disable=1
	KillControl UseModelData
	KillCOntrol UseQRSData
	PopupMenu ErrorDataName, disable=1
	PopupMenu QvecDataName, disable=1
	PopupMenu SelectDataFolder,pos={25,87}
	PopupMenu SelectDataFolder proc=IR2U_PopMenuProc
	PopupMenu IntensityDataName,pos={25,114}
	PopupMenu IntensityDataName proc=IR2U_PopMenuProc	
	KillControl Qmin
	KillControl Qmax
	KillControl QNumPoints

	PopupMenu Model,pos={10,140},size={109,20},proc=IR2U_PopMenuProc,title="Model:"
	PopupMenu Model,help={"Select model to use for data analysis"}
	PopupMenu Model,mode=1,popvalue="---",value= #"root:Packages:Irena_AnalUnifFit:KnownModels"
	PopupMenu AvailableLevels,pos={230,140},size={109,20},proc=IR2U_PopMenuProc,title="Level:"
	PopupMenu AvailableLevels,help={"Select level to use for data analysis"}
	PopupMenu AvailableLevels,mode=1,popvalue="---", value=#"root:Packages:Irena_AnalUnifFit:AvailableLevels"

	//Invariant controls:
	SetVariable InvariantValue, pos={20,170}, size={250,20}, title="Invariant value [cm^-4]       ", help={"Invariant calcualted by the Unified fit."}
	SetVariable InvariantValue, variable=root:Packages:Irena_AnalUnifFit:InvariantValue, noedit=1,limits={-inf,inf,0}

	SetVariable InvariantUserContrast, pos={20,195}, size={250,20}, title="Contrast [10^20 cm^-4]       "
	SetVariable InvariantUserContrast, variable=root:Packages:Irena_AnalUnifFit:InvariantUserContrast
	SetVariable InvariantUserContrast,proc=IR2U_SetVarProc, help={"Contrast - user input. "}

	SetVariable InvariantPhaseVolume, pos={20,220}, size={250,20}, title="Volume of the phase [fract] "
	SetVariable InvariantPhaseVolume, variable=root:Packages:Irena_AnalUnifFit:InvariantPhaseVolume
	SetVariable InvariantPhaseVolume, disable=0,noedit=1,limits={-inf,inf,0}, help={"Fractional volume of the phase calculated from invariant and contrast"}
	//MassFactal stuff
	SetVariable BrFract_G2, pos={10,170}, size={120,20}, title="G2 = ", help={"Radius of gyration prefactor"}
	SetVariable BrFract_G2, variable=root:Packages:Irena_AnalUnifFit:BrFract_G2, noedit=1,limits={-inf,inf,0}
	SetVariable BrFract_Rg2, pos={170,170}, size={120,20}, title="Rg2 [A] = ", help={"Radius of gyration"}
	SetVariable BrFract_Rg2, variable=root:Packages:Irena_AnalUnifFit:BrFract_Rg2, noedit=1,limits={-inf,inf,0}
	SetVariable BrFract_B2, pos={10,195}, size={120,20}, title="B2 = ", help={"Power law slope prefactor"}
	SetVariable BrFract_B2, variable=root:Packages:Irena_AnalUnifFit:BrFract_B2, noedit=1,limits={-inf,inf,0}
	SetVariable BrFract_P2, pos={170,195}, size={120,20}, title="P2   = ", help={"Power law slope value"}
	SetVariable BrFract_P2, variable=root:Packages:Irena_AnalUnifFit:BrFract_P2, noedit=1,limits={-inf,inf,0}
	
	SetVariable BrFract_ErrorMessage, title=" ",value=root:Packages:Irena_AnalUnifFit:BrFract_ErrorMessage, noedit=1
	SetVariable BrFract_ErrorMessage, pos={5,215}, size={365,20}, frame=0, help={"Error message, if any"}	

	SetVariable BrFract_dmin, pos={10,240}, size={120,20}, title="dmin = ", help={"Parameter as defined in the references"}
	SetVariable BrFract_dmin, variable=root:Packages:Irena_AnalUnifFit:BrFract_dmin, noedit=1,limits={-inf,inf,0}
	SetVariable BrFract_c, pos={170,240}, size={120,20}, title="c =     ", help={"Parameter as defined in the references"}
	SetVariable BrFract_c, variable=root:Packages:Irena_AnalUnifFit:BrFract_c, noedit=1,limits={-inf,inf,0}
	SetVariable BrFract_z, pos={10,260}, size={120,20}, title="z =      ", help={"Parameter as defined in the references"}
	SetVariable BrFract_z, variable=root:Packages:Irena_AnalUnifFit:BrFract_z, noedit=1,limits={-inf,inf,0}
	SetVariable BrFract_fBr, pos={170,260}, size={120,20}, title="fBr = ", help={"Parameter as defined in the referecnes"}
	SetVariable BrFract_fBr, variable=root:Packages:Irena_AnalUnifFit:BrFract_fBr, noedit=1,limits={-inf,inf,0}
	SetVariable BrFract_fM, pos={10,280}, size={120,20}, title="fM =   ", help={"Parameter as defined in the references"}
	SetVariable BrFract_fM, variable=root:Packages:Irena_AnalUnifFit:BrFract_fM, noedit=1,limits={-inf,inf,0}

	SetVariable BrFract_Reference1, title="Ref: ",value=root:Packages:Irena_AnalUnifFit:BrFract_Reference1, noedit=1
	SetVariable BrFract_Reference1, pos={5,305}, size={365,20}, frame=0, help={"reference, please read"}	
	SetVariable BrFract_Reference2, title="Ref: ",value=root:Packages:Irena_AnalUnifFit:BrFract_Reference2, noedit=1
	SetVariable BrFract_Reference2, pos={5,325}, size={365,20}, frame=0, help={"Referecne, please read"}	

	//Size dist controls
	SetVariable SizeDist_G1, pos={10,170}, size={120,20}, title="G = ", help={"Rg prefactor"}
	SetVariable SizeDist_G1, variable=root:Packages:Irena_AnalUnifFit:SizeDist_G1, noedit=1,limits={-inf,inf,0}
	SetVariable SizeDist_Rg1, pos={170,170}, size={120,20}, title="Rg [A] = ", help={"Radius of gyration"}
	SetVariable SizeDist_Rg1, variable=root:Packages:Irena_AnalUnifFit:SizeDist_Rg1, noedit=1,limits={-inf,inf,0}
	SetVariable SizeDist_B1, pos={10,195}, size={120,20}, title="B = ", help={"Power law prefactor, also known as Porod constant when P=-4"}
	SetVariable SizeDist_B1, variable=root:Packages:Irena_AnalUnifFit:SizeDist_B1, noedit=1,limits={-inf,inf,0}
	SetVariable SizeDist_P1, pos={170,195}, size={120,20}, title="P   = ", help={"Power law slope value, should be 4 for this to work"}
	SetVariable SizeDist_P1, variable=root:Packages:Irena_AnalUnifFit:SizeDist_P1, noedit=1,limits={-inf,inf,0}

	SetVariable SizeDist_ErrorMessage, title=" ",value=root:Packages:Irena_AnalUnifFit:SizeDist_ErrorMessage, noedit=1
	SetVariable SizeDist_ErrorMessage, pos={5,215}, size={365,20}, frame=0, help={"Error message, if any"}	

	SetVariable SizeDist_sigmag, pos={10,240}, size={140,20}, title="Geom Sigma =", help={"Width of distributioon as defined int he reference"}
	SetVariable SizeDist_sigmag, variable=root:Packages:Irena_AnalUnifFit:SizeDist_sigmag, noedit=1,limits={-inf,inf,0}
	SetVariable SizeDist_GeomMean, pos={190,240}, size={140,20}, title="Geom mean =", help={"Mean radius as defined in the referecne"}
	SetVariable SizeDist_GeomMean, variable=root:Packages:Irena_AnalUnifFit:SizeDist_GeomMean, noedit=1,limits={-inf,inf,0}
	SetVariable SizeDist_PDI, pos={10,260}, size={140,20}, title="Polydisp indx =", help={"Polydispersity index as defined in the reference"}
	SetVariable SizeDist_PDI, variable=root:Packages:Irena_AnalUnifFit:SizeDist_PDI, noedit=1,limits={-inf,inf,0}
	SetVariable SizeDist_SuterMeanDiadp, pos={190,260}, size={140,20}, title="Sauter Mean Dia =", help={"Mean radius as defined in the reference"}
	SetVariable SizeDist_SuterMeanDiadp, variable=root:Packages:Irena_AnalUnifFit:SizeDist_SuterMeanDiadp, noedit=1,limits={-inf,inf,0}

	SetVariable SizeDist_Reference, title="Ref: ",value=root:Packages:Irena_AnalUnifFit:SizeDist_Reference, noedit=1
	SetVariable SizeDist_Reference, pos={5,305}, size={365,20}, frame=0, help={"Referecne for the model"}	
	
	//Porods law
//	Porod_Contrast;Porod_SpecificSfcArea, Porod_Constant
	SetVariable Porod_Constant, pos={20,170}, size={250,20}, title="Porod constant [cm^-1 A^-4]       ", help={"Porod constant calculated by the Unified fit."}
	SetVariable Porod_Constant, variable=root:Packages:Irena_AnalUnifFit:Porod_Constant, noedit=1,limits={-inf,inf,0}
	SetVariable Porod_PowerLawSlope, pos={20,195}, size={250,20}, title="Power law (Porods) slope    ", help={"Power law slope (should be -4)"}
	SetVariable Porod_PowerLawSlope, variable=root:Packages:Irena_AnalUnifFit:Porod_PowerLawSlope, noedit=1,limits={-inf,inf,0}

	SetVariable Porod_Contrast, pos={20,220}, size={250,20}, title="Contrast [10^20 cm^-4]          "
	SetVariable Porod_Contrast, variable=root:Packages:Irena_AnalUnifFit:Porod_Contrast
	SetVariable Porod_Contrast,proc=IR2U_SetVarProc, help={"Contrast - user input. "}


	SetVariable Porod_ErrorMessage, title=" ",value=root:Packages:Irena_AnalUnifFit:Porod_ErrorMessage, noedit=1
	SetVariable Porod_ErrorMessage, pos={5,245}, size={365,20}, frame=0, help={"Error message, if any"}	

	SetVariable Porod_SpecificSfcArea, pos={20,270}, size={250,20}, title="Specific surface area [cm^2/cm^3] "
	SetVariable Porod_SpecificSfcArea, variable=root:Packages:Irena_AnalUnifFit:Porod_SpecificSfcArea
	SetVariable Porod_SpecificSfcArea, disable=0,noedit=1,limits={-inf,inf,0}, help={"Specific surface area calculated from Porod constant and contrast"}

	Button PrintToGraph, pos={5,348}, size={200,20}, title="Print to Graph"
	Button PrintToGraph proc=IR2U_ButtonProc, help={"Create tag with results in the graph"}
	NVAR CurrentResults=root:packages:Irena_AnalUnifFit:CurrentResults
	if(CurrentResults)
		Button PrintToGraph, title="Print to Unified Fit Graph"
	else
		Button PrintToGraph, title="Print to top Graph"
	endif
	
	Button CalcLogNormalDist, pos={225,348}, size={100,20}, title="Display Dist."
	Button CalcLogNormalDist proc=IR2U_ButtonProc, help={"Calculate & display Log-normal distribution for these parameters"}
	
	
	Button SaveToHistory, pos={5,378}, size={150,20}, title="Print to history"
	Button SaveToHistory proc=IR2U_ButtonProc, help={"Create printout in the history area"}
	Button SaveToLogbook, pos={205,378}, size={150,20}, title="Print to LogBook"
	Button SaveToLogbook proc=IR2U_ButtonProc, help={"Create printrout of result into SAS logbook"}
	
	
	IR2U_SetControlsInPanel()
End
//***********************************************************
//***********************************************************
//***********************************************************
Function IR2U_InitUnifAnalysis()
	
	string oldDf=GetDataFolder(1)
	
	NewDataFolder/O/S root:Packages
	NewdataFolder/O/S root:Packages:Irena_AnalUnifFit
	
	string/g ListOfVariables
	string/g ListOfStrings

	ListOfVariables="CurrentResults;StoredResults;"
	ListOfVariables+="SelectedLevel;InvariantValue;InvariantUserContrast;InvariantPhaseVolume;"
	ListOfVariables+="BrFract_G2;BrFract_Rg2;BrFract_B2;BrFract_P2;BrFract_G1;BrFract_Rg1;BrFract_B1;BrFract_P1;"
	ListOfVariables+="BrFract_dmin;BrFract_c;BrFract_z;BrFract_fBr;BrFract_fM;"

	ListOfVariables+="SizeDist_Rg1;SizeDist_G1;SizeDist_B1;SizeDist_P1;SizeDist_PDI;"
	ListOfVariables+="SizeDist_sigmag;SizeDist_GeomMean;SizeDist_SuterMeanDiadp;"
	
	ListOfVariables+="Porod_Contrast;Porod_SpecificSfcArea;Porod_Constant;Porod_PowerLawSlope;"
	ListOfVariables+="SizeDist_NumPoints;SizeDist_MinSize;SizeDist_MaxSize;SizeDist_UserVolume;"
	
	//PDI is polydispersity index
	//
	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;"	
	ListOfStrings="Model;KnownModels;StoredResultsFolder;StoredResultsIntWvName;"
	ListOfStrings+="AvailableLevels;SlectedBranchedLevels;"
	ListOfStrings+="BrFract_Reference1;BrFract_Reference2;BrFract_ErrorMessage;"
	ListOfStrings+="SizeDist_Reference;SizeDist_ErrorMessage;Porod_ErrorMessage;"
	

	variable i
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	SVAR Model
	Model="---"
	SVAR KnownModels
	KnownModels = "Invariant;Porods Law;Branched mass fractal;Size distribution;"
	SVAR AvailableLevels
	AvailableLevels="---;"
	SVAR BrFract_Reference1
	BrFract_Reference1="Beaucage Phys.Rev.E(2004) 70(3) p10"
	SVAR BrFract_Reference2
	BrFract_Reference2="Beaucage Biophys.J.(2008) 95(2) p503"
	SVAR BrFract_ErrorMessage
	BrFract_ErrorMessage=""
	SVAR SizeDist_Reference
	SizeDist_Reference="Beaucage, Kammler and Pratsinis, J.Appl.Crystal. (2004) 37 p523"
	SVAR SizeDist_ErrorMessage
	SizeDist_ErrorMessage=""
	SVAR Porod_ErrorMessage
	Porod_ErrorMessage=""
	NVAR Porod_Contrast
	if(Porod_Contrast<=0)
		Porod_Contrast=100
	endif
	NVAR InvariantUserContrast
	if(InvariantUserContrast<=0)
		InvariantUserContrast=100
	endif
	NVAR CurrentResults
	NVAR StoredResults
	if(CurrentResults+StoredResults!=1)
		CurrentResults=1
		StoredResults=0
	endif
	NVAR InvariantValue
	InvariantValue =0 
	NVAR InvariantPhaseVolume
	InvariantPhaseVolume = 0

	NVAR SizeDist_NumPoints=root:Packages:Irena_AnalUnifFit:SizeDist_NumPoints
	NVAR SizeDist_UserVolume
	NVAR SizeDist_MinSize=root:Packages:Irena_AnalUnifFit:SizeDist_MinSize
	NVAR SizeDist_MaxSize=root:Packages:Irena_AnalUnifFit:SizeDist_MaxSize
	
	if(SizeDist_UserVolume<=0)
		SizeDist_UserVolume=0.1
	endif
	if(SizeDist_MinSize<5)	//5A is smallest size possible
		SizeDist_MinSize=5
	endif
	if(SizeDist_MaxSize<100)
		SizeDist_MaxSize=100
	endif
	if(SizeDist_NumPoints<20)
		SizeDist_NumPoints=400
	endif

	setDataFolder OldDf
end 
//***********************************************************
//***********************************************************
//***********************************************************

Function IR2U_PopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	NVAR SelectedLevel=root:Packages:Irena_AnalUnifFit:SelectedLevel
	SVAR SlectedBranchedLevels=root:Packages:Irena_AnalUnifFit:SlectedBranchedLevels
	SetVariable BrFract_ErrorMessage, win=UnifiedEvaluationPanel,  labelBack=0
	SetVariable SizeDist_ErrorMessage, win=UnifiedEvaluationPanel,  labelBack=0

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			string CtrlName=pa.ctrlName
			if(stringMatch(CtrlName,"Model"))
				SVAR Model=root:Packages:Irena_AnalUnifFit:Model
				Model = popStr
				SelectedLevel =0
				IR2U_SetControlsInPanel()	
				IR2U_FindAvailableLevels()
				IR2U_ClearVariables()
			endif
			if(stringMatch(CtrlName,"AvailableLevels"))
				SelectedLevel = str2num(popStr[0,0])
				SlectedBranchedLevels=popStr
				IR2U_RecalculateAppropriateVals()
			endif
			
			if(stringMatch(CtrlName,"IntensityDataName")||stringMatch(CtrlName,"SelectDataFolder"))
				IR2C_PanelPopupControl(pa)		
				SVAR Model=root:Packages:Irena_AnalUnifFit:Model
				Model = "---"
//				PopupMenu Model,win=UnifiedEvaluationPanel, mode=1,popvalue="---",value= root:Packages:Irena_AnalUnifFit:KnownModels
			endif	
			break
	endswitch

	return 0
End
//***********************************************************
//***********************************************************
//***********************************************************

Function IR2U_SetControlsInPanel()

		SVAR Model=root:Packages:Irena_AnalUnifFit:Model
		NVAR CurrentResults = root:packages:Irena_AnalUnifFit:CurrentResults
		DoWIndow UnifiedEvaluationPanel
		if(V_Flag)
			DoWIndow/F UnifiedEvaluationPanel
			if(CurrentResults)
				PopupMenu SelectDataFolder,disable=1
				PopupMenu IntensityDataName,disable=1	
			else
				PopupMenu SelectDataFolder,disable=0
				PopupMenu IntensityDataName,disable=0	
			endif

			SetVariable InvariantValue, disable=1
			SetVariable InvariantUserContrast, disable=1
			SetVariable InvariantPhaseVolume, disable=1

			SetVariable BrFract_G2, disable=1
			SetVariable BrFract_Rg2, disable=1
			SetVariable BrFract_B2, disable=1
			SetVariable BrFract_P2, disable=1
			SetVariable BrFract_ErrorMessage, disable=1
			SetVariable BrFract_dmin, disable=1
			SetVariable BrFract_c, disable=1
			SetVariable BrFract_z, disable=1
			SetVariable BrFract_fBr, disable=1
			SetVariable BrFract_fM, disable=1
			SetVariable BrFract_Reference1, disable=1
			SetVariable BrFract_Reference2, disable=1

			SetVariable SizeDist_G1, disable=1
			SetVariable SizeDist_Rg1, disable=1
			SetVariable SizeDist_B1, disable=1
			SetVariable SizeDist_P1, disable=1
			SetVariable SizeDist_ErrorMessage, disable=1	
			SetVariable SizeDist_sigmag, disable=1
			SetVariable SizeDist_GeomMean, disable=1
			SetVariable SizeDist_PDI, disable=1
			SetVariable SizeDist_SuterMeanDiadp, disable=1
			SetVariable SizeDist_Reference, disable=1	


			SetVariable Porod_Constant, disable=1	
			SetVariable Porod_Contrast, disable=1	
			SetVariable Porod_SpecificSfcArea, disable=1	
			SetVariable Porod_PowerLawSlope, disable=1
			SetVariable Porod_ErrorMessage, disable=1
			Button CalcLogNormalDist, disable=1
			if(stringmatch(Model,"Branched mass fractal"))
				SetVariable BrFract_G2, disable=0
				SetVariable BrFract_Rg2, disable=0
				SetVariable BrFract_B2, disable=0
				SetVariable BrFract_P2, disable=0
				SetVariable BrFract_ErrorMessage, disable=0
				SetVariable BrFract_dmin, disable=0
				SetVariable BrFract_c, disable=0
				SetVariable BrFract_z, disable=0
				SetVariable BrFract_fBr, disable=0
				SetVariable BrFract_fM, disable=0
				SetVariable BrFract_Reference1, disable=0
				SetVariable BrFract_Reference2, disable=0
			elseif(stringmatch(Model,"Invariant"))
				SetVariable InvariantValue, disable=0
				SetVariable InvariantUserContrast, disable=0
				SetVariable InvariantPhaseVolume, disable=0
			elseif(stringmatch(Model,"Porods law"))
				SetVariable Porod_Constant, disable=0	
				SetVariable Porod_Contrast, disable=0	
				SetVariable Porod_SpecificSfcArea, disable=0	
				SetVariable Porod_PowerLawSlope, disable=0
				SetVariable Porod_ErrorMessage, disable=0
			elseif(stringmatch(Model,"Size distribution"))
				SetVariable SizeDist_G1, disable=0
				SetVariable SizeDist_Rg1, disable=0
				SetVariable SizeDist_B1, disable=0
				SetVariable SizeDist_P1, disable=0
				SetVariable SizeDist_ErrorMessage, disable=0	
				SetVariable SizeDist_sigmag, disable=0
				SetVariable SizeDist_GeomMean, disable=0
				SetVariable SizeDist_PDI, disable=0
				SetVariable SizeDist_SuterMeanDiadp, disable=0
				SetVariable SizeDist_Reference, disable=0	
				Button CalcLogNormalDist, disable=0
			endif
		else
			return 0
		endif
end
//***********************************************************
//***********************************************************
//***********************************************************

Function IR2U_CheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			NVAR CurrentResults=root:packages:Irena_AnalUnifFit:CurrentResults
			NVAR StoredResults=root:packages:Irena_AnalUnifFit:StoredResults
			if(stringMatch(cba.ctrlName,"CurrentResults"))
				StoredResults=!CurrentResults
				Button PrintToGraph, win=UnifiedEvaluationPanel, title="Print to Unified Fit Graph"
			endif
			if(stringMatch(cba.ctrlName,"StoredResults"))
				CurrentResults=!StoredResults
				Button PrintToGraph, win=UnifiedEvaluationPanel, title="Print to top Graph"
			endif
			IR2U_ClearVariables()
			SVAR Model=root:Packages:Irena_AnalUnifFit:Model
			Model = "---"
			PopupMenu Model,win=UnifiedEvaluationPanel, mode=1,popvalue="---",value= #"root:Packages:Irena_AnalUnifFit:KnownModels"
			IR2U_SetControlsInPanel()
			break
	endswitch

	return 0
End
//***********************************************************
//***********************************************************
//***********************************************************

Function IR2U_FindAvailableLevels()
	
	NVAR UseCurrentResults=root:Packages:Irena_AnalUnifFit:CurrentResults
	NVAR UseStoredResults=root:Packages:Irena_AnalUnifFit:StoredResults

	SVAR Model=root:Packages:Irena_AnalUnifFit:Model
	variable LNumOfLevels, i
	
	if(UseCurrentResults)
		NVAR NumberOfLevels = root:Packages:Irena_UnifFit:NumberOfLevels
		LNumOfLevels = NumberOfLevels
	else
		LNumOfLevels =IR2U_ReturnNoteNumValue("NumberOfModelledLevels")
	endif
	string AvailableLevels=""
	if(stringmatch(Model,"Branched mass fractal"))	
		if(LNumOfLevels>=1)
			AvailableLevels+=num2str(1)+";"
		endif
		For(i=2;i<=LNumOfLevels;i+=1)
			AvailableLevels+=num2str(i)+"/"+num2str(i-1)+";"+num2str(i)+";"
		endfor
	else
		For(i=1;i<=LNumOfLevels;i+=1)
			AvailableLevels+=num2str(i)+";"
		endfor
	endif
	String quote = "\""
	AvailableLevels = quote + AvailableLevels + quote
	PopupMenu AvailableLevels,win=UnifiedEvaluationPanel,mode=1,popvalue="---", value=#AvailableLevels
end
//***********************************************************
//***********************************************************
//***********************************************************
Function IR2U_CalculateInvariantVals()

	NVAR SelectedLevel = root:Packages:Irena_AnalUnifFit:SelectedLevel
	NVAR InvariantValue = root:Packages:Irena_AnalUnifFit:InvariantValue
	NVAR InvariantUserContrast = root:Packages:Irena_AnalUnifFit:InvariantUserContrast
	NVAR InvariantPhaseVolume = root:Packages:Irena_AnalUnifFit:InvariantPhaseVolume

	NVAR UseCurrentResults=root:Packages:Irena_AnalUnifFit:CurrentResults
	NVAR UseStoredResults=root:Packages:Irena_AnalUnifFit:StoredResults

	if(SelectedLevel>=1)
		if(UseCurrentResults)
			NVAR Invariant=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"Invariant")
			InvariantValue = Invariant
		else
			//look up from wave note...
			InvariantValue = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"Invariant")
		endif
	else
		InvariantValue=0
		InvariantPhaseVolume=0
	endif
	InvariantPhaseVolume = (InvariantValue / InvariantUserContrast)*1e-20/(2*pi^2)
	
end
//***********************************************************
//***********************************************************
//***********************************************************
Function IR2U_CalculatePorodsLaw()

	NVAR SelectedLevel = root:Packages:Irena_AnalUnifFit:SelectedLevel
	NVAR Porod_Constant = root:Packages:Irena_AnalUnifFit:Porod_Constant
	NVAR Porod_SpecificSfcArea = root:Packages:Irena_AnalUnifFit:Porod_SpecificSfcArea
	NVAR Porod_Contrast = root:Packages:Irena_AnalUnifFit:Porod_Contrast
	SVAR Porod_ErrorMessage=root:Packages:Irena_AnalUnifFit:Porod_ErrorMessage
	NVAR Porod_PowerLawSlope=root:Packages:Irena_AnalUnifFit:Porod_PowerLawSlope
	
	NVAR UseCurrentResults=root:Packages:Irena_AnalUnifFit:CurrentResults
	NVAR UseStoredResults=root:Packages:Irena_AnalUnifFit:StoredResults

	if(SelectedLevel>=1)
		if(UseCurrentResults)
			NVAR Bval=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"B")
			NVAR Pval=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"P")
			Porod_Constant = Bval
			Porod_PowerLawSlope = Pval
		else
			//look up from wave note...
			Porod_Constant = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"B")
			Porod_PowerLawSlope =  IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"P")
		endif
	else
		Porod_Constant=0
		Porod_SpecificSfcArea=0
		Porod_PowerLawSlope=0
	endif
	
	if(Porod_PowerLawSlope>3.95 && Porod_PowerLawSlope<4.05)
		Porod_SpecificSfcArea =Porod_Constant *1e32 / (2*pi*Porod_Contrast*1e20)
		Porod_ErrorMessage=""
	else
		Porod_ErrorMessage="Error, P should be ~ 4"
		Porod_SpecificSfcArea = 0
	endif
		
	if(strlen(Porod_ErrorMessage)>0)
		SetVariable Porod_ErrorMessage, win=UnifiedEvaluationPanel,  labelBack=(65535,49151,49151)
	else
		SetVariable Porod_ErrorMessage, win=UnifiedEvaluationPanel,  labelBack=0
	endif
	
end



//***********************************************************
//***********************************************************
//***********************************************************

Function IR2U_CalculateSizeDist()

	NVAR SelectedLevel = root:Packages:Irena_AnalUnifFit:SelectedLevel
	NVAR UseCurrentResults=root:Packages:Irena_AnalUnifFit:CurrentResults
	NVAR UseStoredResults=root:Packages:Irena_AnalUnifFit:StoredResults

	NVAR SizeDist_G1=root:Packages:Irena_AnalUnifFit:SizeDist_G1
	NVAR SizeDist_Rg1=root:Packages:Irena_AnalUnifFit:SizeDist_Rg1
	NVAR SizeDist_B1=root:Packages:Irena_AnalUnifFit:SizeDist_B1
	NVAR SizeDist_P1=root:Packages:Irena_AnalUnifFit:SizeDist_P1
	SVAR SizeDist_ErrorMessage=root:Packages:Irena_AnalUnifFit:SizeDist_ErrorMessage
	NVAR SizeDist_sigmag=root:Packages:Irena_AnalUnifFit:SizeDist_sigmag
	NVAR SizeDist_GeomMean=root:Packages:Irena_AnalUnifFit:SizeDist_GeomMean
	NVAR SizeDist_PDI=root:Packages:Irena_AnalUnifFit:SizeDist_PDI
	NVAR SizeDist_SuterMeanDiadp=root:Packages:Irena_AnalUnifFit:SizeDist_SuterMeanDiadp
	variable LevelSurfaceToVolRat

	if(SelectedLevel>=1)
		if(UseCurrentResults)
			NVAR gG=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"G")
			SizeDist_G1 = gG
			NVAR gRG=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"Rg")
			SizeDist_Rg1 = gRg
			NVAR gB=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"B")
			SizeDist_B1 = gB
			NVAR gP=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"P")
			SizeDist_P1 = gP
			NVAR gSvR=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"SurfaceToVolRat")
			LevelSurfaceToVolRat = gSvR
			
		else
			//look up from wave note...
			SizeDist_G1 = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"G")
			SizeDist_Rg1 = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"Rg")
			SizeDist_B1 = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"B")
			SizeDist_P1 = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"P")
			LevelSurfaceToVolRat = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"SurfaceToVolRat")
		endif
	
		if(SizeDist_P1<3.96 || SizeDist_P1>4.04)
			SizeDist_ErrorMessage =  "ERROR!   P needs to be   ~  4"
			SizeDist_sigmag = 0
			SizeDist_GeomMean = 0
			SizeDist_PDI = 0
			SizeDist_SuterMeanDiadp = 0
		else
			SizeDist_PDI=SizeDist_Rg1^4*SizeDist_B1/1.62/SizeDist_G1
			SizeDist_sigmag=(ln(SizeDist_PDI)/12)^(1/2)
			SizeDist_GeomMean=(5*SizeDist_Rg1^2/3/exp(14*SizeDist_sigmag^2))^(1/2)
			SizeDist_SuterMeanDiadp=6000/LevelSurfaceToVolRat // s/v is in m2/cm3 and dp is in nm
			SizeDist_ErrorMessage =  "  "
			if(SizeDist_PDI<1)
				SizeDist_ErrorMessage =  "Error, see detailed info in history area"
				print "There is a problem with the fit.  The power law prefactor is smaller than for the lowest surface area particle, a sphere so this is not physically possible.  Refit with different starting parameters please."
			endif
			if(SizeDist_PDI>9)//9 is an experimentally observed number for something like a 2.5 aspect ratio rod which is the limit of what you can obeserve as a dimensional object according to Guinier and Fournet.
				SizeDist_ErrorMessage =  "Error, see detailed info in history area"
				print "There is a problem with the fit.  The power law prefactor is larger than any meaningful polydisperse or asymmetric particle with a single Rg."
				print   "Refit with a different model such as using asymmetric particles such as rods or disk models please."
			endif
		endif
	else
			SizeDist_ErrorMessage =  " "
			SizeDist_sigmag = 0
			SizeDist_GeomMean = 0
			SizeDist_PDI = 0
			SizeDist_SuterMeanDiadp = 0

	endif
	if(strlen(SizeDist_ErrorMessage)>3)
		SetVariable SizeDist_ErrorMessage, win=UnifiedEvaluationPanel,  labelBack=(65535,49151,49151)
		beep
	else
		SetVariable SizeDist_ErrorMessage, win=UnifiedEvaluationPanel,  labelBack=0
	endif

end

//***********************************************************
//***********************************************************
//***********************************************************

Function IR2U_CalcLogNormalDistribution()

	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_AnalUnifFit
	NVAR SizeDist_sigmag=root:Packages:Irena_AnalUnifFit:SizeDist_sigmag
	NVAR SizeDist_GeomMean=root:Packages:Irena_AnalUnifFit:SizeDist_GeomMean
	NVAR SizeDist_NumPoints=root:Packages:Irena_AnalUnifFit:SizeDist_NumPoints
	NVAR SizeDist_MinSize=root:Packages:Irena_AnalUnifFit:SizeDist_MinSize
	NVAR SizeDist_MaxSize=root:Packages:Irena_AnalUnifFit:SizeDist_MaxSize
	NVAR SelectedLevel = root:Packages:Irena_AnalUnifFit:SelectedLevel
	NVAR SizeDist_PDI = root:Packages:Irena_AnalUnifFit:SizeDist_PDI
	
	//find reasonable min and max sizes...
	SizeDist_MinSize = SizeDist_GeomMean - (3)*(SizeDist_sigmag+SizeDist_GeomMean)
	SizeDist_MaxSize = SizeDist_GeomMean + (7)*(SizeDist_sigmag+SizeDist_GeomMean)
	IR2U_ReCalculateLogNormalSD()
	Wave RadiusWave
	Wave SizeNumDistribution
	Wave SizeVolDistribution

	DoWIndow IR2U_UnifLogNormalSizeDist
	if(V_Flag)
		DoWIndow/F IR2U_UnifLogNormalSizeDist
	else
		Display /K=1/W=(446,54,1008,510) SizeNumDistribution vs RadiusWave
		AppendToGraph/R SizeVolDistribution vs RadiusWave
		DoWindow/C IR2U_UnifLogNormalSizeDist
		DoWindow/T IR2U_UnifLogNormalSizeDist,"Unifed Log Normal Size distribution"
		//
		ControlBar 60
			SetVariable SizeDist_MinSize,pos={20,10},size={180,16},title="Radius min [A]:  ", format="%3.1f", help={"Minimum size for calculating size distribution"}
			SetVariable SizeDist_MinSize,limits={5,Inf,0},variable=root:Packages:Irena_AnalUnifFit:SizeDist_MinSize, proc=IR2U_SetVarProc
			SetVariable SizeDist_MaxSize,pos={20,35},size={180,16},title="Radius max [A]:  ", format="%3.1f",  help={"Maximum size for calculating size distribution"}
			SetVariable SizeDist_MaxSize,limits={5,Inf,0},variable=root:Packages:Irena_AnalUnifFit:SizeDist_MaxSize, proc=IR2U_SetVarProc

			SetVariable SelectedLevel,pos={220,10},size={100,16},title="Level:  ", format="%3.0f", help={"Selected level for this size distribution"}
			SetVariable SelectedLevel,limits={5,Inf,0},variable=root:Packages:Irena_AnalUnifFit:SelectedLevel, disable=2

			SetVariable SizeDist_UserVolume,pos={350,10},size={150,16},title="Volume fraction:  ", format="%3.3f", help={"Input volume for calibration (if you need it)"}
			SetVariable SizeDist_UserVolume,limits={0,Inf,0},variable=root:Packages:Irena_AnalUnifFit:SizeDist_UserVolume, proc=IR2U_setVarProc
			
			

			Button SaveDataSD,pos={350,35},size={150,20},proc=IR2U_ButtonProc,title="Save SD "
			Button SaveDataSD help={"Select data on the left and push to add data in the graph"}

		//
		ModifyGraph rgb(SizeNumDistribution)=(24576,24576,65535)
		ModifyGraph mirror(bottom)=1
		String LabelStr= "\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"Number distribution [1/cm\\S3\\M\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"A\\S1\\M\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"]"
		Label left LabelStr
		//Label left "Number distribution [1/cm\\S3\\M A\\S1\\M]"
		LabelStr= "\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"Radius [A]"
		Label bottom LabelStr
		LabelStr= "\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"Volume distribution [cm\\S3\\M/cm\\S3\\M\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"A\\S1\\M\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"]"
		Label right LabelStr
		//Label right "Volume distribution [cm\\S3\\M/cm\\S3\\M A\\S1\\M]"
		Legend/C/N=text0/J/A=MC/X=32.48/Y=45.38 "\\F"+IR2C_LkUpDfltStr("FontType")+"\\Z"+IR2C_LkUpDfltVar("LegendSize")+"\\s(SizeNumDistribution) Number Distribution\r\\s(SizeVolDistribution) Volume Distribution"
	endif
				
	setDataFolder OldDf
End
//***********************************************************
//***********************************************************
//***********************************************************
Function IR2U_ReCalculateLogNormalSD()

	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_AnalUnifFit
	NVAR SizeDist_sigmag=root:Packages:Irena_AnalUnifFit:SizeDist_sigmag
	NVAR SizeDist_GeomMean=root:Packages:Irena_AnalUnifFit:SizeDist_GeomMean
	NVAR SizeDist_NumPoints=root:Packages:Irena_AnalUnifFit:SizeDist_NumPoints
	NVAR SizeDist_MinSize=root:Packages:Irena_AnalUnifFit:SizeDist_MinSize
	NVAR SizeDist_MaxSize=root:Packages:Irena_AnalUnifFit:SizeDist_MaxSize
	NVAR SizeDist_UserVolume = root:Packages:Irena_AnalUnifFit:SizeDist_UserVolume
	
	//find reasonable min and max sizes...
	if(SizeDist_MinSize<5)	//5A is smallest size possible
		SizeDist_MinSize=5
	endif
	Make/O/N=(SizeDist_NumPoints) RadiusWave, SizeNumDistribution, SizeVolDistribution
	
	RadiusWave = SizeDist_MinSize + p* (SizeDist_MaxSize-SizeDist_MinSize)/SizeDist_NumPoints
	
	SizeNumDistribution=(2/((2*RadiusWave)*SizeDist_sigmag*sqrt(2*pi)))*exp(-(ln((2*RadiusWave)/(2*SizeDist_GeomMean)))^2/(2*SizeDist_sigmag^2))
	SizeVolDistribution = SizeNumDistribution * (4/3*pi*(RadiusWave)^3) 
	
	variable IntegralVol=areaXY(RadiusWave, SizeVolDistribution )
	
	SizeVolDistribution *=SizeDist_UserVolume / IntegralVol
	SizeNumDistribution = SizeVolDistribution / (4/3*pi*(RadiusWave)^3)
	//SizeDist_UserVolume

	setDataFolder OldDf


//sig,m_val,Diawave,output
//    variable/g gsig,gm_val
//    variable sig=gsig,m_val=gm_val
//    string/g gDiawave,goutput
//    string Diawave=gDiawave,output=goutput
//    Prompt sig, "Enter Sigma"
//    Prompt m_val,"Enter m (geo mean radius)"
//    Prompt Diawave,"enter Diameter wave:",popup,WaveList("*", ";", "")
//    Prompt Output,"enter the output name: (21 R * _Num_Calc):"
//    
//    silent 1
//    gsig=sig;gm_val=m_val;gDiawave=Diawave;goutput=output
//    output="R"+output[0,21]+"_Num_Calc"
//    duplicate/o $Diawave $output
//    $output=(2/($Diawave*sig*sqrt(2*pi)))*exp(-(ln($Diawave/(2*m_val)))^2/(2*sig^2))/20000
//    string volume=output[0,strlen(output)-13]+"_Vol_Calc"
//    duplicate/o $output $volume
//    $volume=($output*$Diawave^3)/3e7

end


//***********************************************************
//***********************************************************
//***********************************************************

Function IR2U_CalculateBranchedMassFr()

	NVAR SelectedLevel = root:Packages:Irena_AnalUnifFit:SelectedLevel
	SVAR SlectedBranchedLevels=root:Packages:Irena_AnalUnifFit:SlectedBranchedLevels
	NVAR UseCurrentResults=root:Packages:Irena_AnalUnifFit:CurrentResults
	NVAR UseStoredResults=root:Packages:Irena_AnalUnifFit:StoredResults

	NVAR BrFract_G2=root:Packages:Irena_AnalUnifFit:BrFract_G2
	NVAR BrFract_Rg2=root:Packages:Irena_AnalUnifFit:BrFract_Rg2
	NVAR BrFract_B2=root:Packages:Irena_AnalUnifFit:BrFract_B2
	NVAR BrFract_P2=root:Packages:Irena_AnalUnifFit:BrFract_P2
	NVAR BrFract_G1=root:Packages:Irena_AnalUnifFit:BrFract_G1
	NVAR BrFract_Rg1=root:Packages:Irena_AnalUnifFit:BrFract_Rg1
	NVAR BrFract_B1=root:Packages:Irena_AnalUnifFit:BrFract_B1
	NVAR BrFract_P1=root:Packages:Irena_AnalUnifFit:BrFract_P1
	SVAR BrFract_ErrorMessage=root:Packages:Irena_AnalUnifFit:BrFract_ErrorMessage
	NVAR BrFract_dmin=root:Packages:Irena_AnalUnifFit:BrFract_dmin
	NVAR BrFract_c=root:Packages:Irena_AnalUnifFit:BrFract_c
	NVAR BrFract_z=root:Packages:Irena_AnalUnifFit:BrFract_z
	NVAR BrFract_fBr=root:Packages:Irena_AnalUnifFit:BrFract_fBr
	NVAR BrFract_fM=root:Packages:Irena_AnalUnifFit:BrFract_fM

	if(SelectedLevel>=2)
		if(UseCurrentResults)
			NVAR gG2=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"G")
			BrFract_G2 = gG2
			NVAR gRg2=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"Rg")
			BrFract_Rg2 = gRg2
			NVAR gB2=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"B")
			BrFract_B2 = gB2
			NVAR gP2=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"P")
			BrFract_P2 = gP2
			NVAR gG1=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel-1)+"G")
			BrFract_G1 = gG1
			NVAR gRg1=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel-1)+"Rg")
			BrFract_Rg1 = gRg1
			NVAR gB1=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel-1)+"B")
			BrFract_B1 = gB1
			NVAR gP1=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel-1)+"P")
			BrFract_P1 = gP1
		else
			//look up from wave note...
			BrFract_G2 = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"G")
			BrFract_Rg2 = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"Rg")
			BrFract_B2 = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"B")
			BrFract_P2 = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"P")
			BrFract_G1 = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel-1)+"G")
			BrFract_Rg1 = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel-1)+"Rg")
			BrFract_B1 = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel-1)+"B")
			BrFract_P1 = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel-1)+"P")
		endif
	elseif(SelectedLevel==1)
		if(UseCurrentResults)
			NVAR gG2=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"G")
			BrFract_G2 = gG2
			NVAR gRg2=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"Rg")
			BrFract_Rg2 = gRg2
			NVAR gB2=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"B")
			BrFract_B2 = gB2
			NVAR gP2=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"P")
			BrFract_P2 = gP2
			BrFract_G1 =0
			BrFract_Rg1 = 0
			BrFract_B1 =0
			BrFract_P1 = 0
		else
			//look up from wave note...
			BrFract_G2 = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"G")
			BrFract_Rg2 = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"Rg")
			BrFract_B2 = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"B")
			BrFract_P2 = IR2U_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"P")
			BrFract_G1 = 0
			BrFract_Rg1 = 0
			BrFract_B1 = 0
			BrFract_P1 = 0
		endif
	else
			BrFract_G2 = 0
			BrFract_Rg2 = 0
			BrFract_B2 = 0
			BrFract_P2 = 0
			BrFract_G1 = 0
			BrFract_Rg1 = 0
			BrFract_B1 = 0
			BrFract_P1 = 0
	endif
	if(strlen(SlectedBranchedLevels)>1)
		BrFract_dmin  =BrFract_B2*BrFract_Rg2^(BrFract_P2)/(exp(gammln(BrFract_P2/2))*BrFract_G2)
		BrFract_c  =BrFract_P2/(BrFract_B2*BrFract_Rg2^(BrFract_P2)/(exp(gammln(BrFract_P2/2))*BrFract_G2))
		BrFract_z  =BrFract_G2/BrFract_G1
		BrFract_fBr =(1-(BrFract_G2/BrFract_G1)^(1/(BrFract_P2/(BrFract_B2*BrFract_Rg2^(BrFract_P2)/(exp(gammln(BrFract_P2/2))*BrFract_G2)))-1))
		BrFract_fM  = (1-(BrFract_G2/BrFract_G1)^(1/((BrFract_B2*BrFract_Rg2^(BrFract_P2)/(exp(gammln(BrFract_P2/2))*BrFract_G2)))-1))
	else
		BrFract_dmin  =BrFract_B2*BrFract_Rg2^(BrFract_P2)/(exp(gammln(BrFract_P2/2))*BrFract_G2)
		BrFract_c  =BrFract_P2/(BrFract_B2*BrFract_Rg2^(BrFract_P2)/(exp(gammln(BrFract_P2/2))*BrFract_G2))
		BrFract_z  =Nan
		BrFract_fBr =NaN
		BrFract_fM  = NaN
	endif
	
	if(BrFract_c<0.96)
		BrFract_ErrorMessage =  "The mass fractal is too polydisperse to analyse, c < 1"
	else
		if(BrFract_c>=0.96 && BrFract_c<=1.04)//this should be in the range of 1 say +- .02
			BrFract_ErrorMessage = "THIS IS A LINEAR CHAIN WITH NO BRANCHES!"
		endif
		if(BrFract_c>=3)
			BrFract_ErrorMessage =  "There is a problem with the fit, c must be less than 3"
		endif
		if(BrFract_dmin>=3)
			BrFract_ErrorMessage = "There is a problem with the fit since dmin must be less than 3"
		endif
		if(BrFract_dmin>=0.96 && BrFract_dmin<=1.04 )//this should be in the range of 1 say +- .02
			BrFract_ErrorMessage = "This is a regular object, i.e.  c=1 rod, c=2 disk, c=3 sphere, etc."
		endif
	endif
	
	if(strlen(BrFract_ErrorMessage)>0)
		SetVariable BrFract_ErrorMessage, win=UnifiedEvaluationPanel,  labelBack=(65535,49151,49151)
		beep
	else
		SetVariable BrFract_ErrorMessage, win=UnifiedEvaluationPanel,  labelBack=0
	endif

end


//***********************************************************
//***********************************************************
//***********************************************************

Function IR2U_RecalculateAppropriateVals()

	SVAR Model=root:Packages:Irena_AnalUnifFit:Model
	if(stringmatch(Model,"Invariant"))	
		IR2U_CalculateInvariantVals()
	elseif(stringmatch(Model,"Size Distribution"))	
		IR2U_CalculateSizeDist()
	elseif(stringmatch(Model,"Porods law"))	
		IR2U_CalculatePorodsLaw()
	elseif(stringmatch(Model,"Branched mass fractal"))	
		IR2U_CalculateBranchedMassFr()
	ENDIF
	
end

//***********************************************************
//***********************************************************
//***********************************************************

Function IR2U_SetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
			if(stringMatch(sva.CtrlName,"InvariantUserContrast"))
				IR2U_CalculateInvariantVals()
			endif
			if(stringMatch(sva.CtrlName,"Porod_Contrast"))
				IR2U_CalculatePorodsLaw()
			endif
			if(stringMatch(sva.CtrlName,"SizeDist_MinSize"))
				IR2U_ReCalculateLogNormalSD()
			endif
			if(stringMatch(sva.CtrlName,"SizeDist_MaxSize"))
				IR2U_ReCalculateLogNormalSD()
			endif
			if(stringMatch(sva.CtrlName,"SizeDist_UserVolume"))
				IR2U_ReCalculateLogNormalSD()
			endif
		case 2: // Enter key
			if(stringMatch(sva.CtrlName,"InvariantUserContrast"))
				IR2U_CalculateInvariantVals()
			endif
			if(stringMatch(sva.CtrlName,"Porod_Contrast"))
				IR2U_CalculatePorodsLaw()
			endif
			if(stringMatch(sva.CtrlName,"SizeDist_MinSize"))
				IR2U_ReCalculateLogNormalSD()
			endif
			if(stringMatch(sva.CtrlName,"SizeDist_MaxSize"))
				IR2U_ReCalculateLogNormalSD()
			endif
			if(stringMatch(sva.CtrlName,"SizeDist_UserVolume"))
				IR2U_ReCalculateLogNormalSD()
			endif
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			break
	endswitch

	return 0
End
//***********************************************************
//***********************************************************
//***********************************************************
 Function IR2U_ReturnNoteNumValue(KeyWord)
 	string KeyWord
 	
 	variable LUKVal
 	SVAR DataFolderName= root:Packages:Irena_AnalUnifFit:DataFolderName
 	SVAR IntensityWaveName = root:Packages:Irena_AnalUnifFit:IntensityWaveName
 	
 	Wave/Z LkpWv=$(DataFolderName+IntensityWaveName)
 	if(!WaveExists(LkpWv))
 		return NaN
 	endif
 	
 	LUKVal = NumberByKey(KeyWord, note(LkpWv)  , "=",";")
 	return LUKVal
 	
 end
 //***********************************************************
//***********************************************************
//***********************************************************
 Function/S IR2U_ReturnNoteStrValue(KeyWord)
 	string KeyWord
 	
 	string LUKVal
 	SVAR DataFolderName= root:Packages:Irena_AnalUnifFit:DataFolderName
 	SVAR IntensityWaveName = root:Packages:Irena_AnalUnifFit:IntensityWaveName
 	
 	Wave/Z LkpWv=$(DataFolderName+IntensityWaveName)
 	if(!WaveExists(LkpWv))
 		return ""
 	endif
 	
 	LUKVal = StringByKey(KeyWord, note(LkpWv)  , "=",";")
 	return LUKVal
 	
 end
  //***********************************************************
//***********************************************************
//***********************************************************
Function IR2U_ClearVariables()


	NVAR BrFract_G2=root:Packages:Irena_AnalUnifFit:BrFract_G2
	NVAR BrFract_Rg2=root:Packages:Irena_AnalUnifFit:BrFract_Rg2
	NVAR BrFract_B2=root:Packages:Irena_AnalUnifFit:BrFract_B2
	NVAR BrFract_P2=root:Packages:Irena_AnalUnifFit:BrFract_P2
	NVAR BrFract_G1=root:Packages:Irena_AnalUnifFit:BrFract_G1
	NVAR BrFract_Rg1=root:Packages:Irena_AnalUnifFit:BrFract_Rg1
	NVAR BrFract_B1=root:Packages:Irena_AnalUnifFit:BrFract_B1
	NVAR BrFract_P1=root:Packages:Irena_AnalUnifFit:BrFract_P1
	SVAR BrFract_ErrorMessage=root:Packages:Irena_AnalUnifFit:BrFract_ErrorMessage
	NVAR BrFract_dmin=root:Packages:Irena_AnalUnifFit:BrFract_dmin
	NVAR BrFract_c=root:Packages:Irena_AnalUnifFit:BrFract_c
	NVAR BrFract_z=root:Packages:Irena_AnalUnifFit:BrFract_z
	NVAR BrFract_fBr=root:Packages:Irena_AnalUnifFit:BrFract_fBr
	NVAR BrFract_fM=root:Packages:Irena_AnalUnifFit:BrFract_fM
		BrFract_G2 = 0
		BrFract_Rg2 = 0
		BrFract_B2 = 0
		BrFract_P2 = 0
		BrFract_G1 = 0
		BrFract_Rg1 = 0
		BrFract_B1 = 0
		BrFract_P1 = 0
		BrFract_ErrorMessage=""
		BrFract_dmin=0
		BrFract_c=0
		BrFract_z=0
		BrFract_fBr=0
		BrFract_fM=0

	NVAR Porod_Constant = root:Packages:Irena_AnalUnifFit:Porod_Constant
	NVAR Porod_SpecificSfcArea = root:Packages:Irena_AnalUnifFit:Porod_SpecificSfcArea
	SVAR Porod_ErrorMessage=root:Packages:Irena_AnalUnifFit:Porod_ErrorMessage
	NVAR Porod_PowerLawSlope=root:Packages:Irena_AnalUnifFit:Porod_PowerLawSlope
		Porod_Constant=0
		Porod_SpecificSfcArea =0
		Porod_ErrorMessage=""
		Porod_PowerLawSlope=0
		
	NVAR SizeDist_G1=root:Packages:Irena_AnalUnifFit:SizeDist_G1
	NVAR SizeDist_Rg1=root:Packages:Irena_AnalUnifFit:SizeDist_Rg1
	NVAR SizeDist_B1=root:Packages:Irena_AnalUnifFit:SizeDist_B1
	NVAR SizeDist_P1=root:Packages:Irena_AnalUnifFit:SizeDist_P1
	SVAR SizeDist_ErrorMessage=root:Packages:Irena_AnalUnifFit:SizeDist_ErrorMessage
	NVAR SizeDist_sigmag=root:Packages:Irena_AnalUnifFit:SizeDist_sigmag
	NVAR SizeDist_GeomMean=root:Packages:Irena_AnalUnifFit:SizeDist_GeomMean
	NVAR SizeDist_PDI=root:Packages:Irena_AnalUnifFit:SizeDist_PDI
	NVAR SizeDist_SuterMeanDiadp=root:Packages:Irena_AnalUnifFit:SizeDist_SuterMeanDiadp
			
			SizeDist_G1=0
			SizeDist_Rg1=0
			SizeDist_B1=0
			SizeDist_P1=0
			SizeDist_ErrorMessage =  " "
			SizeDist_sigmag = 0
			SizeDist_GeomMean = 0
			SizeDist_PDI = 0
			SizeDist_SuterMeanDiadp = 0
		
	NVAR InvariantValue = root:Packages:Irena_AnalUnifFit:InvariantValue
	NVAR InvariantUserContrast = root:Packages:Irena_AnalUnifFit:InvariantUserContrast
	NVAR InvariantPhaseVolume = root:Packages:Irena_AnalUnifFit:InvariantPhaseVolume
			InvariantValue=0
			InvariantPhaseVolume=0
		
end

//***********************************************************
//***********************************************************
//***********************************************************

Function IR2U_ButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(stringMatch(ba.ctrlName,"SaveToHistory"))
				//here code to print results to history area
				IR2U_SaveResultsperUsrReq("History")
			endif
			if(stringMatch(ba.ctrlName,"SaveToLogbook"))
				//here code to print results to history area
				IR2U_SaveResultsperUsrReq("Logbook")
			endif
			if(stringMatch(ba.ctrlName,"PrintToGraph"))
				//here code to print results to history area
				IR2U_SaveResultsperUsrReq("Graph")
			endif
			if(stringMatch(ba.ctrlName,"CalcLogNormalDist"))
				//here code to print results to history area
				IR2U_CalcLogNormalDistribution()
			endif
			if(stringMatch(ba.ctrlName,"SaveDataSD"))
				//here code to print results to history area
				IR2U_SaveLogNormalDistData()
			endif

 
			break
	endswitch

	return 0
End

//***********************************************************
//***********************************************************
//***********************************************************

Function  IR2U_SaveLogNormalDistData()

//	DoAlert 0, "IR2U_SaveLogNormalDistData is not yet finished"
	string OldDf=getDataFolder(1)
	setDataFolder root:Packages:Irena_AnalUnifFit
	Wave RadiusWave=root:Packages:Irena_AnalUnifFit:RadiusWave
	Wave SizeVolDistribution=root:Packages:Irena_AnalUnifFit:SizeVolDistribution
	Wave SizeNumDistribution=root:Packages:Irena_AnalUnifFit:SizeNumDistribution
	
	NVAR UseCurrentResults=root:Packages:Irena_AnalUnifFit:CurrentResults
	NVAR UseStoredResults=root:Packages:Irena_AnalUnifFit:StoredResults

	if(UseStoredResults)
		SVAR DataFolderName = root:Packages:Irena_AnalUnifFit:DataFolderName
		SVAR IntensityWaveName = root:Packages:Irena_AnalUnifFit:IntensityWaveName
		SVAR QWavename = root:Packages:Irena_AnalUnifFit:QWavename
		SVAR ErrorWaveName = root:Packages:Irena_AnalUnifFit:ErrorWaveName	
	else
		SVAR DataFolderName = root:Packages:Irena_UnifFit:DataFolderName
		SVAR IntensityWaveName = root:Packages:Irena_UnifFit:IntensityWaveName
		SVAR QWavename = root:Packages:Irena_UnifFit:QWavename
		SVAR ErrorWaveName = root:Packages:Irena_UnifFit:ErrorWaveName	
	endif

	SVAR ListOfVariables = root:Packages:Irena_AnalUnifFit:ListOfVariables
	SVAR ListOfStrings = root:Packages:Irena_AnalUnifFit:ListOfStrings
	//create new lists to add to wave notes... 
	//OldWavenote
	string OldWvNote=note($(DataFolderName+IntensityWaveName))
	String NewNote=""
	string ListOfSVars=ListOfStrings
	ListOfSVars=GrepList(ListOfSVars,"Porod_*" ,1, ";")
	ListOfSVars=GrepList(ListOfSVars,"BrFract_*" ,1, ";")
	ListOfSVars=GrepList(ListOfSVars,"Invariant*" ,1, ";")	
	variable i
	For(i=0;i<ItemsInList(ListOfSVars);i+=1)
		SVAR tempstr=$(stringFromList(i,ListOfSVars))
		NewNote+=stringFromList(i,ListOfSVars)+"="+tempstr+";"
	endfor
	ListOfSVars=ListOfVariables
	ListOfSVars=GrepList(ListOfSVars,"Porod_*" ,1, ";")
	ListOfSVars=GrepList(ListOfSVars,"BrFract_*" ,1, ";")
	ListOfSVars=GrepList(ListOfSVars,"Invariant*" ,1, ";")	
	For(i=0;i<ItemsInList(ListOfSVars);i+=1)
		NVAR tempvar=$(stringFromList(i,ListOfSVars))
		NewNote+=stringFromList(i,ListOfSVars)+"="+num2str(tempvar)+";"
	endfor
	string FinalNote=OldWvNote+NewNote


	string UsersComment
	UsersComment="Result from Unified Size Distribution Eval. "+date()+"  "+time()

	Prompt UsersComment, "Modify comment to be saved with these results"
	DoPrompt "Need input for saving data", UsersComment
	if (V_Flag)
		abort
	endif

	setDataFolder $(DataFolderName)
	string tempname 
	variable ii=0
	For(ii=0;ii<1000;ii+=1)
		tempname="UnifSizeDistRadius_"+num2str(ii)
		if (checkname(tempname,1)==0)
			break
		endif
	endfor

	Wave RadiusWave=root:Packages:Irena_AnalUnifFit:RadiusWave
	Wave SizeVolDistribution=root:Packages:Irena_AnalUnifFit:SizeVolDistribution
	Wave SizeNumDistribution=root:Packages:Irena_AnalUnifFit:SizeNumDistribution


	Duplicate RadiusWave, $("UnifSizeDistRadius_"+num2str(ii))
	Duplicate SizeVolDistribution, $("UnifSizeDistVolumeDist_"+num2str(ii))
	Duplicate SizeNumDistribution, $("UnifSizeDistNumberDist_"+num2str(ii))
	
	Wave tempWv=$("UnifSizeDistRadius_"+num2str(ii))
	note tempWv, FinalNote
	Wave tempWv=$("UnifSizeDistVolumeDist_"+num2str(ii))
	note tempWv, FinalNote
	Wave tempWv=$("UnifSizeDistNumberDist_"+num2str(ii))
	note tempWv, FinalNote

	print "\r******\rSaved Unified size analysis data to : "+DataFolderName +" \r  waves : \r"+"UnifSizeDistRadius_"+num2str(ii) +"\r"+"UnifSizeDistVolumeDist_"+num2str(ii)+"\r"+"UnifSizeDistNumberDist_"+num2str(ii)
	setDataFolder oldDF

end

//***********************************************************
//***********************************************************
//***********************************************************
Function IR2U_SaveResultsperUsrReq(where)
	string where

	
	SVAR Model=root:Packages:Irena_AnalUnifFit:Model
	if(stringmatch(Model,"Invariant"))	
		IR2U_SaveInvariantResults(where)
	elseif(stringmatch(Model,"Size Distribution"))	
		IR2U_SaveSizeDistResults(where)
	elseif(stringmatch(Model,"Porods Law"))	
		IR2U_SavePorodsLawResults(where)
	elseif(stringmatch(Model,"Branched mass fractal"))	
		IR2U_SaveMassFractalResults(where)
	ENDIF


end


//***********************************************************
//***********************************************************
//***********************************************************
Function IR2U_SavePorodsLawResults(where)
	string where

	NVAR SelectedLevel = root:Packages:Irena_AnalUnifFit:SelectedLevel

	NVAR Porod_Constant = root:Packages:Irena_AnalUnifFit:Porod_Constant
	NVAR Porod_SpecificSfcArea = root:Packages:Irena_AnalUnifFit:Porod_SpecificSfcArea
	NVAR Porod_Contrast = root:Packages:Irena_AnalUnifFit:Porod_Contrast
	SVAR Porod_ErrorMessage=root:Packages:Irena_AnalUnifFit:Porod_ErrorMessage
	NVAR Porod_PowerLawSlope=root:Packages:Irena_AnalUnifFit:Porod_PowerLawSlope

	NVAR UseCurrentResults=root:Packages:Irena_AnalUnifFit:CurrentResults
	NVAR UseStoredResults=root:Packages:Irena_AnalUnifFit:StoredResults
	
	//avoid printinga garbage, bail out if no sensible data selected...
	if(SelectedLevel<1)
		abort
	endif

	string DataFName="", DataIName="",DataQname="",DataEName="", UserName="", AnalysisComentsAndTime=""
	if(UseCurrentResults)
		SVAR DataFolderName = root:Packages:Irena_UnifFit:DataFolderName
		SVAR IntensityWaveName = root:Packages:Irena_UnifFit:IntensityWaveName
		SVAR QWavename = root:Packages:Irena_UnifFit:QWavename
		SVAR ErrorWaveName = root:Packages:Irena_UnifFit:ErrorWaveName
		DataFName=DataFolderName
		DataIName=IntensityWaveName
		DataQname=QWavename
		DataEName=ErrorWaveName
		Wave IntWv=root:Packages:Irena_UnifFit:OriginalIntensity
		UserName=stringBykey("UserSampleName",note(IntWv),"=",";")
		AnalysisComentsAndTime = "Using data in Unified fit tool, analyzed on "+date()+" at "+time()
	else
	 	SVAR DataFolderName= root:Packages:Irena_AnalUnifFit:DataFolderName
	 	SVAR IntensityWaveName = root:Packages:Irena_AnalUnifFit:IntensityWaveName
		SVAR QWavename = root:Packages:Irena_AnalUnifFit:QWavename
		SVAR ErrorWaveName = root:Packages:Irena_AnalUnifFit:ErrorWaveName
		DataFName=DataFolderName
		DataIName=IntensityWaveName
		DataQname=QWavename
		DataEName=ErrorWaveName
		UserName=IR2U_ReturnNoteStrValue("UserSampleName")
		AnalysisComentsAndTime ="Analyzed using "+IR2U_ReturnNoteStrValue("UsersComment")
	endif
	
	if(stringMatch(where,"History"))
		Print " "
		Print "******************   Results for Porods law analysis from Unified fit ***************************"
		Print "     User Data Name : "+UserName
		Print "     Date/time : "+AnalysisComentsAndTime
		Print "     Folder name : "+DataFName
		Print "     Intensity name : "+DataIName
		Print "     Q vector name : "+DataQname
		Print "     Error name : "+DataEName
		Print "  "
		Print "     Selected level : "+num2str(SelectedLevel)
		if(strLen(Porod_ErrorMessage)>3)
			Print "     Error: "+Porod_ErrorMessage
		else
			Print "     Porods Constant [cm^-1 A^-4]: "+num2str(Porod_Constant)
			Print "     Contrast [10^20 cm^-4]: "+num2str(Porod_Contrast)
			Print "     Power law slope (~ 4) : " + num2str(Porod_PowerLawSlope)
			Print "     Specific surface area [cm^2/cm^3] : " + num2str(Porod_SpecificSfcArea)
		endif
		print "******************************************************************************************************"
		print " "


	elseif(stringMatch(where,"Logbook"))
		IR1_CreateLoggbook()
		IR1_PullUpLoggbook()
		IR1L_AppendAnyText( " ")
		IR1L_AppendAnyText( "******************   Results for Size dsitribution analysis from Unified fit ***************************")
		IR1L_AppendAnyText("     User Data Name : "+UserName)
		IR1L_AppendAnyText("     Date/time : "+AnalysisComentsAndTime)
		IR1L_AppendAnyText("     Folder name : "+DataFName)
		IR1L_AppendAnyText("     Intensity name : "+DataIName)
		IR1L_AppendAnyText( "     Q vector name : "+DataQname)
		IR1L_AppendAnyText("     Error name : "+DataEName)
		IR1L_AppendAnyText("  ")
		IR1L_AppendAnyText( "     Selected level : \t"+num2str(SelectedLevel))
		if(strLen(Porod_ErrorMessage)>3)
			IR1L_AppendAnyText( "     Error: "+Porod_ErrorMessage)
		else
			IR1L_AppendAnyText( "     Porods Constant [cm^-1 A^-4]: \t"+num2str(Porod_Constant))
			IR1L_AppendAnyText( "     Contrast [10^20 cm^-4]: \t"+num2str(Porod_Contrast))
			IR1L_AppendAnyText( "     Power law slope (~ 4) : \t" + num2str(Porod_PowerLawSlope))
			IR1L_AppendAnyText( "     Specific surface area [cm^2/cm^3] : \t" + num2str(Porod_SpecificSfcArea))
		endif
		IR1L_AppendAnyText("******************************************************************************************************")
		IR1L_AppendAnyText("  ")
	elseif(stringmatch(where,"Graph"))
		string GraphName=""
		if(UseCurrentResults)
			GraphName="IR1_LogLogPlotU"
		else
			GraphName=WinName(0,1)
		endif
		string NewTextBoxStr="\\F"+IR2C_LkUpDfltStr("FontType")+"\\Z"+IR2C_LkUpDfltVar("LegendSize")
		NewTextBoxStr+= "Size dsitribution analysis using Unified fit results\r"
		if(strlen(UserName)>0)
			NewTextBoxStr+= "User Data Name : "+UserName+" \r"
		else
			NewTextBoxStr+= "Folder name : "+DataFName+" \r"
		endif
		NewTextBoxStr+= "Selected level : "+num2str(SelectedLevel)+" \r"

		if(strLen(Porod_ErrorMessage)>3)
			NewTextBoxStr+=  "     Error: "+Porod_ErrorMessage+" \r"
		else
			NewTextBoxStr+=  "     Porods Constant [cm^-1 A^-4]: "+num2str(Porod_Constant)+" \r"
			NewTextBoxStr+=  "     Contrast [10^20 cm^-4]: "+num2str(Porod_Contrast)+" \r"
			NewTextBoxStr+=  "     Power law slope (~ 4) : " + num2str(Porod_PowerLawSlope)+" \r"
			NewTextBoxStr+=  "     Specific surface area [cm^2/cm^3] : " + num2str(Porod_SpecificSfcArea)+" \r"
		endif
		string AnotList=AnnotationList(GraphName)
		variable i
		For(i=0;i<100;i+=1)
			if(!stringMatch(AnotList,"*UnifiedAnalysis"+num2str(SelectedLevel)+"_"+num2str(i)+"*"))
				break
			endif
		endfor
		TextBox/C/W=$(GraphName)/N=$("UnifiedAnalysis"+num2str(SelectedLevel)+"_"+num2str(i))/F=0/A=MC NewTextBoxStr
		
	endif
	
end

//***********************************************************
//***********************************************************
//***********************************************************
Function IR2U_SaveSizeDistResults(where)
	string where

	NVAR SelectedLevel = root:Packages:Irena_AnalUnifFit:SelectedLevel

	NVAR SizeDist_G1=root:Packages:Irena_AnalUnifFit:SizeDist_G1
	NVAR SizeDist_Rg1=root:Packages:Irena_AnalUnifFit:SizeDist_Rg1
	NVAR SizeDist_B1=root:Packages:Irena_AnalUnifFit:SizeDist_B1
	NVAR SizeDist_P1=root:Packages:Irena_AnalUnifFit:SizeDist_P1
	SVAR SizeDist_ErrorMessage=root:Packages:Irena_AnalUnifFit:SizeDist_ErrorMessage
	SVAR SizeDist_Reference=root:Packages:Irena_AnalUnifFit:SizeDist_Reference
	NVAR SizeDist_sigmag=root:Packages:Irena_AnalUnifFit:SizeDist_sigmag
	NVAR SizeDist_GeomMean=root:Packages:Irena_AnalUnifFit:SizeDist_GeomMean
	NVAR SizeDist_PDI=root:Packages:Irena_AnalUnifFit:SizeDist_PDI
	NVAR SizeDist_SuterMeanDiadp=root:Packages:Irena_AnalUnifFit:SizeDist_SuterMeanDiadp

	NVAR UseCurrentResults=root:Packages:Irena_AnalUnifFit:CurrentResults
	NVAR UseStoredResults=root:Packages:Irena_AnalUnifFit:StoredResults
	
	//avoid printinga garbage, bail out if no sensible data selected...
	if(SelectedLevel<1)
		abort
	endif

	string DataFName="", DataIName="",DataQname="",DataEName="", UserName="", AnalysisComentsAndTime=""
	if(UseCurrentResults)
		SVAR DataFolderName = root:Packages:Irena_UnifFit:DataFolderName
		SVAR IntensityWaveName = root:Packages:Irena_UnifFit:IntensityWaveName
		SVAR QWavename = root:Packages:Irena_UnifFit:QWavename
		SVAR ErrorWaveName = root:Packages:Irena_UnifFit:ErrorWaveName
		DataFName=DataFolderName
		DataIName=IntensityWaveName
		DataQname=QWavename
		DataEName=ErrorWaveName
		Wave IntWv=root:Packages:Irena_UnifFit:OriginalIntensity
		UserName=stringBykey("UserSampleName",note(IntWv),"=",";")
		AnalysisComentsAndTime = "Using data in Unified fit tool, analyzed on "+date()+" at "+time()
	else
	 	SVAR DataFolderName= root:Packages:Irena_AnalUnifFit:DataFolderName
	 	SVAR IntensityWaveName = root:Packages:Irena_AnalUnifFit:IntensityWaveName
		SVAR QWavename = root:Packages:Irena_AnalUnifFit:QWavename
		SVAR ErrorWaveName = root:Packages:Irena_AnalUnifFit:ErrorWaveName
		DataFName=DataFolderName
		DataIName=IntensityWaveName
		DataQname=QWavename
		DataEName=ErrorWaveName
		UserName=IR2U_ReturnNoteStrValue("UserSampleName")
		AnalysisComentsAndTime ="Analyzed using "+IR2U_ReturnNoteStrValue("UsersComment")
	endif
	
	if(stringMatch(where,"History"))
		Print " "
		Print "******************   Results for Size dsitribution analysis from Unified fit ***************************"
		Print "     User Data Name : "+UserName
		Print "     Date/time : "+AnalysisComentsAndTime
		Print "     Folder name : "+DataFName
		Print "     Intensity name : "+DataIName
		Print "     Q vector name : "+DataQname
		Print "     Error name : "+DataEName
		Print "  "
		Print "     Selected level : "+num2str(SelectedLevel)
		if(strLen(SizeDist_ErrorMessage)>3)
			Print "     Error: "+SizeDist_ErrorMessage
		else
			Print "     G/Rg/B/P    "+num2str(SizeDist_G1)+"\t"+num2str(SizeDist_Rg1)+"\t"+num2str(SizeDist_B1)+"\t"+num2str(SizeDist_P1)
			Print "     Geom. sigma : "+num2str(SizeDist_sigmag)
			Print "     Geom mean : "+num2str(SizeDist_GeomMean)
			Print "     Polydispersity index : " + num2str(SizeDist_PDI)
			Print "     Sauter mean diameter : " + num2str(SizeDist_SuterMeanDiadp)
			Print "     Reference : " + SizeDist_Reference		
		endif
		print "******************************************************************************************************"
		print " "


	elseif(stringMatch(where,"Logbook"))
		IR1_CreateLoggbook()
		IR1_PullUpLoggbook()
		IR1L_AppendAnyText( " ")
		IR1L_AppendAnyText( "******************   Results for Size dsitribution analysis from Unified fit ***************************")
		IR1L_AppendAnyText("     User Data Name : "+UserName)
		IR1L_AppendAnyText("     Date/time : "+AnalysisComentsAndTime)
		IR1L_AppendAnyText("     Folder name : "+DataFName)
		IR1L_AppendAnyText("     Intensity name : "+DataIName)
		IR1L_AppendAnyText( "     Q vector name : "+DataQname)
		IR1L_AppendAnyText("     Error name : "+DataEName)
		IR1L_AppendAnyText("  ")
		IR1L_AppendAnyText( "     Selected level : "+num2str(SelectedLevel))
		if(strLen(SizeDist_ErrorMessage)>3)
			IR1L_AppendAnyText( "     Error: "+SizeDist_ErrorMessage)
		else
			IR1L_AppendAnyText( "     G/Rg/B/P    "+num2str(SizeDist_G1)+"\t"+num2str(SizeDist_Rg1)+"\t"+num2str(SizeDist_B1)+"\t"+num2str(SizeDist_P1))
			IR1L_AppendAnyText( "     Geom. sigma : "+num2str(SizeDist_sigmag))
			IR1L_AppendAnyText( "     Geom mean : "+num2str(SizeDist_GeomMean))
			IR1L_AppendAnyText( "     Polydispersity index : " + num2str(SizeDist_PDI))
			IR1L_AppendAnyText( "     Sauter mean diameter : " + num2str(SizeDist_SuterMeanDiadp))
			IR1L_AppendAnyText( "     Reference : " + SizeDist_Reference		)
		endif
		IR1L_AppendAnyText("******************************************************************************************************")
		IR1L_AppendAnyText("  ")
	elseif(stringmatch(where,"Graph"))
		string GraphName=""
		if(UseCurrentResults)
			GraphName="IR1_LogLogPlotU"
		else
			GraphName=WinName(0,1)
		endif
		string NewTextBoxStr="\\F"+IR2C_LkUpDfltStr("FontType")+"\\Z"+IR2C_LkUpDfltVar("LegendSize")
		NewTextBoxStr+= "Size dsitribution analysis using Unified fit results\r"
		if(strlen(UserName)>0)
			NewTextBoxStr+= "User Data Name : "+UserName+" \r"
		else
			NewTextBoxStr+= "Folder name : "+DataFName+" \r"
		endif
		NewTextBoxStr+= "Selected level : "+num2str(SelectedLevel)+" \r"
		if(strLen(SizeDist_ErrorMessage)>3)
			NewTextBoxStr+= "Error: "+SizeDist_ErrorMessage+" \r"
		else
			NewTextBoxStr+= "G/Rg/B/P    "+num2str(SizeDist_G1)+"\t"+num2str(SizeDist_Rg1)+"\t"+num2str(SizeDist_B1)+"\t"+num2str(SizeDist_P1)+" \r"
			NewTextBoxStr+= "Geom. sigma : "+num2str(SizeDist_sigmag)+" \r"
			NewTextBoxStr+= "Geom mean : "+num2str(SizeDist_GeomMean)+" \r"
			NewTextBoxStr+= "Polydispersity index : " + num2str(SizeDist_PDI)+" \r"
			NewTextBoxStr+= "Sauter mean diameter : " + num2str(SizeDist_SuterMeanDiadp)+" \r"
			NewTextBoxStr+= "Reference : " + SizeDist_Reference
		endif

		string AnotList=AnnotationList(GraphName)
		variable i
		For(i=0;i<100;i+=1)
			if(!stringMatch(AnotList,"*UnifiedAnalysis"+num2str(SelectedLevel)+"_"+num2str(i)+"*"))
				break
			endif
		endfor
		TextBox/C/W=$(GraphName)/N=$("UnifiedAnalysis"+num2str(SelectedLevel)+"_"+num2str(i))/F=0/A=MC NewTextBoxStr
		
	endif
	
end
//***********************************************************
//***********************************************************
//***********************************************************
Function IR2U_SaveInvariantResults(where)
	string where

	NVAR SelectedLevel = root:Packages:Irena_AnalUnifFit:SelectedLevel
	NVAR InvariantValue = root:Packages:Irena_AnalUnifFit:InvariantValue
	NVAR InvariantUserContrast = root:Packages:Irena_AnalUnifFit:InvariantUserContrast
	NVAR InvariantPhaseVolume = root:Packages:Irena_AnalUnifFit:InvariantPhaseVolume

	NVAR UseCurrentResults=root:Packages:Irena_AnalUnifFit:CurrentResults
	NVAR UseStoredResults=root:Packages:Irena_AnalUnifFit:StoredResults
	
	//avoid printinga garbage, bail out if no sensible data selected...
	if(SelectedLevel<1)
		abort
	endif

	string DataFName="", DataIName="",DataQname="",DataEName="", UserName="", AnalysisComentsAndTime=""
	if(UseCurrentResults)
		SVAR DataFolderName = root:Packages:Irena_UnifFit:DataFolderName
		SVAR IntensityWaveName = root:Packages:Irena_UnifFit:IntensityWaveName
		SVAR QWavename = root:Packages:Irena_UnifFit:QWavename
		SVAR ErrorWaveName = root:Packages:Irena_UnifFit:ErrorWaveName
		DataFName=DataFolderName
		DataIName=IntensityWaveName
		DataQname=QWavename
		DataEName=ErrorWaveName
		Wave IntWv=root:Packages:Irena_UnifFit:OriginalIntensity
		UserName=stringBykey("UserSampleName",note(IntWv),"=",";")
		AnalysisComentsAndTime = "Using data in Unified fit tool, analyzed on "+date()+" at "+time()
	else
	 	SVAR DataFolderName= root:Packages:Irena_AnalUnifFit:DataFolderName
	 	SVAR IntensityWaveName = root:Packages:Irena_AnalUnifFit:IntensityWaveName
		SVAR QWavename = root:Packages:Irena_AnalUnifFit:QWavename
		SVAR ErrorWaveName = root:Packages:Irena_AnalUnifFit:ErrorWaveName
		DataFName=DataFolderName
		DataIName=IntensityWaveName
		DataQname=QWavename
		DataEName=ErrorWaveName
		UserName=IR2U_ReturnNoteStrValue("UserSampleName")
		AnalysisComentsAndTime ="Analyzed using "+IR2U_ReturnNoteStrValue("UsersComment")
	endif
	
	if(stringMatch(where,"History"))
		Print " "
		Print "******************   Results for analysis of Invariant from Unified fit ***************************"
		Print "     User Data Name : "+UserName
		Print "     Date/time : "+AnalysisComentsAndTime
		Print "     Folder name : "+DataFName
		Print "     Intensity name : "+DataIName
		Print "     Q vector name : "+DataQname
		Print "     Error name : "+DataEName
		Print "  "
		Print "     Selected level : "+num2str(SelectedLevel)
		Print "     Phase Contrast [10^20 cm^-4] : "+num2str(InvariantUserContrast)
		Print "     Invariant [cm^-4] : "+num2str(InvariantValue)
		Print "     Phase volume [fraction] : " + num2str(InvariantPhaseVolume)
		print "******************************************************************************************************"
		print " "
	elseif(stringMatch(where,"Logbook"))
		IR1_CreateLoggbook()
		IR1_PullUpLoggbook()
		IR1L_AppendAnyText( " ")
		IR1L_AppendAnyText( "******************   Results for analysis of Invariant from Unified fit ***************************")
		IR1L_AppendAnyText("     User Data Name : "+UserName)
		IR1L_AppendAnyText("     Date/time : "+AnalysisComentsAndTime)
		IR1L_AppendAnyText("     Folder name : "+DataFName)
		IR1L_AppendAnyText("     Intensity name : "+DataIName)
		IR1L_AppendAnyText( "     Q vector name : "+DataQname)
		IR1L_AppendAnyText("     Error name : "+DataEName)
		IR1L_AppendAnyText("  ")
		IR1L_AppendAnyText( "     Selected level : "+num2str(SelectedLevel))
		IR1L_AppendAnyText("     Phase Contrast [10^20 cm^-4] : "+num2str(InvariantUserContrast))
		IR1L_AppendAnyText("     Invariant [cm^-4] : "+num2str(InvariantValue))
		IR1L_AppendAnyText("     Phase volume [fraction] : " + num2str(InvariantPhaseVolume))
		IR1L_AppendAnyText("******************************************************************************************************")
		IR1L_AppendAnyText("  ")
	elseif(stringmatch(where,"Graph"))
		string GraphName=""
		if(UseCurrentResults)
			GraphName="IR1_LogLogPlotU"
		else
			GraphName=WinName(0,1)
		endif
		string NewTextBoxStr="\\F"+IR2C_LkUpDfltStr("FontType")+"\\Z"+IR2C_LkUpDfltVar("LegendSize")
		NewTextBoxStr+= "Invariant analysis using Unified fit results\r"
		if(strlen(UserName)>0)
			NewTextBoxStr+= "User Data Name : "+UserName+" \r"
		else
			NewTextBoxStr+= "Folder name : "+DataFName+" \r"
		endif
		NewTextBoxStr+= "Selected level : "+num2str(SelectedLevel)+" \r"
		NewTextBoxStr+= "Phase Contrast [10^20 cm^-4] : "+num2str(InvariantUserContrast)+" \r"
		NewTextBoxStr+= "Invariant [cm^-4] : "+num2str(InvariantValue)+" \r"
		NewTextBoxStr+= "Phase volume [fraction] : " + num2str(InvariantPhaseVolume)+" \r"
		string AnotList=AnnotationList(GraphName)
		variable i
		For(i=0;i<100;i+=1)
			if(!stringMatch(AnotList,"*UnifiedAnalysis"+num2str(SelectedLevel)+"_"+num2str(i)+"*"))
				break
			endif
		endfor
		TextBox/C/W=$(GraphName)/N=$("UnifiedAnalysis"+num2str(SelectedLevel)+"_"+num2str(i))/F=0/A=MC NewTextBoxStr
		
	endif
	
end
//***********************************************************
//***********************************************************
//***********************************************************
Function IR2U_SaveMassFractalResults(where)
	string where

	NVAR SelectedLevel = root:Packages:Irena_AnalUnifFit:SelectedLevel
	NVAR InvariantValue = root:Packages:Irena_AnalUnifFit:InvariantValue

	NVAR BrFract_G2=root:Packages:Irena_AnalUnifFit:BrFract_G2
	NVAR BrFract_Rg2=root:Packages:Irena_AnalUnifFit:BrFract_Rg2
	NVAR BrFract_B2=root:Packages:Irena_AnalUnifFit:BrFract_B2
	NVAR BrFract_P2=root:Packages:Irena_AnalUnifFit:BrFract_P2
	NVAR BrFract_G1=root:Packages:Irena_AnalUnifFit:BrFract_G1
	NVAR BrFract_Rg1=root:Packages:Irena_AnalUnifFit:BrFract_Rg1
	NVAR BrFract_B1=root:Packages:Irena_AnalUnifFit:BrFract_B1
	NVAR BrFract_P1=root:Packages:Irena_AnalUnifFit:BrFract_P1
	SVAR BrFract_ErrorMessage=root:Packages:Irena_AnalUnifFit:BrFract_ErrorMessage
	SVAR BrFract_Reference1 = root:Packages:Irena_AnalUnifFit:BrFract_Reference1
	SVAR BrFract_Reference2 = root:Packages:Irena_AnalUnifFit:BrFract_Reference2
	NVAR BrFract_dmin=root:Packages:Irena_AnalUnifFit:BrFract_dmin
	NVAR BrFract_c=root:Packages:Irena_AnalUnifFit:BrFract_c
	NVAR BrFract_z=root:Packages:Irena_AnalUnifFit:BrFract_z
	NVAR BrFract_fBr=root:Packages:Irena_AnalUnifFit:BrFract_fBr
	NVAR BrFract_fM=root:Packages:Irena_AnalUnifFit:BrFract_fM


	NVAR UseCurrentResults=root:Packages:Irena_AnalUnifFit:CurrentResults
	NVAR UseStoredResults=root:Packages:Irena_AnalUnifFit:StoredResults
	
	//avoid printinga garbage, bail out if no sensible data selected...
	if(SelectedLevel<2)
		abort
	endif

	string DataFName="", DataIName="",DataQname="",DataEName="", UserName="", AnalysisComentsAndTime=""
	if(UseCurrentResults)
		SVAR DataFolderName = root:Packages:Irena_UnifFit:DataFolderName
		SVAR IntensityWaveName = root:Packages:Irena_UnifFit:IntensityWaveName
		SVAR QWavename = root:Packages:Irena_UnifFit:QWavename
		SVAR ErrorWaveName = root:Packages:Irena_UnifFit:ErrorWaveName
		DataFName=DataFolderName
		DataIName=IntensityWaveName
		DataQname=QWavename
		DataEName=ErrorWaveName
		Wave IntWv=root:Packages:Irena_UnifFit:OriginalIntensity
		UserName=stringBykey("UserSampleName",note(IntWv),"=",";")
		AnalysisComentsAndTime = "Using data in Unified fit tool, analyzed on "+date()+" at "+time()
	else
	 	SVAR DataFolderName= root:Packages:Irena_AnalUnifFit:DataFolderName
	 	SVAR IntensityWaveName = root:Packages:Irena_AnalUnifFit:IntensityWaveName
		SVAR QWavename = root:Packages:Irena_AnalUnifFit:QWavename
		SVAR ErrorWaveName = root:Packages:Irena_AnalUnifFit:ErrorWaveName
		DataFName=DataFolderName
		DataIName=IntensityWaveName
		DataQname=QWavename
		DataEName=ErrorWaveName
		UserName=IR2U_ReturnNoteStrValue("UserSampleName")
		AnalysisComentsAndTime ="Analyzed using "+IR2U_ReturnNoteStrValue("UsersComment")
	endif
	
	if(stringMatch(where,"History"))
		Print " "
		Print "***********   Results for analysis of Branched Mass Fractal from Unified fit ****************"
		Print "     User Data Name : "+UserName
		Print "     Date/time : "+AnalysisComentsAndTime
		Print "     Folder name : "+DataFName
		Print "     Intensity name : "+DataIName
		Print "     Q vector name : "+DataQname
		Print "     Error name : "+DataEName
		Print "  "
		Print "     Selected levels : "+num2str(SelectedLevel)+"/"+num2str(SelectedLevel-1)
		Print "     Level 2 : G/Rg/B/P    "+num2str(BrFract_G2)+"\t"+num2str(BrFract_Rg2)+"\t"+num2str(BrFract_B2)+"\t"+num2str(BrFract_P2)
		Print "     Level 1 : G/Rg/B/P    "+num2str(BrFract_G1)+"\t"+num2str(BrFract_Rg1)+"\t"+num2str(BrFract_B1)+"\t"+num2str(BrFract_P1)
		if(strlen(BrFract_ErrorMessage)>3)
			Print "     Error message : "+BrFract_ErrorMessage
		else
			Print "     Results : " 
			Print "     dmin = \t" + num2str(BrFract_dmin)
			Print "     c      = \t" + num2str(BrFract_c)
			Print "     z      = \t" + num2str(BrFract_z)
			Print "     fBr    = \t" + num2str(BrFract_fBr)
			Print "     fM     = \t" + num2str(BrFract_fM)
			Print "     References : "+BrFract_Reference1+"\r"+BrFract_Reference2
		
		endif
		print "******************************************************************************************************"
		print " "


	elseif(stringMatch(where,"Logbook"))
		IR1_CreateLoggbook()
		IR1_PullUpLoggbook()
		IR1L_AppendAnyText( " ")
		IR1L_AppendAnyText( "***********   Results for analysis of Branched Mass Fractal from Unified fit ****************")
		IR1L_AppendAnyText("     User Data Name : "+UserName)
		IR1L_AppendAnyText("     Date/time : "+AnalysisComentsAndTime)
		IR1L_AppendAnyText("     Folder name : "+DataFName)
		IR1L_AppendAnyText("     Intensity name : "+DataIName)
		IR1L_AppendAnyText( "     Q vector name : "+DataQname)
		IR1L_AppendAnyText("     Error name : "+DataEName)
		IR1L_AppendAnyText("  ")
		IR1L_AppendAnyText( "     Selected levels : "+num2str(SelectedLevel)+"/"+num2str(SelectedLevel-1))
		IR1L_AppendAnyText( "     Level 2 : G/Rg/B/P    "+num2str(BrFract_G2)+"\t"+num2str(BrFract_Rg2)+"\t"+num2str(BrFract_B2)+"\t"+num2str(BrFract_P2))
		IR1L_AppendAnyText( "     Level 1 : G/Rg/B/P    "+num2str(BrFract_G1)+"\t"+num2str(BrFract_Rg1)+"\t"+num2str(BrFract_B1)+"\t"+num2str(BrFract_P1))
		if(strlen(BrFract_ErrorMessage)>3)
			IR1L_AppendAnyText( "     Error message : "+BrFract_ErrorMessage)
		else
			IR1L_AppendAnyText( "     Results : " )
			IR1L_AppendAnyText( "     dmin = \t" + num2str(BrFract_dmin))
			IR1L_AppendAnyText( "     c      = \t" + num2str(BrFract_c))
			IR1L_AppendAnyText( "     z      = \t" + num2str(BrFract_z))
			IR1L_AppendAnyText( "     fBr    = \t" + num2str(BrFract_fBr))
			IR1L_AppendAnyText( "     fM     = \t" + num2str(BrFract_fM))
			IR1L_AppendAnyText( "     References : "+BrFract_Reference1+"\r"+BrFract_Reference2)
		
		endif
		IR1L_AppendAnyText("******************************************************************************************************")
		IR1L_AppendAnyText("  ")
	elseif(stringmatch(where,"Graph"))
		string GraphName=""
		if(UseCurrentResults)
			GraphName="IR1_LogLogPlotU"
		else
			GraphName=WinName(0,1)
		endif
		string NewTextBoxStr="\\F"+IR2C_LkUpDfltStr("FontType")+"\\Z"+IR2C_LkUpDfltVar("LegendSize")
		NewTextBoxStr+= "Branched Mass Fractal analysis using Unified fit results\r"
		if(strlen(UserName)>0)
			NewTextBoxStr+= "User Data Name : "+UserName+" \r"
		else
			NewTextBoxStr+= "Folder name : "+DataFName+" \r"
		endif
		NewTextBoxStr+= "Selected levels : "+num2str(SelectedLevel)+"/"+num2str(SelectedLevel-1)+" \r"
		NewTextBoxStr+= "Level 2 : G/Rg/B/P    "+num2str(BrFract_G2)+"\t"+num2str(BrFract_Rg2)+"\t"+num2str(BrFract_B2)+"\t"+num2str(BrFract_P2)+" \r"
		NewTextBoxStr+= "Level 1 : G/Rg/B/P    "+num2str(BrFract_G1)+"\t"+num2str(BrFract_Rg1)+"\t"+num2str(BrFract_B1)+"\t"+num2str(BrFract_P1)+" \r"
		if(strlen(BrFract_ErrorMessage)>3)
			NewTextBoxStr+= "     Error message : "+BrFract_ErrorMessage
		else
			NewTextBoxStr+= "     Results : " +" \r"
			NewTextBoxStr+= "     dmin = \t" + num2str(BrFract_dmin)+" \r"
			NewTextBoxStr+= "     c      = \t" + num2str(BrFract_c)+" \r"
			NewTextBoxStr+= "     z      = \t" + num2str(BrFract_z)+" \r"
			NewTextBoxStr+= "     fBr    = \t" + num2str(BrFract_fBr)+" \r"
			NewTextBoxStr+= "     fM     = \t" + num2str(BrFract_fM)+" \r"
			NewTextBoxStr+= "     References : "+BrFract_Reference1+"\r"+BrFract_Reference2	
		endif

		string AnotList=AnnotationList(GraphName)
		variable i
		For(i=0;i<100;i+=1)
			if(!stringMatch(AnotList,"*UnifiedAnalysis"+num2str(SelectedLevel)+"_"+num2str(i)+"*"))
				break
			endif
		endfor
		TextBox/C/W=$(GraphName)/N=$("UnifiedAnalysis"+num2str(SelectedLevel)+"_"+num2str(i))/F=0/A=MC NewTextBoxStr
		
	endif
	
end
//***********************************************************
//***********************************************************
//***********************************************************

