
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

#define KEY_SCAN_ITERATIONS 10
#define CURSOR_SPEED_COOLDOWN 4
#define MAX_CURSOR_SPEED 4

void Delay10ms(void);

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
	{
		GUI_ITEM_NONE,
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
	char cursor_speed = 1, cursor_speed_cooldown = 0;
	bool redraw = true;

	gfx_SetTransparentColor(248);
	gfx_SetTextTransparentColor(0);

	cursor_x = cursor_y = 20;
	do {
		if (redraw) {
			gfx_SetDrawBuffer();
			guiDrawWindow(&MainWindow);
			gfx_SetDrawScreen();
			gfx_BlitBuffer();
			redraw = false;
		}
		gfx_TransparentSprite(cursor, cursor_x, cursor_y);
		th_HandleNextThread();
		for (char i=0; i<KEY_SCAN_ITERATIONS; i++) {
			if (kb_AnyKey()) {
				break;
			}
			Delay10ms();
		}
		kb_Scan();

		if (kb_AnyKey()) {
			gfx_BlitRectangle(1, cursor_x, cursor_y, cursor->width, cursor->height);
		} else if (cursor_speed > 1) {
			cursor_speed--;
		}

		if (kb_IsDown(kb_KeyUp)) {
			if (cursor_y > 0)
				cursor_y -= cursor_speed;
			goto cursor_moved;
		}
		if (kb_IsDown(kb_KeyDown)) {
			if (cursor_y < LCD_HEIGHT - cursor->height)
				cursor_y += cursor_speed;
			goto cursor_moved;
		}
		if (kb_IsDown(kb_KeyLeft)) {
			if (cursor_x > 0)
				cursor_x -= cursor_speed;
			goto cursor_moved;
		}
		if (kb_IsDown(kb_KeyRight)) {
			if (cursor_x < LCD_WIDTH - cursor->width)
				cursor_x += cursor_speed;
			cursor_moved:;
			cursor_speed_cooldown++;
			if (cursor_speed_cooldown >= CURSOR_SPEED_COOLDOWN) {
				cursor_speed_cooldown = 0;
				if (cursor_speed < MAX_CURSOR_SPEED) {
					cursor_speed++;
				}
			}
		}
		if (kb_IsDown(kb_KeyEnter) || kb_IsDown(kb_Key2nd)) {
			
		}
	} while (!kb_IsDown(kb_KeyClear));
	// th_KillThread(keythread);
	return 0;
}

