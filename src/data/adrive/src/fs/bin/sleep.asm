
	jq sleep_main
	db "FEX",0
sleep_main:
	pop bc,de
	push de,bc
	xor a,a
	sbc hl,hl
.loop:
	ld a,(de)
	or a,a
	jq z,.sleep
	inc de
	sub a,'0'
	jq c,.loop
	cp a,10
	jq nc,.loop
	call .shiftin
	jq .loop
.sleep:
	add hl,bc
	xor a,a
	sbc hl,bc
	ret z
	ld b,a
.sleephl:
	djnz .sleephl
.nextms:
	add hl,bc
	scf
	sbc hl,bc
	jq nz,.sleephl
	ret

.shiftin:
	ld bc,0
	ld c,a
	add hl,bc
	add hl,hl ;x2
	push hl
	add hl,hl ;x4
	add hl,hl ;x8
	pop bc
	add hl,bc ;x8 + x2 = x10
	ret
