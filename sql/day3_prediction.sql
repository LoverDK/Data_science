-- @conn study

SELECT 1 AS test;
delete from most_possible_foundation;
insert into most_possible_foundation
select foundation_type,
case when damage_grade_1 >= damage_grade_2 and damage_grade_1 >= damage_grade_3 then 1
     when damage_grade_2 >= damage_grade_1 and damage_grade_2 >= damage_grade_3 then 2
else 3
end as most_possible_grade from
(
    select foundation_type,sum(damage_grade=1) as damage_grade_1,sum(damage_grade=2) as damage_grade_2,sum(damage_grade=3) as damage_grade_3
    from train
    left join train_labels 
    on train.building_id = train_labels.building_id
    where mod(train.building_id,5)!=0
    group by foundation_type
) as table_1;
DELETE FROM prediction;
insert into prediction
select '用最可能的foundation类型预测',count(distinct building_id) as `预测建筑数`,COUNT(DISTINCT CASE
    WHEN damage_grade = most_possible_grade THEN building_id
END) AS `预测正确数`,sum(damage_grade=most_possible_grade)/count(*) as `准确率`,sum(most_possible_grade=3) as `预测为3的数量`,sum(damage_grade=3 and most_possible_grade=3) as `3级命中数` from (
    select distinct train.building_id,foundation_type,damage_grade from train
    left join train_labels
    on train.building_id=train_labels.building_id
    where mod(train.building_id,5)=0
) as table_2 left join most_possible_foundation
on table_2.foundation_type=most_possible_foundation.foundation_type;

insert into prediction
select '一律预测2级',count(distinct building_id) as `预测建筑数`,sum(damage_grade=2) as `预测正确数`,sum(damage_grade=2)/count(*) as `准确率`,0 as `预测为3的数量`,0 as `3级命中数`
from train_labels where mod(building_id,5)=0;

