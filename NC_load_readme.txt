load_NetCDF XOP allows Igor to NetCDF files.

You can get informations about NetCDF from
(http://unidata.ucar.edu/packages/netcdf/index.html).

For details of the XOP, see the help file.

This XOP is Macintosh version only.

Changes:
/*
 *	load_NetCDF		NetCDF Loader for Igor Pro (Macintosh)
 *
 *	08/10/00	ver. 1.01b	supports TEXT wave with floag(/t)
 *	08/05/00	ver. 1.00a	supports var%d or var%d_att%d style of wavename
 *	07/23/00	ver. 0.99	loads attributes of variables
 *	07/13/00	ver. 0.98	supports NC_CHAR and NC_BYTE, flag(/v)
 *	07/??/00	ver. 0.97b	force continue with flag(/z)
 *	??/??/??	ver. 0.96b	
 *	06/02/99	ver. 0.95b	loads names of variable to text wave
 *	06/01/99	ver. 0.94b	loads all attributes as wave
 *	02/16/99	ver. 0.93b	bug fix : mem leak
 *	02/14/99	ver. 0.92b	for nc_attributes, flags(/q, /d)
 *	01/20/99	ver. 0.91b	bug fix : for netatalk(page size)
 *	01/18/99	ver. 0.90b
 *
*/

The copyright of the NetCDF libs to be found at
(http://unidata.ucar.edu/packages/netcdf/copyright.html).

Koji Yamanaka
kojiy@ppl.eng.osaka-u.ac.jp
08/10/00