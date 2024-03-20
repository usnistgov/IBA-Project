## Types 
The types listed here were developed specifically for the IBAL model. The FORTRAN codes are included in this folder.

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
