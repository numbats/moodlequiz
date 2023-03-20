# Valid answer types: multichoice|truefalse|shortanswer|matching|cloze|essay|numerical|description

#' @export
answer_shortanswer <- function(options, weight = max(options), feedback = ifelse(options == weight, "Correct", ifelse(options == 0, "Incorrect", "Partially correct"))) {
  sprintf(
    "{%i:SHORTANSWER:%s}",
    weight,
    paste0("%", options/weight*100, "%", names(options), "#", feedback, collapse = "~")
  )
}

#' @export
answer_multichoice <- function(options, weight = max(options), feedback = ifelse(options == weight, "Correct", ifelse(options == 0, "Incorrect", "Partially correct"))) {
  sprintf(
    "{%i:MULTIRESPONSE:%s}",
    weight,
    paste0("%", options/weight*100, "%", names(options), "#", feedback, collapse = "~")
  )
}
#' @export

answer_singlechoice <- function(options, weight = max(options), feedback = ifelse(options == weight, "Correct", ifelse(options == 0, "Incorrect", "Partially correct"))) {
  sprintf(
    "{%i:MULTICHOICE:%s}",
    weight,
    paste0("%", options/weight*100, "%", names(options), "#", feedback, collapse = "~")
  )
}

#' @export
answer_numerical <- function(correct, weight = 1, tolerance = 0, feedback = sprintf("Correct, %f is the correct answer.", correct)) {
  # Add alternative solutions / thresholds
  sprintf(
    "{%i:NUMERICAL:=%f:%f#%s}",
    weight, correct, tolerance, correct_feedback
  )
}
