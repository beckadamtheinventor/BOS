
	jq json_main
	db "FEX",0
json_main:
	ld hl,-6
	call ti._frameset
	syscall _argv_1 ; grab program arguments
	ld a,(hl)
	or a,a
	jq z,.display_info
	cp a,'$'
	jq z,.encode
.decode:
	; push hl
	; call bos.fs_GetFilePtr
	; push bc,hl
	; call nc,bos.json_Decode
	; pop bc,bc,bc
	; jq .return
.encode:
	; inc hl
	; push hl
	; call osrt.hexstr_to_int
	; ex (sp),hl
	; call bos.json_Encode
	; pop bc
	jq .return
.display_info:
	ld hl,.info_string
	call bos.gui_PrintLine
.return_zero:
	or a,a
	sbc hl,hl
	db $01 ; dummify 3 bytes
.return_1:
	ld hl,1 ; if this instruction is dummified, only the opcode and lower two bytes will be skipped. Since the upper byte is null this works
.return:
	ld sp,ix
	pop ix
	ret

.info_string:
	db "Usage: json [$addr|file]",$A
	db "json $addr    Encode object at addr into json",$A
	db "json file     Decode json from file into object",0
