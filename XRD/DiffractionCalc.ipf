#pragma rtGlobals=1		// Use modern global access method.

Menu "Macros"
	"Diffraction_Calculator"
	"BM_VonV0_From_Pressure"
End


// --------------------------------------------------------------

Function GO()
	GetDiffractionParameters()
	DoDiffractionCalculation()
End

Function GetDiffractionParameters()
	NVAR Wavelength = root:MyGlobals:Wavelength
	NVAR Pressure = root:MyGlobals:Pressure
	SVAR Calibrant = root:MyGlobals:Calibrant
	SVAR DiffractionOutput = root:MyGlobals:DiffactionOutput // plot, table or nothing
	SVAR DiffractionType = root:MyGlobals:DiffactionType  // d-spacing or two theta

	If (DataFolderExists("root:MyGlobals:")==0)
		NewDataFolder root:MyGlobals
	EndIf
	
	If (NVAR_Exists(Wavelength) == 0)
		Variable/g root:MyGlobals:Wavelength 
		NVAR Wavelength = root:MyGlobals:Wavelength
	EndIf
	
	If (NVAR_Exists(Pressure) == 0)
		Variable/g root:MyGlobals:Pressure
		NVAR Pressure = root:MyGlobals:Pressure
	EndIf
	
	If (DataFolderExists("root:Calibrants:")==0)
		NewDataFolder root:Calibrants
		Print "No calibrant files found; add them to the calibrant folder."
		Abort
	EndIf
	
	If (DataFolderExists("root:Calibrants:Calculated")==0)
		NewDataFolder root:Calibrants:Calculated
	EndIf
	
	If (SVAR_Exists(Calibrant)==0)
		String/g root:MyGlobals:Calibrant
		SVAR Calibrant = root:MyGlobals:Calibrant
	EndIf
	
	If (SVAR_Exists(DiffractionOutput)==0)
		String/g root:MyGlobals:DiffractionOutput
		SVAR DiffractionOutput = root:MyGlobals:DiffractionOutput
	EndIf
	
	If (SVAR_Exists(DiffractionType)==0)
		String/g root:MyGlobals:DiffractionType
		SVAR DiffractionType = root:MyGlobals:DiffractionType
	EndIf

	
	Variable Temp_Wavelength, Temp_Pressure
	String Temp_Calibrant, Temp_DiffractionOutput, Temp_DiffractionType
	Temp_Wavelength = Wavelength
	Temp_Pressure = Pressure
	Temp_Calibrant = Calibrant
	Temp_DiffractionOutput = DiffractionOutput
	Temp_DiffractionType = DiffractionType

	String CurrentDataFolder = GetDataFolder(1)
	SetDataFolder root:Calibrants
	String CalibrantList = WaveList("*",";","")
	SetDataFolder CurrentDataFolder
	String DiffractionOutputList = "Sticks on Top Graph;Table;Nothing"
	String DiffractionTypeList = "d-spacing;two-theta"

	Prompt Temp_Calibrant, "Select calibrant wave: ", popup, CalibrantList	
	Prompt Temp_DiffractionOutput, "What to do with output: ", popup, DiffractionOutputList
	Prompt Temp_DiffractionType, "What kind of calculation: ", popup, DiffractionTypeList	
	Prompt Temp_Wavelength, "Enter wavelength (in Angstroms):  "
	Prompt Temp_Pressure, "Enter pressure (in GPa): "
	
	DoPrompt "Calculation Parameters and Calibrant", Temp_Calibrant, Temp_Pressure, Temp_Wavelength, Temp_DiffractionOutput, Temp_DiffractionType
	Wavelength = Temp_Wavelength
	Pressure = Temp_Pressure
	Calibrant = Temp_Calibrant
	DiffractionOutput = Temp_DiffractionOutput
	DiffractionType = Temp_DiffractionType
End

Function DoDiffractionCalculation()
	SVAR Calibrant = root:MyGlobals:Calibrant
	SVAR DiffractionType = root:MyGlobals:DiffractionType
	SVAR DiffractionOutput = root:MyGlobals:DiffractionOutput
	NVAR P = root:MyGlobals:Pressure
	NVAR Wavelength = root:MyGlobals:Wavelength
	String CurrentDataFolder = GetDataFolder(1)
	SetDataFolder root:Calibrants
	Wave wr_Calibrant = $Calibrant
	SetDataFolder CurrentDataFolder

	Variable k0,kprime,a0,b0,c0,voverv0,covera,bovera, symmetry
	Variable alpha0, beta0, gamma0, numrefl, a, b, c
	symmetry = wr_Calibrant[0]	
	a0 = wr_Calibrant[1]
	b0 = wr_Calibrant[2]
	c0 = wr_Calibrant[3]
	alpha0 = wr_Calibrant[4]*Pi/180
	beta0 = wr_Calibrant[5]*Pi/180
	gamma0 = wr_Calibrant[6]*Pi/180
	k0 = wr_Calibrant[7]
	kprime = wr_Calibrant[8]
	numrefl=wr_Calibrant[10]
	covera = c0/a0	
	bovera = b0/a0
	voverv0=volBirchMurn(P,k0,kprime)
	a=a0*(voverv0)^(1/3)
	b=a*bovera
	c=a*covera
	
	Variable h,k,l,int,d,tt
	
	SetDataFolder root:Calibrants:Calculated
	
	String int_name = Make_int_name(Calibrant)
	Make /O/N=(numrefl) $int_name
	Wave wr_intensity = $int_name
	
	Make /O/N=(numrefl) Temp_DSP
	Wave Temp_DSP
	Make /T/O/N=(numrefl) $(Calibrant+"_hkls")
	Wave/T wr_hkls = $(Calibrant+"_hkls")
	String X_Wave_Name
	variable refl=0
	do
		h=wr_Calibrant[16+4*refl]
		k=wr_Calibrant[17+4*refl]
		l=wr_Calibrant[18+4*refl]
		int=wr_Calibrant[19+4*refl]
		wr_intensity[refl]=int
		d=dspaceBySymmetry(symmetry,a,b,c,alpha0,beta0,gamma0,h,k,l)
		Temp_DSP[refl]=d
		wr_hkls[refl] = num2str(h)+num2str(k)+num2str(k)
		refl+=1
	while(refl<numrefl)

	
	If (cmpstr(DiffractionType,"d-spacing")==0)
		String dsp_name = Make_dsp_name(Calibrant,P)
		If(StrLen(dsp_name)>34)
			Print "Your filenames are getting too long.  Shorten the calibrant name"
			SetDataFolder CurrentDataFolder
			Abort
		EndIf		
		Make /O/N=(numrefl) $dsp_name
		Wave wr_dsp=$dsp_name
		wr_dsp = Temp_DSP
		X_Wave_Name = NameOfWave(wr_dsp)

	ElseIf (cmpstr(DiffractionType,"two-theta")==0)
		String tt_name = Make_tt_name(Calibrant,P,Wavelength)
		If(StrLen(tt_name)>34)
			Print "Your filenames are getting too long.  Shorten the calibrant name"
			SetDataFolder CurrentDataFolder
			Abort
		EndIf		
		Make /O/N=(numrefl) $tt_name
		Wave wr_tt=$tt_name
		wr_tt = (2*180/Pi)*asin(Wavelength/(2*Temp_DSP))
		X_Wave_Name = NameOfWave(wr_tt)
	Else
		Print "Diffraction type error!"
		Abort
	EndIf

		If (cmpstr(DiffractionOutput,"Sticks on Top Graph")==0)
			Plot_Sticks($X_Wave_Name,wr_intensity)
		ElseIF(cmpstr(DiffractionOutput,"Table")==0)
			Edit $X_Wave_Name,wr_intensity,wr_hkls
		EndIf

	Killwaves Temp_DSP
	
	SetDataFolder CurrentDataFolder

End
	
Function/s Make_dsp_name(Calibrant,P)
	String Calibrant
	Variable P
	Variable IntegerP = Floor(P)
	Variable DecimalP = round((P - IntegerP)*10)
	String Name = Calibrant+"_dsp_P"+num2str(IntegerP)+"."+num2str(DecimalP)
	Return Name
End

Function/s Make_tt_name(Calibrant,P,Wavelength)
	String Calibrant
	Variable P, Wavelength
	Variable IntegerP = Floor(P)
	Variable DecimalP = round((P - IntegerP)*10)
	String Name = Calibrant+"_tt_WL"+num2str(Wavelength)+"_P"+num2str(IntegerP)+"."+num2str(DecimalP)
	Return Name
End

Function/s Make_int_name(Calibrant)
	String Calibrant
	Return Calibrant+"_int"
End
	
Function Plot_Sticks(wx,wy)
	Wave wx, wy
	AppendToGraph wy vs wx
	ModifyGraph mode($ReturnLastAppendedTrace())=1 // plot as sticks
	ModifyGraph lsize($ReturnLastAppendedTrace())=2 // change thickness to 2
End
	
	
	
	
	
	
	
	
	
	
	


//----------------------------------------------
function volBirchMurn(pressure,k,kprime)
variable pressure, k, kprime
// idea is for this function to take pressure, k, kprime and return vovervo based on birch murnaghaneos

variable v, kp,x,pressure1,f
variable j
	
	v=(1+ kprime*pressure/k)^(-1/kprime)//use murnaghan eos to get first guess for volume
	
	kp=k + kprime*pressure	//use murnahan EOS to estimate bulk modulus(pressure)

	x=1.5*(kprime - 4)

	j=0
		do							
			//use burch murnahan EOS to get a pressure from initial volume
			 f=.5*(v^(-2/3) -1)

			pressure1=3*f*k*(1+x*f)*(1+2*f)^2.5

			v = v * (1 - (pressure-pressure1)/kp)
		
			j+=1	
		while (abs(pressure-pressure1)>.01)
					//iterate till pressure is close to initial pressure
	
return v		//v is then vovervo
end

//---------------------------------------------------------------------------------------------
function dspaceBySymmetry(symmetry,a,b,c,alpha,beta,gamma,h,k,l)
variable symmetry,a,b,c,alpha,beta,gamma,h,k,l
	//note! alpha,beta,gamma are in radians!!!

variable d,dum
variable sina,cosa,sinb,cosb,sing,cosg,vol

if(symmetry==1) //cubic (a)
	dum= (h*h + k*k + l*l)/(a*a)
endif

if (symmetry==2) //orthorhombic (a,b,c)
	dum = (h*h)/(a*a) + (k*k)/(b*b) + (l*l)/(c*c)
endif

if (symmetry==3) //tetragonal (a,c) (a=b; alpha=beta=gamma=90)
	dum=(h*h + k*k)/(a*a) + (l*l)/(c*c)
endif

if (symmetry==4) //hexagonal (a,c) (a=b; alpha=beta=90;gamma=120)
	dum = (4.0/3.0)*((h*h + h*k + k*k)/(a*a)) + (l*l)/(c*c)
endif

if (symmetry==5) //monoclinic (a,b,c,beta) (alpha=gamma=90)
	dum = ((h*h)/(a*a)) + ((l*l)/(c*c))
	dum += (sin(beta)*sin(beta))*((k*k)/(b*b)) - 2.0*h*l*cos(beta)/(a*c)
	dum /= sin(beta)*sin(beta)
endif

if (symmetry==6) //rhombohedral (a,alpha) (a=b=c;alpha=beta=gamma)
	sina=sin(alpha)
	cosa=cos(alpha)
			dum = (h*h + k*k + l*l)*sina^2
			dum += 2.0*(h*k + k*l + h*l)*(cosa^2 - cosa)
			dum /= a*a*(1.0 - 3.0*cosa^2 + 2.0*cosa^3)
endif

if(symmetry==7) //triclinic (a,b,c,alpha,beta,gamma)
		sina = sin(alpha)
		sinb = sin(beta)
		sing = sin(gamma)
		cosa = cos(alpha)
		cosb = cos(beta)
		cosg = cos(gamma)
			vol = a*b*c*sqrt(1-cosa*cosa-cosb*cosb-cosg*cosg+2*cosa*cosb*cosg);
			dum=(b*c*sina*h)^2 + (a*c*sinb*k)^2 + (a*b*sing*l)^2
			dum+=2*a*b*c^2*(cosa*cosb-cosg)*h*k
			dum+=2*a^2*b*c*(cosb*cosg-cosa)*k*l
			dum+=2*a*b^2*c*(cosg*cosa-cosb)*h*l
			dum/=vol^2		
endif

d=sqrt(1/dum)
return d
end
// --------------------------------------------------------------





function /s ReturnLastAppendedTrace()
    string ListOfTraces= tracenamelist("",";",1)
    return (stringfromlist(itemsinlist(ListOfTraces)-1,ListOfTraces))
End

