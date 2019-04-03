# metar.R
# written by Paul
# to read in the supplied METAR data
# do some text processing 
# count up the proportion of clear days at various US airport locations
# and provide the top 20 and bottom 20
# last updated Apr 2019

# setup -------------------------------------------------------------------
rm(list=ls());gc()
graphics.off()
cat('\014')

sink(file = 'output.log')
print(startedAt <- Sys.time())

# libraries ------------------------------------------------------------
library(data.table)
# library(plyr)
library(stringr)

# config ------------------------------------------------------------------
config <- list(
  N = 1e5  # number of rows, much quicker during development
  # N = 1e6  # number of rows
  # N = -1L  # number of rows, complete set of data
)

# get data ----------------------------------------------------------------
cloudCodes <- fread('tables/lookupTables.txt')[[1]]

message('Getting raw data...')
# myData <- fread('c://Downloads/metar_export.zip', nrows = 1e3)
myData <- fread(
  'sourceData/metar_export.txt'  # this file is not included in the repo
  , nrows = config$N
  , header = F
  )

str(myData)

# basics ------------------------------------------------------------------
message('Basics...')
setnames(myData, names(myData), c('dateTime','string'))
# head(myData, 10)
# head(myData$string, 10)
myData[, date := as.IDate( dateTime)]
diff(range(myData$date))
myData[, time := as.ITime(substr(dateTime, 12, 19))]
myData[, rowNum := .I]

myData[, dayLight := between(time, as.ITime('06:00:00'), as.ITime('18:00:00'))]  # approximation of daylight hours only

prop.table(table(myData$dayLight))
tables()

myData <- myData[dayLight == TRUE]  # reduce this now to save time and memory in next step
tables()

# split string ----------------------------------------------------
message('String processing...')
x <- myData[,tstrsplit(string, split = ' ')]
x[, rowNum := myData$rowNum]

x2 <- melt(x, id.vars = 'rowNum', na.rm = T)  # wide to long
rm(x);gc()  # clean up some memory, x is a large object

setorder(x2, rowNum)

x2[, type := '']
table(x2$type)
x2[variable == 'V1', type := 'location']  # 1 per rowNum
table(x2$type)
x2[variable == 'V2', type := 'ddHHmm']    # 1 per rowNum
table(x2$type)
# x2[value == 'AUTO', type := 'auto']       # < 1 per rowNum
# table(x2$type)
x2[value %like% 'KT$' & variable != 'V1', type := 'wind'] # almost 1 per rowNum
table(x2$type)
x2[value %like% 'SM$' & variable != 'V1', type := 'visibility']  # almost 1 per rowNum
table(x2$type)
x2[substr(value,1,3) %chin% cloudCodes, type := 'cloud']  # > 1 per rowNum
# this should also catch any VV, even though it is only 2 characters long
table(x2$type)

tables()
x2 <- x2[type != '']
tables()

# cloud -------------------------------------------------------------------
message('Cloud data...')
cloudData <- x2[ type == 'cloud']

cloudData[, code := substr(value, 1,3)]
cloudData[, heightChar := substr(value, 4, 6)]  # approximation only, there are exceptions
cloudData[grep('[^0123456789]', heightChar), heightChar := '999']  # make them big, rather than small
cloudData[, height := as.numeric(heightChar)]

cloudData[, lowCeiling := 0]  # default to good
cloudData[ code %chin% c('BKN','OVC') & height < 30, lowCeiling := 1]  # explicitly set those bad
# small number of records with no identifiable records with type='cloud' will be set to lowCeiling=0

tables()

# merge -------------------------------------------------------------------
message('Merging...')

myData[, string := NULL]

myData <- merge(
  myData
  , x2[ type == 'location', .(rowNum, location = value)]
  , by = 'rowNum', all.x = T, all.m = F
  )

myData <- merge(
  myData, x2[ type == 'ddHHmm', .(rowNum, ddHHmm = value)]
  , by = 'rowNum', all.x = T, all.y = F
  )

# myData <- merge(
#   myData, x2[ type == 'auto', .(rowNum, auto = value)]
#   , by = 'rowNum', all.x = T, all.y = F
# )

myData <- merge(
  myData, x2[ type == 'wind', .(rowNum, wind = value)]
  , by = 'rowNum', all.x = T, all.y = F
)

myData <- merge(
  myData, x2[ type == 'visibility', .(rowNum, visibility = value)]
  , by = 'rowNum', all.x = T, all.y = F
)

myData <- merge(
  myData
  ,cloudData[, .(lowCeiling = max(lowCeiling)), by = .(rowNum)]
  , by = 'rowNum', all.x = T, all.y = F
)

tables()
rm(x2, cloudData)
gc()
tables()

# derived -----------------------------------------------------------------
message('Derived...')
myData[, windSpeedChar := str_sub(wind, -4, -3)]  # catches most cases
myData[grep('[^0123456789]', windSpeedChar), windSpeedChar := '99']  # make them big, rather than small, conservative
myData[, windSpeedNum := as.numeric(str_sub(windSpeedChar, -2, -1))]

myData[, visDistChar := str_sub(visibility, end = -3)]
myData[grep('[^0123456789]', visDistChar), visDistChar := '01']  # make them small, rather than big, conservative
# myData[ visDistChar %like% '/', visDistChar := '1']
myData[, visDistNum := as.numeric(visDistChar)]

myData[, good := 0]  # good weather flag, default to bad weather
myData[ windSpeedNum < 15 & visDistNum >= 10 & lowCeiling == 0, good := 1]  # flag those that are good

# aggregate ---------------------------------------------------------------
# by location by date

byLocDay <- myData[
  , .(
    records = .N
    ,good = mean(good)
    )
  , by = .(location, date)
  ]
print(byLocDay)
saveRDS(byLocDay, file = 'output/byLocDay.rds')

# by location
byLoc <- byLocDay[
  ,.(
    minDay = min(date)
    ,maxDay = max(date)
    ,numDays = max(date) - min(date)+1
    ,numRecords = sum(records)
    ,recsPerDay = mean(records)
    ,meanGood = mean(good)
  )
  , by = .(location)
  ]
print(byLoc)

setorder(byLoc, -meanGood)
print(byLoc)

head(byLoc, 20)
tail(byLoc, 20)

saveRDS(byLoc, file = 'output/byLoc.rds')
write.csv(byLoc, file = 'output/byLoc.csv', row.names = F)

print(timetaken(started.at = startedAt))
message('Successful completion!')
sink()
