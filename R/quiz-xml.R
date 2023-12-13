#' R Markdown format for Moodle XML quizzes
#'
#' Provides an alternative interface to working with the exams package for
#' producing Moodle questions any type.
#'
#' @inheritParams rmarkdown::html_document
#'
#' @import rmarkdown
#'
#' @export
moodlequiz <- function(self_contained = TRUE,
                       extra_dependencies = NULL,
                       theme = NULL,
                       includes = NULL,
                       lib_dir = NULL,
                       md_extensions = NULL,
                       pandoc_args = NULL,
                       ...) {

  post_processor <- function(metadata, input_file, output_file, ...) {
    # Convert content within pandoc divs to quiz questions
    # xml <- xml2::read_xml(output_file)
    # questions <- xml2::xml_find_all(xml, '//cdata')

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
