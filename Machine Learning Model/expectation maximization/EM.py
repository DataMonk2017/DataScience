#!usr/bin/python2.7 python 
# -*- coding:utf-8 -*-
#@author: Jianyuan Zheng
import numpy as np
import sys
import random

def EM_tied(arr,K,N,miu,sigma,lamb,error=1*10**(-1)):	
	theta=np.zeros((N,K))
	likehood=0
	iteration=0
	like_list=[]
	while True:
		likehood_old=likehood
		likehood=0
		iteration+=1
	################E-step##############################
		for n in range(N):
			total=0
			for k in range(K):
				if np.linalg.det(sigma[k])==0:
					break
				de=lamb[0,k]*1/((2*np.pi)**(1/dm)*np.linalg.det(sigma[k])**0.5)
				no=np.exp(-0.5*np.dot((arr[n,:]-miu[k]).T,np.dot(np.linalg.inv(sigma[k]),(arr[n,:]-miu[k]))))
				theta[n,k]=np.divide(no,de)
				total=total+theta[n,k]
			theta[n,:]=np.divide(theta[n,:],total+np.spacing(1))
			likehood=likehood+np.log(total+np.spacing(1))			
			if likehood<=-10**(10):
				break
		#print(likehood)
		#print(likehood_old)
		like_list.append(-likehood)
		if np.absolute(likehood-likehood_old)<=error:
			break
		#print(theta[n,k])
	################M-step########################
		sigma_temp=sigma[0]
		for k in range(K):
			Nk=np.sum(theta,axis=0) #Nk is sum(P(Z=k|X^n))
			lamb[0,k]=Nk[k]/N	#update lambda
			for n in range(N):
				miu[k]=miu[k]+theta[n,k]*arr[n,:]
			#print(miu[k])
			#print(Nk[k])

			miu[k]=np.divide(miu[k],Nk[k]) # update miu
			
			#tied covariance matrice should be used for the mixture of guassian for each data point in the iterative update
			for n in range(N):
				temp=np.asmatrix(arr[n,:]-miu[k])
				sigma_temp=sigma_temp+theta[n,k]*(temp.T).dot(temp)
			sigma_temp=np.divide(sigma_temp,Nk[k])	#update sigma
		for k in range(K):
			sigma[k]=sigma_temp
			#print(lamb,miu,sigma)
		
		print('iteration',iteration,'\tlikehood:',-likehood)
	return iteration,like_list,miu,sigma,lamb

def EM_seperate(arr,K,N,miu,sigma,lamb,error=1*10**(-1)):
	theta=np.zeros((N,K))
	likehood=0
	iteration=0
	like_list=[]
	while True:
		likehood_old=likehood
		likehood=0
		iteration+=1
	################E-step##############################
		for n in range(N):
			total=0
			for k in range(K):
				if np.linalg.det(sigma[k])==0:
					break
				de=lamb[0,k]*1/((2*np.pi)**(1/dm)*np.linalg.det(sigma[k])**0.5)
				no=np.exp(-0.5*np.dot((arr[n,:]-miu[k]).T,np.dot(np.linalg.inv(sigma[k]),(arr[n,:]-miu[k]))))
				theta[n,k]=np.divide(no,de)
				total=total+theta[n,k]
			theta[n,:]=np.divide(theta[n,:],total+np.spacing(1))
			likehood=likehood+np.log(total+np.spacing(1))			
			if likehood<=-10**(10):
				break
		#print(likehood)
		#print(likehood_old)
		like_list.append(-likehood)
		if np.absolute(likehood-likehood_old)<=error:
			break
		#print(theta[n,k])
	################M-step########################
		
		for k in range(K):
			Nk=np.sum(theta,axis=0) #Nk is sum(P(Z=k|X^n))
			lamb[0,k]=Nk[k]/N
			for n in range(N):
				miu[k]=miu[k]+theta[n,k]*arr[n,:]
			#print(miu[k])
			#print(Nk[k])

			miu[k]=np.divide(miu[k],Nk[k])
		
			for n in range(N):
				temp=np.asmatrix(arr[n,:]-miu[k])
				sigma[k]=sigma[k]+theta[n,k]*(temp.T).dot(temp)
			sigma[k]=np.divide(sigma[k],Nk[k])	
			#print(lamb,miu,sigma)
		print('iteration',iteration,'\tlikehood:',-likehood)
	return iteration,like_list,miu,sigma,lamb
	

###############data preprocess######################
arr1=[]
arr2=[]
with open(sys.argv[1],'r') as f:
	for lines in f:
		line=lines.split()
		arr1.append(line[0])
		arr2.append(line[1])
		
arr1=np.array(arr1,ndmin=2).T
arr2=np.array(arr2,ndmin=2).T
array=np.concatenate((arr1,arr2),axis=1).astype(float)


K=int(sys.argv[3]) #number of hidden variables
dm=2 # 2-dimensional

###################################################
################train data#######################
###################################################
#train data
#choose first 100 examples as dev in orde to compare results conveniently
#rest of them are train
arr=array[100:,:]
N=len(arr) #length

################initialize##########################
miu=[]
sigma=[]
for k in range(K):
	#np.divide(np.sum(arr,axis=0),N)
	x1=random.uniform(min(arr[:,0]), max(arr[:,0]))
	x2=random.uniform(min(arr[:,1]), max(arr[:,1]))
	miu.append([x1,x2])
	sigma.append(np.identity(2))
miu=np.asarray(miu)
sigma=np.asarray(sigma)
lamb=np.ones((1,K))/float(K)


#(arr,K,N,miu,sigma,lamb,theta)
print('train set')
if sys.argv[2]=='tied':#tied covariance
	iteration,like_list,miu,sigma,lamb=EM_tied(arr,K,N,miu,sigma,lamb,0.1)
			
elif sys.argv[2]=='seperate':#separate covariance matrices
	iteration,like_list,miu,sigma,lamb=EM_seperate(arr,K,N,miu,sigma,lamb,0.5)
'''
import matplotlib.pyplot as plt
fig = plt.figure(1)
t = np.arange(0,iteration, 1)
plt.xlabel("Iteration Count")
plt.ylabel("Log Likelihood")
plt.plot(t, like_list, 'ro')
plt.title("Train Set, Num of Mix Gauss : %d, Covar Matrix: %s"%(K,sys.argv[2]))
plt.show()	
'''	
###################################################
################dev data#######################
###################################################
#dev data
#choose first 100 examples as dev in orde to compare results conveniently
arr=array[0:100,:]
N=len(arr) #length	
print('dev set')
if sys.argv[2]=='tied':#tied covariance
	iteration,like_list,_,_,_=EM_tied(arr,K,N,miu,sigma,lamb,0.1)
			
elif sys.argv[2]=='seperate':#separate covariance matrices
	iteration,like_list,_,_,_=EM_seperate(arr,K,N,miu,sigma,lamb,0.5)

import matplotlib.pyplot as plt
fig2 = plt.figure(2)
t2 = np.arange(0,iteration, 1)
'''
plt.xlabel("Iteration Count")
plt.ylabel("Log Likelihood")
plt.plot(t2, like_list, 'ro')
plt.title("Dev Set, Num of Mix Gauss : %d, Covar Matrix: %s"%(K,sys.argv[2]))
plt.show()
#Train_seperate_5.png
#Dev_seperate_5.png
#Train_tied_5.png
#Dev_tied_5.png
'''