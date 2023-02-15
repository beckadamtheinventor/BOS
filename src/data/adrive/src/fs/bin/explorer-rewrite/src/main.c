
#include <stdint.h>
#include <stdbool.h>
#include <string.h>

#include <tice.h>
#include <bos.h>
#include <graphx.h>

#include "gui.h"

uint8_t keypress_queue[16] = {0};

gui_item_t MainWindowItems[] = {
	{
		GUI_ITEM_TEXT,
		1, 1, 100, 10,
		"Test Text",
		NULL, NULL,
	},
	{
		GUI_ITEM_BUTTON,
		102, 1, 100, 10,
		"Test Button",
		NULL, NULL,
	},
};

window_t MainWindow = {
	WIN_BORDERLESS,
	0, 0, LCD_WIDTH, LCD_HEIGHT,
	NULL,
	NULL,
	NULL,
	&MainWindowItems,
};


int isKeyPressed_NoConsume(uint8_t key) {
	for (int i=0; i<sizeof(keypress_queue); i++) {
		if (keypress_queue[i] == key) {
			return i+1;
		}
	}
	return 0;
}

bool isKeyPressed(uint8_t key) {
	int i = isKeyPressed_NoConsume(key);
	if (i > 0)
		keypress_queue[i-1] = 0;
	else
		return false;
	return true;
}

void _keythread(int argc, char **argv) {
	uint8_t key;
	do {
		if ((key = sys_GetKey())) {
			for (int i=0; i<sizeof(keypress_queue); i++) {
				if (keypress_queue[i] == key)
					break; // don't re-queue keys that haven't been handled yet
				if (keypress_queue[i] == 0) {
					keypress_queue[i] = key; // queue a key to be handled
					break;
				} 
			}
		}
		th_HandleNextThread();
	} while (true);
}


int main(int argc, char **argv) {
	uint8_t *keythreadstack;
	uint8_t keythread;
	int cursor_x, cursor_y;
	bool redraw = true;
	if ((keythreadstack = sys_Malloc(32*sizeof(void*))) == NULL)
		return 1;
	keythread = th_CreateThread(&_keythread, &keythreadstack[32*sizeof(void*)], 0, NULL);

	do {
		if (redraw) {
			gfx_SetDrawBuffer();
			guiDrawWindow(&MainWindow);
			gfx_BlitBuffer();
			redraw = false;
		}
		th_HandleNextThread();

		if (isKeyPressed(sk_Up)) {
			if (cursor_y > 0)
				cursor_y--;
		} else if (isKeyPressed(sk_Down)) {
			if (cursor_y < LCD_HEIGHT - CURSOR_HEIGHT)
				cursor_y++;
		} else if (isKeyPressed(sk_Left)) {
			if (cursor_x > 0)
				cursor_x--;
		} else if (isKeyPressed(sk_Right)) {
			if (cursor_x < LCD_WIDTH - CURSOR_HEIGHT)
				cursor_x++;
		} else if (isKeyPressed(sk_Enter) || isKeyPressed(sk_2nd)) {
			
		}
	} while (!isKeyPressed(sk_Clear));
	th_KillThread(keythread);
	return 0;
}

