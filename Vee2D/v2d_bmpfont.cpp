/*
* MIT License
*
* Copyright (c) 2021 Seth Ballantyne
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

#include <map>
#include <SDL_image.h>
#include "v2d_bmpfont.h"
#include "console.h"


using namespace std;
using namespace console;

int currentFontPoolKey = 0;
map<int, bitmap_font_t*> fontPool;

extern SDL_Surface* screen;
extern Console gameConsole;

/// INTERNAL FUNCTIONS ////////////////////////////////////////////////////////
void V2D_BmpFont_CleanUp()
{
	for(auto font : fontPool)
	{
		if(font.second != nullptr)
		{
			if(font.second->surface != nullptr)
			{
				SDL_FreeSurface(font.second->surface);
			}

			delete font.second;
		}
	}
}

int RenderChar(SDL_Surface* surface, int key, int x, int y, const char character)
{
	SDL_Rect src;
	SDL_Rect dest;

	src.x = (character - 32) * fontPool[key]->charWidth;
	src.y = 0;
	src.w = fontPool[key]->charWidth;
	src.h = fontPool[key]->charHeight;

	dest.x = x;
	dest.y = y;
	dest.w = src.w;
	dest.h = src.h;

	return SDL_BlitSurface(fontPool[key]->surface, &src, screen, &dest);
}

/// FUNCTIONS EXPOSED TO LUA //////////////////////////////////////////////////

int V2D_BmpFont_DrawLine(lua_State* state)
{
	int key = luaL_checkinteger(state, 1);
	int y = luaL_checkinteger(state, 2);
	const string& text = luaL_checkstring(state, 3);
	int charWidth = 0;

	try
	{
		charWidth = fontPool.at(key)->charWidth;
	}
	catch(...)
	{
		Console_Print(gameConsole, "BmpFont_PrintLine: invalid key: " + to_string(key));
		lua_pushinteger(state, -1);
		return 1;
	}

	int strLengthInPixels = text.length() * charWidth;
	int halfOfStrWidth = strLengthInPixels / 2;
	int middleOfScreen = screen->w / 2;
	int strXPosition = middleOfScreen - halfOfStrWidth;

	int result = 0;
	for(int i = 0; i < text.length(); i++)
	{
		int charPos = strXPosition + (i * charWidth);
		result = RenderChar(screen, key, charPos, y, text[i]);
		if(-1 == result)
		{
			break;
		}
	}

	lua_pushinteger(state, result);

	return 1;
}

int V2D_BmpFont_Load(lua_State* state)
{
	int charWidth = luaL_checkinteger(state, 1);
	int charHeight = luaL_checkinteger(state, 2);
	const string& filename = luaL_checkstring(state, 3);
	int colourKey = luaL_checkinteger(state, 4);

	SDL_Surface* img = IMG_Load(filename.c_str());
	if(!img)
	{
		lua_pushinteger(state, -1);
	}
	else
	{
		SDL_SetColorKey(img, SDL_SRCCOLORKEY, colourKey);

		bitmap_font_t* font = new bitmap_font_t;
		font->charHeight = charHeight;
		font->charWidth = charHeight;
		font->colourKey = colourKey;
		font->surface = img;

		fontPool[currentFontPoolKey] = font;

		lua_pushinteger(state, currentFontPoolKey++);
	}
	
	return 1;
}