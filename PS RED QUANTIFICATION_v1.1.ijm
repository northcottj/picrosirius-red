//-----PICROSIRIUS RED QUANTIFICATION MACRO-----
// Written 2017-03-08 by Josette Northcott for Weaver Lab use.
// This is version 1.1 of this macro (updated 2017-03-24 by J.Northcott).

//-----VERSION NOTES-----
// Version 1.1 changes: Intensity measurements confined to user defined area (set by threshold).
// Requires ImageJ version 1.50i.
requires("1.50i");

//-----SAMPLE DATA-----
// 	Label						Area	Mean	IntDen	%Area	RawIntDen	MinThr	MaxThr
//1	10070 pic 1 PS				90655	42.551	3857487	6.262	3857487		18		255
//2	10070 pic 1 PS:COL:Red		90655	57.421	5205521	100.000	5205521		0		255
//3	10070 pic 1 PS:COL:Green	90655	52.911	4796610	99.986	4796610		0		255

//-----MACRO-----

// Prompt user to choose the input directory, get name and parent folder.
dirIN = getDirectory("Choose the folder where your images are located");
dirINname = File.getName(dirIN);
dirINParent = File.getParent(dirIN);
dirINFileList = getFileList(dirIN);
Array.sort(dirINFileList);

// Get info for date stamp of output folder.
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
if (month < 10) month = "0"+month;
if (dayOfMonth < 10) dayOfMonth = "0"+dayOfMonth;
DATE = (""+year+""+month+""+dayOfMonth+"");

// Assign output directory.
dirOUT = dirINParent+"/";

// Create dialog box to determine the image content and order in the input directory.
Dialog.create("Image folder description");
Dialog.addCheckbox("Folder contains both brightfield and polarized light images.", false);
Dialog.addMessage("\nIf true, describe the image order:\n");
Dialog.addCheckbox("Brightfield and polarized light images are alternating.", false);
Dialog.addCheckbox("Brightfield images appear before polarized light images.", false);
Dialog.addMessage("\n\n");
Dialog.show();
BOTH = Dialog.getCheckbox();
ALT = Dialog.getCheckbox();;
BFPS = Dialog.getCheckbox();;;
// Assign conditions and variables so that only the polarized light images are opened.
if (BOTH == false){
	START = 0; END = 0; SKIP = 1; PSred = 0;
	};
if (BOTH == true){
	HalfListLength = (lengthOf(dirINFileList))/2;
	if (ALT == true && BFPS == true){START = 0; END = 0; SKIP = 2; PSred = 1;}
	if (ALT == false && BFPS == true){START = HalfListLength; END = 0; SKIP = 1; PSred = 0;}
	if (ALT == true && BFPS == false){START = 0; END = 0; SKIP = 2; PSred = 0;} 
	if (ALT == false && BFPS == false){START = 0; END = HalfListLength; SKIP = 1; PSred = 0;}
}

// Set measurements.
run("Set Measurements...", "area mean integrated area_fraction limit display redirect=None decimal=3");

// Set threshold minimum to 0.
var MinThr = 0;

// Close any open Results tables.
if (isOpen("Results") == 1){
	selectWindow("Results"); run("Close");
}

// Open polarized light images and measure the mean pixel intensity for the red and green channels.
// For composite 16-bit or 8-bit images, set to green or red slice before measuring.
// For non-composite images (RGB images), split channels and then measure green and red channels.

for (i=START; i<((dirINFileList.length-END)-(SKIP-1)); i=i+SKIP){
	open(dirINFileList[i+PSred]);
	
	ImageType = is("Composite");
	if (ImageType == 1){
		CompositeImageID = getImageID();
		rename(replace(getTitle(),".tif",""));
		run("8-bit");
		run("Stack to RGB");
		RGBImageID = getImageID();
		rename(replace(getTitle(),"[\(RGB\)]",""));
	} else {
		RGBImageID = getImageID();
		rename(replace(getTitle(),".tif",""));
		run("Duplicate...", " ");
		run("Make Composite");
		CompositeImageID = getImageID();
		rename(replace(getTitle(),"-1",""));
	}	
	
	selectImage(RGBImageID); run("8-bit");
	if (MinThr == 0){
		run("Threshold...");
		call("ij.plugin.frame.ThresholdAdjuster.setMode", "Over/Under");
		call("ij.plugin.frame.ThresholdAdjuster.setMethod", "Triangle");
		setAutoThreshold("Triangle dark");
		waitForUser("Adjust Threshold", "Set threshold minimum (top slider).\n   * Background appears blue.\n   * Collagen appears grey.\nTheshold will be applied to all images.\n \nClick OK (in this box) when done.");
		getThreshold(lower, upper);
		MinThr = lower;
	} else {
		setThreshold(MinThr, 255);
	}
	run("Measure");
	run("Convert to Mask");
	run("Create Selection");
	roiManager("Add");
	roiManager("Select", 0);
	roiManager("rename", "COL");
	selectImage(RGBImageID); close();
	
	selectImage(CompositeImageID);
	roiManager("Select", 0);
	setSlice(1); run("Measure");
	setSlice(2); run("Measure");
	selectImage(CompositeImageID); close();
	
	roiManager("reset"); 
}

// Select the Threshold and ROI Manager windows and close them.
if (isOpen("Threshold") == 1){
	selectWindow("Threshold"); run("Close");
}
if (isOpen("ROI Manager") == 1){
	selectWindow("ROI Manager"); run("Close");
}

// Select the results window and save it as a (tab delimited)text file.
// Copy the results to the clipboard for quick & easy pasting into excel.
selectWindow("Results");
saveAs("text", dirOUT+dirINname+"_PS Red Quantification_"+DATE);
selectWindow("Results");
String.copyResults();
run("Close");

// Dialog box alerts user that macro is finished running.
waitForUser("MACRO COMPLETE","Measurements acquired and\ndata saved as .txt file");
