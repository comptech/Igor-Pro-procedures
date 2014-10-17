#pragma rtGlobals=1		// Use modern global access method.
Menu "Macros"
	"Make hkl d-spacing/8", Makehkl()
	"Calc Lattice Parameter/9", CalcLatticeParam()
End

Macro Makehkl(marker)
	String marker
	
	Make/O/N=1 $marker+"_h"
	Edit/K=0 $marker+"_h"
	Make/O/N=1 $marker+"_k"
	AppendToTable $marker+"_k"
	Make/O/N=1 $marker+"_l"
	AppendToTable $marker+"_l"
	Make/O/N=1 $marker+"_d"
	AppendToTable $marker+"_d"
	Make/O/N=1 $marker+"_d_s"
	AppendToTable $marker+"_d_s"
End

Macro CalcLatticeParam(marker)
	String marker
	
	System_Fit($marker+"_d", $marker+"_d_s", $marker+"_h", $marker+"_k",$marker+"_l",1)
End