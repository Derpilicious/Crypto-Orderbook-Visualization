#importing packages/libraries
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

# dfdataframe <- data.frame(product_id = character(),
#                           change_type = character(),
#                           price = character(),
#                           stringsAsFactors = FALSE)

wsconnection <- FALSE

ws$onMessage(function(message) {
  #print(message$data)
  parsed_json <- fromJSON(message$data)
  # Create separate columns for each key-value pair
  type <- parsed_json$type
  if (type == "snapshot"){
    print("Snapshot received!")
    snapshot <<- parsed_json
  }
  #count <<- count + 1
  #print(paste(product_id,":",change_type,price,count))
  #dfdataframe[nrow(dfdataframe) + 1,] <<- list(product_id, change_type, price, count)
  #dfdataframe$price[nrow(dfdataframe)] <- as.numeric(as.character(dfdataframe$price[nrow(dfdataframe)]))
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

for (x in 1:1){
  ws$send("{\"type\": \"subscribe\",\"channels\": [\"level2_batch\"],\"product_ids\": [\"BTC-USD\"]}")
  
  start <- as.numeric(Sys.time())

  while(as.numeric(Sys.time())-start < 1) {
  }

  ws$send("{\"type\": \"unsubscribe\",\"channels\": [\"level2_batch\"],\"product_ids\": [\"BTC-USD\"]}")

  #ws$close()

  start <- as.numeric(Sys.time())

  asks_df <- data.frame(change_type = rep("asks", length(snapshot$asks[,1])), price = snapshot$asks[,1], depth = snapshot$asks[,2])

  bids_df <- data.frame(change_type = rep("bids", length(snapshot$bids[,1])), price = snapshot$bids[,1], depth = snapshot$bids[,2])

  df <- rbind(asks_df, bids_df)

  # df <- list(change_type = c(rep("ask", length(parsed_json$asks)), rep("buy", length(parsed_json$buys))),
  #            value = c(sapply(parsed_json$asks),sapply(parsed_json$bids)))
  
  dbWriteTable(conn = conn, 
               name = "Crypto Orderbook Data", 
               value = df,
               overwrite = TRUE)
}
ws$close()

head(df)

#min(na.omit(as.numeric(df[df$change_type == "asks", "price"])))
#max(na.omit(as.numeric(df[df$change_type == "bids", "price"])))