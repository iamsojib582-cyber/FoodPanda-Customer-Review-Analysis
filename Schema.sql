Create Table store (
		store_id VARCHAR(10) PRIMARY KEY,
    store_name VARCHAR(200),
    restaurant_type VARCHAR(50),
    city VARCHAR(50)
);

COPY store
FROM '"D:\SQL Project\Food_review\dim_store_.csv"'
DELIMITER ','
CSV HEADER;

Select * from store 
Limit 10;

Select store_name
from store
WHERE store_name ~ '[^[:ascii:]]'
Limit 20;

Update store
Set store_name= Regexp_Replace(store_name, '[^[:ascii:]]', '', 'g');

---------
Create Table reviews(
	store_id Varchar(50) Foreign Key,
user_id Text ,
review_date Date,
review_time Time,
reviewer_Id Text Varchar(200),
review_like_count Int,
overall_ratings decimal (3,2),
rider_ratings decimal (3,2),
food_ratings decimal (3,2)

);

CREATE TABLE reviews (
    store_id VARCHAR(50),
    user_id TEXT,
    review_date DATE,
    review_time TIME,
    reviewer_id VARCHAR(200),
    review_like_count INT,
    overall_ratings DECIMAL(3,2),
    rider_ratings DECIMAL(3,2),
    food_ratings DECIMAL(3,2),
    FOREIGN KEY (store_id) REFERENCES store(store_id)
);

Select * from reviews;

