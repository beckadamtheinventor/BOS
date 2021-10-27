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

int main(int argc, char *argv[])
{
	uint8_t sector_buffer[FAT_BLOCK_SIZE];
    static char buffer[212];
    static msd_partition_t partitions[MAX_PARTITIONS];
    static global_t global;
    static fat_t fat;
    uint8_t num_partitions;
    msd_info_t msdinfo;
    usb_error_t usberr;
    msd_error_t msderr;
    fat_error_t faterr;
    fat_file_t srcfile;
    fat_file_t destfile;

    memset(&global, 0, sizeof(global_t));

	if (argc < 3) {
		gui_PrintLine("Usage: msd src dest\n*/PATH is on usb, /path is on local fs.");
		return 0;
	}

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
    num_partitions = msd_FindPartitions(&global.msd, partitions, MAX_PARTITIONS);
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
			gui_PrintString("opened fat partition");
			gui_PrintInt(p);
			gui_NewLine();
            break;
        }
        p++;
        if (p >= num_partitions)
        {
            gui_PrintLine("no fat32 paritions found");
            goto msd_error;
        }
    }

	gui_PrintLine("Transferring Files");
	for (int i = 1; i < argc;) {
		char *src, *dest;
		void *srcfd, *destfd;
		src = argv[i++];
		dest = argv[i++];
		gui_PrintString("Transferring ");
		gui_PrintString(src);
		gui_PrintString(" to ");
		gui_PrintString(dest);
		gui_NewLine();
		if (*src == '*') {
			faterr = fat_Open(&srcfile, &fat, &src[1]);
			if (faterr != FAT_SUCCESS) {
				goto source_file_missing;
			}
		} else {
			srcfd = fs_OpenFile(src);
			if (srcfd == -1) {
				source_file_missing:;
				gui_PrintLine("source file not found!");
				goto fat_error;
			}
		}
		if (*dest == '*') {
			char *d = &dest[1];
			char *path = fs_ParentDir(d);
			char *base = &d[strlen(path)+1];
			fat_Delete(&fat, d);
			faterr = fat_Create(&fat, path, base, FAT_FILE);
			if (faterr != FAT_SUCCESS) {
				goto destination_file_error;
			}
			faterr = fat_Open(&srcfile, &fat, d);
			if (faterr != FAT_SUCCESS) {
				goto destination_file_error;
			}
			if (*src == '*') {
				uint32_t srclen;
				faterr = fat_SetSize(&destfile, (srclen = fat_GetSize(&srcfile)));
				if (faterr != FAT_SUCCESS) {
					goto destination_file_error;
				}
				for (uint32_t i = 0; i < srclen; i += FAT_BLOCK_SIZE) {
					if (fat_Read(&srcfile, 1, &sector_buffer) != 1) {
						read_error:;
						gui_PrintLine("Error reading source file!");
						goto fat_error;
					}
					if (fat_Write(&destfile, 1, &sector_buffer) != 1) {
						write_error:;
						gui_PrintLine("Error writing destination file!");
						goto fat_error;
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
			if (*src = '*') {
				uint32_t srclen = fat_GetSize(&srcfile);
				if (srclen > 65535) {
					gui_PrintLine("File too large for internal filesystem!");
					goto fat_error;
				}
				destfd = fs_CreateFile(dest, 0, srclen);
				if (destfd == -1) {
					destination_file_error:;
					gui_PrintLine("Failed to create destination file!");
					goto fat_error;
				}
				for (uint32_t i = 0; i < srclen; i += FAT_BLOCK_SIZE) {
					if (fat_Read(&srcfile, 1, &sector_buffer) != 1) {
						goto read_error;
					}
					fs_Write(&sector_buffer, 512, 1, destfd, i);
				}
				fat_Close(&srcfile);
			} else {
				fs_WriteNewFile(dest, 0, fs_GetFDPtr(srcfd), fs_GetFDLen(srcfd));
			}
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
