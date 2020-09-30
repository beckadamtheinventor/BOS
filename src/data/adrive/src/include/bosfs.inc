
macro pad_db? str, pad, amt
	local start
	start = $
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



macro fs_fs? @base
	fs.base = @base
	org fs.base
	virtual
		fs.exports.cmap::
		dd $F0FFFFF0, $0FFFFFFF, $0FFFFFFF
	end virtual
	db fs.cmap
	db $1000 - (fs.cmap_len and $7FF) dup $FF
	db fs.cmap
	db $1000 - (fs.cmap_len and $7FF) dup $FF
	fs.clusters_section:

	macro fs_subdir? fsname
		virtual
			_#fsname.exports.entries::
			db 64 dup $FF
		end virtual
		db _#fsname.entries
		db $400 - (_#fsname.entries_len and $3FF) dup $FF
		macro fs_file? @@name, @@ext, @@prop
			local file
			file.start = $
			virtual fs.exports.cmap
				if file.len > 1024
					local num
					num = $-$$ shr 2
					repeat file.len shr 10
						dd num
						num = num + 1
					end repeat
				end if
				dd $0FFFFFFF
			end virtual
			virtual _#fsname.exports.entries
				pad_db @@name, ' ', 8
				pad_db @@ext, ' ', 3
				db @@prop
				db 8 dup 0
				dw (((file.start-fs.clusters_section) shr 26) and $FFFF)
				db 4 dup 0
				dw (((file.start-fs.clusters_section) shr 10) and $FFFF)
				dd file.len
			end virtual
			macro end?.fs_file?
				purge end?.fs_file?
				file.end = $
				file.len = $ - file.start
				db ( $400 - ( file.len and $3FF ) ) dup $FF
				file.last_sector = $-$$ shr 10
			end macro
		end macro
		macro end?.fs_subdir?
			purge end?.fs_subdir?
			virtual _#fsname.exports.entries
				db 32 dup 0
				_#fsname.entries_len = $-$$
				load _#fsname.entries:$-$$ from $$
			end virtual
		end macro
	end macro

	fs_subdir 0

	macro end?.fs_fs?
		purge end?.fs_fs?
		virtual fs.exports.cmap
			fs.cmap_len = $-$$
			load fs.cmap:$-$$ from $$
		end virtual
		end fs_subdir
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

