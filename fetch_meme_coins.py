from pycoingecko import CoinGeckoAPI
import pandas as pd
import time

# Connect to CoinGecko (no API key needed)
cg = CoinGeckoAPI()

# Top 10 meme coins (CoinGecko IDs)
meme_coin_ids = [
    "dogecoin", "shiba-inu", "pepe", "floki", "bonk",
    "dogwifcoin", "mog-coin", "popcat", "brett", "book-of-meme"
]

# Empty table for data
all_data = pd.DataFrame()

# Fetch data for each coin
for coin_id in meme_coin_ids:
    print(f"Getting data for {coin_id}...")
    try:
        # Get price and volume data
        data = cg.get_coin_market_chart_range_by_id(
            id=coin_id,
            vs_currency="usd",
            from_timestamp=1730419200,  # Nov 1, 2024
            to_timestamp=1746057600    # May 1, 2025
        )
        # Extract prices and volumes
        prices = data["prices"]
        volumes = data["total_volumes"]
        # Create table for this coin
        coin_data = pd.DataFrame({
            "coin": [coin_id] * len(prices),
            "date": [pd.to_datetime(price[0], unit="ms").date() for price in prices],
            "price_usd": [price[1] for price in prices],
            "volume_usd": [volume[1] for volume in volumes]
        })
        # Add to main table
        all_data = pd.concat([all_data, coin_data], ignore_index=True)
    except Exception as e:
        print(f"Error with {coin_id}: {e}")
    # Wait to avoid overwhelming CoinGecko
    time.sleep(2)

# Save to CSV
all_data.to_csv("meme_coins_data.csv", index=False)
print("Data saved to meme_coins_data.csv")