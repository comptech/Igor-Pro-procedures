#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.01
//version 2.01 adds the Analyze Results

//This macro file is part of Igor macros package called "Irena", 
//the full package should be available from www.uni.aps.anl.gov/~ilavsky
//this package contains 
// Igor functions for modeling of SAS from various distributions of scatterers...

//Jan Ilavsky, March 2002

//please, read Readme in the distribution zip file with more details on the program
//report any problems to: ilavsky@aps.anl.gov 
//main functions for modeling with user input of distributions...

//comment :
// the invariant is:
//   2*pi^2*FI(1-FI)*delta-rho-squared
// Need to convert the Unified provided invariant to cm^-4 by multiplying by 10^24 (from cm^-1A^-3 to cm^-4)



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1A_UnifiedModel()

	IN2G_CheckScreenSize("height",670)
	
	DoWindow IR1A_ControlPanel
	if (V_Flag)
		DoWindow/K IR1A_ControlPanel	
	endif
	DoWindow IR1_LogLogPlotU
	if (V_Flag)
		DoWindow/K IR1_LogLogPlotU	
	endif
	DoWindow IR1_IQ4_Q_PlotU
	if (V_Flag)
		DoWindow/K IR1_IQ4_Q_PlotU	
	endif

	IR1A_Initialize(0)					//this may be OK now... 
//	IR1_KillGraphsAndPanels()
	Execute ("IR1A_ControlPanel()")
end

Function IR1A_ResetUnified()
	IR1A_Initialize(1)					//this may be OK now... 
	DoWindow IR1A_ControlPanel
	if(V_Flag)
		IR1A_TabPanelControl("",0)
	endif	
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1A_Initialize(enforceReset)
	variable enforceReset
	//function, which creates the folder for SAS modeling and creates the strings and variables
	
	string oldDf=GetDataFolder(1)
	
	NewDataFolder/O/S root:Packages
	NewdataFolder/O/S root:Packages:Irena_UnifFit
	
	string ListOfVariables
	string ListOfStrings
	
	//here define the lists of variables and strings needed, separate names by ;...
	
	ListOfVariables="UseIndra2Data;UseQRSdata;NumberOfLevels;SubtractBackground;UseSMRData;SlitLengthUnif;"
	ListOfVariables+="Level1Rg;Level1FitRg;Level1RgLowLimit;Level1RgHighLimit;Level1G;Level1FitG;Level1GLowLimit;Level1GHighLimit;"
	ListOfVariables+="Level1RgStep;Level1GStep;Level1PStep;Level1BStep;Level1EtaStep;Level1PackStep;"
	ListOfVariables+="Level1P;Level1FitP;Level1PLowLimit;Level1PHighLimit;Level1B;Level1FitB;Level1BLowLimit;Level1BHighLimit;"
	ListOfVariables+="Level1ETA;Level1FitETA;Level1ETALowLimit;Level1ETAHighLimit;Level1PACK;Level1FitPACK;Level1PACKLowLimit;Level1PACKHighLimit;"
	ListOfVariables+="Level1RgCO;Level1LinkRgCO;Level1FitRgCO;Level1RgCOLowLimit;Level1RgCOHighLimit;Level1K;"
	ListOfVariables+="Level1Corelations;Level1MassFractal;Level1DegreeOfAggreg;Level1SurfaceToVolRat;Level1Invariant;"
	ListOfVariables+="Level1RgError;Level1GError;Level1PError;Level1BError;Level1ETAError;Level1PACKError;Level1RGCOError;"
	ListOfVariables+="Level2Rg;Level2FitRg;Level2RgLowLimit;Level2RgHighLimit;Level2G;Level2FitG;Level2GLowLimit;Level2GHighLimit;"
	ListOfVariables+="Level2RgStep;Level2GStep;Level2PStep;Level2BStep;Level2EtaStep;Level2PackStep;"
	ListOfVariables+="Level2P;Level2FitP;Level2PLowLimit;Level2PHighLimit;Level2B;Level2FitB;Level2BLowLimit;Level2BHighLimit;"
	ListOfVariables+="Level2ETA;Level2FitETA;Level2ETALowLimit;Level2ETAHighLimit;Level2PACK;Level2FitPACK;Level2PACKLowLimit;Level2PACKHighLimit;"
	ListOfVariables+="Level2RgCO;Level2LinkRgCO;Level2FitRgCO;Level2RgCOLowLimit;Level2RgCOHighLimit;Level2K;"
	ListOfVariables+="Level2Corelations;Level2MassFractal;Level2DegreeOfAggreg;Level2SurfaceToVolRat;Level2Invariant;"
	ListOfVariables+="Level2RgError;Level2GError;Level2PError;Level2BError;Level2ETAError;Level2PACKError;Level2RGCOError;"
	ListOfVariables+="Level3Rg;Level3FitRg;Level3RgLowLimit;Level3RgHighLimit;Level3G;Level3FitG;Level3GLowLimit;Level3GHighLimit;"
	ListOfVariables+="Level3RgStep;Level3GStep;Level3PStep;Level3BStep;Level3EtaStep;Level3PackStep;"
	ListOfVariables+="Level3P;Level3FitP;Level3PLowLimit;Level3PHighLimit;Level3B;Level3FitB;Level3BLowLimit;Level3BHighLimit;"
	ListOfVariables+="Level3ETA;Level3FitETA;Level3ETALowLimit;Level3ETAHighLimit;Level3PACK;Level3FitPACK;Level3PACKLowLimit;Level3PACKHighLimit;"
	ListOfVariables+="Level3RgCO;Level3LinkRgCO;Level3FitRgCO;Level3RgCOLowLimit;Level3RgCOHighLimit;Level3K;"
	ListOfVariables+="Level3Corelations;Level3MassFractal;Level3DegreeOfAggreg;Level3SurfaceToVolRat;Level3Invariant;"
	ListOfVariables+="Level3RgError;Level3GError;Level3PError;Level3BError;Level3ETAError;Level3PACKError;Level3RGCOError;"
	ListOfVariables+="Level4Rg;Level4FitRg;Level4RgLowLimit;Level4RgHighLimit;Level4G;Level4FitG;Level4GLowLimit;Level4GHighLimit;"
	ListOfVariables+="Level4RgStep;Level4GStep;Level4PStep;Level4BStep;Level4EtaStep;Level4PackStep;"
	ListOfVariables+="Level4P;Level4FitP;Level4PLowLimit;Level4PHighLimit;Level4B;Level4FitB;Level4BLowLimit;Level4BHighLimit;"
	ListOfVariables+="Level4ETA;Level4FitETA;Level4ETALowLimit;Level4ETAHighLimit;Level4PACK;Level4FitPACK;Level4PACKLowLimit;Level4PACKHighLimit;"
	ListOfVariables+="Level4RgCO;Level4LinkRgCO;Level4FitRgCO;Level4RgCOLowLimit;Level4RgCOHighLimit;Level4K;"
	ListOfVariables+="Level4Corelations;Level4MassFractal;Level4DegreeOfAggreg;Level4SurfaceToVolRat;Level4Invariant;"
	ListOfVariables+="Level4RgError;Level4GError;Level4PError;Level4BError;Level4ETAError;Level4PACKError;Level4RGCOError;"
	ListOfVariables+="Level5Rg;Level5FitRg;Level5RgLowLimit;Level5RgHighLimit;Level5G;Level5FitG;Level5GLowLimit;Level5GHighLimit;"
	ListOfVariables+="Level5RgStep;Level5GStep;Level5PStep;Level5BStep;Level5EtaStep;Level5PackStep;"
	ListOfVariables+="Level5P;Level5FitP;Level5PLowLimit;Level5PHighLimit;Level5B;Level5FitB;Level5BLowLimit;Level5BHighLimit;"
	ListOfVariables+="Level5ETA;Level5FitETA;Level5ETALowLimit;Level5ETAHighLimit;Level5PACK;Level5FitPACK;Level5PACKLowLimit;Level5PACKHighLimit;"
	ListOfVariables+="Level5RgCO;Level5LinkRgCO;Level5FitRgCO;Level5RgCOLowLimit;Level5RgCOHighLimit;Level5K;"
	ListOfVariables+="Level5Corelations;Level5MassFractal;Level5DegreeOfAggreg;Level5SurfaceToVolRat;Level5Invariant;"
	ListOfVariables+="Level5RgError;Level5GError;Level5PError;Level5BError;Level5ETAError;Level5PACKError;Level5RGCOError;"
	ListOfVariables+="SASBackground;SASBackgroundError;SASBackgroundStep;FitSASBackground;UpdateAutomatically;DisplayLocalFits;ActiveTab;ExportLocalFIts;"


	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;"
	
	variable i
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	//cleanup after possible previous fitting stages...
	Wave/Z CoefNames=root:Packages:Irena_UnifFit:CoefNames
	Wave/Z CoefficientInput=root:Packages:Irena_UnifFit:CoefficientInput
	KillWaves/Z CoefNames, CoefficientInput
	
//	Execute ("IR1A_SetInitialValues()")										
	IR1A_SetInitialValues(enforceReset)			
	setDataFolder OldDF							
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1A_SetInitialValues(enforce)
	variable enforce
	//and here set default values...

	string OldDf=getDataFolder(1)
	setDataFolder root:Packages:Irena_UnifFit
	
	string ListOfVariables
	variable i
	//here we set what needs to be 0
	ListOfVariables="NumberOfLevels;Level1FitRg;Level1FitG;Level1FitP;Level1FitB;Level1FitETA;Level1FitPACK;Level1FitRgCO;Level1MassFractal;Level1LinkRgCO;Level1Corelations;"
	ListOfVariables+="Level2FitRg;Level2FitG;Level2FitP;Level2FitB;Level2FitETA;Level2FitPACK;Level2FitRgCO;Level2MassFractal;Level2LinkRgCO;Level2Corelations;"
	ListOfVariables+="Level3FitRg;Level3FitG;Level3FitP;Level3FitB;Level3FitETA;Level3FitPACK;Level3FitRgCO;Level3MassFractal;Level3LinkRgCO;Level3Corelations;"
	ListOfVariables+="Level4FitRg;Level4FitG;Level4FitP;Level4FitB;Level4FitETA;Level4FitPACK;Level4FitRgCO;Level4MassFractal;Level4LinkRgCO;Level4Corelations;"
	ListOfVariables+="Level5FitRg;Level5FitG;Level5FitP;Level5FitB;Level5FitETA;Level5FitPACK;Level5FitRgCO;Level5MassFractal;Level5LinkRgCO;Level5Corelations;"
	ListOfVariables+="FitSASBackground;UpdateAutomatically;DisplayLocalFits;ActiveTab;DisplayLocalFits;UseIndra2Data;UseRQSdata;SubtractBackground;UseSMRData;SlitLengthUnif;"
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if(enforce)
			testVar=0
		endif
	endfor

	ListOfVariables="Level1RgCO;Level2RgCO;Level3RgCO;Level4RgCO;Level5RgCO;"
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (enforce)
			testVar=0
		endif
	endfor
	
	//and here values to 0.000001
	ListOfVariables="Level1RgLowLimit;Level1GLowLimit;Level1PLowLimit;Level1BLowLimit;Level1ETALowLimit;Level1RgCOLowLimit;"
	ListOfVariables+="Level2RgLowLimit;Level2GLowLimit;Level2PLowLimit;Level2BLowLimit;Level2ETALowLimit;Level2RgCOLowLimit;"
	ListOfVariables+="Level3RgLowLimit;Level3GLowLimit;Level3PLowLimit;Level3BLowLimit;Level3ETALowLimit;Level3RgCOLowLimit;"
	ListOfVariables+="Level4RgLowLimit;Level4GLowLimit;Level4PLowLimit;Level4BLowLimit;Level4ETALowLimit;Level4RgCOLowLimit;"
	ListOfVariables+="Level5RgLowLimit;Level5GLowLimit;Level5PLowLimit;Level5BLowLimit;Level5ETALowLimit;Level5RgCOLowLimit;"
	ListOfVariables+="SASBackground;SASBackgroundStep;"

	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0 || enforce)
			testVar=0.000001
		endif
	endfor
	
	
	//and here to 1
	ListOfVariables="Level1RgStep;Level1GStep;Level1PStep;Level1BStep;Level1EtaStep;Level1K;"
	ListOfVariables+="Level2RgStep;Level2GStep;Level2PStep;Level2BStep;Level2EtaStep;Level2K;"
	ListOfVariables+="Level3RgStep;Level3GStep;Level3PStep;Level3BStep;Level3EtaStep;Level3K;"
	ListOfVariables+="Level4RgStep;Level4GStep;Level4PStep;Level4BStep;Level4EtaStep;Level4K;"
	ListOfVariables+="Level5RgStep;Level5GStep;Level5PStep;Level5BStep;Level5EtaStep;Level5K;"
	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0 || enforce)
			testVar=1
		endif
	endfor

	//and here to 0.1
	ListOfVariables="Level1PackStep;Level2PackStep;Level3PackStep;Level4PackStep;Level5PackStep;"
	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0 || enforce)
			testVar=0.1
		endif
	endfor
		
	//here top limit, test 10 000	
	ListOfVariables="Level1RgHighLimit;Level1GHighLimit;Level1BHighLimit;Level1ETAHighLimit;Level1RgCOHighLimit;"
	ListOfVariables+="Level2RgHighLimit;Level2GHighLimit;Level2BHighLimit;Level2ETAHighLimit;Level2RgCOHighLimit;"
	ListOfVariables+="Level3RgHighLimit;Level3GHighLimit;Level3BHighLimit;Level3ETAHighLimit;Level3RgCOHighLimit;"
	ListOfVariables+="Level4RgHighLimit;Level4GHighLimit;Level4BHighLimit;Level4ETAHighLimit;Level4RgCOHighLimit;"
	ListOfVariables+="Level5RgHighLimit;Level5GHighLimit;Level5BHighLimit;Level5ETAHighLimit;Level5RgCOHighLimit;"
	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0 || enforce)
			testVar=10000
		endif
	endfor
	//here  top limit
	ListOfVariables="Level1PHighLimit;Level2PHighLimit;Level3PHighLimit;Level4PHighLimit;Level5PHighLimit;"
	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0 || enforce)
			testVar=4.2
		endif
	endfor
	
	//here Pack top limit, test 8	
	ListOfVariables="Level1PACKHighLimit;Level2PACKHighLimit;Level3PACKHighLimit;Level4PACKHighLimit;Level5PACKHighLimit;"
	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0 || enforce)
			testVar=8
		endif
	endfor

	//here limit of 0	
	ListOfVariables="Level1PACKLowLimit;Level2PACKLowLimit;Level3PACKLowLimit;Level4PACKLowLimit;Level5PACKLowLimit;Level1RgCO;"

	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar!=0 || enforce)
			testVar=0
		endif
	endfor

	//here limit of 0.3	
	ListOfVariables="Level1PACK;Level2PACK;Level3PACK;Level4PACK;Level5PACK;"

	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0 || enforce)
			testVar=2.5
		endif
	endfor
	//here limit of 0.01	
	ListOfVariables="Level1B;Level2B;Level3B;Level4B;Level5B;"

	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0 || enforce)
			testVar=0.01
		endif
	endfor
	ListOfVariables="Level1P;Level2P;Level3P;Level4P;Level5P;"

	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0 || enforce)
			testVar=4
		endif
	endfor
	
	
	//here another number as will be needed
	ListOfVariables="Level1Rg;Level1G;Level1ETA;"
	ListOfVariables+="Level2Rg;Level2G;Level2ETA;" //Level2RgCO;"
	ListOfVariables+="Level3Rg;Level3G;Level3ETA;"  //Level3RgCO;"
	ListOfVariables+="Level4Rg;Level4G;Level4ETA;" //Level4RgCO;"
	ListOfVariables+="Level5Rg;Level5G;Level5ETA;" //Level5RgCO;"

	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0 || enforce)
			testVar=100
		endif
	endfor
	IR1A_SetErrorsToZero()
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1A_SetErrorsToZero()

	string ListOfVariables="SASBackgroundError;"
	ListOfVariables+="Level1RgError;Level1GError;Level1PError;Level1BError;Level1ETAError;Level1PACKError;Level1RGCOError;"
	ListOfVariables+="Level2RgError;Level2GError;Level2PError;Level2BError;Level2ETAError;Level2PACKError;Level2RGCOError;"
	ListOfVariables+="Level3RgError;Level3GError;Level3PError;Level3BError;Level3ETAError;Level3PACKError;Level3RGCOError;"
	ListOfVariables+="Level4RgError;Level4GError;Level4PError;Level4BError;Level4ETAError;Level4PACKError;Level4RGCOError;"
	ListOfVariables+="Level5RgError;Level5GError;Level5PError;Level5BError;Level5ETAError;Level5PACKError;Level5RGCOError;"
	variable i
	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		testVar=0
	endfor


end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Window IR1A_ControlPanel() 
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(2.25,43.25,390,720) as "Unified fit"

	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup="r*:q*;"
	string EUserLookup="r*:s*;"
	IR2C_AddDataControls("Irena_UnifFit","IR1A_ControlPanel","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 1,1)

	SetDrawLayer UserBack
	SetDrawEnv fname= "Times New Roman", save
	SetDrawEnv fname= "Times New Roman",fsize= 22,fstyle= 3,textrgb= (0,0,52224)
	DrawText 50,23,"Unified modeling input panel"
	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
	DrawLine 16,181,339,181
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 18,49,"Data input"
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 20,209,"Unified model input"
	SetDrawEnv textrgb= (0,0,65280),fstyle= 1, fsize= 12
	DrawText 200,275,"Fit?:"
	SetDrawEnv textrgb= (0,0,65280),fstyle= 1, fsize= 12
	DrawText 230,275,"Low limit:    High Limit:"
	DrawText 10,600,"Fit using least square fitting ?"
	DrawPoly 113,225,1,1,{113,225,113,225}
	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
	DrawLine 330,612,350,612
	SetDrawEnv textrgb= (0,0,65280),fstyle= 1
	DrawText 4,640,"Results:"

	//Experimental data input
	CheckBox UseSMRData,pos={170,40},size={141,14},proc=IR1A_InputPanelCheckboxProc,title="SMR data"
	CheckBox UseSMRData,variable= root:packages:Irena_UnifFit:UseSMRData, help={"Check, if you are using slit smeared data"}
	SetVariable SlitLength,limits={0,Inf,0},value= root:Packages:Irena_UnifFit:SlitLengthUnif, disable=!root:packages:Irena_UnifFit:UseSMRData
	SetVariable SlitLength,pos={260,40},size={100,16},title="SL=",proc=IR1A_PanelSetVarProc, help={"slit length"}
	Button DrawGraphs,pos={56,158},size={100,20},proc=IR1A_InputPanelButtonProc,title="Graph", help={"Create a graph (log-log) of your experiment data"}
	SetVariable SubtractBackground,limits={0,Inf,0.1},value= root:Packages:Irena_UnifFit:SubtractBackground
	SetVariable SubtractBackground,pos={170,162},size={180,16},title="Subtract background",proc=IR1A_PanelSetVarProc, help={"Subtract flat background from data"}

	//Modeling input, common for all distributions
	PopupMenu NumberOfLevels,pos={200,190},size={170,21},proc=IR1A_PanelPopupControl,title="Number of levels :", help={"Select number of levels to use, NOTE that the level 1 has to have the smallest Rg"}
	PopupMenu NumberOfLevels,mode=2,popvalue="0",value= #"\"0;1;2;3;4;5;\""
	Button GraphDistribution,pos={12,215},size={90,20},proc=IR1A_InputPanelButtonProc,title="Graph Unified", help={"Add results of your model in the graph with data"}
	CheckBox UpdateAutomatically,pos={105,210},size={225,14},proc=IR1A_InputPanelCheckboxProc,title="Update Unified automatically?"
	CheckBox UpdateAutomatically,variable= root:Packages:Irena_UnifFit:UpdateAutomatically, help={"When checked the graph updates automatically anytime you make change in model parameters"}
	CheckBox DisplayLocalFits,pos={105,225},size={225,14},proc=IR1A_InputPanelCheckboxProc,title="Display local (Porod & Guinier) fits?"
	CheckBox DisplayLocalFits,variable= root:Packages:Irena_UnifFit:DisplayLocalFits, help={"Check to display in graph local Porod and Guinier fits for selected level, fits change with changes in values of P, B, Rg and G"}

	CheckBox ExportLocalFits,pos={130,604},size={225,14},proc=IR1A_InputPanelCheckboxProc,title="Store local (Porod & Guinier) fits?"
	CheckBox ExportLocalFits,variable= root:Packages:Irena_UnifFit:ExportLocalFits, help={"Check to store local Porod and Guinier fits for all existing levels together with full Unified fit"}
	Button DoFitting,pos={175,584},size={70,20},proc=IR1A_InputPanelButtonProc,title="Fit", help={"Do least sqaures fitting of the whole model, find good starting conditions and proper limits before fitting"}
	Button RevertFitting,pos={255,584},size={100,20},proc=IR1A_InputPanelButtonProc,title="Revert back",help={"Return back befoire last fitting attempt"}
	Button ResetUnified,pos={3,605},size={80,15},proc=IR1A_InputPanelButtonProc,title="reset unif?", help={"Reset variables to default values?"}
	Button CopyToFolder,pos={55,623},size={120,20},proc=IR1A_InputPanelButtonProc,title="Store in Data Folder", help={"Copy results of the modeling into original data folder"}
	Button ExportData,pos={180,623},size={90,20},proc=IR1A_InputPanelButtonProc,title="Export ASCII", help={"Export ASCII data out of Igor"}
	Button MarkGraphs,pos={277,623},size={110,20},proc=IR1A_InputPanelButtonProc,title="Results to graphs", help={"Insert text boxes with results into the graphs for printing"}
	Button EvaluateSpecialCases,pos={10,645},size={120,20},proc=IR1A_InputPanelButtonProc,title="Analyze Results", help={"Analyze special Cases"}


	SetVariable SASBackground,pos={10,565},size={190,16},proc=IR1A_PanelSetVarProc,title="SAS Background", help={"SAS background"}
	SetVariable SASBackground,limits={-inf,Inf,root:Packages:Irena_UnifFit:SASBackgroundStep},value= root:Packages:Irena_UnifFit:SASBackground
	SetVariable SASBackgroundStep,pos={205,565},size={70,16},title="step",proc=IR1A_PanelSetVarProc, help={"Step for increments in SAS background"}
	SetVariable SASBackgroundStep,limits={0,Inf,0},value= root:Packages:Irena_UnifFit:SASBackgroundStep
	CheckBox FitBackground,pos={285,566},size={63,14},proc=IR1A_InputPanelCheckboxProc,title="Fit Bckg?"
	CheckBox FitBackground,variable= root:Packages:Irena_UnifFit:FitSASBackground, help={"Check if you want the background to be fitting parameter"}

	//Dist Tabs definition
	TabControl DistTabs,pos={10,240},size={370,320},proc=IR1A_TabPanelControl
	TabControl DistTabs,fSize=10,tabLabel(0)="1. Level ",tabLabel(1)="2. Level "
	TabControl DistTabs,tabLabel(2)="3. Level ",tabLabel(3)="4. Level "
	TabControl DistTabs,tabLabel(4)="5. Level ",value= 0
	
	TitleBox Level1_Title, title="   Level  1 controls    ", frame=1, labelBack=(64000,0,0), pos={14,258}, size={150,8}

	SetVariable Level1_G,pos={14,280},size={180,16},proc=IR1A_PanelSetVarProc,title="G   "
	SetVariable Level1_G,limits={0,inf,root:Packages:Irena_UnifFit:Level1GStep},value= root:Packages:Irena_UnifFit:Level1G, help={"Gunier prefactor"}
	CheckBox Level1_FitG,pos={200,281},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level1_FitG,variable= root:Packages:Irena_UnifFit:Level1FitG, help={"Fit G?, find god starting conditions and select fitting limits..."}
	SetVariable Level1_GLowLimit,pos={230,280},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level1_GLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level1GLowLimit, help={"Low limit for G fitting"}
	SetVariable Level1_GHighLimit,pos={300,280},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level1_GHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level1GHighLimit, help={"High limit for G fitting"}

	SetVariable Level1_Rg,pos={14,300},size={180,16},proc=IR1A_PanelSetVarProc,title="Rg   ", help={"Radius of gyration, e.g., sqrt(5/3)*R for sphere etc..."}
	SetVariable Level1_Rg,limits={0,inf,root:Packages:Irena_UnifFit:Level1RgStep},variable= root:Packages:Irena_UnifFit:Level1Rg
	CheckBox Level1_FitRg,pos={200,301},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level1_FitRg,variable= root:Packages:Irena_UnifFit:Level1FitRg, help={"Fit Rg? Select properly starting conditions and limits"}
	SetVariable Level1_RgLowLimit,pos={230,300},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level1_RgLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level1RgLowLimit, help={"Low limit for Rg fitting..."}
	SetVariable Level1_RgHighLimit,pos={300,300},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level1_RgHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level1RgHighLimit, help={"High limit for Rg fitting"}

	SetVariable Level1_RgStep,pos={16,320},size={90,16},proc=IR1A_PanelSetVarProc, title="Rg step", help={"Increment with which the Rg setting changes, when you click the up/down arrows in the Rg box"}
	SetVariable Level1_RgStep,limits={0,inf,(0.1*root:Packages:Irena_UnifFit:Level1RgStep)},value= root:Packages:Irena_UnifFit:Level1RgStep
	SetVariable Level1_GStep,pos={120,320},size={90,16},proc=IR1A_PanelSetVarProc, title="G step", help={"Increment with which the G setting changes, when you click the up/down arrows in the G box"}
	SetVariable Level1_GStep,limits={0,inf,(0.1*root:Packages:Irena_UnifFit:Level1GStep)},value= root:Packages:Irena_UnifFit:Level1GStep

	Button Level1_FitRgAndG,pos={220,318},size={130,20},font="Times New Roman",fSize=10,proc=IR1A_InputPanelButtonProc,title="Fit Rg/G bwtn cursors", help={"Do locol fit of Gunier dependence between the cursors amd put resulting values into the Rg and G fields"}

	CheckBox Level1_MassFractal,pos={20,350},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Is this mass fractal from lower level?"
	CheckBox Level1_MassFractal,variable= root:Packages:Irena_UnifFit:Level1MassFractal, help={"Is this mass fractal composed of particles from lower level?"}
	SetVariable Level1_SurfToVolRat,pos={230,350},size={130,16},proc=IR1A_PanelSetVarProc,title="Surf / Vol", help={"Surface to volume ratio if P=4 (Porod law) in m2/cm3 if input Q in is A"}
	SetVariable Level1_SurfToVolRat,limits={inf,inf,0},value= root:Packages:Irena_UnifFit:Level1SurfaceToVolRat

	SetVariable Level1_B,pos={14,370},size={180,16},proc=IR1A_PanelSetVarProc,title="B   ", help={"Power law prefactor"}
	SetVariable Level1_B,limits={0,inf,root:Packages:Irena_UnifFit:Level1BStep},value= root:Packages:Irena_UnifFit:Level1B
	CheckBox Level1_FitB,pos={200,371},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level1_FitB,variable= root:Packages:Irena_UnifFit:Level1FitB, help={"Fit the Power law prefactor?, select properly the starting conditions and limits before fitting"}
	SetVariable Level1_BLowLimit,pos={230,370},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level1_BLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level1BLowLimit, help={"Power law prefactor low limit"}
	SetVariable Level1_BHighLimit,pos={300,370},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level1_BHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level1BHighLimit, help={"Power law prefactor high limit"}

	SetVariable Level1_P,pos={14,390},size={180,16},proc=IR1A_PanelSetVarProc,title="P   ", help={"Power law slope, e.g., -4 for Porod tails"}
	SetVariable Level1_P,limits={0,6,root:Packages:Irena_UnifFit:Level1PStep},value= root:Packages:Irena_UnifFit:Level1P
	CheckBox Level1_FitP,pos={200,391},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level1_FitP,variable= root:Packages:Irena_UnifFit:Level1FitP, help={"Fit the Power law slope, select good starting conditions and appropriate limits"}
	SetVariable Level1_PLowLimit,pos={230,390},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level1_PLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level1PLowLimit, help={"Power law low limit for slope"}
	SetVariable Level1_PHighLimit,pos={300,390},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level1_PHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level1PHighLimit, help={"Power law high limit for slope"}

	SetVariable Level1_DegreeOfAggreg,pos={14,370},size={140,16},proc=IR1A_PanelSetVarProc,title="Deg. of Aggreg ", help={"Degree of aggregation for mass fractals. = Rg/Rg(level-1) "}
	SetVariable Level1_DegreeOfAggreg,limits={-inf,inf,0},value= root:Packages:Irena_UnifFit:Level1DegreeOfAggreg

	SetVariable Level1_PStep,pos={16,410},size={90,16},proc=IR1A_PanelSetVarProc, title="P step", help={"Increment with which the P setting changes, when you click the up/down arrows in the P box"}
	SetVariable Level1_PStep,limits={0,inf,(0.1*root:Packages:Irena_UnifFit:Level1PStep)},value= root:Packages:Irena_UnifFit:Level1PStep
	SetVariable Level1_BStep,pos={120,410},size={90,16},proc=IR1A_PanelSetVarProc, title="B step", help={"Increment with which the B setting changes, when you click the up/down arrows in the B box"}
	SetVariable Level1_BStep,limits={0,inf,(0.1*root:Packages:Irena_UnifFit:Level1BStep)},value= root:Packages:Irena_UnifFit:Level1BStep

	Button Level1_FitPAndB,pos={220,408},size={130,20},font="Times New Roman",fSize=10,proc=IR1A_InputPanelButtonProc,title="Fit P/B bwtn cursors", help={"Do Power law fitting between the cursors and put resulting parameters in the P and B fields"}


	SetVariable Level1_RGCO,pos={14,430},size={180,16},proc=IR1A_PanelSetVarProc,title="RgCutoff  "
	SetVariable Level1_RGCO,limits={0,inf,1},value= root:Packages:Irena_UnifFit:Level1RgCO, help={"Size, where the power law dependence ends, 0 or sometimes Rg of lower level, for level 1 it is 0"}
	CheckBox Level1_FitRGCO,pos={200,431},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level1_FitRGCO,variable= root:Packages:Irena_UnifFit:Level1FitRgCo, help={"Fit the RgCutoff ? Select properly starting point and limits."}
	SetVariable Level1_RGCOLowLimit,pos={230,430},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level1_RGCOLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level1RgCoLowLimit, help={"RgCutOff low limit"}
	SetVariable Level1_RGCOHighLimit,pos={300,430},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level1_RGCOHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level1RgCOHighLimit, help={"RgCutOff high limit"}

	Button Level1_SetRGCODefault,pos={20,450},size={100,20},font="Times New Roman",fSize=10,proc=IR1A_InputPanelButtonProc,title="Rg(level-1)->RGCO", help={"This button sets the RgCutOff to value of Rg from previous level (or 0 for level 1)"}
	CheckBox Level1_LinkRGCO,pos={160,455},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Link RGCO"
	CheckBox Level1_LinkRGCO,variable= root:Packages:Irena_UnifFit:Level1LinkRgCo, help={"Link the RgCO to lower level and fit at the same time?"}

	PopupMenu Level1_KFactor,pos={230,450},size={170,21},proc=IR1A_PanelPopupControl,title="k factor :"
	PopupMenu Level1_KFactor,mode=2,popvalue="1",value= #"\"1;1.06;\"", help={"This value is usually 1, for weak decays and mass fractals 1.06"}

	CheckBox Level1_Corelations,pos={90,480},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Is this correlated system? "
	CheckBox Level1_Corelations,variable= root:Packages:Irena_UnifFit:Level1Corelations, help={"Is there a peak or do you expect Corelations between particles to have importance"}

	SetVariable Level1_ETA,pos={14,500},size={180,16},proc=IR1A_PanelSetVarProc,title="ETA    "
	SetVariable Level1_ETA,limits={0,inf,root:Packages:Irena_UnifFit:Level1EtaStep},value= root:Packages:Irena_UnifFit:Level1ETA, help={"Corelations distance for correlated systems using Born-Green approximation by Gunier for multiple order Corelations"}
	CheckBox Level1_FitETA,pos={200,500},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level1_FitETA,variable= root:Packages:Irena_UnifFit:Level1FitETA, help={"Fit correaltion distance? Slect properly the starting conditions and limits."}
	SetVariable Level1_ETALowLimit,pos={230,500},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level1_ETALowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level1ETALowLimit, help={"Correlation distance low limit"}
	SetVariable Level1_ETAHighLimit,pos={300,500},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level1_ETAHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level1ETAHighLimit, help={"Correlation distance high limit"}

	SetVariable Level1_PACK,pos={14,520},size={180,16},proc=IR1A_PanelSetVarProc,title="Pack    "
	SetVariable Level1_PACK,limits={0,8,root:Packages:Irena_UnifFit:Level1PackStep},value= root:Packages:Irena_UnifFit:Level1PACK, help={"Packing factor for domains. For dilute objects 0, for FCC packed spheres 8*0.592"}
	CheckBox Level1_FitPACK,pos={200,520},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level1_FitPACK,variable= root:Packages:Irena_UnifFit:Level1FitPACK, help={"Fit packing factor? Select properly starting condions and limits"}
	SetVariable Level1_PACKLowLimit,pos={230,520},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level1_PACKLowLimit,limits={0,8,0},value= root:Packages:Irena_UnifFit:Level1PACKLowLimit, help={"Low limit for packing factor"}
	SetVariable Level1_PACKHighLimit,pos={300,520},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level1_PACKHighLimit,limits={0,8,0},value= root:Packages:Irena_UnifFit:Level1PACKHighLimit, help={"High limit for packing factor"}

	SetVariable Level1_EtaStep,pos={16,540},size={150,16},proc=IR1A_PanelSetVarProc, title="Eta step", help={"Increment with which the ETA setting changes, when you click the up/down arrows in the ETA box"}
	SetVariable Level1_EtaStep,limits={0.001,inf,(0.1*root:Packages:Irena_UnifFit:Level1EtaStep)},value= root:Packages:Irena_UnifFit:Level1EtaStep
	SetVariable Level1_PackStep,pos={200,540},size={150,16},proc=IR1A_PanelSetVarProc, title="Pack step", help={"Increment with which the Pack setting changes, when you click the up/down arrows in the Pack box"}
	SetVariable Level1_PackStep,limits={0.001,inf,(0.1*root:Packages:Irena_UnifFit:Level1PackStep)},value= root:Packages:Irena_UnifFit:Level1PackStep


	//end of Level 1 controls....
//
//
	//Level2 controls

	TitleBox Level2_Title, title="   Level  2 controls    ", frame=1, labelBack=(0,64000,0), pos={14,258}, size={150,8}

	SetVariable Level2_G,pos={14,280},size={180,16},proc=IR1A_PanelSetVarProc,title="G   "
	SetVariable Level2_G,limits={0,inf,root:Packages:Irena_UnifFit:Level2GStep},value= root:Packages:Irena_UnifFit:Level2G, help={"Gunier prefactor"}
	CheckBox Level2_FitG,pos={200,281},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level2_FitG,variable= root:Packages:Irena_UnifFit:Level2FitG, help={"Fit G?, find god starting conditions and select fitting limits..."}
	SetVariable Level2_GLowLimit,pos={230,280},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level2_GLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level2GLowLimit, help={"Low limit for G fitting"}
	SetVariable Level2_GHighLimit,pos={300,280},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level2_GHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level2GHighLimit, help={"High limit for G fitting"}

	SetVariable Level2_Rg,pos={14,300},size={180,16},proc=IR1A_PanelSetVarProc,title="Rg  ", help={"Radius of gyration, e.g., sqrt(5/3)*R for sphere etc..."}
	SetVariable Level2_Rg,limits={0,inf,root:Packages:Irena_UnifFit:Level2RgStep},value= root:Packages:Irena_UnifFit:Level2Rg
	CheckBox Level2_FitRg,pos={200,301},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level2_FitRg,variable= root:Packages:Irena_UnifFit:Level2FitRg, help={"Fit Rg? Select properly starting conditions and limits"}
	SetVariable Level2_RgLowLimit,pos={230,300},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level2_RgLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level2RgLowLimit, help={"Low limit for Rg fitting..."}
	SetVariable Level2_RgHighLimit,pos={300,300},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level2_RgHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level2RgHighLimit, help={"High limit for Rg fitting"}

	SetVariable Level2_RgStep,pos={16,320},size={90,16},proc=IR1A_PanelSetVarProc, title="Rg step", help={"Increment with which the Rg setting changes, when you click the up/down arrows in the Rg box"}
	SetVariable Level2_RgStep,limits={0,inf,(0.1*root:Packages:Irena_UnifFit:Level2RgStep)},value= root:Packages:Irena_UnifFit:Level2RgStep
	SetVariable Level2_GStep,pos={120,320},size={90,16},proc=IR1A_PanelSetVarProc, title="G step", help={"Increment with which the G setting changes, when you click the up/down arrows in the G box"}
	SetVariable Level2_GStep,limits={0,inf,(0.1*root:Packages:Irena_UnifFit:Level2GStep)},value= root:Packages:Irena_UnifFit:Level2GStep

	Button Level2_FitRgAndG,pos={220,318},size={130,20},font="Times New Roman",fSize=10,proc=IR1A_InputPanelButtonProc,title="Fit Rg/G bwtn cursors", help={"Do locol fit of Gunier dependence between the cursors amd put resulting values into the Rg and G fields"}

	CheckBox Level2_MassFractal,pos={20,350},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Is this mass fractal from lower level?"
	CheckBox Level2_MassFractal,variable= root:Packages:Irena_UnifFit:Level2MassFractal, help={"Is this mass fractal composed of particles from lower level?"}
	SetVariable Level2_SurfToVolRat,pos={230,350},size={130,16},proc=IR1A_PanelSetVarProc,title="Surf / Vol", help={"Surface to volume ratio if P=4 (Porod law) in m2/cm3 if input Q in is A"}
	SetVariable Level2_SurfToVolRat,limits={inf,inf,0},value= root:Packages:Irena_UnifFit:Level2SurfaceToVolRat

	SetVariable Level2_B,pos={14,370},size={180,16},proc=IR1A_PanelSetVarProc,title="B   ", help={"Power law prefactor"}
	SetVariable Level2_B,limits={0,inf,root:Packages:Irena_UnifFit:Level2BStep},value= root:Packages:Irena_UnifFit:Level2B
	CheckBox Level2_FitB,pos={200,371},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level2_FitB,variable= root:Packages:Irena_UnifFit:Level2FitB, help={"Fit the Power law prefactor?, select properly the starting conditions and limits before fitting"}
	SetVariable Level2_BLowLimit,pos={230,370},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level2_BLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level2BLowLimit, help={"Power law prefactor low limit"}
	SetVariable Level2_BHighLimit,pos={300,370},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level2_BHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level2BHighLimit, help={"Power law prefactor high limit"}

	SetVariable Level2_DegreeOfAggreg,pos={14,370},size={140,16},proc=IR1A_PanelSetVarProc,title="Deg. of Aggreg ", help={"Degree of aggregation for mass fractals. = Rg/Rg(level-1) "}
	SetVariable Level2_DegreeOfAggreg,limits={-inf,inf,0},value= root:Packages:Irena_UnifFit:Level2DegreeOfAggreg

	SetVariable Level2_P,pos={14,390},size={180,16},proc=IR1A_PanelSetVarProc,title="P   ", help={"Power law slope, e.g., -4 for Porod tails"}
	SetVariable Level2_P,limits={0,6,root:Packages:Irena_UnifFit:Level2PStep},value= root:Packages:Irena_UnifFit:Level2P
	CheckBox Level2_FitP,pos={200,390},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level2_FitP,variable= root:Packages:Irena_UnifFit:Level2FitP, help={"Fit the Power law slope, select good starting conditions and appropriate limits"}
	SetVariable Level2_PLowLimit,pos={230,390},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level2_PLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level2PLowLimit, help={"Power law low limit for slope"}
	SetVariable Level2_PHighLimit,pos={300,390},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level2_PHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level2PHighLimit, help={"Power law high limit for slope"}


	SetVariable Level2_PStep,pos={16,410},size={90,16},proc=IR1A_PanelSetVarProc, title="P step", help={"Increment with which the P setting changes, when you click the up/down arrows in the P box"}
	SetVariable Level2_PStep,limits={0,inf,(0.1*root:Packages:Irena_UnifFit:Level2PStep)},value= root:Packages:Irena_UnifFit:Level2PStep
	SetVariable Level2_BStep,pos={120,410},size={90,16},proc=IR1A_PanelSetVarProc, title="B step", help={"Increment with which the B setting changes, when you click the up/down arrows in the B box"}
	SetVariable Level2_BStep,limits={0,inf,(0.1*root:Packages:Irena_UnifFit:Level2BStep)},value= root:Packages:Irena_UnifFit:Level2BStep

	Button Level2_FitPAndB,pos={220,408},size={130,20},font="Times New Roman",fSize=10,proc=IR1A_InputPanelButtonProc,title="Fit P/B bwtn cursors", help={"Do Power law fitting between the cursors and put resulting parameters in the P and B fields"}


	SetVariable Level2_RGCO,pos={14,430},size={180,16},proc=IR1A_PanelSetVarProc,title="RgCutoff  "
	SetVariable Level2_RGCO,limits={0,inf,1},value= root:Packages:Irena_UnifFit:Level2RgCO, help={"Size, where the power law dependence ends, usually Rg of lower level, for level 1 it is 0"}
	CheckBox Level2_FitRGCO,pos={200,431},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level2_FitRGCO,variable= root:Packages:Irena_UnifFit:Level2FitRgCo, help={"Fit the RgCutoff ? Select properly starting point and limits."}
	SetVariable Level2_RGCOLowLimit,pos={230,430},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level2_RGCOLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level2RgCoLowLimit, help={"RgCutOff low limit"}
	SetVariable Level2_RGCOHighLimit,pos={300,430},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level2_RGCOHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level2RgCOHighLimit, help={"RgCutOff high limit"}

	Button Level2_SetRGCODefault,pos={20,450},size={100,20},font="Times New Roman",fSize=10,proc=IR1A_InputPanelButtonProc,title="Rg(level-1)->RGCO", help={"This button sets the RgCutOff to value of Rg from previous level (or 0 for level 1)"}
	CheckBox Level2_LinkRGCO,pos={160,455},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Link RGCO"
	CheckBox Level2_LinkRGCO,variable= root:Packages:Irena_UnifFit:Level2LinkRgCo, help={"Link the RgCO to lower level and fit at the same time?"}

	PopupMenu Level2_KFactor,pos={230,450},size={170,21},proc=IR1A_PanelPopupControl,title="k factor :"
	PopupMenu Level2_KFactor,mode=2,popvalue="1",value= #"\"1;1.06;\"", help={"This value is usually 1, for weak decays and mass fractals 1.06"}

	CheckBox Level2_Corelations,pos={90,480},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Is this correlated system? "
	CheckBox Level2_Corelations,variable= root:Packages:Irena_UnifFit:Level2Corelations, help={"Is there a peak or do you expect Corelations between particles to have importance"}

	SetVariable Level2_ETA,pos={14,500},size={180,16},proc=IR1A_PanelSetVarProc,title="ETA    "
	SetVariable Level2_ETA,limits={0,inf,root:Packages:Irena_UnifFit:Level2EtaStep},value= root:Packages:Irena_UnifFit:Level2ETA, help={"Corelations distance for correlated systems using Born-Green approximation by Gunier for multiple order Corelations"}
	CheckBox Level2_FitETA,pos={200,500},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level2_FitETA,variable= root:Packages:Irena_UnifFit:Level2FitETA, help={"Fit correaltion distance? Slect properly the starting conditions and limits."}
	SetVariable Level2_ETALowLimit,pos={230,500},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level2_ETALowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level2ETALowLimit, help={"Correlation distance low limit"}
	SetVariable Level2_ETAHighLimit,pos={300,500},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level2_ETAHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level2ETAHighLimit, help={"Correlation distance high limit"}

	SetVariable Level2_PACK,pos={14,520},size={180,16},proc=IR1A_PanelSetVarProc,title="Pack    "
	SetVariable Level2_PACK,limits={0,8,root:Packages:Irena_UnifFit:Level2PackStep},value= root:Packages:Irena_UnifFit:Level2PACK, help={"Packing factor for domains. For dilute objects 0, for FCC packed spheres 8*0.592"}
	CheckBox Level2_FitPACK,pos={200,520},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level2_FitPACK,variable= root:Packages:Irena_UnifFit:Level2FitPACK, help={"Fit packing factor? Select properly starting condions and limits"}
	SetVariable Level2_PACKLowLimit,pos={230,520},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level2_PACKLowLimit,limits={0,8,0},value= root:Packages:Irena_UnifFit:Level2PACKLowLimit, help={"Low limit for packing factor"}
	SetVariable Level2_PACKHighLimit,pos={300,520},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level2_PACKHighLimit,limits={0,8,0},value= root:Packages:Irena_UnifFit:Level2PACKHighLimit, help={"High limit for packing factor"}

	SetVariable Level2_EtaStep,pos={16,540},size={150,16},proc=IR1A_PanelSetVarProc, title="Eta step", help={"Increment with which the ETA setting changes, when you click the up/down arrows in the ETA box"}
	SetVariable Level2_EtaStep,limits={0.001,inf,(0.1*root:Packages:Irena_UnifFit:Level2EtaStep)},value= root:Packages:Irena_UnifFit:Level2EtaStep
	SetVariable Level2_PackStep,pos={200,540},size={150,16},proc=IR1A_PanelSetVarProc, title="Pack step", help={"Increment with which the Pack setting changes, when you click the up/down arrows in the Pack box"}
	SetVariable Level2_PackStep,limits={0.001,inf,(0.1*root:Packages:Irena_UnifFit:Level2PackStep)},value= root:Packages:Irena_UnifFit:Level2PackStep
////End of Level2 	
////	
	//Level3 controls
	TitleBox Level3_Title, title="   Level  3 controls    ", frame=1, labelBack=(30000,30000,64000), pos={14,258}, size={150,8}

	SetVariable Level3_G,pos={14,280},size={180,16},proc=IR1A_PanelSetVarProc,title="G   "
	SetVariable Level3_G,limits={0,inf,root:Packages:Irena_UnifFit:Level3GStep},value= root:Packages:Irena_UnifFit:Level3G, help={"Gunier prefactor"}
	CheckBox Level3_FitG,pos={200,281},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level3_FitG,variable= root:Packages:Irena_UnifFit:Level3FitG, help={"Fit G?, find god starting conditions and select fitting limits..."}
	SetVariable Level3_GLowLimit,pos={230,280},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level3_GLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level3GLowLimit, help={"Low limit for G fitting"}
	SetVariable Level3_GHighLimit,pos={300,280},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level3_GHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level3GHighLimit, help={"High limit for G fitting"}

	SetVariable Level3_Rg,pos={14,300},size={180,16},proc=IR1A_PanelSetVarProc,title="Rg   ", help={"Radius of gyration, e.g., sqrt(5/3)*R for sphere etc..."}
	SetVariable Level3_Rg,limits={0,inf,root:Packages:Irena_UnifFit:Level3RgStep},value= root:Packages:Irena_UnifFit:Level3Rg
	CheckBox Level3_FitRg,pos={200,301},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level3_FitRg,variable= root:Packages:Irena_UnifFit:Level3FitRg, help={"Fit Rg? Select properly starting conditions and limits"}
	SetVariable Level3_RgLowLimit,pos={230,300},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level3_RgLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level3RgLowLimit, help={"Low limit for Rg fitting..."}
	SetVariable Level3_RgHighLimit,pos={300,300},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level3_RgHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level3RgHighLimit, help={"High limit for Rg fitting"}

	SetVariable Level3_RgStep,pos={16,320},size={90,16},proc=IR1A_PanelSetVarProc, title="Rg step", help={"Increment with which the Rg setting changes, when you click the up/down arrows in the Rg box"}
	SetVariable Level3_RgStep,limits={0,inf,(0.1*root:Packages:Irena_UnifFit:Level3RgStep)},value= root:Packages:Irena_UnifFit:Level3RgStep
	SetVariable Level3_GStep,pos={120,320},size={90,16},proc=IR1A_PanelSetVarProc, title="G step", help={"Increment with which the G setting changes, when you click the up/down arrows in the G box"}
	SetVariable Level3_GStep,limits={0,inf,(0.1*root:Packages:Irena_UnifFit:Level3GStep)},value= root:Packages:Irena_UnifFit:Level3GStep

	Button Level3_FitRgAndG,pos={220,318},size={130,20},font="Times New Roman",fSize=10,proc=IR1A_InputPanelButtonProc,title="Fit Rg/G bwtn cursors", help={"Do locol fit of Gunier dependence between the cursors amd put resulting values into the Rg and G fields"}

	CheckBox Level3_MassFractal,pos={20,350},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Is this mass fractal from lower level?"
	CheckBox Level3_MassFractal,variable= root:Packages:Irena_UnifFit:Level3MassFractal, help={"Is this mass fractal composed of particles from lower level?"}
	SetVariable Level3_SurfToVolRat,pos={230,350},size={130,16},proc=IR1A_PanelSetVarProc,title="Surf / Vol", help={"Surface to volume ratio if P=4 (Porod law) in m2/cm3 if input Q in is A"}
	SetVariable Level3_SurfToVolRat,limits={inf,inf,0},value= root:Packages:Irena_UnifFit:Level3SurfaceToVolRat

	SetVariable Level3_B,pos={14,370},size={180,16},proc=IR1A_PanelSetVarProc,title="B   ", help={"Power law prefactor"}
	SetVariable Level3_B,limits={0,inf,root:Packages:Irena_UnifFit:Level3BStep},value= root:Packages:Irena_UnifFit:Level3B
	CheckBox Level3_FitB,pos={200,371},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level3_FitB,variable= root:Packages:Irena_UnifFit:Level3FitB, help={"Fit the Power law prefactor?, select properly the starting conditions and limits before fitting"}
	SetVariable Level3_BLowLimit,pos={230,370},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level3_BLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level3BLowLimit, help={"Power law prefactor low limit"}
	SetVariable Level3_BHighLimit,pos={300,370},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level3_BHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level3BHighLimit, help={"Power law prefactor high limit"}

	SetVariable Level3_DegreeOfAggreg,pos={14,370},size={140,16},proc=IR1A_PanelSetVarProc,title="Deg. of Aggreg ", help={"Degree of aggregation for mass fractals. = Rg/Rg(level-1) "}
	SetVariable Level3_DegreeOfAggreg,limits={-inf,inf,0},value= root:Packages:Irena_UnifFit:Level3DegreeOfAggreg

	SetVariable Level3_P,pos={14,390},size={180,16},proc=IR1A_PanelSetVarProc,title="P   ", help={"Power law slope, e.g., -4 for Porod tails"}
	SetVariable Level3_P,limits={0,6,root:Packages:Irena_UnifFit:Level3PStep},value= root:Packages:Irena_UnifFit:Level3P
	CheckBox Level3_FitP,pos={200,391},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level3_FitP,variable= root:Packages:Irena_UnifFit:Level3FitP, help={"Fit the Power law slope, select good starting conditions and appropriate limits"}
	SetVariable Level3_PLowLimit,pos={230,390},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level3_PLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level3PLowLimit, help={"Power law low limit for slope"}
	SetVariable Level3_PHighLimit,pos={300,390},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level3_PHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level3PHighLimit, help={"Power law high limit for slope"}

	SetVariable Level3_PStep,pos={16,410},size={90,16},proc=IR1A_PanelSetVarProc, title="P step", help={"Increment with which the P setting changes, when you click the up/down arrows in the P box"}
	SetVariable Level3_PStep,limits={0,inf,(0.1*root:Packages:Irena_UnifFit:Level3PStep)},value= root:Packages:Irena_UnifFit:Level3PStep
	SetVariable Level3_BStep,pos={120,410},size={90,16},proc=IR1A_PanelSetVarProc, title="B step", help={"Increment with which the B setting changes, when you click the up/down arrows in the B box"}
	SetVariable Level3_BStep,limits={0,inf,(0.1*root:Packages:Irena_UnifFit:Level3BStep)},value= root:Packages:Irena_UnifFit:Level3BStep

	Button Level3_FitPAndB,pos={220,408},size={130,20},font="Times New Roman",fSize=10,proc=IR1A_InputPanelButtonProc,title="Fit P/B bwtn cursors", help={"Do Power law fitting between the cursors and put resulting parameters in the P and B fields"}


	SetVariable Level3_RGCO,pos={14,430},size={180,16},proc=IR1A_PanelSetVarProc,title="RgCutoff  "
	SetVariable Level3_RGCO,limits={0,inf,1},value= root:Packages:Irena_UnifFit:Level3RgCO, help={"Size, where the power law dependence ends, usually Rg of lower level, for level 1 it is 0"}
	CheckBox Level3_FitRGCO,pos={200,431},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level3_FitRGCO,variable= root:Packages:Irena_UnifFit:Level3FitRgCo, help={"Fit the RgCutoff ? Select properly starting point and limits."}
	SetVariable Level3_RGCOLowLimit,pos={230,430},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level3_RGCOLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level3RgCoLowLimit, help={"RgCutOff low limit"}
	SetVariable Level3_RGCOHighLimit,pos={300,430},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level3_RGCOHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level3RgCOHighLimit, help={"RgCutOff high limit"}

	Button Level3_SetRGCODefault,pos={20,450},size={100,20},font="Times New Roman",fSize=10,proc=IR1A_InputPanelButtonProc,title="Rg(level-1)->RGCO", help={"This button sets the RgCutOff to value of Rg from previous level (or 0 for level 1)"}
	CheckBox Level3_LinkRGCO,pos={160,455},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Link RGCO"
	CheckBox Level3_LinkRGCO,variable= root:Packages:Irena_UnifFit:Level3LinkRgCo, help={"Link the RgCO to lower level and fit at the same time?"}

	PopupMenu Level3_KFactor,pos={230,450},size={170,21},proc=IR1A_PanelPopupControl,title="k factor :"
	PopupMenu Level3_KFactor,mode=2,popvalue="1",value= #"\"1;1.06;\"", help={"This value is usually 1, for weak decays and mass fractals 1.06"}

	CheckBox Level3_Corelations,pos={90,480},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Is this correlated system? "
	CheckBox Level3_Corelations,variable= root:Packages:Irena_UnifFit:Level3Corelations, help={"Is there a peak or do you expect Corelations between particles to have importance"}

	SetVariable Level3_ETA,pos={14,500},size={180,16},proc=IR1A_PanelSetVarProc,title="ETA    "
	SetVariable Level3_ETA,limits={0,inf,root:Packages:Irena_UnifFit:Level3EtaStep},value= root:Packages:Irena_UnifFit:Level3ETA, help={"Corelations distance for correlated systems using Born-Green approximation by Gunier for multiple order Corelations"}
	CheckBox Level3_FitETA,pos={200,500},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level3_FitETA,variable= root:Packages:Irena_UnifFit:Level3FitETA, help={"Fit correaltion distance? Slect properly the starting conditions and limits."}
	SetVariable Level3_ETALowLimit,pos={230,500},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level3_ETALowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level3ETALowLimit, help={"Correlation distance low limit"}
	SetVariable Level3_ETAHighLimit,pos={300,500},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level3_ETAHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level3ETAHighLimit, help={"Correlation distance high limit"}

	SetVariable Level3_PACK,pos={14,520},size={180,16},proc=IR1A_PanelSetVarProc,title="Pack    "
	SetVariable Level3_PACK,limits={0,8,root:Packages:Irena_UnifFit:Level3PackStep},value= root:Packages:Irena_UnifFit:Level3PACK, help={"Packing factor for domains. For dilute objects 0, for FCC packed spheres 8*0.592"}
	CheckBox Level3_FitPACK,pos={200,520},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level3_FitPACK,variable= root:Packages:Irena_UnifFit:Level3FitPACK, help={"Fit packing factor? Select properly starting condions and limits"}
	SetVariable Level3_PACKLowLimit,pos={230,520},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level3_PACKLowLimit,limits={0,8,0},value= root:Packages:Irena_UnifFit:Level3PACKLowLimit, help={"Low limit for packing factor"}
	SetVariable Level3_PACKHighLimit,pos={300,520},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level3_PACKHighLimit,limits={0,8,0},value= root:Packages:Irena_UnifFit:Level3PACKHighLimit, help={"High limit for packing factor"}

	SetVariable Level3_EtaStep,pos={16,540},size={150,16},proc=IR1A_PanelSetVarProc, title="Eta step", help={"Increment with which the ETA setting changes, when you click the up/down arrows in the ETA box"}
	SetVariable Level3_EtaStep,limits={0.001,inf,(0.1*root:Packages:Irena_UnifFit:Level3EtaStep)},value= root:Packages:Irena_UnifFit:Level3EtaStep
	SetVariable Level3_PackStep,pos={200,540},size={150,16},proc=IR1A_PanelSetVarProc, title="Pack step", help={"Increment with which the Pack setting changes, when you click the up/down arrows in the Pack box"}
	SetVariable Level3_PackStep,limits={0.001,inf,(0.1*root:Packages:Irena_UnifFit:Level3PackStep)},value= root:Packages:Irena_UnifFit:Level3PackStep
////Level 3
////
	//Level4 controls
	TitleBox Level4_Title, title="   Level  4 controls    ", frame=1, labelBack=(52000,52000,0), pos={14,258}, size={150,8}

	SetVariable Level4_G,pos={14,280},size={180,16},proc=IR1A_PanelSetVarProc,title="G   "
	SetVariable Level4_G,limits={0,inf,root:Packages:Irena_UnifFit:Level4GStep},value= root:Packages:Irena_UnifFit:Level4G, help={"Gunier prefactor"}
	CheckBox Level4_FitG,pos={200,281},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level4_FitG,variable= root:Packages:Irena_UnifFit:Level4FitG, help={"Fit G?, find god starting conditions and select fitting limits..."}
	SetVariable Level4_GLowLimit,pos={230,280},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level4_GLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level4GLowLimit, help={"Low limit for G fitting"}
	SetVariable Level4_GHighLimit,pos={300,280},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level4_GHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level4GHighLimit, help={"High limit for G fitting"}

	SetVariable Level4_Rg,pos={14,300},size={180,16},proc=IR1A_PanelSetVarProc,title="Rg   ", help={"Radius of gyration, e.g., sqrt(5/3)*R for sphere etc..."}
	SetVariable Level4_Rg,limits={0,inf,root:Packages:Irena_UnifFit:Level4RgStep},value= root:Packages:Irena_UnifFit:Level4Rg
	CheckBox Level4_FitRg,pos={200,301},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level4_FitRg,variable= root:Packages:Irena_UnifFit:Level4FitRg, help={"Fit Rg? Select properly starting conditions and limits"}
	SetVariable Level4_RgLowLimit,pos={230,300},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level4_RgLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level4RgLowLimit, help={"Low limit for Rg fitting..."}
	SetVariable Level4_RgHighLimit,pos={300,300},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level4_RgHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level4RgHighLimit, help={"High limit for Rg fitting"}

	SetVariable Level4_RgStep,pos={16,320},size={90,16},proc=IR1A_PanelSetVarProc, title="Rg step", help={"Increment with which the Rg setting changes, when you click the up/down arrows in the Rg box"}
	SetVariable Level4_RgStep,limits={0,inf,(0.1*root:Packages:Irena_UnifFit:Level4RgStep)},value= root:Packages:Irena_UnifFit:Level4RgStep
	SetVariable Level4_GStep,pos={120,320},size={90,16},proc=IR1A_PanelSetVarProc, title="G step", help={"Increment with which the G setting changes, when you click the up/down arrows in the G box"}
	SetVariable Level4_GStep,limits={0,inf,(0.1*root:Packages:Irena_UnifFit:Level4GStep)},value= root:Packages:Irena_UnifFit:Level4GStep

	Button Level4_FitRgAndG,pos={220,318},size={130,20},font="Times New Roman",fSize=10,proc=IR1A_InputPanelButtonProc,title="Fit Rg/G bwtn cursors", help={"Do local fit of Gunier dependence between the cursors amd put resulting values into the Rg and G fields"}

	CheckBox Level4_MassFractal,pos={20,350},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Is this mass fractal from lower level?"
	CheckBox Level4_MassFractal,variable= root:Packages:Irena_UnifFit:Level4MassFractal, help={"Is this mass fractal composed of particles from lower level?"}
	SetVariable Level4_SurfToVolRat,pos={230,350},size={130,16},proc=IR1A_PanelSetVarProc,title="Surf / Vol", help={"Surface to volume ratio if P=4 (Porod law) in m2/cm3 if input Q in is A"}
	SetVariable Level4_SurfToVolRat,limits={inf,inf,0},value= root:Packages:Irena_UnifFit:Level4SurfaceToVolRat

	SetVariable Level4_B,pos={14,370},size={180,16},proc=IR1A_PanelSetVarProc,title="B   ", help={"Power law prefactor"}
	SetVariable Level4_B,limits={0,inf,root:Packages:Irena_UnifFit:Level4BStep},value= root:Packages:Irena_UnifFit:Level4B
	CheckBox Level4_FitB,pos={200,371},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level4_FitB,variable= root:Packages:Irena_UnifFit:Level4FitB, help={"Fit the Power law prefactor?, select properly the starting conditions and limits before fitting"}
	SetVariable Level4_BLowLimit,pos={230,370},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level4_BLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level4BLowLimit, help={"Power law prefactor low limit"}
	SetVariable Level4_BHighLimit,pos={300,370},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level4_BHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level4BHighLimit, help={"Power law prefactor high limit"}

	SetVariable Level4_DegreeOfAggreg,pos={14,370},size={140,16},proc=IR1A_PanelSetVarProc,title="Deg. of Aggreg ", help={"Degree of aggregation for mass fractals. = Rg/Rg(level-1) "}
	SetVariable Level4_DegreeOfAggreg,limits={-inf,inf,0},value= root:Packages:Irena_UnifFit:Level4DegreeOfAggreg

	SetVariable Level4_P,pos={14,390},size={180,16},proc=IR1A_PanelSetVarProc,title="P   ", help={"Power law slope, e.g., -4 for Porod tails"}
	SetVariable Level4_P,limits={0,6,root:Packages:Irena_UnifFit:Level4PStep},value= root:Packages:Irena_UnifFit:Level4P
	CheckBox Level4_FitP,pos={200,391},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level4_FitP,variable= root:Packages:Irena_UnifFit:Level4FitP, help={"Fit the Power law slope, select good starting conditions and appropriate limits"}
	SetVariable Level4_PLowLimit,pos={230,390},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level4_PLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level4PLowLimit, help={"Power law low limit for slope"}
	SetVariable Level4_PHighLimit,pos={300,390},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level4_PHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level4PHighLimit, help={"Power law high limit for slope"}

	SetVariable Level4_PStep,pos={16,410},size={90,16},proc=IR1A_PanelSetVarProc, title="P step", help={"Increment with which the P setting changes, when you click the up/down arrows in the P box"}
	SetVariable Level4_PStep,limits={0,inf,(0.1*root:Packages:Irena_UnifFit:Level4PStep)},value= root:Packages:Irena_UnifFit:Level4PStep
	SetVariable Level4_BStep,pos={120,410},size={90,16},proc=IR1A_PanelSetVarProc, title="B step", help={"Increment with which the B setting changes, when you click the up/down arrows in the B box"}
	SetVariable Level4_BStep,limits={0,inf,(0.1*root:Packages:Irena_UnifFit:Level4BStep)},value= root:Packages:Irena_UnifFit:Level4BStep

	Button Level4_FitPAndB,pos={220,408},size={130,20},font="Times New Roman",fSize=10,proc=IR1A_InputPanelButtonProc,title="Fit P/B bwtn cursors", help={"Do Power law fitting between the cursors and put resulting parameters in the P and B fields"}


	SetVariable Level4_RGCO,pos={14,430},size={180,16},proc=IR1A_PanelSetVarProc,title="RgCutoff  "
	SetVariable Level4_RGCO,limits={0,inf,1},value= root:Packages:Irena_UnifFit:Level4RgCO, help={"Size, where the power law dependence ends, usually Rg of lower level, for level 1 it is 0"}
	CheckBox Level4_FitRGCO,pos={200,431},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level4_FitRGCO,variable= root:Packages:Irena_UnifFit:Level4FitRgCo, help={"Fit the RgCutoff ? Select properly starting point and limits."}
	SetVariable Level4_RGCOLowLimit,pos={230,430},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level4_RGCOLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level4RgCoLowLimit, help={"RgCutOff low limit"}
	SetVariable Level4_RGCOHighLimit,pos={300,430},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level4_RGCOHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level4RgCOHighLimit, help={"RgCutOff high limit"}

	Button Level4_SetRGCODefault,pos={20,450},size={100,20},font="Times New Roman",fSize=10,proc=IR1A_InputPanelButtonProc,title="Rg(level-1)->RGCO", help={"This button sets the RgCutOff to value of Rg from previous level (or 0 for level 1)"}
	CheckBox Level4_LinkRGCO,pos={160,455},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Link RGCO"
	CheckBox Level4_LinkRGCO,variable= root:Packages:Irena_UnifFit:Level4LinkRgCo, help={"Link the RgCO to lower level and fit at the same time?"}

	PopupMenu Level4_KFactor,pos={230,450},size={170,21},proc=IR1A_PanelPopupControl,title="k factor :"
	PopupMenu Level4_KFactor,mode=2,popvalue="1",value= #"\"1;1.06;\"", help={"This value is usually 1, for weak decays and mass fractals 1.06"}

	CheckBox Level4_Corelations,pos={90,480},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Is this correlated system? "
	CheckBox Level4_Corelations,variable= root:Packages:Irena_UnifFit:Level4Corelations, help={"Is there a peak or do you expect Corelations between particles to have importance"}

	SetVariable Level4_ETA,pos={14,500},size={180,16},proc=IR1A_PanelSetVarProc,title="ETA    "
	SetVariable Level4_ETA,limits={0,inf,root:Packages:Irena_UnifFit:Level4EtaStep},value= root:Packages:Irena_UnifFit:Level4ETA, help={"Corelations distance for correlated systems using Born-Green approximation by Gunier for multiple order Corelations"}
	CheckBox Level4_FitETA,pos={200,500},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level4_FitETA,variable= root:Packages:Irena_UnifFit:Level4FitETA, help={"Fit correaltion distance? Slect properly the starting conditions and limits."}
	SetVariable Level4_ETALowLimit,pos={230,500},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level4_ETALowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level4ETALowLimit, help={"Correlation distance low limit"}
	SetVariable Level4_ETAHighLimit,pos={300,500},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level4_ETAHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level4ETAHighLimit, help={"Correlation distance high limit"}

	SetVariable Level4_PACK,pos={14,520},size={180,16},proc=IR1A_PanelSetVarProc,title="Pack    "
	SetVariable Level4_PACK,limits={0,8,root:Packages:Irena_UnifFit:Level4PackStep},value= root:Packages:Irena_UnifFit:Level4PACK, help={"Packing factor for domains. For dilute objects 0, for FCC packed spheres 8*0.592"}
	CheckBox Level4_FitPACK,pos={200,520},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level4_FitPACK,variable= root:Packages:Irena_UnifFit:Level4FitPACK, help={"Fit packing factor? Select properly starting condions and limits"}
	SetVariable Level4_PACKLowLimit,pos={230,520},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level4_PACKLowLimit,limits={0,8,0},value= root:Packages:Irena_UnifFit:Level4PACKLowLimit, help={"Low limit for packing factor"}
	SetVariable Level4_PACKHighLimit,pos={300,520},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level4_PACKHighLimit,limits={0,8,0},value= root:Packages:Irena_UnifFit:Level4PACKHighLimit, help={"High limit for packing factor"}

	SetVariable Level4_EtaStep,pos={16,540},size={150,16},proc=IR1A_PanelSetVarProc, title="Eta step", help={"Increment with which the ETA setting changes, when you click the up/down arrows in the ETA box"}
	SetVariable Level4_EtaStep,limits={0.001,inf,(0.1*root:Packages:Irena_UnifFit:Level4EtaStep)},value= root:Packages:Irena_UnifFit:Level4EtaStep
	SetVariable Level4_PackStep,pos={200,540},size={150,16},proc=IR1A_PanelSetVarProc, title="Pack step", help={"Increment with which the Pack setting changes, when you click the up/down arrows in the Pack box"}
	SetVariable Level4_PackStep,limits={0.001,inf,(0.1*root:Packages:Irena_UnifFit:Level4PackStep)},value= root:Packages:Irena_UnifFit:Level4PackStep
////Level 4
////
	//Level5 controls
	TitleBox Level5_Title, title="   Level  5 controls    ", frame=1, labelBack=(0,50000,50000), pos={14,258}, size={150,8}

	SetVariable Level5_G,pos={14,280},size={180,16},proc=IR1A_PanelSetVarProc,title="G   "
	SetVariable Level5_G,limits={0,inf,root:Packages:Irena_UnifFit:Level5GStep},value= root:Packages:Irena_UnifFit:Level5G, help={"Gunier prefactor"}
	CheckBox Level5_FitG,pos={200,281},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level5_FitG,variable= root:Packages:Irena_UnifFit:Level5FitG, help={"Fit G?, find god starting conditions and select fitting limits..."}
	SetVariable Level5_GLowLimit,pos={230,280},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level5_GLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level5GLowLimit, help={"Low limit for G fitting"}
	SetVariable Level5_GHighLimit,pos={300,280},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level5_GHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level5GHighLimit, help={"High limit for G fitting"}

	SetVariable Level5_Rg,pos={14,300},size={180,16},proc=IR1A_PanelSetVarProc,title="Rg   ", help={"Radius of gyration, e.g., sqrt(5/3)*R for sphere etc..."}
	SetVariable Level5_Rg,limits={0,inf,root:Packages:Irena_UnifFit:Level5RgStep},value= root:Packages:Irena_UnifFit:Level5Rg
	CheckBox Level5_FitRg,pos={200,301},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level5_FitRg,variable= root:Packages:Irena_UnifFit:Level5FitRg, help={"Fit Rg? Select properly starting conditions and limits"}
	SetVariable Level5_RgLowLimit,pos={230,300},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level5_RgLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level5RgLowLimit, help={"Low limit for Rg fitting..."}
	SetVariable Level5_RgHighLimit,pos={300,300},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level5_RgHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level5RgHighLimit, help={"High limit for Rg fitting"}

	SetVariable Level5_RgStep,pos={16,320},size={90,16},proc=IR1A_PanelSetVarProc, title="Rg step", help={"Increment with which the Rg setting changes, when you click the up/down arrows in the Rg box"}
	SetVariable Level5_RgStep,limits={0,inf,(0.1*root:Packages:Irena_UnifFit:Level5RgStep)},value= root:Packages:Irena_UnifFit:Level5RgStep
	SetVariable Level5_GStep,pos={120,320},size={90,16},proc=IR1A_PanelSetVarProc, title="G step", help={"Increment with which the G setting changes, when you click the up/down arrows in the G box"}
	SetVariable Level5_GStep,limits={0,inf,(0.1*root:Packages:Irena_UnifFit:Level5GStep)},value= root:Packages:Irena_UnifFit:Level5GStep

	Button Level5_FitRgAndG,pos={220,318},size={130,20},font="Times New Roman",fSize=10,proc=IR1A_InputPanelButtonProc,title="Fit Rg/G bwtn cursors", help={"Do local fit of Gunier dependence between the cursors amd put resulting values into the Rg and G fields"}

	CheckBox Level5_MassFractal,pos={20,350},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Is this mass fractal from lower level?"
	CheckBox Level5_MassFractal,variable= root:Packages:Irena_UnifFit:Level5MassFractal, help={"Is this mass fractal composed of particles from lower level?"}
	SetVariable Level5_SurfToVolRat,pos={230,350},size={130,16},proc=IR1A_PanelSetVarProc,title="Surf / Vol", help={"Surface to volume ratio if P=4 (Porod law) in m2/cm3 if input Q in is A"}
	SetVariable Level5_SurfToVolRat,limits={inf,inf,0},value= root:Packages:Irena_UnifFit:Level5SurfaceToVolRat

	SetVariable Level5_B,pos={14,370},size={180,16},proc=IR1A_PanelSetVarProc,title="B   ", help={"Power law prefactor"}
	SetVariable Level5_B,limits={0,inf,root:Packages:Irena_UnifFit:Level5BStep},value= root:Packages:Irena_UnifFit:Level5B
	CheckBox Level5_FitB,pos={200,371},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level5_FitB,variable= root:Packages:Irena_UnifFit:Level5FitB, help={"Fit the Power law prefactor?, select properly the starting conditions and limits before fitting"}
	SetVariable Level5_BLowLimit,pos={230,370},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level5_BLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level5BLowLimit, help={"Power law prefactor low limit"}
	SetVariable Level5_BHighLimit,pos={300,370},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level5_BHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level5BHighLimit, help={"Power law prefactor high limit"}

	SetVariable Level5_DegreeOfAggreg,pos={14,370},size={140,16},proc=IR1A_PanelSetVarProc,title="Deg. of Aggreg ", help={"Degree of aggregation for mass fractals. = Rg/Rg(level-1) "}
	SetVariable Level5_DegreeOfAggreg,limits={-inf,inf,0},value= root:Packages:Irena_UnifFit:Level5DegreeOfAggreg

	SetVariable Level5_P,pos={14,390},size={180,16},proc=IR1A_PanelSetVarProc,title="P   ", help={"Power law slope, e.g., -4 for Porod tails"}
	SetVariable Level5_P,limits={0,6,root:Packages:Irena_UnifFit:Level5PStep},value= root:Packages:Irena_UnifFit:Level5P
	CheckBox Level5_FitP,pos={200,391},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level5_FitP,variable= root:Packages:Irena_UnifFit:Level5FitP, help={"Fit the Power law slope, select good starting conditions and appropriate limits"}
	SetVariable Level5_PLowLimit,pos={230,390},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level5_PLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level5PLowLimit, help={"Power law low limit for slope"}
	SetVariable Level5_PHighLimit,pos={300,390},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level5_PHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level5PHighLimit, help={"Power law high limit for slope"}

	SetVariable Level5_PStep,pos={16,410},size={90,16},proc=IR1A_PanelSetVarProc, title="P step", help={"Increment with which the P setting changes, when you click the up/down arrows in the P box"}
	SetVariable Level5_PStep,limits={0,inf,(0.1*root:Packages:Irena_UnifFit:Level5PStep)},value= root:Packages:Irena_UnifFit:Level5PStep
	SetVariable Level5_BStep,pos={120,410},size={90,16},proc=IR1A_PanelSetVarProc, title="B step", help={"Increment with which the B setting changes, when you click the up/down arrows in the B box"}
	SetVariable Level5_BStep,limits={0,inf,(0.1*root:Packages:Irena_UnifFit:Level5BStep)},value= root:Packages:Irena_UnifFit:Level5BStep

	Button Level5_FitPAndB,pos={220,408},size={130,20},font="Times New Roman",fSize=10,proc=IR1A_InputPanelButtonProc,title="Fit P/B bwtn cursors", help={"Do Power law fitting between the cursors and put resulting parameters in the P and B fields"}


	SetVariable Level5_RGCO,pos={14,430},size={180,16},proc=IR1A_PanelSetVarProc,title="RgCutoff  "
	SetVariable Level5_RGCO,limits={0,inf,1},value= root:Packages:Irena_UnifFit:Level5RgCO, help={"Size, where the power law dependence ends, usually Rg of lower level, for level 1 it is 0"}
	CheckBox Level5_FitRGCO,pos={200,431},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level5_FitRGCO,variable= root:Packages:Irena_UnifFit:Level5FitRgCo, help={"Fit the RgCutoff ? Select properly starting point and limits."}
	SetVariable Level5_RGCOLowLimit,pos={230,430},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level5_RGCOLowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level5RgCoLowLimit, help={"RgCutOff low limit"}
	SetVariable Level5_RGCOHighLimit,pos={300,430},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level5_RGCOHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level5RgCOHighLimit, help={"RgCutOff high limit"}

	Button Level5_SetRGCODefault,pos={20,450},size={100,20},font="Times New Roman",fSize=10,proc=IR1A_InputPanelButtonProc,title="Rg(level-1)->RGCO", help={"This button sets the RgCutOff to value of Rg from previous level (or 0 for level 1)"}
	CheckBox Level5_LinkRGCO,pos={160,455},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Link RGCO"
	CheckBox Level5_LinkRGCO,variable= root:Packages:Irena_UnifFit:Level5LinkRgCo, help={"Link the RgCO to lower level and fit at the same time?"}

	PopupMenu Level5_KFactor,pos={230,450},size={170,21},proc=IR1A_PanelPopupControl,title="k factor :"
	PopupMenu Level5_KFactor,mode=2,popvalue="1",value= #"\"1;1.06;\"", help={"This value is usually 1, for weak decays and mass fractals 1.06"}

	CheckBox Level5_Corelations,pos={90,480},size={80,16},proc=IR1A_InputPanelCheckboxProc,title="Is this correlated system? "
	CheckBox Level5_Corelations,variable= root:Packages:Irena_UnifFit:Level5Corelations, help={"Is there a peak or do you expect Corelations between particles to have importance"}

	SetVariable Level5_ETA,pos={14,500},size={180,16},proc=IR1A_PanelSetVarProc,title="ETA    "
	SetVariable Level5_ETA,limits={0,inf,root:Packages:Irena_UnifFit:Level5EtaStep},value= root:Packages:Irena_UnifFit:Level5ETA, help={"Corelations distance for correlated systems using Born-Green approximation by Gunier for multiple order Corelations"}
	CheckBox Level5_FitETA,pos={200,500},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level5_FitETA,variable= root:Packages:Irena_UnifFit:Level5FitETA, help={"Fit correaltion distance? Slect properly the starting conditions and limits."}
	SetVariable Level5_ETALowLimit,pos={230,500},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level5_ETALowLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level5ETALowLimit, help={"Correlation distance low limit"}
	SetVariable Level5_ETAHighLimit,pos={300,500},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level5_ETAHighLimit,limits={0,inf,0},value= root:Packages:Irena_UnifFit:Level5ETAHighLimit, help={"Correlation distance high limit"}

	SetVariable Level5_PACK,pos={14,520},size={180,16},proc=IR1A_PanelSetVarProc,title="Pack    "
	SetVariable Level5_PACK,limits={0,8,root:Packages:Irena_UnifFit:Level5PackStep},value= root:Packages:Irena_UnifFit:Level5PACK, help={"Packing factor for domains. For dilute objects 0, for FCC packed spheres 8*0.592"}
	CheckBox Level5_FitPACK,pos={200,520},size={80,16},proc=IR1A_InputPanelCheckboxProc,title=" "
	CheckBox Level5_FitPACK,variable= root:Packages:Irena_UnifFit:Level5FitPACK, help={"Fit packing factor? Select properly starting condions and limits"}
	SetVariable Level5_PACKLowLimit,pos={230,520},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level5_PACKLowLimit,limits={0,8,0},value= root:Packages:Irena_UnifFit:Level5PACKLowLimit, help={"Low limit for packing factor"}
	SetVariable Level5_PACKHighLimit,pos={300,520},size={60,16},proc=IR1A_PanelSetVarProc, title=" "
	SetVariable Level5_PACKHighLimit,limits={0,8,0},value= root:Packages:Irena_UnifFit:Level5PACKHighLimit, help={"High limit for packing factor"}

	SetVariable Level5_EtaStep,pos={16,540},size={150,16},proc=IR1A_PanelSetVarProc, title="Eta step", help={"Increment with which the ETA setting changes, when you click the up/down arrows in the ETA box"}
	SetVariable Level5_EtaStep,limits={0.001,inf,(0.1*root:Packages:Irena_UnifFit:Level5EtaStep)},value= root:Packages:Irena_UnifFit:Level5EtaStep
	SetVariable Level5_PackStep,pos={200,540},size={150,16},proc=IR1A_PanelSetVarProc, title="Pack step", help={"Increment with which the Pack setting changes, when you click the up/down arrows in the Pack box"}
	SetVariable Level5_PackStep,limits={0.001,inf,(0.1*root:Packages:Irena_UnifFit:Level5PackStep)},value= root:Packages:Irena_UnifFit:Level5PackStep
////Level5 controls

	//lets try to update the tabs...
	IR1A_TabPanelControl("test",0)

EndMacro


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1A_TabPanelControl(name,tab)
	String name
	Variable tab

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_UnifFit
	
	NVAR/Z ActiveTab=root:Packages:Irena_UnifFit:ActiveTab
	if (!NVAR_Exists(ActiveTab))
		variable/g root:Packages:Irena_UnifFit:ActiveTab
		NVAR ActiveTab=root:Packages:Irena_UnifFit:ActiveTab
	endif
	ActiveTab=tab+1

	NVAR Nmbdist=root:Packages:Irena_UnifFit:NumberOfLevels
	if (NmbDIst==0)
		ActiveTab=0
	endif
	//need to kill any outstanding windows for shapes... ANy... All should have the same name...
	DoWindow/F IR1A_ControlPanel

	PopupMenu NumberOfLevels mode=NmbDist+1

//	Level1 controls
	NVAR Level1Corelations=root:Packages:Irena_UnifFit:Level1Corelations
	NVAR Level1FitRg=root:Packages:Irena_UnifFit:Level1FitRg
	NVAR Level1FitG=root:Packages:Irena_UnifFit:Level1FitG
	NVAR Level1FitP=root:Packages:Irena_UnifFit:Level1FitP
	NVAR Level1FitB=root:Packages:Irena_UnifFit:Level1FitB
	NVAR Level1FitEta=root:Packages:Irena_UnifFit:Level1FitEta
	NVAR Level1FitPack=root:Packages:Irena_UnifFit:Level1FitPack
	NVAR Level1FitRGCO=root:Packages:Irena_UnifFit:Level1FitRGCO
	NVAR Level1MassFractal=root:Packages:Irena_UnifFit:Level1MassFractal
	NVAR Level1LinkRGCO=root:Packages:Irena_UnifFit:Level1LinkRGCO
	
	TitleBox Level1_Title, disable= (tab!=0 || Nmbdist<1)
	SetVariable Level1_Rg,disable= (tab!=0 || Nmbdist<1)
	CheckBox Level1_FitRg,disable= (tab!=0 || Nmbdist<1)
	SetVariable Level1_RgLowLimit,disable= (tab!=0 || Nmbdist<1 || Level1FitRg!=1)
	SetVariable Level1_RgHighLimit,disable= (tab!=0 || Nmbdist<1|| Level1FitRg!=1)

	SetVariable Level1_G,disable= (tab!=0 || Nmbdist<1)
	CheckBox Level1_FitG,disable= (tab!=0 || Nmbdist<1)
	SetVariable Level1_GLowLimit,disable= (tab!=0 || Nmbdist<1 || Level1FitG!=1)
	SetVariable Level1_GHighLimit,disable= (tab!=0 || Nmbdist<1 || Level1FitG!=1)

	CheckBox Level1_MassFractal, value=Level1MassFractal
	CheckBox Level1_MassFractal,disable= (tab!=0 || Nmbdist<1)
	SetVariable Level1_SurfToVolRat,disable= (tab!=0 || Nmbdist<1)

	SetVariable Level1_RgStep,disable= (tab!=0 || Nmbdist<1)
	SetVariable Level1_GStep,disable= (tab!=0 || Nmbdist<1)
	Button Level1_FitRgAndG,disable= (tab!=0 || Nmbdist<1)
	
	SetVariable Level1_P,disable= (tab!=0 || Nmbdist<1)
	CheckBox Level1_FitP,disable= (tab!=0 || Nmbdist<1)
	SetVariable Level1_PLowLimit,disable= (tab!=0 || Nmbdist<1 || Level1FitP!=1)
	SetVariable Level1_PHighLimit,disable= (tab!=0 || Nmbdist<1 || Level1FitP!=1)

	SetVariable Level1_B,disable= (tab!=0 || Nmbdist<1 || Level1MassFractal)
	CheckBox Level1_FitB,disable= (tab!=0 || Nmbdist<1 ||Level1MassFractal)
	SetVariable Level1_BLowLimit,disable= (tab!=0 || Nmbdist<1 || Level1FitB!=1 || Level1MassFractal)
	SetVariable Level1_BHighLimit,disable= (tab!=0 || Nmbdist<1 || Level1FitB!=1 || Level1MassFractal)
	
	SetVariable Level1_DegreeOfAggreg,disable= (tab!=0 || Nmbdist<1 || !Level1MassFractal || tab==0)	//this control exists only for higher levels...

	SetVariable Level1_PStep,disable= (tab!=0 || Nmbdist<1)
	SetVariable Level1_BStep,disable= (tab!=0 || Nmbdist<1 || Level1MassFractal)
	Button Level1_FitPAndB,disable= (tab!=0 || Nmbdist<1)
	CheckBox Level1_Corelations, value=Level1Corelations
	CheckBox Level1_Corelations,disable= (tab!=0 || Nmbdist<1)
	SetVariable Level1_ETA,disable= (tab!=0 || Nmbdist<1||  Level1Corelations!=1)
	CheckBox Level1_FitETA,disable= (tab!=0 || Nmbdist<1||  Level1Corelations!=1)
	SetVariable Level1_ETALowLimit,disable= (tab!=0 || Nmbdist<1||  Level1Corelations!=1 || Level1FitEta!=1)
	SetVariable Level1_ETAHighLimit,disable= (tab!=0 || Nmbdist<1||  Level1Corelations!=1 || Level1FitEta!=1)

	SetVariable Level1_PACK,disable= (tab!=0 || Nmbdist<1||  Level1Corelations!=1)
	CheckBox Level1_FitPACK,disable= (tab!=0 || Nmbdist<1||  Level1Corelations!=1)
	SetVariable Level1_PACKLowLimit,disable= (tab!=0 || Nmbdist<1||  Level1Corelations!=1 || Level1FitPack!=1)
	SetVariable Level1_PACKHighLimit,disable= (tab!=0 || Nmbdist<1||  Level1Corelations!=1 || Level1FitPack!=1)

	SetVariable Level1_EtaStep,disable= (tab!=0 || Nmbdist<1  ||  Level1Corelations!=1)
	SetVariable Level1_PackStep,disable= (tab!=0 || Nmbdist<1||  Level1Corelations!=1)
	SetVariable Level1_RGCO,disable= (tab!=0 || Nmbdist<1)
	CheckBox Level1_FitRGCO,disable= (tab!=0 || Nmbdist<1 || Level1LinkRGCO) 
	SetVariable Level1_RGCOLowLimit,disable= (tab!=0 || Nmbdist<1 || Level1FitRGCO!=1|| Level1LinkRGCO)
	SetVariable Level1_RGCOHighLimit,disable= (tab!=0 || Nmbdist<1 || Level1FitRGCO!=1|| Level1LinkRGCO)
	Button Level1_SetRGCODefault,disable= (tab!=0 || Nmbdist<1 || tab==0)
	CheckBox Level1_LinkRGCO,disable= (tab!=0 || Nmbdist<1 || tab==0)
	PopupMenu Level1_KFactor,disable= (tab!=0 || Nmbdist<1)
//
//	Level2 controls
	NVAR Level2Corelations=root:Packages:Irena_UnifFit:Level2Corelations
	NVAR Level2FitRg=root:Packages:Irena_UnifFit:Level2FitRg
	NVAR Level2FitG=root:Packages:Irena_UnifFit:Level2FitG
	NVAR Level2FitP=root:Packages:Irena_UnifFit:Level2FitP
	NVAR Level2FitB=root:Packages:Irena_UnifFit:Level2FitB
	NVAR Level2FitEta=root:Packages:Irena_UnifFit:Level2FitEta
	NVAR Level2FitPack=root:Packages:Irena_UnifFit:Level2FitPack
	NVAR Level2FitRGCO=root:Packages:Irena_UnifFit:Level2FitRGCO
	NVAR Level2MassFractal=root:Packages:Irena_UnifFit:Level2MassFractal
	NVAR Level2LinkRGCO=root:Packages:Irena_UnifFit:Level2LinkRGCO
	
	TitleBox Level2_Title,disable= (tab!=1 || Nmbdist<2)
	SetVariable Level2_Rg,disable= (tab!=1 || Nmbdist<2)
	CheckBox Level2_FitRg,disable= (tab!=1 || Nmbdist<2)
	SetVariable Level2_RgLowLimit,disable= (tab!=1 || Nmbdist<2 || Level2FitRg!=1)
	SetVariable Level2_RgHighLimit,disable= (tab!=1 || Nmbdist<2|| Level2FitRg!=1)

	SetVariable Level2_G,disable= (tab!=1 || Nmbdist<2)
	CheckBox Level2_FitG,disable= (tab!=1 || Nmbdist<2)
	SetVariable Level2_GLowLimit,disable= (tab!=1 || Nmbdist<2 || Level2FitG!=1)
	SetVariable Level2_GHighLimit,disable= (tab!=1 || Nmbdist<2 || Level2FitG!=1)

	CheckBox Level2_MassFractal, value=Level2MassFractal
	CheckBox Level2_MassFractal,disable= (tab!=1 || Nmbdist<2 ) 
	SetVariable Level2_SurfToVolRat,disable= (tab!=1 || Nmbdist<2)

	SetVariable Level2_RgStep,disable= (tab!=1 || Nmbdist<2)
	SetVariable Level2_GStep,disable= (tab!=1 || Nmbdist<2)
	Button Level2_FitRgAndG,disable= (tab!=1 || Nmbdist<2)
	
	SetVariable Level2_P,disable= (tab!=1 || Nmbdist<2)
	CheckBox Level2_FitP,disable= (tab!=1 || Nmbdist<2)
	SetVariable Level2_PLowLimit,disable= (tab!=1 || Nmbdist<2 || Level2FitP!=1)
	SetVariable Level2_PHighLimit,disable= (tab!=1 || Nmbdist<2 || Level2FitP!=1)

	SetVariable Level2_B,disable= (tab!=1 || Nmbdist<2 || Level2MassFractal)
	CheckBox Level2_FitB,disable= (tab!=1 || Nmbdist<2 ||Level2MassFractal)
	SetVariable Level2_BLowLimit,disable= (tab!=1 || Nmbdist<2 || Level2FitB!=1 || Level2MassFractal)
	SetVariable Level2_BHighLimit,disable= (tab!=1 || Nmbdist<2 || Level2FitB!=1 || Level2MassFractal)
	
	SetVariable Level2_DegreeOfAggreg,disable= (tab!=1 || Nmbdist<2 || !Level2MassFractal)

	SetVariable Level2_PStep,disable= (tab!=1 || Nmbdist<2)
	SetVariable Level2_BStep,disable= (tab!=1 || Nmbdist<2 || Level2MassFractal)
	Button Level2_FitPAndB,disable= (tab!=1 || Nmbdist<2)
	CheckBox Level2_Corelations, value=Level2Corelations
	CheckBox Level2_Corelations,disable= (tab!=1 || Nmbdist<2)
	SetVariable Level2_ETA,disable= (tab!=1 || Nmbdist<2||  Level2Corelations!=1)
	CheckBox Level2_FitETA,disable= (tab!=1 || Nmbdist<2||  Level2Corelations!=1)
	SetVariable Level2_ETALowLimit,disable= (tab!=1 || Nmbdist<2||  Level2Corelations!=1 || Level2FitEta!=1)
	SetVariable Level2_ETAHighLimit,disable= (tab!=1 || Nmbdist<2||  Level2Corelations!=1 || Level2FitEta!=1)

	SetVariable Level2_PACK,disable= (tab!=1 || Nmbdist<2||  Level2Corelations!=1)
	CheckBox Level2_FitPACK,disable= (tab!=1 || Nmbdist<2||  Level2Corelations!=1)
	SetVariable Level2_PACKLowLimit,disable= (tab!=1 || Nmbdist<2||  Level2Corelations!=1 || Level2FitPack!=1)
	SetVariable Level2_PACKHighLimit,disable= (tab!=1 || Nmbdist<2||  Level2Corelations!=1 || Level2FitPack!=1)

	SetVariable Level2_EtaStep,disable= (tab!=1 || Nmbdist<2  ||  Level2Corelations!=1)
	SetVariable Level2_PackStep,disable= (tab!=1 || Nmbdist<2||  Level2Corelations!=1)
	SetVariable Level2_RGCO,disable= (tab!=1 || Nmbdist<2)
	CheckBox Level2_FitRGCO,disable= (tab!=1 || Nmbdist<2 || Level2LinkRGCO)
	SetVariable Level2_RGCOLowLimit,disable= (tab!=1 || Nmbdist<2 || Level2FitRGCO!=1 || Level2LinkRGCO)
	SetVariable Level2_RGCOHighLimit,disable= (tab!=1 || Nmbdist<2 || Level2FitRGCO!=1 || Level2LinkRGCO)
	Button Level2_SetRGCODefault,disable= (tab!=1 || Nmbdist<2)
	CheckBox Level2_LinkRGCO,disable= (tab!=1 || Nmbdist<2)
	PopupMenu Level2_KFactor,disable= (tab!=1 || Nmbdist<2)
//
//
//	Level3 controls
	NVAR Level3Corelations=root:Packages:Irena_UnifFit:Level3Corelations
	NVAR Level3FitRg=root:Packages:Irena_UnifFit:Level3FitRg
	NVAR Level3FitG=root:Packages:Irena_UnifFit:Level3FitG
	NVAR Level3FitP=root:Packages:Irena_UnifFit:Level3FitP
	NVAR Level3FitB=root:Packages:Irena_UnifFit:Level3FitB
	NVAR Level3FitEta=root:Packages:Irena_UnifFit:Level3FitEta
	NVAR Level3FitPack=root:Packages:Irena_UnifFit:Level3FitPack
	NVAR Level3FitRGCO=root:Packages:Irena_UnifFit:Level3FitRGCO
	NVAR Level3MassFractal=root:Packages:Irena_UnifFit:Level3MassFractal
	NVAR Level3LinkRGCO=root:Packages:Irena_UnifFit:Level3LinkRGCO
	
	TitleBox Level3_Title,disable= (tab!=2 || Nmbdist<3)
	SetVariable Level3_Rg,disable= (tab!=2 || Nmbdist<3)
	CheckBox Level3_FitRg,disable= (tab!=2 || Nmbdist<3)
	SetVariable Level3_RgLowLimit,disable= (tab!=2 || Nmbdist<3 || Level3FitRg!=1)
	SetVariable Level3_RgHighLimit,disable= (tab!=2 || Nmbdist<3|| Level3FitRg!=1)

	SetVariable Level3_G,disable= (tab!=2 || Nmbdist<3)
	CheckBox Level3_FitG,disable= (tab!=2 || Nmbdist<3)
	SetVariable Level3_GLowLimit,disable= (tab!=2 || Nmbdist<3 || Level3FitG!=1)
	SetVariable Level3_GHighLimit,disable= (tab!=2 || Nmbdist<3 || Level3FitG!=1)

	CheckBox Level3_MassFractal, value=Level3MassFractal
	CheckBox Level3_MassFractal,disable= (tab!=2 || Nmbdist<3) 
	SetVariable Level3_SurfToVolRat,disable= (tab!=2 || Nmbdist<3)

	SetVariable Level3_RgStep,disable= (tab!=2 || Nmbdist<3)
	SetVariable Level3_GStep,disable= (tab!=2 || Nmbdist<3)
	Button Level3_FitRgAndG,disable= (tab!=2 || Nmbdist<3)
	
	SetVariable Level3_P,disable= (tab!=2 || Nmbdist<3)
	CheckBox Level3_FitP,disable= (tab!=2 || Nmbdist<3)
	SetVariable Level3_PLowLimit,disable= (tab!=2 || Nmbdist<3 || Level3FitP!=1)
	SetVariable Level3_PHighLimit,disable= (tab!=2 || Nmbdist<3 || Level3FitP!=1)

	SetVariable Level3_B,disable= (tab!=2 || Nmbdist<3 || Level3MassFractal)
	CheckBox Level3_FitB,disable= (tab!=2 || Nmbdist<3 ||Level3MassFractal)
	SetVariable Level3_BLowLimit,disable= (tab!=2 || Nmbdist<3 || Level3FitB!=1 || Level3MassFractal)
	SetVariable Level3_BHighLimit,disable= (tab!=2 || Nmbdist<3 || Level3FitB!=1 || Level3MassFractal)
	
	SetVariable Level3_DegreeOfAggreg,disable= (tab!=2 || Nmbdist<3 || !Level3MassFractal)

	SetVariable Level3_PStep,disable= (tab!=2 || Nmbdist<3)
	SetVariable Level3_BStep,disable= (tab!=2 || Nmbdist<3 || Level3MassFractal)
	Button Level3_FitPAndB,disable= (tab!=2 || Nmbdist<3)
	CheckBox Level3_Corelations, value=Level3Corelations
	CheckBox Level3_Corelations,disable= (tab!=2 || Nmbdist<3)
	SetVariable Level3_ETA,disable= (tab!=2 || Nmbdist<3||  Level3Corelations!=1)
	CheckBox Level3_FitETA,disable= (tab!=2 || Nmbdist<3||  Level3Corelations!=1)
	SetVariable Level3_ETALowLimit,disable= (tab!=2 || Nmbdist<3||  Level3Corelations!=1 || Level3FitEta!=1)
	SetVariable Level3_ETAHighLimit,disable= (tab!=2 || Nmbdist<3||  Level3Corelations!=1 || Level3FitEta!=1)

	SetVariable Level3_PACK,disable= (tab!=2 || Nmbdist<3||  Level3Corelations!=1)
	CheckBox Level3_FitPACK,disable= (tab!=2 || Nmbdist<3||  Level3Corelations!=1)
	SetVariable Level3_PACKLowLimit,disable= (tab!=2 || Nmbdist<3||  Level3Corelations!=1 || Level3FitPack!=1)
	SetVariable Level3_PACKHighLimit,disable= (tab!=2 || Nmbdist<3||  Level3Corelations!=1 || Level3FitPack!=1)

	SetVariable Level3_EtaStep,disable= (tab!=2 || Nmbdist<3  ||  Level3Corelations!=1)
	SetVariable Level3_PackStep,disable= (tab!=2 || Nmbdist<3||  Level3Corelations!=1)
	SetVariable Level3_RGCO,disable= (tab!=2 || Nmbdist<3)
	CheckBox Level3_FitRGCO,disable= (tab!=2 || Nmbdist<3 || Level3LinkRGCO)
	SetVariable Level3_RGCOLowLimit,disable= (tab!=2 || Nmbdist<3 || Level3FitRGCO!=1 || Level3LinkRGCO)
	SetVariable Level3_RGCOHighLimit,disable= (tab!=2 || Nmbdist<3 || Level3FitRGCO!=1 || Level3LinkRGCO)
	Button Level3_SetRGCODefault,disable= (tab!=2 || Nmbdist<3)
	CheckBox Level3_LinkRGCO,disable= (tab!=2 || Nmbdist<3)
	PopupMenu Level3_KFactor,disable= (tab!=2 || Nmbdist<3)
//
//

//	Level4 controls
	NVAR Level4Corelations=root:Packages:Irena_UnifFit:Level4Corelations
	NVAR Level4FitRg=root:Packages:Irena_UnifFit:Level4FitRg
	NVAR Level4FitG=root:Packages:Irena_UnifFit:Level4FitG
	NVAR Level4FitP=root:Packages:Irena_UnifFit:Level4FitP
	NVAR Level4FitB=root:Packages:Irena_UnifFit:Level4FitB
	NVAR Level4FitEta=root:Packages:Irena_UnifFit:Level4FitEta
	NVAR Level4FitPack=root:Packages:Irena_UnifFit:Level4FitPack
	NVAR Level4FitRGCO=root:Packages:Irena_UnifFit:Level4FitRGCO
	NVAR Level4MassFractal=root:Packages:Irena_UnifFit:Level4MassFractal
	NVAR Level4LinkRGCO=root:Packages:Irena_UnifFit:Level4LinkRGCO
	
	TitleBox Level4_Title,disable= (tab!=3 || Nmbdist<4)
	SetVariable Level4_Rg,disable= (tab!=3 || Nmbdist<4)
	CheckBox Level4_FitRg,disable= (tab!=3 || Nmbdist<4)
	SetVariable Level4_RgLowLimit,disable= (tab!=3 || Nmbdist<4 || Level4FitRg!=1)
	SetVariable Level4_RgHighLimit,disable= (tab!=3 || Nmbdist<4|| Level4FitRg!=1)

	SetVariable Level4_G,disable= (tab!=3 || Nmbdist<4)
	CheckBox Level4_FitG,disable= (tab!=3 || Nmbdist<4)
	SetVariable Level4_GLowLimit,disable= (tab!=3 || Nmbdist<4 || Level4FitG!=1)
	SetVariable Level4_GHighLimit,disable= (tab!=3 || Nmbdist<4 || Level4FitG!=1)

	CheckBox Level4_MassFractal, value=Level4MassFractal
	CheckBox Level4_MassFractal,disable= (tab!=3 || Nmbdist<4) 
	SetVariable Level4_SurfToVolRat,disable= (tab!=3 || Nmbdist<4)

	SetVariable Level4_RgStep,disable= (tab!=3 || Nmbdist<4)
	SetVariable Level4_GStep,disable= (tab!=3 || Nmbdist<4)
	Button Level4_FitRgAndG,disable= (tab!=3 || Nmbdist<4)
	
	SetVariable Level4_P,disable= (tab!=3 || Nmbdist<4)
	CheckBox Level4_FitP,disable= (tab!=3 || Nmbdist<4)
	SetVariable Level4_PLowLimit,disable= (tab!=3 || Nmbdist<4 || Level4FitP!=1)
	SetVariable Level4_PHighLimit,disable= (tab!=3 || Nmbdist<4 || Level4FitP!=1)

	SetVariable Level4_B,disable= (tab!=3 || Nmbdist<4 || Level4MassFractal)
	CheckBox Level4_FitB,disable= (tab!=3 || Nmbdist<4 ||Level4MassFractal)
	SetVariable Level4_BLowLimit,disable= (tab!=3 || Nmbdist<4 || Level4FitB!=1 || Level4MassFractal)
	SetVariable Level4_BHighLimit,disable= (tab!=3 || Nmbdist<4 || Level4FitB!=1 || Level4MassFractal)
	
	SetVariable Level4_DegreeOfAggreg,disable= (tab!=3 || Nmbdist<4 || !Level4MassFractal)

	SetVariable Level4_PStep,disable= (tab!=3 || Nmbdist<4)
	SetVariable Level4_BStep,disable= (tab!=3 || Nmbdist<4 || Level4MassFractal)
	Button Level4_FitPAndB,disable= (tab!=3 || Nmbdist<4)
	CheckBox Level4_Corelations, value=Level4Corelations
	CheckBox Level4_Corelations,disable= (tab!=3 || Nmbdist<4)
	SetVariable Level4_ETA,disable= (tab!=3 || Nmbdist<4||  Level4Corelations!=1)
	CheckBox Level4_FitETA,disable= (tab!=3 || Nmbdist<4||  Level4Corelations!=1)
	SetVariable Level4_ETALowLimit,disable= (tab!=3 || Nmbdist<4||  Level4Corelations!=1 || Level4FitEta!=1)
	SetVariable Level4_ETAHighLimit,disable= (tab!=3 || Nmbdist<4||  Level4Corelations!=1 || Level4FitEta!=1)

	SetVariable Level4_PACK,disable= (tab!=3 || Nmbdist<4||  Level4Corelations!=1)
	CheckBox Level4_FitPACK,disable= (tab!=3 || Nmbdist<4||  Level4Corelations!=1)
	SetVariable Level4_PACKLowLimit,disable= (tab!=3 || Nmbdist<4||  Level4Corelations!=1 || Level4FitPack!=1)
	SetVariable Level4_PACKHighLimit,disable= (tab!=3 || Nmbdist<4||  Level4Corelations!=1 || Level4FitPack!=1)

	SetVariable Level4_EtaStep,disable= (tab!=3 || Nmbdist<4  ||  Level4Corelations!=1)
	SetVariable Level4_PackStep,disable= (tab!=3 || Nmbdist<4||  Level4Corelations!=1)
	SetVariable Level4_RGCO,disable= (tab!=3 || Nmbdist<4)
	CheckBox Level4_FitRGCO,disable= (tab!=3 || Nmbdist<4 || Level4LinkRGCO)
	SetVariable Level4_RGCOLowLimit,disable= (tab!=3 || Nmbdist<4 || Level4FitRGCO!=1 || Level4LinkRGCO)
	SetVariable Level4_RGCOHighLimit,disable= (tab!=3 || Nmbdist<4 || Level4FitRGCO!=1 || Level4LinkRGCO)
	Button Level4_SetRGCODefault,disable= (tab!=3 || Nmbdist<4)
	CheckBox Level4_LinkRGCO,disable= (tab!=3 || Nmbdist<4)
	PopupMenu Level4_KFactor,disable= (tab!=3 || Nmbdist<4)
//
//	Level5 controls
	NVAR Level5Corelations=root:Packages:Irena_UnifFit:Level5Corelations
	NVAR Level5FitRg=root:Packages:Irena_UnifFit:Level5FitRg
	NVAR Level5FitG=root:Packages:Irena_UnifFit:Level5FitG
	NVAR Level5FitP=root:Packages:Irena_UnifFit:Level5FitP
	NVAR Level5FitB=root:Packages:Irena_UnifFit:Level5FitB
	NVAR Level5FitEta=root:Packages:Irena_UnifFit:Level5FitEta
	NVAR Level5FitPack=root:Packages:Irena_UnifFit:Level5FitPack
	NVAR Level5FitRGCO=root:Packages:Irena_UnifFit:Level5FitRGCO
	NVAR Level5MassFractal=root:Packages:Irena_UnifFit:Level5MassFractal
	NVAR Level5LinkRGCO=root:Packages:Irena_UnifFit:Level5LinkRGCO
	
	TitleBox Level5_Title,disable= (tab!=4 || Nmbdist<5)
	SetVariable Level5_Rg,disable= (tab!=4 || Nmbdist<5)
	CheckBox Level5_FitRg,disable= (tab!=4 || Nmbdist<5)
	SetVariable Level5_RgLowLimit,disable= (tab!=4 || Nmbdist<5 || Level5FitRg!=1)
	SetVariable Level5_RgHighLimit,disable= (tab!=4 || Nmbdist<5|| Level5FitRg!=1)

	SetVariable Level5_G,disable= (tab!=4 || Nmbdist<5)
	CheckBox Level5_FitG,disable= (tab!=4 || Nmbdist<5)
	SetVariable Level5_GLowLimit,disable= (tab!=4 || Nmbdist<5 || Level5FitG!=1)
	SetVariable Level5_GHighLimit,disable= (tab!=4 || Nmbdist<5 || Level5FitG!=1)

	CheckBox Level5_MassFractal, value=Level5MassFractal
	CheckBox Level5_MassFractal,disable= (tab!=4 || Nmbdist<5) 
	SetVariable Level5_SurfToVolRat,disable= (tab!=4 || Nmbdist<5)

	SetVariable Level5_RgStep,disable= (tab!=4 || Nmbdist<5)
	SetVariable Level5_GStep,disable= (tab!=4 || Nmbdist<5)
	Button Level5_FitRgAndG,disable= (tab!=4 || Nmbdist<5)
	
	SetVariable Level5_P,disable= (tab!=4 || Nmbdist<5)
	CheckBox Level5_FitP,disable= (tab!=4 || Nmbdist<5)
	SetVariable Level5_PLowLimit,disable= (tab!=4 || Nmbdist<5 || Level5FitP!=1)
	SetVariable Level5_PHighLimit,disable= (tab!=4 || Nmbdist<5 || Level5FitP!=1)

	SetVariable Level5_B,disable= (tab!=4 || Nmbdist<5 || Level5MassFractal)
	CheckBox Level5_FitB,disable= (tab!=4 || Nmbdist<5 ||Level5MassFractal)
	SetVariable Level5_BLowLimit,disable= (tab!=4 || Nmbdist<5 || Level5FitB!=1 || Level5MassFractal)
	SetVariable Level5_BHighLimit,disable= (tab!=4 || Nmbdist<5 || Level5FitB!=1 || Level5MassFractal)
	
	SetVariable Level5_DegreeOfAggreg,disable= (tab!=4 || Nmbdist<5 || !Level5MassFractal)

	SetVariable Level5_PStep,disable= (tab!=4 || Nmbdist<5)
	SetVariable Level5_BStep,disable= (tab!=4 || Nmbdist<5 || Level5MassFractal)
	Button Level5_FitPAndB,disable= (tab!=4 || Nmbdist<5)
	CheckBox Level5_Corelations, value=Level5Corelations
	CheckBox Level5_Corelations,disable= (tab!=4 || Nmbdist<5)
	SetVariable Level5_ETA,disable= (tab!=4 || Nmbdist<5||  Level5Corelations!=1)
	CheckBox Level5_FitETA,disable= (tab!=4 || Nmbdist<5||  Level5Corelations!=1)
	SetVariable Level5_ETALowLimit,disable= (tab!=4 || Nmbdist<5||  Level5Corelations!=1 || Level5FitEta!=1)
	SetVariable Level5_ETAHighLimit,disable= (tab!=4 || Nmbdist<5||  Level5Corelations!=1 || Level5FitEta!=1)

	SetVariable Level5_PACK,disable= (tab!=4 || Nmbdist<5||  Level5Corelations!=1)
	CheckBox Level5_FitPACK,disable= (tab!=4 || Nmbdist<5||  Level5Corelations!=1)
	SetVariable Level5_PACKLowLimit,disable= (tab!=4 || Nmbdist<5||  Level5Corelations!=1 || Level5FitPack!=1)
	SetVariable Level5_PACKHighLimit,disable= (tab!=4 || Nmbdist<5||  Level5Corelations!=1 || Level5FitPack!=1)

	SetVariable Level5_EtaStep,disable= (tab!=4 || Nmbdist<5  ||  Level5Corelations!=1)
	SetVariable Level5_PackStep,disable= (tab!=4 || Nmbdist<5||  Level5Corelations!=1)
	SetVariable Level5_RGCO,disable= (tab!=4 || Nmbdist<5)
	CheckBox Level5_FitRGCO,disable= (tab!=4 || Nmbdist<5 || Level5LinkRGCO)
	SetVariable Level5_RGCOLowLimit,disable= (tab!=4 || Nmbdist<5 || Level5FitRGCO!=1 || Level5LinkRGCO)
	SetVariable Level5_RGCOHighLimit,disable= (tab!=4 || Nmbdist<5 || Level5FitRGCO!=1 || Level5LinkRGCO)
	Button Level5_SetRGCODefault,disable= (tab!=4 || Nmbdist<5)
	CheckBox Level5_LinkRGCO,disable= (tab!=4 || Nmbdist<5)
	PopupMenu Level5_KFactor,disable= (tab!=4 || Nmbdist<5)
//
	//update the displayed local fits in graph
	IR1A_DisplayLocalFits(tab+1,0)
	setDataFolder oldDF

End



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

