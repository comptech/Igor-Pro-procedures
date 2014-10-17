#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 1.09


//*************************************************************************\
//* Copyright (c) 2005 - 2010, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.09 added license for ANL


//version 1.04 adds to "qrs" also "qis" - NIST intended naming structure as of 11/2007 
//version 1.05 adds capability to be used on child (or sub) panels and graphs. Keep names short, so the total length is below 28 characters (of both HOST and CHILD together)
//version 1.06 fixes the NIST qis naming structure 3/8/2008. Only q, int, and error are used, resolution wave is nto used at this time. 
//version 1.07 fixes minor bug for Model input, when the Qs werento recalculated when log-Q choice wa changed. 
//version 1.08 - added Unified size distribution and changed global string to help with upgrades. Now the list of known results is updated every time the cod eis run. 


//How to - readme 
//version 1  7/19/2005 - first release, allows already user type (type Indra2 and QRS logic) of data
//Adds controls to select data to panels 
//How to:
//	Following are parameters
//		PckgDataFolder 		-	data folder where strings with folder and Q/Int/Error wave names will be created. Also place for variables use IN2, QRS, Resutls, User...  Will be created if necessary. 
//		PanelWindowName	- 	in which panel to create the controls. Neede for lookup tables
//		AllowedIrenaTypes	-	which of the Indra2 data types are allowed. Note, order is the order in which these will be listed (if they exist) and first existing will be preselected. 
//		AllowedResultsTypes	-	list of Irena allowed results types. For example "SizesNumberDistribution;SizesVolumeDistribution;" etc. There should be list of all existing results in this package. If "", this scontrol will not show. Same about order as above (I hope).
		//NOTE - if set to "AllCurrentlyAllowedTypes" all currently known results types will be used... 

//		AllowedUserTypes	- 	list of user defined types of data. For now can handle either Nika type - where unique names are known ("DSM_Int;SMR_Int;...") or qrs type which can include * for common part of name - at this time ONLY at the end.
//								So, at this time you can use "r*;" to get qrs data and see below for other information needed.					
//		UserNameString		- 	string which will be displayed on panel as name at the chekcbox. Make it SHORT!!!!
//		XUserTypeLookup	- 	Lookup table, which returns for each AllowedUserTypes item one prescription for x axis data.
//								Examples: "DSM_Int:DSM_Qvec;r*:q*;" etc.   NOTE: use ":" between keyword and value and ";" between items in this table. Necessary!!!!
//								Important note: this library can be as large as needed, but ONLY ONE PER EXPERIMENT. It is common for all panels. But, not every panel needs to use all of the known types in this table. 
//								Every package can add to this common library - the unknown typers will be added... But note, that if you redefine relationship, it is redefined for WHOLE EXPERIMENT. Seems only sensible way  to make this. 		
//		EUserTypeLookup	- 	Same as above but for errors.
//		RequireErrorWaves	- 	0 if data without errors are allowed, 1 if errors are required. Can be different for each panel. 
//		AllowModelData		- 	adds option to allow generation of model Q data and provides these data to the other packages
//	
// example which creates test panel:
//Window TestPanel2() : Panel
//	PauseUpdate; Silent 1		// building window...
//	NewPanel /K=1 /W=(2.25,43.25,390,690) as "Test"
//Uncomment either Example 1 or Example 2 
//Example 1 - User data of Irena type
//	string UserDataTypes="DSM_Int;SMR_Int;"
//	string UserNameString="Test me"
//	string XUserLookup="DSM_Int:DSM_Qvec;SMR_Int:SMR_Qvec;"
//	string EUserLookup="DSM_Int:DSM_Error;SMR_Int:SMR_Error;"
//Example 2 - qrs data type
//	string UserDataTypes="r_*;"
//	string UserNameString="Test me"
//	string XUserLookup="r_*:q_*;"
//	string EUserLookup="r_*:s_*;"
//	variable RequireErrorWaves =0
//	variable AllowModelData = 0
//and this creates the controls. 
//	IR2C_AddDataControls("testpacakge2","TestPanel2","DSM_Int;M_DSM_Int;R_Int;SMR_Int;M_SMR_Int;","SizesFitIntensity;SizesVolumeDistribution;SizesNumberDistribution;",UserDataTypes,UserNameString,XUserLookup,EUserLookup, RequireErrorWaves, AllowModelData)
//end

//modifications:
//	1.01		if Indra 2 data type is empty, controls will not show...
//	1.03      Modifed PanelControlProcedures to enable user to write "hook" functions which can be run after the selection is made... 
//	Important: There are 4 hook functions, run after folder, Q, intensity, and error data are selected, names must be exactly: 
//	IR2_ContrProc_F_Hook_Proc(), IR2_ContrProc_Q_Hook_Proc(), IR2_ContrProc_R_Hook_Proc(), and IR2_ContrProc_E_Hook_Proc(). 
//	User needs to make sure these can be called with no parameters and that they will nto fail if called by differnt panel!!! 
//	This is important, as they will be called from any panel whic is using this package, so they have to be prrof to that. 
//	I suggest checcking on the name of top active panel window or the current folder...  Example of function is below: 
//Function IR2_ContrProc_Q_Hook_Proc()
//	print getDataFolder(0)
//end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR2C_AddDataControls(PckgDataFolder,PanelWindowName,AllowedIrenaTypes, AllowedResultsTypes, AllowedUserTypes, UserNameString, XUserTypeLookup,EUserTypeLookup, RequireErrorWaves,AllowModelData)
	string PckgDataFolder,PanelWindowName, AllowedIrenaTypes, AllowedResultsTypes, AllowedUserTypes, UserNameString, XUserTypeLookup,EUserTypeLookup
	variable RequireErrorWaves, AllowModelData
	
	//modification to enable use in subpanels and subwindows in general... Looks like we need to check in bizzard way as Dowindow does not work with subwindow syntax...
//	DoWindow $(PanelWindowName)
//	if(!V_Flag)
//		abort //widnow does not exist, nothing to do...
//	endif
	if(stringmatch(PanelWindowName, "*#*" ))	//# so expect subwindow... Limit only to first child here, else is not allowed for now...
		//first check for the main window existance...
		string MainPnlWinName=StringFromList(0, PanelWindowName , "#")
		string ChildPnlWinName=StringFromList(1, PanelWindowName , "#")
				//check on existence here...
			DoWindow $(MainPnlWinName)
			if(!V_Flag)
				abort //widnow does not exist, nothing to do...
			endif
			//OK, window exists, now check if it has the other in the childlist
			if(!stringmatch(ChildWindowList(MainPnlWinName), "*"+ChildPnlWinName+"*" ))
				abort //that child does nto exist!
			endif
			
	else		//no # no subvwindow. Use old code...
		DoWindow $(PanelWindowName)
		if(!V_Flag)
			abort //widnow does not exist, nothing to do...
		endif
	endif

	IR2C_InitControls(PckgDataFolder,PanelWindowName,AllowedIrenaTypes, AllowedResultsTypes, AllowedUserTypes, UserNameString, XUserTypeLookup,EUserTypeLookup, RequireErrorWaves,AllowModelData)
	
	//This is fix to simplify coding all results
	SVAR AllCurrentlyAllowedTypes=root:Packages:IrenaControlProcs:AllCurrentlyAllowedTypes
	if(cmpstr(AllowedResultsTypes,"AllCurrentlyAllowedTypes")==0)
		AllowedResultsTypes=AllCurrentlyAllowedTypes
	endif

	IR2C_AddControlsToWndw(PckgDataFolder,PanelWindowName,AllowedIrenaTypes, AllowedResultsTypes, AllowedUserTypes, UserNameString, XUserTypeLookup,EUserTypeLookup, RequireErrorWaves,AllowModelData)
	
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR2C_InitControls(PckgDataFolder,PanelWindowName,AllowedIrenaTypes, AllowedResultsTypes, AllowedUserTypes, UserNameString, XUserTypeLookup,EUserTypeLookup, RequireErrorWaves,AllowModelData)
	string PckgDataFolder,PanelWindowName, AllowedIrenaTypes, AllowedResultsTypes,AllowedUserTypes, UserNameString, XUserTypeLookup,EUserTypeLookup
	variable RequireErrorWaves,AllowModelData
	
	string OldDf=GetDataFolder(1)
	setdatafolder root:
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S IrenaControlProcs

	SVAR/Z AllCurrentlyAllowedTypes
//	if(!SVAR_Exists(AllCurrentlyAllowedTypes))
		string/g AllCurrentlyAllowedTypes
//	endif
	//List of all types currently existing: 
	AllCurrentlyAllowedTypes = "SizesFitIntensity;SizesVolumeDistribution;SizesNumberDistribution;UnifiedFitIntensity;"
	AllCurrentlyAllowedTypes+="IntensityModelLSQF2;NumberDistModelLSQF2;VolumeDistModelLSQF2;"
	AllCurrentlyAllowedTypes+= "ReflModel;SLDProfile;"
	AllCurrentlyAllowedTypes+="ModelingNumberDistribution;ModelingVolumeDistribution;ModelingIntensity;FractFitIntensity;DebyeBuecheModelInt;AnalyticalModelInt;"
	AllCurrentlyAllowedTypes+="ModelingNumDist_Pop1;ModelingVolDist_Pop1;Mass1FractFitInt;Surf1FractFitInt;UniLocalLevel1Unified;UniLocalLevel1Pwrlaw;UniLocalLevel1Guinier;"
	AllCurrentlyAllowedTypes+="ModelingNumDist_Pop2;ModelingVolDist_Pop2;Mass2FractFitInt;Surf2FractFitInt;UniLocalLevel2Unified;UniLocalLevel2Pwrlaw;UniLocalLevel2Guinier;"
	AllCurrentlyAllowedTypes+="ModelingNumDist_Pop3;ModelingVolDist_Pop3;Mass3FractFitInt;Surf3FractFitInt;UniLocalLevel3Unified;UniLocalLevel3Pwrlaw;UniLocalLevel3Guinier;"
	AllCurrentlyAllowedTypes+="ModelingNumDist_Pop4;ModelingVolDist_Pop4;Mass4FractFitInt;Surf4FractFitInt;UniLocalLevel4Unified;UniLocalLevel4Pwrlaw;UniLocalLevel4Guinier;"
	AllCurrentlyAllowedTypes+="ModelingNumDist_Pop5;ModelingVolDist_Pop5;Mass5FractFitInt;Surf5FractFitInt;UniLocalLevel5Unified;UniLocalLevel5Pwrlaw;UniLocalLevel5Guinier;"
	AllCurrentlyAllowedTypes+="CumulativeSizeDist;CumulativeSfcArea;MIPVolume;SADModelIntensity;SADModelIntPeak1;SADModelIntPeak2;SADModelIntPeak3;"
	AllCurrentlyAllowedTypes+="SADModelIntPeak4;SADModelIntPeak5;SADModelIntPeak6;"
	AllCurrentlyAllowedTypes+="PDDFIntensity;PDDFDistFunction;PDDFChiSquared;"
	AllCurrentlyAllowedTypes+="UnifSizeDistVolumeDist;UnifSizeDistNumberDist;"


	if(cmpstr(AllowedResultsTypes,"AllCurrentlyAllowedTypes")==0)
		AllowedResultsTypes=AllCurrentlyAllowedTypes
	endif

	variable i
	
	SVAR/Z ControlProcsLocations
	if(!SVAR_Exists(ControlProcsLocations))
		string/g ControlProcsLocations
	endif
	ControlProcsLocations=ReplaceStringByKey(PanelWindowName, ControlProcsLocations, PckgDataFolder,":",";" )

	SVAR/Z ControlAllowedIrenaTypes
	if(!SVAR_Exists(ControlAllowedIrenaTypes))
		string/g ControlAllowedIrenaTypes
	endif
	ControlAllowedIrenaTypes=ReplaceStringByKey(PanelWindowName, ControlAllowedIrenaTypes, AllowedIrenaTypes, "=",">" )

	SVAR/Z ControlAllowedUserTypes
	if(!SVAR_Exists(ControlAllowedUserTypes))
		string/g ControlAllowedUserTypes
	endif
	ControlAllowedUserTypes=ReplaceStringByKey(PanelWindowName, ControlAllowedUserTypes, AllowedUserTypes, "=",">" )

	SVAR/Z ControlAllowedResultsTypes
	if(!SVAR_Exists(ControlAllowedResultsTypes))
		string/g ControlAllowedResultsTypes
	endif
	ControlAllowedResultsTypes=ReplaceStringByKey(PanelWindowName, ControlAllowedResultsTypes, AllowedResultsTypes, "=",">" )

	SVAR/Z ControlRequireErrorWvs
	if(!SVAR_Exists(ControlRequireErrorWvs))
		string/g ControlRequireErrorWvs
	endif
	ControlRequireErrorWvs=ReplaceStringByKey(PanelWindowName, ControlRequireErrorWvs, num2str(RequireErrorWaves) )
	//added 7/27/2006
	SVAR/Z ControlAllowModelData
	if(!SVAR_Exists(ControlAllowModelData))
		string/g ControlAllowModelData
	endif
	ControlAllowModelData=ReplaceStringByKey(PanelWindowName, ControlAllowModelData, num2str(AllowModelData) )
	//I suspect I'll need to be able to remeber which fields have displayed... 
//	SVAR/Z ControlError
//	if(!SVAR_Exists(ControlAllowModelData))
//		string/g ControlAllowModelData
//	endif
//	ControlAllowModelData=ReplaceStringByKey(PanelWindowName, ControlAllowModelData, num2str(AllowModelData) )

	SVAR/Z XwaveUserDataTypesLookup
	if(!SVAR_Exists(XwaveUserDataTypesLookup))
		string/g XwaveUserDataTypesLookup
	endif
	For(i=0;i<ItemsInList(XUserTypeLookup,";");i+=1)
		XwaveUserDataTypesLookup = ReplaceStringByKey(StringFromList(0,StringFromList(i,XUserTypeLookup,";"),":"), XwaveUserDataTypesLookup, StringFromList(1,StringFromList(i,XUserTypeLookup,";"),":")  , ":" , ";")
	endfor

	SVAR/Z EwaveUserDataTypesLookup
	if(!SVAR_Exists(EwaveUserDataTypesLookup))
		string/g EwaveUserDataTypesLookup
	endif
	For(i=0;i<ItemsInList(EUserTypeLookup,";");i+=1)
		EwaveUserDataTypesLookup = ReplaceStringByKey(StringFromList(0,StringFromList(i,EUserTypeLookup,";"),":"), EwaveUserDataTypesLookup, StringFromList(1,StringFromList(i,EUserTypeLookup,";"),":")  , ":" , ";")
	endfor


	SVAR/Z XwaveDataTypesLookup
	if(!SVAR_Exists(XwaveDataTypesLookup))
		string/g XwaveDataTypesLookup
	endif
	XwaveDataTypesLookup="DSM_Int:DSM_Qvec;"
	XwaveDataTypesLookup+="M_DSM_Int:M_DSM_Qvec;"
	XwaveDataTypesLookup+="BCK_Int:BCK_Qvec;"
	XwaveDataTypesLookup+="M_BCK_Int:M_BCK_Qvec;"
	XwaveDataTypesLookup+="SMR_Int:SMR_Qvec;"
	XwaveDataTypesLookup+="M_SMR_Int:M_SMR_Qvec;"
	XwaveDataTypesLookup+="R_Int:R_Qvec;"
//	XwaveDataTypesLookup+="r*:q*;"
//	XwaveDataTypesLookup+="DSM_Int:DSM_Qvec;"
	
	SVAR/Z EwaveDataTypesLookup
	if(!SVAR_Exists(EwaveDataTypesLookup))
		string/g EwaveDataTypesLookup
	endif
	EwaveDataTypesLookup="DSM_Int:DSM_Error;"
	EwaveDataTypesLookup+="M_DSM_Int:M_DSM_Error;"
	EwaveDataTypesLookup+="BCK_Int:BCK_Error;"
	EwaveDataTypesLookup+="M_BCK_Int:M_BCK_Error;"
	EwaveDataTypesLookup+="SMR_Int:SMR_Error;"
	EwaveDataTypesLookup+="M_SMR_Int:M_SMR_Error;"
	EwaveDataTypesLookup+="R_Int:R_Error;"
//	EwaveDataTypesLookup+="r*:s*;"
	

	SVAR/Z ResultsEDataTypesLookup
	if(!SVAR_Exists(ResultsEDataTypesLookup))
		string/g ResultsEDataTypesLookup
	endif
	ResultsEDataTypesLookup="PDDFDistFunction:PDDFErrors;"		//PDDF has error estimates for the result... 
	
	SVAR/Z ResultsDataTypesLookup
	if(!SVAR_Exists(ResultsDataTypesLookup))
		string/g ResultsDataTypesLookup
	endif
	//sizes
	ResultsDataTypesLookup="SizesFitIntensity:SizesFitQvector;"
	ResultsDataTypesLookup+="SizesVolumeDistribution:SizesDistDiameter;"
	ResultsDataTypesLookup+="SizesNumberDistribution:SizesDistDiameter;"
	//unified
	ResultsDataTypesLookup+="UnifiedFitIntensity:UnifiedFitQvector;"
	ResultsDataTypesLookup+="UniLocalLevel1Unified:UnifiedFitQvector;"
	ResultsDataTypesLookup+="UniLocalLevel1Pwrlaw:UnifiedFitQvector;"
	ResultsDataTypesLookup+="UniLocalLevel1Guinier:UnifiedFitQvector;"
	ResultsDataTypesLookup+="UniLocalLevel2Unified:UnifiedFitQvector;"
	ResultsDataTypesLookup+="UniLocalLevel2Pwrlaw:UnifiedFitQvector;"
	ResultsDataTypesLookup+="UniLocalLevel2Guinier:UnifiedFitQvector;"
	ResultsDataTypesLookup+="UniLocalLevel3Unified:UnifiedFitQvector;"
	ResultsDataTypesLookup+="UniLocalLevel3Pwrlaw:UnifiedFitQvector;"
	ResultsDataTypesLookup+="UniLocalLevel3Guinier:UnifiedFitQvector;"
	ResultsDataTypesLookup+="UniLocalLevel4Unified:UnifiedFitQvector;"
	ResultsDataTypesLookup+="UniLocalLevel4Pwrlaw:UnifiedFitQvector;"
	ResultsDataTypesLookup+="UniLocalLevel4Guinier:UnifiedFitQvector;"
	ResultsDataTypesLookup+="UniLocalLevel5Unified:UnifiedFitQvector;"
	ResultsDataTypesLookup+="UniLocalLevel5Pwrlaw:UnifiedFitQvector;"
	ResultsDataTypesLookup+="UniLocalLevel5Guinier:UnifiedFitQvector;"
	
	ResultsDataTypesLookup+="UnifSizeDistVolumeDist:UnifSizeDistRadius;"
	ResultsDataTypesLookup+="UnifSizeDistNumberDist:UnifSizeDistRadius;"
	
	//LSQF
	ResultsDataTypesLookup+="ModelingNumberDistribution:ModelingDiameters;"
	ResultsDataTypesLookup+="ModelingVolumeDistribution:ModelingDiameters;"
	ResultsDataTypesLookup+="ModelingIntensity:ModelingQvector;"
	ResultsDataTypesLookup+="ModelingNumDist_Pop1:ModelingDia_Pop1;"
	ResultsDataTypesLookup+="ModelingVolDist_Pop1:ModelingDia_Pop1;"
	ResultsDataTypesLookup+="ModelingNumDist_Pop2:ModelingDia_Pop2;"
	ResultsDataTypesLookup+="ModelingVolDist_Pop2:ModelingDia_Pop2;"
	ResultsDataTypesLookup+="ModelingNumDist_Pop3:ModelingDia_Pop3;"
	ResultsDataTypesLookup+="ModelingVolDist_Pop3:ModelingDia_Pop3;"
	ResultsDataTypesLookup+="ModelingNumDist_Pop4:ModelingDia_Pop4;"
	ResultsDataTypesLookup+="ModelingVolDist_Pop4:ModelingDia_Pop4;"
	ResultsDataTypesLookup+="ModelingNumDist_Pop5:ModelingDia_Pop5;"
	ResultsDataTypesLookup+="ModelingVolDist_Pop5:ModelingDia_Pop5;"
	//Fractals
	ResultsDataTypesLookup+="FractFitIntensity:FractFitQvector;"
	ResultsDataTypesLookup+="Mass1FractFitInt:Mass1FractFitQvec;"
	ResultsDataTypesLookup+="Surf1FractFitInt:Surf1FractFitQvec;"
	ResultsDataTypesLookup+="Mass2FractFitInt:Mass2FractFitQvec;"
	ResultsDataTypesLookup+="Surf2FractFitInt:Surf2FractFitQvec;"
	ResultsDataTypesLookup+="Mass3FractFitInt:Mass3FractFitQvec;"
	ResultsDataTypesLookup+="Surf3FractFitInt:Surf3FractFitQvec;"
	ResultsDataTypesLookup+="Mass4FractFitInt:Mass4FractFitQvec;"
	ResultsDataTypesLookup+="Surf4FractFitInt:Surf4FractFitQvec;"
	ResultsDataTypesLookup+="Mass5FractFitInt:Mass5FractFitQvec;"
	ResultsDataTypesLookup+="Surf5FractFitInt:Surf5FractFitQvec;"
	//Small-angle diffraction
	ResultsDataTypesLookup+="SADModelIntensity:SADModelQ;"
	ResultsDataTypesLookup+="SADModelIntPeak1:SADModelQPeak1;"
	ResultsDataTypesLookup+="SADModelIntPeak2:SADModelQPeak2;"
	ResultsDataTypesLookup+="SADModelIntPeak3:SADModelQPeak3;"
	ResultsDataTypesLookup+="SADModelIntPeak4:SADModelQPeak4;"
	ResultsDataTypesLookup+="SADModelIntPeak5:SADModelQPeak5;"
	ResultsDataTypesLookup+="SADModelIntPeak6:SADModelQPeak6;"
	//Gels
	ResultsDataTypesLookup+="DebyeBuecheModelInt:DebyeBuecheModelQvec;"//old, now next line...
	ResultsDataTypesLookup+="AnalyticalModelInt:AnalyticalModelQvec;"
	//Reflcecitivty
	ResultsDataTypesLookup+="ReflModel:ReflQ;"
	ResultsDataTypesLookup+="SLDProfile:x-scaling;"
	//PDDF
	ResultsDataTypesLookup+="PDDFIntensity:PDDFQvector;"
	ResultsDataTypesLookup+="PDDFChiSquared:PDDFQvector;"
	ResultsDataTypesLookup+="PDDFDistFunction:PDDFDistances;"
	
	//NLQSF2
	ResultsDataTypesLookup+="IntensityModelLSQF2:QvectorModelLSQF2;"
	ResultsDataTypesLookup+="VolumeDistModelLSQF2:RadiiModelLSQF2;"
	ResultsDataTypesLookup+="NumberDistModelLSQF2:RadiiModelLSQF2;"

	//CumulativeSizeDist Curve from Evaluate Size dist
	ResultsDataTypesLookup+="CumulativeSizeDist:CumulativeDistDiameters;"
	ResultsDataTypesLookup+="CumulativeSfcArea:CumulativeDistDiameters;"
	ResultsDataTypesLookup+="MIPVolume:MIPPressure;"


	string ListOfVariables
	string ListOfStrings

	//************************************************************
	//************************************************************
	//************************************************************
	//And now controls for Modeling - need to generate Q values...
	//ad subfolder with the name of the window
	NewDataFolder/O/S $(PanelWindowName)
	Variable/G Qmin,Qmax,QNumPoints,QLogScale
	if(Qmin<1e-20)
		Qmin=0.0001
	endif
	if(Qmax<1e-20)
		Qmax=1
	endif
	if(QNumPoints<2)
		QNumPoints=100
	endif
	ListOfStrings="tempXlist;tempYlist;tempElist;"
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	

	//************************************************************
	//************************************************************
	//************************************************************
	setDataFolder root:packages
	if(ItemsInList(PckgDataFolder , ":")>1)
		For(i=0;i<ItemsInList(PckgDataFolder , ":");i+=1)
			NewDataFolder/O/S $(StringFromList(i,PckgDataFolder,":"))
		endfor	
	else
		NewDataFolder/O/S $(PckgDataFolder)
	endif
	
	//here define the lists of variables and strings needed, separate names by ;...
	
	ListOfVariables="UseIndra2Data;UseQRSdata;UseResults;UseSMRData;UseUserDefinedData;UseModelData;"

	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;"
	
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	

	setDataFolder OldDf
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR2C_AddControlsToWndw(PckgDataFolder,PanelWindowName,AllowedIrenaTypes,AllowedResultsTypes, AllowedUserTypes, UserNameString, XUserTypeLookup,EUserTypeLookup, RequireErrorWaves,AllowModelData)
	string PckgDataFolder,PanelWindowName, AllowedIrenaTypes,AllowedResultsTypes,AllowedUserTypes, UserNameString, XUserTypeLookup,EUserTypeLookup
	variable RequireErrorWaves,AllowModelData

	SVAR ControlProcsLocations=root:Packages:IrenaControlProcs:ControlProcsLocations
	SVAR ControlAllowedIrenaTypes=root:Packages:IrenaControlProcs:ControlAllowedIrenaTypes
	SVAR ControlAllowedResultsTypes=root:Packages:IrenaControlProcs:ControlAllowedResultsTypes
	SVAR ControlRequireErrorWvs=root:Packages:IrenaControlProcs:ControlRequireErrorWvs

	string CntrlLocation="root:Packages:"+PckgDataFolder

	setDataFolder $(CntrlLocation)
	string TopPanel=PanelWindowName

//	//Experimental data input
	if(strlen(AllowedIrenaTypes)>0)
		CheckBox UseIndra2Data,pos={100,25},size={141,14},proc=IR2C_InputPanelCheckboxProc,title="Indra 2 data"
		CheckBox UseIndra2Data,variable= $(CntrlLocation+":UseIndra2data"), help={"Check, if you are using Indra 2 produced data with the orginal names, uncheck if the names of data waves are different"}
	endif
	CheckBox UseQRSData,pos={100,39},size={90,14},proc=IR2C_InputPanelCheckboxProc,title="QRS (QIS)"
	CheckBox UseQRSData,variable= $(CntrlLocation+":UseQRSdata"), help={"Check, if you are using QRS or QIS names, uncheck if the names of data waves are different"}
	if(strlen(AllowedResultsTypes)>0)
		CheckBox UseResults,pos={200,25},size={90,14},proc=IR2C_InputPanelCheckboxProc,title="Irena results"
		CheckBox UseResults,variable= $(CntrlLocation+":UseResults"), help={"Check, if you want to use results of Irena macros"}
	endif
	if(strlen(AllowedUserTypes)>0)
		CheckBox UseUserDefinedData,pos={200,39},size={90,14},proc=IR2C_InputPanelCheckboxProc,title=UserNameString
		CheckBox UseUserDefinedData,variable= $(CntrlLocation+":UseUserDefinedData"), help={"Check, if you want to use "+UserNameString+" data"}
	endif
	if(AllowModelData>0)
		CheckBox UseModelData,pos={300,25},size={90,14},proc=IR2C_InputPanelCheckboxProc,title="Model"
		CheckBox UseModelData,variable= $(CntrlLocation+":UseModelData"), help={"Check, if you want to generate Q data for modeling"}
	endif
	PopupMenu SelectDataFolder,pos={8,56},size={180,21},proc=IR2C_PanelPopupControl,title="Data folder:", help={"Select folder with data"}
	execute("PopupMenu SelectDataFolder,mode=1,popvalue=\"---\",value= \"---;\"+IR2P_GenStringOfFolders(winNm=\""+TopPanel+"\")")
	PopupMenu QvecDataName,pos={9,80},size={179,21},proc=IR2C_PanelPopupControl,title="Wave with X axis data  ", help={"Select wave with data to be used on X axis (Q, diameters, etc)"}
	execute("PopupMenu QvecDataName,mode=1,popvalue=\"---\",value= \"---;\"+IR2P_ListOfWaves(\"Xaxis\",\"*\",\""+TopPanel+"\")")
	PopupMenu IntensityDataName,pos={8,106},size={180,21},proc=IR2C_PanelPopupControl,title="Wave with Y axis data  ", help={"Select wave with data to be used on Y data (Intensity, distributions)"}
	//PopupMenu IntensityDataName,mode=1,popvalue="---",value= #"\"---;\"+IR2P_ListOfWaves(\"Yaxis\",\"*\",\""+PanelWindowName+"\")"
	execute("PopupMenu IntensityDataName,mode=1,popvalue=\"---\",value= \"---;\"+IR2P_ListOfWaves(\"Yaxis\",\"*\",\""+TopPanel+"\")")
	PopupMenu ErrorDataName,pos={10,133},size={178,21},proc=IR2C_PanelPopupControl,title="Wave with Error data   ", help={"Select wave with error data"}
	//PopupMenu ErrorDataName,mode=1,popvalue="---",value= #"\"---;\"+IR2P_ListOfWaves(\"Error\",\"*\",\""+PanelWindowName+"\")"
	execute("PopupMenu ErrorDataName,mode=1,popvalue=\"---\",value= \"---;\"+IR2P_ListOfWaves(\"Error\",\"*\",\""+TopPanel+"\")")

//	NewDataFolder/O/S PanelWindowName
//	Variable/G Qmin,Qmax,QNumPoints,QLogScale
	SetVariable Qmin, pos={8,60},size={220,20}, proc=IR2C_ModelQSetVarProc,title="Min value for Q [A]   ", help={"Value of Q min "}
	SetVariable Qmin, variable=$("root:Packages:IrenaControlProcs:"+possiblyQuoteName(PanelWindowName)+":Qmin"), limits={0,10,0}
	SetVariable Qmax, pos={8,85},size={220,20}, proc=IR2C_ModelQSetVarProc,title="Max value for Q [A]  ", help={"Value of Q max "}
	SetVariable Qmax, variable=$("root:Packages:IrenaControlProcs:"+possiblyQuoteName(PanelWindowName)+":Qmax"),limits={0,10,0}
	SetVariable QNumPoints, pos={8,110},size={220,20}, proc=IR2C_ModelQSetVarProc,title="Num points in Q        ", help={"Number of points in Q "}
	SetVariable QNumPoints, variable=$("root:Packages:IrenaControlProcs:"+possiblyQuoteName(PanelWindowName)+":QNumPoints"),limits={0,1e6,0}
	CheckBox QLogScale,pos={100,135},size={90,14},proc=IR2C_InputPanelCheckboxProc,title="Log-Q stepping?"
	CheckBox QLogScale,variable= $("root:Packages:IrenaControlProcs:"+possiblyQuoteName(PanelWindowName)+":QLogScale"), help={"Check, if you want to generate Q in log scale"}
	
	IR2C_FixDisplayedControls(TopPanel) 

	STRUCT WMSetVariableAction SV_Struct
	SV_Struct.ctrlName=""
	SV_Struct.dval=0
	SV_Struct.win=TopPanel
	SV_Struct.sVAL=""
	SV_Struct.vName=""
	SV_Struct.eventcode=2
	IR2C_ModelQSetVarProc(SV_Struct)
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR2C_ModelQSetVarProc(SV_Struct) : SetVariableControl
	STRUCT WMSetVariableAction &SV_Struct

	if(SV_Struct.eventcode<1 || SV_Struct.eventcode>5)
		return 0
	endif
	String ctrlName=SV_Struct.ctrlName
	Variable varNum=SV_Struct.dval
	String varStr=SV_Struct.sVal
	String varName=SV_Struct.vName

	string oldDf=GetDataFolder(1)
	string TopPanel=SV_Struct.win
	SVAR ControlProcsLocations=root:Packages:IrenaControlProcs:ControlProcsLocations
	SVAR ControlAllowedIrenaTypes=root:Packages:IrenaControlProcs:ControlAllowedIrenaTypes
	SVAR ControlAllowedResultsTypes=root:Packages:IrenaControlProcs:ControlAllowedResultsTypes
	SVAR ControlRequireErrorWvs=root:Packages:IrenaControlProcs:ControlRequireErrorWvs
	string CntrlLocation="root:Packages:"+StringByKey(TopPanel, ControlProcsLocations)
	
	NVAR UseIndra2Data=$(CntrlLocation+":UseIndra2Data")
	NVAR UseQRSData=$(CntrlLocation+":UseQRSData")
	NVAR UseResults=$(CntrlLocation+":UseResults")
	NVAR UseUserDefinedData=$(CntrlLocation+":UseUserDefinedData")
	NVAR UseModelData=$(CntrlLocation+":UseModelData")

	SVAR Dtf=$(CntrlLocation+":DataFolderName")
	SVAR IntDf=$(CntrlLocation+":IntensityWaveName")
	SVAR QDf=$(CntrlLocation+":QWaveName")
	SVAR EDf=$(CntrlLocation+":ErrorWaveName")

	setDataFolder $("root:Packages:IrenaControlProcs:"+possiblyQuoteName(TopPanel))

	NVAR Qmin
	NVAR Qmax
	NVAR QNumPoints
	NVAR QLogScale
	
	Make/O/N=(QNumPoints) ModelQ, ModelInt, ModelError
	ModelInt = 1
	ModelError = 0
	if(QLogScale)	//log scale
		ModelQ = 10^(log(Qmin)+p*((log(Qmax)-log(Qmin))/(QNumPoints-1))) 
	else
		ModelQ = Qmin + p * (Qmax - Qmin)/(QNumPoints-1)
	endif

	Dtf = "root:Packages:IrenaControlProcs:"+possiblyQuoteName(TopPanel)+":"
	IntDf = "ModelInt"
	QDf = "ModelQ"
	EDf = "ModelError"
	
	setDataFolder OldDf

End

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR2C_FixDisplayedControls(WnName) 
	string WnName

	string oldDf=GetDataFolder(1)
	string TopPanel=WnName
	//GetWindow $(TopPanel), activeSW		//fix for subwindow controls... This will add teh subwidnow which is selected, I hope that means in which we operate!
	//TopPanel=S_value
	SVAR ControlProcsLocations=root:Packages:IrenaControlProcs:ControlProcsLocations
	SVAR ControlAllowedIrenaTypes=root:Packages:IrenaControlProcs:ControlAllowedIrenaTypes
	SVAR ControlAllowedResultsTypes=root:Packages:IrenaControlProcs:ControlAllowedResultsTypes
	SVAR ControlRequireErrorWvs=root:Packages:IrenaControlProcs:ControlRequireErrorWvs
	string CntrlLocation="root:Packages:"+StringByKey(TopPanel, ControlProcsLocations)
	setDataFolder $(CntrlLocation)
	
	NVAR UseIndra2Data=$(CntrlLocation+":UseIndra2Data")
	NVAR UseQRSData=$(CntrlLocation+":UseQRSData")
	NVAR UseResults=$(CntrlLocation+":UseResults")
	NVAR UseUserDefinedData=$(CntrlLocation+":UseUserDefinedData")
	NVAR UseModelData=$(CntrlLocation+":UseModelData")


	if (UseModelData)
		PopupMenu SelectDataFolder disable=1, win=$(TopPanel)
		PopupMenu IntensityDataName disable=1, win=$(TopPanel)
		PopupMenu QvecDataName disable=1, win=$(TopPanel)
		PopupMenu ErrorDataName disable=1, win=$(TopPanel)
		SetVariable Qmin, disable=0, win=$(TopPanel)
		SetVariable Qmax, disable=0, win=$(TopPanel)
		SetVariable QNumPoints, disable=0, win=$(TopPanel)
		CheckBox QLogScale,disable=0, win=$(TopPanel)
	
	else
		PopupMenu SelectDataFolder disable=0, win=$(TopPanel)
		PopupMenu IntensityDataName disable=0, win=$(TopPanel)
		PopupMenu QvecDataName disable=0, win=$(TopPanel)
		PopupMenu ErrorDataName disable=0, win=$(TopPanel)
		SetVariable Qmin, disable=1, win=$(TopPanel)
		SetVariable Qmax, disable=1, win=$(TopPanel)
		SetVariable QNumPoints, disable=1, win=$(TopPanel)
		CheckBox QLogScale,disable=1, win=$(TopPanel)
	endif
	
	
	setDataFolder OldDf
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

//Function IR2C_InputPanelCheckboxProc(ctrlName,checked) : CheckBoxControl
//	String ctrlName
//	Variable checked

Function IR2C_InputPanelCheckboxProc(CB_Struct)
	STRUCT WMCheckboxAction &CB_Struct

	if(CB_Struct.eventcode<1 ||CB_Struct.eventcode>2)
		return 0
	endif
	
	String ctrlName=CB_Struct.ctrlName
	Variable checked=CB_Struct.checked
	string oldDf=GetDataFolder(1)
	string TopPanel=CB_Struct.win
	//string TopPanel=WinName(0,65)
	//GetWindow $(TopPanel), activeSW
	//TopPanel=S_value
	if(CB_Struct.eventcode!=2)
		return 0
	endif
	
	SVAR ControlProcsLocations=root:Packages:IrenaControlProcs:ControlProcsLocations
	SVAR ControlAllowedIrenaTypes=root:Packages:IrenaControlProcs:ControlAllowedIrenaTypes
	SVAR ControlAllowedResultsTypes=root:Packages:IrenaControlProcs:ControlAllowedResultsTypes
	SVAR ControlRequireErrorWvs=root:Packages:IrenaControlProcs:ControlRequireErrorWvs
	string CntrlLocation="root:Packages:"+StringByKey(TopPanel, ControlProcsLocations,":",";")
	setDataFolder $(CntrlLocation)
	
	NVAR UseIndra2Data=$(CntrlLocation+":UseIndra2Data")
	NVAR UseQRSData=$(CntrlLocation+":UseQRSData")
	NVAR UseResults=$(CntrlLocation+":UseResults")
	NVAR UseUserDefinedData=$(CntrlLocation+":UseUserDefinedData")
	NVAR UseModelData=$(CntrlLocation+":UseModelData")


	if (cmpstr(ctrlName,"UseIndra2Data")==0)
		//here we control the data structure checkbox
		if (checked)
			UseQRSData=0
			UseResults=0
			UseUserDefinedData=0
			UseModelData=0
			ControlRequireErrorWvs = ReplaceStringByKey(TopPanel, ControlRequireErrorWvs, "1"  , ":"  , ";")		//Indra 2 data do require errors, let user change that later, if needed.
		endif
	endif
	if (cmpstr(ctrlName,"UseQRSData")==0)
		//here we control the data structure checkbox
		if (checked)
			UseIndra2Data=0
			UseResults=0
			UseUserDefinedData=0
			UseModelData=0
		endif
	endif
	if (cmpstr(ctrlName,"UseResults")==0)
		//here we control the data structure checkbox
		if (checked)
			UseIndra2Data=0
			UseQRSData=0
			UseUserDefinedData=0
			UseModelData=0
		endif
	endif
	if (cmpstr(ctrlName,"UseUserDefinedData")==0)
		//here we control the data structure checkbox
		if (checked)
			UseIndra2Data=0
			UseQRSData=0
			UseResults=0
			UseModelData=0
		endif
	endif
	if (cmpstr(ctrlName,"UseModelData")==0)
		//here we control the data structure checkbox
		if (checked)
			UseIndra2Data=0
			UseQRSData=0
			UseResults=0
			UseUserDefinedData=0
		endif
	endif
	
	
//	if (cmpstr(ctrlName,"QLogScale")==0 || cmpstr(ctrlName,"UseModelData")==0)
	if ( cmpstr(ctrlName,"UseModelData")==0 || cmpstr(ctrlName,"QLogScale")==0)
		STRUCT WMSetVariableAction SV_Struct
		SV_Struct.ctrlName=""
		SV_Struct.dval=0
		SV_Struct.win=TopPanel
		SV_Struct.sVAL=""
		SV_Struct.vName=""
		SV_Struct.eventcode=2
		IR2C_ModelQSetVarProc(SV_Struct)			//here we create the model and stuff the values in the Dtf etc... 
	else				//in case we do not use model, this is the right thing to do... 
		SVAR Dtf=$(CntrlLocation+":DataFolderName")
		SVAR IntDf=$(CntrlLocation+":IntensityWaveName")
		SVAR QDf=$(CntrlLocation+":QWaveName")
		SVAR EDf=$(CntrlLocation+":ErrorWaveName")
			Dtf=" "
			IntDf=" "
			QDf=" "
			EDf=" "
			string TpPnl=TopPanel
			PopupMenu SelectDataFolder mode=1, win=$(TopPanel)
		//	PopupMenu IntensityDataName mode=1,value= #"\"---;\"+IR2P_ListOfWaves(\"Yaxis\",\"*\",\""+TpPnl+"\")", win=$(TopPanel)
			Execute ("PopupMenu IntensityDataName mode=1, value=\"---;\"+IR2P_ListOfWaves(\"Yaxis\",\"*\",\""+TpPnl+"\"), win="+TopPanel)
			Execute ("PopupMenu QvecDataName mode=1, value=\"---;\"+IR2P_ListOfWaves(\"Xaxis\",\"*\",\""+TpPnl+"\"), win="+TopPanel)
			Execute ("PopupMenu ErrorDataName mode=1, value=\"---;\"+IR2P_ListOfWaves(\"Error\",\"*\",\""+TpPnl+"\"), win="+TopPanel)
			//PopupMenu QvecDataName mode=1,value= #"\"---;\"+IR2P_ListOfWaves(\"Xaxis\",\"*\")", win=$(TopPanel)
			//PopupMenu ErrorDataName mode=1,value= #"\"---;\"+IR2P_ListOfWaves(\"Error\",\"*\")", win=$(TopPanel)
	endif
	IR2C_FixDisplayedControls(TopPanel) 
	
	setDataFolder OldDf
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function/T IR2P_CleanUpPckagesFolder(FolderList)
		string FolderList
		
		variable i
		string tempstr
		string newList=""
		For(I=0;i<ItemsInList(FolderList , ";" );i+=1)
			tempstr=StringFromList(i, FolderList , ";")
			if(!stringmatch(Tempstr,"root:packages:*"))
				NewList+=Tempstr+";"
			endif
		endfor
	return newList
//	return FolderList
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function/T IR2P_GenStringOfFolders([winNm])
	string winNm
	
	//part to copy everywhere...	
	string oldDf=GetDataFolder(1)
	string TopPanel
	if( ParamIsDefault(winNm))
		TopPanel=WinName(0,65)
	else
		TopPanel=winNm
	endif
	//string TopPanel=winNm
//	string TopPanel=WinName(0,65)
//	GetWindow $(TopPanel), activeSW
//	TopPanel=S_Value
	SVAR ControlProcsLocations=root:Packages:IrenaControlProcs:ControlProcsLocations
	SVAR ControlAllowedIrenaTypes=root:Packages:IrenaControlProcs:ControlAllowedIrenaTypes
	SVAR ControlAllowedUserTypes=root:Packages:IrenaControlProcs:ControlAllowedUserTypes
	SVAR ControlAllowedResultsTypes=root:Packages:IrenaControlProcs:ControlAllowedResultsTypes
	SVAR ControlRequireErrorWvs=root:Packages:IrenaControlProcs:ControlRequireErrorWvs
	string CntrlLocation="root:Packages:"+StringByKey(TopPanel, ControlProcsLocations)
	string LocallyAllowedUserData=StringByKey(TopPanel, ControlAllowedUserTypes,"=",">")
	string LocallyAllowedIndra2Data=StringByKey(TopPanel, ControlAllowedIrenaTypes,"=",">")
	string LocallyAllowedResultsData=StringByKey(TopPanel, ControlAllowedResultsTypes,"=",">")
	setDataFolder $(CntrlLocation)

	NVAR UseIndra2Structure=$(CntrlLocation+":UseIndra2Data")
	NVAR UseQRSStructure=$(CntrlLocation+":UseQRSData")
	NVAR UseResults=$(CntrlLocation+":UseResults")
	NVAR UseUserDefinedData=$(CntrlLocation+":UseUserDefinedData")
	SVAR Dtf=$(CntrlLocation+":DataFolderName")
	SVAR IntDf=$(CntrlLocation+":IntensityWaveName")
	SVAR QDf=$(CntrlLocation+":QWaveName")
	SVAR EDf=$(CntrlLocation+":ErrorWaveName")
	///endof common block  
	
	string ListOfQFolders
	string result="", tempResult
	variable i, j, StartTime, AlreadyIn
	string tempStr="", temp1, temp2, temp3
	if (UseIndra2Structure)
		tempResult=IN2G_FindFolderWithWvTpsList("root:USAXS:", 10,LocallyAllowedIndra2Data, 1) //contains list of all folders which contain any of the tested Intensity waves...
		//now prune the folders off the ones which do not contain full triplet of waves...
		For(j=0;j<ItemsInList(tempResult);j+=1)			//each folder one by one
			temp1 = stringFromList(j,tempResult)
			//AlreadyIn=0
			for(i=0;i<ItemsInList(LocallyAllowedIndra2Data);i+=1)			//each type of data one by one...
				temp2=stringFromList(i,LocallyAllowedIndra2Data)
				if(cmpstr("---",IR2P_CheckForRightIN2TripletWvs(TopPanel,stringFromList(j,tempResult),stringFromList(i,LocallyAllowedIndra2Data)))!=0 )//&& AlreadyIn<1)
					//AlreadyIn=1
					result += stringFromList(j,tempResult)+";"
					break
				endif
			endfor
		endfor	
	elseif (UseQRSStructure)
		ListOfQFolders=IR2P_CheckForRightQRSTripletWvs(TopPanel,IN2G_NewFindFolderWithWaveTypes("root:", 10, "*r*", 1)+IN2G_NewFindFolderWithWaveTypes("root:", 10, "*i*", 1))
		ListOfQFolders=IR2P_RemoveDuplicateFolders(ListOfQFolders)
		ListOfQFolders=IR2P_CleanUpPckagesFolder(ListOfQFolders)
		result=ListOfQFolders
	elseif (UseResults)
		temp3=""
		For(i=0;i<ItemsInList(LocallyAllowedResultsData);i+=1)
			temp3+=stringFromList(i,LocallyAllowedResultsData)+"*;"
		endfor
		tempResult=IN2G_FindFolderWithWvTpsList("root:", 10,temp3, 1) //contains list of all folders which contain any of the tested Y waves... But may not contain the whole duplex of waves...
		tempResult=IR2P_CleanUpPckagesFolder(tempResult)
		//result=tempResult+";"
		//the following will remove the folders which accidentally contain not-full duplex of waves and display ONLY folders with the right duplexes of waves.... 
		result = IR2P_CheckForRightINResultsWvs(TopPanel,tempResult)
	elseif (UseUserDefinedData)
		tempResult=IN2G_FindFolderWithWvTpsList("root:", 10,LocallyAllowedUserData, 1) //contains list of all folders which contain any of the tested Intensity waves...
		tempResult=IR2P_CleanUpPckagesFolder(tempResult)
		//now prune the folders off the ones which do not contain full triplet of waves...
		For(j=0;j<ItemsInList(tempResult);j+=1)			//each folder one by one
			temp1 = stringFromList(j,tempResult)
			for(i=0;i<ItemsInList(LocallyAllowedUserData);i+=1)			//each type of data one by one...
				temp2=stringFromList(i,LocallyAllowedUserData)
				if(cmpstr("---",IR2P_CheckForRightUsrTripletWvs(TopPanel,stringFromList(j,tempResult),stringFromList(i,LocallyAllowedUserData)))!=0 )//&& AlreadyIn<1)
					result += stringFromList(j,tempResult)+";"
					break
				endif
			endfor
		endfor	
	else
		result=IN2G_NewFindFolderWithWaveTypes("root:", 10, "*", 1)
	endif
	setDataFolder OldDf
	return result
end
//*****************************************************************************************************************
//*****************************************************************************************************************
static Function/T IR2P_RemoveDuplicateFolders(FldrList)
	string FldrList
	
	variable i
	string result=""
	For(i=0;i<ItemsInList(FldrList,";");i+=1)
		if(!stringmatch(result, "*"+stringFromList(i,FldrList,";")+"*" ))
			result+=stringFromList(i,FldrList,";")+";"
		endif
	endfor
	return result
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function/T IR2P_ReturnListQRSFolders(ListOfQFolders, AllowQROnly)
	string ListOfQFolders
	variable AllowQROnly
	
	if(cmpstr(ListOfQFolders,"---")==0)
		return "---"
	endif
	
	string result, tempStringQ, tempStringR, tempStringS, nowFolder,oldDf
	oldDf=GetDataFolder(1)
	variable i, j
	result=""
	For(i=0;i<ItemsInList(ListOfQFolders);i+=1)
		NowFolder= stringFromList(i,ListOfQFolders)
		setDataFolder NowFolder
		tempStringQ=IR2P_ListOfWavesOfType("q*",IN2G_ConvertDataDirToList(DataFolderDir(2)))
		tempStringR=IR2P_ListOfWavesOfType("r*",IN2G_ConvertDataDirToList(DataFolderDir(2)))
		tempStringS=IR2P_ListOfWavesOfType("s*",IN2G_ConvertDataDirToList(DataFolderDir(2)))
		For (j=0;j<ItemsInList(tempStringQ);j+=1)
			if(AllowQROnly)
				if (stringMatch(tempStringR,"*r"+StringFromList(j,tempStringQ)[1,inf]+";*"))
					result+=NowFolder+";"
					break
				endif
			else
				if (stringMatch(tempStringR,"*r"+StringFromList(j,tempStringQ)[1,inf]+";*") && stringMatch(tempStringS,"*s"+StringFromList(j,tempStringQ)[1,inf]+";*"))
					result+=NowFolder+";"
					break
				endif
			endif
		endfor
				
	endfor
	setDataFOlder oldDf
	return result

end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
static Function/T IR2P_CheckForRightINResultsWvs(TopPanel, FullFldrNames)
	string TopPanel, FullFldrNames

	string oldDf=GetDataFolder(1)
	SVAR ControlProcsLocations=root:Packages:IrenaControlProcs:ControlProcsLocations
	SVAR ControlAllowedIrenaTypes=root:Packages:IrenaControlProcs:ControlAllowedIrenaTypes
	SVAR ControlAllowedResultsTypes=root:Packages:IrenaControlProcs:ControlAllowedResultsTypes
	SVAR ControlRequireErrorWvs=root:Packages:IrenaControlProcs:ControlRequireErrorWvs
	SVAR XwaveDataTypesLookup=root:Packages:IrenaControlProcs:XwaveDataTypesLookup
	SVAR EwaveDataTypesLookup=root:Packages:IrenaControlProcs:EwaveDataTypesLookup
	SVAR ResultsDataTypesLookup=root:Packages:IrenaControlProcs:ResultsDataTypesLookup
	SVAR ResultsEDataTypesLookup = root:Packages:IrenaControlProcs:ResultsEDataTypesLookup
	
	string CntrlLocation="root:Packages:"+StringByKey(TopPanel, ControlProcsLocations)
	string LocallyAllowedIndra2Data=StringByKey(TopPanel, ControlAllowedIrenaTypes,"=",">")
	string LocallyAllowedResultsData=StringByKey(TopPanel, ControlAllowedResultsTypes,"=",">")
	string XwaveType//=stringByKey(DataTypeSearchedFor,XwaveDataTypesLookup)
	string EwaveType//=stringByKey(DataTypeSearchedFor,EwaveDataTypesLookup)
	variable RequireErrorWvs = numberByKey(TopPanel, ControlRequireErrorWvs)
	string result=""
	string tempResult="" , FullFldrName
 	variable i,j,jj, matchX=0,matchE=0
	string AllWaves, allYwaves, currentYWave,currentXWave, currentEwave
	
	for(i=0;i<ItemsInList(FullFldrNames);i+=1)
		FullFldrName = stringFromList(i,FullFldrNames)
		AllWaves = IN2G_CreateListOfItemsInFolder(FullFldrName,2)
		matchX=0
		tempresult=""
		For(j=0;j<ItemsInList(LocallyAllowedResultsData);j+=1)
			allYwaves=IR2P_ListOfWavesOfType(stringFromList(j,LocallyAllowedResultsData)+"_*",AllWaves)
			For(jj=0;jj<ItemsInList(allYWaves);jj+=1)
				currentYWave=stringFromList(jj,AllYWaves)
				currentXWave = StringByKey(StringFromList(0,currentYWave,"_"), ResultsDataTypesLookup)
				currentEwave = StringByKey(StringFromList(0,currentYWave,"_"), ResultsEDataTypesLookup)
				if(stringmatch(";"+AllWaves, "*;"+currentXWave+"_"+StringFromList(1,currentYWave,"_")+"*" ) || cmpstr("x-scaling",currentXWave)==0)
					matchX=1
					tempresult=FullFldrName+";"
					break
				endif
			endfor
			if(matchX)
				break	
			endif
		endfor
		result+=tempresult
	endfor
	if(strlen(result)>1)
		return result
	else
		return "---"
	endif
//		AllWaves = IN2G_CreateListOfItemsInFolder(FullFldrNames,2)
//
//		For(j=0;j<ItemsInList(LocallyAllowedResultsData);j+=1)
//			allYwaves=IR2P_ListOfWavesOfType(stringFromList(j,LocallyAllowedResultsData)+"_*",AllWaves)
//			For(jj=0;jj<ItemsInList(allYWaves);jj+=1)
//				currentYWave=stringFromList(jj,AllYWaves)
//				currentXWave = StringByKey(StringFromList(0,currentYWave,"_"), ResultsDataTypesLookup)
//				if(stringmatch(";"+AllWaves, "*;"+currentXWave+"_"+StringFromList(1,currentYWave,"_")+"*" ))
//					return 1
//				endif
//			endfor
//		endfor
//	return 0	
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//**********************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
static Function/T IR2P_CheckForRightQRSTripletWvs(TopPanel, FullFldrNames)
	string TopPanel, FullFldrNames

	string oldDf=GetDataFolder(1)
	SVAR ControlProcsLocations=root:Packages:IrenaControlProcs:ControlProcsLocations
	SVAR ControlAllowedIrenaTypes=root:Packages:IrenaControlProcs:ControlAllowedIrenaTypes
	SVAR ControlAllowedResultsTypes=root:Packages:IrenaControlProcs:ControlAllowedResultsTypes
	SVAR ControlRequireErrorWvs=root:Packages:IrenaControlProcs:ControlRequireErrorWvs
	SVAR XwaveDataTypesLookup=root:Packages:IrenaControlProcs:XwaveDataTypesLookup
	SVAR EwaveDataTypesLookup=root:Packages:IrenaControlProcs:EwaveDataTypesLookup
	string CntrlLocation="root:Packages:"+StringByKey(TopPanel, ControlProcsLocations)
	string LocallyAllowedIndra2Data=StringByKey(TopPanel, ControlAllowedIrenaTypes,"=",">")
	string LocallyAllowedResultsData=StringByKey(TopPanel, ControlAllowedResultsTypes,"=",">")
	variable RequireErrorWvs = numberByKey(TopPanel, ControlRequireErrorWvs)
	string result=""
	string tempResult="" , FullFldrName
 	variable i,j, matchX=0,matchE=0
	string AllWaves
	string allRwaves

	variable startTime=ticks	
	for(i=0;i<ItemsInList(FullFldrNames);i+=1)			//this looks for qrs tripplets
		FullFldrName = stringFromList(i,FullFldrNames)
		AllWaves = IN2G_CreateListOfItemsInFolder(FullFldrName,2)
		allRwaves=IR2P_ListOfWavesOfType("r*",AllWaves)
		tempresult=""
			for(j=0;j<ItemsInList(allRwaves);j+=1)
				matchX=0
				matchE=0
				if(stringmatch(";"+AllWaves, ";*q"+stringFromList(j,allRwaves)[1,inf]+";*" ))
					matchX=1
				endif
				if(stringmatch(";"+AllWaves,";*s"+stringFromList(j,allRwaves)[1,inf]+";*" ))
					matchE=1
				endif
				if(matchX && (matchE || !RequireErrorWvs))
					tempResult+= FullFldrName+";"
					break
				endif
			endfor
			result+=tempresult
	endfor
	for(i=0;i<ItemsInList(FullFldrNames);i+=1)			//and this for qis NIST standard
		FullFldrName = stringFromList(i,FullFldrNames)
		AllWaves = IN2G_CreateListOfItemsInFolder(FullFldrName,2)
		allRwaves=IR2P_ListOfWavesOfType("*i",AllWaves)
		tempresult=""
			for(j=0;j<ItemsInList(allRwaves);j+=1)
				matchX=0
				matchE=0
				if(stringmatch(";"+AllWaves, ";*"+stringFromList(j,allRwaves)[0,strlen(stringFromList(j,allRwaves))-2]+"q;*" ))
					matchX=1
				endif
				if(stringmatch(";"+AllWaves,";*"+stringFromList(j,allRwaves)[0,strlen(stringFromList(j,allRwaves))-2]+"s;*" ))
					matchE=1
				endif
				if(matchX && matchE)
					tempResult+= FullFldrName+";"
					break
				endif
			endfor
			result+=tempresult
	endfor
//	print ticks-startTime
	if(strlen(result)>1)
		return result
	else
		return "---"
	endif
	
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function/T IR2P_ListOfWavesOfType(type,ListOfWaves)
		string type, ListOfWaves
		
		variable i
		string tempresult=""
		for (i=0;i<ItemsInList(ListOfWaves);i+=1)
			if (stringMatch(StringFromList(i,ListOfWaves),type))
				tempresult+=StringFromList(i,ListOfWaves)+";"
			endif
		endfor

	return tempresult
//	string tempType=""
//	if(GrepString(type, "^\*" ) )
//		tempType = type[1,1]+"$"
//	else
//		tempType = "^"+type[0,0]
//	endif
////	print type+"   "+tempType
//	return grepList(ListOfWaves, "(?i)"+tempType)
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//**************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
static Function/T IR2P_CheckForRightUsrTripletWvs(TopPanel, FullFldrNames,DataTypeSearchedFor)
	string TopPanel, FullFldrNames,DataTypeSearchedFor

	string oldDf=GetDataFolder(1)
	SVAR ControlProcsLocations=root:Packages:IrenaControlProcs:ControlProcsLocations
	SVAR ControlAllowedIrenaTypes=root:Packages:IrenaControlProcs:ControlAllowedIrenaTypes
	SVAR ControlAllowedUserTypes=root:Packages:IrenaControlProcs:ControlAllowedUserTypes
	SVAR ControlAllowedResultsTypes=root:Packages:IrenaControlProcs:ControlAllowedResultsTypes
	SVAR ControlRequireErrorWvs=root:Packages:IrenaControlProcs:ControlRequireErrorWvs
	SVAR XwaveDataTypesLookup=root:Packages:IrenaControlProcs:XwaveDataTypesLookup
	SVAR EwaveDataTypesLookup=root:Packages:IrenaControlProcs:EwaveDataTypesLookup
	SVAR XwaveUserDataTypesLookup=root:Packages:IrenaControlProcs:XwaveUserDataTypesLookup
	SVAR EwaveUserDataTypesLookup=root:Packages:IrenaControlProcs:EwaveUserDataTypesLookup
	string CntrlLocation="root:Packages:"+StringByKey(TopPanel, ControlProcsLocations)
	string LocallyAllowedIndra2Data=StringByKey(TopPanel, ControlAllowedIrenaTypes,"=",">")
	string LocallyAllowedUserData=StringByKey(TopPanel, ControlAllowedUserTypes,"=",">")
	string LocallyAllowedResultsData=StringByKey(TopPanel, ControlAllowedResultsTypes,"=",">")
	string XwaveType=stringByKey(DataTypeSearchedFor,XwaveUserDataTypesLookup)
	string EwaveType=stringByKey(DataTypeSearchedFor,EwaveUserDataTypesLookup)
	variable RequireErrorWvs = numberByKey(TopPanel, ControlRequireErrorWvs)
	string result=""
	string tempResult="" , FullFldrName
 	variable i,j, matchX=0,matchE=0
	string AllWaves, allRwaves
	string LocallyAllowedUserXData=stringFromList(0,StringByKey(DataTypeSearchedFor, XwaveUserDataTypesLookup , ":", ";"),"*")
	string LocallyAllowedUserEData=stringFromList(0,StringByKey(DataTypeSearchedFor, EwaveUserDataTypesLookup , ":", ";"),"*")
	
	for(i=0;i<ItemsInList(FullFldrNames);i+=1)
		FullFldrName = stringFromList(i,FullFldrNames)
		if(grepstring(DataTypeSearchedFor,"\*"))			//the match contains *, assume semi qrs type...... The data type is Q*, r*, s*
			AllWaves = IN2G_CreateListOfItemsInFolder(FullFldrName,2)
			allRwaves=IR2P_ListOfWavesOfType(DataTypeSearchedFor,AllWaves)
			tempresult=""
			for(j=0;j<ItemsInList(allRwaves);j+=1)
				matchX=0
				matchE=0
				if(stringmatch(";"+AllWaves, ";*"+LocallyAllowedUserXData+stringFromList(j,allRwaves)[strlen(LocallyAllowedUserXData),inf]+";*" )||stringmatch(XwaveType,"x-scaling"))
					matchX=1
				endif
				if(stringmatch(";"+AllWaves,";*"+LocallyAllowedUserEData+stringFromList(j,allRwaves)[strlen(LocallyAllowedUserEData),inf]+";*" ))
					matchE=1
				endif
				if(matchX && (matchE || !RequireErrorWvs))
					tempResult+= FullFldrName+";"
					break
				endif
			endfor
			result+=tempresult
		else												//asume Indra2 type system
			AllWaves = IN2G_CreateListOfItemsInFolder(FullFldrName,2)
			matchX=0
			matchE=0
			if(stringmatch(";"+AllWaves, "*;"+XwaveType+";*" )||stringmatch(XwaveType,"x-scaling"))
				matchX=1
			endif
			if(stringmatch(";"+AllWaves, "*;"+EwaveType+";*" ))
				matchE=1
			endif
			if(matchX && (matchE || !RequireErrorWvs))
				tempResult+= FullFldrName+";"
			endif
			result+=tempresult
		endif
	endfor
	if(strlen(result)>1)
		return result
	else
		return "---"
	endif
	
end
//*****************************************************************************************************************
//**********************************************************************************************************
//**************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
static Function/T IR2P_CheckForRightIN2TripletWvs(TopPanel, FullFldrNames,DataTypeSearchedFor)
	string TopPanel, FullFldrNames,DataTypeSearchedFor

	string oldDf=GetDataFolder(1)
	SVAR ControlProcsLocations=root:Packages:IrenaControlProcs:ControlProcsLocations
	SVAR ControlAllowedIrenaTypes=root:Packages:IrenaControlProcs:ControlAllowedIrenaTypes
	SVAR ControlAllowedResultsTypes=root:Packages:IrenaControlProcs:ControlAllowedResultsTypes
	SVAR ControlRequireErrorWvs=root:Packages:IrenaControlProcs:ControlRequireErrorWvs
	SVAR XwaveDataTypesLookup=root:Packages:IrenaControlProcs:XwaveDataTypesLookup
	SVAR EwaveDataTypesLookup=root:Packages:IrenaControlProcs:EwaveDataTypesLookup
	string CntrlLocation="root:Packages:"+StringByKey(TopPanel, ControlProcsLocations)
	string LocallyAllowedIndra2Data=StringByKey(TopPanel, ControlAllowedIrenaTypes,"=",">")
	string LocallyAllowedResultsData=StringByKey(TopPanel, ControlAllowedResultsTypes,"=",">")
	string XwaveType=stringByKey(DataTypeSearchedFor,XwaveDataTypesLookup)
	string EwaveType=stringByKey(DataTypeSearchedFor,EwaveDataTypesLookup)
	variable RequireErrorWvs = numberByKey(TopPanel, ControlRequireErrorWvs)
	string result=""
	string tempResult="" , FullFldrName
 	variable i,j, matchX=0,matchE=0
	string AllWaves
	
	for(i=0;i<ItemsInList(FullFldrNames);i+=1)
		FullFldrName = stringFromList(i,FullFldrNames)
		AllWaves = IN2G_CreateListOfItemsInFolder(FullFldrName,2)
		matchX=0
		matchE=0
		if(stringmatch(";"+AllWaves, "*;"+XwaveType+";*" ))
			matchX=1
		endif
		if(stringmatch(";"+AllWaves, "*;"+EwaveType+";*" ))
			matchE=1
		endif
		if(matchX && (matchE || !RequireErrorWvs))
			tempResult+= FullFldrName+";"
		endif
		result+=tempresult
	endfor
	if(strlen(result)>1)
		return result
	else
		return "---"
	endif
	
end
//**********************************************************************************************************
//**************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function/T IR2P_ListOfWaves(DataType,MatchMeTo, winNm)
	string DataType, MatchMeTo, winNm			//data type   : Xaxis, Yaxis, Error
										//Match me to is string to match the type to... Use "*" to get all... Applicable ONLY to Y and error data
	string oldDf=GetDataFolder(1)
	string TopPanel=winNm
//	string TopPanel=WinName(0,65)
//	GetWindow $(TopPanel), activeSW
//	TopPanel = S_Value
	SVAR ControlProcsLocations=root:Packages:IrenaControlProcs:ControlProcsLocations
	SVAR ControlAllowedIrenaTypes=root:Packages:IrenaControlProcs:ControlAllowedIrenaTypes
	SVAR ControlAllowedResultsTypes=root:Packages:IrenaControlProcs:ControlAllowedResultsTypes
	SVAR ControlAllowedUserTypes=root:Packages:IrenaControlProcs:ControlAllowedUserTypes
	SVAR ControlRequireErrorWvs=root:Packages:IrenaControlProcs:ControlRequireErrorWvs
	SVAR XwaveDataTypesLookup=root:Packages:IrenaControlProcs:XwaveDataTypesLookup
	SVAR EwaveDataTypesLookup=root:Packages:IrenaControlProcs:EwaveDataTypesLookup
	SVAR ResultsDataTypesLookup=root:Packages:IrenaControlProcs:ResultsDataTypesLookup
	SVAR XwaveUserDataTypesLookup=root:Packages:IrenaControlProcs:XwaveUserDataTypesLookup
	SVAR EwaveUserDataTypesLookup=root:Packages:IrenaControlProcs:EwaveUserDataTypesLookup
	SVAR ResultsEDataTypesLookup=root:Packages:IrenaControlProcs:ResultsEDataTypesLookup
	
	string CntrlLocation="root:Packages:"+StringByKey(TopPanel, ControlProcsLocations)
	string LocallyAllowedIndra2Data=StringByKey(TopPanel, ControlAllowedIrenaTypes,"=",">")
	string LocallyAllowedResultsData=StringByKey(TopPanel, ControlAllowedResultsTypes,"=",">")
	string LocallyAllowedUserData=StringByKey(TopPanel, ControlAllowedUserTypes,"=",">")
//	string XwaveType=stringByKey(DataTypeSearchedFor,XwaveDataTypesLookup)
//	string EwaveType=stringByKey(DataTypeSearchedFor,EwaveDataTypesLookup)
	variable RequireErrorWvs = numberByKey(TopPanel, ControlRequireErrorWvs)

	NVAR UseIndra2Structure=$(CntrlLocation+":UseIndra2Data")
	NVAR UseQRSStructure=$(CntrlLocation+":UseQRSData")
	NVAR UseUserDefinedData=$(CntrlLocation+":UseUserDefinedData")
	NVAR UseResults=$(CntrlLocation+":UseResults")
	SVAR Dtf=$(CntrlLocation+":DataFolderName")
	SVAR IntDf=$(CntrlLocation+":IntensityWaveName")
	SVAR QDf=$(CntrlLocation+":QWaveName")
	SVAR EDf=$(CntrlLocation+":ErrorWaveName")

	string result="", tempresult="", tempStringX="", tempStringY="", tempStringE="", listOfXWvs="", Endstr="", tempstringX2="", tempstringY2="", tempstringE2="", existingYWvs, existingXWvs, existingEWvs,tmpp, tmpstr2
	variable i,j, jj
	variable setControls
	tempresult=""
	setControls=0
	tempresult=IN2G_CreateListOfItemsInFolder(Dtf,2)
	if (UseIndra2Structure)
		if(cmpstr(DataType,"Xaxis")==0)
			for(i=0;i<itemsInList(LocallyAllowedIndra2Data);i+=1)
				tempStringY=stringFromList(i,LocallyAllowedIndra2Data)
				tempStringX=stringByKey(tempStringY,XwaveDataTypesLookup)
				tempStringE=stringByKey(tempStringY,EwaveDataTypesLookup)
				if(stringmatch(";"+tempresult, "*;"+tempStringY+";*") && stringmatch(";"+tempresult, "*;"+tempStringX+";*") && (!RequireErrorWvs || stringmatch(";"+tempresult, "*;"+tempStringE+";*")))
					result+=tempStringX+";"
					if(setControls==0)
						IntDf=tempStringY
						QDf=tempStringX
						EDf=tempStringE
						setControls=1
					endif
				endif
			endfor
		elseif(cmpstr(DataType,"Yaxis")==0)
			for(i=0;i<itemsInList(LocallyAllowedIndra2Data);i+=1)
				tempStringY=stringFromList(i,LocallyAllowedIndra2Data)
				tempStringX=stringByKey(tempStringY,XwaveDataTypesLookup)
				tempStringE=stringByKey(tempStringY,EwaveDataTypesLookup)
				if(stringmatch(";"+tempresult, "*;"+tempStringY+";*") && stringmatch(";"+tempresult, "*;"+tempStringX+";*") && (!RequireErrorWvs || stringmatch(";"+tempresult, "*;"+tempStringE+";*")))
					if(cmpstr(MatchMeTo,"*")==0 || cmpstr(stringByKey(tempStringY,XwaveDataTypesLookup),MatchMeTo)==0)
						result+=tempStringY+";"
					endif
				endif
			endfor
		elseif(cmpstr(DataType,"Error")==0)
			for(i=0;i<itemsInList(LocallyAllowedIndra2Data);i+=1)
				tempStringY=stringFromList(i,LocallyAllowedIndra2Data)
				tempStringX=stringByKey(tempStringY,XwaveDataTypesLookup)
				tempStringE=stringByKey(tempStringY,EwaveDataTypesLookup)
				if(stringmatch(";"+tempresult, "*;"+tempStringY+";*") && stringmatch(";"+tempresult, "*;"+tempStringX+";*") && (!RequireErrorWvs || stringmatch(";"+tempresult, "*;"+tempStringE+";*")))
					if(cmpstr(MatchMeTo,"*")==0 || cmpstr(stringByKey(tempStringY,XwaveDataTypesLookup),MatchMeTo)==0)
						result+=tempStringE+";"
					endif
				endif
			endfor
		endif
	elseif(UseUserDefinedData) 
		if(cmpstr(DataType,"Xaxis")==0)
			for(i=0;i<itemsInList(LocallyAllowedUserData);i+=1)
				tempStringY=stringFromList(i,LocallyAllowedUserData)
				tempStringX=stringByKey(tempStringY,XwaveUserDataTypesLookup)
				tempStringE=stringByKey(tempStringY,EwaveUserDataTypesLookup)
				existingYWvs=IR2P_ListOfWavesOfType(tempStringY,tempresult)
				existingXWvs=IR2P_ListOfWavesOfType(tempStringX,tempresult)
				existingEWvs=IR2P_ListOfWavesOfType(tempStringE,tempresult)
				tmpp=replaceString("*",tempStringY,"&")
				if(stringmatch(tmpp, "*&" ))		//Star was at the end,, so we need to match the end of the wave names
					tempstringY2=stringFromList(0,tempstringY,"*")
					tempstringX2=stringFromList(0,tempstringX,"*")
					tempstringE2=stringFromList(0,tempstringE,"*")
					For (j=0;j<ItemsInList(existingXWvs);j+=1)
						if (stringMatch(";"+existingYWvs,"*;"+tempstringY2+StringFromList(j,existingXWvs)[strlen(tempstringX2),inf]+";*") && (!RequireErrorWvs || stringMatch(";"+existingEWvs,"*;"+tempstringE2+StringFromList(j,existingXWvs)[strlen(tempstringX2),inf])))
							result+=StringFromList(j,existingXWvs)+";"
							if(setControls==0)
								IntDf=tempstringY2+StringFromList(j,existingXWvs)[strlen(tempstringX2),inf]
								QDf=StringFromList(j,existingXWvs)
								if(stringMatch(";"+existingEWvs,"*"+tempstringE2+StringFromList(j,existingXWvs)[strlen(tempstringX2),inf]))
									EDf=tempstringE2+StringFromList(j,existingXWvs)[strlen(tempstringX2),inf]
								else
									EDf="---"
								endif
								setControls=1
							endif
						endif
					endfor
				
				elseif(stringmatch(tmpp, "&*" ))						//assume IN2 type data, we need to match the front parts of the wave names...
					if(stringmatch(";"+tempresult, "*;"+tempStringY+";*") && stringmatch(";"+tempresult, "*;"+tempStringX+";*") && (!RequireErrorWvs || stringmatch(";"+tempresult, "*;"+tempStringE+";*")))
						//result+=tempStringX+";"
						result = IR2P_ListOfWavesOfType(tempStringX,tempresult)
						if(setControls==0)
						//	IntDf=tempStringY
						//	QDf=tempStringX
							IntDf=stringFromList(0,IR2P_ListOfWavesOfType(tempStringY,tempresult))
							QDf=stringFromList(0,IR2P_ListOfWavesOfType(tempStringX,tempresult))
							if(stringmatch(";"+tempresult, "*;"+tempStringE+";*"))
								//EDf=tempStringE
								EDf=stringFromList(0,IR2P_ListOfWavesOfType(tempStringE,tempresult))
							else
								EDf="---"
							endif
							setControls=1
						endif
					endif
				else //assume there is not match string to deal with
					if(stringmatch(";"+tempresult, "*;"+tempStringY+";*") && stringmatch(";"+tempresult, "*;"+tempStringX+";*") && (!RequireErrorWvs || stringmatch(";"+tempresult, "*;"+tempStringE+";*")))
						//result+=tempStringX+";"
						result += IR2P_ListOfWavesOfType(tempStringX,tempresult)
						if(setControls==0)
						//	IntDf=tempStringY
						//	QDf=tempStringX
							IntDf=stringFromList(0,IR2P_ListOfWavesOfType(tempStringY,tempresult))
							QDf=stringFromList(0,IR2P_ListOfWavesOfType(tempStringX,tempresult))
							if(stringmatch(";"+tempresult, "*;"+tempStringE+";*"))
								//EDf=tempStringE
								EDf=stringFromList(0,IR2P_ListOfWavesOfType(tempStringE,tempresult))
							else
								EDf="---"
							endif
							setControls=1
						endif
					endif
				endif	
			endfor
		elseif(cmpstr(DataType,"Yaxis")==0)
			for(i=0;i<itemsInList(LocallyAllowedUserData);i+=1)
				tempStringY=stringFromList(i,LocallyAllowedUserData)
				tempStringX=stringByKey(tempStringY,XwaveUserDataTypesLookup)
				tempStringE=stringByKey(tempStringY,EwaveUserDataTypesLookup)
				existingYWvs=IR2P_ListOfWavesOfType(tempStringY,tempresult)
				existingXWvs=IR2P_ListOfWavesOfType(tempStringX,tempresult)
				existingEWvs=IR2P_ListOfWavesOfType(tempStringE,tempresult)
				tmpp=replaceString("*",tempStringY,"&")
				if(stringmatch(tmpp, "*&" ))		//assume qrs type data
					tempstringY2=stringFromList(0,tempstringY,"*")
					tempstringX2=stringFromList(0,tempstringX,"*")
					tempstringE2=stringFromList(0,tempstringE,"*")
					For (j=0;j<ItemsInList(existingYWvs);j+=1)
						if (stringMatch(";"+existingXWvs,"*;"+tempstringX2+StringFromList(j,existingYWvs)[strlen(tempstringY2),inf]+";*") && (!RequireErrorWvs || stringMatch(";"+existingEWvs,"*;"+tempstringE2+StringFromList(j,existingXWvs)[strlen(tempstringX2),inf])))
							if(cmpstr(MatchMeTo,"*")==0 || cmpstr(StringFromList(j,existingYWvs)[strlen(tempstringY2),inf],MatchMeTo[strlen(tempstringX2),inf])==0)
								result+=StringFromList(j,existingYWvs)+";"
							endif
						endif
					endfor
				
				elseif(stringmatch(tmpp, "&*" ))						//assume IN2 type data
					tempstringY2=stringFromList(1,tempstringY,"*")
					tempstringX2=stringFromList(1,tempstringX,"*")
					tempstringE2=stringFromList(1,tempstringE,"*")
					For (j=0;j<ItemsInList(existingYWvs);j+=1)
						if (stringMatch(";"+existingXWvs,"*;"+StringFromList(j,existingYWvs)[0,strlen(StringFromList(j,existingYWvs))-strlen(tempstringY)]+tempstringX2+";*") && (!RequireErrorWvs || stringMatch(";"+existingEWvs,"*;"+StringFromList(j,existingYWvs)[0,strlen(StringFromList(j,existingYWvs))-strlen(tempstringY)]+tempstringE2+";*")))
							if(cmpstr(MatchMeTo,"*")==0 || cmpstr(StringFromList(j,existingYWvs)[strlen(tempstringY),inf],MatchMeTo[strlen(tempstringX),inf])==0)
								result+=StringFromList(j,existingYWvs)+";"
							endif
						endif
					endfor
				else				//assume data which may not have any match string... 
					tempstringY2=tempstringY
					tempstringX2=tempstringX
					tempstringE2=tempstringE
					For (j=0;j<ItemsInList(existingYWvs);j+=1)
					//this is purely wrong here. We need to just test, that the xwave is here for the y wave, nothing else... ZRewire this to make sense... 
//						if (stringMatch(";"+existingXWvs,"*;"+StringFromList(j,existingYWvs)) && (!RequireErrorWvs || stringMatch(";"+existingEWvs,"*;"+StringFromList(j,existingYWvs))))
//							if(cmpstr(MatchMeTo,"*")==0 || cmpstr(StringFromList(j,existingYWvs)[strlen(tempstringY),inf],MatchMeTo[strlen(tempstringX),inf])==0)
								result+=StringFromList(j,existingYWvs)+";"
//							endif
//						endif
					endfor
				endif
			endfor
		elseif(cmpstr(DataType,"Error")==0)
			for(i=0;i<itemsInList(LocallyAllowedUserData);i+=1)
				tempStringY=stringFromList(i,LocallyAllowedUserData)
				tempStringX=stringByKey(tempStringY,XwaveUserDataTypesLookup)
				tempStringE=stringByKey(tempStringY,EwaveUserDataTypesLookup)
				existingYWvs=IR2P_ListOfWavesOfType(tempStringY,tempresult)
				existingXWvs=IR2P_ListOfWavesOfType(tempStringX,tempresult)
				existingEWvs=IR2P_ListOfWavesOfType(tempStringE,tempresult)
				tmpp=replaceString("*",tempStringY,"&")
				if(stringmatch(tmpp, "*&" ))		//assume qrs type data
					tempstringY2=stringFromList(0,tempstringY,"*")
					tempstringX2=stringFromList(0,tempstringX,"*")
					tempstringE2=stringFromList(0,tempstringE,"*")
					For (j=0;j<ItemsInList(existingEWvs);j+=1)
						if (stringMatch(";"+existingXWvs,"*;"+tempstringX2+StringFromList(j,existingEWvs)[strlen(tempstringE2),inf]+";*") && stringMatch(";"+existingYWvs,"*;"+tempstringY2+StringFromList(j,existingEWvs)[strlen(tempstringE2),inf]+";*"))
							if(cmpstr(MatchMeTo,"*")==0 || cmpstr(StringFromList(j,existingEWvs)[strlen(tempstringE2),inf],MatchMeTo[strlen(tempstringX2),inf])==0)
								result+=StringFromList(j,existingEWvs)+";"
							endif
						endif
					endfor
				
				else									//asume IN2 type data

					tempstringY2=stringFromList(1,tempstringY,"*")
					tempstringX2=stringFromList(1,tempstringX,"*")
					tempstringE2=stringFromList(1,tempstringE,"*")
					For (j=0;j<ItemsInList(existingEWvs);j+=1)
//						if (stringMatch(";"+existingXWvs,"*;"+StringFromList(j,existingEWvs)[0,strlen(StringFromList(j,existingEWvs))-strlen(tempstringE)]+tempstringX2+";*") && (stringMatch(";"+existingYWvs,"*;"+StringFromList(j,existingEWvs)[0,strlen(StringFromList(j,existingEWvs))-strlen(tempstringE)]+tempstringY2+";*")))
//							if(cmpstr(MatchMeTo,"*")==0 || cmpstr(StringFromList(j,existingEWvs)[strlen(tempstringE),inf],MatchMeTo[strlen(tempstringX),inf])==0)
								result+=StringFromList(j,existingEWvs)+";"
//							endif
//						endif
					endfor

//					For (j=0;j<ItemsInList(existingEWvs);j+=1)
//						if (stringMatch(";"+existingXWvs,"*;"+tempstringX2+StringFromList(j,existingEWvs)[strlen(tempstringE2),inf]+";*") && stringMatch(";"+existingYWvs,"*;"+tempstringY2+StringFromList(j,existingEWvs)[strlen(tempstringE2),inf]+";*"))
//							if(cmpstr(MatchMeTo,"*")==0 || cmpstr(StringFromList(j,existingEWvs)[strlen(tempstringE2),inf],MatchMeTo[strlen(tempstringX2),inf])==0)
//								result+=StringFromList(j,existingEWvs)+";"
//							endif
//						endif
//					endfor
//					if(stringmatch(";"+tempresult, "*;"+tempStringY+";*") && stringmatch(";"+tempresult, "*;"+tempStringX+";*") && (!RequireErrorWvs || stringmatch(";"+tempresult, "*;"+tempStringE+";*")))
//						if(cmpstr(MatchMeTo,"*")==0 || (cmpstr(stringByKey(tempStringY,XwaveUserDataTypesLookup),MatchMeTo)==0 && stringmatch(";"+tempresult, "*;"+tempStringE+";*")))
//							result+=tempStringE+";"
//						endif
//					endif
				endif
			endfor
		endif
	elseif(UseQRSStructure) 
		tempStringX=IR2P_ListOfWavesOfType("q*",tempresult)+IR2P_ListOfWavesOfType("*q",tempresult)
		tempStringY=IR2P_ListOfWavesOfType("r*",tempresult)+IR2P_ListOfWavesOfType("*i",tempresult)
		tempStringE=IR2P_ListOfWavesOfType("s*",tempresult)+IR2P_ListOfWavesOfType("*s",tempresult)
		if (cmpstr(DataType,"Yaxis")==0)
			For (j=0;j<ItemsInList(tempStringY);j+=1)
				tmpstr2 = StringFromList(j,tempStringY)
				if ((stringMatch(";"+tempStringX,"*q"+tmpstr2[1,inf]+";*") && (!RequireErrorWvs || stringMatch(";"+tempStringE,"*s"+tmpstr2[1,inf]+";*"))) || (stringMatch(";"+tempStringX,"*"+tmpstr2[0,strlen(tmpstr2)-2]+"q;*") && (stringMatch(";"+tempStringE,"*"+tmpstr2[0,strlen(tmpstr2)-2]+"s;*"))))
					if(cmpstr(MatchMeTo,"*")==0 || cmpstr(tmpstr2,"r"+MatchMeTo[1,inf])==0)
						result+=StringFromList(j,tempStringY)+";"
					endif
				endif
			endfor
		elseif(cmpstr(DataType,"Xaxis")==0)
			For (j=0;j<ItemsInList(tempStringX);j+=1)
				tmpstr2 = StringFromList(j,tempStringX)
				if ((stringMatch(";"+tempStringY,"*r"+tmpstr2[1,inf]+";*") && (!RequireErrorWvs || stringMatch(";"+tempStringE,"*s"+tmpstr2[1,inf]+";*"))) || (stringMatch(";"+tempStringY,"*"+tmpstr2[0,strlen(tmpstr2)-2]+"i;*") && (stringMatch(";"+tempStringE,"*"+tmpstr2[0,strlen(tmpstr2)-2]+"s;*"))))
					result+=StringFromList(j,tempStringX)+";"
					if(setControls==0)
						IntDf=StringFromList(j,tempStringY)
						QDf=StringFromList(j,tempStringX)
						EDf=StringFromList(j,tempStringE)
						setControls=1
					endif
				endif
			endfor
		elseif(cmpstr(DataType,"Error")==0)
			For (j=0;j<ItemsInList(tempStringE);j+=1)
				tmpstr2 = StringFromList(j,tempStringE)
				if ((stringMatch(";"+tempStringY,"*r"+tmpstr2[1,inf]+";*") && stringMatch(";"+tempStringX,"*q"+tmpstr2[1,inf]+";*")) || (stringMatch(";"+tempStringY,"*"+tmpstr2[0,strlen(tmpstr2)-2]+"i;*")&& stringMatch(";"+tempStringX,"*"+tmpstr2[0,strlen(tmpstr2)-2]+"q;*")))
					if(cmpstr(MatchMeTo,"*")==0 || cmpstr(tmpstr2,"s"+MatchMeTo[1,inf])==0)
						result+=StringFromList(j,tempStringE)+";"
					endif
				endif
			endfor
		endif
	elseif(UseResults)
		if(cmpstr(DataType,"Xaxis")==0)
			for(i=0;i<itemsInList(LocallyAllowedResultsData);i+=1)
				tempStringY=stringFromList(i,LocallyAllowedResultsData)
				tempStringX=stringByKey(tempStringY,ResultsDataTypesLookup)
				For (j=0;j<ItemsInList(tempStringY);j+=1)
					For(jj=0;jj<itemsInList(tempresult);jj+=1)
						if (stringMatch(StringFromList(jj,tempresult), StringFromList(j,tempStringY)+"_*"))
							Endstr="_"+StringByKey(StringFromList(j,tempStringY), StringFromList(jj,tempresult) , "_" )
							if (stringMatch(";"+tempresult,"*;"+tempStringX+EndStr+";*"))
								result+=StringFromList(j,tempStringX)+EndStr+";"
								if(setControls==0)
									IntDf=tempStringY
									QDf=tempStringX
									EDf="---"
									setControls=1
								endif
							elseif(cmpstr("x-scaling",tempStringX)==0 )
								result+=StringFromList(j,tempStringX)+";"
								if(setControls==0)
									IntDf=tempStringY
									QDf=tempStringX
									EDf="---"
									setControls=1
								endif
							endif
						endif
					endfor
				endfor
			endfor
		elseif(cmpstr(DataType,"Yaxis")==0)
	//		string tt1, tt2, tt3, tt4, tt5, tt6
			for(i=0;i<itemsInList(LocallyAllowedResultsData);i+=1)		//iterates over all known Indra data types
				tempStringY=stringFromList(i,LocallyAllowedResultsData)		//one data type (Y axis data) at a time
				tempStringX=stringByKey(tempStringY,ResultsDataTypesLookup)	//this is appropriate data x data type 
					For(jj=0;jj<itemsInList(tempresult);jj+=1)					//tempresult contains all waves in the given folder
						if (stringMatch(StringFromList(jj,tempresult), tempStringY+"_*") &&(cmpstr(MatchMeTo,"*")==0 || cmpstr(StringFromList(jj,tempresult),IR2C_ReverseLookup(ResultsDataTypesLookup,stringFromList(0,MatchMeTo,"_"))+"_"+stringFromList(1,MatchMeTo,"_"))==0 ))		//Ok, this is appriapriate Y data set
							Endstr="_"+StringByKey(StringFromList(j,tempStringY), StringFromList(jj,tempresult) , "_" )	//this is current index _XX
							if (stringMatch(";"+tempresult,"*;"+tempStringX+EndStr+";*") || cmpstr("x-scaling",tempStringX)==0  )		//Ok, the appropriate X data set exists or x-scaling is allowed...
								result+=tempStringY+Endstr+";"
							endif
						endif
					endfor
			endfor
		elseif(cmpstr(DataType,"Error")==0)
			result="---;"
			for(i=0;i<itemsInList(LocallyAllowedResultsData);i+=1)		//iterates over all known Indra data types
				tempStringY=stringFromList(i,LocallyAllowedResultsData)		//one data type (Y axis data) at a time
				tempStringX=stringByKey(tempStringY,ResultsEDataTypesLookup)	//this is appropriate data E data type 
				if(strlen(tempStringX)>2)
					For(jj=0;jj<itemsInList(tempresult);jj+=1)					//tempresult contains all waves in the given folder
						if (stringMatch(StringFromList(jj,tempresult), tempStringY+"_*") &&(cmpstr(MatchMeTo,"*")==0 || cmpstr(StringFromList(jj,tempresult),IR2C_ReverseLookup(ResultsEDataTypesLookup,stringFromList(0,MatchMeTo,"_"))+"_"+stringFromList(1,MatchMeTo,"_"))==0 ))		//Ok, this is appriapriate Y data set		
							Endstr="_"+StringByKey(StringFromList(j,tempStringY), StringFromList(jj,tempresult) , "_" )	//this is current index _XX
							if (stringMatch(";"+tempresult,"*;"+tempStringX+EndStr+";*"))
								result+=tempStringX+Endstr+";"
							endif
						endif
					endfor
				endif
			endfor
//			result += "---;"
		endif
	else
		result=tempresult+";x-scaling;"
	endif
	if(strlen(result)<1)
		result="---"
	endif
//	print result
	return result
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**************************************************************************************************
Function/S IR2C_ReverseLookup(StrToSearch,Keywrd)
	string StrToSearch,Keywrd
	
	string result, tempstr
	variable i
	For(i=0;i<ItemsInList(StrToSearch , ";");i+=1)
		tempStr=StringFromList(i, StrToSearch ,";")
		if(stringmatch(tempStr, "*:"+Keywrd ))
			return stringFromList(0,tempStr,":")
		endif
	endfor
	return ""
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**************************************************************************************************

//popup procedure
//Function IR2C_PanelPopupControl(ctrlName,popNum,popStr) : PopupMenuControl
Function IR2C_PanelPopupControl(Pa) : PopupMenuControl
	STRUCT WMPopupAction &Pa

	if(Pa.eventCode!=2)
		return 0
	endif
	String ctrlName=Pa.ctrlName
	Variable popNum=Pa.popNum
	String popStr=Pa.popStr

	//part to copy everywhere...	
	string oldDf=GetDataFolder(1)
	string TopPanel=Pa.win
	//WinName(0,65)
	//GetWindow $(TopPanel), activeSW
	//TopPanel = S_Value
	
	SVAR ControlProcsLocations=root:Packages:IrenaControlProcs:ControlProcsLocations
	SVAR ControlAllowedIrenaTypes=root:Packages:IrenaControlProcs:ControlAllowedIrenaTypes
	SVAR ControlAllowedResultsTypes=root:Packages:IrenaControlProcs:ControlAllowedResultsTypes
	SVAR ControlRequireErrorWvs=root:Packages:IrenaControlProcs:ControlRequireErrorWvs
	string CntrlLocation="root:Packages:"+StringByKey(TopPanel, ControlProcsLocations,":",";")
	string LocallyAllowedIndra2Data=StringByKey(TopPanel, ControlAllowedIrenaTypes,"=",">")
	string LocallyAllowedResultsData=StringByKey(TopPanel, ControlAllowedResultsTypes,"=",">")
	setDataFolder $(CntrlLocation)

	NVAR UseIndra2Structure=$(CntrlLocation+":UseIndra2Data")
	NVAR UseQRSStructure=$(CntrlLocation+":UseQRSData")
	NVAR UseResults=$(CntrlLocation+":UseResults")
	NVAR UseUserDefinedData=$(CntrlLocation+":UseUserDefinedData")
	SVAR Dtf=$(CntrlLocation+":DataFolderName")
	SVAR IntDf=$(CntrlLocation+":IntensityWaveName")
	SVAR QDf=$(CntrlLocation+":QWaveName")
	SVAR EDf=$(CntrlLocation+":ErrorWaveName")
	String infostr = ""
	///endof common block  
//print Dtf
	if (cmpstr(ctrlName,"QvecDataName")==0)
		QDf=popStr
		//and need to fix IntDf & EDf
		//avoid reseting when using general selection...
		if((UseIndra2Structure || UseQRSStructure || UseResults || UseUserDefinedData))
			IntDf=stringFromList(0,IR2P_ListOfWaves("Yaxis",popStr,TopPanel)+";")		
			EDf=stringFromList(0,IR2P_ListOfWaves("Error",popStr,TopPanel)+";")
			Execute ("PopupMenu IntensityDataName mode=1, value=\""+IntDf +";\"+IR2P_ListOfWaves(\"Yaxis\",\"*\",\""+TopPanel+"\"), win="+TopPanel)
			Execute ("PopupMenu ErrorDataName mode=1, value=\""+EDf +";\"+IR2P_ListOfWaves(\"Error\",\"*\",\""+TopPanel+"\"), win="+TopPanel)
		endif
		//now we need to deal with allowing x-scaling...
		if(cmpstr(popStr,"x-scaling")==0)
			setDataFolder  Dtf
			Wave/Z tempYwv=$(IntDf)
			if(WaveExists(tempYwv))
				Duplicate/O tempYWv, $("X_"+IntDf[0,28])
				Wave tempXWv= $("X_"+IntDf[0,28])
				tempXWv = leftx(tempYWv)+p*deltax(tempYWv)
				QDf="X_"+IntDf[0,28]
			endif
			setDataFolder $(CntrlLocation)	
		endif
	 	//allow user function through hook function...
		infostr = FunctionInfo("IR2_ContrProc_Q_Hook_Proc")
		if (strlen(infostr) >0)
			Execute("IR2_ContrProc_Q_Hook_Proc()")
		endif
		//end of allow user function through hook function
	endif
	if (cmpstr(ctrlName,"IntensityDataName")==0)
		IntDf=popStr
		if(cmpstr(QDf,"x-scaling")==0 || cmpstr(QDf,"X_"+IntDf[0,28])==0 )
			setDataFolder Dtf
			Wave/Z tempYwv=$(IntDf)
			if(WaveExists(tempYwv))
				Duplicate/O tempYWv, $("X_"+IntDf[0,28])
				Wave tempXWv= $("X_"+IntDf)
				tempXWv = leftx(tempYWv)+p*deltax(tempYWv)
				QDf="X_"+IntDf[0,28]
			endif
			setDataFolder $(CntrlLocation)	
		endif
	 	//allow user function through hook function...
		infostr = FunctionInfo("IR2_ContrProc_R_Hook_Proc")
		if (strlen(infostr) >0)
			Execute("IR2_ContrProc_R_Hook_Proc()")
		endif
		//end of allow user function through hook function
	endif
	if (cmpstr(ctrlName,"ErrorDataName")==0)
		EDf=popStr
	 	//allow user function through hook function...
		infostr = FunctionInfo("IR2_ContrProc_E_Hook_Proc")
		if (strlen(infostr) >0)
			Execute("IR2_ContrProc_E_Hook_Proc()")
		endif
		//end of allow user function through hook function
	endif

	if (cmpstr(ctrlName,"SelectDataFolder")==0)
		String tempDf=GetDataFolder(1)
		setDataFolder root:Packages:IrenaControlProcs
		setDataFolder $(TopPanel)
		string TopPanelFixed=PossiblyQuoteName(TopPanel)
		string/g TempYList, tempXList, tempEList
		SVAR TempYList 
		SVAR TempXList 
		SVAR TempEList 
		setDataFolder tempDF
		Dtf=popStr
		TempYlist=IR2P_ListOfWaves("Yaxis","*",TopPanel)
		TempXList=IR2P_ListOfWaves("Xaxis","*",TopPanel)
		TempEList=IR2P_ListOfWaves("Error","*",TopPanel)
			Execute ("PopupMenu IntensityDataName mode=1,value= #\"\\\"---;\\\"+root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempYList\", win="+TopPanel)
			Execute ("PopupMenu QvecDataName mode=1,value= #\"\\\"---;\\\"+root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempXList\", win="+TopPanel)
			Execute ("PopupMenu ErrorDataName mode=1,value= #\"\\\"---;\\\"+root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempEList\", win="+TopPanel)
			//root:Packages:IrenaControlProcs:'IR1D_DataManipulationPanel#Top':tempXList
	//		PopupMenu QvecDataName mode=1,value= #"\"---;\"+root:Packages:IrenaControlProcs:"+TopPanel+":tempXList", win=$(TopPanel)
	//		PopupMenu ErrorDataName mode=1,value= #"\"---;\"+root:Packages:IrenaControlProcs:"+TopPanel+":tempEList", win=$(TopPanel)
		if (UseIndra2Structure)
			QDf=stringFromList(0,TempXlist)
			IntDf=stringFromList(0,TempYlist)
			EDf=stringFromList(0,TempElist)
			Execute ("PopupMenu IntensityDataName mode=1,value= #\"root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempYList\", win="+TopPanel)
			Execute ("PopupMenu QvecDataName mode=1,value= #\"root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempXList\", win="+TopPanel)
			Execute ("PopupMenu ErrorDataName mode=1,value= #\"root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempEList\", win="+TopPanel)
//			PopupMenu IntensityDataName value=#"root:Packages:IrenaControlProcs:\"+TopPanel+\":tempYList", win=$(TopPanel)
//			PopupMenu QvecDataName value=#"root:Packages:IrenaControlProcs:\"+TopPanel+\":tempXList", win=$(TopPanel)
//			PopupMenu ErrorDataName value=#"root:Packages:IrenaControlProcs:\"+TopPanel+\":tempEList+\";---;\"", win=$(TopPanel)
		elseif(UseQRSStructure)
			QDf=stringFromList(0,TempXlist)
			IntDf=stringFromList(0,TempYlist)
			EDf=stringFromList(0,TempElist)
			Execute ("PopupMenu IntensityDataName mode=1,value= #\"root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempYList\", win="+TopPanel)
			Execute ("PopupMenu QvecDataName mode=1,value= #\"root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempXList\", win="+TopPanel)
			Execute ("PopupMenu ErrorDataName mode=1,value= #\"root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempEList\", win="+TopPanel)
//			PopupMenu IntensityDataName value=#"root:Packages:IrenaControlProcs:tempYList", win=$(TopPanel)
//			PopupMenu QvecDataName value=#"root:Packages:IrenaControlProcs:tempXList", win=$(TopPanel)
//			PopupMenu ErrorDataName value=#"root:Packages:IrenaControlProcs:tempEList+\";---;\"", win=$(TopPanel)
		elseif(UseResults)
			QDf=stringFromList(0,TempXlist)
			IntDf=stringFromList(0,TempYlist)
			EDf=stringFromList(0,TempElist)
			Execute ("PopupMenu IntensityDataName mode=1,value= #\"root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempYList\", win="+TopPanel)
			Execute ("PopupMenu QvecDataName mode=1,value= #\"root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempXList\", win="+TopPanel)
			Execute ("PopupMenu ErrorDataName mode=1,value= #\"root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempEList\", win="+TopPanel)
//			PopupMenu IntensityDataName value=#"root:Packages:IrenaControlProcs:tempYList", win=$(TopPanel)/
//			PopupMenu QvecDataName value=#"root:Packages:IrenaControlProcs:tempXList", win=$(TopPanel)
//			PopupMenu ErrorDataName value=#"root:Packages:IrenaControlProcs:tempEList+\";---;\"", win=$(TopPanel)
		elseif(UseUserDefinedData)
			QDf=stringFromList(0,TempXlist)
			IntDf=stringFromList(0,TempYlist)
			EDf=stringFromList(0,TempElist)
			Execute ("PopupMenu IntensityDataName mode=1,value= #\"root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempYList\", win="+TopPanel)
			Execute ("PopupMenu QvecDataName mode=1,value= #\"root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempXList\", win="+TopPanel)
			Execute ("PopupMenu ErrorDataName mode=1,value= #\"root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempEList\", win="+TopPanel)
//			PopupMenu IntensityDataName value=#"root:Packages:IrenaControlProcs:tempYList", win=$(TopPanel)
//			PopupMenu QvecDataName value=#"root:Packages:IrenaControlProcs:tempXList", win=$(TopPanel)
//			PopupMenu ErrorDataName value=#"root:Packages:IrenaControlProcs:tempEList+\";---;\"", win=$(TopPanel)
		else
			IntDf="---"
			QDf="---"
			EDf="---"
			Execute ("PopupMenu IntensityDataName mode=1,value= #\"\\\"---;\\\"+root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempYList\", win="+TopPanel)
			Execute ("PopupMenu QvecDataName mode=1,value= #\"\\\"---;\\\"+root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempXList\", win="+TopPanel)
			Execute ("PopupMenu ErrorDataName mode=1,value= #\"\\\"---;\\\"+root:Packages:IrenaControlProcs:"+TopPanelFixed+":tempEList\", win="+TopPanel)
//			PopupMenu IntensityDataName value=#"\"---;\"+root:Packages:IrenaControlProcs:tempYList", win=$(TopPanel)
//			PopupMenu QvecDataName value=#"\"---;\"+root:Packages:IrenaControlProcs:tempXList", win=$(TopPanel)
//			PopupMenu ErrorDataName value=#"\"---;\"+root:Packages:IrenaControlProcs:tempEList+\";---;\"", win=$(TopPanel)
		endif

	 	//allow user function through hook function...
//print Dtf
		infostr = FunctionInfo("IR2_ContrProc_F_Hook_Proc")
		if (strlen(infostr) >0)
			Execute("IR2_ContrProc_F_Hook_Proc()")
		endif
		//end of allow user function through hook function
	endif
	setDataFolder oldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//
//Function/T IR2C_ListWavesForPopups(WhichWave,TopPanel,CntrlLocation,UseIndra2Structure,UseQRSStructure,UseResults)
//	string WhichWave,CntrlLocation, TopPanel
//	variable UseIndra2Structure,UseQRSStructure,UseResults		
//
//	string result=""
//	string AllWaves=""
//	variable i, j
//	SVAR Dtf=$(CntrlLocation+":DataFolderName")
//	SVAR ControlProcsLocations=root:Packages:IrenaControlProcs:ControlProcsLocations
//	SVAR ControlAllowedIrenaTypes=root:Packages:IrenaControlProcs:ControlAllowedIrenaTypes
//	SVAR ControlAllowedResultsTypes=root:Packages:IrenaControlProcs:ControlAllowedResultsTypes
//	SVAR ControlRequireErrorWvs=root:Packages:IrenaControlProcs:ControlRequireErrorWvs
//
//	SVAR XwaveDataTypesLookup=root:Packages:IrenaControlProcs:XwaveDataTypesLookup
//	SVAR EwaveDataTypesLookup=root:Packages:IrenaControlProcs:EwaveDataTypesLookup
//	SVAR ResultsDataTypesLookup=root:Packages:IrenaControlProcs:ResultsDataTypesLookup
//
//	string LocallyAllowedIndra2Data=StringByKey(TopPanel, ControlAllowedIrenaTypes,"=",">")
//	string LocallyAllowedResultsData=StringByKey(TopPanel, ControlAllowedResultsTypes,"=",">")
//	
//	AllWaves = IN2G_CreateListOfItemsInFolder(Dtf,2)
//	if (cmpstr(WhichWave,"Y")==0)
//		if(UseIndra2Structure)
//			For(i=0;i<ItemsInList(LocallyAllowedIndra2Data);i+=1)
//				For(j=0;j<ItemsInList(AllWaves);j+=1)
//					if(cmpstr(stringfromList(i,LocallyAllowedIndra2Data),stringfromList(j,AllWaves))==0)
//						result+=stringfromList(i,LocallyAllowedIndra2Data)+";"
//					endif
//				endfor	
//			endfor
//		elseif(UseQRSStructure)
//			For(i=0;i<ItemsInList(LocallyAllowedIndra2Data);i+=1)
//				For(j=0;j<ItemsInList(AllWaves);j+=1)
//					if(cmpstr(stringfromList(i,LocallyAllowedIndra2Data),stringfromList(j,AllWaves))==0)
//						result+=stringfromList(i,LocallyAllowedIndra2Data)+";"
//					endif
//				endfor	
//			endfor
//		endif
//	endif
//	if (cmpstr(WhichWave,"X")==0)
//		if(UseIndra2Structure)
//			For(i=0;i<ItemsInList(LocallyAllowedIndra2Data);i+=1)
//				For(j=0;j<ItemsInList(AllWaves);j+=1)
//					if(cmpstr(stringByKey(stringfromList(i,LocallyAllowedIndra2Data),XwaveDataTypesLookup),stringfromList(j,AllWaves))==0)
//						result+=stringByKey(stringfromList(i,LocallyAllowedIndra2Data),XwaveDataTypesLookup)+";"
//					endif
//				endfor	
//			endfor
//		elseif(UseQRSStructure)
//			For(i=0;i<ItemsInList(LocallyAllowedIndra2Data);i+=1)
//				For(j=0;j<ItemsInList(AllWaves);j+=1)
//					if(cmpstr(stringfromList(i,LocallyAllowedIndra2Data),stringfromList(j,AllWaves))==0)
//						result+=stringfromList(i,LocallyAllowedIndra2Data)+";"
//					endif
//				endfor	
//			endfor
//		endif
//	endif
//	if (cmpstr(WhichWave,"E")==0)
//		if(UseIndra2Structure)
//			For(i=0;i<ItemsInList(LocallyAllowedIndra2Data);i+=1)
//				For(j=0;j<ItemsInList(AllWaves);j+=1)
//					if(cmpstr(stringByKey(stringfromList(i,LocallyAllowedIndra2Data),EwaveDataTypesLookup),stringfromList(j,AllWaves))==0)
//						result+=stringByKey(stringfromList(i,LocallyAllowedIndra2Data),EwaveDataTypesLookup)+";"
//					endif
//				endfor	
//			endfor
//		elseif(UseQRSStructure)
//			For(i=0;i<ItemsInList(LocallyAllowedIndra2Data);i+=1)
//				For(j=0;j<ItemsInList(AllWaves);j+=1)
//					if(cmpstr(stringfromList(i,LocallyAllowedIndra2Data),stringfromList(j,AllWaves))==0)
//						result+=stringfromList(i,LocallyAllowedIndra2Data)+";"
//					endif
//				endfor	
//			endfor
//		endif
//	endif
//	return result
//end
//
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
