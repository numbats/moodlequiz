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
    xfun::write_utf8(
      c(
        '<?xml version="1.0" encoding="UTF-8"?>\n<quiz>',
        do.call(c, xml),
        '</quiz>'
      ),
      xfun::with_ext(input, "xml")
    )

    # Prevent knitting of document
    render_env <- rlang::caller_env(n = 2)
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
      render_env, nm = "output_file", value = normalizePath(render_env$output_file),
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
