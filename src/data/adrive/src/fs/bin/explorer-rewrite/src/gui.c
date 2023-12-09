
#include <stdint.h>
#include <stdbool.h>
#include <graphx.h>
#include "gui.h"

void guiDrawWindow(window_t *window) {
	gfx_SetColor(WINDOW_FILL_COLOR);
	if (window->type == WIN_BORDERLESS) {
		gfx_FillRectangle(window->x, window->y, window->width, window->height);
	} else {
		gfx_FillRectangle(window->x + 1, window->y + 1, window->width - 2, window->height - 2);
		gfx_SetColor(WINDOW_BORDER_COLOR);
		gfx_Rectangle(window->x, window->y, window->width, window->height);
	}
	gfx_SetTextBGColor(WINDOW_FILL_COLOR);
	gfx_SetTextFGColor(WINDOW_TEXT_COLOR);
	if (window->icon != NULL) {
		gfx_Sprite(window->icon, window->x + 1, window->y + 1);
	}
	if (window->title != NULL) {
		gfx_HorizLine(window->x + 1, window->y + 10, window->width - 2);
		if (window->icon != NULL)
			guiDrawStringXY(window->title, (window->x + 2 + window->icon->width), window->y + 2, (window->width - 4 + window->icon->height), 9);
		else
			guiDrawStringXY(window->title, window->x + 2, window->y + 2, window->width - 4, 9);
	}
	if (window->content != NULL) {
		guiDrawStringXY(window->content, window->x + 2, window->y + (window->title != NULL ? LINE_HEIGHT + 3 : 2), window->width - 4, window->height - 4);
	}
	for (unsigned int i=0; i<window->numitems; i++) {
		guiDrawItem(window->items[i]);
	}
}

void guiDrawItem(gui_item_t *item) {
	switch (item->type) {
		case GUI_ITEM_BUTTON:
			gfx_SetColor(WINDOW_BUTTON_BG_COLOR);
			gfx_FillRectangle(item->x, item->y, item->width, item->height);
			gfx_SetColor(WINDOW_BUTTON_FG_COLOR);
			gfx_Rectangle(item->x, item->y, item->width, item->height);
			gfx_SetTextFGColor(WINDOW_BUTTON_TEXT_COLOR);
			gfx_SetTextBGColor(WINDOW_BUTTON_BG_COLOR);
			break;
		case GUI_ITEM_TEXTFIELD:
			gfx_SetColor(WINDOW_FIELD_BG_COLOR);
			gfx_FillRectangle(item->x, item->y, item->width, item->height);
			gfx_SetColor(WINDOW_FIELD_FG_COLOR);
			gfx_Rectangle(item->x, item->y, item->width, item->height);
			gfx_SetTextFGColor(WINDOW_FIELD_TEXT_COLOR);
			gfx_SetTextBGColor(WINDOW_BUTTON_BG_COLOR);
			break;
		case GUI_ITEM_CHECKBOX:
			gfx_SetColor(WINDOW_FIELD_BG_COLOR);
			gfx_FillRectangle(item->x, item->y, 9, 9);
			gfx_SetColor(WINDOW_FIELD_FG_COLOR);
			gfx_Rectangle(item->x, item->y, 9, 9);
			gfx_SetTextFGColor(WINDOW_FIELD_TEXT_COLOR);
			gfx_SetTextBGColor(WINDOW_BUTTON_BG_COLOR);
			if (item->text != NULL) {
				guiDrawStringXY(item->text, item->x + 10, item->y, item->width, item->height);
			}
			return;
		case GUI_ITEM_TEXT:
			gfx_SetTextFGColor(WINDOW_TEXT_COLOR);
			gfx_SetTextBGColor(WINDOW_FILL_COLOR);
		default:
			break;
	}
	if (item->text != NULL) {
		guiDrawStringXY(item->text, item->x, item->y, item->width, item->height);
	}
}

void guiDrawStringXY(const char *str, int minx, int miny, int w, int h) {
	char c;
	int maxx, maxy;
	int x = minx;
	int y = miny;
	if (w == 0)
		maxx = LCD_WIDTH;
	else
		maxx = x + w;
	if (h == 0)
		maxy = LCD_HEIGHT;
	else
		maxy = y + h;

	gfx_SetTextXY(x, y);
	while ((c = *str++)) {
		if ((unsigned)c < 0x80) {
			uint8_t cw = gfx_GetCharWidth(c);
			if (c == 0xA || x + cw >= maxx) {
				x = minx;
				y += LINE_HEIGHT;
				gfx_SetTextXY(x, y);
			}
			if (y >= maxy)
				break;
			if (c == 0xA)
				continue;
			gfx_PrintChar(c);
			x += cw;
		}
	}
	
}
