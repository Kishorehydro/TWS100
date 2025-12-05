# TWS100
A MATLAB-based global platform for GRACE/GRACE-FO TWSA analysis, reconstruction evaluation, trend detection, and SHAP-driven sensitivity assessment featuring continental-scale datasets and global basin coverage.

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
<img width="2000" height="375" alt="image" src="https://github.com/user-attachments/assets/ad0712b4-5289-4385-a177-3f554aabf3c1" />

•	Click on the basin name

All analyses automatically clip data to the selected basin.
### 5.2 Dataset loading button

Click “**Load Data**” to load all the data load automatically.
<img width="2000" height="375" alt="image" src="https://github.com/user-attachments/assets/e88056bd-7753-4aa1-bb34-c0f66d3f6fca" />

### 5.3 Temporal Options

<img width="2000" height="374" alt="image" src="https://github.com/user-attachments/assets/4259bf44-aa6e-4e44-8c0d-8c7ebe280d9f" />
<img width="2000" height="768" alt="image" src="https://github.com/user-attachments/assets/3549f217-6fd5-498b-ab41-2d0b698f97ff" />

### 5.4 Spatial Plot Module

Basin Map Mode: Shows clipped spatial anomalies for the selected basin.
<img width="2000" height="374" alt="image" src="https://github.com/user-attachments/assets/6ce55921-9d71-4a15-b08f-b00af74e2e07" />
<img width="1209" height="1197" alt="image" src="https://github.com/user-attachments/assets/4515824e-61c4-42f3-94b9-50a52e205a3c" />

### 5.5 Regional Mean Module

<img width="2000" height="374" alt="image" src="https://github.com/user-attachments/assets/2b6fe6d5-e749-4730-ab53-f1640c804dc6" />
<img width="1883" height="1181" alt="image" src="https://github.com/user-attachments/assets/ff4cf586-d8c5-4805-80a9-f5c87ac81299" />

**Plot Options:** GRACE (JPL/CSR/GSFC), Reconstruction datasets

## 6. Analytical Modules

### 6.1 Trend Analysis Module
For using one of these or all the trend please plot at first then check on this option/options. (Should be tempotal plot)

<img width="2000" height="374" alt="image" src="https://github.com/user-attachments/assets/9b111fa3-85ee-4224-9d09-ae00ddd31e86" />

**Available Methods:** Linear regression, Polynomial (2nd order), LOESS smoothing, Sen’s slope

<img width="1911" height="1008" alt="image" src="https://github.com/user-attachments/assets/b2e00f6d-1db0-4ef4-8579-87250362b6da" />

### 6.2 SHAP-Based Sensitivity Module

This module quantifies how much each dataset or model variable contributes to TWSA or reconstruction output. Details about this will be available only after performing reconstruction.
<img width="2000" height="375" alt="image" src="https://github.com/user-attachments/assets/ea02996c-d5d1-49f3-b72b-d15df3393858" />
<img width="1406" height="1122" alt="image" src="https://github.com/user-attachments/assets/48ddebd2-501c-4c2b-92a7-adb7efcf826f" />

### 6.3 Reconstruction Module
External Reconstructions

Compare Li, Humphrey, Palazzoli, etc.

Internal Reconstruction Models
<img width="2000" height="375" alt="image" src="https://github.com/user-attachments/assets/a9e9d40e-3457-4901-8c7a-68c0b1b68af5" />

•	Random Forest

•	Artificial Neural Network

### 6.4 Evaluation Metrics

<img width="2000" height="374" alt="image" src="https://github.com/user-attachments/assets/9a977d5a-19d1-463d-88f3-2a414d90bef6" />

All metrics will be calculated for the plotted variable (selected time period)

## 7. Output and Export Tools
<img width="2000" height="375" alt="image" src="https://github.com/user-attachments/assets/72fea6e0-1601-4e93-80b9-fba2bbbfea4a" />

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
