test_that("Moodlequiz format", {
  expect_message(rmarkdown::render("documents/quiz.Rmd", output_file = quiz_xml <- tempfile()), "Output created")
})
