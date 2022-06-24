	private	ti.AppVarObj
	private	ti.Arc_Unarc
	private	ti.ChkFindSym
	private	ti.CreateReal
	private	ti.CreateVar
	private	ti.DataSize
	private	ti.DelVarArc
	private	ti.EquObj
	private	ti.Get_Tok_Strng
	private	ti.GroupObj
	private	ti.GroupObj
	private	ti.Mov9ToOP1
	private	ti.OP1
	private	ti.OP3
	private	ti.OPSet0
	private	ti.PopErrorHandler
	private	ti.ProgObj
	private	ti.ProtProgObj
	private	ti.PushErrorHandler
	private	ti.flags
	private	ti.tAns
	private	ti.tExtTok
	private	ti.tRecurn
	private	ti.tVarLst
	private	ti.tVarOut
include 'ti84pceg.inc'

	private ImageObj
	private tVarImage1
	private	varTypeMask
ImageObj := $1A
tVarImage1 := $50
varTypeMask := $3F

	private	DELETE_VAR_NOT_DELETED
	private	DELETE_VAR_DELETED
	private	DELETE_VAR_TRUNCATED
	private	DELETE_VAR_ZEROED
virtual at 0
	DELETE_VAR_NOT_DELETED rb 1
	DELETE_VAR_DELETED     rb 1
	DELETE_VAR_TRUNCATED   rb 1
	DELETE_VAR_ZEROED      rb 1
end virtual

	private	CREATE_VAR_NOT_CREATED
	private	CREATE_VAR_CREATED
	private	CREATE_VAR_RECREATED
virtual at 0
	CREATE_VAR_NOT_CREATED rb 1
	CREATE_VAR_RECREATED   rb 1
	CREATE_VAR_CREATED     rb 1
end virtual

	section	.text
	public	_var_name_cmp
_var_name_cmp:
	pop	bc,de
	ex	(sp),hl
	push	de,bc
.enter:
	ld	a,(hl)
	call	.canon
	ld	c,a
	ld	a,(de)
	call	.canon
	sub	a,c
	ret	nz
	ld	b,8
.loop:
	inc	de
	inc	hl
	ld	a,(de)
	sub	a,(hl)
	ret	nz
	cp	a,(hl)
	ret	z
	djnz	.loop
	ret
.canon:
	and	a,varTypeMask
	cp	a,ti.ProtProgObj
	jq	z,.protProg
	cp	a,ti.GroupObj
	ret	nz
assert ti.GroupObj-2 = ti.AppVarObj
	dec	a
.protProg:
assert ti.ProtProgObj-1 = ti.ProgObj
	dec	a
	ret

	section	.text
	private	_force_delete_var
_force_delete_var:
	push	hl
	call	_get_var_vat_ptr
	ld	iy,ti.flags
	push	af
	call	nc,ti.DelVarArc
	pop	af,hl
	call	ti.Mov9ToOP1
	ld	hl,ti.OP1
	ret

	section	.text
	public	_get_var_vat_ptr
_get_var_vat_ptr:
	pop	de
	ex	(sp),hl
	push	de
.enter:
	call	ti.Mov9ToOP1
	call	ti.ChkFindSym
	ret	nc
	sbc	hl,hl
	inc	hl
	ret

	section	.text
	public	_get_var_data_ptr
_get_var_data_ptr:
	pop	de
	ex	(sp),hl
	push	de
.enter:
	call	_get_var_vat_ptr.enter
	ret	c
	ex	de,hl
	bit	15,bc
	ret	nz
	ex	de,hl
	call	ti.Sym_Prog_non_t_Lst
	jq	z,.named
	ld	c,2
.named:
	ex	de,hl
	ld	de,10
	add	hl,de
	ld	e,c
	add	hl,de
	ret

	section	.text
	public	_get_var_data_size
_get_var_data_size:
	pop	de
	ex	(sp),hl
	push	de
.enter:
	call	_get_var_data_ptr.enter
	ret	c
	call	ti.DataSize
	ex	de,hl
	ret

	section	.text
	public	_delete_var
_delete_var:
	pop	de
	ex	(sp),hl
	push	de
.enter:
	inc	hl
	ld	a,(hl)
	sub	a,' '
assert ~('/'-' '+1) and ('/'-' ')
	and	a,not ('/'-' ')
assert ~DELETE_VAR_NOT_DELETED
	ret	z
	dec	hl
	call	_force_delete_var
	ld	a,(hl)
	and	a,varTypeMask
	cp	a,ti.EquObj
	jq	z,.empty
	inc	hl
	ld	de,(hl)
	ld	hl,ti.tAns
	xor	a,a
	sbc.s	hl,de
	jq	z,.zero
	ld	hl,ti.tVarOut or ti.tRecurn shl 8
	xor	a,a
	sbc	hl,de
	jq	z,.zero
assert DELETE_VAR_DELETED = 1
	inc	a
	ret
.empty:
	sbc	hl,hl
	call	ti.CreateVar
	ld	a,DELETE_VAR_TRUNCATED
	ret
.zero:
	call	ti.CreateReal
	ld	a,DELETE_VAR_ZEROED
	jq	ti.OPSet0

	section	.text
	public	_create_var
_create_var:
	ld	iy,0
	add	iy,sp
assert ~CREATE_VAR_NOT_CREATED
	ld	hl,_arc_unarc_var.return_zero
	call	ti.PushErrorHandler
	ld	hl,(iy+6)
	ld	bc,(iy+9)
	push	hl,bc
	ld	hl,(iy+3)
	call	_force_delete_var
	ld	a,(hl)
	pop	hl
	push	af
	dec	hl
	dec	hl
	call	ti.CreateVar
	inc	bc
	inc	bc
	pop	af,hl
	ldir
	ld	e,c
	rl	e
	inc	e
	call	ti.PopErrorHandler
	ld	a,e
	ret

	section	.text
	public	_arc_unarc_var
_arc_unarc_var:
	pop	de
	ex	(sp),iy
	push	de
.enter:
	ld	a,(de)
	cp	a,'A'
	ret	c
	cp	a,ti.tAns
	ret	z
	ld	hl,.return
	call	ti.PushErrorHandler
	lea	hl,iy
	call	ti.Mov9ToOP1
	ld	iy,ti.flags
	call	ti.Arc_Unarc
	call	ti.PopErrorHandler
	private	_arc_unarc_var.return_zero
.return_zero:
	xor	a,a
.return:
	ret

	section	.text
	public	_get_var_file_name
_get_var_file_name:
	pop	bc,de
	ex	(sp),hl
	push	de,bc
	ld	b,8
	ld	a,(de)
	inc	de
	and	a,varTypeMask
	add	a,a
	ld	(.type),a
	sub	a,ti.ProgObj shl 1
	sub	a,(ti.ProtProgObj-ti.ProgObj+1) shl 1
	jq	c,.named
	sub	a,(ti.AppVarObj-ti.ProtProgObj-1) shl 1
	sub	a,(ti.GroupObj-ti.AppVarObj+1) shl 1
	jq	c,.named
	sub	a,(ImageObj-ti.GroupObj-1) shl 1
	jq	z,.image
	ld	a,(de)
	cp	a,'.'
	jq	z,.namedEnter
	cp	a,ti.tVarLst
	jq	nz,.token
	inc	de
	ld	a,(de)
	cp	a,10
	jq	c,.list
	ld	(hl),$9F
	inc	hl
	ld	(hl),2
	inc	hl
	dec	b
.named:
	ld	a,(de)
.namedEnter:
	or	a,a
	jq	z,.extension
	inc	de
	push	bc
	ld	bc,0
	add	a,a
	ld	c,a
	rl	b
	ld	iy,_var_codepoints
	add	iy,bc
	add	iy,bc
	ld	a,(iy+0)
	ld	(hl),a
	inc	hl
	ld	a,(iy+1)
	ld	(hl),a
	inc	hl
	ld	a,(iy+2)
	or	a,a
	jq	z,.short
	ld	(hl),a
	inc	hl
	ld	a,(iy+3)
	ld	(hl),a
	inc	hl
.short:
	pop	bc
	djnz	.named
	xor	a,a
.extension:
	ld	(hl),'.'
	inc	hl
	ld	(hl),a
	inc	hl
	ld	(hl),'8'
	inc	hl
	ld	(hl),a
	inc	hl
	ld	iy,_var_extensions
	ld	de,(iy)
.type := $-1
	ld	(hl),e
	inc	hl
	ld	(hl),a
	inc	hl
	ld	(hl),d
	inc	hl
	ld	(hl),a
	ld	c,b
	inc	b
.fill:
	inc	hl
	ld	(hl),a
	inc	hl
	ld	(hl),a
	djnz	.fill
	ld	a,13
	sub	a,c
	ret
.image:
	inc	de
	ld	a,(de)
	ld	de,_image_name+1
	add	a,tVarImage1
	ld	(de),a
.list:
	dec	de
.token:
	push	hl
	ex	de,hl
	ld	iy,ti.flags
	call	ti.Get_Tok_Strng
	pop	hl
	ld	de,ti.OP3
	ld	b,8
	jq	.named

	section	.data
	public	_image_name
_image_name:
	db	ti.tExtTok,tVarImage1

	public	_var_extensions
_var_extensions:
	db	"xnxlxmxyxsxpxpci"
	db	"xd____xwxcxl__xw"
	db	"xzxt______xv__cg"
	db	"xn__caxcxnxcxcxc"
	db	"xnxn__puek______"
	db	"________________"

	section	.rodata
	public	_var_codepoints
_var_codepoints:
	dw	$25A0,$0000, $006E,$0000, $0075,$0000, $0076,$0000, $0077,$0000, $D83D,$DF82, $2B06,$0000, $2B07,$0000, $222B,$0000, $00D7,$0000, $25AB,$0000, $208A,$0000, $25AA,$0000, $1D1B,$0000, $1D9F,$0000, $D835,$DDD9
	dw	$221A,$0000, $207B,$00B9, $00B2,$0000, $2220,$0000, $00B0,$0000, $02B3,$0000, $1D40,$0000, $2264,$0000, $2260,$0000, $2265,$0000, $207B,$0000, $1D07,$0000, $2192,$0000, $23E8,$0000, $2191,$0000, $2193,$0000
	dw	$0020,$0000, $0021,$0000, $0022,$0000, $0023,$0000, $0024,$0000, $0025,$0000, $0026,$0000, $0027,$0000, $0028,$0000, $0029,$0000, $2217,$0000, $002B,$0000, $002C,$0000, $2212,$0000, $002E,$0000, $002F,$0000
	dw	$0030,$0000, $0031,$0000, $0032,$0000, $0033,$0000, $0034,$0000, $0035,$0000, $0036,$0000, $0037,$0000, $0038,$0000, $0039,$0000, $003A,$0000, $003B,$0000, $003C,$0000, $003D,$0000, $003E,$0000, $003F,$0000
	dw	$0040,$0000, $0041,$0000, $0042,$0000, $0043,$0000, $0044,$0000, $0045,$0000, $0046,$0000, $0047,$0000, $0048,$0000, $0049,$0000, $004A,$0000, $004B,$0000, $004C,$0000, $004D,$0000, $004E,$0000, $004F,$0000
	dw	$0050,$0000, $0051,$0000, $0052,$0000, $0053,$0000, $0054,$0000, $0055,$0000, $0056,$0000, $0057,$0000, $0058,$0000, $0059,$0000, $005A,$0000, $03B8,$0000, $005C,$0000, $005D,$0000, $005E,$0000, $005F,$0000
	dw	$201B,$0000, $0061,$0000, $0062,$0000, $0063,$0000, $0064,$0000, $0065,$0000, $0066,$0000, $0067,$0000, $0068,$0000, $0069,$0000, $006A,$0000, $006B,$0000, $006C,$0000, $006D,$0000, $006E,$0000, $006F,$0000
	dw	$0070,$0000, $0071,$0000, $0072,$0000, $0073,$0000, $0074,$0000, $0075,$0000, $0076,$0000, $0077,$0000, $0078,$0000, $0079,$0000, $007A,$0000, $007B,$0000, $007C,$0000, $007D,$0000, $007E,$0000, $2338,$0000
	dw	$2080,$0000, $2081,$0000, $2082,$0000, $2083,$0000, $2084,$0000, $2085,$0000, $2086,$0000, $2087,$0000, $2088,$0000, $2089,$0000, $00C1,$0000, $00C0,$0000, $00C2,$0000, $00C4,$0000, $00E1,$0000, $00E0,$0000
	dw	$00E2,$0000, $00E4,$0000, $00C9,$0000, $00C8,$0000, $00CA,$0000, $00CB,$0000, $00E9,$0000, $00E8,$0000, $00EA,$0000, $00EB,$0000, $00CD,$0000, $00CC,$0000, $00CE,$0000, $00CF,$0000, $00ED,$0000, $00EC,$0000
	dw	$00EE,$0000, $00EF,$0000, $00D3,$0000, $00D2,$0000, $00D4,$0000, $00D6,$0000, $00F3,$0000, $00F2,$0000, $00F4,$0000, $00F6,$0000, $00DA,$0000, $00D9,$0000, $00DB,$0000, $00DC,$0000, $00FA,$0000, $00F9,$0000
	dw	$00FB,$0000, $00FC,$0000, $00C7,$0000, $00E7,$0000, $00D1,$0000, $00F1,$0000, $00B4,$0000, $0060,$0000, $00A8,$0000, $00BF,$0000, $00A1,$0000, $03B1,$0000, $03B2,$0000, $03B3,$0000, $2206,$0000, $03B4,$0000
	dw	$03B5,$0000, $005B,$0000, $03BB,$0000, $03BC,$0000, $03C0,$0000, $03C1,$0000, $03A3,$0000, $03C3,$0000, $03C4,$0000, $03D5,$0000, $03A9,$0000, $0078,$0304, $0079,$0304, $02E3,$0000, $2026,$0000, $D83D,$DF80
	dw	$25A0,$0000, $2215,$0000, $2010,$0000, $14BE,$0000, $02DA,$0000, $00B3,$0000, $000A,$0000, $D835,$DC56, $0070,$0302, $03C7,$0000, $D835,$DC05, $D835,$DC52, $029F,$0000, $D835,$DDE1, $2E29,$0000, $D83E,$DC3A
	dw	$2588,$0000, $2191,$20DE, $0041,$20DE, $0061,$20DE, $005F,$0000, $2191,$0332, $0041,$0332, $0061,$0332, $2572,$0000, $D834,$DE0F, $25E5,$0000, $25E3,$0000, $22B8,$0000, $2218,$0000, $22F1,$0000, $D83E,$DC45
	dw	$D83E,$DC47, $2591,$0000, $2074,$0000, $2B06,$0000, $00DF,$0000, $2423,$0000, $2044,$0000, $2B1A,$0000, $1A1E,$0000, $2024,$0000, $25A0,$0000, $25A0,$0000, $25A0,$0000, $25A0,$0000, $25A0,$0000, $25A0,$0000

;	db	$A0,$35,$35,$35,$35,$3D,$06,$07,$2B,$D7,$AB,$8A,$AA,$1B,$9F,$35
;	db	$1A,$7B,$B2,$20,$B0,$B3,$40,$64,$60,$65,$7B,$07,$92,$E8,$91,$93
;	db	$20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$17,$2B,$2C,$12,$2E,$2F
;	db	$30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,$3C,$3D,$3E,$3F
;	db	$40,$41,$42,$43,$44,$45,$46,$47,$48,$49,$4A,$4B,$4C,$4D,$4E,$4F
;	db	$50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$5A,$B8,$5C,$5D,$5E,$5F
;	db	$1B,$61,$62,$63,$64,$65,$66,$67,$68,$69,$6A,$6B,$6C,$6D,$6E,$6F
;	db	$70,$71,$72,$73,$74,$75,$76,$77,$78,$79,$7A,$7B,$7C,$7D,$7E,$38
;	db	$80,$81,$82,$83,$84,$85,$86,$87,$88,$89,$C1,$C0,$C2,$C4,$E1,$E0
;	db	$E2,$E4,$C9,$C8,$CA,$CB,$E9,$E8,$EA,$EB,$CD,$CC,$CE,$CF,$ED,$EC
;	db	$EE,$EF,$D3,$D2,$D4,$D6,$F3,$F2,$F4,$F6,$DA,$D9,$DB,$DC,$FA,$F9
;	db	$FB,$FC,$C7,$E7,$D1,$F1,$B4,$60,$A8,$BF,$A1,$B1,$B2,$B3,$06,$B4
;	db	$B5,$5B,$BB,$BC,$C0,$C1,$A3,$C3,$C4,$D5,$A9,$78,$79,$E3,$26,$3D
;	db	$A0,$15,$10,$BE,$DA,$B3,$0A,$35,$70,$C7,$35,$35,$9F,$35,$29,$3E
;	db	$88,$91,$41,$61,$5F,$91,$41,$61,$72,$34,$E5,$E3,$B8,$18,$F1,$3E
;	db	$3E,$91,$74,$06,$DF,$23,$44,$1A,$1E,$24,$A0,$A0,$A0,$A0,$A0,$A0
;
;	db	$25,$D8,$D8,$D8,$D8,$D8,$2B,$2B,$22,$00,$25,$20,$25,$1D,$1D,$D8
;	db	$22,$20,$00,$22,$00,$02,$1D,$22,$22,$22,$20,$1D,$21,$23,$21,$21
;	db	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$22,$00,$00,$22,$00,$00
;	db	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;	db	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;	db	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$00,$00,$00,$00
;	db	$20,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;	db	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$23
;	db	$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$00,$00,$00,$00,$00,$00
;	db	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;	db	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;	db	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$03,$03,$22,$03
;	db	$03,$00,$03,$03,$03,$03,$03,$03,$03,$03,$03,$00,$00,$02,$20,$D8
;	db	$25,$22,$20,$14,$02,$00,$00,$D8,$00,$03,$D8,$D8,$02,$D8,$2E,$D8
;	db	$25,$21,$00,$00,$00,$21,$00,$00,$25,$D8,$25,$25,$22,$22,$22,$D8
;	db	$D8,$25,$20,$2B,$00,$24,$20,$2B,$1A,$20,$25,$25,$25,$25,$25,$25
;
;	db	$00,$8F,$02,$03,$04,$82,$00,$00,$00,$00,$00,$00,$00,$00,$00,$D9
;	db	$00,$B9,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;	db	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;	db	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;	db	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;	db	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;	db	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;	db	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;	db	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;	db	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;	db	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;	db	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;	db	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$04,$04,$00,$00,$80
;	db	$00,$00,$00,$00,$00,$00,$00,$56,$02,$00,$05,$52,$00,$E1,$00,$3A
;	db	$00,$DE,$DE,$DE,$00,$32,$32,$32,$00,$0F,$00,$00,$00,$00,$00,$45
;	db	$47,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;
;	db	$00,$DC,$DE,$DE,$DE,$DF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$DD
;	db	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;	db	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;	db	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;	db	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;	db	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;	db	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;	db	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;	db	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;	db	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;	db	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;	db	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;	db	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$03,$00,$00,$DF
;	db	$00,$00,$00,$00,$00,$00,$00,$DC,$03,$00,$DC,$DC,$00,$DD,$00,$DC
;	db	$00,$20,$20,$20,$00,$03,$03,$03,$00,$DE,$00,$00,$00,$00,$00,$DC
;	db	$DC,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
