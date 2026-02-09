SET SQL_SAFE_UPDATES = 0;

create database summer_olympics;

-- Using database summer_olympics
-- 01
create table countries (
id int primary key auto_increment,
name varchar(40) not null unique
);

create table sports (
id int primary key auto_increment,
name varchar(20) not null unique
);

create table disciplines (
id int primary key auto_increment,
name varchar(40) not null unique,
sport_id int not null,
constraint foreign key (sport_id) references sports(id)
);

create table athletes (
id int primary key auto_increment,
first_name varchar(40) not null,
last_name varchar(40) not null,
age int not null,
country_id int not null,
constraint foreign key (country_id) references countries(id)
);

create table medals (
id int primary key auto_increment,
type varchar(10) not null unique
);

create table disciplines_athletes_medals (
discipline_id int not null,
athlete_id int not null,
medal_id int not null,
constraint primary key (discipline_id, athlete_id),
constraint foreign key (discipline_id) references disciplines(id),
constraint foreign key (athlete_id) references athletes(id),
constraint foreign key (medal_id) references medals(id)
);

-- 02
insert into athletes (first_name, last_name, age, country_id)
select 
upper(a.first_name),
concat(a.last_name, ' comes from ', c.name) as last_name,
a.age + a.country_id as age,
a.country_id
from athletes as a
join countries as c
on a.country_id = c.id
where c.name like 'A%';

-- 03
update disciplines
set name = replace(name, 'weight', '')
where name like '%weight%';

-- 04
delete from athletes
where age > 35;

-- 05
select c.id, c.`name` from countries as c
left join athletes as a
on a.country_id = c.id
where country_id is null
order by c.name desc
limit 15;

-- 06
select concat(a.first_name, ' ', a.last_name) as full_name, a.age from athletes as a
join disciplines_athletes_medals as dam
on a.id = dam.athlete_id
where dam.medal_id is not null and age = (select min(age) from athletes)
order by a.id asc
limit 2;

-- 07
select a.id, a.first_name, a.last_name from athletes as a
left join disciplines_athletes_medals as dam
on a.id = dam.athlete_id
where dam.medal_id is null
order by a.id asc;

-- 08
select a.id, a.first_name, a.last_name, count(dam.medal_id) as medals_count, s.`name` as sport from athletes as a
join disciplines_athletes_medals as dam
on a.id = dam.athlete_id
join disciplines as d
on d.id = dam.discipline_id
join sports as s
on d.sport_id = s.id
group by a.id, a.first_name, a.last_name, s.`name`
order by medals_count desc, a.first_name asc
limit 10;

-- 09
select concat(first_name, ' ', last_name) as full_name,
case
when age <= 18 then 'Teenager'
when age > 18 and age <= 25 then 'Young adult'
when age >= 26 then 'Adult'
end as age_group
from athletes
order by age desc, first_name asc;

-- 10
delimiter //
create function udf_total_medals_count_by_country (country_name varchar(40))
returns int
DETERMINISTIC
begin
return (
select count(dam.medal_id) as count
from countries as c
join athletes as a
on c.id = a.country_id
join disciplines_athletes_medals as dam
on a.id = dam.athlete_id
where c.`name` = country_name
);
end//
delimiter ;

-- 11
delimiter //
create procedure udp_first_name_to_upper_case (letter varchar(1))
begin
update athletes
set first_name = upper(first_name)
where lower(first_name) like concat('%', lower(letter));
end//
delimiter ;