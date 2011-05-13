#include <string.h>
#include <ctype.h>
#include <strings.h>

#include "domain-name.h"

static void
_lower( /* @out@ */ char *to, const char *from)
{
    size_t          i;
    for (i = 0; i < strlen(from); i++) {
        to[i] = (char) tolower((int) from[i]);
    }
    to[i] = '\0';
}


static void
_reg_domain(char *to, const char *from)
{
    char           *last_dot;
    size_t          l = strlen(from);
    size_t          offset;
    char            lc_from[MAX_LENGTH];
    char            tld[MAX_LENGTH];
    char            sld[MAX_LENGTH];
    char            domain[MAX_LENGTH];
    char            temp[MAX_LENGTH];
    bool            two_labels = false;
    _lower(lc_from, from);
    last_dot = rindex(lc_from, '.');
    if (last_dot != NULL) {
        strcpy(tld, last_dot + 1);
        if (strcmp(tld, "fr") == 0) {
            offset = l - strlen(tld) - 1;
            strncpy(domain, lc_from, offset);
            domain[offset] = '\0';
            last_dot = rindex(domain, '.');
            if (last_dot != NULL) {
                strcpy(sld, last_dot + 1);
                offset = strlen(domain) - strlen(sld) - 1;
            } else {            /* Just two labels */
                two_labels = true;
                strcpy(sld, domain);
                offset = strlen(domain);
            }
            /* See also
             * http://www.afnic.fr/obtenir/chartes/nommage-fr/annexe-sectoriels */
            if ((strcmp(sld, "nom") == 0) ||
                (strcmp(sld, "com") == 0) ||
                (strcmp(sld, "presse") == 0) ||
                (strcmp(sld, "asso") == 0) ||
                (strcmp(sld, "cci") == 0) ||
                (strcmp(sld, "notaires") == 0) ||
                (strcmp(sld, "gouv") == 0) || (strcmp(sld, "tm") == 0)) {
                if (!two_labels) {
                    strncpy(temp, domain, offset);
                    temp[offset] = '\0';
                    last_dot = rindex(temp, '.');
                    if (last_dot != NULL) {
                        strcpy(to, last_dot + 1);
                    } else {    /* Three labels, TLD, SLD and domain */
                        strcpy(to, temp);
                    }
                    strcat(to, ".");
                    strcat(to, sld);
                } else {
                    strcat(to, sld);
                }
                strcat(to, ".fr");
            } else {            /* Ordinary SLD */
                last_dot = rindex(domain, '.');
                if (last_dot != NULL) {
                    strcpy(to, last_dot + 1);
                } else {
                    strcpy(to, domain);
                }
                strcat(to, ".fr");
            }
        } else {                /* Not a .FR. TODO: use publicsuffix.org */
            /* We (more or less) arbitrarily keep two labels */
            offset = l - strlen(tld) - 1;
            strncpy(domain, lc_from, offset);
            domain[offset] = '\0';
            last_dot = rindex(domain, '.');
            if (last_dot != NULL) {
                strcpy(sld, last_dot + 1);
                offset = strlen(domain) - strlen(sld) - 1;
            } else {            /* Just two labels */
                two_labels = true;
                strcpy(sld, domain);
                offset = strlen(domain);
            }
            strcat(to, sld);
            strcat(to, ".");
            strcat(to, tld);
        }
    } else {                    /* Just one label, the TLD */
        strcpy(to, lc_from);
    }
}

static unsigned short
_nlabels_of(const char *fqdn)
{
    unsigned short  result = 1;
    char           *next_dot;
    next_dot = index(fqdn, (int) '.');
    while (next_dot != NULL) {
        result++;
        next_dot = index(next_dot + 1, '.');
    }
    return result;
}

bool
are_equal(domainname l, domainname r)
{
    return (strcmp(l._lcase_name, r._lcase_name) == 0);
}

bool
is_lower(domainname l, domainname r)
{
    return (strcmp(l._lcase_name, r._lcase_name) < 0);
}

bool
is_greater(domainname l, domainname r)
{
    return (strcmp(l._lcase_name, r._lcase_name) > 0);
}

bool
are_identical(domainname l, domainname r)
{
    return (strcmp(l._orig_name, r._orig_name) == 0);
}

char           *
orig_domain_name(char *result, const domainname d)
{
    result[0] = '\0';
    strncat(result, d._orig_name, d._length);
    return result;
}

char           *
domain_name(char *result, const domainname d)
{
    result[0] = '\0';
    strncat(result, d._lcase_name, d._length);
    return result;
}

char           *
tld(char *result, const domainname d)
{
    result[0] = '\0';
    strncat(result, d._tld, strlen(d._tld));
    return result;
}

char           *
registered_domain_name(char *result, const domainname d)
{
    result[0] = '\0';
    strncat(result, d._reg_domain, strlen(d._reg_domain));
    return result;
}

unsigned short
nlabels(const domainname d)
{
    return d._nlabels;
}

/* Input-Output functions */
domainname
text_to_domain(const char *textr)
{
    domainname      result;
    size_t          length = strlen(textr);
    char           *last_dot;
    INIT(result);
    if (length > MAX_LENGTH) {
        return result;
    }
    /* Delete trailing dot(s). TODO: accept only one trailing dot? The current code
     * does not handle internal suites of dots, either... */
    while (length != 0 && textr[length - 1] == '.') {
        length--;
    }
    if (length == 0) {
        return result;
    }
    strncat(result._orig_name, textr, length);
    result._orig_name[length] = '\0';
    result._reg_domain[length] = '\0';
    result._length = length;
    _lower(result._lcase_name, result._orig_name);
    /* TODO: lowercasing an ASCII string does not change the length. But it may be a 
     * problem later with Unicode */
    last_dot = rindex(result._lcase_name, '.');
    if (last_dot != NULL) {
        strcpy(result._tld, last_dot + 1);
    } else {                    /* Just one label, the TLD */
        strcpy(result._tld, result._lcase_name);
    }
    _reg_domain(result._reg_domain, result._lcase_name);
    result._nlabels = _nlabels_of(result._orig_name);
    return result;
}
