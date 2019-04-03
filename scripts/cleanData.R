# cleanData.R

naPlot(myData)

# numerics ----------------------------------------------------------------
# integers, replace NAs with 0
# could use tidyr::replace_na() if we needed different replacements for different columns
# for example, some 0, some 1, some mean(column) or median(column)
for(colNum in grep('integer', sapply(myData, class)))
  set(
    myData
    , i = which(is.na(myData[[colNum]]))
    , j = colNum
    , value = 0
  )

# character ---------------------------------------------------------------
# character to factor
for(colNum in grep('character', sapply(myData, class)))
  set(
    myData
    , j = colNum
    , value = myData[[colNum]] %>% fct_explicit_na %>% fct_infreq
  )
# there aren't any NAs, so no need for explicit na
# usually use fct_lump to group together small levels, but can't do that with player id

naPlot(myData)


# feature engineering -----------------------------------------------------

?baseball
myData <- subset(myData, subset = ab > 0)  # only those playerXyear who batted
myData <- subset(myData, subset = r <= ab)  # don't understand how you could have more runs than times at bat

myData[, ave := r / ab] # runs / times at bat

myData[, response := logit((r+1)/(ab+2))]    # transformed

if (config$showPlots)
  hist(myData$response)
