## Contents

This folder contains information related to modeling of an ice-on-coil thermal energy storage (ice) tank.

- NIST.TN.2256.pdf: Technical note "Comparison of ice-on-coil thermal energy storage models" that describes the development of machine learning models of the ice tank and compares them with a physics based model. These models do not consider the time series behavior, but instead predict the ice inventory given the total load over the period of interest.
- MLModels_TN2256.ipynb: Notebook used to develop the ML models in NIST TN 2265.
- iceStorageModel.ipynb: Physics based model of the ice tank.
