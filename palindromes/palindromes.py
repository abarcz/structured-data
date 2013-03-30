#!/usr/bin/python

from string import letters
import random
import argparse

"""
Generating positive and negative samples for palindromes classification
"""

class PalindromeBuilder():
	"""
	Builds lowercase palindromes of given length
	"""
	def __init__(self, length):
		self.length = length
		self.generated_chars_num = self.length / 2
		self.duplicated_chars_num = self.length / 2
		if self.odd_length():
			self.generated_chars_num = self.generated_chars_num + 1

	def odd_length(self):
		return self.length % 2 == 1

	def create_one(self):
		palindrome = ""
		for i in range(self.generated_chars_num):
			palindrome = palindrome + random.choice(letters.lower())
		for i in reversed(range(self.duplicated_chars_num)):
			palindrome = palindrome + palindrome[i]
		return palindrome

	def create(self, number):
		palindromes = []
		for i in range(number):
			string = self.create_one()
			palindromes.append(string)
		for p in palindromes:
			print p

	def is_palindrome(self, string):
		for i in range(self.duplicated_chars_num):
			j = self.length - i - 1
			if string[i] != string[j]:
				return False
		return True

	def create_random_string(self):
		string = ""
		for i in range(self.length):
			string = string + random.choice(letters.lower())
		return string
			
	def create_random_strings(self, number):
		strings = []
		while len(strings) < number:
			string = self.create_random_string()
			if not self.is_palindrome(string):
				strings.append(string)
		for p in strings:
			print p

parser = argparse.ArgumentParser(description='')
parser.add_argument("-l", "--length", help="length of a palindrome", type=int)
parser.add_argument("-n", "--number", help="number of palindromes", type=int)
parser.add_argument("-r", "--random", help="generate random strings and assure \
	they are not palindromes", action="store_true", default=False)

args = parser.parse_args()
builder = PalindromeBuilder(args.length)

if args.random:
	builder.create_random_strings(args.number)
else:
	builder.create(args.number)
