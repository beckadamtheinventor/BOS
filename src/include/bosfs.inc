

macro pad_db? str, pad, amt
	local fstart
	fstart = $
	assert lengthof str <= amt
	db str
	if lengthof str < amt
		db amt - lengthof str dup pad
	end if
end macro

f_hidden     := 2
f_system     := 4
f_subfile    := 8
f_subdir     := $10
f_device     := $20
f_link       := $40
f_elevated   := $80

fb_hidden     := 1
fb_system     := 2
fb_subfile    := 3
fb_subdir     := 4
fb_device     := 5
fb_link       := 6
fb_elevated   := 7

macro fs_fs? fsbase
	local fs
	fs.base = fsbase

	macro fs_sfentry? fdata, name, ext, prop
		pad_db name, ' ', 8
		pad_db ext, ' ', 3
		db prop
		fdata.offset = fdata - ($ and not $3F)
		assert fdata.offset < 65536
		dw fdata.offset
		assert fdata.len < 65536
		dw fdata.len
	end macro

	macro fs_entry? fdata, name, ext, prop
		assert ((fdata - fs.base) shr 6) < 65536
		assert fdata.len < 65536
		pad_db name, ' ', 8
		pad_db ext, ' ', 3
		db prop
		dw (fdata - fs.base) shr 6
		dw fdata.len
	end macro

;	macro fs_link? entryptr, name, ext, prop
;		
;	end macro

	macro fs_longentry? fdata, name, prop
		assert ((fdata - fs.base) shr 6) < 65536
		assert fdata.len < 65536
		db $F1,lengthof name,9 dup 0,prop
		dw (fdata-fs.base) shr 6
		dw fdata.len
		fdata.namestart:
		db name,0
		db $10 - (($ - fdata.namestart) and $F) dup 0
	end macro

	macro fs_dir? flabel
		fs_file flabel
		macro end?.fs_dir?
			if ($ and $FF) >= $F0
				db $10 dup $FF
			end if
			db ($F0 - ($ and $FF)) dup $FF
			db $FE, 15 dup $FF
			end fs_file
			purge end?.fs_dir
		end macro
	end macro

	macro fs_file? flabel
		if $ and $3F > 0
			db $40 - ($ and $3F) dup $FF
		end if
		flabel := $
		macro end?.fs_file?
			flabel.len := $ - flabel
			if $ and $3F > 0
				db ($40-($ and $3F)) dup $FF
			end if
			purge end?.fs_file?
		end macro
	end macro

	macro fs_subfile? flabel, base:0
		flabel := $
		macro end?.fs_subfile?
			flabel.len := $ - flabel
			purge end?.fs_subfile?
		end macro
	end macro

	macro end?.fs_fs?
		purge end?.fs_fs?
		purge fs_entry?
		purge fs_dir?
		purge fs_file?
		purge fs_subfile?
	end macro
end macro

