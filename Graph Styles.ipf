#pragma rtGlobals=1		// Use modern global access method.

Proc XYBox() : GraphStyle
	PauseUpdate; Silent 1		// modifying window...
	ModifyGraph/Z gFont="Times New Roman",width=400,height={Aspect,0.8}
	ModifyGraph/Z tick=2
	ModifyGraph/Z mirror=2
	ModifyGraph/Z standoff=0
	Label/Z left "\\Z18Y_Axis (Unit)"
	Label/Z bottom "\\Z18X-Axis (Unit)"
EndMacro

Proc GraphStd() : GraphStyle
	PauseUpdate; Silent 1		// modifying window...
	ModifyGraph/Z gFont="Helvetica",width=450,height={Aspect,0.8}
	ModifyGraph/Z tick=2
	ModifyGraph/Z mirror=2
	ModifyGraph/Z standoff=0
	ModifyGraph fSize=18, axThick=1.5
	ModifyGraph gfSize=16
	ModifyGraph lblMargin(left)=2,lblMargin(bottom)=2
	ModifyGraph axOffset(left)=-2
	ModifyGraph axOffset(bottom)=-0.5
EndMacro

Proc GraphStd2() : GraphStyle
	PauseUpdate; Silent 1		// modifying window...
	ModifyGraph/Z gFont="Helvetica",width=200,height={Aspect,0.8}
	ModifyGraph/Z tick=2
	ModifyGraph/Z mirror=2
	ModifyGraph/Z standoff=0
	ModifyGraph fSize=18, axThick=1.0
	ModifyGraph gfSize=16
	ModifyGraph lblMargin(left)=5,lblMargin(bottom)=5
	ModifyGraph axOffset(left)=-1
	ModifyGraph axOffset(bottom)=-1
EndMacro

Proc LayoutStd() : LayoutStyle
	PauseUpdate; Silent 1		// modifying window...
	Layout/C=1/W=(120,44,750,753)
	ModifyLayout mag=1
EndMacro

Proc SMSData() : GraphStyle
	PauseUpdate; Silent 1
	ModifyGraph gFont="Helvetica",gfSize=16,width=288,height={Aspect,0.5}
	ModifyGraph log(left)=1
	ModifyGraph tick=2
	ModifyGraph mirror=2
	ModifyGraph fSize=18
	ModifyGraph lblMargin(left)=18,lblMargin(bottom)=3
	ModifyGraph standoff=0
	ModifyGraph axOffset=-1
	ModifyGraph axThick=1.5
	SetAxis bottom 20,130
	ModifyGraph mirror(bottom)=1
	ModifyGraph noLabel(bottom)=2
	Label left "\\Z22Log Counts"
EndMacro

Function SaveFig()
	SavePICT/C=2/EF=1/E=-3
	SavePICT/O/E=-6/RES=300
End