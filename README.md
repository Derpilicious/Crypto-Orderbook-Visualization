# Crypto Orderbook

Orderbook visualization for cryptocurrencies. Uses R to retrieve data from Coinbase websocket, format and upload it to a SQL Server which is then "live streamed" (loaded using DirectQuery) to a PowerBI dashboard. 

![](https://github.com/Derpilicious/Crypto-Orderbook-Visualization/blob/main/example.gif)
###### This is a 2x recording of what the dashboard looks like when the R script is running to collect the most current data. 

The PowerBI file in this repository is currently loaded using a CSV with mock data as there is no way to publish a dashboard connected to a SQL Server without a data gateway which I do not have permission to get with a Waterloo email. 

The focus on this project was more about setting up the technical side of the data pipeline rather than a focus on what data was being visually displayed, although that would definitely be my next priority. Hence, my next steps could be to take in more data from some of the other channels of the Coinbase websocket and display that data on the dashboard as well, such as the matches, ticker or even level3 channels. 