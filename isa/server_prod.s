#     31 27   26 23   22                      0
#   | ddddd | ccc c | vvvvvvv vvvvvvvv vvvvvvvv |

# 0b01000 011 01001111 01001101 01010000
DISTR_ID_OFF   = 27
CANDT_ID_OFF   = 23
VOTE_COUNT_OFF = 0

DISTR_ID_MSK   = 0x1F
CANDT_ID_MSK   = 0x0F
VOTE_COUNT_MSK = 0x7FFFFF

CTRL_WORD      = 0x1842946

	.data
vote_count_table:
	.space	2048	# 2^4 * 2^5 * 4

vote_count_totals:
	.space	64		# 2^4 * 4

ctrl_word:
	.space	4

	.text
	# void main(void);
main:
	li		$t0, CTRL_WORD
	sw		$t0, ctrl_word

	j		clear_vote_count_table			# clear_vote_count_table();
clear_vote_count_table_rtn:

	j		clear_vote_count_totals			# clear_vote_count_totals();
clear_vote_count_totals_rtn:

main_while_1:
											# while (1)
main_if_send_eq_1:
	li		$t0, 1
	bne		$send, $t0, main_if_send_eq_1_f	# if (send == 1) {
	move	$busy, $t0						#   *busy_port = 1;

	move	$a0, $rec						#   vote_record_t rec = *rec_port;
	move	$a1, $tag						#   tag_t tag = *tag_port;
	j		process_record					#   process_record(rec, tag);
	move	$busy, $zero					#   *busy_port = 0;
process_record_rtn:

main_if_send_eq_1_f:
	j		main_while_1					# }


	# void clear_vote_count_table()
	# locals:
	#	$t0 = int i;
clear_vote_count_table:
	li		$t0, 0										# int i = 0;
clear_vote_count_table_loop:
	li		$t1, 512
	beq		$t0, $t1, clear_vote_count_table_loop_end	# while (i != 512) {
	li		$t2, 2										#   int w_i = 4 * i;
	sllv	$t2, $t0, $t2
	sw		$zero, vote_count_table($t2)				#   vote_count_table[w_i] = 0;
	addi	$t0, $t0, 1									#   i++;
	j		clear_vote_count_table_loop	

clear_vote_count_table_loop_end:						# }
	j		clear_vote_count_table_rtn


	# void clear_vote_count_totals()
	# locals:
	#	$t0 = int i;
clear_vote_count_totals:
	li		$t0, 0										# int i = 0;
clear_vote_count_totals_loop:
	li		$t1, 16
	beq		$t0, $t1, clear_vote_count_totals_loop_end	# while (i != 16) {
	li		$t2, 2										#   int w_i = 4 * i;
	sllv	$t2, $t0, $t2
	sw		$zero, vote_count_totals($t2)				#   vote_count_totals[w_i] = 0;
	addi	$t0, $t0, 1									#   i++;
	j		clear_vote_count_totals_loop	

clear_vote_count_totals_loop_end:						# }
	j		clear_vote_count_totals_rtn


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
	j		compute_tag		

	# $a0 still equals packet.vote_record after it returns
compute_tag_rtn:

	move	$t0, $v0							# tag_t tag_prime = compute_tag(rec);
process_record_if_tag_valid:
	beq	$t0, $a1, process_record_if_tag_valid_t # if (tag_prime != packet.vote_tag)
	j	process_record_rtn						#   return

process_record_if_tag_valid_t:
	li		$t1, 0								# uint32_t candt_id = 0;
	li		$t2, 0								# uint32_t distr_id = 0;
	li		$t3, 0								# uint32_t vote_count = 0;

	# candt_id = (packet.vote_record >> CANDT_ID_OFF) & CANDT_ID_MSK;
	li		$t4, CANDT_ID_OFF
	srlv	$t1, $a0, $t4						# (s)hift word (r)ight (l)ogical (v)ariable
	li		$t4, CANDT_ID_MSK
	and		$t1, $t1, $t4
	# distr_id = (packet.vote_record >> DISTR_ID_OFF) & DISTR_ID_MSK;
	li		$t4, DISTR_ID_OFF
	srlv	$t2, $a0, $t4		
	li		$t4, DISTR_ID_MSK
	and		$t2, $t2, $t4
	# vote_count = (packet.vote_record >> VOTE_COUNT_OFF) & VOTE_COUNT_MSK;
	li		$t4, VOTE_COUNT_OFF
	srlv	$t3, $a0, $t4
	li		$t4, VOTE_COUNT_MSK
	and		$t3, $t3, $t4

	move	$a0, $t1							# addi	$a0, $t1, $zero
	move	$a1, $t2
	move	$a2, $t3
	j		update_vote_count					# update_vote_count(candt_id, distr_id, vote_count)
update_vote_count_rtn:
	j		process_record_rtn


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
	li		$t3, 2						# $t3 = 2
	sllv	$t4, $a0, $t3				# $t4 = 4 * candt_id
	sllv	$t3, $a1, $t3				# $t3 = 4 * distr_id
	add		$t3, $t4, $t3				# $t3 = offset = (4 * candt_id) + (4 * distr_id)

	lw		$t0, vote_count_table($t3)	# uint32_t prev = vote_count_table[candt_id][distr_id]
	sw		$a2, vote_count_table($t3)	# vote_count_table[candt_id][distr_id] = vote_count

	sub		$t1, $a2, $t0				# uint32_t diff = vote_count - prev;
	lw		$t2, vote_count_totals($t4)	# uint32_t curr_total = vote_count_totals[candt_id]
	add		$t2, $t2, $t1				# curr_total += diff;
	sw		$t2, vote_count_totals($t4)	# vote_count_totals[candt_id] = curr_total;

	j		update_vote_count_rtn		# return

	
	# tag_t compute_tag(vote_record_t rec)
	# args:
	#	$a0 = vote_record_t rec 
	# returns:
	#	$v0 = tag_t
compute_tag:
	lw		$t0, ctrl_word
	swap    $t1, $a0, $t0
	rolb    $t1, $t1, $t0
	xorb    $v0, $t1, $t0

	j		compute_tag_rtn
