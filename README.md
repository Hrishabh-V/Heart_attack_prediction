# Heart Attack Prediction

Heart attack prediction app using R

![R](https://img.shields.io/badge/Made_with-R-blue?style=for-the-badge)
![Shiny](https://img.shields.io/badge/Framework-Shiny-lightgrey?style=for-the-badge)
![Deployment](https://img.shields.io/badge/Deployment-Shinyapps.io-green?style=for-the-badge)

This repository contains a Shiny app that predicts the risk of a heart attack based on various medical and demographic variables. The app allows healthcare professionals and researchers to input patient data and receive a risk assessment in real-time.

## Table of Contents

- [Project Overview](#project-overview)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Deployment](#deployment)
- [License](LICENSE)

## Project Overview

The Heart Attack Prediction Shiny App leverages a machine learning model to predict the likelihood of a heart attack. The model is trained on historical patient data, enabling it to provide risk scores that can assist healthcare providers in making informed decisions.

### Key Deliverables:
- **Shiny App**: A web-based interface for real-time heart attack risk prediction.
- **Model**: A machine learning model trained on patient data for accurate risk assessment.

## Features

- **User-Friendly Interface**: Simple and intuitive UI built with Shiny.
- **Real-Time Predictions**: Instant risk assessment based on user inputs.

## Installation

To run this app locally, you'll need to have R and RStudio installed. Additionally, install the required packages:

```r
install.packages(c("tidyverse", "caret", "e1071", "randomForest", "caTools", "rmarkdown", "shiny", "shinythemes", "ggplot2", "plotly", "DMwR2"))

## Usage

- **Load the Model: Ensure the trained model (heart_disease_rf_model.rds) is in the working directory.

- **Run the Shiny App: Open the app.R file in RStudio and click Run App or use the following command in R: 

```r
shiny::runApp("path/to/your/app")

- **Interact with the App: Enter patient data into the input fields and click the "Predict" button to get the heart attack risk prediction.

## Deployment
- **The Shiny app is deployed on [Shinyapps.io](https://hrishabhv.shinyapps.io/Heart_Attack_Prediction/). You can access the live application at this link.