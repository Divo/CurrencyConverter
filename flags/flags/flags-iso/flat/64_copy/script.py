#!/usr/bin/python

import csv
import os

codes = dict()
with open('country-codes.csv', 'rb') as csvfile:
	reader = csv.reader(csvfile, delimiter=',')
	for row in reader:
		country_code = row[3].lower()
		currency_code = row[14].lower()
		if currency_code and os.path.isfile(country_code +".png"):
			if(currency_code in codes):
				print country_code + " " + currency_code + " " + str(codes[currency_code])
				codes[currency_code] += 1
				os.rename(country_code + ".png", currency_code + str(codes[currency_code]) + ".png") 
			else:
				codes[currency_code] = 1
				os.rename(country_code + ".png", currency_code + ".png")

