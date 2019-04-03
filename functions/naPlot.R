# naPlot.R

naPlot <- function(df) {
  dotchart(sort(apply(is.na(df), 2, mean)))
  grid()
}