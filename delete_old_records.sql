delete from dns_packets where age (date) > '7 days' and ((extract(minute from date)<30 and extract(minute from date)>=0) or (extract(minute from date)<60 and extract( minute from date) >35));
