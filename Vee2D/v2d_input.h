#pragma once
#include <lua.hpp>

/// INTERNAL FUNCTIONS ////////////////////////////////////////////////////////
void V2D_Input_HandleKeyPress();
void V2D_Input_HandleMouseButtonPress();

/// FUNCTIONS EXPOSED TO LUA //////////////////////////////////////////////////
int V2D_Input_GetMouseXY(lua_State* state);
int V2D_Input_RegisterMouseButton(lua_State* state);
int V2D_Input_RegisterKey(lua_State*);