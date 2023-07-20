install.packages(glue)
# importing packages/libraries
library(httr)
library(jsonlite)
library(glue)
# declaring all pairs of currency pairs we need
pairs < - c("DOGEUSDT", "BTCUSDT", "ETHUSDT")

# running loop
for (i in 1: 3){
  p < - pairs[i]  # storing pair in p variable by it's index value
  
  # completing url and storing it in url variable
  url = paste0("6bee1498-9d86-4e83-bd5e-4d56865abb9e", p)
  r < - GET(url)  # requesting url data
  res = rawToChar(r$content)  # converting raw content to char format
  data = fromJSON(res)  # converting char to json format
  
  # storing keys and values of json data in separate variables
  pair < - data$symbol
  value < - data$price
  
  # printing output
  print(paste(pair, "price is", value))
}