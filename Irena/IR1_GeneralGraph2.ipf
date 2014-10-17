#pragma rtGlobals=1		// Use modern global access method.
#include "IR1_Loader"
#pragma version=2.01


//2.01 8/23/2010 fixed bug when if the General graph was not the top one, some formating was applied to the top graph. Now general graph is made top before formating it. 

	//this string contains formating for the data
//	SVAR ListOfGraphFormating
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//this creates graph, adds data into the graph, synchronizes the formating string and contrrol
//variables and formats the graph
Function IR1P_CreateGraph()
	IR1P_CheckForDataIntegrity()
	Execute ("IR1P_makeGraphWindow()")
	IR1P_CreateDataToPlot()
	IR1P_AddDataToGenGraph()
	IR1P_SynchronizeListAndVars()
	IR1P_UpdateGenGraph()
end


Function IR1P_CheckForDataIntegrity()

	SVAR ListOfDataOrgWvNames=root:Packages:GeneralplottingTool:ListOfDataOrgWvNames
	SVAR ListOfDataWaveNames=root:Packages:GeneralplottingTool:ListOfDataWaveNames
	SVAR ListOfDataFolderNames=root:Packages:GeneralplottingTool:ListOfDataFolderNames
	

	variable i, imax, IsOK, j
	string checkDf, checkEwave
	isOK=1
	imax=ItemsInList(ListOfDataFolderNames)
	For(i=0;i<imax;i+=1)
		checkDF=StringFromList(i,ListOfDataFolderNames)
		j=itemsInList(checkDF,":")
		checkDf=RemoveFromList(StringFromList(j-1,checkDF,":"),checkDf,":")
		if (!DataFolderExists(checkDF))
			IsOk=0
		endif
		Wave/Z TestInt=$(StringByKey("IntWave"+num2str(i),ListOfDataOrgWvNames,"=",";"))
		Wave/Z TestQ=$(StringByKey("QWave"+num2str(i),ListOfDataOrgWvNames,"=",";"))
		Wave/Z TestE=$(StringByKey("EWave"+num2str(i),ListOfDataOrgWvNames,"=",";"))
		checkEwave=StringByKey("EWave"+num2str(i),ListOfDataOrgWvNames,"=",";")
		j = itemsInList(StringByKey("IntWave"+num2str(i),ListOfDataOrgWvNames,"=",";"),":")
		checkEwave=StringFromList(j-1,checkEWave)
		if (strlen(checkEwave)>0)		
			if(!WaveExists(TestInt)||!WaveExists(TestQ)||!WaveExists(TestE))
				IsOk=0
			endif
		else
			if(!WaveExists(TestInt)||!WaveExists(TestQ))
				IsOk=0
			endif
		endif
	endfor
	if (!IsOK)
		Abort "Data integrity compromised, restart the tool and do not modify data while this tool si running"
	endif
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//this is added into selection in Marquee.
//if run, sets limits to marquee selection and switches into manual mode for axis range
Function ZoomAndSetLimits(): GraphMarquee
	//this will zoom graph and set limits to the appropriate numbers
	SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating
	GetMarquee/K left, bottom
	ListOfGraphFormating=ReplaceStringByKey("Axis left auto",ListOfGraphFormating,"0","=" )
	ListOfGraphFormating=ReplaceStringByKey("Axis bottom auto",ListOfGraphFormating,"0","=" )
	ListOfGraphFormating=ReplaceStringByKey("Axis left min",ListOfGraphFormating,num2str(V_bottom),"=" )
	ListOfGraphFormating=ReplaceStringByKey("Axis left max",ListOfGraphFormating,num2str(V_top),"=" )
	ListOfGraphFormating=ReplaceStringByKey("Axis bottom min",ListOfGraphFormating,num2str(V_left),"=" )
	ListOfGraphFormating=ReplaceStringByKey("Axis bottom max",ListOfGraphFormating,num2str(V_right),"=" )
	IR1P_SynchronizeListAndVars()
	IR1P_UpdateGenGraph()
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//makes graph 
Proc  IR1P_makeGraphWindow() 
	DoWindow GeneralGraph
	if (V_Flag)
		DoWindow/K generalGraph
	endif
	PauseUpdate; Silent 1		// building window...
	Display /K=1 /W=(285,37.25,756.75,340.25) as "GeneralGraph"
	DoWindow/C GeneralGraph
	showInfo
EndMacro
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//adds data into general graph
Function IR1P_AddDataToGenGraph()

	
	SVAR ListOfDataFolderNames=root:Packages:GeneralplottingTool:ListOfDataFolderNames
	SVAR ListOfDataWaveNames=root:Packages:GeneralplottingTool:ListOfDataWaveNames
	variable NumberOfWaves,i
	
	string ListOfWaves=TraceNameList("GeneralGraph", ",", 1 )		//list of waves in the graph
	ListOfWaves=TraceNameList("GeneralGraph", ",", 1 )	
	For(i=(ItemsInList(ListOfWaves,",")-1);i>=0;i-=1)
		RemoveFromGraph/W=GeneralGraph $(stringFromList(i,ListOfWaves,","))
	endfor
	
	NumberOfWaves=ItemsInList(ListOfDataFolderNames)
	For(i=0;i<NumberOfWaves;i+=1)
		Wave IntWv=$(StringByKey("IntWave"+num2str(i), ListOfDataWaveNames  , "="))
		Wave QWv=$(StringByKey("QWave"+num2str(i), ListOfDataWaveNames  , "="))
		Wave/Z EWv=$(StringByKey("EWave"+num2str(i), ListOfDataWaveNames  , "="))
		
		AppendToGraph/W=GeneralGraph IntWv vs QWv
	endfor
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//stores pointers to data for the graph from other pieces 
Function IR1P_RecordDataForGraph()
	//here we need to create record of data for plotting in the graph

	setDataFolder root:Packages:GeneralplottingTool
	//these should by now exist, since the previous function checked for their existence...
		SVAR DFloc=root:Packages:GeneralplottingTool:DataFolderName
		SVAR DFInt=root:Packages:GeneralplottingTool:IntensityWaveName
		SVAR DFQ=root:Packages:GeneralplottingTool:QWaveName
		SVAR DFE=root:Packages:GeneralplottingTool:ErrorWaveName
		
		//these strings have to checked and fixed for lieral names, or the code later does not work
		DFInt= possiblyQuoteName(DfInt)
		DFQ= possiblyQuoteName(DfQ)
		DFE= possiblyQuoteName(DfE)
	
	SVAR ListOfDataFolderNames=root:Packages:GeneralplottingTool:ListOfDataFolderNames
	SVAR ListOfDataOrgWvNames=root:Packages:GeneralplottingTool:ListOfDataOrgWvNames
//	SVAR ListOfDataFormating=root:Packages:GeneralplottingTool:ListOfDataFormating
	
	variable NumberOfDataPresent,i
	NumberOfDataPresent=ItemsInList(ListOfDataFolderNames)
	For(i=0;i<NumberOfDataPresent;i+=1)
		if(cmpstr(stringfromList(i,ListOfDataFolderNames),DFloc+DFInt)==0)		//same data we are trying to add are present already....
			Abort "These data are already present, cannot display same data twice"
		endif
	endfor

	//OK, these data are not yet in the list, so let's add them in the list as necessary
	
	ListOfDataFolderNames+=DFloc+DFInt+";"
	ListOfDataOrgWvNames=ReplaceStringByKey("IntWave"+num2str(NumberOfDataPresent), ListOfDataOrgWvNames, DFloc+DFInt , "=")
	ListOfDataOrgWvNames=ReplaceStringByKey("QWave"+num2str(NumberOfDataPresent), ListOfDataOrgWvNames, DFloc+DFQ , "=")
	if (strlen(DFE)>1)
		ListOfDataOrgWvNames=ReplaceStringByKey("EWave"+num2str(NumberOfDataPresent), ListOfDataOrgWvNames, DFloc+DFE , "=")
	else
		ListOfDataOrgWvNames=ReplaceStringByKey("EWave"+num2str(NumberOfDataPresent), ListOfDataOrgWvNames, "---" , "=")
	endif
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//create data if user wants to plot different type of data than directly int, q and error
Function IR1P_CreateDataToPlot()
	//here we create data to plot, if they do not exist and move appropriate names from ListOfDataOrgWvNames into ListOfDataWaveNames

	SVAR ListOfDataOrgWvNames=root:Packages:GeneralplottingTool:ListOfDataOrgWvNames
	SVAR ListOfDataWaveNames=root:Packages:GeneralplottingTool:ListOfDataWaveNames
	//this string contains formating for the data
	SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating
	//this list cointains follwing list
	//DataX: Q, Q^2, Q^3, Q^4
	//DataY and DataE: I, I^2, I^3, I^4, I*Q^4, I*Q^2, I*Q, ln(I*Q^2), ln(I*Q)
	//here we need to create (if do not exist) these data and write the appropriate names into the appropriate list
	//ListOfDataOrgWvNames contains full path to original waves
	//ListOfDataWaveNames contains full path to ploted waves
	//ListOfGraphFormating contains info, which data should be ploted...
	
	variable i, imax=ItemsInList(ListOfDataOrgWvNames)/3		//there should be always 3 items in each list per data set ploted
	string DataX=stringByKey("DataX", ListOfGraphFormating,"=")
	string DataY=stringByKey("DataY", ListOfGraphFormating,"=")
	string DataE=stringByKey("DataE", ListOfGraphFormating,"=")
	string tempFullName, tempShortName, tempPath, tempQwaveName
	
	For (i=0;i<imax;i+=1)
		//and here we need to take the data and make them as needed
	//	1. Intensity
		tempFullName=stringByKey("IntWave"+num2str(i),ListOfDataOrgWvNames,"=")
		tempQwaveName=stringByKey("QWave"+num2str(i),ListOfDataOrgWvNames,"=")
		tempShortName=StringFromList(itemsInList(tempFullName,":")-1, tempFullName , ":")
		tempPath=tempFullName[0,(strlen(tempFullName)-strlen(tempShortName)-1)]
		Wave IntOrg=$(tempFullName)
		if (cmpstr(DataY,"Y")==0)		//straight, nothing to do really
			ListOfDataWaveNames=replaceStringByKey("IntWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")
		elseif(cmpstr(DataY,"Y^2")==0)		//Want to plot I^2, create data and name...
			tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
			tempShortName=tempShortName[0,26]	+ "_2"			//Igor names are limited to 30 characters
			tempShortName = possiblyQuoteName(tempShortName)
			tempFullName=tempPath+tempShortName
			Duplicate/o IntOrg, $tempFullName
			Wave IntNew=$(tempFullName)
			IntNew=IntNew^2
			ListOfDataWaveNames=replaceStringByKey("IntWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
		elseif(cmpstr(DataY,"Y^3")==0)		//Want to plot I^2, create data and name...
			tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
			tempShortName=tempShortName[0,26]	+ "_3"			//Igor names are limited to 30 characters
			tempShortName = possiblyQuoteName(tempShortName)
			tempFullName=tempPath+tempShortName
			Duplicate/o IntOrg, $tempFullName
			Wave IntNew=$(tempFullName)
			IntNew=IntNew^3
			ListOfDataWaveNames=replaceStringByKey("IntWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
		elseif(cmpstr(DataY,"Y^4")==0)		//Want to plot I^2, create data and name...
			tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
			tempShortName=tempShortName[0,26]	+ "_4"			//Igor names are limited to 30 characters
			tempShortName = possiblyQuoteName(tempShortName)
			tempFullName=tempPath+tempShortName
			Duplicate/o IntOrg, $tempFullName
			Wave IntNew=$(tempFullName)
			IntNew=IntNew^4
			ListOfDataWaveNames=replaceStringByKey("IntWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
		elseif(cmpstr(DataY,"1/Y")==0)		//Want to plot I^2, create data and name...
			tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
			tempShortName=tempShortName[0,26]	+ "_r1"			//Igor names are limited to 30 characters
			tempShortName = possiblyQuoteName(tempShortName)
			tempFullName=tempPath+tempShortName
			Duplicate/o IntOrg, $tempFullName
			Wave IntNew=$(tempFullName)
			IntNew=1/IntNew
			ListOfDataWaveNames=replaceStringByKey("IntWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
		elseif(cmpstr(DataY,"ln(Y)")==0)		//Want to plot ln(I), create data and name...
			tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
			tempShortName=tempShortName[0,26]	+ "_lny"			//Igor names are limited to 30 characters
			tempShortName = possiblyQuoteName(tempShortName)
			tempFullName=tempPath+tempShortName
			Duplicate/o IntOrg, $tempFullName
			Wave IntNew=$(tempFullName)
			IntNew=ln(IntNew)
			ListOfDataWaveNames=replaceStringByKey("IntWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
		elseif(cmpstr(DataY,"sqrt(1/Y)")==0)		//Want to plot I^2, create data and name...
			tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
			tempShortName=tempShortName[0,26]	+ "_sr1"			//Igor names are limited to 30 characters
			tempShortName = possiblyQuoteName(tempShortName)
			tempFullName=tempPath+tempShortName
			Duplicate/o IntOrg, $tempFullName
			Wave IntNew=$(tempFullName)
			IntNew=sqrt(1/IntNew)
			ListOfDataWaveNames=replaceStringByKey("IntWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
		elseif(cmpstr(DataY,"ln(Y*X^2)")==0)		//Want to plot I^2, create data and name...
			tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
			tempShortName=tempShortName[0,26]	+ "_Gu"			//Igor names are limited to 30 characters
			tempShortName = possiblyQuoteName(tempShortName)
			tempFullName=tempPath+tempShortName
			Duplicate/o IntOrg, $tempFullName
			Wave IntNew=$(tempFullName)
			Wave QWvOld=$(tempQwaveName)
			IntNew=ln(QWvOld^2*IntNew)
			ListOfDataWaveNames=replaceStringByKey("IntWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
		elseif(cmpstr(DataY,"ln(Y*X)")==0)		//Want to plot I^2, create data and name...
			tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
			tempShortName=tempShortName[0,26]	+ "_LIQ"			//Igor names are limited to 30 characters
			tempShortName = possiblyQuoteName(tempShortName)
			tempFullName=tempPath+tempShortName
			Duplicate/o IntOrg, $tempFullName
			Wave IntNew=$(tempFullName)
			Wave QWvOld=$(tempQwaveName)
			IntNew=ln(QWvOld*IntNew)
			ListOfDataWaveNames=replaceStringByKey("IntWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
		elseif(cmpstr(DataY,"Y*X^2")==0)		//Want to plot I^2, create data and name...
			tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
			tempShortName=tempShortName[0,26]	+ "_IQ2"			//Igor names are limited to 30 characters
			tempShortName = possiblyQuoteName(tempShortName)
			tempFullName=tempPath+tempShortName
			Duplicate/o IntOrg, $tempFullName
			Wave IntNew=$(tempFullName)
			Wave QWvOld=$(tempQwaveName)
			IntNew=IntNew * QWvOld^2
			ListOfDataWaveNames=replaceStringByKey("IntWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
		elseif(cmpstr(DataY,"Y*X^4")==0)		//Want to plot I^2, create data and name...
				tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
			tempShortName=tempShortName[0,26]	+ "_IQ4"			//Igor names are limited to 30 characters
			tempShortName = possiblyQuoteName(tempShortName)
			tempFullName=tempPath+tempShortName
			Duplicate/o IntOrg, $tempFullName
			Wave IntNew=$(tempFullName)
			Wave QWvOld=$(tempQwaveName)
			IntNew=IntNew*QWvOld^4
			ListOfDataWaveNames=replaceStringByKey("IntWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
		else
			ListOfDataWaveNames=replaceStringByKey("IntWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")
		endif
		
	//	2. Q vector (X axis)
		tempFullName=stringByKey("QWave"+num2str(i),ListOfDataOrgWvNames,"=")
		tempShortName=StringFromList(itemsInList(tempFullName,":")-1, tempFullName , ":")
		tempPath=tempFullName[0,(strlen(tempFullName)-strlen(tempShortName)-1)]
		Wave QOrg=$(tempFullName)
		if (cmpstr(DataX,"X")==0)		//straight, nothing to do really
			ListOfDataWaveNames=replaceStringByKey("QWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")
		elseif(cmpstr(DataX,"X^2")==0)		//Want to plot I^2, create data and name...
			tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
			tempShortName=tempShortName[0,26]	+ "_2"			//Igor names are limited to 30 characters
			tempShortName = possiblyQuoteName(tempShortName)
			tempFullName=tempPath+tempShortName
			Duplicate/o QOrg, $tempFullName
			Wave QNew=$(tempFullName)
			QNew=QNew^2
			ListOfDataWaveNames=replaceStringByKey("QWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
		elseif(cmpstr(DataX,"X^3")==0)		//Want to plot I^3, create data and name...
			tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
			tempShortName=tempShortName[0,26]	+ "_3"			//Igor names are limited to 30 characters
			tempShortName = possiblyQuoteName(tempShortName)
			tempFullName=tempPath+tempShortName
			Duplicate/o QOrg, $tempFullName
			Wave QNew=$(tempFullName)
			QNew=QNew^3
			ListOfDataWaveNames=replaceStringByKey("QWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
		elseif(cmpstr(DataX,"X^4")==0)		//Want to plot I^4, create data and name...
			tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
			tempShortName=tempShortName[0,26]	+ "_4"			//Igor names are limited to 30 characters
			tempShortName = possiblyQuoteName(tempShortName)
			tempFullName=tempPath+tempShortName
			Duplicate/o QOrg, $tempFullName
			Wave QNew=$(tempFullName)
			QNew=QNew^4
			ListOfDataWaveNames=replaceStringByKey("QWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
		else
			ListOfDataWaveNames=replaceStringByKey("QWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")
		endif
		
	//	3 errors
		tempFullName=stringByKey("EWave"+num2str(i),ListOfDataOrgWvNames,"=")
		tempShortName=StringFromList(itemsInList(tempFullName,":")-1, tempFullName , ":")
		if(cmpstr(tempShortName,"---")==0 || cmpstr(tempShortName,"'---'")==0)
			ListOfDataWaveNames=replaceStringByKey("EWave"+num2str(i),ListOfDataWaveNames, "---","=")
		else
			tempPath=tempFullName[0,(strlen(tempFullName)-strlen(tempShortName)-1)]
			Wave EOrg=$(tempFullName)
			if (cmpstr(DataE,"Y")==0)		//straight, nothing to do really
				ListOfDataWaveNames=replaceStringByKey("EWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")
			elseif(cmpstr(DataE,"Y^2")==0)		//Want to plot I^2, create data and name...
				tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
				tempShortName=tempShortName[0,26]	+ "_2"			//Igor names are limited to 30 characters
				tempShortName = possiblyQuoteName(tempShortName)
				tempFullName=tempPath+tempShortName
				Duplicate/o EOrg, $tempFullName
				Wave ENew=$(tempFullName)
				ENew=IRP_ErrorsForPowers(IntOrg, EOrg, 2)
				ListOfDataWaveNames=replaceStringByKey("EWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
			elseif(cmpstr(DataE,"Y^3")==0)		//Want to plot I^2, create data and name...
				tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
				tempShortName=tempShortName[0,26]	+ "_3"			//Igor names are limited to 30 characters
				tempShortName = possiblyQuoteName(tempShortName)
				tempFullName=tempPath+tempShortName
				Duplicate/o EOrg, $tempFullName
				Wave ENew=$(tempFullName)
				ENew=IRP_ErrorsForPowers(IntOrg, EOrg, 3)
				ListOfDataWaveNames=replaceStringByKey("EWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
			elseif(cmpstr(DataE,"Y^4")==0)		//Want to plot I^2, create data and name...
				tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
				tempShortName=tempShortName[0,26]	+ "_4"			//Igor names are limited to 30 characters
				tempShortName = possiblyQuoteName(tempShortName)
				tempFullName=tempPath+tempShortName
				Duplicate/o EOrg, $tempFullName
				Wave ENew=$(tempFullName)
				ENew=IRP_ErrorsForPowers(IntOrg, EOrg, 4)
				ListOfDataWaveNames=replaceStringByKey("EWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
			elseif(cmpstr(DataE,"1/Y")==0)		//Want to plot I^2, create data and name...
				tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
				tempShortName=tempShortName[0,26]	+ "_r1"			//Igor names are limited to 30 characters
				tempShortName = possiblyQuoteName(tempShortName)
				tempFullName=tempPath+tempShortName
				Duplicate/o EOrg, $tempFullName
				Wave ENew=$(tempFullName)
				ENew=IRP_ErrorsForInverse(IntOrg, EOrg)
				ListOfDataWaveNames=replaceStringByKey("EWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
			elseif(cmpstr(DataE,"ln(Y)")==0)		//Want to plot I^2, create data and name...
				tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
				tempShortName=tempShortName[0,26]	+ "_lny"			//Igor names are limited to 30 characters
				tempShortName = possiblyQuoteName(tempShortName)
				tempFullName=tempPath+tempShortName
				Duplicate/o EOrg, $tempFullName
				Wave ENew=$(tempFullName)
				ENew=IRP_ErrorsForLn(IntNew, ENew)
				ListOfDataWaveNames=replaceStringByKey("EWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
			elseif(cmpstr(DataE,"sqrt(1/Y)")==0)		//Want to plot I^2, create data and name...
				tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
				tempShortName=tempShortName[0,26]	+ "_sr1"			//Igor names are limited to 30 characters
				tempShortName = possiblyQuoteName(tempShortName)
				tempFullName=tempPath+tempShortName
				Duplicate/o EOrg, $tempFullName
				Wave ENew=$(tempFullName)
				ENew = IRP_ErrorsForInverse(IntOrg, EOrg)
				ENew = IRP_ErrorsForSQRT(IntNew, ENew)
				ListOfDataWaveNames=replaceStringByKey("EWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
 			elseif(cmpstr(DataE,"ln(Y*X^2)")==0)		//Want to plot I^2, create data and name...
				tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
				tempShortName=tempShortName[0,26]	+ "_Gu"			//Igor names are limited to 30 characters
				tempShortName = possiblyQuoteName(tempShortName)
				tempFullName=tempPath+tempShortName
				Duplicate/o EOrg, $tempFullName
				Wave ENew=$(tempFullName)
				Wave QWvOld=$(tempQwaveName)
				ENew= EOrg * QWvOld^2
				ENew = IRP_ErrorsForLn(IntNew, ENew)
				ListOfDataWaveNames=replaceStringByKey("EWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
 			elseif(cmpstr(DataE,"ln(Y*X)")==0)		//Want to plot I^2, create data and name...
				tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
				tempShortName=tempShortName[0,26]	+ "_LIQ"			//Igor names are limited to 30 characters
				tempShortName = possiblyQuoteName(tempShortName)
				tempFullName=tempPath+tempShortName
				Duplicate/o EOrg, $tempFullName
				Wave ENew=$(tempFullName)
				Wave QWvOld=$(tempQwaveName)
				ENew= EOrg * QWvOld
				ENew = IRP_ErrorsForLn(IntNew, ENew)
				ListOfDataWaveNames=replaceStringByKey("EWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
			elseif(cmpstr(DataE,"Y*X^2")==0)		//Want to plot I^2, create data and name...
				tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
				tempShortName=tempShortName[0,26]	+ "_IQ2"			//Igor names are limited to 30 characters
				tempShortName = possiblyQuoteName(tempShortName)
				tempFullName=tempPath+tempShortName
				Duplicate/o EOrg, $tempFullName
				Wave ENew=$(tempFullName)
				Wave QWvOld=$(tempQwaveName)
				ENew=ENew * QWvOld^2
				ListOfDataWaveNames=replaceStringByKey("EWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
			elseif(cmpstr(DataE,"Y*X^4")==0)		//Want to plot I*Q^4, create data and name...
				tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
				tempShortName=tempShortName[0,26]	+ "_IQ4"			//Igor names are limited to 30 characters
				tempShortName = possiblyQuoteName(tempShortName)
				tempFullName=tempPath+tempShortName
				Duplicate/o EOrg, $tempFullName
				Wave ENew=$(tempFullName)
				Wave QWvOld=$(tempQwaveName)
				ENew=ENew * QWvOld^4
				ListOfDataWaveNames=replaceStringByKey("EWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
			else
				ListOfDataWaveNames=replaceStringByKey("EWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")
			endif
		endif
	
	endfor
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//checbox control procedure
Function IR1P_GenPlotCheckBox(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	SVAR 	ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating

	if (cmpstr("GraphErrors",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("ErrorBars",ListOfGraphFormating, num2str(checked),"=")
	endif
	if (cmpstr("DisplayTimeAndDate",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("DisplayTimeAndDate",ListOfGraphFormating, num2str(checked),"=")
	endif

	if (cmpstr("GraphLogX",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("log(bottom)",ListOfGraphFormating, num2str(checked),"=")
		IR1P_ChangeToUserPlotType()
	endif
	if (cmpstr("GraphXMajorGrid",ctrlName)==0)
		//anything needs to be done here?   
		NVAR GraphXMajorGrid=root:Packages:GeneralplottingTool:GraphXMajorGrid
		NVAR GraphXMinorGrid=root:Packages:GeneralplottingTool:GraphXMinorGrid
		if (GraphXMajorGrid)
			if(GraphXMinorGrid)
				ListOfGraphFormating=ReplaceStringByKey("grid(bottom)",ListOfGraphFormating, "1","=")
			else
				ListOfGraphFormating=ReplaceStringByKey("grid(bottom)",ListOfGraphFormating, "2","=")
			endif
		else
			ListOfGraphFormating=ReplaceStringByKey("grid(bottom)",ListOfGraphFormating, "0","=")
			GraphXMinorGrid=0
		endif
	endif
	if (cmpstr("GraphXMinorGrid",ctrlName)==0)
		//anything needs to be done here?
		NVAR GraphXMajorGrid=root:Packages:GeneralplottingTool:GraphXMajorGrid
		NVAR GraphXMinorGrid=root:Packages:GeneralplottingTool:GraphXMinorGrid
		ListOfGraphFormating=ReplaceStringByKey("grid(bottom)",ListOfGraphFormating, "0","=")
		if (GraphXMinorGrid)
			GraphXMajorGrid=1
			ListOfGraphFormating=ReplaceStringByKey("grid(bottom)",ListOfGraphFormating, "1","=")
		else
			if(GraphXMajorGrid) 
				ListOfGraphFormating=ReplaceStringByKey("grid(bottom)",ListOfGraphFormating, "2","=")
			endif
		endif
	endif
	if (cmpstr("GraphXMirrorAxis",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("mirror(bottom)",ListOfGraphFormating, num2str(checked),"=")
	endif


	if (cmpstr("GraphLogY",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("log(left)",ListOfGraphFormating, num2str(checked),"=")
		IR1P_ChangeToUserPlotType()
	endif
	if (cmpstr("GraphYMajorGrid",ctrlName)==0)
		//anything needs to be done here?
		NVAR GraphYMajorGrid=root:Packages:GeneralplottingTool:GraphYMajorGrid
		NVAR GraphYMinorGrid=root:Packages:GeneralplottingTool:GraphYMinorGrid
		if (GraphYMajorGrid)
			if(GraphYMinorGrid)
				ListOfGraphFormating=ReplaceStringByKey("grid(left)",ListOfGraphFormating, "1","=")
			else
				ListOfGraphFormating=ReplaceStringByKey("grid(left)",ListOfGraphFormating, "2","=")
			endif
		else
			ListOfGraphFormating=ReplaceStringByKey("grid(left)",ListOfGraphFormating, "0","=")
			GraphYMinorGrid=0
		endif
	endif
	if (cmpstr("GraphYMinorGrid",ctrlName)==0)
		//anything needs to be done here?
		NVAR GraphYMajorGrid=root:Packages:GeneralplottingTool:GraphYMajorGrid
		NVAR GraphYMinorGrid=root:Packages:GeneralplottingTool:GraphYMinorGrid
		ListOfGraphFormating=ReplaceStringByKey("grid(left)",ListOfGraphFormating, "0","=")
		if (GraphYMinorGrid)
			GraphYMajorGrid=1
			ListOfGraphFormating=ReplaceStringByKey("grid(left)",ListOfGraphFormating, "1","=")
		else
			if(GraphYMajorGrid) 
				ListOfGraphFormating=ReplaceStringByKey("grid(left)",ListOfGraphFormating, "2","=")
			endif
		endif
	endif
	if (cmpstr("GraphYMirrorAxis",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("mirror(left)",ListOfGraphFormating, num2str(checked),"=")
	endif
	if (cmpstr("GraphLegend",ctrlName)==0)
		//anything needs to be done here?
		if(checked)
			NVAR GraphLegendUseFolderNms=root:Packages:GeneralplottingTool:GraphLegendUseFolderNms
			NVAR GraphLegendUseWaveNote=root:Packages:GeneralplottingTool:GraphLegendUseWaveNote
			ListOfGraphFormating=ReplaceStringByKey("Legend",ListOfGraphFormating, num2str(checked+GraphLegendUseFolderNms+2*GraphLegendUseWaveNote),"=")
		else
			ListOfGraphFormating=ReplaceStringByKey("Legend",ListOfGraphFormating, num2str(checked),"=")
		endif
	endif
	variable UseLegend
	if (cmpstr("GraphLegendUseFolderNms",ctrlName)==0)
		//anything needs to be done here?
		UseLegend=NumberByKey("Legend",ListOfGraphFormating,"=")
		if (UseLegend)
			NVAR GraphLegendUseFolderNms=root:Packages:GeneralplottingTool:GraphLegendUseFolderNms
			NVAR GraphLegendUseWaveNote=root:Packages:GeneralplottingTool:GraphLegendUseWaveNote
			ListOfGraphFormating=ReplaceStringByKey("Legend",ListOfGraphFormating, num2str(1+GraphLegendUseFolderNms+2*GraphLegendUseWaveNote),"=")
		endif
	endif
	if (cmpstr("GraphLegendUseWaveNote",ctrlName)==0)
		//anything needs to be done here?
		UseLegend=NumberByKey("Legend",ListOfGraphFormating,"=")
		if (UseLegend)
			NVAR GraphLegendUseFolderNms=root:Packages:GeneralplottingTool:GraphLegendUseFolderNms
			NVAR GraphLegendUseWaveNote=root:Packages:GeneralplottingTool:GraphLegendUseWaveNote
			ListOfGraphFormating=ReplaceStringByKey("Legend",ListOfGraphFormating, num2str(1+GraphLegendUseFolderNms+2*GraphLegendUseWaveNote),"=")
		endif
	endif

	if (cmpstr("GraphLegendFrame",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("Graph Legend Frame",ListOfGraphFormating, num2str(checked),"=")
	endif
	if (cmpstr("GraphUseColors",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("Graph use Colors",ListOfGraphFormating, num2str(checked),"=")
		if (checked==1)
			ListOfGraphFormating=ReplaceStringByKey("rgb[0]",ListOfGraphFormating, "(65280,0,0)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[1]",ListOfGraphFormating, "(0,0,65280)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[2]",ListOfGraphFormating, "(0,65280,0)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[3]",ListOfGraphFormating, "(32680,32680,0)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[4]",ListOfGraphFormating, "(0,32680,32680)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[5]",ListOfGraphFormating, "(32680,0,32680)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[6]",ListOfGraphFormating, "(32680,32680,32680)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[7]",ListOfGraphFormating, "(65280,32680,32680)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[8]",ListOfGraphFormating, "(32680,32680,65280)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[9]",ListOfGraphFormating, "(65280,0,0)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[10]",ListOfGraphFormating, "(0,0,65280)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[11]",ListOfGraphFormating, "(32680,32680,65280)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[12]",ListOfGraphFormating, "(0,65280,0)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[13]",ListOfGraphFormating, "(32680,32680,0)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[14]",ListOfGraphFormating, "(0,32680,32680)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[15]",ListOfGraphFormating, "(32680,0,32680)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[16]",ListOfGraphFormating, "(32680,32680,32680)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[17]",ListOfGraphFormating, "(65280,32680,32680)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[18]",ListOfGraphFormating, "(32680,32680,65280)","=")
		else
			ListOfGraphFormating=ReplaceStringByKey("rgb[0]",ListOfGraphFormating, "(65280,0,0)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[1]",ListOfGraphFormating, "(65280,0,0)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[2]",ListOfGraphFormating, "(65280,0,0)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[3]",ListOfGraphFormating, "(65280,0,0)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[4]",ListOfGraphFormating, "(65280,0,0)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[5]",ListOfGraphFormating, "(65280,0,0)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[6]",ListOfGraphFormating, "(65280,0,0)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[7]",ListOfGraphFormating, "(65280,0,0)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[8]",ListOfGraphFormating, "(65280,0,0)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[9]",ListOfGraphFormating, "(65280,0,0)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[10]",ListOfGraphFormating, "(65280,0,0)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[11]",ListOfGraphFormating, "(65280,0,0)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[12]",ListOfGraphFormating, "(65280,0,0)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[13]",ListOfGraphFormating, "(65280,0,0)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[14]",ListOfGraphFormating, "(65280,0,0)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[15]",ListOfGraphFormating, "(65280,0,0)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[16]",ListOfGraphFormating, "(65280,0,0)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[17]",ListOfGraphFormating, "(65280,0,0)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[18]",ListOfGraphFormating, "(65280,0,0)","=")
		endif
	endif

	if (cmpstr("GraphUseSymbols",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("Graph use Symbols",ListOfGraphFormating, num2str(checked),"=")
		variable UseLinesAlso=NumberByKey("Graph use Lines",ListOfGraphFormating,"=",";")

		if ((checked==1)&&(UseLinesAlso==1))
			IR1P_SetSymbolsAndLines()	
		else
			ListOfGraphFormating=ReplaceStringByKey("Graph use Lines",ListOfGraphFormating, "1","=")
			NVAR GraphUseLines=root:Packages:GeneralplottingTool:GraphUseLines
			GraphUseLines=1
			IR1P_SetSymbolsAndLines()
		endif
	endif
	if (cmpstr("GraphVarySymbols",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("Graph vary Symbols",ListOfGraphFormating, num2str(checked),"=")
		IR1P_SetSymbolsAndLines()			
	endif
	if (cmpstr("GraphUseSymbolSet1",ctrlName)==0)
		ListOfGraphFormating=ReplaceStringByKey("GraphUseSymbolSet1",ListOfGraphFormating, num2str(checked),"=")
		if (checked)
			NVAR GraphUseSymbolSet2=root:Packages:GeneralplottingTool:GraphUseSymbolSet2
			GraphUseSymbolSet2=0
			ListOfGraphFormating=ReplaceStringByKey("GraphUseSymbolSet2",ListOfGraphFormating, "0","=")
		endif
		IR1P_SetSymbolsAndLines()
	endif
	if (cmpstr("GraphUseSymbolSet2",ctrlName)==0)
		ListOfGraphFormating=ReplaceStringByKey("GraphUseSymbolSet2",ListOfGraphFormating, num2str(checked),"=")
		if (checked)
			NVAR GraphUseSymbolSet1=root:Packages:GeneralplottingTool:GraphUseSymbolSet1
			GraphUseSymbolSet1=0
			ListOfGraphFormating=ReplaceStringByKey("GraphUseSymbolSet1",ListOfGraphFormating, "0","=")
		endif
		IR1P_SetSymbolsAndLines()
	endif
	
	if (cmpstr("GraphVaryLines",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("Graph vary Lines",ListOfGraphFormating, num2str(checked),"=")
		if (checked==1)
			ListOfGraphFormating=ReplaceStringByKey("lStyle[0]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("lStyle[1]",ListOfGraphFormating, "1","=")
			ListOfGraphFormating=ReplaceStringByKey("lStyle[2]",ListOfGraphFormating, "2","=")
			ListOfGraphFormating=ReplaceStringByKey("lStyle[3]",ListOfGraphFormating, "3","=")
			ListOfGraphFormating=ReplaceStringByKey("lStyle[4]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("lStyle[5]",ListOfGraphFormating, "5","=")
			ListOfGraphFormating=ReplaceStringByKey("lStyle[6]",ListOfGraphFormating, "6","=")
			ListOfGraphFormating=ReplaceStringByKey("lStyle[7]",ListOfGraphFormating, "7","=")
			ListOfGraphFormating=ReplaceStringByKey("lStyle[8]",ListOfGraphFormating, "8","=")
		else
			ListOfGraphFormating=ReplaceStringByKey("lStyle[0]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("lStyle[1]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("lStyle[2]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("lStyle[3]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("lStyle[4]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("lStyle[5]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("lStyle[6]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("lStyle[7]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("lStyle[8]",ListOfGraphFormating, "0","=")
		endif
	endif

	if (cmpstr("GraphUseLines",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("Graph use Lines",ListOfGraphFormating, num2str(checked),"=")
		variable UseSymbolsAlso=NumberByKey("Graph use Symbols",ListOfGraphFormating,"=",";")
		if ((checked==1)&&(UseSymbolsAlso==1))
			ListOfGraphFormating=ReplaceStringByKey("mode[0]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[1]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[2]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[3]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[4]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[5]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[6]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[7]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[8]",ListOfGraphFormating, "4","=")
		else
			ListOfGraphFormating=ReplaceStringByKey("Graph use Symbols",ListOfGraphFormating, "1","=")
			NVAR GraphUseSymbols=root:Packages:GeneralplottingTool:GraphUseSymbols
			GraphUseSymbols=1
			ListOfGraphFormating=ReplaceStringByKey("mode[0]",ListOfGraphFormating, "3","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[1]",ListOfGraphFormating, "3","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[2]",ListOfGraphFormating, "3","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[3]",ListOfGraphFormating, "3","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[4]",ListOfGraphFormating, "3","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[5]",ListOfGraphFormating, "3","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[6]",ListOfGraphFormating, "3","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[7]",ListOfGraphFormating, "3","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[8]",ListOfGraphFormating, "3","=")
		endif
	endif


	if (cmpstr("GraphLeftAxisAuto",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("Axis left auto",ListOfGraphFormating, num2str(checked),"=")
	endif
	if (cmpstr("GraphBottomAxisAuto",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("Axis bottom auto",ListOfGraphFormating, num2str(checked),"=")
	endif
	if (cmpstr("GraphAxisStandoff",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("standoff",ListOfGraphFormating, num2str(checked),"=")
	endif
	if (cmpstr("GraphTicksIn",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("tick",ListOfGraphFormating, num2str(2*checked),"=")
	endif
	if (cmpstr("GraphLegendShortNms",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("GraphLegendShortNms",ListOfGraphFormating, num2str(checked),"=")
	endif

DoUpdate

	//And here we should update everytime
	IR1P_UpdateGenGraph()
	
End
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//SetVar procedure 
Function  IR1P_SetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	SVAR 	ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating
	
	if (cmpstr("GraphXAxisName",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("Label bottom",ListOfGraphFormating, varStr,"=")
		DoWindow/F IR1P_ControlPanel
	endif
	if (cmpstr("Xoffset",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("Xoffset",ListOfGraphFormating, varStr,"=")
		DoWindow/F IR1P_ControlPanel
	endif
	if (cmpstr("Yoffset",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("Yoffset",ListOfGraphFormating, varStr,"=")
		DoWindow/F IR1P_ControlPanel
	endif
	if (cmpstr("GraphYAxisName",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("Label left",ListOfGraphFormating, varStr,"=")
		DoWindow/F IR1P_ControlPanel
	endif
	if (cmpstr("GraphLineWidth",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceNumberByKey("lsize",ListOfGraphFormating, varNum,"=")
		DoWindow/F IR1P_ControlPanel
	endif
	if (cmpstr("GraphSymbolSize",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceNumberByKey("msize",ListOfGraphFormating, varNum,"=")
		DoWindow/F IR1P_ControlPanel
	endif

	if (cmpstr("GraphLeftAxisMin",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceNumberByKey("Axis left min",ListOfGraphFormating, varNum,"=")
		DoWindow/F IR1P_ControlPanel
	endif
	if (cmpstr("GraphLeftAxisMax",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceNumberByKey("Axis left max",ListOfGraphFormating, varNum,"=")
		DoWindow/F IR1P_ControlPanel
	endif
	if (cmpstr("GraphBottomAxisMin",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceNumberByKey("Axis bottom min",ListOfGraphFormating, varNum,"=")
		DoWindow/F IR1P_ControlPanel
	endif
	if (cmpstr("GraphBottomAxisMax",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceNumberByKey("Axis bottom max",ListOfGraphFormating, varNum,"=")
		DoWindow/F IR1P_ControlPanel
	endif
	if (cmpstr("GraphAxisWidth",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceNumberByKey("axThick",ListOfGraphFormating, varNum,"=")
	endif
	if (cmpstr("GraphWindowWidth",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceNumberByKey("Graph Window Width",ListOfGraphFormating, varNum,"=")
	endif
	if (cmpstr("GraphWindowHeight",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceNumberByKey("Graph Window Height",ListOfGraphFormating, varNum,"=")
	endif
	//this part belongs to modify data panel
	if (cmpstr("ModifyDataMultiplier",ctrlName)==0)
		//anything needs to be done here?
		IR1P_RecalcModifyData()
	endif
	if (cmpstr("ModifyDataBackground",ctrlName)==0)
		//anything needs to be done here?
		IR1P_RecalcModifyData()
	endif
	if (cmpstr("ModifyDataQshift",ctrlName)==0)
		//anything needs to be done here?
		IR1P_RecalcModifyData()
	endif
	if (cmpstr("ModifyDataErrorMult",ctrlName)==0)
		//anything needs to be done here?
		IR1P_RecalcModifyData()
	endif
	
	
	//And here we should update everytime
	IR1P_UpdateGenGraph()
End

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1P_SetGraphSize(left,top, right,bottom)
		variable left, top, right, bottom
		
		MoveWindow /W=GeneralGraph left, top, right, bottom
		AutopositionWindow /M=0 /R=IR1P_ControlPanel GeneralGraph
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//update all function...
Function IR1P_UpdateGenGraph()

	SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating
	variable i, imax=ItemsInList(ListOfGraphFormating,";"), j
	string ListOfWaves
	variable Xofst, Yofst
	DoWindow GeneralGraph
	if (!V_Flag)
		abort
	endif
	//User could change the type of graph on us, so we also need to recalculate the data...
	IR1P_CheckForDataIntegrity()
	IR1P_CreateDataToPlot()
	IR1P_AddDataToGenGraph()
	IR1P_FixAxesInGraph()
	IR1P_SetGraphSize(0,0, NumberByKey("Graph Window Width", ListOfGraphFormating,"=",";"),NumberByKey("Graph Window Height", ListOfGraphFormating,"=",";"))
	//done
	DoWindow generalGraph
	PauseUpdate
	if (V_Flag)
		DoWindow/F generalGraph
		ListOfWaves=TraceNameList("generalGraph", ";", 1 )
		For(i=0;i<imax;i+=1)
//			Dowindow/F generalGraph
			if(cmpstr(StringFromList(i,ListOfGraphFormating)[0,4],"Label")==0)
				Execute (IN2G_ChangePartsOfString(StringFromList(i,ListOfGraphFormating),"="," \"")+"\"")	
			elseif (cmpstr(StringFromList(i,ListOfGraphFormating)[0,5],"Legend")==0)
				IR1P_AttachLegend(NumberByKey("Legend",ListOfGraphFormating,"="))
			elseif(cmpstr(StringFromList(i,ListOfGraphFormating)[0,8],"ErrorBars")==0)
				//attach error bars or remove them
				IR1P_AttachErrorBars(NumberByKey("ErrorBars",ListOfGraphFormating,"="))
			elseif(cmpstr(StringFromList(i,ListOfGraphFormating)[0,3],"Data")==0)
				//these lines contain data formating (which data are plot) and this macro needs to skip them
			elseif(cmpstr(StringFromList(i,ListOfGraphFormating)[0,4],"Graph")==0)
				//these lines contain some other graph formating and this macro needs to skip them
			elseif(cmpstr(StringFromList(i,ListOfGraphFormating)[0,17],"DisplayTimeAndDate")==0)
				//these lines contain some other graph formating and this macro needs to skip them
				if(NumberByKey("DisplayTimeAndDate", ListOfGraphFormating,"=",";"))
					TextBox/W=GeneralGraph/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()		
				else
					TextBox/W=GeneralGraph/K/N=DateTimeTag
				endif
			elseif(cmpstr(StringFromList(i,ListOfGraphFormating)[0,3],"Axis")==0)
				//these lines contain axis formating (about axis ranges) and this macro needs to skip them
			elseif(cmpstr(StringFromList(i,ListOfGraphFormating)[0,6],"Xoffset")==0 || cmpstr(StringFromList(i,ListOfGraphFormating)[0,6],"Yoffset")==0)
				//these lines contain axis formating (about axis ranges) and this macro needs to skip them
			else
				Execute ("ModifyGraph /Z "+StringFromList(i,ListOfGraphFormating))
			endif
		endfor
		SVAR ListOfWavesNames=root:Packages:GeneralplottingTool:ListOfDataFolderNames
		variable tempXLin, tempXlog, tempYLin, tempYlog
		For(j=0;j<ItemsInList(ListOfWaves);j+=1)
			//change 12 1 2006, Igor 6 now has multiplicative offset...
			if(NumberByKey("IGORVERS", IgorInfo(0) )< 6)	//Igor 5 only
				Xofst=numberByKey("Xoffset",ListOfGraphFormating,"=")*j
				Yofst=numberByKey("Yoffset",ListOfGraphFormating,"=")*j
				Xofst = numtype(Xofst)==0 ?  Xofst : 0
				Yofst = numtype(Yofst)==0 ? Yofst : 0
				ModifyGraph/W=GeneralGraph offset($(stringFromList(j,ListOfWaves)))={Xofst,Yofst}
			else	//Igor 6, so need to check what is axis
				//log(bottom)=1;log(left)=1
				
				if(NumberByKey("log(bottom)", ListOfGraphFormating ,"="))	//log x axis
					Xofst=numberByKey("Xoffset",ListOfGraphFormating,"=")^j
					Xofst = numtype(Xofst)==0 ?  Xofst : 0
					tempXLin = 0
					tempXlog = Xofst
				else
					Xofst=numberByKey("Xoffset",ListOfGraphFormating,"=")*j
					Xofst = numtype(Xofst)==0 ?  Xofst : 0
					tempXLin = Xofst
					tempXlog = 0
				endif
				if(NumberByKey("log(left)", ListOfGraphFormating ,"="))	//log x axis
					Yofst=numberByKey("Yoffset",ListOfGraphFormating,"=")^j
					Yofst = numtype(Yofst)==0 ? Yofst : 0
					tempYLin = 0
					tempYLog = Yofst
				else
					Yofst=numberByKey("Yoffset",ListOfGraphFormating,"=")*j
					Yofst = numtype(Yofst)==0 ? Yofst : 0
					tempYLin = Yofst
					tempYLog = 0
				endif
				Execute("ModifyGraph/W=GeneralGraph offset("+stringFromList(j,ListOfWaves)+")={"+num2str(tempXLin)+","+num2str(tempYLin)+"},muloffset("+stringFromList(j,ListOfWaves)+")={"+num2str(tempXLog)+","+num2str(tempYLog)+"}")
				//ModifyGraph muloffset(SMR_Int#1)={2,2}
			endif
		endfor
	endif
	DoUpdate

//	DOWIndow/F IR1P_ControlPanel
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//Legend handling
Function IR1P_AttachLegend(addOrRemove)
		variable addOrRemove

	if (addOrRemove>0)
		SVAR ListOfWavesNames=root:Packages:GeneralplottingTool:ListOfDataFolderNames
		SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating
		string ListOfWaves=TraceNameList("GeneralGraph", ";", 1 )		//list of waves in the graph
		variable i, imax, test2
		string FontSize, test1, test3
		imax=ItemsInList(ListOfWavesNames , ";")
		SVAR GraphLegendPosition=root:Packages:GeneralplottingTool:GraphlegendPosition
		NVAR GraphLegendFrame=root:Packages:GeneralplottingTool:GraphLegendFrame
		NVAR GraphLegendShortNms=root:Packages:GeneralplottingTool:GraphLegendShortNms
				
		string text0=""
		For(i=0;i<imax;i+=1)
			if(addOrRemove==1)		//if 1 use only wave names, if 2 use full folder structure for legend
					test1=StringFromList(i, ListOfWavesNames)
					test2=ItemsInList(StringFromList(i, ListOfWavesNames),":")
//					test3=StringFromList(ItemsInList(StringFromList(i, ListOfWavesNames),":")-1,StringFromList(i, ListOfWavesNames))
					FontSize = stringByKey("Graph Legend Size", ListOfGraphFormating, "=",";")
					text0+="\\Z"+FontSize+"\\s("+StringFromList(i, ListOfWaves)+") "+StringFromList(ItemsInList(StringFromList(i, ListOfWavesNames),":")-1,StringFromList(i, ListOfWavesNames),":")
			else
				if (GraphLegendShortNms)
					test1=StringFromList(i, ListOfWavesNames)
					test2=ItemsInList(StringFromList(i, ListOfWavesNames),":")
//					test3=StringFromList(ItemsInList(StringFromList(i, ListOfWavesNames),":")-1,StringFromList(i, ListOfWavesNames))
					FontSize = stringByKey("Graph Legend Size", ListOfGraphFormating, "=",";")
					string longname=StringFromList(ItemsInList(StringFromList(i, ListOfWavesNames),":")-2,StringFromList(i, ListOfWavesNames),":")
//					text0+="\\Z"+FontSize+"\\s("+StringFromList(i, ListOfWaves)+") "+StringFromList(ItemsInList(LongName,":")-2,Longname,":")
					text0+="\\Z"+FontSize+"\\s("+StringFromList(i, ListOfWaves)+") "+Longname
				else
					FontSize = stringByKey("Graph Legend Size", ListOfGraphFormating, "=",";")
					text0+="\\Z"+FontSize+"\\s("+StringFromList(i, ListOfWaves)+") "+StringFromList(i, ListOfWavesNames)
				endif
			endif
			if (i<imax-1)
				text0+="\r"
			endif
		endfor
		Legend/C/N=text0/W=GeneralGraph/A=$(GraphLegendPosition)/J/F=(2*GraphLegendFrame) text0
	else
		Execute("Legend/W=GeneralGraph/K/N=text0")
	endif	
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//error bars handling
Function IR1P_AttachErrorBars(addOrRemove)
	variable addOrRemove
	
	variable i, imax
	string ListOfWaves=TraceNameList("GeneralGraph", ";", 1 )		//list of waves in the graph
	SVAR ListOfWaveNames=root:Packages:GeneralplottingTool:ListOfDataWaveNames
	imax=ItemsInList(ListOfWaves , ";")
	if (addOrRemove)
		For(i=0;i<imax;i+=1)
			if(WaveExists($(StringByKey("EWave"+num2str(i), ListOfWaveNames, "="))))
				ErrorBars/W=GeneralGraph $(StringFromList(i, ListOfWaves)) Y,wave=($(StringByKey("EWave"+num2str(i), ListOfWaveNames, "=")),$(StringByKey("EWave"+num2str(i), ListOfWaveNames, "=")))
			else			//no errors given by user, cannot display
				ErrorBars/W=GeneralGraph $(StringFromList(i, ListOfWaves)) OFF
			endif
		endfor
	else
		For(i=0;i<imax;i+=1)
			ErrorBars/W=GeneralGraph $(StringFromList(i, ListOfWaves)) OFF
		endfor
	endif
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//apply selected style function. Copies string with graph & data formating into current formating string 
//and updates the graph as necessary
Function IR1P_ApplySelectedStyle(StyleString)
	string StyleString
	
	if (cmpstr("NewUserStyle",StyleString)!=0)
		SVAR StringToApply=$("root:Packages:plottingToolsStyles:"+possiblyQuoteName(StyleString))
		SVAR FormatingString=root:Packages:GeneralplottingTool:ListOfGraphFormating
		FormatingString=StringToApply
		IR1P_SynchronizeListAndVars()
		IR1P_UpdateGenGraph()
		NVAR LegendYes=root:Packages:GeneralplottingTool:GraphLegend
		NVAR LongLegend=root:Packages:GeneralplottingTool:GraphLegendUseFolderNms
		if (LegendYes)
			LegendYes+=LongLegend
		endif
		IR1P_AttachLegend(LegendYes)
	endif
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//very important. The string with graph formating is primary record of the graph style. This
//function must synchronize the variables used to control GUI 
Function IR1P_SynchronizeListAndVars()
	
	SVAR FormatingStr=root:Packages:GeneralplottingTool:ListOfGraphFormating
	SVAR GraphXAxisName=root:Packages:GeneralplottingTool:GraphXAxisName
	SVAR GraphYAxisName=root:Packages:GeneralplottingTool:GraphYAxisName

	NVAR GraphLogX=root:Packages:GeneralplottingTool:GraphLogX
	NVAR GraphLogY=root:Packages:GeneralplottingTool:GraphLogY
	NVAR GraphErrors=root:Packages:GeneralplottingTool:GraphErrors

	NVAR GraphLegend=root:Packages:GeneralplottingTool:GraphLegend
	NVAR GraphLegendUseFolderNms=root:Packages:GeneralplottingTool:GraphLegendUseFolderNms
	NVAR GraphUseColors=root:Packages:GeneralplottingTool:GraphUseColors
	NVAR GraphUseSymbols=root:Packages:GeneralplottingTool:GraphUseSymbols

	NVAR GraphXMajorGrid=root:Packages:GeneralplottingTool:GraphXMajorGrid
	NVAR GraphXMinorGrid=root:Packages:GeneralplottingTool:GraphXMinorGrid
	NVAR GraphYMajorGrid=root:Packages:GeneralplottingTool:GraphYMajorGrid
	NVAR GraphYMinorGrid=root:Packages:GeneralplottingTool:GraphYMinorGrid
	NVAR GraphXMirrorAxis=root:Packages:GeneralplottingTool:GraphXMirrorAxis
	NVAR GraphYMirrorAxis=root:Packages:GeneralplottingTool:GraphYMirrorAxis
	
	NVAR GraphLeftAxisAuto=root:Packages:GeneralplottingTool:GraphLeftAxisAuto
	NVAR GraphLeftAxisMin=root:Packages:GeneralplottingTool:GraphLeftAxisMin
	NVAR GraphLeftAxisMax=root:Packages:GeneralplottingTool:GraphLeftAxisMax
	NVAR GraphBottomAxisAuto=root:Packages:GeneralplottingTool:GraphBottomAxisAuto
	NVAR GraphBottomAxisMin=root:Packages:GeneralplottingTool:GraphBottomAxisMin
	NVAR GraphBottomAxisMax=root:Packages:GeneralplottingTool:GraphBottomAxisMax
	NVAR GraphAxisStandoff=root:Packages:GeneralplottingTool:GraphAxisStandoff
	NVAR GraphUseLines=root:Packages:GeneralplottingTool:GraphUseLines
	NVAR GraphSymbolSize=root:Packages:GeneralplottingTool:GraphSymbolSize
	NVAR GraphVarySymbols=root:Packages:GeneralplottingTool:GraphVarySymbols
	NVAR GraphVaryLines=root:Packages:GeneralplottingTool:GraphVaryLines
	NVAR GraphAxisWidth=root:Packages:GeneralplottingTool:GraphAxisWidth
	NVAR GraphWindowWidth=root:Packages:GeneralplottingTool:GraphWindowWidth
	NVAR GraphWindowHeight=root:Packages:GeneralplottingTool:GraphWindowHeight
	NVAR GraphTicksIn=root:Packages:GeneralplottingTool:GraphTicksIn
	NVAR GraphLegendFrame=root:Packages:GeneralplottingTool:GraphLegendFrame
	NVAR GraphLegendShortNms=root:Packages:GeneralplottingTool:GraphLegendShortNms

	
	SVAR GraphLegendPosition=root:Packages:GeneralplottingTool:GraphLegendPosition
	
	GraphLegendPosition=StringByKey("Graph Legend Position", FormatingStr, "=")
	
	GraphLegendFrame=NumberByKey("Graph Legend Frame", FormatingStr, "=")
	GraphUseLines=NumberByKey("Graph use Lines", FormatingStr, "=")
	GraphSymbolSize=NumberByKey("msize", FormatingStr, "=")
	GraphVarySymbols=NumberByKey("Graph Vary Symbols", FormatingStr, "=")
	GraphVaryLines=NumberByKey("Graph vary Lines", FormatingStr, "=")
	GraphAxisWidth=NumberByKey("axThick", FormatingStr, "=")
	GraphWindowWidth=NumberByKey("Graph Window width", FormatingStr, "=")
	GraphWindowHeight=NumberByKey("Graph window Height", FormatingStr, "=")
	GraphTicksIn=NumberByKey("tick", FormatingStr, "=")
	
	GraphAxisStandoff=NumberByKey("standoff", FormatingStr, "=")
	GraphUseColors=NumberByKey("Graph use Colors", FormatingStr, "=")
	GraphUseSymbols=NumberByKey("Graph use Symbols", FormatingStr, "=")

	GraphLeftAxisAuto=NumberByKey("Axis left auto", FormatingStr, "=")
	GraphLeftAxisMin=NumberByKey("Axis left min", FormatingStr, "=")
	GraphLeftAxisMax=NumberByKey("Axis left max", FormatingStr, "=")
	GraphBottomAxisAuto=NumberByKey("Axis bottom auto", FormatingStr, "=")
	GraphBottomAxisMin=NumberByKey("Axis bottom min", FormatingStr, "=")
	GraphBottomAxisMax=NumberByKey("Axis bottom max", FormatingStr, "=")
	
	GraphXAxisName=StringByKey("Label bottom", FormatingStr, "=")
	GraphYAxisName=StringByKey("Label left", FormatingStr, "=")
	GraphLogX=NumberByKey("log(bottom)", FormatingStr, "=")
	GraphLogY=NumberByKey("log(left)", FormatingStr, "=")
	GraphXMirrorAxis=NumberByKey("mirror(bottom)", FormatingStr, "=")
	GraphYMirrorAxis=NumberByKey("mirror(left)", FormatingStr, "=")
	GraphLegendShortNms= NumberByKey("GraphLegendShortNms", FormatingStr, "=")
	if (NumberByKey("Legend", FormatingStr, "=")==2)
		GraphLegend=1
		GraphLegendUseFolderNms=1
	elseif (NumberByKey("Legend", FormatingStr, "=")==1)
		GraphLegend=1
		GraphLegendUseFolderNms=0
	else
		GraphLegend=0
		GraphLegendUseFolderNms=0
	endif

	GraphXMajorGrid=0
	GraphXMinorGrid=0
	GraphYMajorGrid=0
	GraphYMinorGrid=0
	if (NumberByKey("grid(bottom)", FormatingStr, "=")==1)
		GraphXMajorGrid=1
		GraphXMinorGrid=1
	endif
	if (NumberByKey("grid(bottom)", FormatingStr, "=")==2)
		GraphXMajorGrid=1
		GraphXMinorGrid=0
	endif
	if (NumberByKey("grid(left)", FormatingStr, "=")==1)
		GraphYMajorGrid=1
		GraphYMinorGrid=1
	endif
	if (NumberByKey("grid(left)", FormatingStr, "=")==2)
		GraphYMajorGrid=1
		GraphYMinorGrid=0
	endif
	PopupMenu XAxisDataType, win=IR1P_ControlPanel,mode=1,popvalue=StringByKey("DataX", FormatingStr, "=") //,value= "Q;Q^2;Q^3;Q^4;"
	PopupMenu YAxisDataType,win=IR1P_ControlPanel, mode=1,popvalue=StringByKey("DataY", FormatingStr, "=")//,value= "I;I^2;I^3;I^4;I*Q^4;1/I;ln(Q^2*I);"
	
	
		if (GraphUseColors)
			FormatingStr=ReplaceStringByKey("rgb[0]",FormatingStr, "(65280,0,0)","=")
			FormatingStr=ReplaceStringByKey("rgb[1]",FormatingStr, "(0,0,65280)","=")
			FormatingStr=ReplaceStringByKey("rgb[2]",FormatingStr, "(0,65280,0)","=")
			FormatingStr=ReplaceStringByKey("rgb[3]",FormatingStr, "(32680,32680,0)","=")
			FormatingStr=ReplaceStringByKey("rgb[4]",FormatingStr, "(0,32680,32680)","=")
			FormatingStr=ReplaceStringByKey("rgb[5]",FormatingStr, "(32680,0,32680)","=")
			FormatingStr=ReplaceStringByKey("rgb[6]",FormatingStr, "(32680,32680,32680)","=")
			FormatingStr=ReplaceStringByKey("rgb[7]",FormatingStr, "(65280,32680,32680)","=")
			FormatingStr=ReplaceStringByKey("rgb[8]",FormatingStr, "(32680,32680,65280)","=")
			FormatingStr=ReplaceStringByKey("rgb[9]",FormatingStr, "(65280,0,0)","=")
			FormatingStr=ReplaceStringByKey("rgb[10]",FormatingStr, "(0,0,65280)","=")
			FormatingStr=ReplaceStringByKey("rgb[11]",FormatingStr, "(32680,32680,65280)","=")
			FormatingStr=ReplaceStringByKey("rgb[12]",FormatingStr, "(0,65280,0)","=")
			FormatingStr=ReplaceStringByKey("rgb[13]",FormatingStr, "(32680,32680,0)","=")
			FormatingStr=ReplaceStringByKey("rgb[14]",FormatingStr, "(0,32680,32680)","=")
			FormatingStr=ReplaceStringByKey("rgb[15]",FormatingStr, "(32680,0,32680)","=")
			FormatingStr=ReplaceStringByKey("rgb[16]",FormatingStr, "(32680,32680,32680)","=")
			FormatingStr=ReplaceStringByKey("rgb[17]",FormatingStr, "(65280,32680,32680)","=")
			FormatingStr=ReplaceStringByKey("rgb[18]",FormatingStr, "(32680,32680,65280)","=")
		else
			FormatingStr=ReplaceStringByKey("rgb[0]",FormatingStr, "(65280,0,0)","=")
			FormatingStr=ReplaceStringByKey("rgb[1]",FormatingStr, "(65280,0,0)","=")
			FormatingStr=ReplaceStringByKey("rgb[2]",FormatingStr, "(65280,0,0)","=")
			FormatingStr=ReplaceStringByKey("rgb[3]",FormatingStr, "(65280,0,0)","=")
			FormatingStr=ReplaceStringByKey("rgb[4]",FormatingStr, "(65280,0,0)","=")
			FormatingStr=ReplaceStringByKey("rgb[5]",FormatingStr, "(65280,0,0)","=")
			FormatingStr=ReplaceStringByKey("rgb[6]",FormatingStr, "(65280,0,0)","=")
			FormatingStr=ReplaceStringByKey("rgb[7]",FormatingStr, "(65280,0,0)","=")
			FormatingStr=ReplaceStringByKey("rgb[8]",FormatingStr, "(65280,0,0)","=")
			FormatingStr=ReplaceStringByKey("rgb[9]",FormatingStr, "(65280,0,0)","=")
			FormatingStr=ReplaceStringByKey("rgb[10]",FormatingStr, "(65280,0,0)","=")
			FormatingStr=ReplaceStringByKey("rgb[11]",FormatingStr, "(65280,0,0)","=")
			FormatingStr=ReplaceStringByKey("rgb[12]",FormatingStr, "(65280,0,0)","=")
			FormatingStr=ReplaceStringByKey("rgb[13]",FormatingStr, "(65280,0,0)","=")
			FormatingStr=ReplaceStringByKey("rgb[14]",FormatingStr, "(65280,0,0)","=")
			FormatingStr=ReplaceStringByKey("rgb[15]",FormatingStr, "(65280,0,0)","=")
			FormatingStr=ReplaceStringByKey("rgb[16]",FormatingStr, "(65280,0,0)","=")
			FormatingStr=ReplaceStringByKey("rgb[17]",FormatingStr, "(65280,0,0)","=")
			FormatingStr=ReplaceStringByKey("rgb[18]",FormatingStr, "(65280,0,0)","=")		
		endif
	if (GraphUseSymbols)
			FormatingStr=ReplaceStringByKey("mode[0]",FormatingStr, "4","=")
			FormatingStr=ReplaceStringByKey("mode[1]",FormatingStr, "4","=")
			FormatingStr=ReplaceStringByKey("mode[2]",FormatingStr, "4","=")
			FormatingStr=ReplaceStringByKey("mode[3]",FormatingStr, "4","=")
			FormatingStr=ReplaceStringByKey("mode[4]",FormatingStr, "4","=")

			FormatingStr=ReplaceStringByKey("marker[0]",FormatingStr, "8","=")
			FormatingStr=ReplaceStringByKey("marker[1]",FormatingStr, "17","=")
			FormatingStr=ReplaceStringByKey("marker[2]",FormatingStr, "5","=")
			FormatingStr=ReplaceStringByKey("marker[3]",FormatingStr, "12","=")
			FormatingStr=ReplaceStringByKey("marker[4]",FormatingStr, "16","=")
		else
			FormatingStr=ReplaceStringByKey("mode[0]",FormatingStr, "0","=")
			FormatingStr=ReplaceStringByKey("mode[1]",FormatingStr, "0","=")
			FormatingStr=ReplaceStringByKey("mode[2]",FormatingStr, "0","=")
			FormatingStr=ReplaceStringByKey("mode[3]",FormatingStr, "0","=")
			FormatingStr=ReplaceStringByKey("mode[4]",FormatingStr, "0","=")
		
		endif

end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//sets the popup to "userstyle". Just simple reset of the popup menu
Function IR1P_ChangeToUserPlotType()

	PopupMenu GraphType,mode=1, win=IR1P_ControlPanel
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//create new user style, so user can apply it to another data
Function IR1P_CreateNewUserStyle()

	//here we must make new user style
	//this contains the current graph
	SVAR CurrentGraph=root:Packages:GeneralplottingTool:ListOfGraphFormating
	
	string NewStyleName="MyNewStyle"
	Prompt NewStyleName, "Input name for new style"
	DoPrompt "Modify for new style name macro",NewStyleName
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:plottingToolsStyles
	NewStyleName = CleanupName(NewStyleName, 0)
	if(CheckName(NewStyleName,4)!=0)
		NewStyleName=UniqueName(NewStyleName,4,0)
	endif
	
	string/g $NewStyleName
	SVAR newstyle=$NewStyleName
	newstyle=CurrentGraph

	PopupMenu GraphType,win= IR1P_ControlPanel, mode=1,popvalue= newstyleName
	
	SetDataFolder oldDf
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//Axis handling function. Needs tro have synchronized fromating string and variables, since it
//apparently uses the variables, not the string as it should. FIX IT>>>
Function IR1P_FixAxesInGraph()
	
	DoWindow GeneralGraph
	if (V_Flag==0)
		abort
	endif
	//this function fixes both axis in the graph according to variables
	
	NVAR GraphLeftAxisAuto=root:Packages:GeneralplottingTool:GraphLeftAxisAuto
	NVAR GraphLeftAxisMin=root:Packages:GeneralplottingTool:GraphLeftAxisMin
	NVAR GraphLeftAxisMax=root:Packages:GeneralplottingTool:GraphLeftAxisMax
	NVAR GraphBottomAxisAuto=root:Packages:GeneralplottingTool:GraphBottomAxisAuto
	NVAR GraphBottomAxisMin=root:Packages:GeneralplottingTool:GraphBottomAxisMin
	NVAR GraphBottomAxisMax=root:Packages:GeneralplottingTool:GraphBottomAxisMax
	SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating
		GetAxis/Q left
		if (V_Flag)
			abort
		endif
	
	if (GraphLeftAxisAuto)	//autoscale left axis
		SetAxis/A/W=GeneralGraph left
		DoUpdate
		GetAxis /W=GeneralGraph /Q left
		GraphLeftAxisMin=V_min
		GraphLeftAxisMax=V_max
		ListOfGraphFormating=ReplaceNumberByKey("Axis left min",ListOfGraphFormating, GraphLeftAxisMin,"=")
		ListOfGraphFormating=ReplaceNumberByKey("Axis left max",ListOfGraphFormating, GraphLeftAxisMax,"=")
		SetVariable GraphLeftAxisMin win=IR1P_ControlPanel,  limits={0,inf,0}, noedit=1
		SetVariable GraphLeftAxisMax win=IR1P_ControlPanel, limits={0,inf,0}, noedit=1
	else		//fixed left axis
		SetAxis/W=GeneralGraph left GraphLeftAxisMin,GraphLeftAxisMax
		SetVariable GraphLeftAxisMin win=IR1P_ControlPanel,  limits={0,inf,1e-6+GraphLeftAxisMin/10}, noedit=0
		SetVariable GraphLeftAxisMax win=IR1P_ControlPanel, limits={0,inf,1e-6+GraphLeftAxisMax/10}, noedit=0
	endif
	
	if (GraphBottomAxisAuto)	//autoscale bottom axis
		SetAxis/A/W=GeneralGraph bottom
		DoUpdate
		GetAxis /W=GeneralGraph /Q bottom
		GraphBottomAxisMin=V_min
		GraphBottomAxisMax=V_max
		ListOfGraphFormating=ReplaceNumberByKey("Axis bottom min",ListOfGraphFormating, GraphBottomAxisMin,"=")
		ListOfGraphFormating=ReplaceNumberByKey("Axis bottom max",ListOfGraphFormating, GraphBottomAxisMax,"=")
		SetVariable GraphBottomAxisMin win=IR1P_ControlPanel, limits={0,inf,0}, noedit=1
		SetVariable GraphBottomAxisMax win=IR1P_ControlPanel, limits={0,inf,0}, noedit=1
	else		//fixed bottom axis
		SetAxis/W=GeneralGraph bottom GraphBottomAxisMin,GraphBottomAxisMax
		SetVariable GraphBottomAxisMin win=IR1P_ControlPanel, limits={0,inf,1e-6+GraphBottomAxisMin/10}, noedit=0
		SetVariable GraphBottomAxisMax win=IR1P_ControlPanel, limits={0,inf,1e-6+GraphBottomAxisMax/10}, noedit=0
	endif
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR1P_CopyModifyData()  //this function copies data so they can be modified

	SVAR SelectedDataToModify=root:Packages:GeneralplottingTool:SelectedDataToModify
	SVAR ListOfDataWaveNames=root:Packages:GeneralplottingTool:ListOfDataOrgWvNames

	if (cmpstr(SelectedDataToModify,"---")==0)
		abort
	endif

	SVAR ModifyIntName=root:Packages:GeneralplottingTool:ModifyIntName
	SVAR ModifyQname= root:Packages:GeneralplottingTool:ModifyQname
	SVAR ModifyErrName=root:Packages:GeneralplottingTool:ModifyErrName
	
	ModifyIntName = ""
	ModifyQname = ""
	ModifyErrName = ""
	
	variable i
	variable imax=ItemsInList(ListOfDataWaveNames,";")/3
	
	For(i=0;i<imax;i+=1)
		if (cmpstr(StringByKey("IntWave"+num2str(i), ListOfDataWaveNames , "=", ";"),SelectedDataToModify)==0)
			ModifyIntName= StringByKey("IntWave"+num2str(i), ListOfDataWaveNames , "=", ";")
			ModifyQname=StringByKey("QWave"+num2str(i), ListOfDataWaveNames , "=", ";")
			ModifyErrName=StringByKey("EWave"+num2str(i), ListOfDataWaveNames , "=", ";")
		endif
	endfor
	
	Wave OrgInt=$ModifyIntName
	Wave OrgQ=$ModifyQname
	Wave/Z OrgE=$ModifyErrName
	
	Duplicate/O OrgInt, $("root:Packages:GeneralplottingTool:BackupInt")
	Duplicate/O OrgQ, $("root:Packages:GeneralplottingTool:BackupQ")
	if(WaveExists(OrgE))
		Duplicate/O OrgE, $("root:Packages:GeneralplottingTool:BackupErr")
	endif
	string addOn="_bckup"
		string ModifyIntName1 = ModifyIntName
		string ModifyQName1 = ModifyQName
		string ModifyErrName1 = ModifyErrName
	if(stringmatch(ModifyIntName[strlen(ModifyIntName)-1],"'"))
		ModifyIntName1 = ModifyIntName[0,strlen(ModifyIntName)-2]
		ModifyQName1 = ModifyQName[0,strlen(ModifyQName)-2]
		ModifyErrName1 = ModifyErrName[0,strlen(ModifyErrName)-2]
		addOn+="'"
	endif
	
	Wave/Z OrgIntBckp=$(ModifyIntName1+addOn)		//known bug, the name of waves cannot be longer than 32 characters
	if (!WaveExists(OrgIntBckp))
		Duplicate/O OrgInt, $(ModifyIntName1+addOn)
		Duplicate/O OrgQ, $(ModifyQName1+addOn)
		if(WaveExists(OrgE))
			Duplicate/O OrgE, $(ModifyErrName1+addOn)
		endif
	endif
		
	IR1P_RecalcModifyData()
end
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
Function IR1P_RecalcModifyData()	//and this function modifies the data with parameters set in the panel

	NVAR ModifyDataBackground=root:Packages:GeneralplottingTool:ModifyDataBackground
	NVAR ModifyDataMultiplier=root:Packages:GeneralplottingTool:ModifyDataMultiplier
	NVAR ModifyDataQshift=root:Packages:GeneralplottingTool:ModifyDataQshift
	NVAR ModifyDataErrorMult=root:Packages:GeneralplottingTool:ModifyDataErrorMult
	SVAR ListOfRemovedPoints=root:Packages:GeneralplottingTool:ListOfRemovedPoints

	SVAR ModifyIntName=root:Packages:GeneralplottingTool:ModifyIntName
	SVAR ModifyQname= root:Packages:GeneralplottingTool:ModifyQname
	SVAR ModifyErrName=root:Packages:GeneralplottingTool:ModifyErrName

	Wave OrgInt=$ModifyIntName
	Wave OrgQ=$ModifyQname
	Wave/Z OrgE=$ModifyErrName
	
	Wave BackupInt= $("root:Packages:GeneralplottingTool:BackupInt")
	Wave BackupQ = $("root:Packages:GeneralplottingTool:BackupQ")
	if(WaveExists(OrgE))
		Wave BackupErr= $("root:Packages:GeneralplottingTool:BackupErr")
	endif
	OrgInt = ModifyDataMultiplier * backupInt - ModifyDataBackground
	OrgQ  = BackupQ - ModifyDataQshift
	if(WaveExists(OrgE))
		OrgE  = BackupErr * ModifyDataErrorMult
	endif
	NVAR TrimPointSmallQ=root:Packages:GeneralplottingTool:TrimPointSmallQ
	NVAR TrimPointLargeQ=root:Packages:GeneralplottingTool:TrimPointLargeQ
	OrgInt[0,TrimPointSmallQ-1]=NaN
	OrgInt[TrimPointLargeQ+1,inf]=NaN
	
	variable i, cursorNow
	string tempPntNum, tempWvName
	if (strlen(ListOfRemovedPoints)>0)
		for (i=0;i<ItemsInList(ListOfRemovedPoints);i+=1)
			tempPntNum=stringFromList(i,ListOfRemovedPoints)
			OrgInt[str2num(tempPntNum)]=NaN
		endfor
	endif
//	cursorNow=pcsr(A)+1
//	cursor/M /P/W=GeneralGraph  A,csrWave(A,"GeneralGraph"), cursorNow
	IR1P_CreateDataToPlot()
end
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
Function IRP_ButtonProc3(ctrlName) : ButtonControl
	String ctrlName
	
	if(cmpstr(ctrlName,"CancelModify")==0)

		NVAR ModifyDataBackground=root:Packages:GeneralplottingTool:ModifyDataBackground
		NVAR ModifyDataMultiplier=root:Packages:GeneralplottingTool:ModifyDataMultiplier
		NVAR ModifyDataQshift=root:Packages:GeneralplottingTool:ModifyDataQshift
		NVAR ModifyDataErrorMult=root:Packages:GeneralplottingTool:ModifyDataErrorMult
		NVAR TrimPointSmallQ=root:Packages:GeneralplottingTool:TrimPointSmallQ
		NVAR TrimPointLargeQ=root:Packages:GeneralplottingTool:TrimPointLargeQ
		SVAR ListOfRemovedPoints=root:Packages:GeneralplottingTool:ListOfRemovedPoints

		SVAR ModifyIntName=root:Packages:GeneralplottingTool:ModifyIntName
		SVAR ModifyQname= root:Packages:GeneralplottingTool:ModifyQname
		SVAR ModifyErrName=root:Packages:GeneralplottingTool:ModifyErrName
	
		Wave/Z OrgInt=$ModifyIntName
		if (WaveExists(OrgInt)==0)
			abort
		endif
		Wave OrgQ=$ModifyQname
		Wave OrgE=$ModifyErrName
		
		Wave BackupInt= $("root:Packages:GeneralplottingTool:BackupInt")
		Wave BackupQ = $("root:Packages:GeneralplottingTool:BackupQ")
		Wave BackupErr= $("root:Packages:GeneralplottingTool:BackupErr")

		ModifyDataBackground = 0
		ModifyDataMultiplier = 1
		ModifyDataQshift = 0
		ModifyDataErrorMult = 1
		TrimPointSmallQ=0
		TrimPointLargeQ=inf
		ListOfRemovedPoints=""
	
		OrgInt = BackupInt
		OrgQ = BackupQ
		OrgE = BackupErr

		IR1P_CreateDataToPlot()

	endif
	
	if(cmpstr(ctrlName,"RemoveSmallData")==0)
		IR1P_RemoveSmallData()
		IR1P_RecalcModifyData()
	endif
	
	if(cmpstr(ctrlName,"RemoveLargeData")==0)
		IR1P_RemoveLargeData()
		IR1P_RecalcModifyData()
	endif
	if(cmpstr(ctrlName,"RemoveOneDataPnt")==0)
		IR1P_RemoveOneDataPoint()
		IR1P_RecalcModifyData()
	endif
	if(cmpstr(ctrlName,"RecoverBackup")==0)
		IR1P_RecoverBackup()
		IR1P_RecalcModifyData()
	endif


	if(cmpstr(ctrlName,"DoFitting")==0)
		IR1P_DoFitting()
	endif
	if(cmpstr(ctrlName,"RemoveTagsAndFits")==0)
		IR1P_RemoveTagsAndFits()
	endif
	if(cmpstr(ctrlName,"GuessFitParam")==0)
		IR1P_GuessFitParam()
	endif
End

//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************

Function IR1P_RecoverBackup()
	//this function recovers original data from backup for Modify data panel
	
	SVAR ModifyIntName=root:Packages:GeneralplottingTool:ModifyIntName
	SVAR ModifyQname= root:Packages:GeneralplottingTool:ModifyQname
	SVAR ModifyErrName=root:Packages:GeneralplottingTool:ModifyErrName

	Wave/Z OrgIntBckp=$(ModifyIntName+"_bckup") //known bug, the name cannot be longer than 32 characters
	if (WaveExists(OrgIntBckp))
		Wave OrgBackupInt= $(ModifyIntName+"_bckup")
		Wave OrgBackupQ = $(ModifyQName+"_bckup")
		Wave OrgBackupE=  $(ModifyErrName+"_bckup")
	else
		Abort "backup for these data does not exists"
	endif


		NVAR ModifyDataBackground=root:Packages:GeneralplottingTool:ModifyDataBackground
		NVAR ModifyDataMultiplier=root:Packages:GeneralplottingTool:ModifyDataMultiplier
		NVAR ModifyDataQshift=root:Packages:GeneralplottingTool:ModifyDataQshift
		NVAR ModifyDataErrorMult=root:Packages:GeneralplottingTool:ModifyDataErrorMult
		NVAR TrimPointSmallQ=root:Packages:GeneralplottingTool:TrimPointSmallQ
		NVAR TrimPointLargeQ=root:Packages:GeneralplottingTool:TrimPointLargeQ
		SVAR ListOfRemovedPoints=root:Packages:GeneralplottingTool:ListOfRemovedPoints

		Wave/Z OrgInt=$ModifyIntName
		if (WaveExists(OrgInt)==0)
			abort
		endif
		Wave OrgQ=$ModifyQname
		Wave OrgE=$ModifyErrName
		
		Wave BackupInt= $("root:Packages:GeneralplottingTool:BackupInt")
		Wave BackupQ = $("root:Packages:GeneralplottingTool:BackupQ")
		Wave BackupErr= $("root:Packages:GeneralplottingTool:BackupErr")

		ModifyDataBackground = 0
		ModifyDataMultiplier = 1
		ModifyDataQshift = 0
		ModifyDataErrorMult = 1
		TrimPointSmallQ=0
		TrimPointLargeQ=inf
		ListOfRemovedPoints=""
	
		BackupInt=OrgBackupInt
		BackupQ = OrgBackupQ
		BackupErr=OrgBackupE
		OrgInt = BackupInt
		OrgQ = BackupQ
		OrgE = BackupErr

		IR1P_CreateDataToPlot()
	
end
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************

Function IR1P_RemoveSmallData()
  

	//sets to NaNs data with Q smaller than where the cursor A is in GeneralGraph
	//is cursor A on the wave listed in the list Box, let's put it there...
	
		SVAR ModifyIntName=root:Packages:GeneralplottingTool:ModifyIntName
		string CsrAFullWaveRef=IR1P_CursorAWave()
		if (cmpstr(ModifyIntName,CsrAFullWaveRef)!=0)
			Abort "Cursor is not on the right wave"
		endif
		
		variable PointWithCsrA=pcsr(A,"GeneralGraph" )
		NVAR TrimPointSmallQ = root:Packages:GeneralplottingTool:TrimPointSmallQ
		TrimPointSmallQ = PointWithCsrA
end

//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************

Function IR1P_RemoveLargeData()
  

	//sets to NaNs data with Q smaller than where the cursor A is in GeneralGraph
	//is cursor A on the wave listed in the list Box, let's put it there...
	
		SVAR ModifyIntName=root:Packages:GeneralplottingTool:ModifyIntName
		string CsrBFullWaveRef=IR1P_CursorBWave()
		if (cmpstr(ModifyIntName,CsrBFullWaveRef)!=0)
			Abort "Cursor is not on the right wave"
		endif
		
		variable PointWithCsrB=pcsr(B,"GeneralGraph" )
		NVAR TrimPointLargeQ = root:Packages:GeneralplottingTool:TrimPointLargeQ
		TrimPointLargeQ = PointWithCsrB
end
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************


Function IR1P_RemoveOneDataPoint()
  

	//sets to NaNs data point where the cursor A is in GeneralGraph
	//is cursor A on the wave listed in the list Box, let's put it there...
	
		SVAR ModifyIntName=root:Packages:GeneralplottingTool:ModifyIntName
		string CsrAFullWaveRef=IR1P_CursorAWave()
		if (cmpstr(ModifyIntName,CsrAFullWaveRef)!=0)
			Abort "Cursor is not on the right wave"
		endif
		
		variable PointWithCsrA=pcsr(A,"GeneralGraph" )
		SVAR ListOfRemovedPoints = root:Packages:GeneralplottingTool:ListOfRemovedPoints
		ListOfRemovedPoints += num2str(PointWithCsrA)+";"
end
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************

Function/S IR1P_CursorAWave()
	Wave/Z w= CsrWaveRef(A)
	if (WaveExists(w)==0)
		return ""
	endif
	return GetWavesDataFolder(w,2)
End
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************

Function/S IR1P_CursorBWave()
	Wave/Z w= CsrWaveRef(B)
	if (WaveExists(w)==0)
		return ""
	endif
	return GetWavesDataFolder(w,2)
End

//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
Function IR1P_SetSymbolsAndLines()

	SVAR 	ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating


	variable UseLinesAlso=NumberByKey("Graph use Lines",ListOfGraphFormating,"=",";")
	variable GraphVarySymbols=NumberByKey("Graph Vary Symbols",ListOfGraphFormating,"=",";")
	variable GraphUseSymbols=NumberByKey("Graph Use Symbols",ListOfGraphFormating,"=",";")
	variable GraphUseSymbolSet1=NumberByKey("GraphUseSymbolSet1",ListOfGraphFormating,"=",";")
	variable GraphUseSymbolSet2=NumberByKey("GraphUseSymbolSet2",ListOfGraphFormating,"=",";")

	if (GraphUseSymbols && UseLinesAlso)
			ListOfGraphFormating=ReplaceStringByKey("mode[0]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[1]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[2]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[3]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[4]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[5]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[6]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[7]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[8]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[9]",ListOfGraphFormating, "4","=")
	endif
	if (!GraphUseSymbols && UseLinesAlso)
			ListOfGraphFormating=ReplaceStringByKey("mode[0]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[1]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[2]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[3]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[4]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[5]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[6]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[7]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[8]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[9]",ListOfGraphFormating, "0","=")		
	endif

	if (GraphVarySymbols)
		if (GraphUseSymbolSet2)
			ListOfGraphFormating=ReplaceStringByKey("marker[0]",ListOfGraphFormating, "8","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[1]",ListOfGraphFormating, "5","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[2]",ListOfGraphFormating, "6","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[3]",ListOfGraphFormating, "22","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[4]",ListOfGraphFormating, "25","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[5]",ListOfGraphFormating, "28","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[6]",ListOfGraphFormating, "7","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[7]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[8]",ListOfGraphFormating, "3","=")		
	// plne 19,16,17, 23, 26, 29 ,18, 15, 14
	// otevrene 8, 5, 6, 22, 25, 28, 7, 4, 3
		else		//symbol set1
			ListOfGraphFormating=ReplaceStringByKey("marker[0]",ListOfGraphFormating, "19","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[1]",ListOfGraphFormating, "16","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[2]",ListOfGraphFormating, "17","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[3]",ListOfGraphFormating, "23","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[4]",ListOfGraphFormating, "26","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[5]",ListOfGraphFormating, "29","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[6]",ListOfGraphFormating, "18","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[7]",ListOfGraphFormating, "15","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[8]",ListOfGraphFormating, "14","=")
		endif
	else		//do not vary
			ListOfGraphFormating=ReplaceStringByKey("marker[0]",ListOfGraphFormating, "8","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[1]",ListOfGraphFormating, "8","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[2]",ListOfGraphFormating, "8","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[3]",ListOfGraphFormating, "8","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[4]",ListOfGraphFormating, "8","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[5]",ListOfGraphFormating, "8","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[6]",ListOfGraphFormating, "8","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[7]",ListOfGraphFormating, "8","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[8]",ListOfGraphFormating, "8","=")
	endif

end 
