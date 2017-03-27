class Solution(object):
    def fizzBuzz(self, n):
        """
        :type n: int
        :rtype: List[str]
        """
        L = []
        for i in range(1,n+1):
            if i%3 == 0 and i%5 ==0:
                L.append('FizzBuzz')
            elif i%3 == 0:
                L.append('Fizz')
            elif i%5 ==0:
                L.append('Buzz')
            else:
                L.append(str(i))
        return L
        #shorten way
        return ['FizzBuzz'[i%-3&-4:i%-5&8^12]or`i`for i in range(1,n+1)]
        #cleaner way
        return ['Fizz'*(not i%3)+'Buzz'*(not i%5) or str(i) for i in range(1,n+1)]
