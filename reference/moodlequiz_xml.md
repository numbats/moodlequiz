# Generate Moodle Quiz XML Output for R Markdown

This function is intended for internal generation of the XML output. It
is strongly recommended that you use the `[moodlequiz::moodlequiz()]`
output format, which provides a higher-level interface for creating
Moodle-compatible quizzes.

## Usage

``` r
moodlequiz_xml(
  replicate = "",
  self_contained = TRUE,
  extra_dependencies = NULL,
  theme = NULL,
  includes = NULL,
  lib_dir = NULL,
  md_extensions = NULL,
  pandoc_args = NULL,
  ...
)
```

## Arguments

- replicate:

  A character string specifying the how many replications of the quiz
  should be produced.

- self_contained:

  Logical. If `TRUE`, the output document will be self-contained,
  embedding resources directly into the file. Defaults to `TRUE`.

- extra_dependencies:

  Additional dependencies to include in the output. These can be
  specified as an `html_dependency` object or a list of such objects.

- theme:

  A character string specifying the theme for the output. This can be a
  standard theme name or a custom CSS file.

- includes:

  Additional content to include in the output. This should be a list of
  named elements, such as `in_header`, `before_body`, and `after_body`.

- lib_dir:

  Directory to copy library files for the output. If `NULL`, no library
  files are copied.

- md_extensions:

  A character string specifying Markdown extensions to be passed to
  Pandoc.

- pandoc_args:

  Additional arguments to pass to Pandoc.

- ...:

  Additional arguments passed to
  [`bookdown::html_document2()`](https://pkgs.rstudio.com/bookdown/reference/html_document2.html)

## Value

An R Markdown output format object.

## See also

[`moodlequiz()`](https://numbats.github.io/moodlequiz/reference/moodlequiz.md)
