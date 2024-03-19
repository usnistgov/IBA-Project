# Intelligent Building Agents Project

In the U.S., commercial buildings are responsible for approximately 36 % of total energy consumption, 
and the heating, ventilation, and air-conditioning (HVAC) systems make up about 52 % of that total. 
Improving building operations can significantly reduce the amount and cost of the energy used in the 
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

## Contact
If you have questions or would like to discuss the IBA project, contact:

Amanda Pertzborn, PhD  [@apertzbo][apertzbo] <br> 
Engineering Laboratory<br>
Building Energy and Environment Division<br>
Mechanical Systems and Controls Group<br>

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
When using 


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




1. Software or Data description
   - Statements of purpose and maturity
   - Description of the repository contents
   - Technical installation instructions, including operating
     system or software dependencies
1. Contact information
   - PI name, NIST OU, Division, and Group names
   - Contact email address at NIST
   - Details of mailing lists, chatrooms, and discussion forums,
     where applicable
1. Related Material
   - URL for associated project on the NIST website or other Department
     of Commerce page, if available
   - References to user guides if stored outside of GitHub
1. Directions on appropriate citation with example text
1. References to any included non-public domain software modules,
   and additional license language if needed, *e.g.* [BSD][li-bsd],
   [GPL][li-gpl], or [MIT][li-mit]

The more detailed your README, the more likely our colleagues
around the world are to find it through a Web search. For general
advice on writing a helpful README, please review
[*Making Readmes Readable*][18f-guide] from 18F and Cornell's
[*Guide to Writing README-style Metadata*][cornell-meta].

## LICENSE

Each repository will contain a plain-text file named `LICENSE.md`
or `LICENSE` that is phrased in compliance with the Public Access
to NIST Research [*Copyright, Fair Use, and Licensing Statement
for SRD, Data, and Software*][nist-open], which provides
up-to-date official language for each category in a blue box.

- The version of [LICENSE.md](LICENSE.md) included in this
  repository is approved for use.
- Updated language on the [Licensing Statement][nist-open] page
  supersedes the copy in this repository. You may transcribe the
  language from the appropriate "blue box" on that page into your
  README.

If your repository includes any software or data that is licensed
by a third party, create a separate file for third-party licenses
(`THIRD_PARTY_LICENSES.md` is recommended) and include copyright
and licensing statements in compliance with the conditions of
those licenses.

## CODEOWNERS

This template repository includes a file named
[CODEOWNERS](CODEOWNERS), which visitors can view to discover
which GitHub users are "in charge" of the repository. More
crucially, GitHub uses it to assign reviewers on pull requests.
GitHub documents the file (and how to write one) [here][gh-cdo].

***Please update that file*** to point to your own account or
team, so that the [Open-Source Team][gh-ost] doesn't get spammed
with spurious review requests. *Thanks!*

## CODEMETA

Project metadata is captured in `CODEMETA.yaml`, used by the NIST
Software Portal to sort your work under the appropriate thematic
homepage. ***Please update this file*** with the appropriate
"theme" and "category" for your code/data/software. The Tier 1
themes are:

- [Advanced communications](https://www.nist.gov/advanced-communications)
- [Bioscience](https://www.nist.gov/bioscience)
- [Buildings and Construction](https://www.nist.gov/buildings-construction)
- [Chemistry](https://www.nist.gov/chemistry)
- [Electronics](https://www.nist.gov/electronics)
- [Energy](https://www.nist.gov/energy)
- [Environment](https://www.nist.gov/environment)
- [Fire](https://www.nist.gov/fire)
- [Forensic Science](https://www.nist.gov/forensic-science)
- [Health](https://www.nist.gov/health)
- [Information Technology](https://www.nist.gov/information-technology)
- [Infrastructure](https://www.nist.gov/infrastructure)
- [Manufacturing](https://www.nist.gov/manufacturing)
- [Materials](https://www.nist.gov/materials)
- [Mathematics and Statistics](https://www.nist.gov/mathematics-statistics)
- [Metrology](https://www.nist.gov/metrology)
- [Nanotechnology](https://www.nist.gov/nanotechnology)
- [Neutron research](https://www.nist.gov/neutron-research)
- [Performance excellence](https://www.nist.gov/performance-excellence)
- [Physics](https://www.nist.gov/physics)
- [Public safety](https://www.nist.gov/public-safety)
- [Resilience](https://www.nist.gov/resilience)
- [Standards](https://www.nist.gov/standards)
- [Transportation](https://www.nist.gov/transportation)

---

[usnistgov/opensource-repo][gh-osr] is developed and maintained
by the [opensource-team][gh-ost], principally:

- Gretchen Greene, @GRG2
- Yannick Congo, @faical-yannick-congo
- Trevor Keller, @tkphd

Please reach out with questions and comments.

<!-- References -->

[18f-guide]: https://github.com/18F/open-source-guide/blob/18f-pages/pages/making-readmes-readable.md
[cornell-meta]: https://data.research.cornell.edu/content/readme
[gh-cdo]: https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners
[gh-mdn]: https://github.github.com/gfm/
[gh-nst]: https://github.com/usnistgov
[gh-odi]: https://odiwiki.nist.gov/ODI/GitHub.html
[gh-osr]: https://github.com/usnistgov/opensource-repo/
[gh-ost]: https://github.com/orgs/usnistgov/teams/opensource-team
[gh-rob]: https://odiwiki.nist.gov/pub/ODI/GitHub/GHROB.pdf
[gh-tpl]: https://github.com/usnistgov/carpentries-development/discussions/3
[li-bsd]: https://opensource.org/licenses/bsd-license
[li-gpl]: https://opensource.org/licenses/gpl-license
[li-mit]: https://opensource.org/licenses/mit-license
[nist-code]: https://code.nist.gov
[nist-disclaimer]: https://www.nist.gov/open/license
[nist-s-1801-02]: https://inet.nist.gov/adlp/directives/review-data-intended-publication
[nist-open]: https://www.nist.gov/open/license#software
[wk-rdm]: https://en.wikipedia.org/wiki/README
