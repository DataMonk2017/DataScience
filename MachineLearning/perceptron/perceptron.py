#perceptron.py
import numpy as np

def perceptron(x,y,eta=1,max_iter=10000):
    #input x : tranning set, rows of data points.
    #y lable
    #eta : learning rate
    #max_iter: maximum iteration
    w = np.zeros((1,x.shape[1]))
    b = 0
      
    
    for i in range(max_iter):
        sample_worngly_classified = 0
        for j in range(x.shape[0]):
            if y[j]*(np.dot(w,x[j])+b) <= 0:
                w += eta*y[j]*x[j]
                b += eta*y[j]
                sample_worngly_classified += 1
        if sample_worngly_classified == 0:
            break
    return w,b
    

x = np.array([[3,3],[4,3],[1,1]])
y =np.array( [[1],[1],[-1]])

perceptron(x,y)
