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

Each case has a folder that contains files specific to that case. The SharedModelFiles folder contains the files that are common across cases. To run each case, move the files from the specific case folder into the same folder that contains the SharedModelFiles. You can test the case by running ExampleCall.m, which calls callSim.m, the entry point for HSIM. The inputs and outputs for the model are defined in callSim.m. ExampleCall loads a file containing real laboratory data and data from a previous execution of IBASIM and uses that data as the input to HSIM. When used with TRNSYS, Type 155 in TRNSYS calls the script mmFcnCTM11.m, which calls callSim.m.

## Types 
The types listed here were developed specifically for the IBAL model. The FORTRAN codes are included in this folder. These types call other subroutines that are included as part of TRNSYS, but are not included here.

| Type ID  | Equipment | Description |
| ------------- | ------------- | ------------- |
| 2201 | Thermal energy storage | Based on the [approach][tesmodel] developed from grant 70NANB17H277 |
| 8888 | Water-cooled chiller | Based on [Type 888][laith] from grant 70NANB21H108, which is based on [Type 666][TessTypes] |
| 9031 | Pumps and pipes | Based on [Type 9000][laith] from grant 70NANB21H108; calculates hydronic system pressures and flow rates, and pump power consumption |
| 9106 | Pump controller | Developed in grant 70NANB21H108 |
| 9318 | Airflow calculation | Based on [Type 8317][kopach] from grant 70NANB18H203 |
| 9898 | Cooling coil | Based on [Type 9897][kopach] from grant 70NANB18H203; models the cooling coil in the AHUs |

<!-- References -->
[TessTypes]: https://www.trnsys.com/tess-libraries/TESSLibs17_General_Descriptions.pdf
[kopach]: https://sel.me.wisc.edu/publications/theses/kopach21.zip
[laith]: https://sel.me.wisc.edu/publications/theses/abdulmajeid23.zip
[tesmodel]: https://www.nist.gov/publications/development-and-validation-simulation-testbed-intelligent-building-agents-laboratory


<!-- References -->

## Citations
Chen Z, Wen J, Bushby ST, Lo LJ, O'Neill Z, Payne WV, Pertzborn A, Calfa C, Fu Y, Grajewski G, Li Y. (2022) Development of a Hardware-in-the-loop Testbed for Laboratory Performance Verification of Flexible Building Equipment in Typical Commercial Buildings. ASHRAE 2022 Annual Conference (Toronto, Ontario, Canada). 

[hilft]: https://doi.org/10.48550/arXiv.2301.13412
