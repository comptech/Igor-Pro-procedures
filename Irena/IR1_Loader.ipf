#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.02

//2.01 February 2010
//2.02 May 2010

//This macro file is part of Igor macros package called "Irena", 
//the full package should be available from www.uni.aps.anl.gov/~ilavsky
//this package contains 
// Igor functions for modeling of SAS from various distributions of scatterers...

//Jan Ilavsky, April 2004, version 2.00

//please, read Readme in the distribution zip file with more details on the program
//report any problems to: ilavsky@aps.anl.gov


//this function loads the modeling of Distribution modeling macros...

//these should be all in /User Procedures/Irena folder
#include "IR1_CreateFldrStrctr", version>=2
#include "IR1_CromerLiberman", version>=2
#include "IR1_DataManipulation", version>=2.21
#include "IR1_Desmearing", version>=2
#include "IR1_EvaluationGraph", version>=2
#include "IR1_FittingProc", version>=2
#include "IR1_FormFactors", version>=2.1
#include "IR1_FractalsMain", version>=2
#include "IR1_FractalsFiting", version>=2
#include "IR1_FractalsInit", version>=2
#include "IR1_FractalsCtrlPanel", version>=2
#include "IR1_Functions", version>=2
#include "IR1_GeneralGraph2", version >=2
#include "IR1_GeneralGraph", version >=2.01
#include "IR1_GraphStyling", version>=2
#include "IR1_ImportData", version>=2.04
#include "IR1_IntCalculations", version>=2
#include "IR1_InterferenceLQSF", version>=2
#include "IR1_LSQF_UserModelMain", version>=2
#include "IR1_LSQF_UserPanel", version>=2
#include "IR1_LSQF_UserFncts", version>=2
#include "IR1_LSQF_UserFit", version>=2
#include "IR1_Main", version>=2.38
#include "IR1_Panel", version>=2
#include "IR1_PlotStylesMngr", version>=2
#include "IR1_Recording", version>=2
#include "IR1_ScattContr_New", version>=2.11
#include "IR1_Sizes", version>=2.01
#include "IR1_SupportFncts", version>=2.01
#include "IR1_Unified_Fit_Fncts2", version>=2
#include "IR1_Unified_Fit_Fncts", version>=2.01
#include "IR1_Unified_Panel", version>=2.01
#include "IR1_Unified_Panel_Fncts", version>=2
#include "IR1_Unified_SaveExport", version>=2
#include "IR1_UnifiedSaveToXLS", version>=2
#include "IR2_GelsTool", version>=4
#include "IR2_PanelCntrlProcs", version>=1.08
#include "IR2_UniversalDataExport", version>=1 
#include "IR2_dataMiner", version >=1.02
#include "IR2_Reflectivity", version >=1
#include "IR2L_NLSQFmain", version>=1
#include "IR2L_NLSQFsupport", version>=1
#include "IR2L_NLSQFfunctions", version>=1
#include "IR2L_NLSQFCalc", version>=1
#include "IR2_StructureFactors", version>=1.01
#include "IR2_ScriptingTool", version>=1
#include "IR2_SmallAngleDiff", version>=1
#include "IR2Pr_Regularization", version>=1.01
#include "IR2Pr_PDFMain", version>=1.01
#include "IR2_DWSGraphControls", version>=1
#include "IR2_DWSgraph", version>=1

//these are in different folders...
#include "canSASXML_GUI", version>=1
#include "canSASXML", version>=1.09

#include "GeneticOptimisation", version>=1


#include "IN2_GeneralProcedures", version>=1.53

