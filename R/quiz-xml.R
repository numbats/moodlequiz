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

  pre_processor <- function(front_matter, input, runtime, knit_meta, files_dir,
                            output_dir, ...) {
    # Fence questions with pandoc divs
    rmd <- split_rmd(input)
    rmd$body <- lapply(rmd$body, fence_question)
    xfun::write_utf8(c(rmd$yaml, do.call(c, rmd$body)), input)
  }

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

  # return format
  output_format(
    knitr = knitr_options(),
    pandoc = pandoc_options(to = "html", ext = ".xml", lua_filters = c(system.file("question.lua", package = "moodlequiz"), system.file("code.lua", package = "moodlequiz"))),
    pre_processor = pre_processor,
    post_processor = post_processor,
    base_format = rmarkdown::html_document(
      highlight = NULL,
      template = system.file("moodle.xml", package = "moodlequiz"),
      ...
    )
  )
}

fence_question <- function(x) {
  opts_prefix <- "^(\\|\\-\\s*)([^:]+):\\s*(.+)$"
  opts_loc <- grep(opts_prefix, x)
  opts <- sub(opts_prefix, " \\2=\\3", x[opts_loc])
  if(length(opts) > 0) x <- x[-opts_loc]
  c(
    paste0(":::{.question", paste(opts, collapse = ""), "}"),
    x,
    ":::"
  )

}
