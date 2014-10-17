#pragma rtGlobals=1		// Use modern global access method.
#include <Multi-peak Fitting 2.0>

Menu "Macros"
	"Load Raman Data, ALS", LoadRamanData_ALS()
End

Function LoadRamanData_ALS()
 
	NewPath/O PathName	//prompt for folder in which the files are
 
	if (V_flag == -1)   //User cancelled dialog
		return -1
	endif
 
	string ListOfFiles = IndexedFile(PathName, -1, ".txt")	// Get list of *.dat files in folder
	string CurrentFile = ""	
	variable i
 
	do 
		CurrentFile = StringFromList(i, ListOfFiles)			
		if(strlen(CurrentFile)==0)	// no more file to import
			break
		endif
		
		string CurrentFile2 = CurrentFile[0, strlen(CurrentFile)-5]
 
		NewDataFolder/O/S $CurrentFile2   //make new datafolder
 
		//LoadWave/A/D/J/W/K=0/V={" "," $",0,0}/L={0,1,0,0,0}   /P=PathName CurrentFile 
		//LoadWave/J/D/O/A=Column/K=0/L={0,1,0,0,0} /P=PathName CurrentFile 
		LoadWave/J/D/O/B="C=1,N='Wave Number (nm)'; C=1,N='Intensity';"/A=Column/K=0/L={0,1,0,0,0} /P=PathName CurrentFile 
		Display 'Intensity' vs 'Wave Number (nm)'
		//SetAxisLabels
		Label left "Intensity"; DelayUpdate
		Label bottom "Wavenumber (nm)"; DelayUpdate
		//Annotate graph
		Textbox/A=LT "Loaded from " + CurrentFile2
		SetDataFolder ::
		i+=1
	while(1)
end

