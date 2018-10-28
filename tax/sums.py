#!/usr/bin/python

import sys

def main():
  if len(sys.argv) != 2:
    print("Usage:\n  sums.py FILENAME")
    return

  filename = sys.argv[1]
  file = open(filename, 'r')

  # Gross and Net
  gross = 0
  net = 0
  for line in file:
    tokens = line.split()
    if len(tokens) > 0 and tokens[0].startswith('201'):
      gross += float(tokens[1])
      net += float(tokens[2]) if (len(tokens) > 2) else 0

  print("Gross: ", str(gross), "Net", str(net), "Tax", str(gross-net))

if __name__ == '__main__':
  main()
