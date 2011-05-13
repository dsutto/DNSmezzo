DROP TABLE IF EXISTS DNS_types;
DROP TABLE IF EXISTS DNS_Packets;
DROP TABLE IF EXISTS PCAP_files;
DROP TYPE IF EXISTS protocols;

CREATE TYPE protocols AS ENUM ('TCP', 'UDP');

CREATE TABLE Pcap_files(id SERIAL UNIQUE NOT NULL, 
       added TIMESTAMP NOT NULL DEFAULT now(), 
       hostname TEXT,
       filename TEXT UNIQUE NOT NULL, datalinktype TEXT, snaplength INTEGER, 
       filesize INTEGER, filedate TIMESTAMP,
       firstpacket TIMESTAMP, lastpacket TIMESTAMP,
       samplingrate FLOAT CHECK (samplingrate <= 1.0 AND samplingrate >= 0.0),
       stoppedat INTEGER, -- If we used the -m option, use that to indicate that
       -- we "truncated" the input file
       totalpackets INTEGER, storedpackets INTEGER);	

CREATE TABLE DNS_Packets (id SERIAL UNIQUE NOT NULL, 
       file INTEGER NOT NULL REFERENCES Pcap_files(id),
       rank INTEGER NOT NULL, -- Rank of the packet in the file
       date TIMESTAMP, -- Date of capture in UTC
       length INTEGER NOT NULL, -- Length on the cable, we may have stored 
                                -- less bytes
       added TIMESTAMP NOT NULL DEFAULT now(),
       src_address INET NOT NULL,
       dst_address INET  NOT NULL,
       protocol protocols  NOT NULL,     
       src_port INTEGER  NOT NULL,
       dst_port INTEGER  NOT NULL,
       -- Field names and semantic are found in RFC 1034 and 1035. We do not 
       -- try to be user-friendly
       query BOOLEAN   NOT NULL,
       query_id INTEGER   NOT NULL,
       opcode INTEGER   NOT NULL,
       rcode INTEGER  NOT NULL, 
       aa BOOLEAN  NOT NULL,
       tc BOOLEAN  NOT NULL,
       rd BOOLEAN  NOT NULL,
       ra BOOLEAN  NOT NULL,
       qclass INTEGER, -- NULL are allowed because this field was not always in the schema
       qname TEXT  NOT NULL, -- The raw version of the QNAME, without any processing (not even lowercasing)
       qtype INTEGER  NOT NULL, -- With helper functions TODO to translate numeric values to well-known text like AAAA, MX, etc
       edns0_size INTEGER, -- NULL if no EDNS0
       do_dnssec BOOLEAN, -- NULL if no EDNS0
       ancount INTEGER  NOT NULL,
       nscount INTEGER  NOT NULL,
       arcount INTEGER  NOT NULL,
       -- All the columns above are directly obtained from the
       -- packet. They are sufficient for all the
       -- processings. However, both for performance reasons and for
       -- easying the task of the developers, some (optional) columns
       -- are computed at store-time. They are obtained only from the
       -- values above. So, the table, up to this line, is in first
       -- normal form, but it is not if you include the columns here:
       registered_domain TEXT, -- The part of the QNAME that was
			       -- registered such as example.fr for a
			       -- QNAME of www.example.fr or
			       -- durand.nom.fr for a QNAME of
			       -- mail.durand.nom.fr.
       lowercase_qname TEXT
       );

CREATE TABLE DNS_types (id SERIAL UNIQUE NOT NULL,
       type TEXT UNIQUE NOT NULL,
       value INTEGER UNIQUE NOT NULL,
       meaning TEXT,
       rfcreferences TEXT);

-- Examples of requests: 
--
-- 1) to find the NXDOMAIN (rcode 3) responses:
-- SELECT DISTINCT substr(qname, 1, 40) AS domain,count(qname) AS num FROM DNS_packets WHERE NOT query AND rcode= 3 GROUP BY qname ORDER BY count(qname) DESC;
--
-- 2) to find the most talkative IPv6 clients
-- SELECT src_address,count(src_address) AS requests FROM DNS_packets WHERE family(src_address)=6 AND query GROUP BY src_address ORDER BY requests DESC;
--
-- 3) to find the typical EDNS0 sizes advertised by clients
-- SELECT edns0_size, count(edns0_size) AS occurrences FROM DNS_packets WHERE query GROUP BY edns0_size ORDER BY occurrences DESC;
