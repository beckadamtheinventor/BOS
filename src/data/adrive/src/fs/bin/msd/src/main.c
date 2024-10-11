typedef struct global global_t;
#define usb_callback_data_t global_t
#define fat_callback_usr_t msd_t

#include <usbdrvce.h>
#include <msddrvce.h>
#include <fatdrvce.h>
#include <tice.h>
#include <bos.h>

#include <stdio.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>

#define isDirectory(entry) (((uint8_t*)(entry))[0xB] & (1<<4))
#define O_8X_VAR_TYPE 59
#define O_8X_VAR_NAME 60

#define MAX_PARTITIONS 10
#define GUI_LIST_LEN 24

struct global
{
    usb_device_t usb;
    msd_t msd;
};

enum { USB_RETRY_INIT = USB_USER_ERROR };

enum {
	TT_COPY = 0,
	TT_BPK,
	TT_8X,
};

static usb_error_t handleUsbEvent(usb_event_t event, void *event_data,
                                  usb_callback_data_t *global)
{
    switch (event)
    {
        case USB_DEVICE_DISCONNECTED_EVENT:
            gui_PrintLine("usb device disconnected");
            if (global->usb)
                msd_Close(&global->msd);
            global->usb = NULL;
            break;
        case USB_DEVICE_CONNECTED_EVENT:
            gui_PrintLine("usb device connected");
            return usb_ResetDevice(event_data);
        case USB_DEVICE_ENABLED_EVENT:
            gui_PrintLine("usb device enabled");
            global->usb = event_data;
            break;
        case USB_DEVICE_DISABLED_EVENT:
            gui_PrintLine("usb device disabled");
            return USB_RETRY_INIT;
        default:
            break;
    }

    return USB_SUCCESS;
}


bool checkIs8xVar(const char *path) {
	char *ext, *base;
	base = fs_BaseName(path);
	sys_Free(base); //memory isnt mangled until next malloc anyways
	if (ext = strchr(base, '.')) {
		if (!strncmp(ext, ".8x", 3)) return true;
		if (!strncmp(ext, ".8X", 3)) return true;
	}
	return false;
}

bool transfer_file(fat_t *fat, const char *src, const char *dest, bool send, uint8_t type) {
	fat_file_t srcfile;
    fat_file_t destfile;
	uint8_t sector_buffer[FAT_BLOCK_SIZE];
	void *srcfd, *destfd;
    fat_error_t faterr;
	gui_Print("Transferring ");
	gui_Print(src);
	gui_Print(" to ");
	gui_Print(dest);
	_NewLine();
	if (send) {
		char *path = fs_ParentDir(dest);
		char *base = &dest[strlen(path)+1];
		uint24_t srclen = fs_GetFDLen(srcfd);
		uint24_t sectors = srclen / FAT_BLOCK_SIZE;
		uint8_t *srcptr = fs_GetFDPtr(srcfd);
		if (srclen % FAT_BLOCK_SIZE) sectors++;
		for (char *ptr = path; *ptr; ptr++) {
			if ((unsigned)(*ptr - 'a') < 26) *ptr ^= 0x20;
		}
		srcfd = fs_OpenFile(src);
		if (srcfd == -1) {
			source_file_missing:;
			gui_PrintLine("source file not found!");
			return 0;
		}
		fat_Delete(fat, dest);
		faterr = fat_Create(fat, path, base, 0);
		if (faterr != FAT_SUCCESS) {
			goto destination_file_error;
		}
		faterr = fat_OpenFile(fat, dest, 0, &destfile);
		if (faterr != FAT_SUCCESS) {
			goto destination_file_error;
		}
		if (fat_WriteFile(&destfile, sectors, srcptr) != sectors) {
			fat_Close(&destfile);
			goto write_error;
		}
		fat_Close(&destfile);
	} else {
		uint32_t srclen;
		unsigned int write_offset, i;
		for (char *ptr = src; *ptr; ptr++) {
			if ((unsigned)(*ptr - 'a') < 26) *ptr ^= 0x20;
		}
		faterr = fat_OpenFile(fat, src, 0, &srcfile);
		if (faterr != FAT_SUCCESS) {
			goto source_file_missing;
		}
		srclen = fat_GetFileSize(&srcfile);
		if (srclen > 65536) {
			char *dest2;
			if (fs_AllocChk(srclen) == -1) {
				gui_PrintLine("Not enough space for file.");
				return false;
			}
			if ((destfd = fs_CreateFile(dest, 0, 65536)) == 0) {
				goto destination_file_error;
			}
			dest2 = malloc(strlen(dest)+1);
			strcpy(dest2, dest);
			dest2[strlen(dest2)-1] = '0';
			do {
				unsigned int blocklen = 65536;
				if (srclen < blocklen) {
					blocklen = srclen;
					srclen = 0;
				} else {
					srclen -= blocklen;
				}
				for (i = 0; i < blocklen; i += FAT_BLOCK_SIZE) {
					if (fat_ReadFile(&srcfile, 1, &sector_buffer) != 1) {
						goto read_error;
					}
					if (fs_WriteRaw(&sector_buffer, ((i+512<blocklen)?512:(blocklen-i)), 1, destfd, i) == -1) {
						goto write_error;
					}
				}
				if ((destfd = fs_CreateFile(dest2, 0, blocklen)) == 0) {
					goto destination_file_error;
				}
				dest2[strlen(dest2)-1]++;
			} while (srclen > 0);
			sys_Free(dest2);
		} else {
			if (type == TT_8X || checkIs8xVar(src)) {
				if (fat_ReadFile(&srcfile, 1, &sector_buffer) != 1) {
					goto read_error;
				}
				if (!memcmp(&sector_buffer, "**TI83F*\x1A\x0A", 10)) {
					char *varname = TIVarToPath(&sector_buffer[O_8X_VAR_NAME], sector_buffer[O_8X_VAR_TYPE]);
					char *varpath = fs_JoinPath("/tivars", varname);
					uint8_t nlen = strlen(&sector_buffer[O_8X_VAR_NAME]);
					unsigned int len;
					if (nlen < 8) {
						nlen += 4;
					} else {
						nlen = 11;
					}
					len = *(uint16_t*)&sector_buffer[O_8X_VAR_NAME + nlen + 4];
					sys_Free(varname);
					if (len+nlen > 65534) {
						fat_Close(&srcfile);
						gui_PrintLine("File too large for internal filesystem!");
						return false;
					} else {
						gui_Print("Transferring 8x var to ");
						gui_PrintLine(varpath);
						// Allocate space for the header length byte, header, var size word, and var data
						if ((destfd = fs_CreateFile(varpath, 0, (unsigned int)len + nlen + 1)) == 0) {
							goto destination_file_error;
						}
						sys_Free(varpath);
						// Write header data
						if (fs_WriteRaw(&sector_buffer[O_8X_VAR_TYPE], nlen-1, 1, destfd, 0) == -1)
								goto write_error;
						if (fs_WriteByte(1, destfd, nlen-1) == -1)
								goto write_error;
						// Write the remaining data in the sector buffer
						if (srclen <= FAT_BLOCK_SIZE) {
							write_offset = srclen;
							i = 0xffffffff; // tell the copy loop it doesn't need to copy any more data
						} else {
							write_offset = FAT_BLOCK_SIZE;
							i = FAT_BLOCK_SIZE; // tell the copy loop it starts at file LBA 1
						}
						// Calculate remaining data to write for this sector
						write_offset -= O_8X_VAR_TYPE + nlen + 4;
						if (fs_WriteRaw(&sector_buffer[O_8X_VAR_TYPE + nlen + 4], write_offset, 1, destfd, nlen) == -1)
							goto write_error;
						// Calculate offset in destination file to continue writing additional data
						write_offset += nlen-1;
					}
				}
			} else {
				if ((destfd = fs_CreateFile(dest, 0, (unsigned int)srclen)) == 0) {
					goto destination_file_error;
				}
				i = write_offset = 0;
			}
		}
		if (destfd == -1) {
			destination_file_error:;
			gui_PrintLine("Failed to create destination file!");
			return false;
		}
		// Copy remaining sectors if there are any
		if (i != 0xffffffff) {
			for (; i < (int)srclen; i += FAT_BLOCK_SIZE) {
				if (fat_ReadFile(&srcfile, 1, &sector_buffer) != 1) {
					read_error:;
					fat_Close(&srcfile);
					gui_PrintLine("Read error");
					return false;
				}
				if (fs_WriteRaw(&sector_buffer, ((i+512<srclen)?512:(srclen-i)), 1, destfd, write_offset) == -1) {
					write_error:;
					fat_Close(&srcfile);
					gui_PrintLine("Write error");
					return false;
				}
				write_offset += FAT_BLOCK_SIZE;
			}
		}
		fat_Close(&srcfile);

	}
	return true;
}

unsigned int fat_DirList(fat_t* fat, const char* path, fat_dir_entry_t* entries, unsigned int count, unsigned int offset) {
	fat_dir_t dir;
	if (fat_OpenDir(fat, path, &dir) != FAT_SUCCESS) {
		return 0;
	}
	unsigned int i;
	for (i = 0; i < offset; i++) {
		if (fat_ReadDir(&dir, &entries[0]) != FAT_SUCCESS) {
			i = 0;
			goto end;
		}
	}
	for (i = 0; i < count; i++) {
		if (fat_ReadDir(&dir, &entries[i]) != FAT_SUCCESS) {
			break;
		}
		if (entries[i].name[0] == 0) {
			break;
		}
	}
	end:;
	fat_CloseDir(&dir);
	return i;
}

int main(int argc, char *argv[]) {
    static msd_partition_t partitions[MAX_PARTITIONS];
    static global_t global;
    static fat_t fat;
    uint8_t num_partitions;
    msd_info_t msdinfo;
    usb_error_t usberr;
    msd_error_t msderr;
    fat_error_t faterr;
	uint8_t key;
	bool errored = false;

	if (argc > 1 && !strcmp(argv[1], "-h")) {
		gui_PrintLine("Command-line arguments:\n\t-h\tshow this info\n\t-r\tReceive a file A from msd, writing to B\n\
\t-s\tSend a file A to msd, writing to B\n\t-8x\tReceive an 8x (TI Variable) from usb");
		return 0;
	}

    memset(&global, 0, sizeof(global_t));

    // usb initialization loop; waits for something to be plugged in
	global.usb = NULL;

    // usb initialization loop; waits for something to be plugged in
    do
    {
        global.usb = NULL;

        usberr = usb_Init(handleUsbEvent, &global, NULL, USB_DEFAULT_INIT_FLAGS);
        if (usberr != USB_SUCCESS)
        {
            gui_PrintLine("usb init error.");
            goto usb_error;
        }

        do {

            // break out if a key is pressed
            if (os_GetCSC())
            {
                gui_PrintLine("abort.");
                goto usb_error;
            }
			usb_HandleEvents();
        } while (global.usb == NULL);
    } while (usberr == USB_RETRY_INIT);

    if (usberr != USB_SUCCESS)
    {
        gui_PrintLine("usb enable error.");
        goto usb_error;
    }

    // initialize the msd device
    msderr = msd_Open(&global.msd, global.usb);
    if (msderr != MSD_SUCCESS)
    {
        gui_PrintLine("failed opening msd");
        goto usb_error;
    }

    gui_PrintLine("opened msd");

    // get block count and size
    msderr = msd_Info(&global.msd, &msdinfo);
    if (msderr != MSD_SUCCESS)
    {
        gui_PrintLine("error getting msd info");
        goto msd_error;
    }

    // locate the first fat partition available
    num_partitions = msd_FindPartitions(&global.msd, partitions, MAX_PARTITIONS);
    if (num_partitions < 1)
    {
        gui_PrintLine("no paritions found");
        goto msd_error;
    }

    // attempt to open the first found fat partition
    // it is not required to use a MSD to access a FAT filesystem if the
    // appropriate callbacks are configured.
    for (uint8_t p = 0;;)
    {
        uint32_t base_lba = partitions[p].first_lba;
        fat_callback_usr_t *usr = &global.msd;
        fat_read_callback_t read = &msd_Read;
        fat_write_callback_t write = &msd_Write;

        faterr = fat_Open(&fat, read, write, usr, base_lba);
        if (faterr == FAT_SUCCESS)
        {
            gui_PrintLine("opened fat partition");
            break;
        }

        p++;
        if (p >= num_partitions)
        {
            gui_PrintLine("no suitable patitions");
            goto msd_error;
        }
    
	}

	if (!errored) {
		if (argc > 1) {
			for (int i=1; i<argc;) {
				if (i+2<argc) {
					if (!strcmp(argv[i], "-r")) {
						// recieve file from msd
						gui_PrintLine("Receiving File");
						if (!transfer_file(&fat, argv[i+1], argv[i+2], false, TT_COPY)) {
							transfer_failed:;
							gui_PrintLine("Failed to transfer files.");
							sys_WaitKeyCycle();
							goto fat_error;
						}
					} else if (!strcmp(argv[i], "-s")) {
						// send file to msd
						gui_PrintLine("Sending file");
						if (!transfer_file(&fat, argv[i+1], argv[i+2], true, TT_COPY)) {
							goto transfer_failed;
						}
					}
					i += 3;
					continue;
				}
				if (!strcmp(argv[i], "-8x")) {
					// recieve 8x var
					gui_PrintLine("Receiving 8x file");
					if (!transfer_file(&fat, argv[i+1], NULL, false, TT_8X)) {
						goto transfer_failed;
					}
				} else {
					gui_PrintLine("Unknown argument passed:");
					gui_PrintLine(argv[i]);
				}
				i++;
			}
		} else {
			// otherwise open the GUI
			fat_dir_entry_t msdentries[GUI_LIST_LEN];
			void *fsentries[GUI_LIST_LEN];
			char *namebuffer = sys_Malloc(14);
			char *msdpath;
			char *fspath;
			unsigned int num_entries;
			sk_key_t key;
			uint8_t cursor = 0;
			bool on_internal_fs = false;
			bool redraw = true;
			unsigned int skip_entries = 0;
			namebuffer[13] = 0;
			msdpath = "/";
			fspath = "/";
			do {
				if (on_internal_fs) {
					if (redraw) {
						gui_DrawConsoleWindow("/");
						gui_PrintLine(fspath);
						num_entries = fs_DirList(&fsentries, fspath, GUI_LIST_LEN, skip_entries);
						for (uint8_t i=0; i<num_entries; i++) {
							char *name = fs_CopyFileName(fsentries[i]);
							bosgfx_SetTextPos(2, i+2);
							if (isDirectory(fsentries[i])) // check if entry is a directory
								gui_PrintChar('/');
							gui_Print(name);
							sys_Free(name);
						}
					}
				} else {
					if (redraw) {
						gui_DrawConsoleWindow("MSD/");
						gui_PrintLine(msdpath);
						num_entries = fat_DirList(&fat, msdpath, &msdentries, GUI_LIST_LEN, skip_entries);
						for (uint8_t i=0; i<(GUI_LIST_LEN<num_entries?GUI_LIST_LEN:num_entries); i++) {
							bosgfx_SetTextPos(2, i+2);
							if (msdentries[i].attrib & FAT_DIR) // check if entry is a directory
								gui_PrintChar('/');
							memcpy(namebuffer, &msdentries[i].name, 13);
							gui_Print(namebuffer);
						}
					}
				}
				redraw = false;
				bosgfx_SetTextPos(0, cursor+2);
				gui_PrintLine(">"); // right-facing triangle
				keywait:;
				key = sys_WaitKeyCycle();
				usb_HandleEvents();
				bosgfx_SetTextPos(0, cursor+2);
				gui_PrintChar(' ');
				if (key == sk_Up) {
					if (cursor > 0) cursor--;
					else if (skip_entries > 0) {
						skip_entries--;
						redraw = true;
					}
				} else if (key == sk_Down) {
					if (cursor < GUI_LIST_LEN && cursor < num_entries) cursor++;
					else if (skip_entries < num_entries) {
						skip_entries++;
						redraw = true;
					}
				} else if (key == sk_Enter) {
					char *fnamebuffer;
					if (on_internal_fs) {
						if (isDirectory(fsentries[cursor])) {
							char *tofree, *tofree2;
							redraw = true;
							tofree = fspath;
							fspath = fs_JoinPath(fspath, (tofree2 = fs_CopyFileName(fsentries[cursor])));
							sys_Free(tofree);
							sys_Free(tofree2);
							cursor = skip_entries = 0;
							continue;
						}
					} else {
						if (msdentries[cursor].attrib & FAT_DIR) {
							char *tofree;
							redraw = true;
							if (msdentries[cursor].name[0] == '.') {
								if (msdentries[cursor].name[1] == '.') {
									int l = strlen(msdpath);
									if (l < 2)
										continue;
									for (int i=l; i>=0; --i) {
										if (msdpath[i] == '/') {
											if (i > 0)
												msdpath[i] = 0;
											else
												msdpath[1] = 0;
											break;
										}
									}
									cursor = skip_entries = 0;
								}
								continue;
							}
							tofree = msdpath;
							memcpy(namebuffer, &msdentries[cursor].name, 13);
							msdpath = fs_JoinPath(msdpath, namebuffer);
							sys_Free(tofree);
							cursor = skip_entries = 0;
							continue;
						}
					}
					redraw = true;
					fnamebuffer = sys_Malloc(256);
					gui_DrawConsoleWindow("File to write: (default -> same)");
					if (gui_Input(fnamebuffer, 255)) {
						char *s, *d, *tofree;
						if (on_internal_fs) {
							if (*fnamebuffer) {
								s = fnamebuffer;
							} else {
								s = fs_CopyFileName(fsentries[cursor]);
							}
							memcpy((d = namebuffer), &msdentries[cursor].name, 13);
							d = fs_JoinPath(msdpath, d);
							sys_Free(tofree);
						} else {
							if (*fnamebuffer) {
								d = fnamebuffer;
							} else {
								d = (char*)&msdentries[cursor].name;
							}
							memcpy((s = namebuffer), &msdentries[cursor].name, 13);
							s = fs_JoinPath(msdpath, s);
						}
						if (transfer_file(&fat, s, d, on_internal_fs, TT_COPY)) {
							gui_PrintLine("Transfer completed successfuly.");
						} else {
							gui_PrintLine("Failed to transfer files.");
						}
						sys_WaitKeyCycle();
					}
					sys_Free(fnamebuffer);
				} else if (key == sk_Alpha || key == sk_Window) {
					char *tofree;
					if (on_internal_fs) {
						tofree = fspath;
						fspath = fs_ParentDir(fspath);
						sys_Free(tofree);
					} else {
						tofree = msdpath;
						msdpath = fs_ParentDir(msdpath);
						sys_Free(tofree);
					}
				} else if (key == sk_Mode) {
					on_internal_fs = !on_internal_fs;
				} else if (key != sk_Clear) {
					goto keywait;
				}
			} while (key != sk_Clear);
			sys_Free(namebuffer);
		}
	}
fat_error:
    // close the filesystem
    fat_Close(&fat);

msd_error:
    // close the msd device
    msd_Close(&global.msd);

usb_error:
    // cleanup usb
    usb_Cleanup();

    return 0;
}

