#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.04

//2.03 adds checking for presence of columns of data in the folder - in case user chooses wrong number of columns. 
//2.02 added some print commands in history to let user know what is happening
//2.04 5/10/2010 FIxed issue with naming of teh waves. Used || instead of &&, how come it actually worked (ever)? 

//this should allow user to import data to Igor - let's deal with 3 column data in ASCII for now


Function IR1I_ImportDataMain()
	//IR1_KillGraphsAndPanels()
	IN2G_CheckScreenSize("height",620)
	DoWindow IR1I_ImportData
	if(V_Flag)
		DoWIndow/K IR1I_ImportData
	endif
	IR1I_InitializeImportData()
	Execute("IR1I_ImportData()")
	
	//fix checboxes
	IR1I_FIxCheckboxesForWaveTypes()
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Proc IR1I_ImportData() 
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(3,40,430,660) as "Import data"
	DoWindow/C IR1I_ImportData
	SetDrawLayer UserBack
	SetDrawEnv fsize= 18,fstyle= 1,textrgb= (16384,16384,65280)
	DrawText 84,31,"Import Data in Igor"
	SetDrawEnv linethick= 2,linefgc= (16384,16384,65280)
	DrawLine 21,44,363,44
	DrawText 41,140,"List of available files"
	DrawText 216,231,"Column 1"
	DrawText 216,248,"Column 2"
	DrawText 216,265,"Column 3"
	DrawText 216,282,"Column 4"
	DrawText 216,299,"Column 5"
	DrawText 216,316,"Column 6"
	DrawText 291,211,"Qvec  Int      Err   QErr"
	Button SelectDataPath,pos={99,53},size={130,20},font="Times New Roman",fSize=10,proc=IR1I_ButtonProc,title="Select data path"
	Button SelectDataPath,help={"Select data path to the data"}
	SetVariable DataPathString,pos={2,85},size={415,19},title="Data path :", noedit=1
	SetVariable DataPathString,help={"This is currently selected data path where Igor looks for the data"}
	SetVariable DataPathString,fSize=12,limits={-Inf,Inf,0},value= root:Packages:ImportData:DataPathName
	SetVariable DataExtensionString,pos={220,110},size={150,19},proc=IR1I_SetVarProc,title="Data extension:"
	SetVariable DataExtensionString,help={"Insert extension string to mask data of only some type (dat, txt, ...)"}
	SetVariable DataExtensionString,fSize=12
	SetVariable DataExtensionString,value= root:Packages:ImportData:DataExtension

	CheckBox SkipLines,pos={220,135},size={16,14},proc=IR1I_CheckProc,title="Skip lines?",variable= root:Packages:ImportData:SkipLines, help={"Check if you want to skip lines in header. Needed ONLY for weird headers..."}
	SetVariable SkipNumberOfLines,pos={300,135},size={70,19},proc=IR1I_SetVarProc,title=" "
	SetVariable SkipNumberOfLines,help={"Insert number of lines to skip"}
	SetVariable SkipNumberOfLines,variable= root:Packages:ImportData:SkipNumberOfLines, disable=(!root:Packages:ImportData:SkipLines)

	ListBox ListOfAvailableData,pos={7,148},size={196,244}
	ListBox ListOfAvailableData,help={"Select files from this location you want to import"}
	ListBox ListOfAvailableData,listWave=root:Packages:ImportData:WaveOfFiles
	ListBox ListOfAvailableData,selWave=root:Packages:ImportData:WaveOfSelections
	ListBox ListOfAvailableData,mode= 4
	Button TestImport,pos={210,160},size={80,20},font="Times New Roman",fSize=10,proc=IR1I_ButtonProc,title="Test"
	Button TestImport,help={"Test how if import can be succesful and how many waves are found"}
	Button Preview,pos={300,160},size={80,20},font="Times New Roman",fSize=10,proc=IR1I_ButtonProc,title="Preview"
	Button Preview,help={"Preview selected file."}

	CheckBox Col1Qvec,pos={289,216},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col1Qvec, help={"What does this column contain?"}
	CheckBox Col1Int,pos={321,216},size={16,14},proc=IR1I_CheckProc,title="", variable= root:Packages:ImportData:Col1Int, help={"What does this column contain?"}
	CheckBox Col1Error,pos={354,216},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col1Err, help={"What does this column contain?"}
	CheckBox Col1QError,pos={384,216},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col1QErr, help={"What does this column contain?"}

	CheckBox Col2Qvec,pos={289,233},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col2Qvec, help={"What does this column contain?"}
	CheckBox Col2Int,pos={321,233},size={16,14},proc=IR1I_CheckProc,title="", variable= root:Packages:ImportData:Col2Int, help={"What does this column contain?"}
	CheckBox Col2Error,pos={354,233},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col2Err, help={"What does this column contain?"}
	CheckBox Col2QError,pos={384,233},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col2QErr, help={"What does this column contain?"}

	CheckBox Col3Qvec,pos={289,250},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col3Qvec, help={"What does this column contain?"}
	CheckBox Col3Int,pos={321,250},size={16,14},proc=IR1I_CheckProc,title="", variable= root:Packages:ImportData:Col3Int, help={"What does this column contain?"}
	CheckBox Col3Error,pos={354,250},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col3Err, help={"What does this column contain?"}
	CheckBox Col3QError,pos={384,250},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col3QErr, help={"What does this column contain?"}

	CheckBox Col4Qvec,pos={289,267},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col4Qvec, help={"What does this column contain?"}
	CheckBox Col4Int,pos={321,267},size={16,14},proc=IR1I_CheckProc,title="", variable= root:Packages:ImportData:Col4Int, help={"What does this column contain?"}
	CheckBox Col4Error,pos={354,267},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col4Err, help={"What does this column contain?"}
	CheckBox Col4QError,pos={384,267},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col4QErr, help={"What does this column contain?"}

	CheckBox Col5Qvec,pos={289,284},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col5Qvec, help={"What does this column contain?"}
	CheckBox Col5Int,pos={321,284},size={16,14},proc=IR1I_CheckProc,title="", variable= root:Packages:ImportData:Col5Int, help={"What does this column contain?"}
	CheckBox Col5Error,pos={354,284},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col5Err, help={"What does this column contain?"}
	CheckBox Col5QError,pos={384,284},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col5QErr, help={"What does this column contain?"}

	CheckBox Col6Qvec,pos={289,301},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col6Qvec, help={"What does this column contain?"}
	CheckBox Col6Int,pos={321,301},size={16,14},proc=IR1I_CheckProc,title="", variable= root:Packages:ImportData:Col6Int, help={"What does this column contain?"}
	CheckBox Col6Error,pos={354,301},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col6Err, help={"What does this column contain?"}
	CheckBox Col6QError,pos={384,301},size={16,14},proc=IR1I_CheckProc,title="",variable= root:Packages:ImportData:Col6QErr, help={"What does this column contain?"}


	SetVariable FoundNWaves,pos={220,325},size={130,19},title="Found columns :",proc=IR1I_SetVarProc
	SetVariable FoundNWaves,help={"This is how many columns were found in the tested file"}
	SetVariable FoundNWaves,limits={0,Inf,1},value= root:Packages:ImportData:FoundNWaves

	CheckBox QvectorInA,pos={240,350},size={16,14},proc=IR1I_CheckProc,title="Qvec units [A^-1]",variable= root:Packages:ImportData:QvectInA, help={"What units is Q in? Select if in Angstroems ^-1"}
	CheckBox QvectorInNM,pos={240,365},size={16,14},proc=IR1I_CheckProc,title="Qvec units [nm^-1]",variable= root:Packages:ImportData:QvectInNM, help={"What units is Q in? Select if in nanometers ^-1. WIll be converted to inverse Angstroems"}
	CheckBox CreateSQRTErrors,pos={240,380},size={16,14},proc=IR1I_CheckProc,title="Create SQRT Errors?",variable= root:Packages:ImportData:CreateSQRTErrors, help={"If input data do not contain errors, create errors as sqrt of intensity?"}
	CheckBox CreatePercentErrors,pos={240,395},size={16,14},proc=IR1I_CheckProc,title="Create n% Errors?",variable= root:Packages:ImportData:CreatePercentErrors, help={"If input data do not contain errors, create errors as n% of intensity?, select how many %"}
	SetVariable PercentErrorsToUse, pos={240,415}, size={100,20},title="Error %?:", proc=IR1I_setvarProc, disable=!(root:Packages:ImportData:CreatePercentErrors)
	SetVariable PercentErrorsToUse value= root:packages:ImportData:PercentErrorsToUse,help={"Input how many percent error you want to create."}

	Button SelectAll,pos={5,400},size={100,20},font="Times New Roman",fSize=10,proc=IR1I_ButtonProc,title="Select All"
	Button SelectAll,help={"Select all waves in the list"}

	Button DeSelectAll,pos={120,400},size={100,20},font="Times New Roman",fSize=10,proc=IR1I_ButtonProc,title="Deselect All"
	Button DeSelectAll,help={"Deselect all waves in the list"}

	CheckBox UseFileNameAsFolder,pos={10,430},size={16,14},proc=IR1I_CheckProc,title="Use File Nms As Fldr Nms?",variable= root:Packages:ImportData:UseFileNameAsFolder, help={"Use names of imported files as folder names for the data?"}
	CheckBox UseIndra2Names,pos={10,445},size={16,14},proc=IR1I_CheckProc,title="Use Indra 2 wave names?",variable= root:Packages:ImportData:UseIndra2Names, help={"Use wave names using Indra 2 name structure? (DSM_Int, DSM_Qvec, DSM_Error)"}
	CheckBox ImportSMRdata,pos={170,445},size={16,14},proc=IR1I_CheckProc,title="Slit smeared?",variable= root:Packages:ImportData:ImportSMRdata, help={"Check if the data are slit smeared, changes suggested Indra data names to SMR_Qvec, SMR_Int, SMR_error"}
	CheckBox ImportSMRdata, disable= !root:Packages:ImportData:UseIndra2Names
	CheckBox UseQRSNames,pos={10,460},size={16,14},proc=IR1I_CheckProc,title="Use QRS wave names?",variable= root:Packages:ImportData:UseQRSNames, help={"Use QRS name structure? (Q_filename, R_filename, S_filename)"}
	CheckBox UseQISNames,pos={220,460},size={16,14},proc=IR1I_CheckProc,title="Use QIS (NIST) wave names?",variable= root:Packages:ImportData:UseQISNames, help={"Use QIS name structure? (filename_q, filename_i, filename_s)"}


	CheckBox IncludeExtensionInName,pos={220,430},size={16,14},proc=IR1I_CheckProc,title="Include Extension in fldr nm?",variable= root:Packages:ImportData:IncludeExtensionInName, help={"Include file extension in imported data foldername?"}, disable=!(root:Packages:ImportData:UseFileNameAsFolder)
	CheckBox ScaleImportedDataCheckbox,pos={220,445},size={16,14},proc=IR1I_CheckProc,title="Scale Imported data?",variable= root:Packages:ImportData:ScaleImportedData, help={"Check to scale (multiply by) factor imported data. Both Intensity and error will be scaled by same number. Insert appriate number below."}
	SetVariable ScaleImportedDataBy, pos={220,460}, size={150,20},title="Scaling factor?:", proc=IR1I_setvarProc, disable=!(root:Packages:ImportData:ScaleImportedData)
	SetVariable ScaleImportedDataBy limits={1e-32,inf,1},value= root:packages:ImportData:ScaleImportedDataBy,help={"Input number by which you want to multiply the imported intensity and errors."}

	PopupMenu SelectFolderNewData,pos={1,485},size={250,21},proc=IR1I_PopMenuProc,title="Select data folder", help={"Select folder with data"}
	PopupMenu SelectFolderNewData,mode=1,popvalue="---",value= #"\"---;\"+IR1_GenStringOfFolders(0, 0,0,0)"

	SetVariable NewDataFolderName, pos={5,510}, size={410,20},title="New data folder:", proc=IR1I_setvarProc
	SetVariable NewDataFolderName value= root:packages:ImportData:NewDataFolderName,help={"Folder for the new data. Will be created, if does not exist. Use popup above to preselect."}
	SetVariable NewQwaveName, pos={5,530}, size={320,20},title="Q wave names ", proc=IR1I_setvarProc
	SetVariable NewQwaveName, value= root:packages:ImportData:NewQWaveName,help={"Input name for the new Q wave"}
	SetVariable NewIntensityWaveName, pos={5,550}, size={320,20},title="Intensity names", proc=IR1I_setvarProc
	SetVariable NewIntensityWaveName, value= root:packages:ImportData:NewIntensityWaveName,help={"Input name for the new intensity wave"}
	SetVariable NewErrorWaveName, pos={5,570}, size={320,20},title="Error wv names", proc=IR1I_setvarProc
	SetVariable NewErrorWaveName, value= root:packages:ImportData:NewErrorWaveName,help={"Input name for the new Error wave"}
	SetVariable NewQErrorWaveName, pos={5,590}, size={320,20},title="Q Error wv names", proc=IR1I_setvarProc
	SetVariable NewQErrorWaveName, value= root:packages:ImportData:NewQErrorWaveName,help={"Input name for the new Q data Error wave"}

	Button ImportData,pos={330,550},size={80,30},font="Times New Roman",fSize=10,proc=IR1I_ButtonProc,title="Import"
	Button ImportData,help={"Import the selected data files."}

EndMacro

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IR1I_ImportDataFnct()

	string OldDf = getDataFolder(1)
	
	Wave/T WaveOfFiles      = root:Packages:ImportData:WaveOfFiles
	Wave WaveOfSelections = root:Packages:ImportData:WaveOfSelections

	IR1I_CheckForProperNewFolder()
	variable i, imax, icount
	string SelectedFile
	imax = numpnts(WaveOfSelections)
	icount = 0
	for(i=0;i<imax;i+=1)
		if (WaveOfSelections[i])
			selectedfile = WaveOfFiles[i]
			IR1I_CreateImportDataFolder(selectedFile)
			KillWaves/Z TempIntensity, TempQvector, TempError
			IR1I_ImportOneFile(selectedFile)
			IR1I_NameImportedWaves(selectedFile)
			IR1I_RecordResults(selectedFile)
			icount+=1
		endif
	endfor
	print "Imported "+num2str(icount)+" data file(s) in total"
	setDataFolder OldDf
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1I_CheckForProperNewFolder()

	SVAR NewDataFolderName = root:packages:ImportData:NewDataFolderName
	if (strlen(NewDataFolderName)>0 && cmpstr(":",NewDataFolderName[strlen(NewDataFolderName)-1])!=0)
		NewDataFolderName = NewDataFolderName + ":"
	endif
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IR1I_RecordResults(selectedFile)
	string selectedFile	//before or after - that means fit...

	string OldDF=GetDataFolder(1)
	setdataFolder root:Packages:ImportData

	SVAR DataPathName=root:Packages:ImportData:DataPathName
	SVAR NewDataFolderName=root:Packages:ImportData:NewDataFolderName
	SVAR NewIntensityWaveName=root:Packages:ImportData:NewIntensityWaveName
	SVAR NewQWaveName=root:Packages:ImportData:NewQWaveName
	SVAR NewErrorWaveName=root:Packages:ImportData:NewErrorWaveName	
	SVAR NewQErrorWaveName=root:Packages:ImportData:NewQErrorWaveName	
	string NewFldrNm,NewIntName, NewQName, NewEName, NewQEName, tempFirstPart, tempLastPart
	
	if(stringMatch(NewDataFolderName,"*<fileName>*")==0)
		NewFldrNm = CleanupName(NewDataFolderName, 1 )
	else
		TempFirstPart = NewDataFolderName[0,strsearch(NewDataFolderName, "<fileName>", 0 )-1]
		tempLastPart  = NewDataFolderName[strsearch(NewDataFolderName, "<fileName>", 0 )+10,inf]
		NewFldrNm = TempFirstPart+CleanupName(StringFromList(0,selectedFile,"."), 1 )+tempLastPart
	endif
	if(stringMatch(NewIntensityWaveName,"*<fileName>*")==0)
		NewIntName = CleanupName(NewIntensityWaveName, 1 )
	else
		TempFirstPart = NewIntensityWaveName[0,strsearch(NewIntensityWaveName, "<fileName>", 0 )-1]
		tempLastPart  = NewIntensityWaveName[strsearch(NewIntensityWaveName, "<fileName>", 0 )+10,inf]
		NewIntName = TempFirstPart+StringFromList(0,selectedFile,".")+tempLastPart
		NewIntName = CleanupName(NewIntName, 1 )
	endif
	if(stringMatch(NewQwaveName,"*<fileName>*")==0)
		NewQName = CleanupName(NewQwaveName, 1 )
	else
		TempFirstPart = NewQwaveName[0,strsearch(NewQwaveName, "<fileName>", 0 )-1]
		tempLastPart  = NewQwaveName[strsearch(NewQwaveName, "<fileName>", 0 )+10,inf]
		NewQName = TempFirstPart+StringFromList(0,selectedFile,".")+tempLastPart
		NewQName = CleanupName(NewQName, 1 )
	endif
	if(stringMatch(NewErrorWaveName,"*<fileName>*")==0)
		NewEName = CleanupName(NewErrorWaveName, 1 )
	else
		TempFirstPart = NewErrorWaveName[0,strsearch(NewErrorWaveName, "<fileName>", 0 )-1]
		tempLastPart  = NewErrorWaveName[strsearch(NewErrorWaveName, "<fileName>", 0 )+10,inf]
		NewEName = TempFirstPart+StringFromList(0,selectedFile,".")+tempLastPart
		NewEName = CleanupName(NewEName, 1 )
	endif
	if(stringMatch(NewQErrorWaveName,"*<fileName>*")==0)
		NewQEName = CleanupName(NewQErrorWaveName, 1 )
	else
		TempFirstPart = NewQErrorWaveName[0,strsearch(NewQErrorWaveName, "<fileName>", 0 )-1]
		tempLastPart  = NewQErrorWaveName[strsearch(NewQErrorWaveName, "<fileName>", 0 )+10,inf]
		NewQEName = TempFirstPart+StringFromList(0,selectedFile,".")+tempLastPart
		NewQEName = CleanupName(NewQEName, 1 )
	endif

	NVAR DataContainErrors=root:Packages:ImportData:DataContainErrors
	NVAR CreateSQRTErrors=root:Packages:ImportData:CreateSQRTErrors
	NVAR CreatePercentErrors=root:Packages:ImportData:CreatePercentErrors
	NVAR PercentErrorsToUse=root:Packages:ImportData:PercentErrorsToUse
	NVAR ScaleImportedData=root:Packages:ImportData:ScaleImportedData
	NVAR ScaleImportedDataBy=root:Packages:ImportData:ScaleImportedDataBy
	NVAR ImportSMRdata=root:Packages:ImportData:ImportSMRdata
	NVAR SkipLines=root:Packages:ImportData:SkipLines
	NVAR SkipNumberOfLines =root:Packages:ImportData:SkipNumberOfLines
	NVAR QvectInA=root:Packages:ImportData:QvectInA
	NVAR QvectInNM=root:Packages:ImportData:QvectInNM

	IR1_CreateLoggbook()		//this creates the logbook
	SVAR nbl=root:Packages:SAS_Modeling:NotebookName

	IR1L_AppendAnyText("     ")
	IR1L_AppendAnyText("***********************************************")
	IR1L_AppendAnyText("***********************************************")
	IR1L_AppendAnyText("Data load record ")
	IR1_InsertDateAndTime(nbl)
	IR1L_AppendAnyText("File path and file name \t"+DataPathName+selectedFile)
	IR1L_AppendAnyText(" ")
	IR1L_AppendAnyText("Loaded on       \t\t\t"+ Date()+"    "+time())
	IR1L_AppendAnyText("Data stored in : \t\t \t"+ NewFldrNm)
	IR1L_AppendAnyText("New waves named (Int,q,error) :  \t"+ NewIntName+"\t"+NewQName+"\t"+NewEName)
	IR1L_AppendAnyText("Comments and processing:")
	if(DataContainErrors)
		IR1L_AppendAnyText("Data Contained errors")	
	elseif(CreateSQRTErrors)
		IR1L_AppendAnyText("Data did not contain errors, created sqrt(int) errors")	
	elseif(CreatePercentErrors)
		IR1L_AppendAnyText("Data did not contain errors, created %(Int) errors, used "+num2str(PercentErrorsToUse)+"  %")	
	endif
	if(ScaleImportedData)
		IR1L_AppendAnyText("Data (Intensity and error) scaled by \t "+num2str(ScaleImportedDataBy))	
	endif
	if(QvectInA)
		IR1L_AppendAnyText("Q was in A")	
	elseif(QvectInNM)
		IR1L_AppendAnyText("Q was in nm, scaled to A ")	
	endif
	if(SkipLines)
		IR1L_AppendAnyText("Following number of lines was skiped from the original file "+num2str(SkipNumberOfLines))	
	endif

	//and print in history, so user has some feedback...
	print "Imported data from :"+DataPathName+selectedFile+"\r"
	print "\tData stored in :\t\t\t"+NewFldrNm
	print  "\tNew Wave names are :\t"+ NewIntName+"\t"+NewQName+"\t"+NewEName+"\r"
	setdataFolder oldDf
end


//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1I_NameImportedWaves(selectedFile)
	string selectedFile

	variable i, numOfInts, numOfQs, numOfErrs, numOfQErrs, refNum
	numOfInts  = 0
	numOfQs   = 0
	numOfErrs = 0
	numOfQErrs = 0
	string HeaderFromData=""
	NVAR SkipNumberOfLines=root:Packages:ImportData:SkipNumberOfLines
	NVAR SkipLines=root:Packages:ImportData:SkipLines	
	NVAR FoundNWaves = root:Packages:ImportData:FoundNWaves
	if(!SkipLines)			//lines automatically skipped, so the header may make sense, add to header...
	        Open/R/P=ImportDataPath refNum as selectedFile
		HeaderFromData=""
	        Variable j
 	       String text
  	      For(j=0;j<SkipNumberOfLines;j+=1)
   	             FReadLine refNum, text
 			HeaderFromData+=IN2G_ZapControlCodes(text)+";"
		endfor        
	      Close refNum
	endif	
	For(i=0;i<FoundNWaves;i+=1)	
		NVAR testIntStr = $("root:Packages:ImportData:Col"+num2str(i+1)+"Int")
		NVAR testQvecStr = $("root:Packages:ImportData:Col"+num2str(i+1)+"Qvec")
		NVAR testErrStr = $("root:Packages:ImportData:Col"+num2str(i+1)+"Err")
		NVAR testQErrStr = $("root:Packages:ImportData:Col"+num2str(i+1)+"QErr")
		Wave/Z CurrentWave = $("wave"+num2str(i))
		SVAR DataPathName=root:Packages:ImportData:DataPathName
		if (testIntStr&&WaveExists(CurrentWave))
			duplicate/O CurrentWave, TempIntensity
			note TempIntensity, "Data imported from folder="+DataPathName+";Data file name="+selectedFile+";"+HeaderFromData
			numOfInts+=1
		endif
		if (testQvecStr&&WaveExists(CurrentWave))
			duplicate/O CurrentWave, TempQvector
			note TempQvector, "Data imported from folder="+DataPathName+";Data file name="+selectedFile+";"+HeaderFromData
			numOfQs+=1
		endif
		if (testErrStr&&WaveExists(CurrentWave))
			duplicate/O CurrentWave, TempError
			note TempError, "Data imported from folder="+DataPathName+";Data file name="+selectedFile+";"+HeaderFromData
			numOfErrs+=1
		endif
		if (testQErrStr&&WaveExists(CurrentWave))
			duplicate/O CurrentWave, TempQError
			note TempQError, "Data imported from folder="+DataPathName+";Data file name="+selectedFile+";"+HeaderFromData
			numOfQErrs+=1
		endif
		if(!WaveExists(CurrentWave))
			string Messg="Error, the column of data selected did not exist in the data file. The missing column is : "
			if(testIntStr)
				Messg+="Intensity"
			elseif(testQvecStr)
				Messg+="Q vector"
			elseif(testErrStr)
				Messg+="Error"
			elseif(testQErrStr)
				Messg+="Q Error"
			endif
			DoAlert 0, Messg 
		endif
	endfor
	if (numOfInts!=1 || numOfQs!=1 || numOfErrs>1|| numOfQErrs>1)
		Abort "Import waves problem, check values in checkboxes which indicate which column contains Intensity, Q and error"
	endif

	//here we will modify the data if user wants to do so...
	NVAR QvectInA=root:Packages:ImportData:QvectInA
	NVAR QvectInNM=root:Packages:ImportData:QvectInNM
	NVAR ScaleImportedData=root:Packages:ImportData:ScaleImportedData
	NVAR ScaleImportedDataBy=root:Packages:ImportData:ScaleImportedDataBy
	if (QvectInNM)
		TempQvector=TempQvector/10			//converts nm-1 in A-1  ???
		note TempQvector, "Q data converted from nm to A-1;"
	endif
	if (ScaleImportedData)
		TempIntensity=TempIntensity*ScaleImportedDataBy		//scales imported data for user
		note TempIntensity, "Data scaled by="+num2str(ScaleImportedDataBy)+";"
		if (WaveExists(TempError))
			TempError=TempError*ScaleImportedDataBy		//scales imported data for user
			note TempError, "Data scaled by="+num2str(ScaleImportedDataBy)+";"
		endif
	endif
	//here we will deal with erros, if the user needs to create them
	NVAR CreateSQRTErrors=root:Packages:ImportData:CreateSQRTErrors
	NVAR CreatePercentErrors=root:Packages:ImportData:CreatePercentErrors
	NVAR PercentErrorsToUse=root:Packages:ImportData:PercentErrorsToUse
	if ((CreatePercentErrors||CreateSQRTErrors) && WaveExists(TempError))	
		DoAlert 0, "Debugging message: Should create SQRT errors, but error wave exists. Mess in the checkbox values..."
	endif
	if (CreateSQRTErrors && !WaveExists(TempError))
		Duplicate/O TempIntensity, TempError
		TempError = sqrt(TempIntensity)
		note TempError, "Error data created for user as SQRT of intensity;"
	endif
	if (CreatePercentErrors && !WaveExists(TempError))
		Duplicate/O TempIntensity, TempError
		TempError = TempIntensity * (PercentErrorsToUse/100)
		note TempError, "Error data created for user as percentage of intensity;Amount of error as percentage="+num2str(PercentErrorsToUse/100)+";"
	endif

	SVAR NewIntensityWaveName= root:packages:ImportData:NewIntensityWaveName
	SVAR NewQwaveName= root:packages:ImportData:NewQWaveName
	SVAR NewErrorWaveName= root:packages:ImportData:NewErrorWaveName
	SVAR NewQErrorWaveName= root:packages:ImportData:NewQErrorWaveName
	NVAR IncludeExtensionInName=root:packages:ImportData:IncludeExtensionInName
	string NewIntName, NewQName, NewEName, NewQEName, tempFirstPart, tempLastPart
	
	if(stringMatch(NewIntensityWaveName,"*<fileName>*")==0)
		NewIntName = CleanupName(NewIntensityWaveName, 1 )
	else
		TempFirstPart = NewIntensityWaveName[0,strsearch(NewIntensityWaveName, "<fileName>", 0 )-1]
		tempLastPart  = NewIntensityWaveName[strsearch(NewIntensityWaveName, "<fileName>", 0 )+10,inf]
		if(IncludeExtensionInName)
			NewIntName = TempFirstPart+selectedFile+tempLastPart
		else
			NewIntName = TempFirstPart+StringFromList(0,selectedFile,".")+tempLastPart
		endif
		NewIntName = CleanupName(NewIntName, 1 )
	endif
	if(stringMatch(NewQwaveName,"*<fileName>*")==0)
		NewQName = CleanupName(NewQwaveName, 1 )
	else
		TempFirstPart = NewQwaveName[0,strsearch(NewQwaveName, "<fileName>", 0 )-1]
		tempLastPart  = NewQwaveName[strsearch(NewQwaveName, "<fileName>", 0 )+10,inf]
		if(IncludeExtensionInName)
			NewQName = TempFirstPart+selectedFile+tempLastPart
		else
			NewQName = TempFirstPart+StringFromList(0,selectedFile,".")+tempLastPart
		endif
		NewQName = CleanupName(NewQName, 1 )
	endif
	if(stringMatch(NewErrorWaveName,"*<fileName>*")==0)
		NewEName = CleanupName(NewErrorWaveName, 1 )
	else
		TempFirstPart = NewErrorWaveName[0,strsearch(NewErrorWaveName, "<fileName>", 0 )-1]
		tempLastPart  = NewErrorWaveName[strsearch(NewErrorWaveName, "<fileName>", 0 )+10,inf]
		if(IncludeExtensionInName)
			NewEName = TempFirstPart+selectedFile+tempLastPart
		else
			NewEName = TempFirstPart+StringFromList(0,selectedFile,".")+tempLastPart
		endif
		NewEName = CleanupName(NewEName, 1 )
	endif
	if(stringMatch(NewQErrorWaveName,"*<fileName>*")==0)
		NewQEName = CleanupName(NewQErrorWaveName, 1 )
	else
		TempFirstPart = NewQErrorWaveName[0,strsearch(NewQErrorWaveName, "<fileName>", 0 )-1]
		tempLastPart  = NewQErrorWaveName[strsearch(NewQErrorWaveName, "<fileName>", 0 )+10,inf]
		if(IncludeExtensionInName)
			NewQEName = TempFirstPart+selectedFile+tempLastPart
		else
			NewQEName = TempFirstPart+StringFromList(0,selectedFile,".")+tempLastPart
		endif
		NewQEName = CleanupName(NewQEName, 1 )
	endif

	Wave/Z testE=$NewEName
	Wave/Z testQ=$NewQName
	Wave/Z testI=$NewIntName
	Wave/Z testQE=$NewQEName
	if (WaveExists(testI) || WaveExists(testQ)||WaveExists(testE)||WaveExists(testQE))
		DoAlert 1, "The data of this name : "+NewIntName+" , "+NewQName+ " , "+NewEName+" , or "+NewQEName+"  exist. DO you want to overwrite them?"
		if (V_Flag==2)
			abort
		endif
	endif
		
	Duplicate/O TempQvector, $NewQName
	Duplicate/O TempIntensity, $NewIntName
	if(WaveExists(TempError))
		Duplicate/O TempError, $NewEName
	endif	
	if(WaveExists(TempQError))
		Duplicate/O TempQError, $NewQEName
	endif	
	KillWaves/Z tempError, tempQvector, TempIntensity, TempQError

//	NVAR UseFileNameAsFolder = root:Packages:ImportData:UseFileNameAsFolder
//	NVAR UseIndra2Names = root:Packages:ImportData:UseIndra2Names
//	NVAR UseQRSNames = root:Packages:ImportData:UseQRSNames
//
//	SVAR NewDataFolderName = root:packages:ImportData:NewDataFolderName
//	SVAR NewIntensityWaveName= root:packages:ImportData:NewIntensityWaveName
//	SVAR NewQwaveName= root:packages:ImportData:NewQWaveName
//	SVAR NewErrorWaveName= root:packages:ImportData:NewErrorWaveName

	IR1I_KillAutoWaves()
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1I_ImportOneFile(selectedFile)
	string selectedFile
		
	NVAR SkipNumberOfLines=root:Packages:ImportData:SkipNumberOfLines
	NVAR SkipLines=root:Packages:ImportData:SkipLines	
	IR1I_KillAutoWaves()
//	LoadWave/Q/A/G/P=ImportDataPath  selectedfile
	if (SkipLines)
		LoadWave/Q/A/G/L={0, SkipNumberOfLines, 0, 0, 0}/P=ImportDataPath  selectedfile
	else
		LoadWave/Q/A/G/P=ImportDataPath  selectedfile
		SkipNumberOfLines = IR1I_CountHeaderLines("ImportDataPath", selectedfile)
	endif

end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1I_CountHeaderLines(pathName, fileName)
        String pathName         // Symbolic path name
        String fileName                 // File name or full path
        String FirstPoint		//string containing first point number.... 
        
        Variable refNum = 0
        
        Open/R/P=$pathName refNum as fileName
        if (refNum == 0)
                return -1                                               // File was not opened. Probably bad file name.
        endif
        
        Variable tmp
        Variable count = 0
        String text
        do
                FReadLine refNum, text
                if (strlen(text) == 0)
                        break
                endif
                
                sscanf text, "%g", tmp
                if (V_flag == 1)                                // Found a number at the start of the line?
                        break                                           // This marks the start of the numeric data.
                endif
//			if( strsearch(text, FirstPoint, 0) >= 0)
//			        break   //found first data point
//			endif              
                count += 1
        while(1)
        
        Close refNum
        
        return count
End
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1I_KillAutoWaves()

	variable i
	for(i=0;i<=100;i+=1)
		Wave/Z test = $("wave"+num2str(i))
		KillWaves/Z test
	endfor
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1I_CreateImportDataFolder(selectedFile)
	string selectedFile

	SVAR NewDataFolderName = root:packages:ImportData:NewDataFolderName
	NVAR IncludeExtensionInName = root:packages:ImportData:IncludeExtensionInName
	variable i
	string tempFldrName, tempSelectedFile
	setDataFolder root:
	For (i=0;i<ItemsInList(NewDataFolderName, ":");i+=1)
		tempFldrName = StringFromList(i, NewDataFolderName , ":")
		if (cmpstr(tempFldrName,"<fileName>")!=0 )
			if(cmpstr(tempFldrName,"root")!=0)
				NewDataFolder/O/S $(cleanupName(IN2G_RemoveExtraQuote(tempFldrName,1,1),1))
			endif
		else
			if(!IncludeExtensionInName)
				selectedFile = stringFromList(0,selectedFile,".")
			endif
			selectedFile = CleanupName(selectedFile, 1 )
			NewDataFolder/O/S $selectedFile
		endif
	endfor
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************


Function IR1I_PopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	if (Cmpstr(ctrlName,"SelectFolderNewData")==0)
		SVAR NewDataFolderName = root:packages:ImportData:NewDataFolderName
		NewDataFolderName = popStr
			NVAR UseFileNameAsFolder = root:Packages:ImportData:UseFileNameAsFolder
			if (UseFileNameAsFolder)
				NewDataFolderName+="<fileName>:"
			endif		
	endif
End
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1I_SetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	if (cmpstr(ctrlName,"DataExtensionString")==0)
		IR1I_UpdateListOfFilesInWvs()
	endif
	if (cmpstr(ctrlName,"FoundNWaves")==0)
		IR1I_FIxCheckboxesForWaveTypes()
	endif
	
End

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IR1I_ButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	if(cmpstr(ctrlName,"SelectDataPath")==0)
		IR1I_SelectDataPath()	
		IR1I_UpdateListOfFilesInWvs()
	endif
	if(cmpstr(ctrlName,"TestImport")==0)
		IR1I_testImport()
	endif
	if(cmpstr(ctrlName,"Preview")==0)
		IR1I_TestImportNotebook()
	endif
	if(cmpstr(ctrlName,"SelectAll")==0)
		IR1I_SelectDeselectAll(1)
	endif
	if(cmpstr(ctrlName,"DeselectAll")==0)
		IR1I_SelectDeselectAll(0)
	endif
	if(cmpstr(ctrlName,"ImportData")==0)
		IR1I_ImportDataFnct()
	endif
End
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1I_SelectDeselectAll(SetNumber)
		variable setNumber
		
		Wave WaveOfSelections=root:Packages:ImportData:WaveOfSelections

		WaveOfSelections = SetNumber
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IR1I_TestImport()
	
	Wave/T WaveOfFiles      = root:Packages:ImportData:WaveOfFiles
	Wave WaveOfSelections = root:Packages:ImportData:WaveOfSelections
	NVAR FoundNWaves = root:Packages:ImportData:FoundNWaves
	NVAR SkipNumberOfLines=root:Packages:ImportData:SkipNumberOfLines
	NVAR SkipLines=root:Packages:ImportData:SkipLines
	FoundNWaves = 0
	
	variable i, imax, firstSelectedPoint, maxWaves
	string SelectedFile
	imax = numpnts(WaveOfSelections)
	firstSelectedPoint = NaN
	For(i=0;i<numpnts(WaveOfSelections);i+=1)
		if(WaveOfSelections[i]==1)
			firstSelectedPoint = i
			break
		endif
	endfor
	if (numtype(firstSelectedPoint)==2)
		abort
	endif
	selectedfile = WaveOfFiles[firstSelectedPoint]
	
	killWaves/Z wave0, wave1, wave2, wave3, wave4, wave5, wave6,wave7,wave8,wave9
	
	if (SkipLines)
		LoadWave/Q/A/G/L={0, SkipNumberOfLines, 0, 0, 0}/P=ImportDataPath  selectedfile
		FoundNWaves = V_Flag
	else
		LoadWave/Q/A/G/P=ImportDataPath  selectedfile
		FoundNWaves = V_Flag
	endif
	//now fix the checkboxes as needed
	IR1I_FIxCheckboxesForWaveTypes()
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IR1I_TestImportNotebook()

	Wave/T WaveOfFiles      = root:Packages:ImportData:WaveOfFiles
	Wave WaveOfSelections = root:Packages:ImportData:WaveOfSelections
	variable i, imax, firstSelectedPoint, maxWaves
	string SelectedFile
	imax = numpnts(WaveOfSelections)
	firstSelectedPoint = NaN
	For(i=0;i<numpnts(WaveOfSelections);i+=1)
		if(WaveOfSelections[i]==1)
			firstSelectedPoint = i
			break
		endif
	endfor
	if (numtype(firstSelectedPoint)==2)
		abort
	endif
	selectedfile = WaveOfFiles[firstSelectedPoint]
	
	
	//LoadWave/Q/A/G/P=ImportDataPath  selectedfile
	DOwindow FilePreview
	if (V_Flag)
		DoWindow/K FilePreview
	endif
	OpenNotebook /K=1 /N=FilePreview /P=ImportDataPath /R /V=1 selectedfile
	MoveWindow /W=FilePreview 350, 5, 700, 400	
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1I_FIxCheckboxesForWaveTypes()

	NVAR FoundNWaves = root:Packages:ImportData:FoundNWaves
	variable maxWaves, i
	maxWaves = FoundNWaves
	if (MaxWaves>6)
		MaxWaves = 6
	endif

	For (i=1;i<=MaxWaves;i+=1)
		CheckBox $("Col"+num2str(i)+"Int") disable=0, win=IR1I_ImportData
		CheckBox $("Col"+num2str(i)+"Qvec") disable=0, win=IR1I_ImportData
		CheckBox $("Col"+num2str(i)+"Error") disable=0, win=IR1I_ImportData
		CheckBox $("Col"+num2str(i)+"QError") disable=0, win=IR1I_ImportData
	endfor
	For (i=FoundNWaves+1;i<=6;i+=1)
		CheckBox $("Col"+num2str(i)+"Int") disable=1, win=IR1I_ImportData
		CheckBox $("Col"+num2str(i)+"Qvec") disable=1, win=IR1I_ImportData
		CheckBox $("Col"+num2str(i)+"Error") disable=1, win=IR1I_ImportData
		CheckBox $("Col"+num2str(i)+"QError") disable=1, win=IR1I_ImportData
		NVAR ColInt=$("root:Packages:ImportData:Col"+num2str(i)+"Int")
		NVAR ColQvec=$("root:Packages:ImportData:Col"+num2str(i)+"Qvec")
		NVAR ColErr=$("root:Packages:ImportData:Col"+num2str(i)+"Err")
		NVAR ColQErr=$("root:Packages:ImportData:Col"+num2str(i)+"QErr")
		ColInt=0
		ColQvec=0
		ColErr=0
		ColQErr=0
	endfor
	
	NVAR Col1QErr=root:Packages:ImportData:Col1QErr
	NVAR Col2QErr=root:Packages:ImportData:Col2QErr
	NVAR Col3QErr=root:Packages:ImportData:Col3QErr
	NVAR Col4QErr=root:Packages:ImportData:Col4QErr
	NVAR Col5QErr=root:Packages:ImportData:Col5QErr
	NVAR Col6QErr=root:Packages:ImportData:Col6QErr
	if(Col6QErr || Col5QErr || Col4QErr || Col3QErr || Col2QErr || Col1QErr)
		SetVariable NewQErrorWaveName, disable = 0 
	else	
		SetVariable NewQErrorWaveName, disable = 1
	endif

end


//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1I_SelectDataPath()

	NewPath /M="Select path to data to be imported" /O ImportDataPath
	if (V_Flag!=0)
		abort
	endif 
	PathInfo ImportDataPath
	SVAR DataPathName=root:Packages:ImportData:DataPathName
	DataPathName = S_Path
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1I_CheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	NVAR Col1Int=root:Packages:ImportData:Col1Int
	NVAR Col1Qvec=root:Packages:ImportData:Col1Qvec
	NVAR Col1Err=root:Packages:ImportData:Col1Err
	NVAR Col1QErr=root:Packages:ImportData:Col1QErr

	NVAR Col2Int=root:Packages:ImportData:Col2Int
	NVAR Col2Qvec=root:Packages:ImportData:Col2Qvec
	NVAR Col2Err=root:Packages:ImportData:Col2Err
	NVAR Col2QErr=root:Packages:ImportData:Col2QErr

	NVAR Col3Int=root:Packages:ImportData:Col3Int
	NVAR Col3Qvec=root:Packages:ImportData:Col3Qvec
	NVAR Col3Err=root:Packages:ImportData:Col3Err
	NVAR Col3QErr=root:Packages:ImportData:Col3QErr

	NVAR Col4Int=root:Packages:ImportData:Col4Int
	NVAR Col4Qvec=root:Packages:ImportData:Col4Qvec
	NVAR Col4Err=root:Packages:ImportData:Col4Err
	NVAR Col4QErr=root:Packages:ImportData:Col4QErr

	NVAR Col5Int=root:Packages:ImportData:Col5Int
	NVAR Col5Qvec=root:Packages:ImportData:Col5Qvec
	NVAR Col5Err=root:Packages:ImportData:Col5Err
	NVAR Col5QErr=root:Packages:ImportData:Col5QErr

	NVAR Col6Int=root:Packages:ImportData:Col6Int
	NVAR Col6Qvec=root:Packages:ImportData:Col6Qvec
	NVAR Col6Err=root:Packages:ImportData:Col6Err
	NVAR Col6QErr=root:Packages:ImportData:Col6QErr

	NVAR QvectInA=root:Packages:ImportData:QvectInA
	NVAR QvectInNM=root:Packages:ImportData:QvectInNM
	NVAR CreateSQRTErrors=root:Packages:ImportData:CreateSQRTErrors
	NVAR CreatePercentErrors=root:Packages:ImportData:CreatePercentErrors

	NVAR UseFileNameAsFolder = root:Packages:ImportData:UseFileNameAsFolder
	NVAR UseIndra2Names = root:Packages:ImportData:UseIndra2Names
	NVAR UseQRSNames = root:Packages:ImportData:UseQRSNames
	NVAR UseQISNames = root:Packages:ImportData:UseQISNames

	NVAR SkipLines = root:Packages:ImportData:SkipLines
	NVAR SkipNumberOfLines = root:Packages:ImportData:SkipNumberOfLines
	
	SVAR NewDataFolderName = root:packages:ImportData:NewDataFolderName
	SVAR NewIntensityWaveName= root:packages:ImportData:NewIntensityWaveName
	SVAR NewQwaveName= root:packages:ImportData:NewQWaveName
	SVAR NewErrorWaveName= root:packages:ImportData:NewErrorWaveName
	SVAR NewQErrorWaveName= root:packages:ImportData:NewQErrorWaveName

	if(cmpstr(ctrlName,"UseFileNameAsFolder")==0)	
		CheckBox IncludeExtensionInName, disable=!(checked)
		if (checked && UseIndra2Names)
			CheckBox ImportSMRdata, disable=0
		else
			CheckBox ImportSMRdata, disable=1
		endif
		if(!checked)
			//UseFileNameAsFolder = 1
			//UseQRSNames = 0
			UseIndra2Names = 0
			if (!UseQRSNames)
				NewDataFolderName = ""	
				NewIntensityWaveName= ""
				NewQwaveName= ""
				NewErrorWaveName= ""
			endif
			if (stringmatch(NewDataFolderName, "*<fileName>*"))
				NewDataFolderName = RemoveFromList("<fileName>", NewDataFolderName , ":")
			endif
		else
			if (!stringmatch(NewDataFolderName, "*<fileName>*"))
				if(strlen(NewDataFolderName)==0)
					NewDataFolderName="root:"
				endif
				NewDataFolderName+="<fileName>:"
			endif		
		endif
	endif
	if(cmpstr(ctrlName,"UseIndra2Names")==0)
		CheckBox ImportSMRdata, disable= !checked
		NVAR ImportSMRdata=root:Packages:ImportData:ImportSMRdata
		if(checked)
			UseFileNameAsFolder = 1
			UseQRSNames = 0
			//UseIndra2Names = 0
			if (ImportSMRdata)
				NewDataFolderName = "root:USAXS:ImportedData:<fileName>:"	
				NewIntensityWaveName= "SMR_Int"
				NewQwaveName= "SMR_Qvec"
				NewErrorWaveName= "SMR_Error"
			else
				NewDataFolderName = "root:USAXS:ImportedData:<fileName>:"	
				NewIntensityWaveName= "DSM_Int"
				NewQwaveName= "DSM_Qvec"
				NewErrorWaveName= "DSM_Error"
			endif
		endif
	endif

	if(cmpstr(ctrlName,"ImportSMRdata")==0)
		NVAR UseIndra2Names=root:Packages:ImportData:UseIndra2Names
		if(checked)
			UseFileNameAsFolder = 1
			UseQRSNames = 0
			//UseIndra2Names = 0
			if (UseIndra2Names)
				NewDataFolderName = "root:USAXS:ImportedData:<fileName>:"	
				NewIntensityWaveName= "SMR_Int"
				NewQwaveName= "SMR_Qvec"
				NewErrorWaveName= "SMR_Error"
			endif
		else
			if (UseIndra2Names)
				NewDataFolderName = "root:USAXS:ImportedData:<fileName>:"	
				NewIntensityWaveName= "DSM_Int"
				NewQwaveName= "DSM_Qvec"
				NewErrorWaveName= "DSM_Error"
			endif
		endif
	endif


	if(cmpstr(ctrlName,"UseQRSNames")==0)
		if (!checked && UseIndra2Names)
			CheckBox ImportSMRdata, disable=0
		else
			CheckBox ImportSMRdata, disable=1
		endif
		if(checked)
			//UseFileNameAsFolder = 1
			UseQISNames = 0
			UseIndra2Names = 0
			NewDataFolderName = "root:SAS:ImportedData:"	
			if (UseFileNameAsFolder)
				NewDataFolderName+="<fileName>:"
			endif		
			NewIntensityWaveName= "R_<fileName>"
			NewQwaveName= "Q_<fileName>"
			NewErrorWaveName= "S_<fileName>"
			NewQErrorWaveName= "W_<fileName>"
		endif
	endif
	if(cmpstr(ctrlName,"UseQISNames")==0)
		if (!checked && UseIndra2Names)
			CheckBox ImportSMRdata, disable=0
		else
			CheckBox ImportSMRdata, disable=1
		endif
		if(checked)
			//UseFileNameAsFolder = 1
			UseQRSNames = 0
			UseIndra2Names = 0
			NewDataFolderName = "root:"	
			//if (UseFileNameAsFolder)
				NewDataFolderName+="<fileName>:"
			//endif		
			NewIntensityWaveName= "<fileName>_i"
			NewQwaveName= "<fileName>_q"
			NewErrorWaveName= "<fileName>_s"
			NewQErrorWaveName= "<fileName>_w"
		endif
	endif
	
	if(cmpstr(ctrlName,"QvectorInA")==0)
		if(checked)
			QvectInNM = 0
		else
			QvectInNM = 1
		endif
	endif
	if(cmpstr(ctrlName,"QvectorInNM")==0)
		if(checked)
			QvectInA = 0
		else
			QvectInA = 1	
		endif
	endif


	if(cmpstr(ctrlName,"Col1Int")==0)
		//fix others for col 1
		if(checked)
			//Col1Int=0
			Col2Int=0
			Col3Int=0
			Col4Int=0
			Col5Int=0
			Col6Int=0
			Col1Qvec=0
			Col1Err=0			
			Col1QErr=0			
		endif
	endif
	if(cmpstr(ctrlName,"Col1Qvec")==0)
			Col1Int=0
			//Col1Qvec=0
			Col2Qvec=0
			Col3Qvec=0
			Col4Qvec=0
			Col5Qvec=0
			Col6Qvec=0
			Col1Err=0			
			Col1QErr=0			
	endif
	if(cmpstr(ctrlName,"Col1Error")==0)
			Col1Int=0
			Col1Qvec=0
			//Col1Err=0			
			Col2Err=0			
			Col3Err=0			
			Col4Err=0			
			Col5Err=0			
			Col6Err=0			
			Col1QErr=0			
	endif
	if(cmpstr(ctrlName,"Col1QError")==0)
			Col1Int=0
			Col1Qvec=0
			//Col1Err=0			
			Col2QErr=0			
			Col3QErr=0			
			Col4QErr=0			
			Col5QErr=0			
			Col6QErr=0			
			Col1Err=0			
	endif


	if(cmpstr(ctrlName,"Col2Int")==0)
		if(checked)
			Col1Int=0
			//Col2Int=0
			Col3Int=0
			Col4Int=0
			Col5Int=0
			Col6Int=0
			Col2Qvec=0
			Col2Err=0			
			Col2QErr=0			
		endif
	endif
	if(cmpstr(ctrlName,"Col2Qvec")==0)
			Col2Int=0
			Col1Qvec=0
			//Col2Qvec=0
			Col3Qvec=0
			Col4Qvec=0
			Col5Qvec=0
			Col6Qvec=0
			Col2Err=0			
			Col2QErr=0			
	endif
	if(cmpstr(ctrlName,"Col2Error")==0)
			Col2Int=0
			Col2Qvec=0
			Col1Err=0			
			//Col2Err=0			
			Col3Err=0			
			Col4Err=0			
			Col5Err=0			
			Col6Err=0			
			Col2QErr=0			
	endif
	if(cmpstr(ctrlName,"Col2QError")==0)
			Col2Int=0
			Col2Qvec=0
			Col1QErr=0			
			//Col2Err=0			
			Col3QErr=0			
			Col4QErr=0			
			Col5QErr=0			
			Col6QErr=0			
			Col2Err=0			
	endif
	
	if(cmpstr(ctrlName,"Col3Int")==0)
		if(checked)
			Col1Int=0
			Col2Int=0
			//Col3Int=0
			Col4Int=0
			Col5Int=0
			Col6Int=0
			Col3Qvec=0
			Col3Err=0			
			Col3QErr=0			
		endif
	endif
	if(cmpstr(ctrlName,"Col3Qvec")==0)
			Col3Int=0
			Col1Qvec=0
			Col2Qvec=0
			//Col3Qvec=0
			Col4Qvec=0
			Col5Qvec=0
			Col6Qvec=0
			Col3Err=0			
			Col3QErr=0			
	endif
	if(cmpstr(ctrlName,"Col3Error")==0)
			Col3Int=0
			Col3Qvec=0
			Col1Err=0			
			Col2Err=0			
			//Col3Err=0			
			Col4Err=0			
			Col5Err=0			
			Col6Err=0			
			Col3QErr=0			
	endif
	if(cmpstr(ctrlName,"Col3QError")==0)
			Col3Int=0
			Col3Qvec=0
			Col1QErr=0			
			Col2QErr=0			
			//Col3Err=0			
			Col4QErr=0			
			Col5QErr=0			
			Col6QErr=0			
			Col3Err=0			
	endif
	
	if(cmpstr(ctrlName,"Col4Int")==0)
		if(checked)
			Col1Int=0
			Col2Int=0
			Col3Int=0
			//Col4Int=0
			Col5Int=0
			Col6Int=0
			Col4Qvec=0
			Col4Err=0			
			Col4QErr=0			
		endif
	endif
	if(cmpstr(ctrlName,"Col4Qvec")==0)
			Col4Int=0
			Col1Qvec=0
			Col2Qvec=0
			Col3Qvec=0
			//Col4Qvec=0
			Col5Qvec=0
			Col6Qvec=0
			Col4Err=0			
			Col4QErr=0			
	endif
	if(cmpstr(ctrlName,"Col4Error")==0)
			Col4Int=0
			Col4Qvec=0
			Col1Err=0			
			Col2Err=0			
			Col3Err=0			
			//Col4Err=0			
			Col5Err=0			
			Col6Err=0			
			Col4QErr=0			
	endif
	if(cmpstr(ctrlName,"Col4QError")==0)
			Col4Int=0
			Col4Qvec=0
			Col1QErr=0			
			Col2QErr=0			
			Col3QErr=0			
			//Col4Err=0			
			Col5QErr=0			
			Col6QErr=0			
			Col4Err=0			
	endif

	if(cmpstr(ctrlName,"Col5Int")==0)
		if(checked)
			Col1Int=0
			Col2Int=0
			Col3Int=0
			Col4Int=0
			//Col5Int=0
			Col6Int=0
			Col5Qvec=0
			Col5Err=0			
			Col5QErr=0			
		endif
	endif
	if(cmpstr(ctrlName,"Col5Qvec")==0)
			Col5Int=0
			Col1Qvec=0
			Col2Qvec=0
			Col3Qvec=0
			Col4Qvec=0
			//Col5Qvec=0
			Col6Qvec=0
			Col5Err=0			
			Col5QErr=0			
	endif
	if(cmpstr(ctrlName,"Col5Error")==0)
			Col5Int=0
			Col5Qvec=0
			Col1Err=0			
			Col2Err=0			
			Col3Err=0			
			Col4Err=0			
			//Col5Err=0			
			Col6Err=0			
			Col5QErr=0			
	endif
	if(cmpstr(ctrlName,"Col5QError")==0)
			Col5Int=0
			Col5Qvec=0
			Col1QErr=0			
			Col2QErr=0			
			Col3QErr=0			
			Col4QErr=0			
			//Col5Err=0			
			Col6QErr=0			
			Col5Err=0			
	endif

	if(cmpstr(ctrlName,"Col6Int")==0)
		if(checked)
			Col1Int=0
			Col2Int=0
			Col3Int=0
			Col4Int=0
			Col5Int=0
			//Col6Int=0
			Col6Qvec=0
			Col6Err=0			
			Col6QErr=0			
		endif
	endif
	if(cmpstr(ctrlName,"Col6Qvec")==0)
			Col6Int=0
			Col1Qvec=0
			Col2Qvec=0
			Col3Qvec=0
			Col4Qvec=0
			Col5Qvec=0
			//Col6Qvec=0
			Col6Err=0			
			Col6QErr=0			
	endif
	if(cmpstr(ctrlName,"Col6Error")==0)
			Col6Int=0
			Col6Qvec=0
			Col1Err=0			
			Col2Err=0			
			Col3Err=0			
			Col4Err=0			
			Col5Err=0			
			//Col6Err=0			
			Col6QErr=0			
	endif
	if(cmpstr(ctrlName,"Col6QError")==0)
			Col6Int=0
			Col6Qvec=0
			Col1QErr=0			
			Col2QErr=0			
			Col3QErr=0			
			Col4QErr=0			
			Col5QErr=0			
			//Col6Err=0			
			Col6Err=0			
	endif

	if (Col1Err || Col2Err || Col3Err || Col4Err || Col5Err || Col6Err)
		CheckBox CreateSQRTErrors, disable=1, win=IR1I_ImportData
		CheckBox CreatePercentErrors, disable=1, win=IR1I_ImportData
		CreateSQRTErrors=0
		CreatePercentErrors=0
		SetVariable PercentErrorsToUse, disable=1
	else
		CheckBox CreateSQRTErrors, disable=0, win=IR1I_ImportData
		CheckBox CreatePercentErrors, disable=0, win=IR1I_ImportData
		SetVariable PercentErrorsToUse, disable=!(CreatePercentErrors)
	endif
	
	if(Col6QErr || Col5QErr || Col4QErr || Col3QErr || Col2QErr || Col1QErr)
		SetVariable NewQErrorWaveName, disable = 0 
	else	
		SetVariable NewQErrorWaveName, disable = 1
	endif
	
	if(cmpstr(ctrlName,"CreateSQRTErrors")==0)
		if(checked)
			CreatePercentErrors=0
			SetVariable PercentErrorsToUse, disable=1
		endif
	endif
	if(cmpstr(ctrlName,"CreatePercentErrors")==0)
		if(checked)
			CreateSQRTErrors=0
			SetVariable PercentErrorsToUse, disable=0
		else
			SetVariable PercentErrorsToUse, disable=1
		endif
	endif

	
	if(cmpstr(ctrlName,"ScaleImportedDataCheckbox")==0)
		if(checked)
			SetVariable ScaleImportedDataBy, disable=0
		else
			SetVariable ScaleImportedDataBy, disable=1
		endif
	endif

	if(cmpstr(ctrlName,"SkipLines")==0)
		if(checked)
			SetVariable SkipNumberOfLines, disable=0
		else
			SetVariable SkipNumberOfLines, disable=1
		endif
	endif
	
End
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IR1I_UpdateListOfFilesInWvs()

	SVAR DataPathName = root:Packages:ImportData:DataPathName
	SVAR DataExtension  = root:Packages:ImportData:DataExtension
	Wave/T WaveOfFiles      = root:Packages:ImportData:WaveOfFiles
	Wave WaveOfSelections = root:Packages:ImportData:WaveOfSelections
	string ListOfAllFiles
	string LocalDataExtension
	variable i, imax
	LocalDataExtension = DataExtension
	if (cmpstr(LocalDataExtension[0],".")!=0)
		LocalDataExtension = "."+LocalDataExtension
	endif
	PathInfo ImportDataPath
	if(V_Flag && strlen(DataPathName)>0)
		if (strlen(LocalDataExtension)<=1)
			ListOfAllFiles = IndexedFile(ImportDataPath,-1,"????")
		else		
			ListOfAllFiles = IndexedFile(ImportDataPath,-1,LocalDataExtension)
		endif
		imax = ItemsInList(ListOfAllFiles,";")
		Redimension/N=(imax) WaveOfSelections
		Redimension/N=(imax) WaveOfFiles
		for (i=0;i<imax;i+=1)
			WaveOfFiles[i] = stringFromList(i, ListOfAllFiles,";")
		endfor
	else
		Redimension/N=0 WaveOfSelections
		Redimension/N=0 WaveOfFiles
	endif 
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************


Function IR1I_InitializeImportData()
	
	string OldDf = GetDataFolder(1)
	
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:ImportData
	
	string ListOfStrings
	string ListOfVariables
	variable i
	
	ListOfStrings = "DataPathName;DataExtension;IntName;QvecName;ErrorName;NewDataFolderName;NewIntensityWaveName;"
	ListOfStrings+="NewQWaveName;NewErrorWaveName;NewQErrorWavename;"
	ListOfVariables = "UseFileNameAsFolder;UseIndra2Names;UseQRSNames;DataContainErrors;UseQISNames;"
	ListOfVariables += "CreateSQRTErrors;Col1Int;Col1Qvec;Col1Err;Col1QErr;FoundNWaves;"	
	ListOfVariables += "Col2Int;Col2Qvec;Col2Err;Col2QErr;Col3Int;Col3Qvec;Col3Err;Col3QErr;Col4Int;Col4Qvec;Col4Err;Col4QErr;"	
	ListOfVariables += "Col5Int;Col5Qvec;Col5Err;Col5QErr;Col6Int;Col6Qvec;Col6Err;Col6QErr;Col7Int;Col7Qvec;Col7Err;Col7QErr;"	
	ListOfVariables += "QvectInA;QvectInNM;CreateSQRTErrors;CreatePercentErrors;PercentErrorsToUse;"
	ListOfVariables += "ScaleImportedData;ScaleImportedDataBy;ImportSMRdata;SkipLines;SkipNumberOfLines;"	
	ListOfVariables += "IncludeExtensionInName;"	

		//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
								
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	

	Make/O/T/N=0 WaveOfFiles
	Make/O/N=0 WaveOfSelections
	
	ListOfVariables = "CreateSQRTErrors;Col1Int;Col1Qvec;Col1Err;Col1QErr;"	
	ListOfVariables += "Col2Int;Col2Qvec;Col2Err;Col2QErr;Col3Int;Col3Qvec;Col3Err;Col3QErr;Col4Int;Col4Qvec;Col4Err;Col4QErr;"	
	ListOfVariables += "Col5Int;Col5Qvec;Col5Err;Col5QErr;Col6Int;Col6Qvec;Col6Err;Col6QErr;Col7Int;Col7Qvec;Col7Err;Col7QErr;"	
	ListOfVariables += "QvectInNM;CreateSQRTErrors;UseFileNameAsFolder;CreatePercentErrors;"	
	ListOfVariables += "ScaleImportedData;ImportSMRdata;SkipLines;SkipNumberOfLines;"	

	//Set numbers to 0
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		NVAR test=$(StringFromList(i,ListOfVariables))
		test =0
	endfor		
	ListOfVariables = "QvectInA;PercentErrorsToUse;ScaleImportedDataBy;"	
	//Set numbers to 0
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		NVAR test=$(StringFromList(i,ListOfVariables))
		test =1
	endfor		
	
	IR1I_UpdateListOfFilesInWvs()
end


//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
