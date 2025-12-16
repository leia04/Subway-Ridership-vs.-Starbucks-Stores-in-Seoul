############################################################
# 00_setup.R
# - Libraries, common utilities, and output directory
# - Assumes scripts are run from the project root
############################################################

# Load required libraries (do NOT install packages inside scripts)
suppressPackageStartupMessages({
  library(extrafont)
  library(dplyr)
  library(ggplot2)
  library(scales)
})

# Output directory for README-friendly figures
dir.create("figures", showWarnings = FALSE)

# Helper: close graphics device safely (for base R plots)
safe_dev_off <- function() {
  if (dev.cur() != 1) dev.off()
}

# Optional: font setup for macOS (safe to skip if it causes issues)
# - If AppleGothic isn't available on your system, comment this block out.
try({
  font_import(pattern = "AppleGothic", prompt = FALSE)
  loadfonts(quiet = TRUE)
  par(family = "AppleGothic")
}, silent = TRUE)