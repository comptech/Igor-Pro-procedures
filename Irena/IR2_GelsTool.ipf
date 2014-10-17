#pragma rtGlobals=1		// Use modern global access method.
#pragma version=4.01


//this is package for Analytical models
//coded by Jan Ilavsky, September 2004
//December 2008
//changed to Analytic models by adding Teubner-Strey as additional model. 
//note: it seems illogical that one sample would require both at once... 
//added also full Unified level as an option. 
// http://www.ncnr.nist.gov/resources/sansmodels/TeubnerStrey.html
	//Teubner, M; Strey, R. J. Chem. Phys., 1987, 87, 3195.
	//Schubert, K-V.; Strey, R.; Kline, S. R.; and E. W. Kaler J. Chem. Phys., 1994, 101, 5343.
//version 4.01, May 2010, adds Ciccariello-Benedetti model for Porod scattering from surfaces with layer
	// J. Appl. Cryst. (2003). 36, 744 - 748	
	// J. Appl. Cryst. (1994). 27, 249 - 256	
	

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2H_GelsMainFnct()

	IN2G_CheckScreenSize("height",670)

	IR2C_InitConfigMain()
	DoWindow IR2H_SI_Q2_PlotGels
	if (V_Flag)
		DoWindow/K IR2H_SI_Q2_PlotGels	
	endif
	DoWindow IR2H_IQ4_Q_PlotGels
	if (V_Flag)
		DoWindow/K IR2H_IQ4_Q_PlotGels	
	endif
	DoWindow IR2H_LogLogPlotGels
	if (V_Flag)
		DoWindow/K IR2H_LogLogPlotGels	
	endif
	DoWindow IR2H_ControlPanel
	if (V_Flag)
		DoWindow/K IR2H_ControlPanel
	endif
	IR2H_Initialize()
	Execute ("IR2H_ControlPanel()")
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
static Function IR2H_Initialize()
	//function, which creates the folder for SAS modeling and creates the strings and variables
	
	string oldDf=GetDataFolder(1)
	
	NewDataFolder/O/S root:Packages
	NewdataFolder/O/S root:Packages:Gels_Modeling
	
	string/g ListOfVariables
	string/g ListOfStrings
	
	//here define the lists of variables and strings needed, separate names by ;...
	
	ListOfVariables="UseIndra2Data;UseQRSdata;CurrentTab;UseLowQInDB;"
	ListOfVariables+="UseSlitSmearedData;SlitLength;"	
	ListOfVariables+="SASBackground;SASBackgroundStep;FitSASBackground;UpdateAutomatically;SASBackgroundError;"
	//Unified level
	ListOfVariables+="LowQslope;LowQPrefactor;FitLowQslope;FitLowQPrefactor;LowQslopeLowLimit;LowQPrefactorLowLimit;"
	ListOfVariables+="LowQslopeError;LowQPrefactorError;LowQslopeHighLimit;LowQPrefactorHighLimit;"
	ListOfVariables+="LowQRg;FitLowQRg;LowQRgLowLimit;LowQRgHighLimit;LowQRgError;"
	ListOfVariables+="LowQRgPrefactor;FitLowQRgPrefactor;LowQRgPrefactorLowLimit;LowQRgPrefactorHighLimit;LowQRgPrefactorError;"
	//Debye-Bueche parameters	
	ListOfVariables+="DBPrefactor;DBEta;DBcorrL;DBWavelength;UseDB;"
	ListOfVariables+="DBEtaError;DBcorrLError;"
	ListOfVariables+="FitDBPrefactor;FitDBEta;FitDBcorrL;"
	ListOfVariables+="DBPrefactorHighLimit;DBEtaHighLimit;DBcorrLHighLimit;"
	ListOfVariables+="DBPrefactorLowLimit;DBEtaLowLimit;DBcorrLLowLimit;"
	//Teubner-Strey Model
	ListOfVariables+="TSPrefactor;FitTSPrefactor;TSPrefactorHighLimit;TSPrefactorLowLimit;TSPrefactorError;UseTS;"
	ListOfVariables+="TSAvalue;FitTSAvalue;TSAvalueHighLimit;TSAvalueLowLimit;TSAvalueError;"
	ListOfVariables+="TSC1Value;FitTSC1Value;TSC1ValueHighLimit;TSC1ValueLowLimit;TSC1ValueError;"
	ListOfVariables+="TSC2Value;FitTSC2Value;TSC2ValueHighLimit;TSC2ValueLowLimit;TSC2ValueError;"
	ListOfVariables+="TSCorrelationLength;TSCorrLengthError;TSRepeatDistance;TSRepDistError;"
	//Benedetti-Ciccariello Coated Porous media Porods oscillations
	ListOfVariables+="BC_PorodsSpecSurfArea;BC_SolidScatLengthDensity;BC_VoidScatLengthDensity;BC_LayerScatLengthDens;"
	ListOfVariables+="BC_CoatingsThickness;UseCiccBen;"
	ListOfVariables+="BC_LayerScatLengthDensHL;BC_LayerScatLengthDensLL;FitBC_LayerScatLengthDens;"
	ListOfVariables+="BC_CoatingsThicknessHL;BC_CoatingsThicknessLL;FitBC_CoatingsThickness;"
	ListOfVariables+="BC_PorodsSpecSurfAreaHL;BC_PorodsSpecSurfAreaLL;FitBC_PorodsSpecSurfArea;"
	ListOfVariables+="BC_PorodsSpecSurfAreaError;BC_CoatingsThicknessError;BC_LayerScatLengthDensError;"
	

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
//	Wave/Z CoefNames=root:Packages:SAS_Modeling:CoefNames
//	Wave/Z CoefficientInput=root:Packages:SAS_Modeling:CoefficientInput
//	KillWaves/Z CoefNames, CoefficientInput
	
	IR2H_SetInitialValues()
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR2H_SetInitialValues()
	//and here set default values...

	string OldDf=getDataFolder(1)
	setDataFolder root:Packages:Gels_Modeling
	NVAR UseQRSData=root:Packages:Gels_Modeling:UseQRSData
	NVAR UseIndra2data=root:Packages:Gels_Modeling:UseIndra2data
	NVAR FitSASBackground=root:Packages:Gels_Modeling:FitSASBackground
	NVAR UpdateAutomatically=root:Packages:Gels_Modeling:UpdateAutomatically

	NVAR CurrentTab=root:Packages:Gels_Modeling:CurrentTab
	NVAR UseSlitSmearedData=root:Packages:Gels_Modeling:UseSlitSmearedData
	NVAR SlitLength=root:Packages:Gels_Modeling:SlitLength
	NVAR SASBackgroundStep=root:Packages:Gels_Modeling:SASBackgroundStep

	NVAR DBPrefactor=root:Packages:Gels_Modeling:DBPrefactor
	NVAR DBPrefactorLowLimit=root:Packages:Gels_Modeling:DBPrefactorLowLimit
	NVAR DBPrefactorHighLimit=root:Packages:Gels_Modeling:DBPrefactorHighLimit

	NVAR DBEta=root:Packages:Gels_Modeling:DBEta
	NVAR DBEtaLowLimit=root:Packages:Gels_Modeling:DBEtaLowLimit
	NVAR DBEtaHighLimit=root:Packages:Gels_Modeling:DBEtaHighLimit

	NVAR DBcorrL=root:Packages:Gels_Modeling:DBcorrL
	NVAR DBcorrLLowLimit=root:Packages:Gels_Modeling:DBcorrLLowLimit
	NVAR DBcorrLHighLimit=root:Packages:Gels_Modeling:DBcorrLHighLimit

	NVAR LowQslope=root:Packages:Gels_Modeling:LowQslope
	NVAR LowQslopeLowLimit=root:Packages:Gels_Modeling:LowQslopeLowLimit
	NVAR LowQslopeHighLimit=root:Packages:Gels_Modeling:LowQslopeHighLimit

	NVAR LowQPrefactor=root:Packages:Gels_Modeling:LowQPrefactor
	NVAR LowQPrefactorLowLimit=root:Packages:Gels_Modeling:LowQPrefactorLowLimit
	NVAR LowQPrefactorHighLimit=root:Packages:Gels_Modeling:LowQPrefactorHighLimit
	//Rg
	NVAR LowQRg=root:Packages:Gels_Modeling:LowQRg
	NVAR LowQRgLowLimit=root:Packages:Gels_Modeling:LowQRgLowLimit
	NVAR LowQRgHighLimit=root:Packages:Gels_Modeling:LowQRgHighLimit
	//RGPref
	NVAR LowQRgPrefactor=root:Packages:Gels_Modeling:LowQRgPrefactor
	NVAR LowQRgPrefactorLowLimit=root:Packages:Gels_Modeling:LowQRgPrefactorLowLimit
	NVAR LowQRgPrefactorHighLimit=root:Packages:Gels_Modeling:LowQRgPrefactorHighLimit
	//TSPref
	NVAR TSPrefactor=root:Packages:Gels_Modeling:TSPrefactor
	NVAR TSPrefactorLowLimit=root:Packages:Gels_Modeling:TSPrefactorLowLimit
	NVAR TSPrefactorHighLimit=root:Packages:Gels_Modeling:TSPrefactorHighLimit
	//TSA
	NVAR TSAvalue=root:Packages:Gels_Modeling:TSAvalue
	NVAR TSAvalueLowLimit=root:Packages:Gels_Modeling:TSAvalueLowLimit
	NVAR TSAvalueHighLimit=root:Packages:Gels_Modeling:TSAvalueHighLimit
	//TSC1
	NVAR TSC1Value=root:Packages:Gels_Modeling:TSC1Value
	NVAR TSC1ValueLowLimit=root:Packages:Gels_Modeling:TSC1ValueLowLimit
	NVAR TSC1ValueHighLimit=root:Packages:Gels_Modeling:TSC1ValueHighLimit
	//TSC2
	NVAR TSC2Value=root:Packages:Gels_Modeling:TSC2Value
	NVAR TSC2ValueLowLimit=root:Packages:Gels_Modeling:TSC2ValueLowLimit
	NVAR TSC2ValueHighLimit=root:Packages:Gels_Modeling:TSC2ValueHighLimit
	//Ciccariellos tool
	NVAR BC_PorodsSpecSurfArea=root:Packages:Gels_Modeling:BC_PorodsSpecSurfArea
	NVAR BC_SolidScatLengthDensity=root:Packages:Gels_Modeling:BC_SolidScatLengthDensity
	NVAR BC_VoidScatLengthDensity=root:Packages:Gels_Modeling:BC_VoidScatLengthDensity
	NVAR BC_LayerScatLengthDens=root:Packages:Gels_Modeling:BC_LayerScatLengthDens
//	NVAR BC_CoatingsThickness=root:Packages:Gels_Modeling:BC_CoatingsThickness
	
	NVAR DBWavelength=root:Packages:Gels_Modeling:DBWavelength

	if(LowQRg<=0)
		LowQRg=1e5
		LowQRgLowLimit=1
		LowQRgHighLimit=1e10
	endif
	if(LowQRgPrefactor<=0)
		LowQRgPrefactor=1
		LowQRgPrefactorLowLimit=1e-10
		LowQRgPrefactorHighLimit=1e10
	endif

	if(TSPrefactor<=0)
		TSPrefactor=1
		TSPrefactorLowLimit=1e-10
		TSPrefactorHighLimit=1e10
	endif

	if(TSAvalue==0)
		TSAvalue=0.1
		TSAvalueLowLimit=-1e10
		TSAvalueHighLimit=1e10
	endif
	if(TSC1Value==0)
		TSC1Value=-30
		TSC1ValueLowLimit=-1e10
		TSC1ValueHighLimit=1e10
	endif
	if(TSC2Value==0)
		TSC2Value=5000
		TSC2ValueLowLimit=-1e10
		TSC2ValueHighLimit=1e10
	endif


	CurrentTab=0
	if(SlitLength==0)
		SlitLength = 1 
	endif
	SASBackgroundStep=1
	if(DBPrefactor==0)
		DBPrefactor = 1
		DBPrefactorLowLimit = 1e-10
		DBPrefactorHighLimit = 1e10
	endif
	if(DBEta==0)
		DBEta=1
		DBEtaLowLimit=1e-6
		DBEtaHighLimit=1e6
	endif
	if(DBcorrL==0)
		DBcorrL=200
		DBcorrLLowLimit=2
		DBcorrLHighLimit=1e6
	endif
	if(LowQslope==0)
		LowQslope=3
		LowQslopeLowLimit=1
		LowQslopeHighLimit=4
	endif
	if(LowQPrefactor==0)
		LowQPrefactor=1
		LowQPrefactorLowLimit=1e-10
		LowQPrefactorHighLimit=1e10
	endif
	if(DBWavelength==0)
		DBWavelength=1
	endif
	if (UseQRSData)
		UseIndra2data=0
	endif
	if (FitSASBackground==0)
		FitSASBackground=1
	endif
	
	
	if(BC_PorodsSpecSurfArea<=0)
		BC_PorodsSpecSurfArea=1e4
	endif
	if(BC_SolidScatLengthDensity<=0)
		BC_SolidScatLengthDensity=19.32			//this is value for silica 
	endif

	UpdateAutomatically=0

	setDataFolder oldDF
	
end	




//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//****


Proc IR2H_ControlPanel() 
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(2.25,20,369.75,670) as "Analytical models"
	DoWindow/C IR2H_Controlpanel

	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup="r*:q*;"
	string EUserLookup="r*:s*;"
	IR2C_AddDataControls("Gels_Modeling","IR2H_ControlPanel","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,1)

	SetDrawLayer UserBack
	SetDrawEnv fname= "Times New Roman",fsize= 22,fstyle= 3,textrgb= (0,0,52224)
	DrawText 20,22,"Analytical models input panel"
	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
	DrawLine 16,181,339,181
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 8,49,"Data input"
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 17,209,"Modeling input"
	SetDrawEnv fstyle= 1
	SetDrawEnv fsize= 12,fstyle= 1
	DrawText 69,441,"Limits for fitting "
	SetDrawEnv fsize= 10,fstyle= 1
	DrawText 10,575,"Fit using least square fitting ?"
	DrawLine 24,420,344,420
//	DrawLine 225,390,225,456
//	DrawLine 229,390,229,456
//	DrawPoly 113,225,1,1,{113,225,113,225}
	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
	DrawLine 16,585,339,585
	SetDrawEnv textrgb= (0,0,65280),fstyle= 1
	DrawText 5,615,"Results:"

	//Experimental data input
	CheckBox UseSlitSmearedData,pos={10,160},size={90,14},proc=IR2H_InputPanelCheckboxProc,title="Slit smeared? "
	CheckBox UseSlitSmearedData,variable= root:Packages:Gels_Modeling:UseSlitSmearedData, help={"Input data are slit smeared? Model will be smeared to follow."}
	SetVariable SlitLength,pos={100,160},size={140,16},proc=IR2H_PanelSetVarProc,title="Slit length", help={"Slit length for slit smeared data, set ot inf  if necessary"}
	SetVariable SlitLength,limits={0,Inf,0.01},variable= root:Packages:Gels_Modeling:SlitLength, disable=!(root:Packages:Gels_Modeling:UseSlitSmearedData)

	Button DrawGraphs,pos={260,158},size={80,20},font="Times New Roman",fSize=10,proc=IR2H_InputPanelButtonProc,title="Graph", help={"Click to generate data graphs, necessary step for further evaluation"}

	//Modeling input, common for all distributions
	Button GraphDistribution,pos={32,217},size={50,20},font="Times New Roman",fSize=10,proc=IR2H_InputPanelButtonProc,title="Graph", help={"Graph manually. Used if UpdateAutomatically is not selected."}
	CheckBox UpdateAutomatically,pos={200,190},size={225,14},proc=IR2H_InputPanelCheckboxProc,title="Update graphs automatically?"
	CheckBox UpdateAutomatically,variable= root:Packages:Gels_Modeling:UpdateAutomatically, help={"Graph automatically anytime distribution parameters are changed. May be slow..."}

	Button DoFitting,pos={170,560},size={70,20},font="Times New Roman",fSize=10,proc=IR2H_InputPanelButtonProc,title="Fit", help={"Click to start least square fitting. Make sure the fitting coefficients are well guessed and limited."}
	Button RevertFitting,pos={255,560},size={100,20},font="Times New Roman",fSize=10,proc=IR2H_InputPanelButtonProc,title="Revert fit", help={"Return values before last fit attempmt. Use to recover from unsuccesfull fit."}

	Button ResultsToGraph,pos={80,590},size={100,20},font="Times New Roman",fSize=10,proc=IR2H_InputPanelButtonProc,title="Results to graph", help={"Paste results into the graph...."}
	Button ResultsToNotebook,pos={200,590},size={140,20},font="Times New Roman",fSize=10,proc=IR2H_InputPanelButtonProc,title="Results to Notebook", help={"Paste results into the notebook"}

	Button CopyToFolder,pos={80,620},size={100,20},font="Times New Roman",fSize=10,proc=IR2H_InputPanelButtonProc,title="Store in Data Folder", help={"Copy results back to data folder for future use."}
	Button ExportData,pos={200,620},size={100,20},font="Times New Roman",fSize=10,proc=IR2H_InputPanelButtonProc,title="Export ASCII", help={"Export ASCII data out from Igor."}

	SetVariable SASBackground,pos={13,539},size={150,16},proc=IR2H_PanelSetVarProc,title="SAS Background", help={"Background of SAS"}
	SetVariable SASBackground,limits={-inf,Inf,root:Packages:Gels_Modeling:SASBackgroundStep},variable= root:Packages:Gels_Modeling:SASBackground
	SetVariable SASBackgroundStep,pos={173,539},size={80,16},title="step",proc=IR2H_PanelSetVarProc, help={"Step for SAS background. Used to set appropriate steps for clicking background up and down."}
	SetVariable SASBackgroundStep,limits={0,Inf,0},value= root:Packages:Gels_Modeling:SASBackgroundStep
	CheckBox FitBackground,pos={273,536},size={63,14},proc=IR2H_InputPanelCheckboxProc,title="Fit Bckg?"
	CheckBox FitBackground,variable= root:Packages:Gels_Modeling:FitSASBackground, help={"Fit the background during least square fitting?"}

	//Dist Tabs definition
	TabControl DistTabs,pos={3,260},size={363,270},proc=IR2H_TabPanelControl
	TabControl DistTabs,fSize=10,tabLabel(0)="Unified", tabLabel(1)="Debye-Bueche",tabLabel(2)="Teubner-Strey",tabLabel(3)="Ciccar.-Bened."

	//unified level controls
	CheckBox UseLowQInDB,pos={40,290},size={79,14},proc=IR2H_InputPanelCheckboxProc,title="Use Unified?"
	CheckBox UseLowQInDB,variable= root:Packages:Gels_Modeling:UseLowQInDB, help={"Use one level unified model data?"}

	SetVariable LowQRgPrefactor,pos={30,310},size={180,16},title="G       ",proc=IR2H_PanelSetVarProc, disable=!(root:Packages:Gels_Modeling:UseLowQInDB)
	SetVariable LowQRgPrefactor,limits={0,inf,1},value= root:Packages:Gels_Modeling:LowQRgPrefactor, help={"G for Unified level Rg"}
	SetVariable LowQRg,pos={30,330},size={180,16},title="Rg     ",proc=IR2H_PanelSetVarProc, disable=!(root:Packages:Gels_Modeling:UseLowQInDB)
	SetVariable LowQRg,limits={0,inf,1},value= root:Packages:Gels_Modeling:LowQRg, help={"Rg for Unified level"}	
	SetVariable LowQPrefactor,pos={30,350},size={180,16},title="B       ",proc=IR2H_PanelSetVarProc, disable=!(root:Packages:Gels_Modeling:UseLowQInDB)
	SetVariable LowQPrefactor,limits={0,inf,1},value= root:Packages:Gels_Modeling:LowQPrefactor, help={"Prefactor for low-Q power law slope"}
	SetVariable LowQslope,pos={30,370},size={180,16},title="P        ",proc=IR2H_PanelSetVarProc, disable=!(root:Packages:Gels_Modeling:UseLowQInDB)
	SetVariable LowQslope,limits={0,5,0.1},value= root:Packages:Gels_Modeling:LowQslope, help={"Power law slope of low-Q region"}
	Button EstimateLowQ,pos={250,348},size={100,20},font="Times New Roman",fSize=10,proc=IR2H_InputPanelButtonProc
	Button EstimateLowQ, title="Estimate slope", help={"Fit power law to estimate slope of low q region"}, disable=!(root:Packages:Gels_Modeling:UseLowQInDB)
	
	SetVariable LowQRgPrefactorLowLimit,pos={32,450},size={50,16},title=" ", help={"Low fitting limit for G"}
	SetVariable LowQRgPrefactorLowLimit,limits={0,Inf,0},variable= root:Packages:Gels_Modeling:LowQRgPrefactorLowLimit,disable=!(root:Packages:Gels_Modeling:UseLowQInDB)
	SetVariable LowQRgPrefactorHighLimit,pos={98,450},size={130,16},title=" <        G       < ", help={"High fitting limit for G"}
	SetVariable LowQRgPrefactorHighLimit,limits={0,Inf,0},variable= root:Packages:Gels_Modeling:LowQRgPrefactorHighLimit,disable=!(root:Packages:Gels_Modeling:UseLowQInDB)
	CheckBox FitLowQRgPrefactor,pos={250,450},size={65,14},proc=IR2H_InputPanelCheckboxProc,title="Fit G?",disable=!(root:Packages:Gels_Modeling:UseLowQInDB)
	CheckBox FitLowQRgPrefactor,variable= root:Packages:Gels_Modeling:FitLowQRgPrefactor, help={"Fit? If selected, fitting limits appear, please set correct numbers..."}

	SetVariable LowQRgLowLimit,pos={32,470},size={50,16},title=" ", help={"Low fitting limit for Rg"}
	SetVariable LowQRgLowLimit,limits={0,Inf,0},variable= root:Packages:Gels_Modeling:LowQRgLowLimit,disable=!(root:Packages:Gels_Modeling:UseLowQInDB)
	SetVariable LowQRgHighLimit,pos={98,470},size={130,16},title=" <        P       < ", help={"High fitting limit for Rg"}
	SetVariable LowQRgHighLimit,limits={0,Inf,0},variable= root:Packages:Gels_Modeling:LowQRgHighLimit,disable=!(root:Packages:Gels_Modeling:UseLowQInDB)
	CheckBox FitLowQRg,pos={250,470},size={65,14},proc=IR2H_InputPanelCheckboxProc,title="Fit Rg?",disable=!(root:Packages:Gels_Modeling:UseLowQInDB)
	CheckBox FitLowQRg,variable= root:Packages:Gels_Modeling:FitLowQRg, help={"Fit? If selected, fitting limits appear, please set correct numbers..."}

	SetVariable LowQPrefactorLowLimit,pos={32,490},size={50,16},title=" ", help={"Low fitting limit for power law slope prefactor"}
	SetVariable LowQPrefactorLowLimit,limits={0,Inf,0},variable= root:Packages:Gels_Modeling:LowQPrefactorLowLimit,disable=!(root:Packages:Gels_Modeling:UseLowQInDB)
	SetVariable LowQPrefactorHighLimit,pos={98,490},size={130,16},title=" <        B       < ", help={"High fitting limit for power law prefactor"}
	SetVariable LowQPrefactorHighLimit,limits={0,Inf,0},variable= root:Packages:Gels_Modeling:LowQPrefactorHighLimit,disable=!(root:Packages:Gels_Modeling:UseLowQInDB)
	CheckBox FitLowQPrefactor,pos={250,490},size={65,14},proc=IR2H_InputPanelCheckboxProc,title="Fit B?",disable=!(root:Packages:Gels_Modeling:UseLowQInDB)
	CheckBox FitLowQPrefactor,variable= root:Packages:Gels_Modeling:FitLowQPrefactor, help={"Fit? If selected, fitting limits appear, please set correct numbers..."}

	SetVariable LowQslopeLowLimit,pos={32,510},size={50,16},title=" ", help={"Low fitting limit for low-Q power law slope "}
	SetVariable LowQslopeLowLimit,limits={0,Inf,0},variable= root:Packages:Gels_Modeling:LowQslopeLowLimit,disable=!(root:Packages:Gels_Modeling:UseLowQInDB)
	SetVariable LowQslopeHighLimit,pos={98,510},size={130,16},title=" <        P        < ", help={"High fitting limit for low-q power law slope"}
	SetVariable LowQslopeHighLimit,limits={0,Inf,0},variable= root:Packages:Gels_Modeling:LowQslopeHighLimit,disable=!(root:Packages:Gels_Modeling:UseLowQInDB)
	CheckBox FitLowQslope,pos={250,510},size={65,14},proc=IR2H_InputPanelCheckboxProc,title="Fit P?",disable=!(root:Packages:Gels_Modeling:UseLowQInDB)
	CheckBox FitLowQslope,variable= root:Packages:Gels_Modeling:FitLowQslope, help={"Fit? If selected, fitting limits appear, please set correct numbers..."}
	//**************************************	
	//Debye-Bueche controls
	CheckBox UseDB,pos={40,290},size={79,14},proc=IR2H_InputPanelCheckboxProc,title="Use Debye-Bueche?"
	CheckBox UseDB,variable= root:Packages:Gels_Modeling:UseDB, help={"Use Debye-Bueche model?"}
	SetVariable DBEta,pos={30,310},size={180,16},proc=IR2H_PanelSetVarProc,title="Eta :                 "
	SetVariable DBEta,limits={0,inf,0.03},value= root:Packages:Gels_Modeling:DBEta, help={"Eta "}
	SetVariable DBcorrL,pos={30,330},size={180,16},title="corrLength       ",proc=IR2H_PanelSetVarProc
	SetVariable DBcorrL,limits={0,inf,1},value= root:Packages:Gels_Modeling:DBcorrL, help={"Corelaton length."}


	SetVariable DBWavelength,pos={30,360},size={150,16},title="Wavelength     ",proc=IR2H_PanelSetVarProc
	SetVariable DBWavelength,limits={0,20,1},value= root:Packages:Gels_Modeling:DBWavelength, help={"Wavelength in A"}

	Button EstimateCorrL,pos={250,310},size={100,20},font="Times New Roman",fSize=10,proc=IR2H_InputPanelButtonProc,title="Estimate corrL"
	Button EstimateCorrL, help={"Estimate corrL by linear fitting. Place cursors in the linearized DB plot to do fitting"}
	SetVariable DBEtaLowLimit,pos={32,455},size={50,16},title=" ", help={"Low fitting limit for the eta"}
	SetVariable DBEtaLowLimit,limits={0,Inf,0},value= root:Packages:Gels_Modeling:DBEtaLowLimit
	SetVariable DBEtaHighLimit,pos={97,455},size={130,16},title="  < eta <          ", help={"High fitting limit for eta"}
	SetVariable DBEtaHighLimit,limits={0,Inf,0},value= root:Packages:Gels_Modeling:DBEtaHighLimit
	SetVariable DBcorrLLowLimit,pos={32,475},size={50,16},title=" ", help={"Low fitting limit for corrL"}
	SetVariable DBcorrLLowLimit,limits={0,Inf,0},value= root:Packages:Gels_Modeling:DBcorrLLowLimit
	SetVariable DBcorrLHighLimit,pos={98,475},size={130,16},title=" < corrL <       ", help={"High fitting limit for corrL"}
	SetVariable DBcorrLHighLimit,limits={0,Inf,0},value= root:Packages:Gels_Modeling:DBcorrLHighLimit
	CheckBox FitDBEta,pos={250,455},size={79,14},proc=IR2H_InputPanelCheckboxProc,title="Fit eta?"
	CheckBox FitDBEta,variable= root:Packages:Gels_Modeling:FitDBEta, help={"Fit? If selected, fitting limits appear, please set correct numbers..."}
	CheckBox FitDBcorrL,pos={250,475},size={65,14},proc=IR2H_InputPanelCheckboxProc,title="Fit corrL?"
	CheckBox FitDBcorrL,variable= root:Packages:Gels_Modeling:FitDBcorrL, help={"Fit? If selected, fitting limits appear, please set correct numbers..."}

	//**************************************	
	//Trebner-Strey
	CheckBox UseTS,pos={40,290},size={79,14},proc=IR2H_InputPanelCheckboxProc,title="Use Teubner-Strey?"
	CheckBox UseTS,variable= root:Packages:Gels_Modeling:UseTS, help={"Use Teubner-Strey model?"}

	SetVariable TSPrefactor,pos={30,310},size={180,16},title="TS prefactor ",proc=IR2H_PanelSetVarProc, disable=!(root:Packages:Gels_Modeling:UseTS)
	SetVariable TSPrefactor,limits={0,inf,1},value= root:Packages:Gels_Modeling:TSPrefactor, help={"Scaling factor for Treubner-Strey model"}
	SetVariable TSAvalue,pos={30,330},size={180,16},title="A param        ",proc=IR2H_PanelSetVarProc, disable=!(root:Packages:Gels_Modeling:UseTS)
	SetVariable TSAvalue,limits={0,inf,0.05},value= root:Packages:Gels_Modeling:TSAvalue, help={"Parameter A for the theory"}	
	SetVariable TSC1Value,pos={30,350},size={180,16},title="C1 param      ",proc=IR2H_PanelSetVarProc, disable=!(root:Packages:Gels_Modeling:UseTS)
	SetVariable TSC1Value,limits={0,inf,1},value= root:Packages:Gels_Modeling:TSC1Value, help={"Parameter C1 for the theory"}
	SetVariable TSC2Value,pos={30,370},size={180,16},title="C2 param      ",proc=IR2H_PanelSetVarProc, disable=!(root:Packages:Gels_Modeling:UseTS)
	SetVariable TSC2Value,limits={0,5,1},value= root:Packages:Gels_Modeling:TSC2Value, help={"Parameter C2 for the theory"}

	SetVariable TSCorrelationLength,pos={10,395},size={150,16},title="Corr. length [A]", noedit=1
	SetVariable TSCorrelationLength,value= root:Packages:Gels_Modeling:TSCorrelationLength, help={"Correlation length from parameters A, C1 and C2"}, limits={-inf,inf,0}

	SetVariable TSRepeatDistance,pos={190,395},size={150,16},title="Repeat dist. [A] ", noedit=1, limits={-inf,inf,0}
	SetVariable TSRepeatDistance,value= root:Packages:Gels_Modeling:TSRepeatDistance, help={"Repeat distance from parameters A, C1 and C2"}


	SetVariable TSPrefactorLowLimit,pos={32,450},size={50,16},title=" ", help={"Low fitting limit"}
	SetVariable TSPrefactorLowLimit,limits={0,Inf,0},variable= root:Packages:Gels_Modeling:TSPrefactorLowLimit,disable=!(root:Packages:Gels_Modeling:UseTS)
	SetVariable TSPrefactorHighLimit,pos={98,450},size={130,16},title=" <  Prefactor < ", help={"High fitting limit"}
	SetVariable TSPrefactorHighLimit,limits={0,Inf,0},variable= root:Packages:Gels_Modeling:TSPrefactorHighLimit,disable=!(root:Packages:Gels_Modeling:UseTS)
	CheckBox FitTSPrefactor,pos={250,450},size={65,14},proc=IR2H_InputPanelCheckboxProc,title="Fit?",disable=!(root:Packages:Gels_Modeling:UseTS)
	CheckBox FitTSPrefactor,variable= root:Packages:Gels_Modeling:FitTSPrefactor, help={"Fit? If selected, fitting limits appear, please set correct numbers..."}

	SetVariable TSAvalueLowLimit,pos={32,470},size={50,16},title=" ", help={"Low fitting limit"}
	SetVariable TSAvalueLowLimit,limits={0,Inf,0},variable= root:Packages:Gels_Modeling:TSAvalueLowLimit,disable=!(root:Packages:Gels_Modeling:UseTS)
	SetVariable TSAvalueHighLimit,pos={98,470},size={130,16},title=" <         A       < ", help={"High fitting limit"}
	SetVariable TSAvalueHighLimit,limits={0,Inf,0},variable= root:Packages:Gels_Modeling:TSAvalueHighLimit,disable=!(root:Packages:Gels_Modeling:UseTS)
	CheckBox FitTSAvalue,pos={250,470},size={65,14},proc=IR2H_InputPanelCheckboxProc,title="Fit?",disable=!(root:Packages:Gels_Modeling:UseTS)
	CheckBox FitTSAvalue,variable= root:Packages:Gels_Modeling:FitTSAvalue, help={"Fit? If selected, fitting limits appear, please set correct numbers..."}

	SetVariable TSC1ValueLowLimit,pos={32,490},size={50,16},title=" ", help={"Low fitting limit"}
	SetVariable TSC1ValueLowLimit,limits={0,Inf,0},variable= root:Packages:Gels_Modeling:TSC1ValueLowLimit,disable=!(root:Packages:Gels_Modeling:UseTS)
	SetVariable TSC1ValueHighLimit,pos={98,490},size={130,16},title=" <        C1      < ", help={"High fitting limit"}
	SetVariable TSC1ValueHighLimit,limits={0,Inf,0},variable= root:Packages:Gels_Modeling:TSC1ValueHighLimit,disable=!(root:Packages:Gels_Modeling:UseTS)
	CheckBox FitTSC1Value,pos={250,490},size={65,14},proc=IR2H_InputPanelCheckboxProc,title="Fit?",disable=!(root:Packages:Gels_Modeling:UseTS)
	CheckBox FitTSC1Value,variable= root:Packages:Gels_Modeling:FitTSC1Value, help={"Fit? If selected, fitting limits appear, please set correct numbers..."}

	SetVariable TSC2ValueLowLimit,pos={32,510},size={50,16},title=" ", help={"Low fitting limit "}
	SetVariable TSC2ValueLowLimit,limits={0,Inf,0},variable= root:Packages:Gels_Modeling:LowQslopeLowLimit,disable=!(root:Packages:Gels_Modeling:UseTS)
	SetVariable TSC2ValueHighLimit,pos={98,510},size={130,16},title=" <        C2      < ", help={"High fitting limit"}
	SetVariable TSC2ValueHighLimit,limits={0,Inf,0},variable= root:Packages:Gels_Modeling:TSC2ValueHighLimit,disable=!(root:Packages:Gels_Modeling:UseTS)
	CheckBox FitTSC2Value,pos={250,510},size={65,14},proc=IR2H_InputPanelCheckboxProc,title="Fit?",disable=!(root:Packages:Gels_Modeling:UseTS)
	CheckBox FitTSC2Value,variable= root:Packages:Gels_Modeling:FitTSC2Value, help={"Fit? If selected, fitting limits appear, please set correct numbers..."}

	//**************************************	
	//Modified Porod (Ciccariellos tool)
	CheckBox UseCiccBen,pos={40,290},size={79,14},proc=IR2H_InputPanelCheckboxProc,title="Use Ciccariello-Benedetti?"
	CheckBox UseCiccBen,variable= root:Packages:Gels_Modeling:UseCiccBen, help={"Use Coated Porous media tool by Ciccariello & Benedetti?"}


	SetVariable BC_PorodsSpecSurfArea,pos={10,310},size={310,16},title="Porod Surface Area [cm2/cm3]            ",proc=IR2H_PanelSetVarProc, disable=!(root:Packages:Gels_Modeling:UseCiccBen)
	SetVariable BC_PorodsSpecSurfArea,limits={0,inf,1},value= root:Packages:Gels_Modeling:BC_PorodsSpecSurfArea, help={"Specific area for Porod surface"}
	SetVariable BC_SolidScatLengthDensity,pos={10,330},size={150,16},title="Rho:  Solid",proc=IR2H_PanelSetVarProc, disable=!(root:Packages:Gels_Modeling:UseCiccBen)
	SetVariable BC_SolidScatLengthDensity,limits={0,inf,1},value= root:Packages:Gels_Modeling:BC_SolidScatLengthDensity, help={"Scattering length density for solid"}
	SetVariable BC_VoidScatLengthDensity,pos={170,330},size={180,16},title="Void/solv [10^10 cm^-2]",proc=IR2H_PanelSetVarProc, disable=!(root:Packages:Gels_Modeling:UseCiccBen)
	SetVariable BC_VoidScatLengthDensity,limits={0,inf,1},value= root:Packages:Gels_Modeling:BC_VoidScatLengthDensity, help={"Scattering length density for void/solvant"}

	SetVariable BC_LayerScatLengthDens,pos={30,376},size={280,16},title="Layer rho [10^10 cm^-2]  ",proc=IR2H_PanelSetVarProc, disable=!(root:Packages:Gels_Modeling:UseCiccBen)
	SetVariable BC_LayerScatLengthDens,limits={0,inf,1},value= root:Packages:Gels_Modeling:BC_LayerScatLengthDens, help={"Scattering length density for layer material"}
	SetVariable BC_CoatingsThickness,pos={30,398},size={280,16},title="Layer thickness [A]          ",proc=IR2H_PanelSetVarProc, disable=!(root:Packages:Gels_Modeling:UseCiccBen)
	SetVariable BC_CoatingsThickness,limits={0,inf,1},value= root:Packages:Gels_Modeling:BC_CoatingsThickness, help={"Thickness of the layer in A"}


	SetVariable BC_PorodsSpecSurfAreaLL,pos={12,450},size={50,16},title=" ", help={"Low fitting limit"}
	SetVariable BC_PorodsSpecSurfAreaLL,limits={0,Inf,0},variable= root:Packages:Gels_Modeling:BC_PorodsSpecSurfAreaLL,disable=!(root:Packages:Gels_Modeling:UseCiccBen)
	SetVariable BC_PorodsSpecSurfAreaHL,pos={68,450},size={160,16},title=" <  Porod Sfc Area < ", help={"High fitting limit"}
	SetVariable BC_PorodsSpecSurfAreaHL,limits={0,Inf,0},variable= root:Packages:Gels_Modeling:BC_PorodsSpecSurfAreaHL,disable=!(root:Packages:Gels_Modeling:UseCiccBen)
	CheckBox FitBC_PorodsSpecSurfArea,pos={250,450},size={65,14},proc=IR2H_InputPanelCheckboxProc,title="Fit?",disable=!(root:Packages:Gels_Modeling:UseCiccBen)
	CheckBox FitBC_PorodsSpecSurfArea,variable= root:Packages:Gels_Modeling:FitBC_PorodsSpecSurfArea, help={"Fit? If selected, fitting limits appear, please set correct numbers..."}

	SetVariable BC_LayerScatLengthDensLL,pos={12,470},size={50,16},title=" ", help={"Low fitting limit"}
	SetVariable BC_LayerScatLengthDensLL,limits={0,Inf,0},variable= root:Packages:Gels_Modeling:BC_LayerScatLengthDensLL,disable=!(root:Packages:Gels_Modeling:UseCiccBen)
	SetVariable BC_LayerScatLengthDensHL,pos={68,470},size={160,16},title=" <  Layer Rho        < ", help={"High fitting limit"}
	SetVariable BC_LayerScatLengthDensHL,limits={0,Inf,0},variable= root:Packages:Gels_Modeling:BC_LayerScatLengthDensHL,disable=!(root:Packages:Gels_Modeling:UseCiccBen)
	CheckBox FitBC_LayerScatLengthDens,pos={250,470},size={65,14},proc=IR2H_InputPanelCheckboxProc,title="Fit?",disable=!(root:Packages:Gels_Modeling:UseCiccBen)
	CheckBox FitBC_LayerScatLengthDens,variable= root:Packages:Gels_Modeling:FitBC_LayerScatLengthDens, help={"Fit? If selected, fitting limits appear, please set correct numbers..."}

	SetVariable BC_CoatingsThicknessLL,pos={12,490},size={50,16},title=" ", help={"Low fitting limit"}
	SetVariable BC_CoatingsThicknessLL,limits={0,Inf,0},variable= root:Packages:Gels_Modeling:BC_CoatingsThicknessLL,disable=!(root:Packages:Gels_Modeling:UseCiccBen)
	SetVariable BC_CoatingsThicknessHL,pos={68,490},size={160,16},title=" <  Layer Thick.     < ", help={"High fitting limit"}
	SetVariable BC_CoatingsThicknessHL,limits={0,Inf,0},variable= root:Packages:Gels_Modeling:BC_CoatingsThicknessHL,disable=!(root:Packages:Gels_Modeling:UseCiccBen)
	CheckBox FitBC_CoatingsThickness,pos={250,490},size={65,14},proc=IR2H_InputPanelCheckboxProc,title="Fit?",disable=!(root:Packages:Gels_Modeling:UseCiccBen)
	CheckBox FitBC_CoatingsThickness,variable= root:Packages:Gels_Modeling:FitBC_CoatingsThickness, help={"Fit? If selected, fitting limits appear, please set correct numbers..."}

	IR2H_TabPanelControl("",0)
end




//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2H_InputPanelCheckboxProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Gels_Modeling

	if (cmpstr(ctrlName,"UseIndra2Data")==0)
		//here we control the data structure checkbox
		NVAR UseIndra2Data=root:Packages:Gels_Modeling:UseIndra2Data
		NVAR UseQRSData=root:Packages:Gels_Modeling:UseQRSData
		UseIndra2Data=checked
		if (checked)
			UseQRSData=0
		endif
		Checkbox UseIndra2Data, value=UseIndra2Data
		Checkbox UseQRSData, value=UseQRSData
		SVAR Dtf=root:Packages:Gels_Modeling:DataFolderName
		SVAR IntDf=root:Packages:Gels_Modeling:IntensityWaveName
		SVAR QDf=root:Packages:Gels_Modeling:QWaveName
		SVAR EDf=root:Packages:Gels_Modeling:ErrorWaveName
			Dtf=" "
			IntDf=" "
			QDf=" "
			EDf=" "
			PopupMenu SelectDataFolder mode=1
			PopupMenu IntensityDataName   mode=1, value="---"
			PopupMenu QvecDataName    mode=1, value="---"
			PopupMenu ErrorDataName    mode=1, value="---"
	endif
	if (cmpstr(ctrlName,"UseQRSData")==0)
		//here we control the data structure checkbox
		NVAR UseQRSData=root:Packages:Gels_Modeling:UseQRSData
		NVAR UseIndra2Data=root:Packages:Gels_Modeling:UseIndra2Data
		UseQRSData=checked
		if (checked)
			UseIndra2Data=0
		endif
		Checkbox UseIndra2Data, value=UseIndra2Data
		Checkbox UseQRSData, value=UseQRSData
		SVAR Dtf=root:Packages:Gels_Modeling:DataFolderName
		SVAR IntDf=root:Packages:Gels_Modeling:IntensityWaveName
		SVAR QDf=root:Packages:Gels_Modeling:QWaveName
		SVAR EDf=root:Packages:Gels_Modeling:ErrorWaveName
			Dtf=" "
			IntDf=" "
			QDf=" "
			EDf=" "
			PopupMenu SelectDataFolder mode=1
			PopupMenu IntensityDataName   mode=1, value="---"
			PopupMenu QvecDataName    mode=1, value="---"
			PopupMenu ErrorDataName    mode=1, value="---"
	endif
	if (cmpstr(ctrlName,"UseSlitSmearedData")==0)
		//here we control the data structure checkbox
		NVAR UseSlitSmearedData=root:Packages:Gels_Modeling:UseSlitSmearedData
		SetVariable SlitLength disable=!(UseSlitSmearedData), win=IR2H_ControlPanel
		NVAR UseIndra2Data=root:Packages:Gels_Modeling:UseIndra2Data
		NVAR UseQRSData=root:Packages:Gels_Modeling:UseQRSData
		Checkbox UseIndra2Data, value=UseIndra2Data
		Checkbox UseQRSData, value=UseQRSData
		SVAR Dtf=root:Packages:Gels_Modeling:DataFolderName
		SVAR IntDf=root:Packages:Gels_Modeling:IntensityWaveName
		SVAR QDf=root:Packages:Gels_Modeling:QWaveName
		SVAR EDf=root:Packages:Gels_Modeling:ErrorWaveName
			Dtf=" "
			IntDf=" "
			QDf=" "
			EDf=" "
			PopupMenu SelectDataFolder mode=1
			PopupMenu IntensityDataName   mode=1, value="---"
			PopupMenu QvecDataName    mode=1, value="---"
			PopupMenu ErrorDataName    mode=1, value="---"
		PopupMenu SelectDataFolder,win=IR2H_ControlPanel, value= #"\"---;\"+IR1_GenStringOfFolders(root:Packages:Gels_Modeling:UseIndra2Data, root:Packages:Gels_Modeling:UseQRSData,root:Packages:Gels_Modeling:UseSlitSmearedData,0)"
		IR2H_AutoUpdateIfSelected()	
	endif

	if (cmpstr(ctrlName,"FitBackground")==0)
		//here we control the data structure checkbox
//		NVAR FitSASBackground=root:Packages:Gels_Modeling:FitSASBackground
//		FitSASBackground=checked
//		Checkbox FitBackground, value=FitSASBackground
	endif
	
	if (cmpstr(ctrlName,"UpdateAutomatically")==0)
		//here we control the data structure checkbox
	//	NVAR UpdateAutomatically=root:Packages:Gels_Modeling:UpdateAutomatically
	//	UpdateAutomatically=checked
	//	Checkbox UpdateAutomatically, value=UpdateAutomatically
		IR2H_AutoUpdateIfSelected()
	endif

	if (cmpstr(ctrlName,"UseLowQInDB")==0)
		NVAR UseLowQInDB=root:Packages:Gels_Modeling:UseLowQInDB
		IR2H_TabPanelControl("",0)
		IR2H_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"UseDB")==0)
		NVAR UseDB=root:Packages:Gels_Modeling:UseDB
		IR2H_TabPanelControl("",1)
		IR2H_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"UseTS")==0)
		NVAR UseTS=root:Packages:Gels_Modeling:UseTS
		IR2H_TabPanelControl("",2)
		IR2H_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"UseCiccBen")==0)
		NVAR UseTS=root:Packages:Gels_Modeling:UseTS
		IR2H_TabPanelControl("",3)
		IR2H_AutoUpdateIfSelected()
	endif
//
	
	DoWindow/F IR2H_ControlPanel
	setDataFolder oldDF

End


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2H_PanelPopupControl(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Gels_Modeling
		SVAR Dtf=root:Packages:Gels_Modeling:DataFolderName
		NVAR UseIndra2Data=root:Packages:Gels_Modeling:UseIndra2Data
		NVAR UseQRSData=root:Packages:Gels_Modeling:UseQRSdata
		SVAR IntDf=root:Packages:Gels_Modeling:IntensityWaveName
		SVAR QDf=root:Packages:Gels_Modeling:QWaveName
		SVAR EDf=root:Packages:Gels_Modeling:ErrorWaveName
		NVAR UseSlitSmearedData=root:Packages:Gels_Modeling:UseSlitSmearedData

	if (cmpstr(ctrlName,"SelectDataFolder")==0)
		//here we do what needs to be done when we select data folder
		Dtf=popStr
		PopupMenu IntensityDataName mode=1
		PopupMenu QvecDataName mode=1
		PopupMenu ErrorDataName mode=1
		if (UseIndra2Data)
			if(UseSlitSmearedData)
				if(stringmatch(IR1_ListOfWaves("SMR_Int","Gels_Modeling",0,0), "*M_SMR_Int*") &&stringmatch(IR1_ListOfWaves("SMR_Qvec","Gels_Modeling",0,0), "*M_SMR_Qvec*")  &&stringmatch(IR1_ListOfWaves("SMR_Error","Gels_Modeling",0,0), "*M_SMR_Error*") )			
					IntDf="M_SMR_Int"
					QDf="M_SMR_Qvec"
					EDf="M_SMR_Error"
					PopupMenu IntensityDataName value="M_SMR_Int;SMR_Int"
					PopupMenu QvecDataName value="M_SMR_Qvec;SMR_Qvec"
					PopupMenu ErrorDataName value="M_SMR_Error;SMR_Error"
				else
					if(!stringmatch(IR1_ListOfWaves("SMR_Int","Gels_Modeling",0,0), "*M_SMR_Int*") &&!stringmatch(IR1_ListOfWaves("SMR_Qvec","Gels_Modeling",0,0), "*M_SMR_Qvec*")  &&!stringmatch(IR1_ListOfWaves("SMR_Error","Gels_Modeling",0,0), "*M_SMR_Error*") )			
						IntDf="SMR_Int"
						QDf="SMR_Qvec"
						EDf="SMR_Error"
						PopupMenu IntensityDataName value="SMR_Int"
						PopupMenu QvecDataName value="SMR_Qvec"
						PopupMenu ErrorDataName value="SMR_Error"
					endif
				ENDIF
			else
				if(stringmatch(IR1_ListOfWaves("DSM_Int","Gels_Modeling",0,0), "*M_BKG_Int*") &&stringmatch(IR1_ListOfWaves("DSM_Qvec","Gels_Modeling",0,0), "*M_BKG_Qvec*")  &&stringmatch(IR1_ListOfWaves("DSM_Error","Gels_Modeling",0,0), "*M_BKG_Error*") )			
					IntDf="M_BKG_Int"
					QDf="M_BKG_Qvec"
					EDf="M_BKG_Error"
					PopupMenu IntensityDataName value="M_BKG_Int;M_DSM_Int;DSM_Int"
					PopupMenu QvecDataName value="M_BKG_Qvec;M_DSM_Qvec;DSM_Qvec"
					PopupMenu ErrorDataName value="M_BKG_Error;M_DSM_Error;DSM_Error"
				elseif(stringmatch(IR1_ListOfWaves("DSM_Int","Gels_Modeling",0,0), "*BKG_Int*") &&stringmatch(IR1_ListOfWaves("DSM_Qvec","Gels_Modeling",0,0), "*BKG_Qvec*")  &&stringmatch(IR1_ListOfWaves("DSM_Error","Gels_Modeling",0,0), "*BKG_Error*") )			
					IntDf="BKG_Int"
					QDf="BKG_Qvec"
					EDf="BKG_Error"
					PopupMenu IntensityDataName value="BKG_Int;DSM_Int"
					PopupMenu QvecDataName value="BKG_Qvec;DSM_Qvec"
					PopupMenu ErrorDataName value="BKG_Error;DSM_Error"
				elseif(stringmatch(IR1_ListOfWaves("DSM_Int","Gels_Modeling",0,0), "*M_DSM_Int*") &&stringmatch(IR1_ListOfWaves("DSM_Qvec","Gels_Modeling",0,0), "*M_DSM_Qvec*")  &&stringmatch(IR1_ListOfWaves("DSM_Error","Gels_Modeling",0,0), "*M_DSM_Error*") )			
					IntDf="M_DSM_Int"
					QDf="M_DSM_Qvec"
					EDf="M_DSM_Error"
					PopupMenu IntensityDataName value="M_DSM_Int;DSM_Int"
					PopupMenu QvecDataName value="M_DSM_Qvec;DSM_Qvec"
					PopupMenu ErrorDataName value="M_DSM_Error;DSM_Error"
				else
					if(!stringmatch(IR1_ListOfWaves("DSM_Int","Gels_Modeling",0,0), "*M_DSM_Int*") &&!stringmatch(IR1_ListOfWaves("DSM_Qvec","Gels_Modeling",0,0), "*M_DSM_Qvec*")  &&!stringmatch(IR1_ListOfWaves("DSM_Error","Gels_Modeling",0,0), "*M_DSM_Error*") )			
						IntDf="DSM_Int"
						QDf="DSM_Qvec"
						EDf="DSM_Error"
						PopupMenu IntensityDataName value="DSM_Int"
						PopupMenu QvecDataName value="DSM_Qvec"
						PopupMenu ErrorDataName value="DSM_Error"
					endif
				endif
			endif
		else
			IntDf=""
			QDf=""
			EDf=""
			PopupMenu IntensityDataName value="---"
			PopupMenu QvecDataName  value="---"
			PopupMenu ErrorDataName  value="---"
		endif
		if(UseQRSdata)
			IntDf=""
			QDf=""
			EDf=""
			PopupMenu IntensityDataName  value="---;"+IR1_ListOfWaves("DSM_Int","Gels_Modeling",0,0)
			PopupMenu QvecDataName  value="---;"+IR1_ListOfWaves("DSM_Qvec","Gels_Modeling",0,0)
			PopupMenu ErrorDataName  value="---;"+IR1_ListOfWaves("DSM_Error","Gels_Modeling",0,0)
		endif
		if(!UseQRSdata && !UseIndra2Data)
			IntDf=""
			QDf=""
			EDf=""
			PopupMenu IntensityDataName  value="---;"+IR1_ListOfWaves("DSM_Int","Gels_Modeling",0,0)
			PopupMenu QvecDataName  value="---;"+IR1_ListOfWaves("DSM_Qvec","Gels_Modeling",0,0)
			PopupMenu ErrorDataName  value="---;"+IR1_ListOfWaves("DSM_Error","Gels_Modeling",0,0)
		endif
		if (cmpstr(popStr,"---")==0)
			IntDf=""
			QDf=""
			EDf=""
			PopupMenu IntensityDataName  value="---"
			PopupMenu QvecDataName  value="---"
			PopupMenu ErrorDataName  value="---"
		endif
	endif
	

	if (cmpstr(ctrlName,"IntensityDataName")==0)
		if (cmpstr(popStr,"---")!=0)
			IntDf=popStr
			if (UseQRSData && strlen(QDf)==0 && strlen(EDf)==0)
				QDf="q"+popStr[1,inf]
				EDf="s"+popStr[1,inf]
				Execute ("PopupMenu QvecDataName mode=1, value=root:Packages:Gels_Modeling:QWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Qvec\",\"Gels_Modeling\",0,0)")
				Execute ("PopupMenu ErrorDataName mode=1, value=root:Packages:Gels_Modeling:ErrorWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Error\",\"Gels_Modeling\",0,0)")
			endif
		else
			IntDf=""	
		endif
	endif

	if (cmpstr(ctrlName,"QvecDataName")==0)
		//here goes what needs to be done, when we select this popup...
		if (cmpstr(popStr,"---")!=0)
			QDf=popStr
			if (UseQRSData && strlen(IntDf)==0 && strlen(EDf)==0)
				IntDf="r"+popStr[1,inf]
				EDf="s"+popStr[1,inf]
				Execute ("PopupMenu IntensityDataName mode=1, value=root:Packages:Gels_Modeling:IntensityWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Int\",\"Gels_Modeling\",0,0)")
				Execute ("PopupMenu ErrorDataName mode=1, value=root:Packages:Gels_Modeling:ErrorWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Error\",\"Gels_Modeling\",0,0)")
			endif
		else
			QDf=""
		endif
	endif
	
	if (cmpstr(ctrlName,"ErrorDataName")==0)
		//here goes what needs to be done, when we select this popup...
		if (cmpstr(popStr,"---")!=0)
			EDf=popStr
			if (UseQRSData && strlen(IntDf)==0 && strlen(QDf)==0)
				IntDf="r"+popStr[1,inf]
				QDf="q"+popStr[1,inf]
				Execute ("PopupMenu IntensityDataName mode=1, value=root:Packages:Gels_Modeling:IntensityWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Int\",\"Gels_Modeling\",0,0)")
				Execute ("PopupMenu QvecDataName mode=1, value=root:Packages:Gels_Modeling:QWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Qvec\",\"Gels_Modeling\",0,0)")
			endif
		else
			EDf=""
		endif
	endif
	
	if (cmpstr(ctrlName,"NumberOfDistributions")==0)
		//here goes what happens when we change number of distributions
		NVAR nmbdist=root:Packages:Gels_Modeling:NumberOfDistributions
		nmbdist=popNum-1
		IR2H_FixTabsInPanel()
		IR2H_AutoUpdateIfSelected()
		DoWindow IR2H_InterferencePanel
			if (V_Flag)
				DoWindow/F IR2H_InterferencePanel
	//			IR2H_TabPanelControlInterf("name",nmbdist-1)
			endif
	endif
	
	if (cmpstr(ctrlName,"Dis1_ShapePopup")==0)
		//here goes what happens when user selects shape in the panel
		//and that means, depending on the shape selected we need to get another panel with parameters
		//we have 3 universal shape parameters available for each shape type:
		//Dist1ScatShapeParam1;Dist1ScatShapeParam2;Dist1ScatShapeParam3
		IR2H_ResetScatShapeFitParam(1)		//Dist1ScatShapeParam1;Dist1ScatShapeParam2;Dist1ScatShapeParam3

				
		//kill spheroid window if exists...
		DoWindow Shape_Model_Input_Panel
		if (V_Flag)
			DoWindow/K Shape_Model_Input_Panel
		endif
		//create new window as needed
		if (cmpstr(popStr,"spheroid")==0 || cmpstr(popStr,"Algebraic_Globules")==0 || cmpstr(popStr,"Algebraic_Disks")==0 || cmpstr(popStr,"Integrated_Spheroid")==0)
			Execute ("Dis_Spheroid_Input_Panel(1)")
		endif
		if (cmpstr(popStr,"cylinder")==0 || cmpstr(popStr,"Algebraic_Rods")==0)
			Execute ("Dis_cylinder_Panel(1)")
		endif
		if (cmpstr(popStr,"tube")==0)
			Execute ("Dis_tube_Panel(1)")
		endif
		if (cmpstr(popStr,"CoreShell")==0)
			Execute ("Dis_CoreShell_Input_Panel(1)")
		endif
		if (cmpstr(popStr,"Fractal Aggregate")==0)
			Execute ("Dis_FractalAgg_Input_Panel(1)")
		endif
		
		SVAR Dist1ShapeModel=root:Packages:Gels_Modeling:Dist1ShapeModel
		Dist1ShapeModel=popstr
		//create and recalculate the distributions
		IR1_CreateDistributionWaves()
		IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
//		IR2H_UpdateModeMedianMean()		//modified for 5
		IR2H_AutoUpdateIfSelected()
	endif
	
	if (cmpstr(ctrlName,"Dis1_DistributionType")==0)
		//here goes what happens when user selects different dist type
		SVAR Dist1DistributionType=root:Packages:Gels_Modeling:Dist1DistributionType
		Dist1DistributionType=popStr
		NVAR Dist1FitShape=root:Packages:Gels_Modeling:Dist1FitShape
		NVAR Dist1FitLocation=root:Packages:Gels_Modeling:Dist1FitLocation
		NVAR Dist1FitScale=root:Packages:Gels_Modeling:Dist1FitScale
		if (cmpstr(popStr,"Gauss")==0)
			SetVariable Dis1_shape, disable=1, win=IR2H_ControlPanel
			SetVariable Dis1_ShapeStep, disable=1, win=IR2H_ControlPanel
			SetVariable Dis1_Scale, disable=0,title="Width        ", win=IR2H_ControlPanel
			SetVariable Dis1_Location, disable=0,title="Mean size", win=IR2H_ControlPanel
			SetVariable Dis1_ScaleStep, disable=0, win=IR2H_ControlPanel
			SetVariable Dis1_LocationStep, disable=0, win=IR2H_ControlPanel
			SetVariable Dis1_LocationLow,disable= (!Dist1FitLocation), win=IR2H_ControlPanel
			SetVariable Dis1_LocationHigh,disable= (!Dist1FitLocation),title="  < Mean size < ", win=IR2H_ControlPanel
			CheckBox Dis1_FitLocation,disable= 0,title="Fit mean size?", win=IR2H_ControlPanel
			SetVariable Dis1_ScaleLow,disable= (!Dist1FitScale), win=IR2H_ControlPanel
			SetVariable Dis1_ScaleHigh,disable=(!Dist1FitScale),title="  < Width <       ", win=IR2H_ControlPanel
			CheckBox Dis1_FitScale,disable= 0,title="Fit width?", win=IR2H_ControlPanel
			SetVariable Dis1_ShapeLow,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis1_ShapeHigh,disable= 1, win=IR2H_ControlPanel
			CheckBox Dis1_FitShape,disable= 1, win=IR2H_ControlPanel
			
			TitleBox 	Dis1_Gauss, disable=0
			TitleBox 	Dis1_LogNormal, disable=1
			TitleBox 	Dis1_LSW, disable=1
			TitleBox 	Dis1_PowerLaw, disable=1
			
			//Dist1FitScale = 0
			//Dist1FitLocation = 0
			Dist1FitShape = 0
		endif
		if (cmpstr(popStr,"LogNormal")==0)
			SetVariable Dis1_shape, disable=0,title="Sdeviation  ", win=IR2H_ControlPanel
			SetVariable Dis1_ShapeStep, disable=0, win=IR2H_ControlPanel
			SetVariable Dis1_Scale, disable=0,title="Mean size", win=IR2H_ControlPanel
			SetVariable Dis1_Location, disable=0,title="Min size  ", win=IR2H_ControlPanel
			SetVariable Dis1_ScaleStep, disable=0, win=IR2H_ControlPanel
			SetVariable Dis1_LocationStep, disable=0, win=IR2H_ControlPanel

			SetVariable Dis1_LocationLow,disable= (!Dist1FitLocation), win=IR2H_ControlPanel
 			SetVariable Dis1_LocationHigh,disable= (!Dist1FitLocation),title="  < Min. size <   ", win=IR2H_ControlPanel
			CheckBox Dis1_FitLocation,disable= 0,title="Fit min. size?", win=IR2H_ControlPanel
			SetVariable Dis1_ScaleLow,disable=(!Dist1FitScale), win=IR2H_ControlPanel
			SetVariable Dis1_ScaleHigh,disable= (!Dist1FitScale),title="  < Mean size < ", win=IR2H_ControlPanel
			CheckBox Dis1_FitScale,disable= 0,title="Fit mean size?", win=IR2H_ControlPanel
			SetVariable Dis1_ShapeLow,disable= (!Dist1FitShape), win=IR2H_ControlPanel
			SetVariable Dis1_ShapeHigh,disable=(!Dist1FitShape),title=" < Sdeviation < ", win=IR2H_ControlPanel
			CheckBox Dis1_FitShape,disable= 0,title="Fit Sdev.?", win=IR2H_ControlPanel

			TitleBox 	Dis1_Gauss, disable=1
			TitleBox 	Dis1_LogNormal, disable=0
			TitleBox 	Dis1_LSW, disable=1
			TitleBox 	Dis1_PowerLaw, disable=1
			//Dist1FitScale = 0
			//Dist1FitLocation = 0
			//Dist1FitShape = 0
		endif
		if (cmpstr(popStr,"LSW")==0)
			SetVariable Dis1_shape, disable=1, win=IR2H_ControlPanel
			SetVariable Dis1_ShapeStep, disable=1, win=IR2H_ControlPanel
			SetVariable Dis1_Scale, disable=1, win=IR2H_ControlPanel
			SetVariable Dis1_Location, disable=0,title="Location  ", win=IR2H_ControlPanel
			SetVariable Dis1_ScaleStep, disable=1, win=IR2H_ControlPanel
			SetVariable Dis1_LocationStep, disable=0, win=IR2H_ControlPanel
			
			SetVariable Dis1_LocationLow,disable= (!Dist1FitLocation), win=IR2H_ControlPanel
			SetVariable Dis1_LocationHigh,disable= (!Dist1FitLocation),title="  < location <     ", win=IR2H_ControlPanel
			CheckBox Dis1_FitLocation,disable= 0,title="Fit Location?", win=IR2H_ControlPanel
			SetVariable Dis1_ScaleLow,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis1_ScaleHigh,disable= 1, win=IR2H_ControlPanel
			CheckBox Dis1_FitScale,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis1_ShapeLow,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis1_ShapeHigh,disable= 1, win=IR2H_ControlPanel
			CheckBox Dis1_FitShape,disable= 1, win=IR2H_ControlPanel

			TitleBox 	Dis1_Gauss, disable=1
			TitleBox 	Dis1_LogNormal, disable=1
			TitleBox 	Dis1_LSW, disable=0
			TitleBox 	Dis1_PowerLaw, disable=1

			Dist1FitScale = 0
			//Dist1FitLocation = 0
			Dist1FitShape = 0
		endif
		if (cmpstr(popStr,"PowerLaw")==0)
			SetVariable Dis1_shape, disable=0,title="Power slope   ", win=IR2H_ControlPanel
			SetVariable Dis1_ShapeStep, disable=0, win=IR2H_ControlPanel
			SetVariable Dis1_Scale, disable=0,title="Minimum Dia   ", win=IR2H_ControlPanel
			SetVariable Dis1_Location, disable=0,title="Maximum Dia  ", win=IR2H_ControlPanel
			SetVariable Dis1_ScaleStep, disable=1, win=IR2H_ControlPanel
			SetVariable Dis1_LocationStep, disable=1, win=IR2H_ControlPanel
			
			SetVariable Dis1_LocationLow,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis1_LocationHigh,disable= 1, win=IR2H_ControlPanel
			CheckBox Dis1_FitLocation,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis1_ScaleLow,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis1_ScaleHigh,disable= 1, win=IR2H_ControlPanel
			CheckBox Dis1_FitScale,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis1_ShapeLow,disable= 0, win=IR2H_ControlPanel
			SetVariable Dis1_ShapeHigh,disable= 0,title=" < slope < ", win=IR2H_ControlPanel
			CheckBox Dis1_FitShape,disable= 0,title="Fit slope?", win=IR2H_ControlPanel

			TitleBox 	Dis1_Gauss, disable=1
			TitleBox 	Dis1_LogNormal, disable=1
			TitleBox 	Dis1_LSW, disable=1
			TitleBox 	Dis1_PowerLaw, disable=0
			Dist1FitScale = 0
			Dist1FitLocation = 0
			//Dist1FitShape = 0
		endif
		//create and recalculate the distributions
		IR1_CreateDistributionWaves()
		IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
//		IR2H_UpdateModeMedianMean()		//modified for 5
		IR2H_AutoUpdateIfSelected()
	endif


	if (cmpstr(ctrlName,"Dis2_ShapePopup")==0)
		//here goes what happens when user selects shape in the panel
		//and that means, depending on the shape selected we need to get another panel with parameters
		//we have 3 universal shape parameters available for each shape type:
		//Dist2ScatShapeParam1;Dist2ScatShapeParam2;Dist2ScatShapeParam3
		IR2H_ResetScatShapeFitParam(2)		//Dist1ScatShapeParam1;Dist1ScatShapeParam2;Dist1ScatShapeParam3
		
		//kill shpheroid window if exists...
		DoWindow Shape_Model_Input_Panel
		if (V_Flag)
			DoWindow/K Shape_Model_Input_Panel
		endif
		//create new window as needed
		if (cmpstr(popStr,"spheroid")==0 || cmpstr(popStr,"Algebraic_Globules")==0 || cmpstr(popStr,"Algebraic_Disks")==0 || cmpstr(popStr,"Integrated_Spheroid")==0)
			Execute ("Dis_Spheroid_Input_Panel(2)")
		endif
		if (cmpstr(popStr,"cylinder")==0 || cmpstr(popStr,"Algebraic_Rods")==0)
			Execute ("Dis_cylinder_Panel(2)")
		endif
		if (cmpstr(popStr,"tube")==0)
			Execute ("Dis_tube_Panel(2)")
		endif
		if (cmpstr(popStr,"CoreShell")==0)
			Execute ("Dis_CoreShell_Input_Panel(2)")
		endif
		if (cmpstr(popStr,"Fractal Aggregate")==0)
			Execute ("Dis_FractalAgg_Input_Panel(2)")
		endif
		SVAR Dist2ShapeModel=root:Packages:Gels_Modeling:Dist2ShapeModel
		Dist2ShapeModel=popStr
		//create and recalculate the distributions
		IR1_CreateDistributionWaves()
		IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
	//	IR2H_UpdateModeMedianMean()		//modified for 5
		IR2H_AutoUpdateIfSelected()
	endif
	
	if (cmpstr(ctrlName,"Dis2_DistributionType")==0)
		//here goes what happens when user selects different dist type
		SVAR Dist2DistributionType=root:Packages:Gels_Modeling:Dist2DistributionType
		NVAR Dist2FitShape=root:Packages:Gels_Modeling:Dist2FitShape
		NVAR Dist2FitLocation=root:Packages:Gels_Modeling:Dist2FitLocation
		NVAR Dist2FitScale=root:Packages:Gels_Modeling:Dist2FitScale
		Dist2DistributionType=popStr
		if (cmpstr(popStr,"Gauss")==0)
			SetVariable Dis2_shape, disable=1, win=IR2H_ControlPanel
			SetVariable Dis2_ShapeStep, disable=1, win=IR2H_ControlPanel
			SetVariable Dis2_Scale, disable=0,title="Width        ", win=IR2H_ControlPanel
			SetVariable Dis2_Location, disable=0,title="Mean size", win=IR2H_ControlPanel
			SetVariable Dis2_ScaleStep, disable=0, win=IR2H_ControlPanel
			SetVariable Dis2_LocationStep, disable=0, win=IR2H_ControlPanel
			SetVariable Dis2_LocationLow,disable= (!Dist2FitLocation), win=IR2H_ControlPanel
			SetVariable Dis2_LocationHigh,disable= (!Dist2FitLocation),title="  < Mean size < ", win=IR2H_ControlPanel
			CheckBox Dis2_FitLocation,disable= 0,title="Fit mean size?", win=IR2H_ControlPanel
			SetVariable Dis2_ScaleLow,disable= (!Dist2FitScale), win=IR2H_ControlPanel
			SetVariable Dis2_ScaleHigh,disable=(!Dist2FitScale),title="  < Width <       ", win=IR2H_ControlPanel
			CheckBox Dis2_FitScale,disable= 0,title="Fit width?", win=IR2H_ControlPanel
			SetVariable Dis2_ShapeLow,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis2_ShapeHigh,disable= 1, win=IR2H_ControlPanel
			CheckBox Dis2_FitShape,disable= 1, win=IR2H_ControlPanel
			
			TitleBox 	Dis2_Gauss, disable=0
			TitleBox 	Dis2_LogNormal, disable=1
			TitleBox 	Dis2_LSW, disable=1
			TitleBox 	Dis2_PowerLaw, disable=1
			
			//Dist2FitScale = 0
			//Dist2FitLocation = 0
			Dist2FitShape = 0
		endif
		if (cmpstr(popStr,"LogNormal")==0)
			SetVariable Dis2_shape, disable=0,title="Sdeviation  ", win=IR2H_ControlPanel
			SetVariable Dis2_ShapeStep, disable=0, win=IR2H_ControlPanel
			SetVariable Dis2_Scale, disable=0,title="Mean size", win=IR2H_ControlPanel
			SetVariable Dis2_Location, disable=0,title="Min size  ", win=IR2H_ControlPanel
			SetVariable Dis2_ScaleStep, disable=0, win=IR2H_ControlPanel
			SetVariable Dis2_LocationStep, disable=0, win=IR2H_ControlPanel

			SetVariable Dis2_LocationLow,disable= (!Dist2FitLocation), win=IR2H_ControlPanel
 			SetVariable Dis2_LocationHigh,disable= (!Dist2FitLocation),title="  < Min. size <   ", win=IR2H_ControlPanel
			CheckBox Dis2_FitLocation,disable= 0,title="Fit min. size?", win=IR2H_ControlPanel
			SetVariable Dis2_ScaleLow,disable=(!Dist2FitScale), win=IR2H_ControlPanel
			SetVariable Dis2_ScaleHigh,disable= (!Dist2FitScale),title="  < Mean size < ", win=IR2H_ControlPanel
			CheckBox Dis2_FitScale,disable= 0,title="Fit mean size?", win=IR2H_ControlPanel
			SetVariable Dis2_ShapeLow,disable= (!Dist2FitShape), win=IR2H_ControlPanel
			SetVariable Dis2_ShapeHigh,disable=(!Dist2FitShape),title=" < Sdeviation < ", win=IR2H_ControlPanel
			CheckBox Dis2_FitShape,disable= 0,title="Fit Sdev.?", win=IR2H_ControlPanel

			TitleBox 	Dis2_Gauss, disable=1
			TitleBox 	Dis2_LogNormal, disable=0
			TitleBox 	Dis2_LSW, disable=1
			TitleBox 	Dis2_PowerLaw, disable=1
			//Dist2FitScale = 0
			//Dist2FitLocation = 0
			//Dist2FitShape = 0
		endif
		if (cmpstr(popStr,"LSW")==0)
			SetVariable Dis2_shape, disable=1, win=IR2H_ControlPanel
			SetVariable Dis2_ShapeStep, disable=1, win=IR2H_ControlPanel
			SetVariable Dis2_Scale, disable=1, win=IR2H_ControlPanel
			SetVariable Dis2_Location, disable=0,title="Location  ", win=IR2H_ControlPanel
			SetVariable Dis2_ScaleStep, disable=1, win=IR2H_ControlPanel
			SetVariable Dis2_LocationStep, disable=0, win=IR2H_ControlPanel
			
			SetVariable Dis2_LocationLow,disable= (!Dist2FitLocation), win=IR2H_ControlPanel
			SetVariable Dis2_LocationHigh,disable= (!Dist2FitLocation),title="  < location <     ", win=IR2H_ControlPanel
			CheckBox Dis2_FitLocation,disable= 0,title="Fit Location?", win=IR2H_ControlPanel
			SetVariable Dis2_ScaleLow,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis2_ScaleHigh,disable= 1, win=IR2H_ControlPanel
			CheckBox Dis2_FitScale,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis2_ShapeLow,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis2_ShapeHigh,disable= 1, win=IR2H_ControlPanel
			CheckBox Dis2_FitShape,disable= 1, win=IR2H_ControlPanel

			TitleBox 	Dis2_Gauss, disable=1
			TitleBox 	Dis2_LogNormal, disable=1
			TitleBox 	Dis2_LSW, disable=0
			TitleBox 	Dis2_PowerLaw, disable=1

			Dist2FitScale = 0
			//Dist2FitLocation = 0
			Dist2FitShape = 0
		endif
		if (cmpstr(popStr,"PowerLaw")==0)
			SetVariable Dis2_shape, disable=0,title="Power slope   ", win=IR2H_ControlPanel
			SetVariable Dis2_ShapeStep, disable=0, win=IR2H_ControlPanel
			SetVariable Dis2_Scale, disable=0,title="Minimum Dia   ", win=IR2H_ControlPanel
			SetVariable Dis2_Location, disable=0,title="Maximum Dia  ", win=IR2H_ControlPanel
			SetVariable Dis2_ScaleStep, disable=1, win=IR2H_ControlPanel
			SetVariable Dis2_LocationStep, disable=1, win=IR2H_ControlPanel
			
			SetVariable Dis2_LocationLow,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis2_LocationHigh,disable= 1, win=IR2H_ControlPanel
			CheckBox Dis2_FitLocation,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis2_ScaleLow,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis2_ScaleHigh,disable= 1, win=IR2H_ControlPanel
			CheckBox Dis2_FitScale,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis2_ShapeLow,disable= 0, win=IR2H_ControlPanel
			SetVariable Dis2_ShapeHigh,disable= 0,title=" < slope < ", win=IR2H_ControlPanel
			CheckBox Dis2_FitShape,disable= 0,title="Fit slope?", win=IR2H_ControlPanel

			TitleBox 	Dis2_Gauss, disable=1
			TitleBox 	Dis2_LogNormal, disable=1
			TitleBox 	Dis2_LSW, disable=1
			TitleBox 	Dis2_PowerLaw, disable=0
			Dist2FitScale = 0
			Dist2FitLocation = 0
			//Dist2FitShape = 0
		endif
		//create and recalculate the distributions
		IR1_CreateDistributionWaves()
		IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
//		IR2H_UpdateModeMedianMean()		//modified for 5
		IR2H_AutoUpdateIfSelected()
	endif


	if (cmpstr(ctrlName,"Dis3_ShapePopup")==0)
		//here goes what happens when user selects shape in the panel
		//and that means, depending on the shape selected we need to get another panel with parameters
		//we have 3 universal shape parameters available for each shape type:
		//Dist3ScatShapeParam1;Dist3ScatShapeParam2;Dist3ScatShapeParam3
		IR2H_ResetScatShapeFitParam(3)		//Dist1ScatShapeParam1;Dist1ScatShapeParam2;Dist1ScatShapeParam3
		
		//kill shpheroid window if exists...
		DoWindow Shape_Model_Input_Panel
		if (V_Flag)
			DoWindow/K Shape_Model_Input_Panel
		endif
		//create new window as needed
		if (cmpstr(popStr,"spheroid")==0 || cmpstr(popStr,"Algebraic_Globules")==0 || cmpstr(popStr,"Algebraic_Disks")==0 || cmpstr(popStr,"Integrated_Spheroid")==0)
			Execute ("Dis_Spheroid_Input_Panel(3)")
		endif
		if (cmpstr(popStr,"cylinder")==0 || cmpstr(popStr,"Algebraic_Rods")==0)
			Execute ("Dis_cylinder_Panel(3)")
		endif
		if (cmpstr(popStr,"tube")==0)
			Execute ("Dis_tube_Panel(3)")
		endif
		if (cmpstr(popStr,"CoreShell")==0)
			Execute ("Dis_CoreShell_Input_Panel(3)")
		endif
		if (cmpstr(popStr,"Fractal Aggregate")==0)
			Execute ("Dis_FractalAgg_Input_Panel(3)")
		endif
		SVAR Dist3ShapeModel=root:Packages:Gels_Modeling:Dist3ShapeModel
		Dist3ShapeModel=popStr
		//create and recalculate the distributions
		IR1_CreateDistributionWaves()
		IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
//		IR2H_UpdateModeMedianMean()		//modified for 5

		IR2H_AutoUpdateIfSelected()
	endif
	
	if (cmpstr(ctrlName,"Dis3_DistributionType")==0)
		//here goes what happens when user selects different dist type
		SVAR Dist3DistributionType=root:Packages:Gels_Modeling:Dist3DistributionType
		NVAR Dist3FitShape=root:Packages:Gels_Modeling:Dist3FitShape
		NVAR Dist3FitLocation=root:Packages:Gels_Modeling:Dist3FitLocation
		NVAR Dist3FitScale=root:Packages:Gels_Modeling:Dist3FitScale
		Dist3DistributionType=popStr
		if (cmpstr(popStr,"Gauss")==0)
			SetVariable Dis3_shape, disable=1, win=IR2H_ControlPanel
			SetVariable Dis3_ShapeStep, disable=1, win=IR2H_ControlPanel
			SetVariable Dis3_Scale, disable=0,title="Width        ", win=IR2H_ControlPanel
			SetVariable Dis3_Location, disable=0,title="Mean size", win=IR2H_ControlPanel
			SetVariable Dis3_ScaleStep, disable=0, win=IR2H_ControlPanel
			SetVariable Dis3_LocationStep, disable=0, win=IR2H_ControlPanel
			SetVariable Dis3_LocationLow,disable= (!Dist3FitLocation), win=IR2H_ControlPanel
			SetVariable Dis3_LocationHigh,disable= (!Dist3FitLocation),title="  < Mean size < ", win=IR2H_ControlPanel
			CheckBox Dis3_FitLocation,disable= 0,title="Fit mean size?", win=IR2H_ControlPanel
			SetVariable Dis3_ScaleLow,disable= (!Dist3FitScale), win=IR2H_ControlPanel
			SetVariable Dis3_ScaleHigh,disable=(!Dist3FitScale),title="  < Width <       ", win=IR2H_ControlPanel
			CheckBox Dis3_FitScale,disable= 0,title="Fit width?", win=IR2H_ControlPanel
			SetVariable Dis3_ShapeLow,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis3_ShapeHigh,disable= 1, win=IR2H_ControlPanel
			CheckBox Dis3_FitShape,disable= 1, win=IR2H_ControlPanel
			
			TitleBox 	Dis3_Gauss, disable=0
			TitleBox 	Dis3_LogNormal, disable=1
			TitleBox 	Dis3_LSW, disable=1
			TitleBox 	Dis3_PowerLaw, disable=1
			
			//Dist3FitScale = 0
			//Dist3FitLocation = 0
			Dist3FitShape = 0
		endif
		if (cmpstr(popStr,"LogNormal")==0)
			SetVariable Dis3_shape, disable=0,title="Sdeviation  ", win=IR2H_ControlPanel
			SetVariable Dis3_ShapeStep, disable=0, win=IR2H_ControlPanel
			SetVariable Dis3_Scale, disable=0,title="Mean size", win=IR2H_ControlPanel
			SetVariable Dis3_Location, disable=0,title="Min size  ", win=IR2H_ControlPanel
			SetVariable Dis3_ScaleStep, disable=0, win=IR2H_ControlPanel
			SetVariable Dis3_LocationStep, disable=0, win=IR2H_ControlPanel

			SetVariable Dis3_LocationLow,disable= (!Dist3FitLocation), win=IR2H_ControlPanel
 			SetVariable Dis3_LocationHigh,disable= (!Dist3FitLocation),title="  < Min. size <   ", win=IR2H_ControlPanel
			CheckBox Dis3_FitLocation,disable= 0,title="Fit min. size?", win=IR2H_ControlPanel
			SetVariable Dis3_ScaleLow,disable=(!Dist3FitScale), win=IR2H_ControlPanel
			SetVariable Dis3_ScaleHigh,disable= (!Dist3FitScale),title="  < Mean size < ", win=IR2H_ControlPanel
			CheckBox Dis3_FitScale,disable= 0,title="Fit mean size?", win=IR2H_ControlPanel
			SetVariable Dis3_ShapeLow,disable= (!Dist3FitShape), win=IR2H_ControlPanel
			SetVariable Dis3_ShapeHigh,disable=(!Dist3FitShape),title=" < Sdeviation < ", win=IR2H_ControlPanel
			CheckBox Dis3_FitShape,disable= 0,title="Fit Sdev.?", win=IR2H_ControlPanel

			TitleBox 	Dis3_Gauss, disable=1
			TitleBox 	Dis3_LogNormal, disable=0
			TitleBox 	Dis3_LSW, disable=1
			TitleBox 	Dis3_PowerLaw, disable=1
			//Dist3FitScale = 0
			//Dist3FitLocation = 0
			//Dist3FitShape = 0
		endif
		if (cmpstr(popStr,"LSW")==0)
			SetVariable Dis3_shape, disable=1, win=IR2H_ControlPanel
			SetVariable Dis3_ShapeStep, disable=1, win=IR2H_ControlPanel
			SetVariable Dis3_Scale, disable=1, win=IR2H_ControlPanel
			SetVariable Dis3_Location, disable=0,title="Location  ", win=IR2H_ControlPanel
			SetVariable Dis3_ScaleStep, disable=1, win=IR2H_ControlPanel
			SetVariable Dis3_LocationStep, disable=0, win=IR2H_ControlPanel
			
			SetVariable Dis3_LocationLow,disable= (!Dist3FitLocation), win=IR2H_ControlPanel
			SetVariable Dis3_LocationHigh,disable= (!Dist3FitLocation),title="  < location <     ", win=IR2H_ControlPanel
			CheckBox Dis3_FitLocation,disable= 0,title="Fit Location?", win=IR2H_ControlPanel
			SetVariable Dis3_ScaleLow,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis3_ScaleHigh,disable= 1, win=IR2H_ControlPanel
			CheckBox Dis3_FitScale,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis3_ShapeLow,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis3_ShapeHigh,disable= 1, win=IR2H_ControlPanel
			CheckBox Dis3_FitShape,disable= 1, win=IR2H_ControlPanel

			TitleBox 	Dis3_Gauss, disable=1
			TitleBox 	Dis3_LogNormal, disable=1
			TitleBox 	Dis3_LSW, disable=0
			TitleBox 	Dis3_PowerLaw, disable=1

			Dist3FitScale = 0
			//Dist3FitLocation = 0
			Dist3FitShape = 0
		endif
		if (cmpstr(popStr,"PowerLaw")==0)
			SetVariable Dis3_shape, disable=0,title="Power slope   ", win=IR2H_ControlPanel
			SetVariable Dis3_ShapeStep, disable=0, win=IR2H_ControlPanel
			SetVariable Dis3_Scale, disable=0,title="Minimum Dia   ", win=IR2H_ControlPanel
			SetVariable Dis3_Location, disable=0,title="Maximum Dia  ", win=IR2H_ControlPanel
			SetVariable Dis3_ScaleStep, disable=1, win=IR2H_ControlPanel
			SetVariable Dis3_LocationStep, disable=1, win=IR2H_ControlPanel
			
			SetVariable Dis3_LocationLow,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis3_LocationHigh,disable= 1, win=IR2H_ControlPanel
			CheckBox Dis3_FitLocation,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis3_ScaleLow,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis3_ScaleHigh,disable= 1, win=IR2H_ControlPanel
			CheckBox Dis3_FitScale,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis3_ShapeLow,disable= 0, win=IR2H_ControlPanel
			SetVariable Dis3_ShapeHigh,disable= 0,title=" < slope < ", win=IR2H_ControlPanel
			CheckBox Dis3_FitShape,disable= 0,title="Fit slope?", win=IR2H_ControlPanel

			TitleBox 	Dis3_Gauss, disable=1
			TitleBox 	Dis3_LogNormal, disable=1
			TitleBox 	Dis3_LSW, disable=1
			TitleBox 	Dis3_PowerLaw, disable=0
			Dist3FitScale = 0
			Dist3FitLocation = 0
			//Dist3FitShape = 0
		endif
		//create and recalculate the distributions
		IR1_CreateDistributionWaves()
		IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
//		IR2H_UpdateModeMedianMean()		//modified for 5
		IR2H_AutoUpdateIfSelected()
	endif

	if (cmpstr(ctrlName,"Dis4_ShapePopup")==0)
		//here goes what happens when user selects shape in the panel
		//and that means, depending on the shape selected we need to get another panel with parameters
		//we have 3 universal shape parameters available for each shape type:
		//Dist4ScatShapeParam1;Dist4ScatShapeParam2;Dist4ScatShapeParam3
		IR2H_ResetScatShapeFitParam(4)
		
		//kill shpheroid window if exists...
		DoWindow Shape_Model_Input_Panel
		if (V_Flag)
			DoWindow/K Shape_Model_Input_Panel
		endif
		//create new window as needed
		if (cmpstr(popStr,"spheroid")==0 || cmpstr(popStr,"Algebraic_Globules")==0 || cmpstr(popStr,"Algebraic_Disks")==0 || cmpstr(popStr,"Integrated_Spheroid")==0)
			Execute ("Dis_Spheroid_Input_Panel(4)")
		endif
		if (cmpstr(popStr,"cylinder")==0 || cmpstr(popStr,"Algebraic_Rods")==0)
			Execute ("Dis_cylinder_Panel(4)")
		endif
		if (cmpstr(popStr,"tube")==0)
			Execute ("Dis_tube_Panel(4)")
		endif
		if (cmpstr(popStr,"CoreShell")==0)
			Execute ("Dis_CoreShell_Input_Panel(4)")
		endif
		if (cmpstr(popStr,"Fractal Aggregate")==0)
			Execute ("Dis_FractalAgg_Input_Panel(4)")
		endif
		SVAR Dist4ShapeModel=root:Packages:Gels_Modeling:Dist4ShapeModel
		Dist4ShapeModel=popStr
		//create and recalculate the distributions
		IR1_CreateDistributionWaves()
		IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
//		IR2H_UpdateModeMedianMean()		//modified for 5
		IR2H_AutoUpdateIfSelected()
	endif
	
	if (cmpstr(ctrlName,"Dis4_DistributionType")==0)
		//here goes what happens when user selects different dist type
		SVAR Dist4DistributionType=root:Packages:Gels_Modeling:Dist4DistributionType
		NVAR Dist4FitShape=root:Packages:Gels_Modeling:Dist4FitShape
		NVAR Dist4FitLocation=root:Packages:Gels_Modeling:Dist4FitLocation
		NVAR Dist4FitScale=root:Packages:Gels_Modeling:Dist4FitScale
		Dist4DistributionType=popStr
		if (cmpstr(popStr,"Gauss")==0)
			SetVariable Dis4_shape, disable=1, win=IR2H_ControlPanel
			SetVariable Dis4_ShapeStep, disable=1, win=IR2H_ControlPanel
			SetVariable Dis4_Scale, disable=0,title="Width        ", win=IR2H_ControlPanel
			SetVariable Dis4_Location, disable=0,title="Mean size", win=IR2H_ControlPanel
			SetVariable Dis4_ScaleStep, disable=0, win=IR2H_ControlPanel
			SetVariable Dis4_LocationStep, disable=0, win=IR2H_ControlPanel
			SetVariable Dis4_LocationLow,disable= (!Dist4FitLocation), win=IR2H_ControlPanel
			SetVariable Dis4_LocationHigh,disable= (!Dist4FitLocation),title="  < Mean size < ", win=IR2H_ControlPanel
			CheckBox Dis4_FitLocation,disable= 0,title="Fit mean size?", win=IR2H_ControlPanel
			SetVariable Dis4_ScaleLow,disable= (!Dist4FitScale), win=IR2H_ControlPanel
			SetVariable Dis4_ScaleHigh,disable=(!Dist4FitScale),title="  < Width <       ", win=IR2H_ControlPanel
			CheckBox Dis4_FitScale,disable= 0,title="Fit width?", win=IR2H_ControlPanel
			SetVariable Dis4_ShapeLow,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis4_ShapeHigh,disable= 1, win=IR2H_ControlPanel
			CheckBox Dis4_FitShape,disable= 1, win=IR2H_ControlPanel
			
			TitleBox 	Dis4_Gauss, disable=0
			TitleBox 	Dis4_LogNormal, disable=1
			TitleBox 	Dis4_LSW, disable=1
			TitleBox 	Dis4_PowerLaw, disable=1
			
			//Dist4FitScale = 0
			//Dist4FitLocation = 0
			Dist4FitShape = 0
		endif
		if (cmpstr(popStr,"LogNormal")==0)
			SetVariable Dis4_shape, disable=0,title="Sdeviation  ", win=IR2H_ControlPanel
			SetVariable Dis4_ShapeStep, disable=0, win=IR2H_ControlPanel
			SetVariable Dis4_Scale, disable=0,title="Mean size", win=IR2H_ControlPanel
			SetVariable Dis4_Location, disable=0,title="Min size  ", win=IR2H_ControlPanel
			SetVariable Dis4_ScaleStep, disable=0, win=IR2H_ControlPanel
			SetVariable Dis4_LocationStep, disable=0, win=IR2H_ControlPanel

			SetVariable Dis4_LocationLow,disable= (!Dist4FitLocation), win=IR2H_ControlPanel
 			SetVariable Dis4_LocationHigh,disable= (!Dist4FitLocation),title="  < Min. size <   ", win=IR2H_ControlPanel
			CheckBox Dis4_FitLocation,disable= 0,title="Fit min. size?", win=IR2H_ControlPanel
			SetVariable Dis4_ScaleLow,disable=(!Dist4FitScale), win=IR2H_ControlPanel
			SetVariable Dis4_ScaleHigh,disable= (!Dist4FitScale),title="  < Mean size < ", win=IR2H_ControlPanel
			CheckBox Dis4_FitScale,disable= 0,title="Fit mean size?", win=IR2H_ControlPanel
			SetVariable Dis4_ShapeLow,disable= (!Dist4FitShape), win=IR2H_ControlPanel
			SetVariable Dis4_ShapeHigh,disable=(!Dist4FitShape),title=" < Sdeviation < ", win=IR2H_ControlPanel
			CheckBox Dis4_FitShape,disable= 0,title="Fit Sdev.?", win=IR2H_ControlPanel

			TitleBox 	Dis4_Gauss, disable=1
			TitleBox 	Dis4_LogNormal, disable=0
			TitleBox 	Dis4_LSW, disable=1
			TitleBox 	Dis4_PowerLaw, disable=1
			//Dist4FitScale = 0
			//Dist4FitLocation = 0
			//Dist4FitShape = 0
		endif
		if (cmpstr(popStr,"LSW")==0)
			SetVariable Dis4_shape, disable=1, win=IR2H_ControlPanel
			SetVariable Dis4_ShapeStep, disable=1, win=IR2H_ControlPanel
			SetVariable Dis4_Scale, disable=1, win=IR2H_ControlPanel
			SetVariable Dis4_Location, disable=0,title="Location  ", win=IR2H_ControlPanel
			SetVariable Dis4_ScaleStep, disable=1, win=IR2H_ControlPanel
			SetVariable Dis4_LocationStep, disable=0, win=IR2H_ControlPanel
			
			SetVariable Dis4_LocationLow,disable= (!Dist4FitLocation), win=IR2H_ControlPanel
			SetVariable Dis4_LocationHigh,disable= (!Dist4FitLocation),title="  < location <     ", win=IR2H_ControlPanel
			CheckBox Dis4_FitLocation,disable= 0,title="Fit Location?", win=IR2H_ControlPanel
			SetVariable Dis4_ScaleLow,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis4_ScaleHigh,disable= 1, win=IR2H_ControlPanel
			CheckBox Dis4_FitScale,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis4_ShapeLow,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis4_ShapeHigh,disable= 1, win=IR2H_ControlPanel
			CheckBox Dis4_FitShape,disable= 1, win=IR2H_ControlPanel

			TitleBox 	Dis4_Gauss, disable=1
			TitleBox 	Dis4_LogNormal, disable=1
			TitleBox 	Dis4_LSW, disable=0
			TitleBox 	Dis4_PowerLaw, disable=1

			Dist4FitScale = 0
			//Dist4FitLocation = 0
			Dist4FitShape = 0
		endif
		if (cmpstr(popStr,"PowerLaw")==0)
			SetVariable Dis4_shape, disable=0,title="Power slope   ", win=IR2H_ControlPanel
			SetVariable Dis4_ShapeStep, disable=0, win=IR2H_ControlPanel
			SetVariable Dis4_Scale, disable=0,title="Minimum Dia   ", win=IR2H_ControlPanel
			SetVariable Dis4_Location, disable=0,title="Maximum Dia  ", win=IR2H_ControlPanel
			SetVariable Dis4_ScaleStep, disable=1, win=IR2H_ControlPanel
			SetVariable Dis4_LocationStep, disable=1, win=IR2H_ControlPanel
			
			SetVariable Dis4_LocationLow,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis4_LocationHigh,disable= 1, win=IR2H_ControlPanel
			CheckBox Dis4_FitLocation,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis4_ScaleLow,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis4_ScaleHigh,disable= 1, win=IR2H_ControlPanel
			CheckBox Dis4_FitScale,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis4_ShapeLow,disable= 0, win=IR2H_ControlPanel
			SetVariable Dis4_ShapeHigh,disable= 0,title=" < slope < ", win=IR2H_ControlPanel
			CheckBox Dis4_FitShape,disable= 0,title="Fit slope?", win=IR2H_ControlPanel

			TitleBox 	Dis4_Gauss, disable=1
			TitleBox 	Dis4_LogNormal, disable=1
			TitleBox 	Dis4_LSW, disable=1
			TitleBox 	Dis4_PowerLaw, disable=0
			Dist4FitScale = 0
			Dist4FitLocation = 0
			//Dist4FitShape = 0
		endif
		//create and recalculate the distributions
		IR1_CreateDistributionWaves()
		IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
	//	IR2H_UpdateModeMedianMean()		//modified for 5
		IR2H_AutoUpdateIfSelected()
	endif


	if (cmpstr(ctrlName,"Dis5_ShapePopup")==0)
		//here goes what happens when user selects shape in the panel
		//and that means, depending on the shape selected we need to get another panel with parameters
		//we have 3 universal shape parameters available for each shape type:
		//Dist5ScatShapeParam1;Dist5ScatShapeParam2;Dist5ScatShapeParam3
		IR2H_ResetScatShapeFitParam(5)
		
		//kill shpheroid window if exists...
		DoWindow Shape_Model_Input_Panel
		if (V_Flag)
			DoWindow/K Shape_Model_Input_Panel
		endif
		//create new window as needed
		if (cmpstr(popStr,"spheroid")==0 || cmpstr(popStr,"Algebraic_Globules")==0 || cmpstr(popStr,"Algebraic_Disks")==0 || cmpstr(popStr,"Integrated_Spheroid")==0)
			Execute ("Dis_Spheroid_Input_Panel(5)")
		endif
		if (cmpstr(popStr,"cylinder")==0 || cmpstr(popStr,"Algebraic_Rods")==0)
			Execute ("Dis_cylinder_Panel(5)")
		endif
		if (cmpstr(popStr,"tube")==0)
			Execute ("Dis_tube_Panel(5)")
		endif
		if (cmpstr(popStr,"CoreShell")==0)
			Execute ("Dis_CoreShell_Input_Panel(5)")
		endif
		if (cmpstr(popStr,"Fractal Aggregate")==0)
			Execute ("Dis_FractalAgg_Input_Panel(5)")
		endif
		SVAR Dist5ShapeModel=root:Packages:Gels_Modeling:Dist5ShapeModel
		Dist5ShapeModel=popStr
		//create and recalculate the distributions
		IR1_CreateDistributionWaves()
		IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
//		IR2H_UpdateModeMedianMean()		//modified for 5

		IR2H_AutoUpdateIfSelected()
	endif
	
	if (cmpstr(ctrlName,"Dis5_DistributionType")==0)
		//here goes what happens when user selects different dist type
		SVAR Dist5DistributionType=root:Packages:Gels_Modeling:Dist5DistributionType
		NVAR Dist5FitShape=root:Packages:Gels_Modeling:Dist5FitShape
		NVAR Dist5FitLocation=root:Packages:Gels_Modeling:Dist5FitLocation
		NVAR Dist5FitScale=root:Packages:Gels_Modeling:Dist5FitScale
		Dist5DistributionType=popStr

		if (cmpstr(popStr,"Gauss")==0)
			SetVariable Dis5_shape, disable=1, win=IR2H_ControlPanel
			SetVariable Dis5_ShapeStep, disable=1, win=IR2H_ControlPanel
			SetVariable Dis5_Scale, disable=0,title="Width        ", win=IR2H_ControlPanel
			SetVariable Dis5_Location, disable=0,title="Mean size", win=IR2H_ControlPanel
			SetVariable Dis5_ScaleStep, disable=0, win=IR2H_ControlPanel
			SetVariable Dis5_LocationStep, disable=0, win=IR2H_ControlPanel
			SetVariable Dis5_LocationLow,disable= (!Dist5FitLocation), win=IR2H_ControlPanel
			SetVariable Dis5_LocationHigh,disable= (!Dist5FitLocation),title="  < Mean size < ", win=IR2H_ControlPanel
			CheckBox Dis5_FitLocation,disable= 0,title="Fit mean size?", win=IR2H_ControlPanel
			SetVariable Dis5_ScaleLow,disable= (!Dist5FitScale), win=IR2H_ControlPanel
			SetVariable Dis5_ScaleHigh,disable=(!Dist5FitScale),title="  < Width <       ", win=IR2H_ControlPanel
			CheckBox Dis5_FitScale,disable= 0,title="Fit width?", win=IR2H_ControlPanel
			SetVariable Dis5_ShapeLow,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis5_ShapeHigh,disable= 1, win=IR2H_ControlPanel
			CheckBox Dis5_FitShape,disable= 1, win=IR2H_ControlPanel
			
			TitleBox 	Dis5_Gauss, disable=0
			TitleBox 	Dis5_LogNormal, disable=1
			TitleBox 	Dis5_LSW, disable=1
			TitleBox 	Dis5_PowerLaw, disable=1
			
			//Dist5FitScale = 0
			//Dist5FitLocation = 0
			Dist5FitShape = 0
		endif
		if (cmpstr(popStr,"LogNormal")==0)
			SetVariable Dis5_shape, disable=0,title="Sdeviation  ", win=IR2H_ControlPanel
			SetVariable Dis5_ShapeStep, disable=0, win=IR2H_ControlPanel
			SetVariable Dis5_Scale, disable=0,title="Mean size", win=IR2H_ControlPanel
			SetVariable Dis5_Location, disable=0,title="Min size  ", win=IR2H_ControlPanel
			SetVariable Dis5_ScaleStep, disable=0, win=IR2H_ControlPanel
			SetVariable Dis5_LocationStep, disable=0, win=IR2H_ControlPanel

			SetVariable Dis5_LocationLow,disable= (!Dist5FitLocation), win=IR2H_ControlPanel
 			SetVariable Dis5_LocationHigh,disable= (!Dist5FitLocation),title="  < Min. size <   ", win=IR2H_ControlPanel
			CheckBox Dis5_FitLocation,disable= 0,title="Fit min. size?", win=IR2H_ControlPanel
			SetVariable Dis5_ScaleLow,disable=(!Dist5FitScale), win=IR2H_ControlPanel
			SetVariable Dis5_ScaleHigh,disable= (!Dist5FitScale),title="  < Mean size < ", win=IR2H_ControlPanel
			CheckBox Dis5_FitScale,disable= 0,title="Fit mean size?", win=IR2H_ControlPanel
			SetVariable Dis5_ShapeLow,disable= (!Dist5FitShape), win=IR2H_ControlPanel
			SetVariable Dis5_ShapeHigh,disable=(!Dist5FitShape),title=" < Sdeviation < ", win=IR2H_ControlPanel
			CheckBox Dis5_FitShape,disable= 0,title="Fit Sdev.?", win=IR2H_ControlPanel

			TitleBox 	Dis5_Gauss, disable=1
			TitleBox 	Dis5_LogNormal, disable=0
			TitleBox 	Dis5_LSW, disable=1
			TitleBox 	Dis5_PowerLaw, disable=1
			//Dist5FitScale = 0
			//Dist5FitLocation = 0
			//Dist5FitShape = 0
		endif
		if (cmpstr(popStr,"LSW")==0)
			SetVariable Dis5_shape, disable=1, win=IR2H_ControlPanel
			SetVariable Dis5_ShapeStep, disable=1, win=IR2H_ControlPanel
			SetVariable Dis5_Scale, disable=1, win=IR2H_ControlPanel
			SetVariable Dis5_Location, disable=0,title="Location  ", win=IR2H_ControlPanel
			SetVariable Dis5_ScaleStep, disable=1, win=IR2H_ControlPanel
			SetVariable Dis5_LocationStep, disable=0, win=IR2H_ControlPanel
			
			SetVariable Dis5_LocationLow,disable= (!Dist5FitLocation), win=IR2H_ControlPanel
			SetVariable Dis5_LocationHigh,disable= (!Dist5FitLocation),title="  < location <     ", win=IR2H_ControlPanel
			CheckBox Dis5_FitLocation,disable= 0,title="Fit Location?", win=IR2H_ControlPanel
			SetVariable Dis5_ScaleLow,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis5_ScaleHigh,disable= 1, win=IR2H_ControlPanel
			CheckBox Dis5_FitScale,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis5_ShapeLow,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis5_ShapeHigh,disable= 1, win=IR2H_ControlPanel
			CheckBox Dis5_FitShape,disable= 1, win=IR2H_ControlPanel

			TitleBox 	Dis5_Gauss, disable=1
			TitleBox 	Dis5_LogNormal, disable=1
			TitleBox 	Dis5_LSW, disable=0
			TitleBox 	Dis5_PowerLaw, disable=1

			Dist5FitScale = 0
			//Dist5FitLocation = 0
			Dist5FitShape = 0
		endif
		if (cmpstr(popStr,"PowerLaw")==0)
			SetVariable Dis5_shape, disable=0,title="Power slope   ", win=IR2H_ControlPanel
			SetVariable Dis5_ShapeStep, disable=0, win=IR2H_ControlPanel
			SetVariable Dis5_Scale, disable=0,title="Minimum Dia   ", win=IR2H_ControlPanel
			SetVariable Dis5_Location, disable=0,title="Maximum Dia  ", win=IR2H_ControlPanel
			SetVariable Dis5_ScaleStep, disable=1, win=IR2H_ControlPanel
			SetVariable Dis5_LocationStep, disable=1, win=IR2H_ControlPanel
			
			SetVariable Dis5_LocationLow,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis5_LocationHigh,disable= 1, win=IR2H_ControlPanel
			CheckBox Dis5_FitLocation,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis5_ScaleLow,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis5_ScaleHigh,disable= 1, win=IR2H_ControlPanel
			CheckBox Dis5_FitScale,disable= 1, win=IR2H_ControlPanel
			SetVariable Dis5_ShapeLow,disable= 0, win=IR2H_ControlPanel
			SetVariable Dis5_ShapeHigh,disable= 0,title=" < slope < ", win=IR2H_ControlPanel
			CheckBox Dis5_FitShape,disable= 0,title="Fit slope?", win=IR2H_ControlPanel

			TitleBox 	Dis5_Gauss, disable=1
			TitleBox 	Dis5_LogNormal, disable=1
			TitleBox 	Dis5_LSW, disable=1
			TitleBox 	Dis5_PowerLaw, disable=0
			Dist5FitScale = 0
			Dist5FitLocation = 0
			//Dist5FitShape = 0
		endif
		//create and recalculate the distributions
		IR1_CreateDistributionWaves()
		IR1_CalculateDistributions()		//modified for 5
		//update the mode median and mean
	//	IR2H_UpdateModeMedianMean()		//modified for 5
		IR2H_AutoUpdateIfSelected()
	endif
	setDataFolder oldDF

End



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR2H_ResetScatShapeFitParam(which)
		variable which 
		
		NVAR FitShape1=$("root:Packages:Gels_Modeling:Dist"+num2str(which)+"FitScatShapeParam1")
		NVAR FitShape2=$("root:Packages:Gels_Modeling:Dist"+num2str(which)+"FitScatShapeParam3")
		NVAR FitShape3=$("root:Packages:Gels_Modeling:Dist"+num2str(which)+"FitScatShapeParam2")
		
		FitShape1=0
		FitShape2=0
		FitShape3=0
end






//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2H_InputPanelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Gels_Modeling
	

	if (cmpstr(ctrlName,"DrawGraphs")==0)
		//here goes what is done, when user pushes Graph button
		SVAR DFloc=root:Packages:Gels_Modeling:DataFolderName
		SVAR DFInt=root:Packages:Gels_Modeling:IntensityWaveName
		SVAR DFQ=root:Packages:Gels_Modeling:QWaveName
		SVAR DFE=root:Packages:Gels_Modeling:ErrorWaveName
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
			//set the slit smeared data in case of Indra2 data set, else leave alone - could be qrs slit smeared 
			NVAR UseIndra2Data=root:Packages:Gels_Modeling:UseIndra2Data
			if(UseIndra2Data)
				NVAR UseSlitSmearedData=root:Packages:Gels_Modeling:UseSlitSmearedData
				if(stringmatch(DFInt, "*SMR_Int"))
					UseSlitSmearedData=1
				else
					UseSlitSmearedData=0
				endif
				SetVariable SlitLength disable=!(UseSlitSmearedData), win=IR2H_ControlPanel
			endif
			IR2H_GraphMeasuredData()
			IR2H_RecoverParameters() //mostly done...
			IR2H_FixTabsInPanel()		//not done yet
		//	NVAR ActiveTab=root:Packages:Gels_Modeling:ActiveTab	//do I need this?
			IR2H_AutoUpdateIfSelected()
			AutoPositionWindow /M=0 /R=IR2H_ControlPanel IR2H_LogLogPlotGels
			AutoPositionWindow /M=1 /R=IR2H_LogLogPlotGels IR2H_IQ4_Q_PlotGels
			AutoPositionWindow /M=1 /R=IR2H_IQ4_Q_PlotGels IR2H_SI_Q2_PlotGels
			
		else
			Abort "Data not selected properly"
		endif
	endif

	if(cmpstr(ctrlName,"DoFitting")==0)
		//here we call the fitting routine
		IR2H_ConstructTheFittingCommand()
	endif
	if(cmpstr(ctrlName,"RevertFitting")==0)
		//here we call the fitting routine
		IR2H_ResetParamsAfterBadFit()
		IR2H_GraphModelData()
	endif
	
	if(cmpstr(ctrlName,"GraphDistribution")==0)
		//here we graph the distribution
		IR2H_GraphModelData()
	endif
	if(cmpstr(ctrlName,"CopyToFolder")==0)
		//here we copy final data back to original data folder		I	
		IR2H_CopyDataBackToFolder()
	//	DoAlert 0,"Copy"
	endif
	
	if(cmpstr(ctrlName,"ExportData")==0)
		//here we export ASCII form of the data
		IR2H_ExportASCIIResults()

	//	DoAlert 0, "Export"
	endif
	if(cmpstr(ctrlName,"EstimateCorrL")==0)
		//here we export ASCII form of the data
		IR2H_EstimateCorrL()
	endif
	if(cmpstr(ctrlName,"EstimateLowQ")==0)
		//here we export ASCII form of the data
		IR2H_EstimateLowQslope()
	endif
	if(cmpstr(ctrlName,"ResultsToGraph")==0)
		//here we export ASCII form of the data
		IR2H_AttachTags()
	endif
	if(cmpstr(ctrlName,"ResultsToNotebook")==0)
		IR2H_SaveResultsToNotebook()
	endif

	setDataFolder oldDf

end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


static Function IR2H_SaveResultsToNotebook()

	IR1_CreateResultsNbk()
	MoveWindow /W=IR2H_LogLogPlotGels 400, 30, 980, 530
	IR2H_AttachTags()
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Gels_Modeling
	SVAR  DataFolderName=root:Packages:Gels_Modeling:DataFolderName
	SVAR  IntensityWaveName=root:Packages:Gels_Modeling:IntensityWaveName
	SVAR  QWavename=root:Packages:Gels_Modeling:QWavename
	SVAR  ErrorWaveName=root:Packages:Gels_Modeling:ErrorWaveName
//	SVAR  MethodRun=root:Packages:Sizes:MethodRun
	IR1_AppendAnyText("\r Results of Analytical modeling \r",1)	
	IR1_AppendAnyText("Date & time: \t"+Date()+"   "+time(),0)	
	IR1_AppendAnyText("Data from folder: \t"+DataFolderName,0)	
	IR1_AppendAnyText("Intensity: \t"+IntensityWaveName,0)	
	IR1_AppendAnyText("Q: \t"+QWavename,0)	
	IR1_AppendAnyText("Error: \t"+ErrorWaveName,0)	
//	IR1_AppendAnyText("Method used: \t"+MethodRun,0)	
	string FittingResults="\r\r"
	
		string ListOfVariables="UseIndra2Data;UseQRSdata;CurrentTab;UseLowQInDB;"
		ListOfVariables+="UseSlitSmearedData;SlitLength;"	
		ListOfVariables+="SASBackground;SASBackgroundStep;FitSASBackground;UpdateAutomatically;SASBackgroundError;"
		//Unified level
		ListOfVariables+="LowQslope;LowQPrefactor;FitLowQslope;FitLowQPrefactor;LowQslopeLowLimit;LowQPrefactorLowLimit;"
		ListOfVariables+="LowQslopeError;LowQPrefactorError;LowQslopeHighLimit;LowQPrefactorHighLimit;"
		ListOfVariables+="LowQRg;FitLowQRg;LowQRgLowLimit;LowQRgHighLimit;LowQRgError;"
		ListOfVariables+="LowQRgPrefactor;FitLowQRgPrefactor;LowQRgPrefactorLowLimit;LowQRgPrefactorHighLimit;LowQRgPrefactorError;"
		//Debye-Bueche parameters	
		ListOfVariables+="DBPrefactor;DBEta;DBcorrL;DBWavelength;"
		ListOfVariables+="DBEtaError;DBcorrLError;"
		ListOfVariables+="FitDBPrefactor;FitDBEta;FitDBcorrL;"
		ListOfVariables+="DBPrefactorHighLimit;DBEtaHighLimit;DBcorrLHighLimit;"
		ListOfVariables+="DBPrefactorLowLimit;DBEtaLowLimit;DBcorrLLowLimit;"
		//Teubner-Strey Model
		ListOfVariables+="TSPrefactor;FitTSPrefactor;TSPrefactorHighLimit;TSPrefactorLowLimit;TSPrefactorError;"
		ListOfVariables+="TSAvalue;FitTSAvalue;TSAvalueHighLimit;TSAvalueLowLimit;TSAvalueError;"
		ListOfVariables+="TSC1Value;FitTSC1Value;TSC1ValueHighLimit;TSC1ValueLowLimit;TSC1ValueError;"
		ListOfVariables+="TSC2Value;FitTSC2Value;TSC2ValueHighLimit;TSC2ValueLowLimit;TSC2ValueError;"
		ListOfVariables+="TSCorrelationLength;TSCorrLengthError;TSRepeatDistance;TSRepDistError;"
		//Ciccariello Coated Porous media Porods oscillations
		ListOfVariables+="BC_PorodsSpecSurfArea;BC_SolidScatLengthDensity;BC_VoidScatLengthDensity;BC_LayerScatLengthDens;"
		ListOfVariables+="BC_CoatingsThickness;UseCiccBen;"
		ListOfVariables+="BC_LayerScatLengthDensHL;BC_LayerScatLengthDensLL;FitBC_LayerScatLengthDens;"
		ListOfVariables+="BC_CoatingsThicknessHL;BC_CoatingsThicknessLL;FitBC_CoatingsThickness;"
		ListOfVariables+="BC_PorodsSpecSurfAreaHL;BC_PorodsSpecSurfAreaLL;FitBC_PorodsSpecSurfArea;"
		ListOfVariables+="BC_PorodsSpecSurfAreaError;BC_CoatingsThicknessError;BC_LayerScatLengthDensError;"
	NVAR UseDB
	NVAR UseLowQInDB
	NVAR useTS
	NVAR UseCiccBen
	if(UseDB)
		FittingResults+="Results of Analytical modeling using Debye-Bueche\r"
		NVAR DBPrefactor
		NVAR DBEta
		NVAR DBcorrL
		NVAR DBEtaError
		NVAR DBcorrLError
		FittingResults+="Prefactor = "+num2str(DBPrefactor)+"\r"
		FittingResults+="Eta = "+num2str(DBEta)+" +/- "+num2str(DBEtaError)+"\r"
		FittingResults+="Correlation Length = "+num2str(DBcorrL)+" +/- "+num2str(DBcorrLError)+"\r"
	elseif(useTS)
		FittingResults+="Results of Analytical modeling using Treubner-Streuss\r"
		NVAR TSPrefactor
		NVAR TSCorrelationLength
		NVAR TSRepeatDistance
		FittingResults+="Prefactor = "+num2str(TSPrefactor)+"\r"
		FittingResults+="Correlation Length = "+num2str(TSCorrelationLength)+"\r"
		FittingResults+="Repeat distance = "+num2str(TSRepeatDistance)+"\r"
	elseif(UseCiccBen)
		FittingResults+="Results of Analytical modeling using  Ciccariello & Benedetti\r"
		NVAR BC_PorodsSpecSurfArea
		NVAR BC_LayerScatLengthDens
		NVAR BC_CoatingsThickness
		NVAR BC_PorodsSpecSurfAreaError
		NVAR BC_LayerScatLengthDensError
		NVAR BC_CoatingsThicknessError
		FittingResults+="Porod specific surface area [cm2/cm3]= "+num2str(BC_PorodsSpecSurfArea)+" +/- "+num2str(BC_PorodsSpecSurfAreaError)+"\r"
		FittingResults+="Layer Thickness [A] = "+num2str(BC_CoatingsThickness)+" +/- "+num2str(BC_CoatingsThicknessError)+"\r"
		FittingResults+="Layer Contrast [10^10 cm^-2]= "+num2str(BC_LayerScatLengthDens)+" +/- "+num2str(BC_LayerScatLengthDensError)+"\r"
	endif
	
	if(UseLowQInDB)
		FittingResults+="\rModeling also included low-q power-law slope\r"
		NVAR LowQslope
		NVAR LowQPrefactor
		NVAR LowQslopeError
		NVAR LowQPrefactorError
		FittingResults+="Low-Q Prefactor = "+num2str(LowQPrefactor)+" +/- "+num2str(LowQPrefactorError)+"\r"
		FittingResults+="Low-Q slope = "+num2str(LowQslope)+" +/- "+num2str(LowQslopeError)+"\r"
	endif
	NVAR SASBackground
	FittingResults+= "SAS background included = "+num2str(SASBackground)+"\r"
	IR1_AppendAnyGraph("IR2H_LogLogPlotGels")
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



static Function IR2H_AttachTags()

	NVAR DBPrefactor=root:Packages:Gels_Modeling:DBPrefactor
	NVAR DBEta=root:Packages:Gels_Modeling:DBEta
	NVAR DBcorrL=root:Packages:Gels_Modeling:DBcorrL
	NVAR LowQslope=root:Packages:Gels_Modeling:LowQslope
	NVAR LowQPrefactor=root:Packages:Gels_Modeling:LowQPrefactor
	NVAR DBWavelength=root:Packages:Gels_Modeling:DBWavelength
	SVAR DataFolderName=root:Packages:Gels_Modeling:DataFolderName
	SVAR IntensityWaveName=root:Packages:Gels_Modeling:IntensityWaveName
	wave OriginalQvector=root:Packages:Gels_Modeling:OriginalQvector
	NVAR DBEtaError=root:Packages:Gels_Modeling:DBEtaError
	NVAR DBcorrLError=root:Packages:Gels_Modeling:DBcorrLError
	NVAR LowQslopeError=root:Packages:Gels_Modeling:LowQslopeError
	NVAR LowQPrefactorError=root:Packages:Gels_Modeling:LowQPrefactorError
	NVAR UseLowQInDB=root:Packages:Gels_Modeling:UseLowQInDB
	NVAR UseDB=root:Packages:Gels_Modeling:UseDB
	NVAR UseTS=root:Packages:Gels_Modeling:UseTS
	NVAR LowQRg=LowQRg
	NVAR LowQRgError=LowQRgError
	NVAR LowQRgPrefactor=LowQRgPrefactor
	NVAR LowQRgPrefactorError=LowQRgPrefactorError
	NVAR TSCorrelationLength=TSCorrelationLength
	NVAR TSCorrLengthError=TSCorrLengthError
	NVAR TSRepeatDistance=TSRepeatDistance
	NVAR TSRepDistError=TSRepDistError

	NVAR BC_PorodsSpecSurfArea=BC_PorodsSpecSurfArea
	NVAR BC_PorodsSpecSurfAreaError=BC_PorodsSpecSurfAreaError
	NVAR BC_SolidScatLengthDensity=BC_SolidScatLengthDensity
	NVAR BC_VoidScatLengthDensity=BC_VoidScatLengthDensity
	NVAR BC_LayerScatLengthDens=BC_LayerScatLengthDens
	NVAR BC_LayerScatLengthDensError=BC_LayerScatLengthDensError
	NVAR BC_CoatingsThickness=BC_CoatingsThickness
	NVAR BC_CoatingsThicknessError=BC_CoatingsThicknessError
	NVAR UseCiccBen=UseCiccBen

	//I(q) = (4*pi*K*eta^2*corrL^2)/(1+q^2*corrL^2)^2
	//K = 8*pi^2*n^2*lambda^-4
	// q = (4*pi*n/lambda)* sin(theta/2).
	NVAR LegendSize = root:Packages:IrenaConfigFolder:LegendSize
	string LowQText, DBText, CiccBenTxt,TStxt
	variable attachPoint
	Tag/W=IR2H_LogLogPlotGels /K/N=DBTag 
	Tag/W=IR2H_LogLogPlotGels /K/N=CiccBenTag 
	Tag/W=IR2H_IQ4_Q_PlotGels /K/N=CiccBenTag 
	Tag/W=IR2H_LogLogPlotGels /K/N=TStag 
	
	if(UseDB)
		findlevel /Q /P OriginalQvector, (pi/ DBcorrL)^2
		attachPoint=V_levelX
		DBText = "\Z"+IR2C_LkUpDfltVar("LegendSize")+"Debye-Bueche model results\r"
		DBText += "Sample name: "+DataFolderName+IntensityWaveName+"\r"
		DBText += "Eta = "+num2str(DBEta)+" +/- "+num2str(DBEtaError)+"\r"
		DBText += "Correlation length = "+num2str(DBcorrL)+" A"+" +/- "+num2str(DBcorrLError)
		Tag/W=IR2H_LogLogPlotGels /C/N=DBTag OriginalIntensity, attachPoint,DBText
	elseif(UseCiccBen)
		attachPoint=(pcsr(A,"IR2H_LogLogPlotGels") +pcsr(B,"IR2H_LogLogPlotGels"))/2
		CiccBenTxt = "\Z"+IR2C_LkUpDfltVar("LegendSize")+"Ciccariello & Benedetti model results\r"
		CiccBenTxt += "Sample name: "+DataFolderName+IntensityWaveName+"\r"
		CiccBenTxt += "Porod specific surface area [cm2/cm3] = "+num2str(BC_PorodsSpecSurfArea)+" +/- "+num2str(BC_PorodsSpecSurfAreaError)+"\r"
		CiccBenTxt += "Layer thickness = "+num2str(BC_CoatingsThickness)+" A"+" +/- "+num2str(BC_CoatingsThicknessError)+"\r"
		CiccBenTxt += "Scat. Length dens = "+num2str(BC_LayerScatLengthDens)+" cm^-2"+" +/- "+num2str(BC_LayerScatLengthDensError)
		Tag/W=IR2H_LogLogPlotGels /C/N=CiccBenTag OriginalIntensity, attachPoint,CiccBenTxt
		CheckDisplayed /W=IR2H_IQ4_Q_PlotGels OriginalIntQ3
		if(V_Flag)
			Tag/W=IR2H_IQ4_Q_PlotGels /C/N=CiccBenTag OriginalIntQ3, attachPoint,CiccBenTxt
		endif
		CheckDisplayed /W=IR2H_IQ4_Q_PlotGels OriginalIntQ4
		if(V_Flag)
			Tag/W=IR2H_IQ4_Q_PlotGels /C/N=CiccBenTag OriginalIntQ4, attachPoint,CiccBenTxt
		endif
		
	elseif(UseTS)
		findlevel /Q /P OriginalQvector, (pi/ TSCorrelationLength)
		attachPoint=V_levelX
		TStxt = "\Z"+IR2C_LkUpDfltVar("LegendSize")+"Teubner-Strey model results\r"
		TStxt += "Sample name: "+DataFolderName+IntensityWaveName+"\r"
		TStxt += "Correlation length = "+num2str(TSCorrelationLength)+"A"+" +/- "+num2str(TSCorrLengthError)+"\r"
		TStxt += "Repeat distance = "+num2str(TSRepeatDistance)+" A"+" +/- "+num2str(TSRepDistError)
		Tag/W=IR2H_LogLogPlotGels /C/N=TStag OriginalIntensity, attachPoint,TStxt
	endif
	if(UseLowQInDB)
		if(LowQRg<1e10)
			findlevel /Q /P OriginalQvector, (pi/ LowQRg)^2
			attachPoint=V_levelX
		else
			attachPoint = numpnts(OriginalQvector)/2
		endif
		LowQText = "\Z"+IR2C_LkUpDfltVar("LegendSize")+"Low Q Unified model"+"\r"
		if(LowQRg<1e10)
			 LowQText +="Rg = "+num2str(LowQRg)+" +/- "+num2str(LowQRgError)+"\r"
			 LowQText +="Rg prefactor (G) = "+num2str(LowQRgPrefactor)+" +/- "+num2str(LowQRgPrefactorError)+"\r"
		endif
		 LowQText +="Power law Slope (P) = "+num2str(LowQslope)+" +/- "+num2str(LowQslopeError)+"\r"
		 LowQText +="P Prefactor (B) = "+num2str(LowQPrefactor)+" +/- "+num2str(LowQPrefactorError)
		 
		Tag/W=IR2H_LogLogPlotGels /C/N=LowQSlopeTag OriginalIntensity, attachPoint/2,LowQText
	else
		Tag/W=IR2H_LogLogPlotGels /K/N=LowQSlopeTag 
	endif
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
static Function IR2H_GraphModelData()
	//next we calculate the model
	
	wave OriginalIntensity=root:Packages:Gels_Modeling:OriginalIntensity
	Wave OriginalQvector=root:Packages:Gels_Modeling:OriginalQvector
	Wave OriginalError=root:Packages:Gels_Modeling:OriginalError
	IR2H_CalculateModel(OriginalIntensity,OriginalQvector)
	
//	IR1_CalculateNormalizedError("fit")
//	//append waves to the two top graphs with measured data
	IR2H_AppendModelToMeasuredData()
	TextBox/W=IR2H_SI_Q2_PlotGels/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	TextBox/W=IR2H_IQ4_Q_PlotGels/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	TextBox/W=IR2H_LogLogPlotGels/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
//	DoWindow IR2H_InterferencePanel
//	if (V_Flag)
//		DoWindow/F IR2H_InterferencePanel
//	endif

end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


static Function IR2H_EstimateCorrL()

	Wave OriginalQ2=root:Packages:Gels_Modeling:OriginalQ2
	Wave OriginalSqrtIntN1=root:Packages:Gels_Modeling:OriginalSqrtIntN1
	Wave OriginalSqrtErrN1=root:Packages:Gels_Modeling:OriginalSqrtErrN1	
	
	if(strlen(CsrWave(A, "IR2H_LogLogPlotGels"))<=0 || strlen(CsrWave(B, "IR2H_LogLogPlotGels"))<=0)
		Abort "Cursors not set correctly in the appropriate graph. Set cursors in log-log plot"
	endif
	variable cursA, cursB
	cursA= pcsr(A  , "IR2H_LogLogPlotGels")
	cursB= pcsr(B  , "IR2H_LogLogPlotGels")
	DoWindow/F IR2H_SI_Q2_PlotGels
	SetAxis/W=IR2H_SI_Q2_PlotGels bottom 0,1.3*OriginalQ2[cursB] 
	SetAxis/W=IR2H_SI_Q2_PlotGels left 0.3*OriginalSqrtIntN1[cursA],2*OriginalSqrtIntN1[cursB] 
	CurveFit line  OriginalSqrtIntN1[cursA,cursB] /X=OriginalQ2 /W=OriginalSqrtErrN1 /I=1 /D 
	ModifyGraph/W=IR2H_SI_Q2_PlotGels mode(fit_OriginalSqrtIntN1)=0
	NVAR corrL=root:Packages:Gels_Modeling:DBcorrL
	NVAR DBEta=root:Packages:Gels_Modeling:DBEta
	Wave W_coef
	corrL = sqrt(W_coef[1]/W_coef[0])
	IR2H_GraphModelData()
	Wave OriginalIntensity=root:Packages:Gels_Modeling:OriginalIntensity
	Wave DBModelIntensity=root:Packages:Gels_Modeling:DBModelIntensity
	variable AveModel, AveData
	wavestats/Q/R=[cursA,cursB] OriginalIntensity
	AveData = V_avg
	wavestats/Q/R=[cursA,cursB] DBModelIntensity
	AveModel = V_avg
	DBEta *= sqrt(AveData/AveModel)
	IR2H_GraphModelData()

end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


static Function IR2H_EstimateLowQslope()

	Wave OriginalIntensity=root:Packages:Gels_Modeling:OriginalIntensity
	Wave OriginalQvector=root:Packages:Gels_Modeling:OriginalQvector
	Wave OriginalError=root:Packages:Gels_Modeling:OriginalError	
	variable cursA, cursB
	cursA= pcsr(A  , "IR2H_LogLogPlotGels")
	cursB= pcsr(B  , "IR2H_LogLogPlotGels")
	CurveFit power  OriginalIntensity[cursA,cursB] /X=OriginalQvector /W=OriginalError /I=1 /D 
	NVAR UseSlitSmearedData=root:Packages:Gels_Modeling:UseSlitSmearedData
	NVAR LowQslope=root:Packages:Gels_Modeling:LowQslope
	NVAR LowQPrefactor=root:Packages:Gels_Modeling:LowQPrefactor
	Wave W_coef
	if(UseSlitSmearedData)
		LowQslope = -(W_coef[2] - 1)
		LowQPrefactor = W_coef[1]
	else
		LowQslope = -W_coef[2]
		LowQPrefactor = W_coef[1]
	endif
	IR2H_GraphModelData()
	Wave OriginalIntensity=root:Packages:Gels_Modeling:OriginalIntensity
	Wave DBModelIntensity=root:Packages:Gels_Modeling:DBModelIntensity
	variable AveModel, AveData
	wavestats/Q/R=[cursA,cursB] OriginalIntensity
	AveData = V_avg
	wavestats/Q/R=[cursA,cursB] DBModelIntensity
	AveModel = V_avg
	NVAR LowQPrefactor=root:Packages:Gels_Modeling:LowQPrefactor
	LowQPrefactor *= (AveData/AveModel)
	IR2H_GraphModelData()

end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR2H_CalculateModel(OriginalIntensity,OriginalQvector)
	wave OriginalIntensity,OriginalQvector

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Gels_Modeling

	
	Duplicate/O OriginalIntensity, DBModelIntensity,DBModelIntensityQ4,DBModelIntensityQ3, DBTempInt1, DBtempInt2, DBTempInt3, DBModelIntSqrtN1, DBTempIntTS
	Duplicate/O OriginalIntensity, CiccBenModelIntensity
	Duplicate/O OriginalQvector, DBModelQvector, QstarVector
	DBTempInt1=0
	DBtempInt2=0
	DBtempInt3=0
	DBTempIntTS=0
	CiccBenModelIntensity=0
	
	NVAR UseSlitSmearedData=root:Packages:Gels_Modeling:UseSlitSmearedData
	NVAR SlitLength=root:Packages:Gels_Modeling:SlitLength
	NVAR SASBackground=root:Packages:Gels_Modeling:SASBackground
	NVAR DBPrefactor=root:Packages:Gels_Modeling:DBPrefactor
	NVAR DBEta=root:Packages:Gels_Modeling:DBEta
	NVAR DBcorrL=root:Packages:Gels_Modeling:DBcorrL
	NVAR LowQslope=root:Packages:Gels_Modeling:LowQslope
	NVAR LowQPrefactor=root:Packages:Gels_Modeling:LowQPrefactor
	NVAR DBWavelength=root:Packages:Gels_Modeling:DBWavelength
	NVAR SASBackground=root:Packages:Gels_Modeling:SASBackground
	NVAR UseLowQInDB=root:Packages:Gels_Modeling:UseLowQInDB
	NVAR UseDB=root:Packages:Gels_Modeling:UseDB
	NVAR UseTS=root:Packages:Gels_Modeling:UseTS
	NVAR LowQRg=root:Packages:Gels_Modeling:LowQRg
	NVAR TSPrefactor=root:Packages:Gels_Modeling:TSPrefactor
	NVAR TSAvalue=root:Packages:Gels_Modeling:TSAvalue
	NVAR TSC1Value=root:Packages:Gels_Modeling:TSC1Value
	NVAR TSC2Value=root:Packages:Gels_Modeling:TSC2Value
	NVAR LowQRgPrefactor=root:Packages:Gels_Modeling:LowQRgPrefactor
	NVAR TSCorrelationLength=root:Packages:Gels_Modeling:TSCorrelationLength
	NVAR TSRepeatDistance=root:Packages:Gels_Modeling:TSRepeatDistance
	
	NVAR UseCiccBen=root:Packages:Gels_Modeling:UseCiccBen				//[A]
	NVAR BC_PorodsSpecSurfArea=root:Packages:Gels_Modeling:BC_PorodsSpecSurfArea			//[cm2/cm3]
	NVAR BC_SolidScatLengthDensity=root:Packages:Gels_Modeling:BC_SolidScatLengthDensity		//N1 [10^10 cm^-2]
	NVAR BC_VoidScatLengthDensity=root:Packages:Gels_Modeling:BC_VoidScatLengthDensity		//N2 [10^10 cm^-2]
	NVAR BC_LayerScatLengthDens=root:Packages:Gels_Modeling:BC_LayerScatLengthDens		//N3 [10^10 cm^-2]
	NVAR BC_CoatingsThickness=root:Packages:Gels_Modeling:BC_CoatingsThickness				//[A]
	NVAR SlitLength = root:Packages:Gels_Modeling:SlitLength	
	NVAR UseSlitSmearedData = root:Packages:Gels_Modeling:UseSlitSmearedData	
	// first Debye-Bueche theory
	//I(q) = (4*pi*K*eta^2*corrL^2)/(1+q^2*corrL^2)^2
	//K = 8*pi^2*n^2*lambda^-4
	// q = (4*pi*n/lambda)* sin(theta/2).
	//n=1
	
	variable DBK = 8 * pi^2 * DBWavelength^(-4)			//debye-bueche
	if(UseDB)
		DBTempInt1 = DBPrefactor*(4*pi*DBK*DBeta^2*DBcorrL^2)/(1+OriginalQvector^2*DBcorrL^2)^2
	else
		DBTempInt1 = 0
	endif
	if(UseLowQInDB)										//Unified
		QstarVector=OriginalQvector/(erf(OriginalQvector*LowQRg/sqrt(6)))^3	
		DBtempInt2=LowQRgPrefactor*exp(-OriginalQvector^2*LowQRg^2/3)+(LowQPrefactor/QstarVector^LowQslope)
		//DBtempInt2 = LowQPrefactor * OriginalQvector^(-1*LowQslope)
	else
		DBtempInt2 = 0
	endif

	if(UseTS)												//Treubner Stre
		DBTempIntTS = TSPrefactor / (TSAvalue + TSC1Value * OriginalQvector^2 + TSC2Value* OriginalQvector^4)
		TSCorrelationLength = 1/sqrt(0.5*sqrt(TSAvalue/TSC2Value)+TSC1Value/4/TSC2Value)
	//	xi = 0.5*sqrt(a2/c2) + c1/4/c2
	//	xi = 1/sqrt(xi)
		TSRepeatDistance = 2*pi/sqrt(0.5*sqrt(TSAvalue/TSC2Value) - TSC1Value/4/TSC2Value)
	//	dd = 0.5*sqrt(a2/c2) - c1/4/c2
	//	dd = 1/sqrt(dd)
	//	dd *=2*Pi
	else
		DBTempIntTS=0	
	endif

	//Ciccariello's  coated porous media
			//nu = (n13 - n32)/n12
			//where n13 =  N1 - N3 etc. 
			// nu = (n13 - n32)/n12 = (N1-2N2+N3)/(N1-N2) 
			variable n12 = BC_SolidScatLengthDensity*1e10 - BC_VoidScatLengthDensity*1e10
			variable NuValue = ((BC_SolidScatLengthDensity - 2*BC_LayerScatLengthDens + BC_VoidScatLengthDensity))/(BC_SolidScatLengthDensity - BC_VoidScatLengthDensity)
			variable ALpha = (1 + NuValue^2)/2
			variable Rnu = (1-NuValue^2)/(1+NuValue^2)
	//COMMON...
	//pinhole data or data with finite slit length
	if(UseCiccBen&&(!UseSlitSmearedData||(UseSlitSmearedData&&numtype(SlitLength)==0)))								//Ciccariello's  coated porous media
		//and now I(q) = (2*pi*n12^2*alpha*BC_PorodsSpecSurfArea / Q^4) * [1+Rnu*cos(Q*BC_CoatingsThickness)]+BC_MicroscDensFluctuations
		//print (2*pi*n12^2*alpha*BC_PorodsSpecSurfArea / (OriginalQvector[120]^4*1e32))		
		CiccBenModelIntensity = (2*pi*n12^2*alpha*BC_PorodsSpecSurfArea / (OriginalQvector^4*1e32)) * (1+Rnu*cos(OriginalQvector*BC_CoatingsThickness))
	else
		CiccBenModelIntensity=0
	endif
	
	
	
	DBTempInt3 = DBTempInt1 + DBtempInt2 + DBTempIntTS + CiccBenModelIntensity
	//slit smear with finite slit length...
	if(UseSlitSmearedData&&numtype(SlitLength)==0)
		//print "slit smeared"
		IR1B_SmearData(DBTempInt3, OriginalQvector, slitLength, DBModelIntensity)
	else
		DBModelIntensity= DBTempInt3	
	endif

	//and now deal with infinite slit length case for  Benedetti-Ciccariello model
	if(UseCiccBen&&(UseSlitSmearedData&&numtype(SlitLength)!=0))								//Ciccariello's  coated porous media
		//print (pi^2*n12^2*alpha*BC_PorodsSpecSurfArea / (OriginalQvector[120]^3*1e32))	
		CiccBenModelIntensity = (pi^2*n12^2*alpha*BC_PorodsSpecSurfArea / (OriginalQvector^3*1e32)) * (1+Rnu*IR2H_CiccBenFiFunction(OriginalQvector*BC_CoatingsThickness))
		DBModelIntensity= CiccBenModelIntensity
	endif


	
	DBModelIntensity = DBModelIntensity + SASBackground
	Duplicate/O OriginalQvector, OriginalQvector4, OriginalQvector3
	OriginalQvector4 = OriginalQvector^4
	OriginalQvector3 = OriginalQvector^3
	DBModelIntensityQ4= DBModelIntensity*OriginalQvector^4
	DBModelIntensityQ3= DBModelIntensity*OriginalQvector^3
	DBModelIntSqrtN1 = 1/(sqrt(DBModelIntensity))
	
	setDataFolder OldDf
end
//*****************************************************************************************************************

Function IR2H_CiccBenFiFunction(Xval)
	variable Xval
	variable result	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Gels_Modeling
	make/O/N=1 TWv1	
	TWv1={0.5}
	make/O/N=2 TWv2
	TWv2={2,2.5} 
	result =  1 - Xval^2 + (1/3)*XVal^3*hyperGPFQ(TWv1,TWv2, (-XVal^2/4))
	setDataFolder OldDf
	return result
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR2H_AppendModelToMeasuredData()
	//here we need to append waves with calculated intensities to the measured data

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Gels_Modeling

	DoWindow IR2H_LogLogPlotGels
	if(!V_flag)
		abort
	endif
	NVAR UseSlitSmearedData = root:Packages:Gels_Modeling:UseSlitSmearedData	
	
	Wave Intensity=root:Packages:Gels_Modeling:DBModelIntensity
	Wave QVec=root:Packages:Gels_Modeling:DBModelQvector
	Duplicate/O QVec, Qvec4, Qvec3
	Qvec4=Qvec^4
	Qvec3=Qvec^3
	Wave IQ4=root:Packages:Gels_Modeling:DBModelIntensityQ4
	Wave IQ3=root:Packages:Gels_Modeling:DBModelIntensityQ3
	Wave DBModelIntSqrtN1=root:Packages:Gels_Modeling:DBModelIntSqrtN1
	Wave OriginalQ2=root:Packages:Gels_Modeling:OriginalQ2
	Wave/Z NormalizedError=root:Packages:Gels_Modeling:NormalizedError
	Wave/Z NormErrorQvec=root:Packages:Gels_Modeling:NormErrorQvec
	
	DoWindow/F IR2H_LogLogPlotGels
	variable CsrAPos
	if (strlen(CsrWave(A))!=0)
		CsrAPos=pcsr(A)
	else
		CsrAPos=0
	endif
	variable CsrBPos
	if (strlen(CsrWave(B))!=0)
		CsrBPos=pcsr(B)
	else
		CsrBPos=numpnts(Intensity)-1
	endif
	
	RemoveFromGraph /Z/W=IR2H_LogLogPlotGels DBModelIntensity 
	RemoveFromGraph /Z/W=IR2H_LogLogPlotGels NormalizedError 
	RemoveFromGraph /Z/W=IR2H_IQ4_Q_PlotGels DBModelIntensityQ4 
	RemoveFromGraph /Z/W=IR2H_IQ4_Q_PlotGels DBModelIntensityQ3 
	RemoveFromGraph /Z/W=IR2H_SI_Q2_PlotGels DBModelIntSqrtN1 

	AppendToGraph/W=IR2H_LogLogPlotGels Intensity vs Qvec
	cursor/P/W=IR2H_LogLogPlotGels A, OriginalIntensity, CsrAPos	
	cursor/P/W=IR2H_LogLogPlotGels B, OriginalIntensity, CsrBPos	
	ModifyGraph/W=IR2H_LogLogPlotGels rgb(DBModelIntensity)=(0,0,0)
	ModifyGraph/W=IR2H_LogLogPlotGels mode(OriginalIntensity)=3
	ModifyGraph/W=IR2H_LogLogPlotGels msize(OriginalIntensity)=1
	ShowInfo/W=IR2H_LogLogPlotGels
	if (WaveExists(NormalizedError))
		AppendToGraph/R/W=IR2H_LogLogPlotGels NormalizedError vs NormErrorQvec
		ModifyGraph/W=IR2H_LogLogPlotGels  mode(NormalizedError)=3,marker(NormalizedError)=8
		ModifyGraph/W=IR2H_LogLogPlotGels zero(right)=4
		ModifyGraph/W=IR2H_LogLogPlotGels msize(NormalizedError)=1,rgb(NormalizedError)=(0,0,0)
		SetAxis/W=IR2H_LogLogPlotGels /A/E=2 right
		ModifyGraph/W=IR2H_LogLogPlotGels log(right)=0
		Label/W=IR2H_LogLogPlotGels right "Standardized residual"
	else
		ModifyGraph/W=IR2H_LogLogPlotGels mirror(left)=1
	endif
	ModifyGraph/W=IR2H_LogLogPlotGels log(left)=1
	ModifyGraph/W=IR2H_LogLogPlotGels log(bottom)=1
	ModifyGraph/W=IR2H_LogLogPlotGels mirror(bottom)=1
	Label/W=IR2H_LogLogPlotGels left "Intensity [cm\\S-1\\M]"
	Label/W=IR2H_LogLogPlotGels bottom "Q [A\\S-1\\M]"
	ErrorBars/W=IR2H_LogLogPlotGels OriginalIntensity Y,wave=(root:Packages:Gels_Modeling:OriginalError,root:Packages:Gels_Modeling:OriginalError)
	Legend/W=IR2H_LogLogPlotGels/N=text0/K
	Legend/W=IR2H_LogLogPlotGels/N=text0/J/F=0/A=MC/X=32.03/Y=38.79 "\\s(OriginalIntensity) Experimental intensity"
	AppendText/W=IR2H_LogLogPlotGels "\\s(DBModelIntensity) Model calculated Intensity"
	if (WaveExists(NormalizedError))
		AppendText/W=IR2H_LogLogPlotGels "\\s(NormalizedError) Standardized residual"
	endif

	if(UseSlitSmearedData)
		AppendToGraph/W=IR2H_IQ4_Q_PlotGels IQ3 vs Qvec
		checkdisplayed /W=IR2H_IQ4_Q_PlotGels OriginalIntQ3
		if(V_Flag)
			ErrorBars/W=IR2H_IQ4_Q_PlotGels OriginalIntQ3 Y,wave=(root:Packages:Gels_Modeling:OriginalErrQ3,root:Packages:Gels_Modeling:OriginalErrQ3)
			Label/W=IR2H_IQ4_Q_PlotGels left "Intensity * Q^3"
			Legend/W=IR2H_IQ4_Q_PlotGels/N=text0/K
			Legend/W=IR2H_IQ4_Q_PlotGels/N=text0/J/F=0/A=MC/X=-29.74/Y=37.76 "\\s(OriginalIntQ3) Experimental intensity * Q^3"
			AppendText/W=IR2H_IQ4_Q_PlotGels "\\s(DBModelIntensityQ3) Model Calculated intensity * Q^3"
			ModifyGraph/W=IR2H_IQ4_Q_PlotGels rgb(DBModelIntensityQ3)=(0,0,0)
			ModifyGraph/W=IR2H_IQ4_Q_PlotGels mode(DBModelIntensityQ3)=0
		endif
	else
		AppendToGraph/W=IR2H_IQ4_Q_PlotGels IQ4 vs Qvec
		checkdisplayed /W=IR2H_IQ4_Q_PlotGels OriginalIntQ4
		if(V_Flag)
			ErrorBars/W=IR2H_IQ4_Q_PlotGels OriginalIntQ4 Y,wave=(root:Packages:Gels_Modeling:OriginalErrQ4,root:Packages:Gels_Modeling:OriginalErrQ4)
			Label/W=IR2H_IQ4_Q_PlotGels left "Intensity * Q^4"
			Legend/W=IR2H_IQ4_Q_PlotGels/N=text0/K
			Legend/W=IR2H_IQ4_Q_PlotGels/N=text0/J/F=0/A=MC/X=-29.74/Y=37.76 "\\s(OriginalIntQ4) Experimental intensity * Q^4"
			AppendText/W=IR2H_IQ4_Q_PlotGels "\\s(DBModelIntensityQ4) Model Calculated intensity * Q^4"
			ModifyGraph/W=IR2H_IQ4_Q_PlotGels rgb(DBModelIntensityQ4)=(0,0,0)
			ModifyGraph/W=IR2H_IQ4_Q_PlotGels mode(DBModelIntensityQ4)=0
		endif
	endif
	ModifyGraph/W=IR2H_IQ4_Q_PlotGels mode=3
	ModifyGraph/W=IR2H_IQ4_Q_PlotGels msize=1
	ModifyGraph/W=IR2H_IQ4_Q_PlotGels log=0
	ModifyGraph/W=IR2H_IQ4_Q_PlotGels mirror=1
	Label/W=IR2H_IQ4_Q_PlotGels bottom "Q [A\\S-1\\M]"

	AppendToGraph/W=IR2H_SI_Q2_PlotGels DBModelIntSqrtN1 vs OriginalQ2
	ModifyGraph/W=IR2H_SI_Q2_PlotGels rgb(DBModelIntSqrtN1)=(0,0,0)
	ModifyGraph/W=IR2H_SI_Q2_PlotGels mode(DBModelIntSqrtN1)=3
	ModifyGraph/W=IR2H_SI_Q2_PlotGels msize=1
	ModifyGraph/W=IR2H_SI_Q2_PlotGels log=0
	ModifyGraph/W=IR2H_SI_Q2_PlotGels mirror=1
	ModifyGraph/W=IR2H_SI_Q2_PlotGels mode(DBModelIntSqrtN1)=0
	Label/W=IR2H_SI_Q2_PlotGels left "1/sqrt(Intensity)"
	Label/W=IR2H_SI_Q2_PlotGels bottom "Q^2 [A\\S-2\\M]"
	ErrorBars/W=IR2H_SI_Q2_PlotGels OriginalSqrtIntN1 Y,wave=(root:Packages:Gels_Modeling:OriginalSqrtErrN1,root:Packages:Gels_Modeling:OriginalSqrtErrN1)
	Legend/W=IR2H_SI_Q2_PlotGels/N=text0/K
	Legend/W=IR2H_SI_Q2_PlotGels/N=text0/J/F=0/A=MC/X=-29.74/Y=37.76 "\\s(OriginalSqrtIntN1) Experimental intensity ^ -(1/2)"
	AppendText/W=IR2H_SI_Q2_PlotGels "\\s(DBModelIntSqrtN1) Model Calculated intensity ^-(1/2)"

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

static Function IR2H_GraphMeasuredData()
	//this function graphs data into the various graphs as needed
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Gels_Modeling
	SVAR DataFolderName
	SVAR IntensityWaveName
	SVAR QWavename
	SVAR ErrorWaveName
	variable cursorAposition, cursorBposition
	NVAR DBWavelength=root:Packages:Gels_Modeling:DBWavelength
	NVAR UseSlitSmearedData=root:Packages:Gels_Modeling:UseSlitSmearedData
	NVAR SlitLength=root:Packages:Gels_Modeling:SlitLength
	
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
	if(UseSlitSmearedData)
		variable tempSL=NumberByKey("SlitLength", note(OriginalIntensity) , "=" , ";")
		if(numtype(tempSL)==0)
			SlitLength=tempSL
		endif
	endif
	variable originalWvlngth=DBWavelength
	variable tempWavelength=NumberByKey("Wavelength", note(OriginalIntensity) , "=" , ";")
	DBWavelength=tempWavelength
	if(numtype(tempWavelength)!=0)
		tempWavelength=NumberByKey("Wavelength", note(OriginalIntensity))
		DBWavelength=tempWavelength
	endif
	if(numtype(tempWavelength)!=0)
		tempWavelength=12.4/NumberByKey("energy", note(OriginalIntensity) , "=" , ";")
		DBWavelength=tempWavelength
	endif
	if(numtype(tempWavelength)!=0)
		tempWavelength=12.4/NumberByKey("energy", note(OriginalIntensity))
		DBWavelength=tempWavelength
	endif
	if(numtype(tempWavelength)!=0)
		DBWavelength=1
	elseif(originalWvlngth==0)
		DBWavelength=originalWvlngth
	endif
	
	
		DoWindow IR2H_LogLogPlotGels
		if (V_flag)
			cursorAposition=pcsr(A,"IR2H_LogLogPlotGels")
			cursorBposition=pcsr(B,"IR2H_LogLogPlotGels")
			Dowindow/K IR2H_LogLogPlotGels
		endif
		Execute ("IR2H_LogLogPlotGels()")
		cursor/P/W=IR2H_LogLogPlotGels A, OriginalIntensity,cursorAposition
		cursor/P/W=IR2H_LogLogPlotGels B, OriginalIntensity,cursorBposition
	
	Duplicate/O $(DataFolderName+IntensityWaveName), OriginalIntQ4, OriginalIntQ3
	Duplicate/O $(DataFolderName+QWavename), OriginalQ4, OriginalQ3
	Duplicate/O $(DataFolderName+ErrorWaveName), OriginalErrQ4, OriginalErrQ3
	Redimension/D OriginalIntQ4, OriginalQ4, OriginalErrQ4, OriginalQ3, OriginalErrQ3

	
	OriginalQ4=OriginalQ4^4
	OriginalQ3=OriginalQ3^3
	OriginalIntQ4=OriginalIntQ4*OriginalQ4
	OriginalErrQ4=OriginalErrQ4*OriginalQ4
	OriginalIntQ3=OriginalIntQ3*OriginalQ3
	OriginalErrQ3=OriginalErrQ3*OriginalQ3

		DoWindow IR2H_IQ4_Q_PlotGels
		if (V_flag)
			Dowindow/K IR2H_IQ4_Q_PlotGels
		endif
		Execute ("IR2H_IQ4_Q_PlotGels()")

	Duplicate/O $(DataFolderName+IntensityWaveName), OriginalSqrtIntN1
	Duplicate/O $(DataFolderName+QWavename), OriginalQ2
	Duplicate/O $(DataFolderName+ErrorWaveName), OriginalSqrtErrN1
	Redimension/D OriginalSqrtIntN1, OriginalQ2, OriginalSqrtErrN1

	
	OriginalQ2=OriginalQ2^2
	OriginalSqrtIntN1=1/sqrt(OriginalSqrtIntN1)
	OriginalSqrtErrN1=OriginalSqrtIntN1 * (OriginalError/OriginalIntensity)
	
		DoWindow IR2H_SI_Q2_PlotGels
		if (V_flag)
			Dowindow/K IR2H_SI_Q2_PlotGels
		endif
		Execute ("IR2H_SI_Q2_PlotGels()")
	setDataFolder oldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Proc  IR2H_SI_Q2_PlotGels() 
	PauseUpdate; Silent 1		// building window...
	String fldrSav= GetDataFolder(1)
	SetDataFolder root:Packages:Gels_Modeling:
	Display /W=(283.5,384,761.25,545)/K=1  OriginalSqrtIntN1 vs OriginalQ2 as "DB_Plot"
	DoWIndow/C IR2H_SI_Q2_PlotGels
	ModifyGraph mode(OriginalSqrtIntN1)=3
	ModifyGraph msize(OriginalSqrtIntN1)=1
	ModifyGraph log=0
	ModifyGraph mirror=1
	Label left "1/sqrt(Intensity)"
	Label bottom "Q^2 [A\\S-2\\M]"
	ErrorBars/Y=1 OriginalSqrtIntN1 Y,wave=(OriginalSqrtErrN1,OriginalSqrtErrN1)
	ShowInfo
	TextBox/W=IR2H_SI_Q2_PlotGels/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	TextBox/W=IR2H_SI_Q2_PlotGels/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z07"+DataFolderName+IntensityWaveName	
//	Cursor /P /W=IR2H_SI_Q2_PlotGels A, OriginalSqrtIntN1  0 
//	Cursor /P /W=IR2H_SI_Q2_PlotGels B, OriginalSqrtIntN1  (numpnts(OriginalSqrtIntN1)-1)
	SetDataFolder fldrSav
	//and now some controls
//	ControlBar 30
//	Button SaveStyle size={80,20}, pos={50,5},proc=IR1U_StyleButtonCotrol,title="Save Style"
//	Button ApplyStyle size={80,20}, pos={150,5},proc=IR1U_StyleButtonCotrol,title="Apply Style"
EndMacro


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Proc  IR2H_IQ4_Q_PlotGels() 
	PauseUpdate; Silent 1		// building window...
	String fldrSav= GetDataFolder(1)
	SetDataFolder root:Packages:Gels_Modeling:
//	 UseSlitSmearedData = root:Packages:Gels_Modeling:UseSlitSmearedData	
	Display /W=(283.5,228.5,761.25,383)/K=1  as "Mod. Porod Plot"
	DoWindow/C IR2H_IQ4_Q_PlotGels
	if(UseSlitSmearedData)
		 Append OriginalIntQ3 vs OriginalQvector
		ErrorBars/Y=1 OriginalIntQ3 Y,wave=(root:Packages:Gels_Modeling:OriginalErrQ3,root:Packages:Gels_Modeling:OriginalErrQ3)
		ModifyGraph mode(OriginalIntQ3)=3
		ModifyGraph msize(OriginalIntQ3)=1
	else
		 Append OriginalIntQ4 vs OriginalQvector
		ErrorBars/Y=1 OriginalIntQ4 Y,wave=(root:Packages:Gels_Modeling:OriginalErrQ4,root:Packages:Gels_Modeling:OriginalErrQ4)
		ModifyGraph mode(OriginalIntQ4)=3
		ModifyGraph msize(OriginalIntQ4)=1
	endif
	TextBox/W=IR2H_IQ4_Q_PlotGels/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	TextBox/W=IR2H_IQ4_Q_PlotGels/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z07"+DataFolderName+IntensityWaveName	
	ModifyGraph log=0
	ModifyGraph mirror=1
	if(UseSlitSmearedData)
		 Label left "Intensity * Q^3"
	else
		 Label left "Intensity * Q^4"
	endif
	Label bottom "Q [A\\S-1\\M]"
	SetDataFolder fldrSav
	//and now some controls
//	ControlBar 30
//	Button SaveStyle size={80,20}, pos={50,5},proc=IR1U_StyleButtonCotrol,title="Save Style"
//	Button ApplyStyle size={80,20}, pos={150,5},proc=IR1U_StyleButtonCotrol,title="Apply Style"
EndMacro

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Proc  IR2H_LogLogPlotGels() 
	PauseUpdate; Silent 1		// building window...
	String fldrSav= GetDataFolder(1)
	SetDataFolder root:Packages:Gels_Modeling:
	Display /W=(282.75,37.25,759.75,208.25)/K=1  OriginalIntensity vs OriginalQvector as "LogLogPlot"
	DoWIndow/C IR2H_LogLogPlotGels
	ModifyGraph mode(OriginalIntensity)=3
	ModifyGraph msize(OriginalIntensity)=1
	ModifyGraph log=1
	ModifyGraph mirror=1
	ShowInfo
	Label left "Intensity [cm\\S-1\\M]"
	Label bottom "Q [A\\S-1\\M]"
	Legend/W=IR2H_LogLogPlotGels /N=text0/J/F=0/A=MC/X=32.03/Y=38.79 "\\s(OriginalIntensity) Experimental intensity"
	TextBox/W=IR2H_LogLogPlotGels/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	TextBox/W=IR2H_LogLogPlotGels/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z07"+DataFolderName+IntensityWaveName	
	SetDataFolder fldrSav
	ErrorBars/Y=1 OriginalIntensity Y,wave=(root:Packages:Gels_Modeling:OriginalError,root:Packages:Gels_Modeling:OriginalError)
	//and now some controls
//	ControlBar 30
//	Button SaveStyle size={80,20}, pos={50,5},proc=IR1U_StyleButtonCotrol,title="Save Style"
//	Button ApplyStyle size={80,20}, pos={150,5},proc=IR1U_StyleButtonCotrol,title="Apply Style"
EndMacro

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2H_TabPanelControl(name,tab)
	String name
	Variable tab

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Gels_Modeling

	NVAR CurrentTab=root:Packages:Gels_Modeling:CurrentTab
	CurrentTab=tab
	NVAR UseUnif=root:Packages:Gels_Modeling:UseLowQInDB
	
	CheckBox UseLowQInDB, disable= (tab!=0), win=IR2H_ControlPanel
	SetVariable LowQRgPrefactor, disable= (tab!=0 || UseUnif==0), win=IR2H_ControlPanel
	SetVariable LowQRg, disable= (tab!=0 || UseUnif==0), win=IR2H_ControlPanel
	SetVariable LowQPrefactor, disable= (tab!=0 || UseUnif==0), win=IR2H_ControlPanel
	SetVariable LowQslope, disable= (tab!=0 || UseUnif==0), win=IR2H_ControlPanel
	Button EstimateLowQ, disable= (tab!=0 || UseUnif==0), win=IR2H_ControlPanel
	SetVariable LowQPrefactorLowLimit, disable= (tab!=0 || UseUnif==0), win=IR2H_ControlPanel
	SetVariable LowQPrefactorHighLimit, disable= (tab!=0 || UseUnif==0), win=IR2H_ControlPanel
	SetVariable LowQslopeLowLimit, disable= (tab!=0 || UseUnif==0), win=IR2H_ControlPanel
	SetVariable LowQslopeHighLimit, disable= (tab!=0 || UseUnif==0), win=IR2H_ControlPanel
	CheckBox FitLowQPrefactor, disable= (tab!=0 || UseUnif==0), win=IR2H_ControlPanel
	CheckBox FitLowQslope, disable= (tab!=0 || UseUnif==0), win=IR2H_ControlPanel
	SetVariable LowQRgPrefactorLowLimit, disable= (tab!=0 || UseUnif==0), win=IR2H_ControlPanel
	SetVariable LowQRgPrefactorHighLimit, disable= (tab!=0 || UseUnif==0), win=IR2H_ControlPanel
	SetVariable LowQRgLowLimit, disable= (tab!=0 || UseUnif==0), win=IR2H_ControlPanel
	SetVariable LowQRgHighLimit, disable= (tab!=0 || UseUnif==0), win=IR2H_ControlPanel
	CheckBox FitLowQRgPrefactor, disable= (tab!=0 || UseUnif==0), win=IR2H_ControlPanel
	CheckBox FitLowQRg, disable= (tab!=0 || UseUnif==0), win=IR2H_ControlPanel


	NVAR UseDB=root:Packages:Gels_Modeling:UseDB
	CheckBox UseDB, disable= (tab!=1), win=IR2H_ControlPanel
	SetVariable DBEta, disable= (tab!=1 || UseDB==0), win=IR2H_ControlPanel
	SetVariable DBcorrL, disable= (tab!=1 || UseDB==0), win=IR2H_ControlPanel
	Button EstimateCorrL, disable= (tab!=1 || UseDB==0), win=IR2H_ControlPanel
	SetVariable DBEtaLowLimit, disable= (tab!=1 || UseDB==0), win=IR2H_ControlPanel
	SetVariable DBEtaHighLimit, disable= (tab!=1 || UseDB==0), win=IR2H_ControlPanel
	SetVariable DBcorrLLowLimit, disable= (tab!=1 || UseDB==0), win=IR2H_ControlPanel
	SetVariable DBcorrLHighLimit, disable= (tab!=1 || UseDB==0), win=IR2H_ControlPanel
	CheckBox FitDBEta, disable= (tab!=1 || UseDB==0), win=IR2H_ControlPanel
	CheckBox FitDBcorrL, disable= (tab!=1 || UseDB==0), win=IR2H_ControlPanel
	SetVariable DBWavelength, disable= (tab!=1 || UseDB==0), win=IR2H_ControlPanel

	NVAR UseTS=root:Packages:Gels_Modeling:UseTS
	CheckBox UseTS, disable= (tab!=2), win=IR2H_ControlPanel
	SetVariable TSPrefactor, disable= (tab!=2 || UseTS==0), win=IR2H_ControlPanel
	SetVariable TSAvalue, disable= (tab!=2 || UseTS==0), win=IR2H_ControlPanel
	SetVariable TSC1Value, disable= (tab!=2 || UseTS==0), win=IR2H_ControlPanel
	SetVariable TSC2Value, disable= (tab!=2 || UseTS==0), win=IR2H_ControlPanel
	SetVariable TSPrefactorLowLimit, disable= (tab!=2 || UseTS==0), win=IR2H_ControlPanel
	SetVariable TSPrefactorHighLimit, disable= (tab!=2 || UseTS==0), win=IR2H_ControlPanel
	CheckBox FitTSPrefactor, disable= (tab!=2 || UseTS==0), win=IR2H_ControlPanel
	SetVariable TSAvalueLowLimit, disable= (tab!=2 || UseTS==0), win=IR2H_ControlPanel
	SetVariable TSAvalueHighLimit, disable= (tab!=2 || UseTS==0), win=IR2H_ControlPanel
	CheckBox FitTSAvalue, disable= (tab!=2 || UseTS==0), win=IR2H_ControlPanel
	SetVariable TSC1ValueLowLimit, disable= (tab!=2 || UseTS==0), win=IR2H_ControlPanel
	SetVariable TSC1ValueHighLimit, disable= (tab!=2 || UseTS==0), win=IR2H_ControlPanel
	CheckBox FitTSC1Value, disable= (tab!=2 || UseTS==0), win=IR2H_ControlPanel
	SetVariable TSC2ValueLowLimit, disable= (tab!=2 || UseTS==0), win=IR2H_ControlPanel
	SetVariable TSC2ValueHighLimit, disable= (tab!=2 || UseTS==0), win=IR2H_ControlPanel
	CheckBox FitTSC2Value, disable= (tab!=2 || UseTS==0), win=IR2H_ControlPanel
	SetVariable TSCorrelationLength, disable= (tab!=2 || UseTS==0), win=IR2H_ControlPanel
	SetVariable TSRepeatDistance, disable= (tab!=2 || UseTS==0), win=IR2H_ControlPanel

	NVAR UseCiccBen=root:Packages:Gels_Modeling:UseCiccBen

	CheckBox UseCiccBen,disable= (tab!=3), win=IR2H_ControlPanel
	SetVariable BC_PorodsSpecSurfArea,disable= (tab!=3 || UseCiccBen==0), win=IR2H_ControlPanel
	SetVariable BC_SolidScatLengthDensity,disable= (tab!=3 || UseCiccBen==0), win=IR2H_ControlPanel
	SetVariable BC_VoidScatLengthDensity,disable= (tab!=3 || UseCiccBen==0), win=IR2H_ControlPanel
	SetVariable BC_LayerScatLengthDens,disable= (tab!=3 || UseCiccBen==0), win=IR2H_ControlPanel
	SetVariable BC_CoatingsThickness,disable= (tab!=3 || UseCiccBen==0), win=IR2H_ControlPanel

	SetVariable BC_PorodsSpecSurfAreaLL,disable= (tab!=3 || UseCiccBen==0), win=IR2H_ControlPanel
	SetVariable BC_PorodsSpecSurfAreaHL,disable= (tab!=3 || UseCiccBen==0), win=IR2H_ControlPanel
	CheckBox FitBC_PorodsSpecSurfArea,disable= (tab!=3 || UseCiccBen==0), win=IR2H_ControlPanel

	SetVariable BC_LayerScatLengthDensLL,disable= (tab!=3 || UseCiccBen==0), win=IR2H_ControlPanel
	SetVariable BC_LayerScatLengthDensHL,disable= (tab!=3 || UseCiccBen==0), win=IR2H_ControlPanel
	CheckBox FitBC_LayerScatLengthDens,disable= (tab!=3 || UseCiccBen==0), win=IR2H_ControlPanel

	SetVariable BC_CoatingsThicknessLL,disable= (tab!=3 || UseCiccBen==0), win=IR2H_ControlPanel
	SetVariable BC_CoatingsThicknessHL,disable= (tab!=3 || UseCiccBen==0), win=IR2H_ControlPanel
	CheckBox FitBC_CoatingsThickness,disable= (tab!=3 || UseCiccBen==0), win=IR2H_ControlPanel

	setDataFolder oldDF

End



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR2H_FixTabsInPanel()
	//here we modify the panel, so it reflects the selected number of distributions
	
	NVAR CurrentTab=root:Packages:Gels_Modeling:CurrentTab
	IR2H_TabPanelControl("DistTabs",CurrentTab)
	variable SetToTab
	SetToTab=CurrentTab
	if(SetToTab<0)
		SetToTab=0
	endif
	TabControl DistTabs,value= SetToTab, win=IR2H_ControlPanel

end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2H_PanelSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Gels_Modeling
	

	if (cmpstr(ctrlName,"BC_PorodsSpecSurfArea")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR2H_AutoUpdateIfSelected()
		NVAR myval = root:Packages:Gels_Modeling:BC_PorodsSpecSurfArea
		SetVariable BC_PorodsSpecSurfArea,win=IR2H_ControlPanel, limits={0,inf,myval/20}
	endif
	if (cmpstr(ctrlName,"BC_SolidScatLengthDensity")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR2H_AutoUpdateIfSelected()
		NVAR myval = root:Packages:Gels_Modeling:BC_SolidScatLengthDensity
		SetVariable BC_SolidScatLengthDensity,win=IR2H_ControlPanel, limits={0,inf,myval/20}
	endif
	if (cmpstr(ctrlName,"BC_VoidScatLengthDensity")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR2H_AutoUpdateIfSelected()
		NVAR myval = root:Packages:Gels_Modeling:BC_VoidScatLengthDensity
		SetVariable BC_VoidScatLengthDensity,win=IR2H_ControlPanel, limits={0,inf,myval/20}
	endif
	if (cmpstr(ctrlName,"BC_LayerScatLengthDens")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR2H_AutoUpdateIfSelected()
		NVAR myval = root:Packages:Gels_Modeling:BC_LayerScatLengthDens
		SetVariable BC_LayerScatLengthDens,win=IR2H_ControlPanel, limits={0,inf,myval/20}
	endif
	if (cmpstr(ctrlName,"BC_CoatingsThickness")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR2H_AutoUpdateIfSelected()
		NVAR myval = root:Packages:Gels_Modeling:BC_CoatingsThickness
		SetVariable BC_CoatingsThickness,win=IR2H_ControlPanel, limits={0,inf,myval/20}
	endif
	if (cmpstr(ctrlName,"SASBackground")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR2H_AutoUpdateIfSelected()
		NVAR myval = root:Packages:Gels_Modeling:SASBackground
		SetVariable SASBackground,win=IR2H_ControlPanel, limits={-inf,inf,myval/20}
	endif
	if (cmpstr(ctrlName,"SASBackgroundStep")==0)
		//here goes what happens when user changes the SASBackground in distribution
		SetVariable SASBackground,win=IR2H_ControlPanel, limits={0,Inf,varNum}
	endif	
	if (cmpstr(ctrlName,"DBPrefactor")==0)
		//here goes what happens when user changes the contrast
		IR2H_AutoUpdateIfSelected()
		NVAR myval = root:Packages:Gels_Modeling:DBPrefactor
		SetVariable DBPrefactor,win=IR2H_ControlPanel, limits={1e-20,inf,myval/20}
	endif
	if (cmpstr(ctrlName,"DBEta")==0)
		//here goes what happens when user changes the location
		IR2H_AutoUpdateIfSelected()
		NVAR myval = root:Packages:Gels_Modeling:DBEta
		SetVariable DBEta,win=IR2H_ControlPanel, limits={1e-20,inf,myval/20}
	endif
	if (cmpstr(ctrlName,"DBcorrL")==0)
		//here goes what happens when user changes the scale
		IR2H_AutoUpdateIfSelected()
		NVAR myval = root:Packages:Gels_Modeling:DBcorrL
		SetVariable DBcorrL,win=IR2H_ControlPanel, limits={10,inf,myval/20}
	endif
	
	if (cmpstr(ctrlName,"DBWavelength")==0)
		//here goes what happens when user changes the shape
		IR2H_AutoUpdateIfSelected()
		NVAR myval = root:Packages:Gels_Modeling:DBWavelength
		SetVariable DBWavelength,win=IR2H_ControlPanel, limits={1e-3,100,myval/20}
	endif
	if (cmpstr(ctrlName,"LowQPrefactor")==0)
		//here goes what happens when user changes the volume in distribution
		IR2H_AutoUpdateIfSelected()
		NVAR myval = root:Packages:Gels_Modeling:LowQPrefactor
		SetVariable LowQPrefactor,win=IR2H_ControlPanel, limits={0,inf,myval/20}
	endif
	if (cmpstr(ctrlName,"LowQslope")==0)
		//here goes what happens when user changes the volume in distribution
		IR2H_AutoUpdateIfSelected()
		NVAR myval = root:Packages:Gels_Modeling:LowQslope
		SetVariable LowQslope,win=IR2H_ControlPanel, limits={0.1,5,myval/20}
	endif
	if (cmpstr(ctrlName,"LowQRgPrefactor")==0)
		//here goes what happens when user changes the volume in distribution
		NVAR G=root:Packages:Gels_Modeling:LowQRgPrefactor
		if(G<=0)
			NVAR RG=root:Packages:Gels_Modeling:LowQRg
			NVAR FitG=root:Packages:Gels_Modeling:FitLowQRgPrefactor
			NVAR FitRG=root:Packages:Gels_Modeling:FitLowQRg
			RG=1e10
			G=0
			FitG=0
			FitRg=0
		endif
		IR2H_AutoUpdateIfSelected()
		NVAR myval = root:Packages:Gels_Modeling:LowQRgPrefactor
		SetVariable LowQRgPrefactor,win=IR2H_ControlPanel, limits={-inf,inf,myval/20}
	endif
	if (cmpstr(ctrlName,"LowQRg")==0)
		//here goes what happens when user changes the volume in distribution
		NVAR RG=root:Packages:Gels_Modeling:LowQRg
		if(RG>=1e10)
			NVAR G=root:Packages:Gels_Modeling:LowQRgPrefactor
			NVAR FitG=root:Packages:Gels_Modeling:FitLowQRgPrefactor
			NVAR FitRG=root:Packages:Gels_Modeling:FitLowQRg
			G=0
			FitG=0
			FitRg=0
			Rg=1e10
		endif
		IR2H_AutoUpdateIfSelected()
		NVAR myval = root:Packages:Gels_Modeling:LowQRg
		SetVariable LowQRg,win=IR2H_ControlPanel, limits={1,inf,myval/20}
	endif
	if (cmpstr(ctrlName,"TSPrefactor")==0)
		//here goes what happens when user changes the volume in distribution
		IR2H_AutoUpdateIfSelected()
		NVAR myval = root:Packages:Gels_Modeling:TSPrefactor
		SetVariable TSPrefactor,win=IR2H_ControlPanel, limits={-inf,inf,myval/20}
	endif
	if (cmpstr(ctrlName,"TSAvalue")==0)
		//here goes what happens when user changes the volume in distribution
		IR2H_AutoUpdateIfSelected()
		NVAR myval = root:Packages:Gels_Modeling:TSAvalue
		SetVariable TSAvalue,win=IR2H_ControlPanel, limits={1e-10,inf,myval/20}
	endif
	if (cmpstr(ctrlName,"TSC1Value")==0)
		//here goes what happens when user changes the volume in distribution
		IR2H_AutoUpdateIfSelected()
		NVAR myval = root:Packages:Gels_Modeling:TSC1Value
		SetVariable TSC1Value,win=IR2H_ControlPanel, limits={-inf,inf,myval/20}
	endif
	if (cmpstr(ctrlName,"TSC2Value")==0)
		//here goes what happens when user changes the volume in distribution
		IR2H_AutoUpdateIfSelected()
		NVAR myval = root:Packages:Gels_Modeling:TSC2Value
		SetVariable TSC2Value,win=IR2H_ControlPanel, limits={-inf,inf,myval/20}
	endif
//	if (cmpstr(ctrlName,"LowQslope")==0)
//		//here goes what happens when user changes the volume in distribution
//		IR2H_AutoUpdateIfSelected()
//		NVAR myval = root:Packages:Gels_Modeling:LowQslope
//		SetVariable LowQslope,win=IR2H_ControlPanel, limits={0.1,5,myval/20}
//	endif

		NVAR RG=root:Packages:Gels_Modeling:LowQRg
		NVAR G=root:Packages:Gels_Modeling:LowQRgPrefactor
		if(RG>=1e10 && G<=0)
			NVAR FitG=root:Packages:Gels_Modeling:FitLowQRgPrefactor
			NVAR FitRG=root:Packages:Gels_Modeling:FitLowQRg
			G=0
			FitG=0
			FitRg=0
			Rg=1e10
		endif

//		IR2H_AutoUpdateIfSelected()
	DoWindow/F IR2H_ControlPanel
	setDataFolder oldDF
End


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR2H_AutoUpdateIfSelected()
	
	NVAR UpdateAutomatically=root:Packages:Gels_Modeling:UpdateAutomatically
	if (UpdateAutomatically)
		IR2H_GraphModelData()
	endif
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

static Function IR2H_ConstructTheFittingCommand()
	//here we need to construct the fitting command and prepare the data for fit...

	string OldDF=GetDataFolder(1)
	setDataFolder root:Packages:Gels_Modeling

	NVAR SASBackground=root:Packages:Gels_Modeling:SASBackground
	NVAR FitSASBackground=root:Packages:Gels_Modeling:FitSASBackground
	NVAR UseSlitSmearedData = root:Packages:Gels_Modeling:UseSlitSmearedData
	
	NVAR DBEta=root:Packages:Gels_Modeling:DBEta
	NVAR DBcorrL=root:Packages:Gels_Modeling:DBcorrL
	NVAR LowQslope=root:Packages:Gels_Modeling:LowQslope
	NVAR LowQPrefactor=root:Packages:Gels_Modeling:LowQPrefactor
	
	NVAR FitDBPrefactor=root:Packages:Gels_Modeling:FitDBPrefactor
	NVAR FitDBEta=root:Packages:Gels_Modeling:FitDBEta
	NVAR FitDBcorrL=root:Packages:Gels_Modeling:FitDBcorrL
	NVAR FitLowQslope=root:Packages:Gels_Modeling:FitLowQslope
	NVAR FitLowQPrefactor=root:Packages:Gels_Modeling:FitLowQPrefactor
	
	NVAR DBPrefactorHighLimit=root:Packages:Gels_Modeling:DBPrefactorHighLimit
	NVAR DBPrefactorLowLimit=root:Packages:Gels_Modeling:DBPrefactorLowLimit
	
	NVAR DBEtaHighLimit=root:Packages:Gels_Modeling:DBEtaHighLimit
	NVAR DBEtaLowLimit=root:Packages:Gels_Modeling:DBEtaLowLimit
	
	NVAR DBcorrLHighLimit=root:Packages:Gels_Modeling:DBcorrLHighLimit
	NVAR DBcorrLLowLimit=root:Packages:Gels_Modeling:DBcorrLLowLimit

	NVAR LowQslopeHighLimit=root:Packages:Gels_Modeling:LowQslopeHighLimit
	NVAR LowQslopeLowLimit=root:Packages:Gels_Modeling:LowQslopeLowLimit
	
	NVAR LowQPrefactorHighLimit=root:Packages:Gels_Modeling:LowQPrefactorHighLimit
	NVAR LowQPrefactorLowLimit=root:Packages:Gels_Modeling:LowQPrefactorLowLimit
	NVAR UseLowQInDB=root:Packages:Gels_Modeling:UseLowQInDB
	NVAR UseDB=root:Packages:Gels_Modeling:UseDB
	NVAR UseTS=root:Packages:Gels_Modeling:UseTS


	NVAR LowQRgPrefactor=root:Packages:Gels_Modeling:LowQRgPrefactor
	NVAR LowQRgPrefactorLowLimit=root:Packages:Gels_Modeling:LowQRgPrefactorLowLimit
	NVAR LowQRgPrefactorHighLimit=root:Packages:Gels_Modeling:LowQRgPrefactorHighLimit
	NVAR FitLowQRgPrefactor=root:Packages:Gels_Modeling:FitLowQRgPrefactor

	NVAR LowQRg=root:Packages:Gels_Modeling:LowQRg
	NVAR LowQRgLowLimit=root:Packages:Gels_Modeling:LowQRgLowLimit
	NVAR LowQRgHighLimit=root:Packages:Gels_Modeling:LowQRgHighLimit
	NVAR FitLowQRg=root:Packages:Gels_Modeling:FitLowQRg

	NVAR TSPrefactor=root:Packages:Gels_Modeling:TSPrefactor
	NVAR TSPrefactorLowLimit=root:Packages:Gels_Modeling:TSPrefactorLowLimit
	NVAR TSPrefactorHighLimit=root:Packages:Gels_Modeling:TSPrefactorHighLimit
	NVAR FitTSPrefactor=root:Packages:Gels_Modeling:FitTSPrefactor

	NVAR TSAvalue=root:Packages:Gels_Modeling:TSAvalue
	NVAR TSAvalueLowLimit=root:Packages:Gels_Modeling:TSAvalueLowLimit
	NVAR TSAvalueHighLimit=root:Packages:Gels_Modeling:TSAvalueHighLimit
	NVAR FitTSAvalue=root:Packages:Gels_Modeling:FitTSAvalue

	NVAR TSC1Value=root:Packages:Gels_Modeling:TSC1Value
	NVAR TSC1ValueLowLimit=root:Packages:Gels_Modeling:TSC1ValueLowLimit
	NVAR TSC1ValueHighLimit=root:Packages:Gels_Modeling:TSC1ValueHighLimit
	NVAR FitTSC1Value=root:Packages:Gels_Modeling:FitTSC1Value

	NVAR TSC2Value=root:Packages:Gels_Modeling:TSC2Value
	NVAR TSC2ValueLowLimit=root:Packages:Gels_Modeling:TSC2ValueLowLimit
	NVAR TSC2ValueHighLimit=root:Packages:Gels_Modeling:TSC2ValueHighLimit
	NVAR FitTSC2Value=root:Packages:Gels_Modeling:FitTSC2Value

	NVAR UseCiccBen=root:Packages:Gels_Modeling:UseCiccBen
	NVAR BC_PorodsSpecSurfArea=root:Packages:Gels_Modeling:BC_PorodsSpecSurfArea
	NVAR BC_PorodsSpecSurfAreaLL=root:Packages:Gels_Modeling:BC_PorodsSpecSurfAreaLL
	NVAR BC_PorodsSpecSurfAreaHL=root:Packages:Gels_Modeling:BC_PorodsSpecSurfAreaHL
	NVAR FitBC_PorodsSpecSurfArea=root:Packages:Gels_Modeling:FitBC_PorodsSpecSurfArea

	NVAR BC_LayerScatLengthDens=root:Packages:Gels_Modeling:BC_LayerScatLengthDens
	NVAR BC_LayerScatLengthDensLL=root:Packages:Gels_Modeling:BC_LayerScatLengthDensLL
	NVAR BC_LayerScatLengthDensHL=root:Packages:Gels_Modeling:BC_LayerScatLengthDensHL
	NVAR FitBC_LayerScatLengthDens=root:Packages:Gels_Modeling:FitBC_LayerScatLengthDens

	NVAR BC_CoatingsThickness=root:Packages:Gels_Modeling:BC_CoatingsThickness
	NVAR BC_CoatingsThicknessLL=root:Packages:Gels_Modeling:BC_CoatingsThicknessLL
	NVAR BC_CoatingsThicknessHL=root:Packages:Gels_Modeling:BC_CoatingsThicknessHL
	NVAR FitBC_CoatingsThickness=root:Packages:Gels_Modeling:FitBC_CoatingsThickness

	Make/D/N=0/O W_coef
	Make/T/N=0/O CoefNames
	Make/D/O/T/N=0 T_Constraints
	T_Constraints=""
	CoefNames=""
	
	if (FitSASBackground)		//are we fitting background?
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames//, T_Constraints
		W_Coef[numpnts(W_Coef)-1]=SASBackground
		CoefNames[numpnts(CoefNames)-1]="SASBackground"
//		T_Constraints[0] = {"K"+num2str(numpnts(W_coef)-1)+" > 0"}
	endif

	if (FitBC_CoatingsThickness && UseCiccBen)		//are we fitting distribution 1 location?
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=BC_CoatingsThickness
		CoefNames[numpnts(CoefNames)-1]="BC_CoatingsThickness"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(BC_CoatingsThicknessLL)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(BC_CoatingsThicknessHL)}		
	endif
	if (FitBC_LayerScatLengthDens && UseCiccBen)		//are we fitting distribution 1 location?
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=BC_LayerScatLengthDens
		CoefNames[numpnts(CoefNames)-1]="BC_LayerScatLengthDens"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(BC_LayerScatLengthDensLL)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(BC_LayerScatLengthDensHL)}		
	endif
	if (FitBC_PorodsSpecSurfArea && UseCiccBen)		//are we fitting distribution 1 location?
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=BC_PorodsSpecSurfArea
		CoefNames[numpnts(CoefNames)-1]="BC_PorodsSpecSurfArea"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(BC_PorodsSpecSurfAreaLL)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(BC_PorodsSpecSurfAreaHL)}		
	endif


	if (FitDBEta && UseDB)		//are we fitting distribution 1 location?
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=DBEta
		CoefNames[numpnts(CoefNames)-1]="DBEta"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(DBEtaLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(DBEtaHighLimit)}		
	endif
	if (FitDBcorrL && UseDB)
			//are we fitting distribution 1 scale?
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=DBcorrL
		CoefNames[numpnts(CoefNames)-1]="DBcorrL"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(DBcorrLLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(DBcorrLHighLimit)}		
	endif
	if (FitLowQslope && UseLowQInDB)
			//are we fitting distribution 1 shape?
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=LowQslope
		CoefNames[numpnts(CoefNames)-1]="LowQslope"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(LowQslopeLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(LowQslopeHighLimit)}		
	endif

	if (FitLowQPrefactor && UseLowQInDB)
			//are we fitting distribution 1 scatterer shape parameter?
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=LowQPrefactor
		CoefNames[numpnts(CoefNames)-1]="LowQPrefactor"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(LowQPrefactorLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(LowQPrefactorHighLimit)}		
	endif
	
	if (FitLowQRgPrefactor && UseLowQInDB && (LowQRg<1e10 || LowQRgPrefactor<=0))	
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=LowQRgPrefactor
		CoefNames[numpnts(CoefNames)-1]="LowQRgPrefactor"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(LowQRgPrefactorLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(LowQRgPrefactorHighLimit)}		
	endif
	
	if (FitLowQRg && UseLowQInDB && (LowQRg<1e10 || LowQRgPrefactor<=0))	
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=LowQRg
		CoefNames[numpnts(CoefNames)-1]="LowQRg"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(LowQRgLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(LowQRgHighLimit)}		
	endif
	if (FitTSPrefactor && UseTS)	
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=TSPrefactor
		CoefNames[numpnts(CoefNames)-1]="TSPrefactor"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(TSPrefactorLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(TSPrefactorHighLimit)}		
	endif
	if (FitTSAvalue && UseTS)	
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=TSAvalue
		CoefNames[numpnts(CoefNames)-1]="TSAvalue"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(TSAvalueLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(TSAvalueHighLimit)}		
	endif
	if (FitTSC1Value && UseTS)	
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=TSC1Value
		CoefNames[numpnts(CoefNames)-1]="TSC1Value"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(TSC1ValueLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(TSC1ValueHighLimit)}		
	endif
	if (FitTSC2Value && UseTS)	
		Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
		Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
		W_Coef[numpnts(W_Coef)-1]=TSC2Value
		CoefNames[numpnts(CoefNames)-1]="TSC2Value"
		T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(TSC2ValueLowLimit)}
		T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(TSC2ValueHighLimit)}		
	endif


	
	IR2H_ResetErrors()
	DoWindow /F IR2H_LogLogPlotGels
	Wave OriginalQvector
	Wave OriginalIntensity
	Wave OriginalError	
	
	Variable V_chisq
	Duplicate/O W_Coef, E_wave, CoefficientInput
	E_wave=W_coef/20

//	IR2H_RecordResults("before")
	
	Variable V_FitError=0			//This should prevent errors from being generated
	//and now the fit...
	if (strlen(csrWave(A))!=0 && strlen(csrWave(B))!=0)		//cursors in the graph
		//check that cursors are actually on hte right wave...
		//make sure the cursors are on the right waves..
		if (cmpstr(CsrWave(A, "IR2H_LogLogPlotGels"),"IntensityOriginal")!=0)
			Cursor/P/W=IR2H_LogLogPlotGels A  OriginalIntensity  binarysearch(OriginalQvector, CsrXWaveRef(A) [pcsr(A, "IR2H_LogLogPlotGels")])
		endif
		if (cmpstr(CsrWave(B, "IR2H_LogLogPlotGels"),"IntensityOriginal")!=0)
			Cursor/P /W=IR2H_LogLogPlotGels B  OriginalIntensity  binarysearch(OriginalQvector,CsrXWaveRef(B) [pcsr(B, "IR2H_LogLogPlotGels")])
		endif
		Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalIntensity, FitIntensityWave		
		Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalQvector, FitQvectorWave
		Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalError, FitErrorWave
		FuncFit /N/Q IR2H_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1/E=E_wave /D /C=T_Constraints 
	else
		Duplicate/O OriginalIntensity, FitIntensityWave		
		Duplicate/O OriginalQvector, FitQvectorWave
		Duplicate/O OriginalError, FitErrorWave
		FuncFit /N/Q IR2H_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1 /E=E_wave/D /C=T_Constraints	
	endif
	if (V_FitError!=0)	//there was error in fitting
		IR2H_ResetParamsAfterBadFit()
		Abort "Fitting error, check starting parameters and fitting limits" 
	endif
	//this now records the errors for fitted parameters into the appropriate variables
	Wave W_sigma=root:Packages:Gels_Modeling:W_sigma
	variable i
	string OneErrorName

	For(i=0;i<(numpnts(CoefNames));i+=1)
		OneErrorName="root:Packages:Gels_Modeling:"+CoefNames[i]+"Error"
		NVAR Error=$(OneErrorName)
		Error=W_sigma[i]
	endfor
	
//	variable/g AchievedChisq=V_chisq
	IR2H_GraphModelData()
//	IR2H_RecordResults("after")
//	DoWIndow/F IR2H_ControlPanel
//	IR2H_FixTabsInPanel()
//		
//	KillWaves T_Constraints, E_wave
	
	setDataFolder OldDF
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
static Function IR2H_ResetErrors()
	NVAR DBEtaError=root:Packages:Gels_Modeling:DBEtaError
	NVAR DBcorrLError=root:Packages:Gels_Modeling:DBcorrLError
	NVAR LowQslopeError=root:Packages:Gels_Modeling:LowQslopeError
	NVAR LowQPrefactorError=root:Packages:Gels_Modeling:LowQPrefactorError
	NVAR BC_PorodsSpecSurfAreaError=root:Packages:Gels_Modeling:BC_PorodsSpecSurfAreaError
	NVAR BC_CoatingsThicknessError=root:Packages:Gels_Modeling:BC_CoatingsThicknessError
	NVAR BC_LayerScatLengthDensError=root:Packages:Gels_Modeling:BC_LayerScatLengthDensError
	BC_LayerScatLengthDensError=0
	BC_PorodsSpecSurfAreaError=0
	BC_CoatingsThicknessError=0
	LowQPrefactorError=0
	LowQslopeError=0
	DBcorrLError=0
	DBEtaError=0
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR2H_ResetParamsAfterBadFit()

	Wave/Z w=root:Packages:Gels_Modeling:CoefficientInput		//thsi should have the original parameters...
	Wave/T/Z CoefNames=root:Packages:Gels_Modeling:CoefNames		//text wave with names of parameters

	if ((!WaveExists(w)) || (!WaveExists(CoefNames)))
		abort
	endif

	NVAR SASBackground=root:Packages:Gels_Modeling:SASBackground
	NVAR FitSASBackground=root:Packages:Gels_Modeling:FitSASBackground
	variable i, NumOfParam
	NumOfParam=numpnts(CoefNames)
	string ParamName=""
	
	for (i=0;i<NumOfParam;i+=1)
		ParamName=CoefNames[i]
		NVAR TempParam=$(ParamName)
		TempParam=w[i]
	endfor
	DoWIndow/F IR2H_ControlPanel
	//IR2H_FixTabsInPanel()

end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2H_FitFunction(w,yw,xw) : FitFunc
	Wave w,yw,xw
	
	//here the w contains the parameters, yw will be the result and xw is the input
	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(q) = very complex calculations, forget about formula
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1 - the q vector...
	//CurveFitDialog/ q
	//CurveFitDialog/ Coefficients 21 - up to, but never used


	Wave/T CoefNames=root:Packages:Gels_Modeling:CoefNames		//text wave with names of parameters

	variable i, NumOfParam
	NumOfParam=numpnts(CoefNames)
	string ParamName=""
	
	setDataFOlder root:packages:Gels_Modeling
	
	for (i=0;i<NumOfParam;i+=1)
		ParamName=CoefNames[i]

		Nvar TempParam=$(ParamName)
		TempParam=w[i]	
	endfor
	
	Wave QvectorWave=root:Packages:Gels_Modeling:FitQvectorWave

	IR2H_CalculateModel(yw,xw)
	
	Wave resultWv=root:Packages:Gels_Modeling:DBModelIntensity
	
	yw=resultWv
	
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
static Function IR2H_RecoverParameters()

	SVAR DataFolderName=root:Packages:Gels_Modeling:DataFolderName
	variable DataExists=0,i
	string ListOfWaves=IN2G_CreateListOfItemsInFolder(DataFolderName, 2)
	string tempString
	if (stringmatch(ListOfWaves, "*DebyeBuecheModelInt*" )||stringmatch(ListOfWaves, "*AnalyticalModelInt*" ))
		string ListOfSolutions="start from current state;"
		For(i=0;i<itemsInList(ListOfWaves);i+=1)
			if (stringmatch(stringFromList(i,ListOfWaves),"*DebyeBuecheModelInt*") || stringmatch(stringFromList(i,ListOfWaves),"*AnalyticalModelInt*"))
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

	if (DataExists==1)
		ReturnSolution=ReturnSolution[0,strsearch(ReturnSolution, "*", 0 )-1]
		Wave/Z OldDistribution=$(DataFolderName+ReturnSolution)
	
		string Notestr = note(OldDistribution)
		
		string ListOfWavesForNotes="tempDBModelQvector;tempDBModelIntensity;"

		string ListOfVariables="UseIndra2Data;UseQRSdata;CurrentTab;UseLowQInDB;"
		ListOfVariables+="UseSlitSmearedData;SlitLength;"	
		ListOfVariables+="SASBackground;SASBackgroundStep;FitSASBackground;UpdateAutomatically;SASBackgroundError;"
		//Unified level
		ListOfVariables+="LowQslope;LowQPrefactor;FitLowQslope;FitLowQPrefactor;LowQslopeLowLimit;LowQPrefactorLowLimit;"
		ListOfVariables+="LowQslopeError;LowQPrefactorError;LowQslopeHighLimit;LowQPrefactorHighLimit;"
		ListOfVariables+="LowQRg;FitLowQRg;LowQRgLowLimit;LowQRgHighLimit;LowQRgError;"
		ListOfVariables+="LowQRgPrefactor;FitLowQRgPrefactor;LowQRgPrefactorLowLimit;LowQRgPrefactorHighLimit;LowQRgPrefactorError;"
		//Debye-Bueche parameters	
		ListOfVariables+="DBPrefactor;DBEta;DBcorrL;DBWavelength;"
		ListOfVariables+="DBEtaError;DBcorrLError;"
		ListOfVariables+="FitDBPrefactor;FitDBEta;FitDBcorrL;"
		ListOfVariables+="DBPrefactorHighLimit;DBEtaHighLimit;DBcorrLHighLimit;"
		ListOfVariables+="DBPrefactorLowLimit;DBEtaLowLimit;DBcorrLLowLimit;"
		//Teubner-Strey Model
		ListOfVariables+="TSPrefactor;FitTSPrefactor;TSPrefactorHighLimit;TSPrefactorLowLimit;TSPrefactorError;"
		ListOfVariables+="TSAvalue;FitTSAvalue;TSAvalueHighLimit;TSAvalueLowLimit;TSAvalueError;"
		ListOfVariables+="TSC1Value;FitTSC1Value;TSC1ValueHighLimit;TSC1ValueLowLimit;TSC1ValueError;"
		ListOfVariables+="TSC2Value;FitTSC2Value;TSC2ValueHighLimit;TSC2ValueLowLimit;TSC2ValueError;"
		ListOfVariables+="TSCorrelationLength;TSCorrLengthError;TSRepeatDistance;TSRepDistError;"
		//Ciccariello Coated Porous media Porods oscillations
		ListOfVariables+="BC_PorodsSpecSurfArea;BC_SolidScatLengthDensity;BC_VoidScatLengthDensity;BC_LayerScatLengthDens;"
		ListOfVariables+="BC_CoatingsThickness;UseCiccBen;"
		ListOfVariables+="BC_LayerScatLengthDensHL;BC_LayerScatLengthDensLL;FitBC_LayerScatLengthDens;"
		ListOfVariables+="BC_CoatingsThicknessHL;BC_CoatingsThicknessLL;FitBC_CoatingsThickness;"
		ListOfVariables+="BC_PorodsSpecSurfAreaHL;BC_PorodsSpecSurfAreaLL;FitBC_PorodsSpecSurfArea;"
		ListOfVariables+="BC_PorodsSpecSurfAreaError;BC_CoatingsThicknessError;BC_LayerScatLengthDensError;"

		string ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;"
		variable j
		//deal with the old data here...
		if(stringmatch(Notestr, "*DebyeBueche_*")) //old data	
			For(j=0;j<ItemsInList(ListOfWavesForNotes);j+=1)
				For(i=0;i<itemsInList(ListOfVariables);i+=1)
					NVAR TempVal = $("root:Packages:Gels_Modeling:"+stringFromList(i,ListOfVariables))
					TempVal = numberByKey("DebyeBueche_"+stringFromList(i,ListOfVariables), Notestr, "=", ";") 
				endfor
			endfor
			For(j=0;j<ItemsInList(ListOfWavesForNotes);j+=1)
				For(i=0;i<itemsInList(ListOfStrings);i+=1)
					SVAR TempStr = $("root:Packages:Gels_Modeling:"+stringFromList(i,ListOfStrings))
					TempStr = stringByKey("DebyeBueche_"+stringFromList(i,ListOfStrings), Notestr, "=", ";") 
				endfor
			endfor
		else		//assume new data
			For(j=0;j<ItemsInList(ListOfWavesForNotes);j+=1)
				For(i=0;i<itemsInList(ListOfVariables);i+=1)
					NVAR TempVal = $("root:Packages:Gels_Modeling:"+stringFromList(i,ListOfVariables))
					TempVal = numberByKey("AnalyticalModels_"+stringFromList(i,ListOfVariables), Notestr, "=", ";") 
				endfor
			endfor
			For(j=0;j<ItemsInList(ListOfWavesForNotes);j+=1)
				For(i=0;i<itemsInList(ListOfStrings);i+=1)
					SVAR TempStr = $("root:Packages:Gels_Modeling:"+stringFromList(i,ListOfStrings))
					TempStr = stringByKey("AnalyticalModels_"+stringFromList(i,ListOfStrings), Notestr, "=", ";") 
				endfor
			endfor
		endif
	endif
	//IR2H_GraphModelData()
end
//***************************************************************************************
//***************************************************************************************
//***************************************************************************************
//***************************************************************************************
//***************************************************************************************


static Function IR2H_CopyDataBackToFolder()

	//here we need to copy the final data back to folder
	//before that we need to also attach note to teh waves with the results
	
	string OldDf=getDataFOlder(1)
	setDataFolder root:Packages:Gels_Modeling	
	Wave DBmodelIntensity=root:Packages:Gels_Modeling:DBmodelIntensity
	Wave DBmodelQvector=root:Packages:Gels_Modeling:DBmodelQvector
//	SVAR DataFolderName=root:Packages:Gels_Modeling:DataFolderName
//	
	string UsersComment="Result from Modeling "+date()+"  "+time()
	Prompt UsersComment, "Modify comment to be saved with these results"
	DoPrompt "Need input for saving data", UsersComment
	if (V_Flag)
		abort
	endif

	Duplicate/O DBModelIntensity, tempDBModelIntensity
	Duplicate/O DBModelQvector, tempDBModelQvector
	string ListOfWavesForNotes="tempDBModelQvector;tempDBModelIntensity;"
	string ListOfVariables="UseIndra2Data;UseQRSdata;CurrentTab;UseLowQInDB;"
	ListOfVariables+="UseSlitSmearedData;SlitLength;"	
	ListOfVariables+="SASBackground;SASBackgroundStep;FitSASBackground;UpdateAutomatically;SASBackgroundError;"
	//Unified level
	ListOfVariables+="LowQslope;LowQPrefactor;FitLowQslope;FitLowQPrefactor;LowQslopeLowLimit;LowQPrefactorLowLimit;"
	ListOfVariables+="LowQslopeError;LowQPrefactorError;LowQslopeHighLimit;LowQPrefactorHighLimit;"
	ListOfVariables+="LowQRg;FitLowQRg;LowQRgLowLimit;LowQRgHighLimit;LowQRgError;"
	ListOfVariables+="LowQRgPrefactor;FitLowQRgPrefactor;LowQRgPrefactorLowLimit;LowQRgPrefactorHighLimit;LowQRgPrefactorError;"
	//Debye-Bueche parameters	
	ListOfVariables+="DBPrefactor;DBEta;DBcorrL;DBWavelength;"
	ListOfVariables+="DBEtaError;DBcorrLError;"
	ListOfVariables+="FitDBPrefactor;FitDBEta;FitDBcorrL;"
	ListOfVariables+="DBPrefactorHighLimit;DBEtaHighLimit;DBcorrLHighLimit;"
	ListOfVariables+="DBPrefactorLowLimit;DBEtaLowLimit;DBcorrLLowLimit;"
	//Teubner-Strey Model
	ListOfVariables+="TSPrefactor;FitTSPrefactor;TSPrefactorHighLimit;TSPrefactorLowLimit;TSPrefactorError;"
	ListOfVariables+="TSAvalue;FitTSAvalue;TSAvalueHighLimit;TSAvalueLowLimit;TSAvalueError;"
	ListOfVariables+="TSC1Value;FitTSC1Value;TSC1ValueHighLimit;TSC1ValueLowLimit;TSC1ValueError;"
	ListOfVariables+="TSC2Value;FitTSC2Value;TSC2ValueHighLimit;TSC2ValueLowLimit;TSC2ValueError;"
	ListOfVariables+="TSCorrelationLength;TSCorrLengthError;TSRepeatDistance;TSRepDistError;"
	//Ciccariello Coated Porous media Porods oscillations
	ListOfVariables+="BC_PorodsSpecSurfArea;BC_SolidScatLengthDensity;BC_VoidScatLengthDensity;BC_LayerScatLengthDens;"
	ListOfVariables+="BC_CoatingsThickness;UseCiccBen;"
	ListOfVariables+="BC_LayerScatLengthDensHL;BC_LayerScatLengthDensLL;FitBC_LayerScatLengthDens;"
	ListOfVariables+="BC_CoatingsThicknessHL;BC_CoatingsThicknessLL;FitBC_CoatingsThickness;"
	ListOfVariables+="BC_PorodsSpecSurfAreaHL;BC_PorodsSpecSurfAreaLL;FitBC_PorodsSpecSurfArea;"
	ListOfVariables+="BC_PorodsSpecSurfAreaError;BC_CoatingsThicknessError;BC_LayerScatLengthDensError;"

	string ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;"
	variable i,j
	For(j=0;j<ItemsInList(ListOfWavesForNotes);j+=1)
		For(i=0;i<itemsInList(ListOfVariables);i+=1)
			NVAR TempVal = $("root:Packages:Gels_Modeling:"+stringFromList(i,ListOfVariables))
			IN2G_AppendorReplaceWaveNote(stringFromList(j,ListOfWavesForNotes),"AnalyticalModels_"+stringFromList(i,ListOfVariables),num2str(TempVal))
		endfor
	endfor
	For(j=0;j<ItemsInList(ListOfWavesForNotes);j+=1)
		For(i=0;i<itemsInList(ListOfStrings);i+=1)
			SVAR TempStr = $("root:Packages:Gels_Modeling:"+stringFromList(i,ListOfStrings))
			IN2G_AppendorReplaceWaveNote(stringFromList(j,ListOfWavesForNotes),"AnalyticalModels_"+stringFromList(i,ListOfStrings),TempStr)
		endfor
	endfor
	
	SVAR DataFolderName=root:Packages:Gels_Modeling:DataFolderName
	setDataFolder $DataFolderName
	string tempname 
	variable ii=0
	For(ii=0;ii<1000;ii+=1)
		tempname="AnalyticalModelInt_"+num2str(ii)
		if (checkname(tempname,1)==0)
			break
		endif
	endfor
	Duplicate /O tempDBModelIntensity, $tempname
	Wave MytempWave=$tempname
	IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
	IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
	IN2G_AppendorReplaceWaveNote(tempname,"Units","1/mm")
	Redimension/D MytempWave
	
	tempname="AnalyticalModelQvec_"+num2str(ii)
	Duplicate /O tempDBModelQvector, $tempname
	Wave MytempWave=$tempname
	IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
	IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
	IN2G_AppendorReplaceWaveNote(tempname,"Units","1/A")
	Redimension/D MytempWave
	
	setDataFolder root:Packages:Gels_Modeling
//
	Killwaves/Z tempDBModelQvector, tempDBModelIntensity
	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR2H_ExportASCIIResults()

	//here we need to copy the export results out of Igor
	//before that we need to also attach note to teh waves with the results
	
	string OldDf=getDataFOlder(1)
	setDataFolder root:Packages:Gels_Modeling	
	Wave DBmodelIntensity=root:Packages:Gels_Modeling:DBmodelIntensity
	Wave DBmodelQvector=root:Packages:Gels_Modeling:DBmodelQvector
	SVAR DataFolderName=root:Packages:Gels_Modeling:DataFolderName
	string UsersComment="Result from Analytical Models tool "+date()+"  "+time()
	Prompt UsersComment, "Modify comment to be saved with these results"
	DoPrompt "Need input for saving data", UsersComment
	if (V_Flag)
		abort
	endif

	Duplicate/O DBModelIntensity, tempDBModelIntensity
	Duplicate/O DBModelQvector, tempDBModelQvector
	string ListOfWavesForNotes="tempDBModelQvector;tempDBModelIntensity;"
	string ListOfVariables="UseIndra2Data;UseQRSdata;CurrentTab;UseLowQInDB;"
	ListOfVariables+="UseSlitSmearedData;SlitLength;"	
	ListOfVariables+="SASBackground;SASBackgroundStep;FitSASBackground;UpdateAutomatically;SASBackgroundError;"
	//Unified level
	ListOfVariables+="LowQslope;LowQPrefactor;FitLowQslope;FitLowQPrefactor;LowQslopeLowLimit;LowQPrefactorLowLimit;"
	ListOfVariables+="LowQslopeError;LowQPrefactorError;LowQslopeHighLimit;LowQPrefactorHighLimit;"
	ListOfVariables+="LowQRg;FitLowQRg;LowQRgLowLimit;LowQRgHighLimit;LowQRgError;"
	ListOfVariables+="LowQRgPrefactor;FitLowQRgPrefactor;LowQRgPrefactorLowLimit;LowQRgPrefactorHighLimit;LowQRgPrefactorError;"
	//Debye-Bueche parameters	
	ListOfVariables+="DBPrefactor;DBEta;DBcorrL;DBWavelength;"
	ListOfVariables+="DBEtaError;DBcorrLError;"
	ListOfVariables+="FitDBPrefactor;FitDBEta;FitDBcorrL;"
	ListOfVariables+="DBPrefactorHighLimit;DBEtaHighLimit;DBcorrLHighLimit;"
	ListOfVariables+="DBPrefactorLowLimit;DBEtaLowLimit;DBcorrLLowLimit;"
	//Teubner-Strey Model
	ListOfVariables+="TSPrefactor;FitTSPrefactor;TSPrefactorHighLimit;TSPrefactorLowLimit;TSPrefactorError;"
	ListOfVariables+="TSAvalue;FitTSAvalue;TSAvalueHighLimit;TSAvalueLowLimit;TSAvalueError;"
	ListOfVariables+="TSC1Value;FitTSC1Value;TSC1ValueHighLimit;TSC1ValueLowLimit;TSC1ValueError;"
	ListOfVariables+="TSC2Value;FitTSC2Value;TSC2ValueHighLimit;TSC2ValueLowLimit;TSC2ValueError;"
	ListOfVariables+="TSCorrelationLength;TSCorrLengthError;TSRepeatDistance;TSRepDistError;"
	//Ciccariello Coated Porous media Porods oscillations
	ListOfVariables+="BC_PorodsSpecSurfArea;BC_SolidScatLengthDensity;BC_VoidScatLengthDensity;BC_LayerScatLengthDens;"
	ListOfVariables+="BC_CoatingsThickness;UseCiccBen;"
	ListOfVariables+="BC_LayerScatLengthDensHL;BC_LayerScatLengthDensLL;FitBC_LayerScatLengthDens;"
	ListOfVariables+="BC_CoatingsThicknessHL;BC_CoatingsThicknessLL;FitBC_CoatingsThickness;"
	ListOfVariables+="BC_PorodsSpecSurfAreaHL;BC_PorodsSpecSurfAreaLL;FitBC_PorodsSpecSurfArea;"
	ListOfVariables+="BC_PorodsSpecSurfAreaError;BC_CoatingsThicknessError;BC_LayerScatLengthDensError;"
	string ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;"
	variable i,j
	UsersComment+="\r"
	For(j=0;j<ItemsInList(ListOfWavesForNotes);j+=1)
		For(i=0;i<itemsInList(ListOfVariables);i+=1)
			NVAR TempVal = $("root:Packages:Gels_Modeling:"+stringFromList(i,ListOfVariables))
			IN2G_AppendorReplaceWaveNote(stringFromList(j,ListOfWavesForNotes),"AnalyticalModels_"+stringFromList(i,ListOfVariables),num2str(TempVal))
			UsersComment+="AnalyticalModels_"+stringFromList(i,ListOfVariables)+":"+num2str(TempVal)+";\r"
		endfor
	endfor
	For(j=0;j<ItemsInList(ListOfWavesForNotes);j+=1)
		For(i=0;i<itemsInList(ListOfStrings);i+=1)
			SVAR TempStr = $("root:Packages:Gels_Modeling:"+stringFromList(i,ListOfStrings))
			IN2G_AppendorReplaceWaveNote(stringFromList(j,ListOfWavesForNotes),"AnalyticalModels_"+stringFromList(i,ListOfStrings),TempStr)
			UsersComment+="AnalyticalModels_"+stringFromList(i,ListOfStrings)+":"+TempStr+";\r"
		endfor
	endfor
	
	IN2G_AppendorReplaceWaveNote("tempDBModelQvector","UsersComment",UsersComment)
	IN2G_AppendorReplaceWaveNote("tempDBModelQvector","Units","1/mm")
	IN2G_AppendorReplaceWaveNote("tempDBModelIntensity","UsersComment",UsersComment)
	IN2G_AppendorReplaceWaveNote("tempDBModelIntensity","Units","1/A")
	
	SVAR DataFolderName = root:Packages:Gels_Modeling:DataFolderName
	string filename1
	filename1=StringFromList(ItemsInList(DataFolderName,":")-1, DataFolderName,":")+"_AnalyticalModel.txt"
	variable refnum

	Open/D/T=".txt"/M="Select file to save data to" refnum as filename1
	filename1=S_filename
	if (strlen(filename1)==0)
		abort
	endif

	
	String nb = "Notebook99999"
	NewNotebook/N=$nb/F=0/V=0/K=0/W=(5.25,40.25,558,408.5) as "Notebook99999:ExportData"
	Notebook $nb defaultTab=20, statusWidth=238, pageMargins={72,72,72,72}
	Notebook $nb font="Arial", fSize=10, fStyle=0, textRGB=(0,0,0)
	Notebook $nb text=UsersComment	
	SaveNotebook $nb as filename1
	DoWindow /K $nb
	Save/A/G/M="\r" tempDBModelQvector,tempDBModelIntensity as filename1	 
	
	Killwaves/Z tempDBModelQvector, tempDBModelIntensity
	setDataFolder OldDf
end
	

