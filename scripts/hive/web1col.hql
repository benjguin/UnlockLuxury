set hive.execution.engine=tez;

-- please replace the value in the following variable
set storageaccount=ul001;

drop table web1col;
create external table web1col
(
line string
)
stored as textfile
location 'wasb://lvdata@${hiveconf:storageaccount}.blob.core.windows.net/webgz';

select * 
from web1col
limit 20;
 
