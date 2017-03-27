#!usr/bin/python2.7 python 
# -*- coding:utf-8 -*-
#@author: Jianyuan Zheng
import numpy as np
import sys
from sklearn.datasets import load_svmlight_file
	
def perceptron_fit(x,y,maxiter=300):
	'''
	fit the adult data with raw perceptron
	use activation function g=tanh(a)

	input:
		x:features  2-d numpy array
		y:class labels	1-d numpy array
		maxiter: maximum iteration. default 1000
	output:
		w:weights
	'''
	temp=[]
	iter=1
	list_w=[]
	w=np.zeros(x.shape[1]+1)
	b=np.asmatrix(np.ones(x.shape[0])).T
	x=np.asarray(np.concatenate((x,b),axis=1))
	t=np.zeros(x.shape[0])    
	while iter<=maxiter:        
		for index in range(x.shape[0]):
			t[index]=np.sign(np.dot(w,x[index].T))
			if t[index]!=y[index]:
				w=w+y[index]*x[index]
		iter+=1
		cr=(t==y).sum()

		if cr==x.shape[0]:
			print "interation:",iter
			break
		temp.append(cr)
		list_w.append(w)
	#else:
	#	print 'reach the max iteration'
	#print 'best iteration:',np.argmax(temp)
	return list_w[np.argmax(temp)]

def perceptron_fit_gd(x,y,maxiter=300):
	'''
	fit the adult data with perceptron with gradien decent
	use activation function g=tanh(a)

	input:
		x:features  2-d numpy array
		y:class labels	1-d numpy array
		r: learning rate.
		maxiter: maximum iteration. default 300
	output:
		w:weights
	'''
	iter=1
	w=np.asmatrix(np.zeros(x.shape[1]+1))
	b=np.asmatrix(np.ones(x.shape[0])).T
	x=np.concatenate((x,b),axis=1)
	temp=[]
	list_w=[]
	t=np.zeros(x.shape[0])
	while iter<maxiter:
		r=1.0/iter
		for index in range(x.shape[0]):
			a=np.dot(w,np.asmatrix(x[index]).T)[0,0]
			#print a
			t[index]=np.tanh(a)
			da=1-(np.tanh(a))**2 # derivative of t w.r.t a
			de=np.multiply((t[index]-y[index])*da,x[index])# derivative of E w.r.t w
			w=np.subtract(w,np.multiply(r,de))
			E=np.sum(np.multiply(0.5,np.square(np.subtract(t,y))))
		temp.append(E)
		list_w.append(w)
		iter+=1
	#print E
	#print 'best iteration:', np.argmin(temp)+1
	return list_w[np.argmin(temp)]

def preceptron_predict(w,x):
	'''
	predict the adult data with perceptron

	input:
		x:features  2-d numpy array
	output:
		t:predicted class label
	'''
	b=np.asmatrix(np.ones(x.shape[0])).T
	x=np.concatenate((x,b),axis=1)
	t=np.zeros(x.shape[0])
	for index in range(x.shape[0]):
		a=np.dot(w,np.asmatrix(x[index]).T)
		t[index]=np.tanh(a)
	t=np.sign(t)
	return t


def svm(x,y,c=1,maxiter=10000,r=1,threshold=10**(-4)):
	'''
	fit the adult data with svm
	input:
		x:features  2-d numpy array
		y:class labels	1-d numpy array
		r: learning rate. default initiate 1, r=1/iter
		maxiter: maximum iteration. default 10000
		c: C
		threshold:threshold for stopping criterion
	output:
		w:weights
	'''
	b=0
	w=np.zeros(x.shape[1])
	t=np.zeros(x.shape[0])
	iter=1
	list_w=[]
	temp=[np.inf]
	N=float(x.shape[0])
	zero=np.zeros((N,1))
	while iter<=maxiter:
		r=1.0/iter
		for index in range(x.shape[0]):
			if 1-y[index]*(np.dot(w,x[index].T)+b)>0:
				w=w-r*(w/N-c*y[index]*x[index])
				b=b+r*(c*y[index])
			else:
				w=w-r*(w/N)
		list_w.append(w)
		l=0.5*(np.linalg.norm(w)**2)+c*np.sum(np.maximum(zero,np.subtract(1,np.dot(y,(np.dot(w,x.T)+b)))))#loss function
		iter+=1
		if (temp[-1]-l<threshold) and (len(temp)>1):
			break
		temp.append(l)
	else:
		#print "reach max iteration"
		#print np.min(l)
		return list_w[np.argmin(l)-1]
	return w,b

def svm_predict(w,x,b):
	'''
	predict the adult data with svm
	input:
		x:features  2-d numpy array
	output:
		predicted class label
	'''
	return np.sign(np.dot(w,x.T)+b)

def accuracy (x,y):
	''' return accuracy,compared between x and y
	x:predict class
	y:original class
	'''
	correct_result = (x==y).sum()
	acc = float(correct_result)/y.shape[0]
	return correct_result,acc
	
	
if __name__=='__main__':
	#preprocess the data file: convert the file to numpy.ndarray 
	X,y = load_svmlight_file('/u/cs246/data/adult/a7a.train', n_features=123)
	X_dev,y_dev = load_svmlight_file('/u/cs246/data/adult/a7a.dev', n_features=123)
	#X,y = load_svmlight_file('s7a.train', n_features=123)
	#X_dev,y_dev = load_svmlight_file('s7a.dev', n_features=123)	
	X_test,y_test = load_svmlight_file(sys.argv[1], n_features=123)
	#X_test,y_test = load_svmlight_file('s7a.test', n_features=123)
	X = X.toarray()
	X_dev = X_dev.toarray()
	X_test = X_test.toarray()

	#raw perceptron
	weight_trained=perceptron_fit(X,y)
	p_ori=preceptron_predict(weight_trained,X_dev)
	p_ori_train=preceptron_predict(weight_trained,X)
	p_ori_test=preceptron_predict(weight_trained,X_test)
	_,acc_ori_train=accuracy(p_ori_train,y)
	_,acc_ori_dev=accuracy(p_ori,y_dev)
	_,acc_ori_test=accuracy(p_ori_test,y_test)

	#perceptron with gradien decent
	weight_gd_trained=perceptron_fit_gd(X,y)
	p_gd_train=preceptron_predict(weight_gd_trained,X)
	p_gd_test=preceptron_predict(weight_gd_trained,X_test)
	p_gd_dev=preceptron_predict(weight_gd_trained,X_dev)
	_,acc_gd_dev=accuracy(p_gd_dev,y_dev)
	_,acc_gd_train=accuracy(p_gd_train,y)
	_,acc_gd_test=accuracy(p_gd_test,y_test)		


	#SVM
	list_c=np.linspace(0, 1, 51, endpoint=True)
	l_acc_dev=[]
	for c in list_c:
		weight,b=svm(X,y,c)
		_,acc=accuracy(svm_predict(weight,X_dev,b),y_dev)
		l_acc_dev.append(acc)

	index_c=np.argmax(l_acc_dev)
	#print "best c",list_c[index_c]
	best_weight,b=svm(X,y,list_c[index_c])
	_,acc_svm_dev=accuracy(svm_predict(best_weight,X_dev,b),y_dev)
	_,acc_svm_test=accuracy(svm_predict(best_weight,X_test,b),y_test)
	#print acc_svm_dev,acc_svm_test

	print '-----------------------dev data--------------------------'
	print "baseline of train data:",max(accuracy(np.ones(y_dev.shape[0]),y_dev)[1],1-accuracy(np.ones(y_dev.shape[0]),y_dev)[1])
	print 'The accuracy of raw perceptron is ',acc_ori_dev
	print 'The accuracy of perceptron with gradient decent is %f'%(acc_gd_dev)
	print 'The accuracy of svm is %f, best c is %f'%(acc_svm_dev,list_c[index_c])

	print '-----------------------test data--------------------------'
	print "baseline of test data:",max(accuracy(np.ones(y_test.shape[0]),y_test)[1],1-accuracy(np.ones(y_test.shape[0]),y_test)[1])
	print 'The accuracy of raw perceptron is ',acc_ori_test
	print 'The accuracy of perceptron with gradient decent is %f'%(acc_gd_test)
	print 'The accuracy of svm is %f, best c is %f'%(acc_svm_test,list_c[index_c])