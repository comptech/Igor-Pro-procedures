// Writen by Bin Chen (bbchen@gmail.com)
// Version 0.1, 6/4/2009

#pragma rtGlobals=1		// Use modern global access method.
Menu "Macros"
	"Calculate Diamond Pressure", DisplayDiaPCalcControlPanel()
End

// This is the display recreation macro, created by Igor and then manually tweaked. 
// The parts that were tweaked are shown in bold.
// To-Do error analysis for the ramanshift
// To-Do double check if the error analysis is right
Window DiaPCalcControlPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(423,297,807,579) as "Compute Pressure"
	ModifyPanel frameStyle=3, frameInset=1
	SetDrawLayer UserBack
	SetDrawEnv fillbgc= (65535,49151,49151)
	DrawRect 14,132,366,185
	SetDrawEnv fname= "Arial",fsize= 16
	DrawText 13,27,"The high pressure edge the Raman band"
	DrawRect 14,191,366,251
	SetDrawEnv fname= "Arial"
	DrawText 128,242,"(ref: Akahama and Kawamura, JAP, 2004)"
	SetDrawEnv fname= "Arial",fsize= 14
	DrawText 34,220,"P (GPa) = 66.9(7)-0.5281(4)*v+3.585(3)*1e-4*v^2"
	SetDrawEnv fname= "Arial",fsize= 16,fstyle= 1
	DrawText 20,153,"Calculated Pressure:"
	SetDrawEnv linefgc= (65535,0,0),fillfgc= (65535,49151,49151),fname= "Arial",fsize= 18,fstyle= 1
	DrawText 164,179,"±"
	SetDrawEnv linefgc= (65535,0,0),fillfgc= (65535,49151,49151),fname= "Arial",fsize= 18,fstyle= 1
	DrawText 231,180,"GPa"
	DrawText 174,274,"© Bin Chen (bbchen@gmail.com)"
	DrawText 13,272,"version 0.1"
	SetDrawEnv fname= "Arial",fsize= 16
	DrawText 14,49,"of the diamond culet face"
	SetVariable XSetVar,pos={15,68},size={236,21},title="Raman shift, cm\\S-1\\M:"
	SetVariable XSetVar,labelBack=(57346,65535,49151),font="Arial",fSize=16
	SetVariable XSetVar,format="%4.2f",fStyle=1
	SetVariable XSetVar,limits={1330,inf,1},value= root:Packages:DiaPCalcControlPanel:gRamanShift
	Button ComputeButton,pos={96,98},size={178,23},proc=ComputeDiaPressureProc,title="Compute Diamond Pressure"
	Button ComputeButton,fSize=12
	ValDisplay dispressure,pos={99,157},size={60,23},font="Arial Bold",fSize=18
	ValDisplay dispressure,format="%3.2f",frame=0,fStyle=1
	ValDisplay dispressure,limits={0,0,0},barmisc={0,1000},mode= 1,zeroColor= (32792,65535,1)
	ValDisplay dispressure,value= #"root:Packages:DiaPCalcControlPanel:gPressure"
	ValDisplay dispressure_err,pos={177,157},size={54,23},font="Arial Bold",fSize=18
	ValDisplay dispressure_err,format="%0.2f",frame=0,fStyle=1
	ValDisplay dispressure_err,limits={0,0,0},barmisc={0,1000},mode= 1
	ValDisplay dispressure_err,value= #"root:Packages:DiaPCalcControlPanel:gPressureErr"
EndMacro

// This is the action procedure for the Compute button.
// We created it using the Button dialog.
Function ComputeDiaPressureProc(ctrlName) : ButtonControl
	String ctrlName

	String dfSave = GetDataFolder(1)
	SetDataFolder root:Packages:DiaPCalcControlPanel

	NVAR gRamanShift, gPressure, gPressureErr			// Access current data folder.
	// Calculate pressure from Akahama and Kawanura (2004) 
	// High-pressure Raman spectroscopy of diamond anvils to 250 GPa: Method for pressure determination 
	// in the multimegabar pressure range .Journal of Applied Physics, 96, 3748-3751
	gPressure = 66.9-0.5281*gRamanShift+3.585*1e-4*gRamanShift^2
	gPressureErr = 0.7 - 0.0004*gRamanShift + 0.003*1e-4*gRamanShift^2
	//Printf "Pressure=%g +/- %g GPa\r", gPressure, gPressureErr

	SetDataFolder dfSave
End

// This is the top level routine which makes sure that the globals
// and their enclosing data folders exist and then makes sure that
// the control panel is displayed.
Function DisplayDiaPCalcControlPanel()
	// If the panel is already created, just bring it to the front.
	DoWindow/F DiaPCalcControlPanel
	if (V_Flag != 0)
		return 0
	endif

	String dfSave = GetDataFolder(1)

	// Create a data folder in Packages to store globals.
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:DiaPCalcControlPanel

	// Create global variables used by the control panel.
	Variable RamanShift = NumVarOrDefault(":gRamanShift", 1334)
	Variable pressure = NumVarOrDefault(":gPressure", 0.00)
	Variable pressure_err = NumVarOrDefault(":gPressureErr", 0.00)
	Variable/G gRamanShift = RamanShift, gPressure = pressure, gPressureErr = pressure_err
	// Create the control panel.
	Execute "DiaPCalcControlPanel()"

	SetDataFolder dfSave
End
