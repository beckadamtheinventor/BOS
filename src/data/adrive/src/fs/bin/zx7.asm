
	jr _zx7_main
	db "FEX",0
_zx7_main:
	ld hl,-9
	call ti._frameset
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
.return_neg_1:
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
    ld a,(hl)
    or a,a
    jq z,.failed_to_create_file
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
	pop bc,bc,de ; pop pixelShadow, pointer to compressed data, destination file length
    pop hl ; pop file descriptor

	ld bc,0
	push bc,hl ; push file write offset, file descriptor
	ld c,1
	push bc ; push 8-bit value 1 (write count)
	push de ; push file length
	ld bc,ti.pixelShadow
	push bc ; push file data
	call bos.fs_Write
	jq c,.write_error
    pop bc,hl ; pop data pointer, file length
; the others don't need to be popped, the stack pointer gets restored in the exit routine
    jq .success


.not_decompress:
	cp a,'c' ; check if requesting compression
	jp nz,.display_info ; if not, display usage info

; compress
	call osrt.argv_2 ; source file argument -> HL
	push hl
	call bos.fs_GetFilePtr ; grab source file data pointer (HL) length (BC) and properties (A)
	jp c,.file_not_found ; fail if file was not found
	ld (ix-9),bc ; save original file length
	ex (sp),hl
	push bc,hl
	call bos.sys_GetExecTypeFD ; check what kind of file we're compressing
	ld hl,(hl)
	ex hl,de
	db $21, "REX"
	or a,a
	sbc hl,de
	ld hl,.header_zx7
	ld bc,.header_zx7.len
	jr nz,.compress_generic
	ld hl,.header_crx
	ld bc,.header_crx.len
.compress_generic:
	ld (ix-3),hl
	ld (ix-6),bc
	pop de,bc,hl
	

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
	push de,bc ; push compressed data pointer, file descriptor
	ld bc,(ix-6)
	add hl,bc
	inc hl
	inc hl
	push hl ; push compressed length + header length + decompressed length word
	call bos.fs_SetSize ; resize the output file
	jp c,.failed_to_create_file ; fail if failed to resize
	pop bc,de,de ; pop compressed length, old file descriptor, compressed data pointer
	push hl ; push file descriptor from fs_SetSize

.write_file_entry:
; save for later
	push bc ; push compressed data length
	push de ; push compressed/decompressed data (file write data) (pixelShadow)

; write header
	ld bc,0
	push bc,hl ; push file write offset, file descriptor
	ld c,1
	push bc ; push 8-bit value 1 (write count)
	ld bc,(ix-6)
	push bc ; push header length
	ld bc,(ix-3)
	push bc ; push header data
	call bos.fs_Write
	jr c,.write_error
	pop bc,bc,bc,bc,bc

; write decompressed length
	ld bc,(ix-6)
	push bc,hl ; push file write offset, file descriptor
	ld bc,1
	push bc ; push write count
	ld c,2
	push bc ; push write length
	pea ix-9 ; push write data (original file length)
	call bos.fs_Write
	pop bc,bc,bc,bc,bc

; restore from earlier
	pop de,bc ; pop compressed data, compressed data length

; write compressed data
	push hl ; push file descriptor
	ld hl,(ix-6)
	inc hl
	inc hl
	ex (sp),hl ; push write offset, pop file descriptor
	push hl ; push file descriptor
	ld l,1
	push hl ; push write count
	push bc,de ; push compressed data length, compressed data
	call bos.fs_Write
	jr c,.write_error
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
.write_error:
	ld hl,.failed_to_write_file
	jp .error_print
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
.failed_to_write_file:
	db "Failed to write to output file.",0
.success_str:
	db "Success. Output: ",0
.bytes_str:
	db "bytes.",0
.header_crx:
	db $18,$06,"CRX",0
.header_crx.len:=$-.header_crx
.header_zx7:
	db "ZX7",0
.header_zx7.len:=$-.header_zx7
