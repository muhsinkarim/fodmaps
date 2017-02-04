##### Fodmaps data wrangling to get food dairy
# Wrangling and exploratory data analysis


### Libraries
suppressPackageStartupMessages(library(dplyr))


### Load data

setwd("C:/Users/Muhsin Karim/Documents/GitHub/fodmaps")
dfFoods <- read.csv(file = "Foods.csv", header = T, stringsAsFactors = F)
dfSymptoms <- read.csv(file = "Symptoms.csv", header = T, stringsAsFactors = F)
dfSleepyPills <- read.csv(file = "Sleepy pills.csv", header = T,  stringsAsFactors = F)


### Format

## Date
dfFoods$Date <- as.Date(dfFoods$Datetime, format = "%d/%m/%Y")
dfSymptoms$Date <- as.Date(dfSymptoms$Datetime, format = "%d/%m/%Y")
dfSleepyPills$Date <- as.Date(dfSleepyPills$Datetime, format = "%d/%m/%Y")

## Datetime
dfFoods$Datetime <- as.POSIXct(dfFoods$Datetime, format = "%d/%m/%Y %H:%M:%S")
dfSymptoms$Datetime <- as.POSIXct(dfSymptoms$Datetime, format = "%d/%m/%Y %H:%M:%S")
dfSleepyPills$Datetime <- as.POSIXct(dfSleepyPills$Datetime, format = "%d/%m/%Y %H:%M:%S")

## Boolean
#dfFoods$Fibre[which(dfFoods$Fibre == "true")] <- TRUE
#dfFoods$Fibre[which(dfFoods$Fibre == "false")] <- FALSE
#dfFoods$Enzymes[which(dfFoods$Enzymes == "true")] <- TRUE
#dfFoods$Enzymes[which(dfFoods$Enzymes == "false")] <- FALSE
dfFoods$Challenge[which(dfFoods$Challenge == "true")] <- TRUE
dfFoods$Challenge[which(dfFoods$Challenge == "false")] <- ""
#dfFoods$Fibre <- as.logical(dfFoods$Fibre)
#dfFoods$Enzymes <- as.logical(dfFoods$Enzymes)
#dfFoods$Challenge <- as.logical(dfFoods$Enzymes)


# Arrange data for food dairy----------------------------------------------------------------------

### Include blank rows

dfFoods$Symptoms <- ""    

dfSymptoms$Food.Ingredient <- ""
dfSymptoms$Challenge <- ""


### Select columns

dfFoods <- dfFoods %>%
    select(Datetime,
           Date,
           Food.Ingredient,
           Challenge,
           Symptoms)

dfSymptoms <- dfSymptoms %>%
    select(Datetime,
           Date,
           Food.Ingredient,
           Challenge,
           Symptoms)


### Bind Food and Symptoms

food_dairy <- rbind.data.frame(dfFoods, dfSymptoms)

## Sort by Datetime
food_dairy <- food_dairy[order(food_dairy$Datetime), ]

## Remove rows
food_dairy <- food_dairy[which(food_dairy$Date >= "2016-10-25"), ]


### Save as xlsx

library(xlsx)

write.xlsx(food_dairy, file = "food_dairy.xlsx", row.names = FALSE)
