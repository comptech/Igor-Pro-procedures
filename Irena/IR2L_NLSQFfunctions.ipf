#pragma rtGlobals=1		// Use modern global access method.



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_LoadDataIntoSet(whichDataSet)
	variable whichDataSet
	
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF

		SVAR InputFoldrName=root:Packages:IR2L_NLSQF:DataFolderName
		SVAR InputIntName=root:Packages:IR2L_NLSQF:IntensityWaveName
		SVAR InputQName=root:Packages:IR2L_NLSQF:QWavename
		SVAR InputErrorName=root:Packages:IR2L_NLSQF:ErrorWaveName
		SVAR NewFldrName=$("root:Packages:IR2L_NLSQF:FolderName_set"+num2str(whichDataSet))
		SVAR NewIntName = $("root:Packages:IR2L_NLSQF:IntensityDataName_set"+num2str(whichDataSet))
		SVAR NewQName=$("root:Packages:IR2L_NLSQF:QvecDataName_set"+num2str(whichDataSet))
		SVAR NewErrorName=$("root:Packages:IR2L_NLSQF:ErrorDataName_set"+num2str(whichDataSet))
		NVAR SlitSmeared_set=$("root:Packages:IR2L_NLSQF:SlitSmeared_set"+num2str(whichDataSet))
		NVAR SlitLength_set=$("root:Packages:IR2L_NLSQF:SlitLength_set"+num2str(whichDataSet))
		NVAR UseIndra2Data=root:Packages:IR2L_NLSQF:UseIndra2Data
		NVAR GraphXMin = root:Packages:IR2L_NLSQF:GraphXMin
		NVAR GraphXMax = root:Packages:IR2L_NLSQF:GraphXMax
		NVAR GraphYMin = root:Packages:IR2L_NLSQF:GraphYMin
		NVAR GraphYMax = root:Packages:IR2L_NLSQF:GraphYMax
		SVAR UserDataSetName = $("root:Packages:IR2L_NLSQF:UserDataSetName_set"+num2str(whichDataSet))
		
	if(strlen(InputFoldrName)<4)
		abort
	endif
	if(!DataFolderExists(InputFoldrName))
		Abort "Bad input folder name"
	endif
	setDataFolder InputFoldrName
	wave/Z inputI=$(InputIntName)
	wave/Z inputQ=$(InputQName)
	wave/Z inputE=$(InputErrorName)

	if(UseIndra2Data)
		if(stringmatch(InputIntName, "*SMR*" ) && stringmatch(InputQName,"*SMR*") &&stringmatch(InputErrorName,"*SMR*")  )
			SlitSmeared_set=1
			string WvNote=note(inputI)
			SlitLength_set=NumberByKey("SlitLength", WvNote , "=" , ";")
		else
			SlitSmeared_set=0
			SlitLength_set=0
		endif
	endif
	
	if(!WaveExists(InputI) || !WaveExists(InputQ))
		abort "Input waves (at least one of them) do not exists)"
	endif
	if (numpnts(inputI) != numpnts(InputQ))
		abort "Number of point of input waves is different, cannot continue"
	endif
	if(WaveExists(inputE) &&  (numpnts(InputI) != numpnts(InputE)))
		abort "Number of point of input waves is different, cannot continue"
	endif
	
	NVAR UseUserErrors=$("root:Packages:IR2L_NLSQF:UseUserErrors_set"+num2str(whichDataSet))
	NVAR UseSQRTErrors=$("root:Packages:IR2L_NLSQF:UseSQRTErrors_set"+num2str(whichDataSet))
	NVAR UsePercentErrors=$("root:Packages:IR2L_NLSQF:UsePercentErrors_set"+num2str(whichDataSet))
	if(!WaveExists(inputE))
		UseUserErrors=0
		if(UseSQRTErrors+UsePercentErrors!=1)
			UseSQRTErrors=1
			UsePercentErrors=0
		endif
	else
		UseUserErrors=1
		UseSQRTErrors=0
		UsePercentErrors=0
	endif
	
	// set for user the name so it is meaningfull... Just guess...
	if(UseIndra2Data)	//FOLDERIS THE NAME
		UserDataSetName=GetDataFolder(0)
	else		//hope the name of wave is the right thing there... 
		UserDataSetName = InputIntName
	endif
	//recover old parameters, if user wants...
		IR2L_RecoverOldParameters()
	//end load
	setDataFolder root:Packages:IR2L_NLSQF
	
	NewFldrName = InputFoldrName
	NewIntName = InputIntName
	NewQName = InputQName
	NewErrorName = InputErrorName
	
	Duplicate/O inputI, $("Intensity_set"+num2str(whichDataSet))
	Duplicate/O inputQ, $("Q_set"+num2str(whichDataSet))
	if(UseUserErrors)		//handle special cases of errors not loaded in Igor
		Duplicate/O inputE, $("Error_set"+num2str(whichDataSet))		
	elseif(UseSQRTErrors)
		Duplicate/O inputI, $("Error_set"+num2str(whichDataSet))	
		Wave ErrorWv=$("Error_set"+num2str(whichDataSet))	
		Wave IntWv= $("Intensity_set"+num2str(whichDataSet))
		ErrorWv=sqrt(IntWv)
	else
		Duplicate/O inputI, $("Error_set"+num2str(whichDataSet))	
		Wave ErrorWv=$("Error_set"+num2str(whichDataSet))	
		Wave IntWv= $("Intensity_set"+num2str(whichDataSet))
		ErrorWv=0.01*(IntWv)
	endif
	Duplicate/O inputI, $("IntensityMask_set"+num2str(whichDataSet))
	Wave Mask = $("IntensityMask_set"+num2str(whichDataSet))
	Mask = 5

	NVAR Qmax_set=$("Qmax_set"+num2str(whichDataSet))
	Qmax_set = inputQ[numpnts(inputQ)-1]
	NVAR Qmin_set=$("Qmin_set"+num2str(whichDataSet))
	Qmin_set = inputQ[0]
	IR2L_setQMinMax(whichDataSet)
	
	if(UseIndra2Data && stringmatch(InputIntName, "*SMR*" ))
		SlitSmeared_set=1
	endif

	//set limits, if not set otherwise...
	if(GraphXMin==0 || GraphXMax==0 || GraphYMin==0 || GraphYMax==0)
		wavestats/Q inputI
		if(V_min<=0)
			DoAlert 0, "Note, minimum value on Intensity axis is less than 0. That will not work for log axis. Default selected. Please, change manually!!!"
			V_min = V_max/1e6
		endif 
		GraphYMin = V_min
		GraphYMax = V_max
		wavestats/Q  inputQ
		if(V_min<=0)
			DoAlert 0, "Note, minimum value on Q axis is less than 0. That will not work for log axis. Default selected. Please, change manually!!!"
			V_min=1e-4
		endif 
		GraphXMin = V_min
		GraphXMax = V_max
	endif
	
	IR2L_RecalculateIfSelected()
	
	setDataFolder OldDf

end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//
Function IR2L_RecoverOldParameters()
	
	variable DataExists=0,i
	string ListOfWaves=IN2G_CreateListOfItemsInFolder(GetDataFolder(1), 2)
	string tempString
	if (stringmatch(ListOfWaves, "*IntensityModelLSQF2*" ))
		string ListOfSolutions=""
		For(i=0;i<itemsInList(ListOfWaves);i+=1)
			if (stringmatch(stringFromList(i,ListOfWaves),"IntensityModelLSQF2*"))
				tempString=stringFromList(i,ListOfWaves)
				Wave tempwv=$(GetDataFolder(1)+tempString)
				tempString=stringByKey("UsersComment",note(tempwv),"=")
				ListOfSolutions+=stringFromList(i,ListOfWaves)+"*  "+tempString+";"
			endif
		endfor
		DataExists=1
		string ReturnSolution=""
		Prompt ReturnSolution, "Select solution to recover", popup,  ListOfSolutions+";Start fresh"
		DoPrompt "Previous solutions found, select one to recover", ReturnSolution
		if (V_Flag)
			abort
		endif
	endif

	if (DataExists==1 && cmpstr("Start fresh", ReturnSolution)!=0)
		ReturnSolution=ReturnSolution[0,strsearch(ReturnSolution, "*", 0 )-1]
		Wave/Z OldDistribution=$(GetDataFolder(1)+ReturnSolution)

		string OldNote=note(OldDistribution)
		string TempStr
		variable j
			for(j=0;j<ItemsInList(OldNote);j+=1)
				TempStr = StringFromList(j,OldNote,";")
				NVAR/Z TestVar=$("root:Packages:IR2L_NLSQF:"+StringFromList(0,StringFromList(j,OldNote,";"),"="))
				if (NVAR_Exists(testVar))
					TestVar = str2num(StringFromList(1,TempStr,"="))
				endif
				SVAR/Z TestStr=$("root:Packages:IR2L_NLSQF:"+StringFromList(0,StringFromList(j,OldNote,";"),"="))
				if (SVAR_Exists(testStr))
					TestStr = StringFromList(1,TempStr,"=")
				endif
			endfor
		return 1
		DoAlert 1, "unfinished, need to set the Panel controls - popups are likely stale" 
	else
		return 0
	endif
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_AutosetGraphAxis(autoset)
	variable autoset
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF

		NVAR GraphXMin = root:Packages:IR2L_NLSQF:GraphXMin
		NVAR GraphXMax = root:Packages:IR2L_NLSQF:GraphXMax
		NVAR GraphYMin = root:Packages:IR2L_NLSQF:GraphYMin
		NVAR GraphYMax = root:Packages:IR2L_NLSQF:GraphYMax

//		DoAlert 1, "Fifnish IR2L_AutosetGraphAxis() proc..."
		if(autoset)
			setAxis/W=LSQF_MainGraph/A
			Doupdate
		endif
		GetAxis/W=LSQF_MainGraph/Q left
		GraphYMin = V_min
		GraphYMax = V_max
		GetAxis/W=LSQF_MainGraph/Q bottom
		GraphXMin = V_min
		GraphXMax = V_max
	setDataFolder OldDf

end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function  IR2L_AppendDataIntoGraph(whichDataSet) //Adds user data into the graph for selected data set 
	variable whichDataSet
	
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF
	
	DoWindow LSQF_MainGraph
	if(V_Flag)
		DoWindow/F LSQF_MainGraph
	else
		Display /K=1/W=(313.5,38.75,858,374) as "LSQF2 main data window"
		Dowindow/C LSQF_MainGraph
		//Add command bar
		ControlBar /T/W=LSQF_MainGraph 50
		SetVariable GraphXMin, pos={20,3}, size={140,25}, variable= root:Packages:IR2L_NLSQF:GraphXMin, help={"Set minimum value for q axis"}, title="Min q = "
		SetVariable GraphXMin, limits={0,inf,0}, proc=IR2L_DataTabSetVarProc
		SetVariable GraphXMax, pos={20,25}, size={140,25}, variable= root:Packages:IR2L_NLSQF:GraphXMax, help={"Set maximum value for q axis"}, title="Max q = "
		SetVariable GraphXMax, limits={0,inf,0}, proc=IR2L_DataTabSetVarProc
		SetVariable GraphYMin, pos={180,3}, size={140,25}, variable= root:Packages:IR2L_NLSQF:GraphYMin, help={"Set minimum value for intensity axis"}, title="Min Int = "
		SetVariable GraphYMin, limits={0,inf,0}, proc=IR2L_DataTabSetVarProc
		SetVariable GraphYMax, pos={180,25}, size={140,25}, variable= root:Packages:IR2L_NLSQF:GraphYMax, help={"Set maximum value for intensity axis"}, title="Max Int = "
		SetVariable GraphYMax, limits={0,inf,0}, proc=IR2L_DataTabSetVarProc
		Button SetAxis, pos={350,5},size={80,16},font="Times New Roman",fSize=10,proc=IR2L_InputGraphButtonProc,title="Read Axis", help={"Read current axis range on to variables controlling the range"}
		Button AutoSetAxis, pos={350,25},size={80,16},font="Times New Roman",fSize=10,proc=IR2L_InputGraphButtonProc,title="Autoset Axis", help={"Set range on axis to display all data"}
		Checkbox DisplaySinglePopInt, proc =IR2L_GraphsCheckboxProc, variable = root:Packages:IR2L_NLSQF:DisplaySinglePopInt, pos={450,3},title="Display Ind. Pop. Ints.?", help={"Display in the graph intensitiesfor separate populations?"} 
	endif

	Wave/Z InputIntensity= $("Intensity_set"+num2str(whichDataSet))
	Wave/Z InputQ=$("Q_set"+num2str(whichDataSet))
	Wave/Z InputError= $("Error_set"+num2str(whichDataSet))
	NVAR UseTheData_set = $("UseTheData_set"+num2str(whichDataSet))
	if(!WaveExists(InputIntensity) || !WaveExists(InputQ) || !WaveExists(InputError))
		UseTheData_set=0
		DoAlert 0, "This data do not exists, add data first in to the tool"
	else
		Checkdisplayed/W=LSQF_MainGraph $("Intensity_set"+num2str(whichDataSet))
		if(V_Flag==0)
			AppendToGraph/W=LSQF_MainGraph InputIntensity vs InputQ 
			ErrorBars $("Intensity_set"+num2str(whichDataSet)) Y,wave=(InputError,InputError)
			ModifyGraph/Z/W=LSQF_MainGraph zmrkSize( $("Intensity_set"+num2str(whichDataSet)))={$("IntensityMask_set"+num2str(whichDataSet)),0,5,0.5,3}
		endif
	endif

	setDataFolder OldDf
End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************



Function IR2L_AppendOrRemoveLocalPopInts()


	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF

	DoWindow LSQF_MainGraph
	if(!V_Flag)
		return 1
	endif
	ControlInfo/W=LSQF2_MainPanel DistTabs
	variable WhichPopSet= V_Value+1

	NVAR MultipleInputData = root:Packages:IR2L_NLSQF:MultipleInputData
	variable WhichDataSet=1
	if(MultipleInputData)
		ControlInfo/W=LSQF2_MainPanel DataTabs
		WhichDataSet = V_Value+1
	endif
	NVAR UseTheDataSet = $("root:Packages:IR2L_NLSQF:UseTheData_Set"+num2str(WhichDataSet))
	NVAR UseThePop = $("root:Packages:IR2L_NLSQF:UseThePop_pop"+num2str(WhichPopSet))


	NVAR DisplaySinglePopInt = root:Packages:IR2L_NLSQF:DisplaySinglePopInt
	variable i,j
	for(i=0;i<=10;i+=1)
		for(j=0;j<=10;j+=1)
			RemoveFromGraph/Z/W=LSQF_MainGraph $("IntensityModel_set"+num2str(i)+"_pop"+num2str(j))
		endfor
	endfor

	if(UseTheDataSet && DisplaySinglePopInt&& UseThePop)
		Wave/Z Int = $("root:Packages:IR2L_NLSQF:IntensityModel_set"+num2str(whichDataSet)+"_pop"+num2str(whichPopSet))
		Wave/Z Qvec = $("root:Packages:IR2L_NLSQF:Qmodel_set"+num2str(whichDataSet))
		if(!WaveExists(Int) || !WaveExists(Qvec))
			return 1
		endif
		Checkdisplayed/W=LSQF_MainGraph $("IntensityModel_set"+num2str(whichDataSet)+"_pop"+num2str(whichPopSet))
		if(V_Flag==0)
			AppendToGraph/W=LSQF_MainGraph Int vs Qvec 
			ModifyGraph/W=LSQF_MainGraph  lstyle($("IntensityModel_set"+num2str(whichDataSet)+"_pop"+num2str(whichPopSet)))=8
			ModifyGraph/W=LSQF_MainGraph  rgb($("IntensityModel_set"+num2str(whichDataSet)+"_pop"+num2str(whichPopSet)))=(0,0,0)
		endif
	endif

	IR2L_FormatLegend()
	setDataFolder OldDf
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************



Function IR2L_GraphsCheckboxProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF
	
	ControlInfo/W=LSQF2_MainPanel PopTabs
	variable WhichPopSet= V_Value+1

	if (stringMatch(ctrlName,"DisplaySinglePopInt"))
		NVAR DisplaySinglePopInt = root:Packages:IR2L_NLSQF:DisplaySinglePopInt
		IR2L_AppendOrRemoveLocalPopInts()
	endif
	setDataFolder oldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function  IR2L_RemoveDataFromGraph(whichDataSet)
	variable whichDataSet
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF
	DoWindow LSQF_MainGraph
	if(V_Flag)
		DoWindow/F LSQF_MainGraph
		checkdisplayed /W=LSQF_MainGraph $("Intensity_set"+num2str(whichDataSet))
		if(V_Flag)
			RemoveFromGraph /W=LSQF_MainGraph /Z $("Intensity_set"+num2str(whichDataSet))
		endif
	endif	
	setDataFolder OldDf
End


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR2L_FormatInputGraph()

	NVAR GraphXMin = root:Packages:IR2L_NLSQF:GraphXMin
	NVAR GraphXMax = root:Packages:IR2L_NLSQF:GraphXMax
	NVAR GraphYMin = root:Packages:IR2L_NLSQF:GraphYMin
	NVAR GraphYMax = root:Packages:IR2L_NLSQF:GraphYMax
	DoWindow LSQF_MainGraph
	if(V_Flag)
		DoWindow/F LSQF_MainGraph
		ModifyGraph/Z/W=LSQF_MainGraph mode=3
		ModifyGraph/Z/W=LSQF_MainGraph marker=19
		ModifyGraph/Z/W=LSQF_MainGraph msize=2
		ModifyGraph/Z/W=LSQF_MainGraph grid=1
		ModifyGraph/Z/W=LSQF_MainGraph log=1
		ShowInfo/W=LSQF_MainGraph 
		ModifyGraph/Z/W=LSQF_MainGraph mirror=1
		Label/Z/W=LSQF_MainGraph left "Intensity [cm\\S-1\\M or arbitrary units]"
		Label/Z/W=LSQF_MainGraph bottom "Q [A\\S-1\\M]"
		SetAxis/Z left GraphYMin,GraphYMax
		SetAxis/Z bottom GraphXMin,GraphXMax
		
		SVAR rgbIntensity_set1=root:Packages:IR2L_NLSQF:rgbIntensity_set1
		SVAR rgbIntensity_set2=root:Packages:IR2L_NLSQF:rgbIntensity_set2
		SVAR rgbIntensity_set3=root:Packages:IR2L_NLSQF:rgbIntensity_set3
		SVAR rgbIntensity_set4=root:Packages:IR2L_NLSQF:rgbIntensity_set4
		SVAR rgbIntensity_set5=root:Packages:IR2L_NLSQF:rgbIntensity_set5
		SVAR rgbIntensity_set6=root:Packages:IR2L_NLSQF:rgbIntensity_set6
		SVAR rgbIntensity_set7=root:Packages:IR2L_NLSQF:rgbIntensity_set7
		SVAR rgbIntensity_set8=root:Packages:IR2L_NLSQF:rgbIntensity_set8
		SVAR rgbIntensity_set9=root:Packages:IR2L_NLSQF:rgbIntensity_set9
		SVAR rgbIntensity_set10=root:Packages:IR2L_NLSQF:rgbIntensity_set10

		SVAR rgbIntensityLine_set1=root:Packages:IR2L_NLSQF:rgbIntensityLine_set1
		SVAR rgbIntensityLine_set2=root:Packages:IR2L_NLSQF:rgbIntensityLine_set2
		SVAR rgbIntensityLine_set3=root:Packages:IR2L_NLSQF:rgbIntensityLine_set3
		SVAR rgbIntensityLine_set4=root:Packages:IR2L_NLSQF:rgbIntensityLine_set4
		SVAR rgbIntensityLine_set5=root:Packages:IR2L_NLSQF:rgbIntensityLine_set5
		SVAR rgbIntensityLine_set6=root:Packages:IR2L_NLSQF:rgbIntensityLine_set6
		SVAR rgbIntensityLine_set7=root:Packages:IR2L_NLSQF:rgbIntensityLine_set7
		SVAR rgbIntensityLine_set8=root:Packages:IR2L_NLSQF:rgbIntensityLine_set8
		SVAR rgbIntensityLine_set9=root:Packages:IR2L_NLSQF:rgbIntensityLine_set9
		SVAR rgbIntensityLine_set10=root:Packages:IR2L_NLSQF:rgbIntensityLine_set10
		Execute("ModifyGraph/Z/W=LSQF_MainGraph rgb(Intensity_set1)="+rgbIntensity_set1)
		Execute("ModifyGraph/Z /W=LSQF_MainGraph rgb(Intensity_set2)="+rgbIntensity_set2)
		Execute("ModifyGraph/Z/W=LSQF_MainGraph rgb(Intensity_set3)="+rgbIntensity_set3)
		Execute("ModifyGraph/Z/W=LSQF_MainGraph rgb(Intensity_set4)="+rgbIntensity_set4)
		Execute("ModifyGraph/Z/W=LSQF_MainGraph rgb(Intensity_set5)="+rgbIntensity_set5)
		Execute("ModifyGraph/Z/W=LSQF_MainGraph rgb(Intensity_set6)="+rgbIntensity_set6)
		Execute("ModifyGraph/Z/W=LSQF_MainGraph rgb(Intensity_set7)="+rgbIntensity_set7)
		Execute("ModifyGraph/Z/W=LSQF_MainGraph rgb(Intensity_set8)="+rgbIntensity_set8)
		Execute("ModifyGraph/Z/W=LSQF_MainGraph rgb(Intensity_set9)="+rgbIntensity_set9)
		Execute("ModifyGraph/Z/W=LSQF_MainGraph rgb(Intensity_set10)="+rgbIntensity_set10)

		Execute("ModifyGraph/Z/W=LSQF_MainGraph mode(IntensityModel_set1)=0,lsize(IntensityModel_set1)=2, rgb(IntensityModel_set1)="+rgbIntensityLine_set1)
		Execute("ModifyGraph/Z/W=LSQF_MainGraph mode(IntensityModel_set2)=0,lsize(IntensityModel_set2)=2, rgb(IntensityModel_set2)="+rgbIntensityLine_set2)
		Execute("ModifyGraph/Z/W=LSQF_MainGraph mode(IntensityModel_set3)=0,lsize(IntensityModel_set3)=2, rgb(IntensityModel_set3)="+rgbIntensityLine_set3)
		Execute("ModifyGraph/Z/W=LSQF_MainGraph mode(IntensityModel_set4)=0,lsize(IntensityModel_set4)=2, rgb(IntensityModel_set4)="+rgbIntensityLine_set4)
		Execute("ModifyGraph/Z/W=LSQF_MainGraph mode(IntensityModel_set5)=0,lsize(IntensityModel_set5)=2, rgb(IntensityModel_set5)="+rgbIntensityLine_set5)
		Execute("ModifyGraph/Z/W=LSQF_MainGraph mode(IntensityModel_set6)=0,lsize(IntensityModel_set6)=2, rgb(IntensityModel_set6)="+rgbIntensityLine_set6)
		Execute("ModifyGraph/Z/W=LSQF_MainGraph mode(IntensityModel_set7)=0,lsize(IntensityModel_set7)=2, rgb(IntensityModel_set7)="+rgbIntensityLine_set7)
		Execute("ModifyGraph/Z/W=LSQF_MainGraph mode(IntensityModel_set8)=0,lsize(IntensityModel_set8)=2, rgb(IntensityModel_set8)="+rgbIntensityLine_set8)
		Execute("ModifyGraph/Z/W=LSQF_MainGraph mode(IntensityModel_set9)=0,lsize(IntensityModel_set9)=2, rgb(IntensityModel_set9)="+rgbIntensityLine_set9)
		Execute("ModifyGraph/Z/W=LSQF_MainGraph mode(IntensityModel_set10)=0,lsize(IntensityModel_set10)=2, rgb(IntensityModel_set10)="+rgbIntensityLine_set10)
	endif
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_FormatLegend()
	
	DoWindow LSQF_MainGraph
	if(V_Flag)
		string Ltext="", curFldrName
		string AllWaves=TraceNameList("LSQF_MainGraph", ";", 1 )
		variable i, curset, curpop
		NVAR LegendUseWaveName=root:Packages:IrenaConfigFolder:LegendUseWaveName
		NVAR LegendUseFolderName=root:Packages:IrenaConfigFolder:LegendUseFolderName
		NVAR LegendSize=root:Packages:IrenaConfigFolder:LegendSize
		string LegSizeStr=""
		if(LegendSize<10)
			legSizeStr="0"+num2str(LegendSize)
		else
			LegSizeStr=num2str(LegendSize)
		endif
		string UserDataSetNameL
		string curIntNameL
		string IsModel=""
		for(i=0;i<ItemsInList(AllWaves);i+=1)
			//Need to decide if this is "Intensity_setX" or IntensityModel_setX of IntensityModel_setX_popY
			if(strlen(stringFromList(i,AllWaves))<16)
				curset = str2num(stringFromList(i,AllWaves)[13,inf])
				SVAR curSource=$("root:Packages:IR2L_NLSQF:FolderName_set"+num2str(curset))
				SVAR UserDataSetName=$("root:Packages:IR2L_NLSQF:UserDataSetName_set"+num2str(curset))
				UserDataSetNameL=UserDataSetName
				curFldrName = stringFromList(ItemsInList(curSource,":")-1,curSource,":")
				SVAR curIntName=$("root:Packages:IR2L_NLSQF:IntensityDataName_set"+num2str(curset))
				curIntNameL =curIntName
				isModel = ""
			elseif(strlen(stringFromList(i,AllWaves))<21) //should be the IntensityModel_setX 
				curset = str2num(stringFromList(i,AllWaves)[18,inf])
				SVAR curSource=$("root:Packages:IR2L_NLSQF:FolderName_set"+num2str(curset))
				SVAR UserDataSetName=$("root:Packages:IR2L_NLSQF:UserDataSetName_set"+num2str(curset))
				UserDataSetNameL="Model for "+UserDataSetName
				curFldrName = stringFromList(ItemsInList(curSource,":")-1,curSource,":")
				SVAR curIntName=$("root:Packages:IR2L_NLSQF:IntensityDataName_set"+num2str(curset))
				curIntNameL="Model for "+curIntName
				IsModel = "Model for "
			else //should be the IntensityModel_setX_popY 
				curset = str2num(stringFromList(i,AllWaves)[18,19])
				if(curset<10)
					curpop = str2num(stringFromList(i,AllWaves)[23,inf])
				else
					curpop = str2num(stringFromList(i,AllWaves)[24,inf])
				endif
				SVAR curSource=$("root:Packages:IR2L_NLSQF:FolderName_set"+num2str(curset))
				SVAR UserDataSetName=$("root:Packages:IR2L_NLSQF:UserDataSetName_set"+num2str(curset))
				UserDataSetNameL="Pop "+num2str(curpop)+" Model for "+UserDataSetName
				curFldrName = stringFromList(ItemsInList(curSource,":")-1,curSource,":")
				SVAR curIntName=$("root:Packages:IR2L_NLSQF:IntensityDataName_set"+num2str(curset))
				curIntNameL="Pop "+num2str(curpop)+" Model for "+curIntName
				IsModel ="Pop "+num2str(curpop)+ " Model for "
			endif
			Ltext+= "\\Z"+legSizeStr+"\\s("+stringFromList(i,AllWaves)+") "
			if(strlen(UserDataSetName)>0)
				Ltext+=" "+UserDataSetNameL
			else
				if(!LegendUseFolderName && !LegendUseWaveName)
					Ltext+=" "+IsModel+StringFromList(1,stringFromList(i,AllWaves),"_")
				endif
				if(LegendUseFolderName)
					Ltext+=" "+IsModel+curFldrName
				endif
				if(LegendUseWaveName)	
					Ltext+=" "+curIntNameL
				endif
			endif
			Ltext+="\r"
		endfor
		Ltext=Ltext[0,(strlen(Ltext)-2)]
		Legend/C/W=LSQF_MainGraph/N=Ltext/J/F=0/A=LB Ltext
	endif
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_Fitting()
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF


	//Create the fitting parameters, these will have _pop added and we need to add them to list of parameters to fit...
	string ListOfPopulationVariables=""

	Make/O/N=0/T T_Constraints
	T_Constraints=""
	Make/D/N=0/O W_coef
	Make/O/N=(0,2) Gen_Constraints
	Make/T/N=0/O CoefNames
	CoefNames=""

	variable i,j //i goes through all items in list, j is 1 to 6 - populations
	//first handle coefficients which are easy - those existing all the time... Volume is the only one at this time...
	ListOfPopulationVariables="Volume;"	
	For(j=1;j<=6;j+=1)
		NVAR UseThePop = $("root:Packages:IR2L_NLSQF:UseThePop_pop"+num2str(j))
		if(UseThePop)
			For(i=0;i<ItemsInList(ListOfPopulationVariables);i+=1)
				NVAR CurVarTested = $("root:Packages:IR2L_NLSQF:"+stringfromList(i,ListOfPopulationVariables)+"_pop"+num2str(j))
				NVAR FitCurVar=$("root:Packages:IR2L_NLSQF:"+stringfromList(i,ListOfPopulationVariables)+"Fit_pop"+num2str(j))
				NVAR CuVarMin=$("root:Packages:IR2L_NLSQF:"+stringfromList(i,ListOfPopulationVariables)+"Min_pop"+num2str(j))
				NVAR CuVarMax=$("root:Packages:IR2L_NLSQF:"+stringfromList(i,ListOfPopulationVariables)+"Max_pop"+num2str(j))
				if (FitCurVar)		//are we fitting this variable?
					Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
					Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
					W_Coef[numpnts(W_Coef)-1]=CurVarTested
					CoefNames[numpnts(CoefNames)-1]=stringfromList(i,ListOfPopulationVariables)+"_pop"+num2str(j)
					T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(CuVarMin)}
					T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(CuVarMax)}	
					Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
					Gen_Constraints[numpnts(CoefNames)-1][0] = CuVarMin
					Gen_Constraints[numpnts(CoefNames)-1][1] = CuVarMax
				endif
			endfor
		endif	
	endfor

	//second handle coefficients which are dependen on distribution shape....
	//Distribution parameters
	For(j=1;j<=6;j+=1)
		NVAR UseThePop = $("root:Packages:IR2L_NLSQF:UseThePop_pop"+num2str(j))
		SVAR PopSizeDistShape=$("root:Packages:IR2L_NLSQF:PopSizeDistShape_pop"+num2str(j))
		if(stringmatch(PopSizeDistShape,"Gauss"))
			ListOfPopulationVariables="GMeanSize;GWidth;"
		elseif(stringmatch(PopSizeDistShape,"LSW"))	
			ListOfPopulationVariables="LSWLocation;"
		else
			ListOfPopulationVariables="LNMinSize;LNMeanSize;LNSdeviation;"	
		endif
		if(UseThePop)
			For(i=0;i<ItemsInList(ListOfPopulationVariables);i+=1)
				NVAR CurVarTested = $("root:Packages:IR2L_NLSQF:"+stringfromList(i,ListOfPopulationVariables)+"_pop"+num2str(j))
				NVAR FitCurVar=$("root:Packages:IR2L_NLSQF:"+stringfromList(i,ListOfPopulationVariables)+"Fit_pop"+num2str(j))
				NVAR CuVarMin=$("root:Packages:IR2L_NLSQF:"+stringfromList(i,ListOfPopulationVariables)+"Min_pop"+num2str(j))
				NVAR CuVarMax=$("root:Packages:IR2L_NLSQF:"+stringfromList(i,ListOfPopulationVariables)+"Max_pop"+num2str(j))
				if (FitCurVar)		//are we fitting this variable?
					Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
					Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
					W_Coef[numpnts(W_Coef)-1]=CurVarTested
					CoefNames[numpnts(CoefNames)-1]=stringfromList(i,ListOfPopulationVariables)+"_pop"+num2str(j)
					T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(CuVarMin)}
					T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(CuVarMax)}		
					Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
					Gen_Constraints[numpnts(CoefNames)-1][0] = CuVarMin
					Gen_Constraints[numpnts(CoefNames)-1][1] = CuVarMax
				endif
			endfor
		endif	
	endfor

	//next structure factor coefficients 
	ListOfPopulationVariables="StructureParam1;StructureParam2;StructureParam3;StructureParam4;StructureParam5;StructureParam6;"
	For(j=1;j<=6;j+=1)
		NVAR UseThePop = $("root:Packages:IR2L_NLSQF:UseThePop_pop"+num2str(j))		
		//NVAR UseInterference = $("root:Packages:IR2L_NLSQF:UseInterference_pop"+num2str(j))
		if(UseThePop)// && UseInterference)
			//this checks in the checkboxes for fitting are nto set incorrectly... 
			SVAR StrFac=$("root:Packages:IR2L_NLSQF:StructureFactor_pop"+num2str(j))
			string FitP1Str = "root:Packages:IR2L_NLSQF:StructureParam1Fit_pop"+num2str(j)
			string FitP2Str = "root:Packages:IR2L_NLSQF:StructureParam2Fit_pop"+num2str(j)
			string FitP3Str = "root:Packages:IR2L_NLSQF:StructureParam3Fit_pop"+num2str(j)
			string FitP4Str = "root:Packages:IR2L_NLSQF:StructureParam4Fit_pop"+num2str(j)
			string FitP5Str = "root:Packages:IR2L_NLSQF:StructureParam5Fit_pop"+num2str(j)
			string FitP6Str = "root:Packages:IR2L_NLSQF:StructureParam6Fit_pop"+num2str(j)
			IR2S_CheckFitParameter(StrFac,FitP1Str,FitP2Str,FitP3Str,FitP4Str,FitP5Str,FitP6Str)
			For(i=0;i<ItemsInList(ListOfPopulationVariables);i+=1)
				NVAR CurVarTested = $("root:Packages:IR2L_NLSQF:"+stringfromList(i,ListOfPopulationVariables)+"_pop"+num2str(j))
				NVAR FitCurVar=$("root:Packages:IR2L_NLSQF:"+stringfromList(i,ListOfPopulationVariables)+"Fit_pop"+num2str(j))
				NVAR CuVarMin=$("root:Packages:IR2L_NLSQF:"+stringfromList(i,ListOfPopulationVariables)+"Min_pop"+num2str(j))
				NVAR CuVarMax=$("root:Packages:IR2L_NLSQF:"+stringfromList(i,ListOfPopulationVariables)+"Max_pop"+num2str(j))
				if (FitCurVar)		//are we fitting this variable?
					Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
					Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
					W_Coef[numpnts(W_Coef)-1]=CurVarTested
					CoefNames[numpnts(CoefNames)-1]=stringfromList(i,ListOfPopulationVariables)+"_pop"+num2str(j)
					T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(CuVarMin)}
					T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(CuVarMax)}		
					Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
					Gen_Constraints[numpnts(CoefNames)-1][0] = CuVarMin
					Gen_Constraints[numpnts(CoefNames)-1][1] = CuVarMax
				endif
			endfor
		endif	
	endfor

	//next the most complicated one - form factor parameters... Need to set the checkboxes right accoring to selected for factor so we do not have to bother here 
	ListOfPopulationVariables="FormFactor_Param1;"	
	ListOfPopulationVariables+="FormFactor_Param2;"	
	ListOfPopulationVariables+="FormFactor_Param3;"	
	ListOfPopulationVariables+="FormFactor_Param4;"	
	ListOfPopulationVariables+="FormFactor_Param5;"	
	For(j=1;j<=6;j+=1)
		NVAR UseThePop = $("root:Packages:IR2L_NLSQF:UseThePop_pop"+num2str(j))		
		if(UseThePop)
			For(i=0;i<ItemsInList(ListOfPopulationVariables);i+=1)
				NVAR CurVarTested = $("root:Packages:IR2L_NLSQF:"+stringfromList(i,ListOfPopulationVariables)+"_pop"+num2str(j))
				NVAR FitCurVar=$("root:Packages:IR2L_NLSQF:"+stringfromList(i,ListOfPopulationVariables)+"Fit_pop"+num2str(j))
				NVAR CuVarMin=$("root:Packages:IR2L_NLSQF:"+stringfromList(i,ListOfPopulationVariables)+"Min_pop"+num2str(j))
				NVAR CuVarMax=$("root:Packages:IR2L_NLSQF:"+stringfromList(i,ListOfPopulationVariables)+"Max_pop"+num2str(j))
				if (FitCurVar)		//are we fitting this variable?
					Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
					Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
					W_Coef[numpnts(W_Coef)-1]=CurVarTested
					CoefNames[numpnts(CoefNames)-1]=stringfromList(i,ListOfPopulationVariables)+"_pop"+num2str(j)
					T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(CuVarMin)}
					T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(CuVarMax)}		
					Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
					Gen_Constraints[numpnts(CoefNames)-1][0] = CuVarMin
					Gen_Constraints[numpnts(CoefNames)-1][1] = CuVarMax
				endif
			endfor
		endif	
	endfor
	
	//Now background... 
	string ListOfDataVariables="Background;"
	NVAR MultipleInputData=root:Packages:IR2L_NLSQF:MultipleInputData
	variable LastDataSet
	LastDataSet = (MultipleInputData) ? 10 : 1
	For(j=1;j<=LastDataSet;j+=1)
		NVAR UseThePop = $("root:Packages:IR2L_NLSQF:UseTheData_set"+num2str(j))		
		if(UseThePop || !MultipleInputData)
			For(i=0;i<ItemsInList(ListOfDataVariables);i+=1)
				NVAR CurVarTested = $("root:Packages:IR2L_NLSQF:"+stringfromList(i,ListOfDataVariables)+"_set"+num2str(j))
				NVAR FitCurVar=$("root:Packages:IR2L_NLSQF:"+stringfromList(i,ListOfDataVariables)+"Fit_set"+num2str(j))
				NVAR CuVarMin=$("root:Packages:IR2L_NLSQF:"+stringfromList(i,ListOfDataVariables)+"Min_set"+num2str(j))
				NVAR CuVarMax=$("root:Packages:IR2L_NLSQF:"+stringfromList(i,ListOfDataVariables)+"Max_set"+num2str(j))
				if (FitCurVar)		//are we fitting this variable?
					Redimension /N=(numpnts(W_coef)+1) W_coef, CoefNames
					Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
					W_Coef[numpnts(W_Coef)-1]=CurVarTested
					CoefNames[numpnts(CoefNames)-1]=stringfromList(i,ListOfDataVariables)+"_set"+num2str(j)
					T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(CuVarMin)}
					T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(CuVarMax)}		
					Redimension /N=((numpnts(W_coef)),2) Gen_Constraints
					Gen_Constraints[numpnts(CoefNames)-1][0] = CuVarMin
					Gen_Constraints[numpnts(CoefNames)-1][1] = CuVarMax
				endif
			endfor
		endif	
	endfor

	//Ok, all parameters should be dealt with, now the fitting... 
	DoWindow /F LSQF_MainGraph
	variable QstartPoint, QendPoint
	Make/O/N=0 QWvForFit, IntWvForFit, EWvForFit
	For(j=1;j<=LastDataSet;j+=1)
		NVAR UseTheSet = $("root:Packages:IR2L_NLSQF:UseTheData_set"+num2str(j))		
		if(UseTheSet)
			Wave Qwave=$("root:Packages:IR2L_NLSQF:Q_set"+num2str(j))
			Wave InWave=$("root:Packages:IR2L_NLSQF:Intensity_set"+num2str(j))
			Wave Ewave=$("root:Packages:IR2L_NLSQF:Error_set"+num2str(j))	
			NVAR Qmin=$("root:Packages:IR2L_NLSQF:Qmin_set"+num2str(j))
			NVAR Qmax=$("root:Packages:IR2L_NLSQF:Qmax_set"+num2str(j))
			QstartPoint=BinarySearch(Qwave, Qmin )
			QendPoint=BinarySearch(Qwave, Qmax )
			Duplicate/O/R=[QstartPoint,QendPoint] Qwave, QTemp
			Duplicate/O/R=[QstartPoint,QendPoint] InWave, IntTemp
			Duplicate/O/R=[QstartPoint,QendPoint] Ewave, ETemp
			Concatenate/NP/O {QWvForFit, QTemp}, TempWv
			Duplicate/O TempWv, QWvForFit
			Concatenate/NP/O {IntWvForFit, IntTemp}, TempWv
			Duplicate/O TempWv,IntWvForFit
			Concatenate/NP/O {EWvForFit, ETemp}, TempWv
			Duplicate/O TempWv,EWvForFit
		endif
	endfor
	if(numpnts(W_Coef)<1)
		DoAlert 0, "Nothing to fit, select at least 1 parameter to fit"
		return 1
	endif

	Duplicate/O W_Coef, E_wave, CoefficientInput
	E_wave=W_coef/20
	Variable V_chisq
	string HoldStr=""
	For(i=0;i<numpnts(CoefficientInput);i+=1)
		HoldStr+="0"
	endfor
	Duplicate/O IntWvForFit, MaskWaveGenOpt
	MaskWaveGenOpt=1
	
	IR2L_CheckFittingParamsFnct()
	PauseForUser IR2L_CheckFittingParams

	NVAR UserCanceled=root:Packages:IR2L_NLSQF:UserCanceled
	if (UserCanceled)
		setDataFolder OldDf
		abort
	endif


	IR2L_RecordResults("before")
	NVAR UseGeneticOptimization=root:Packages:IR2L_NLSQF:UseGeneticOptimization
	Duplicate/O IntWvForFit, tempDestWave
	Variable V_FitError=0			//This should prevent errors from being generated
	//and now the fit...
	if(UseGeneticOptimization)
//	  	gencurvefit IR2L_FitFunction W_Coef IntWvForFit,HoldStr,x=QWvForFit,w=EWvForFit,c=Gen_Constraints, /M=MaskWaveGenOpt, popsize=20,k_m=0.7,recomb=0.5,iters=50,tol=0.002)	
#if Exists("gencurvefit")
////	  	gencurvefit  /I=1 /W=EWvForFit /M=MaskWaveGenOpt /N /TOL=1 /K={50,20,0.7,0.5} /X=QWvForFit /METH=1 IR2L_FitFunction, IntWvForFit  , W_Coef, HoldStr, Gen_Constraints  	
	  	gencurvefit  /I=1 /W=EWvForFit /M=MaskWaveGenOpt /N /TOL=0.002 /K={50,20,0.7,0.5} /X=QWvForFit IR2L_FitFunction, IntWvForFit  , W_Coef, HoldStr, Gen_Constraints  	
//		print "xop code"
#else
	  	GEN_curvefit("IR2L_FitFunction",W_Coef,IntWvForFit,HoldStr,x=QWvForFit,w=EWvForFit,c=Gen_Constraints, mask=MaskWaveGenOpt, popsize=20,k_m=0.7,recomb=0.5,iters=50,tol=0.002)	
//		print "Old code"
#endif
	else
		FuncFit /N/Q IR2L_FitFunction W_coef IntWvForFit /X=QWvForFit /W=EWvForFit /I=1/E=E_wave /D /C=T_Constraints 
//		FuncFit /N/Q IR1U_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1 /E=E_wave/D /C=T_Constraints	
	endif

	if (V_FitError!=0)	//there was error in fitting
		IR2L_ResetParamsAfterBadFit()
		Abort "Fitting error, check starting parameters and fitting limits" 
	else		//results OK, make sure the resulting values are set 
		variable NumParams=numpnts(CoefNames)
		string ParamName
		For(i=0;i<NumParams;i+=1)
			ParamName = CoefNames[i]
			NVAR TempVar = $(ParamName)
			TempVar=W_Coef[i]
		endfor
	endif
	
	variable/g AchievedChisq=V_chisq
//	IR1U_GraphModelData()
	IR2L_RecordResults("after")
//	
//	DoWIndow/F IR1U_ControlPanel
//	IR1U_FixTabsInPanel()
//	
	KillWaves T_Constraints, E_wave
	
	IR2L_CalculateIntensity(1,0)

	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_CheckFittingParamsFnct() 
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1/W=(400,140,870,600) as "Check fitting parameters"
	Dowindow/C IR2L_CheckFittingParams
	SetDrawLayer UserBack
	SetDrawEnv fsize= 20,fstyle= 3,textrgb= (0,0,65280)
	DrawText 39,28,"Modeling II Fit Params & Limits"
	NVAR UseGeneticOptimization=root:Packages:IR2L_NLSQF:UseGeneticOptimization
	if(UseGeneticOptimization)
		SetDrawEnv fstyle= 1,fsize= 14
		DrawText 10,50,"For Gen Opt. verify fitted parameters. Make sure"
		SetDrawEnv fstyle= 1,fsize= 14
		DrawText 10,70,"the parameter range is appropriate."
		SetDrawEnv fstyle= 1,fsize= 14
		DrawText 10,90,"The whole range must be valid! It will be tested!"
		SetDrawEnv fstyle= 1,fsize= 14
		DrawText 10,110,"       Then continue....."
	else
		SetDrawEnv fstyle= 1,fsize= 14
		DrawText 17,55,"Verify the list of fitted parameters."
		SetDrawEnv fstyle= 1,fsize= 14
		DrawText 17,75,"        Then continue......"
	endif
	Button CancelBtn,pos={27,420},size={150,20},proc=IR2L_CheckFitPrmsButtonProc,title="Cancel fitting"
	Button ContinueBtn,pos={187,420},size={150,20},proc=IR2L_CheckFitPrmsButtonProc,title="Continue fitting"
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:IR2L_NLSQF:
	Wave Gen_Constraints,W_coef
	Wave/T CoefNames
	SetDimLabel 1,0,Min,Gen_Constraints
	SetDimLabel 1,1,Max,Gen_Constraints
	variable i
	For(i=0;i<numpnts(CoefNames);i+=1)
		SetDimLabel 0,i,$(CoefNames[i]),Gen_Constraints
	endfor
	if(UseGeneticOptimization)
		Edit/W=(0.05,0.25,0.95,0.865)/HOST=#  Gen_Constraints.ld,W_coef
//		ModifyTable format(Point)=1,width(Point)=0, width(Gen_Constraints)=110
//		ModifyTable alignment(W_coef)=1,sigDigits(W_coef)=4,title(W_coef)="Curent value"
//		ModifyTable alignment(Gen_Constraints)=1,sigDigits(Gen_Constraints)=4,title(Gen_Constraints)="Limits"
//		ModifyTable statsArea=85
		ModifyTable format(Point)=1,width(Point)=0,alignment(W_coef.y)=1,sigDigits(W_coef.y)=4
		ModifyTable width(W_coef.y)=90,title(W_coef.y)="Start value",width(Gen_Constraints.l)=172
//		ModifyTable title[1]="Min"
//		ModifyTable title[2]="Max"
		ModifyTable alignment(Gen_Constraints.d)=1,sigDigits(Gen_Constraints.d)=4,width(Gen_Constraints.d)=72
		ModifyTable title(Gen_Constraints.d)="Limits"
//		ModifyTable statsArea=85
//		ModifyTable statsArea=20
	else
		Edit/W=(0.05,0.18,0.95,0.865)/HOST=#  CoefNames
		ModifyTable format(Point)=1,width(Point)=0,width(CoefNames)=144,title(CoefNames)="Fitted Coef Name"
//		ModifyTable statsArea=85
	endif
	SetDataFolder fldrSav0
	RenameWindow #,T0
	SetActiveSubwindow ##
End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_CheckFitPrmsButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	if(stringmatch(ctrlName,"*CancelBtn*"))
		variable/g root:Packages:IR2L_NLSQF:UserCanceled=1
		DoWindow/K IR2L_CheckFittingParams
	endif

	if(stringmatch(ctrlName,"*ContinueBtn*"))
		variable/g root:Packages:IR2L_NLSQF:UserCanceled=0
		DoWindow/K IR2L_CheckFittingParams
	endif

End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_ResetParamsAfterBadFit()
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF
	variable i
	Wave/Z w=root:Packages:IR2L_NLSQF:CoefficientInput
	Wave/T/Z CoefNames=root:Packages:IR2L_NLSQF:CoefNames		//text wave with names of parameters

	if(!WaveExists(w) || !WaveExists(CoefNames))
		abort
	endif
	
	variable NumParams=numpnts(CoefNames)
	string ParamName
	
	For(i=0;i<NumParams;i+=1)
		ParamName = CoefNames[i]
		NVAR TempVar = $(ParamName)
		TempVar=w[i]
	endfor

	IR2L_CalculateIntensity(1,0)

	setDataFolder oldDF
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_FitFunction(w,yw,xw) : FitFunc
	Wave w,yw,xw
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF
	variable i

	Wave/T CoefNames
	variable NumParams=numpnts(CoefNames)
	string ParamName
	
	For(i=0;i<NumParams;i+=1)
		ParamName = CoefNames[i]
		NVAR TempVar = $(ParamName)
		TempVar=w[i]
	endfor
	IR2L_CalculateIntensity(1,1)
	Make/O/N=0 IntWvResult
	NVAR MultipleInputData=root:Packages:IR2L_NLSQF:MultipleInputData
	variable LastDataSet
	LastDataSet = (MultipleInputData) ? 10 : 1
	For(i=1;i<=LastDataSet;i+=1)
		NVAR UseTheSet = $("root:Packages:IR2L_NLSQF:UseTheData_set"+num2str(i))		
		if(UseTheSet)
			Wave InWave=$("root:Packages:IR2L_NLSQF:IntensityModel_set"+num2str(i))
			Concatenate/NP/O {IntWvResult, InWave}, tempWv
			Duplicate/O tempWv, IntWvResult
		endif
	endfor

	yw = IntWvResult
	
	KillWaves IntWvResult
	setDataFolder oldDF
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR2L_RecordResults(CalledFromWere)
	string CalledFromWere	//before or after - that means fit...

	string OldDF=GetDataFolder(1)
	setdataFolder root:Packages:IR2L_NLSQF
	variable i
	IR1_CreateLoggbook()		//this creates the logbook
	SVAR nbl=root:Packages:SAS_Modeling:NotebookName
	IR1L_AppendAnyText("     ")
	if (cmpstr(CalledFromWere,"before")==0)
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("Parameters before starting Modeling II Fitting on the data from: ")
		IR1_InsertDateAndTime(nbl)
	else			//after
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("Results of the Modeling II Fitting on the data from: ")	
		IR1_InsertDateAndTime(nbl)
	endif
	NVAR MultipleInputData=root:Packages:IR2L_NLSQF:MultipleInputData
	if(MultipleInputData)
		//multiple data selected, need to return to multiple places....
		IR1L_AppendAnyText("Multiple data sets used, listing of data sets\r")	
		for(i=1;i<11;i+=1)
			NVAR UseSet=$("root:Packages:IR2L_NLSQF:UseTheData_set"+num2str(i))
			if(UseSet)
					SVAR testStr = $("FolderName_set"+num2str(i))
					IR1L_AppendAnyText("FolderName_set"+num2str(i)+"\t=\t"+testStr)
					IR2L_RecordDataResults(i)
					IR1L_AppendAnyText("  ")
			endif
		endfor
	else
		IR1L_AppendAnyText("Single data set used:")	
		//only one data set to be returned... the first one
		SVAR testStr = $("FolderName_set1")
		IR1L_AppendAnyText("FolderName_set1"+"\t=\t"+testStr)
		IR2L_RecordDataResults(1)
	endif
	//now models... 
	IR1L_AppendAnyText("\rModel microsctructure parameters\r")	
	For (i=1;i<=6;i+=1)
		IR2L_RecordModelResults(i)
	endfor
	
	if (cmpstr(CalledFromWere,"after")==0)
			IR1L_AppendAnyText("             **********************                   ")
			IR1L_AppendAnyText("Fit has been reached with following parameters")
			SVAR nbl=root:Packages:SAS_Modeling:NotebookName
			IR1_InsertDateAndTime(nbl)
			NVAR AchievedChisq
			IR1L_AppendAnyText("Chi-Squared \t"+ num2str(AchievedChisq))
			IR1L_AppendAnyText("             **********************                   ")
	endif			//after

	setdataFolder oldDf

end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_SaveResultsInDataFolder()
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF

	SVAR/Z ListOfVariables=root:Packages:IR2L_NLSQF:ListOfVariables
	SVAR/Z ListOfDataVariables=root:Packages:IR2L_NLSQF:ListOfDataVariables
	SVAR/Z ListOfPopulationVariables=root:Packages:IR2L_NLSQF:ListOfPopulationVariables
	SVAR/Z ListOfStrings=root:Packages:IR2L_NLSQF:ListOfStrings
	SVAR/Z ListOfDataStrings=root:Packages:IR2L_NLSQF:ListOfDataStrings
	SVAR/Z ListOfPopulationsStrings=root:Packages:IR2L_NLSQF:ListOfPopulationsStrings

	if(!SVAR_Exists(ListOfVariables) || !SVAR_Exists(ListOfDataVariables) || !SVAR_Exists(ListOfPopulationVariables) || !SVAR_Exists(ListOfStrings) || !SVAR_Exists(ListOfDataStrings) || !SVAR_Exists(ListOfPopulationsStrings))
		abort "Error in parameters in SaveResultsInDdataFolder routine. Send the file to author for bug fix, please"
	endif
	
	variable i, j 

	//and here we store them in the List to use in the wave note...
	string ListOfParameters=""
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		NVAR testVar = $( StringFromList(i,ListOfVariables))
		ListOfParameters+=StringFromList(i,ListOfVariables)+"="+num2str(testVar)+";"
	endfor		
	//following needs to run 10 times to create 10 sets for 10 data sets...
	for(j=1;j<=10;j+=1)	
		for(i=0;i<itemsInList(ListOfDataVariables);i+=1)	
			NVAR testVar = $(StringFromList(i,ListOfDataVariables)+"_set"+num2str(j))
			ListOfParameters+=StringFromList(i,ListOfDataVariables)+"_set"+num2str(j)+"="+num2str(testVar)+";"
		endfor	
	endfor
	//following needs to run 6 times to create 6 different populations sets of variables and strings	
	for(j=1;j<=6;j+=1)	
		for(i=0;i<itemsInList(ListOfPopulationVariables);i+=1)	
			NVAR testVar = $(StringFromList(i,ListOfPopulationVariables)+"_pop"+num2str(j))
			ListOfParameters+=StringFromList(i,ListOfPopulationVariables)+"_pop"+num2str(j)+"="+num2str(testVar)+";"
		endfor
	endfor		
	//following 10 times as these are data sets
	for(j=1;j<=10;j+=1)	
		for(i=0;i<itemsInList(ListOfDataStrings);i+=1)	
			SVAR testStr = $(StringFromList(i,ListOfDataStrings)+"_set"+num2str(j))
			ListOfParameters+=StringFromList(i,ListOfDataStrings)+"_set"+num2str(j)+"="+testStr+";"
		endfor	
	endfor		
	for(j=1;j<=6;j+=1)	
		for(i=0;i<itemsInList(ListOfPopulationsStrings);i+=1)	
			SVAR testStr = $(StringFromList(i,ListOfPopulationsStrings)+"_pop"+num2str(j))
			ListOfParameters+=StringFromList(i,ListOfPopulationsStrings)+"_pop"+num2str(j)+"="+testStr+";"
		endfor	
	endfor							
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		SVAR testStr = $(StringFromList(i,ListOfStrings))
		ListOfParameters+=StringFromList(i,ListOfStrings)+"="+testStr+";"
	endfor	

//	print ListOfParameters
	NVAR MultipleInputData=root:Packages:IR2L_NLSQF:MultipleInputData
	if(MultipleInputData)
		//multiple data selected, need to return to multiple places....
		for(i=1;i<11;i+=1)
			NVAR UseSet=$("root:Packages:IR2L_NLSQF:UseTheData_set"+num2str(i))
			if(UseSet)
				IR2L_ReturnOneDataSetToFolder(i, ListOfParameters)
			endif
		endfor
	else
		//only one data set to be returned... the first one
		IR2L_ReturnOneDataSetToFolder(1, ListOfParameters)
	endif
	

	setDataFolder oldDF

end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_ReturnOneDataSetToFolder(whichDataSet, WaveNoteText)
	variable whichDataSet
	string WaveNoteText

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF


	SVAR DataFolderName = $("root:Packages:IR2L_NLSQF:FolderName_set"+num2str(whichDataSet))
	
	Wave Intensity		= $("root:Packages:IR2L_NLSQF:IntensityModel_set"+num2str(whichDataSet))
	Wave Qvector 		= $("root:Packages:IR2L_NLSQF:Qmodel_set"+num2str(whichDataSet))
	Wave Radii 			= root:Packages:IR2L_NLSQF:DistRadia
	Wave NumberDist 	= root:Packages:IR2L_NLSQF:TotalNumberDist
	Wave VolumeDist 	= root:Packages:IR2L_NLSQF:TotalVolumeDist
	
	string UsersComment, ExportSeparateDistributions
	UsersComment="Result from LSQF2 Modeling "+date()+"  "+time()
	ExportSeparateDistributions="No"
	Prompt UsersComment, "Modify comment to be saved with these results"
	Prompt ExportSeparateDistributions, "Export separately populations data", popup, "No;Yes;"
	DoPrompt "Need input for saving data", UsersComment, ExportSeparateDistributions
	if (V_Flag)
		abort
	endif

	setDataFolder $(DataFolderName)
	string tempname 
	variable ii=0
	For(ii=0;ii<1000;ii+=1)
		tempname="IntensityModelLSQF2_"+num2str(ii)
		if (checkname(tempname,1)==0)
			break
		endif
	endfor

	Duplicate Intensity, $("IntensityModelLSQF2_"+num2str(ii))
	Duplicate Qvector, $("QvectorModelLSQF2_"+num2str(ii))
	Duplicate Radii, $("RadiiModelLSQF2_"+num2str(ii))
	Duplicate NumberDist, $("NumberDistModelLSQF2_"+num2str(ii))
	Duplicate VolumeDist, $("VolumeDistModelLSQF2_"+num2str(ii))
	
	Wave MytempWave=$("IntensityModelLSQF2_"+num2str(ii))
	tempname = "IntensityModelLSQF2_"+num2str(ii)
	IN2G_AppendorReplaceWaveNote(tempname,"DataFrom",GetDataFolder(0))
	IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
	IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
	IN2G_AppendorReplaceWaveNote(tempname,"Units","1/cm")
	note MytempWave, WaveNoteText
	Redimension/D MytempWave
		
	Wave MytempWave=$("QvectorModelLSQF2_"+num2str(ii))
	tempname = "QvectorModelLSQF2_"+num2str(ii)
	IN2G_AppendorReplaceWaveNote(tempname,"DataFrom",GetDataFolder(0))
	IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
	IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
	IN2G_AppendorReplaceWaveNote(tempname,"Units","1/A")
	note MytempWave, WaveNoteText
	Redimension/D MytempWave
		
	Wave MytempWave=$("RadiiModelLSQF2_"+num2str(ii))
	tempname = "RadiiModelLSQF2_"+num2str(ii)
	IN2G_AppendorReplaceWaveNote(tempname,"DataFrom",GetDataFolder(0))
	IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
	IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
	IN2G_AppendorReplaceWaveNote(tempname,"Units","A")
	note MytempWave, WaveNoteText
	Redimension/D MytempWave
		
	Wave MytempWave=$("NumberDistModelLSQF2_"+num2str(ii))
	tempname = "NumberDistModelLSQF2_"+num2str(ii)
	IN2G_AppendorReplaceWaveNote(tempname,"DataFrom",GetDataFolder(0))
	IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
	IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
	IN2G_AppendorReplaceWaveNote(tempname,"Units","1/cm3")
	note MytempWave, WaveNoteText
	Redimension/D MytempWave
		
	Wave MytempWave=$("VolumeDistModelLSQF2_"+num2str(ii))
	tempname = "VolumeDistModelLSQF2_"+num2str(ii)
	IN2G_AppendorReplaceWaveNote(tempname,"DataFrom",GetDataFolder(0))
	IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
	IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
	IN2G_AppendorReplaceWaveNote(tempname,"Units","fraction")
	note MytempWave, WaveNoteText
	Redimension/D MytempWave

	setDataFolder oldDF
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_SaveResultsInWaves()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF
	//define new folder through dialog... stuff in NewFolderName
	string/g ExportWvsDataFolderName
	string NewFolderName
	if(strlen(ExportWvsDataFolderName)>0)
		NewFolderName = ExportWvsDataFolderName
	else
		NewFolderName = "NewLSQF_FitResults"
	endif
	Prompt NewFolderName, "Input folder name for Output waves"
	DoPrompt "Output folder Name", NewFolderName
	

	NVAR MultipleInputData=root:Packages:IR2L_NLSQF:MultipleInputData
	variable i
	if(MultipleInputData)
		//multiple data selected, need to return to multiple places....
		for(i=1;i<11;i+=1)
			NVAR UseSet=$("root:Packages:IR2L_NLSQF:UseTheData_set"+num2str(i))
			if(UseSet)
				IR2L_SaveResInWavesIndivDtSet(i,NewFolderName)
			endif
		endfor
	else
		//only one data set to be returned... the first one
		IR2L_SaveResInWavesIndivDtSet(1,NewFolderName)
	endif

	setDataFolder OldDf
end

//*****************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_SaveResInWavesIndivDtSet(WdtSt, NewFolderName)
	variable WdtSt
	string NewFolderName
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF

	string ListOfVariables, ListOfDataVariables, ListOfPopulationVariables
	string ListOfStrings, ListOfDataStrings, ListOfPopulationsStrings
	string ListOfParameters, ListOfParametersStr
	ListOfParametersStr = ""
	ListOfParameters=""
	variable i, j 
	
	j = WdtSt
	
	//First deal with data itself... Name, background etc. 
	ListOfDataStrings ="FolderName;IntensityDataName;QvecDataName;ErrorDataName;UserDataSetName;"
	for(i=0;i<itemsInList(ListOfDataStrings);i+=1)	
		SVAR testStr = $(StringFromList(i,ListOfDataStrings)+"_set"+num2str(j))
		ListOfParametersStr+=StringFromList(i,ListOfDataStrings)+"_set"+num2str(j)+"="+testStr+";"
	endfor	
	ListOfDataVariables="DataScalingFactor;ErrorScalingFactor;Qmin;Qmax;Background;"
	for(i=0;i<itemsInList(ListOfDataVariables);i+=1)	
		NVAR testVar = $(StringFromList(i,ListOfDataVariables)+"_set"+num2str(j))
		ListOfParameters+=StringFromList(i,ListOfDataVariables)+"_set"+num2str(j)+"="+num2str(testVar)+";"
	endfor	
	
	//Slit smeared data?
	NVAR SlitSmeared = $("root:Packages:IR2L_NLSQF:SlitSmeared_set"+num2str(j))
	if(SlitSmeared)
		NVAR SlitLength = $("root:Packages:IR2L_NLSQF:SlitLength_set"+num2str(j))
		ListOfParameters+="SlitLength"+"_set"+num2str(j)+"="+num2str(SlitLength)+";"
	else
		ListOfParameters+="SlitLength"+"_set"+num2str(j)+"=0;"
	endif

	//Background fit?
	NVAR BackgroundFit = $("root:Packages:IR2L_NLSQF:BackgroundFit_set"+num2str(j))
	if(BackgroundFit)
		NVAR BackgErr = $("root:Packages:IR2L_NLSQF:BackgErr_set"+num2str(j))
		ListOfParameters+="BackgroundError"+"_set"+num2str(j)+"="+num2str(BackgErr)+";"
	else
		ListOfParameters+="BackgroundError"+"_set"+num2str(j)+"=0;"
	endif

	variable k
	//And now the populations
	For(i=1;i<=6;i+=1)
		NVAR UseThePop = $("root:Packages:IR2L_NLSQF:UseThePop_pop"+num2str(i))
		
		if(UseThePop)
				ListOfPopulationVariables="Volume;Mean;Mode;Median;FWHM;"	
				for(k=0;k<itemsInList(ListOfPopulationVariables);k+=1)	
					NVAR testVar = $(StringFromList(k,ListOfPopulationVariables)+"_pop"+num2str(i))
					ListOfParameters+=StringFromList(k,ListOfPopulationVariables)+"_pop"+num2str(i)+"="+num2str(testVar)+";"
				endfor
			
				SVAR PopSizeDistShape = $("root:Packages:IR2L_NLSQF:PopSizeDistShape_pop"+num2str(i))		
				if(stringmatch(PopSizeDistShape, "Gauss") )
					ListOfParametersStr+="DistributionShape_pop"+num2str(i)+"=Gauss;"
					NVAR GMeanSize =  $("root:Packages:IR2L_NLSQF:GMeanSize_pop"+num2str(i))	
					ListOfParameters+="GaussMean_pop"+num2str(i)+"="+num2str(GMeanSize)+";"
					NVAR GWidth =  $("root:Packages:IR2L_NLSQF:GWidth_pop"+num2str(i))	
					ListOfParameters+="GaussWidth_pop"+num2str(i)+"="+num2str(GWidth)+";"
					ListOfParameters+="LSWLocation_pop"+num2str(i)+"=0;"				
					ListOfParameters+="LogNormalMin_pop"+num2str(i)+"=0;"
					ListOfParameters+="LogNormalMean_pop"+num2str(i)+"=0;"
					ListOfParameters+="LogNormalSdeviation_pop"+num2str(i)+"=0;"
				elseif(stringmatch(PopSizeDistShape, "LogNormal" ))
					ListOfParametersStr+="DistributionShape_pop"+num2str(i)+"=LogNormal;"
					NVAR LNMinSize =  $("root:Packages:IR2L_NLSQF:LNMinSize_pop"+num2str(i))	
					ListOfParameters+="LogNormalMin_pop"+num2str(i)+"="+num2str(LNMinSize)+";"
					NVAR LNMeanSize =  $("root:Packages:IR2L_NLSQF:LNMeanSize_pop"+num2str(i))	
					ListOfParameters+="LogNormalMean_pop"+num2str(i)+"="+num2str(LNMeanSize)+";"
					NVAR LNSdeviation =  $("root:Packages:IR2L_NLSQF:LNSdeviation_pop"+num2str(i))	
					ListOfParameters+="LogNormalSdeviation_pop"+num2str(i)+"="+num2str(LNSdeviation)+";"
					ListOfParameters+="GaussMean_pop"+num2str(i)+"=0;"
					ListOfParameters+="GaussWidth_pop"+num2str(i)+"=0;"
					ListOfParameters+="LSWLocation_pop"+num2str(i)+"=0;"				
				else //LSW
					ListOfParametersStr+="DistributionShape_pop"+num2str(i)+"=LSW;"
					NVAR LSWLocation =  $("root:Packages:IR2L_NLSQF:LSWLocation_pop"+num2str(i))	
					ListOfParameters+="LSWLocation_pop"+num2str(i)+"="+num2str(LSWLocation)+";"				
					ListOfParameters+="GaussMean_pop"+num2str(i)+"=0;"
					ListOfParameters+="GaussWidth_pop"+num2str(i)+"=0;"
					ListOfParameters+="LogNormalMin_pop"+num2str(i)+"=0;"
					ListOfParameters+="LogNormalMean_pop"+num2str(i)+"=0;"
					ListOfParameters+="LogNormalSdeviation_pop"+num2str(i)+"=0;"
				endif
					
				NVAR VaryContrast=root:Packages:IR2L_NLSQF:SameContrastForDataSets
//				ListOfPopulationVariables+="Contrast;Contrast_set1;Contrast_set2;Contrast_set3;Contrast_set4;Contrast_set5;Contrast_set6;Contrast_set7;Contrast_set8;Contrast_set9;Contrast_set10;"	
				if(VaryContrast)
					ListOfParameters+="Contrast_pop"+num2str(i)+"=0;"
					ListOfPopulationVariables="Contrast_set1;Contrast_set2;Contrast_set3;Contrast_set4;Contrast_set5;Contrast_set6;Contrast_set7;Contrast_set8;Contrast_set9;Contrast_set10;"
					for(k=0;k<itemsInList(ListOfPopulationVariables);k+=1)	
						NVAR testVar = $(StringFromList(k,ListOfPopulationVariables)+"_pop"+num2str(i))
						ListOfParameters+=StringFromList(k,ListOfPopulationVariables)+"_pop"+num2str(i)+"="+num2str(testVar)+";"
					endfor
				else		//same contrast for all sets... 
					NVAR Contrast = $("root:Packages:IR2L_NLSQF:Contrast_pop"+num2str(i))
					ListOfParameters+="Contrast_pop"+num2str(i)+"="+num2str(Contrast)+";"
					ListOfPopulationVariables="Contrast_set1;Contrast_set2;Contrast_set3;Contrast_set4;Contrast_set5;Contrast_set6;Contrast_set7;Contrast_set8;Contrast_set9;Contrast_set10;"
					for(k=0;k<itemsInList(ListOfPopulationVariables);k+=1)	
						NVAR testVar = $(StringFromList(k,ListOfPopulationVariables)+"_pop"+num2str(i))
						ListOfParameters+=StringFromList(k,ListOfPopulationVariables)+"_pop"+num2str(i)+"=0;"
					endfor
				endif
				// For factor parameters.... messy... 
				SVAR FormFac=$("root:Packages:IR2L_NLSQF:FormFactor_pop"+num2str(i))
				ListOfParametersStr+="FormFactor_pop"+num2str(i)+"="+FormFac+";"
				if(stringmatch(FormFac, "*User*"))
					SVAR U1FormFac=$("root:Packages:IR2L_NLSQF:FFUserFFformula_pop"+num2str(i))
					ListOfParametersStr+="FFUserFFformula_pop"+num2str(i)+"="+U1FormFac+";"
					SVAR U2FormFac=$("root:Packages:IR2L_NLSQF:FFUserVolumeFormula_pop"+num2str(i))
					ListOfParametersStr+="FFUserVolumeFormula_pop"+num2str(i)+"="+U2FormFac+";"
				else
					ListOfParametersStr+="FFUserFFformula_pop"+num2str(i)+"= none ;"
					ListOfParametersStr+="FFUserVolumeFormula_pop"+num2str(i)+"= none ;"
				endif

					NVAR FFParam1= $("root:Packages:IR2L_NLSQF:FormFactor_Param1_pop"+num2str(i))
					ListOfParameters+="FormFactor_Param1_pop"+num2str(i)+"="+num2str(FFParam1)+";"
					NVAR FFParam2= $("root:Packages:IR2L_NLSQF:FormFactor_Param2_pop"+num2str(i))
					ListOfParameters+="FormFactor_Param2_pop"+num2str(i)+"="+num2str(FFParam1)+";"
					NVAR FFParam3= $("root:Packages:IR2L_NLSQF:FormFactor_Param3_pop"+num2str(i))
					ListOfParameters+="FormFactor_Param3_pop"+num2str(i)+"="+num2str(FFParam1)+";"
					NVAR FFParam4= $("root:Packages:IR2L_NLSQF:FormFactor_Param4_pop"+num2str(i))
					ListOfParameters+="FormFactor_Param4_pop"+num2str(i)+"="+num2str(FFParam1)+";"
					NVAR FFParam5= $("root:Packages:IR2L_NLSQF:FormFactor_Param5_pop"+num2str(i))
					ListOfParameters+="FormFactor_Param5_pop"+num2str(i)+"="+num2str(FFParam1)+";"


			
//				NVAR UseInterference = $("root:Packages:IR2L_NLSQF:UseInterference_pop"+num2str(i))			
				SVAR StrFac=$("root:Packages:IR2L_NLSQF:StructureFactor_pop"+num2str(i))
				ListOfParametersStr+="StructureFactor_pop"+num2str(i)+"="+StrFac+";"
				if(!stringmatch(StrFac, "*Dilute system*"))
					NVAR StructureParam1= $("root:Packages:IR2L_NLSQF:StructureParam1_pop"+num2str(i))
					ListOfParameters+="StructureParam1_pop"+num2str(i)+"="+num2str(StructureParam1)+";"
					NVAR StructureParam2= $("root:Packages:IR2L_NLSQF:StructureParam2_pop"+num2str(i))
					ListOfParameters+="StructureParam2_pop"+num2str(i)+"="+num2str(StructureParam2)+";"
					NVAR StructureParam3= $("root:Packages:IR2L_NLSQF:StructureParam3_pop"+num2str(i))
					ListOfParameters+="StructureParam3_pop"+num2str(i)+"="+num2str(StructureParam3)+";"
					NVAR StructureParam4= $("root:Packages:IR2L_NLSQF:StructureParam4_pop"+num2str(i))
					ListOfParameters+="StructureParam4_pop"+num2str(i)+"="+num2str(StructureParam4)+";"
					NVAR StructureParam5= $("root:Packages:IR2L_NLSQF:StructureParam5_pop"+num2str(i))
					ListOfParameters+="StructureParam5_pop"+num2str(i)+"="+num2str(StructureParam5)+";"
					NVAR StructureParam6= $("root:Packages:IR2L_NLSQF:StructureParam6_pop"+num2str(i))
					ListOfParameters+="StructureParam6_pop"+num2str(i)+"="+num2str(StructureParam6)+";"
				else
					ListOfParameters+="StructureParam1_pop"+num2str(i)+"=0;"
					ListOfParameters+="StructureParam2_pop"+num2str(i)+"=0;"
					ListOfParameters+="StructureParam3_pop"+num2str(i)+"=0;"
					ListOfParameters+="StructureParam4_pop"+num2str(i)+"=0;"
					ListOfParameters+="StructureParam5_pop"+num2str(i)+"=0;"
					ListOfParameters+="StructureParam6_pop"+num2str(i)+"=0;"
				endif
		else	//this population does not exist, but we need to set these to 0 to have the line in the waves if needed...
		
				ListOfPopulationVariables="Volume;Mean;Mode;Median;FWHM;"	
				for(k=0;k<itemsInList(ListOfPopulationVariables);k+=1)	
					NVAR testVar = $(StringFromList(k,ListOfPopulationVariables)+"_pop"+num2str(i))
					ListOfParameters+=StringFromList(k,ListOfPopulationVariables)+"_pop"+num2str(i)+"=0;"
				endfor
			
				ListOfParametersStr+="FormFactor_pop"+num2str(i)+"= none ;"
				ListOfParametersStr+="FFUserFFformula_pop"+num2str(i)+"= none ;"
				ListOfParametersStr+="FFUserVolumeFormula_pop"+num2str(i)+"= none ;"
				ListOfParameters+="FormFactor_Param1_pop"+num2str(i)+"=0;"
				ListOfParameters+="FormFactor_Param2_pop"+num2str(i)+"=0;"
				ListOfParameters+="FormFactor_Param3_pop"+num2str(i)+"=0;"
				ListOfParameters+="FormFactor_Param4_pop"+num2str(i)+"=0;"
				ListOfParameters+="FormFactor_Param5_pop"+num2str(i)+"=0;"


				SVAR PopSizeDistShape = $("root:Packages:IR2L_NLSQF:PopSizeDistShape_pop"+num2str(i))		
				ListOfParametersStr+="DistributionShape_pop"+num2str(i)+"=none;"
				ListOfParameters+="GaussMean_pop"+num2str(i)+"=0;"
				ListOfParameters+="GaussWidth_pop"+num2str(i)+"=0;"
				ListOfParameters+="LSWLocation_pop"+num2str(i)+"=0;"				
				ListOfParameters+="LogNormalMin_pop"+num2str(i)+"=0;"
				ListOfParameters+="LogNormalMean_pop"+num2str(i)+"=0;"
				ListOfParameters+="LogNormalSdeviation_pop"+num2str(i)+"=0;"
				ListOfParameters+="Contrast_pop"+num2str(i)+"=0;"
				ListOfPopulationVariables="Contrast_set1;Contrast_set2;Contrast_set3;Contrast_set4;Contrast_set5;Contrast_set6;Contrast_set7;Contrast_set8;Contrast_set9;Contrast_set10;"
				for(k=0;k<itemsInList(ListOfPopulationVariables);k+=1)	
					NVAR testVar = $(StringFromList(k,ListOfPopulationVariables)+"_pop"+num2str(i))
					ListOfParameters+=StringFromList(k,ListOfPopulationVariables)+"_pop"+num2str(i)+"=0;"
				endfor			
				ListOfParametersStr+="StructureFactor_pop"+num2str(i)+"="+"Dilute system"+";"
				ListOfParameters+="StructureParam1_pop"+num2str(i)+"=0;"
				ListOfParameters+="StructureParam2_pop"+num2str(i)+"=0;"
				ListOfParameters+="StructureParam3_pop"+num2str(i)+"=0;"
				ListOfParameters+="StructureParam4_pop"+num2str(i)+"=0;"
				ListOfParameters+="StructureParam5_pop"+num2str(i)+"=0;"
				ListOfParameters+="StructureParam6_pop"+num2str(i)+"=0;"
		endif
	endfor
	IR2L_SaveResInWavesIndivDtSet2(ListOfParameters,ListOfParametersStr,NewFolderName )
	
	setDataFolder oldDF

end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_SaveResInWavesIndivDtSet2(ListOfParameters,ListOfParametersStr,NewFolderName )
	String ListOfParameters,ListOfParametersStr,NewFolderName
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF
	string NewFolderNameClean = CleanupName(NewFolderName, 1 )
	setDatafolder root:
	NewDataFolder/O/S $(NewFolderNameClean)
	variable i
	string NewWvName
	string NewStrVal
	variable NewVarVal
	for(i=0;i<ItemsInList(ListOfParametersStr);i+=1)
		NewWvName = StringFromList(0,StringFromList(i,ListOfParametersStr,";"),"=")
		NewStrVal = StringFromList(1,StringFromList(i,ListOfParametersStr,";"),"=")
		IR2L_SaveResInWavesIndivDtSet3(NewWvName,0,NewStrVal)
	endfor
	for(i=0;i<ItemsInList(ListOfParameters);i+=1)
		NewWvName = StringFromList(0,StringFromList(i,ListOfParameters,";"),"=")
		NewVarVal = str2num(StringFromList(1,StringFromList(i,ListOfParameters,";"),"="))
		IR2L_SaveResInWavesIndivDtSet3(NewWvName,NewVarVal,"")
	endfor
	setDataFolder oldDF

end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2L_SaveResInWavesIndivDtSet3(WvName,NewPointVal,NewPointStr)
	string WvName,NewPointStr
	variable NewPointVal
	
	if(strlen(NewPointStr)>0)
		Wave/Z/T WvStr=$(WvName)
		if(!WaveExists(WvStr))
			make/O/N=0/T $(WvName)
		endif
		Wave/T WvStr=$(WvName)
		redimension/N=(numpnts(WvStr)+1) WvStr
		WvStr[numpnts(WvStr)] = NewPointStr
	else
		Wave/Z WvNum=$(WvName)
		if(!WaveExists(WvNum))
			make/O/N=0 $(WvName)
		endif
		Wave WvNum=$(WvName)
		redimension/N=(numpnts(WvNum)+1) WvNum
		WvNum[numpnts(WvNum)] = NewPointVal
	endif

end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function Ir2L_WriteOneFitVarPop(VarName, which)
	String VarName
	variable which
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF
	
	NVAR testVar = $(VarName+"_pop"+num2str(which))
	NVAR FittestVar = $(VarName+"Fit_pop"+num2str(which))
	NVAR MintestVar = $(VarName+"Min_pop"+num2str(which))
	NVAR MaxtestVar = $(VarName+"Max_pop"+num2str(which))
	if(FittestVar)
		IR1L_AppendAnyText(VarName+"_pop"+num2str(which)+"\tFitted\tValue="+num2str(testVar)+"\tMin="+num2str(MintestVar)+"\tMax="+num2str(MaxtestVar))
	else
		IR1L_AppendAnyText(VarName+"_pop"+num2str(which)+"\tFixed\tValue="+num2str(testVar))
	endif
	setDataFolder OldDf
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR2L_RecordModelResults(which)
	variable which
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF

	string ListOfVariables, ListOfDataVariables, ListOfPopulationVariables
	string ListOfStrings, ListOfDataStrings, ListOfPopulationsStrings
	string ListOfParameters, ListOfParametersStr
	ListOfParametersStr = ""
	ListOfParameters=""
	variable i=which 
	variable k
	NVAR UseThePop = $("root:Packages:IR2L_NLSQF:UseThePop_pop"+num2str(which))
		
	if(UseThePop)
		IR1L_AppendAnyText("Used population "+num2str(i)+",  listing of parameters:\r")
			ListOfPopulationVariables="Volume;Mean;Mode;Median;FWHM;"	
			for(k=0;k<itemsInList(ListOfPopulationVariables);k+=1)	
				NVAR testVar = $(StringFromList(k,ListOfPopulationVariables)+"_pop"+num2str(i))
				IR1L_AppendAnyText(StringFromList(k,ListOfPopulationVariables)+"_pop"+num2str(i)+"\t=\t"+num2str(testVar))
			endfor
		IR1L_AppendAnyText(" ")
			
			SVAR PopSizeDistShape = $("root:Packages:IR2L_NLSQF:PopSizeDistShape_pop"+num2str(i))		
				if(stringmatch(PopSizeDistShape, "Gauss") )
					IR1L_AppendAnyText("DistributionShape_pop"+num2str(i)+"\t=\tGauss;")
					//NVAR GMeanSize =  $("root:Packages:IR2L_NLSQF:GMeanSize_pop"+num2str(i))	
					//IR1L_AppendAnyText("GaussMean_pop"+num2str(i)+"\t=\t"+num2str(GMeanSize))
					Ir2L_WriteOneFitVarPop("GMeanSize", i)
					//NVAR GWidth =  $("root:Packages:IR2L_NLSQF:GWidth_pop"+num2str(i))	
					//IR1L_AppendAnyText("GaussWidth_pop"+num2str(i)+"\t=\t"+num2str(GWidth))
					Ir2L_WriteOneFitVarPop("GWidth", i)
				elseif(stringmatch(PopSizeDistShape, "LogNormal" ))
					IR1L_AppendAnyText("DistributionShape_pop"+num2str(i)+"\t=\tLogNormal;")
					//NVAR LNMinSize =  $("root:Packages:IR2L_NLSQF:LNMinSize_pop"+num2str(i))	
					Ir2L_WriteOneFitVarPop("LNMinSize", i)
					//IR1L_AppendAnyText("LogNormalMin_pop"+num2str(i)+"\t=\t"+num2str(LNMinSize))
					//NVAR LNMeanSize =  $("root:Packages:IR2L_NLSQF:LNMeanSize_pop"+num2str(i))	
					Ir2L_WriteOneFitVarPop("LNMeanSize", i)
					//IR1L_AppendAnyText("LogNormalMean_pop"+num2str(i)+"\t=\t"+num2str(LNMeanSize))
					//NVAR LNSdeviation =  $("root:Packages:IR2L_NLSQF:LNSdeviation_pop"+num2str(i))	
					//IR1L_AppendAnyText("LogNormalSdeviation_pop"+num2str(i)+"t=\t"+num2str(LNSdeviation))
					Ir2L_WriteOneFitVarPop("LNSdeviation", i)
				else //LSW
					IR1L_AppendAnyText("DistributionShape_pop"+num2str(i)+"=LSW;")
					//NVAR LSWLocation =  $("root:Packages:IR2L_NLSQF:LSWLocation_pop"+num2str(i))	
					//IR1L_AppendAnyText("LSWLocation_pop"+num2str(i)+"\t=\t"+num2str(LSWLocation))				
					Ir2L_WriteOneFitVarPop("LSWLocation", i)
				endif
					
				NVAR VaryContrast=root:Packages:IR2L_NLSQF:SameContrastForDataSets
				NVAR UseMultipleData=root:Packages:IR2L_NLSQF:MultipleInputData
				if(VaryContrast && UseMultipleData)
					IR1L_AppendAnyText("Contrast varies for different populations")
					ListOfPopulationVariables="Contrast_set1;Contrast_set2;Contrast_set3;Contrast_set4;Contrast_set5;Contrast_set6;Contrast_set7;Contrast_set8;Contrast_set9;Contrast_set10;"
					for(k=0;k<itemsInList(ListOfPopulationVariables);k+=1)	
						NVAR testVar = $(StringFromList(k,ListOfPopulationVariables)+"_pop"+num2str(i))
						IR1L_AppendAnyText(StringFromList(k,ListOfPopulationVariables)+"_pop"+num2str(i)+"\t=\t"+num2str(testVar))
					endfor
				else		//same contrast for all sets... 
					NVAR Contrast = $("root:Packages:IR2L_NLSQF:Contrast_pop"+num2str(i))
					IR1L_AppendAnyText("Contrast_pop"+num2str(i)+"\t=\t"+num2str(Contrast))
				endif
				IR1L_AppendAnyText(" ")
				// For factor parameters.... messy... 
				SVAR FormFac=$("root:Packages:IR2L_NLSQF:FormFactor_pop"+num2str(i))
				IR1L_AppendAnyText("FormFactor_pop"+num2str(i)+"\t=\t"+FormFac)
				IR1L_AppendAnyText("Note, not all FF parameters are applicable, check the FF description")
				if(stringmatch(FormFac, "*User*"))
					SVAR U1FormFac=$("root:Packages:IR2L_NLSQF:FFUserFFformula_pop"+num2str(i))
					IR1L_AppendAnyText("FFUserFFformula_pop"+num2str(i)+"\t=\t"+U1FormFac)
					SVAR U2FormFac=$("root:Packages:IR2L_NLSQF:FFUserVolumeFormula_pop"+num2str(i))
					IR1L_AppendAnyText("FFUserVolumeFormula_pop"+num2str(i)+"\t=\t"+U2FormFac)
				endif
//					NVAR FFParam1= $("root:Packages:IR2L_NLSQF:FormFactor_Param1_pop"+num2str(i))
//					IR1L_AppendAnyText("FormFactor_Param1_pop"+num2str(i)+"="+num2str(FFParam1))
//					NVAR FFParam2= $("root:Packages:IR2L_NLSQF:FormFactor_Param2_pop"+num2str(i))
//					IR1L_AppendAnyText("FormFactor_Param2_pop"+num2str(i)+"="+num2str(FFParam1))
//					NVAR FFParam3= $("root:Packages:IR2L_NLSQF:FormFactor_Param3_pop"+num2str(i))
//					IR1L_AppendAnyText("FormFactor_Param3_pop"+num2str(i)+"="+num2str(FFParam1))
//					NVAR FFParam4= $("root:Packages:IR2L_NLSQF:FormFactor_Param4_pop"+num2str(i))
//					IR1L_AppendAnyText("FormFactor_Param4_pop"+num2str(i)+"="+num2str(FFParam1))
//					NVAR FFParam5= $("root:Packages:IR2L_NLSQF:FormFactor_Param5_pop"+num2str(i))
//					IR1L_AppendAnyText("FormFactor_Param5_pop"+num2str(i)+"="+num2str(FFParam1))
					Ir2L_WriteOneFitVarPop("FormFactor_Param1", i)
					Ir2L_WriteOneFitVarPop("FormFactor_Param2", i)
					Ir2L_WriteOneFitVarPop("FormFactor_Param3", i)
					Ir2L_WriteOneFitVarPop("FormFactor_Param4", i)
					Ir2L_WriteOneFitVarPop("FormFactor_Param5", i)


				IR1L_AppendAnyText(" ")
			
//				NVAR UseInterference = $("root:Packages:IR2L_NLSQF:UseInterference_pop"+num2str(i))			
				SVAR StrFac=$("root:Packages:IR2L_NLSQF:StructureFactor_pop"+num2str(i))
				IR1L_AppendAnyText("StructureFactor_pop"+num2str(i)+"="+StrFac)
				if(!stringmatch(StrFac, "*Dilute system*"))
//					NVAR StructureParam1= $("root:Packages:IR2L_NLSQF:StructureParam1_pop"+num2str(i))
//					IR1L_AppendAnyText("StructureParam1_pop"+num2str(i)+"="+num2str(StructureParam1))
//					NVAR StructureParam2= $("root:Packages:IR2L_NLSQF:StructureParam2_pop"+num2str(i))
//					IR1L_AppendAnyText("StructureParam2_pop"+num2str(i)+"="+num2str(StructureParam2))
//					NVAR StructureParam3= $("root:Packages:IR2L_NLSQF:StructureParam3_pop"+num2str(i))
//					IR1L_AppendAnyText("StructureParam3_pop"+num2str(i)+"="+num2str(StructureParam3))
//					NVAR StructureParam4= $("root:Packages:IR2L_NLSQF:StructureParam4_pop"+num2str(i))
//					IR1L_AppendAnyText("StructureParam4_pop"+num2str(i)+"="+num2str(StructureParam4))
//					NVAR StructureParam5= $("root:Packages:IR2L_NLSQF:StructureParam5_pop"+num2str(i))
//					IR1L_AppendAnyText("StructureParam5_pop"+num2str(i)+"="+num2str(StructureParam5))
//					NVAR StructureParam6= $("root:Packages:IR2L_NLSQF:StructureParam6_pop"+num2str(i))
//					IR1L_AppendAnyText("StructureParam6_pop"+num2str(i)+"="+num2str(StructureParam6))
					Ir2L_WriteOneFitVarPop("StructureParam1", i)
					Ir2L_WriteOneFitVarPop("StructureParam2", i)
					Ir2L_WriteOneFitVarPop("StructureParam3", i)
					Ir2L_WriteOneFitVarPop("StructureParam4", i)
					Ir2L_WriteOneFitVarPop("StructureParam5", i)
					Ir2L_WriteOneFitVarPop("StructureParam6", i)
				else
					IR1L_AppendAnyText("Dilute system, no Structure factor parameters applicable")
				endif
			IR1L_AppendAnyText("  ")
		endif

	setDataFolder OldDf	
end

//*****************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2L_RecordDataResults(which)
	variable which
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF
	
	string ListOfVariables, ListOfDataVariables, ListOfPopulationVariables
	string ListOfStrings, ListOfDataStrings, ListOfPopulationsStrings
	string ListOfParameters, ListOfParametersStr
	ListOfParametersStr = ""
	ListOfParameters=""
	variable i, j 
	
	ListOfDataStrings ="IntensityDataName;QvecDataName;ErrorDataName;UserDataSetName;"
	for(i=0;i<itemsInList(ListOfDataStrings);i+=1)	
		SVAR testStr = $(StringFromList(i,ListOfDataStrings)+"_set"+num2str(which))
		IR1L_AppendAnyText(StringFromList(i,ListOfDataStrings)+"_set"+num2str(which)+"\t=\t"+testStr)
	endfor	
	ListOfDataVariables="DataScalingFactor;ErrorScalingFactor;Qmin;Qmax;"
	for(i=0;i<itemsInList(ListOfDataVariables);i+=1)	
		NVAR testVar = $(StringFromList(i,ListOfDataVariables)+"_set"+num2str(which))
		IR1L_AppendAnyText(StringFromList(i,ListOfDataVariables)+"_set"+num2str(which)+"\t=\t"+num2str(testVar))
	endfor	
	Ir2L_WriteOneFitVar("Background", which)
	setDataFolder OldDf
end
//*****************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function Ir2L_WriteOneFitVar(VarName, which)
	String VarName
	variable which
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:IR2L_NLSQF
	NVAR testVar = $(VarName+"_set"+num2str(which))
	NVAR FittestVar = $(VarName+"Fit_set"+num2str(which))
	NVAR MintestVar = $(VarName+"Min_set"+num2str(which))
	NVAR MaxtestVar = $(VarName+"Max_set"+num2str(which))
	if(FittestVar)
		IR1L_AppendAnyText(VarName+"_set"+num2str(which)+"\tFitted\tValue="+num2str(testVar)+"\tMin="+num2str(MintestVar)+"\tMax="+num2str(MaxtestVar))
	else
		IR1L_AppendAnyText(VarName+"_set"+num2str(which)+"\tFixed\tValue="+num2str(testVar))
	endif
	setDataFolder OldDf
end
//*****************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************
//*****************************************************************************************************************
