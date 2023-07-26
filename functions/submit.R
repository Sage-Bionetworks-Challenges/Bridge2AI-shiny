submit_response <- function(syn, table_id, response) {

  schema <- syn$get(table_id)

  res <- syn$tableQuery(sprintf("select * from %s", table_id))
  res <- res$asDataFrame()

  table <- syn$store(synapse$Table(schema, new_res))

  return(table)
}
