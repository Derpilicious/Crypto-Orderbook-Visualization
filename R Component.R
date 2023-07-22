# importing packages/libraries
#library(httr)
library(jsonlite)
#library(glue)
library(websocket)

ws <- websocket::WebSocket$new('wss://ws-feed.exchange.coinbase.com',autoConnect = FALSE)

ws$onMessage(function(message) {
  #print(message$data)
  parsed_json <- fromJSON(json_string)
  
  # Create separate columns for each key-value pair
  type <- parsed_json$type
  product_id <- parsed_json$product_id
  change_type <- parsed_json$changes[[1]][1]
  price <- as.numeric(parsed_json$changes[[1]][2])
  amount <- as.numeric(parsed_json$changes[[1]][3])
  time <- parsed_json$time
  
  # Combine the extracted data into a data frame
  result_df <- data.frame(type, product_id, change_type, price, amount, time)
})

ws$onClose(function(event) {
  cat("Client disconnected\n")
})

ws$onOpen(function(event) {
  cat("Client connected\n")
})

ws$connect()
Sys.sleep(10)
ws$send("{\"type\": \"subscribe\",\"channels\": [\"level2\"],\"product_ids\": [\"BTC-USD\"]}")
Sys.sleep(3)
ws$close()



# Print the result
print(result_df)


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