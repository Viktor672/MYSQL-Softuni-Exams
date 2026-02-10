set sql_safe_updates = 0;

create schema restaurant_db;

-- Using Database restaurant_db
-- 01
create table products (
id int primary key auto_increment,
`name` varchar(30) not null unique,
`type` varchar(30) not null,
price decimal(10, 2) not null
);

create table clients (
id int primary key auto_increment,
first_name varchar(50) not null,
last_name varchar(50) not null,
birthdate date not null,
card varchar(50),
review text
);

create table `tables` (
id int primary key auto_increment,
floor int not null,
reserved boolean,
capacity int not null
);

create table waiters (
id int primary key auto_increment,
first_name varchar(50) not null,
last_name varchar(50) not null,
email varchar(50) not null,
phone varchar(50),
salary decimal(10, 2)
);

create table orders (
id int primary key auto_increment,
table_id int not null,
waiter_id int not null,
order_time time not null,
payed_status boolean,
foreign key (table_id) references `tables`(id),
foreign key (waiter_id) references waiters(id)
);

create table orders_clients (
order_id int,
client_id int,
foreign key (order_id) references orders(id),
foreign key (client_id) references clients(id)
);

create table orders_products (
order_id int,
product_id int,
foreign key (order_id) references orders(id),
foreign key (product_id) references products(id)
);

-- 02
insert into products (`name`, `type`, price)
select
concat(last_name, ' ', 'specialty'),
'Cocktail',
ceil(salary * 0.01)
from waiters
where id > 6;

-- 03
update orders
set table_id = table_id - 1
where id between 12 and 23;

-- 04
delete w from waiters as w
left join orders as o
on w.id = o.waiter_id
where o.id is null;

-- 05
select id, first_name, last_name, birthdate, card, review from clients
order by birthdate desc, id desc;

-- 06
select first_name, last_name, birthdate, review from clients
where card is null and year(birthdate) between 1978 and 1993
order by last_name desc, id asc
limit 5;

-- 07
select
concat(last_name, first_name, char_length(first_name), 'Restaurant') as username,
reverse(substring(email, 2, 12)) as 'password' from waiters
where salary is not null
order by password desc;

-- 08
select p.id, p.`name`, count(op.product_id) as 'count' from products as p
join orders_products as op
on p.id = op.product_id
group by p.id, p.`name`, op.product_id
having `count` >= 5
order by `count` desc, p.`name` asc;

-- 09
select t.id, t.capacity, count(oc.client_id) as 'count',
case
when count(oc.client_id) < t.capacity then 'Free seats'
when count(oc.client_id) = t.capacity then 'Full'
when count(oc.client_id) > t.capacity then 'Extra seats'
end as availability
from `tables` as t
join orders as o
on t.id = o.table_id
join orders_clients as oc
on o.id = oc.order_id
where t.`floor` = 1
group by t.id, t.capacity
order by t.id desc;

-- 10
delimiter //
create function udf_client_bill (full_name varchar(50))
returns decimal(19,2)
deterministic
begin
return (
select round(sum(price), 2) from clients as c
join orders_clients as oc
on c.id = oc.client_id
join orders as o
on o.id = oc.order_id
join orders_products as op
on o.id = op.order_id
join products as p
on p.id = op.product_id
where concat_ws(' ', first_name, last_name) = full_name
);
end//
delimiter ;

-- 11
delimiter //
create procedure udp_happy_hour (product_type varchar(50))
begin
update products
set price = price* 0.8
where price >= 10 and `type` = product_type;
end//
delimiter ;