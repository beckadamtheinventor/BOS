
; WIP

; standalone executable example
; some C code
;
; int main(void){ return 0; }
;
; compiled into assembler source
; 
; ezf
;
; entrypoint _main
; section _main, ezsec.execany
;   or a,a
;   sbc hl,hl
;   ret
; end section
;
; end ezf
; 
;
; assembled into an excutable binary
; $7F,$45,$5A,$46
; $06,$00,$00,$00,$00,$00,$08,$00
; $03,$00,$00,$00,$01,$00,$04,$00
; $FF
; $00,$00,$B7,$ED,$62,$C9


; shared object example
; some C code
;
; int printsomething(char *something) {
;     gui_Print(something);
;     return strlen(something);
; }
;
;
; compiled into assembler source
;
; ezf
;
; public _printsomething, "printsomething"
; section _printsomething, ezsec.execany
;   pop bc
;   ex (sp),hl
;   push bc,hl,hl
;   call bos.gui_Print
;   pop bc
;   call ti._strlen
;   pop bc
;   ret
; end section
;
; end ezf
;
; assembled into a shared object
; $7F,$45,$5A,$46
; $05,$1A,$00,$00,$00,$00,$08,$00
; $03,$00,$00,$00,$01,$00,$10,$00
; $FF
; $00,$00,$C1,$E3,$C5,$E5,$E5,$CD,$80,$01,$02,$C1,$CD,$D4,$00,$00,$C1,$C9
; $0E,$70,$72,$69,$6E,$74,$73,$6F,$6D,$65,$74,$68,$69,$6E,$67,$00


; using shared object example
; some C code
; ```
; int main(int argc, char *argv[]){
;    printsomething(argv); //this will need to be included as part of a header file
;    return 0;
; }
; ```
;
; compiled into assembler source
; ```
; ezf
;
; extern _printsomething, "printsomething"
; entrypoint _main 
; section _main, ezsec.execany
;	call ti._frameset0
;	ld ix,(ix+6)
;	ld hl,(ix+3)
;	push hl
;   call _printsomething
;   pop bc
;   or a,a
;   sbc hl,hl
;   pop ix
;	ret
; end section
;
; end ezf
; ```
;
; assembled into a standalone executable with dependency
; $7F,$45,$5A,$46
; $07,$18,$00,$00,$00,$00,$08,$00
; $03,$00,$00,$00,$01,$00,$0D,$00
; $FF
; $00,$00,$C1,$E3,$C5,$E5,$CD,$FF,$FF,$FF,$C1,$B7,$ED,$62,$C9
; $0E,$70,$72,$69,$6E,$74,$73,$6F,$6D,$65,$74,$68,$69,$6E,$67,$00






namespace ezsec
define ezsec? ezsec
?END?           := $FF ;end of sections table
virtual at 0
	?NONE?      rb 1   ;unused section.
	?BSS?       rb 1   ;unitialized data section. Allocates RAM.
	?EXECANY?   rb 1   ;standalone executable section that is run without relocation.
	?PRIVATE?   rb 1   ;mark a section as private for internal use. Anything relative to the code has to be marked public, private, or extern.
	?PUBLIC?    rb 1   ;mark a section as public for internal and external use.
	?EXTERN?    rb 1   ;locate and load an external section by reference.
	?ENTRY?     rb 1   ;mark a section as the program entry point, aka main function.
	?RODATA?    rb 1   ;readonly data section relocated into flash.
	?ROEXEC?    rb 1   ;readonly executable section relocated into flash.
	?ROTHREAD?  rb 1   ;readonly thread executable section relocated into flash.
	?RWDATA?    rb 1   ;writable data section relocated into RAM.
	?RWEXEC?    rb 1   ;writable executable section relocated into RAM.
	?RWTHREAD?  rb 1   ;writable thread executable section relocated into RAM.
end virtual
end namespace

macro ezf?
	local _ezf
	_ezf.numexterns = 0
	_ezf.numpublics = 0
	_ezf.numprivates = 0

	macro @ez80.word size*, value*
		local value, address
		address = $-$$
		if value >= $01000000 ; relocatable label
			virtual _ezf.relocation_offsets
				dw address, value and $FFFF
			end virtual
			@ez80.word 3, $FFFFFF
		else
			@ez80.word 3, value
		end if
	end macro

	virtual at 0
		db $7F,"EZF"
		load _ezf.header: $-$$ from $$
	end virtual
	virtual at 4
		_ezf.externs_table::
	end virtual
	virtual at _ezf.externs_table.end
		_ezf.publics_table::
	end virtual
	virtual at _ezf.publics_table.end
		_ezf.privates_table::
	end virtual
	virtual at _ezf.privates_table.end
		_ezf.program_table::
	end virtual
	virtual at _ezf.sections_data.end
		_ezf.relocation_offsets::
	end virtual
	virtual at _ezf.relocation_offsets.end
		_ezf.function_names::
	end virtual
	virtual at _ezf.program_table.end 

	macro entrypoint? sectionlabel
		virtual _ezf.program_table
			db ezsec.entry
			db 3 dup 0
			dw sectionlabel.header
			dw 8
			sectionlabel._headerend:
		end virtual
	end macro

	macro private? sectionlabel
		_ezf.numprivates = _ezf.numprivates + 1
		sectionlabel := $01000000 + _ezf.numprivates
		virtual _ezf.privates_table
			db ezsec.private
			db 3 dup $FF
			dw sectionlabel.header
			dw sectionlabel.sectionsource
		end virtual
	end macro

	macro public? sectionlabel, sectionname
		_ezf.numpublics = _ezf.numpublics + 1
		sectionlabel := $02000000 + _ezf.numpublics
		virtual _ezf.function_names
			sectionlabel.nameloc:
			db sectionname, 0
		end virtual
		virtual _ezf.publics_table
			sectionlabel.headerloc:
			db ezsec.public
			dw sectionlabel.nameloc
			assert lengthof sectionname < $100
			db lengthof sectionname
			dw sectionlabel.header
			dw sectionlabel.sectionsource
			sectionlabel._headerend:
		end virtual
	end macro

	macro extern? sectionlabel, sectionname
		_ezf.numexterns = _ezf.numexterns + 1
		sectionlabel := $03000000
		virtual _ezf.function_names
			sectionlabel.externnameloc:
			db sectionname, 0
		end virtual
		sectionlabel.isextern = 1
		virtual _ezf.externs_table
			db ezsec.extern
			dw sectionlabel.externnameloc
			assert lengthof sectionname < $100
			db lengthof sectionname
			sectionlabel.jump:
			jp $FFFFFF
			sectionlabel._headerend:
		end virtual
	end macro

	macro uninitialized?.section? sectionlabel, sectionsize
		section sectionlabel, ezsec.bss, sectionsize
		end section
	end macro

	macro section? sectionlabel, sectiontype, sectionsize:0
		virtual _ezf.program_table
			sectionlabel.header:
			db sectiontype
			db $FF
			dw sectionlabel.relocations_offset
			dw sectionlabel.sectionsource_offset
			if sectionsize = 0
				dw sectionlabel.sectionsize
			else
				assert sectionsize < $10000
				dw sectionsize
			end if
			sectionlabel.headerend:
		end virtual
		virtual _ezf.relocation_offsets
			sectionlabel.relocations_offset = $
		end virtual
		sectionlabel.sectionsource:
		virtual at 0
		macro end?.section?
			sectionlabel.sectionsize = $-$$
			load sectionlabel.sectiondata: $-$$ from $$
			end virtual
			virtual _ezf.relocation_offsets
				dw $FFFF
				sectionlabel.relocations_end = $
			end virtual
			sectionlabel.sectionsource_offset = $
			db sectionlabel.sectiondata
			sectionlabel.end = $
			restore @ez80.word
			purge end?.section?
		end macro
	end macro


	macro end?.ezf?
			_ezf.sections_data.end:
			load _ezf.sections_data: $-$$ from $$
		end virtual

		virtual _ezf.publics_table
			_ezf.publics_table.end:
			load _ezf.publics_table.data: $-$$ from $$
		end virtual
		virtual _ezf.privates_table
			_ezf.privates_table.end:
			load _ezf.privates_table.data: $-$$ from $$
		end virtual
		virtual _ezf.externs_table
			_ezf.externs_table.end:
			load _ezf.externs_table.data: $-$$ from $$
		end virtual
		virtual _ezf.program_table
			db $FF
			_ezf.program_table.end:
			load _ezf.program_table.data: $-$$ from $$
		end virtual
		virtual _ezf.function_names
			_ezf.function_names.end:
			load _ezf.function_names.data: $-$$ from $$
		end virtual
		virtual _ezf.relocation_offsets
			_ezf.relocation_offsets.end:
			load _ezf.relocation_offsets.data: $-$$ from $$
		end virtual
		db _ezf.header
		db _ezf.externs_table.data
		db _ezf.publics_table.data
		db _ezf.privates_table.data
		db _ezf.program_table.data
		db _ezf.sections_data
		db _ezf.relocation_offsets.data
		db _ezf.function_names.data
		purge end?.ezf?
	end macro
end macro
