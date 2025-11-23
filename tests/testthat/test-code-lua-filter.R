test_that("Lua filter strips `...`{=html} in code blocks (#34)", {
  skip_if_not(rmarkdown::pandoc_available(), "Pandoc is not available")

  lua_filter <- system.file("code.lua", package = "moodlequiz")
  expect_true(file.exists(lua_filter), info = "Lua filter file not found")

  # Input markdown containing a fenced code block with the pattern
  input_md <- "
```r
for (i in x) {
  `{1:SHORTANSWER:%100%aes(x=step, y=val)#}`{=html}
}
```
"

  # Use a temporary file for input and output
  in_file  <- tempfile(fileext = ".md")
  out_file <- tempfile(fileext = ".md")
  writeLines(input_md, in_file)

  # Run pandoc with the Lua filter
  # Output format can be anything; we just inspect the raw output text
  rmarkdown::pandoc_convert(
    input = in_file,
    to    = "markdown",
    output = out_file,
    options = c("--lua-filter", lua_filter)
  )

  output_md <- readLines(out_file, warn = FALSE)
  output_text <- paste(output_md, collapse = "\n")

  # The backticks + {=html} should be removed, leaving only {...}
  expect_match(
    output_text,
    "for (i in x) {\n  {1:SHORTANSWER:%100%aes(x=step, y=val)#}\n}",
    fixed = TRUE,
    info = "Lua filter did not unwrap `{...}`{=html} inside code block"
  )

  # And there should be no literal `{=html}` remaining
  expect_false(grepl("\\{=html\\}", output_text), info = "Found leftover {=html} in output")
})