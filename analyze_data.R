# Load libraries
library(tidyverse)

# Read data
data <- read_csv("meme_coins_processed.csv")

# 1. Clean data
data_clean <- data %>%
  mutate(daily_price_change_pct = ifelse(is.na(daily_price_change_pct), 0, daily_price_change_pct)) %>%
  filter(!is.na(price_usd) & !is.na(volume_usd))
summary(data_clean)
write_csv(data_clean, "meme_coins_final.csv")

# 2. Analysis: Total price change (%)
price_change <- data_clean %>%
  group_by(coin) %>%
  summarise(
    start_price = price_usd[date == min(date)],
    end_price = price_usd[date == max(date)],
    price_change_pct = (end_price - start_price) / start_price * 100,
    avg_volume = mean(volume_usd, na.rm = TRUE)
  ) %>%
  arrange(desc(price_change_pct))
write_csv(price_change, "meme_coins_results.csv")

# 3. Analysis: Volatility (standard deviation of daily changes)
volatility <- data_clean %>%
  group_by(coin) %>%
  summarise(volatility = sd(daily_price_change_pct, na.rm = TRUE)) %>%
  arrange(desc(volatility))
write_csv(volatility, "meme_coins_volatility.csv")

# 4. Plot: Price trends over time
ggplot(data_clean, aes(x = date, y = price_usd, color = coin)) +
  geom_line() +
  facet_wrap(~coin, scales = "free_y") +
  theme_minimal() +
  labs(title = "Price Trends of Top Meme Coins (Nov 2024 - May 2025)",
       x = "Date", y = "Price (USD)")
ggsave("price_trends.png", width = 10, height = 8)

# 5. Plot: Bar chart of total price change
ggplot(price_change, aes(x = reorder(coin, price_change_pct), y = price_change_pct, fill = coin)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  theme_minimal() +
  labs(title = "Total Price Change (%) of Meme Coins",
       x = "Coin", y = "Price Change (%)")
ggsave("price_change_bar.png", width = 8, height = 6)

# 6. Plot: Scatter plot of price change vs. volume
ggplot(price_change, aes(x = price_change_pct, y = avg_volume, color = coin, label = coin)) +
  geom_point(size = 3) +
  geom_text(vjust = -1, size = 3) +
  theme_minimal() +
  labs(title = "Price Change vs. Average Volume",
       x = "Price Change (%)", y = "Average Volume (USD)")
ggsave("price_volume_scatter.png", width = 8, height = 6)

# 7. Plot: Box plot of daily price changes
ggplot(data_clean, aes(x = coin, y = daily_price_change_pct, fill = coin)) +
  geom_boxplot() +
  theme_minimal() +
  labs(title = "Distribution of Daily Price Changes",
       x = "Coin", y = "Daily Price Change (%)") +
  coord_flip()
ggsave("daily_change_boxplot.png", width = 8, height = 6)

# 8. Plot: Bar chart of volatility
ggplot(volatility, aes(x = reorder(coin, volatility), y = volatility, fill = coin)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  theme_minimal() +
  labs(title = "Volatility of Meme Coins (Std Dev of Daily Changes)",
       x = "Coin", y = "Volatility")
ggsave("volatility_bar.png", width = 8, height = 6)

# Print summaries
print("Top 5 Coins by Price Change (%):")
print(head(price_change, 5))
print("Top 5 Coins by Volatility:")
print(head(volatility, 5))