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

int V2D_Input_GetMouseX(lua_State* state)
{
	lua_pushnumber(state, event.motion.x);
	return 1;
}

int V2D_Input_GetMouseY(lua_State* state)
{
	lua_pushnumber(state, event.motion.y);
	return 1;
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