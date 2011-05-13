#!/usr/bin/python
# -*- coding: utf-8 -*-

from simpletal import simpleTAL, simpleTALES, simpleTALUtils
import psycopg2
import locale
import time
import Utils

encoding = "UTF-8"
sniffer = "sutda"
limit = 100

conn = psycopg2.connect("dbname=dns_monitor host=127.0.0.1 user=dns_monitor password=nono")
cursor = conn.cursor()

html_page = open("top100.tmpl.xhtml")
template = simpleTAL.compileXMLTemplate(html_page)
context = simpleTALES.Context()

# TODO: ignored, decimal numbers are formatted with a dot :-(
locale.setlocale(locale.LC_NUMERIC, "hu_HU.%s" % encoding)
# But month names are OK
locale.setlocale(locale.LC_TIME, "hu_HU.%s" % encoding)

cursor.execute("SELECT DISTINCT registered_domain AS domain, count(registered_domain) AS num FROM DNS_packets WHERE query GROUP BY registered_domain ORDER BY num DESC LIMIT %(limit)s", 
                   {'limit': limit})
domains = []
for (domain, count) in cursor.fetchall():
    domains.append({'domain': unicode(domain, "latin-1"), 'count': count})
context.addGlobal ("domains", domains)

now = time.localtime(time.time())
now_str = time.strftime("%Y %B %d. %H:%M", now)
context.addGlobal("now", unicode(now_str, encoding))

rendered = simpleTALUtils.FastStringOutput()
template.expand (context, rendered, outputEncoding=encoding)
output = open("top100.html", 'w')
output.write(rendered.getvalue())
output.write("\n")
output.close()

conn.close()
