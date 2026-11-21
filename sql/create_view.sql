create or replace view test_total_view AS
select train.building_id as building_id,foundation_type,roof_type,ground_floor_type,geo_level_1_id,damage_grade from train 
left join train_labels
on train.building_id=train_labels.building_id
where mod(train.building_id,5)=0;