#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.48

//*************************************************************************\
//* Copyright (c) 2005 - 2010, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//This macro loads the Nika 1 set of Igor Pro macros for evaluation of 2D images in small angle scattering

#include "NI1_BeamCenterUtils",version>=2.02
#include "NI1_ConvProc", version>=2.08
#include "NI1_FileLoaders",version>=2.05
#include "NI1_LineProfile", version>=2.02
#include "NI1_LineProfCalcs",version>=2.02
#include "NI1_main", version>=1.48
#include "NI1_MainPanel", version>=2.16
#include "NI1_mar345", version>=1.01
#include "NI1_mask", version>=1.11
#include "NI1_pix2Dsensitivity",version>=1.01
#include "NI1_SaveRecallConfig", version>=1.01
#include "NI1_SquareMatrix", version>=1.01
#include "NI1_WinView",version>=1.87
#include "NI1_DNDCATsupport",version>=1.11

#include "IN2_GeneralProcedures", version>=1.41


//1.43, updated FIle loaders to 2.01
//1.44  fixes to adding Q scale to images
