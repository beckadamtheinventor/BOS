
/**
 * A minimal serial file transfer program for BOS.
 * by Adam "beckadamtheinventor" Beckingham
 */


/* Keep these headers */
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <tice.h>

#include <bos.h>

/* Standard headers - it's recommended to leave them included */
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


#include <usbdrvce.h>
#include <srldrvce.h>

#include "network/network.h"

int main(void)
{
	if(init_usb())
	{
		do {
			ntwk_process();
		} while (sys_GetKey() != sk_Clear);
	}
	usb_Cleanup();
	return 0;
}
