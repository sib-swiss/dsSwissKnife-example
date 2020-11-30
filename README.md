Utilisation examples for the R package dsSwissKnife
============

Instructions
============
You will need a fairly recent computer with at least 10 GB of RAM and the docker and docker-compose software for your platform.
Alternatively you can ask a sysadmin to download and run the docker images on a server. In this case you will have to modify the logindata.txt file
by replacing 'localhost' with the actual ip address of the server.

Please download this repository (click the green Code button, then Download zip) and unzip it.
Run docker-compose with the provided docker-compose.yml file.I

In Linux the command would be 
<code>
docker-compose up -d
</code>
  
At the first run the docker images will be downloaded, this will take about 20 - 30 minutes depending on your internet speed.
Once the containers are created and executed, please run R or RStudio in the newly created folder (or setwd() to this folder)
Execute the lines in the script one by one and examine the results.




