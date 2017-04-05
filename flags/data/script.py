#!/usr/bin/python

import csv
import os
with open('countries_raw.csv', 'rb') as csvfile:
	reader = csv.reader(csvfile, delimiter=',')
	for row in reader:
		print row[2] 
