## Utilisation examples for the R package dsSwissKnife

Docker images and script with usage examples for the R packages dsSwissKnifeClient (https://github.com/sib-swiss/dsSwissKnifeClient) and dsSwissKnife (https://github.com/sib-swiss/dsSwissKnife)

### Instructions

You will need a fairly recent computer with at least 6 GB of RAM and the docker and docker-compose software for your platform.\
If you are running docker on Mac or Windows please increase the memory available to the docker vm at 4 GB.\
Alternatively you can ask a sysadmin to download and run the docker images on a server. In this case you will have to modify the logindata.txt file
by replacing 'localhost' with the actual ip address of the server.

Please download this repository (click the green Code button, then Download zip) and unzip it.\
Open a terminal, cd to into the newly created folder and run docker-compose with the provided docker-compose.yml file.\
In Linux the command would be:
<code>
docker-compose up -d
</code>
  
At the first run the docker images will be downloaded, this will take about 20 - 30 minutes depending on your internet speed.
This will be followed by about 5 - 10  minutes of package updates, the system will only be available once this process is finished (the progress can be followed in one of the rserver containers in /srv_local/logs/Rserve.log). In the subsequent runs there will still be a wait time of about 5 minutes until all the servers are started.

Once the containers are created and executed, please run R or RStudio in the newly created folder (or setwd() to this folder).
Execute the lines in the dsSwissKnife_example.R script one by one and examine the results.

A few useful docker commands:
* list all the running containers:             <code>docker ps</code>
* stop all the running containers:             <code>docker stop $(docker ps -aq)</code>
* open a shell in the container:               <code>docker exec -it dsswissknife-example_opal_server1_1 /bin/bash</code>
* examine resource consumption per container:  <code>docker stats</code>



