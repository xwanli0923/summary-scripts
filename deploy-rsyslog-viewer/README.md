# **Introduction** # 



This shell script `deploy-rsyslog-viewer.sh` is used to deploy `loganalyzer` to 
display rsyslog log data which is in `MySQL` database.

Users use loganalyzer(httpd & php) container to display log data in MySQL container. rsyslog server transfer log data collected from rsyslog client to MySQL.
    
In this case, rsyslog server, loganalyzer container and MySQL container have been 
deployed at the same node(AIO).

You should prepare `Quay v3.3.0` (current) or other registry in your environment, or load associated container image on the node.

Also you can use this script to deploy on the different nodes.

If use this script in other environment, please replace as followings:
1. all variables
2. yum repository: please pay attention to podman version
3. container image tag
4. prefix of all container images: quay.io/alberthua/{container_name}:[tag]
