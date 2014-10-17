#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.4
#pragma igorVersion=6.1
#pragma modulename=get2DArea
#include "get_mdint3.1"
#include <WaveSelectorWidget>

static constant enableRomansOldscanNnmeVthing = 0		// set 0 to 1 to enable Roman's old scale and nmeV functionality
static constant kPrefsVersion = 230
static constant kPrefsRecordID = 0
static strConstant kPackageName = "get2Darea"
static strConstant kPreferencesFileName = "Preferences.bin"

Menu "Macros"
	"Get 2D Area", get2DArea#Get2DArea()
end

static function Get2DArea()
	DoWindow/f get2dAreaWindowPanel
	if(V_flag)		// panel already exits
		return 0
	endif
	
	struct get2DareaPanelPrefs prefs
	LoadPackagePrefs(prefs)
	Variable left = prefs.panelCoords[0]
	Variable top = prefs.panelCoords[1]
	Variable right = prefs.panelCoords[2]
	Variable bottom = prefs.panelCoords[3]
	
	dfref oldDF=getdatafolderdfr()
	newdatafolder/o root:Packages; newdatafolder/o/s root:Packages:get2Darea
	variable/g spectrumnumber=0
	variable/g V_dep
	string/g currentWave
	PauseUpdate; Silent 1		// building window...
	Display/k=1/W=(left,top,right,bottom)/n=get2dAreaWindowPanel as "Get 2D Area"
	ControlBar 80
	Slider sliderSpectrumNum,pos={79,4},size={244,45},limits={0,0,1},live=1,value= 0,vert= 0,disable=2,ticks=0,proc=get2DArea#setWaveFromSlider
	if(enableRomansOldscanNnmeVthing)
		Button setScaleButton,pos={346,54},size={50,20},title="Scale",disable=1,proc=get2DArea#DoSetScale
		Button nmeVButton,pos={406,54},size={80,20},title="nm -> eV",disable=1,proc=get2DArea#DonmeV
		SetVariable setvarX,pos={155,56},size={87,15},bodyWidth=60,title="left x", value=_NUM:prefs.setvarX,disable=1
		SetVariable setvarDeltaX,pos={245,56},size={93,15},bodyWidth=60,title="delta x", value=_NUM:prefs.setvarDeltaX,disable=1
	endif
	SetVariable setvarSpectrumNum,pos={333,3},size={160,19},limits={-inf,+inf,0},disable=2,fSize=12
	SetVariable setvarSpectrumNum,value= _NUM:0,bodyWidth=58,proc=get2DArea#setWaveFromSetVar
	Button areaButton,pos={335,30},size={50,45},disable=2,fSize=13,title="Live\rArea",proc=get2DArea#areaButtonProc
	Button hideWaveList,pos={9,6},size={60,45},fSize=11,title="Hide\rWaveList",proc=get2DArea#ShowWaveListProcFunction
	Button Get_mdint3Button,pos={396,30},size={95,20},disable=2,title="Get_mdint3",proc=get2DArea#Do_get_mdint3
	Button OldCursorButton,pos={396,54},size={95,20},disable=2,title="SetOldCurPos",proc=get2DArea#SetOldCursorPosition
	CheckBox check_reverseAxis,pos={9,58},size={109,14},value=prefs.V_check_reverseAxis,proc=get2DArea#Check_ReverseAxisProc,disable=1,title="Reverse Vertical Axis"
	NewPanel/W=(140,300,5,100)/HOST=#/N=get2dAreaWaveListPanel/K=2/EXT=1 as "Wave List"
	ListBox theList,pos={4,4},size={132,292}
	MakeListIntoWaveSelector("get2dAreaWindowPanel#get2dAreaWaveListPanel", "theList", content = WMWS_Waves, selectionMode=WMWS_SelectionSingle, listoptions="DIMS:2")
	WS_SetNotificationProc("get2dAreaWindowPanel#get2dAreaWaveListPanel", "theList", "get2DArea#notificationFunc", isExtendedProc=1)
	SetWindow get2dAreaWaveListPanel,hook(actualizeList)=get2DArea#actualizeListFunction
	SetActiveSubWindow ##
	SetWindow get2dAreaWindowPanel,hook(killNsync)=get2DArea#killNSyncWindowFunction
	setdatafolder oldDF
end

static function actualizeListFunction(s)
	struct  WMWinHookStruct &s

	switch (s.eventcode)
		case 4:
			WS_UpdateWaveSelectorWidget("get2dAreaWindowPanel#get2dAreaWaveListPanel", "theList")
			break
	endswitch
	return 0
end

static function killNSyncWindowFunction(H_Struct)
	struct WMWinHookStruct &H_Struct

	STRUCT get2DareaPanelPrefs prefs
	LoadPackagePrefs(prefs)
	
	switch(H_Struct.eventcode)
		case 2:		// kill
			nvar V_dep=root:Packages:get2Darea:V_dep
			setformula V_dep,""
			killdatafolder/z root:Packages:get2Darea
			//Execute/p/q/z "killwaves/z root:Packages:get2Darea:intWave, root:Packages:get2Darea:oneSpectrum"
			return 1
			break
		case 6:		// resize
			SyncPackagePrefsStruct(prefs)			// Sync prefs struct to match panel state.
			SavePackagePrefs(prefs)
			break
		case 17:	// killVote
			SyncPackagePrefsStruct(prefs)			// Sync prefs struct to match panel state.
			SavePackagePrefs(prefs)
			break
	endswitch
	return 0
end

static function SyncAtCursorMoveFunction(H_Struct)
	struct WMWinHookStruct &H_Struct

	STRUCT get2DareaPanelPrefs prefs
	LoadPackagePrefs(prefs)
	
	switch(H_Struct.eventcode)
		case 7:
			strswitch(H_Struct.cursorName)
				case "A":
					prefs.V_pcsrA = H_Struct.pointnumber
					break
				case "B":
					prefs.V_pcsrB = H_Struct.pointnumber
					break
			endswitch
			SyncPackagePrefsStruct(prefs)			// Sync prefs struct to match panel state.
			SavePackagePrefs(prefs)
			break
	endswitch
	return 0
end

static function notificationFunc(SelectedItem, EventCode, WindowName, listboxName)
	String SelectedItem
	Variable EventCode
	String WindowName
	String listboxName
	
	wave/z selWave=$SelectedItem
	if(!eventCode&4)		// was not a mouse-up
		return 0
	elseif(!waveexists(selWave))		// selectedItem is not a wave
		return 0
	endif
	string tracenameliststr=removeending(tracenamelist("",",",1))
	removefromgraph/w=get2dAreaWindowPanel/z $tracenameliststr
	svar currentWave=root:Packages:get2Darea:currentWave;currentWave=selectedItem
	variable numRows = dimsize(selWave,0)
	variable numColumns = dimsize(selWave,1)
	Slider sliderSpectrumNum,win=get2dAreaWindowPanel,limits={0,(numColumns-1),1},ticks=10,value= 0,vert= 0
	nvar vs=root:Packages:get2Darea:spectrumnumber; vs=0
	appendtograph selWave[][0]
	ModifyGraph mirror=1,minor=1
	ModifyControl setvarSpectrumNum win=get2dAreaWindowPanel,limits={0,(numColumns-1),1},disable=0
	ModifyControl sliderSpectrumNum win=get2dAreaWindowPanel,disable=0
	ModifyControl areaButton win=get2dAreaWindowPanel,disable=0
	ModifyControl Get_mdint3Button win=get2dAreaWindowPanel,disable=0
	ModifyControl OldCursorButton win=get2dAreaWindowPanel,disable=0
	ModifyControl/z setScaleButton win=get2dAreaWindowPanel,disable=1
	ModifyControl/z setvarX win=get2dAreaWindowPanel,disable=1
	ModifyControl/z setvarDeltax win=get2dAreaWindowPanel,disable=1
	ModifyControl/z nmeVButton win=get2dAreaWindowPanel,disable=1
	ModifyControl/z check_reverseAxis win=get2dAreaWindowPanel,disable=1
	ShowInfo
	wavestats/q selWave
	SetAxis/w=get2dAreaWindowPanel left (V_min),(V_max)
	SetWindow get2dAreaWindowPanel,hook(syncAtCursorMove)=get2DArea#SyncAtCursorMoveFunction
	killwaves/z root:Packages:get2Darea:intWave, root:Packages:get2Darea:oneSpectrum
	// make Cursor moveable:
	makeCursorMoveable()
	SetActiveSubwindow get2dAreaWindowPanel
end

static function makeCursorMoveable()
	ListBox theList,win=get2dAreaWindowPanel#get2dAreaWaveListPanel,disable=1
	ListBox theList,win=get2dAreaWindowPanel#get2dAreaWaveListPanel,disable=0
end

static function setWaveFromSetVar(ctrlName,V_SpectrumNum,S_spectrumNum,varName) : SetVariableControl
	string ctrlName
	variable V_SpectrumNum
	string S_spectrumNum
	string varName
	nvar V_dep=root:Packages:get2Darea:V_dep; setformula V_dep, ""
	slider sliderSpectrumNum win=get2dAreaWindowPanel,value=V_SpectrumNum
	modifyGraph/w=get2dAreaWindowPanel column=V_SpectrumNum
end

static function SetWaveFromSlider(ctrlName,V_SpectrumNum,event):sliderControl
	string ctrlName
	variable V_SpectrumNum
	variable event
	if(!(event&1))
		return 0
	endif
	nvar V_dep=root:Packages:get2Darea:V_dep; setformula V_dep, ""
	SetVariable setvarSpectrumNum win=get2dAreaWindowPanel,value= _NUM:V_SpectrumNum
	modifyGraph/w=get2dAreaWindowPanel column=V_SpectrumNum
end

static function DonmeV(nmeVButton):ButtonControl
	string nmeVButton
	wave/z w=waverefindexed("",0,1)
	if(!waveexists(w))
		return 0
	endif
	duplicate/o w,$(nameofwave(w)+"_ev")
	wave ww=$(nameofwave(w)+"_ev")
	ww=((1/x)*1e7)/8065.55
	removefromgraph $nameofwave(w)
	appendtograph w vs ww
	Button setScaleButton win=get2dAreaWindowPanel,disable=2
	SetVariable setvarX win=get2dAreaWindowPanel,disable=2
	SetVariable setvarDeltax win=get2dAreaWindowPanel,disable=2
	Button nmeVButton win=get2dAreaWindowPanel,disable=2
end

static function DoSetScale(setScaleButton):ButtonControl
	string setScaleButton
	wave/z currentwave=waverefindexed("",0,1)
	if(!waveexists(currentwave))
		return 0
	endif
	controlinfo/w=get2dAreaWindowPanel setvarX; variable xstart=V_Value
	controlinfo/w=get2dAreaWindowPanel setvarDeltax; variable xdelta=V_Value
	setscale/p x, xstart, xdelta,"nm", currentWave
	struct get2DareaPanelPrefs prefs
	LoadPackagePrefs(prefs)
	prefs.setvarX = xstart
	prefs.setvarDeltaX = xdelta
	SyncPackagePrefsStruct(prefs)			// Sync prefs struct to match panel state.
	SavePackagePrefs(prefs)
end

static function Do_get_mdint3(Get_mdint3Button) : ButtonControl
	string Get_mdint3Button
	if(strlen(Csrinfo(a,"get2dAreaWindowPanel"))==0||strlen(Csrinfo(b,"get2dAreaWindowPanel"))==0)
		DoAlert 0, "Integration Error: Cursor A and B must be set!"
		return 0
	endif
	struct get2DareaPanelPrefs prefs
	LoadPackagePrefs(prefs)
	svar currentwave=root:Packages:get2Darea:currentwave
	wave sourcewave = $currentwave
	variable bg = prefs.bgMode
	prompt bg, "Start of background (value < 0: no background correction):"
	DoPrompt "Enter value!", bg
	if(V_flag==1)
		return 0
	endif
	variable csrA = pcsr(A), csrB = pcsr(B)
	printf "get_mdint3(%s,%u,%u,%d)\r",currentwave,csrA,csrB,bg
	print get_mdint3(sourcewave,csrA,csrB,bg)
	prefs.V_pcsrA = csrA
	prefs.V_pcsrB = csrB
	prefs.bgMode = bg
	SyncPackagePrefsStruct(prefs)			// Sync prefs struct to match panel state.
	SavePackagePrefs(prefs)
end

static function SetOldCursorPosition(OldCursorButton) : ButtonControl
	string OldCursorButton
	nvar V_dep=root:Packages:get2Darea:V_dep; setformula V_dep, ""
	struct get2DareaPanelPrefs prefs
	LoadPackagePrefs(prefs)
	Cursor/P A $WaveName("",0,1) prefs.V_pcsrA
	Cursor/P B $WaveName("",0,1) prefs.V_pcsrB
	setactiveSubwindow get2dAreaWindowPanel
end

static function ShowWaveListProcFunction(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			controlinfo/w=get2dAreaWindowPanel $ba.ctrlname
			splitstring/e="\".*\"" stringbykey("title",S_recreation,"=",",")
			switch(grepstring(S_Value,".*Hide.*"))
				case 1:
					Button hideWaveList win=get2dAreaWindowPanel,title="Show\rWaveList"
					killwindow $(ba.win+"#get2dAreaWaveListPanel")
					break
				case 0:
					Button hideWaveList win=get2dAreaWindowPanel,title="Hide\rWaveList"
					NewPanel/W=(140,300,5,100)/HOST=#/N=get2dAreaWaveListPanel/K=2/EXT=1 as "Wave List"
					SetWindow get2dAreaWaveListPanel,hook(actualizeList)=get2DArea#actualizeListFunction
					ListBox theList,pos={4,4},size={132,292}
					MakeListIntoWaveSelector("get2dAreaWindowPanel#get2dAreaWaveListPanel", "theList", content = WMWS_Waves, selectionMode=WMWS_SelectionSingle, listoptions="DIMS:2")
					WS_SetNotificationProc("get2dAreaWindowPanel#get2dAreaWaveListPanel", "theList", "get2DArea#notificationFunc", isExtendedProc=1)
			endswitch
			break
	endswitch
	return 0
end

static function areaButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			struct get2DareaPanelPrefs prefs
			LoadPackagePrefs(prefs)
			nvar V_dep=root:Packages:get2Darea:V_dep
			svar currentwave=root:Packages:get2Darea:currentwave
			wave w2d=$currentwave
			if(strlen(Csrinfo(a,"get2dAreaWindowPanel"))==0||strlen(Csrinfo(b,"get2dAreaWindowPanel"))==0)
				print "Life Area Error: Cursor A and B must be set!"
				break
			endif
			variable csrA = pcsr(A), csrB = pcsr(B)
			make/n=(dimsize(w2d,1))/o root:Packages:get2Darea:intWave
			wave intWave=root:Packages:get2Darea:intWave
			variable i
			for(i=0;i<numpnts(intwave);i+=1)
				duplicate/o/r=[csrA,csrB][i] w2d root:Packages:get2Darea:oneSpectrum
				wave oneSpectrum=root:Packages:get2Darea:oneSpectrum
				intwave[i]=area(oneSpectrum)
			endfor
			setscale/p x,dimoffset(w2d,1),dimdelta(w2d,1),waveunits(w2d,1), intwave
			string setFromulaStr
			sprintf setFromulaStr,"get2DArea#V_depFunction(%s,root:Packages:get2Darea:intwave,%d,%d)",currentwave,csrA,csrB
			setformula V_dep, setFromulaStr
			if(strlen(removeending(tracenamelist("",",",1)))>0)
				removefromgraph $removeending(tracenamelist("",",",1))
			endif
			appendtograph intwave
			ModifyGraph/w=get2dAreaWindowPanel mirror=1,minor=1
			ControlInfo/w=get2dAreaWindowPanel check_reverseAxis
			if(V_value)
				setAxis/a/r left
			endif
			ModifyGraph highTrip(bottom)=1e+07		// in case bottom axis units are steps
			if(deltax(intwave)<0)		// in case a time scan was made and the stepsize was negative
				setAxis/a/r bottom
			endif
			ModifyControl setvarSpectrumNum win=get2dAreaWindowPanel,disable=1
			ModifyControl sliderSpectrumNum win=get2dAreaWindowPanel,disable=1
			ModifyControl Get_mdint3Button win=get2dAreaWindowPanel,disable=1
			ModifyControl OldCursorButton win=get2dAreaWindowPanel,disable=1
			ModifyControl areaButton win=get2dAreaWindowPanel,disable=1
			ModifyControl/z setScaleButton win=get2dAreaWindowPanel,disable=0
			ModifyControl/z setvarX win=get2dAreaWindowPanel,disable=0
			ModifyControl/z setvarDeltax win=get2dAreaWindowPanel,disable=0
			ModifyControl/z nmeVButton win=get2dAreaWindowPanel,disable=0
			ModifyControl/z check_reverseAxis win=get2dAreaWindowPanel,disable=0
			HideInfo
			SetWindow get2dAreaWindowPanel,hook(syncAtCursorMove)=$""
			prefs.V_pcsrA = csrA; prefs.V_pcsrB = csrB
			SyncPackagePrefsStruct(prefs)			// Sync prefs struct to match panel state.
			SavePackagePrefs(prefs)
			break
	endswitch
	return 0
end

static function V_depFunction(w2d,intWave,V_pcsrA,V_pcsrB)
	wave w2d,intwave
	variable V_pcsrA,V_pcsrB

	if(dimsize(w2d,1)==numpnts(intwave))
		return 0
	elseif(dimsize(w2d,1)!=numpnts(intwave)+1)
		return -1
	else
		duplicate/o/r=[V_pcsrA,V_pcsrB][(dimsize(w2d,1))-1] w2d root:Packages:get2Darea:oneSpectrum
		wave oneSpectrum=root:Packages:get2Darea:oneSpectrum
		intwave[numpnts(intwave)]={area(oneSpectrum)}
		return 1
	endif
end

static function Check_ReverseAxisProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			if(checked)
				setAxis/a/r left
			else
				setAxis/a left
			endif
			break
	endswitch

	return 0
end

static structure get2DareaPanelPrefs
	uint32 version			// Preferences structure version number. 100 means 1.00
	double panelCoords[4]		// left, top, right, bottom
	uint32 V_pcsrA
	uint32 V_pcsrB
	int32 bgMode
	uint16 V_check_reverseAxis
	double setvarX
	double setvarDeltaX
endStructure

static function DefaultPackagePrefsStruct(prefs)
	STRUCT get2DareaPanelPrefs &prefs

	prefs.version = kPrefsVersion
	
	prefs.panelCoords[0] = 362				// Left
	prefs.panelCoords[1] = 49				// Top
#if stringmatch(igorinfo(2),"Windows")
	prefs.panelCoords[2] = 736				// Right
	prefs.panelCoords[3] = 400				// Bottom
#elif stringmatch(igorinfo(2),"Macintosh")
	prefs.panelCoords[2] = 865				// Right
	prefs.panelCoords[3] = 492				// Bottom
#endif
	prefs.V_pcsrA = 0
	prefs.V_pcsrB = inf
	prefs.bgMode = -56
	prefs.V_check_reverseAxis = 0
	prefs.setvarX = 0
	prefs.setvarDeltaX = 0
end

static function LoadPackagePrefs(prefs)
	STRUCT get2DareaPanelPrefs &prefs

	// This loads preferences from disk if they exist on disk.
	LoadPackagePreferences kPackageName, kPreferencesFileName, kPrefsRecordID, prefs
	// Printf "%d byte loaded\r", V_bytesRead

	// If error or prefs not found or not valid, initialize them.
	if (V_flag!=0 || V_bytesRead==0 || prefs.version!=kPrefsVersion)
		InitPackagePrefsStruct(prefs)						// Set based on panel if it exists or set to default values.
		SavePackagePrefs(prefs)							// Create initial prefs record.
	endif
end

// Sets prefs structures to match state of panel or to default values if panel does not exist.
static function InitPackagePrefsStruct(prefs)
	STRUCT get2DareaPanelPrefs &prefs

	DoWindow get2dAreaWindowPanel
	if (V_flag == 0)
		DefaultPackagePrefsStruct(prefs)		// Panel does not exist. Set prefs struct to default.
	else
		SyncPackagePrefsStruct(prefs)			// Panel does exists. Sync prefs struct to match panel state.
	endif
end

static function SavePackagePrefs(prefs)
	STRUCT get2DareaPanelPrefs &prefs

	SavePackagePreferences kPackageName, kPreferencesFileName, kPrefsRecordID, prefs
end

// SyncPackagePrefsStruct(prefs)
// Syncs package prefs structures to match state of panel.
// Call this function only if the panel exists.
static function SyncPackagePrefsStruct(prefs)
	STRUCT get2DareaPanelPrefs &prefs

	// Panel does exists. Set prefs to match panel settings.
	prefs.version = kPrefsVersion
	
	GetWindow get2dAreaWindowPanel wsize
	prefs.panelCoords[0] = V_left
	prefs.panelCoords[1] = V_top
	prefs.panelCoords[2] = V_right
	prefs.panelCoords[3] = V_bottom
	// to make sure that the graph has initially always the same dimensions, we set right and bottom coords manually:
#if stringmatch(igorinfo(2),"Windows")
	prefs.panelCoords[2] = prefs.panelCoords[0] + (736 - 362); prefs.panelCoords[3] = prefs.panelCoords[1] + (400 - 49)
#elif stringmatch(igorinfo(2),"Macintosh")
	prefs.panelCoords[2] = prefs.panelCoords[0] + (865 - 362); prefs.panelCoords[3] = prefs.panelCoords[1] + (492 - 49)
#endif
	
	ControlInfo /W=get2dAreaWindowPanel check_reverseAxis
	prefs.V_check_reverseAxis = V_Value
	ControlInfo /W=get2dAreaWindowPanel setvarX
	prefs.setvarX = V_Value
	ControlInfo /W=get2dAreaWindowPanel setvarDeltaX
	prefs.setvarDeltaX = V_value
end

static function setDefaultPrefsStruct()
	STRUCT get2DareaPanelPrefs prefs
	DoWindow/k get2dAreaWindowPanel
	DefaultPackagePrefsStruct(prefs)
	SavePackagePrefs(prefs)
end