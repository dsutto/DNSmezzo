DROP TABLE dns_packets_prev2;
ALTER TABLE dns_packets_prev RENAME TO dns_packets_prev2;
ALTER TABLE dns_packets RENAME TO dns_packets_prev;

DROP TABLE pcap_files_prev2;
ALTER TABLE pcap_files_prev RENAME TO pcap_files_prev2;
ALTER TABLE pcap_files RENAME TO pcap_files_prev;

VACUUM FULL;
