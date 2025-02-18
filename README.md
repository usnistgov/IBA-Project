# Intelligent Building Agents Project

In the U.S., commercial buildings are responsible for approximately 36 % of total energy consumption, 
and the heating, ventilation, and air-conditioning (HVAC) systems make up about 52 % of that total. 
Improving building operations can significantly reduce the cost of the energy used in the 
commercial building sector. The Intelligent Building Agents (IBA) project is part of the Embedded Intelligence 
in Buildings Program in the Engineering Laboratory at the National Institute of Standards and Technology (NIST).
A key part of the IBA Project is the IBA Laboratory (IBAL), a unique facility consisting of a mixed system 
of off the shelf equipment, including chillers and air handling units, controlled by a data acquisition 
system and capable of supporting building system optimization research under realistic and reproducible 
operating conditions.

## Data
The [IBAL Database][ibal-db] contains the values of approximately 300 sensors/actuators in the IBAL, 
including both sensor measurements and control actions, as well as approximately 850 process data, 
which are typically related to control settings and decisions. Each of the sensors/actuators has 
associated metadata. Data are collected every 10 s. The data can be access as individual sensor data or as 
all the data from a specific test. For example, searching for "DOE Formal Testing" in the Experiments page will
bring up tests run as part of a 2019 DOE BENEFIT project. Data can be isolated by subsystem as well. If you select
Chiller1, for example, all sensors directly related to Chiller1 are listed. The time series data are shown 
as plots and can be downloaded as csv files for use offline.

## Software
This repository contains scripts developed as part of the IBA project for data processing and model development.
They are organized based on the equipment they model, the publication they support, or another keyword. When
use in support of a publication, the publication or a link to it are included in the folder. Each script has different 
software requirements. The languages include MATLAB, Python, and FORTRAN.

## Research Topics
The folders in this repo are organized by research topic. They contain README files to explain their contents in more detail. 

- IBASIM: publications and software related to the simulation model of the IBAL
- Comparison of ice-on-coil thermal energy storage models: publications and scripts related to the development of machine learning models of the ice-on-coil thermal energy storage system in the IBAL

## Contact
[usnistgov/IBA-Project][gh-iba] is developed and maintained
by:

Amanda Pertzborn, PhD  [@apertzbo][apertzbo] <br> 
Engineering Laboratory<br>
Building Energy and Environment Division<br>
Mechanical Systems and Controls Group<br>

Please reach out with questions and comments.

## Related materials
Information about the IBA Project: 

[Intelligent Building Agents Project][iba] <br>
[Embedded Intelligence in Buildings Program][eib] <br>
[Publications][nist_bio] <br>

Information about software:

[TRNSYS][trnsys] <br>
[EnergyPlus][eplus] <br>
[EnergyPlust to FMU][eplusFMU] <br>
[MATLAB][matlab] <br>
[Simulink][simulink] <br>
[Python][python] <br>
[scikit-learn][scikit] <br>
[pytorch][pytorch] <br>
[tensorflow][tensorflow] <br>


## Citations
Check the README file within each subfolder for citations specific to that set of research. A general reference for the IBA project is:

National Institute of Standards and Technology (2024) _Intelligent Building Agents Project_. Available at [https://www.nist.gov/el/energy-and-environment-division-73200/intelligent-buildings-agents-project][iba]


<!-- References -->
[ibal-db]: https://ibal.nist.gov
[apertzbo]: https://github.com/apertzbo
[iba]: https://nist.gov/el/energy-and-environment-division-73200/intelligent-buildings-agents-project
[eib]: https://www.nist.gov/programs-projects/embedded-intelligence-buildings-program
[nist_bio]: https://www.nist.gov/people/amanda-pertzborn
[trnsys]: https://www.trnsys.com/
[python]: https://www.python.org/
[scikit]: https://scikit-learn.org/stable/
[pytorch]: https://pytorch.org/
[tensorflow]: https://www.tensorflow.org/
[eplus]: https://energyplus.net/
[eplusFMU]: https://github.com/lbl-srg/EnergyplusToFMU
[matlab]: https://www.mathworks.com/
[simulink]: https://www.mathworks.com/products/simulink.html#:~:text=Simulink%20is%20a%20block%20diagram,and%20deploy%20without%20writing%20code.
[gh-iba]: https://github.com/usnistgov/IBA-Project

---

