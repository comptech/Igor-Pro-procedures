#pragma rtGlobals=1		// Use modern global access method.
#pragma IgorVersion=6.2	// for URLEncode
#pragma moduleName=LaTeXPictures
#pragma version=2.1
#include "LaTeX Palettes", menus=0	// don't show "Create LaTeX Palettes" menu to civilians.

// LaTeX Pictures.ipf
//
// JP, 120208, Version 1.0 - PNG-only version via "Roger's Online Equation Editor"
// JP, 120209, Version 2.0 - PDF, PNG, etc version via CodeCogs.com's Online TaTeX Equation Editor
// JP, 120308, Version 2.1 - Insertion of text that doesn't end with } gets a space appended to avoid illegal equations.
//
// This procedure file implements a "LaTeX Pictures" panel which uses a web site to render LaTeX math equations into an Igor PICT.
//
// This is not the place to look for LaTeX expertise, see the "LaTeX Help" button
// and search online for "LaTeX math mode syntax".
//

Menu "LaTeX"
	"LaTeX Pictures",/Q,  LaTeXCreatePicturesPanel()
	LaTeXPictures#LaTeXAutoUpdateMenu(),/Q, LaTeXPictures#LaTeXToggleAutoUpdate()
End

#if 0
// debugging
Menu "LaTeX"
	"Show Pictures Table",/Q, LaTeXPictures#LaTeXMemoryTable()
	"Delete all Latex Pictures",/Q, LaTeXPictures#LaTeXClear()
End
#endif

Static StrConstant ksPanelName= "LaTeXPanel2"		// version 2 panel
Static StrConstant ksNotebookName= "LaTeXPanel2#LATEX"
Static StrConstant ksLaTeXPrefix= "LaTeXPict"	// that is, picture names starting with this are deemed LaTeX pictures
Static StrConstant ksLaTeXMatchPattern= "LaTeXPict*"	
Static StrConstant ksPreviewPictName="LaTeXPreview"
Static StrConstant ksTempFolder="Temporary"
Static StrConstant ksLaTexRendererURL="http://latex.codecogs.com"	// leave the possibility for using a WaveMetrics site someday.

// public
// returns name of created panel
Function/S LaTeXCreatePicturesPanel()
	LaTeXInit()
	DoWindow/K $ksPanelName
	NewPanel/K=1/W=(60,63,668,505)/N=$ksPanelName as "LaTeX Pictures"
	ModifyPanel/W=$ksPanelName noEdit=1

	DefaultGuiFont/W=$ksPanelName/Mac popup={"_IgorMedium",12,0},all={"_IgorMedium",12,0}
	DefaultGuiFont/W=$ksPanelName/Win popup={"_IgorMedium",0,0},all={"_IgorMedium",0,0}

	SetDrawLayer/W=$ksPanelName UserFront
	DrawPICT/W=$ksPanelName 199,334,1,1,LaTeXPreview

	CustomControl link pos={10,4}, size={251,16},fsize=10,title="\\JLLaTeX rendering by \\K(0,0,65535)\\f04"+ksLaTexRendererURL
	CustomControl link,frame=0,value= root:Packages:LaTeXPictures:link,proc=LaTeXPictures#LaTeXLinkcontrolproc

	Button delete,pos={51,34},size={60,20},proc=LaTeXPictures#LaTeXDeleteButtonProc,title="Delete"

	PopupMenu LaTeXPictures,pos={181,33},size={183,20},proc=LaTeXPictures#LaTeXPopMenuProc,title="LaTeX Pictures"
	PopupMenu LaTeXPictures,mode=2,value= #"\"_new_;\"+LaTeXPictures#LaTeXPicturesList(NumVarOrDefault(\"root:Packages:LaTeXPictures:fromTarget\",1))"

	CheckBox fromTarget,pos={183,66},size={187,16},proc=LaTeXPictures#LaTeXFromTargetCheckProc,title="Pictures from Target Window"
	CheckBox fromTarget,variable= root:Packages:LaTeXPictures:fromTarget

	PopupMenu windowsPop,pos={370,4},size={189,20},proc=LaTeXPictures#WindowsPopMenuProc,title="Window using this PICT:"
	PopupMenu windowsPop,fSize=10,fStyle=1
	PopupMenu windowsPop,mode=1,popvalue="_none_",value= #"\"_none_\""

	TitleBox title0,pos={29,97},size={139,16},title="\\JC\\f01Enter LaTeX Expression:", frame=0
	
	PopupMenu palettes,pos={39,131},size={116,20},proc=LaTeXPictures#PalettesPopMenuProc,title="LaTeX Palettes"
	PopupMenu palettes,mode=0,value= #"LaTeXPictures#PaletteList()"

	Button help,pos={46,193},size={90,20},proc=LaTeXPictures#LaTeXHelpButtonProc,title="LaTeX Help"

	PopupMenu foregroundColor,pos={178,191},size={113,20},proc=LaTeXPictures#LaTeXColorPopMenuProc,title="Text Color"
	PopupMenu foregroundColor,mode=1,popColor= (0,0,0),value= #"\"*COLORPOP*\""

	PopupMenu backgroundColor,pos={419,221},size={114,20},proc=LaTeXPictures#LaTeXColorPopMenuProc,title="Back Color"
	PopupMenu backgroundColor,mode=1,popColor= (65535,65534,49151),value= #"\"*COLORPOP*\""

	CheckBox transparent,pos={377,193},size={160,16},proc=LaTeXPictures#LaTexTransparentCheckProc,title="Transparent Background"
	CheckBox transparent,value= 0

	PopupMenu font,pos={178,221},size={161,20},proc=LaTeXPictures#LaTeXFontPopMenuProc,title="Font"
	PopupMenu font,mode=2,popvalue="Computer Modern",value= #"\"Comic Sans;Computer Modern;Helvetica;San Serif;Verdana;\""

	PopupMenu format,pos={178,283},size={139,20},proc=LaTeXPictures#LaTeXFormatPopMenuProc,title="Picture Format"
	PopupMenu format,mode=1,popvalue="PNG",value= #"LaTeXPictures#LaTeXFormats()"

	PopupMenu sizePopup,pos={178,252},size={131,20},proc=LaTeXPictures#LaTeXSizePopMenuProc,title="Size"
	PopupMenu sizePopup,mode=3,popvalue="Normal - 10 pt",value= #"\"Tiny - 5 pt;Small - 9 pt;Normal - 10 pt;Large - 12 pt;LARGE - 18 pt;Huge - 20 pt;\""

	CheckBox compressed,pos={377,254},size={168,16},proc=LaTeXPictures#LaTeXInlineCheckProc,title="Inline/compressed Layout"
	CheckBox compressed,value= 0

	SetVariable setvarDPI,pos={337,286},size={68,15},bodyWidth=50,proc=LaTeXPictures#LaTeXDPISetVarProc,title="DPI"
	SetVariable setvarDPI,fSize=9
	SetVariable setvarDPI,limits={60,600,1},value=_NUM:110

	Button update,pos={458,283},size={105,20},proc=LaTeXPictures#LaTeXUpdateButtonProc,title="Update Picture"

	Button newAnnotation,pos={29,254},size={105,20},proc=LaTeXPictures#LaTeXNewAnnotationButtonProc,title="New Annotation"

	GroupBox shrink,pos={5,305},size={164,77},title="For Hi-Res Printing of PNGs"
	GroupBox shrink,fSize=10

	TitleBox titleScalePICT,pos={9,326},size={101,13},title="\\JRShrink DrawPICTs by:"
	TitleBox titleScalePICT,fSize=10,frame=0,anchor= RT

	SetVariable pictScale,pos={115,324},size={50,16},bodyWidth=50,title=" "
	SetVariable pictScale,fSize=10,format="%d x",limits={1,16,1},variable=root:Packages:LaTeXPictures:pictScale

	Button newDrawPICT,pos={29,353},size={105,20},proc=LaTeXPictures#LaTeXNewDrawPICTButtonProc,title="New DrawPICT"

	Button pictures,pos={36,400},size={90,20},title="Pictures...",proc=LaTeXPictures#LaTeXPicturesButtonProc

	// Notebook subwindow
	DefineGuide UGV0={FR,-16},UGV1={FL,178},UGH0={FT,186}
	NewNotebook /F=1 /N=LaTeX /W=(122,95,362,291)/FG=(UGV1,,UGV0,UGH0) /HOST=# 
	Notebook kwTopWin, defaultTab=36, statusWidth=0, autoSave=1, showRuler=0, rulerUnits=1
	Notebook kwTopWin newRuler=Normal, justification=0, margins={0,0,389}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",10,0,(0,0,0)}
	Notebook kwTopWin, zdata= "GaqDU%ejN7!Z)ts!+JDOp1=$K)nClX8AL$OXonuhNQhoT!s90qgJ2>bpXHk*Z:\"m$!0cgXb5"
	Notebook kwTopWin, zdataEnd= 1
	RenameWindow #,LaTeX
	SetActiveSubwindow ##

	// update to current settings
	SetWindow $ksPanelName hook(LaTeXPanel)=LaTeXPictures#LaTeXPanelWindowHook
	String/G root:Packages:LaTeXPictures:previousLaTeXPicture = "" // to force an update
	ControlInfo/W=$ksPanelName LaTeXPictures
	LaTeXSetControlsByName(S_Value)
	LaTeXUpdatePanelForActivate()
	
	return ksPanelName
End

Static Function LaTeXPanelWindowHook(s)
	STRUCT WMWinHookStruct &s

	Variable hookResult = 0

	strswitch(s.eventName)
		case "activate":
			LaTeXUpdatePanelForActivate()
			break
		case "kill":
			LaTeXPruneMemory()
			KillPICTs/Z $ksPreviewPictName
			break
	endswitch
	return hookResult
End	

Static Function LaTeXUpdatePanelForActivate()

	NVAR fromTarget= root:Packages:LaTeXPictures:fromTarget
	String windowName= LaTeXTargetWindow()
	Variable disable
	if( strlen(windowName) == 0  )
		fromTarget= 0
		disable= 2
	else
		disable= 0
	endif
	CheckBox fromTarget,win=$ksPanelName,disable=disable
	LaTeXUpdatePicturesList(fromTarget)
	LaTeXEnableButtons()
End

Static Function/S LaTeXAutoUpdateMenu()
	String checked=""

	Variable au=LaTexWantAutoUpdate()
	if( au )
		checked= "!" + num2char(18)
	endif
	return "\\M0:"+checked+":LaTeX Auto update"
End

Static Function LaTeXToggleAutoUpdate()

	Variable au=LaTexWantAutoUpdate()
	Variable/G root:Packages:LaTeXPictures:autoUpdate= !au
End

Static Function LaTexWantAutoUpdate()

	Variable au=NumVarOrDefault("root:Packages:LaTeXPictures:autoUpdate",1)
	return au
End


Static Constant kCurrentLaTexSettingsVersion= 1
Static StrConstant ksCurrentLaTexSettingsInfo= "Initial version, renderer on www.codecogs.com"
Static Constant kVersionInfoBytes=128
Static Constant kFileFormatBytes=16
Static Constant kFontNameBytes=64
Static Constant kSizeStyleBytes=64

// Public
Structure LaTeXSettings	// everything EXCEPT the actual LaTeX code itself.
	// Version
	int32 version							// kCurrentLaTexSettingsVersion
	char versionInfo[kVersionInfoBytes]	// whatever seems pertinent
	
	// Format
	char fileFormat[kFileFormatBytes]		// "EMF;PDF;PNG;"
	
	// Font
	char font[kFontNameBytes]			// "Comic Sans;Computer Modern;Helvetica;San Serif;Verdana;"
	
	// size
	char sizeStyle[kSizeStyleBytes]		// "Tiny - 5 pt;Small - 9 pt;Normal - 10 pt;Large - 12 pt;LARGE - 18 pt;Huge - 20 pt;"
	Variable dpi								// 50-600	Set Variable, not used for PDF or other vector-based formats
	Variable inlineStyle						// aka "Compressed", Checkbox

	// Background
	Variable backgroundIsTransparent		// Checkbox
	Variable backgroundOpaqueRed			// color popup enabled if Transparent isn't checked.
	Variable backgroundOpaqueGreen
	Variable backgroundOpaqueBlue

	// Foreground
	Variable foregroundOpaqueRed	// color popup
	Variable foregroundOpaqueGreen
	Variable foregroundOpaqueBlue
	
	// End of Version 1 format
EndStructure

// Usage:
//
//	STRUCT LaTexSettings ts
//	LaTexInitSettings(ts)
Static Function LaTexInitSettings(ts)
	STRUCT LaTexSettings &ts	// output
	
	ts.version= kCurrentLaTexSettingsVersion
	ts.versionInfo= ksCurrentLaTexSettingsInfo
	// defaults
	ts.fileFormat= "PNG"	// not best; it's just cross-platform

	ts.font= "Computer Modern"

	ts.sizeStyle= "Normal - 10 pt"
	ts.dpi= 110
	ts.inlineStyle= 0
	
	ts.backgroundIsTransparent= 1
	ts.backgroundOpaqueRed= 65535	// white
	ts.backgroundOpaqueGreen= 65535
	ts.backgroundOpaqueBlue= 65535
	
	ts.foregroundOpaqueRed= 0			// black
	ts.foregroundOpaqueGreen= 0
	ts.foregroundOpaqueBlue= 0
End

Static Function LaTeXInit()

	String df= GetDataFolder(1)
	NewDataFolder/O root:Packages
	NewDataFolder/O/S root:Packages:LaTeXPictures

	Variable checked= NumVarOrDefault("root:Packages:LaTeXPictures:fromTarget",0)
	String windowName= LaTeXTargetWindow()
	if( strlen(windowName) == 0  )
		checked= 0
	endif
	Variable/G fromTarget= checked
	
	String previous= StrVarOrDefault("root:Packages:LaTeXPictures:previousLaTeXPicture","")
	String/G previousLaTeXPicture=previous
	
	String/G link= "http://www.codecogs.com/latex/eqneditor.php"
	
	Variable ps=NumVarOrDefault("root:Packages:LaTeXPictures:pictScale",4)
	Variable/G pictScale= ps
	
	Variable au=NumVarOrDefault("root:Packages:LaTeXPictures:autoUpdate",1)
	Variable/G autoUpdate= au
	
	SetDataFolder df
	
	// create a blank preview
	if( !LaTeXPICTExists(ksPreviewPictName) )
		LaTeXPreviewMessage("")
	endif
End

// Trims nonexistent picts from the memory wave.
// (Do this when closing the panel.)
Static Function/S LaTeXPruneMemory()
	
	String list=""	// list of forgotten picts
	// go through the list and remove the memory of any pict that's not in the picture gallery
	Wave/T/Z tw= root:Packages:LaTeXPictures:LaTeXMemory2
	if( WaveExists(tw) )
		Variable row,rows= DimSize(tw,0)
		for(row=0; row<rows; row+=1)
			String name=GetDimLabel(tw,0,row)
			if( !LaTeXIsNew(name) )
				if( !LaTeXPICTExists(name) ) // PICT name was deleted (or never created)
					if( (row == 0) && (rows == 1) )	// avoid collapsing to 1-d wave
						Redimension/N=(0,-1), tw
					else
						DeletePoints/M=0 row, 1, tw
						row -= 1
						rows -=1
					endif
					list += name+";"	 // list of forgotten picts
				endif
			endif
		endfor
	endif
	return list
End


// Debugging
Static Function LaTeXMemoryTable()
	Wave/T/Z tw= root:Packages:LaTeXPictures:LaTeXMemory2
	if( WaveExists(tw) )
		DoWindow/K LaTeXMemoryTable
		Edit/N=LaTeXMemoryTable root:Packages:LaTeXPictures:LaTeXMemory2.ld
	else
		DoAlert 0, "The LaTeX Memory text wave does not exist!"
	endif
End

// Debugging
Static Function LaTeXClear()
	Wave/T/Z tw= root:Packages:LaTeXPictures:LaTeXMemory2
	if( WaveExists(tw) )
		DoWindow/K LaTeXMemoryTable
		DoWindow/K $ksPanelName
		
		Variable row,rows= DimSize(tw,0)
		for(row=0; row<rows; row+=1)
			String name=GetDimLabel(tw,0,row)
			KillPICTs/Z $name
		endfor
		KillWaves/Z tw
	endif
	KillDataFolder/Z root:Packages:LaTeXPictures
	KillPICTs/Z $ksPreviewPictName
	DoIgorMenu "Misc","Pictures"
End

Function/S LaTexPageColorCommand(fileFormat,red,green,blue)
	String fileFormat	// "PDF", "EMF", or "PNG"
	Variable red,green,blue	// 0-65535
	
	String opaque= "\\bg_white&space;"
	red /= 65535
	green /= 65535
	blue /= 65535
	String pagecolor
	sprintf pagecolor "\\pagecolor[rgb]{%f,%f,%f}&space;", red, green, blue // note the trailing &space;
	return opaque + pagecolor 	// make opaque, then change the background color
End

// Returns name of loaded picture, or "" on error
// Leave this public
Function/S LaTeXDownload(LaTeX, ts, pictName)
	String LaTeX
	STRUCT LaTexSettings &ts	// input
	String pictName	// pass "" to get an automatically created picture name

	String url= ksLaTexRendererURL+"/"	// "http://latex.codecogs.com/"

	// file type determines the query
	String download= LowerStr(ts.fileFormat)+".download?"
	url += download
	
	// font
	String font=""	// default
	strswitch(ts.font)
		default:
		case "San Serif":
			break
		case "Verdana":
			font= "\\fn_jvn "	// the trailing space is required
			break
		case "Comic Sans":
			font= "\\fn_cs "	// the trailing space is required
			break
		case "Computer Modern":
			font= "\\fn_cm "	// the trailing space is required
			break
		case "Helvetica":
			font= "\\fn_phv "	// the trailing space is required
			break
	endswitch
	String encodeThis= font
	
	// sizing: style
	String sizeStyle=""	// default
	strswitch( ts.sizeStyle )
		case "Tiny - 5 pt":
			sizeStyle= "\\tiny "	// the trailing space is required, as is the \\ (for \t especially)
			break
		case "Small - 9 pt":
			sizeStyle= "\\small "	// the trailing space is required
			break
		default:
		case "Normal - 10 pt":
			break
		case "Large - 12 pt":
			sizeStyle= "\\large "	// the trailing space is required
			break
		case "LARGE - 18 pt":
			sizeStyle= "\\LARGE "	// the trailing space is required, and case matters to LaTeX
			break
		case "Huge - 20 pt":
			sizeStyle= "\\huge "	// the trailing space is required
			break
	endswitch
	
	// sizing: dpi
	String dpi
	sprintf dpi, "\\dpi{%d} ",max(50,ts.dpi)
	sizeStyle += dpi
	
	// siziing: inline
	if( ts.inlineStyle )
		sizeStyle += "\\inline "
	endif

	encodeThis += sizeStyle
	
	// optional background color (default is transparent)
	Variable red, green, blue
	if( !ts.backgroundIsTransparent )
		String bgcolor= LaTexPageColorCommand(ts.fileFormat,ts.backgroundOpaqueRed,ts.backgroundOpaqueGreen,ts.backgroundOpaqueBlue)
		encodeThis += bgcolor
	endif

	// The foreground color wraps around the LaTeX expression, so we process LaTeX now
	if( CmpStr(LaTeX[0],"$") == 0 )
		LaTeX= RemoveEnding(LaTeX[1,inf],"$")
	endif

	// wrap the expression in the foreground color:
	// 	{\\color[rgb]{redFraction,greenFraction,blueFraction}<LaTeX>}
	String coloredLaTeX
	red= ts.foregroundOpaqueRed/65535
	green= ts.foregroundOpaqueGreen/65535
	blue=ts.foregroundOpaqueBlue/65535
	sprintf coloredLaTeX, "{\\color[rgb]{%f,%f,%f} %s} ", red, green, blue, LaTeX

	encodeThis += coloredLaTeX

#if 0
	// latex.codecogs.com doesn't like this standard method.
	encodeThis= URLEncode(encodeThis)
#else
	encodeThis= replacestring("\r", encodeThis, "")
	encodeThis= replacestring("\n", encodeThis, "")
	encodeThis= replacestring(" ", encodeThis, "&space;")
#endif
//Print encodeThis	

	url +=encodeThis
	String imageBytes = FetchURL(url)	// Get the image
	Variable error = GetRTError(1)
	if (error != 0)
		Beep
		LaTeXPreviewMessage("Error downloading image from "+ksLaTexRendererURL)
	elseif( LaTexStringStartsWithError(imageBytes)  )
		Beep
		LaTeXPreviewMessage(imageBytes[0,200])	// limit the string length to fit in a picture
	else
		// Save PNG to disk
		Variable refNum
		String fileName= "LaTeXIgor"
		String extension= "."+LowerStr(ts.fileFormat)
		String localPath = SpecialDirPath(ksTempFolder, 0, 0, 0) +fileName+extension
		Open/T=(extension) refNum as localPath
		FBinWrite refNum, imageBytes
		Close refNum
		
		// now try loading the png as a picture
		if( strlen(pictName) )
			LoadPICT/Q/O localPath, $pictName	// overwrites given name
		else
			LoadPICT/Q localPath
		endif
		pictName= StringByKey("NAME", S_info)
		String type= StringByKey("TYPE", S_info)
		LaTeXRememberSettings(pictName,LaTeX,ts)
		if( CmpStr(type, "Unknown type") == 0 )
			Beep
			LaTeXPreviewMessage(type)
		else
			LaTeXUpdatePreviewFromPICT(pictName,extension)
		endif
	endif
	
	return pictName
End

Static Function LaTexStringStartsWithError(str)
	String str
	
	String error= "Error: "	// what codecogs.com puts in to the http result on error, followed by explanatory text
	Variable len= strlen(error)
	String start= str[0,len-1]
	return CmpStr(start,error)== 0
End

Static Function/S LaTeXTargetWindow()

	String windowName= WinName(0,1+4+64)	// top graphs, layouts, and panels, INCLUDING $ksPanelName
	if( CmpStr(windowName, ksPanelName) == 0 )
		windowName= WinName(1,1+4+64)	// next one down
	endif
	return windowName
End

Static Function/S PictsInRecreation(windowName)
	String windowName
	
	String list=""
	// search for "\\$PICT$name="+pictName+"$/PICT$"
	Variable options= WinType(windowName) == 1 ? 4 : 0
	String recreation= WinRecreation(windowName,options)
	Variable index= 0
	String key1= "\\$PICT$name="
	String key2= "$/PICT$"
	do
		index= strsearch(recreation, key1, index , 2)	// ignore case
		if( index < 0 )
			break
		endif
		index += strlen(key1)
		Variable pastName= strsearch(recreation, key2, index, 2)
		if( pastName < 0 )
			break
		endif
		String pictName= recreation[index,pastName-1]
		list += pictName+";"
		index= pastName+strlen(key2)
	while(1)
	return list
End

Static Function/S LaTeXPictsInRecreation(windowName)
	String windowName
	
	String list=PictsInRecreation(windowName)
	list= ListMatch(list,ksLaTeXMatchPattern)
	return list
End

Static Function/S LaTeXPictsInWindow(windowName)
	String windowName	// pass "_all_" for a list of all LaTeXPICTs, "" for those in the target window
	
	String list=""
	
	if( CmpStr(windowName,"_all_") == 0 )
		list= PictList(ksLaTeXMatchPattern,";","")
	else
		if( strlen(windowName) == 0 )
			windowName= LaTeXTargetWindow()
			if( strlen(windowName) == 0 )
				return ""	// none!
			endif
		endif
		// we have a window name, perhaps the window doesn't exist!
		DoWindow $windowName
		if( V_Flag )	// window exists!
			list= PictList(ksLaTeXMatchPattern,";","WIN:"+windowName)
			list += LaTeXPictsInRecreation(windowName)
		endif
	endif
	
	return list
End

Static Function LaTeXPreviewMessage(errorString)
	String errorString
	
	Variable haveError = strlen(errorString)
	Variable width=20, height=20, fs=10
	if( haveError )
		Variable fsPix= fs * ScreenResolution/72	// point text in pixels
		width= FontSizeStringWidth("default",fsPix,0,errorString,"native")
		width = width / ScreenResolution * 72 + 10	// pixels
		height= FontSizeHeight("default",fsPix,0,"native") + 10
	else
		errorString="Empty Preview"
	endif
	NewPanel/W=(20,20,20+width,20+height) as errorString
	String windowName= S_Name
	if( haveError )
		SetDrawEnv/W=$windowName xcoord=abs, ycoord=abs, fsize=fs, textrgb=(65535,0,0), save
		DrawText/W=$windowName 5,height-5, errorString
	endif

	String fileName= "LaTeXIgorPreview.png"
	String localPath = SpecialDirPath("Temporary", 0, 0, 0) +fileName
	SavePICT/O/WIN=$windowName/SNAP=2/E=-5 as localPath
	DoWindow/K $windowName
	LoadPICT/Q/O localPath, $ksPreviewPictName	// overwrites given name
End

Static Function/S LaTeXFormats()

	String formats="PNG"
#ifdef WINDOWS
	formats= "PNG;EMF;"
#endif
#ifdef MACINTOSH
	formats = "PDF;PNG;"
#endif
	return formats
End


Static Function/S LaTeXPicturesList(fromTarget)
	Variable fromTarget	// NumVarOrDefault("root:Packages:LaTeXPictures:fromTarget",1)

	String list=""
	if( fromTarget )
		String windowName= LaTeXTargetWindow()
		if( strlen(windowName)  )
			DoWindow $windowName
			if( V_Flag )	// it exists!
				list= LaTeXPictsInWindow(windowName)
			endif
		endif
	else
		//list= PictList(ksLaTeXMatchPattern,";","")
		// Instead, get the list of all pictures that are remembered in the memory wave:
		// this gets Tex for deleted pictures!
		Wave/T/Z tw= root:Packages:LaTeXPictures:LaTeXMemory2
		if( WaveExists(tw) )
			Variable row,rows= DimSize(tw,0)
			for(row=0; row<rows; row+=1)
				String name=GetDimLabel(tw,0,row)
				if( !LaTeXIsNew(name) )	// avoid _new_ showing up in the popup twice.
					// nonexistent picts
					if( !LaTeXPICTExists(name) ) // PICT name was deleted (or never created)
						if( (row == 0) && (rows == 1) )	// avoid collapsing to 1-d wave
							Redimension/N=(0,-1), tw
						else
							DeletePoints/M=0 row, 1, tw
							row -= 1
							rows -=1
						endif
					else
						list += name+";"
					endif
				endif
			endfor
		endif
	endif
	return SortList(list)
End


//	for all targetable windows in WindowList, get the pictList, check for match, and if so, force an update
Static Function LaTeXUpdateWindowsWithPict(pictName)
	String pictName
	
	String windowName
	Variable index=0
	do
		windowName= WinName(index,1+4+64)	// top graphs, layouts, and panels, INCLUDING $ksPanelName
		if( strlen(windowName) == 0 )
			break
		endif
		index += 1
		
		String picts= LaTeXPictsInWindow(windowName)
		Variable whichItem= WhichListItem(pictName, picts)
		if( whichItem >= 0 )
			// force an update; the strategy depends on the window type
			Variable type= WinType(windowName)
			switch( type )
				case 1:			// Graph
					DrawAction /W=$windowName getgroup=LaTeXDummyGroup, delete, begininsert
					SetDrawEnv /W=$windowName gstart, gname= LaTeXDummyGroup
					DrawText/W=$windowName 0,0, "Updating "+pictName
					SetDrawEnv /W=$windowName gstop
					DrawAction /W=$windowName endinsert
					DrawAction /W=$windowName getgroup=LaTeXDummyGroup, delete
					break
				case 3:			// layout
					ModifyLayout/W=$windowName/Z fidelity=0
					DoUpdate/W=$windowName
					ModifyLayout/W=$windowName/Z fidelity=1
					DoUpdate/W=$windowName
					break
				case 7:			// Panel
					break		// it just works.
			endswitch
		endif
	while(1)
End

Static Function/S LaTeXWindowsUsingPICT(pictName)
	String pictName
	
	String list=""
	String windowName
	Variable index=0
	do
		windowName= WinName(index,1+4+64)	// top graphs, layouts, and panels, INCLUDING $ksPanelName
		if( strlen(windowName) == 0 )
			break
		endif
		index += 1
		
		String picts= LaTeXPictsInWindow(windowName)
		Variable whichItem= WhichListItem(pictName, picts)
		if( whichItem >= 0 )
			list += windowName+";"
		endif
	while(1)

	return list
End

static Function WindowsPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	if( CmpStr(popStr,"_none_") != 0 )
		DoWindow/F $popStr
	endif
End

// returns LaTex expression
Static Function/S LaTeXGetControlSettings(ts)
	STRUCT LaTexSettings &ts	// output

	String LaTeX= LaTeXGetNotebookText()

	LaTexInitSettings(ts)
	
	// Format
	ControlInfo/W=$ksPanelName format
	ts.fileFormat= S_value

	// Font
	ControlInfo/W=$ksPanelName font
	ts.font= S_value
	
	// Size
	ControlInfo/W=$ksPanelName sizePopup
	ts.sizeStyle= S_value
	
	ControlInfo/W=$ksPanelName setvarDPI
	ts.dpi= V_Value
	
	ControlInfo/W=$ksPanelName compressed
	ts.inlineStyle= V_Value
	
	// Background
	ControlInfo/W=$ksPanelName transparent
	ts.backgroundIsTransparent= V_Value

	ControlInfo/W=$ksPanelName backgroundColor
	ts.backgroundOpaqueRed= V_Red
	ts.backgroundOpaqueGreen= V_Green
	ts.backgroundOpaqueBlue= V_Blue
	
	// Foreground
	ControlInfo/W=$ksPanelName foregroundColor
	ts.foregroundOpaqueRed= V_Red
	ts.foregroundOpaqueGreen= V_Green
	ts.foregroundOpaqueBlue= V_Blue
	
	return LaTeX
End

// returns the pictures popup name
// The returned string will NOT be "_new_", because if the popup is "_new_",
// then a new unique pict name is created and returned.
Static Function/S LaTeXRememberControlSettings(pictName)
	String pictName

	if( strlen(pictName) == 0 )
		ControlInfo/W=$ksPanelName LaTeXPictures
		if( V_flag > 0 )
			pictName= S_value	// can be "_new_"
		else
			pictName= "_new_"	// shouldn't happen
		endif
	endif

	Variable isNew= LaTeXIsNew(pictName)
	if( isNew )
		pictName= UniqueName(ksLaTeXPrefix, 13, 0)	// unique picture name
	endif

	STRUCT LaTexSettings ts
	String LaTeX= LaTeXGetControlSettings(ts)

	LaTeXRememberSettings(pictName,LaTeX,ts)

	return pictName
End

Static Function LaTeXRememberSettings(pictName, LaTeX, ts)
	String pictName, LaTeX
	STRUCT LaTexSettings &ts	// input
	
	Variable index= -2	// not found
	if( strlen(pictName) )
		Wave/T tw= LaTeXEnsureMemoryWave()
		// find by name; we use dimension label for each row
		index= FindDimLabel(tw,0,pictName)	// returns -2 if not found (-1 is the overall dimension label)
		if( index == -2 )
			// add a row. We'll put it up front to implement a Most Recently Used priority
			// this invalidates any indexes stored elsewhere, so don't store indexes (store names).
			InsertPoints/M=0 0, 1, tw
			SetDimLabel 0, 0, $pictName, tw
			index= 0
		endif
		tw[index][%LaTeX]= LaTeX

		String contents
		// StructPut /S [/B=b ] structVar, strStruct
		StructPut/S/B=2 ts, contents	// use /B=2 so the experiment can be transferred between Mac and Windows
		tw[index][%structureVersion]=num2istr(ts.version)	// INTEGER
		tw[index][%structureContents]=contents

	endif
	return index
End

// NOTE: we need two back slashes to get one (we need two), then a space and a newline
static StrConstant ksInitialLaTeX= "Enter LaTeX expression here.\\\\ \rNote: normal spaces are discarded, use \; to insert a space!"

Static Function LaTeXIsInitialText()
	
	String LaTeX= LaTeXGetNotebookText()
	return CmpStr(LaTeX, ksInitialLaTeX) == 0
End

// returns LaTeX
Static Function/S LaTeXGetSettingsByName(pictName, ts)
	String pictName	// can be _new_
	STRUCT LaTexSettings &ts	// output
	
	String LaTeX= ksInitialLaTeX

	LaTexInitSettings(ts)

	if( strlen(pictName) && !LaTeXIsNew(pictName) )
		Wave/T tw= LaTeXEnsureMemoryWave()
		// find by name; we use dimension label for each row
		Variable index= FindDimLabel(tw,0,pictName)	// returns -2 if not found (-1 is the overall dimension label)
		if( index >= 0 )
			LaTeX= tw[index][%LaTeX]
			Variable structureVersion= str2num(tw[index][%structureVersion])	// integer
			String  structureContents= tw[index][%structureContents]
			LaTexMakeSettingsCompatible(structureVersion, structureContents, ts)
		endif
	endif
	return LaTeX
End

// Protect against old versions of the structure by up-converting old versions
// Also protect against Mac <--> Win conversions
Static Function LaTexMakeSettingsCompatible(structureVersion, structureContents, ts)
	Variable structureVersion	// input
	String  structureContents	// input: result of a previous StructPut/S/B=2 structureContents based on the structure as defined by structureVersion
	STRUCT LaTexSettings &ts	// output

	// ony one version exists
	switch( structureVersion )
		default:
			DoAlert 0, "Incompatible settings structure found! (ignored)"
			LaTexInitSettings(ts)
			break
		case kCurrentLaTexSettingsVersion:
			// StructGet /S [/B=b ] structVar, strStruct
			StructGet/S/B=2 ts, structureContents		// use /B=2 so the experiment can be transferred between Mac and Windows
#ifdef WINDOWS
			// Windows doesn't do PDF (!)
			if( CmpStr(ts.fileFormat, "PDF") == 0 )
				ts.fileFormat= "PNG"	// EMF works, yes, but PNG is prettier (the size isn't goofed up)
			endif	// "EMF;PDF;PNG;"
#endif
#ifdef MACINTOSH
			// Mac doesn't do EMF
			if( CmpStr(ts.fileFormat, "EMF") == 0 )
				ts.fileFormat= "PDF"	// On Mac, PDF is best
			endif
#endif
			break
	endswitch
End

Static Function/WAVE LaTeXEnsureMemoryWave()
	
	Wave/T/Z tw= root:Packages:LaTeXPictures:LaTeXMemory2
	if( !WaveExists(tw) )
		Make/T/O/N=(0,3) root:Packages:LaTeXPictures:LaTeXMemory2/WAVE=tw
		SetDimLabel 1, 0, LaTeX, tw
		SetDimLabel 1, 1, structureVersion, tw	// Structure LaTeXSettings.version
		SetDimLabel 1, 2, structureContents, tw	// Structure LaTeXSettings
	endif
	return tw
End

Static Function/S LaTeXUpdateLaTeXPICT()

	ControlInfo/W=$ksPanelName LaTeXPictures
	String pictName= S_Value
	Variable isNew= LaTeXIsNew(pictName)

	pictName= LATexRememberControlSettings(pictName)
	
	STRUCT LaTexSettings ts
	String LaTeX= LaTeXGetSettingsByName(pictName, ts)

	String createdName= LaTeXDownload(LaTeX,ts,pictName)
	if( strlen(createdName) )	// mostly to check that all went well, it should be the same as pictName
		if( isNew )	// new means it's not in use anywhere yet
			// turn off From Target; it's not in any target window, yet.
			NVAR fromTarget= root:Packages:LaTeXPictures:fromTarget
			fromTarget= 0
		else
			LaTeXUpdateWindowsWithPict(pictName)
		endif
	endif
	PopupMenu LaTeXPictures, win=$ksPanelName, popmatch=createdName
	return createdName
End

Static Function LaTeXIsNew(name)
	String name
	
	return CmpStr(name,"_new_") == 0
End

Static Function LaTeXPICTExists(pictName)
	String pictName
	
	String emptyIfNotExists= PICTList(pictName,";","")
	Variable pictExists= strlen(emptyIfNotExists)
	
	return pictExists
End

Static Function LaTeXUpdatePicturesList(fromTarget)
	Variable fromTarget
	
	ControlInfo/W=$ksPanelName LaTeXPictures
	String currentName= S_value
	Variable wasNew= LaTeXIsNew(currentName)
	
	String windowName="_all_"
	if( fromTarget )
		windowName= LaTeXTargetWindow()
	endif
	Variable mode=1	// _new_
	if( strlen(windowName) )
		String picts= LaTeXPictsInWindow(windowName)
		if( strlen(picts) )
			mode=2
		endif
	endif
	PopupMenu LaTeXPictures, win=$ksPanelName, mode=mode
	PopupMenu LaTeXPictures, win=$ksPanelName, popMatch=currentName	// if possible
	
	// Possibly Update the LaTeXt and settings
	ControlInfo/W=$ksPanelName LaTeXPictures
	String newName= S_value
	if( CmpStr(newName, currentName) != 0 )
		LaTeXSetControlsByName(newName)
		LaTeXPossiblyUpdatePicture()
	endif
	
	// always update the window list, because windows come and go, as do their use of the named picture
	LaTeXUpdatePICTWindowList()
End

Static Function LaTeXUpdatePICTWindowList()

	ControlInfo/W=$ksPanelName LaTeXPictures
	String windows= LaTeXWindowsUsingPICT(S_value)
	Variable fstyle= 0
	String title="Window(s) using this PICT:"
	if( strlen(windows) )
		Variable items= ItemsInList(windows)
//		windows= RemoveEnding(ReplaceString(";", windows, ", "),", ")
		if( items == 1 )
			title= "Window using this PICT:"
		else
			title= "Windows using this PICT:"
		endif
#ifdef MACINTOSH
		fstyle= 1
#endif
	else
		windows= "\\M1:(:_none_"
	endif
		
	PopupMenu windowsPop, win=$ksPanelName, fstyle=fstyle,title=title
	windows= "\"" +windows+"\""
	PopupMenu windowsPop, win=$ksPanelName,mode=1,value=#windows
End

Static Function LaTeXSetControlsByName(pictName)
	String pictName

	STRUCT LaTexSettings ts
	String LaTeX= LaTeXGetSettingsByName(pictName, ts)

	LaTeXSetNotebookText(LaTeX)
	
	// Format
	PopupMenu format, win=$ksPanelName, popmatch=ts.fileFormat

	// Font
	PopupMenu font, win=$ksPanelName, popmatch=ts.font
	
	// Size
	PopupMenu sizePopup, win=$ksPanelName, popmatch=ts.sizeStyle
	
	// dpi
	SetVariable setvarDPI, win=$ksPanelName, value=_NUM:ts.dpi
	
	Checkbox compressed, win=$ksPanelName, value=ts.inlineStyle
	
	// Background
	Checkbox transparent, win=$ksPanelName, value=ts.backgroundIsTransparent

	PopupMenu backgroundColor, win=$ksPanelName, popcolor=(ts.backgroundOpaqueRed,ts.backgroundOpaqueGreen,ts.backgroundOpaqueBlue)
	
	// Foreground
	PopupMenu foregroundColor, win=$ksPanelName, popcolor=(ts.foregroundOpaqueRed,ts.foregroundOpaqueGreen,ts.foregroundOpaqueBlue)

	String fileExtension= "."+LowerStr(ts.fileFormat)
	LaTeXUpdatePreviewFromPICT(pictName,fileExtension)

	LaTeXEnableButtons()
	LaTeXUpdatePICTWindowList()
End

Static Function LaTeXUpdatePreviewFromPICT(pictName, fileExtension)
	String pictName
	String fileExtension	// ".png", ".pdf", or ".emf"
	
	if( LaTeXIsNew(pictName) || !LaTeXPICTExists(pictName) )
		LaTeXPreviewMessage("")
	else
		// No: this overwrites the clipboard
		//	SavePICT/PICT=$pictName as "Clipboard"
		//	LoadPICT/O/Q "Clipboard", $ksPreviewPictName
		// This requires Igor 6.23
#if IgorVersion() >= 6.23
		SavePICT/O/PICT=$pictName/P=_PictGallery_ as ksPreviewPictName
#else
		// use a temp file
		String fileName= "LaTeXIgorPreview"+fileExtension
		String localPath = SpecialDirPath("Temporary", 0, 0, 0) +fileName
		SavePICT/O/PICT=$pictName as localPath
		LoadPICT/Q/O localPath, $ksPreviewPictName	// overwrites given name
#endif
	endif
End

Static Function LaTeXFromTargetCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	LaTeXUpdatePicturesList(checked)
End

static Function ParseLaTeXForInsert(LaTeX, escapeChar, beforeEscape, escapedSelection, afterEscape)	// outputs
	String LaTeX, escapeChar	// inputs
	String &beforeEscape, &escapedSelection, &afterEscape		// outputs, all will be "" if no escape char is found.

	beforeEscape=""
	escapedSelection=""
	afterEscape=""
	// search LaTeX for <escapeChar> <stuff to replace> <escapeChar>
	Variable startPos= strsearch(LaTeX, escapeChar,0,0)
	Variable foundEscape= startPos >= 0 
	if( foundEscape)
		beforeEscape= LaTeX[0, startPos-1]
		Variable endPos= strsearch(LaTeX, escapeChar,Inf,1)	// search backwards from end
		Variable escapeLen= strlen(escapeChar)	// could be multi-char
		endPos += escapeLen
		escapedSelection= LaTeX[startPos, endPos-1]
		escapedSelection= replaceString(escapeChar, escapedSelection, "")
		afterEscape= LaTeX[endPos, strlen(LaTeX)-1]
	endif
	return foundEscape
End

// The goal of this function is to rewrite the selected text.
// Either replace it all with the LaTeX, or insert the selection within the LaTeX
// if the LaTeX has escape characters which delimit where the selection is to be used.
Static Function/S RewriteLaTex(LaTeX,selectedText,escapeChar)
	String LaTeX,selectedText,escapeChar
	
	String before, selection, after	// outputs from ParseLaTeXForInsert()
	Variable foundEscape= ParseLaTeXForInsert(LaTeX, escapeChar, before, selection, after)

	String rewritten
	if( foundEscape )
		rewritten= before
		if( strlen(selectedText) )
			rewritten += selectedText
		else
			rewritten += selection
		endif
		rewritten += after
	else
		rewritten= LaTeX
	endif
	return rewritten
End


// this must match the prototype of
// static Function LaTeXInsertProtoFunc(insertThis, escapeChar[, isUndo])
Static Function/S LaTeXInsert(insertThis, escapeChar[, isUndo])
	String insertThis	// LaTeX text, such as "\frac{#a#}{b}" or "\bullet"
	String escapeChar	// if "#", then something like #abc# is replaced by the LaTeX editor's current selection.
	Variable isUndo
	
	DoWindow $ksPanelName
	if( V_Flag == 0 )	// JP120229
		return ""
	endif
	
	if( ParamIsDefault(isUndo) )
		isUnDo= 0
	endif

	String oldLaTeX= LaTeXGetNotebookText()

	if( isUnDo )
		LaTeXSetNotebookText(insertThis)
	else
		if( LaTexIsInitialText() && strlen(insertThis) )
			LaTeXSetNotebookText("")
		endif
		// Rewrite the existing text based on the selection.
		// If anything is selected, that's copied and replaces the anything between escapeChar chars in insertThis
		// Version 2.1: Insertion of text that doesn't end with } gets a space appended to avoid illegal equations.
		String withoutRBrace= RemoveEnding(insertThis,"}")
		if( CmpStr(withoutRBrace, insertThis) == 0 )	// then it DID NOT end with right brace
			insertThis += " "		// so that inserting "\bullet" before, say, "x", isn't interpreted as "\bulletx".
		endif
		GetSelection notebook, $ksNotebookName, 1+2
		String selectedText="", rewritten
		Variable hadSelection= V_Flag
		if( hadSelection )	// true even if no chars are selected (if there's just a selection position)
			Variable old_startParagraph= V_startParagraph
			Variable old_V_startPos= V_startPos
			Variable old_V_endParagraph= V_endParagraph
			Variable old_V_endPos= V_endPos
			selectedText= S_selection
			rewritten= RewriteLaTex(insertThis,selectedText,escapeChar)
			Notebook $ksNotebookName, text=rewritten	
		else
			// append
			rewritten= RewriteLaTex(insertThis,"",escapeChar)
			Notebook $ksNotebookName selection={endOfFile, endOfFile}, text=rewritten	
			Notebook $ksNotebookName selection={endOfFile, endOfFile}, findText={"", 1}	
		endif
	endif
	// try to re-establish focus to the panel (not any floating palette)
	DoWindow/F $ksPanelName
	
	LaTeXPossiblyUpdatePicture()
	LaTeXEnableButtons()

	return oldLaTeX	// for Undo, someday
End

Static Function/S LaTeXGetNotebookText()

	GetSelection notebook, $ksNotebookName, 1	// keep current selection
	Variable hadSelection= V_Flag
	if( hadSelection )
		Variable old_startParagraph= V_startParagraph
		Variable old_V_startPos= V_startPos
		Variable old_V_endParagraph= V_endParagraph
		Variable old_V_endPos= V_endPos
	endif
	Notebook $ksNotebookName selection={startOfFile, endOfFile}
	GetSelection notebook, $ksNotebookName, 2
	if( hadSelection )
		Notebook $ksNotebookName selection={(old_startParagraph,old_V_startPos), (old_V_endParagraph,old_V_endPos)}
	endif
	return S_Selection
End

Static Function/S LaTeXSetNotebookText(LaTeX)
	String LaTeX
	
	String oldLaTeX=  LaTeXGetNotebookText()
	Notebook $ksNotebookName selection={startOfFile, endOfFile}, text=LaTeX	
	Notebook $ksNotebookName selection={startOfFile, startOfFile}, findText={"", 1}	
	return oldLaTeX
End

Static Function LaTeXPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr	// new popup value, can be "_new_"
	
	// save the previous popup's LaTeX
	String previousName= StrVarOrDefault("root:Packages:LaTeXPictures:previousLaTeXPicture","")	// can be _new_, also!
	if( CmpStr(previousName,popStr) != 0 )
		LaTeXRememberControlSettings(previousName)
		// restore by name
		LaTeXSetControlsByName(popStr)
		String/G root:Packages:LaTeXPictures:previousLaTeXPicture = popStr	// can be "_new_"
	endif
End

#include <CustomControl Definitions>

Static Function LaTeXLinkcontrolproc(s)
	struct WMCustomControlAction &s
	
	switch(s.eventCode)
		case kCCE_mouseup:	// Mouse up in control.
			//Print "s.sVal= \""+s.sVal+"\""
			BrowseURL(s.sVal)
			break
	endswitch
	
	return 0
End

Static Function LaTeXEnableButtons()

	ControlInfo/W=$ksPanelName LaTeXPictures
	String pictName= S_Value
	Variable isNew= 	LaTeXIsNew(pictName)

	String LaTeX= LaTeXGetNotebookText()
	Variable disable= strlen(LaTeX) ? 0 : 2
	ModifyControl/Z update, win=$ksPanelName, disable=disable

	if( disable == 0 )
		if( isNew )
			disable= 2	// user needs to click Update Picture to generate a persistent PICT name
		endif
	endif

	String windowName= LaTeXTargetWindow()
	if( disable == 0 )
		if( strlen(windowName) == 0  )
			disable= 2	// no place to put the pict
		endif
	endif
	ModifyControlList/Z "newDrawPICT;" , win=$ksPanelName, disable=disable
	
	if( disable == 0 && strlen(windowName) && WinType(windowName) == 7  )
		disable= 2	// annotations aren't allowed in panels
	endif
	ModifyControl/Z newAnnotation, win=$ksPanelName, disable=disable
	
	disable= LaTeXIsNew(pictName) ? 2 : 0
	if( disable == 0 )
		String windows= LaTeXWindowsUsingPICT(S_value)
		disable= strlen(windows) ? 2 : 0
	endif
	ModifyControl/Z delete, win=$ksPanelName, disable=disable
	
	// show/hide the background color
	ControlInfo/W=$ksPanelName transparent
	disable= V_Value ? 1 : 0
	ModifyControl/Z backgroundColor, win=$ksPanelName, disable=disable
	
	// Shrink is appropriate for only PNG
	LaTexEnableDisableShrink()
End

Static Function LaTeXNewAnnotationButtonProc(ctrlName) : ButtonControl
	String ctrlName

	ControlInfo/W=$ksPanelName LaTeXPictures
	String pictName= S_Value
	String windowName= LaTeXTargetWindow()

	if( (!LaTeXIsNew(pictName)) && strlen(pictName) && strlen(windowName) )
		Variable type= WinType(windowName)
		switch (type)
			case 1:	// graph
			case 3:	// layout
				TextBox/W=$windowName "\\$PICT$name="+pictName+"$/PICT$"
				LaTeXUpdatePICTWindowList()
				break
			default:
				Beep
		endswitch
	else
		Beep
	endif
End

Static Function LaTeXNewDrawPICTButtonProc(ctrlName) : ButtonControl
	String ctrlName

	ControlInfo/W=$ksPanelName LaTeXPictures
	String pictName= S_Value
	String windowName= LaTeXTargetWindow()

	if( (!LaTeXIsNew(pictName)) && strlen(pictName) && strlen(windowName) )
		Variable type= WinType(windowName)
		switch (type)
			case 1:	// graph
			case 3:	// layout
			case 7:	// Panel
				ControlInfo/W=$ksPanelName pictScale
				Variable scale= V_Value > 1 ? (1/V_Value) : 1
				SetDrawEnv/W=$windowName xcoord=rel, ycoord=rel
				DrawPICT/W=$windowName 0.1,0.1,scale,scale, $pictName
				ShowTools/A/W=$windowName arrow	// turn drawing mode on, since the pict WILL be in the wrong place.
				LaTeXUpdatePICTWindowList()
				break
			default:
				Beep
		endswitch
	else
		Beep
	endif
End

Static Function LaTeXPicturesButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DoIgorMenu "Misc","Pictures"
End

Static Function LaTeXDeleteButtonProc(ctrlName) : ButtonControl
	String ctrlName

	ControlInfo/W=$ksPanelName LaTeXPictures
	String pictName= S_Value
	Variable isNew= LaTeXIsNew(pictName)
	if( isNew )
		Beep
	else
		KillPICTs/Z $pictName
		LaTeXUpdatePanelForActivate()
	endif
End

Static Function LaTeXPossiblyUpdatePicture()

	Variable didUpdate=LaTexWantAutoUpdate() && !LaTexIsInitialText()
	if( didUpdate )
		LaTexUpdatePICTFromControls()
	endif
	return didUpdate
End

Static Function LaTexUpdatePICTFromControls()

	LaTeXUpdateLaTeXPICT()
	LaTeXUpdatePICTWindowList()
	LaTeXEnableButtons()
End

Static Function LaTeXUpdateButtonProc(ctrlName) : ButtonControl
	String ctrlName

	LaTexUpdatePICTFromControls()
End

Static Function LaTexExamplePopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String exampleText
	strswitch(popStr)
		case "Quadratic":
			exampleText= "\\mathbf{x=\\frac{-b\\pm\\sqrt{b^2-4ac}}{2a}}"
			break
		case "Quadratic Bold Text":
			exampleText= "\\mathbf{x=\\frac{-b\\pm\\sqrt{b^2-4ac}}{2a}}"
			exampleText= "\\mathbf{"+exampleText+"}"	// enclose in math bold face
			break
		case "3x3 Matrix":
			exampleText = "\\begin{pmatrix}"+"\r"
			exampleText += "a_{11} & a_{12}  & a_{13} \\\\ "+"\r"
			exampleText += "a_{21} & a_{22}  & a_{23} \\\\ "+"\r"
			exampleText += "a_{31} & a_{32} & a_{33}"+"\r"
			exampleText += "\\end{pmatrix}"
			break
		default:
			exampleText= ""
			break
	endswitch
	
	Notebook $ksNotebookName selection={startOfFile, endOfFile}, text=exampleText
	LaTeXPossiblyUpdatePicture()
	LaTeXEnableButtons()
End

Static Function LaTeXHelpButtonProc(ctrlName) : ButtonControl
	String ctrlName

	BrowseURL("http://en.wikipedia.org/wiki/Help:Formula")
End

static Function LaTeXColorPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	LaTeXPossiblyUpdatePicture()
End

static Function LaTexTransparentCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	if( !LaTeXPossiblyUpdatePicture() )
		LaTeXEnableButtons()	// show/hide the background color
	endif
End

static Function LaTeXFontPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	LaTeXPossiblyUpdatePicture()
End

static Function LaTeXSizePopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	LaTeXPossiblyUpdatePicture()
End

static Function LaTexEnableDisableShrink()

	ControlInfo/W=$ksPanelName format
	Variable isPNG= CmpStr(S_Value,"PNG") == 0
	if( isPNG )
		SetVariable pictScale, win=$ksPanelName,variable=root:Packages:LaTeXPictures:pictScale
	else
		SetVariable pictScale, win=$ksPanelName, value= _NUM:1
	endif
End

static Function LaTeXFormatPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	LaTexEnableDisableShrink()
	LaTeXPossiblyUpdatePicture()
End

static Function LaTeXDPISetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	LaTeXPossiblyUpdatePicture()
End

static Function LaTeXInlineCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	LaTeXPossiblyUpdatePicture()
End

static Function/S PaletteList()

	String list=LaTeXPalettes#Categories()
	
	if( CmpStr(list,"_none_;") == 0 )
		list= "Load Palettes"
	endif
	return list
End

static Function PalettesPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	strswitch(popStr)
		case "Load Palettes":
			LaTeXPalettes#LoadLaTeXPalettes()
			Variable numPalettes= ItemsInList(LaTeXPalettes#Categories())
			DoAlert 0, "Loaded "+num2istr(numPalettes)+" LaTeX palettes. Click the popup again to display that palette. Click in the palette to insert LaTeX text."
			break
		default:
			LaTeXPalettes#ShowLaTeXPalette(popStr)
			break
	endswitch
End

