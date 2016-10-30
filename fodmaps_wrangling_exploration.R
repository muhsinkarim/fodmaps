##### Fodmaps data wrangling
# Wrangling and exploratory data analysis


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


### Select and rename columns by Date

dfF.date <- dfFoods %>%
    select(Date, 
           Food = Food.Ingredient)
dfF.date <- unique(dfF.date)

dfS.date <- dfSymptoms %>%
    select(Date,
           Symptoms)
dfS.date <- unique(dfS.date)


### Merge by Date

df.date <- left_join(dfF.date, dfS.date, by = "Date")
df.date$Symptoms[is.na(df.date$Symptoms)] <- 0 # Impute 0
df.date <- df.date[order(df.date$Date), ]

## Save
setwd("C:/Users/Muhsin Karim/Documents/GitHub/fodmaps")
write.csv(df.date, file = "merged.csv", row.names = F)


### Set days to count back

daysBack <- 1


### Get good foods

## Get dates when there were no symptoms
datesGood <- unique(df.date$Date[which(df.date$Symptoms == 0)])

## Get previous dates within a range
datesPrevious <- datesGood - daysBack

## Get all foods the previous day
goodFoods <- ""
for (i in 1:length(datesPrevious)) {
    
    ## Get dates in between excluding day of symptom watch
    datesBetween <- seq(datesPrevious[i], datesGood[i], "days")
    datesBetween <- datesBetween[!datesBetween %in% datesGood[i]]
    
    ## Subset data frame based on date range
    addFoods <- unique(df.date$Food[df.date$Date %in% datesBetween])
    goodFoods <- c(goodFoods, addFoods)
}

goodFoods <- unique(goodFoods)
goodFoods <- goodFoods[-1]


### Get bad foods

## Get dates when there were symptoms
datesBad <- unique(df.date$Date[which(df.date$Symptoms == 1)])

## Get previous dates within a range
datesPrevious <- datesBad - daysBack

## Get all foods the previous day
badFoods <- ""
for (i in 1:length(datesPrevious)) {
    
    ## Get dates in between excluding day of symptom watch
    datesBetween <- seq(datesPrevious[i], datesBad[i], "days")
    datesBetween <- datesBetween[!datesBetween %in% datesBad[i]]
    
    ## Subset data frame based on date range
    addFoods <- unique(df.date$Food[df.date$Date %in% datesBetween])
    badFoods <- c(badFoods, addFoods)
}

badFoods <- unique(badFoods)
badFoods <- badFoods[-1]


### Identify really bad foods

## Examine badFoods with any goodFoods removed
reallyBadFoods <- sort(setdiff(badFoods, goodFoods))
reallyBadFoods


### Get dates when you consumed the really bad foods

min(df.date$Date); max(df.date$Date) 
sort(unique(df.date$Date[which(df.date$Food %in% reallyBadFoods)]))
sort(table(weekdays(sort(unique(df.date$Date[which(df.date$Food %in% reallyBadFoods)])))), decreasing = T)


### Create and save Food and Symptoms datetimes

## Select columns and rename
dfF <- dfFoods %>%
    select(Datetime,
           Item = Food.Ingredient)

dfS <- dfSymptoms %>%
    select(Datetime,
           Item = Symptoms)

## Rename Symptom flag
dfS$Item <- "INTOLERANCE SYMPTOMS"

## Datetimes

## Bind
dfEvents <- rbind.data.frame(dfF, dfS)
dfEvents <- dfEvents[order(dfEvents$Datetime), ]

## Save
setwd("C:/Users/Muhsin Karim/Documents/GitHub/fodmaps")
write.csv(dfEvents, file = "events.csv", row.names = F)




#--------------------------------------------------------------------------------------------------
### Calendar plots example
# https://www.r-bloggers.com/calendar-charts-with-googlevis/

stock <- "MSFT"
start.date <- "2012-01-01"
end.date <- Sys.Date()
quote <- paste("http://ichart.finance.yahoo.com/table.csv?s=",
               stock,
               "&a=", substr(start.date,6,7),
               "&b=", substr(start.date, 9, 10),
               "&c=", substr(start.date, 1,4), 
               "&d=", substr(end.date,6,7),
               "&e=", substr(end.date, 9, 10),
               "&f=", substr(end.date, 1,4),
               "&g=d&ignore=.csv", sep="")             
stock.data <- read.csv(quote, as.is=TRUE)
stock.data$Date <- as.Date(stock.data$Date)
## Uncomment the next 3 lines to install the developer version of googleVis
# install.packages(c("devtools","RJSONIO", "knitr", "shiny", "httpuv"))
# library(devtools)
# install_github("mages/googleVis")
library(googleVis)
plot( 
    gvisCalendar(data=stock.data, datevar="Date", numvar="Adj.Close",
                 options=list(
                     title="Calendar heat map of MSFT adjsuted close",
                     calendar="{cellSize:10,
                     yearLabel:{fontSize:20, color:'#444444'},
                     focusedCellColor:{stroke:'red'}}",
                     width=590, height=320),
                 chartid="Calendar")
)
