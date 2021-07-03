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
#include "v2d_common.h"
#include "v2d_video.h"

SDL_Surface* screen = nullptr;

int V2D_Video_CreateWindow(int width, int height, int bpp, bool fullscreen)
{
	Uint32 flags = SDL_HWSURFACE | SDL_DOUBLEBUF;

	if(fullscreen)
	{
		flags |= SDL_FULLSCREEN;
	}

	screen = SDL_SetVideoMode(640, 480, 32, flags);
	if(!screen)
	{
		return V2D_ERROR;
	}

	return V2D_SUCCESS;
}

void V2D_Video_Shutdown()
{
	if(nullptr != screen)
	{
		SDL_FreeSurface(screen);
	}
}

/// FUNCTIONS EXPOSED TO LUA //////////////////////////////////////////////////
int V2D_Video_MapRGB(lua_State* state)
{
	int r = luaL_checkinteger(state, 1);
	int g = luaL_checkinteger(state, 2);
	int b = luaL_checkinteger(state, 3);

	int result = SDL_MapRGB(screen->format, r, g, b);

	lua_pushinteger(state, result);

	return 1;
}

int V2D_Video_DrawQuad(lua_State* state)
{
	int x = luaL_checknumber(state, 1);
	int y = luaL_checknumber(state, 2);
	int width = luaL_checknumber(state, 3);
	int height = luaL_checknumber(state, 4);
	unsigned char R = luaL_checknumber(state, 5);
	unsigned char G = luaL_checknumber(state, 6);
	unsigned char B = luaL_checknumber(state, 7);

	Uint32 colour = SDL_MapRGB(screen->format, R, G, B);

	SDL_Rect rect;

	rect.h = height;
	rect.w = width;
	rect.x = x;
	rect.y = y;
	SDL_FillRect(screen, &rect, colour);

	return 0;
}