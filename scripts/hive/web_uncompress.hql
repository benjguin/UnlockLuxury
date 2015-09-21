set hive.execution.engine=tez;
set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;
set mapred.output.compress=false;
set hive.exec.compress.output=false;
set mapred.output.compression.codec=org.apache.hadoop.io.compress.GzipCodec;
set io.compression.codecs=org.apache.hadoop.io.compress.GzipCodec; 

-- please replace the value in the following variable
set storageaccount=ul001;

drop table webtxt;
create external table webtxt
(
	weekId date,
	TrackingId string, 
	RowId int,
	DECountryName string,
	DECity string,
	DeviceSgement string,
	FullDeviceName string,
	Model string,
	OS string,
	BrowserType string,
	Browser string,
	SessionNumber string,
	HourDate date,
	HourTime string,
	SessionDurationExport string,
	TrafficSource string,
	ReferrerHost string,
	SearchPhrase string,
	CampaignPV string,
	PageCountryName string,
	PageLanguage string,
	Page string,
	Animation string,
	InternalSearchPhrase string,
	Position string,
	LinkID string,
	EventType string,
	PaymentMethod string,
	ShippingMethod string,
	Sku string,
	Quantity float,
	Stock string,
	Price float,
	Currency string,
	OrderTotalAmount float
)
row format delimited fields terminated by '\t'
stored as textfile
location 'wasb://lvdata@${hiveconf:storageaccount}.blob.core.windows.net/webtxt';

insert overwrite table webtxt
select * from web;

select * 
from webtxt
limit 100;
