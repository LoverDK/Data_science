select '用geo_level_1_id平均值预测' as 预测方法,count(*) as 验证建筑数,sum(if(predicted_damage_grade=damage_grade,1,0)) as 预测正确数,
sum(if(predicted_damage_grade=damage_grade,1,0))/count(*) as 准确率,
sum(if(predicted_damage_grade=3,1,0)) as 预测为3的数量,sum(if(predicted_damage_grade=3 and damage_grade=3,1,0)) as 3级命中数 from(
    select distinct geo_level_1_id,
        CASE
                when avg_damage_grade<1.5 then 1
                when avg_damage_grade<2.5 then 2
                else 3
        end as predicted_damage_grade
    from(
        select building_id,geo_level_1_id,damage_grade,avg(damage_grade) over (
            partition by geo_level_1_id
        ) as avg_damage_grade
        from train_total_view
    ) as a
) as b right JOIN
test_total_view on b.geo_level_1_id=test_total_view.geo_level_1_id;