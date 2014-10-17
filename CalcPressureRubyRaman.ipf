// Writen by Bin Chen (bbchen@gmail.com)
// Version 0.1, 6/4/2009

#pragma rtGlobals=1		// Use modern global access method.
Menu "Macros"
	"Calculate Ruby Pressure", DisplayPressureCalcControlPanel()
End

// This is the display recreation macro, created by Igor and then manually tweaked. 
// The parts that were tweaked are shown in bold.
// Error analysis for the ramanshift
Window PressureCalcControlPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(183,494,573,776) as "Compute Pressure"
	ModifyPanel frameStyle=3, frameInset=1
	SetDrawLayer UserBack
	SetDrawEnv fname= "Arial",fsize= 16
	DrawText 13,27,"Calculate pressure from ruby R1 emission line"
	SetDrawEnv fname= "Arial"
	DrawText 226,249,"(ref: Mao et al., 1986, JGR)"
	SetDrawEnv fname= "Arial",fsize= 16,fstyle= 5
	DrawText 17,188,"Calculated Pressure:"
	SetDrawEnv linefgc= (65535,0,0),fillfgc= (65535,49151,49151),fname= "Arial",fsize= 18,fstyle= 1
	DrawText 272,218,"GPa"
	DrawText 184,275,"© Bin Chen (bbchen@gmail.com)"
	DrawText 12,275,"version 0.2"
	SetDrawEnv linefgc= (65535,0,0),fillfgc= (65535,49151,49151),fname= "Arial",fsize= 18,fstyle= 1
	DrawText 171,219,"±"
	DrawText 232,206,"(G)"
	DrawText 232,225,"(L)"
	SetVariable XSetVar,pos={15,67},size={223,21},title="Ruby R1 line, nm:"
	SetVariable XSetVar,labelBack=(57346,65535,49151),font="Arial",fSize=16
	SetVariable XSetVar,format="%4.2f",fStyle=1
	SetVariable XSetVar,limits={694,800,0.1},value= root:Packages:PressureCalcControlPanel:gRubyCurrent
	Button ComputeButton,pos={105,129},size={178,23},proc=ComputePressureProc,title="Compute Ruby Pressure"
	Button ComputeButton,fSize=12
	ValDisplay dispressure,pos={85,195},size={81,33},font="Arial Bold",fSize=28
	ValDisplay dispressure,format="%3.2f",frame=0,fStyle=1,valueColor=(65535,0,0)
	ValDisplay dispressure,limits={0,0,0},barmisc={0,1000},mode= 1,zeroColor= (32792,65535,1)
	ValDisplay dispressure,value= #"root:Packages:PressureCalcControlPanel:gPressure"
	ValDisplay dispressureerrG,pos={188,189},size={60,21},font="Arial Bold",fSize=18
	ValDisplay dispressureerrG,format="%3.2f",frame=0,fStyle=1
	ValDisplay dispressureerrG,valueColor=(1,16019,65535)
	ValDisplay dispressureerrG,limits={0,0,0},barmisc={0,1000},mode= 1,zeroColor= (32792,65535,1)
	ValDisplay dispressureerrG,value= #"root:Packages:PressureCalcControlPanel:gPressureErrG"
	SetVariable ZeroPR1,pos={15,39},size={277,21},title="Ruby R line at 0 GPa, nm:"
	SetVariable ZeroPR1,labelBack=(57346,65535,49151),font="Arial",fSize=16
	SetVariable ZeroPR1,format="%4.2f",fStyle=1
	SetVariable ZeroPR1,limits={694,800,0},value= root:Packages:PressureCalcControlPanel:gRubyStd
	SetVariable XSetVar1,pos={95,97},size={143,21},title="FWHM:"
	SetVariable XSetVar1,labelBack=(57346,65535,49151),font="Arial",fSize=16
	SetVariable XSetVar1,format="%4.2f",fStyle=1
	SetVariable XSetVar1,limits={0,2,0.1},value= root:Packages:PressureCalcControlPanel:gRubyFWHM
	ValDisplay dispressureerrL,pos={187,208},size={60,21},font="Arial Bold",fSize=18
	ValDisplay dispressureerrL,format="%3.2f",frame=0,fStyle=1
	ValDisplay dispressureerrL,valueColor=(1,16019,65535)
	ValDisplay dispressureerrL,limits={0,0,0},barmisc={0,1000},mode= 1,zeroColor= (32792,65535,1)
	ValDisplay dispressureerrL,value= #"root:Packages:PressureCalcControlPanel:gPressureErrL"
EndMacro

// This is the action procedure for the Compute button.
// We created it using the Button dialog.
Function ComputePressureProc(ctrlName) : ButtonControl
	String ctrlName

	String dfSave = GetDataFolder(1)
	SetDataFolder root:Packages:PressureCalcControlPanel

	NVAR gRubyCurrent, gRubyFWHM, gRubyStd, gPressure, gPressureErrG, gPressureErrL			// Access current data folder.
	
	gPressure = 19.04/7.665*((1+((gRubyCurrent-gRubyStd)/gRubyStd))^7.665-1)*100
	gPressureErrG = 1904*gRubyFWHM/2.35482*(gRubyCurrent/gRubyStd)^7.665/gRubyCurrent
	gPressureErrL = 1904*gRubyFWHM/2.00*(gRubyCurrent/gRubyStd)^7.665/gRubyCurrent
	
	SetDataFolder dfSave
End

// This is the top level routine which makes sure that the globals
// and their enclosing data folders exist and then makes sure that
// the control panel is displayed.
Function DisplayPressureCalcControlPanel()
	// If the panel is already created, just bring it to the front.
	DoWindow/F PressureCalcControlPanel
	if (V_Flag != 0)
		return 0
	endif

	String dfSave = GetDataFolder(1)

	// Create a data folder in Packages to store globals.
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:PressureCalcControlPanel

	// Create global variables used by the control panel.
	Variable ruby_std = NumVarOrDefault(":gRubyStd", 694.34)
	Variable ruby_current = NumVarOrDefault(":gRubyCurrent", 694.34)
	Variable pressure = NumVarOrDefault(":gPressure", 0.00)
	Variable fwhm = NumVarOrDefault(":gRubyFWHM", 0.00)
	Variable pressure_errg = NumVarOrDefault(":gPressureErrG", 0.00)
	Variable pressure_errl = NumVarOrDefault(":gPressureErrL", 0.00)
	Variable/G gRubyStd = ruby_std, gRubyCurrent = ruby_current, gPressure = pressure 
	Variable/G gPressureErrG = pressure_errg, gPressureErrL = pressure_errl
	Variable/G gRubyFWHM = fwhm
	// Create the control panel.
	Execute "PressureCalcControlPanel()"

	SetDataFolder dfSave
End
