
#include <stdint.h>
#include <stdbool.h>
#include <string.h>

#include <tice.h>
#include <bos.h>
#include <graphx.h>
#include <keypadc.h>

#include "gui.h"
#include "gfx/gfx.h"

//uint8_t keypress_queue[6*8] = {0};

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


/*
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
		kb_Scan();
		if (kb_AnyKey()) {
			for (uint8_t y=1; y<8; y++) {
				for (uint8_t x=0; x<8; x++) {
					if (kb_Data[y] & (1<<x)) {
						key = ((7 - y) << 3) + x + 1;
						for (int i=0; i<sizeof(keypress_queue); i++) {
							if (keypress_queue[i] == key)
								break; // don't re-queue keys that haven't been handled yet
							if (keypress_queue[i] == 0) {
								keypress_queue[i] = key; // queue a key to be handled
								break;
							} 
						}
					}
				}
			}
		}
		th_HandleNextThread();
	} while (true);
}
*/


int main(int argc, char **argv) {
//	uint8_t *keythreadstack;
//	uint8_t keythread;
	int cursor_x, cursor_y;
	bool redraw = true;
//	if ((keythreadstack = sys_Malloc(32*sizeof(void*))) == NULL)
//		return 1;
//	keythread = th_CreateThread(&_keythread, &keythreadstack[32*sizeof(void*)], 0, NULL);

	gfx_SetTransparentColor(248);

	cursor_x = cursor_y = 20;
	do {
		if (redraw) {
			gfx_SetDrawBuffer();
			guiDrawWindow(&MainWindow);
			redraw = false;
			gfx_SetDrawScreen();
			gfx_BlitBuffer();
		}
		gfx_TransparentSprite(cursor, cursor_x, cursor_y);
		th_HandleNextThread();
		kb_Scan();

		if (kb_AnyKey()) {
			gfx_BlitArea(1, cursor_x, cursor_y, cursor->width, cursor->height);
		}

		if (kb_IsDown(kb_KeyUp)) {
			if (cursor_y > 0)
				cursor_y -= 1;
		}
		if (kb_IsDown(kb_KeyDown)) {
			if (cursor_y < LCD_HEIGHT - cursor->height)
				cursor_y += 1;
		}
		if (kb_IsDown(kb_KeyLeft)) {
			if (cursor_x > 0)
				cursor_x -= 1;
		}
		if (kb_IsDown(kb_KeyRight)) {
			if (cursor_x < LCD_WIDTH - cursor->width)
				cursor_x += 1;
		}
		if (kb_IsDown(kb_KeyEnter) || kb_IsDown(kb_Key2nd)) {
			
		}
	} while (!kb_IsDown(kb_KeyClear));
	// th_KillThread(keythread);
	return 0;
}

