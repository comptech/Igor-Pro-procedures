Function Normalize(spectrum)
//  Creates a relative intensity wave in arbitrary units ranging from 0-100
        Wave spectrum
        WaveStats spectrum
        //Variable V_max
        spectrum = spectrum/V_max*100
End 

