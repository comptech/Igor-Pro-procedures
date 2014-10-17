#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 1.01

//January 2008. JIL. 
//First version of the Small-angle scattering package in version 2.25 of Irena package. Basic SA diffraction package with usual functionality. Mostly in manual. 
// January 13, 2008 added Rg and prefactor for Rg, changed to use basic one level of Unified fit for background.

//Comment to be able to remember...
// Common structures - peak d spacing ratios
// Lamellar  1: 2 : 3 : 4 : 5 : 6 : 7
// Hexagonally packed cylinders 1 : sqrt(3) : 2 : sqrt(7) : 3 : sqrt(12) : sqrt(13) : 4
// Primitive (simple cubic) 1 : sqrt(2) : sqrt(3) : 2 : sqrt(5) : sqrt(6) :sqrt(8) : 3
// BCC   1 : sqrt(2) : sqrt(3) : 2 : sqrt(5) : sqrt(6) : sqrt(7) : sqrt(8) : 3
//FCC    sqrt(3) : 2 : sqrt(8) : sqrt (11) : sqrt(12) : 4 : sqrt(19)
// Hex close packed  sqrt(32) : 6 : sqrt(41) : sqrt(68) : sqrt(96) : sqrt(113)
// double diamond   sqrt(2) : sqrt(3) : 2 : sqrt(6) :sqrt(8) : 3 : sqrt(10) : sqrt(11)
//Ialpha(-3)d		sqrt(3) : 2 : sqrt(7) :sqrt(8) : sqrt(10) : sqrt(11) : sqrt(12)
//Pm3m		sqrt(2) : 2 : sqrt(5) : sqrt(6) : sqrt(8) : sqrt(10) : sqrt(12)
// from Block copolymers: synthetic strategies, Physical properties and applications, Hadjichrististidis, Pispas, Floudas, Willey & sons, 2003, chapter 19, pg 347
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR2D_MainSmallAngleDiff()

	IN2G_CheckScreenSize("height",670)

	IR2D_InitializeSAD()
	
	DoWindow IR2D_ControlPanel
	if(V_Flag)
		DoWIndow /K IR2D_ControlPanel
	endif
	Execute("IR2D_ControlPanel()")


end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR2D_InitializeSAD()

	string oldDf=GetDataFolder(1)
	
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:Irena_SAD

	
	string/g ListOfVariables
	string/g ListOfStrings

	ListOfVariables="UseIndra2Data;UseQRSdata;UseSMRData;SlitLength;AutoRecalculate;UserCanceled;UseGeneticOptimization;DisplayPeaks;PeakSASScaling;"
	ListOfVariables+="UseGeneticOptimization;Oversample;ResultingChiSquared;UseLogX;UseLogY;AppendResiduals;AppendNormalizedResiduals;"
	ListOfVariables+="Background;FitBackground;BackgroundLowLimit;BackgroundHighLimit;"
	ListOfVariables+="PwrLawPref;FitPwrLawPref;PwrLawPrefLowLimit;PwrLawPrefHighLimit;"
	ListOfVariables+="PwrLawSlope;FitPwrLawSlope;PwrLawSlopeLowLimit;PwrLawSlopeHighLimit;"
	ListOfVariables+="RgPrefactor;FitRgPrefactor;RgPrefactorLowLimit;RgPrefactorHighLimit;"
	ListOfVariables+="Rg;FitRg;RgLowLimit;RgHighLimit;"

	ListOfVariables+="UsePeak1;UsePeak2;UsePeak3;UsePeak4;UsePeak5;UsePeak6;"

	ListOfVariables+="PeakDPosition1;PeakDPosition2;PeakDPosition3;PeakDPosition4;PeakDPosition5;PeakDPosition6;"
	ListOfVariables+="PeakPosition1;PeakPosition2;PeakPosition3;PeakPosition4;PeakPosition5;PeakPosition6;"
	ListOfVariables+="PeakFWHM1;PeakFWHM2;PeakFWHM3;PeakFWHM4;PeakFWHM5;PeakFWHM6;"
	ListOfVariables+="PeakIntgInt1;PeakIntgInt2;PeakIntgInt3;PeakIntgInt4;PeakIntgInt5;PeakIntgInt6;"

	ListOfVariables+="Peak1_Par1;FitPeak1_Par1;Peak1_Par1LowLimit;Peak1_Par1HighLimit;"
	ListOfVariables+="Peak1_Par2;FitPeak1_Par2;Peak1_Par2LowLimit;Peak1_Par2HighLimit;"
	ListOfVariables+="Peak1_Par3;FitPeak1_Par3;Peak1_Par3LowLimit;Peak1_Par3HighLimit;"
	ListOfVariables+="Peak1_Par4;FitPeak1_Par4;Peak1_Par4LowLimit;Peak1_Par4HighLimit;"
	ListOfVariables+="Peak1_LinkPar2;Peak1_LinkMultiplier;"

	ListOfVariables+="Peak2_Par1;FitPeak2_Par1;Peak2_Par1LowLimit;Peak2_Par1HighLimit;"
	ListOfVariables+="Peak2_Par2;FitPeak2_Par2;Peak2_Par2LowLimit;Peak2_Par2HighLimit;"
	ListOfVariables+="Peak2_Par3;FitPeak2_Par3;Peak2_Par3LowLimit;Peak2_Par3HighLimit;"
	ListOfVariables+="Peak2_Par4;FitPeak2_Par4;Peak2_Par4LowLimit;Peak2_Par4HighLimit;"
	ListOfVariables+="Peak2_LinkPar2;Peak2_LinkMultiplier;"

	ListOfVariables+="Peak3_Par1;FitPeak3_Par1;Peak3_Par1LowLimit;Peak3_Par1HighLimit;"
	ListOfVariables+="Peak3_Par2;FitPeak3_Par2;Peak3_Par2LowLimit;Peak3_Par2HighLimit;"
	ListOfVariables+="Peak3_Par3;FitPeak3_Par3;Peak3_Par3LowLimit;Peak3_Par3HighLimit;"
	ListOfVariables+="Peak3_Par4;FitPeak3_Par4;Peak3_Par4LowLimit;Peak3_Par4HighLimit;"
	ListOfVariables+="Peak3_LinkPar2;Peak3_LinkMultiplier;"

	ListOfVariables+="Peak4_Par1;FitPeak4_Par1;Peak4_Par1LowLimit;Peak4_Par1HighLimit;"
	ListOfVariables+="Peak4_Par2;FitPeak4_Par2;Peak4_Par2LowLimit;Peak4_Par2HighLimit;"
	ListOfVariables+="Peak4_Par3;FitPeak4_Par3;Peak4_Par3LowLimit;Peak4_Par3HighLimit;"
	ListOfVariables+="Peak4_Par4;FitPeak4_Par4;Peak4_Par4LowLimit;Peak4_Par4HighLimit;"
	ListOfVariables+="Peak4_LinkPar2;Peak4_LinkMultiplier;"

	ListOfVariables+="Peak5_Par1;FitPeak5_Par1;Peak5_Par1LowLimit;Peak5_Par1HighLimit;"
	ListOfVariables+="Peak5_Par2;FitPeak5_Par2;Peak5_Par2LowLimit;Peak5_Par2HighLimit;"
	ListOfVariables+="Peak5_Par4;FitPeak5_Par4;Peak5_Par4LowLimit;Peak5_Par4HighLimit;"
	ListOfVariables+="Peak5_Par3;FitPeak5_Par3;Peak5_Par3LowLimit;Peak5_Par3HighLimit;"
	ListOfVariables+="Peak5_LinkPar2;Peak5_LinkMultiplier;"

	ListOfVariables+="Peak6_Par1;FitPeak6_Par1;Peak6_Par1LowLimit;Peak6_Par1HighLimit;"
	ListOfVariables+="Peak6_Par2;FitPeak6_Par2;Peak6_Par2LowLimit;Peak6_Par2HighLimit;"
	ListOfVariables+="Peak6_Par3;FitPeak6_Par3;Peak6_Par3LowLimit;Peak6_Par3HighLimit;"
	ListOfVariables+="Peak6_Par4;FitPeak6_Par4;Peak6_Par4LowLimit;Peak6_Par4HighLimit;"
	ListOfVariables+="Peak6_LinkPar2;Peak6_LinkMultiplier;"

	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;ListOfKnownPeakShapes;"
	ListOfStrings+="Peak1_Function;Peak2_Function;Peak3_Function;Peak4_Function;Peak5_Function;Peak6_Function;"
	ListOfStrings+="Peak1_LinkedTo;Peak2_LinkedTo;Peak3_LinkedTo;Peak4_LinkedTo;Peak5_LinkedTo;Peak6_LinkedTo;"
	ListOfStrings+="PeakRelationship;"
	string/g ListOfKnownPeakRelationships	="---;Lamellar;HCP cylinders;Simple Cubic;BCC;FCC;HCP spheres;Doube Diamond;1a-3d;Pm-3n;"
	variable i
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	SVAR PeakRelationship
	if(strlen(PeakRelationship)<2)
		PeakRelationship="---"
	endif

	for(i=1;i<=6;i+=1)
		SVAR testStr=$("Peak"+num2str(i)+"_Function")
		if(strlen(testStr)<2)
			testStr="Gauss"
		endif
	endfor
	for(i=1;i<=6;i+=1)
		NVAR testPar1=$("Peak"+num2str(i)+"_Par1")
		if(testPar1==0)
			testPar1=1
		endif
		NVAR testPar1=$("Peak"+num2str(i)+"_LinkMultiplier")
		if(testPar1==0)
			testPar1=4
		endif
		NVAR testPar2=$("Peak"+num2str(i)+"_Par2")
		if(testPar2==0)
			testPar2=0.01
		endif
		NVAR testPar3=$("Peak"+num2str(i)+"_Par3")
		if(testPar3==0)
			testPar3=0.01
		endif
		NVAR testPar4=$("Peak"+num2str(i)+"_Par4")
		if(testPar4==0)
			testPar4=0.5
		endif
		NVAR testPar4LL=$("Peak"+num2str(i)+"_Par4LowLimit")
		testPar4LL=0
		NVAR testPar4HL=$("Peak"+num2str(i)+"_Par4HighLimit")
		testPar4HL=1
		SVAR testStr=$("Peak"+num2str(i)+"_LinkedTo")
		if(strlen(TestStr)<3)
			testStr="---"		
		endif
	endfor
	NVAR Rg
	NVAR RgPrefactor
	if(Rg==0)
		Rg=10^10
		RgPrefactor = 0
	endif
	NVAR PwrLawPref
	if(PwrLawPref==0)
		PwrLawPref=1
	endif
	NVAR PwrLawSlope
	if(PwrLawSlope==0)
		PwrLawSlope=4
	endif
	SVAR ListOfKnownPeakShapes
	ListOfKnownPeakShapes="Gauss;Lorenz;Pseudo-Voigt;Gumbel;Pearson_VII;Modif_Gauss;"
	
	setDataFolder OldDf
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Window IR2D_ControlPanel() 
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(2.25,43.25,390,690) as "Small angle diffraction panel"

	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup="r*:q*;"
	string EUserLookup="r*:s*;"
	IR2C_AddDataControls("Irena_SAD","IR2D_ControlPanel","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,1)

	SetDrawLayer UserBack
	SetDrawEnv fname= "Times New Roman", save
	SetDrawEnv fname= "Times New Roman",fsize= 22,fstyle= 3,textrgb= (0,0,52224)
	DrawText 50,23,"Small angle diffraction input panel"
	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
	DrawLine 16,181,339,181
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 18,49,"Data input"
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 20,209,"Model input"
	SetDrawEnv textrgb= (0,0,65280),fstyle= 1, fsize= 12
	DrawText 200,275,"Fit?:"
	SetDrawEnv textrgb= (0,0,65280),fstyle= 1, fsize= 12
	DrawText 230,275,"Low limit:    High Limit:"
//	DrawText 10,600,"Fit using least square fitting ?"
//	DrawPoly 113,225,1,1,{113,225,113,225}
//	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
//	DrawLine 330,612,350,612
//	SetDrawEnv textrgb= (0,0,65280),fstyle= 1
//	DrawText 4,640,"Results:"

	CheckBox UseSMRData,pos={170,40},size={141,14},proc=IR2D_InputPanelCheckboxProc,title="SMR data"
	CheckBox UseSMRData,variable= root:packages:Irena_SAD:UseSMRData, help={"Check, if you are using slit smeared data"}
	SetVariable SlitLength,limits={0,Inf,0},value= root:Packages:Irena_SAD:SlitLength, disable=!root:packages:Irena_SAD:UseSMRData
	SetVariable SlitLength,pos={260,40},size={100,16},title="SL=",noproc, help={"slit length"}

	Button DrawGraphs,pos={56,158},size={100,20},font="Times New Roman",fSize=10,proc=IR2D_InputPanelButtonProc,title="Graph", help={"Create a graph (log-log) of your experiment data"}

	CheckBox UseLogX,pos={250,150},size={141,14},proc=IR2D_InputPanelCheckboxProc2,title="Log X axis?"
	CheckBox UseLogX,variable= root:packages:Irena_SAD:UseLogX, help={"Check, if you want to display X axis on log scale"}
	CheckBox UseLogY,pos={250,165},size={141,14},proc=IR2D_InputPanelCheckboxProc2,title="Log Y axis?"
	CheckBox UseLogY,variable= root:packages:Irena_SAD:UseLogY, help={"Check, if you want to display Y axis on log scale"}

	CheckBox AutoRecalculate,pos={150,185},size={141,14},proc=IR2D_InputPanelCheckboxProc,title="Auto recalculate"
	CheckBox AutoRecalculate,variable= root:packages:Irena_SAD:AutoRecalculate, help={"Check, if you want to reclaculate data at any change"}
	CheckBox PeakSASScaling,pos={150,201},size={141,14},proc=IR2D_InputPanelCheckboxProc,title="Peak SAS rel."
	CheckBox PeakSASScaling,variable= root:packages:Irena_SAD:PeakSASScaling, help={"Check, to modify relationship between SAS and peaks. See manual."}

	CheckBox DisplayPeaks,pos={250,185},size={141,14},proc=IR2D_InputPanelCheckboxProc,title="Display peaks"
	CheckBox DisplayPeaks,variable= root:packages:Irena_SAD:DisplayPeaks, help={"Check, if you want to display peaks"}
	CheckBox Oversample,pos={250,201},size={141,14},proc=IR2D_InputPanelCheckboxProc,title="Oversample (SMR)"
	CheckBox Oversample,variable= root:packages:Irena_SAD:Oversample, help={"Check, if you have artefacts for slit smeared data and want to oversample (slow)"}



	TabControl DataTabs,pos={2,220},size={380,320},proc=IR2D_TabPanelControl
	TabControl DataTabs,fSize=9,tabLabel(0)="SAS",tabLabel(1)="Pk 1"
	TabControl DataTabs,tabLabel(2)="Pk 2",tabLabel(3)="Pk 3"
	TabControl DataTabs,tabLabel(4)="Pk 4",tabLabel(5)="Pk 5"
	TabControl DataTabs,tabLabel(6)="Pk 6", value= 0
	
//	ListOfVariables+="Background;FitBackground;BackgroundowLimit;BackgroundHighLimit;"
//	/ListOfVariables+="PwrLawPref;FitPwrLawPref;PwrLawPrefLowLimit;PwrLawPrefHighLimit;"
//	ListOfVariables+="PwrLawSlope;FitPwrLawSlope;PwrLawSlopeLowLimit;PwrLawSlopeHighLimit;"
	SetVariable RgPrefactor,pos={14,280},size={180,16},proc=IR2D_PanelSetVarProc,title="G   "
	SetVariable RgPrefactor,limits={0,inf,0.03*root:Packages:Irena_SAD:RgPrefactor},value= root:Packages:Irena_SAD:RgPrefactor, help={"Gunier prefactor"}
	CheckBox FitRgPrefactor,pos={200,281},size={80,16},proc=IR2D_InputPanelCheckboxProc,title=" "
	CheckBox FitRgPrefactor,variable= root:Packages:Irena_SAD:FitRgPrefactor, help={"Fit G?, find god starting conditions and select fitting limits..."}
	SetVariable RgPrefactorLowLimit,pos={230,280},size={60,16}, title=" "
	SetVariable RgPrefactorLowLimit,limits={0,inf,0},value= root:Packages:Irena_SAD:RgPrefactorLowLimit, help={"Low limit for G fitting"}
	SetVariable RgPrefactorHighLimit,pos={300,280},size={60,16}, title=" "
	SetVariable RgPrefactorHighLimit,limits={0,inf,0},value= root:Packages:Irena_SAD:RgPrefactorHighLimit, help={"High limit for G fitting"}

	SetVariable Rg,pos={14,300},size={180,16},proc=IR2D_PanelSetVarProc,title="Rg  "
	SetVariable Rg,limits={0,inf,0.03*root:Packages:Irena_SAD:Rg},value= root:Packages:Irena_SAD:Rg, help={"Gunier radius"}
	CheckBox FitRg,pos={200,301},size={80,16},proc=IR2D_InputPanelCheckboxProc,title=" "
	CheckBox FitRg,variable= root:Packages:Irena_SAD:RitRg, help={"Fit Rg?, find god starting conditions and select fitting limits..."}
	SetVariable RgLowLimit,pos={230,300},size={60,16}, title=" "
	SetVariable RgLowLimit,limits={0,inf,0},value= root:Packages:Irena_SAD:RgLowLimit, help={"Low limit for Rg fitting"}
	SetVariable RgHighLimit,pos={300,300},size={60,16}, title=" "
	SetVariable RgHighLimit,limits={0,inf,0},value= root:Packages:Irena_SAD:RgHighLimit, help={"High limit for Rg fitting"}

	SetVariable PwrLawPref,pos={14,320},size={180,16},proc=IR2D_PanelSetVarProc,title="B   "
	SetVariable PwrLawPref,limits={0,inf,0.03*root:Packages:Irena_SAD:PwrLawPref},value= root:Packages:Irena_SAD:PwrLawPref, help={"Powerlaw prefactor"}
	CheckBox FitPwrLawPref,pos={200,321},size={80,16},proc=IR2D_InputPanelCheckboxProc,title=" "
	CheckBox FitPwrLawPref,variable= root:Packages:Irena_SAD:FitPwrLawPref, help={"Fit B?, find god starting conditions and select fitting limits..."}
	SetVariable PwrLawPrefLowLimit,pos={230,320},size={60,16}, title=" "
	SetVariable PwrLawPrefLowLimit,limits={0,inf,0},value= root:Packages:Irena_SAD:PwrLawPrefLowLimit, help={"Low limit for B fitting"}
	SetVariable PwrLawPrefHighLimit,pos={300,320},size={60,16}, title=" "
	SetVariable PwrLawPrefHighLimit,limits={0,inf,0},value= root:Packages:Irena_SAD:PwrLawPrefHighLimit, help={"High limit for B fitting"}

	SetVariable PwrLawSlope,pos={14,340},size={180,16},proc=IR2D_PanelSetVarProc,title="P   "
	SetVariable PwrLawSlope,limits={0,inf,0.03*root:Packages:Irena_SAD:PwrLawSlope},value= root:Packages:Irena_SAD:PwrLawSlope, help={"Power law slope"}
	CheckBox FitPwrLawSlope,pos={200,341},size={80,16},proc=IR2D_InputPanelCheckboxProc,title=" "
	CheckBox FitPwrLawSlope,variable= root:Packages:Irena_SAD:FitPwrLawSlope, help={"Fit P?, find god starting conditions and select fitting limits..."}
	SetVariable PwrLawSlopeLowLimit,pos={230,340},size={60,16}, title=" "
	SetVariable PwrLawSlopeLowLimit,limits={0,inf,0},value= root:Packages:Irena_SAD:PwrLawSlopeLowLimit, help={"Low limit for P fitting"}
	SetVariable PwrLawSlopeHighLimit,pos={300,340},size={60,16}, title=" "
	SetVariable PwrLawSlopeHighLimit,limits={0,inf,0},value= root:Packages:Irena_SAD:PwrLawSlopeHighLimit, help={"High limit for P fitting"}

	SetVariable Background,pos={14,360},size={180,16},proc=IR2D_PanelSetVarProc,title="Bckg"
	SetVariable Background,limits={-inf,inf,0.03*root:Packages:Irena_SAD:Background},value= root:Packages:Irena_SAD:Background, help={"Background"}
	CheckBox FitBackground,pos={200,361},size={80,16},proc=IR2D_InputPanelCheckboxProc,title=" "
	CheckBox FitBackground,variable= root:Packages:Irena_SAD:FitBackground, help={"Fit Background?, find god starting conditions and select fitting limits..."}
	SetVariable BackgroundLowLimit,pos={230,360},size={60,16}, title=" "
	SetVariable BackgroundLowLimit,limits={0,inf,0},value= root:Packages:Irena_SAD:BackgroundLowLimit, help={"Low limit for Background fitting"}
	SetVariable BackgroundHighLimit,pos={300,360},size={60,16}, title=" "
	SetVariable BackgroundHighLimit,limits={0,inf,0},value= root:Packages:Irena_SAD:BackgroundHighLimit, help={"High limit for Background fitting"}

	//and now the other 6 tabs for 6 peaks... Populate them	
		CheckBox UseThePeak,pos={10,245},size={25,16},proc=IR2D_ModelTabCheckboxProc,title="Use?",  fstyle=1
		CheckBox UseThePeak,variable= root:Packages:Irena_SAD:UsePeak1, help={"Use the peak in model?"}


		PopupMenu PopSizeDistShape title="Peak shape : ",proc=IR2D_PanelPopupControl, pos={10,280}
		PopupMenu PopSizeDistShape value=root:packages:Irena_SAD:ListOfKnownPeakShapes, mode=whichListItem(root:Packages:Irena_SAD:Peak1_Function, root:Packages:Irena_SAD:ListOfKnownPeakShapes)+1
		PopupMenu PopSizeDistShape help={"Select peak profile for this population"}

		SetVariable Peak_Par1,limits={0,Inf,0.03*root:Packages:Irena_SAD:Peak1_Par1},variable= root:Packages:Irena_SAD:Peak1_Par1, proc=IR2D_PanelSetVarProc
		SetVariable Peak_Par1,pos={5,320},size={180,16},title="Prefactor    :", help={"Peak parameter 1"}, fSize=10
		CheckBox FitPeak_Par1,pos={200,320},size={80,16},proc=IR2D_ModelTabCheckboxProc,title=" ",  fstyle=1
		CheckBox FitPeak_Par1,variable= root:Packages:Irena_SAD:FitPeak1_Par1, help={"Fit this parameter?"}
		SetVariable Peak_Par1LowLimit,limits={0,Inf,0},variable= root:Packages:Irena_SAD:Peak1_Par1LowLimit, noproc
		SetVariable Peak_Par1LowLimit,pos={230,320},size={60,15},title=" ", help={"This is min selected for this peak parameter"}, fSize=10
		SetVariable Peak_Par1HighLimit,limits={0,Inf,0},variable= root:Packages:Irena_SAD:Peak1_Par1HighLimit, noproc
		SetVariable Peak_Par1HighLimit,pos={300,320},size={60,15},title=" ", help={"This is max selected for this peak parameter"}, fSize=10

		SetVariable Peak_Par2,limits={0,Inf,0.03*root:Packages:Irena_SAD:Peak1_Par2},variable= root:Packages:Irena_SAD:Peak1_Par2, proc=IR2D_PanelSetVarProc
		SetVariable Peak_Par2,pos={5,340},size={180,16},title="Position       :", help={"Peak parameter 2"}, fSize=10
		CheckBox FitPeak_Par2,pos={200,340},size={80,16},proc=IR2D_ModelTabCheckboxProc,title=" ",  fstyle=1
		CheckBox FitPeak_Par2,variable= root:Packages:Irena_SAD:FitPeak1_Par2, help={"Fit this parameter?"}
		SetVariable Peak_Par2LowLimit,limits={0,Inf,0},variable= root:Packages:Irena_SAD:Peak1_Par2LowLimit, noproc
		SetVariable Peak_Par2LowLimit,pos={230,340},size={60,15},title=" ", help={"This is min selected for this peak parameter"}, fSize=10
		SetVariable Peak_Par2HighLimit,limits={0,Inf,0},variable= root:Packages:Irena_SAD:Peak1_Par2HighLimit, noproc
		SetVariable Peak_Par2HighLimit,pos={300,340},size={60,15},title=" ", help={"This is max selected for this peak parameter"}, fSize=10

		SetVariable Peak_Par3,limits={0,Inf,0.03*root:Packages:Irena_SAD:Peak1_Par3},variable= root:Packages:Irena_SAD:Peak1_Par3, proc=IR2D_PanelSetVarProc
		SetVariable Peak_Par3,pos={5,360},size={180,16},title="Width          :", help={"Peak parameter 3"}, fSize=10
		CheckBox FitPeak_Par3,pos={200,360},size={80,16},proc=IR2D_ModelTabCheckboxProc,title=" ",  fstyle=1
		CheckBox FitPeak_Par3,variable= root:Packages:Irena_SAD:FitPeak1_Par3, help={"Fit this parameter?"}
		SetVariable Peak_Par3LowLimit,limits={0,Inf,0},variable= root:Packages:Irena_SAD:Peak1_Par3LowLimit, noproc
		SetVariable Peak_Par3LowLimit,pos={230,360},size={60,15},title=" ", help={"This is min selected for this peak parameter"}, fSize=10
		SetVariable Peak_Par3HighLimit,limits={0,Inf,0},variable= root:Packages:Irena_SAD:Peak1_Par3HighLimit, noproc
		SetVariable Peak_Par3HighLimit,pos={300,360},size={60,15},title=" ", help={"This is max selected for this peak parameter"}, fSize=10
	
		SetVariable Peak_Par4,limits={0,1,0.03*root:Packages:Irena_SAD:Peak1_Par4},variable= root:Packages:Irena_SAD:Peak1_Par4, proc=IR2D_PanelSetVarProc
		SetVariable Peak_Par4,pos={5,380},size={180,16},title="Eta(Pseudo-Voigt):", help={"Peak parameter 3"}, fSize=10
		CheckBox FitPeak_Par4,pos={200,380},size={80,16},proc=IR2D_ModelTabCheckboxProc,title=" ",  fstyle=1
		CheckBox FitPeak_Par4,variable= root:Packages:Irena_SAD:FitPeak1_Par4, help={"Fit this parameter?"}
		SetVariable Peak_Par4LowLimit,limits={0,1,0},variable= root:Packages:Irena_SAD:Peak1_Par4LowLimit, noproc
		SetVariable Peak_Par4LowLimit,pos={230,380},size={60,15},title=" ", help={"This is min selected for this peak parameter"}, fSize=10
		SetVariable Peak_Par4HighLimit,limits={0,1,0},variable= root:Packages:Irena_SAD:Peak1_Par4HighLimit, noproc
		SetVariable Peak_Par4HighLimit,pos={300,380},size={60,15},title=" ", help={"This is max selected for this peak parameter"}, fSize=10


		CheckBox Peak_LinkPar2,pos={10,410},size={80,16},proc=IR2D_ModelTabCheckboxProc,title="Link Position to other peak?",  fstyle=1
		CheckBox Peak_LinkPar2,variable= root:Packages:Irena_SAD:Peak1_LinkPar2, help={"Link the position parameter to other peak position?"}
		PopupMenu Peak_LinkedTo title="Link to : ",proc=IR2D_PanelPopupControl, pos={10,430}
		PopupMenu Peak_LinkedTo value="---;Peak1;Peak2;Peak3;Peak4;Peak5;Peak6;", mode=whichListItem(root:Packages:Irena_SAD:Peak1_LinkedTo, "---;Peak1;Peak2;Peak3;Peak4;Peak5;Peak6;")+1
		PopupMenu Peak_LinkedTo help={"Select which population to link to"}
		SetVariable Peak_LinkMultiplier,limits={1e-10,inf,0},variable= root:Packages:Irena_SAD:Peak1_LinkMultiplier, proc=IR2D_PanelSetVarProc
		SetVariable Peak_LinkMultiplier,pos={200,433},size={130,16},title="Multiplier", help={"Multiplier to scale the Pak X position here"}, fSize=10


		SetVariable PeakDPosition,limits={0,1,0},variable= root:Packages:Irena_SAD:PeakDPosition1, noproc, disable=2
		SetVariable PeakDPosition,pos={5,460},size={280,16},title="Peak position -spacing [A]:", help={"peak position in D units"}, fSize=10
		SetVariable PeakPosition,limits={0,1,0},variable= root:Packages:Irena_SAD:PeakPosition1, noproc, disable=2
		SetVariable PeakPosition,pos={5,480},size={280,16},title="Peak position - Q   [A^-1]:", help={"peak position in Q units"}, fSize=10
		SetVariable PeakFWHM,limits={0,1,0},variable= root:Packages:Irena_SAD:PeakFWHM1, noproc, disable=2
		SetVariable PeakFWHM,pos={5,500},size={280,16},title="Peak FWHM [A^-1]:", help={"peak position in Q units"}, fSize=10
		SetVariable PeakIntgInt,limits={0,1,0},variable= root:Packages:Irena_SAD:PeakIntgInt1, noproc, disable=2
		SetVariable PeakIntgInt,pos={5,520},size={280,16},title="Peak Integral Intensity:", help={"peak integral inetnsity"}, fSize=10


	Button Recalculate,pos={16,545},size={100,20},font="Times New Roman",fSize=10,proc=IR2D_InputPanelButtonProc,title="Recalculate", help={"Recalculate model data"}
	Button CopyToNbk,pos={16,570},size={100,20},font="Times New Roman",fSize=10,proc=IR2D_InputPanelButtonProc,title="Paste to Notebook", help={"Recalculate model data"}

	PopupMenu EnforceGeometry title="Structure?",proc=IR2D_PanelPopupControl, pos={130,545}
	PopupMenu EnforceGeometry value=root:packages:Irena_SAD:ListOfKnownPeakRelationships, mode=whichListItem(root:Packages:Irena_SAD:PeakRelationship, root:Packages:Irena_SAD:ListOfKnownPeakRelationships)+1
	PopupMenu EnforceGeometry help={"Select structure to present peak d-spacing relationships"}
	
	Button AppendResultsToGraph,pos={130,570},size={100,20},font="Times New Roman",fSize=10,proc=IR2D_InputPanelButtonProc,title="Add tags to graph", help={"Append results to graphs"}
	Button RemoveResultsFromGraph,pos={130,595},size={100,20},font="Times New Roman",fSize=10,proc=IR2D_InputPanelButtonProc,title="Remove tags", help={"Append results to graphs"}
	Button Fit,pos={250,570},size={100,20},font="Times New Roman",fSize=10,proc=IR2D_InputPanelButtonProc,title="Fit", help={"Fit model data"}
	Button ResetFit,pos={250,595},size={100,20},font="Times New Roman",fSize=10,proc=IR2D_InputPanelButtonProc,title="Revert back", help={"Fit model data"}
	Button SaveDataInFoldr,pos={16,595},size={100,20},font="Times New Roman",fSize=10,proc=IR2D_InputPanelButtonProc,title="Save In Fldr", help={"Save model data to original folder"}

	CheckBox AppendResiduals,pos={10,620},size={100,14},proc=IR2D_InputPanelCheckboxProc2,title="Display Residuals?"
	CheckBox AppendResiduals,variable= root:packages:Irena_SAD:AppendResiduals, help={"Check, if you want to display residuals in the graph"}
	CheckBox AppendNormalizedResiduals,pos={120,620},size={141,14},proc=IR2D_InputPanelCheckboxProc2,title="Display Norm. Residuals?"
	CheckBox AppendNormalizedResiduals,variable= root:packages:Irena_SAD:AppendNormalizedResiduals, help={"Check, if you want to display normalized residuals in the graph"}
	CheckBox UseGeneticOptimization,pos={270,620},size={80,16},noproc,title="Use genetic opt?",  fstyle=1
	CheckBox UseGeneticOptimization,variable= root:Packages:Irena_SAD:UseGeneticOptimization, help={"Usze genetic optimization (uncheck to use LSQF)?"}

	
	IR2D_TabPanelControl("",0)
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2D_PopSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_SAD
	variable whichDataSet
	//BackgStep_set
	ControlInfo/W=IR2D_ControlPanel DataTabs
	whichDataSet= V_Value+1
	
	IR2D_CalculateIntensity(0)

	setDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2D_ModelTabCheckboxProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_SAD
	

	ControlInfo/W=IR2D_ControlPanel DataTabs
	variable WhichPeakSet= V_Value+1

//	if (stringMatch(ctrlName,"UseThePeak"))
		IR2D_TabPanelControl("",WhichPeakSet-1)
		IR2D_CalculateIntensity(0)
//	endif
	
	setDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2D_PanelPopupControl(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_SAD
	if (stringmatch(ctrlName,"PopSizeDistShape"))
		ControlInfo/W=IR2D_ControlPanel DataTabs
		SVAR PeakFunction = $("root:Packages:Irena_SAD:Peak"+num2str(V_Value)+"_Function")
		PeakFunction = popStr
//		if(stringmatch(popStr,"Pseudo-Voigt"))
//			Execute("SetVariable Peak_Par4,title=\"Eta(Pseudo-Voigt):\",limits={0,1,0.1}")
//			Execute("SetVariable Peak_Par4LowLimit,limits={0,1,0}")
//			Execute("SetVariable Peak_Par4highLimit,limits={0,1,0}")
//			
//		else
//			Execute("SetVariable Peak_Par4,title=\"Skewness(Gumbel):\",limits={0,inf,0.1}")
//			Execute("SetVariable Peak_Par4LowLimit,limits={0,1,0}")
//			Execute("SetVariable Peak_Par4highLimit,limits={0,inf,0}")
//		endif
		IR2D_CalculateIntensity(0)
		IR2D_TabPanelControl("",V_Value)

	endif
	
	if (stringmatch(ctrlName,"Peak_LinkedTo"))
		ControlInfo/W=IR2D_ControlPanel DataTabs
		SVAR Peak_LinkedTo = $("root:Packages:Irena_SAD:Peak"+num2str(V_Value)+"_LinkedTo")
		Peak_LinkedTo = popStr
		IR2D_CalculateIntensity(0)
		IR2D_TabPanelControl("",V_Value)
	endif
	if (stringmatch(ctrlName,"EnforceGeometry"))
		ControlInfo/W=IR2D_ControlPanel DataTabs
		SVAR PeakRelationship
		PeakRelationship = popStr
		IR2D_SetStructure()
//	string/g ListOfKnownPeakRelationships	="---;Lamellar;HCP cylinders;Primitive Simple cubic;BCC;FCC;HCP spheres;Doube Diamond;1a-3d;Pm-3n;"

		IR2D_CalculateIntensity(0)
		IR2D_TabPanelControl("",V_Value)
	endif

	setDataFolder OldDf

end
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2D_SetStructure()
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_SAD
	SVAR PeakRelationship
	variable i
	NVAR UsePeak1=UsePeak1
	usePeak1=1
	SVAR LinkPk1=Peak1_linkedTo
	LinkPk1="---"
	NVAR LinkOn=Peak1_LinkPar2
	LinkOn=0
	for(i=2;i<=6;i+=1)
		NVAR usePop=$("UsePeak"+num2str(i))
		usePop=1
		SVAR linkPk=$("Peak"+num2str(i)+"_LinkedTo")
		linkPk="Peak1"
		NVAR LinkOn = $("Peak"+num2str(i)+"_LinkPar2")
		LinkOn = 1
	endfor
//and now the ratios... 
	NVAR Pk1M=root:Packages:Irena_SAD:Peak1_LinkMultiplier
	NVAR Pk2M=root:Packages:Irena_SAD:Peak2_LinkMultiplier
	NVAR Pk3M=root:Packages:Irena_SAD:Peak3_LinkMultiplier
	NVAR Pk4M=root:Packages:Irena_SAD:Peak4_LinkMultiplier
	NVAR Pk5M=root:Packages:Irena_SAD:Peak5_LinkMultiplier
	NVAR Pk6M=root:Packages:Irena_SAD:Peak6_LinkMultiplier
	if(stringmatch(PeakRelationship,"Lamellar"))
	// Lamellar  1: 2 : 3 : 4 : 5 : 6 : 7
		Pk1M=1*(1)
		Pk2M=1*(2)
		Pk3M=1*(3)
		Pk4M=1*(4)
		Pk5M=1*(5)
		Pk6M=1*(6)
	elseif(stringmatch(PeakRelationship,"HCP cylinders"))
	// Hexagonally packed cylinders 1 : sqrt(3) : 2 : sqrt(7) : 3 : sqrt(12) : sqrt(13) : 4
		Pk1M=1*(1)
		Pk2M=1*(sqrt(3))
		Pk3M=1*(2)
		Pk4M=1*(sqrt(7))
		Pk5M=1*(3)
		Pk6M=1*(sqrt(12))
	elseif(stringmatch(PeakRelationship,"Simple cubic"))
	// Primitive (simple cubic) 1 : sqrt(2) : sqrt(3) : 2 : sqrt(5) : sqrt(6) :sqrt(8) : 3
		Pk1M=1*(1)
		Pk2M=1*(sqrt(2))
		Pk3M=1*(sqrt(3))
		Pk4M=1*(2)
		Pk5M=1*(sqrt(5))
		Pk6M=1*(sqrt(6))
	elseif(stringmatch(PeakRelationship,"BCC"))
	// BCC   1 : sqrt(2) : sqrt(3) : 2 : sqrt(5) : sqrt(6) : sqrt(7) : sqrt(8) : 3
		Pk1M=1*(1)
		Pk2M=1*(sqrt(2))
		Pk3M=1*(sqrt(3))
		Pk4M=1*(2)
		Pk5M=1*(sqrt(5))
		Pk6M=1*(sqrt(6))
	elseif(stringmatch(PeakRelationship,"FCC"))
	//FCC    sqrt(3) : 2 : sqrt(8) : sqrt (11) : sqrt(12) : 4 : sqrt(19)
		Pk1M=1*(1)
		Pk2M=1*(2/sqrt(3))
		Pk3M=1*(sqrt(8)/sqrt(3))
		Pk4M=1*(sqrt(11)/sqrt(3))
		Pk5M=1*(sqrt(12)/sqrt(3))
		Pk6M=1*(4/sqrt(3))
	elseif(stringmatch(PeakRelationship,"HCP spheres"))
	// Hex close packed  sqrt(32) : 6 : sqrt(41) : sqrt(68) : sqrt(96) : sqrt(113)
		Pk1M=1*(1)
		Pk2M=1*(6/sqrt(32))
		Pk3M=1*(sqrt(41)/sqrt(32))
		Pk4M=1*(sqrt(68)/sqrt(32))
		Pk5M=1*(sqrt(96)/sqrt(32))
		Pk6M=1*(sqrt(113)/sqrt(32))
	elseif(stringmatch(PeakRelationship,"Doube Diamond"))
	// double diamond   sqrt(2) : sqrt(3) : 2 : sqrt(6) :sqrt(8) : 3 : sqrt(10) : sqrt(11)
		Pk1M=1*(1)
		Pk2M=1*(sqrt(3)/sqrt(2))
		Pk3M=1*(2/sqrt(2))
		Pk4M=1*(sqrt(6)/sqrt(2))
		Pk5M=1*(sqrt(8)/sqrt(2))
		Pk6M=1*(3/sqrt(2))
	elseif(stringmatch(PeakRelationship,"1a-3d"))
	//Ialpha(-3)d		sqrt(3) : 2 : sqrt(7) :sqrt(8) : sqrt(10) : sqrt(11) : sqrt(12)
		Pk1M=1*(1)
		Pk2M=1*(2/sqrt(3))
		Pk3M=1*(sqrt(7)/sqrt(3))
		Pk4M=1*(sqrt(10)/sqrt(3))
		Pk5M=1*(sqrt(11)/sqrt(3))
		Pk6M=1*(sqrt(12)/sqrt(3))
	elseif(stringmatch(PeakRelationship,"Pm-3n"))
	//Pm3m		sqrt(2) : 2 : sqrt(5) : sqrt(6) : sqrt(8) : sqrt(10) : sqrt(12)
		Pk1M=1*(1)
		Pk2M=1*(2/sqrt(2))
		Pk3M=1*(sqrt(5)/sqrt(2))
		Pk4M=1*(sqrt(8)/sqrt(2))
		Pk5M=1*(sqrt(10)/sqrt(2))
		Pk6M=1*(sqrt(12)/sqrt(2))

	endif
//	SVAR ListOfKnownPeakRelationships	="---;Lamellar;HCP cylinders;Primitive Simple cubic;BCC;FCC;HCP spheres;Doube Diamond;1a-3d;Pm-3n;"
// from Block copolymers: synthetic strategies, Physical properties and applications, Hadjichrististidis, Pispas, Floudas, Willey & sons, 2003, chapter 19, pg 347

	
	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR2D_TabPanelControl(name,tab)
	String name
	Variable tab

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_SAD

	SetVariable RgPrefactor, disable =  (tab!=0)
	CheckBox FitRgPrefactor, disable =  (tab!=0)
	NVAR FitRgPrefactor = root:Packages:Irena_SAD:FitRgPrefactor
	SetVariable RgPrefactorLowLimit, disable =  (tab!=0 || !FitRgPrefactor)
	SetVariable RgPrefactorHighLimit, disable =  (tab!=0 || !FitRgPrefactor)

	SetVariable Rg, disable =  (tab!=0)
	CheckBox FitRg, disable =  (tab!=0)
	NVAR FitRg = root:Packages:Irena_SAD:FitRg
	SetVariable RgLowLimit, disable =  (tab!=0 || !FitRg)
	SetVariable RgHighLimit, disable =  (tab!=0 || !FitRg)

	SetVariable PwrLawPref, disable =  (tab!=0)
	CheckBox FitPwrLawPref, disable =  (tab!=0)
	NVAR FitPwrLawPref = root:Packages:Irena_SAD:FitPwrLawPref
	SetVariable PwrLawPrefLowLimit, disable =  (tab!=0 || !FitPwrLawPref)
	SetVariable PwrLawPrefHighLimit, disable =  (tab!=0 || !FitPwrLawPref)

	SetVariable PwrLawSlope, disable =  (tab!=0)
	CheckBox FitPwrLawSlope, disable =  (tab!=0)
	NVAR FitPwrLawSlope = root:Packages:Irena_SAD:FitPwrLawSlope
	SetVariable PwrLawSlopeLowLimit, disable =  (tab!=0 || !FitPwrLawSlope)
	SetVariable PwrLawSlopeHighLimit, disable =  (tab!=0 || !FitPwrLawSlope)

	SetVariable Background, disable =  (tab!=0)
	CheckBox FitBackground, disable =  (tab!=0)
	NVAR FitBackground = root:Packages:Irena_SAD:FitBackground
	SetVariable BackgroundLowLimit, disable =  (tab!=0 || !FitBackground)
	SetVariable BackgroundHighLimit, disable =  (tab!=0 || !FitBackground)


	CheckBox UseThePeak, disable=(tab==0)
	SetVariable Peak_Par1,disable=(tab==0)
	CheckBox FitPeak_Par1,disable=(tab==0)
	SetVariable Peak_Par1LowLimit,disable=(tab==0)
	SetVariable Peak_Par1HighLimit,disable=(tab==0)
	SetVariable Peak_Par2,disable=(tab==0)
	CheckBox FitPeak_Par2,disable=(tab==0)
	SetVariable Peak_Par2LowLimit,disable=(tab==0)
	SetVariable Peak_Par2HighLimit,disable=(tab==0)
	SetVariable Peak_Par3,disable=(tab==0)
	CheckBox FitPeak_Par3,disable=(tab==0)
	SetVariable Peak_Par3LowLimit,disable=(tab==0)
	SetVariable Peak_Par3HighLimit, disable=(tab==0)
	SetVariable Peak_Par4,disable=(tab==0)
	CheckBox FitPeak_Par4,disable=(tab==0)
	SetVariable Peak_Par4LowLimit,disable=(tab==0)
	SetVariable Peak_Par4HighLimit, disable=(tab==0)
	PopupMenu PopSizeDistShape, disable=(tab==0)


	CheckBox Peak_LinkPar2, disable=(tab==0)
	PopupMenu Peak_LinkedTo, disable=(tab==0)
	SetVariable Peak_LinkMultiplier, disable=(tab==0)

	SetVariable PeakDPosition, disable=(tab==0
	SetVariable PeakPosition, disable=(tab==0
	SetVariable PeakFWHM, disable=(tab==0
	SetVariable PeakIntgInt, disable=(tab==0
	
	if(tab>0)
		SVAR ListOfKnownPeakShapes=root:packages:Irena_SAD:ListOfKnownPeakShapes
		SVAR CurDistType=$("root:Packages:Irena_SAD:Peak"+num2str(tab)+"_Function")
		NVAR PP2 = $("root:Packages:Irena_SAD:Peak"+num2str(tab)+"_LinkPar2")  
		variable Display4=0
		if(stringmatch(CurDistType,"Pseudo-Voigt")||stringmatch(CurDistType,"Pearson_VII")||stringmatch(CurDistType,"Modif_Gauss"))
			Display4=1
		endif
		PopupMenu PopSizeDistShape win=IR2D_ControlPanel,  mode=whichListItem(CurDistType, ListOfKnownPeakShapes)+1
		NVAR UsePeak = $("root:Packages:Irena_SAD:UsePeak"+num2str(tab))
		NVAR Fit1 = $("root:Packages:Irena_SAD:FitPeak"+num2str(tab)+"_Par1")
		Execute("CheckBox UseThePeak win=IR2D_ControlPanel,variable= root:Packages:Irena_SAD:UsePeak"+num2str(tab))
		Execute("SetVariable Peak_Par1 win=IR2D_ControlPanel,variable= root:Packages:Irena_SAD:Peak"+num2str(tab)+"_Par1, disable = !"+num2Str(UsePeak))
		Execute("CheckBox FitPeak_Par1 win=IR2D_ControlPanel,variable= root:Packages:Irena_SAD:FitPeak"+num2str(tab)+"_Par1, disable = !"+num2Str(UsePeak))
		Execute("SetVariable Peak_Par1LowLimit  win=IR2D_ControlPanel,variable= root:Packages:Irena_SAD:Peak"+num2str(tab)+"_Par1LowLimit, disable = !("+num2Str(UsePeak)+"&&"+num2str(Fit1)+")")
		Execute("SetVariable Peak_Par1HighLimit  win=IR2D_ControlPanel,variable= root:Packages:Irena_SAD:Peak"+num2str(tab)+"_Par1HighLimit, disable = !("+num2Str(UsePeak)+"&&"+num2str(Fit1)+")")
	
		NVAR Fit2 = $("root:Packages:Irena_SAD:FitPeak"+num2str(tab)+"_Par2")
		Execute("SetVariable Peak_Par2 win=IR2D_ControlPanel,variable= root:Packages:Irena_SAD:Peak"+num2str(tab)+"_Par2, disable = !"+num2Str(UsePeak))
		if(PP2)
			Execute("SetVariable Peak_Par2 win=IR2D_ControlPanel,variable= root:Packages:Irena_SAD:Peak"+num2str(tab)+"_Par2, disable = 2")		
		endif
		Execute("CheckBox FitPeak_Par2 win=IR2D_ControlPanel,variable= root:Packages:Irena_SAD:FitPeak"+num2str(tab)+"_Par2, disable = !"+num2Str(UsePeak)+" || "+num2str(PP2))
		Execute("SetVariable Peak_Par2LowLimit  win=IR2D_ControlPanel,variable= root:Packages:Irena_SAD:Peak"+num2str(tab)+"_Par2LowLimit, disable = !("+num2Str(UsePeak)+"&&"+num2str(Fit2)+")"+" || "+num2str(PP2))
		Execute("SetVariable Peak_Par2HighLimit  win=IR2D_ControlPanel,variable= root:Packages:Irena_SAD:Peak"+num2str(tab)+"_Par2HighLimit, disable = !("+num2Str(UsePeak)+"&&"+num2str(Fit2)+")"+" || "+num2str(PP2))
	
		NVAR Fit3 = $("root:Packages:Irena_SAD:FitPeak"+num2str(tab)+"_Par3")
		Execute("SetVariable Peak_Par3  win=IR2D_ControlPanel,variable= root:Packages:Irena_SAD:Peak"+num2str(tab)+"_Par3, disable = !"+num2Str(UsePeak))
		Execute("CheckBox FitPeak_Par3  win=IR2D_ControlPanel,variable= root:Packages:Irena_SAD:FitPeak"+num2str(tab)+"_Par3, disable = !"+num2Str(UsePeak))
		Execute("SetVariable Peak_Par3LowLimit  win=IR2D_ControlPanel,variable= root:Packages:Irena_SAD:Peak"+num2str(tab)+"_Par3LowLimit, disable = !("+num2Str(UsePeak)+"&&"+num2str(Fit3)+")")
		Execute("SetVariable Peak_Par3HighLimit  win=IR2D_ControlPanel,variable= root:Packages:Irena_SAD:Peak"+num2str(tab)+"_Par3HighLimit, disable = !("+num2Str(UsePeak)+"&&"+num2str(Fit3)+")")
	
		NVAR Fit4 = $("root:Packages:Irena_SAD:FitPeak"+num2str(tab)+"_Par4")
		Execute("SetVariable Peak_Par4 win=IR2D_ControlPanel,variable= root:Packages:Irena_SAD:Peak"+num2str(tab)+"_Par4, disable = !("+num2Str(UsePeak)+"&& "+num2str(Display4)+")")
		Execute("CheckBox FitPeak_Par4 win=IR2D_ControlPanel,variable= root:Packages:Irena_SAD:FitPeak"+num2str(tab)+"_Par4, disable = !("+num2Str(UsePeak)+"&& "+num2str(Display4)+")")
		Execute("SetVariable Peak_Par4LowLimit  win=IR2D_ControlPanel,variable= root:Packages:Irena_SAD:Peak"+num2str(tab)+"_Par4LowLimit, disable = !("+num2Str(UsePeak)+"&& "+num2str(Display4)+"&&"+num2str(Fit4)+")")
		Execute("SetVariable Peak_Par4HighLimit  win=IR2D_ControlPanel,variable= root:Packages:Irena_SAD:Peak"+num2str(tab)+"_Par4HighLimit, disable = !("+num2Str(UsePeak)+"&& "+num2str(Display4)+"&&"+num2str(Fit4)+")")

		if(stringmatch(CurDistType,"Pseudo-Voigt"))
			Execute("SetVariable Peak_Par4 win=IR2D_ControlPanel,title=\"ETA (Pseudo-Voigt)\"")
		elseif(stringmatch(CurDistType,"Pearson_VII"))
			Execute("SetVariable Peak_Par4 win=IR2D_ControlPanel,title=\"Tail Par\"")
		elseif(stringmatch(CurDistType,"Modif_Gauss"))
			Execute("SetVariable Peak_Par4 win=IR2D_ControlPanel,title=\"Tail Par\"")
		endif
		
		
		Execute("CheckBox Peak_LinkPar2 win=IR2D_ControlPanel,variable= root:Packages:Irena_SAD:Peak"+num2str(tab)+"_LinkPar2, disable = !("+num2Str(UsePeak)+")")

		string MenuVal= "---;Peak1;Peak2;Peak3;Peak4;Peak5;Peak6;"
		MenuVal = ReplaceString("Peak"+num2str(tab)+";", MenuVal, "" )
		SVAR testStr=$("root:Packages:Irena_SAD:Peak"+num2str(tab)+"_LinkedTo")
		Execute("PopupMenu Peak_LinkedTo value=\""+MenuVal+"\", mode="+Num2str(whichListItem(testStr, MenuVal)+1))
	
		Execute("PopupMenu Peak_LinkedTo win=IR2D_ControlPanel, disable = !("+num2Str(UsePeak)+"&&"+num2str(PP2)+")")
		Execute("SetVariable Peak_LinkMultiplier win=IR2D_ControlPanel,variable= root:Packages:Irena_SAD:Peak"+num2str(tab)+"_LinkMultiplier, disable = !("+num2Str(UsePeak)+"&&"+num2str(PP2)+")")

		Execute("SetVariable PeakDPosition  win=IR2D_ControlPanel,variable= root:Packages:Irena_SAD:PeakDPosition"+num2str(tab)+", disable = 2")
		Execute("SetVariable PeakPosition  win=IR2D_ControlPanel,variable= root:Packages:Irena_SAD:PeakPosition"+num2str(tab)+", disable = 2")
		Execute("SetVariable PeakFWHM  win=IR2D_ControlPanel,variable= root:Packages:Irena_SAD:PeakFWHM"+num2str(tab)+", disable = 2")
		Execute("SetVariable PeakIntgInt  win=IR2D_ControlPanel,variable= root:Packages:Irena_SAD:PeakIntgInt"+num2str(tab)+", disable = 2")

	endif
	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************



Function IR2D_InputPanelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_SAD
	

	if (cmpstr(ctrlName,"DrawGraphs")==0 || cmpstr(ctrlName,"DrawGraphsSkipDialogs")==0)
		//here goes what is done, when user pushes Graph button
		SVAR DFloc=root:Packages:Irena_SAD:DataFolderName
		SVAR DFInt=root:Packages:Irena_SAD:IntensityWaveName
		SVAR DFQ=root:Packages:Irena_SAD:QWaveName
		SVAR DFE=root:Packages:Irena_SAD:ErrorWaveName
		variable IsAllAllRight=1
		if (cmpstr(DFloc,"---")==0)
			IsAllAllRight=0
		endif
		if (cmpstr(DFInt,"---")==0)
			IsAllAllRight=0
		endif
		if (cmpstr(DFQ,"---")==0)
			IsAllAllRight=0
		endif
		if (cmpstr(DFE,"---")==0)
			IsAllAllRight=0
		endif
		
		if (IsAllAllRight)
			if(cmpstr(ctrlName,"DrawGraphsSkipDialogs")!=0)
//				variable recovered = IR1A_RecoverOldParameters()	//recovers old parameters and returns 1 if done so...
			endif
			IR2D_GraphMeasuredData()
			IR2D_RecoverOldParameters()
		else
			Abort "Data not selected properly"
		endif
	endif
	if (cmpstr(ctrlName,"Recalculate")==0)
		IR2D_CalculateIntensity(1)
	endif
	if (cmpstr(ctrlName,"Fit")==0)
		IR2D_Fitting()
	endif
	if (cmpstr(ctrlName,"ResetFit")==0)
		IR2D_ResetParamsAfterBadFit()
	endif
	if (cmpstr(ctrlName,"AppendResultsToGraph")==0)
		IR2D_AppendTagsToGraph()
	endif
	if (cmpstr(ctrlName,"RemoveResultsFromGraph")==0)
		IR2D_RemoveTagsFromGraph()
	endif	
	if (cmpstr(ctrlName,"SaveDataInFoldr")==0)
		IR2D_SaveResultsToFolder()
	endif	
	if (cmpstr(ctrlName,"CopyToNbk")==0)
		IR2D_SaveResultsToNotebook()
	endif	
	
	setDataFolder OldDf	
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


static Function IR2D_SaveResultsToNotebook()

	IR1_CreateResultsNbk()
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_SAD
	SVAR  DataFolderName=root:Packages:Irena_SAD:DataFolderName
	SVAR  IntensityWaveName=root:Packages:Irena_SAD:IntensityWaveName
	SVAR  QWavename=root:Packages:Irena_SAD:QWavename
	SVAR  ErrorWaveName=root:Packages:Irena_SAD:ErrorWaveName
	IR1_AppendAnyText("\r Results of Small-angle diffraction fitting\r",1)	
	IR1_AppendAnyText("Date & time: \t"+Date()+"   "+time(),0)	
	IR1_AppendAnyText("Data from folder: \t"+DataFolderName,0)	
	IR1_AppendAnyText("Intensity: \t"+IntensityWaveName,0)	
	IR1_AppendAnyText("Q: \t"+QWavename,0)	
	IR1_AppendAnyText("Error: \t"+ErrorWaveName,0)	
//	IR1_AppendAnyText("Method used: \t"+MethodRun,0)	
	
	IR1_AppendAnyGraph("IR2D_LogLogPlotSAD")
	//save data here... For Moore include "Fittingresults" which is Intensity Fit stuff
//	SVAR FittingResults = root:Packages:Irena_PDDF:FittingResults
	string FittingResults=""
	NVAR background = root:Packages:Irena_SAD:Background
	NVAR PwrlawPref=root:Packages:Irena_SAD:PwrLawPref
	NVAR PwrLawSlope=root:Packages:Irena_SAD:PwrLawSlope
	NVAR RgPref=root:Packages:Irena_SAD:RgPrefactor
	NVAR Rg=root:Packages:Irena_SAD:Rg
	if(Rg<10000)
		FittingResults	= "Guinier area parameters \r"
		FittingResults += "Rg = "+num2str(Rg) + "   prefactor = "+num2str(RgPref) +"\r"
	endif
	FittingResults += " Power law slope = "+num2str(PwrLawSlope)+"   Prefactor = "+num2str(PwrlawPref)+"\r"
	FittingResults += " Bacground = "+num2str(background)+" \r\r"
	variable i
	For(i=1;i<=6;i+=1)
		NVAR UsePeak = $("root:Packages:Irena_SAD:UsePeak"+num2str(i))
		if(UsePeak)
			NVAR PeakDpos=$("root:Packages:Irena_SAD:PeakDPosition"+num2str(i))
			NVAR PeakFWHM=$("root:Packages:Irena_SAD:PeakFWHM"+num2str(i))
			NVAR PeakIntgInt=$("root:Packages:Irena_SAD:PeakIntgInt"+num2str(i))
			NVAR PeakPos=$("root:Packages:Irena_SAD:PeakPosition"+num2str(i))
			FittingResults += "Peak number "+num2str(i)+" used \r"
			FittingResults += "Peak position (Q units) = "+num2str(PeakPos)+"  [A^-1]   , D units = "+num2str(PeakDpos)+" [A] \r"
			FittingResults += "Peak FWHM (Q units) = "+num2str(PeakFWHM)+" [A^-1] \r"
			FittingResults += "Peak Integral intensity = "+num2str(PeakIntgInt)+"\r\r"
		endif
	endfor
	IR1_AppendAnyText(FittingResults,0)	
	IR1_AppendAnyText("******************************************\r",0)	
	SetDataFolder OldDf
	SVAR/Z nbl=root:Packages:Irena:ResultsNotebookName	
	DoWindow/F $nbl

end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2D_RecoverOldParameters()
	
	string oldDf=GetDataFolder(1)

	SVAR DataFolderName = root:Packages:Irena_SAD:DataFolderName
	SetDataFolder DataFolderName
	variable DataExists=0,i
	string ListOfWaves=IN2G_CreateListOfItemsInFolder(DataFolderName, 2)
	string tempString
	if (stringmatch(ListOfWaves, "*SADModelIntensity*" ))
		string ListOfSolutions="start from current state;"
		For(i=0;i<itemsInList(ListOfWaves);i+=1)
			if (stringmatch(stringFromList(i,ListOfWaves),"*SADModelIntensity*"))
				tempString=stringFromList(i,ListOfWaves)
				Wave tempwv=$(DataFolderName+tempString)
				tempString=stringByKey("UsersComment",note(tempwv),"=")
				ListOfSolutions+=stringFromList(i,ListOfWaves)+"*  "+tempString+";"
			endif
		endfor
		DataExists=1
		string ReturnSolution=""
		Prompt ReturnSolution, "Select solution to recover", popup,  ListOfSolutions
		DoPrompt "Previous solutions found, select one to recover", ReturnSolution
		if (V_Flag)
			abort
		endif
		if (cmpstr("start from current state",ReturnSolution)==0)
			DataExists=0
		endif
	endif

	setDataFolder root:Packages:Irena_SAD
	if (DataExists==1)
		ReturnSolution=ReturnSolution[0,strsearch(ReturnSolution, "*", 0 )-1]
		Wave/Z OldDistribution=$(DataFolderName+ReturnSolution)

		string OldNote=note(OldDistribution)
		SVAR ListOfVariables = root:Packages:Irena_SAD:ListOfVariables
		SVAR ListOfStrings = root:Packages:Irena_SAD:ListOfStrings
		string LocalListOFStrings = ReplaceString("DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;ListOfKnownPeakShapes;", ListOfStrings, "")
		
		For(i=0;i<ItemsInList(ListOfVariables);i+=1)
			NVAR tmp = $(StringFromList(i,ListOfVariables))
			tmp = NumberByKey(StringFromList(i,ListOfVariables), OldNote  , "="  ,";")
		endfor
		For(i=0;i<ItemsInList(LocalListOFStrings);i+=1)
			SVAR tmpS = $(StringFromList(i,LocalListOFStrings))
			tmpS = StringByKey(StringFromList(i,LocalListOFStrings), OldNote  , "="  ,";")
		endfor
	endif
	setDataFolder OldDf	
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2D_SaveResultsToFolder()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_SAD

	SVAR/Z ListOfVariables=root:Packages:Irena_SAD:ListOfVariables
	SVAR/Z ListOfStrings=root:Packages:Irena_SAD:ListOfStrings
	if(!SVAR_Exists(ListOfVariables) || !SVAR_Exists(ListOfStrings))
		abort "Error in parameters in IR2D_SaveResultsToFolder routine. Send the file to author for bug fix, please"
	endif
	
	variable i, j 

	//and here we store them in the List to use in the wave note...
	string ListOfParameters=""
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		NVAR testVar = $( StringFromList(i,ListOfVariables))
		ListOfParameters+=StringFromList(i,ListOfVariables)+"="+num2str(testVar)+";"
	endfor		
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		SVAR testStr = $(StringFromList(i,ListOfStrings))
		ListOfParameters+=StringFromList(i,ListOfStrings)+"="+testStr+";"
	endfor	
//

	SVAR DataFolderName = root:Packages:Irena_SAD:DataFolderName
	
	Wave/Z Intensity		= root:Packages:Irena_SAD:ModelIntensity
	Wave/Z Qvector 		= root:Packages:Irena_SAD:ModelQvector
	if(!WaveExists(Intensity) || !WaveExists(Qvector))
		setDataFolder OldDf
		abort "No data exist, aborted"
	endif
	
	string UsersComment, ExportSeparateDistributions
	UsersComment="Result from Small-angle difraction Modeling "+date()+"  "+time()
	ExportSeparateDistributions="No"
	Prompt UsersComment, "Modify comment to be saved with these results"
	Prompt ExportSeparateDistributions, "Export separately populations data", popup, "No;Yes;"
	DoPrompt "Need input for saving data", UsersComment, ExportSeparateDistributions
	if (V_Flag)
		abort
	endif

	setDataFolder $(DataFolderName)
	string tempname 
	variable ii=0
	For(ii=0;ii<1000;ii+=1)
		tempname="SADModelIntensity_"+num2str(ii)
		if (checkname(tempname,1)==0)
			break
		endif
	endfor

	Duplicate Intensity, $("SADModelIntensity_"+num2str(ii))
	Duplicate Qvector, $("SADModelQ_"+num2str(ii))
	
	Wave MytempWave=$("SADModelIntensity_"+num2str(ii))
	tempname="SADModelIntensity_"+num2str(ii)
	IN2G_AppendorReplaceWaveNote(tempname,"DataFrom",GetDataFolder(0))
	IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
	IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
	IN2G_AppendorReplaceWaveNote(tempname,"Units","1/cm")
	note MytempWave, ListOfParameters
	Redimension/D MytempWave
		
	Wave MytempWave=$("SADModelQ_"+num2str(ii))
	tempname="SADModelQ_"+num2str(ii)
	IN2G_AppendorReplaceWaveNote(tempname,"DataFrom",GetDataFolder(0))
	IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
	IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
	IN2G_AppendorReplaceWaveNote(tempname,"Units","1/A")
	note MytempWave, ListOfParameters
	Redimension/D MytempWave
	
	if(stringmatch(ExportSeparateDistributions, "Yes" ))
		For(i=1;i<=6;i+=1)
			Wave/Z IntensityPeak = $("root:Packages:Irena_SAD:Peak"+num2str(i)+"Intensity")
			if(WaveExists(IntensityPeak))
				Duplicate IntensityPeak, $("SADModelIntPeak"+num2str(i)+"_"+num2str(ii))
				Duplicate Qvector, $("SADModelQPeak"+num2str(i)+"_"+num2str(ii))

				Wave MytempWave=$("SADModelIntPeak"+num2str(i)+"_"+num2str(ii))
				tempname="SADModelIntPeak"+num2str(i)+"_"+num2str(ii)
				IN2G_AppendorReplaceWaveNote(tempname,"DataFrom",GetDataFolder(0))
				IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
				IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
				IN2G_AppendorReplaceWaveNote(tempname,"Units","1/cm")
				note MytempWave, ListOfParameters
				Redimension/D MytempWave
				Wave MytempWave=$("SADModelQPeak"+num2str(i)+"_"+num2str(ii))
				tempname="SADModelQPeak"+num2str(i)+"_"+num2str(ii)
				IN2G_AppendorReplaceWaveNote(tempname,"DataFrom",GetDataFolder(0))
				IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
				IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
				IN2G_AppendorReplaceWaveNote(tempname,"Units","1/cm")
				note MytempWave, ListOfParameters
				Redimension/D MytempWave
			endif
		endfor
	endif	

	setDataFolder OldDf	
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR2D_PanelSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_SAD
	ControlInfo/W=IR2D_ControlPanel DataTabs
	String whichTab=num2str(V_Value)
	if(stringMatch(ctrlName,"RgPrefactor"))
		if(varNum==0)
			NVAR Rg=root:Packages:Irena_SAD:Rg
			Rg=1e10
		endif
	endif
	
	//recalculate...
	IR2D_CalculateIntensity(0)
	//set step
	Execute ("SetVariable "+ctrlName+",limits={0,inf,"+num2str(0.03*varNum)+"}")
	//set limits
	if(!stringmatch(varName, "*par4*" ) && !stringmatch(varName, "*LinkMultiplier" ) )	//no change in limtis for eta
		if(V_Value>0)	//need to insert the peak number in it...
			ctrlName = ctrlName[0,3]+num2str(V_Value)+ctrlName[4,inf]
		endif
		NVAR LowLimit=$("root:Packages:Irena_SAD:"+ctrlName+"LowLimit")
		LowLimit=0.5*varNum
		NVAR HighLimit=$("root:Packages:Irena_SAD:"+ctrlName+"HighLimit")
		HighLimit=2*varNum
	endif
	setDataFolder OldDf
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR2D_InputPanelCheckboxProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_SAD


	if (cmpstr(ctrlName,"UseSMRData")==0)
		//here we control the data structure checkbox
		NVAR UseIndra2Data=root:Packages:Irena_SAD:UseIndra2Data
		NVAR UseQRSData=root:Packages:Irena_SAD:UseQRSData
		NVAR UseSMRData=root:Packages:Irena_SAD:UseSMRData
		SetVariable SlitLength,win=IR2D_ControlPanel, disable=!UseSMRData
		Checkbox UseIndra2Data,win=IR2D_ControlPanel, value=UseIndra2Data
		Checkbox UseQRSData,win=IR2D_ControlPanel, value=UseQRSData
		SVAR Dtf=root:Packages:Irena_SAD:DataFolderName
		SVAR IntDf=root:Packages:Irena_SAD:IntensityWaveName
		SVAR QDf=root:Packages:Irena_SAD:QWaveName
		SVAR EDf=root:Packages:Irena_SAD:ErrorWaveName
			Dtf=" "
			IntDf=" "
			QDf=" "
			EDf=" "
			PopupMenu SelectDataFolder,win=IR2D_ControlPanel, mode=1
			PopupMenu IntensityDataName,  mode=1,win=IR2D_ControlPanel, value="---"
			PopupMenu QvecDataName, mode=1,win=IR2D_ControlPanel, value="---"
			PopupMenu ErrorDataName, mode=1,win=IR2D_ControlPanel, value="---"
		//here we control the data structure checkbox
			PopupMenu SelectDataFolder,win=IR2D_ControlPanel, value= #"\"---;\"+IR1_GenStringOfFolders(root:Packages:Irena_SAD:UseIndra2Data, root:Packages:Irena_SAD:UseQRSData,root:Packages:Irena_SAD:UseSMRData,0)"
	elseif(!stringmatch(ctrlName,"DisplayPeaks") && !stringMatch(ctrlname,"AutoRecalculate") && !stringMatch(ctrlname,"Oversample"))
		Execute("Setvariable "+ctrlName[3,inf]+"LowLimit disable=!"+num2str(checked))
		Execute("Setvariable "+ctrlName[3,inf]+"HighLimit disable=!"+num2str(checked))
	endif
	
	if(stringmatch(ctrlName,"DisplayPeaks") || stringMatch(ctrlname,"AutoRecalculate") || stringMatch(ctrlname,"Oversample")|| stringMatch(ctrlname,"PeakSASScaling") )
		IR2D_CalculateIntensity(0)
	endif

	setDataFolder OldDF
end


///********************************************************************************************************
///********************************************************************************************************
///********************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2D_InputPanelCheckboxProc2(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_SAD


	NVAR AppendResiduals
	NVAR AppendNormalizedResiduals
	if(stringmatch(ctrlName,"AppendResiduals"))
		if(checked)
			AppendNormalizedResiduals=0
		endif
		IR2D_AppendRemoveResiduals()
	endif	
	if(stringmatch(ctrlName,"AppendNormalizedResiduals"))
		if(checked)
			AppendResiduals=0
		endif
		IR2D_AppendRemoveResiduals()
	endif	
	if(stringmatch(ctrlName,"UseLogX"))
		DoWindow IR2D_LogLogPlotSAD
		if(V_Flag)
			ModifyGraph log(bottom) =checked
		endif
	endif
	if(stringmatch(ctrlName,"UseLogY"))
		DoWindow IR2D_LogLogPlotSAD
		if(V_Flag)
			ModifyGraph log(left) =checked
		endif
	endif

	setDataFolder OldDF
end
///********************************************************************************************************
///********************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2D_AppendRemoveResiduals()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_SAD
	NVAR AppendResiduals
	NVAR AppendNormalizedResiduals
	Wave Residuals
	Wave ModelQvector
	Wave NormalizedResiduals
	
	CheckDisplayed /W=IR2D_LogLogPlotSAD  Residuals
	if(V_Flag && AppendResiduals)
		//do nothing
	elseif(V_Flag && !AppendResiduals)
		RemoveFromGraph 	/W=IR2D_LogLogPlotSAD  Residuals
		CheckDisplayed /W=IR2D_LogLogPlotSAD  NormalizedResiduals
		if(!V_Flag)
			ModifyGraph mirror(left)=1
		endif
	elseif(!V_Flag && AppendResiduals)
		CheckDisplayed /W=IR2D_LogLogPlotSAD  NormalizedResidual
		if(V_Flag)
			RemoveFromGraph 	/W=IR2D_LogLogPlotSAD  NormalizedResidual
			ModifyGraph mirror(left)=1
		endif
		AppendToGraph /W=IR2D_LogLogPlotSAD /R Residuals vs ModelQvector
		SetAxis/A=2/E=2 right
		ModifyGraph mode(Residuals)=3,marker(Residuals)=29,rgb(Residuals)=(0,0,0)
		Label right "Residuals"
	endif

	CheckDisplayed /W=IR2D_LogLogPlotSAD  NormalizedResiduals
	if(V_Flag && AppendNormalizedResiduals)
		//do nothing
	elseif(V_Flag && !AppendNormalizedResiduals)
		RemoveFromGraph 	/W=IR2D_LogLogPlotSAD  NormalizedResiduals
		CheckDisplayed /W=IR2D_LogLogPlotSAD  Residuals
		if(!V_Flag)
			ModifyGraph mirror(left)=1
		endif
	elseif(!V_Flag && AppendNormalizedResiduals)
		CheckDisplayed /W=IR2D_LogLogPlotSAD  Residuals
		if(V_Flag)
			RemoveFromGraph 	/W=IR2D_LogLogPlotSAD  Residuals
			ModifyGraph mirror(left)=1
		endif
		AppendToGraph /W=IR2D_LogLogPlotSAD /R NormalizedResiduals vs ModelQvector
		SetAxis/A=2/E=2 right
		ModifyGraph mode(NormalizedResiduals)=3,marker(NormalizedResiduals)=29,rgb(NormalizedResiduals)=(0,0,0)
		Label right "Normalized Residuals"
	endif


	setDataFolder OldDF
end
///********************************************************************************************************
///********************************************************************************************************
///********************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2D_GraphMeasuredData()
	//this function graphs data into the various graphs as needed
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_SAD
	SVAR DataFolderName
	SVAR IntensityWaveName
	SVAR QWavename
	SVAR ErrorWaveName
	variable cursorAposition, cursorBposition
	
	//fix for liberal names
	IntensityWaveName = PossiblyQuoteName(IntensityWaveName)
	QWavename = PossiblyQuoteName(QWavename)
	ErrorWaveName = PossiblyQuoteName(ErrorWaveName)
	
	WAVE/Z test=$(DataFolderName+IntensityWaveName)
	if (!WaveExists(test))
		abort "Error in IntensityWaveName wave selection"
	endif
	cursorAposition=0
	cursorBposition=numpnts(test)-1
	WAVE/Z test=$(DataFolderName+QWavename)
	if (!WaveExists(test))
		abort "Error in QWavename wave selection"
	endif
	WAVE/Z test=$(DataFolderName+ErrorWaveName)
	if (!WaveExists(test))
		abort "Error in ErrorWaveName wave selection"
	endif
	
	Duplicate/O $(DataFolderName+IntensityWaveName), OriginalIntensity
	Duplicate/O $(DataFolderName+QWavename), OriginalQvector
	Duplicate/O $(DataFolderName+ErrorWaveName), OriginalError
	Redimension/D OriginalIntensity, OriginalQvector, OriginalError
	
////test  Lorenzian correction
//OriginalIntensity = OriginalIntensity * OriginalQvector^2
//OriginalError = OriginalError *  OriginalQvector^2
////end of test for Lorenzian correction

	wavestats /Q OriginalQvector
	if(V_min<0)
		OriginalQvector = OriginalQvector[p]<=0 ? NaN : OriginalQvector[p] 
	endif
	IN2G_RemoveNaNsFrom3Waves(OriginalQvector,OriginalIntensity, OriginalError)
	NVAR/Z SubtractBackground=root:Packages:Irena_SAD:SubtractBackground
	NVAR/Z UseSMRData=root:Packages:Irena_SAD:UseSMRData
	if(stringmatch(IntensityWaveName, "*SMR_Int*" ))		// slit smeared data
		UseSMRData=1
		SetVariable SlitLength,win=IR2D_ControlPanel,disable=!UseSMRData
	elseif(stringmatch(IntensityWaveName, "*DSM_Int*" ))	//Indra 2 desmeared data
		UseSMRData=0
		SetVariable SlitLength,win=IR2D_ControlPanel,disable=!UseSMRData
	else
			//we have no clue what user input, leave it to him to deal with slit smearing
	endif

	if(NVAR_Exists(UseSMRData))
		if(UseSMRData)
			NVAR SlitLength=root:Packages:Irena_SAD:SlitLength
			variable tempSL1=NumberByKey("SlitLength", note(OriginalIntensity) , "=" , ";")
			if(numtype(tempSL1)==0)
				SlitLength=tempSL1
			endif
		endif
	endif
	
	
		DoWindow IR2D_LogLogPlotSAD
		if (V_flag)
			Dowindow/K IR2D_LogLogPlotSAD
		endif
		Execute ("IR2D_LogLogPlotSAD()")
	setDataFolder oldDf
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Proc  IR2D_LogLogPlotSAD() 
	PauseUpdate; Silent 1		// building window...
	String fldrSav= GetDataFolder(1)
	SetDataFolder root:Packages:Irena_SAD:
	Display /W=(400.75,37.25,959.75,508.25)/K=1  OriginalIntensity vs OriginalQvector as "LogLogPlot"
	DoWindow/C IR2D_LogLogPlotSAD
	ModifyGraph mode(OriginalIntensity)=3
	ModifyGraph msize(OriginalIntensity)=1
//	NVAR UseLogX=root:Packages:Irena_SAD:UseLogX
//	NVAR UseLogY=root:Packages:Irena_SAD:UseLogY
	if(UseLogX)
		ModifyGraph log(bottom) =1
	else
		ModifyGraph log(bottom)=0
	endif
	if(UseLogY)
		ModifyGraph log(left)=1
	else
		ModifyGraph log(left)=0
	endif
	ModifyGraph mirror=1
	ShowInfo
	String LabelStr= "\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"Intensity [cm\\S-1\\M\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"]"
	Label left LabelStr
	LabelStr= "\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"Q [A\\S-1\\M\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"]"
	Label bottom LabelStr
	string LegendStr="\\F"+IR2C_LkUpDfltStr("FontType")+"\\Z"+IR2C_LkUpDfltVar("LegendSize")+"\\s(OriginalIntensity) Experimental intensity"
	Legend/W=IR2D_LogLogPlotSAD/N=text0/J/F=0/A=MC/X=32.03/Y=38.79 LegendStr
	//
	ErrorBars/Y=1 OriginalIntensity Y,wave=(OriginalError,OriginalError)
	//and now some controls
	TextBox/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z"+IR2C_LkUpDfltVar("TagSize")+date()+", "+time()	
	TextBox/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z"+IR2C_LkUpDfltVar("TagSize")+DataFolderName+IntensityWaveName	
//	ControlBar 30
//	Button SaveStyle size={80,20}, pos={50,5},proc=IR1U_StyleButtonCotrol,title="Save Style"
//	Button ApplyStyle size={80,20}, pos={150,5},proc=IR1U_StyleButtonCotrol,title="Apply Style"
	SetDataFolder fldrSav
EndMacro

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************



Function IR2D_CalculateIntensity(force)
	variable force
	
	NVAR AutoRecalculate=root:Packages:Irena_SAD:AutoRecalculate
	if(!AutoRecalculate && !force)
		return 1
	endif
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_SAD

	NVAR Background=root:Packages:Irena_SAD:Background
	NVAR RgPrefactor=root:Packages:Irena_SAD:RgPrefactor
	NVAR Rg=root:Packages:Irena_SAD:Rg
	NVAR PwrLawSlope=root:Packages:Irena_SAD:PwrLawSlope
	NVAR PwrLawPref=root:Packages:Irena_SAD:PwrLawPref
	NVAR DisplayPeaks=root:Packages:Irena_SAD:DisplayPeaks
	NVAR SlitLength=root:Packages:Irena_SAD:SlitLength
	Wave/Z OriginalIntensity=root:Packages:Irena_SAD:OriginalIntensity
	Wave/Z OriginalQvector=root:Packages:Irena_SAD:OriginalQvector
	Wave/Z OriginalError=root:Packages:Irena_SAD:OriginalError
	NVAR UseSMRData = root:Packages:Irena_SAD:UseSMRData
	NVAR SlitLength = root:Packages:Irena_SAD:SlitLength
	NVAR Oversample = root:Packages:Irena_SAD:Oversample
	NVAR PeakSASScaling = root:Packages:Irena_SAD:PeakSASScaling

	if(!WaveExists(OriginalIntensity) || !WaveExists(OriginalQvector))
		abort
	endif
	variable startPoint, endPoint, i
	startPoint=0
	endPoint=numpnts(OriginalIntensity)-1
	if(strlen(CsrInfo(A,"IR2D_LogLogPlotSAD")))
		startPoint = pcsr(A,"IR2D_LogLogPlotSAD")
	endif
	if(strlen(CsrInfo(B,"IR2D_LogLogPlotSAD")))
		endPoint = pcsr(B,"IR2D_LogLogPlotSAD")
	endif
	Duplicate/O /R=[startpoint,endpoint]  OriginalQvector, ModelQvector
	Duplicate/O /R=[startpoint,endpoint]  OriginalError, TempErrors
	Duplicate/O /R=[startpoint,endpoint]  OriginalIntensity, ModelIntensity, tempInt, tempInt2, ResInt, Residuals, NormalizedResiduals

	SetScale/P x 0,1,"", ModelQvector, ModelIntensity, tempInt, Residuals, NormalizedResiduals

	//here we fix it in case of slit smeared data...
	variable OriginalNumPnts=numpnts(ModelQvector)
	variable OriginalNumPnts2=numpnts(ModelQvector)
	variable CurLength
	variable newLength
	variable DataLengths
	if(UseSMRData)
		DataLengths=numpnts(ModelQvector)							//get number of original data points
		variable Qstep=((ModelQvector[DataLengths-1]/ModelQvector[DataLengths-2])-1)*ModelQvector[DataLengths]
		variable ExtendByQ=sqrt(ModelQvector[DataLengths-1]^2 + (1.5*slitLength)^2) - ModelQvector[DataLengths-1]
		if (ExtendByQ<2.1*Qstep)
			ExtendByQ=2.1*Qstep
		endif
		variable NumNewPoints=floor(ExtendByQ/Qstep)	
		if (NumNewPoints<1)
			NumNewPoints=1
		endif	
		newLength=OriginalNumPnts +NumNewPoints				//New length of waves
		Redimension /N=(newLength) ModelQvector, ModelIntensity, tempInt, tempInt2
		For(i=0;i<=NumNewPoints;i+=1)									
			ModelQvector[OriginalNumPnts+i]=ModelQvector[OriginalNumPnts-1]+(ExtendByQ)*((i+1)/NumNewPoints)     	//extend Q
		EndFor
	endif
//end of slit smeared data 1 part...
	CurLength = numpnts(ModelQvector)
	if(Oversample)
		Duplicate/O ModelQvector, ShortQvector
		Redimension /N=(5*CurLength) ModelQvector, ModelIntensity, tempInt, tempInt2
		For(i=0;i<(5*CurLength);i+=5)
			ModelQvector[i] =  ShortQvector[i/5]
			ModelQvector[i+1] =  ShortQvector[i/5] +(1/5)*(ShortQvector[(i+5)/5] - ShortQvector[i/5])
			ModelQvector[i+2] =  ShortQvector[i/5] +(2/5)*(ShortQvector[(i+5)/5] - ShortQvector[i/5])
			ModelQvector[i+3] =  ShortQvector[i/5] +(3/5)*(ShortQvector[(i+5)/5] - ShortQvector[i/5])
			ModelQvector[i+4] =  ShortQvector[i/5] +(4/5)*(ShortQvector[(i+5)/5] - ShortQvector[i/5])
		endfor
		OriginalNumPnts = 5*CurLength
	endif

	SetScale/P x 0,1,"", ModelQvector, ModelIntensity, tempInt, tempInt2, Residuals, NormalizedResiduals, ResInt
	
	//calculate the intensity
	ModelIntensity = 0

	IR2D_UnifiedIntensity(ModelIntensity,ModelQvector,RgPrefactor,Rg,PwrLawPref,PwrLawSlope)	
	IR2D_UnifiedIntensity(tempInt2,ModelQvector,RgPrefactor,Rg,PwrLawPref,PwrLawSlope)	
	
	ModelIntensity+=Background
	
	//here we need to add the code which calculates the peaks... 
	Duplicate/O ModelIntensity, tempModelIntensity
//	NVAR PeakSASScaling = root:Packages:Irena_SAD:PeakSASScaling
	//set PeakSASScaling to 1 to have peaks separate, otherwise these are multiplied by Unified level intensity here... No background assumed. 
	For(i=1;i<=6;i+=1)
		IR2D_CalcOnePeakInt(i, tempInt, ModelQvector)
		if(PeakSASScaling)
			ModelIntensity+= tempInt
		else
			ModelIntensity+= tempInt* tempInt2	
		endif
	endfor
	
	if(UseSMRData)
		Duplicate/O ModelIntensity, SMModelIntensity
		IR1B_SmearData(ModelIntensity, ModelQvector, slitLength, SMModelIntensity)
		DeletePoints  (OriginalNumPnts), inf, SMModelIntensity, ModelQvector, ModelIntensity
		ModelIntensity = SMModelIntensity 
	endif
	if(Oversample)
		Duplicate/O ModelIntensity, CutMeModelIntensity
		Redimension /N=(OriginalNumPnts2) ModelIntensity
		For(i=0;i<(OriginalNumPnts2);i+=1)
			ModelIntensity[i] = CutMeModelIntensity[i*5]
		endfor
		Duplicate/O ShortQvector,ModelQvector
	endif
	//residuals
	Residuals = ResInt - ModelIntensity
	NormalizedResiduals = Residuals/TempErrors
	
////test Lorenz correction
//ModelIntensity = ModelIntensity * ModelQvector^2
//
////end test Lorenz correction	
	//now the local fits
	RemoveFromGraph /W=IR2D_LogLogPlotSAD /Z Peak1Intensity,Peak2Intensity,Peak3Intensity,Peak4Intensity,Peak5Intensity,Peak6Intensity
	KillWaves/Z Peak1Intensity,Peak2Intensity,Peak3Intensity,Peak4Intensity,Peak5Intensity,Peak6Intensity, ResInt, TempErrors, tempInt2
		For(i=1;i<=6;i+=1)
			NVAR usePk = $("root:Packages:Irena_SAD:UsePeak"+num2str(i))
			if(usePk)
				IR2D_CalcOnePeakInt(i, tempInt, ModelQvector)
				Duplicate/O tempInt, $("Peak"+num2str(i)+"Intensity") 
				SetScale/P x 0,1,"", tempInt
			endif
		endfor
		
		
	IR2D_AppendDataToGraph()
	IR2D_AppendRemoveResiduals()
	IR2D_UpdatePeakParams()
	setDataFolder oldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2D_UnifiedIntensity(ReturnInt,Qvector,G,Rg,B,P)
	variable G,Rg,B,P
	wave Qvector, ReturnInt
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_SAD
	Wave OriginalIntensity
	
	Duplicate /O Qvector, QstarVector
	
	variable K=1

	QstarVector=Qvector/(erf(K*Qvector*Rg/sqrt(6)))^3
	
	ReturnInt=G*exp(-Qvector^2*Rg^2/3)+(B/QstarVector^P)
	
	killWaves QstarVector
	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function  IR2D_CalcOnePeakInt(i, tempInt, qwv)
	variable i
	wave tempInt, qwv
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_SAD
	
	NVAR UsePeak=$("root:Packages:Irena_SAD:UsePeak"+num2str(i))	
	NVAR Par1=$("root:Packages:Irena_SAD:Peak"+num2str(i)+"_Par1")	
	NVAR Par2=$("root:Packages:Irena_SAD:Peak"+num2str(i)+"_Par2")	
	NVAR Par3=$("root:Packages:Irena_SAD:Peak"+num2str(i)+"_Par3")	
	NVAR Par4=$("root:Packages:Irena_SAD:Peak"+num2str(i)+"_Par4")	
	SVAR FunctionName=$("root:Packages:Irena_SAD:Peak"+num2str(i)+"_Function")	
	NVAR Peak_LinkPar2=$("root:Packages:Irena_SAD:Peak"+num2str(i)+"_LinkPar2")	
	NVAR Peak_LinkMultiplier=$("root:Packages:Irena_SAD:Peak"+num2str(i)+"_LinkMultiplier")	
	SVAR Peak_LinkedTo=$("root:Packages:Irena_SAD:Peak"+num2str(i)+"_LinkedTo")	
	
	if(Peak_LinkPar2)
		variable PeakLinkedTo=str2num(Peak_LinkedTo[4,inf])
		if(numtype(PeakLinkedTo)>0)
			abort  "Bad Peak number linked to peak "+num2str(i)
		endif
		NVAR Par2Linked=$("root:Packages:Irena_SAD:Peak"+num2str(PeakLinkedTo)+"_Par2")	
		Par2 = Par2Linked * Peak_LinkMultiplier
	endif

	tempInt = 0
	if(usePeak)
		if(stringmatch(FunctionName, "Gauss" ))
//			tempInt =Par1*exp(-((qwv-Par2)^2/Par3))
			tempInt = IR2D_Gauss(qwv,Par1,Par2,Par3) 
			//Par1 * IR1_GaussProbability(qwv,Par2,Par3, 0)
		endif
		if(stringmatch(FunctionName, "Lorenz" ))
			tempInt = IR2D_Lorenz(qwv,Par1,Par2,Par3)
			//tempInt =(1/pi) *  Par1 * Par3/((qwv-Par2)^2+Par3^2) 	//from formula 10 at
			//http://mathworld.wolfram.com/CauchyDistribution.html
		endif
		if(stringmatch(FunctionName, "Pseudo-Voigt" ))
			tempInt = Par4*(IR2D_Lorenz(qwv,Par1,Par2,Par3)) + (1-Par4) *IR2D_Gauss(qwv,Par1,Par2,Par3)
			//tempInt =(1/pi) *  Par1 * Par3/((qwv-Par2)^2+Par3^2) 	//from formula 10 at
			//http://mathworld.wolfram.com/CauchyDistribution.html
		endif
		if(stringmatch(FunctionName, "Gumbel" ))
			tempInt = IR2D_Gumbel(qwv,Par1,Par2,Par3,Par4)
			//NIST handbook on statistics
			//http://mathworld.wolfram.com/CauchyDistribution.html
		endif
		if(stringmatch(FunctionName, "Pearson_VII" ))
			tempInt = IR2D_PearsonVII(qwv,Par1,Par2,Par3,Par4)
			//NIST handbook on statistics
			//http://mathworld.wolfram.com/CauchyDistribution.html
		endif
		if(stringmatch(FunctionName, "Modif_Gauss" ))
			tempInt = IR2D_ModifGauss(qwv,Par1,Par2,Par3,Par4)
			//NIST handbook on statistics
			//http://mathworld.wolfram.com/CauchyDistribution.html
		endif
	endif
	 
	return 1
	setDataFolder oldDf
end

//*****************************************************************************************************************
Function IR2D_PearsonVII(x,Par1,Par2,Par3,Par4)
	variable x,Par1,Par2,Par3,Par4
	//this function calculates probability for Gauss (normal) distribution
	
	variable result
	//NIST handbook on statists...
	result=Par1 * (1+((x-Par2)^2 / (Par4*Par3^2)))^(-Par4)

	if (numtype(result)!=0)
		result=0
	endif
	
	return result
	
end

//*****************************************************************************************************************
Function IR2D_ModifGauss(x,Par1,Par2,Par3,Par4)
	variable x,Par1,Par2,Par3,Par4
	//this function calculates probability for Gauss (normal) distribution
	
	variable result
	//NIST handbook on statists...
	result=Par1 *exp(-0.5 * ((abs(x-Par2)/Par3)^Par4))

	if (numtype(result)!=0)
		result=0
	endif
	
	return result
	
end

//*****************************************************************************************************************
Function IR2D_Gumbel(x,Par1,Par2,Par3,Par4)
	variable x,Par1,Par2,Par3,Par4
	//this function calculates probability for Gauss (normal) distribution
	
	variable result
	//NIST handbook on statists...
	result=(Par1 /Par3)*exp((x-Par2)/Par3)*exp(-exp((x-Par2)/Par3))

	if (numtype(result)!=0)
		result=0
	endif
	
	return result
	
end

//*****************************************************************************************************************
Function IR2D_Gauss(x,Par1,Par2,Par3)
	variable x,Par1,Par2,Par3
	//this function calculates probability for Gauss (normal) distribution
	
	variable result
	
//	result=Par1 * (exp(-((x-Par2)^2)/(2*Par3^2)))/(Par3*(sqrt(2*pi)))
//used: http://books.google.com/books?id=P6Y7FRi9gW0C&pg=PA23&lpg=PA23&dq=%22pseudo+voigt%22+peak+shape+function&source=web&ots=Ejz1Fm95Jo&sig=coEWMIfGWu6yzeQIMzF7HK1E7Us#PPA23,M1

	result=Par1 * (exp(-ln(2) * ((x-Par2)/Par3)^2))

	if (numtype(result)!=0)
		result=0
	endif
	
	return result
	
end
//*****************************************************************************************************************
Function IR2D_Lorenz(x,Par1,Par2,Par3)
	variable x,Par1,Par2,Par3

	//		tempInt =(1/pi) *  Par1 * Par3/((qwv-Par2)^2+Par3^2) 	//from formula 10 at
	//used: http://books.google.com/books?id=P6Y7FRi9gW0C&pg=PA23&lpg=PA23&dq=%22pseudo+voigt%22+peak+shape+function&source=web&ots=Ejz1Fm95Jo&sig=coEWMIfGWu6yzeQIMzF7HK1E7Us#PPA23,M1
	
	variable result
	
	//result=(1/pi) *  Par1 * Par3/((x-Par2)^2+Par3^2) 
	result=Par1 * (1+((x-Par2)/Par3)^2)^(-1.5)

	if (numtype(result)!=0)
		result=0
	endif
	
	return result

end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR2D_AppendDataToGraph()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_SAD
	
	DoWindow IR2D_LogLogPlotSAD
	if(!V_Flag)
		abort
	endif
	NVAR DisplayPeaks=root:Packages:Irena_SAD:DisplayPeaks
	Wave/Z ModelIntensity=root:Packages:Irena_SAD:ModelIntensity
	Wave/Z ModelQvector=root:Packages:Irena_SAD:ModelQvector
	if(!WaveExists(ModelIntensity)||!WaveExists(ModelQvector))
		abort
	endif
	Checkdisplayed/W=IR2D_LogLogPlotSAD ModelIntensity
	if(!V_Flag)
		AppendToGraph /W=IR2D_LogLogPlotSAD  ModelIntensity vs ModelQvector
		ModifyGraph/W=IR2D_LogLogPlotSAD   lsize(ModelIntensity)=2,rgb(ModelIntensity)=(1,3,39321)
		SetAxis /W=IR2D_LogLogPlotSAD bottom, ModelQvector[0], ModelQvector[numpnts(ModelQvector)-1]
		wavestats/Q ModelIntensity
		SetAxis /W=IR2D_LogLogPlotSAD left,  V_min, V_max
		
	endif
	
	variable i
	For(i=0;i<=6;i+=1)
		Wave/Z PeakInt=$("Peak"+num2str(i)+"Intensity")
		if(WaveExists(PeakInt)&&DisplayPeaks)
			Checkdisplayed/W=IR2D_LogLogPlotSAD $("Peak"+num2str(i)+"Intensity")
			AppendToGraph /W=IR2D_LogLogPlotSAD  PeakInt vs ModelQvector
			ModifyGraph/W=IR2D_LogLogPlotSAD   lsize($("Peak"+num2str(i)+"Intensity"))=2,rgb($("Peak"+num2str(i)+"Intensity"))=(0,0,0)
		endif
	
	endfor
		//Peak1Intensity,Peak2Intensity,Peak3Intensity,Peak4Intensity,Peak5Intensity,Peak6Intensity
	setDataFolder oldDf
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2D_Fitting()
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_SAD


	//Create the fitting parameters, these will have _pop added and we need to add them to list of parameters to fit...
	string ListOfPeakVariables=""

	Make/O/N=0/T T_Constraints
	T_Constraints=""
	Make/D/N=0/O W_coef
	Make/O/N=(0,2) Gen_Constraints
	Make/T/N=0/O CoefNames
	CoefNames=""

	variable i,j //i goes through all items in list, j is 1 to 6 - populations
	variable Link2=1
	//first handle coefficients which are easy - those existing all the time... Volume is the only one at this time...
	ListOfPeakVariables="Peak1_Par;Peak2_Par;Peak3_Par;Peak4_Par;Peak5_Par;Peak6_Par;"	
	For(j=1;j<=6;j+=1)
		NVAR UseThePop = $("root:Packages:Irena_SAD:UsePeak"+num2str(j))
		if(UseThePop)
				//Parameter 1
				NVAR CurVarTested = $("root:Packages:Irena_SAD:Peak"+num2str(j)+"_Par1")
				NVAR FitCurVar=$("root:Packages:Irena_SAD:FitPeak"+num2str(j)+"_Par1")
				NVAR CuVarMin=$("root:Packages:Irena_SAD:Peak"+num2str(j)+"_Par1LowLimit")
				NVAR CuVarMax=$("root:Packages:Irena_SAD:Peak"+num2str(j)+"_Par1HighLimit")
				if (FitCurVar)		//are we fitting this variable?
					Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
					Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
					W_Coef[numpnts(W_Coef)-1]=CurVarTested
					CoefNames[numpnts(CoefNames)-1]="Peak"+num2str(j)+"_Par1"
					T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(CuVarMin)}
					T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(CuVarMax)}	
					Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
					Gen_Constraints[numpnts(CoefNames)-1][0] = CuVarMin
					Gen_Constraints[numpnts(CoefNames)-1][1] = CuVarMax
				endif
				//Parameter 2
				
				NVAR LinkPop = $("root:Packages:Irena_SAD:Peak"+num2str(j)+"_LinkPar2")
				Link2 = !LinkPop
				NVAR CurVarTested = $("root:Packages:Irena_SAD:Peak"+num2str(j)+"_Par2")
				NVAR FitCurVar=$("root:Packages:Irena_SAD:FitPeak"+num2str(j)+"_Par2")
				NVAR CuVarMin=$("root:Packages:Irena_SAD:Peak"+num2str(j)+"_Par2LowLimit")
				NVAR CuVarMax=$("root:Packages:Irena_SAD:Peak"+num2str(j)+"_Par2HighLimit")
				if (FitCurVar && Link2)		//are we fitting this variable?
					Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
					Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
					W_Coef[numpnts(W_Coef)-1]=CurVarTested
					CoefNames[numpnts(CoefNames)-1]="Peak"+num2str(j)+"_Par2"
					T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(CuVarMin)}
					T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(CuVarMax)}	
					Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
					Gen_Constraints[numpnts(CoefNames)-1][0] = CuVarMin
					Gen_Constraints[numpnts(CoefNames)-1][1] = CuVarMax
				endif
				//Parameter 3
				NVAR CurVarTested = $("root:Packages:Irena_SAD:Peak"+num2str(j)+"_Par3")
				NVAR FitCurVar=$("root:Packages:Irena_SAD:FitPeak"+num2str(j)+"_Par3")
				NVAR CuVarMin=$("root:Packages:Irena_SAD:Peak"+num2str(j)+"_Par3LowLimit")
				NVAR CuVarMax=$("root:Packages:Irena_SAD:Peak"+num2str(j)+"_Par3HighLimit")
				if (FitCurVar)		//are we fitting this variable?
					Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
					Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
					W_Coef[numpnts(W_Coef)-1]=CurVarTested
					CoefNames[numpnts(CoefNames)-1]="Peak"+num2str(j)+"_Par3"
					T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(CuVarMin)}
					T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(CuVarMax)}	
					Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
					Gen_Constraints[numpnts(CoefNames)-1][0] = CuVarMin
					Gen_Constraints[numpnts(CoefNames)-1][1] = CuVarMax
				endif
				//Parameter 4
				SVAR Peak_Function= $("root:Packages:Irena_SAD:Peak"+num2str(j)+"_Function") 
				NVAR CurVarTested = $("root:Packages:Irena_SAD:Peak"+num2str(j)+"_Par4")
				NVAR FitCurVar=$("root:Packages:Irena_SAD:FitPeak"+num2str(j)+"_Par4")
				NVAR CuVarMin=$("root:Packages:Irena_SAD:Peak"+num2str(j)+"_Par4LowLimit")
				NVAR CuVarMax=$("root:Packages:Irena_SAD:Peak"+num2str(j)+"_Par4HighLimit")
				if (FitCurVar && stringmatch(Peak_Function,"Pseudo-Voigt"))		//are we fitting this variable?
					Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
					Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
					W_Coef[numpnts(W_Coef)-1]=CurVarTested
					CoefNames[numpnts(CoefNames)-1]="Peak"+num2str(j)+"_Par4"
					T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(CuVarMin)}
					T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(CuVarMax)}	
					Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
					Gen_Constraints[numpnts(CoefNames)-1][0] = CuVarMin
					Gen_Constraints[numpnts(CoefNames)-1][1] = CuVarMax
				endif
		endif	
	endfor
	
	//Now background... 
	string ListOfDataVariables="Background;PwrLawPref;PwrLawSlope;Rg;RgPrefactor;"
			For(i=0;i<ItemsInList(ListOfDataVariables);i+=1)
				NVAR CurVarTested = $("root:Packages:Irena_SAD:"+stringfromList(i,ListOfDataVariables))
				NVAR FitCurVar=$("root:Packages:Irena_SAD:Fit"+stringfromList(i,ListOfDataVariables))
				NVAR CuVarMin=$("root:Packages:Irena_SAD:"+stringfromList(i,ListOfDataVariables)+"LowLimit")
				NVAR CuVarMax=$("root:Packages:Irena_SAD:"+stringfromList(i,ListOfDataVariables)+"HighLimit")
				if (FitCurVar)		//are we fitting this variable?
					Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
					Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
					W_Coef[numpnts(W_Coef)-1]=CurVarTested
					CoefNames[numpnts(CoefNames)-1]=stringfromList(i,ListOfDataVariables)
					T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(CuVarMin)}
					T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(CuVarMax)}		
					Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
					Gen_Constraints[numpnts(CoefNames)-1][0] = CuVarMin
					Gen_Constraints[numpnts(CoefNames)-1][1] = CuVarMax
				endif
			endfor

	//Ok, all parameters should be dealt with, now the fitting... 
//	DoWindow /F LSQF_MainGraph
//	variable QstartPoint, QendPoint
//	Make/O/N=0 QWvForFit, IntWvForFit, EWvForFit
	Wave/Z OriginalIntensity=root:Packages:Irena_SAD:OriginalIntensity
	Wave/Z OriginalQvector=root:Packages:Irena_SAD:OriginalQvector
	Wave/Z OriginalError=root:Packages:Irena_SAD:OriginalError
//	Wave/Z ModelIntensity=root:Packages:Irena_SAD:ModelIntensity
//	if(!WaveExists(ModelIntensity))
//		IR2D_CalculateIntensity(1)
//	endif
	NVAR UseGeneticOptimization=root:Packages:Irena_SAD:UseGeneticOptimization

	if(!WaveExists(OriginalIntensity) || !WaveExists(OriginalQvector))
		abort
	endif
	variable startPoint, endPoint
	startPoint=0
	endPoint=numpnts(OriginalIntensity)-1
	if(strlen(CsrInfo(A,"IR2D_LogLogPlotSAD")))
		startPoint = pcsr(A,"IR2D_LogLogPlotSAD")
	endif
	if(strlen(CsrInfo(B,"IR2D_LogLogPlotSAD")))
		endPoint = pcsr(B,"IR2D_LogLogPlotSAD")
	endif
	Duplicate/O /R=[startpoint,endpoint]  OriginalQvector, QvectorForFit
	Duplicate/O /R=[startpoint,endpoint]  OriginalIntensity, IntensityForFit
	Duplicate/O /R=[startpoint,endpoint]  OriginalError, ErrorForFit
	
	
	if(numpnts(W_Coef)<1)
		DoAlert 0, "Nothing to fit, select at least 1 parameter to fit"
		return 1
	endif

	Duplicate/O W_Coef, E_wave, CoefficientInput
	E_wave=W_coef/20
	Variable V_chisq
	string HoldStr=""
	For(i=0;i<numpnts(CoefficientInput);i+=1)
		HoldStr+="0"
	endfor
	Duplicate/O IntensityForFit, MaskWaveGenOpt
	MaskWaveGenOpt=1
	
	if(UseGeneticOptimization)
		IR2D_CheckFittingParamsFnct()
		PauseForUser IR2D_CheckFittingParams
	endif
	NVAR UserCanceled=root:Packages:Irena_SAD:UserCanceled
	if (UserCanceled)
		setDataFolder OldDf
		abort
	endif


	IR2D_RecordResults("before")
//	Duplicate/O IntensityForFit, tempDestWave
	Variable V_FitError=0			//This should prevent errors from being generated
	//and now the fit...
	if(UseGeneticOptimization)
#if Exists("gencurvefit")
	  	gencurvefit  /I=1 /W=ErrorForFit /M=MaskWaveGenOpt /N /TOL=0.002 /K={50,20,0.7,0.5} /X=QvectorForFit IR2D_FitFunction, IntensityForFit  , W_Coef, HoldStr, Gen_Constraints  	
#else
	  	GEN_curvefit("IR2D_FitFunction",W_Coef,IntensityForFit,HoldStr,x=QvectorForFit,w=ErrorForFit,c=Gen_Constraints, mask=MaskWaveGenOpt, popsize=20,k_m=0.7,recomb=0.5,iters=50,tol=0.002)	
#endif
	else
		FuncFit /N/Q IR2D_FitFunction W_coef IntensityForFit /X=QvectorForFit /W=ErrorForFit /I=1/E=E_wave /D /C=T_Constraints 
	endif

	if (V_FitError!=0)	//there was error in fitting
		IR2D_ResetParamsAfterBadFit()
		Abort "Fitting error, check starting parameters and fitting limits" 
	else		//results OK, make sure the resulting values are set 
		variable NumParams=numpnts(CoefNames)
		string ParamName
		For(i=0;i<NumParams;i+=1)
			ParamName = CoefNames[i]
			NVAR TempVar = $(ParamName)
			TempVar=W_Coef[i]
		endfor
		print "Achieved chi-square = "+num2str(V_chisq)
	endif
	
	variable/g AchievedChisq=V_chisq
	IR2D_RecordResults("after")
	KillWaves T_Constraints, E_wave
	
//	IR2L_CalculateIntensity(1,0)

	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2D_CheckFittingParamsFnct() 
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1/W=(400,140,870,600) as "Check fitting parameters"
	Dowindow/C IR2D_CheckFittingParams
	SetDrawLayer UserBack
	SetDrawEnv fsize= 20,fstyle= 3,textrgb= (0,0,65280)
	DrawText 39,28,"Small angle diffraction Fit Params & Limits"
	NVAR UseGeneticOptimization=root:Packages:Irena_SAD:UseGeneticOptimization
	if(UseGeneticOptimization)
		SetDrawEnv fstyle= 1,fsize= 14
		DrawText 10,50,"For Gen Opt. verify fitted parameters. Make sure"
		SetDrawEnv fstyle= 1,fsize= 14
		DrawText 10,70,"the parameter range is appropriate."
		SetDrawEnv fstyle= 1,fsize= 14
		DrawText 10,90,"The whole range must be valid! It will be tested!"
		SetDrawEnv fstyle= 1,fsize= 14
		DrawText 10,110,"       Then continue....."
	else
		SetDrawEnv fstyle= 1,fsize= 14
		DrawText 17,55,"Verify the list of fitted parameters."
		SetDrawEnv fstyle= 1,fsize= 14
		DrawText 17,75,"        Then continue......"
	endif
	Button CancelBtn,pos={27,420},size={150,20},proc=IR2D_CheckFitPrmsButtonProc,title="Cancel fitting"
	Button ContinueBtn,pos={187,420},size={150,20},proc=IR2D_CheckFitPrmsButtonProc,title="Continue fitting"
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:Irena_SAD:
	Wave Gen_Constraints,W_coef
	Wave/T CoefNames
	SetDimLabel 1,0,Min,Gen_Constraints
	SetDimLabel 1,1,Max,Gen_Constraints
	variable i
	For(i=0;i<numpnts(CoefNames);i+=1)
		SetDimLabel 0,i,$(CoefNames[i]),Gen_Constraints
	endfor
	if(UseGeneticOptimization)
		Edit/W=(0.05,0.25,0.95,0.865)/HOST=#  Gen_Constraints.ld,W_coef
//		ModifyTable format(Point)=1,width(Point)=0, width(Gen_Constraints)=110
//		ModifyTable alignment(W_coef)=1,sigDigits(W_coef)=4,title(W_coef)="Curent value"
//		ModifyTable alignment(Gen_Constraints)=1,sigDigits(Gen_Constraints)=4,title(Gen_Constraints)="Limits"
//		ModifyTable statsArea=85
		ModifyTable format(Point)=1,width(Point)=0,alignment(W_coef.y)=1,sigDigits(W_coef.y)=4
		ModifyTable width(W_coef.y)=90,title(W_coef.y)="Start value",width(Gen_Constraints.l)=172
//		ModifyTable title[1]="Min"
//		ModifyTable title[2]="Max"
		ModifyTable alignment(Gen_Constraints.d)=1,sigDigits(Gen_Constraints.d)=4,width(Gen_Constraints.d)=72
		ModifyTable title(Gen_Constraints.d)="Limits"
//		ModifyTable statsArea=85
//		ModifyTable statsArea=20
	else
		Edit/W=(0.05,0.18,0.95,0.865)/HOST=#  CoefNames
		ModifyTable format(Point)=1,width(Point)=0,width(CoefNames)=144,title(CoefNames)="Fitted Coef Name"
//		ModifyTable statsArea=85
	endif
	SetDataFolder fldrSav0
	RenameWindow #,T0
	SetActiveSubwindow ##
End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2D_CheckFitPrmsButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	if(stringmatch(ctrlName,"*CancelBtn*"))
		variable/g root:Packages:Irena_SAD:UserCanceled=1
		DoWindow/K IR2D_CheckFittingParams
	endif

	if(stringmatch(ctrlName,"*ContinueBtn*"))
		variable/g root:Packages:Irena_SAD:UserCanceled=0
		DoWindow/K IR2D_CheckFittingParams
	endif

End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2D_FitFunction(w,yw,xw) : FitFunc
	Wave w,yw,xw
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_SAD
	variable i

	Wave/T CoefNames
	variable NumParams=numpnts(CoefNames)
	string ParamName
	
	For(i=0;i<NumParams;i+=1)
		ParamName = CoefNames[i]
		NVAR TempVar = $(ParamName)
		TempVar=w[i]
	endfor
	IR2D_CalculateIntensity(1)
	Wave ModelIntensity
	yw = ModelIntensity
	
	setDataFolder oldDF
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR2D_RecordResults(CalledFromWere)
	string CalledFromWere	//before or after - that means fit...

	string OldDF=GetDataFolder(1)
	setdataFolder root:Packages:Irena_SAD
	variable i, j
	IR1_CreateLoggbook()		//this creates the logbook
	SVAR nbl=root:Packages:SAS_Modeling:NotebookName
	IR1L_AppendAnyText("     ")
	if (cmpstr(CalledFromWere,"before")==0)
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("Parameters before starting Small-angle diffraction on the data from: ")
		IR1_InsertDateAndTime(nbl)
	else			//after
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("Results of the Small-angle diffraction on the data from: ")	
		IR1_InsertDateAndTime(nbl)
	endif
	SVAR DataFolderName
	SVAR IntensityWaveName
	SVAR QWavename
	SVAR ErrorWaveName
	NVAR/Z AchievedChiSq
	IR1L_AppendAnyText("Data folder    : "+DataFolderName)
	IR1L_AppendAnyText("Intensity     : "+IntensityWaveName)
	IR1L_AppendAnyText("Qvector     : "+QWavename)
	IR1L_AppendAnyText("Error     : "+ErrorWaveName)
	if(NVAR_Exists(AchievedChiSq))
		IR1L_AppendAnyText("Achieved chi^2     : "+num2str(AchievedChiSq))
	endif	
	string 	ListOfVariables="Background;RgPrefactor;Rg;PwrLawPref;PwrLawSlope;"
	for(j=0;j<ItemsInList(ListOfVariables);j+=1)
		NVAR testVar=$(stringFromList(j,ListOfVariables))
		IR1L_AppendAnyText(stringFromList(j,ListOfVariables) +"    : "+num2str(testVar))
	endfor

	string 	tempName
	ListOfVariables="PeakX_Par1;PeakX_Par2;PeakX_Par3;PeakX_Par4;PeakPositionX;PeakFWHMX;PeakIntgIntX;"
	for(i=1;i<=6;i+=1)
		NVAR Useme=$("usePeak"+num2str(i))
		if(UseMe)
			IR1L_AppendAnyText("******************")
			IR1L_AppendAnyText("Included peak number     : "+num2str(i))
			SVAR PeakFnct=$("Peak"+num2str(i)+"_Function")
			IR1L_AppendAnyText("Peak function     : "+PeakFnct)
			NVAR Peak_LinkPar2=$("Peak"+num2str(i)+"_LinkPar2")
			if(Peak_LinkPar2)
				SVAR LinkedTo=$("Peak"+num2str(i)+"_LinkedTo")
				IR1L_AppendAnyText("Position of this peak was linked to      : "+LinkedTo)
			endif
			for(j=0;j<ItemsInList(ListOfVariables);j+=1)
				tempName = ReplaceString("X", stringFromList(j,ListOfVariables), num2str(i))
				NVAR testVar=$(tempName)
				IR1L_AppendAnyText(tempName +"    : "+num2str(testVar))
			endfor
		endif
	endfor

	setdataFolder oldDf

end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2D_ResetParamsAfterBadFit()
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_SAD
	variable i
	Wave/Z w=root:Packages:Irena_SAD:CoefficientInput
	Wave/T/Z CoefNames=root:Packages:Irena_SAD:CoefNames		//text wave with names of parameters

	if(!WaveExists(w) || !WaveExists(CoefNames))
		abort
	endif
	
	variable NumParams=numpnts(CoefNames)
	string ParamName
	
	For(i=0;i<NumParams;i+=1)
		ParamName = CoefNames[i]
		NVAR TempVar = $(ParamName)
		TempVar=w[i]
	endfor

	IR2D_CalculateIntensity(1)

	setDataFolder oldDF
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2D_UpdatePeakParams()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_SAD
	variable i
	For(i=1;i<=6;i+=1)
		NVAR usePk = $("root:Packages:Irena_SAD:UsePeak"+num2str(i))
		Wave/Z Intensity=$("Peak"+num2str(i)+"Intensity") 
		Wave/Z Qvec=ModelQvector 
		if(usePk && WaveExists(Intensity))
			NVAR PeakDPosition=$("PeakDPosition"+num2str(i))
			NVAR PeakPosition=$("PeakPosition"+num2str(i))
			NVAR PeakFWHM=$("PeakFWHM"+num2str(i))
			NVAR PeakIntgInt=$("PeakIntgInt"+num2str(i))
			PeakIntgInt = areaXY(Qvec, Intensity )
			wavestats/Q Intensity
			PeakPosition = Qvec[V_maxloc]
			PeakDPosition = 2*pi/PeakPosition
			FindLevels/Q  Intensity, V_max/2 
			Wave W_FindLevels
			PeakFWHM = abs(Qvec[W_FindLevels[1]] - Qvec[W_FindLevels[0]])
		endif
	endfor

	setDataFolder oldDF
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2D_RemoveTagsFromGraph()

	variable i
	string TagName
	For(i=1;i<=6;i+=1)
		TagName  = "peakTag"+num2str(i)
		Tag/K/W=IR2D_LogLogPlotSAD /N=$(TagName)
	endfor
	
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2D_AppendTagsToGraph()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_SAD
	variable i, LocationPnt
	string TagName, TagText
	For(i=1;i<=6;i+=1)
		NVAR usePk = $("root:Packages:Irena_SAD:UsePeak"+num2str(i))
		Wave/Z Qvec=ModelQvector 
		if(usePk)
			NVAR PeakDPosition=$("PeakDPosition"+num2str(i))
			NVAR PeakPosition=$("PeakPosition"+num2str(i))
			NVAR PeakFWHM=$("PeakFWHM"+num2str(i))
			NVAR PeakIntgInt=$("PeakIntgInt"+num2str(i))
			TagName  = "peakTag"+num2str(i)
			LocationPnt = BinarySearch(Qvec, PeakPosition )
			TagText="\\Z"+IR2C_LkUpDfltVar("TagSize")+"Peak number "+num2str(i)+"\r"
			TagText+="Peak Position (d) = "+num2str(PeakDPosition)+"  [A]\r"
			TagText+="Peak Position (Q) = "+num2str(PeakPosition)+"  [A^-1]\r"
			TagText+="Peak Integral intensity = "+num2str(PeakIntgInt)+"\r"
			TagText+="Peak FWHM (Q) = "+num2str(PeakFWHM)+" [A^-1]"
			Tag/C/W=IR2D_LogLogPlotSAD /N=$(TagName)/F=0/L=2/TL=0 ModelIntensity, LocationPnt, TagText
			
		endif
	endfor

	setDataFolder oldDF
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************