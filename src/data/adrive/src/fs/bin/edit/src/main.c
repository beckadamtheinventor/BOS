
/** EDIT: A text based file editor for BOS
* Author: Adam "beckadamtheinventor" Beckingham
* License: GPL, see BOS LICENSE for details
*/

#include <stdint.h>
#incldue <string.h>

#include <graphx.h>
#include <bos.h>

#define LINE_FEED 0x0A
#define HORIZ_TAB 0x09
#define MARGIN_LEFT 10
#define MARGIN_RIGHT 310
#define MARGIN_TOP 20
#define MARGIN_BOTTOM 230
#define LINE_HEIGHT 9
#define CHAR_WIDTH 8
#define TAB_WIDTH 4

int main_draw(const char *str);
void load_args(const char *args);

int main(const char *args){
	void *fd = fs_OpenFile(args);
	if ((int)fd != -1){
		
	}
	
	
	return 0;
}


int main_draw(const char *str){
	char c;
	int x = MARGIN_LEFT;
	int y = MARGIN_TOP;
	for (int i = 0; c = *str; i++, str++){
		if (c == LINE_FEED) y+=LINE_HEIGHT;
		else if (c == HORIZ_TAB) x+=TAB_WIDTH*CHAR_WIDTH;
		else {
			gfx_SetTextXY(x, y);
			gfx_PrintChar(c);
			x += 8;
			if (x > MARGIN_RIGHT){
				x = MARGIN_LEFT;
				y += LINE_HEIGHT;
				if (y > MARGIN_BOTTOM) return y;
			}
		}
	}
	return y;
}

