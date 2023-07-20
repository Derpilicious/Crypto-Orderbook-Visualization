# importing packages/libraries
#library(httr)
library(jsonlite)
#library(glue)
library(websocket)

ws <- websocket::WebSocket$new('wss://ws-feed.exchange.coinbase.com',autoConnect = FALSE)

ws$onMessage(function(message) {
  d <- message$data
  print(message$data)
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
