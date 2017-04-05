#!/usr/bin/python
import os

for name in os.listdir("."):
	os.rename(name, name.lower())
