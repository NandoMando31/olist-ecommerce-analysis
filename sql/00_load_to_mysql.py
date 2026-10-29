import getpass
import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy.engine import URL
from sqlalchemy.types import String

RAW = "data/raw/"
pwd = getpass.getpass("MySQL password: ")  # not stored anywhere

# URL.create handles special characters in the password safely
url = URL.create("mysql+pymysql", username="root", password=pwd,
                 host="localhost", port=3306, database="olist")
engine = create_engine(url)

ID = String(40)

tables = {
    "orders": dict(
        file="olist_orders_dataset.csv",
        dates=["order_purchase_timestamp", "order_approved_at",
               "order_delivered_carrier_date", "order_delivered_customer_date",
               "order_estimated_delivery_date"],
        dtype={"order_id": ID, "customer_id": ID}),
    "order_items": dict(
        file="olist_order_items_dataset.csv",
        dates=["shipping_limit_date"],
        dtype={"order_id": ID, "product_id": ID, "seller_id": ID}),
    "order_reviews": dict(
        file="olist_order_reviews_dataset.csv",
        cols=["review_id", "order_id", "review_score",
              "review_creation_date", "review_answer_timestamp"],
        dates=["review_creation_date", "review_answer_timestamp"],
        dtype={"review_id": ID, "order_id": ID}),
    "products": dict(
        file="olist_products_dataset.csv",
        cols=["product_id", "product_category_name", "product_weight_g",
              "product_length_cm", "product_height_cm", "product_width_cm"],
        dtype={"product_id": ID}),
    "customers": dict(
        file="olist_customers_dataset.csv",
        cols=["customer_id", "customer_unique_id", "customer_city", "customer_state"],
        dtype={"customer_id": ID, "customer_unique_id": ID}),
    "category_translation": dict(
        file="product_category_name_translation.csv"),
}

for name, cfg in tables.items():
    df = pd.read_csv(RAW + cfg["file"], usecols=cfg.get("cols"),
                     parse_dates=cfg.get("dates", []))
    df.to_sql(name, engine, if_exists="replace", index=False,
              dtype=cfg.get("dtype"), chunksize=5000)
    print(name, len(df))

print("Done.")