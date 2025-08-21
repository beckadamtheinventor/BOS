	jq mkfile_main
	db "FEX",0
mkfile_main:
	ld hl,-18
	call ti._frameset
	ld (ix-3),iy ; save iy
	or a,a
	sbc hl,hl
	ld (ix-6),hl ; length of data
	ld (ix-9),hl ; pointer to data
	ld (ix-12),hl ; output file name
	ld (ix-18),hl ; pointer to argument containing number to fill file bytes with
	ld bc,(ix+6)
	ld iy,(ix+9)
	call .args.entry ; bypasses argv[0]
	ld hl,(ix-12) ; check if the output file name is set, show info and exit if zero
	add hl,bc
	xor a,a
	sbc hl,bc
	jq z,.show_info
	ld hl,(ix-6) ; check if the length of the data is set, create empty if zero
	add hl,bc
	xor a,a
	sbc hl,bc
	jr z,.empty_file
	ld hl,(ix-9) ; check if the data pointer is set, if not then create a file of a given size
	add hl,bc
	xor a,a
	sbc hl,bc
	jr nz,.file_has_data
	ld hl,(ix-18) ; check if a fill byte is set, if not then create the file unwritten (0xff bytes)
	add hl,bc
	xor a,a
	sbc hl,bc
	jr z,.empty_file
	push hl
	call bos.str_IntStrToInt
	pop bc
	ld a,l ; byte to fill file with
	jr .empty_file
.file_has_data:
	ld de,(ix-12) ; file name
	ld bc,(ix-6) ; data pointer
	ld hl,(ix-9) ; data length
	push hl,bc,de
	call bos.fs_WriteNewFile
	pop bc,bc,bc
	jr .exit_hl
.empty_file:
	push af
	ld hl,(ix-6) ; file length. zero length works, just doesn't allocate a data section
	push hl
	ld l,0 ; file flag byte
	push hl
	ld hl,(ix-12) ; file name
	push hl
	call bos.fs_CreateFile
	pop bc
	pop af
	inc a ; zf set if A was 0xff
	jr z,.exit_hl
	dec a
	push hl
.exit_hl:
	ld iy,(ix-3)
	ld sp,ix
	pop ix
	ret


.args.entry:
	ld (ix-15),bc ; save argc as a counter
	call .nextargv ; bypass argv[0]
	ret po ; return if no more arguments
.args:
	call .nextargv ; hl=argv[n]; n++;
	ret po ; return if no more arguments
	ld a,(hl)
	cp a,'-'
	ret nz
	inc hl
	ld a,(hl)
	cp a,'l'
	jr z,.args.length
	cp a,'a'
	jr z,.args.addr
	cp a,'i'
	jr z,.args.file
	cp a,'b'
	jr z,.args.byte
	cp a,'s'
	jr z,.args.string
	cp a,'h'
	jr nz,.args

.show_info:
	ld hl,.info_string
	call bos.gui_PrintLine
.exit_zero:
	or a,a
	sbc hl,hl
	jr .exit_hl

.args.length:
	call .intstrtoint
	ret po
	ld (ix-6),hl
	jr .args
.args.addr:
	call .intstrtoint
	ret po
	ld (ix-9),hl
	jr .args
.args.byte:
	call .nextargv
	ld (ix-18),hl
	jr .args
.args.string:
	call .nextargv
	ld (ix-6),hl
	push hl
	call ti._strlen
	pop bc
	ld (ix-9),hl
	jr .args
.args.file:
	call .nextargv
	push hl
	call bos.fs_GetFilePtr
	pop de
	ld (ix-6),hl
	ld (ix-9),de
	jr .args
; returns argv at counter, advances counter
; returns PO if no more arguments, otherwise PE
.nextargv:
	ld bc,(ix-15)
	cpi ; bc--, update p/v flag if zero
	ld (ix-15),bc
	ld hl,(iy)
	lea iy,iy+3
	ret
.intstrtoint:
	call .nextargv
	ret po
	push hl
	call bos.str_IntStrToInt
	pop bc
	ret

.info_string:
	db $9,"mkfile -h",$A
	db $9,"mkfile [-l len] [-i file] [-a addr] [-s string] [-b byte] [output_file]",$A,0

