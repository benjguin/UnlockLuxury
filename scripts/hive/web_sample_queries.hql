set hive.execution.engine=tez;
set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;
set mapred.output.compress=true;
set hive.exec.compress.output=true;
set mapred.output.compression.codec=org.apache.hadoop.io.compress.GzipCodec;
set io.compression.codecs=org.apache.hadoop.io.compress.GzipCodec; 

select count(*) as nbLines
from web;

select 
	weekId, 
	min(HourDate) as minDate, 
	max(HourDate) as maxDate, 
	count(*) as nbLines
from web
group by weekId
order by weekId asc;
