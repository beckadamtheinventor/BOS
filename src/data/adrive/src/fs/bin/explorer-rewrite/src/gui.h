
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
#define WINDOW_FILL_COLOR 0xBF
#define WINDOW_TEXT_COLOR 0x80

#define WIN_DEFAULT         0
#define WIN_BORDERLESS      1

#define GUI_ITEM_TEXT       1
#define GUI_ITEM_BUTTON     2
#define GUI_ITEM_TEXTFIELD  3
#define GUI_ITEM_CHECKBOX   4

typedef struct gui_item_t {
	uint8_t type;
	int x, y, width, height;
	char *text;
	bool (*lclickaction)(void *);
	bool (*rclickaction)(void *);
} gui_item_t;

typedef struct window_t {
	uint8_t type;
	int x, y, width, height;
	char *title;
	char *content;
	gfx_sprite_t *icon;
	gui_item_t **items;
} window_t;


void guiDrawWindow(window_t *window);
void guiDrawStringXY(const char *str, int minx, int miny, int w, int h);
void guiDrawItem(const gui_item_t *item);

#endif
