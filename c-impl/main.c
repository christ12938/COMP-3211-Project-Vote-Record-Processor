#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <assert.h>

#define N_VOTES       1
#define N_CANDIDATES  5
#define N_DISTRICTS   5

/*
      31 27   26 23   22                      0
    | ddddd | ccc c | vvvvvvv vvvvvvvv vvvvvvvv |
*/

    // 0b01000 011 01001111 01001101 01010000
#define DISTR_ID_OFF   27
#define CANDT_ID_OFF   23
#define VOTE_COUNT_OFF 0

#define DISTR_ID_MSK   (0x1F << DISTR_ID_OFF)
#define CANDT_ID_MSK   (0x0F << CANDT_ID_OFF)
#define VOTE_COUNT_MSK (0x3FFFFF << VOTE_COUNT_OFF)

#define vote_record_create(distr_id, candt_id, vote_count) ((distr_id << DISTR_ID_OFF) | (candt_id << CANDT_ID_OFF) | (vote_count << VOTE_COUNT_OFF))

typedef uint8_t tag_t;

typedef uint32_t vote_record_t;

/*
typedef struct vote_record {
    uint32_t district_id : 5,
             candidate_d : 4,
             vote_count : 23;
} vote_record_t;
*/

typedef struct vote_packet {
    vote_record_t vote_record;
    tag_t vote_tag;
} vote_packet_t;


/*
      31    25     22    19    16    13    10     7     4    2    0    
    | xxxxxxx | r rr | rrr | rrr | rrr | sss | pp p | ppp | bb | bb |

    |-padding-|--r3--|-r2--|-r1--|-r0--|--s--|--p2--|-p1--|-b2-|-b1-|
0b 110 000 100 001 010 010 100 01 10
*/

#define CTRL_WRD_R3_OFF 22
#define CTRL_WRD_R2_OFF 19
#define CTRL_WRD_R1_OFF 16
#define CTRL_WRD_R0_OFF 13
#define CTRL_WRD_S_OFF  10
#define CTRL_WRD_P2_OFF  7
#define CTRL_WRD_P1_OFF  4
#define CTRL_WRD_B2_OFF  2
#define CTRL_WRD_B1_OFF  0

#define CTRL_WRD_R3_MSK (0x7 << CTRL_WRD_R3_OFF)
#define CTRL_WRD_R2_MSK (0x7 << CTRL_WRD_R2_OFF)
#define CTRL_WRD_R1_MSK (0x7 << CTRL_WRD_R1_OFF)
#define CTRL_WRD_R0_MSK (0x7 << CTRL_WRD_R0_OFF)
#define CTRL_WRD_S_MSK  (0x7 << CTRL_WRD_S_OFF )
#define CTRL_WRD_P2_MSK (0x7 << CTRL_WRD_P2_OFF)
#define CTRL_WRD_P1_MSK (0x7 << CTRL_WRD_P1_OFF)
#define CTRL_WRD_B2_MSK (0x3 << CTRL_WRD_B2_OFF)
#define CTRL_WRD_B1_MSK (0x3 << CTRL_WRD_B1_OFF)

void print_vote_record (vote_record_t record);

static uint32_t ctrl_wrd = 0;

static uint32_t vote_count_table[N_CANDIDATES][N_DISTRICTS] = {0};
static uint64_t vote_count_totals[N_CANDIDATES] = {0};

static vote_record_t votes[N_VOTES] = {
    /*
    vote_record_create(1, 1, 10),
    vote_record_create(1, 2, 20),
    vote_record_create(1, 3, 30),
    vote_record_create(1, 4, 40),
    vote_record_create(2, 1, 50)
    */
    // vote_record_create(8, 6, 5197136)
    vote_record_create(3, 4, 10)
};

void init_ctrl_word() {
    /*
    ctrl_wrd |= 6u << CTRL_WRD_R3_OFF;
    ctrl_wrd |= 0u << CTRL_WRD_R2_OFF;
    ctrl_wrd |= 4u << CTRL_WRD_R1_OFF;
    ctrl_wrd |= 1u << CTRL_WRD_R0_OFF;
    ctrl_wrd |= 2u << CTRL_WRD_S_OFF;
    ctrl_wrd |= 2u << CTRL_WRD_P2_OFF;
    ctrl_wrd |= 4u << CTRL_WRD_P1_OFF;
    ctrl_wrd |= 1u << CTRL_WRD_B2_OFF;
    ctrl_wrd |= 2u << CTRL_WRD_B1_OFF;
    */
    ctrl_wrd |= 6u << CTRL_WRD_R3_OFF;
    ctrl_wrd |= 0u << CTRL_WRD_R2_OFF;
    ctrl_wrd |= 4u << CTRL_WRD_R1_OFF;
    ctrl_wrd |= 1u << CTRL_WRD_R0_OFF;
    ctrl_wrd |= 2u << CTRL_WRD_S_OFF;
    ctrl_wrd |= 2u << CTRL_WRD_P2_OFF;
    ctrl_wrd |= 4u << CTRL_WRD_P1_OFF;
    ctrl_wrd |= 2u << CTRL_WRD_B2_OFF;
    ctrl_wrd |= 1u << CTRL_WRD_B1_OFF;
}

void swap(vote_record_t* record) {
    uint32_t b1 = (ctrl_wrd & CTRL_WRD_B1_MSK) >> CTRL_WRD_B1_OFF;
    uint32_t b2 = (ctrl_wrd & CTRL_WRD_B2_MSK) >> CTRL_WRD_B2_OFF;
    uint32_t p1 = (ctrl_wrd & CTRL_WRD_P1_MSK) >> CTRL_WRD_P1_OFF;
    uint32_t p2 = (ctrl_wrd & CTRL_WRD_P2_MSK) >> CTRL_WRD_P2_OFF;
    uint32_t s  = (ctrl_wrd & CTRL_WRD_S_MSK)  >> CTRL_WRD_S_OFF;

    printf("swap: (b1=%u, b2=%u, p1=%u, p2=%u, s=%u)\n",
        b1, b2, p1, p2, s);

    /*
        record = 0b 01000011 01001111 01001101 01010000
        
        swap(b1=2, b2=1, p1=4, p2=2, s=2)

            before

                      24         16         8
            0b 01000011 01|00|1111 0100|11|01 01010000
               D3       D2         D1         D0

            after

                      24         16         8
            0b 01000011 01|11|1111 0100|00|01 01010000
               D3       D2         D1         D0

                                
    */

    vote_record_t record_lc = *record;

    uint8_t pos_1 = 8*b1 + p1;
    uint8_t pos_2 = 8*b2 + p2;

    uint32_t b1_msk = ~(0xFFFFFFFF << s) << pos_1;
    uint32_t b2_msk = ~(0xFFFFFFFF << s) << pos_2;

    uint32_t b1_bits = (record_lc & b1_msk) >> pos_1;
    uint32_t b2_bits = (record_lc & b2_msk) >> pos_2;

    uint32_t swapped_record = (record_lc & ~b2_msk);
    swapped_record |= (b1_bits << pos_2);
    swapped_record |= (swapped_record & ~b1_msk);
    swapped_record |= (b2_bits << pos_1);
    *record = swapped_record;
}

void rot_left_shift(uint8_t* v, uint8_t n) {
    /*
        rsl 0b01101011 5
    */
   uint8_t bottom = *v >> (8 - n); // 0b00001101
   uint8_t top = *v << n;          // 0b01100000
   *v = top | bottom;              // 0b01101101
}

tag_t compute_tag(vote_record_t record) {
    swap(&record);

    uint8_t d3 = (record & 0xFF000000) >> 24;
    uint8_t d2 = (record & 0x00FF0000) >> 16;
    uint8_t d1 = (record & 0x0000FF00) >> 8;
    uint8_t d0 = (record & 0x000000FF) >> 0;

    uint32_t r3 = (ctrl_wrd & CTRL_WRD_R3_MSK) >> CTRL_WRD_R3_OFF;
    rot_left_shift(&d3, r3);

    uint32_t r2 = (ctrl_wrd & CTRL_WRD_R2_MSK) >> CTRL_WRD_R2_OFF;
    rot_left_shift(&d2, r2);

    uint32_t r1 = (ctrl_wrd & CTRL_WRD_R1_MSK) >> CTRL_WRD_R1_OFF;
    rot_left_shift(&d1, r1);

    uint32_t r0 = (ctrl_wrd & CTRL_WRD_R0_MSK) >> CTRL_WRD_R0_OFF;
    rot_left_shift(&d0, r0);

    tag_t tag = d3 ^ d2 ^ d1 ^ d0;

    return tag;
}

void process_packet (vote_packet_t packet) {
    tag_t tag_prime = compute_tag(packet.vote_record);
    printf("tag_prime: 0x%x\n", tag_prime);
    if (tag_prime != packet.vote_tag) return;

    uint32_t distr_id   = (packet.vote_record & DISTR_ID_MSK)   >> DISTR_ID_OFF;
    uint32_t candt_id   = (packet.vote_record & CANDT_ID_MSK)   >> CANDT_ID_OFF;
    uint32_t vote_count = (packet.vote_record & VOTE_COUNT_MSK) >> VOTE_COUNT_OFF;

    uint64_t prev = vote_count_table[candt_id][distr_id];
    vote_count_table[candt_id][distr_id] = vote_count;

    uint64_t diff = vote_count - prev;
    vote_count_totals[candt_id] += diff;

    return;
}

vote_packet_t siml_untrusted_network(vote_packet_t packet_in) {
    // potentially permutate the record
    return packet_in;
}

void print_vote_record (vote_record_t record) {
    uint32_t candt_id   = (record & CANDT_ID_MSK)   >> CANDT_ID_OFF;
    uint32_t distr_id   = (record & DISTR_ID_MSK)   >> DISTR_ID_OFF;
    uint32_t vote_count = (record & VOTE_COUNT_MSK) >> VOTE_COUNT_OFF;
    printf("record: (distr_id=%u, candt_id=%u, vote_count=%u): 0x%x\n",
        distr_id, candt_id, vote_count, record);
}

void print_ctrl_word () {
    uint32_t b1 = (ctrl_wrd & CTRL_WRD_B1_MSK) >> CTRL_WRD_B1_OFF;
    uint32_t b2 = (ctrl_wrd & CTRL_WRD_B2_MSK) >> CTRL_WRD_B2_OFF;
    uint32_t p1 = (ctrl_wrd & CTRL_WRD_P1_MSK) >> CTRL_WRD_P1_OFF;
    uint32_t p2 = (ctrl_wrd & CTRL_WRD_P2_MSK) >> CTRL_WRD_P2_OFF;
    uint32_t s  = (ctrl_wrd & CTRL_WRD_S_MSK)  >> CTRL_WRD_S_OFF;
    uint32_t r3 = (ctrl_wrd & CTRL_WRD_R3_MSK) >> CTRL_WRD_R3_OFF;
    uint32_t r2 = (ctrl_wrd & CTRL_WRD_R2_MSK) >> CTRL_WRD_R2_OFF;
    uint32_t r1 = (ctrl_wrd & CTRL_WRD_R1_MSK) >> CTRL_WRD_R1_OFF;
    uint32_t r0 = (ctrl_wrd & CTRL_WRD_R0_MSK) >> CTRL_WRD_R0_OFF;
    printf("ctrl_wrd: (r3=%u, r2=%u, r1=%u, r0=%u, s=%u, p2=%u, p1=%u, b2=%u, b1=%u): 0x%x\n",
        r3, r2, r1, r0, s, p2, p1, b2, b1, ctrl_wrd);
}


void print_vote_table() {
    // print row headers
    printf("| candt ");
    for (int d_i = 0; d_i < N_DISTRICTS; d_i++) {
        printf("| d_%02d ", d_i);
    }
    printf("| total    |\n");

    printf("| ----- ");
    for (int d_i = 0; d_i < N_DISTRICTS; d_i++) {
        printf("| ---- ");
    }
    printf("| -------- |\n");

    // print rows
    for (int c_i = 0; c_i < N_CANDIDATES; c_i++) {
        printf("| %5d ", c_i);
        for (int d_i = 0; d_i < N_DISTRICTS; d_i++) {
            printf("| %4u ", vote_count_table[c_i][d_i]);
        }
        printf("| %8lu |\n", vote_count_totals[c_i]);
    }
}

int main (void) {
    printf("initialising control word (ctrl_wrd)\n");
    init_ctrl_word();
    printf("control word initialised\n");
    print_ctrl_word();

    for (int i = 0; i < N_VOTES; i++) {
        /* vote district */
        vote_record_t vote_record = votes[i];
        tag_t tag = compute_tag(vote_record);
        vote_packet_t packet_in = {
            .vote_record = vote_record,
            .vote_tag = tag
        };
        /* untrusted network */
        printf("vote district is about to send\n");
        print_vote_record(vote_record);
        printf("tag: 0x%x\n", tag);
        vote_packet_t packet_out = siml_untrusted_network(packet_in);
        /* election centre */
        printf("election centre is about to process\n");
        print_vote_record(vote_record);
        printf("tag: 0x%x\n", tag);
        process_packet(packet_out);
        print_vote_table();
    }
}