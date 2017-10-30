# picrosirius-red
ImageJ macro for quantification of polarized light images of picrosirius red stained tissues.

-----PICROSIRIUS RED QUANTIFICATION MACRO-----/
Written 2017-03-08 by Josette Northcott for Weaver Lab use.
This is version 1.1 of this macro (updated 2017-03-24 by J.Northcott).

-----VERSION NOTES-----/
Version 1.1 changes: Intensity measurements confined to user defined area (set by threshold).
Requires ImageJ version 1.50i.

-----INPUT DIRECTORY-----/
User input impage directory can contain:
- Only  polarized light images, OR
- Brightfield and polarized light images. In this case, the folder must contain the same number of brightfield and polarized light images
AND the order of the images must be either:
	- Alternating brightfield then polarized light for each image.
	- Alternating polarized light then brightfield for each image.
	- All brightfield and then all polarized light images.
	- All polarized light and then all brightfield images. 

-----THRESHOLD-----/
The user defined threshold is set using the first image, and then applied to all subsequent images.

-----RESULTS-----/
The results window is selected and saved as a (tab delimited) text file.
The results are also copied to the clipboard for quick & easy pasting into excel.

-----SAMPLE DATA-----/
 	Label  				Area	Mean  	IntDen	%Area 	RawIntDen	MinThr	MaxThr
1	10070 pic 1 PS 			90655	42.551	3857487	6.262 	3857487		18    	255
2	10070 pic 1 PS:COL:Red		90655	57.421	5205521	100.000	5205521		0     	255
3	10070 pic 1 PS:COL:Green	90655	52.911	4796610	99.986	4796610		0     	255

-----QUANTIFICATION-----/
Amount of collagen per field = PS %Area
Ratio of collagen fiber types = (PS:COL:Red IntDen)/(PS:COL:Green IntDen)
