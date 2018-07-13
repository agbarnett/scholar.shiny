# scholar.shiny
A shiny application that interacts with Google Scholar to create publication lists.

The main file is `scholar.R` which takes a Google Scholar id and uses the scholar package to get the researcher's publications. The shiny files are `ui.R` and `server.R`. It uses the R packages: shiny, tidyverse, dplyr, scholar, stringr, knitr and rmarkdown.

This will work on your own computer, but it will not work if uploaded to a server (e.g., shinyapps.io). This is because of permissions and it has been solved with google sheets (see https://github.com/jennybc/googlesheets/blob/master/R/gs_webapp.R). Please get in touch if you want to help me fix this issue, so we can make this into a publicly available shiny app.
