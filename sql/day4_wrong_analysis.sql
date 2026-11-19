delete from wrong_analysis_foundation;
insert into wrong_analysis_foundation
select damage_grade,count(*) as all_b,sum(damage_grade=2) as two_b,sum(damage_grade=most_possible_grade) as most_possible_b,
        sum(damage_grade!=2 and damage_grade=most_possible_grade) as from_wrong_to_right,
        sum(damage_grade=2 and damage_grade!=most_possible_grade) as from_right_to_wrong,
        sum(damage_grade!=2 and damage_grade=most_possible_grade)-sum(damage_grade=2 and damage_grade!=most_possible_grade) as net_correct_b
from
(
    select building_id,a.foundation_type,damage_grade,most_possible_grade from
    (
        select train.building_id as building_id,foundation_type,damage_grade from train
        left join train_labels
        on train.building_id=train_labels.building_id
        where mod(train.building_id,5)=0
    ) as a left join most_possible_foundation
    on a.foundation_type=most_possible_foundation.foundation_type
) as table_1
group by damage_grade
order by damage_grade;
select * from wrong_analysis_foundation;
