sudo docker kill ears-server_acquisition ears-server_postgres ears-server_tomcat ears-server_mysql
sudo docker-compose build &&
sudo docker-compose up -d
sleep 70
echo Finished! Go to http://localhost:8181/ears3
echo -ne '\007'
