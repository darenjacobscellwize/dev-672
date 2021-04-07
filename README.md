[DEV-672](https://jira.cellwize.com/browse/DEV-672)
Generate SQL file containing inserts to oss_info table

```
INSERT command example:

INSERT INTO oss_info (id,description,localId,name,vendor) VALUES (9,'Samsung OSS 5e8f860397b14f001d51c247','5e8f860397b14f001d51c247','5e8f860397b14f001d51c247','SAMSUNG_LTE')


OSS Ids should be taken from the following folder on Westlake Lab NFS server (172.21.188.152):
{{}}
/opt/spaces/raw_data/network/NOKIA
/opt/spaces/raw_data/network/SAMSUNG
```
