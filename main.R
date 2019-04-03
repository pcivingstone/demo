# main.R
# written by Paul
# to call all the other scripts in turn
# get some data, clean it, draw some plots, train a model
# last updated: April 2019

# initialise --------------------------------------------------------------
# clean up the workspace, call libraries and declare custom functions
source('scripts/setup.R', T)

# config ------------------------------------------------------------------
# put all the input settings into a single list
source('scripts/config.R', T)

# get data ----------------------------------------------------------------
# get the source data from where it is
# moving this code into a script or function, allows someone else to
# work on it, push code to git, without blocking other people
source('scripts/getData.R', T)

# clean data --------------------------------------------------------------
source('scripts/cleanData.R', T)

# eda ---------------------------------------------------------------------

if (F) {
  qplot(year, ave, data = sample_n(myData, 1e3), size = ab)
  qplot(year, response, data = myData, geom = 'smooth')
  qplot(ab, ave, data = sample_n(myData, 1e3), col = year)
  qplot(
    ab, r
    , data = sample_n(myData, 1e3)
    , col = year
    # , log = 'xy'
    )
  qplot(
    team
    , response
    # , data = sample_n(myData, 1e3)
    , data = myData
    , geom = 'boxplot'
    )
  }

# build simple model ------------------------------------------------------

summary(model <- lm(response ~ poly(year,2) + team, data = myData ))

myCoefs <- summary(model)$coef

myCoefs <- tail(myCoefs, -3)
myCoefs <- head(myCoefs, 10)

coefplot(myCoefs[,1], myCoefs[, 2], varnames = rownames(myCoefs))
grid()


# build complex model -----------------------------------------------------
# now build a better model, perhaps using xgb

# store the output, save the model for scoring future data
# send an email to notify users / developers that the script has finished
# store model evaluation (RMSE, AUC, time, number of records, etc.) for future referenc




