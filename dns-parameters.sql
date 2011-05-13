DELETE FROM DNS_types;
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('A', 1, 'a host address', '[RFC1035]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('NS', 2, 'an authoritative name server', '[RFC1035]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('MD', 3, 'a mail destination (Obsolete - use MX)', '[RFC1035]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('MF', 4, 'a mail forwarder (Obsolete - use MX)', '[RFC1035]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('CNAME', 5, 'the canonical name for an alias', '[RFC1035]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('SOA', 6, 'marks the start of a zone of authority', '[RFC1035]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('MB', 7, 'a mailbox domain name (EXPERIMENTAL)', '[RFC1035]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('MG', 8, 'a mail group member (EXPERIMENTAL)', '[RFC1035]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('MR', 9, 'a mail rename domain name (EXPERIMENTAL)', '[RFC1035]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('NULL', 10, 'a null RR (EXPERIMENTAL)', '[RFC1035]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('WKS', 11, 'a well known service description', '[RFC1035]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('PTR', 12, 'a domain name pointer', '[RFC1035]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('HINFO', 13, 'host information', '[RFC1035]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('MINFO', 14, 'mailbox or mail list information', '[RFC1035]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('MX', 15, 'mail exchange', '[RFC1035]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('TXT', 16, 'text strings', '[RFC1035]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('RP', 17, 'for Responsible Person', '[RFC1183]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('AFSDB', 18, 'for AFS Data Base location', '[RFC1183]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('ISDN', 20, 'for ISDN address', '[RFC1183]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('RT', 21, 'for Route Through', '[RFC1183]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('NSAP', 22, 'for NSAP address, NSAP style A record', '[RFC1706]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('SIG', 24, 'for security signature', '[RFC4034][RFC3755][RFC2535]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('KEY', 25, 'for security key', '[RFC4034][RFC3755][RFC2535]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('PX', 26, 'X.400 mail mapping information', '[RFC2163]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('GPOS', 27, 'Geographical Position', '[RFC1712]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('AAAA', 28, 'IP6 Address', '[RFC3596]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('LOC', 29, 'Location Information', '[RFC1876]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('NXT', 30, 'Next Domain - OBSOLETE', '[RFC3755][RFC2535]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('SRV', 33, 'Server Selection', '[RFC2782]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('NAPTR', 35, 'Naming Authority Pointer', '[RFC2915][RFC2168]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('KX', 36, 'Key Exchanger', '[RFC2230]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('CERT', 37, 'CERT', '[RFC4398]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('DNAME', 39, 'DNAME', '[RFC2672]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('OPT', 41, 'OPT', '[RFC2671]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('APL', 42, 'APL', '[RFC3123]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('DS', 43, 'Delegation Signer', '[RFC4034][RFC3658]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('SSHFP', 44, 'SSH Key Fingerprint', '[RFC4255]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('IPSECKEY', 45, 'IPSECKEY', '[RFC4025]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('RRSIG', 46, 'RRSIG', '[RFC4034][RFC3755]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('NSEC', 47, 'NSEC', '[RFC4034][RFC3755]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('DNSKEY', 48, 'DNSKEY', '[RFC4034][RFC3755]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('DHCID', 49, 'DHCID', '[RFC4701]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('HIP', 55, 'Host Identity Protocol', '[RFC5205]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('SPF', 99, '', '[RFC4408]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('TKEY', 249, 'Transaction Key', '[RFC2930]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('TSIG', 250, 'Transaction Signature', '[RFC2845]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('IXFR', 251, 'incremental transfer', '[RFC1995]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('AXFR', 252, 'transfer of an entire zone', '[RFC1035]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('MAILB', 253, 'mailbox-related RRs (MB, MG or MR)', '[RFC1035]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('MAILA', 254, 'mail agent RRs (Obsolete - see MX)', '[RFC1035]');
INSERT INTO DNS_types (type, value, meaning, rfcreferences) 
                           VALUES ('DLV', 32769, 'DNSSEC Lookaside Validation', '[RFC4431]');
