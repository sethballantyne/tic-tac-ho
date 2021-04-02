#pragma once
#include <SDL.h>
#include "v2d_lua.h"

struct bitmap_font_t
{
	int charWidth;
	int charHeight;
	int colourKey;
	SDL_Surface* surface;
};

/// INTERNAL FUNCTIONS ////////////////////////////////////////////////////////
void V2D_BmpFont_CleanUp();

/// FUNCTIONS EXPOSED TO LUA //////////////////////////////////////////////////
int V2D_BmpFont_DrawLine(lua_State* state);
int V2D_BmpFont_Load(lua_State* state);