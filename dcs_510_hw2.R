### Finding Best Mexican Restaurants in Winston-Salem city

source("./yelp_api_key.R")

base_uri<-"https://api.yelp.com/v3"
end_point<-"/businesses/search"
search_uri<-paste0(base_uri,end_point)
print(search_uri)

query_params <- list(
  term = "restaurant" ,
  categories = "mexican" ,
  location = "Winston-Salem, NC" ,
  sort_by = "rating" ,
  radius = 10000
)
print(query_params)
#install.packages("httr")
library(httr)
response <- GET(
  search_uri, query = query_params,
  add_headers(Authorization = paste("bearer", yelp_key))
)
response_text <- content(response, type ="text")

#install.packages("jsonlite")
library(jsonlite)
response_data<-fromJSON(response_text)

restaurants<- flatten(response_data$businesses)
print(restaurants)
View(restaurants)
#install.packages("dplyr")
library(dplyr)
restaurants <- restaurants %>%
  filter(review_count >= 30) %>%
  arrange(-rating) %>%
  mutate(Rank=row_number()) %>%
  mutate("Restaurant Name" = name) %>%
  mutate(Rating = rating) %>%
  mutate("Review Count" =  review_count) %>%
  mutate("Address" = paste0(location.address1, location.city, location.zip_code, location.state)) %>%
  mutate("Phone Number" = phone) %>%
  select(Rank, "Restaurant Name", Rating, "Review Count", Address, "Phone Number")
  
print(restaurants)
View(restaurants)
write.csv(restaurants, file = "./ws_mexican_restaurants.csv", append= FALSE, row.names=FALSE)
  
#install.packages("dbplyr")
library(DBI)
#install.packages("RSQLite")
library(RSQLite)
db_connect <- dbConnect(SQLite(),dbname= "C://Users/GODFREDS/Documents/dcs510.db")
dbListTables(db_connect)
restaurants_table<- tbl(db_connect, "restaurants_table")
           
restaurants_table         
resturants_best <- restaurants_table %>% 
  filter(Rank >= 4.5)




