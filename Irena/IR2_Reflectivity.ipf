#pragma rtGlobals=1		// Use modern global access method.



Function IR2R_ReflectivitySimpleToolMain()

	IN2G_CheckScreenSize("height",670)
	IR2R_InitializeSimpleTool()
	
	DoWindow IR2R_ReflSimpleToolMainPanel
	if(V_Flag)
		DOWIndow/K IR2R_ReflSimpleToolMainPanel
	endif
	Execute("IR2R_ReflSimpleToolMainPanel()")

end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Window IR2R_ReflSimpleToolMainPanel()
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(2.25,43.25,390,710) as "Reflectivity Simple Tool"
	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup="r*:q*;"
	string EUserLookup="r*:s*;"
	IR2C_AddDataControls("Refl_SimpleTool","IR2R_ReflSimpleToolMainPanel","DSM_Int;M_DSM_Int;","",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,1)
	SetDrawLayer UserBack
	SetDrawEnv linefgc= (65535,65535,65535),fillfgc= (60928,60928,60928)
	DrawRect 1,156,387,193
	SetDrawLayer UserBack

	SetDrawEnv fillfgc= (65280,65280,32768)
	DrawRect 1,570,387,615
	SetDrawEnv fillfgc= (32768,65280,32768)
	DrawRect 1,501,387,569
	SetDrawEnv fillfgc= (48896,59904,65280)
	DrawRect 1,235,387,264
	SetDrawEnv fname= "Times New Roman", save
	SetDrawEnv fsize= 22,fstyle= 3,textrgb= (0,0,52224)
	DrawText 58,28,"Simple reflectivity tool"
	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
	DrawLine 16,194,339,194
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 2,49,"Data input"
	SetDrawEnv fsize= 20,fstyle= 1, textrgb= (52224,0,0)
	DrawText 5,217,"Model input:"
	SetDrawEnv fsize= 12, fstyle= 1
	DrawText 200,305,"Fit?     Low limit    High limit"
	SetDrawEnv fsize= 16,fstyle= 1, textrgb= (0,0,52224)
	DrawText 10,258,"Top environment "
	SetDrawEnv fsize= 16,fstyle= 1, textrgb= (0,0,52224)
	DrawText 10,520,"Substrate "

	//************************
	Button DrawGraphs,pos={270,39},size={100,18},font="Times New Roman",fSize=10,proc=IR2R_InputPanelButtonProc,title="Graph", help={"Create a graph (log-log) of your experiment data"}, fColor=(65280,65280,48896)

	CheckBox ZeroAtTheSubstrate,pos={10,160},size={63,14},proc=IR2R_InputPanelCheckboxProc,title="0 at the substrate?"
	CheckBox ZeroAtTheSubstrate,variable= root:Packages:Refl_SimpleTool:ZeroAtTheSubstrate, help={"Check if you want to Define SLD profile with 0 at the substrate"}
	CheckBox L1AtTheBottom,pos={10,175},size={63,14},proc=IR2R_InputPanelCheckboxProc,title="L1 at the substrate?"
	CheckBox L1AtTheBottom,variable= root:Packages:Refl_SimpleTool:L1AtTheBottom, help={"Check if you want to Define SLD profile with Layer 1 at the substrate, else Layer 1 is at the top"}


	CheckBox AutoUpdate,pos={130,175},size={63,14},proc=IR2R_InputPanelCheckboxProc,title="Auto update?"
	CheckBox AutoUpdate,variable= root:Packages:Refl_SimpleTool:AutoUpdate, help={"Check if you want to update with every change inthe panel."}

	CheckBox UseErrors,pos={130,160},size={63,14},proc=IR2R_InputPanelCheckboxProc,title="Use errors?"
	CheckBox UseErrors,variable= root:Packages:Refl_SimpleTool:UseErrors, help={"Check if you want to use Intensity errors in fitting (if errors are available)"}

	PopupMenu ErrorDataName, disable=!root:Packages:Refl_SimpleTool:UseErrors

	CheckBox UseResolutionWave,pos={260,158},size={80,16},proc=IR2R_InputPanelCheckboxProc,title="Resolution wave?"
	CheckBox UseResolutionWave,variable= root:Packages:Refl_SimpleTool:UseResolutionWave, help={"Use wave for instrument resolution? Must be in the same folder as data... "}
	SetVariable Resolution,pos={260,175},size={100,16},proc=IR2R_PanelSetVarProc,title="Instr res. [%]", help={"Instrument resolution in %"}
	SetVariable Resolution,limits={0,Inf,0},variable= root:Packages:Refl_SimpleTool:Resoln, disable = (root:Packages:Refl_SimpleTool:UseResolutionWave)

	//ResolutionWaveName
	PopupMenu ResolutionWaveName,pos={220,173},size={100,16},proc=IR2R_PanelPopupControl,title="Res Wv [%]:", help={"Select wave with resolution data. Must be in % and have same number of points as other data. "}
	PopupMenu ResolutionWaveName,mode=1,popvalue="---",value= #"\"---;Create From Parameters;\"+IR2R_ResWavesList()", disable=!(root:Packages:Refl_SimpleTool:UseResolutionWave)


	PopupMenu NumberOfLevels,pos={120,198},size={140,21},proc=IR2R_PanelPopupControl,title="Number of layers :", help={"Select number of layers to use, NOTE that the layer 1 has to have the top one, layer 8 last one"}
	PopupMenu NumberOfLevels,mode=2,popvalue=num2str(WhichListItem(num2str(root:Packages:Refl_SimpleTool:NumberOfLayers), "0;1;2;3;4;5;6;7;8;")),value= #"\"0;1;2;3;4;5;6;7;8;\""

	PopupMenu FitIQN,pos={270,198},size={100,21},proc=IR2R_PanelPopupControl,title="Fit I*Q^n :", help={"For display & fitting purposes, display & fit I * Q^n (scaling to help least sqaure fitting). n=0 fits Intensity"}
	PopupMenu FitIQN,mode=2,popvalue=num2str(WhichListItem(num2str(root:Packages:Refl_SimpleTool:FitIQN), "0;1;2;3;4;")),value= #"\"0;1;2;3;4;\""


	SetVariable SLD_Real_Top,pos={140,245},size={110,16},proc=IR2R_PanelSetVarProc,title="SLD (real) "
	SetVariable SLD_Real_Top,limits={-inf,inf,0},variable= root:Packages:Refl_SimpleTool:SLD_Real_Top, help={"SLD (real part) of top material"}
	SetVariable SLD_Imag_Top,pos={270,245},size={110,16},proc=IR2R_PanelSetVarProc,title="SLD (imag) "
	SetVariable SLD_Imag_Top,limits={-inf,inf,0},variable= root:Packages:Refl_SimpleTool:SLD_Imag_Top, help={"SLD (imag part) of top material"}


//	SetDrawEnv linebgc= (56576,56576,56576)
//	SetDrawEnv linepat= 4
	SetDrawEnv fillpat= 2
	SetDrawEnv fillfgc= (56576,56576,56576)
	DrawRect 10,380,375,403
	SetDrawEnv fsize= 12
	DrawText 20,398,"SLD units - either * 10^-6 [1/A^2] or * 10^10  [1/cm^2]"
//	CheckBox SLDinA,pos={150,383},size={40,16},proc=IR2R_InputPanelCheckboxProc,fSize=12, title=" * 10\S-6\M [1/A\S2\M]?", mode=1
//	CheckBox SLDinA,variable= root:Packages:Refl_SimpleTool:SLDinA, help={"Input SLD in 1/A, Do not use the usual 10^-6? "}
//	CheckBox SLDinCm,pos={250,383},size={40,16},proc=IR2R_InputPanelCheckboxProc,fSize=12, title=" * 10\S10\M  [1/cm\S2\M]?", mode=1
//	CheckBox SLDinCm,variable= root:Packages:Refl_SimpleTool:SLDinCm, help={"Input SLD in 1/cm, do not insert the usual 10^10? "}


	SetVariable ScalingFactor,pos={8,220},size={160,16},proc=IR2R_PanelSetVarProc,title="ScalingFactor", fstyle=1
	SetVariable ScalingFactor,limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:ScalingFactor, help={"ScalingFactor - 1 if data corrected correctly"}
	CheckBox FitScalingFactor,pos={200,220},size={80,16},proc=IR2R_InputPanelCheckboxProc,title=""
	CheckBox FitScalingFactor,variable= root:Packages:Refl_SimpleTool:FitScalingFactor, help={"Fit FitScalingFactor?, "}
	SetVariable ScalingFactorLL,pos={230,220},size={60,16},proc=IR2R_PanelSetVarProc, title=" "
	SetVariable ScalingFactorLL,limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:ScalingFactorLL, help={"Low limit for ScalingFactor"}
	SetVariable ScalingFactorUL,pos={300,220},size={60,16},proc=IR2R_PanelSetVarProc, title=" "
	SetVariable ScalingFactorUL,limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:ScalingFactorUL, help={"High limit for ScalingFactor"}

	SetVariable Roughness_Bot,pos={14,525},size={160,16},proc=IR2R_PanelSetVarProc,title="Roughness "
	SetVariable Roughness_Bot,limits={0,inf,1},variable= root:Packages:Refl_SimpleTool:Roughness_Bot, help={"Roughness of the substrate material"}
	CheckBox FitRoughness_Bot,pos={200,525},size={80,16},proc=IR2R_InputPanelCheckboxProc,title=" "
	CheckBox FitRoughness_Bot,variable= root:Packages:Refl_SimpleTool:FitRoughness_Bot, help={"Fit roughness of substrate?, find god starting conditions and select fitting limits..."}
	SetVariable Roughness_BotLL,pos={230,525},size={60,16},proc=IR2R_PanelSetVarProc, title=" "
	SetVariable Roughness_BotLL,limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:Roughness_BotLL, help={"Low limit for substrate Roughness"}
	SetVariable Roughness_BotUL,pos={300,525},size={60,16},proc=IR2R_PanelSetVarProc, title=" "
	SetVariable Roughness_BotUL,limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:Roughness_BotUL, help={"High limit for substrate Roughness"}

	SetVariable SLD_real_Bot,pos={14,550},size={150,16},proc=IR2R_PanelSetVarProc,title="SLD (real) "
	SetVariable SLD_Real_Bot,limits={-inf,inf,0},variable= root:Packages:Refl_SimpleTool:SLD_Real_Bot, help={"SLD (real part) of substrate material"}
	SetVariable SLD_Imag_Bot,pos={190,550},size={150,16},proc=IR2R_PanelSetVarProc,title="SLD (imag) "
	SetVariable SLD_Imag_Bot,limits={-inf,inf,0},variable= root:Packages:Refl_SimpleTool:SLD_Imag_Bot, help={"SLD (real part) of substrate material"}


	SetVariable Background,pos={10,575},size={160,16},proc=IR2R_PanelSetVarProc,title="Background", help={"Background"}
	SetVariable Background,limits={0,Inf,root:Packages:Refl_SimpleTool:BackgroundStep},variable= root:Packages:Refl_SimpleTool:Background
	SetVariable BackgroundStep,pos={25,595},size={160,16},title="Background step",proc=IR2R_PanelSetVarProc, help={"Step for increments in background"}
	SetVariable BackgroundStep,limits={0,Inf,0},variable= root:Packages:Refl_SimpleTool:BackgroundStep
	CheckBox FitBackground,pos={200,575},size={63,14},proc=IR2R_InputPanelCheckboxProc,title=" "
	CheckBox FitBackground,variable= root:Packages:Refl_SimpleTool:FitBackground, help={"Check if you want the background to be fitting parameter"}
	SetVariable BackgroundLL,pos={230,575},size={60,16},proc=IR2R_PanelSetVarProc, title=" "
	SetVariable BackgroundLL,limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:BackgroundLL, help={"Low limit for Background"}
	SetVariable BackgroundUL,pos={300,575},size={60,16},proc=IR2R_PanelSetVarProc, title=" "
	SetVariable BackgroundUL,limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:BackgroundUL, help={"High limit for Background"}
	
	

	Button CalculateModel,pos={5,620},size={90,20},font="Times New Roman",fSize=10,proc=IR2R_InputPanelButtonProc,title="Graph model", help={"Graph model data and calculate reflectivity"}
	Button Fitmodel,pos={5,645},size={90,20},font="Times New Roman",fSize=10,proc=IR2R_InputPanelButtonProc,title="Fit model", help={"Fit modto data"}
	Button SaveDataBtn,pos={195,620},size={90,20},font="Times New Roman",fSize=10,proc=IR2R_InputPanelButtonProc,title="Save data", help={"Save data"}
	Button ExportData,pos={290,620},size={90,20},font="Times New Roman",fSize=10,proc=IR2R_InputPanelButtonProc,title="Export data", help={"Export data"}

	Button ReversFit,pos={100,645},size={90,20},font="Times New Roman",fSize=10,proc=IR2R_InputPanelButtonProc,title="Reverse fit", help={"Fit modto data"}


	CheckBox UpdateDuringFitting,pos={200,646},size={80,16},noproc,title="Update while fitting?"
	CheckBox UpdateDuringFitting,variable= root:Packages:Refl_SimpleTool:UpdateDuringFitting, help={"Update graph during fitting? Will slow things down!!! "}

	CheckBox UseGenOpt,pos={100,618},size={25,90},proc=IR2R_InputPanelCheckboxProc,title="Genetic Opt.?", mode=1
	CheckBox UseGenOpt,variable= root:Packages:Refl_SimpleTool:UseGenOpt, help={"Use genetic Optimization? SLOW..."}
	CheckBox UseLSQF,pos={100,630},size={25,90},proc=IR2R_InputPanelCheckboxProc,title="LSQF?", mode=1
	CheckBox UseLSQF,variable= root:Packages:Refl_SimpleTool:UseLSQF, help={"Use LSQF?"}

	//Dist Tabs definition
	TabControl DistTabs,pos={3,265},size={380,230},proc=IR2R_TabPanelControl
	TabControl DistTabs,fSize=10,tabLabel(0)="L 1",tabLabel(1)="L 2"
	TabControl DistTabs,tabLabel(2)="L 3",tabLabel(3)="L 4",value= 0
	TabControl DistTabs,tabLabel(4)="L 5",tabLabel(5)="L 6"
	TabControl DistTabs,tabLabel(6)="L 7",tabLabel(7)="L 8"

	variable i=1
	Do	
		Execute("TitleBox LayerTitleBox"+num2str(i)+", title=\"   Layer "+num2str(i)+"  \", frame=1, labelBack=("+num2str(4000*i)+","+num2str(6000*(i))+","+num2str(4000*(8-i))+"), pos={14,285}, fstyle=1,size={200,8},fColor=(65535,65535,65535)")
		Execute("SetVariable ThicknessLayer"+num2str(i)+",pos={8,308},size={160,16},proc=IR2R_PanelSetVarProc,title=\"Thickness [A]   \", fstyle=1")
		Execute("SetVariable ThicknessLayer"+num2str(i)+",limits={0,inf,root:Packages:Refl_SimpleTool:ThicknessLayerStep"+num2str(i)+"},variable= root:Packages:Refl_SimpleTool:ThicknessLayer"+num2str(i)+", help={\"Layer Thickness in A\"}")
		Execute("SetVariable ThicknessLayerStep"+num2str(i)+",pos={10,325},size={160,16},proc=IR2R_PanelSetVarProc,title=\"Thickness step   \"")
		Execute("SetVariable ThicknessLayerStep"+num2str(i)+",limits={0,inf,1},variable= root:Packages:Refl_SimpleTool:ThicknessLayerStep"+num2str(i)+", help={\"Layer Thickness step to take above\"}")
		Execute("CheckBox FitThicknessLayer"+num2str(i)+",pos={200,308},size={80,16},proc=IR2R_InputPanelCheckboxProc,title=\" \"")
		Execute("CheckBox FitThicknessLayer"+num2str(i)+",variable= root:Packages:Refl_SimpleTool:FitThicknessLayer"+num2str(i)+", help={\"Fit thickness surface?, find god starting conditions and select fitting limits...\"}")
		Execute("SetVariable ThicknessLayerLL"+num2str(i)+",pos={230,308},size={60,16},proc=IR2R_PanelSetVarProc, title=\" \"")
		Execute("SetVariable ThicknessLayerLL"+num2str(i)+",limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:ThicknessLayerLL"+num2str(i)+", help={\"Low limit for thickness\"}")
		Execute("SetVariable ThicknessLayerUL"+num2str(i)+",pos={300,308},size={60,16},proc=IR2R_PanelSetVarProc, title=\" \"")
		Execute("SetVariable ThicknessLayerUL"+num2str(i)+",limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:ThicknessLayerUL"+num2str(i)+", help={\"High limit for thickness\"}")

		Execute("SetVariable SLD_Real_Layer"+num2str(i)+",pos={8,345},size={160,16},proc=IR2R_PanelSetVarProc,title=\"SLD (real)  \", fstyle=1")
		Execute("SetVariable SLD_Real_Layer"+num2str(i)+",limits={-inf,inf,root:Packages:Refl_SimpleTool:SLD_Real_LayerStep"+num2str(i)+"},variable= root:Packages:Refl_SimpleTool:SLD_Real_Layer"+num2str(i)+", help={\"Layer SLD (real part)\"}")
		Execute("SetVariable SLD_Real_LayerStep"+num2str(i)+",pos={10,362},size={160,16},proc=IR2R_PanelSetVarProc,title=\"SLD (real) step   \"")
		Execute("SetVariable SLD_Real_LayerStep"+num2str(i)+",limits={-inf,inf,1},variable= root:Packages:Refl_SimpleTool:SLD_Real_LayerStep"+num2str(i)+", help={\"Layer SLD (real) step to take above\"}")
		Execute("CheckBox FitSLD_Real_Layer"+num2str(i)+",pos={200,345},size={80,16},proc=IR2R_InputPanelCheckboxProc,title=\" \"")
		Execute("CheckBox FitSLD_Real_Layer"+num2str(i)+",variable= root:Packages:Refl_SimpleTool:FitSLD_Real_Layer"+num2str(i)+", help={\"Fit SLD?, find god starting conditions and select fitting limits...\"}")
		Execute("SetVariable SLD_Real_LayerLL"+num2str(i)+",pos={230,345},size={60,16},proc=IR2R_PanelSetVarProc, title=\" \"")
		Execute("SetVariable SLD_Real_LayerLL"+num2str(i)+",limits={-inf,inf,0},variable= root:Packages:Refl_SimpleTool:SLD_Real_LayerLL"+num2str(i)+", help={\"Low limit for SLD\"}")
		Execute("SetVariable SLD_Real_LayerUL"+num2str(i)+",pos={300,345},size={60,16},proc=IR2R_PanelSetVarProc, title=\" \"")
		Execute("SetVariable SLD_Real_LayerUL"+num2str(i)+",limits={-inf,inf,0},variable= root:Packages:Refl_SimpleTool:SLD_Real_LayerUL"+num2str(i)+", help={\"High limit for SLD\"}")

		Execute("SetVariable SLD_Imag_Layer"+num2str(i)+",pos={8,410},size={160,16},proc=IR2R_PanelSetVarProc,title=\"SLD (imag)  \", fstyle=1")
		Execute("SetVariable SLD_Imag_Layer"+num2str(i)+",limits={-inf,inf,root:Packages:Refl_SimpleTool:SLD_Imag_LayerStep"+num2str(i)+"},variable= root:Packages:Refl_SimpleTool:SLD_Imag_Layer"+num2str(i)+", help={\"Layer SLD (imag part) in A\"}")
		Execute("SetVariable SLD_Imag_LayerStep"+num2str(i)+",pos={10,427},size={160,16},proc=IR2R_PanelSetVarProc,title=\"SLD (imag) step   \"")
		Execute("SetVariable SLD_Imag_LayerStep"+num2str(i)+",limits={-inf,inf,1},variable= root:Packages:Refl_SimpleTool:SLD_Imag_LayerStep"+num2str(i)+", help={\"Layer SLD (imag) step to take above\"}")
		Execute("CheckBox FitSLD_Imag_Layer"+num2str(i)+",pos={200,410},size={80,16},proc=IR2R_InputPanelCheckboxProc,title=\" \"")
		Execute("CheckBox FitSLD_Imag_Layer"+num2str(i)+",variable= root:Packages:Refl_SimpleTool:FitSLD_Imag_Layer"+num2str(i)+", help={\"Fit SLD?, find god starting conditions and select fitting limits...\"}")
		Execute("SetVariable SLD_Imag_LayerLL"+num2str(i)+",pos={230,410},size={60,16},proc=IR2R_PanelSetVarProc, title=\" \"")
		Execute("SetVariable SLD_Imag_LayerLL"+num2str(i)+",limits={-inf,inf,0},variable= root:Packages:Refl_SimpleTool:SLD_Imag_LayerLL"+num2str(i)+", help={\"Low limit for SLD\"}")
		Execute("SetVariable SLD_Imag_LayerUL"+num2str(i)+",pos={300,410},size={60,16},proc=IR2R_PanelSetVarProc, title=\" \"")
		Execute("SetVariable SLD_Imag_LayerUL"+num2str(i)+",limits={-inf,inf,0},variable= root:Packages:Refl_SimpleTool:SLD_Imag_LayerUL"+num2str(i)+", help={\"High limit for SLD\"}")

		Execute("SetVariable RoughnessLayer"+num2str(i)+",pos={8,450},size={160,16},proc=IR2R_PanelSetVarProc,title=\"Roughness  \", fstyle=1")
		Execute("SetVariable RoughnessLayer"+num2str(i)+",limits={0,inf,root:Packages:Refl_SimpleTool:RoughnessLayerStep"+num2str(i)+"},variable= root:Packages:Refl_SimpleTool:RoughnessLayer"+num2str(i)+", help={\"Layer roughness \"}")
		Execute("SetVariable RoughnessLayerStep"+num2str(i)+",pos={10,467},size={160,16},proc=IR2R_PanelSetVarProc,title=\"Roughness step   \"")
		Execute("SetVariable RoughnessLayerStep"+num2str(i)+",limits={0,inf,1},variable= root:Packages:Refl_SimpleTool:RoughnessLayerStep"+num2str(i)+", help={\"Layer roughness step to take above\"}")
		Execute("CheckBox FitRoughnessLayer"+num2str(i)+",pos={200,450},size={80,16},proc=IR2R_InputPanelCheckboxProc,title=\" \"")
		Execute("CheckBox FitRoughnessLayer"+num2str(i)+",variable= root:Packages:Refl_SimpleTool:FitRoughnessLayer"+num2str(i)+", help={\"Fit roughness?, find god starting conditions and select fitting limits...\"}")
		Execute("SetVariable RoughnessLayerLL"+num2str(i)+",pos={230,450},size={60,16},proc=IR2R_PanelSetVarProc, title=\" \"")
		Execute("SetVariable RoughnessLayerLL"+num2str(i)+",limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:RoughnessLayerLL"+num2str(i)+", help={\"Low limit for roughness\"}")
		Execute("SetVariable RoughnessLayerUL"+num2str(i)+",pos={300,450},size={60,16},proc=IR2R_PanelSetVarProc, title=\" \"")
		Execute("SetVariable RoughnessLayerUL"+num2str(i)+",limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:RoughnessLayerUL"+num2str(i)+", help={\"High limit for roughness\"}")
	i+=1
	while(i<=8)	
	//endfor

	IR2R_TabPanelControl("",0)
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function/T IR2R_ResWavesList()

	string TopPanel=WinName(0,64)
	SVAR ControlProcsLocations=root:Packages:IrenaControlProcs:ControlProcsLocations
	string CntrlLocation="root:Packages:"+StringByKey(TopPanel, ControlProcsLocations)
	SVAR Dtf=$(CntrlLocation+":DataFolderName")
	string tempresult=IN2G_CreateListOfItemsInFolder(Dtf,2)
	return tempresult
end


Function IR2R_GraphMeasuredData()
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool
	SVAR DataFolderName
	SVAR IntensityWaveName
	SVAR QWavename
	SVAR ErrorWaveName
	
	//fix for liberal names
	IntensityWaveName = PossiblyQuoteName(IntensityWaveName)
	QWavename = PossiblyQuoteName(QWavename)
	ErrorWaveName = PossiblyQuoteName(ErrorWaveName)
	
	WAVE/Z test=$(DataFolderName+IntensityWaveName)
	if (!WaveExists(test))
		abort "Error in IntensityWaveName wave selection"
	endif
	Duplicate/O $(DataFolderName+IntensityWaveName), OriginalIntensity

	WAVE/Z test=$(DataFolderName+QWavename)
	if (!WaveExists(test))
		abort "Error in QWavename wave selection"
	endif
	Duplicate/O $(DataFolderName+QWavename), OriginalQvector
	WAVE/Z test=$(DataFolderName+ErrorWaveName)
	if (!WaveExists(test))
		//no error wave provided - fudge one with 1 in it...
		Duplicate/O $(DataFolderName+IntensityWaveName), OriginalError
		Wave OriginalError
		OriginalError=0
		//abort "Error in ErrorWaveName wave selection"
	else
		Duplicate/O $(DataFolderName+ErrorWaveName), OriginalError
	endif
	Redimension/D OriginalIntensity, OriginalQvector, OriginalError

	DoWindow IR2R_LogLogPlotRefl
	if (V_flag)
		Dowindow/K IR2R_LogLogPlotRefl
	endif
	Execute ("IR2R_LogLogPlotRefl()")
	
	//create different view on data (may be fitting view?)
	Duplicate/O OriginalIntensity, IntensityQN
	Duplicate/O OriginalQvector, QvectorToN
	Duplicate/O OriginalError, ErrorQN
	NVAR FitIQN=root:Packages:Refl_SimpleTool:FitIQN	
	
	IntensityQN = OriginalIntensity * OriginalQvector^FitIQN
	QvectorToN = OriginalQvector^FitIQN
	ErrorQN = OriginalError  * OriginalQvector^FitIQN
	

		DoWindow IR2R_IQN_Q_PlotV
		if (V_flag)
			Dowindow/K IR2R_IQN_Q_PlotV
		endif
		Execute ("IR2R_IQN_Q_PlotV()")

		IR2R_CalculateSLDProfile()
		DoWindow IR2R_SLDProfile
		if (V_flag)
			Dowindow/K IR2R_SLDProfile
		endif
		Execute ("IR2R_SLDProfile()")
	AutopositionWindow/E/M=0 /R=IR2R_ReflSimpleToolMainPanel  IR2R_LogLogPlotRefl
	AutopositionWindow/E/M=1 /R=IR2R_LogLogPlotRefl IR2R_IQN_Q_PlotV
	AutopositionWindow/E/M=1 /R=IR2R_IQN_Q_PlotV IR2R_SLDProfile
	
	
	setDataFolder oldDf
end

Proc  IR2R_LogLogPlotRefl() 
	PauseUpdate; Silent 1		// building window...
	String fldrSav= GetDataFolder(1)
	SetDataFolder root:Packages:Refl_SimpleTool
	Display /W=(300,37.25,850,300)/K=1  OriginalIntensity vs OriginalQvector as "LogLogPlot"
	DoWIndow/C IR2R_LogLogPlotRefl
	ModifyGraph mode(OriginalIntensity)=3
	ModifyGraph msize(OriginalIntensity)=1
	ModifyGraph log(left)=1
	ModifyGraph mirror=1
	ShowInfo
	Label left "Reflectivity"
	Label bottom "Q [A\\S-1\\M]"
	TextBox/W=IR2R_LogLogPlotRefl/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	TextBox/W=IR2R_LogLogPlotRefl/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z07"+DataFolderName+IntensityWaveName	
	Legend/W=IR2R_LogLogPlotRefl/N=text0/J/F=0/A=MC/X=32.03/Y=38.79 "\\s(OriginalIntensity) Experimental intensity"
	SetDataFolder fldrSav
	ErrorBars/Y=1 OriginalIntensity Y,wave=(root:Packages:Refl_SimpleTool:OriginalError,root:Packages:Refl_SimpleTool:OriginalError)
EndMacro

Proc  IR2R_IQN_Q_PlotV() 
	PauseUpdate; Silent 1		// building window...
	String fldrSav= GetDataFolder(1)
	SetDataFolder root:Packages:Refl_SimpleTool:
	Display /W=(300,250,850,430)/K=1  IntensityQN vs OriginalQvector as "IQ^N_Q_Plot"
	DoWIndow/C IR2R_IQN_Q_PlotV
	ModifyGraph mode(IntensityQN)=3
	ModifyGraph msize(IntensityQN)=1
	ModifyGraph log=1
	ModifyGraph mirror=1
	Label left "Reflectivity * Q^n"
	Label bottom "Q [A\\S-1\\M]"
	TextBox/W=IR2R_IQN_Q_PlotV/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	TextBox/W=IR2R_IQN_Q_PlotV/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z07"+DataFolderName+IntensityWaveName	
	SetDataFolder fldrSav
	ErrorBars/Y=1 IntensityQN Y,wave=(root:Packages:Refl_SimpleTool:ErrorQN,root:Packages:Refl_SimpleTool:ErrorQN)
EndMacro

Proc  IR2R_SLDProfile()
	PauseUpdate; Silent 1		// building window...
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:Refl_SimpleTool:
	Display /W=(298.5,390.5,847.5,567.5)/K=1 SLDProfile as "SLD profile (top=left, substrate=right)"
	DoWindow/C IR2R_SLDProfile
	Label left "SLD profile [A\\S-2\\M]"
	if(ZeroAtTheSubstrate)
		Label bottom "<<--Substrate                                               Layer thickness [A]                                         Top -->>"
		DoWindow/T IR2R_SLDProfile,"SLD profile (substrate=left, top=right)"
	else
		Label bottom "<<--TOP                                               Layer thickness [A]                                         Substrate -->>"
		DoWindow/T IR2R_SLDProfile,"SLD profile (top=left, substrate=right) "
	endif
	SetDataFolder fldrSav0
EndMacro


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2R_InitializeSimpleTool()

	string oldDf=GetDataFolder(1)
	
	NewDataFolder/O/S root:Packages
	NewdataFolder/O/S root:Packages:Refl_SimpleTool
	
	string ListOfVariables
	string ListOfStrings
	
	//here define the lists of variables and strings needed, separate names by ;...
	
	ListOfVariables="NumberOfLayers;ActiveTab;AutoUpdate;FitIQN;Resoln;UpdateAutomatically;ActiveTab;UseErrors;UseResolutionWave;UseLSQF;UseGenOpt;"
	ListOfVariables+="SLD_Real_Top;SLD_Imag_Top;SLD_Real_Bot;SLD_Imag_Bot;ZeroAtTheSubstrate;UpdateDuringFitting;"
	ListOfVariables+="Roughness_Bot;FitRoughness_Bot;Roughness_BotLL;Roughness_BotUL;Roughness_BotError;"
	ListOfVariables+="Background;BackgroundStep;FitBackground;BackgroundLL;BackgroundUL;BackgroundError;"
	ListOfVariables+="L1AtTheBottom;"

	ListOfVariables+="Res_DeltaLambdaOverLambda;Res_DeltaLambda;Res_Lambda;Res_SourceDivergence;Res_DetectorSize;Res_DetectorDistance;"
	ListOfVariables+="Res_DetectorAngularResolution;Res_sampleSize;Res_beamHeight;"
	ListOfVariables+="ScalingFactor;ScalingFactorLL;ScalingFactorUL;FitScalingFactor;ScalingFactorError;"
	
	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;ResolutionWaveName;"
	
	variable i, j
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
// create 8 x this following list:
	ListOfVariables="SLD_Real_Layer;SLD_Imag_Layer;ThicknessLayer;RoughnessLayer;"
	ListOfVariables+="SLD_Real_LayerError;SLD_Imag_LayerError;ThicknessLayerError;RoughnessLayerError;"
	ListOfVariables+="SLD_Real_LayerStep;SLD_Imag_LayerStep;ThicknessLayerStep;RoughnessLayerStep;"
	ListOfVariables+="SLD_Real_LayerLL;SLD_Imag_LayerLL;ThicknessLayerLL;RoughnessLayerLL;"
	ListOfVariables+="SLD_Real_LayerUL;SLD_Imag_LayerUL;ThicknessLayerUL;RoughnessLayerUL;"
	ListOfVariables+="FitSLD_Real_Layer;FitSLD_Imag_Layer;FitThicknessLayer;FitRoughnessLayer;"
	for(j=1;j<=8;j+=1)	
		for(i=0;i<itemsInList(ListOfVariables);i+=1)	
			IN2G_CreateItem("variable",StringFromList(i,ListOfVariables)+num2str(j))
		endfor		
	endfor
										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	//cleanup after possible previous fitting stages...
	Wave/Z CoefNames=root:Packages:FractalsModel:CoefNames
	Wave/Z CoefficientInput=root:Packages:FractalsModel:CoefficientInput
	KillWaves/Z CoefNames, CoefficientInput
	
	IR2R_SetInitialValues()		
	setDataFolder oldDF

end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
/////******************************************************************************************
//
Function IR2R_SetInitialValues()
//	//and here set default values...
//
	string OldDf=getDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool
//	
	string ListOfVariables
	variable i, j
	
	//	here we set what needs to be 0
	ListOfVariables="SLD_Real_Top;SLD_Imag_Top;Background;Roughness_Bot;FitIQN;FitBackground;BackgroundLL;BackgroundUL;UpdateAutomatically;FitRoughness_Bot;Roughness_BotLL;Roughness_BotUL;"
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		testVar=0
	endfor
		
	//and here to 1
	ListOfVariables="NumberOfLayers;Resoln;UseErrors;ScalingFactor;"
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=1
		endif
	endfor
	ListOfVariables="FitIQN;"
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=4
		endif
	endfor

	ListOfVariables="ScalingFactorLL;"
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=0.1
		endif
	endfor

	ListOfVariables="ScalingFactorUL;"
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=2
		endif
	endfor
	
	
	NVAR SLD_Real_Bot
	if(SLD_Real_Bot==0)
		SLD_Real_Bot = 2.073
	endif

	NVAR SLD_Imag_Bot
	if(SLD_Imag_Bot==0)
		SLD_Imag_Bot = 2.37e-5
	endif
	
	NVAR UseLSQF
	NVAR UseGenOpt
	if((UseLSQF+UseGenOpt)!=1)
		UseLSQF=1
		UseGenOpt=0
	endif

	For(j=1;j<=8;j+=1)
		//set to 0
		ListOfVariables="RoughnessLayer;SolventPenetrationLayer;"
		For(i=0;i<itemsInList(ListOfVariables);i+=1)
			NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+num2str(j))
			if (testVar==0)
				testVar=0
			endif
		endfor
		ListOfVariables="RoughnessLayerStep;SolventPenetrationLayerStep;"
		For(i=0;i<itemsInList(ListOfVariables);i+=1)
			NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+num2str(j))
			if (testVar==0)
				testVar=0.3
			endif
		endfor
		ListOfVariables="FitSLD_Real_Layer;FitSLD_Imag_Layer;FitThicknessLayer;FitRoughnessLayer;FitSolventPenetrationLayer;"
		For(i=0;i<itemsInList(ListOfVariables);i+=1)
			NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+num2str(j))
			if (testVar==0)
				testVar=0
			endif
		endfor
		//set to 25
		ListOfVariables="ThicknessLayer;"
		For(i=0;i<itemsInList(ListOfVariables);i+=1)
			NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+num2str(j))
			if (testVar==0)
				testVar=25
			endif
		endfor
		//set to 25
		ListOfVariables="ThicknessLayerStep;"
		For(i=0;i<itemsInList(ListOfVariables);i+=1)
			NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+num2str(j))
			if (testVar==0)
				testVar=5
			endif
		endfor
		//set to 3.47e-6
		ListOfVariables="SLD_Real_Layer;"
		For(i=0;i<itemsInList(ListOfVariables);i+=1)
			NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+num2str(j))
			if (testVar==0)
				testVar=3.47
			endif
		endfor
		//set to 3.47e-6
		ListOfVariables="SLD_Real_LayerStep;"
		For(i=0;i<itemsInList(ListOfVariables);i+=1)
			NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+num2str(j))
			if (testVar==0)
				testVar=0.1
			endif
		endfor
		//set to 3.47e-6
		ListOfVariables="SLD_Imag_Layer;"
		For(i=0;i<itemsInList(ListOfVariables);i+=1)
			NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+num2str(j))
			if (testVar==0)
				testVar=1.05e-5
			endif
		endfor
		//set to 3.47e-6
		ListOfVariables="SLD_Imag_LayerStep;"
		For(i=0;i<itemsInList(ListOfVariables);i+=1)
			NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+num2str(j))
			if (testVar==0)
				testVar=1e-6
			endif
		endfor
	
		
	endfor
	IR2R_SetErrorsToZero()
	setDataFolder oldDF
end
//
//
/////******************************************************************************************
/////******************************************************************************************
/////******************************************************************************************
/////******************************************************************************************
/////******************************************************************************************
/////******************************************************************************************
Function IR2R_SetErrorsToZero()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool

	string ListOfVariables="Roughness_BotError;BackgroundError;"
	variable i,j
	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		testVar=0
	endfor

	ListOfVariables="SLD_Real_Layer;SLD_Imag_Layer;ThicknessLayer;RoughnessLayer;SolventPenetrationLayer;"

	For(j=1;j<9;j+=1)
		For(i=0;i<itemsInList(ListOfVariables);i+=1)
			NVAR/Z testVar=$(StringFromList(i,ListOfVariables)+"Error"+num2str(j))
			testVar=0
		endfor
	endfor

	setDataFolder oldDF

end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR2R_CalculateSLDProfile()
	//this function calculates model data
//	make/o/t parameters_Cref = {"Numlayers","scale","re_SLDtop","imag_SLDtop","re_SLDbase","imag_SLD base","bkg","sigma_base","thick1","re_SLD1","imag_SLD1","rough1","thick2","re_SLD2","imag_SLD2","rough2"}
//	Edit parameters_Cref,coef_Cref,par_res,resolution
//	ywave_Cref:= Motofit_Imag(coef_Cref,xwave_Cref)

	variable i, j
	string OldDf=getDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool

		//Need to create wave with parameters for Motofit_Imag here
	NVAR NumberOfLayers= root:Packages:Refl_SimpleTool:NumberOfLayers
	variable NumPntsInSLDPlot=NumberOfLayers * 200+50
	make/O/N=(NumPntsInSLDPlot) SLDThicknessWv, SLDProfile
	//need 8 parameters to start with - numLayers, scale, TopSLD_real, TopSLD_Imag, Bot_SLD_real, BotSLD_imag, Background, SubstareRoughness, and then 4 parameters for each layer 
	// thickness, re_SLD, imag_SLD and roughness
	variable NumPointsNeeded= NumberOfLayers * 4 + 8
	
	make/O/N=(NumPointsNeeded) SLDParametersIn
	//now let's fill this in
	SLDParametersIn[0] = NumberOfLayers
	NVAR ScalingFactor=root:Packages:Refl_SimpleTool:ScalingFactor
	NVAR SLD_Real_Top=root:Packages:Refl_SimpleTool:SLD_Real_Top
	NVAR SLD_Imag_Top=root:Packages:Refl_SimpleTool:SLD_Imag_Top
	NVAR SLD_Real_Bot=root:Packages:Refl_SimpleTool:SLD_Real_Bot
	NVAR SLD_Imag_Bot=root:Packages:Refl_SimpleTool:SLD_Imag_Bot
	NVAR Background=root:Packages:Refl_SimpleTool:Background
	NVAR Roughness_Bot=root:Packages:Refl_SimpleTool:Roughness_Bot	
	NVAR L1AtTheBottom=root:Packages:Refl_SimpleTool:L1AtTheBottom
	
	SLDParametersIn[1] = ScalingFactor		
	SLDParametersIn[2] = SLD_Real_Top
	SLDParametersIn[3] = SLD_Imag_Top
	SLDParametersIn[4] = SLD_Real_Bot
	SLDParametersIn[5] = SLD_Imag_Bot
	SLDParametersIn[6] = Background
	SLDParametersIn[7] = Roughness_Bot

	//fix to allow L1 at the bottom
	if(L1AtTheBottom)
		j=0
		for(i=NumberOfLayers;i>=1;i-=1)
			j+=1
			NVAR ThicknessLayer= $("root:Packages:Refl_SimpleTool:ThicknessLayer"+Num2str(i))
			NVAR SLD_real_Layer = $("root:Packages:Refl_SimpleTool:SLD_Real_Layer"+Num2str(i))
			NVAR SLD_imag_Layer = $("root:Packages:Refl_SimpleTool:SLD_Imag_Layer"+Num2str(i))
			NVAR RoughnessLayer = $("root:Packages:Refl_SimpleTool:RoughnessLayer"+Num2str(i))
			SLDParametersIn[7+(j-1)*4+1] =  ThicknessLayer
			SLDParametersIn[7+(j-1)*4+2] =  SLD_real_Layer
			SLDParametersIn[7+(j-1)*4+3] =  SLD_imag_Layer
			SLDParametersIn[7+(j-1)*4+4] =  RoughnessLayer
		endfor
	else
		for(i=1;i<=NumberOfLayers;i+=1)
			NVAR ThicknessLayer= $("root:Packages:Refl_SimpleTool:ThicknessLayer"+Num2str(i))
			NVAR SLD_real_Layer = $("root:Packages:Refl_SimpleTool:SLD_Real_Layer"+Num2str(i))
			NVAR SLD_imag_Layer = $("root:Packages:Refl_SimpleTool:SLD_Imag_Layer"+Num2str(i))
			NVAR RoughnessLayer = $("root:Packages:Refl_SimpleTool:RoughnessLayer"+Num2str(i))
			SLDParametersIn[7+(i-1)*4+1] =  ThicknessLayer
			SLDParametersIn[7+(i-1)*4+2] =  SLD_real_Layer
			SLDParametersIn[7+(i-1)*4+3] =  SLD_imag_Layer
			SLDParametersIn[7+(i-1)*4+4] =  RoughnessLayer
		endfor
	endif


	//setup the thickness scaling... 
	variable zstart
        if (NumberOfLayers==0)
                zstart=-4*abs(Roughness_Bot)	//roughness substrate
        else
 		  NVAR RoughnessLayer = root:Packages:Refl_SimpleTool:RoughnessLayer1
               zstart=-4*abs(RoughnessLayer)	//roughness first layer 
        endif
	  
	variable zend, temp
        
        temp=0
        if (NumberOfLayers==0)
                zend=4*abs(Roughness_Bot)	//roughness substrate
        else    
		for(i=1;i<=NumberOfLayers;i+=1)
			NVAR ThicknessLayer= $("root:Packages:Refl_SimpleTool:ThicknessLayer"+Num2str(i))
			temp+=ThicknessLayer
		endfor            
   		  NVAR RoughnessLayer = root:Packages:Refl_SimpleTool:RoughnessLayer1
           zend=temp+4*abs(RoughnessLayer)
        endif
        variable totalLength = zend - zstart
        zstart = zstart- floor( 0.04 * totalLength)
        zend = zend + floor( 0.04 * totalLength)
	SetScale/I x zstart,zend,"", SLDProfile

//	Duplicate/O OriginalQvector, ModelQvector, ModelIntensity
//	ModelIntensity=Calcreflectivity_Imag(ParametersIn,ModelQvector)
//	variable/g plotyp=2
//	ModelIntensity=Motofit_Imag(ParametersIn,ModelQvector)
	SLDProfile = IR2R_SLDplot(SLDParametersIn,x)
	//this has 0 at the top... 
	//Now we may have to flip the top and bottom..
	 NVAR ZeroAtTheSubstrate=root:Packages:Refl_SimpleTool:ZeroAtTheSubstrate
	if(ZeroAtTheSubstrate)
		SetScale/I x zend,zstart,"", SLDProfile
	endif 
	setDataFolder OldDf
	
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


Function IR2R_SLDplot(w,z)
	Wave w
	Variable z
	
	string OldDf=getDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool
//	Wave SLDThicknessWv=root:Packages:Refl_SimpleTool:SLDThicknessWv
//	variable  SLDpts=numpnts(SLDThicknessWv)
	
	variable nlayers,SLD1,SLD2,zstart,zend,ii,temp,zinc,summ,deltarho,zi,dindex,sigma,thick,dist,rhotop


////This function calculates the SLD profile.  
	nlayers=w[0]
	rhotop=w[3]
		dist=0
		summ=w[2]		//SLDTop
		ii=0
		do
			if(ii==0)
				//SLD1=(w[7]/100)*(100-w[8])+(w[8]*rhosolv/100) 	original...
				SLD1=w[9]
				deltarho=-w[2]+SLD1
				thick=0
				if(nlayers==0)
					sigma=abs(w[7])		//substrate roughness
					//deltarho=-w[2]+w[3]	//SLD substrate and top
					deltarho=-w[2]+w[4]	//SLD substrate and top
				else
					//sigma=abs(w[9])
					sigma=abs(w[11])		//roughness first layer
//					deltarho=-w[2]+w[4]	//SLD substrate and first layer
				endif
			elseif(ii==nlayers)
				//SLD1=(w[4*ii+3]/100)*(100-w[4*ii+4])+(w[4*ii+4]*rhosolv/100)
				SLD1=(w[7+(ii-1)*4+2])
				SLD2=w[4]			//substrate
				//deltarho=-SLD1+rhosolv
				deltarho=-SLD1+SLD2
				//thick=abs(w[4*ii+2])
				//sigma=abs(w[5])
				thick=abs(w[7+(ii-1)*4+1])
				sigma=abs(w[7])
			else
				//SLD1=(w[4*ii+3]/100)*(100-w[4*ii+4])+(w[4*ii+4]*rhosolv/100)
				//SLD2=(w[4*(ii+1)+3]/100)*(100-w[4*(ii+1)+4])+(w[4*(ii+1)+4]*rhosolv/100)
				//deltarho=-SLD1+SLD2
				//thick=abs(w[4*(ii)+2])
				//sigma=abs(w[4*(ii+1)+5])
				SLD1=(w[7+(ii-1)*4+2])
				SLD2=(w[7+(ii)*4+2])
				deltarho=-SLD1+SLD2
				thick=abs(w[7+(ii-1)*4+1])
				sigma=abs(w[7+(ii)*4+4])
			endif
			
			
			dist+=thick
			
			
			//if sigma=0 then the computer goes haywire (division by zero), so say it's vanishingly small
			if(sigma==0)
				sigma+=1e-3
			endif
			summ+=(deltarho/2)*(1+erf((z-dist)/(sigma*sqrt(2))))
			
			
			ii+=1
		while(ii<nlayers+1)
		        
		return summ
End


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2R_CalculateReflectivity(w,x, res) 
	Wave w
	variable x, res
	Variable dq,reflectivity
	
	duplicate/o w call
	Wave call
	call[6]=0
	dq=x*(res/100)

#if Exists("Abeles_imag")	
	reflectivity=Abeles_imag(call,x)
	if(dq>0)
		reflectivity+=0.135*Abeles_imag(call,x-dq)
		reflectivity+=0.135*Abeles_imag(call,x+dq)
		reflectivity+=0.325*Abeles_imag(call,x-(dq*0.75))
		reflectivity+=0.325*Abeles_imag(call,x+(dq*0.75))
		reflectivity+=0.605*Abeles_imag(call,x-(dq/2))
		reflectivity+=0.605*Abeles_imag(call,x+(dq/2))
		reflectivity+=0.88*Abeles_imag(call,x-(dq/4))
		reflectivity+=0.88*Abeles_imag(call,x+(dq/4))
		reflectivity/=4.89
	endif
#else
	reflectivity=IR2R_CalculateReflectivityInt(call,x)
	if(dq>0)
		reflectivity+=0.135*IR2R_CalculateReflectivityInt(call,x-dq)
		reflectivity+=0.135*IR2R_CalculateReflectivityInt(call,x+dq)
		reflectivity+=0.325*IR2R_CalculateReflectivityInt(call,x-(dq*0.75))
		reflectivity+=0.325*IR2R_CalculateReflectivityInt(call,x+(dq*0.75))
		reflectivity+=0.605*IR2R_CalculateReflectivityInt(call,x-(dq/2))
		reflectivity+=0.605*IR2R_CalculateReflectivityInt(call,x+(dq/2))
		reflectivity+=0.88*IR2R_CalculateReflectivityInt(call,x-(dq/4))
		reflectivity+=0.88*IR2R_CalculateReflectivityInt(call,x+(dq/4))
		reflectivity/=4.89
	endif
#endif


	reflectivity+=abs(w[6])
	
	Killwaves/Z kzn,rn,rrn
	
	return reflectivity
End

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR2R_CalcReflectivitySwitch(w,x)
	Wave w
	Variable x

//	//if we can use the xop here and skip the rest. This should be basically transparent to user, if we can get the xop function...
//	//

	if(exists("Abeles_imag")==3)
	   Funcref IR2R_CalculateReflectivityInt f=$"Abeles_imag"
	else
	   Funcref IR2R_CalculateReflectivityInt f=IR2R_CalculateReflectivityInt
	endif

	variable y
	y=f(w,x)

	return y
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2R_CalculateReflectivityInt(w,x) //:fitfunc
	Wave w
	Variable x
	
	Variable reflectivity,ii,nlayers,inter,qq,scale,bkg,subrough
	Variable/C super,sub,arg,cinter,SLD
	
	//number of layers,re_SUPERphaseSLD,imag_SUPER,re_SUBphaseSLD,imag_SUB
	
	//subsequent layers have 4 parameters each: thickness, re_SLD, imag_SLD and roughness
	//if you increase the number of layers you have to put extra parameters in.
	//you should be able to remember the order in which they go.
	
	
	//Layer 1 is always closest to the SUPERPHASE (e.g. air).  increasing layers go down 
	//towards the subphase.  This may be confusing if you switch between air-solid and solid-liquid
	//I will write some functions to create exotic SLD profiles if required.
	
	
	nlayers=w[0]
	scale=w[1]
	super=cmplx(w[2]*1e-6,-abs(w[3]))			// JI 3/306 this fixes some problems - f" is negative and hence the SLD imaginary part should be also...
	sub=cmplx(w[4]*1e-6,-abs(w[5]))			// JI 3/306 this fixes some problems - f" is negative and hence the SLD imaginary part should be also...
	bkg=abs(w[6])
	subrough=w[7]
	qq=x
	
	//for definitions of these see Parratt handbook
	Make/o/d/C/n=(nlayers+2) kzn
	Make/o/d/C/n=(nlayers+2) rn
	Make/o/d/C/n=(nlayers+2) RRN
	
	//workout the wavevector in the incident medium/superphase
	inter=cabs(sqrt((qq/2)^2))
	kzn[0]=cmplx(inter,0)
	
	//workout the wavevector in the subphase
	kzn[nlayers+1]=sqrt(kzn[0]^2-4*Pi*(sub-super))
	
	//workout the wavevector in each of the layers
	ii=1
	if(ii<nlayers+1)
		do
	//	 SLD=cmplx(w[4*ii+5],w[4*ii+6])			//original
		 SLD=cmplx(w[4*ii+5]*1e-6,-abs(w[4*ii+6]))			// JI 3/306 this fixes some problems - f" is negative and hence the SLD imaginary part should be also...
		 
		 cinter=sqrt(kzn[0]^2-4*Pi*(SLD-super))		//this bit is important otherwise the SQRT doesn't work on the complex number
		 kzn[ii]=(cinter)
		 ii+=1
		while(ii<nlayers+1)
	endif
	
	//RRN[subphase]=0,RRN[subphase-1]=fresnel reflectance of n, subphase
	RRN[nlayers+1]=cmplx(0,0)
	RRN[nlayers]=(kzn[nlayers]-kzn[nlayers+1])/(kzn[nlayers]+kzn[nlayers+1])
	arg=-2*kzn[nlayers]*kzn[nlayers+1]*subrough^2
	RRN[nlayers]*=exp(arg)
	
	//work out the fresnel reflectance for the layer then calculate the total reflectivity from each layer
	ii=nlayers-1
	do
		//work out the fresnel reflectance for each layer
		rn[ii]=(kzn[ii]-kzn[ii+1])/(kzn[ii]+kzn[ii+1])
		arg=-2*kzn[ii]*kzn[ii+1]*w[4*(ii+1)+7]^2
		rn[ii]*=exp(arg)
		//now work out the total reflectivity from the layer
		arg=cmplx(0,2*abs(w[4*(ii+1)+4]))
		arg*=(kzn[ii+1])
		RRN[ii]=rn[ii]+RRN[ii+1]*exp(arg)
		RRN[ii]/=1+rn[ii]*RRN[ii+1]*exp(arg)
		
		ii-=1
	while(ii>-1)
	
	//reflectivity=abs(Ro)^2
	reflectivity=magsqr(RRN[0])
	reflectivity*=scale
	reflectivity+=bkg
	
	
//	reflectivity=(reflectivity)
	
	return reflectivity
	
End


//Control procedures for simple tool Mottfit 

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2R_PanelSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool
	variable currentVar
	if (stringmatch(ctrlName,"ThicknessLayer*") && !stringmatch(ctrlName,"*Step*") && !stringmatch(ctrlName,"*LL*") && !stringmatch(ctrlName,"*UL*"))
		currentVar=str2num(ctrlName[14,inf])
		NVAR ThicknessLayer=$("root:Packages:Refl_SimpleTool:ThicknessLayer"+num2str(currentVar))
		NVAR ThicknessLayerLL=$("root:Packages:Refl_SimpleTool:ThicknessLayerLL"+num2str(currentVar))
		NVAR ThicknessLayerUL=$("root:Packages:Refl_SimpleTool:ThicknessLayerUL"+num2str(currentVar))
		NVAR RoughnessLayer=$("root:Packages:Refl_SimpleTool:RoughnessLayer"+num2str(currentVar))
		NVAR RoughnessLayerUL=$("root:Packages:Refl_SimpleTool:RoughnessLayerUL"+num2str(currentVar))
		ThicknessLayerLL = ThicknessLayer/1.5
		ThicknessLayerUL = ThicknessLayer*1.5
//		if(RoughnessLayer>ThicknessLayer)
//			RoughnessLayer = ThicknessLayer /2
//		endif
//		if(RoughnessLayerUL>ThicknessLayer || RoughnessLayerUL<0.1)
//			RoughnessLayerUL = ThicknessLayer * 0.9
//		endif
	endif
	if (stringmatch(ctrlName,"SLD_Real_Layer*") && !stringmatch(ctrlName,"*Step*") && !stringmatch(ctrlName,"*LL*") && !stringmatch(ctrlName,"*UL*"))
		currentVar=str2num(ctrlName[14,inf])
		NVAR SLD_Real_Layer=$("root:Packages:Refl_SimpleTool:SLD_Real_Layer"+num2str(currentVar))
		NVAR SLD_Real_LayerLL=$("root:Packages:Refl_SimpleTool:SLD_Real_LayerLL"+num2str(currentVar))
		NVAR SLD_Real_LayerUL=$("root:Packages:Refl_SimpleTool:SLD_Real_LayerUL"+num2str(currentVar))
		SLD_Real_LayerLL = SLD_Real_Layer/2
		SLD_Real_LayerUL = SLD_Real_Layer*2
	endif
	if (stringmatch(ctrlName,"SLD_Imag_Layer*")&& !stringmatch(ctrlName,"*Step*") && !stringmatch(ctrlName,"*LL*") && !stringmatch(ctrlName,"*UL*"))
		currentVar=str2num(ctrlName[14,inf])
		NVAR SLD_Imag_Layer=$("root:Packages:Refl_SimpleTool:SLD_Imag_Layer"+num2str(currentVar))
		NVAR SLD_Imag_LayerLL=$("root:Packages:Refl_SimpleTool:SLD_Imag_LayerLL"+num2str(currentVar))
		NVAR SLD_Imag_LayerUL=$("root:Packages:Refl_SimpleTool:SLD_Imag_LayerUL"+num2str(currentVar))
		SLD_Imag_LayerLL = SLD_Imag_Layer/2
		SLD_Imag_LayerUL = SLD_Imag_Layer*2
	endif

	if (stringmatch(ctrlName,"RoughnessLayer*")&& !stringmatch(ctrlName,"*Step*") && !stringmatch(ctrlName,"*LL*") && !stringmatch(ctrlName,"*UL*"))
		currentVar=str2num(ctrlName[14,inf])
		NVAR RoughnessLayer=$("root:Packages:Refl_SimpleTool:RoughnessLayer"+num2str(currentVar))
		NVAR RoughnessLayerLL=$("root:Packages:Refl_SimpleTool:RoughnessLayerLL"+num2str(currentVar))
		NVAR RoughnessLayerUL=$("root:Packages:Refl_SimpleTool:RoughnessLayerUL"+num2str(currentVar))
		NVAR ThicknessLayer=$("root:Packages:Refl_SimpleTool:ThicknessLayer"+num2str(currentVar))
		RoughnessLayerLL = RoughnessLayer/2
		RoughnessLayerUL = RoughnessLayer*2
//		if(RoughnessLayerUL>ThicknessLayer || RoughnessLayerUL<0.1)
//			RoughnessLayerUL = ThicknessLayer / 5
//		endif
	endif
	if (stringmatch(ctrlName,"Roughness_Bot")&& !stringmatch(ctrlName,"*Step*") && !stringmatch(ctrlName,"*LL*") && !stringmatch(ctrlName,"*UL*"))
		NVAR Roughness_Bot=root:Packages:Refl_SimpleTool:Roughness_Bot
		NVAR Roughness_BotLL=root:Packages:Refl_SimpleTool:Roughness_BotLL
		NVAR Roughness_BotUL=root:Packages:Refl_SimpleTool:Roughness_BotUL
		Roughness_BotLL = Roughness_Bot/2
		Roughness_BotUL = Roughness_Bot*2
	endif

	if (stringmatch(ctrlName,"ThicknessLayerStep*"))
		currentVar=str2num(ctrlName[18,inf])
		NVAR ThicknessLayerStep=$("root:Packages:Refl_SimpleTool:ThicknessLayerStep"+num2str(currentVar))
		Execute("SetVariable ThicknessLayer"+num2str(currentVar)+",limits={0,inf,root:Packages:Refl_SimpleTool:ThicknessLayerStep"+num2str(currentVar)+"},win=IR2R_ReflSimpleToolMainPanel")
	endif
	if (stringmatch(ctrlName,"SLD_Real_LayerStep*"))
		currentVar=str2num(ctrlName[18,inf])
		NVAR ThicknessLayerStep=$("root:Packages:Refl_SimpleTool:SLD_Real_LayerStep"+num2str(currentVar))
		Execute("SetVariable SLD_Real_Layer"+num2str(currentVar)+",limits={0,inf,root:Packages:Refl_SimpleTool:SLD_Real_LayerStep"+num2str(currentVar)+"},win=IR2R_ReflSimpleToolMainPanel")
	endif
	if (stringmatch(ctrlName,"SLD_Imag_LayerStep*"))
		currentVar=str2num(ctrlName[18,inf])
		NVAR ThicknessLayerStep=$("root:Packages:Refl_SimpleTool:SLD_Imag_LayerStep"+num2str(currentVar))
		Execute("SetVariable SLD_Imag_Layer"+num2str(currentVar)+",limits={0,inf,root:Packages:Refl_SimpleTool:SLD_Imag_LayerStep"+num2str(currentVar)+"},win=IR2R_ReflSimpleToolMainPanel")
	endif

	if (stringmatch(ctrlName,"RoughnessLayerStep*"))
		currentVar=str2num(ctrlName[18,inf])
		NVAR RoughnessLayerStep=$("root:Packages:Refl_SimpleTool:RoughnessLayerStep"+num2str(currentVar))
		Execute("SetVariable RoughnessLayer"+num2str(currentVar)+",limits={0,inf,root:Packages:Refl_SimpleTool:RoughnessLayerStep"+num2str(currentVar)+"},win=IR2R_ReflSimpleToolMainPanel")
	endif

	if (cmpstr(ctrlName,"BackgroundStep")==0)
	//	currentVar=str2num(ctrlName[18,inf])
		NVAR BackgroundStep=$("root:Packages:Refl_SimpleTool:BackgroundStep")
		Execute("SetVariable Background,limits={0,inf,root:Packages:Refl_SimpleTool:BackgroundStep},win=IR2R_ReflSimpleToolMainPanel")
	endif

	if (!stringmatch(ctrlName,"*Step*") && !stringmatch(ctrlName,"*LL*") && !stringmatch(ctrlName,"*UL*"))
		NVAR AutoUpdate=root:Packages:Refl_SimpleTool:AutoUpdate
		if (AutoUpdate)
			IR2R_CalculateModelResults()
			IR2R_CalculateSLDProfile()
			IR2R_GraphModelResults()		
		endif
	endif	
	DoWindow /F IR2R_ReflSimpleToolMainPanel
	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2R_InputPanelCheckboxProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool

//	if (stringmatch(ctrlName,"ThicknessLayerStep*")==0)
//		variable currentVar=str2num(ctrlName[19,inf])
//	endif
	
	NVAR AutoUpdate=root:Packages:Refl_SimpleTool:AutoUpdate
	if ( (cmpstr(ctrlName,"AutoUpdate")==0 ||  cmpstr(ctrlName,"L1AtTheBottom")==0 ||  cmpstr(ctrlName,"ZeroAtTheSubstrate")==0 ) && AutoUpdate)
		IR2R_CalculateModelResults()
		IR2R_CalculateSLDProfile()
		IR2R_GraphModelResults()		
	endif
	if (cmpstr(ctrlName,"UseErrors")==0)
		Execute ("PopupMenu ErrorDataName, disable=!root:Packages:Refl_SimpleTool:UseErrors, win=IR2R_ReflSimpleToolMainPanel")
	endif
	if (cmpstr(ctrlName,"UseResolutionWave")==0)
		Execute ("PopupMenu ResolutionWaveName, disable=!root:Packages:Refl_SimpleTool:UseResolutionWave, win=IR2R_ReflSimpleToolMainPanel")
		Execute ("SetVariable Resolution, disable=root:Packages:Refl_SimpleTool:UseResolutionWave, win=IR2R_ReflSimpleToolMainPanel")
	endif

	if (cmpstr(ctrlName,"ZeroAtTheSubstrate")==0)
		DoWindow IR2R_SLDProfile
		if(V_Flag)
			NVAR ZeroAtTheSubstrate=root:Packages:Refl_SimpleTool:ZeroAtTheSubstrate
			DoWindow/F IR2R_SLDProfile
			if(ZeroAtTheSubstrate)
				Label bottom "<<--Substrate                                               Layer thickness [A]                                         Top -->>"
				DoWindow/T IR2R_SLDProfile,"SLD profile (substrate=left,  top=right) "
			else
				Label bottom "<<--TOP                                               Layer thickness [A]                                         Substrate -->>"
				DoWindow/T IR2R_SLDProfile,"SLD profile (top=left, substrate=right) "
			endif
			IR2R_CalculateSLDProfile()
		endif
	endif

	NVAR UseGeneticOptimization=root:Packages:Refl_SimpleTool:UseGenOpt
	NVAR UseLSQF=root:Packages:Refl_SimpleTool:UseLSQF
	if (stringMatch(ctrlName,"UseGenOpt"))
		UseGeneticOptimization=1
		UseLSQF=0
	endif
	if (stringMatch(ctrlName,"UseLSQF"))
		UseLSQF=1
		UseGeneticOptimization=0
	endif

	DoWindow /F IR2R_ReflSimpleToolMainPanel	
	setDataFolder OldDf
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2R_PanelPopupControl(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool
	
	NVAR ActiveTab=root:Packages:Refl_SimpleTool:ActiveTab
	NVAR NumberOfLayers=root:Packages:Refl_SimpleTool:NumberOfLayers
	ControlInfo /W=IR2R_ReflSimpleToolMainPanel DistTabs
	ActiveTab = V_value

	if (cmpstr(ctrlName,"NumberOfLevels")==0)
		NumberOfLayers=str2num(popStr)
		if (NumberOfLayers<ActiveTab)
			ActiveTab=0
			//IR2R_TabPanelControl("",ActiveTab)
			Execute("TabControl DistTabs,value= 0, win=IR2R_ReflSimpleToolMainPanel")
		endif
		IR2R_CalculateModelResults()
		IR2R_CalculateSLDProfile()
		IR2R_GraphModelResults()		
		IR2R_TabPanelControl("",ActiveTab)
	endif
	
	if (cmpstr(ctrlName,"FitIQN")==0)
		NVAR FitIQN=root:Packages:Refl_SimpleTool:FitIQN
		FitIQN = str2num(popStr)	
		Wave/Z OInt=root:Packages:Refl_SimpleTool:OriginalIntensity
		Wave/Z OQvec=root:Packages:Refl_SimpleTool:OriginalQvector
		Wave/Z OErr=root:Packages:Refl_SimpleTool:OriginalError
		Wave/Z NInt=root:Packages:Refl_SimpleTool:IntensityQN
		Wave/Z NQvec=root:Packages:Refl_SimpleTool:QvectorToN
		Wave/Z NErr=root:Packages:Refl_SimpleTool:ErrorQN
		if(WaveExists(OInt) &&WaveExists(OQvec) &&WaveExists(NInt) &&WaveExists(NQvec) )
			NInt= OInt * OQvec^FitIQN
		endif
		if(WaveExists(OErr) &&WaveExists(OQvec) &&WaveExists(NErr) &&WaveExists(NQvec) )
			NErr = OErr * OQvec^FitIQN
		endif
		IR2R_CalculateModelResults()
		IR2R_CalculateSLDProfile()
		IR2R_GraphModelResults()		
	endif
	if (cmpstr(ctrlName,"ResolutionWaveName")==0)
		SVAR ResolutionWaveName=root:Packages:Refl_SimpleTool:ResolutionWaveName
		if(stringmatch("Create From Parameters",popStr))
			ResolutionWaveName="CreatedFromParamaters"
			IR2R_CreateResolutionWave()
		else
			ResolutionWaveName=popstr
		endif
	endif

	DoWindow/F IR2R_ReflSimpleToolMainPanel
	setDataFolder OldDf

end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR2R_TabPanelControl(name,tab)
	String name
	Variable tab

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool
	
	NVAR ActiveTab=root:Packages:Refl_SimpleTool:ActiveTab
	ActiveTab=tab+1

	NVAR NumberOfLayers=root:Packages:Refl_SimpleTool:NumberOfLayers
	if (NumberOfLayers==0)
		ActiveTab=0
	endif
	//need to kill any outstanding windows for shapes... Any... All should have the same name...
	DoWindow/F IR2R_ReflSimpleToolMainPanel
	NVAR UseResolutionWave=root:Packages:Refl_SimpleTool:UseResolutionWave
	SetVariable Resolution, disable = UseResolutionWave
	PopupMenu ResolutionWaveName,disable=!UseResolutionWave
//	if(tab==0 && NumberOfLayers>0)
//			SetDrawLayer UserBack
//			TabControl DistTabs labelBack=(57344,65280,48896)
//	elseif(tab==1 && NumberOfLayers>1)
//			TabControl DistTabs labelBack=(48896,65280,57344)
//	elseif(tab==2 && NumberOfLayers>2)
//			TabControl DistTabs labelBack=(65280,54528,48896)
//	elseif(tab==3 && NumberOfLayers>3)
//			TabControl DistTabs labelBack=(51456,44032,58880)
//	elseif(tab==4 && NumberOfLayers>4)
//			TabControl DistTabs labelBack=(60928,60928,60928)
//	elseif(tab==5 && NumberOfLayers>5)
//			TabControl DistTabs labelBack=(48896,65280,48896)
//	elseif(tab==6 && NumberOfLayers>6)
//			TabControl DistTabs labelBack=(65280,43520,32768)
//	elseif(tab==7 && NumberOfLayers>7)
//			TabControl DistTabs labelBack=(65280,32768,45824)
//	else
//			TabControl DistTabs labelBack=0
//	endif
	

	variable i, test1, test2
	For(i=1;i<=8;i+=1)
		test1=(tab!=(i-1))
		test2=((tab+1)>NumberOfLayers)
		Execute("TitleBox LayerTitleBox"+num2str(i)+",disable = "+num2str(tab!=(i-1) || (tab+1)>NumberOfLayers))
		Execute("SetVariable ThicknessLayer"+num2str(i)+",disable = "+num2str(tab!=(i-1) || (tab+1)>NumberOfLayers))
		Execute("SetVariable ThicknessLayerStep"+num2str(i)+",disable = "+num2str(tab!=(i-1) || (tab+1)>NumberOfLayers))
		Execute("CheckBox FitThicknessLayer"+num2str(i)+",disable = "+num2str(tab!=(i-1) || (tab+1)>NumberOfLayers))
		Execute("SetVariable ThicknessLayerLL"+num2str(i)+",disable = "+num2str(tab!=(i-1) || (tab+1)>NumberOfLayers))
		Execute("SetVariable ThicknessLayerUL"+num2str(i)+",disable = "+num2str(tab!=(i-1) || (tab+1)>NumberOfLayers))

		Execute("SetVariable SLD_Real_Layer"+num2str(i)+",disable = "+num2str(tab!=(i-1) || (tab+1)>NumberOfLayers))
		Execute("SetVariable SLD_Real_LayerStep"+num2str(i)+",disable = "+num2str(tab!=(i-1) || (tab+1)>NumberOfLayers))
		Execute("CheckBox FitSLD_Real_Layer"+num2str(i)+",disable = "+num2str(tab!=(i-1) || (tab+1)>NumberOfLayers))
		Execute("SetVariable SLD_Real_LayerLL"+num2str(i)+",disable = "+num2str(tab!=(i-1) || (tab+1)>NumberOfLayers))
		Execute("SetVariable SLD_Real_LayerUL"+num2str(i)+",disable = "+num2str(tab!=(i-1) || (tab+1)>NumberOfLayers))

		Execute("SetVariable SLD_Imag_Layer"+num2str(i)+",disable = "+num2str(tab!=(i-1) || (tab+1)>NumberOfLayers))
		Execute("SetVariable SLD_Imag_LayerStep"+num2str(i)+",disable = "+num2str(tab!=(i-1) || (tab+1)>NumberOfLayers))
		Execute("CheckBox FitSLD_Imag_Layer"+num2str(i)+",disable = "+num2str(tab!=(i-1) || (tab+1)>NumberOfLayers))
		Execute("SetVariable SLD_Imag_LayerLL"+num2str(i)+",disable = "+num2str(tab!=(i-1) || (tab+1)>NumberOfLayers))
		Execute("SetVariable SLD_Imag_LayerUL"+num2str(i)+",disable = "+num2str(tab!=(i-1) || (tab+1)>NumberOfLayers))

		Execute("SetVariable RoughnessLayer"+num2str(i)+",disable = "+num2str(tab!=(i-1) || (tab+1)>NumberOfLayers))
		Execute("SetVariable RoughnessLayerStep"+num2str(i)+",disable = "+num2str(tab!=(i-1) || (tab+1)>NumberOfLayers))
		Execute("CheckBox FitRoughnessLayer"+num2str(i)+",disable = "+num2str(tab!=(i-1) || (tab+1)>NumberOfLayers))
		Execute("SetVariable RoughnessLayerLL"+num2str(i)+",disable = "+num2str(tab!=(i-1) || (tab+1)>NumberOfLayers))
		Execute("SetVariable RoughnessLayerUL"+num2str(i)+",disable = "+num2str(tab!=(i-1) || (tab+1)>NumberOfLayers))


	endfor

end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2R_InputPanelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool
	

	if (cmpstr(ctrlName,"DrawGraphs")==0)
		//here goes what is done, when user pushes Graph button
		SVAR DFloc=root:Packages:Refl_SimpleTool:DataFolderName
		SVAR DFInt=root:Packages:Refl_SimpleTool:IntensityWaveName
		SVAR DFQ=root:Packages:Refl_SimpleTool:QWaveName
		SVAR DFE=root:Packages:Refl_SimpleTool:ErrorWaveName
		variable IsAllAllRight=1
		if (cmpstr(DFloc,"---")==0 || strlen(DFloc)==0)
			IsAllAllRight=0
		endif
		if (cmpstr(DFInt,"---")==0 || strlen(DFInt)==0)
			IsAllAllRight=0
		endif
		if (cmpstr(DFQ,"---")==0 || strlen(DFQ)==0)
			IsAllAllRight=0
		endif
//		if (cmpstr(DFE,"---")==0 || strlen(DFE)==0)
//			IsAllAllRight=0
//		endif
		
		if (IsAllAllRight)
			variable recovered = IR2R_RecoverOldParameters()	//recovers old parameters and returns 1 if done so...
			IR2R_GraphMeasuredData()
///			ControlInfo DistTabs
//			IR1V_DisplayLocalFits(V_Value)
//			IR1V_AutoUpdateIfSelected()
//			MoveWindow /W=IR1V_LogLogPlotV 285,37,760,337
//			MoveWindow /W=IR1V_IQ4_Q_PlotV 285,360,760,600
			if (recovered)
				IR2R_TabPanelControl("",0)
				IR2R_CalculateModelResults()
				IR2R_CalculateSLDProfile()
				IR2R_GraphModelResults()
			endif
		else
			Abort "Data not selected properly"
		endif
	endif

	if(cmpstr(ctrlName,"ReversFit")==0)
		//here we call the fitting routine
		IR2R_ResetParamsAfterBadFit()
		IR2R_CalculateModelResults()
		IR2R_CalculateSLDProfile()
		IR2R_GraphModelResults()
	endif
	if(cmpstr(ctrlName,"CalculateModel")==0)
		//here we graph the distribution
		IR2R_CalculateModelResults()
		IR2R_CalculateSLDProfile()
		IR2R_GraphModelResults()
	endif
	if(cmpstr(ctrlName,"Fitmodel")==0)
		//here we copy final data back to original data folder	
		IR2R_SimpleToolFit()		//fitting	
		IR2R_CalculateModelResults()
		IR2R_CalculateSLDProfile()
		IR2R_GraphModelResults()
	endif	
	if(cmpstr(ctrlName,"SaveDataBtn")==0)
		//here we copy final data back to original data folder		I	
		IR2R_SaveDataToFolder()
	endif
	if(cmpstr(ctrlName,"ExportData")==0)
		//here we export ASCII form of the data
		IR2R_SaveASCII()
	endif
	Dowindow /F IR2R_ReflSimpleToolMainPanel
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
///******************************************************************************************

Function IR2R_RecoverOldParameters()
	
	string OldDf=getDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool

//	NVAR SASBackground=root:Packages:FractalsModel:SASBackground
//	NVAR SASBackgroundError=root:Packages:FractalsModel:SASBackgroundError
	SVAR DataFolderName=root:Packages:Refl_SimpleTool:DataFolderName
	

	variable DataExists=0,i
	string ListOfWaves=IN2G_CreateListOfItemsInFolder(DataFolderName, 2)
	string tempString, tmpNote
	if (stringmatch(ListOfWaves, "*ReflModel_*" ))
		string ListOfSolutions=""
		For(i=0;i<itemsInList(ListOfWaves);i+=1)
			if (stringmatch(stringFromList(i,ListOfWaves),"*ReflModel_*"))
				tempString=stringFromList(i,ListOfWaves)
				Wave tempwv=$(DataFolderName+tempString)
				tempString=stringByKey("UsersComment",note(tempwv),"=",";")
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
		Wave/Z OldDistribution=$(DataFolderName+ReturnSolution)

		string OldNote=note(OldDistribution)
	//skip UsersComment and 	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;ResolutionWaveName;"

		for(i=0;i<ItemsInList(OldNote);i+=1)
			NVAR/Z testVal=$(StringFromList(0,StringFromList(i,OldNote),"="))
			if(NVAR_Exists(testVal))
				testVal=str2num(StringFromList(1,StringFromList(i,OldNote),"="))
			endif
		endfor
		//Now, fix displayed panel...
		DoWindow/F IR2R_ReflSimpleToolMainPanel
		NVAR UseResolutionWave=root:Packages:Refl_SimpleTool:UseResolutionWave
		SetVariable Resolution, disable = UseResolutionWave
		PopupMenu ResolutionWaveName,disable=!UseResolutionWave
		NVAR NumberOfLayers=root:Packages:Refl_SimpleTool:NumberOfLayers
		PopupMenu NumberOfLevels mode=NumberOfLayers+1
		TabControl DistTabs value=0
		IR2R_TabPanelControl("",0)
		return 1
	else
		return 0
	endif
	setDataFolder oldDF
end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2R_SaveASCII()
	
	string OldDf=getDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool

	string UsersComment="Reflectivity results from : "+date()+" "+time()
	Prompt  UsersComment, "Input comments to be included with exported data"
	string DataRecordStr="UsersComment="+UsersComment+";"
	
	string ListOfVariables
	string ListOfStrings
	variable i, j

	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;ResolutionWaveName;"

	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		SVAR testStr= $(stringFromList(i,ListOfStrings))
		DataRecordStr+=stringFromList(i,ListOfStrings)+"="+testStr+";"
	endfor		
	
	//here define the lists of variables and strings needed, separate names by ;...
	
	ListOfVariables="NumberOfLayers;ActiveTab;AutoUpdate;FitIQN;Resoln;UpdateAutomatically;ActiveTab;UseErrors;UseResolutionWave;"
	ListOfVariables+="SLD_Real_Top;SLD_Imag_Top;SLD_Real_Bot;SLD_Imag_Bot;"
	ListOfVariables+="Roughness_Bot;FitRoughness_Bot;Roughness_BotLL;Roughness_BotUL;Roughness_BotError;"
	ListOfVariables+="Background;BackgroundStep;FitBackground;BackgroundLL;BackgroundUL;BackgroundError;"
	ListOfVariables+="ScalingFactor;FitScalingFactor;ScalingFactorLL;ScalingFactorUL;ScalingFactorError;"

	
	//and here we read them to the list
	
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		NVAR test= $(stringFromList(i,ListOfVariables))
		DataRecordStr+=stringFromList(i,ListOfVariables)+"="+num2str(test)+";"
	endfor		
// create 8 x this following list:
	ListOfVariables="SLD_Real_Layer;SLD_Imag_Layer;ThicknessLayer;RoughnessLayer;"
	ListOfVariables+="SLD_Real_LayerError;SLD_Imag_LayerError;ThicknessLayerError;RoughnessLayerError;"
	ListOfVariables+="SLD_Real_LayerStep;SLD_Imag_LayerStep;ThicknessLayerStep;RoughnessLayerStep;"
	ListOfVariables+="SLD_Real_LayerLL;SLD_Imag_LayerLL;ThicknessLayerLL;RoughnessLayerLL;"
	ListOfVariables+="SLD_Real_LayerUL;SLD_Imag_LayerUL;ThicknessLayerUL;RoughnessLayerUL;"
	ListOfVariables+="FitSLD_Real_Layer;FitSLD_Imag_Layer;FitThicknessLayer;FitRoughnessLayer;"
	NVAR  NumberOfLayers
	if(NumberOfLayers<1)
	//	abort "Save data errors, Number of Layers <1, nothing to save.."
		DoALert 0, "Note: No layers used, stored only substrate and top layer values"
	endif
	for(j=1;j<=NumberOfLayers;j+=1)	
		for(i=0;i<itemsInList(ListOfVariables);i+=1)	
			NVAR test= $(stringFromList(i,ListOfVariables)+num2str(j))
			DataRecordStr+=stringFromList(i,ListOfVariables)+num2str(j)+"="+num2str(test)+";"
		endfor		
	endfor
	
	wave/Z Reflectivity=root:Packages:Refl_SimpleTool:ModelIntensity
	wave/Z Qvec=root:Packages:Refl_SimpleTool:ModelQvector
	if(!WaveExists(Reflectivity) || !WaveExists(Qvec))
		abort "Save error, Reflectivity and Q wave do not exist"
	endif 
	
	SVAR DataFolderName
	if(strlen(DataFolderName)<1)
		abort "Save data error, DataFolderName is not correct"
	endif
	variable TextWvLength=ItemsInList(DataRecordStr,";")
	make/O/T/N=(TextWvLength) Record_Of_All_Model_Parameters
	for(i=0;i<TextWvLength;i+=1)
		Record_Of_All_Model_Parameters[i]=stringFromList(i,DataRecordStr,";")
	endfor
	
	Duplicate /O Reflectivity, Reflectivity_Model
	Wave Reflectivity_Model
	Duplicate/O Qvec, Q_Reflectivity_Model
	Wave Q_Reflectivity_Model
	Save/G/M="\r\n"/W/I Record_Of_All_Model_Parameters, Q_Reflectivity_Model, Reflectivity_Model
	
	KilLWaves Record_Of_All_Model_Parameters, Q_Reflectivity_Model, Reflectivity_Model

	setDataFOlder OldDf
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2R_SaveDataToFolder()
	
	string OldDf=getDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool

	string UsersComment="Reflectivity results from : "+date()+" "+time()
	Prompt  UsersComment, "Input comments to be included with stored data"
	DoPrompt "Correct comment for saved data", UsersComment
	if(V_Flag)
		abort
	endif
	string DataRecord="UsersComment="+UsersComment+";"
	
	string ListOfVariables
	string ListOfStrings
	variable i, j

	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;ResolutionWaveName;"

	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		SVAR testStr= $(stringFromList(i,ListOfStrings))
		DataRecord+=stringFromList(i,ListOfStrings)+"="+testStr+";"
	endfor		
	
	//here define the lists of variables and strings needed, separate names by ;...
	
	ListOfVariables="NumberOfLayers;ActiveTab;AutoUpdate;FitIQN;Resoln;UpdateAutomatically;ActiveTab;UseErrors;UseResolutionWave;"
	ListOfVariables+="SLD_Real_Top;SLD_Imag_Top;SLD_Real_Bot;SLD_Imag_Bot;"
	ListOfVariables+="Roughness_Bot;FitRoughness_Bot;Roughness_BotLL;Roughness_BotUL;Roughness_BotError;"
	ListOfVariables+="Background;BackgroundStep;FitBackground;BackgroundLL;BackgroundUL;BackgroundError;"
	ListOfVariables+="ScalingFactor;FitScalingFactor;ScalingFactorLL;ScalingFactorUL;ScalingFactorError;"

	
	//and here we read them to the list
	
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		NVAR test= $(stringFromList(i,ListOfVariables))
		DataRecord+=stringFromList(i,ListOfVariables)+"="+num2str(test)+";"
	endfor		
// create 8 x this following list:
	ListOfVariables="SLD_Real_Layer;SLD_Imag_Layer;ThicknessLayer;RoughnessLayer;"
	ListOfVariables+="SLD_Real_LayerError;SLD_Imag_LayerError;ThicknessLayerError;RoughnessLayerError;"
	ListOfVariables+="SLD_Real_LayerStep;SLD_Imag_LayerStep;ThicknessLayerStep;RoughnessLayerStep;"
	ListOfVariables+="SLD_Real_LayerLL;SLD_Imag_LayerLL;ThicknessLayerLL;RoughnessLayerLL;"
	ListOfVariables+="SLD_Real_LayerUL;SLD_Imag_LayerUL;ThicknessLayerUL;RoughnessLayerUL;"
	ListOfVariables+="FitSLD_Real_Layer;FitSLD_Imag_Layer;FitThicknessLayer;FitRoughnessLayer;"
	NVAR/Z  NumberOfLayers
	if(NumberOfLayers<1)
	//	abort "Save data error, Number of Layers <1 nothing to save..."
		DoAlert 0, "Note: No layers used, stored only top and substrate values"
	endif
	for(j=1;j<=NumberOfLayers;j+=1)	
		for(i=0;i<itemsInList(ListOfVariables);i+=1)	
			NVAR test= $(stringFromList(i,ListOfVariables)+num2str(j))
			DataRecord+=stringFromList(i,ListOfVariables)+num2str(j)+"="+num2str(test)+";"
		endfor		
	endfor
	
	wave/Z Reflectivity=root:Packages:Refl_SimpleTool:ModelIntensity
	wave/Z Qvec=root:Packages:Refl_SimpleTool:ModelQvector
	if(!WaveExists(Reflectivity) || !WaveExists(Qvec))
		abort "Save error, Reflectivity and Q wave do not exist"
	endif 
	
	wave/Z SLDProfile=root:Packages:Refl_SimpleTool:SLDProfile
	if(!WaveExists(SLDProfile))
		abort "Save error, SLDProfile wave does not exist"
	endif 

	SVAR DataFolderName
	if(strlen(DataFolderName)<1)
		abort "Save data error, DataFolderName is not correct"
	endif
	setDataFolder root:
	setDataFolder DataFolderName
	string NewIntName=UniqueName("ReflModel_", 1, 0)
	variable FoundIndex=str2num(stringFromList(1,NewIntName,"_"))
	string NewQwave="ReflQ_"+num2str(FoundIndex)
	string NewSLDProfileWave="SLDProfile_"+num2str(FoundIndex)
	
	Duplicate/O Reflectivity, $NewIntName
	Wave NewReflectivity=$(NewIntName)
	Duplicate/O Qvec, $NewQwave
	Wave NewQ=$(NewQwave)
	Duplicate/O SLDProfile, $NewSLDProfileWave
	Wave NewSLDProfile=$(NewSLDProfileWave)
	
	note/NOCR NewReflectivity, DataRecord
	note/NOCR NewQ, DataRecord
	note/NOCR NewSLDProfile, DataRecord

	setDataFOlder OldDf
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR2R_CalculateModelResults()
	//this function calculates model data
//	make/o/t parameters_Cref = {"Numlayers","scale","re_SLDtop","imag_SLDtop","re_SLDbase","imag_SLD base","bkg","sigma_base","thick1","re_SLD1","imag_SLD1","rough1","thick2","re_SLD2","imag_SLD2","rough2"}
//	Edit parameters_Cref,coef_Cref,par_res,resolution
//	ywave_Cref:= Motofit_Imag(coef_Cref,xwave_Cref)

//variable startTime=ticks
	variable i, j
	string OldDf=getDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool

	wave/Z OriginalQvector=root:Packages:Refl_SimpleTool:OriginalQvector
	if(!WaveExists(OriginalQvector))
		abort
	endif

	//Need to create wave with parameters for Motofit_Imag here
	NVAR NumberOfLayers= root:Packages:Refl_SimpleTool:NumberOfLayers
	//need 8 parameters to start with - numLayers, scale, TopSLD_real, TopSLD_Imag, Bot_SLD_real, BotSLD_imag, Background, SubstareRoughness, and then 4 parameters for each layer 
	// thickness, re_SLD, imag_SLD and roughness
	variable NumPointsNeeded= NumberOfLayers * 4 + 8
	
	make/O/N=(NumPointsNeeded) ParametersIn
	//now let's fill this in
	ParametersIn[0] = NumberOfLayers
	NVAR ScalingFactor=root:Packages:Refl_SimpleTool:ScalingFactor
	NVAR SLD_Real_Top=root:Packages:Refl_SimpleTool:SLD_Real_Top
	NVAR SLD_Imag_Top=root:Packages:Refl_SimpleTool:SLD_Imag_Top
	NVAR SLD_Real_Bot=root:Packages:Refl_SimpleTool:SLD_Real_Bot
	NVAR SLD_Imag_Bot=root:Packages:Refl_SimpleTool:SLD_Imag_Bot
	NVAR Background=root:Packages:Refl_SimpleTool:Background
	NVAR Roughness_Bot=root:Packages:Refl_SimpleTool:Roughness_Bot	
	NVAR L1AtTheBottom=root:Packages:Refl_SimpleTool:L1AtTheBottom
	
	ParametersIn[1] = ScalingFactor	
	ParametersIn[2] = SLD_Real_Top//*1e-6
	ParametersIn[3] = SLD_Imag_Top*1e-6
	ParametersIn[4] = SLD_Real_Bot//*1e-6
	ParametersIn[5] = SLD_Imag_Bot*1e-6
	ParametersIn[6] = Background
	ParametersIn[7] = Roughness_Bot

	//fix to allow L1 at the bottom...
	if(L1AtTheBottom)
		j=0
		for(i=NumberOfLayers;i>=1;i-=1)
			j+=1
			NVAR ThicknessLayer= $("root:Packages:Refl_SimpleTool:ThicknessLayer"+Num2str(i))
			NVAR SLD_real_Layer = $("root:Packages:Refl_SimpleTool:SLD_Real_Layer"+Num2str(i))
			NVAR SLD_imag_Layer = $("root:Packages:Refl_SimpleTool:SLD_Imag_Layer"+Num2str(i))
			NVAR RoughnessLayer = $("root:Packages:Refl_SimpleTool:RoughnessLayer"+Num2str(i))
			ParametersIn[7+(j-1)*4+1] =  ThicknessLayer
			ParametersIn[7+(j-1)*4+2] =  SLD_real_Layer//*1e-6
			ParametersIn[7+(j-1)*4+3] =  SLD_imag_Layer*1e-6
			ParametersIn[7+(j-1)*4+4] =  RoughnessLayer
		endfor
	else
		for(i=1;i<=NumberOfLayers;i+=1)
			NVAR ThicknessLayer= $("root:Packages:Refl_SimpleTool:ThicknessLayer"+Num2str(i))
			NVAR SLD_real_Layer = $("root:Packages:Refl_SimpleTool:SLD_Real_Layer"+Num2str(i))
			NVAR SLD_imag_Layer = $("root:Packages:Refl_SimpleTool:SLD_Imag_Layer"+Num2str(i))
			NVAR RoughnessLayer = $("root:Packages:Refl_SimpleTool:RoughnessLayer"+Num2str(i))
			ParametersIn[7+(i-1)*4+1] =  ThicknessLayer
			ParametersIn[7+(i-1)*4+2] =  SLD_real_Layer//*1e-6
			ParametersIn[7+(i-1)*4+3] =  SLD_imag_Layer*1e-6
			ParametersIn[7+(i-1)*4+4] =  RoughnessLayer
		endfor
	endif

	Duplicate/O OriginalQvector, ModelQvector, ModelIntensity
	NVAR Resoln=root:Packages:Refl_SimpleTool:Resoln
	NVAR UseResolutionWave=root:Packages:Refl_SimpleTool:UseResolutionWave
	SVAR ResolutionWaveName=root:Packages:Refl_SimpleTool:ResolutionWaveName
	SVAR DataFolderName=root:Packages:Refl_SimpleTool:DataFolderName
	Wave/Z ResolutionWave=$(DataFolderName+ResolutionWaveName)
	if(UseResolutionWave)	
		if(!WaveExists(ResolutionWave))
			abort "Resolution wave does not exist"
		endif
		ModelIntensity=IR2R_CalculateReflectivity(ParametersIn,ModelQvector,ResolutionWave)
	else//use resoln
		ModelIntensity=IR2R_CalculateReflectivity(ParametersIn,ModelQvector,Resoln)
	endif

	setDataFolder OldDf
//print (ticks-startTime)/60	
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR2R_GraphModelResults()
	//this function graphs model data
	
	string OldDf=getDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool
	Wave/Z ModelIntensity=root:Packages:Refl_SimpleTool:ModelIntensity
	if(!WaveExists(ModelIntensity))
		abort 	//no data to do anything
	endif
	Wave ModelQvector=root:Packages:Refl_SimpleTool:ModelQvector
	NVAR FitIQN=root:Packages:Refl_SimpleTool:FitIQN
	Duplicate/O ModelIntensity, ModelIntensityQN
	Duplicate/O ModelQvector, ModelQvectorToN
//	ModelQvectorToN = ModelQvectorToN
	ModelIntensityQN = ModelIntensity * ModelQvectorToN^FitIQN

	DoWindow IR2R_LogLogPlotRefl
	if(V_Flag)
		DoWindow/F IR2R_LogLogPlotRefl
		CheckDisplayed /W=IR2R_LogLogPlotRefl ModelIntensity
		if(V_Flag!=1)
			AppendToGraph/W=IR2R_LogLogPlotRefl ModelIntensity vs ModelQvector
		endif
		ModifyGraph rgb(ModelIntensity)=(0,0,0)
	endif
	DoWindow IR2R_IQN_Q_PlotV
	if(V_Flag)
		DoWindow/F IR2R_IQN_Q_PlotV
		CheckDisplayed /W=IR2R_IQN_Q_PlotV ModelIntensityQN
		if(V_Flag!=1)
			AppendToGraph/W=IR2R_IQN_Q_PlotV ModelIntensityQN vs ModelQvectorToN
		endif
		ModifyGraph rgb(ModelIntensityQN)=(0,0,0)
	endif
	DoWindow IR2R_SLDProfile
	if(V_Flag)
		DoWindow/F IR2R_SLDProfile
	else
		Execute ("IR2R_SLDProfile()")
	endif

	setDataFolder OldDf
end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


Function IR2R_SimpleToolFit()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool
	//setup waves for fitting
	string ListOfVariables
	variable i, j, curLen, curLenConst
	//Each variable has Name, FitName, NameLL, NameUL, and for layers the name has index 1 to NumberOfLayers (up to 8)
	NVAR NumberOfLayers=root:Packages:Refl_SimpleTool:NumberOfLayers
	NVAR FitIQN=root:Packages:Refl_SimpleTool:FitIQN
	make/O/N=0/T CoefNames, T_Constraints
	Make/O/N=(0,2) Gen_Constraints
	make/O/D/N=0 W_coef

	ListOfVariables="Roughness_Bot;"//FitRoughness_Bot;Roughness_BotLL;Roughness_BotUL;"
	ListOfVariables+="Background;ScalingFactor;"//FitBackground;BackgroundLL;BackgroundUL;"
	T_Constraints=""
	CoefNames=""

	For(i=0;i<ItemsInList(ListOfVariables);i+=1)
		NVAR FitMe=$("root:Packages:Refl_SimpleTool:Fit"+StringFromList(i,ListOfVariables))
		NVAR CurVal=$("root:Packages:Refl_SimpleTool:"+StringFromList(i,ListOfVariables))
		NVAR LLVal=$("root:Packages:Refl_SimpleTool:"+StringFromList(i,ListOfVariables)+"LL")
		NVAR ULVal=$("root:Packages:Refl_SimpleTool:"+StringFromList(i,ListOfVariables)+"UL")
		curLen=numpnts(W_coef)
		curLenConst=numpnts(T_Constraints)
		if(FitMe)
			if(LLVal>CurVal || ULVal<CurVal)
				abort "Limits for "+ StringFromList(i,ListOfVariables)+"  set incorrectly"
			endif
			redimension/N=(curlen+1) CoefNames, W_coef
			Redimension /N=((curlen+1),2) Gen_Constraints
			redimension/N=(curLenConst+2) T_Constraints
			W_coef[curLen] = CurVal
			CoefNames[curLen] = StringFromList(i,ListOfVariables)
			T_Constraints[curLenConst] = {"K"+num2str(curlen)+" > "+num2str(LLVal)}
			T_Constraints[curLenConst+1] = {"K"+num2str(curlen)+" < "+num2str(ULVal)}
			Gen_Constraints[curLen][0] = LLVal
			Gen_Constraints[curLen][1] = ULVal
		endif
	endfor
	
// create 8 x this following list:
//	NVAR SLDinCm=root:Packages:Refl_SimpleTool:SLDinCm
//	NVAR SLDinA=root:Packages:Refl_SimpleTool:SLDinA

	ListOfVariables="SLD_Real_Layer;SLD_Imag_Layer;ThicknessLayer;RoughnessLayer;"
	For(j=1;j<=NumberOfLayers;j+=1)
		For(i=0;i<ItemsInList(ListOfVariables);i+=1)
			NVAR FitMe=$("root:Packages:Refl_SimpleTool:Fit"+StringFromList(i,ListOfVariables)+num2str(j))
			NVAR CurVal=$("root:Packages:Refl_SimpleTool:"+StringFromList(i,ListOfVariables)+num2str(j))
			NVAR LLVal=$("root:Packages:Refl_SimpleTool:"+StringFromList(i,ListOfVariables)+"LL"+num2str(j))
			NVAR ULVal=$("root:Packages:Refl_SimpleTool:"+StringFromList(i,ListOfVariables)+"UL"+num2str(j))
			curLen=numpnts(W_coef)
			curLenConst=numpnts(T_Constraints)
			if(FitMe)
				if(LLVal>CurVal || ULVal<CurVal)
					abort "Limits for "+ StringFromList(i,ListOfVariables)+num2str(j)+"  set incorrectly"
				endif
				redimension/N=(curlen+1) CoefNames, W_coef
				Redimension /N=((curlen+1),2) Gen_Constraints
				redimension/N=(curLenConst+2) T_Constraints
					W_coef[curLen] = CurVal
					CoefNames[curLen] = StringFromList(i,ListOfVariables)+num2str(j)
					T_Constraints[curLenConst] = {"K"+num2str(curlen)+" > "+num2str(LLVal)}
					T_Constraints[curLenConst+1] = {"K"+num2str(curlen)+" < "+num2str(ULVal)}
					Gen_Constraints[curLen][0] = LLVal
					Gen_Constraints[curLen][1] = ULVal
			endif
		endfor
	endfor

	//Now let's check if we have what to fit at all...
	if (numpnts(CoefNames)==0)
		beep
		Abort "Select parameters to fit and set their fitting limits"
	endif
	IR2R_SetErrorsToZero()
	
	DoWindow /F IR2R_LogLogPlotRefl
	Wave OriginalQvector
	Wave OriginalIntensity
	Wave OriginalError	
	NVAR FitIQN=root:Packages:Refl_SimpleTool:FitIQN	
	NVAR UseErrors=root:Packages:Refl_SimpleTool:UseErrors
	
	Variable V_chisq
	Duplicate/O W_Coef, E_wave, CoefficientInput
	E_wave=W_coef/20

	NVAR/Z UseLSQF = root:Packages:Refl_SimpleTool:UseLSQF 
	NVAR/Z UseGenOpt = root:Packages:Refl_SimpleTool:UseGenOpt 
	if(!NVAR_Exists(UseGenOpt)||!NVAR_Exists(UseLSQF))
		variable/g UseGenOpt
		variable/g UseLSQF
		UseLSQF=1
		UseGenOpt=0
	endif
	string HoldStr=""
	For(i=0;i<numpnts(W_Coef);i+=1)
		HoldStr+="0"
	endfor
	if(UseGenOpt)	//check the limits, for GenOpt the ratio between min and max should not be too high
//		string Warning
//		For(i=0;i<DimSize(Gen_Constraints, 0);i+=1)
//			if(Gen_Constraints[i][1]/Gen_Constraints[i][0] >5)
//				Warning="For Genetic Optimization the range of limits should be as small as possible. For "+  CoefNames[i]
//				Warning+=" the range of limits is more than 5, that is likely too high. Continue?"
//				DoAlert 1, Warning
//				if (V_Flag==2)
//					abort
//				else
//					break
//				endif
//			endif
//		
//		endfor
		IR2R_CheckFittingParamsFnct()
		PauseForUser IR2R_CheckFittingParams
		NVAR UserCanceled=root:Packages:Refl_SimpleTool:UserCanceled
		if (UserCanceled)
			setDataFolder OldDf
			abort
		endif
		
	endif


////	IR1A_RecordResults("before")

	Variable V_FitError=0			//This should prevent errors from being generated
	variable temp
	
	NVAR Resoln=root:Packages:Refl_SimpleTool:Resoln
	NVAR UseResolutionWave=root:Packages:Refl_SimpleTool:UseResolutionWave
	SVAR ResolutionWaveName=root:Packages:Refl_SimpleTool:ResolutionWaveName
	SVAR DataFolderName=root:Packages:Refl_SimpleTool:DataFolderName
	Wave/Z ResolutionWave=$(DataFolderName+ResolutionWaveName)
		if(!WaveExists(ResolutionWave) && UseResolutionWave)
			abort "Resolution wave does not exist"
		endif

	//remember, to allow user not to have errors, if they are not provided we create them and set them to 0... 
//	//and now the fit...

//	variable starttime=ticks
	
	
	if (strlen(csrWave(A))!=0 && strlen(csrWave(B))!=0)		//cursors in the graph
		//check that the cursors are on the right wave or get them set to the right wave
		if(cmpstr(CsrWave(A),"OriginalIntensity")!=0)
			temp = CsrXWaveRef(A)[xcsr(A)]
			cursor A OriginalIntensity binarysearch(OriginalQvector,temp)
		endif
		if(cmpstr(CsrWave(B),"OriginalIntensity")!=0)
			temp = CsrXWaveRef(B)[xcsr(B)]
			cursor B OriginalIntensity binarysearch(OriginalQvector,temp)
		endif
		
		Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalIntensity, FitIntensityWave, ErrorFractionWave		
		Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalQvector, FitQvectorWave
		Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalError, FitErrorWave
		//FitResolutionWave
		if(UseResolutionWave)
			Duplicate/O/R=[pcsr(A),pcsr(B)] ResolutionWave, FitResolutionWave	
		endif
		ErrorFractionWave = FitErrorWave / FitIntensityWave
		FitIntensityWave = FitIntensityWave * FitQvectorWave^FitIQN
		//FitErrorWave = FitErrorWave * FitQvectorWave^FitIQN
		FitErrorWave = FitIntensityWave * ErrorFractionWave

 
		if(sum(FitErrorWave)==0 || !UseErrors)	//no errors to use...
			if(UseLSQF)
				FuncFit /N/Q IR2R_ST_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /E=E_wave  /C=T_Constraints 
			else
				Duplicate/O FitIntensityWave, GenMaskWv
				GenMaskWv=1
	 	//	 	GEN_curvefit("IR2R_ST_FitFunction",W_Coef,FitIntensityWave,HoldStr,x=FitQvectorWave,c=Gen_Constraints,mask=GenMaskWv, popsize=20,k_m=0.7,recomb=0.5,iters=50,tol=0.001)
#if Exists("gencurvefit")
	  	gencurvefit  /M=GenMaskWv /N /TOL=0.001 /K={50,20,0.7,0.5} /X=FitQvectorWave IR2R_ST_FitFunction, FitIntensityWave  , W_Coef, HoldStr, Gen_Constraints  	
#else
	  	GEN_curvefit("IR2R_ST_FitFunction",W_Coef,FitIntensityWave,HoldStr,x=FitQvectorWave,c=Gen_Constraints,mask=GenMaskWv, popsize=20,k_m=0.7,recomb=0.5,iters=50,tol=0.001)	
#endif
			endif
		else
			if(UseLSQF)
				FuncFit /N/Q IR2R_ST_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1/E=E_wave /C=T_Constraints 
			else
				Duplicate/O FitIntensityWave, GenMaskWv
				GenMaskWv=1
	 		// 	GEN_curvefit("IR2R_ST_FitFunction",W_Coef,FitIntensityWave,HoldStr,x=FitQvectorWave,w=FitErrorWave,c=Gen_Constraints,mask=GenMaskWv, popsize=20,k_m=0.7,recomb=0.5,iters=50,tol=0.001)
#if Exists("gencurvefit")
	  	gencurvefit  /I=1 /W=FitErrorWave /M=GenMaskWv /N /TOL=0.001 /K={50,20,0.7,0.5} /X=FitQvectorWave IR2R_ST_FitFunction, FitIntensityWave  , W_Coef, HoldStr, Gen_Constraints  	
#else
	  	GEN_curvefit("IR2R_ST_FitFunction",W_Coef,FitIntensityWave,HoldStr,x=FitQvectorWave,c=Gen_Constraints,mask=GenMaskWv, popsize=20,k_m=0.7,recomb=0.5,iters=50,tol=0.001)	
#endif
			endif
		endif
	else
		Duplicate/O OriginalIntensity, FitIntensityWave, ErrorFractionWave		
		Duplicate/O OriginalQvector, FitQvectorWave
		Duplicate/O OriginalError, FitErrorWave
		//FitResolutionWave
		if(UseResolutionWave)
			Duplicate/O ResolutionWave, FitResolutionWave	
		endif
		ErrorFractionWave = FitErrorWave / FitIntensityWave
		FitIntensityWave = FitIntensityWave * FitQvectorWave^FitIQN
		//FitErrorWave = FitErrorWave * FitQvectorWave^FitIQN
		FitErrorWave = FitIntensityWave * ErrorFractionWave
variable starttime=ticks
		if(sum(FitErrorWave)==0 || !UseErrors)	//no errors to use...
			if(UseLSQF)
				FuncFit /N/Q IR2R_ST_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /E=E_wave /C=T_Constraints	
			else
				Duplicate/O FitIntensityWave, GenMaskWv
				GenMaskWv=1
	 		 //	GEN_curvefit("IR2R_ST_FitFunction",W_Coef,FitIntensityWave,HoldStr,x=FitQvectorWave,c=Gen_Constraints,mask=GenMaskWv, popsize=20,k_m=0.7,recomb=0.5,iters=100,tol=0.001)
#if Exists("gencurvefit")
	  	gencurvefit  /M=GenMaskWv /N /TOL=0.01 /K={50,20,0.7,0.5} /X=FitQvectorWave IR2R_ST_FitFunction, FitIntensityWave  , W_Coef, HoldStr, Gen_Constraints  	
//		print "xop code"
#else
	  	GEN_curvefit("IR2R_ST_FitFunction",W_Coef,FitIntensityWave,HoldStr,x=FitQvectorWave,c=Gen_Constraints,mask=GenMaskWv, popsize=20,k_m=0.7,recomb=0.5,iters=50,tol=0.01)	
//		print "Old code"
#endif
			endif
		else
			if(UseLSQF)
				FuncFit /N/Q IR2R_ST_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1 /E=E_wave /C=T_Constraints	
			else
				Duplicate/O FitIntensityWave, GenMaskWv
				GenMaskWv=1
	 		// 	GEN_curvefit("IR2R_ST_FitFunction",W_Coef,FitIntensityWave,HoldStr,x=FitQvectorWave,w=FitErrorWave,c=Gen_Constraints,mask=GenMaskWv, popsize=20,k_m=0.7,recomb=0.5,iters=100,tol=0.001)
#if Exists("gencurvefit")
	  	gencurvefit  /I=1 /W=FitErrorWave /M=GenMaskWv /N /TOL=0.01 /K={50,20,0.7,0.5} /X=FitQvectorWave IR2R_ST_FitFunction, FitIntensityWave  , W_Coef, HoldStr, Gen_Constraints  	
//		print "xop code"
#else
	  	GEN_curvefit("IR2R_ST_FitFunction",W_Coef,FitIntensityWave,HoldStr,x=FitQvectorWave,w=FitErrorWave,c=Gen_Constraints,mask=GenMaskWv, popsize=20,k_m=0.7,recomb=0.5,iters=50,tol=0.01)	
//		print "Old code"
#endif
			endif
		endif
	endif
	if (V_FitError!=0)	//there was error in fitting
		IR2R_ResetParamsAfterBadFit()
		beep
		Abort "Fitting error, check starting parameters and fitting limits" 
	else
		For(i=0;i<numpnts(W_coef);i+=1)
			NVAR testVal=$(CoefNames[i])
			testVal=W_coef[i]
		endfor	
	endif
print "Time to fit ="+num2str((ticks-starttime)/60)	
	variable/g AchievedChisq=V_chisq
	//here we graph the distribution
	IR2R_CalculateModelResults()
	IR2R_CalculateSLDProfile()
	IR2R_GraphModelResults()

//	IR1V_RecordErrorsAfterFit()
//	IR1V_GraphModelData()
////	IR1A_RecordResults("after")
////	
//	DoWIndow/F IR1V_ControlPanel
////	IR1A_FixTabsInPanel()
//	
//	KillWaves T_Constraints, E_wave
	KillWaves/Z ErrorFractionWave
//	
	
	setDataFolder OldDf
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2R_CheckFittingParamsFnct() 
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1/W=(400,140,870,600) as "Check fitting parameters"
	Dowindow/C IR2R_CheckFittingParams
	SetDrawLayer UserBack
	SetDrawEnv fsize= 20,fstyle= 3,textrgb= (0,0,65280)
	DrawText 39,28,"Reflectivity Fit Params & Limits"
		SetDrawEnv fstyle= 1,fsize= 14
		DrawText 10,50,"For Gen Opt. verify fitted parameters. Make sure"
		SetDrawEnv fstyle= 1,fsize= 14
		DrawText 10,70,"the parameter range is appropriate."
		SetDrawEnv fstyle= 1,fsize= 14
		DrawText 10,90,"The whole range must be valid! It will be tested!"
		SetDrawEnv fstyle= 1,fsize= 14
		DrawText 10,110,"       Then continue....."
	Button CancelBtn,pos={27,420},size={150,20},proc=IR2R_CheckFitPrmsButtonProc,title="Cancel fitting"
	Button ContinueBtn,pos={187,420},size={150,20},proc=IR2R_CheckFitPrmsButtonProc,title="Continue fitting"
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:Refl_SimpleTool:
	Wave Gen_Constraints,W_coef
	Wave/T CoefNames
	SetDimLabel 1,0,Min,Gen_Constraints
	SetDimLabel 1,1,Max,Gen_Constraints
	variable i
	For(i=0;i<numpnts(CoefNames);i+=1)
		SetDimLabel 0,i,$(CoefNames[i]),Gen_Constraints
	endfor
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
	SetDataFolder fldrSav0
	RenameWindow #,T0
	SetActiveSubwindow ##
End

// Function Test()
//> Make /o /n=(5,2) myWave
//> SetDimLabel 1,0,min,myWave
//> SetDimLabel 1,1,max,myWave
//> Edit myWave.ld
//> End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2R_CheckFitPrmsButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	if(stringmatch(ctrlName,"*CancelBtn*"))
		variable/g root:Packages:Refl_SimpleTool:UserCanceled=1
		DoWindow/K IR2R_CheckFittingParams
	endif

	if(stringmatch(ctrlName,"*ContinueBtn*"))
		variable/g root:Packages:Refl_SimpleTool:UserCanceled=0
		DoWindow/K IR2R_CheckFittingParams
	endif

End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2R_ResetParamsAfterBadFit()
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool

	Wave w=root:Packages:Refl_SimpleTool:CoefficientInput
	Wave/T CoefNames=root:Packages:Refl_SimpleTool:CoefNames		//text wave with names of parameters

	if ((!WaveExists(w)) || (!WaveExists(CoefNames)))
		Beep
		abort "Record of old parameters does not exist, this is BUG, please report it..."
	endif

	variable i
	For(i=0;i<numpnts(w);i+=1)
		NVAR testVal=$(CoefNames[i])
		testVal=w[i]
	endfor
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
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR2R_ST_FitFunction(w,yw,xw) : FitFunc
	Wave w,yw,xw
	
	//here the w contains the parameters, yw will be the result and xw is the input
	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(q) = very complex calculations, forget about formula
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1 - the q vector...
	//CurveFitDialog/ q

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool

	Wave/T CoefNames=root:Packages:Refl_SimpleTool:CoefNames		//text wave with names of parameters
	NVAR FitIQN=root:Packages:Refl_SimpleTool:FitIQN	

	variable i, NumOfParam
	NumOfParam=numpnts(CoefNames)
	string ParamName=""
	
	for (i=0;i<NumOfParam;i+=1)
		ParamName=CoefNames[i]
		NVAR tempVar=$(ParamName)
		//let's allow enforcement of positivity of given parameter here...
		if(stringmatch(ParamName, "*roughness*"))
			tempVar = abs( w[i])
		else
			tempVar = w[i]
		endif
	endfor

	Wave QvectorWave=root:Packages:Refl_SimpleTool:FitQvectorWave
//	Duplicate/O QvectorWave, SimpleToolFitIntensity
	//and now we need to calculate the model Intensity
	IR2R_FitCalculateModelResults(QvectorWave)		

//	FitIntensityWave = FitIntensityWave * FitQvectorWave^FitIQN
	
	Wave resultWv=root:Packages:Refl_SimpleTool:SimpleToolFitIntensity
	resultWv = resultWv * QvectorWave^FitIQN
//	resultWv = resultWv * xw^FitIQN
	
	yw=resultWv

	NVAR UpdateDuringFitting=root:Packages:Refl_SimpleTool:UpdateDuringFitting
	if(UpdateDuringFitting)
		IR2R_CalculateModelResults()
		IR2R_CalculateSLDProfile()
		IR2R_GraphModelResults()
		DoUpdate
	endif
	setDataFolder oldDF
End


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
Function IR2R_FitCalculateModelResults(FitQvector)
	wave FitQvector
	//this function calculates model data
//	make/o/t parameters_Cref = {"Numlayers","scale","re_SLDtop","imag_SLDtop","re_SLDbase","imag_SLD base","bkg","sigma_base","thick1","re_SLD1","imag_SLD1","rough1","thick2","re_SLD2","imag_SLD2","rough2"}
//	Edit parameters_Cref,coef_Cref,par_res,resolution
//	ywave_Cref:= Motofit_Imag(coef_Cref,xwave_Cref)

	variable i,j
	string OldDf=getDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool
	//Need to create wave with parameters for Motofit_Imag here
	NVAR NumberOfLayers= root:Packages:Refl_SimpleTool:NumberOfLayers
	//need 8 parameters to start with - numLayers, scale, TopSLD_real, TopSLD_Imag, Bot_SLD_real, BotSLD_imag, Background, SubstareRoughness, and then 4 parameters for each layer 
	// thickness, re_SLD, imag_SLD and roughness
	variable NumPointsNeeded= NumberOfLayers * 4 + 8
	
	make/O/N=(NumPointsNeeded) ParametersIn
	//now let's fill this in
	ParametersIn[0] = NumberOfLayers
	NVAR ScalingFactor=root:Packages:Refl_SimpleTool:ScalingFactor
	NVAR SLD_Real_Top=root:Packages:Refl_SimpleTool:SLD_Real_Top
	NVAR SLD_Imag_Top=root:Packages:Refl_SimpleTool:SLD_Imag_Top
	NVAR SLD_Real_Bot=root:Packages:Refl_SimpleTool:SLD_Real_Bot
	NVAR SLD_Imag_Bot=root:Packages:Refl_SimpleTool:SLD_Imag_Bot
	NVAR Background=root:Packages:Refl_SimpleTool:Background
	NVAR Roughness_Bot=root:Packages:Refl_SimpleTool:Roughness_Bot	
	NVAR L1AtTheBottom=root:Packages:Refl_SimpleTool:L1AtTheBottom
	
	
	ParametersIn[1] = ScalingFactor		
	ParametersIn[2] = SLD_Real_Top// * 1e-6
	ParametersIn[3] = SLD_Imag_Top * 1e-6
	ParametersIn[4] = SLD_Real_Bot// * 1e-6
	ParametersIn[5] = SLD_Imag_Bot * 1e-6
	ParametersIn[6] = Background
	ParametersIn[7] = Roughness_Bot

	//fix to allow L1 at the bottom...
	
	if(L1AtTheBottom)
		j=0
		for(i=NumberOfLayers;i>=1;i-=1)
			j+=1
			NVAR ThicknessLayer= $("root:Packages:Refl_SimpleTool:ThicknessLayer"+Num2str(i))
			NVAR SLD_real_Layer = $("root:Packages:Refl_SimpleTool:SLD_Real_Layer"+Num2str(i))
			NVAR SLD_imag_Layer = $("root:Packages:Refl_SimpleTool:SLD_Imag_Layer"+Num2str(i))
			NVAR RoughnessLayer = $("root:Packages:Refl_SimpleTool:RoughnessLayer"+Num2str(i))
			ParametersIn[7+(j-1)*4+1] =  ThicknessLayer
			ParametersIn[7+(j-1)*4+2] =  SLD_real_Layer// * 1e-6
			ParametersIn[7+(j-1)*4+3] =  SLD_imag_Layer * 1e-6
			ParametersIn[7+(j-1)*4+4] =  RoughnessLayer
		endfor

	else
		for(i=1;i<=NumberOfLayers;i+=1)
			NVAR ThicknessLayer= $("root:Packages:Refl_SimpleTool:ThicknessLayer"+Num2str(i))
			NVAR SLD_real_Layer = $("root:Packages:Refl_SimpleTool:SLD_Real_Layer"+Num2str(i))
			NVAR SLD_imag_Layer = $("root:Packages:Refl_SimpleTool:SLD_Imag_Layer"+Num2str(i))
			NVAR RoughnessLayer = $("root:Packages:Refl_SimpleTool:RoughnessLayer"+Num2str(i))
			ParametersIn[7+(i-1)*4+1] =  ThicknessLayer
			ParametersIn[7+(i-1)*4+2] =  SLD_real_Layer// * 1e-6
			ParametersIn[7+(i-1)*4+3] =  SLD_imag_Layer * 1e-6
			ParametersIn[7+(i-1)*4+4] =  RoughnessLayer
		endfor
	endif

	Duplicate/O FitQvector, SimpleToolFitIntensity
//	ModelIntensity=Calcreflectivity_Imag(ParametersIn,ModelQvector)
//	variable/g plotyp=2
//	SimpleToolFitIntensity=IR2R_CalculateReflectivity(ParametersIn,FitQvector)

	NVAR Resoln=root:Packages:Refl_SimpleTool:Resoln
	NVAR UseResolutionWave=root:Packages:Refl_SimpleTool:UseResolutionWave
	Wave/Z FitResolutionWave=root:Packages:Refl_SimpleTool:FitResolutionWave
	if(UseResolutionWave)	
		SimpleToolFitIntensity=IR2R_CalculateReflectivity(ParametersIn,FitQvector,FitResolutionWave)
	else//use resoln
		SimpleToolFitIntensity=IR2R_CalculateReflectivity(ParametersIn,FitQvector,Resoln)
	endif

	setDataFolder OldDf
	
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2R_CreateResolutionWave()
	//add on to create resolution wave... 
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool
	
	NVAR/Z Res_DeltaLambdaOverLambda
	if(!NVAR_EXISTS(Res_DeltaLambdaOverLambda))
		IR2R_InitializeSimpleTool()
	endif	
	NVAR Res_DeltaLambdaOverLambda
	NVAR Res_DeltaLambda
	NVAR Res_Lambda
	NVAR Res_SourceDivergence
	NVAR Res_DetectorSize
	NVAR Res_DetectorDistance
	NVAR Res_DetectorAngularResolution
	NVAR Res_sampleSize
	NVAR Res_beamHeight
	if(Res_Lambda==0)
		Res_Lambda=1
	endif
	if(Res_DetectorDistance==0)
		Res_DetectorDistance=1
	endif
	SVAR DataFolderName
	SVAR QWavename
	SetDataFolder $(DataFolderName)
	Wave Qwave=$(QWavename)
	Duplicate/O Qwave, CreatedFromParamaters
	Wave CreatedFromParamaters=CreatedFromParamaters
	
	setDataFolder root:Packages:Refl_SimpleTool
	DoWIndow ResolutionCalculator
	if(V_Flag)
		DoWindow/F ResolutionCalculator
	else
		//create new panel...
		PauseUpdate; Silent 1		// building window...
		NewPanel/K=1 /W=(195,94,658,561) as "Resolution calculator"
		DoWindow/C ResolutionCalculator
		SetDrawLayer UserBack
		SetDrawEnv fsize= 22,fstyle= 1,textrgb= (0,0,52224)
		DrawText 95,35,"Create resolution data"
		SetDrawEnv fsize= 16,fstyle= 1,textrgb= (0,0,52224)
		DrawText 9,63,"Wavelength resolution"
		SetDrawEnv fsize= 16,fstyle= 1,textrgb= (0,0,52224)
		DrawText 9,148,"Source divergence resolution"
		SetDrawEnv fsize= 16,fstyle= 1,textrgb= (0,0,52224)
		DrawText 9,233,"Sample footprint resolution"
		SetDrawEnv fsize= 16,fstyle= 1,textrgb= (0,0,52224)
		DrawText 9,318,"Detector resolution"
		SetDrawEnv fsize= 14,fstyle= 1
		DrawText 9,454,"Close when finished. Resolution data are always recalculated"
		SetDrawEnv fsize= 14,fstyle= 1
		DrawText 9,434,"Set to 0 unneeded or negligible calculations"

		SetVariable Res_DeltaLambda,pos={14,70},size={180,16},proc=IR2R_ResPanelSetVarProc,title="delta Wavelength [A]"
		SetVariable Res_DeltaLambda,limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:Res_DeltaLambda, help={"Uncertaininty of wavelength in wavelength units"}
		SetVariable Res_Lambda,pos={230,70},size={180,16},proc=IR2R_ResPanelSetVarProc,title="Wavelength [A]"
		SetVariable Res_Lambda,limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:Res_Lambda, help={"wavelength in wavelength units"}
		SetVariable Res_DeltaLambdaOverLambda,pos={100,100},size={200,16},proc=IR2R_ResPanelSetVarProc,title="Wavelength resolution "
		SetVariable Res_DeltaLambdaOverLambda,limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:Res_DeltaLambdaOverLambda, help={"dLambda/Lambda"}

		SetVariable Res_SourceDivergence,pos={14,160},size={300,16},proc=IR2R_ResPanelSetVarProc,title="Source angular divergence [rad]"
		SetVariable Res_SourceDivergence,limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:Res_SourceDivergence, help={"Angular divergence of source. 0 for parallel beam."}

		SetVariable Res_sampleSize,pos={14,250},size={180,16},proc=IR2R_ResPanelSetVarProc,title="Sample size [mm] "
		SetVariable Res_sampleSize,limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:Res_sampleSize, help={"length of sample in the beam direction in mm"}
		SetVariable Res_beamHeight,pos={230,250},size={180,16},proc=IR2R_ResPanelSetVarProc,title="Beam height in [mm] "
		SetVariable Res_beamHeight,limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:Res_beamHeight, help={"Height of beam in mm in the sample position"}

		SetVariable Res_DetectorSize,pos={14,340},size={180,16},proc=IR2R_ResPanelSetVarProc,title="Detector size [mm] "
		SetVariable Res_DetectorSize,limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:Res_DetectorSize, help={"Detector slits opening (size) in scanning direction in mm"}
		SetVariable Res_DetectorDistance,pos={230,340},size={180,16},proc=IR2R_ResPanelSetVarProc,title="Detector distance [mm] "
		SetVariable Res_DetectorDistance,limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:Res_DetectorDistance, help={"Distance between detector slits and sample in mm"}
		SetVariable Res_DetectorAngularResolution,pos={100,370},size={200,16},proc=IR2R_ResPanelSetVarProc,title="Detector resolution [rad] "
		SetVariable Res_DetectorAngularResolution,limits={0,inf,0},variable= root:Packages:Refl_SimpleTool:Res_DetectorAngularResolution, help={"Detector resolution in radians"}
	endif
	
	IR2R_ResRecalculateResolution()
	setDataFolder OldDf
	
end
///******************************************************************************************
///******************************************************************************************
Function IR2R_ResRecalculateResolution()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool
	SVAR DataFolderName
	SVAR QWavename
	SetDataFolder $(DataFolderName)
	Wave Qwave=$(QWavename)
	Wave ResWv=CreatedFromParamaters
	setDataFolder root:Packages:Refl_SimpleTool

	NVAR Res_DeltaLambdaOverLambda
	NVAR Res_SourceDivergence
	NVAR Res_DetectorAngularResolution
	NVAR Res_sampleSize
	NVAR Res_beamHeight
	NVAR Res_Lambda
	NVAR Res_DetectorDistance
	variable i
	variable curAngRes
	variable curAngle
	variable curFootprint, curDetRes
	
	for(i=0;i<numpnts(Qwave);i+=1)
		curAngle = asin(Qwave[i] * Res_Lambda /(4*pi))
		if(Res_sampleSize>0 && Res_beamHeight>0)
			curFootprint = min(Res_sampleSize,(Res_beamHeight/sin(curAngle)))
			curDetRes = curFootprint * sin(curAngle)/Res_DetectorDistance
		else
			curDetRes=0
		endif
		if(Res_DetectorAngularResolution>0)
			curAngRes = Res_DetectorAngularResolution / curAngle
		else
			curAngRes=0
		endif
		
		ResWv[i] = 100 * sqrt(curDetRes^2 + curAngRes^2 + Res_SourceDivergence^2 +Res_DeltaLambdaOverLambda^2)
	endfor

	setDataFolder OldDf
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2R_ResPanelSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Refl_SimpleTool
	NVAR Res_DeltaLambdaOverLambda
	NVAR Res_DeltaLambda
	NVAR Res_Lambda
	NVAR Res_SourceDivergence
	NVAR Res_DetectorSize
	NVAR Res_DetectorDistance
	NVAR Res_DetectorAngularResolution
	NVAR Res_sampleSize
	NVAR Res_beamHeight

	if (stringmatch(ctrlName,"Res_DeltaLambda") || stringmatch(ctrlName,"Res_Lambda"))
		Res_DeltaLambdaOverLambda = Res_DeltaLambda/Res_Lambda
	endif
	if (stringmatch(ctrlName,"Res_DeltaLambdaOverLambda"))
		Res_DeltaLambda = Res_DeltaLambdaOverLambda * Res_Lambda
	endif
	if (stringmatch(ctrlName,"Res_DetectorSize") || stringmatch(ctrlName,"Res_DetectorDistance"))
		Res_DetectorAngularResolution = Res_DetectorSize/Res_DetectorDistance
	endif
	if (stringmatch(ctrlName,"Res_DetectorAngularResolution"))
		Res_DetectorSize = Res_DetectorAngularResolution * Res_DetectorDistance
	endif
	
	IR2R_ResRecalculateResolution()
	setDataFolder OldDf
end