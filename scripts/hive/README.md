#hive scripts

Script name | purpose
------------|-------------
twitter.hql | a sample script that counts data out of Twitter stored as JSON
web1col.hql | defines an external table that shows the Web Analytics data without any indication on the columns. This can be used to discover the structure
web.hql | defines an external table that shows the Web Analytics data with typed columns (dates, numbers). Spark SQL may not like it
websgz.hql | defines an external table that shows the Web Analytics data with string columns.
web_uncompress.hql | copies data from .txt.gz files to .txt files. This defines a new webtxt external table that points to this data. 
web_sample_queries.hql | sample queries on the Web Analytics dataset