#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.00



//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************



Function IR2S_ScriptingTool()

	IN2G_CheckScreenSize("height",670)
	
	IR2S_InitScritingTool()
	
	IR2S_UpdateListOfAvailFiles()
	DoWindow IR2S_ScriptingToolPnl
	if(V_Flag)
		DoWindow/F IR2S_ScriptingToolPnl
	else
		Execute("IR2S_ScriptingToolPnl()")
	endif

end

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************



Function IR2S_PopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	if(stringmatch(ctrlName,"StartFolderSelection"))
		//Update the listbox using start folde popStr
		SVAR StartFolderName=root:Packages:Irena:ScriptingTool:StartFolderName
		StartFolderName = popStr
		IR2S_UpdateListOfAvailFiles()
	endif
End


//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************



Function IR2S_CheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	NVAR UseIndra2Data=root:Packages:Irena:ScriptingTool:UseIndra2Data
	NVAR UseQRSdata=root:Packages:Irena:ScriptingTool:UseQRSdata
	if(stringmatch(ctrlname,"UseIndra2Data"))
		if(checked)
			UseQRSdata =0
		endif
		//update listbox 
		IR2S_UpdateListOfAvailFiles()
	endif
	if(stringmatch(ctrlname,"UseQRSdata"))
		if(checked)
			UseIndra2Data =0
		endif
		//update listbox 
		IR2S_UpdateListOfAvailFiles()
	endif
	
	
End

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************



Function IR2S_ButtonProc(ctrlName) : ButtonControl
	String ctrlName

		wave SelectionOfAvailableData=root:Packages:Irena:ScriptingTool:SelectionOfAvailableData
	if(stringmatch(ctrlName,"GetHelp"))
		IR2S_HelpPanel()
	endif
	if(stringmatch(ctrlName,"GetLogbook"))
		//generate help in notebook.
		IR2S_GetLogbook()
	endif
	if(stringmatch(ctrlName,"AllData"))
		SelectionOfAvailableData=1
	endif
	if(stringmatch(ctrlName,"NoData"))
		SelectionOfAvailableData=0
	endif
	if(stringmatch(ctrlName,"FitWithUnified"))
		IR2S_FItWithUnifiedFit()
	endif
	if(stringmatch(ctrlName,"FitWithSizes"))
		IR2S_FItWithSizes()
	endif
	
	
End

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************

Function IR2S_HelpPanel()
	DoWindow Scripting_tool_help
	if(V_Flag)
		DoWindow/K Scripting_tool_help
	endif

	PauseUpdate; Silent 1		// building window...
	NewPanel/K=1 /W=(173.25,50,580,460) as "Scripting tool help"
	DoWindow/C Scripting_tool_help
	SetDrawLayer UserBack
	SetDrawEnv fsize= 20,fstyle= 1,textrgb= (16384,28160,65280)
	DrawText 23,37,"Help for Irena Scripting tool"
	SetDrawEnv fsize= 16,textrgb= (16384,28160,65280)
	DrawText 52,64,"@ Jan Ilavsky, 2007"
	DrawText 11,136,"To use scripting tool, please open the tool you want to use"
	DrawText 11,156,"Currently supported: Unified fit, Size distribution"

	DrawText 11,190,"Setup fitting parameters on representative case"
	DrawText 11,210,"Make sure data selection with cursors will be "
	DrawText 11,230,"      correct for all dataset you want to process."
	DrawText 11,250,"Make sure ranges for fitting (Unified) are wide enough."
	DrawText 11,270,"Keep the tool panel and graph opened!!!!"
	DrawText 11,290,"In the Scripting tool panel select the data "
	DrawText 11,310,"Select output options "
	DrawText 11,330,"Run the fits. Good luck."
	DrawText 11,345," "
	DrawText 11,360,""
	DrawText 11,375,""
// ().	
end

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************



Window IR2S_ScriptingToolPnl() 
	PauseUpdate; Silent 1		// building window...
	NewPanel/K=1 /W=(28,44,412,615) as "Scripting tool"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 20,fstyle= 1,textrgb= (0,0,65535)
	DrawText 29,29,"Scripting tool"

	Button GetHelp,pos={280,4},size={90,15},proc=IR2S_ButtonProc,title="Get help"
	Button GetHelp,fSize=10,fStyle=2
	Button GetLogbook,pos={280,21},size={90,15},proc=IR2S_ButtonProc,title="Open logbook"
	Button GetLogbook,fSize=10,fStyle=2

	PopupMenu StartFolderSelection,pos={11,54},size={130,20},proc=IR2S_PopMenuProc,title="Select start folder"
//	PopupMenu StartFolderSelection,mode=1,popvalue="Yes",value= #"\"Yes;No\""
	PopupMenu StartFolderSelection,mode=1,popvalue=root:Packages:Irena:ScriptingTool:StartFolderName,value= #"\"---;\"+IR2S_GenStringOfFolders2(root:Packages:Irena:ScriptingTool:UseIndra2Data, root:Packages:Irena:ScriptingTool:UseQRSdata,2,1)"

	CheckBox UseIndra2data,pos={301,45},size={76,14},proc=IR2S_CheckProc,title="Indra 2 data?"
	CheckBox UseIndra2data,variable= root:Packages:Irena:ScriptingTool:UseIndra2Data
	CheckBox UseQRSdata,pos={302,63},size={64,14},proc=IR2S_CheckProc,title="QRS data?"
	CheckBox UseQRSdata,variable= root:Packages:Irena:ScriptingTool:UseQRSdata

	ListBox DataFolderSelection,pos={4,85},size={372,180}, mode=4
	ListBox DataFolderSelection,listWave=root:Packages:Irena:ScriptingTool:ListOfAvailableData
	ListBox DataFolderSelection,selWave=root:Packages:Irena:ScriptingTool:SelectionOfAvailableData

	Button AllData,pos={150,270},size={100,15},proc=IR2S_ButtonProc,title="Select all data"
	Button AllData,fSize=10,fStyle=2
	Button NoData,pos={250,270},size={100,15},proc=IR2S_ButtonProc,title="DeSelect all data"
	Button NoData,fSize=10,fStyle=2


	Button FitWithUnified,pos={30,300},size={200,15},proc=IR2S_ButtonProc,title="Run Unified Fit on selected data"
	Button FitWithUnified,fSize=10,fStyle=2

	Button FitWithSizes,pos={30,325},size={200,15},proc=IR2S_ButtonProc,title="Run Size distribution on selected data"
	Button FitWithSizes,fSize=10,fStyle=2

	CheckBox SaveResultsInNotebook,pos={30,360},size={64,14},proc=IR2S_CheckProc,title="Save results in notebook?"
	CheckBox SaveResultsInNotebook,variable= root:Packages:Irena:ScriptingTool:SaveResultsInNotebook
	CheckBox ResetBeforeNextFit,pos={30,390},size={64,14},proc=IR2S_CheckProc,title="Reset before next fit? (Unified)"
	CheckBox ResetBeforeNextFit,variable= root:Packages:Irena:ScriptingTool:ResetBeforeNextFit
	CheckBox SaveResultsInFldrs,pos={30,420},size={64,14},proc=IR2S_CheckProc,title="Save results in folders?"
	CheckBox SaveResultsInFldrs,variable= root:Packages:Irena:ScriptingTool:SaveResultsInFldrs

EndMacro

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
Function IR2S_GetLogbook()

	DoWIndow ScriptingToolNbk
	if(V_Flag)
		DoWindow/F ScriptingToolNbk
	else
		DoWIndow SAS_FitLog
		if(V_Flag)
			DoWindow/F SAS_FitLog
		endif
	endif
end

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************


Function/T IR2S_GenStringOfFolders2(UseIndra2Structure, UseQRSStructure, SlitSmearedData, AllowQRDataOnly)
	variable UseIndra2Structure, UseQRSStructure, SlitSmearedData, AllowQRDataOnly
		//SlitSmearedData =0 for DSM data, 
		//                          =1 for SMR data 
		//                    and =2 for both
		// AllowQRDataOnly=1 if Q and R data are allowed only (no error wave). For QRS data ONLY!
	
	string ListOfQFolders
	//	if UseIndra2Structure = 1 we are using Indra2 data, else return all folders 
	string result
	variable i
	if (UseIndra2Structure)
		if(SlitSmearedData==1)
			result=IN2G_FindFolderWithWaveTypes("root:USAXS:", 10, "*SMR*", 1)
		elseif(SlitSmearedData==2)
			string tempStr=IN2G_FindFolderWithWaveTypes("root:USAXS:", 10, "*SMR*", 1)
			result=IN2G_FindFolderWithWaveTypes("root:USAXS:", 10, "*DSM*", 1)+";"
			for(i=0;i<ItemsInList(tempStr);i+=1)
			//print stringmatch(result, "*"+StringFromList(i, tempStr,";")+"*")
				if(stringmatch(result, "*"+StringFromList(i, tempStr,";")+"*")==0)
					result+=StringFromList(i, tempStr,";")+";"
				endif
			endfor
		else
			result=IN2G_FindFolderWithWaveTypes("root:USAXS:", 10, "*DSM*", 1)
		endif
	elseif (UseQRSStructure)
		ListOfQFolders=IN2G_FindFolderWithWaveTypes("root:", 10, "q*", 1)
		result=IR1_ReturnListQRSFolders(ListOfQFolders,AllowQRDataOnly)
	else
		result=IN2G_FindFolderWithWaveTypes("root:", 10, "*", 1)
	endif
	
	//now the result contains folder, we want list of parents here. create new list...
	string newresult=""
	string tempstr2
	for(i=0;i<ItemsInList(result , ";");i+=1)
		tempstr2=stringFromList(i,result,";")
		tempstr2=RemoveListItem(ItemsInList(tempstr2,":")-1, tempstr2  , ":")
		if(!stringmatch(newresult, "*"+tempstr2+"*" ))
			newresult+=tempstr2+";"
		endif
		
	endfor
	
	return newresult
end

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************



Function/T IR2S_GenStringOfFolders(StartFolder,UseIndra2Structure, UseQRSStructure, SlitSmearedData, AllowQRDataOnly)
	string StartFolder
	variable UseIndra2Structure, UseQRSStructure, SlitSmearedData, AllowQRDataOnly
		//SlitSmearedData =0 for DSM data, 
		//                          =1 for SMR data 
		//                    and =2 for both
		// AllowQRDataOnly=1 if Q and R data are allowed only (no error wave). For QRS data ONLY!
	
	string ListOfQFolders
	//	if UseIndra2Structure = 1 we are using Indra2 data, else return all folders 
	string result
	if (UseIndra2Structure)
		if(SlitSmearedData==1)
			result=IN2G_FindFolderWithWaveTypes(StartFolder, 10, "*SMR*", 1)
		elseif(SlitSmearedData==2)
			string tempStr=IN2G_FindFolderWithWaveTypes(StartFolder, 10, "*SMR*", 1)
			result=IN2G_FindFolderWithWaveTypes(StartFolder, 10, "*DSM*", 1)+";"
			variable i
			for(i=0;i<ItemsInList(tempStr);i+=1)
			//print stringmatch(result, "*"+StringFromList(i, tempStr,";")+"*")
				if(stringmatch(result, "*"+StringFromList(i, tempStr,";")+"*")==0)
					result+=StringFromList(i, tempStr,";")+";"
				endif
			endfor
		else
			result=IN2G_FindFolderWithWaveTypes(StartFolder, 10, "*DSM*", 1)
		endif
	elseif (UseQRSStructure)
		ListOfQFolders=IN2G_FindFolderWithWaveTypes(StartFolder, 10, "q*", 1)
		result=IR1_ReturnListQRSFolders(ListOfQFolders,AllowQRDataOnly)
	else
		result=IN2G_FindFolderWithWaveTypes(StartFolder, 10, "*", 1)
	endif
	
	return result
end

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************



Function IR2S_UpdateListOfAvailFiles()

	string OldDF=GetDataFolder(1)
	setDataFolder root:Packages:Irena:ScriptingTool
	
	NVAR UseIndra2Data=root:Packages:Irena:ScriptingTool:UseIndra2Data
	NVAR UseQRSdata=root:Packages:Irena:ScriptingTool:UseQRSData
	SVAR StartFolderName=root:Packages:Irena:ScriptingTool:StartFolderName

	string CurrentFolders=IR2S_GenStringOfFolders(StartFolderName,UseIndra2Data, UseQRSData,2,1)

	Wave/T ListOfAvailableData=root:Packages:Irena:ScriptingTool:ListOfAvailableData
	Wave SelectionOfAvailableData=root:Packages:Irena:ScriptingTool:SelectionOfAvailableData
	variable i, j
	string TempStr
		
	Redimension/N=(ItemsInList(CurrentFolders , ";")-1) ListOfAvailableData
	j=0
	For(i=0;i<ItemsInList(CurrentFolders , ";");i+=1)
		//TempStr = RemoveFromList("USAXS",RemoveFromList("root",StringFromList(i, CurrentFolders , ";"),":"),":")
		TempStr = ReplaceString(StartFolderName, StringFromList(i, CurrentFolders , ";"),"")
		if(strlen(TempStr)>0)
			ListOfAvailableData[j] = tempStr
			j+=1
		endif
	endfor
	Redimension/N=(Numpnts(ListOfAvailableData))  SelectionOfAvailableData
	SelectionOfAvailableData = 0
	setDataFolder OldDF
end


//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************



Function IR2S_InitScritingTool()
	
	string OldDF=GetDataFolder(1)
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S Irena
	NewDataFolder/O/S ScriptingTool
	
	string ListOfVariables
	string ListOfStrings
	variable i

	//here define the lists of variables and strings needed, separate names by ;...
	ListOfStrings="StartFolderName;"//"DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;"
	ListOfVariables="UseIndra2Data;UseQRSdata;SaveResultsInNotebook;ResetBeforeNextFit;SaveResultsInFldrs;"

	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
								
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	
	SVAR StartFolderName	
	if(strlen(StartFolderName)<1)
		StartFolderName="root:"
	endif
	Make/O/T/N=(0) ListOfAvailableData
	Make/O/N=(0) SelectionOfAvailableData
	
	
	setDataFolder OldDF
end


//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************

Function IR2S_FItWithSizes()

	DoWindow IR1R_SizesInputPanel
	if(!V_Flag)
		Abort  "The Size distribution tool panel and graph must be opened"
	else
		DoWIndow/F IR1R_SizesInputPanel 
	endif
	
	DoWindow IR1R_SizesInputGraph
	if(!V_Flag)
		Abort  "The Size distribution tool panel and graph must be opened"
	else
		DoWIndow/F IR1R_SizesInputGraph 
	endif

	string OldDF=GetDataFolder(1)
	setDataFolder root:Packages:Irena:ScriptingTool


	Wave/T ListOfAvailableData = root:Packages:Irena:ScriptingTool:ListOfAvailableData
	Wave SelectionOfAvailableData =root:Packages:Irena:ScriptingTool:SelectionOfAvailableData
	NVAR UseIndra2Data = root:Packages:Irena:ScriptingTool:UseIndra2Data
	variable NumOfSelectedFiles = sum(SelectionOfAvailableData)
	NVAR SaveResultsInNotebook = root:Packages:Irena:ScriptingTool:SaveResultsInNotebook
	NVAR ResetBeforeNextFit = root:Packages:Irena:ScriptingTool:ResetBeforeNextFit
	NVAR SaveResultsInFldrs = root:Packages:Irena:ScriptingTool:SaveResultsInFldrs
	SVAR StartFolderName = root:Packages:Irena:ScriptingTool:StartFolderName
	
	variable i
	string CurrentFolderName
	variable StartQ, EndQ		//need to store these from cursor positions (if set)
	DoWIndow IR1R_SizesInputGraph
	if(V_Flag)
		Wave Ywv = csrXWaveRef(A  , "IR1R_SizesInputGraph" )
		StartQ = Ywv[pcsr(A  , "IR1R_SizesInputGraph" )]
		EndQ = Ywv[pcsr(B  , "IR1R_SizesInputGraph" )]
	endif
	For(i=0;i<numpnts(ListOfAvailableData);i+=1)
		if(SelectionOfAvailableData[i]>0.5)
			CurrentFolderName = StartFolderName + ListOfAvailableData[i]
			//OK, now we know which files to process	
			//now stuff the name of the new folder in the folder name in Unified...
			SVAR DataFolderName = root:Packages:Sizes:DataFolderName
			DataFolderName = CurrentFolderName
			//now except for case when we use Indra 2 data we need to reload the other wave names... 
			STRUCT WMPopupAction PU_Struct
			PU_Struct.ctrlName = "SelectDataFolder"
			PU_Struct.popNum=0
			PU_Struct.popStr=DataFolderName
			PU_Struct.win = "IR1R_SizesInputPanel"
			IR2C_PanelPopupControl(PU_Struct)
				
			//this should create the new graph...
			IR1R_GraphDataButton("GraphIfAllowedSkipRecover")
			//now we need to set back the cursors.
			if(StartQ>0)
				Wave Qwave = root:Packages:Sizes:Q_vecOriginal
				if(binarysearch(Qwave,StartQ)>0)
					Cursor  /P /W=IR1R_SizesInputGraph A  IntensityOriginal binarysearch(Qwave,StartQ)
				endif	
			endif
			if(EndQ>0)
				Wave Qwave = root:Packages:Sizes:Q_vecOriginal
				if(binarysearch(Qwave,EndQ)>0)
					Cursor  /P /W=IR1R_SizesInputGraph B  IntensityOriginal binarysearch(Qwave,EndQ)	
				endif
			endif
			
			variable/g root:Packages:Sizes:FitFailed
			//do fitting
			IR1R_SizesFitting("DoFittingSkipReset")
			DoUpdate
			NVAR FitFailed=root:Packages:Sizes:FitFailed
			
			if(SaveResultsInNotebook)
				IR2S_SaveResInNbkSizes(FitFailed)
			endif
			if(SaveResultsInFldrs && !FitFailed)
				IR1R_saveData("SaveDataNoQuestions")
			endif
			KillVariables  FitFailed
		endif
		
	
	endfor
	
	

	setDataFolder OldDF


end

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************



Function IR2S_FItWithUnifiedFit()

	DoWindow IR1A_ControlPanel
	if(!V_Flag)
		Abort  "The Unified fit tool panel and graph must be opened"
	else
		DoWIndow/F IR1A_ControlPanel 
	endif
	
	DoWindow IR1_LogLogPlotU
	if(!V_Flag)
		Abort  "The Unified fit tool panel and graph must be opened"
	else
		DoWIndow/F IR1_LogLogPlotU 
	endif


	string OldDF=GetDataFolder(1)
	setDataFolder root:Packages:Irena:ScriptingTool


	Wave/T ListOfAvailableData = root:Packages:Irena:ScriptingTool:ListOfAvailableData
	Wave SelectionOfAvailableData =root:Packages:Irena:ScriptingTool:SelectionOfAvailableData
	NVAR UseIndra2Data = root:Packages:Irena:ScriptingTool:UseIndra2Data
	variable NumOfSelectedFiles = sum(SelectionOfAvailableData)
	NVAR SaveResultsInNotebook = root:Packages:Irena:ScriptingTool:SaveResultsInNotebook
	NVAR ResetBeforeNextFit = root:Packages:Irena:ScriptingTool:ResetBeforeNextFit
	NVAR SaveResultsInFldrs = root:Packages:Irena:ScriptingTool:SaveResultsInFldrs
	SVAR StartFolderName = root:Packages:Irena:ScriptingTool:StartFolderName
	
	variable i
	string CurrentFolderName
	variable StartQ, EndQ		//need to store these from cursor positions (if set)
	DoWIndow IR1_LogLogPlotU
	if(V_Flag)
		Wave Ywv = csrXWaveRef(A  , "IR1_LogLogPlotU" )
		StartQ = Ywv[pcsr(A  , "IR1_LogLogPlotU" )]
		EndQ = Ywv[pcsr(B  , "IR1_LogLogPlotU" )]
	endif
	For(i=0;i<numpnts(ListOfAvailableData);i+=1)
		if(SelectionOfAvailableData[i]>0.5)
			//here process the Unified...
			//CurrentFolderName="root:"
			//if(UseIndra2Data)
			//	CurrentFolderName+="USAXS:"
			//endif
			CurrentFolderName = StartFolderName + ListOfAvailableData[i]
			//OK, now we know which files to process	
			//now stuff the name of the new folder in the folder name in Unified...
			SVAR DataFolderName = root:Packages:Irena_UnifFit:DataFolderName
			DataFolderName = CurrentFolderName
			//now except for case when we use Indra 2 data we need to reload the other wave names... 
			STRUCT WMPopupAction PU_Struct
			PU_Struct.ctrlName = "SelectDataFolder"
			PU_Struct.popNum=0
			PU_Struct.popStr=DataFolderName
			PU_Struct.win = "IR1A_ControlPanel"
			IR2C_PanelPopupControl(PU_Struct)
			
			//this should create the new graph...
			IR1A_InputPanelButtonProc("DrawGraphsSkipDialogs")
			//now we need to set back the cursors.
			if(StartQ>0)
				Wave Qwave = root:Packages:Irena_UnifFit:OriginalQvector
				if(binarysearch(Qwave,StartQ)>0)
					Cursor  /P /W=IR1_LogLogPlotU A  OriginalIntensity binarysearch(Qwave,StartQ)
				endif	
			endif
			if(EndQ>0)
				Wave Qwave = root:Packages:Irena_UnifFit:OriginalQvector
				if(binarysearch(Qwave,EndQ)>0)
					Cursor  /P /W=IR1_LogLogPlotU B  OriginalIntensity binarysearch(Qwave,EndQ)	
				endif
			endif
			
			variable/g root:Packages:Irena_UnifFit:FitFailed
			//do fitting
			IR1A_InputPanelButtonProc("DoFittingSkipReset")
			DoUpdate
			NVAR FitFailed=root:Packages:Irena_UnifFit:FitFailed
			
			if(SaveResultsInNotebook)
				IR2S_SaveResInNbkUnif(FitFailed)
			endif
			if(SaveResultsInFldrs && !FitFailed)
				IR1A_InputPanelButtonProc("CopyTFolderNoQuestions")
			endif
			if(ResetBeforeNextFit && !FitFailed)
				IR1A_InputPanelButtonProc("RevertFitting")   
			endif
			KillVariables  FitFailed
		endif
		
	
	endfor
	
	

	setDataFolder OldDF
end

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************



Function IR2S_SaveResInNbkUnif(FitFailed)
	variable FitFailed
	
		DoWIndow ScriptingToolNbk

		if(!V_Flag)
			NewNotebook /F=1 /K=1 /N=ScriptingToolNbk /W=(400,20,1000,700 ) as "Results of scripting tool runs"		
		endif
		SVAR DataFolderName = root:Packages:Irena_UnifFit:DataFolderName


		Notebook ScriptingToolNbk   selection={endOfFile, endOfFile}
		Notebook ScriptingToolNbk text="\r"
		Notebook ScriptingToolNbk text="\r"
		Notebook ScriptingToolNbk text="\r"
		Notebook ScriptingToolNbk text="***********************************************\r"
		Notebook ScriptingToolNbk text="***********************************************\r"
		Notebook ScriptingToolNbk text=date()+"   "+time()+"\r"
		Notebook ScriptingToolNbk text="Unified results from folder :   "+ DataFolderName+"\r"
		Notebook ScriptingToolNbk text="\r"
		if(FitFailed)
			Notebook ScriptingToolNbk text="Fit failed\r"
		else
			Notebook ScriptingToolNbk  scaling={50,50}, frame=1, picture={IR1_LogLogPlotU,2,1}	
			Notebook ScriptingToolNbk text="\r"
			IR2S_RecordResultsToNbkUnif()
		endif
end	
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************



Function IR2S_SaveResInNbkSizes(FitFailed)
	variable FitFailed
	
		DoWIndow ScriptingToolNbk

		if(!V_Flag)
			NewNotebook /F=1 /K=1 /N=ScriptingToolNbk /W=(400,20,1000,700 ) as "Results of scripting tool runs"		
		endif
		SVAR DataFolderName = root:Packages:Sizes:DataFolderName


		Notebook ScriptingToolNbk   selection={endOfFile, endOfFile}
		Notebook ScriptingToolNbk text="\r"
		Notebook ScriptingToolNbk text="\r"
		Notebook ScriptingToolNbk text="\r"
		Notebook ScriptingToolNbk text="***********************************************\r"
		Notebook ScriptingToolNbk text="***********************************************\r"
		Notebook ScriptingToolNbk text=date()+"   "+time()+"\r"
		Notebook ScriptingToolNbk text="Size Distribution results from folder :   "+ DataFolderName+"\r"
		Notebook ScriptingToolNbk text="\r"
		if(FitFailed)
			Notebook ScriptingToolNbk text="Fit failed\r"
		else
			Notebook ScriptingToolNbk  scaling={40,40}, frame=1, picture={IR1R_SizesInputGraph,2,1}	
			Notebook ScriptingToolNbk text="\r"
			IR2S_RecordResultsToNbkSizes()
		endif
end	


//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************

Function IR2S_RecordResultsToNbkSizes()

	string OldDF=GetDataFolder(1)
	setdataFolder root:Packages:Sizes

	SVAR DataFolderName=root:Packages:Sizes:DataFolderName
	SVAR OriginalIntensityWvName=root:Packages:Sizes:IntensityWaveName
	SVAR OriginalQvectorWvName=root:Packages:Sizes:QWaveName
	SVAR OriginalErrorWvName=root:Packages:Sizes:ErrorWaveName
	SVAR SizesParameters=root:Packages:Sizes:SizesParameters
	SVAR LogDist=root:Packages:Sizes:LogDist
	SVAR ShapeType=root:Packages:Sizes:ShapeType
	SVAR SlitSmearedData=root:Packages:Sizes:SlitSmearedData
	SVAR MethodRun=root:Packages:Sizes:MethodRun
	
	
	Notebook ScriptingToolNbk text="\r"

	Notebook ScriptingToolNbk text="   "
	Notebook ScriptingToolNbk text="***********************************************"
	Notebook ScriptingToolNbk text="***********************************************"
	Notebook ScriptingToolNbk text="Sizes fitting record \r"
	Notebook ScriptingToolNbk text="Input data names \t"
	Notebook ScriptingToolNbk text="\t\tFolder \t\t"+ DataFolderName+"\r"
	Notebook ScriptingToolNbk text="\t\tIntensity/Q/errror wave names \t"+ OriginalIntensityWvName+"\t"+OriginalQvectorWvName+"\t"+OriginalErrorWvName+"\r"
	variable i
	For(i=0;i<ItemsInList(SizesParameters , ";");i+=1)
		Notebook ScriptingToolNbk text="\t\t"+StringFromList(i, SizesParameters, ";")+"\r"
	endfor
	Notebook ScriptingToolNbk text="\r"
	
	setdataFolder oldDf

end


//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************



Function IR2S_RecordResultsToNbkUnif()	

	string OldDF=GetDataFolder(1)
	setdataFolder root:Packages:Irena_UnifFit

	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels

	NVAR SASBackground=root:Packages:Irena_UnifFit:SASBackground
	NVAR FitSASBackground=root:Packages:Irena_UnifFit:FitSASBackground
	NVAR SubtractBackground=root:Packages:Irena_UnifFit:SubtractBackground
	NVAR UseSMRData=root:Packages:Irena_UnifFit:UseSMRData
	NVAR SlitLengthUnif=root:Packages:Irena_UnifFit:SlitLengthUnif

	SVAR DataAreFrom=root:Packages:Irena_UnifFit:DataFolderName
	SVAR IntensityWaveName=root:Packages:Irena_UnifFit:IntensityWaveName
	SVAR QWavename=root:Packages:Irena_UnifFit:QWavename
	SVAR ErrorWaveName=root:Packages:Irena_UnifFit:ErrorWaveName

	Notebook ScriptingToolNbk   selection={endOfFile, endOfFile}
	Notebook ScriptingToolNbk text="\r"
	Notebook ScriptingToolNbk text="Summary of Unified fit results :"+"\r"
	if(UseSMRData)
		Notebook ScriptingToolNbk text="Slit smeared data were. Slit length [A^-1] = "+num2str(SlitLengthUnif)+"\r"
	endif
	Notebook ScriptingToolNbk text="Name of data waves Int/Q/Error \t"+IntensityWaveName+"\t"+QWavename+"\t"+ErrorWaveName+"\r"
	Notebook ScriptingToolNbk text="Number of levels: "+num2str(NumberOfLevels)+"\r"
	Notebook ScriptingToolNbk text="SAS background = "+num2str(SASBackground)+", was fitted? = "+num2str(FitSASBackground)+"       (yes=1/no=0)"+"\r"
	Notebook ScriptingToolNbk text="\r"
	variable i
	For (i=1;i<=NumberOfLevels;i+=1)
		Notebook ScriptingToolNbk text="***********  Level  "+num2str(i)+"\r"
		NVAR tempVal =$("Level"+num2str(i)+"Rg")
		NVAR tempValError =$("Level"+num2str(i)+"RgError")
		NVAR fitTempVal=$("Level"+num2str(i)+"FitRg")
			Notebook ScriptingToolNbk text="Rg      \t\t"+ num2str(tempVal)+"\t\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal)+"\r"
		NVAR tempVal =$("Level"+num2str(i)+"G")
		NVAR tempValError =$("Level"+num2str(i)+"GError")
		NVAR fitTempVal=$("Level"+num2str(i)+"FitG")
			Notebook ScriptingToolNbk text="G      \t\t"+ num2str(tempVal)+"\t\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal)+"\r"
		NVAR tempVal =$("Level"+num2str(i)+"P")
		NVAR tempValError =$("Level"+num2str(i)+"PError")
		NVAR fitTempVal=$("Level"+num2str(i)+"FitP")
			Notebook ScriptingToolNbk text="P     \t \t"+ num2str(tempVal)+"\t\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal)+"\r"
		NVAR tempValMassFractal =$("Level"+num2str(i)+"MassFractal")
			if (tempValMassFractal)
				Notebook ScriptingToolNbk text="\tAssumed Mass Fractal"
				Notebook ScriptingToolNbk text="Parameter B calculated as B=(G*P/Rg^P)*Gamma(P/2)"+"\r"
			else
				NVAR tempVal =$("Level"+num2str(i)+"B")
				NVAR tempValError =$("Level"+num2str(i)+"BError")
				NVAR fitTempVal=$("Level"+num2str(i)+"FitB")
				Notebook ScriptingToolNbk text="B     \t \t"+ num2str(tempVal)+"\t\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal)+"\r"
			endif
		NVAR tempVal =$("Level"+num2str(i)+"RGCO")
		NVAR tempValError =$("Level"+num2str(i)+"RgCOError")
		NVAR LinktempVal=$("Level"+num2str(i)+"LinkRgCO")
		NVAR fitTempVal=$("Level"+num2str(i)+"FitRGCO")
				if (fitTempVal)
					Notebook ScriptingToolNbk text="RgCO linked to lower level Rg =\t"+ num2str(tempVal)+"\r"
				else
					Notebook ScriptingToolNbk text="RgCO      \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal)+"\r"
				endif
		NVAR tempVal =$("Level"+num2str(i)+"K")
			Notebook ScriptingToolNbk text="K      \t"+ num2str(tempVal)+"\r"
		NVAR tempValCorrelations =$("Level"+num2str(i)+"Corelations")
			if (tempValCorrelations)
				Notebook ScriptingToolNbk text="Assumed Corelations so following parameters apply"+"\r"
				NVAR tempVal =$("Level"+num2str(i)+"ETA")
				NVAR tempValError =$("Level"+num2str(i)+"ETAError")
				NVAR fitTempVal=$("Level"+num2str(i)+"FitETA")
					Notebook ScriptingToolNbk text="ETA      \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal)+"\r"
				NVAR tempVal =$("Level"+num2str(i)+"PACK")
				NVAR tempValError =$("Level"+num2str(i)+"PACKError")
				NVAR fitTempVal=$("Level"+num2str(i)+"FitPACK")
				Notebook ScriptingToolNbk text="PACK      \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal)+"\r"
		else
				Notebook ScriptingToolNbk text="Corelations       \tNot assumed\r"
			endif

		NVAR tempVal =$("Level"+num2str(i)+"Invariant")
				Notebook ScriptingToolNbk text="Invariant  =\t"+num2str(tempVal)+"   cm^(-1) A^(-3)\r"
		NVAR tempVal =$("Level"+num2str(i)+"SurfaceToVolRat")
			if (Numtype(tempVal)==0)
				Notebook ScriptingToolNbk text="Surface to volume ratio  =\t"+num2str(tempVal)+"   m^(2) / cm^(3)\r"
			endif
			Notebook ScriptingToolNbk text=" \r "
	endfor
	
		NVAR AchievedChisq
		Notebook ScriptingToolNbk text="Chi-Squared \t"+ num2str(AchievedChisq)+"\r"

		DoWindow /F IR1_LogLogPlotU
		if (strlen(csrWave(A))!=0 && strlen(csrWave(B))!=0)		//cursors in the graph
			Notebook ScriptingToolNbk text="Points selected for fitting \t"+ num2str(pcsr(A)) + "   to \t"+num2str(pcsr(B))+"\r"
		else
			Notebook ScriptingToolNbk text="Whole range of data selected for fitting"+"\r"
		endif
				
	setdataFolder oldDf
end

//Function IR1A_SaveRecordResults()	
//
//	string OldDF=GetDataFolder(1)
//	setdataFolder root:Packages:Irena_UnifFit
//
//	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels
//
//	NVAR SASBackground=root:Packages:Irena_UnifFit:SASBackground
//	NVAR FitSASBackground=root:Packages:Irena_UnifFit:FitSASBackground
//	NVAR SubtractBackground=root:Packages:Irena_UnifFit:SubtractBackground
//	NVAR UseSMRData=root:Packages:Irena_UnifFit:UseSMRData
//	NVAR SlitLengthUnif=root:Packages:Irena_UnifFit:SlitLengthUnif
//	NVAR LastSavedUnifOutput=root:Packages:Irena_UnifFit:LastSavedUnifOutput
//	NVAR ExportLocalFits=root:Packages:Irena_UnifFit:ExportLocalFits
//
//	SVAR DataAreFrom=root:Packages:Irena_UnifFit:DataFolderName
//	SVAR IntensityWaveName=root:Packages:Irena_UnifFit:IntensityWaveName
//	SVAR QWavename=root:Packages:Irena_UnifFit:QWavename
//	SVAR ErrorWaveName=root:Packages:Irena_UnifFit:ErrorWaveName
//
//	IR1_CreateLoggbook()		//this creates the logbook
//	SVAR nbl=root:Packages:SAS_Modeling:NotebookName
//
//	IR1L_AppendAnyText("     ")
//		IR1L_AppendAnyText("***********************************************")
//		IR1L_AppendAnyText("***********************************************")
//		IR1L_AppendAnyText("Saved Results of the UNIFIED FIT on the data from: \t"+DataAreFrom)	
//		IR1_InsertDateAndTime(nbl)
//		IR1L_AppendAnyText("Name of data waves Int/Q/Error \t"+IntensityWaveName+"\t"+QWavename+"\t"+ErrorWaveName)
//		if(UseSMRData)
//			IR1L_AppendAnyText("Slit smeared data were used. Slit length = "+num2str(SlitLengthUnif))
//		endif
//		IR1L_AppendAnyText("Output wave names :")
//		IR1L_AppendAnyText("Int/Q \t"+"UnifiedFitIntensity_"+num2str(LastSavedUnifOutput)+"\tUnifiedFitQvector_"+num2str(LastSavedUnifOutput))
//		if(ExportLocalFits)
//			IR1L_AppendAnyText("Loacl fits saved also")
//		endif
//		
//		IR1L_AppendAnyText("Number of fitted levels: "+num2str(NumberOfLevels))
//		IR1L_AppendAnyText("Fitting results: ")
//	IR1L_AppendAnyText("SAS background = "+num2str(SASBackground)+", was fitted? = "+num2str(FitSASBackground)+"       (yes=1/no=0)")
//	variable i
//	For (i=1;i<=NumberOfLevels;i+=1)
//		IR1L_AppendAnyText("***********  Level  "+num2str(i))
//		NVAR tempVal =$("Level"+num2str(i)+"Rg")
//		NVAR tempValError =$("Level"+num2str(i)+"RgError")
//		NVAR fitTempVal=$("Level"+num2str(i)+"FitRg")
//			IR1L_AppendAnyText("Rg      \t\t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
//		NVAR tempVal =$("Level"+num2str(i)+"G")
//		NVAR tempValError =$("Level"+num2str(i)+"GError")
//		NVAR fitTempVal=$("Level"+num2str(i)+"FitG")
//			IR1L_AppendAnyText("G      \t\t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
//		NVAR tempVal =$("Level"+num2str(i)+"P")
//		NVAR tempValError =$("Level"+num2str(i)+"PError")
//		NVAR fitTempVal=$("Level"+num2str(i)+"FitP")
//			IR1L_AppendAnyText("P     \t \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
//		NVAR tempValMassFractal =$("Level"+num2str(i)+"MassFractal")
//			if (tempValMassFractal)
//				IR1L_AppendAnyText("\tAssumed Mass Fractal")
//				IR1L_AppendAnyText("Parameter B calculated as B=(G*P/Rg^P)*Gamma(P/2)")
//			else
//				NVAR tempVal =$("Level"+num2str(i)+"B")
//				NVAR tempValError =$("Level"+num2str(i)+"BError")
//				NVAR fitTempVal=$("Level"+num2str(i)+"FitB")
//				IR1L_AppendAnyText("B     \t \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
//			endif
//		NVAR tempVal =$("Level"+num2str(i)+"RGCO")
//		NVAR tempValError =$("Level"+num2str(i)+"RgCOError")
//		NVAR LinktempVal=$("Level"+num2str(i)+"LinkRgCO")
//		NVAR fitTempVal=$("Level"+num2str(i)+"FitRGCO")
//				if (fitTempVal)
//					IR1L_AppendAnyText("RgCO linked to lower level Rg =\t"+ num2str(tempVal))
//				else
//					IR1L_AppendAnyText("RgCO      \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
//				endif
//		NVAR tempVal =$("Level"+num2str(i)+"K")
//			IR1L_AppendAnyText("K      \t"+ num2str(tempVal))
//		NVAR tempValCorrelations =$("Level"+num2str(i)+"Corelations")
//			if (tempValCorrelations)
//				IR1L_AppendAnyText("Assumed Corelations so following parameters apply")
//				NVAR tempVal =$("Level"+num2str(i)+"ETA")
//				NVAR tempValError =$("Level"+num2str(i)+"ETAError")
//				NVAR fitTempVal=$("Level"+num2str(i)+"FitETA")
//					IR1L_AppendAnyText("ETA      \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
//				NVAR tempVal =$("Level"+num2str(i)+"PACK")
//				NVAR tempValError =$("Level"+num2str(i)+"PACKError")
//				NVAR fitTempVal=$("Level"+num2str(i)+"FitPACK")
//				IR1L_AppendAnyText("PACK      \t"+ num2str(tempVal)+"\t+/- "+num2str(tempValError)+"\t,  \tfitted? = "+num2str(fitTempVal))
//		else
//				IR1L_AppendAnyText("Corelations       \tNot assumed")
//			endif
//
//		NVAR tempVal =$("Level"+num2str(i)+"Invariant")
//				IR1L_AppendAnyText("Invariant  =\t"+num2str(tempVal)+"   cm^(-1) A^(-3)")
//		NVAR tempVal =$("Level"+num2str(i)+"SurfaceToVolRat")
//			if (Numtype(tempVal)==0)
//				IR1L_AppendAnyText("Surface to volume ratio  =\t"+num2str(tempVal)+"   m^(2) / cm^(3)")
//			endif
//			IR1L_AppendAnyText("  ")
//	endfor
//	
//		IR1L_AppendAnyText("Fit has been reached with following parameters")
//		IR1_InsertDateAndTime(nbl)
//		NVAR/Z AchievedChisq
//		if(NVAR_Exists(AchievedChisq))
//			IR1L_AppendAnyText("Chi-Squared \t"+ num2str(AchievedChisq))
//		endif
//		DoWindow /F IR1_LogLogPlotU
//		if (strlen(csrWave(A))!=0 && strlen(csrWave(B))!=0)		//cursors in the graph
//			IR1L_AppendAnyText("Points selected for fitting \t"+ num2str(pcsr(A)) + "   to \t"+num2str(pcsr(B)))
//		else
//			IR1L_AppendAnyText("Whole range of data selected for fitting")
//		endif
//		IR1L_AppendAnyText(" ")
//		IR1L_AppendAnyText("***********************************************")
//
//	setdataFolder oldDf
//end
//