taskbar_item_strings:
	dl .strings
.strings:
	dl .l1, .l2, .l3, .l4, .l5
.l1:
	db "recovery",0
.l2:
	db "back",0
.l3:
	db "file",0
.l4:
	db "options",0
.l5:
	db "cmd",0

options_item_strings:
	dl .strings
	jp explorer_configure_theme
	db 12 dup $C9
	jp run_power_app
.strings:
	dl .l1, .l2, .l3, .l4, .l5
.l1:
	db "power"
.l2:
.l3:
.l4:
	db 0
.l5:
	db "theme",0

quickmenu_item_strings:
	dl .strings
	jp explorer_main.edit_file
	jp explorer_paste_file
	jp explorer_cut_file
	jp explorer_copy_file
	jp explorer_create_new_file
.strings:
	dl .l1, .l2, .l3, .l4, .l5
.l1:
	db "new",0
.l2:
	db "copy",0
.l3:
	db "cut",0
.l4:
	db "paste",0
.l5:
	db "edit",0

explorer_themes_default:
	db "BOS Blue",0,$08,$11,$FF,$07
	db "BOS Green",0,$0C,$03,$AF,$C7
	db "BOS Red",0,$C0,$A0,$E6,$E2
.len := $-.

; input_dir_string:
	; db "Input path on usb to explore.",$A,0
; input_source_string:
	; db "Input file on usb to recieve.",$A,0
; input_dest_string:
	; db "Input destination file in filesystem.",$A,0
; input_program_string:
	; db "Input path to binary on usb to execute.",$A,0
str_ConfirmDelete:
	db "Press enter to confirm deletion.",0
str_PressEnterConfirm:
	db "Press enter to confirm.",0
str_DestinationFilePrompt:
	db "New name? ",0
str_NewFileNamePrompt:
	db "File name? ",0
str_CustomTheme:
	db "Custom Theme",0
; str_UsbRecvExecutable:
	; db "/bin/usbrecv",0
str_OffExecutable:
	db "off",0
; str_UsbRunExecutable:
	; db "/bin/usbrun",0
; str_UpdaterExecutable:
	; db "/bin/updater",0
str_CmdExecutable:
	db "cmd",0
str_ExplorerExecutable:
	db "explorer",0
explorer_config_dir:
	db "/etc/config/explorer",0
explorer_themes_file:
	db "/etc/config/explorer/themes.lst",0
explorer_config_file:
	db "/etc/config/explorer/explorer.cfg",0
explorer_preload_cmd:
	db "cmd -x "
explorer_preload_file:
	db "/etc/config/explorer/prerun.cfg",0

explorer_default_directory:
	db "/home/user",0
str_memeditexe:
	db "memedit",0
str_ceditexe:
	db "cedit",0
str_MissingIconFile:
	db "/etc/explorer/missing.ico"
explorer_background_image_sprite_default:
	db 0
; explorer_extensions_dir:
	; db "/opt/explorer/",0
explorer_dirlist_buffer:
	dl display_items_num_x * display_items_num_y dup 0