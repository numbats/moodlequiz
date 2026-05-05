#' R Markdown format for Moodle XML quizzes
#'
#' Provides an alternative interface to working with the exams package for
#' producing Moodle questions any type.
#'
#' @param replicates The number of times the questions are rendered, useful for
#'   producing multiple versions of the same quiz with different random samples.
#' @inheritParams rmarkdown::html_document
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
  pre_knit <- function(input, ...) {
    output <- tempfile(fileext = ".xml")

    replicate_prefix <- if (replicates > 1)
      paste0(" R", formatC(seq_len(replicates), width = nchar(replicates), format = "d", flag = "0"))
    else
      ""

    # Generate XML for each replicate
    xml <- lapply(replicate_prefix, function(prefix) {
      rmarkdown::render(
        input,
        output_format = "moodlequiz::moodlequiz_xml",
        output_options = list(replicate = prefix),
        output_file = output,
        quiet = TRUE
      )
      xfun::read_utf8(output)
    })

    # Combine and write final XML output
    render_env <- rlang::caller_env(n = 2)
    xfun::write_utf8(
      c('<?xml version="1.0" encoding="UTF-8"?>\n<quiz>', do.call(c, xml), '</quiz>'),
      xfun::with_ext(render_env$output_file, "xml")
    )

    # Keep HTML rendering
    rlang::env_poke(render_env, nm = "requires_knit", value = TRUE)
  }

  output_format(
    knitr = knitr_options(),
    pandoc = pandoc_options(to = "html"),
    pre_knit = pre_knit,
    base_format = rmarkdown::html_document(...)
  )
}

#' Generate Moodle Quiz XML Output for R Markdown
#'
#' Internal function. Use `moodlequiz()` instead.
#'
#' @param replicate Replication label
#' @param self_contained Logical. If TRUE, output is self-contained HTML
#' @param extra_dependencies HTML dependencies
#' @param theme HTML theme
#' @param includes HTML includes
#' @param lib_dir Library directory
#' @param md_extensions Markdown extensions
#' @param pandoc_args Extra pandoc arguments
#' @param ... Other arguments passed to `bookdown::html_document2`
#'
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
  pre_processor <- function(metadata, input_file, ...) {
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

  post_processor <- function(metadata, input_file, output_file, ...) {
    xml <- xfun::read_utf8(output_file)
    xml <- gsub("<cdata>", "<![CDATA[", xml, fixed = TRUE)
    xml <- gsub("</cdata>", "]]>", xml, fixed = TRUE)
    xfun::write_utf8(xml, output_file)
    output_file
  }

  filters <- vapply(
    c("header.lua", "question.lua", "code.lua"),
    system.file, character(1L),
    package = "moodlequiz", mustWork = TRUE
  )

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

  out$knitr$opts_knit$bookdown.internal.label <- TRUE
  out
}
