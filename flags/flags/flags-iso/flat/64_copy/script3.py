#!/usr/bin/python

import csv
import os
with open('code.csv', 'rb') as csvfile:
	reader = csv.reader(csvfile, delimiter=',')
	for row in reader:
		alpha2 = row[1]
		alpha3 = row[0]
		fname =  alpha2 + ".png"
		rname =  alpha3 + ".png"
		if(os.path.isfile(fname)):
			print fname
			os.rename(fname, rname);
