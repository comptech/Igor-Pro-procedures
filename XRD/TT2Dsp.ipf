Function Convert_TT_to_Dsp(TT_Wave,Wavelength)
// Example Convert_TT_to_Dsp(Spodumene_002_TwoTheta,0.368179)
// this function does not make use of waveforms, it uses Excel type data, ie one set of data for each "x" and "y"
// this function makes use of the two_theta waves loaded using load_chi()
        Variable Wavelength
        Wave TT_Wave
        string output_wave_name=NameofWave(TT_Wave)
        output_wave_name[(strlen(output_wave_name)-8),(strlen(output_wave_name))] = "Dsp"
        Duplicate/O/D  TT_Wave $output_wave_name
        wave wr_output_wave_name = $output_wave_name
        //Wavelength = 12.407 / Wavelength // convert from keV to ?
        // print wavelength
        wr_output_wave_name = Wavelength/(2*sin(TT_Wave*Pi/180/2))
End
