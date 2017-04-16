#load ad.datax in adDataset
# load(file=file.choose())
# or the csv file
ad.datax = read.csv(file.choose(), na.strings="?")
# copy ad.datax into ad.data, we will clean this dataframe
# naive Bayes algorithm that we will only works with factors
ad.data = ad.datax
ncol(ad.data)
ad.data[0,1558]
# convert the 0/1 integers to factors for features 4 thru 1557
for (i in 4:1557){ ad.data[,i]= as.factor(ad.data[,i])}

#create the train sample
set.seed(34789)
train = sample(1:nrow(ad.datax), 0.667*nrow(ad.datax))
ad.train = ad.data[train,]
ad.test = ad.data[-train,]

#first let us just try rpart on the first three size variables
summary(ad.data[,c("height", "width", "aratio")])

#to figure out a good discretization of height, width, and aratio, contruct a tree on these
library(rpart)
trmodel = rpart(class~height+width+aratio, data=ad.train)
plot(trmodel, margin=0.1, uniform=T)
text(trmodel, use.n=T)

#based on the tree, created only using the training data set
# try width break 0, 225, 382, 650
# try height breaks 0, 23, 106, 640
# try aratio 0, 5, 100
ad.data$height = cut(ad.data$height, breaks=c(0,23,106,640), labels=c("s","m","l"))
ad.data$width = cut(ad.data$width, breaks=c(0,225,382,640), labels=c("s","m","l"))
ad.data$aratio = cut(ad.data$aratio, breaks=c(0,5,100), labels=c("a","b"))

# save(ad.data, file=file.choose())
#now rebuild the training and test data using using the same train index
#  note - train is NOT recomputed, the purpose is to pick up the discretization
ad.train = ad.data[train,]
ad.test = ad.data[-train,]

library (e1071)

## Naive Bayes Classifier for Discrete Predictors 
model = naiveBayes(class~., ad.train)
# alternative format
# model = naiveBayes(ad.train[,-1558], ad.train$class)

# predict the outcome of the first 20 records
pred = predict(model, ad.test) 
actual = ad.test$class
# form and display confusion matrix & overall accuracy
cm <- table(actual, pred )
cm
#accuracy
sum(diag(cm))/sum(cm)
# because of imbalanced class, important to look at 
# the performance in the small class - that of ads
# fnr = 25/(140+25) = 0.15 or 15% (ads predicted as non ads)

# model$apriori has the counts of each class
model$apriori  

# model$tables is a vector of tables, one for each predictor
# each table has P[xj | ci]
# eg for "caption.for" predictor
model$tables["caption.for"]

# we will use model$apriori to compute the prior probs
prior=c()  # create prior as a vector - empty for now
prior[1] = model$apriori[1]/(model$apriori[1]+model$apriori[2])
prior[2] = model$apriori[2]/(model$apriori[1]+model$apriori[2])
prior

# we will use model$tables to compute the lifts
# there are as many model$tables as there are predictors
# first let us determine the number of predictors
num.predictors = length(model$tables) 
num.predictors

# look at model$tables for a particular predictor
model$tables["caption.for"]
# note that there is a row for each class 
#    and a column for each value of preditor
#    the cells contain P[xj | ci]

# lift for a predictor = P[xj=1|ad]/(P[xj=1|ad]P[ad]+P[xj=1|noad]P[noad])
lift = c()  #inittialize empty vector
for(i in 4:num.predictors) {
  lift[i] = model$tables[[i]][1,2]/(model$tables[[i]][1,2]*prior[1] + 
                                      model$tables[[i]][2,2]*prior[2])
}

#let us take a look at the distribution of the lift
library(ggplot2)
ggplot(as.data.frame(lift), aes(lift))  + geom_histogram()
