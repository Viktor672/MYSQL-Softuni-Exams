set sql_safe_updates = 0;

create schema online_store;

-- Using database online_stroe
-- 01
create table brands (
id int primary key auto_increment,
`name` varchar(40) not null unique
);

create table categories (
id int primary key auto_increment,
`name` varchar(40) not null unique
);

create table reviews (
id int primary key auto_increment,
content text,
rating decimal(10, 2) not null,
picture_url varchar(80) not null,
published_at datetime not null
);

create table products (
id int primary key auto_increment,
`name` varchar(40) not null,
price decimal(19, 2) not null,
quantity_in_stock int,
`description` text,
brand_id int not null,
category_id int not null,
review_id int,
foreign key (brand_id) references brands(id),
foreign key (category_id) references categories(id),
foreign key (review_id) references reviews(id)
);

create table customers (
id int primary key auto_increment,
first_name varchar(20) not null,
last_name varchar(20) not null,
phone varchar(30) not null unique,
address varchar(60) not null,
discount_card bit(1) default 0 not null
);

create table orders (
id int primary key auto_increment,
order_datetime datetime not null,
customer_id int not null,
foreign key (customer_id) references customers(id)
);

create table orders_products (
order_id int,
product_id int,
foreign key (order_id) references orders(id),
foreign key (product_id) references products(id)
);

-- 02
insert into reviews (content, picture_url, published_at, rating)
select
substring(`description`, 1, 15),
reverse(`name`),
'2010-10-10',
round( (price / 8), 2 )
from products
where id >= 5;

-- 03
update products
set quantity_in_stock = quantity_in_stock - 5
where quantity_in_stock between 60 and 70;

-- 04
delete c from customers as c
left join orders as o
on c.id = o.customer_id
where o.id is null;

-- 05
select id, `name` from categories
order by `name` desc;

-- 06
select p.id, b.id, p.`name`, p.quantity_in_stock from products as p
join brands as b
on p.brand_id = b.id
where p.price > 1000 and p.quantity_in_stock < 30
order by p.quantity_in_stock asc, p.id asc;

-- 07
select id, content, rating, picture_url, published_at from reviews
where left(content, 2) = 'My' and char_length(content) > 61
order by rating desc;

-- 08
select concat(c.first_name, ' ', c.last_name) as full_name, c.address, o.order_datetime as order_date from customers as c
join orders as o
on c.id = o.customer_id
where year(o.order_datetime) <= 2018
order by full_name desc;

-- 09
select count(p.id) as items_count, c.`name`, sum(p.quantity_in_stock) as total_quantity from categories as c
join products as p
on c.id = p.category_id
group by c.`name`
order by items_count desc, total_quantity asc
limit 5;

-- 10
delimiter //
create function udf_customer_products_count (customer_name varchar(30))
returns int
deterministic
begin
return (
select count(op.product_id) as total_products from customers as c
join orders as o
on c.id = o.customer_id
join orders_products as op
on o.id = op.order_id
where c.first_name = customer_name
);
end//
delimiter ;

-- 11
delimiter //
create procedure udp_reduce_price (category_name varchar(50))
begin
update products as p
join reviews as r
on p.review_id = r.id
join categories as c
on p.category_id = c.id
set p.price = p.price * 0.7
where r.rating < 4 and c.`name` = category_name;
end//
delimiter ;