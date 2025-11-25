# Changelog

## moodlequiz 0.2.0

Initial CRAN release, allowing the creation of Moodle XML quizzes from R
with R Markdown.

### New features

- Categorisation of questions with H1 headings (`# Category name`).
- Creation of individual questions with H2 headings
  (`## Question name`).
- Support for R Markdown content within question text, including
  figures, tables, code, and equations.
- Randomised questions with multiple replicates using the `replicates`
  output format argument.
- Added
  [`cloze()`](https://numbats.github.io/moodlequiz/reference/cloze_questions.md)
  and `cloze_*()` functionality.
- Added
  [`moodlequiz()`](https://numbats.github.io/moodlequiz/reference/moodlequiz.md)
  output format for R Markdown.
- Added
  [`choices()`](https://numbats.github.io/moodlequiz/reference/choices.md)
  helper for constructing graded vectors of choices.

## moodlequiz 0.1.0

Initial development version not published to CRAN.

- Basic functionality for creating quizzes containing multiple questions
  in Moodle XML format.
- Support for cloze style questions only.
