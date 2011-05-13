#!/usr/bin/python
# -*- coding: utf-8 -*-

from simpletal import simpleTAL, simpleTALES, simpleTALUtils
import psycopg2
import locale
import time
import Utils
import sys
from string import Formatter
import ConfigParser
if (len(sys.argv) < 2):
  sys.exit("Error using %s\n  Report type must be given as first variable (eg. top100)"% sys.argv[0])

data=None
config = ConfigParser.ConfigParser()
config.read('reports.cfg')
for opt in config.items(sys.argv[1]):
  exec (opt[0] + "=" + opt[1])

encoding = "UTF-8"
sniffer = "sutda"


conn = psycopg2.connect("dbname=dns_monitor host=127.0.0.1 user=dns_monitor password=nono")
cursor = conn.cursor()

html_page = open(template)
template = simpleTAL.compileXMLTemplate(html_page)
context = simpleTALES.Context()

# TODO: ignored, decimal numbers are formatted with a dot :-(
locale.setlocale(locale.LC_NUMERIC, "hu_HU.%s" % encoding)
# But month names are OK
locale.setlocale(locale.LC_TIME, "hu_HU.%s" % encoding)

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
context.addGlobal (contexname, result)

now = time.localtime(time.time())
now_str = time.strftime("%Y %B %d. %H:%M", now)
context.addGlobal("now", unicode(now_str, encoding))

rendered = simpleTALUtils.FastStringOutput()
template.expand (context, rendered, outputEncoding=encoding)
outputf = open(output, 'w')
outputf.write(rendered.getvalue())
outputf.write("\n")
outputf.close()

conn.close()
