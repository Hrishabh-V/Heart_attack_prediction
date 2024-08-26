# Install necessary packages
install.packages(c("tidyverse", "caret", "e1071", "randomForest", "caTools", "rmarkdown", "shiny", "shinythemes", "ggplot2", "plotly", "DMwR2"))

# Load libraries
library(tidyverse)
library(caret)
library(e1071)
library(randomForest)
library(caTools)
library(rmarkdown)
library(shiny)
library(shinythemes)
library(ggplot2)
library(plotly)
library(DMwR2)  # For imputation
library(pROC)
library(corrplot)

# Read data
heart_data <- read.csv("data/heart.csv")

# Summary of data
str(heart_data)
summary(heart_data)
anyNA(heart_data)

# Convert categorical data to factors
heart_data$sex <- as.factor(heart_data$sex)
heart_data$cp <- as.factor(heart_data$cp)
heart_data$restecg <- as.factor(heart_data$restecg)
heart_data$slope <- as.factor(heart_data$slope)
heart_data$thal <- as.factor(heart_data$thal)
heart_data$fbs <- as.factor(heart_data$fbs)
heart_data$exang <- as.factor(heart_data$exang)
heart_data$ca <- as.factor(heart_data$ca)

# Add additional feature for age groups (for exploratory analysis only)
heart_data$age_group <- cut(heart_data$age, breaks = c(29, 39, 49, 59, 69, 79), labels = c("30-39", "40-49", "50-59", "60-69", "70-79"))

# Standardize numerical data (mean 0, std dev 1)
numeric_features <- c("age", "trestbps", "chol", "thalach", "oldpeak")
preProcValues <- preProcess(heart_data[, numeric_features], method = c("center", "scale"))
heart_data[numeric_features] <- predict(preProcValues, heart_data[, numeric_features])

# Exploratory Data Analysis (EDA)

# Visualize age distribution
ggplot(heart_data, aes(x = age, fill = as.factor(target))) +
  geom_histogram(binwidth = 5, alpha = 0.7, position = "identity") +
  labs(title = "Age Distribution by Heart Disease", x = "Age", y = "Frequency", fill = "Heart Disease") +
  theme_minimal()

# Correlation matrix
cor_matrix <- cor(heart_data[, numeric_features])
corrplot(cor_matrix, method = "color", title = "Correlation Matrix")

# Cholesterol levels
ggplot(heart_data, aes(x = chol, fill = as.factor(target))) +
  geom_density(alpha = 0.5) +
  labs(title = "Cholesterol Levels by Heart Disease", x = "Cholesterol Level", y = "Density") +
  theme_minimal()

# Model Development
set.seed(123)  # For reproducibility

# Create a training/test split
splitIndex <- createDataPartition(heart_data$target, p = 0.8, list = FALSE)
train_data <- heart_data[splitIndex, ]
test_data <- heart_data[-splitIndex, ]

# Check for missing values in training data
sum(is.na(train_data))
sum(is.na(test_data))

# Impute missing values with median for numeric variables
train_data <- centralImputation(train_data)
test_data <- centralImputation(test_data)  # Also apply to test_data

# Verify imputation
sum(is.na(train_data))
sum(is.na(test_data))

# Ensure target is a factor
train_data$target <- as.factor(train_data$target)
test_data$target <- as.factor(test_data$target)

# Exclude 'age_group' from the training data
train_data_no_age_group <- train_data %>%
  select(-age_group)

test_data_no_age_group <- test_data %>%
  select(-age_group)

# Train Logistic Regression model
logit_model <- train(target ~ ., data = train_data_no_age_group, method = "glm", family = "binomial")

# Train Decision Tree model
tree_model <- train(target ~ ., data = train_data_no_age_group, method = "rpart")

# Train Random Forest model
rf_model <- train(target ~ ., data = train_data_no_age_group, method = "rf")

# Save the model
saveRDS(rf_model, "models/heart_disease_rf_model.rds")

# Predictions and evaluation
logit_predictions <- predict(logit_model, test_data_no_age_group)
tree_predictions <- predict(tree_model, test_data_no_age_group)
rf_predictions <- predict(rf_model, test_data_no_age_group)

# Confusion matrices
confusionMatrix(logit_predictions, test_data_no_age_group$target)
confusionMatrix(tree_predictions, test_data_no_age_group$target)
confusionMatrix(rf_predictions, test_data_no_age_group$target)

# Collect performance metrics
model_results <- resamples(list(Logistic = logit_model, Tree = tree_model, RandomForest = rf_model))
summary(model_results)

# Feature importance for Random Forest
importance <- varImp(rf_model, scale = FALSE)
print(importance)

# Logistic Regression ROC
logit_probs <- predict(logit_model, test_data_no_age_group, type = "prob")[,2]
roc_logit <- roc(test_data_no_age_group$target, logit_probs)
plot(roc_logit, main = "ROC Curve - Logistic Regression")

# Random Forest ROC
rf_probs <- predict(rf_model, test_data_no_age_group, type = "prob")[,2]
roc_rf <- roc(test_data_no_age_group$target, rf_probs)
plot(roc_rf, add = TRUE, col = "red")

# Legend
legend("bottomright", legend = c("Logistic Regression", "Random Forest"), col = c("black", "red"), lwd = 2)

