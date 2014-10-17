Copy and paste these procedure files into the User Procedure folder.  The path is:

c>Program Files>WaveMetrics>Igor Pro Folder>User Procedures

Then copy and paste the following into the procedure window:

#pragma rtGlobals=1                // Use modern global access method.
#pragma rtGlobals=1                // Use modern global access method.
#pragma rtGlobals=1                // Use modern global access method.
#include "DiffractionCalc_DataEditor"
#include "DiffractionCalc" 
#include "getHKLfrom1dwave"
#include "DoubleGaussFit"
#include  <Split Axis>
#include  <SaveGraph>
//#include "HS_DblGauss"


The diffraction calculator lets you predict d-spacing or 2-theta values at P>0 and
300K based on the 3rd Order Birch-Murnaghan EOS.
To perform the calculations, do the following steps:

1.  Make a new folder 'Calibrants' in the data browser and move the arrow to that
folder
2.  Under the macros tab, click on Editing Files for DiffractionCalc, then click on
Input_New_Dspace_Data
3.  Select the crystal system and name the file. A table will appear.
4.  Enter the h,k,l,intensity in the appropriate columns along with the bulk modulus
and its pressure derivitave, and lattice constants in the appropriate rows.
5.  Close the table and DO NOT SAVE
6.  Under the macros tab, click on Editing Files for DiffractionCalc, then click on
Make_Dspace_File
7.  Select the file that you just named in step 2 when inputting new dspace data.

Editing previously made Dspace files can be done by selecting Editing Files for
DiffractionCalc under the macros tab and selecting Edit_Preexisting_Dspace_Data.
Make the edits and follow steps 4-6 from above.

To plot the BM-EOS intensities as a function of d-spacing or 2-theta,make sure that
the arrow is on the calibrants folder in the data browser and simply type GO() into
the command window. This will prompt a window.
The "sticks" will only be plotted if a diffraction pattern is already plotted on a
graph.

