/* Converts a list of DNS packets (read in a pcap trace file) to a
   PostgreSQL database.

   S. Bortzmeyer <bortzmeyer@afnic.fr> */

/* TODO: still some segfaults and memory corruption. Try it under
   splint and under garder gcc options. See
   http://stackoverflow.com/questions/154630/recommended-gcc-warning-options-for-c */

/* TODO: warnings when compiling on UltraSparc/NetBSD, worth some investigation

packets2postgresql.c: In function 'current_time':
packets2postgresql.c:46: warning: passing argument 1 of 'gmtime' from incompatible pointer type
packets2postgresql.c: In function 'lower':
packets2postgresql.c:56: warning: array subscript has type 'char'
packets2postgresql.c: In function 'main':
packets2postgresql.c:451: warning: passing argument 1 of 'gmtime' from incompatible pointer type
packets2postgresql.c:457: warning: passing argument 1 of 'gmtime' from incompatible pointer type

The gmtime problem seems serious since, on UltraSparc/NetBSD, the
program runs but stores only 1970-01-01 00:00:00 for the dates of the
packets.

*/

/* Standard headers */
#include <unistd.h>
#include <time.h>
#include <string.h>
#include <strings.h>
#include <arpa/inet.h>
#include <ctype.h>
#include <limits.h>
#include <sys/stat.h>
#include <unistd.h>

/* Application-specific headers */
#include <postgresql/libpq-fe.h>

#include "packet-defs.h"

#define MAX_TIME_SIZE 256
#define MAX_NAME 255
#define ISO_FORMAT "%F %H:%M:%SZ"

static char    *progname;

static void
usage()
{
    (void) fprintf(stderr, "Usage: %s filename.pcap\n", progname);
    exit(EXIT_FAILURE);
}

static char    *
current_time()
{
    char           *result = malloc(MAX_TIME_SIZE);
    struct timeval  tv;
    struct tm      *time;
    (void) gettimeofday(&tv, NULL);
    time = gmtime(&tv.tv_sec);
    strftime(result, MAX_TIME_SIZE, "%Y-%m-%dT%H:%M:%SZ", time);
    return result;
}

void
lower(char *to, const char *from)
{
    unsigned int    i;
    for (i = 0; i < strlen(from); i++) {
        to[i] = tolower(from[i]);
    }
    to[i] = '\0';
}

void
reg_domain(char *to, const char *from)
{
    char           *last_dot;
    unsigned int    l = strlen(from);
    unsigned int    offset;
    char            lc_from[MAX_NAME];
    char            tld[MAX_NAME];
    char            sld[MAX_NAME];
    char            domain[MAX_NAME];
    char            temp[MAX_NAME];
    bool            two_labels = false;
    lower(lc_from, from);
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
        } else {                /* Not a .FR */
            strcpy(to, lc_from);
        }
    } else {                    /* Just one label, the TLD */
        strcpy(to, lc_from);
    }
}

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

#define SQL_PACKET_COMMAND "INSERT INTO DNS_Packets \
           (file, rank, date, length, src_address, dst_address, protocol, src_port, dst_port, \
            query, query_id, opcode, rcode, aa, tc, rd, ra, qname, qtype, qclass, edns0_size, do_dnssec, \
            ancount, nscount, arcount, registered_domain, lowercase_qname) \
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, \
                   $16, $17, $18, $19, $20, $21, $22, $23, $24, $25, $26, $27);"
#define NUM_PACKET_PARAMS 27
#define PREPARED_PACKET_STMT "insert-data"
#define SQL_FILE_COMMAND "INSERT INTO Pcap_Files (hostname, filename, datalinktype, snaplength, filesize, filedate, stoppedat, samplingrate) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING id;"
#define NUM_FILE_PARAMS 8
#define PREPARED_FILE_STMT "insert-filename"
#define SQL_FILEEND_COMMAND "UPDATE Pcap_Files SET totalpackets=$1, storedpackets=$2, firstpacket=$3, lastpacket=$4 \
                                WHERE id=$5;"
#define NUM_FILEEND_PARAMS 5
#define PREPARED_FILEEND_STMT "update-filename"
#define MAX_INTEGER_WIDTH 30
#define MAX_FLOAT_WIDTH 40
#define MAX_TIMESTAMP_WIDTH 60

/* Defaults */
static bool     verbose = false;
static bool     dry_run = false;
static unsigned long maxpackets = 0;
static unsigned long commit_every = 0;
static bool     parse_filename = false;

int
main(int argc, char *argv[])
{
    /* Misc. variables */
    char           *filename, *hostname[MAX_NAME], errbuf[PCAP_ERRBUF_SIZE];
    pcap_parser_file *inputfile;
    struct dns_packet *packet;
    char            ch;
    char           *backup;
    unsigned long   packetnum = 0;

    /* PostgreSQL-related variables */
    char           *conninfo = "dbname=dns_monitor";
    PGconn         *conn = NULL;
    ConnStatusType  status;
    PGresult       *result;
    struct tm       file_creation, date_firstpacket, date_lastpacket;
    int            *sampling;
    const char     *packet_params[NUM_PACKET_PARAMS];
    const char     *file_params[NUM_FILE_PARAMS];
    const char     *fileend_params[NUM_FILEEND_PARAMS];
    unsigned int    file_id;

    progname = argv[0];
    while ((ch = (char) getopt(argc, argv, "nvm:c:e:p")) != -1) {
        switch (ch) {
        case 'v':
            verbose = true;
            break;
        case 'n':
            dry_run = true;
            break;
        case 'e':
            commit_every = atoi(optarg);
            if (commit_every <= 0) {
                fatal("illegal value for the commit interval");
            }
            break;
        case 'm':
            maxpackets = (unsigned long) atoi(optarg);
            if (maxpackets == 0) {
                fatal("illegal max. packets value");
            }
            break;
        case 'c':
            conninfo = optarg;
            break;
        case 'p':
            parse_filename = true;
            break;
        default:
            usage();
        }
    }
    argc -= optind;
    argv += optind;
    if (argc < 1) {
        usage();
    }
    filename = argv[0];
    inputfile = pcap_file_open(filename);
    if (inputfile == NULL) {
        fatal("Couldn't open file %s: %s\n", filename, errbuf);
    }
    if (verbose) {
        fprintf(stdout, "%s Dissecting %s and sending to \"%s\"\n", current_time(),
                filename, conninfo);
        /* TODO: retrieve from inputfile other parameters such as the snapshot size */
    }
    if (!dry_run) {
        conn = PQconnectdb(conninfo);
        if (conn == NULL) {
            fatal("Cannot connect to the database (unknown reason)");
        }
        status = PQstatus(conn);
        if (status != CONNECTION_OK) {
            fatal(PQerrorMessage(conn));
        }
        /* We find lot of funny characters in domain names, not always UTF-8.
         * Setting the client encoding to Latin-1 is arbitrary, but it is to be sure 
         * * * the program * won't crash (because any string is valid Latin-&,
         * unlike UTF-8). */
        result = PQexec(conn, "SET CLIENT_ENCODING TO 'LATIN-1';");
        if (PQresultStatus(result) != PGRES_COMMAND_OK) {
            fatal("Cannot set encoding");
        }
        result = PQexec(conn, "BEGIN;");
        if (PQresultStatus(result) != PGRES_COMMAND_OK) {
            fatal("Cannot start transaction");
        }
        /* TODO: may be not add it if there are no packets? */
        result = PQprepare(conn, PREPARED_FILE_STMT, SQL_FILE_COMMAND, 1, NULL);
        if (PQresultStatus(result) != PGRES_COMMAND_OK) {
            fatal("Cannot prepare statement: %s", PQresultErrorMessage(result));
        }
    }
    status = gethostname((char *) hostname, MAX_NAME);
    if (status != 0) {
        fatal("Cannot retrieve host name");
    }
    file_params[0] = (char *) hostname;
    file_params[1] = malloc(PATH_MAX + 1);
    realpath(filename, (char *) file_params[1]);
    file_params[2] = pcap_datalink_val_to_description(inputfile->datalink);
    file_params[3] = malloc(MAX_INTEGER_WIDTH);
    sprintf((char *) file_params[3], "%i", inputfile->snaplen);
    file_params[4] = malloc(MAX_INTEGER_WIDTH);
    sprintf((char *) file_params[4], "%li", (long int) inputfile->size);
    file_params[5] = malloc(MAX_TIMESTAMP_WIDTH);
    file_creation = *gmtime(&inputfile->creation);
    strftime((char *) file_params[5], MAX_TIMESTAMP_WIDTH, ISO_FORMAT,
             &file_creation);
    if (maxpackets > 0) {
        file_params[6] = malloc(MAX_INTEGER_WIDTH);
        sprintf((char *) file_params[6], "%li", maxpackets);
    } else {
        file_params[6] = NULL;
    }
    if (parse_filename) {
        sampling = (int *) get_metadata(filename, "SAMPLING", METADATA_INT);
        if (sampling == NULL) {
            file_params[7] = NULL;
        } else {
            file_params[7] = malloc(MAX_FLOAT_WIDTH);
            sprintf((char *) file_params[7], "%f", 1.0 / (*sampling));
        }
    } else {
        file_params[7] = NULL;
    }
    if (!dry_run) {
        result =
            PQexecPrepared(conn, PREPARED_FILE_STMT, NUM_FILE_PARAMS, file_params,
                           NULL, NULL, 0);
        if (PQresultStatus(result) == PGRES_TUPLES_OK) {
            file_id = (unsigned int) atoi(PQgetvalue(result, 0, 0));
            if (file_id == 0) {
                fatal("Cannot retrieve file_id after inserting file name %s",
                      filename);
            }
        } else {
            fatal("Result for '%s' with \"%s\" is %s", SQL_FILE_COMMAND,
                  file_params[0], PQresultErrorMessage(result));
        }
        result = PQprepare(conn, PREPARED_PACKET_STMT, SQL_PACKET_COMMAND, 1, NULL);
        if (PQresultStatus(result) != PGRES_COMMAND_OK) {
            fatal("Cannot prepare statement: %s", PQresultErrorMessage(result));
        }
        result =
            PQprepare(conn, PREPARED_FILEEND_STMT, SQL_FILEEND_COMMAND, 1, NULL);
        if (PQresultStatus(result) != PGRES_COMMAND_OK) {
            fatal("Cannot prepare statement: %s", PQresultErrorMessage(result));
        }
    }
    packet = malloc(sizeof(struct dns_packet));
    packet->qname = malloc(MAX_NAME);
    packet->src = malloc(INET6_ADDRSTRLEN);
    packet->dst = malloc(INET6_ADDRSTRLEN);
    packet_params[0] = malloc(MAX_INTEGER_WIDTH);
    packet_params[1] = malloc(MAX_INTEGER_WIDTH);
    packet_params[2] = malloc(MAX_TIMESTAMP_WIDTH);
    packet_params[3] = malloc(MAX_INTEGER_WIDTH);
    packet_params[4] = malloc(MAX_NAME);        /* TODO: it is an IP address... */
    packet_params[5] = malloc(MAX_NAME);        /* TODO: it is an IP address... */
    /* packet_params[6] = malloc(MAX_PROTO_WIDTH); Static value */
    packet_params[7] = malloc(MAX_INTEGER_WIDTH);
    packet_params[8] = malloc(MAX_INTEGER_WIDTH);
    /* packet_params[9] = malloc(MAX_BOOL_WIDTH); Static value */
    packet_params[10] = malloc(MAX_INTEGER_WIDTH);
    packet_params[11] = malloc(MAX_INTEGER_WIDTH);
    packet_params[12] = malloc(MAX_INTEGER_WIDTH);
    /* packet_params[13] = malloc(MAX_BOOL_WIDTH); Static value */
    /* packet_params[14] = malloc(MAX_BOOL_WIDTH); Static value */
    /* packet_params[15] = malloc(MAX_BOOL_WIDTH); Static value */
    /* packet_params[16] = malloc(MAX_BOOL_WIDTH); Static value */
    packet_params[17] = malloc(MAX_NAME);
    packet_params[18] = malloc(MAX_INTEGER_WIDTH);
    packet_params[19] = malloc(MAX_INTEGER_WIDTH);
    packet_params[20] = malloc(MAX_INTEGER_WIDTH);
    /* packet_params[21] = malloc(MAX_BOOL_WIDTH); Static value */
    packet_params[22] = malloc(MAX_INTEGER_WIDTH);
    packet_params[23] = malloc(MAX_INTEGER_WIDTH);
    packet_params[24] = malloc(MAX_INTEGER_WIDTH);
    packet_params[25] = malloc(MAX_NAME);
    packet_params[26] = malloc(MAX_NAME);
    sprintf((char *) packet_params[0], "%i", (int) file_id);
    for (;;) {
        /* Grab a packet */
        packet = get_next_packet(packet, inputfile);
        if (packet == NULL) {
            break;
        }
        sprintf((char *) packet_params[1], "%i", packet->rank);
        strftime((char *) packet_params[2], MAX_TIMESTAMP_WIDTH,
                 "%Y-%m-%d:%H:%M:%SZ",
                 gmtime((const time_t *) &packet->date.tv_sec));
        sprintf((char *) packet_params[3], "%i", packet->length);
        packet_params[4] = packet->src;
        packet_params[5] = packet->dst;
        packet_params[6] = "UDP";       /* TODO: add TCP support one day... */
        sprintf((char *) packet_params[7], "%i", packet->src_port);
        sprintf((char *) packet_params[8], "%i", packet->dst_port);
        packet_params[9] = packet->query ? "true" : "false";
        sprintf((char *) packet_params[10], "%i", packet->query_id);
        sprintf((char *) packet_params[11], "%i", packet->opcode);
        sprintf((char *) packet_params[12], "%i", packet->returncode);
        packet_params[13] = packet->aa ? "true" : "false";
        packet_params[14] = packet->tc ? "true" : "false";
        packet_params[15] = packet->rd ? "true" : "false";
        packet_params[16] = packet->ra ? "true" : "false";
        packet_params[17] = packet->qname;
        sprintf((char *) packet_params[18], "%i", packet->qtype);
        sprintf((char *) packet_params[19], "%i", packet->qclass);
        if (packet->edns0) {
            sprintf((char *) packet_params[20], "%i", packet->edns0_size);
            packet_params[21] = packet->do_dnssec ? "true" : "false";
        } else {
            backup = (char *) packet_params[20];
            packet_params[20] = NULL;
            packet_params[21] = NULL;
        }
        sprintf((char *) packet_params[22], "%i", packet->ancount);
        sprintf((char *) packet_params[23], "%i", packet->nscount);
        sprintf((char *) packet_params[24], "%i", packet->arcount);
        reg_domain((char *) packet_params[25], packet->qname);
        lower((char *) packet_params[26], packet->qname);
        if (!dry_run) {
            result =
                PQexecPrepared(conn, PREPARED_PACKET_STMT, NUM_PACKET_PARAMS,
                               packet_params, NULL, NULL, 0);
            if (PQresultStatus(result) == PGRES_COMMAND_OK) {
                /* OK */
            } else {
                fatal("Result for '%s' with \"%s\" is %s", SQL_PACKET_COMMAND,
                      packet_params[0], PQresultErrorMessage(result));
            }
        }
        if (!packet->edns0) {
            packet_params[20] = backup;
        }
        packetnum++;
        if (maxpackets > 0 && packetnum >= maxpackets) {
            break;
        }
        if ((commit_every != 0) && (packetnum % commit_every == 0)) {
            /* TODO: fill in atopped at? */
            if (!dry_run) {
                result = PQexec(conn, "COMMIT;");
                if (PQresultStatus(result) != PGRES_COMMAND_OK) {
                    fatal("Cannot commit transaction");
                }
                if (verbose) {
                    fprintf(stdout, "%s Committed %lu DNS packets\n",
                            current_time(), packetnum);
                }
                result = PQexec(conn, "BEGIN;");
                if (PQresultStatus(result) != PGRES_COMMAND_OK) {
                    fatal("Cannot start transaction");
                }
            }
        }
    }
    if (verbose) {
        fprintf(stdout, "%s Done, %lu DNS packets stored%s\n",
                current_time(), packetnum, (maxpackets > 0
                                            && packetnum >=
                                            maxpackets) ?
                " - interrupted before the end because max packets read" : "");
    }
    fileend_params[0] = malloc(MAX_INTEGER_WIDTH);
    fileend_params[1] = malloc(MAX_INTEGER_WIDTH);
    sprintf((char *) fileend_params[0], "%lu", inputfile->packetnum);
    sprintf((char *) fileend_params[1], "%lu", inputfile->dnspacketnum);
    fileend_params[2] = malloc(MAX_TIMESTAMP_WIDTH);
    date_firstpacket = *gmtime(&inputfile->firstpacket.tv_sec);
    strftime((char *) fileend_params[2], MAX_TIMESTAMP_WIDTH, ISO_FORMAT,
             &date_firstpacket);
    if (maxpackets == 0) {      /* Otherwise, the timestamp of the last packet is
                                 * not significant */
        fileend_params[3] = malloc(MAX_TIMESTAMP_WIDTH);
        date_lastpacket = *gmtime(&inputfile->lastpacket.tv_sec);
        strftime((char *) fileend_params[3], MAX_TIMESTAMP_WIDTH, ISO_FORMAT,
                 &date_lastpacket);
    } else {
        fileend_params[3] = NULL;
    }
    fileend_params[4] = malloc(MAX_INTEGER_WIDTH);
    sprintf((char *) fileend_params[4], "%i", file_id);
    if (!dry_run) {
        result =
            PQexecPrepared(conn, PREPARED_FILEEND_STMT, NUM_FILEEND_PARAMS,
                           fileend_params, NULL, NULL, 0);
        if (PQresultStatus(result) == PGRES_COMMAND_OK) {
            /* OK */
        } else {
            fatal("Result for '%s' with \"%s\" is %s", SQL_FILEEND_COMMAND,
                  fileend_params[2], PQresultErrorMessage(result));
        }
    }
    /* And close the session */
    pcap_file_close(inputfile);
    if (!dry_run) {
        result = PQexec(conn, "COMMIT;");
        if (PQresultStatus(result) != PGRES_COMMAND_OK) {
            fatal("Cannot commit transaction");
        }
        PQfinish(conn);
    }
    return (0);
}
