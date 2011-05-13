#!/usr/bin/python
# -*- coding: utf-8 -*-

import psycopg2
import locale
import time
import Utils

encoding = "UTF-8"

conn = psycopg2.connect("dbname=dns_monitor host=127.0.0.1 user=dns_monitor password=nono")
cursor = conn.cursor()

query = "select * from crosstab('select start, type, count from qtype order by 1,2') as qtype(start timestamp, A bigint, AAAA bigint, AXFR bigint, CNAME bigint, DLV bigint, DNSKEY bigint, MX bigint, NAPTR bigint, NS bigint, PTR bigint, PX bigint, SOA bigint, SPF bigint, SRV bigint, TXT bigint);"


cursor.execute(query)
while cursor.rownumber < cursor.rowcount:
    t=cursor.fetchone()
    line = str(cursor.rownumber+1) + ' '
    for  val in enumerate(list(t)):
      line += ('0' if val[1] is None else str(val[1])) + ' '
    print line

conn.close()
