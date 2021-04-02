#pragma once
#include <SDL.h>

struct sprite_t
{
	int colourKey;
	SDL_Surface* surface;
};

/// FUNCTIONS EXPOSED TO LUA //////////////////////////////////////////////////
int V2D_Sprite_Load(lua_State* state);
int V2D_Sprite_Draw(lua_State* state);