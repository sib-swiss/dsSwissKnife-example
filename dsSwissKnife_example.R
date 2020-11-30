install.packages('devtools')
devtools::install_github('sib-swiss/dsSwissKnifeClient')
devtools::install_github('datashield/dsBaseClient')
library(dsSwissKnifeClient) # functions with the dss prefix - the objects of these tests
library(dsBaseClient) #  functions with the ds. or datashield. prefixes come from this or related DataSHIELD packages

#### The local CNSIM data frame (in this session) contains the concatenated data of the 2 remote ones
#### and will be used to compare the results of various operations
load('CNSIM.rda')

logindata <- read.delim('logindata.txt') # read the login information
logindata
# log into the 2 remote servers:
opals <- datashield.login(logindata)
#load the CNSIM table from the 2 respective databases:
datashield.assign(opals, 'cnsim', 'test.CNSIM')
#inspect it:
ds.summary('cnsim') # a bit like str() for remote data frames
# compare the above with :
str(CNSIM)

# a useful helper function to transform all non numeric data frame columns into factors...
dssMakeFactors('cnsim')
# ... that can be examined: 
dssShowFactors('cnsim')

# check the column means:
dssColMeans('cnsim') # the function looks only at the numeric columns no need to subset
# check if they correspond to the local ones:
colMeans(CNSIM[,1:5], na.rm = TRUE)
# how about the covariance matrix:
dssCov('cnsim') # again, no need to pick only the numerics, it does it for us
# got some errors, let's examine them:
datashield.errors()
# It doesn't work with NAs, so let's get rid of them. We can use one of 2 ways:
# 1) use complete cases and hope we have enough data left
# 2) impute missing data using the VIM package
#
# 1) complete cases:
dssSubset('cnsim_complete', 'cnsim', row.filter = 'complete.cases(cnsim[,1:5])')
# how many left?
ds.length('cnsim_complete$LAB_TSC') # no nrow function implemented, we use the length of one of the columns
# how does this compare with the local CNSIM?
CNSIM_COMPLETE <- CNSIM[complete.cases(CNSIM[,1:5]),]
nrow(CNSIM_COMPLETE)
# and retry the covariance matrix:
dssCov('cnsim_complete')
# and the local one:
cov(CNSIM_COMPLETE[,1:5])
#
# 2) sometimes we might need to impute data, we can do this with the VIM package
# first let's paint a picture of the missing data:
myplots <- dssVIM('aggr', newobj = NULL, async = TRUE, datasources = opals, 'cnsim' )
# the VIM package help provides more documentation about the functions aggr and kNN implemented here
# we can plot the results of the aggr function for each node:
par(mfrow = c(2,1))
lapply(myplots, plot) #
# we can now decide to impute the missing data using the VIM function kNN:
dssVIM('kNN', newobj = 'cnsim_imp', async = TRUE, datasources = opals, data = 'cnsim', imp_var = FALSE)
# this created new object called cns_imp on each remote server:
datashield.symbols(opals)
# this object has no NAs:
myplots <- dssVIM('aggr', newobj = NULL, async = TRUE, datasources = opals, 'cnsim_imp' )
lapply(myplots, plot) 
#retry the covariance matrix with cnsim_imputed
dssCov('cnsim_imp')

# Once we have the covariance matrix, PCA is easy:
dssSubset('cnsim_complete', 'cnsim_complete', col.filter = '1:5') # this time we need to keep only the numeric columns
remote_pca <- dssPrincomp('cnsim_complete')
summary(remote_pca$global)
# and the local correspondent:
local_pca <- princomp(covmat = cov(CNSIM_COMPLETE[,1:5]))
summary(local_pca)
par(mfrow = c(1,1))
plot(remote_pca$global)
biplot(remote_pca$global)

# kmeans clustering:
remote_clusters <- dssKmeans('cnsim_complete', centers = 3, iter.max = 40, nstart =30)

local_clusters <- kmeans(CNSIM_COMPLETE[,1:5], centers = 3, iter.max = 40, nstart = 30)
# compare the two:
remote_clusters$global$centers
local_clusters$centers
# we can produce biplots grouped by the 3 clusters like so:
biplot(remote_pca$global, choices = c(1,2), type = 'combine', draw.arrows = FALSE, levels = 'cnsim_complete_km_clust3', emphasize_level = 1 )
biplot(remote_pca$global, choices = c(1,2), type = 'combine', draw.arrows = FALSE, levels = 'cnsim_complete_km_clust3', emphasize_level = 2 )



datashield.logout(opals)

