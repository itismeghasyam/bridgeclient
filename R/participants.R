#' Get a study participant (user) record using the external ID of the account
#' 
#' @param external_id The external ID of the participant
#' @export
get_participant <- function(external_id) {
  response <- bridgeGET(glue::glue("/v3/participants/externalId:{external_id}"))
  participant <- httr::content(response)
  return(participant)
}