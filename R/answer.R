# Valid answer types: multichoice|truefalse|shortanswer|matching|cloze|essay|numerical|description

#' @export
answer_shortanswer <- function(
    options, weight = max(options),
    feedback = ifelse(options == weight, "Correct", ifelse(options == 0, "Incorrect", "Partially correct")),
    case_sensitive = FALSE) {
  # Validate an answer is provided
  options <- options/weight*100
  if(!any(options == 100)) stop("At least one correct answer with mark value 1 (or more) must be specified for a short answer question.")
  sprintf(
    "`{%i:SHORTANSWER%s:%s}`{=html}",
    weight,
    if(case_sensitive) "_C" else "",
    paste0("%", options, "%", names(options), "#", feedback, collapse = "~")
  )
}

#' @export
answer_multichoice <- function(
    options, weight = max(options),
    feedback = ifelse(options == weight, "Correct", ifelse(options == 0, "Incorrect", "Partially correct")),
    type = c("vertical", "horizontal"),
    shuffle = FALSE) {
  # Validate an answer is provided
  options <- options/weight*100
  if(!any(options == 100)) stop("At least one correct answer with mark value 1 (or more) must be specified for a multiple choice question.")

  type <- match.arg(type)
  sprintf(
    "`{%i:MULTIRESPONSE%s%s%s:%s}`{=html}",
    weight,
    if(shuffle || type != "vertical") "_" else "",
    switch(type, vertical = "", horizontal = "H"),
    if(shuffle) "S" else "",
    paste0("%", options, "%", names(options), "#", feedback, collapse = "~")
  )
}
#' @export

answer_singlechoice <- function(
    options, weight = max(options),
    feedback = ifelse(options == weight, "Correct", ifelse(options == 0, "Incorrect", "Partially correct")),
    type = c("dropdown", "vertical", "horizontal"),
    shuffle = FALSE) {
  # Validate an answer is provided
  options <- options/weight*100
  if(!any(options == 100)) stop("At least one correct answer with mark value 1 (or more) must be specified for a single choice question.")

  type <- match.arg(type)
  sprintf(
    "`{%i:MULTICHOICE%s%s:%s}`{=html}",
    weight,
    switch(type, dropdown = "", vertical = "_V", horizontal = "_H"),
    #if(shuffle || type != "dropdown") "_" else "",
    if(shuffle) "S" else "",
    paste0("%", options, "%", names(options), "#", feedback, collapse = "~")
  )
}

#' @export
answer_numerical <- function(correct, weight = 1, tolerance = 0, feedback = sprintf("Correct, %f is the correct answer.", correct)) {
  # Add alternative solutions / thresholds
  sprintf(
    "`{%i:NUMERICAL:=%f:%f#%s}`{=html}",
    weight, correct, tolerance, feedback
  )
}

#' Create a set of choices for single or multiple choice questions
#'
#' @param A character vector of selectable choices
#' @param A character vector of the correct answers
#'
#' @export
choices <- function(options, answer) {
  i <- options %in% answer
  if(!any(i)) stop("The correct answer does not exist in the provided options.")
  i <- as.integer(i)
  names(i) <- options
  i
}

#' Succinctly create a suitable cloze question
#'
#' @param x The correct answer
#' @param ... Options passed on to other methods
#'
#' @export
cloze <- function(x, ...) {
  UseMethod("cloze")
}

#' @export
cloze.numeric <- function(x, ...) {
  answer_numerical(x, ...)
}

#' @export
cloze.character <- function(x, choices = NULL, ...) {
  if(is.null(choices))
    answer_shortanswer(x, ...)
  else if(length(x) > 1)
    answer_multichoice(choices(choices, x))
  else
    answer_singlechoice(choices(choices, x))
}
