#!/usr/bin/python
# -*- coding: utf-8 -*-

from simpletal import simpleTAL, simpleTALES, simpleTALUtils
from string import Formatter
import psycopg2
import locale
import time
import Utils

encoding = "UTF-8"
sniffer = "sutda"

conn = psycopg2.connect("dbname=dns_monitor host=127.0.0.1 user=dns_monitor password=nono")
cursor = conn.cursor()

html_page = open("qtypes.tmpl.xhtml")
template = simpleTAL.compileXMLTemplate(html_page)
context = simpleTALES.Context()

# TODO: ignored, decimal numbers are formatted with a dot :-(
locale.setlocale(locale.LC_NUMERIC, "hu_HU.%s" % encoding)
# But month names are OK
locale.setlocale(locale.LC_TIME, "hu_HU.%s" % encoding)

cursor.execute("select type, meaning, count(*) from dns_packets,dns_types where qtype=value group by 1, 2 order by 1 asc;")
qtypes_results = []
for tuple in cursor.fetchall():
    qtypes_results.append({'type': tuple[0], 'meaning': tuple[1], 
                           'count': tuple[2], 'perc': '{0:.2%}.'.format(float(tuple[2]))})

now = time.localtime(time.time())
now_str = time.strftime("%Y %B %d. %H:%M", now)
context.addGlobal("now", unicode(now_str, encoding))

context.addGlobal("qtypes", qtypes_results)

rendered = simpleTALUtils.FastStringOutput()
template.expand (context, rendered, outputEncoding=encoding)
output = open("qtypes.html", 'w')
output.write(rendered.getvalue())
output.write("\n")
output.close()

conn.close()
