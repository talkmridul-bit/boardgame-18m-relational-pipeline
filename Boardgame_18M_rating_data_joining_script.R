library(tidyverse)
library(readr)

data_rating<- read_csv(file.choose())
data_rating

glimpse(data_rating)


data_subcategory<- read_csv(file.choose())
data_subcategory
glimpse(data_subcategory)

cleaned_data_rating<- data_rating %>% distinct() %>%
  mutate(
    BGGId = as.integer(BGGId),
    Rating = as.numeric(Rating)
  ) %>% filter(BGGId > 0 & Rating > 0 )
cleaned_data_rating

cleaned_data_subcategory<- data_subcategory %>% distinct() %>%
  mutate(
    BGGId = as.integer(BGGId),
    
  ) %>% filter(BGGId > 0 )
cleaned_data_subcategory

join_report<- data_rating %>% 
  inner_join(data_subcategory,by='BGGId')

glimpse(join_report)

final_report<- join_report %>% 
  select(BGGId,Rating,Username,Puzzle,Exploration,Electronic)
write.csv(final_report,'Boardgame_18M_rating_join_data.csv',
          row.names = FALSE)
getwd()
