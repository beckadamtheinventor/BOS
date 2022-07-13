
include "src/include/ez80.inc"
include "src/include/ti84pceg.inc"
include "src/include/bos.inc"

calminstruction (var) strcalc? val
	compute val, val        ; compute expression
	arrange val, val        ; convert result to a decimal token
	stringify val           ; convert decimal token to string
	publish var, val
end calminstruction

virtual at $04E000
	rb bos.fs_sector_size - ($ and (bos.fs_sector_size-1))
	include "src/fs/bin/argv.so.asm"
	rb bos.fs_sector_size - ($ and (bos.fs_sector_size-1))
	include "src/fs/bin/mem.so.asm"
	rb bos.fs_sector_size - ($ and (bos.fs_sector_size-1))
	include "src/fs/bin/numstr.so.asm"
	rb bos.fs_sector_size - ($ and (bos.fs_sector_size-1))
end virtual


_addr_osrt_argv_so strcalc _osrt_argv_so
_addr_osrt_mem_so strcalc _osrt_mem_so
_addr_osrt_numstr_so strcalc _osrt_numstr_so
virtual as "inc"
	db "virtual at $04E000",$A
	db "_osrt_lib_table rb bos.fs_sector_size",$A
	db "end virtual",$A
	db "virtual at ", _addr_osrt_argv_so, $A
	db "osrt.argv_so.version rb 4", $A
	db _routines_osrt_argv_so
	db "end virtual",$A
	db "virtual at ", _addr_osrt_mem_so, $A
	db "osrt.mem_so.version rb 4", $A
	db _routines_osrt_mem_so
	db "end virtual",$A
	db "virtual at ", _addr_osrt_numstr_so, $A
	db "osrt.numstr_so.version rb 4", $A
	db _routines_osrt_numstr_so
	db "end virtual",$A
end virtual

