
include 'include/ti84pceg.inc'
include 'include/ez80.inc'
include 'include/defines.inc'
include 'include/macros.inc'
include 'include/ezf.inc'
include 'include/bosfs.inc'

org $020108

include 'table.asm'
include 'boot.asm'
include 'threading.inc'
include 'gfx.inc'
include 'str.inc'
include 'sys.inc'
include 'util.inc'
include 'fs.inc'
include 'gui.inc'
include 'compatibility.inc'
include 'math.inc'
include 'data.inc'

macro exaf
	db $08 ;why does the comma in ex af,af' have to screw with things? >_>
end macro

calminstruction (var) strcalc? val
	compute val, val        ; compute expression
	arrange val, val        ; convert result to a decimal token
	stringify val           ; convert decimal token to string
	publish var, val
end calminstruction

MAIN_CODE_LENGTH strcalc $-$$

fs_drive_a_data_compressed_bin := $+4 ; this MUST be at the end of the OS data, so we can write the filesystem data directly following. The +4 is important.


display "OS code size: ",MAIN_CODE_LENGTH,$A,$A
