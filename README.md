
<!-- README.md is generated from README.Rmd. Please edit that file -->

# askgpt

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The goal of askgpt is to help you to learn R, using a ChatGPT-like
prompt and answer system. It sends prompts to [openai’s
API](https://openai.com/api/) directly from R. It also has some
additional functionality:

- Prompt “What is wrong with my last command?” (or “help!”) to get help
  on the last error R emmitted
- Prompt “Can you elaborate on that?” (or “what?”) to ask GPT to
  elaborate on the last reply
- Use the RStudio addin to comment, annotate or explain highlighted code

## Installation

You can install the development version of askgpt like so:

``` r
remotes::install_github("JBGruber/askgpt")
```

Then you should get a key for the openai API on [this
page](https://openai.com/api/). Save it to your project with:

``` r
usethis::edit_r_environ(scope = "project")
```

In the format:

``` r
OPENAI_API_KEY = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

## Demo

<picture>
<source media="(prefers-color-scheme: dark)" srcset="man/figures/README-/unnamed-chunk-4-dark.svg">
<img src="man/figures/README-/unnamed-chunk-4.svg" width="100%" />
</picture>
