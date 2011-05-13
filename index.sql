-- Requires the last_labels function to be marked IMMUTABLE ("pure")
-- CREATE INDEX domain_idx ON DNS_packets(last_labels(qname, 2));     
CREATE INDEX qname_idx ON DNS_packets(qname);     
CREATE INDEX reg_domain_idx ON DNS_packets(registered_domain);     
CREATE INDEX lc_qname_idx ON DNS_packets(lowercase_qname);     
CREATE INDEX pcap_idx ON DNS_packets(file);     
CREATE INDEX date_idx ON DNS_packets(date);     
CREATE INDEX rcode_idx ON DNS_packets(rcode);     
