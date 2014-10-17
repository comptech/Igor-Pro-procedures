#pragma rtGlobals=1		// Use modern global access method.
#pragma IgorVersion=6.2
#pragma moduleName=LaTeXPalettes
#pragma version=2.2

// Version 2.2: restored palette's readout of the LaTeX lost in 2.1.
// Version 2.1: can now be installed In Igor Pro Folder:User Procedures,
// and the Palette Creator doesn't insert text into the LaTeX Pictures panel's notebook subwindow.

#include <Resize Controls>

Menu "LaTeX"
	"Create LaTeX Palettes",/Q, ShowLaTeXPaletteCreator()
End

// Data Organization:
//
// A data folder full of palette waves, each one contains LaTex related to one category,
// and the name of the category is the wave's note
// The palette wave is a text wave, where:

// all rows, all cols, layer 0,= image data, (special mode 3)
// all rows, all cols, layer 1, = LaTeX command, with an extra '#' character which is where selected text is inserted.

Static StrConstant ksPanelName= "LaTeXPaletteCreator"
Static StrConstant ksNotebookName= "LaTeXPaletteCreator#LATEX"
Static StrConstant ksPreviewPICTName="CodeCogsEqn_png"
Static StrConstant ksEscapeChar="#"	// something like #abc# is replaced by the LaTeX editor's current selection.

// Create your own palettes of LaTeX codes
Function ShowLaTeXPaletteCreator()

	LaTeXPaletteInit()

	Variable floating=0	// =1 to float.
	DoWindow/K $ksPanelName
	NewPanel /W=(100,59,661,632)/N=$ksPanelName/K=1/FLT=(floating) as "LaTeX Palette Creator"
	ModifyPanel/W=$ksPanelName noEdit=1
	DefaultGuiFont/W=$ksPanelName/Mac popup={"_IgorMedium",12,0},all={"_IgorMedium",12,0}
	DefaultGuiFont/W=$ksPanelName/Win popup={"_IgorMedium",12,0},all={"_IgorMedium",12,0}
	SetDrawLayer/W=$ksPanelName UserBack
	SetDrawEnv/W=$ksPanelName gstart,gname= LaTeXPreviewGroup
	//DrawPICT/W=$ksPanelName 187,94,0.5,0.5,$ksPreviewPICTName
	SetDrawEnv/W=$ksPanelName gstop

	TitleBox LaTeXTitle,pos={25,23},size={39,16},title="LaTeX:"
	TitleBox LaTeXTitle,userdata(ResizeControlsInfo)= A"!!,C,!!#<p!!#>*!!#<8z!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
	TitleBox LaTeXTitle,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	TitleBox LaTeXTitle,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
	TitleBox LaTeXTitle,frame=0,anchor= RC

	PopupMenu scale,pos={468,94},size={82,20},proc=LaTeXPalettes#ScalePopMenuProc,title="Scale"
	PopupMenu scale,userdata(ResizeControlsInfo)= A"!!,IP!!#?u!!#?]!!#<Xz!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
	PopupMenu scale,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	PopupMenu scale,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
	PopupMenu scale,mode=3,popvalue="0.5",value= #"\"0.125;0.25;0.5;1;2;\""

	PopupMenu paletteWavesPop,pos={263,130},size={186,20},proc=LaTeXPalettes#CategoryPopMenuProc,title="Category"
	PopupMenu paletteWavesPop,userdata(ResizeControlsInfo)= A"!!,H>J,hq<!!#AI!!#<Xz!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
	PopupMenu paletteWavesPop,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:DuaHizzzzzzzzzzz"
	PopupMenu paletteWavesPop,userdata(ResizeControlsInfo) += A"zzz!!#u:DuaHizzzzzzzzzzzzzz!!!"
	PopupMenu paletteWavesPop,mode=1,popvalue="Examples",value= #"LaTeXPalettes#Categories()"

	ListBox palette,pos={182,157},size={365,400},proc=LaTeXPalettes#PaletteListBoxProc
	ListBox palette,userdata(ResizeControlsInfo)= A"!!,GF!!#A,!!#BpJ,hsXz!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
	ListBox palette,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:DuaHizzzzzzzzzzz"
	ListBox palette,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"
	ListBox palette,mode= 5
	ListBox palette,special= {3,0,0}

	ControlInfo/W=$ksPanelName paletteWavesPop
	String category= S_Value
	SelectCategory(category)

	Button replaceCell,pos={17,100},size={147,20},proc=LaTeXPalettes#ReplaceCellButtonProc,title="Replace Selected Cell"
	Button replaceCell,userdata(ResizeControlsInfo)= A"!!,BA!!#@,!!#A\"!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
	Button replaceCell,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	Button replaceCell,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

	Button resuse,pos={15,132},size={150,20},proc=LaTeXPalettes#PutThatHereButtonProc,title="Put that\\W623 here\\W617"
	Button resuse,userdata(ResizeControlsInfo)= A"!!,B)!!#@h!!#A%!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
	Button resuse,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	Button resuse,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

	SetVariable StoredLaTeX,pos={21,160},size={150,19},bodyWidth=150
	SetVariable StoredLaTeX,userdata(ResizeControlsInfo)= A"!!,Ba!!#A/!!#A%!!#<Pz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
	SetVariable StoredLaTeX,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	SetVariable StoredLaTeX,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
	SetVariable StoredLaTeX,value= _STR:""

	Button newCategory,pos={41,203},size={102,20},proc=LaTeXPalettes#NewPaletteButtonProc,title="New Category"
	Button newCategory,userdata(ResizeControlsInfo)= A"!!,D3!!#AZ!!#@0!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
	Button newCategory,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	Button newCategory,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

	Button showTable,pos={32,239},size={120,20},proc=LaTeXPalettes#CategoryTableButtonProc,title="Show LaTeX Table"
	Button showTable,userdata(ResizeControlsInfo)= A"!!,Cd!!#B)!!#@T!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
	Button showTable,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	Button showTable,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

	Button RenderAllCells,pos={8,275},size={168,20},proc=LaTeXPalettes#RenderAllCellsButtonProc,title="Render All Cells from Plane 1"
	Button RenderAllCells,userdata(ResizeControlsInfo)= A"!!,@c!!#BCJ,hqb!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
	Button RenderAllCells,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	Button RenderAllCells,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
	Button RenderAllCells,fSize=11

	Button rowsAndColumns,pos={31,311},size={122,20},proc=LaTeXPalettes#RowsAndColumnsProc,title="Rows and Columns"
	Button rowsAndColumns,userdata(ResizeControlsInfo)= A"!!,C\\!!#BUJ,hq.!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
	Button rowsAndColumns,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	Button rowsAndColumns,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

	Button rename,pos={52,347},size={80,20},proc=LaTeXPalettes#RenameCategoryButtonProc,title="Rename..."
	Button rename,userdata(ResizeControlsInfo)= A"!!,D_!!#BgJ,hp/!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
	Button rename,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	Button rename,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

	Button delete,pos={52,384},size={80,20},proc=LaTeXPalettes#DeleteCategoryButtonProc,title="Delete..."
	Button delete,userdata(ResizeControlsInfo)= A"!!,D_!!#C%!!#?Y!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
	Button delete,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	Button delete,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

	Button saveAll,pos={22,458},size={60,20},proc=LaTeXPalettes#SavePalettesButtonProc,title="Save..."
	Button saveAll,userdata(ResizeControlsInfo)= A"!!,Bi!!#CJ!!#?)!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
	Button saveAll,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#AtDKKH1zzzzzzzzzzz"
	Button saveAll,userdata(ResizeControlsInfo) += A"zzz!!#AtDKKH1zzzzzzzzzzzzzz!!!"

	Button loadAll,pos={95,458},size={60,20},proc=LaTeXPalettes#LoadPalettes,title="Load..."
	Button loadAll,userdata(ResizeControlsInfo)= A"!!,F#!!#CJ!!#?)!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
	Button loadAll,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#AtDKKH1zzzzzzzzzzz"
	Button loadAll,userdata(ResizeControlsInfo) += A"zzz!!#AtDKKH1zzzzzzzzzzzzzz!!!"

	Button help,pos={44,536},size={86,20},proc=LaTeXPalettes#ButtonProc,title="LaTex Help"
	Button help,userdata(ResizeControlsInfo)= A"!!,D?!!#Ck!!#?e!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
	Button help,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	Button help,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

	DefineGuide UGV0={FR,-15}
	SetWindow kwTopWin,hook(ResizeControls)=ResizeControls#ResizeControlsHook
	SetWindow kwTopWin,userdata(ResizeControlsInfo)= A"!!*'\"z!!#Cq5QF1_5QCcazzzzzzzzzzzzzzzzzzzz"
	SetWindow kwTopWin,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzzzzzzzz"
	SetWindow kwTopWin,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzz!!!"
	SetWindow kwTopWin,userdata(ResizeControlsGuides)=  "UGV0;"
	SetWindow kwTopWin,userdata(ResizeControlsInfoUGV0)= A":-hTC3`S[N0KW?-:-)'W<+T0.@;KLsFCdg[ART\\!E][6':dmEFF(KAR85E,T>#.mm5tj<n4&A^O8Q88W:-(6h2EOE/8OQ!%3_!\"/7o`,K75?nc;FO8U:K'ha8P`)B/MT+E"
	NewNotebook /F=0 /N=LaTeX /W=(73,8,421,81)/FG=(,,UGV0,) /HOST=# 
	Notebook kwTopWin, defaultTab=20, statusWidth=0, autoSave=1
	Notebook kwTopWin font="Geneva", fSize=10, fStyle=0, textRGB=(0,0,0)
	Notebook kwTopWin, zdata= "GaqDU%ejN7!Z)%D?tAb<=R'hO`]tdL!6<Ul\\,"
	Notebook kwTopWin, zdataEnd= 1
	RenameWindow #,LaTeX
	SetActiveSubwindow ##
	if (floating)
		SetActiveSubwindow _endfloat_
	endif
End

static Function LaTeXPaletteInit()

	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:LaTeXPictures
	NewDataFolder/O root:Packages:LaTeXPictures:palettes
	String palettes=Categories()
	if( CmpStr(palettes,"_none_;") == 0 )
		LoadLaTeXPalettes()
	endif
End

static Function/S NameForPalette(category)
	String category
	
	String panelName=""
	WAVE/T/Z tw= CategoryWavePath(category)
	if( WaveExists(tw) )
		panelName= "LaTeXPal"+NameOfWave(tw)
		panelName= CleanupName(panelName,0)
	endif

	return panelName	// for floating palette
End

static Function/WAVE MatchingSelectionWave(tw)
	Wave/T tw
	
	Variable nrows= DimSize(tw,0), ncols= DimSize(tw,1)
	DFREF dfr= GetWavesDataFolderDFR(tw)
	String twSelName= CleanupName(NameOfWave(tw)+"Sel",1)
	Make/O/N=(nrows,ncols) dfr:$twSelName/WAVE=twSel
	twSel= 0
	return twSel
End

static Function ShowLaTeXPalette(category)
	String category
	
	String panelName= NameForPalette(category)
	if( strlen(panelName) )
		DoWindow/F $panelName
		if( V_Flag == 0 )
			WAVE/T tw= CategoryWavePath(category)
			if( WaveExists(tw) )
				// create a resizable floating palette
				WAVE twSel= MatchingSelectionWave(tw)
				Variable floating=1// 0 for non-floating,1 for floating
				NewPanel/N=$panelName/K=1/FLT=(floating)/W=(746,159,1017,414) as category
				ModifyPanel/W=$panelName fixedSize=0

				ListBox palette,win=$panelName,pos={5,5},size={260,223},proc=LaTeXPalettes#PaletteListBoxProc
				ListBox palette,win=$panelName,mode= 5,special= {3,0,0}
				ListBox palette,win=$panelName, listWave=tw, selWave=twSel
				ListBox palette,userdata(ResizeControlsInfo)= A"!!,?X!!#9W!!#B<!!#Anz!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
				ListBox palette,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
				ListBox palette,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"
			
				SetVariable StoredLaTeX,pos={8,235},size={239,15},bodyWidth=239
				SetVariable StoredLaTeX,userdata(ResizeControlsInfo)= A"!!,@c!!#B%!!#B)!!#<(z!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
				SetVariable StoredLaTeX,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
				SetVariable StoredLaTeX,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"
				SetVariable StoredLaTeX,frame=0,value= _STR:""
			
				SetWindow kwTopWin,hook(ResizeControls)=ResizeControls#ResizeControlsHook
				SetWindow kwTopWin,userdata(ResizeControlsInfo)= A"!!*'\"z!!#BAJ,hrdzzzzzzzzzzzzzzzzzzzzz"
				SetWindow kwTopWin,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzzzzzzzz"
				SetWindow kwTopWin,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzz!!!"
				if (floating)
					SetActiveSubwindow _endfloat_
				endif
				AutoPositionWindow/E $panelName
			endif
		endif
	endif
End	

// Set the actual LaTex Equation Notebook selection to LaTeX
// or to a variant stripped of its arguments

Function/S LaTeXInsertProtoFunc(insertThis, escapeChar[, isUndo])
	String insertThis	// LaTeX text, such as "\frac{#a#}{b}"
	String escapeChar	// if "#", then something like #abc# is replaced by the LaTeX editor's current selection.
	Variable isUndo

	// TO DO: implement undo locally by saving and returning the previous values sent here
//	print "in LaTeXInsertProtoFunc with insertThis= ",insertThis
	return insertThis
End

static Function/S LaTeXInsert(win,LaTeX)
	String win,LaTeX

	// 2.2: restored palette's readout of the LaTeX
	ControlInfo/W=$win StoredLaTeX
	if( V_flag )
		SetVariable StoredLaTeX,win=$win,value= _STR:LaTex
	endif
	FUNCREF LaTeXInsertProtoFunc fr = $"LaTeXPictures#LaTeXInsert"	// #include "LaTeX Pictures"

	return fr(LaTeX,ksEscapeChar)	// someday the returned undo text might be used for undo!
End

static Function/S LaTeXInsertIntoCreator(win,LaTeX)
	String win,LaTeX

	String undoThis=""
	ControlInfo/W=$win StoredLaTeX
	if( V_flag )
		undoThis=S_Value
		SetVariable StoredLaTeX,win=$win,value= _STR:LaTex
	endif
	
	return undoThis
End

static Function NewPaletteButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	String category= NewPalette()
	if( strlen(category) )
		KillAllCategoryTables(category)	// that is, all but this category
		CategoryTable(category)
	endif
End

// returns the category name, or ""
static Function/S NewPalette()

	String category
	Variable rows=8, cols=4
	Prompt category, "New Category"
	Prompt rows, "rows"
	Prompt cols, "columns"
	DoPrompt "New LaTeX Palette", category, rows, cols
	if( V_flag != 0 )
		return ""
	endif
	WAVE/T/Z tw= CategoryWavePath(category)
	if( WaveExists(tw) )
		DoAlert 0, "Category "+category+" already exists!"
		SelectCategory(category)
		category= ""
	else
		String wName= CleanupName(category,0)
		String oldDF= GetDataFolder(1)
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:LaTeXPictures
		NewDataFolder/O/S root:Packages:LaTeXPictures:palettes
		if( WaveExists($"wName") )
			wName= UniqueName(wName, 1, 0)
		endif
		WAVE/T/Z tw= CreatePaletteWave(wName, category, rows, cols)
		SelectCategory(category)
		SetDataFolder oldDF
	endif
	return category
End

static Function RenameCurrentCategory()

	ControlInfo/W=$ksPanelName paletteWavesPop
	String category= S_Value
	WAVE/T/Z tw= CategoryWavePath(category)

	if( !WaveExists(tw) )
		Beep
		return 0
	endif

	String oldCategoryName= category
	
	Prompt category, "Change category name"
	DoPrompt "Rename Category "+oldCategoryName, category
	if( V_flag != 0 )
		return 0
	endif
	if( RenameCategory(oldCategoryName,category) )
		SelectCategory(category)
	endif
End

static Function RenameCategory(oldCategoryName,newCategoryName)
	String oldCategoryName,newCategoryName

	WAVE/T/Z tw= CategoryWavePath(oldCategoryName)
	if( !WaveExists(tw) )
		Beep
		return 0
	endif
	
	// The wave's note is the category name
	Note/K tw, newCategoryName
	
	// try to use the same name for the wave
	String newName= CleanupName(newCategoryName,0)
	String oldDF= GetDataFolder(1)
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:LaTeXPictures
	NewDataFolder/O/S root:Packages:LaTeXPictures:palettes
	Wave/Z conflictingWave= $newName
	if( WaveExists(conflictingWave) )
		newName= UniqueName(newName, 1, 0)
	endif
	Rename tw, $newName
	SetDataFolder oldDF
	return 1	// success
End

static Function DeleteCurrentCategory()

	ControlInfo/W=$ksPanelName paletteWavesPop
	String category= S_Value
	Variable mode= V_Value
	WAVE/T/Z tw= CategoryWavePath(category)

	if( !WaveExists(tw) )
		Beep
		return 0
	endif
	DoAlert 1, "Really delete the "+category+" palette?"
	if( V_Flag == 1 )
		if( DeleteCategory(category) )
			String list= Categories()
			Variable numCategories= ItemsInList(list)
			if( numCategories && (mode > numCategories) )
				mode= numCategories
			endif
			category= StringFromList(mode-1, list)
			SelectCategory(category)
		endif
	endif
End

static Function KillAllCategoryTables(exceptThisCategory)
	String exceptThisCategory	// pass "" to kill them all.

	String list= Categories()
	Variable i, n= ItemsInList(list)
	for(i=0; i<n; i+=1 )
		String category= StringFromList(i,list)
		if( CmpStr(exceptThisCategory,category) != 0 ) 
			KillCategoryTables(category)
		endif
	endfor
End


static Function KillCategoryTables(category)
	String category

	WAVE/T/Z tw= CategoryWavePath(category)
	if( !WaveExists(tw) )
		return 0
	endif
	// it may be in a table
	do
		String table= FindTableWithWave(tw)
		if( strlen(table) == 0 )
			break
		endif
		KillWindow $table
	while(1)
	return 1
End

static Function DeleteCategory(category)
	String category

	WAVE/T/Z tw= CategoryWavePath(category)
	if( !WaveExists(tw) )
		return 0
	endif
	// it may be in a table
	KillCategoryTables(category)
	KillWaves/Z tw
	return 1
End

static Function/WAVE CreatePaletteWave(wName, category, rows, cols [,LaTeXList])
	String wName, category
	Variable rows, cols
	String LaTeXList	// optional
	
	String oldDF= GetDataFolder(1)
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:LaTeXPictures
	NewDataFolder/O/S root:Packages:LaTeXPictures:palettes
	
	Make/T/O/N=(rows,cols,2) $wName 
	Wave/T/Z tw= $wName
	// assign dimension labels to layers
	SetDimLabel 2, 0, pict, tw
	SetDimLabel 2, 1, LaTeX, tw

	// The wave's note is the category name
	Note/K tw, category

	if( !ParamIsDefault(LaTeXList) )
		tw[][][1]=StringFromList(p*cols+q,LaTeXList)	// fills left-to-right, then top to bottom in the listbox
	endif
	
	SetDataFolder oldDF
	
	return tw
End

static Function RowsAndColumnsProc(ctrlName) : ButtonControl
	String ctrlName

	Wave/T/Z tw= SelectedPaletteWave()
	if( WaveExists(tw) )
		Variable rows= DimSize(tw,0)
		Variable cols= DimSize(tw,1)
	
		Prompt rows, "new rows"
		Prompt cols, "new columns"
		String category= note(tw)
		DoPrompt "Change Rows and Columns for "+category, rows, cols
		if( V_flag != 0 )
			return 0
		endif
		ReshapeCategoryWave(tw,rows,cols)
		SelectCategory(category)	// redimensions the selection wave
	else
		Beep
	endif
End

static Function ReshapeCategoryWave(tw, rows, cols)
	Wave/T tw
	Variable rows, cols
	
	Variable oldRows= DimSize(tw,0)
	Variable oldCols= DimSize(tw,1)
	
	Variable row, col

	Variable useRedimension= rows >= oldRows && cols >= oldCols	// no data will be lost
	if( !useRedimension )
		// (A better algorithm would find the last used row and the last used column
		// and see if truncation is non-destructive.)
		// see if the to-be lost rows or columns actually contain any data
		Variable haveData= 0
		// Check all columns of lost rows (if any)
		for(row= rows; (row < oldRows) && !haveData; row+=1)
			for( col= 0; col < oldCols; col+=1 )
				if( strlen(tw[row][col][1]) )
					haveData= 1
					break
				endif
			endfor
		endfor
		// Check remaining rows of lost columns (if any)
		if( !haveData )
			for( col= cols; col < oldCols; col+=1 )
				for(row= 0; (row < rows) && !haveData; row+=1)
					if( strlen(tw[row][col][1]) )
						haveData= 1
						break
					endif
				endfor
			endfor
		endif
		if( !haveData )
			useRedimension= 1
		endif
	endif
	if( useRedimension )
		Redimension/N=(rows,cols,-1) tw
	else
		String category= note(tw)
		WAVE/T temp= CreatePaletteWave("temp", category, rows, cols)
		Variable pointNum, n= rows*cols
		// fill in row-major order
		for( pointNum= 0; pointNum < n; pointNum+=1 )
			Variable oldCol = mod(pointNum, oldCols)
			Variable oldRow= floor(pointNum/oldCols)
			Variable newCol = mod(pointNum, cols)
			Variable newRow= floor(pointNum/cols)
			temp[newRow][newCol][] = tw[oldRow][oldCol][r]
		endfor
		Duplicate/O/T temp, tw
		KillWaves/Z temp
	endif	
End

static Function SelectCategory(category)
	String category
	
	WAVE/T/Z tw= CategoryWavePath(category)
	if( WaveExists(tw) )
		Variable nrows= DimSize(tw,0), ncols= DimSize(tw,1)
		Make/O/N=(nrows,ncols) root:Packages:LaTeXPictures:Palettes:twSel=0
		WAVE twSel= root:Packages:LaTeXPictures:Palettes:twSel
		ListBox palette,win=$ksPanelName, listWave=tw, selWave=twSel
		PopupMenu paletteWavesPop, win=$ksPanelName, popMatch=category
	endif
End

static Function/WAVE CategoryWavePath(category)
	String category
	
	WAVE/T/Z tw=$""
	if( DataFolderExists("root:Packages:LaTeXPictures:Palettes") )
		String oldDF= GetDataFolder(1)
		SetDataFolder root:Packages:LaTeXPictures:Palettes
		Variable i=0
		do
			WAVE/T/Z tw= WaveRefIndexed("",i,4)
			if( !WaveExists(tw) )
				break
			endif
			String nt= note(tw)
			if( CmpStr(nt, category) == 0 )
				SetDataFolder oldDF
				return tw
			endif
			i += 1
		while(1)
		SetDataFolder oldDF
	endif
	return tw		// NULL, always assign with WAVE/T/Z tw=CategoryWavePath(category)
End

static Function/S Categories()

	String list=""
	if( DataFolderExists("root:Packages:LaTeXPictures:Palettes") )
		String oldDF= GetDataFolder(1)
		SetDataFolder root:Packages:LaTeXPictures:Palettes
		Variable i=0
		do
			WAVE/T/Z tw= WaveRefIndexed("",i,4)
			if( !WaveExists(tw) )
				break
			endif
			String nt= note(tw)
			if( strlen(nt) )
				list += nt+";"
			endif
			i += 1
		while(1)
		SetDataFolder oldDF
	endif
	if( strlen(list) == 0 )
		list= "_none_"
	endif
	return SortList(list)
End

static Function/WAVE SelectedPaletteWave()

	ControlInfo/W=$ksPanelName paletteWavesPop
	String category= S_Value
	WAVE/T/Z tw= CategoryWavePath(category)

	return tw
End


static Function CategoryPopMenuProc(ctrlName,popNum,category) : PopupMenuControl
	String ctrlName
	Variable popNum
	String category

	SelectCategory(category)
End

static Function LaTeXSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	// dynamic update with varStr

End

//returns the row
static Function FindFirstEmptyCell(col)
	Variable &col	// col is an OUTPUT

	Wave/T/Z tw= SelectedPaletteWave()
	Variable plane= 1
	Variable row, nrows= DimSize(tw,0), ncols= DimSize(tw,1)
	for( row= 0; row < nrows; row+=1)
		for( col=0; col<ncols; col+=1 )
			if( strlen(tw[row][col][plane]) < 10 )
				return row
			endif
		endfor
	endfor
	
	if( row >= nrows )
		row= -1	// no empty cells
		col= -1
	endif
	return row
End

// returns selected row in the palette creator panel (not a floating palette)
static Function GetSelectedCell(col)
	Variable &col	// col is an OUTPUT

	Wave/T/Z tw= SelectedPaletteWave()
	Wave/Z sw= root:Packages:LaTeXPictures:Palettes:twSel	// shared

	Variable plane= 0
	Variable row, nrows= DimSize(sw,0), ncols= DimSize(sw,1)
	for( row= 0; row < nrows; row+=1)
		for( col=0; col<ncols; col+=1 )
			Variable v= sw[row][col][plane]
			if( v & 0x1 )
				return row
			endif
		endfor
	endfor
	
	col= -1
	return -1	// no selection
End


// Find topmost table containing given wave
//	returns zero length string if not found
//
static Function/S FindTableWithWave(w)
	wave w
	
	string win=""
	variable i=0
	
	do
		win=WinName(i, 2)				// name of ith table window
		if( strlen(win) == 0 )
			break;						// no more table windows
		endif
		CheckDisplayed/W=$win  w
		if(V_Flag)
			break
		endif
		i += 1
	while(1)
	return win
end

static Function CategoryTable(category)
	String category
	
	WAVE/T/Z tw= CategoryWavePath(category)
	if( WaveExists(tw) )
		String table= FindTableWithWave(tw)
		if( strlen(table) == 0 )
			Edit/K=1 tw
			table= S_Name
			Execute "ModifyTable/Z elements=(-2,-3,1)"
			AutoPositionWindow/R=$ksPanelName $table
		else
			DoWindow/F $table
		endif
	endif
End


static Function CategoryTableButtonProc(ctrlName) : ButtonControl
	String ctrlName

	ControlInfo/W=$ksPanelName paletteWavesPop
	String category= S_Value
	KillAllCategoryTables(category)	// that is, all but this category
	CategoryTable(category)
End


static Function ButtonProc(ctrlName) : ButtonControl
	String ctrlName

	BrowseURL "http://en.wikipedia.org/wiki/Help:Formula#Functions.2C_symbols.2C_special_characters"
End

static Function ReplaceCellButtonProc(ctrlName) : ButtonControl
	String ctrlName

 	String LaTeX= LaTeXGetNotebookText()

	Variable col, row= GetSelectedCell(col)
	if( row<0 )	// no selection, then append
		row= FindFirstEmptyCell(col)	// col is an OUTPUT
	endif
	if( row >= 0 )
		Wave/T/Z tw= SelectedPaletteWave()
		String cleanedLaTeX= ReplaceString("#",LaTeX, "")	// remove the insertion character for rendering the preview
		String str= Download(cleanedLaTeX)
		tw[row][col][0]= str
		tw[row][col][1]= LaTeX
		ControlUpdate/W=$ksPanelName palette
	else
		Beep	// to do: error string that no cell is selected
	endif
End

static Function RenderAllCellsButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Wave/T/Z tw= SelectedPaletteWave()
	Variable plane= 1
	Variable row, nrows= DimSize(tw,0)
	Variable col, ncols= DimSize(tw,1)
	String emptyPicture= StrVarOrDefault("root:Packages:LaTeXPictures:palettes:emptyPictureAsString","")

	for( row= 0; row < nrows; row+=1)
		for( col=0; col<ncols; col+=1 )
			String LaTeX= tw[row][col][1]
			String pictureAsString="" 
			if( strlen(LaTeX) == 0 )
				LaTeX= "\\;"	// so the selection is visible
				// don't repeatedly render a blank space.
				if( strlen(emptyPicture) == 0 )
					emptyPicture= Download(LaTeX)
					String/G root:Packages:LaTeXPictures:palettes:emptyPictureAsString= emptyPicture
				endif
				pictureAsString=emptyPicture
			else
				LaTeX= ReplaceString("#",LaTeX, "")	// remove the insertion character
				pictureAsString= Download(LaTeX)
			endif
			tw[row][col][0]= pictureAsString
		endfor
	endfor
	ControlUpdate/W=$ksPanelName palette
End

Static Function PaletteListBoxProc(lba) : ListBoxControl
	STRUCT WMListboxAction &lba

	Variable row = lba.row
	Variable col = lba.col
	WAVE/T/Z listWave = lba.listWave
	WAVE/Z selWave = lba.selWave

	switch( lba.eventCode )
		case -1: // control being killed
			break
		case 1: // mouse down
			break
		case 3: // double click
			break
		case 4: // cell selection
		case 5: // cell selection plus shift key
			String LaTeX= listWave[row][col][1]	// LaTex
			if( CmpStr(lba.win, ksPanelName) == 0 )
				LaTeXInsertIntoCreator(lba.win,LaTeX)
			else
				LaTeXInsert(lba.win,LaTeX)
			endif
			break
		case 6: // begin edit
			break
		case 7: // finish edit
			break
		case 13: // checkbox clicked (Igor 6.2 or later)
			break
	endswitch

	return 0
End




// returns the content of the downloaded PNG as a string for use with
// Listbox palette special={3,0,0 }
static Function/S Download(LaTeX)
	String LaTeX
	
	String pictAsString=""

	String format="\huge&space;"

#ifdef MACINTOSH
	Variable gray=0.916548
#else
	Variable gray=0.96862
#endif
	String grayStr
	sprintf grayStr, "%f,%f,%f", gray,gray,gray

	format += "\bg_white&space;\pagecolor[rgb]{"+grayStr+"}&space;"
 	
	String formula = replacestring(" ", LaTeX, "&space;")
	formula= replacestring("\r", formula, "")
	formula= replacestring("\n", formula, "")

	String url = "http://latex.codecogs.com/png.download?" + format+formula
//Print url	// compare to: http://latex.codecogs.com/png.download?\huge&space;\begin{matrix}&space;a&space;&&space;b&space;&&space;c&space;\\&space;x&space;&&space;y&space;&&space;z&space;\end{matrix}
	String imageBytes = FetchURL(url)	// Get the image
	Variable error = GetRTError(1)
	if (error != 0)
		DoAlert 0, "Error downloading image from: "+url
		return ""
	else
		// Save PNG to disk
		Variable refNum
		String fileName= "LaTeXIgor"
		String extension= ".png"
		String localPath = SpecialDirPath("Temporary", 0, 0, 0) +fileName+extension
		Open/T=(extension) refNum as localPath
		FBinWrite refNum, imageBytes
		Close refNum
		
		// now try loading the png as a picture
		LoadPICT/Q/O localPath, $ksPreviewPICTName	// overwrites given name
		//SavePICT/PICT=$ksPreviewPICTName as "_string_"
		pictAsString= imageBytes// S_Value
		UpdatePreviewPICT()
	endif
	
	return pictAsString	
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

static Function PutThatHereButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	// from SetVariable StoredLaTeX
	ControlInfo/W=$ksPanelName StoredLaTeX
	
	// to the notebook subwindow
	 LaTeXSetNotebookText(S_Value)
End

static Function RenameCategoryButtonProc(ctrlName) : ButtonControl
	String ctrlName

	RenameCurrentCategory()
End


static Function DeleteCategoryButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DeleteCurrentCategory()
End

static Function ScalePreviewBy(scale)
	Variable scale
	
	DrawAction /W=$ksPanelName getgroup=LaTeXPreviewGroup, delete, begininsert
	SetDrawEnv /W=$ksPanelName gstart, gname= LaTeXPreviewGroup
	DrawPICT/W=$ksPanelName 187,94,scale,scale,CodeCogsEqn_png
	SetDrawEnv /W=$ksPanelName gstop
	DrawAction /W=$ksPanelName endinsert
End

static Function UpdatePreviewPICT()

	ControlInfo/W=$ksPanelName scale
	Variable scale= str2num(S_Value)
	ScalePreviewBy(scale)
End

static Function ScalePopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	Variable scale= str2num(popStr)
	ScalePreviewBy(scale)
End

// Version 2.1: "LaTeX Palettes" folder within the same folder as this procedure file.
static Function/S PathToPaletteFolder()

	String pathToThisFile= FunctionPath("")
	String pathToThisFilesFolder= ParseFilePath(1, pathToThisFile, ":", 1, 0)
	String pathToFolder=pathToThisFilesFolder+"LaTeX Palettes"

	return pathToFolder	// note: no trailing ":"
End

// saved as Igor Binary
static Function SaveLaTeXPalettesAsFiles()
	
	String oldDF= GetDataFolder(1)
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:LaTeXPictures
	NewDataFolder/O/S root:Packages:LaTeXPictures:palettes

	String pathToFolder= PathToPaletteFolder()
	NewPath/C/O/Q/Z LaTeXSavePalettes, pathToFolder
	
	String list= Categories()
	Variable i, numCategories= ItemsInList(list)
	Print numCategories, "palettes saved to "+pathToFolder
	for(i=0; i<numCategories; i+= 1 )
		String category= StringFromList(i,list)
		WAVE/T tw= CategoryWavePath(category)
		Save/O/P=LaTeXSavePalettes tw
		Print "\t\t "+category
	endfor
	SetDataFolder oldDF
End


static Function SavePalettesButtonProc(ctrlName) : ButtonControl
	String ctrlName

	SaveLaTeXPalettesAsFiles()
	PathInfo/SHOW LaTeXSavePalettes
End

// Note: this does not delete any existing palettes()
// Set (or kill) the LaTeXLoadPalettes path before calling this routine.
static Function LoadLaTeXPalettes()

	String oldCategories= Categories()	// can be "_none_;"
	String currentCategory=""
	ControlInfo/W=$ksPanelName paletteWavesPop
	if( V_Flag )
		currentCategory= S_Value
	endif
	
	String oldDF= GetDataFolder(1)
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:LaTeXPictures
	NewDataFolder/O/S root:Packages:LaTeXPictures:palettes

	PathInfo/S LaTeXLoadPalettes
	String pathToFolder
	if( V_Flag == 0 )	// if not defined, use the save path where we normally save palettes
		pathToFolder= PathToPaletteFolder()
		NewPath/C/O/Q/Z LaTeXLoadPalettes, pathToFolder
		PathInfo LaTeXLoadPalettes
	endif
	pathToFolder= S_path
	
	String files= IndexedFile(LaTeXLoadPalettes,-1,".ibw")	// Igor binary files
	
	Variable i, numFiles= ItemsInList(files)
	Print numFiles, "palettes loaded from "+pathToFolder
	for( i=0; i<numFiles; i+=1 )
		String file= StringFromList(i,files)
		LoadWave/P=LaTeXLoadPalettes/O/H/N file
		WAVE/T/Z tw= $StringFromList(0,S_waveNames)
		if( WaveExists(tw) )
			String category= note(tw)
			// Print "\t\t "+category
		endif
	endfor
	SetDataFolder oldDF

	DoWindow $ksPanelName
	if( V_Flag )
		String allCategories= Categories()
		
		// try to select a new category to show that it succeeded
		String newCategories= RemoveFromList(oldCategories, allCategories)
		String newCategory= StringFromList(0,newCategories)
		if( strlen(newCategory) )
			currentCategory= newCategory
		endif
		SelectCategory(currentCategory)
	endif
End

static Function LoadPalettes(ctrlName) : ButtonControl
	String ctrlName

	// Give the use the opportunity to load palettes from some other folder
	PathInfo/S LaTeXLoadPalettes
	String pathToFolder
	if( V_Flag == 0 )	// if not defined, use the save path where we normally save palettes
		pathToFolder= PathToPaletteFolder()
		NewPath/C/O/Q/Z LaTeXLoadPalettes, pathToFolder
		PathInfo/S LaTeXLoadPalettes
	endif
	NewPath/C/O/Q/Z/M="Choose folder containing Igor Binary LaTeX palette files" LaTeXLoadPalettes	// prompt the users
	if( V_flag != 0 )	// user cancelled
		return 0
	endif
	
	LoadLaTeXPalettes()
End
