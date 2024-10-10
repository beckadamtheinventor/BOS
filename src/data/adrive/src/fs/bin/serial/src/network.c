#include <stdint.h>
#include <stdio.h>
#include <tice.h>
#include <bos.h>
#include <usbdrvce.h>
#include <srldrvce.h>
#include "network.h"

usb_device_t device;
srl_device_t srl;
uint8_t srl_buf[8192];
uint8_t net_buf[4096];
file_header_t incoming_file;
file_header_t outgoing_file;
uint8_t *incoming_data = NULL;
bool network_up = false;

void ntwk_process(void) {
	static size_t len = 0;

	/* Only read if the device is connected */
	usb_process();
	if (network_up) {
		if (len > 0) {
				if (usb_read_to_size(len)) {
					conn_HandleInput(&net_buf, len);
					len = 0;
				}
		} else {
			if (usb_read_to_size(3)) {
				len = *(size_t*)&net_buf;
			}
		}
	}
}

bool ntwk_send(uint8_t ctrl, uint8_t *data, size_t len) {
	uint8_t i;
	unsigned int total_len;

	if(!network_up) return false;

	total_len = len + (sizeof(ctrl));
	usb_write(&total_len, (sizeof(total_len)));
	usb_write(&ctrl, (sizeof(ctrl)));
	usb_write(data, len);
	return true;
}

void conn_HandleInput(packet_t *in_buff, size_t buff_size) {
	uint8_t *data = &in_buff->data;
	size_t data_size = buff_size-1;
	char *file_name;
	unsigned int len;
	if (incoming_data == NULL) {
		incoming_data = sys_Malloc(incoming_data_buffer_len);
	}
	switch (in_buff->control) {
		case 0: // incoming message
			if (data[0] == 0x01) {
				gui_DrawConsoleWindow(&data[1]);
			} else {
				gui_PrintLine(data);
			}
			break;
		case 1: // incoming file header
			sys_Free(incoming_file.name);
			len = strlen((file_name = &data[3])) + 1;
			incoming_file.len = *(unsigned int *)data;
			incoming_file.current_len = 0;
			if ((incoming_file.name = sys_Malloc(len)) == NULL) {
				malloc_error();
			} else {
				memcpy(incoming_file.name, file_name, len);
				if ((incoming_file.fd = fs_OpenFile(incoming_file.name)) != -1) {
					if (!(fs_DeleteFile(incoming_file.name))) {
						goto sendError;
					}
				}
				gui_Print("Creating file: ");
				gui_PrintLine(incoming_file.name);
				if ((incoming_file.fd = fs_CreateFile(incoming_file.name, 0, incoming_file.len)) == NULL) {
					goto sendError;
				}
			}
			ntwk_send(4, -1, 1); // acknowledge that we've created the file
			break;
		case 2: // incoming file data section
			len = (incoming_file.current_len + incoming_data_buffer_len > incoming_file.len) ?
				(incoming_file.len - incoming_file.current_len) : incoming_data_buffer_len;
			if (fs_WriteRaw(data, len, 1, incoming_file.fd, incoming_file.current_len) == -1) {
				gui_Print("Failed to write data to FD: ");
				gui_PrintInt((int)incoming_file.fd);
				gui_Print("\nOffset: ");
				gui_PrintInt(incoming_file.current_len);
				_NewLine();
				goto sendError;
			}
			incoming_file.current_len += len;
			ntwk_send(4, -1, 1); // acknowledge that we've written the received block
			break;
		case 3: // request file
			sys_Free(outgoing_file.name);
			len = strlen((file_name = data)) + 1;
			outgoing_file.current_len = 0;
			if (!(outgoing_file.name = sys_Malloc(len))) {
				malloc_error();
			} else {
				uint8_t *tmp;
				memcpy(outgoing_file.name, file_name, len);
				if (!(outgoing_file.fd = fs_OpenFile(outgoing_file.name))) {
					gui_PrintLine("Error: Requested outgoing file not found. Aborting transfer.");
					ntwk_send(0, PS_STR("Error: File not found."));
				}
				outgoing_file.ptr = fs_GetFDPtr(outgoing_file.fd);
				outgoing_file.len = fs_GetFDLen(outgoing_file.fd);
				if (!(tmp = sys_Malloc((len = strlen(outgoing_file.name)+4)))) {
					malloc_error();
					break;
				}
				ntwk_send(1, &outgoing_file.len, 3);
				do {
					memcpy(incoming_data, outgoing_file.ptr, incoming_data_buffer_len);
					outgoing_file.ptr += incoming_data_buffer_len;
					ntwk_send(2, PS_PTR(incoming_data, incoming_data_buffer_len));
					len = outgoing_file.current_len + incoming_data_buffer_len > outgoing_file.len ? outgoing_file.len - outgoing_file.current_len : incoming_data_buffer_len;
					outgoing_file.current_len += len;
				} while (outgoing_file.current_len < outgoing_file.len);
			}
			break;
		case 5: // directory list
			{
				void *fdbuffer;
				unsigned int skip = 0;
				gui_DrawConsoleWindow(data);
				while (fs_DirList(&fdbuffer, data, 1, skip++)) {
					char *fname = fs_CopyFileName(fdbuffer);
					gui_PrintLine(fname);
					ntwk_send(0, PS_STR(fname));
					sys_Free(fname);
				}
			}
			break;
		case 6: // incoming directory
			sys_Free(incoming_file.name);
			len = strlen((file_name = data)) + 1;
			incoming_file.current_len = 0;
			if (!(outgoing_file.name = sys_Malloc(len))) {
				malloc_error();
			} else {
				fs_CreateDir(data, 0x10);
			}
			break;
		case 7: // preparing for long file block
			len = *(unsigned int*)data;
			if (fs_AllocChk(len) == -1) {
				fs_GarbageCollect();
				if (fs_AllocChk(len) == -1) {
					const char *str = "Failed to allocate long file block.";
					gui_PrintLine(str);
					gui_Print("Not enough space for ");
					gui_PrintInt(len);
					gui_PrintLine(" bytes");
					ntwk_send(0, PS_STR(str));
				}
			}
			break;
		case 10: // requested ROM dump
			{
				uintptr_t ptr = 0;
				len = 0x400000;
				ntwk_send(1, &len, 3);
				do {
					memcpy(incoming_data, ptr, incoming_data_buffer_len);
					ntwk_send(2, incoming_data, incoming_data_buffer_len);
					ptr += incoming_data_buffer_len;
					
				} while (ptr < len);
			}
			break;
		default:
			gui_PrintLine("Unknown/invalid packet recieved.");
			ntwk_send(0, PS_STR("Unknown/invalid packet recieved."));
			break;
	}
	return;
	sendError:; // respond to host with error
	gui_PrintLine("Send Error.");
	ntwk_send(5, -1, 1);
}

void malloc_error(void) {
	const char *str = "Error: Out of malloc memory. Aborting transfer.";
	gui_PrintLine(str);
	ntwk_send(0, PS_STR(str));
}

bool init_usb(void) {
	usb_error_t usb_error;
    srl_error_t srl_error;
    sk_key_t key = 0;
    network_up = false;
    usb_error = usb_Init(handle_usb_event, NULL, srl_GetCDCStandardDescriptors(), USB_DEFAULT_INIT_FLAGS);
    do {
        usb_HandleEvents();
        key = os_GetCSC();
    } while((!device) && (key!= sk_Clear));
    if(!device) {
        gui_PrintLine("no device");
        os_GetKey();
        return false;
    }
    srl_error = srl_Open(&srl, device, srl_buf, sizeof(srl_buf), SRL_INTERFACE_ANY, 115200);
    if(srl_error) {
        gui_PrintLine("srl error");
        os_GetKey();
        return false;
    }
    network_up = true;
	return true;
}

/* Handle USB events */
static usb_error_t handle_usb_event(usb_event_t event, void *event_data,
                                    usb_callback_data_t *callback_data) {
    usb_error_t err;
    /* Delegate to srl USB callback */
    if ((err = srl_UsbEventCallback(event, event_data, callback_data)) != USB_SUCCESS)
        return err; 
    /* Enable newly connected devices */
    if(event == USB_DEVICE_CONNECTED_EVENT && !(usb_GetRole() & USB_ROLE_DEVICE)) {
        usb_device_t device = event_data;
        gui_PrintLine("device connected\n");
        usb_ResetDevice(device);
    }
    if(event == USB_HOST_CONFIGURE_EVENT) {
        usb_device_t host = usb_FindDevice(NULL, NULL, USB_SKIP_HUBS);
        if(host) device = host;
    }
    /* When a device is connected, or when connected to a computer */
    if((event == USB_DEVICE_ENABLED_EVENT && !(usb_GetRole() & USB_ROLE_DEVICE))) {
        device = event_data;
    }
    if(event == USB_DEVICE_DISCONNECTED_EVENT) {
        srl_Close(&srl);
        network_up = false;
        device = NULL;
    }

    return USB_SUCCESS;
}

bool usb_read_to_size(size_t size) {
	static unsigned int bytes_read = 0;
	bytes_read += srl_Read(&srl, &net_buf[bytes_read], size - bytes_read);
	if(bytes_read >= size) {bytes_read = 0; return true;}
	else return false;
}
