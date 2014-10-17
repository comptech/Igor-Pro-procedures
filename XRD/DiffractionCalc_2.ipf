#pragma rtGlobals=1		// Use modern global access method.

Menu "Macros"
	"Diffraction_Calculator/3"
	"Change Pressure/4",Change_Pressure()
	"BM_VonV0_From_Pressure"
End

//  Macros and Functions for dpace functions GUI----------------------------------
Macro Diffraction_Calculator()
	string current_folder, calibrant_folder
	current_folder = GetDataFolder(1)
	if (DataFolderExists("root:Calibrants:")==1)
		SetDataFolder root:Calibrants
	else
		// if the Calibrants folder does not exist, create one.
		NewDataFolder/O root:Calibrants
		SetDataFolder root:Calibrants
	endif
	Variable/G root:Calibrants:pressure
	Variable/G root:Calibrants:energy
	String/G root:Calibrants:crystal
	String/G root:Calibrants:angorkev
	Diffraction_Calculator_Params()
	
	SetDataFolder current_folder
end

Macro Change_Pressure()
	string current_folder, calibrant_folder
	current_folder = GetDataFolder(1)
	if (DataFolderExists("root:Calibrants:")==1)
		SetDataFolder root:Calibrants
	else
		// if the Calibrants folder does not exist, create one.
		NewDataFolder/O root:Calibrants
		SetDataFolder root:Calibrants
	endif
	Variable/G root:Calibrants:pressure
	Variable/G root:Calibrants:energy
	String/G root:Calibrants:crystal
	String/G root:Calibrants:angorkev
	
	Diffraction_Calculator_ChangeP()
	SetDataFolder current_folder
end

Macro Diffraction_Calculator_Params(crystal,p0,pdelta,p1,energy,angorkev,sticks)
	String crystal=root:Calibrants:crystal, sticks, angorkev=root:Calibrants:angorkev
	Variable p0 =root:Calibrants:pressure
	Variable p1=0,pdelta=1,energy=root:Calibrants:energy
	Prompt crystal, "Data file:", popup, MYListFilter(WaveList("*",";",""), "d_", "tt_","int", "hkl_")
	Prompt p0, "Initial P:"
	Prompt p1, "FInal P (leave zero for one P):"
	Prompt pdelta, "Increment P:"
	Prompt energy, "Energy (0 for d-spacing):"
	Prompt angorkev, "Energy units:",popup,"keV;A"
	Prompt sticks, "Add data sticks to top graph? ", popup, "Yes;No"
	
	root:Calibrants:pressure = p0
	root:Calibrants:energy=energy
	root:Calibrants:crystal=crystal
	root:Calibrants:angorkev=angorkev
	
	if (p1 == 0)
		p1 = p0
		pdelta =1
	endif
	
	if (cmpstr(angorkev,"A")==0)
		if (!(energy == 0))
			energy = 12.3987/energy
		endif
	endif

	dspaceFunction($crystal,p0,p1,pdelta,energy)	
	
	// Even if sticks is "yes" only proceed if there is a top graph, and only one pressure was calculated
	if (cmpstr(sticks,"Yes")==0 %& p1==p0 %&  cmpstr(WinName(0,1),"")!=0)
		String wx,wy,wl
		wx = Make_x_name(crystal,energy,p0)
		wy = Make_y_name(crystal)
		wl = Make_hkl_name(crystal,energy)
		Plot_Sticks($wx,$wy, $wl)
		Phase_List(crystal, p0)
	endif
End

Macro Diffraction_Calculator_ChangeP(crystal,p0,energy,angorkev,sticks)
	String crystal=root:Calibrants:crystal, sticks="No", angorkev=root:Calibrants:angorkev
	Variable p0=root:Calibrants:pressure
	Variable energy=root:Calibrants:energy
	//String theTraceList = MYListFilter(TraceNameList("", ";", 1), "d_", "tt_","int", "hkl_")
	//theTraceList = theTraceList[4, strlen(theTraceList)]
	Prompt crystal, "Data file:", popup, MYListFilter(WaveList("*",";",""), "d_", "tt_","int", "hkl_")
	Prompt p0, "Pressure:"
	
	root:Calibrants:pressure = p0
	root:Calibrants:crystal = crystal
	
	dspaceFunction($crystal,p0,p0,1,energy)
	Phase_List(crystal, p0)
End

Function Change_AllPressure(name)
	String name

	SVAR angorkev=root:Calibrants:angorkev
	NVAR p0=root:Calibrants:pressure
	NVAR energy=root:Calibrants:energy
	
	string current_folder
	current_folder = GetDataFolder(1)
	
	if (DataFolderExists("root:Calibrants:")==1)
		SetDataFolder root:Calibrants
	endif
	
	Variable ic=0
	String crystal
	//String theList = MYListFilter(TraceNameList("",";", 5), "d_", "tt_","int", "hkl_")
	String theList = TraceNameList("", ";", 1)
	//theList = theList
	//print theList
	do
		crystal = StringFromList(ic, theList, ";")
		if (cmpstr(crystal[0,3], "int_") ==0)
			crystal = crystal[4, strlen(crystal)]
		endif
			print crystal
			if (DataFolderExists("root:Calibrants:")==1)
				SetDataFolder root:Calibrants
			endif
			if (strlen(crystal)==0)
				break	//all done
			elseif (WaveExists($crystal))
				dspaceFunction($crystal,p0,0,1,energy)
				Phase_List(crystal, p0)
			endif
			ic +=1
	while(1)
	SetDataFolder current_folder
End

Function Plot_Sticks(wx,wy,wl)
	Wave wx, wy
	Wave/T wl
	String wyn = NameOfWave(wy)
	NVAR pressure = root:Calibrants:pressure
	AppendToGraph wy vs wx
	ModifyGraph mode($ReturnLastAppendedTrace())=1 // plot as sticks
	ModifyGraph lsize($ReturnLastAppendedTrace())=1 // change thickness to 1
	ModifyGraph offset($ReturnLastAppendedTrace())={0, -20} //offset
	
	Variable index
	for (index = 0; index < numpnts(wy); index+=1)
		String tagname = wyn + num2str(index)
		Tag/C/N=$tagName/TL={dash=1}/B=1/L=1/A=MB/O=90/X=0/Y=5/F=0 $wyn, index, "\\Z10"+wl[index]
	endfor
	ControlBar 30
	SetVariable msg,pos={10,10},size={140,16},title=" Pressure (GPa) = ",fSize=10
	SetVariable msg,fStyle=1,fColor=(0,0,65535),valueColor=(65535,0,0)
	SetVariable msg,value= root:Calibrants:pressure
	Button prebtn,pos={157,10},size={120,16},proc=Change_AllPressure,title="Change All Pressure"
	Button prebtn,fSize=10
	Button zoomfullbtn,pos={284,10},size={75,16},proc=ZoomFullProc,title="Zoom Full"
	Button zoomfullbtn,fSize=10
	Button cleanbtn,pos={446,10},size={75,16},proc=CleanPhaseProc,title="Clean"
	Button cleanbtn,fSize=10
	SetDrawLayer UserFront
End

//Make legend list
Function Phase_List(crystal, p0)
	String crystal
	Variable p0
	
	Variable i = 0
	
	Make/O/T/N=20 phaselist
	Wave/T phaselist
	do
		if (cmpstr(phaselist[i],crystal) != 0) //not equal to crystal
			if (cmpstr(phaselist[i],"") !=0) //not empty
				//print "xxx"
				i = i+2
				continue
			else //empty
				phaselist[i] = crystal
				phaselist[i+1] = num2str(p0)
				i = i+2
				//print "zzz"
				break
			endif
		else //if (cmpstr(phaselist[i],crystal) == 0) //equal to crystal
			//print "yyy"
			phaselist[i] = crystal
			phaselist[i+1] = num2str(p0)
			i = i+2
			break
		endif
	while (cmpstr(phaselist[i],"") ==0)
	
	Variable index
	String phaselist_str = ""
	for (index = 0; index < numpnts(phaselist); index+=2)
		if (cmpstr(phaselist[index],"") != 0)
			if (index != 0 ) 
				phaselist_str += "\r" 
			endif
			phaselist_str += "\\s" + "(int_" + phaselist[index] + ")" + phaselist[index] +  " @ " + phaselist[index+1] + "GPa"
			Legend/C/N=phase/J  phaselist_str
		endif
	endfor
	
End

Macro BM_VonV0_From_Pressure(P,K,Kp)
	variable P,K,Kp=4, V
	Prompt P, "Pressure:"
	Prompt K, "Bulk Modulus:"
	Prompt Kp, "dK/dP:"
	V = volBirchMurn(P,K,Kp)
	Print V
End
// --------------------------------------------------------------


// Robin's dspace Functions---------------------------------------------
function dspaceFunction(w,p0,p1,pdelta,energy)
wave w
variable p0,p1,pdelta,energy
	
variable p,h,k,l,int,d,tt,refl,a,b,c,alpha,beta,gamma,numrefl
variable ko,kprime,ao,bo,co,vovervo,covera,bovera
variable symmetry
string hkl
 	
//get information from mineral wave	
symmetry=w[0]	

ao=w[1]
bo=w[2]
co=w[3]
alpha=w[4]*Pi/180
beta=w[5]*Pi/180
gamma=w[6]*Pi/180
ko=w[7]
kprime=w[8]

covera=co/ao		//assume isotropic compression by preserving c/a,b/a
bovera=bo/ao

if (DataFolderExists("root:Calibrants:list:")==1)
	SetDataFolder root:Calibrants:list
else
	NewDataFolder root:Calibrants:list
	SetDataFolder root:Calibrants:list	
endif

p=p0
	do
	//use birch murnaghan to determine lattice parameter a
	vovervo=volBirchMurn(p,ko,kprime)
	// calculate a,b,c from vovervo?
	//assumes isotropic compression: a:b:c constant; angles constant
	a=ao*(vovervo)^(1/3)
	b=a*bovera
	c=a*covera
	
	// Name and make the output waves.  Size of both with be the number of reflections
	string wn, x_name, y_name, hkl_name
	wn=NameofWave(w)
	numrefl=w[10]	
	y_name = Make_y_name(wn)
	Make /O/N=(numrefl) $y_name
	Wave wi=$y_name
	x_name = Make_x_name(wn,energy,p)
	Make/O/N=(numrefl) $x_name
	Wave wr = $x_name
	hkl_name = Make_hkl_name(wn,energy)
	Make/O/N=(numrefl)/T $hkl_name
	Wave/T wl = $hkl_name
	
	refl=0
	do
		h=w[16+4*refl]
		k=w[17+4*refl]
		l=w[18+4*refl]
		int=w[19+4*refl]
		wi[refl]=int
		
		d=dspaceBySymmetry(symmetry,a,b,c,alpha,beta,gamma,h,k,l) 	
		tt=(2*180/Pi)*asin(12.3985/(2*energy*d))
		hkl = "("+num2str(h)+" "+num2str(k)+" "+num2str(l)+")"
		if(energy==0) 
			wr[refl]=d
		else 
			wr[refl]=tt
		endif
		
		wl[refl] = hkl	
	
	refl+=1
	while(refl<numrefl)

p+=pdelta
while(p<=p1)

end

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



Function/s Make_x_name(crystal,energy,p)
	string crystal
	variable energy, p
	string wx
	if (energy == 0)
		 //wx=("d_"+crystal+num2istr(p)+"_"+num2istr((p-floor(p))*100))
		 wx=("d_"+num2istr(energy)+crystal)
	else
		//wx =("tt_"+num2istr(energy)+crystal+num2istr(p)+"_"+num2istr((p-floor(p))*100))
		wx =("tt_"+num2istr(energy)+crystal)
	endif
	return wx
End

Function/s Make_y_name(crystal)
	string crystal
	string wy
	wy="int_"+crystal
	return wy
End

Function/s Make_hkl_name(crystal,energy)
	string crystal
	variable energy
	string wl
	wl=("hkl_"+num2istr(energy)+crystal)
	return wl
End

function /s ReturnLastAppendedTrace()
    string ListOfTraces= tracenamelist("",";",1)
    return (stringfromlist(itemsinlist(ListOfTraces)-1,ListOfTraces))
End

Function/S MYListFilter(inputList, excludeStart01, excludeStart02, excludeStart03, excludeStart04)
	String inputList
	String excludeStart01, excludeStart02, excludeStart03, excludeStart04
	String excludedList="", outputList=""
	
	Variable startLen01 = strlen(excludeStart01), startLen02 = strlen(excludeStart02), startLen03 = strlen(excludeStart03), startLen04 = strlen(excludeStart04)
	
	String list = inputList
	String item
	Variable index = 0
	
	do
		item = StringFromList(index, list)
		if (strlen(item) == 0)
			break
		endif
		
		Variable len = strlen(item)
		if (len >= startLen01 %& (len >= startLen02) %& (len >= startLen03) %& (len >= startLen04))
			Variable exclude = 0
			
			String temp
			temp = item[0,startLen01-1]
			if (CmpStr(temp,excludeStart01) == 0)			// Starts with excludeStart01?
				exclude =  1
			endif
		
			temp = item[0,startLen02-1]
			if (CmpStr(temp,excludeStart02) == 0)			// Starts with excludeStart02?
				exclude =  1
			endif
			
			temp = item[0,startLen03-1]
			if (CmpStr(temp,excludeStart03) == 0)			// Starts with excludeStart03?
				exclude =  1
			endif
			
			temp = item[0,startLen04-1]
			if (CmpStr(temp,excludeStart04) == 0)			// Starts with excludeStart03?
				exclude =  1
			endif

			if (exclude)
				excludedList += item + ";"
			else
				outputList += item + ";"		
			endif
		endif
		
		index += 1
	while(1)
	
	return outputList
End

//Zoom button
Function ZoomFullProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			SetAxis/A
			break
	endswitch

	return 0
End

Function CleanPhaseProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			KillWaves root:Calibrants:list:phaselist
			Legend/K/N=phase
			break
	endswitch

	return 0
End