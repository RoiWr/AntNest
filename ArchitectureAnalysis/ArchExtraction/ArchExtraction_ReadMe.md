# Architecture Extraction READ ME

scripts to run:

1) ArchAnalysis.m
This scripts crops and registers the images to t0 image.
IN: the raw Arch images per specific nest.
OUT: Registered (RGBreg) and registered and cropped images (RGB) in new folders.

2) ArchBWforSet.m
This script runs on all the images:
  a. binarizes them
  b. removes queen
  c. manual fixes
  d. saves BW images into new folder

3) update_AA.m
Runs the same as ArchAnalysis.m for newly added images

* check for missing scripts in the google Drive "Scripts" folder
