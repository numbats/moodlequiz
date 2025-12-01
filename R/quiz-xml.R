#' R Markdown format for Moodle XML quizzes
#'
#' Provides an alternative interface to working with the exams package for
#' producing Moodle questions any type.
#'
#' @param replicates The number of times the questions are rendered, useful for
#'   producing multiple versions of the same quiz with different random samples.
#'   To keep identify replicates of questions for random importation into Moodle
#'   we recommend organising the materials into categories using top level
#'   headers.
#' @inheritParams rmarkdown::html_document
#'
#' @return R Markdown output format to pass to [rmarkdown::render()]
#' 
#' @import rmarkdown
#'
#' @export
moodlequiz <- function(replicates = 1L,
                       self_contained = TRUE,
                       extra_dependencies = NULL,
                       theme = NULL,
                       includes = NULL,
                       lib_dir = NULL,
                       md_extensions = NULL,
                       pandoc_args = NULL,
                       ...) {
  pre_knit <- function (input, ...) {
    output <- tempfile(fileext = ".xml")

    replicate_prefix <- if(replicates > 1)
      paste0(" R", formatC(seq_len(replicates), width = nchar(replicates), format = "d", flag = "0"))
    else
      ""

    # Repeatedly render to XML format
    xml <- lapply(replicate_prefix, function(prefix) {
      rmarkdown::render(
        input, output_format = "moodlequiz::moodlequiz_xml", output_options = list(replicate = prefix),
        output_file = output, quiet = TRUE
      )
      xfun::read_utf8(output)
    })

    # Combine into a single XML for upload
    render_env <- rlang::caller_env(n = 2)
    xfun::write_utf8(
      c(
        '<?xml version="1.0" encoding="UTF-8"?>\n<quiz>',
        do.call(c, xml),
        '</quiz>'
      ),
      xfun::with_ext(render_env$output_file, "xml")
    )

    # Prevent knitting of document
    rlang::env_poke(
      render_env, nm = "requires_knit", value = FALSE,
      inherit = TRUE, create = FALSE
    )
    # Change input to dummy md with Moodle XML import instructions
    input <- system.file("instructions.md", package = "moodlequiz")
    rlang::env_poke(
      render_env, nm = "input", value = input,
      inherit = TRUE, create = FALSE
    )
    rlang::env_poke(
      render_env, nm = "output_file", value = file.path(normalizePath(render_env$output_dir), "moodlequiz-instructions.html"),
      inherit = TRUE, create = FALSE
    )

    input
  }

  # return format
  output_format(
    knitr = knitr_options(),
    pandoc = pandoc_options(to = "html"),
    pre_knit = pre_knit,
    base_format = rmarkdown::html_document(...)
  )
}

#' Generate Moodle Quiz XML Output for R Markdown
#'
#' This function is intended for internal generation of the XML output.
#' It is strongly recommended that you use the `[moodlequiz::moodlequiz()]`
#' output format, which provides a higher-level interface for creating
#' Moodle-compatible quizzes.
#'
#' @param replicate A character string specifying the how many replications of the quiz should be produced.
#' @param self_contained Logical. If `TRUE`, the output document will be self-contained,
#'   embedding resources directly into the file. Defaults to `TRUE`.
#' @param extra_dependencies Additional dependencies to include in the output. These can be
#'   specified as an `html_dependency` object or a list of such objects.
#' @param theme A character string specifying the theme for the output. This can be a standard
#'   theme name or a custom CSS file.
#' @param includes Additional content to include in the output. This should be a list of
#'   named elements, such as `in_header`, `before_body`, and `after_body`.
#' @param lib_dir Directory to copy library files for the output. If `NULL`, no library files
#'   are copied.
#' @param md_extensions A character string specifying Markdown extensions to be passed to Pandoc.
#' @param pandoc_args Additional arguments to pass to Pandoc.
#' @param ... Additional arguments passed to [`bookdown::html_document2()`]
#'
#' @return An R Markdown output format object.
#'
#' @seealso [moodlequiz::moodlequiz()]
#'
#' @keywords internal
#' @export
moodlequiz_xml <- function(replicate = "",
                           self_contained = TRUE,
                           extra_dependencies = NULL,
                           theme = NULL,
                           includes = NULL,
                           lib_dir = NULL,
                           md_extensions = NULL,
                           pandoc_args = NULL,
                           ...) {
  pre_processor <- function (metadata, input_file, ...) {
    metadata$moodlequiz$replicate <- replicate
    xfun::write_utf8(
      c(
        "---", yaml::as.yaml(metadata), "---",
        split_rmd(input_file)$body
      ),
      input_file
    )
    list()
  }

  post_processor <- function (metadata, input_file, output_file, ...) {
    # Convert content within pandoc divs to quiz questions
    xml <- xfun::read_utf8(output_file)
    xml <- gsub("<cdata>", replacement = "<![CDATA[", xml, fixed = TRUE)
    xml <- gsub("</cdata>", replacement = "]]>", xml, fixed = TRUE)
    xfun::write_utf8(xml, output_file)
    output_file
  }

  filters <- vapply(
    c("header.lua", "question.lua", "code.lua"),
    system.file, character(1L),
    package = "moodlequiz", mustWork = TRUE
  )

  # return format
  out <- output_format(
    knitr = knitr_options(),
    pandoc = pandoc_options(to = "html", ext = ".xml", lua_filters = filters),
    pre_processor = pre_processor,
    post_processor = post_processor,
    base_format = bookdown::html_document2(
      highlight = NULL,
      template = system.file("moodle.xml", package = "moodlequiz"),
      ...
    )
  )
  # use labels of the form (\#label) in knitr
  out$knitr$opts_knit$bookdown.internal.label = TRUE

  out
}
