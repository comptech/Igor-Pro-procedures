#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.02

//This should be package which allows mining data for variuous outputs.
//Needs to be able to read parts of folder tree and in ech folder provide some servgices:
//	find data and add to new graph if they exist
//	find strings/variables/wave (notes) and print into notebook
//	find strings/variables/wave (notes) and output to waves


//Use no more than about 8 distinct colors.
//Subtle differences are not obvious and can actually
//obscure significant differences between curves.
//Use about 6 different symbols.  You can also
//choose open and filled symbols (but not for
//cross, plus, and dot, of course) but symbols have
//to be large enough to distinguish this.  Be certain
//to have a different number of symbols and colors,
//then the pattern has a longer repeat interval.
//
//
//This example has a repeat interval of 70:
//colors:  red green blue black brown orange purple
//shapes:  circle square diamond uptriangle downtriangle
//fills:   open closed
//Vary the colors and shapes together keeping fill fixed
//for the first half, then change fill and repeat colors
//and shapes.
//
//
//This is not Igor code but describes my selection method.
//(zero-based arrays
// index = zero-based number of curve on the plot
// number(xx) = number of items in xx array
// int(0.9) = 0  and  int(1.1) = 1
//)
//     color = colors[ index % number(colors) ]
//     shape = shapes[ index % number(shapes) ]
//     fill  = fills[ int(2*index/number(fills)) ]

Function IR2M_GetDataMiner()

	IR2M_InitDataMiner()
	
	DoWindow DataMiningTool
	if(V_Flag)
		DoWindow/K DataMiningTool
	endif
	DoWindow ItemsInFolderPanel
	if(V_Flag)
		DoWindow/K ItemsInFolderPanel
	endif
	
	IR2M_DataMinerPanel()
	
	IR2M_SyncSearchListAndListBox()	//sync the list box... 
	IR2M_MakePanelWithListBox()	//and create the other panel... 
	popupmenu QvecDataName, win=DataMiningTool, disable=1
	popupmenu IntensityDataName, win=DataMiningTool, disable=1
	popupmenu ErrorDataName, win=DataMiningTool, disable=1
	popupmenu SelectDataFolder, win=DataMiningTool, title="Test data folder"

end




Function IR2M_DataMinerPanel()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:DataMiner
	SVAR DataFolderName=root:Packages:DataMiner:DataFolderName
	DataFolderName="---"

	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(2.25,43.25,390,690) as "Data mining tool"
	DoWindow/C DataMiningTool
	
	string AllowedIrenaTypes="DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;R_Int;"
	IR2C_AddDataControls("DataMiner","DataMiningTool",AllowedIrenaTypes,"AllCurrentlyAllowedTypes","","","","", 0,0)
		PopupMenu SelectDataFolder proc=IR2M_DataFolderPopMenuProc
		//PopupMenu SelectDataFolder value=#DataFolderName+"+IR2P_GenStringOfFolders()"
		popupmenu QvecDataName, pos={500,500},disable=1
		popupmenu IntensityDataName, pos={500,500}, disable=1
		popupmenu ErrorDataName, pos={500,500}, disable=1
		popupmenu SelectDataFolder, title="Test data folder"
	SetDrawLayer UserBack
	SetDrawEnv fname= "Times New Roman", save
	SetDrawEnv fname= "Times New Roman",fsize= 22,fstyle= 3,textrgb= (0,0,52224)
	DrawText 50,23,"Data mining tool panel"
	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
	DrawLine 16,165,339,165
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 18,49,"Test folder"
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 20,190,"Which data:"
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 20,450,"Output Options:"
	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
	DrawLine 16,425,339,425
	SVAR StartFolder
	PopupMenu StartFolder,pos={10,100},size={180,20},proc=IR2M_PanelPopupControl,title="Start Folder", help={"Select folder where to start. Only subfolders will be searched"}
	PopupMenu StartFolder,mode=(WhichListItem(StartFolder, IR2M_ListFoldersWithSubfolders("root:", 25))+1),value=  #"IR2M_ListFoldersWithSubfolders(\"root:\", 25)"
	SetVariable FolderMatchString,value= root:Packages:DataMiner:FolderMatchString,noProc, frame=1
	SetVariable FolderMatchString,pos={10,130},size={350,25},title="Folder Match String (\"*\" for all):", help={"String to match folder name to. \" * \" for all, \"XYZ*\" for folders staring XYZ, \"*XYZ\" for ending, etc..."}//, fSize=10,fstyle=1,labelBack=(65280,21760,0)


//	ListOfVariables+="MineVariables;MineStrings;MineWaves;MineWavenotes;"
	CheckBox MineVariables,pos={5,200},size={80,14},proc= IR2M_DataMinerCheckProc,title="Variable?"
	CheckBox MineVariables,variable= root:Packages:DataMiner:MineVariables, help={"Is the info stored as variable?"}
	CheckBox MineStrings,pos={100,200},size={80,14},proc= IR2M_DataMinerCheckProc,title="String?"
	CheckBox MineStrings,variable= root:Packages:DataMiner:MineStrings, help={"Is the info stored as string?"}
	CheckBox MineWavenotes,pos={195,200},size={80,14},proc= IR2M_DataMinerCheckProc,title="Wave notes?"
	CheckBox MineWavenotes,variable= root:Packages:DataMiner:MineWavenotes, help={"Info in wave notes?"}
	CheckBox MineWaves,pos={290,200},size={80,14},proc= IR2M_DataMinerCheckProc,title="Waves?"
	CheckBox MineWaves,variable= root:Packages:DataMiner:MineWaves, help={"Waves - you can only plot the waves matching some pattern?"}


//Waves_Xtemplate;Waves_Ytemplate;Waves_Etemplate
	//Graph controls
	SetVariable Waves_Xtemplate,variable= root:Packages:DataMiner:Waves_Xtemplate,noProc, frame=1
	SetVariable Waves_Xtemplate,pos={3,230},size={250,25},title="X data:", help={"Template for X data waves"}//, fSize=10,fstyle=1,labelBack=(65280,21760,0)
	SetVariable Waves_Ytemplate,variable= root:Packages:DataMiner:Waves_Ytemplate,noProc, frame=1
	SetVariable Waves_Ytemplate,pos={3,250},size={250,25},title="Y data:", help={"Template for Y data waves"}//, fSize=10,fstyle=1,labelBack=(65280,21760,0)
	SetVariable Waves_Etemplate,variable= root:Packages:DataMiner:Waves_Etemplate,noProc, frame=1
	SetVariable Waves_Etemplate,pos={3,270},size={250,25},title="Error data:", help={"Template for Error data waves"}//, fSize=10,fstyle=1,labelBack=(65280,21760,0)
	Button Waves_ReadX, pos={300,230},size={80,15},font="Times New Roman",fSize=10,proc=IR2M_DataMinerPanelButtonProc,title="Read X", help={"Read name from table"}
	Button Waves_ReadY, pos={300,250},size={80,15},font="Times New Roman",fSize=10,proc=IR2M_DataMinerPanelButtonProc,title="Read Y", help={"Read name from table"}
	Button Waves_ReadE, pos={300,270},size={80,15},font="Times New Roman",fSize=10,proc=IR2M_DataMinerPanelButtonProc,title="Read Error", help={"Read name from table"}

	//Waves notebook controls
	//
	Button Others_Read, pos={10,230},size={100,15},font="Times New Roman",fSize=10,proc=IR2M_DataMinerPanelButtonProc,title="Add to list", help={"Add selected item to list of searched"}
	Button Others_Clear, pos={150,230},size={100,15},font="Times New Roman",fSize=10,proc=IR2M_DataMinerPanelButtonProc,title="Clear list", help={"Reset the list oif searched items..."}

	ListBox SelectedItems,pos={10,270},size={330,150}
	ListBox SelectedItems,listWave=root:Packages:DataMiner:SelectedItems
	ListBox SelectedItems selRow= 0//, proc=IR2M_ListBoxProc
	ListBox SelectedItems mode=0,help={"List of items selected to be mined..."}



//	ListOfVariables+="SaveToNotebook;SaveToWaves;SaveToGraph;"
	CheckBox SaveToNotebook,pos={5,480},size={80,14},proc= IR2M_DataMinerCheckProc,title="Save to notebook?"
	CheckBox SaveToNotebook,variable= root:Packages:DataMiner:SaveToNotebook, help={"Info will be stored in notebook."}
	CheckBox SaveToWaves,pos={130,480},size={80,14},proc= IR2M_DataMinerCheckProc,title="Save to waves?"
	CheckBox SaveToWaves,variable= root:Packages:DataMiner:SaveToWaves, help={"Info will be stored in waves"}
	CheckBox SaveToGraph,pos={255,480},size={80,14},proc= IR2M_DataMinerCheckProc,title="Create graph?"
	CheckBox SaveToGraph,variable= root:Packages:DataMiner:SaveToGraph, help={"Data will be graphed"}


	SetVariable Others_FolderForWaves,variable= root:Packages:DataMiner:Others_FolderForWaves,proc=IR2M_MinerSetVarProc, frame=1
	SetVariable Others_FolderForWaves,pos={3,455},size={350,25},title="Folder to save waves to   root:", help={"Folder to save waves with results. "}//, fSize=10,fstyle=1,labelBack=(65280,21760,0)

//	ListOfVariables+="GraphLogX;GraphLogY;GraphColorScheme1;GraphColorScheme2;GraphColorScheme3;"
	CheckBox GraphLogX,pos={155,500},size={80,14},proc= IR2M_DataMinerCheckProc,title="log X axis?"
	CheckBox GraphLogX,variable= root:Packages:DataMiner:GraphLogX, help={"Graph with log X axis"}
	CheckBox GraphLogY,pos={255,500},size={80,14},proc= IR2M_DataMinerCheckProc,title="log Y axis?"
	CheckBox GraphLogY,variable= root:Packages:DataMiner:GraphLogY, help={"Graph with log Y axis"}

	CheckBox GraphColorScheme1,pos={155,515},size={80,14},proc= IR2M_DataMinerCheckProc,title="Color scheme 1?"
	CheckBox GraphColorScheme1,variable= root:Packages:DataMiner:GraphColorScheme1, help={"One of preselected color schemes for graph"}
	CheckBox GraphColorScheme2,pos={255,515},size={80,14},proc= IR2M_DataMinerCheckProc,title="Color scheme 2?"
	CheckBox GraphColorScheme2,variable= root:Packages:DataMiner:GraphColorScheme2, help={"One of preselected color schemes for graph"}
	CheckBox GraphColorScheme3,pos={155,530},size={80,14},proc= IR2M_DataMinerCheckProc,title="Color scheme 3?"
	CheckBox GraphColorScheme3,variable= root:Packages:DataMiner:GraphColorScheme3, help={"One of preselected color schemes for graph"}
	NVAR GraphFontSize=root:Packages:DataMiner:GraphFontSize
	PopupMenu GraphFontSize,pos={155,550},size={180,20},proc=IR2M_PanelPopupControl,title="Legend font size", help={"Select font size for legend to be used."}
	PopupMenu GraphFontSize,mode=WhichListItem(num2str(GraphFontSize),  "6;8;10;12;14;16;18;20;22;24;")+1,value= "06;08;10;12;14;16;18;20;22;24;"//, popvalue="10"


	// 
	CheckBox WavesNbk_contains,pos={20,500},size={80,14},proc= IR2M_DataMinerCheckProc,title="Find present?"
	CheckBox WavesNbk_contains,variable= root:Packages:DataMiner:WavesNbk_contains, help={"Find Folders which contain these waves..."}
	CheckBox WavesNbk_NOTcontains,pos={20,520},size={80,14},proc= IR2M_DataMinerCheckProc,title="Find not present?"
	CheckBox WavesNbk_NOTcontains,variable= root:Packages:DataMiner:WavesNbk_NOTcontains, help={"Find folders which do not contain these waves..."}

//	Button LoadAndGraphData, pos={100,280},size={180,20},font="Times New Roman",fSize=10,proc=IR2E_InputPanelButtonProc,title="Load data", help={"Load data into the tool, generate graph and display notes if checkboxes are checked."}
//
//

	Button SearchAndMineData, pos={10,615},size={180,20},font="Times New Roman",fSize=10,proc=IR2M_DataMinerPanelButtonProc,title="Mine data", help={"Run data miner"}
	Button PullUpNotebook, pos={200,590},size={180,20},font="Times New Roman",fSize=10,proc=IR2M_DataMinerPanelButtonProc,title="Get notebook with results", help={"Get notebook with results if it was closed"}
	Button KillNotebook, pos={200,615},size={180,20},font="Times New Roman",fSize=10,proc=IR2M_DataMinerPanelButtonProc,title="Kill notebook with results", help={"Close (kill totally) notebook with results"}

	IR2M_FixPanelControls()
	setDataFolder oldDF
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2M_DataFolderPopMenuProc(Pa) : PopupMenuControl
	STRUCT WMPopupAction &Pa

//	Pa.win = WinName(0,64)
	if(Pa.eventCode!=2)
		return 0
	endif
	//IR2C_PanelPopupControl(ctrlName,popNum,popStr) 
	IR2C_PanelPopupControl(Pa) 
	
	IR2M_MakePanelWithListBox()
End
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR2M_MinerSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	variable i
	string OldDf=GetDataFolder(1)
	
	
	if(cmpstr(ctrlName,"Others_FolderForWaves")==0)
		SVAR Others_FolderForWaves= root:Packages:DataMiner:Others_FolderForWaves
		//add ":" at the end, if not there
		if(cmpstr(Others_FolderForWaves[strlen(Others_FolderForWaves)-1,inf],":")!=0)
			Others_FolderForWaves+=":"
		endif
		setDataFolder root:
		//Now make the folder, so it exists... Assume more than single level...
		For(i=0;i<ItemsInList(Others_FolderForWaves,":");I+=1)
			NewDataFolder/O/S $(stringFromList(i,Others_FolderForWaves,":"))
		endfor
	endif
	
	setDataFolder OldDf
End
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function/S IR2M_ListFoldersWithSubfolders(startDF, levels)
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
//        skipRest=0
//        string AllWaves = ";"+WaveList("*",";","")
////	For(i=0;i<ItemsInList(WaveList("*",";",""));i+=1)
////		tempWvName = StringFromList(i, WaveList("*",";","") ,";")
////	 //   	 if (Stringmatch(WaveList("*",";",""),WaveTypes))
//		For(j=0;j<ItemsInList(WaveTypes);j+=1)
//
//			if(skipRest || strlen(AllWaves)<2)
//				//nothing needs to be done
//			else
//				tempWaveType = stringFromList(j,WaveTypes)
//			    	 if (Stringmatch(AllWaves,"*;"+tempWaveType+";*") && skipRest==0)
//					if (LongShortType)
//				            		list += startDF + ";"
//							skipRest=1
//				      	else
//			     		      		list += GetDataFolder(0) + ";"
//		      					skipRest=1
//			      		endif
//		        	endif
//		      //  endfor
//	        endif
//   	     endfor
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
            		 list += IR2M_ListFoldersWithSubfolders(subDF, levels)       	// Recurse.
                index += 1
        while(1)
        
        SetDataFolder(dfSave)
        return list
End
//**********************************************************************************************
//**********************************************************************************************

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
//popup procedure
Function IR2M_PanelPopupControl(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:DataMiner

	NVAR GraphFontSize=root:Packages:DataMiner:GraphFontSize

	if (cmpstr(ctrlName,"GraphFontSize")==0)
		GraphFontSize=str2num(popStr)
		IR2M_AppendLegend(GraphFontSize)
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

Function IR2M_FixPanelControls()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:DataMiner
	DoWindow/F DataMiningTool
	
	NVAR MineVariables = root:Packages:DataMiner:MineVariables
	NVAR MineStrings = root:Packages:DataMiner:MineStrings
	NVAR MineWaves = root:Packages:DataMiner:MineWaves
	NVAR MineWavenotes = root:Packages:DataMiner:MineWavenotes

	NVAR SaveToNotebook = root:Packages:DataMiner:SaveToNotebook
	NVAR SaveToWaves = root:Packages:DataMiner:SaveToWaves
	NVAR SaveToGraph = root:Packages:DataMiner:SaveToGraph

	if(MineWaves)
		CheckBox SaveToNotebook,win=DataMiningTool, disable=0
		CheckBox SaveToWaves,win=DataMiningTool, disable=1
		CheckBox SaveToGraph,win=DataMiningTool, disable=0
		SetVariable Waves_Xtemplate,win=DataMiningTool, disable=0
		SetVariable Waves_Ytemplate,win=DataMiningTool, disable=0
		SetVariable Waves_Etemplate,win=DataMiningTool, disable=0
		Button Waves_ReadX,win=DataMiningTool, disable=0
		Button Waves_ReadY,win=DataMiningTool, disable=0
		Button Waves_ReadE,win=DataMiningTool, disable=0
		ListBox SelectedItems,win=DataMiningTool, disable=1
		Button Others_Read,win=DataMiningTool, disable=1
		Button Others_Clear,win=DataMiningTool, disable=1
		SetVariable Others_FolderForWaves, disable=1

	endif
	if(MineVariables || MineStrings || MineWavenotes)
		CheckBox SaveToNotebook,win=DataMiningTool, disable=0
		CheckBox SaveToWaves,win=DataMiningTool, disable=0
		CheckBox SaveToGraph,win=DataMiningTool, disable=1
		SetVariable Waves_Xtemplate,win=DataMiningTool, disable=1
		SetVariable Waves_Ytemplate,win=DataMiningTool, disable=1
		SetVariable Waves_Etemplate,win=DataMiningTool, disable=1
		Button Waves_ReadX,win=DataMiningTool, disable=1
		Button Waves_ReadY,win=DataMiningTool, disable=1
		Button Waves_ReadE,win=DataMiningTool, disable=1
		ListBox SelectedItems,win=DataMiningTool, disable=0
		Button Others_Read,win=DataMiningTool, disable=0
		Button Others_Clear,win=DataMiningTool, disable=0
	endif

	if(MineVariables || MineStrings || MineWavenotes && SaveToWaves)
		SetVariable Others_FolderForWaves, disable=0
	else
		SetVariable Others_FolderForWaves, disable=1
	endif

	if(MineWaves && SaveToGraph)
		CheckBox GraphLogX, disable=0
		CheckBox GraphLogY, disable=0
		CheckBox GraphColorScheme1, disable=0
		CheckBox GraphColorScheme2, disable=0
		CheckBox GraphColorScheme3, disable=0
		PopupMenu GraphFontSize, disable=0
	else
		CheckBox GraphLogX, disable=1
		CheckBox GraphLogY, disable=1
		CheckBox GraphColorScheme1, disable=1
		CheckBox GraphColorScheme2, disable=1
		CheckBox GraphColorScheme3, disable=1	
		PopupMenu GraphFontSize, disable=1
	endif	
	if(MineWaves && SaveToNotebook)
		CheckBox WavesNbk_contains, disable=0
		CheckBox WavesNbk_NOTcontains, disable=0
	else
		CheckBox WavesNbk_contains, disable=1
		CheckBox WavesNbk_NOTcontains, disable=1
	endif	

	setDataFolder oldDF

end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR2M_DataMinerPanelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:DataMiner

	if(cmpstr(ctrlName,"Waves_ReadX")==0)
		IR2M_ReadWavesFromListBox("Waves_X")
	endif
	if(cmpstr(ctrlName,"Waves_ReadY")==0)
		IR2M_ReadWavesFromListBox("Waves_Y")
	endif
	if(cmpstr(ctrlName,"Waves_ReadE")==0)
		IR2M_ReadWavesFromListBox("Waves_E")
	endif

	if(cmpstr(ctrlName,"SearchAndMineData")==0)
		IR2M_MineTheDataFunction()
	endif
	if(cmpstr(ctrlName,"PullUpNotebook")==0)
		IR2M_PullUpNotebook()
	endif
	if(cmpstr(ctrlName,"KillNotebook")==0)
		IR2M_KillNotebook()
	endif

	if(cmpstr(ctrlName,"Others_Read")==0)
		IR2M_ReadOthersIntoLists()
	endif
	if(cmpstr(ctrlName,"Others_Clear")==0)
		IR2M_ClearOthersLists()
	endif
	
	setDataFolder oldDF
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR2M_ReadOthersIntoLists()


	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:DataMiner

	SVAR Variables_ListToFind
	SVAR Strings_ListToFind
	SVAR WaveNotes_ListToFind
	NVAR MineVariables = root:Packages:DataMiner:MineVariables
	NVAR MineStrings = root:Packages:DataMiner:MineStrings
	NVAR MineWaves = root:Packages:DataMiner:MineWaves
	NVAR MineWavenotes = root:Packages:DataMiner:MineWavenotes
	wave/T ItemsInFolder
	wave/T WaveNoteList
	variable ItmsFldr, WvNote
	
	if(MineVariables)
		ControlInfo  /W=ItemsInFolderPanel ItemsInCurrentFolder
		if(V_Value>=0 && FindListItem(ItemsInFolder[V_Value],Variables_ListToFind)<0)
			Variables_ListToFind+= ItemsInFolder[V_Value]+";"
		endif
	endif
	if(MineStrings)
		ControlInfo  /W=ItemsInFolderPanel ItemsInCurrentFolder
		if(V_Value>=0&& FindListItem(ItemsInFolder[V_Value],Strings_ListToFind)<0)
			Strings_ListToFind+= ItemsInFolder[V_Value]+";"
		endif
	endif
	if(MineWavenotes)
		ControlInfo  /W=ItemsInFolderPanel ItemsInCurrentFolder
		ItmsFldr = V_Value
		ControlInfo  /W=ItemsInFolderPanel WaveNoteList
		WvNote = V_Value
		string tempKey
		tempKey = StringFromList(0,WaveNoteList[WvNote],"=")
		if(V_Value>=0&& FindListItem(ItemsInFolder[ItmsFldr]+":"+tempKey,WaveNotes_ListToFind)<0)
			WaveNotes_ListToFind+= ItemsInFolder[ItmsFldr]+":"+tempKey+";"
		endif
	endif


	
	IR2M_SyncSearchListAndListBox()
	setDataFolder oldDF

end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR2M_ClearOthersLists()


	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:DataMiner

	SVAR Variables_ListToFind
	SVAR Strings_ListToFind
	SVAR WaveNotes_ListToFind

	Variables_ListToFind=""
	Strings_ListToFind=""
	WaveNotes_ListToFind=""
	
	IR2M_SyncSearchListAndListBox()
	setDataFolder oldDF

end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR2M_PullUpNotebook()

	IR2M_CreateNotebook()	
end

Function IR2M_KillNotebook()

	string nbl="DataMinerNotebook"
	Silent 1
	if (strsearch(WinList("*",";","WIN:16"),nbL,0)!=-1) 		///Logbook exists
		DoWindow/K $nbl
	endif
end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2M_MineTheDataFunction()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:DataMiner

	NVAR MineVariables = root:Packages:DataMiner:MineVariables
	NVAR MineStrings = root:Packages:DataMiner:MineStrings
	NVAR MineWaves = root:Packages:DataMiner:MineWaves
	NVAR MineWavenotes = root:Packages:DataMiner:MineWavenotes
	NVAR WavesNbk_contains=root:Packages:DataMiner:WavesNbk_contains
	NVAR WavesNbk_NOTcontains=root:Packages:DataMiner:WavesNbk_NOTcontains

	NVAR SaveToNotebook = root:Packages:DataMiner:SaveToNotebook
	NVAR SaveToWaves = root:Packages:DataMiner:SaveToWaves
	NVAR SaveToGraph = root:Packages:DataMiner:SaveToGraph

	SVAR Waves_Xtemplate=root:Packages:DataMiner:Waves_Xtemplate
	SVAR Waves_Ytemplate=root:Packages:DataMiner:Waves_Ytemplate
	SVAR Waves_Etemplate=root:Packages:DataMiner:Waves_Etemplate
	NVAR GraphFontSize=root:Packages:DataMiner:GraphFontSize
	
	SVAR StartFolder=root:Packages:DataMiner:StartFolder
	string NotebookHeader
	
	if(MineWaves && SaveToNotebook)
		IR2M_CreateNotebook()	
		if(WavesNbk_contains)
			if(strlen(Waves_Etemplate)>0)
				NotebookHeader="Folders containing "+Waves_Xtemplate+" , "+Waves_Ytemplate+" , and "+Waves_Etemplate+"\r"
			elseif(strlen(Waves_Etemplate)==0 && strlen(Waves_Ytemplate)>0 && strlen(Waves_Xtemplate)>0)
				NotebookHeader="Folders containing "+Waves_Xtemplate+" and "+Waves_Ytemplate+"\r"
			elseif(strlen(Waves_Etemplate)==0 && strlen(Waves_Ytemplate)==0 && strlen(Waves_Xtemplate)>0)
				NotebookHeader="Folders containing "+Waves_Xtemplate+"\r"
			else
				//nothing to do..
				abort
			endif
		else
			if(strlen(Waves_Etemplate)>0)
				NotebookHeader="Folders not containing "+Waves_Xtemplate+" , "+Waves_Ytemplate+" , and "+Waves_Etemplate+"\r"
			elseif(strlen(Waves_Etemplate)==0 && strlen(Waves_Ytemplate)>0 && strlen(Waves_Xtemplate)>0)
				NotebookHeader="Folders not containing "+Waves_Xtemplate+" and "+Waves_Ytemplate+"\r"
			elseif(strlen(Waves_Etemplate)==0 && strlen(Waves_Ytemplate)==0 && strlen(Waves_Xtemplate)>0)
				NotebookHeader="Folders not containing "+Waves_Xtemplate+"\r"
			else
				//nothing to do..
				abort
			endif
		endif
		IR2M_InsertText(NotebookHeader)
		IN2G_UniversalFolderScan(StartFolder, 25, "IR2M_MineWavesIntoNotebook()")
		IR2M_InsertDateAndTime()
	endif
	if(MineWaves && SaveToGraph)
		IR2M_CreateGraph()
		IN2G_UniversalFolderScan(StartFolder, 25, "IR2M_MineWavesIntoGraph()")
		IR2M_AppendLegend(GraphFontSize)
		IR2M_FormatGraphAsRequested()
	endif
	if((MineVariables || MineStrings || MineWavenotes) && SaveToNotebook)
		IR2M_CreateNotebook()	
		NotebookHeader="Result of search through data "+"\r"
		IR2M_InsertText(NotebookHeader)
		IN2G_UniversalFolderScan(StartFolder, 25, "IR2M_MineOthersIntoNotebook()")
		IR2M_InsertDateAndTime()
	endif
	if((MineVariables || MineStrings || MineWavenotes) && SaveToWaves)
		IR2M_CreateWavestoMineOthers()
		IN2G_UniversalFolderScan(StartFolder, 25, "IR2M_MineOthersIntoWaves()")
		IR2M_ConvertWavestoMineOthers()
		IR2M_CreateOutputTable()
	endif

	setDataFolder oldDF

end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR2M_MineOthersIntoWaves()
	
	
	SVAR Variables_ListToFind=root:Packages:DataMiner:Variables_ListToFind
	SVAR Strings_ListToFind=root:Packages:DataMiner:Strings_ListToFind
	SVAR WaveNotes_ListToFind=root:Packages:DataMiner:WaveNotes_ListToFind
	SVAR Others_FolderForWaves=root:Packages:DataMiner:Others_FolderForWaves
	SVAR FolderMatchString=root:Packages:DataMiner:FolderMatchString

	variable i, tempVal
	string curFolder=GetDataFolder(0)
	string curWvName, curNote, curStrVal
	variable curLength
	
	if(stringmatch(curFolder, FolderMatchString))
		if(IR2M_CheckIfSomethingToDo())			
			Wave/T DataFolderName=$("root:"+Others_FolderForWaves+"DataFolderName")
			curLength=numpnts(DataFolderName)
			redimension/N=(curLength+1) DataFolderName
			DataFolderName[curLength]=GetDataFolder(0)
	
			For(i=0;i<ItemsInList(Variables_ListToFind);i+=1)
			 	curWvName=StringFromList(i,Variables_ListToFind)
			 	curWvName = CleanupName(curWvName,1)
				Wave TempWv= $("root:"+Others_FolderForWaves+curWvName)
				redimension/N=(curLength+1) TempWv
				NVAR/Z tempVar = $(curWvName)
				if(NVAR_Exists(tempVar))
					TempWv[curLength]=tempVar
				else
					TempWv[curLength]=NaN
				endif
			endfor
			For(i=0;i<ItemsInList(Strings_ListToFind);i+=1)
			 	curWvName=StringFromList(i,Strings_ListToFind)
			 	curWvName = CleanupName(curWvName,1)
				Wave/T TempWvText= $("root:"+Others_FolderForWaves+curWvName)
				redimension/N=(curLength+1) TempWvText
				SVAR/Z tempStr = $(curWvName)
				if(SVAR_Exists(tempStr))
					TempWvText[curLength]=tempStr
				else
					TempWvText[curLength]=""
				endif
			endfor
			For(i=0;i<ItemsInList(WaveNotes_ListToFind);i+=1)
				curWvName = IR2M_CreateWaveName(StringFromList(0,StringFromList(i,WaveNotes_ListToFind),":"),StringFromList(1,StringFromList(i,WaveNotes_ListToFind),":"))
//			 	curWvName=StringFromList(0,StringFromList(i,WaveNotes_ListToFind),":")+"."+StringFromList(1,StringFromList(i,WaveNotes_ListToFind),":")
//			 	if(strlen(curWvName)>32)
//			 		tempVal = 28 - strlen(StringFromList(1,StringFromList(i,WaveNotes_ListToFind),":"))
//			 		curWvName=StringFromList(0,StringFromList(i,WaveNotes_ListToFind),":")[0,tempVal]+"."+StringFromList(1,StringFromList(i,WaveNotes_ListToFind),":")
//				endif
//			 	curWvName = CleanupName(curWvName,1)
				Wave/T TempTextWave=$("root:"+Others_FolderForWaves+possiblyQuoteName(curWvName))
				redimension/N=(curLength+1) TempTextWave
				Wave/Z SourceWv=$(StringFromList(0,StringFromList(i,WaveNotes_ListToFind),":"))
				if(WaveExists(SourceWv))
					curNote=note(SourceWv)
					curStrVal = StringByKey(StringFromList(1,StringFromList(i,WaveNotes_ListToFind),":"), curNote , "=") 
					TempTextWave[curLength] = curStrVal
				else
					TempTextWave[curLength] = ""
				endif
			endfor
		endif
	endif
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR2M_isWaveNumbers(ws)
    Wave/T ws
    Variable N=numpnts(ws)
    String wName = UniqueName("isNumbers",1,0)
    Make/N=(N) $wName
    Wave w = $wName
    w = !IR2M_isaNumber(ws[p])
    Variable allNumbers = (!sum(w))
    KillWaves w
    return allNumbers
End


Function IR2M_isaNumber(in)                // checks if the input string  is ONLY a number
    String in
    String str
    Variable v
    if(strlen(in)==0)
    	return 1
    endif
    sscanf in, "%g%s", v,str
    return (V_flag==1)
End

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2M_ConvertWavestoMineOthers()
	
	
	SVAR Variables_ListToFind=root:Packages:DataMiner:Variables_ListToFind
	SVAR Strings_ListToFind=root:Packages:DataMiner:Strings_ListToFind
	SVAR WaveNotes_ListToFind=root:Packages:DataMiner:WaveNotes_ListToFind
	SVAR Others_FolderForWaves=root:Packages:DataMiner:Others_FolderForWaves
	SVAR FolderMatchString=root:Packages:DataMiner:FolderMatchString

    	String wName = UniqueName("Temp_ConvWv",1,0)
    
	variable i, tempVal
	string curWvName
	string OldDf=GetDataFolder(1)
	SetDataFolder $("root:"+Others_FolderForWaves)
	
//	Wave/T/Z DataFolderName
//	
//	For(i=0;i<ItemsInList(Strings_ListToFind);i+=1)
//	 	curWvName=StringFromList(i,Strings_ListToFind)
//	 	curWvName = CleanupName(curWvName,1)
//		Wave/T CurStrWave= $(curWvName)
//		if(IR2M_isWaveNumbers(CurStrWave))
//			make/O/N=(numpnts(CurStrWave)) $wName
//			Wave TempNumWave = $wName
//			tempNumWave=str2num(CurStrWave)
//			killwaves CurStrWave
//			Duplicate/O tempNumWave, $(curWvName)
//		endif
//	endfor
	For(i=0;i<ItemsInList(WaveNotes_ListToFind);i+=1)

		curWvName = IR2M_CreateWaveName(StringFromList(0,StringFromList(i,WaveNotes_ListToFind),":"),StringFromList(1,StringFromList(i,WaveNotes_ListToFind),":"))

//	 	curWvName=StringFromList(0,StringFromList(i,WaveNotes_ListToFind),":")+"."+StringFromList(1,StringFromList(i,WaveNotes_ListToFind),":")
//	 	if(strlen(curWvName)>32)
//	 		tempVal = 28 - strlen(StringFromList(1,StringFromList(i,WaveNotes_ListToFind),":"))
//	 		curWvName=StringFromList(0,StringFromList(i,WaveNotes_ListToFind),":")[0,tempVal]+"."+StringFromList(1,StringFromList(i,WaveNotes_ListToFind),":")
//		endif
//	 	curWvName = CleanupName(curWvName,1)
		Wave/T CurStrWave= $(curWvName)
		if(IR2M_isWaveNumbers(CurStrWave))
			make/O/N=(numpnts(CurStrWave)) $wName
			Wave TempNumWave = $wName
			tempNumWave=str2num(CurStrWave)
			killwaves CurStrWave
			Duplicate/O tempNumWave, $(curWvName)
		endif
	endfor
	KillWaves/Z tempNumWave
	
	setDataFolder OldDf
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

Function IR2M_CreateWavestoMineOthers()
	
	
	SVAR Variables_ListToFind=root:Packages:DataMiner:Variables_ListToFind
	SVAR Strings_ListToFind=root:Packages:DataMiner:Strings_ListToFind
	SVAR WaveNotes_ListToFind=root:Packages:DataMiner:WaveNotes_ListToFind
	SVAR Others_FolderForWaves=root:Packages:DataMiner:Others_FolderForWaves
	SVAR FolderMatchString=root:Packages:DataMiner:FolderMatchString

	variable i, tempVal
	string curWvName
	string OldDf=GetDataFolder(1)
	if(!DataFolderExists("root:"+Others_FolderForWaves))
		setDataFolder root:
		For(i=0;i<itemsInList(Others_FolderForWaves,":");i+=1)
			NewDataFolder/O/S $(StringFromList(i,Others_FolderForWaves,":"))
		endfor
	endif
	SetDataFolder $("root:"+Others_FolderForWaves)
	
	DoWindow SearchOutputTable
	if(V_Flag)
		DOWIndow/K SearchOutputTable
	endif
	
	Wave/T/Z DataFolderName
	if(WaveExists(DataFoldername))
		DoAlert 1, "Some search results in this folder exists, do you want to overwrite them? If not, click No and change output folder name."
		if(V_flag==2)
			setDataFolder OldDf
			abort
		endif
	endif
	
	
	make/T/O/N=0 DataFolderName
	For(i=0;i<ItemsInList(Variables_ListToFind);i+=1)
	 	curWvName=StringFromList(i,Variables_ListToFind)
	 	curWvName = CleanupName(curWvName,1)
	 	Wave/Z testWv=$(curWvName)
	 	if(WaveExists(testWv))
	 		killWaves testWv
	 	endif
		Make/O/N=0 $(curWvName)
	endfor
	For(i=0;i<ItemsInList(Strings_ListToFind);i+=1)
	 	curWvName=StringFromList(i,Strings_ListToFind)
	 	curWvName = CleanupName(curWvName,1)
	 	Wave/Z testWv=$(curWvName)
	 	if(WaveExists(testWv))
	 		killWaves testWv
	 	endif
		Make/T/O/N=0 $(curWvName)
	endfor
	For(i=0;i<ItemsInList(WaveNotes_ListToFind);i+=1)
		curWvName = IR2M_CreateWaveName(StringFromList(0,StringFromList(i,WaveNotes_ListToFind),":"),StringFromList(1,StringFromList(i,WaveNotes_ListToFind),":"))
//	 	curWvName=StringFromList(0,StringFromList(i,WaveNotes_ListToFind),":")+"."+StringFromList(1,StringFromList(i,WaveNotes_ListToFind),":")
//	 	if(strlen(curWvName)>32)
//	 		tempVal = 28 - strlen(StringFromList(1,StringFromList(i,WaveNotes_ListToFind),":"))
//	 		curWvName=StringFromList(0,StringFromList(i,WaveNotes_ListToFind),":")[0,tempVal]+"."+StringFromList(1,StringFromList(i,WaveNotes_ListToFind),":")
//		endif
//	 	curWvName = CleanupName(curWvName,1)
	 	Wave/Z testWv=$(curWvName)
	 	if(WaveExists(testWv))
	 		killWaves testWv
	 	endif
		Make/T/O/N=0 $(curWvName)
	endfor

	
	setDataFolder OldDf
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function/T IR2M_CreateWaveName(WaveNameStr,ItemNameStr)
	string WaveNameStr,ItemNameStr

	string finalStr

	 	finalStr=WaveNameStr+"."+ItemNameStr
	 	if(strlen(finalStr)>32)
	 		//tempVal = 28 - strlen(StringFromList(1,StringFromList(i,WaveNotes_ListToFind),":"))
	 		//finalStr=StringFromList(0,StringFromList(i,WaveNotes_ListToFind),":")[0,tempVal]+"."+StringFromList(1,StringFromList(i,WaveNotes_ListToFind),":")
			//treat Separately the offending cases...
			if (stringmatch(finalStr, "*Intensity*"))
				finalStr = ReplaceString("Intensity", finalStr, "Int" , 1 , 10)
			endif 
			if (stringmatch(finalStr, "*Qvector*"))
				finalStr = ReplaceString("Qvector", finalStr, "Qvec" , 1 , 10)
			endif 
			if (stringmatch(finalStr, "*Error*"))
				finalStr = ReplaceString("Error", finalStr, "Err" , 1 , 10)
			endif 
			if (stringmatch(finalStr, "*Volume*"))
				finalStr = ReplaceString("Volume", finalStr, "Vol" , 1 , 10)
			endif 
			if (stringmatch(finalStr, "*Surface*"))
				finalStr = ReplaceString("Surface", finalStr, "Surf" , 1 , 10)
			endif 
			if (stringmatch(finalStr, "*Background*"))
				finalStr = ReplaceString("Background", finalStr, "Bckg" , 1 , 10)
			endif 
			if (stringmatch(finalStr, "*Maximum*"))
				finalStr = ReplaceString("Maximum", finalStr, "Max" , 1 , 10)
			endif 
			if (stringmatch(finalStr, "*Minimum*"))
				finalStr = ReplaceString("Minimum", finalStr, "Min" , 1 , 10)
			endif 

			if (stringmatch(finalStr, "UnifiedFit*"))
				finalStr = ReplaceString("UnifiedFit", finalStr, "UF" , 1 , 1)
			endif 
		endif
	
	 	finalStr = CleanupName(finalStr,1)
	
	
	return finalStr
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR2M_CreateOutputTable()
	PauseUpdate; Silent 1		// building window...
	String fldrSav0= GetDataFolder(1)
	
	SVAR Variables_ListToFind=root:Packages:DataMiner:Variables_ListToFind
	SVAR Strings_ListToFind=root:Packages:DataMiner:Strings_ListToFind
	SVAR WaveNotes_ListToFind=root:Packages:DataMiner:WaveNotes_ListToFind
	SVAR Others_FolderForWaves=root:Packages:DataMiner:Others_FolderForWaves
	SVAR FolderMatchString=root:Packages:DataMiner:FolderMatchString

	variable tempVal
	SetDataFolder $("root:"+Others_FolderForWaves)
	DoWIndow SearchOutputTable
	if(V_Flag)
		DoWindow/K SearchOutputTable
	endif
	Edit/K=1/W=(471,48.5,1149,600.5) DataFolderName
	DoWindow/C SearchOutputTable

	variable i
	string curWvName
	string OldDf=GetDataFolder(1)
	setDataFolder $(" root:"+Others_FolderForWaves)
	
	For(i=0;i<ItemsInList(Variables_ListToFind);i+=1)
	 	curWvName=StringFromList(i,Variables_ListToFind)
	 	curWvName = CleanupName(curWvName,1)
		AppendToTable $(curWvName)
	endfor
	For(i=0;i<ItemsInList(Strings_ListToFind);i+=1)
	 	curWvName=StringFromList(i,Strings_ListToFind)
	 	curWvName = CleanupName(curWvName,1)
		AppendToTable $(curWvName)
	endfor
	For(i=0;i<ItemsInList(WaveNotes_ListToFind);i+=1)
		curWvName = IR2M_CreateWaveName(StringFromList(0,StringFromList(i,WaveNotes_ListToFind),":"),StringFromList(1,StringFromList(i,WaveNotes_ListToFind),":"))

//	 	curWvName=StringFromList(0,StringFromList(i,WaveNotes_ListToFind),":")+"."+StringFromList(1,StringFromList(i,WaveNotes_ListToFind),":")
//	 	if(strlen(curWvName)>32)
//	 		tempVal = 28 - strlen(StringFromList(1,StringFromList(i,WaveNotes_ListToFind),":"))
//	 		curWvName=StringFromList(0,StringFromList(i,WaveNotes_ListToFind),":")[0,tempVal]+"."+StringFromList(1,StringFromList(i,WaveNotes_ListToFind),":")
//		endif
//	 	curWvName = CleanupName(curWvName,1)
		AppendToTable $(curWvName)
	endfor

	AutoPositionWindow/M=0 /R=DataMiningTool SearchOutputTable

	SetDataFolder fldrSav0
End
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR2M_CheckIfSomethingToDo()

	SVAR Variables_ListToFind=root:Packages:DataMiner:Variables_ListToFind
	SVAR Strings_ListToFind=root:Packages:DataMiner:Strings_ListToFind
	SVAR WaveNotes_ListToFind=root:Packages:DataMiner:WaveNotes_ListToFind

	variable i
	string curNote
	For(i=0;i<ItemsInList(Variables_ListToFind);i+=1)
	 	NVAR/Z testVar=$(StringFromList(i,Variables_ListToFind))
		if(NVAR_Exists(testVar))
			return 1
		endif
	endfor
	For(i=0;i<ItemsInList(Strings_ListToFind);i+=1)
	 	SVAR/Z testStr=$(StringFromList(i,Strings_ListToFind))
		if(SVAR_Exists(testStr))
			return 1
		endif
	endfor
	For(i=0;i<ItemsInList(WaveNotes_ListToFind);i+=1)
	 	Wave/Z testWave=$(StringFromList(0,StringFromList(i,WaveNotes_ListToFind),":"))
		if(WaveExists(testWave))
			curNote=note(testWave)
			if(strlen(StringByKey(StringFromList(1,StringFromList(i,WaveNotes_ListToFind),":"), curNote , "=")))
				return 1
			endif
		endif
	endfor
	

end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR2M_MineOthersIntoNotebook()
	
	
	SVAR Variables_ListToFind=root:Packages:DataMiner:Variables_ListToFind
	SVAR Strings_ListToFind=root:Packages:DataMiner:Strings_ListToFind
	SVAR WaveNotes_ListToFind=root:Packages:DataMiner:WaveNotes_ListToFind
	SVAR Others_FolderForWaves=root:Packages:DataMiner:Others_FolderForWaves
	SVAR FolderMatchString=root:Packages:DataMiner:FolderMatchString

	variable i, FolderNameInserted=0
	string curNote
	string curFolder=GetDataFolder(0)
	string textToInsert
	string nbl="DataMinerNotebook"
	
	if(stringmatch(curFolder, FolderMatchString))
//		if(IR2M_CheckIfSomethingToDo())			

			For(i=0;i<ItemsInList(Variables_ListToFind);i+=1)
			 	NVAR/Z testVar=$(StringFromList(i,Variables_ListToFind))
				if(NVAR_Exists(testVar))
					if(!FolderNameInserted)
						Notebook $nbl selection={endOfFile, endOfFile}
						textToInsert = "\r"+GetDataFolder(1)+"\r"
						Notebook $nbl text=textToInsert		
						FolderNameInserted=1
					endif
					textToInsert = StringFromList(i,Variables_ListToFind)+"   =   "+num2str(testVar)+ "\r"
					Notebook $nbl text=textToInsert
				endif
			endfor
			For(i=0;i<ItemsInList(Strings_ListToFind);i+=1)
			 	SVAR/Z testStr=$(StringFromList(i,Strings_ListToFind))
				if(SVAR_Exists(testStr))
					if(!FolderNameInserted)
						Notebook $nbl selection={endOfFile, endOfFile}
						textToInsert = "\r"+GetDataFolder(1)+"\r"
						Notebook $nbl text=textToInsert		
						FolderNameInserted=1
					endif
					textToInsert = StringFromList(i,Strings_ListToFind)+"   =   "+testStr+ "\r"
					Notebook $nbl text=textToInsert
				endif
			endfor
			For(i=0;i<ItemsInList(WaveNotes_ListToFind);i+=1)
			 	Wave/Z testWave=$(StringFromList(0,StringFromList(i,WaveNotes_ListToFind),":"))
				if(WaveExists(testWave))
					curNote=note(testWave)
					if(strlen(StringByKey(StringFromList(1,StringFromList(i,WaveNotes_ListToFind),":"), curNote , "=")))
						if(!FolderNameInserted)
							Notebook $nbl selection={endOfFile, endOfFile}
							textToInsert = "\r"+GetDataFolder(1)+"\r"
							Notebook $nbl text=textToInsert		
							FolderNameInserted=1
						endif
						textToInsert = StringFromList(0,StringFromList(i,WaveNotes_ListToFind),":") +"   ;   "
						textToInsert+= StringFromList(1,StringFromList(i,WaveNotes_ListToFind),":")+"   =   "
						textToInsert+= StringByKey(StringFromList(1,StringFromList(i,WaveNotes_ListToFind),":"), curNote , "=") + "\r"
						Notebook $nbl text=textToInsert
					endif
				endif
			endfor

//	
//		if(strlen(Waves_Etemplate)>0)
//			if(((WaveExists(testX) && WaveExists(testY) && WaveExists(testE)) && WavesNbk_contains) || (!(WaveExists(testX) && WaveExists(testY) && WaveExists(testE)) && WavesNbk_NOTcontains))
//				textToInsert = GetDataFolder(1)+"\r"
//				Notebook $nbl text=textToInsert
//			endif
//		elseif(strlen(Waves_Etemplate)==0 && strlen(Waves_Ytemplate)>0 && strlen(Waves_Xtemplate)>0 )
//			if(((WaveExists(testX) && WaveExists(testY)) && WavesNbk_contains) || (!(WaveExists(testX) && WaveExists(testY)) && WavesNbk_NOTcontains)) 
//				textToInsert = GetDataFolder(1)+"\r"
//				Notebook $nbl text=textToInsert
//			endif
//		elseif(strlen(Waves_Etemplate)==0 && strlen(Waves_Ytemplate)==0 && strlen(Waves_Xtemplate)>0)
//			if((WaveExists(testX) && WavesNbk_contains) || (!WaveExists(testX) && WavesNbk_NOTcontains)) 
//				textToInsert = GetDataFolder(1)+"\r"
//				Notebook $nbl text=textToInsert
//			endif
//		else
//			//nothing to do... 
//		endif	
	endif
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2M_FormatGraphAsRequested()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:DataMiner

	NVAR GraphLogX
	NVAR GraphLogY
	NVAR GraphColorScheme1
	NVAR GraphColorScheme2
	NVAR GraphColorScheme3
	
	DoWIndow DataMiningGraph
	if(!V_Flag)
		abort
	else
		DoWindow/F DataMiningGraph
	endif
	
	ModifyGraph/Z  /W=DataMiningGraph  log(bottom)=GraphLogX
	ModifyGraph/Z  /W=DataMiningGraph  log(left)=GraphLogY
	if(GraphColorScheme1)
		IR2M_MultiColorStyle()
	elseif(GraphColorScheme2)
		IR2M_ColorCurves()
	elseif(GraphColorScheme3)
		IR2M_RainbowColorizeTraces(0)
	else
	
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

Function IR2M_MineWavesIntoGraph()
	
	SVAR Waves_Xtemplate=root:Packages:DataMiner:Waves_Xtemplate
	SVAR Waves_Ytemplate=root:Packages:DataMiner:Waves_Ytemplate
	SVAR Waves_Etemplate=root:Packages:DataMiner:Waves_Etemplate

	SVAR FolderMatchString=root:Packages:DataMiner:FolderMatchString

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
						AppendToGraph /W=DataMiningGraph testY vs TestX
				//		ErrorBars /W=DataMiningGraph "traceName", Y 
				//ErrorBars SMR_Int#31 Y,wave=(:'S32_-2.3 aluminum':SMR_Error,:'S32_-2.3 aluminum':SMR_Error)		
					endif
				else
					if(WaveExists(testX) && WaveExists(testY))
						AppendToGraph /W=DataMiningGraph testY vs TestX
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
							AppendToGraph /W=DataMiningGraph testY vs TestX
					//		ErrorBars /W=DataMiningGraph "traceName", Y 
					//ErrorBars SMR_Int#31 Y,wave=(:'S32_-2.3 aluminum':SMR_Error,:'S32_-2.3 aluminum':SMR_Error)		
						endif
					else
						if(WaveExists(testX) && WaveExists(testY))
							AppendToGraph /W=DataMiningGraph testY vs TestX
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
							AppendToGraph /W=DataMiningGraph testY vs TestX
					//		ErrorBars /W=DataMiningGraph "traceName", Y 
					//ErrorBars SMR_Int#31 Y,wave=(:'S32_-2.3 aluminum':SMR_Error,:'S32_-2.3 aluminum':SMR_Error)		
						endif
					else
						if(WaveExists(testX) && WaveExists(testY))
							AppendToGraph /W=DataMiningGraph testY vs TestX
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
///******************************************************************************************
Function IR2M_AppendLegend(FontSize)
	variable FontSize

	string Traces=TraceNameList("DataMiningGraph", ";", 1 )
	variable i
	string legendStr=""
	if(Fontsize<10)
		legendStr="\Z0"+num2str(floor(FontSize))	
	else
		legendStr="\Z"+num2str(floor(FontSize))	
	endif
	For(i=0;i<ItemsInList(Traces);i+=1)
		legendStr+="\\s("+StringFromList(i,traces)+") "+GetWavesDataFolder(TraceNameToWaveRef("DataMiningGraph", StringFromList(i,traces)),0)+":"+StringFromList(i,traces)+"\r"
	endfor
	
	Legend/C/N=text0/A=LB legendStr
end

///******************************************************************************************
///******************************************************************************************
Function IR2M_CreateGraph()
	
	DoWIndow DataMiningGraph
	if(V_Flag)
		DoWIndow/K DataMiningGraph
	endif
	Display/K=1/W=(305.25,42.5,870,498.5) 
	DoWindow/C DataMiningGraph

end

///******************************************************************************************
///******************************************************************************************
Function IR2M_InsertDateAndTime()

	Variable/D now=datetime
	string bucket11=Secs2Date(now,0)+",  "+Secs2Time(now,0) +"\r"
	string nbl="DataMinerNotebook"
	Notebook $nbl selection={endOfFile, endOfFile}
	Notebook $nbl text="\r\rList created on :     "+bucket11

end
///******************************************************************************************
///******************************************************************************************
Function IR2M_InsertText(textToInsert)
	string textToInsert

	string nbl="DataMinerNotebook"
	Notebook $nbl selection={endOfFile, endOfFile}
	Notebook $nbl text=textToInsert+"\r"

end

///******************************************************************************************
///******************************************************************************************
Function IR2M_MineWavesIntoNotebook()
	
	SVAR Waves_Xtemplate=root:Packages:DataMiner:Waves_Xtemplate
	SVAR Waves_Ytemplate=root:Packages:DataMiner:Waves_Ytemplate
	SVAR Waves_Etemplate=root:Packages:DataMiner:Waves_Etemplate
	NVAR WavesNbk_contains=root:Packages:DataMiner:WavesNbk_contains
	NVAR WavesNbk_NOTcontains=root:Packages:DataMiner:WavesNbk_NOTcontains
	SVAR FolderMatchString=root:Packages:DataMiner:FolderMatchString

	string curFolder=GetDataFolder(0)
	string ListOfAllWaves="",curName="",ListOfXWaves="",ListOfYWaves="",ListOfEWaves=""
		string textToInsert
		string nbl="DataMinerNotebook"
	variable i
	if(!stringmatch(curFolder, FolderMatchString ))
		return 1
	endif
	
	//Now we can start dealing with this
	if(strsearch(Waves_Xtemplate, "*", 0)<0 && strsearch(Waves_Ytemplate, "*", 0)<0  && strsearch(Waves_Etemplate, "*", 0)<0 )
		Wave/Z testX=$(Waves_Xtemplate)
		Wave/Z testY=$(Waves_Ytemplate)
		Wave/Z testE=$(Waves_Etemplate)
		Notebook $nbl selection={endOfFile, endOfFile}
	
		if(strlen(Waves_Etemplate)>0)
			if(((WaveExists(testX) && WaveExists(testY) && WaveExists(testE)) && WavesNbk_contains) || (!(WaveExists(testX) && WaveExists(testY) && WaveExists(testE)) && WavesNbk_NOTcontains))
				textToInsert = GetDataFolder(1)+"\r"
				Notebook $nbl text=textToInsert
			endif
		elseif(strlen(Waves_Etemplate)==0 && strlen(Waves_Ytemplate)>0 && strlen(Waves_Xtemplate)>0 )
			if(((WaveExists(testX) && WaveExists(testY)) && WavesNbk_contains) || (!(WaveExists(testX) && WaveExists(testY)) && WavesNbk_NOTcontains)) 
				textToInsert = GetDataFolder(1)+"\r"
				Notebook $nbl text=textToInsert
			endif
		elseif(strlen(Waves_Etemplate)==0 && strlen(Waves_Ytemplate)==0 && strlen(Waves_Xtemplate)>0)
			if((WaveExists(testX) && WavesNbk_contains) || (!WaveExists(testX) && WavesNbk_NOTcontains)) 
				textToInsert = GetDataFolder(1)+"\r"
				Notebook $nbl text=textToInsert
			endif
		else
			//nothing to do... 
		endif
	else
		//here we deal with the cases when user partially described the waves... Much more difficult.
		//note, this will work ONLY with present, not present needs special treatment. 
		
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
			For(i=0;i<ItemsInList(ListOfXWaves);i+=1)
				Wave/Z testX=$(stringFromList(i,ListOfXWaves))
				Wave/Z testY=$(stringFromList(i,ListOfYWaves))
				Wave/Z testE=$(stringFromList(i,ListOfEWaves))
				if(strlen(Waves_Etemplate)>0)
					if(((WaveExists(testX) && WaveExists(testY) && WaveExists(testE)) && WavesNbk_contains) || (!(WaveExists(testX) && WaveExists(testY) && WaveExists(testE)) && WavesNbk_NOTcontains))
						textToInsert = GetDataFolder(1)+"  contains    "+stringFromList(i,ListOfXWaves)+", "+stringFromList(i,ListOfYWaves)+", and "+stringFromList(i,ListOfEWaves)+"\r"
						Notebook $nbl text=textToInsert
					endif
				elseif(strlen(Waves_Etemplate)==0 && strlen(Waves_Ytemplate)>0 && strlen(Waves_Xtemplate)>0 )
					if(((WaveExists(testX) && WaveExists(testY)) && WavesNbk_contains) || (!(WaveExists(testX) && WaveExists(testY)) && WavesNbk_NOTcontains)) 
						textToInsert = GetDataFolder(1)+"  contains    "+stringFromList(i,ListOfXWaves)+", and "+stringFromList(i,ListOfYWaves)+"\r"
						Notebook $nbl text=textToInsert
					endif
				elseif(strlen(Waves_Etemplate)==0 && strlen(Waves_Ytemplate)==0 && strlen(Waves_Xtemplate)>0)
					if((WaveExists(testX) && WavesNbk_contains) || (!WaveExists(testX) && WavesNbk_NOTcontains)) 
						textToInsert = GetDataFolder(1)+"  contains    "+stringFromList(i,ListOfXWaves)+"\r"
						Notebook $nbl text=textToInsert
					endif
				else
					//nothing to do... 
				endif
			endfor
		endif
			
	endif
end

///******************************************************************************************
///******************************************************************************************
Function IR2M_CreateNotebook()
	
	string nbl="DataMinerNotebook"
	Silent 1
	if (strsearch(WinList("*",";","WIN:16"),nbL,0)!=-1) 		///Logbook exists
		DoWindow/F $nbl
	else
		NewNotebook/K=3/V=0/N=$nbl/F=1/V=1/W=(235.5,44.75,817.5,592.25) as nbl
		Notebook $nbl defaultTab=36, statusWidth=238, pageMargins={72,72,72,72}
		Notebook $nbl showRuler=1, rulerUnits=1, updating={1, 60}
		Notebook $nbl newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Arial",10,0,(0,0,0)}
		Notebook $nbl ruler=Normal; Notebook $nbl  justification=1, rulerDefaults={"Arial",14,1,(0,0,0)}
		Notebook $nbl text="This is log results of data mining of SAS data with Irena package.\r"
		Notebook $nbl text="\r"
		Notebook $nbl ruler=Normal
	endif
	DoWindow/F $nbl
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR2M_ReadWavesFromListBox(which)
	string which
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:DataMiner
	Wave/T ItemsInFolder
	
	if(cmpstr(which,"Waves_X")==0)
		SVAR Waves_Xtemplate=root:Packages:DataMiner:Waves_Xtemplate
		ControlInfo  /W=ItemsInFolderPanel ItemsInCurrentFolder
		Waves_Xtemplate = ItemsInFolder[V_Value]
	endif
	if(cmpstr(which,"Waves_Y")==0)
		SVAR Waves_Ytemplate=root:Packages:DataMiner:Waves_Ytemplate
		ControlInfo  /W=ItemsInFolderPanel ItemsInCurrentFolder
		Waves_Ytemplate = ItemsInFolder[V_Value]
	endif
	if(cmpstr(which,"Waves_E")==0)
		SVAR Waves_Etemplate=root:Packages:DataMiner:Waves_Etemplate
		ControlInfo  /W=ItemsInFolderPanel ItemsInCurrentFolder
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

Function IR2M_MakePanelWithListBox()
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:DataMiner
	
	DoWindow ItemsInFolderPanel
	if(V_Flag)
		DoWindow/K ItemsInFolderPanel
	endif
	SVAR DataFolderName=root:Packages:DataMiner:DataFolderName
	if(!DataFolderExists(DataFolderName) || cmpstr(DataFolderName,"---")==0)
		return 1
	endif
	NVAR MineVariables = root:Packages:DataMiner:MineVariables
	NVAR MineStrings = root:Packages:DataMiner:MineStrings
	NVAR MineWaves = root:Packages:DataMiner:MineWaves
	NVAR MineWavenotes = root:Packages:DataMiner:MineWavenotes
 	SVAR LastSelectedItem = root:Packages:DataMiner:LastSelectedItem

	variable WhatToTest
	string TitleStr
	if(MineWaves || MineWavenotes)
		WhatToTest=2
		TitleStr = "Waves in test folder"
	endif
	if(MineVariables)
		WhatToTest=4
		TitleStr = "Variables in test folder"
	endif
	if(MineStrings)
		WhatToTest=8
		TitleStr = "Strings in test folder"
	endif
	setDataFolder DataFolderName
	string ListOfItems = StringFromList(1,(DataFolderDir(WhatToTest)),":")
	setDataFolder root:Packages:DataMiner
	make/O/T/N=(itemsInList(ListOfItems,",")) ItemsInFolder
	variable i
	variable selItemOld=0
	for(i=0;i<itemsInList(ListOfItems,",");i+=1)
		ItemsInFolder[i]= stringFromList(0,stringFromList(i,ListOfItems,","),";")
		if(stringmatch(ItemsInFolder[i], LastSelectedItem ))
			selItemOld=i
		endif
	endfor
	
	if(strlen(ItemsInFolder[0])>0)
		if(MineWaves || MineWavenotes)
			Wave FirstSelectedWave=$(DataFolderName+possiblyQuoteName(ItemsInFolder[selItemOld]))
			string CurNote=note(FirstSelectedWave)
			if(MineWaves || MineWavenotes)
				make/T/O/N=(itemsInList(CurNote)) WaveNoteList
				for(i=0;i<itemsInList(CurNote);i+=1)
					WaveNoteList[i]= stringFromList(i,CurNote)
				endfor
			endif
		else
			if(MineStrings)
				SVAR SelectedString=$(DataFolderName+possiblyQuoteName(ItemsInFolder[selItemOld]))
				make/T/O/N=(1) WaveNoteList
				WaveNoteList[0]=SelectedString
			else
				NVAR SelectedVariable=$(DataFolderName+possiblyQuoteName(ItemsInFolder[selItemOld]))
				make/T/O/N=(1) WaveNoteList
				WaveNoteList[0]=num2str(SelectedVariable)
			endif
		endif
	else
			make/T/O/N=(1) WaveNoteList
			WaveNoteList=""
	endif

	DoWindow ItemsInFolderPanel
	if(V_Flag)
		DoWindow/K ItemsInFolderPanel
	endif
	
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(400,50,720,696) as "Items in selected folder"
	DoWindow/C ItemsInFolderPanel
	SetDrawLayer UserBack
	SetDrawEnv fsize= 16,fstyle= 3,textrgb= (0,0,65280)
	DrawText 45,21,"Items In the selected folder"
	SetDrawEnv fsize= 16,fstyle= 3,textrgb= (0,0,65280)
	DrawText 11,313,"Wave note/value for selection above:"
	ListBox ItemsInCurrentFolder,pos={2,23},size={311,262}
	ListBox ItemsInCurrentFolder,listWave=root:Packages:DataMiner:ItemsInFolder
	ListBox ItemsInCurrentFolder,mode= 1,selRow= selItemOld, proc=IR2M_ListBoxProc

	ListBox WaveNoteList,pos={3,317},size={313,244},mode=1
	ListBox WaveNoteList,listWave=root:Packages:DataMiner:WaveNoteList,row= 0
	
	AutoPositionWindow/M=0 /R=DataMiningTool ItemsInFolderPanel
	setDataFolder oldDF
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


Function IR2M_ListBoxProc(ctrlName,row,col,event) : ListBoxControl
	String ctrlName
	Variable row
	Variable col
	Variable event	//1=mouse down, 2=up, 3=dbl click, 4=cell select with mouse or keys
					//5=cell select with shift key, 6=begin edit, 7=end

	if(event==4)
		//update
		IR2M_UpdateValueListBox()
	endif
	return 0
End

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2M_UpdateValueListBox()
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:DataMiner
	
	SVAR DataFolderName=root:Packages:DataMiner:DataFolderName
	if(!DataFolderExists(DataFolderName))
		abort
	endif
	NVAR MineVariables = root:Packages:DataMiner:MineVariables
	NVAR MineStrings = root:Packages:DataMiner:MineStrings
	NVAR MineWaves = root:Packages:DataMiner:MineWaves
	NVAR MineWavenotes = root:Packages:DataMiner:MineWavenotes
	SVAR LastSelectedItem = root:Packages:DataMiner:LastSelectedItem
	variable WhatToTest
	string TitleStr
	if(MineWaves || MineWavenotes)
		WhatToTest=2
		TitleStr = "Waves in test folder"
	endif
	if(MineVariables)
		WhatToTest=4
		TitleStr = "Variables in test folder"
	endif
	if(MineStrings)
		WhatToTest=8
		TitleStr = "Strings in test folder"
	endif
//	setDataFolder DataFolderName
//	string ListOfItems = StringFromList(1,(DataFolderDir(WhatToTest)),":")
//	setDataFolder root:Packages:DataMiner
//	make/O/T/N=(itemsInList(ListOfItems,",")) ItemsInFolder
	variable i
//	for(i=0;i<itemsInList(ListOfItems,",");i+=1)
//		ItemsInFolder[i]= stringFromList(0,stringFromList(i,ListOfItems,","),";")
//	endfor
	ControlInfo  /W=ItemsInFolderPanel ItemsInCurrentFolder
	Wave/T ItemsInFolder
	variable SelectedItem=V_Value
	LastSelectedItem = ItemsInFolder[SelectedItem]
	if(MineWaves || MineWavenotes)
		Wave FirstSelectedWave=$(DataFolderName+possiblyQuoteName(ItemsInFolder[SelectedItem]))
		string CurNote=note(FirstSelectedWave)
		if(MineWaves || MineWavenotes)
			make/T/O/N=(itemsInList(CurNote)) WaveNoteList
			for(i=0;i<itemsInList(CurNote);i+=1)
				WaveNoteList[i]= stringFromList(i,CurNote)
			endfor
		endif
	else
		if(MineStrings)
			SVAR SelectedString=$(DataFolderName+possiblyQuoteName(ItemsInFolder[SelectedItem]))
			make/T/O/N=(itemsInList(SelectedString)) WaveNoteList
			for(i=0;i<itemsInList(SelectedString);i+=1)
				WaveNoteList[i]= stringFromList(i,SelectedString)
			endfor
		else
			NVAR SelectedVariable=$(DataFolderName+possiblyQuoteName(ItemsInFolder[SelectedItem]))
			make/T/O/N=(1) WaveNoteList
			WaveNoteList[0]=num2str(SelectedVariable)
		endif
	endif

	DoWindow ItemsInFolderPanel
	if(V_Flag)
		DoWindow/F ItemsInFolderPanel
	else
		abort
	endif
	ControlUpdate  /W=ItemsInFolderPanel  WaveNoteList
//	ListBox WaveNoteList,win=ItemsInFolderPanel, listWave=root:Packages:DataMiner:WaveNoteList,row= 0
	
	setDataFolder oldDF

end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function  IR2M_DataMinerCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

//	ListOfVariables+="MineVariables;MineStrings;MineWaves;MineWavenotes;"
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:DataMiner
	NVAR MineVariables = root:Packages:DataMiner:MineVariables
	NVAR MineStrings = root:Packages:DataMiner:MineStrings
	NVAR MineWaves = root:Packages:DataMiner:MineWaves
	NVAR MineWavenotes = root:Packages:DataMiner:MineWavenotes
	
	NVAR SaveToNotebook = root:Packages:DataMiner:SaveToNotebook
	NVAR SaveToWaves = root:Packages:DataMiner:SaveToWaves
	NVAR SaveToGraph = root:Packages:DataMiner:SaveToGraph

	if(cmpstr(ctrlName,"MineVariables")==0 || cmpstr(ctrlName,"MineStrings")==0 || cmpstr(ctrlName,"MineWaves")==0 || cmpstr(ctrlName,"MineWavenotes")==0)
		DoWindow ItemsInFolderPanel
		if(V_Flag)
			DoWindow/K ItemsInFolderPanel
		endif
	endif
	if(cmpstr(ctrlName,"MineVariables")==0)
		if(Checked)
			// MineVariables = 0
			 MineStrings = 0
			 MineWaves = 0
			 MineWavenotes = 0
			 IR2M_MakePanelWithListBox()
		endif
	endif
	if(cmpstr(ctrlName,"MineStrings")==0)
		if(Checked)
			 MineVariables = 0
			// MineStrings = 0
			 MineWaves = 0
			 MineWavenotes = 0
			 IR2M_MakePanelWithListBox()
		endif
	endif
	if(cmpstr(ctrlName,"MineWaves")==0)
		if(Checked)
			 MineVariables = 0
			 MineStrings = 0
			// MineWaves = 0
			 MineWavenotes = 0
			 IR2M_MakePanelWithListBox()
		endif
	endif
	if(cmpstr(ctrlName,"MineWavenotes")==0)
		if(Checked)
			 MineVariables = 0
			 MineStrings = 0
			 MineWaves = 0
			// MineWavenotes = 0
			 IR2M_MakePanelWithListBox()
		endif
	endif
	if(cmpstr(ctrlName,"SaveToNotebook")==0)
		if(Checked)
			// SaveToNotebook = 0
			 SaveToWaves = 0
			 SaveToGraph = 0
		endif
	endif
	if(cmpstr(ctrlName,"SaveToWaves")==0)
		if(Checked)
			 SaveToNotebook = 0
			// SaveToWaves = 0
		//	 SaveToGraph = 0
		endif
	endif
		if((SaveToNotebook + SaveToWaves !=1)&&(MineVariables || MineStrings || MineWavenotes))
				SaveToWaves=1
				SaveToNotebook=0
		endif

		if((SaveToNotebook + SaveToGraph !=1)&& MineWaves)
				SaveToGraph=1
				SaveToNotebook=0
		endif

	if(cmpstr(ctrlName,"GraphLogX")==0)
		//fix graph axis if exists
		IR2M_FormatGraphAsRequested()
	endif
	if(cmpstr(ctrlName,"GraphLogY")==0)
		//fix graph axis if exists
		IR2M_FormatGraphAsRequested()
	endif

	NVAR GraphColorScheme1
	NVAR GraphColorScheme2
	NVAR GraphColorScheme3
	if(cmpstr(ctrlName,"GraphColorScheme1")==0)
		if(checked)
			// GraphColorScheme1=0
			 GraphColorScheme2=0
			 GraphColorScheme3=0
			 //apply formating if graph exists
			 IR2M_FormatGraphAsRequested()
		endif
	endif
	if(cmpstr(ctrlName,"GraphColorScheme2")==0)
		if(checked)
			 GraphColorScheme1=0
			// GraphColorScheme2=0
			 GraphColorScheme3=0
			 //apply formating if graph exists
			 IR2M_FormatGraphAsRequested()
		endif
	endif
	if(cmpstr(ctrlName,"GraphColorScheme3")==0)
		if(checked)
			 GraphColorScheme1=0
			 GraphColorScheme2=0
			// GraphColorScheme3=0
			 //apply formating if graph exists
			 IR2M_FormatGraphAsRequested()
		endif
	endif

	NVAR WavesNbk_contains
	NVAR WavesNbk_NOTcontains
	if(cmpstr(ctrlName,"WavesNbk_contains")==0)
		if(Checked)
			WavesNbk_NOTcontains = 0
		else
			WavesNbk_NOTcontains=1
		endif
	endif
	if(cmpstr(ctrlName,"WavesNbk_NOTcontains")==0)
		if(Checked)
			WavesNbk_contains = 0
		else
			WavesNbk_contains=1
		endif
	endif

	IR2M_FixPanelControls()
	setDataFolder oldDF
	
End


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR2M_SyncSearchListAndListBox()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:DataMiner
	SVAR Variables_ListToFind
	SVAR Strings_ListToFind
	SVAR WaveNotes_ListToFind
	Wave/T SelectedItems
	variable i
	variable numVariables=ItemsInList(Variables_ListToFind)
	variable numStrings=ItemsInList(Strings_ListToFind)
	variable numWaveNotes=ItemsInList(WaveNotes_ListToFind)
	redimension/N=(numVariables+numStrings+numWaveNotes+4) SelectedItems
	SelectedItems[0]="DataFolderName"
	SelectedItems[1]="               Variables:"
	for(i=0;i<ItemsInList(Variables_ListToFind);i+=1)
		SelectedItems[i+2]=stringFromList(i,Variables_ListToFind)
	endfor
	SelectedItems[2+numVariables]="               Strings:"
	for(i=0;i<ItemsInList(Strings_ListToFind);i+=1)
		SelectedItems[i+3+numVariables]=stringFromList(i,Strings_ListToFind)
	endfor
	SelectedItems[3+numVariables+numStrings]="               WaveNotes:"
	for(i=0;i<ItemsInList(WaveNotes_ListToFind);i+=1)
		SelectedItems[i+4+numVariables+numStrings]=stringFromList(i,WaveNotes_ListToFind)
	endfor

	setDataFolder oldDF

end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2M_InitDataMiner()


	string OldDf=GetDataFolder(1)
	setdatafolder root:
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S DataMiner

	string ListOfVariables
	string ListOfStrings
	variable i
	
	//here define the lists of variables and strings needed, separate names by ;...
	
	ListOfVariables="UseIndra2Data;UseQRSdata;UseResults;UseSMRData;UseUserDefinedData;"
	ListOfVariables+="MineVariables;MineStrings;MineWaves;MineWavenotes;"
	ListOfVariables+="SaveToNotebook;SaveToWaves;SaveToGraph;"
	ListOfVariables+="GraphLogX;GraphLogY;GraphColorScheme1;GraphColorScheme2;GraphColorScheme3;GraphFontSize;"
	ListOfVariables+="WavesNbk_contains;WavesNbk_NOTcontains;"
//
	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;"
	ListOfStrings+="Waves_Xtemplate;Waves_Ytemplate;Waves_Etemplate;"
	ListOfStrings+="StartFolder;FolderMatchString;LastSelectedItem;"
	ListOfStrings+="Variables_ListToFind;Strings_ListToFind;WaveNotes_ListToFind;Others_FolderForWaves;Others_ListToFind;"
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
	
	NVAR GraphFontSize
	if(GraphFontSize<6)
		GraphFontSize=8
	endif
	NVAR WavesNbk_contains
	NVAR WavesNbk_NOTcontains
	if(WavesNbk_contains+WavesNbk_NOTcontains!=1)
		WavesNbk_contains=1
		WavesNbk_NOTcontains=0
	endif
	SVAR StartFolder
	if(!DataFolderExists(StartFolder) || strlen(StartFolder)<1)
		StartFolder="root:"
	endif
	SVAR FolderMatchString
	if(Strlen(FolderMatchString)==0)
		FolderMatchString="*"
	endif
	SVAR Others_FolderForWaves
	if(Strlen(Others_FolderForWaves)==0)
		Others_FolderForWaves="SearchResults:"
	endif
	SVAR Others_ListToFind
	if(Strlen(Others_ListToFind)==0)
		Others_ListToFind="DataFolderName;Variables;Strings;WaveNotes;"
	endif
	
	NVAR MineVariables
	NVAR MineStrings
	NVAR MineWaves
	NVAR MineWavenotes
	if(MineVariables+MineStrings+MineWaves+MineWavenotes!=1)
		MineVariables=0
		MineStrings=0
		MineWaves=1
		MineWavenotes=0
	endif
	
//	SVAR/Z OutputNameExtension
//	if(!SVAR_Exists(OutputNameExtension))
//		string/G OutputNameExtension
//		OutputNameExtension="dat"
//	endif
//	SVAR/Z HeaderSeparator
//	if(!SVAR_Exists(HeaderSeparator))
//		string/G HeaderSeparator
//		HeaderSeparator="#   "
//	endif
//	//Ouptu path
//	PathInfo IR2E_ExportPath
//	if(!V_Flag)
//		PathInfo Igor
//		NewPath/Q IR2E_ExportPath S_Path
//	endif
//	PathInfo IR2E_ExportPath
//	SVAR CurrentlySetOutputPath
//	CurrentlySetOutputPath=S_Path
//	
//	SVAR NewFileOutputName
//	NewFileOutputName=""
//	SVAR CurrentlyLoadedDataName
//	CurrentlyLoadedDataName = ""
//	SVAR DataFolderName
//	DataFolderName=""
//	SVAR IntensityWaveName
//	IntensityWaveName=""
//	SVAR QWavename
//	QWavename=""
//	SVAR ErrorWaveName
//	ErrorWaveName=""
	setDataFolder OldDf


end



function IR2M_RainbowColorizeTraces(rev)
variable rev  //Reverses coloring order if non-zero


    Variable k, km
    variable r,g,b,scale


    // Find the number of traces on the top graph
    String tnl = TraceNameList( "", ";", 1 )
    k = ItemsInList(tnl)
    if (k <= 1)
        return -1
    endif


    km = k
    colortab2wave Rainbow
    wave M_colors


    do
        k-=1
        scale = (rev==0 ? k : (km-k-1))  / (km-1) * dimsize(M_colors,0)
        r = M_colors[scale][0]
        g = M_colors[scale][1]
        b = M_colors[scale][2]
        ModifyGraph/Z rgb[k]=( r, g, b )
    while(k>0)
    killwaves M_colors
    return 1
end


Function IR2M_ColorCurves()
        PauseUpdate; Silent 1


        Variable i, NumTraces, iRed, iBlue, iGreen, io, w, Red, Blue, Green,  ColorNorm
        String DataName
        NumTraces=ItemsInList(TraceNameList("", ";", 1),";")


        i=0
        w = (NumTraces/2)
        do
                DataName = StringFromList(i, TraceNameList("", ";", 1),";")
                if(strlen(DataName)>0)
	                io = 0
	                iRed = exp(-(i-io)^2/w)
	                io = NumTraces/2
	                iBlue = exp(-(i-io)^2/w)
	                io = NumTraces
	                iGreen = exp(-(i-io)^2/w)
	
	
	                ColorNorm = sqrt(iRed^2 + iBlue^2 + iGreen^2)
	
	
	                Red = 65535 * (iRed/ColorNorm)
	                Blue = 65535 * (iBlue/ColorNorm)
	                Green = 65535 * (iGreen/ColorNorm)
	
	
	                ModifyGraph/Z rgb($DataName)=(Red,Blue,Green)
	                ModifyGraph/Z lsize($DataName)=1
                endif
                i+=1
        while(i<NumTraces)
End

function IR2M_MultiColorStyle()
    variable i
    variable traces=ItemsInList(TraceNameList("",";",1))
    for(i=0;(i<=traces/8);i+=1)
        ModifyGraph/Z lstyle[0+8*i]=i,lstyle[1+8*i]=i,lstyle[2+8*i] =i,lstyle[3+8*i]=i
        ModifyGraph/Z lstyle[4+8*i]=i,lstyle[5+8*i]=i,lstyle[6+8*i]=i
        ModifyGraph/Z lstyle[7+8*i]=i
        ModifyGraph/Z rgb[0+8*i]=(0,0,0),rgb[1+8*i]=(0,65535,0), rgb [2+8*i]=(0,65535,65535),rgb[3+8*i]=(32768,0,65535)
        ModifyGraph/Z rgb[4+8*i]=(65535,32768,0),rgb[5+8*i]= (65535,65535,0),rgb[6+8*i]=(65535,26214,52428)
        ModifyGraph/Z rgb[7+8*i]=(32768,16384,0)
    endfor
End

