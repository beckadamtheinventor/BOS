;@DOES Join argv into a space-delimited string.
;@INPUT char *sys_JoinArgv(int argc, char *argv[]);
;@OUTPUT Pointer to string.
sys_JoinArgv:
	ld hl,-3
	call ti._frameset
	ld (ix-3),iy
	ld bc,(ix+6)
	ld iy,(ix+9)
	or a,a
	sbc hl,hl
	lea iy,iy+3
	dec bc
	ld a,c
	or a,b
	jq z,.no_args
.loop:
	ld de,(iy)
	pea iy+3
	push bc,hl,de
	call ti._strlen
	pop de,bc
	add hl,bc
	inc hl
	pop bc,iy
	dec bc
	ld a,c
	or a,b
	jr nz,.loop
	call sys_Malloc.entryhl
	jr c,.exit
	push hl
	ex hl,de
	ld bc,(ix+6)
	ld iy,(ix+9)
	dec bc
.loop2:
	push bc
	lea iy,iy+3
	ld hl,(iy)
	jr .copyloopentry
.copyloop:
	ldi
.copyloopentry:
	ld a,(hl)
	or a,a
	jr nz,.copyloop
	ld a,' '
	ld (de),a
	inc de
	pop bc
	dec bc
	ld a,c
	or a,b
	jr nz,.loop2
	dec de
	ld (de),a
	pop hl
	jr .exit
.no_args:
	ld hl,$FF0000
.exit:
	ld iy,(ix-3)
	ld sp,ix
	pop ix
	ret
