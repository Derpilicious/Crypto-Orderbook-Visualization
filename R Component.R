# importing packages/libraries
#library(httr)
#library(glue)
library(jsonlite)
library(websocket)
library(powerbiR)
#library(odbc)

ws <- websocket::WebSocket$new('wss://ws-feed.exchange.coinbase.com',autoConnect = FALSE)

df <- data.frame(product_id = character(),
                 change_type = character(),
                 price = character(),
                 count = character(),
                 stringsAsFactors = FALSE)

count <- -2

ws$onMessage(function(message) {
  #print(message$data)
  parsed_json <- fromJSON(message$data)
  # Create separate columns for each key-value pair
  type <- parsed_json$type
  product_id <- parsed_json$product_id
  change_type <- parsed_json$changes[1]
  price <- parsed_json$changes[2]
  amount <- parsed_json$changes[3]
  time <- parsed_json$time
  count <<- count + 1
  print(paste(product_id,":",change_type,price,count))
  #df[nrow(df) + 1,] <<- list(product_id, change_type, price, count)
})

ws$onClose(function(event) {
  cat("Client disconnected!\n")
})

ws$onOpen(function(event) {
  cat("Client connected!\n")
})

pbi_auth(
  tenant = "f8cdef31-a31e-4b4a-93e4-5f571e91255a", # The tenant ID
  app = "c520d6e2-a0a8-4d54-9dc9-995caf0f4bfc", # The app ID
  password = "jU18Q~Nb4m0a1UxB.ikwa4nZaQQi2rQpfYuwvcnQ" # The client secret
)

Sys.setenv(
  PBI_TENANT = "f8cdef31-a31e-4b4a-93e4-5f571e91255a",
  PBI_APP = "c520d6e2-a0a8-4d54-9dc9-995caf0f4bfc",
  PBI_PW = "jU18Q~Nb4m0a1UxB.ikwa4nZaQQi2rQpfYuwvcnQ"
)

pbi_auth()
pbi_list_groups()
# Use data from the powerbiR package
data(dim_hour)
data(fact_visitors)
# Define dataset and its tables
table_list <- list(fact_visitors, dim_hour)
table_names <- c("visitors", "hour")
dataset_name <- c("Online Visitors")
# Define relations between tables
relation <- pbi_schema_relation_create(
  from_table = "visitors",
  from_column = "hour_key",
  to_table = "hour"
)
# Define sorting behavior of columns in the hour table
sortlist = list(
  table = c("hour"),
  sort = c("hour"),
  sort_by = c("hour_key")
)
# Hide hour_key in the hour and visitors tables
hidden <- list(
  list(
    table = c("hour"),
    hidden = c("hour_key")
  ),
  list(
    table = c("visitors"),
    hidden = c("hour_key", "visitor_id")
  )
)
# Create schema
schema <- pbi_schema_create(
  dt_list = table_list,
  dataset_name = dataset_name,
  table_name_list = table_names,
  relations_list = list(relation),
  sort_by_col = list(sortlist),
  hidden_col = hidden
)
pbi_list_groups()
pbi_list_datasets("https://app.powerbi.com/groups/me/list?experience=power-bi")
# ws$connect()
# Sys.sleep(10)
# ws$send("{\"type\": \"subscribe\",\"channels\": [\"level2\"],\"product_ids\": [\"BTC-USD\"]}")
# Sys.sleep(1)
# ws$close()
# 
# df$price <- as.numeric(as.character(df$price))
# dim(df)
# summary(df)
# head(df)
