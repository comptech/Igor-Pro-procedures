Menu "Macros"
	"Load XRD Chi File and Plot/1", Load_Chi_Append()
	"Load XYErr data", Load_XYErr()
	"Load XYErr data and Plot/5", Load_XYErrPlot()
End

Function Load_Chi()
//  Typing Load_Chi() in the command line will bring up a window that allows
// you to choose the .chi file to load
//  It is designed for 2 column text
//  The first wave created will be the Intensity wave and the second wave will be
// the twotheta wave
       string name
       LoadWave/G/A
       Normalize(wave1)
       name = (S_fileName[0,strlen(S_fileName)-5])
       Rename wave1, $name+"_Intensity"
       Rename wave0, $name+"_TwoTheta"
End

Function Load_XYErr()
//  Typing Load_XYErr() in the command line will bring up a window that allows
// you to choose the data file to load
//  It is designed for 3 column text: X, Y, Err
       string name
       LoadWave/O/G/A
       //Normalize(wave1)
       name = (S_fileName[0,strlen(S_fileName)-5])
       Rename wave2, $name+"_Err"
       Rename wave1, $name+"_Y"
       Rename wave0, $name+"_X"
End

Function Load_XYErrPlot()
//  Typing Load_XYErr() in the command line will bring up a window that allows
// you to choose the data file to load
//  It is designed for 3 column text: X, Y, Err
       string name
       LoadWave/G/A
       //Normalize(wave1)
       name = (S_fileName[0,strlen(S_fileName)-5])
       Rename wave2, $name+"_Err"
       Rename wave1, $name+"_Y"
       Rename wave0, $name+"_X"
       AppendToGraph $name+"_Y" vs $name+"_X"
       ErrorBars $name+"_Y" Y,wave=($name+"_Err",$name+"_Err")
End

Function Load_Chi_dsp()
//  Typing Load_Chi() in the command line will bring up a window that allows
// you to choose the .chi file to load
//  It is designed for 2 column text
//  The first wave created will be the Intensity wave and the second wave will be
// the twotheta wave
       string name
       LoadWave/G/A
       Normalize(wave1)
       name = (S_fileName[0,strlen(S_fileName)-5])
       Rename wave1, $name+"_Intensity"
       Rename wave0, $name+"_DSpacing"
End

Function Henry_Load_Chi(xstart, xend)
	variable xstart, xend
	variable Wavelength
       string name
       LoadWave/G/A
       name = (S_fileName[0,strlen(S_fileName)-5])
       variable xstart_p, xend_p, flag1 =1, flag2 =1, i
       wave wave0
       for (i=0; i<numpnts(wave0); i=i+1)
       	if ((wave0[i] >=xstart) && flag1)
       		xstart_p = i
       		flag1 = 0
       	endif
       	if ((wave0[i] >=xend) && flag2)
       		xend_p = i
       		flag2 = 0
       	endif
       endfor
       variable numofpoints
       numofpoints = numpnts(wave0)
       DeletePoints 0, xstart_p, wave0
       DeletePoints 0, xstart_p, wave1
       DeletePoints xend_p, numofpoints-xend_p, wave0
       DeletePoints xend_p, numofpoints-xend_p, wave1
       Rename wave1, $name //wave1 is intensity
       ScaleChi(wave0,$name) //creates evenly spaced x-ray intensity data and scaled two theta values
       Normalize($name)
       //Henry_TwoTheta_to_Dsp(wave0, Wavelength)
       Killwaves wave0 //kills two theta because it can be calculated if intensity is used as a waveform
       
End

Function Load_Chi_NoRange()
       string name
       LoadWave/G/A
       name = (S_fileName[0,strlen(S_fileName)-5])
       Rename wave1, $name //wave1 is intensity
       ScaleChi(wave0,$name) //creates evenly spaced x-ray intensity data and scaled two theta values
       Normalize($name)
       Killwaves wave0 //kills two theta because it can be calculated if intensity is used as a waveform
End

Function Load_Chi_Append()
       string name
       LoadWave/G/A
       name = (S_fileName[0,strlen(S_fileName)-5])
       Rename wave1, $name //wave1 is intensity
       ScaleChi(wave0,$name) //creates evenly spaced x-ray intensity data and scaled two theta values
       Normalize($name)
       Killwaves wave0 //kills two theta because it can be calculated if intensity is used as a waveform
       String windowName
       windowName = WinName(0,3)
       print windowName
       if (strlen(windowName) == 0)
       	Display nullwave
       endif
       AppendToGraph $name
End

Function Load_SMS_Append()
       string name
       LoadWave/G/A
       name = (S_fileName[0,strlen(S_fileName)-5])
       Rename wave1, $name //wave1 is intensity
       ScaleChi(wave0,$name) //creates evenly spaced x-ray intensity data and scaled two theta values
       Normalize($name)
       Killwaves wave0 //kills two theta because it can be calculated if intensity is used as a waveform
       String windowName
       windowName = WinName(0,3)
       print windowName
       if (strlen(windowName) == 0)
       	Display nullwave
       endif
       AppendToGraph $name
End

Function Load_Vin()
       string name
       LoadWave/G/A
       name = (S_fileName[0,strlen(S_fileName)])
       Rename wave1, $name //wave1 is intensity
       ScaleChi(wave0,$name) //creates evenly spaced x-ray intensity data and scaled two theta values
       Normalize($name)
       Killwaves wave0 //kills two theta because it can be calculated if intensity is used as a waveform
End

Function ScaleChi(x,y)
       wave x, y
       variable startx, endx
        startx = x[0]
        endx = x[numpnts(x)-1]
        SetScale/I x startx, endx, "", y
end

Function Henry_TwoTheta_to_Dsp(wTwoTheta, Wavelength)
// This function takes waveform X-ray intensity data that is evenly spaced
// and scaled for two theta values and produces a new wave in that is waveform
// and evenly spaced and scaled for d-spacing values by interpolation
       Wave wTwoTheta // waveform TwoTheta data (TT values are the scaling)
       Variable Wavelength // in Angstroms!
       String output_wave_name = NameofWave(wTwoTheta)+"_DSP"
       Duplicate/O wTwoTheta $output_wave_name, xdata, ydata
// the xdata and ydata are temporary representations of the waveform data as x-y
       Wave wrDsp = $output_wave_name // wave reference to newly created wave
       xdata = x // the x-data wave is its own scaling values, initially in two theta
       xdata = Wavelength / (2 * sin((xdata/2)*(Pi/180))) // convert the x-data to dspacing
       MakeWaveForm(xdata,ydata,wrDsp)
       Killwaves xdata, ydata
End

Function MakeWaveForm(xdata,ydata,wf)
       Wave xdata,ydata,wf
       SetScale/I x xdata[0], xdata[numpnts(xdata)-1], wf
       wf = interp(x, xdata, ydata)
End
