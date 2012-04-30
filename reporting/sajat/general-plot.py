#!/usr/bin/python
# -*- coding: utf-8 -*-

import psycopg2
import locale
import time
import sys
import Utils
import getopt
import datetime
import ConfigParser
import subprocess


def usage():
  print 'Usage:'
  print '  %s [--date=DATE] report_type '%sys.argv[0]
  print '  %s [--from=DATE --to=DATE2] report_type \n'%sys.argv[0]
  print '    Where report_type refers to a report definition in reports.cfg (eg. top100)'
  print '    DATE and DATE2 have the format YYYY/MM/DD and DATE < DATE2'

# Parse arguments
try:
   opts, args = getopt.gnu_getopt(sys.argv[1:], "h", ["help", "date=", "from=", "to="])
except getopt.GetoptError:
   print 'Error parsing arguments'
   usage()
   sys.exit(2)

oneday = False
interval = False
for opt, arg in opts:
   if opt == '-h':
      usage()
      sys.exit()
   elif opt == "--date":
      oneday = True
      date = datetime.datetime.strptime(arg, "%Y/%m/%d").date()
   elif opt == "--from":
      interval = True
      date_from = datetime.datetime.strptime(arg, "%Y/%m/%d").date()
   elif opt == "--to":
      interval = True
      date_to = datetime.datetime.strptime(arg, "%Y/%m/%d").date()

if(len(args) != 1): # No report type was given
  print 'No report type was given'
  usage()
  exit(2)

try:
  if (interval and (date_from == None or date_to == None)):
    print 'Both date (from and to) must be specified.'
    usage()
    exit(2)
except NameError:
    print 'Both date (from and to) must be specified.'
    usage()
    exit(2)

report_type = args[0]

data={}
config = ConfigParser.SafeConfigParser()
config.read(['reports.cfg', 'din_images.cfg'])
for opt in config.items(report_type):
  exec (opt[0] + "=" + opt[1])

encoding = "UTF-8"
dns_packets_tablename = "dns_packets"
qtypes_tablename = "qtypes"

conn = psycopg2.connect("dbname=dns_monitor host=127.0.0.1 user=dns_monitor password=nono")
cursor = conn.cursor()
#cursor.execute("set search_path='nic1';")

if (oneday):
  try:
    newtablename = "dns_packets_" + date.strftime("%Y%m%d")
    prequery = "CREATE TABLE " + newtablename + " AS SELECT * FROM " + dns_packets_tablename + " WHERE date_trunc('day', date) = %(date)s"
    cursor.execute(prequery, {'date': date.isoformat()})
    conn.commit()
    with open("temptables", "a") as f:
        f.write(newtablename + "\n")
  except psycopg2.ProgrammingError, e:
    if (e.pgcode == '42P07'):
      conn.rollback()
    else:
      exit(e)

dns_packets_tablename = newtablename
data['dns_packets_tablename'] = dns_packets_tablename
data['percent_sign'] ='%'
query = query %data

f = open(report_type + '.dat', 'w')

cursor.execute(query)
while cursor.rownumber < cursor.rowcount:
    t=list(cursor.fetchone())
    line = str(cursor.rownumber+1) + ' '
    for  val in enumerate(t):
      line += ('0' if val[1] is None else str(val[1])) + ' '
    f.write(line + '\n')

conn.close()
f.close()

syscall=''
if type == 'time_hist':
  syscall = ['./time_hist.gp.sh',  "-d",  report_type + ".dat", "-o", report_type + ".png", "-t", pagetitle, "-f", " ".join(values), "-x", xlabel, "-y", ylabel]
if type == 'data_hist':
  syscall = ['./data_hist.gp.sh',  "-d",  report_type + ".dat", "-o", report_type + ".png", "-t", pagetitle, "-f", " ".join(values), "-x", xlabel, "-y", ylabel]
if type == 'qtypes_png':
  syscall = "./qtypes_png.gp.sh"
if type == 'ipv6_png':
  syscall = "./ipv6_png.gp.sh"
if type == 'kaminsky_png':
  syscall = "./kaminsky_png.gp.sh"

print syscall
if syscall == '':
	exit("Can't create plot. Don't know which command to use. Bad type: " + type)

subprocess.call(syscall)

