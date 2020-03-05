Using psychTestR for Music Cognition
================

This week, we will learn how to create our own experiments with Peter
Harrison’s new `psychTestR` package. Please use this document as a
companion to the extensive set of tutorials on his [package web
site](https://pmcharrison.github.io/psychTestR/).

## Set up shinyapps.io

In order to run our experiments, we need to be able to host web sites
with Shiny. You can do that inexpensively with shinyapps.io. Make an
account, and then run these commands just once to set up your laptop.

``` r
install.packages('rsconnect')
remotes::install_github('pmcharrison/psychTestR')
rsconnect::setAccountInfo(name='YOUR_NAME',
              token='YOUR_TOKEN',
              secret='YOUR_SECRET')
```

And then load the packages and begin\!

``` r
library(tidyverse)
```

    ## ── Attaching packages ──────────────────────────────────────────────────────────────────────────── tidyverse 1.3.0 ──

    ## ✓ ggplot2 3.2.1     ✓ purrr   0.3.3
    ## ✓ tibble  2.1.3     ✓ dplyr   0.8.4
    ## ✓ tidyr   1.0.2     ✓ stringr 1.4.0
    ## ✓ readr   1.3.1     ✓ forcats 0.5.0

    ## ── Conflicts ─────────────────────────────────────────────────────────────────────────────── tidyverse_conflicts() ──
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

``` r
library(psychTestR)
```

    ## 
    ## Attaching package: 'psychTestR'

    ## The following objects are masked from 'package:utils':
    ## 
    ##     demo, page

## Creating an experiment

We start by loading the agreement prompts. The sliders in `psychTestR`
don’t allow us to label the scale points, and so it is better to use a
multiple-choice question instead. We give each choice a name (`MSI1`,
`MSI1`, etc.) in order to make it easier to write a scoring function
later. The function inside `pmap` needs to handle every column in our
CSV file.

``` r
msi_agreement_prompts <- read_csv2('app/gold-msi-agreement.csv')
```

    ## Using ',' as decimal and '.' as grouping mark. Use read_delim() for more control.

    ## Parsed with column specification:
    ## cols(
    ##   id = col_character(),
    ##   prompt = col_character(),
    ##   is_positive = col_logical()
    ## )

``` r
msi_agreement <- 
    pmap(
        msi_agreement_prompts,
        function(id, prompt, is_positive) {
            NAFC_page(
                label = id,
                prompt = prompt,
                choices = 
                    c('MSI1', 'MSI2', 'MSI3', 'MSI4', 'MSI5', 'MSI6', 'MSI7'),
                labels = 
                    c(
                        'Completely disagree',
                        'Strongly disagree',
                        'Disagree',
                        'Neither agree nor disagree',
                        'Agree',
                        'Strongly agree',
                        'Completely agree'
                    )
            )
        }
    )
```

For the non-agreement questions, we want to use the same choice names
for our scoring function, but we’ll use the labels from the CSV file.

``` r
msi_other_prompts <- read_csv2('app/gold-msi-other.csv')
```

    ## Using ',' as decimal and '.' as grouping mark. Use read_delim() for more control.

    ## Parsed with column specification:
    ## cols(
    ##   id = col_character(),
    ##   prompt = col_character(),
    ##   score1 = col_double(),
    ##   score2 = col_character(),
    ##   score3 = col_double(),
    ##   score4 = col_character(),
    ##   score5 = col_character(),
    ##   score6 = col_character(),
    ##   score7 = col_character(),
    ##   is_positive = col_logical()
    ## )

``` r
msi_other <-
    pmap(
        msi_other_prompts,
        function(id, prompt, score1, score2, score3, score4, score5, score6, score7, is_positive) {
            NAFC_page(
                label = id,
                prompt = prompt,
                choices = 
                    c('MSI1', 'MSI2', 'MSI3', 'MSI4', 'MSI5', 'MSI6', 'MSI7'),
                labels = 
                    c(score1, score2, score3, score4, score5, score6, score7)
            )
        }
    )
```

Finally, we join them all together with randomisation.

``` r
msi_complete <- 
    join(
        one_button_page(
            'You will be given a series of statements about how you engage with music in your daily life. Please tell us how much you agree with them.'
        ),
        randomise_at_run_time(label = 'msi_agreement_order', logic = msi_agreement),
        one_button_page(
            'Now we have a few more questions about your formal music experience in the past.'
        ),
        randomise_at_run_time(label = 'msi_other_order', logic = msi_other),
        text_input_page(
            label = 'MSI39',
            prompt = 'The instrument I play best, including voice, is _____.'
        )
    )
```

Once we have a complete test, we set some options and make a test. You
can look up the `shinythemes` package if you want to try other themes.

``` r
my_options <-
    test_options(
        title = 'Everyday Listening 2020: Gold-MSI General',
        admin_password = 'delovely',
        researcher_email = 'j.a.burgoyne@uva.nl',
        theme = 'lumen'
    )
my_test <- make_test(
    elts = 
        join(
            one_button_page(
                'Welcome to my experiment! Let me give you some instructions.'
            ),
            get_basic_demographics(),
            msi_complete,
            elt_save_results_to_disk(complete = TRUE),
            final_page('Those are all of the questions we have. Thank you!')
        ),
    opt = my_options
)
```

Finally, let’s run the app with Shiny\!

``` r
shiny::runApp(my_test)
```

Eventually, we will need to make a separate app repository and end with
a *bare* `make_test()` function, without storing it as a variable. For
an example, look at the `app` directory at the [course
repository](https://github.com/jaburgoyne/everyday2020).
