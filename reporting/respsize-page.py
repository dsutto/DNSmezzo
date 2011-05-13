#!/usr/bin/python
# -*- coding: utf-8 -*-

from simpletal import simpleTAL, simpleTALES, simpleTALUtils
import psycopg2
import locale
import time
import Utils

encoding = "UTF-8"
sniffer = "jezabel"

conn = psycopg2.connect("dbname=dnsmezzo2")
cursor = conn.cursor()

html_page = open("respsize.tmpl.xhtml")
template = simpleTAL.compileXMLTemplate(html_page)
context = simpleTALES.Context()

# TODO: ignored, decimal numbers are formatted with a dot :-(
locale.setlocale(locale.LC_NUMERIC, "fr_FR.%s" % encoding)
# But month names are OK
locale.setlocale(locale.LC_TIME, "fr_FR.%s" % encoding)

(last_sunday_id, last_tuesday_id, last_tuesday_date) = Utils.get_set_days(cursor, sniffer, 1).next()
cursor.execute("SELECT count(id) FROM DNS_packets WHERE query AND (file=%(sunday)s OR file=%(tuesday)s);", 
                   {'sunday': last_sunday_id, 'tuesday': last_tuesday_id})
total_queries = int(cursor.fetchone()[0])
cursor.execute("SELECT count(id) FROM DNS_packets WHERE query AND family(src_address)=6 AND (file=%(sunday)s OR file=%(tuesday)s);", 
               {'sunday': last_sunday_id, 'tuesday': last_tuesday_id})
context.addGlobal("respsize", "%2.1f" % ((float(cursor.fetchone()[0])*100)/total_queries))

now = time.localtime(time.time())
now_str = time.strftime("%d %B %Y à %H:%M", now)
context.addGlobal("now", unicode(now_str, encoding))

rendered = simpleTALUtils.FastStringOutput()
template.expand (context, rendered, outputEncoding=encoding)
output = open("respsize.html", 'w')
output.write(rendered.getvalue())
output.write("\n")
output.close()

conn.close()
