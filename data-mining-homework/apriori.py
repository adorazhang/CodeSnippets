#coding: UTF8
import sys
from copy import copy

def generate_candidate(F,k):
    candidate = []
    for f1 in F: 
        for f2 in F: 
            if f1[k-2] < f2[k-2]:
                c = copy(f1)
                c.append(f2[k-2])
                if c not in candidate:
                    candidate.append(c)
    return candidate
    
def counttimes(li):
    count = 0
    dontcount = False
    for line in alldata:
        for item in li:
            if item not in line:
                dontcount = True
                break
        if dontcount:
            dontcount = False
        else:   
            count += 1
    return count

def apriori():
    
    l = [[]] #l[k] == frequent-k-itemsets
    for item in dic:
        if dic[item] >= mincount:
            l[0].append([item])
    l[0].sort()
    candidate = copy(l[0])
    
    #now we get the frequent-1-itemsets
    k = 1
    while l[k-1] != []:
        candidate = generate_candidate(l[k-1],k+1)
        l.append([])
        for c in candidate:
            if counttimes(c) >= mincount:
                #print c, counttimes(c)
                l[k].append(c)
        k += 1
            
    ans = []
    
    for each_k_itemsets in l:
        for i in each_k_itemsets:
            ans.append(i)

    return ans


### Main Function ###
filename = raw_input("Please enter your data file:")
data = open(filename)
minsup = float(raw_input("Please enter the min support:"))

#data = open("plants.data")
#minsup = 0.3

alldata = list()
for eachline in data:
    x = eachline.strip().split(",")
    alldata.append(x[1:])

dic = dict()
for line in alldata:
    for item in line:
        if item in dic:
            dic[item] += 1
        else:
            dic[item] = 1

mincount = minsup*len(alldata)
ans = apriori()
print len(ans),"Frequent Intemsets are found:"
for i in ans:
    print i
