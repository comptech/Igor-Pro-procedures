#pragma rtGlobals=1		// Use modern global access method.

Function FileImport()
 
	NewPath/O PathName	//prompt for folder in which the files are
 
	if (V_flag == -1)   //User cancelled dialog
		return -1
	endif
 
	string ListOfFiles = IndexedFile(PathName, -1, ".exp")	// Get list of *.dat files in folder
	string CurrentFile = ""	
	variable i
 
	do 
		CurrentFile = StringFromList(i, ListOfFiles)			
		if(strlen(CurrentFile)==0)	// no more file to import
			break
		endif
		
		string CurrentFile2 = CurrentFile[0, strlen(CurrentFile)-5]
 
		//NewDataFolder/O/S $CurrentFile2   //make new datafolder
 
		//LoadWave/A/D/J/W/K=0/V={" "," $",0,0}/L={0,1,0,0,0}   /P=PathName CurrentFile 
		//LoadWave/J/D/O/A=Column/K=0/L={0,12,0,0,0} /P=PathName CurrentFile2
		//LoadWave/J/D/O/A=$CurrentFile2/K=0/L={0,12,0,0,0} /P=PathName CurrentFile
		LoadWave/J/M/D/O/A=$CurrentFile2/K=0/V={" "," $",0,0} /P=PathName CurrentFile
		Rename $CurrentFile2+"0", $CurrentFIle2
		Display $CurrentFile2+"[][1]" vs $CurrentFile2 +"[][0]"
		//SetAxisLabels
		Label left "Intensity"; DelayUpdate
		Label bottom "Channel No."; DelayUpdate
		//Change graph name
		DoWindow/T Graph0, CurrentFile2
		//Annotate graph
		Textbox/A=LT "Loaded from " + CurrentFile2
		SetDataFolder ::
		i+=1
	while(1)
end