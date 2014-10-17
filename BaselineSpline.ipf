#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.00
#pragma IgorVersion=6.10
#pragma ModuleName=BaselineSpline
#pragma hide=1

#include <Readback ModifyStr>

// written by tony withers, withers@umn.edu

// 2.0  8/6/09
// incorporated suggestions from JJ Weimer that improve functionality and clarity of code
// and compatibility with 6.10
// ... and then wrecked his nice programming with my clumsy code.

// 1.43b
// allow refit function to switch interpolate flag when number of nodes is small to allow linear fit

// 1.42 6/8/08
// set y axis to manual range to avoid crazy rescaling if spline shoots out of range.
// show subtracted spectrum whilst fitting

// 1.41 10/9/07
// for XY data we now interpolate directly into XY baseline
// improved guesses for initial node positions for unevenly spaced XY data

// 1.40   10/9/07
// fixed bug that occurred with baseline subtraction of XY data

// 1.30  7/24/07
// handles XY data
// baseline is waveform, but data wave need not be (though it should be reasonably closely spaced).

// 1.20 7/3/07
// uses new graphwaveedit flag. now requires version 6.0.1.


Static StrConstant thePackage="BaselineSpline"
Static StrConstant thePackageFolder="root:Packages:BaselineSpline"
Static StrConstant theProcedureFile = "BaselineSpline.ipf"
Static Constant thePackageVersion = 2.0
Static Constant hasHelp = 0



// uncomment to use JJ Weimer style menu definitions:

//#define Weimerized

#ifdef Weimerized
	Menu "Misc"
		Submenu "Packages"
			"Spline Baseline",/Q, ACW_InitSplineBaseline()
		end
	end
	
	Menu "Macros"
		ACW_ToggleFitMenu(), /Q, ACW_ToggleFitting()
		ACW_SubtractBaseMenu(),/Q, ACW_subtractSpline()
		ACW_ClearSplineMenu(),/Q, ACW_clearSpline()
	end

#else
	Menu "Analysis"
		Submenu "Packages"
			"Spline Baseline",/Q, ACW_InitSplineBaseline()
		end
	end
	
	Menu "Macros"	
		Submenu "Spline Baseline"
			"Initalise...", ACW_InitSplineBaseline()
			
			// following Macro menus appear when editing is possible
			ACW_ToggleFitMenu(), /Q, ACW_ToggleFitting()
			ACW_SubtractBaseMenu(), /Q , ACW_subtractSpline()	
			ACW_ClearSplineMenu(),/Q, ACW_clearSpline()
		end
	end

#endif

// Macro menus appear when editing is possible

Function/S ACW_ToggleFitMenu()	

	NVAR V_edit= root:Packages:SplineFit:V_edit

	if (NVAR_exists(V_edit))
		switch(V_edit)
			case -1:
				return ""
				break
			case 0:
				return "Adjust Nodes/1"
				break
			case 1:
				return "Adjust Nodes!"+num2char(18)+"/1"
				break
		endswitch
	else
		return ""
	endif
end

// Macro menu appears when spline curve is attached to graph

Function/S ACW_SubtractBaseMenu()

	NVAR V_edit= root:Packages:SplineFit:V_edit
	
	if (NVAR_exists(V_edit))
		if (V_edit >= 0)
			return "Subtract Baseline"
		else
			return ""
		endif
	else
		return ""
	endif
end


// clear spline line menu

Function/S ACW_ClearSplineMenu()	

	NVAR V_edit= root:Packages:SplineFit:V_edit

	if (NVAR_exists(V_edit))
		if (V_edit >= 0)
			return "Clear Spline Trace"
		else
			return ""
		endif
	else
		return ""
	endif
end

// initialize spline baseline package

function ACW_InitSplineBaseline()
	
	if (strlen(WinList("*",";","WIN:1"))==0)  // no graphs 
		doalert 0, "Spline baseline requires a trace plotted in a graph window."
		return 0
	endif
	
	// clear any package detritus from the graph
	ACW_clearSpline() 
	
	// initialise (or reinitialise) the package data folder
	
	NewDataFolder /O root:Packages
	NewDataFolder /O root:Packages:SplineFit
	
	
	string /G root:Packages:SplineFit:S_Data=""
	string /G root:Packages:SplineFit:S_Xwave=""
	variable /G root:Packages:SplineFit:V_edit=0
	
	make /O/n=(1) root:Packages:SplineFit:W_nodesX, root:Packages:SplineFit:W_nodesY
	make /O/n=1  root:Packages:SplineFit:W_spline_dependency
	make/O/n=1  root:Packages:SplineFit:W_base
	
	// create a wave to store some global variables	
	if (exists("root:Packages:SplineFit:SplineFitGlobals")==1)
		wave SplineFitGlobals=root:Packages:SplineFit:SplineFitGlobals
		// for backward compatibility with older versions of this procedure
		redimension /N=10 SplineFitGlobals
		setdimlabel  0, 5, isXY, SplineFitGlobals
		setdimlabel  0, 6, showSub, SplineFitGlobals
		setdimlabel  0, 7, nodes, SplineFitGlobals
	else
		make /o/n=10 root:Packages:SplineFit:SplineFitGlobals=nan
		wave SplineFitGlobals=root:Packages:SplineFit:SplineFitGlobals
		setdimlabel  0, 0, null, SplineFitGlobals
		setdimlabel  0, 1, flagE, SplineFitGlobals
		setdimlabel  0, 2, flagF, SplineFitGlobals
		setdimlabel  0, 3, flagJ, SplineFitGlobals
		setdimlabel  0, 4, flagT, SplineFitGlobals
		setdimlabel  0, 5, isXY, SplineFitGlobals
		setdimlabel  0, 6, showSub, SplineFitGlobals
		setdimlabel  0, 7, nodes, SplineFitGlobals
		setdimlabel  0, 8, fitWithinGraph, SplineFitGlobals
		SplineFitGlobals[%flagE]=2
		SplineFitGlobals[%flagF]=1
		SplineFitGlobals[%flagJ]=1
		SplineFitGlobals[%flagT]=2
		SplineFitGlobals[%showSub]=1
		SplineFitGlobals[%nodes]=5
		SplineFitGlobals[%fitWithinGraph]=1
	endif
	
	// define the globals
	SVAR S_Data=root:Packages:SplineFit:S_Data
	SVAR S_Xwave=root:Packages:SplineFit:S_Xwave
	NVAR V_edit=root:Packages:SplineFit:V_edit
	wave W_nodesX=root:Packages:SplineFit:W_nodesX
	wave W_nodesY=root:Packages:SplineFit:W_nodesY
	wave W_spline_dependency=root:Packages:SplineFit:W_spline_dependency
	wave W_base=root:Packages:SplineFit:W_base
	
	
	// define some local variables	
	variable i, nthRange, nn=SplineFitGlobals[%nodes]-3
	nn=max(1, nn) // just making sure
	string s_traceName
	variable p_low, p_high, v1, v2
	variable pmin, pmax, delP
	string s_info
	variable trace_offset=0
	

	prompt s_traceName, "Data Wave", popup, TraceNameList("",";",1+4) // what does bit 2 do?
	prompt nn, "Number of Nodes", popup, "4;5;6;7;8;9;10;"
	DoPrompt "", s_traceName, nn
	if (V_Flag)
		return 0
	endif
	
	SplineFitGlobals[%nodes]=nn+3
	if (stringmatch(s_traceName, "_none_"))
		doalert 0, "No spectra in top graph window. Inititalisation failed."
		return 0
	endif	
	
	S_Data=s_traceName
	
	wave data=TraceNametoWaveRef("",s_tracename)
	duplicate /O data root:Packages:SplineFit:W_base,  root:Packages:SplineFit:W_sub
	wave W_base=root:Packages:SplineFit:W_base
	wave w_sub= root:Packages:SplineFit:W_sub
	
	redimension/N=(SplineFitGlobals[%nodes]) W_nodesX, W_nodesY
	
	SplineFitGlobals[%isXY]=0
	// find out whether data is XY
	S_Xwave=StringByKey("XWAVE", TraceInfo("",s_tracename,0))
	if (strlen(S_Xwave))
		wave Xwave=XWaveRefFromTrace("", s_tracename )
		S_Xwave[0]=StringByKey("XWAVEDF", TraceInfo("",s_tracename,0))
		SplineFitGlobals[%isXY]=1
	endif
		
	// manually scale y axis
	getaxis /Q left
	setAxis left, V_min, V_max
	
	// determine where to place nodes on the bottom axis	
	if(SplineFitGlobals[%fitWithinGraph]) // keep nodes within window 
		GetAxis/Q bottom
		
		if (SplineFitGlobals[%isXY])
			findlevel /Q/P Xwave, V_max
			if (V_flag)
				v1=numpnts(Xwave)
			else
				v1=V_LevelX
			endif
			findlevel /Q/P Xwave, V_min
			if (V_flag)
				v2=0
			else
				v2=V_LevelX
			endif
			
			pmax=max(v1,v2)
			pmin=min(v1,v2)
		else
			pmax=floor(max( x2pnt(data, V_max), x2pnt(data,V_min) ) ) -1
			pmin=ceil (min( x2pnt(data,V_max), x2pnt(data,V_min) ) ) +1
		endif
	else // spead nodes across entire range of wave and autoscale bottom axis
		pmin=0
		pmax=numpnts(data)-1

		// autoscale bottom axis before adding spline nodes
		// baseline is subtracted from entire wave, so show the whole range.
		getaxis /Q  bottom
		if (v_min>v_max)
			setaxis /r/a bottom
		else
			setaxis /A bottom
		endif		
	endif
	
	delP=(pmax-pmin)/(SplineFitGlobals[%nodes]-1)
	
	// initialise node positions. set nodes to follow roughly the data
	
	if (SplineFitGlobals[%isXY])
		nthRange=(Xwave[pmax]-Xwave[pmin])/(SplineFitGlobals[%nodes]-1)
		W_nodesX=Xwave[pmin]+p*nthRange
	else
		nthRange=(pnt2x(data, pmax)-pnt2x(data, pmin))/(SplineFitGlobals[%nodes]-1)
		W_nodesX=pnt2x(data, pmin)+p*nthRange
	endif
	
	
	for (i=0;i<(SplineFitGlobals[%nodes]);i+=1)
		if (SplineFitGlobals[%isXY])
			// necessary for unevenly spaced data
			findlevel /Q/P Xwave, W_nodesX[i]-nthRange/6
			if (V_flag)
				p_low=pmin
			else
				p_low= V_LevelX
			endif
			
			findlevel /Q/P Xwave, W_nodesX[i]+nthRange/6
			if (V_flag)
				p_high=pmax
			else
				p_high= V_LevelX
			endif		
		else					
			p_low=  max(pmin, pmin+i*delP - delP/6 ) 
			p_high= min(pmax, pmin+i*delP + delP/6 )
		endif
		wavestats /Q/M=1/R=[p_low , p_high] /Z  data
		W_nodesY[i]=V_avg  // this handles a few NANs	
	endfor
	

	
	// if data are offset, then apply offsets to baseline and nodes
	s_info=traceinfo("",s_tracename,0)
	trace_offset=GetNumFromModifyStr(s_info,"offset","{",1)
	
	
	AppendToGraph W_spline_dependency // need to have this on graph to force update while in drawing mode
	ModifyGraph hideTrace(W_spline_dependency)=1
	
	appendtograph W_nodesY vs W_nodesX
	ModifyGraph mode(W_nodesY)=3,marker(W_nodesY)=11,rgb(W_nodesY)=(0,39168,0)
	ModifyGraph offset(W_nodesY)={0,trace_offset}
	
	ACW_RefitSpline(W_nodesX)
	
	
	if (SplineFitGlobals[%isXY])
		appendtograph W_base vs Xwave
		if (SplineFitGlobals[%showSub])
			appendtograph W_sub vs Xwave
		endif
	else
		appendtograph W_base
		if (SplineFitGlobals[%showSub])
			appendtograph W_sub
		endif
	endif
	
	ModifyGraph offset(W_base)={0,trace_offset}
	ModifyGraph rgb(W_base)=(0,0,52224)
	modifygraph live(W_base)=1
	
	if (SplineFitGlobals[%showSub])
		ModifyGraph rgb(W_sub)=(0,0,0)
		ModifyGraph zero(left)=1
		W_sub=data-W_base
	endif
	
	// set a dependency to trigger interpolation AND update graph when we adjust a node position
	W_spline_dependency:=ACW_RefitSpline(root:Packages:SplineFit:W_nodesY)	
	
	ReorderTraces $"W_nodesY",{$"W_base"}
	V_edit = 0
	ACW_ToggleFitting()
	return 0	
end


// dependency funtion to define the spline curve

function ACW_RefitSpline(w)
	wave w
	
	wave g=root:Packages:SplineFit:SplineFitGlobals
	SVAR S_Xwave=root:Packages:SplineFit:S_Xwave
	
	// check for small number of points
	wave W_nodesX=root:Packages:SplineFit:W_nodesX
	if (numpnts(W_nodesX)<4)
		g[%flagT]=1
	else
		g[%flagT]=2
	endif

	// interpolate2 doesn't work unless you give full paths	
	if (g[%isXY])	
		Interpolate2 /E=(g[%flagE]) /F=(g[%flagF]) /J=(g[%flagJ]) /T=(g[%flagT]) /I=3  /X=$S_Xwave /Y=root:Packages:SplineFit:W_base root:Packages:SplineFit:W_nodesX, root:Packages:SplineFit:W_nodesY
	else
		Interpolate2 /E=(g[%flagE]) /F=(g[%flagF]) /J=(g[%flagJ]) /T=(g[%flagT]) /I=3  /Y=root:Packages:SplineFit:W_base root:Packages:SplineFit:W_nodesX, root:Packages:SplineFit:W_nodesY
	endif
	
	if (g[%showSub])
		SVAR s_data=root:Packages:SplineFit:S_Data
		wave data=TraceNametoWaveRef("",S_Data) 
		wave w_base=root:Packages:SplineFit:w_base
		wave w_sub= root:Packages:SplineFit:w_sub
		w_sub=data-w_base
	endif
	
	return nan	
end

// function to subtract the spline curve

function ACW_subtractSpline()
	
	SVAR s_data=root:Packages:SplineFit:S_Data
	NVAR V_edit=root:Packages:SplineFit:V_edit
	wave W_base=root:Packages:SplineFit:W_base
	wave data=TraceNametoWaveRef("",S_Data)
	string strSubtracted, strBaseline
	strSubtracted=CleanupName( nameofwave(data)+"_BS",0)
	strBaseline=CleanupName( nameofwave(data)+"_SplineBL",0)

	if (exists(strSubtracted))
		doalert 1, strSubtracted+" exists. Overwrite?"
		if(V_flag==2)
			return 0
		endif
	endif
	duplicate /o data $strSubtracted
	wave nob=$strSubtracted
	
	if (exists(strBaseline))
		doalert 1, strBaseline+" exists. Overwrite?"
		if(V_flag==2)
			return 0
		endif
	endif
	duplicate /o W_base $strBaseline
	wave bl=$strBaseline
	
	nob=data-bl
	
	removefromgraph /Z $strSubtracted, $strBaseline, W_base,  W_nodesY, w_sub
	
	// find out whether data is XY	
	string s_Xwave=StringByKey("XWAVE", TraceInfo("",NameOfWave(data),0))
	
	if (strlen(s_Xwave))  // XY data
		wave Xwave=XWaveRefFromTrace("", NameOfWave(data) )	
		appendtograph nob, bl vs Xwave
	else
		appendtograph nob, bl
	endif
	
	// would be nice to put some of this in the history...
	
	ModifyGraph rgb($nameofwave(bl))=(0,65280,0)	
	ModifyGraph rgb($nameofwave(nob))=(0,0,0)	
	V_edit=-1
	BuildMenu "macros"	
	
	return 1
end

// function to toggle between normal graph and draw mode

function ACW_ToggleFitting()

	NVAR V_edit=root:Packages:SplineFit:V_edit
	if (V_edit)
		GraphNormal
		ModifyGraph mode(W_nodesY)=2
		V_edit=0
	else
		ModifyGraph mode(W_nodesY)=3
		GraphWaveEdit /T=1 /M $"W_nodesY"
		V_edit=1
	endif
	buildmenu "macros"
	return 1
end


// function to clear the spline curve

function ACW_clearSpline()
	
	NVAR /Z V_edit=root:Packages:SplineFit:V_edit
	wave W_spline_dependency=root:Packages:SplineFit:W_spline_dependency
	
	GraphNormal
	//ModifyGraph /z mode(W_nodesY)=2
	RemoveFromGraph /Z W_spline_dependency,W_base,W_nodesY, w_sub
	if ( NVAR_Exists(V_edit) )
		V_edit = -1
	endif
	if (waveexists(W_spline_dependency))
		W_spline_dependency=NaN
	endif
	return 0
end