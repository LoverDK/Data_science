import pandas as pd
from sqlalchemy import create_engine, URL
from getpass import getpass
import numpy as np
password = getpass("Enter password:")
url = URL.create(
    drivername="mysql+pymysql",
    username="root",
    password=password,
    host="127.0.0.1",
    port=3306,
    database="ml",
    query={"charset": "utf8mb4"},
)
engine = create_engine(url)
train_fit=pd.read_sql('select building_id,geo_level_1_id,damage_grade from train_total_view',engine)
test_fit=pd.read_sql('select building_id,geo_level_1_id,damage_grade from test_total_view',engine)
X_train=np.column_stack((np.ones(len(train_fit)),train_fit[['geo_level_1_id']].to_numpy()))
y_train=train_fit[['damage_grade']].to_numpy()
X_test=np.column_stack((np.ones(len(test_fit)),test_fit[['geo_level_1_id']].to_numpy()))
beta=np.linalg.inv(X_train.T@X_train)@X_train.T@y_train
print(beta)
y_pred=X_test@beta
y_answer=np.select(
    [y_pred<1.5,y_pred<2.5,y_pred>=2.5],
    [1,2,3],
    default=2
)
result=pd.DataFrame({
    '预测方法':'用geo_level_1_id线性预测',
    '验证建筑数':len(y_answer),
    '预测正确数':np.sum(y_answer==test_fit[['damage_grade']].to_numpy()),
    '准确率':np.sum(y_answer==test_fit[['damage_grade']].to_numpy())/len(y_answer),
    '预测为3的数量':np.sum(y_answer==3),
    '3级命中数':np.sum((y_answer==3) & (test_fit[['damage_grade']].to_numpy()==3))
},index=[0])
result.to_sql('prediction',engine,if_exists='append',index=False)
