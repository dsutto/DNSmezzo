DROP TABLE Registry;

CREATE TABLE Registry (id SERIAL UNIQUE NOT NULL,
     created TIMESTAMP NOT NULL DEFAULT now(),
     fqdn Domainname UNIQUE NOT NULL);

-- Legal values
INSERT INTO Registry (fqdn) VALUES ('example.net');
INSERT INTO Registry (fqdn) VALUES ('marissa.google.net');
INSERT INTO Registry (fqdn) VALUES ('WWW.exemple.com.fr');
INSERT INTO Registry (fqdn) VALUES ('_ldap._tcp.foobar.fr');
INSERT INTO Registry (fqdn) VALUES ('FR');

-- Illegal values
INSERT INTO Registry (fqdn) VALUES ('....');
INSERT INTO Registry (fqdn) VALUES ('eXample.Net');

SELECT * FROM Registry ORDER BY fqdn;
SELECT * FROM Registry WHERE dn_name(fqdn) = 'example.net';
SELECT * FROM Registry WHERE dn_tld(fqdn) = 'fr' ORDER BY fqdn;

SELECT dn_nlabels(fqdn) AS labels, count(id) AS number FROM Registry 
         GROUP BY dn_nlabels(fqdn) ORDER BY labels DESC;

SELECT fqdn, length(fqdn), dn_reg_name(fqdn), dn_orig_name(fqdn) AS registered 
     FROM Registry 
     ORDER BY dn_nlabels(fqdn), fqdn;

