
;@DOES Find and reserve an asset location.
;@INPUT int util_AllocAssetLoc(size_t len);
;@OUTPUT asset handle. Returns 0 and Cf set if failed to allocate.
util_AllocAssetLoc:
	pop hl,de
	push de,hl
	ld hl,asset_reservations_table
	ld a,d
	or a,a
	jq nz,.start_search
	or a,e
	jq z,.fail
	inc d
	ld e,l
.start_search:
	xor a,a
	ld b,a
	ld c,4
.search_loop:
	cp a,(hl)
	inc hl
	jq z,.check_len ;found free asset handle
	djnz .search_loop
	dec c
	jq nz,.search_loop
.fail:
	sbc hl,hl
	scf
	ret
.check_len:
	push hl
.check_len_loop:
	dec d
	jq z,.found
	cp a,(hl)
	inc hl
	jq nz,.next_search_loop
	djnz .check_len_loop
	dec c
	jq nz,.check_len_loop
	jq .fail
.next_search_loop:
	pop af
	jq .search_loop
.found:
	pop hl
	dec hl
	ld de,-asset_reservations_table
	add hl,de
	ld b,8
.mult_loop:
	add hl,hl
	djnz .mult_loop
	ld de,asset_locations_start
	add hl,de
	ret
