Major files:
1. callSim.m
The function for all simulation side activity.
2. DataDL.m
Download data from MongoDB, EPlus folder, and HardwareData folder, then save them to a *.mat file. File name is constructed as foldername_MMDDYYYY_HHMMSS.

Other folders/files:
CTRL: Include control models related scripts 
HardwareData: Place to store hardware data.
OBM: OBM related scripts
DB: MongoDB reading/writing related scripts
VB: Virtual building Simulink model
DBLoc.mat: It stores the database and collection names for each run. 
ExampleCall.m: Example file to call callSim.m