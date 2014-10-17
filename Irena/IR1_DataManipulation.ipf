#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.21

//version 2.1 modified to use new control procedures using subpanels... Hope this will work as advertised.
//2.11 added log-x rebinning as option. 
//2.20 add Data Manipualtion II - manipualting multiple data sets. For now only avergaging multiple data sets but can be made more extensive
//2.21  modified Data manipulation II to be able to subtract one wave from many data sets. 


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

///////		***************        Data manipulation I - two data sets   ******************

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1D_DataManipulation()

	IN2G_CheckScreenSize("height",670)
	//IR1_KillGraphsAndPanels()
	DoWindow IR1D_DataManipulationPanel
	if(V_Flag)
		DoWindow/K IR1D_DataManipulationPanel
	endif
	DoWindow IR1D_DataManipulationGraph
	if(V_Flag)
		DoWindow/K IR1D_DataManipulationGraph
	endif

	IR1D_InitDataManipulation()
	
	Execute("IR1D_DataManipulationPanel()")
	
	
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


Proc IR1D_DataManipulationPanel()
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(2.25,43.25,400,700) as "Data Manipulation"
	DoWIndow/C IR1D_DataManipulationPanel
	SetDrawLayer UserBack
	SetDrawEnv fname= "Times New Roman",fsize= 22,fstyle= 3,textrgb= (0,0,52224)
	DrawText 57,28,"Data manipulation input panel"
	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
	DrawLine 16,158,339,158
	SetDrawEnv fsize= 16,fstyle= 1
	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
	DrawLine 16,430,339,430
	SetDrawEnv fsize= 16,fstyle= 1
	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
	DrawLine 16,508,339,508
	SetDrawEnv fsize= 16,fstyle= 1
	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
	DrawLine 16,540,339,540
//	SetDrawEnv fsize= 16,fstyle= 1
//	DrawText 8,190,"Second set data input"
	DrawText 28,342,"Modify data 1                                          Modify Data 2"
	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
	DrawLine 16,300,339,300

	//Experimental data input
	NewPanel /W=(0,25,398,157) /HOST=# /N=Top
	ModifyPanel cbRGB=(52428,52428,52428), frameStyle=1
	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup=""
	string EUserLookup=""
	IR2C_AddDataControls("SASDataModificationTop","IR1D_DataManipulationPanel#Top","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","AllCurrentlyAllowedTypes",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,1)
	SetDrawLayer UserBack
	SetDrawEnv fname= "Times New Roman",fsize= 22,fstyle= 3,textrgb= (0,0,52224)
	SetDrawEnv fsize= 12,fstyle= 1
	DrawText 10,25,"First data set"
	Checkbox UseIndra2Data, pos={100,10}
	Checkbox UseResults, pos={250,10}
	Checkbox UseModelData, pos={330,10}
	checkbox UseQRSData, pos={180,10}
	popupMenu SelectDataFolder, pos={10,30} 
	popupMenu QvecDataName, pos={10,52}
	popupMenu IntensityDataName, pos={10,78}
	popupMenu ErrorDataName, pos={10,103}
	setVariable Qmin, pos={10,30}
	setVariable Qmax, pos={10,52}
	setVariable QNumPoints, pos={10,78}
	Checkbox QlogScale, pos={10,103}
	
	
	SetActiveSubwindow ##
	
	NewPanel /W=(0,160,398,295) /HOST=# /N=Bot
	ModifyPanel cbRGB=(52428,52428,52428), frameStyle=1
	IR2C_AddDataControls("SASDataModificationBot","IR1D_DataManipulationPanel#Bot","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","AllCurrentlyAllowedTypes",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,1)
	SetDrawLayer UserBack
	SetDrawEnv fname= "Times New Roman",fsize= 22,fstyle= 3,textrgb= (0,0,52224)
	SetDrawEnv fsize= 12,fstyle= 1
	DrawText 10,25,"Second data set"
	Checkbox UseIndra2Data, pos={100,10}
	Checkbox UseResults, pos={250,10}
	Checkbox UseModelData, pos={330,10}
	checkbox UseQRSData, pos={180,10}
	popupMenu SelectDataFolder, pos={10,30} 
	popupMenu QvecDataName, pos={10,52}
	popupMenu IntensityDataName, pos={10,78}
	popupMenu ErrorDataName, pos={10,103}
	setVariable Qmin, pos={10,30}
	setVariable Qmax, pos={10,52}
	setVariable QNumPoints, pos={10,78}
	Checkbox QlogScale, pos={10,103}

	SetActiveSubwindow ##

	Button CopyGraphData,pos={5,310},size={120,17},font="Times New Roman",fSize=10,proc=IR1D_InputPanelButtonProc,title="Add data and Graph", help={"Create graph"}
	Button ResetModify,pos={140,310},size={100,17},font="Times New Roman",fSize=10,proc=IR1D_InputPanelButtonProc,title="Reset Modify", help={"Reset the modify data parameters and return all removed points"}
	Button AutoScale,pos={250,310},size={100,17},font="Times New Roman",fSize=10,proc=IR1D_InputPanelButtonProc,title="AutoScale", help={"Autoscales. Set cursors on data overlap and the data 2 will be scaled to Data 1 using integral intensity"}

	SetVariable Data1_IntMultiplier, pos={5,344}, size={150,15},title="Multiply Int by", proc=IR1D_setvarProc
	SetVariable Data1_IntMultiplier, value= root:Packages:SASDataModification:Data1_IntMultiplier,help={"Intensity scaling factor for intensity 1"}
	SetVariable Data1_Background, pos={5,360}, size={150,15},title="Sbtrct bckg   ", proc=IR1D_setvarProc
	SetVariable Data1_Background, value= root:Packages:SASDataModification:Data1_Background,help={"Subtract bacground from intensity"}
	SetVariable Data1_Qshift, pos={5,376}, size={150,15},title="Q shift           ", proc=IR1D_setvarProc
	SetVariable Data1_Qshift, value= root:Packages:SASDataModification:Data1_Qshift,help={"Offset in Q by"}
	SetVariable Data1_ErrMulitplier, pos={5,392}, size={150,15},title="Error multiplier", proc=IR1D_setvarProc
	SetVariable Data1_ErrMulitplier, value= root:Packages:SASDataModification:Data1_ErrMultiplier,help={"Multiply intesnity by"}

	SetVariable Data2_IntMultiplier, pos={185,344}, size={150,15},title="Multiply Int by", proc=IR1D_setvarProc
	SetVariable Data2_IntMultiplier, value= root:Packages:SASDataModification:Data2_IntMultiplier,help={"Intensity scaling factor for intensity 1"}
	SetVariable Data2_Background, pos={185,360}, size={150,15},title="Sbtrct bckg   ", proc=IR1D_setvarProc
	SetVariable Data2_Background, value= root:Packages:SASDataModification:Data2_Background,help={"Subtract bacground from intensity"}
	SetVariable Data2_Qshift, pos={185,376}, size={150,15},title="Q shift           ", proc=IR1D_setvarProc
	SetVariable Data2_Qshift, value= root:Packages:SASDataModification:Data2_Qshift,help={"Offset in Q by"}
	SetVariable Data2_ErrMulitplier, pos={185,392}, size={150,15},title="Error multiplier", proc=IR1D_setvarProc
	SetVariable Data2_ErrMulitplier, value= root:Packages:SASDataModification:Data2_ErrMultiplier,help={"Multiply intesnity by"}


	Button RemoveSmallQData,pos={5,410},size={100,16},font="Times New Roman",fSize=10,proc=IR1D_InputPanelButtonProc,title="Rem Q<Csr(A)", help={"Remove data with Q smaller than Cursor A position"}
	Button RemoveLargeQData,pos={255,410},size={100,16},font="Times New Roman",fSize=10,proc=IR1D_InputPanelButtonProc,title="Rem Q>Csr(B)", help={"Remove data with Q larger than Cursor B position"}
	Button RemoveOneQData,pos={125,410},size={100,16},font="Times New Roman",fSize=10,proc=IR1D_InputPanelButtonProc,title="Rem Csr(A)", help={"Remove one data point with Cursor A"}

	CheckBox CombineData,pos={10,435},size={141,14},proc=IR1D_InputPanelCheckboxProc2,title="Combine data"
	CheckBox CombineData,variable= root:packages:SASDataModification:CombineData, help={"Check, if you want to combine data together"}
	CheckBox SubtractData,pos={10,450},size={141,14},proc=IR1D_InputPanelCheckboxProc2,title="Data1 - Data2"
	CheckBox SubtractData,variable= root:packages:SASDataModification:SubtractData, help={"Check, if you want to subtract second set of data from the first one (Int1 - Int2)"}
	CheckBox SubtractData2,pos={10,465},size={141,14},proc=IR1D_InputPanelCheckboxProc2,title="Data2 - Data1"
	CheckBox SubtractData2,variable= root:packages:SASDataModification:SubtractData2, help={"Check, if you want to subtract second set of data from the first one (Int1 - Int2) @Q2"}
	CheckBox SumData,pos={130,435},size={141,14},proc=IR1D_InputPanelCheckboxProc2,title="Data1 + Data2"
	CheckBox SumData,variable= root:packages:SASDataModification:SumData, help={"Check, if you want to sum intensities together Int1 + Int2 @ Q1 (+Q2 where Q1 does not exist)"}
	CheckBox RescaleToNewQscale,pos={130,450},size={141,14},proc=IR1D_InputPanelCheckboxProc2,title="Data1 using Q2"
	CheckBox RescaleToNewQscale,variable= root:packages:SASDataModification:RescaleToNewQscale, help={"Check, if you want to convert Int1 to Q scale of Q2"}
	CheckBox PassData1Through,pos={130,465},size={141,14},proc=IR1D_InputPanelCheckboxProc2,title="Data 1"
	CheckBox PassData1Through,variable= root:packages:SASDataModification:PassData1Through, help={"Check, if you want to pass Int1 through to use smoothnig only"}
	CheckBox PassData2Through,pos={250,465},size={141,14},proc=IR1D_InputPanelCheckboxProc2,title="Data 2"
	CheckBox PassData2Through,variable= root:packages:SASDataModification:PassData2Through, help={"Check, if you want to pass Int2 through to use smoothnig only"}
	CheckBox DivideData1byData2,pos={250,435},size={141,14},proc=IR1D_InputPanelCheckboxProc2,title="Data1 / Data2"
	CheckBox DivideData1byData2,variable= root:packages:SASDataModification:DivideData1byData2, help={"Check, if you want to divide intensities Int1 / Int2 @ Qvec1 (+Qvec2 where Qvec1 does not exist)"}
	CheckBox SubtractData2AndDivideByThem,pos={250,450},size={141,14},proc=IR1D_InputPanelCheckboxProc2,title="(Data1-Data2)/Data2"
	CheckBox SubtractData2AndDivideByThem,variable= root:packages:SASDataModification:SubtractData2AndDivideByThem, help={"Check, if you want to subtract intensities and divide (Int1 - Int2)/Int2 @ Qvec1 (+Qvec2 where Qvec1 does not exist)"}
	CheckBox ReducePointNumber,pos={10,480},size={141,14},proc=IR1D_InputPanelCheckboxProc2,title="Reduce No pnts by"
	CheckBox ReducePointNumber,variable= root:packages:SASDataModification:ReducePointNumber, help={"Check, if you want to reduce number of points by number selected next"}
	SetVariable ReducePointNumberBy, pos={125,480}, size={50,20},title=" ", proc=IR1D_setvarProc
	SetVariable ReducePointNumberBy, value= root:Packages:SASDataModification:ReducePointNumberBy,help={"Select number by which to reduce No of points"}

	CheckBox LogReducePointNumber,pos={200,480},size={141,14},proc=IR1D_InputPanelCheckboxProc2,title="Log Reduce to"
	CheckBox LogReducePointNumber,variable= root:packages:SASDataModification:LogReducePointNumber, help={"Check, to log-reduce points. Higher Q points are avearaged."}
	SetVariable LogReducePointNumberTo, pos={300,480}, size={90,20},title=" ", proc=IR1D_setvarProc
	SetVariable LogReducePointNumberTo, value= root:Packages:SASDataModification:ReducePointNumberTo,help={"Select number of resulting points"}
	Slider LogBinningPar pos={100,495},size={270,10},vert=0, side=0
	Slider LogBinningPar proc=IR1D_SliderProc,variable=root:packages:SASDataModification:LogReduceParam
	Slider LogBinningPar value=0.001,limits={0.5,10,0}, ticks=0
	Slider LogBinningPar help={"Slide to change log-binning parameter"}		

	CheckBox SmoothInLogScale,pos={10,511},size={141,14},proc=IR1D_InputPanelCheckboxProc2,title="Smooth (log)"
	CheckBox SmoothInLogScale,variable= root:packages:SASDataModification:SmoothInLogScale, help={"Check, if you want to smooth data in log scale. Select window correctly"}
	CheckBox SmoothInLinScale,pos={100,511},size={141,14},proc=IR1D_InputPanelCheckboxProc2,title="Smooth (lin)"
	CheckBox SmoothInLinScale,variable= root:packages:SASDataModification:SmoothInLinScale, help={"Check, if you want to smooth data in linera scale. Select window correctly."}
	SetVariable SmoothWindow, pos={200,511}, size={170,20},title="Smoothing window?"
	SetVariable SmoothWindow value= root:packages:SASDataModification:SmoothWindow,help={"Window for smoothing"}

	CheckBox SmoothSpline,pos={10,524},size={141,14},proc=IR1D_InputPanelCheckboxProc2,title="Smooth Spline"
	CheckBox SmoothSpline,variable= root:packages:SASDataModification:SmoothSplines, help={"Check, if you want to smooth data using splines."}
	Slider SmoothSplineSlider pos={100,527},size={270,10},vert=0, side=0
	Slider SmoothSplineSlider proc=IR1D_SliderProc,variable=root:packages:SASDataModification:SmoothSplinesParam
	Slider SmoothSplineSlider value=0.001,limits={1e-6,22,0}, ticks=0
	Slider SmoothSplineSlider help={"Slide to change smoothing parameter"}		

	PopupMenu SelectFolderNewData,pos={1,545},size={250,21},proc=IR1D_PanelPopupControl,title="Pick new data folder", help={"Select folder with data"}
	PopupMenu SelectFolderNewData,mode=1,popvalue="---",value= #"\"---;\"+IR1_GenStringOfFolders(0, 0,0,0)"

	SetVariable NewDataFolderName, pos={5,570}, size={390,20},title="New data folder:", proc=IR1D_setvarProc
	SetVariable NewDataFolderName value= root:packages:SASDataModification:NewDataFolderName,help={"Folder for the new data. Will be created, if does not exist. Use popup above to preselect."}
	SetVariable NewQwaveName, pos={5,590}, size={320,20},title="New Q wave nm", proc=IR1D_setvarProc
	SetVariable NewQwaveName, value= root:packages:SASDataModification:NewQWaveName,help={"Input name for the new Q wave"}
	SetVariable NewIntensityWaveName, pos={5,610}, size={320,20},title="New Intensity nm", proc=IR1D_setvarProc
	SetVariable NewIntensityWaveName, value= root:packages:SASDataModification:NewIntensityWaveName,help={"Input name for the new intensity wave"}
	SetVariable NewErrorWaveName, pos={5,630}, size={320,20},title="New Error name", proc=IR1D_setvarProc
	SetVariable NewErrorWaveName, value= root:packages:SASDataModification:NewErrorWaveName,help={"Input name for the new Error wave"}


	Button ConvertData, pos={330,600},size={60,25},font="Times New Roman",fSize=10,proc=IR1D_InputPanelButtonProc,title="GO", help={"Do the selected conversion"}
	Button SaveData,pos={330,630},size={60,25},font="Times New Roman",fSize=10,proc=IR1D_InputPanelButtonProc,title="SAVE", help={"Save the result of conversion"}

end
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//*********************************************************************************************
Function IR1D_SliderProc(ctrlName,sliderValue,event) : SliderControl
	String ctrlName
	Variable sliderValue
	Variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved

//	if(event %& 0x1)	// bit 0, value set
//
//	endif

	if(cmpstr(ctrlName,"SmoothSplineSlider")==0 && event ==4)	// bit 0, value set
		//here we go and do what should be done...
	//	IR1B_SliderSmoothSMRData(sliderValue)
		Wave/Z ResultsInt=root:packages:SASDataModification:ResultsInt
		NVAR SmoothSplines=root:packages:SASDataModification:SmoothSplines
		if(WaveExists(ResultsInt)&& SmoothSplines)
			IR1D_InputPanelButtonProc("ConvertData")
		endif
	endif
	if(cmpstr(ctrlName,"LogBinningPar")==0 && event ==4)	// bit 0, value set
		//here we go and do what should be done...
	//	IR1B_SliderSmoothSMRData(sliderValue)
		Wave/Z ResultsInt=root:packages:SASDataModification:ResultsInt
		NVAR LogReducePointNumber=root:packages:SASDataModification:LogReducePointNumber
		if(WaveExists(ResultsInt)&& LogReducePointNumber)
			IR1D_InputPanelButtonProc("ConvertData")
		endif
	endif

	return 0
End
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR1D_setvarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	SVAR NewIntensityWaveName=root:packages:SASDataModification:NewIntensityWaveName
	SVAR NewQWaveName=root:packages:SASDataModification:NewQWaveName
	SVAR NewErrorWaveName=root:packages:SASDataModification:NewErrorWaveName

	if(cmpstr(ctrlName,"NewIntensityWaveName")==0)
		SVAR CheckString=root:packages:SASDataModification:NewIntensityWaveName
		if(strlen(CheckString)>0)
			CheckString =  CleanupName(CheckString,1)
			if (CheckName(CheckString,1)!=0)
				CheckString=UniqueName(CheckString,1,0)
			endif 
			if ((strlen(NewQWaveName)==0)&&(strlen(NewErrorWaveName)==0))
				NewQWaveName = "q"+CheckString[1,inf]
				NewErrorWaveName = "s"+CheckString[1,inf]
			endif	
		endif
	endif
	if(cmpstr(ctrlName,"NewQwaveName")==0)
		SVAR CheckString=root:packages:SASDataModification:NewQwaveName
		if(strlen(CheckString)>0)
			CheckString =  CleanupName(CheckString,1)
			if (CheckName(CheckString,1)!=0)
				CheckString=UniqueName(CheckString,1,0)
			endif 
//			if ((strlen(NewIntensityWaveName)==0)&&(strlen(NewErrorWaveName)==0))	//commented byrequest of Dale Schefer, 4 12 2005
				NewIntensityWaveName = "r"+CheckString[1,inf]
				NewErrorWaveName = "s"+CheckString[1,inf]
//			endif	
		endif
	endif
	if(cmpstr(ctrlName,"NewErrorWaveName")==0)
		SVAR CheckString=root:packages:SASDataModification:NewErrorWaveName
		if(strlen(CheckString)>0)
			CheckString =  CleanupName(CheckString,1)
			if (CheckName(CheckString,1)!=0)
				CheckString=UniqueName(CheckString,1,0)
			endif 
			if ((strlen(NewIntensityWaveName)==0)&&(strlen(NewQWaveName)==0))
				NewIntensityWaveName = "r"+CheckString[1,inf]
				NewQWaveName = "q"+CheckString[1,inf]
			endif	
		endif
	endif
	if(cmpstr(ctrlName,"Data1_IntMultiplier")==0)
		IR1D_RecalculateData()
	endif 
	if(cmpstr(ctrlName,"Data1_Background")==0)
		IR1D_RecalculateData()
	endif 
	if(cmpstr(ctrlName,"Data1_Qshift")==0)
		IR1D_RecalculateData()
	endif 
	if(cmpstr(ctrlName,"Data1_ErrMulitplier")==0)
		IR1D_RecalculateData()
	endif 
	 
	if(cmpstr(ctrlName,"Data2_IntMultiplier")==0)
		IR1D_RecalculateData()
	endif 
	if(cmpstr(ctrlName,"Data2_Background")==0)
		IR1D_RecalculateData()
	endif 
	if(cmpstr(ctrlName,"Data2_Qshift")==0)
		IR1D_RecalculateData()
	endif 
	if(cmpstr(ctrlName,"Data2_ErrMulitplier")==0)
		IR1D_RecalculateData()
	endif 
End

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR1D_InputPanelButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	if(cmpstr(ctrlName,"CopyGraphData")==0)
		IR1D_ResetModifyData()
		IR1D_CopyDataAndGraph()
		IR1D_PresetOutputStrings()
	endif
	if(cmpstr(ctrlName,"ResetModify")==0)
		IR1D_ResetModifyData()
		IR1D_RecalculateData()
	endif
	if(cmpstr(ctrlName,"RemoveSmallQData")==0)
		IR1D_RemoveSmallQpnt()
		IR1D_RecalculateData()
	endif
	if(cmpstr(ctrlName,"RemoveOneQData")==0)
		IR1D_RemoveListQpnt()
		IR1D_RecalculateData()
	endif
	if(cmpstr(ctrlName,"RemoveLargeQData")==0)
		IR1D_RemoveLargeQpnt()
		IR1D_RecalculateData()
	endif
	if(cmpstr(ctrlName,"AutoScale")==0)
		IR1D_AutoScale()
		IR1D_RecalculateData()
	endif
	if(cmpstr(ctrlName,"ConvertData")==0)
		IR1D_ConvertData()
		IR1D_SmoothData()
		IR1D_AppendResultToGraph()
	endif
	if(cmpstr(ctrlName,"SaveData")==0)
		IR1D_ConvertData()
		IR1D_SmoothData()
		IR1D_AppendResultToGraph()
		IR1D_SaveData()
		IR1D_RecordResults()
	endif
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR1D_RecordResults()

	string OldDF=GetDataFolder(1)
	setdataFolder root:Packages:SASDataModification

	SVAR DataFolderName2 =root:Packages:SASDataModification:DataFolderName2
	SVAR IntensityWaveName2=root:Packages:SASDataModification:IntensityWaveName2
	SVAR QWavename2=root:Packages:SASDataModification:QWavename2
	SVAR ErrorWaveName2 =root:Packages:SASDataModification:ErrorWaveName2
	SVAR DataFolderName1=root:Packages:SASDataModification:DataFolderName1
	SVAR IntensityWaveName1=root:Packages:SASDataModification:IntensityWaveName1
	SVAR QWavename1=root:Packages:SASDataModification:QWavename1
	SVAR ErrorWaveName1=root:Packages:SASDataModification:ErrorWaveName1
	SVAR Data1RemoveListofPnts=root:Packages:SASDataModification:Data1RemoveListofPnts
	SVAR Data2RemoveListofPnts=root:Packages:SASDataModification:Data2RemoveListofPnts
	SVAR nbl=root:Packages:SAS_Modeling:NotebookName

	IR1_CreateLoggbook()		//this creates the logbook

	IR1L_AppendAnyText("     ")
	IR1L_AppendAnyText("***********************************************")
	IR1L_AppendAnyText("***********************************************")
	IR1L_AppendAnyText("Data modification record ")
	IR1_InsertDateAndTime(nbl)
	IR1L_AppendAnyText("Data set names \t")
	IR1L_AppendAnyText("\tData set 1 :")
	IR1L_AppendAnyText("\t\tFolder \t"+ DataFolderName1)
	IR1L_AppendAnyText("\t\tIntensity/Q/errror wave names \t"+ IntensityWaveName1+"\t"+QWavename1+"\t"+ErrorWaveName1)
	IR1L_AppendAnyText("\tData set 2 :")
	IR1L_AppendAnyText("\t\tFolder \t"+ DataFolderName2)
	IR1L_AppendAnyText("\t\tIntensity/Q/errror wave names \t"+ IntensityWaveName2+"\t"+QWavename2+"\t"+ErrorWaveName2)
	IR1L_AppendAnyText(" ")
	IR1L_AppendAnyText("Points removed ")
	NVAR Data1RemoveSmallQ=root:Packages:SASDataModification:Data1RemoveSmallQ
	NVAR Data1RemoveLargeQ=root:Packages:SASDataModification:Data1RemoveLargeQ
	if(strlen(Data1RemoveListofPnts)>0)
		IR1L_AppendAnyText("Data set 1 removed individual points :  " + Data1RemoveListofPnts)
	endif
	if(numtype(Data1RemoveSmallQ)==0 && Data1RemoveSmallQ>0)
		IR1L_AppendAnyText("Data set 1 removed "+num2str(Data1RemoveSmallQ)+" points at small Q")
	endif
	if(numtype(Data1RemoveLargeQ)==0 && Data1RemoveLargeQ>0)
		IR1L_AppendAnyText("Data set 1 removed "+num2str(Data1RemoveLargeQ)+" points at high Q")
	endif
	NVAR Data2RemoveSmallQ=root:Packages:SASDataModification:Data2RemoveSmallQ
	NVAR Data2RemoveLargeQ=root:Packages:SASDataModification:Data2RemoveLargeQ
	if(strlen(Data2RemoveListofPnts)>0)
		IR1L_AppendAnyText("Data set 2 removed individual points :  " + Data2RemoveListofPnts)
	endif
	if(numtype(Data2RemoveSmallQ)==0 && Data2RemoveSmallQ>0)
		IR1L_AppendAnyText("Data set 2 removed "+num2str(Data2RemoveSmallQ)+" points at small Q")
	endif
	if(numtype(Data2RemoveLargeQ)==0 && Data2RemoveLargeQ>0)
		IR1L_AppendAnyText("Data set 2 removed "+num2str(Data2RemoveLargeQ)+" points at high Q")
	endif

	NVAR Data1_IntMultiplier=root:Packages:SASDataModification:Data1_IntMultiplier
	NVAR Data1_ErrMultiplier=root:Packages:SASDataModification:Data1_ErrMultiplier
	NVAR Data1_Qshift=root:Packages:SASDataModification:Data1_Qshift
	NVAR Data1_Background=root:Packages:SASDataModification:Data1_Background

	IR1L_AppendAnyText("     ")
	if(Data1_IntMultiplier!=1 || Data1_Background!=0 || Data1_Qshift!=0 || Data1_ErrMultiplier!=1)
		IR1L_AppendAnyText("Data set 1 corrections ")
		IR1L_AppendAnyText("Intensity multiplied by  "+num2str(Data1_IntMultiplier))
		IR1L_AppendAnyText("Intensity background subtracted  "+num2str(Data1_Background))
		IR1L_AppendAnyText("Q shifted by  "+num2str(Data1_Qshift))
		IR1L_AppendAnyText("Error multiplied by  "+num2str(Data1_ErrMultiplier))
	else
		IR1L_AppendAnyText("No numerical corrections applied to Data set 1")
	endif

	NVAR Data2_IntMultiplier=root:Packages:SASDataModification:Data2_IntMultiplier
	NVAR Data2_ErrMultiplier=root:Packages:SASDataModification:Data2_ErrMultiplier
	NVAR Data2_Qshift=root:Packages:SASDataModification:Data2_Qshift
	NVAR Data2_Background=root:Packages:SASDataModification:Data2_Background

	IR1L_AppendAnyText("     ")
	if(Data2_IntMultiplier!=1 || Data2_Background!=0 || Data2_Qshift!=0 || Data2_ErrMultiplier!=1)
		IR1L_AppendAnyText("Data set 2 corrections ")
		IR1L_AppendAnyText("Intensity multiplied by  "+num2str(Data2_IntMultiplier))
		IR1L_AppendAnyText("Intensity background subtracted  "+num2str(Data2_Background))
		IR1L_AppendAnyText("Q shifted by  "+num2str(Data2_Qshift))
		IR1L_AppendAnyText("Error multiplied by  "+num2str(Data2_ErrMultiplier))
	else
		IR1L_AppendAnyText("No numerical corrections applied to Data set 2")
	endif

	NVAR CombineData=root:Packages:SASDataModification:CombineData
	NVAR SubtractData=root:Packages:SASDataModification:SubtractData
	NVAR SumData=root:Packages:SASDataModification:SumData
	NVAR RescaleToNewQscale=root:Packages:SASDataModification:RescaleToNewQscale
	NVAR ReducePointNumber=root:Packages:SASDataModification:ReducePointNumber
	NVAR ReducePointNumberBy=root:Packages:SASDataModification:ReducePointNumberBy
	NVAR PassData1Through=root:Packages:SASDataModification:PassData1Through
	NVAR PassData2Through=root:Packages:SASDataModification:PassData2Through
	NVAR SubtractData2=root:Packages:SASDataModification:SubtractData2
	NVAR DivideData1byData2=root:Packages:SASDataModification:DivideData1byData2
	NVAR SubtractData2AndDivideByThem=root:Packages:SASDataModification:SubtractData2AndDivideByThem

	IR1L_AppendAnyText("     ")
	if(CombineData)
		IR1L_AppendAnyText("Data combined together")
	elseif(SubtractData)
		IR1L_AppendAnyText("Data subtracted ... Data 1 - Data 2")
	elseif(SumData)
		IR1L_AppendAnyText("Data summed ... Data 1 + Data 2")
	elseif(RescaleToNewQscale)
		IR1L_AppendAnyText("Data 1 rescaled to 1 values from Data set 2")
	elseif(ReducePointNumber)
		IR1L_AppendAnyText("Reduced number of points of Data 1 by "+num2str(ReducePointNumberBy)+",  data 2 not used")
	elseif(PassData1Through)
		IR1L_AppendAnyText("Data 1 passed through, data 2 not used")
	elseif(PassData2Through)
		IR1L_AppendAnyText("Data 2 passed through, data 1 not used")
	elseif(SubtractData2)
		IR1L_AppendAnyText("Data subtracted ... Data 2 - Data 1")
	elseif(DivideData1byData2)
		IR1L_AppendAnyText("Data divided ... Data 1 / Data 2")
	elseif(SubtractData2AndDivideByThem)
		IR1L_AppendAnyText("Data 2 subtracted from Data and then divided by Data 2 ... (Data 1 - Data 2)/Data 2")
	endif
	NVAR SmoothInLogScale=root:Packages:SASDataModification:SmoothInLogScale
	NVAR SmoothInLinScale=root:Packages:SASDataModification:SmoothInLinScale
	NVAR SmoothWindow=root:Packages:SASDataModification:SmoothWindow
	NVAR SmoothSplines=root:Packages:SASDataModification:SmoothSplines
	NVAR SmoothSplinesParam=root:Packages:SASDataModification:SmoothSplinesParam

	if(SmoothInLogScale)
		IR1L_AppendAnyText("Data smoothed in log scale, smoothing window = "+num2str(SmoothWindow))
	endif	
	if(SmoothInLinScale)
		IR1L_AppendAnyText("Data smoothed in lin scale, smoothing window = "+num2str(SmoothWindow))
	endif	
	if(SmoothSplines)
		IR1L_AppendAnyText("Data smoothed using spline smoothing, smoothing parameter = "+num2str(SmoothSplinesParam))
	endif	

	SVAR NewDataFolderName=root:Packages:SASDataModification:NewDataFolderName
	SVAR NewIntensityWaveName=root:Packages:SASDataModification:NewIntensityWaveName
	SVAR NewQWavename=root:Packages:SASDataModification:NewQWavename
	SVAR NewErrorWaveName=root:Packages:SASDataModification:NewErrorWaveName

	IR1L_AppendAnyText("  ")
	IR1L_AppendAnyText("\t\tData saved in \t\t"+NewDataFolderName)
	IR1L_AppendAnyText("\t\tInt/Q/err wave names \t\t"+NewIntensityWaveName+"\t"+NewQWavename+"\t"+NewErrorWaveName)
	

	IR1L_AppendAnyText("***********************************************")

	setdataFolder oldDf
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function  IR1D_SaveData()

	string OldDf
	OldDf = GetDataFolder(1)
	SVAR NewDataFolderName=root:Packages:SASDataModification:NewDataFolderName
	SVAR NewIntensityWaveName=root:Packages:SASDataModification:NewIntensityWaveName
	SVAR NewQWavename=root:Packages:SASDataModification:NewQWavename
	SVAR NewErrorWaveName=root:Packages:SASDataModification:NewErrorWaveName
	//check for name errors
	if(strlen(NewIntensityWaveName)>30)
		NewIntensityWaveName=NewIntensityWaveName[0,30]
	endif
	if(strlen(NewQWavename)>30)
		NewQWavename=NewQWavename[0,30]
	endif
	if(strlen(NewErrorWaveName)>30)
		NewErrorWaveName=NewErrorWaveName[0,30]
	endif

	NewIntensityWaveName=cleanupName(NewIntensityWaveName,1)
	NewQWavename=cleanupName(NewQWavename,1)
	NewErrorWaveName=cleanupName(NewErrorWaveName,1)
	
	Wave/Z ResultsInt = root:packages:SASDataModification:ResultsInt
	Wave/Z ResultsQ = root:packages:SASDataModification:ResultsQ
	Wave/Z ResultsE = root:packages:SASDataModification:ResultsE

	if ((strlen(NewDataFolderName)<=1) || (strlen(NewIntensityWaveName)<=0)|| (strlen(NewQWaveName)<=0))
		Abort "Input output waves names"
	endif
	variable i
	string DataFldrNameStr

	if (WaveExists(ResultsE) && (strlen(NewErrorWaveName)>0))
		if(WaveExists(ResultsInt)&&WaveExists(ResultsQ))
			if ((numpnts(ResultsInt)!=numpnts(ResultsQ)) || (numpnts(ResultsInt)!=numpnts(ResultsE)))
				DoAlert 1, "Intensity, Q and Error waves DO NOT have same number of points. Do you want really to continue?"
				if (V_Flag==2)
					abort
				endif
			endif
		endif
	else
		if(WaveExists(ResultsInt)&&WaveExists(ResultsQ))
			if (numpnts(ResultsInt)!=numpnts(ResultsQ))
				DoAlert 1, "Intensity and Q waves DO NOT have same number of points. Do you want really to continue?"
				if (V_Flag==2)
					abort
				endif
			endif
		endif
	endif


	if(WaveExists(ResultsInt)&&WaveExists(ResultsQ))
		if (cmpstr(NewDataFolderName[strlen(NewDataFolderName)-1],":")!=0)
			NewDataFolderName+=":"
		endif
		setDataFolder root:
		For(i=0;i<ItemsInList(NewDataFolderName,":");i+=1)
			if (cmpstr(StringFromList(i, NewDataFolderName , ":"),"root")!=0)
				DataFldrNameStr = StringFromList(i, NewDataFolderName , ":")
				if(cmpstr(DataFldrNameStr[0],"'")==0)
					DataFldrNameStr = DataFldrNameStr[1,inf]
				endif
				if(cmpstr(DataFldrNameStr[strlen(DataFldrNameStr)-1],"'")==0)
					DataFldrNameStr = DataFldrNameStr[0,strlen(DataFldrNameStr)-2]
				endif
				NewDataFolder/O/S $(DataFldrNameStr)
			endif
		endfor	
	endif
	if(WaveExists(ResultsInt)&&WaveExists(ResultsQ))
		Wave/Z testOutputInt=$NewIntensityWaveName
		Wave/Z testOutputQ=$NewQWaveName
		if (WaveExists(testOutputInt) || WaveExists(testOutputQ))
			DoAlert 1, "Intensity and/or Q data with this name already exist, overwrite?"
			if (V_Flag!=1)
				abort 
			endif
		endif 
		Duplicate/O ResultsInt, $NewIntensityWaveName
		Duplicate/O ResultsQ, $NewQWaveName
		if (WaveExists(ResultsE) && (strlen(NewErrorWaveName)>0))
			Wave/Z testOutputE=$NewErrorWaveName
			if (WaveExists(testOutputE))
				DoAlert 1, "Error data with this name already exist, overwrite?"
				if (V_Flag!=1)
					abort 
				endif
			endif 
			Duplicate/O ResultsE, $NewErrorWaveName
		
		endif
	endif
	setDataFolder OldDf
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR1D_AppendResultToGraph()

	RemoveFromGraph/W=IR1D_DataManipulationGraph/Z ResultsInt
	Legend/N=text0/K/W=IR1D_DataManipulationGraph
	
	
	Wave/Z ResultsInt = root:packages:SASDataModification:ResultsInt
	Wave/Z ResultsQ = root:packages:SASDataModification:ResultsQ
	Wave/Z ResultsE = root:packages:SASDataModification:ResultsE
	
	if(WaveExists(ResultsInt)&&WaveExists(ResultsQ))
		AppendToGraph/W=IR1D_DataManipulationGraph ResultsInt vs ResultsQ
		ModifyGraph/W=IR1D_DataManipulationGraph lsize(ResultsInt)=2,rgb(ResultsInt)=(0,0,0)
	endif
	if (WaveExists(ResultsE))
		ErrorBars/W=IR1D_DataManipulationGraph ResultsInt Y,wave=(ResultsE,ResultsE)
	endif
	TextBox/W=IR1D_DataManipulationGraph/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	
	Legend/C/N=text0/A=LB/W=IR1D_DataManipulationGraph "\\s(Intensity1) Data1\r\\s(Intensity2) Data2\r\\s(ResultsInt) Result"
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1D_ConvertData()

	string OldDf
	OldDf = GetDataFOlder(1)
	setDataFolder root:packages:SASDataModification
	
	DoWindow IR1D_DataManipulationGraph
	if(V_Flag)
		RemoveFromGraph/W=IR1D_DataManipulationGraph /Z ResultsInt
	endif
	NVAR CombineData = root:packages:SASDataModification:CombineData
	NVAR SubtractData = root:packages:SASDataModification:SubtractData
	NVAR SumData = root:packages:SASDataModification:SumData
	NVAR RescaleToNewQscale = root:packages:SASDataModification:RescaleToNewQscale
	NVAR SmoothInLogScale = root:packages:SASDataModification:SmoothInLogScale
	NVAR SmoothInLinScale = root:packages:SASDataModification:SmoothInLinScale
	NVAR SubtractData2 = root:packages:SASDataModification:SubtractData2
	NVAR PassData1Through = root:packages:SASDataModification:PassData1Through
	NVAR PassData2Through = root:packages:SASDataModification:PassData2Through
	NVAR DivideData1byData2 = root:packages:SASDataModification:DivideData1byData2
	NVAR SubtractData2AndDivideByThem = root:packages:SASDataModification:SubtractData2AndDivideByThem
	NVAR ReducePointNumber =root:packages:SASDataModification:ReducePointNumber
	NVAR ReducePointNumberBy = root:packages:SASDataModification:ReducePointNumberBy
	NVAR LogReducePointNumber =root:packages:SASDataModification:LogReducePointNumber
	NVAR ReducePointNumberTo = root:packages:SASDataModification:ReducePointNumberTo

	Wave/Z Intensity1=root:Packages:SASDataModification:Intensity1
	Wave/Z Qvector1=root:Packages:SASDataModification:Qvector1
	Wave/Z Error1=root:Packages:SASDataModification:Error1
	Wave/Z Intensity2=root:Packages:SASDataModification:Intensity2
	Wave/Z Qvector2=root:Packages:SASDataModification:Qvector2
	Wave/Z Error2=root:Packages:SASDataModification:Error2

	if (WaveExists(Intensity1))
		Duplicate/O Intensity1, TempInt1	
	endif
	if (WaveExists(Intensity2))
		Duplicate/O Intensity2, TempInt2	
	endif
	if (WaveExists(Qvector1))
		Duplicate/O Qvector1, TempQ1	
	endif
	if (WaveExists(Qvector2))
		Duplicate/O Qvector2, TempQ2
	endif
	if (WaveExists(Error1))
		Duplicate/O Error1, TempE1	
	endif
	if (WaveExists(Error2))
		Duplicate/O Error2, TempE2	
	endif
			variable Length1, Length2
	
	if (ReducePointNumber)
		If (WaveExists(TempInt1)&&WaveExists(TempQ1)&&WaveExists(TempE1) &&(ReducePointNumberBy>0)&&(numpnts(TempInt1)/ReducePointNumberBy>5))
			IN2G_RemoveNaNsFrom3Waves(TempInt1,TempQ1,TempE1)
			Duplicate/O TempInt1, ResultsInt
			Duplicate/O TempQ1, ResultsQ
			Duplicate/O TempE1, ResultsE
			Redimension/N=(floor(numpnts(ResultsInt)/ReducePointNumberBy)) ResultsInt, ResultsQ, ResultsE
			ResultsInt =TempInt1 [floor(p*ReducePointNumberBy)]
			ResultsQ  = TempQ1[floor(p*ReducePointNumberBy)]
			ResultsE  = TempE1[floor(p*ReducePointNumberBy)]
			//error calc OK		
		elseif(WaveExists(TempInt1)&&WaveExists(TempQ1)&&(ReducePointNumberBy>0)&&(numpnts(TempInt1)/ReducePointNumberBy>5))
			IN2G_RemoveNaNsFrom2Waves(TempInt1,TempQ1)
			Duplicate/O TempInt1, ResultsInt
			Duplicate/O TempQ1, ResultsQ
			Redimension/N=(floor(numpnts(ResultsInt)/ReducePointNumberBy)) ResultsInt, ResultsQ
			ResultsInt =TempInt1 [floor(p*ReducePointNumberBy)]
			ResultsQ  = TempQ1[floor(p*ReducePointNumberBy)]
		else
			DoAlert 0, "Incorrect data, you need data 1 set with at least Intensity and Q (errors are optional) and Reduce number by such that at least 5 points are left"
		endif
	elseif (LogReducePointNumber)
		NVAR ReducePointNumberTo=root:packages:SASDataModification:ReducePointNumberTo
		NVAR LogReduceParam=root:packages:SASDataModification:LogReduceParam
		If (WaveExists(TempInt1)&&WaveExists(TempQ1)&&WaveExists(TempE1))
			IN2G_RemoveNaNsFrom3Waves(TempInt1,TempQ1,TempE1)
			Duplicate/O TempInt1, ResultsInt
			Duplicate/O TempQ1, ResultsQ
			Duplicate/O TempE1, ResultsE
			IR1D_rebinData(ResultsInt,ResultsQ,ResultsE,ReducePointNumberTo, LogReduceParam)
		elseif(WaveExists(TempInt1)&&WaveExists(TempQ1))
			IN2G_RemoveNaNsFrom2Waves(TempInt1,TempQ1)
			Duplicate/O TempInt1, ResultsInt
			Duplicate/O TempQ1, ResultsQ
			Duplicate/O TempInt1, ResultsE
			IR1D_rebinData(ResultsInt,ResultsQ,ResultsE,ReducePointNumberTo, LogReduceParam)
			KillWaves ResultsE
		endif
	elseif (CombineData)
		If (WaveExists(TempInt1)&&WaveExists(TempQ1)&&WaveExists(TempE1)&&WaveExists(TempInt2)&&WaveExists(TempQ2)&&WaveExists(TempE2))
			IN2G_RemoveNaNsFrom3Waves(TempInt1,TempQ1,TempE1)
			IN2G_RemoveNaNsFrom3Waves(TempInt2,TempQ2,TempE2)
			Length1=numpnts(TempInt1)
			Length2=numpnts(TempInt2)
			redimension/N=(Length1+Length2) TempInt1,TempQ1,TempE1
			TempInt1[Length1,inf]=TempInt2[p-Length1]
			TempQ1[Length1,inf]=TempQ2[p-Length1]
			TempE1[Length1,inf]=TempE2[p-Length1]
			sort TempQ1, TempInt1, TempQ1,TempE1
			
			Duplicate/O TempInt1, ResultsInt
			Duplicate/O TempQ1, ResultsQ
			Duplicate/O TempE1, ResultsE
			
		elseif(WaveExists(TempInt1)&&WaveExists(TempQ1)&&WaveExists(TempInt2)&&WaveExists(TempQ2))
			IN2G_RemoveNaNsFrom2Waves(TempInt1,TempQ1)
			IN2G_RemoveNaNsFrom2Waves(TempInt2,TempQ2)
			Length1=numpnts(TempInt1)
			Length2=numpnts(TempInt2)
			redimension/N=(Length1+Length2) TempInt1,TempQ1
			TempInt1[Length1,inf]=TempInt2[p-Length1]
			TempQ1[Length1,inf]=TempQ2[p-Length1]
			sort TempQ1, TempInt1, TempQ1
			
			Duplicate/O TempInt1, ResultsInt
			Duplicate/O TempQ1, ResultsQ
		else
			DoAlert 0, "Incorrect data, you need two sets of at least Intensity and Q (errors are optional)"
		endif
	elseif  (SubtractData)
		If (WaveExists(TempInt1)&&WaveExists(TempQ1)&&WaveExists(TempE1)&&WaveExists(TempInt2)&&WaveExists(TempQ2)&&WaveExists(TempE2))
			IN2G_RemoveNaNsFrom3Waves(TempInt1,TempQ1,TempE1)
			IN2G_RemoveNaNsFrom3Waves(TempInt2,TempQ2,TempE2)
			Duplicate/O TempInt1, ResultsInt, TempIntInterp2
			Duplicate/O TempQ1, ResultsQ, TempEInterp2
			Duplicate/O TempE1, ResultsE
			Duplicate/O TempInt2, TempIntLog2
			Duplicate/O TempE2, TempELog2
			TempIntLog2=log(TempInt2)
			TempELog2=log(TempE2)
			TempIntInterp2 = 10^(interp(TempQ1, TempQ2, TempIntLog2))
			TempEInterp2 = 10^(interp(TempQ1, TempQ2, TempELog2))
			if (BinarySearch(ResultsQ, TempQ2[0] )>0)
				TempIntInterp2[0,BinarySearch(ResultsQ, TempQ2[0] )]=NaN
				TempEInterp2[0,BinarySearch(ResultsQ, TempQ2[0] )]=NaN
			endif
			if ((BinarySearch(ResultsQ, TempQ2[numpnts(TempQ2)-1] )!=numpnts(ResultsQ)-1)&&(BinarySearch(ResultsQ, TempQ2[numpnts(TempQ2)-1] )!=-2))
				TempIntInterp2[BinarySearch(ResultsQ, TempQ2[numpnts(TempQ2)])+1,inf]=Nan
				TempEInterp2[BinarySearch(ResultsQ, TempQ2[numpnts(TempQ2)])+1,inf]=Nan
			endif
			ResultsInt = TempInt1 - TempIntInterp2
			ResultsE = sqrt(TempE1^2 + TempEInterp2^2)
			//error calc OK		
			IN2G_ReplaceNegValsByNaNWaves(ResultsInt,ResultsQ,ResultsE)
			IN2G_RemoveNaNsFrom3Waves(ResultsInt,ResultsQ,ResultsE)
			
		elseif(WaveExists(TempInt1)&&WaveExists(TempQ1)&&WaveExists(TempInt2)&&WaveExists(TempQ2))
			IN2G_RemoveNaNsFrom2Waves(TempInt1,TempQ1)
			IN2G_RemoveNaNsFrom2Waves(TempInt2,TempQ2)
			Duplicate/O TempInt1, ResultsInt, TempIntInterp2
			Duplicate/O TempQ1, ResultsQ, ResultsEtemp
			Duplicate/O TempInt2, TempIntLog2
			TempIntLog2=log(TempInt2)
			TempIntInterp2 = 10^(interp(TempQ1, TempQ2, TempIntLog2))
			if (BinarySearch(ResultsQ, TempQ2[0] )>0)
				TempIntInterp2[0,BinarySearch(ResultsQ, TempQ2[0] )]=NaN
			endif
			if ((BinarySearch(ResultsQ, TempQ2[numpnts(TempQ2)-1] )!=numpnts(ResultsQ)-1)&&(BinarySearch(ResultsQ, TempQ2[numpnts(TempQ2)-1] )!=-2))
				TempIntInterp2[BinarySearch(ResultsQ, TempQ2[numpnts(TempQ2)])+1,inf]=NaN
			endif
			ResultsInt = TempInt1 - TempIntInterp2
			IN2G_ReplaceNegValsByNaNWaves(ResultsInt,ResultsQ,ResultsEtemp)
			IN2G_RemoveNaNsFrom3Waves(ResultsInt,ResultsQ,ResultsEtemp)
		else
			DoAlert 0, "Incorrect data, you need two sets of at least Intensity and Q (errors are optional)"
		endif
	elseif  (SubtractData2)
		If (WaveExists(TempInt1)&&WaveExists(TempQ1)&&WaveExists(TempE1)&&WaveExists(TempInt2)&&WaveExists(TempQ2)&&WaveExists(TempE2))
			IN2G_RemoveNaNsFrom3Waves(TempInt1,TempQ1,TempE1)
			IN2G_RemoveNaNsFrom3Waves(TempInt2,TempQ2,TempE2)
			Duplicate/O TempInt1, ResultsInt, TempIntInterp2
			Duplicate/O TempQ1, ResultsQ, TempEInterp2
			Duplicate/O TempE1, ResultsE
			Duplicate/O TempInt2, TempIntLog2
			Duplicate/O TempE2, TempELog2
			TempIntLog2=log(TempInt2)
			TempELog2=log(TempE2)
			TempIntInterp2 = 10^(interp(TempQ1, TempQ2, TempIntLog2))
			TempEInterp2 = 10^(interp(TempQ1, TempQ2, TempELog2))
			if (BinarySearch(ResultsQ, TempQ2[0] )>0)
				TempIntInterp2[0,BinarySearch(ResultsQ, TempQ2[0] )]=0
				TempEInterp2[0,BinarySearch(ResultsQ, TempQ2[0] )]=0
			endif
			if ((BinarySearch(ResultsQ, TempQ2[numpnts(TempQ2)-1] )!=numpnts(ResultsQ)-1)&&(BinarySearch(ResultsQ, TempQ2[numpnts(TempQ2)-1] )!=-2))
				TempIntInterp2[BinarySearch(ResultsQ, TempQ2[numpnts(TempQ2)])+1,inf]=NaN
				TempEInterp2[BinarySearch(ResultsQ, TempQ2[numpnts(TempQ2)])+1,inf]=NaN
			endif
			ResultsInt =  TempIntInterp2 -TempInt1
			ResultsE = sqrt(TempE1^2 + TempEInterp2^2)
			//error calc OK		
			IN2G_ReplaceNegValsByNaNWaves(ResultsInt,ResultsQ,ResultsE)
			IN2G_RemoveNaNsFrom3Waves(ResultsInt,ResultsQ,ResultsE)
			
		elseif(WaveExists(TempInt1)&&WaveExists(TempQ1)&&WaveExists(TempInt2)&&WaveExists(TempQ2))
			IN2G_RemoveNaNsFrom2Waves(TempInt1,TempQ1)
			IN2G_RemoveNaNsFrom2Waves(TempInt2,TempQ2)
			Duplicate/O TempInt1, ResultsInt, TempIntInterp2
			Duplicate/O TempQ1, ResultsQ, ResultsEtemp
			Duplicate/O TempInt2, TempIntLog2
			TempIntLog2=log(TempInt2)
			TempIntInterp2 = 10^(interp(TempQ1, TempQ2, TempIntLog2))
			if (BinarySearch(ResultsQ, TempQ2[0] )>0)
				TempIntInterp2[0,BinarySearch(ResultsQ, TempQ2[0] )]=NaN
			endif
			if ((BinarySearch(ResultsQ, TempQ2[numpnts(TempQ2)-1] )!=numpnts(ResultsQ)-1)&&(BinarySearch(ResultsQ, TempQ2[numpnts(TempQ2)-1] )!=-2))
				TempIntInterp2[BinarySearch(ResultsQ, TempQ2[numpnts(TempQ2)-1])+1,inf]=NaN
			endif
			ResultsInt =  TempIntInterp2 - TempInt1
			IN2G_ReplaceNegValsByNaNWaves(ResultsInt,ResultsQ,ResultsEtemp)
			IN2G_RemoveNaNsFrom3Waves(ResultsInt,ResultsQ,ResultsEtemp)
		else
			DoAlert 0, "Incorrect data, you need two sets of at least Intensity and Q (errors are optional)"
		endif
	elseif  (PassData1Through)
		If (WaveExists(TempInt1)&&WaveExists(TempQ1)&&WaveExists(TempE1))
			IN2G_RemoveNaNsFrom3Waves(TempInt1,TempQ1,TempE1)
			Duplicate/O TempInt1, ResultsInt
			Duplicate/O TempQ1, ResultsQ
			Duplicate/O TempE1, ResultsE
			//error calc OK		
		elseif(WaveExists(TempInt1)&&WaveExists(TempQ1))
			IN2G_RemoveNaNsFrom2Waves(TempInt1,TempQ1)
			Duplicate/O TempInt1, ResultsInt
			Duplicate/O TempQ1, ResultsQ
		else
			DoAlert 0, "Incorrect data, you need two sets of at least Intensity and Q (errors are optional)"
		endif
	elseif  (PassData2Through)
		If (WaveExists(TempInt2)&&WaveExists(TempQ2)&&WaveExists(TempE2))
			IN2G_RemoveNaNsFrom3Waves(TempInt2,TempQ2,TempE2)
			Duplicate/O TempInt2, ResultsInt
			Duplicate/O TempQ2, ResultsQ
			Duplicate/O TempE2, ResultsE
			//error calc OK		
		elseif(WaveExists(TempInt2)&&WaveExists(TempQ2))
			IN2G_RemoveNaNsFrom2Waves(TempInt2,TempQ2)
			Duplicate/O TempInt2, ResultsInt
			Duplicate/O TempQ2, ResultsQ
		else
			DoAlert 0, "Incorrect data, you need two sets of at least Intensity and Q (errors are optional)"
		endif
	elseif  (SumData)
		If (WaveExists(TempInt1)&&WaveExists(TempQ1)&&WaveExists(TempE1)&&WaveExists(TempInt2)&&WaveExists(TempQ2)&&WaveExists(TempE2))
			IN2G_RemoveNaNsFrom3Waves(TempInt1,TempQ1,TempE1)
			IN2G_RemoveNaNsFrom3Waves(TempInt2,TempQ2,TempE2)
			Duplicate/O TempInt1, ResultsInt, TempIntInterp2
			Duplicate/O TempQ1, ResultsQ
			Duplicate/O TempE1, ResultsE, TempEInterp2
			Duplicate/O TempInt2, TempIntLog2
			Duplicate/O TempE2, TempELog2
			TempIntLog2=log(TempInt2)
			TempELog2=log(TempE2)
			TempIntInterp2 = 10^(interp(TempQ1, TempQ2, TempIntLog2))
			TempEInterp2 = 10^(interp(TempQ1, TempQ2, TempELog2))
			if (BinarySearch(ResultsQ, TempQ2[0] )>0)
				TempIntInterp2[0,BinarySearch(ResultsQ, TempQ2[0] )]=Nan
				TempEInterp2[0,BinarySearch(ResultsQ, TempQ2[0] )]=Nan
			endif
			if ((BinarySearch(ResultsQ, TempQ2[numpnts(TempQ2)-1] )!=numpnts(ResultsQ)-1)&&(BinarySearch(ResultsQ, TempQ2[numpnts(TempQ2)-1] )!=-2))
				TempIntInterp2[BinarySearch(ResultsQ, TempQ2[numpnts(TempQ2)])+1,inf]=NaN
				TempEInterp2[BinarySearch(ResultsQ, TempQ2[numpnts(TempQ2)])+1,inf]=NaN
			endif
			ResultsInt = TempInt1+ TempIntInterp2
			ResultsE = sqrt(TempE1^2 + TempEInterp2^2)
			//error calc OK		
			IN2G_ReplaceNegValsByNaNWaves(ResultsInt,ResultsQ,ResultsE)
			IN2G_RemoveNaNsFrom3Waves(ResultsInt,ResultsQ,ResultsE)
			
		elseif(WaveExists(TempInt1)&&WaveExists(TempQ1)&&WaveExists(TempInt2)&&WaveExists(TempQ2))
			IN2G_RemoveNaNsFrom2Waves(TempInt1,TempQ1)
			IN2G_RemoveNaNsFrom2Waves(TempInt2,TempQ2)
			Duplicate/O TempInt1, ResultsInt, TempIntInterp2
			Duplicate/O TempQ1, ResultsQ, ResultsEtemp
			Duplicate/O TempInt2, TempIntLog2
			TempIntLog2=log(TempInt2)
			TempIntInterp2 = 10^(interp(TempQ1, TempQ2, TempIntLog2))
			if (BinarySearch(ResultsQ, TempQ2[0] )>0)
				TempIntInterp2[0,BinarySearch(ResultsQ, TempQ2[0] )]=NaN
			endif
			if ((BinarySearch(ResultsQ, TempQ2[numpnts(TempQ2)-1] )!=numpnts(ResultsQ)-1)&&(BinarySearch(ResultsQ, TempQ2[numpnts(TempQ2)-1] )!=-2))
				TempIntInterp2[BinarySearch(ResultsQ, TempQ2[numpnts(TempQ2)])+1,inf]=Nan
			endif
			ResultsInt = TempInt1+ TempIntInterp2
			IN2G_ReplaceNegValsByNaNWaves(ResultsInt,ResultsQ,ResultsEtemp)
			IN2G_RemoveNaNsFrom3Waves(ResultsInt,ResultsQ,ResultsEtemp)
		else
			DoAlert 0, "Incorrect data, you need two sets of at least Intensity and Q (errors are optional)"
		endif
	elseif  (DivideData1byData2)
		If (WaveExists(TempInt1)&&WaveExists(TempQ1)&&WaveExists(TempE1)&&WaveExists(TempInt2)&&WaveExists(TempQ2)&&WaveExists(TempE2))
			IN2G_RemoveNaNsFrom3Waves(TempInt1,TempQ1,TempE1)
			IN2G_RemoveNaNsFrom3Waves(TempInt2,TempQ2,TempE2)
			Duplicate/O TempInt1, ResultsInt, TempIntInterp2
			Duplicate/O TempQ1, ResultsQ
			Duplicate/O TempE1, ResultsE, TempEInterp2
			Duplicate/O TempInt2, TempIntLog2
			Duplicate/O TempE2, TempELog2
			TempIntLog2=log(TempInt2)
			TempELog2=log(TempE2)
			TempIntInterp2 = 10^(interp(TempQ1, TempQ2, TempIntLog2))
			TempEInterp2 = 10^(interp(TempQ1, TempQ2, TempELog2))
			if (BinarySearch(ResultsQ, TempQ2[0] )>0)
				TempIntInterp2[0,BinarySearch(ResultsQ, TempQ2[0] )]=NaN
				TempEInterp2[0,BinarySearch(ResultsQ, TempQ2[0] )]=NaN
			endif
			if ((BinarySearch(ResultsQ, TempQ2[numpnts(TempQ2)-1] )!=numpnts(ResultsQ)-1)&&(BinarySearch(ResultsQ, TempQ2[numpnts(TempQ2)-1] )!=-2))
				TempIntInterp2[BinarySearch(ResultsQ, TempQ2[numpnts(TempQ2)])+1,inf]=NaN
				TempEInterp2[BinarySearch(ResultsQ, TempQ2[numpnts(TempQ2)])+1,inf]=NaN
			endif
			ResultsInt = TempInt1/ TempIntInterp2
			ResultsE = sqrt((TempInt1^2)*(TempEInterp2^4) + (TempE1^2)*(TempIntInterp2^4) + ((TempInt1^2)+(TempE1^2))*TempIntInterp2^2 *TempEInterp2^2 ) / (TempIntInterp2*(TempIntInterp2^2 -TempEInterp2^2 ))
			//errors OK? I think so...			
			IN2G_ReplaceNegValsByNaNWaves(ResultsInt,ResultsQ,ResultsE)
			IN2G_RemoveNaNsFrom3Waves(ResultsInt,ResultsQ,ResultsE)
			
		elseif(WaveExists(TempInt1)&&WaveExists(TempQ1)&&WaveExists(TempInt2)&&WaveExists(TempQ2))
			IN2G_RemoveNaNsFrom2Waves(TempInt1,TempQ1)
			IN2G_RemoveNaNsFrom2Waves(TempInt2,TempQ2)
			Duplicate/O TempInt1, ResultsInt, TempIntInterp2
			Duplicate/O TempQ1, ResultsQ, ResultsEtemp
			Duplicate/O TempInt2, TempIntLog2
			TempIntLog2=log(TempInt2)
			TempIntInterp2 = 10^(interp(TempQ1, TempQ2, TempIntLog2))
			if (BinarySearch(ResultsQ, TempQ2[0] )>0)
				TempIntInterp2[0,BinarySearch(ResultsQ, TempQ2[0] )]=NaN
			endif
			if ((BinarySearch(ResultsQ, TempQ2[numpnts(TempQ2)-1] )!=numpnts(ResultsQ)-1)&&(BinarySearch(ResultsQ, TempQ2[numpnts(TempQ2)-1] )!=-2))
				TempIntInterp2[BinarySearch(ResultsQ, TempQ2[numpnts(TempQ2)])+1,inf]=NaN
			endif
			ResultsInt = TempInt1 / TempIntInterp2
			IN2G_ReplaceNegValsByNaNWaves(ResultsInt,ResultsQ,ResultsEtemp)
			IN2G_RemoveNaNsFrom3Waves(ResultsInt,ResultsQ,ResultsEtemp)
		else
			DoAlert 0, "Incorrect data, you need two sets of at least Intensity and Q (errors are optional)"
		endif
	elseif  (SubtractData2AndDivideByThem)
		If (WaveExists(TempInt1)&&WaveExists(TempQ1)&&WaveExists(TempE1)&&WaveExists(TempInt2)&&WaveExists(TempQ2)&&WaveExists(TempE2))
			IN2G_RemoveNaNsFrom3Waves(TempInt1,TempQ1,TempE1)
			IN2G_RemoveNaNsFrom3Waves(TempInt2,TempQ2,TempE2)
			Duplicate/O TempInt1, ResultsInt, TempIntInterp2
			Duplicate/O TempQ1, ResultsQ
			Duplicate/O TempE1, ResultsE, TempEInterp2
			Duplicate/O TempInt2, TempIntLog2
			Duplicate/O TempE2, TempELog2
			TempIntLog2=log(TempInt2)
			TempELog2=log(TempE2)
			TempIntInterp2 = 10^(interp(TempQ1, TempQ2, TempIntLog2))
			TempEInterp2 = 10^(interp(TempQ1, TempQ2, TempELog2))
			if (BinarySearch(ResultsQ, TempQ2[0] )>0)
				TempIntInterp2[0,BinarySearch(ResultsQ, TempQ2[0] )]=NaN
				TempEInterp2[0,BinarySearch(ResultsQ, TempQ2[0] )]=NaN
			endif
			if ((BinarySearch(ResultsQ, TempQ2[numpnts(TempQ2)-1] )!=numpnts(ResultsQ)-1)&&(BinarySearch(ResultsQ, TempQ2[numpnts(TempQ2)-1] )!=-2))
				TempIntInterp2[BinarySearch(ResultsQ, TempQ2[numpnts(TempQ2)])+1,inf]=NaN
				TempEInterp2[BinarySearch(ResultsQ, TempQ2[numpnts(TempQ2)])+1,inf]=NaN
			endif
			ResultsInt = (TempInt1- TempIntInterp2)/TempIntInterp2
			ResultsE = sqrt(TempE1^2 + TempEInterp2^2)		//this creates erros for subtraction, line below for division...
			ResultsE = sqrt(((TempInt1- TempIntInterp2)^2)*(TempEInterp2^4) + (ResultsE^2)*(TempIntInterp2^4) + (((TempInt1- TempIntInterp2)^2)+(ResultsE^2))*TempIntInterp2^2 *TempEInterp2^2 ) / (TempIntInterp2*(TempIntInterp2^2 -TempEInterp2^2 ))
			//errors OK? I think so...			
			
			IN2G_ReplaceNegValsByNaNWaves(ResultsInt,ResultsQ,ResultsE)
			IN2G_RemoveNaNsFrom3Waves(ResultsInt,ResultsQ,ResultsE)
			
		elseif(WaveExists(TempInt1)&&WaveExists(TempQ1)&&WaveExists(TempInt2)&&WaveExists(TempQ2))
			IN2G_RemoveNaNsFrom2Waves(TempInt1,TempQ1)
			IN2G_RemoveNaNsFrom2Waves(TempInt2,TempQ2)
			Duplicate/O TempInt1, ResultsInt, TempIntInterp2
			Duplicate/O TempQ1, ResultsQ, ResultsEtemp
			Duplicate/O TempInt2, TempIntLog2
			TempIntLog2=log(TempInt2)
			TempIntInterp2 = 10^(interp(TempQ1, TempQ2, TempIntLog2))
				if (BinarySearch(ResultsQ, TempQ2[0] )>0)
				TempIntInterp2[0,BinarySearch(ResultsQ, TempQ2[0] )]=NaN
			endif
			if ((BinarySearch(ResultsQ, TempQ2[numpnts(TempQ2)-1] )!=numpnts(ResultsQ)-1)&&(BinarySearch(ResultsQ, TempQ2[numpnts(TempQ2)-1] )!=-2))
				TempIntInterp2[BinarySearch(ResultsQ, TempQ2[numpnts(TempQ2)])+1,inf]=NaN
			endif
			ResultsInt = (TempInt1 - TempIntInterp2)/TempIntInterp2
			IN2G_ReplaceNegValsByNaNWaves(ResultsInt,ResultsQ,ResultsEtemp)
			IN2G_RemoveNaNsFrom3Waves(ResultsInt,ResultsQ,ResultsEtemp)
		else
			DoAlert 0, "Incorrect data, you need two sets of at least Intensity and Q (errors are optional)"
		endif
	elseif  (RescaleToNewQscale)
		If (WaveExists(TempInt1)&&WaveExists(TempQ1)&&WaveExists(TempE1)&&WaveExists(TempQ2))
			IN2G_RemoveNaNsFrom3Waves(TempInt1,TempQ1,TempE1)
			IN2G_RemNaNsFromAWave(TempQ2)
			Duplicate/O TempQ2, ResultsInt, TempIntInterp1, TempEInterp1
			Duplicate/O TempQ2, ResultsQ
			Duplicate/O TempQ2, ResultsE
			Duplicate/O TempInt1, TempIntLog1
			Duplicate/O TempE1, TempELog1
			TempIntLog1=log(TempInt1)
			TempELog1=log(TempE1)
			TempIntInterp1 = 10^(interp(ResultsQ,TempQ1, TempIntLog1))
			TempEInterp1    = 10^(interp(ResultsQ,TempQ1, TempELog1))
			ResultsInt = TempIntInterp1
			ResultsE   =  TempEInterp1
			//now check, that we do not generate data beyond where they existed...
			if(BinarySearch(ResultsQ, TempQ1[0] )>0)			//so the Q1[0] is larger than Q2[0] (results Q)
				ResultsInt[0,BinarySearch(ResultsQ, TempQ1[0] )]=NaN
				ResultsE[0,BinarySearch(ResultsQ, TempQ1[0] )]=NaN				
			endif
			if(BinarySearch(ResultsQ, TempQ1[numpnts(TempQ1)-1] )<numpnts(ResultsQ) &&(BinarySearch(ResultsQ, TempQ1[numpnts(TempQ1)-1] )!=-2))			//so the Q1[last] is smaller than Q2[last] (results Q)
				ResultsInt[BinarySearch(ResultsQ, TempQ1[numpnts(TempQ1)-1] ), inf]=NaN
				ResultsE[BinarySearch(ResultsQ, TempQ1[numpnts(TempQ1)-1] ), inf]=NaN				
			endif
			
			IN2G_ReplaceNegValsByNaNWaves(ResultsInt,ResultsQ,ResultsE)
			IN2G_RemoveNaNsFrom3Waves(ResultsInt,ResultsQ,ResultsE)
			
		elseif(WaveExists(TempInt1)&&WaveExists(TempQ1)&&WaveExists(TempQ2))
			IN2G_RemoveNaNsFrom2Waves(TempInt1,TempQ1)
			IN2G_RemNaNsFromAWave(TempQ2)
			Duplicate/O TempQ2, ResultsInt, TempIntInterp1
			Duplicate/O TempQ2, ResultsQ
			Duplicate/O TempInt1, TempIntLog1
			TempIntLog1=log(TempInt1)
			TempIntInterp1 = 10^(interp(ResultsQ,TempQ1,TempIntLog1))
			ResultsInt = TempIntInterp1
	
			IN2G_ReplaceNegValsByNaNWaves(ResultsInt,ResultsQ,TempIntInterp1)
			IN2G_RemoveNaNsFrom3Waves(ResultsInt,ResultsQ,TempIntInterp1)
		else
			DoAlert 0, "Incorrect data, you need two sets of at least Intensity and Q (errors are optional)"
		endif
	else
		Abort "Nothing to do... Select action by selecting checbox above"
	endif
	//IN2G_RemoveNaNsFrom3Waves(TempInt1,TempQ1,TempE1)
	//IN2G_RemNaNsFromAWave
	//IN2G_RemoveNaNsFrom3Waves(TempInt2,TempQ2,TempE2)
	KillWaves/Z TempInt1, TempInt2, TempQ1, TempQ2, TempE1, TempE2
	KillWaves/Z TempIntLog2, TempIntInterp2
	KillWaves/Z TempIntLog1, TempIntInterp1
	KillWaves/Z TempELog2, TempEInterp2, ResultsEtemp
	KillWaves/Z TempELog1, TempEInterp1, ResultsEtemp
	setDataFolder OldDf
end
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1D_rebinData(TempInt,TempQ,TempE,NumberOfPoints, LogBinParam)
	wave TempInt,TempQ,TempE
	variable NumberOfPoints, LogBinParam

	string OldDf
	OldDf = GetDataFOlder(1)
	NewDataFolder/O/S root:packages
	NewDataFolder/O/S root:packages:TempDataRebin
	
	//Log rebinning, if requested.... 
	//create log distribution of points...
	make/O/D/N=(NumberOfPoints) tempNewLogDist, tempNewLogDistBinWidth
	tempNewLogDist = exp((0.8*LogBinParam/100) * p)
	variable tempLogDistRange = tempNewLogDist[numpnts(tempNewLogDist)-1] - tempNewLogDist[0]
	tempNewLogDist =((tempNewLogDist-1)/tempLogDistRange)
	variable StartQ, EndQ
	startQ=TempQ[0]
	endQ=TempQ[numpnts(TempQ)-1]
	tempNewLogDist = startQ + (tempNewLogDist[p])*((endQ-startQ))
	tempNewLogDistBinWidth = tempNewLogDist[p+1] - tempNewLogDist[p]
	make/O/D/N=(NumberOfPoints) Rebinned_TempQ, Rebinned_tempInt, Rebinned_TempErr
	Rebinned_tempInt=0
	Rebinned_TempErr=0	
	variable i, j	//, startIntg=TempQ[1]-TempQ[0]
	//first assume that we can step through this easily...
	variable cntPoints, BinHighEdge
	//variable i will be from 0 to number of new points, moving through destination waves
	j=0		//this variable goes through data to be reduced, therefore it goes from 0 to numpnts(TempInt)
	For(i=0;i<NumberOfPoints;i+=1)
		cntPoints=0
		BinHighEdge = tempNewLogDist[i]+tempNewLogDistBinWidth[i]/2
		Do
			Rebinned_tempInt[i]+=TempInt[j]
			Rebinned_TempErr[i]+=TempE[j]
			Rebinned_TempQ[i] += TempQ[j]
			cntPoints+=1
		j+=1
		While(TempQ[j]<BinHighEdge)
		Rebinned_tempInt[i]/=	cntPoints
		Rebinned_TempErr[i]/=cntPoints
		Rebinned_TempQ[i]/=cntPoints
	endfor
	
	Rebinned_TempQ = (Rebinned_TempQ[p]>0) ? Rebinned_TempQ[p] : NaN
	
	IN2G_RemoveNaNsFrom3Waves(Rebinned_tempInt,Rebinned_TempErr,Rebinned_TempQ)

	
	Redimension/N=(numpnts(Rebinned_tempInt))/D TempInt,TempQ,TempE
	TempInt=Rebinned_tempInt
	TempQ=Rebinned_TempQ
	TempE=Rebinned_TempErr
	
	KillWaves/Z Rebinned_tempInt, Rebinned_TempQ,Rebinned_TempErr

	setDataFolder OldDF
	KillDataFolder/Z root:packages:TempDataRebin
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR1D_SmoothData()

	string OldDf
	OldDf=GetDataFOlder(1)
	setDataFolder root:packages:SASDataModification
	
	NVAR SmoothInLogScale = root:packages:SASDataModification:SmoothInLogScale
	NVAR SmoothInLinScale = root:packages:SASDataModification:SmoothInLinScale
	NVAR SmoothWindow = root:Packages:SASDataModification:SmoothWindow
	NVAR SmoothSplines=root:Packages:SASDataModification:SmoothSplines
	NVAR SmoothSplinesParam=root:Packages:SASDataModification:SmoothSplinesParam
	
	Wave/Z ResultsInt=root:Packages:SASDataModification:ResultsInt
	Wave/Z ResultsQ=root:Packages:SASDataModification:ResultsQ
	Wave/Z ResultsE=root:Packages:SASDataModification:ResultsE
	if(!WaveExists(ResultsInt))
		abort
	endif
	
	VARIABLE CreatedErrors=0
	if(!WaveExists(ResultsE))
		CreatedErrors=1
		Duplicate/O ResultsInt, ResultsE
		ResultsE=0.005*ResultsE
	endif

	IN2G_ReplaceNegValsByNaNWaves(ResultsQ,ResultsInt,ResultsE)
	variable i=0, imax=numpnts(ResultsQ)
	for (i=imax;i>=0;i-=1)
		if (ResultsQ[i]==0 || ResultsInt[i]==0)  // || ResultsE[i]==0)   changed 7/27/09, 0 error is acceptable...
			ResultsQ[i]=NaN
			ResultsInt[i]=Nan
			ResultsE[i]=NaN
		endif
	endfor

	IN2G_RemoveNaNsFrom3Waves(ResultsQ,ResultsInt,ResultsE)

	Duplicate/O ResultsInt, ResultsIntBckp
	if (WaveExists(ResultsE))
		Duplicate/O ResultsE, ResultsEBckp
	endif
	if (SmoothSplines)
		If (WaveExists(ResultsInt)&&WaveExists(ResultsE))
			Duplicate/O ResultsInt, ResultsInt_log, Error_log,SmoothInt
			Duplicate/O ResultsQ, ResultsQ_log
			ResultsQ_log = log( ResultsQ)
			ResultsInt_log= log(ResultsInt)
			variable scaleMe
			variable param = -1+10^SmoothSplinesParam
			variable startPoint
			variable endPoint
			variable tempN
			if(strlen(CsrWave(A, "IR1D_DataManipulationGraph"))>0)
				Wave tempWv=CsrXWaveRef(A, "IR1D_DataManipulationGraph")
				tempN = tempWv[pcsr(A, "IR1D_DataManipulationGraph")]
				startPoint= binarysearch(ResultsQ,tempN)
				//startPoint= pcsr(A, "IR1D_DataManipulationGraph")-1
			else
				startPoint=0
			endif
			if(strlen(CsrWave(B, "IR1D_DataManipulationGraph"))>0)
				Wave tempWv=CsrXWaveRef(B, "IR1D_DataManipulationGraph")
				tempN = tempWv[pcsr(B, "IR1D_DataManipulationGraph")]
				endPoint= binarysearch(ResultsQ,tempN)
				//endPoint= pcsr(B, "IR1D_DataManipulationGraph")+1
			else
				endPoint=numpnts(ResultsInt_log)-1
			endif
			wavestats/Q ResultsInt_log
			scaleMe = 2*(-V_min)
			ResultsInt_log+= scaleMe
			Error_log= ResultsInt_log*( (ResultsE)/(ResultsInt))
			

			IN2G_SplineSmooth(startPoint,endPoint,ResultsQ_log,ResultsInt_log,Error_log,param,SmoothInt,$"")
			//
//			Duplicate/O ResultsQ_log, ResultsQ_log1
//			Interpolate2 /A=0 /F=(param) /I=3 /J=1 /SWAV=Error_log /X=ResultsQ_log1 /T=2 /Y=SmoothInt ResultsQ_log, ResultsInt_log		
//		//	Interpolate2 /A=(numpnts(ResultsInt_log)) /F=(param) /I=3 /J=1 /SWAV=Error_log /X=ResultsQ_log1 /T=3 ResultsQ_log, ResultsInt_log	
//		//	Wave ResultsInt_log_CS
//		//	SmoothInt=ResultsInt_log_CS	
			//
			SmoothInt-=scaleMe
			Duplicate/O ResultsInt, ResultsInt2
			ResultsInt = 10^SmoothInt
			duplicate/O ResultsInt, ChiSqWv
			ChiSqWv= (ResultsInt-ResultsInt2)/ResultsE
			ChiSqWv=ChiSqWv^2
			IN2G_RemNaNsFromAWave(ChiSqWv)	
			variable NormalizedChiSquare
			NormalizedChiSquare = sqrt(sum(ChiSqWv))/numpnts(ChiSqWv)
			TextBox/C/A=LC/W=IR1D_DataManipulationGraph/N=text1 "Chi-squared reached ="+num2str(NormalizedChiSquare)
		elseif(WaveExists(ResultsInt))
//			smooth/B/E=3 SmoothWindow, ResultsInt
			DoAlert 0, "Spline smooth available only when error bars are provided"
		endif
	endif
	if (SmoothInLogScale)
		If (WaveExists(ResultsInt)&&WaveExists(ResultsE) &&!CreatedErrors)
			ResultsInt = log(ResultsInt)
//			smooth/B/E=3 SmoothWindow, ResultsInt
			smooth/E=3 SmoothWindow, ResultsInt
			ResultsInt = 10^ResultsInt
			ResultsE = log(ResultsE)
//			smooth/B/E=3 SmoothWindow, ResultsE
			smooth/E=3 SmoothWindow, ResultsE
			ResultsE = 10^ResultsE
		elseif(WaveExists(ResultsInt) && CreatedErrors)
			ResultsInt = log(ResultsInt)
//			smooth/B/E=3 SmoothWindow, ResultsInt
			smooth/E=3 SmoothWindow, ResultsInt
			ResultsInt = 10^ResultsInt
		endif
	endif
	if (SmoothInLinScale)
		If (WaveExists(ResultsInt)&&WaveExists(ResultsE) && !CreatedErrors)
//			smooth/B/E=3 SmoothWindow, ResultsInt
			smooth/E=3 SmoothWindow, ResultsInt
			smooth/E=3 SmoothWindow, ResultsE
		elseif(WaveExists(ResultsInt) && CreatedErrors)
//			smooth/B/E=3 SmoothWindow, ResultsInt
			smooth/E=3 SmoothWindow, ResultsInt
		endif
	endif

//	variable i
//	If (WaveExists(ResultsInt))
//		For(i=0;i<SmoothWindow;i+=1)
//			ResultsInt[i] = ResultsIntBckp[i]
//		endfor
//	endif
//	If(WaveExists(ResultsE))
//		For(i=0;i<SmoothWindow;i+=1)
//			ResultsE[i] = ResultsEBckp[i]
//		endfor
//	endif
	if(CreatedErrors)
		KillWaves ResultsE
	endif
	KillWaves/Z ResultsIntBckp, ResultsEBckp
	setDataFolder OldDf
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1D_AutoScale()

	string OldDf
	OldDf= GetDataFOlder(1)
	setDataFolder root:Packages:SASDataModification
	
	if ((strlen(CsrWave(A,"IR1D_DataManipulationGraph"))==0) || (strlen(CsrWave(B,"IR1D_DataManipulationGraph"))==0))
		Abort "Please position both cursors in the graph so they select the overlap region to use"
	endif

	NVAR Data1_IntMultiplier=root:Packages:SASDataModification:Data1_IntMultiplier
	NVAR Data2_IntMultiplier=root:Packages:SASDataModification:Data2_IntMultiplier
	Data1_IntMultiplier=1
	Data2_IntMultiplier = 1

	IR1D_RecalculateData()
	
	Wave/Z Intensity1=root:Packages:SASDataModification:Intensity1
	Wave/Z Intensity2=root:Packages:SASDataModification:Intensity2
	Wave/Z Qvector1=root:Packages:SASDataModification:Qvector1
	Wave/Z Qvector2=root:Packages:SASDataModification:Qvector2

	variable startQ, endQ
	startQ = CsrXWaveRef(A,"IR1D_DataManipulationGraph")[pcsr(A,"IR1D_DataManipulationGraph")]
	endQ = CsrXWaveRef(B,"IR1D_DataManipulationGraph")[pcsr(B,"IR1D_DataManipulationGraph")]

	
	if (!WaveExists(Intensity1) || !WaveExists(Intensity2) || !WaveExists(Qvector1) || !WaveExists(Qvector2))
		abort
	endif
	Duplicate/O Intensity1, TempInt1
	Duplicate/O Intensity2, TempInt2
	Duplicate/O Qvector1, TempQ1, bla1
	Duplicate/O Qvector2, TempQ2, bla2
	variable integral1, integral2
	IN2G_RemoveNaNsFrom3Waves(TempInt1,TempQ1,bla1)
	IN2G_RemoveNaNsFrom3Waves(TempInt2,TempQ2,bla2)
	
	integral1=areaXY(TempQ1, TempInt1, startQ, endQ )
	integral2=areaXY(TempQ2, TempInt2, startQ, endQ )
	
	
	Data1_IntMultiplier=1
	Data2_IntMultiplier = integral1/integral2

	KillWaves TempInt1,TempInt2, TempQ1, TempQ2, bla1, bla2
	setDataFolder OldDf
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1D_RemoveListQpnt()
	
	SVAR Data1RemoveListofPnts=root:Packages:SASDataModification:Data1RemoveListofPnts
	SVAR Data2RemoveListofPnts=root:Packages:SASDataModification:Data2RemoveListofPnts

	variable CurrentPoint=pcsr(A)
	string currentWave=CsrWave(A,"IR1D_DataManipulationGraph")
	if (cmpstr(CsrWave(A,"IR1D_DataManipulationGraph"), "Intensity1")==0)
		Data1RemoveListofPnts+=num2str(pcsr(A))+";"
	endif	
	if (cmpstr(CsrWave(A,"IR1D_DataManipulationGraph"), "Intensity2")==0)
		Data2RemoveListofPnts+=num2str(pcsr(A))+";"
	endif	
	Cursor /P /W=IR1D_DataManipulationGraph A  $currentWave CurrentPoint+1	
end
Function IR1D_RemoveSmallQpnt()
	
	NVAR Data1RemoveSmallQ=root:Packages:SASDataModification:Data1RemoveSmallQ
	NVAR Data2RemoveSmallQ=root:Packages:SASDataModification:Data2RemoveSmallQ

	if (cmpstr(CsrWave(A,"IR1D_DataManipulationGraph"), "Intensity1")==0)
		Data1RemoveSmallQ=pcsr(A)
	endif	
	if (cmpstr(CsrWave(A,"IR1D_DataManipulationGraph"), "Intensity2")==0)
		Data2RemoveSmallQ=pcsr(A)
	endif	
end
Function IR1D_RemoveLargeQpnt()
	
	NVAR Data1RemoveLargeQ=root:Packages:SASDataModification:Data1RemoveLargeQ
	NVAR Data2RemoveLargeQ=root:Packages:SASDataModification:Data2RemoveLargeQ

	if (cmpstr(CsrWave(B,"IR1D_DataManipulationGraph"), "Intensity1")==0)
		Data1RemoveLargeQ=pcsr(B)
	endif	
	if (cmpstr(CsrWave(B,"IR1D_DataManipulationGraph"), "Intensity2")==0)
		Data2RemoveLargeQ=pcsr(B)
	endif	
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1D_ResetModifyData()

	string ListOfVariables
	variable i
	ListOfVariables="Data1_IntMultiplier;Data1_ErrMultiplier;"
	ListOfVariables+="Data2_IntMultiplier;Data2_ErrMultiplier;"
		//Set numbers to 1
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		NVAR test=$("root:Packages:SASDataModification:"+StringFromList(i,ListOfVariables))
		test =1
	endfor		
	
	ListOfVariables="Data1_Qshift;Data1_Background;Data1RemoveSmallQ;"
	ListOfVariables+="Data2_Qshift;Data2_Background;Data2RemoveSmallQ;"
	//Set numbers to 0
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		NVAR test=$("root:Packages:SASDataModification:"+StringFromList(i,ListOfVariables))
		test =0
	endfor		
	//set numbers to inf
	ListOfVariables="Data1RemoveLargeQ;"
	ListOfVariables+="Data2RemoveLargeQ;"
	//Set numbers to 0
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		NVAR test=$("root:Packages:SASDataModification:"+StringFromList(i,ListOfVariables))
		test =inf
	endfor		
	
	string ListOfStrings
	ListOfStrings="Data1RemoveListofPnts;"
	ListOfStrings+="Data2RemoveListofPnts;"
	//Set strings to ""
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		SVAR teststr=$("root:Packages:SASDataModification:"+StringFromList(i,ListOfStrings))
		teststr =""
	endfor		

	DOWIndow IR1D_DataManipulationGraph
	if(V_Flag)
		DoWindow/K IR1D_DataManipulationGraph
	endif
	string OldDf
	OldDf=GetDataFolder (1)
	setDataFolder root:Packages:SASDataModification:
	KillWaves/Z Intensity1, OriginalIntensity1, Qvector1, OriginalQvector1, OriginalError1, Error1
	KillWaves/Z Intensity2, OriginalIntensity2, Qvector2, OriginalQvector2, OriginalError2, Error2
	KillWaves/Z ResultsInt,ResultsQ, ResultsE
	setDataFolder OldDf

end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR1D_RecalculateData()

	NVAR Data1_IntMultiplier=root:Packages:SASDataModification:Data1_IntMultiplier
	NVAR Data1_ErrMultiplier=root:Packages:SASDataModification:Data1_ErrMultiplier
	NVAR Data2_IntMultiplier=root:Packages:SASDataModification:Data2_IntMultiplier
	NVAR Data2_ErrMultiplier=root:Packages:SASDataModification:Data2_ErrMultiplier
	NVAR Data1_Qshift=root:Packages:SASDataModification:Data1_Qshift
	NVAR Data1_Background=root:Packages:SASDataModification:Data1_Background
	NVAR Data2_Qshift=root:Packages:SASDataModification:Data2_Qshift
	NVAR Data2_Background=root:Packages:SASDataModification:Data2_Background

	NVAR Data1RemoveSmallQ=root:Packages:SASDataModification:Data1RemoveSmallQ
	NVAR Data1RemoveLargeQ=root:Packages:SASDataModification:Data1RemoveLargeQ
	SVAR Data1RemoveListofPnts=root:Packages:SASDataModification:Data1RemoveListofPnts
	
	NVAR Data2RemoveSmallQ=root:Packages:SASDataModification:Data2RemoveSmallQ
	NVAR Data2RemoveLargeQ=root:Packages:SASDataModification:Data2RemoveLargeQ
	SVAR Data2RemoveListofPnts=root:Packages:SASDataModification:Data2RemoveListofPnts

	Wave/Z Intensity1=root:Packages:SASDataModification:Intensity1
	Wave/Z Qvector1=root:Packages:SASDataModification:Qvector1
	Wave/Z Error1=root:Packages:SASDataModification:Error1
	Wave/Z Intensity2=root:Packages:SASDataModification:Intensity2
	Wave/Z Qvector2=root:Packages:SASDataModification:Qvector2
	Wave/Z Error2=root:Packages:SASDataModification:Error2

	Wave/Z OriginalIntensity1=root:Packages:SASDataModification:OriginalIntensity1
	Wave/Z OriginalQvector1=root:Packages:SASDataModification:OriginalQvector1
	Wave/Z OriginalError1=root:Packages:SASDataModification:OriginalError1
	Wave/Z OriginalIntensity2=root:Packages:SASDataModification:OriginalIntensity2
	Wave/Z OriginalQvector2=root:Packages:SASDataModification:OriginalQvector2
	Wave/Z OriginalError2=root:Packages:SASDataModification:OriginalError2
	variable i, cursorNow
	string tempPntNum, tempWvName


	if (WaveExists(Intensity1))
		Intensity1 = Data1_IntMultiplier * OriginalIntensity1 - Data1_Background
		Intensity1[0,Data1RemoveSmallQ-1]=NaN
		Intensity1[Data1RemoveLargeQ+1,inf]=NaN
		if (strlen(Data1RemoveListofPnts)>0)
			for (i=0;i<ItemsInList(Data1RemoveListofPnts);i+=1)
				tempPntNum=stringFromList(i,Data1RemoveListofPnts)
				Intensity1[str2num(tempPntNum)]=NaN
			endfor
		endif
	endif
	if(WaveExists(Qvector1))
		Qvector1  = OriginalQvector1 - Data1_Qshift
	endif
	if(WaveExists(Error1))
		Error1  = OriginalError1 * Data1_ErrMultiplier * Data1_IntMultiplier		//have to first scale to intensity muplitplier then scale by other parameter
	endif
	if (WaveExists(Intensity2))
		Intensity2 = Data2_IntMultiplier * OriginalIntensity2 - Data2_Background
		Intensity2[0,Data2RemoveSmallQ-1]=NaN
		Intensity2[Data2RemoveLargeQ+1,inf]=NaN
		if (strlen(Data2RemoveListofPnts)>0)
			for (i=0;i<ItemsInList(Data2RemoveListofPnts);i+=1)
				tempPntNum=stringFromList(i,Data2RemoveListofPnts)
				Intensity2[str2num(tempPntNum)]=NaN
			endfor
		endif
	endif
	if(WaveExists(Qvector2))
		Qvector2  = OriginalQvector2 - Data2_Qshift
	endif
	if(WaveExists(Error2))
		Error2  = OriginalError2 * Data2_ErrMultiplier * Data2_IntMultiplier		//again, first scale to intensity then to special factor...
	endif	
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR1D_CopyDataAndGraph()

	DoWIndow IR1D_DataManipulationGraph
	if(V_Flag)
		DoWindow/K IR1D_DataManipulationGraph
	endif
	IR1D_CopyDataLocally()
	Execute("IR1D_DataManipulationGraph()")
	AutoPositionWindow/M=0 /R=IR1D_DataManipulationPanel IR1D_DataManipulationGraph
	IR1D_RegraphData()
	DoWindow/F IR1D_DataManipulationPanel
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR1D_RegraphData()
	
	Wave/Z Intensity1=root:Packages:SASDataModification:Intensity1
	Wave/Z Qvector1=root:Packages:SASDataModification:Qvector1
	Wave/Z Error1=root:Packages:SASDataModification:Error1
	Wave/Z Intensity2=root:Packages:SASDataModification:Intensity2
	Wave/Z Qvector2=root:Packages:SASDataModification:Qvector2
	Wave/Z Error2=root:Packages:SASDataModification:Error2
	
	SVAR DataFolderName=root:Packages:SASDataModification:DataFolderName
	SVAR IntensityWaveName= root:Packages:SASDataModification:IntensityWaveName
	SVAR DataFolderName2=root:Packages:SASDataModification:DataFolderName2
	SVAR IntensityWaveName2=root:Packages:SASDataModification:IntensityWaveName2
	if (WaveExists(Intensity1)&& WaveExists(Qvector1))
		AppendToGraph/W=IR1D_DataManipulationGraph Intensity1 vs Qvector1 
		if (WaveExists(Error1))
			ErrorBars/W=IR1D_DataManipulationGraph Intensity1 Y,wave=(Error1,Error1)		
		endif
	endif
	if (WaveExists(Intensity2)&& WaveExists(Qvector2))
		AppendToGraph/W=IR1D_DataManipulationGraph Intensity2 vs Qvector2 
		if (WaveExists(Error2))
			ErrorBars/W=IR1D_DataManipulationGraph Intensity2 Y,wave=(Error2,Error2)		
		endif
	endif

	string LegendStr="\\F"+IR2C_LkUpDfltStr("FontType")+"\\Z"+IR2C_LkUpDfltVar("LegendSize")+"\\s(Intensity1) Data1\r\\s(Intensity2) Data2"
//	Legend/W=IR1_LogLogPlotU/N=text0/J/F=0/A=MC/X=32.03/Y=38.79 LegendStr

	Legend/C/N=text0/A=LB/W=IR1D_DataManipulationGraph LegendStr
	
	ModifyGraph/W=IR1D_DataManipulationGraph mode=3
	ModifyGraph/Z/W=IR1D_DataManipulationGraph marker[0]=8,marker[1]=17
	ModifyGraph/Z/W=IR1D_DataManipulationGraph rgb[1]=(16384,16384,65280)
	TextBox/W=IR1D_DataManipulationGraph/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	TextBox/W=IR1D_DataManipulationGraph/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z07"+DataFolderName+IntensityWaveName+"\r"+DataFolderName2+IntensityWaveName2	

	ModifyGraph/W=IR1D_DataManipulationGraph log=1
	ModifyGraph/W=IR1D_DataManipulationGraph mirror=1

	String LabelStr= "\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"Intensity [cm\\S-1\\M\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"]"
	Label/Z/W=IR1D_DataManipulationGraph left LabelStr
	LabelStr= "\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"Q [A\\S-1\\M\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"]"
	Label/Z/W=IR1D_DataManipulationGraph bottom LabelStr
//	Label/Z/W=IR1D_DataManipulationGraph left "Intensity [cm\\S-1\\M]"
//	Label/Z/W=IR1D_DataManipulationGraph bottom "Q [A\\S-1\\M]"
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Proc IR1D_DataManipulationGraph()
	PauseUpdate; Silent 1		// building window...
	Display/K=1 /W=(320.25,41.75,714.75,371.75) as "IR1D_DataManipulationGraph"
	DoWindow/C IR1D_DataManipulationGraph
	ShowInfo
EndMacro

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR1D_PresetOutputStrings()

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:SASDataModification:
	SVAR DataFolderName1=root:Packages:SASDataModificationTop:DataFolderName
	SVAR IntensityWaveName1=root:Packages:SASDataModificationTop:IntensityWaveName
	SVAR QWavename1=root:Packages:SASDataModificationTop:QWavename
	SVAR ErrorWaveName1=root:Packages:SASDataModificationTop:ErrorWaveName

	SVAR NewDataFolderName=root:Packages:SASDataModification:NewDataFolderName
	SVAR NewIntensityWaveName=root:Packages:SASDataModification:NewIntensityWaveName
	SVAR NewQWavename=root:Packages:SASDataModification:NewQWavename
	SVAR NewErrorWaveName=root:Packages:SASDataModification:NewErrorWaveName
	
	NewDataFolderName = DataFolderName1
	NewIntensityWaveName = IntensityWaveName1
	NewQWavename = QWavename1
	NewErrorWaveName = ErrorWaveName1
	string MostOfThePath
	string LastPartOfPath
	variable NumberOfLevelsInPath
	NumberOfLevelsInPath= ItemsInList(NewDataFolderName , ":")
	LastPartOfPath = StringFromList(NumberOfLevelsInPath-1, NewDataFolderName ,":")
	MostOfThePath = RemoveFromList(LastPartOfPath, NewDataFolderName ,":")
	
	if (stringmatch(IntensityWaveName1,"*DSM_Int*") && stringmatch(QWavename1,"*DSM_Qvec*") && stringmatch(ErrorWaveName1,"*DSM_Error*"))
		//using Indra naming convention on input Data 1, change NewDataFolderName
		LastPartOfPath = IN2G_RemoveExtraQuote(LastPartOfPath,1,1)	//remove ' from liberal names
		LastPartOfPath = LastPartOfPath[0,26]
		LastPartOfPath += "_mod" 
		LastPartOfPath = PossiblyQuoteName(LastPartOfPath)
		NewDataFolderName = MostOfThePath+LastPartOfPath+":"
	endif
	string tempNIN, tempNQN, tempNEN
	tempNIN = IN2G_RemoveExtraQuote(NewIntensityWaveName,1,1)
	tempNQN = IN2G_RemoveExtraQuote(NewQWavename,1,1)
	tempNEN = IN2G_RemoveExtraQuote(NewErrorWaveName,1,1)
	if ((cmpstr(tempNIN[0],"r")==0) &&(cmpstr(tempNQN[0],"q")==0) &&(cmpstr(tempNEN[0],"s")==0))
		//using qrs data structure, rename the waves names
		//intensity
		NewIntensityWaveName = IN2G_RemoveExtraQuote(NewIntensityWaveName,1,1)
		NewIntensityWaveName = NewIntensityWaveName[0,26]
		NewIntensityWaveName = NewIntensityWaveName+"_mod"
	//	NewIntensityWaveName = PossiblyQuoteName(NewIntensityWaveName)
		//Q vector
		NewQWavename = IN2G_RemoveExtraQuote(NewQWavename,1,1)
		NewQWavename = NewQWavename[0,26]
		NewQWavename = NewQWavename+"_mod"
	//	NewQWavename = PossiblyQuoteName(NewQWavename)
		//error
		NewErrorWaveName = IN2G_RemoveExtraQuote(NewErrorWaveName,1,1)
		NewErrorWaveName = NewErrorWaveName[0,26]
		NewErrorWaveName = NewErrorWaveName+"_mod"
	//	NewErrorWaveName = PossiblyQuoteName(NewErrorWaveName)
		
	endif
	
		
	setDataFolder OldDf
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1D_CopyDataLocally()

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:SASDataModification:
	
	SVAR DataFolderName1=root:Packages:SASDataModificationTop:DataFolderName
	SVAR IntensityWaveName1=root:Packages:SASDataModificationTop:IntensityWaveName
	SVAR QWavename1=root:Packages:SASDataModificationTop:QWavename
	SVAR ErrorWaveName1=root:Packages:SASDataModificationTop:ErrorWaveName
	SVAR DataFolderName2=root:Packages:SASDataModificationBot:DataFolderName
	SVAR IntensityWaveName2=root:Packages:SASDataModificationBot:IntensityWaveName
	SVAR QWavename2=root:Packages:SASDataModificationBot:QWavename
	SVAR ErrorWaveName2=root:Packages:SASDataModificationBot:ErrorWaveName
	//fix for liberal names
	if (cmpstr(IntensityWaveName1[0],"'")!=0)
		IntensityWaveName1 = PossiblyQuoteName(IntensityWaveName1)
	endif
	if (cmpstr(QWavename1[0],"'")!=0)
		QWavename1 = PossiblyQuoteName(QWavename1)
	endif
	if (cmpstr(ErrorWaveName1[0],"'")!=0)
		ErrorWaveName1 = PossiblyQuoteName(ErrorWaveName1)
	endif
	if (cmpstr(IntensityWaveName2[0],"'")!=0)
		IntensityWaveName2 = PossiblyQuoteName(IntensityWaveName2)
	endif
	if (cmpstr(QWavename2[0],"'")!=0)
		QWavename2 = PossiblyQuoteName(QWavename2)
	endif
	if (cmpstr(ErrorWaveName2[0],"'")!=0)
		ErrorWaveName2 = PossiblyQuoteName(ErrorWaveName2)
	endif
	Wave/Z IntWv1=$(DataFolderName1+IntensityWaveName1) 
	Wave/Z QWv1=$(DataFolderName1+QWavename1) 
	Wave/Z EWv1=$(DataFolderName1+ErrorWaveName1) 
	Wave/Z IntWv2=$(DataFolderName2+IntensityWaveName2) 
	Wave/Z QWv2=$(DataFolderName2+QWavename2) 
	Wave/Z EWv2=$(DataFolderName2+ErrorWaveName2) 
	
	Wave/Z KillWv1=root:Packages:SASDataModification:Intensity1
	Wave/Z KillWv2=root:Packages:SASDataModification:Qvector1
	Wave/Z KillWv3=root:Packages:SASDataModification:Error1
	Wave/Z KillWv4=root:Packages:SASDataModification:Intensity2
	Wave/Z KillWv5=root:Packages:SASDataModification:Qvector2
	Wave/Z KillWv6=root:Packages:SASDataModification:Error2

	Wave/Z KillWvO1=root:Packages:SASDataModification:OriginalIntensity1
	Wave/Z KillWvO2=root:Packages:SASDataModification:OriginalQvector1
	Wave/Z KillWvO3=root:Packages:SASDataModification:OriginalError1
	Wave/Z KillWvO4=root:Packages:SASDataModification:OriginalIntensity2
	Wave/Z KillWvO5=root:Packages:SASDataModification:OriginalQvector2
	Wave/Z KillWvO6=root:Packages:SASDataModification:OriginalError2
	
	KillWaves/Z KillWv1, KillWv2,KillWv3,KillWv4,KillWv5,KillWv6
	KillWaves/Z KillWvO1, KillWvO2,KillWvO3,KillWvO4,KillWvO5,KillWvO6
	
	if (WaveExists(IntWv1))
		Duplicate/O IntWv1, $("root:Packages:SASDataModification:Intensity1")
		Duplicate/O IntWv1, $("root:Packages:SASDataModification:OriginalIntensity1")
	endif
	if (WaveExists(QWv1))
		Duplicate/O QWv1, $("root:Packages:SASDataModification:Qvector1")
		Duplicate/O QWv1, $("root:Packages:SASDataModification:OriginalQvector1")
	endif
	if (WaveExists(EWv1))
		Duplicate/O EWv1, $("root:Packages:SASDataModification:Error1")
		Duplicate/O EWv1, $("root:Packages:SASDataModification:OriginalError1")
	endif
	if (WaveExists(IntWv2))
		Duplicate/O IntWv2, $("root:Packages:SASDataModification:Intensity2")
		Duplicate/O IntWv2, $("root:Packages:SASDataModification:OriginalIntensity2")
	endif
	if (WaveExists(QWv2))
		Duplicate/O QWv2, $("root:Packages:SASDataModification:Qvector2")
		Duplicate/O QWv2, $("root:Packages:SASDataModification:OriginalQvector2")
	endif
	if (WaveExists(EWv2))
		Duplicate/O EWv2, $("root:Packages:SASDataModification:Error2")
		Duplicate/O EWv2, $("root:Packages:SASDataModification:OriginalError2")
	endif
	setDataFolder OldDf
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1D_InputPanelCheckboxProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:SASDataModification
		SVAR Dtf=root:Packages:SASDataModification:DataFolderName
		SVAR IntDf=root:Packages:SASDataModification:IntensityWaveName
		SVAR QDf=root:Packages:SASDataModification:QWaveName
		SVAR EDf=root:Packages:SASDataModification:ErrorWaveName
		NVAR UseIndra2Data=root:Packages:SASDataModification:UseIndra2Data
		NVAR UseQRSData=root:Packages:SASDataModification:UseQRSData

		SVAR Dtf2=root:Packages:SASDataModification:DataFolderName2
		SVAR IntDf2=root:Packages:SASDataModification:IntensityWaveName2
		SVAR QDf2=root:Packages:SASDataModification:QWaveName2
		SVAR EDf2=root:Packages:SASDataModification:ErrorWaveName2
		NVAR UseIndra2Data2=root:Packages:SASDataModification:UseIndra2Data2
		NVAR UseQRSData2=root:Packages:SASDataModification:UseQRSData2

		SVAR NDtf=root:Packages:SASDataModification:NewDataFolderName
		SVAR NIntDf=root:Packages:SASDataModification:NewIntensityWaveName
		SVAR NQDf=root:Packages:SASDataModification:NewQWaveName
		SVAR NEDf=root:Packages:SASDataModification:NewErrorWaveName

	if (cmpstr(ctrlName,"UseIndra2Data")==0)
		//here we control the data structure checkbox
		UseIndra2Data=checked
		if (checked)
			UseQRSData=0
		endif
		Checkbox UseIndra2Data, value=UseIndra2Data
		Checkbox UseQRSData, value=UseQRSData
			Dtf=" "
			IntDf=" "
			QDf=" "
			EDf=" "
			PopupMenu SelectDataFolder mode=1
			PopupMenu IntensityDataName   mode=1, value="---"
			PopupMenu QvecDataName    mode=1, value="---"
			PopupMenu ErrorDataName    mode=1, value="---"
			//this resets the data folder pointers for user
			NDtf=""
			NIntDf=""
			NQDf=""
			NEDf=""
	endif
	if (cmpstr(ctrlName,"UseQRSData")==0)
		//here we control the data structure checkbox
		UseQRSData=checked
		if (checked)
			UseIndra2Data=0
		endif
		Checkbox UseIndra2Data, value=UseIndra2Data
		Checkbox UseQRSData, value=UseQRSData
			Dtf=" "
			IntDf=" "
			QDf=" "
			EDf=" "
			PopupMenu SelectDataFolder mode=1
			PopupMenu IntensityDataName   mode=1, value="---"
			PopupMenu QvecDataName    mode=1, value="---"
			PopupMenu ErrorDataName    mode=1, value="---"
			//this resets the data folder pointers for user
			NDtf=""
			NIntDf=""
			NQDf=""
			NEDf=""
	endif
	if (cmpstr(ctrlName,"UseIndra2Data2")==0)
		//here we control the data structure checkbox
		UseIndra2Data2=checked
		if (checked)
			UseQRSData2=0
		endif
		Checkbox UseIndra2Data2, value=UseIndra2Data2
		Checkbox UseQRSData2, value=UseQRSData2
			Dtf2=" "
			IntDf2=" "
			QDf2=" "
			EDf2=" "
			PopupMenu SelectDataFolder2 mode=1
			PopupMenu IntensityDataName2   mode=1, value="---"
			PopupMenu QvecDataName2    mode=1, value="---"
			PopupMenu ErrorDataName2    mode=1, value="---"
	endif
	if (cmpstr(ctrlName,"UseQRSData2")==0)
		//here we control the data structure checkbox
		UseQRSData2=checked
		if (checked)
			UseIndra2Data2=0
		endif
		Checkbox UseIndra2Data2, value=UseIndra2Data2
		Checkbox UseQRSData2, value=UseQRSData2
			Dtf2=" "
			IntDf2=" "
			QDf2=" "
			EDf2=" "
			PopupMenu SelectDataFolder2 mode=1
			PopupMenu IntensityDataName2   mode=1, value="---"
			PopupMenu QvecDataName2    mode=1, value="---"
			PopupMenu ErrorDataName2    mode=1, value="---"
	endif


	//ANd now lets always synchronize the above stuff with the strings in the SASDataModification
	SVAR DataFolderName1=root:Packages:SASDataModification:DataFolderName1
	SVAR IntensityWaveName1=root:Packages:SASDataModification:IntensityWaveName1
	SVAR QWavename1=root:Packages:SASDataModification:QWavename1
	SVAR ErrorWaveName1=root:Packages:SASDataModification:ErrorWaveName1

	SVAR DataFolderName2=root:Packages:SASDataModification:DataFolderName2
	SVAR IntensityWaveName2=root:Packages:SASDataModification:IntensityWaveName2
	SVAR QWavename2=root:Packages:SASDataModification:QWavename2
	SVAR ErrorWaveName2=root:Packages:SASDataModification:ErrorWaveName2
	
	DataFolderName1=Dtf
	IntensityWaveName1=IntDf
	QWavename1=QDf
	ErrorWaveName1=EDf

	DataFolderName2=Dtf2
	IntensityWaveName2=IntDf2
	QWavename2=QDf2
	ErrorWaveName2=EDf2
end

Function IR1D_InputPanelCheckboxProc2(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	NVAR CombineData = root:packages:SASDataModification:CombineData
	NVAR SubtractData = root:packages:SASDataModification:SubtractData
	NVAR SumData = root:packages:SASDataModification:SumData
	NVAR SubtractData2 = root:packages:SASDataModification:SubtractData2
	NVAR PassData1Through = root:packages:SASDataModification:PassData1Through
	NVAR PassData2Through = root:packages:SASDataModification:PassData2Through
	NVAR RescaleToNewQscale = root:packages:SASDataModification:RescaleToNewQscale
	NVAR SmoothInLogScale = root:packages:SASDataModification:SmoothInLogScale
	NVAR SmoothInLinScale = root:packages:SASDataModification:SmoothInLinScale
	NVAR SmoothSplines= root:packages:SASDataModification:SmoothSplines
	NVAR DivideData1byData2 = root:packages:SASDataModification:DivideData1byData2
	NVAR SubtractData2AndDivideByThem = root:packages:SASDataModification:SubtractData2AndDivideByThem
	NVAR ReducePointNumber=root:packages:SASDataModification:ReducePointNumber
	NVAR LogReducePointNumber=root:packages:SASDataModification:LogReducePointNumber

	if(cmpstr("CombineData", ctrlName)==0)
		if(checked)
			//CombineData=0
			SubtractData=0
			SumData=0
			SubtractData2=0
			PassData1Through=0
			PassData2Through=0
			RescaleToNewQscale=0
			DivideData1byData2=0
			SubtractData2AndDivideByThem=0	
			ReducePointNumber=0	
			LogReducePointNumber=0
		endif
	endif
	if(cmpstr("SubtractData", ctrlName)==0)
		if(checked)
			CombineData=0
			//SubtractData=0
			SumData=0
			SubtractData2=0
			PassData1Through=0
			PassData2Through=0
			RescaleToNewQscale=0
			DivideData1byData2=0
			SubtractData2AndDivideByThem=0		
			ReducePointNumber=0
			LogReducePointNumber=0
		endif
	endif
	if(cmpstr("SumData", ctrlName)==0)
		if(checked)
			CombineData=0
			SubtractData=0
			//SumData=0
			SubtractData2=0
			PassData1Through=0
			PassData2Through=0
			RescaleToNewQscale=0
			DivideData1byData2=0
			SubtractData2AndDivideByThem=0		
			ReducePointNumber=0
			LogReducePointNumber=0
		endif
	endif
	if(cmpstr("RescaleToNewQscale", ctrlName)==0)
		if(checked)
			CombineData=0
			SubtractData=0
			SumData=0
			SubtractData2=0
			PassData1Through=0
			PassData2Through=0
			//RescaleToNewQscale=0
			DivideData1byData2=0
			SubtractData2AndDivideByThem=0		
			ReducePointNumber=0
			LogReducePointNumber=0
		endif
	endif
	if(cmpstr("SubtractData2", ctrlName)==0)
		if(checked)
			CombineData=0
			SubtractData=0
			SumData=0
			//SubtractData2=0
			PassData1Through=0
			PassData2Through=0
			RescaleToNewQscale=0
			DivideData1byData2=0
			SubtractData2AndDivideByThem=0		
			ReducePointNumber=0
			LogReducePointNumber=0
		endif
	endif
	if(cmpstr("PassData1Through", ctrlName)==0)
		if(checked)
			CombineData=0
			SubtractData=0
			SumData=0
			SubtractData2=0
			//PassData1Through=0
			PassData2Through=0
			RescaleToNewQscale=0
			DivideData1byData2=0
			SubtractData2AndDivideByThem=0		
			ReducePointNumber=0
			LogReducePointNumber=0
		endif
	endif
	if(cmpstr("DivideData1byData2", ctrlName)==0)
		if(checked)
			CombineData=0
			SubtractData=0
			SumData=0
			SubtractData2=0
			PassData1Through=0
			PassData2Through=0
			RescaleToNewQscale=0
			//DivideData1byData2=0
			SubtractData2AndDivideByThem=0		
			ReducePointNumber=0
			LogReducePointNumber=0
		endif
	endif
	if(cmpstr("SubtractData2AndDivideByThem", ctrlName)==0)
		if(checked)
			CombineData=0
			SubtractData=0
			SumData=0
			SubtractData2=0
			PassData1Through=0
			PassData2Through=0
			RescaleToNewQscale=0
			DivideData1byData2=0
			//SubtractData2AndDivideByThem=0		
			ReducePointNumber=0
			LogReducePointNumber=0
		endif
	endif
	if(cmpstr("ReducePointNumber", ctrlName)==0)
		if(checked)
			CombineData=0
			SubtractData=0
			SumData=0
			SubtractData2=0
			PassData1Through=0
			PassData2Through=0
			RescaleToNewQscale=0
			DivideData1byData2=0
			SubtractData2AndDivideByThem=0		
			//ReducePointNumber=0
			LogReducePointNumber=0
		endif
	endif
	if(cmpstr("LogReducePointNumber", ctrlName)==0)
		if(checked)
			CombineData=0
			SubtractData=0
			SumData=0
			SubtractData2=0
			PassData1Through=0
			PassData2Through=0
			RescaleToNewQscale=0
			DivideData1byData2=0
			SubtractData2AndDivideByThem=0		
			ReducePointNumber=0
			//LogReducePointNumber=0
		endif
	endif
	if(cmpstr("PassData2Through", ctrlName)==0)
		if(checked)
			CombineData=0
			SubtractData=0
			SumData=0
			SubtractData2=0
			PassData1Through=0
			//PassData2Through=0
			RescaleToNewQscale=0
			DivideData1byData2=0
			SubtractData2AndDivideByThem=0		
			ReducePointNumber=0
			LogReducePointNumber=0
		endif
	endif

	if(cmpstr("SmoothInLogScale", ctrlName)==0)
		if(checked)
			SmoothInLinScale=0
			SmoothSplines=0
		endif
	endif
	if(cmpstr("SmoothInLinScale", ctrlName)==0)
		if(checked)
			SmoothInLogScale=0
			SmoothSplines=0
		endif
	endif
	if(cmpstr("SmoothSpline", ctrlName)==0)
		if(checked)
			SmoothInLogScale=0
			SmoothInLinScale=0
		endif
	endif

 //	 DoUpdate
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//popup procedure
Function IR1D_PanelPopupControl(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	SVAR DataFolderName1=root:Packages:SASDataModification:DataFolderName1
	SVAR IntensityWaveName1=root:Packages:SASDataModification:IntensityWaveName1
	SVAR QWavename1=root:Packages:SASDataModification:QWavename1
	SVAR ErrorWaveName1=root:Packages:SASDataModification:ErrorWaveName1

	SVAR DataFolderName2=root:Packages:SASDataModification:DataFolderName2
	SVAR IntensityWaveName2=root:Packages:SASDataModification:IntensityWaveName2
	SVAR QWavename2=root:Packages:SASDataModification:QWavename2
	SVAR ErrorWaveName2=root:Packages:SASDataModification:ErrorWaveName2

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:SASDataModification
		NVAR UseIndra2Data=root:Packages:SASDataModification:UseIndra2Data
		NVAR UseQRSData=root:Packages:SASDataModification:UseQRSdata
		SVAR Dtf=root:Packages:SASDataModification:DataFolderName
		SVAR IntDf=root:Packages:SASDataModification:IntensityWaveName
		SVAR QDf=root:Packages:SASDataModification:QWaveName
		SVAR EDf=root:Packages:SASDataModification:ErrorWaveName

//		IntDf=""
//		Dtf=""
//		QDf=""
//		EDf=""
	if (cmpstr(ctrlName,"SelectDataFolder")==0)
		//here we do what needs to be done when we select data folder
		Dtf=popStr
		PopupMenu IntensityDataName mode=1
		PopupMenu QvecDataName mode=1
		PopupMenu ErrorDataName mode=1
		if (UseIndra2Data)
			IntDf=stringFromList(0,IR1_ListIndraWavesForPopups("DSM_Int","SASDataModification",1,1))
			QDf=stringFromList(0,IR1_ListIndraWavesForPopups("DSM_Qvec","SASDataModification",1,1))
			EDf=stringFromList(0,IR1_ListIndraWavesForPopups("DSM_Error","SASDataModification",1,1))
			PopupMenu IntensityDataName value=IR1_ListIndraWavesForPopups("DSM_Int","SASDataModification",1,1)
			PopupMenu QvecDataName value=IR1_ListIndraWavesForPopups("DSM_Qvec","SASDataModification",1,1)
			PopupMenu ErrorDataName value=IR1_ListIndraWavesForPopups("DSM_Error","SASDataModification",1,1)
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
			PopupMenu IntensityDataName  value="---;"+IR1_ListOfWaves("DSM_Int","SASDataModification",1,1)
			PopupMenu QvecDataName  value="---;"+IR1_ListOfWaves("DSM_Qvec","SASDataModification",1,1)
			PopupMenu ErrorDataName  value="---;"+IR1_ListOfWaves("DSM_Error","SASDataModification",1,1)
		endif
		if(!UseQRSdata && !UseIndra2Data)
			IntDf=""
			QDf=""
			EDf=""
			PopupMenu IntensityDataName  value="---;"+IR1_ListOfWaves("DSM_Int","SASDataModification",0,0)
			PopupMenu QvecDataName  value="---;"+IR1_ListOfWaves("DSM_Qvec","SASDataModification",0,0)
			PopupMenu ErrorDataName  value="---;"+IR1_ListOfWaves("DSM_Error","SASDataModification",0,0)
		endif
		if (cmpstr(popStr,"---")==0)
			IntDf=""
			QDf=""
			EDf=""
			PopupMenu IntensityDataName  value="---"
			PopupMenu QvecDataName  value="---"
			PopupMenu ErrorDataName  value="---"
		endif
		DataFolderName1=Dtf
		IntensityWaveName1=IntDf
		QWavename1=QDf
		ErrorWaveName1=EDf
	endif
	

	if (cmpstr(ctrlName,"IntensityDataName")==0)
		//here goes what needs to be done, when we select this popup...
		if (cmpstr(popStr,"---")!=0)
			IntDf=popStr
			if (UseQRSData && strlen(QDf)==0 && strlen(EDf)==0)
				QDf="q"+popStr[1,inf]
				EDf="s"+popStr[1,inf]
				Wave/Z IsThereError=$(Dtf+possiblyquotename(EDf))
				if(WaveExists(IsThereError))
					Execute ("PopupMenu ErrorDataName mode=1, value=root:Packages:SASDataModification:ErrorWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Error\",\"SASDataModification\",0,1)")
				else
					EDf=""
				endif
				Execute ("PopupMenu QvecDataName mode=1, value=root:Packages:SASDataModification:QWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Qvec\",\"SASDataModification\",0,1)")
			elseif(UseIndra2Data)
				QDf=ReplaceString("Int", popStr, "Qvec")
				EDf=ReplaceString("Int", popStr, "Error")
				Execute ("PopupMenu QvecDataName mode=1, value=root:Packages:SASDataModification:QWaveName+\";---;\"+IR1_ListIndraWavesForPopups(\"DSM_Qvec\",\"SASDataModification\",1,1)")
				Execute ("PopupMenu ErrorDataName mode=1, value=root:Packages:SASDataModification:ErrorWaveName+\";---;\"+IR1_ListIndraWavesForPopups(\"DSM_Error\",\"SASDataModification\",1,1)")
			endif
		else
			IntDf=""
		endif
		IntensityWaveName1=IntDf
		QWavename1=QDf
		ErrorWaveName1=EDf
	endif

	if (cmpstr(ctrlName,"QvecDataName")==0)
		//here goes what needs to be done, when we select this popup...
		if (cmpstr(popStr,"---")!=0)
			QDf=popStr
			if (UseQRSData && strlen(IntDf)==0 && strlen(EDf)==0)
				IntDf="r"+popStr[1,inf]
				EDf="s"+popStr[1,inf]
				Execute ("PopupMenu IntensityDataName mode=1, value=root:Packages:SASDataModification:IntensityWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Int\",\"SASDataModification\",0,1)")
				Wave/Z IsThereError=$(Dtf+possiblyquotename(EDf))
				if(WaveExists(IsThereError))
					Execute ("PopupMenu ErrorDataName mode=1, value=root:Packages:SASDataModification:ErrorWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Error\",\"SASDataModification\",0,1)")
				else
					EDf=""
				endif
			elseif(UseIndra2Data)
				IntDf=ReplaceString("Qvec", popStr, "Int")
				EDf=ReplaceString("Qvec", popStr, "Error")
				Execute ("PopupMenu IntensityDataName mode=1, value=root:Packages:SASDataModification:IntensityWaveName+\";---;\"+IR1_ListIndraWavesForPopups(\"DSM_Int\",\"SASDataModification\",1,1)")
				Execute ("PopupMenu ErrorDataName mode=1, value=root:Packages:SASDataModification:ErrorWaveName+\";---;\"+IR1_ListIndraWavesForPopups(\"DSM_Error\",\"SASDataModification\",1,1)")
			endif
		else
			QDf=""
		endif
		IntensityWaveName1=IntDf
		QWavename1=QDf
		ErrorWaveName1=EDf
	endif
	
	if (cmpstr(ctrlName,"ErrorDataName")==0)
		//here goes what needs to be done, when we select this popup...
		if (cmpstr(popStr,"---")!=0)
			EDf=popStr
			if (UseQRSData && strlen(IntDf)==0 && strlen(QDf)==0)
				IntDf="r"+popStr[1,inf]
				QDf="q"+popStr[1,inf]
				Execute ("PopupMenu IntensityDataName mode=1, value=root:Packages:SASDataModification:IntensityWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Int\",\"SASDataModification\",0)")
				Execute ("PopupMenu QvecDataName mode=1, value=root:Packages:SASDataModification:QWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Qvec\",\"SASDataModification\",0)")
			elseif(UseIndra2Data)
				IntDf=ReplaceString("Error", popStr, "Int")
				Qdf=ReplaceString("Error", popStr, "Qvec")
				Execute ("PopupMenu IntensityDataName mode=1, value=root:Packages:SASDataModification:IntensityWaveName+\";---;\"+IR1_ListIndraWavesForPopups(\"DSM_Int\",\"SASDataModification\",1,1)")
				Execute ("PopupMenu QvecDataName mode=1, value=root:Packages:SASDataModification:QWaveName+\";---;\"+IR1_ListIndraWavesForPopups(\"DSM_Qvec\",\"SASDataModification\",1,1)")
			endif
		else
			EDf=""
		endif
		IntensityWaveName1=IntDf
		QWavename1=QDf
		ErrorWaveName1=EDf
	endif

	//ANd now the other population	
		NVAR UseIndra2Data2=root:Packages:SASDataModification:UseIndra2Data2
		NVAR UseQRSData2=root:Packages:SASDataModification:UseQRSdata2
		SVAR Dtf2=root:Packages:SASDataModification:DataFolderName2
		SVAR IntDf2=root:Packages:SASDataModification:IntensityWaveName2
		SVAR QDf2=root:Packages:SASDataModification:QWaveName2
		SVAR EDf2=root:Packages:SASDataModification:ErrorWaveName2
	if (cmpstr(ctrlName,"SelectDataFolder2")==0)
		//here we do what needs to be done when we select data folder
		Dtf2=popStr
		PopupMenu IntensityDataName2 mode=1
		PopupMenu QvecDataName2 mode=1
		PopupMenu ErrorDataName2 mode=1
		if (UseIndra2Data2)
			IntDf2=stringFromList(0,IR1_ListIndraWavesForPopups("DSM_Int","SASDataModification",1,2))
			QDf2=stringFromList(0,IR1_ListIndraWavesForPopups("DSM_Qvec","SASDataModification",1,2))
			EDf2=stringFromList(0,IR1_ListIndraWavesForPopups("DSM_Error","SASDataModification",1,2))
			PopupMenu IntensityDataName2 value=IR1_ListIndraWavesForPopups("DSM_Int","SASDataModification",1,2)
			PopupMenu QvecDataName2 value=IR1_ListIndraWavesForPopups("DSM_Qvec","SASDataModification",1,2)
			PopupMenu ErrorDataName2 value=IR1_ListIndraWavesForPopups("DSM_Error","SASDataModification",1,2)
		else
			IntDf2=""
			QDf2=""
			EDf2=""
			PopupMenu IntensityDataName2 value="---"
			PopupMenu QvecDataName2  value="---"
			PopupMenu ErrorDataName2  value="---"
		endif
		if(UseQRSdata2)
			IntDf2=""
			QDf2=""
			EDf2=""
			PopupMenu IntensityDataName2  value="---;"+IR1_ListOfWaves2("DSM_Int","SASDataModification",1,1)
			PopupMenu QvecDataName2  value="---;"+IR1_ListOfWaves2("DSM_Qvec","SASDataModification",1,1)
			PopupMenu ErrorDataName2  value="---;"+IR1_ListOfWaves2("DSM_Error","SASDataModification",1,1)
		endif
		if(!UseQRSdata2 && !UseIndra2Data2)
			IntDf2=""
			QDf2=""
			EDf2=""
			PopupMenu IntensityDataName2  value="---;"+IR1_ListOfWaves2("DSM_Int","SASDataModification",1,1)
			PopupMenu QvecDataName2  value="---;"+IR1_ListOfWaves2("DSM_Qvec","SASDataModification",1,1)
			PopupMenu ErrorDataName2  value="---;"+IR1_ListOfWaves2("DSM_Error","SASDataModification",1,1)
		endif
		if (cmpstr(popStr,"---")==0)
			IntDf2=""
			QDf2=""
			EDf2=""
			PopupMenu IntensityDataName2  value="---"
			PopupMenu QvecDataName2  value="---"
			PopupMenu ErrorDataName2  value="---"
		endif
		DataFolderName2=Dtf2
		IntensityWaveName2=IntDf2
		QWavename2=QDf2
		ErrorWaveName2=EDf2
	endif
	

	if (cmpstr(ctrlName,"IntensityDataName2")==0)
		//here goes what needs to be done, when we select this popup...
		if (cmpstr(popStr,"---")!=0)
			IntDf2=popStr
			if (UseQRSData2 && strlen(QDf2)==0 && strlen(EDf2)==0)
				QDf2="q"+popStr[1,inf]
				EDf2="s"+popStr[1,inf]
				Execute ("PopupMenu QvecDataName2 mode=1, value=root:Packages:SASDataModification:QWaveName2+\";---;\"+IR1_ListOfWaves2(\"DSM_Qvec\",\"SASDataModification\",2,1)")
				Wave/Z IsThereError2=$(Dtf2+possiblyquotename(EDf2))
				if(WaveExists(IsThereError2))
					Execute ("PopupMenu ErrorDataName2 mode=1, value=root:Packages:SASDataModification:ErrorWaveName2+\";---;\"+IR1_ListOfWaves2(\"DSM_Error\",\"SASDataModification\",2,1)")
				else
					EDf2=""
				endif
			elseif(UseIndra2Data2)
				QDf2=ReplaceString("Int", popStr, "Qvec")
				EDf2=ReplaceString("Int", popStr, "Error")
				Execute ("PopupMenu QvecDataName2 mode=1, value=root:Packages:SASDataModification:QWaveName2+\";---;\"+IR1_ListIndraWavesForPopups(\"DSM_Qvec\",\"SASDataModification\",1,2)")
				Execute ("PopupMenu ErrorDataName2 mode=1, value=root:Packages:SASDataModification:ErrorWaveName2+\";---;\"+IR1_ListIndraWavesForPopups(\"DSM_Error\",\"SASDataModification\",1,2)")
			endif
		else
			IntDf2=""
		endif
		IntensityWaveName2=IntDf2
		QWavename2=QDf2
		ErrorWaveName2=EDf2
	endif

	if (cmpstr(ctrlName,"QvecDataName2")==0)
		//here goes what needs to be done, when we select this popup...
		if (cmpstr(popStr,"---")!=0)
			QDf2=popStr
			if (UseQRSData2 && strlen(IntDf2)==0 && strlen(EDf2)==0)
				IntDf2="r"+popStr[1,inf]
				EDf2="s"+popStr[1,inf]
				Execute ("PopupMenu IntensityDataName2 mode=1, value=root:Packages:SASDataModification:IntensityWaveName2+\";---;\"+IR1_ListOfWaves2(\"DSM_Int\",\"SASDataModification\",2,1)")
				Wave/Z IsThereError2=$(Dtf2+possiblyquotename(EDf2))
				if(WaveExists(IsThereError2))
					Execute ("PopupMenu ErrorDataName2 mode=1, value=root:Packages:SASDataModification:ErrorWaveName2+\";---;\"+IR1_ListOfWaves2(\"DSM_Error\",\"SASDataModification\",2,1)")
				else
					EDf2=""
				endif
			elseif(UseIndra2Data2)
				IntDf2=ReplaceString("Qvec", popStr, "Int")
				EDf2=ReplaceString("Qvec", popStr, "Error")
				Execute ("PopupMenu IntensityDataName2 mode=1, value=root:Packages:SASDataModification:IntensityWaveName2+\";---;\"+IR1_ListIndraWavesForPopups(\"DSM_Int\",\"SASDataModification\",1,2)")
				Execute ("PopupMenu ErrorDataName2 mode=1, value=root:Packages:SASDataModification:ErrorWaveName2+\";---;\"+IR1_ListIndraWavesForPopups(\"DSM_Error\",\"SASDataModification\",1,2)")
			endif
		else
			QDf2=""
		endif
		IntensityWaveName2=IntDf2
		QWavename2=QDf2
		ErrorWaveName2=EDf2
	endif
	
	if (cmpstr(ctrlName,"ErrorDataName2")==0)
		//here goes what needs to be done, when we select this popup...
		if (cmpstr(popStr,"---")!=0)
			EDf2=popStr
			if (UseQRSData2 && strlen(QDf2)==0 && strlen(IntDf2)==0)
				IntDf2="r"+popStr[1,inf]
				QDf2="q"+popStr[1,inf]
				Execute ("PopupMenu IntensityDataName2 mode=1, value=root:Packages:SASDataModification:IntensityWaveName2+\";---;\"+IR1_ListOfWaves2(\"DSM_Int\",\"SASDataModification\",2,1)")
				Execute ("PopupMenu QvecDataName2 mode=1, value=root:Packages:SASDataModification:QWaveName2+\";---;\"+IR1_ListOfWaves2(\"DSM_Qvec\",\"SASDataModification\",2,1)")
			elseif(UseIndra2Data2)
				IntDf2=ReplaceString("Error", popStr, "Int")
				Qdf2=ReplaceString("Error", popStr, "Qvec")
				Execute ("PopupMenu IntensityDataName2 mode=1, value=root:Packages:SASDataModification:IntensityWaveName2+\";---;\"+IR1_ListIndraWavesForPopups(\"DSM_Int\",\"SASDataModification\",1,2)")
				Execute ("PopupMenu QvecDataName2 mode=1, value=root:Packages:SASDataModification:QWaveName2+\";---;\"+IR1_ListIndraWavesForPopups(\"DSM_Qvec\",\"SASDataModification\",1,2)")
			endif
		else
			EDf2=""
		endif
		IntensityWaveName2=IntDf2
		QWavename2=QDf2
		ErrorWaveName2=EDf2
	endif

	if (cmpstr(ctrlName,"SelectFolderNewData")==0)
		//here goes what needs to be done, when we select this popup...
		SVAR NewDataFolderName=root:Packages:SASDataModification:NewDataFolderName
		NewDataFolderName=popStr
	endif



end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1D_InitDataManipulation()


	string oldDf=GetDataFolder(1)
	string ListOfVariables
	string ListOfStrings
	variable i
	//First the ones needed in SASDataModification for compatibility
		
	if (!DataFolderExists("root:Packages:SASDataModification"))		//create folder
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:SASDataModification
	endif
	SetDataFolder root:Packages:SASDataModification					//go into the folder

	//here define the lists of variables and strings needed, separate names by ;...
	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;"
	ListOfStrings+="DataFolderName2;IntensityWaveName2;QWavename2;ErrorWaveName2;"
	ListOfVariables="UseIndra2Data;UseQRSdata;"
	ListOfVariables+="UseIndra2Data2;UseQRSdata2;"

	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
								
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	

	//here define the lists of variables and strings needed, separate names by ;...
	ListOfStrings="DataFolderName1;IntensityWaveName1;QWavename1;ErrorWaveName1;"
	ListOfStrings+="DataFolderName2;IntensityWaveName2;QWavename2;ErrorWaveName2;"
	ListOfStrings+="NewDataFolderName;NewIntensityWaveName;NewQWavename;NewErrorWaveName;"
	ListOfStrings+="Data1RemoveListofPnts;Data2RemoveListofPnts;"

	ListOfVariables="Data1RemoveSmallQ;Data1RemoveLargeQ;SmoothWindow;"
	ListOfVariables+="CombineData;SubtractData;SumData;RescaleToNewQscale;SmoothInLogScale;SmoothInLinScale;"
	ListOfVariables+="ReducePointNumber;ReducePointNumberBy;LogReducePointNumber;ReducePointNumberTo;LogReduceParam;"
	ListOfVariables+="Data2RemoveSmallQ;Data2RemoveLargeQ;"
	ListOfVariables+="Data1_IntMultiplier;Data1_ErrMultiplier;Data1_Qshift;Data1_Background;"
	ListOfVariables+="Data2_IntMultiplier;Data2_ErrMultiplier;Data2_Qshift;Data2_Background;"
	ListOfVariables+="PassData1Through;PassData2Through;SubtractData2;DivideData1byData2;SubtractData2AndDivideByThem;"
	ListOfVariables+="SmoothSplines;SmoothSplinesParam;"

	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
	
	NVAR ReducePointNumberBy
	if(ReducePointNumberBy<1)
		ReducePointNumberBy=1
	endif
	NVAR ReducePointNumberTo
	if(ReducePointNumberTo<1)
		ReducePointNumberTo=100
	endif
	NVAR LogReduceParam
	if(LogReduceParam<0.2)
		LogReduceParam=1
	endif



								
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	
	ListOfVariables="Data1_IntMultiplier;Data1_ErrMultiplier;"
	ListOfVariables+="Data2_IntMultiplier;Data2_ErrMultiplier;"
		//Set numbers to 1
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		NVAR test=$(StringFromList(i,ListOfVariables))
		test =1
	endfor		
	
	ListOfVariables="Data1_Qshift;Data1_Background;Data1RemoveSmallQ;"
	ListOfVariables+="Data2_Qshift;Data2_Background;Data2RemoveSmallQ;"
	ListOfVariables+="CombineData;SubtractData;SumData;RescaleToNewQscale;SmoothInLogScale;SmoothInLinScale;"
	ListOfVariables+="PassData1Through;SubtractData2;DivideData1byData2;SubtractData2AndDivideByThem;"
	//Set numbers to 0
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		NVAR test=$(StringFromList(i,ListOfVariables))
		test =0
	endfor		
	//set to inf
	ListOfVariables="Data1RemoveLargeQ;Data2RemoveLargeQ;"
	//Set numbers to 0
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		NVAR test=$(StringFromList(i,ListOfVariables))
		test =inf
	endfor		
	
	NVAR SmoothWindow
	SmoothWindow = 3

	ListOfStrings="DataFolderName1;IntensityWaveName1;QWavename1;ErrorWaveName1;"
	ListOfStrings+="DataFolderName2;IntensityWaveName2;QWavename2;ErrorWaveName2;"
	ListOfStrings+="NewDataFolderName;NewIntensityWaveName;NewQWavename;NewErrorWaveName;"
	ListOfStrings+="Data1RemoveListofPnts;Data2RemoveListofPnts;"
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		SVAR teststr=$(StringFromList(i,ListOfStrings))
		teststr =""
	endfor		

	Wave/Z KillWv1=root:Packages:SASDataModification:Intensity1
	Wave/Z KillWv2=root:Packages:SASDataModification:Qvector1
	Wave/Z KillWv3=root:Packages:SASDataModification:Error1
	Wave/Z KillWv4=root:Packages:SASDataModification:Intensity2
	Wave/Z KillWv5=root:Packages:SASDataModification:Qvector2
	Wave/Z KillWv6=root:Packages:SASDataModification:Error2

	Wave/Z KillWvO1=root:Packages:SASDataModification:OriginalIntensity1
	Wave/Z KillWvO2=root:Packages:SASDataModification:OriginalQvector1
	Wave/Z KillWvO3=root:Packages:SASDataModification:OriginalError1
	Wave/Z KillWvO4=root:Packages:SASDataModification:OriginalIntensity2
	Wave/Z KillWvO5=root:Packages:SASDataModification:OriginalQvector2
	Wave/Z KillWvO6=root:Packages:SASDataModification:OriginalError2
	
	KillWaves/Z KillWv1, KillWv2,KillWv3,KillWv4,KillWv5,KillWv6
	KillWaves/Z KillWvO1, KillWvO2,KillWvO3,KillWvO4,KillWvO5,KillWvO6
	
end


///******************************************************************************************
///******************************************************************************************
//             ***********          Data manipulation II - multiple data sets    *******************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR3M_DataManipulationII()

	IR3M_InitDataManipulationII()
	
	DoWindow DataManipulationII
	if(V_Flag)
		DoWindow/K DataManipulationII
	endif
	DoWindow ItemsInFolderPanel_DMII
	if(V_Flag)
		DoWindow/K ItemsInFolderPanel_DMII
	endif
	
	IR3M_DataManipulationIIPanel()
	
//	IR3M_SyncSearchListAndListBox()	//sync the list box... 
	IR3M_MakePanelWithListBox()	//and create the other panel... 

end

//**********************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


Function IR3M_DataManipulationIIPanel()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:DataManipulationII
	SVAR DataFolderName=root:Packages:DataManipulationII:DataFolderName
	DataFolderName="---"

	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(2.25,43.25,390,690) as "Data manipulation II"
	DoWindow/C DataManipulationII
	
	string AllowedIrenaTypes="DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;R_Int;"
	IR2C_AddDataControls("DataManipulationII","DataManipulationII",AllowedIrenaTypes,"AllCurrentlyAllowedTypes","","","","", 0,0)
		PopupMenu SelectDataFolder, pos={15,65 }, proc=IR3M_DataFolderPopMenuProc
		popupmenu QvecDataName, pos={500,500},disable=1
		popupmenu IntensityDataName, pos={500,500}, disable=1
		popupmenu ErrorDataName, pos={500,500}, disable=1
		popupmenu SelectDataFolder, title="Test data folder"
	SetDrawLayer UserBack
	SetDrawEnv fname= "Times New Roman", save
	SetDrawEnv fname= "Times New Roman",fsize= 22,fstyle= 3,textrgb= (0,0,52224)
	DrawText 50,23,"Data manipulation II panel"
	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
	DrawLine 16,100,339,100
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 18,49,"Test folder"
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 20,123,"Which data:"
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 3,325,"Processing:"
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 20,470,"Output Options:"
	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
	DrawLine 16,305,339,305
	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
	DrawLine 16,450,339,450



//Waves_Xtemplate;Waves_Ytemplate;Waves_Etemplate
	//Graph controls
	SVAR StartFolder
	PopupMenu StartFolder,pos={10,133},size={180,20},proc=IR3M_PanelPopupControl,title="Start Folder", help={"Select folder where to start. Only subfolders will be searched"}
	PopupMenu StartFolder,mode=(WhichListItem(StartFolder, IR3M_ListFoldersWithSubfolders("root:", 25))+1),value=  #"IR3M_ListFoldersWithSubfolders(\"root:\", 25)"
	SetVariable FolderMatchString,value= root:Packages:DataManipulationII:FolderMatchString,noProc, frame=1
	SetVariable FolderMatchString,pos={10,165},size={350,25},title="Folder Match String (\"*\" for all):", help={"String to match folder name to. \" * \" for all, \"XYZ*\" for folders staring XYZ, \"*XYZ\" for ending, etc..."}//, fSize=10,fstyle=1,labelBack=(65280,21760,0)

	SetVariable Waves_Xtemplate,variable= root:Packages:DataManipulationII:Waves_Xtemplate,noProc, frame=1
	SetVariable Waves_Xtemplate,pos={3,200},size={250,25},title="X data:", help={"Template for X data waves"}//, fSize=10,fstyle=1,labelBack=(65280,21760,0)
	SetVariable Waves_Ytemplate,variable= root:Packages:DataManipulationII:Waves_Ytemplate,noProc, frame=1
	SetVariable Waves_Ytemplate,pos={3,225},size={250,25},title="Y data:", help={"Template for Y data waves"}//, fSize=10,fstyle=1,labelBack=(65280,21760,0)
	SetVariable Waves_Etemplate,variable= root:Packages:DataManipulationII:Waves_Etemplate,noProc, frame=1
	SetVariable Waves_Etemplate,pos={3,250},size={250,25},title="Error data:", help={"Template for Error data waves"}//, fSize=10,fstyle=1,labelBack=(65280,21760,0)
	Button Waves_ReadX, pos={300,200},size={80,15},font="Times New Roman",fSize=10,proc=IR3M_DataManIIPanelButtonProc,title="Read X", help={"Read name from table"}
	Button Waves_ReadY, pos={300,225},size={80,15},font="Times New Roman",fSize=10,proc=IR3M_DataManIIPanelButtonProc,title="Read Y", help={"Read name from table"}
	Button Waves_ReadE, pos={300,250},size={80,15},font="Times New Roman",fSize=10,proc=IR3M_DataManIIPanelButtonProc,title="Read Error", help={"Read name from table"}


	Button PreviewListOfSelFolders, pos={25,275},size={120,20},font="Times New Roman",fSize=10,proc=IR3M_DataManIIPanelButtonProc,title="Preview selection", help={"Show selected folders in the panel"}

	CheckBox ManualFolderSelection,pos={200,278},size={80,14},proc= IR3M_DataMinerCheckProc,title="Enable Manual Folder Selection?"
	CheckBox ManualFolderSelection,variable= root:Packages:DataManipulationII:ManualFolderSelection, help={"Enable Select data in Listbox manually?"}

	//Waves notebook controls

//AverageWaves;GenerateStatisticsForAveWvs
	CheckBox AverageWaves,pos={15,335},size={80,14},title="Average Waves?",proc= IR3M_CheckProc
	CheckBox AverageWaves,variable= root:Packages:DataManipulationII:AverageWaves, help={"Average waves using Q values of the first selected wave"}
	NVAR AverageWaves = root:Packages:DataManipulationII:AverageWaves
	CheckBox GenerateStatisticsForAveWvs,pos={150,335},size={80,14},title="Generate Statistics For AveWvs?", proc= IR3M_CheckProc, disable=!(AverageWaves)
	CheckBox GenerateStatisticsForAveWvs,variable= root:Packages:DataManipulationII:GenerateStatisticsForAveWvs, help={"Generate Sdev of each point"}
//error decisions, ErrorUseStdDev;ErrorUseStdErOfMean
	NVAR GenerateStatisticsForAveWvs=root:Packages:DataManipulationII:GenerateStatisticsForAveWvs
	
	CheckBox GenerateMinMax,pos={10,355},size={80,14},title="Min/Max?", noproc, disable=!(GenerateStatisticsForAveWvs&&AverageWaves)
	CheckBox GenerateMinMax,variable= root:Packages:DataManipulationII:GenerateMinMax, help={"Generate Sdev of each point?"}, mode=0
	CheckBox ErrorUseStdDev,pos={120,355},size={80,14},title="Std Deviation?", proc= IR3M_CheckProc, disable=!(GenerateStatisticsForAveWvs&&AverageWaves)
	CheckBox ErrorUseStdDev,variable= root:Packages:DataManipulationII:ErrorUseStdDev, help={"Generate Sdev of each point?"}, mode=1
	CheckBox ErrorUseStdErOfMean,pos={250,355},size={80,14},title="Std Dev of Mean?", proc= IR3M_CheckProc, disable=!(GenerateStatisticsForAveWvs&&AverageWaves)
	CheckBox ErrorUseStdErOfMean,variable= root:Packages:DataManipulationII:ErrorUseStdErOfMean, help={"Generate Standard error of mean of each point?"}, mode=1
//Subtract one data set from all	
	CheckBox SubtractDataFromAll,pos={170,310},size={80,14},title="Subtract Data?",proc= IR3M_CheckProc
	CheckBox SubtractDataFromAll,variable= root:Packages:DataManipulationII:SubtractDataFromAll, help={"Subtract one set of data from all"}
	NVAR SubtractDataFromAll = root:Packages:DataManipulationII:SubtractDataFromAll
	
	//Experimental data input
	NewPanel /W=(0,325,398,448) /HOST=# /N=SubDta
	ModifyPanel cbRGB=(52428,52428,52428), frameStyle=1
	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup=""
	string EUserLookup=""
	IR2C_AddDataControls("SASDataModIISubDta","DataManipulationII#SubDta","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","AllCurrentlyAllowedTypes",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,1)
	SetDrawLayer UserBack
	SetDrawEnv fname= "Times New Roman",fsize= 22,fstyle= 3,textrgb= (0,0,52224)
	SetDrawEnv fsize= 12,fstyle= 1
	DrawText 10,25,"First data set"
	Checkbox UseIndra2Data, pos={90,10}
	Checkbox UseResults, pos={266,10}
	Checkbox UseModelData, disable=1
	checkbox UseQRSData, pos={180,10}
	popupMenu SelectDataFolder, pos={10,28} 
	popupMenu QvecDataName, pos={10,48}
	popupMenu IntensityDataName, pos={10,72}
	popupMenu ErrorDataName, pos={10,95}
	setVariable Qmin, disable=1
	setVariable Qmax, disable=1
	setVariable QNumPoints, disable=1
	Checkbox QlogScale, disable=1
	
	SetActiveSubwindow ##
	NVAR SubtractDataFromAll = root:Packages:DataManipulationII:SubtractDataFromAll
	
	SetWindow DataManipulationII#SubDta , hide =!SubtractDataFromAll
	
//DisplayResults;DisplaySourceData;
	CheckBox DisplayResults,pos={10,472},size={80,14},title="Plot Result?",noproc//,proc= IR2M_DataMinerCheckProc
	CheckBox DisplayResults,variable= root:Packages:DataManipulationII:DisplayResults, help={"Display Graph with the reuslt of processing"}
	CheckBox DisplaySourceData,pos={130,472},size={80,14},title="Plot Source data?",noproc//,proc= IR2M_DataMinerCheckProc
	CheckBox DisplaySourceData,variable= root:Packages:DataManipulationII:DisplaySourceData, help={"Display Graph with the source waves of processing"}
	


//ResultsDataFolderName;ResultsIntWaveName;ResultsQvecWaveName;ResultsErrWaveName;
	SetVariable NameModifier,variable= root:Packages:DataManipulationII:NameModifier,proc=IR3M_SetVarProc, frame=1
	SetVariable NameModifier,pos={200,452},size={170,16},title="Append to name:", help={"Name Modifier"}//, fSize=10,fstyle=1,labelBack=(65280,21760,0)

	SetVariable ResultsDataFolderName,variable= root:Packages:DataManipulationII:ResultsDataFolderName,noProc, frame=1
	SetVariable ResultsDataFolderName,pos={3,490},size={350,25},title="New Folder name:    ", help={"Folder to save New Data to"}//, fSize=10,fstyle=1,labelBack=(65280,21760,0)
	SetVariable ResultsQvecWaveName,variable= root:Packages:DataManipulationII:ResultsQvecWaveName,noProc, frame=1
	SetVariable ResultsQvecWaveName,pos={3,510},size={350,25},title="New X data name:    ", help={"Results Q Wave name"}//, fSize=10,fstyle=1,labelBack=(65280,21760,0)
	SetVariable ResultsIntWaveName,variable= root:Packages:DataManipulationII:ResultsIntWaveName,noProc, frame=1
	SetVariable ResultsIntWaveName,pos={3,530},size={350,25},title="New Y data name:    ", help={"Results Intensity Wave name"}//, fSize=10,fstyle=1,labelBack=(65280,21760,0)
	SetVariable ResultsErrWaveName,variable= root:Packages:DataManipulationII:ResultsErrWaveName,noProc, frame=1
	SetVariable ResultsErrWaveName,pos={3,550},size={350,25},title="New Err data name:  ", help={"Results Error wave name"}//, fSize=10,fstyle=1,labelBack=(65280,21760,0)

//	ListOfVariables+="GraphLogX;GraphLogY;GraphColorScheme1;GraphColorScheme2;GraphColorScheme3;"
	CheckBox GraphLogX,pos={15,570},size={80,14},proc= IR3M_DataMinerCheckProc,title="log X axis?"
	CheckBox GraphLogX,variable= root:Packages:DataManipulationII:GraphLogX, help={"Graph with log X axis"}
	CheckBox GraphLogY,pos={15,590},size={80,14},proc= IR3M_DataMinerCheckProc,title="log Y axis?"
	CheckBox GraphLogY,variable= root:Packages:DataManipulationII:GraphLogY, help={"Graph with log Y axis"}

	CheckBox GraphColorScheme1,pos={115,570},size={80,14},proc= IR3M_DataMinerCheckProc,title="Color scheme 1?", mode=1
	CheckBox GraphColorScheme1,variable= root:Packages:DataManipulationII:GraphColorScheme1, help={"One of preselected color schemes for graph"}
	CheckBox GraphColorScheme2,pos={115,590},size={80,14},proc= IR3M_DataMinerCheckProc,title="Color scheme 2?", mode=1
	CheckBox GraphColorScheme2,variable= root:Packages:DataManipulationII:GraphColorScheme2, help={"One of preselected color schemes for graph"}
	CheckBox GraphColorScheme3,pos={255,570},size={80,14},proc= IR3M_DataMinerCheckProc,title="Color scheme 3?", mode=1
	CheckBox GraphColorScheme3,variable= root:Packages:DataManipulationII:GraphColorScheme3, help={"One of preselected color schemes for graph"}
	NVAR GraphFontSize=root:Packages:DataManipulationII:GraphFontSize
	PopupMenu GraphFontSize,pos={235,590},size={180,20},proc=IR3M_PanelPopupControl,title="Legend font size", help={"Select font size for legend to be used."}
	PopupMenu GraphFontSize,mode=WhichListItem(num2str(GraphFontSize),  "6;8;10;12;14;16;18;20;22;24;")+1,value= "06;08;10;12;14;16;18;20;22;24;"//, popvalue="10"

	Button ProcessData, pos={10,615},size={180,20},font="Times New Roman",fSize=10,proc=IR3M_DataManIIPanelButtonProc,title="Process data", help={"Run the processing as per choices above"}
	Button SaveDataBtn, pos={200,615},size={180,20},font="Times New Roman",fSize=10,proc=IR3M_DataManIIPanelButtonProc,title="Save data", help={"Save the processed data as per choices above"}
//	IR2M_FixPanelControls()
	setDataFolder oldDF
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR3M_SetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			if(stringmatch(sva.ctrlName,"NameModifier"))
				SVAR NameModifier= root:Packages:DataManipulationII:NameModifier
				NameModifier = sval[0,5]
				IR3M_PresetOutputWvsNms()
			endif	
			break
	endswitch

	return 0
End

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function  IR3M_DataMinerCheckProc(CB_Struct) : CheckBoxControl
	STRUCT WMCheckboxAction &CB_Struct
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:DataManipulationII


	if(CB_Struct.eventCode ==2)
		if(stringmatch(CB_Struct.ctrlName,"ManualFolderSelection") )
			Wave SelectedFoldersWv=root:Packages:DataManipulationII:SelectedFoldersWv
			if(CB_Struct.checked)
				ListBox SelectedWaves win=ItemsInFolderPanel_DMII, mode=10
			else
				ListBox SelectedWaves win=ItemsInFolderPanel_DMII, mode=0
				SelectedFoldersWv=1
			endif
		endif
		NVAR GraphColorScheme1=root:Packages:DataManipulationII:GraphColorScheme1
		NVAR GraphColorScheme2=root:Packages:DataManipulationII:GraphColorScheme2
		NVAR GraphColorScheme3=root:Packages:DataManipulationII:GraphColorScheme3
		if(stringmatch(CB_Struct.ctrlName,"GraphLogX") )
			IR3M_FormatManIIGraph()
		endif		
		if(stringmatch(CB_Struct.ctrlName,"GraphLogY") )
			IR3M_FormatManIIGraph()
		endif		
		if(stringmatch(CB_Struct.ctrlName,"GraphColorScheme1") )
			if(CB_Struct.checked)
			//	GraphColorScheme1 = 
				GraphColorScheme2 =0
				GraphColorScheme3 =0
			endif
			IR3M_FormatManIIGraph()
		endif		
		if(stringmatch(CB_Struct.ctrlName,"GraphColorScheme2") )
			if(CB_Struct.checked)
				GraphColorScheme1 = 0
			//	GraphColorScheme2 =0
				GraphColorScheme3 =0
			endif
			IR3M_FormatManIIGraph()
		endif		
		if(stringmatch(CB_Struct.ctrlName,"GraphColorScheme3") )
			if(CB_Struct.checked)
				GraphColorScheme1 = 0
				GraphColorScheme2 =0
			//	GraphColorScheme3 =0
			endif
			IR3M_FormatManIIGraph()
		endif		
//		DoAlert 0, "Need to create Panel with Listbox and enable manual data selection"
	endif
	setDataFolder oldDF
	
End


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR3M_CheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			if(stringmatch(cba.CtrlName, "GenerateStatisticsForAveWvs"))
				CheckBox ErrorUseStdDev win=DataManipulationII, disable=!checked
				CheckBox ErrorUseStdErOfMean win=DataManipulationII, disable=!checked
				CheckBox GenerateMinMax win=DataManipulationII,disable=!(checked)
			endif
			if(stringmatch(cba.CtrlName, "ErrorUseStdDev"))
				NVAR ErrorUseStdDev= root:Packages:DataManipulationII:ErrorUseStdDev
				NVAR ErrorUseStdErOfMean = root:Packages:DataManipulationII:ErrorUseStdErOfMean
				ErrorUseStdErOfMean=!ErrorUseStdDev
			endif			
			if(stringmatch(cba.CtrlName,"ErrorUseStdErOfMean"))
				NVAR ErrorUseStdDev= root:Packages:DataManipulationII:ErrorUseStdDev
				NVAR ErrorUseStdErOfMean = root:Packages:DataManipulationII:ErrorUseStdErOfMean
				ErrorUseStdDev=!ErrorUseStdErOfMean
			endif			
				NVAR SubtractDataFromAll = root:Packages:DataManipulationII:SubtractDataFromAll
				NVAR AverageWaves = root:Packages:DataManipulationII:AverageWaves
				NVAR GenerateStatisticsForAveWvs=root:Packages:DataManipulationII:GenerateStatisticsForAveWvs
			if(stringmatch(cba.CtrlName,"AverageWaves"))
				CheckBox GenerateStatisticsForAveWvs , win=DataManipulationII,disable=!(AverageWaves)
				CheckBox ErrorUseStdDev, win=DataManipulationII, disable=!(GenerateStatisticsForAveWvs&&AverageWaves)
				CheckBox ErrorUseStdErOfMean win=DataManipulationII,disable=!(GenerateStatisticsForAveWvs&&AverageWaves)
				CheckBox GenerateMinMax win=DataManipulationII,disable=!(GenerateStatisticsForAveWvs&&AverageWaves)
				if(checked)
					SubtractDataFromAll=0
				endif
			endif			
			
			if(stringmatch(cba.CtrlName,"SubtractDataFromAll")&& SubtractDataFromAll)
				SetWindow DataManipulationII#SubDta , hide =0
				AverageWaves = 0
				GenerateStatisticsForAveWvs = 0
				CheckBox GenerateStatisticsForAveWvs , win=DataManipulationII,disable=1
				CheckBox ErrorUseStdDev, win=DataManipulationII, disable=1
				CheckBox ErrorUseStdErOfMean win=DataManipulationII,disable=1
				CheckBox GenerateMinMax win=DataManipulationII,disable=1
				CheckBox AverageWaves win=DataManipulationII,disable=1
			else
				SetWindow DataManipulationII#SubDta , hide =1
				CheckBox AverageWaves win=DataManipulationII,disable=0
				CheckBox GenerateStatisticsForAveWvs , win=DataManipulationII,disable=!(AverageWaves)
				CheckBox ErrorUseStdDev, win=DataManipulationII, disable=!(GenerateStatisticsForAveWvs&&AverageWaves)
				CheckBox ErrorUseStdErOfMean win=DataManipulationII,disable=!(GenerateStatisticsForAveWvs&&AverageWaves)
				CheckBox GenerateMinMax win=DataManipulationII,disable=!(GenerateStatisticsForAveWvs&&AverageWaves)
			endif


			break
	endswitch

	return 0
End
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function/S IR3M_ListFoldersWithSubfolders(startDF, levels)
        String startDF               // startDF requires trailing colon.
        Variable levels		//set 1 for long type and 0 for short type return
        			// 
        String dfSave
        String list = "", templist, tempWvName, tempWaveType
        variable i, skipRest, j
        
        dfSave = GetDataFolder(1)
  	
  	if (!DataFolderExists(startDF))
  		return ""
  	endif
  	
        SetDataFolder startDF
        
        templist = DataFolderDir(1)
	templist=templist[8,strlen(templist)-3]
	if(strlen(tempList)>0)
		list=GetDataFolder(1)+";"
	endif
        levels -= 1
        if (levels <= 0)
                return list
        endif
        
        String subDF
        Variable index = 0
        do
                String temp
                temp = PossiblyQuoteName(GetIndexedObjName(startDF, 4, index))     	// Name of next data folder.
                if (strlen(temp) == 0)
                        break                                                                           			// No more data folders.
                endif
     	              subDF = startDF + temp + ":"
            		 list += IR3M_ListFoldersWithSubfolders(subDF, levels)       	// Recurse.
                index += 1
        while(1)
        
        SetDataFolder(dfSave)
        return list
End
//**********************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
//popup procedure
Function IR3M_PanelPopupControl(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:DataManipulationII

	NVAR GraphFontSize=root:Packages:DataManipulationII:GraphFontSize

	if (cmpstr(ctrlName,"GraphFontSize")==0)
		GraphFontSize=str2num(popStr)
		IR3M_AppendLegend()
	endif
	if (cmpstr(ctrlName,"StartFolder")==0)
		SVAR StartFolder
		StartFolder=popStr
	endif
	
	
	setDataFolder oldDF
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR3M_DataManIIPanelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:DataManipulationII

	if(cmpstr(ctrlName,"Waves_ReadX")==0)
		IR3M_ReadWavesFromListBox("Waves_X")
	endif
	if(cmpstr(ctrlName,"Waves_ReadY")==0)
		IR3M_ReadWavesFromListBox("Waves_Y")
	endif
	if(cmpstr(ctrlName,"Waves_ReadE")==0)
		IR3M_ReadWavesFromListBox("Waves_E")
	endif

	if(cmpstr(ctrlName,"ProcessData")==0)
		IR3M_ProcessTheDataFunction()
	endif
	if(cmpstr(ctrlName,"PreviewListOfSelFolders")==0)
		IR3M_PreviewListOfSelFolders()
		IR3M_PresetOutputWvsNms()
	endif
	if(cmpstr(ctrlName,"SelectAll")==0)
		NVAR ManualFolderSelection = root:Packages:DataManipulationII:ManualFolderSelection
		if(ManualFolderSelection)
			Wave selWave=root:Packages:DataManipulationII:SelectedFoldersWv
			selWave=1
		endif
	endif
	if(cmpstr(ctrlName,"deSelectAll")==0)
		NVAR ManualFolderSelection = root:Packages:DataManipulationII:ManualFolderSelection
		if(ManualFolderSelection)
			Wave selWave=root:Packages:DataManipulationII:SelectedFoldersWv
			selWave=0
		endif
	endif
	if(cmpstr(ctrlName,"SaveDataBtn")==0)
			IR3M_SaveProcessedData()
	endif
	setDataFolder oldDF
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR3M_PresetOutputWvsNms()
	
	SVAR ResultsDataFolderName = root:Packages:DataManipulationII:ResultsDataFolderName
	SVAR ResultsIntWaveName = root:Packages:DataManipulationII:ResultsIntWaveName
	SVAR ResultsQvecWaveName = root:Packages:DataManipulationII:ResultsQvecWaveName
	SVAR ResultsErrWaveName = root:Packages:DataManipulationII:ResultsErrWaveName
	SVAR NameModifier=root:Packages:DataManipulationII:NameModifier

	SVAR DataFolderName = root:Packages:DataManipulationII:DataFolderName
	SVAR Waves_Ytemplate = root:Packages:DataManipulationII:Waves_Ytemplate
	SVAR Waves_Xtemplate = root:Packages:DataManipulationII:Waves_Xtemplate
	SVAR Waves_Etemplate = root:Packages:DataManipulationII:Waves_Etemplate
	SVAR IntensityWaveName = root:Packages:DataManipulationII:IntensityWaveName
	SVAR QWavename = root:Packages:DataManipulationII:QWavename
	SVAR ErrorWaveName = root:Packages:DataManipulationII:ErrorWaveName
	//May be better use start data folder here?
	//SVAR DataFolderName =root:Packages:DataManipulationII:StartFolder
	//Or may be not... 
	NVAR UseIndra2Data=root:Packages:DataManipulationII:UseIndra2Data
	string StartPath=RemoveFromList(StringFromList(ItemsInList(DataFolderName,":")-1,DataFolderName,":"), DataFolderName  , ":")
	string endpath = IN2G_RemoveExtraQuote(StringFromList(ItemsInList(DataFolderName,":")-1,DataFolderName,":"),1,1)
	ResultsDataFolderName =StartPath+ possiblyQuoteName( endpath[0,25]+NameModifier)
	if(UseIndra2Data)
		ResultsIntWaveName  = IntensityWaveName
		ResultsQvecWaveName = QWavename
		ResultsErrWaveName =  ErrorWaveName
	else
		ResultsIntWaveName  = IntensityWaveName[0,25]+NameModifier
		ResultsQvecWaveName = QWavename[0,25]+NameModifier
		ResultsErrWaveName =  ErrorWaveName[0,25]+NameModifier
	endif
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR3M_ReadWavesFromListBox(which)
	string which
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:DataManipulationII
	Wave/T ItemsInFolder
	
	if(cmpstr(which,"Waves_X")==0)
		SVAR Waves_Xtemplate=root:Packages:DataManipulationII:Waves_Xtemplate
		ControlInfo  /W=ItemsInFolderPanel_DMII ItemsInCurrentFolder
		Waves_Xtemplate = ItemsInFolder[V_Value]
	endif
	if(cmpstr(which,"Waves_Y")==0)
		SVAR Waves_Ytemplate=root:Packages:DataManipulationII:Waves_Ytemplate
		ControlInfo  /W=ItemsInFolderPanel_DMII ItemsInCurrentFolder
		Waves_Ytemplate = ItemsInFolder[V_Value]
	endif
	if(cmpstr(which,"Waves_E")==0)
		SVAR Waves_Etemplate=root:Packages:DataManipulationII:Waves_Etemplate
		ControlInfo  /W=ItemsInFolderPanel_DMII ItemsInCurrentFolder
		Waves_Etemplate = ItemsInFolder[V_Value]
	endif
	
	
	setDataFolder oldDF	
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR3M_PreviewListOfSelFolders()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:DataManipulationII
	Wave/T PreviewSelectedFolder =root:Packages:DataManipulationII:PreviewSelectedFolder
	Redimension/N=0 PreviewSelectedFolder
	SVAR StartFolder = root:Packages:DataManipulationII:StartFolder
	IN2G_UniversalFolderScan(StartFolder, 25, "IR3M_FindListOfFolders()")

	Wave SelectedFoldersWv=root:Packages:DataManipulationII:SelectedFoldersWv
	redimension/n=(numpnts(PreviewSelectedFolder)) SelectedFoldersWv
	NVAR ManualSelection=root:Packages:DataManipulationII:ManualFolderSelection
	if(ManualSelection==0)
		SelectedFoldersWv=1
	else
		SelectedFoldersWv=0
	endif
	setDataFolder oldDF

end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR3M_FindListOfFolders()
	
	SVAR Waves_Xtemplate=root:Packages:DataManipulationII:Waves_Xtemplate
	SVAR Waves_Ytemplate=root:Packages:DataManipulationII:Waves_Ytemplate
	SVAR Waves_Etemplate=root:Packages:DataManipulationII:Waves_Etemplate

	SVAR FolderMatchString=root:Packages:DataManipulationII:FolderMatchString

	Wave/T PreviewSelectedFolder =root:Packages:DataManipulationII:PreviewSelectedFolder

	string curFolder=GetDataFolder(0)
	string ListOfAllWaves="", ListOfXWaves="", ListOfYWaves="", ListOfEWaves="", curName=""
	variable i

	//need to deal with two cases. Number one is case when full names are given, number two is when partial name and * are given...

	//first check that the folder is selected by user to deal with
	if(!stringmatch(curFolder, FolderMatchString ))
		return 1
	endif
	
	//Now we can start dealing with this
	if(strsearch(Waves_Xtemplate, "*", 0)<0 && strsearch(Waves_Ytemplate, "*", 0)<0  && strsearch(Waves_Etemplate, "*", 0)<0 )
	//no * in any of the names
				Wave/Z testX=$(Waves_Xtemplate)
				Wave/Z testY=$(Waves_Ytemplate)
				Wave/Z testE=$(Waves_Etemplate)
			
				if(strlen(Waves_Etemplate)>0)
					if(WaveExists(testX) && WaveExists(testY) && WaveExists(testE))
						Redimension/N=(numpnts(PreviewSelectedFolder)+1) PreviewSelectedFolder
						PreviewSelectedFolder[numpnts(PreviewSelectedFolder)]=GetDataFolder(1)
					endif
				else
					if(WaveExists(testX) && WaveExists(testY))
						Redimension/N=(numpnts(PreviewSelectedFolder)+1) PreviewSelectedFolder
						PreviewSelectedFolder[numpnts(PreviewSelectedFolder)]=GetDataFolder(1)
					endif
				endif	
	else		//User wants to find partially defined waves. Much more trouble...
		//OK, let's figure out, which all waves should be ploted...
		ListOfAllWaves = stringFromList(1,DataFolderDir(2),":")
		ListOfAllWaves = ListOfAllWaves[0,strlen(ListOfAllWaves)-3]+","
		if(strlen(ListOfAllWaves)>0)
			For(i=0;i<ItemsInList(ListOfAllWaves,",");i+=1)
				curName = StringFromList(i,ListOfAllWaves,",")
				if(stringmatch(curName,Waves_Xtemplate))
					ListOfXWaves+=curName+";"
				endif
				if(stringmatch(curName,Waves_Ytemplate))
					ListOfYWaves+=curName+";"
				endif
				if(stringmatch(curName,Waves_Etemplate))
					ListOfEWaves+=curName+";"
				endif
			endfor
			//Note, for now... This can miserably fail and assign wave together, which do not belong together.
			//there is no gurrantee, that this will not assign wrong "ends/starts" together...
			//but at least we need to run this for cases when we find same number for each X and Y and when we have just one X and many Y
			if(ItemsInList(ListOfXWaves)==1)
				For(i=0;i<ItemsInList(ListOfYWaves);i+=1)
					Wave/Z testX=$(stringFromList(0,ListOfXWaves))
					Wave/Z testY=$(stringFromList(i,ListOfYWaves))
					Wave/Z testE=$(stringFromList(i,ListOfEWaves))
				
					if(strlen(Waves_Etemplate)>0)
						if(WaveExists(testX) && WaveExists(testY) && WaveExists(testE))
							Redimension/N=(numpnts(PreviewSelectedFolder)+1) PreviewSelectedFolder
							PreviewSelectedFolder[numpnts(PreviewSelectedFolder)]=GetDataFolder(1)
						endif
					else
						if(WaveExists(testX) && WaveExists(testY))
							Redimension/N=(numpnts(PreviewSelectedFolder)+1) PreviewSelectedFolder
							PreviewSelectedFolder[numpnts(PreviewSelectedFolder)]=GetDataFolder(1)
						endif
					endif	
				endfor
			else
				For(i=0;i<ItemsInList(ListOfXWaves);i+=1)
					Wave/Z testX=$(stringFromList(i,ListOfXWaves))
					Wave/Z testY=$(stringFromList(i,ListOfYWaves))
					Wave/Z testE=$(stringFromList(i,ListOfEWaves))
				
					if(strlen(Waves_Etemplate)>0)
						if(WaveExists(testX) && WaveExists(testY) && WaveExists(testE))
							Redimension/N=(numpnts(PreviewSelectedFolder)+1) PreviewSelectedFolder
							PreviewSelectedFolder[numpnts(PreviewSelectedFolder)]=GetDataFolder(1)
						endif
					else
						if(WaveExists(testX) && WaveExists(testY))
							Redimension/N=(numpnts(PreviewSelectedFolder)+1) PreviewSelectedFolder
							PreviewSelectedFolder[numpnts(PreviewSelectedFolder)]=GetDataFolder(1)
						endif
					endif	
				endfor
			endif
		endif
	endif
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR3M_ProcessTheDataFunction()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:DataManipulationII
	//here we prepare teh list of folders and waves to process... 
	variable NumWavesToProcess
//	String ListOfFldersToProcess
	// first we need to figure out, if we are running automatically (and then should update the list of folders to process) 
	//or manually, in which case we just use what is selected in the selection...
	NVAR ManualFolderSelection = root:Packages:DataManipulationII:ManualFolderSelection
	if(!ManualFolderSelection)
		//this should update the selection, safe only if automatic processing...
		IR3M_PreviewListOfSelFolders()
	//	IR3M_PresetOutputWvsNms()
	endif
	//These are further important data...
	SVAR Xtmplt=root:Packages:DataManipulationII:Waves_Xtemplate
	SVAR Ytmplt=root:Packages:DataManipulationII:Waves_Ytemplate
	SVAR Etmplt=root:Packages:DataManipulationII:Waves_Etemplate
	SVAR FolderMatchString=root:Packages:DataManipulationII:FolderMatchString
	SVAR OutFldrNm = root:Packages:DataManipulationII:ResultsDataFolderName
	SVAR OutYWvNm=root:Packages:DataManipulationII:ResultsIntWaveName
	SVAR OutXWvNm=root:Packages:DataManipulationII:ResultsQvecWaveName
	SVAR OutEWvNm=root:Packages:DataManipulationII:ResultsErrWaveName
	//and now these also should exist and be present.
	Wave/T FldrNamesTWv =root:Packages:DataManipulationII:PreviewSelectedFolder
	Wave SelFldrs = root:Packages:DataManipulationII:SelectedFoldersWv
	//they are either defined by user or defined by automatic routine. They can be passed further into routines we need. 
	//What actually we want to do???
	NVAR AverageWaves = root:Packages:DataManipulationII:AverageWaves
	NVAR UseStdDev = root:Packages:DataManipulationII:ErrorUseStdDev
	NVAR UseSEM = root:Packages:DataManipulationII:ErrorUseStdErOfMean
	NVAR UseMinMax = root:Packages:DataManipulationII:GenerateMinMax
		
	NVAR SubtractDataFromAll = root:Packages:DataManipulationII:SubtractDataFromAll	
		
	if(AverageWaves)
		//call average waves routine. Let's create the routine as folder/parameters agnostic to be able to be reused... 
		IR3M_AverageMultipleWaves(FldrNamesTWv,SelFldrs,Xtmplt,Ytmplt,Etmplt,OutFldrNm,OutXWvNm, OutYWvNm,OutEWvNm,UseStdDev,UseSEM, UseMinMax)
		Wave AveragedDataXwave
		Wave AveragedDataYwave
		Wave AveragedDataEwave
		Wave/Z AveragedDataYwaveMin
		Wave/Z AveragedDataYwaveMax
		Duplicate/O AveragedDataXwave, ManipIIProcessedDataX
		Duplicate/O AveragedDataYwave, ManipIIProcessedDataY
		Duplicate/O AveragedDataEwave, ManipIIProcessedDataE
		if(WaveExists(AveragedDataYwaveMin))
			Duplicate/O AveragedDataYwaveMin, ManipIIProcessedDataYMin
		endif
		if(WaveExists(AveragedDataYwaveMax))
			Duplicate/O AveragedDataYwaveMax, ManipIIProcessedDataYMax
		endif
	elseif(SubtractDataFromAll)
		SVAR SubFldrNm = root:Packages:SASDataModIISubDta:DataFolderName
		SVAR SubYWvNm = root:Packages:SASDataModIISubDta:IntensityWaveName
		SVAR SubXWvNm = root:Packages:SASDataModIISubDta:QWavename
		SVAR SubEWvNm = root:Packages:SASDataModIISubDta:ErrorWaveName
		Wave/Z SubtrWvX = $(SubFldrNm+SubXWvNm)
		Wave/Z SubtrWvY = $(SubFldrNm+SubYWvNm)
		if(!WaveExists(SubtrWvX)||!WaveExists(SubtrWvY))
			abort "Bad call to Subtract waves, selected wave to subtract does not exists"
		endif
		Wave/Z SubtrWvE= $(SubFldrNm+SubEWvNm)
		if(!WaveExists(SubtrWvE))
			Duplicate/O SubtrWvY, SubtrWvE
			Wave SubtrWvE
			SubtrWvE=0
		endif
		IR3M_SubtractWave(FldrNamesTWv,SelFldrs,SubtrWvX,SubtrWvY,SubtrWvE,Xtmplt,Ytmplt,Etmplt)
		
	endif
	
	KillWaves/Z AveragedDataXwave, AveragedDataYwave, AveragedDataEwave, AveragedDataYwaveMin, AveragedDataYwaveMax
	
	IR3M_DisplayDataManipII()	
	setDataFolder oldDF

end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR3M_SubtractWave(FldrNamesTWv,SelFldrs,SubtrWvX,SubtrWvY,SubtrWvE,Xtmplt,Ytmplt,Etmplt)
	Wave/T FldrNamesTWv
	Wave SelFldrs, SubtrWvX,SubtrWvY,SubtrWvE
	String Xtmplt,Ytmplt,Etmplt
	//for other uses, here is the parameters description:
	//FldrNamesTWv is text wave pointing to existing folders with waves to be processed. One fodler per line... It can contain more lines, since only...
	// lines which have 1 in wave  SelFldrs (has to have same number of points as the FldrNamesTWv) will be processed. This is to enable user selectiong throught listbox.
	// SubtrWvX,SubtrWvY,SubtrWvE ... teh waves toi be subtaracted. if Errors do nto excist, need to create 0 containing waves. 
	// Xtmplt,Ytmplt,Etmplt - strings with templates to match wave names. Non-fatal error will be generated if data cannot be found and printed in history area. The folder will be then skipped.
	// OutFldrNm,OutXWvNm, OutYWvNm,OutEWvNm - string for output data. Folder will be created, if it does not exist. User will be warned if data should be overwritten. 
	// note: if Etmplt is empty, no error wave is expected and no error is generated. BUT, output error wave is produced
	// Processing:
	//The tool will interpolate (linearly for now) for Qs from first data set selected (can be changed in the future) Y values and then in each point will calculate mean and either stdDev or SEM. 
	// to address in the future: How to propagate uncertainities (Ewaves) through in meaningful way
	// May be interpolate in log-space?
	// enable user defined Q scale. 
	
	if(numpnts(SubtrWvX)!=numpnts(SubtrWvY) || numpnts(SubtrWvY)!=numpnts(SubtrWvE))
		Abort "Bad call to IR3M_SubtractWave, number of points on input subtract waves do not agree"
	endif
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:
	NewDataFolder /O/S root:Packages
	NewDataFolder /O/S root:Packages:DataManipulationII
	//OK before we even do anything, let's do some checking on the parameters called... 
	if(numpnts(FldrNamesTWv)!=numpnts(SelFldrs))
		abort "Bad call to IR3M_AverageMultipleWaves"
	endif

	Duplicate/O SubtrWvY, WaveToSubtractLog
	WaveToSubtractLog = log(SubtrWvY)
	//Ok, now let's create the data to do statistics on
	variable NumOfFoldersToTest=numpnts(SelFldrs)
	variable i, j
	String NewWaveNote=";Data modified by subtracting wave: " +GetWavesDataFolder(SubtrWvY,2)
	//Now fill the Matrix with the right values...
	j=0
	variable HadError=0
	For(i=0;i<NumOfFoldersToTest;i+=1)
		if(SelFldrs[i]>0)		//set to 1, selected
			wave/Z tmpWvX=$(FldrNamesTWv[i]+PossiblyQuoteName(IN2G_ReturnExistingWaveName(FldrNamesTWv[i],Xtmplt)))
			wave/Z tmpWvY=$(FldrNamesTWv[i]+PossiblyQuoteName(IN2G_ReturnExistingWaveName(FldrNamesTWv[i],Ytmplt)))
			wave/Z tmpWvE=$(FldrNamesTWv[i]+PossiblyQuoteName(IN2G_ReturnExistingWaveName(FldrNamesTWv[i],Etmplt)))
				SVAR DataFolderName = root:Packages:DataManipulationII:DataFolderName
				SVAR IntensityWaveName = root:Packages:DataManipulationII:IntensityWaveName
				SVAR QWavename = root:Packages:DataManipulationII:QWavename
				SVAR ErrorWaveName = root:Packages:DataManipulationII:ErrorWaveName
				DataFolderName=FldrNamesTWv[i]
				IntensityWaveName=IN2G_ReturnExistingWaveName(FldrNamesTWv[i],Ytmplt)
				QWavename=IN2G_ReturnExistingWaveName(FldrNamesTWv[i],Xtmplt)
				ErrorWaveName=IN2G_ReturnExistingWaveName(FldrNamesTWv[i],Etmplt)
			
			if(WaveExists(tmpWvX) && WaveExists(tmpWvY))
				Duplicate/O tmpWvX, TempSubtractedXWv0123
				Duplicate/O tmpWvY, TempSubtractedYWv0123, tempLogDataToSubtractAtrighQ
				tempLogDataToSubtractAtrighQ = 10^ interp(tmpWvX[p], SubtrWvX, WaveToSubtractLog )
				TempSubtractedYWv0123 = (tmpWvY[p]) - tempLogDataToSubtractAtrighQ[p]
				//fix the note.
				NewWaveNote+=" from wave: "+GetWavesDataFolder(tmpWvY,2)+";"		
				Note TempSubtractedYWv0123, NewWaveNote
				Note TempSubtractedXWv0123, NewWaveNote
				if(WaveExists(tmpWvE))
					Duplicate/O tmpWvE, TempSubtractedEWv0123
					TempSubtractedEWv0123 = sqrt(tmpWvE[p]^2 + (interp(tmpWvX[p], SubtrWvX, SubtrWvE ))^2)
					Note TempSubtractedEWv0123, NewWaveNote
				endif
				//and now we need to save them... 
				//OutFldrNm,OutXWvNm, OutYWvNm,OutEWvNm
				IR3M_PresetOutputWvsNms()
	
				SVAR OutFldrNm = root:Packages:DataManipulationII:ResultsDataFolderName
				SVAR OutYWvNm = root:Packages:DataManipulationII:ResultsIntWaveName
				SVAR OutXWvNm = root:Packages:DataManipulationII:ResultsQvecWaveName
				SVAR OutEWvNm = root:Packages:DataManipulationII:ResultsErrWaveName

				Wave/Z testWvX=$(IN2G_CheckFldrNmSemicolon(OutFldrNm,1)+PossiblyQuoteName(OutXWvNm))
				Wave/Z testWvY=$(IN2G_CheckFldrNmSemicolon(OutFldrNm,1)+PossiblyQuoteName(OutYWvNm))
				Wave/Z testWvE=$(IN2G_CheckFldrNmSemicolon(OutFldrNm,1)+PossiblyQuoteName(OutEWvNm))
				if(WaveExists(testWvX)||WaveExists(testWvY)||WaveExists(testWvE))
					HadError=1
					Print "Could not save data in the folder : "+OutFldrNm
					Print "The data in this folder already exist and this tool cannot overwrite the data" 
				else
					string tempFldrNm=GetDataFolder(1)
					IN2G_CreateAndSetArbFolder(OutFldrNm)
					Duplicate TempSubtractedXWv0123, $((OutXWvNm))
					Duplicate TempSubtractedYWv0123, $((OutYWvNm))
					Wave/Z TempSubtractedEWv0123= $(tempFldrNm+"TempSubtractedEWv0123")
					if(WaveExists(TempSubtractedEWv0123))
						Duplicate TempSubtractedEWv0123, $((OutEWvNm))
					endif
					setDataFolder tempFldrNm
				endif
			else
				Print "Error found... " + FldrNamesTWv[i] + " selected data were not found. Please, check data selection and if persistent, report this as error."
				KillWaves/Z TempSubtractedXWv0123, TempSubtractedYWv0123, TempSubtractedEWv0123
				
			endif
		endif
	endfor
	
	if(HadError)
		DoAlert  0, "Note there were errors while processing the data, see details in history area"
	endif
	KillWaves/Z AverageWvsTempMatrix, tempWvForStatistics, TempSubtractedXWv0123, TempSubtractedYWv0123, TempSubtractedEWv0123, tempLogDataToSubtractAtrighQ, WaveToSubtractLog
	setDataFolder oldDf
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR3M_CreateGraph()

		NVAR DisplayResults = root:Packages:DataManipulationII:DisplayResults
	if(DisplayResults)	
		DoWIndow DataManipulationIIGraph
		if(V_Flag)
			DoWIndow/K DataManipulationIIGraph
		endif
		Display/K=1/W=(305.25,42.5,870,498.5) as "DataManipulation II Graph"
		DoWindow/C DataManipulationIIGraph
	endif
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR3M_AverageMultipleWaves(FldrNamesTWv,SelFldrs,Xtmplt,Ytmplt,Etmplt,OutFldrNm,OutXWvNm, OutYWvNm,OutEWvNm,UseStdDev,UseSEM,UseMinMax)
	Wave/T FldrNamesTWv
	Wave SelFldrs
	String Xtmplt,Ytmplt,Etmplt,OutFldrNm,OutXWvNm, OutYWvNm,OutEWvNm
	Variable UseStdDev,UseSEM, useMinMax
	//for other uses, here is the parameters description:
	//FldrNamesTWv is text wave pointing to existing folders with waves to be processed. One fodler per line... It can contain more lines, since only...
	// lines which have 1 in wave  SelFldrs (has to have same number of points as the FldrNamesTWv) will be processed. This is to enable user selectiong throught listbox.
	// Xtmplt,Ytmplt,Etmplt - striongs with templates to match wave names. Non-fatal error will be generated if data cannot be found and printed in history area. The folder will be then skipped.
	// OutFldrNm,OutXWvNm, OutYWvNm,OutEWvNm - string for output data. Folder will be created, if it does not exist. User will be warned if data should be overwritten. 
	// note: if Etmplt is empty, no error wave is expected and no error is generated. BUT, output error wave is produced
	// UseStdDev,UseSEM - which error is produced for each point. Either standard deviation of Std of mean (std Dev /sqrt(numpnts)). NOTE: At this time there is no use for measurement errors.
	// UseMinMax -  generate also values for Min and Max for each point, separate waves
	// Processing:
	//The tool will interpolate (linearly for now) for Qs from first data set selected (can be changed in the future) Y values and then in each point will calculate mean and either stdDev or SEM. 
	// to address in the future: How to propagate uncertainities (Ewaves) through in meaningful way
	// May be interpolate in log-space?
	// enable user defined Q scale. 
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:
	NewDataFolder /O/S root:Packages
	NewDataFolder /O/S root:Packages:DataManipulationII
	//OK before we even do anything, let's do some checking on the parameters called... 
	if(numpnts(FldrNamesTWv)!=numpnts(SelFldrs))
		abort "Bad call to IR3M_AverageMultipleWaves"
	endif

	//Ok, now let's create the data to do statistics on
	variable NumOfFoldersToTest=numpnts(SelFldrs)
	variable NumOfFolderstoProcess=0
	variable i, j
	for (i=0;i<NumOfFoldersToTest;i+=1)
		if(SelFldrs[i])
			wave/Z tmpWv=$(FldrNamesTWv[i]+IN2G_ReturnExistingWaveName(FldrNamesTWv[i],Xtmplt))
			break
		endif
	endfor
	if(!WaveExists(tmpWv))
		abort "Bad call to IR3M_AverageMultipleWaves"
	endif
	variable NumOfXsToProcess = numpnts(tmpWv)
	//OK, now we know how many waves and how many x points. Also, we now have the first existing used x-wave, which we will use as results x wave also. Make a copy...
	Duplicate/O tmpWv, AveragedDataXwave
	Wave AveragedDataXwave
	//create matric where we will put all the data (interpolated)
	Make/O/N=(NumOfXsToProcess,NumOfFoldersToTest) AverageWvsTempMatrix
	String NewWaveNote="Data averaged from following data sets="
	//Now fill the Matrix with the right values...
	j=0
	For(i=0;i<NumOfFoldersToTest;i+=1)
		if(SelFldrs[i]>0)		//set to 1, selected
			wave/Z tmpWvX=$(FldrNamesTWv[i]+IN2G_ReturnExistingWaveName(FldrNamesTWv[i],Xtmplt))
			wave/Z tmpWvY=$(FldrNamesTWv[i]+IN2G_ReturnExistingWaveName(FldrNamesTWv[i],Ytmplt))
			if(WaveExists(tmpWvX) && WaveExists(tmpWvY))
				AverageWvsTempMatrix[][j]=interp(AveragedDataXwave[p], tmpWvX, tmpWvY )
				NewWaveNote+=FldrNamesTWv[i]+IN2G_ReturnExistingWaveName(FldrNamesTWv[i],Ytmplt) +","
			else
				AverageWvsTempMatrix[p][j]=Nan
				Print "Error found... " + FldrNamesTWv[i] + " selected data were not found. Please, check data selection and if persistent, report this as error."
			endif
			j+=1
			NumOfFolderstoProcess+=1
		endif
	endfor
	NewWaveNote+=";"
	//And now we should be simply able to do row-by=row analysis and stuff it into resulting wave.
	Redimension/N=(NumOfXsToProcess,NumOfFolderstoProcess) AverageWvsTempMatrix
	Duplicate/O AveragedDataXwave, AveragedDataYwave, AveragedDataEwave, AveragedDataYwaveMin, AveragedDataYwaveMax 
	variable tmpError
	Make/O/N=(NumOfFolderstoProcess) tempWvForStatistics
	For(i=0;i<NumOfXsToProcess;i+=1)
		tempWvForStatistics[] = AverageWvsTempMatrix[i][p]
		wavestats/Q tempWvForStatistics
		AveragedDataYwave[i]=V_avg
		AveragedDataYwaveMin[i]=V_min
		AveragedDataYwaveMax[i]=V_max
		tmpError = V_sdev
		if(UseSEM)
			tmpError/=sqrt(V_npnts)
		else
		endif
		AveragedDataEwave[i]=tmpError
	endfor
		if(UseSEM)
			NewWaveNote+="Statistical error=Standard error of mean;"
		else
			NewWaveNote+="Statistical error=Standard deviation;"
		endif
	Note AveragedDataYwave, NewWaveNote
	Note AveragedDataXwave, NewWaveNote
	Note AveragedDataEwave, NewWaveNote
	Note AveragedDataYwaveMax, NewWaveNote
	Note AveragedDataYwaveMin, NewWaveNote
	
	KillWaves AverageWvsTempMatrix, tempWvForStatistics
	setDataFolder oldDf
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR3M_DataFolderPopMenuProc(Pa) : PopupMenuControl
	STRUCT WMPopupAction &Pa

//	Pa.win = WinName(0,64)
	if(Pa.eventCode!=2)
		return 0
	endif
	IR2C_PanelPopupControl(Pa) 
	//and for Indra data we should be able to present also templates...
	NVAR UseIndra2Data = root:Packages:DataManipulationII:UseIndra2Data
	SVAR IntensityWaveName=root:Packages:DataManipulationII:IntensityWaveName
	SVAR QWavename=root:Packages:DataManipulationII:QWavename
	SVAR ErrorWaveName=root:Packages:DataManipulationII:ErrorWaveName
	SVAR Waves_Xtemplate=root:Packages:DataManipulationII:Waves_Xtemplate
	SVAR Waves_Ytemplate=root:Packages:DataManipulationII:Waves_Ytemplate
	SVAR Waves_Etemplate=root:Packages:DataManipulationII:Waves_Etemplate
	if(UseIndra2Data)
		Waves_Xtemplate=QWavename
		Waves_Ytemplate=IntensityWaveName
		Waves_Etemplate=ErrorWaveName
	endif
	IR3M_MakePanelWithListBox()
End
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR3M_MakePanelWithListBox()
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:DataManipulationII
	
	DoWindow ItemsInFolderPanel_DMII
	if(V_Flag)
		DoWindow/K ItemsInFolderPanel_DMII
	endif
	SVAR DataFolderName=root:Packages:DataManipulationII:DataFolderName
	if(!DataFolderExists(DataFolderName) || cmpstr(DataFolderName,"---")==0)
		return 1
	endif
 	SVAR LastSelectedItem = root:Packages:DataManipulationII:LastSelectedItem

	variable WhatToTest
	string TitleStr
		WhatToTest=2
		TitleStr = "Waves in test folder"
	setDataFolder DataFolderName
	string ListOfItems = StringFromList(1,(DataFolderDir(WhatToTest)),":")
	setDataFolder root:Packages:DataManipulationII
	make/O/T/N=(itemsInList(ListOfItems,",")) ItemsInFolder
	variable i
	variable selItemOld=0
	for(i=0;i<itemsInList(ListOfItems,",");i+=1)
		ItemsInFolder[i]= stringFromList(0,stringFromList(i,ListOfItems,","),";")
		if(stringmatch(ItemsInFolder[i], LastSelectedItem ))
			selItemOld=i
		endif
	endfor
	Make/O/T/N=0 PreviewSelectedFolder
	Make/O/N=0 SelectedFoldersWv

	DoWindow ItemsInFolderPanel
	if(V_Flag)
		DoWindow/K ItemsInFolderPanel
	endif
	
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(400,50,720,696) as "Items in selected folder"
	DoWindow/C ItemsInFolderPanel_DMII
	SetDrawLayer UserBack
	SetDrawEnv fsize= 16,fstyle= 3,textrgb= (0,0,65280)
	DrawText 45,21,"Items In the selected folder"
	SetDrawEnv fsize= 16,fstyle= 3,textrgb= (0,0,65280)
	DrawText 11,313,"Selected Folders for processing:"
	ListBox ItemsInCurrentFolder,pos={2,23},size={311,262}
	ListBox ItemsInCurrentFolder,listWave=root:Packages:DataManipulationII:ItemsInFolder
	ListBox ItemsInCurrentFolder,mode= 1,selRow= selItemOld, proc=IR3M_ListBoxProc

	ListBox SelectedWaves,pos={3,317},size={313,270},mode=1
	ListBox SelectedWaves,listWave=root:Packages:DataManipulationII:PreviewSelectedFolder,row= 0
	ListBox SelectedWaves,selWave=root:Packages:DataManipulationII:SelectedFoldersWv
	NVAR ManualFolderSelection = root:Packages:DataManipulationII:ManualFolderSelection
	if(ManualFolderSelection)
		ListBox SelectedWaves win=ItemsInFolderPanel_DMII, mode=10
	else
		ListBox SelectedWaves win=ItemsInFolderPanel_DMII, mode=0
	endif

	Button SelectAll,pos={15,610},size={120,14},proc= IR3M_DataManIIPanelButtonProc,title="Select All"
	Button DeselectAll,pos={155,610},size={120,14},proc= IR3M_DataManIIPanelButtonProc,title="Deselect All"
	
	AutoPositionWindow/M=0 /R=DataManipulationII ItemsInFolderPanel_DMII
	setDataFolder oldDF
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


Function IR3M_ListBoxProc(ctrlName,row,col,event) : ListBoxControl
	String ctrlName
	Variable row
	Variable col
	Variable event	//1=mouse down, 2=up, 3=dbl click, 4=cell select with mouse or keys
					//5=cell select with shift key, 6=begin edit, 7=end

	if(event==4)
		//update
		IR3M_UpdateValueListBox()
	endif
	return 0
End

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR3M_UpdateValueListBox()
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:DataManipulationII
	
	SVAR DataFolderName=root:Packages:DataManipulationII:DataFolderName
	if(!DataFolderExists(DataFolderName))
		abort
	endif
	SVAR LastSelectedItem = root:Packages:DataManipulationII:LastSelectedItem
	variable WhatToTest
	string TitleStr
		WhatToTest=2
		TitleStr = "Waves in test folder"
	variable i
	ControlInfo  /W=ItemsInFolderPanel_DMII ItemsInCurrentFolder
	Wave/T ItemsInFolder
	variable SelectedItem=V_Value
	LastSelectedItem = ItemsInFolder[SelectedItem]
	Wave FirstSelectedWave=$(DataFolderName+possiblyQuoteName(ItemsInFolder[SelectedItem]))
	string CurNote=note(FirstSelectedWave)
	make/T/O/N=(itemsInList(CurNote)) WaveNoteList
	for(i=0;i<itemsInList(CurNote);i+=1)
		WaveNoteList[i]= stringFromList(i,CurNote)
	endfor

	DoWindow ItemsInFolderPanel_DMII
	if(V_Flag)
		DoWindow/F ItemsInFolderPanel_DMII
	else
		abort
	endif
	ControlUpdate  /W=ItemsInFolderPanel_DMII  WaveNoteList
	
	setDataFolder oldDF

end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************



Function IR3M_InitDataManipulationII()


	string OldDf=GetDataFolder(1)
	setdatafolder root:
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S DataManipulationII

	string ListOfVariables
	string ListOfStrings
	variable i
	
	//here define the lists of variables and strings needed, separate names by ;...
	
	ListOfVariables="UseIndra2Data;UseQRSdata;UseResults;UseSMRData;UseUserDefinedData;"
	ListOfVariables+="ManualFolderSelection;DisplayResults;DisplaySourceData;"
	ListOfVariables+="ErrorUseStdDev;ErrorUseStdErOfMean;GenerateMinMax;"
	ListOfVariables+="GraphLogX;GraphLogY;GraphColorScheme1;GraphColorScheme2;GraphColorScheme3;GraphFontSize;"
	ListOfVariables+="AverageWaves;GenerateStatisticsForAveWvs;SubtractDataFromAll;"
//
	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;"
	ListOfStrings+="Waves_Xtemplate;Waves_Ytemplate;Waves_Etemplate;"
	ListOfStrings+="StartFolder;FolderMatchString;LastSelectedItem;"
	ListOfStrings+="ResultsDataFolderName;ResultsIntWaveName;ResultsQvecWaveName;ResultsErrWaveName;NameModifier;"
//	
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	
	//Waves
	Wave/T/Z SelectedItems 
	if(!WaveExists(SelectedItems))
		make/T/N=1 SelectedItems
		SelectedItems[0]="DataFolderName;"
	endif
	
	NVAR ErrorUseStdDev
	NVAR ErrorUseStdErOfMean
	if(ErrorUseStdDev+ErrorUseStdErOfMean!=1)
		ErrorUseStdDev=1
		ErrorUseStdErOfMean=0
	endif
	
	NVAR GraphFontSize
	if(GraphFontSize<6)
		GraphFontSize=8
	endif
	SVAR StartFolder
	if(!DataFolderExists(StartFolder) || strlen(StartFolder)<1)
		StartFolder="root:"
	endif
	SVAR FolderMatchString
	if(Strlen(FolderMatchString)==0)
		FolderMatchString="*"
	endif
	SVAR NameModifier
	if(strlen(NameModifier)<1)
		NameModifier="_manII"
	endif
	setDataFolder OldDf
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


Function IR3M_DisplayDataManipII()

	IR3M_CreateGraph()
	IR3M_AppendDataToGraph()
	IR3M_FormatManIIGraph()
	IR3M_AppendLegend()
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR3M_FormatManIIGraph()

	DoWindow DataManipulationIIGraph
	if(!V_Flag)
		return 0
	endif
	NVAR ColorScheme1=root:Packages:DataManipulationII:GraphColorScheme1
	NVAR ColorScheme2=root:Packages:DataManipulationII:GraphColorScheme2
	NVAR ColorScheme3 = root:Packages:DataManipulationII:GraphColorScheme3

	NVAR GraphLogX=root:Packages:DataManipulationII:GraphLogX
	NVAR GraphLogY=root:Packages:DataManipulationII:GraphLogY

	Label left "Intensity [cm\\S-1\\M]"
	Label bottom "Q [A\\S-1\\M]"

	DoWIndow DataManipulationIIGraph
	if(!V_Flag)
		abort
	else
		DoWindow/F DataManipulationIIGraph
	endif
	
	ModifyGraph/Z  /W=DataManipulationIIGraph  log(bottom)=GraphLogX
	ModifyGraph/Z  /W=DataManipulationIIGraph  log(left)=GraphLogY
	if(ColorScheme1)
		IR2M_MultiColorStyle()
	elseif(ColorScheme2)
		IR2M_ColorCurves()
	elseif(ColorScheme3)
		IR2M_RainbowColorizeTraces(0)
	else
	
	endif



	CheckDisplayed /W=DataManipulationIIGraph ManipIIProcessedDataY
	if(V_Flag)
		ModifyGraph /W=DataManipulationIIGraph lSize(ManipIIProcessedDataY)=3
		ModifyGraph /W=DataManipulationIIGraph lStyle(ManipIIProcessedDataY)=2
		ModifyGraph /W=DataManipulationIIGraph rgb(ManipIIProcessedDataY)=(0,0,0)
	endif
	CheckDisplayed /W=DataManipulationIIGraph ManipIIProcessedDataYMin
	if(V_Flag)
		ModifyGraph /W=DataManipulationIIGraph lstyle(ManipIIProcessedDataYMin)=5
		ModifyGraph /W=DataManipulationIIGraph lsize(ManipIIProcessedDataYMin)=2
		ModifyGraph /W=DataManipulationIIGraph rgb(ManipIIProcessedDataYMin)=(0,0,0)
	endif
	CheckDisplayed /W=DataManipulationIIGraph ManipIIProcessedDataYMax
	if(V_Flag)
		ModifyGraph /W=DataManipulationIIGraph lstyle(ManipIIProcessedDataYMax)=5
		ModifyGraph /W=DataManipulationIIGraph lsize(ManipIIProcessedDataYMax)=2
		ModifyGraph /W=DataManipulationIIGraph rgb(ManipIIProcessedDataYMax)=(0,0,0)
	endif
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR3M_AppendLegend()
	DoWindow DataManipulationIIGraph
	if(!V_Flag)
		return 0
	endif

	NVAR FontSize = root:Packages:DataManipulationII:GraphFontSize

	string Traces=TraceNameList("DataManipulationIIGraph", ";", 1 )
	variable i
	string legendStr=""
	if(Fontsize<10)
		legendStr="\Z0"+num2str(floor(FontSize))	
	else
		legendStr="\Z"+num2str(floor(FontSize))	
	endif
	For(i=0;i<ItemsInList(Traces);i+=1)
		legendStr+="\\s("+StringFromList(i,traces)+") "+GetWavesDataFolder(TraceNameToWaveRef("DataManipulationIIGraph", StringFromList(i,traces)),0)+":"+StringFromList(i,traces)+"\r"
	endfor
	
	Legend/C/N=text0/A=LB legendStr
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR3M_AppendDataToGraph()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:DataManipulationII
	SVAR Xtmplt=root:Packages:DataManipulationII:Waves_Xtemplate
	SVAR Ytmplt=root:Packages:DataManipulationII:Waves_Ytemplate
	SVAR Etmplt=root:Packages:DataManipulationII:Waves_Etemplate
	Wave/T FldrNamesTWv =root:Packages:DataManipulationII:PreviewSelectedFolder
	Wave SelFldrs = root:Packages:DataManipulationII:SelectedFoldersWv

	variable NumOfFoldersToTest=numpnts(SelFldrs)
	variable NumOfFolderstoProcess=sum(SelFldrs)		//this wave better be 0 or 1, nothing else or this fails misserably

	NVAR DisplayResults = root:Packages:DataManipulationII:DisplayResults
	NVAR DisplaySourceData = root:Packages:DataManipulationII:DisplaySourceData

	NVAR AverageWaves = root:Packages:DataManipulationII:AverageWaves
	NVAR SubtractDataFromAll = root:Packages:DataManipulationII:SubtractDataFromAll

	NVAR GenerateMinMax=root:Packages:DataManipulationII:GenerateMinMax
	variable i, j
	j=0
	
	if(DisplaySourceData)
		For(i=0;i<NumOfFoldersToTest;i+=1)
			if(SelFldrs[i])		//set to 1, selected
				wave/Z tmpWvX=$(FldrNamesTWv[i]+PossiblyQuoteName(IN2G_ReturnExistingWaveName(FldrNamesTWv[i],Xtmplt)))
				wave/Z tmpWvY=$(FldrNamesTWv[i]+PossiblyQuoteName(IN2G_ReturnExistingWaveName(FldrNamesTWv[i],Ytmplt)))
				if(WaveExists(tmpWvX) && WaveExists(tmpWvY))
					AppendToGraph/W=DataManipulationIIGraph tmpWvY vs tmpWvX
				endif
				j+=1
			endif
		endfor
	endif
	if(DisplayResults && AverageWaves)
		SVAR OutFldrNm = root:Packages:DataManipulationII:ResultsDataFolderName
		SVAR OutXWvNm=root:Packages:DataManipulationII:ResultsIntWaveName
		SVAR OutYWvNm=root:Packages:DataManipulationII:ResultsQvecWaveName
		SVAR OutEWvNm=root:Packages:DataManipulationII:ResultsErrWaveName
		Wave TmpWvX = root:Packages:DataManipulationII:ManipIIProcessedDataX
		Wave TmpWvY = root:Packages:DataManipulationII:ManipIIProcessedDataY
		Wave TmpWvE = root:Packages:DataManipulationII:ManipIIProcessedDataE
		if(DisplayResults)
			AppendToGraph/W=DataManipulationIIGraph TmpWvY vs TmpWvX
			ErrorBars $(NameOfWave(TmpWvY)) Y,wave=(TmpWvE,TmpWvE)
			if(GenerateMinMax)
				Wave TmpWvY = root:Packages:DataManipulationII:ManipIIProcessedDataYMin
				AppendToGraph/W=DataManipulationIIGraph TmpWvY vs TmpWvX
				Wave TmpWvY = root:Packages:DataManipulationII:ManipIIProcessedDataYMax
				AppendToGraph/W=DataManipulationIIGraph TmpWvY vs TmpWvX
			endif
		endif
	endif
	if(DisplayResults && SubtractDataFromAll)
		Wave/T FldrNamesTWv = root:Packages:DataManipulationII:PreviewSelectedFolder
		Wave SelFldrs = root:Packages:DataManipulationII:SelectedFoldersWv
		SVAR  Xtmplt=root:Packages:DataManipulationII:Waves_Xtemplate
		SVAR  Ytmplt=root:Packages:DataManipulationII:Waves_Ytemplate
		SVAR  Etmplt=root:Packages:DataManipulationII:Waves_Etemplate
		For(i=0;i<NumOfFoldersToTest;i+=1)
			if(SelFldrs[i]>0)		//set to 1, selected
				SVAR DataFolderName = root:Packages:DataManipulationII:DataFolderName
				SVAR IntensityWaveName = root:Packages:DataManipulationII:IntensityWaveName
				SVAR QWavename = root:Packages:DataManipulationII:QWavename
				SVAR ErrorWaveName = root:Packages:DataManipulationII:ErrorWaveName
				DataFolderName=FldrNamesTWv[i]
				IntensityWaveName=IN2G_ReturnExistingWaveName(FldrNamesTWv[i],Ytmplt)
				QWavename=IN2G_ReturnExistingWaveName(FldrNamesTWv[i],Xtmplt)
				ErrorWaveName=IN2G_ReturnExistingWaveName(FldrNamesTWv[i],Etmplt)
				IR3M_PresetOutputWvsNms()
				SVAR OutFldrNm = root:Packages:DataManipulationII:ResultsDataFolderName
				SVAR OutYWvNm = root:Packages:DataManipulationII:ResultsIntWaveName
				SVAR OutXWvNm = root:Packages:DataManipulationII:ResultsQvecWaveName
				SVAR OutEWvNm = root:Packages:DataManipulationII:ResultsErrWaveName
				Wave/Z testWvX=$(IN2G_CheckFldrNmSemicolon(OutFldrNm,1)+PossiblyQuoteName(OutXWvNm))
				Wave/Z testWvY=$(IN2G_CheckFldrNmSemicolon(OutFldrNm,1)+PossiblyQuoteName(OutYWvNm))
			// 	Wave/Z testWvE=$(IN2G_CheckFldrNmSemicolon(OutFldrNm,1)+PossiblyQuoteName(OutEWvNm))
				if(WaveExists(testWvX) && WaveExists(testWvY))
					AppendToGraph/W=DataManipulationIIGraph testWvY vs testWvX
				endif
			endif
		endfor
	endif


	setDataFolder OldDf
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR3M_SaveProcessedData()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:DataManipulationII
	SVAR OutFldrNm = root:Packages:DataManipulationII:ResultsDataFolderName
	SVAR OutYWvNm=root:Packages:DataManipulationII:ResultsIntWaveName
	SVAR OutXWvNm=root:Packages:DataManipulationII:ResultsQvecWaveName
	SVAR OutEWvNm=root:Packages:DataManipulationII:ResultsErrWaveName
	Wave ManipIIProcessedDataX=root:Packages:DataManipulationII:ManipIIProcessedDataX
	Wave ManipIIProcessedDataY=root:Packages:DataManipulationII:ManipIIProcessedDataY
	Wave ManipIIProcessedDataE=root:Packages:DataManipulationII:ManipIIProcessedDataE
	variable i,j
	string newFldrNm, tempStrNm
	//nearly done, now we need to save the waves where users wants them. Typical messy folder issue...
	//first the folder, does it exists and if not, create it:
	if(!DataFolderExists(OutFldrNm))
		//does not exist, create it. At the same time, check and make this acceptable folder path...
		newFldrNm=""
		string OldDf1=GetDataFolder(1)
		setDataFolder root:
		for(i=0;i<itemsInList(OutFldrNm,":");i+=1)
			tempStrNm = StringFromList(i, OutFldrNm,":")
			if(!stringmatch(tempStrNm,"root"))
				tempStrNm= IN2G_RemoveExtraQuote(tempStrNm,1,1)
				tempStrNm=tempStrNm[0,30]
				NewDataFolder/O/S $(tempStrNm)
				tempStrNm=PossiblyQuoteName(tempStrNm)
				newFldrNm+=tempStrNm+":"
			else
				newFldrNm+="root:"
			endif
		endfor
		//now we should have new folder exisitng, be there and also have new possibly quote name pointing there.
		OutFldrNm = newFldrNm
		setDataFolder OldDf1
	endif
		//Next we can check if there are waves of these names already and warn user if he/she wants to overwrite...
		Wave/Z ExistsXWv=$(OutFldrNm+OutXWvNm)
		Wave/Z ExistsYWv=$(OutFldrNm+OutYWvNm)
		Wave/Z ExistsEWv=$(OutFldrNm+OutEWvNm)
		if(WaveExists(ExistsXWv)||WaveExists(ExistsYWv)||WaveExists(ExistsEWv))
			DoAlert 1, "Wave(s) with these names exist. Do you want to overwrite? If not, please select NO, change the wave or folder names and save again"
			if(V_Flag!=1)
				Print "Nothing was saved due to name conflict. Please fix output folder and wave names and save the data again."
				Abort
			endif	
		endif
		//OK, now we can save the waves and be done, hopefully...
		//folder exists, all we need to do is write the waves out.
		Duplicate/O ManipIIProcessedDataX, $(OutFldrNm+OutXWvNm)
		Duplicate/O ManipIIProcessedDataY, $(OutFldrNm+OutYWvNm)
		Duplicate/O ManipIIProcessedDataE, $(OutFldrNm+OutEWvNm)
		

	setDataFolder OldDf

end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

