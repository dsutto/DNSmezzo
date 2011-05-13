#include <stdio.h>
#include <stdlib.h>

#include "domain-name.h"

int
main(int argc, char **argv)
{
    domainname      d1, d2;
    char           *data1, *data2, *data3, *data4;
    if (argc < 3) {
        printf("Usage: %s domainname domainname\n", argv[0]);
        return 1;
    }
    data1 = (char *) malloc(MAX_LENGTH);
    data2 = (char *) malloc(MAX_LENGTH);
    data3 = (char *) malloc(MAX_LENGTH);
    data4 = (char *) malloc(MAX_LENGTH);
    d1 = text_to_domain(argv[1]);
    if (!VALID(d1)) {
        printf("Invalid domain name \"%s\"\n", argv[1]);
        return 1;
    }
    d2 = text_to_domain(argv[2]);
    if (!VALID(d2)) {
        printf("Invalid domain name \"%s\"\n", argv[2]);
        return 1;
    }
    printf
        ("The canonical version of \"%s\" is \"%s\"; its TLD is \"%s\".\n\tIts registered domain is \"%s\", it has %i labels\n",
         orig_domain_name(data1, d1), domain_name(data2, d1), tld(data3, d1),
         registered_domain_name(data4, d1), (int) nlabels(d1));
    if (are_equal(d1, d2)) {
        printf("%s and %s are equivalent domain names\n", argv[1], argv[2]);
    } else {
        printf("%s and %s are NOT equivalent domain names\n", argv[1], argv[2]);
    }
    if (are_identical(d1, d2)) {
        printf("%s and %s are absolutely identical\n", argv[1], argv[2]);
    } else {
        printf("%s and %s are NOT absolutely identical\n", argv[1], argv[2]);
    }
    free(data1);
    free(data2);
    free(data3);
    free(data4);
    return 0;
}
