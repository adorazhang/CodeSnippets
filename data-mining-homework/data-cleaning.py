# coding=utf-8
import sys
import string

# print data file
def printfile(filename):
	txt = open(filename)
	print txt.read()
	txt.close()

# print menu
def init():
	print "\n################################################################################\n"
	print "Data Cleaning"
	print "Author: Qiao Zhang (adora@yahoo.cn)"
	print "Input file: test.txt"
	print "Every line is a vector consists of positive numbers, -1 for absent values"
	print "1. Clean all invalid vectors"
	print "2. Replace invalid values with user defined value"
	print "3. Replace invalid values with a pre-defined constant value"
	print "4. Replace invalid values with the average of that column"
	print "5. Replace invalid values with the average of two nearest values"
	print "6. Exit"
	print "\n################################################################################\n"

# Main Proccess
def process(opt):
	if (opt == 1):
		delete_invalid()
	elif (opt == 2):
		user_define()
	elif (opt == 3):
		unknown_constant()
	elif (opt == 4):
		use_average()
	elif (opt == 5):
		nearest_two()
	else:
		print "Exiting...\n"
		exit()

# Clean all invalid vectors
def delete_invalid():
	rawfile = open("test.txt",'r')
	result = open("result.txt",'w')
	for line in rawfile:
		if "-1" in line:
			continue
		else:
			result.write(line)
	result.close()
	rawfile.close()

# Replace invalid values with user defined invalid values
def user_define():
	rawfile = open("test.txt",'r')
	result = open("result.txt",'w')
	for line in rawfile:
		if "-1" in line:
			count = line.count("-1")
			for i in range(1,count+1):
				print "\nAn invalid value found in line ",line,":"
				print "Enter the value of the %dth value:" %i
				x = raw_input()
				line = line.replace("-1",x,1)
			result.write(line)
		else:
			result.write(line)
	result.close()
	rawfile.close()

# Replace invalid values with a pre-defined constant number
def unknown_constant():
	rawfile = open("test.txt",'r')
	result = open("result.txt",'w')
	print "\nEnter a pre-defined value for replacement"
	unknown = raw_input()
	for line in rawfile:
		line = line.replace("-1",unknown)
		result.write(line)
	result.close()
	rawfile.close()
	
# Compute the average of that column
def avg(x , row_num , tj):
	sum = 0	
	count = 0
	for i in range(row_num):
		if x[i][tj] != '-1':
			count = count + 1
			sum = sum + float(x[i][tj])
	avg = sum/count
	return '%1.1f' %avg

# Replace invalid values with the average of that column
def use_average():	
	rawfile = open("test.txt",'r')
	result = open("result.txt",'w')
	lines = rawfile.readlines()
	# getting data matrix x
	x = list()
	for line in lines:
		row = line.strip().split()
		x.append(row)
	col_num = len(row)
	row_num = len(lines)
	for i in range(col_num): # iterating every column
		for j in range(row_num):
			if x[j][i] == '-1':
				x[j][i] = avg(x , row_num , i) # compute the average
	for i in range(row_num): # Write data to result.txt
		for j in range(col_num):
			result.write(x[i][j])
			result.write(' ')
		result.write('\n')
	result.close()
	rawfile.close()

# Computing column average
def nearest(x , row_num , ti , tj):
	upper = 0 # nearest previous value
	lower = 0 # nearest following value
	# in stead of using index+1 / index-1, find the nearest valuess in case of absent values

	for i in range(ti,0,-1): # find the nearst previous value from bottom-up
		print i
		if x[i][tj] != '-1':
			upper = float(x[i][tj])
			break
			
	for i in range(ti,row_num,1): # find the nearst following value from top-down
		if x[i][tj] != '-1':
			lower = float(x[i][tj])
			break

	if (upper != 0 and lower != 0):
		ans = (upper+lower)/2
	elif (upper == 0 and lower != 0):
		ans = lower
	elif (upper !=0 and lower == 0):
		ans = upper
	else:
		print "There is no usable data, please use another method."

	return '%1.1f' %ans

# Replace invalid values with the most likely value
def nearest_two():
	rawfile = open("test.txt",'r')
	result = open("result.txt",'w')
	lines = rawfile.readlines()
	x = list()
	for line in lines:
		row = line.strip().split()
		x.append(row)
	col_num = len(row)
	row_num = len(lines)
	for i in range(col_num):
		for j in range(row_num):
			if x[j][i] == '-1':
				x[j][i] = nearest(x , row_num , j , i)
	for i in range(row_num):
		for j in range(col_num):
			result.write(x[i][j])
			result.write(' ')
		result.write('\n')
	result.close()
	rawfile.close()

# Main Funtion
while True:
	init()
	print "Enter your option:"
	opt=input()
	if opt not in range(1,6):
		break
	else:
		print "\n********************************************************************************\n"
		print "Raw data:"
		printfile("test.txt")
		process(opt)
		print "\n********************************************************************************\n"
		print "Data after processing:"
		printfile("result.txt")	
		print "********************************************************************************\n"
		print "Press Enter to Continue..."
		raw_input()
exit()
