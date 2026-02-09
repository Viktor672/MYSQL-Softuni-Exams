set sql_safe_updates = 0;

create schema airlines_db;

-- Using Database airlines_db
-- 01
create table countries (
id int primary key auto_increment,
`name` varchar(30) not null unique,
`description` text,
currency varchar(5) not null
);

create table airplanes (
id int primary key auto_increment,
model varchar(50) not null unique,
passengers_capacity int not null,
tank_capacity decimal(19, 2) not null,
cost decimal(19, 2) not null
);

create table passengers (
id int primary key auto_increment,
first_name varchar(30) not null,
last_name varchar(30) not null,
country_id int not null,
foreign key (country_id) references countries(id)
);

create table flights (
id int primary key auto_increment,
flight_code varchar(30) not null unique,
departure_country int not null,
destination_country int not null,
airplane_id int not null,
has_delay boolean,
departure datetime,
foreign key (departure_country) references countries(id),
foreign key (destination_country) references countries(id),
foreign key (airplane_id ) references airplanes(id)
);

create table flights_passengers (
flight_id int,
passenger_id int,
foreign key (flight_id) references flights(id),
foreign key (passenger_id) references passengers(id)
);

-- 02
insert into airplanes(model, passengers_capacity, tank_capacity, cost)
select
concat(reverse(first_name), '797'),
char_length(last_name) * 17,
id * 790,
char_length(first_name) * 50.6
from passengers
where id <= 5;

-- 03
update flights as f
join countries as c
on f.departure_country = c.id
set f.airplane_id = f.airplane_id + 1
where c.`name` = 'Armenia';

-- 04
delete f from flights as f
left join flights_passengers as fp
on f.id = fp.flight_id
left join passengers as p
on p.id = fp.passenger_id
where p.id is null;

-- 05
select id, model, passengers_capacity, tank_capacity, cost from airplanes
order by cost desc, id desc;

-- 06
select flight_code, departure_country, airplane_id, departure from flights
where year(departure) = 2022
order by airplane_id asc, flight_code asc
limit 20;

-- 07
select upper( concat( left(p.last_name, 2), p.country_id ) ) as flight_code, concat(p.first_name, ' ', p.last_name), p.country_id from passengers as p
left join flights_passengers as fp
on p.id = fp.passenger_id
where fp.passenger_id is null
order by p.country_id asc;

-- 08
select c.`name`, c.currency, count(f.destination_country) as booked_tickets from countries as c
join flights as f
on c.id = f.destination_country
join flights_passengers as fp
on f.id = fp.flight_id
group by c.`name`, c.currency
having booked_tickets >= 20
order by booked_tickets desc;

-- 09
select flight_code, departure,
case
when time(departure) >= '05:00:00' and time(departure) <= '11:59:59' then 'Morning'
when time(departure) >= '12:00:00' and time(departure) <= '16:59:59' then 'Afternoon'
when time(departure) >= '17:00:00' and time(departure) <= '20:59:59' then 'Evening'
when time(departure) >= '21:00:00' or time(departure) <= '04:59:59' then 'Night'
end as day_part 
from flights
order by flight_code desc;

-- 10
delimiter //
create function udf_count_flights_from_country (country_name varchar(50))
returns int
deterministic
begin
return (
select count(f.departure_country) from flights as f
join countries as c
on f.departure_country = c.id
where c.`name` = country_name
);
end//
delimiter ;

-- 11
delimiter //
create procedure udp_delay_flight (flight_code varchar(50))
begin
update flights
set has_delay = 1,
departure = date_add(departure, interval 30 minute); 
end//
delimiter ;