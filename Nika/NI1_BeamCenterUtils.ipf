#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.02

//*************************************************************************\
//* Copyright (c) 2005 - 2010, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/


// 8/2/2010 fixed fitting when I was checking on presence of infs in lineout but not nan. Added chgeck for nan (when mask is used)
//2.0 updated for Nika 1.42


//Window NI1B_BeamCenterAndCalPanel() : Panel
//	PauseUpdate; Silent 1		// building window...
//	NewPanel/K=1 /W=(17,55,452,592) as "Beam Center & Calibration Panel"
//	DoWindow/C BeamCenterAndCalibrationPanel
//	SetDrawLayer UserBack
//	SetDrawEnv fname= "Times New Roman",fsize= 20,fstyle= 1,textrgb= (0,0,65280)
//	DrawText 53,35,"Beam center & Calibration"
//	
//	
//EndMacro
//
//Function NI1B_InitBeamCenterCalTool()
//
//		string OldDf=GetDataFolder(1)
//	NewDataFolder/O root:Packages
//	NewDataFolder/O/S root:Packages:Convert2Dto1DBeamCenter
//
//	//string/g ListOfKnownExtensions="tif;marIP/Fit2d;BrukerCCD;Mar;mp/bin;mp/asc;"
//	string ListOfVariables
//	string ListOfStrings
//	
//	//here define the lists of variables and strings needed, separate names by ;...
//	
//	ListOfVariables="BC_UseImageToConvert;BC_UseEmpty;BC_Use"
////	ListOfVariables+="PixelSizeX;PixelSizeY;StartDataRangeNumber;EndDataRangeNumber;XrayEnergy;"
//
//	ListOfStrings="CurrentInstrumentGeometry;DataFileType;DataFileExtension;MaskFileExtension;BlankFileExtension;CurrentMaskFileName;"
//
////	Wave/Z/T ListOfCCDDataInCCDPath
////	if (!WaveExists(ListOfCCDDataInCCDPath))
////		make/O/T/N=0 ListOfCCDDataInCCDPath
////	endif
////	Wave/Z SelectionsofCCDDataInCCDPath
////	if(!WaveExists(SelectionsofCCDDataInCCDPath))
////		make/O/N=0 SelectionsofCCDDataInCCDPath
////	endif
//
//	variable i
//	//and here we create them
//	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
//		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
//	endfor		
//										
//	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
//		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
//	endfor	
//
//end



Function NI1_CreateBmCntrFile()
	
	NI1A_Initialize2Dto1DConversion()
	NI1BC_InitCreateBmCntrFile()
	NI1BC_CreateBmCntrField()
	NI1BC_TabProc("",0)
end


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_CreateBmCntrField()

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

	DoWindow NI1_CreateBmCntrFieldPanel
	if( V_Flag==1 )
		DoWindow/K NI1_CreateBmCntrFieldPanel
	endif
//BmCntrFileName
	SVAR BmCntrFileType=root:Packages:Convert2Dto1D:BmCntrFileType
	SVAR BMColorTableName=root:Packages:Convert2Dto1D:BMColorTableName
	SVAR BmCalibrantName=root:Packages:Convert2Dto1D:BmCalibrantName
	
	NVAR BMImageRangeMaxLimit=root:Packages:Convert2Dto1D:BMImageRangeMaxLimit
	NVAR BMImageRangeMinLimit=root:Packages:Convert2Dto1D:BMImageRangeMinLimit
	NVAR BMBeamCenterXStep=root:Packages:Convert2Dto1D:BMBeamCenterXStep
	NVAR BMBeamCenterYStep=root:Packages:Convert2Dto1D:BMBeamCenterYStep
	NVAR BMHelpCircleRadius=root:Packages:Convert2Dto1D:BMHelpCircleRadius
	NVAR BMMaxCircleRadius=root:Packages:Convert2Dto1D:BMMaxCircleRadius

//	NVAR =root:Packages:Convert2Dto1D:
	
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(22,58,450,630) as "Beam center and calibration panel"
	Dowindow/C NI1_CreateBmCntrFieldPanel
	SetDrawLayer UserBack
	SetDrawEnv fsize= 19,fstyle= 1,textrgb= (0,0,65280)
	DrawText 10,25,"Refinement of Beam Center & Calibration"
	DrawText 18,92,"Select data set to use:"

	Button SelectPathToData,pos={27,35},size={150,20},proc=NI1BC_BmCntrButtonProc,title="Select path to data"
	Button SelectPathToData,help={"Sets path to data where BmCntr image is"}
	PopupMenu BmCntrFileType,pos={207,35},size={101,21},proc=NI1BC_BmCntrPopMenuProc,title="File type:"
	PopupMenu BmCntrFileType,help={"Select image type of data to be used"}
	PopupMenu BmCntrFileType,mode=1,popvalue=BmCntrFileType,value= #"root:Packages:Convert2Dto1D:ListOfKnownExtensions"
	TitleBox BCPathInfoStrt, pos={3,60}, size={350,20}, variable=root:Packages:Convert2Dto1D:BCPathInfoStr, fsize=9, frame=0, fstyle=2, fColor=(0,12800,32000)

	ListBox CCDDataSelection,pos={17,95},size={300,150}//,proc=NI1BC_ListBoxProc
	ListBox CCDDataSelection,help={"Select CCD file for which you want to create mask"}
	ListBox CCDDataSelection,listWave=root:Packages:Convert2Dto1D:ListOfCCDDataInBmCntrPath
	ListBox CCDDataSelection,row= 0,mode= 1,selRow= 0

	Button CreateROIWorkImage,pos={325,225},size={100,20},proc=NI1BC_BmCntrButtonProc,title="Make Image"


	CheckBox BMUseGeometryCorr title="Use Geom. corrs?",pos={300,260}
	CheckBox BMUseGeometryCorr proc=NI1BC_BmCntrCheckProc,variable=root:Packages:Convert2Dto1D:BMUseGeometryCorr
	CheckBox BMUseGeometryCorr help={"Use geometry corrections?"}

	CheckBox BMUseMask title="Use Mask?",pos={300,280}
	CheckBox BMUseMask proc=NI1BC_BmCntrCheckProc,variable=root:Packages:Convert2Dto1D:BMUseMask
	CheckBox BMUseMask help={"Use mask for data evaluation?"}

//AddFlat;FlatValToAdd;MaximumValueBmCntr
	CheckBox DisplayLogImage title="Log image?",pos={10,260}
	CheckBox DisplayLogImage proc=NI1BC_BmCntrCheckProc,variable=root:Packages:Convert2Dto1D:BmCntrDisplayLogImage
	CheckBox DisplayLogImage help={"Display log intensity for the image?"}

	CheckBox BMDezinger title="Dezinger?",pos={100,260}
	CheckBox BMDezinger proc=NI1BC_BmCntrCheckProc,variable=root:Packages:Convert2Dto1D:BMDezinger
	CheckBox BMDezinger help={"Deziner image during loading?"}
	NVAR BMDezinger=root:Packages:Convert2Dto1D:BMDezinger
	SetVariable BMDezinerTimes,pos={170,260},size={90,16},title="times =", disable=!(BMDezinger)
	SetVariable BMDezinerTimes,help={"How many times to dezinger"}, proc=NI1BC_SetVarProc
	SetVariable BMDezinerTimes,limits={0,Inf,1},variable= root:Packages:Convert2Dto1D:BMDezinerTimes


	TabControl BmCntrTab,pos={8,284},size={400,200},proc=NI1BC_TabProc,font="Times", fsize=11
	TabControl BmCntrTab,help={"Select tabs to control various methods"}
	TabControl BmCntrTab,tabLabel(0)="BeamCntr",tabLabel(1)="Calibrant"
	TabControl BmCntrTab,tabLabel(2)="Refinement"//,tabLabel(3)="4"
	TitleBox UserSuggestion,pos={20,310}, title=" Zoom to area of attn. beam & fit 2DGauss or Manually guess "

//TAB 0
	Button Fit2DGauss,pos={30,340},size={180,20},proc=NI1BC_BmCntrBtnProc,title="Fit 2D Gaussian"
	Button Fit2DGauss,help={"Zoom to area with beam imprint and fit 2D Gaussian on the peak there"}
	Button ReadCursors,pos={260,340},size={100,20},proc=NI1BC_BmCntrBtnProc,title="Read Cursor A"
	Button ReadCursors,help={"Read into Beam center values position of cursor A"}
	SetVariable BeamCenterX,pos={30,380},size={200,16},title="Beam center X ="
	SetVariable BeamCenterX,help={"Beam center X value, fitted or input manually"}, proc=NI1BC_SetVarProc
	SetVariable BeamCenterX,limits={-Inf,Inf,BMBeamCenterXStep},variable= root:Packages:Convert2Dto1D:BeamCenterX
	SetVariable BMBeamCenterXStep,pos={250,380},size={80,16},title="step="
	SetVariable BMBeamCenterXStep,help={"Step for Beam center X "}, proc=NI1BC_SetVarProc
	SetVariable BMBeamCenterXStep,limits={-Inf,Inf,1},variable= root:Packages:Convert2Dto1D:BMBeamCenterXStep

	SetVariable BeamCenterY,pos={30,410},size={200,16},title="Beam center Y ="
	SetVariable BeamCenterY,help={"Beam center Y value, fitted or input manually"}, proc=NI1BC_SetVarProc
	SetVariable BeamCenterY,limits={-Inf,Inf,BMBeamCenterYStep},variable= root:Packages:Convert2Dto1D:BeamCenterY
	SetVariable BMBeamCenterYStep,pos={250,410},size={80,16},title="step="
	SetVariable BMBeamCenterYStep,help={"Step for Beam center Y "}, proc=NI1BC_SetVarProc
	SetVariable BMBeamCenterYStep,limits={-Inf,Inf,1},variable= root:Packages:Convert2Dto1D:BMBeamCenterYStep

	CheckBox BMDisplayHelpCircle title="Display circle?",pos={40,430}
	CheckBox BMDisplayHelpCircle proc=NI1BC_BmCntrCheckProc,variable=root:Packages:Convert2Dto1D:BMDisplayHelpCircle
	CheckBox BMDisplayHelpCircle help={"Display circle in the image to help guess the beam center?"}
	Slider BMHelpCircleRadius,pos={15,450},size={230,16},proc=NI1BC_MainSliderProc,variable= root:Packages:Convert2Dto1D:BMHelpCircleRadius,live= 0,side= 2,vert= 0,ticks= 0
	Slider BMHelpCircleRadius,limits={1,BMMaxCircleRadius,0}, title="Help circle radius"
	SetVariable BMHelpCircleRadiusV,pos={270,452},size={120,16},title=" "
	SetVariable BMHelpCircleRadiusV,help={"Step for Beam center Y "}, proc=NI1BC_SetVarProc
	SetVariable BMHelpCircleRadiusV,limits={1,BMMaxCircleRadius,1},variable= root:Packages:Convert2Dto1D:BMHelpCircleRadius

//Tab 1
	PopupMenu BmCalibrantName,pos={13,340},size={101,21},proc=NI1BC_BmCntrPopMenuProc,title="Calibrant:"
	PopupMenu BmCalibrantName,help={"Select type of calibrant to be used"}
	PopupMenu BmCalibrantName,mode=1,popvalue=BmCalibrantName,value= #"\"User;Ceria;Ag behenate;LaB6;\""
	CheckBox BMCalibrantDisplayCircles title="Display?",pos={320,310}
	CheckBox BMCalibrantDisplayCircles proc=NI1BC_BmCntrCheckProc,variable=root:Packages:Convert2Dto1D:BMCalibrantDisplayCircles
	CheckBox BMCalibrantDisplayCircles help={"Display circles in image?"}
	SetVariable BMPathWidth,pos={170,340},size={190,16},title="Lineout Intg over (pix) ="
	SetVariable BMPathWidth,help={"Integration width for for lineouts"}, proc=NI1BC_SetVarProc
	SetVariable BMPathWidth,limits={1,Inf,1},variable= root:Packages:Convert2Dto1D:BMPathWidth


	CheckBox BMUseCalibrantD1 title="Use d1?",pos={20,370}
	CheckBox BMUseCalibrantD1 proc=NI1BC_BmCntrCheckProc,variable=root:Packages:Convert2Dto1D:BMUseCalibrantD1
	CheckBox BMUseCalibrantD1 help={"Use d1 for calibrant?"}
	SetVariable BMCalibrantD1,pos={90,370},size={100,16},title="d1 ="
	SetVariable BMCalibrantD1,help={"Largest d spacing of calibrant"}, proc=NI1BC_SetVarProc
	SetVariable BMCalibrantD1,limits={0,Inf,0},variable= root:Packages:Convert2Dto1D:BMCalibrantD1
	SetVariable BMCalibrantD1LineWidth,pos={210,370},size={100,16},title="width ="
	SetVariable BMCalibrantD1LineWidth,help={"Width of the line for evaluation"}, proc=NI1BC_SetVarProc
	SetVariable BMCalibrantD1LineWidth,limits={1,Inf,5},variable= root:Packages:Convert2Dto1D:BMCalibrantD1LineWidth

	CheckBox BMUseCalibrantD2 title="Use d2?",pos={20,390}
	CheckBox BMUseCalibrantD2 proc=NI1BC_BmCntrCheckProc,variable=root:Packages:Convert2Dto1D:BMUseCalibrantD2
	CheckBox BMUseCalibrantD2 help={"Use d2 for calibrant?"}
	SetVariable BMCalibrantD2,pos={90,390},size={100,16},title="d2 ="
	SetVariable BMCalibrantD2,help={"Largest d spacing of calibrant"}, proc=NI1BC_SetVarProc
	SetVariable BMCalibrantD2,limits={0,Inf,0},variable= root:Packages:Convert2Dto1D:BMCalibrantD2
	SetVariable BMCalibrantD2LineWidth,pos={210,390},size={100,16},title="width ="
	SetVariable BMCalibrantD2LineWidth,help={"Width of the line for evaluation"}, proc=NI1BC_SetVarProc
	SetVariable BMCalibrantD2LineWidth,limits={1,Inf,5},variable= root:Packages:Convert2Dto1D:BMCalibrantD2LineWidth

	CheckBox BMUseCalibrantD3 title="Use d3?",pos={20,410}
	CheckBox BMUseCalibrantD3 proc=NI1BC_BmCntrCheckProc,variable=root:Packages:Convert2Dto1D:BMUseCalibrantD3
	CheckBox BMUseCalibrantD3 help={"Use d3 for calibrant?"}
	SetVariable BMCalibrantD3,pos={90,410},size={100,16},title="d3 ="
	SetVariable BMCalibrantD3,help={"Largest d spacing of calibrant"}, proc=NI1BC_SetVarProc
	SetVariable BMCalibrantD3,limits={0,Inf,0},variable= root:Packages:Convert2Dto1D:BMCalibrantD3
	SetVariable BMCalibrantD3LineWidth,pos={210,410},size={100,16},title="width ="
	SetVariable BMCalibrantD3LineWidth,help={"Width of the line for evaluation"}, proc=NI1BC_SetVarProc
	SetVariable BMCalibrantD3LineWidth,limits={1,Inf,5},variable= root:Packages:Convert2Dto1D:BMCalibrantD3LineWidth

	CheckBox BMUseCalibrantD4 title="Use d4?",pos={20,430}
	CheckBox BMUseCalibrantD4 proc=NI1BC_BmCntrCheckProc,variable=root:Packages:Convert2Dto1D:BMUseCalibrantD4
	CheckBox BMUseCalibrantD4 help={"Use d4 for calibrant?"}
	SetVariable BMCalibrantD4,pos={90,430},size={100,16},title="d4 ="
	SetVariable BMCalibrantD4,help={"Largest d spacing of calibrant"}, proc=NI1BC_SetVarProc
	SetVariable BMCalibrantD4,limits={0,Inf,0},variable= root:Packages:Convert2Dto1D:BMCalibrantD4
	SetVariable BMCalibrantD4LineWidth,pos={210,430},size={100,16},title="width ="
	SetVariable BMCalibrantD4LineWidth,help={"Width of the line for evaluation"}, proc=NI1BC_SetVarProc
	SetVariable BMCalibrantD4LineWidth,limits={1,Inf,5},variable= root:Packages:Convert2Dto1D:BMCalibrantD4LineWidth

	CheckBox BMUseCalibrantD5 title="Use d5?",pos={20,450}
	CheckBox BMUseCalibrantD5 proc=NI1BC_BmCntrCheckProc,variable=root:Packages:Convert2Dto1D:BMUseCalibrantD5
	CheckBox BMUseCalibrantD5 help={"Use d5 for calibrant?"}
	SetVariable BMCalibrantD5,pos={90,450},size={100,16},title="d5 ="
	SetVariable BMCalibrantD5,help={"Largest d spacing of calibrant"}, proc=NI1BC_SetVarProc
	SetVariable BMCalibrantD5,limits={0,Inf,0},variable= root:Packages:Convert2Dto1D:BMCalibrantD5
	SetVariable BMCalibrantD5LineWidth,pos={210,450},size={100,16},title="width ="
	SetVariable BMCalibrantD5LineWidth,help={"Width of the line for evaluation"}, proc=NI1BC_SetVarProc
	SetVariable BMCalibrantD5LineWidth,limits={1,Inf,5},variable= root:Packages:Convert2Dto1D:BMCalibrantD5LineWidth
//Tab 2

//	ListOfVariables+="BMFitBeamCenter;BMFitSDD;BMFitWavelength;"
	SVAR BMFunctionName=root:Packages:Convert2Dto1D:BMFunctionName
	PopupMenu BMFunctionName,pos={180,310},size={101,21},proc=NI1BC_BmCntrPopMenuProc,title="Peak shape function:"
	PopupMenu BMFunctionName,help={"Select type of function to fit to peaks"}
	PopupMenu BMFunctionName,mode=(1+WhichListItem(BMFunctionName,"Gauss;Lorenz;")),value= #"\"Gauss;Lorenz;\""

	CheckBox BMFitBeamCenter title="Refine beam center?",pos={20,340}
	CheckBox BMFitBeamCenter proc=NI1BC_BmCntrCheckProc,variable=root:Packages:Convert2Dto1D:BMFitBeamCenter
	CheckBox BMFitBeamCenter help={"Refine beam center?"}
	CheckBox BMFitSDD title="Refine Sa-Det distance?",pos={20,360}
	CheckBox BMFitSDD proc=NI1BC_BmCntrCheckProc,variable=root:Packages:Convert2Dto1D:BMFitSDD
	CheckBox BMFitSDD help={"Refine sample to detector distance?"}
	CheckBox BMFitWavelength title="Refine wavelength?",pos={20,380}
	CheckBox BMFitWavelength proc=NI1BC_BmCntrCheckProc,variable=root:Packages:Convert2Dto1D:BMFitWavelength
	CheckBox BMFitWavelength help={"Refine wavelength?"}
	CheckBox BMFitTilts title="Refine tilts?",pos={20,400}
	CheckBox BMFitTilts proc=NI1BC_BmCntrCheckProc,variable=root:Packages:Convert2Dto1D:BMFitTilts
	CheckBox BMFitTilts help={"Refine tilts?"}
	SetVariable BMRefNumberOfSectors,pos={20,430},size={200,16},title="Num sectors   =   "
	SetVariable BMRefNumberOfSectors,help={"Number of sectors to use per 360 degrees"}, proc=NI1BC_SetVarProc
	SetVariable BMRefNumberOfSectors,limits={0,Inf,1},variable= root:Packages:Convert2Dto1D:BMRefNumberOfSectors
	CheckBox BMDisplayInImage title="Display in image?",pos={250,430}
	CheckBox BMDisplayInImage variable=root:Packages:Convert2Dto1D:BMDisplayInImage
	CheckBox BMDisplayInImage help={"Display in image where sectors are evaluated?"}
	
	SetVariable SampleToDetectorDistance,pos={180,340},size={200,16},disable=1,proc=NI1BC_SetVarProc,title="Sa-det distance [mm]  "
	SetVariable SampleToDetectorDistance,limits={0,Inf,1},value= root:Packages:Convert2Dto1D:SampleToCCDDistance
	SetVariable Wavelength,pos={180,360},size={200,16},proc=NI1BC_SetVarProc,title="Wavelength [A]          "
	SetVariable Wavelength,help={"\"Input wavelegth of X-rays in Angstroems\" "}
	SetVariable Wavelength,limits={0,Inf,0.1},value= root:Packages:Convert2Dto1D:Wavelength
	SetVariable XrayEnergy,pos={180,380},size={200,16},proc=NI1BC_SetVarProc,title="X-ray energy [keV]      "
	SetVariable XrayEnergy,help={"Input energy of X-rays in keV (linked with wavelength)"}
	SetVariable XrayEnergy,limits={0,Inf,0.1},value= root:Packages:Convert2Dto1D:XrayEnergy

	SetVariable HorizontalTilt,pos={130,400},size={120,16},proc=NI1A_PanelSetVarProc,title="Horizontal"
	SetVariable HorizontalTilt,limits={-90,90,0},value= root:Packages:Convert2Dto1D:HorizontalTilt,help={"Tilt of the image in horizontal plane (around 0 degrees)"}
	SetVariable VerticalTilt,pos={280,400},size={120,16},proc=NI1A_PanelSetVarProc,title="Vertical"
	SetVariable VerticalTilt,limits={-90,90,0},value= root:Packages:Convert2Dto1D:VerticalTilt,help={"Tilt of the image in vertical plane (around 90 degrees)"}

	Button RefineParameters,pos={30,450},size={150,20},proc=NI1BC_BmCntrButtonProc,title="Run refinement"
	Button RefineParameters,help={"Refine above selected parameters"}
	Button RecoverParameters,pos={200,450},size={150,20},proc=NI1BC_BmCntrButtonProc,title="Return back"
	Button RecoverParameters,help={"If refinement fails, this is going to return parameters where they were before..."}


//bottom
	Slider ImageRangeMin,pos={15,500},size={150,16},proc=NI1BC_MainSliderProc,variable= root:Packages:Convert2Dto1D:BMImageRangeMin,live= 0,side= 2,vert= 0,ticks= 0
	Slider ImageRangeMin,limits={BMImageRangeMinLimit,BMImageRangeMaxLimit,0}
	Slider ImageRangeMax,pos={15,530},size={150,16},proc=NI1BC_MainSliderProc,variable= root:Packages:Convert2Dto1D:BMImageRangeMax,live= 0,side= 2,vert= 0,ticks= 0
	Slider ImageRangeMax,limits={BMImageRangeMinLimit,BMImageRangeMaxLimit,0}
	SVAR BMColorTableName=root:Packages:Convert2Dto1D:BMColorTableName
	PopupMenu BMImageColor,pos={200,500},size={200,16}, value= #"\"Grays;Rainbow;YellowHot;BlueHot;BlueRedGreen;RedWhiteBlue;PlanetEarth;Terrain;\""
	PopupMenu BMImageColor,proc=NI1BC_PopMenuProc, mode=(1+WhichListItem(BMColorTableName, "Grays;Rainbow;YellowHot;BlueHot;BlueRedGreen;RedWhiteBlue;PlanetEarth;Terrain;" ))

	setDataFolder OldDf
end
 //*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_TabProc(ctrlName,tabNum)
	String ctrlName
	Variable tabNum

//	//tab 0 controls
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

	NVAR BMDisplayHelpCircle=root:Packages:Convert2Dto1D:BMDisplayHelpCircle
	Button Fit2DGauss, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=0)
	Button ReadCursors, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=0)
	SetVariable BeamCenterX,win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=0)
	SetVariable BeamCenterY, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=0)
	SetVariable BMBeamCenterXStep, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=0)
	SetVariable BMBeamCenterYStep, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=0)
	CheckBox BMDisplayHelpCircle, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=0)
	Slider BMHelpCircleRadius, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=0 || BMDisplayHelpCircle==0)
	SetVariable BMHelpCircleRadiusV, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=0 || BMDisplayHelpCircle==0)
	if(tabNum==0)
		TitleBox UserSuggestion, win=NI1_CreateBmCntrFieldPanel, title=" Zoom to area of attn. beam & fit 2DGauss or Manually guess "
	elseif(tabNum==1)
		TitleBox UserSuggestion, win=NI1_CreateBmCntrFieldPanel, title=" Pick calibrant / own param, border lines "
	elseif(tabNum==2)
		TitleBox UserSuggestion, win=NI1_CreateBmCntrFieldPanel, title=" Select what to refine and run "
	else
		TitleBox UserSuggestion, win=NI1_CreateBmCntrFieldPanel, title="  help text here   "
	endif
//	SetVariable PixleSizeY,disable=(tabNum!=0)
	NVAR  BMUseCalibrantD1=root:Packages:Convert2Dto1D:BMUseCalibrantD1
	NVAR  BMUseCalibrantD2=root:Packages:Convert2Dto1D:BMUseCalibrantD2
	NVAR  BMUseCalibrantD3=root:Packages:Convert2Dto1D:BMUseCalibrantD3
	NVAR  BMUseCalibrantD4=root:Packages:Convert2Dto1D:BMUseCalibrantD4
	NVAR  BMUseCalibrantD5=root:Packages:Convert2Dto1D:BMUseCalibrantD5
	
	SetVariable BMPathWidth, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=1)
	PopupMenu BmCalibrantName, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=1)
	CheckBox BMCalibrantDisplayCircles win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=1)
	CheckBox BMUseCalibrantD1 win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=1)
	SetVariable BMCalibrantD1,win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=1 || BMUseCalibrantD1==0)
	SetVariable BMCalibrantD1LineWidth,win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=1 || BMUseCalibrantD1==0)
	CheckBox BMUseCalibrantD2 win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=1)
	SetVariable BMCalibrantD2,win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=1 || BMUseCalibrantD2==0)
	SetVariable BMCalibrantD2LineWidth,win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=1 || BMUseCalibrantD2==0)
	CheckBox BMUseCalibrantD3 win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=1)
	SetVariable BMCalibrantD3,win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=1 || BMUseCalibrantD3==0)
	SetVariable BMCalibrantD3LineWidth,win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=1 || BMUseCalibrantD3==0)
	CheckBox BMUseCalibrantD4 win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=1)
	SetVariable BMCalibrantD4,win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=1 || BMUseCalibrantD4==0)
	SetVariable BMCalibrantD4LineWidth,win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=1 || BMUseCalibrantD4==0)
	CheckBox BMUseCalibrantD5 win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=1)
	SetVariable BMCalibrantD5,win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=1 || BMUseCalibrantD5==0)
	SetVariable BMCalibrantD5LineWidth,win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=1 || BMUseCalibrantD5==0)



	PopupMenu BMFunctionName, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=2)
	CheckBox BMFitBeamCenter, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=2)
	CheckBox BMFitSDD, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=2)
	CheckBox BMFitWavelength, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=2)
	Button RefineParameters, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=2)
	Button RecoverParameters, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=2)
	SetVariable BMRefNumberOfSectors, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=2)
	CheckBox BMDisplayInImage, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=2)
	SetVariable SampleToDetectorDistance, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=2)
	SetVariable Wavelength, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=2)
	SetVariable XrayEnergy, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=2)
	SetVariable HorizontalTilt, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=2)
	SetVariable VerticalTilt, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=2)
	CheckBox BMFitTilts, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=2)

	if(tabNum==0)
		NI1BC_DisplayHelpCircle()	
	elseif(tabNum==1 || tabNum==2)
		NI1BC_DisplayCalibrantCircles()
	endif

	setDataFolder OldDf
end

 //*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1BC_SetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

	IF(cmpstr(ctrlName,"BMBeamCenterXStep")==0)
		NVAR BMBeamCenterXStep=root:Packages:Convert2Dto1D:BMBeamCenterXStep
		SetVariable BeamCenterX,limits={-Inf,Inf,BMBeamCenterXStep}, win=NI1_CreateBmCntrFieldPanel
	endif
	IF(cmpstr(ctrlName,"BMBeamCenterYStep")==0)
		NVAR BMBeamCenterYStep=root:Packages:Convert2Dto1D:BMBeamCenterYStep
		SetVariable BeamCenterY,limits={-Inf,Inf,BMBeamCenterYStep}, win=NI1_CreateBmCntrFieldPanel
	endif
	IF(cmpstr(ctrlName,"BeamCenterX")==0)
		NI1BC_DisplayHelpCircle()
	endif
	IF(cmpstr(ctrlName,"BeamCenterY")==0)
		NI1BC_DisplayHelpCircle()
	endif
	variable i
	For(i=1;i<=5;i+=1)
		if(cmpstr(ctrlName,"BMCalibrantD"+num2str(i))==0 || cmpstr(ctrlName,"BMCalibrantD"+num2str(i)+"LineWidth")==0)
			NI1BC_DisplayCalibrantCircles()	
		endif
	endfor
	if(cmpstr("XrayEnergy",ctrlName)==0)
		NVAR Wavelength= root:Packages:Convert2Dto1D:Wavelength
		Wavelength = 12.398424437/VarNum
		NI1BC_DisplayCalibrantCircles()	
	endif
	if(cmpstr("Wavelength",ctrlName)==0)
		NVAR XrayEnergy= root:Packages:Convert2Dto1D:XrayEnergy
		XrayEnergy = 12.398424437/VarNum
		NI1BC_DisplayCalibrantCircles()	
	endif
	if(cmpstr("SampleToDetectorDistance",ctrlName)==0)
		NI1BC_DisplayCalibrantCircles()	
	endif	
	if(cmpstr("BMHelpCircleRadiusV",ctrlName)==0)
		NI1BC_DisplayHelpCircle()	
	endif	


	setDataFolder OldDf
End
 //*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_DisplayHelpCircle()

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	NVAR BMDisplayHelpCircle=root:Packages:Convert2Dto1D:BMDisplayHelpCircle
	NVAR BMHelpCircleRadius=root:Packages:Convert2Dto1D:BMHelpCircleRadius
	//remove all drawings
	DoWindow CCDImageForBmCntr
	if(V_Flag)
	      setDrawLayer/W=CCDImageForBmCntr/K ProgFront
	      setDrawLayer/W=CCDImageForBmCntr UserFront
	//and now new drawing
		if(BMDisplayHelpCircle)
		      setDrawLayer/W=CCDImageForBmCntr ProgFront
			NVAR ycenter=root:Packages:Convert2Dto1D:BeamCenterY
			NVAR xcenter=root:Packages:Convert2Dto1D:BeamCenterX
			if(stringMatch(AxisList("CCDImageForBmCntr"),"*top*"))
				setdrawenv/W=CCDImageForBmCntr fillpat=0,xcoord=top,ycoord=left,save
			else
				setdrawenv/W=CCDImageForBmCntr fillpat=0,xcoord=bottom,ycoord=left,save
			endif
			SetDrawEnv/W=CCDImageForBmCntr linefgc=(65535, 65535,65535 )
			SetDrawEnv /W=CCDImageForBmCntr linethick=3
			DrawOval/W=CCDImageForBmCntr xcenter-2, ycenter+2, xcenter+2, ycenter-2
			SetDrawEnv/W=CCDImageForBmCntr linefgc=(65535, 0,0 )
			SetDrawEnv/W=CCDImageForBmCntr linethick=2
			DrawOval/W=CCDImageForBmCntr xcenter-10, ycenter+10, xcenter+10, ycenter-10
			//SetDrawEnv/W=CCDImageForBmCntr linefgc=(65535, 0,0 )
			//SetDrawEnv/W=CCDImageForBmCntr linethick=2
			//DrawOval/W=CCDImageForBmCntr xcenter-50, ycenter+50, xcenter+50, ycenter-50
			SetDrawEnv/W=CCDImageForBmCntr linefgc=(65535, 0,0 )
			SetDrawEnv/W=CCDImageForBmCntr linethick=2
			DrawOval/W=CCDImageForBmCntr xcenter-BMHelpCircleRadius, ycenter+BMHelpCircleRadius, xcenter+BMHelpCircleRadius, ycenter-BMHelpCircleRadius
		      setDrawLayer/W=CCDImageForBmCntr UserFront
		  endif
	  endif
	  DoWIndow CCDImageForBmCntr
	  if(V_Flag)
		  RemoveFromGraph/W=CCDImageForBmCntr/Z ywave
	  endif

  	setDataFolder OldDf

end
 //*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_DisplayCalibrantCircles()

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	NVAR ycenter=root:Packages:Convert2Dto1D:BeamCenterY
	NVAR xcenter=root:Packages:Convert2Dto1D:BeamCenterX
	NVAR BMCalibrantDisplayCircles=root:Packages:Convert2Dto1D:BMCalibrantDisplayCircles
	//remove all drawings
	DoWindow CCDImageForBmCntr
	if(V_Flag)
	      setDrawLayer/W=CCDImageForBmCntr/K ProgFront
	      setDrawLayer/W=CCDImageForBmCntr UserFront
		//and now new drawing
		//this calculates the right radius NI1_GetPixelFromDSpacing(dspacing, direction)
		variable i, radX, radY
		if(BMCalibrantDisplayCircles)
			For(i=1;i<=5;i+=1)
				NVAR  BMUseCalibrantD=$("root:Packages:Convert2Dto1D:BMUseCalibrantD"+num2str(i))
				NVAR BMCalibrantD=$("root:Packages:Convert2Dto1D:BMCalibrantD"+num2str(i))
				NVAR BMCalibrantDLineWidth=$("root:Packages:Convert2Dto1D:BMCalibrantD"+num2str(i)+"LineWidth")
		
			      setDrawLayer/W=CCDImageForBmCntr ProgFront
				if(BMUseCalibrantD)
					if(stringMatch(AxisList("CCDImageForBmCntr"),"*top*"))
						setdrawenv/W=CCDImageForBmCntr fillpat=0,xcoord=top,ycoord=left,save
					else
						setdrawenv/W=CCDImageForBmCntr fillpat=0,xcoord=bottom,ycoord=left,save
					endif
					SetDrawEnv/W=CCDImageForBmCntr linefgc=(65535, 65535,65535 )
					SetDrawEnv /W=CCDImageForBmCntr linethick=2
					radX = NI1BC_GetPixelFromDSpacing(BMCalibrantD, "X")
					radY = NI1BC_GetPixelFromDSpacing(BMCalibrantD, "Y")
					DrawOval/W=CCDImageForBmCntr xcenter-radX, ycenter+radY, xcenter+radX, ycenter-radY
		//			DrawOval/W=CCDImageForBmCntr xcenter, ycenter, xcenter, ycenter
					SetDrawEnv/W=CCDImageForBmCntr linefgc=(65535, 0,0 )
					SetDrawEnv/W=CCDImageForBmCntr linethick=1
					DrawOval/W=CCDImageForBmCntr xcenter-radX+BMCalibrantDLineWidth, ycenter+radY-BMCalibrantDLineWidth, xcenter+radX-BMCalibrantDLineWidth, ycenter-radY+BMCalibrantDLineWidth
					SetDrawEnv/W=CCDImageForBmCntr linefgc=(65535, 0,0 )
					SetDrawEnv/W=CCDImageForBmCntr linethick=1
					DrawOval/W=CCDImageForBmCntr xcenter-radX-BMCalibrantDLineWidth, ycenter+radY+BMCalibrantDLineWidth, xcenter+radX+BMCalibrantDLineWidth, ycenter-radY-BMCalibrantDLineWidth
				  endif
			      setDrawLayer/W=CCDImageForBmCntr UserFront
			endfor 
		endif
	  endif
  	setDataFolder OldDf

end

 //*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_GetPixelFromDSpacing(dspacing, direction)
	variable dspacing		//d in A
	string direction		//X (horizontal) or Y (vertical)
	
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	
	variable pixelDist			//distance from center
	NVAR Wavelength
	NVAR SampleToCCDDistance
	NVAR PixelSizeX
	NVAR PixelSizeY
	NVAR XrayEnergy
	NVAR HorizontalTilt
	NVAR VerticalTilt
	//Ok, this should just return simple Bragg law with little trigonometry
	//		
	// wrong... pixelDist = 2 * SampleToCCDDistance * asin( Wavelength /(2* dspacing) )  
	pixelDist = SampleToCCDDistance *tan(2* asin( Wavelength /(2* dspacing) )  )
	//add the tilts 6/22/2005
	
	if(cmpstr(direction,"X"))
//		if(HorizontalTilt!=0)
//			pixelDist = NI1T_TheoreticalToTilted(pixelDist,SampleToCCDDistance,HorizontalTilt) / PixelSizeX 
//		else
			pixelDist = pixelDist / PixelSizeX 
//		endif
	elseif(cmpstr(direction,"Y"))
//		if(VerticalTilt!=0)
//			pixelDist = NI1T_TheoreticalToTilted(pixelDist,SampleToCCDDistance,VerticalTilt) / PixelSizeY 
//		else
			pixelDist = pixelDist / PixelSizeY 
//		endif
	else
		pixelDist=0
	endif 

	setDataFolder OldDf

	return pixelDist

end

 //*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_PopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	
	if(cmpstr(ctrlName,"BMImageColor")==0)
		SVAR ColorTableName=root:Packages:Convert2Dto1D:BMColorTableName
		ColorTableName = popStr
		NI1BC_TopCCDImageUpdateColors(0)
	endif

	setDataFolder OldDf
End

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_MainSliderProc(ctrlName,sliderValue,event) //: SliderControl
	String ctrlName
	Variable sliderValue
	Variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved

	if(cmpstr(ctrlName,"ImageRangeMin")==0 || cmpstr(ctrlName,"ImageRangeMax")==0)
		if(event %& 0x1)	// bit 0, value set
				NI1BC_TopCCDImageUpdateColors(0)
		endif
	endif
	if(cmpstr(ctrlName,"BMHelpCircleRadius")==0)
		if(event %& 0x1)	// bit 0, value set
				NI1BC_DisplayHelpCircle()
		endif
	endif
	
	
	return 0
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_TopCCDImageUpdateColors(updateRanges)
	variable updateRanges
	
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	NVAR ImageRangeMin= root:Packages:Convert2Dto1D:BMImageRangeMin
	NVAR ImageRangeMax = root:Packages:Convert2Dto1D:BMImageRangeMax
	SVAR ColorTableName=root:Packages:Convert2Dto1D:BMColorTableName
	NVAR ImageRangeMinLimit= root:Packages:Convert2Dto1D:BMImageRangeMinLimit
	NVAR ImageRangeMaxLimit = root:Packages:Convert2Dto1D:BMImageRangeMaxLimit
	String s= ImageNameList("", ";")
	Variable p1= StrSearch(s,";",0)
	if( p1<0 )
		abort			// no image in top graph
	endif
	s= s[0,p1-1]
	if(updateRanges)
		Wave waveToDisplayDis=$(s)
		wavestats/Q  waveToDisplayDis
		ImageRangeMin=V_min
		ImageRangeMinLimit=V_min
		ImageRangeMax=V_max
		ImageRangeMaxLimit=V_max
		Slider ImageRangeMin,limits={ImageRangeMinLimit,ImageRangeMaxLimit,0}, win=NI1_CreateBmCntrFieldPanel
		Slider ImageRangeMax,limits={ImageRangeMinLimit,ImageRangeMaxLimit,0}, win=NI1_CreateBmCntrFieldPanel
	endif
	ModifyImage $(s) ctab= {ImageRangeMin,ImageRangeMax,$ColorTableName,0}
	PopupMenu BMImageColor,win=NI1_CreateBmCntrFieldPanel, popvalue=ColorTableName
	setDataFolder OldDf
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1BC_BmCntrBtnProc(ctrlName) : ButtonControl
	String ctrlName
	
	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Convert2Dto1D
	if(cmpstr(ctrlName,"Fit2DGauss")==0)
		DoWindow CCDImageForBmCntr
		if(!V_flag)
			abort
		endif
		variable BCMarqueetop,BCMarqueebottom,BCMarqueeleft,BCMarqueeright
		wave BmCntrCCDImg=root:Packages:Convert2Dto1D:BmCntrCCDImg
		NVAR InvertImages=root:Packages:Convert2Dto1D:InvertImages
		if(InvertImages)
			GetAxis /W=CCDImageForBmCntr /Q bottom 
			BCMarqueeleft=V_min
			BCMarqueeright=V_max
		else
			GetAxis /W=CCDImageForBmCntr /Q top 
			BCMarqueeleft=V_min
			BCMarqueeright=V_max
		endif
		GetAxis /W=CCDImageForBmCntr /Q left 
		BCMarqueebottom=V_max
		BCMarqueetop=V_min
		NI1BC_Fitto2DGaussian1(BCMarqueeleft,BCMarqueeright,BCMarqueebottom,BCMarqueetop,BmCntrCCDImg)
	endif


	if(cmpstr(ctrlName,"ReadCursors")==0)

		NVAR BeamCenterX = root:Packages:Convert2Dto1D:BeamCenterX
		NVAR BeamCenterY = root:Packages:Convert2Dto1D:BeamCenterY
		STRING strC = CsrInfo(A  , "CCDImageForBmCntr" )
		if(strlen(strC)>0)
			BeamCenterX = NumberByKey("Point", strC)
			BeamCenterY = NumberByKey("Ypoint", strC)
		endif
		NI1BC_DisplayHelpCircle()
	endif

	SetDataFolder OldDf
end


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_Fitto2DGaussian1(left,right,bottom,top,wvToFItTo)
	variable left,right,bottom,top
	wave wvToFItTo

	string OldDf=GetDataFolder(1)
	SetDataFolder root:Packages:Convert2Dto1D
	redimension/S wvToFItTo
	variable tmp
	if(left>right)
		tmp = right
		right=left
		left=tmp
	endif
	if(bottom>top)
		tmp = top
		top=bottom
		bottom=tmp
	endif
	ImageStats /G={left,right,bottom,top} wvToFItTo
	if(V_Flag<0)
		Abort "Problem in Fit2DGaussian routine, bad range of data for image stats"
	endif
	
	if(abs(left-right)+abs(bottom-top)>400)
		Abort "Too large area for fitting 2D gauss function"
	endif
	variable PeakInt=V_max
	variable xcenter=V_maxColLoc
	variable ycenter=V_MaxRowLoc
	make/O/N=(abs(floor(right-left))) tempStDevWv
	tempStDevWv=wvToFItTo[p+left][xcenter]
	FindLEvels/P tempStDevWv, (V_max/2)
	wave W_FindLevels
	variable stddev=2
	if(numpnts(W_FindLevels)==2)
		stddev = abs(W_FindLevels[1]-W_FindLevels[0])
	endif
	if(stddev<2)
		stddev=2
	endif
	
	Silent 1
//	root:P:gPeakInt=PeakInt ;root:P:gxcenter=xcenter ;root:P:gycenter=ycenter ;root:P:gstddev=stddev
	Make/o/n=4 gw2DGaussian
	gw2DGaussian[0]=PeakInt
	gw2DGaussian[1]=ycenter
	gw2DGaussian[2]=xcenter
	gw2DGaussian[3]=stddev
	CheckDisplayed /W=CCDImageForBmCntr fit_BmCntrCCDImg
	if(V_Flag)
		RemoveContour fit_BmCntrCCDImg
	endif
	FuncFitMD NI1BC_gaussian2D, gw2DGaussian, wvToFItTo(left,right)(bottom, top) /d
	wave fit_BmCntrCCDImg=root:Packages:Convert2Dto1D:fit_BmCntrCCDImg
	make/o/N=(DimSize(fit_BmCntrCCDImg, 0)) fit_BmCntrCCDImgX
	fit_BmCntrCCDImgX=DimOffset(fit_BmCntrCCDImg, 0) + p *DimDelta(fit_BmCntrCCDImg,0)
	make/o/N=(DimSize(fit_BmCntrCCDImg, 1)) fit_BmCntrCCDImgY
	fit_BmCntrCCDImgY=DimOffset(fit_BmCntrCCDImg, 1) + p *DimDelta(fit_BmCntrCCDImg,1)
	if(stringmatch(AxisList("CCDImageForBmCntr"),"*top*"))
		AppendMatrixContour/T fit_BmCntrCCDImg vs {fit_BmCntrCCDImgX, fit_BmCntrCCDImgY}
	else
		AppendMatrixContour fit_BmCntrCCDImg vs {fit_BmCntrCCDImgX, fit_BmCntrCCDImgY}
	endif
	ModifyContour fit_BmCntrCCDImg labels=0//, interpolate=1
	ModifyGraph/W=CCDImageForBmCntr lsize=1

	//now save data in centers...
	NVAR BeamCenterX=root:Packages:Convert2Dto1D:BeamCenterX
	NVAR BeamCenterY=root:Packages:Convert2Dto1D:BeamCenterY
	BeamCenterX=gw2DGaussian[1]
	BeamCenterY=gw2DGaussian[2]
	setDataFolder OldDf
Endmacro

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************


Function NI1BC_Gaussian2D(w,x1,y1)
	Wave w;Variable x1 , y1//x is chann
	return(w[0]*exp(-((x1-w[1])^2+(y1-w[2])^2)/w[3]^2))
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function  NI1BC_DisplayMask()

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

	NVAR BMUseMask=root:Packages:Convert2Dto1D:BMUseMask
	if(BMUseMask)
		Wave/Z M_ROIMask=root:Packages:Convert2Dto1D:M_ROIMask
		if(!WaveExists(M_ROIMask) )
			DoAlert 	0, "Mask image does not exist, please load the mask through main panel or create new one through the Mask tool"
			BMUseMask=0
		endif
	endif
	
	DoWindow CCDImageForBmCntr
	if(V_Flag)
		if(BMUseMask && WaveExists(M_ROIMask))
			DoWindow/F CCDImageForBmCntr
			CheckDisplayed/W=CCDImageForBmCntr M_ROIMask
			if(WaveExists(M_ROIMask) && !V_Flag)
				AppendImage/W=CCDImageForBmCntr M_ROIMask
				ModifyImage/W=CCDImageForBmCntr M_ROIMask  ctab ={0.2,0.5, Grays}, minRGB=(12000,12000,12000),maxRGB=NaN
			endif
		else	
			DoWindow CCDImageForBmCntr
			if(V_Flag)
				CheckDisplayed /W=CCDImageForBmCntr root:Packages:Convert2Dto1D:M_ROIMask
				if(V_Flag)
					RemoveImage/W=CCDImageForBmCntr  M_ROIMask
				endif
			endif
		endif
	endif
	setDataFolder OldDf

end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_BmCntrCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

	if(cmpstr(ctrlName,"DisplayLogImage")==0)
		DoWindow CCDImageForBmCntr
		if(V_Flag)
			DoWindow/F CCDImageForBmCntr
			NVAR BmCntrDisplayLogImage=root:Packages:Convert2Dto1D:BmCntrDisplayLogImage
			wave BmCntrCCDImg=root:Packages:Convert2Dto1D:BmCntrCCDImg
			wave BmCntrDisplayImage=root:Packages:Convert2Dto1D:BmCntrDisplayImage
			redimension/S BmCntrCCDImg
			ImageStats BmCntrCCDImg
			if(BmCntrDisplayLogImage)
				MatrixOp/O BmCntrDisplayImage=log(BmCntrCCDImg)
				V_min=log(V_min)
				V_max=log(V_max)
				if(numType(V_min)!=0)
					V_min=0
				endif
			else
				MatrixOp/O BmCntrDisplayImage=BmCntrCCDImg
			endif
			NVAR ImageRangeMin= root:Packages:Convert2Dto1D:BMImageRangeMin
			NVAR ImageRangeMax = root:Packages:Convert2Dto1D:BMImageRangeMax
			NVAR ImageRangeMinLimit= root:Packages:Convert2Dto1D:BMImageRangeMinLimit
			NVAR ImageRangeMaxLimit = root:Packages:Convert2Dto1D:BMImageRangeMaxLimit
			SVAR BMColorTableName = root:Packages:Convert2Dto1D:BMColorTableName
			ImageRangeMin=V_min
			ImageRangeMinLimit=V_min
			ImageRangeMax=V_max
			ImageRangeMaxLimit=V_max
			Slider ImageRangeMin,win=NI1_CreateBmCntrFieldPanel ,limits={ImageRangeMinLimit,ImageRangeMaxLimit,0}
			Slider ImageRangeMax,win=NI1_CreateBmCntrFieldPanel,limits={ImageRangeMinLimit,ImageRangeMaxLimit,0}
		
			ModifyImage/W=CCDImageForBmCntr BmCntrDisplayImage, ctab= {ImageRangeMin,ImageRangeMax,$BMColorTableName,0}
		endif
	endif
	if(cmpstr(ctrlName,"BMDisplayHelpCircle")==0)
		Slider BMHelpCircleRadius, win=NI1_CreateBmCntrFieldPanel, disable=(checked==0)
		SetVariable BMHelpCircleRadiusV, win=NI1_CreateBmCntrFieldPanel, disable=(checked==0)
		NI1BC_DisplayHelpCircle()
	endif


	IF(cmpstr(ctrlName,"BMUseMask")==0)
		NI1BC_DisplayMask()
	endif
	IF(cmpstr(ctrlName,"BMCalibrantDisplayCircles")==0)
		NI1BC_DisplayCalibrantCircles()
	endif
	IF(cmpstr(ctrlName,"BMDezinger")==0)
		NVAR BMDezinger=root:Packages:Convert2Dto1D:BMDezinger
		SetVariable BMDezinerTimes,win=NI1_CreateBmCntrFieldPanel, disable=!(BMDezinger)
	endif
	if(cmpstr(ctrlName,"BMUseCalibrantD1")==0 || cmpstr(ctrlName,"BMUseCalibrantD2")==0 ||cmpstr(ctrlName,"BMUseCalibrantD3")==0 ||cmpstr(ctrlName,"BMUseCalibrantD4")==0 ||cmpstr(ctrlName,"BMUseCalibrantD5")==0 )
		NVAR  BMUseCalibrantD1=root:Packages:Convert2Dto1D:BMUseCalibrantD1
		NVAR  BMUseCalibrantD2=root:Packages:Convert2Dto1D:BMUseCalibrantD2
		NVAR  BMUseCalibrantD3=root:Packages:Convert2Dto1D:BMUseCalibrantD3
		NVAR  BMUseCalibrantD4=root:Packages:Convert2Dto1D:BMUseCalibrantD4
		NVAR  BMUseCalibrantD5=root:Packages:Convert2Dto1D:BMUseCalibrantD5
		
		SetVariable BMCalibrantD1,win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD1==0)
		SetVariable BMCalibrantD1LineWidth,win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD1==0)
		SetVariable BMCalibrantD2,win=NI1_CreateBmCntrFieldPanel, disable=( BMUseCalibrantD2==0)
		SetVariable BMCalibrantD2LineWidth,win=NI1_CreateBmCntrFieldPanel, disable=( BMUseCalibrantD2==0)
		SetVariable BMCalibrantD3,win=NI1_CreateBmCntrFieldPanel, disable=( BMUseCalibrantD3==0)
		SetVariable BMCalibrantD3LineWidth,win=NI1_CreateBmCntrFieldPanel, disable=( BMUseCalibrantD3==0)
		SetVariable BMCalibrantD4,win=NI1_CreateBmCntrFieldPanel, disable=( BMUseCalibrantD4==0)
		SetVariable BMCalibrantD4LineWidth,win=NI1_CreateBmCntrFieldPanel, disable=( BMUseCalibrantD4==0)
		SetVariable BMCalibrantD5,win=NI1_CreateBmCntrFieldPanel, disable=( BMUseCalibrantD5==0)
		SetVariable BMCalibrantD5LineWidth,win=NI1_CreateBmCntrFieldPanel, disable=( BMUseCalibrantD5==0)
		NI1BC_DisplayCalibrantCircles()
	endif
	
	setDataFolder OldDf
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1BC_BmCntrPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D


	if(cmpstr(ctrlName,"BMFunctionName")==0)
		SVAR BMFunctionName=root:Packages:Convert2Dto1D:BMFunctionName
		BMFunctionName = popStr
	endif
	if(cmpstr(ctrlName,"BmCntrFileType")==0)
		//set appropriate extension
		SVAR BmCntrFileType=root:Packages:Convert2Dto1D:BmCntrFileType
		BmCntrFileType = popStr
		if(cmpstr(popStr,"GeneralBinary")==0)
			NI1_GBLoaderPanelFnct()
		endif
		if(cmpstr(popStr,"Pilatus")==0)
			NI1_PilatusLoaderPanelFnct()
		endif
		NI1BC_UpdateBmCntrListBox()
	endif
	if(cmpstr(ctrlName,"BmCalibrantName")==0)
		NVAR BMCalibrantD1=root:Packages:Convert2Dto1D:BMCalibrantD1
		NVAR BMCalibrantD2=root:Packages:Convert2Dto1D:BMCalibrantD2
		NVAR BMCalibrantD3=root:Packages:Convert2Dto1D:BMCalibrantD3
		NVAR BMCalibrantD4=root:Packages:Convert2Dto1D:BMCalibrantD4
		NVAR BMCalibrantD5=root:Packages:Convert2Dto1D:BMCalibrantD5
		NVAR BMUseCalibrantD1=root:Packages:Convert2Dto1D:BMUseCalibrantD1
		NVAR BMUseCalibrantD2=root:Packages:Convert2Dto1D:BMUseCalibrantD2
		NVAR BMUseCalibrantD3=root:Packages:Convert2Dto1D:BMUseCalibrantD3
		NVAR BMUseCalibrantD4=root:Packages:Convert2Dto1D:BMUseCalibrantD4
		NVAR BMUseCalibrantD5=root:Packages:Convert2Dto1D:BMUseCalibrantD5
		if(cmpstr(popStr,"Ceria")==0)
			BMCalibrantD1=3.1241
			BMCalibrantD2=2.70555
			BMCalibrantD3=1.91311
			BMCalibrantD4=1.63151
			BMCalibrantD5=1.56205
			//these data are from : http://www.sci.himeji-tech.ac.jp/material/cryst_struct/LTVcam/sokutei/ceo2.htm
			//and further d spacings: 1.35278, 1.24139, 1.20996, 1.10454...
			BMUseCalibrantD1=1
			BMUseCalibrantD2=1
			BMUseCalibrantD3=1
			BMUseCalibrantD4=1
			BMUseCalibrantD5=1
		elseif(cmpstr(popStr,"Ag behenate")==0)
			//The number I use is q = 0.1076 (1/Angstrom), d = 58.380 Angstroms.  The
			//reference is T.C. Huang et al, J. Appl. Cryst. (1993), 26, 180-184.
			BMCalibrantD1=58.380
			BMCalibrantD2=29.185
			BMUseCalibrantD1=1
			BMUseCalibrantD2=1
			BMUseCalibrantD3=0
			BMUseCalibrantD4=0
			BMUseCalibrantD5=0
		elseif(cmpstr(popStr,"LaB6")==0)
			//Numbers from Peter Lee
			BMCalibrantD1=4.15690	//[100]/rel int 60
			BMCalibrantD2=2.93937	//110 /100
			BMCalibrantD3=2.39999	//111/45
			BMCalibrantD4=2.07845	//200/23.6
			BMCalibrantD5=1.85902	//210/55
			BMUseCalibrantD1=1
			BMUseCalibrantD2=1
			BMUseCalibrantD3=1
			BMUseCalibrantD4=1
			BMUseCalibrantD5=1
		endif
		SetVariable BMCalibrantD1,win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD1==0)
		SetVariable BMCalibrantD1LineWidth,win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD1==0)
		SetVariable BMCalibrantD2,win=NI1_CreateBmCntrFieldPanel, disable=( BMUseCalibrantD2==0)
		SetVariable BMCalibrantD2LineWidth,win=NI1_CreateBmCntrFieldPanel, disable=( BMUseCalibrantD2==0)
		SetVariable BMCalibrantD3,win=NI1_CreateBmCntrFieldPanel, disable=( BMUseCalibrantD3==0)
		SetVariable BMCalibrantD3LineWidth,win=NI1_CreateBmCntrFieldPanel, disable=( BMUseCalibrantD3==0)
		SetVariable BMCalibrantD4,win=NI1_CreateBmCntrFieldPanel, disable=( BMUseCalibrantD4==0)
		SetVariable BMCalibrantD4LineWidth,win=NI1_CreateBmCntrFieldPanel, disable=( BMUseCalibrantD4==0)
		SetVariable BMCalibrantD5,win=NI1_CreateBmCntrFieldPanel, disable=( BMUseCalibrantD5==0)
		SetVariable BMCalibrantD5LineWidth,win=NI1_CreateBmCntrFieldPanel, disable=( BMUseCalibrantD5==0)
		NI1BC_DisplayCalibrantCircles()
	endif
	

	setDataFolder OldDf
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************


Function NI1BC_UpdateBmCntrListBox()

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

		Wave/T  ListOfCCDDataInBmCntrPath=root:Packages:Convert2Dto1D:ListOfCCDDataInBmCntrPath
		Wave SelofCCDDataInBmCntrDPath=root:Packages:Convert2Dto1D:SelofCCDDataInBmCntrDPath
		SVAR BmCntrFileType=root:Packages:Convert2Dto1D:BmCntrFileType
		string RealExtension				//for starnge extensions
		if(cmpstr(BmCntrFileType,".tif")==0)
			RealExtension=BmCntrFileType
//			if(stringMatch(IgorInfo(2),"*Macintosh*"))
	//			RealExtension="TIFF"
		//	endif
		else
			RealExtension="????"
		endif
		string ListOfAvailableCompounds
		PathInfo Convert2Dto1DBmCntrPath
		if(V_Flag==0)
			abort
		endif

		ListOfAvailableCompounds=IndexedFile(Convert2Dto1DBmCntrPath,-1,RealExtension)
		if(strlen(ListOfAvailableCompounds)<2)	//none found
			ListOfAvailableCompounds="--none--;"
		endif
		redimension/N=(ItemsInList(ListOfAvailableCompounds)) ListOfCCDDataInBmCntrPath
		redimension/N=(ItemsInList(ListOfAvailableCompounds)) SelofCCDDataInBmCntrDPath
		variable i
		ListOfCCDDataInBmCntrPath=NI1A_CleanListOfFilesForTypes(ListOfCCDDataInBmCntrPath,BmCntrFileType,"" )
		For(i=0;i<ItemsInList(ListOfAvailableCompounds);i+=1)
			ListOfCCDDataInBmCntrPath[i]=StringFromList(i, ListOfAvailableCompounds)
		endfor
		sort ListOfCCDDataInBmCntrPath, ListOfCCDDataInBmCntrPath, SelofCCDDataInBmCntrDPath		//, NumbersOfCompoundsOutsideIgor
		SelofCCDDataInBmCntrDPath=0

		ListBox CCDDataSelection win=NI1_CreateBmCntrFieldPanel,listWave=root:Packages:Convert2Dto1D:ListOfCCDDataInBmCntrPath
		ListBox CCDDataSelection win=NI1_CreateBmCntrFieldPanel ,row= 0,mode= 1,selRow= 0
		DoUpdate
	setDataFolder OldDf
end	


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1BC_BmCntrButtonProc(ctrlName) : ButtonControl
	String ctrlName

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	variable i
	if( CmpStr(ctrlName,"CreateROIWorkImage") == 0 )
		//create image for working here...
		NI1BC_BmCntrCreateImage()
		//set slider
		NVAR BMMaxCircleRadius=root:Packages:Convert2Dto1D:BMMaxCircleRadius
		Wave BmCntrFieldImg=root:Packages:Convert2Dto1D:BmCntrCCDImg 
		BMMaxCircleRadius=sqrt(DimSize(BmCntrFieldImg, 0 )^2 + DimSize(BmCntrFieldImg, 1 )^2)
		Slider BMHelpCircleRadius,limits={1,BMMaxCircleRadius,0}, win=NI1_CreateBmCntrFieldPanel
		SetVariable BMHelpCircleRadiusV,limits={1,BMMaxCircleRadius,0}, win=NI1_CreateBmCntrFieldPanel
		NVAR BMImageRangeMinLimit= root:Packages:Convert2Dto1D:BMImageRangeMinLimit
		NVAR BMImageRangeMaxLimit = root:Packages:Convert2Dto1D:BMImageRangeMaxLimit
		Slider ImageRangeMin,limits={BMImageRangeMinLimit,BMImageRangeMaxLimit,0}, win=NI1_CreateBmCntrFieldPanel
		Slider ImageRangeMax,limits={BMImageRangeMinLimit,BMImageRangeMaxLimit,0}, win=NI1_CreateBmCntrFieldPanel
		NI1BC_DisplayHelpCircle()
		NI1BC_DisplayMask()
		TabControl BmCntrTab, value=0, win=NI1_CreateBmCntrFieldPanel
		//NI1BC_TabProc("",0)
	endif
	
	if( CmpStr(ctrlName,"SelectPathToData") == 0 )
		NewPath/C/O/M="Select path to your data" Convert2Dto1DBmCntrPath
		SVAR BCPathInfoStr=root:Packages:Convert2Dto1D:BCPathInfoStr
		PathInfo Convert2Dto1DBmCntrPath
		BCPathInfoStr=S_Path
		NI1BC_UpdateBmCntrListBox()
	endif
	if( CmpStr(ctrlName,"RefineParameters") == 0 )
		NI1BC_RunRefinement()
	endif

	if( CmpStr(ctrlName,"RecoverParameters") == 0 )
		NI1BC_RecoverParameters()
	endif	
	setDataFolder OldDf
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_BmCntrCreateImage()

	string OldDf=GetDataFOlder(1)
	setDataFOlder root:Packages:Convert2Dto1D
	Wave/T  ListOfCCDDataInBmCntrPath=root:Packages:Convert2Dto1D:ListOfCCDDataInBmCntrPath
	controlInfo /W=NI1_CreateBmCntrFieldPanel CCDDataSelection
	variable selection = V_Value
	if(selection<0)
		setDataFolder OldDf
		abort
	endif
	DoWindow CCDImageForBmCntr
	if(V_Flag)
		DoWindow/K CCDImageForBmCntr
	endif
	SVAR FileNameToLoad=root:Packages:Convert2Dto1D:FileNameToLoad
	FileNameToLoad=ListOfCCDDataInBmCntrPath[selection]
	SVAR BmCntrFileType=root:Packages:Convert2Dto1D:BmCntrFileType
	NI1A_UniversalLoader("Convert2Dto1DBmCntrPath",FileNameToLoad,BmCntrFileType,"BmCntrCCDImg")
	NVAR BmCntrDisplayLogImage=root:Packages:Convert2Dto1D:BmCntrDisplayLogImage
	wave BmCntrCCDImg
	//allow user function modification to the image through hook function...
		String infostr = FunctionInfo("ModifyImportedImageHook")
		if (strlen(infostr) >0)
			Execute("ModifyImportedImageHook(BmCntrCCDImg)")
		endif
	//end of allow user modification of imported image through hook function
	variable i
	NVAR BMDezinger=root:Packages:Convert2Dto1D:BMDezinger
	if(BMDezinger)
		NVAR BMDezinerTimes=root:Packages:Convert2Dto1D:BMDezinerTimes
		For(i=0;i<BMDezinerTimes;i+=1)
			NI1A_DezingerImage(BmCntrCCDImg)
		endfor
	endif
	duplicate/O BmCntrCCDImg, BmCntrDisplayImage
	redimension/S BmCntrCCDImg
	//ed of dezinger...
	if(BmCntrDisplayLogImage)
		BmCntrDisplayImage=log(BmCntrCCDImg)
	else
		BmCntrDisplayImage=BmCntrCCDImg
	endif
	NVAR InvertImages=root:Packages:Convert2Dto1D:InvertImages
	if(InvertImages)
		NewImage/F/K=1 BmCntrDisplayImage
	else	
		NewImage/K=1 BmCntrDisplayImage
	endif
	DoWindow/C CCDImageForBmCntr
	AutoPositionWindow/E/M=0/R=NI1_CreateBmCntrFieldPanel CCDImageForBmCntr
	
	NVAR ImageRangeMin= root:Packages:Convert2Dto1D:BMImageRangeMin
	NVAR ImageRangeMax = root:Packages:Convert2Dto1D:BMImageRangeMax
	NVAR ImageRangeMinLimit= root:Packages:Convert2Dto1D:BMImageRangeMinLimit
	NVAR ImageRangeMaxLimit = root:Packages:Convert2Dto1D:BMImageRangeMaxLimit
	SVAR BMColorTableName = root:Packages:Convert2Dto1D:BMColorTableName
	ImageStats BmCntrDisplayImage
	ImageRangeMin=V_min
	ImageRangeMinLimit=V_min
	ImageRangeMax=V_max
	ImageRangeMaxLimit=V_max

	ModifyImage/W=CCDImageForBmCntr BmCntrDisplayImage, ctab= {ImageRangeMin,ImageRangeMax,$BMColorTableName,0}
	
	setDataFolder OldDf
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_InitCreateBmCntrFile()

	string OldDf=GetDataFolder(1)
	NewDataFolder/O root:Packages
	NewDataFolder/O/S root:Packages:Convert2Dto1D

	string/g ListOfVariablesBC
	string/g ListOfStringsBC
	
	//here define the lists of variables and strings needed, separate names by ;...
	
	//ListOfVariables="AddFlat;FlatValToAdd;MaximumValueBmCntr;MinimumValueBmCntr;ImageRangeMaxLimit;ImageRangeMinLimit;BmCntrDisplayLogImage;"
	ListOfVariablesBC="BMImageRangeMaxLimit;BMImageRangeMinLimit;BMImageRangeMax;BMImageRangeMin;BmCntrDisplayLogImage;BMUseGeometryCorr;"
	ListOfVariablesBC+="BMBeamCenterXStep;BMBeamCenterYStep;BMDisplayHelpCircle;BMHelpCircleRadius;BMMaxCircleRadius;BMFitTilts;"
	ListOfVariablesBC+="BMCalibrantD1;BMUseCalibrantD1;BMCalibrantD2;BMUseCalibrantD2;BMCalibrantD3;BMUseCalibrantD3;BMCalibrantD4;BMUseCalibrantD4;BMCalibrantD5;BMUseCalibrantD5;"
	ListOfVariablesBC+="BMCalibrantD1LineWidth;BMCalibrantD2LineWidth;BMCalibrantD3LineWidth;BMCalibrantD4LineWidth;BMCalibrantD5LineWidth;BMCalibrantDisplayCircles;"
	ListOfVariablesBC+="BMFitBeamCenter;BMFitSDD;BMFitWavelength;BMRefNumberOfSectors;BMDezinger;BMDezinerTimes;BMPathWidth;BMUseMask;BMDisplayInImage;"
	
	ListOfStringsBC="BmCntrFileName;BmCntrFileType;ExportBmCntrFileName;BMColorTableName;FileNameToLoad;"
	ListOfStringsBC+="BmCalibrantName;BMFunctionName;BCPathInfoStr;"
	
	Wave/Z/T ListOfCCDDataInBmCntrPath
	if (!WaveExists(ListOfCCDDataInBmCntrPath))
		make/O/T/N=0 ListOfCCDDataInBmCntrPath
	endif
	Wave/Z SelofCCDDataInBmCntrDPath
	if(!WaveExists(SelofCCDDataInBmCntrDPath))
		make/O/N=0 SelofCCDDataInBmCntrDPath
	endif

	variable i
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariablesBC);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariablesBC))
	endfor		
										
	for(i=0;i<itemsInList(ListOfStringsBC);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStringsBC))
	endfor	

	string ListOfVariablesL
	string ListOfStringsL
	//set start values
	ListOfVariablesL="BMBeamCenterXStep;BMBeamCenterYStep;BMDisplayHelpCircle;BMHelpCircleRadius;BMMaxCircleRadius;BMCalibrantDisplayCircles;BMDezinerTimes;"
	for(i=0;i<itemsInList(ListOfVariablesL);i+=1)	
		NVAR testMe=$stringFromList(i,ListOfVariablesL)
		if(testMe==0)
			testMe=1
		endif
	endfor		
	
	ListOfVariablesL="BMCalibrantD1LineWidth;BMCalibrantD2LineWidth;BMCalibrantD3LineWidth;BMCalibrantD4LineWidth;BMCalibrantD5LineWidth;"
	for(i=0;i<itemsInList(ListOfVariablesL);i+=1)	
		NVAR testMe=$stringFromList(i,ListOfVariablesL)
		if(testMe==0)
			testMe=15
		endif
	endfor		
	ListOfVariablesL="BMRefNumberOfSectors;"
	for(i=0;i<itemsInList(ListOfVariablesL);i+=1)	
		NVAR testMe=$stringFromList(i,ListOfVariablesL)
		if(testMe==0)
			testMe=60
		endif
	endfor		
	ListOfVariablesL="BMPathWidth;"
	for(i=0;i<itemsInList(ListOfVariablesL);i+=1)	
		NVAR testMe=$stringFromList(i,ListOfVariablesL)
		if(testMe==0)
			testMe=5
		endif
	endfor		

	SVAR BmCalibrantName
	if(strlen(BmCalibrantName)<1)
		BmCalibrantName="user"
	endif
	SVAR BmCntrFileType
	if(strlen(BmCntrFileType)<2)
		BmCntrFileType=".tif"
	endif
	SVAR BMColorTableName
	if(strlen(BMColorTableName)<1)
		BMColorTableName="Terrain"
	endif	
	SVAR BMFunctionName
	if(strlen(BMFunctionName)<1)
		BMFunctionName="Gauss"
	endif	


	setDataFolder OldDf
end


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1BC_RecoverParameters()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Convert2Dto1D

	Wave/Z /T ParametersNames
	Wave/Z parametersWvBackup
	if(WaveExists(parametersWvBackup))
		variable i
		For(i=0;i<numpnts(ParametersNames);i+=1)
			NVAR temp=$(ParametersNames[i])
			temp = parametersWvBackup[i]
		endfor	
	endif	
	setDataFolder OldDf
	NI1BC_DisplayCalibrantCircles()
end


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************


Function NI1BC_RunRefinement()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Convert2Dto1D
	NVAR BMRefNumberOfSectors=root:Packages:Convert2Dto1D:BMRefNumberOfSectors
	NVAR BMFitBeamCenter=root:Packages:Convert2Dto1D:BMFitBeamCenter
	NVAR BMFitSDD=root:Packages:Convert2Dto1D:BMFitSDD
	NVAR BMFitWavelength=root:Packages:Convert2Dto1D:BMFitWavelength
	NVAR BMFitTilts=root:Packages:Convert2Dto1D:BMFitTilts

	if(BMFitBeamCenter+BMFitSDD+BMFitWavelength+BMFitTilts<0.5)
		abort //nothing to do, no fitting requested...
	endif
	if(BMFitSDD+BMFitWavelength>1)
		//try to fit both SDD and wavelength, must have more tha 1 line...
		NVAR Use1=root:Packages:Convert2Dto1D:BMUseCalibrantD1
		NVAR Use2=root:Packages:Convert2Dto1D:BMUseCalibrantD2
		NVAR Use3=root:Packages:Convert2Dto1D:BMUseCalibrantD3
		NVAR Use4=root:Packages:Convert2Dto1D:BMUseCalibrantD4
		NVAR Use5=root:Packages:Convert2Dto1D:BMUseCalibrantD5
		if(Use1+Use2+Use3+Use4+Use5<1.5)
			abort "Not enough lines to fit both Sample to detector distance and wavelength, you need at least  2 lines"
		endif
	endif
	variable i
	For(i=1;i<=5;i+=1)
		NVAR BMUseCalibrantD=$("root:Packages:Convert2Dto1D:BMUseCalibrantD"+num2str(i))
		if(BMUseCalibrantD)
			NI1BC_GetEvaluationPaths(i,BMRefNumberOfSectors)
		endif
	endfor
	
	NI1BC_FitParameters()
	
	NI1BC_DisplayCalibrantCircles()
	  RemoveFromGraph/W=CCDImageForBmCntr/Z ywave

	setDataFolder OldDf
end


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************


Function NI1BC_FitParameters()

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	NVAR BeamCenterX=root:Packages:Convert2Dto1D:BeamCenterX
	NVAR BeamCenterY=root:Packages:Convert2Dto1D:BeamCenterY
	NVAR Wavelength = root:Packages:Convert2Dto1D:Wavelength
	NVAR SampleToCCDDistance = root:Packages:Convert2Dto1D:SampleToCCDDistance
	variable azimuthalAngle, i, MaxNumPixels
	
	variable radX 
	variable radY 
	variable CalibrantRadInPix
	variable startPnt, endPnt, minX, maxX, minY, maxY
	//variable angleStep=360/numberOfSectors
	Variable V_fitOptions=4

	make/O/N=0 CalibrantXY, CalibrantAngles, CalibrantErrors
	For(i=1;i<=5;i+=1)
		NVAR BMUseCalibrantD=$("root:Packages:Convert2Dto1D:BMUseCalibrantD"+num2str(i))
		if(BMUseCalibrantD)
			Wave BMOptimizeAngles = $("BMOptimizeAngles"+num2str(i))
			Wave BMOptimizeXs = $("BMOptimizeXs"+num2str(i))
			Wave BMOptimizeYs = $("BMOptimizeYs"+num2str(i))
			Wave BMOptimizeErrors = $("BMOptimizeErrors"+num2str(i))

			Concatenate /NP/O  {CalibrantXY,BMOptimizeXs,BMOptimizeYs} , CalibrantXYtmp
			//fix for 6.10 upodate...
			Wave CalibrantXYtmp
			Duplicate/O  CalibrantXYtmp, CalibrantXY
			KillWaves CalibrantXYtmp
			//end of fix...
			Concatenate  /NP/O {CalibrantAngles,BMOptimizeAngles,BMOptimizeAngles} , CalibrantAnglesTmp
			//fix for 6.10 upodate...
			Wave CalibrantAnglesTmp
			Duplicate/O CalibrantAnglesTmp, CalibrantAngles
			KillWaves CalibrantAnglesTmp
			//end of fix...
			Concatenate  /NP/O {CalibrantErrors,BMOptimizeErrors,BMOptimizeErrors} , CalibrantErrorsTmp
			//fix for 6.10 upodate...
			Wave CalibrantErrorsTmp
			Duplicate/O CalibrantErrorsTmp, CalibrantErrors
			KillWaves CalibrantErrorsTmp
			//end of fix...
	
		endif
	endfor

	Make/D/N=0/O parametersWv, parametersWvBackup
	Make/T/N=0/O ParametersNames
	NVAR BMFitBeamCenter=root:Packages:Convert2Dto1D:BMFitBeamCenter
	NVAR BMFitSDD=root:Packages:Convert2Dto1D:BMFitSDD
	NVAR BMFitWavelength=root:Packages:Convert2Dto1D:BMFitWavelength
	NVAR BMFitTilts=root:Packages:Convert2Dto1D:BMFitTilts
	NVAR HorizontalTilt=root:Packages:Convert2Dto1D:HorizontalTilt
	NVAR VerticalTilt=root:Packages:Convert2Dto1D:VerticalTilt
	if(BMFitTilts)
		redimension /N=(numpnts(parametersWv)+2) parametersWv,parametersWvBackup
		redimension /N=(numpnts(ParametersNames)+2) ParametersNames
		parametersWv[numpnts(parametersWv)-2] = HorizontalTilt
		parametersWv[numpnts(parametersWv)-1] = VerticalTilt
		ParametersNames[numpnts(parametersWv)-2] = "HorizontalTilt"
		ParametersNames[numpnts(parametersWv)-1] = "VerticalTilt"
	endif	
	if(BMFitBeamCenter)
		redimension /N=(numpnts(parametersWv)+2) parametersWv,parametersWvBackup
		redimension /N=(numpnts(ParametersNames)+2) ParametersNames
		parametersWv[numpnts(parametersWv)-2] = BeamCenterX
		parametersWv[numpnts(parametersWv)-1] = BeamCenterY
		ParametersNames[numpnts(parametersWv)-2] = "BeamCenterX"
		ParametersNames[numpnts(parametersWv)-1] = "BeamCenterY"
	endif	
	if(BMFitSDD)
		redimension /N=(numpnts(parametersWv)+1) parametersWv, parametersWvBackup
		redimension /N=(numpnts(ParametersNames)+1) ParametersNames
		parametersWv[numpnts(parametersWv)-1] = SampleToCCDDistance
		ParametersNames[numpnts(parametersWv)-1] = "SampleToCCDDistance"
	endif	
	if(BMFitWavelength)
		redimension /N=(numpnts(parametersWv)+1) parametersWv, parametersWvBackup
		redimension /N=(numpnts(ParametersNames)+1) ParametersNames
		parametersWv[numpnts(parametersWv)-1] = Wavelength
		ParametersNames[numpnts(parametersWv)-1] = "Wavelength"
	endif	
	parametersWvBackup=parametersWv
	Duplicate/O parametersWv, parametersWvStartStep
	parametersWvStartStep = 0.05 * parametersWvStartStep
	parametersWvStartStep = abs(parametersWvStartStep[p])>0 ? parametersWvStartStep[p] : 0.02 
	//fitting...................
	VARIABLE V_fitError=0
	FuncFit NI1BC_RefinementFunction parametersWv  CalibrantXY /X=CalibrantAngles /I=1 /W=CalibrantErrors /E=parametersWvStartStep
	//fitting...................
	if(V_fitError==0)
		For(i=0;i<numpnts(ParametersNames);i+=1)
			NVAR temp=$(ParametersNames[i])
			temp = parametersWv[i]
			if(cmpstr(ParametersNames[i],"Wavelength")==0)		
				NVAR XrayEnergy=root:Packages:Convert2Dto1D:XrayEnergy 
				XrayEnergy = 12.398424437/temp
			endif
		endfor	
	else
		abort "Fitting was unsuccesful, no changes made. Make different parameter selection and try again..."
	endif


	setDataFolder OldDf
end


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************


Function NI1BC_RefinementFunction(pw, yw, xw) : FitFunc
	Wave pw, yw, xw

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	NVAR Wavelength
	NVAR SampleToCCDDistance
	NVAR BeamCenterX
	NVAR BeamCenterY
	Wave parametersWv
	Wave/T ParametersNames
	variable i
	For(i=0;i<numpnts(ParametersNames);i+=1)
		NVAR temp=$(ParametersNames[i])
		temp = parametersWv[i]
	endfor	

	variable LocalNumPnts, OldLength=0
	For(i=1;i<=5;i+=1)
		NVAR BMUseCalibrantD=$("root:Packages:Convert2Dto1D:BMUseCalibrantD"+num2str(i))
		if(BMUseCalibrantD)
			NVAR dspacing=$("root:Packages:Convert2Dto1D:BMCalibrantD"+num2str(i))
			Wave BMOptimizeAngles = $("BMOptimizeAngles"+num2str(i))
			LocalNumPnts=numpnts(BMOptimizeAngles)
			Make/O/D/N=(LocalNumPnts) tempXCalc, tempYCalc
			tempXCalc = NI1BC_CalcXYForAngleAndParam("X", BMOptimizeAngles[p], BeamCenterX, BeamCenterY,dspacing,Wavelength,SampleToCCDDistance)
			tempYCalc = NI1BC_CalcXYForAngleAndParam("Y", BMOptimizeAngles[p], BeamCenterX, BeamCenterY,dspacing,Wavelength,SampleToCCDDistance)
			yw[OldLength,(OldLength+LocalNumPnts)-1] 					=	tempXCalc[p-OldLength]
			yw[(OldLength+LocalNumPnts),(OldLength+2*LocalNumPnts)-1]	=	tempYCalc[p-(OldLength+LocalNumPnts)]
			OldLength += 2*LocalNumPnts
		endif
	endfor
	
	KillWaves/Z tempXCalc, tempYCalc

	setDataFolder OldDf
End


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************



Function NI1BC_GetEvaluationPaths(CalibrantLine,numberOfSectors)
	variable CalibrantLine, numberOfSectors

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

	NVAR BeamCenterX=root:Packages:Convert2Dto1D:BeamCenterX
	NVAR BeamCenterY=root:Packages:Convert2Dto1D:BeamCenterY
	NVAR PixelSizeX=root:Packages:Convert2Dto1D:PixelSizeX
	NVAR PixelSizeY=root:Packages:Convert2Dto1D:PixelSizeY
	NVAR SampleToCCDDistance=root:Packages:Convert2Dto1D:SampleToCCDDistance
	NVAR HorizontalTilt=root:Packages:Convert2Dto1D:HorizontalTilt
	NVAR VerticalTilt=root:Packages:Convert2Dto1D:VerticalTilt

	
	NVAR BMPathWidth=root:Packages:Convert2Dto1D:BMPathWidth
	NVAR BMUseMask=root:Packages:Convert2Dto1D:BMUseMask
	NVAR BMUseGeometryCorr=root:Packages:Convert2Dto1D:BMUseGeometryCorr
	Wave/Z M_ROIMask=root:Packages:Convert2Dto1D:M_ROIMask

	Wave BmCntrImage=root:Packages:Convert2Dto1D:BmCntrCCDImg
	if(BMUseMask && WaveExists(M_ROIMask))
		MatrixOp/O BmCntrImageMsk=BmCntrImage / M_ROIMask
	else	
		MatrixOp/O BmCntrImageMsk=BmCntrImage 
	endif
	Wave BmCntrImageMsk=root:Packages:Convert2Dto1D:BmCntrImageMsk
	//we need to get path for each direction, pick 30 directions, each therefore 6 degrees appart
	variable azimuthalAngle, i, MaxNumPixels
	MaxNumPixels=floor(sqrt(DimSize(BmCntrImage, 0 )^2 + DimSize(BmCntrImage, 0 )^2))
	
	//NVAR  BMUseCalibrantD=$("root:Packages:Convert2Dto1D:BMUseCalibrantD"+num2str(i))
	NVAR BMCalibrantD=$("root:Packages:Convert2Dto1D:BMCalibrantD"+num2str(CalibrantLine))
	NVAR BMCalibrantDLineWidth=$("root:Packages:Convert2Dto1D:BMCalibrantD"+num2str(CalibrantLine)+"LineWidth")
	variable radX = NI1BC_GetPixelFromDSpacing(BMCalibrantD, "X")
	variable radY = NI1BC_GetPixelFromDSpacing(BMCalibrantD, "Y")
	variable CalibrantRadInPix= radX 
	variable startPnt, endPnt, minX, maxX, minY, maxY
	variable angleStep=360/numberOfSectors
	Variable V_fitOptions=4
	Variable V_FitError=0
	Make/O/N=0 $("BMOptimizeAngles"+num2str(CalibrantLine)), $("BMOptimizeXs"+num2str(CalibrantLine)), $("BMOptimizeYs"+num2str(CalibrantLine)), $("BMOptimizeErrors"+num2str(CalibrantLine))
	Wave BMOptimizeAngles = $("BMOptimizeAngles"+num2str(CalibrantLine))
	Wave BMOptimizeXs = $("BMOptimizeXs"+num2str(CalibrantLine))
	Wave BMOptimizeYs = $("BMOptimizeYs"+num2str(CalibrantLine))
	Wave BMOptimizeErrors = $("BMOptimizeErrors"+num2str(CalibrantLine))
	SVAR BMFunctionName=root:Packages:Convert2Dto1D:BMFunctionName
	NVAR BMDisplayInImage=root:Packages:Convert2Dto1D:BMDisplayInImage
	
	Make/O/N=(MaxNumPixels) xwave,ywave, radialDistWv, MyProfile,xwaveT, ywaveT,GeomCorrWv		//working folder
	For(i=0;i<numberOfSectors;i+=1)
		redimension/N=(MaxNumPixels) xwave,ywave, radialDistWv, MyProfile,xwaveT, ywaveT
		CalibrantRadInPix= sqrt( (radX*cos(i * angleStep * (pi/180)))^2 + (radY*sin(i * angleStep * (pi/180)))^2)
		xwave = BeamCenterX + p*cos(i * angleStep * (pi/180))
		ywave = BeamCenterY - p*sin(i * angleStep * (pi/180))
		xwaveT = p*cos(i * angleStep * (pi/180))
		ywaveT = - p*sin(i * angleStep * (pi/180))
		radialDistWv = sqrt((xwaveT)^2 + (ywaveT)^2)
			if(BMUseGeometryCorr)
				redimension/N=(numpnts(radialDistWv)) GeomCorrWv
				NI1BC_SolidangleCorrection(radialDistWv,GeomCorrWv, (PixelSizeY+PixelSizeX)/2,SampleToCCDDistance)		//roigh approximation, for now valid strictly only for square pixels...
			endif
		startPnt = BinarySearch(radialDistWv, CalibrantRadInPix-BMCalibrantDLineWidth )
		endPnt = BinarySearch(radialDistWv, CalibrantRadInPix+BMCalibrantDLineWidth )+1
		DeletePoints endPnt, inf, xwave, ywave, GeomCorrWv
		DeletePoints 0, startPnt, xwave, ywave, GeomCorrWv
		wavestats/Q xwave
		minX=V_min
		maxX =V_max
		wavestats/Q ywave
		minY=V_min
		maxY=V_max
		if(MinX>=0 && maxX<=dimsize(BmCntrImage, 0)&&MinY>=0 && maxY<=dimsize(BmCntrImage, 1))
			ImageLineProfile xWave=xwave, yWave=ywave, srcwave=BmCntrImageMsk , width= BMPathWidth
			CheckDisplayed /A/W=CCDImageForBmCntr ywave
			if(!V_flag && BMDisplayInImage)
				AppendtoGraph/T/W=CCDImageForBmCntr ywave vs xwave
				ModifyGraph/W=CCDImageForBmCntr lsize=5,lstyle=1,rgb=(65280,16384,16384)
			endif
			Wave W_ImageLineProfile
			if(BMUseGeometryCorr)
				W_ImageLineProfile=W_ImageLineProfile*GeomCorrWv
			endif
			wavestats/Q W_ImageLineProfile
			if(V_numINFs==0 && V_numNans==0)
				DoWindow LineFitWindow
				if(!V_Flag)
					Display/K=1 W_ImageLineProfile
					DoWindow/C/T LineFitWindow,"Profile Fit window"
				endif
				DoWindow/F LineFitWindow
				V_FitError=0
				if(cmpstr(BMFunctionName,"Gauss")==0)
					CurveFit/Q/N gauss  W_ImageLineProfile /D 
				else
					CurveFit/Q/N Lor  W_ImageLineProfile /D 
				endif
				Wave W_sigma
				ModifyGraph/W=LineFitWindow mode(W_ImageLineProfile)=3,marker(W_ImageLineProfile)=19
				ModifyGraph/W=LineFitWindow rgb(W_ImageLineProfile)=(0,0,65280),lsize(fit_W_ImageLineProfile)=2
				Label/W=LineFitWindow left "Intensity"
				ModifyGraph/W=LineFitWindow mirror=1
				Label/W=LineFitWindow bottom "Pixels"
				TextBox/W=LineFitWindow/C/N=text0/A=LT "Angle = "+num2str(i * angleStep )	
				DoUpdate
				//Sleep/S 2
				Wave  W_coef // really need w_coef[2] which is the poition of center of gaussien ={134.04,71.355,30.111,12.034}
				//print num2str(i * angleStep ) +"   " + num2str(W_coef[2])
				redimension/N=(numpnts(BMOptimizeYs)+1) BMOptimizeYs, BMOptimizeXs, BMOptimizeAngles, BMOptimizeErrors
				BMOptimizeAngles[numpnts(BMOptimizeAngles)-1] = i*angleStep 
				BMOptimizeYs[numpnts(BMOptimizeAngles)-1] = ywave[W_coef[2]]
				BMOptimizeXs[numpnts(BMOptimizeAngles)-1] = xwave[W_coef[2]] 
				BMOptimizeErrors[numpnts(BMOptimizeAngles)-1] = W_sigma[2] 	
			endif
		endif	
	endfor

	KillWaves/Z BmCntrImageMsk
	setDataFolder OldDf
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_SolidangleCorrection(radialDistWv,GeomCorrWv, pixelsize,SDD) //from Dale Schaefer, needs to be checked what is it doing... 
    		wave radialDistWv,GeomCorrWv
        	variable pixelsize,SDD 
         
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

    duplicate/o radialDistWv, omega, SAP, HYP, theta 
    theta=atan(radialDistWv/SDD)		//theta here is really 2Theta, since it is angle between beam in and out... 
    SAP=PixelSize*cos(theta)		//this is projection of pixel into the direction perpendicular to the center line from sample 
   // HYP=((PixelSize*(qwave))^2+SDD^2)^(1/2)//qout is still in pixels 
    HYP=SDD/cos(theta)			//this is distance from the sample
 //       qwave=(4*pi/wavelength)*(sin(theta/2)) 
    omega=(SAP/HYP) 			//this is angle under which we see the pixel from the sample
    variable startOmega=omega[0]
    omega /= startOmega				//and this is to scale it, so the correction for center pixel is 1
    duplicate/o theta, PF 
    PF= (1+cos((theta))^2)/2			// polarization factor 
    GeomCorrWv=1/(omega^2*PF)     		//Squared because it is solid angle and the above is done for lin angle 
    killwaves/z  SAP, HYP, omega, PF,theta 
	setDataFolder OldDf
end 
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************


Function NI1BC_CalcXYForAngleAndParam(Type, Angle, BeamCenterX, BeamCenterY, dspacing,Wavelength,SampleToCCDDistance)
	variable Angle, BeamCenterX, BeamCenterY, dspacing,Wavelength,SampleToCCDDistance		//d in A, angle in degrees, centers in pixles etc...
	string Type		//X (horizontal) or Y (vertical)
	
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	NVAR PixelSizeX
	NVAR PixelSizeY
	NVAR HorizontalTilt=root:Packages:Convert2Dto1D:HorizontalTilt							//tilt in degrees
	NVAR VerticalTilt=root:Packages:Convert2Dto1D:VerticalTilt								//tilt in degrees
	variable TheoreticalDistance, pixelDistX, pixelDistY 			//distance from center of the line
	variable pixelPosXAngle, pixelPosYAngle
	//Ok, this should just return simple Bragg law with little trigonometry
	//		
	//wrong at high angles...pixelDist = 2 * SampleToCCDDistance * asin( Wavelength /(2* dspacing) )  
	variable SDDLoc=SampleToCCDDistance              
	TheoreticalDistance =  SDDLoc * tan(2* asin( Wavelength /(2* dspacing) ) )	//this is theoretical distance on detector in perfect alignment
	pixelDistX = TheoreticalDistance* cos(Angle * (pi/180))  / PixelSizeX 		//this is in pixels hom much that theoretical distance is...  in X direction corrected for azimuthal angle... 
	pixelDistY = TheoreticalDistance * (-1) * sin(Angle * (pi/180))  / PixelSizeY		//this is in pixels
	variable  SampleToCCDDistanceX = SampleToCCDDistance/PixelSizeX		//this is now in pixles aslo
	variable  SampleToCCDDistanceY = SampleToCCDDistance/PixelSizeY
	setDataFolder OldDf
	if(cmpstr(Type,"X")==0)
		return BeamCenterX + NI1T_TheoreticalToTilted(pixelDistX, SampleToCCDDistanceX, HorizontalTilt)
	elseif(cmpstr(Type,"Y")==0)
		return BeamCenterY + NI1T_TheoreticalToTilted(pixelDistY, SampleToCCDDistanceY, VerticalTilt)
	else
		return 0
	endif 
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

