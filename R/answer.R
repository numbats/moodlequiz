# Valid answer types: multichoice|truefalse|shortanswer|matching|cloze|essay|numerical|description

#' @export
answer_shortanswer <- function(
    options, weight = max(options),
    feedback = ifelse(options == weight, "Correct", ifelse(options == 0, "Incorrect", "Partially correct")),
    case_sensitive = FALSE) {
  sprintf(
    "`{%i:SHORTANSWER%s:%s}`{=html}",
    weight,
    paste0("%", options/weight*100, "%", names(options), "#", feedback, collapse = "~"),
    if(case_sensitive) "_C" else ""
  )
}

#' @export
answer_multichoice <- function(
    options, weight = max(options),
    feedback = ifelse(options == weight, "Correct", ifelse(options == 0, "Incorrect", "Partially correct")),
    type = c("vertical", "horizontal"),
    shuffle = FALSE) {
  sprintf(
    "`{%i:MULTIRESPONSE%s%s%s:%s}`{=html}",
    weight,
    paste0("%", options/weight*100, "%", names(options), "#", feedback, collapse = "~"),
    if(shuffle || type != "vertical") "_" else "",
    switch(type, vertical = "", horizontal = "H"),
    if(shuffle) "S" else ""
  )
}
#' @export

answer_singlechoice <- function(
    options, weight = max(options),
    feedback = ifelse(options == weight, "Correct", ifelse(options == 0, "Incorrect", "Partially correct")),
    type = c("dropdown", "vertical", "horizontal"),
    shuffle = FALSE) {
  sprintf(
    "`{%i:MULTICHOICE:%s}`{=html}",
    weight,
    paste0("%", options/weight*100, "%", names(options), "#", feedback, collapse = "~"),
    if(shuffle || type != "dropdown") "_" else "",
    switch(type, dropdown = "", vertical = "V", horizontal = "H"),
    if(shuffle) "S" else ""
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
