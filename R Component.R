# importing packages/libraries
#library(httr)
#library(glue)
library(jsonlite)
library(websocket)

count <- 0
ws <- websocket::WebSocket$new('wss://ws-feed.exchange.coinbase.com',autoConnect = FALSE)

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
  print(paste(product_id,":",change_type,price,count))
  count <- count + 1
})

ws$onClose(function(event) {
  cat("Client disconnected\n")
})

ws$onOpen(function(event) {
  cat("Client connected\n")
})

ws$connect()
Sys.sleep(8)
ws$send("{\"type\": \"subscribe\",\"channels\": [\"level2\"],\"product_ids\": [\"BTC-USD\"]}")
Sys.sleep(1)
ws$close()

#sqldf('SELECT
#      JSON_VALUE(json_data, \'$.type\') AS type,
#      JSON_VALUE(json_data, \'$.product_id\') AS product_id,
#      JSON_VALUE(json_data, \'$.changes[0][0]\') AS change_type,
#      JSON_VALUE(json_data, \'$.changes[0][1]\') AS change_value,
#      JSON_VALUE(json_data, \'$.changes[0][2]\') AS change_amount,
#      JSON_VALUE(json_data, \'$.time\') AS time
#      FROM
#      data_table;'
#)