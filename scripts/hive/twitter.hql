set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;

drop table raw_tweets;
drop table tweets2;
drop table tweet_details;
drop table twitter_user_location;
drop table twitter_tags_user_location;
drop table twitter_tags_count;
drop table twitter_tags_count_100;
drop table twitter_tags_user_location_count;
drop table twitter_tags_user_location_count_100;

create external table IF NOT EXISTS raw_tweets ( json_response string ) partitioned by (dt string) stored as textfile;
alter table raw_tweets add if not exists partition(dt='2013-03-06') location 'wasb://demo@monstockageazure.blob.core.windows.net/data/socialvilles/2013-3-6';
alter table raw_tweets add if not exists partition(dt='2013-03-07') location 'wasb://demo@monstockageazure.blob.core.windows.net/data/socialvilles/2013-3-7';
alter table raw_tweets add if not exists partition(dt='2013-03-08') location 'wasb://demo@monstockageazure.blob.core.windows.net/data/socialvilles/2013-3-8';
alter table raw_tweets add if not exists partition(dt='2013-03-09') location 'wasb://demo@monstockageazure.blob.core.windows.net/data/socialvilles/2013-3-9';
alter table raw_tweets add if not exists partition(dt='2013-03-10') location 'wasb://demo@monstockageazure.blob.core.windows.net/data/socialvilles/2013-3-10';
alter table raw_tweets add if not exists partition(dt='2013-03-11') location 'wasb://demo@monstockageazure.blob.core.windows.net/data/socialvilles/2013-3-11';
alter table raw_tweets add if not exists partition(dt='2013-03-12') location 'wasb://demo@monstockageazure.blob.core.windows.net/data/socialvilles/2013-3-12';

create external table IF NOT EXISTS tweets2 (
	id string,
	lang string,
	json_response string)
partitioned by (dt string)
row format delimited fields terminated by '\t' lines terminated by '\n' stored as textfile 
location '/wasbwork/tweets2';

insert overwrite table tweets2
partition (dt)
select 
	get_json_object(json_response, '$.id_str') as id,
	get_json_object(json_response, '$.user.lang') as lang,
	json_response, 
	dt
	FROM raw_tweets
	where (length(json_response) > 500);

create external table IF NOT EXISTS tweet_details
(
	id string,
	created_at string,
	created_at_date string,
	created_at_year string,
	created_at_month string,
	created_at_day string,
	created_at_time string,
	in_reply_to_user_id_str string,
	text string,
	contributors string,
	is_a_retweet boolean,
	truncated string,
	coordinates string,
	source string,
	retweet_count int,
	url string,
	first_hashtag string,
	first_user_mention string,
	screen_name string,
	name string,
	followers_count int,
	listed_count int,
	friends_count int,
	lang string,
	user_location string,
	time_zone string,
	profile_image_url string,
	hashtags array<string>,
	user_mentions array<string>
)
partitioned by (dt string)
row format delimited fields terminated by '\t' lines terminated by '\n' stored as textfile 
location '/wasbwork/tweet_details';

insert overwrite table tweet_details
partition (dt)
select
	get_json_object(json_response, '$.id_str') as id,
	get_json_object(json_response, '$.created_at') as created_at,
	concat(substr (get_json_object(json_response, '$.created_at'),1,10),' ',
		substr (get_json_object(json_response, '$.created_at'),27,4)) as created_at_date,
	substr (get_json_object(json_response, '$.created_at'),27,4) as created_at_year,
	case substr (get_json_object(json_response, '$.created_at'),5,3)
		when "Jan" then "01"
		when "Feb" then "02"
		when "Mar" then "03"
		when "Apr" then "04"
		when "May" then "05"
		when "Jun" then "06"
		when "Jul" then "07"
		when "Aug" then "08"
		when "Sep" then "09"
		when "Oct" then "10"
		when "Nov" then "11"
		when "Dec" then "12" end as created_at_month,
	substr (get_json_object(json_response, '$.created_at'),9,2) as created_at_day,
	substr (get_json_object(json_response, '$.created_at'),12,8) as created_at_time,
	get_json_object(json_response, '$.in_reply_to_user_id_str') as in_reply_to_user_id_str,
	get_json_object(json_response, '$.text') as text,
	get_json_object(json_response, '$.contributors') as contributors,
	(cast (get_json_object(json_response, '$.retweet_count') as int) != 0) as is_a_retweet,
	get_json_object(json_response, '$.truncated') as truncated,
	get_json_object(json_response, '$.coordinates') as coordinates,
	get_json_object(json_response, '$.source') as source,
	cast (get_json_object(json_response, '$.retweet_count') as int) as retweet_count,
	get_json_object(json_response, '$.entities.display_url') as url,
	trim(lower(get_json_object(json_response, '$.entities.hashtags[0].text'))) as first_hashtag,
	trim(lower(get_json_object(json_response, '$.entities.user_mentions[0].screen_name'))) as first_user_mention,
	get_json_object(json_response, '$.user.screen_name') as screen_name,
	get_json_object(json_response, '$.user.name') as name,
	cast (get_json_object(json_response, '$.user.followers_count') as int) as followers_count,
	cast (get_json_object(json_response, '$.user.listed_count') as int) as listed_count,
	cast (get_json_object(json_response, '$.user.friends_count') as int) as friends_count,
	get_json_object(json_response, '$.user.lang') as lang,
	get_json_object(json_response, '$.user.location') as user_location,
	get_json_object(json_response, '$.user.time_zone') as time_zone,
	get_json_object(json_response, '$.user.profile_image_url') as profile_image_url,
	array(	
		trim(lower(get_json_object(json_response, '$.entities.hashtags[0].text'))),
		trim(lower(get_json_object(json_response, '$.entities.hashtags[1].text'))),
		trim(lower(get_json_object(json_response, '$.entities.hashtags[2].text'))),
		trim(lower(get_json_object(json_response, '$.entities.hashtags[3].text'))),
		trim(lower(get_json_object(json_response, '$.entities.hashtags[4].text'))),
		trim(lower(get_json_object(json_response, '$.entities.hashtags[5].text'))),
		trim(lower(get_json_object(json_response, '$.entities.hashtags[6].text'))),
		trim(lower(get_json_object(json_response, '$.entities.hashtags[7].text'))),
		trim(lower(get_json_object(json_response, '$.entities.hashtags[8].text'))),
		trim(lower(get_json_object(json_response, '$.entities.hashtags[9].text')))) as hashtags,
	array(
		trim(lower(get_json_object(json_response, '$.entities.user_mentions[0].screen_name'))),
		trim(lower(get_json_object(json_response, '$.entities.user_mentions[1].screen_name'))),
		trim(lower(get_json_object(json_response, '$.entities.user_mentions[2].screen_name'))),
		trim(lower(get_json_object(json_response, '$.entities.user_mentions[3].screen_name'))),
		trim(lower(get_json_object(json_response, '$.entities.user_mentions[4].screen_name'))),
		trim(lower(get_json_object(json_response, '$.entities.user_mentions[5].screen_name'))),
		trim(lower(get_json_object(json_response, '$.entities.user_mentions[6].screen_name'))),
		trim(lower(get_json_object(json_response, '$.entities.user_mentions[7].screen_name'))),
		trim(lower(get_json_object(json_response, '$.entities.user_mentions[8].screen_name'))),
		trim(lower(get_json_object(json_response, '$.entities.user_mentions[9].screen_name')))) as user_mentions,
	dt
from tweets2
where lang='fr'
	and coalesce(id, 'X') RLIKE '^[0-9]+$'
	and substr(coalesce(id, 'X'),1,1) RLIKE '[0-9]';

create external table IF NOT EXISTS twitter_user_location
(
id string,
user_location string)
row format delimited fields terminated by '\t' lines terminated by '\n' stored as textfile 
location '/wasbwork/twitter_user_location';

insert overwrite table twitter_user_location
select id,
	trim(upper(user_location)) as user_location
	from tweet_details
	where length(coalesce(user_location,"")) > 0;

create external table IF NOT EXISTS twitter_tags_user_location
(id string, tag string, user_location string)
partitioned by (dt string)
row format delimited fields terminated by '\t' lines terminated by '\n' stored as textfile 
location '/wasbwork/twitter_tags_user_location';

insert overwrite table twitter_tags_user_location
partition (dt)
select id, 
	tag, 
	trim(regexp_replace(
		regexp_replace(upper(user_location), 
		"FRANCE", ""), 
			"[^a-zA-Z]", 
			"")) as user_location, 
	dt
	from tweet_details
	LATERAL VIEW explode(hashtags) tagTable as tag 
where length(coalesce(tag,"")) > 0;

create external table IF NOT EXISTS twitter_tags_count
(tag string, nb_tweets bigint)
row format delimited fields terminated by '\t' lines terminated by '\n' stored as textfile 
location '/wasbwork/twitter_tags_count';

insert overwrite table twitter_tags_count
select tag, count(distinct id) as nb_tweets
	from twitter_tags_user_location
	group by tag
	order by nb_tweets desc;

create external table if not exists twitter_tags_count_100
(tag string, nb_tweets bigint)
ROW FORMAT DELIMITED
	FIELDS TERMINATED BY '\t'
	LINES TERMINATED BY '\n'
STORED AS TEXTFILE
LOCATION '/wasbwork/twitter_tags_count_100';

insert overwrite table twitter_tags_count_100
select * from twitter_tags_count
	where nb_tweets >= 100;

create external table IF NOT EXISTS twitter_tags_user_location_count
(
user_location string,
tag string, 
nb_tweets int)
row format delimited fields terminated by '\t' lines terminated by '\n' stored as textfile 
location '/wasbwork/twitter_tags_user_location_count';

insert overwrite table twitter_tags_user_location_count
select user_location, tag, count(distinct id) as nb_tweets
	from twitter_tags_user_location 
	where length(coalesce(user_location, '')) > 0
	group by user_location, tag
	order by nb_tweets desc, user_location asc, tag asc;
 
create external table if not exists twitter_tags_user_location_count_100
(
user_location string,
tag string, 
nb_tweets int)
row format delimited fields terminated by '\t' lines terminated by '\n' stored as textfile 
location '/wasbwork/twitter_tags_user_location_count_100';

insert overwrite table twitter_tags_user_location_count_100
select *
	from twitter_tags_user_location_count
	where nb_tweets >= 100;
drop table twitter_tags_user_location_dt_hh;
drop table twitter_tags_user_location_dt_hh_count;

create external table IF NOT EXISTS twitter_tags_user_location_dt_hh
(id string, tag string, user_location string, hh string)
partitioned by (dt string)
row format delimited fields terminated by '\t' lines terminated by '\n' stored as textfile 
location '/wasbwork/twitter_tags_user_location_dt_hh';

insert overwrite table twitter_tags_user_location_dt_hh
partition (dt)
select id, 
	tag, 
	trim(regexp_replace(
		regexp_replace(upper(user_location), 
		"FRANCE", ""), 
			"[^a-zA-Z]", 
			"")) as user_location, 
	substr(created_at_time, 1, 2) as hh,
	dt
	from tweet_details
	LATERAL VIEW explode(hashtags) tagTable as tag 
where length(coalesce(tag,"")) > 0;

create external table IF NOT EXISTS twitter_tags_user_location_dt_hh_count
(id string, tag string, user_location string, dt string, hh string)
row format delimited fields terminated by '\t' lines terminated by '\n' stored as textfile 
location '/wasbwork/twitter_tags_user_location_dt_hh_count';

insert overwrite table twitter_tags_user_location_dt_hh_count
select tag, user_location, dt, hh, count(distinct id) as nb_tweets
	from twitter_tags_user_location_dt_hh
	group by tag, user_location, dt, hh;
