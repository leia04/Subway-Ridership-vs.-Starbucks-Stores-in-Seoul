############################################################
# 01_prepare_and_eda.R
# - Load raw subway data
# - Compute line/station aggregates
# - Create Top/Bottom comparisons
# - Save key EDA plots to ./figures/
############################################################

source("R/00_setup.R")

############################################################
# 1) Load raw monthly subway data (Oct 2023)
############################################################

df <- read.csv("data/CARD_SUBWAY_MONTH_202310 (3).csv", header = TRUE, row.names = NULL)

# Remove the first index-like column
df <- df[, -1]

############################################################
# 2) Line-level totals (boarding / alighting / total)
############################################################

get_on <- aggregate(승차총승객수 ~ 노선명, data = df, sum)
get_on <- get_on[order(-get_on$승차총승객수), ]

get_off <- aggregate(하차총승객수 ~ 노선명, data = df, sum)
get_off <- get_off[order(-get_off$하차총승객수), ]

get <- aggregate(cbind(승차총승객수, 하차총승객수) ~ 노선명, data = df, sum)
get$호선별총승객수 <- get$승차총승객수 + get$하차총승객수
get <- get[order(-get$호선별총승객수), ]

############################################################
# 3) For major lines (2,5,7,3): top/bottom stations
############################################################

second <- aggregate(cbind(승차총승객수, 하차총승객수) ~ 역명, data = subset(df, 노선명 == "2호선"), sum)
second$승하차총승객수_2호선 <- second$승차총승객수 + second$하차총승객수
second <- second[order(-second$승하차총승객수_2호선), ]

fifth <- aggregate(cbind(승차총승객수, 하차총승객수) ~ 역명, data = subset(df, 노선명 == "5호선"), sum)
fifth$승하차총승객수_5호선 <- fifth$승차총승객수 + fifth$하차총승객수
fifth <- fifth[order(-fifth$승하차총승객수_5호선), ]

seventh <- aggregate(cbind(승차총승객수, 하차총승객수) ~ 역명, data = subset(df, 노선명 == "7호선"), sum)
seventh$승하차총승객수_7호선 <- seventh$승차총승객수 + seventh$하차총승객수
seventh <- seventh[order(-seventh$승하차총승객수_7호선), ]

third <- aggregate(cbind(승차총승객수, 하차총승객수) ~ 역명, data = subset(df, 노선명 == "3호선"), sum)
third$승하차총승객수_3호선 <- third$승차총승객수 + third$하차총승객수
third <- third[order(-third$승하차총승객수_3호선), ]

############################################################
# 4) Station-level totals (boarding / alighting / total)
############################################################

st_on <- aggregate(승차총승객수 ~ 역명, data = df, sum)
st_on <- st_on[order(-st_on$승차총승객수), ]
st_on_h10 <- head(st_on, 10)
st_on_t10 <- tail(st_on, 10)

st_off <- aggregate(하차총승객수 ~ 역명, data = df, sum)
st_off <- st_off[order(-st_off$하차총승객수), ]
st_off_h10 <- head(st_off, 10)
st_off_t10 <- tail(st_off, 10)

get_station <- aggregate(cbind(승차총승객수, 하차총승객수) ~ 역명, data = df, sum)
get_station$역별총승객수 <- get_station$승차총승객수 + get_station$하차총승객수
get_station <- get_station[order(-get_station$역별총승객수), ]

# Bottom-10 Seoul stations (pre-selected)
bt_st_seoul <- c("구반포","도림천","남태령","신답","응봉","삼양","버티고개","신내","학여울","개화")
sb_t10 <- get_station[get_station$역명 %in% bt_st_seoul, ]
sb_h10 <- head(get_station, 10)
sb_h40 <- head(get_station, 40)

############################################################
# 5) Save EDA plots (Base R)
############################################################

st_on_h10$승차총승객수 <- as.numeric(st_on_h10$승차총승객수)
st_off_h10$하차총승객수 <- as.numeric(st_off_h10$하차총승객수)
st_on_t10$승차총승객수 <- as.numeric(st_on_t10$승차총승객수)
st_off_t10$하차총승객수 <- as.numeric(st_off_t10$하차총승객수)
sb_h10$역별총승객수 <- as.numeric(sb_h10$역별총승객수)
sb_t10$역별총승객수 <- as.numeric(sb_t10$역별총승객수)

png("figures/Fig01_Top10_Boarding_vs_Alighting.png", width = 1800, height = 900, res = 200)
par(mfrow = c(1, 2), mar = c(9, 4, 4, 2))
barplot(st_on_h10$승차총승객수, names.arg = st_on_h10$역명, las = 2,
        main = "Top 10 Stations (Boarding)", ylab = "Passengers")
barplot(st_off_h10$하차총승객수, names.arg = st_off_h10$역명, las = 2,
        main = "Top 10 Stations (Alighting)", ylab = "Passengers")
safe_dev_off()

png("figures/Fig02_Bottom10_Boarding_vs_Alighting.png", width = 1800, height = 900, res = 200)
par(mfrow = c(1, 2), mar = c(9, 4, 4, 2))
barplot(st_on_t10$승차총승객수, names.arg = st_on_t10$역명, las = 2,
        main = "Bottom 10 Stations (Boarding)", ylab = "Passengers")
barplot(st_off_t10$하차총승객수, names.arg = st_off_t10$역명, las = 2,
        main = "Bottom 10 Stations (Alighting)", ylab = "Passengers")
safe_dev_off()

png("figures/Fig03_TopBottom10_TotalPassengers.png", width = 1800, height = 900, res = 200)
par(mfrow = c(1, 2), mar = c(9, 4, 4, 2))
barplot(sb_h10$역별총승객수, names.arg = sb_h10$역명, las = 2,
        main = "Top 10 Stations (Total Passengers)", ylab = "Passengers")
barplot(sb_t10$역별총승객수, names.arg = sb_t10$역명, las = 2,
        main = "Bottom 10 Stations (Total Passengers)", ylab = "Passengers")
safe_dev_off()

############################################################
# 6) Top 10 stations + Starbucks counts
############################################################

top_df <- read.csv("data/top_station_starbucks.csv", header = TRUE)
top_counts <- table(top_df$역.명)
seoul_tp10_sb <- as.data.frame(top_counts)
colnames(seoul_tp10_sb) <- c("station", "스타벅스매장수")

sb_h10 <- left_join(sb_h10, seoul_tp10_sb, by = c("역명" = "station"))
sb_h10$스타벅스매장수 <- as.numeric(sb_h10$스타벅스매장수)

# Bottom-10 Starbucks counts were manually entered in the original workflow
sb_t10$스타벅스매장수 <- c(0, 1, 0, 0, 0, 0, 1, 0, 0, 0)
sb_t10$스타벅스매장수 <- as.numeric(sb_t10$스타벅스매장수)

png("figures/Fig04_Top10_StarbucksCounts.png", width = 1800, height = 900, res = 200)
par(mar = c(9, 4, 4, 2))
barplot(sb_h10$스타벅스매장수,
        names.arg = sb_h10$역명,
        col = "skyblue",
        main = "Top 10 Stations: Starbucks Store Count",
        ylab = "Number of Starbucks",
        las = 2)
safe_dev_off()

png("figures/Fig05_Bottom10_StarbucksCounts.png", width = 1800, height = 900, res = 200)
par(mar = c(9, 4, 4, 2))
barplot(sb_t10$스타벅스매장수,
        names.arg = sb_t10$역명,
        col = "skyblue",
        main = "Bottom 10 Stations: Starbucks Store Count",
        ylab = "Number of Starbucks",
        las = 2)
safe_dev_off()

png("figures/Fig06_Scatter_Top10_Passengers_vs_Starbucks.png", width = 1400, height = 1000, res = 200)
par(mar = c(5, 5, 4, 2))
plot(sb_h10$역별총승객수, sb_h10$스타벅스매장수,
     main = "Top 10: Total Passengers vs Starbucks",
     xlab = "Total passengers (boarding + alighting)",
     ylab = "Number of Starbucks",
     pch = 19, col = "darkgreen")
text(sb_h10$역별총승객수, sb_h10$스타벅스매장수, labels = sb_h10$역명, pos = 4, cex = 0.7)
safe_dev_off()

png("figures/Fig07_Scatter_Bottom10_Passengers_vs_Starbucks.png", width = 1400, height = 1000, res = 200)
par(mar = c(5, 5, 4, 2))
plot(sb_t10$역별총승객수, sb_t10$스타벅스매장수,
     main = "Bottom 10: Total Passengers vs Starbucks",
     xlab = "Total passengers (boarding + alighting)",
     ylab = "Number of Starbucks",
     pch = 19, col = "orange")
text(sb_t10$역별총승객수, sb_t10$스타벅스매장수, labels = sb_t10$역명, pos = 4, cex = 0.7)
safe_dev_off()

# Save objects for modeling step
saveRDS(list(
  df = df,
  get_station = get_station
), file = "figures/_intermediate_prepare.rds")
