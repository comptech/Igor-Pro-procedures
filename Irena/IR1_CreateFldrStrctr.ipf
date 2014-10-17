#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2
//these macros create folder structure for users with QRS data and no folder structure


Function IR1F_CreateFldrStrctMain()

	IN2G_CheckScreenSize("height",450)
	IR1F_InitializeCreateFldrStrct()
	DoWindow IR1F_CreateQRSFldrStructure
	if(V_Flag)
		DOwindow/K IR1F_CreateQRSFldrStructure
	endif
	Execute ("IR1F_CreateQRSFldrStructure()")
	
end


Proc IR1F_CreateQRSFldrStructure() 
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1/W=(135,98,551.25,392.75) as "Create QRS Folder Structure"
	DoWindow/C IR1F_CreateQRSFldrStructure
	SetDrawLayer UserBack
	SetDrawEnv fsize= 16,fstyle= 3,textrgb= (0,0,65280)
	DrawText 64,30,"Create folder structure for QRS data"
	PopupMenu SelectFolderWithData,pos={19,49},size={171,21},proc=IR1F_PopMenuProc,title="Select folder with data :"
	PopupMenu SelectFolderWithData,fSize=12,mode=1,popvalue="---",value= #"\"---;\"+IR1_GenStringOfFolders(0, 1,0,0)"
	SetVariable NewFolderForData,pos={16,88},size={380,19},proc=IR1F_SetVarProc,title="Where to create new data folders?"
	SetVariable NewFolderForData,fSize=12
	SetVariable NewFolderForData,value= root:Packages:CreateFldrStructure:NewFldrPath
	Button CreateFolders,pos={124,177},size={150,20},font="Times New Roman",fSize=10,proc=IR1F_ButtonProc,title="Convert structure"
	SetVariable BackupFolder,pos={45,128},size={350,19},proc=IR1F_SetVarProc,title="Backup old data to"
	SetVariable BackupFolder,fSize=12
	SetVariable BackupFolder,value= root:Packages:CreateFldrStructure:NewBackupFldr
EndMacro


Function IR1F_PopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	if (cmpstr(ctrlName,"SelectFolderWithData")==0)
		SVAR FolderWithData=root:Packages:CreateFldrStructure:FolderWithData
		FolderWithData = popStr
	
	endif
End

Function IR1F_SetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	if(cmpstr("NewFolderForData",ctrlName)==0)
	
	endif
	if(cmpstr("BackupFolder",ctrlName)==0)
	
	endif

	
End

Function IR1F_ButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	if(cmpstr(ctrlName,"CreateFolders")==0)
		IR1F_CreateFolders()
	endif

End


Function  IR1F_InitializeCreateFldrStrct()

	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:CreateFldrStructure
	
	string ListOfStrings
	ListOfStrings = "ListOfDataAvailable;FolderWithData;NewFldrPath;NewBackupFldr;"

	variable i
	//and here we create them
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
		SVAR test = $(StringFromList(i,ListOfStrings))
		test = ""
	endfor		

	//set starting values here
	SVAR NewFldrPath
	NewFldrPath = "root:SAS:"
	SVAR NewBackupFldr
	NewBackupFldr = "root:SAS_Data_Backup:"
end	

Function  IR1F_CreateFolders()

	SVAR ListOfDataAvailable=root:Packages:CreateFldrStructure:ListOfDataAvailable
	SVAR FolderWithData=root:Packages:CreateFldrStructure:FolderWithData
	SVAR NewFldrPath=root:Packages:CreateFldrStructure:NewFldrPath
	SVAR NewBackupFldr=root:Packages:CreateFldrStructure:NewBackupFldr

	//first let's see if there are any data available for conversion
	ListOfDataAvailable=IR1F_CreateListQRSOfData(FolderWithData)
	
	if(strlen(NewBackupFldr)>0)
		IR1F_BackupData(ListOfDataAvailable, FolderWithData, NewBackupFldr)
	endif
	
	
	IR1F_MoveData(ListOfDataAvailable, FolderWithData,NewFldrPath )	
	
end


Function	IR1F_MoveData(ListOfDataAvailable, FolderWithData,NewFldrPath )	
	string ListOfDataAvailable, FolderWithData,NewFldrPath
	
	string OldDf
	OldDf = getDataFOlder(1)
	
	variable i
	string RWvname,QWvName,SWvName, SaFldrName
	if(cmpstr(":",NewFldrPath[strlen(NewFldrPath)-1] )!=0)
		NewFldrPath+=":"
	endif
	variable numberOfFldrLevels=ItemsInList(NewFldrPath,":")
	
	setDataFolder root:
	for(i=0;i<numberOfFldrLevels;i+=1)
		if(cmpstr(StringFromList(i, NewFldrPath ,":"),"root")!=0)
			NewDataFolder /O/S $(StringFromList(i, NewFldrPath ,":"))
		endif
	endfor
	
	For(i=0;i<ItemsInList(ListOfDataAvailable);i+=1)
		setDataFolder FolderWithData
		RWvname = StringFromList(i, ListOfDataAvailable)
		QWvName = "Q"+RWvname[1,inf]
		SWvName = "S"+RWvname[1,inf]
		SaFldrName = RWvname[1,inf]
		if(cmpstr(SaFldrName[0],"_")==0)
			SaFldrName=SaFldrName[1,inf]
		endif
		Wave/Z RWave = $RWvname
		Wave/Z QWave = $QWvname
		Wave/Z SWave = $SWvname
		if(WaveExists(RWave) && WaveExists(QWave) &&WaveExists(SWave))
			SetDataFolder NewFldrPath
			if(DataFolderExists(SaFldrName))
				SaFldrName=UniqueName(SaFldrName,11,0)
				SaFldrName=CleanupName(SaFldrName, 0 )
			endif
			NewDataFolder/O/S $(SaFldrName)
			Duplicate /O RWave, $(RWvname)
			Duplicate /O QWave, $(QWvname)
			Duplicate /O SWave, $(SWvname)
//			Duplicate /O RWave, $(NewFldrPath+SaFldrName+":"+RWvname)
//			Duplicate /O QWave, $(NewFldrPath+SaFldrName+":"+QWvname)
//			Duplicate /O SWave, $(NewFldrPath+SaFldrName+":"+SWvname)
			
			KillWaves/Z RWave, QWave, SWave
		endif
	endfor
	
	setDataFolder OldDf

end

Function IR1F_BackupData(ListOfDataAvailable, FolderWithData, NewBackupFldr)
	string ListOfDataAvailable, FolderWithData, NewBackupFldr
	
	string OldDf
	OldDf = getDataFOlder(1)
	
	variable i
	string RWvname,QWvName,SWvName
	if(cmpstr(":",NewBackupFldr[strlen(NewBackupFldr)-1] )!=0)
		NewBackupFldr+=":"
	endif
	variable numberOfFldrLevels=ItemsInList(NewBackupFldr,":")
	
	setDataFolder root:
	for(i=0;i<numberOfFldrLevels;i+=1)
		if(cmpstr(StringFromList(i, NewBackupFldr ,":"),"root")!=0)
			NewDataFolder /O/S $(StringFromList(i, NewBackupFldr ,":"))
		endif
	endfor
	
	setDataFolder FolderWithData
	For(i=0;i<ItemsInList(ListOfDataAvailable);i+=1)
		RWvname = StringFromList(i, ListOfDataAvailable)
		QWvName = "Q"+RWvname[1,inf]
		SWvName = "S"+RWvname[1,inf]
		Wave/Z RWave = $RWvname
		Wave/Z QWave = $QWvname
		Wave/Z SWave = $SWvname
		if(WaveExists(RWave) && WaveExists(QWave) &&WaveExists(SWave))
			Duplicate /O RWave, $(NewBackupFldr+RWvname)
			Duplicate /O QWave, $(NewBackupFldr+QWvname)
			Duplicate /O SWave, $(NewBackupFldr+SWvname)
		endif
	endfor
	
	setDataFOlder OldDf
end

Function/T IR1F_CreateListQRSOfData(FolderWithData)
	string FolderWithData
	
	string OldDf=GetDataFOlder(1)
	setDataFolder FolderWithData
	
	variable NumberOfAllWaves=CountObjects(FolderWithData, 1 )
	variable i
	string ListOfQRSWaves, TempRWaveName, TempQWaveName, TempSWaveName
	ListOfQRSWaves = ""
	FOr(i=0;i<=NumberOfAllWaves;i+=1)
		TempRWaveName = GetIndexedObjName(FolderWithData, 1, i )
		if (cmpstr(TempRWaveName[0],"R")==0)	//the wave starts with R
			TempQWaveName="Q"+TempRWaveName[1,inf]
			TempSWaveName="S"+TempRWaveName[1,inf]
			Wave/Z testQ=$(TempQWaveName)
			Wave/Z testS=$(TempSWaveName)
			if(WaveExists(testQ) && WaveExists(testS))
				ListOfQRSWaves+=TempRWaveName+";"
			endif
			
		endif
		
	endfor

	setDataFolder OldDf
	return ListOfQRSWaves

end