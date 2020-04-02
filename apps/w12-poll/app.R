library(psychTestR)
library(dplyr)
library(htmltools)
library(purrr)
library(tibble)

### COPY THIS CODE TO YOUR OWN APP ###

library(googlesheets4)

## Save function based on Harrison's elt_save_results_to_disk()
elt_save_results_to_google <- function(email, ssid) {
    code_block(
        function(state, opt, ...) {
            sheets_auth(cache = '.', email = email, use_oob = TRUE)
            results <-
                as.data.frame(
                    get_results(state, complete = TRUE, add_session_info = TRUE)
                ) %>%
                psychTestR:::list_cols_to_json()
            saved_data <- sheets_read(ssid, sheet = 1)
            if (nrow(saved_data) == 0) {
                sheets_write(results, ssid, sheet = 1)
            } else {
                sheets_append(results, ssid, sheet = 1)
            }
        }
    )
}

### END CODE TO COPY ###


TIME_SLOTS <-
    tribble(
        ~label, ~prompt,
        '10am', '10.00 to 12.00',
        'noon', '12.00 to 14.00',
        '2pm',  '14.00 to 16.00',
        '4pm',  '16.00 to 18.00',
        '6pm',  '18.00 to 20.00 (no change to the official schedule)'
    )

make_test(
    elts =
        join(
            one_button_page(
                div(
                    p(
                        "
                        The coronavirus crisis is changing everybody's
                        schedules,and in this new environment, perhaps our
                        regular meeting time is no longer optimal for you. We
                        will stay with Thursdays, but this survey will ask
                        whether there are other time slots that would be better
                        for you.
                        "
                    )
                )
            ),
            text_input_page(
                label = 'name',
                prompt = div(p('What is your name?'))
            ),
            pmap(
                TIME_SLOTS,
                function(label, prompt) {
                    NAFC_page(
                        label = label,
                        prompt =
                            div(
                                p(
                                    "
                                    How would you feel about moving course
                                    meetings for The Data Science of Everyday
                                    Listening to
                                    ",
                                    tags$strong(prompt),
                                    tags$strong('on Thursdays'),
                                    '?'
                                )
                            ),
                        choices = c('2p', '1p', '0p'),
                        labels =
                            list(
                                p('This time would be good for me.'),
                                p('This time is possible for me, but it is not my preference.'),
                                p('This time is', tags$strong('not'), 'possible for me most weeks.')
                            )
                    )
                }
            ),
            elt_save_results_to_google(
                email = 'john.ashley.burgoyne@gmail.com',
                ssid = '1__2P-D9Uy8SSzJjv-XD6xXVLAfIMQxpRHNm-6mA_zok'
            ),
            final_page(div(p('Thank you for your response! You may close the window now.')))
        ),
    opt =
        test_options(
            title = 'Everyday Listening 2020: Online Meeting Times',
            admin_password = 'delovely',
            researcher_email = 'j.a.burgoyne@uva.nl',
            theme = 'flatly'
        )
) -> test

shiny::runApp(test)

