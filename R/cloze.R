# Valid answer types: multichoice|truefalse|shortanswer|matching|cloze|essay|numerical|description


#' Generate Cloze-Type Questions for Moodle
#'
#' These functions create cloze-type questions for Moodle quizzes, designed for use with inline R code chunks in an R Markdown document formatted with the `moodlequiz::moodlequiz` output format.
#'
#' @param options A named vector or list of answer options. Names correspond to answers, and values specify their weights (e.g., 100 for a correct answer or partial weights for partially correct answers). For multiple-choice and single-choice questions, this includes both correct and distractor options.
#' @param weight A numeric value or vector specifying the weight for the correct answer(s). Defaults to the highest weight in `options`.
#' @param feedback A character vector or named list providing feedback for answers. For named lists, names should match options.
#' @param case_sensitive Logical. For `cloze_shortanswer`, whether the answer should be case-sensitive. Defaults to `FALSE`.
#' @param type A character string specifying the presentation style of the options. For `cloze_multichoice`, valid values are `"vertical"` or `"horizontal"`. For `cloze_singlechoice`, valid values are `"dropdown"`, `"vertical"`, or `"horizontal"`.
#' @param shuffle Logical. For `cloze_multichoice` and `cloze_singlechoice`, whether the answer options should be shuffled. Defaults to `FALSE`.
#' @param correct A numeric value or vector specifying the correct numerical answer(s). For `cloze_numerical`, this replaces `options`.
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
#' # Short-answer question
#' cloze_shortanswer(
#'   options = c("Canberra" = 100, "canberra" = 100),
#'   feedback = c("Canberra" = "Correct!", "canberra" = "Correct!"),
#'   case_sensitive = FALSE
#' )
#'
#' # Multiple-choice question
#' cloze_multichoice(
#'   options = c("4" = 100, "3" = 0, "5" = 0),
#'   feedback = c("4" = "Correct!", "3" = "Too low.", "5" = "Too high."),
#'   type = "vertical"
#' )
#'
#' # Single-choice question
#' cloze_singlechoice(
#'   options = c("2" = 100, "1" = 0, "3" = 0),
#'   feedback = c("2" = "Correct!", "1" = "1 is not a prime.", "3" = "Close, but 3 is larger."),
#'   type = "dropdown"
#' )
#'
#' # Numerical question
#' cloze_numerical(
#'   correct = 5,
#'   tolerance = 0.1,
#'   feedback = "Good job!"
#' )
#'
#' # Automatic cloze question
#' cloze("rep_len", c("rep", "rep.int", "rep_len", "replicate"))
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
  options <- options/weight*100
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

#' @rdname cloze_questions
#' @export
cloze_singlechoice <- function(
    options, weight = max(options),
    feedback = "",
    type = c("dropdown", "vertical", "horizontal"),
    shuffle = FALSE) {
  force(feedback)
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

#' @rdname cloze_questions
#' @export
cloze_numerical <- function(correct, weight = 1, tolerance = 0, feedback = "") {
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
cloze.character <- function(x, choices = NULL, ...) {
  if(is.null(choices))
    cloze_shortanswer(`names<-`(1L, x), ...)
  else if(length(x) > 1)
    cloze_multichoice(choices(choices, x))
  else
    cloze_singlechoice(choices(choices, x))
}
