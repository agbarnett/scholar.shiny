# for Google Scholar
# Jan 2018

shinyServer(function(input, output) {
  
  source('scholar.R')
  source('paste5.R')
  
  # reactive function to run chart
  results <- reactive({
    
    id.no.spaces = input$google.id
    id.no.spaces = gsub(' $', '', id.no.spaces) # remove trailing space
    
    validate(
      need(nchar(id.no.spaces) == 12, 
           paste("Scholar IDs should be 12 characters without spaces, e.g., lhc97roAAAAJ", sep=''))
    )
    
    withProgress(message = 'Getting data from Google Scholar', 
                 detail = 'This may take a while...', value=0, {
                   results = scholar(google.id=id.no.spaces, max.authors=input$max.authors, years.since=input$years.since, order.by=input$order)
                   incProgress(1)
                 })
    
    return(results)
  })
  
  # function to get filtered papers (used by basics and table; must be copied into report)
  my.filter = function(){
    res = data.frame(NULL)
    res = results()$papers
    if(is.null(res)==T){
      res = data.frame(NULL)
      return(res)
    }
    # add authors - from ORCID, not yet working
#    if(input$max.authors==1){res$Authors = results()$authors[,1]}
#    if(input$max.authors>1){
#      upper.limit = min(c(input$max.authors, ncol(results()$authors)))
#      if(nrow(results()$authors) > 1){res$Authors = apply(results()$authors[, 1:upper.limit], 1, paste5, collapse=input$spacer)} #
#      if(nrow(results()$authors) == 1 ){res$Authors = paste5(results()$authors, collapse=input$spacer)} #
#    } 
    # add et al
#    if(input$max.authors < ncol(results()$authors)){ # don't add if at max author number
#      index = results()$authors[, input$max.authors+1] != '' # something in next author
#      res$Authors[index] = paste(res$Authors[index], input$spacer, 'et al', sep='')
#    }
    # filter by year:
    res = subset(res, Year>= input$years.since) 
    # filter by keywords - from ORCID, not yet working
#    if(input$keywords != ''){
#      keywords = tolower(gsub(',|, ', '\\|', input$keywords))
#      index = grep(pattern=keywords, tolower(res$Title)) #
#      res = res[index, ]
#    }
    return(res)
  }
  
  
  # basic details:
  output$h_text <- renderText({
    papers = my.filter()
    # output or not:
    if(dim(papers)[1] == 0){
      paste(results()$name, '.\n', sep='')
    }
    if(dim(papers)[1] > 0){
      paste('Researcher = ', results()$name, '.\n',
            'Affiliation = ', results()$affiliation, '.\n',
            'Number of papers = ', nrow(papers), '.', sep='')
    }
  })
  
  # table of papers:
  output$table <- renderTable({
    papers = my.filter()
    # output or not:
    if(dim(papers)[1] == 0){
      res = data.frame(NULL)
    }
    if(dim(papers)[1] > 0){
      papers$Year = as.character(papers$Year) # looks better as character
      res = papers[, input$variable] # select columns
    }
    res
  })
  
  # report for download; see https://shiny.rstudio.com/articles/generating-reports.html
  # and here http://stackoverflow.com/questions/37018983/how-to-make-pdf-download-in-shiny-app-response-to-user-inputs
  output$report <- downloadHandler(
    filename = function(){
      paste("report.docx", sep='') # could expand, e.g., see here: 
    },
    content = function(file){
      
      # Copy the report file to a temporary directory before processing it, in
      # case we don't have write permissions to the current working dir (which
      # can happen when deployed).
      tempReport <- file.path(tempdir(), "report.Rmd")
      #tempReport <- "C:/temp/report.Rmd"
      file.copy("report.Rmd", tempReport, overwrite = TRUE)
      
      params = list(google.id = input$google.id, 
                    years.since = input$years.since,
                    spacer = input$spacer,
                    order = input$order,
                    max.authors = input$max.authors,
                    style = input$style)
      
      out = rmarkdown::render(
        input = tempReport,
        output_file = file,
        params = params,
        envir = new.env(parent = globalenv())
      ) 
      file.rename(out, file)
    }
  )
  
})
