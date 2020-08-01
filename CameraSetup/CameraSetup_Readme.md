*Camera Setup ReadMe*
=====================================
-------------------------------------

Installation Requirements:
1) DigCamControl software for control of DSLR cameras (http://digicamcontrol.com/)
2) CameraController.m MATLAB add-on (https://www.mathworks.com/matlabcentral/fileexchange/57196-cameracontroller)
3) Arduino hardware support package for MATLAB (https://www.mathworks.com/matlabcentral/fileexchange/47522-matlab-support-package-for-arduino-hardware)

--------------------------------------

CameraController GUI

Run cameracontroller.m to open the GUI for manual picture aquisition.
Via the compputer or the trigger button.
Setup up temp saving directories for image in the code in advance and camera properties.

files:
- cameracontroller.m
- cameracontroller.fig
- PhotoProgram.m

-----------------------------------

Timelapse

Run timelapse_1.m for timelaspe setting picture aquisition.
And automatic control of backlight flash.

files:
- timelapse_1.m
- timelapseFcn.m - timelapse function of images and lower backlight
- DayNight.m - 12 hour cycle timer function for top backlight
- PhotoProgram.m - see below

------------------------------------------

PhotoProgram.m

This script configures the triggered camera photography sequence for both manual and timelapse aquisition.
Sets up exposure setting, number of images and delays between them.

------------------------------------------
BroodLocator GUI

GUI for review and annotation of captured images.
Setup up saving directories for image and annotations in the code in advance.

files:
- BroodLocator.m
- BroodLocator.fig
- OCR_nest_tag.m - script to automatically extract nest tag
