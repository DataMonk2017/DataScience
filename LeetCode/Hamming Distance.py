# -*- coding: utf-8 -*-
"""
Created on Tue Mar 21 21:55:22 2017

@author: Jeremy

The Hamming distance between two integers is the number of positions at which the corresponding bits are different.

Given two integers x and y, calculate the Hamming distance.

Note:
0 ≤ x, y < 2^31.
"""
# My Answer
class Solution(object):
    def hammingDistance(self, x, y):
        """
        :type x: int
        :type y: int
        :rtype: int
        """
        self.max_num = '{0:031b}'.format(x) 
        self.min_num = '{0:031b}'.format(y) 
        count = 0        
        for i in range(1,32):
            if self.max_num[-i] != self.min_num[-i]:
                count+=1
        return count
S = Solution()
S.hammingDistance(x=1,y=4)


#Answer from yuyuyu0915
class Solution(object):
    def hammingDistance(self, x, y):
        return bin(x^y).count('1')
