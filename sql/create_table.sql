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
create table if not exists wrong_analysis_foundation(
    `真实等级` int,
    `该等级验证建筑数` int,
    `全猜2级正确数` int,
    `地基规则正确数` int,
    `从错变对` int comment '一律预测2级判错,且地基规则判对',
    `从对变错` int comment '一律预测2级判对,且地基规则判错',
    `净增正确数` int
);



alter table prediction add column `预测为3的数量` int;
alter table prediction add column `3级命中数` int;
