# -*- coding: utf-8 -*-
"""
Created on Tue Apr  3 11:33:32 2018

@author: jianyuan
"""
#不需要numpy 模组的代码
#https://github.com/hanbt/learn_dl/blob/master/perceptron.py
#以下是需要numpy模组的代码

import numpy as np

iteration = 70
class Perceptron:
    def __init__(self, input_num, activator):
        #权重和偏置初始化
        self.activator = activator
        self.weights = np.ones((input_num,1))
        self.bias = 0.0
    
    def __str__(self):
        #打印初始值
        return 'weights\t:%s\nbias\t:%f\n' % (self.weights, self.bias)

    def predict(self, input_vec):
        '''
        预测数据
        '''
        #print(np.dot(input_vec,self.weights))
        return self.activator(np.dot(input_vec,self.weights)+self.bias)
    
    def train(self, input_vec, label, iteration, rate):
        '''
        训练数据
        梯度下降法
        '''
        for i in range(iteration):
            predcited_val = self.predict(input_vec)
            
            delta = label - predcited_val
            #print(delta)
            #print(rate)
            #print(input_vec)
            #向量化实现
            #weight_change = alpha*X.T*Delta
            #bias_change = alpha*np.sum(delta)
            self.weights += rate*input_vec.T*delta
            self.bias += rate*np.sum(delta)
            
def f(x):
    '''
    定义激活函数f
    '''
    return np.sign(x)
def get_training_dataset():
    '''
    基于and真值表构建训练数据
    '''
    # 构建训练数据
    # 输入向量列表
    input_vec = np.array([[1,1], [0,0], [1,0], [0,1]])
    # 期望的输出列表，注意要与输入一一对应
    # [1,1] -> 1, [0,0] -> 0, [1,0] -> 0, [0,1] -> 0
    label = np.matrix([1, -1, -1, -1]).T
    return input_vec, label
    
def train_and_perceptron():
    '''
    使用and真值表训练感知器
    '''
    # 创建感知器，输入参数个数为2（因为and是二元函数），激活函数为f
    p = Perceptron(2, f)
    # 训练，迭代10轮, 学习速率为0.1
    input_vecs, labels = get_training_dataset()
    p.train(input_vecs, labels, 10, 0.1)
    #返回训练好的感知器
    return p
if __name__ == '__main__': 
    # 训练and感知器
    and_perception = train_and_perceptron()
    # 打印训练获得的权重
    print(and_perception)
    # 测试
    print('1 and 1 = %d' % and_perception.predict([1, 1]))
    print('0 and 0 = %d' % and_perception.predict([0, 0]))
    print('1 and 0 = %d' % and_perception.predict([1, 0]))
    print('0 and 1 = %d' % and_perception.predict([0, 1]))      
        
        