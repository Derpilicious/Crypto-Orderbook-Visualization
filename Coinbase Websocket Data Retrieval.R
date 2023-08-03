# importing packages/libraries
#library(httr)
#library(glue)
library(jsonlite)
library(websocket)
library(odbc)
library(DBI)

ws <- websocket::WebSocket$new('wss://ws-feed.exchange.coinbase.com')

conn <- DBI::dbConnect(
  odbc::odbc(),
  driver = "SQL Server",
  server = ".\\SQLEXPRESS",
  database = "Crypto Orderbook Data",
  uid = ".\\Roy Luo",
  Trusted_Connection = "True",
  options(connectionObserver = NULL)
) 

count <- -2

dfdataframe <- data.frame(product_id = character(),
                          change_type = character(),
                          price = character(),
                          count = character(),
                          stringsAsFactors = FALSE)

duration <- 2

wsconnection <- FALSE

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
  dfdataframe[nrow(dfdataframe) + 1,] <<- list(product_id, change_type, price, count)
  dfdataframe$price[nrow(dfdataframe)] <- as.numeric(as.character(dfdataframe$price[nrow(dfdataframe)]))
})

ws$onClose(function(event) {
  cat("Client disconnected!\n")
})

ws$onOpen(function(event) {
  cat("Client connected!\n")
  wsconnection <<- TRUE
})

ws$connect()
  
while (TRUE){
  if (wsconnection){
    break
  }
}
  
ws$send("{\"type\": \"subscribe\",\"channels\": [\"level2\"],\"product_ids\": [\"DOGE-USD\"]}")

start <- as.numeric(Sys.time())

while(as.numeric(Sys.time())-start < duration) {
}

ws$close()

#Sys.sleep(5)

dbWriteTable(conn = conn, 
             name = "Crypto Orderbook Data", 
             value = dfdataframe,
             overwrite = TRUE)

head(dfdataframe)
# mean(na.omit(as.numeric(df[df$change_type == "buy", "price"]), na.rm = TRUE))
# mean(na.omit(as.numeric(df[df$change_type == "sell", "price"]), na.rm = TRUE))