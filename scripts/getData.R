# getData.R

# usually this script would be more complicated
# it might connect to a database and run several queries
# it could merge them remotely or extract them and do some data munging locally
# or it might just grab a csv file from some local folder

myData <- copy(plyr::baseball)
setDT(myData)

if (config$verbose){
  glimpse(myData)
  print(head(myData))
}

if (config$showPlots) {
  naPlot(myData)
  mat <- cor(myData[, 6:17], use = 'pairwise.complete.obs')
  corrplot(
    mat
    ,method = 'ellipse'
    ,diag = F
    ,addCoef.col = 'grey'
  )
}


