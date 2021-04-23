############################################################################
# Author: Meghasyam Tummalacherla, Phil Snyder
############################################################################

#--------------------------------------------------------#
# All GET requests from 
# https://developer.sagebridge.org/swagger-ui/index.html#/Participants
#--------------------------------------------------------#

#' Get a study participant (user) record using the external ID 
#' or healthCode or userId of the account
#' https://developer.sagebridge.org/swagger-ui/index.html#/Participants/getParticipantById
#' https://developer.sagebridge.org/swagger-ui/index.html#/Participants/getParticipantByExternalId
#' https://developer.sagebridge.org/swagger-ui/index.html#/Participants/getParticipantByHealthCode
#' 
#' @param external_id The external ID of the participant
#' @param healthCode  The healthCode of the participant
#' @param user_id The userId(Bridge) of the participant
#' @export
getParticipant <- function(healthCode = NULL,
                           external_id = NULL,
                           user_id = NULL) {
  
  tryCatch(
    {if(!is.null(healthCode)){
      response <- bridgeGET(glue::glue("/v3/participants/healthCode:{healthCode}"))
    }else if(!is.null(external_id)){
      response <- bridgeGET(glue::glue("/v3/participants/externalId:{external_id}"))
    }else if(!is.null(user_id)){
      response <- bridgeGET(glue::glue("/v3/participants/{user_id}"))
    }else{
      return(NA)
    }
      
      participant <- httr::content(response)
      return(participant)},
    error = function(e){return(NA)})
  
}

#' Get a study participant's upload history given the userId(Bridge) 
#' https://developer.sagebridge.org/swagger-ui/index.html#/Participants/getParticipantUploads
#' 
#' @param user_id The userID(Bridge) of the participant
#' @export
getParticipantUploads <- function(user_id){
  tryCatch({
    response <- bridgeGET(glue::glue("/v3/participants/{user_id}/uploads"))
    participant <- httr::content(response)
    return(participant)},
    error = function(e){return(NA)})
}

#' Get a study participant's push notification registrations given the userId(Bridge) 
#' https://developer.sagebridge.org/swagger-ui/index.html#/Participants/getParticipantPushNotificationRegistrations
#' 
#' @param user_id The userID(Bridge) of the participant
#' @export
getParticipantPushNotificationRegistrations <- function(user_id){
  tryCatch({
    response <- bridgeGET(glue::glue("/v3/participants/{user_id}/notifications"))
    participant <- httr::content(response)
    return(participant)},
    error = function(e){return(NA)})
}

#' Get information about the last request made by this participant given the userId(Bridge) 
#' https://developer.sagebridge.org/swagger-ui/index.html#/Participants/getParticipantRequestInfo
#' 
#' @param user_id The userID(Bridge) of the participant
#' @export
getParticipantRequestInfo <- function(user_id){
  tryCatch({
    response <- bridgeGET(glue::glue("/v3/participants/{user_id}/requestInfo"))
    participant <- httr::content(response)
    return(participant)},
    error = function(e){return(NA)})
}

#' Get a study participant's history of activities given the userId(Bridge) and activityGuid
#' https://developer.sagebridge.org/swagger-ui/index.html#/Participants/getParticipantActivityHistory
#' 
#' @param user_id The userID(Bridge) of the participant
#' @param activity_guid The guid (Globally Unique ID) of the activity 
#' @export
getParticipantActivityHistory <- function(user_id,
                                          activity_guid){
  tryCatch({
    response <- bridgeGET(glue::glue("/v3/participants/{user_id}/activities/{activity_guid}"))
    participant <- httr::content(response)
    return(participant)},
    error = function(e){return(NA)})
}

#' Get a study participant's history of a task given the userId(Bridge) and taskId
#' https://developer.sagebridge.org/swagger-ui/index.html#/Participants/getParticipantTaskHistory
#' 
#' @param user_id The userID(Bridge) of the participant
#' @param task_id The task ID of the task 
#' @export
getParticipantTaskHistory <- function(user_id,
                                      task_id){
  tryCatch({
    response <- bridgeGET(glue::glue("/v3/participants/{user_id}/activities/tasks/{task_id}"))
    participant <- httr::content(response)
    return(participant)},
    error = function(e){return(NA)})
}

#' Get a study participant's history of a survey given the userId(Bridge) and surveyGuid
#' https://developer.sagebridge.org/swagger-ui/index.html#/Participants/getParticipantSurveyHistory
#' 
#' @param user_id The userID(Bridge) of the participant
#' @param survey_guid The guid (Globally Unique ID) of the survey 
#' @export
getParticipantSurveyHistory <- function(user_id,
                                        survey_guid){
  tryCatch({
    response <- bridgeGET(glue::glue("/v3/participants/{user_id}/activities/surveys/{survey_guid}"))
    participant <- httr::content(response)
    return(participant)},
    error = function(e){return(NA)})
}

#' Get a study participant's history of a compound activity given the userId(Bridge) and taskId
#' https://developer.sagebridge.org/swagger-ui/index.html#/Participants/getParticipantCompoundActivityHistory
#' 
#' @param user_id The userID(Bridge) of the participant
#' @param task_id The task ID of the task  
#' @export
getParticipantCompoundActivityHistory <- function(user_id,
                                                  task_id){
  tryCatch({
    response <- bridgeGET(glue::glue("/v3/participants/{user_id}/activities/compoundactivities/{task_id}"))
    participant <- httr::content(response)
    return(participant)},
    error = function(e){return(NA)})
}

#--------------------------------------------------------#
# Additional functions derived from ones above
#--------------------------------------------------------#

#' Get all ids(healthCode, externalId, userId) related to a participant given one of them
#' 
#' @param external_id The external ID of the participant
#' @param healthCode  The healthCode of the participant
#' @param user_id The userID(Bridge) of the participant
#' @export
getParticipantIds <- function(healthCode = NULL,
                              external_id = NULL, 
                              user_id = NULL){
  if(!is.null(healthCode)){
    participant <- getParticipant(healthCode = healthCode)
  }else if(!is.null(external_id)){
    participant <- getParticipant(external_id = external_id)
  }else if(!is.null(user_id)){
    participant <- getParticipant(user_id = user_id)
  }
  
  if(is.list(participant)){
    output_list <- list(healthCode = participant$healthCode,
                        externalId = participant$externalIds,
                        userId = participant$id,
                        error = 'none')
  }else{
    output_list <- list(healthCode = healthCode,
                        externalId = external_id,
                        userId = user_id,
                        error = 'unable to get_participant, might be test/deleted user')
  }
  
  return(output_list)
  
}
