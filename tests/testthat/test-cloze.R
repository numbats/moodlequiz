library(testthat)

test_that("cloze_shortanswer generates correct output", {
  # Test with a single correct answer, case insensitive
  expect_equal(
    cloze_shortanswer(c("Canberra" = 100), case_sensitive = FALSE),
    "`{100:SHORTANSWER:%100%Canberra#}`{=html}"
  )

  # Test with multiple correct answers, case insensitive
  expect_equal(
    cloze_shortanswer(c("Canberra" = 100, "canberra" = 100), case_sensitive = FALSE),
    "`{100:SHORTANSWER:%100%Canberra#~%100%canberra#}`{=html}"
  )

  # Test with case sensitivity enabled
  expect_equal(
    cloze_shortanswer(c("Canberra" = 100), case_sensitive = TRUE),
    "`{100:SHORTANSWER_C:%100%Canberra#}`{=html}"
  )

  # Test with missing correct answer
  expect_error(
    cloze_shortanswer(c("Sydney" = 0)),
    "At least one correct answer with mark value 1.*must be specified"
  )
})

test_that("cloze_multichoice generates correct output", {
  # Test with vertical layout
  expect_equal(
    cloze_multichoice(c("4" = 100, "3" = 0, "5" = 0), type = "vertical"),
    "`{100:MULTIRESPONSE:%100%4#~%0%3#~%0%5#}`{=html}"
  )

  # Test with horizontal layout
  expect_equal(
    cloze_multichoice(c("4" = 100, "3" = 0, "5" = 0), type = "horizontal"),
    "`{100:MULTIRESPONSE_H:%100%4#~%0%3#~%0%5#}`{=html}"
  )

  # Test with shuffling enabled
  expect_equal(
    cloze_multichoice(c("4" = 100, "3" = 0, "5" = 0), shuffle = TRUE),
    "`{100:MULTIRESPONSE_S:%100%4#~%0%3#~%0%5#}`{=html}"
  )

  # Test with no correct answer
  expect_error(
    cloze_multichoice(c("3" = 0, "5" = 0)),
    "At least one correct answer with mark value 1.*must be specified"
  )
})

test_that("cloze_singlechoice generates correct output", {
  # Test with dropdown layout
  expect_equal(
    cloze_singlechoice(c("2" = 100, "1" = 0, "3" = 0), type = "dropdown"),
    "`{100:MULTICHOICE:%100%2#~%0%1#~%0%3#}`{=html}"
  )

  # Test with vertical layout
  expect_equal(
    cloze_singlechoice(c("2" = 100, "1" = 0, "3" = 0), type = "vertical"),
    "`{100:MULTICHOICE_V:%100%2#~%0%1#~%0%3#}`{=html}"
  )

  # Test with shuffling enabled
  expect_equal(
    cloze_singlechoice(c("2" = 100, "1" = 0, "3" = 0), shuffle = TRUE),
    "`{100:MULTICHOICE_S:%100%2#~%0%1#~%0%3#}`{=html}"
  )

  # Test with no correct answer
  expect_error(
    cloze_singlechoice(c("1" = 0, "3" = 0)),
    "At least one correct answer with mark value 1.*must be specified"
  )
})

test_that("cloze_numerical generates correct output", {
  # Test with exact match
  expect_equal(
    cloze_numerical(5, weight = 1, tolerance = 0),
    "`{1:NUMERICAL:=5.000000:0.000000#}`{=html}"
  )

  # Test with tolerance
  expect_equal(
    cloze_numerical(5, weight = 2, tolerance = 0.1),
    "`{2:NUMERICAL:=5.000000:0.100000#}`{=html}"
  )
})

test_that("choices function works as expected", {
  # Test valid choices
  expect_equal(
    choices(c("A", "B", "C"), c("A", "C")),
    c(A = 1, B = 0, C = 1)
  )

  # Test with no correct answer
  expect_error(
    choices(c("A", "B", "C"), "D"),
    "The correct answer does not exist in the provided options"
  )
})

test_that("cloze dispatch works correctly", {
  # Test numeric dispatch
  expect_equal(
    cloze(5, tolerance = 0.1),
    "`{1:NUMERICAL:=5.000000:0.100000#}`{=html}"
  )

  # Test character dispatch (short answer)
  expect_equal(
    cloze("Canberra"),
    "`{1:SHORTANSWER:%100%Canberra#}`{=html}"
  )

  # Test character dispatch (multiple choice)
  expect_equal(
    cloze(c("4", "5"), choices = c("4", "5", "6")),
    "`{1:MULTIRESPONSE:%100%4#~%100%5#~%0%6#}`{=html}"
  )

  # Test character dispatch (single choice)
  expect_equal(
    cloze("4", choices = c("4", "5", "6"), weight = 3),
    "`{3:MULTICHOICE:%100%4#~%0%5#~%0%6#}`{=html}"
  )
})
