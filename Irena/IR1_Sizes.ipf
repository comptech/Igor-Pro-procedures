#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 2.02
#include "IN2_GeneralProcedures", version>=1.41	//we need functions from this file

//version 2.02 edited 11/9/2005 - added weighing by Q^N to all methods
// version 2.01 edited 2/5/2005 	-	added NNLS - interior point gradient method
// version 1.50 edited on 4/10/2004 - added maximum entropy.

// Interior point method for totally nonnegative least square method used is by:
//	Michael Merrit and Yin Zhang, Technical report TR04-08
//	Department of Computational and Applied Mathematics
//	Rice University, Houston, Texas, 77005, USA
//	from May 2004
//	found on the web posted in December 2004:
//	http://www.caam.rice.edu/caam/trs/2004/TR04-08.pdf


// The code in this procedure file is conversion of Fortran and C source code from Pete Jemian, with other credits listed below.
// The code has been debugged and verified WRT to the compiled source code.
// 
//C       Analysis of small-angle scattering data using the technique of
//C       entropy maximization.
//
//
//C   Adapted from the program MAXE.FOR
//
//
//C       Credits:
//C       G.J. Daniell, Dept. of Physics, Southampton University, UK
//C       J.A. Potton, UKAEA Harwell Laboratory, UK
//C       I.D. Culverwell, UKAEA Harwell Laboratory, UK
//C       G.P. Clarke, UKAEA Harwell Laboratory, UK
//C       A.J. Allen, UKAEA Harwell Laboratory, UK
//C       P.R. Jemian, Northwestern University, USA
//
//
//C       References:
//C       1. J Skilling and RK Bryan; MON NOT R ASTR SOC
//C               211 (1984) 111 - 124.
//C       2. JA Potton, GJ Daniell, and BD Rainford; Proc. Workshop
//C               Neutron Scattering Data Analysis, Rutherford
//C               Appleton Laboratory, UK, 1986; ed. MW Johnson,
//C               IOP Conference Series 81 (1986) 81 - 86, Institute
//C               of Physics, Bristol, UK.
//C       3. ID Culverwell and GP Clarke; Ibid. 87 - 96.
//C       4. JA Potton, GK Daniell, & BD Rainford,
//C               J APPL CRYST 21 (1988) 663 - 668.
//C       5. JA Potton, GJ Daniell, & BD Rainford,
//C               J APPL CRYST 21 (1988) 891 - 897.
//
//
//C       This progam was written in BASIC by GJ Daniell and later
//C         translated into FORTRAN and adapted for SANS analysis.  It
//C         has been further modified by AJ Allen to allow use with a
//C         choice of particle form factors for different shapes.  It
//C         was then modified by PR Jemian to allow portability between
//C         the Digital Equipment Corporation VAX and Apple Macintosh
//C         computers.
//
//

//this is Sizes procedure.
//this is list of procedures:
//	Data input is done by
	//IR1R_SelectAndCopyData()			//Procedure which loads data and sets work folder
	//IR1R_SetupFittingParameters()		//sets up the graph and panel to control the Sizes
	//
//	Calculate G[][]		done for spheres,
	//procedures:		GenerateShapeFunction()
	//				CalculateSphereFormFactor(FRwave,Qw,radius)	
	//				CalculateSphereFFPoints(Qvalue,radius)
	//				NormalizationFactorSphere(radius)
	//
	//	Units handling:
	//	drho^2 is in 10^20 cm-4, G matrix calculations need to be in cm, so volume of 
	//	particles is in cm3 (10-24 A3) and width of the sectors is in cm.
	//
	//
	//
//	Calculate H matrix	done,
	//procedures:		MakeHmatrix()
	//
//	CalculateBVector()	done, single procedure
	//makes new B vector and calculates values from G, Int and errors
	//	
//	CalculateDMatrix()
	//calculates D matrix from G[][] and errors
	//
//	CalculateAvalue()
	//calculates the A[][]= d[][] + a * H[][]
	//
//	FindOptimumAvalue(Evalue)	
	//does the fitting itself, call with precision (e~0.1 or so)
	// procedures : 	CalculateCvalue()	
	//				
	//this function does the whole Sizes procedure
	//List of waves, vectors, and matrixes
	//	works in root:Packages:Sizes
	//	Intensity	[M]
	//	Error	[M]
	//	Q_vec	[M]
	//	R_distribution	[N]		contains distribution of radia for particles, defines number of points in solution
	//	G_matrix		[M] [N]	Shape matrix, for now spheres
	//	H_matrix		[N] [N]	Constraint matrix, here done for second derivative
	//	B_vector		[N]			
	//	A_matrix	[N][N]
	//	D_matrix	[M][N]
	//	Evalue					precision, for now hardwired to 0.1
	//	Difference		chi squared sum of the difference value between the fit and measured intensity		
//units used:
//	All units internally are in A - Radius and Q ([A^-1]). 
//
//
//****************************************
// Main Evaluation procedure:
//****************************************
Function IR1R_Sizes()

	IN2G_CheckScreenSize("height",670)

	DoWindow IR1R_SizesInputGraph
	if (V_Flag)
		DoWindow/K IR1R_SizesInputGraph	
	endif
	DoWindow IR1R_SizesInputPanel
	if (V_Flag)
		DoWindow/K IR1R_SizesInputPanel	
	endif
	IR1R_InitializeSizes()	
	IR1T_InitFormFactors()
//	IR1_KillGraphsAndPanels()
	Execute("IR1R_SizesInputPanel()")				//this panel
	IR1R_FixSetVarsInPanel()
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR1R_FixSetVarsInPanel()

		SVAR ShapeType=root:Packages:Sizes:ShapeType
		PopupMenu ShapeModel,mode=1,popvalue=ShapeType,win=IR1R_SizesInputPanel
		SetVariable AspectRatio,disable=1,win=IR1R_SizesInputPanel
		SetVariable CoreShellThickness,disable=1,win=IR1R_SizesInputPanel
		SetVariable CoreShellCoreRho,disable=1,win=IR1R_SizesInputPanel
		SetVariable CoreShellShellRho,disable=1,win=IR1R_SizesInputPanel
		SetVariable CoreShellSolvntRho,disable=1,win=IR1R_SizesInputPanel
		SetVariable CylinderLength,disable=1,win=IR1R_SizesInputPanel
		SetVariable FractalRadiusOfPriPart,disable=1,win=IR1R_SizesInputPanel
		SetVariable FractalDimension,disable=1,win=IR1R_SizesInputPanel
		SetVariable TubeLength,disable=1,win=IR1R_SizesInputPanel
		SetVariable TubeWallThickness,disable=1,win=IR1R_SizesInputPanel
		SetVariable AspectRatio,disable=1	,win=IR1R_SizesInputPanel
		SetVariable ScatteringContrast,disable=0,win=IR1R_SizesInputPanel

		if (cmpstr(ShapeType,"Fractal Aggregate")==0)
			SetVariable FractalRadiusOfPriPart,disable=0,win=IR1R_SizesInputPanel
			SetVariable FractalDimension,disable=0,win=IR1R_SizesInputPanel
		elseif(cmpstr(ShapeType,"Cylinder")==0)	
			SetVariable CylinderLength,disable=0,win=IR1R_SizesInputPanel
		elseif(cmpstr(ShapeType,"Unified_Sphere")==0)	
		
		elseif(cmpstr(ShapeType,"Unified_Disk")==0)	
			SetVariable AspectRatio,disable=0,win=IR1R_SizesInputPanel, title="Disk thickness [A] ", help={"thickness of the disk in A"}
		elseif(cmpstr(ShapeType,"Unified_Rod")==0)	
			SetVariable AspectRatio,disable=0,win=IR1R_SizesInputPanel, title="Rod Length [A] ", help={"length of the rod, in A"}
		elseif(cmpstr(ShapeType,"CoreShell")==0)	
			SetVariable ScatteringContrast,disable=1	,win=IR1R_SizesInputPanel
			SetVariable CoreShellThickness,disable=0,win=IR1R_SizesInputPanel
			SetVariable CoreShellCoreRho,disable=0,win=IR1R_SizesInputPanel
			SetVariable CoreShellShellRho,disable=0,win=IR1R_SizesInputPanel
			SetVariable CoreShellSolvntRho,disable=0,win=IR1R_SizesInputPanel
		elseif(cmpstr(ShapeType,"Unified_Tube")==0)	
			SetVariable ScatteringContrast,disable=0,win=IR1R_SizesInputPanel
			SetVariable TubeLength,disable=0,win=IR1R_SizesInputPanel
			SetVariable TubeWallThickness,disable=0,win=IR1R_SizesInputPanel
		elseif(cmpstr(ShapeType,"Tube")==0)	
			SetVariable ScatteringContrast,disable=1	,win=IR1R_SizesInputPanel
			SetVariable TubeLength,disable=0,win=IR1R_SizesInputPanel
			SetVariable TubeWallThickness,disable=0,win=IR1R_SizesInputPanel
			SetVariable CoreShellCoreRho,disable=0,win=IR1R_SizesInputPanel
			SetVariable CoreShellShellRho,disable=0,win=IR1R_SizesInputPanel
			SetVariable CoreShellSolvntRho,disable=0,win=IR1R_SizesInputPanel
		elseif(cmpstr(ShapeType,"User")==0)	
			DoWindow IR1R_SizesUserFFInputPanel
			if(V_Flag)
				DoWindow/K IR1R_SizesUserFFInputPanel
			endif
			Execute("IR1R_SizesUserFFInputPanel()")
		else
			SetVariable AspectRatio,disable=0,win=IR1R_SizesInputPanel, title="Aspect Ratio ", help={"Aspect ratio for spheroids and other particles with AR"}
		endif
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1R_SizesFitting(ctrlName) : ButtonControl			//this function is called by button from the panel
	String ctrlName

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes
	
	DoWindow/F IR1R_SizesInputGraph				//pulls the control graph, in case it is not the top...
	if ( ((strlen(CsrWave(A))!=0) && (strlen(CsrWave(B))!=0) ) && (pcsr (A)!=pcsr (B)) )	//this should make sure, that both cursors are in the graph and not on the same point
		//make sure the cursors are on the right waves..
		Wave QvectorTmp=root:Packages:Sizes:Q_vecOriginal
		if (cmpstr(CsrWave(A, "IR1R_SizesInputGraph"),"IntensityOriginal")!=0)
			Cursor/P/W=IR1R_SizesInputGraph A  IntensityOriginal  binarysearch(QvectorTmp, CsrXWaveRef(A) [pcsr(A, "IR1R_SizesInputGraph")])
		endif
		if (cmpstr(CsrWave(B, "IR1R_SizesInputGraph"),"IntensityOriginal")!=0)
			Cursor/P /W=IR1R_SizesInputGraph B  IntensityOriginal  binarysearch(QvectorTmp,CsrXWaveRef(B) [pcsr(B, "IR1R_SizesInputGraph")])
		endif
	endif
	
	IR1R_FinishSetupOfRegParam()					//finishes the setup of parametes for Sizes

	SVAR SlitSmearedData=root:Packages:Sizes:SlitSmearedData	
	if (cmpstr(SlitSmearedData, "Yes")==0)				//if we are working with slit smeared data
		IR1R_ExtendQVecForSmearing()				//here we extend them by slitLength
	endif		

	//testing....	New Formfactor calculations Check that the G matrix actually exists. We need it... 
	//we will setup only form factor G matrix G_matrixFF, which will be scaled by contrats later on...
	Wave/Z G_matrixFF=root:Packages:Sizes:G_matrixFF
	Wave Q_vec=root:Packages:Sizes:Q_vec
	Wave R_distribution=root:Packages:Sizes:R_distribution
	variable M=numpnts(Q_vec)
	variable N=numpnts(R_distribution)
	if(!WaveExists(G_matrixFF))
		Make/D/O/N=(M,N) $("G_matrixFF")
		Wave G_matrixFF=root:Packages:Sizes:G_matrixFF	
	endif	
	//now need to set the particle parameters according to used particle shape model...
		//Algebraic_Integrated Spheres		no parameter needed
		//Algebraic_Globules		AspectRatio = ParticlePar1
		//Algebraic_Rods			AspectRatio = ParticlePar1
		//Algebraic_Disks			AspectRatio = ParticlePar1
		//Integrated_Spheroid		AspectRatio=ParticlePar1
		//	spheroid				AspectRatio = ParticlePar1

		//Cylinders				CylinderLength=ParticlePar1

		//	Fractal aggregate	 	FractalRadiusOfPriPart=ParticlePar1=root:Packages:Sizes:FractalRadiusOfPriPart	//radius of primary particle
		//						 FractalDimension=ParticlePar2=root:Packages:Sizes:FractalDimension			//Fractal dimension
		//Tube 					length=ParticlePar1						//length in A
		//						WallThickness=ParticlePar2				//in A
		//						CoreRho=ParticlePar3			// rho for core material
		//						ShellRho=ParticlePar4			// rho for shell material
		//						SolventRho=ParticlePar5			// rho for solvent material
		//CoreShell				CoreShellThickness=ParticlePar1			//skin thickness in Angstroems
		//						CoreRho=ParticlePar2		// rho for core material
		//						ShellRho=ParticlePar3			// rho for shell material
		//						SolventRho=ParticlePar4			// rho for solvent material

	//AspectRatio;FractalRadiusOfPriPart;FractalDimension;CylinderLength;TubeLength;
	//CylinderLength;CoreShellThicknessRatio;CoreShellContrastRatio;TubeWallThickness;TubeCoreContrastRatio
	
	variable ParticlePar1=0,ParticlePar2=0,ParticlePar3=0,ParticlePar4=0,ParticlePar5=0
	SVAR ShapeType=root:Packages:Sizes:ShapeType
	NVAR AspectRatio=root:Packages:Sizes:AspectRatio

	if(cmpstr(ShapeType,"Algebraic_Integrated Spheres")==0)		//no parameter at all - it is sphere
		//no parameter
	elseif(cmpstr(ShapeType,"Cylinders")==0)						//Cylinder 1 poarameter - length
		NVAR CylinderLength=root:Packages:Sizes:CylinderLength	//CylinderLength
		ParticlePar1=CylinderLength
	elseif(cmpstr(ShapeType,"User")==0)						//Cylinder 1 poarameter - length
		NVAR ParticlePar1G=root:Packages:Sizes:UserFFpar1
		ParticlePar1=ParticlePar1G
		NVAR ParticlePar2G=root:Packages:Sizes:UserFFpar2
		ParticlePar2=ParticlePar2G
		NVAR ParticlePar3G=root:Packages:Sizes:UserFFpar3
		ParticlePar3=ParticlePar3G
		NVAR ParticlePar4G=root:Packages:Sizes:UserFFpar4
		ParticlePar4=ParticlePar4G
		NVAR ParticlePar5G=root:Packages:Sizes:UserFFpar5
		ParticlePar5=ParticlePar5G
	elseif(cmpstr(ShapeType,"CoreShell")==0)				//CoreShell - 2 parameters
		NVAR CoreShellThickness=root:Packages:Sizes:CoreShellThickness	//radius of primary particle
		ParticlePar1=CoreShellThickness
		NVAR CoreShellCoreRho=root:Packages:Sizes:CoreShellCoreRho	
		ParticlePar2=CoreShellCoreRho	
		NVAR CoreShellShellRho=root:Packages:Sizes:CoreShellShellRho	
		ParticlePar3=CoreShellShellRho	
		NVAR CoreShellSolvntRho=root:Packages:Sizes:CoreShellSolvntRho	
		ParticlePar4=CoreShellSolvntRho	
	elseif(cmpstr(ShapeType,"Fractal aggregate")==0)				//Fractal aggregate - 2 parameters
		NVAR FractalRadiusOfPriPart=root:Packages:Sizes:FractalRadiusOfPriPart	//radius of primary particle
		ParticlePar1=FractalRadiusOfPriPart
		NVAR FractalDimension=root:Packages:Sizes:FractalDimension	
		ParticlePar2=FractalDimension	
	elseif(cmpstr(ShapeType,"Tube")==0)				//Tube - 3 parameters
		NVAR TubeLength=root:Packages:Sizes:TubeLength			//TubeLength
		ParticlePar1=TubeLength
		NVAR TubeWallThickness=root:Packages:Sizes:TubeWallThickness		//WallThickness
		ParticlePar2=TubeWallThickness	
		NVAR CoreShellCoreRho=root:Packages:Sizes:CoreShellCoreRho	
		ParticlePar3=CoreShellCoreRho	
		NVAR CoreShellShellRho=root:Packages:Sizes:CoreShellShellRho	
		ParticlePar4=CoreShellShellRho	
		NVAR CoreShellSolvntRho=root:Packages:Sizes:CoreShellSolvntRho	
		ParticlePar5=CoreShellSolvntRho	
	elseif(cmpstr(ShapeType,"Unified_Tube")==0)				//Tube - 3 parameters
		NVAR TubeLength=root:Packages:Sizes:TubeLength			//TubeLength
		ParticlePar1=TubeLength
		NVAR TubeWallThickness=root:Packages:Sizes:TubeWallThickness		//WallThickness
		ParticlePar2=TubeWallThickness	
	else												//the ones which require 1 parameter - aspect ratio or (Unif) thickness/length
		ParticlePar1=AspectRatio
	endif
	SVAR User_FormFactorFnct=root:Packages:Sizes:User_FormFactorFnct
	SVAR User_FormFactorVol=root:Packages:Sizes:User_FormFactorVol
	//end setup parameters...
	IR1T_GenerateGMatrix(G_matrixFF, Q_vec,R_distribution,1,ShapeType,ParticlePar1,ParticlePar2,ParticlePar3,ParticlePar4,ParticlePar5,User_FormFactorFnct,User_FormFactorVol)

	//now handle the contarst by copying data into the G_matrix
	Duplicate/O G_matrixFF, G_matrix		//G_matrixFF (root:Packages:Sizes:G_matrixFF)  contains form factor without contrast
	Wave G_matrix=root:Packages:Sizes:G_matrix
	NVAR ScatteringContrast=root:Packages:Sizes:ScatteringContrast
	
	if(cmpstr(ShapeType,"CoreShell")==0 || cmpstr(ShapeType,"Tube")==0)	
		G_matrix=G_matrixFF * 1e20		//this case the contrast is part of the calculations already... 
	else
		G_matrix=G_matrixFF * ScatteringContrast*1e20		//this multiplyies by scattering contrast
	endif
	//done with G matrix processing, if it slit smeared let's fix it and that is all....
	if (cmpstr(SlitSmearedData, "Yes")==0)				//if we are working with slit smeared data
		IR1R_SmearGMatrix()							//here we smear the Columns in the G matrix
		IR1R_ShrinkGMatrixAfterSmearing()			//here we cut the G matrix back in length
	endif		

	NVAR UseRegularization=root:Packages:Sizes:UseRegularization
	NVAR UseMaxEnt=root:Packages:Sizes:UseMaxEnt
	NVAR UseTNNLS=root:Packages:Sizes:UseTNNLS
	if(UseTNNLS+UseMaxEnt+UseRegularization !=1)
		abort "Bad use variables in the IR1R_SizesFitting function"
	endif
	SVAR MethodRun=root:Packages:Sizes:MethodRun
	MethodRun = ""
	if (UseMaxEnt)		//run internal maxEnt
		IR1R_DoInternalMaxent()						//run Maximum Entropy 
		MethodRun="MaxEnt"
	elseif (UseTNNLS)		//run internal maxEnt
		MethodRun="NNLS"
		IR1R_DoNNLS()						//run TNNLS 
	else												//regularization
		IR1R_DoInternalRegularization()				//run regularization
		MethodRun="Regularization"
	endif
	
	SVAR SizesParameters=root:Packages:Sizes:SizesParameters
	SizesParameters=ReplaceStringByKey("MethodRun", SizesParameters, MethodRun,"=")

	IR1R_FinishGraph()								//finish the graph to proper shape
	
	setDataFolder OldDf
end	

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
static  Function IR1R_DoInternalRegularization()

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes

	NVAR SizesPowerToUse=root:Packages:Sizes:SizesPowerToUse
	NVAR UseNoErrors=root:Packages:Sizes:UseNoErrors
	
	//Now we need to create new waves with data scaled by Int^N to provide fitting in more ballanced space...
	Wave Q_vec=root:Packages:Sizes:Q_vec
	Wave Intensity=root:Packages:Sizes:Intensity
	Wave Errors=root:Packages:Sizes:Errors
	Wave G_matrix=root:Packages:Sizes:G_matrix
	Duplicate/O Intensity, IntensityQ2N
	Duplicate/O Errors, ErrorsQ2N
	Duplicate/O G_matrix, G_matrixQ2N
	Duplicate/O Q_vec, QvectorP
	
	if(UseNoErrors)	//ONLY, if no errors were provided by user... 
		IntensityQ2N=Intensity*Q_vec^SizesPowerToUse
		ErrorsQ2N=Errors*Q_vec^SizesPowerToUse
		QvectorP = Q_vec^SizesPowerToUse
		G_matrixQ2N[][] = G_matrix[p][q] * QvectorP[p]
	endif


		IR1R_MakeHmatrix()				//creates H matrix
		
		IR1R_CalculateBVector()			//creates B vector
	
		IR1R_CalculateDMatrix()			//creates D matrix
	
		IR1R_SetupDiagnostics()			//setup diagnostics graphs if needed
	
		//variable Evalue=0.1				//may not be needed in the future
		NVAR Evalue=root:Packages:Sizes:MaxEntStabilityParam
		NVAR NumberIterations=root:Packages:Sizes:NumberIterations

		NumberIterations=IR1R_FindOptimumAvalue(Evalue)	//does the  fitting for given e value, for now set here to a value 0.1

		Wave CurrentResultSizeDistribution = root:Packages:Sizes:CurrentResultSizeDistribution
		Wave SizesFitIntensity=root:Packages:Sizes:SizesFitIntensity
		Wave NormalizedResidual=root:Packages:Sizes:NormalizedResidual

		NVAR Chisquare=root:Packages:Sizes:Chisquare
	
		if ((numtype(NumberIterations)!=0)||(numberIterations>numpnts(SizesFitIntensity)))	//no solution found
			SizesFitIntensity=0
			CurrentResultSizeDistribution = 0
			NormalizedResidual = 0
			Chisquare = 0			//new Chisquared
		endif
		setDataFolder OldDf
	
end 
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
static    Function IR1R_DoInternalMaxent()
	
	string OldDf=GetDataFolder(1)
	SetDataFolder root:Packages:Sizes
	
	Wave Intensity=root:Packages:Sizes:Intensity
	Wave Q_vec=root:Packages:Sizes:Q_vec
	Wave Errors=root:Packages:Sizes:Errors
	Wave G_matrix= root:Packages:Sizes:G_matrix
	Wave R_distribution=root:Packages:Sizes:R_distribution
	Wave ModelDistribution=root:Packages:Sizes:ModelDistribution
	Wave InitialModelBckg=root:Packages:Sizes:InitialModelBckg
	Wave NormalizedResidual=root:Packages:Sizes:NormalizedResidual

	NVAR NumberIterations=root:Packages:Sizes:NumberIterations
	NVAR MaxsasNumIter=root:Packages:Sizes:MaxsasNumIter
	NVAR MaxEntSkyBckg=root:Packages:Sizes:MaxEntSkyBckg
	NVAR blank=root:Packages:Sizes:blank
	NVAR MaxsasNumIter=root:Packages:Sizes:MaxsasNumIter
	NVAR MaxEntStabilityParam=root:Packages:Sizes:MaxEntStabilityParam
	NVAR Chisquare=root:Packages:Sizes:Chisquare
	NVAR SizesPowerToUse=root:Packages:Sizes:SizesPowerToUse
	NVAR UseNoErrors=root:Packages:Sizes:UseNoErrors
	//Now we need to create new waves with data scaled by Int^N to provide fitting in more ballanced space...
	
	Duplicate/O Intensity, IntensityQ2N
	Duplicate/O Errors, ErrorsQ2N
	Duplicate/O G_matrix, G_matrixQ2N
	Duplicate/O Q_vec, QvectorP
	if(UseNoErrors)		//ONLY, if no errros provided by user...
		IntensityQ2N=Intensity*Q_vec^SizesPowerToUse
		ErrorsQ2N=Errors*Q_vec^SizesPowerToUse
		QvectorP = Q_vec^SizesPowerToUse
		G_matrixQ2N[][] = G_matrix[p][q] * QvectorP[p]
	endif
	InitialModelBckg=MaxEntSkyBckg
	ModelDistribution=InitialModelBckg
	blank = MaxEntSkyBckg
	NumberIterations=0

	IR1R_SetupDiagnostics()			//setup diagnostics graphs if needed
	
//	NumberIterations=IR1R_MaximumEntropy(Intensity,Errors,InitialModelBckg,MaxsasNumIter,ModelDistribution,MaxEntStabilityParam,IR1R_Opus,IR1R_Tropus,IR1R_MaxEntUpdateDataForGrph)
	NumberIterations=IR1R_MaximumEntropy(IntensityQ2N,ErrorsQ2N,InitialModelBckg,MaxsasNumIter,ModelDistribution,MaxEntStabilityParam,IR1R_Opus,IR1R_Tropus,IR1R_MaxEntUpdateDataForGrph)

	Wave ox=root:Packages:Sizes:ox
	Wave zscratch=root:Packages:Sizes:zscratch
	Wave zscratch2=root:Packages:Sizes:zscratch2
	

	if ((numtype(NumberIterations)!=0)||(numberIterations>=MaxsasNumIter))	//no solution found
		ox=0
		Chisquare =NaN
		IR1R_MaxEntUpdateDataForGrph()
	else
		IR1R_Opus(ModelDistribution,ox)						//calculate ox model result from Model
		zscratch = ( Intensity[p] - ox[p]) / Errors[p]	//residuals
		zscratch2 = zscratch^2
		Chisquare = sum(zscratch2)			//new Chisquared
	endif


	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR1R_MaxEntUpdateDataForGrph()

	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes
	//copy data to update graph
	Wave/Z CurrentResultSizeDistribution = root:Packages:Sizes:CurrentResultSizeDistribution
	Wave ModelDistribution=root:Packages:Sizes:ModelDistribution
	Wave NormalizedResidual=root:Packages:Sizes:NormalizedResidual
	Wave Intensity=root:Packages:Sizes:Intensity
	Wave Errors=root:Packages:Sizes:Errors
	Wave Q_vec=root:Packages:Sizes:Q_vec
	NVAR SizesPowerToUse=root:Packages:Sizes:SizesPowerToUse
	NVAR UseNoErrors=root:Packages:Sizes:UseNoErrors
	
	Duplicate/O ModelDistribution, CurrentResultSizeDistribution
	Wave/Z SizesFitIntensity=root:Packages:Sizes:SizesFitIntensity
	Wave ox=root:Packages:Sizes:ox
	Duplicate/O ox, SizesFitIntensity
	
	if(UseNoErrors)
		SizesFitIntensity = ox/Q_vec^SizesPowerToUse
	endif
	if(sum(ox)==0)		//fit not found, zero everything
		CurrentResultSizeDistribution = 0
		NormalizedResidual = 0
	else
		CurrentResultSizeDistribution = ModelDistribution/2					//convert data into radia
		NormalizedResidual = (Intensity - SizesFitIntensity)/Errors
	endif
	
//	variable i
//	For(i=0;i<numpnts(ModelDistribution);i+=1)
		CurrentResultSizeDistribution = CurrentResultSizeDistribution[p] / IR1R_BinWidthInRadia(p)
//	endfor

	NVAR SuggestedSkyBackground=root:Packages:Sizes:SuggestedSkyBackground		//make suggestion to user with new sky background
	NVAR MaxEntSkyBckg=root:Packages:Sizes:MaxEntSkyBckg
	wavestats/Q CurrentResultSizeDistribution
	SuggestedSkyBackground=V_max/100
	if((MaxEntSkyBckg > (5*SuggestedSkyBackground)) || (MaxEntSkyBckg < (0.2*SuggestedSkyBackground)))
		SetVariable SuggestedSkyBackground labelBack=(65280,0,0), win=IR1R_SizesInputPanel
		SetVariable SuggestedSkyBackground font="Times New Roman",fstyle=1, win=IR1R_SizesInputPanel
		Button SetMaxEntSkyBckg, fColor=(65280,0,0), win=IR1R_SizesInputPanel
	else
		SetVariable SuggestedSkyBackground labelBack=0, win=IR1R_SizesInputPanel
		SetVariable SuggestedSkyBackground font="Times New Roman",fstyle=0, win=IR1R_SizesInputPanel
		Button SetMaxEntSkyBckg, fColor=(0,0,0), win=IR1R_SizesInputPanel
	endif

	NVAR Chisquare=root:Packages:Sizes:Chisquare
	
	IR1R_FinishGraph()
	DoUpdate
	setDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1R_GraphDataButton(ctrlName) : ButtonControl			//this function is called by button from the panel
	String ctrlName

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes

		DoWIndow IR1R_SizesInputGraph
		if (V_Flag)
			DoWindow/K IR1R_SizesInputGraph
		endif

		IR1R_GraphIfAllowed(ctrlName)		

	DoWIndow/F IR1R_SizesInputPanel

	setDataFolder OldDf
end	

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1R_SelectAndCopyData()		//this function selects data to be used and copies them with proper names to Sizes folder

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes


	SVAR DataFolderName=root:Packages:Sizes:DataFolderName
	SVAR Intname=root:Packages:Sizes:IntensityWaveName
	SVAR Qname=root:Packages:Sizes:QWavename
	SVAR Ename=root:Packages:Sizes:ErrorWaveName
		NVAR UseNoErrors=root:Packages:Sizes:UseNoErrors
		NVAR UseUserErrors=root:Packages:Sizes:UseUserErrors
		NVAR UseSQRTErrors=root:Packages:Sizes:UseSQRTErrors
		NVAR UsePercentErrors=root:Packages:Sizes:UsePercentErrors

	
	Duplicate/O $(DataFolderName+Intname), root:Packages:Sizes:IntensityOriginal			//here goes original Intensity
	Redimension/D root:Packages:Sizes:IntensityOriginal
	Duplicate/O $(DataFolderName+Intname), root:Packages:Sizes:Intensity					//and its second copy, for fixing
	Redimension/D root:Packages:Sizes:Intensity
	Duplicate/O $(DataFolderName+Qname), root:Packages:Sizes:Q_vec					//Q vector 
	Redimension/D root:Packages:Sizes:Q_vec
	Duplicate/O $(DataFolderName+Qname), root:Packages:Sizes:Q_vecOriginal				//second copy of the Q vector
	Redimension/D root:Packages:Sizes:Q_vecOriginal
	Wave/Z ErrorOrg=$(DataFolderName+Ename)
	if(WaveExists(ErrorOrg))
		Duplicate/O $(DataFolderName+Ename), root:Packages:Sizes:Errors						//errors
		Redimension/D root:Packages:Sizes:Errors
		Duplicate/O $(DataFolderName+Ename), root:Packages:Sizes:ErrorsOriginal
		Redimension/D root:Packages:Sizes:ErrorsOriginal
		UseNoErrors = 0
		UseUserErrors=1
		UseSQRTErrors=0
		UsePercentErrors=0
		SetVariable ErrorMultiplier,disable=!(UseUserErrors||UseSQRTErrors), WIN=IR1R_SizesInputPanel
		SetVariable PercentErrorToUse, disable=!(UsePercentErrors), WIN=IR1R_SizesInputPanel
		PopupMenu SizesPowerToUse, disable=!(UseNoErrors), WIN=IR1R_SizesInputPanel
	else	//errors do nto exist, create errors with 0 in them...
		Duplicate/O $(DataFolderName+Intname), root:Packages:Sizes:Errors						//errors
		Redimension/D root:Packages:Sizes:Errors
		Duplicate/O $(DataFolderName+Intname), root:Packages:Sizes:ErrorsOriginal
		Redimension/D root:Packages:Sizes:ErrorsOriginal
		wave Err1=root:Packages:Sizes:Errors
		Err1=0
		wave Err2=root:Packages:Sizes:ErrorsOriginal
		Err2=0
		UseNoErrors = 1
		UseUserErrors=0
		UseSQRTErrors=0
		UsePercentErrors=0
		SetVariable ErrorMultiplier,disable=!(UseUserErrors||UseSQRTErrors), WIN=IR1R_SizesInputPanel
		SetVariable PercentErrorToUse, disable=!(UsePercentErrors), WIN=IR1R_SizesInputPanel
		PopupMenu SizesPowerToUse, disable=!(UseNoErrors), WIN=IR1R_SizesInputPanel
	endif
	
//	IR1L_AppendAnyText("\r************************************\r")
//	IR1L_AppendAnyText("Started Size distribution fitting procedure")
//	IR1L_AppendAnyText("Data:  \t"+DataFolderName)
	

	SVAR/Z SlitSmearedData=root:Packages:Sizes:SlitSmearedData
	If (!SVAR_Exists(SlitSmearedData))
		string/G SlitSmearedData="No"
		SVAR SlitSmearedData=root:Packages:Sizes:SlitSmearedData
	endif
	if (stringMatch(IntName,"*SMR*"))								//if we are working with slit smeared data
		SlitSmearedData="Yes"									//lets set user the switch
	else
		SlitSmearedData="No"
	endif		

//	string/G fldrName=DataFolderName									//record parameters there
	String/G SizesParameters
	SizesParameters=ReplaceStringByKey("SizesDataFrom", SizesParameters, DataFolderName,"=")
	SizesParameters=ReplaceStringByKey("SizesIntensity", SizesParameters, Intname,"=")
	SizesParameters=ReplaceStringByKey("SizesQvector", SizesParameters, Qname,"=")
	SizesParameters=ReplaceStringByKey("SizesError", SizesParameters, Ename,"=")
	
	Wave IntensityOriginal=root:Packages:Sizes:IntensityOriginal
	Wave ErrorsOriginal=root:Packages:Sizes:ErrorsOriginal

	Duplicate/O IntensityOriginal BackgroundWave			//this background wave is to help user to subtract background
	Duplicate/O IntensityOriginal DeletePointsMaskWave		//this wave is used to delete points by using this as amark wave and seting points to 
	Duplicate/O ErrorsOriginal DeletePointsMaskErrorWave		//delete to NaN. Then Intensity is at appropriate time mulitplied by this wave (and divided)
	IR1R_UpdateErrorWave()
														//to set points to delete to NaNs
	DeletePointsMaskWave=7								//this is symbol number used...
	NVAR Bckg=root:Packages:Sizes:Bckg
	BackgroundWave=Bckg

	NVAR SlitLength=root:Packages:Sizes:SlitLength
	SlitLength=NumberByKey("SlitLength", Note(IntensityOriginal), "=")
	
	Execute("IR1R_SizesInputGraph()")				//this creates the graph
//	IN2G_AutoAlignGraphAndPanel()						//this aligns them together
	setDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1R_UpdateErrorWave()

	//let's use this now also to display user messing up the errors...
		NVAR UsePercentErrors=root:Packages:Sizes:UsePercentErrors
		NVAR PercentErrorToUse=root:Packages:Sizes:PercentErrorToUse
		NVAR ErrorsMultiplier=root:Packages:Sizes:ErrorsMultiplier
		NVAR UseNoErrors=root:Packages:Sizes:UseNoErrors
		NVAR UseUserErrors=root:Packages:Sizes:UseUserErrors
		NVAR UseSQRTErrors=root:Packages:Sizes:UseSQRTErrors
		NVAR UsePercentErrors=root:Packages:Sizes:UsePercentErrors
		Wave DeletePointsMaskErrorWave=root:Packages:Sizes:DeletePointsMaskErrorWave
		Wave ErrorsOriginal=root:Packages:Sizes:ErrorsOriginal
		Wave IntensityOriginal=root:Packages:Sizes:IntensityOriginal
		
		if(UsePercentErrors)
			DeletePointsMaskErrorWave = IntensityOriginal * PercentErrorToUse / 100
			Smooth 5, DeletePointsMaskErrorWave
		elseif(UseNoErrors)
			DeletePointsMaskErrorWave = 0
		elseif(UseSQRTErrors)
			DeletePointsMaskErrorWave = sqrt(IntensityOriginal) * ErrorsMultiplier
			Smooth 5, DeletePointsMaskErrorWave
		elseif(UseUserErrors)
			DeletePointsMaskErrorWave = ErrorsOriginal * ErrorsMultiplier
		endif
end

//*****************************************************************************************************************
//*****************************************************************************************************************


Window IR1R_SizesUserFFInputPanel() 
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(306,271,666,604) as "IR1R_SizesUserFFInputPanel"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 16,fstyle= 1,textrgb= (0,0,65280)
	DrawText 31,28,"User form factor parameters"
	DrawText 11,55,"These are parameters for user defined form factor"
	DrawText 11,73,"The meaning and need for them depends"
	DrawText 11,92," on user function, set only the used ones"
	Button GetHelp,pos={55,104},size={120,20},proc=IR1R_UserFFButtonProc,title="Get Help"
	SetVariable FormFactorFunction,pos={6,140},size={350,16},title="Form Factor fnct: "
	SetVariable FormFactorFunction,help={"Name (as string), no quotes, no \"()\" of the form factor function"}
	SetVariable FormFactorFunction,value= root:Packages:Sizes:User_FormFactorFnct
	SetVariable VolumeOfFormFactorFnct,pos={6,167},size={350,16},title="Volume fnct:        "
	SetVariable VolumeOfFormFactorFnct,help={"Name (as string), no quotes, no \"()\" of the volume function for form factor"}
	SetVariable VolumeOfFormFactorFnct,value= root:Packages:Sizes:User_FormFactorVol
	SetVariable UserParam1,pos={46,194},size={250,16},title="Param1       "
	SetVariable UserParam1, help={"First parameter (in order) for the form factor and volume USER function"}
	SetVariable UserParam1,value= root:Packages:Sizes:UserFFpar1
	SetVariable UserParam2,pos={46,221},size={250,16},title="Param2       "
	SetVariable UserParam2,value= root:Packages:Sizes:UserFFpar2
	SetVariable UserParam2, help={"Second parameter (in order) for the form factor and volume USER function"}
	SetVariable UserParam3,pos={46,248},size={250,16},title="Param3       "
	SetVariable UserParam3,value= root:Packages:Sizes:UserFFpar3
	SetVariable UserParam3, help={"Third parameter (in order) for the form factor and volume USER function"}
	SetVariable UserParam4,pos={46,275},size={250,16},title="Param4       "
	SetVariable UserParam4,value= root:Packages:Sizes:UserFFpar4
	SetVariable UserParam4, help={"Fourth parameter (in order) for the form factor and volume USER function"}
	SetVariable UserParam5,pos={46,303},size={250,16},title="Param5       "
	SetVariable UserParam5,value= root:Packages:Sizes:UserFFpar5
	SetVariable UserParam5, help={"Fifth parameter (in order) for the form factor and volume USER function"}
EndMacro

Function IR1R_UserFFButtonProc(ctrlName) : ButtonControl
	String ctrlName
	if(cmpstr(ctrlName,"GetHelp")==0)
		//call the help notebook
		IR1T_GenerateHelpForUserFF()
	endif
End


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1R_InitializeSizes()			//dialog for radius wave creation, simple linear binning now.

	string OldDf
	OldDf=GetDataFolder(1)
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:Sizes
	
	//initializes the Maximum lentropy part of Sizes
	
	string ListOfVariables
	string ListOfStrings
	variable i
	//AspectRatio;FractalRadiusOfPriPart;FractalDimension;CylinderLength;TubeLength;
	//CylinderLength;CoreShellThicknessRatio;CoreShellContrastRatio;TubeWallThickness;TubeCoreContrastRatio

	ListOfVariables="Chisquare;blank;chizer;chitarg;fSum;UseIndra2Data;UseQRSdata;ShowDiagnostics;SuggestedSkyBackground;UseSlitSmearedData;"
	ListOfVariables+="MaxEntSkyBckg;MaxEntRegular;MaxsasNumIter;numOfPoints;SlitLength;Rmin;Rmax;Bckg;ScatteringContrast;Dmin;"
	ListOfVariables+="CurrentEntropy;CurrentChiSq;CurChiSqMinusAlphaEntropy;BinWidthInGMatrix;GraphLogTopAxis;GraphLogRightAxis;"
	ListOfVariables+="Dmax;ErrorsMultiplier;TicksForDiagnostics;MaxEntStabilityParam;NumberIterations;MaxEntNumIter;"	
	ListOfVariables+="AspectRatio;FractalRadiusOfPriPart;FractalDimension;CylinderLength;TubeLength;"
	ListOfVariables+="CylinderLength;TubeWallThickness;TubeCoreContrastRatio;"
	ListOfVariables+="CoreShellThickness;CoreShellCoreRho;CoreShellShellRho;CoreShellSolvntRho;"
	ListOfVariables+="UserFFpar1;UserFFpar2;UserFFpar3;UserFFpar4;UserFFpar5;"
	ListOfVariables+="NNLS_MaxNumIterations;NNLS_ApproachParameter;"
	ListOfVariables+="UseRegularization;UseMaxEnt;UseTNNLS;"
	ListOfVariables+="SizesPowerToUse;UseUserErrors;UseSQRTErrors;UsePercentErrors;PercentErrorToUse;UseNoErrors;"
	ListOfVariables+="StartFItQvalue;EndFItQvalue;"
	
//	ListOfStrings="DataFolderName;OriginalIntensityWvName;OriginalQvectorWvName;OriginalErrorWvName;SizesParameters;"
	ListOfStrings="DataFolderName;SizesParameters;"
	ListOfStrings+="LogDist;ShapeType;SlitSmearedData;MethodRun;User_FormFactorFnct;User_FormFactorVol;"	
	make/D/O/N=(3,3) flWv
	make/D/O/N=3 blWv
	
	make/D/O/N=0 CurrentEntropyW, CurrentChiSqW, CurChiSqMinusAlphaEntropyW

	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
								
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	
	SVAR User_FormFactorFnct
	if(strlen(User_FormFactorFnct)<1)
		User_FormFactorFnct="IR1T_ExampleSphereFFPoints"
	endif
	SVAR User_FormFactorVol
	if(strlen(User_FormFactorVol)<1)
		User_FormFactorVol="IR1T_ExampleSphereVolume"
	endif
	NVAR MaxEntNumIter=root:Packages:Sizes:MaxEntNumIter
	MaxEntNumIter=0
	SVAR MethodRun=root:Packages:Sizes:MethodRun
	MethodRun=""
	SVAR LogDist=root:Packages:Sizes:LogDist
	if (strlen(LogDist)==0)
		LogDist="yes"
	endif
	NVAR GraphLogTopAxis=root:Packages:Sizes:GraphLogTopAxis
	if(cmpstr(LogDist,"yes")==0)
		GraphLogTopAxis=1
	endif
	
	
	NVAR UseUserErrors
	NVAR UseSQRTErrors
	NVAR UsePercentErrors
	NVAR PercentErrorToUse
	NVAR UseNoErrors
	
	if(UseUserErrors+UseSQRTErrors+UsePercentErrors+UseNoErrors!=1)
		UseUserErrors=1
		UseSQRTErrors=0
		UsePercentErrors=0
		UseNoErrors=0
	endif
	if(PercentErrorToUse==0)
		PercentErrorToUse = 5
	endif

	NVAR UseRegularization=root:Packages:Sizes:UseRegularization
	NVAR UseMaxEnt=root:Packages:Sizes:UseMaxEnt
	NVAR UseTNNLS=root:Packages:Sizes:UseTNNLS
	if(UseRegularization+UseMaxEnt+UseTNNLS != 1)
		UseRegularization=0
		UseMaxEnt=1
		UseTNNLS=0
	endif

	NVAR SizesPowerToUse=root:Packages:Sizes:SizesPowerToUse
	NVAR NNLS_MaxNumIterations=root:Packages:Sizes:NNLS_MaxNumIterations
	if(NNLS_MaxNumIterations==0|| numtype(NNLS_MaxNumIterations)!=0)
		NNLS_MaxNumIterations=100
		SizesPowerToUse=2
	endif
	NVAR NNLS_ApproachParameter=root:Packages:Sizes:NNLS_ApproachParameter
	if(NNLS_ApproachParameter==0|| numtype(NNLS_ApproachParameter)!=0)
		NNLS_ApproachParameter=0.8
	endif
	
	NVAR SuggestedSkyBackground=root:Packages:Sizes:SuggestedSkyBackground
	if(SuggestedSkyBackground==0)
		SuggestedSkyBackground=1e-6
	endif
	SVAR ShapeType=root:Packages:Sizes:ShapeType
	if (strlen(ShapeType)==0)
		ShapeType="Spheroid"	
	endif
	SVAR SlitSmearedData=root:Packages:Sizes:SlitSmearedData
	if (strlen(SlitSmearedData)==0)
		SlitSmearedData="no"	
	endif
	NVAR MaxEntStabilityParam=root:Packages:Sizes:MaxEntStabilityParam
	if (MaxEntStabilityParam==0)
		MaxEntStabilityParam=0.01
	endif
	NVAR FractalRadiusOfPriPart=root:Packages:Sizes:FractalDimension
	if (FractalRadiusOfPriPart==0)
		FractalRadiusOfPriPart=10
	endif
	NVAR FractalDimension =root:Packages:Sizes:FractalDimension
	if (FractalDimension==0)
		FractalDimension=3		
	endif
	NVAR MaxEntSkyBckg=root:Packages:Sizes:MaxEntSkyBckg
	if (MaxEntSkyBckg==0)
		MaxEntSkyBckg=1e-6
	endif
	NVAR MaxEntRegular=root:Packages:Sizes:MaxEntRegular
	if (MaxEntRegular==0)
		MaxEntRegular=1
	endif
	NVAR MaxsasNumIter=root:Packages:Sizes:MaxsasNumIter
	if (MaxsasNumIter==0)
		MaxsasNumIter=100
	endif
	NVAR numOfPoints=root:Packages:Sizes:numOfPoints
	if (numOfPoints==0)
		numOfPoints=100
	endif
	NVAR AspectRatio	=root:Packages:Sizes:AspectRatio
	if (AspectRatio==0)
		AspectRatio=1
	endif
	NVAR Rmin=root:Packages:Sizes:Rmin
	if (Rmin==0)
		Rmin=25
	endif
	NVAR Rmax=root:Packages:Sizes:Rmax
	if (Rmax==0)
		Rmax=1000
	endif	
	NVAR Bckg=root:Packages:Sizes:Bckg
	if (Bckg==0)
		Bckg=0.1
	endif
	NVAR ScatteringContrast =root:Packages:Sizes:ScatteringContrast
	if (ScatteringContrast==0)
		ScatteringContrast=1
	endif
	NVAR Dmin=root:Packages:Sizes:Dmin
	if (Dmin==0)
		Dmin=25
	endif
	NVAR Dmax=root:Packages:Sizes:Dmax
	if (Dmax==0)
		Dmax=1000
	endif
	NVAR ErrorsMultiplier =root:Packages:Sizes:ErrorsMultiplier
	if (ErrorsMultiplier==0)
		ErrorsMultiplier=1
	endif
	NVAR BinWidthInGMatrix=root:Packages:Sizes:BinWidthInGMatrix
	BinWidthInGMatrix=0		//this is right setting, will default to this one...
	
	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1R_RecoverOldParameters()
	
	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes

	SVAR fldrName				=root:Packages:Sizes:DataFolderName
	NVAR MaxEntSkyBckg		=root:Packages:Sizes:MaxEntSkyBckg
	NVAR MaxEntRegular			=root:Packages:Sizes:MaxEntRegular
	NVAR MaxsasNumIter		=root:Packages:Sizes:MaxsasNumIter
	NVAR numOfPoints			=root:Packages:Sizes:numOfPoints
	NVAR AspectRatio			=root:Packages:Sizes:AspectRatio
	NVAR SlitLength				=root:Packages:Sizes:SlitLength
	NVAR Rmin					=root:Packages:Sizes:Rmin
	NVAR Rmax					=root:Packages:Sizes:Rmax
	NVAR Bckg					=root:Packages:Sizes:Bckg
	NVAR ScatteringContrast		=root:Packages:Sizes:ScatteringContrast
	NVAR Dmin					=root:Packages:Sizes:Dmin
	NVAR Dmax					=root:Packages:Sizes:Dmax
	NVAR ErrorsMultiplier			=root:Packages:Sizes:ErrorsMultiplier
	SVAR LogDist				=root:Packages:Sizes:LogDist
	SVAR ShapeType			=root:Packages:Sizes:ShapeType
	SVAR SlitSmearedData		=root:Packages:Sizes:SlitSmearedData
	SVAR MethodRun			=root:Packages:Sizes:MethodRun
	NVAR MaxEntStabilityParam	=root:Packages:Sizes:MaxEntStabilityParam
	NVAR MaxEntSkyBckg		=root:Packages:Sizes:MaxEntSkyBckg
	NVAR BinWidthInGMatrix		=root:Packages:Sizes:BinWidthInGMatrix

	NVAR SizesPowerToUse		=root:Packages:Sizes:SizesPowerToUse
	NVAR NNLS_MaxNumIterations	=root:Packages:Sizes:NNLS_MaxNumIterations
	NVAR NNLS_ApproachParameter	=root:Packages:Sizes:NNLS_ApproachParameter
	NVAR UseRegularization		=root:Packages:Sizes:UseRegularization
	NVAR UseMaxEnt			=root:Packages:Sizes:UseMaxEnt
	NVAR UseTNNLS			=root:Packages:Sizes:UseTNNLS
	NVAR StartFItQvalue
	NVAR EndFItQvalue




	variable DataExists=0,i
	string tempString
	string ListOfWaves=IN2G_CreateListOfItemsInFolder(fldrName, 2)
	if (stringmatch(ListOfWaves, "*SizesVolumeDistribution*" ))
		string ListOfSolutions="start fresh;"
		For(i=0;i<itemsInList(ListOfWaves);i+=1)
			if (stringmatch(stringFromList(i,ListOfWaves),"*SizesVolumeDistribution*"))
				tempString=stringFromList(i,ListOfWaves)
				Wave tempwv=$(fldrName+tempString)
				tempString=stringByKey("UsersComment",note(tempwv),"=")
				ListOfSolutions+=stringFromList(i,ListOfWaves)+"*  "+tempString+";"
			endif
		endfor
		DataExists=1
		string ReturnSolution=""
		Prompt ReturnSolution, "Select solution to recover", popup,  ListOfSolutions
		DoPrompt "Previous solutions found", ReturnSolution
		if (V_Flag)
			abort
		endif
	else
		abort
	endif


	if (DataExists==1 && cmpstr(ReturnSolution,"Start fresh")!=0)
			ReturnSolution=ReturnSolution[0,strsearch(ReturnSolution, "*", 0 )-1]
			Wave/Z OldDistribution=$(fldrName+ReturnSolution)
			wave Q_vecOriginal=root:Packages:Sizes:Q_vecOriginal
			string OldNote=note(OldDistribution)
	
	//		Old wave notes recovery is here....
			numOfPoints=NumberByKey("NumPoints", OldNote,"=")
			Rmin=NumberByKey("Rmin", OldNote,"=")
			Dmin=2*NumberByKey("Rmin", OldNote,"=")
			Rmax=NumberByKey("Rmax", OldNote,"=")
			Dmax=2*NumberByKey("Rmax", OldNote,"=")
			ErrorsMultiplier=NumberByKey("ErrorsMultiplier", OldNote,"=")
			ScatteringContrast=NumberByKey("ScatteringContrast", OldNote,"=")
			
			MethodRun=StringByKey("MethodRun", OldNote,"=")
			LogDist=StringByKey("LogRBinning", OldNote,"=")
			ShapeType=StringByKey("ParticleShape", OldNote,"=")
			StartFItQvalue=NumberbyKey("StartFitQValue", OldNote,"=")
			EndFItQvalue=NumberbyKey("EndFitQValue", OldNote,"=")
			MaxEntStabilityParam=NumberbyKey("MaxEntStabilityParam", OldNote,"=")
			MaxEntSkyBckg=NumberbyKey("MaxEntSkyBckg", OldNote,"=")
		//	BinWidthInGMatrix=NumberbyKey("BinWidthInGMatrix", OldNote,"=")
			BinWidthInGMatrix=0			//patch, found to be right setting
	
			 SizesPowerToUse		=NumberByKey("SizesPowerToUse", OldNote,"=")
			 NNLS_MaxNumIterations	=NumberByKey("NNLS_MaxNumIterations", OldNote,"=")
			 NNLS_ApproachParameter	=NumberByKey("NNLS_ApproachParameter", OldNote,"=")
			 UseRegularization		=NumberByKey("UseRegularization", OldNote,"=")
			 UseMaxEnt			=NumberByKey("UseMaxEnt", OldNote,"=")
			 UseTNNLS			=NumberByKey("UseTNNLS", OldNote,"=")
		
			if((UseRegularization+UseMaxEnt+UseTNNLS)!=1)
				if(cmpstr(MethodRun,"Regularization")==0)
					UseRegularization=1
					UseMaxEnt=0
					UseTNNLS=0
				elseif(cmpstr(MethodRun,"MaxEnt")==0)
					UseRegularization=0
					UseMaxEnt=1
					UseTNNLS=0
				else
					UseRegularization=0
					UseMaxEnt=0
					UseTNNLS=1				
				endif
			endif
			SetVariable NNLS_ApproachParameter,disable=!(UseTNNLS), win=IR1R_SizesInputPanel
			SetVariable NNLS_MaxNumIterations,disable=!(UseTNNLS), win=IR1R_SizesInputPanel
			PopupMenu SizesPowerToUse,disable=!(UseTNNLS), win=IR1R_SizesInputPanel
	
			SetVariable SizesStabilityParam,disable=!(UseMaxEnt), win=IR1R_SizesInputPanel
			SetVariable MaxsasIter,disable=!(UseMaxEnt), win=IR1R_SizesInputPanel
			SetVariable MaxSkyBckg,disable=!(UseMaxEnt), win=IR1R_SizesInputPanel
			SetVariable SuggestedSkyBackground,disable=!(UseMaxEnt), win=IR1R_SizesInputPanel
			Button SetMaxEntSkyBckg,disable=!(UseMaxEnt), win=IR1R_SizesInputPanel
			//end of old recovery part. we should remove this later..
			
			// New type of recovery... We should go this way since otherwise this is just going to make all crazy...
			string ListOfVariables=""
			ListOfVariables+="MaxEntSkyBckg;MaxEntRegular;MaxsasNumIter;numOfPoints;SlitLength;Rmin;Rmax;Bckg;ScatteringContrast;Dmin;"
			ListOfVariables+="CurrentEntropy;CurrentChiSq;CurChiSqMinusAlphaEntropy;BinWidthInGMatrix;GraphLogTopAxis;GraphLogRightAxis;"
			ListOfVariables+="Dmax;ErrorsMultiplier;TicksForDiagnostics;MaxEntStabilityParam;NumberIterations;MaxEntNumIter;"	
			ListOfVariables+="AspectRatio;FractalRadiusOfPriPart;FractalDimension;CylinderLength;TubeLength;"
			ListOfVariables+="CylinderLength;TubeWallThickness;TubeCoreContrastRatio;"
			ListOfVariables+="CoreShellThickness;CoreShellCoreRho;CoreShellShellRho;CoreShellSolvntRho;"
			ListOfVariables+="UserFFpar1;UserFFpar2;UserFFpar3;UserFFpar4;UserFFpar5;"
			ListOfVariables+="NNLS_MaxNumIterations;NNLS_ApproachParameter;"
			ListOfVariables+="UseRegularization;UseMaxEnt;UseTNNLS;"
			ListOfVariables+="SizesPowerToUse;UseUserErrors;UseSQRTErrors;UsePercentErrors;PercentErrorToUse;UseNoErrors;"
			ListOfVariables+="StartFItQvalue;EndFItQvalue;"
		
			string ListOfStrings=""
			ListOfStrings+="LogDist;ShapeType;SlitSmearedData;MethodRun;User_FormFactorFnct;User_FormFactorVol;"	
	
			variable tempVal
			for(i=0;i<itemsInList(ListOfVariables);i+=1)
				tempVal=NumberByKey(StringFromList(i,ListOfvariables), OldNote,"=")
				if(numtype(tempVal)==0)
					NVAR/Z tempVar=$(StringFromList(i,ListOfvariables))
					if(!NVAR_Exists(tempVar))
						variable/g $(StringFromList(i,ListOfvariables))
						NVAR tempVar=$(StringFromList(i,ListOfvariables))
					endif
					tempVar=tempVal
				endif
			endfor
			string tempStr
			for(i=0;i<itemsInList(ListOfStrings);i+=1)
				tempStr=StringByKey(StringFromList(i,ListOfStrings), OldNote,"=")
				if(strlen(tempStr)>0)
					SVAR/Z tempStr1=$(StringFromList(i,ListOfStrings))
					if(!SVAR_Exists(tempStr1))
						string/g $(StringFromList(i,ListOfStrings))
						SVAR tempStr1=$(StringFromList(i,ListOfStrings))
					endif
					tempStr1=tempStr
				endif
			endfor
		//end of new recovery and next is the nightmare of form factors... 
		//	popup
		//now need to set the particle parameters according to used particle shape model...
			//Algebraic_Integrated Spheres		no parameter needed
			//Algebraic_Globules		AspectRatio = ParticlePar1
			//Algebraic_Rods			AspectRatio = ParticlePar1
			//Algebraic_Disks			AspectRatio = ParticlePar1
			//Integrated_Spheroid		AspectRatio=ParticlePar1
			//	spheroid				AspectRatio = ParticlePar1
	
			//Cylinders				CylinderLength=ParticlePar1
	
			//	Fractal aggregate	 	FractalRadiusOfPriPart=ParticlePar1=root:Packages:Sizes:FractalRadiusOfPriPart	//radius of primary particle
			//						 FractalDimension=ParticlePar2=root:Packages:Sizes:FractalDimension			//Fractal dimension
			//Tube 					TubeLength=ParticlePar1
			//						WallThickness=ParticlePar2
			//						CoreContrastRatio=ParticlePar3
			//CoreShell				CoreShellThicknessRatio=ParticlePar1			//skin thickness to diameter ratio
			//						CoreShellContrastRatio=ParticlePar2			//contrast of skin -to- core ratio
	
		//AspectRatio;FractalRadiusOfPriPart;FractalDimension;CylinderLength;TubeLength;
		//CylinderLength;CoreShellThicknessRatio;CoreShellContrastRatio;TubeWallThickness;TubeCoreContrastRatio
		
		variable ParticlePar1=0,ParticlePar2=0,ParticlePar3=0,ParticlePar4=0,ParticlePar5=0
		SVAR ShapeType=root:Packages:Sizes:ShapeType
		NVAR AspectRatio=root:Packages:Sizes:AspectRatio

		if(cmpstr(ShapeType,"Algebraic_Integrated Spheres")==0)		//no parameter at all - it is sphere
			//no parameter
		elseif(cmpstr(ShapeType,"Cylinders")==0)						//Cylinder 1 poarameter - length
			NVAR CylinderLength=root:Packages:Sizes:CylinderLength	//CylinderLength
			CylinderLength			=NumberbyKey("CylinderLength", OldNote,"=")
		elseif(cmpstr(ShapeType,"User")==0)						//Cylinder 1 poarameter - length
			NVAR ParticlePar1G=root:Packages:Sizes:UserFFpar1
			ParticlePar1G			=NumberbyKey("UserParameter1", OldNote,"=")
			NVAR ParticlePar2G=root:Packages:Sizes:UserFFpar2
			ParticlePar2G			=NumberbyKey("UserParameter2", OldNote,"=")
			NVAR ParticlePar3G=root:Packages:Sizes:UserFFpar3
			ParticlePar3G			=NumberbyKey("UserParameter3", OldNote,"=")
			NVAR ParticlePar4G=root:Packages:Sizes:UserFFpar4
			ParticlePar4G			=NumberbyKey("UserParameter4", OldNote,"=")
			NVAR ParticlePar5G=root:Packages:Sizes:UserFFpar5
			ParticlePar5G			=NumberbyKey("UserParameter5", OldNote,"=")
		elseif(cmpstr(ShapeType,"CoreShell")==0)				//CoreShell - 2 parameters
			NVAR CoreShellThicknessRatio=root:Packages:Sizes:CoreShellThicknessRatio	//radius of primary particle
			CoreShellThicknessRatio	=NumberbyKey("CoreShellThicknessRatio", OldNote,"=")
			NVAR CoreShellContrastRatio=root:Packages:Sizes:CoreShellContrastRatio	
			CoreShellContrastRatio	=NumberbyKey("CoreShellContrastRatio", OldNote,"=")
		elseif(cmpstr(ShapeType,"Fractal aggregate")==0)				//Fractal aggregate - 2 parameters
			NVAR FractalRadiusOfPriPart=root:Packages:Sizes:FractalRadiusOfPriPart	//radius of primary particle
			FractalRadiusOfPriPart	=NumberbyKey("FractalRadiusOfPriPart", OldNote,"=")
			NVAR FractalDimension=root:Packages:Sizes:FractalDimension	
			FractalDimension			=NumberbyKey("FractalDimension", OldNote,"=")
		elseif(cmpstr(ShapeType,"Unified_Tube")==0)				//Tube - 3 parameters
			NVAR TubeLength=root:Packages:Sizes:TubeLength			//TubeLength
				TubeLength				=NumberbyKey("TubeLength", OldNote,"=")
			NVAR TubeWallThickness=root:Packages:Sizes:TubeWallThickness		//WallThickness
				TubeWallThickness		=NumberbyKey("TubeWallThickness", OldNote,"=")	
		elseif(cmpstr(ShapeType,"Tube")==0)				//Tube - 3 parameters
			NVAR TubeLength=root:Packages:Sizes:TubeLength			//TubeLength
				TubeLength				=NumberbyKey("TubeLength", OldNote,"=")
			NVAR TubeWallThickness=root:Packages:Sizes:TubeWallThickness		//WallThickness
				TubeWallThickness		=NumberbyKey("TubeWallThickness", OldNote,"=")	
				DoAlert 0, "Unifinished recovery for Tube in  IR1R_RecoverOldParameters() function"
			NVAR TubeCoreContrastRatio=root:Packages:Sizes:TubeCoreContrastRatio		//CoreContrastRatio
				TubeCoreContrastRatio	=NumberbyKey("TubeCoreContrastRatio", OldNote,"=")	
		else												//the ones which require 1 parameter - aspect ratio or (Unif) thickness/length
				AspectRatio				=NumberbyKey("AspectRatio", OldNote,"=")
		endif
		SVAR ListOfFF=root:Packages:FormFactorCalc:ListOfFormFactors
		NVAR Bckg=root:Packages:Sizes:Bckg
		NVAR StartFItQvalue=root:Packages:Sizes:StartFItQvalue
		NVAR EndFItQvalue=root:Packages:Sizes:EndFItQvalue
	
		Execute("PopupMenu ShapeModel,mode=(1+WhichListItem(ShapeType,root:Packages:FormFactorCalc:ListOfFormFactors)),value= root:Packages:FormFactorCalc:ListOfFormFactors, win=IR1R_SizesInputPanel")
		Dowindow IR1R_SizesInputGraph	//this checks for existence of this window and if it exists, it will put in the cursors as appropriate...
		if(V_Flag)
			Cursor /W=IR1R_SizesInputGraph A IntensityOriginal BinarySearch(Q_vecOriginal, StartFItQvalue )
			Cursor /W=IR1R_SizesInputGraph B IntensityOriginal BinarySearch(Q_vecOriginal, EndFItQvalue )
		endif
		//and now recalculate the background
		IR1R_BackgroundInput("bckg",Bckg,"bla","Bla")
		IR1R_FixSetVarsInPanel()
		IR1R_UpdateErrorWave()
	endif
	
	setDataFolder oldDf
end



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


static  Function IR1R_FinishSetupOfRegParam()			//Finish the preparation for parameters selected in the panel

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes
	
	Wave DeletePointsMaskWave	=root:Packages:Sizes:DeletePointsMaskWave
	Wave IntensityOriginal			=root:Packages:Sizes:IntensityOriginal
	Wave/Z Intensity				=root:Packages:Sizes:Intensity
	Wave/Z Q_vec				=root:Packages:Sizes:Q_vec
	Wave Q_vecOriginal			=root:Packages:Sizes:Q_vecOriginal
	Wave/Z Errors				=root:Packages:Sizes:Errors
	Wave ErrorsOriginal			=root:Packages:Sizes:ErrorsOriginal
	SVAR ShapeType			=root:Packages:Sizes:ShapeType
	SVAR SizesParameters		=root:Packages:Sizes:SizesParameters				
	SVAR LogDist				=root:Packages:Sizes:LogDist
	SVAR SlitSmearedData		=root:Packages:Sizes:SlitSmearedData
	NVAR Bckg					=root:Packages:Sizes:Bckg
	NVAR numOfPoints			=root:Packages:Sizes:numOfPoints
	NVAR Dmin					=root:Packages:Sizes:Dmin
	NVAR Dmax					=root:Packages:Sizes:Dmax
	NVAR Rmin					=root:Packages:Sizes:Rmin
	NVAR Rmax					=root:Packages:Sizes:Rmax
	NVAR AspectRatio			=root:Packages:Sizes:AspectRatio
	NVAR ScatteringContrast		=root:Packages:Sizes:ScatteringContrast
	NVAR ErrorsMultiplier			=root:Packages:Sizes:ErrorsMultiplier
	NVAR MaxEntSkyBckg		=root:Packages:Sizes:MaxEntSkyBckg
	NVAR MaxsasNumIter		=root:Packages:Sizes:MaxsasNumIter
	NVAR SlitLength				=root:Packages:Sizes:SlitLength
	NVAR MaxEntStabilityParam	=root:Packages:Sizes:MaxEntStabilityParam
	NVAR MaxEntSkyBckg		=root:Packages:Sizes:MaxEntSkyBckg
	
	NVAR SizesPowerToUse		=root:Packages:Sizes:SizesPowerToUse
	NVAR NNLS_MaxNumIterations	=root:Packages:Sizes:NNLS_MaxNumIterations
	NVAR NNLS_ApproachParameter	=root:Packages:Sizes:NNLS_ApproachParameter
	NVAR UseRegularization		=root:Packages:Sizes:UseRegularization
	NVAR UseMaxEnt			=root:Packages:Sizes:UseMaxEnt
	NVAR UseTNNLS			=root:Packages:Sizes:UseTNNLS


	NVAR UseUserErrors			=root:Packages:Sizes:UseUserErrors
	NVAR UseSQRTErrors		=root:Packages:Sizes:UseSQRTErrors
	NVAR UsePercentErrors		=root:Packages:Sizes:UsePercentErrors
	NVAR UseNoErrors			=root:Packages:Sizes:UseNoErrors

	NVAR PercentErrorToUse		=root:Packages:Sizes:PercentErrorToUse

	Duplicate/O IntensityOriginal, Intensity, NormalizedResidual	//here we return in the original data, which will be trimmed next
	redimension/D Intensity
	Duplicate/O Q_vecOriginal, Q_vec
	Redimension/D Q_vec
	Duplicate/O ErrorsOriginal, Errors
	Redimension/D Errors
	if(UseUserErrors)
		Errors=ErrorsMultiplier*ErrorsOriginal						//mulitply the erros by user selected multiplier
	elseif(UseSQRTErrors)
		Errors=sqrt(Intensity)* ErrorsMultiplier						//sqrt of intensity requested by user
		Smooth 5, Errors
	elseif(UsePercentErrors)
		Errors=Intensity*PercentErrorToUse/100						//% of intensity requested by user
		Smooth 5, Errors
	elseif(UseNoErrors)
		Errors=1													//should be equivavlent to no errors at all
	else
		Errors=1													//should be equivavlent to no errors at all
	endif


	Intensity=Intensity*(DeletePointsMaskWave/7)				//since DeletePointsMaskWave contains NaNs for points which we want to delete
															//at this moment we set these points in intensity to NaNs
	Intensity=Intensity-Bckg									//subtract background from Intensity
	if ( ((strlen(CsrWave(A))!=0) && (strlen(CsrWave(B))!=0) ) && (pcsr (A)!=pcsr (B)) )	//this should make sure, that both cursors are in the graph and not on the same point
		//make sure the cursors are on the right waves..
		IR1R_TrimData(Intensity,Q_vec,Errors)					//this trims the data with cursors
	endif
	IN2G_RemoveNaNsFrom3Waves(Intensity,Q_vec,Errors)		//this should remove NaNs from the important waves
	Rmax=Dmax/2										//create radia from user input
	Rmin=Dmin/2
	make /D/O/N=(numOfPoints) R_distribution, temp		//this part creates the distribution of radia
	if (cmpstr(LogDist,"no")==0)							//linear binninig
		R_distribution=Rmin+p*((Rmax-Rmin)/(numOfPoints-1))
	else													//log binnning (default)
		temp=log(Rmin)+p*((log(Rmax)-log(Rmin))/(numOfPoints-1))
		R_distribution=10^temp
	endif
	Killwaves temp										//kill this wave, not needed anymore
	Duplicate/O R_distribution D_distribution, ModelDistribution, InitialModelBckg	//and create the Diameter distribution wave and modelWave
	Redimension/D R_Distribution, D_distribution
	D_distribution*=2										//and put diameters there
	NVAR StartFitQvalue
	StartFitQvalue=Q_vec[0]
	NVAR EndFitQvalue
	EndFitQvalue=Q_vec[numpnts(Q_vec)-1]
	
//	SizesParameters=ReplaceStringByKey("NumPoints", SizesParameters, num2str(numOfPoints),"=")
//	SizesParameters=ReplaceStringByKey("Rmin", SizesParameters, num2str(Rmin),"=")
//	SizesParameters=ReplaceStringByKey("Rmax", SizesParameters, num2str(Rmax),"=")
//	SizesParameters=ReplaceStringByKey("ErrorsMultiplier", SizesParameters, num2str(ErrorsMultiplier),"=")
//	SizesParameters=ReplaceStringByKey("LogRBinning", SizesParameters,LogDist,"=")
//	SizesParameters=ReplaceStringByKey("ParticleShape", SizesParameters, ShapeType,"=")
//	SizesParameters=ReplaceStringByKey("Background", SizesParameters, num2str(Bckg),"=")
//	SizesParameters=ReplaceStringByKey("ScatteringContrast", SizesParameters, num2str(ScatteringContrast),"=")
//	SizesParameters=ReplaceStringByKey("SlitSmearedData", SizesParameters, SlitSmearedData,"=")
//	SizesParameters=ReplaceStringByKey("StartFitQvalue", SizesParameters, num2str(Q_vec[0]),"=")
//	SizesParameters=ReplaceStringByKey("EndFitQvalue", SizesParameters, num2str(Q_vec[numpnts(Q_vec)-1]),"=")
//	SizesParameters=ReplaceStringByKey("MaxEntSkyBckg", SizesParameters, num2str(MaxEntSkyBckg),"=")
//	SizesParameters=ReplaceStringByKey("MaxsasNumIter", SizesParameters, num2str(MaxsasNumIter),"=")
//	SizesParameters=ReplaceStringByKey("SlitLength", SizesParameters, num2str(SlitLength),"=")
//	SizesParameters=ReplaceStringByKey("MaxEntStabilityParam", SizesParameters, num2str(MaxEntStabilityParam),"=")
//	SizesParameters=ReplaceStringByKey("MaxEntSkyBckg", SizesParameters, num2str(MaxEntSkyBckg),"=")
//
//	SizesParameters=ReplaceStringByKey("SizesPowerToUse", SizesParameters, num2str(SizesPowerToUse),"=")
//	SizesParameters=ReplaceStringByKey("NNLS_MaxNumIterations", SizesParameters, num2str(NNLS_MaxNumIterations),"=")
//	SizesParameters=ReplaceStringByKey("NNLS_ApproachParameter", SizesParameters, num2str(NNLS_ApproachParameter),"=")
//	SizesParameters=ReplaceStringByKey("UseRegularization", SizesParameters, num2str(UseRegularization),"=")
//	SizesParameters=ReplaceStringByKey("UseMaxEnt", SizesParameters, num2str(UseMaxEnt),"=")
//	SizesParameters=ReplaceStringByKey("UseTNNLS", SizesParameters, num2str(UseTNNLS),"=")
//
//	SizesParameters=ReplaceStringByKey("UseUserErrors", SizesParameters, num2str(UseUserErrors),"=")
//	SizesParameters=ReplaceStringByKey("UseSQRTErrors", SizesParameters, num2str(UseSQRTErrors),"=")
//	SizesParameters=ReplaceStringByKey("UsePercentErrors", SizesParameters, num2str(UsePercentErrors),"=")
//	SizesParameters=ReplaceStringByKey("UseNoErrors", SizesParameters, num2str(UseNoErrors),"=")
//	SizesParameters=ReplaceStringByKey("PercentErrorToUse", SizesParameters, num2str(PercentErrorToUse),"=")
		string ListOfVariables=""
		ListOfVariables+="MaxEntSkyBckg;MaxEntRegular;MaxsasNumIter;numOfPoints;SlitLength;Rmin;Rmax;Bckg;ScatteringContrast;Dmin;"
		ListOfVariables+="Dmax;ErrorsMultiplier;TicksForDiagnostics;MaxEntStabilityParam;NumberIterations;MaxEntNumIter;"	
		ListOfVariables+="AspectRatio;FractalRadiusOfPriPart;FractalDimension;CylinderLength;TubeLength;"
		ListOfVariables+="CylinderLength;TubeWallThickness;TubeCoreContrastRatio;"
		ListOfVariables+="CoreShellThickness;CoreShellCoreRho;CoreShellShellRho;CoreShellSolvntRho;"
		ListOfVariables+="UserFFpar1;UserFFpar2;UserFFpar3;UserFFpar4;UserFFpar5;"
		ListOfVariables+="NNLS_MaxNumIterations;NNLS_ApproachParameter;"
		ListOfVariables+="UseRegularization;UseMaxEnt;UseTNNLS;"
		ListOfVariables+="SizesPowerToUse;UseUserErrors;UseSQRTErrors;UsePercentErrors;PercentErrorToUse;UseNoErrors;"
		ListOfVariables+="StartFItQvalue;EndFItQvalue;"
	
		string ListOfStrings=""
		ListOfStrings+="LogDist;ShapeType;SlitSmearedData;MethodRun;User_FormFactorFnct;User_FormFactorVol;"	

		variable tempVal, i
		for(i=0;i<itemsInList(ListOfVariables);i+=1)
			NVAR tempVar=$(StringFromList(i,ListOfvariables))
			SizesParameters=ReplaceStringByKey(StringFromList(i,ListOfvariables), SizesParameters, num2str(tempVar),"=")
		endfor
		for(i=0;i<itemsInList(ListOfStrings);i+=1)
			SVAR tempStr1=$(StringFromList(i,ListOfStrings))
			SizesParameters=ReplaceStringByKey(StringFromList(i,ListOfStrings), SizesParameters, tempStr1,"=")
		endfor

	//now need to set the particle parameters according to used particle shape model...
		//Algebraic_Integrated Spheres		no parameter needed
		//Algebraic_Globules		AspectRatio = ParticlePar1
		//Algebraic_Rods			AspectRatio = ParticlePar1
		//Algebraic_Disks			AspectRatio = ParticlePar1
		//Integrated_Spheroid		AspectRatio=ParticlePar1
		//	spheroid				AspectRatio = ParticlePar1

		//Cylinders				CylinderLength=ParticlePar1

		//	Fractal aggregate	 	FractalRadiusOfPriPart=ParticlePar1=root:Packages:Sizes:FractalRadiusOfPriPart	//radius of primary particle
		//						 FractalDimension=ParticlePar2=root:Packages:Sizes:FractalDimension			//Fractal dimension
		//Tube 					TubeLength=ParticlePar1
		//						WallThickness=ParticlePar2
		//						CoreContrastRatio=ParticlePar3
		//CoreShell				CoreShellThicknessRatio=ParticlePar1			//skin thickness to diameter ratio
		//						CoreShellContrastRatio=ParticlePar2			//contrast of skin -to- core ratio

	//AspectRatio;FractalRadiusOfPriPart;FractalDimension;CylinderLength;TubeLength;
	//CylinderLength;CoreShellThicknessRatio;CoreShellContrastRatio;TubeWallThickness;TubeCoreContrastRatio
	
	variable ParticlePar1=0,ParticlePar2=0,ParticlePar3=0,ParticlePar4=0,ParticlePar5=0
	SVAR ShapeType=root:Packages:Sizes:ShapeType
	NVAR AspectRatio=root:Packages:Sizes:AspectRatio

	if(cmpstr(ShapeType,"Algebraic_Integrated Spheres")==0)		//no parameter at all - it is sphere
		//no parameter
	elseif(cmpstr(ShapeType,"Cylinders")==0)						//Cylinder 1 poarameter - length
		NVAR CylinderLength=root:Packages:Sizes:CylinderLength	//CylinderLength
		SizesParameters=ReplaceStringByKey("CylinderLength", SizesParameters, num2str(CylinderLength),"=")
	elseif(cmpstr(ShapeType,"User")==0)						//Cylinder 1 poarameter - length
		NVAR ParticlePar1G=root:Packages:Sizes:UserFFpar1
		SizesParameters=ReplaceStringByKey("UserParameter1", SizesParameters, num2str(ParticlePar1G),"=")
		NVAR ParticlePar2G=root:Packages:Sizes:UserFFpar2
		SizesParameters=ReplaceStringByKey("UserParameter2", SizesParameters, num2str(ParticlePar2G),"=")
		NVAR ParticlePar3G=root:Packages:Sizes:UserFFpar3
		SizesParameters=ReplaceStringByKey("UserParameter3", SizesParameters, num2str(ParticlePar3G),"=")
		NVAR ParticlePar4G=root:Packages:Sizes:UserFFpar4
		SizesParameters=ReplaceStringByKey("UserParameter4", SizesParameters, num2str(ParticlePar4G),"=")
		NVAR ParticlePar5G=root:Packages:Sizes:UserFFpar5
		SizesParameters=ReplaceStringByKey("UserParameter5", SizesParameters, num2str(ParticlePar5G),"=")
	elseif(cmpstr(ShapeType,"CoreShell")==0)				//CoreShell - 2 parameters
		NVAR CoreShellThicknessRatio=root:Packages:Sizes:CoreShellThicknessRatio	//radius of primary particle
		SizesParameters=ReplaceStringByKey("CoreShellThicknessRatio", SizesParameters, num2str(CoreShellThicknessRatio),"=")
		NVAR CoreShellContrastRatio=root:Packages:Sizes:CoreShellContrastRatio	
		SizesParameters=ReplaceStringByKey("CoreShellContrastRatio", SizesParameters, num2str(CoreShellContrastRatio),"=")
	elseif(cmpstr(ShapeType,"Fractal aggregate")==0)				//Fractal aggregate - 2 parameters
		NVAR FractalRadiusOfPriPart=root:Packages:Sizes:FractalRadiusOfPriPart	//radius of primary particle
		SizesParameters=ReplaceStringByKey("FractalRadiusOfPriPart", SizesParameters, num2str(FractalRadiusOfPriPart),"=")
		NVAR FractalDimension=root:Packages:Sizes:FractalDimension	
		SizesParameters=ReplaceStringByKey("FractalDimension", SizesParameters, num2str(FractalDimension),"=")
	elseif(cmpstr(ShapeType,"Unified_Tube")==0)				//Tube - 2 parameters
		NVAR TubeLength=root:Packages:Sizes:TubeLength			//TubeLength
		SizesParameters=ReplaceStringByKey("TubeLength", SizesParameters, num2str(TubeLength),"=")
		NVAR TubeWallThickness=root:Packages:Sizes:TubeWallThickness		//WallThickness
		SizesParameters=ReplaceStringByKey("TubeWallThickness", SizesParameters, num2str(TubeWallThickness),"=")
	elseif(cmpstr(ShapeType,"Tube")==0)				//Tube - 3 parameters
		NVAR TubeLength=root:Packages:Sizes:TubeLength			//TubeLength
		SizesParameters=ReplaceStringByKey("TubeLength", SizesParameters, num2str(TubeLength),"=")
		NVAR TubeWallThickness=root:Packages:Sizes:TubeWallThickness		//WallThickness
		SizesParameters=ReplaceStringByKey("TubeWallThickness", SizesParameters, num2str(TubeWallThickness),"=")
		NVAR TubeCoreContrastRatio=root:Packages:Sizes:TubeCoreContrastRatio		//CoreContrastRatio
		SizesParameters=ReplaceStringByKey("TubeCoreContrastRatio", SizesParameters, num2str(TubeCoreContrastRatio),"=")
	else												//the ones which require 1 parameter - aspect ratio or (Unif) thickness/length
		SizesParameters=ReplaceStringByKey("AspectRatio", SizesParameters, num2str(AspectRatio),"=")
	endif

	setDataFolder oldDf
end

//*********************************************************************************************
//*********************************************************************************************

static  Function IR1R_TrimData(wave1, wave2, wave3) 				//this is local trimming procedure
	Wave wave1, wave2, wave3
	
	variable AP=pcsr (A)
	variable BP=pcsr (B)
	
	deletePoints 0, AP, wave1, wave2, wave3
	variable newLength=numpnts(wave1)
	deletePoints (BP-AP+1), (newLength),  wave1, wave2, wave3
End

////*********************************************************************************************
////*********************************************************************************************
//

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static  Function IR1R_CalcFractAggFormFactor(FRwave,Qw,currentR,Param1,Param2)	
	Wave Qw,FRwave					//returns column (FRwave) for column of Qw and diameter
	Variable currentR, Param1, Param2
	//Param1 is primary particle radius
	//Param2 is fractal dimension
	
	FRwave=IR1R_CalcSphereFormFactor(Qw[p],(2*Param1))			//calculates the F(Q,r) * V(r) part fo formula  
																//this is same as for sphere of diameter = 2*Param1 (= radius of primary particle, which is hard sphere)
	FRwave*=FRwave												//second power of the value
	FRwave*=IR1R_CalculateFractAggSQPoints(Qw[p],currentR,Param1, Param2)
															//this last part multiplies by S(Q) part of the formula
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


static  Function IR1R_CalcSphereFormFactor(QVal,currentR)
		variable Qval, currentR
		
		variable radius=currentR
		variable QR=Qval*radius
		
		variable tempResult
		tempResult=(3/(QR*QR*QR))*(sin(QR)-(QR*cos(QR)))				//calculate sphere scattering factor 
	
		tempResult*=(IR1R_SphereVolume(radius))							//multiply by volume of sphere, one step above will be ^2

	return tempResult
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


static  Function IR1R_CalculateFractAggSQPoints(Qvalue,R,r0, D)
	variable Qvalue, R, r0, D							//does the math for S(Q) factor function
	
	variable QR=Qvalue*R	
	variable tempResult
	
 	   variable part1, part2, part3, part4, part5
	   part1=1
	   part2=(qR*r0/R)^-D
 	   part3=D*(exp(gammln(D-1)))
	   part5= (1+(qR)^-2)^((D-1)/2)
	   part4=abs(sin((D-1)*atan(qR)))
	   
	return (part1+part2*part3*part4/part5)													
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static  Function IR1R_VolumeOfFractalAggregate(FractalRadius, PrimaryPartRadius,Dimension)
	variable FractalRadius, PrimaryPartRadius,Dimension
	
	variable result
	result=((4/3)*pi*PrimaryPartRadius^3)*((FractalRadius/PrimaryPartRadius)^Dimension)*10^(-24)		//solid volume 
//	result=((4/3)*pi*PrimaryPartRadius^3)*10^(-24)
//	result=((4/3)*pi*FractalRadius^3)*10^(-24)
//	result=((4/3)*pi*FractalRadius^3)*10^(-24)				//envelope volume
	return result
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
static Function IR1R_BinWidthInRadia(i)			//calculates the width in radia by taking half distance to point before and after
	variable i								//returns number in A

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes

	Wave R_distribution=root:Packages:Sizes:R_distribution
	variable width
	variable Imax=numpnts(R_distribution)
	
	if (i==0)
		width=R_distribution[1]-R_distribution[0]
	elseif (i==Imax-1)
		width=R_distribution[i]-R_distribution[i-1]
	else
		width=((R_distribution[i]-R_distribution[i-1])/2)+((R_distribution[i+1]-R_distribution[i])/2)
	endif
	return width
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static  Function IR1R_CalculateSphereFormFactor(FRwave,Qw,radius)	
	Wave Qw,FRwave					//returns column (FRwave) for column of Qw and radius
	Variable radius	
	
	FRwave=IR1R_CalculateSphereFFPoints(Qw[p],radius)		//calculates the formula 
	FRwave*=FRwave											//second power of the value
end



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static  Function IR1R_CalculateSphereFFPoints(Qvalue,radius)
	variable Qvalue, radius										//does the math for Sphere Form factor function
	variable QR=Qvalue*radius

	return (3/(QR*QR*QR))*(sin(QR)-(QR*cos(QR)))
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR1R_SphereVolume(radius)							//returns the sphere...
	variable radius
	return ((4/3)*pi*radius*radius*radius)
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR1R_CalcSpheroidFormFactor(FRwave,Qw,radius,AR)	
	Wave Qw,FRwave					//returns column (FRwave) for column of Qw and radius
	Variable radius, AR	
	
	FRwave=IR1R_CalcIntgSpheroidFFPoints(Qw[p],radius,AR)	//calculates the formula 
	// second power needs to be done before integration...FRwave*=FRwave											//second power of the value
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR1R_CalcIntgSpheroidFFPoints(Qvalue,radius,AR)		//we have to integrate from 0 to 1 over cos(th)
	variable Qvalue, radius	, AR
	
	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes

	Make/O/D/N=50 IntgWave
	SetScale/I x 0,1,"", IntgWave
	IntgWave=IR1R_CalcSpheroidFFPoints(Qvalue,radius,AR, x)	//this 
	IntgWave*=IntgWave						//calculate second power before integration, thsi was bug
	//found on 3/22/2002, which caused wrong results with larger AR...
	variable result= area(IntgWave, 0,1)
	KillWaves IntgWave
//	Display IntgWave
//	ModifyGraph log(left)=1
//	DoUpdate
//	sleep/s 0.5
//	DoWindow/K Graph0
	setDataFolder OldDf
	return result
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static  Function IR1R_CalcSpheroidFFPoints(Qvalue,radius,AR,CosTh)
	variable Qvalue, radius	, AR, CosTh							//does the math for Spheroid Form factor function
	variable QR=Qvalue*radius*sqrt(1+(((AR*AR)-1)*CosTh*CosTh))

	return (3/(QR*QR*QR))*(sin(QR)-(QR*cos(QR)))
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static  Function IR1R_SpheroidVolume(radius,AspectRatio)							//returns the spheroid volume...
	variable radius, AspectRatio
	return ((4/3)*pi*radius*radius*radius*AspectRatio)				//what is the volume of spheroid?
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static  Function IR1R_MakeHmatrix()									//makes the H matrix

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes

	Wave R_distribution=root:Packages:Sizes:R_distribution
	
	variable numOfPoints=numpnts(R_Distribution), i=0, j=0

	Make/D/O/N=(numOfPoints,numOfPoints) H_matrix			//make the matrix
	H_matrix=0												//zero the matrix
	
	For(i=2;i<numOfPoints-2;i+=1)								//this fills with 1 -4 6 -4 1 most of the matrix
		For(j=0;j<numOfPoints;j+=1)
			if(j==i-2)
				H_matrix[i][j]=1
			endif
			if(j==i-1)
				H_matrix[i][j]=-4
			endif
			if(j==i)
				H_matrix[i][j]=6
			endif
			if(j==i+1)
				H_matrix[i][j]=-4
			endif
			if(j==i+2)
				H_matrix[i][j]=1
			endif
		endfor
	endfor
															//now we need to fill in the first and last parts
	H_matrix[0][0]=1											//beginning of the H matrix
	H_matrix[0][1]=-2
	H_matrix[0][2]=1
	H_matrix[1][0]=-2
	H_matrix[1][1]=5
	H_matrix[1][2]=-4
	H_matrix[1][3]=1

	H_matrix[numOfPoints-2][numOfPoints-4]=1					//end of the H matrix
	H_matrix[numOfPoints-2][numOfPoints-3]=-4
	H_matrix[numOfPoints-2][numOfPoints-2]=5
	H_matrix[numOfPoints-2][numOfPoints-1]=-2
	H_matrix[numOfPoints-1][numOfPoints-3]=1
	H_matrix[numOfPoints-1][numOfPoints-2]=-2
	H_matrix[numOfPoints-1][numOfPoints-1]=1

	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR1R_CalculateBVector()								//makes new B vector and calculates values from G, Int and errors

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes
	
//	Wave G_matrix	=root:Packages:Sizes:G_matrix
//	Wave Intensity	=root:Packages:Sizes:Intensity
//	Wave Errors		=root:Packages:Sizes:Errors
	
	Wave G_matrix	=root:Packages:Sizes:G_matrixQ2N
	Wave Intensity	=root:Packages:Sizes:IntensityQ2N
	Wave Errors		=root:Packages:Sizes:ErrorsQ2N
	
	variable M=DimSize(G_matrix, 0)							//rows, i.e, measured points number
	variable N=DimSize(G_matrix, 1)							//columns, i.e., bins in distribution
	variable i=0, j=0
	Make/D/O/N=(N) B_vector									//points = bins in size dist.
	B_vector=0
	for (i=0;i<N;i+=1)					
		For (j=0;j<M;j+=1)
			B_vector[i]+=((G_matrix[j][i]*Intensity[j])/(Errors[j]*Errors[j]))
		endfor
	endfor

	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static  Function IR1R_CalculateDMatrix()								//makes new D matrix and calculates values from G, Int and errors

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes
	
//	Wave G_matrix=root:Packages:Sizes:G_matrix
//	Wave Errors=root:Packages:Sizes:Errors
	Wave G_matrix=root:Packages:Sizes:G_matrixQ2N
	Wave Errors=root:Packages:Sizes:ErrorsQ2N
	
	variable N=DimSize(G_matrix, 1)							//rows, i.e, measured points number
	variable M=DimSize(G_matrix, 0)							//columns, i.e., bins in distribution
	variable i=0, j=0, k=0
	Make/D/O/N=(N,N) D_matrix	
	Duplicate/O Errors, Errors2
	Errors2=Errors^2

//	variable tiskst=ticks			
	D_matrix=0
	Duplicate/O G_matrix, G_matrix_ErrScaled
	for (i=0;i<N;i+=1)	
		for (j=0;j<M;j+=1)				
			G_matrix_ErrScaled[j][i]=G_matrix[j][i]/(Errors2[j])
		endfor
	endfor	
	MatrixOp/O testM =  G_matrix_ErrScaled^t x G_matrix
	D_matrix = testM
//	for (i=0;i<N;i+=1)					
//		for (k=0;k<N;k+=1)					
//			For (j=0;j<M;j+=1)
//				D_matrix[i][k]+=(G_matrix[j][i]*G_matrix[j][k])/(Errors2[j])
//			endfor
//		endfor
//	endfor
//print (ticks-tiskst)/60
	KillWaves/Z Errors2, testM, G_matrix_ErrScaled

	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR1R_FindOptimumAvalue(Evalue)						//does the fitting itself, call with precision (e~0.1 or so)
	variable Evalue	

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes

//	Wave Intensity=root:Packages:Sizes:Intensity
//	Wave Errors=root:Packages:Sizes:Errors
	Wave Intensity=root:Packages:Sizes:IntensityQ2N
	Wave Errors=root:Packages:Sizes:ErrorsQ2N
	Wave D_distribution=root:Packages:Sizes:D_distribution

	variable LogAmax=100, LogAmin=-100, M=numpnts(Intensity)
	variable tolerance=Evalue*sqrt(2*M)
	variable Chisquared, MidPoint, Avalue, i=0, logAval, LogChisquarerdDivN, Smoothness
	do
		MidPoint=(LogAmax+LogAmin)/2
		Avalue=10^MidPoint								//calculate A
		IR1R_CalculateAmatrix(Avalue)
		MatrixLUD A_matrix								//decompose A_matrix 
		Wave M_Lower									//results in these matrices for next step:
		Wave M_Upper
		Wave W_LUPermutation
		Wave B_vector
		MatrixLUBkSub M_Lower, M_Upper, W_LUPermutation, B_vector				//Backsubstitute B to get x[]=inverse(A[][]) B[]	
		Wave M_x										//this is created by MatrixMultiply

		Redimension/D/N=(-1,0) M_x							//create from M_x[..][0] only M_x[..] so it is simple wave
		Duplicate/O M_x CurrentResultSizeDistribution		//put the data into the wave 
		Note/K CurrentResultSizeDistribution
		Note CurrentResultSizeDistribution, note(intensity)
		CurrentResultSizeDistribution/=2					//this fixes conversion to presentation in diameters
		
		//Need to fix binning effect, if it was not accounted for in G matrix we need to take bin width out now...
		variable iv
//		NVAR BinWidthInGMatrix=root:Packages:Sizes:BinWidthInGMatrix
		Wave CurrentResultSizeDistribution = root:Packages:Sizes:CurrentResultSizeDistribution
//		if(!BinWidthInGMatrix)
		For(iv=0;iv<numpnts(ModelDistribution);iv+=1)
			CurrentResultSizeDistribution[iv] = CurrentResultSizeDistribution[iv] / IR1R_BinWidthInRadia(iv)
		endfor
//		endif
		Chisquared=IR1R_CalculateChisquared()				//Calculate C 	C=|| I - G M_x ||
		
		Wave SizesFitIntensity=root:Packages:Sizes:SizesFitIntensity		//produced by IR1R_CalculateChisquared
		//Old diagnostics removed, replaced by new compatible with Maximum entropy 4/12/2004
		//this is here to make diagnostic outputs....
//		logAval=log(Avalue)
//		LogChisquarerdDivN=log(Chisquarered/numpnts(Intensity))
		Duplicate/O CurrentResultSizeDistribution, diffWave
		Duplicate/O D_distribution, diffWaveX
		Differentiate diffWave
		Differentiate diffWaveX
		diffWave=abs(diffWave)/abs(diffWaveX)		//this is suppose to create derivative of the CurrentSizeDistribution
		Smoothness=sum(diffWave,-inf,inf)
//		NVAR CurrentEntropy=root:Packages:Sizes:CurrentEntropy
		NVAR CurrentChiSq=root:Packages:Sizes:CurrentChiSq
		NVAR CurChiSqMinusAlphaEntropy=root:Packages:Sizes:CurChiSqMinusAlphaEntropy
		Duplicate/O SizesFitIntensity, zscratch2
//		Duplicate/O CurrentResultSizeDistribution, ModelScratch
//		variable 	fSum=sum(CurrentResultSizeDistribution)
//		ModelScratch= CurrentResultSizeDistribution/fSum		//fraction of Model(i) in this bin
//		ModelScratch= ModelScratch[p]>0 ? ModelScratch[p] : 1e-10
//		ModelScratch=ModelScratch * ln(ModelScratch)		
//		CurrentEntropy=-sum(ModelScratch)		// from Skilling and Brian eq. 1
		
		zscratch2 = (( Intensity[p] - SizesFitIntensity[p]) / Errors[p])^2	//residuals
		CurrentChiSq = sum(zscratch2)			//new Chisquared
		
		CurChiSqMinusAlphaEntropy=CurrentChiSq - tolerance*Smoothness
		KillWaves diffWave, diffWaveX, zscratch2

		IR1R_DisplayDiagnostics(Smoothness,CurrentChiSq, CurChiSqMinusAlphaEntropy,i)		//display data in diagnostic graphs, if needed
		//and here ends the diagnostics code modified 4 12 2004
		
		IR1R_FinishGraph()
		DoUpdate

//		print "("+num2str(i+1)+")     Chi squared value:  " + num2str(Chisquarered) + ",    target value:   "+num2str(M)

		if (Chisquared>M)
			LogAMax=MidPoint
		else
			LogAmin=MidPoint
		endif
		i+=1
		if (i>M)											//no solution found
			return NaN
		endif
	while(abs(Chisquared-M)>tolerance)				//how much can I divide 200 points interval before it is useless?
	
	NVAR Chisquare=root:Packages:Sizes:Chisquare
	Chisquare=Chisquared

	
	SVAR SizesParameters=root:Packages:Sizes:SizesParameters					//record the data
	SizesParameters=ReplaceStringByKey("Iterations", SizesParameters, num2str(i),"=")
	SizesParameters=ReplaceStringByKey("Chisquared", SizesParameters, num2str(Chisquare),"=")
	SizesParameters=ReplaceStringByKey("FinalAparam", SizesParameters, num2str(Avalue),"=")

//	IR1L_AppendAnyText("Fitted with following parameters :\r"+SizesParameters)

	return i
	SetDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static  Function IR1R_CalculateAmatrix(aValue)					//generates A matrix
	variable aValue

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes

	Wave D_matrix=root:Packages:Sizes:D_matrix
	Wave H_matrix=root:Packages:Sizes:H_matrix
	
	Duplicate/O D_matrix A_matrix
	A_matrix=0
	A_matrix=D_matrix[p][q]+aValue*H_matrix[p][q]
	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static  Function IR1R_CalculateChisquared()			//calculates Chisquared difference between the data
		//in Intensity and result calculated by G_matrix x x_vector

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes

//	Wave Intensity=root:Packages:Sizes:Intensity
//	Wave G_matrix=root:Packages:Sizes:G_matrix
//	Wave Errors=root:Packages:Sizes:Errors
	Wave Intensity=root:Packages:Sizes:IntensityQ2N
	Wave Q_vec=root:Packages:Sizes:Q_vec
	Wave G_matrix=root:Packages:Sizes:G_matrixQ2N
	Wave Errors=root:Packages:Sizes:ErrorsQ2N
	Wave M_x=root:Packages:Sizes:M_x
	NVAR SizesPowerToUse=root:Packages:Sizes:SizesPowerToUse
	NVAR UseNoErrors=root:Packages:Sizes:UseNoErrors

	Duplicate/O Intensity, NormalizedResidual, ChisquaredWave	//waves for data
	IN2G_AppendorReplaceWaveNote("NormalizedResidual","Units"," ")
	
	
	MatrixMultiply  G_matrix, M_x				//generates scattering intesity from current result (M_x - before correction for contrast and diameter)
	Wave M_product	
	Redimension/D/N=(-1,0) M_product			//again make the matrix with one dimension 0 into regular wave

	Duplicate/O M_product SizesFitIntensity
	if(UseNoErrors)		//only when not using any errors!!!!
		SizesFitIntensity = SizesFitIntensity/Q_vec^SizesPowerToUse
	endif
	Note/K SizesFitIntensity
	Note SizesFitIntensity, note(Intensity)

	NormalizedResidual=(Intensity-M_product)/Errors		//we need this for graph
	ChisquaredWave=NormalizedResidual^2			//and this is wave with Chisquared
	setDataFolder OldDf
	return (sum(ChisquaredWave,-inf,inf))				//return sum of Chisquared
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

  Function IR1R_FinishGraph()			//finish the graph to proper way,  this will be really difficult to make Mac compatible

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes

	DoWindow  IR1R_SizesInputGraph	
	if(!V_Flag)
		abort
	endif
	string fldrName
	Wave CurrentResultSizeDistribution=root:Packages:Sizes:CurrentResultSizeDistribution
	Wave D_distribution=root:Packages:Sizes:D_distribution
	Wave SizesFitIntensity=root:Packages:Sizes:SizesFitIntensity
	Wave Q_vec=root:Packages:Sizes:Q_vec
	Wave IntensityOriginal=root:Packages:Sizes:IntensityOriginal
	Wave NormalizedResidual=root:Packages:Sizes:NormalizedResidual
	Wave Q_vecOriginal=root:Packages:Sizes:Q_vecOriginal
	SVAR SizesParameters=root:Packages:Sizes:SizesParameters
	Wave BackgroundWave=root:Packages:Sizes:BackgroundWave
	SVAR MethodRun=root:Packages:Sizes:MethodRun
	NVAR NumberIterations=root:Packages:Sizes:NumberIterations
	NVAR MaxsasNumIter=root:Packages:Sizes:MaxsasNumIter
	NVAR GraphLogTopAxis		=root:Packages:Sizes:GraphLogTopAxis
	NVAR GraphLogRightAxis 	=root:Packages:Sizes:GraphLogRightAxis
	
	variable csrApos
	variable csrBpos
	
	DoWindow /F IR1R_SizesInputGraph
	
	if (strlen(csrWave(A))!=0)
		csrApos=pcsr(A)
	else
		csrApos=0
	endif	
	 
	if (strlen(csrWave(B))!=0)
		csrBpos=pcsr(B)
	else
		csrBpos=numpnts(IntensityOriginal)-1
	endif	
	DoWIndow /F IR1R_SizesInputGraph
	PauseUpdate
	RemoveFromGraph/Z/W=IR1R_SizesInputGraph SizesFitIntensity
	RemoveFromGraph/Z/W=IR1R_SizesInputGraph BackgroundWave
	RemoveFromGraph/Z/W=IR1R_SizesInputGraph CurrentResultSizeDistribution
	RemoveFromGraph/Z/W=IR1R_SizesInputGraph NormalizedResidual
	RemoveFromGraph/Z/W=IR1R_SizesInputGraph IntensityOriginal
	RemoveFromGraph/Z/W=IR1R_SizesInputGraph Intensity
	
	AppendToGraph/T/R/W=IR1R_SizesInputGraph CurrentResultSizeDistribution vs D_distribution
	
	WaveStats/Q CurrentResultSizeDistribution
	if(GraphLogRightAxis)		//log scaling
			SetAxis/W=IR1R_SizesInputGraph/N=1 right (V_max*1e-5),V_max*1.1
	else						//lin scailng
		if (V_min>0)
			SetAxis/W=IR1R_SizesInputGraph/N=1 right 0,V_max*1.1 
		else
			SetAxis/W=IR1R_SizesInputGraph/N=1 right -(V_max*0.1),V_max*1.1
		endif
	endif
	AppendToGraph/W=IR1R_SizesInputGraph Intensity vs Q_vec
	AppendToGraph/W=IR1R_SizesInputGraph SizesFitIntensity vs Q_vec
	AppendToGraph/W=IR1R_SizesInputGraph BackgroundWave vs Q_vecOriginal
	AppendToGraph/W=IR1R_SizesInputGraph IntensityOriginal vs Q_vecOriginal
	AppendToGraph/W=IR1R_SizesInputGraph/L=ChisquaredAxis NormalizedResidual vs Q_vec
	ModifyGraph/W=IR1R_SizesInputGraph log(left)=1
	ModifyGraph/W=IR1R_SizesInputGraph log(bottom)=1
	ModifyGraph/W=IR1R_SizesInputGraph log(top)=GraphLogTopAxis
	ModifyGraph/W=IR1R_SizesInputGraph log(right)=GraphLogRightAxis
	Label/W=IR1R_SizesInputGraph top "Particle diameter [A]"
	ModifyGraph/W=IR1R_SizesInputGraph lblMargin(top)=30,lblLatPos(top)=100
	Label/W=IR1R_SizesInputGraph right "Particle vol. distribution f(D)"
	Label/W=IR1R_SizesInputGraph left "Intensity"
	ModifyGraph/W=IR1R_SizesInputGraph lblPos(left)=50
	ModifyGraph/W=IR1R_SizesInputGraph lblMargin(right)=20
	Label/W=IR1R_SizesInputGraph bottom "Q [A\\S-1\\M]"	
	ModifyGraph/W=IR1R_SizesInputGraph axisEnab(left)={0.15,1}
	ModifyGraph/W=IR1R_SizesInputGraph axisEnab(right)={0.15,1}
	ModifyGraph/W=IR1R_SizesInputGraph lblMargin(top)=30
	ModifyGraph/W=IR1R_SizesInputGraph axisEnab(ChisquaredAxis)={0,0.15}
	ModifyGraph/W=IR1R_SizesInputGraph freePos(ChisquaredAxis)=0
	Label/W=IR1R_SizesInputGraph ChisquaredAxis "Residuals"
	ModifyGraph/W=IR1R_SizesInputGraph lblPos(ChisquaredAxis)=50,lblLatPos=0
	ModifyGraph/W=IR1R_SizesInputGraph mirror(ChisquaredAxis)=1
	SetAxis/W=IR1R_SizesInputGraph /A/E=2 ChisquaredAxis
	ModifyGraph/W=IR1R_SizesInputGraph nticks(ChisquaredAxis)=3

	ModifyGraph/W=IR1R_SizesInputGraph mode(Intensity)=3,marker(Intensity)=5,msize(Intensity)=3
	
	Cursor/P/W=IR1R_SizesInputGraph A IntensityOriginal, csrApos
	Cursor/P/W=IR1R_SizesInputGraph B IntensityOriginal, csrBpos
	
	ModifyGraph/W=IR1R_SizesInputGraph rgb(SizesFitIntensity)=(0,0,52224)	
	ModifyGraph/W=IR1R_SizesInputGraph  lsize(SizesFitIntensity)=3	
	ModifyGraph/W=IR1R_SizesInputGraph lstyle(BackgroundWave)=3

	ModifyGraph/W=IR1R_SizesInputGraph mode(IntensityOriginal)=3
	ModifyGraph/W=IR1R_SizesInputGraph msize(IntensityOriginal)=2
	ModifyGraph/W=IR1R_SizesInputGraph rgb(IntensityOriginal)=(0,52224,0)
	ModifyGraph/W=IR1R_SizesInputGraph zmrkNum(IntensityOriginal)={DeletePointsMaskWave}
	ErrorBars/W=IR1R_SizesInputGraph IntensityOriginal Y,wave=(DeletePointsMaskErrorWave,DeletePointsMaskErrorWave)

	ModifyGraph/W=IR1R_SizesInputGraph mode(CurrentResultSizeDistribution)=5
	ModifyGraph/W=IR1R_SizesInputGraph hbFill(CurrentResultSizeDistribution)=4	
	ModifyGraph/W=IR1R_SizesInputGraph useNegRGB(CurrentResultSizeDistribution)=1
	ModifyGraph/W=IR1R_SizesInputGraph usePlusRGB(CurrentResultSizeDistribution)=1
	ModifyGraph/W=IR1R_SizesInputGraph hbFill(CurrentResultSizeDistribution)=12
	ModifyGraph/W=IR1R_SizesInputGraph plusRGB(CurrentResultSizeDistribution)=(32768,65280,0)
	ModifyGraph/W=IR1R_SizesInputGraph negRGB(CurrentResultSizeDistribution)=(32768,65280,0)
	ModifyGraph/W=IR1R_SizesInputGraph  lblMargin(right)=41,lblMargin(top)=20
	ModifyGraph/W=IR1R_SizesInputGraph  lblPos(left)=75,lblPos(ChisquaredAxis)=77
	ModifyGraph/W=IR1R_SizesInputGraph  lblLatPos(right)=1,lblLatPos(top)=-45,lblLatPos(left)=-14,lblLatPos(ChisquaredAxis)=-6
	ModifyGraph/W=IR1R_SizesInputGraph  freePos(ChisquaredAxis)=0
	ModifyGraph/W=IR1R_SizesInputGraph  axisEnab(right)={0.15,1}
	ModifyGraph/W=IR1R_SizesInputGraph  axisEnab(left)={0.15,1}
	ModifyGraph/W=IR1R_SizesInputGraph  axisEnab(ChisquaredAxis)={0,0.15}

	ModifyGraph/W=IR1R_SizesInputGraph mode(NormalizedResidual)=3,marker(NormalizedResidual)=19
	ModifyGraph/W=IR1R_SizesInputGraph msize(NormalizedResidual)=1
	TextBox/W=IR1R_SizesInputGraph/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	
	NVAR Chisquare=root:Packages:Sizes:Chisquare
	variable/G FittedNumberOfpoints=numpnts(Intensity)
	SetVariable Chisquared size={180,15}, pos={400,5}, title="Chisquared reached", win=IR1R_SizesInputGraph
	SetVariable Chisquared limits={-Inf,Inf,0},value= root:Packages:Sizes:Chisquare, win=IR1R_SizesInputGraph
	SetVariable NumFittedPoints size={180,15}, pos={400,25}, title="Number of fitted points", win=IR1R_SizesInputGraph
	SetVariable NumFittedPoints limits={-Inf,Inf,0},value= root:Packages:Sizes:FittedNumberOfpoints, win=IR1R_SizesInputGraph

	IN2G_GenerateLegendForGraph(7,0,1)
	Legend/J/C/N=Legend1/J/A=LB/X=-8/Y=-8/W=IR1R_SizesInputGraph
	string LegendText2="\\Z09\K(0,0,65280)Method used: "+MethodRun+"\r"
	if(numtype(NumberIterations)!=0)
		LegendText2+="No success, change parameters and run again"
	elseif(NumberIterations==0)
		LegendText2+="working...."
	elseif(cmpstr(MethodRun,"MaxEnt")==0 && (NumberIterations>=MaxsasNumIter))
		LegendText2+="No success, change parameters and run again"
	else
		LegendText2+="Number of iterations ="+num2str(NumberIterations)				
	endif

	TextBox/C/F=0/N=Legend2/X=0.00/Y=-14.00 LegendText2

	DoUpdate						//and here we again record what we have done
	IN2G_AppendStringToWaveNote("CurrentResultSizeDistribution",SizesParameters)	
	IN2G_AppendStringToWaveNote("D_distribution",SizesParameters)	
	IN2G_AppendStringToWaveNote("SizesFitIntensity",SizesParameters)	
	IN2G_AppendStringToWaveNote("Q_vec",SizesParameters)	

	setDataFolder OldDf
end

//***********************************************************************************************************
//***********************************************************************************************************

static  Function IR1R_ReturnFitBack(ctrlName)			//copies data back to folder with original data
	string ctrlName
	
	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes

	SVAR fldrName=root:Packages:Sizes:DataFolderName
	Wave CurrentResultSizeDistribution=root:Packages:Sizes:CurrentResultSizeDistribution
	Wave D_distribution=root:Packages:Sizes:D_distribution
	Wave SizesFitIntensity=root:Packages:Sizes:SizesFitIntensity
	Wave Q_vec=root:Packages:Sizes:Q_vec
	Wave NormalizedResidual=root:Packages:Sizes:NormalizedResidual
	SVAR SizesParameters=root:Packages:Sizes:SizesParameters
	SVAR MethodRun=root:Packages:Sizes:MethodRun
	
	string tempname 
	variable ii=0
	setDataFolder fldrName
		For(ii=0;ii<1000;ii+=1)
			tempname="SizesVolumeDistribution_"+num2str(ii)
			if (checkname(tempname,1)==0)
				break
			endif
		endfor
	setDataFolder root:Packages:Sizes
	string UsersComment
	UsersComment="Result from Sizes method: "+MethodRun+"  "+date()+"  "+time()
	if(cmpstr(ctrlName,"SaveDataNoQuestions")!=0)
		Prompt UsersComment, "Modify comment to be saved with these results"
		DoPrompt "Sizes input for comment", UsersComment
		if (V_Flag)
			abort
		endif
	endif
	
	IN2G_AppendorReplaceWaveNote("CurrentResultSizeDistribution","UsersComment",UsersComment)
	IN2G_AppendorReplaceWaveNote("CurrentResultSizeDistribution","Wname",tempname)
	tempname=fldrName+tempname
	Duplicate/O CurrentResultSizeDistribution $tempname
	Redimension/D $tempname
	WAVE SizeDistributionFD=$tempname


	tempname="SizesDistDiameter_"+num2str(ii)
	IN2G_AppendorReplaceWaveNote("D_distribution","UsersComment",UsersComment)
	IN2G_AppendorReplaceWaveNote("D_distribution","Wname",tempname)
	IN2G_AppendorReplaceWaveNote("D_distribution","Units","A")
	tempname=fldrName+tempname
	Duplicate/O D_distribution $tempname
	Redimension/D $tempname
	WAVE SizeDistDiameter=$tempname

	tempname="SizesFitIntensity_"+num2str(ii)
	IN2G_AppendorReplaceWaveNote("SizesFitIntensity","UsersComment",UsersComment)
	IN2G_AppendorReplaceWaveNote("SizesFitIntensity","Wname","SizesFitIntensity")
	IN2G_AppendorReplaceWaveNote("SizesFitIntensity","Units","cm-1")
	tempname=fldrName+tempname
	Duplicate/O SizesFitIntensity $tempname
	Redimension/D $tempname
	WAVE SizesFitIntensity=$tempname

	tempname="SizesFitQvector_"+num2str(ii)
	IN2G_AppendorReplaceWaveNote("Q_vec","UsersComment",UsersComment)
	IN2G_AppendorReplaceWaveNote("Q_vec","Wname","SizesFitQvector")
	IN2G_AppendorReplaceWaveNote("Q_vec","Units","A-1")
	tempname=fldrName+tempname
	Duplicate/O Q_vec $tempname
	Redimension/D $tempname
	WAVE SizesFitQvector=$tempname
	
	setDataFolder fldrName
		tempname="SizesParameters_"+num2str(ii)
		String/g $tempname
		SVAR SizesExport=$tempname
	setDataFolder root:Packages:Sizes

	SVAR shape=root:Packages:Sizes:ShapeType
	variable Aspectratio=NumberByKey("AspectRatio", SizesParameters,"=")

	setDataFolder fldrName
	
	string tempnameVolNm="SizesVolumeDistribution_"+num2str(ii)
	string tempnameNumNm="SizesNumberDistribution_"+num2str(ii)

	Duplicate/O SizeDistributionFD, $tempnameNumNm, AveVolumeWave
	Wave SizesNumberDistribution=$tempnameNumNm
	Wave SizesVolumeDistribution=$tempnameVolNm
	Redimension/D SizesNumberDistribution, SizesVolumeDistribution, AveVolumeWave
	variable ParticlePar1=0, ParticlePar2=0, ParticlePar3=0, ParticlePar4=0, ParticlePar5=0
	variable UP1=0, UP2=0, UP3=0, UP4=0, UP5=0
	string ShapeType=shape
	//convert vol dist into num dist...
		if(cmpstr(ShapeType,"Algebraic_Integrated Spheres")==0)		//no parameter at all - it is sphere
		//no parameter
	elseif(cmpstr(ShapeType,"Cylinder")==0)						//Cylinder 1 poarameter - length
		NVAR CylinderLength=root:Packages:Sizes:CylinderLength	//CylinderLength
		ParticlePar1=CylinderLength
	elseif(cmpstr(ShapeType,"User")==0)						//Cylinder 1 poarameter - length
		NVAR ParticlePar1G=root:Packages:Sizes:UserFFpar1
		UP1=ParticlePar1G
		NVAR ParticlePar2G=root:Packages:Sizes:UserFFpar2
		UP2=ParticlePar2G
		NVAR ParticlePar3G=root:Packages:Sizes:UserFFpar3
		UP3=ParticlePar3G
		NVAR ParticlePar4G=root:Packages:Sizes:UserFFpar4
		UP4=ParticlePar4G
		NVAR ParticlePar5G=root:Packages:Sizes:UserFFpar5
		UP5=ParticlePar5G
	elseif(cmpstr(ShapeType,"CoreShell")==0)				//CoreShell - 2 parameters
		NVAR CoreShellThickness=root:Packages:Sizes:CoreShellThickness	//radius of primary particle
		ParticlePar1=CoreShellThickness
		NVAR CoreShellCoreRho=root:Packages:Sizes:CoreShellCoreRho	
		ParticlePar2=CoreShellCoreRho	
		NVAR CoreShellShellRho=root:Packages:Sizes:CoreShellShellRho	
		ParticlePar3=CoreShellShellRho	
	elseif(cmpstr(ShapeType,"Fractal aggregate")==0)				//Fractal aggregate - 2 parameters
		NVAR FractalRadiusOfPriPart=root:Packages:Sizes:FractalRadiusOfPriPart	//radius of primary particle
		ParticlePar1=FractalRadiusOfPriPart
		NVAR FractalDimension=root:Packages:Sizes:FractalDimension	
		ParticlePar2=FractalDimension	
	elseif(cmpstr(ShapeType,"Unified_Tube")==0)				//Tube - 3 parameters
		NVAR TubeLength=root:Packages:Sizes:TubeLength			//TubeLength
		ParticlePar1=TubeLength
		NVAR TubeWallThickness=root:Packages:Sizes:TubeWallThickness		//WallThickness
		ParticlePar2=TubeWallThickness	
	elseif(cmpstr(ShapeType,"Tube")==0)				//Tube - 3 parameters
		NVAR TubeLength=root:Packages:Sizes:TubeLength			//TubeLength
		ParticlePar1=TubeLength
		NVAR TubeWallThickness=root:Packages:Sizes:TubeWallThickness		//WallThickness
		ParticlePar2=TubeWallThickness	
		NVAR CoreShellCoreRho=root:Packages:Sizes:CoreShellCoreRho		//CoreContrastRatio
		ParticlePar3=CoreShellCoreRho	
		NVAR CoreShellShellRho=root:Packages:Sizes:CoreShellShellRho		//CoreContrastRatio
		ParticlePar4=CoreShellShellRho	
		NVAR CoreShellSolvntRho=root:Packages:Sizes:CoreShellSolvntRho		//CoreContrastRatio
		ParticlePar5=CoreShellSolvntRho	
	else												//the ones which require 1 parameter - aspect ratio
		ParticlePar1=AspectRatio
	endif
	SVAR User_FormFactorFnct=root:Packages:Sizes:User_FormFactorFnct
	SVAR User_FormFactorVol=root:Packages:Sizes:User_FormFactorVol

	IR1T_CreateAveVolumeWave(AveVolumeWave,SizeDistDiameter,shape,ParticlePar1,ParticlePar2,ParticlePar3,0,0,User_FormFactorVol,UP1,UP2,UP3,UP4,UP5)
	//IR1T_CreateAveVolumeWave(AveVolumeWave,Distdiameters,DistShapeModel,DistScatShapeParam1,DistScatShapeParam2,DistScatShapeParam3,UserVolumeFnctName,UserPar1,UserPar2,UserPar3,UserPar4,UserPar5)//	
	SizesNumberDistribution=SizesVolumeDistribution/AveVolumeWave
	
	variable MeanSize=IR1R_MeanOfDistribution(SizesVolumeDistribution,SizeDistDiameter)


	IN2G_AppendorReplaceWaveNote(tempnameVolNm,"UsersComment",UsersComment)
	IN2G_AppendorReplaceWaveNote(tempnameVolNm,"Wname","SizesVolumeDistribution")
	IN2G_AppendorReplaceWaveNote(tempnameVolNm,"Units","cm3/cm3")
	IN2G_AppendorReplaceWaveNote(tempnameVolNm,"MeanSizeOfDistribution",num2str(MeanSize))
	IN2G_AppendorReplaceWaveNote(tempnameNumNm,"UsersComment",UsersComment)
	IN2G_AppendorReplaceWaveNote(tempnameNumNm,"Wname","SizesNumberDistribution")
	IN2G_AppendorReplaceWaveNote(tempnameNumNm,"Units","1/cm3")
	IN2G_AppendorReplaceWaveNote(tempnameNumNm,"MeanSizeOfDistribution",num2str(MeanSize))

	//create record of all Sizes parameters to add to all of the waves as wave note...
	string ListOfVariables="SuggestedSkyBackground;UseSlitSmearedData;"
	ListOfVariables+="MaxEntSkyBckg;MaxEntRegular;MaxsasNumIter;numOfPoints;SlitLength;Rmin;Rmax;Bckg;ScatteringContrast;Dmin;"
	ListOfVariables+="Dmax;ErrorsMultiplier;TicksForDiagnostics;MaxEntStabilityParam;NumberIterations;MaxEntNumIter;"	
	ListOfVariables+="AspectRatio;FractalRadiusOfPriPart;FractalDimension;CylinderLength;TubeLength;"
	ListOfVariables+="CylinderLength;TubeWallThickness;TubeCoreContrastRatio;"
	ListOfVariables+="CoreShellThickness;CoreShellCoreRho;CoreShellShellRho;CoreShellSolvntRho;"
	ListOfVariables+="UserFFpar1;UserFFpar2;UserFFpar3;UserFFpar4;UserFFpar5;"
	ListOfVariables+="NNLS_MaxNumIterations;NNLS_ApproachParameter;"
	ListOfVariables+="UseRegularization;UseMaxEnt;UseTNNLS;"
	ListOfVariables+="SizesPowerToUse;UseUserErrors;UseSQRTErrors;UsePercentErrors;PercentErrorToUse;UseNoErrors;"
	ListOfVariables+="StartFItQvalue;EndFItQvalue;"
	
	string ListOfStrings=""
	ListOfStrings+="LogDist;ShapeType;SlitSmearedData;MethodRun;User_FormFactorFnct;User_FormFactorVol;"	
	variable i
	For(i=0;i<ItemsInList(ListOfVariables);i+=1)
		NVAR TempVal=$("root:Packages:Sizes:"+StringFromList(i,ListOfVariables))	
		IN2G_AppendorReplaceWaveNote(tempnameVolNm,StringFromList(i,ListOfVariables),num2str(TempVal))
		IN2G_AppendorReplaceWaveNote(tempnameNumNm,StringFromList(i,ListOfVariables),num2str(TempVal))	
	endfor	
	For(i=0;i<ItemsInList(ListOfStrings);i+=1)
		SVAR TempStr=$("root:Packages:Sizes:"+StringFromList(i,ListOfStrings))	
		IN2G_AppendorReplaceWaveNote(tempnameVolNm,StringFromList(i,ListOfStrings),(TempStr))
		IN2G_AppendorReplaceWaveNote(tempnameNumNm,StringFromList(i,ListOfStrings),(TempStr))	
	endfor	
	
	print "Mean size of distribution"+num2str(MeanSize)

	SizesParameters=ReplaceStringByKey("MeanSizeOfDistribution", SizesParameters, num2str(MeanSize),"=")
	
	SizesExport=SizesParameters
	setDataFolder OldDf

end 

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Window IR1R_SizesInputPanel() 
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(6,10,372,670) as "Size distribution"
	SetDrawLayer UserBack
	SetDrawEnv fname= "Times New Roman", save
	SetDrawEnv fsize= 16,fstyle= 1,textrgb= (65280,0,0)
	DrawText 74,231,"Distribution parameters"
	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,0,52224)
	DrawText 48,599,"Set range of data to fit with cursors!!"
//	SetDrawEnv gstart
//	SetDrawEnv gstop
	DrawLine 9,291,350,291
	DrawText 20,650,"You need to store the results or they are lost!!"
	SetDrawEnv fsize= 20,fstyle= 1,textrgb= (0,15872,65280)
	DrawText 70,22,"Sizes input panel"
	DrawLine 8,33,100,33
	DrawLine 8,209,349,209
	DrawLine 140,407,348,407
	DrawLine 8,487,348,487
	DrawLine 8,583,348,583
	SetDrawEnv fsize= 16,fstyle= 1,textrgb= (65280,0,0)
	DrawText 5,54,"Data"
	SetDrawEnv fsize= 16,fstyle= 1,textrgb= (65280,0,0)
	DrawText 90,310,"Fitting parameters"
	SetDrawEnv fsize= 16,fstyle= 1,textrgb= (65280,0,0)
	DrawText 5,417,"Particle model"
	SetDrawEnv fsize= 16,fstyle= 1,textrgb= (65280,0,0)
	DrawText 8,509,"Method: "

	string UserDataTypes=""
	string UserNameString="Test me"
	string XUserLookup="r*:q*;"
	string EUserLookup="r*:s*;"
	IR2C_AddDataControls("Sizes","IR1R_SizesInputPanel","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,0)
	CheckBox ShowDiagnostics,pos={10,165},size={141,14},title="Diagnostics?", help={"Check to show extendend diagnostics during evaluation"}
	CheckBox ShowDiagnostics,variable= root:Packages:Sizes:ShowDiagnostics
	Button GraphIfAllowed,pos={40,183},size={100,20},font="Times New Roman",fSize=10,proc=IR1R_GraphDataButton,title="Graph", help={"Push to graph data"}
	CheckBox SlitSmearedData,pos={160,164},size={150,21},proc=IR1R_InputPanelCheckboxProc,title="Slit smeared data?"
	CheckBox SlitSmearedData,variable=root:Packages:Sizes:UseSlitSmearedData, help={"Are these slit smeared data?"}
	SetVariable SlitLength,pos={167,188},size={140,16},title="Slit Length   ", help={"If slit smeared data, input slit length (automatically inserted for Indra 2 data"}
	SetVariable SlitLength,limits={0,Inf,0.001},value= root:Packages:Sizes:SlitLength, disable=!(root:Packages:Sizes:UseSlitSmearedData)
	SetVariable RminInput,pos={13,237},size={150,16},title="Minimum diameter", help={"Input minimum diameter of the particles being modeled"}
	SetVariable RminInput,limits={0,Inf,5},value= root:Packages:Sizes:Dmin
	SetVariable RmaxInput,pos={199,237},size={150,16},title="Maximum diameter", help={"Input maximum diamter of particles being modeled"}
	SetVariable RmaxInput,limits={1,Inf,5},value= root:Packages:Sizes:Dmax
	PopupMenu Binning,pos={188,264},size={161,21},proc=IR1R_PopMenuProc,title="Logaritmic binning ?"
	PopupMenu Binning,mode=1,popvalue=root:Packages:Sizes:LogDist,value= #"\"Yes;No\"", help={"If selected Yes, bins diameter are equidistantly spaced in their logarithm, if No selected the bins are all same width"}
	SetVariable RadiaSteps,pos={13,264},size={150,16},title="Bins in diameter"
	SetVariable RadiaSteps,limits={1,Inf,5},value= root:Packages:Sizes:numOfPoints, help={"Number of bins modeled."}

	CheckBox UseUserErrors,pos={250,310},size={141,14},proc=IR1R_InputPanelCheckboxProc,title="Use user errors?", mode=1
	CheckBox UseUserErrors,variable= root:packages:Sizes:UseUserErrors, help={"Check, if you want to use errors provided by you from error wave"}
	CheckBox UseSQRTErrors,pos={250,330},size={141,14},proc=IR1R_InputPanelCheckboxProc,title="Use sqrt errors?", mode=1
	CheckBox UseSQRTErrors,variable= root:packages:Sizes:UseSQRTErrors, help={"Check, if you want to use errors equal square root of intensity"}
	CheckBox UsePercentErrors,pos={250,350},size={141,14},proc=IR1R_InputPanelCheckboxProc,title="Use % errors?", mode=1
	CheckBox UsePercentErrors,variable= root:packages:Sizes:UsePercentErrors, help={"Check, if you want to use errors equal n% of intensity"}
	CheckBox UseNoErrors,pos={250,370},size={141,14},proc=IR1R_InputPanelCheckboxProc,title="Use No errors?", mode=1
	CheckBox UseNoErrors,variable= root:packages:Sizes:UseNoErrors, help={"Check, if you do not want to use errors"}

	SetVariable ErrorMultiplier,pos={5,358},size={220,16},title="Multiply Errors by :                        ", proc=IR1R_SetVarProc, disable=!(root:packages:Sizes:UseUserErrors || root:packages:Sizes:UseSQRTErrors)
	SetVariable ErrorMultiplier,limits={0,Inf,root:Packages:Sizes:ErrorsMultiplier/10},value= root:Packages:Sizes:ErrorsMultiplier, help={"Errors scaling factor"}
	SetVariable PercentErrorToUse,pos={5,358},size={220,16},title="Errors % ofintensity :                     ", proc=IR1R_SetVarProc, disable=!(root:packages:Sizes:UsePercentErrors)
	SetVariable PercentErrorToUse,limits={0,Inf,1},value= root:Packages:Sizes:PercentErrorToUse, help={"Percent errors of intensity"}
	PopupMenu SizesPowerToUse,pos={5,380},size={161,21},proc=IR1R_PopMenuProc,title="Scaling power ?", disable=!(root:packages:Sizes:UseNoErrors)
	PopupMenu SizesPowerToUse,mode=(1+root:Packages:Sizes:SizesPowerToUse),popvalue=num2str(root:Packages:Sizes:SizesPowerToUse),value= #"\"0;1;2;3;4\"", help={"Parameter used to scale SAXS data - most likely 1 or 2, range 0 to 4, test to find ideal..."}

	SetVariable Background,pos={5,315},size={220,16},proc=IR1R_BackgroundInput,title="Subtract Background                   "
	SetVariable Background,limits={-Inf,Inf,0.001},value= root:Packages:Sizes:Bckg, help={"Value for flat backgound"}
	SetVariable ScatteringContrast,pos={5,336},size={220,16},title="Contrast (drho^2)[10^20, 1/cm4] ", proc=IR1R_SetVarProc, disable=1
	SetVariable ScatteringContrast,limits={0,Inf,1},value= root:Packages:Sizes:ScatteringContrast, help={"Scattering contrast, if data are calibrated and proper scattering contrast used, the results are calibrated."}

//shapes
	PopupMenu ShapeModel,pos={10,418},size={223,21},proc=IR1R_PopMenuProc,title="Select particle shape model", help={"Particle shape models in the code. Set appropriate Aspect ratio. "}
	PopupMenu ShapeModel,mode=1,popvalue=root:Packages:Sizes:ShapeType,value= root:Packages:FormFactorCalc:ListOfFormFactors

	SetVariable AspectRatio,pos={10,444},size={140,16},title="Aspect Ratio ", help={"Aspect ratio for spheroids and other particles with AR"}
	SetVariable AspectRatio,limits={0,Inf,0.1},value= root:Packages:Sizes:AspectRatio

	SetVariable CoreShellThickness,pos={5,440},size={170,15},title="Shell thickness [A] ", disable=1
	SetVariable CoreShellThickness,limits={0,Inf,0},value= root:Packages:Sizes:CoreShellThickness, help={"Thickness of shell in A"}
	SetVariable CoreShellCoreRho,pos={5,455},size={170,15},title="Core Rho [10^10 cm-2] ", disable=1
	SetVariable CoreShellCoreRho,limits={-inf,Inf,0},value= root:Packages:Sizes:CoreShellCoreRho, help={"Rho (not delat rho sqaured) for core material"}
	SetVariable CoreShellShellRho,pos={5,470},size={170,15},title="Shell Rho [10^10 cm-2] ", disable=1
	SetVariable CoreShellShellRho,limits={-inf,Inf,0},value= root:Packages:Sizes:CoreShellShellRho, help={"Rho (not delat rho sqaured) for shell material"}
	SetVariable CoreShellSolvntRho,pos={180,470},size={180,15},title="Solvant Rho [10^10 cm-2] ", disable=1
	SetVariable CoreShellSolvntRho,limits={-inf,Inf,0},value= root:Packages:Sizes:CoreShellSolvntRho, help={"Rho (not delat rho sqaured) for surrownding material (air ~0)"}

	SetVariable TubeLength,pos={5,440},size={160,15},title="Tube length [A]   ", disable=1
	SetVariable TubeLength,limits={0,Inf,0},value= root:Packages:Sizes:TubeLength, help={"Length of Core shell cylinder = tube"}
	SetVariable TubeWallThickness,pos={180,455},size={160,15},title="Tube wall thickn. ", disable=1
	SetVariable TubeWallThickness,limits={0,Inf,0},value= root:Packages:Sizes:TubeWallThickness, help={"Thickness shell of the core shell cylinder = tube"}

	SetVariable CylinderLength,pos={10,444},size={140,16},title="Cylinder Length ", disable=1
	SetVariable CylinderLength,limits={0,Inf,100},value= root:Packages:Sizes:CylinderLength, help={"Length of cylinder"}

	SetVariable FractalRadiusOfPriPart,pos={10,444},size={170,16},title="Primary part radius ", disable=1
	SetVariable FractalRadiusOfPriPart,limits={0,Inf,5},value= root:Packages:Sizes:FractalRadiusOfPriPart, help={"Radius of the primary particle (A)"}
	SetVariable FractalDimension,pos={10,464},size={170,16},title="Fractal dimension ", disable=1
	SetVariable FractalDimension,limits={0,4,0.2},value= root:Packages:Sizes:FractalDimension, help={"Fractal dimension)"}

//Method
	CheckBox UseTNNLS,pos={70,493},size={141,14},proc=IR1R_InputPanelCheckboxProc,title="IPG/TNNLS", mode=1
	CheckBox UseTNNLS,variable= root:packages:Sizes:UseTNNLS, help={"Select to use Interior-point gradient method - totally NNLS method"}
	CheckBox UseMaxEnt,pos={160,493},size={141,14},proc=IR1R_InputPanelCheckboxProc,title="MaxEnt", mode=1
	CheckBox UseMaxEnt,variable= root:packages:Sizes:UseMaxEnt, help={"Select to use Maximum Entropy method"}
	CheckBox UseRegularization,pos={220,493},size={141,14},proc=IR1R_InputPanelCheckboxProc,title="Regularization", mode=1
	CheckBox UseRegularization,variable= root:packages:Sizes:UseRegularization, help={"Select to use Regularization method"}

//NNLS 
	SetVariable NNLS_ApproachParameter,pos={10,514},size={220,16},title="NNLS approach param.       ", proc=IR1R_SetVarProc, disable=!(root:packages:Sizes:UseTNNLS)
	SetVariable NNLS_ApproachParameter,limits={0.3,0.99,0.03},value= root:Packages:Sizes:NNLS_ApproachParameter, help={"Internal precision parameter for NNLS Entropy, usually ~0.6, range 0.3 to 0.99."}
	SetVariable NNLS_MaxNumIterations,pos={10,534},size={220,16},title="NNLS max Num of Iterations", proc=IR1R_SetVarProc, disable=!(root:packages:Sizes:UseTNNLS)
	SetVariable NNLS_MaxNumIterations,limits={10,Inf,100},value= root:Packages:Sizes:NNLS_MaxNumIterations, help={"IPG/TNNLS maximum number of iterations. Varies significantly."}

	//NVAR SizesPowerToUse=root:Packages:Sizes:SizesPowerToUse

//MaxSAS stuf
	SetVariable SizesStabilityParam,pos={10,514},size={240,16},title="Sizes precision param              ", proc=IR1R_SetVarProc, disable=!(root:packages:Sizes:UseMaxEnt)
	SetVariable SizesStabilityParam,limits={0,Inf,1},value= root:Packages:Sizes:MaxEntStabilityParam, help={"Internal precision parameter for Maximum Entropy, usually ~0.01, range 0 to 0.5. Lower value requires resulting chi^2 to be closer to target "}
	SetVariable MaxsasIter,pos={10,534},size={240,16},title="MaxEnt max Num of Iterations ", proc=IR1R_SetVarProc, disable=!(root:packages:Sizes:UseMaxEnt)
	SetVariable MaxsasIter,limits={0,Inf,1},value= root:Packages:Sizes:MaxsasNumIter, help={"Maximum Entropy maximum number of iterations"}
	SetVariable MaxSkyBckg,pos={10,559},size={200,16},title="MaxEnt sky backg      ", proc=IR1R_SetVarProc, disable=!(root:packages:Sizes:UseMaxEnt)
	SetVariable MaxSkyBckg,limits={0,Inf,1e-06},value= root:Packages:Sizes:MaxEntSkyBckg, help={"Parameter for Maximum Entropy"}
	SetVariable SuggestedSkyBackground,pos={230,550},title="Suggested:", disable=!(root:packages:Sizes:UseMaxEnt)
	SetVariable SuggestedSkyBackground,limits={0,Inf,0},value= root:Packages:Sizes:SuggestedSkyBackground, help={"Suggested value forParameter for Maximum Entropy"}
	SetVariable SuggestedSkyBackground size={130,16},noedit=1,frame=0
	SetVariable SuggestedSkyBackground font="Times New Roman",fstyle=0
	Button SetMaxEntSkyBckg,pos={230,565},size={100,13},font="Times New Roman",fSize=10,proc=IR1R_SizesButtonProc,title="Set", help={"Set suggested MaxEnt Sky background to suggested value"}

//end buttons
	Button RunSizes,pos={200,610},size={150,20},font="Times New Roman",fSize=10,proc=IR1R_SizesFitting,title="Run Fitting", help={"Push to run fitting using method selected above"}
//	Button RunInternalMaxEnt,pos={198,610},size={150,20},font="Times New Roman",fSize=10,proc=IR1R_SizesFitting,title="Run Internal MaxEnt", help={"Push to run MaxEnt within Igor"}
//	Button RunNNLS,pos={198,637},size={150,20},font="Times New Roman",fSize=10,proc=IR1R_SizesFitting,title="Run NNLS", help={"Push to run NNLS within Igor"}
	Button CopyDataToNbk,pos={26,600},size={150,15},font="Times New Roman",fSize=10,proc=IR1R_saveData,title="Paste to Notebook", help={"Push to copy results to folder where the data came from"}
	Button SaveData,pos={26,620},size={150,15},font="Times New Roman",fSize=10,proc=IR1R_saveData,title="Store in Data Folder", help={"Push to copy results to folder where the data came from"}
EndMacro
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


static Function IR1R_SaveResultsToNotebook()

	IR1_CreateResultsNbk()
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes
	SVAR  DataFolderName=root:Packages:Sizes:DataFolderName
	SVAR  IntensityWaveName=root:Packages:Sizes:IntensityWaveName
	SVAR  QWavename=root:Packages:Sizes:QWavename
	SVAR  ErrorWaveName=root:Packages:Sizes:ErrorWaveName
//	SVAR  MethodRun=root:Packages:Sizes:MethodRun
	IR1_AppendAnyText("\r Results of Size distribution fitting\r",1)	
	IR1_AppendAnyText("Date & time: \t"+Date()+"   "+time(),0)	
	IR1_AppendAnyText("Data from folder: \t"+DataFolderName,0)	
	IR1_AppendAnyText("Intensity: \t"+IntensityWaveName,0)	
	IR1_AppendAnyText("Q: \t"+QWavename,0)	
	IR1_AppendAnyText("Error: \t"+ErrorWaveName,0)	
//	IR1_AppendAnyText("Method used: \t"+MethodRun,0)	
	string FittingResults=""
	
	SVAR ShapeType=root:Packages:Sizes:ShapeType
	FittingResults+="\rSize distribution calculate using shape : "+ShapeType+"\r"
	NVAR Chisquare = root:Packages:Sizes:Chisquare
	NVAR Rmin=root:Packages:Sizes:Rmin
	NVAR Rmax=root:Packages:Sizes:Rmax
	NVAR Background=root:Packages:Sizes:Bckg
	NVAR Contrast = root:Packages:Sizes:ScatteringContrast
	NVAR UseReg = root:Packages:Sizes:UseRegularization
	NVAR useMEM=root:Packages:Sizes:UseMaxEnt
	NVAR useTNNLS=root:Packages:Sizes:UseTNNLS
	FittingResults+="Rmin = "+num2str(Rmin)+"     Rmax = "+num2str(Rmax)+"\r"
	FittingResults+="Scattering contrast = "+num2str(Contrast)+"\r"
	FittingResults+="Used method :" 
	if(useMEM)
		FittingResults+="Maximum Entropy"+"\r"
	elseif(useTNNLS)
		FittingResults+="TNNLS"+"\r"
	else
		FittingResults+="Regularization"+"\r"	
	endif	
	IR1_AppendAnyGraph("IR1R_SizesInputGraph")
//	SVAR FittingResults = root:Packages:Irena_PDDF:FittingResults
	IR1_AppendAnyText(FittingResults,0)	
	IR1_AppendAnyText("******************************************\r",0)	
	SetDataFolder OldDf
	SVAR/Z nbl=root:Packages:Irena:ResultsNotebookName	
	DoWindow/F $nbl
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1R_SizesButtonProc(ctrlName) : ButtonControl			//this function is called by button from the panel
	String ctrlName

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes


	if(cmpstr("SetMaxEntSkyBckg",ctrlName)==0)
		NVAR MaxEntSkyBckg=root:Packages:Sizes:MaxEntSkyBckg
		NVAR SuggestedSkyBackground=root:Packages:Sizes:SuggestedSkyBackground
		if(SuggestedSkyBackground<=0)
			abort
		endif
		MaxEntSkyBckg=SuggestedSkyBackground
		SetVariable SuggestedSkyBackground labelBack=0, win=IR1R_SizesInputPanel
		SetVariable SuggestedSkyBackground font="Times New Roman",fstyle=0, win=IR1R_SizesInputPanel
		Button SetMaxEntSkyBckg, fColor=(0,0,0), win=IR1R_SizesInputPanel
	endif
	DoWIndow/F IR1R_SizesInputPanel

	setDataFolder OldDf
end	

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR1R_SetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	DoWindow/F IR1R_SizesInputPanel
	IR1G_UpdateSetVarStep(ctrlName,0.1)

	if(cmpstr("MaxsasIter",ctrlName)==0)
		NVAR test=root:Packages:Sizes:MaxsasNumIter
		test=floor(test)
	endif
	if(cmpstr("ErrorMultiplier",ctrlName)==0)
		IR1R_UpdateErrorWave()
	endif
	if(cmpstr("PercentErrorToUse",ctrlName)==0)
		IR1R_UpdateErrorWave()
	endif
	DoWIndow/F IR1R_SizesInputPanel

End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1R_InputPanelCheckboxProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes


	NVAR UseUserErrors=root:packages:Sizes:UseUserErrors
	NVAR UseSQRTErrors=root:packages:Sizes:UseSQRTErrors
	NVAR UsePercentErrors=root:packages:Sizes:UsePercentErrors
	NVAR UseNoErrors=root:packages:Sizes:UseNoErrors
	SVAR ErrorWaveName=root:Packages:Sizes:ErrorWaveName
	if(cmpstr(ctrlName,"UseUserErrors")==0 && !(cmpstr(ErrorWaveName,"---")==0 || cmpstr(ErrorWaveName,"'---'")==0))
		UseUserErrors=1
		UseSQRTErrors=0
		UsePercentErrors=0
		UseNoErrors=0
		IR1R_UpdateErrorWave()
	elseif(cmpstr(ctrlName,"UseUserErrors")==0 && (cmpstr(ErrorWaveName,"---")==0 || cmpstr(ErrorWaveName,"'---'")==0))
		UseUserErrors=0
		UseSQRTErrors=0
		UsePercentErrors=0
		UseNoErrors=1
		IR1R_UpdateErrorWave()
	endif
	if(cmpstr(ctrlName,"UseSQRTErrors")==0)
		UseUserErrors=0
		//UseSQRTErrors=0
		UsePercentErrors=0
		UseNoErrors=0
		IR1R_UpdateErrorWave()
	endif
	if(cmpstr(ctrlName,"UsePercentErrors")==0)
		UseUserErrors=0
		UseSQRTErrors=0
		//UsePercentErrors=0
		UseNoErrors=0
		IR1R_UpdateErrorWave()
	endif
	if(cmpstr(ctrlName,"UseNoErrors")==0)
		UseUserErrors=0
		UseSQRTErrors=0
		UsePercentErrors=0
		//UseNoErrors=0
		IR1R_UpdateErrorWave()
	endif
	SetVariable ErrorMultiplier,disable=!(UseUserErrors||UseSQRTErrors)
	SetVariable PercentErrorToUse, disable=!(UsePercentErrors)
	PopupMenu SizesPowerToUse, disable=!(UseNoErrors)

	if(cmpstr(ctrlName,"SlitSmearedData")==0)
		SVAR SlitSmeared=root:Packages:Sizes:SlitSmearedData
		SVAR SizesParameters=root:Packages:Sizes:SizesParameters
		if(checked)	
			SlitSmeared="yes"
		else
			SlitSmeared="no"
		endif
		SizesParameters=ReplaceStringByKey("RegSlitSmearedData",SizesParameters,SlitSmeared,"=")
		SetVariable SlitLength,disable=!(checked)
		SVAR Dtf=root:Packages:Sizes:DataFolderName
		SVAR IntDf=root:Packages:Sizes:IntensityWaveName
		SVAR QDf=root:Packages:Sizes:QWaveName
		SVAR EDf=root:Packages:Sizes:ErrorWaveName
			Dtf=" "
			IntDf=" "
			QDf=" "
			EDf=" "
			PopupMenu SelectDataFolder, win=IR1R_SizesInputPanel, mode=1
			PopupMenu IntensityDataName, win=IR1R_SizesInputPanel, mode=1, value="---"
			PopupMenu QvecDataName, win=IR1R_SizesInputPanel,  mode=1, value="---"
			PopupMenu ErrorDataName, win=IR1R_SizesInputPanel,  mode=1, value="---"
	endif

	NVAR UseTNNLS= root:packages:Sizes:UseTNNLS
	NVAR UseMaxEnt= root:packages:Sizes:UseMaxEnt
	NVAR UseRegularization= root:packages:Sizes:UseRegularization
	if(cmpstr(ctrlName,"UseTNNLS")==0)
		UseTNNLS=1
		UseMaxEnt=0
		UseRegularization=0
	endif
	if(cmpstr(ctrlName,"UseMaxEnt")==0)
		UseTNNLS=0
		UseMaxEnt=1
		UseRegularization=0
	endif
	if(cmpstr(ctrlName,"UseRegularization")==0)
		UseTNNLS=0
		UseMaxEnt=0
		UseRegularization=1
	endif
	SetVariable NNLS_ApproachParameter,disable=!(UseTNNLS)
	SetVariable NNLS_MaxNumIterations,disable=!(UseTNNLS)

	SetVariable SizesStabilityParam,disable=!(UseMaxEnt)
	SetVariable MaxsasIter,disable=!(UseMaxEnt)
	SetVariable MaxSkyBckg,disable=!(UseMaxEnt)
	SetVariable SuggestedSkyBackground,disable=!(UseMaxEnt)
	Button SetMaxEntSkyBckg,disable=!(UseMaxEnt)

	DoWIndow/F IR1R_SizesInputPanel
	SETDATaFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1R_PopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	SVAR SizesParameters=root:Packages:Sizes:SizesParameters

	if(cmpstr(ctrlName,"Binning")==0)
		SVAR LogDist=root:Packages:Sizes:LogDist	
		LogDist=popStr
		SizesParameters=ReplaceStringByKey("RegLogRBinning",SizesParameters,popStr,"=")
		NVAR GraphLogTopAxis=root:Packages:Sizes:GraphLogTopAxis
		if(cmpstr(LogDist,"yes")==0)
			GraphLogTopAxis=1
		else
			GraphLogTopAxis=0
		endif
		IR1R_GraphCheckboxes("LogParticleAxis",GraphLogTopAxis)
	endif
	if(cmpstr(ctrlName,"SizesPowerToUse")==0)
		NVAR SizesPowerToUse=root:Packages:Sizes:SizesPowerToUse	
		SizesPowerToUse = str2num(popStr)
	endif
	//NVAR SizesPowerToUse=root:Packages:Sizes:SizesPowerToUse

	if(cmpstr(ctrlName,"ShapeModel")==0)
		SVAR ShapeType=root:Packages:Sizes:ShapeType
		SVAR User_FormFactorFnct=root:Packages:Sizes:User_FormFactorFnct
		SVAR User_FormFactorVol=root:Packages:Sizes:User_FormFactorVol
		ShapeType=popStr
		SizesParameters=ReplaceStringByKey("RegParticleShape",SizesParameters,popStr,"=")
		SetVariable AspectRatio,disable=1,win=IR1R_SizesInputPanel
		SetVariable CoreShellThickness,disable=1,win=IR1R_SizesInputPanel
		SetVariable CoreShellCoreRho,disable=1,win=IR1R_SizesInputPanel
		SetVariable CoreShellShellRho,disable=1,win=IR1R_SizesInputPanel
		SetVariable CoreShellSolvntRho,disable=1,win=IR1R_SizesInputPanel
		SetVariable CylinderLength,disable=1,win=IR1R_SizesInputPanel
		SetVariable FractalRadiusOfPriPart,disable=1,win=IR1R_SizesInputPanel
		SetVariable FractalDimension,disable=1,win=IR1R_SizesInputPanel
		SetVariable TubeLength,disable=1,win=IR1R_SizesInputPanel
		SetVariable TubeWallThickness,disable=1,win=IR1R_SizesInputPanel
		SetVariable AspectRatio,disable=1	,win=IR1R_SizesInputPanel
		SetVariable ScatteringContrast,disable=0	,win=IR1R_SizesInputPanel
		DoWindow IR1R_SizesUserFFInputPanel
		if(V_Flag)
			DoWindow/K IR1R_SizesUserFFInputPanel
		endif


		if (cmpstr(popstr,"Fractal Aggregate")==0)
			SetVariable FractalRadiusOfPriPart,disable=0,win=IR1R_SizesInputPanel
			SetVariable FractalDimension,disable=0,win=IR1R_SizesInputPanel
		elseif(cmpstr(popstr,"Cylinder")==0)	
			SetVariable CylinderLength,disable=0,win=IR1R_SizesInputPanel
		elseif(cmpstr(popstr,"Unified_Sphere")==0)	
		
		elseif(cmpstr(popstr,"Unified_Disk")==0)	
			SetVariable AspectRatio,disable=0,win=IR1R_SizesInputPanel, title="Disk thickness [A] ", help={"thickness of the disk in A"}
		elseif(cmpstr(popstr,"Unified_Rod")==0)	
			SetVariable AspectRatio,disable=0,win=IR1R_SizesInputPanel, title="Rod Length [A] ", help={"length of the rod, in A"}
		elseif(cmpstr(popstr,"CoreShell")==0)	
			SetVariable ScatteringContrast,disable=1,win=IR1R_SizesInputPanel
			SetVariable CoreShellThickness,disable=0,win=IR1R_SizesInputPanel
			SetVariable CoreShellCoreRho,disable=0,win=IR1R_SizesInputPanel
			SetVariable CoreShellShellRho,disable=0,win=IR1R_SizesInputPanel
			SetVariable CoreShellSolvntRho,disable=0,win=IR1R_SizesInputPanel
		elseif(cmpstr(popstr,"Unified_Tube")==0)	
			SetVariable ScatteringContrast,disable=0,win=IR1R_SizesInputPanel
			SetVariable TubeLength,disable=0,win=IR1R_SizesInputPanel
			SetVariable TubeWallThickness,disable=0,win=IR1R_SizesInputPanel
		elseif(cmpstr(popstr,"Tube")==0)	
			SetVariable ScatteringContrast,disable=1,win=IR1R_SizesInputPanel
			SetVariable TubeLength,disable=0,win=IR1R_SizesInputPanel
			SetVariable TubeWallThickness,disable=0,win=IR1R_SizesInputPanel
			SetVariable CoreShellCoreRho,disable=0,win=IR1R_SizesInputPanel
			SetVariable CoreShellShellRho,disable=0,win=IR1R_SizesInputPanel
			SetVariable CoreShellSolvntRho,disable=0,win=IR1R_SizesInputPanel
		elseif(cmpstr(popstr,"User")==0)	
			DoWindow IR1R_SizesUserFFInputPanel
			if(V_Flag)
				DoWindow/K IR1R_SizesUserFFInputPanel
			endif
			Execute("IR1R_SizesUserFFInputPanel()")
		else
			SetVariable AspectRatio,disable=0,win=IR1R_SizesInputPanel, title="Aspect Ratio ", help={"Aspect ratio for spheroids and other particles with AR"}
		endif
	endif

		NVAR UseIndra2Data=root:Packages:Sizes:UseIndra2Data
		NVAR UseQRSData=root:Packages:Sizes:UseQRSdata
		SVAR IntDf=root:Packages:Sizes:IntensityWaveName
		SVAR QDf=root:Packages:Sizes:QWaveName
		SVAR EDf=root:Packages:Sizes:ErrorWaveName
		SVAR Dtf=root:Packages:Sizes:DataFolderName
		NVAR UseSlitSmearedData=root:Packages:Sizes:UseSlitSmearedData
	
//	if(cmpstr(ctrlName,"SelectFolder")==0)
//		//here goes what happens when user selects the folder...
//		Dtf=popStr
//		PopupMenu SelectIntensity mode=1
//		PopupMenu SelectQvector mode=1
//		PopupMenu SelectError mode=1
//		if (UseIndra2Data)
//			if(UseSlitSmearedData)
//				if(stringmatch(IR1R_ListOfWaves("SMR_Int"), "*M_SMR_Int*") &&stringmatch(IR1R_ListOfWaves("SMR_Qvec"), "*M_SMR_Qvec*")  &&stringmatch(IR1R_ListOfWaves("SMR_Error"), "*M_SMR_Error*") )			
//					IntDf="M_SMR_Int"
//					QDf="M_SMR_Qvec"
//					EDf="M_SMR_Error"
//					PopupMenu SelectIntensity value="M_SMR_Int;SMR_Int"
//					PopupMenu SelectQvector value="M_SMR_Qvec;SMR_Qvec"
//					PopupMenu SelectError value="M_SMR_Error;SMR_Error"
//				else
//					if(stringmatch(IR1R_ListOfWaves("SMR_Int"), "*SMR_Int*") &&stringmatch(IR1R_ListOfWaves("SMR_Qvec"), "*SMR_Qvec*")  &&stringmatch(IR1R_ListOfWaves("SMR_Error"), "*SMR_Error*") )			
//						IntDf="SMR_Int"
//						QDf="SMR_Qvec"
//						EDf="SMR_Error"
//						PopupMenu SelectIntensity value="SMR_Int"
//						PopupMenu SelectQvector value="SMR_Qvec"
//						PopupMenu SelectError value="SMR_Error"
//					endif
//				endif
//			else
//				if(stringmatch(IR1R_ListOfWaves("DSM_Int"), "*M_BKG_Int*") &&stringmatch(IR1R_ListOfWaves("DSM_Qvec"), "*M_BKG_Qvec*")  &&stringmatch(IR1R_ListOfWaves("DSM_Error"), "*M_BKG_Error*") )			
//					IntDf="M_BKG_Int"
//					QDf="M_BKG_Qvec"
//					EDf="M_BKG_Error"
//					PopupMenu SelectIntensity value="M_BKG_Int;M_DSM_Int;DSM_Int"
//					PopupMenu SelectQvector value="M_BKG_Qvec;M_DSM_Qvec;DSM_Qvec"
//					PopupMenu SelectError value="M_BKG_Error;M_DSM_Error;DCM_Error"
//				elseif(stringmatch(IR1R_ListOfWaves("DSM_Int"), "*BKG_Int*") &&stringmatch(IR1R_ListOfWaves("DSM_Qvec"), "*BKG_Qvec*")  &&stringmatch(IR1R_ListOfWaves("DSM_Error"), "*BKG_Error*") )			
//					IntDf="BKG_Int"
//					QDf="BKG_Qvec"
//					EDf="BKG_Error"
//					PopupMenu SelectIntensity value="BKG_Int;DSM_Int"
//					PopupMenu SelectQvector value="BKG_Qvec;DSM_Qvec"
//					PopupMenu SelectError value="BKG_Error;DCM_Error"
//				elseif(stringmatch(IR1R_ListOfWaves("DSM_Int"), "*M_DSM_Int*") &&stringmatch(IR1R_ListOfWaves("DSM_Qvec"), "*M_DSM_Qvec*")  &&stringmatch(IR1R_ListOfWaves("DSM_Error"), "*M_DSM_Error*") )			
//					IntDf="M_DSM_Int"
//					QDf="M_DSM_Qvec"
//					EDf="M_DSM_Error"
//					PopupMenu SelectIntensity value="M_DSM_Int;DSM_Int"
//					PopupMenu SelectQvector value="M_DSM_Qvec;DSM_Qvec"
//					PopupMenu SelectError value="M_DSM_Error;DCM_Error"
//				else
//					if(!stringmatch(IR1R_ListOfWaves("DSM_Int"), "*M_DSM_Int*") &&!stringmatch(IR1R_ListOfWaves("DSM_Qvec"), "*M_DSM_Qvec*")  &&!stringmatch(IR1R_ListOfWaves("DSM_Error"), "*M_DSM_Error*") )			
//						IntDf="DSM_Int"
//						QDf="DSM_Qvec"
//						EDf="DSM_Error"
//						PopupMenu SelectIntensity value="DSM_Int"
//						PopupMenu SelectQvector value="DSM_Qvec"
//						PopupMenu SelectError value="DSM_Error"
//					endif
//				endif
//			
//			endif
//		else
//			IntDf=""
//			QDf=""
//			EDf=""
//			PopupMenu SelectIntensity value="---"
//			PopupMenu SelectQvector  value="---"
//			PopupMenu SelectError  value="---"
//		endif
//		if(UseQRSdata)
//			IntDf=""
//			QDf=""
//			EDf=""
//			PopupMenu SelectIntensity  value="---;"+IR1R_ListOfWaves("DSM_Int")
//			PopupMenu SelectQvector  value="---;"+IR1R_ListOfWaves("DSM_Qvec")
//			PopupMenu SelectError  value="---;"+IR1R_ListOfWaves("DSM_Error")
//		endif
//		if(!UseQRSdata && !UseIndra2Data)
//			IntDf=""
//			QDf=""
//			EDf=""
//			PopupMenu SelectIntensity  value="---;"+IR1R_ListOfWaves("DSM_Int")
//			PopupMenu SelectQvector  value="---;"+IR1R_ListOfWaves("DSM_Qvec")
//			PopupMenu SelectError  value="---;"+IR1R_ListOfWaves("DSM_Error")
//		endif
//		if (cmpstr(popStr,"---")==0)
//			IntDf=""
//			QDf=""
//			EDf=""
//			PopupMenu SelectIntensity  value="---"
//			PopupMenu SelectQvector  value="---"
//			PopupMenu SelectError  value="---"
//		endif
//
//
//		DoWIndow IR1R_SizesInputGraph
//		if (V_Flag)
//			DoWindow/K IR1R_SizesInputGraph
//		endif
//	endif
//	
//	
//	if(cmpstr(ctrlName,"SelectIntensity")==0)
//		if (cmpstr(popStr,"---")!=0)
//			IntDf=popStr
//			if (UseQRSData && strlen(QDf)==0 && strlen(EDf)==0)
//				QDf="q"+popStr[1,inf]
//				EDf="s"+popStr[1,inf]
//				Execute ("PopupMenu SelectQvector mode=1, value=root:Packages:Sizes:OriginalQvectorWvName+\";---;\"+IR1R_ListOfWaves(\"DSM_Qvec\")")
//				Execute ("PopupMenu SelectError mode=1, value=root:Packages:Sizes:OriginalErrorWvName+\";---;\"+IR1R_ListOfWaves(\"DSM_Error\")")
//			endif
//		else
//			IntDf=""		
//		endif
//
//		DoWIndow IR1R_SizesInputGraph
//		if (V_Flag)
//			DoWindow/K IR1R_SizesInputGraph
//		endif
//	endif
//	
//	if(cmpstr(ctrlName,"SelectQvector")==0)
//		if (cmpstr(popStr,"---")!=0)
//			QDf=popStr	
//			if (UseQRSData && strlen(IntDf)==0 && strlen(EDf)==0)
//				IntDf="r"+popStr[1,inf]
//				EDf="s"+popStr[1,inf]
//				Execute ("PopupMenu SelectIntensity mode=1, value=root:Packages:Sizes:OriginalIntensityWvName+\";---;\"+IR1R_ListOfWaves(\"DSM_Int\")")
//				Execute ("PopupMenu SelectError mode=1, value=root:Packages:Sizes:OriginalErrorWvName+\";---;\"+IR1R_ListOfWaves(\"DSM_Error\")")
//			endif
//		else
//			QDf=""		
//		endif
//
//		DoWIndow IR1R_SizesInputGraph
//		if (V_Flag)
//			DoWindow/K IR1R_SizesInputGraph
//		endif
//
//		DoWIndow IR1R_SizesInputGraph
//		if (V_Flag)
//			DoWindow/K IR1R_SizesInputGraph
//		endif
//	endif
//
//	if(cmpstr(ctrlName,"SelectError")==0)
//		if (cmpstr(popStr,"---")!=0)
//			EDf=popStr	
//			if (UseQRSData && strlen(IntDf)==0 && strlen(QDf)==0)
//				IntDf="r"+popStr[1,inf]
//				QDf="q"+popStr[1,inf]
//				Execute ("PopupMenu SelectIntensity mode=1, value=root:Packages:Sizes:OriginalIntensityWvName+\";---;\"+IR1R_ListOfWaves(\"DSM_Int\")")
//				Execute ("PopupMenu SelectQvector mode=1, value=root:Packages:Sizes:OriginalQvectorWvName+\";---;\"+IR1R_ListOfWaves(\"DSM_Qvec\")")
//			endif
//		else
//			EDf=""		
//		endif
//	endif
	DoWIndow/F IR1R_SizesInputPanel

End


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Window Reg_FractalAgg_Input_Panel() 
	Variable which
	DoWindow Shape_Model_Input_Panel
	if (V_Flag)
			DoWindow/K Shape_Model_Input_Panel	
	endif
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(189,124.25,485.25,299.75) as "Fractal_Aggregate_Input_Panel"
	DoWindow/C Shape_Model_Input_Panel
	SetDrawLayer UserBack
	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,0,65280)
	DrawText 38,29,"Parameters for Fractal Aggregate"
	DrawText 34,68,"Input primary particle hard radius r0"
	DrawText 34,85,"Input fractal dimension D"
	DrawText 61,103,"These parameters cannot be fitted"
	SetVariable DisHardRadius,pos={38,117},size={200,16},title="Primary particle hard radius"
	SetVariable DisHardRadius,limits={0,Inf,1},value= $("root:Packages:Sizes:FractalRadiusOfPriPart")
	SetVariable DisFractalDimension,pos={38,140},size={200,16},title="Fractal dimension"
	SetVariable DisFractalDimension,limits={1,Inf,0.1},value= $("root:Packages:Sizes:FractalDimension")
endMacro

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1R_GraphIfAllowed(ctrlName)
		string ctrlName

		DoWIndow IR1R_SizesInputGraph
		if (V_Flag)
			DoWIndow/K IR1R_SizesInputGraph
		endif
		SVAR FldrNm=root:Packages:Sizes:DataFolderName

//		SVAR IntNm=root:Packages:Sizes:OriginalIntensityWvName
//		SVAR QvcNm=root:Packages:Sizes:OriginalQvectorWvName
//		SVAR ErrNm=root:Packages:Sizes:OriginalErrorWvName	
		SVAR IntNm=root:Packages:Sizes:IntensityWaveName
		SVAR QvcNm=root:Packages:Sizes:QWavename
		SVAR ErrNm=root:Packages:Sizes:ErrorWaveName	
		//fix for liberal names
		IntNm=IN2G_RemoveExtraQuote(IntNm,1,1)
		QvcNm=IN2G_RemoveExtraQuote(QvcNm,1,1)
		ErrNm=IN2G_RemoveExtraQuote(ErrNm,1,1)
		IntNm= PossiblyQuoteName(IntNm)
		QvcNm= PossiblyQuoteName(QvcNm)
		ErrNm= PossiblyQuoteName(ErrNm)

	//check if slit smeared data used...
	if(stringmatch(IntNm, "*SMR_Int") && stringmatch(ErrNm, "*SMR_Error") && stringmatch(QvcNm, "*SMR_Qvec"))
		SVAR SlitSmeared=root:Packages:Sizes:SlitSmearedData
		//NVAR UseSMRData=root:Packages:Sizes:UseSMRData
		NVAR UseSlitSmearedData=root:Packages:Sizes:UseSlitSmearedData
		SVAR SizesParameters=root:Packages:Sizes:SizesParameters
		SlitSmeared="yes"
		//UseSMRData=1
		UseSlitSmearedData=1
		SizesParameters=ReplaceStringByKey("RegSlitSmearedData",SizesParameters,SlitSmeared,"=")
		SetVariable SlitLength,disable=0
	elseif(stringmatch(IntNm, "*DSM_Int") && stringmatch(ErrNm, "*DSM_Error") && stringmatch(QvcNm, "*DSM_Qvec"))
		SVAR SlitSmeared=root:Packages:Sizes:SlitSmearedData
		//NVAR UseSMRData=root:Packages:Sizes:UseSMRData
		NVAR UseSlitSmearedData=root:Packages:Sizes:UseSlitSmearedData
		SVAR SizesParameters=root:Packages:Sizes:SizesParameters
		SlitSmeared="no"
		//UseSMRData=1
		UseSlitSmearedData=0
		SizesParameters=ReplaceStringByKey("RegSlitSmearedData",SizesParameters,SlitSmeared,"=")
		SetVariable SlitLength,disable=1
	endif
		
	if ((strlen(IN2G_RemoveExtraQuote(IntNm,1,1))>0)&&(strlen(IN2G_RemoveExtraQuote(QvcNm,1,1))>0)&&(strlen(IN2G_RemoveExtraQuote(ErrNm,1,1))>0))
		Wave Int=$(FldrNm+IntNm)
		Wave Qvc=$(FldrNm+QvcNm)
		Wave/Z Err=$(FldrNm+ErrNm)
		
		if ((numpnts(Int)==numpnts(Qvc))&&(!WaveExists(Err)||(numpnts(Int)==numpnts(Err))))
			IR1R_SelectAndCopyData()
			if(cmpstr(ctrlName,"GraphIfAllowedSkipRecover")!=0)
				IR1R_RecoverOldParameters()							//this function recovers fitting parameters, if sizes were run already on the data
			endif
		else
			DoAlert 0, "The data DO NOT have same number of points. This indicates problem with data. Please fix the data to same length and try again..." 
		endif
	
	endif

	DoWIndow/F IR1R_SizesInputPanel
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Proc  IR1R_SizesInputGraph() 
	PauseUpdate; Silent 1		// building window...
	SetDataFolder root:Packages:Sizes:
	Display/K=1 /W=(35*IN2G_ScreenWidthHeight("width"),5*IN2G_ScreenWidthHeight("heigth"),95*IN2G_ScreenWidthHeight("width"),80*IN2G_ScreenWidthHeight("height")) IntensityOriginal vs Q_vecOriginal
	DoWindow/C IR1R_SizesInputGraph
	IR1R_AppendIntOriginal()	//appends original Intensity 
//	IN2G_AppendSizeTopWave("IR1R_SizesInputGraph",Q_vecOriginal, IntensityOriginal,-25,0,40)		//appends the size wave
//	removed on request of Pete
	ModifyGraph mirror=1
	AppendToGraph BackgroundWave vs Q_vecOriginal
	ModifyGraph/Z margin(top)=80
	ControlBar /T 60
	Button RemovePointR pos={115,5}, size={120,15},font="Times New Roman",fSize=10, title="Remove pnt w/csrA", proc=IR1R_RemovePointWithCursorA
	Button ReturnAllPoints pos={115,25}, size={120,15},font="Times New Roman",fSize=10, title="Return All deleted points", proc=IR1R_ReturnAllDeletedPoints
	Button KillThisWindow pos={5,5}, size={90,15},font="Times New Roman",fSize=10, title="Kill window", proc=IN2G_KillGraphsAndTables
	Button ResetWindow pos={5,25}, size={90,15},font="Times New Roman",fSize=10, title="Reset window", proc=IN2G_ResetGraph
	Button CalculateVolume pos={250,40}, size={100,15},font="Times New Roman",fSize=10, title="Calculate Parameters", proc=IN2R_CalculateVolume, help={"Calculates volume, mean, mode and median of  scatterers between cursors. Set cursors on bar graph."}
	Checkbox LogParticleAxis, pos={250,5}, title="Log Particle size axis?", proc = IR1R_GraphCheckboxes, help={"Check to have logarithmic particle size (top) axis"}
	Checkbox LogParticleAxis, variable=root:Packages:Sizes:GraphLogTopAxis
	Checkbox LogDistVolumeAxis, pos={250,20}, title="Log Particle Volume axis?", proc = IR1R_GraphCheckboxes, help={"Check to have logarithmic particle voilume distribution (right) axis"}
	Checkbox LogDistVolumeAxis, variable=root:Packages:Sizes:GraphLogRightAxis
	ModifyGraph log=1
	Label left "Intensity"
	ModifyGraph lblPos(left)=50
	Label bottom "Q [A\\S-1\\M]"
	ShowInfo
	variable testQRS
	testQRS = root:Packages:Sizes:UseQRSdata
	if(strlen(StringByKey("UserSampleName", note(IntensityOriginal), "="))>1)
		Textbox/N=text0/S=3/A=RT "The sample evaluated is:  "+StringByKey("UserSampleName", note(IntensityOriginal), "=")
	else
		if(testQRS==1)
			Textbox/N=text0/S=3/A=RT "The sample evaluated is:  "+root:Packages:Sizes:IntensityWaveName
		else
			Textbox/K/N=text0
		endif	
	endif
	//and now some controls
//	ControlBar 30
//	Button SaveStyle size={80,20}, pos={50,5},proc=IR1U_StyleButtonCotrol,title="Save Style"
//	Button ApplyStyle size={80,20}, pos={150,5},proc=IR1U_StyleButtonCotrol,title="Apply Style"
	TextBox/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	TextBox/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z07"+DataFolderName+IntensityWaveName	
	DoUpdate

EndMacro


Function IN2R_CalculateVolume(ctrlname) : Buttoncontrol
	string ctrlname
	
	variable startA, startB
	wave MyXWave=root:Packages:Sizes:D_distribution
	Wave MyYWave=root:Packages:Sizes:CurrentResultSizeDistribution
	variable volume
	variable meanDia
	variable modeDia
	variable medianDia
	variable movedCursors=0
	if(!(strlen(CsrWave(A,"IR1R_SizesInputGraph"))>0) || !(strlen(CsrWave(B,"IR1R_SizesInputGraph"))>0) )
		//abort "Cursors not set"
		//user forot to set cursors, let's do all of the stuff
		startA=0
		startB=numpnts(MyXWave)-1
		Cursor  /P /W=IR1R_SizesInputGraph A  CurrentResultSizeDistribution  startA
		Cursor  /P /W=IR1R_SizesInputGraph B  CurrentResultSizeDistribution  startB
		movedCursors=1
	else
		startA=pcsr(A)
		startB=pcsr(B)
	endif		
//	if(cmpstr(CsrWave(A,"IR1R_SizesInputGraph"),"CurrentResultSizeDistribution")!=0 || cmpstr(CsrWave(B,"IR1R_SizesInputGraph"),"CurrentResultSizeDistribution")!=0) 
//		abort "Cursors not set on right waves. Set cursors on Volume distribution (bar graph)"
//	endif		
	
	volume = areaXY(MyXWave,MyYWave, MyXWave[pcsr(A)],MyXWave[pcsr(B)])
	//now calculate meanDia
	Duplicate/O/R=[startA,startB] MyYwave, temp_cumulative, temp_probability, Another_temp
	Duplicate/O/R=[startA,startB] MyXwave, tempXwave
	Another_temp=temp_probability*tempXwave
	MeanDia=areaXY(tempXwave, Another_temp,0,inf)	/ areaXY(tempXwave, temp_probability,0,inf)				//Sum P(D)*D*deltaD/P(D)*deltaD
	//median
	Temp_Cumulative=areaXY(tempXwave, Temp_Probability, tempXwave[0], tempXwave[p] )

	MedianDia = tempXwave[BinarySearchInterp(Temp_Cumulative, 0.5*Temp_Cumulative[numpnts(Temp_Cumulative)-1] )]		//R for which cumulative probability=0.5
	//mode
		FindPeak/P/Q Temp_Probability
		modeDia=tempXwave[V_PeakLoc]								//location of maximum on the P(R)

	
	print "Volume of scatterers between "+num2str(MyXWave[pcsr(A)])+"  and " +num2str(MyXWave[pcsr(B)])+"  A particle diameter is  "+num2str(volume)
	print "Mean diameter between  "+num2str(MyXWave[pcsr(A)])+"  and " +num2str(MyXWave[pcsr(B)])+" is " +num2str(meanDia)
	print "Mode diameter between  "+num2str(MyXWave[pcsr(A)])+"  and " +num2str(MyXWave[pcsr(B)])+" is " +num2str(modeDia)
	print "Median diameter between  "+num2str(MyXWave[pcsr(A)])+"  and " +num2str(MyXWave[pcsr(B)])+" is " +num2str(medianDia)
	string tagText = "Volume of scatterers = "+num2str(volume)+"\r"
	tagText += "Mean diameter = "+num2str(meanDia)+"\r"
	tagText += "Mode diameter = "+num2str(modeDia)+"\r"
	tagText += "Median diameter = "+num2str(medianDia)
	Tag/C/N=Label1/B=1 CurrentResultSizeDistribution, (pcsr(A) + pcsr(B))/2,tagText
	if(movedCursors)
		Cursor  /P /W=IR1R_SizesInputGraph A  IntensityOriginal  startA
		Cursor  /P /W=IR1R_SizesInputGraph B  IntensityOriginal  startB
	endif
	KillWaves temp_cumulative, temp_probability, Another_temp, tempXwave
End


Function IR1R_GraphCheckboxes(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	NVAR GraphLogTopAxis		=root:Packages:Sizes:GraphLogTopAxis
	NVAR GraphLogRightAxis 	=root:Packages:Sizes:GraphLogRightAxis
	if(cmpstr(ctrlName,"LogParticleAxis")==0)
		if (stringmatch(AxisList("IR1R_SizesInputGraph"), "*top*"))		//axis used
			ModifyGraph/W=IR1R_SizesInputGraph log(top)=GraphLogTopAxis
		endif
	endif
	if(cmpstr(ctrlName,"LogDistVolumeAxis")==0)
		if (stringmatch(AxisList("IR1R_SizesInputGraph"), "*right*"))		//axis used
			Wave CurrentResultSizeDistribution=root:Packages:Sizes:CurrentResultSizeDistribution
			WaveStats/Q CurrentResultSizeDistribution
			if(GraphLogRightAxis)		//log scaling
					SetAxis/W=IR1R_SizesInputGraph/N=1 right (V_max*1e-6),V_max*1.1
			else						//lin scailng
				if (V_min>0)
					SetAxis/W=IR1R_SizesInputGraph/N=1 right 0,V_max*1.1 
				else
					SetAxis/W=IR1R_SizesInputGraph/N=1 right -(V_max*0.1),V_max*1.1
				endif
			endif
			ModifyGraph/W=IR1R_SizesInputGraph log(right)=GraphLogRightAxis
		endif

	endif

end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1R_AppendIntOriginal()		//appends (and removes) and configures in graph IntOriginal vs Qvec Original
	
	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes
	
	Wave IntensityOriginal=root:Packages:Sizes:IntensityOriginal
	Wave Q_vecOriginal=root:Packages:Sizes:Q_vecOriginal
	Wave DeletePointsMaskErrorWave=root:Packages:Sizes:DeletePointsMaskErrorWave
	variable csrApos
	variable csrBpos
	
	if (strlen(csrWave(A))!=0)
		csrApos=pcsr(A)
	else
		csrApos=0
	endif	
		
	 
	if (strlen(csrWave(B))!=0)
		csrBpos=pcsr(B)
	else
		csrBpos=numpnts(IntensityOriginal)-1
	endif	

	RemoveFromGraph/Z IntensityOriginal
	AppendToGraph IntensityOriginal vs Q_vecOriginal
	
	Label left "Intensity"
	ModifyGraph lblPos(left)=50
	Label bottom "Q [A\\S-1\\M]"

	ModifyGraph mode(IntensityOriginal)=3
	ModifyGraph msize(IntensityOriginal)=2
	ModifyGraph rgb(IntensityOriginal)=(0,52224,0)
	ModifyGraph zmrkNum(IntensityOriginal)={DeletePointsMaskWave}
	ErrorBars IntensityOriginal Y,wave=(DeletePointsMaskErrorWave,DeletePointsMaskErrorWave)
	Cursor/P A IntensityOriginal, csrApos
	Cursor/P B IntensityOriginal, csrBpos
	
	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1R_RemovePointWithCursorA(ctrlname) : Buttoncontrol			// Removes point in wave
	string ctrlname

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes
	
	Wave DeletePointsMaskWave=root:Packages:Sizes:DeletePointsMaskWave
	Wave DeletePointsMaskErrorWave=root:Packages:Sizes:DeletePointsMaskErrorWave
	
	DeletePointsMaskWave[pcsr(A)]=NaN
	DeletePointsMaskErrorWave[pcsr(A)]=NaN
	
	IR1R_AppendIntOriginal()	

	setDataFolder OldDf
End


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1R_ReturnAllDeletedPoints(ctrlname) : Buttoncontrol			// Removes point in wave
	string ctrlname

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes
	
	Wave DeletePointsMaskWave=root:Packages:Sizes:DeletePointsMaskWave
	Wave DeletePointsMaskErrorWave=root:Packages:Sizes:DeletePointsMaskErrorWave
	Wave ErrorsOriginal=root:Packages:Sizes:ErrorsOriginal
	
	DeletePointsMaskErrorWave=ErrorsOriginal
	DeletePointsMaskWave=7

	IR1R_AppendIntOriginal()	

	setDataFolder OldDf
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1R_BackgroundInput(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes
	DOWIndow/F IR1R_SizesInputPanel
	IR1G_UpdateSetVarStep("Background",0.1)

	Wave Q_vec=root:Packages:Sizes:Q_vec
	Duplicate/O Q_vecOriginal BackgroundWave
	BackgroundWave=varNum
	CheckDisplayed BackgroundWave 
	if (!V_Flag)
		AppendToGraph BackgroundWave vs Q_vecOriginal
	endif

	DoWIndow/F IR1R_SizesInputPanel
	setDataFolder OldDf
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//Function IR1R_SelectShapeModel(ctrlName,popNum,popStr) : PopupMenuControl
//	String ctrlName
//	Variable popNum
//	String popStr
//
//	string OldDf
//	OldDf=GetDataFolder(1)
//	setDataFolder root:Packages:Sizes
//
//	SVAR ShapeType=root:Packages:Sizes:ShapeType
//	ShapeType=popStr
//	
//	setDataFolder OldDf
//End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//Function IR1R_restart(ctrlName) : ButtonControl
//	String ctrlName
//	
//	IN2G_KillAllGraphsAndTables("yes")		//kills the graph and panel
//	
//	IR1R_Sizes()						//restarts the procredure
//End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1R_saveData(ctrlName) : ButtonControl
	String ctrlName

	
	if(stringmatch(ctrlName,"copyDataToNbk"))
		IR1R_SaveResultsToNotebook()
	else
		IR1R_ReturnFitBack(ctrlName)		//and this returns the data to original folder
		IR1R_RecordResults()
	endif
	DoWIndow/F IR1R_SizesInputPanel
End

//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR1R_RecordResults()

	string OldDF=GetDataFolder(1)
	setdataFolder root:Packages:Sizes

	SVAR DataFolderName=root:Packages:Sizes:DataFolderName
	SVAR OriginalIntensityWvName=root:Packages:Sizes:IntensityWaveName
	SVAR OriginalQvectorWvName=root:Packages:Sizes:QWaveName
	SVAR OriginalErrorWvName=root:Packages:Sizes:ErrorWaveName
	SVAR SizesParameters=root:Packages:Sizes:SizesParameters
	SVAR LogDist=root:Packages:Sizes:LogDist
	SVAR ShapeType=root:Packages:Sizes:ShapeType
	SVAR SlitSmearedData=root:Packages:Sizes:SlitSmearedData
	SVAR MethodRun=root:Packages:Sizes:MethodRun
	
	
	IR1_CreateLoggbook()		//this creates the logbook
	SVAR nbl=root:Packages:SAS_Modeling:NotebookName

	IR1L_AppendAnyText("     ")
	IR1L_AppendAnyText("***********************************************")
	IR1L_AppendAnyText("***********************************************")
	IR1L_AppendAnyText("Sizes fitting record ")
	IR1_InsertDateAndTime(nbl)
	IR1L_AppendAnyText("Input data names \t")
	IR1L_AppendAnyText("\t\tFolder \t\t"+ DataFolderName)
	IR1L_AppendAnyText("\t\tIntensity/Q/errror wave names \t"+ OriginalIntensityWvName+"\t"+OriginalQvectorWvName+"\t"+OriginalErrorWvName)
	variable i
	For(i=0;i<ItemsInList(SizesParameters , ";");i+=1)
		IR1L_AppendAnyText("\t\t"+StringFromList(i, SizesParameters, ";"))
	endfor
	IR1L_AppendAnyText(" ")
	

	IR1L_AppendAnyText("***********************************************")

	setdataFolder oldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static  Function IR1R_ShrinkGMatrixAfterSmearing()		//this shrinks the G_matrix and Q_vec back
												//Errors are used to get originasl length

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes

	Wave G_matrix=root:Packages:Sizes:G_matrix
	Wave Q_vec=root:Packages:Sizes:Q_vec
	Wave Errors=root:Packages:Sizes:Errors
	
	variable OldLength=numpnts(Errors)				//this is old number of points (Erros length did not change during smearing)
	
	redimension/N=(OldLength) Q_vec				//this shrinks the Q_veck to old length
	
	redimension/N=(OldLength,-1) G_matrix			//this shrinks the G_matrix to original number of rows, columns stay same

	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static  Function IR1R_SmearGMatrix()			//this function smears the colums in the G matrix

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes

	Wave G_matrix=root:Packages:Sizes:G_matrix
	Wave Q_vec=root:Packages:Sizes:Q_vec
	NVAR SlitLength=root:Packages:Sizes:SlitLength

	variable M=DimSize(G_matrix, 0)							//rows, i.e, measured points 
	variable N=DimSize(G_matrix, 1)							//columns, i.e., bins in radius distribution
	variable i=0
	Make/D/O/N=(M) tempOrg, tempSmeared									//points = measured Q points

	for (i=0;i<N;i+=1)					//for each column (radius point)
		tempOrg=G_matrix[p][i]			//column -> temp
		
		IR1R_SmearData(tempOrg, Q_vec, slitLength, tempSmeared)			//temp is smeared (Q_vec, SlitLength) ->  tempSmeared
	
		G_matrix[][i]=tempSmeared[p]		//column in G is set to smeared value
	endfor

//	G_matrix*=SlitLength*1e-4				//try to fix calibration
	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


//*****************************This function smears data***********************
static  Function IR1R_SmearData(Int_to_smear, Q_vec_sm, slitLength, Smeared_int)
	wave Int_to_smear, Q_vec_sm, Smeared_int
	variable slitLength

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes
	
	Make/D/O/N=(0.5*numpnts(Q_vec_sm)) Smear_Q, Smear_Int							
		//Q's in L spacing and intensitites in the l's will go to Smear_Int (intensity distribution in the slit, changes for each point)

	variable DataLengths=numpnts(Q_vec_sm)
	
	Smear_Q=1.1*slitLength*(Q_vec_sm[2*p]-Q_vec_sm[0])/(Q_vec_sm[DataLengths-1]-Q_vec_sm[0])		//create distribution of points in the l's which mimics the aroginal distribution of pointsd
	//the 1.1* added later, because without it I di dno  cover the whole slit length range... 
	variable i=0
	
	For(i=0;i<DataLengths;i+=1) 
		Smear_Int=interp(sqrt((Q_vec_sm[i])^2+(Smear_Q[p])^2), Q_vec_sm, Int_to_smear)		//put the distribution of intensities in the slit for each point 
		Smeared_int[i]=areaXY(Smear_Q, Smear_Int, 0, slitLength) 							//integrate the intensity over the slit 
	endfor

	Smeared_int*= 1 / slitLength															//normalize
	
	KillWaves Smear_Int, Smear_Q														//cleanup temp waves
	setDataFolder OldDf

	setDataFolder OldDf
end
//**************End common******************************


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static  Function IR1R_ExtendQVecForSmearing()		//this is function extends the Q vector for smearing

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes

	Wave Q_vec=root:Packages:Sizes:Q_vec
	NVAR SlitLength=root:Packages:Sizes:SlitLength

	variable OldPnts=numpnts(Q_vec)
	variable qmax=Q_vec[OldPnts-1]
	variable newNumPnts=0
	
	Duplicate/O Q_vec, TempWv	
	Redimension/D TempWv
	TempWv=log(Q_vec)

	if (qmax<SlitLength)
		NewNumPnts=numpnts(Q_vec)
	else
		NewNumPnts=numpnts(Q_vec)-BinarySearch(Q_vec, (Q_vec[OldPnts-1]-SlitLength) )
	endif
	
	if (NewNumPnts<10)
		NewNumPnts=10
	endif
	
	Make/O/D/N=(NewNumPnts) Extension
	Extension=Q_vec[OldPnts-1]+p*(SlitLength/NewNumPnts)
	Redimension /N=(OldPnts+NewNumPnts) Q_vec
	Q_vec[OldPnts, OldPnts+NewNumPnts-1]=Extension[p-OldPnts]
	
	KillWaves TempWv, Extension

	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static  Function IR1R_MeanOfDistribution(VolDist,Dia)
	Wave VolDist, Dia
	variable result=0, i, imax=numpnts(VolDist), VolTotal=0
	
	if (numpnts(VolDist)!=numpnts(Dia))
		Abort "Error in IR1R_MeanOfDistribution, the waves do not have the length"
	endif
	
	for(i=0;i<imax;i+=1)					// initialize variables;continue test
		if (VolDist[i]>=0)
			result+=VolDist[i]*Dia[i]
			VolTotal+=VolDist[i]
		endif
	endfor								// execute body code until continue test is false
 
 	result = result/VolTotal
	
	return result

end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//		Diagnostic functions

static  Function IR1R_SetupDiagnostics()
	
	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes

	NVAR Diagnostics=root:Packages:Sizes:ShowDiagnostics
	
	DoWindow IR1S_RegDiagnosticsWindow
	if (V_Flag)
		DoWindow/K IR1S_RegDiagnosticsWindow
	endif	
	
	if (Diagnostics)
		//here we need to setup the waves and graphs as needed
	//	Make/O/N=0 DiagLogAVal, DiagLogChisquareDivN, DiagSmoothness
		
		execute ("IR1S_RegDiagnosticsWindow()")
		
	endif
	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static  Function IR1R_DisplayDiagnostics(CurrentEntropy,CurrentChiSq, CurChiSqMinusAlphaEntropy,currentIteration)
	variable CurrentEntropy,CurrentChiSq, CurChiSqMinusAlphaEntropy, currentIteration


	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes

	NVAR TicksForDiagnostics=root:Packages:Sizes:TicksForDiagnostics
	NVAR Diagnostics=root:Packages:Sizes:ShowDiagnostics

	variable TimeFromLastUpdate=(ticks-TicksForDiagnostics)/60		//this is in seconds time from last update
	if (Diagnostics)
		//here we need to update the waves for graphs
		Wave CurrentEntropyW=root:Packages:Sizes:CurrentEntropyW
		Wave CurrentChiSqW=root:Packages:Sizes:CurrentChiSqW
		Wave CurChiSqMinusAlphaEntropyW=root:Packages:Sizes:CurChiSqMinusAlphaEntropyW
		Redimension/N=(currentIteration+1) CurrentEntropyW, CurrentChiSqW, CurChiSqMinusAlphaEntropyW
		CurrentEntropyW[currentIteration]=CurrentEntropy
		CurrentChiSqW[currentIteration]=CurrentChiSq
		CurChiSqMinusAlphaEntropyW[currentIteration]=CurChiSqMinusAlphaEntropy
		DoUpdate
		if(TimeFromLastUpdate<1)
			sleep /S 1
		endif
		CurrentEntropyW[0]=NaN
		CurrentChiSqW[0]=NaN
		CurChiSqMinusAlphaEntropyW[0]=NaN
	endif
	TicksForDiagnostics=ticks
	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Proc  IR1S_RegDiagnosticsWindow() 
	PauseUpdate; Silent 1		// building window...
	String fldrSav= GetDataFolder(1)
	SetDataFolder root:Packages:Sizes:
	Display /K=1/W=(10,250,350,450) CurrentEntropyW as "Diagnostic of the Sizes"
	DoWIndow/C IR1S_RegDiagnosticsWindow
	AppendToGraph /R CurrentChiSqW //vs DiagLogAVal
	AppendToGraph/L=ChiMinAlphaS CurChiSqMinusAlphaEntropyW
	SetDataFolder fldrSav
	Label left "Entropy or Smoothness"
	Label bottom "Iteration"
	Label right "Current ChiSquared"
	Label ChiMinAlphaS "Current ChiSq - alpha*S"
	ModifyGraph mirror(bottom)=1, log(right)=1
	ModifyGraph mode=4,marker(CurrentEntropyW)=19
	ModifyGraph marker(CurrentChiSqW)=5,rgb(CurrentChiSqW)=(0,0,65280)
	ModifyGraph marker(CurChiSqMinusAlphaEntropyW)=15,rgb(CurChiSqMinusAlphaEntropyW)=(0,52224,0)
	ModifyGraph lblPos(left)=0
	ModifyGraph lblLatPos(right)=2
	ModifyGraph lblMargin(right)=25
//	Legend/C/N=text0/J/A=RT "\\s(DiagLogChisquareDivN) Log Chi^2\r\\s(DiagSmoothness) Smoothness"
	Legend/C/N=text1/J/A=RB/F=0/B=1 "\\s(CurrentEntropyW) Entropy or smoothness\r\\s(CurrentChiSqW) Chi^2\r\\s(CurChiSqMinusAlphaEntropyW) Ch^2 - alpha * S"
EndMacro

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//*****************************************************************************************************************************
//*****************************************************************************************************************************
//*****************************************************************************************************************************
//*****************************************************************************************************************************


static  Function IR1R_MaximumEntropy(MeasuredData,Errors,InitialModelBckg,MaxIterations,Model,MaxEntStabilityParam,OpusFnct,TropusFnct,UpdateGraph)
	wave MeasuredData,Errors,InitialModelBckg,Model
	variable MaxIterations,MaxEntStabilityParam
	FuncRef IR1R_ModelOpus OpusFnct		//converts the Model to MeasuredData
	FuncRef IR1R_ModelOpus TropusFnct	//converts the MeasuredData into Model
	FuncRef IR1R_UpdateDataForGrph UpdateGraph	//converts the MeasuredData into Model

	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes
	variable npnts=numpnts(MeasuredData)			//number of measure points
	variable nbins=numpnts(Model)					//number of bins in model
	
	WAVE flWv=root:Packages:Sizes:flWv
	WAVE blWv=root:Packages:Sizes:blWv
	flWv=0
	blWv=0

	NVAR chtarg=root:Packages:Sizes:chitarg
	NVAR chizer=root:Packages:Sizes:chizer
	NVAR fSum=root:Packages:Sizes:fSum
	NVAR blank=root:Packages:Sizes:blank
	NVAR CurrentEntropy=root:Packages:Sizes:CurrentEntropy
	NVAR CurrentChiSq=root:Packages:Sizes:CurrentChiSq
	NVAR CurChiSqMinusAlphaEntropy=root:Packages:Sizes:CurChiSqMinusAlphaEntropy
	fSum=0
	variable tolerance=MaxEntStabilityParam*sqrt(2*npnts) //for convergnence in Chisquare
	variable tstLim=0.05		//for convergence for entropy terms

	NVAR Chisquare=root:Packages:Sizes:Chisquare
	Chisquare=0
	chizer = npnts		//setup some starting conditions
	chtarg = chizer 
	variable iter=0, snorm=0, cnorm=0,tnorm=0, a=0, b=0 , test=0, i=0, j=0, l=0, fchange=0, df=0, sEntropy=0, k=0
	duplicate/O MeasuredData, ox, ascratch, bscratch, etaScratch	, zscratch, zscratch2		//create work waves with measured Points length
	duplicate/O Model, cgrad,sgrad, ModelScratch, ModelScratch2, xiScratch		//create work waves with bins length
	make/O/D/N=(numpnts(Model),3) xi
	make/O/D/N=(numpnts(MeasuredData),3) eta
	Make/O/D/N=3  c1,s1, betaMX
	Make/O/D/N=(3,3) c2, s2
	
	
	For(iter=0;iter<MaxIterations;iter+=1)		//this is the main loop which does the searching for solution
	
		OpusFnct(Model,ox)						//calculate ox model result from Model
		DoUpdate
		Chisquare=0
		ascratch = (ox - MeasuredData) / Errors
		ox = 2 * ascratch / Errors
		ascratch=ascratch^2
		Chisquare = sum(ascratch)
		TropusFnct(ox,cgrad)
		snorm=0
		cnorm=0
		tnorm=0
		test=0
		fSum=sum(Model)
		sgrad = -ln(Model/InitialModelBckg) / (InitialModelBckg * e)
		ModelScratch = Model * sgrad^2
		snorm = sum(ModelScratch)
		ModelScratch = Model * cgrad^2
		cnorm = sum(ModelScratch)
		ModelScratch = Model * sgrad * cgrad
		tnorm = sum(ModelScratch)
		
		snorm = sqrt(snorm)
		cnorm = sqrt(cnorm)
		a = 1
		b = 1/cnorm
		if (iter>0)
			test = sqrt(0.5*(1-tnorm/(snorm*cnorm)))
			a = 0.5 / (snorm * test)
			b = 0.5 * b / test
		endif
		xi[][0] = Model[p] * cgrad[p] / cnorm
		xi[][1] = Model[p] * (a * sgrad[p] - b * cgrad[p])

		xiscratch=xi[p][0]
		OpusFnct(xiscratch, etaScratch)
		eta[][0] = etaScratch[p]
		
		xiscratch=xi[p][1]
		OpusFnct(xiscratch, etaScratch)
		eta[][1] = etaScratch[p]
		
		ox = eta[p][1] / (Errors[p])^2
		
		TropusFnct(ox,xiscratch)
		xi[][2] = xiScratch[p]
		
		ModelScratch=Model[p] * xi[p][2]
		ModelScratch2=ModelScratch[p] * xi[p][2]
		a = sum(ModelScratch2)
		xi[][2] = ModelScratch[p]
		
		a= 1/sqrt(a)
		xi[][2] = a * xi[p][2]
		xiscratch=xi[p][2]
		OpusFnct(xiscratch,etascratch)
		eta[][2]=etascratch[p]
		
		For(i=0;i<3;i+=1)
			xiScratch=xi[p][i] * sgrad[p]
			s1[i]=sum(xiScratch)
			xiScratch=xi[p][i] * cgrad[p]
			c1[i]=sum(xiScratch)
		endfor
		c1=c1/Chisquare
		
		s2=0
		c2=0
		For(k=0;k<3;k+=1)
			For(l=0;l<=k;l+=1)
				For(i=0;i<nBins;i+=1)
					s2[k][l] = s2[k][l] - xi[i][k] * xi[i][l] / Model[i]
				endfor	
				For(j=0;j<nPnts;j+=1)
					c2[k][l] = c2[k][l] + eta[j][k] * eta[j][l] / ((Errors[j])^2)
				endfor	
			endfor
		endfor	
		s2 = s2 / InitialModelBckg
		c2 = 2 * c2 /Chisquare
		
        	c2[0][1] = c2[1][0]
        	c2[0][2] = c2[2][0]
        	c2[1][2] = c2[2][1]
        	s2[0][1] = s2[1][0]
        	s2[0][2] = s2[2][0]
        	s2[1][2] = s2[2][1]
        	betaMX[0] = -0.5 * c1[0] / c2[0][0]
        	betaMX[1] = 0
		betaMX[2] = 0
		if(iter>0)
			IR1R_Move(3)
		endif
		//  Modify the current distribution (f-vector)
        	fSum = 0              // find the sum of the f-vector
        	fChange = 0          // and how much did it change?
        	For(i = 0;i<nBins;i+=1)
	          	df = betaMX[0]*xi[i][0]+betaMX[1]*xi[i][1]+betaMX[2]*xi[i][2]
      	    		IF (df < (-Model[i])) 
      	    			df = 0.001 * InitialModelBckg[i] - Model[i]       // a patch
          		endif
          		Model[i] = Model[i] + df              // adjust the f-vector
          		fSum = fSum + Model[i]
          		fChange = fChange + df
        	endfor
			
		ModelScratch= Model/fSum		//fraction of Model(i) in this bin
		ModelScratch=ModelScratch * ln(ModelScratch)		
		sEntropy=-sum(ModelScratch)		// from Skilling and Brian eq. 1
		
		OpusFnct(Model,zscratch)
		zscratch = ( MeasuredData[p] - zscratch[p]) / Errors[p]	//residuals
		zscratch2 = zscratch^2
		Chisquare = sum(zscratch2)			//new Chisquared
		
		CurrentEntropy=sEntropy
		CurrentChiSq=Chisquare
		CurChiSqMinusAlphaEntropy=Chisquare - MaxEntStabilityParam*sEntropy
		IR1R_DisplayDiagnostics(CurrentEntropy,CurrentChiSq, CurChiSqMinusAlphaEntropy,iter)		//display data in diagnostic graphs, if needed
		//see, if we have reached solution
		OpusFnct(Model,ox)	
		UpdateGraph()
		if(abs(Chisquare - chizer) < tolerance)
			if(test<tstLim)	//same solution limit
			//solution found
				KillWaves/Z ascratch, bscratch, etaScratch	//cleanup
				KillWaves/Z  cgrad,sgrad, ModelScratch, ModelScratch2, xiScratch		//cleanup
				KillWaves/Z  xi, eta, c1,s1, betaMX, c2, s2
				setDataFolder OldDf
				return iter
			endif
		endif
		
	endfor
	KillWaves/Z ascratch, bscratch, etaScratch		//cleanup
	KillWaves/Z  cgrad,sgrad, ModelScratch, ModelScratch2, xiScratch		//cleanup
	KillWaves/Z  xi, eta, c1,s1, betaMX, c2, s2
	setDataFolder OldDf
	return NaN
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


static  Function IR1R_Move(m)
	variable m

	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes

	variable MxLoop=500				//for no solution	
	variable Passes=0.001			//convergence test
	NVAR Chisquare=root:Packages:Sizes:Chisquare
	NVAR chtarg=root:Packages:Sizes:chitarg
	NVAR chizer=root:Packages:Sizes:chizer
	NVAR fSum=root:Packages:Sizes:fSum
	NVAR blank=root:Packages:Sizes:blank
	Wave betaMX=root:Packages:Sizes:betaMX
	Wave c1=root:Packages:Sizes:c1
	Wave c2=root:Packages:Sizes:c2
	Wave s1=root:Packages:Sizes:s1
	Wave s2=root:Packages:Sizes:s2
 	
 	//debug stuff
// 	make/O/N=1000 testChiNow
//	setscale/I x,0,1,"", testChiNow 
//	
		variable a1 = 0                       // lower bracket  "a"
		variable a2 = 1                       // upper bracket of "a"
		variable cmin = IR1R_ChiNow (a1, m)		//get current chi
		variable ctarg
		IF ((cmin*Chisquare)>chizer) 
			ctarg = 0.5*(1 + cmin)
		endif
		IF ((cmin*Chisquare) <= chizer) 
			ctarg = chizer/Chisquare
		endif
		variable f1 = cmin - ctarg
		variable f2 = IR1R_ChiNow (a2,m) - ctarg
		variable i, anew, fx
//	testChiNow=IR1R_ChiNow (x,m) - ctarg
//	display testChiNow
////	abort
//print f1
//print a1
//print f2
//print a2
//print ""
		For (i=0;i<MxLoop;i+=1)
			anew = 0.5 * (a1+a2)          //! choose a new "a"
			fx = IR1R_ChiNow (anew,m) - ctarg
			//Ok, sometimes apparently the halving method does not work properly, since there is minimum between the 0 and 1
			//let's first check for that
//			if (((f1>0 && fx>0) || (f1<0 && fx<0)) && (abs(fx)>abs(f1)))	//both f1 and fx larger or smaller than 0
//				a1 = anew
//				f1 = fx
//			elseif(((f2>0 && fx>0) || (f2<0 && fx<0))&&(abs(fx)>abs(f2)))		//again, both f2 and fx are smaller or large than 0, and error condition
//				a2 = anew
//				f2 = fx			
//			else	
				IF (f1*fx >0) 
					a1 = anew
					f1 = fx
				endif
				IF (f2*fx > 0)
					a2 = anew
					f2 = fx
				endif
//			endif
			IF (abs(fx) < Passes) 
				break
			endif
		endfor
//C  If the preceding loop finishes, then we do not seem to be converging.
//C       Stop gracefully 
		if (i>=MxLoop-1)
			Abort "	No convergence in alpha chop (MOVE). Loop counter = "+num2str(MxLoop)
		endif
		variable w = IR1R_Dist (m)
		variable k
		IF (w > 0.1*fSum/blank)
			For(k=0;k<m;k+=1)
				betaMX[k] = betaMX[k] * SQRT(0.1 * fSum/(blank * w))
			endfor
		ENDIF
		chtarg = ctarg * Chisquare
		setDataFolder OldDf
		RETURN 0
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


  Function IR1R_Opus(Model, MeasuredData)			//Model to MeasuredDataSpace
	wave MeasuredData,Model

	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes

	//Wave G_matrix=root:Packages:Sizes:G_matrix
	Wave G_matrixQ2N=root:Packages:Sizes:G_matrixQ2N

	MatrixOp/O resultMO =G_matrixQ2N x Model 
	MeasuredData = resultMO //* 10^6
	Killwaves resultMO
	setDataFolder OldDf
end

 
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1R_UpdateDataForGrph()

	//This function is run to update data for graphing purposes
	Abort "There is nothing here in IR1R_UpdateDataForGraph"
	
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


  Function IR1R_TrOpus(MeasuredData,Model)			//MeasuredDataSpace to Model
	wave MeasuredData,Model

	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes

//	Wave G_matrix=root:Packages:Sizes:G_matrix
	Wave G_matrixQ2N=root:Packages:Sizes:G_matrixQ2N
	
	//MatrixOp/O  resultMO=G_matrixQ2N^t x MeasuredData 
	MatrixOp/O  resultMO=G_matrixQ2N^h x MeasuredData 			//changed to ^h (Hermitian transpose) 5/9/08 JIL
	Model = resultMO
	KillWaves resultMO
	setDataFolder OldDf
end

Function IR1R_ModelOpus(MeasuredData,Model)
	wave MeasuredData,Model
	
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************



static  Function IR1R_Dist(m)
		variable m

	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes

	NVAR Chisquare=root:Packages:Sizes:Chisquare
	NVAR chtarg=root:Packages:Sizes:chitarg
	NVAR chizer=root:Packages:Sizes:chizer
	NVAR fSum=root:Packages:Sizes:fSum
	NVAR blank=root:Packages:Sizes:blank
	Wave betaMX=root:Packages:Sizes:betaMX
	Wave c1=root:Packages:Sizes:c1
	Wave c2=root:Packages:Sizes:c2
	Wave s1=root:Packages:Sizes:s1
	Wave s2=root:Packages:Sizes:s2

	variable w = 0
	variable k, l, z
		For(k=0;k<m;k+=1)
			z = 0
			For(l=0;l<m;l+=1)
				z = z - s2[k][l] * betaMX[l]
			endfor
			w = w + betaMX[k] * z
		endfor
		variable Dist = w
	setDataFolder OldDf
	RETURN Dist
END
//
//
//


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************





static  Function IR1R_ChiNow(ax,m)
	variable ax,m

	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes

	NVAR Chisquare=root:Packages:Sizes:Chisquare
	NVAR chtarg=root:Packages:Sizes:chitarg
	NVAR chizer=root:Packages:Sizes:chizer
	NVAR fSum=root:Packages:Sizes:fSum
	NVAR blank=root:Packages:Sizes:blank
	Wave betaMX=root:Packages:Sizes:betaMX
	Wave c1=root:Packages:Sizes:c1
	Wave c2=root:Packages:Sizes:c2
	Wave s1=root:Packages:Sizes:s1
	Wave s2=root:Packages:Sizes:s2

	Make/D/O/N=(3,3) aWv
	aWv=0
	Make/D/O/N=3 bWv
	bWv=0
		variable bx = 1 - ax
		variable k, l, w, z
		
	for(k=0;k<m;k+=1)
		For(l=0;l<m;l+=1)
			aWv[k][l] = bx * c2[k][l]  -  ax * s2[k][l]
		endfor
		 bWv[k] = -(bx * c1[k]  -  ax * s1[k])
	endfor
	IR1R_ChoSol(aWv,bWv,m,betaMX)
        w = 0
		for(k=0;k<m;k+=1)
			z = 0
			for(l=0;l<m;l+=1)
				z = z + c2[k][l] * betaMX[l]
			endfor
			 w = w + betaMX[k] * (c1[k] + 0.5 * z)
		endfor
		variable ChiNow = 1 +  w
		setDataFolder OldDf
	RETURN ChiNow
END

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


static  Function IR1R_ChoSol(a, b, m, betaMX)
	wave a, b, betaMX
	variable m

	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes
	WAVE flWv=root:Packages:Sizes:flWv
	WAVE blWv=root:Packages:Sizes:blWv
//	flWv=0
//	blWv=0

		IF (a[0][0] <= 0) 
			Abort  "Fatal error in CHOSOL: a(0,0) = "+num2str(a[0][0])
		ENDIF
		flWv[0][0] = SQRT(a[0][0])
		variable i, j, z, k,i1
		For (i =1;i<m;i+=1)
			flWv[i][0] = a[i][0] / flWv[0][0]
			For (j = 1;j<=i;j+=1)
				z = 0
				For (k = 0;k<=(j-1);k+=1)
					z = z + flWv[i][k] * flWv[j][k]
				endfor
				z = a[i][j] - z
				if (j==i)
					flWv[i][j] = SQRT(z)
				else
					flWv[i][j] = z / flWv[j][j]
				endif
			endfor
		endfor
		blWv[0] = b[0] / flWv[0][0]
		For(i=1;i<m;i+=1)
			z = 0
			For ( k = 0;k<=i-1;k+=1)
				z = z + flWv[i][k] * blWv[k]
			endfor
			blWv[i] = (b[i] - z) / flWv[i][i]
		endfor
		betaMX[m-1] = blWv[m-1] / flWv[m-1][m-1]
		For (i1=0;i1<m-1;i1+=1)
			i = m-2 - i1
			z = 0
				For (k = i+1;k<m;k+=1)
					z = z + flWv[k][i] * betaMX[k]
				endfor
			betaMX[i] = (blWv[i] - z) / flWv[i][i]
		endfor
		setDataFolder OldDf
		RETURN 0
END
//
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

static Function IR1R_DoNNLS()
	
	Wave Intensity=root:Packages:Sizes:Intensity
	Wave Q_vec=root:Packages:Sizes:Q_vec
	Wave Errors=root:Packages:Sizes:Errors
	Wave R_distribution=root:Packages:Sizes:R_distribution
	Wave ModelDistribution=root:Packages:Sizes:ModelDistribution
	Wave InitialModelBckg=root:Packages:Sizes:InitialModelBckg
	Wave NormalizedResidual=root:Packages:Sizes:NormalizedResidual
	Wave G_matrix=root:Packages:Sizes:G_matrix
	Duplicate/O Intensity, root:Packages:Sizes:SIzesFitIntensity
	Duplicate/O ModelDistribution, root:Packages:Sizes:CurrentResultSizeDistribution
	Duplicate/O intensity, ModelIntensity
	CheckDisplayed /W=IR1R_SizesInputGraph ModelIntensity
	if(!V_Flag)
		appendToGraph /W=IR1R_SizesInputGraph ModelIntensity vs Q_vec
	endif
	NVAR SizesPowerToUse=root:Packages:Sizes:SizesPowerToUse
	variable LocalPower
	NVAR UseNoErrors=root:Packages:Sizes:UseNoErrors
	if(UseNoErrors)	//use power scaling ONLy if no errors are used... 
		LocalPower=SizesPowerToUse
	else
		LocalPower=0
	endif
	IR1R_TNNLS(G_matrix,ModelDistribution,Intensity, Q_vec, errors, LocalPower)
//	TNNLS(G_matrix,ModelDistribution, R_distribution,Intensity, Q_vec, errors, 0.8, 100)
	IR1R_NNLSUpdateDataForGrph()
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

 Function IR1R_NNLSUpdateDataForGrph()

	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Sizes
	//copy data to update graph
	Wave/Z CurrentResultSizeDistribution = root:Packages:Sizes:CurrentResultSizeDistribution
//	Wave ModelDistribution=root:Packages:Sizes:ModelDistribution
	Wave NormalizedResidual=root:Packages:Sizes:NormalizedResidual
	Wave Intensity=root:Packages:Sizes:Intensity
	Wave Errors=root:Packages:Sizes:Errors

//	Duplicate/O ModelDistribution, CurrentResultSizeDistribution
	Wave SizesFitIntensity=root:Packages:Sizes:SizesFitIntensity
	NormalizedResidual = (Intensity - SizesFitIntensity)/Errors

	NVAR Chisquare=root:Packages:Sizes:Chisquare
	
	IR1R_FinishGraph()
	DoUpdate
	setDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

static Function IR1R_TNNLS(G_matrix,ModelDistribution,Intensity, Qvector, errors, Power)
	wave G_matrix,ModelDistribution,Intensity, Qvector, errors
	variable Power
	// Amatrix,Xwave,BVector, Uncertainities
	//Amatrix is n x m matrix relating Xvector (model data) to BVector(measured data)
	 
	 string OldDf=GetDataFolder(1)
	 NewDataFolder/O/S root:Packages
	 NewDataFolder/O/S root:Packages:NNLS
 	Duplicate/O G_matrix, G_matrixE, AmatrixOrig
	Duplicate/O Intensity, IntensityE
	 variable useerrors=1
	 if(useerrors)
	 	G_matrixE = G_matrix[p][q] / errors[p]
	 	MatrixOp/O IntensityE = Intensity / errors
	 endif
	Duplicate/O G_matrixE, Amatrix
	Duplicate/O ModelDistribution, Xwave
	Duplicate/O IntensityE, BVector, BvectorOrig
	Duplicate/O errors, Uncertainities
	NVAR NNLS_MaxNumIterations=root:Packages:Sizes:NNLS_MaxNumIterations
	NVAR NNLS_ApproachParameter=root:Packages:Sizes:NNLS_ApproachParameter
	//first we will need some variables, strings etc to work with
	variable i,j
	//we will need this multiple times
	Duplicate/O Qvector, QvectorP
	QvectorP = Qvector^Power
	Amatrix[][] = G_matrixE[p][q] * QvectorP[p]
	MatrixOp/O AmatrixT=Amatrix^t
	MatrixOp/O BVector = BvectorOrig * QvectorP
	//starting conditions
	redimension/D Xwave
	Xwave = 1e-32
	//working waves & variables
//	make/O/D/N=(Numpnts(Xwave)) Qk, Pk, Dk, AkSTAR

	variable numIter=0
	//variable tau = 0.9
	variable lasterr=1e3
	variable err=0	
	variable alphaStar, temp1, temp2
	string LegendText2
	//here the iterations start...
	print "    "
	Do
	//start of NNLS Interior point gradient method itself
	//step 1
		MatrixOp/O Qk = AmatrixT x Amatrix x Xwave - AmatrixT x BVector
		MatrixOp/O Dk = Xwave / (AmatrixT x Amatrix x Xwave)
		MatrixOp/O Pk = - Dk * Qk	
	//step 2	
		MatrixOp/O AkSTAR= (pk^t x AmatrixT x Amatrix x Pk)
		temp1 = AkSTAR[0]
		MatrixOp/O AkSTAR= - (pk^t x Qk) 
		temp2 = AkSTAR[0]
		alphaStar = temp2 / temp1
		redimension/N=(numpnts(Xwave)) AkSTAR
		AkSTAR = alphaStar
		//above is ideal step to make//below is limiting the step so we do not get negative values...		
		MatrixOP/O AlphaWv =  - Xwave/Pk		//this is maximum alpha, which we canmake, if pk is negative
		For(i=0;i<numpnts(PK);i+=1)
			if(Pk[i]<0)		//if pk is negative, we may have to limit the step
				AkSTAR[i]=min(NNLS_ApproachParameter*AlphaWv[i],AkSTAR[i])		//the step is limited to smaller from the two values
			endif
		endfor
	//step 3
		MatrixOp/O Xwave = Xwave +(AkSTAR * Pk ) 	//new model, go back after some calculations below
	//end of NNLS Interior point gradient method itself	
	//end of 
		Wave SizesFitIntensity=root:Packages:Sizes:SizesFitIntensity
		Wave CurrentResultsSizeDistribution=root:Packages:Sizes:CurrentResultSizeDistribution
		CurrentResultsSizeDistribution=Xwave[p]/ (2*IR1R_BinWidthInRadia(p))		//converts results into radi and scales to width of each bin
		Wave NormalizedResidual=root:Packages:Sizes:NormalizedResidual
		NVAR NumberIterations=root:Packages:Sizes:NumberIterations
		NVAR Chisquare=root:Packages:Sizes:Chisquare
		MatrixOp/O SizesFitIntensity = AmatrixOrig x Xwave
		duplicate/O SizesFitIntensity, tempWv
		tempWv = (Intensity - SizesFitIntensity)/Errors
		tempWv = tempWv^2
		NormalizedResidual = tempWv
		Chisquare = sum(tempWv)
		err=Chisquare/numpnts(SizesFitIntensity)

		numIter+=1
		NumberIterations=numIter
		if(mod(NumberIterations,10)==0)
			IR1R_NNLSUpdateDataForGrph()
			LegendText2="\\Z09\K(0,0,65280)Method used: NNLS \r"
			LegendText2+="working....  Number of iterations ="+num2str(NumberIterations)
			TextBox/C/F=0/N=Legend2/X=0.00/Y=-14.00 LegendText2
		endif
		DoUpdate
//	while(NumberIterations<50 || (err>1 && numIter<NNLS_MaxNumIterations && (lasterr*1.1)>err))
	while((err>1 && numIter<NNLS_MaxNumIterations))// && (lasterr*1.1)>err))
	KillWaves/Z Amatrix, tempWv, AkSTAR, Qk, Dk, Pk, AmatrixT, Amatrix, BVector
	ModelDistribution = Xwave [p]/ (2*IR1R_BinWidthInRadia(p))		//converts results into radi and scales to width of each bin
	setDataFolder OldDf
	
end
