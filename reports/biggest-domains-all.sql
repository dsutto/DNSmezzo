-- Find the most often queried domains

SELECT substr(registered_domain,1,46) AS domain, count(id) AS requests FROM dns_packets WHERE (file=5 OR file=13) AND query AND qtype != 15
   GROUP BY registered_domain ORDER by requests DESC LIMIT 100;

