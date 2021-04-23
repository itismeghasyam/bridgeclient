############################################################################
# Author: Meghasyam Tummalacherla
############################################################################
get_participant_report <- function(identifier){
  response <- bridgeGET(
    glue::glue("/v3/users/self/reports/{identifier}"))
  content <- httr::content(response)
  return(content$items)
  
}
