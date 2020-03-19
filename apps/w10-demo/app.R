library(psychTestR)
library(tidyverse)
msi_agreement_prompts <- read_csv2('./gold-msi-agreement.csv')
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
msi_other_prompts <- read_csv2('./gold-msi-other.csv')
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
my_options <-
    test_options(
        title = 'Everyday Listening 2020: Gold-MSI General',
        admin_password = 'delovely',
        researcher_email = 'j.a.burgoyne@uva.nl',
        theme = 'lumen'
    )
make_test(
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
