# import student survey.csv using R studio
#  make sure to remove NA from na.strings option
#  data imported into student.survey
#  see documentation for details


#some summary statistics
summary(student.survey)
# notice lots of missing data

#lets look at the means more carefully
means.ss = data.frame(means=  #make a new data frame with column "means"
    # sapply(dataframe, function to apply
    sapply(student.survey[,5:50], mean, 
          na.rm=T))  #, how to treat na)
# R automatically names the rows with the columns whose  means were calculated
#also create a column that is the difference of the mean of category from overall satisfaction
means.ss$diff = means.ss$means - means.ss["Overall_Satisfaction","means"]
# let us define categories of features
means.ss$cat = c(rep("Teach",7), rep("Curr",10), 
                 rep("Adv",4), rep("Acad",8), rep("Other",4), rep("CMC",10),
                 rep("Overall",3))
means.ss  #check it
# can save as Excel file 
# library(xlsx)
# write.xlsx(means.ss, 
   "/Users/dewan/Dropbox/Documents/CLASS/CIS417/Data/Student Satisfaction/Story/means.ss.xlsx")
# or as Rda.  Tableau can read Rda
save(means.ss, 
      file="/Users/dewan/Dropbox/Documents/CLASS/CIS417/Data/Student Satisfaction/Story/means.ss.Rda")
#now lets visualize this using ggplot
#let us first visualize the data
library(ggplot2)
ggplot(means.ss, aes(x=rownames(means.ss), means, fill=cat)) + 
     geom_bar(stat="identity") +   #basic bar plot
     theme(axis.text.x=element_text(angle=90, hjust=1)) # fix x axis labels
# you can notice some trends 
# teaching categories best, cmc worst

#now let us look at diff - difference of column mean from mean overall satisfactoion
ggplot(means.ss, aes(x=rownames(means.ss), diff, fill=cat)) + 
  geom_bar(stat="identity") +   ##bar plot of means row by row not histogram
  theme(axis.text.x=element_text(angle=90, hjust=1)) # fix x axis labels

# there is always a lot of covmovement in surveys
# columns 5:11 are Teaching related
cor(student.survey[,5:11], use="pairwise.complete.obs")
#now save it for visualization using Tableau
cor.ss = cor(student.survey[,5:50], use="pairwise.complete.obs")
save(cor.ss, 
           file="/Users/dewan/Dropbox/Documents/CLASS/CIS417/Data/Student Satisfaction/Story/cor.ss.Rda")

# can we say more, lets visualize a subset using R
p = ggplot(student.survey)
# p + geom_point(aes(Teaching_Core, Teaching_FacQual))
p+ geom_point(aes(Teaching_Core, Teaching_FacQual)) + facet_grid(Nationality ~ Gender)

# pca does not work with obs with missing values
# some columns have very many mising values, eg. CMCInternshiphelp has 28 na
# let us find the number of observations that are complete
nrow(na.omit(student.survey[,4:50]))
# so only 51 observations are complete with no missing value for any column

#now for princ component analysis
pca.out = prcomp(na.omit(student.survey), scale=T)

# look at the structure of pca.out
str(pca.out)
# sdev is the sd explained
# rotation is the loading - coefficients for columns to make the score
# center is the mean which was used to re-center observations, making new mean 0
# scale is the sd of original column used to scale sd to 1
# x is the fitted value
ncol(student.survey)
student.survey
# you can print out a readable version
summary(pca.out)
# this is very good
# first 5 variables explain almost 60% of the variance
# lets visualize these

# first let us create vector of variances from sd
pca.var = pca.out$sdev^2
pca.pve = data.frame(pve=pca.var/sum(pca.var))  # this is what we had in the summary

plot(pca.pve$pve)
plot(cumsum(pca.pve$pve))

save(pca.pve, 
           file="/Users/dewan/Dropbox/Documents/CLASS/CIS417/Data/Student Satisfaction/Story/pca.pve.Rda")
#lets look at the loadings of the first two components
biplot(pca.out)
# the loadings are stored in the rotation part of the output
pca.out$rotation[,1:2]

#now we cluster
library(cluster)
library(fpc)
# note that pca.out$x are the scores for the observations
#  a row for each observation with the rowname = original obs no
#  a column for each score, with row names PC1, PC2, ...
# we want to cluster using these
# lets use the first 2 components
# and make 3 clusters
clus.out = kmeans(pca.out$x[,1:2], 4)
# the clus.out$cluster has the cluster assignment
clus.out$cluster
# let us plot the cluster
plotcluster(pca.out$x[,1:2], clus.out$cluster)

# to see other choices
plotcluster(pca.out$x[,1:2], kmeans(pca.out$x[,1:2], 2)$cluster)
plotcluster(pca.out$x[,1:2], kmeans(pca.out$x[,1:2], 3)$cluster)
plotcluster(pca.out$x[,1:2], kmeans(pca.out$x[,1:2], 4)$cluster)
plotcluster(pca.out$x[,1:2], kmeans(pca.out$x[,1:2], 5)$cluster)

# now let us look more closely at the clusters
# let us start by figuring which rows we used for pca
rows.used = as.integer(row.names(pca.out$x))
rows.used
# now let us make a new data set from student.survey
#  with only the rows used for pca
#  with only demographic, overall evaluation, and a cluster column
# start by adding a column titled cluster into student.survey
ss.out = cbind(student.survey[rows.used,c(1,2,3,4,48,49,50)], 
                 cluster=clus.out$cluster)

# now let us look at the means by cluster
aggregate(.~cluster, ss.out ,mean )

#re-order cluster in order of increasing overall sat mean
# cluster numbers with increasing overall sat 
# cluster 1 becomes 4, 2 becomes 1, 3 becomes 2 and 4 becomes 3
for (i in 1:nrow(ss.out)) ss.out[i,"cluster"] = switch(ss.out[i,"cluster"], 4,1,2,3)

# now let us look at the means by cluster
aggregate(.~cluster, ss.out ,mean )

# cluster plot in detail for export
dcf = discrcoord(pca.out$x[,1:2], clus.out$cluster)
clus.coord = cbind(ss.out, dcf$proj)
save(clus.coord, 
      file="C:/Users/dewan/Dropbox/Documents/CLASS/CIS417/Data/Student Satisfaction/Story/clus.coord.Rda")
rownames(clus.coord)

# data for parallel plot
clus.pc = data.frame(cluster=ss.out$cluster,
      cv=(ss.out$cluster-1)*33.33,
      gender = student.survey[rows.used,"Gender"],
      female=(student.survey[rows.used,"Gender"]-1)*95, 
      have_offer = student.survey[rows.used,"Have_offer"],
      withjob = (2-student.survey[rows.used,"Have_offer"])*95,
      nationality = student.survey[rows.used,"Nationality"],
      foreign = (student.survey[rows.used,"Nationality"]-1)*95,
      teach = (rowSums(student.survey[rows.used,5:11])/7 -1)*10,
      curr = (rowSums(student.survey[rows.used,12:21])/10 -1)*10,
      adv = (rowSums(student.survey[rows.used,22:25])/4 -1)*10,s
      acad = (rowSums(student.survey[rows.used,26:33])/8 -1)*10,
      cmc = (rowSums(student.survey[rows.used,38:47])/10 -1)*10,
      overall = (rowSums(student.survey[rows.used,48:50])/3 -1)*10
)
#add jitter
clus.pc$female = clus.pc$female + 5* runif(49)
clus.pc$withjob = clus.pc$withjob + 5* runif(49)
clus.pc$foreign = clus.pc$foreign + 5* runif(49)

save(clus.pc, 
     file="C:/Users/dewan/Dropbox/Documents/CLASS/CIS417/Data/Student Satisfaction/Story/clus.pc.Rda")
