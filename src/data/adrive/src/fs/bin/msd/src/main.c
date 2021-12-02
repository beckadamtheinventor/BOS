typedef struct global global_t;
#define usb_callback_data_t global_t
#define fat_callback_data_t msd_t

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

#define MAX_PARTITIONS 10

struct global
{
    usb_device_t usb;
    msd_t msd;
};

enum { USB_RETRY_INIT = USB_USER_ERROR };

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
            global->usb = event_data;
            gui_PrintLine("usb device enabled");
            break;
        case USB_DEVICE_DISABLED_EVENT:
            gui_PrintLine("usb device disabled");
            return USB_RETRY_INIT;
        default:
            break;
    }

    return USB_SUCCESS;
}

bool transfer_file(fat_t *fat, const char *src, const char *dest) {
	fat_file_t srcfile;
    fat_file_t destfile;
	uint8_t sector_buffer[FAT_BLOCK_SIZE];
	void *srcfd, *destfd;
    fat_error_t faterr;
	gui_Print("Transferring ");
	gui_Print(src);
	gui_Print(" to ");
	gui_Print(dest);
	gui_NewLine();
	if (*src == '*') {
		faterr = fat_Open(&srcfile, fat, &src[1]);
		if (faterr != FAT_SUCCESS) {
			goto source_file_missing;
		}
	} else {
		srcfd = fs_OpenFile(src);
		if (srcfd == -1) {
			source_file_missing:;
			gui_PrintLine("source file not found!");
			return 0;
		}
	}
	if (*dest == '*') {
		char *path = fs_ParentDir(&dest[1]);
		char *base = &dest[strlen(path)+2];
		fat_Delete(fat, &dest[1]);
		faterr = fat_Create(fat, path, base, FAT_FILE);
		if (faterr != FAT_SUCCESS) {
			goto destination_file_error;
		}
		faterr = fat_Open(&destfile, fat, &dest[1]);
		if (faterr != FAT_SUCCESS) {
			goto destination_file_error;
		}
		if (*src == '*') {
			uint32_t srclen;
			faterr = fat_Open(&srcfile, fat, &src[1]);
			if (faterr != FAT_SUCCESS) {
				goto source_file_missing;
			}
			faterr = fat_SetSize(&destfile, (srclen = fat_GetSize(&srcfile)));
			if (faterr != FAT_SUCCESS) {
				goto destination_file_error;
			}
			for (uint32_t i = 0; i < srclen; i += FAT_BLOCK_SIZE) {
				if (fat_Read(&srcfile, 1, &sector_buffer) != 1) {
					read_error:;
					gui_PrintLine("Error reading source file!");
					return 0;
				}
				if (fat_Write(&destfile, 1, &sector_buffer) != 1) {
					write_error:;
					gui_PrintLine("Error writing destination file!");
					return 0;
				}
			}
			fat_Close(&srcfile);
			fat_Close(&destfile);
		} else {
			uint24_t srclen = fs_GetFDLen(srcfd);
			uint24_t sectors = srclen / FAT_BLOCK_SIZE;
			uint8_t *srcptr = fs_GetFDPtr(srcfd);
			if (fat_Write(&destfile, sectors, srcptr) != sectors) {
				goto write_error;
			}
			fat_Close(&destfile);
		}
	} else {
		if (*src == '*') {
			uint32_t srclen = fat_GetSize(&srcfile);
			if (srclen > 65535) {
				gui_PrintLine("File too large for internal filesystem!");
				return 0;
			}
			destfd = fs_CreateFile(dest, 0, (int)srclen);
			if (destfd == -1) {
				destination_file_error:;
				gui_PrintLine("Failed to create destination file!");
				return 0;
			}
			for (int i = 0; i < (int)srclen; i += FAT_BLOCK_SIZE) {
				if (fat_Read(&srcfile, 1, &sector_buffer) != 1) {
					goto read_error;
				}
				if (fs_WriteRaw(&sector_buffer, (i+512<srclen?512:srclen-i), 1, destfd, i) == -1) {
					goto write_error;
				}
			}
			fat_Close(&srcfile);
		} else {
			fs_WriteNewFile(dest, 0, fs_GetFDPtr(srcfd), fs_GetFDLen(srcfd));
		}
	}
	return 1;
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
	bool errored = false;

    memset(&global, 0, sizeof(global_t));

    // usb initialization loop; waits for something to be plugged in
    do
    {
        global.usb = NULL;

        usberr = usb_Init(handleUsbEvent, &global, NULL, USB_DEFAULT_INIT_FLAGS & ~(USB_USE_C_HEAP | USB_USE_OS_HEAP));
        if (usberr != USB_SUCCESS)
        {
            gui_PrintLine("usb init error.");
            goto usb_error;
        }

        while (usberr == USB_SUCCESS)
        {
            if (global.usb != NULL)
                break;

            // break out if a key is pressed
            if (os_GetCSC())
            {
                gui_PrintLine("operation cancelled.");
                goto usb_error;
            }

            usberr = usb_WaitForInterrupt();
        }
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
    num_partitions = msd_FindPartitions(&global.msd, &partitions, MAX_PARTITIONS);
    if (num_partitions < 1)
    {
        gui_PrintLine("no paritions found");
        goto msd_error;
    }

    // attempt to open the first found fat partition
    // it is not required to use a MSD to access a FAT filesystem if the
    // appropriate callbacks are configured.
    fat.read = &msd_Read;
    fat.write = &msd_Write;
    fat.usr = &global.msd;
    for (uint8_t p = 0;;)
    {
        fat.first_lba = partitions[p].first_lba;
        fat.last_lba = partitions[p].last_lba;
        faterr = fat_Init(&fat);
        if (faterr == FAT_SUCCESS)
        {
			gui_Print("opened fat partition");
			gui_PrintInt(p);
			gui_NewLine();
            break;
        }
        p++;
        if (p >= num_partitions)
        {
            gui_PrintLine("no fat32 paritions found");
			errored = true;
            break;
        }
    }

	if (!errored) {
		if (!strcmp(argv[1], "-t")) {
			gui_PrintLine("Transferring Files");
			for (int i = 2; i < argc; i += 2) {
				if (!transfer_file(&fat, argv[i], argv[i+1])) {
					gui_PrintLine("Failed to transfer files.");
					sys_WaitKeyCycle();
					goto fat_error;
				}
			}
		} else {
		// otherwise open the GUI
			fat_dir_entry_t msdentries[16];
			void *fsentries[16];
			char *namebuffer = sys_Malloc(14);
			char *msdpath;
			char *fspath;
			unsigned int num_entries;
			sk_key_t key;
			uint8_t cursor = 0;
			bool on_internal_fs = false;
			unsigned int skip_entries = 0;
			namebuffer[13] = 0;
			msdpath = "/";
			do {
				if (on_internal_fs) {
					gui_DrawConsoleWindow("/");
					num_entries = fs_DirList(&fsentries, fspath, 16, skip_entries);
					for (uint8_t i=0; i<num_entries; i++) {
						char *name = fs_CopyFileName(fsentries[i]);
						bosgfx_SetTextPos(2, i+1);
						if (((uint8_t*)fsentries[i])[0xB] & (1<<4)) // check if entry is a directory
							gui_PrintChar('/');
						gui_Print(name);
						sys_Free(name);
					}
				} else {
					gui_DrawConsoleWindow("MSD/");
					num_entries = fat_DirList(&fat, msdpath, FAT_LIST_ALL, &msdentries, 16, skip_entries);
					for (uint8_t i=0; i<(16<num_entries?16:num_entries); i++) {
						bosgfx_SetTextPos(2, i+1);
						if (msdentries[i].attrib & FAT_DIR) // check if entry is a directory
							gui_PrintChar('/');
						memcpy(namebuffer, &msdentries[i].filename, 13);
						gui_Print(namebuffer);
					}
				}
				bosgfx_SetTextPos(0, cursor+1);
				gui_PrintLine(">"); // right-facing triangle
				key = sys_WaitKeyCycle();
				usb_HandleEvents();
				if (key == sk_Up) {
					if (cursor > 0) cursor--;
					else if (skip_entries > 0) skip_entries--;
				} else if (key == sk_Down) {
					if (cursor < 16 && cursor < num_entries) cursor++;
					else if (skip_entries < num_entries) skip_entries++;
				} else if (key == sk_Enter) {
					char *fnamebuffer = sys_Malloc(256);
					gui_DrawConsoleWindow("File to write:");
					gui_Input(&fnamebuffer[1], 254);
					if (fnamebuffer[1]) {
						char *s, *d, *tofree;
						if (on_internal_fs) {
							s = fnamebuffer+1;
							*fnamebuffer = '*';
							tofree = d = fs_CopyFileName(fsentries[cursor]);
							d = fs_JoinPath(msdpath, d);
							sys_Free(tofree);
						} else {
							d = fnamebuffer+1;
							memcpy((s = namebuffer), &msdentries[cursor].filename, 13);
							tofree = s = fs_JoinPath(msdpath, s);
							s = fs_JoinPath("*", s);
							sys_Free(tofree);
						}
						if (!transfer_file(&fat, s, d)) {
							gui_PrintLine("Failed to transfer files.");
						} else {
							gui_PrintLine("Transfer completed successfuly.");
						}
						sys_WaitKeyCycle();
					}
					sys_Free(fnamebuffer);
				}
			} while (key != sk_Clear);
			sys_Free(namebuffer);
		}
	}
fat_error:
    // close the filesystem
    fat_Deinit(&fat);

msd_error:
    // close the msd device
    msd_Close(&global.msd);

usb_error:
    // cleanup usb
    usb_Cleanup();

    return 0;
}

