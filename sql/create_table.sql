create table if not exists prediction(
    `预测方法` varchar(255),
    `验证建筑数` int,
    `预测正确数` int,
    `准确率` float
);
create table if not exists most_possible_foundation(
    `foundation_type` varchar(255),
    `most_possible_grade` int
);