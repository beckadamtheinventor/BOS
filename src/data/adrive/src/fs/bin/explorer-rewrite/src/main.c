
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

#define KEY_SCAN_ITERATIONS 25
#define CURSOR_SPEED_COOLDOWN 20
#define MAX_CURSOR_SPEED 4

void Delay10ms(void);


gui_item_t MainWindowItem0 = {
	GUI_ITEM_TEXT,
	64, 1, 100, 15,
	"Test Text",
	NULL, NULL,
};
gui_item_t MainWindowItem1 = {
	GUI_ITEM_BUTTON,
	1, 1, 62, 15,
	"Butt",
	NULL, NULL,
};

gui_item_t* MainWindowItems[] = {
	&MainWindowItem0,
	&MainWindowItem1,
	NULL
};

window_t MainWindow = {
	WIN_BORDERLESS,
	0, 0, LCD_WIDTH, LCD_HEIGHT,
	NULL,
	NULL,
	NULL,
	MainWindowItems,
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
	bool redraw = true, cursor_moved = false, key_pressed = false;

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
				key_pressed = true;
				break;
			}
			Delay10ms();
		}
		kb_Scan();

		if (key_pressed) {
			gfx_BlitRectangle(1, cursor_x, cursor_y, cursor_width, cursor_height);
			key_pressed = false;
		}

		if (kb_IsDown(kb_KeyUp)) {
			if (cursor_y > 0) {
				cursor_y -= cursor_speed;
			} else {
				cursor_y = 0;
			}
			cursor_moved = true;
		}
		if (kb_IsDown(kb_KeyDown)) {
			if (cursor_y < LCD_HEIGHT - cursor_height) {
				cursor_y += cursor_speed;
			} else {
				cursor_y = LCD_HEIGHT - cursor_height;
			}
			cursor_moved = true;
		}
		if (kb_IsDown(kb_KeyLeft)) {
			if (cursor_x > 0) {
				cursor_x -= cursor_speed;
			} else {
				cursor_x = 0;
			}
			cursor_moved = true;
		}
		if (kb_IsDown(kb_KeyRight)) {
			if (cursor_x < LCD_WIDTH - cursor_width) {
				cursor_x += cursor_speed;
			} else {
				cursor_x = LCD_WIDTH - cursor_width;
			}
			cursor_moved = true;
		}

		if (cursor_moved) {
			cursor_speed_cooldown++;
			if (cursor_speed_cooldown >= CURSOR_SPEED_COOLDOWN) {
				cursor_speed_cooldown = 0;
				if (cursor_speed < MAX_CURSOR_SPEED) {
					cursor_speed++;
				}
			}
			cursor_moved = false;
		} else if (cursor_speed > 1) {
			cursor_speed--;
		}

		if (kb_IsDown(kb_KeyEnter) || kb_IsDown(kb_Key2nd)) {
			gui_item_t* item = guiGetItemAt(&MainWindow, cursor_x, cursor_y);
			if (item && item->lclickaction) {
				item->lclickaction((void*)&MainWindow, (void*)item);
			}
		} else if (kb_IsDown(kb_KeyAlpha)) {
			gui_item_t* item = guiGetItemAt(&MainWindow, cursor_x, cursor_y);
			if (item && item->rclickaction) {
				item->rclickaction((void*)&MainWindow, (void*)item);
			}
		}
	} while (!kb_IsDown(kb_KeyClear));
	// th_KillThread(keythread);
	return 0;
}

