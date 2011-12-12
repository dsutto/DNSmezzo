#!/usr/bin/python
# -*- coding: utf-8 -*-

from simpletal import simpleTAL, simpleTALES, simpleTALUtils
import psycopg2
import locale
import time
import Utils
import sys
import getopt
import datetime
from string import Formatter
import ConfigParser

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
config.read('reports.cfg')
for opt in config.items(report_type):
  exec (opt[0] + "=" + opt[1])


encoding = "UTF-8"
sniffer = "sutda"
dns_packets_tablename = "dns_packets"
qtypes_tablename = "qtypes"


conn = psycopg2.connect("dbname=dns_monitor host=127.0.0.1 user=dns_monitor password=nono")
cursor = conn.cursor()
#cursor.execute("set search_path='nic1';")

html_page = open(template)
template = simpleTAL.compileXMLTemplate(html_page)
context = simpleTALES.Context()

# TODO: ignored, decimal numbers are formatted with a dot :-(
locale.setlocale(locale.LC_NUMERIC, "hu_HU.%s" % encoding)
# But month names are OK
locale.setlocale(locale.LC_TIME, "hu_HU.%s" % encoding)

if (oneday):
  try:
    interval = date.strftime("%Y. %B %d. (%A)")
    context.addGlobal("interval", unicode(interval, encoding))

    newtablename = "dns_packets_" + date.strftime("%Y%m%d")
    prequery = "CREATE TABLE " + newtablename + " AS SELECT * FROM " + dns_packets_tablename + " WHERE date_trunc('day', date) = %(date)s"
    # print prequery %{'date': date.isoformat()}
    cursor.execute(prequery, {'date': date.isoformat()})
    conn.commit()


  except psycopg2.ProgrammingError, e:
    if (e.pgcode == '42P07'):
      conn.rollback()
    else:
      exit(e)

dns_packets_tablename = newtablename
query = query %{'dns_packets_tablename': dns_packets_tablename}

# print query
# print data
cursor.execute(query, data)
result = []
for t in cursor.fetchall():
    d = {}
    for i in range(len(t)):
      try:
        d[keys[i]] = unicode( str(t[i]) if prep[i] == None else str(prep[i](t[i])), "latin-1")
      except NameError:
        d[keys[i]] = unicode( str(t[i]), "latin-1")
      i+=1
    result.append(d)
context.addGlobal (contextname, result)

now = time.localtime(time.time())
now_str = time.strftime("%Y. %B %d. %H:%M", now)
context.addGlobal("now", unicode(now_str, encoding))

rendered = simpleTALUtils.FastStringOutput()
template.expand (context, rendered, outputEncoding=encoding)
outputf = open(output, 'w')
outputf.write(rendered.getvalue())
outputf.write("\n")
outputf.close()

conn.close()
