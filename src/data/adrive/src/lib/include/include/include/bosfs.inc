
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



macro fs_fs? @clustersize, @cmap_size
	local fs
	fs.base = $
	fs.clustersize = @clustersize
	fs.cmap_size = @cmap_size shl 9
	virtual
		fs.exports.cmap::
		dd $F0FFFFF0, $0FFFFFFF, $0FFFFFFF
	end virtual
	db fs.cmap
	db fs.cmap_size - (fs.cmap_len and (fs.cmap_size-1)) dup $FF
	db fs.cmap
	db fs.cmap_size - (fs.cmap_len and (fs.cmap_size-1)) dup $FF
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
				if file.len > (fs.clustersize shl 9)
					local num
					num = ($-$$) shr 2
					repeat file.len / (fs.clustersize shl 9)
						num = num + 1
						dd num
					end repeat
				end if
				dd $0FFFFFFF
			end virtual
			virtual _#fsname.exports.entries
				pad_db @@name, ' ', 8
				pad_db @@ext, ' ', 3
				db @@prop
				db 8 dup 0
				dw (((file.start+(fs.clustersize shl 9)-fs.clusters_section) / (fs.clustersize shl 25)) and $FFFF)
				db 4 dup 0
				dw (((file.start+(fs.clustersize shl 9)-fs.clusters_section) / (fs.clustersize shl 9)) and $FFFF)
				dd file.len
			end virtual
			esc virtual
			macro end?.fs_file?
				purge end?.fs_file?
				load file.data:$-$$ from $$
				end virtual
				db file.data
				file.end = $
				file.len = $ - file.start
				db ( (fs.clustersize shl 9) - ( file.len and ((fs.clustersize shl 9) - 1) ) ) dup $FF
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

