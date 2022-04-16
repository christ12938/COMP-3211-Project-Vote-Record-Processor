RECORD_PORT_MM_ADDR = 0xF000 # 0xFFFFF000 
TAG_PORT_MM_ADDR    = 0xF004 # 0xFFFF0004 
SEND_PORT_MM_ADDR   = 0xF008 # 0xFFFF0008
BUSY_PORT_MM_ADDR   = 0xF00C # 0xFFFF000C

#     31 27   26 23   22                      0
#   | ddddd | ccc c | vvvvvvv vvvvvvvv vvvvvvvv |

# 0b01000 011 01001111 01001101 01010000
DISTR_ID_OFF   = 27
CANDT_ID_OFF   = 23
VOTE_COUNT_OFF = 0

DISTR_ID_MSK   = (0x1F << DISTR_ID_OFF)
CANDT_ID_MSK   = (0x0F << CANDT_ID_OFF)
VOTE_COUNT_MSK = (0x3FFFFF << VOTE_COUNT_OFF)

	.data
ctrl_word:
	.word	0x12345678
vote_count_table:
	.space	2048	# 2^4 * 2^5 * 4

vote_count_totals:
	.space	64	# 2^4 * 4

	.text

	# void main(void);
	# locals:
	#	$t0 = uint32_t send
	#	$t1 = vote_record_t rec
main:

main_while_1:
						# while (1)
main_if_send_eq_1:
	addi	$t2, $zero, 1			# $t2 = 1
	lw	$t0, SEND_PORT_MM_ADDR
	bne	$t0, $t2, main_if_send_eq_1_f	# if (send == 1) {
	sw	$t2, BUSY_PORT_MM_ADDR		#   *busy_port = 1;
	lw	$t1, RECORD_PORT_MM_ADDR	#   vote_record_t rec = *rec_port;
	jal	process_record			#   process_record(rec);
main_if_send_eq_1_f:
	j	main_while_1			# }


	# void process_packet (vote_packet_t packet);
	# args:
	#	$a0 = packet.vote_record
	#	$a1 = packet.vote_tag
	# locals:
	#	$t0 = tag_t tag_prime
	#	$t1 = uint32_t candt_id
	#	$t2 = uint32_t distr_id
	#	$t3 = uint32_t vote_count
process_record:
	jal	compute_tag		
	add	$t0, $zero, $v0				# tag_t tag_prime = compute_tag(rec);
process_record_if_tag_valid:
	beq	$t0, $a1, process_record_if_tag_valid_t # if (tag_prime != packet.vote_tag)
	jr	$ra					#   return

process_record_if_tag_valid_t:
	# uint32_t candt_id = (packet.vote_record & CANDT_ID_MSK) >> CANDT_ID_OFF;
	addi	$t4, $zero, CANDT_ID_MSK
	and	$t1, $a0, $t4
	addi	$t4, $zero, CANDT_ID_OFF
	srlv	$t1, $t1, $t4		# (s)hift word (r)ight (l)ogical (v)ariable
	# uint32_t distr_id = (packet.vote_record & DISTR_ID_MSK) >> DISTR_ID_OFF;
	addi	$t4, $zero, DISTR_ID_MSK
	and	$t2, $a1, $t4
	addi	$t4, $zero, DISTR_ID_OFF
	srlv	$t2, $t2, $t4		# shift word right logical variable
	# uint32_t vote_count = (packet.vote_record & VOTE_COUNT_MSK) >> VOTE_COUNT_OFF;
	addi	$t4, $zero, VOTE_COUNT_MSK
	and	$t3, $a2, $t4
	addi	$t4, $zero, VOTE_COUNT_OFF
	srlv	$t3, $t3, $t4		# shift word right logical variable

	add	$a0, $t1, $zero
	add	$a1, $t2, $zero
	add	$a2, $t3, $zero
	j	update_vote_count	# update_vote_count(candt_id, distr_id, vote_count)


	# void update_vote_count(
	#	uint32_t candt_id,
	#	uint32_t distr_id,
	#	uint32_t vote_count
	# );
	#
	# args:
	#	$a0 = uint32_t candt_id
	#	$a1 = uint32_t distr_id
	#	$a2 = uint32_t vote_count
	# locals:
	#	$t0 = uint32_t prev 
	#	$t1 = uint32_t diff
	#	$t2 = uint32_t curr_total
update_vote_count:
	# uint32_t prev = vote_count_table[candt_id][distr_id];
	addi	$t3, $zero, 2			# $t3 = 2
	sllv	$t4, $a0, $t3			# $t4 = 4 * candt_id
	sllv	$t5, $a1, $t3			# $t5 = 4 * distr_id
	add	$t3, $t4, $t5			# $t3 = offset = (4 * candt_id) + (4 * distr_id)

	lw	$t0, vote_count_table($t3)	# uint32_t prev = vote_count_table[candt_id][distr_id]
	sw	$a2, vote_count_table($t3)	# vote_count_table[candt_id][distr_id] = vote_count

	sub	$t1, $a2, $t0			# uint32_t diff = vote_count - prev;
	lw	$t2, vote_count_totals($t4)	# uint32_t curr_total = vote_count_totals[candt_id]
	add	$t2, $t2, $t1			# curr_total += diff;
	sw	$t2, vote_count_totals($t4)	# vote_count_totals[candt_id] = curr_total;

	jr	$ra				# return
	
	
	# tag_t compute_tag(vote_record_t rec)
	# args:
	#	$a0 = vote_record_t rec 
	# returns:
	#	$v0 = tag_t
compute_tag:
	la	$t0, ctrl_word
	lw	$t1, 0($t0)
	# swap    $t2, $a0, $t0
	# rolb    $t2, $t2, $t0
	# xorb    $v0, $t2, $t0

	jr      $ra                   
