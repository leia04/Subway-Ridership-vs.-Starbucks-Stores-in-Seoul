############################################################
# 02_modeling.R
# - Build Top40 analysis dataset
# - Regression + ANOVA
# - Save a clean README-ready regression plot to ./figures/
############################################################

source("R/00_setup.R")

# Load intermediate objects if available (optional)
if (file.exists("figures/_intermediate_prepare.rds")) {
  tmp <- readRDS("figures/_intermediate_prepare.rds")
  get_station <- tmp$get_station
}

############################################################
# 7) Top 40 merge using Starbucks cross file (monthly totals version)
############################################################

df_40 <- read.csv("data/상위 40개 역 스벅 교차수정 (1).csv", header = TRUE, row.names = NULL)
unique_stations <- unique(df_40$역.명)

top40_st <- as.data.frame(table(df_40$역.명))
colnames(top40_st) <- c("역명", "스타벅스매장수")

top40_passenger <- get_station[get_station$역명 %in% unique_stations, ]
top40_final <- left_join(top40_st, top40_passenger, by = c("역명" = "역명"))
top40_final$스타벅스매장수[top40_final$역명 == "대림(구로구청)"] <- 0

png("figures/Fig08_Scatter_Top40_MonthlyTotals.png", width = 1400, height = 1000, res = 200)
par(mar = c(5, 5, 4, 2))
plot(top40_final$역별총승객수, top40_final$스타벅스매장수,
     main = "Top 40: Total Passengers vs Starbucks (Monthly totals)",
     xlab = "Total passengers (boarding + alighting)",
     ylab = "Number of Starbucks",
     pch = 19, col = "blue")
safe_dev_off()

############################################################
# 8) Pre-aggregated file + station name alignment + regression + ANOVA
############################################################

subway <- read.csv("data/서울시역별승하차수.csv", header = TRUE, fileEncoding = "CP949")
subway_40 <- head(subway[order(subway$승하차수, decreasing = TRUE), ], 40)

starbucks_40 <- read.csv("data/상위 40개 역 스벅 교차수정 (1).csv", header = TRUE, row.names = NULL)

# Align station names between datasets (as in original workflow)
new_starbucks_names <- c(
  "건대입구","교대(법원.검찰청)","동대문역사문화공원(DDP)","서울대입구(관악구청)",
  "서울역","역삼","왕십리(성동구청)","청량리(서울시립대입구)"
)
starbucks_40$역.명[starbucks_40$역.명 %in% setdiff(starbucks_40$역.명, sort(subway_40$역명))] <- new_starbucks_names

top40_st2 <- as.data.frame(table(starbucks_40$역.명))
colnames(top40_st2) <- c("역명", "스타벅스매장수")

top40 <- left_join(subway_40, top40_st2, by = "역명")
top40$스타벅스매장수[top40$역명 == "대림(구로구청)"] <- 0

############################################################
# 9) Regression + save a README-friendly plot
############################################################

model <- lm(승하차수 ~ 스타벅스매장수, data = top40)
print(summary(model))

p_reg <- ggplot(top40, aes(x = 스타벅스매장수, y = 승하차수)) +
  geom_point(size = 1.8, alpha = 0.85, color = "black") +
  geom_smooth(method = "lm", se = TRUE, linewidth = 1, color = "steelblue") +
  labs(
    title = "Regression between Subway Ridership and Starbucks Stores",
    subtitle = "Top 40 Seoul stations (linear regression with 95% CI)",
    x = "Number of Starbucks Stores",
    y = "Total Subway Ridership (Boardings + Alightings)"
  ) +
  scale_y_continuous(labels = comma) +
  scale_x_continuous(breaks = pretty_breaks()) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5),
    plot.subtitle = element_text(size = 11, margin = margin(b = 8), hjust = 0.5),
    axis.title = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    plot.margin = margin(12, 12, 12, 12)
  )

ggsave("figures/ridership_starbucks_regression.png", plot = p_reg, width = 8, height = 6, dpi = 200, bg = "white")

############################################################
# 10) Grouping top40 into 4 groups (10 each) + boxplot + ANOVA
############################################################

top40$group <- factor(rep(1:4, each = 10))

p_box <- ggplot(top40, aes(x = group, y = 승하차수, fill = group)) +
  geom_boxplot(alpha = 0.85, width = 0.65) +
  labs(
    title = "Ridership Distribution by Station Group",
    subtitle = "Top 40 stations split into 4 groups (10 stations each)",
    x = "Group (ranked by ridership)",
    y = "Total Ridership (Boardings + Alightings)"
  ) +
  scale_y_continuous(labels = comma) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5),
    plot.subtitle = element_text(size = 11, margin = margin(b = 8), hjust = 0.5),
    axis.title = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    plot.margin = margin(12, 12, 12, 12)
  )

ggsave("figures/Fig10_Boxplot_GroupComparison.png", plot = p_box, width = 8, height = 6, dpi = 200, bg = "white")

anova_result <- aov(승하차수 ~ group, data = top40)
print(summary(anova_result))
