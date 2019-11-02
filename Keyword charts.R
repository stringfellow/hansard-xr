library(ggplot2)
library(ggthemes)
library(tidyverse)
library(readr)
library(forecast)
library(magrittr)

# Moving average
ma_month <- function(x, n = 30){stats::filter(x, rep(1 / n, n), sides = 2)}
ma_2week <- function(x, n = 14){stats::filter(x, rep(1 / n, n), sides = 2)}

# Import (manual muahaha!)
d1 <- read_csv("extinction_rebellion.js.csv")
d2 <- read_csv("climate_change.js.csv")
d3 <- read_csv("climate_crisis.js.csv")
d4 <- read_csv("citizens_assembly.js.csv")
d5 <- read_csv("global_warming.js.csv")
d6 <- read_csv("climate_emergency.js.csv")

# Full join, could be done much better
hansard <- full_join(d1, d2, by = "Date")
hansard <- full_join(hansard, d3, by = "Date")
hansard <- full_join(hansard, d4, by = "Date")
hansard <- full_join(hansard, d5, by = "Date")
hansard <- full_join(hansard, d6, by = "Date")

# ORDER, ORDER! (Order matters)
colnames(hansard) <- c("Date", 
                       "extinction_rebellion", "climate_change", "climate_crisis", 
                       "citizens_assembly", "global_warming", "climate_emergency")
hansard[is.na(hansard)] <- 0 # replace all NAs with zeros
hansard <- hansard[order(hansard$Date), ] # sort by Date

# Add keywords together
hansard$climate_alarm <- hansard$climate_crisis + hansard$climate_emergency 
hansard$global_heating <- hansard$climate_change + hansard$global_warming

# Smooth the lines
hansard_smooth <- lapply(hansard[,-1], ma_2week) %>% as.data.frame()
hansard_smooth$Date <- hansard$Date

# Set start date
hansard_smooth_2017 <- filter(hansard_smooth, Date >= as.POSIXct("2017-01-01"))

# Simple MA plot
ggplot(data = hansard_smooth_2017) + 
  geom_line(aes(Date, scale(extinction_rebellion)), color = "limegreen", size = 1.2, alpha = 0.8) +
  geom_line(aes(Date, scale(climate_alarm)), color = "red4", alpha = 0.6) +
  geom_line(aes(Date, scale(global_heating)), color = "red", alpha = 0.6) +
  geom_vline(xintercept = as.POSIXct("2018-11-29"), color = "hotpink") +
  geom_vline(xintercept = as.POSIXct("2019-04-15"), color = "hotpink", linetype = "longdash") +
  ylab("Standardised count of keywords in Hansard") +
  theme_light() +  
  theme(axis.text.y = element_blank()) +
  annotate(label = '"Extinction Rebellion"', "text", x = as.POSIXct("2017-06-29"), y = 0, color = "limegreen") +
  annotate(label = '"Climate crisis/emergency"', "text", x = as.POSIXct("2019-01-29"), y = -0.7, color = "red4") +
  annotate(label = '"Climate change & global warming"', "text", x = as.POSIXct("2018-06-29"), y = 0.5, color = "red") +
  annotate(label = "2018-11-29", "text", x = as.POSIXct("2018-08-29"), y = 3.5, color = "hotpink") +
  annotate(label = "2019-04-15", "text", x = as.POSIXct("2019-07-15"), y = 3.5, color = "hotpink")


ggsave("hansard-extinction-rebellion.pdf", width = 6, height = 4, device = "pdf")
  


#------ Other Stuff -----


# Simple plot
ggplot(data = hansard) + 
  geom_line(aes(date, extinction_rebellion), color = "red") + 
  geom_line(aes(date, climate_change), color = "darkgreen") +
  geom_vline(xintercept = as.POSIXct("2018-11-29"), size = 1.5, color = "limegreen") +
  theme_economist()


cor(hansard[, -1], use = "pairwise") %>% heatmap
cor(hansard_smooth[, -7], use = "pairwise") %>% heatmap

cor(hansard_smooth[, -7], use = "pairwise")


