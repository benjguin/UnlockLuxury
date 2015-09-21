set hive.execution.engine=tez;
set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;

-- please replace the value in the following variable
set storageaccount=ul001;

drop table webs;
create external table webs
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
location 'wasb://lvdata@${hiveconf:storageaccount}.blob.core.windows.net/webtxt';

select * 
from webs
limit 100;
