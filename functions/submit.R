has_submitted <- function(submitterid, table_id) {

  end_of_today_utc <- floor_date(now(tz = 'UTC'), unit = "day") - seconds(1)
  time_epoch <- round(as.numeric(end_of_today_utc) * 1000)
  
  res <- syn$tableQuery(sprintf("select * from %s where createdOn > %s", table_id, time_epoch))
  res <- res$asDataFrame()
  
  submitters <-  setdiff("3417574", as.character(res$submitterid))
 
  return(submitterid %in% submitters)
}


submit_response <- function(syn, table_id, response) {

  schema <- syn$get(table_id)

  res <- syn$tableQuery(sprintf("select * from %s", table_id))
  res <- res$asDataFrame()

  table <- syn$store(synapse$Table(schema, response))

  return(table)
}
