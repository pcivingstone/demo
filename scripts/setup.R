# setup.R

# clean up workspace ------------------------------------------------------
if (interactive()) {
  rm(list = ls())
  graphics.off()
  cat('\014')
}

# libraries ---------------------------------------------------------------
library(data.table)
library(lubridate)
library(ggplot2)
library(dplyr)
library(corrplot)
library(forcats)
library(boot)
library(arm)

# custom functions --------------------------------------------------------
for (filename in list.files(path = 'functions/', pattern = '*.R', full.names = T))
  source(filename, local = T)

