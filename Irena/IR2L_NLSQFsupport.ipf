#pragma rtGlobals=1		// Use modern global access method.



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_InputGraphButtonProc(ctrlName) : ButtonControl
	String ctrlName

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF

	if(cmpstr(ctrlName,"AutoSetAxis")==0)
			IR2L_AutosetGraphAxis(1)
	endif
	if(cmpstr(ctrlName,"SetAxis")==0)
			IR2L_AutosetGraphAxis(0)
	endif
	DoWIndow/F LSQF_MainGraph
	setDataFolder oldDF
end



Function IR2L_InputPanelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF
	variable i
	if(cmpstr(ctrlName,"AddDataSet")==0)
		//here we load the data and create default values
		ControlInfo/W=LSQF2_MainPanel DataTabs
		IR2L_LoadDataIntoSet(V_Value+1)
		NVAR UseTheData_set=$("UseTheData_set"+num2str(V_Value+1))
		UseTheData_set=1
		IR2L_Data_TabPanelControl("",V_Value)
		IR2L_AppendDataIntoGraph(V_Value+1)
		IR2L_AppendOrRemoveLocalPopInts()
		IR2L_FormatInputGraph()
		IR2L_FormatLegend()
		DoWIndow LSQF_MainGraph
		if(V_Flag)
			AutoPositionWindow/R=LSQF2_MainPanel LSQF_MainGraph
		endif
	endif
	if(stringmatch(ctrlName,"Recalculate"))
		IR2L_CalculateIntensity(0,0)
	endif
	if(stringmatch(ctrlName,"ReverseFit"))
		IR2L_ResetParamsAfterBadFit()
	endif
	if(stringmatch(ctrlName,"FitModel"))
		IR2L_Fitting()
	endif
	if(cmpstr(ctrlName,"RemoveAllDataSets")==0)
		IR2L_RemoveAllDataSets()
	endif
	if(cmpstr(ctrlName,"UnuseAllDataSets")==0)
		IR2L_unUseAllDataSets()
	endif
	if(cmpstr(ctrlName,"SaveInDataFolder")==0)
		IR2L_SaveResultsInDataFolder()
	endif
	if(cmpstr(ctrlName,"SaveInWaves")==0)
		IR2L_SaveResultsInWaves()
	endif
	
	if(cmpstr(ctrlName,"ReadCursors")==0)
		ControlInfo/W=LSQF2_MainPanel DataTabs
		IR2L_SetQminQmaxWCursors(V_Value+1)
	endif
	if(cmpstr(ctrlName,"ConfigureGraph")==0)
		IR2C_ConfigMain()
		PauseForUser IR2C_MainConfigPanel
		IR2L_FormatInputGraph()
		IR2L_FormatLegend()
	endif
	if(cmpstr(ctrlName,"ReGraph")==0)
		DoWindow LSQF_MainGraph
		if(V_Flag)
			DoWindow/K LSQF_MainGraph
		endif
		NVAR MultipleInputData = root:Packages:IR2L_NLSQF:MultipleInputData
		variable MaxDataSets=10
		if(!MultipleInputData)
			MaxDataSets=1
		endif
		For(i=1;i<=MaxDataSets;i+=1)
			NVAR UseTheData_set=$("UseTheData_set"+num2str(i))
			if(UseTheData_set)
				IR2L_AppendDataIntoGraph(i)
			endif
		endfor
		IR2L_AppendOrRemoveLocalPopInts()	
		IR2L_FormatInputGraph()
		IR2L_FormatLegend()
		DoWIndow LSQF_MainGraph
		if(V_Flag)
			AutoPositionWindow/R=LSQF2_MainPanel LSQF_MainGraph
		endif
	endif

	if(cmpstr(ctrlName,"SaveInNotebook")==0)
			IR2L_SaveResultsInNotebook()
	endif
		
	DoWindow/F LSQF2_MainPanel
	setDataFolder oldDF
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_RemoveAllDataSets()
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF
	variable i
	DoAlert 1, "All data sets will be removed. Do you really want to do it?"
	if(V_Flag==1) 
		
		For(i=1;i<11;i+=1)
			IR2L_RemoveDataFromGraph(i)		//remove the data from graph
			NVAR UseTheData_set=$("UseTheData_set"+num2str(i))	//set them not to be used
			UseTheData_set=0
			SVAR Fldr=$("root:Packages:IR2L_NLSQF:FolderName_set"+num2str(i))
			SVAR Int=$("root:Packages:IR2L_NLSQF:IntensityDataName_set"+num2str(i))
			SVAR Qvec=$("root:Packages:IR2L_NLSQF:QvecDataName_set"+num2str(i))
			SVAR Err = $("root:Packages:IR2L_NLSQF:ErrorDataName_set"+num2str(i))
			Fldr=""
			Int=""
			Qvec=""
			Err=""
			Wave/Z IntWv=$("root:Packages:IR2L_NLSQF:Intensity_set"+num2str(i))
			Wave/Z QWv=$("root:Packages:IR2L_NLSQF:Q_set"+num2str(i))
			Wave/Z ErrWv=$("root:Packages:IR2L_NLSQF:Error_set"+num2str(i))
			if(WaveExists(IntWv))
				KillWaves/Z IntWv
			endif
			if(WaveExists(QWv))
				KillWaves/Z QWv
			endif
			if(WaveExists(ErrWv))
				KillWaves/Z ErrWv
			endif
		endfor
		ControlInfo/W=LSQF2_MainPanel DataTabs
		IR2L_Data_TabPanelControl("",V_Value)
	endif
	setDataFolder oldDF
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_unUseAllDataSets()
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF
	variable i
	For(i=1;i<11;i+=1)
		IR2L_RemoveDataFromGraph(i)
		NVAR UseTheData_set=$("UseTheData_set"+num2str(i))
		UseTheData_set=0
	endfor
	ControlInfo/W=LSQF2_MainPanel DataTabs
	IR2L_Data_TabPanelControl("",V_Value)
	setDataFolder oldDF
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR2L_PanelPopupControl(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF
	if (stringmatch(ctrlName,"FormFactorPop"))
		ControlInfo/W=LSQF2_MainPanel DistTabs
		SVAR FormFactor = $("root:Packages:IR2L_NLSQF:FormFactor_pop"+num2str(V_Value+1))
		FormFactor = popStr
		IR2L_CallPanelFromFFpackage(V_Value+1)
	endif
	
	if (stringmatch(ctrlName,"PopSizeDistShape"))
		ControlInfo/W=LSQF2_MainPanel DistTabs
		SVAR PopSizeDistShape = $("root:Packages:IR2L_NLSQF:PopSizeDistShape_pop"+num2str(V_Value+1))
		PopSizeDistShape = popStr
		IR2L_Model_TabPanelControl("",V_Value)
	endif

	if(stringmatch(ctrlName,"StructureFactorModel") )
			variable whichDataSet
			ControlInfo/W=LSQF2_MainPanel DistTabs
			whichDataSet= V_Value+1
			SVAR StrFac=$("root:Packages:IR2L_NLSQF:StructureFactor_pop"+num2str(whichDataSet))
			StrFac = popStr
			DoWindow StructureFactorControlScreen
			if(V_Flag)
				DoWindow/K StructureFactorControlScreen
			endif
//	ListOfPopulationVariables+="StructureParam3;StructureParam3Fit;StructureParam3Min;StructureParam3Max;StructureParam4;StructureParam4Fit;StructureParam4Min;StructureParam4Max;"
///	ListOfPopulationVariables+="StructureParam5;StructureParam5Fit;StructureParam5Min;StructureParam5Max;"

			string TitleStr= "Structure Factor for Pop"+num2str(whichDataSet)+" of LSQF2 modeling"
			string SFStr = "root:Packages:IR2L_NLSQF:StructureFactor_pop"+num2str(whichDataSet)
			string P1Str = "root:Packages:IR2L_NLSQF:StructureParam1_pop"+num2str(whichDataSet)
			string FitP1Str = "root:Packages:IR2L_NLSQF:StructureParam1Fit_pop"+num2str(whichDataSet)
			string LowP1Str = "root:Packages:IR2L_NLSQF:StructureParam1Min_pop"+num2str(whichDataSet)
			string HighP1Str = "root:Packages:IR2L_NLSQF:StructureParam1Max_pop"+num2str(whichDataSet)
			string P2Str = "root:Packages:IR2L_NLSQF:StructureParam2_pop"+num2str(whichDataSet)
			string FitP2Str = "root:Packages:IR2L_NLSQF:StructureParam2Fit_pop"+num2str(whichDataSet)
			string LowP2Str = "root:Packages:IR2L_NLSQF:StructureParam2Min_pop"+num2str(whichDataSet)
			string HighP2Str = "root:Packages:IR2L_NLSQF:StructureParam2Max_pop"+num2str(whichDataSet)

			string P3Str = "root:Packages:IR2L_NLSQF:StructureParam3_pop"+num2str(whichDataSet)
			string FitP3Str = "root:Packages:IR2L_NLSQF:StructureParam3Fit_pop"+num2str(whichDataSet)
			string LowP3Str = "root:Packages:IR2L_NLSQF:StructureParam3Min_pop"+num2str(whichDataSet)
			string HighP3Str = "root:Packages:IR2L_NLSQF:StructureParam3Max_pop"+num2str(whichDataSet)

			string P4Str = "root:Packages:IR2L_NLSQF:StructureParam4_pop"+num2str(whichDataSet)
			string FitP4Str = "root:Packages:IR2L_NLSQF:StructureParam4Fit_pop"+num2str(whichDataSet)
			string LowP4Str = "root:Packages:IR2L_NLSQF:StructureParam4Min_pop"+num2str(whichDataSet)
			string HighP4Str = "root:Packages:IR2L_NLSQF:StructureParam4Max_pop"+num2str(whichDataSet)

			string P5Str = "root:Packages:IR2L_NLSQF:StructureParam5_pop"+num2str(whichDataSet)
			string FitP5Str = "root:Packages:IR2L_NLSQF:StructureParam5Fit_pop"+num2str(whichDataSet)
			string LowP5Str = "root:Packages:IR2L_NLSQF:StructureParam5Min_pop"+num2str(whichDataSet)
			string HighP5Str = "root:Packages:IR2L_NLSQF:StructureParam5Max_pop"+num2str(whichDataSet)

			string P6Str = "root:Packages:IR2L_NLSQF:StructureParam6_pop"+num2str(whichDataSet)
			string FitP6Str = "root:Packages:IR2L_NLSQF:StructureParam6Fit_pop"+num2str(whichDataSet)
			string LowP6Str = "root:Packages:IR2L_NLSQF:StructureParam6Min_pop"+num2str(whichDataSet)
			string HighP6Str = "root:Packages:IR2L_NLSQF:StructureParam6Max_pop"+num2str(whichDataSet)

			//the Structure factor package will take of making the fit parameters fo hidden parameters uncheckedm if they are checked.  
			string SFUserSFformula = ""
			IR2S_MakeSFParamPanel(TitleStr,SFStr,P1Str,FitP1Str,LowP1Str,HighP1Str,P2Str,FitP2Str,LowP2Str,HighP2Str,P3Str,FitP3Str,LowP3Str,HighP3Str,P4Str,FitP4Str,LowP4Str,HighP4Str,P5Str,FitP5Str,LowP5Str,HighP5Str,P6Str,FitP6Str,LowP6Str,HighP6Str,SFUserSFformula)
			DoWIndow  StructureFactorControlScreen
			if(V_Flag)
					SetWindow StructureFactorControlScreen  hook(Update)=IR2L_UpdateHook
					SetDrawEnv /W=StructureFactorControlScreen fstyle= 3
	//				DrawText/W=StructureFactorControlScreen 4,220,"Hit enter twice to auto recalculate (if Auto recalculate is selected)"
			endif
	endif
	IR2L_RecalculateIfSelected() 
	setDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_UpdateHook(H_Struct)
	STRUCT WMWinHookStruct &H_Struct

	 if(stringmatch(H_Struct.eventName,"Keyboard"))
		IR2L_RecalculateIfSelected() 
	 endif
//	<code to test and process events>
//	...
//	return statusCode		// 0 if nothing done, else 1
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function  IR2L_CallPanelFromFFpackage(which)
	variable which

	string TitleStr="Form factor parameters for Population "+num2str(which)
	string FFStr="root:Packages:IR2L_NLSQF:FormFactor_pop"+num2str(which)
	string P1Str="root:Packages:IR2L_NLSQF:FormFactor_Param1_pop"+num2str(which)
	string FitP1Str="root:Packages:IR2L_NLSQF:FormFactor_Param1Fit_pop"+num2str(which)
	string LowP1Str="root:Packages:IR2L_NLSQF:FormFactor_Param1Min_pop"+num2str(which)
	string HighP1Str="root:Packages:IR2L_NLSQF:FormFactor_Param1Max_pop"+num2str(which)
	string P2Str="root:Packages:IR2L_NLSQF:FormFactor_Param2_pop"+num2str(which)
	string FitP2Str="root:Packages:IR2L_NLSQF:FormFactor_Param2Fit_pop"+num2str(which)
	string LowP2Str="root:Packages:IR2L_NLSQF:FormFactor_Param2Min_pop"+num2str(which)
	string HighP2Str="root:Packages:IR2L_NLSQF:FormFactor_Param2Max_pop"+num2str(which)
	string P3Str="root:Packages:IR2L_NLSQF:FormFactor_Param3_pop"+num2str(which)
	string FitP3Str="root:Packages:IR2L_NLSQF:FormFactor_Param3Fit_pop"+num2str(which)
	string LowP3Str="root:Packages:IR2L_NLSQF:FormFactor_Param3Min_pop"+num2str(which)
	string HighP3Str="root:Packages:IR2L_NLSQF:FormFactor_Param3Max_pop"+num2str(which)
	string P4Str="root:Packages:IR2L_NLSQF:FormFactor_Param4_pop"+num2str(which)
	string FitP4Str="root:Packages:IR2L_NLSQF:FormFactor_Param4Fit_pop"+num2str(which)
	string LowP4Str="root:Packages:IR2L_NLSQF:FormFactor_Param4Min_pop"+num2str(which)
	string HighP4Str="root:Packages:IR2L_NLSQF:FormFactor_Param4Max_pop"+num2str(which)
	string P5Str="root:Packages:IR2L_NLSQF:FormFactor_Param5_pop"+num2str(which)
	string FitP5Str="root:Packages:IR2L_NLSQF:FormFactor_Param5Fit_pop"+num2str(which)
	string LowP5Str="root:Packages:IR2L_NLSQF:FormFactor_Param5Min_pop"+num2str(which)
	string HighP5Str="root:Packages:IR2L_NLSQF:FormFactor_Param5Max_pop"+num2str(which)
	string FFUserFFformula="root:Packages:IR2L_NLSQF:FFUserFFformula_pop"+num2str(which)
	string FFUserVolumeFormula="root:Packages:IR2L_NLSQF:FFUserVolumeFormula_pop"+num2str(which)
		

 
 	IR1T_MakeFFParamPanel(TitleStr,FFStr,P1Str,FitP1Str,LowP1Str,HighP1Str,P2Str,FitP2Str,LowP2Str,HighP2Str,P3Str,FitP3Str,LowP3Str,HighP3Str,P4Str,FitP4Str,LowP4Str,HighP4Str,P5Str,FitP5Str,LowP5Str,HighP5Str,FFUserFFformula,FFUserVolumeFormula)

	DoWIndow  FormFactorControlScreen
	if(V_Flag)
			SetWindow FormFactorControlScreen  hook(Update)=IR2L_UpdateHook
			SetDrawEnv /W=FormFactorControlScreen fstyle= 3
//			DrawText/W=FormFactorControlScreen 4,295,"Hit enter twice to auto recalculate (if Auto recalculate is selected)"
	endif

end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_Data_TabPanelControl(name,tab)
	String name
	Variable tab

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF

		SVAR rgbIntensity_set=$("root:Packages:IR2L_NLSQF:rgbIntensity_set"+num2str(tab+1))
		Execute("Button AddDataSet,win=LSQF2_MainPanel, fColor="+rgbIntensity_set)
		variable i
		NVAR DisplayInputDataControls=root:Packages:IR2L_NLSQF:DisplayInputDataControls
		NVAR DisplayModelControls=root:Packages:IR2L_NLSQF:DisplayModelControls
		NVAR displayControls = $("UseTheData_set"+num2str(tab+1))
		NVAR DisplayFitRange = $("BackgroundFit_set"+num2str(tab+1))
		NVAR DisplaySlitSmeared = $("SlitSmeared_set"+num2str(tab+1))
		Wave/Z InputIntensity= $("Intensity_set"+num2str(tab+1))
		Wave/Z InputQ=$("Q_set"+num2str(tab+1))
		Wave/Z InputError= $("Error_set"+num2str(tab+1))
		variable displayUseCheckbox=1
		if(!WaveExists(InputIntensity) || !WaveExists(InputQ) || !WaveExists(InputError))
			displayUseCheckbox=0
			displayControls = 0
		endif

		Button AddDataSet, win=LSQF2_MainPanel, disable=( !DisplayInputDataControls)
		Button ReadCursors, win=LSQF2_MainPanel,disable=( !DisplayInputDataControls || !displayControls) 
		Execute("CheckBox UseTheData_set ,win=LSQF2_MainPanel ,variable= root:Packages:IR2L_NLSQF:UseTheData_set"+num2str(tab+1)+", disable=( !"+num2str(DisplayInputDataControls)+"||!"+num2str(displayUseCheckbox)+")")
		Execute("CheckBox SlitSmeared_set ,win=LSQF2_MainPanel ,variable= root:Packages:IR2L_NLSQF:SlitSmeared_set"+num2str(tab+1)+", disable=( !"+num2str(displayControls)+"||!"+num2str(DisplayInputDataControls)+")")
		Execute("SetVariable SlitLength_set ,win=LSQF2_MainPanel ,value= root:Packages:IR2L_NLSQF:SlitLength_set"+num2str(tab+1)+", disable=( !"+num2str(displayControls)+"|| !"+num2str(DisplaySlitSmeared)+"||!"+num2str(DisplayInputDataControls)+")")
		Execute("SetVariable FolderName_set ,win=LSQF2_MainPanel ,value= root:Packages:IR2L_NLSQF:FolderName_set"+num2str(tab+1)+", disable=( !"+num2str(DisplayInputDataControls)+"||!"+num2str(displayUseCheckbox)+")")
		Execute("SetVariable UserDataSetName_set ,win=LSQF2_MainPanel ,value= root:Packages:IR2L_NLSQF:UserDataSetName_set"+num2str(tab+1)+", disable=( !"+num2str(DisplayInputDataControls)+"||!"+num2str(displayUseCheckbox)+")")
		Execute("SetVariable Qmin_set ,win=LSQF2_MainPanel ,value= root:Packages:IR2L_NLSQF:Qmin_set"+num2str(tab+1)+", disable=( !"+num2str(displayControls)+"||!"+num2str(DisplayInputDataControls)+")")
		Execute("SetVariable Qmax_set ,win=LSQF2_MainPanel ,value= root:Packages:IR2L_NLSQF:Qmax_set"+num2str(tab+1)+", disable=( !"+num2str(displayControls)+"||!"+num2str(DisplayInputDataControls)+")")
		Execute("SetVariable Background ,win=LSQF2_MainPanel ,limits={0,Inf,root:Packages:IR2L_NLSQF:BackgStep_set"+num2str(tab+1)+"}, variable=root:Packages:IR2L_NLSQF:Background_set"+num2str(tab+1)+", disable=( !"+num2str(displayControls)+"||!"+num2str(DisplayInputDataControls)+")")
//		Execute("SetVariable BackgStep ,win=LSQF2_MainPanel ,value= root:Packages:IR2L_NLSQF:BackgStep_set"+num2str(tab+1)+", disable=( !"+num2str(displayControls)+"||!"+num2str(DisplayInputDataControls)+")")
		Execute("SetVariable BackgroundMin ,win=LSQF2_MainPanel ,value= root:Packages:IR2L_NLSQF:BackgroundMin_set"+num2str(tab+1)+", disable=( !"+num2str(displayControls)+"||!"+num2str(DisplayFitRange)+"||!"+num2str(DisplayInputDataControls)+")")
		Execute("SetVariable BackgroundMax ,win=LSQF2_MainPanel ,variable=root:Packages:IR2L_NLSQF:BackgroundMax_set"+num2str(tab+1)+", disable=( !"+num2str(displayControls)+"||!"+num2str(DisplayFitRange)+"||!"+num2str(DisplayInputDataControls)+")")
		Execute("CheckBox BackgroundFit_set ,win=LSQF2_MainPanel ,variable= root:Packages:IR2L_NLSQF:BackgroundFit_set"+num2str(tab+1)+", disable=( !"+num2str(displayControls)+"||!"+num2str(DisplayInputDataControls)+")")
		
		Execute("SetVariable DataScalingFactor_set,win=LSQF2_MainPanel,value= root:Packages:IR2L_NLSQF:DataScalingFactor_set"+num2str(tab+1)+", disable=( !"+num2str(displayControls)+"||!"+num2str(DisplayInputDataControls)+")")
		Execute("CheckBox UseUserErrors_set,win=LSQF2_MainPanel, variable= root:Packages:IR2L_NLSQF:UseUserErrors_set"+num2str(tab+1)+", disable=( !"+num2str(displayControls)+"||!"+num2str(DisplayInputDataControls)+")")
		Execute("CheckBox UseSQRTErrors_set,win=LSQF2_MainPanel, variable= root:Packages:IR2L_NLSQF:UseSQRTErrors_set"+num2str(tab+1)+", disable=( !"+num2str(displayControls)+"||!"+num2str(DisplayInputDataControls)+")")
		Execute("CheckBox UsePercentErrors_set,win=LSQF2_MainPanel, variable= root:Packages:IR2L_NLSQF:UsePercentErrors_set"+num2str(tab+1)+", disable=( !"+num2str(displayControls)+"||!"+num2str(DisplayInputDataControls)+")")
		Execute("SetVariable ErrorScalingFactor_set,win=LSQF2_MainPanel,value= root:Packages:IR2L_NLSQF:ErrorScalingFactor_set"+num2str(tab+1)+", disable=( !"+num2str(displayControls)+"||!"+num2str(DisplayInputDataControls)+")")
	
	setDataFolder OldDf
	IR2L_AppendOrRemoveLocalPopInts()
	DoWindow/F LSQF2_MainPanel
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_Model_TabPanelControl(name,tab)
	String name
	Variable tab

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF
	
	NVAR DisplayInputDataControls=root:Packages:IR2L_NLSQF:DisplayInputDataControls
	NVAR DisplayModelControls=root:Packages:IR2L_NLSQF:DisplayModelControls
	NVAR UsePop=$("root:Packages:IR2L_NLSQF:UseThePop_pop"+num2str(tab+1))
	NVAR RdistAuto=$("root:Packages:IR2L_NLSQF:RdistAuto_pop"+num2str(tab+1))
	NVAR RdistManual=$("root:Packages:IR2L_NLSQF:RdistMan_pop"+num2str(tab+1))
	NVAR DisplayVolumeLims=$("root:Packages:IR2L_NLSQF:VolumeFit_pop"+num2str(tab+1))
	NVAR SameContr=root:Packages:IR2L_NLSQF:SameContrastForDataSets
	NVAR MID=root:Packages:IR2L_NLSQF:MultipleInputData
	NVAR UD1=UseTheData_set1
	NVAR UD2=UseTheData_set2
	NVAR UD3=UseTheData_set3
	NVAR UD4=UseTheData_set4
	NVAR UD5=UseTheData_set5
	NVAR UD6=UseTheData_set6
	NVAR UD7=UseTheData_set7
	NVAR UD8=UseTheData_set8
	NVAR UD9=UseTheData_set9
	NVAR UD10=UseTheData_set10
	SVAR Shape=$("root:Packages:IR2L_NLSQF:PopSizeDistShape_pop"+num2str(tab+1))
	variable S_sw
	if(stringmatch(Shape, "LogNormal"))
		S_sw=1
	elseif(stringmatch(Shape, "Gauss"))
		S_sw=2
	else
		S_sw=3			//we have LSW....
	endif


		Execute("CheckBox UseThePop,win=LSQF2_MainPanel ,variable=root:Packages:IR2L_NLSQF:UseThePop_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+")")
		Execute("CheckBox RdistAuto,win=LSQF2_MainPanel ,variable= root:Packages:IR2L_NLSQF:RdistAuto_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(UsePop)+")")
		Execute("CheckBox RdistrSemiAuto,win=LSQF2_MainPanel ,variable= root:Packages:IR2L_NLSQF:RdistrSemiAuto_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(UsePop)+")")
		Execute("CheckBox RdistMan,win=LSQF2_MainPanel ,variable= root:Packages:IR2L_NLSQF:RdistMan_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(UsePop)+")")

		Execute("SetVariable RdistNumPnts,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:RdistNumPnts_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable RdistManMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:RdistManMin_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable RdistManMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:RdistManMax_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(UsePop)+"|| "+num2str(!RdistManual)+")")

		Execute("SetVariable RdistNeglectTails,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:RdistNeglectTails_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(UsePop)+"|| "+num2str(RdistManual)+")")

		Execute("CheckBox RdistLog,win=LSQF2_MainPanel ,variable= root:Packages:IR2L_NLSQF:RdistLog_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(UsePop)+")")

		Execute("PopupMenu FormFactorPop,win=LSQF2_MainPanel, mode=(WhichListItem(root:Packages:IR2L_NLSQF:FormFactor_pop"+num2str(tab+1)+",root:Packages:FormFactorCalc:ListOfFormFactors)+1), disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(UsePop)+")")

		Execute("PopupMenu PopSizeDistShape,win=LSQF2_MainPanel, mode=(WhichListItem(root:Packages:IR2L_NLSQF:PopSizeDistShape_pop"+num2str(tab+1)+",\"LogNormal;Gauss;LSW\")+1), disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(UsePop)+")")

		Execute("SetVariable Volume,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:Volume_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(UsePop)+")")
		Execute("Checkbox FitVolume,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:VolumeFit_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable VolumeMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:VolumeMin_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(UsePop)+"|| !"+num2str(DisplayVolumeLims)+")")
		Execute("SetVariable VolumeMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:VolumeMax_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(UsePop)+"|| !"+num2str(DisplayVolumeLims)+")")

		NVAR DLNM1=$("root:Packages:IR2L_NLSQF:LNMinSizeFit_pop"+num2str(tab+1))
		Execute("SetVariable LNMinSize,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:LNMinSize_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(S_sw==1)+"|| !"+num2str(UsePop)+")")
		Execute("Checkbox LNMinSizeFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:LNMinSizeFit_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(S_sw==1)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable LNMinSizeMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:LNMinSizeMin_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(S_sw==1)+"|| !"+num2str(UsePop)+"|| !"+num2str(DLNM1)+")")
		Execute("SetVariable LNMinSizeMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:LNMinSizeMax_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(S_sw==1)+"|| !"+num2str(UsePop)+"|| !"+num2str(DLNM1)+")")
//		SetVariable LNMinSize,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LNMinSize_pop1
//		CheckBox LNMinSizeFit,variable= root:Packages:IR2L_NLSQF:LNMinSizeFit_pop1, help={"Fit the Min size for Log-Normal distribution?"}
//		SetVariable LNMinSizeMin,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LNMinSizeMin_pop1
//		SetVariable LNMinSizeMax,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LNMinSizeMax_pop1

		NVAR DLNM2=$("root:Packages:IR2L_NLSQF:LNMeanSizeFit_pop"+num2str(tab+1))
		Execute("SetVariable LNMeanSize,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:LNMeanSize_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(S_sw==1)+"|| !"+num2str(UsePop)+")")
		Execute("Checkbox LNMeanSizeFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:LNMeanSizeFit_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(S_sw==1)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable LNMeanSizeMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:LNMeanSizeMin_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(S_sw==1)+"|| !"+num2str(UsePop)+"|| !"+num2str(DLNM2)+")")
		Execute("SetVariable LNMeanSizeMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:LNMeanSizeMax_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(S_sw==1)+"|| !"+num2str(UsePop)+"|| !"+num2str(DLNM2)+")")
//		SetVariable LNMeanSize,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LNMeanSize_pop1
//		CheckBox LNMeanSizeFit,variable= root:Packages:IR2L_NLSQF:LNMeanSizeFit_pop1, help={"Fit the mean size for Log-Normal distribution?"}
//		SetVariable LNMeanSizeMin,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LNMeanSizeMin_pop1
//		SetVariable LNMeanSizeMax,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LNMeanSizeMax_pop1

		NVAR DLNM3=$("root:Packages:IR2L_NLSQF:LNSdeviationFit_pop"+num2str(tab+1))
		Execute("SetVariable LNSdeviation,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:LNSdeviation_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(S_sw==1)+"|| !"+num2str(UsePop)+")")
		Execute("Checkbox LNSdeviationFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:LNSdeviationFit_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(S_sw==1)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable LNSdeviationMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:LNSdeviationMin_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(S_sw==1)+"|| !"+num2str(UsePop)+"|| !"+num2str(DLNM3)+")")
		Execute("SetVariable LNSdeviationMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:LNSdeviationMax_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(S_sw==1)+"|| !"+num2str(UsePop)+"|| !"+num2str(DLNM3)+")")
//		SetVariable LNSdeviation,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LNSdeviation_pop1
//		CheckBox LNSdeviationFit,variable= root:Packages:IR2L_NLSQF:LNSdeviationFit_pop1, help={"Fit the standard deviation for Log-Normal distribution?"}
//		SetVariable LNSdeviationMin,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LNSdeviationMin_pop1
//		SetVariable LNSdeviationMax,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LNSdeviationMax_pop1

		NVAR DGM1=$("root:Packages:IR2L_NLSQF:GMeanSizeFit_pop"+num2str(tab+1))
		Execute("SetVariable GMeanSize,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:GMeanSize_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(S_sw==2)+"|| !"+num2str(UsePop)+")")
		Execute("Checkbox GMeanSizeFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:GMeanSizeFit_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(S_sw==2)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable GMeanSizeMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:GMeanSizeMin_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(S_sw==2)+"|| !"+num2str(UsePop)+"|| !"+num2str(DGM1)+")")
		Execute("SetVariable GMeanSizeMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:GMeanSizeMax_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(S_sw==2)+"|| !"+num2str(UsePop)+"|| !"+num2str(DGM1)+")")
//		SetVariable GMeanSize,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:GMeanSize_pop1
//		CheckBox GMeanSizeFit,variable= root:Packages:IR2L_NLSQF:GMeanSizeFit_pop1, help={"Fit the mean size for gaussian distribution?"}
//		SetVariable GMeanSizeMin,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:GMeanSizeMin_pop1
//		SetVariable GMeanSizeMax,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:GMeanSizeMax_pop1

		NVAR DGM2=$("root:Packages:IR2L_NLSQF:GWidthFit_pop"+num2str(tab+1))
		Execute("SetVariable GWidth,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:GWidth_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(S_sw==2)+"|| !"+num2str(UsePop)+")")
		Execute("Checkbox GWidthFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:GWidthFit_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(S_sw==2)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable GWidthMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:GWidthMin_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(S_sw==2)+"|| !"+num2str(UsePop)+"|| !"+num2str(DGM2)+")")
		Execute("SetVariable GWidthMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:GWidthMax_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(S_sw==2)+"|| !"+num2str(UsePop)+"|| !"+num2str(DGM2)+")")
//		SetVariable GWidth,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:GWidth_pop1
//		CheckBox GWidthFit,variable= root:Packages:IR2L_NLSQF:GWidthFit_pop1, help={"Fit the width for Gaussian distribution?"}
//		SetVariable GWidthMin,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:GWidthMin_pop1
//		SetVariable GWidthMax,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:GWidthMax_pop1

		NVAR DLSW1=$("root:Packages:IR2L_NLSQF:LSWLocationFit_pop"+num2str(tab+1))
		Execute("SetVariable LSWLocation,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:LSWLocation_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(S_sw==3)+"|| !"+num2str(UsePop)+")")
		Execute("Checkbox LSWLocationFit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:LSWLocationFit_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(S_sw==3)+"|| !"+num2str(UsePop)+")")
		Execute("SetVariable LSWLocationMin,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:LSWLocationMin_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(S_sw==3)+"|| !"+num2str(UsePop)+"|| !"+num2str(DLSW1)+")")
		Execute("SetVariable LSWLocationMax,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:LSWLocationMax_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(S_sw==3)+"|| !"+num2str(UsePop)+"|| !"+num2str(DLSW1)+")")
//		SetVariable LSWLocation,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LSWLocation_pop1
//		CheckBox LSWLocationFit,variable= root:Packages:IR2L_NLSQF:LSWLocationFit_pop1, help={"Fit the LSW position?"}
//		SetVariable LSWLocationMin,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LSWLocationMin_pop1
//		SetVariable LSWLocationMax,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:LSWLocationMax_pop1

//		NVAR UseIntf=$("root:Packages:IR2L_NLSQF:UseInterference_pop"+num2str(tab+1))
//		Execute("CheckBox UseInterference,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:UseInterference_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(UsePop)+")")
		SVAR StrA=$("root:Packages:IR2L_NLSQF:StructureFactor_pop"+num2str(tab+1))
		SVAR StrB=root:Packages:StructureFactorCalc:ListOfStructureFactors
		Execute("PopupMenu StructureFactorModel win=LSQF2_MainPanel, mode=WhichListItem(\""+StrA+"\",\""+StrB+"\" )+1, disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(UsePop)+")")

//		Execute("SetVariable StructureParam1,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:StructureParam1_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+" || !"+num2str(UseIntf)+"|| !"+num2str(UsePop)+")")  
//		Execute("CheckBox StructureParam1Fit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:StructureParam1Fit_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+" || !"+num2str(UseIntf)+"|| !"+num2str(UsePop)+")")
//		NVAR StructureParam1Fit = $("root:Packages:IR2L_NLSQF:StructureParam1Fit_pop"+num2str(tab+1))
//		Execute("SetVariable StructureParam1Min,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:StructureParam1Min_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+" || !"+num2str(UseIntf)+"|| !"+Num2str(StructureParam1Fit)+"|| !"+num2str(UsePop)+")")
//		Execute("SetVariable StructureParam1Max,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:StructureParam1Max_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+" || !"+num2str(UseIntf)+"|| !"+Num2str(StructureParam1Fit)+"|| !"+num2str(UsePop)+")")
//
//
//		Execute("SetVariable StructureParam2,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:StructureParam2_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+" || !"+num2str(UseIntf)+"|| !"+num2str(UsePop)+")")
//		Execute("CheckBox StructureParam2Fit,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:StructureParam2Fit_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+" || !"+num2str(UseIntf)+"|| !"+num2str(UsePop)+")")
//		NVAR StructureParam2Fit = $("root:Packages:IR2L_NLSQF:StructureParam2Fit_pop"+num2str(tab+1))
//		Execute("SetVariable StructureParam2Min,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:StructureParam2Min_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+" || !"+num2str(UseIntf)+"|| !"+Num2str(StructureParam2Fit)+"|| !"+num2str(UsePop)+")")
//		Execute("SetVariable StructureParam2Max,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:StructureParam2Max_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+" || !"+num2str(UseIntf)+"|| !"+Num2str(StructureParam2Fit)+"|| !"+num2str(UsePop)+")")

		Execute("SetVariable Contrast,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:Contrast_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(UsePop)+"|| !"+num2str(!SameContr || !MID)+")")

		Execute("SetVariable Contrast_set1,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:Contrast_set1_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(UD1)+"|| !"+num2str(UsePop)+"|| "+num2str(!SameContr || !MID)+")")
		Execute("SetVariable Contrast_set2,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:Contrast_set2_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(UD2)+"|| !"+num2str(UsePop)+"|| "+num2str(!SameContr || !MID)+")")
		Execute("SetVariable Contrast_set3,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:Contrast_set3_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(UD3)+"|| !"+num2str(UsePop)+"|| "+num2str(!SameContr || !MID)+")")
		Execute("SetVariable Contrast_set4,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:Contrast_set4_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(UD4)+"|| !"+num2str(UsePop)+"|| "+num2str(!SameContr || !MID)+")")
		Execute("SetVariable Contrast_set5,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:Contrast_set5_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(UD5)+"|| !"+num2str(UsePop)+"|| "+num2str(!SameContr || !MID)+")")
		Execute("SetVariable Contrast_set6,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:Contrast_set6_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(UD6)+"|| !"+num2str(UsePop)+"|| "+num2str(!SameContr || !MID)+")")
		Execute("SetVariable Contrast_set7,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:Contrast_set7_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(UD7)+"|| !"+num2str(UsePop)+"|| "+num2str(!SameContr || !MID)+")")
		Execute("SetVariable Contrast_set8,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:Contrast_set8_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(UD8)+"|| !"+num2str(UsePop)+"|| "+num2str(!SameContr || !MID)+")")
		Execute("SetVariable Contrast_set9,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:Contrast_set9_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(UD9)+"|| !"+num2str(UsePop)+"|| "+num2str(!SameContr || !MID)+")")
		Execute("SetVariable Contrast_set10,win=LSQF2_MainPanel,variable= root:Packages:IR2L_NLSQF:Contrast_set10_pop"+num2str(tab+1)+", disable=(!"+num2str(DisplayModelControls)+"|| !"+num2str(UD10)+"|| !"+num2str(UsePop)+"|| "+num2str(!SameContr || !MID)+")")
		
	setDataFolder OldDf
	
	//update the graph with displayed Mean mode etc...
	IR2L_GraphSizeDistUpdate()
	IR2L_AppendOrRemoveLocalPopInts()
	DoWindow/F LSQF2_MainPanel
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_SetQminQmaxWCursors(WhichDataSet)
	variable WhichDataSet
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF

	Wave CurQ=$("Q_set"+num2str(whichDataSet))
	NVAR Qmax_set=$("Qmax_set"+num2str(whichDataSet))
	NVAR Qmin_set=$("Qmin_set"+num2str(whichDataSet))

	if(cmpstr("Intensity_set"+num2str(whichDataSet),stringByKey("TNAME",CsrInfo(A ,"LSQF_MainGraph")))==0)
		Qmin_set=CurQ[pcsr(A, "LSQF_MainGraph")]
	endif
	if(cmpstr("Intensity_set"+num2str(whichDataSet),stringByKey("TNAME",CsrInfo(B ,"LSQF_MainGraph")))==0)
		Qmax_set=CurQ[pcsr(B, "LSQF_MainGraph")]
	endif
	if(Qmin_set>Qmax_set)
		variable tempS
		tempS=Qmin_set
		Qmin_set=Qmax_set
		Qmax_set=tempS
	endif
	IR2L_setQMinMax(whichDataSet)
	setDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_PopSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF
	variable whichDataSet
	//BackgStep_set
	ControlInfo/W=LSQF2_MainPanel DistTabs
	whichDataSet= V_Value+1
	
	if(stringmatch(ctrlName,"Volume"))
		//set volume limits... 
		NVAR VolMin=$("root:Packages:IR2L_NLSQF:VolumeMin_pop"+num2str(whichDataSet))
		NVAR VolMax=$("root:Packages:IR2L_NLSQF:VolumeMax_pop"+num2str(whichDataSet))
		VolMin= varNum*0.5
		VolMax=varNum*2
		Execute("SetVariable Volume,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(varNum*0.05)+"}")	
	endif
		//LN controls...
	if(stringmatch(ctrlName,"LNMinSize"))
		//set LNMinSize limits... 
		NVAR LNMinSizeMin=$("root:Packages:IR2L_NLSQF:LNMinSizeMin_pop"+num2str(whichDataSet))
		NVAR LNMinSizeMax=$("root:Packages:IR2L_NLSQF:LNMinSizeMax_pop"+num2str(whichDataSet))
		LNMinSizeMin= varNum*0.5
		LNMinSizeMax=varNum*2
		Execute("SetVariable LNMinSize,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(varNum*0.05)+"}")
	endif
	if(stringmatch(ctrlName,"LNMeanSize"))
		//set LNMeanSize limits... 
		NVAR LNMeanSizeMin=$("root:Packages:IR2L_NLSQF:LNMeanSizeMin_pop"+num2str(whichDataSet))
		NVAR LNMeanSizeMax=$("root:Packages:IR2L_NLSQF:LNMeanSizeMax_pop"+num2str(whichDataSet))
		LNMeanSizeMin= varNum*0.5
		LNMeanSizeMax=varNum*2
		Execute("SetVariable LNMeanSize,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(varNum*0.05)+"}")
	endif
	if(stringmatch(ctrlName,"LNSdeviation"))
		//set LNSdeviation limits... 
		NVAR LNSdeviationMin=$("root:Packages:IR2L_NLSQF:LNSdeviationMin_pop"+num2str(whichDataSet))
		NVAR LNSdeviationMax=$("root:Packages:IR2L_NLSQF:LNSdeviationMax_pop"+num2str(whichDataSet))
		LNSdeviationMin= varNum*0.5
		LNSdeviationMax=varNum*2
		Execute("SetVariable LNSdeviation,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(varNum*0.05)+"}")
	endif
		//GW controls
	if(stringmatch(ctrlName,"GMeanSize"))
		//set GMeanSize limits... 
		NVAR GMeanSizeMin=$("root:Packages:IR2L_NLSQF:GMeanSizeMin_pop"+num2str(whichDataSet))
		NVAR GMeanSizeMax=$("root:Packages:IR2L_NLSQF:GMeanSizeMax_pop"+num2str(whichDataSet))
		GMeanSizeMin= varNum*0.5
		GMeanSizeMax=varNum*2
		Execute("SetVariable  GMeanSize,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(varNum*0.05)+"}")
	endif
	if(stringmatch(ctrlName,"GWidth"))
		//set GWidth limits... 
		NVAR GWidthMin=$("root:Packages:IR2L_NLSQF:GWidthMin_pop"+num2str(whichDataSet))
		NVAR GWidthMax=$("root:Packages:IR2L_NLSQF:GWidthMax_pop"+num2str(whichDataSet))
		GWidthMin= varNum*0.5
		GWidthMax=varNum*2
		Execute("SetVariable  GWidth,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(varNum*0.05)+"}")
	endif
		//LSW params		
	if(stringmatch(ctrlName,"LSWLocation"))
		//set LSWLocation limits... 
		NVAR LSWLocationMin=$("root:Packages:IR2L_NLSQF:LSWLocationMin_pop"+num2str(whichDataSet))
		NVAR LSWLocationMax=$("root:Packages:IR2L_NLSQF:LSWLocationMax_pop"+num2str(whichDataSet))
		LSWLocationMin= varNum*0.5
		LSWLocationMax=varNum*2
		Execute("SetVariable  LSWLocation,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(varNum*0.05)+"}")
	endif
	if(stringmatch(ctrlName,"StructureParam1"))
		//set LSWLocation limits... 
		NVAR StructureParam1Min=$("root:Packages:IR2L_NLSQF:StructureParam1Min_pop"+num2str(whichDataSet))
		NVAR StructureParam1Max=$("root:Packages:IR2L_NLSQF:StructureParam1Max_pop"+num2str(whichDataSet))
		StructureParam1Min= varNum*0.5
		StructureParam1Max=varNum*2
		Execute("SetVariable  StructureParam1,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(varNum*0.05)+"}")
	endif
	if(stringmatch(ctrlName,"StructureParam2"))
		//set LSWLocation limits... 
		NVAR StructureParam2Min=$("root:Packages:IR2L_NLSQF:StructureParam2Min_pop"+num2str(whichDataSet))
		NVAR StructureParam2Max=$("root:Packages:IR2L_NLSQF:StructureParam2Max_pop"+num2str(whichDataSet))
		StructureParam2Min= varNum*0.5
		StructureParam2Max=varNum*2
		Execute("SetVariable  StructureParam2,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(varNum*0.05)+"}")
	endif
	//contrasts
	
	setDataFolder OldDf
	IR2L_RecalculateIfSelected() 
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_DataTabSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF
	variable whichDataSet
	//BackgStep_set
	ControlInfo/W=LSQF2_MainPanel DataTabs
	whichDataSet= V_Value+1
	if(stringmatch(ctrlName, "BackgStep_set"))
		Execute("SetVariable Background_set,limits={0,Inf,root:Packages:IR2L_NLSQF:BackgStep_set"+num2str(whichDataSet)+"},win=LSQF2_MainPanel")
	endif
	if(stringmatch(ctrlName, "Qmin_set"))
		IR2L_setQMinMax(whichDataSet)
		IR2L_RecalculateIfSelected() 
	endif
	if(stringmatch(ctrlName, "Qmax_set"))
		IR2L_setQMinMax(whichDataSet)
		IR2L_RecalculateIfSelected() 
	endif
	if(stringmatch(ctrlName, "Background"))
		//set Background limits... 
		NVAR BackgroundMin_set=$("root:Packages:IR2L_NLSQF:BackgroundMin_set"+num2str(whichDataSet))
		NVAR BackgroundMax_set=$("root:Packages:IR2L_NLSQF:BackgroundMax_set"+num2str(whichDataSet))
		BackgroundMin_set= varNum*0.01
		BackgroundMax_set=varNum*10
		Execute("SetVariable Background,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(varNum*0.05)+"}")	
		IR2L_RecalculateIfSelected() 
	endif
	if(stringmatch(ctrlName, "UserDataSetName_set"))
		IR2L_FormatLegend()
	endif
	if(stringmatch(ctrlName, "ErrorScalingFactor_set"))
		IR2L_RecalculateErrors(WhichDataSet)
	endif

	if(stringMatch(ctrlName,"GraphXMin") ||stringMatch(ctrlName,"GraphXMax") ||stringMatch(ctrlName,"GraphYMin") ||stringMatch(ctrlName,"GraphYMax"))
		IR2L_FormatInputGraph()
	endif
	
	setDataFolder OldDf
end	


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_setQMinMax(whichDataSet)
	variable whichDataSet
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF
	Wave CurMask=$("IntensityMask_set"+num2str(whichDataSet))
	Wave CurQ=$("Q_set"+num2str(whichDataSet))
	NVAR Qmax_set=$("Qmax_set"+num2str(whichDataSet))
	NVAR Qmin_set=$("Qmin_set"+num2str(whichDataSet))

	variable QminPoint=binarysearch(CurQ, Qmin_set)
	if(QminPoint<0)
		Qmin_set=CurQ[0]
	endif
	if(CurQ[QminPoint]<0)
		QminPoint=binarysearch(CurQ, 0)+1
		Qmin_set = CurQ[QminPoint]
	endif
	
	variable QmaxPoint=binarysearch(CurQ, Qmax_set)
	if(QmaxPoint<0)
		QmaxPoint=numpnts(CurQ)
		Qmax_set=CurQ[inf]
	endif
	
	CurMask[0,QminPoint]=1
	CurMask[QminPoint,QmaxPoint+1]=5
	CurMask[QmaxPoint,inf]=1
	DoWindow LSQF_MainGraph
	if(V_Flag)
		ModifyGraph/Z/W=LSQF_MainGraph zmrkSize( $("Intensity_set"+num2str(whichDataSet)))={$("IntensityMask_set"+num2str(whichDataSet)),0,5,0.5,3}
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
//*****************************************************************************************************************
//*****************************************************************************************************************



Function IR2L_ModelTabCheckboxProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF
	

	ControlInfo/W=LSQF2_MainPanel DistTabs
	variable WhichPopSet= V_Value+1

	if (stringMatch(ctrlName,"UseThePop"))

	endif
	//RdistrSemiAuto, RdistMan, RdistAuto
	NVAR RdistrSemiAuto=$("root:Packages:IR2L_NLSQF:RdistrSemiAuto_pop"+num2str(WhichPopSet))
	NVAR RdistMan=$("root:Packages:IR2L_NLSQF:RdistMan_pop"+num2str(WhichPopSet))
	NVAR RdistAuto=$("root:Packages:IR2L_NLSQF:RdistAuto_pop"+num2str(WhichPopSet))
	if (stringMatch(ctrlName,"RdistAuto"))
		if(checked)
			RdistAuto=1
			RdistrSemiAuto=0
			RdistMan = 0
		else
			RdistAuto=0
			RdistrSemiAuto=1
			RdistMan = 0
		endif
		Execute("SetVariable RdistManMin,win=LSQF2_MainPanel,disable=("+num2str(RdistAuto)+")")
		Execute("SetVariable RdistManMax,win=LSQF2_MainPanel,disable=("+num2str(RdistAuto)+")")
		Execute("SetVariable RdistNeglectTails,win=LSQF2_MainPanel, disable=(!"+num2str(RdistAuto)+")")
	endif
	if (stringMatch(ctrlName,"RdistrSemiAuto"))
		if(checked)
			RdistAuto=0
			RdistrSemiAuto=1
			RdistMan = 0
		else
			RdistAuto=1
			RdistrSemiAuto=0
			RdistMan = 0
		endif
		Execute("SetVariable RdistManMin,win=LSQF2_MainPanel,disable=("+num2str(RdistAuto)+")")
		Execute("SetVariable RdistManMax,win=LSQF2_MainPanel,disable=("+num2str(RdistAuto)+")")
		Execute("SetVariable RdistNeglectTails,win=LSQF2_MainPanel, disable=(!"+num2str(RdistAuto)+")")
	endif
	if (stringMatch(ctrlName,"RdistMan"))
		if(checked)
			RdistAuto=0
			RdistrSemiAuto=0
			RdistMan = 1
		else
			RdistAuto=1
			RdistrSemiAuto=0
			RdistMan = 0
		endif
		Execute("SetVariable RdistManMin,win=LSQF2_MainPanel,disable=("+num2str(RdistAuto)+")")
		Execute("SetVariable RdistManMax,win=LSQF2_MainPanel,disable=("+num2str(RdistAuto)+")")
		Execute("SetVariable RdistNeglectTails,win=LSQF2_MainPanel, disable=(!"+num2str(RdistAuto)+")")
	endif
	
/////////////////////////////
	variable whichDataSet
	//BackgStep_set
	ControlInfo/W=LSQF2_MainPanel DistTabs
	whichDataSet= V_Value+1
	
	if(stringmatch(ctrlName,"FitVolume"))
		//set volume limits... 
		NVAR Vol=$("root:Packages:IR2L_NLSQF:Volume_pop"+num2str(whichDataSet))
		NVAR VolMin=$("root:Packages:IR2L_NLSQF:VolumeMin_pop"+num2str(whichDataSet))
		NVAR VolMax=$("root:Packages:IR2L_NLSQF:VolumeMax_pop"+num2str(whichDataSet))
		VolMin= Vol*0.2
		VolMax=Vol*5
		Execute("SetVariable Volume,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(Vol*0.05)+"}")	
	endif
		//LN controls...
	if(stringmatch(ctrlName,"LNMinSizeFit"))
		//set LNMinSize limits... 
		NVAR LNMinSize=$("root:Packages:IR2L_NLSQF:LNMinSize_pop"+num2str(whichDataSet))
		NVAR LNMinSizeMin=$("root:Packages:IR2L_NLSQF:LNMinSizeMin_pop"+num2str(whichDataSet))
		NVAR LNMinSizeMax=$("root:Packages:IR2L_NLSQF:LNMinSizeMax_pop"+num2str(whichDataSet))
		LNMinSizeMin= LNMinSize*0.1
		LNMinSizeMax=LNMinSize*10
		Execute("SetVariable LNMinSize,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(LNMinSize*0.05)+"}")
	endif
	if(stringmatch(ctrlName,"LNMeanSizeFit"))
		//set LNMeanSize limits... 
		NVAR LNMeanSize=$("root:Packages:IR2L_NLSQF:LNMeanSize_pop"+num2str(whichDataSet))
		NVAR LNMeanSizeMin=$("root:Packages:IR2L_NLSQF:LNMeanSizeMin_pop"+num2str(whichDataSet))
		NVAR LNMeanSizeMax=$("root:Packages:IR2L_NLSQF:LNMeanSizeMax_pop"+num2str(whichDataSet))
		LNMeanSizeMin= LNMeanSize*0.1
		LNMeanSizeMax=LNMeanSize*10
		Execute("SetVariable LNMeanSize,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(LNMeanSize*0.05)+"}")
	endif
	if(stringmatch(ctrlName,"LNSdeviationFit"))
		//set LNSdeviation limits... 
		NVAR LNSdeviation=$("root:Packages:IR2L_NLSQF:LNSdeviation_pop"+num2str(whichDataSet))
		NVAR LNSdeviationMin=$("root:Packages:IR2L_NLSQF:LNSdeviationMin_pop"+num2str(whichDataSet))
		NVAR LNSdeviationMax=$("root:Packages:IR2L_NLSQF:LNSdeviationMax_pop"+num2str(whichDataSet))
		LNSdeviationMin= LNSdeviation*0.1
		LNSdeviationMax=LNSdeviation*10
		Execute("SetVariable LNSdeviation,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(LNSdeviation*0.05)+"}")
	endif
		//GW controls
	if(stringmatch(ctrlName,"GMeanSizeFit"))
		//set GMeanSize limits... 
		NVAR GMeanSize=$("root:Packages:IR2L_NLSQF:GMeanSize_pop"+num2str(whichDataSet))
		NVAR GMeanSizeMin=$("root:Packages:IR2L_NLSQF:GMeanSizeMin_pop"+num2str(whichDataSet))
		NVAR GMeanSizeMax=$("root:Packages:IR2L_NLSQF:GMeanSizeMax_pop"+num2str(whichDataSet))
		GMeanSizeMin= GMeanSize*0.1
		GMeanSizeMax=GMeanSize*10
		Execute("SetVariable  GMeanSize,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(GMeanSize*0.05)+"}")
	endif
	if(stringmatch(ctrlName,"GWidthFit"))
		//set GWidth limits... 
		NVAR GWidth=$("root:Packages:IR2L_NLSQF:GWidth_pop"+num2str(whichDataSet))
		NVAR GWidthMin=$("root:Packages:IR2L_NLSQF:GWidthMin_pop"+num2str(whichDataSet))
		NVAR GWidthMax=$("root:Packages:IR2L_NLSQF:GWidthMax_pop"+num2str(whichDataSet))
		GWidthMin= GWidth*0.1
		GWidthMax=GWidth*10
		Execute("SetVariable  GWidth,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(GWidth*0.05)+"}")
	endif
		//LSW params		
	if(stringmatch(ctrlName,"LSWLocationFit"))
		//set LSWLocation limits... 
		NVAR LSWLocation=$("root:Packages:IR2L_NLSQF:LSWLocation_pop"+num2str(whichDataSet))
		NVAR LSWLocationMin=$("root:Packages:IR2L_NLSQF:LSWLocationMin_pop"+num2str(whichDataSet))
		NVAR LSWLocationMax=$("root:Packages:IR2L_NLSQF:LSWLocationMax_pop"+num2str(whichDataSet))
		LSWLocationMin= LSWLocation*0.1
		LSWLocationMax=LSWLocation*10
		Execute("SetVariable  LSWLocation,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(LSWLocation*0.05)+"}")
	endif
//	if(stringmatch(ctrlName,"StructureParam1Fit") || stringmatch(ctrlName,"UseInterference") )
//		//set LSWLocation limits... 
//		NVAR MeanVal=$("root:Packages:IR2L_NLSQF:Mean_pop"+num2str(whichDataSet))
//		NVAR StructureParam1=$("root:Packages:IR2L_NLSQF:StructureParam1_pop"+num2str(whichDataSet))
//		NVAR StructureParam1Min=$("root:Packages:IR2L_NLSQF:StructureParam1Min_pop"+num2str(whichDataSet))
//		NVAR StructureParam1Max=$("root:Packages:IR2L_NLSQF:StructureParam1Max_pop"+num2str(whichDataSet))
//		if(StructureParam1<MeanVal)
//			StructureParam1 = MeanVal
//		endif
//		StructureParam1Min= StructureParam1*0.1
//		StructureParam1Max=StructureParam1*10
//		Execute("SetVariable  StructureParam1,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(StructureParam1*0.05)+"}")
//	endif
//	if(stringmatch(ctrlName,"StructureParam2Fit"))
//		//set LSWLocation limits... 
//		NVAR StructureParam2=$("root:Packages:IR2L_NLSQF:StructureParam2_pop"+num2str(whichDataSet))
//		NVAR StructureParam2Min=$("root:Packages:IR2L_NLSQF:StructureParam2Min_pop"+num2str(whichDataSet))
//		NVAR StructureParam2Max=$("root:Packages:IR2L_NLSQF:StructureParam2Max_pop"+num2str(whichDataSet))
//		StructureParam2Min= StructureParam2*0.1
//		StructureParam2Max=StructureParam2*10
//		Execute("SetVariable  StructureParam2,win=LSQF2_MainPanel,limits={0,Inf,"+num2str(StructureParam2*0.05)+"}")
//	endif
//	if(stringmatch(ctrlName,"UseInterference") )
//		if(checked)
//			string TitleStr= "Structure Factor for Pop"+num2str(whichDataSet)+" of LSQF2 modeling"
//			string SFStr = "root:Packages:IR2L_NLSQF:StructureFactor_pop"+num2str(whichDataSet)
//			string P1Str = "root:Packages:IR2L_NLSQF:StructureParam1_pop"+num2str(whichDataSet)
//			string FitP1Str = "root:Packages:IR2L_NLSQF:StructureParam1Fit_pop"+num2str(whichDataSet)
//			string LowP1Str = "root:Packages:IR2L_NLSQF:StructureParam1Min_pop"+num2str(whichDataSet)
//			string HighP1Str = "root:Packages:IR2L_NLSQF:StructureParam1Max_pop"+num2str(whichDataSet)
//			string P2Str = "root:Packages:IR2L_NLSQF:StructureParam2_pop"+num2str(whichDataSet)
//			string FitP2Str = "root:Packages:IR2L_NLSQF:StructureParam2Fit_pop"+num2str(whichDataSet)
//			string LowP2Str = "root:Packages:IR2L_NLSQF:StructureParam2Min_pop"+num2str(whichDataSet)
//			string HighP2Str = "root:Packages:IR2L_NLSQF:StructureParam2Max_pop"+num2str(whichDataSet)
//			string P3Str = ""
//			string FitP3Str = ""
//			string LowP3Str = ""
//			string HighP3Str = ""
//			string P4Str = ""
//			string FitP4Str = ""
//			string LowP4Str = ""
//			string HighP4Str = ""
//			string P5Str = ""
//			string FitP5Str = ""
//			string LowP5Str = ""
//			string HighP5Str = ""
//			string SFUserSFformula = ""
//			IR2S_MakeSFParamPanel(TitleStr,SFStr,P1Str,FitP1Str,LowP1Str,HighP1Str,P2Str,FitP2Str,LowP2Str,HighP2Str,P3Str,FitP3Str,LowP3Str,HighP3Str,P4Str,FitP4Str,LowP4Str,HighP4Str,P5Str,FitP5Str,LowP5Str,HighP5Str,SFUserSFformula)
//		else
//			DoWindow StructureFactorControlScreen
//			if(V_Flag)
//				DoWindow/K StructureFactorControlScreen
//			endif
//		endif
//	endif
//		SetVariable StructureParam1,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:StructureParam1_pop1,proc=IR2L_PopSetVarProc
//		SetVariable StructureParam1,pos={8,455},size={140,15},title="ETA [A]= ", help={"ETA for interferences [A] (see manual)"}, fSize=10
//		CheckBox StructureParam1Fit,pos={155,455},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Fit?"
//		CheckBox StructureParam1Fit,variable= root:Packages:IR2L_NLSQF:StructureParam1Fit_pop1, help={"Fit the ETA position?"}
//		SetVariable StructureParam1Min,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:StructureParam1Min_pop1, noproc
//		SetVariable StructureParam1Min,pos={200,455},size={80,15},title="Min ", help={"Low limit for ETA position"}, fSize=10
//		SetVariable StructureParam1Max,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:StructureParam1Max_pop1, noproc
//		SetVariable StructureParam1Max,pos={290,455},size={80,15},title="Max ", help={"High limit for ETA position"}, fSize=10
//		
//		SetVariable StructureParam2,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:StructureParam2_pop1,proc=IR2L_PopSetVarProc
//		SetVariable StructureParam2,pos={8,475},size={140,15},title="Phi = ", help={"Phi for interferences (see manual)"}, fSize=10
//		CheckBox StructureParam2Fit,pos={155,475},size={25,16},proc=IR2L_ModelTabCheckboxProc,title="Fit?"
//		CheckBox StructureParam2Fit,variable= root:Packages:IR2L_NLSQF:StructureParam2Fit_pop1, help={"Fit the phi?"}
//		SetVariable StructureParam2Min,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:StructureParam2Min_pop1, noproc
//		SetVariable StructureParam2Min,pos={200,475},size={80,15},title="Min ", help={"Low limit for phi position"}, fSize=10
//		SetVariable StructureParam2Max,limits={0,Inf,0},variable= root:Packages:IR2L_NLSQF:StructureParam2Max_pop1, noproc
//		SetVariable StructureParam2Max,pos={290,475},size={80,15},title="Max ", help={"High limit for phi"}, fSize=10


/////////////////////////////
	if(!stringMatch(ctrlName,"*Fit*"))	//skip recalculations when user select what to fit... No real change was done... 
		IR2L_RecalculateIfSelected()
	endif
	ControlInfo/W=LSQF2_MainPanel DistTabs
	IR2L_Model_TabPanelControl("",V_Value)
	DoWindow/F LSQF2_MainPanel
	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_RecalculateErrors(WhichDataSet)
	variable WhichDataSet
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF


	NVAR UseUserErrors = $("UseUserErrors_set"+num2str(WhichDataSet))
	NVAR UseSQRTErrors = $("UseSQRTErrors_set"+num2str(WhichDataSet))
	NVAR UsePercentErrors = $("UsePercentErrors_set"+num2str(WhichDataSet))
	NVAR ErrorScalingFactor = $("ErrorScalingFactor_set"+num2str(WhichDataSet))
		SVAR NewFldrName=$("root:Packages:IR2L_NLSQF:FolderName_set"+num2str(whichDataSet))
		SVAR NewIntName = $("root:Packages:IR2L_NLSQF:IntensityDataName_set"+num2str(whichDataSet))
		SVAR NewQName=$("root:Packages:IR2L_NLSQF:QvecDataName_set"+num2str(whichDataSet))
		SVAR NewErrorName=$("root:Packages:IR2L_NLSQF:ErrorDataName_set"+num2str(whichDataSet))
		NVAR SlitSmeared_set=$("root:Packages:IR2L_NLSQF:SlitSmeared_set"+num2str(whichDataSet))

	setDataFolder NewFldrName
	wave/Z inputI=$(NewIntName)
	wave/Z inputQ=$(NewQName)
	wave/Z inputE=$(NewErrorName)
	if(!WaveExists(inputE))
		UseUserErrors=0
		if(UseSQRTErrors+UsePercentErrors!=1)
			UseSQRTErrors=1
			UsePercentErrors=0
		endif
	endif
	setDataFolder root:Packages:IR2L_NLSQF
	if(UseUserErrors)		//handle special cases of errors not loaded in Igor
		Duplicate/O inputE, $("Error_set"+num2str(whichDataSet))		
	elseif(UseSQRTErrors)
		Duplicate/O inputI, $("Error_set"+num2str(whichDataSet))	
		Wave ErrorWv=$("Error_set"+num2str(whichDataSet))	
		Wave IntWv= $("Intensity_set"+num2str(whichDataSet))
		ErrorWv=sqrt(IntWv)
	else
		Duplicate/O inputI, $("Error_set"+num2str(whichDataSet))	
		Wave ErrorWv=$("Error_set"+num2str(whichDataSet))	
		Wave IntWv= $("Intensity_set"+num2str(whichDataSet))
		ErrorWv=0.01*(IntWv)
	endif
	Wave ErrorWv=$("Error_set"+num2str(whichDataSet))	
	ErrorWv = ErrorWv * ErrorScalingFactor
	variable i
	wavestats/Q ErrorWv
	ErrorWv = (numtype(ErrorWv[p])==0) ? ErrorWv[p] : V_min

	setDataFolder OldDf

end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_Initialize()

	string OldDf=GetDataFolder(1)
	setdatafolder root:
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S IR2L_NLSQF

	string/g ListOfVariables, ListOfDataVariables, ListOfPopulationVariables
	string/g ListOfStrings, ListOfDataStrings, ListOfPopulationsStrings
	variable i, j
	
	ListOfPopulationsStrings=""	
	ListOfDataStrings=""	

	//here define the lists of variables and strings needed, separate names by ;...
	
	//Main parameters
	ListOfVariables="UseIndra2Data;UseQRSdata;UseSMRData;MultipleInputData;UseNumberDistributions;RecalculateAutomatically;DisplaySinglePopInt;"
	ListOfVariables+="SameContrastForDataSets;VaryContrastForDataSets;DisplayInputDataControls;DisplayModelControls;UseGeneticOptimization;UseLSQF;"
	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;"

	ListOfVariables+="GraphXMin;GraphXMax;GraphYMin;GraphYMax;SizeDistLogX;SizeDistDisplayNumDist;SizeDistDisplayVolDist;"
	ListOfVariables+="SizeDistLogVolDist;SizeDistLogNumDist;"


	//Input Data parameters... Will have _setX attached, in this method background needs to be here...
	ListOfDataVariables="UseTheData;SlitSmeared;SlitLength;Qmin;Qmax;"
	ListOfDataVariables+="Background;BackgroundFit;BackgroundMin;BackgroundMax;BackgErr;BackgStep;"
	ListOfDataVariables+="DataScalingFactor;ErrorScalingFactor;UseUserErrors;UseSQRTErrors;UsePercentErrors;"
	ListOfDataStrings ="FolderName;IntensityDataName;QvecDataName;ErrorDataName;UserDataSetName;"
	
	
	//Model parameters, these need to have _popX attached at the end of name
	ListOfPopulationVariables="UseThePop;"//UseInterference;"
		//R distribution parameters
	ListOfPopulationVariables+="RdistAuto;RdistrSemiAuto;RdistMan;RdistManMin;RdistManMax;RdistLog;RdistNumPnts;RdistNeglectTails;"	
	ListOfPopulationVariables+="Contrast;Contrast_set1;Contrast_set2;Contrast_set3;Contrast_set4;Contrast_set5;Contrast_set6;Contrast_set7;Contrast_set8;Contrast_set9;Contrast_set10;"	
		//Form factor parameters
	ListOfPopulationsStrings+="FormFactor;FFUserFFformula;FFUserVolumeFormula;StructureFactor;"	
	ListOfPopulationVariables+="FormFactor_Param1;FormFactor_Param1Fit;FormFactor_Param1Min;FormFactor_Param1Max;"	
	ListOfPopulationVariables+="FormFactor_Param2;FormFactor_Param2Fit;FormFactor_Param2Min;FormFactor_Param2Max;"	
	ListOfPopulationVariables+="FormFactor_Param3;FormFactor_Param3Fit;FormFactor_Param3Min;FormFactor_Param3Max;"	
	ListOfPopulationVariables+="FormFactor_Param4;FormFactor_Param4Fit;FormFactor_Param4Min;FormFactor_Param4Max;"	
	ListOfPopulationVariables+="FormFactor_Param5;FormFactor_Param5Fit;FormFactor_Param5Min;FormFactor_Param5Max;"	
		//Distribution parameters
	ListOfPopulationVariables+="Volume;VolumeFit;VolumeMin;VolumeMax;Mean;Mode;Median;FWHM;"	
	ListOfPopulationVariables+="LNMinSize;LNMinSizeFit;LNMinSizeMin;LNMinSizeMax;LNMeanSize;LNMeanSizeFit;LNMeanSizeMin;LNMeanSizeMax;LNSdeviation;LNSdeviationFit;LNSdeviationMin;LNSdeviationMax;"	
	ListOfPopulationVariables+="GMeanSize;GMeanSizeFit;GMeanSizeMin;GMeanSizeMax;GWidth;GWidthFit;GWidthMin;GWidthMax;LSWLocation;LSWLocationFit;LSWLocationMin;LSWLocationMax;"	

	ListOfPopulationVariables+="StructureParam1;StructureParam1Fit;StructureParam1Min;StructureParam1Max;StructureParam2;StructureParam2Fit;StructureParam2Min;StructureParam2Max;"
	ListOfPopulationVariables+="StructureParam3;StructureParam3Fit;StructureParam3Min;StructureParam3Max;StructureParam4;StructureParam4Fit;StructureParam4Min;StructureParam4Max;"
	ListOfPopulationVariables+="StructureParam5;StructureParam5Fit;StructureParam5Min;StructureParam5Max;StructureParam6;StructureParam6Fit;StructureParam6Min;StructureParam6Max;"
	
	ListOfPopulationsStrings+="PopSizeDistShape;"	
		
		
	
	
	
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
	//following needs to run 10 times to create 10 sets for 10 data sets...
	for(j=1;j<=10;j+=1)	
		for(i=0;i<itemsInList(ListOfDataVariables);i+=1)	
			IN2G_CreateItem("variable",StringFromList(i,ListOfDataVariables)+"_set"+num2str(j))
		endfor	
	endfor
	//following needs to run 6 times to create 6 different populations sets of variables and strings	
	for(j=1;j<=6;j+=1)	
		for(i=0;i<itemsInList(ListOfPopulationVariables);i+=1)	
			IN2G_CreateItem("variable",StringFromList(i,ListOfPopulationVariables)+"_pop"+num2str(j))
		endfor
	endfor		
	//following 10 times as these are data sets
	for(j=1;j<=10;j+=1)	
		for(i=0;i<itemsInList(ListOfDataStrings);i+=1)	
			IN2G_CreateItem("string",StringFromList(i,ListOfDataStrings)+"_set"+num2str(j))
		endfor	
	endfor		
	for(j=1;j<=6;j+=1)	
		for(i=0;i<itemsInList(ListOfPopulationsStrings);i+=1)	
			IN2G_CreateItem("string",StringFromList(i,ListOfPopulationsStrings)+"_pop"+num2str(j))
		endfor	
	endfor		
										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	

	NVAR UseGeneticOptimization
	NVAR UseLSQF
	UseLSQF = !UseGeneticOptimization

	String/g rgbIntensity_set1="(52224,0,0)"
	String/g rgbIntensity_set2="(0,39168,0)"
	String/g rgbIntensity_set3="(0,9472,39168)"
	String/g rgbIntensity_set4="(39168,0,31232)"
	String/g rgbIntensity_set5="(65280,16384,16384)"
	String/g rgbIntensity_set6="(16384,65280,16384)"
	String/g rgbIntensity_set7="(16384,28160,65280)"
	String/g rgbIntensity_set8="(65280,16384,55552)"
	String/g rgbIntensity_set9="(0,0,0)"
	String/g rgbIntensity_set10="(34816,34816,34816)"

	String/g rgbIntensityLine_set10="(52224,0,0)"
	String/g rgbIntensityLine_set9="(0,39168,0)"
	String/g rgbIntensityLine_set8="(0,9472,39168)"
	String/g rgbIntensityLine_set7="(39168,0,31232)"
	String/g rgbIntensityLine_set6="(65280,16384,16384)"
	String/g rgbIntensityLine_set5="(16384,65280,16384)"
	String/g rgbIntensityLine_set4="(16384,28160,65280)"
	String/g rgbIntensityLine_set3="(65280,16384,55552)"
	String/g rgbIntensityLine_set2="(0,0,0)"
	String/g rgbIntensityLine_set1="(34816,34816,34816)"

	for(j=1;j<=6;j+=1)	
		for(i=0;i<itemsInList(ListOfPopulationsStrings);i+=1)	
			SVAR testStr = $( "StructureFactor_pop"+num2str(j))
			if(strlen(testStr)==0)
				testStr="Dilute system"
			endif
		endfor	
	endfor		

	setDataFolder OldDf

end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_SetInitialValues(enforce)
	variable enforce
	//and here set default values...

	string OldDf=getDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF
	
//	abort "finish me - IE2L_SetInitialValues"
	string ListOfVariables
	variable i, j
	//here we set what needs to be 0
	//Main parameters
//	ListOfVariables="UseIndra2Data;UseQRSdata;UseSMRData;MultipleInputData;"
//	ListOfVariables+="SameContrastForDataSets;VaryContrastForDataSets;DisplayInputDataControls;DisplayModelControls;"
//	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;"
//
//	ListOfVariables+="GraphXMin;GraphXMax;GraphYMin;GraphYMax;"
//
//
//	//Input Data parameters... Will have _setX attached, in this method background needs to be here...
//	ListOfDataVariables="UseTheData;SlitSmeared;SlitLength;Qmin;Qmax;"
//	ListOfDataVariables+="Background;BackgroundFit;BackgroundMin;BackgroundMax;BackgErr;BackgStep;"
//	ListOfDataVariables+="DataScalingFactor;ErrorScalingFactor;UseUserErrors;UseSQRTErrors;UsePercentErrors;"
//	ListOfDataStrings ="FolderName;IntensityDataName;QvecDataName;ErrorDataName;UserDataSetName;"
//	
//	
//	//Model parameters, these need to have _popX attached at the end of name
//	ListOfPopulationVariables="UseThePop;"
//		//R distribution parameters
//	ListOfPopulationVariables+="RdistAuto;RdistrSemiAuto;RdistMan;RdistManMin;RdistManMax;RdistLog;RdistNumPnts;RdistNeglectTails;"	
//	ListOfPopulationVariables+="Contrast;Contrast_set1;Contrast_set2;Contrast_set3;Contrast_set4;Contrast_set5;Contrast_set6;Contrast_set7;Contrast_set8;Contrast_set9;Contrast_set10;"	
//		//Form factor parameters
//	ListOfPopulationsStrings+="FormFactor;FFUserFFformula;FFUserVolumeFormula;"	
//	ListOfPopulationVariables+="FormFactor_Param1;FormFactor_Param1Fit;FormFactor_Param1Min;FormFactor_Param1Max;"	
//	ListOfPopulationVariables+="FormFactor_Param2;FormFactor_Param2Fit;FormFactor_Param2Min;FormFactor_Param2Max;"	
//	ListOfPopulationVariables+="FormFactor_Param3;FormFactor_Param3Fit;FormFactor_Param3Min;FormFactor_Param3Max;"	
//	ListOfPopulationVariables+="FormFactor_Param4;FormFactor_Param4Fit;FormFactor_Param4Min;FormFactor_Param4Max;"	
//	ListOfPopulationVariables+="FormFactor_Param5;FormFactor_Param5Fit;FormFactor_Param5Min;FormFactor_Param5Max;"	
//		//Distribution parameters
//	ListOfPopulationVariables+="Volume;VolumeFit;VolumeMin;VolumeMax;"	
//	ListOfPopulationVariables+="LNMinSize;LNMinSizeFit;LNMinSizeMin;LNMinSizeMax;LNMeanSize;LNMeanSizeFit;LNMeanSizeMin;LNMeanSizeMax;LNSdeviation;LNSdeviationFit;LNSdeviationMin;LNSdeviationMax;"	
//	ListOfPopulationVariables+="GMeanSize;GMeanSizeFit;GMeanSizeMin;GMeanSizeMax;GWidth;GWidthFit;GWidthMin;GWidthMax;LSWLocation;LSWLocationFit;LSWLocationMin;LSWLocationMax;"	
//
//	ListOfPopulationsStrings+="PopSizeDistShape;"	


//set initial values....
	//set starting conditions here....
	//SameContrastForDataSets;VaryContrastForDataSets;DisplayInputDataControls;DisplayModelControls
	NVAR SameContrastForDataSets
	NVAR VaryContrastForDataSets
	if((VaryContrastForDataSets + SameContrastForDataSets)!=1)
		VaryContrastForDataSets=0
		SameContrastForDataSets =1
	endif
	NVAR DisplayInputDataControls
	NVAR DisplayModelControls
	if((DisplayInputDataControls+DisplayModelControls)!=1)
		DisplayInputDataControls = 1
		DisplayModelControls = 0
	endif

	NVAR SizeDistDisplayNumDist
	NVAR SizeDistDisplayVolDist
	if(SizeDistDisplayNumDist + SizeDistDisplayVolDist <1)
		SizeDistDisplayVolDist=1
	endif

	for(i=1;i<=10;i+=1)	
		NVAR UseUserErrors=$("UseUserErrors_set"+num2str(i))
		NVAR UseSQRTErrors=$("UseSQRTErrors_set"+num2str(i))
		NVAR UsePercentErrors=$("UsePercentErrors_set"+num2str(i))
		if(UseUserErrors+UseSQRTErrors+UsePercentErrors!=0)
			UseUserErrors=1
			UseSQRTErrors=0
			UsePercentErrors=0
		endif
	endfor

	for(i=1;i<=6;i+=1)	
		SVAR FormFactor=$("FormFactor_pop"+num2str(i))
		if(strlen(FormFactor)<3)
			FormFactor="Spheroid"
		endif
	endfor
	for(i=1;i<=6;i+=1)	//RdistAuto;RdistrSemiAuto;RdistMan
		NVAR RdistAuto=$("RdistAuto_pop"+num2str(i))
		NVAR RdistrSemiAuto=$("RdistrSemiAuto_pop"+num2str(i))
		NVAR RdistMan=$("RdistMan_pop"+num2str(i))
		if(RdistMan+RdistrSemiAuto+RdistAuto !=1)
			RdistAuto=1
			RdistMan=0
			RdistrSemiAuto=0
			//RdistManMin;RdistManMax;RdistLog;RdistNumPnts;RdistNeglectTails
			NVAR RdistManMin=$("RdistManMin_pop"+num2str(i))
			NVAR RdistManMax=$("RdistManMax_pop"+num2str(i))
			NVAR RdistLog=$("RdistLog_pop"+num2str(i))
			NVAR RdistNumPnts=$("RdistNumPnts_pop"+num2str(i))
			NVAR RdistNeglectTails=$("RdistNeglectTails_pop"+num2str(i))
			RdistNeglectTails=0.01
			RdistNumPnts=50
			RdistLog=1
			RdistManMin=10
			RdistManMax=10000
			SVAR PopSizeDistShape=$("PopSizeDistShape_pop"+num2str(i))
			PopSizeDistShape="LogNormal"
			SVAR FormFactor=$("FormFactor_pop"+num2str(i))
			FormFactor="Spheroid"
			NVAR Par1=$("FormFactor_Param1_pop"+num2str(i))
			NVAR Par2=$("FormFactor_Param2_pop"+num2str(i))
			NVAR Par3=$("FormFactor_Param3_pop"+num2str(i))
			NVAR Par4=$("FormFactor_Param4_pop"+num2str(i))
			NVAR Par5=$("FormFactor_Param5_pop"+num2str(i))
			Par1=1
			Par2=1
			Par3=1
			Par4=1
			Par5=1
		endif
	endfor

		for(j=1;j<=6;j+=1)	//"Contrast;Contrast_set1;Contrast_set2;Contrast_set3;Contrast_set4;Contrast_set5;Contrast_set6;Contrast_set7;Contrast_set8;Contrast_set9;Contrast_set10;"
			ListOfVariables = "Contrast;Contrast_set1;Contrast_set2;Contrast_set3;Contrast_set4;Contrast_set5;Contrast_set6;Contrast_set7;Contrast_set8;Contrast_set9;Contrast_set10;"
			For(i=0;i<itemsInList(ListOfVariables);i+=1)
				NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"_pop"+num2str(j))
				if(testVar==0)
					testVar=100
				endif
			endfor
		endfor



	for(i=1;i<=10;i+=1)	
		NVAR DataScalingFactor=$("DataScalingFactor_set"+num2str(i))
		NVAR ErrorScalingFactor=$("ErrorScalingFactor_set"+num2str(i))
		if(DataScalingFactor==0)
			DataScalingFactor=1
		endif
		if(ErrorScalingFactor==0)
			ErrorScalingFactor=1
		endif
	endfor

//	//Model parameters, these need to have _popX attached at the end of name
//	ListOfPopulationVariables+="Volume;VolumeFit;VolumeMin;VolumeMax;"	
//	ListOfPopulationVariables+="LNMinSize;LNMinSizeFit;LNMinSizeMin;LNMinSizeMax;LNMeanSize;LNMeanSizeFit;LNMeanSizeMin;LNMeanSizeMax;LNSdeviation;LNSdeviationFit;LNSdeviationMin;LNSdeviationMax;"	
//	ListOfPopulationVariables+="GMeanSize;GMeanSizeFit;GMeanSizeMin;GMeanSizeMax;GWidth;GWidthFit;GWidthMin;GWidthMax;LSWLocation;LSWLocationFit;LSWLocationMin;LSWLocationMax;"	

	for(j=1;j<=6;j+=1)	//RdistAuto;RdistrSemiAuto;RdistMan
		ListOfVariables = "Volume"
		For(i=0;i<itemsInList(ListOfVariables);i+=1)
			NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"_pop"+num2str(j))
			if(testVar==0)
				testVar=0.05
			endif
		endfor
		ListOfVariables = "LNSdeviation"
		For(i=0;i<itemsInList(ListOfVariables);i+=1)
			NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"_pop"+num2str(j))
			if(testVar==0)
				testVar=0.5
			endif
		endfor
		ListOfVariables = "GWidth"
		For(i=0;i<itemsInList(ListOfVariables);i+=1)
			NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"_pop"+num2str(j))
			if(testVar==0)
				testVar=50*j
			endif
		endfor
		
		ListOfVariables = "LNMeanSize;GMeanSize;LSWLocation"
		For(i=0;i<itemsInList(ListOfVariables);i+=1)
			NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"_pop"+num2str(j))
			if(testVar==0)
				testVar=j*150
			endif
		endfor


	endfor
end

Function IR2L_DataTabCheckboxProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF
	
	ControlInfo/W=LSQF2_MainPanel DataTabs
	variable WhichDataSet= V_Value+1

	if (stringMatch(ctrlName,"BackgroundFit_set"))
//		IR2L_Data_TabPanelControl("",V_Value)
	endif
	if (stringMatch(ctrlName,"UseTheData_set"))
		if(checked)
			IR2L_AppendDataIntoGraph(WhichDataSet)
		else
			IR2L_RemoveDataFromGraph(WhichDataSet)
		endif
		IR2L_AppendOrRemoveLocalPopInts()
		IR2L_FormatInputGraph()
		//IR2L_FormatLegend()		//part of IR2L_AppendOrRemoveLocalPopInts
		IR2L_RecalculateIfSelected()
	endif
	if (stringMatch(ctrlName,"MultipleInputData"))
		if(checked)
			TabControl DataTabs,win=LSQF2_MainPanel,tabLabel(0)="1.",tabLabel(1)="2."
			TabControl DataTabs,win=LSQF2_MainPanel,tabLabel(2)="3.",tabLabel(3)="4."
			TabControl DataTabs,win=LSQF2_MainPanel,tabLabel(4)="5.",tabLabel(5)="6."
			TabControl DataTabs,win=LSQF2_MainPanel,tabLabel(6)="7.",tabLabel(7)="8."
			TabControl DataTabs,win=LSQF2_MainPanel,tabLabel(8)="9.",tabLabel(9)="10.", value=0
			CheckBox SameContrastForDataSets,win=LSQF2_MainPanel,disable=0
			IR2L_InputPanelButtonProc("Regraph")
			IR2L_Model_TabPanelControl("",V_Value)	
		else
			TabControl DataTabs,win=LSQF2_MainPanel,tabLabel(0)="Input Data",tabLabel(1)=""
			TabControl DataTabs,win=LSQF2_MainPanel,tabLabel(2)="",tabLabel(3)=""
			TabControl DataTabs,win=LSQF2_MainPanel,tabLabel(4)="",tabLabel(5)=""
			TabControl DataTabs,win=LSQF2_MainPanel,tabLabel(6)="",tabLabel(7)=""
			TabControl DataTabs,win=LSQF2_MainPanel,tabLabel(8)="",tabLabel(9)="", value=0
			CheckBox SameContrastForDataSets,win=LSQF2_MainPanel,disable=1
			IR2L_InputPanelButtonProc("Regraph")
			IR2L_Model_TabPanelControl("",V_Value)	
		endif
		IR2L_RecalculateIfSelected()
	endif


	if (stringMatch(ctrlName,"SameContrastForDataSets"))
		NVAR SameContrastForDataSets
		NVAR VaryContrastForDataSets
		VaryContrastForDataSets = !SameContrastForDataSets
		IR2L_Model_TabPanelControl("",V_Value)	
		IR2L_RecalculateIfSelected()
	endif
	NVAR DisplayInputDataControls
	NVAR DisplayModelControls
	if (stringMatch(ctrlName,"DisplayInputDataControls"))
		DisplayModelControls=!DisplayInputDataControls
		TabControl DataTabs, win=LSQF2_MainPanel, disable=!DisplayInputDataControls
		ControlInfo/W=LSQF2_MainPanel DistTabs
		IR2L_Model_TabPanelControl("",V_Value)
		TabControl DistTabs, win=LSQF2_MainPanel, disable=!DisplayModelControls
	endif
	if (stringMatch(ctrlName,"DisplayModelControls"))
		DisplayInputDataControls=!DisplayModelControls
		TabControl DataTabs, win=LSQF2_MainPanel, disable=!DisplayInputDataControls
		ControlInfo/W=LSQF2_MainPanel DistTabs
		IR2L_Model_TabPanelControl("",V_Value)
		TabControl DistTabs, win=LSQF2_MainPanel, disable=!DisplayModelControls
	endif

	NVAR UseUserErrors_set = $("UseUserErrors_set"+num2str(WhichDataSet))
	NVAR UseSQRTErrors_set = $("UseSQRTErrors_set"+num2str(WhichDataSet))
	NVAR UsePercentErrors_set = $("UsePercentErrors_set"+num2str(WhichDataSet))
	if (stringMatch(ctrlName,"UseUserErrors_set"))
		if(UseUserErrors_set)
			UseSQRTErrors_set=0
			UsePercentErrors_set=0
		else
			UseSQRTErrors_set=1
			UsePercentErrors_set=0
		endif	
		IR2L_RecalculateErrors(WhichDataSet)
	endif
	if (stringMatch(ctrlName,"UseSQRTErrors_set"))
		if(UseSQRTErrors_set)
			UseUserErrors_set=0
			UsePercentErrors_set=0
		else
			UseUserErrors_set=0
			UsePercentErrors_set=1
		endif	
		IR2L_RecalculateErrors(WhichDataSet)
	endif
	if (stringMatch(ctrlName,"UsePercentErrors_set"))
		if(UsePercentErrors_set)
			UseUserErrors_set=0
			UseSQRTErrors_set=0
		else
			UseUserErrors_set=0
			UseSQRTErrors_set=1
		endif	
		IR2L_RecalculateErrors(WhichDataSet)
	endif
	if (stringMatch(ctrlName,"RecalculateAutomatically"))
		IR2L_RecalculateIfSelected()
	endif
	if (stringMatch(ctrlName,"UseNumberDistributions"))
		NVAR SizeDistDisplayNumDist = root:Packages:IR2L_NLSQF:SizeDistDisplayNumDist
		NVAR SizeDistDisplayVolDist = root:Packages:IR2L_NLSQF:SizeDistDisplayVolDist
		if(Checked)
			SizeDistDisplayNumDist =1
		//	SizeDistDisplayVolDist = 0
		else
		//	SizeDistDisplayNumDist =0
			SizeDistDisplayVolDist = 1
		endif
		IR2L_RecalculateIfSelected()
	endif

	NVAR UseGeneticOptimization=root:Packages:IR2L_NLSQF:UseGeneticOptimization
	NVAR UseLSQF=root:Packages:IR2L_NLSQF:UseLSQF
	if (stringMatch(ctrlName,"UseGeneticOptimization"))
		UseLSQF=!UseGeneticOptimization
	endif
	if (stringMatch(ctrlName,"UseLSQF"))
		UseGeneticOptimization=!UseLSQF
	endif


	ControlInfo/W=LSQF2_MainPanel DataTabs
	IR2L_Data_TabPanelControl("",V_Value)
	DoWindow/F LSQF2_MainPanel
	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_SaveResultsInNotebook()


	IR2L_SvNbk_CreateNbk()		//create notebook

	IR2L_SvNbk_SampleInf()		//store data information
	
	IR2L_SvNbk_Graphs(1)			//insert graphs
	
	IR2L_SvNbk_ModelInf()		//store model information
	
	//summary?
	IR2L_SvNbk_PgBreak()		//page break at the end
end 


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR2L_SvNbk_ModelInf()
	//this function saves information about the samples
	//and header
	
	SVAR/Z nbl=root:Packages:IR2L_NLSQF:NotebookName
	if(!SVAR_Exists(nbl))
		abort
	endif
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF
	variable k, i
	string ListOfPopulationVariables
	k=0
	For(i=1;i<=6;i+=1)
		NVAR UseThePop = $("root:Packages:IR2L_NLSQF:UseThePop_pop"+num2str(i))
		k+=UseThePop
	endfor
	
//	//write header here... separator and some heading to divide the record.... 
	IR2L_AppendAnyText("   ",2)	//separate
	IR2L_AppendAnyText("Model data for "+num2str(k)+" population(s) used to obtain above results"+"\r",1)	
	//IR2L_AppendAnyText("     ",0)	
	
	//And now the populations
	For(i=1;i<=6;i+=1)	
		NVAR UseThePop = $("root:Packages:IR2L_NLSQF:UseThePop_pop"+num2str(i))	
		if(UseThePop)
				IR2L_AppendAnyText("Summary results for "+num2str(i)+" population",1)	
				ListOfPopulationVariables="Volume;Mean;Mode;Median;FWHM;"	
				for(k=0;k<itemsInList(ListOfPopulationVariables);k+=1)	
					NVAR testVar = $(StringFromList(k,ListOfPopulationVariables)+"_pop"+num2str(i))
					IR2L_AppendAnyText(StringFromList(k,ListOfPopulationVariables)+"_pop"+num2str(i)+"\t=\t"+num2str(testVar),0)
				endfor
			
				IR2L_AppendAnyText("  ",0)	
				IR2L_AppendAnyText("Distribution type for "+num2str(i)+" population",1)	
				SVAR PopSizeDistShape = $("root:Packages:IR2L_NLSQF:PopSizeDistShape_pop"+num2str(i))		
				if(cmpstr(PopSizeDistShape, "Gauss") )
					IR2L_AppendAnyText("DistributionShape_pop"+num2str(i)+"\t=\t Gauss",0)
					NVAR GMeanSize =  $("root:Packages:IR2L_NLSQF:GMeanSize_pop"+num2str(i))	
					IR2L_AppendAnyText("GaussMean_pop"+num2str(i)+"\t=\t"+num2str(GMeanSize),0)
					NVAR GWidth =  $("root:Packages:IR2L_NLSQF:GWidth_pop"+num2str(i))	
					IR2L_AppendAnyText("GaussWidth_pop"+num2str(i)+"\t=\t"+num2str(GWidth),0)
				elseif(cmpstr(PopSizeDistShape, "LogNormal" ))
					IR2L_AppendAnyText("DistributionShape_pop"+num2str(i)+"\t=\tLogNormal",0)
					NVAR LNMinSize =  $("root:Packages:IR2L_NLSQF:LNMinSize_pop"+num2str(i))	
					IR2L_AppendAnyText("LogNormalMin_pop"+num2str(i)+"\t=\t"+num2str(LNMinSize),0)
					NVAR LNMeanSize =  $("root:Packages:IR2L_NLSQF:LNMeanSize_pop"+num2str(i))	
					IR2L_AppendAnyText("LogNormalMean_pop"+num2str(i)+"\t=\t"+num2str(LNMeanSize),0)
					NVAR LNSdeviation =  $("root:Packages:IR2L_NLSQF:LNSdeviation_pop"+num2str(i))	
					IR2L_AppendAnyText("LogNormalSdeviation_pop"+num2str(i)+"\t=\t"+num2str(LNSdeviation),0)
				else //LSW
					IR2L_AppendAnyText("DistributionShape_pop"+num2str(i)+"\t=\tLSW",0)
					NVAR LSWLocation =  $("root:Packages:IR2L_NLSQF:LSWLocation_pop"+num2str(i))	
					IR2L_AppendAnyText("LSWLocation_pop"+num2str(i)+"\t=\t"+num2str(LSWLocation),0)				
				endif
					
				NVAR VaryContrast=root:Packages:IR2L_NLSQF:SameContrastForDataSets
				NVAR UseMultipleData=root:Packages:IR2L_NLSQF:MultipleInputData
				IR2L_AppendAnyText("  ",0)	
				if(VaryContrast && UseMultipleData)
					IR2L_AppendAnyText("Contrasts for different data sets "+num2str(i)+" population",1)	
					ListOfPopulationVariables="Contrast_set1;Contrast_set2;Contrast_set3;Contrast_set4;Contrast_set5;Contrast_set6;Contrast_set7;Contrast_set8;Contrast_set9;Contrast_set10;"
					for(k=0;k<itemsInList(ListOfPopulationVariables);k+=1)	
						NVAR testVar = $(StringFromList(k,ListOfPopulationVariables)+"_pop"+num2str(i))
						IR2L_AppendAnyText(StringFromList(k,ListOfPopulationVariables)+"_pop"+num2str(i)+"="+num2str(testVar),0)
					endfor
				else		//same contrast for all sets... 
					IR2L_AppendAnyText("Contrasts for data set "+num2str(i)+" population",1)	
					NVAR Contrast = $("root:Packages:IR2L_NLSQF:Contrast_pop"+num2str(i))
					IR2L_AppendAnyText("Contrast_pop"+num2str(i)+"="+num2str(Contrast),0)				
				endif
//				// For factor parameters.... messy... 
				SVAR FormFac=$("root:Packages:IR2L_NLSQF:FormFactor_pop"+num2str(i))
				IR2L_AppendAnyText("  ",0)	
				IR2L_AppendAnyText("Form factor description and parameters  ",1)	
				IR2L_AppendAnyText("FormFactor_pop"+num2str(i)+"\t=\t"+FormFac,0)
				if(stringmatch(FormFac, "*User*"))
					SVAR U1FormFac=$("root:Packages:IR2L_NLSQF:FFUserFFformula_pop"+num2str(i))
					IR2L_AppendAnyText("FFUserFFformula_pop"+num2str(i)+"\t=\t"+U1FormFac,0)
					SVAR U2FormFac=$("root:Packages:IR2L_NLSQF:FFUserVolumeFormula_pop"+num2str(i))
					IR2L_AppendAnyText("FFUserVolumeFormula_pop"+num2str(i)+"\t=\t"+U2FormFac,0)
				endif
//		IR1T_IdentifyFFParamName(FormFactorName,ParameterOrder)
					NVAR FFParam1= $("root:Packages:IR2L_NLSQF:FormFactor_Param1_pop"+num2str(i))
					if(strlen(IR1T_IdentifyFFParamName(FormFac,1))>0)
						IR2L_AppendAnyText(IR1T_IdentifyFFParamName(FormFac,1)+"\t"+"FormFactor_Param1_pop"+num2str(i)+"\t=\t"+num2str(FFParam1),0)
					endif
					NVAR FFParam2= $("root:Packages:IR2L_NLSQF:FormFactor_Param2_pop"+num2str(i))
					if(strlen(IR1T_IdentifyFFParamName(FormFac,2))>0)
						IR2L_AppendAnyText(IR1T_IdentifyFFParamName(FormFac,2)+"\t"+"FormFactor_Param2_pop"+num2str(i)+"\t=\t"+num2str(FFParam2),0)
					endif
					NVAR FFParam3= $("root:Packages:IR2L_NLSQF:FormFactor_Param3_pop"+num2str(i))
					if(strlen(IR1T_IdentifyFFParamName(FormFac,3))>0)
						IR2L_AppendAnyText(IR1T_IdentifyFFParamName(FormFac,3)+"\t"+"FormFactor_Param3_pop"+num2str(i)+"\t=\t"+num2str(FFParam3),0)
					endif
					NVAR FFParam4= $("root:Packages:IR2L_NLSQF:FormFactor_Param4_pop"+num2str(i))
					if(strlen(IR1T_IdentifyFFParamName(FormFac,4))>0)
						IR2L_AppendAnyText(IR1T_IdentifyFFParamName(FormFac,4)+"\t"+"FormFactor_Param4_pop"+num2str(i)+"\t=\t"+num2str(FFParam4),0)
					endif
					NVAR FFParam5= $("root:Packages:IR2L_NLSQF:FormFactor_Param5_pop"+num2str(i))
					if(strlen(IR1T_IdentifyFFParamName(FormFac,5))>0)
						IR2L_AppendAnyText(IR1T_IdentifyFFParamName(FormFac,5)+"\t"+"FormFactor_Param5_pop"+num2str(i)+"="+num2str(FFParam5),0)
					endif
//
//
//			IR1T_IdentifySFParamName(SFactorName,ParameterOrder)
////				NVAR UseInterference = $("root:Packages:IR2L_NLSQF:UseInterference_pop"+num2str(i))			
				SVAR StrFac=$("root:Packages:IR2L_NLSQF:StructureFactor_pop"+num2str(i))
				IR2L_AppendAnyText("  ",0)	
				IR2L_AppendAnyText("Structure factor description and parameters  ",1)	
				IR2L_AppendAnyText("StructureFactor_pop"+num2str(i)+"\t=\t"+StrFac,0)
				if(!stringmatch(StrFac, "*Dilute system*"))
					NVAR SFParam1= $("root:Packages:IR2L_NLSQF:StructureParam1_pop"+num2str(i))
					if(strlen(IR1T_IdentifySFParamName(StrFac,1))>0)
						IR2L_AppendAnyText(IR1T_IdentifySFParamName(StrFac,1)+"\t"+"StructureParam1_pop"+num2str(i)+"\t=\t"+num2str(SFParam1),0)
					endif
					NVAR SFParam2= $("root:Packages:IR2L_NLSQF:StructureParam2_pop"+num2str(i))
					if(strlen(IR1T_IdentifySFParamName(StrFac,2))>0)
						IR2L_AppendAnyText(IR1T_IdentifySFParamName(StrFac,2)+"\t"+"StructureParam2_pop"+num2str(i)+"\t=\t"+num2str(SFParam2),0)
					endif
					NVAR SFParam3= $("root:Packages:IR2L_NLSQF:StructureParam3_pop"+num2str(i))
					if(strlen(IR1T_IdentifySFParamName(StrFac,3))>0)
						IR2L_AppendAnyText(IR1T_IdentifySFParamName(StrFac,3)+"\t"+"StructureParam3_pop"+num2str(i)+"\t=\t"+num2str(SFParam3),0)
					endif
					NVAR SFParam4= $("root:Packages:IR2L_NLSQF:StructureParam4_pop"+num2str(i))
					if(strlen(IR1T_IdentifySFParamName(StrFac,4))>0)
						IR2L_AppendAnyText(IR1T_IdentifySFParamName(StrFac,4)+"\t"+"StructureParam4_pop"+num2str(i)+"\t=\t"+num2str(SFParam4),0)
					endif
					NVAR SFParam5= $("root:Packages:IR2L_NLSQF:StructureParam5_pop"+num2str(i))
					if(strlen(IR1T_IdentifySFParamName(StrFac,5))>0)
						IR2L_AppendAnyText(IR1T_IdentifySFParamName(StrFac,5)+"\t"+"StructureParam5_pop"+num2str(i)+"\t=\t"+num2str(SFParam5),0)
					endif
					NVAR SFParam6= $("root:Packages:IR2L_NLSQF:StructureParam6_pop"+num2str(i))
					if(strlen(IR1T_IdentifySFParamName(StrFac,6))>0)
						IR2L_AppendAnyText(IR1T_IdentifySFParamName(StrFac,6)+"\t"+"StructureParam6_pop"+num2str(i)+"\t=\t"+num2str(SFParam6),0)
					endif
				endif	
				IR2L_AppendAnyText("  ",0)	
				IR2L_AppendAnyText("  ",0)	
		endif
	endfor

end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_SvNbk_Graphs(color)
	variable color
	Silent 1
	SVAR nbl=root:Packages:IR2L_NLSQF:NotebookName
	DoWIndow LSQF_MainGraph
	if(V_Flag)
		Notebook $nbl text="\r"
		Notebook $nbl selection={endOfFile, endOfFile}
		Notebook $nbl scaling={80,80}, frame=1, picture={LSQF_MainGraph,1,color}
		Notebook $nbl text="\r"
		Notebook $nbl text=IN2G_WindowTitle("LSQF_MainGraph")
		Notebook $nbl text="\r"
	endif
	DoWIndow LSQF_MainGraph
	if(V_Flag)
		Notebook $nbl text="\r"
		Notebook $nbl selection={endOfFile, endOfFile}
		Notebook $nbl scaling={80,80}, frame=1, picture={GraphSizeDistributions,1,color}
		Notebook $nbl text="\r"
		Notebook $nbl text=IN2G_WindowTitle("GraphSizeDistributions")
		Notebook $nbl text="\r"
	endif
End

end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_SvNbk_PgBreak()
	
	Silent 1
	SVAR nbl=root:Packages:IR2L_NLSQF:NotebookName
	Notebook $nbl selection={endOfFile, endOfFile}
	Notebook $nbl SpecialChar={1,0,""}
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_SvNbk_SampleInf()
	//this function saves information about the samples
	//and header
	
	SVAR/Z nbl=root:Packages:IR2L_NLSQF:NotebookName
	if(!SVAR_Exists(nbl))
		abort
	endif
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF
	
	//write header here... separator and some heading to divide the record.... 
	IR2L_AppendAnyText("************************************************\r",2)	
	IR2L_AppendAnyText("Results saved on " + date() +"   "+time()+"\r",1)	
	IR2L_AppendAnyText("     ",0)	

	
	NVAR MultipleInputData=root:Packages:IR2L_NLSQF:MultipleInputData
	variable i
	if(MultipleInputData)
		//multiple data selected, need to return to multiple places....
		IR2L_AppendAnyText("Multiple data sets used, listing of data sets and associated parameters\r",2)	
		for(i=1;i<11;i+=1)
			NVAR UseSet=$("root:Packages:IR2L_NLSQF:UseTheData_set"+num2str(i))
			if(UseSet)
				IR2L_SvNbk_DataSetSave(i)
				IR2L_AppendAnyText("",0)	
			endif
		endfor
	else
		IR2L_AppendAnyText("Single data set used:",2)	
		//only one data set to be returned... the first one
		IR2L_SvNbk_DataSetSave(1)
	endif
	
	setDataFolder OldDf
	
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************



Function IR2L_SvNbk_DataSetSave(WdtSt)
	variable WdtSt

	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF

	string ListOfVariables, ListOfDataVariables, ListOfPopulationVariables
	string ListOfStrings, ListOfDataStrings, ListOfPopulationsStrings
	string ListOfParameters, ListOfParametersStr
	ListOfParametersStr = ""
	ListOfParameters=""
	variable i, j 
	
	j = WdtSt
	
	//First deal with data itself... Name, background etc. 
	ListOfDataStrings ="FolderName;IntensityDataName;QvecDataName;ErrorDataName;UserDataSetName;"
	for(i=0;i<itemsInList(ListOfDataStrings);i+=1)	
		SVAR testStr = $(StringFromList(i,ListOfDataStrings)+"_set"+num2str(j))
		if(stringmatch(StringFromList(i,ListOfDataStrings),"FolderName"))
			IR2L_AppendAnyText(StringFromList(i,ListOfDataStrings)+"_set"+num2str(j)+"\t=\t"+testStr,2)
		else
			IR2L_AppendAnyText(StringFromList(i,ListOfDataStrings)+"_set"+num2str(j)+"\t=\t"+testStr,0)
		endif
	endfor
		
	ListOfDataVariables="DataScalingFactor;ErrorScalingFactor;Qmin;Qmax;Background;"
	for(i=0;i<itemsInList(ListOfDataVariables);i+=1)	
		NVAR testVar = $(StringFromList(i,ListOfDataVariables)+"_set"+num2str(j))
		IR2L_AppendAnyText(StringFromList(i,ListOfDataVariables)+"_set"+num2str(j)+"\t=\t"+num2str(testVar),0)
	endfor	
	
	//Slit smeared data?
	NVAR SlitSmeared = $("root:Packages:IR2L_NLSQF:SlitSmeared_set"+num2str(j))
	if(SlitSmeared)
		NVAR SlitLength = $("root:Packages:IR2L_NLSQF:SlitLength_set"+num2str(j))
		IR2L_AppendAnyText("Slit smeared data used...",1)
		IR2L_AppendAnyText("SlitLength"+"_set"+num2str(j)+"\t=\t"+num2str(SlitLength),0)
	else
	//	ListOfParameters+="SlitLength"+"_set"+num2str(j)+"=0;"
	endif


end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_AppendAnyText(TextToBeInserted, level)		//this function checks for existance of notebook
	string TextToBeInserted						//and appends text to the end of the notebook
	variable level 								//formating level... 0 for base, 1 and higher define my own
	Silent 1
	TextToBeInserted=TextToBeInserted+"\r"
    SVAR/Z nbl=root:Packages:IR2L_NLSQF:NotebookName
	if(SVAR_exists(nbl))
		if (strsearch(WinList("*",";","WIN:16"),nbl,0)!=-1)				//Logs data in Logbook
			Notebook $nbl selection={endOfFile, endOfFile}
			Switch(level)
				case 0:
					Notebook $nbl font="Arial", fsize=10, fStyle=-1, text=TextToBeInserted
					break
				case 1:
					Notebook $nbl font="Arial", fsize=10, fStyle=4, text=TextToBeInserted
					break
				case 2:
					Notebook $nbl font="Arial", fsize=12, fStyle=3, text=TextToBeInserted
					break
				
				default:
					Notebook $nbl text=TextToBeInserted
			endswitch
		endif
	endif
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_SvNbk_CreateNbk()
	
	SVAR/Z nbl=root:Packages:IR2L_NLSQF:NotebookName
	if(!SVAR_Exists(nbl))
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:IR2L_NLSQF 
		String/G root:Packages:IR2L_NLSQF:NotebookName=""
		SVAR nbl=root:Packages:IR2L_NLSQF:NotebookName
		nbL="ModelingII_Results"
	endif
	
	string nbLL=nbl
	
	Silent 1
	if (strsearch(WinList("*",";","WIN:16"),nbL,0)!=-1) 		///Logbook exists
		DoWindow/F $nbl
	else
		NewNotebook/K=3/N=$nbl/F=1/V=1/W=(235.5,44.75,817.5,592.25) as nbl +": Modeling II Output"
		Notebook $nbl defaultTab=144, statusWidth=238, pageMargins={72,72,72,72}
		Notebook $nbl showRuler=1, rulerUnits=1, updating={1, 60}
		Notebook $nbl newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={2.5*72, 3.5*72 + 8192, 5*72 + 3*8192}, rulerDefaults={"Arial",10,0,(0,0,0)}
		Notebook $nbl ruler=Normal
		Notebook $nbl  justification=1, rulerDefaults={"Arial",14,1,(0,0,0)}
		Notebook $nbl text="This is output of results from Modeling II of Irena package.\r"
		Notebook $nbl text="\r"
		Notebook $nbl ruler=Normal
		IR1_InsertDateAndTime(nbl)
	endif

end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

