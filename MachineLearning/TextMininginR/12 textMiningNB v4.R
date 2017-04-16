
library(tm)
library(SnowballC)
library(e1071)
library(caret)
library(ggplot2)
library(ROCR)
# now make a function for accuracy
accuracy = function(cm){  # input confusin matrix
  return(sum(diag(cm))/sum(cm))  # accuracy
}

#library(tm)
#process the positive ones
 pos.reviews = VCorpus(DirSource(choose.dir()))  #on Windows, macs see above
# choose.dir is not available on macs
#  on macs use the actual path in quotes
#  easy way to get this: right click on directory, 
#  pick "get info" and then copy and paste from "where"
# pos.reviews = VCorpus(DirSource("~/Dropbox/Documents/CLASS/CIS417/Data/Movie Reviews/Reviews/1-pos/"))

# now process the negative ones
neg.reviews = VCorpus(DirSource(choose.dir()))
# on a mac
# neg.reviews = VCorpus(DirSource("~/Dropbox/Documents/CLASS/CIS417/Data/Movie Reviews/Reviews/2-neg/"))
# now combine the corpora into one for cleaning, etc
all.reviews.raw = c(pos.reviews, neg.reviews, recursive=T) #recursive=T maintain metadata
#Pcorpus
# now build the class vector
pos = rep("pos",length(pos.reviews)) #rep(what to repeat, how many times)
neg = rep("neg", length(neg.reviews))
class = c(pos, neg) #concatenate the two vectors
class = as.factor(class) #convert to factor from string
# prepare sample vector for training and testing
set.seed(458)
train = sample(1:length(all.reviews.raw), 0.667*length(all.reviews.raw), replace=F)
class.train = class[train]
class.test = class[-train]
#free up some memory
# save(all.reviews.raw, file=file.choose())
# rm(pos.reviews, neg.reviews, pos, neg)

# let us check them out
summary(class)
#print() provides number of documents in each corpus
print(all.reviews.raw)
#can get more details on any one document
inspect(all.reviews.raw[5])
# and you can see it as well
writeLines(as.character(all.reviews.raw[[5]]))
#see the metadata
meta(all.reviews.raw[[5]])

#now clean up the data

#convert to all lowercase
# note start with all.reviews.raw but use just all.reviews henceforth
ptm=proc.time()
all.reviews = tm_map(all.reviews.raw, content_transformer(tolower))
# remove all numbers
all.reviews = tm_map(all.reviews, content_transformer(removeNumbers))
#remove all punctuation
all.reviews = tm_map(all.reviews, content_transformer(removePunctuation))
#remove all stopwords
all.reviews = tm_map(all.reviews, removeWords, stopwords("english"))
#now let us stem it
#library(SnowballC)
all.reviews = tm_map(all.reviews, stemDocument)
#remove whitespace
all.reviews = tm_map(all.reviews, content_transformer(stripWhitespace))
proc.time()-ptm
# lets take a look
writeLines(as.character(all.reviews[[5]]))
# save(all.reviews, file=file.choose())

# now make the document term matrix
dtm = DocumentTermMatrix(all.reviews)
dtm
# save(dtm, file=file.choose())

#note that the sparsity is 99%, and there at 30,585 terms
# most of the terms are in very few documents
# let us remove terms occur in only a few documents
# for this we will use removeSparseTerms(dtm, ss)
#   where ss is the upper limit on sparsity for a term

dtm.95 = removeSparseTerms(dtm, 0.95)
dtm.95
# note that we have 1,047 terms with 86% sparsity

#now form the dataset and do the model building
dtm.df = as.data.frame(as.matrix(dtm.95))
dtm.train = dtm.df[train,]
dtm.test = dtm.df[-train,]
#load e1071
#library(e1071)
model = naiveBayes(dtm.train, class.train)
# first the resubstitution error
pred = predict(model, dtm.train)
cm = table(class.train, pred)
cm
accuracy(cm)
#now test error
pred = predict(model, dtm.test)
cm = table(class.test, pred)
cm
accuracy(cm)

# now get a better estimate with cross validation
# needs the caret package
#library(caret)
train_control = trainControl(method="cv", number=3, repeats=1)
# train the model 
model = train(dtm.df, class, trControl=train_control, method="nb")
# make predictions
pred = predict(model, dtm.test)
cm = table(class.test, pred)
cm
accuracy(cm) 


# try a nunber of different values
sparsity.setting = c(0.985, 0.975, 0.95, 0.90)
num.terms = c()
sparsity = c()
err.resub = c()
err.test = c()
nss = length(sparsity.setting)
for (i in 1:nss){
  dtm.ss = removeSparseTerms(dtm, sparsity.setting[i])
  num.terms[i] = dtm.ss$ncol  # number of terms
  sparsity[i] = 1 - length(dtm.ss$i)/(dtm.ss$ncol * dtm.ss$nrow) # sparsity
  # make the datasets
  dtm.df = as.data.frame(as.matrix(dtm.ss))
  dtm.train = dtm.df[train,]
  dtm.test = dtm.df[-train,]
  model = naiveBayes(dtm.train, class.train)
  #resub error
  pred = predict(model, dtm.train)
  err.resub[i] = 1 - accuracy(table(class.train, pred))
  #now test error
  pred = predict(model, dtm.test)
  err.test[i] = 1 - accuracy(table(class.test, pred))
}
# turn into df
report.sp.tf = data.frame(sparsity.setting, sparsity, 
                       num.terms, err.resub, err.test)
report.sp.tf
# best error.test 27.03% with 1,047 terms

#library(ggplot2)

ggplot(report.sp.tf) + geom_point(aes(num.terms,err.resub), color="blue", size=6) + 
  geom_line(aes(num.terms,err.resub), color="blue", size=1.5) +
  geom_point(aes(num.terms,err.test), color="red", size=6) + 
  geom_line(aes(num.terms,err.test), color="red", size=1.5) +
  ylab("Error Rate") + xlab("Number of Terms") +
  theme(panel.background = element_blank(), axis.line = element_line(colour = "black"),
        text = element_text(size=30, color="black"))

# now make the document term matrix with tfidf weighting
dtm = DocumentTermMatrix(all.reviews, control = list(weighting = weightTfIdf))
dtm
#note that the sparsity is 99%, and there at 30,585 terms
# most of the terms are in very few documents
# let us remove terms that are in fewer than 99% of documents
sparsity.setting = c(0.985, 0.975, 0.95, 0.90)
num.terms = c()
sparsity = c()
err.resub = c()
err.test = c()
nss = length(sparsity.setting)
for (i in 1:nss){
  dtm.ss = removeSparseTerms(dtm, sparsity.setting[i])
  num.terms[i] = dtm.ss$ncol  # number of terms
  sparsity[i] = 1 - length(dtm.ss$i)/(dtm.ss$ncol * dtm.ss$nrow) # sparsity
  # make the datasets
  dtm.df = as.data.frame(as.matrix(dtm.ss))
  dtm.train = dtm.df[train,]
  dtm.test = dtm.df[-train,]
  model = naiveBayes(dtm.train, class.train)
  #resub error
  pred = predict(model, dtm.train)
  err.resub[i] = 1 - accuracy(table(class.train, pred))
  #now test error
  pred = predict(model, dtm.test)
  err.test[i] = 1 - accuracy(table(class.test, pred))
}
# turn into df
report.sp.tfidf = data.frame(sparsity.setting, sparsity, 
                          num.terms, err.resub, err.test)

report.sp.tfidf
# best test.error of 24.47% with 1,834 terms

ggplot(report.sp.tfidf) + 
  geom_point(aes(num.terms,err.resub), color="steelblue2", size=6, shape=17) + 
  geom_line(aes(num.terms,err.resub), color="steelblue2", size=1.5) +
  geom_point(aes(num.terms,err.test), color="deeppink2", size=6, shape=17) + 
  geom_line(aes(num.terms,err.test), color="deeppink2", size=1.5) +
  geom_point(data=report.sp.tf, aes(num.terms,err.resub), color="steelblue4", size=6) + 
  geom_line(data=report.sp.tf, aes(num.terms,err.resub), color="steelblue4", size=1.5, linetype="dashed") +
  geom_point(data=report.sp.tf, aes(num.terms,err.test), color="deeppink4", size=6) + 
  geom_line(data=report.sp.tf, aes(num.terms,err.test), color="deeppink4", size=1.5, linetype="dashed") +
  ylab("Error Rate") + xlab("Number of Terms") +
  theme(panel.background = element_blank(), axis.line = element_line(colour = "black"),
        text = element_text(size=30, color="black"))

#now leave the stopwords in and use tfidf
#now clean up the data
#remove whitespace
all.reviews = tm_map(all.reviews.raw, content_transformer(stripWhitespace))
#convert to all lowercase
all.reviews = tm_map(all.reviews, content_transformer(tolower))
# remove all numbers
all.reviews = tm_map(all.reviews, content_transformer(removeNumbers))
#remove all punctuation
all.reviews = tm_map(all.reviews, content_transformer(removePunctuation))
#now let us stem it
all.reviews = tm_map(all.reviews, stemDocument)

# now make the document term matrix
dtm = DocumentTermMatrix(all.reviews, control = list(weighting = weightTfIdf))
dtm
#note that the sparsity is 99%, and there at 30,657 terms
# most of the terms are in very few documents
# let us remove terms that are in fewer than 99% of documents
sparsity.setting = c(0.985, 0.975, 0.95, 0.90)
num.terms = c()
sparsity = c()
err.resub = c()
err.test = c()
nss = length(sparsity.setting)
for (i in 1:nss){
  dtm.ss = removeSparseTerms(dtm, sparsity.setting[i])
  num.terms[i] = dtm.ss$ncol  # number of terms
  sparsity[i] = 1 - length(dtm.ss$i)/(dtm.ss$ncol * dtm.ss$nrow) # sparsity
  # make the datasets
  dtm.df = as.data.frame(as.matrix(dtm.ss))
  dtm.train = dtm.df[train,]
  dtm.test = dtm.df[-train,]
  model = naiveBayes(dtm.train, class.train)
  #resub error
  pred = predict(model, dtm.train)
  err.resub[i] = 1 - accuracy(table(class.train, pred))
  #now test error
  pred = predict(model, dtm.test)
  err.test[i] = 1 - accuracy(table(class.test, pred))
}
# turn into df
report.sp.tfidf.s = data.frame(sparsity.setting, sparsity, 
                             num.terms, err.resub, err.test)
report.sp.tfidf.s

ggplot(report.sp.tfidf.s) + 
  geom_point(aes(num.terms,err.resub), color="lightblue", size=6, shape=15) + 
  geom_line(aes(num.terms,err.resub), color="lightblue", size=1.5) +
  geom_point(aes(num.terms,err.test), color="pink", size=6, shape=15) + 
  geom_line(aes(num.terms,err.test), color="pink", size=1.5) +
  geom_point(data=report.sp.tfidf, aes(num.terms,err.resub), color="steelblue2", size=6, shape=17) + 
  geom_line(data=report.sp.tfidf, aes(num.terms,err.resub), color="steelblue2", size=1.5, linetype="dashed") +
  geom_point(data=report.sp.tfidf, aes(num.terms,err.test), color="deeppink2", size=6, shape=17) + 
  geom_line(data=report.sp.tfidf, aes(num.terms,err.test), color="deeppink2", size=1.5, linetype="dashed") +
  geom_point(data=report.sp.tf, aes(num.terms,err.resub), color="steelblue4", size=6) + 
  geom_line(data=report.sp.tf, aes(num.terms,err.resub), color="steelblue4", size=1.5, linetype="dotted") +
  geom_point(data=report.sp.tf, aes(num.terms,err.test), color="deeppink4", size=6) + 
  geom_line(data=report.sp.tf, aes(num.terms,err.test), color="deeppink4", size=1.5, linetype="dotted") +
  ylab("Error Rate") + xlab("Number of Terms") +
  theme(panel.background = element_blank(), axis.line = element_line(colour = "black"),
        text = element_text(size=30, color="black"))
  ylab("Error Rate") + xlab("Number of Terms") +
  theme(panel.background = element_blank(), axis.line = element_line(colour = "black"),
        text = element_text(size=30, color="black"))

report.sp.tfidf.s
# best test error of 24.47% with 1,129 terms, at sparsity.setting = 0.95

# Some more charts
# using all.reviews with stop words and tfidf weighting
# run the model again with the proper settings
dtm.df = as.data.frame(as.matrix(removeSparseTerms(dtm, 0.95)))
dtm.train = dtm.df[train,]
dtm.test = dtm.df[-train,]
model = naiveBayes(dtm.train, class.train)
#test prob prediction
pred = predict(model, dtm.test, type="raw")
pred[1:10,1:2]

#library(ROCR)
score = prediction(pred[,2], class.test)

# ROC chart tpr vs fpr
perf = performance(score,"tpr","fpr")
plot(perf, main="ROC Chart", colorize=T, lwd=2)
abline(0,1)
abline(h=0)
abline(h=1)
abline(v=1)
abline(v=0)

#area under the curve
performance(score, "auc")@y.values

#lift chart tpr vs rpp
# tpr = TP/P  
# rate of positive prediction rpp = (TP + FP)/(P+N)
# random classifier has tpr 
perf = performance(score,"tpr","rpp")
plot(perf, main="Lift Chart", colorize=T, lwd=2)
abline(0,1)

