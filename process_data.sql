-- Remove duplicates
CREATE OR REPLACE TABLE `meme_coins_dataset.meme_coins_cleaned` AS
SELECT DISTINCT coin, date, price_usd, volume_usd
FROM `meme_coins_dataset.meme_coins_raw`;

-- Calculate daily price changes
CREATE OR REPLACE TABLE `meme_coins_dataset.meme_coins_processed` AS
SELECT
    coin,
    date,
    price_usd,
    volume_usd,
    LAG(price_usd) OVER (PARTITION BY coin ORDER BY date) AS previous_price,
    SAFE_DIVIDE(price_usd - LAG(price_usd) OVER (PARTITION BY coin ORDER BY date),
                LAG(price_usd) OVER (PARTITION BY coin ORDER BY date)) * 100 AS daily_price_change_pct
FROM `meme_coins_dataset.meme_coins_cleaned`
ORDER BY coin, date;