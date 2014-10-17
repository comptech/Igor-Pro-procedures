#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 1.2

Menu "jtgSpectroscopy"
	Submenu "Other Data Load Procs"
		"File Load",MultiFileLoad()
	End
End

//name of datafolder path used for file load functions
Static StrConstant ksDFPath = "root:Packages:JTG:MultiFileLoader:"
Static StrConstant ksDefaultDataPath = "C:My Stuff:pg:Fluorescence:Data:SPEX_Data:SPEX FL3-22 Data:Data Files:2007:"

//*************************************************************************************************************//
//*****                                               Notes			                                                      *****//
//*************************************************************************************************************//
//	4/21/2008																		//
//	User can change the string constants above as well as the menu entry above as needed.	//
//	The function bpMFLGetSelectedFileList will compile a string containing a semicolon 		//
//	separated list of files selected from the listbox.  The user could operated on each selected//
//	item as it is found by adding code to bpMFLGetSelectedFileList or simply operate on		//
//	the string after bpMFLGetSelectedFileList completes .  The selected list is saved in a 	//
//	string named FileList in a folder that is in the	in the path dictated by ksDFPath.  			//
//	The folder is uniquely named using a base name of MultiFileLoadPanel.					//
//*************************************************************************************************************//

//*************************************************************************************************************//
//*****                                                MultiFileLoad                                                        *****//
//*************************************************************************************************************//
//	Start Multiple file load routine.  Display control panel; create waves used to handle waves  //
//	and wave selections.																//
//	10/31/06 modified code so that data folders are used to hold waves (list of files) and string	//
//	unique to a MultiFileLoad panel.  Now multiple panels can be open and each will retain	//
//	its own unique information set; each of which can open files from different directories.		//
//	A hook function is set for each open panel and when the panel is killed the associated	//
//	data folder and waves are also killed.												//
//	4/21/08 Removed file loading specific code and generalized so that a string list of selected//
//	 files is compiled and stored in the panel specific data folder.							//
//************************************************************************************************************//
Function MultiFileLoad()
	
	String PanelName
	String DFName
	String DataLocation
	String KnownFileTypes
	
	PanelName = UniqueName("MultiFileLoadPanel", 9, 0 )
	DataLocation = ksDFPath + PanelName
//Create data folders to hold panel info; ksDFPath is string constant
//see top of procedure file for its value.  Folder has same name as panel name.
	CreateDFPath(ksDFPath, PanelName)
	
	String/G $(DataLocation + ":PathToFiles") = ksDefaultDataPath
	make /O /T /N=10 $(DataLocation + ":w")
	make /O /B /U /N=10  $(DataLocation + ":sw") = 0
	
	Wave/T w = $(DataLocation + ":w")
	Wave sw = $(DataLocation + ":sw")
	String/G $(DataLocation + ":FileList") = ""
	String/G $(DataLocation + ":FileNumberList") = ""
	Variable/G $(DataLocation + ":NumberOfFiles") = 0
	
	KnownFileTypes = "\"_Auto_;Spex (.SPT);PE L-9 (.SP);Foss (.TXT);HP UVVis (.WAV);HySPEC (.TIF); TIFF (.TIF);"
	KnownFileTypes += "MM log (.LOG);GRAMS (.SPC);Text (.???);TextMatrix (.CSV)\""
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(338.0,67.0,776,288)
	DoWindow /C $PanelName		//change graph window name
	DoWindow /T $PanelName	 PanelName	//change graph window title
	SetVariable svPath,pos={66,24},size={284,16},proc=GetFileList,title="Path"
	SetVariable svPath,value= $(DataLocation + ":PathToFiles") //PathToFiles
	Button btnSetPath,pos={8,22},size={50,20},proc=bpMFLSetPath,title="Set Path"
	Button btnUpdateList,pos={359,22},size={65,20},proc=bpMFLUpdateList,title="Update List"
	Button btnUpdateList,help={"Update list of files from current path."}
	GroupBox gbPath frame=1, title="Path", pos={2,5}, size={431, 43}
	ListBox lbFiles disable=0, editStyle= 0, listWave= w, mode=10, pos={2,55}
	ListBox lbFiles selWave=sw, size={200,150}, widths={200}
	Button btnGetSelectedFileList,pos={262,55},size={50,20},proc=bpMFLGetSelectedFileList,title="Get Files"
	PopupMenu popFileType,disable=1,pos={206,90},size={158,21},title="File Type",proc=poprocFileType
	PopupMenu popFileType,mode=1,value= #KnownFileTypes //list of known file types for pop up menu
	SetWindow kwTopWin, hook(MultiFileLoadCleanUp )=MultiFileLoadHook
End Function
//*************************************************************************************************************//
//*****                                            End of MultiFileLoad                                                  *****//
//*************************************************************************************************************//

//************************************************************************************************************//
//*****								MultiFileLoadHook							*****//
//************************************************************************************************************//
//	Added 10/31/06																	//
//	Event processing function for panel created by MultiFileLoad function.					//
//	First intended purpuose is to clean up when  the MultiFileLoad panel is killed.  It is used 	//
//	to delete waves ("w" & "sw") and folder created by when the panel is opened.			//
//************************************************************************************************************//
Function MultiFileLoadHook(s)
	STRUCT WMWinHookStruct &s
	
	Variable statusCode = 0
	
	String PanelName
	String DFName

	PanelName = s.winName
	DFName = ksDFPath + PanelName

	if(s.eventCode == 2)	//kill window: clean up
		KillDataFolder $DFName
		statusCode = 1
	endif
	
	return statusCode // 0 if nothing done, else 1
End
//************************************************************************************************************//
//*****							 End of MultiFileLoadHook							*****//
//************************************************************************************************************//

//*************************************************************************************************************//
//*****                                                     bpMFLSetPath                                                 *****//
//*************************************************************************************************************//
//	Called by Set Path button on panel.  Opens dialog to select new symbolic path to		//
//	directory containing files to load.  Then calls routine to get all files from that directory and	//
//	load into wave w for display in the list box.											//
//	10/31/06 Modified for data folder use.												//
//*************************************************************************************************************//
Function bpMFLSetPath(ctrlName)
	String ctrlName

	String Msg
	String PanelName
	String DataLocation

	if(stringmatch(ctrlName, "btnSetPath") != 1)
		return 0
	endif

//string and waves associated with this panel instance are located in a data folder named 
//after the panel name 
	PanelName = WinName(0, 64)	//name of top panel
	DataLocation = ksDFPath + PanelName
	SVAR PathToFiles = $(DataLocation + ":PathToFiles")

	Msg = "Browse To The File Location..."
	NewPath /M=Msg /O jtgSpecFileLoader
	
	if(V_flag != 0)	//user hit cancel
		return 0
	endif
	
	PathInfo jtgSpecFileLoader
	if(V_flag == 0)//path doesn't exist
		return 0
	endif

//update path variable
	PathToFiles = S_path
	
//fill listbox with files from new path
	GetFileList("",0,"","")
End Function 
//*************************************************************************************************************//
//*****                                            End of bpMFLSetPath                                                *****//
//*************************************************************************************************************//

//*************************************************************************************************************//
//*****                                                  poprocFileType                                                    *****//
//*************************************************************************************************************//
//	Currently, this is not really used although it is called when the popup menu popFileType is	   //
//	accessed.  This could, perhaps be used to limit the items appearing in the list boxt.  Or	   //
//	maybe some other control could be used for this purpose.								  //
//*************************************************************************************************************//
Function poprocFileType(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	if(stringmatch(ctrlName, "popFileType") != 1)
		return 0
	endif
//	print popStr
End Function
//*************************************************************************************************************//
//*****                                            End of poprocFileType                                                *****//
//*************************************************************************************************************//

//*************************************************************************************************************//
//*****                                             bpMFLGetSelectedFileList                                        *****//
//*************************************************************************************************************//
//	Called by Get Files buttons on controll panel.  Check wave sw to determine which files       //
//	were selected and assign to output string.                                                                       //
//	Query popFileType control to determine which routine to call for loading the files.               //
//	10/31/06 Modified for data folder use.												 //
//	user specific code could be put in the if/endif segment in this procedure or user could act   //
//	on FileNameList stored in the package folder											 //
//*************************************************************************************************************//
Function bpMFLGetSelectedFileList(ctrlName)
	String ctrlName

	Variable index
	Variable NumFiles
	String FPath_Name
	String FName
//	String FType
	String FBaseName
	String FExtension
	String PanelName
	String DataLocation
	
	if(stringmatch(ctrlName, "btnGetSelectedFileList") != 1)
		return 0
	endif
	
////string and waves associated with this panel instance are located in a data folder named 
////after the panel name 
	PanelName = WinName(0, 64)	//name of top panel
	DataLocation = ksDFPath + PanelName
	
	Wave/T w = $(DataLocation + ":w")
	Wave sw = $(DataLocation + ":sw")
	SVAR PathToFiles = $(DataLocation + ":PathToFiles")
	SVAR FileNameList = $(DataLocation + ":FileList")
	NVAR NumberOfFiles = $(DataLocation + ":NumberOfFiles")
	SVAR FileNumberList = $(DataLocation + ":FileNumberList")

	
////Check popFileType control (labelled "File Type") to determine
////which file loading routine to call.

//	ControlInfo  popFileType
//	if(abs(V_flag) == 3)
//		FType = S_Value		//type of file to open, Spex, Lambda9...
//	else
//		DoAlert 0, "Problem with file type."
//		return 0
//	endif

	FileNameList = ""
	FileNumberList = "" 
	NumFiles = numpnts(sw)
	index = 0
	Do
//bit one or bit 3 is set if listbox row(index) was selected (listbox mode 10)
		if(((sw[index] & 0x01) || (sw[index] & 0x08)) == 1)	
		//user specific code could be put in this if/endif segment
		//or user could act on FileNameList stored in the package folder	
			FName = w[index]
	 		FileNameList +=  FName + ";"
	 		FileNumberList += num2str(index) + ";"
	 		FPath_Name = PathToFiles + FName
	 		FBaseName = ParseFilePath(3, FName, ":", 0, 0)	
	 		FExtension =  ParseFilePath(4, FName, ":", 0, 0)	
		endif
		index += 1
	 While (index < NumFiles)
	NumberOfFiles = ItemsInList(FileNameList, ";")

//For debugging print a list of files selected for loading and a list of their position in the 
//wave of all files in directory.
//	 print FileNameList
//	 print FileNumberList
End Function 
//*************************************************************************************************************//
//*****                                        End of bpMFLGetSelectedFileList                                  *****//
//*************************************************************************************************************//

//*************************************************************************************************************//
//*****                                                    GetFileList                                                        *****//
//*************************************************************************************************************//
//	Get list of files from current path jtgSpecFileLoader, redimension waves used to hold           //
//	file names and list box attributes.                                                                                    //
//	This will automatically put new list into listbox.                                                                 //
//	10/31/06 Modified for data folder use.												  //
//	6/20/07:
//		added line "sw = 0" to clear all selections when the listbox is updated	  			  //
//*************************************************************************************************************//
Function GetFileList(ctrlName,varNum,varStr,varName)
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable

	String PanelName
	String DataLocation
	
//string and waves associated with this panel instance are located in a data folder named 
//after the panel name 
	PanelName = WinName(0, 64)	//name of top panel
	DataLocation = ksDFPath + PanelName
	
	Wave/T w = $(DataLocation + ":w")
	Wave sw = $(DataLocation + ":sw")
	
	Variable NumFiles
	Variable i = 0
	
	String FileList = IndexedFile(jtgSpecFileLoader, -1, "????")

	FileList = SortList(FileList, ";", 16)	//16: case-insensitive alphanumeric sort that sorts wave0 and wave9 before wave10.
	NumFiles = itemsinlist(FileList, ";")
	
	Redimension /N=(NumFiles) w
	Redimension /N=(NumFiles) sw
	sw = 0
	w[] = StringFromList(p, FileList, ";")
	
End Function
//*************************************************************************************************************//
//*****                                            End of GetFileList                                                     *****//
//*************************************************************************************************************//

//*************************************************************************************************************//
//*****                                                    bpMFLUpdateList                                              *****//
//*************************************************************************************************************//
//	Update list of files in displayed in list box lbFiles.										//
//	This button procedures just calls GetFileList procedure.								//
//	01/17/07 Modified for data folder use.												//
//*************************************************************************************************************//
Function bpMFLUpdateList(ctrlName)
	String ctrlName
	
	if(stringmatch(ctrlName, "btnUpdateList") != 1)
		return 0
	endif
	
	GetFileList("",0,"","")
End Function
//*************************************************************************************************************//
//*****                                            End of bpMFLUpdateList                                            *****//
//*************************************************************************************************************//

//************************************************************************************************************//
//*****							Static Function CreateDFPath						*****//
//************************************************************************************************************//
//	Standard function used to created a new data folder and the path to it if it does not exist.	//
//	Function is delared as static in case it exists in other open procedure files.				//
//************************************************************************************************************//	
Static Function CreateDFPath(sFullDFPath, sNewDF)
	String sFullDFPath
	String sNewDF
	
	String sEntireDFPath	//path plus new folder
	Variable incr
	String sPathElement = ""
	String sPartialPath = ""
	String sPathChar = ""
	sEntireDFPath = sFullDFPath + sNewDF
//check that path and folder strings aren't empty
	if((strlen(sFullDFPath) == 0) || (strlen(sNewDF) == 0 ) == 1)
		DoAlert 0, "Missing Data Folder Path... check string constant at start of procedure."
		return 0
	endif
	
//Does path already exist?
//then check for its existence, if it alrealdy exists, alert user and return success
	If(DataFolderExists(sEntireDFPath))
		//print "Path already exists: ", sEntireDFPath
		return 1
	EndIf

//Are there any ":" at front?
	Do
		sPathChar = sEntireDFPath[0]
		if(stringmatch(sPathChar, ":") == 0)
			break
		endif
		sPartialPath += ":"
		sEntireDFPath = sEntireDFPath[1, inf]
	While(1)
	
	incr = 0	
//if the first part of the path is "root:", this is a special case.  It always exists and we don't
//need to create it, so skip over it.
//break path at folders and work with each part of the path
	sPathElement = StringFromList(incr, sEntireDFPath, ":")
	If(stringmatch(sPathElement, "root"))
		sPartialPath = "root:"
		incr += 1
	EndIf
			
	
	Do
//break path at folders and work with each part of the path
		sPathElement = StringFromList(incr, sEntireDFPath, ":")
//exit loop when we encounter a null string, this usually means that all elements of loop 
//have been processed
		If(!strlen(sPathElement))
			break
		EndIf
		sPartialPath += sPathElement
//		print "creating: ", sPartialPath
		NewDataFolder/O $sPartialPath
		
//need ":" to separate path elements, but NewDataFolder doesn't like this on the end of a path
//string, so we append it here.
		sPartialPath +=  ":"

		incr += 1
	While(1)
	return 1
	
End
//************************************************************************************************************//
//*****							End of  CreateDFPath								*****//
//************************************************************************************************************//
