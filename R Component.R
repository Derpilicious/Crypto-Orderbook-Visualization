# importing packages/libraries
#library(httr)
#library(glue)
library(jsonlite)
library(websocket)
library(odbc)
library(DBI)

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
Sys.sleep(1)
ws$close()

df$price <- as.numeric(as.character(df$price))

conn <- DBI::dbConnect(
  odbc::odbc(),
  driver = "SQL Server",
  server = ".\\SQLEXPRESS",
  database = "Crypto Orderbook Data",
  uid = ".\\Roy Luo",
  Trusted_Connection = "True",
  options(connectionObserver = NULL)
) 

dbWriteTable(conn = conn, 
             name = "Crypto Orderbook Data", 
             value = df,
             overwrite = TRUE)

head(df)
mean(na.omit(as.numeric(df[df$change_type == "buy", "price"]), na.rm = TRUE))
mean(na.omit(as.numeric(df[df$change_type == "sell", "price"]), na.rm = TRUE))