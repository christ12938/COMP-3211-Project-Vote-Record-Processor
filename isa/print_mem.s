	.data
cand_str:
	.asciiz "cand="
dist_str:
	.asciiz "dist="
count_str:
	.asciiz "count="
total_str:
	.asciiz "total="

	.text
	# void print_vote_count_table()
	# locals:
	#	$t0 = int i;
	#	$t1 = int j;
print_vote_count_table:
	# int i = 0;
	li		$t0, 0						
print_vote_count_table_outer_loop:

	# while (i < 16) {
	bge		$t0, 16, print_vote_count_table_outer_loop_end	

	# 	printf("cand: %u\n", i);
	li		$v0, 4						
	la		$a0, cand_str
	syscall

	li		$v0, 1
	move	$a0, $t0
	syscall							

	li		$v0, 11
	li		$a0, '\n'
	syscall							

	#   int j = 0;
	li		$t1, 0						
print_vote_count_table_inner_loop:
	#   while (j < 32) {
	bge		$t1, 32, print_vote_count_table_inner_loop_end	

	#     uint32_t val = vote_count_table[i][j];
	mul		$t4, $t0, 4					
	mul		$t5, $t1, 4
	add		$t3, $t4, $t5
	lw		$t4, vote_count_table($t3)	

	#     printf("dist=%u count=%u\n", j, val);
	li		$v0, 4						
	la		$a0, dist_str
	syscall

	li		$v0, 1
	move	$a0, $t1
	syscall

	li		$v0, 11
	li		$a0, ' '
	syscall							

	li		$v0, 4						
	la		$a0, count_str
	syscall

	li		$v0, 1
	move	$a0, $t4
	syscall

	li		$v0, 11
	li		$a0, '\n'
	syscall							

	#     j++;
	addi	$t1, $t1, 1					
	j		print_vote_count_table_inner_loop
print_vote_count_table_inner_loop_end:
	#   }
	#   i++;
	addi	$t0, $t0, 1					
	j		print_vote_count_table_outer_loop

print_vote_count_table_outer_loop_end:				
	# }
	j		print_vote_count_table_rtn


	# void print_vote_count_totals()
	# locals:
	#	$t0 = int i;
print_vote_count_totals:
	#   int i = 0;
	li		$t0, 0						
print_vote_count_totals_loop:
	#   while (j < 16) {
	bge		$t0, 16, print_vote_count_totals_loop_end	

	#     uint32_t val = vote_count_totals[i];
	mul		$t3, $t0, 4					
	lw		$t4, vote_count_totals($t3)	

	#     printf("cand=%u total=%u\n", i, val);
	li		$v0, 4						
	la		$a0, cand_str
	syscall

	li		$v0, 1
	move	$a0, $t0
	syscall

	li		$v0, 11
	li		$a0, ' '
	syscall							

	li		$v0, 4						
	la		$a0, total_str
	syscall

	li		$v0, 1
	move	$a0, $t4
	syscall

	li		$v0, 11
	li		$a0, '\n'
	syscall							

	#     i++;
	addi	$t0, $t0, 1					
	j		print_vote_count_totals_loop

print_vote_count_totals_loop_end:
	j		print_vote_count_totals_rtn