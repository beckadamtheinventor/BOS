
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
		if (window->icon != NULL) {
			guiDrawStringXY(window->title, (window->x + 2 + window->icon->width), window->y + 2, (window->width - 4 + window->icon->height), 9);
		} else {
			guiDrawStringXY(window->title, window->x + 2, window->y + 2, window->width - 4, 9);
		}
	}
	if (window->content != NULL) {
		guiDrawStringXY(window->content, window->x + 2, window->y + (window->title != NULL ? LINE_HEIGHT + 3 : 2), window->width - 4, window->height - 4);
	}
	if (window->items) {
		while (window->items[i]) {
			guiDrawItem(window->items[i]);
		}
	}
}

void guiDrawItem(gui_item_t *item) {
	int xx, yy;
	if (item->x < 0) {
		xx = window->x;
	} else if (item->x + item->width >= window->width) {
		xx = window->width - item->width;
		if (xx < 0) {
			xx = 0;
		}
	} else {
		xx = window->x + item->x;
	}
	if (item->y < 0) {
		yy = window->y;
	} else if (item->y + item->height >= window->height) {
		yy = window->height - item->height;
		if (yy < 0) {
			yy = 0;
		}
	} else {
		yy = window->y + item->y;
	}
	switch (item->type) {
		case GUI_ITEM_BUTTON:
			gfx_SetColor(WINDOW_BUTTON_BG_COLOR);
			gfx_FillRectangle(xx, yy, item->width, item->height);
			gfx_SetColor(WINDOW_BUTTON_FG_COLOR);
			gfx_Rectangle(xx, yy, item->width, item->height);
			gfx_SetTextFGColor(WINDOW_BUTTON_TEXT_COLOR);
			gfx_SetTextBGColor(WINDOW_BUTTON_BG_COLOR);
			break;
		case GUI_ITEM_TEXTFIELD:
			gfx_SetColor(WINDOW_FIELD_BG_COLOR);
			gfx_FillRectangle(xx, yy, item->width, item->height);
			gfx_SetColor(WINDOW_FIELD_FG_COLOR);
			gfx_Rectangle(xx, yy, item->width, item->height);
			gfx_SetTextFGColor(WINDOW_FIELD_TEXT_COLOR);
			gfx_SetTextBGColor(WINDOW_BUTTON_BG_COLOR);
			break;
		case GUI_ITEM_CHECKBOX:
			if (item->value != NULL && *(uint8_t*)item->value) {
				gfx_SetColor(WINDOW_FIELD_FG_COLOR);
			} else {
				gfx_SetColor(WINDOW_FIELD_BG_COLOR);
			}
			gfx_FillRectangle(xx+1, yy+1, 7, 7);
			gfx_SetColor(WINDOW_FIELD_FG_COLOR);
			gfx_Rectangle(xx, yy, 9, 9);
			gfx_SetTextFGColor(WINDOW_FIELD_TEXT_COLOR);
			gfx_SetTextBGColor(WINDOW_BUTTON_BG_COLOR);
			if (item->text != NULL) {
				guiDrawStringXY(item->text, xx + 10, yy, item->width, item->height);
			}
			return;
		case GUI_ITEM_TEXT:
			gfx_SetTextFGColor(WINDOW_TEXT_COLOR);
			gfx_SetTextBGColor(WINDOW_FILL_COLOR);
		default:
			break;
	}
	if (item->text != NULL) {
		guiDrawStringXY(item->text, xx, yy, item->width, item->height);
	}
}

void guiDrawStringXY(const char *str, int minx, int miny, int w, int h) {
	char c;
	int maxx, maxy;
	int x = minx;
	int y = miny;
	if (w == 0) {
		maxx = LCD_WIDTH;
	} else {
		maxx = x + w;
	}
	if (h == 0) {
		maxy = LCD_HEIGHT;
	} else {
		maxy = y + h;
	}

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

bool guiCursorOnWindow(window_t* window, int x, int y) {
	if ((unsigned)(y - window->y) < window->height) {
		if ((unsigned)(x - window->x) < window->width) {
			
		}
	}
}

gui_item_t* guiGetItemAt(window_t* window, int x, int y) {
	gui_item_t* item;
	if (window->items) {
		while ((item = window->items[i])) {
			if ((unsigned)(y - item->y) < item->height) {
				if ((unsigned)(x - item->x) < item->width) {
					
				}
			}
		}
	}
	return NULL;
}
