#1 Read	in	the	CSV	file	using	read.csv(file.choose()) and	save	it	into	churn	data	frame.
churn=read.csv(file.choose())

#2 Examine	the structure	of	the	churn	data	frame.	
str(churn)
churn

#4 Fix	the	order	of	levels of	factors	to	match	that	in	the	table	on	the	first	page.	
levels(churn$college)
churn$college = factor(churn$college,levels(churn$college)[c(2,1)])
levels(churn$college)
#check the order of levels of factors and fix it
#rep_sat
levels(churn$rep_sat)
churn$rep_sat = factor(churn$rep_sat,levels(churn$rep_sat)[c(5,3,1,2,4)])
levels(churn$rep_sat)
#rep_usage
levels(churn$rep_usage)
churn$rep_usage = factor(churn$rep_usage,levels(churn$rep_usage)[c(5,3,1,2,4)])
levels(churn$rep_usage)
#rep_change
levels(churn$rep_change)
churn$rep_change = factor(churn$rep_change,levels(churn$rep_change)[c(3,4,2,5,1)])
levels(churn$rep_change)
#stay
levels(churn$stay)

#5 Save	the data	frame	as	churn.Rda for	later	reuse.
save(churn, file ="churn.Rda")
#6 Create	randomly	sampled	training	and	test	data	sets	with	about	66.7%	and	
#33.3%	of	the	observations,	respectively.		Use	the seed 3478	so	that	it	is	
#repeatable across	the	groups
set.seed(3478)
train = sample(1:nrow(churn),nrow(churn)*0.667)
str(train)
churn.train = churn[train,]
churn.test = churn[-train,]

#7 Grow	a	tree	using	the	training	dataset	to	explain	the	stay	class	variable.		Use	
#minsplit=100	to	keep	the	tree	small	for	now.
require(rpart)
fit = rpart(stay ~ .,data = churn.train,
            method = "class", 
            control=rpart.control(xval = 0,minsplit = 100), 
            parm=list(split = 'information'))
#8 Display	fit	(type	fit	and	hit	return). 
fit

#9
# node 1 is the parent node of node 3 and node 10, 
#but neither of node 3 and node 10 is the parent node of each other.
#        the	immediate	split	that	created	it   the	count	of	stay	  the	count	of	leave
#node 1           No,since node 1 is the root 	      6525                  6815
#node 3           house>=604440.5                     1379                  3082
#node 10          leftover>=24.5                      1221                  774

#10. Plot	and	label	the	tree. (save	the	pdf)
plot(fit,uniform = T, branch=0.5,compress=F,main="Classification Tree for predicting Churn",margin=0.05)
text(fit, use.n=T,all=T,fancy=T,pretty=T,fwidth=0.5,fheight=0.6)

#11. Print	the	confusion	matrix	for the	test	data	set.
stay.pred = predict(fit,churn.test, type = "class")
stay.actual = churn.test[,"stay"]
confusion.matrix = table(stay.actual, stay.pred)
confusion.matrix

#12. Determine	the	accuracy,	error	rates,	recall,	specificity,	and	precision	for	this	
#tree	and	the	test	data	set.
#Print	the	confusion	matrix	for this tree
train_stay.pred = predict(fit,churn.train, type = "class")
train_stay.actual = churn.train[,"stay"]
train_confusion.matrix = table(train_stay.actual,train_stay.pred)
train_confusion.matrix

#calculating the	accuracy,	error	rates,	recall,	specificity,	and	precision for test set
accuracy=(confusion.matrix[1,1]+confusion.matrix[2,2])/(confusion.matrix[2,1]+confusion.matrix[1,2]+confusion.matrix[1,1]+confusion.matrix[2,2])
FPR=(confusion.matrix[1,2])/(confusion.matrix[1,2]+confusion.matrix[1,1])
FNR=(confusion.matrix[2,1])/(confusion.matrix[2,1]+confusion.matrix[2,2])
recall=1-FNR
spec=1-FPR
prec=(confusion.matrix[2,2])/(confusion.matrix[2,2]+confusion.matrix[1,2])
#calculating the	accuracy,	error	rates,	recall,	specificity,	and	precision	for	this tree
train_accuracy=(train_confusion.matrix[1,1]+train_confusion.matrix[2,2])/(train_confusion.matrix[2,1]+train_confusion.matrix[1,2]+train_confusion.matrix[1,1]+confusion.matrix[2,2])  
train_FPR=(train_confusion.matrix[1,2])/(train_confusion.matrix[1,2]+train_confusion.matrix[1,1])
train_FNR=(train_confusion.matrix[2,1])/(train_confusion.matrix[2,1]+train_confusion.matrix[2,2])
train_recall=1-train_FNR
train_spec=1-train_FPR
train_prec=(train_confusion.matrix[2,2])/(train_confusion.matrix[2,2]+train_confusion.matrix[1,2])

#make a matrix to display these metrics for this tree and test data set
Amatrix=matrix(c(train_accuracy,train_FPR,train_FNR,train_recall,train_spec,train_prec,accuracy,FPR,FNR,recall,spec,prec),
               nrow=6,ncol=2)
rownames(Amatrix)=c("accuracy","False Positive Rate","False Negative Rate","recall","specificity","precision")
colnames(Amatrix)=c("the tree","test set")
Amatrix
#sample result 
#                     the tree  test set
#accuracy            0.8452102 0.6888889
#False Positive Rate 0.2370881 0.2636008
#False Negative Rate 0.3555393 0.3585359
#recall              0.6444607 0.6414641
#specificity         0.7629119 0.7363992
#precision           0.7395184 0.7091211


#13 Write	a	one_page	report
#please see report.docx
