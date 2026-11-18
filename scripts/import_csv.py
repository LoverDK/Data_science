import pandas as pd
from sqlalchemy import create_engine, URL, text
from getpass import getpass
from pathlib import Path

HOST = "127.0.0.1"
PORT = 3306
USERNAME = "root"
DATABASE = "ml"
DATA_DIR = Path(__file__).resolve().parents[1] / "data"

# 左边是 data 目录里的文件，右边是要写入的表名。
# train_values.csv 已经导入过，表名仍用 train。
IMPORTS = [
    ("train_values.csv", "train"),
    ("train_labels.csv", "train_labels"),
    ("test_values.csv", "test_values"),
    ("submission_format.csv", "submission_format"),
]

password = getpass("Enter password:")
url = URL.create(
    drivername="mysql+pymysql",
    username=USERNAME,
    password=password,
    host=HOST,
    port=PORT,
    database=DATABASE,
    query={"charset": "utf8mb4"},
)

engine = create_engine(
    url,
    pool_pre_ping=True,
)


def table_exists(conn, table_name):
    found = conn.execute(
        text(
            "SELECT COUNT(*) FROM information_schema.tables "
            "WHERE table_schema = :schema AND table_name = :table_name"
        ),
        {"schema": DATABASE, "table_name": table_name},
    ).scalar_one()
    return found > 0


try:
    with engine.connect() as conn:
        conn.execute(text("SELECT 1"))

    print("MySQL 数据库连接成功！")

    for csv_name, table_name in IMPORTS:
        csv_path = DATA_DIR / csv_name
        with engine.connect() as conn:
            if table_exists(conn, table_name):
                print(f"跳过 {csv_name}：表 {table_name} 已存在")
                continue

        df = pd.read_csv(csv_path)
        df.to_sql(
            name=table_name,
            con=engine,
            if_exists="fail",
            index=False,
            chunksize=1000,
        )

        with engine.connect() as conn:
            count = conn.execute(
                text(f"SELECT COUNT(*) FROM `{table_name}`")
            ).scalar_one()

        print(f"数据导入成功：{table_name}")
        print("CSV 原始记录数：", len(df))
        print("MySQL 导入记录数：", count)

        if count == len(df):
            print("数据数量核对通过！")
        else:
            print("警告：导入前后记录数量不一致！")

finally:
    engine.dispose()
    print("数据库连接已关闭。")
