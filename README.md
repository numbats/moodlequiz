
<!-- README.md is generated from README.Rmd. Please edit that file -->

# moodlequiz

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The `moodlequiz` R package is an alternative interface to produce the
Moodle XML files via the `exams` package.

## Installation

You can install the development version of moodlequiz like so:

``` r
remotes::install_github("emitanaka/moodlequiz")
```

## Example

Below is a Moodle quiz where the students have to select the right
variables from the data to map onto the plot aesthetics in `ggplot2`.

<img src="man/quiz-screenshot.png" style="border:1px solid black;" />

The above quiz is created from the R Markdown document below. Knitting
the document below will generate 5 different versions of the quiz where
the x, y, color, and size are mapped randomly to one of the variables in
the `mtcars` data.

    ---
    output: moodlequiz::teachr_cloze
    title: Drawing a scatterplot
    times: 5
    topic: datavis
    ---

    ```{r set-up, include = FALSE}
    library(tidyverse)
    library(rlang)
    knitr::opts_chunk$set(echo = FALSE,
                          results = "hide",
                          fig.height = 4, 
                          fig.width = 5,
                          fig.path = "",
                          fig.cap = "",
                          fig.align = "center")
    library(teachr)
    library(exams)
    ```
    ```{r data}
    cols <- colnames(mtcars)
    cats <- c("cyl", "vs", "am", "gear", "carb")
    nums <- setdiff(cols, cats)
    x <- sample(nums, 1)
    y <- sample(setdiff(nums, x), 1)
    color <- sample(cats, 1)
    size <- sample(setdiff(nums, c(x, y)), 1)
    ```



    You have been asked to analyse the `mtcars` data. The variables and the class types of the data is shown below.

    ```{r, echo = TRUE, results = "show"}
    str(mtcars)
    ```

    As a starting point, you decide to draw a scatter plot for some variables. Complete the code below to get the target plot below:

    ```r
    ggplot(mtcars, aes(x = `cloze schoice(cols, x)`, 
                       y = `cloze schoice(cols, y)`,
                       color = factor(`cloze schoice(cols, color)`),
                       size = `cloze schoice(cols, size)`)) +
        `cloze schoice(ls(envir = as.environment("package:ggplot2"), pattern = "^geom_"), "geom_point")`()
    ```

    ```{r, results = "show"}
    ggplot(mtcars, aes(!!sym(x), !!sym(y), size = !!sym(size), color = factor(!!sym(color)))) + 
      geom_point() +
      theme(plot.background = element_rect(color = "black"))
    ```
