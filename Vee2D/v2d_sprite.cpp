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

#include <SDL.h>
#include <lua.hpp>
#include <map>
#include <SDL_image.h>
#include "console.h"
#include "v2d_sprite.h"

using namespace std;
using namespace console;

int currentSpritePoolKey = 0;
map<int, sprite_t*> spritePool;

extern Console gameConsole;
extern SDL_Surface* screen;

int V2D_Sprite_Load(lua_State* state)
{
	const string& filename = luaL_checkstring(state, 1);
	int colourKey = luaL_checkinteger(state, 2);

	SDL_Surface* img = IMG_Load(filename.c_str());
	if(!img)
	{
		lua_pushinteger(state, -1);
	}
	else
	{
		int res = SDL_SetColorKey(img, SDL_SRCCOLORKEY, colourKey);
		
		sprite_t* sprite = new sprite_t;
		sprite->colourKey = colourKey;
		sprite->surface = img;

		spritePool[currentSpritePoolKey] = sprite;

		lua_pushinteger(state, currentSpritePoolKey++);
	}

	return 1;
}

int V2D_Sprite_Draw(lua_State* state)
{
	int key = luaL_checkinteger(state, 1);
	int x = luaL_checkinteger(state, 2);
	int y = luaL_checkinteger(state, 3);
	SDL_Surface* surface = nullptr;

	try
	{
		surface = spritePool.at(key)->surface;
	}
	catch(...)
	{
		Console_Print(gameConsole, "Sprite_Draw: invalid key: " + to_string(key));
		lua_pushinteger(state, -1);
		return 1;
	}

	SDL_Rect dest;
	dest.x = x;
	dest.y = y;
	dest.h = surface->h;
	dest.w = surface->w;

	int result = SDL_BlitSurface(surface, nullptr, screen, &dest);
	lua_pushinteger(state, result);

	return 1;
}