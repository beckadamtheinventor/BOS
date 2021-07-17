
;@DOES join two filesystem paths
;@INPUT char *fs_JoinPath(const char *path1, const char *path2);
;@OUTPUT hl = resultant path.
;@OUTPUT Cf set, hl = -1 if failed
fs_JoinPath:
	ld hl,-12
	call ti._frameset
	ld hl,(ix+6)
	ld (ix-9),hl
	ld a,(hl)
	or a,a
	jq z,fs_AbsPath.fail
	ld de,(ix+9)
	ld (ix-12),de
	ld a,(de)
	or a,a
	jq z,fs_AbsPath.fail
	jq fs_AbsPath.entry
