# R script for dsSwissKnife demo
# Iulian Dragan, 21/12/2020

# Publication:
# Dragan, I., Sparso, T., Kuznetsov, D., Slieker, R. & Ibberson, M. dsSwissKnife: An R package for federated data analysis. bioRxiv 2020.11.17.386813 (2020). doi: 10.1101/2020.11.17.386813

# Summary
# This script contains some example code for running federated analysis using dsSwissKnife. It requires you to have already have 2 Opal virtual machines set up and running.
# For more information on how to do this please see the GitHub page https://github.com/sib-swiss/dsSwissKnife-example.


# 1) Install and load the required R packages
install.packages(c('dsBaseClient', 'dsSwissKnifeClient'), repos = c('https://cran.obiba.org', 'https://rhap-fdb01.vital-it.ch/repo' ,'https://cloud.r-project.org/'))
library(dsSwissKnifeClient) # functions with the dss prefix - the objects of these tests
library(dsBaseClient) #  functions with the ds. or datashield. prefixes come from this or related DataSHIELD packages

# replace the path in the command below with the actual path on your computer
setwd('/Users/mibber/Work/Projects/SOPHIA/WP2/dsSwissKnife/dsSwissKnife-example-main-new')

# 2) Load the example data into local memory. 
#### The local CNSIM data frame (in this session) contains the concatenated data of the 2 remote ones and will be used to compare the results of various operations
load('CNSIM.rda')


# 3) Login to the federated nodes
logindata <- read.delim('logindata.txt') # read the login information
logindata

# log into the 2 remote servers:
opals <- datashield.login(logindata)

# load the CNSIM table from the 2 respective databases:
datashield.assign(opals, 'cnsim', 'test.CNSIM')

# inspect the dataframes on the remote servers
ds.summary('cnsim') # a bit like str() for remote data frames

# compare with the local dataframe
str(CNSIM)


# 4) Perform some operations on the remote data

# a useful helper function to transform all non numeric data frame columns into factors...
dssMakeFactors('cnsim')

# ... that can be examined: 
dssShowFactors('cnsim')

# check the column means:
dssColMeans('cnsim') # the function looks only at the numeric columns no need to subset

# check if they correspond to the local ones:
colMeans(CNSIM[,1:5], na.rm = TRUE)

# how about the covariance matrix:
dssCov('cnsim') # again, no need to pick only the numeric columns, the algorithm does it for us

# This throws an error, let's examine them:
datashield.errors()

# It doesn't work with NAs, so let's get rid of them. We can use one of 2 ways:
# (i) use complete cases and hope we have enough data left
# (ii) impute missing data using the VIM package

# (i) complete cases:
dssSubset('cnsim_complete', 'cnsim', row.filter = 'complete.cases(cnsim[,1:5])')

# how many rows of data are left?
ds.length('cnsim_complete$LAB_TSC') # no nrow function implemented, we use the length of one of the columns

# how does this compare with the local CNSIM?
CNSIM_COMPLETE <- CNSIM[complete.cases(CNSIM[,1:5]),]
nrow(CNSIM_COMPLETE)

# Now we can retry the covariance matrix:
dssCov('cnsim_complete')

# and compare to the local one:
cov(CNSIM_COMPLETE[,1:5])

# (ii) sometimes we might need to impute data, we can do this with the VIM package

# first let's paint a picture of the missing data:
myplots <- dssVIM('aggr', newobj = NULL, async = TRUE, datasources = opals, 'cnsim' )

# the VIM package help provides more documentation about the functions aggr and kNN implemented here

# we can plot the results of the aggr function for each node:
par(mfrow = c(2,1))
lapply(myplots, plot) #

# we can now decide to impute the missing data using the VIM function kNN:
dssVIM('kNN', newobj = 'cnsim_imp', async = TRUE, datasources = opals, data = 'cnsim', imp_var = FALSE)

# this created new object called cns_imp on each remote server. We can look at the remote objects
datashield.symbols(opals)

# the imputed object has no NAs:
myplots <- dssVIM('aggr', newobj = NULL, async = TRUE, datasources = opals, 'cnsim_imp' )
lapply(myplots, plot) 

# Now we can retry the covariance matrix with cnsim_imputed
dssCov('cnsim_imp')


# 5) Perform federated PCA

# Once we have the covariance matrix, PCA is easy:
dssSubset('cnsim_complete', 'cnsim_complete', col.filter = '1:5') # this time we need to keep only the numeric columns
remote_pca <- dssPrincomp('cnsim_complete')
summary(remote_pca$global)

# We can compare to PCA on the local dataframe
local_pca <- princomp(covmat = cov(CNSIM_COMPLETE[,1:5]))
summary(local_pca)

# Plot the results
par(mfrow = c(1,2))

# Scree plot
plot(remote_pca$global)

# Smooth scatter biplot of the first 2 principal components
biplot(remote_pca$global)


# 6) Federated Kmeans clustering
# The federated kmeans algorithm performs kmeans clustering in parallel on multiple nodes, combining the cluster centers at each iteration.

remote_clusters <- dssKmeans('cnsim_complete', centers = 3, iter.max = 50, nstart = 60)

# dssKmeans uses the Forgy algorithm - Here we force the same for the local version:
local_clusters <- kmeans(CNSIM_COMPLETE[,1:5], centers = 3, iter.max = 50, nstart = 60, algorithm = 'Forgy')

# compare the remote and the local cluster centers:
remote_clusters$global$centers
local_clusters$centers

# The starting points at each repetition (nstart) are random; there is a slight chance that the centers will not match exactly. 
# If this is the case, an increase of the nstart parameter to 100 or more should fix the mismatch

# We can layer the kmeans cluster classification onto the PCA biplots:
biplot(remote_pca$global, choices = c(1,2), type = 'combine', draw.arrows = FALSE, levels = 'cnsim_complete_km_clust3', emphasize_level = 1 )
biplot(remote_pca$global, choices = c(1,2), type = 'combine', draw.arrows = FALSE, levels = 'cnsim_complete_km_clust3', emphasize_level = 2 )


# 7) Logout of the federated nodes
datashield.logout(opals)

