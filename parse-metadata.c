/* Tests the possibility of extracting meta-data (such as the sampling
   rate) from structured information in the file name. For instance,
   if the file name is
   mezzo-HOSTNAME-a.nic.fr-FOOBAR-4-IFACE-eth1-SAMPLING-10.2009-06-01.pcap, the
   meta-data indicates that the sampling rate is 10 %. */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_METADATA_SIZE 256

#define METADATA_INT 1
#define METADATA_DOUBLE 2

#define METADATA_BASE 10

void           *
get_metadata(name, key, type)
    char           *name;
    char           *key;
    int             type;
{
    char           *data;
    int            *iresult;
    double         *fresult;
    data = strstr(name, key);
    if (data == NULL) {
        return NULL;
    } else {
        data = data + strlen(key) + 1;
        switch (type) {
        case METADATA_INT:
            iresult = malloc(sizeof(int));
            *iresult = strtol(data, NULL, METADATA_BASE);
            if (*iresult <= 0) {
                fprintf(stderr, "Cannot find a value in %s\n", data);
                exit(1);
            }
            return iresult;
        case METADATA_DOUBLE:
            fresult = malloc(sizeof(double));
            *fresult = strtod(data, NULL);
            if (*fresult <= 0.0) {
                fprintf(stderr, "Cannot find a value in %s\n", data);
                exit(1);
            }
            return fresult;
        default:
            fprintf(stderr, "Invalid metadata type %i\n", type);
            break;
        }
        return NULL;
    }
}

int
main(argc, argv)
    int             argc;
    char          **argv;
{
    double         *sampling;
    int            *foobar;
    unsigned short  i;
    char           *filename;
    if (argc <= 1) {
        fprintf(stderr, "Usage: %s filename...\n", argv[0]);
        exit(1);
    }
    for (i = 1; i < argc; i++) {
        filename = argv[i];
        sampling = (double *) get_metadata(filename, "SAMPLING", METADATA_DOUBLE);
        if (sampling == NULL) {
            fprintf(stdout, "Sampling rate not found in %s\n", filename);
        } else {
            fprintf(stdout, "Sampling rate in %s is %1.3f\n", filename,
                    1.0 / (*sampling));
        }
        foobar = (int *) get_metadata(filename, "FOOBAR", METADATA_INT);
        if (foobar == NULL) {
            fprintf(stdout, "Foobar not found in %s\n", filename);
        } else {
            fprintf(stdout, "Foobar in %s is %i\n", filename, *foobar);
        }
    }
    exit(0);
}
