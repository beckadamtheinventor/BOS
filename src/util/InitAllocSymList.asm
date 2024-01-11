;@DOES Allocate and initialize a Symbol list.
;@INPUT symlist *util_InitSymList(void);
;@OUTPUT Pointer to new Symbol list. 0 if failed.
;@NOTE All this does is allocate 6 bytes and set to 0. The memory location doesn't matter as long as it's in RAM and initialized to 0.
util_InitAllocSymList:
	ld hl,symlist.size
	call sys_Malloc.entryhl
	jr c,.fail
	push hl
	ld de,symbol.end
	ld (hl),de
	inc hl
	inc hl
	inc hl
	ld (hl),de
	pop hl
	ret
.fail:
	or a,a
	sbc hl,hl
	ret
