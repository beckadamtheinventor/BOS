
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
; int printsomething(char *something){
;     gui_Print(something);
;     return strlen(something);
; }
;
;
; compiled into assembler source
;
; ezf
;
; export _printsomething, "printsomething"
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
; assembled into an excutable binary
; $7F,$45,$5A,$46
; $05,$1A,$00,$00,$00,$00,$08,$00
; $03,$00,$00,$00,$01,$00,$10,$00
; $FF
; $00,$00,$C1,$E3,$C5,$E5,$E5,$CD,$80,$01,$02,$C1,$CD,$D4,$00,$00,$C1,$C9
; $0E,$00,$70,$72,$69,$6E,$74,$73,$6F,$6D,$65,$74,$68,$69,$6E,$67,$00


; using shared object example
; some C code
; ```
; int main(int args){
;    char *argv = (char*)args; //BOS program arguments are pushed as a string, but this is probably gonna change at some point.
;    printsomething(argv); //this will likely still need to be included as part of a header file
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
;   pop bc
;   ex (sp),hl
;   push bc,hl
;   call _printsomething
;   pop bc
;   or a,a
;   sbc hl,hl
;   ret
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
; $0E,$00,$70,$72,$69,$6E,$74,$73,$6F,$6D,$65,$74,$68,$69,$6E,$67,$00






namespace ezsec
define ezsec? ezsec
?END?           := $FF ;end of sections table
virtual at 0
	?NONE?      rb 1   ;unused section
	?BSS?       rb 1   ;BSS program global unitialized data section
	?STUB?      rb 1   ;stub / data section
	?EXECANY?   rb 1   ;executable anywhere section
	?PUBLIC?    rb 1   ;publicize a section for internal use
	?EXPORT?    rb 1   ;publicize a section for external use
	?ENTRY?     rb 1   ;program entry point
	?EXTERN?    rb 1   ;external section reference
	?IMPORT?    rb 1   ;library import reference
	?ROEXEC?    rb 1   ;readonly executable section
	?RODAT?     rb 1   ;readonly data section
	?RONULL?    rb 1   ;readonly null data section
	?ROTHREAD?  rb 1   ;readonly thread executable section
	?ROLIB?     rb 1   ;readonly external library reference
	?RWEXEC?    rb 1   ;writable executable section
	?RWDAT?     rb 1   ;writable data section
	?RWNULL?    rb 1   ;writable null data section
	?RWTHREAD?  rb 1   ;writable thread executable section
	?RWLIB?     rb 1   ;writable external library reference
end virtual
end namespace

macro ezf?
	local _ezf

	virtual
		db $7F,"EZF"
		load _ezf.header: $-$$ from $$
	end virtual
	virtual at 4
		_ezf.exports_table::
	end virtual
	virtual at _ezf.exports_table.end
		_ezf.publics_table::
	end virtual
	virtual at _ezf.publics_table.end
		_ezf.externs_table::
	end virtual
	virtual at _ezf.externs_table.end
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
			dl 0
			dw sectionlabel.header
			dw 8
			sectionlabel._headerend:
		end virtual
	end macro

	macro public? sectionlabel
		virtual _ezf.publics_table
			db ezsec.public
			dl 0
			dw sectionlabel.header
			dw sectionlabel._pub_relocation_table
		end virtual
		sectionlabel.ispublic = 1
	end macro

	macro export? sectionlabel, sectionname
		virtual _ezf.function_names
			dw lengthof sectionname
			sectionlabel.nameloc:
			db sectionname, 0
		end virtual
		sectionlabel.isexport = 1
		virtual _ezf.exports_table
			sectionlabel.headerloc:
			db ezsec.export
			dl sectionlabel.nameloc
			dw sectionlabel.header
			dw sectionlabel._exp_relocation_table
			sectionlabel._headerend:
		end virtual
	end macro

	macro extern? sectionlabel, sectionname
		virtual _ezf.function_names
			dw lengthof sectionname
			sectionlabel.externnameloc:
			db sectionname, 0
		end virtual
		sectionlabel.isextern = 1
		virtual _ezf.externs_table
			db ezsec.extern
			dl sectionlabel.externnameloc
			dw 0
			dw sectionlabel._ext_relocation_table
			sectionlabel._headerend:
		end virtual
	end macro

	macro section? sectionlabel, sectiontype, sectionaddress:0
		virtual _ezf.program_table
			sectionlabel.header:
			db sectiontype
			dl sectionaddress
			dw sectionlabel.sectionsource_offset
			dw sectionlabel.sectionsize
			sectionlabel.headerend:
		end virtual
		macro @ez80.word? @value*
			local value, address
			value = @value
			if value relativeto sectionaddress
				virtual _ezf.relocation_offsets
					dw $ - $$
				end virtual
				@ez80.word $FFFFFF
			else
				@ez80.word value
			end if
		end macro
		sectionlabel.sectionsource:
		virtual at sectionaddress
		macro end?.section?
			sectionlabel.sectionsize = $-$$
			load sectionlabel.sectiondata: $-$$ from $$
			end virtual
			virtual _ezf.relocation_offsets
				dw $FFFF
			end virtual
			sectionlabel.end:
			sectionlabel.sectionsource_offset = $
			db sectionlabel.sectiondata
			purge end?.section?
		end macro
	end macro


	macro end?.ezf?
			_ezf.sections_data.end:
			load _ezf.sections_data: $-$$ from $$
		end virtual

		virtual _ezf.exports_table
			_ezf.exports_table.end:
			load _ezf.exports_table.data: $-$$ from $$
		end virtual
		virtual _ezf.publics_table
			_ezf.publics_table.end:
			load _ezf.publics_table.data: $-$$ from $$
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
		db _ezf.exports_table.data
		db _ezf.publics_table.data
		db _ezf.externs_table.data
		db _ezf.program_table.data
		db _ezf.sections_data
		db _ezf.relocation_offsets.data
		db _ezf.function_names.data
		purge end?.ezf?
	end macro
end macro
