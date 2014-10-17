#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.01

//2.01 fixed bugs when screens were coming up behind the main panel. 

//This is General graphing procedure. I'll try to make useful tool for graphing any data in SAS.
//This is difficult problem, since the variability of the problem is enormous. So there will be limits,
//but I want to make it so the user does not have to know much of Igor to create useful plots and at 
//the same time I want to make sure user can use recreation macros. Therefore we cannot copy, move
//or modify data, we have to use the data as they are in the users folders...

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//this does all....
Function IR1P_GeneralPlotTool()

	IN2G_CheckScreenSize("height",670)

	DoWindow GeneralGraph
	if (V_Flag)
		DoWindow/K GeneralGraph	
	endif
	DoWindow IR1P_ControlPanel
	if (V_Flag)
		DoWindow/K IR1P_ControlPanel	
	endif
	DoWindow IR1P_RemoveDataPanel
	if (V_Flag)
		DoWindow/K IR1P_RemoveDataPanel	
	endif
	DoWindow IR1P_ModifyDataPanel
	if (V_Flag)
		DoWindow/K IR1P_ModifyDataPanel	
	endif
	DoWindow IR1P_FittingDataPanel
	if (V_Flag)
		DoWindow/K IR1P_FittingDataPanel	
	endif
	DoWindow IR1P_ChangeGraphDetailsPanel
	if (V_Flag)
		DoWindow/K IR1P_ChangeGraphDetailsPanel	
	endif

	IR1P_InitializeGenGraph()
	//IR1_KillGraphsAndPanels()
	Execute ("IR1P_ControlPanel()")
end

//**************************************************************************************************
//		Create control panel as necessary for general plot tool
//**************************************************************************************************


Window IR1P_ControlPanel() 
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(2.25,43.25,369.75,690) as "General Plotting tool"
	SetDrawLayer UserBack
	SetDrawEnv fname= "Times New Roman",fsize= 22,fstyle= 3,textrgb= (0,0,52224)
	DrawText 57,22,"Plotting tool input panel"
	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
	DrawLine 16,199,339,199
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 8,49,"Data input"
	string UserDataTypes="Isas;"
	string UserNameString="CanSAS"
	string XUserLookup="Isas:Qsas;"
	string EUserLookup="Isas:Idev;"
	IR2C_AddDataControls("GeneralplottingTool","IR1P_ControlPanel","M_DSM_Int;DSM_Int;M_SMR_Int;SMR_Int","AllCurrentlyAllowedTypes",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,0)
//IR2C_AddDataControls(PckgDataFolder,PanelWindowName,AllowedIrenaTypes, AllowedResultsTypes, AllowedUserTypes, UserNameString, XUserTypeLookup,EUserTypeLookup, RequireErrorWaves)
	Button AddDataToGraph,pos={5,165},size={80,20},font="Times New Roman",fSize=10,proc=IR1P_InputPanelButtonProc,title="Add data", help={"Click to add data into the list of data to be displayed in the graph"}
	Button RemoveData,pos={90,165},size={80,20},font="Times New Roman",fSize=10,proc=IR1P_InputPanelButtonProc,title="Remove data", help={"Click to remove data  from the list of data to be displayed in the graph"}
	Button CreateGraph,pos={175,165},size={85,20},font="Times New Roman",fSize=10,proc=IR1P_InputPanelButtonProc,title="(Re)Graph", help={"Click to create graph or regraph with newly added data"}
	Button ResetAll,pos={265,165},size={100,20},font="Times New Roman",fSize=10,proc=IR1P_InputPanelButtonProc,title="Kill Graph, Reset", help={"Click here to kill graph and reset this tool (remove all data sets from graph)"}

//graph controls
	PopupMenu GraphType,pos={1,210},size={178,21},proc=IR1P_PanelPopupControl,title="Graph style", help={"Select graph type to create, needed data types will be created if necessary"}
	PopupMenu GraphType,mode=1,value= #"\"NewUserStyle;\"+IN2G_CreateListOfItemsInFolder(\"root:Packages:plottingToolsStyles\",8)"
	Button CreateNewStyle,pos={30,240},size={150,17},font="Times New Roman",fSize=10,proc=IR1P_InputPanelButtonProc,title="Save new graph style", help={"Click to add new graph style into the list of available graphs"}
	Button ManageStyles,pos={30,265},size={150,17},font="Times New Roman",fSize=10,proc=IR1P_InputPanelButtonProc,title="Manage Graph styles", help={"Manage graph styles (styles)."}

	Button ModifyData,pos={210,205},size={150,17},font="Times New Roman",fSize=10,proc=IR1P_InputPanelButtonProc,title="Modify data", help={"Click to open dialog to modify the data. USE CAUTION - THIS CAN HAVE BAD SIDE EFFECTS for your data!!!!"}
	Button SetGraphDetails,pos={210,225},size={150,17},font="Times New Roman",fSize=10,proc=IR1P_InputPanelButtonProc,title="Change graph details", help={"Click to open dialog to modify graph minor details."}
	Button GraphFitting,pos={210,245},size={150,17},font="Times New Roman",fSize=10,proc=IR1P_InputPanelButtonProc,title="Fitting", help={"Click to pull out panel with fitting tools."}
	Button StoreGraphs,pos={210,265},size={150,17},font="Times New Roman",fSize=10,proc=IR1P_InputPanelButtonProc,title="Store and recall graphs", help={"Store and restore graphs for future use."}

	PopupMenu XAxisDataType,pos={10,300},size={178,21},proc=IR1P_PanelPopupControl,title="X axis data", help={"Select data to be displayed on X axis, needed data types will be created if necessary"}
	PopupMenu XAxisDataType,mode=1,popvalue="X",value= "X;X^2;X^3;X^4;"
	PopupMenu YAxisDataType,pos={220,300},size={178,21},proc=IR1P_PanelPopupControl,title="Y axis data", help={"Select data to be displayed on Y axis, needed data types will be created if necessary"}
	PopupMenu YAxisDataType,mode=1,popvalue="I",value= "Y;Y^2;Y^3;Y^4;Y*X^4;Y*X^2;1/Y;sqrt(1/Y);ln(Y);ln(Y*X);ln(Y*X^2);"

	CheckBox GraphLogX pos={12,330},title="Log X axis?", variable=root:Packages:GeneralplottingTool:GraphLogX
	CheckBox GraphLogX proc=IR1P_GenPlotCheckBox, help={"Select to modify horizontal axis to log scale, uncheck for linear scale"}
	CheckBox GraphXMajorGrid pos={12,350},title="Major Grid X axis?", variable=root:Packages:GeneralplottingTool:GraphXMajorGrid
	CheckBox GraphXMajorGrid proc=IR1P_GenPlotCheckBox, help={"Check to add major grid lines to horizontal axis"}
	CheckBox GraphXMinorGrid pos={12,370},title="Minor Grid X axis?", variable=root:Packages:GeneralplottingTool:GraphXMinorGrid
	CheckBox GraphXMinorGrid proc=IR1P_GenPlotCheckBox, help={"Check to add minor grid lines to horizontal axis. May not display if graph would be too crowded."}
	CheckBox GraphXMirrorAxis pos={12,390},title="Mirror X axis?", variable=root:Packages:GeneralplottingTool:GraphXMirrorAxis
	CheckBox GraphXMirrorAxis proc=IR1P_GenPlotCheckBox, help={"Check to add mirror axis to horizontal axis"}


	CheckBox GraphLogY pos={220,330},title="Log Y axis?", variable=root:Packages:GeneralplottingTool:GraphLogY
	CheckBox GraphLogY proc=IR1P_GenPlotCheckBox, help={"Select to modify vertical axis to log scale, uncheck for linear scale"}
	CheckBox GraphYMajorGrid pos={220,350},title="Major Grid Y axis?", variable=root:Packages:GeneralplottingTool:GraphYMajorGrid
	CheckBox GraphYMajorGrid proc=IR1P_GenPlotCheckBox, help={"Check to add major grid lines to vertical axis"}
	CheckBox GraphYMinorGrid pos={220,370},title="Minor Grid Y axis?", variable=root:Packages:GeneralplottingTool:GraphYMinorGrid
	CheckBox GraphYMinorGrid proc=IR1P_GenPlotCheckBox, help={"Check to add minor grid lines to vertical axis. May not display if graph would be too crowded."}
	CheckBox GraphYMirrorAxis pos={220,390},title="Mirror Y axis?", variable=root:Packages:GeneralplottingTool:GraphYMirrorAxis
	CheckBox GraphYMirrorAxis proc=IR1P_GenPlotCheckBox, help={"Check to add mirror  axis to vertical axis."}

	SetVariable GraphXAxisName pos={20,415},size={340,20},proc=IR1P_SetVarProc,title="X axis title"
	SetVariable GraphXAxisName variable= root:Packages:GeneralplottingTool:GraphXAxisName, help={"Input horizontal axis title. Use Igor formating characters for special symbols."}	
	SetVariable GraphYAxisName pos={20,435},size={340,20},proc=IR1P_SetVarProc,title="Y axis title"
	SetVariable GraphYAxisName variable= root:Packages:GeneralplottingTool:GraphYAxisName, help={"Input vertical axis title. Use Igor formating characters for special symbols."}		

	SetVariable Xoffset pos={20,460},size={100,20},limits={0,inf,1},proc=IR1P_SetVarProc,title="X offset"
	SetVariable Xoffset variable= root:Packages:GeneralplottingTool:Xoffset, help={"Offset data in graph? For log axis multiplier, for lin axis addition"}	
	SetVariable Yoffset pos={220,460},size={100,20},limits={0,inf,1},proc=IR1P_SetVarProc,title="Y offset"
	SetVariable Yoffset variable= root:Packages:GeneralplottingTool:Yoffset, help={"Offset data in graph? For log axis multiplier, for lin axis addition"}	

	CheckBox GraphLegend pos={20,485},title="Append Legend?", variable=root:Packages:GeneralplottingTool:GraphLegend
	CheckBox GraphLegend proc=IR1P_GenPlotCheckBox, help={"Append legend to the graph?"}	
	CheckBox GraphErrors pos={230,485},title="Errors bars?", variable=root:Packages:GeneralplottingTool, help={"Display Errors?"}
	CheckBox GraphErrors proc=IR1P_GenPlotCheckBox

	//Graph Line & symbols
	CheckBox GraphUseSymbols pos={20,505},title="Use symbols?", variable=root:Packages:GeneralplottingTool:GraphUseSymbols
	CheckBox GraphUseSymbols proc=IR1P_GenPlotCheckBox, help={"Use symbols and vary them for the data?"}
	CheckBox GraphUseLines pos={20,525},title="Use lines?", variable=root:Packages:GeneralplottingTool:GraphUseLines
	CheckBox GraphUseLines proc=IR1P_GenPlotCheckBox, help={"Use lines them for the data?"}
	SetVariable GraphLineWidth pos={180,525},size={100,20},proc=IR1P_SetVarProc,title="Line width", limits={1,20,1}
	SetVariable GraphLineWidth value= root:Packages:GeneralplottingTool:GraphLineWidth, help={"Line width, same for all."}		
	SetVariable GraphSymbolSize pos={180,505},size={100,20},proc=IR1P_SetVarProc,title="Symbol size", limits={1,20,1}
	SetVariable GraphSymbolSize value= root:Packages:GeneralplottingTool:GraphSymbolSize, help={"Symbol size same for all."}		

	CheckBox GraphUseColors pos={20,545},title="Vary colors?", variable=root:Packages:GeneralplottingTool:GraphUseColors
	CheckBox GraphUseColors proc=IR1P_GenPlotCheckBox, help={"Vary colors for the data?"}	
	CheckBox GraphVarySymbols pos={120,545},title="Vary Symbols?", variable=root:Packages:GeneralplottingTool:GraphVarySymbols
	CheckBox GraphVarySymbols proc=IR1P_GenPlotCheckBox, help={"Vary symbols for the data?"}	
	CheckBox GraphVaryLines pos={240,545},title="Vary lines?", variable=root:Packages:GeneralplottingTool:GraphVaryLines
	CheckBox GraphVaryLines proc=IR1P_GenPlotCheckBox, help={"Vary Lines for the data?"}	


	//Axis ranges
	
	CheckBox GraphLeftAxisAuto pos={180,565},title="Y axis autoscale?", variable=root:Packages:GeneralplottingTool:GraphLeftAxisAuto
	CheckBox GraphLeftAxisAuto proc=IR1P_GenPlotCheckBox, help={"Autoscale Y (left) axis using data range?"}	
	SetVariable GraphLeftAxisMin pos={180,585},size={140,20},proc=IR1P_SetVarProc,title="Min: ", limits={0,inf,1e-6+root:Packages:GeneralplottingTool:GraphLeftAxisMin}
	SetVariable GraphLeftAxisMin value= root:Packages:GeneralplottingTool:GraphLeftAxisMin, format="%4.4e",help={"Minimum on Y (left) axis"}		
	SetVariable GraphLeftAxisMax pos={180,605},size={140,20},proc=IR1P_SetVarProc,title="Max:", limits={0,inf,1e-6+root:Packages:GeneralplottingTool:GraphLeftAxisMax}
	SetVariable GraphLeftAxisMax value= root:Packages:GeneralplottingTool:GraphLeftAxisMax, format="%4.4e", help={"Maximum on Y (left) axis"}		

	CheckBox GraphBottomAxisAuto pos={20,565},title="X axis autoscale?", variable=root:Packages:GeneralplottingTool:GraphBottomAxisAuto
	CheckBox GraphBottomAxisAuto proc=IR1P_GenPlotCheckBox, help={"Autoscale X (bottom) axis using data range?"}	
	SetVariable GraphBottomAxisMin pos={20,585},size={140,20},proc=IR1P_SetVarProc,title="Min: ", limits={0,inf,1e-6+root:Packages:GeneralplottingTool:GraphBottomAxisMin}
	SetVariable GraphBottomAxisMin value= root:Packages:GeneralplottingTool:GraphBottomAxisMin, format="%4.4e", help={"Minimum on X (bottom) axis"}		
	SetVariable GraphBottomAxisMax pos={20,605},size={140,20},proc=IR1P_SetVarProc,title="Max:", limits={0,inf,1e-6+root:Packages:GeneralplottingTool:GraphBottomAxisMax}
	SetVariable GraphBottomAxisMax value= root:Packages:GeneralplottingTool:GraphBottomAxisMax, format="%4.4e", help={"Maximum on X (bottom) axis"}		
	
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**************************************************************************************************
//		Control procedures for the General plotting tool 
//**************************************************************************************************

Function/T IR1P_ListOfWaves(DataType)
	string DataType			//data type   : Xaxis, Yaxis, Error
	
	NVAR UseIndra2Data=root:packages:GeneralplottingTool:UseIndra2Data
	NVAR UseQRSData=root:packages:GeneralplottingTool:UseQRSData
	NVAR UseResults=root:packages:GeneralplottingTool:UseResults

	string result="", tempresult="", tempStringQ="", tempStringR="", tempStringS=""
	SVAR FldrNm=$("root:Packages:GeneralplottingTool:DataFolderName")
	variable i,j
		
	if (UseIndra2Data)
		result=IN2G_CreateListOfItemsInFolder(FldrNm,2)
		tempresult=""
		if(cmpstr(DataType,"Xaxis")==0)
		//	if(stringMatch(result,"*DSM_Qvec*"))
				for (i=0;i<ItemsInList(result);i+=1)
					if (stringMatch(StringFromList(i,result),"*DSM_Qvec*"))
						tempresult+=StringFromList(i,result)+";"
					endif
				endfor
				For (j=0;j<ItemsInList(result);j+=1)
					if (stringMatch(StringFromList(j,result),"*BKG_Qvec*"))
						tempresult+=StringFromList(j,result)+";"
					endif
				endfor
				For (j=0;j<ItemsInList(result);j+=1)
					if (stringMatch(StringFromList(j,result),"*SMR_Qvec*"))
						tempresult+=StringFromList(j,result)+";"
					endif
				endfor
		//	endif
		elseif (cmpstr(DataType,"Yaxis")==0)
		//	if(stringMatch(result,"*DSM_Int*"))
				for (i=0;i<ItemsInList(result);i+=1)
					if (stringMatch(StringFromList(i,result),"*DSM_Int*"))
						tempresult+=StringFromList(i,result)+";"
					endif
				endfor
				For (j=0;j<ItemsInList(result);j+=1)
					if (stringMatch(StringFromList(j,result),"*BKG_Int*"))
						tempresult+=StringFromList(j,result)+";"
					endif
				endfor
				For (j=0;j<ItemsInList(result);j+=1)
					if (stringMatch(StringFromList(j,result),"*SMR_Int*"))
						tempresult+=StringFromList(j,result)+";"
					endif
				endfor
		//	endif
		else // (cmpstr(DataType,"Error")==0)
			//if(stringMatch(result,"*DSM_Error*"))
				for (i=0;i<ItemsInList(result);i+=1)
					if (stringMatch(StringFromList(i,result),"*DSM_Error*"))
						tempresult+=StringFromList(i,result)+";"
					endif
				endfor
				For (j=0;j<ItemsInList(result);j+=1)
					if (stringMatch(StringFromList(j,result),"*BKG_Error*"))
						tempresult+=StringFromList(j,result)+";"
					endif
				endfor
				For (j=0;j<ItemsInList(result);j+=1)
					if (stringMatch(StringFromList(j,result),"*SMR_Error*"))
						tempresult+=StringFromList(j,result)+";"
					endif
				endfor
			//endif
		endif
		result=tempresult
	elseif(UseQRSData) 
		result=""			//IN2G_CreateListOfItemsInFolder(FldrNm,2)
		tempStringQ=IR1_ListOfWavesOfType("q",IN2G_CreateListOfItemsInFolder(FldrNm,2))
		tempStringR=IR1_ListOfWavesOfType("r",IN2G_CreateListOfItemsInFolder(FldrNm,2))
		tempStringS=IR1_ListOfWavesOfType("s",IN2G_CreateListOfItemsInFolder(FldrNm,2))
		
		if (cmpstr(DataType,"Yaxis")==0)
			For (j=0;j<ItemsInList(tempStringR);j+=1)
				if (stringMatch(tempStringQ,"*q"+StringFromList(j,tempStringR)[1,inf]+";*"))// && stringMatch(tempStringS,"*s"+StringFromList(j,tempStringR)[1,inf]+";*"))
					result+=StringFromList(j,tempStringR)+";"
				endif
			endfor
		elseif(cmpstr(DataType,"Xaxis")==0)
			For (j=0;j<ItemsInList(tempStringQ);j+=1)
				if (stringMatch(tempStringR,"*r"+StringFromList(j,tempStringQ)[1,inf]+";*"))// && stringMatch(tempStringS,"*s"+StringFromList(j,tempStringQ)[1,inf]+";*"))
					result+=StringFromList(j,tempStringQ)+";"
				endif
			endfor
		else
			For (j=0;j<ItemsInList(tempStringS);j+=1)
				if (stringMatch(tempStringR,"*r"+StringFromList(j,tempStringS)[1,inf]+";*") && stringMatch(tempStringQ,"*q"+StringFromList(j,tempStringS)[1,inf]+";*"))
					result+=StringFromList(j,tempStringS)+";"
				endif
			endfor
		endif
	elseif (UseResults)
		result=IN2G_CreateListOfItemsInFolder(FldrNm,2)
		tempresult=""
		string tempstr
		if(cmpstr(DataType,"Xaxis")==0)
			For (j=0;j<ItemsInList(result);j+=1)
			tempstr= StringFromList(j,result)
				if (stringMatch(tempstr,"UnifiedFitQvector*") || stringMatch(tempstr,"SizesFitQvector*")|| stringMatch(tempstr,"SizesDistDiameter*") ||stringMatch(tempstr,"ModelingDiameters*") || stringMatch(tempstr,"FractFitQvector*") || stringMatch(tempstr,"ModelingQvector*"))
					tempresult+=tempstr+";"
				endif
			endfor		
		elseif (cmpstr(DataType,"Yaxis")==0)
			For (j=0;j<ItemsInList(result);j+=1)
			tempstr= StringFromList(j,result)
				if (stringMatch(tempstr,"UnifiedFitIntensity*") || stringMatch(tempstr,"SizesFitIntensity*") || stringMatch(tempstr,"SizesVolumeDistribution*")|| stringMatch(tempstr,"SizesNumberDistribution*") ||stringMatch(tempstr,"ModelingNumberDistribution*")||stringMatch(tempstr,"ModelingVolumeDistribution*") || stringMatch(tempstr,"FractFitIntensity*") || stringMatch(tempstr,"ModelingIntensity*"))
					tempresult+=tempstr+";"
				endif
			endfor		
		else		//error
			result = "---"
		endif
		result = tempresult
	else
		result=IN2G_CreateListOfItemsInFolder(FldrNm,2)
	endif
	
	return result
end


Function/T IR1P_GenStringOfFolders()
		
	NVAR UseIndra2Structure=root:packages:GeneralplottingTool:UseIndra2Data
	NVAR UseQRSStructure=root:packages:GeneralplottingTool:UseQRSData
	NVAR UseResults=root:packages:GeneralplottingTool:UseResults
	string ListOfQFolders
	string result
	if (UseIndra2Structure)
		//result=IN2G_FindFolderWithWaveTypes("root:USAXS:", 10, "*DSM*", 1)
		string tempStr=IN2G_FindFolderWithWaveTypes("root:USAXS:", 10, "*SMR*", 1)
		result=IN2G_FindFolderWithWaveTypes("root:USAXS:", 10, "*DSM*", 1)+";"
		variable i
		for(i=0;i<ItemsInList(tempStr);i+=1)
		//print stringmatch(result, "*"+StringFromList(i, tempStr,";")+"*")
			if(stringmatch(result, "*"+StringFromList(i, tempStr,";")+"*")==0)
				result+=StringFromList(i, tempStr,";")+";"
			endif
		endfor
	elseif (UseQRSStructure)
		ListOfQFolders=IN2G_FindFolderWithWaveTypes("root:", 10, "q*", 1)
		result=IR1_ReturnListQRSFolders(ListOfQFolders,1)
	elseif (UseResults)
		ListOfQFolders=IN2G_FindFolderWithWaveTypes("root:", 10, "UnifiedFitIntensity*", 1)
		ListOfQFolders+=IN2G_FindFolderWithWaveTypes("root:", 10, "SizesVolumeDistribution*", 1)
		ListOfQFolders+=IN2G_FindFolderWithWaveTypes("root:", 10, "ModelingVolumeDistribution*", 1)
		ListOfQFolders+=IN2G_FindFolderWithWaveTypes("root:", 10, "FractFitIntensity*", 1)
		result=ReturnListResultsFolders(ListOfQFolders)
	else
		result=IN2G_FindFolderWithWaveTypes("root:", 10, "*", 1)
	endif
	
	return result
end

Function/T ReturnListResultsFolders(ListOfQFolders)
	string ListOfQFolders
	
	string result=""
	variable i
	For(i=0;i<ItemsInList(ListOfQFolders);i+=1)
		if(!stringmatch(result, "*"+stringFromList(i,ListOfQFolders)+"*"))
			result+=stringFromList(i,ListOfQFolders)+";"
		endif
	
	endfor
	
	return result

end


Function IR1P_InputPanelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:GeneralplottingTool
	
	variable IsAllAllRight

	if (cmpstr(ctrlName,"AddDataToGraph")==0)
		//here goes what is done, when user pushes Graph button
		SVAR DFloc=root:Packages:GeneralplottingTool:DataFolderName
		SVAR DFInt=root:Packages:GeneralplottingTool:IntensityWaveName
		SVAR DFQ=root:Packages:GeneralplottingTool:QWaveName
		SVAR DFE=root:Packages:GeneralplottingTool:ErrorWaveName
		IsAllAllRight=1
		if (cmpstr(DFloc,"---")==0 || strlen(DFloc)<=0)
			IsAllAllRight=0
		endif
		if (cmpstr(DFInt,"---")==0 || strlen(DFInt)<=0)
			IsAllAllRight=0
		endif
		if (cmpstr(DFQ,"---")==0 || strlen(DFQ)<=0)
			IsAllAllRight=0
		endif
//		if (cmpstr(DFE,"---")==0) //commented out, so data without error bars can be displayed
//			IsAllAllRight=0
//		endif
		
		if (IsAllAllRight)
			IR1P_RecordDataForGraph()
		else
			Abort "Data not selected properly"
		endif
		IR1P_CreateGraph()					//create or update the graph
		DoWIndow/F IR1P_ControlPanel
	endif
	if (cmpstr(ctrlName,"CreateGraph")==0)
		//here goes what is done, when user pushes Graph button
		IsAllAllRight=1

		if (IsAllAllRight)
			IR1P_CreateGraph()
		else
			Abort "Data not selected properly"
		endif
		DoWIndow/F IR1P_ControlPanel
	endif
	if (cmpstr(ctrlName,"RemoveData")==0)
		//here goes what is done, when user pushes Graph button
		IR1P_RemoveDataFn()
	endif
	
	
	if (cmpstr(ctrlName,"CreateNewStyle")==0)
		//here goes what is done, when user pushes Graph button
			IR1P_CreateNewUserStyle()
		DoWIndow/F IR1P_ControlPanel
	endif
	if (cmpstr(ctrlName,"ResetAll")==0)
		//here goes what is done, when user pushes Graph button
			IR1P_ResetTool()
		DoWIndow/F IR1P_ControlPanel
	endif
	if (cmpstr(ctrlName,"SetGraphDetails")==0)
		//here goes what is done, when user pushes Graph button
			IR1P_ChangeGraphDetailsFn()
	endif
	if (cmpstr(ctrlName,"ModifyData")==0)
		//here goes what is done, when user pushes Graph button
			IR1P_ModifyDataFn()
	endif
	if (cmpstr(ctrlName,"GraphFitting")==0)
		//here goes what is done, when user pushes Graph button
			IR1P_FittingDataFn()
	endif
	if (cmpstr(ctrlName,"ManageStyles")==0)
		//here goes what is done, when user pushes Graph button
			IR1P_ManageStyles()
	endif
	if (cmpstr(ctrlName,"StoreGraphs")==0)
		//here goes what is done, when user pushes Graph button
			IR1P_StoreGraphs()
	endif
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1P_RemoveDataFn()
	//here we create new panel with some more controls...
	
	DoWindow IR1P_RemoveDataPanel
	if(V_Flag)
		DoWindow/K IR1P_RemoveDataPanel
	endif
	Execute ("IR1P_RemoveDataPanel()")

end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//creates modify data panel. For now empty
Function IR1P_ModifyDataFn()
	//here we create new panel with some more controls...
	
	NVAR ModifyDataBackground=root:Packages:GeneralplottingTool:ModifyDataBackground
	NVAR ModifyDataMultiplier=root:Packages:GeneralplottingTool:ModifyDataMultiplier
	NVAR ModifyDataQshift=root:Packages:GeneralplottingTool:ModifyDataQshift
	NVAR ModifyDataErrorMult=root:Packages:GeneralplottingTool:ModifyDataErrorMult
	NVAR TrimPointSmallQ=root:Packages:GeneralplottingTool:TrimPointSmallQ
	NVAR TrimPointLargeQ=root:Packages:GeneralplottingTool:TrimPointLargeQ
	SVAR ListOfRemovedPoints=root:Packages:GeneralplottingTool:ListOfRemovedPoints
	
	TrimPointSmallQ=0
	TrimPointLargeQ=inf
	ModifyDataBackground=0
	ModifyDataMultiplier=1
	ModifyDataQshift=0
	ModifyDataErrorMult=1
	ListOfRemovedPoints=""
	
	DoWindow IR1P_ModifyDataPanel
	if(V_Flag)
		DoWindow/K IR1P_ModifyDataPanel
	endif
	Execute ("IR1P_ModifyDataPanel()")
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR1P_FittingDataFn()
	//here we create new panel with some more controls...
	
	DoWindow IR1P_FittingDataPanel
	if(V_Flag)
		DoWindow/K IR1P_FittingDataPanel
	endif
	Execute ("IR1P_FittingDataPanel()")
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//another of modify data panel macros
Window IR1P_FittingDataPanel() 
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(63,128.75,375,425.75) as "IR1P_FittingDataPanel"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,0,65280)
	DrawText 5,23,"Standard fitts to the data in the graph"
	SetDrawEnv textrgb= (65280,0,0)
	DrawText 16,42,"Set cursors to a data set to range of data"
	SetDrawEnv textrgb= (65280,0,0)
	DrawText 16,58,"Select function etc."
	SetDrawEnv fsize= 12,fstyle= 1,textrgb= (0,0,65280)
	DrawText 16,135,"Input starting guesses for parameters"
	
	PopupMenu SelectFitFunction,pos={10,66},size={178,20},proc=IR1P_PanelPopupControlFitting,title="Function", help={"Select fitting function to use to fit on the data"}
	PopupMenu SelectFitFunction,mode=1,value= "---;Line;Porod in loglog;Guinier in loglog;Area under curve;", popvalue = root:Packages:GeneralplottingTool:FittingSelectedFitFunction

	SetVariable FittingFunctionDescription pos={3,96},size={310,20},title="Fitted formula", limits={-inf,inf,0},noedit=1, frame=0 //,proc=IR1P_SetVarProc
	SetVariable FittingFunctionDescription value= root:Packages:GeneralplottingTool:FittingFunctionDescription, help={"Fitted formula spelled out"}		
	CheckBox FitUseErrors pos={220,66},title="Use errors?", variable=root:Packages:GeneralplottingTool:FitUseErrors
	CheckBox FitUseErrors noproc, help={"Use error for fitting?"}	
	
	Button GuessFitParam pos={10,230}, size={120,20},font="Times New Roman",fSize=10, proc=IRP_ButtonProc3,title="Guess fit param", help={"Will guess starting parameters for fitting."}
	Button DoFitting pos={10,260}, size={120,20},font="Times New Roman",fSize=10, proc=IRP_ButtonProc3,title="Fit", help={"Do the fitting on data between cursors. Will generate error if cursors are not on the same wave."}
	Button RemoveTagsAndFits pos={150,260}, size={120,20}, font="Times New Roman",fSize=10,proc=IRP_ButtonProc3,title="Remove Tags and Fits", help={"Remove the fit curves and tag from previous fits"}

	IR1P_ModifyFittingPanel(root:Packages:GeneralplottingTool:FittingSelectedFitFunction)
EndMacro


//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1P_PanelPopupControlFitting(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:GeneralplottingTool

	if (cmpstr(ctrlName,"SelectFitFunction")==0)		
		IR1P_ModifyFittingPanel(popStr)
	endif
	
	setDataFolder oldDf
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1P_ModifyFittingPanel(popStr)
	string popStr
	//here we need to modify fitting panel for the appropriate fitting function as well as save the fitting function in string
	
	SVAR FittingSelectedFitFunction = root:Packages:GeneralplottingTool:FittingSelectedFitFunction 
	FittingSelectedFitFunction  = popStr

	SVAR FittingFunctionDescription = root:Packages:GeneralplottingTool:FittingFunctionDescription 
	NVAR FittingParam1 = root:Packages:GeneralplottingTool:FittingParam1 	//background
	NVAR FittingParam2 = root:Packages:GeneralplottingTool:FittingParam2 	//first fitting param.
	// Porod constant, 
	NVAR FittingParam3 = root:Packages:GeneralplottingTool:FittingParam3 
	NVAR FittingParam4 = root:Packages:GeneralplottingTool:FittingParam4 
	NVAR FittingParam5 = root:Packages:GeneralplottingTool:FittingParam5 
	
	SetVariable FittingParam1, disable = 1, win=IR1P_FittingDataPanel
	SetVariable FittingParam2, disable = 1, win=IR1P_FittingDataPanel
	SetVariable FittingParam3, disable = 1, win=IR1P_FittingDataPanel
	SetVariable FittingParam4, disable = 1, win=IR1P_FittingDataPanel
	SetVariable FittingParam5, disable = 1, win=IR1P_FittingDataPanel
	
	if(cmpstr(popStr,"Line")==0)
		//here goes modifications for line
		FittingFunctionDescription = "Int = a * Q + background"
	endif
	if(cmpstr(popStr,"Porod in loglog")==0)
		//here goes modifications for line
		FittingFunctionDescription = "Int = PC * Q^(-4) + background"
		SetVariable FittingParam1 pos={10,140},size={210,20},title="Background      ", limits={-inf,inf,1}, disable=0, win=IR1P_FittingDataPanel
		SetVariable FittingParam1 value= root:Packages:GeneralplottingTool:FittingParam1, format="%4.4e", help={"Fitted formula spelled out"}		
		SetVariable FittingParam2 pos={10,160},size={210,20},title="Porod const.     ", limits={-inf,inf,1}, disable=0, win=IR1P_FittingDataPanel
		SetVariable FittingParam2 value= root:Packages:GeneralplottingTool:FittingParam2, format="%4.4e", help={"Fitted formula spelled out"}		
		if (FittingParam2==0)
			FittingParam2=1
		endif
	endif
	if(cmpstr(popStr,"Guinier in loglog")==0)
		//here goes modifications for line
		FittingFunctionDescription = "Int = G*exp(-q^2*Rg^2/3))"
		SetVariable FittingParam1 pos={10,140},size={210,20},title="G      ", limits={0,inf,1}, disable=0, win=IR1P_FittingDataPanel
		SetVariable FittingParam1 value= root:Packages:GeneralplottingTool:FittingParam1, format="%4.4e", help={"Guinier fit prefactor (G)"}		
		SetVariable FittingParam2 pos={10,160},size={210,20},title="Rg        ", limits={0,inf,1}, disable=0, win=IR1P_FittingDataPanel
		SetVariable FittingParam2 value= root:Packages:GeneralplottingTool:FittingParam2, format="%4.4e", help={"Guinier fit Rg"}		
		if (FittingParam2==0)
			FittingParam2=100
		endif
		if (FittingParam1==0)
			FittingParam1=10
		endif
	endif

	if(cmpstr(popStr,"Area under curve")==0)
		//here goes modifications for line
		FittingFunctionDescription = "For size distributions, Vol/Num of scatterers"
	endif

end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1P_GuessFitParam()

	string OldDf = GetDataFolder(1)
	setDataFolder root:Packages:GeneralplottingTool:
	SVAR FittingSelectedFitFunction = root:Packages:GeneralplottingTool:FittingSelectedFitFunction 
	SVAR FittingFunctionDescription = root:Packages:GeneralplottingTool:FittingFunctionDescription 
	NVAR FittingParam1 = root:Packages:GeneralplottingTool:FittingParam1 	//background, G in guinier
	NVAR FittingParam2 = root:Packages:GeneralplottingTool:FittingParam2 	//first fitting param.
	// Porod constant, Rg in Guinier
	NVAR FittingParam3 = root:Packages:GeneralplottingTool:FittingParam3 
	NVAR FittingParam4 = root:Packages:GeneralplottingTool:FittingParam4 
	NVAR FittingParam5 = root:Packages:GeneralplottingTool:FittingParam5 
	
	NVAR FitUseErrors=root:Packages:GeneralplottingTool:FitUseErrors
	//this contains the fitting function

	//now lets make checkbox for 
	Wave/Z ErrorWave=$(IR1P_FindErrorWaveForCursor())
	if(WaveExists(ErrorWave))
		CheckBox FitUseErrors disable=0, win=IR1P_FittingDataPanel
		FitUseErrors=1
	else
		CheckBox FitUseErrors disable=1, win=IR1P_FittingDataPanel
		FitUseErrors=0
	endif	
	//check that cursors are set and set on the same wave or give error
	
	Wave/Z CursorAWave = CsrWaveRef(A, "GeneralGraph")
	Wave/Z CursorBWave = CsrWaveRef(B, "GeneralGraph")
	if(!WaveExists(CursorAWave) || !WaveExists(CursorBWave) || cmpstr(NameOfWave(CursorAWave),NameOfWave(CursorBWave))!=0)
		Abort "The cursors are not set properly - they are not in the graph or not on the same wave"
	endif
	Wave CursorAXWave= CsrXWaveRef(A, "GeneralGraph")

	if(cmpstr(FittingSelectedFitFunction,"Porod in loglog")==0)
		if (pcsr(B)>pcsr(A))
			FittingParam2=CursorAWave[pcsr(A)]/(CursorAXWave[pcsr(A)]^(-4))
			FittingParam1=CursorAwave[pcsr(B)]
		else
			FittingParam2=CursorAWave[pcsr(B)]/(CursorAXWave[pcsr(B)]^(-4))
			FittingParam1=CursorAwave[pcsr(A)]		
		endif
	endif

	if(cmpstr(FittingSelectedFitFunction,"Guinier in loglog")==0)
		if (pcsr(B)>pcsr(A))
			FittingParam1=CursorAWave[pcsr(A)]
			FittingParam2=1/((CursorAXwave[pcsr(B)] + 7*CursorAXwave[pcsr(A)])/8)	
		else
			FittingParam1=CursorAWave[pcsr(B)]
			FittingParam2=1/((CursorAXwave[pcsr(A)] + 7*CursorAXwave[pcsr(B)])/8)	
		endif
	endif	

end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1P_DoFitting()

	string OldDf = GetDataFolder(1)
	setDataFolder root:Packages:GeneralplottingTool:
	SVAR FittingSelectedFitFunction = root:Packages:GeneralplottingTool:FittingSelectedFitFunction 
	SVAR FittingFunctionDescription = root:Packages:GeneralplottingTool:FittingFunctionDescription 
	NVAR FittingParam1 = root:Packages:GeneralplottingTool:FittingParam1 	//background, G in Guinier,
	NVAR FittingParam2 = root:Packages:GeneralplottingTool:FittingParam2 	//first fitting param.
	// Porod constant, Rg in Guinier,
	NVAR FittingParam3 = root:Packages:GeneralplottingTool:FittingParam3 
	NVAR FittingParam4 = root:Packages:GeneralplottingTool:FittingParam4 
	NVAR FittingParam5 = root:Packages:GeneralplottingTool:FittingParam5 
	
	NVAR FitUseErrors=root:Packages:GeneralplottingTool:FitUseErrors
	//this contains the fitting function
	
	//check that cursors are set and set on the same wave or give error
	
	Wave/Z CursorAWave = CsrWaveRef(A, "GeneralGraph")
	Wave/Z CursorBWave = CsrWaveRef(B, "GeneralGraph")
	if(!WaveExists(CursorAWave) || !WaveExists(CursorBWave) || cmpstr(NameOfWave(CursorAWave),NameOfWave(CursorBWave))!=0)
		Abort "The cursors are not set properly - they are not in the graph or not on the same wave"
	endif
	Wave CursorAXWave= CsrXWaveRef(A, "GeneralGraph")
	string TagName= UniqueName("IR1P_TagName",14,0,"GeneralGraph")
	string TagText

	Wave/Z  FitWave= $("fit_"+NameOfWave(CursorAWave))
	KillWaves/Z FitWave
	string FitWaveName= UniqueName("IR1P_FitWave",1,0)
	Wave/Z  FitXWave= $("fitX_"+NameOfWave(CursorAWave))
	KillWaves/Z FitXWave
	string FitXWaveName= UniqueName("IR1P_FitWaveX",1,0)

	Make/D/N=0/O W_coef, LocalEwave
	Make/D/T/N=0/O T_Constraints
	Wave/Z W_sigma
	//find the error wave and make it available, if exists
	Wave/Z ErrorWave=$(IR1P_FindErrorWaveForCursor())
	Variable V_FitError=0			//This should prevent errors from being generated

	
	if(cmpstr(FittingSelectedFitFunction,"Line")==0)
		//do line fitting
		if (FitUseErrors && WaveExists(ErrorWave))
			CurveFit line CursorAWave[pcsr(A),pcsr(B)] /X=CursorAXWave /D /W=ErrorWave /I=1
		else
			CurveFit line CursorAWave[pcsr(A),pcsr(B)] /X=CursorAXWave /D		
		endif
		TagText = "Fitted line y=a + bx.\r a = "+num2str(W_coef[0])+"\r b = "+num2str(W_coef[1])+"\r chi-square = "+num2str(V_chisq)
		Tag/C/W=GeneralGraph/N=$(TagName)/L=2 $NameOfWave(CursorAWave), ((pcsr(A) + pcsr(B))/2),TagText	
	endif
	if(cmpstr(FittingSelectedFitFunction,"Area under curve")==0)	
		if(!(strlen(CsrWave(A,"GeneralGraph"))>0) || !(strlen(CsrWave(B,"GeneralGraph"))>0) )
			abort "Cursors not set"
		endif		
		if(cmpstr(CsrWave(A,"GeneralGraph"),CsrWave(B,"GeneralGraph"))!=0) 
			abort "Cursors not set on the same waves"
		endif		
		//print CsrWaveRef(A,"GeneralGraph")
		wave MyXWave=CsrXWaveRef(A,"GeneralGraph")
	
		Wave MyYWave=CsrWaveRef(A,"GeneralGraph")
		variable volume
		volume = areaXY(MyXWave,MyYWave, MyXWave[pcsr(A)],MyXWave[pcsr(B)])
		Tag/C/W=GeneralGraph/N=$(TagName)/L=2 $NameOfWave(CursorAWave), ((pcsr(A) + pcsr(B))/2),"Volume/Number of scatterers = "+num2str(volume)
	endif
	if(cmpstr(FittingSelectedFitFunction,"Porod in loglog")==0)
		//do line fitting
		Redimension /N=2 W_coef
		Redimension/N=1 T_Constraints
		T_Constraints[0] = {"K1 > 0"}
		W_coef = {FittingParam2,FittingParam1}
		V_FitError=0			//This should prevent errors from being generated
		if (FitUseErrors && WaveExists(ErrorWave))
			FuncFit PorodInLogLog W_coef CursorAWave[pcsr(A),pcsr(B)] /X=CursorAXWave /D /C=T_Constraints /W=ErrorWave /I=1
		else
			FuncFit PorodInLogLog W_coef CursorAWave[pcsr(A),pcsr(B)] /X=CursorAXWave /D /C=T_Constraints			
		endif
		if (V_FitError!=0)	//there was error in fitting
			RemoveFromGraph $("fit_"+NameOfWave(CursorAWave))
			beep
			Abort "Fitting error, check starting parameters and fitting limits" 
		endif
		Wave W_sigma
		TagText = "Fitted Porod  "+FittingFunctionDescription+" \r PC = "+num2str(W_coef[0])+"\r Background = "+num2str(W_coef[1])
		if (FitUseErrors && WaveExists(ErrorWave))
			TagText+="\r chi-square = "+num2str(V_chisq)
		endif
		Tag/C/W=GeneralGraph/N=$(TagName)/L=2 $NameOfWave(CursorAWave), ((pcsr(A) + pcsr(B))/2),TagText	
		FittingParam2=W_coef[0]
		FittingParam1=W_coef[1]
	endif

	if(cmpstr(FittingSelectedFitFunction,"Guinier in loglog")==0)

		Redimension /N=2 W_coef, LocalEwave
		Redimension/N=2 T_Constraints
		T_Constraints[0] = {"K1 > 0"}
		T_Constraints[1] = {"K0 > 0"}

		W_coef[0]=FittingParam1 	//G
		W_coef[1]=FittingParam2	//Rg

		LocalEwave[0]=(FittingParam1/20)
		LocalEwave[1]=(FittingParam2/20)

		V_FitError=0			//This should prevent errors from being generated
		if (FitUseErrors && WaveExists(ErrorWave))
			FuncFit IR1_GuinierFit W_coef CursorAWave[pcsr(A),pcsr(B)] /X=CursorAXWave /D /C=T_Constraints /W=ErrorWave /I=1//E=LocalEwave 
		else
			FuncFit IR1_GuinierFit W_coef CursorAWave[pcsr(A),pcsr(B)] /X=CursorAXWave /D /C=T_Constraints //E=LocalEwave 
		endif
		if (V_FitError!=0)	//there was error in fitting
			RemoveFromGraph $("fit_"+NameOfWave(CursorAWave))
			beep
			Abort "Fitting error, check starting parameters and fitting limits" 
		endif
		Wave W_sigma
		TagText = "Fitted Guinier  "+FittingFunctionDescription+" \r G = "+num2str(W_coef[0])+"\r Rg = "+num2str(W_coef[1])
		if (FitUseErrors && WaveExists(ErrorWave))
			TagText+="\r chi-square = "+num2str(V_chisq)
		endif
		Tag/C/W=GeneralGraph/N=$(TagName)/L=2 $NameOfWave(CursorAWave), ((pcsr(A) + pcsr(B))/2),TagText	
		
		FittingParam1=W_coef[0] 	//G
		FittingParam2=W_coef[1]	//Rg

	endif	


	//rename fit wave and modify their appearance...
	Wave/Z  FitWave= $(("fit_"+NameOfWave(CursorAWave))[0,30])
	Wave/Z  FitXWave= $(("fitX_"+NameOfWave(CursorAWave))[0,30])
	
	if (WaveExists(FitWave))
		Rename FitWave, $(FitWaveName)	
	endif
	if (WaveExists(FitXWave))
		Rename FitXWave, $(FitXWaveName)	
	endif
	ModifyGraph/Z lstyle(IR1P_FitWave0)=5,rgb(IR1P_FitWave0)=(0,15872,65280), lsize(IR1P_FitWave0)=3
	ModifyGraph/Z lstyle(IR1P_FitWave1)=7,rgb(IR1P_FitWave1)=(0,65280,33024), lsize(IR1P_FitWave1)=3
	ModifyGraph/Z lstyle(IR1P_FitWave2)=9,rgb(IR1P_FitWave2)=(65280,0,52224), lsize(IR1P_FitWave2)=3
	ModifyGraph/Z lstyle(IR1P_FitWave3)=1,rgb(IR1P_FitWave3)=(65280,65280,0), lsize(IR1P_FitWave3)=3
	ModifyGraph/Z lstyle(IR1P_FitWave4)=14,rgb(IR1P_FitWave4)=(0,52224,0), lsize(IR1P_FitWave4)=3
	ModifyGraph/Z lstyle(IR1P_FitWave5)=12,rgb(IR1P_FitWave5)=(65280,0,0), lsize(IR1P_FitWave5)=3
	ModifyGraph/Z lstyle(IR1P_FitWave6)=2,rgb(IR1P_FitWave6)=(16384,28160,65280), lsize(IR1P_FitWave6)=3
	ModifyGraph/Z lstyle(IR1P_FitWave7)=11,rgb(IR1P_FitWave7)=(65280,0,52224), lsize(IR1P_FitWave7)=3	
	setDataFolder oldDf
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function/T IR1P_FindErrorWaveForCursor()

	//find the error wave if exists
	SVAR ListOfDataWaveNames= root:Packages:GeneralplottingTool:ListOfDataWaveNames
	if (strlen(CsrWave(A))==0 && strlen(CsrWave(B))==0)
		return ""
	endif
	string PathToIntWave=GetWavesDataFolder(CsrWaveRef(A, "GeneralGraph"), 2 )	
	string PathToErrorWave
	variable ii, iimax
	iimax = ItemsInList(ListOfDataWaveNames , ";")/3
	For(ii=0;ii<iimax;ii+=1)
		if (cmpstr(StringByKey("IntWave"+num2str(ii), ListOfDataWaveNames , "=" ,";"),PathToIntWave)==0)
			PathToErrorWave = StringByKey("EWave"+num2str(ii), ListOfDataWaveNames , "=" ,";")
		endif
	endfor 
	return PathToErrorWave
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1P_RemoveTagsAndFits()


	string TagName= UniqueName("IR1P_TagName",14,0,"GeneralGraph")
	string FitWaveName= UniqueName("IR1P_FitWave",1,0)
	string tempTagname, tempFItWaveName, tempFItXWaveName
	variable lastTag, lastFitWv
	if (numtype(str2num(TagName[strlen(TagName)-3,inf]))==0)
		lastTag=str2num(TagName[strlen(TagName)-3,inf])
	elseif(numtype(str2num(TagName[strlen(TagName)-2,inf]))==0)
		lastTag=str2num(TagName[strlen(TagName)-2,inf])
	elseif(numtype(str2num(TagName[strlen(TagName)-1,inf]))==0)
		lastTag=str2num(TagName[strlen(TagName)-1,inf])
	endif
	lastTag = lastTag -1

	if (numtype(str2num(FitWaveName[strlen(FitWaveName)-3,inf]))==0)
		lastFitWv=str2num(FitWaveName[strlen(FitWaveName)-3,inf])
	elseif(numtype(str2num(FitWaveName[strlen(FitWaveName)-2,inf]))==0)
		lastFitWv=str2num(FitWaveName[strlen(FitWaveName)-2,inf])
	elseif(numtype(str2num(FitWaveName[strlen(FitWaveName)-1,inf]))==0)
		lastFitWv=str2num(FitWaveName[strlen(FitWaveName)-1,inf])
	endif
	lastFitWv = lastFitWv -1
	
	variable i
	For(i=0;i<=lastTag;i+=1)
		tempTagname = "IR1P_TagName" + num2str(i)
		Tag/W=GeneralGraph/N=$(tempTagname)	/K	
	endfor
	For(i=0;i<=lastFitWv;i+=1)
		tempFItWaveName = "IR1P_FitWave" + num2str(i)
		RemoveFromGraph /W=GeneralGraph /Z $tempFItWaveName
		Wave/Z KillMe=$tempFItWaveName
		KillWaves/Z KillMe
		tempFItXWaveName = "IR1P_FitWaveX" + num2str(i)
		Wave/Z KillMeX=$tempFItXWaveName
		KillWaves/Z KillMeX
	endfor
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//another of modify data panel macros
Window IR1P_ModifyDataPanel() 
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(63,128.75,375,490) as "IR1P_ModifyDataPanel"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,0,65280)
	DrawText 13,23,"Here you can modify the data in the graph"
	SetDrawEnv textrgb= (65280,0,0)
	DrawText 13,44,"This WILL CHANGE your data"
	SetDrawEnv textrgb= (65280,0,0)
	DrawText 13,101,"Make sure you understand possible sideffects"
	SetDrawEnv textrgb= (65280,0,0)
	DrawText 13,63,"Backup is saved with \"name\"+_bckup "
	SetDrawEnv textrgb= (65280,0,0)
	DrawText 13,82,"And if different, ploted data types are recreated "
	
	PopupMenu ModifyDataList,pos={10,110},size={178,20},proc=IR1P_PanelPopupControl,title="Data", help={"Select data to modify"}
	PopupMenu ModifyDataList,mode=1,value= IR1P_ListWavesInGraphListModify()

	SetVariable ModifyDataMultiplier pos={10,145},size={200,20},proc=IR1P_SetVarProc,title="Int Scaling factor", limits={1e-40,inf,0.1}
	SetVariable ModifyDataMultiplier value= root:Packages:GeneralplottingTool:ModifyDataMultiplier, format="%4.4e", help={"Scaling factor (multiplier) for Intensity"}		
	SetVariable ModifyDataBackground pos={10,170},size={200,20},proc=IR1P_SetVarProc,title="Int Subtract background", limits={-inf,inf,0.1}
	SetVariable ModifyDataBackground value= root:Packages:GeneralplottingTool:ModifyDataBackground, format="%4.4e", help={"Flat bacground to be subtracted from Intensity"}		
	SetVariable ModifyDataQshift pos={10,195},size={200,20},proc=IR1P_SetVarProc,title="Shift Q      ", limits={-inf,inf,0.1}
	SetVariable ModifyDataQshift value= root:Packages:GeneralplottingTool:ModifyDataQshift, format="%4.4e", help={"Shift (add to) Q "}		
	SetVariable ModifyDataErrorMult pos={10,220},size={200,20},proc=IR1P_SetVarProc,title="Multiply error bars by", limits={1e-40,inf,0.1}
	SetVariable ModifyDataErrorMult value= root:Packages:GeneralplottingTool:ModifyDataErrorMult, format="%4.4e", help={"Multiply errors by this number"}		

	Button RemoveSmallData pos={10,245}, size={120,20},font="Times New Roman",fSize=10, proc=IRP_ButtonProc3,title="Remove Q<Csr(A)", help={"Remove data with Q smaller than where cursor A (rounded) is"}
	Button RemoveLargeData pos={160,245}, size={120,20}, font="Times New Roman",fSize=10,proc=IRP_ButtonProc3,title="Remove Q>Csr(B)", help={"Remove data with Q smaller than where cursor A (rounded) is"}
	Button RemoveOneDataPnt pos={80,270}, size={120,20}, font="Times New Roman",fSize=10,proc=IRP_ButtonProc3,title="Remove point (Csr(A))", help={"Remove one data point using cursor A (rounded) is"}

	Button CancelModify pos={80,300}, size={100,20},font="Times New Roman",fSize=10, proc=IRP_ButtonProc3,title="Cancel", help={"Reset curent modifcation to the data to original"}
	Button RecoverBackup pos={80,330}, size={120,20},font="Times New Roman",fSize=10, proc=IRP_ButtonProc3,title="Recover backup", help={"Recover ORIGINAL data from backup"}
EndMacro
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Window IR1P_RemoveDataPanel() 
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(63,128.75,375,425.75) as "IR1P_RemoveDataPanel"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,0,65280)
	DrawText 5,23,"Remove the data from the graph"

	PopupMenu RemoveDataList,pos={10,40},size={178,20},proc=IR1P_PanelPopupControl,title="Data", help={"Select data to remove"}
	PopupMenu RemoveDataList,mode=1,value= IR1P_ListWavesInGraphList(), help={"Select data to remove from graph"}
	Button RemoveDataBtn,font="Times New Roman",fSize=10, size={100,20},pos={60,80}, proc=IR1P_InputPanelButtonProc1,title="Remove"
	Button RemoveDataBtn,font="Times New Roman",fSize=10, help={"Click here to remove the selected data set from the graph"}
EndMacro


 
Function IR1P_InputPanelButtonProc1(ctrlName) : ButtonControl
	String ctrlName

	if (cmpstr(ctrlName,"RemoveDataBtn")==0)
		//here we need to remove the data in the popup from lists...
		IR1P_RemoveDataFromList()
		IR1P_SynchronizeListAndVars()
		IR1P_UpdateGenGraph()
	endif

end

Function IR1P_RemoveDataFromList()

	SVAR ListOfDataFolderNames=root:Packages:GeneralplottingTool:ListOfDataFolderNames
	SVAR ListOfDataWaveNames=root:Packages:GeneralplottingTool:ListOfDataWaveNames
	SVAR ListOfDataOrgWvNames=root:Packages:GeneralplottingTool:ListOfDataOrgWvNames
	SVAR SelectedDataToRemove=root:Packages:GeneralplottingTool:SelectedDataToRemove
	
	variable i, j, imax
	i = 0
	j = 0
	string NewListOfDataFolderNames=""
	string NewListOfDataWaveNames=""
	string NewListOfDataOrgWvnames=""
	imax=ItemsInList(ListOfDataWaveNames , ";")/3
	For(i=0;i<imax;i+=1)
		if(cmpstr(StringByKey("IntWave"+num2str(i), ListOfDataWaveNames , "=", ";"), SelectedDataToRemove)!=0)
			NewListOfDataFolderNames+=StringFromList(i,ListOfDataFolderNames, ";")+";"
			NewListOfDataWaveNames=ReplaceStringByKey("IntWave"+num2str(j), NewListOfDataWaveNames, StringByKey("IntWave"+num2str(i), ListOfDataWavenames ,"=" ,";"),"=",";")
			NewListOfDataWaveNames=ReplaceStringByKey("QWave"+num2str(j), NewListOfDataWaveNames, StringByKey("QWave"+num2str(i), ListOfDataWavenames ,"=" ,";"),"=",";")
			NewListOfDataWaveNames=ReplaceStringByKey("EWave"+num2str(j), NewListOfDataWaveNames, StringByKey("EWave"+num2str(i), ListOfDataWavenames ,"=" ,";"),"=",";")
			NewListOfDataOrgWvNames=ReplaceStringByKey("IntWave"+num2str(j), NewListOfDataOrgWvNames, StringByKey("IntWave"+num2str(i), ListOfDataWavenames ,"=" ,";"),"=",";")
			NewListOfDataOrgWvNames=ReplaceStringByKey("QWave"+num2str(j), NewListOfDataOrgWvNames, StringByKey("QWave"+num2str(i), ListOfDataWavenames ,"=" ,";"),"=",";")
			NewListOfDataOrgWvNames=ReplaceStringByKey("EWave"+num2str(j), NewListOfDataOrgWvNames, StringByKey("EWave"+num2str(i), ListOfDataWavenames ,"=" ,";"),"=",";")
			j+=1
		endif
	endfor	
	ListOfDataFolderNames=NewListOfDataFolderNames
	ListOfDataWaveNames=NewListOfDataWavenames
	ListOfDataOrgWvNames=NewListOfDataOrgWvNames
	
	PopupMenu RemoveDataList,mode=1,value= IR1P_ListWavesInGraphList(), win =IR1P_RemoveDataPanel
	SVAR SelectedDataToRemove=root:Packages:GeneralplottingTool:SelectedDataToRemove
	SelectedDataToRemove=StringFromList(0,IR1P_ListWavesInGraphList())
end
 
Function/T IR1P_ListWavesInGraphList()

	SVAR ListOfDataWaveNames=root:Packages:GeneralplottingTool:ListOfDataWaveNames
	variable i, NumOfListedData
	string result="---;"
	NumOfListedData=ItemsInList(ListOfDataWaveNames , ";")/3		//this should return number of waves listed
	if (NumOfListedData>0)
		For(i=0;i<NumOfListedData;i+=1)
			result+=StringByKey("IntWave"+num2str(i), ListOfDataWaveNames , "=" , ";")+";"
		endfor
	else
		result="---"
	endif
	return result
end

Function/T IR1P_ListWavesInGraphListModify()

	SVAR ListOfDataWaveNames=root:Packages:GeneralplottingTool:ListOfDataOrgWvNames
	variable i, NumOfListedData
	string result="---;"
	NumOfListedData=ItemsInList(ListOfDataWaveNames , ";")/3		//this should return number of waves listed
	if (NumOfListedData>0)
		For(i=0;i<NumOfListedData;i+=1)
			result+=StringByKey("IntWave"+num2str(i), ListOfDataWaveNames , "=" , ";")+";"
		endfor
	else
		result="---"
	endif
	return result
end



//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//this creates panel for nit-picking users, dissatisfied with everything...

Function IR1P_ChangeGraphDetailsFn()
	//here we create new panel with some more controls...
	
	DoWindow IR1P_ChangeGraphDetailsPanel
	if(V_Flag)
		DoWindow/K IR1P_ChangeGraphDetailsPanel
	endif
	Execute ("IR1P_ChangeGraphDetailsPanel()")
	
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//and macro for this job...
Window IR1P_ChangeGraphDetailsPanel() 
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(63,128.75,375,455.75) as "IR1P_ChangeGraphDetailsPanel"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 14,textrgb= (0,0,65280)
	DrawText 5,23,"Here you can change details of graph formating"
	SetDrawEnv fsize= 14,textrgb= (0,0,65280)
	DrawText 5,23,"Here you can change details of graph formating"
	SetDrawEnv fsize= 14,textrgb= (0,0,65280)
	DrawText 14,44,"For details on terminology check Igor manual"
	SetDrawEnv fsize= 14,textrgb= (0,0,65280)
	DrawText 15,65,"These details should be saved in user styles"

	CheckBox GraphAxisStandoff pos={10,80},title="Axes standoff?", variable=root:Packages:GeneralplottingTool:GraphAxisStandoff
	CheckBox GraphAxisStandoff proc=IR1P_GenPlotCheckBox, help={"Standoff axes from start?"}	
	CheckBox GraphTicksIn pos={120,80},title="Ticks In?", variable=root:Packages:GeneralplottingTool:GraphTicksIn
	CheckBox GraphTicksIn proc=IR1P_GenPlotCheckBox, help={"Ticks in the graph pointing in?"}	
	SetVariable GraphAxisWidth pos={10,105},size={140,20},proc=IR1P_SetVarProc,title="Axis width:", limits={1,25,1}
	SetVariable GraphAxisWidth value= root:Packages:GeneralplottingTool:GraphAxisWidth, help={"Axis width selection."}		
	SetVariable GraphWindowWidth pos={10,125},size={140,20},proc=IR1P_SetVarProc,title="Graph width:", limits={100,1000,50}
	SetVariable GraphWindowWidth value= root:Packages:GeneralplottingTool:GraphWindowWidth, help={"Set the width of the graph."}		
	SetVariable GraphWindowHeight pos={10,145},size={140,20},proc=IR1P_SetVarProc,title="Graph height:", limits={100,1000,50}
	SetVariable GraphWindowHeight value= root:Packages:GeneralplottingTool:GraphWindowHeight, help={"Set the height of the graph."}		
	PopupMenu GraphLegendSize,pos={10,165},size={180,20},proc=IR1P_PanelPopupControl,title="Legend font size", help={"Select font size for legend to be used."}
	PopupMenu GraphLegendSize,mode=1,value= "06;08;10;12;14;16;18;20;22;24;", popvalue="10"
	PopupMenu GraphLegendPosition,pos={10,190},size={180,20},proc=IR1P_PanelPopupControl,title="Legend position", help={"Select position for legend in the graph."}
	PopupMenu GraphLegendPosition,mode=1,value= "Left Top;Right Top;Left Bottom;Right Bottom;Middle Center;Left Center;Right Center;Middle Top;Middle Bottom;", popvalue="---"
	CheckBox GraphLegendFrame pos={10,220},title="Legend frame?", variable=root:Packages:GeneralplottingTool:GraphLegendFrame
	CheckBox GraphLegendFrame proc=IR1P_GenPlotCheckBox, help={"Check to have frame around the legend?"}	
	CheckBox GraphLegendUseFolderNms pos={10,240},title="Use folders in Legend?", variable=root:Packages:GeneralplottingTool:GraphLegendUseFolderNms
	CheckBox GraphLegendUseFolderNms proc=IR1P_GenPlotCheckBox, help={"Use folder names in Legend?"}	
	CheckBox GraphLegendUseWaveNote pos={10,260},title="Use wave note in Legend?", variable=root:Packages:GeneralplottingTool:GraphLegendUseWaveNote
	CheckBox GraphLegendUseWaveNote proc=IR1P_GenPlotCheckBox, help={"Use text from wave notes in Legend?"}	
	CheckBox GraphLegendShortNms pos={10,280},title="Only last folder in Legend?", variable=root:Packages:GeneralplottingTool:GraphLegendShortNms
	CheckBox GraphLegendShortNms proc=IR1P_GenPlotCheckBox, help={"Check to have legend use only last folder name."}	

	CheckBox DisplayTimeAndDate pos={170,280},title="Date & time stamp?", variable=root:Packages:GeneralplottingTool:DisplayTimeAndDate
	CheckBox DisplayTimeAndDate proc=IR1P_GenPlotCheckBox, help={"Display date and time in the lower right corner"}	


	CheckBox GraphUseSymbolSet1 pos={10,300},title="Use closed symbols?", proc=IR1P_GenPlotCheckBox, variable=root:Packages:GeneralplottingTool:GraphUseSymbolSet1, help={"Check to have symbols to be set 1 (closed symbols)"}	
	CheckBox GraphUseSymbolSet2 pos={170,300},title="Use open symbols?", proc=IR1P_GenPlotCheckBox,variable=root:Packages:GeneralplottingTool:GraphUseSymbolSet2,  help={"Check to have symbols to be set 2 (open symbols)."}	
EndMacro
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//resets all intol fresh start
Function IR1P_ResetTool()
	//kill graph and reset the strings for new start

	DoWindow GeneralGraph
	if(V_Flag)
		Dowindow/K GeneralGraph
	endif
	
	SVAR ListOfDataFolderNames=root:Packages:GeneralplottingTool:ListOfDataFolderNames
	SVAR ListOfDataWaveNames=root:Packages:GeneralplottingTool:ListOfDataWaveNames
	SVAR ListOfDataFormating=root:Packages:GeneralplottingTool:ListOfDataFormating
	SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating
	SVAR ListOfDataOrgWvNames=root:Packages:GeneralplottingTool:ListOfDataOrgWvNames

	ListOfDataOrgWvNames=""
	ListOfDataFolderNames=""
	ListOfDataWaveNames=""
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//Checkbox procedure
Function IR1P_InputPanelCheckboxProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:GeneralplottingTool

	if (cmpstr(ctrlName,"UseIndra2Data")==0)
		//here we control the data structure checkbox
		NVAR UseIndra2Data=root:Packages:GeneralplottingTool:UseIndra2Data
		NVAR UseQRSData=root:Packages:GeneralplottingTool:UseQRSData
		NVAR UseResults=root:Packages:GeneralplottingTool:UseResults
//		UseIndra2Data=checked
		if (checked)
			UseQRSData=0
			UseResults=0
		endif
//		Checkbox UseIndra2Data, value=UseIndra2Data
//		Checkbox UseQRSData, value=UseQRSData
		SVAR Dtf=root:Packages:GeneralplottingTool:DataFolderName
		SVAR IntDf=root:Packages:GeneralplottingTool:IntensityWaveName
		SVAR QDf=root:Packages:GeneralplottingTool:QWaveName
		SVAR EDf=root:Packages:GeneralplottingTool:ErrorWaveName
			Dtf=" "
			IntDf=" "
			QDf=" "
			EDf=" "
			PopupMenu SelectDataFolder mode=1
			PopupMenu IntensityDataName   mode=1, value="---"
			PopupMenu QvecDataName    mode=1, value="---"
			PopupMenu ErrorDataName    mode=1, value="---"
	endif
	if (cmpstr(ctrlName,"UseQRSData")==0)
		//here we control the data structure checkbox
		NVAR UseQRSData=root:Packages:GeneralplottingTool:UseQRSData
		NVAR UseIndra2Data=root:Packages:GeneralplottingTool:UseIndra2Data
		NVAR UseResults=root:Packages:GeneralplottingTool:UseResults
//		UseQRSData=checked
		if (checked)
			UseIndra2Data=0
			UseResults=0
		endif
//		Checkbox UseIndra2Data, value=UseIndra2Data
//		Checkbox UseQRSData, value=UseQRSData
		SVAR Dtf=root:Packages:GeneralplottingTool:DataFolderName
		SVAR IntDf=root:Packages:GeneralplottingTool:IntensityWaveName
		SVAR QDf=root:Packages:GeneralplottingTool:QWaveName
		SVAR EDf=root:Packages:GeneralplottingTool:ErrorWaveName
			Dtf=" "
			IntDf=" "
			QDf=" "
			EDf=" "
			PopupMenu SelectDataFolder mode=1
			PopupMenu IntensityDataName   mode=1, value="---"
			PopupMenu QvecDataName    mode=1, value="---"
			PopupMenu ErrorDataName    mode=1, value="---"
	endif
	if (cmpstr(ctrlName,"UseResults")==0)
		//here we control the data structure checkbox
		NVAR UseQRSData=root:Packages:GeneralplottingTool:UseQRSData
		NVAR UseIndra2Data=root:Packages:GeneralplottingTool:UseIndra2Data
		NVAR UseResults=root:Packages:GeneralplottingTool:UseResults
//		UseQRSData=checked
		if (checked)
			UseIndra2Data=0
			UseQRSData=0
		endif
//		Checkbox UseIndra2Data, value=UseIndra2Data
//		Checkbox UseQRSData, value=UseQRSData
		SVAR Dtf=root:Packages:GeneralplottingTool:DataFolderName
		SVAR IntDf=root:Packages:GeneralplottingTool:IntensityWaveName
		SVAR QDf=root:Packages:GeneralplottingTool:QWaveName
		SVAR EDf=root:Packages:GeneralplottingTool:ErrorWaveName
			Dtf=" "
			IntDf=" "
			QDf=" "
			EDf=" "
			PopupMenu SelectDataFolder mode=1
			PopupMenu IntensityDataName   mode=1, value="---"
			PopupMenu QvecDataName    mode=1, value="---"
			PopupMenu ErrorDataName    mode=1, value="---"
	endif
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//popup procedure
Function IR1P_PanelPopupControl(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:GeneralplottingTool

	NVAR UseIndra2Data=root:Packages:GeneralplottingTool:UseIndra2Data
	NVAR UseQRSData=root:Packages:GeneralplottingTool:UseQRSdata
	NVAR UseResults=root:Packages:GeneralplottingTool:UseResults
	SVAR Dtf=root:Packages:GeneralplottingTool:DataFolderName

	if (cmpstr(ctrlName,"SelectDataFolder")==0)
		Dtf=popStr
		PopupMenu IntensityDataName mode=1
		PopupMenu QvecDataName mode=1
		PopupMenu ErrorDataName mode=1
		SVAR IntDf=root:Packages:GeneralplottingTool:IntensityWaveName
		SVAR QDf=root:Packages:GeneralplottingTool:QWaveName
		SVAR EDf=root:Packages:GeneralplottingTool:ErrorWaveName
		if (UseIndra2Data)
			IntDf=stringFromList(0,IR1_ListIndraWavesForPopups("DSM_Int","GeneralplottingTool",1,1))
			QDf=stringFromList(0,IR1_ListIndraWavesForPopups("DSM_Qvec","GeneralplottingTool",1,1))
			EDf=stringFromList(0,IR1_ListIndraWavesForPopups("DSM_Error","GeneralplottingTool",1,1))
			PopupMenu IntensityDataName value=IR1_ListIndraWavesForPopups("DSM_Int","GeneralplottingTool",1,1)
			PopupMenu QvecDataName value=IR1_ListIndraWavesForPopups("DSM_Qvec","GeneralplottingTool",1,1)
			PopupMenu ErrorDataName value=IR1_ListIndraWavesForPopups("DSM_Error","GeneralplottingTool",1,1)

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
			PopupMenu IntensityDataName  value="---;"+IR1P_ListOfWaves("Yaxis")
			PopupMenu QvecDataName  value="---;"+IR1P_ListOfWaves("Xaxis")
			PopupMenu ErrorDataName  value="---;"+IR1P_ListOfWaves("Error")
		endif
		if(UseResults)
			IntDf=""
			QDf=""
			EDf=""
			PopupMenu IntensityDataName  value="---;"+IR1P_ListOfWaves("Yaxis")
			PopupMenu QvecDataName  value="---;"+IR1P_ListOfWaves("Xaxis")
			PopupMenu ErrorDataName  value="---;"+IR1P_ListOfWaves("Error")
		endif
		if(!UseQRSdata && !UseIndra2Data && !UseResults)
			IntDf=""
			QDf=""
			EDf=""
			PopupMenu IntensityDataName  value="---;"+IR1P_ListOfWaves("Yaxis")
			PopupMenu QvecDataName  value="---;"+IR1P_ListOfWaves("Xaxis")
			PopupMenu ErrorDataName  value="---;"+IR1P_ListOfWaves("Error")
		endif
		if (cmpstr(popStr,"---")==0)
			IntDf=""
			QDf=""
			EDf=""
			PopupMenu IntensityDataName  value="---"
			PopupMenu QvecDataName  value="---"
			PopupMenu ErrorDataName  value="---"
		endif
	endif
	
		SVAR IntDf=root:Packages:GeneralplottingTool:IntensityWaveName
		SVAR QDf=root:Packages:GeneralplottingTool:QWaveName
		SVAR EDf=root:Packages:GeneralplottingTool:ErrorWaveName
		NVAR UseQRSData=root:Packages:GeneralplottingTool:UseQRSdata

	if (cmpstr(ctrlName,"IntensityDataName")==0)
		if (cmpstr(popStr,"---")!=0)
			IntDf=popStr
			if (UseQRSData && strlen(QDf)==0 && strlen(EDf)==0)
				QDf="q"+popStr[1,inf]
				EDf="s"+popStr[1,inf]
				Execute ("PopupMenu QvecDataName mode=1, value=root:Packages:GeneralplottingTool:QWaveName+\";---;\"+IR1P_ListOfWaves(\"Xaxis\")")
				Wave/Z IsThereError=$(Dtf+possiblyquotename(EDf))
				if(WaveExists(IsThereError))
					Execute ("PopupMenu ErrorDataName mode=1, value=root:Packages:GeneralplottingTool:ErrorWaveName+\";---;\"+IR1P_ListOfWaves(\"Error\")")
				else
					EDf=""
				endif
			elseif(UseIndra2Data)
				QDf=ReplaceString("Int", popStr, "Qvec")
				EDf=ReplaceString("Int", popStr, "Error")
				//Execute ("PopupMenu QvecDataName mode=1, value=root:Packages:GeneralplottingTool:QWaveName+\";---;\"+IR1P_ListOfWaves(\"Xaxis\")")
				//Execute ("PopupMenu ErrorDataName mode=1, value=root:Packages:GeneralplottingTool:ErrorWaveName+\";---;\"+IR1P_ListOfWaves(\"Error\")")
				Execute ("PopupMenu QvecDataName mode=1, value=root:Packages:GeneralplottingTool:QWaveName+\";---;\"+IR1_ListIndraWavesForPopups(\"DSM_Qvec\",\"GeneralplottingTool\",1,1)")
				Execute ("PopupMenu ErrorDataName mode=1, value=root:Packages:GeneralplottingTool:ErrorWaveName+\";---;\"+IR1_ListIndraWavesForPopups(\"DSM_Error\",\"GeneralplottingTool\",1,1)")
				//IR1_ListIndraWavesForPopups(WhichWave,WhereAreControls,IncludeSMR,OneOrTwo)
			elseif(UseResults)// && strlen(QDf)==0 && strlen(EDf)==0)
				QDf=IR1P_CheckRightResultsWvs(popStr)
				EDf=""
				Execute ("PopupMenu QvecDataName mode=1, value=root:Packages:GeneralplottingTool:QWaveName+\";---;\"+IR1P_ListOfWaves(\"Xaxis\")")
				Execute ("PopupMenu ErrorDataName mode=1, value=root:Packages:GeneralplottingTool:ErrorWaveName+\";---;\"+IR1P_ListOfWaves(\"Error\")")
			endif
		else
			IntDf=""
		endif
	endif

	if (cmpstr(ctrlName,"QvecDataName")==0)
		//here goes what needs to be done, when we select this popup...
		if (cmpstr(popStr,"---")!=0)
			QDf=popStr
			if (UseQRSData && strlen(IntDf)==0 && strlen(EDf)==0)
				IntDf="r"+popStr[1,inf]
				EDf="s"+popStr[1,inf]
				Execute ("PopupMenu IntensityDataName mode=1, value=root:Packages:GeneralplottingTool:IntensityWaveName+\";---;\"+IR1P_ListOfWaves(\"Yaxis\")")
				Wave/Z IsThereError=$(Dtf+possiblyquotename(EDf))
				if(WaveExists(IsThereError))
					Execute ("PopupMenu ErrorDataName mode=1, value=root:Packages:GeneralplottingTool:ErrorWaveName+\";---;\"+IR1P_ListOfWaves(\"Error\")")
				else
					EDf=""
				endif
			elseif(UseIndra2Data)
				IntDf=ReplaceString("Qvec", popStr, "Int")
				EDf=ReplaceString("Qvec", popStr, "Error")
				Execute ("PopupMenu IntensityDataName mode=1, value=root:Packages:GeneralplottingTool:IntensityWaveName+\";---;\"+IR1_ListIndraWavesForPopups(\"DSM_Int\",\"GeneralplottingTool\",1,1)")
				Execute ("PopupMenu ErrorDataName mode=1, value=root:Packages:GeneralplottingTool:ErrorWaveName+\";---;\"+IR1_ListIndraWavesForPopups(\"DSM_Error\",\"GeneralplottingTool\",1,1)")
			elseif(UseResults)// && strlen(QDf)==0 && strlen(EDf)==0)
				IntDf=IR1P_CheckRightResultsWvs(popStr)
				EDf=""
				Execute ("PopupMenu IntensityDataName mode=1, value=root:Packages:GeneralplottingTool:IntensityWaveName+\";---;\"+IR1P_ListOfWaves(\"Yaxis\")")
				Execute ("PopupMenu ErrorDataName mode=1, value=root:Packages:GeneralplottingTool:ErrorWaveName+\";---;\"+IR1P_ListOfWaves(\"Error\")")
			endif
		else
			QDf=""
		endif
	endif
	
	if (cmpstr(ctrlName,"ErrorDataName")==0)
		//here goes what needs to be done, when we select this popup...
		if (cmpstr(popStr,"---")!=0)
			EDf=popStr
			if (UseQRSData && strlen(IntDf)==0 && strlen(QDf)==0)
				IntDf="r"+popStr[1,inf]
				QDf="q"+popStr[1,inf]
				Execute ("PopupMenu IntensityDataName mode=1, value=root:Packages:GeneralplottingTool:IntensityWaveName+\";---;\"+IR1P_ListOfWaves(\"Yaxis\")")
				Execute ("PopupMenu QvecDataName mode=1, value=root:Packages:GeneralplottingTool:QWaveName+\";---;\"+IR1P_ListOfWaves(\"Xaxis\")")
			elseif(UseIndra2Data)
				IntDf=ReplaceString("Error", popStr, "Int")
				QDf=ReplaceString("Error", popStr, "Qvec")
				Execute ("PopupMenu IntensityDataName mode=1, value=root:Packages:GeneralplottingTool:IntensityWaveName+\";---;\"+IR1_ListIndraWavesForPopups(\"DSM_Int\",\"GeneralplottingTool\",1,1)")
				Execute ("PopupMenu QvecDataName mode=1, value=root:Packages:GeneralplottingTool:QvecDataName+\";---;\"+IR1_ListIndraWavesForPopups(\"DSM_Qvec\",\"GeneralplottingTool\",1,1)")
			endif
		else
			EDf=""		
		endif
	endif
	
	if (cmpstr(ctrlName,"GraphType")==0)
		//here goes what needs to be done, when we select this popup...
		//reformat the graph and make sure the right data exist and are in the graph.
		IR1P_ApplySelectedStyle(popStr)
	endif
	if (cmpstr(ctrlName,"XAxisDataType")==0)
		//here goes what needs to be done, when we select this popup...
		//reformat the graph and make sure the right data exist and are in the graph.
		SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating	//this contains data formating
		ListOfGraphFormating=ReplaceStringByKey("DataX", ListOfGraphFormating, popstr,"=")
		popupMenu GraphType, mode=1
		IR1P_UpdateAxisName("X",popstr)
		IR1P_UpdateGenGraph()
	endif
	if (cmpstr(ctrlName,"YAxisDataType")==0)
		//here goes what needs to be done, when we select this popup...
		//reformat the graph and make sure the right data exist and are in the graph.
		SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating	//this contains data formating
		ListOfGraphFormating=ReplaceStringByKey("DataY", ListOfGraphFormating, popstr,"=")
		ListOfGraphFormating=ReplaceStringByKey("DataE", ListOfGraphFormating, popstr,"=")
		popupMenu GraphType, mode=1
		IR1P_UpdateAxisName("Y",popstr)
		IR1P_UpdateGenGraph()
	endif
	if (cmpstr(ctrlName,"RemoveDataList")==0)
		//here goes what needs to be done, when we select this popup...
		SVAR SelectedDataToRemove=root:Packages:GeneralplottingTool:SelectedDataToRemove
		SelectedDataToRemove=popStr
	endif
	if (cmpstr(ctrlName,"ModifyDataList")==0)
		//here goes what needs to be done, when we select this popup...
		SVAR SelectedDataToModify=root:Packages:GeneralplottingTool:SelectedDataToModify
		SelectedDataToModify=popStr
		IR1P_CopyModifyData()
	endif
	if (cmpstr(ctrlName,"GraphLegendSize")==0)
		//here goes what needs to be done, when we select this popup...
		NVAR GraphLegendSize=root:Packages:GeneralplottingTool:GraphlegendSize
		GraphlegendSize=str2num(popStr)
		SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating	//this contains data formating
		ListOfGraphFormating=ReplaceStringByKey("Graph legend size", ListOfGraphFormating, popstr,"=")
		IR1P_UpdateGenGraph()
	endif
	if (cmpstr(ctrlName,"GraphLegendPosition")==0)
		//here goes what needs to be done, when we select this popup...
		SVAR GraphLegendPosition=root:Packages:GeneralplottingTool:GraphlegendPosition
		string PosShortcut
		if (cmpstr(popStr,"Left Top")==0)
			PosShortcut="LT"
		elseif (cmpstr(popStr,"Right Top")==0)
			PosShortcut="RT"
		elseif (cmpstr(popStr,"Left Bottom")==0)
			PosShortcut="LB"
		elseif (cmpstr(popStr,"Right Bottom")==0)
			PosShortcut="RB"
		elseif (cmpstr(popStr,"Middle Center")==0)
			PosShortcut="MC"
		elseif (cmpstr(popStr,"Left Center")==0)
			PosShortcut="LC"
		elseif (cmpstr(popStr,"Right Center")==0)
			PosShortcut="RC"
		elseif (cmpstr(popStr,"Middle Top")==0)
			PosShortcut="MT"
		elseif (cmpstr(popStr,"Middle Bottom")==0)
			PosShortcut="MB"
		endif
		//Left Top;Right Top;Left Bottom;Right Bottom;Middle Center;Left Center;Righ Center;Middle Top;Middle Bottom;
		GraphlegendPosition=PosShortcut
		SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating	//this contains data formating
		ListOfGraphFormating=ReplaceStringByKey("Graph legend Position", ListOfGraphFormating, PosShortcut,"=")
		IR1P_UpdateGenGraph()
	endif
	
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function/T IR1P_CheckRightResultsWvs(KnownWv)
	string KnownWv
	
	string result=""
	if(stringmatch(KnownWv,"UnifiedFitQvector_*"))
		result="UnifiedFitIntensity_"+KnownWv[18,inf]
	endif
	if(stringmatch(KnownWv,"UnifiedFitIntensity_*"))
		result="UnifiedFitQvector_"+KnownWv[20,inf]
	endif

	if(stringmatch(KnownWv,"SizesFitIntensity_*"))
		result="SizesFitQvector_"+KnownWv[18,inf]
	endif
	if(stringmatch(KnownWv,"SizesFitQvector_*"))
		result="SizesFitIntensity_"+KnownWv[16,inf]
	endif

	if(stringmatch(KnownWv,"SizesDistDiameter_*"))
		result="SizesVolumeDistribution_"+KnownWv[18,inf]
	endif
	if(stringmatch(KnownWv,"SizesVolumeDistribution_*"))
		result="SizesDistDiameter_"+KnownWv[24,inf]
	endif
	if(stringmatch(KnownWv,"SizesNumberDistribution_*"))
		result="SizesDistDiameter_"+KnownWv[24,inf]
	endif

	if(stringmatch(KnownWv,"ModelingIntensity_*"))
		result="ModelingQvector_"+KnownWv[18,inf]
	endif
	if(stringmatch(KnownWv,"ModelingQvector_*"))
		result="ModelingIntensity_"+KnownWv[16,inf]
	endif

	if(stringmatch(KnownWv,"ModelingDiameters_*"))
		result="ModelingVolumeDistribution_"+KnownWv[18,inf]
	endif
	if(stringmatch(KnownWv,"ModelingVolumeDistribution_*"))
		result="ModelingDiameters_"+KnownWv[27,inf]
	endif
	if(stringmatch(KnownWv,"ModelingNumberDistribution_*"))
		result="ModelingDiameters_"+KnownWv[27,inf]
	endif

	if(stringmatch(KnownWv,"FractFitIntensity_*"))
		result="FractFitQvector_"+KnownWv[18,inf]
	endif
	if(stringmatch(KnownWv,"FractFitQvector_*"))
		result="FractFitIntensity_"+KnownWv[16,inf]
	endif


	return result
end



Function IR1P_UpdateAxisName(which,WhatTypeSelected)
	string which,WhatTypeSelected
	

	SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating	//this contains data formating
	SVAR GraphXAxisName=root:Packages:GeneralplottingTool:GraphXAxisName
	SVAR GraphYAxisName=root:Packages:GeneralplottingTool:GraphYAxisName
	string NewLabel
	
	if (cmpstr(which,"X")==0)
		if(cmpstr(WhatTypeSelected,"X")==0)
			NewLabel="q [A\S-1\M]"
		elseif(cmpstr(WhatTypeSelected,"X^2")==0)
			NewLabel="q\S2\M [A\S-2\M]"
		elseif(cmpstr(WhatTypeSelected,"X^3")==0)
			NewLabel="q\S3\M [A\S-3\M]"
		elseif(cmpstr(WhatTypeSelected,"X^4")==0)
			NewLabel="q\S4\M [A\S-4\M]"
		else
			NewLabel=""
		endif
		
		ListOfGraphFormating=ReplaceStringByKey("Label bottom", ListOfGraphFormating, NewLabel,"=")
		GraphXAxisName=NewLabel
			
	elseif (cmpstr(which,"Y")==0)

		if(cmpstr(WhatTypeSelected,"Y")==0)
			NewLabel="Intensity [cm\S-1\M]"
		elseif(cmpstr(WhatTypeSelected,"Y^2")==0)
			NewLabel="Intensity\S2\M [cm\S-2\M]"
		elseif(cmpstr(WhatTypeSelected,"Y^3")==0)
			NewLabel="Intensity\S3\M [cm\S-3\M]"
		elseif(cmpstr(WhatTypeSelected,"Y^4")==0)
			NewLabel="Intensity\S4\M [cm\S-4\M]"
		elseif(cmpstr(WhatTypeSelected,"1/Y")==0)
			NewLabel="Intensity\S-1\M [cm]"
		elseif(cmpstr(WhatTypeSelected,"sqrt(1/Y)")==0)
			NewLabel="sqrt(Intensity\S-1\M) [cm\S-0.5\M]"
		elseif(cmpstr(WhatTypeSelected,"ln(Y*X^2)")==0)
			NewLabel="ln(Intensity * q\S2\M)"
		elseif(cmpstr(WhatTypeSelected,"ln(Y)")==0)
			NewLabel="ln(Intensity)"
		elseif(cmpstr(WhatTypeSelected,"ln(Y*X)")==0)
			NewLabel="ln(Intensity * q)"
		elseif(cmpstr(WhatTypeSelected,"Y*X^2")==0)
			NewLabel="Intensity * q\S2\M [cm\S-1\M * A\S-2\M]"
		elseif(cmpstr(WhatTypeSelected,"Y*X^4")==0)
			NewLabel="Intensity * q\S4\M [cm\S-1\M * A\S-4\M]"
		else
			NewLabel=""
		endif
		
		
		ListOfGraphFormating=ReplaceStringByKey("Label left", ListOfGraphFormating, NewLabel,"=")
		GraphYAxisName=NewLabel
		
	endif
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**************************************************************************************************
//		Initialize procedure, as usually
//**************************************************************************************************

Function IR1P_InitializeGenGraph()			//initialize general plotting tool.

	string oldDf=GetDataFolder(1)
	string ListOfVariables
	string ListOfStrings
	variable i
	//First the ones needed in SAS_Modeling for compatibility
		
//	if (!DataFolderExists("root:Packages:SAS_Modeling"))		//create folder
//		NewDataFolder/O root:Packages
//		NewDataFolder/O root:Packages:SAS_Modeling
//	endif
//	SetDataFolder root:Packages:SAS_Modeling					//go into the folder
//
//	//here define the lists of variables and strings needed, separate names by ;...
//
//	//and here we create them
//	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
//		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
//	endfor		
//								
//	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
//		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
//	endfor	
//	//These were needed in SAS_Modeling folder


	//And these are needed in GeneralplottingTool folder
	if (!DataFolderExists("root:Packages:GeneralplottingTool"))		//create folder
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:GeneralplottingTool
	endif

	SetDataFolder root:Packages:GeneralplottingTool					//go into the folder

//	//here define the lists of variables and strings needed, separate names by ;...
	ListOfStrings="ListOfDataFolderNames;ListOfDataWaveNames;ListOfGraphFormating;ListOfDataOrgWvNames;ListOfDataFormating;SelectedDataToModify;"
	ListOfStrings+="GraphXAxisName;GraphYAxisName;SelectedDataToRemove;GraphLegendPosition;ModifyIntName;ModifyQname;ModifyErrName;"
	ListOfStrings+="ListOfRemovedPoints;FittingSelectedFitFunction;FittingFunctionDescription;"
	ListOfStrings+="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;"

	ListOfVariables="UseIndra2Data;UseQRSdata;UseResults;DisplayTimeAndDate;"
	ListOfVariables+="GraphLogX;GraphLogY;GraphErrors;GraphXMajorGrid;GraphXMinorGrid;GraphYMajorGrid;GraphYMinorGrid;"
	ListOfVariables+="GraphLegend;GraphUseColors;GraphUseSymbols;GraphXMirrorAxis;GraphYMirrorAxis;GraphLineWidth;"
	ListOfVariables+="GraphUseSymbolSet1;GraphUseSymbolSet2;GraphLegendUseWaveNote;"
	ListOfVariables+="GraphLegendUseFolderNms;GraphLegendShortNms;GraphLeftAxisAuto;GraphLeftAxisMin;GraphLeftAxisMax;"
	ListOfVariables+="GraphBottomAxisAuto;GraphBottomAxisMin;GraphBottomAxisMax;GraphAxisStandoff;"
	ListOfVariables+="GraphUseLines;GraphSymbolSize;GraphVarySymbols;GraphVaryLines;GraphAxisWidth;"
	ListOfVariables+="GraphWindowWidth;GraphWindowHeight;GraphTicksIn;GraphLegendSize;GraphLegendFrame;"
	ListOfVariables+="ModifyDataBackground;ModifyDataMultiplier;ModifyDataQshift;ModifyDataErrorMult;"
	ListOfVariables+="TrimPointLargeQ;TrimPointSmallQ;FittingParam1;FittingParam2;FittingParam3;FittingParam4;FittingParam5;"
	ListOfVariables+="FitUseErrors;Xoffset;Yoffset;"
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
								
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	

	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		SVAR testS=$(StringFromList(i,ListOfStrings))
		testS=""
	endfor	
	SVAR ListOfGraphFormating
	SVAR FittingSelectedFitFunction
	FittingSelectedFitFunction = "---"
	
	ListOfVariables="GraphErrors;GraphXMajorGrid;GraphXMinorGrid;GraphYMajorGrid;GraphYMinorGrid;"
	ListOfVariables+="GraphLegend;GraphUseColors;GraphUseSymbols;GraphXMirrorAxis;GraphYMirrorAxis;GraphLineWidth;"
	ListOfVariables+="GraphLegendUseFolderNms;GraphAxisStandoff;GraphLegendShortNms;"
	ListOfVariables+= "ModifyDataBackground;ModifyDataQshift;"
	ListOfVariables+="GraphUseSymbolSet2;"
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		NVAR testV=$(StringFromList(i,ListOfVariables))
		testV=0
	endfor		
	ListOfVariables="GraphLogX;GraphLogY;GraphUseLines;GraphSymbolSize;DisplayTimeAndDate;"
	ListOfVariables+="GraphLeftAxisAuto;GraphLeftAxisMin;GraphLeftAxisMax;"
	ListOfVariables+="GraphBottomAxisAuto;GraphBottomAxisMin;GraphBottomAxisMax;GraphAxisWidth;"
	ListOfVariables+="ModifyDataMultiplier;ModifyDataErrorMult;"
	ListOfVariables+="FitUseErrors;"
	ListOfVariables+="GraphUseSymbolSet1;"
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		NVAR testV=$(StringFromList(i,ListOfVariables))
		testV=1
	endfor
	NVAR GraphWindowWidth
	NVAR GraphLegendSize
	NVAR GraphWindowHeight		
	if(GraphWindowWidth==0)
		GraphWindowWidth=300
		GraphWindowHeight=300
		GraphLegendSize=10
	endif
	SVAR GraphLegendPosition
	NVAR GraphLegendFrame
	if (strlen(GraphLegendPosition)<2)
		GraphLegendPosition="MC"
		GraphLegendFrame=1
	endif	
	NVAR GraphLineWidth
	GraphLineWidth=1
	
	if (!DataFolderExists("root:Packages:plottingToolsStyles"))		//create folder
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:plottingToolsStyles
	endif
	SetDataFolder root:Packages:plottingToolsStyles					//go into the folder

	String/g LogLog
	SVAR LogLog
	LogLog="log(bottom)=1;log(left)=1;grid(left)=2;grid(bottom)=2;mirror(bottom)=1;mirror(left)=1;Label bottom=q [A\S-1\M];Label left=Intensity [cm\S-1\M];"
	LogLog+="DataY=Y;DataX=X;DataE=Y;Axis left auto=1;Axis bottom auto=1;Axis left min=0;Axis left max=0;Axis bottom min=0;Axis bottom max=0;"
	LogLog+="standoff=0;Graph use Lines=1;Graph use Symbols=1;msize=1;lsize=1;axThick=2;Graph Window Width=450;Graph Window Height=400;"
	LogLog+="mode[0]=4;mode[1]=4;mode[2]=4;mode[3]=4;mode[4]=4;Graph use Colors=1;mode[5]=4;mode[6]=4;mode[7]=4;mode[8]=4;mode[9]=4;Graph vary Lines=1;"
	LogLog+="Graph Legend Size=10;Graph Legend Position=LB;Graph Legend Frame=1;Graph Vary Symbols=1;"
	LogLog+="marker[0]=19;marker[1]=16;marker[2]=17;marker[3]=23;marker[4]=26;marker[5]=29;marker[6]=18;marker[7]=15;marker[8]=14;"
	LogLog+="rgb[0]=(65280,0,0);rgb[1]=(0,0,65280);rgb[2]=(0,65280,0);rgb[3]=(32680,32680,0);rgb[4]=(0,32680,32680);rgb[5]=(32680,0,32680);"
	LogLog+="rgb[6]=(32680,32680,32680);rgb[7]=(65280,32680,32680);rgb[8]=(32680,32680,65280);rgb[9]=(65280,0,0);rgb[10]=(0,0,65280);"
	LogLog+="rgb[11]=(32680,32680,65280);rgb[12]=(0,65280,0);rgb[13]=(32680,32680,0);rgb[14]=(0,32680,32680);rgb[15]=(32680,0,32680);"
	LogLog+="rgb[16]=(32680,32680,32680);rgb[17]=(65280,32680,32680);rgb[18]=(32680,32680,65280);"
	LogLog+="lStyle[0]=0;lStyle[1]=1;lStyle[2]=2;lStyle[3]=3;lStyle[4]=4;lStyle[5]=5;lStyle[6]=6;lStyle[7]=7;lStyle[8]=8;"
	LogLog+="Legend=2;GraphLegendShortNms=1;tick=0;GraphUseSymbolSet1=1;GraphUseSymbolSet2=0;DisplayTimeAndDate=1;Xoffset=0;Yoffset=0;"
	
	string/g VolumeDistribution
	SVAR VolumeDistribution
	VolumeDistribution="log(bottom)=0;log(left)=0;grid(left)=2;grid(bottom)=2;mirror(bottom)=1;mirror(left)=1;Label bottom=Diameter [A];Label left=Volume distribution (f(D));DataY=Y;"
	VolumeDistribution+="DataX=X;DataE=Y;Axis left auto=1;Axis bottom auto=1;Axis left min=1.37359350144832e-06;Axis left max=0.0110271775364775;Axis bottom min=10;"
	VolumeDistribution+="Axis bottom max=5000;standoff=0;Graph use Lines=1;Graph use Symbols=1;msize=1;lsize=1;axThick=2;Graph Window Width=450;Graph Window Height=400;"
	VolumeDistribution+="mode[0]=4;mode[1]=4;mode[2]=4;mode[3]=4;mode[4]=4;Graph use Colors=1;mode[5]=4;mode[6]=4;mode[7]=4;mode[8]=4;mode[9]=4;Graph vary Lines=1;"
	VolumeDistribution+="Graph Legend Size=10;Graph Legend Position=LB;Graph Legend Frame=1;Graph Vary Symbols=1;marker[0]=8;marker[1]=17;marker[2]=5;marker[3]=12;marker[4]=16;"
	VolumeDistribution+="marker[5]=29;marker[6]=18;marker[7]=15;marker[8]=14;rgb[0]=(65280,0,0);rgb[1]=(0,0,65280);rgb[2]=(0,65280,0);rgb[3]=(32680,32680,0);rgb[4]=(0,32680,32680);"
	VolumeDistribution+="rgb[5]=(32680,0,32680);rgb[6]=(32680,32680,32680);rgb[7]=(65280,32680,32680);rgb[8]=(32680,32680,65280);rgb[9]=(65280,0,0);rgb[10]=(0,0,65280);"
	VolumeDistribution+="rgb[11]=(32680,32680,65280);rgb[12]=(0,65280,0);rgb[13]=(32680,32680,0);rgb[14]=(0,32680,32680);rgb[15]=(32680,0,32680);"
	VolumeDistribution+="rgb[16]=(32680,32680,32680);rgb[17]=(65280,32680,32680);rgb[18]=(32680,32680,65280);lStyle[0]=0;lStyle[1]=1;lStyle[2]=2;lStyle[3]=3;lStyle[4]=4;lStyle[5]=5;lStyle[6]=6;lStyle[7]=7;lStyle[8]=8;"	
	VolumeDistribution+="Legend=2;GraphLegendShortNms=0;tick=0;GraphUseSymbolSet1=1;GraphUseSymbolSet2=0;DisplayTimeAndDate=1;Xoffset=0;Yoffset=0;"

	string/g PDDF
	SVAR PDDF
	PDDF="log(bottom)=0;log(left)=0;grid(left)=2;grid(bottom)=2;mirror(bottom)=1;mirror(left)=1;Label bottom=Distance [A];Label left=p(r);DataY=Y;DataX=X;DataE=Y;Axis left auto=1;Axis bottom auto=1;"
	PDDF+="Axis left min=-7.75876036780322e-07;Axis left max=7.4190884970254e-05;Axis bottom min=0;Axis bottom max=300;standoff=0;Graph use Lines=1;Graph use Symbols=1;msize=1;lsize=1;axThick=2;"
	PDDF+="Graph Window Width=450;Graph Window Height=400;mode[0]=4;mode[1]=4;mode[2]=4;mode[3]=4;mode[4]=4;Graph use Colors=1;mode[5]=4;mode[6]=4;mode[7]=4;mode[8]=4;mode[9]=4;Graph vary Lines=1;"
	PDDF+="Graph Legend Size=10;Graph Legend Position=LB;Graph Legend Frame=1;Graph Vary Symbols=1;marker[0]=8;marker[1]=17;marker[2]=5;marker[3]=12;marker[4]=16;marker[5]=29;marker[6]=18;marker[7]=15;"
	PDDF+="marker[8]=14;rgb[0]=(65280,0,0);rgb[1]=(0,0,65280);rgb[2]=(0,65280,0);rgb[3]=(32680,32680,0);rgb[4]=(0,32680,32680);rgb[5]=(32680,0,32680);rgb[6]=(32680,32680,32680);rgb[7]=(65280,32680,32680);"
	PDDF+="rgb[8]=(32680,32680,65280);rgb[9]=(65280,0,0);rgb[10]=(0,0,65280);rgb[11]=(32680,32680,65280);rgb[12]=(0,65280,0);rgb[13]=(32680,32680,0);rgb[14]=(0,32680,32680);rgb[15]=(32680,0,32680);"
	PDDF+="rgb[16]=(32680,32680,32680);rgb[17]=(65280,32680,32680);rgb[18]=(32680,32680,65280);lStyle[0]=0;lStyle[1]=1;lStyle[2]=2;lStyle[3]=3;lStyle[4]=4;lStyle[5]=5;lStyle[6]=6;lStyle[7]=7;lStyle[8]=8;"
	PDDF+="Legend=2;GraphLegendShortNms=1;tick=0;GraphUseSymbolSet1=1;GraphUseSymbolSet2=0;DisplayTimeAndDate=1;Xoffset=0;Yoffset=0;"


	string/g Porod
	SVAR Porod
	Porod= "log(bottom)=0;log(left)=0;grid(left)=2;grid(bottom)=2;mirror(bottom)=1;mirror(left)=1;Label bottom=q\S4\M [A\S-4\M];Label left=Intensity * q\S4\M [cm\S-1\M * A\S-4\M];DataY=Y*X^4;DataX=X^4;"
	Porod+= "DataE=Y*X^4;Axis left auto=1;Axis bottom auto=1;Axis left min=6.05481104002939e-09;Axis left max=0.0596273984790896;Axis bottom min=1.43458344252644e-16;Axis bottom max=0.0256131682633957;standoff=0;"
  	Porod+= "Graph use Lines=1;Graph use Symbols=1;msize=1;lsize=1;axThick=2;Graph Window Width=450;Graph Window Height=400;mode[0]=4;mode[1]=4;mode[2]=4;mode[3]=4;mode[4]=4;Graph use Colors=1;mode[5]=4;mode[6]=4;"
  	Porod+= "mode[7]=4;mode[8]=4;mode[9]=4;Graph vary Lines=1;Graph Legend Size=10;Graph Legend Position=LB;Graph Legend Frame=1;Graph Vary Symbols=1;marker[0]=8;marker[1]=17;marker[2]=5;marker[3]=12;marker[4]=16;"
	Porod+= "marker[5]=29;marker[6]=18;marker[7]=15;marker[8]=14;rgb[0]=(65280,0,0);rgb[1]=(0,0,65280);rgb[2]=(0,65280,0);rgb[3]=(32680,32680,0);rgb[4]=(0,32680,32680);rgb[5]=(32680,0,32680);"
  	Porod+= "rgb[6]=(32680,32680,32680);rgb[7]=(65280,32680,32680);rgb[8]=(32680,32680,65280);rgb[9]=(65280,0,0);rgb[10]=(0,0,65280);rgb[11]=(32680,32680,65280);rgb[12]=(0,65280,0);rgb[13]=(32680,32680,0);"
	Porod+= "rgb[14]=(0,32680,32680);rgb[15]=(32680,0,32680);rgb[16]=(32680,32680,32680);rgb[17]=(65280,32680,32680);rgb[18]=(32680,32680,65280);lStyle[0]=0;lStyle[1]=1;lStyle[2]=2;lStyle[3]=3;lStyle[4]=4;"
 	Porod+= " lStyle[5]=5;lStyle[6]=6;lStyle[7]=7;lStyle[8]=8;Legend=2;GraphLegendShortNms=1;tick=0;GraphUseSymbolSet1=1;GraphUseSymbolSet2=0;DisplayTimeAndDate=1;Xoffset=0;Yoffset=0;"

	string/g Debye_Bueche
	SVAR Debye_Bueche
	Debye_Bueche= "log(bottom)=0;log(left)=0;grid(left)=2;grid(bottom)=2;mirror(bottom)=1;mirror(left)=1;Label bottom=q\S2\M [A\S-2\M];Label left=sqrt(Intensity\S-1\M) [cm\S-0.5\M];DataY=sqrt(1/Y);DataX=X^2;DataE=sqrt(1/Y);"
	Debye_Bueche+= "Axis left auto=1;Axis bottom auto=1;Axis left min=0.000153926221956687;Axis left max=0.655403445936652;Axis bottom min=0.000109441353003394;Axis bottom max=0.400051428609657;standoff=0;"
  	Debye_Bueche+= "Graph use Lines=1;Graph use Symbols=1;msize=1;lsize=1;axThick=2;Graph Window Width=450;Graph Window Height=400;mode[0]=4;mode[1]=4;mode[2]=4;mode[3]=4;mode[4]=4;Graph use Colors=1;mode[5]=4;mode[6]=4;"
  	Debye_Bueche+= "mode[7]=4;mode[8]=4;mode[9]=4;Graph vary Lines=1;Graph Legend Size=10;Graph Legend Position=LB;Graph Legend Frame=1;Graph Vary Symbols=1;marker[0]=8;marker[1]=17;marker[2]=5;marker[3]=12;marker[4]=16;"
	Debye_Bueche+= "marker[5]=29;marker[6]=18;marker[7]=15;marker[8]=14;rgb[0]=(65280,0,0);rgb[1]=(0,0,65280);rgb[2]=(0,65280,0);rgb[3]=(32680,32680,0);rgb[4]=(0,32680,32680);rgb[5]=(32680,0,32680);"
  	Debye_Bueche+= "rgb[6]=(32680,32680,32680);rgb[7]=(65280,32680,32680);rgb[8]=(32680,32680,65280);rgb[9]=(65280,0,0);rgb[10]=(0,0,65280);rgb[11]=(32680,32680,65280);rgb[12]=(0,65280,0);rgb[13]=(32680,32680,0);"
	Debye_Bueche+= "rgb[14]=(0,32680,32680);rgb[15]=(32680,0,32680);rgb[16]=(32680,32680,32680);rgb[17]=(65280,32680,32680);rgb[18]=(32680,32680,65280);lStyle[0]=0;lStyle[1]=1;lStyle[2]=2;lStyle[3]=3;lStyle[4]=4;"
  	Debye_Bueche+= "lStyle[5]=5;lStyle[6]=6;lStyle[7]=7;lStyle[8]=8;Legend=2;GraphLegendShortNms=1;tick=0;GraphUseSymbolSet1=1;GraphUseSymbolSet2=0;DisplayTimeAndDate=1;Xoffset=0;Yoffset=0;"

	string/g Guinier
	SVAR Guinier
	Guinier="log(bottom)=0;log(left)=1;grid(left)=2;grid(bottom)=2;mirror(bottom)=1;mirror(left)=1;Label bottom=q\S2\M [A\S-2\M];Label left=Intensity [cm\S-1\M];DataY=Y;DataX=X^2;DataE=Y;Axis left auto=1;"
	Guinier+="Axis bottom auto=1;Axis left min=5.41957359517844;Axis left max=1.78135123888276e+15;Axis bottom min=0.000109441353003394;Axis bottom max=0.400051428609657;standoff=0;Graph use Lines=1;"
  	Guinier+="Graph use Symbols=1;msize=1;lsize=1;axThick=2;Graph Window Width=450;Graph Window Height=400;mode[0]=4;mode[1]=4;mode[2]=4;mode[3]=4;mode[4]=4;Graph use Colors=1;mode[5]=4;mode[6]=4;mode[7]=4;"
	Guinier+="mode[8]=4;mode[9]=4;Graph vary Lines=1;Graph Legend Size=10;Graph Legend Position=LB;Graph Legend Frame=1;Graph Vary Symbols=1;marker[0]=8;marker[1]=17;marker[2]=5;marker[3]=12;marker[4]=16;"
  	Guinier+="marker[5]=29;marker[6]=18;marker[7]=15;marker[8]=14;rgb[0]=(65280,0,0);rgb[1]=(0,0,65280);rgb[2]=(0,65280,0);rgb[3]=(32680,32680,0);rgb[4]=(0,32680,32680);rgb[5]=(32680,0,32680);"
	Guinier+="rgb[6]=(32680,32680,32680);rgb[7]=(65280,32680,32680);rgb[8]=(32680,32680,65280);rgb[9]=(65280,0,0);rgb[10]=(0,0,65280);rgb[11]=(32680,32680,65280);rgb[12]=(0,65280,0);rgb[13]=(32680,32680,0);"
  	Guinier+="rgb[14]=(0,32680,32680);rgb[15]=(32680,0,32680);rgb[16]=(32680,32680,32680);rgb[17]=(65280,32680,32680);rgb[18]=(32680,32680,65280);lStyle[0]=0;lStyle[1]=1;lStyle[2]=2;lStyle[3]=3;lStyle[4]=4;"
	Guinier+="lStyle[5]=5;lStyle[6]=6;lStyle[7]=7;lStyle[8]=8;Legend=2;GraphLegendShortNms=1;tick=0;GraphUseSymbolSet1=1;GraphUseSymbolSet2=0;DisplayTimeAndDate=1;Xoffset=0;Yoffset=0;"

	string/g Kratky
	SVAR Kratky
 	Kratky="log(bottom)=0;log(left)=0;grid(left)=2;grid(bottom)=2;mirror(bottom)=1;mirror(left)=1;Label bottom=q [A\S-1\M];Label left=Intensity * q\S2\M [cm\S-1\M * A\S-2\M];DataY=Y*X^2;DataX=X;DataE=Y*X^2;"
 	Kratky+="Axis left auto=1;Axis bottom auto=1;Axis left min=0.260499250084115;Axis left max=5.25105256354487;Axis bottom min=0.000109441353003394;Axis bottom max=0.400051428609657;standoff=0;Graph use Lines=1;"
   	Kratky+="Graph use Symbols=1;msize=1;lsize=1;axThick=2;Graph Window Width=450;Graph Window Height=400;mode[0]=4;mode[1]=4;mode[2]=4;mode[3]=4;mode[4]=4;Graph use Colors=1;mode[5]=4;mode[6]=4;mode[7]=4;"
 	Kratky+="mode[8]=4;mode[9]=4;Graph vary Lines=1;Graph Legend Size=10;Graph Legend Position=LB;Graph Legend Frame=1;Graph Vary Symbols=1;marker[0]=8;marker[1]=17;marker[2]=5;marker[3]=12;marker[4]=16;"
   	Kratky+="marker[5]=29;marker[6]=18;marker[7]=15;marker[8]=14;rgb[0]=(65280,0,0);rgb[1]=(0,0,65280);rgb[2]=(0,65280,0);rgb[3]=(32680,32680,0);rgb[4]=(0,32680,32680);rgb[5]=(32680,0,32680);"
 	Kratky+="rgb[6]=(32680,32680,32680);rgb[7]=(65280,32680,32680);rgb[8]=(32680,32680,65280);rgb[9]=(65280,0,0);rgb[10]=(0,0,65280);rgb[11]=(32680,32680,65280);rgb[12]=(0,65280,0);rgb[13]=(32680,32680,0);"
   	Kratky+="rgb[14]=(0,32680,32680);rgb[15]=(32680,0,32680);rgb[16]=(32680,32680,32680);rgb[17]=(65280,32680,32680);rgb[18]=(32680,32680,65280);lStyle[0]=0;lStyle[1]=1;lStyle[2]=2;lStyle[3]=3;lStyle[4]=4;"
 	Kratky+="lStyle[5]=5;lStyle[6]=6;lStyle[7]=7;lStyle[8]=8;Legend=2;GraphLegendShortNms=1;tick=0;GraphUseSymbolSet1=1;GraphUseSymbolSet2=0;DisplayTimeAndDate=1;Xoffset=0;Yoffset=0;"


	string/g Zimm
	SVAR Zimm
	Zimm="log(bottom)=0;log(left)=0;grid(left)=2;grid(bottom)=2;mirror(bottom)=1;mirror(left)=1;Label bottom=q\S2\M [A\S-2\M];Label left=Intensity\S-1\M [cm];DataY=1/Y;DataX=X^2;DataE=1/Y;Axis left auto=1;"
	Zimm+="Axis bottom auto=1;Axis left min=0.0266669243574142;Axis left max=6.07712268829346;Axis bottom min=0.000145193684147671;Axis bottom max=1.37456679344177;standoff=0;Graph use Lines=1;"
  	Zimm+="Graph use Symbols=1;msize=1;lsize=1;axThick=2;Graph Window Width=450;Graph Window Height=400;mode[0]=4;mode[1]=4;mode[2]=4;mode[3]=4;mode[4]=4;Graph use Colors=1;mode[5]=4;mode[6]=4;mode[7]=4;"
	Zimm+="mode[8]=4;mode[9]=4;Graph vary Lines=1;Graph Legend Size=10;Graph Legend Position=LB;Graph Legend Frame=1;Graph Vary Symbols=1;marker[0]=8;marker[1]=17;marker[2]=5;marker[3]=12;marker[4]=16;"
  	Zimm+="marker[5]=29;marker[6]=18;marker[7]=15;marker[8]=14;rgb[0]=(65280,0,0);rgb[1]=(0,0,65280);rgb[2]=(0,65280,0);rgb[3]=(32680,32680,0);rgb[4]=(0,32680,32680);rgb[5]=(32680,0,32680);"
	Zimm+="rgb[6]=(32680,32680,32680);rgb[7]=(65280,32680,32680);rgb[8]=(32680,32680,65280);rgb[9]=(65280,0,0);rgb[10]=(0,0,65280);rgb[11]=(32680,32680,65280);rgb[12]=(0,65280,0);rgb[13]=(32680,32680,0);"
  	Zimm+="rgb[14]=(0,32680,32680);rgb[15]=(32680,0,32680);rgb[16]=(32680,32680,32680);rgb[17]=(65280,32680,32680);rgb[18]=(32680,32680,65280);lStyle[0]=0;lStyle[1]=1;lStyle[2]=2;lStyle[3]=3;lStyle[4]=4;"
	Zimm+="lStyle[5]=5;lStyle[6]=6;lStyle[7]=7;lStyle[8]=8;Legend=2;GraphLegendShortNms=1;tick=0;GraphUseSymbolSet1=1;GraphUseSymbolSet2=0;DisplayTimeAndDate=1;Xoffset=0;Yoffset=0;"

	
	ListOfGraphFormating="log(bottom)=1;log(left)=1;grid(left)=2;grid(bottom)=2;mirror(bottom)=1;mirror(left)=1;Label bottom=q [A\S-1\M];Label left=Intensity [cm\S-1\M];"
	ListOfGraphFormating+="DataY=Y;DataX=X;DataE=Y;Axis left auto=1;Axis bottom auto=1;Axis left min=0;Axis left max=0;Axis bottom min=0;Axis bottom max=0;"
	ListOfGraphFormating+="standoff=0;Graph use Lines=1;Graph use Symbols=1;msize=1;lsize=1;axThick=2;Graph Window Width=450;Graph Window Height=400;"
	ListOfGraphFormating+="mode[0]=4;mode[1]=4;mode[2]=4;mode[3]=4;mode[4]=4;Graph use Colors=1;mode[5]=4;mode[6]=4;mode[7]=4;mode[8]=4;mode[9]=4;Graph vary Lines=1;"
	ListOfGraphFormating+="Graph Legend Size=10;Graph Legend Position=LB;Graph Legend Frame=1;Graph Vary Symbols=1;"
	ListOfGraphFormating+="marker[0]=19;marker[1]=16;marker[2]=17;marker[3]=23;marker[4]=26;marker[5]=29;marker[6]=18;marker[7]=15;marker[8]=14;"
	ListOfGraphFormating+="rgb[0]=(65280,0,0);rgb[1]=(0,0,65280);rgb[2]=(0,65280,0);rgb[3]=(32680,32680,0);rgb[4]=(0,32680,32680);rgb[5]=(32680,0,32680);"
	ListOfGraphFormating+="rgb[6]=(32680,32680,32680);rgb[7]=(65280,32680,32680);rgb[8]=(32680,32680,65280);rgb[9]=(65280,0,0);rgb[10]=(0,0,65280);"
	ListOfGraphFormating+="rgb[11]=(32680,32680,65280);rgb[12]=(0,65280,0);rgb[13]=(32680,32680,0);rgb[14]=(0,32680,32680);rgb[15]=(32680,0,32680);"
	ListOfGraphFormating+="rgb[16]=(32680,32680,32680);rgb[17]=(65280,32680,32680);rgb[18]=(32680,32680,65280);"
	ListOfGraphFormating+="lStyle[0]=0;lStyle[1]=1;lStyle[2]=2;lStyle[3]=3;lStyle[4]=4;lStyle[5]=5;lStyle[6]=6;lStyle[7]=7;lStyle[8]=8;"
	ListOfGraphFormating+="Legend=2;GraphLegendShortNms=1;tick=0;GraphUseSymbolSet1=1;GraphUseSymbolSet2=0;DisplayTimeAndDate=1;Xoffset=0;Yoffset=0;"
	 
	SetDataFolder root:Packages:GeneralplottingTool					//go into the folder

end

//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************


Function PorodInLogLog(w,Q) : FitFunc
	Wave w
	Variable Q

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(Q) = PorodConst * Q^4 + Background
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ Q
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = PorodConst
	//CurveFitDialog/ w[1] = Background

	return w[0] * Q^(-4) + w[1]
End


//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************

Function IRP_ErrorsForPowers(Value, Error, Power)
		variable Value, Error, Power
		
		variable errorResult
		errorResult =  ( (Value+Error)^Power - (Value)^Power )^2  + ( (Value-Error)^Power - (Value)^Power )^2
		errorResult = 0.5 *errorResult
		errorResult = sqrt(errorResult)
		return errorResult
end

//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************

Function IRP_ErrorsForLn(Value, Error)
		variable Value, Error
		
		variable errorResult, tempCalc
		errorResult =  (ln(1+Error/Value))^2
		tempCalc = Error/Value
		if (tempCalc<0.9)
			errorResult +=  (ln(1-Error/Value))^2
		else
			errorResult +=  1+(ln(1+Error/Value))^2
		endif
		errorResult = 0.5 *errorResult
		errorResult = sqrt(errorResult)
		return errorResult
end


//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************

Function IRP_ErrorsForInverse(Value, Error)
		variable Value, Error
		
		variable errorResult
		errorResult =  ( 1/(Value+Error) - 1/(Value) )^2  + ( 1/(Value-Error) - 1/(Value))^2
		errorResult = 0.5 *errorResult
		errorResult = sqrt(errorResult)
		return errorResult
end



//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************

Function IRP_ErrorsForSQRT(Value, Error)
		variable Value, Error
		
		variable errorResult
		errorResult =  (sqrt(Value+Error) - sqrt(Value) )^2  
		if ((Value-Error)>0)
			errorResult +=  ( sqrt(Value-Error) - sqrt(Value))^2
		else
			errorResult +=  + ( sqrt(Value+Error) - sqrt(Value))^2
		endif

		errorResult = 0.5 *errorResult
		errorResult = sqrt(errorResult)
		return errorResult
end



//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************



Function IR1P_StoreGraphs()

	DoWIndow IR1P_StoreGraphsCtrlPnl
	if(V_Flag)
		DoWindow/K IR1P_StoreGraphsCtrlPnl
	endif

	IR1P_StoreGraphInit()
	Execute("IR1P_StoreGraphsCtrlPnl()")
end

//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************

Function IR1P_StoreGraphInit()

	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages
	NewDataFolder/O root:Packages:StoredGraphs
	setDataFolder root:Packages:GeneralplottingTool
	
	string ListOfVariables, ListOfStrings
	ListOfVariables=""

	ListOfStrings="NewStoredGraphName;"
	
	variable i
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	
	Make/O/N=0/T ListOfStoredGraphs
	
	IR1P_UpdateListOfStoredGraphs()
	
	setDataFolder OldDf
end

//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************

Function IR1P_UpdateListOfStoredGraphs()
	
	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:GeneralplottingTool
	Wave/T ListOfStoredGraphs=root:Packages:GeneralplottingTool:ListOfStoredGraphs
	
	string TempList=IN2G_CreateListOfItemsInFolder("root:Packages:StoredGraphs", 8)
	variable i
	redimension/N=(ItemsInList(TempList)) ListOfStoredGraphs
	For(i=0;i<ItemsInList(TempList);i+=1)
		ListOfStoredGraphs[i]=StringFromList(i,TempList)
	endfor
	setDataFolder OldDf		
end

//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************

Function IR1P_StoreGraphsButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	if(cmpstr(ctrlName,"SaveTiffFile")==0)
		DoWindow/F GeneralGraph
		SavePICT/T="TIFF"/B=288
	endif
	if(cmpstr(ctrlName,"SaveJPGFile")==0)
		DoWindow/F GeneralGraph
		SavePICT/T="JPEG"/B=288
	endif
	if(cmpstr(ctrlName,"SaveIgorRecMacro")==0)
		//here we need to create tiff file of the current generalGraph and save it
		DoWindow GeneralGraph
		if(V_Flag)
			DoWindow/F GeneralGraph
			Execute/P ("DoIgorMenu \"Control\", \"Window control\"")
		else
			abort
		endif
	endif

	if(cmpstr(ctrlName,"SaveIrena1Macro")==0)
		IR1P_SaveIrena1Macro()
	endif
	if(cmpstr(ctrlName,"LoadIrena1Macro")==0)
		IR1P_LoadIrena1Macro()
	endif
	if(cmpstr(ctrlName,"DeleteIrena1Macro")==0)
		IR1P_KillIrena1Macro()
	endif
End

//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
Function IR1P_KillIrena1Macro()

	string OldDf=GetDataFolder(1)
	Wave/T ListOfStoredGraphs=root:Packages:GeneralplottingTool:ListOfStoredGraphs	
	string StringToLoad=""
	variable i
	ControlInfo /W=IR1P_StoreGraphsCtrlPnl ListOfGraphs
	StringToLoad = ListOfStoredGraphs[V_Value]
	setDataFolder root:Packages:StoredGraphs
	SVAR tempStr=$(StringToLoad)
	KillStrings tempStr 
	setDataFOlder oldDf
	IR1P_UpdateListOfStoredGraphs()
end

//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************

Function IR1P_LoadIrena1Macro()

	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:GeneralplottingTool
	SVAR ListOfDataFolderNames=root:Packages:GeneralplottingTool:ListOfDataFolderNames
	SVAR ListOfDataWaveNames=root:Packages:GeneralplottingTool:ListOfDataWaveNames
	SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating
	SVAR ListOfDataOrgWvNames=root:Packages:GeneralplottingTool:ListOfDataOrgWvNames
	SVAR ListOfDataFormating=root:Packages:GeneralplottingTool:ListOfDataFormating
	Wave/T ListOfStoredGraphs=root:Packages:GeneralplottingTool:ListOfStoredGraphs
	
	string StringToLoad=""
	variable i
	ControlInfo /W=IR1P_StoreGraphsCtrlPnl ListOfGraphs
	StringToLoad = ListOfStoredGraphs[V_Value]
	setDataFolder root:Packages:StoredGraphs
	SVAR tempStr=$(StringToLoad)
	ListOfDataFolderNames=StringByKey("ListOfDataFolderNames", tempStr , "@"  , ">>>")
	ListOfDataWaveNames=StringByKey("ListOfDataWaveNames", tempStr , "@"  , ">>>")
	ListOfGraphFormating=StringByKey("ListOfGraphFormating", tempStr , "@"  , ">>>")
	ListOfDataOrgWvNames=StringByKey("ListOfDataOrgWvNames", tempStr , "@"  , ">>>")
	ListOfDataFormating=StringByKey("ListOfDataFormating", tempStr , "@"  , ">>>")
	
	setDataFOlder oldDf
	IR1P_SynchronizeListAndVars()
	IR1P_CreateGraph()
end

//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************

Function IR1P_SaveIrena1Macro()

	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:GeneralplottingTool
	SVAR ListOfDataFolderNames=root:Packages:GeneralplottingTool:ListOfDataFolderNames
	SVAR ListOfDataWaveNames=root:Packages:GeneralplottingTool:ListOfDataWaveNames
	SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating
	SVAR ListOfDataOrgWvNames=root:Packages:GeneralplottingTool:ListOfDataOrgWvNames
	SVAR ListOfDataFormating=root:Packages:GeneralplottingTool:ListOfDataFormating
	SVAR NewStoredGraphName=root:Packages:GeneralplottingTool:NewStoredGraphName
	if(strlen(NewStoredGraphName)<=0)
		Abort "Input name first, please"
	endif

	string StringToSave=""
	StringToSave+="ListOfDataFolderNames@"+ListOfDataFolderNames+">>>"
	StringToSave+="ListOfDataWaveNames@"+ListOfDataWaveNames+">>>"
	StringToSave+="ListOfGraphFormating@"+ListOfGraphFormating+">>>"
	StringToSave+="ListOfDataOrgWvNames@"+ListOfDataOrgWvNames+">>>"
	StringToSave+="ListOfDataFormating@"+ListOfDataFormating+">>>"
	setDataFolder root:Packages:StoredGraphs
	string/g $(NewStoredGraphName)
	SVAR tempStr=$(NewStoredGraphName)
	tempStr = StringToSave
	setDataFOlder oldDf	
	IR1P_UpdateListOfStoredGraphs()
end

//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************

Function IR1P_StoreGraphSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	if(cmpstr("NewGraphMacroName",ctrlName)==0)
		SVAR NewStoredGraphName=root:Packages:GeneralplottingTool:NewStoredGraphName
		string OldDf=GetDataFolder(1)
		setDataFolder root:Packages:StoredGraphs
		NewStoredGraphName=cleanupName(NewStoredGraphName,0)
		if(CheckName(NewStoredGraphName, 4)!=0)
			NewStoredGraphName = UniqueName(NewStoredGraphName,4,0)
		endif
		setDataFOlder OldDf	
	endif
End

//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
Window IR1P_StoreGraphsCtrlPnl() 
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(99,127.25,458.25,550.25) as "IR1P_StoreGraphsCtrlPnl"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 18,fstyle= 3,textrgb= (0,0,65280)
	DrawText 60,25,"Save and store graphs"
	SetDrawEnv fstyle= 1,textrgb= (0,0,65280)
	DrawText 72,52,"To save graph to separate file:"
	SetDrawEnv fstyle= 1,textrgb= (0,0,65280)
	DrawText 68,99,"To save IGOR recreation macro:"
	SetDrawEnv fstyle= 1,textrgb= (0,0,65280)
	DrawText 63,153,"To save Irena Plotting tool graph:"
	SetDrawEnv fstyle= 1,textrgb= (0,0,65280)
	DrawText 61,226,"To load Irena Plotting tool graph:"
	Button SaveTiffFile,pos={8,56},size={150,20},font="Times New Roman",fSize=10,proc=IR1P_StoreGraphsButtonProc,title="Save tiff file", help={"Use this button to export TIFF file with 300 dpi resolution of current graph"}
	Button SaveJPGFile,pos={177,55},size={150,20},font="Times New Roman",fSize=10,proc=IR1P_StoreGraphsButtonProc,title="Save jpg file", help={"Use this button to export JPG file with 300 dpi resolution of current graph"}
	Button SaveIgorRecMacro,pos={44,109},size={220,20},font="Times New Roman",fSize=10,proc=IR1P_StoreGraphsButtonProc,title="Save Igor recreation macro", help={"Use this button to create Igor recreation macro"}
	Button SaveIrena1Macro,pos={116,181},size={220,20},font="Times New Roman",fSize=10,proc=IR1P_StoreGraphsButtonProc,title="Store Irena plotting tool graph", help={"Use this button to store Irena plotting tool recreation macro"}
	SetVariable NewGraphMacroName,pos={4,160},size={350,16},proc=IR1P_StoreGraphSetVarProc,title="Name for Saved Graph: ", help={"New Irena plotting tool macro name"}
	SetVariable NewGraphMacroName,value= root:Packages:GeneralplottingTool:NewStoredGraphName
	ListBox ListOfGraphs,pos={10,233},size={330,120}, mode=1
	ListBox ListOfGraphs,listWave=root:Packages:GeneralplottingTool:ListOfStoredGraphs, help={"Here are listed stored Irena plotting tool recreation macros"}
//	ListBox ListOfGraphs,selWave=root:Packages:GeneralplottingTool:ListOfStoredGraphsControl
	Button LoadIrena1Macro,pos={41,363},size={260,20},font="Times New Roman",fSize=10,proc=IR1P_StoreGraphsButtonProc,title="Load selected Plotting tool stored graph", help={"Use this button to load stored Irena plotting tool macros"}
	Button DeleteIrena1Macro,pos={40,393},size={260,20},font="Times New Roman",fSize=10,proc=IR1P_StoreGraphsButtonProc,title="Delete selected Plotting tool stored graph", help={"Use this button to load delete Irena plotting tool macros"}
EndMacro

//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************

