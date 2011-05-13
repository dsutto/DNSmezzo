/*
 *	PostgreSQL type definitions for domain names
 *
 */

#include <postgres.h>
#include <fmgr.h>

#include "domain-name.h"

#ifdef PG_MODULE_MAGIC
PG_MODULE_MAGIC;
#endif


PG_FUNCTION_INFO_V1(domainname_in);
Datum
domainname_in(PG_FUNCTION_ARGS)
{
    char           *str = PG_GETARG_CSTRING(0);
    domainname     *result, val;
    result = MALLOC(sizeof(domainname));
    val = text_to_domain(str);
    if (!VALID(val)) {
        ereport(ERROR, (errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
                        errmsg("domainname_in: invalid domain name \"%s\"", str)));
    }
    memcpy(result, &val, sizeof(domainname));
    PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(domainname_out);
Datum
domainname_out(PG_FUNCTION_ARGS)
{
    char           *result, *val;
    domainname     *fqdn = (domainname *) PG_GETARG_POINTER(0);
    if (fqdn == NULL)
        PG_RETURN_NULL();
    result = (char *) MALLOC(MAX_LENGTH);
    val = domain_name(result, *fqdn);
    PG_RETURN_CSTRING(result);
}

PG_FUNCTION_INFO_V1(domainname_name);
Datum
domainname_name(PG_FUNCTION_ARGS)
{
    char           *result, *val;
    result = (char *) MALLOC(MAX_LENGTH);
    val = domain_name(result, *((domainname *) PG_GETARG_POINTER(0)));
    PG_RETURN_CSTRING(result);
};

PG_FUNCTION_INFO_V1(domainname_tld);
Datum
domainname_tld(PG_FUNCTION_ARGS)
{
    char           *result;
    char           *val;
    result = (char *) MALLOC(MAX_LENGTH);
    val = tld(result, *((domainname *) PG_GETARG_POINTER(0)));
    /* TODO: free result and val? */
    PG_RETURN_CSTRING(result);
};

PG_FUNCTION_INFO_V1(domainname_orig_name);
Datum
domainname_orig_name(PG_FUNCTION_ARGS)
{
    char           *result;
    char           *val;
    result = (char *) MALLOC(MAX_LENGTH);
    val = orig_domain_name(result, *((domainname *) PG_GETARG_POINTER(0)));
    /* TODO: free result and val? */
    PG_RETURN_CSTRING(result);
};

PG_FUNCTION_INFO_V1(domainname_reg_name);
Datum
domainname_reg_name(PG_FUNCTION_ARGS)
{
    char           *result;
    char           *val;
    result = (char *) MALLOC(MAX_LENGTH);
    val = registered_domain_name(result, *((domainname *) PG_GETARG_POINTER(0)));
    /* TODO: free result and val? */
    PG_RETURN_CSTRING(result);
};

PG_FUNCTION_INFO_V1(dn_nlabels);
Datum
dn_nlabels(PG_FUNCTION_ARGS)
{
    size_t          result;
    result = nlabels(*((domainname *) PG_GETARG_POINTER(0)));
    PG_RETURN_INT32(result);
};

PG_FUNCTION_INFO_V1(domainname_eq);
Datum
domainname_eq(PG_FUNCTION_ARGS)
{
    bool            result;
    result =
        are_equal(*((domainname *) PG_GETARG_POINTER(0)),
                  *((domainname *) PG_GETARG_POINTER(1)));
    PG_RETURN_BOOL(result);
};

PG_FUNCTION_INFO_V1(domainname_lt);
Datum
domainname_lt(PG_FUNCTION_ARGS)
{
    bool            result;
    result =
        is_lower(*((domainname *) PG_GETARG_POINTER(0)),
                 *((domainname *) PG_GETARG_POINTER(1)));
    PG_RETURN_BOOL(result);
};

PG_FUNCTION_INFO_V1(domainname_gt);
Datum
domainname_gt(PG_FUNCTION_ARGS)
{
    bool            result;
    result =
        !is_lower(*((domainname *) PG_GETARG_POINTER(0)),
                  *((domainname *) PG_GETARG_POINTER(1)));
    PG_RETURN_BOOL(result);
};

PG_FUNCTION_INFO_V1(domainname_cmp);
Datum
domainname_cmp(PG_FUNCTION_ARGS)
{
    int32_t         result;
    domainname      d1 = *((domainname *) PG_GETARG_POINTER(0));
    domainname      d2 = *((domainname *) PG_GETARG_POINTER(1));
    if (are_equal(d1, d2)) {
        result = 0;
    } else if (is_lower(d1, d2)) {
        result = -1;
    } else {
        result = +1;
    }
    PG_RETURN_INT32(result);
};
