

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

fb_readonly   := 0
fb_hidden     := 1
fb_system     := 2
fb_volume     := 3
fb_subdir     := 4
fb_archive    := 5
fb_device     := 6


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

	macro fs_dir? flabel
		fs_file flabel
		fs_entry flabel, ".", "", f_subdir
		macro end?.fs_dir?
			end fs_file
			purge end?.fs_dir
		end macro
	end macro

	macro fs_file? flabel
		flabel := $
		macro end?.fs_file?
			flabel.len := $ - flabel
			db $200-(flabel.len and $1FF) dup $FF
			purge end?.fs_file?
		end macro
	end macro

	macro end?.fs_fs?
		purge end?.fs_fs?
		purge fs_entry?
		purge fs_dir?
		purge fs_file?
	end macro
end macro

