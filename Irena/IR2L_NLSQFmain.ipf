#pragma rtGlobals=1		// Use modern global access method.




//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************



Function IR2L_Main()


	//initialize, as usually
	IR2L_Initialize()
	IR1_CreateLoggbook()
	IR2S_InitStructureFactors()
	IR2L_SetInitialValues(1)
	//we need the following also inited
	IR2C_InitConfigMain()
	IR1T_InitFormFactors()
	//check for panel if exists - pull up, if not create
	DoWindow LSQF2_MainPanel
	if(V_Flag)
		DoWindow/F LSQF2_MainPanel
	else
		IR2L_MainPanel()
	endif

	IR2L_RecalculateIfSelected()
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR2L_MainPanel()
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(3,42,410,730) as "Modeling II main panel"
	DoWindow/C LSQF2_MainPanel
	
	string AllowedIrenaTypes="DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;"
	IR2C_AddDataControls("IR2L_NLSQF","LSQF2_MainPanel",AllowedIrenaTypes,"","","","","", 0,1)
	SetDrawLayer UserBack
	SetDrawEnv fname= "Times New Roman", save
	SetDrawEnv fname= "Times New Roman",fsize= 28,fstyle= 3,textrgb= (0,0,52224)
	DrawText 90,26,"Modeling II "
	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
	DrawLine 16,176,339,176
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 18,49,"Data input"
	SetDrawEnv fsize= 16,fstyle= 1

	Button RemoveAllDataSets, pos={5,155},size={90,18},font="Times New Roman",fSize=9,proc=IR2L_InputPanelButtonProc,title="Remove all", help={"Remove all data from tool"}
	Button UnuseAllDataSets, pos={100,155},size={90,18},font="Times New Roman",fSize=9,proc=IR2L_InputPanelButtonProc,title="unUse all", help={"Set all data set to not Use"}
	Button ConfigureGraph, pos={195,155},size={90,18},font="Times New Roman",fSize=9,proc=IR2L_InputPanelButtonProc,title="Config Graph", help={"Set parameters for graph"}
	Button ReGraph, pos={290,155},size={90,18},font="Times New Roman",fSize=9,proc=IR2L_InputPanelButtonProc,title="Graph (ReGraph)", help={"Create or Recreate graph"}

	CheckBox DisplayInputDataControls,pos={10,184},size={25,16},proc=IR2L_DataTabCheckboxProc,title="Data controls", mode=1
	CheckBox DisplayInputDataControls,variable= root:Packages:IR2L_NLSQF:DisplayInputDataControls, help={"Select to get data controls"}
	CheckBox DisplayModelControls,pos={120,184},size={25,16},proc=IR2L_DataTabCheckboxProc,title="Model controls", mode=1
	CheckBox DisplayModelControls,variable= root:Packages:IR2L_NLSQF:DisplayModelControls, help={"Select to get model controls"}



	CheckBox MultipleInputData,pos={10,200},size={25,90},proc=IR2L_DataTabCheckboxProc,title="Multiple Input Data sets?"
	CheckBox MultipleInputData,variable= root:Packages:IR2L_NLSQF:MultipleInputData, help={"Do you want to use multiple input data sets in this tool?"}

	CheckBox UseNumberDistributions,pos={170,200},size={25,90},proc=IR2L_DataTabCheckboxProc,title="Number Dist?"
	CheckBox UseNumberDistributions,variable= root:Packages:IR2L_NLSQF:UseNumberDistributions, help={"Use number distributions? Default is volume distributions."}
	CheckBox RecalculateAutomatically,pos={310,200},size={25,90},proc=IR2L_DataTabCheckboxProc,title="Auto Recalc?"
	CheckBox RecalculateAutomatically,variable= root:Packages:IR2L_NLSQF:RecalculateAutomatically, help={"Check to have everything recalculate when change is made. SLOW!"}


	CheckBox SameContrastForDataSets,pos={220,184},size={25,16},proc=IR2L_DataTabCheckboxProc,title="Different contrasts for data sets?"
	CheckBox SameContrastForDataSets,variable= root:Packages:IR2L_NLSQF:SameContrastForDataSets, help={"Check if contrast varies between data sets for one population?"}

	NVAR DisplayInputDataControls=root:Packages:IR2L_NLSQF:DisplayInputDataControls
	NVAR DisplayModelControls=root:Packages:IR2L_NLSQF:DisplayModelControls
	NVAR MultipleInputData=root:Packages:IR2L_NLSQF:MultipleInputData

	//Data Tabs definition
	TabControl DataTabs,pos={2,220},size={400,320},proc=IR2L_Data_TabPanelControl
	TabControl DataTabs,fSize=10,tabLabel(0)="1.",tabLabel(1)="2."
	TabControl DataTabs,tabLabel(2)="3.",tabLabel(3)="4."
	TabControl DataTabs,tabLabel(4)="5.",tabLabel(5)="6."
	TabControl DataTabs,tabLabel(6)="7.",tabLabel(7)="8."
	TabControl DataTabs,tabLabel(8)="9.",tabLabel(9)="10.", value= 0, disable =!DisplayInputDataControls

//	variable i
		Button AddDataSet, pos={5,245},size={80,16},font="Times New Roman",fSize=10,proc=IR2L_InputPanelButtonProc,title="Add data", help={"Load data into the tool"}

		CheckBox UseTheData_set,pos={95,245},size={25,16},proc=IR2L_DataTabCheckboxProc,title="Use?"
		CheckBox UseTheData_set,variable= root:Packages:IR2L_NLSQF:UseTheData_set1, help={"Use the data in the tool?"}
		CheckBox SlitSmeared_set,pos={155,245},size={25,16},proc=IR2L_DataTabCheckboxProc,title="Slit Smeared?"
		CheckBox SlitSmeared_set,variable= root:Packages:IR2L_NLSQF:SlitSmeared_set1, help={"Slit smeared data?"}
		SetVariable SlitLength_set,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:SlitLength_set1, proc=IR2L_DataSetVarProc
		SetVariable SlitLength_set,pos={260,245},size={140,15},title="Slit length [1/A]:", help={"This is slit length of the set currently loaded."}, fSize=10
 
 		SetVariable FolderName_set,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:FolderName_set1, noedit=1,noproc,frame=0,labelBack=(0,52224,0)
		SetVariable FolderName_set,pos={5,265},size={395,15},title="Data:", help={"This is data set currently loaded in this data set."}, fSize=10
 		SetVariable UserDataSetName_set,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:UserDataSetName_set1, proc=IR2L_DataTabSetVarProc
		SetVariable UserDataSetName_set,pos={5,285},size={395,15},title="User Name:", help={"This is data set currently loaded in this data set."}, fSize=10


//	ListOfDataVariables+="DataScalingFactor;ErrorScalingFactor;UseUserErrors;UseSQRTErrors;UsePercentErrors;PercentErrors
		SetVariable DataScalingFactor_set,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:DataScalingFactor_set1, proc=IR2L_DataSetVarProc
		SetVariable DataScalingFactor_set,pos={10,305},size={150,15},title="Scale data by:", help={"Value to scale data set"}, fSize=10
		CheckBox UseUserErrors_set,pos={10,325},size={25,16},proc=IR2L_DataTabCheckboxProc,title="User errors?", mode=1
		CheckBox UseUserErrors_set,variable= root:Packages:IR2L_NLSQF:UseUserErrors_set1, help={"Use user errors (if input)?"}
		CheckBox UseSQRTErrors_set,pos={100,325},size={25,16},proc=IR2L_DataTabCheckboxProc,title="SQRT errors?", mode=1
		CheckBox UseSQRTErrors_set,variable= root:Packages:IR2L_NLSQF:UseSQRTErrors_set1, help={"Use square root of intensity errors?"}
		CheckBox UsePercentErrors_set,pos={200,325},size={25,16},proc=IR2L_DataTabCheckboxProc,title="User % errors?", mode=1
		CheckBox UsePercentErrors_set,variable= root:Packages:IR2L_NLSQF:UsePercentErrors_set1, help={"Use errors equal to % of intensity?"}
		SetVariable ErrorScalingFactor_set,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:ErrorScalingFactor_set1, proc=IR2L_DataTabSetVarProc
		SetVariable ErrorScalingFactor_set,pos={10,345},size={150,15},title="Scale errors by:", help={"Value to scale errors by"}, fSize=10


		SetVariable Qmin_set,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:Qmin_set1, proc=IR2L_DataTabSetVarProc
		SetVariable Qmin_set,pos={10,370},size={100,15},title="Q min:", help={"This is Q min selected for this data set for fitting."}, fSize=10
		SetVariable Qmax_set,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:Qmax_set1, proc=IR2L_DataTabSetVarProc
		SetVariable Qmax_set,pos={140,370},size={100,15},title="Q max:", help={"This is Q max selected for this data set for fitting."}, fSize=10
		Button ReadCursors, pos={285,369},size={80,16},font="Times New Roman",fSize=10,proc=IR2L_InputPanelButtonProc,title="Q from cursors", help={"Read cursors positon into the Q range for fitting"}
	
		SetVariable Background,limits={-inf,Inf,1},variable= root:Packages:IR2L_NLSQF:Background_set1, proc=IR2L_DataTabSetVarProc
		SetVariable Background,pos={5,420},size={120,15},title="Bckg:", help={"Flat background for this data set"}, fSize=10
		CheckBox BackgroundFit_set,pos={150,420},size={25,14},proc=IR2L_DataTabCheckboxProc,title="Fit?"
		CheckBox BackgroundFit_set,variable= root:Packages:IR2L_NLSQF:BackgroundFit_set1, help={"Fit the background?"}
		SetVariable BackgroundMin,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:BackgroundMin_set1, noproc
	 	SetVariable BackgroundMin,pos={220,420},size={80,15},title="Min:", help={"Fitting range for background, minimum"}, fSize=10
		SetVariable BackgroundMax,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:BackgroundMax_set1, noproc
		SetVariable BackgroundMax,pos={310,420},size={80,15},title="Max:", help={"Fitting range for background, maxcimum set"}, fSize=10

//		SetVariable BackgStep_set,limits={0,Inf,1},variable= root:Packages:IR2L_NLSQF:BackgStep_set1, proc=IR2L_DataTabSetVarProc
//		SetVariable BackgStep_set,pos={15,440},size={120,15},title="Step:", help={"Flat background for this data set"}, fSize=10
		IR2L_Data_TabPanelControl("",0)
	//Confing ASAXS or SAXS part here

	//Dist Tabs definition
	TabControl DistTabs,pos={2,220},size={400,380},proc=IR2L_Model_TabPanelControl
	TabControl DistTabs,fSize=10,tabLabel(0)="1. Pop ",tabLabel(1)="2. Pop "
	TabControl DistTabs,tabLabel(2)="3. Pop ",tabLabel(3)="4. Pop "
	TabControl DistTabs,tabLabel(4)="5. Pop ",tabLabel(5)="6. Pop ", value= 0, disable=!DisplayModelControls

		CheckBox UseThePop,pos={10,242},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Use?",  fstyle=1
		CheckBox UseThePop,variable= root:Packages:IR2L_NLSQF:UseThePop_pop1, help={"Use the population in calculations?"}

		CheckBox RdistAuto,pos={65,250},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="R dist auto?", mode=1
		CheckBox RdistAuto,variable= root:Packages:IR2L_NLSQF:RdistAuto_pop1, help={"Use automatic method to determin Rmin and Rmax?"}
		CheckBox RdistrSemiAuto,pos={160,250},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="R dist semi-auto?", mode=1
		CheckBox RdistrSemiAuto,variable= root:Packages:IR2L_NLSQF:RdistrSemiAuto_pop1, help={"Use automatic method for Rmin R max except in fitting?"}
		CheckBox RdistMan,pos={285,250},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="R dist manual?", mode=1
		CheckBox RdistMan,variable= root:Packages:IR2L_NLSQF:RdistMan_pop1, help={"Manually set Rmin R max?"}

		SetVariable RdistNumPnts,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:RdistNumPnts_pop1, proc=IR2L_PopSetVarProc
		SetVariable RdistNumPnts,pos={5,273},size={110,15},title="Num pnts:", help={"Number of points in the population"}, fSize=10
		SetVariable RdistManMin,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:RdistManMin_pop1, noproc
		SetVariable RdistManMin,pos={140,273},size={100,15},title="R min:", help={"This is R min selected for this population"}, fSize=10
		SetVariable RdistManMax,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:RdistManMax_pop1, noproc
		SetVariable RdistManMax,pos={260,273},size={100,15},title="R max:", help={"This is R max selected for this population"}, fSize=10

		SetVariable RdistNeglectTails,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:RdistNeglectTails_pop1, proc=IR2L_PopSetVarProc
		SetVariable RdistNeglectTails,pos={140,273},size={180,15},title="R dist neglect tails:", help={"What fraction of population to neglect, see manual, 0.01 is good"}, fSize=10

		CheckBox RdistLog,pos={10,295},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Log R dist?"
		CheckBox RdistLog,variable= root:Packages:IR2L_NLSQF:RdistLog_pop1, help={"Use Log binning for R distribution?"}
//	SVAR ListOfFormFactors=root:Packages:FormFactorCalc:ListOfFormFactors
		PopupMenu FormFactorPop title="Form Factor : ",proc=IR2L_PanelPopupControl, pos={10,320}
		PopupMenu FormFactorPop mode=1, value=#"(root:Packages:FormFactorCalc:ListOfFormFactors)"
		PopupMenu FormFactorPop help={"Select form factor to be used for this population of scatterers"}

		PopupMenu PopSizeDistShape title="Distribution type : ",proc=IR2L_PanelPopupControl, pos={190,320}
		PopupMenu PopSizeDistShape value="LogNormal;Gauss;LSW"
		PopupMenu PopSizeDistShape help={"Select Distribution type for this population"}


		SetVariable Volume,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:Volume_pop1,proc=IR2L_PopSetVarProc
		SetVariable Volume,pos={8,355},size={140,15},title="Volume = ", help={"Volume of this population (fractional, should be between 0 and 1 if contrast and calibrated data)"}, fSize=10
		CheckBox FitVolume,pos={155,355},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Fit?"
		CheckBox FitVolume,variable= root:Packages:IR2L_NLSQF:VolumeFit_pop1, help={"Fit the volume?"}
		SetVariable VolumeMin,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:VolumeMin_pop1,noproc
		SetVariable VolumeMin,pos={200,355},size={80,15},title="Min ", help={"Low limit for volume"}, fSize=10
		SetVariable VolumeMax,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:VolumeMax_pop1,noproc
		SetVariable VolumeMax,pos={290,355},size={80,15},title="Max ", help={"High limit for volume"}, fSize=10

//	ListOfPopulationVariables+="LNMinSize;LNMinSizeFit;LNMinSizeMin;LNMinSizeMax;LNMeanSize;LNMeanSizeFit;LNMeanSizeMin;LNMeanSizeMax;LNSdeviation;LNSdeviationFit;LNSdeviationMin;LNSdeviationMax;"	
		//Log-Normal parameters....
		SetVariable LNMinSize,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LNMinSize_pop1,proc=IR2L_PopSetVarProc
		SetVariable LNMinSize,pos={8,375},size={140,15},title="Min size [A]= ", help={"Log-normal distribution min size [A]"}, fSize=10
		CheckBox LNMinSizeFit,pos={155,375},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Fit?"
		CheckBox LNMinSizeFit,variable= root:Packages:IR2L_NLSQF:LNMinSizeFit_pop1, help={"Fit the Min size for Log-Normal distribution?"}
		SetVariable LNMinSizeMin,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LNMinSizeMin_pop1,noproc
		SetVariable LNMinSizeMin,pos={200,375},size={80,15},title="Min ", help={"Low limit for min size for Log-normal distribution"}, fSize=10
		SetVariable LNMinSizeMax,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LNMinSizeMax_pop1,noproc
		SetVariable LNMinSizeMax,pos={290,375},size={80,15},title="Max ", help={"High limit for min size for Log-normal distribution"}, fSize=10

		SetVariable LNMeanSize,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LNMeanSize_pop1,proc=IR2L_PopSetVarProc
		SetVariable LNMeanSize,pos={8,395},size={140,15},title="Mean [A]= ", help={"Log-normal distribution mean size [A]"}, fSize=10
		CheckBox LNMeanSizeFit,pos={155,395},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Fit?"
		CheckBox LNMeanSizeFit,variable= root:Packages:IR2L_NLSQF:LNMeanSizeFit_pop1, help={"Fit the mean size for Log-Normal distribution?"}
		SetVariable LNMeanSizeMin,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LNMeanSizeMin_pop1,noproc
		SetVariable LNMeanSizeMin,pos={200,395},size={80,15},title="Min ", help={"Low limit for mean size for Log-normal distribution"}, fSize=10
		SetVariable LNMeanSizeMax,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LNMeanSizeMax_pop1,noproc
		SetVariable LNMeanSizeMax,pos={290,395},size={80,15},title="Max ", help={"High limit for mean size for Log-normal distribution"}, fSize=10

		SetVariable LNSdeviation,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LNSdeviation_pop1,proc=IR2L_PopSetVarProc
		SetVariable LNSdeviation,pos={8,415},size={140,15},title="Std. dev.    = ", help={"Log-normal distribution standard deviation [A]"}, fSize=10
		CheckBox LNSdeviationFit,pos={155,415},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Fit?"
		CheckBox LNSdeviationFit,variable= root:Packages:IR2L_NLSQF:LNSdeviationFit_pop1, help={"Fit the standard deviation for Log-Normal distribution?"}
		SetVariable LNSdeviationMin,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LNSdeviationMin_pop1,noproc
		SetVariable LNSdeviationMin,pos={200,415},size={80,15},title="Min ", help={"Low limit for standard deviation for Log-normal distribution"}, fSize=10
		SetVariable LNSdeviationMax,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LNSdeviationMax_pop1, noproc
		SetVariable LNSdeviationMax,pos={290,415},size={80,15},title="Max ", help={"High limit for standard deviation for Log-normal distribution"}, fSize=10
//	ListOfPopulationVariables+="GMeanSize;GMeanSizeFit;GMeanSizeMin;GMeanSizeMax;GWidth;GWidthFit;GWidthMin;GWidthMax;LSWLocation;LSWLocationFit;LSWLocationMin;LSWLocationMax;"	
		//Gauss parameters...
		SetVariable GMeanSize,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:GMeanSize_pop1,proc=IR2L_PopSetVarProc
		SetVariable GMeanSize,pos={8,375},size={140,15},title="Mean size [A]= ", help={"Gauss mean size [A]"}, fSize=10
		CheckBox GMeanSizeFit,pos={155,375},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Fit?"
		CheckBox GMeanSizeFit,variable= root:Packages:IR2L_NLSQF:GMeanSizeFit_pop1, help={"Fit the mean size for gaussian distribution?"}
		SetVariable GMeanSizeMin,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:GMeanSizeMin_pop1, noproc
		SetVariable GMeanSizeMin,pos={200,375},size={80,15},title="Min ", help={"Low limit for mean size for Gaussian distribution"}, fSize=10
		SetVariable GMeanSizeMax,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:GMeanSizeMax_pop1, noproc
		SetVariable GMeanSizeMax,pos={290,375},size={80,15},title="Max ", help={"High limit for mean size for Gaussian distribution"}, fSize=10

		SetVariable GWidth,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:GWidth_pop1,proc=IR2L_PopSetVarProc
		SetVariable GWidth,pos={8,395},size={140,15},title="Width [A]= ", help={"Gaussian width size [A]"}, fSize=10
		CheckBox GWidthFit,pos={155,395},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Fit?"
		CheckBox GWidthFit,variable= root:Packages:IR2L_NLSQF:GWidthFit_pop1, help={"Fit the width for Gaussian distribution?"}
		SetVariable GWidthMin,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:GWidthMin_pop1, noproc
		SetVariable GWidthMin,pos={200,395},size={80,15},title="Min ", help={"Low limit for width for Gaussian distribution"}, fSize=10
		SetVariable GWidthMax,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:GWidthMax_pop1, noproc
		SetVariable GWidthMax,pos={290,395},size={80,15},title="Max ", help={"High limit for width for Gaussian distribution"}, fSize=10
		//LSW parameters
		SetVariable LSWLocation,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LSWLocation_pop1,proc=IR2L_PopSetVarProc
		SetVariable LSWLocation,pos={8,375},size={140,15},title="Position [A]= ", help={"LSW size [A]"}, fSize=10
		CheckBox LSWLocationFit,pos={155,375},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Fit?"
		CheckBox LSWLocationFit,variable= root:Packages:IR2L_NLSQF:LSWLocationFit_pop1, help={"Fit the LSW position?"}
		SetVariable LSWLocationMin,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LSWLocationMin_pop1, noproc
		SetVariable LSWLocationMin,pos={200,375},size={80,15},title="Min ", help={"Low limit for LSW position"}, fSize=10
		SetVariable LSWLocationMax,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LSWLocationMax_pop1, noproc
		SetVariable LSWLocationMax,pos={290,375},size={80,15},title="Max ", help={"High limit for LSW position"}, fSize=10
		
		//interferences
//		CheckBox UseInterference,pos={40,435},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Use Structure factor?"
//		CheckBox UseInterference,variable= root:Packages:IR2L_NLSQF:UseInterference_pop1, help={"Check to use structure factor"}
		PopupMenu StructureFactorModel title="Structure Factor : ",proc=IR2L_PanelPopupControl, pos={10,435}
		PopupMenu StructureFactorModel value=#"(root:Packages:StructureFactorCalc:ListOfStructureFactors)"
		SVAR StrA=root:Packages:IR2L_NLSQF:StructureFactor_pop1
		SVAR StrB=root:Packages:StructureFactorCalc:ListOfStructureFactors
		PopupMenu StructureFactorModel mode=WhichListItem(StrA,StrB )+1
		PopupMenu StructureFactorModel help={"Select Dilute system or Structure factor to be used for this population of scatterers"}

		SetVariable Contrast,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:Contrast_pop1,proc=IR2L_PopSetVarProc
		SetVariable Contrast,pos={8,495},size={150,15},title="Contrast = ", help={"Contrast of this population"}, fSize=10
		SetVariable Contrast_set1,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:Contrast_set1_pop1,proc=IR2L_PopSetVarProc
		SetVariable Contrast_set1,pos={8,490},size={150,15},title="Contrast data 1 = ", help={"Contrast of this population for data set 1"}, fSize=10
		SetVariable Contrast_set2,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:Contrast_set2_pop1,proc=IR2L_PopSetVarProc
		SetVariable Contrast_set2,pos={8,510},size={150,15},title="Contrast data 2 = ", help={"Contrast of this population for data set 2"}, fSize=10
		SetVariable Contrast_set3,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:Contrast_set3_pop1,proc=IR2L_PopSetVarProc
		SetVariable Contrast_set3,pos={8,530},size={150,15},title="Contrast data 3 = ", help={"Contrast of this population for data set 3"}, fSize=10
		SetVariable Contrast_set4,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:Contrast_set4_pop1,proc=IR2L_PopSetVarProc
		SetVariable Contrast_set4,pos={8,550},size={150,15},title="Contrast data 4 = ", help={"Contrast of this population for data set 4"}, fSize=10
		SetVariable Contrast_set5,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:Contrast_set5_pop1,proc=IR2L_PopSetVarProc
		SetVariable Contrast_set5,pos={8,570},size={150,15},title="Contrast data 5 = ", help={"Contrast of this population for data set 5"}, fSize=10

		SetVariable Contrast_set6,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:Contrast_set6_pop1,proc=IR2L_PopSetVarProc
		SetVariable Contrast_set6,pos={178,490},size={150,15},title="Contrast data 6 = ", help={"Contrast of this population for data set 1"}, fSize=10
		SetVariable Contrast_set7,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:Contrast_set7_pop1,proc=IR2L_PopSetVarProc
		SetVariable Contrast_set7,pos={178,510},size={150,15},title="Contrast data 7 = ", help={"Contrast of this population for data set 2"}, fSize=10
		SetVariable Contrast_set8,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:Contrast_set8_pop1,proc=IR2L_PopSetVarProc
		SetVariable Contrast_set8,pos={178,530},size={150,15},title="Contrast data 8 = ", help={"Contrast of this population for data set 3"}, fSize=10
		SetVariable Contrast_set9,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:Contrast_set9_pop1,proc=IR2L_PopSetVarProc
		SetVariable Contrast_set9,pos={178,550},size={150,15},title="Contrast data 9 = ", help={"Contrast of this population for data set 4"}, fSize=10
		SetVariable Contrast_set10,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:Contrast_set10_pop1,proc=IR2L_PopSetVarProc
		SetVariable Contrast_set10,pos={178,570},size={150,15},title="Contrast set 10 = ", help={"Contrast of this population for data set 5"}, fSize=10

		//few more buttons
		CheckBox UseGeneticOptimization,pos={10,610},size={25,90},proc=IR2L_DataTabCheckboxProc,title="Genetic Optimization?"
		CheckBox UseGeneticOptimization,variable= root:Packages:IR2L_NLSQF:UseGeneticOptimization, help={"Use genetic Optimization? SLOW..."}
		CheckBox UseLSQF,pos={150,610},size={25,90},proc=IR2L_DataTabCheckboxProc,title="Use LSQF?"
		CheckBox UseLSQF,variable= root:Packages:IR2L_NLSQF:UseLSQF, help={"Use LSQF?"}

		Button Recalculate, pos={10,630},size={90,18},font="Times New Roman",fSize=9,proc=IR2L_InputPanelButtonProc,title="Calculate Model", help={"Recalculate model"}
		Button FitModel, pos={110,630},size={90,18},font="Times New Roman",fSize=9,proc=IR2L_InputPanelButtonProc,title="Fit Model", help={"Fit the model"}
		Button ReverseFit, pos={210,630},size={90,18},font="Times New Roman",fSize=9,proc=IR2L_InputPanelButtonProc,title="Reverese Fit", help={"Reverse fit"}
		Button SaveInDataFolder, pos={10,655},size={90,18},font="Times New Roman",fSize=9,proc=IR2L_InputPanelButtonProc,title="Save result", help={"Save result in the data folder"}
		Button SaveInWaves, pos={110,655},size={90,18},font="Times New Roman",fSize=9,proc=IR2L_InputPanelButtonProc,title="Save in Waves", help={"Save result in the separate folder in waves"}
		Button SaveInNotebook, pos={210,655},size={90,18},font="Times New Roman",fSize=9,proc=IR2L_InputPanelButtonProc,title="Save in Notebook", help={"Save result in output notebook"}



	IR2L_Model_TabPanelControl("",0)
	IR2L_DataTabCheckboxProc("MultipleInputData",MultipleInputData)		//carefull this will make graph to be top window!!!
	
	
//	ListOfPopulationVariables+="RdistAuto;RdistrSemiAuto;RdistMan;RdistManMin;RdisManMax;RdistLog;RdistNumPnts;RdistNeglectTails;"	
//	ListOfPopulationVariables+="Contrast;Contrast_set1;Contrast_set2;Contrast_set3;Contrast_set4;Contrast_set5;Contrast_set6;Contrast_set7;Contrast_set8;Contrast_set9;Contrast_set10;"	
//	ListOfPopulationVariables+="Volume;VolumeFit;VolumeMin;VolumeMax;"	
//	ListOfPopulationVariables+="LNMinSize;LNMinSizeFit;LNMinSizeMin;LNMinSizeMax;LNMeanSize;LNMeanSizeFit;LNMeanSizeMin;LNMeanSizeMax;LNSdeviation;LNSdeviationFit;LNSdeviationMin;LNSdeviationMax;"	
//	ListOfPopulationVariables+="GMeanSize;GMeanSizeFit;GMeanSizeMin;GMeanSizeMax;GWidth;GWidthFit;GWidthMin;GWidthMax;LSWLocation;LSWLocationFit;LSWLocationMin;LSWLocationMax;"	
//	ListOfPopulationsStrings+="PopFormFactor;"	
//	ListOfPopulationsStrings+="PopSizeDistShape;"	



//	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
//	DrawLine 16,171,339,171
//	DrawText 20,210,"Preview Options:"
//	SetDrawEnv fsize= 16,fstyle= 1
//	DrawText 20,340,"Output Options:"
////	SetDrawEnv textrgb= (0,0,65280),fstyle= 1, fsize= 12
////	DrawText 200,275,"Fit?:"
////	SetDrawEnv textrgb= (0,0,65280),fstyle= 1, fsize= 12
////	DrawText 230,275,"Low limit:    High Limit:"
////	DrawText 10,600,"Fit using least square fitting ?"
////	DrawPoly 113,225,1,1,{113,225,113,225}
//	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
//	DrawLine 16,310,339,310
////	SetDrawEnv textrgb= (0,0,65280),fstyle= 1
////	DrawText 4,640,"Results:"

end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


