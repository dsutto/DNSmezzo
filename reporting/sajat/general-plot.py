#!/usr/bin/python
# -*- coding: utf-8 -*-

import psycopg2
import locale
import time
import sys
import Utils
import ConfigParser
if (len(sys.argv) < 2):
  sys.exit("Error using %s\n  Report type must be given as first variable (eg. top100)"% sys.argv[0])

data=None
config = ConfigParser.ConfigParser()
config.read('reports.cfg')
for opt in config.items(sys.argv[1]):
  exec (opt[0] + "=" + opt[1])

encoding = "UTF-8"

conn = psycopg2.connect("dbname=dns_monitor host=127.0.0.1 user=dns_monitor password=nono")
cursor = conn.cursor()
cursor.execute("set search_path = nic1");
cursor.execute(query)
while cursor.rownumber < cursor.rowcount:
    t=cursor.fetchone()
    line = str(cursor.rownumber+1) + ' '
    for  val in enumerate(list(t)):
      line += ('0' if val[1] is None else str(val[1])) + ' '
    print line

conn.close()
