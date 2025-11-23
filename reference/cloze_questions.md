# Generate Cloze-Type Questions for Moodle

These functions create cloze-type questions for Moodle quizzes, designed
for use with inline R code chunks in an R Markdown document formatted
with the
[`moodlequiz::moodlequiz`](http://emitanaka.org/moodlequiz/reference/moodlequiz.md)
output format.

## Usage

``` r
cloze_shortanswer(
  options,
  weight = max(options),
  feedback = "",
  case_sensitive = FALSE
)

cloze_multichoice(
  options,
  weight = max(options),
  feedback = "",
  type = c("vertical", "horizontal"),
  shuffle = FALSE
)

cloze_singlechoice(
  options,
  weight = max(options),
  feedback = "",
  type = c("dropdown", "vertical", "horizontal"),
  shuffle = FALSE
)

cloze_numerical(answer, weight = 1, tolerance = 0, feedback = "")

cloze(x, ...)
```

## Arguments

- options:

  A named vector of answer options. For single/multiple choice questions
  the
  [`choices()`](http://emitanaka.org/moodlequiz/reference/choices.md)
  helper function can help create this vector. Names correspond to
  answers, and values specify their weights (e.g., 100 for a correct
  answer or partial weights for partially correct answers). For
  multiple-choice and single-choice questions, this includes both
  correct and distractor options.

- weight:

  A numeric value specifying the weight for the question. Defaults to
  the highest weight in `options`.

- feedback:

  A character vector providing feedback for answers.

- case_sensitive:

  Logical. For `cloze_shortanswer`, whether the answer should be
  case-sensitive. Defaults to `FALSE`.

- type:

  A character string specifying the presentation style of the options.
  For `cloze_multichoice`, valid values are `"vertical"` or
  `"horizontal"`. For `cloze_singlechoice`, valid values are
  `"dropdown"`, `"vertical"`, or `"horizontal"`.

- shuffle:

  Logical. For `cloze_multichoice` and `cloze_singlechoice`, whether the
  answer options should be shuffled. Defaults to `FALSE`.

- answer:

  A numeric value specifying the correct numerical answer(s).

- tolerance:

  A numeric value specifying the acceptable range of deviation for
  `cloze_numerical` answers. Defaults to `0`.

- x:

  For `cloze()`, the correct answer which also determines the question
  type (e.g. `numeric` will use `cloze_numerical()` and `character` will
  use `cloze_shortanswer()` or
  `cloze_singlechoice()`/`cloze_multichoice()` if selectable options are
  given as the second argument).

- ...:

  Additional arguments passed to other `cloze()` methods (such as the
  available options and other `cloze_*()` arguments).

## Value

A character string containing the Moodle-compatible XML or inline text
for the specified cloze question(s).

## Functions

- **`cloze_shortanswer()`**: Creates a short-answer question where the
  student provides a text response.

- **`cloze_singlechoice()`**: Generates a single-choice question where
  students select one correct answer from a list.

- **`cloze_multichoice()`**: Creates a multiple-choice question where
  students can select one or more correct answers.

- **`cloze_numerical()`**: Generates a numerical question where students
  input a numeric response with optional tolerance.

- **`cloze()`**: Automatic question types based on the class of the
  answers.

## Examples

``` r
# Short-answer question: Where is the best coffee?
cloze_shortanswer(
  options = c("Melbourne" = 1),
  case_sensitive = FALSE
)
#> [1] "`{1:SHORTANSWER:%100%Melbourne#}`{=html}"

# Multiple-choice question: Select all lower-case answers
cloze_multichoice(
  options = c("a" = 1, "F" = 0, "g" = 1, "V" = 0, "K" = 0),
  type = "vertical"
)
#> [1] "`{1:MULTIRESPONSE:%100%a#~%0%F#~%100%g#~%0%V#~%0%K#}`{=html}"

# Where is Melbourne?
cloze_singlechoice(
  choices(
    c("New South Wales", "Victoria", "Queensland", "Western Australia",
      "South Australia", "Tasmania", "Australian Capital Territory",
      "Northern Territory"),
    "Victoria"
  ),
  type = "dropdown"
)
#> [1] "`{1:MULTICHOICE:%0%New South Wales#~%100%Victoria#~%0%Queensland#~%0%Western Australia#~%0%South Australia#~%0%Tasmania#~%0%Australian Capital Territory#~%0%Northern Territory#}`{=html}"

# Numerical question: Pick a number between 1 and 10
cloze_numerical(
  answer = 5.5,
  tolerance = 4.5
)
#> [1] "`{1:NUMERICAL:=5.500000:4.500000#}`{=html}"

# Automatic cloze questions
cloze(42) # Numerical
#> [1] "`{1:NUMERICAL:=42.000000:0.000000#}`{=html}"
cloze("Australia") # Short answer
#> [1] "`{1:SHORTANSWER:%100%Australia#}`{=html}"
cloze("rep_len", c("rep", "rep.int", "rep_len", "replicate")) # Single choice
#> [1] "`{1:MULTICHOICE:%0%rep#~%0%rep.int#~%100%rep_len#~%0%replicate#}`{=html}"
cloze(c("A", "B", "C"), LETTERS) # Multiple choice
#> [1] "`{1:MULTIRESPONSE:%100%A#~%100%B#~%100%C#~%0%D#~%0%E#~%0%F#~%0%G#~%0%H#~%0%I#~%0%J#~%0%K#~%0%L#~%0%M#~%0%N#~%0%O#~%0%P#~%0%Q#~%0%R#~%0%S#~%0%T#~%0%U#~%0%V#~%0%W#~%0%X#~%0%Y#~%0%Z#}`{=html}"
```
