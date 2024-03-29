# Folder contents

## Dependencies
MATLAB 2020b or newer
- Parallel computing toolbox
- Signal processing toolbox
- Simulink 
- Simulink coder
- Statistics and machine learning toolbox
- System identification toolbox

EnergyPlus V9.3.0

## Cases
The DOE BENEFIT 2019 project (grant EE-0009153), [Hardware-in-the-loop Flexible Load Testbed (HILFT)][hilft], generated datasets to demonstrate how the HVAC in commercial buildings can be used to support grid needs. This study examined different control approaches in four climate zones. A co-simulation platform was developed that couples MATLAB based control scripts with an EnergyPlus building model. This simulation was integrated with the IBAL - the IBAL provided the simulation with the sensor measurements of the performance of real HVAC equipment and the simulation provided the IBAL with zone loads, weather, and some setpoints. The cases were modified to work with the TRNSYS model and are referred to as HSIM.

| Case Name | Description |
| ------------- | ------------- |
| Atlanta_Eff_Default | Baseline case using ASHRAE Standard 90.1-2004 and a typical summer day (08/26/2015) in Atlanta, GA, USA |
| Atlanta_Shed_Default | Load shedding - uses zone temperature setpoint changes to decrease the zone loads during peak period for electric rates - on a typical summer day (08/26/2015) in Atlanta, GA, USA |
| Atlanta_Shift_Default | Load shifting - pre-cool the zones prior to the peak period for electric rates so that setpoint temperatures can be increased during the peak period - on a typical summer day (08/26/2015) in Atlanta, GA, USA |
| Atlanta_Shift_TES | Load shifting - charge the TES during the night and discharge the TES during the peak period - on a typical summer day (08/26/2015) in Atlanta, GA, USA |
| Atlanta_Eff_ExtrmSum | Baseline case using ASHRAE Standard 90.1-2004 and an extreme summer day (07/08/2015) in Atlanta, GA, USA |
| Atlanta_Shed_ExtrmSum | Load shedding - uses zone temperature setpoint changes to decrease the zone loads during peak period for electric rates - on an extreme summer day (07/08/2015) in Atlanta, GA, USA |
| Atlanta_Shift_ExtrmSum | Load shifting - pre-cool the zones prior to the peak period for electric rates so that setpoint temperatures can be increased during the peak period - on an extreme summer day (07/08/2015) in Atlanta, GA, USA |

Each case folder contains the full set of files required for that case. Type 155 in TRNSYS calls the script mmFcnCTM11.m, which in turn calls callSim.m, which is the entry point for HSIM. The inputs and outputs for the model are defined in callSim.m. The case can be run without interfacing with TRNSYS from ExampleCall.m. This script loads a file containing real laboratory data and data from a previous execution of IBASIM and uses that data as the input to HSIM.

<!-- References -->

## Citations
Chen Z, Wen J, Bushby ST, Lo LJ, O'Neill Z, Payne WV, Pertzborn A, Calfa C, Fu Y, Grajewski G, Li Y. (2022) Development of a Hardware-in-the-loop Testbed for Laboratory Performance Verification of Flexible Building Equipment in Typical Commercial Buildings. ASHRAE 2022 Annual Conference (Toronto, Ontario, Canada). 

[hilft]: https://doi.org/10.48550/arXiv.2301.13412
