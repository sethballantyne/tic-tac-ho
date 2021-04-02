#include <SDL.h>
#include "v2d_video.h"

extern SDL_Surface* screen;

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