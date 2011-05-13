#define MAX_LENGTH 256

/* Never access the fields directly, always use the provided functions! */
typedef struct {
    unsigned short  _nlabels;
    size_t          _length;
    char            _orig_name[MAX_LENGTH];
    char            _lcase_name[MAX_LENGTH];
    char            _tld[MAX_LENGTH];
    char            _reg_domain[MAX_LENGTH];
} domainname;

#define INIT(d) {(d)._orig_name[0] = '\0'; (d)._lcase_name[0] = '\0'; (d)._tld[0] = '\0'; (d)._reg_domain[0] = '\0'; (d)._length = 0; (d)._nlabels = 0;}
#define VALID(d)  (((d)._length) != 0)

/* Comparison functions */
#ifndef bool
#include <stdbool.h>
#endif
/* are_equal uses the case-insensitive comparison of domain names */
bool            are_equal(domainname l, domainname r);
/* are_identical uses a strict (case-sensitive) comparison */
bool            are_identical(domainname l, domainname r);
/* Sort in lexicographic order */
bool            is_lower(domainname l, domainname r);
bool            is_greater(domainname l, domainname r);

/* Accessor functions */
char           *domain_name(char *result, const domainname d);
char           *orig_domain_name(char *result, const domainname d);
char           *tld(char *result, const domainname d);
char           *registered_domain_name(char *result, const domainname d);
unsigned short  nlabels(const domainname d);

/* Input-Output functions */
domainname      text_to_domain(const char *textr);
