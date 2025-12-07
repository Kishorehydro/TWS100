# TWS100: A GUI application for centennial variations in terrestrial water storage 
TWS100 is a MATLAB-based user-friendly platform for GRACE/GRACE-FO-based terrestrial water storage (TWS) reconstruction over a century, analyses, comparison with previous reconstruction datasets, spatiotemporal trends and variability, SHAP-based sensitivity assessment, and validation with the ground-based observations.

## 1. Introduction

**TWS100** is a MATLAB-based global graphical user interface for GRACE/GRACE-FO TWSA analysis, reconstruction, evaluation, trend detection, and SHAP-driven sensitivity assessment. It supports any basin worldwide, with global river basins having catchment areas of more than 63000 sq. km., boundaries and continental-scale data coverage enabling hydrological assessment across climate zones, regions, and scales.

Global river basin datasets for basin selection, GRACE/GRACE-FO mascon products (JPL, CSR, GSFC), Multiple reconstruction datasets (Humphrey et al., 2019; Li et al., 2021; Deng et al., 2023; Palazzoli et al., 2025; and Mandal et al.,2025), Built-in machine learning reconstruction tools,	SHAP-based explainable sensitivity analysis, and Groundwater storage anomaly validation

The interface requires **no programming experience**, and all workflows operate on **any basin worldwide**.
## 2. System Requirements
**MATLAB Version**

•	MATLAB **R2024b** or later recommended

•	Fully compatible with Windows / macOS / Linux

**Required Toolboxes**

•	Mapping Toolbox

•	Statistics and Machine Learning Toolbox

•	Signal Processing Toolbox (recommended)

•	Deep Learning Toolbox (optional, for ANN reconstructions)

## 3. Installation
### 3.1 Download or Clone the Repository
Open a terminal or command prompt:

gh repo clone Kishorehydro/TWS100
### 3.2 Add the Folder to MATLAB Path
Start MATLAB and run:

addpath(genpath('path_to/TWS100'));

savepath;
### 3.3 Launch the GUI
Launch the graphical interface: **TWS100** or double-click **TWS100.mlapp** in MATLAB’s folder browser.
## 4. Input Data Formats
TWS100 supports:
### 4.1 GRACE/GRACE-FO Mascon Products (NetCDF)
JPL RL06M; CSR RL06M; GSFC RL06M
### 4.2 Reconstruction Datasets (NetCDF)
Humphrey et al. 2019; Li et al., 2021; Deng et al., 2023; Palazzoli et al., 2025; Mandal et al.,2025
### 4.3 Basin Boundaries (shapefile: .shp)
•	HydroBASINS Level 5–7
### 4.4 Other Hydro-meteorological Data
•	Precipitation (IMD, GPCP, ERA5)

•	Soil moisture, Evapotranspiration, Temperature, Runoff, Wind Speed, Relative Humidity, Long-wave and Short-wave Solar Radiation. (For reconstruction)

•	In-situ groundwater level data

## 5. Using the TWS100 GUI
The interface contains five main sections:

### 5.1 Basin Selection dropdown
Use the select basin button
<img width="2000" height="375" alt="image" src="https://github.com/user-attachments/assets/773ecc06-0ab3-41bb-8319-8a1aa4fa29b2" />

•	Click on the basin name

All analyses automatically clip data to the selected basin.
### 5.2 Dataset loading button

Click “**Load Data**” to load all the data load automatically.
<img width="2000" height="374" alt="image" src="https://github.com/user-attachments/assets/4215a51e-5692-4b0e-b8a4-53185948bda2" />

### 5.3 Temporal Options

<img width="2000" height="374" alt="image" src="https://github.com/user-attachments/assets/50f620f7-f057-480b-b8a9-c99fef6fc722" />
<img width="2000" height="769" alt="image" src="https://github.com/user-attachments/assets/95072627-f7e7-48d1-92da-2297316746fe" />

### 5.4 Spatial Plot Module

Basin Map Mode: Shows clipped spatial anomalies for the selected basin.
<img width="2000" height="374" alt="image" src="https://github.com/user-attachments/assets/6e2b11a9-d509-4ea4-8f33-42e2660e94cb" />
<img width="1209" height="1196" alt="image" src="https://github.com/user-attachments/assets/a887f6d6-dfc9-4ccc-ad41-db1120b267b0" />

### 5.5 Regional Mean Module

<img width="2000" height="374" alt="image" src="https://github.com/user-attachments/assets/332e3f44-635d-44e8-b948-75377787de9f" />
<img width="1883" height="1181" alt="image" src="https://github.com/user-attachments/assets/ff4cf586-d8c5-4805-80a9-f5c87ac81299" />

**Plot Options:** GRACE (JPL/CSR/GSFC), Reconstruction datasets

## 6. Analytical Modules

### 6.1 Groundwater Storage Anomaly Validation Module
<img width="2000" height="376" alt="image" src="https://github.com/user-attachments/assets/50cf9535-4a9c-490f-8005-5e89951b6780" />
<img width="2016" height="843" alt="image" src="https://github.com/user-attachments/assets/aff60e37-7191-4763-870b-b434e6bdde25" />

### 6.2 Trend Analysis Module
For using one of these or all the trend please plot at first then check on this option/options. (Should be tempotal plot)

<img width="2000" height="375" alt="image" src="https://github.com/user-attachments/assets/8dd0d8ef-379b-4817-98d4-2a1a5330445f" />

**Available Methods:** Linear regression, Polynomial (2nd order), LOESS smoothing, Sen’s slope

<img width="1911" height="1008" alt="image" src="https://github.com/user-attachments/assets/8f293ca4-d671-40ce-8db5-988cb32b345e" />

### 6.3 Evaluation Metrics

<img width="2000" height="374" alt="image" src="https://github.com/user-attachments/assets/a81fc7f0-dccc-40d6-9dde-8f4d99dfd11e" />

All metrics will be calculated for the plotted variable (selected time period)

### 6.4 Reconstruction Module

Internal Reconstruction Models

<img width="2000" height="375" alt="image" src="https://github.com/user-attachments/assets/1c678130-2316-4c52-805f-3bb215ea5e97" />

•	Random Forest

•	Artificial Neural Network

### 6.5 SHAP-Based Sensitivity Module

This module quantifies how much each dataset or model variable contributes to TWSA or reconstruction output. Details about this will be available only after performing reconstruction.
<img width="2000" height="375" alt="image" src="https://github.com/user-attachments/assets/63be691d-e998-4910-8807-410440f0791f" />
<img width="1407" height="1122" alt="image" src="https://github.com/user-attachments/assets/aa054b0a-84a6-4808-b8d4-45a240d160e1" />

## 7. Output and Export Tools
<img width="2000" height="374" alt="image" src="https://github.com/user-attachments/assets/69b06cda-6d3d-4c2a-b91e-569bfd5fd754" />

You can export: Spatial maps, Time series, Regional mean plots, Trend results, Sensitivity outputs, Reconstructed data

in formats: (PNG, TIFF,	PDF,	CSV,	XLSX)

## 8. Troubleshooting
MATLAB says a toolbox is missing

Install the required toolboxes listed in Section 2.

GRACE data not loading

Ensure files are:

•	NetCDF (.nc)

•	HDF5 (.h5)

•	Proper directory structure

Basin not clipping

Verify the HydroBASINS shapefile location.

SHAP analysis errors

Confirm:

•	ML toolbox installed

•	Input variables are numeric and aligned in time

## 9. Best Practices
•	Always inspect spatial maps before interpreting trends.

•	Compare all GRACE centers (JPL, CSR, GSFC) for robustness.

•	Reconstruct multiple basins when validating model performance.

•	Use SHAP to interpret the importance of a variable.

## 10. Citation
If you are using this GUI, we would appreciate it if you could acknowledge both the GUI and the associated publication.

Garai Nabakishor, Abhishek, Chander Shard, 2025 TWS100: Centennial variations in terrestrial water storage: A GUI application.

Version 1.0.0 GitHub Repository.
## 11. Contact
For issues, submit a GitHub issue or contact:

nabakishorofficial@gmail.com

## License
This project is licensed under the MIT License.
