SELECT 'submission_format' AS 表名, COUNT(*) AS 行数,
sum(building_id is null) as 空值数,
count(*)-count(distinct building_id) as 重复数
FROM ML.submission_format
UNION ALL
SELECT 'train', COUNT(*),
sum(building_id is null) ,
count(*)-count(distinct building_id)
FROM ML.train
UNION ALL
SELECT 'train_labels', COUNT(*),
sum(building_id is null),
count(*)-count(distinct building_id)
FROM ML.train_labels
UNION ALL
SELECT 'test_values', COUNT(*),
sum(building_id is null),
count(*)-count(distinct building_id)
FROM ML.test_values;

SELECT SUM(damage_grade = 1) / COUNT(*) AS `1级比例`,
       SUM(damage_grade = 2) / COUNT(*) AS `2级比例`,
       SUM(damage_grade = 3) / COUNT(*) AS `3级比例`,
       SUM(damage_grade between 1 and 3) / COUNT(*) AS `1-3级比例`
FROM ML.train_labels;
