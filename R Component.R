# importing packages/libraries
#library(httr)
#library(glue)
library(jsonlite)
library(websocket)
#library(powerbiR)
library(odbc)

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
  df[nrow(df) + 1,] <<- list(product_id, change_type, price, count)
})

ws$onClose(function(event) {
  cat("Client disconnected!\n")
})

ws$onOpen(function(event) {
  cat("Client connected!\n")
})

ws$connect()
Sys.sleep(10)
ws$send("{\"type\": \"subscribe\",\"channels\": [\"level2\"],\"product_ids\": [\"BTC-USD\"]}")
#Sys.sleep(10)
#ws$close()

df$price <- as.numeric(as.character(df$price))
dim(df)
summary(df)
head(df)
