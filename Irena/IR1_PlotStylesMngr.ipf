#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2

//these macros allow user ot manage styles used by plotting tool
//functions I want to have - move in and out of Igor, delete & rename

Function IR1P_ManageStyles()

	IR1P_InitExportStyles()
	
	DoWindow IR1P_StylesManagementPanel
	if(V_Flag)
		DoWindow/K IR1P_StylesManagementPanel
	endif
	Execute ("IR1P_StylesManagementPanel()")

end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Window IR1P_StylesManagementPanel() 
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(63,50,380,470) as "IR1P_StylesManagementPanel"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 18,fstyle= 1,textrgb= (0,0,65280)
	DrawText 83,23,"Manage styles"
	SetDrawEnv fsize= 14, textrgb= (65280,0,0)
	DrawText 53,44,"Use shift to select multiple set"
	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,0,0)
	DrawText 8,65,"Styles within Igor"
	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,0,0)
	DrawText 170,65,"Styles outside Igor"

	ListBox ListOfInternalStyles pos={10,80}, editStyle= 0, listWave= root:Packages:GeneralplottingTool:WaveOfStylesInIgor, mode=4
	ListBox ListOfInternalStyles size = {130,160}, selwave = root:Packages:GeneralplottingTool:NumbersOfStylesInIgor

	ListBox ListOfExternalStyles pos={170,80}, editStyle= 0, listWave= root:Packages:GeneralplottingTool:WaveOfStylesOutsideIgor, mode=4
	ListBox ListOfExternalStyles size = {130,160}, selwave = root:Packages:GeneralplottingTool:NumbersOfStylesOutsideIgor

	Button DeleteInternalStyle pos={20,260}, size={75,20}, proc=IRP_ButtonProcStyles,title="Delete", help={"Delete internal styles"}
	Button DeleteExternalStyle pos={200,260}, size={75,20}, proc=IRP_ButtonProcStyles,title="Delete", help={"Delete external styles"}

	Button RenameInternalStyle pos={5,290}, size={125,20}, proc=IRP_ButtonProcStyles,title="Rename/Duplicate", help={"Rename ONE internal style"}
	Button RenameExternalStyle pos={180,290}, size={125,20}, proc=IRP_ButtonProcStyles,title="Rename/Duplicate", help={"Rename ONE external style"}

	Button CopyOutOfIgor pos={110,320}, size={95,20}, proc=IRP_ButtonProcStyles,title="  ---  Copy   --->>>", help={"Copy style from Igor experiment out"}
	Button CopyIntoIgor pos={110,350}, size={95,20}, proc=IRP_ButtonProcStyles,title="  <<<---  Copy   ---   ", help={"Copy style into Igor experiment out"}

EndMacro
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IRP_ButtonProcStyles(ctrlName) : ButtonControl
	String ctrlName
	
	if(cmpstr(ctrlName,"DeleteInternalStyle")==0)
		IR1P_DeleteInternalStyle()
	endif
	if(cmpstr(ctrlName,"DeleteExternalStyle")==0)
		IR1P_DeleteExternalStyle()
	endif
	if(cmpstr(ctrlName,"RenameInternalStyle")==0)
		IR1P_RenameDuplicateIntStyle()
	endif
	if(cmpstr(ctrlName,"RenameExternalStyle")==0)
		IR1P_RenameDuplicateExtStyle()
	endif
	if(cmpstr(ctrlName,"CopyOutOfIgor")==0)
		IR1P_CopyStyleOut()
	endif
	if(cmpstr(ctrlName,"CopyIntoIgor")==0)
		IR1P_CopyStyleIn()
	endif
	
	IR1P_InitExportStyles()		//this refreshes the listBoxes...
	
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR1P_CopyStyleOut()
	
	setDataFolder root:Packages:GeneralplottingTool
	Wave/T WaveOfStylesInIgor
	Wave NumbersOfStylesinIgor
	variable i
	string ExportName, Overwrite, testName, NbkNm
	NbkNm = "TestNbk"
	For(i=0;i<numpnts(NumbersOfStylesinIgor);i+=1)
		SVAR InStyle=$("root:Packages:plottingToolsStyles:"+PossiblyQuoteName(WaveOfStylesInIgor[i]))
		ExportName=WaveOfStylesInIgor[i]+".dat"
		if (NumbersOfStylesInIgor[i])
			//check that notebook does not exist
			close/A
			OpenNotebook /Z/P=plottingToolStyles /V=0 /N=TestNbk ExportName
			if (V_Flag==0)	//notebook opened, therefore it exists
				Prompt Overwrite, "The style exists, do you want to ovewrite it?", popup, "Yes;No"
				DoPrompt "Overwrite the existing style", Overwrite
				if (V_Flag)
					abort
				endif
				if (cmpstr(Overwrite,"Yes")==0)
					DoWindow /D/K testNbk
				else
					DoWindow /K testNbk
					ExportName = ExportName[0,strlen(ExportName)-5]
					Prompt ExportName, "Change name of style being exported"
					DoPrompt "Change name for exported style", ExportName
					if (V_Flag)
						abort
					endif
					ExportName=ExportName+".dat"
				endif
			endif
			NewNotebook /F=0 /V=0/N=$NbkNm 
			Notebook $NbkNm selection={endOfFile, endOfFile}
			Notebook $NbkNm text=InStyle
			SaveNotebook /S=3/O/P=plottingToolStyles $NbkNm as ExportName
			DoWindow /K testNbk
		endif
	endfor
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1P_CopyStyleIn()
	setDataFolder root:Packages:GeneralplottingTool
	Wave/T WaveOfStylesOutsideIgor
	Wave NumbersOfStylesOutsideIgor
	variable i, IsUnique
	string testNm, InternalNewStyle, Overwrite
	For(i=0;i<numpnts(NumbersOfStylesOutsideIgor);i+=1)
		testNm=WaveOfStylesOutsideIgor[i]+".dat"
		if (NumbersOfStylesOutsideIgor[i])
			//OpenNotebook /P=plottingToolStyles /V=0 /N=testNbk testNm
			LoadWave/J/Q/P=plottingToolStyles/K=2/N=ImportData/V={"\t"," $",0,1} testNm
			Wave/T LoadedData=root:Packages:GeneralplottingTool:ImportData0
			InternalNewStyle = WaveofStylesOutsideIgor[i]
			setDataFolder root:Packages:plottingToolsStyles
			InternalNewStyle = CleanupName(InternalNewStyle,0)
			IsUnique=CheckName(InternalNewStyle,4)
			setDataFolder root:Packages:GeneralplottingTool
			if (IsUnique!=0)
				Prompt Overwrite, "This style exists, overwrite?", popup, "Yes;No"
				DoPrompt "User select overwrite", Overwrite
				if(V_Flag)
					abort
				endif 
				if (cmpstr(Overwrite,"No")==0)
					Prompt InternalNewStyle, "Select new name for this style"
					DoPrompt "User change name of existing style", InternalNewStyle
					if(V_Flag)
						abort
					endif
					InternalNewStyle=CleanupName(InternalNewStyle,1)
				endif
			endif	
			string/g $("root:Packages:plottingToolsStyles:"+InternalNewStyle)
			SVAR NewStyle=$("root:Packages:plottingToolsStyles:"+InternalNewStyle)
			NewStyle = LoadedData[0]
			KillWaves LoadedData
		endif
	endfor
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR1P_DeleteInternalStyle()
	
	setDataFolder root:Packages:GeneralplottingTool
	Wave/T WaveOfStylesInIgor
	Wave NumbersOfStylesinIgor
	variable i
	For(i=0;i<numpnts(NumbersOfStylesinIgor);i+=1)
		SVAR test=$("root:Packages:plottingToolsStyles:"+PossiblyQuoteName(WaveOfStylesInIgor[i]))
		if (NumbersOfStylesinIgor[i])
			killstrings test
		endif
	endfor
	
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR1P_DeleteExternalStyle()
	setDataFolder root:Packages:GeneralplottingTool
	Wave/T WaveOfStylesOutsideIgor
	Wave NumbersOfStylesOutsideIgor
	variable i
	string testNm
	For(i=0;i<numpnts(NumbersOfStylesOutsideIgor);i+=1)
		testNm=WaveOfStylesOutsideIgor[i]+".dat"
		if (NumbersOfStylesOutsideIgor[i])
			OpenNotebook /P=plottingToolStyles /V=0 /N=testNbk testNm
			DoWindow /D/K testNbk
		endif
	endfor
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR1P_RenameDuplicateExtStyle()
	
	setDataFolder root:Packages:GeneralplottingTool
	Wave/T WaveOfStylesOutsideIgor
	Wave NumbersOfStylesOutsideIgor
	variable i
	string renameStr="rename"
	string NewName, testNm, newNameWIthExt
	string NbkNm="testNbk"
	For(i=0;i<numpnts(NumbersOfStylesOutsideIgor);i+=1)
		testNm=WaveOfStylesOutsideIgor[i]+".dat"
		if (NumbersOfStylesOutsideIgor[i])
			Prompt NewName, "Input new name for style "+WaveOfStylesOutsideIgor[i]
			Prompt RenameStr, "Rename or duplicate?", popup, "Rename;duplicate"
			NewName=WaveOfStylesOutsideIgor[i]
			DoPrompt "Input New Name", NewName, RenameStr
			if (V_Flag)
				abort
			endif
			OpenNotebook /P=plottingToolStyles /V=0 /N=$NbkNm testNm
			newNameWIthExt = NewName+".dat"
			if (cmpstr(NewNameWithExt,testNm)==0)
				abort
			endif
			SaveNotebook /S=3/O/P=plottingToolStyles $NbkNm as newNameWIthExt
			if (cmpstr(RenameStr,"Rename")==0)
				DoWindow /D/K testNbk
			else
				DoWindow /K testNbk
			endif
		endif
	endfor
	
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR1P_RenameDuplicateIntStyle()
	
	setDataFolder root:Packages:GeneralplottingTool
	Wave/T WaveOfStylesInIgor
	Wave NumbersOfStylesinIgor
	variable i
	string renameStr="rename"
	string NewName
	For(i=0;i<numpnts(NumbersOfStylesinIgor);i+=1)
		SVAR test=$("root:Packages:plottingToolsStyles:"+PossiblyQuoteName(WaveOfStylesInIgor[i]))
		if (NumbersOfStylesinIgor[i])
			Prompt NewName, "Input new name for style "+WaveOfStylesInIgor[i]
			Prompt RenameStr, "Rename or duplicate?", popup, "Rename;duplicate"
			NewName=WaveOfStylesInIgor[i]
			DoPrompt "Input New Name", NewName, RenameStr
			if (V_Flag)
				abort
			endif
			NewName=PossiblyQuoteName(NewName)
			string FullNewName
			FullNewName = "root:Packages:plottingToolsStyles:"+NewName
			string/g $FullNewName
			SVAR NewStyleString=$FullNewName
			NewStyleString = test
			if (cmpstr(RenameStr,"Rename")==0)
				killstrings test
			endif
		endif
	endfor
	
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR1P_InitExportStyles()

	//create if does not exist the internal place for styles
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:GeneralplottingTool
	NewDataFolder/O root:Packages:plottingToolsStyles
	//now list what is there in appropriate waves
	string ListOfStyles=IN2G_CreateListOfItemsInFolder("root:Packages:plottingToolsStyles", 8)
	Make/O/T/N=(ItemsInList(ListOfStyles)) WaveOfStylesInIgor
	Make/O/N=(ItemsInList(ListOfStyles)) NumbersOfStylesinIgor
	variable i
	For(i=0;i<ItemsInList(ListOfStyles);i+=1)
		WaveOfStylesInIgor[i]=StringFromList(i, ListOfStyles)
	endfor

	sort WaveOfStylesInIgor, WaveOfStylesInIgor
	//above handles files within Igor
	
	//Now outside
	PathInfo Igor
	string IgorPathStr=S_Path
	string/g StylePath=IgorPathStr+"User Procedures:Irena_Saved_styles"
	NewPath/C/O/Q plottingToolStyles, StylePath
	string ListOfExternalStyles=IndexedFile(plottingToolStyles,-1,".dat")

	Make/O/T/N=(ItemsInList(ListOfExternalStyles)) WaveOfStylesOutsideIgor
	Make/O/N=(ItemsInList(ListOfExternalStyles)) NumbersOfStylesOutsideIgor
	For(i=0;i<ItemsInList(ListOfExternalStyles);i+=1)
		WaveOfStylesOutsideIgor[i]=StringFromList(0,StringFromList(i, ListOfExternalStyles),".")
	endfor
	sort WaveOfStylesOutsideIgor, WaveOfStylesOutsideIgor
end


//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
