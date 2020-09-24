
macro pad_db? str, pad, amt
	local start
	start = $
	db str, amt-(start-$) dup pad
end macro

f_readonly   := 1
f_hidden     := 2
f_system     := 4
f_volume     := 8
f_subdir     := $10
f_archive    := $20
f_device     := $40

macro fs_file? name, ext, prop
	local file_start, file_end
	pad_db name, ' ', 8
	pad_db ext, ' ', 3
	db prop
	db 8 dup 0
	dw ((file_start shr 9) and $FFFF)
	db 4 dup 0
	dw ((file_start shr 25) and $FFFF)
	dd file_end - file_start
	file_start = $
	macro end?.fs_file?
		file_end = $
		db ( $200 - ( $ and $1FF ) ) dup $FF
		purge end?.fs_file?
	end macro
end macro

calminstruction (var) strcalc? val
	compute val, val        ; compute expression
	arrange val, val        ; convert result to a decimal token
	stringify val           ; convert decimal token to string
	publish var, val
end calminstruction

macro display_sector? name, addr
	local addrstr
	addrstr strcalc addr shr 9
	display '"',name,'" LBA: ',addrstr,$A
end macro

