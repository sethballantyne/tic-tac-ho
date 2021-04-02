#pragma once

#include <lua.hpp>
#include <string>

/// INTERNAL FUNCTIONS ////////////////////////////////////////////////////////
void V2D_Lua_CleanUp();
void V2D_Lua_ExecFunction(const std::string& functionName);
int V2D_Lua_ExecScript(const std::string& filename);

/// FUNCTIONS EXPOSED TO LUA //////////////////////////////////////////////////
int V2D_Lua_Init();
int V2D_Lua_HaltExecution(lua_State* luaState);
int V2D_Lua_RegisterFunction(lua_CFunction funcPtr, const std::string& functionNameInLua);