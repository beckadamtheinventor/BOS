;@DOES Determine if an OS is backed up.
;@INPUT bool fs_IsOSBackupPresent();
;@OUTPUT true if there is an OS backed up, false otherwise.
fs_IsOSBackupPresent:
	ld a,$FF ; will be SMC'd to 0 upon first install of BOS
	inc a
	ret
