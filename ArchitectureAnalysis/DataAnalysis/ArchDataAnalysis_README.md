# Arch Data Analysis READ ME

## 1) CM to pixel ratio determination
core function: cmINpixels.m\
Need to run wrapper script cmINpixels_4allNests.m and save manually output struct into a .MAT file 
that will be used later for all nests.

## 2) BW data extraction
Run main function per nest - BW_Data_Extract_Nest_Set.m
all data extracted is saved into A metadata structure.
this function:
  1) **Resizes** the Area and functional Area images by 25% for faster processing
  2) **Data organization** in A metadata structure
  3) **Functional Area**: Gets ClassData, which is geometric information for the 3 structural classes :
  large chambers, small chambers and tunnels. This is done using the function NestRegionClassifier4.m.
  4) **Total Area**: get total area and total length using BW_Area_Length.m
  5) **Population**: get population data from BroodLocator annotations csv files.\
    a. SmoothPop: the population timeseries is smoothed using a mooving average 
    to compensate errors in ant counting.
  6) **Saves** all the data into A metadata structure.
  
*NOTE* If there is no need to get Class data, and only total area and length, 
it is possible to modify the code to run only BW_Area_Length.m on functional area images.
  
