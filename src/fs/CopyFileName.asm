
;@DOES copies file name from file descriptor
;@INPUT char *fs_CopyFileName(char *dest, void *fd);
;@OUTPUT first byte of dest will be null if failed.
;@NOTE dest must be allocated at least 14 bytes
fs_CopyFileName:
	pop bc
	pop de
	pop hl
	push hl
	push de
	push bc
	ld a,(hl)
	or a,a
	jq z,.enda
	cp a,fsentry_deleted
	jq z,.end
	cp a,fsentry_longfilename
	jq z,.end
	ld (de),a
	inc de
	cp a,fsentry_dot
	jq z,.dotentry
.enterloop:
	inc hl
	push hl
	ld b,7
.loop:
	ld a,(hl)
	inc hl
	cp a,' '
	jq z,.ext_start
	ld (de),a
	inc de
	djnz .loop
.ext_start:
	pop hl
	ld bc,7
	add hl,bc
	ld a,(hl)
	cp a,' '
	jr z,.end
	ld a,'.'
	ld (de),a
	inc de
.ext:
	ld b,3
.extloop:
	ld a,(hl)
	inc hl
	cp a,' '
	jq z,.end
	ld (de),a
	inc de
	djnz .extloop
	jq .end
.dotentry:
	inc hl
	ld a,(hl)
	db $2E ;ld l,...
.end:
	xor a,a
.enda:
	ld (de),a
	inc de
	xor a,a
	ld (de),a
	pop bc
	pop hl
	push hl
	push bc
	ret




