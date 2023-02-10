
<!-- README.md is generated from README.Rmd. Please edit that file -->

# askgpt

<!-- badges: start -->
<!-- badges: end -->

The goal of askgpt is to help you to learn R using a ChatGPT-like prompt
and answer system. It wraps the
[openai](https://github.com/irudnyts/openai/) package and let’s you ask
question from the R Console directly.

## Installation

You can install the development version of askgpt like so:

``` r
remotes::install_github("JBGruber/askgpt")
```

Then you should get a key for theopenai API on [this
page](https://openai.com/api/). Save it to your project with:

``` r
usethis::edit_r_environ(scope = "project")
```

In the format:

``` r
OPENAI_API_KEY = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

## Example

<figure>
<video src="man/figures/askgpt.webm" controls=""><a
href="man/figures/askgpt.webm">video of examples</a></video>
<figcaption aria-hidden="true">video of examples</figcaption>
</figure>

``` r
library(askgpt)
library(askgpt)
log_init() # run to enable error logging
askgpt("What is an R function?")
mean[1]
askgpt("What is wrong with my last command?") # this is a special trigger prompt that sends your last command to GPT
askgpt("Can you help me with the function aes() from ggplot2?")
askgpt("Can you elaborate on that?") # the api does not really have a memory, the last prompt is sent to the API again
```
