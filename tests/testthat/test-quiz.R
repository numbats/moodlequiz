test_that("run examples", {
  ex_scatter <- "../../inst/examples/draw-scatterplots.Rmd"
  rmarkdown::render(ex_scatter)

})
