import sys
import random
alphabets = []
codes = (('a','z'),('A','Z'),('0','9'))

# create alphabet list
for r in codes:
    chars = map(chr, range(ord(r[0]),ord(r[1])+1))
    alphabets.extend(chars)

for upper in range(0,62):
    inputList = []
    for n in range(0,1000000):
        term = alphabets[random.randint(0,upper)]
        inputList.append(term+term)
    f = open("{u}.txt".format(u=upper), 'w')
    f.write("".join(inputList))
    f.close
