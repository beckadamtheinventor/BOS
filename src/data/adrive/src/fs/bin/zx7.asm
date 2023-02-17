
	jr _zx7_main
	db "FEX",0
_zx7_main:
	call ti._frameset0
	call osrt.argv_1 ; mode argument -> HL
	ld a,(hl)
	cp a,'-' ; check argument starts with a hyphen
	jr z,.has_args
.display_info:
	ld hl,.info_str
	call bos.gui_PrintLine
.done:
	or a,a
	jr .return_cf
.formaterror:
	ld hl,.format_error_str
	jr .error_print
.failed_to_create_file:
	ld hl,.failed_to_create_file_str
	jr .error_print
.file_not_found:
	ld hl,.file_not_found_str
.error_print:
	call bos.gui_PrintLine
	scf
.return_cf:
	sbc hl,hl
	ld sp,ix
	pop ix
	ret
.has_args:
	inc hl
	ld a,(hl)
	cp a,'d' ; check if requesting decompression
	jq nz,.not_decompress ; otherwise go here
	call osrt.argv_2 ; source file argument -> HL
	push hl
	call bos.fs_GetFilePtr
	pop de
	jr c,.file_not_found
	push bc
	ex (sp),hl ; ptr -> (SP), len -> HL
	ld bc,8
	or a,a
	sbc hl,bc
	jr c,.formaterror ; fail if source file length less than 8 bytes (6 bytes of header, 2 bytes of compressed data)
	add hl,bc
	ex (sp),hl ; restore HL=ptr
	pop bc ; restore BC=len

	ld de,(hl)
	ex hl,de ; file pointer HL -> DE
	push bc ; save source length
	db $01,"ZX7" ; ld bc,"ZX7"
	xor a,a
	sbc hl,bc
	pop bc ; restore source length
	jr z,.formatgood
	ex hl,de ; file pointer DE -> HL
	push bc
	ex (sp),hl ; ptr -> (SP), len -> HL
	ld bc,10
	or a,a
	sbc hl,bc
	jr c,.formaterror ; fail if source file length less than 10 bytes (8 bytes of header, 2 bytes of compressed data)
	add hl,bc
	ex (sp),hl ; restore HL=ptr
	pop bc ; restore BC=len
	ld a,(hl)
	cp a,$18 ; jr instruction
	jr nz,.formaterror
	inc hl
	inc hl ; jr offset
	ld de,(hl) ; grab executable magic number
	ex hl,de
	db $01,"CRX" ; ld bc,"CRX"
	xor a,a
	sbc hl,bc
	jq nz,.formaterror
.formatgood:
	ex hl,de ; file pointer DE -> HL
	inc hl
	inc hl
	inc hl
	or a,(hl)
	jr nz,.formaterror
	inc hl
	mlt de
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	push hl ; save pointer to compressed data
	ld c,0
	push de,bc ; output length, property byte
	call osrt.argv_3 ; destination file argument -> HL
	push hl ; file name
	call bos.fs_OpenFile ; check if destination file exists
	call nc,bos.fs_DeleteFile ; delete it if it exists
	call bos.fs_CreateFile ; create destination file
	jq c,.failed_to_create_file
	pop bc,bc,bc ; pop file name, property byte, output length
	pop de ; pop pointer to compressed data

	push hl ; push destination file descriptor
	push bc ; push destination file length
	push de ; push pointer to compressed data
	ld de,ti.pixelShadow
	push de ; push pointer to temp memory
	call bos.util_Zx7Decompress ; decompress into pixelShadow
	pop de,bc,bc ; pop pixelShadow, pointer to compressed data, destination file length
	jq .write_file_entry  ; jump here as to not duplicate code

.not_decompress:
	cp a,'c' ; check if requesting compression
	jp nz,.display_info ; if not, display usage info

	call osrt.argv_2 ; source file argument -> HL
	push hl
	call bos.fs_GetFilePtr ; grab source file data pointer (HL) length (BC) and properties (A)
	jp c,.file_not_found ; fail if file was not found
	pop de

	push hl,bc ; save source file data pointer, length

	call osrt.argv_3 ; destination file argument -> HL
	ld bc,0
	push bc,bc,hl ; push file length, property byte, file name
	call bos.fs_OpenFile ; check if destination file exists
	call nc,bos.fs_DeleteFile ; delete it if it exists
	call bos.fs_CreateFile ; try to create empty file to hold output
	jp c,.failed_to_create_file ; fail if failed to create empty file
	pop bc,bc,bc
	
	pop bc ; restore source file length
	ex (sp),hl ; save destination file descriptor, restore source file pointer
	
	ld de,.progress_callback ; this will be called during compression to update the progress bar
	push de,bc,hl ; push callback, source length, source pointer
	ld de,ti.pixelShadow ; compress into pixelShadow
	push de ; push location to compress into
	call bos.util_Zx7Compress ; returns HL = compressed length
	pop de,bc,bc,bc ; pop compressed data pointer, source pointer, source length, callback
	pop bc ; restore file descriptor
	push de,bc,hl ; push compressed data pointer, file descriptor, compressed length
	call bos.fs_SetSize ; resize the output file
	jp c,.failed_to_create_file ; fail if failed to resize
	pop bc,hl,de ; pop compressed length, file descriptor, compressed data pointer
	push hl ; push file descriptor

.write_file_entry:
	or a,a
	sbc hl,hl
	ex (sp),hl ; push 0 (file write offset), pop file descriptor
	push hl ; push file descriptor
	ld l,1
	push hl ; push 8-bit value 1 (file write section count)
	push bc ; push destination file length (file write length)
	push de ; push compressed/decompressed data (file write data) (pixelShadow)
	call bos.fs_Write
	pop bc,hl ; pop data, len
	; the other values don't need to be popped, the stack pointer gets restored in the exit routine
.success:
	push hl
	call bos.gui_NewLine
	ld hl,.success_str
	call bos.gui_PrintString
	ld a,':'
	call bos.gui_PrintChar
	pop hl
	call bos.gui_PrintInt
	ld hl,.bytes_str
	call bos.gui_PrintLine
	jp .done
.progress_callback:
	ret
.info_str:
	db "Usage: zx7 -[c|d] infile outfile",$A
	db "Compress/Decompress infile to outfile.",0
.file_not_found_str:
	db "File not found.",0
.format_error_str:
	db "Input file has an invalid header.",0
.failed_to_create_file_str:
	db "Failed to create output file.",0
.success_str:
	db "Success. Output: ",0
.bytes_str:
	db "bytes.",0
