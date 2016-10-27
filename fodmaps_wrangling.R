##### Fodmaps data wrangling


### Libraries
library(dplyr)


### Load data

setwd("C:/Users/Muhsin Karim/Documents/GitHub/fodmaps")
dfFoods <- read.csv(file = "Foods.csv", header = T, stringsAsFactors = F)
dfSymptoms <- read.csv(file = "Symptoms.csv", header = T, stringsAsFactors = F)
dfSleepyPills <- read.csv(file = "Sleepy pills.csv", header = T,  stringsAsFactors = F)


### Format

# # Datetime
# dfFoods$Datetime <- strptime(dfFoods$Datetime,"%d/%m/%Y %H:%M:%S", tz="GMT")
# dfSymptoms$Datetime <- strptime(dfSymptoms$Datetime,"%d/%m/%Y %H:%M:%S", tz="GMT")
# dfSleepyPills$Datetime <- strptime(dfSleepyPills$Datetime,"%d/%m/%Y %H:%M:%S", tz="GMT")

## Date
dfFoods$Date <- as.Date(dfFoods$Datetime, format = "%d/%m/%Y")
dfSymptoms$Date <- as.Date(dfSymptoms$Datetime, format = "%d/%m/%Y")
dfSleepyPills$Date <- as.Date(dfSleepyPills$Datetime, format = "%d/%m/%Y")

## Boolean
dfFoods$Fibre[which(dfFoods$Fibre == "true")] <- TRUE
dfFoods$Fibre[which(dfFoods$Fibre == "false")] <- FALSE
dfFoods$Enzymes[which(dfFoods$Enzymes == "true")] <- TRUE
dfFoods$Enzymes[which(dfFoods$Enzymes == "false")] <- FALSE
dfFoods$Fibre <- as.logical(dfFoods$Fibre)
dfFoods$Enzymes <- as.logical(dfFoods$Enzymes)

## Flag outcome
dfSymptoms$Symptoms <- 1


### Select and rename columns

dfFoods <- dfFoods %>%
    select(Date, 
           Food = Food.Ingredient,
           Fibre)
dfSymptoms <- dfSymptoms %>%
    select(Date,
           Symptoms)


### Merge by Date


