#importing packages/libraries
library(jsonlite)
library(websocket)
library(odbc)
library(DBI)

#establishing websocket connection
ws <- websocket::WebSocket$new('wss://ws-feed.exchange.coinbase.com')

#establishing SQL Server connection
conn <- DBI::dbConnect(
  odbc::odbc(),
  driver = "SQL Server",
  server = ".\\SQLEXPRESS",
  database = "Crypto Orderbook Data",
  uid = ".\\Roy Luo",
  Trusted_Connection = "True",
  options(connectionObserver = NULL)
) 

#setting websocket connection to default state of false
wsconnection <- FALSE

#Verifying that snapshot has been received and assinging it to a global variable
ws$onMessage(function(message) {
  #print(message$data)
  parsed_json <- fromJSON(message$data)
  # Create separate columns for each key-value pair
  type <- parsed_json$type
  if (type == "snapshot"){
    print("Snapshot received!")
    snapshot <<- parsed_json
  }
})

#closing websocket connection
ws$onClose(function(event) {
  cat("Client disconnected!\n")
})

#opening websocket connection
ws$onOpen(function(event) {
  cat("Client connected!\n")
  wsconnection <<- TRUE
})

#connecting to websocket
ws$connect()
  
#proceeding only if the connection has been established
while (TRUE){
  if (wsconnection){
    break
  }
}

for (x in 1:1){
  #sending channel subscription message
  ws$send("{\"type\": \"subscribe\",\"channels\": [\"level2_batch\"],\"product_ids\": [\"BTC-USD\"]}")
  
  #delay of 1 second
  start <- as.numeric(Sys.time())
  while(as.numeric(Sys.time())-start < 1) {
  }
  
  #closing channel subscription
  ws$send("{\"type\": \"unsubscribe\",\"channels\": [\"level2_batch\"],\"product_ids\": [\"BTC-USD\"]}")
  
  #assigning a tolerance value to keep values within that price range
  tolerance <- 0.01
  
  #price interval
  interval = 1
  
  #assigning all asks orders to a df
  asks_df <- data.frame(change_type = rep("asks", length(snapshot$asks[,1])), price = snapshot$asks[,1], depth = snapshot$asks[,2])
  
  asks_df$price <- as.numeric(asks_df$price)
  
  asks_df$depth <- as.numeric(asks_df$depth)
  
  asks_df <- asks_df[asks_df$price >= min(asks_df$price) * (1-tolerance) & asks_df$price <= min(asks_df$price) * (1+ tolerance), ]
  
  asks_df$priceintervals <- floor(asks_df$price / interval) * interval
  
  asks_df$cumulativedepth <- sapply(seq_len(nrow(asks_df)), function(i) {
    sum(asks_df$depth[asks_df$price <= asks_df$priceinterval[i]])
  })
  
  #assigning all bids orders to a df
  #bids_df <- data.frame(change_type = rep("bids", length(snapshot$bids[,1])), price = snapshot$bids[,1], depth = snapshot$bids[,2])
  
  #bids_df <- bids_df[bids_df$price >= max(bids_df$price) * (1-tolerance) & bids_df$price <= max(bids_df$price) * (1+ tolerance), ]
  
  #binding both dfs together
  #df <- rbind(asks_df, bids_df)
  
  #writing to SQL Server
  #dbWriteTable(conn = conn, 
               #name = "Crypto Orderbook Data", 
               #value = df,
               #overwrite = TRUE)
}

#closing websocket connection
ws$close()



#min(na.omit(as.numeric(df[df$change_type == "asks", "price"])))
#max(na.omit(as.numeric(df[df$change_type == "bids", "price"])))