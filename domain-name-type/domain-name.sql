DROP TYPE domainname CASCADE;

CREATE TYPE domainname;

CREATE OR REPLACE function domainname_in(cstring)
	returns domainname
	as '/home/stephane/AFNIC/R&D/Devel/DNSwitness/DNSmezzo/domain-name-type/domain-name.so'
	language 'c';

CREATE OR REPLACE function domainname_out(domainname)
	returns cstring
	as '/home/stephane/AFNIC/R&D/Devel/DNSwitness/DNSmezzo/domain-name-type/domain-name.so'
	language 'c';

CREATE TYPE domainname (
       -- TODO: toast it to avoid wasting: today, we actually use
       -- internallength for each domain
       -- name. http://www.postgresql.org/docs/current/interactive/storage-toast.html
       -- http://www.postgresql.org/docs/current/interactive/xtypes.html
       -- (PG_DETOAST_DATUM)
       -- http://www.google.com/codesearch?q=PG_DETOAST_DATUM+lang%3Ac&hl=en&btnG=Search+Code
       -- (Postgis l'utilise, et tsearch)

       -- TODO: length necessary?
       -- psql:domain-name.sql:8: NOTICE:  return type domainname is only a shell
        -- If no internallength we retrieve always empty records :-(

	-- TODO: computed value
        internallength = 1032,
	input = domainname_in,
	output = domainname_out
);

CREATE OR REPLACE function domainname_reg_name(domainname)
	RETURNS cstring
   AS '/home/stephane/AFNIC/R&D/Devel/DNSwitness/DNSmezzo/domain-name-type/domain-name.so'
	language 'c';

CREATE OR REPLACE function dn_reg_name(domainname)
	RETURNS text
   AS 'SELECT domainname_reg_name($1)::TEXT'
	LANGUAGE 'sql' IMMUTABLE;

CREATE OR REPLACE function domainname_orig_name(domainname)
	RETURNS cstring
   AS '/home/stephane/AFNIC/R&D/Devel/DNSwitness/DNSmezzo/domain-name-type/domain-name.so'
	language 'c';

CREATE OR REPLACE function dn_orig_name(domainname)
	RETURNS text
   AS 'SELECT domainname_orig_name($1)::TEXT'
	LANGUAGE 'sql' IMMUTABLE;

CREATE OR REPLACE function domainname_name(domainname)
	returns cstring
   as '/home/stephane/AFNIC/R&D/Devel/DNSwitness/DNSmezzo/domain-name-type/domain-name.so'
	language 'c';

CREATE OR REPLACE function dn_name(domainname)
	returns text
   as 'SELECT domainname_name($1)::TEXT'
	language 'sql' IMMUTABLE;

CREATE OR REPLACE function domainname_tld(domainname)
	returns cstring
   as '/home/stephane/AFNIC/R&D/Devel/DNSwitness/DNSmezzo/domain-name-type/domain-name.so'
	language 'c';

CREATE OR REPLACE function dn_tld(domainname)
	RETURNS text
   as 'SELECT domainname_tld($1)::TEXT'
	LANGUAGE 'sql' IMMUTABLE;

CREATE OR REPLACE function dn_nlabels(domainname)
	RETURNS integer
   AS '/home/stephane/AFNIC/R&D/Devel/DNSwitness/DNSmezzo/domain-name-type/domain-name.so'
	language 'c' IMMUTABLE;

CREATE OR REPLACE function length(domainname)
	RETURNS integer
   AS 'SELECT length(dn_name($1))'
	LANGUAGE 'sql';

CREATE OR REPLACE function domainname_eq(domainname, domainname)
	returns bool
   as '/home/stephane/AFNIC/R&D/Devel/DNSwitness/DNSmezzo/domain-name-type/domain-name.so'
	language 'c';

CREATE OR REPLACE function domainname_lt(domainname, domainname)
	returns bool
   as '/home/stephane/AFNIC/R&D/Devel/DNSwitness/DNSmezzo/domain-name-type/domain-name.so'
	language 'c';

CREATE OR REPLACE FUNCTION domainname_le(domainname, domainname) RETURNS bool
   AS 'SELECT domainname_lt($1, $2) OR domainname_eq($1, $2)' 
       LANGUAGE 'sql';

CREATE OR REPLACE function domainname_gt(domainname, domainname)
	returns bool
   as '/home/stephane/AFNIC/R&D/Devel/DNSwitness/DNSmezzo/domain-name-type/domain-name.so'
	language 'c';

CREATE OR REPLACE FUNCTION domainname_ge(domainname, domainname) RETURNS bool
   AS 'SELECT domainname_gt($1, $2) OR domainname_eq($1, $2)' 
       LANGUAGE 'sql';

CREATE OR REPLACE function domainname_cmp(domainname, domainname)
	returns integer
   as '/home/stephane/AFNIC/R&D/Devel/DNSwitness/DNSmezzo/domain-name-type/domain-name.so'
	language 'c';

CREATE OPERATOR = (
	leftarg = domainname,
	rightarg = domainname,
	commutator = =,
--	negator = <>,
	procedure = domainname_eq
);

CREATE OPERATOR < (
	leftarg = domainname,
	rightarg = domainname,
	commutator = <,
	negator = >=,
	procedure = domainname_lt
);

CREATE OPERATOR <= (
	leftarg = domainname,
	rightarg = domainname,
	commutator = <=,
	negator = >,
	procedure = domainname_le
);

CREATE OPERATOR > (
	leftarg = domainname,
	rightarg = domainname,
	commutator = >,
	negator = <=,
	procedure = domainname_gt
);

CREATE OPERATOR >= (
	leftarg = domainname,
	rightarg = domainname,
	commutator = >=,
	negator = <,
	procedure = domainname_ge
);

CREATE OPERATOR CLASS domainname_ops
    DEFAULT FOR TYPE domainname USING btree AS
        OPERATOR        1       < ,
        OPERATOR        2       <= ,
        OPERATOR        3       = ,
        OPERATOR        4       >= ,
        OPERATOR        5       > ,
        FUNCTION 1 domainname_cmp(domainname, domainname);

--




