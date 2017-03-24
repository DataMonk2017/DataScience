#1 Create	randomly	sampled	training	and	test	data	sets	with	about	66.7%	and	
#33.3%	of	the	observations,	respectively.		Use	the seed 3478	so	that	it	is	
#repeatable across	the	groups
set.seed(3478)
train = sample(1:nrow(churn),nrow(churn)*0.667)
str(train)
churn.train = churn[train,]
churn.test = churn[-train,]

#2 Use rpart to build a large complex tree with a low value of cp and minsplit. Treating
#LEAVE as Negative and STAY as positive, determine the "Big Tree" error rates (FPR
#and FNR) using the test data set. 
library(rpart)
fit.large = rpart(stay ~ ., 
                  data=churn.train, method="class",
                  control=rpart.control(xval=10, minsplit=2, cp=0))
nrow(fit.large$frame)


# extract the vector of predicted values for stay for every row
stay.pred = predict(fit.large,churn.train, type="class")
# extract the actual value of ira for every row
stay.actual = churn.train[,"stay"]
cm=table(stay.actual,stay.pred)
#Treating LEAVE as Negative and STAY as positive
# now make a function for computing the accuracy
accuracy = function(cm){  # input confusion matrix
  return(sum(diag(cm))/sum(cm))  # accuracy
}
# now make a function for computing FPR
FPR = function(cm){ # input confusion matrix
  return((cm[1,2])/(cm[1,2]+cm[1,1])) #FPR
}
# now make a function for computing FNR
FNR = function(cm){# input confusion matrix
  return((cm[2,1])/(cm[2,1]+cm[2,2])) # FNR
}
# now use this to get resubstitution accuracy
accuracy(cm)
FPR(cm)
FNR(cm)
cm
#now let us use the hold out data in churn.test
# as above, figure out the confusion matrix
stay.pred = predict(fit.large,churn.test, type="class")
stay.actual = churn.test[,"stay"]
cm.test = table(stay.actual,stay.pred)
cm.test
#accuracy FPR FNR
accuracy(cm.test)
FPR(cm.test)
FNR(cm.test)



#3. Find the best cp value to post-prune the tree. Use the test data set to find the
#"Pruned Tree" error rates. Save a PDF of a nicely formatted plot of the pruned tree.
plotcp(fit.large, # tree for which to plot
       upper="size")  # plot size of tree (no. of nodes) on top

#find the CP which provides the lowest error
lowestcp=fit.large$cptable[which.min(fit.large$cptable[,"xerror"]),"CP"]

# It appears that lowest error occurs at CP = 0.002298851
# We can use that for post-pruning
fit.post = prune.rpart(fit.large, cp=lowestcp)
nrow(fit.post$frame)
plot(fit.post, uniform=T, branch=0.5, compress=T,
     main="Tree with Post-Pruning cp = 0.002298851 (19 Nodes)", margin=0.05)
text(fit.post,  splits=T, all=F, use.n=T, 
     pretty=T, fancy=F, cex=0.7)
#Use the test data set to find the "Pruned Tree" error rates
stay.pred = predict(fit.post,churn.test, type="class")
stay.actual = churn.test[,"stay"]
cm.post.test = table(stay.actual,stay.pred)
cm.post.test
#accuracy FPR FNR
accuracy(cm.post.test)
FPR(cm.post.test)
FNR(cm.post.test)


#4 Use ROCR to find the best threshold. Using this recommended threshold, determine
#the "Best Threshold Pruned Tree" error rates for the test data set.
library(ROCR)
# ROC for fit.post
stay.pred.test <- predict(fit.post, churn.test, type = "prob")
stay.pred.score = prediction(stay.pred.test[,2],churn.test$stay)
stay.pred.perf = performance(stay.pred.score, "tpr", "fpr")

plot(stay.pred.perf, 
     colorize=T, # colorize to show cutoff values
     lwd=4) # make the line 4 times thicker than default
abline(0,1)  # draw a line with intercept=0, slope = 1
abline(h=1) #draw a horizontal line at y = 1
abline(v=0) #draw a vertical line at x = 0

# now for cost tradeoff
stay.cost = performance(stay.pred.score, measure="cost", cost.fn=490000*400, cost.fp=510000*100)
plot(stay.cost)
#seems to be minimized around 0.2
# meaning if Prob[yes] < 0.2068036 assign to NO else YES
# we can find this more precisely
cutoffs = data.frame(cut=stay.cost@"x.values"[[1]], cost=stay.cost@"y.values"[[1]])
best.index = which.min(cutoffs$cost)
cutoffs[best.index,]

stay.pred.test.cutoff = 
  ifelse(stay.pred.test[,2] < cutoffs[best.index,"cut"],"Leave","Stay")
cm.best= table(churn.test$stay,stay.pred.test.cutoff)
cm.best

accuracy(cm.best)
FPR(cm.best)
FNR(cm.best)

#5 For each of the error rates determined in steps 2, 3 and 4 above, find the expected
#values of strategy (c), for the firm. Display the result in a table with rows for Big
#Tree, Pruned Tree, and Best Threshold Pruned tree; and columns for FPR, FNR,
#Accuracy, Expected Value. The Expected Value column refers to the expected value
#of strategy (c).

#make a function to get exected value
ExpectValue=function(cm){
  return (490000*1000+100*510000-510000*100*FPR(cm)-490000*400*FNR(cm))
}

#presrent a table
Amatrix=matrix(c(FPR(cm.test),FPR(cm.post.test),FPR(cm.best),
                 FNR(cm.test),FNR(cm.post.test),FNR(cm.best),
                 accuracy(cm.test),accuracy(cm.post.test),accuracy(cm.best),
                 ExpectValue(cm.test),ExpectValue(cm.post.test),ExpectValue(cm.best)),
               nrow=3,ncol=4)
rownames(Amatrix)=c("BigTree", "Pruned Tree","Best Threshold Pruned tree")
colnames(Amatrix)=c("FPR","FNR","Accuracy","Expected Value")
#round the decimal to 4 digits
round(Amatrix, digits = 4)
