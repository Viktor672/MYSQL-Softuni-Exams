set sql_safe_updates = 0;

create schema foods_friends;

-- Using Database foods_friends
-- 01
create table restaurants (
id int primary key auto_increment,
`name` varchar(40) not null unique,
`type` varchar(20) not null,
non_stop boolean not null
);

create table offerings (
id int primary key auto_increment,
`name` varchar(40) not null unique,
price decimal(19, 2) not null,
vegan boolean not null,
restaurant_id int not null,
constraint foreign key (restaurant_id) references restaurants(id)
);

create table customers (
id int primary key auto_increment,
first_name varchar(40) not null,
last_name varchar(40) not null,
phone_number varchar(20) not null unique,
regular boolean not null,
constraint unique(first_name, last_name)
);

create table orders (
id int primary key auto_increment,
`number` varchar(10) not null unique,
priority varchar(10) not null,
customer_id int not null,
restaurant_id int not null,
constraint foreign key (customer_id) references customers(id),
constraint foreign key (restaurant_id) references restaurants(id)
);

create table orders_offerings (
order_id int not null,
offering_id int not null,
restaurant_id int not null,
primary key (order_id, offering_id),
constraint foreign key (order_id) references orders(id),
constraint foreign key (offering_id) references offerings(id),
constraint foreign key (restaurant_id) references restaurants(id)
);

-- 02
insert into offerings (`name`, price, vegan, restaurant_id)
select 
concat(`name`, ' costs:') as name,
price,
vegan,
restaurant_id
from offerings
where left(`name`, 5) = 'Grill'
order by `name` asc; -- Order because of the index on name

-- 03
update offerings
set `name` = upper(`name`)
where `name` like '%Pizza%';

-- 04
delete from restaurants
where `name` like '%fast%' or
`type` like '%fast%';

-- 05
select o.`name`, o.price from offerings as o
join restaurants as r
on o.restaurant_id = r.id
where r.`name` = 'Burger Haven'
order by o.id asc;

-- 06
select c.id, c.first_name, c.last_name from customers as c
left join orders as o
on c.id = o.customer_id
where o.id is null
order by c.id asc;

-- 07
select offerings.id, offerings.`name` from offerings
join orders_offerings as oo
on offerings.id = oo.offering_id
join orders
on orders.id = oo.order_id
join customers as c
on orders.customer_id = c.id
where concat(c.first_name, ' ', c.last_name) = 'Sofia Sanchez' and
offerings.vegan = 0
order by offerings.id asc;

-- 08
select distinct r.id, r.`name` from restaurants as r
join orders
on r.id = orders.restaurant_id
join offerings
on r.id = offerings.restaurant_id
join customers as c
on orders.customer_id = c.id
where c.regular = 1 and
offerings.vegan = 1 and
orders.priority = 'High'
order by r.id asc;

-- 09
select `name` as offering_name,
case
when price <= 10 then 'cheap'
when price > 10 and price <= 25 then 'affordable'
when price > 25 then 'expensive'
end as price_category
from offerings
order by price desc, offering_name asc;

-- 10
delimiter //
create function udf_get_offerings_average_price_per_restaurant (restaurant_name varchar(40))
returns decimal (20, 2)
deterministic
begin
return (
select round(avg(offerings.price), 2) from offerings
join restaurants as r
on offerings.restaurant_id = r.id
where r.`name` = restaurant_name
);
end//
delimiter ;

-- 11
delimiter //
create procedure udp_update_prices (restaurant_type varchar(40))
begin
update offerings
join restaurants as r
on offerings.restaurant_id = r.id
set price = price + 5
where r.non_stop = 1 and
r.`type` = restaurant_type;
end//
delimiter ;