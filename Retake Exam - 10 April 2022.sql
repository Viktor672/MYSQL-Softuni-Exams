set sql_safe_updates = 0;

create database softuni_imdb;

create table countries (
id int primary key auto_increment,
`name` varchar(30) not null unique,
continent varchar(30) not null,
currency varchar(5) not null
);

create table genres (
id int primary key auto_increment,
`name` varchar(50) not null unique
);

create table actors (
id int primary key auto_increment,
first_name varchar(50) not null,
last_name varchar(50) not null,
birthdate date not null,
height int,
awards int,
country_id int not null,
foreign key (country_id) references countries(id)
);

create table movies_additional_info (
id int primary key auto_increment,
rating decimal(10, 2) not null,
runtime int not null,
picture_url varchar(80) not null,
budget decimal(10, 2),
release_date date not null,
has_subtitles boolean,
description text
);

create table movies (
id int primary key auto_increment,
title varchar(70) not null unique,
country_id int not null,
movie_info_id int not null unique,
foreign key (country_id) references countries(id),
foreign key (movie_info_id) references movies_additional_info(id)
);

create table movies_actors (
movie_id int,
actor_id int,
foreign key (movie_id) references movies(id),
foreign key (actor_id) references actors(id)
);

create table genres_movies (
genre_id int,
movie_id int,
foreign key (genre_id) references genres(id),
foreign key (movie_id) references movies(id)
);

-- 02
insert into actors (first_name, last_name, birthdate, height, awards, country_id)
select 
reverse(first_name),
reverse(last_name),
date_sub(birthdate, interval 2 day),
height + 10,
country_id,
(select id from countries where `name` = 'Armenia')
from actors
where id <= 10;

-- 03
update movies_additional_info
set runtime = runtime - 10
where id >= 15 and id <= 25;

-- 04
delete c from countries as c
left join movies as m
on c.id = m.country_id
where m.id is null;

-- 05
select id, `name`, continent, currency from countries
order by currency desc, id asc;

-- 06
select mai.id, m.title, mai.runtime, mai.budget, mai.release_date from movies_additional_info as mai
join movies as m
on m.movie_info_id = mai.id
where year(mai.release_date) between 1996 and 1999
order by mai.runtime asc, mai.id asc
limit 20;

-- 07
select
concat_ws(' ', a.first_name, a.last_name) as full_name,
concat(reverse(a.last_name), char_length(a.last_name), '@cast.com') as email,
2022 - year(a.birthdate) as age,
a.height
from actors as a
left join movies_actors as ma
on a.id = ma.actor_id
where ma.movie_id is null
order by height asc;

-- 08
select c.`name`, count(m.id) as movies_count from countries as c
join movies as m
on c.id = m.country_id
group by c.`name`
having movies_count >= 7
order by c.`name` desc;

-- 09
select m.title,
case
when mai.rating <= 4 then 'poor'
when mai.rating <= 7 then 'good'
else 'excellent'
end as rating,
if(mai.has_subtitles = 1, 'english', '-') as subtitles,
mai.budget from movies as m
join movies_additional_info as mai
on m.movie_info_id = mai.id
order by budget desc;

-- 10
delimiter //
create function udf_actor_history_movies_count (full_name varchar(50))
returns int
deterministic
begin
return (
select count(ma.movie_id) from actors as a
join movies_actors as ma
on a.id = ma.actor_id
join movies as m
on m.id = ma.movie_id
join genres_movies as gm
on m.id = gm.movie_id
join genres as g
on g.id = gm.genre_id
where concat(a.first_name, ' ', last_name) = full_name and g.`name` = 'history'
);
end//
delimiter ;

-- 11
delimiter //
create procedure udp_award_movie (movie_title varchar(50))
begin
update actors as a
join movies_actors as ma
on a.id = ma.actor_id
join movies as m
on m.id = ma.movie_id
set awards = awards + 1
where m.title = movie_title;
end//
delimiter ;

select * from actors as a
join movies_actors as ma
on a.id = ma.actor_id
join movies as m
on m.id = ma.movie_id
where m.title = 'Ask the Dust';

select * from actors as a
join movies_actors as ma
on a.id = ma.actor_id
join movies as m
on m.id = ma.movie_id
where m.title = 'Ask the Dust';