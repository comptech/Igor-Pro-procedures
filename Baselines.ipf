#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.10

// 7/23/07 1.10b
// added smoothed spline baseline
// 7/3/07 1.00

Menu "GraphMarquee"
	submenu "Baselines"
		"Initialise Baseline Fit", /Q, MenuInitBaselineFitting()
		"Add Region to Fit", /Q, GetMarquee /K bottom; ResetFitRegion(V_left, V_right, 1) 
		"Remove Region From Fit", /Q, GetMarquee /K bottom; ResetFitRegion(V_left, V_right, 0) 
		"Clear All Fit Regions", /Q,  ClearFitRegion()
		submenu "fit"
			"line", /Q, MenuFitBaseline()
			"poly 3", /Q, MenuFitBaseline()
			"poly 4", /Q, MenuFitBaseline()
			"gauss", /Q, MenuFitBaseline()		
			"lor", /Q, MenuFitBaseline()
			"exp", /Q, MenuFitBaseline()
			"Tony's gauss", /Q, MenuFitBaseline()
			"sin", /Q, MenuFitBaseline()
			"sigmoid", /Q, MenuFitBaseline()
			"spline", /Q,  MenuFitBaseline()
//			"exp_XOffset", /Q, MenuFitBaseline()
//			"dblexp_XOffset", /Q, MenuFitBaseline()
		end
		"Subtract Baseline", /Q, MenuSubtractBaseline()
	end
End

Menu "TracePopup"
	submenu "Baselines"
		"Initialise Baseline Fit", /Q, MenuInitBaselineFitting()		
		submenu "fit"
			"line", /Q, MenuFitBaseline()
			"poly 3", /Q, MenuFitBaseline()
			"poly 4", /Q, MenuFitBaseline()
			"gauss", /Q, MenuFitBaseline()		
			"lor", /Q, MenuFitBaseline()
			"exp", /Q, MenuFitBaseline()
			"Tony's gauss", /Q, MenuFitBaseline()
			"sin", /Q, MenuFitBaseline()
			"sigmoid", /Q, MenuFitBaseline()
			"spline", /Q, MenuFitBaseline()
//			"exp_XOffset", /Q, MenuFitBaseline()
//			"dblexp_XOffset", /Q, MenuFitBaseline()
		end
		"Subtract Baseline", /Q, MenuSubtractBaseline()
	end
End

Menu "AllTracesPopup" 
	submenu "Fit baseline to all traces on plot"
		"line", /Q, FitAllTraces()
		"poly 3", /Q, FitAllTraces()
		"poly 4", /Q, FitAllTraces()
		"gauss", /Q, FitAllTraces()		
		"lor", /Q, FitAllTraces()
		"exp", /Q, FitAllTraces()
		"Tony's gauss", /Q, FitAllTraces()
		"sin", /Q, MenuFitBaseline()
		"sigmoid", /Q, MenuFitBaseline()
		"spline", /Q,  MenuFitBaseline()
//		"exp_XOffset", /Q, MenuFitBaseline()
//		"dblexp_XOffset", /Q, MenuFitBaseline()
	end
end

Menu "Macros"
	submenu "Baselines"
		"Initialise Baseline Fit", /Q, MenuInitBaselineFitting()
		"Add Region to Fit", /Q, GetMarquee /K bottom; ResetFitRegion(V_left, V_right, 1) 
		"Remove Region From Fit", /Q, GetMarquee /K bottom; ResetFitRegion(V_left, V_right, 0) 
		"Clear All Fit Regions", /Q,  ClearFitRegion()
		submenu "fit"
			"line", /Q, MenuFitBaseline()
			"poly 3", /Q, MenuFitBaseline()
			"poly 4", /Q, MenuFitBaseline()
			"gauss", /Q, MenuFitBaseline()		
			"lor", /Q, MenuFitBaseline()
			"exp", /Q, MenuFitBaseline()
			"Tony's gauss", /Q, MenuFitBaseline()
			"sin", /Q, MenuFitBaseline()
			"sigmoid", /Q, MenuFitBaseline()
			"spline", /Q, MenuFitBaseline()
//			"exp_XOffset", /Q, MenuFitBaseline()
//			"dblexp_XOffset", /Q, MenuFitBaseline()
		end
		"Subtract Baseline", /Q, MenuSubtractBaseline()
	end
	
end


// a wrapper function for InitBaselineFit
function MenuInitBaselineFitting()
	// need to select data wave
	string strDataWave
	prompt strDataWave, "Data Wave", popup, WaveList("*", ";", "" )
	doPrompt "Initialise Baseline Fit", strDataWave
	
	if (V_flag)
		return 0
	endif
	
	wave W_data=$strDataWave
	InitBaselineFitting(W_data)
	CheckDisplayed W_data
	if (V_flag==0)
		appendtograph W_data
	endif
	
end

// value = 1 to include, 0 to exclude.
function ResetFitRegion(V_left, V_right, value)
	variable V_left, V_right, value
	
	if (exists("root:Packages:TonyIR:W_mask")==0)
		return 0
	endif
	
	SVAR wname=root:Packages:TonyIR:BaselineFitDataWaveName
	wave W_data=$wname
	
	wave W_mask=root:Packages:TonyIR:W_mask
	wave W_display=root:Packages:TonyIR:W_display 
	
	variable p_low=min(x2pnt(W_data,V_left), x2pnt(W_data,V_right))
	variable p_high=max(x2pnt(W_data,V_left), x2pnt(W_data,V_right))
	
	W_mask[p_low, p_high]=value
	W_display = W_mask[p] ? W_data[p] : NaN
	
	printf "ResetFitRegion(%d, %d, %d)\r", V_left, V_right, value
end

function ClearFitRegion()
	wave W_mask=root:Packages:TonyIR:W_mask
	wave W_display=root:Packages:TonyIR:W_display 
	W_mask=0
	W_display=nan
end


// set the data wave (raw spectrum from which baseline is to be subtracted)
function InitBaselineFitting(w)
	wave w
	
	NewDataFolder /O root:Packages
	NewDataFolder /O root:Packages:TonyIR
	
	String /G root:Packages:TonyIR:BaselineFitDataWaveName=GetWavesDataFolder(w, 2)
	
	duplicate /O w root:Packages:TonyIR:W_Display 
	wave W_display=root:Packages:TonyIR:W_display 
	
	
	// don't reset the mask wave if new data wave has same length as previous one
	// in case we want to apply the same fit to many spectra
	if (exists("root:Packages:TonyIR:W_mask")==1)
		wave W_mask=root:Packages:TonyIR:W_mask
		if (numpnts(W_mask)!=numpnts(W_display))
			duplicate /O w root:Packages:TonyIR:W_mask
			W_mask=0
			W_display=nan
		endif
	else
		duplicate /O w root:Packages:TonyIR:W_Mask
		wave W_mask=root:Packages:TonyIR:W_mask
		W_mask=0
	endif
	
	W_display = W_mask[p] ? w[p] : NaN
	
	checkdisplayed W_display
	if (V_flag==0)
		appendtograph W_display
		ModifyGraph mode(W_display)=7,hbFill(W_display)=4
		ModifyGraph rgb(W_display)=(24576,24576,65280)
	endif
		
	duplicate /O w  root:Packages:TonyIR:W_Base
	wave W_base=root:Packages:TonyIR:W_base
	W_base=nan
	
	if (WhichListItem("W_base",TraceNameList("", ";", 1 ) )==-1)
		appendtograph W_base
		ModifyGraph rgb(W_base)=(0,15872,65280)
	endif
	
	duplicate /O w  root:Packages:TonyIR:W_NoBase
	wave W_NoBase=root:Packages:TonyIR:W_NoBase
	W_NoBase=nan
	if (WhichListItem("W_NoBase",TraceNameList("", ";", 1 ) )==-1)
		appendtograph W_NoBase
		ModifyGraph rgb(W_NoBase)=(0,0,0)
	endif
	variable /G root:Packages:TonyIR:V_smooth
	NVAR V_smooth=root:Packages:TonyIR:V_smooth
	V_smooth+=0.5*(V_smooth==0)
	
	printf "InitBaselineFitting%s)\r", nameofwave(w)
end


// wrapper function to subtract the current fit from the data wave
function MenuSubtractBaseline()
	
	SVAR wname=root:Packages:TonyIR:BaselineFitDataWaveName
	wave W_data=$wname
	
	SubtractBaseline(W_data)
	
end

// subtract current baseline from W_data
function SubtractBaseline(W_data)
	wave W_data
	
	wave W_base=root:Packages:TonyIR:W_base
	if(numpnts(W_base)!=numpnts(W_data))
		doalert 0, nameofwave(W_data) +" and baseline have different length"
		return 0
	endif
	
	// save a copy of the baseline
	string strNewName=CleanupName( nameofwave(W_data)+"_BL",0)
	if (exists(strNewName))
		doalert 1, strNewName+" exists. Overwrite?"
		if(V_flag==2)
			return 0
		endif
	endif
	duplicate /o W_data $strNewName
	wave newbase= $strNewName
	newbase=W_base
	
	// subtract baseline
	strNewName=CleanupName( nameofwave(W_data)+"_Sub",0)
	if (exists(strNewName))
		doalert 1, strNewName+" exists. Overwrite?"
		if(V_flag==2)
			return 0
		endif
	endif
	duplicate /o W_data $strNewName
	wave subtracted= $strNewName
	subtracted=W_data-W_base
	print "SubtractBaseline("+nameofwave(W_data)+")"
	checkdisplayed subtracted
	if (V_flag)
		return 1
	else
		appendtograph subtracted		
	endif
	KillControl SplineSmoothSetVar
	
end

// wrapper function to start baseline fit of type defined by menu item
function MenuFitBaseline()	
	SVAR wname=root:Packages:TonyIR:BaselineFitDataWaveName
	wave w=$wname
	
	GetLastUserMenuInfo
	
	printf "FitBaseline(%s, \"%s\")\r", nameofwave(w), S_value

	FitBaseline(w, S_value)

end


// fit a baseline defined by type to the data wave W_data using predefined mask wave
// this function allows batch fitting from the command line 
function FitBaseline(W_data, type)
	wave w_data
	string type
	
	wave W_Base=root:Packages:TonyIR:W_Base
	wave W_display=root:Packages:TonyIR:W_display 
	wave W_mask=root:Packages:TonyIR:W_mask
	wave W_noBase=root:Packages:TonyIR:W_noBase
	
	if (stringmatch(type, "spline"))
		
		W_display = W_mask[p] ? W_data[p] : NaN // reset W_display in case we're batch fitting
		
		NVAR V_smooth=root:Packages:TonyIR:V_smooth
		interpolate2/T=3/I=3/F=(V_smooth)/Y=root:Packages:TonyIR:W_Base root:Packages:TonyIR:W_display 
		
		SetVariable SplineSmoothSetVar title="Smoothing", pos={200,100}, size={100,16}
		SetVariable SplineSmoothSetVar labelBack=(65535,65535,65535)
		SetVariable SplineSmoothSetVar limits={0,1e6,0.1 }, value=root:Packages:TonyIR:V_smooth
		SetVariable SplineSmoothSetVar proc=BL_SplineSetVarProc
	else
		// remove the spline smoothing control in case previous fit was a spline
		KillControl SplineSmoothSetVar
	
		string s_hold=""
		if (stringmatch(type, "Tony's gauss"))
			s_hold="/H=\"1000\""
			type="gauss"
			execute /Q "K0 = 0"
		endif
		
		string cmd=""
		variable i
		wave w_mask=root:Packages:TonyIR:W_mask
		variable mask1=0
		for(i=0;i<numpnts(W_mask); i+=1)
			if(w_mask[i]!=mask1)
				mask1=1-mask1
				if(mask1) // started to include
					cmd += num2str(round(pnt2x(w_mask, i)))
				else // stopped including
					cmd+="-"+num2str(round(pnt2x(w_mask, i-1)))+" "
				endif
			elseif( (i==numpnts(w_mask)-1) && mask1)
				cmd+="-"+num2str(round(pnt2x(w_mask, i)))
			endif
		endfor
		print "fitting "+type+" baseline to "+nameofwave(w_data)+" at "+cmd
	
	
		sprintf cmd, "CurveFit/NTHR=0 /Q %s %s , %s /M=root:Packages:TonyIR:W_mask", s_hold, type, GetWavesDataFolder(w_data, 2)
		execute cmd
		
		wave W_coef=W_coef
		
		type=ReplaceString("gauss", type, "Gauss1D")
		type=ReplaceString("line", type, "BL_line")
		type=ReplaceString("lor", type, "BL_lor")
		type=ReplaceString("exp", type, "BL_exp")
		type=ReplaceString("3", type, "")
		type=ReplaceString("4", type, "")
		type=ReplaceString("sin", type, "BL_sin")
		type=ReplaceString("sigmoid", type, "BL_sigmoid")
		
		sprintf cmd, "root:Packages:TonyIR:W_base = %s(%s, x)", type, GetWavesDataFolder(W_coef, 2)
		execute cmd	
	endif
	

	W_noBase=W_data-W_base
	
end



Function BL_SplineSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	interpolate2/T=3/I=3/F=(varNum)/Y=root:Packages:TonyIR:W_Base root:Packages:TonyIR:W_display 
	
	SVAR S_name=root:Packages:TonyIR:BaselineFitDataWaveName
	
	wave W_Data=$S_name
	wave W_noBase=root:Packages:TonyIR:W_noBase
	wave W_base=root:Packages:TonyIR:W_base
	
	W_noBase=W_data-W_base
End




// use these functions to fill the baseline wave
function BL_line(w, x)
	wave w; variable x	
	return w[0]+w[1]*x
end

function BL_exp(W_coef, x)
	wave W_coef; variable x
	return W_coef[0]+W_coef[1]*exp(-W_coef[2]*x)
end

function BL_lor(W_coef, x)
	wave W_coef; variable x
	return W_coef[0]+W_coef[1]/((x-W_coef[2])^2+W_coef[3])
end


//function BL_exp_XOffset(W_coef, x)
//	wave W_coef; variable x
//	return W_coef[0]+W_coef[1]*exp(-(x-W_fitConstants[0])/W_coef[2])
//end
//	
//	
//function BL_dblexp_XOffset(W_coef, x)
//	wave W_coef; variable x
//	return 
//end

function BL_sin(W_coef, x)
	wave W_coef; variable x
	return W_coef[0]+W_coef[1]*sin(W_coef[2]*x+W_coef[3])
end

function BL_sigmoid(W_coef, x)
	wave W_coef; variable x
	return W_coef[0] + W_coef[1]/(1+exp(-(x-W_coef[2])/W_coef[3]))
end


function FitAllTraces()
	GetLastUserMenuInfo
	
	string ListOfTraces=TraceNameList("", ";", 1 )
	string NonDataTraces="W_Display;W_Base;W_NoBase"
	ListOfTraces=removefromlist(NonDataTraces,ListOfTraces, ";", 0)
	
	do
		wave W_data=tracenametowaveref("", StringFromList(0, ListOfTraces))
		ListOfTraces=RemoveListItem(0, ListOfTraces)
		
		FitBaseline(W_data, S_value)
		SubtractBaseline(W_data)
		
	while (itemsinlist(ListOfTraces))
	
end


// can use this function from data browser (Execute Cmd...). N defines baseline type:
 // 1 line
 // 2 poly 3
 // 3 poly 4
 // 4 gauss
 // 5 lor
 // 6 exp
 // 7 Tony's gauss
function FitAndGo(W_data, N)
	wave W_data; variable N
	
	string FitTypeList="line;poly 3;poly 4;gauss;lor;exp;Tony's gauss"
	string type=StringFromList(N-1, FitTypeList)
	
	 FitBaseline(W_data, type)
	 SubtractBaseline(W_data)
end

function OffsetFromZero(W_data, Offset)
	wave W_data
	variable Offset
	
	variable MinVal=-wavemin(W_data)
	
	W_data=W_data-MinVal+Offset
end

function alignSpectra(ref, wavenumber, w_data)
	wave ref, w_data
	variable wavenumber
	
	variable offset=w_data(wavenumber)-ref(wavenumber)
	W_data-=offset
end