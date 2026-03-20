library(tidyverse) 
library(data.table)
library(magick)

# download pictures from url

# get the list of images from the csv files
myfiles <- list.files(pattern = "*.csv") %>% 
           map_df(~fread(.))

# we are not efficient in downloading tweet information so there are overlaps
myfiles_uniq <- unique(myfiles)

# there are some replies without images!
myfiles_jpg <- myfiles_uniq %>% filter(str_detect(media_url, ".jpg"))

# test download does not work very well
# download.file("http://pbs.twimg.com/media/EZuawlTUYAE2h1A.jpg", "images/EZuawlTUYAE2h1A.jpg")

# image links
# img_link_100 <- myfiles_jpg$media_url[1:100]

#image names
# img_names_100 <- paste0("images/", basename(img_link_100))

# download file does not seem to work but let's try anyway
# https://www.storybench.org/scraping-html-tables-and-downloading-files-with-r/
# purrr::walk2(.x = img_link_100, 
#              .y = img_names_100, 
#              .f = download.file)

# magick seems to be great at images
# https://cran.r-project.org/web/packages/magick/vignettes/intro.html#Read_and_write
# img <- image_read("http://pbs.twimg.com/media/EZuawlTUYAE2h1A.jpg")

# this shows up fine! 
# print(img) 

# this writes very well! 
# image_write(img, "images/EZuawlTUYAE2h1A.jpg")

# we can get a vector of pointers to images it seems
# imgs_100 <- image_read(img_link_100)

# but we cannot write a vector of images (it was worth a try)
# image_write(imgs, img_names_100)

# let us write our own function for the purrrpose of downloading
image_read_write <- function(link, name) {
    print(name)
    if (!file.exists(name)) {
    img = image_read(link)
    image_write(img, name) 
  }
}

# individual attempts first
# link1 = img_link[55]
# name1 = img_names[55]

# looks good to me, can do 1 image
# image_read_write(link1, name1)

# can do 100 images! 
# purrr::walk2(img_link_100, img_names_100, image_read_write)

# sorry twitter if this bothers you
img_link_all <- myfiles_jpg$media_url
img_names_all <- paste0("images/", basename(img_link_all))
purrr::walk2(img_link_all, img_names_all, image_read_write)



# resize for a nice time training
# img1 <- img_names_all[1999]

# pointer to image
# img_p <- image_read(img1)

# resize or scale image
# img_s <- image_scale(img_p, "128x")

# change the name
# img_n <- str_replace(img1, "images", "images128")

# write to the smaller size
# image_write(img_s, img_n)

# function! 
image_scale_128 <- function(img) {
  img_n <- str_replace(img, "images", "images128")
  if (!file.exists(img_n)) {
    print(img_n)
    img_p = image_read(img)           # pointer
    img_s = image_scale(img_p, "128") # scaled
    image_write(img_s, img_n)         # write to new folder
  }
}

# tester 
# image_scale_128(img1)

# do it
purrr::walk(img_names_all, image_scale_128)



# resize pictures to be a reasonable size
# what is a reasonable size for a neural network? 
# let's do some testing on small sizes first for timing
# also just look at the pictures to see what is recognisable
# there are some pictures where street view has no imagery
# remove anything where the picture is just about all grey


