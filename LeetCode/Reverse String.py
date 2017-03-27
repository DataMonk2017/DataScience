#Write a function that takes a string as input and returns the string reversed.

#Example:
#Given s = "hello", return "olleh".

class Solution(object):
    def reverseString(self, s):
        """
        :type s: str
        :rtype: str
        """
        #dynamic programming
        def fun1(s):
            if len(s) == 0:
                return ''
            else:
                return s[-1]+fun1(s[:-1])
        return fun1(s)   
        
        #pythonic way
        return ''.join([s[-(i+1)] for i in range(len(s))])
        #second way: Extened Slices
        return s[::-1]
