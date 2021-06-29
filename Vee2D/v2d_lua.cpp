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

#include "v2d_lua.h"
#include "v2d_common.h"
#include "console.h"
#include <string>

using namespace std;

extern console::Console gameConsole;
lua_State* luaState = nullptr;
bool haltExecution = false;

/// INTERNAL FUNCTIONS ////////////////////////////////////////////////////////
void V2D_Lua_CleanUp()
{
	lua_close(luaState);
}

int V2D_Lua_Init()
{
	luaState = luaL_newstate();
	if(!luaState)
	{
		return V2D_ERROR;
	}

	/*luaopen_math(luaState);
	luaopen_string(luaState);*/

	luaL_requiref(luaState, "math", luaopen_math, 1);
	lua_pop(luaState, 1);

	luaL_requiref(luaState, "string", luaopen_string, 1);
	lua_pop(luaState, 1);

	luaL_requiref(luaState, "table", luaopen_table, 1);
	lua_pop(luaState, 1);

	return V2D_SUCCESS;
}

void V2D_Lua_ExecFunction(const string& functionName)
{
	if(!haltExecution)
	{
		lua_getglobal(luaState, functionName.c_str());

		int result = lua_pcall(luaState, 0, 0, 0);
		if(result != 0)
		{
			Console_Print(gameConsole, "Error executing function \"" + functionName + "\"");
			Console_Print(gameConsole, lua_tostring(luaState, -1));
			/*cerr << "Error executing function \"" << functionName.c_str() << "\"" << endl;
			cerr << lua_tostring(luaState, -1) << endl;*/
		}
	}
}

int V2D_Lua_ExecScript(const string& filename)
{
	haltExecution = false; //  clear flag if it was previously halted

	int result = luaL_loadfile(luaState, filename.c_str()) || lua_pcall(luaState, 0, 0, 0);
	if(result)
	{
		Console_Print(gameConsole, "Error executing script \"" + filename + "\"");
		Console_Print(gameConsole, lua_tostring(luaState, -1));
		Console_Print(gameConsole, "Script halted.");
		gameConsole.enabled = true;
		haltExecution = true;

		return -1;
	}

	Console_Print(gameConsole, "Successfully loaded script '" + filename + "'");
	return 0;
}

/// FUNCTIONS EXPOSED TO LUA //////////////////////////////////////////////////
int V2D_Lua_HaltExecution(lua_State* luaState)
{
	haltExecution = true;

	return 0;
}

int V2D_Lua_RegisterFunction(lua_CFunction funcPtr, const string& functionNameInLua)
{
	lua_pushcfunction(luaState, funcPtr);
	lua_setglobal(luaState, functionNameInLua.c_str());

	return 0;
}