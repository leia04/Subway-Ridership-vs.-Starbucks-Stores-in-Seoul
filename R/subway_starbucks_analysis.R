setwd("C:/R")

install.packages("extrafont")
library(extrafont)

# Import and register AppleGothic font for Korean text rendering
font_import(pattern = "AppleGothic")
loadfonts()
par(family = "AppleGothic")


# Read CSV file with automatic row indexing
df <- read.csv("CARD_SUBWAY_MONTH_202310 (3).csv", header = TRUE, row.names = NULL)
head(df)

# Remove the first column (unnecessary index column)
df <- df[, -1]

# Check the modified dataframe
head(df)


### 1. Total number of boarding passengers by subway line
get_on <- aggregate(승차총승객수 ~ 호선명, data = df, sum)

# Sort in descending order
get_on <- get_on[order(-get_on$승차총승객수), ]

# Check results
get_on


### 2. Total number of alighting passengers by subway line
get_off <- aggregate(하차총승객수 ~ 호선명, data = df, sum)

# Sort in descending order
get_off <- get_off[order(-get_off$하차총승객수), ]

# Check results
get_off

# There is no significant difference between boarding and alighting totals


### 3. Total passenger count (boarding + alighting) by line
get <- aggregate(cbind(승차총승객수, 하차총승객수) ~ 호선명, data = df, sum)

# Create a new column for total passengers by line
get$호선별총승객수 <- get$승차총승객수 + get$하차총승객수

# Sort by total passengers
get <- get[order(-get$호선별총승객수), ]

head(get)


### 1-1. Top and bottom 3 stations on Line 2
second <- aggregate(cbind(승차총승객수, 하차총승객수) ~ 역명,
                    data = subset(df, 호선명 == '2호선'), sum)

second$승하차총승객수_2호선 <- second$승차총승객수 + second$하차총승객수
second <- second[order(-second$승하차총승객수_2호선), ]

head(second)
tail(second)


### 1-2. Top and bottom 3 stations on Line 5
fifth <- aggregate(cbind(승차총승객수, 하차총승객수) ~ 역명,
                   data = subset(df, 호선명 == '5호선'), sum)

fifth$승하차총승객수_5호선 <- fifth$승차총승객수 + fifth$하차총승객수
fifth <- fifth[order(-fifth$승하차총승객수_5호선), ]

head(fifth)
tail(fifth)


### 1-3. Top and bottom 3 stations on Line 7
seventh <- aggregate(cbind(승차총승객수, 하차총승객수) ~ 역명,
                     data = subset(df, 호선명 == '7호선'), sum)

seventh$승하차총승객수_7호선 <- seventh$승차총승객수 + seventh$하차총승객수
seventh <- seventh[order(-seventh$승하차총승객수_7호선), ]

head(seventh)
tail(seventh)


### 1-4. Top and bottom 3 stations on Line 3
third <- aggregate(cbind(승차총승객수, 하차총승객수) ~ 역명,
                   data = subset(df, 호선명 == '3호선'), sum)

third$승하차총승객수_3호선 <- third$승차총승객수 + third$하차총승객수
third <- third[order(-third$승하차총승객수_3호선), ]

head(third)
tail(third)


### 4. Total boarding passengers by station
st_on <- aggregate(승차총승객수 ~ 역명, data = df, sum)
st_on <- st_on[order(-st_on$승차총승객수), ]

st_on_h10 <- head(st_on, 10)
st_on_t10 <- tail(st_on, 10)

st_on_h10


### 5. Total alighting passengers by station
st_off <- aggregate(하차총승객수 ~ 역명, data = df, sum)
st_off <- st_off[order(-st_off$하차총승객수), ]

st_off_h10 <- head(st_off, 10)
st_off_t10 <- tail(st_off, 10)

st_off_t10


### 6. Total passengers (boarding + alighting) by station
get_station <- aggregate(cbind(승차총승객수, 하차총승객수) ~ 역명, data = df, sum)

# Create a total passenger column
get_station$역별총승객수 <- get_station$승차총승객수 + get_station$하차총승객수
get_station <- get_station[order(-get_station$역별총승객수), ]

# Select top 40 stations for regression and statistical tests
sb_h40 <- head(get_station, 40)


# Convert passenger counts to numeric for plotting
st_on_h10$승차총승객수 <- as.numeric(st_on_h10$승차총승객수)
st_off_h10$하차총승객수 <- as.numeric(st_off_h10$하차총승객수)

par(mfrow = c(1, 2))

# Bar plot: Top 10 stations by boarding passengers
barplot(st_on_h10$승차총승객수, names.arg = st_on_h10$역명, las = 2,
        main = "Top 10 Stations (Boarding)")

# Bar plot: Top 10 stations by alighting passengers
barplot(st_off_h10$하차총승객수, names.arg = st_off_h10$역명, las = 2,
        main = "Top 10 Stations (Alighting)")


# Bottom 10 station comparison
st_on_t10$승차총승객수 <- as.numeric(st_on_t10$승차총승객수)
st_off_t10$하차총승객수 <- as.numeric(st_off_t10$하차총승객수)

par(mfrow = c(1, 2))

barplot(st_on_t10$승차총승객수, names.arg = st_on_t10$역명, las = 2,
        main = "Bottom 10 Stations (Boarding)")

barplot(st_off_t10$하차총승객수, names.arg = st_off_t10$역명, las = 2,
        main = "Bottom 10 Stations (Alighting)")


# Starbucks store analysis for top stations in Seoul
# Load Starbucks dataset
top_df <- read.csv("top_station_starbucks.csv", header = TRUE)

# Count Starbucks stores by station
top_counts <- table(top_df$역.명)

# Convert to dataframe
seoul_tp10_sb <- as.data.frame(top_counts)
colnames(seoul_tp10_sb) <- c("station", "number_of_starbucks")

library(dplyr)

# Merge passenger data with Starbucks counts
sb_h10 <- left_join(sb_h10, seoul_tp10_sb, by = c("역명" = "station"))


# Regression analysis between passenger count and Starbucks stores
library(ggplot2)

model <- lm(승하차수 ~ 스타벅스매장수, data = top40)
summary(model)

ggplot(top40, aes(x = 스타벅스매장수, y = 승하차수)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(x = "Number of Starbucks Stores", y = "Total Passengers") +
  ggtitle("Regression Analysis: Passengers vs. Starbucks Stores")


# Group comparison using ANOVA
top40$group <- factor(rep(1:4, each = 10))

anova_result <- aov(승하차수 ~ group, data = top40)
summary(anova_result)
