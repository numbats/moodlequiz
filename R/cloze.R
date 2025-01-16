# Valid answer types: multichoice|truefalse|shortanswer|matching|cloze|essay|numerical|description


#' Generate Cloze-Type Questions for Moodle
#'
#' These functions create cloze-type questions for Moodle quizzes, designed for use with inline R code chunks in an R Markdown document formatted with the `moodlequiz::moodlequiz` output format.
#'
#' @param options A named vector of answer options. For single/multiple choice questions the [`choices()`] helper function can help create this vector. Names correspond to answers, and values specify their weights (e.g., 100 for a correct answer or partial weights for partially correct answers). For multiple-choice and single-choice questions, this includes both correct and distractor options.
#' @param weight A numeric value specifying the weight for the question. Defaults to the highest weight in `options`.
#' @param feedback A character vector providing feedback for answers.
#' @param case_sensitive Logical. For `cloze_shortanswer`, whether the answer should be case-sensitive. Defaults to `FALSE`.
#' @param type A character string specifying the presentation style of the options. For `cloze_multichoice`, valid values are `"vertical"` or `"horizontal"`. For `cloze_singlechoice`, valid values are `"dropdown"`, `"vertical"`, or `"horizontal"`.
#' @param shuffle Logical. For `cloze_multichoice` and `cloze_singlechoice`, whether the answer options should be shuffled. Defaults to `FALSE`.
#' @param answer A numeric value specifying the correct numerical answer(s).
#' @param tolerance A numeric value specifying the acceptable range of deviation for `cloze_numerical` answers. Defaults to `0`.
#' @param x For `cloze()`, the correct answer which also determines the question type (e.g. `numeric` will use `cloze_numerical()` and `character` will use `cloze_shortanswer()` or `cloze_singlechoice()`/`cloze_multichoice()` if selectable options are given as the second argument).
#' @param ... Additional arguments passed to other `cloze()` methods (such as the available options and other `cloze_*()` arguments).
#'
#' @section Functions:
#'
#' - **`cloze_shortanswer()`**: Creates a short-answer question where the student provides a text response.
#' - **`cloze_multichoice()`**: Creates a multiple-choice question where students can select one or more correct answers.
#' - **`cloze_singlechoice()`**: Generates a single-choice question where students select one correct answer from a list.
#' - **`cloze_numerical()`**: Generates a numerical question where students input a numeric response with optional tolerance.
#' - **`cloze()`**: Automatic question types based on the class of the answers.
#'
#' @return A character string containing the Moodle-compatible XML or inline text for the specified cloze question(s).
#'
#' @examples
#' # Short-answer question: Where is the best coffee?
#' cloze_shortanswer(
#'   options = c("Melbourne" = 1),
#'   case_sensitive = FALSE
#' )
#'
#' # Multiple-choice question: Select all lower-case answers
#' cloze_multichoice(
#'   options = c("a" = 1, "F" = 0, "g" = 1, "V" = 0, "K" = 0),
#'   type = "vertical"
#' )
#'
#' # Where is Melbourne?
#' cloze_singlechoice(
#'   choices(
#'     c("New South Wales", "Victoria", "Queensland", "Western Australia",
#'       "South Australia", "Tasmania", "Australian Capital Territory",
#'       "Northern Territory"),
#'     "Victoria"
#'   ),
#'   type = "dropdown"
#' )
#'
#' # Numerical question: Pick a number between 1 and 10
#' cloze_numerical(
#'   answer = 5.5,
#'   tolerance = 4.5
#' )
#'
#' # Automatic cloze questions
#' cloze(42) # Numerical
#' cloze("Australia") # Short answer
#' cloze("rep_len", c("rep", "rep.int", "rep_len", "replicate")) # Single choice
#' cloze(c("A", "B", "C"), LETTERS) # Multiple choice
#'
#' @name cloze_questions
NULL

#' @rdname cloze_questions
#' @export
cloze_shortanswer <- function(
    options, weight = max(options),
    feedback = "",
    case_sensitive = FALSE) {
  force(feedback)
  # Validate an answer is provided
  options <- options/pmax(weight, 0.01)*100
  if(!any(options == 100)) stop("At least one correct answer with mark value 1 (or more) must be specified for a short answer question.")
  sprintf(
    "`{%i:SHORTANSWER%s:%s}`{=html}",
    weight,
    if(case_sensitive) "_C" else "",
    paste0("%", options, "%", names(options), "#", feedback, collapse = "~")
  )
}

#' @rdname cloze_questions
#' @export
cloze_multichoice <- function(
    options, weight = max(options),
    feedback = "",
    type = c("vertical", "horizontal"),
    shuffle = FALSE) {
  force(feedback)
  # Validate an answer is provided
  options <- options/pmax(weight, 0.01)*100
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

#' @rdname cloze_questions
#' @export
cloze_singlechoice <- function(
    options, weight = max(options),
    feedback = "",
    type = c("dropdown", "vertical", "horizontal"),
    shuffle = FALSE) {
  force(feedback)
  # Validate an answer is provided
  options <- options/pmax(weight, 0.01)*100
  if(!any(options == 100)) stop("At least one correct answer with mark value 1 (or more) must be specified for a single choice question.")

  type <- match.arg(type)
  sprintf(
    "`{%i:MULTICHOICE%s%s%s:%s}`{=html}",
    weight,
    if(shuffle || type != "dropdown") "_" else "",
    switch(type, dropdown = "", vertical = "V", horizontal = "H"),
    if(shuffle) "S" else "",
    paste0("%", options, "%", names(options), "#", feedback, collapse = "~")
  )
}

#' @rdname cloze_questions
#' @export
cloze_numerical <- function(answer, weight = 1, tolerance = 0, feedback = "") {
  # Add alternative solutions / thresholds
  sprintf(
    "`{%i:NUMERICAL:=%f:%f#%s}`{=html}",
    weight, answer, tolerance, feedback
  )
}

#' Create a set of choices for single or multiple choice questions
#'
#' @param options A character vector of selectable choices
#' @param answer A character vector of the correct answers
#'
#' @export
choices <- function(options, answer) {
  i <- options %in% answer
  if(!any(i)) stop("The correct answer does not exist in the provided options.")
  i <- as.integer(i)
  names(i) <- options
  i
}

#' @rdname cloze_questions
#' @export
cloze <- function(x, ...) {
  UseMethod("cloze")
}

#' @export
cloze.numeric <- function(x, ...) {
  cloze_numerical(x, ...)
}

#' @export
cloze.character <- function(x, choices = NULL, weight = 1L, ...) {
  if(is.null(choices))
    cloze_shortanswer(`names<-`(weight, x), weight = weight, ...)
  else if(length(x) > 1)
    cloze_multichoice(choices(choices, x)*weight, weight = weight, ...)
  else
    cloze_singlechoice(choices(choices, x)*weight, weight = weight, ...)
}
