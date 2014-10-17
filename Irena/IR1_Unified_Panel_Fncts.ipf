#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.01

//version 2.01 has changes to accomodate the Analyze results


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1A_PanelSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_UnifFit
	
	NVAR AutoUpdate=root:Packages:Irena_UnifFit:UpdateAutomatically
	
	if (cmpstr(ctrlName,"SASBackground")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"SASBackgroundStep")==0)
		//here goes what happens when user changes the SASBackground in distribution
		SetVariable SASBackground,win=IR1A_ControlPanel, limits={0,Inf,varNum}
	endif
	if (cmpstr(ctrlName,"SubtractBackground")==0)
		//here goes what happens when user changes the SASBackground in distribution
		IR1A_GraphMeasuredData("Unified")
	endif

//Level1

	if (cmpstr(ctrlName,"Level1_Rg")==0)
		//here goes what happens when user changes the Rg
		IR1A_CorrectLimitsAndValues()
		IR1A_DisplayLocalFits(1,0)
		IR1A_UpdateMassFractCalc()
		IR1A_UpdatePorodSurface()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level1_RgLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level1_RgHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level1_G")==0)
		//here goes what happens when user changes the G
		IR1A_CorrectLimitsAndValues()
		IR1A_DisplayLocalFits(1,0)
		IR1A_UpdatePorodSurface()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level1_GLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level1_GHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level1_P")==0)
		//here goes what happens when user changes the P
		IR1A_CorrectLimitsAndValues()
		IR1A_DisplayLocalFits(1,0)
		IR1A_UpdatePorodSurface()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level1_PLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level1_PHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level1_B")==0)
		//here goes what happens when user changes the B
		IR1A_CorrectLimitsAndValues()
		IR1A_DisplayLocalFits(1,0)
		IR1A_UpdatePorodSurface()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level1_BLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level1_BHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level1_ETA")==0)
		//here goes what happens when user changes the ETA
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level1_ETALowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level1_ETAHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level1_PACK")==0)
		//here goes what happens when user changes the PACK
		IR1A_CorrectLimitsAndValues()
		IR1A_UpdatePorodSurface()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level1_PACKLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level1_PACKHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level1_RGCO")==0)
		IR1A_UpdatePorodSurface()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level1_RGCOLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level1_RGCOHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level1_RgStep")==0)
		//here goes what happens when user changes the step for shape
		NVAR Level1RgStep=root:Packages:Irena_UnifFit:Level1RgStep
		Level1RGStep=VarNum
		SetVariable Level1_RgStep,limits={0,inf,(0.1*Level1RgStep)}
		SetVariable Level1_RG,limits={0,inf,Level1RgStep}
	endif
	if (cmpstr(ctrlName,"Level1_GStep")==0)
		//here goes what happens when user changes the step for shape
		NVAR Level1GStep=root:Packages:Irena_UnifFit:Level1GStep
		Level1GStep=VarNum
		SetVariable Level1_GStep,limits={0,inf,(0.1*Level1GStep)}
		SetVariable Level1_G,limits={0,inf,Level1GStep}
	endif
	if (cmpstr(ctrlName,"Level1_PStep")==0)
		//here goes what happens when user changes the step for shape
		NVAR Level1PStep=root:Packages:Irena_UnifFit:Level1PStep
		Level1PStep=VarNum
		SetVariable Level1_PStep,limits={0,inf,(0.1*Level1PStep)}
		SetVariable Level1_P,limits={0,inf,Level1PStep}
	endif
	if (cmpstr(ctrlName,"Level1_BStep")==0)
		//here goes what happens when user changes the step for shape
		NVAR Level1BStep=root:Packages:Irena_UnifFit:Level1BStep
		Level1BStep=VarNum
		SetVariable Level1_BStep,limits={0,inf,(0.1*Level1BStep)}
		SetVariable Level1_B,limits={0,inf,Level1BStep}
	endif
	if (cmpstr(ctrlName,"Level1_EtaStep")==0)
		//here goes what happens when user changes the step for shape
		NVAR Level1EtaStep=root:Packages:Irena_UnifFit:Level1EtaStep
		Level1EtaStep=VarNum
		SetVariable Level1_EtaStep,limits={0,inf,(0.1*Level1EtaStep)}
		SetVariable Level1_Eta,limits={0,inf,Level1EtaStep}
	endif
	if (cmpstr(ctrlName,"Level1_PackStep")==0)
		//here goes what happens when user changes the step for shape
		NVAR Level1PackStep=root:Packages:Irena_UnifFit:Level1PackStep
		Level1PackStep=VarNum
		SetVariable Level1_PackStep,limits={0,inf,(0.1*Level1PackStep)}
		SetVariable Level1_Pack,limits={0,inf,Level1PackStep}
	endif



//Level2

	if (cmpstr(ctrlName,"Level2_Rg")==0)
		//here goes what happens when user changes the Rg
		IR1A_CorrectLimitsAndValues()
		IR1A_DisplayLocalFits(2,0)
		IR1A_UpdateMassFractCalc()
		IR1A_UpdatePorodSurface()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level2_RgLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level2_RgHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level2_G")==0)
		//here goes what happens when user changes the G
		IR1A_CorrectLimitsAndValues()
		IR1A_DisplayLocalFits(2,0)
		IR1A_UpdatePorodSurface()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level2_GLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level2_GHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level2_P")==0)
		//here goes what happens when user changes the P
		IR1A_CorrectLimitsAndValues()
		IR1A_DisplayLocalFits(2,0)
		IR1A_UpdatePorodSurface()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level2_PLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level2_PHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level2_B")==0)
		//here goes what happens when user changes the B
		IR1A_CorrectLimitsAndValues()
		IR1A_DisplayLocalFits(2,0)
		IR1A_UpdatePorodSurface()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level2_BLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level2_BHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level2_ETA")==0)
		//here goes what happens when user changes the ETA
		IR1A_CorrectLimitsAndValues()
		IR1A_AutoUpdateIfSelected()
		IR1A_UpdatePorodSurface()
	endif
	if (cmpstr(ctrlName,"Level2_ETALowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level2_ETAHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level2_PACK")==0)
		//here goes what happens when user changes the Pack
		IR1A_CorrectLimitsAndValues()
		IR1A_UpdatePorodSurface()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level2_PACKLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level2_PACKHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level2_RGCO")==0)
		//here goes what happens when user changes the RgCO
		IR1A_UpdatePorodSurface()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level2_RGCOLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level2_RGCOHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level2_RgStep")==0)
		//here goes what happens when user changes the step for shape
		NVAR Level2RgStep=root:Packages:Irena_UnifFit:Level2RgStep
		Level2RGStep=VarNum
		SetVariable Level2_RgStep,limits={0,inf,(0.1*Level2RgStep)}
		SetVariable Level2_RG,limits={0,inf,Level2RgStep}
	endif
	if (cmpstr(ctrlName,"Level2_GStep")==0)
		//here goes what happens when user changes the step for shape
		NVAR Level2GStep=root:Packages:Irena_UnifFit:Level2GStep
		Level2GStep=VarNum
		SetVariable Level2_GStep,limits={0,inf,(0.1*Level2GStep)}
		SetVariable Level2_G,limits={0,inf,Level2GStep}
	endif
	if (cmpstr(ctrlName,"Level2_PStep")==0)
		//here goes what happens when user changes the step for shape
		NVAR Level2PStep=root:Packages:Irena_UnifFit:Level2PStep
		Level2PStep=VarNum
		SetVariable Level2_PStep,limits={0,inf,(0.1*Level2PStep)}
		SetVariable Level2_P,limits={0,inf,Level2PStep}
	endif
	if (cmpstr(ctrlName,"Level2_BStep")==0)
		//here goes what happens when user changes the step for shape
		NVAR Level2BStep=root:Packages:Irena_UnifFit:Level2BStep
		Level2BStep=VarNum
		SetVariable Level2_BStep,limits={0,inf,(0.1*Level2BStep)}
		SetVariable Level2_B,limits={0,inf,Level2BStep}
	endif
	if (cmpstr(ctrlName,"Level2_EtaStep")==0)
		//here goes what happens when user changes the step for shape
		NVAR Level2EtaStep=root:Packages:Irena_UnifFit:Level2EtaStep
		Level2EtaStep=VarNum
		SetVariable Level2_EtaStep,limits={0,inf,(0.1*Level2EtaStep)}
		SetVariable Level2_Eta,limits={0,inf,Level2EtaStep}
	endif
	if (cmpstr(ctrlName,"Level2_PackStep")==0)
		//here goes what happens when user changes the step for shape
		NVAR Level2PackStep=root:Packages:Irena_UnifFit:Level2PackStep
		Level2PackStep=VarNum
		SetVariable Level2_PackStep,limits={0,inf,(0.1*Level2PackStep)}
		SetVariable Level2_Pack,limits={0,inf,Level2PackStep}
	endif

//Level3

	if (cmpstr(ctrlName,"Level3_Rg")==0)
		//here goes what happens when user changes the Rg
		IR1A_CorrectLimitsAndValues()
		IR1A_DisplayLocalFits(3,0)
		IR1A_UpdateMassFractCalc()
		IR1A_UpdatePorodSurface()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level3_RgLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level3_RgHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level3_G")==0)
		//here goes what happens when user changes the G
		IR1A_CorrectLimitsAndValues()
		IR1A_DisplayLocalFits(3,0)
		IR1A_UpdatePorodSurface()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level3_GLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level3_GHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level3_P")==0)
		//here goes what happens when user changes the P
		IR1A_CorrectLimitsAndValues()
		IR1A_DisplayLocalFits(3,0)
		IR1A_UpdatePorodSurface()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level3_PLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level3_PHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level3_B")==0)
		//here goes what happens when user changes the B
		IR1A_CorrectLimitsAndValues()
		IR1A_DisplayLocalFits(3,0)
		IR1A_UpdatePorodSurface()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level3_BLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level3_BHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level3_ETA")==0)
		//here goes what happens when user changes the ETA
		IR1A_CorrectLimitsAndValues()
		IR1A_AutoUpdateIfSelected()
		IR1A_UpdatePorodSurface()
	endif
	if (cmpstr(ctrlName,"Level3_ETALowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level3_ETAHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level3_PACK")==0)
		//here goes what happens when user changes the Pack
		IR1A_CorrectLimitsAndValues()
		IR1A_AutoUpdateIfSelected()
		IR1A_UpdatePorodSurface()
	endif
	if (cmpstr(ctrlName,"Level3_PACKLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level3_PACKHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level3_RGCO")==0)
		//here goes what happens when user changes the RgCO
		IR1A_UpdatePorodSurface()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level3_RGCOLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level3_RGCOHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level3_RgStep")==0)
		//here goes what happens when user changes the step for shape
		NVAR Level3RgStep=root:Packages:Irena_UnifFit:Level3RgStep
		Level3RGStep=VarNum
		SetVariable Level3_RgStep,limits={0,inf,(0.1*Level3RgStep)}
		SetVariable Level3_RG,limits={0,inf,Level3RgStep}
	endif
	if (cmpstr(ctrlName,"Level3_GStep")==0)
		//here goes what happens when user changes the step for shape
		NVAR Level3GStep=root:Packages:Irena_UnifFit:Level3GStep
		Level3GStep=VarNum
		SetVariable Level3_GStep,limits={0,inf,(0.1*Level3GStep)}
		SetVariable Level3_G,limits={0,inf,Level3GStep}
	endif
	if (cmpstr(ctrlName,"Level3_PStep")==0)
		//here goes what happens when user changes the step for shape
		NVAR Level3PStep=root:Packages:Irena_UnifFit:Level3PStep
		Level3PStep=VarNum
		SetVariable Level3_PStep,limits={0,inf,(0.1*Level3PStep)}
		SetVariable Level3_P,limits={0,inf,Level3PStep}
	endif
	if (cmpstr(ctrlName,"Level3_BStep")==0)
		//here goes what happens when user changes the step for shape
		NVAR Level3BStep=root:Packages:Irena_UnifFit:Level3BStep
		Level3BStep=VarNum
		SetVariable Level3_BStep,limits={0,inf,(0.1*Level3BStep)}
		SetVariable Level3_B,limits={0,inf,Level3BStep}
	endif
	if (cmpstr(ctrlName,"Level3_EtaStep")==0)
		//here goes what happens when user changes the step for shape
		NVAR Level3EtaStep=root:Packages:Irena_UnifFit:Level3EtaStep
		Level3EtaStep=VarNum
		SetVariable Level3_EtaStep,limits={0,inf,(0.1*Level3EtaStep)}
		SetVariable Level3_Eta,limits={0,inf,Level3EtaStep}
	endif
	if (cmpstr(ctrlName,"Level3_PackStep")==0)
		//here goes what happens when user changes the step for shape
		NVAR Level3PackStep=root:Packages:Irena_UnifFit:Level3PackStep
		Level3PackStep=VarNum
		SetVariable Level3_PackStep,limits={0,inf,(0.1*Level3PackStep)}
		SetVariable Level3_Pack,limits={0,inf,Level3PackStep}
	endif


//Level4

	if (cmpstr(ctrlName,"Level4_Rg")==0)
		//here goes what happens when user changes the Rg
		IR1A_CorrectLimitsAndValues()
		IR1A_DisplayLocalFits(4,0)
		IR1A_UpdateMassFractCalc()
		IR1A_UpdatePorodSurface()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level4_RgLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level4_RgHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level4_G")==0)
		//here goes what happens when user changes the G
		IR1A_CorrectLimitsAndValues()
		IR1A_DisplayLocalFits(4,0)
		IR1A_UpdatePorodSurface()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level4_GLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level4_GHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level4_P")==0)
		//here goes what happens when user changes the P
		IR1A_CorrectLimitsAndValues()
		IR1A_DisplayLocalFits(4,0)
		IR1A_UpdatePorodSurface()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level4_PLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level4_PHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level4_B")==0)
		//here goes what happens when user changes the B
		IR1A_CorrectLimitsAndValues()
		IR1A_DisplayLocalFits(4,0)
		IR1A_UpdatePorodSurface()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level4_BLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level4_BHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level4_ETA")==0)
		//here goes what happens when user changes the ETA
		IR1A_CorrectLimitsAndValues()
		IR1A_AutoUpdateIfSelected()
		IR1A_UpdatePorodSurface()
	endif
	if (cmpstr(ctrlName,"Level4_ETALowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level4_ETAHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level4_PACK")==0)
		//here goes what happens when user changes the Pack
		IR1A_CorrectLimitsAndValues()
		IR1A_AutoUpdateIfSelected()
		IR1A_UpdatePorodSurface()
	endif
	if (cmpstr(ctrlName,"Level4_PACKLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level4_PACKHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level4_RGCO")==0)
		//here goes what happens when user changes the RgCO
		IR1A_UpdatePorodSurface()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level4_RGCOLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level4_RGCOHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level4_RgStep")==0)
		//here goes what happens when user changes the step for shape
		NVAR Level4RgStep=root:Packages:Irena_UnifFit:Level4RgStep
		Level4RGStep=VarNum
		SetVariable Level4_RgStep,limits={0,inf,(0.1*Level4RgStep)}
		SetVariable Level4_RG,limits={0,inf,Level4RgStep}
	endif
	if (cmpstr(ctrlName,"Level4_GStep")==0)
		//here goes what happens when user changes the step for shape
		NVAR Level4GStep=root:Packages:Irena_UnifFit:Level4GStep
		Level4GStep=VarNum
		SetVariable Level4_GStep,limits={0,inf,(0.1*Level4GStep)}
		SetVariable Level4_G,limits={0,inf,Level4GStep}
	endif
	if (cmpstr(ctrlName,"Level4_PStep")==0)
		//here goes what happens when user changes the step for shape
		NVAR Level4PStep=root:Packages:Irena_UnifFit:Level4PStep
		Level4PStep=VarNum
		SetVariable Level4_PStep,limits={0,inf,(0.1*Level4PStep)}
		SetVariable Level4_P,limits={0,inf,Level4PStep}
	endif
	if (cmpstr(ctrlName,"Level4_BStep")==0)
		//here goes what happens when user changes the step for shape
		NVAR Level4BStep=root:Packages:Irena_UnifFit:Level4BStep
		Level4BStep=VarNum
		SetVariable Level4_BStep,limits={0,inf,(0.1*Level4BStep)}
		SetVariable Level4_B,limits={0,inf,Level4BStep}
	endif
	if (cmpstr(ctrlName,"Level4_EtaStep")==0)
		//here goes what happens when user changes the step for shape
		NVAR Level4EtaStep=root:Packages:Irena_UnifFit:Level4EtaStep
		Level4EtaStep=VarNum
		SetVariable Level4_EtaStep,limits={0,inf,(0.1*Level4EtaStep)}
		SetVariable Level4_Eta,limits={0,inf,Level4EtaStep}
	endif
	if (cmpstr(ctrlName,"Level4_PackStep")==0)
		//here goes what happens when user changes the step for shape
		NVAR Level4PackStep=root:Packages:Irena_UnifFit:Level4PackStep
		Level4PackStep=VarNum
		SetVariable Level4_PackStep,limits={0,inf,(0.1*Level4PackStep)}
		SetVariable Level4_Pack,limits={0,inf,Level4PackStep}
	endif


//Level5

	if (cmpstr(ctrlName,"Level5_Rg")==0)
		//here goes what happens when user changes the Rg
		IR1A_CorrectLimitsAndValues()
		IR1A_DisplayLocalFits(5,0)
		IR1A_UpdateMassFractCalc()
		IR1A_UpdatePorodSurface()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level5_RgLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level5_RgHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level5_G")==0)
		//here goes what happens when user changes the G
		IR1A_CorrectLimitsAndValues()
		IR1A_DisplayLocalFits(5,0)
		IR1A_UpdatePorodSurface()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level5_GLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level5_GHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level5_P")==0)
		//here goes what happens when user changes the P
		IR1A_CorrectLimitsAndValues()
		IR1A_DisplayLocalFits(5,0)
		IR1A_UpdatePorodSurface()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level5_PLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level5_PHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level5_B")==0)
		//here goes what happens when user changes the B
		IR1A_CorrectLimitsAndValues()
		IR1A_DisplayLocalFits(5,0)
		IR1A_UpdatePorodSurface()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level5_BLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level5_BHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level5_ETA")==0)
		//here goes what happens when user changes the ETA
		IR1A_CorrectLimitsAndValues()
		IR1A_AutoUpdateIfSelected()
		IR1A_UpdatePorodSurface()
	endif
	if (cmpstr(ctrlName,"Level5_ETALowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level5_ETAHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level5_PACK")==0)
		//here goes what happens when user changes the Pack
		IR1A_CorrectLimitsAndValues()
		IR1A_AutoUpdateIfSelected()
		IR1A_UpdatePorodSurface()
	endif
	if (cmpstr(ctrlName,"Level5_PACKLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level5_PACKHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level5_RGCO")==0)
		//here goes what happens when user changes the RgCO
		IR1A_UpdatePorodSurface()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level5_RGCOLowLimit")==0)

	endif
	if (cmpstr(ctrlName,"Level5_RGCOHighLimit")==0)

	endif

	if (cmpstr(ctrlName,"Level5_RgStep")==0)
		//here goes what happens when user changes the step for shape
		NVAR Level5RgStep=root:Packages:Irena_UnifFit:Level5RgStep
		Level5RGStep=VarNum
		SetVariable Level5_RgStep,limits={0,inf,(0.1*Level5RgStep)}
		SetVariable Level5_RG,limits={0,inf,Level5RgStep}
	endif
	if (cmpstr(ctrlName,"Level5_GStep")==0)
		//here goes what happens when user changes the step for shape
		NVAR Level5GStep=root:Packages:Irena_UnifFit:Level5GStep
		Level5GStep=VarNum
		SetVariable Level5_GStep,limits={0,inf,(0.1*Level5GStep)}
		SetVariable Level5_G,limits={0,inf,Level5GStep}
	endif
	if (cmpstr(ctrlName,"Level5_PStep")==0)
		//here goes what happens when user changes the step for shape
		NVAR Level5PStep=root:Packages:Irena_UnifFit:Level5PStep
		Level5PStep=VarNum
		SetVariable Level5_PStep,limits={0,inf,(0.1*Level5PStep)}
		SetVariable Level5_P,limits={0,inf,Level5PStep}
	endif
	if (cmpstr(ctrlName,"Level5_BStep")==0)
		//here goes what happens when user changes the step for shape
		NVAR Level5BStep=root:Packages:Irena_UnifFit:Level5BStep
		Level5BStep=VarNum
		SetVariable Level5_BStep,limits={0,inf,(0.1*Level5BStep)}
		SetVariable Level5_B,limits={0,inf,Level5BStep}
	endif
	if (cmpstr(ctrlName,"Level5_EtaStep")==0)
		//here goes what happens when user changes the step for shape
		NVAR Level5EtaStep=root:Packages:Irena_UnifFit:Level5EtaStep
		Level5EtaStep=VarNum
		SetVariable Level5_EtaStep,limits={0,inf,(0.1*Level5EtaStep)}
		SetVariable Level5_Eta,limits={0,inf,Level5EtaStep}
	endif
	if (cmpstr(ctrlName,"Level5_PackStep")==0)
		//here goes what happens when user changes the step for shape
		NVAR Level5PackStep=root:Packages:Irena_UnifFit:Level5PackStep
		Level5PackStep=VarNum
		SetVariable Level5_PackStep,limits={0,inf,(0.1*Level5PackStep)}
		SetVariable Level5_Pack,limits={0,inf,Level5PackStep}
	endif

	DoWIndow/F IR1A_ControlPanel

end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1A_InputPanelCheckboxProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_UnifFit


	if (cmpstr(ctrlName,"UseSMRData")==0)
		//here we control the data structure checkbox
		NVAR UseIndra2Data=root:Packages:Irena_UnifFit:UseIndra2Data
		NVAR UseQRSData=root:Packages:Irena_UnifFit:UseQRSData
		NVAR UseSMRData=root:Packages:Irena_UnifFit:UseSMRData
		SetVariable SlitLength,win=IR1A_ControlPanel, disable=!UseSMRData
		Checkbox UseIndra2Data,win=IR1A_ControlPanel, value=UseIndra2Data
		Checkbox UseQRSData,win=IR1A_ControlPanel, value=UseQRSData
		SVAR Dtf=root:Packages:Irena_UnifFit:DataFolderName
		SVAR IntDf=root:Packages:Irena_UnifFit:IntensityWaveName
		SVAR QDf=root:Packages:Irena_UnifFit:QWaveName
		SVAR EDf=root:Packages:Irena_UnifFit:ErrorWaveName
			Dtf=" "
			IntDf=" "
			QDf=" "
			EDf=" "
			PopupMenu SelectDataFolder,win=IR1A_ControlPanel, mode=1
			PopupMenu IntensityDataName,  mode=1,win=IR1A_ControlPanel, value="---"
			PopupMenu QvecDataName, mode=1,win=IR1A_ControlPanel, value="---"
			PopupMenu ErrorDataName, mode=1,win=IR1A_ControlPanel, value="---"
		//here we control the data structure checkbox
			PopupMenu SelectDataFolder,win=IR1A_ControlPanel, value= #"\"---;\"+IR1_GenStringOfFolders(root:Packages:Irena_UnifFit:UseIndra2Data, root:Packages:Irena_UnifFit:UseQRSData,root:Packages:Irena_UnifFit:UseSMRData,0)"
	endif

	if (cmpstr(ctrlName,"UseIndra2Data")==0)
		//here we control the data structure checkbox
		NVAR UseIndra2Data=root:Packages:Irena_UnifFit:UseIndra2Data
		NVAR UseQRSData=root:Packages:Irena_UnifFit:UseQRSData
		UseIndra2Data=checked
		if (checked)
			UseQRSData=0
		endif
		Checkbox UseIndra2Data,win=IR1A_ControlPanel, value=UseIndra2Data
		Checkbox UseQRSData,win=IR1A_ControlPanel, value=UseQRSData
		SVAR Dtf=root:Packages:Irena_UnifFit:DataFolderName
		SVAR IntDf=root:Packages:Irena_UnifFit:IntensityWaveName
		SVAR QDf=root:Packages:Irena_UnifFit:QWaveName
		SVAR EDf=root:Packages:Irena_UnifFit:ErrorWaveName
			Dtf=" "
			IntDf=" "
			QDf=" "
			EDf=" "
			PopupMenu SelectDataFolder ,win=IR1A_ControlPanel, mode=1
			PopupMenu IntensityDataName  mode=1,win=IR1A_ControlPanel, value="---"
			PopupMenu QvecDataName    mode=1,win=IR1A_ControlPanel, value="---"
			PopupMenu ErrorDataName    mode=1,win=IR1A_ControlPanel, value="---"
	endif
	if (cmpstr(ctrlName,"UseQRSData")==0)
		//here we control the data structure checkbox
		NVAR UseQRSData=root:Packages:Irena_UnifFit:UseQRSData
		NVAR UseIndra2Data=root:Packages:Irena_UnifFit:UseIndra2Data
		UseQRSData=checked
		if (checked)
			UseIndra2Data=0
		endif
		Checkbox UseIndra2Data,win=IR1A_ControlPanel, value=UseIndra2Data
		Checkbox UseQRSData,win=IR1A_ControlPanel, value=UseQRSData
		SVAR Dtf=root:Packages:Irena_UnifFit:DataFolderName
		SVAR IntDf=root:Packages:Irena_UnifFit:IntensityWaveName
		SVAR QDf=root:Packages:Irena_UnifFit:QWaveName
		SVAR EDf=root:Packages:Irena_UnifFit:ErrorWaveName
			Dtf=" "
			IntDf=" "
			QDf=" "
			EDf=" "
			PopupMenu SelectDataFolder,win=IR1A_ControlPanel, mode=1
			PopupMenu IntensityDataName   mode=1,win=IR1A_ControlPanel, value="---"
			PopupMenu QvecDataName    mode=1,win=IR1A_ControlPanel, value="---"
			PopupMenu ErrorDataName    mode=1,win=IR1A_ControlPanel, value="---"
	endif
	if (cmpstr(ctrlName,"FitBackground")==0)
		//here we control the data structure checkbox
	//	NVAR FitSASBackground=root:Packages:Irena_UnifFit:FitSASBackground
	//	FitSASBackground=checked
	//	Checkbox FitBackground, value=FitSASBackground
	endif

	if (cmpstr(ctrlName,"DisplayLocalFits")==0)
		//here we control the data structure checkbox
	//	NVAR DisplayLocalFits=root:Packages:Irena_UnifFit:DisplayLocalFits
	//	DisplayLocalFits=checked
	//	Checkbox DisplayLocalFits, value=DisplayLocalFits
		//and here needs to go function which appends the fits.... Need to figure outt active tab...
		NVAR ActiveTab=root:Packages:Irena_UnifFit:ActiveTab
		IR1A_DisplayLocalFits(ActiveTab,0)
	endif
	if (cmpstr(ctrlName,"UpdateAutomatically")==0)
		//here we control the data structure checkbox
	//	NVAR UpdateAutomatically=root:Packages:Irena_UnifFit:UpdateAutomatically
	//	UpdateAutomatically=checked
	//	Checkbox UpdateAutomatically, value=UpdateAutomatically
		IR1A_AutoUpdateIfSelected()
	endif
	
//Level 1 controls


	if (cmpstr(ctrlName,"Level1_MassFractal")==0)
		//here we control the data structure checkbox
		NVAR Level1MassFractal=root:Packages:Irena_UnifFit:Level1MassFractal
		NVAR Level1FitB=root:Packages:Irena_UnifFit:Level1FitB
		NVAR Level1PHighLimit=root:Packages:Irena_UnifFit:Level1PHighLimit
		NVAR Level1PLowLimit=root:Packages:Irena_UnifFit:Level1PLowLimit
		NVAR Level1P=root:Packages:Irena_UnifFit:Level1P
		NVAR Level1K=root:Packages:Irena_UnifFit:Level1K
		if (checked==1)
			Level1PHighLimit=3
			Level1PLowLimit=1
			Level1P=2
			Level1K=1.06
			PopupMenu Level1_KFactor, mode=2
		else
			Level1PHighLimit=4
			Level1PLowLimit=1
			Level1K=1
			PopupMenu Level1_KFactor, mode=1
		endif
		Level1MassFractal=checked
		Level1FitB=0
		Checkbox Level1_MassFractal, value=Level1MassFractal
		Checkbox Level1_FitB, value=0
		IR1A_TabPanelControl("bla",0)
		IR1A_UpdateLocalFitsIfSelected()
		IR1A_UpdateMassFractCalc()
		IR1A_UpdatePorodSurface()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level1_Corelations")==0)
		//here we control the data structure checkbox
		//NVAR Level1Corelations=root:Packages:Irena_UnifFit:Level1Corelations
		//Level1Corelations=checked
		//Checkbox Level1_Corelations, value=Level1Corelations
		IR1A_TabPanelControl("bla",0)
		IR1A_UpdateLocalFitsIfSelected()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level1_FitRg")==0)
		//here we control the data structure checkbox
		//NVAR Level1FitRg=root:Packages:Irena_UnifFit:Level1FitRg
		//Level1FitRg=checked
		//Checkbox Level1_FitRg, value=Level1FitRg
		IR1A_TabPanelControl("bla",0)
	endif
	if (cmpstr(ctrlName,"Level1_FitG")==0)
		//here we control the data structure checkbox
		//NVAR Level1FitG=root:Packages:Irena_UnifFit:Level1FitG
		//Level1FitG=checked
		//Checkbox Level1_FitG, value=Level1FitG
		IR1A_TabPanelControl("bla",0)
	endif
	if (cmpstr(ctrlName,"Level1_FitP")==0)
		//here we control the data structure checkbox
		//NVAR Level1FitP=root:Packages:Irena_UnifFit:Level1FitP
		///Level1FitP=checked
		//Checkbox Level1_FitP, value=Level1FitP
		IR1A_TabPanelControl("bla",0)
	endif
	if (cmpstr(ctrlName,"Level1_FitB")==0)
		//here we control the data structure checkbox
		//NVAR Level1FitB=root:Packages:Irena_UnifFit:Level1FitB
		//Level1FitB=checked
		//Checkbox Level1_FitB, value=Level1FitB
		IR1A_TabPanelControl("bla",0)
	endif
	if (cmpstr(ctrlName,"Level1_FitEta")==0)
		//here we control the data structure checkbox
		//NVAR Level1FitEta=root:Packages:Irena_UnifFit:Level1FitEta
		//Level1FitEta=checked
		//Checkbox Level1_FitEta, value=Level1FitEta
		IR1A_TabPanelControl("bla",0)
	endif
	if (cmpstr(ctrlName,"Level1_FitPack")==0)
		//here we control the data structure checkbox
		//NVAR Level1FitPack=root:Packages:Irena_UnifFit:Level1FitPack
		//Level1FitPack=checked
		//Checkbox Level1_FitPack, value=Level1FitPack
		IR1A_TabPanelControl("bla",0)
	endif
	if (cmpstr(ctrlName,"Level1_FitRGCO")==0)
		//here we control the data structure checkbox
		//NVAR Level1FitRGCO=root:Packages:Irena_UnifFit:Level1FitRGCO
		//Level1FitRGCO=checked
		//Checkbox Level1_FitRGCO, value=Level1FitRGCO
		IR1A_TabPanelControl("bla",0)
	endif
	if (cmpstr(ctrlName,"Level1_LinkRGCO")==0)
		//here we control the data structure checkbox
		//NVAR Level1LinkRGCO=root:Packages:Irena_UnifFit:Level1LinkRGCO
		NVAR Level1FitRGCO=root:Packages:Irena_UnifFit:Level1FitRGCO
		//Level1LinkRGCO=checked
		Level1FitRGCO=0
		//Checkbox Level1_FitRGCO, value=Level1FitRGCO
		//Checkbox Level1_LinkRGCO, value=Level1LinkRGCO
		IR1A_TabPanelControl("bla",0)
		IR1A_AutoUpdateIfSelected()
	endif




//Level2 controls
	if (cmpstr(ctrlName,"Level2_MassFractal")==0)
		//here we control the data structure checkbox
		NVAR Level2MassFractal=root:Packages:Irena_UnifFit:Level2MassFractal
		NVAR Level2FitB=root:Packages:Irena_UnifFit:Level2FitB
		NVAR Level2PHighLimit=root:Packages:Irena_UnifFit:Level2PHighLimit
		NVAR Level2PLowLimit=root:Packages:Irena_UnifFit:Level2PLowLimit
		NVAR Level2P=root:Packages:Irena_UnifFit:Level2P
		NVAR Level2K=root:Packages:Irena_UnifFit:Level2K
		if (checked==1)
			Level2PHighLimit=3
			Level2PLowLimit=1
			Level2P=2
			Level2K=1.06
			PopupMenu Level2_KFactor, mode=2
		else
			Level2PHighLimit=4
			Level2PLowLimit=1
			Level2K=1
			PopupMenu Level2_KFactor, mode=1
		endif
		Level2MassFractal=checked
		Level2FitB=0
		Checkbox Level2_FitB, value=0
		Checkbox Level2_MassFractal, value=Level2MassFractal
		IR1A_TabPanelControl("bla",1)
		IR1A_UpdateLocalFitsIfSelected()
		IR1A_UpdateMassFractCalc()
		IR1A_UpdatePorodSurface()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level2_Corelations")==0)
		//here we control the data structure checkbox
		//NVAR Level2Corelations=root:Packages:Irena_UnifFit:Level2Corelations
		//Level2Corelations=checked
		//Checkbox Level2_Corelations, value=Level2Corelations
		IR1A_TabPanelControl("bla",1)
		IR1A_UpdateLocalFitsIfSelected()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level2_FitRg")==0)
		//here we control the data structure checkbox
		//NVAR Level2FitRg=root:Packages:Irena_UnifFit:Level2FitRg
		//Level2FitRg=checked
		//Checkbox Level2_FitRg, value=Level2FitRg
		IR1A_TabPanelControl("bla",1)
	endif
	if (cmpstr(ctrlName,"Level2_FitG")==0)
		//here we control the data structure checkbox
		//NVAR Level2FitG=root:Packages:Irena_UnifFit:Level2FitG
		//Level2FitG=checked
		//Checkbox Level2_FitG, value=Level2FitG
		IR1A_TabPanelControl("bla",1)
	endif
	if (cmpstr(ctrlName,"Level2_FitP")==0)
		//here we control the data structure checkbox
		//NVAR Level2FitP=root:Packages:Irena_UnifFit:Level2FitP
		//Level2FitP=checked
		//Checkbox Level2_FitP, value=Level2FitP
		IR1A_TabPanelControl("bla",1)
	endif
	if (cmpstr(ctrlName,"Level2_FitB")==0)
		//here we control the data structure checkbox
		//NVAR Level2FitB=root:Packages:Irena_UnifFit:Level2FitB
		//Level2FitB=checked
		//Checkbox Level2_FitB, value=Level2FitB
		IR1A_TabPanelControl("bla",1)
	endif
	if (cmpstr(ctrlName,"Level2_FitEta")==0)
		//here we control the data structure checkbox
		//NVAR Level2FitEta=root:Packages:Irena_UnifFit:Level2FitEta
		//Level2FitEta=checked
		//Checkbox Level2_FitEta, value=Level2FitEta
		IR1A_TabPanelControl("bla",1)
	endif
	if (cmpstr(ctrlName,"Level2_FitPack")==0)
		//here we control the data structure checkbox
		//NVAR Level2FitPack=root:Packages:Irena_UnifFit:Level2FitPack
		//Level2FitPack=checked
		//Checkbox Level2_FitPack, value=Level2FitPack
		IR1A_TabPanelControl("bla",1)
	endif
	if (cmpstr(ctrlName,"Level2_FitRGCO")==0)
		//here we control the data structure checkbox
		//NVAR Level2FitRGCO=root:Packages:Irena_UnifFit:Level2FitRGCO
		//Level2FitRGCO=checked
		//Checkbox Level2_FitRGCO, value=Level2FitRGCO
		IR1A_TabPanelControl("bla",1)
	endif
	if (cmpstr(ctrlName,"Level2_LinkRGCO")==0)
		//here we control the data structure checkbox
		NVAR Level2LinkRGCO=root:Packages:Irena_UnifFit:Level2LinkRGCO
		NVAR Level2FitRGCO=root:Packages:Irena_UnifFit:Level2FitRGCO
		NVAR Level1Rg=root:Packages:Irena_UnifFit:Level1Rg
		NVAR Level2RGCO=root:Packages:Irena_UnifFit:Level2RGCO
		Level2RGCO=Level1Rg	
		Level2LinkRGCO=checked
		Level2FitRGCO=0
		Checkbox Level2_FitRGCO, value=Level2FitRGCO
		Checkbox Level2_LinkRGCO, value=Level2LinkRGCO
		IR1A_TabPanelControl("bla",1)
		IR1A_AutoUpdateIfSelected()
	endif


//Level3 controls
	if (cmpstr(ctrlName,"Level3_MassFractal")==0)
		//here we control the data structure checkbox
		NVAR Level3MassFractal=root:Packages:Irena_UnifFit:Level3MassFractal
		NVAR Level3FitB=root:Packages:Irena_UnifFit:Level3FitB
		NVAR Level3PHighLimit=root:Packages:Irena_UnifFit:Level3PHighLimit
		NVAR Level3PLowLimit=root:Packages:Irena_UnifFit:Level3PLowLimit
		NVAR Level3P=root:Packages:Irena_UnifFit:Level3P
		NVAR Level3K=root:Packages:Irena_UnifFit:Level3K
		if (checked==1)
			Level3PHighLimit=3
			Level3PLowLimit=1
			Level3P=2
			Level3K=1.06
			PopupMenu Level3_KFactor, mode=2
		else
			Level3PHighLimit=4
			Level3PLowLimit=1
			Level3K=1
			PopupMenu Level3_KFactor, mode=1
		endif
		Level3FitB=0
		Level3MassFractal=checked
		Checkbox Level3_MassFractal, value=Level3MassFractal
		Checkbox Level3_FitB, value=0
		IR1A_TabPanelControl("bla",2)
		IR1A_UpdateLocalFitsIfSelected()
		IR1A_UpdateMassFractCalc()
		IR1A_UpdatePorodSurface()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level3_Corelations")==0)
		//here we control the data structure checkbox
		//NVAR Level3Corelations=root:Packages:Irena_UnifFit:Level3Corelations
		//Level3Corelations=checked
		//Checkbox Level3_Corelations, value=Level3Corelations
		IR1A_TabPanelControl("bla",2)
		IR1A_UpdateLocalFitsIfSelected()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level3_FitRg")==0)
		//here we control the data structure checkbox
		//NVAR Level3FitRg=root:Packages:Irena_UnifFit:Level3FitRg
		//Level3FitRg=checked
		//Checkbox Level3_FitRg, value=Level3FitRg
		IR1A_TabPanelControl("bla",2)
	endif
	if (cmpstr(ctrlName,"Level3_FitG")==0)
		//here we control the data structure checkbox
		//NVAR Level3FitG=root:Packages:Irena_UnifFit:Level3FitG
		//Level3FitG=checked
		//Checkbox Level3_FitG, value=Level3FitG
		IR1A_TabPanelControl("bla",2)
	endif
	if (cmpstr(ctrlName,"Level3_FitP")==0)
		//here we control the data structure checkbox
		//NVAR Level3FitP=root:Packages:Irena_UnifFit:Level3FitP
		//Level3FitP=checked
		//Checkbox Level3_FitP, value=Level3FitP
		IR1A_TabPanelControl("bla",2)
	endif
	if (cmpstr(ctrlName,"Level3_FitB")==0)
		//here we control the data structure checkbox
		//NVAR Level3FitB=root:Packages:Irena_UnifFit:Level3FitB
		//Level3FitB=checked
		//Checkbox Level3_FitB, value=Level3FitB
		IR1A_TabPanelControl("bla",2)
	endif
	if (cmpstr(ctrlName,"Level3_FitEta")==0)
		//here we control the data structure checkbox
		//NVAR Level3FitEta=root:Packages:Irena_UnifFit:Level3FitEta
		//Level3FitEta=checked
		//Checkbox Level3_FitEta, value=Level3FitEta
		IR1A_TabPanelControl("bla",2)
	endif
	if (cmpstr(ctrlName,"Level3_FitPack")==0)
		//here we control the data structure checkbox
		//NVAR Level3FitPack=root:Packages:Irena_UnifFit:Level3FitPack
		//Level3FitPack=checked
		//Checkbox Level3_FitPack, value=Level3FitPack
		IR1A_TabPanelControl("bla",2)
	endif
	if (cmpstr(ctrlName,"Level3_FitRGCO")==0)
		//here we control the data structure checkbox
		//NVAR Level3FitRGCO=root:Packages:Irena_UnifFit:Level3FitRGCO
		//Level3FitRGCO=checked
		//Checkbox Level3_FitRGCO, value=Level3FitRGCO
		IR1A_TabPanelControl("bla",2)
	endif
	if (cmpstr(ctrlName,"Level3_LinkRGCO")==0)
		//here we control the data structure checkbox
		NVAR Level3LinkRGCO=root:Packages:Irena_UnifFit:Level3LinkRGCO
		NVAR Level3FitRGCO=root:Packages:Irena_UnifFit:Level3FitRGCO
		NVAR Level2Rg=root:Packages:Irena_UnifFit:Level2Rg
		NVAR Level3RGCO=root:Packages:Irena_UnifFit:Level3RGCO
		Level3RGCO=Level2Rg	
		Level3LinkRGCO=checked
		Level3FitRGCO=0
		Checkbox Level3_LinkRGCO, value=Level3LinkRGCO
		Checkbox Level3_FitRGCO, value=Level3FitRGCO
		IR1A_TabPanelControl("bla",2)
		IR1A_AutoUpdateIfSelected()
	endif


//Level4 controls
	if (cmpstr(ctrlName,"Level4_MassFractal")==0)
		//here we control the data structure checkbox
		NVAR Level4MassFractal=root:Packages:Irena_UnifFit:Level4MassFractal
		NVAR Level4FitB=root:Packages:Irena_UnifFit:Level4FitB
		NVAR Level4PHighLimit=root:Packages:Irena_UnifFit:Level4PHighLimit
		NVAR Level4PLowLimit=root:Packages:Irena_UnifFit:Level4PLowLimit
		NVAR Level4P=root:Packages:Irena_UnifFit:Level4P
		NVAR Level4K=root:Packages:Irena_UnifFit:Level4K
		if (checked==1)
			Level4PHighLimit=3
			Level4PLowLimit=1
			Level4P=2
			Level4K=1.06
			PopupMenu Level4_KFactor, mode=2
		else
			Level4PHighLimit=4
			Level4PLowLimit=1
			Level4K=1
			PopupMenu Level4_KFactor, mode=1
		endif
		Level4MassFractal=checked
		Level4FitB=0
		Checkbox Level4_FitB, value=0
		Checkbox Level4_MassFractal, value=Level4MassFractal
		IR1A_TabPanelControl("bla",3)
		IR1A_UpdateLocalFitsIfSelected()
		IR1A_UpdateMassFractCalc()
		IR1A_UpdatePorodSurface()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level4_Corelations")==0)
		//here we control the data structure checkbox
		//NVAR Level4Corelations=root:Packages:Irena_UnifFit:Level4Corelations
		//Level4Corelations=checked
		//Checkbox Level4_Corelations, value=Level4Corelations
		IR1A_TabPanelControl("bla",3)
		IR1A_UpdateLocalFitsIfSelected()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level4_FitRg")==0)
		//here we control the data structure checkbox
		//NVAR Level4FitRg=root:Packages:Irena_UnifFit:Level4FitRg
		//Level4FitRg=checked
		//Checkbox Level4_FitRg, value=Level4FitRg
		IR1A_TabPanelControl("bla",3)
	endif
	if (cmpstr(ctrlName,"Level4_FitG")==0)
		//here we control the data structure checkbox
		//NVAR Level4FitG=root:Packages:Irena_UnifFit:Level4FitG
		//Level4FitG=checked
		//Checkbox Level4_FitG, value=Level4FitG
		IR1A_TabPanelControl("bla",3)
	endif
	if (cmpstr(ctrlName,"Level4_FitP")==0)
		//here we control the data structure checkbox
		//NVAR Level4FitP=root:Packages:Irena_UnifFit:Level4FitP
		//Level4FitP=checked
		//Checkbox Level4_FitP, value=Level4FitP
		IR1A_TabPanelControl("bla",3)
	endif
	if (cmpstr(ctrlName,"Level4_FitB")==0)
		//here we control the data structure checkbox
		//NVAR Level4FitB=root:Packages:Irena_UnifFit:Level4FitB
		//Level4FitB=checked
		//Checkbox Level4_FitB, value=Level4FitB
		IR1A_TabPanelControl("bla",3)
	endif
	if (cmpstr(ctrlName,"Level4_FitEta")==0)
		//here we control the data structure checkbox
		//NVAR Level4FitEta=root:Packages:Irena_UnifFit:Level4FitEta
		//Level4FitEta=checked
		//Checkbox Level4_FitEta, value=Level4FitEta
		IR1A_TabPanelControl("bla",3)
	endif
	if (cmpstr(ctrlName,"Level4_FitPack")==0)
		//here we control the data structure checkbox
		//NVAR Level4FitPack=root:Packages:Irena_UnifFit:Level4FitPack
		///Level4FitPack=checked
		//Checkbox Level4_FitPack, value=Level4FitPack
		IR1A_TabPanelControl("bla",3)
	endif
	if (cmpstr(ctrlName,"Level4_FitRGCO")==0)
		//here we control the data structure checkbox
		//NVAR Level4FitRGCO=root:Packages:Irena_UnifFit:Level4FitRGCO
		//Level4FitRGCO=checked
		//Checkbox Level4_FitRGCO, value=Level4FitRGCO
		IR1A_TabPanelControl("bla",3)
	endif
	if (cmpstr(ctrlName,"Level4_LinkRGCO")==0)
		//here we control the data structure checkbox
		NVAR Level4LinkRGCO=root:Packages:Irena_UnifFit:Level4LinkRGCO
		NVAR Level4FitRGCO=root:Packages:Irena_UnifFit:Level4FitRGCO
		NVAR Level3Rg=root:Packages:Irena_UnifFit:Level3Rg
		NVAR Level4RGCO=root:Packages:Irena_UnifFit:Level4RGCO
		Level4RGCO=Level3Rg	
		Level4LinkRGCO=checked
		Level4FitRGCO=0
		Checkbox Level4_LinkRGCO, value=Level4LinkRGCO
		Checkbox Level4_FitRGCO, value=Level4FitRGCO
		IR1A_TabPanelControl("bla",3)
		IR1A_AutoUpdateIfSelected()
	endif

//Level5 controls
	if (cmpstr(ctrlName,"Level5_MassFractal")==0)
		//here we control the data structure checkbox
		NVAR Level5MassFractal=root:Packages:Irena_UnifFit:Level5MassFractal
		NVAR Level5FitB=root:Packages:Irena_UnifFit:Level5FitB
		NVAR Level5PHighLimit=root:Packages:Irena_UnifFit:Level5PHighLimit
		NVAR Level5PLowLimit=root:Packages:Irena_UnifFit:Level5PLowLimit
		NVAR Level5P=root:Packages:Irena_UnifFit:Level5P
		NVAR Level5K=root:Packages:Irena_UnifFit:Level5K
		if (checked==1)
			Level5PHighLimit=3
			Level5PLowLimit=1
			Level5P=2
			Level5K=1.06
			PopupMenu Level5_KFactor, mode=2
		else
			Level5PHighLimit=4
			Level5PLowLimit=1
			Level5K=1
			PopupMenu Level5_KFactor, mode=1
		endif
		Level5FitB=0
		Level5MassFractal=checked
		Checkbox Level5_MassFractal, value=Level5MassFractal
		Checkbox Level5_FitB, value=0
		IR1A_TabPanelControl("bla",4)
		IR1A_UpdateLocalFitsIfSelected()
		IR1A_UpdateMassFractCalc()
		IR1A_UpdatePorodSurface()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level5_Corelations")==0)
		//here we control the data structure checkbox
		//NVAR Level5Corelations=root:Packages:Irena_UnifFit:Level5Corelations
		//Level5Corelations=checked
		//Checkbox Level5_Corelations, value=Level5Corelations
		IR1A_TabPanelControl("bla",4)
		IR1A_UpdateLocalFitsIfSelected()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level5_FitRg")==0)
		//here we control the data structure checkbox
		//NVAR Level5FitRg=root:Packages:Irena_UnifFit:Level5FitRg
		//Level5FitRg=checked
		//Checkbox Level5_FitRg, value=Level5FitRg
		IR1A_TabPanelControl("bla",4)
	endif
	if (cmpstr(ctrlName,"Level5_FitG")==0)
		//here we control the data structure checkbox
		//NVAR Level5FitG=root:Packages:Irena_UnifFit:Level5FitG
		//Level5FitG=checked
		//Checkbox Level5_FitG, value=Level5FitG
		IR1A_TabPanelControl("bla",4)
	endif
	if (cmpstr(ctrlName,"Level5_FitP")==0)
		//here we control the data structure checkbox
		//NVAR Level5FitP=root:Packages:Irena_UnifFit:Level5FitP
		//Level5FitP=checked
		//Checkbox Level5_FitP, value=Level5FitP
		IR1A_TabPanelControl("bla",4)
	endif
	if (cmpstr(ctrlName,"Level5_FitB")==0)
		//here we control the data structure checkbox
		//NVAR Level5FitB=root:Packages:Irena_UnifFit:Level5FitB
		//Level5FitB=checked
		//Checkbox Level5_FitB, value=Level5FitB
		IR1A_TabPanelControl("bla",4)
	endif
	if (cmpstr(ctrlName,"Level5_FitEta")==0)
		//here we control the data structure checkbox
		//NVAR Level5FitEta=root:Packages:Irena_UnifFit:Level5FitEta
		//Level5FitEta=checked
		//Checkbox Level5_FitEta, value=Level5FitEta
		IR1A_TabPanelControl("bla",4)
	endif
	if (cmpstr(ctrlName,"Level5_FitPack")==0)
		//here we control the data structure checkbox
		//NVAR Level5FitPack=root:Packages:Irena_UnifFit:Level5FitPack
		//Level5FitPack=checked
		//Checkbox Level5_FitPack, value=Level5FitPack
		IR1A_TabPanelControl("bla",4)
	endif
	if (cmpstr(ctrlName,"Level5_FitRGCO")==0)
		//here we control the data structure checkbox
		//NVAR Level5FitRGCO=root:Packages:Irena_UnifFit:Level5FitRGCO
		//Level5FitRGCO=checked
		//Checkbox Level5_FitRGCO, value=Level5FitRGCO
		IR1A_TabPanelControl("bla",4)
	endif
	if (cmpstr(ctrlName,"Level5_LinkRGCO")==0)
		//here we control the data structure checkbox
		NVAR Level5LinkRGCO=root:Packages:Irena_UnifFit:Level5LinkRGCO
		NVAR Level5FitRGCO=root:Packages:Irena_UnifFit:Level5FitRGCO
		NVAR Level4Rg=root:Packages:Irena_UnifFit:Level4Rg
		NVAR Level5RGCO=root:Packages:Irena_UnifFit:Level5RGCO
		Level5RGCO=Level4Rg	
		Level5LinkRGCO=checked
		Level5FitRGCO=0
		Checkbox Level5_LinkRGCO, value=Level5LinkRGCO
		Checkbox Level5_FitRGCO, value=Level5FitRGCO
		IR1A_TabPanelControl("bla",4)
		IR1A_AutoUpdateIfSelected()
	endif

end

///********************************************************************************************************
///********************************************************************************************************
///********************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1A_GraphMeasuredData(Package)
	string Package	//tells me, if this is called from Unified or LSQF
	//this function graphs data into the various graphs as needed
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_UnifFit
	SVAR DataFolderName
	SVAR IntensityWaveName
	SVAR QWavename
	SVAR ErrorWaveName
	variable cursorAposition, cursorBposition
	
	//fix for liberal names
	IntensityWaveName = PossiblyQuoteName(IntensityWaveName)
	QWavename = PossiblyQuoteName(QWavename)
	ErrorWaveName = PossiblyQuoteName(ErrorWaveName)
	
	WAVE/Z test=$(DataFolderName+IntensityWaveName)
	if (!WaveExists(test))
		abort "Error in IntensityWaveName wave selection"
	endif
	cursorAposition=0
	cursorBposition=numpnts(test)-1
	WAVE/Z test=$(DataFolderName+QWavename)
	if (!WaveExists(test))
		abort "Error in QWavename wave selection"
	endif
	WAVE/Z test=$(DataFolderName+ErrorWaveName)
	if (!WaveExists(test))
		abort "Error in ErrorWaveName wave selection"
	endif
	Duplicate/O $(DataFolderName+IntensityWaveName), OriginalIntensity
	Duplicate/O $(DataFolderName+QWavename), OriginalQvector
	Duplicate/O $(DataFolderName+ErrorWaveName), OriginalError
	Redimension/D OriginalIntensity, OriginalQvector, OriginalError
	wavestats /Q OriginalQvector
	if(V_min<0)
		OriginalQvector = OriginalQvector[p]<=0 ? NaN : OriginalQvector[p] 
	endif
	IN2G_RemoveNaNsFrom3Waves(OriginalQvector,OriginalIntensity, OriginalError)
	NVAR/Z SubtractBackground=root:Packages:Irena_UnifFit:SubtractBackground
	if(NVAR_Exists(SubtractBackground) && (cmpstr(Package,"Unified")==0))
		OriginalIntensity =OriginalIntensity - SubtractBackground
	endif
//	NVAR/Z UseSlitSmearedData=root:Packages:Irena_UnifFit:UseSlitSmearedData
//	if(NVAR_Exists(UseSlitSmearedData) && (cmpstr(Package,"LSQF")==0))
//		if(UseSlitSmearedData)
//			NVAR SlitLength=root:Packages:Irena_UnifFit:SlitLength
//			variable tempSL=NumberByKey("SlitLength", note(OriginalIntensity) , "=" , ";")
//			if(numtype(tempSL)==0)
//				SlitLength=tempSL
//			endif
//		endif
//	endif
//	 change September 2007
//	current universal package which loads data in does nto care about local setting for useSMRData, but we need to set it acording to wave passed...
	NVAR/Z UseSMRData=root:Packages:Irena_UnifFit:UseSMRData
	if(stringmatch(IntensityWaveName, "*SMR_Int*" ))		// slit smeared data
		UseSMRData=1
		SetVariable SlitLength,win=IR1A_ControlPanel,disable=!UseSMRData
	elseif(stringmatch(IntensityWaveName, "*DSM_Int*" ))	//Indra 2 desmeared data
		UseSMRData=0
		SetVariable SlitLength,win=IR1A_ControlPanel,disable=!UseSMRData
	else
			//we have no clue what user input, leave it to him to deal with slit smearing
	endif

	if(NVAR_Exists(UseSMRData) && (cmpstr(Package,"Unified")==0))
		if(UseSMRData)
			NVAR SlitLengthUnif=root:Packages:Irena_UnifFit:SlitLengthUnif
			variable tempSL1=NumberByKey("SlitLength", note(OriginalIntensity) , "=" , ";")
			if(numtype(tempSL1)==0)
				SlitLengthUnif=tempSL1
			endif
		endif
	endif
	
	
	if (cmpstr(Package,"Unified")==0)		//called from unified
		DoWindow IR1_LogLogPlotU
		if (V_flag)
			Dowindow/K IR1_LogLogPlotU
		endif
		Execute ("IR1_LogLogPlotU()")
//	elseif (cmpstr(Package,"LSQF")==0)
//		DoWindow IR1_LogLogPlotLSQF
//		if (V_flag)
//			cursorAposition=pcsr(A,"IR1_LogLogPlotLSQF")
//			cursorBposition=pcsr(B,"IR1_LogLogPlotLSQF")
//			Dowindow/K IR1_LogLogPlotLSQF
//		endif
//		Execute ("IR1_LogLogPlotLSQF()")
//		cursor/P/W=IR1_LogLogPlotLSQF A, OriginalIntensity,cursorAposition
//		cursor/P/W=IR1_LogLogPlotLSQF B, OriginalIntensity,cursorBposition
	endif
	
	Duplicate/O $(DataFolderName+IntensityWaveName), OriginalIntQ4
	Duplicate/O $(DataFolderName+QWavename), OriginalQ4
	Duplicate/O $(DataFolderName+ErrorWaveName), OriginalErrQ4
	Redimension/D OriginalIntQ4, OriginalQ4, OriginalErrQ4
	wavestats /Q OriginalQ4
	if(V_min<0)
		OriginalQ4 = OriginalQ4[p]<=0 ? NaN : OriginalQ4[p] 
	endif
	IN2G_RemoveNaNsFrom3Waves(OriginalQ4,OriginalIntQ4, OriginalErrQ4)

	if(NVAR_Exists(SubtractBackground) && (cmpstr(Package,"Unified")==0))
		OriginalIntQ4 =OriginalIntQ4 - SubtractBackground
	endif
	
	OriginalQ4=OriginalQ4^4
	OriginalIntQ4=OriginalIntQ4*OriginalQ4
	OriginalErrQ4=OriginalErrQ4*OriginalQ4

	if (cmpstr(Package,"Unified")==0)		//called from unified
		DoWindow IR1_IQ4_Q_PlotU
		if (V_flag)
			Dowindow/K IR1_IQ4_Q_PlotU
		endif
		Execute ("IR1_IQ4_Q_PlotU()")
	elseif (cmpstr(Package,"LSQF")==0)
		DoWindow IR1_IQ4_Q_PlotLSQF
		if (V_flag)
			Dowindow/K IR1_IQ4_Q_PlotLSQF
		endif
		Execute ("IR1_IQ4_Q_PlotLSQF()")
	endif
	setDataFolder oldDf
end


//*****************************************************************************************************************
//*****************************************************************************************************************

Proc  IR1_IQ4_Q_PlotU() 
	PauseUpdate; Silent 1		// building window...
	String fldrSav= GetDataFolder(1)
	SetDataFolder root:Packages:Irena_UnifFit:
	Display /W=(283.5,228.5,761.25,383)/K=1  OriginalIntQ4 vs OriginalQvector as "IQ4_Q_Plot"
	DoWindow/C IR1_IQ4_Q_PlotU
	ModifyGraph mode(OriginalIntQ4)=3
	ModifyGraph msize(OriginalIntQ4)=1
	ModifyGraph log=1
	ModifyGraph mirror=1
	Label left "Intensity * Q^4"
	Label bottom "Q [A\\S-1\\M]"
	ErrorBars/Y=1 OriginalIntQ4 Y,wave=(OriginalErrQ4,OriginalErrQ4)
	TextBox/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	TextBox/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z07"+DataFolderName+IntensityWaveName	
	//and now some controls
	SetDataFolder fldrSav
EndMacro
//*****************************************************************************************************************
//*****************************************************************************************************************
Proc  IR1_LogLogPlotU() 
	PauseUpdate; Silent 1		// building window...
	String fldrSav= GetDataFolder(1)
	SetDataFolder root:Packages:Irena_UnifFit:
	Display /W=(282.75,37.25,759.75,208.25)/K=1  OriginalIntensity vs OriginalQvector as "LogLogPlot"
	DoWindow/C IR1_LogLogPlotU
	ModifyGraph mode(OriginalIntensity)=3
	ModifyGraph msize(OriginalIntensity)=1
	ModifyGraph log=1
	ModifyGraph mirror=1
	ShowInfo
	String LabelStr= "\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"Intensity [cm\\S-1\\M\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"]"
	Label left LabelStr
	LabelStr= "\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"Q [A\\S-1\\M\\Z"+IR2C_LkUpDfltVar("AxisLabelSize")+"]"
	Label bottom LabelStr
	string LegendStr="\\F"+IR2C_LkUpDfltStr("FontType")+"\\Z"+IR2C_LkUpDfltVar("LegendSize")+"\\s(OriginalIntensity) Experimental intensity"
	Legend/W=IR1_LogLogPlotU/N=text0/J/F=0/A=MC/X=32.03/Y=38.79 LegendStr
	//
	ErrorBars/Y=1 OriginalIntensity Y,wave=(OriginalError,OriginalError)
	//and now some controls
	TextBox/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	TextBox/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z07"+DataFolderName+IntensityWaveName	
	SetDataFolder fldrSav
EndMacro
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
///********************************************************************************************************
///********************************************************************************************************

Function IR1A_InputPanelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_UnifFit
	

	if (cmpstr(ctrlName,"DrawGraphs")==0 || cmpstr(ctrlName,"DrawGraphsSkipDialogs")==0)
		//here goes what is done, when user pushes Graph button
		SVAR DFloc=root:Packages:Irena_UnifFit:DataFolderName
		SVAR DFInt=root:Packages:Irena_UnifFit:IntensityWaveName
		SVAR DFQ=root:Packages:Irena_UnifFit:QWaveName
		SVAR DFE=root:Packages:Irena_UnifFit:ErrorWaveName
		variable IsAllAllRight=1
		if (cmpstr(DFloc,"---")==0)
			IsAllAllRight=0
		endif
		if (cmpstr(DFInt,"---")==0)
			IsAllAllRight=0
		endif
		if (cmpstr(DFQ,"---")==0)
			IsAllAllRight=0
		endif
		if (cmpstr(DFE,"---")==0)
			IsAllAllRight=0
		endif
		
		if (IsAllAllRight)
			if(cmpstr(ctrlName,"DrawGraphsSkipDialogs")!=0)
				variable recovered = IR1A_RecoverOldParameters()	//recovers old parameters and returns 1 if done so...
			endif
			IR1A_FixTabsInPanel()
			IR1A_GraphMeasuredData("Unified")
			NVAR ActiveTab=root:Packages:Irena_UnifFit:ActiveTab
			IR1A_DisplayLocalFits(ActiveTab,0)
			IR1A_AutoUpdateIfSelected()
			MoveWindow /W=IR1_LogLogPlotU 285,37,760,337
			MoveWindow /W=IR1_IQ4_Q_PlotU 285,360,760,600
			AutoPositionWIndow /M=0  /R=IR1A_ControlPanel IR1_LogLogPlotU
			AutoPositionWIndow /M=1  /R=IR1_LogLogPlotU IR1_IQ4_Q_PlotU
			if (recovered)
				IR1A_GraphModelData()		//graph the data here, all parameters should be defined
			endif
		else
			Abort "Data not selected properly"
		endif
	endif

	if(cmpstr(ctrlName,"DoFitting")==0 || cmpstr(ctrlName,"DoFittingSkipReset")==0)
		//here we call the fitting routine
		variable skipreset=0
		if(cmpstr(ctrlName,"DoFittingSkipReset")==0)
			skipreset = 1
		endif
		IR1A_ConstructTheFittingCommand(skipreset)
		IR1A_UpdateMassFractCalc()
		IR1A_UpdatePorodSurface()
		IR1A_GraphFitData()
	endif
	if(cmpstr(ctrlName,"RevertFitting")==0)
		//here we call the fitting routine
		IR1A_ResetParamsAfterBadFit()
		IR1A_UpdateMassFractCalc()
		IR1A_UpdatePorodSurface()
		IR1A_GraphModelData()
	endif
	if(cmpstr(ctrlName,"GraphDistribution")==0)
		//here we graph the distribution
		IR1A_GraphModelData()
	endif
	if(cmpstr(ctrlName,"ResetUnified")==0)
		//here we graph the distribution
		IR1A_ResetUnified()
	endif
	if(cmpstr(ctrlName,"EvaluateSpecialCases")==0)
		//here we graph the distribution
		IR2U_EvaluateUnifiedData()
	endif
	
	if(cmpstr(ctrlName,"CopyToFolder")==0 || cmpstr(ctrlName,"CopyTFolderNoQuestions")==0)
		//here we copy final data back to original data folder	
		IR1A_UpdateLocalFitsForOutput()		//create local fits 	I	
		if(cmpstr(ctrlName,"CopyTFolderNoQuestions")==0)
			IR1A_CopyDataBackToFolder("user", SaveMe="yes")
		else
			IR1A_CopyDataBackToFolder("user")
		endif
		IR1A_SaveRecordResults()
	//	DoAlert 0,"Copy"
	endif	
	if(cmpstr(ctrlName,"MarkGraphs")==0)
		//here we copy final data back to original data folder		I	
		IR1A_InsertResultsIntoGraphs()
	//	DoAlert 0,"Copy"
	endif
	
	if(cmpstr(ctrlName,"ExportData")==0)
		//here we export ASCII form of the data
		IR1A_ExportASCIIResults()
	//	DoAlert 0, "Export"
	endif
	
	if(cmpstr(ctrlName,"Level1_FitRgAndG")==0)
		//here we fit Rg and G area - Guiner fit level 1
		IR1A_FitLocalGuinier(1)
		IR1A_GraphModelData()
	endif

	if(cmpstr(ctrlName,"Level1_FitPAndB")==0)
		//here we fit P and B area - Porod fit level 1
		IR1A_FitLocalPorod(1)
		IR1A_GraphModelData()
	endif
	if(cmpstr(ctrlName,"Level2_FitRgAndG")==0)
		//here we fit Rg and G area - Guiner fit level 2
		IR1A_FitLocalGuinier(2)
		IR1A_GraphModelData()
	endif

	if(cmpstr(ctrlName,"Level2_FitPAndB")==0)
		//here we fit P and B area - Porod fit level 2
		IR1A_FitLocalPorod(2)
		IR1A_GraphModelData()
	endif
	if(cmpstr(ctrlName,"Level3_FitRgAndG")==0)
		//here we fit Rg and G area - Guiner fit level 3
		IR1A_FitLocalGuinier(3)
		IR1A_GraphModelData()
	endif

	if(cmpstr(ctrlName,"Level3_FitPAndB")==0)
		//here we fit P and B area - Porod fit level 3
		IR1A_FitLocalPorod(3)
		IR1A_GraphModelData()
	endif
	if(cmpstr(ctrlName,"Level4_FitRgAndG")==0)
		//here we fit Rg and G area - Guiner fit level 4
		IR1A_FitLocalGuinier(4)
		IR1A_GraphModelData()
	endif

	if(cmpstr(ctrlName,"Level4_FitPAndB")==0)
		//here we fit P and B area - Porod fit level 4
		IR1A_FitLocalPorod(4)
		IR1A_GraphModelData()
	endif
	if(cmpstr(ctrlName,"Level5_FitRgAndG")==0)
		//here we fit Rg and G area - Guiner fit level 5
		IR1A_FitLocalGuinier(5)
		IR1A_GraphModelData()
	endif

	if(cmpstr(ctrlName,"Level5_FitPAndB")==0)
		//here we fit P and B area - Porod fit level 5
		IR1A_FitLocalPorod(5)
		IR1A_GraphModelData()
	endif
	if(cmpstr(ctrlName,"Level1_SetRGCODefault")==0)
		//set RGCO default
		NVAR Level1RGCO=root:Packages:Irena_UnifFit:Level1RGCO
		//NVAR Level0Rg=root:Packages:Irena_UnifFit:Level0Rg
		Level1RGCO=0
		//Level1RGCO=Level0Rg
	endif
	if(cmpstr(ctrlName,"Level2_SetRGCODefault")==0)
		//set RGCO default
		NVAR Level2RGCO=root:Packages:Irena_UnifFit:Level2RGCO
		NVAR Level1Rg=root:Packages:Irena_UnifFit:Level1Rg
		Level2RGCO=Level1Rg
		IR1A_AutoUpdateIfSelected()
	endif
	if(cmpstr(ctrlName,"Level3_SetRGCODefault")==0)
		//set RGCO default
		NVAR Level3RGCO=root:Packages:Irena_UnifFit:Level3RGCO
		NVAR Level2Rg=root:Packages:Irena_UnifFit:Level2Rg
		Level3RGCO=Level2Rg
		IR1A_AutoUpdateIfSelected()
	endif
	if(cmpstr(ctrlName,"Level4_SetRGCODefault")==0)
		//set RGCO default
		NVAR Level4RGCO=root:Packages:Irena_UnifFit:Level4RGCO
		NVAR Level3Rg=root:Packages:Irena_UnifFit:Level3Rg
		Level4RGCO=Level3Rg
		IR1A_AutoUpdateIfSelected()
	endif
	if(cmpstr(ctrlName,"Level5_SetRGCODefault")==0)
		//set RGCO default
		NVAR Level5RGCO=root:Packages:Irena_UnifFit:Level5RGCO
		NVAR Level4Rg=root:Packages:Irena_UnifFit:Level4Rg
		Level5RGCO=Level4Rg
		IR1A_AutoUpdateIfSelected()
	endif

	DoWIndow/F IR1A_ControlPanel
	DoWIndow UnifiedEvaluationPanel
	if(V_Flag)
		AutoPositionWindow/M=0 /R=IR1A_ControlPanel UnifiedEvaluationPanel
	endif
	
	setDataFolder oldDF
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


Function IR1A_PanelPopupControl(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_UnifFit
		NVAR UseIndra2Data=root:Packages:Irena_UnifFit:UseIndra2Data
		NVAR UseQRSData=root:Packages:Irena_UnifFit:UseQRSdata
		NVAR UseSMRData=root:Packages:Irena_UnifFit:UseSMRData
		SVAR IntDf=root:Packages:Irena_UnifFit:IntensityWaveName
		SVAR QDf=root:Packages:Irena_UnifFit:QWaveName
		SVAR EDf=root:Packages:Irena_UnifFit:ErrorWaveName
		SVAR Dtf=root:Packages:Irena_UnifFit:DataFolderName

	if (cmpstr(ctrlName,"SelectDataFolder")==0)
		//here we do what needs to be done when we select data folder
		Dtf=popStr
		PopupMenu IntensityDataName mode=1
		PopupMenu QvecDataName mode=1
		PopupMenu ErrorDataName mode=1
		if (UseIndra2Data)
//			if(stringmatch(IR1_ListOfWaves("DSM_Int","Irena_UnifFit",0), "*M_BKG_Int*") &&stringmatch(IR1_ListOfWaves("DSM_Qvec","Irena_UnifFit",0), "*M_BKG_Qvec*")  &&stringmatch(IR1_ListOfWaves("DSM_Error","Irena_UnifFit",0), "*M_BKG_Error*") )			
//				IntDf="M_BKG_Int"
//				QDf="M_BKG_Qvec"
//				EDf="M_BKG_Error"
//				PopupMenu IntensityDataName value="M_BKG_Int;M_DSM_Int;DSM_Int"
//				PopupMenu QvecDataName value="M_BKG_Qvec;M_DSM_Qvec;DSM_Qvec"
//				PopupMenu ErrorDataName value="M_BKG_Error;M_DSM_Error;DCM_Error"
//			elseif(stringmatch(IR1_ListOfWaves("DSM_Int","Irena_UnifFit",0), "*BKG_Int*") &&stringmatch(IR1_ListOfWaves("DSM_Qvec","Irena_UnifFit",0), "*BKG_Qvec*")  &&stringmatch(IR1_ListOfWaves("DSM_Error","Irena_UnifFit",0), "*BKG_Error*") )			
//				IntDf="BKG_Int"
//				QDf="BKG_Qvec"
//				EDf="BKG_Error"
//				PopupMenu IntensityDataName value="BKG_Int;DSM_Int"
//				PopupMenu QvecDataName value="BKG_Qvec;DSM_Qvec"
//				PopupMenu ErrorDataName value="BKG_Error;DCM_Error"
//			elseif(stringmatch(IR1_ListOfWaves("DSM_Int","Irena_UnifFit",0), "*M_DSM_Int*") &&stringmatch(IR1_ListOfWaves("DSM_Qvec","Irena_UnifFit",0), "*M_DSM_Qvec*")  &&stringmatch(IR1_ListOfWaves("DSM_Error","Irena_UnifFit",0), "*M_DSM_Error*") )			
//				IntDf="M_DSM_Int"
//				QDf="M_DSM_Qvec"
//				EDf="M_DSM_Error"
//				PopupMenu IntensityDataName value="M_DSM_Int;DSM_Int"
//				PopupMenu QvecDataName value="M_DSM_Qvec;DSM_Qvec"
//				PopupMenu ErrorDataName value="M_DSM_Error;DCM_Error"
//			else
//				if(!stringmatch(IR1_ListOfWaves("DSM_Int","Irena_UnifFit",0), "*M_DSM_Int*") &&!stringmatch(IR1_ListOfWaves("DSM_Qvec","Irena_UnifFit",0), "*M_DSM_Qvec*")  &&!stringmatch(IR1_ListOfWaves("DSM_Error","Irena_UnifFit",0), "*M_DSM_Error*") )			
//					IntDf="DSM_Int"
//					QDf="DSM_Qvec"
//					EDf="DSM_Error"
//					PopupMenu IntensityDataName value="DSM_Int"
//					PopupMenu QvecDataName value="DSM_Qvec"
//					PopupMenu ErrorDataName value="DSM_Error"
//				endif
//			endif
			IntDf=stringFromList(0,IR1_ListIndraWavesForPopups("DSM_Int","Irena_UnifFit",(-1)*UseSMRData,1))
			QDf=stringFromList(0,IR1_ListIndraWavesForPopups("DSM_Qvec","Irena_UnifFit",(-1)*UseSMRData,1))
			EDf=stringFromList(0,IR1_ListIndraWavesForPopups("DSM_Error","Irena_UnifFit",(-1)*UseSMRData,1))
			Execute("PopupMenu IntensityDataName value=IR1_ListIndraWavesForPopups(\"DSM_Int\",\"Irena_UnifFit\",(-1)*root:Packages:Irena_UnifFit:UseSMRData,1)")
			Execute("PopupMenu QvecDataName value=IR1_ListIndraWavesForPopups(\"DSM_Qvec\",\"Irena_UnifFit\",(-1)*root:Packages:Irena_UnifFit:UseSMRData,1)")
			Execute("PopupMenu ErrorDataName value=IR1_ListIndraWavesForPopups(\"DSM_Error\",\"Irena_UnifFit\",(-1)*root:Packages:Irena_UnifFit:UseSMRData,1)")
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
			PopupMenu IntensityDataName  value="---;"+IR1_ListOfWaves("DSM_Int","Irena_UnifFit",0,0)
			PopupMenu QvecDataName  value="---;"+IR1_ListOfWaves("DSM_Qvec","Irena_UnifFit",0,0)
			PopupMenu ErrorDataName  value="---;"+IR1_ListOfWaves("DSM_Error","Irena_UnifFit",0,0)
		endif
		if(!UseQRSdata && !UseIndra2Data)
			IntDf=""
			QDf=""
			EDf=""
			PopupMenu IntensityDataName  value="---;"+IR1_ListOfWaves("DSM_Int","Irena_UnifFit",0,0)
			PopupMenu QvecDataName  value="---;"+IR1_ListOfWaves("DSM_Qvec","Irena_UnifFit",0,0)
			PopupMenu ErrorDataName  value="---;"+IR1_ListOfWaves("DSM_Error","Irena_UnifFit",0,0)
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
	
	if (cmpstr(ctrlName,"IntensityDataName")==0)
		//here goes what needs to be done, when we select this popup...
		if (cmpstr(popStr,"---")!=0)
			IntDf=popStr
			if (UseQRSData && strlen(QDf)==0 && strlen(EDf)==0)
				QDf="q"+popStr[1,inf]
				EDf="s"+popStr[1,inf]
				Execute ("PopupMenu QvecDataName mode=1, value=root:Packages:Irena_UnifFit:QWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Qvec\",\"Irena_UnifFit\",0,0)")
				Execute ("PopupMenu ErrorDataName mode=1, value=root:Packages:Irena_UnifFit:ErrorWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Error\",\"Irena_UnifFit\",0,0)")
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
				Execute ("PopupMenu IntensityDataName mode=1, value=root:Packages:Irena_UnifFit:IntensityWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Int\",\"Irena_UnifFit\",0,0)")
				Execute ("PopupMenu ErrorDataName mode=1, value=root:Packages:Irena_UnifFit:ErrorWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Error\",\"Irena_UnifFit\",0,0)")
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
				Execute ("PopupMenu IntensityDataName mode=1, value=root:Packages:Irena_UnifFit:IntensityWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Int\",\"Irena_UnifFit\",0,0)")
				Execute ("PopupMenu QvecDataName mode=1, value=root:Packages:Irena_UnifFit:QWaveName+\";---;\"+IR1_ListOfWaves(\"DSM_Qvec\",\"Irena_UnifFit\",0,0)")
			endif
		else
			EDf=""
		endif
	endif
	
	if (cmpstr(ctrlName,"NumberOfLevels")==0)
		//here goes what happens when we change number of distributions
		NVAR nmbdist=root:Packages:Irena_UnifFit:NumberOfLevels
		nmbdist=popNum-1
		IR1A_FixTabsInPanel()
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level1_KFactor")==0)
		NVAR Level1K=root:Packages:Irena_UnifFit:Level1K
		Level1K=str2num(popStr)
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level2_KFactor")==0)
		NVAR Level2K=root:Packages:Irena_UnifFit:Level2K
		Level2K=str2num(popStr)
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level3_KFactor")==0)
		NVAR Level3K=root:Packages:Irena_UnifFit:Level3K
		Level3K=str2num(popStr)
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level4_KFactor")==0)
		NVAR Level4K=root:Packages:Irena_UnifFit:Level4K
		Level4K=str2num(popStr)
		IR1A_AutoUpdateIfSelected()
	endif
	if (cmpstr(ctrlName,"Level5_KFactor")==0)
		NVAR Level5K=root:Packages:Irena_UnifFit:Level5K
		Level5K=str2num(popStr)
		IR1A_AutoUpdateIfSelected()
	endif
	
	
	setDataFolder oldDF

End

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


Function IR1A_AutoUpdateIfSelected()
	
	NVAR UpdateAutomatically=root:Packages:Irena_UnifFit:UpdateAutomatically
	if (UpdateAutomatically)
		IR1A_GraphModelData()
		NVAR ActTab=root:Packages:Irena_UnifFit:ActiveTab
		IR1A_DisplayLocalFits(ActTab, 0)
	endif
end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


Function IR1A_FixTabsInPanel()
	//here we modify the panel, so it reflects the selected number of distributions
	
	NVAR NumOfDist=root:Packages:Irena_UnifFit:NumberOfLevels
	
	
	//and now return us back to original tab...
	NVAR ActTab=root:Packages:Irena_UnifFit:ActiveTab
	IR1A_TabPanelControl("bla",ActTab-1)
	variable SetToTab
	SetToTab=ActTab-1
	if(SetToTab<0)
		SetToTab=0
	endif
	TabControl DistTabs,value= SetToTab, win=IR1A_ControlPanel
	IR1A_TabPanelControl("bla",SetToTab)
end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


Function IR1A_GraphModelData()

		IR1A_UnifiedCalculateIntensity()
		//now calculate the normalized error wave
		IR1A_CalculateNormalizedError("graph")
		//append waves to the two top graphs with measured data
		IR1A_AppendModelToMeasuredData()	//modified for 5		
		ControlInfo/W=IR1A_ControlPanel DistTabs
		IR1A_DisplayLocalFits(V_Value+1,0)
end
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


Function IR1A_GraphFitData()

		IR1A_UnifiedCalculateIntensity()
		//now calculate the normalized error wave
		IR1A_CalculateNormalizedError("fit")
		//append waves to the two top graphs with measured data
		IR1A_AppendModelToMeasuredData()	//modified for 5		
end
	

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


Function IR1A_AppendModelToMeasuredData()
	//here we need to append waves with calculated intensities to the measured data

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_UnifFit
	
	Wave Intensity=root:Packages:Irena_UnifFit:UnifiedFitIntensity
	Wave QVec=root:Packages:Irena_UnifFit:UnifiedFitQvector
	Wave IQ4=root:Packages:Irena_UnifFit:UnifiedIQ4
	Wave/Z NormalizedError=root:Packages:Irena_UnifFit:NormalizedError
	Wave/Z NormErrorQvec=root:Packages:Irena_UnifFit:NormErrorQvec
	
	DoWindow/F IR1_LogLogPlotU
	variable CsrAPos
	if (strlen(CsrWave(A))!=0)
		CsrAPos=pcsr(A)
	else
		CsrAPos=0
	endif
	variable CsrBPos
	if (strlen(CsrWave(B))!=0)
		CsrBPos=pcsr(B)
	else
		CsrBPos=numpnts(Intensity)-1
	endif
	
	DoWIndow IR1_LogLogPlotU
	if (!V_Flag)
		abort
	endif
	DoWIndow IR1_IQ4_Q_PlotU
	if (!V_Flag)
		abort
	endif
	SVAR Folder=root:Packages:Irena_UnifFit:DataFolderName
	SVAR WvName=root:Packages:Irena_UnifFit:IntensityWaveName
	RemoveFromGraph /Z/W=IR1_LogLogPlotU UnifiedFitIntensity 
	RemoveFromGraph /Z/W=IR1_LogLogPlotU NormalizedError 
	RemoveFromGraph /Z/W=IR1_IQ4_Q_PlotU UnifiedIQ4 

	AppendToGraph/W=IR1_LogLogPlotU Intensity vs Qvec
	cursor/P/W=IR1_LogLogPlotU A, OriginalIntensity, CsrAPos	
	cursor/P/W=IR1_LogLogPlotU B, OriginalIntensity, CsrBPos	
	ModifyGraph/W=IR1_LogLogPlotU rgb(UnifiedFitIntensity)=(0,0,0)
	ModifyGraph/W=IR1_LogLogPlotU mode(OriginalIntensity)=3
	ModifyGraph/W=IR1_LogLogPlotU msize(OriginalIntensity)=1
	ShowInfo/W=IR1_LogLogPlotU
	TextBox/W=IR1_LogLogPlotU/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	TextBox/W=IR1_LogLogPlotU/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z07"+Folder+WvName	
	if (WaveExists(NormalizedError))
		AppendToGraph/R/W=IR1_LogLogPlotU NormalizedError vs NormErrorQvec
		ModifyGraph/W=IR1_LogLogPlotU  mode(NormalizedError)=3,marker(NormalizedError)=8
		ModifyGraph/W=IR1_LogLogPlotU zero(right)=4
		ModifyGraph/W=IR1_LogLogPlotU msize(NormalizedError)=1,rgb(NormalizedError)=(0,0,0)
		SetAxis/W=IR1_LogLogPlotU /A/E=2 right
		ModifyGraph/W=IR1_LogLogPlotU log(right)=0
		Label/W=IR1_LogLogPlotU right "Standardized residual"
	else
		ModifyGraph/W=IR1_LogLogPlotU mirror(left)=1
	endif
	ModifyGraph/W=IR1_LogLogPlotU log(left)=1
	ModifyGraph/W=IR1_LogLogPlotU log(bottom)=1
	ModifyGraph/W=IR1_LogLogPlotU mirror(bottom)=1
	Label/W=IR1_LogLogPlotU left "Intensity [cm\\S-1\\M]"
	Label/W=IR1_LogLogPlotU bottom "Q [A\\S-1\\M]"
	ErrorBars/Y=1/W=IR1_LogLogPlotU OriginalIntensity Y,wave=(root:Packages:Irena_UnifFit:OriginalError,root:Packages:Irena_UnifFit:OriginalError)
	Legend/W=IR1_LogLogPlotU/N=text0/K
	Legend/W=IR1_LogLogPlotU/N=text0/J/F=0/A=MC/X=32.03/Y=38.79 "\\F"+IR2C_LkUpDfltStr("FontType")+"\\Z"+IR2C_LkUpDfltVar("LegendSize")+Folder+WvName+"\r"+"\\s(OriginalIntensity) Experimental intensity"
	AppendText/W=IR1_LogLogPlotU "\\s(UnifiedFitIntensity) Unified calculated Intensity"
	if (WaveExists(NormalizedError))
		AppendText/W=IR1_LogLogPlotU "\\s(NormalizedError) Standardized residual"
	endif
	ModifyGraph/W=IR1_LogLogPlotU rgb(OriginalIntensity)=(0,0,0),lstyle(UnifiedFitIntensity)=0
	ModifyGraph/W=IR1_LogLogPlotU rgb(UnifiedFitIntensity)=(65280,0,0)

	AppendToGraph/W=IR1_IQ4_Q_PlotU IQ4 vs Qvec
	ModifyGraph/W=IR1_IQ4_Q_PlotU rgb(UnifiedIQ4)=(65280,0,0)
	ModifyGraph/W=IR1_IQ4_Q_PlotU mode=3
	ModifyGraph/W=IR1_IQ4_Q_PlotU msize=1
	ModifyGraph/W=IR1_IQ4_Q_PlotU log=1
	ModifyGraph/W=IR1_IQ4_Q_PlotU mirror=1
	ModifyGraph/W=IR1_IQ4_Q_PlotU mode(UnifiedIQ4)=0
	TextBox/W=IR1_IQ4_Q_PlotU/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	TextBox/W=IR1_IQ4_Q_PlotU/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z07"+Folder+WvName	
	Label/W=IR1_IQ4_Q_PlotU left "Intensity * Q^4"
	Label/W=IR1_IQ4_Q_PlotU bottom "Q [A\\S-1\\M]"
	ErrorBars/Y=1/W=IR1_IQ4_Q_PlotU OriginalIntQ4 Y,wave=(root:Packages:Irena_UnifFit:OriginalErrQ4,root:Packages:Irena_UnifFit:OriginalErrQ4)
	Legend/W=IR1_IQ4_Q_PlotU/N=text0/K
	Legend/W=IR1_IQ4_Q_PlotU/N=text0/J/F=0/A=MC/X=-29.74/Y=37.76 "\\F"+IR2C_LkUpDfltStr("FontType")+"\\Z"+IR2C_LkUpDfltVar("LegendSize")+Folder+WvName+"\r"+"\\s(OriginalIntQ4) Experimental intensity * Q^4"
	AppendText/W=IR1_IQ4_Q_PlotU "\\s(UnifiedIQ4) Unified Calculated intensity * Q^4"
	ModifyGraph/W=IR1_IQ4_Q_PlotU rgb(OriginalIntq4)=(0,0,0)
	setDataFolder oldDF

end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

	
Function	IR1A_CalculateNormalizedError(CalledWhere)
		string CalledWhere	// "fit" or "graph"

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_UnifFit
		if (cmpstr(CalledWhere,"fit")==0)
			Wave/Z ExpInt=root:Packages:Irena_UnifFit:FitIntensityWave
			if (WaveExists(ExpInt))
				Wave ExpError=root:Packages:Irena_UnifFit:FitErrorWave
				Wave FitIntCalc=root:Packages:Irena_UnifFit:UnifiedFitIntensity
				Wave FitIntQvec=root:Packages:Irena_UnifFit:UnifiedFitQvector
				Wave FitQvec=root:Packages:Irena_UnifFit:FitQvectorWave
				variable mystart=binarysearch(FitIntQvec,FitQvec[0])
				variable myend=binarysearch(FitIntQvec,FitQvec[numpnts(FitQvec)-1])
				Duplicate/O/R=[mystart,myend] FitIntCalc, FitInt
				Wave FitInt
				Duplicate /O ExpInt, NormalizedError
				Duplicate/O FitQvec, NormErrorQvec
				NormalizedError=(ExpInt-FitInt)/ExpError
				KillWaves FitInt
			endif
		endif
		if (cmpstr(CalledWhere,"graph")==0)
			Wave ExpInt=root:Packages:Irena_UnifFit:OriginalIntensity
			Wave ExpError=root:Packages:Irena_UnifFit:OriginalError
			Wave FitInt=root:Packages:Irena_UnifFit:UnifiedFitIntensity
			Wave OrgQvec=root:Packages:Irena_UnifFit:OriginalQvector
			Duplicate/O OrgQvec, NormErrorQvec
			Duplicate/O FitInt, NormalizedError
			NormalizedError=(ExpInt-FitInt)/ExpError
		endif	
	setDataFolder oldDf
end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


Function IR1A_InsertResultsIntoGraphs()
	
	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels
	variable i
	for(i=1;i<=NumberOfLevels;i+=1)	
		IR1A_InsertOneLevelResInGrph(i)
	endfor											
end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


Function IR1A_InsertOneLevelResInGrph(Lnmb)
	variable Lnmb
	
	setDataFolder root:Packages:Irena_UnifFit

	NVAR SASBackgroundError=$("SASBackgroundError")
	NVAR SASBackground=$("SASBackground")
	NVAR RgError=$("Level"+num2str(Lnmb)+"RgError")
	NVAR GError=$("Level"+num2str(Lnmb)+"GError")
	NVAR PError=$("Level"+num2str(Lnmb)+"PError")
	NVAR BError=$("Level"+num2str(Lnmb)+"BError")
	NVAR ETAError=$("Level"+num2str(Lnmb)+"ETAError")
	NVAR PACKError=$("Level"+num2str(Lnmb)+"PACKError")
	NVAR RGCOError=$("Level"+num2str(Lnmb)+"RGCOError")
	NVAR Rg=$("Level"+num2str(Lnmb)+"Rg")
	NVAR G=$("Level"+num2str(Lnmb)+"G")
	NVAR P=$("Level"+num2str(Lnmb)+"P")
	NVAR B=$("Level"+num2str(Lnmb)+"B")
	NVAR K=$("Level"+num2str(Lnmb)+"K")
	NVAR ETA=$("Level"+num2str(Lnmb)+"ETA")
	NVAR PACK=$("Level"+num2str(Lnmb)+"PACK")
	NVAR RGCO=$("Level"+num2str(Lnmb)+"RGCO")
	NVAR LinkRGCO=$("Level"+num2str(Lnmb)+"LinkRGCO")
	NVAR Corelations=$("Level"+num2str(Lnmb)+"Corelations")
	NVAR MassFractal=$("Level"+num2str(Lnmb)+"MassFractal")
	NVAR SurfaceToVolume=$("Level"+num2str(Lnmb)+"SurfaceToVolRat")
	NVAR Invariant=$("Level"+num2str(Lnmb)+"Invariant")

	string LogLogTag, IQ4Tag, tagname
	tagname="Level"+num2str(Lnmb)+"Tag"
	Wave OriginalQvector
		
	variable QtoAttach=2/Rg
	variable AttachPointNum=binarysearch(OriginalQvector,QtoAttach)
	
	LogLogTag="\\F"+IR2C_LkUpDfltStr("FontType")+"\\Z"+IR2C_LkUpDfltVar("LegendSize")+"Unified Fit for level "+num2str(Lnmb)+"\r"
	if (GError>0)
		LogLogTag+="G = "+num2str(G)+"  \t"+num2str(GError)+"\r"
	else
		LogLogTag+="G = "+num2str(G)+"  \t 0 "+"\r"	
	endif
	if (RgError>0)
		LogLogTag+="Rg = "+num2str(Rg)+"[A]  \t "+num2str(RgError)+"\r"
	else
		LogLogTag+="Rg = "+num2str(Rg)+"[A]   \t 0 "+"\r"
	endif	
	if (BError>0)
		LogLogTag+="B = "+num2str(B)+"  \t "+num2str(BError)+"\r"
	else
		LogLogTag+="B = "+num2str(B)+"  \t 0 "+"\r"
	endif
	if (PError>0)
		LogLogTag+="P = "+num2str(P)+"  \t "+num2str(PError)+"\r"
	else
		LogLogTag+="P = "+num2str(P)+"  \t 0  "	+"\r"
	endif
	if (MassFractal)
		LogLogTag+="Mass fractal assumed"+"\r"
	endif
	if (LinkRGCO)
		LogLogTag+="RgCO linked to Rg of level"+num2str(Lnmb-1)
	else
		if (RGCOError>0)
			LogLogTag+="RgCO = "+num2str(RGCO)+"[A]   \t "+num2str(RGCOError)+", K = "+num2str(K)
		else
			LogLogTag+="RgCO = "+num2str(RGCO)+"[A]   \t 0 , K = "+num2str(K)
		endif
	endif
	if (Corelations)
		LogLogTag+="\rAssumed corelations:\r"
		if (ETAError>0)
			LogLogTag+= "ETA = "+num2str(ETA)+"[A]   \t "+num2str(ETAError)
		else
			LogLogTag+= "ETA = "+num2str(ETA)+"[A]   \t 0 "
		endif
		if (PackError>0)
			LogLogTag+= ", Pack = "+num2str(PACK)+"  \t "+num2str(PackError)
		else
			LogLogTag+= ", Pack = "+num2str(PACK)+"  \t 0 "
		endif
	endif
	if (Lnmb==1)
		if (SASBackgroundError>0)
			LogLogTag+="\rSAS Background = "+num2str(SASBackground)+"     +/-   "+num2str(SASBackgroundError)
		else
			LogLogTag+="\rSAS Background = "+num2str(SASBackground)+"     (fixed)   "
		endif
	endif
	if (numtype(Invariant)==0)
		LogLogTag+="\rInvariant [cm^(-4)] = "+num2str(Invariant)
	endif
	if (numtype(SurfaceToVolume)==0)
		LogLogTag+="      Surface to Volume ratio = "+num2str(SurfaceToVolume)+"  m^2/cm^3"
	endif
	
	IQ4Tag=LogLogTag
	Tag/W=IR1_LogLogPlotU/C/N=$(tagname)/F=2/L=2/M OriginalIntensity, AttachPointNum, LogLogTag
	Tag/W=IR1_IQ4_Q_PlotU/C/N=$(tagname)/F=2/L=2/M OriginalIntQ4, AttachPointNum, IQ4Tag
	
	
end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1A_CorrectLimitsAndValues()
	//this function check the limits, if they make sense for all used levels and sets them according to rules
	
	setDataFolder root:Packages:Irena_UnifFit

	NVAR nmbLevls=root:Packages:Irena_UnifFit:NumberOfLevels

	variable i
	
	For(i=1;i<=nmbLevls;i+=1)
		//Rules to check:
		//Rg should be larger than Rg of previous level, NA for level 1
		if (i>1)
			NVAR PreviousRg=$("Level"+num2str(i-1)+"Rg")
			NVAR CurrentRgLowLimit=$("Level"+num2str(i)+"RgLowLimit")
			if (CurrentRgLowLimit<PreviousRg)
				CurrentRgLowLimit=PreviousRg
			endif
		endif 
		
		//If G=0 the we need to set Rg for that level to high number to remove it from graph
		NVAR CurrentRg=$("Level"+num2str(i)+"Rg")
		NVAR CurrentG=$("Level"+num2str(i)+"G")
		if (CurrentG==0)
			CurrentRg=10^10
		endif
		
		//ETA foe any level must be larger than Rg for that level
		NVAR CurrentETALowLimit=$("Level"+num2str(i)+"EtaLowLimit")
		NVAR CurrentETA=$("Level"+num2str(i)+"Eta")
		if (CurrentETALowLimit<CurrentRg)
			CurrentETALowLimit=CurrentRg
		endif
		if (CurrentETA<CurrentRg)
			CurrentETA=CurrentRg
		endif
	endfor
	
end

