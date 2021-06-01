
;@DOES A = A / B, R = A % B
;@INPUT bos_u64_t *math_u64Mod(bos_u64_t *A, bos_u64_t *B, bos_u64_t *R);
;@OUTPUT pointer to A
math_u64Div:
	ld hl,-8
	call ti._frameset

	ld hl,(ix+6)
	lea de,(ix+9)
	
.subloop:
	
	
	
	ld sp,ix
	pop ix
	ret
