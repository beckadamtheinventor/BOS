
macro pad_db? str, pad, amt
	local fstart
	fstart = $
	assert lengthof str <= amt
	db str
	if lengthof str < amt
		db amt - lengthof str dup pad
	end if
end macro

f_readonly   := 1
f_hidden     := 2
f_system     := 4
f_volume     := 8
f_subdir     := $10
f_archive    := $20
f_device     := $40



macro fs_fs?
	local fs
	fs.base = $

	macro fs_entry? fdata, name, ext, prop
		pad_db name, ' ', 8
		pad_db ext, ' ', 3
		db prop
		dw (((fdata - fs.base) shr 9) and $FFFF)
		dw (fdata.len and $FFFF)
	end macro

	macro fs_file? flabel
		flabel := $
		macro end?.fs_file?
			flabel.len := $ - flabel
			db $200-(flabel.len and $1FF) dup $FF
		end macro
	end macro

	macro end?.fs_fs?
		purge end?.fs_fs?
		purge fs_entry?
		purge fs_file?
	end macro
end macro

