
#ifndef __GUI_H__
#define __GUI_H__

#include <stdint.h>
#include <stdbool.h>
#include <graphx.h>

#define LCD_WIDTH 320
#define LCD_HEIGHT 240
#define LINE_HEIGHT 9

#define CURSOR_WIDTH 10
#define CURSOR_HEIGHT 10

#define WINDOW_BORDER_COLOR 0x01
#define WINDOW_FILL_COLOR 0xDF
#define WINDOW_TEXT_COLOR 0x40
#define WINDOW_BUTTON_FG_COLOR 0x09
#define WINDOW_BUTTON_BG_COLOR 0x9F
#define WINDOW_BUTTON_TEXT_COLOR 0x00
#define WINDOW_FIELD_FG_COLOR 0x09
#define WINDOW_FIELD_BG_COLOR 0xFF
#define WINDOW_FIELD_TEXT_COLOR 0x00

#define WIN_DEFAULT         0
#define WIN_BORDERLESS      1

#define GUI_ITEM_NONE       0
#define GUI_ITEM_TEXT       1
#define GUI_ITEM_BUTTON     2
#define GUI_ITEM_TEXTFIELD  3
#define GUI_ITEM_CHECKBOX   4

typedef struct _gui_item_t {
	uint8_t type;
	int x, y;
	unsigned int width, height;
	char *text;
	bool (*lclickaction)(void*, void*);
	bool (*rclickaction)(void*, void*);
	void *value;
} gui_item_t;

typedef struct _window_t {
	uint8_t type;
	int x, y;
	unsigned int width, height;
	char *title;
	char *content;
	gfx_sprite_t *icon;
	gui_item_t **items;
} window_t;


void guiDrawWindow(window_t* window);
void guiDrawItem(window_t* window, gui_item_t* item);
void guiDrawStringXY(const char* str, int minx, int miny, int w, int h);
gui_item_t* guiGetItemAt(window_t* window, int x, int y);

#endif
