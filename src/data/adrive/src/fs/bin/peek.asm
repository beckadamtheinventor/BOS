	jq peek_main
	db "FEX",0
peek_main:
	pop bc
	ex (sp),hl
	push bc
	ld a,(de)
	ld c,1
	cp a,'b'
	jq z,.preinchl
	inc c
	cp a,'s'
	jq z,.preinchl
	inc c
	cp a,'i'
	jq z,.preinchl
	inc c
	cp a,'l'
	jq z,.preinchl
	dec hl
	ld c,1
.preinchl:
	push bc
	inc hl
	push hl
	call osrt.hexstr_to_int
	pop bc,bc
	jq osrt.read_a_from_addr
