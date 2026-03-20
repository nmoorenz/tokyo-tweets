# always with the libraries
library(rtweet)
library(tidyverse)
library(lubridate)
library(glue)

# because rtweet says so
get_token()

# our interesting account
tt <- get_timeline("@everylottokyo", n = 300)

# today date for the file save
filedate <- format(now(), "%Y-%m-%d-%H-%M")

# only interested in some things
# tweets are never a reply or retweet or quote
# most interested in the image
my_cols = c("user_id", "status_id", "created_at", "screen_name", "text", 
            "favorite_count", "retweet_count", "media_url")

# select columns
tt_2 <- tt[my_cols]

# media_url is returned as a list but easily fixed
tt_3 <- unnest(tt_2, cols = c(media_url))

# save for posterity
write_csv(tt_3, glue("tokyo-tweets-{filedate}.csv"))

# general interaction variable
# this is what we want to predict
tt_3 <- tt_3 %>% 
  mutate(interaction_count = favorite_count + retweet_count, 
         interaction = interaction_count > 0)

# check on balance
tt_3 %>% count(interaction)

# let's also check on time of day
tt_3 <- tt_3 %>% 
  mutate(create_dt = as.POSIXct(created_at), 
         create_hh = round_time(create_dt, "30 minutes"), 
         halfhour = format(create_hh, "%H:%M"))

# plotting
tt_3 %>% 
  group_by(halfhour) %>% 
  summarise(interactions = sum(interaction)) %>% 
  ggplot(aes(halfhour, interactions)) + 
  geom_col() + 
  theme_light() +
  scale_x_discrete()
