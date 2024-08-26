library(shiny)

# Define the UI
ui <- fluidPage(
  titlePanel("Heart Attack Prediction"),

  sidebarLayout(
    sidebarPanel(
      numericInput("age", "Age:", value = 50, min = 0, max = 100),
      selectInput("sex", "Sex:", choices = c("Male" = "1", "Female" = "0")),
      selectInput("cp", "Chest Pain Type:", choices = c("Type 0" = "0", "Type 1" = "1", "Type 2" = "2", "Type 3" = "3")),
      numericInput("trestbps", "Resting Blood Pressure (mm Hg):", value = 120, min = 50, max = 200),
      numericInput("chol", "Cholesterol (mg/dl):", value = 200, min = 100, max = 400),
      selectInput("fbs", "Fasting Blood Sugar:", choices = c("<= 120 mg/dl" = "0", "> 120 mg/dl" = "1")),
      selectInput("restecg", "Resting Electrocardiographic Results:", choices = c("Normal" = "0", "ST-T Wave Abnormality" = "1", "Left Ventricular Hypertrophy" = "2")),
      numericInput("thalach", "Maximum Heart Rate Achieved:", value = 150, min = 60, max = 220),
      selectInput("exang", "Exercise Induced Angina:", choices = c("No" = "0", "Yes" = "1")),
      numericInput("oldpeak", "Oldpeak (ST depression):", value = 1, min = 0, max = 6),
      selectInput("slope", "Slope of Peak Exercise ST Segment:", choices = c("Up" = "1", "Flat" = "0", "Down" = "2")),
      selectInput("ca", "Number of Major Vessels Colored by Fluoroscopy:", choices = c("0", "1", "2", "3", "4")),
      selectInput("thal", "Thalassemia:", choices = c("Normal" = "0", "Fixed Defect" = "1", "Reversible Defect" = "2", "Unknown" = "3")),
      actionButton("predict", "Predict")
    ),

    mainPanel(
      verbatimTextOutput("prediction")
    )
  )
)

# Define the server logic
server <- function(input, output) {
  # Load the pre-trained model
  rf_model <- readRDS("models/heart_disease_rf_model.rds")

  # Define means and standard deviations for standardization
  means <- c(age = 54, trestbps = 130, chol = 240, thalach = 150, oldpeak = 1)
  sds <- c(age = 6.5, trestbps = 20, chol = 50, thalach = 20, oldpeak = 1)

  # Define correct levels for factors
  levels_list <- list(
    sex = c("0", "1"),
    cp = c("0", "1", "2", "3"),
    fbs = c("0", "1"),
    restecg = c("0", "1", "2"),
    exang = c("0", "1"),
    slope = c("0", "1", "2"),
    ca = c("0", "1", "2", "3", "4"),
    thal = c("0", "1", "2", "3")
  )

  new_data <- reactive({
    req(input$predict)

    # Create a data frame with user input
    data <- data.frame(
      age = input$age,
      sex = as.factor(input$sex),
      cp = as.factor(input$cp),
      trestbps = input$trestbps,
      chol = input$chol,
      fbs = as.factor(input$fbs),
      restecg = as.factor(input$restecg),
      thalach = input$thalach,
      exang = as.factor(input$exang),
      oldpeak = input$oldpeak,
      slope = as.factor(input$slope),
      ca = as.factor(input$ca),
      thal = as.factor(input$thal),
      stringsAsFactors = TRUE
    )

    # Ensure factor levels match those in the training data
    for (var in names(levels_list)) {
      data[[var]] <- factor(data[[var]], levels = levels_list[[var]])
    }

    # Standardize numerical data
    numeric_features <- c("age", "trestbps", "chol", "thalach", "oldpeak")
    data[numeric_features] <- scale(data[numeric_features], center = means[numeric_features], scale = sds[numeric_features])

    # Print the data frame for debugging
    print(data)

    return(data)
  })

  output$prediction <- renderText({
    req(new_data())

    # Check if new_data is not empty
    if (nrow(new_data()) == 0) {
      return("Error: No data available for prediction.")
    }

    # Make predictions
    predictions <- predict(rf_model, new_data())

    # Convert prediction to a human-readable format
    result <- if (predictions == "1") "Heart Attack" else "No Heart Attack"

    paste("Predicted Risk of Heart Attack:", result)
  })
}

# Run the application
shinyApp(ui = ui, server = server)
