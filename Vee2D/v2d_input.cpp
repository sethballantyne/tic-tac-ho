#include <map>
#include <SDL.h>
#include "v2d_input.h"
#include "console.h"

using namespace std;
using namespace console;

map<int, int> keyboardPool;
map<int, int> mousePool;

extern lua_State* luaState;
extern Console gameConsole;
extern SDL_Event event;


/// INTERNAL FUNCTIONS ////////////////////////////////////////////////////////
void V2D_Input_HandleKeyPress()
{
	try
	{
		int funcReference = keyboardPool.at(event.key.keysym.sym);
		lua_rawgeti(luaState, LUA_REGISTRYINDEX, funcReference);
		lua_call(luaState, 0, 0);
	}
	catch(...)
	{
		// no need to do anything; it just means a key has been pressed
		// that doesn't have a lua function associated with it (ie, it doesn't
		// do anything). 
	}
}

void V2D_Input_HandleMouseButtonPress()
{
	try
	{
		int funcReference = mousePool.at(event.button.button);
		lua_rawgeti(luaState, LUA_REGISTRYINDEX, funcReference);
		lua_call(luaState, 0, 0);
	}
	catch(...)
	{
		// no need to do anything; it just means a button has been pressed
		// that doesn't have a lua function associated with it (ie, it doesn't
		// do anything). 
	}
}

/// FUNCTIONS EXPOSED TO LUA //////////////////////////////////////////////////

int V2D_Input_GetMouseXY(lua_State* state)
{
	lua_pushinteger(state, event.motion.x);
	lua_pushinteger(state, event.motion.y);

	return 2;
}

int V2D_Input_RegisterKey(lua_State* state)
{
	int key = luaL_checkinteger(state, 1);
	if(lua_isfunction(state, 2))
	{
		lua_pushvalue(state, 2);
		keyboardPool[key] = luaL_ref(state, LUA_REGISTRYINDEX);
	}

	return 0;
}

int V2D_Input_RegisterMouseButton(lua_State* state)
{
	int button = luaL_checkinteger(state, 1);
	if(lua_isfunction(state, 2))
	{
		lua_pushvalue(state, 2);
		mousePool[button] = luaL_ref(state, LUA_REGISTRYINDEX);
	}

	return 0;
}