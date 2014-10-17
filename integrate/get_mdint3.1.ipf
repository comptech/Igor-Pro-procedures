#pragma rtGlobals=1		// Use modern global access method.
#pragma version=310

// function to integrate 2-dim waves with background subtraction, e.g. a mass trace out of 2-dim ordered mass spectra
// without background subtraction, choose: bgStart < 0, but not bgStart = -56!
// for bgStart >= 0 an equal interval is used to calculate the background to be subtracted
// for bgStart = -56 background is interpolated by start and stop y values
// x scaling of destwave wave is set to y scaling of the 2-dim wave
// Version 3.1:
// duplicate/free used to calculate integrals
// destwave not longer multiplied by -1
// optional area instead of sum
// checks now, if matrix is supplied
// when area function is used, the the data scaling of the destination wave is calculated from x and d scaling of the matrix

#define useArea		// commentize this line to use the Sum function instead of the Area function


function/s get_mdint3(w,start,stop, bgStart)
	wave w
	variable start,stop		// integration limits
	variable bgStart		// left limit of background interval, or special mode (see above)
	if(wavedims(w)!=2)
		print "Abort: get_mdint3 works only with 2-dim waves!"
		return ""
	endif
	variable numcolumns = dimsize(w,1)		// number of coumns
	variable bgStop = bgStart + abs(stop - start)		//calculate right limit of background interval
	string destwavestr = nameofwave(w)
	destwavestr += "_int_" + num2istr(start) + "_" + num2istr(stop)
	make/o/N=(numcolumns) $destwavestr		// destination wave
	wave destwave = $destwavestr
	
	variable j
	for (j=0; j<(numcolumns); j+=1)			// loop over the columns
		duplicate/o/free/r=[start,stop][j] w, singleTrace
#ifdef useArea		// uses the Area function to calculate the integral, can be controlled via the define pragma (see above)
		destwave[j]= area(singleTrace)
		if(bgStart>=0)		// normal background correction for bgStart >= 0
			duplicate/o/free/r=[bgStart,bgStop][j] w,bgTrace
			destwave[j]-=area(bgTrace)
		elseif(bgStart==-56)		// special background correction mode, see above
			destwave[j]-=(pnt2x(w,stop)-pnt2x(w,start))*(singleTrace[0]+singleTrace[inf])/2
		endif
#else		// uses the Sum function to calculate the integral, can be controlled via the define pragma (see above)
		destwave[j]= sum(singleTrace)
		if(bgStart>=0)		// normal background correction for bgStart >= 0
			duplicate/o/free/r=[bgStart,bgStop][j] w,bgTrace
			destwave[j]-=sum(bgTrace)
		elseif(bgStart==-56)		// special background correction mode (see above)
			destwave[j]-=numpnts(singleTrace)*(singleTrace[0]+singleTrace[inf])/2
		endif
#endif
	endfor

	setscale/p x,dimoffset(w,1),dimdelta(w,1),waveunits(w,1),destwave	// transfer y scaling of w to x scaling of destwave
#ifdef useArea
	setscale d,0,0,waveunits(w,-1)+waveunits(w,0),destwave 	// data scaling makes only sense for area, not for sum
#endif
	return destwavestr
end
