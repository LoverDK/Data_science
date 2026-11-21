create or replace view train_total_view as
select train.building_id as building_id,foundation_type,roof_type,ground_floor_type,geo_level_1_id,damage_grade from train
left join train_labels
on train.building_id=train_labels.building_id
where mod(train.building_id,5)!=0;

delimiter //
create procedure loop_columns()
begin
    declare done int default 0;
    declare col_name varchar(64);
    declare cur cursor for
        select 'roof_type'
        union all select 'ground_floor_type'
        union all select 'geo_level_1_id';
    declare continue handler for not found set done=1;
    open cur;
    read_loop:loop
        fetch cur into col_name;
        if done=1 then
            leave read_loop;
        end if;
        set @sql = concat(
            'create or replace view most_pissible_view as ',
            'select ', col_name, ' as feature_value,',
            'sum(damage_grade=1) as damage_grade_1,',
            'sum(damage_grade=2) as damage_grade_2,',
            'sum(damage_grade=3) as damage_grade_3 ',
            'from train_total_view group by ', col_name
        );
        prepare stmt from @sql;
        execute stmt;
        deallocate prepare stmt;

        create or replace view most_possible_one_view as
        select feature_value,
        case when damage_grade_1 >= damage_grade_2 and damage_grade_1 >= damage_grade_3 then 1
            when damage_grade_2 >= damage_grade_1 and damage_grade_2 >= damage_grade_3 then 2
            else 3
            end as most_possible_grade from most_pissible_view;

        set @sql = concat(
            'insert into prediction ',
            'select ''用最可能的', col_name, '预测'',',
            'count(distinct building_id),',
            'count(distinct case when damage_grade = most_possible_grade then building_id end),',
            'sum(damage_grade=most_possible_grade)/count(*),',
            'sum(most_possible_grade=3),',
            'sum(damage_grade=3 and most_possible_grade=3) ',
            'from (',
            'select distinct train.building_id,train.', col_name, ' as feature_value,damage_grade from train ',
            'left join train_labels ',
            'on train.building_id=train_labels.building_id ',
            'where mod(train.building_id,5)=0',
            ') as table_2 left join most_possible_one_view ',
            'on table_2.feature_value=most_possible_one_view.feature_value'
        );
        prepare stmt from @sql;
        execute stmt;
        deallocate prepare stmt;
    end loop;
    close cur;
end//
delimiter ;
call loop_columns();