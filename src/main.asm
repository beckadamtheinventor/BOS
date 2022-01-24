
include 'include/ti84pceg.inc'
include 'include/ez80.inc'
include 'include/defines.inc'
include 'include/macros.inc'
include 'include/ezf.inc'

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

fs_drive_a_data_compressed_bin := $+4 ; this MUST be at the end of the OS data, so we can write the filesystem data directly following. The +4 is important.
