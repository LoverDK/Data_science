
import pymysql
from getpass import getpass

password = getpass("请输入 MySQL root 密码：")

conn = pymysql.connect(
    host="127.0.0.1",
    port=3306,
    user="root",
    password=password,
    charset="utf8mb4"
)

try:
    with conn.cursor() as cursor:

        # 测试1：最简单的查询
        cursor.execute("SELECT 1 AS test")
        print("测试1：", cursor.fetchall())

        # 测试2：查看当前数据库
        cursor.execute("SELECT DATABASE()")
        print("测试2：", cursor.fetchall())

        # 测试3：查看数据库列表
        cursor.execute("SHOW DATABASES")
        print("测试3：", cursor.fetchall())

        cursor.execute("USE ml")
        cursor.execute("SHOW TABLES")
        print("ml 中的数据表：", cursor.fetchall())

        cursor.execute("SELECT COUNT(*) FROM train")
        print("train 行数：", cursor.fetchall())

finally:
    conn.close()