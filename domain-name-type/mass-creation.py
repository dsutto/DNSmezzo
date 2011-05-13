#!/usr/bin/python

import random
import psycopg2

MAX=10000
maxsize=12
tmp_file = "mass-creation.tmp"

ld = []
ldh = []
# Letters
for i in range (97, 122):
    ld.append (chr(i))
# Digits
for i in range (48, 57):
    ld.append (chr(i))
ldh = ld[:]
# Hyphen
ldh.append ('-')

def gen_random_label(gen):
    label = gen.choice(ld)
    for i in range(gen.randint(1, maxsize)):
        label = label + gen.choice(ldh)
    return label

generator = random.Random()
output = open(tmp_file, 'w')
for i in range(0, MAX):
    name = gen_random_label(generator)
    sld = gen_random_label(generator)
    tld = gen_random_label(generator)
    output.write("%s.%s.%s\n" % (name, sld, tld))
output.close()                
input = open(tmp_file, 'r')
conn = psycopg2.connect("dbname=essais")
cursor = conn.cursor()
cursor.execute("BEGIN;")
cursor.copy_from(input, "Registry", columns=['fqdn'])
cursor.execute("COMMIT;")
conn.close()
