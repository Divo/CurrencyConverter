#!/usr/bin/python

import csv
import os
with open('code.csv', 'rb') as csvfile:
	reader = csv.reader(csvfile, delimiter=',')
	for row in reader:
		alpha2 = row[1].lower()
		alpha3 = row[0]
		fname =  alpha2 + ".png"
		rname =  alpha3 + ".png"
		print fname + " " + rname
		obj = open(fname, 'r')
		print obj.name
		obj.close()
		#os.rename(fname, rname);
