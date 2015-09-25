set hive.execution.engine=tez;
set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;
set mapred.output.compress=false;
set hive.exec.compress.output=false;
set mapred.output.compression.codec=org.apache.hadoop.io.compress.GzipCodec;
set io.compression.codecs=org.apache.hadoop.io.compress.GzipCodec; 

-- please replace the value in the following variable
set storageaccount=ul001;
set container=demo;

drop table websmall;
create external table websmall
(
	weekId string,
	TrackingId string, 
	RowId string,
	DECountryName string,
	DECity string,
	DeviceSgement string,
	FullDeviceName string,
	Model string,
	OS string,
	BrowserType string,
	Browser string,
	SessionNumber string,
	HourDate string,
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
	Quantity string,
	Stock string,
	Price string,
	Currency string,
	OrderTotalAmount string
)
row format delimited fields terminated by '\t'
stored as textfile
location 'wasb://${hiveconf:container}@${hiveconf:storageaccount}.blob.core.windows.net/websmall';

insert overwrite table websmall
select * from websgz
limit 50000;

select count(*) from websmall;

select * 
from websmall
limit 100;
