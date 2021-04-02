#include <SDL.h>
#include <SDL_image.h>
#include <iostream>
#include <map>
#include "console.h"
#include "v2d_lua.h"
#include "v2d_common.h"
#include "v2d_bmpfont.h"
#include "v2d_video.h"
#include "v2d_input.h"
#include "v2d_sprite.h"

using namespace std;
using namespace console;

SDL_Surface* screen = nullptr;
SDL_Event event;

extern map<int, int> inputPool;

void RegisterCPPFunctions();
void RegisterConsoleCommands();

int functionReference = 0;
int key = 0;
int mouseX = 0;
int mouseY = 0;
Console gameConsole;

const string luaFile = "game.lua";

int Print(lua_State* state)
{
	const char* text = lua_tostring(state, 1);
	Console_Print(gameConsole, text);

	return 0;
}

//int RegisterKey(lua_State* state)
//{
//	key = luaL_checkint(state, 1);
//	if(lua_isfunction(state, 2))
//	{
//		lua_pushvalue(state, 2);
//		functionReference = luaL_ref(state, LUA_REGISTRYINDEX);	
//	}
//
//	return 0;
//}

int GetMouseX(lua_State* state)
{
	lua_pushnumber(state, mouseX);
	return 1;
}

int GetMouseY(lua_State* state)
{
	lua_pushnumber(state, mouseY);
	return 1;
}

int DrawQuad(lua_State* state)
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



void Cleanup()
{
	if(nullptr != screen)
	{
		SDL_FreeSurface(screen);
	}

	SDL_Quit();
}

int main(int argc, char** argv)
{
	int result = SDL_Init(SDL_INIT_VIDEO);
	if(0 != result)
	{
		return -1;
	}

	atexit(Cleanup);

	screen = SDL_SetVideoMode(640, 480, 32, SDL_HWSURFACE | SDL_DOUBLEBUF);
	if(!screen)
	{
		return -1;
	}

	SDL_Colour consoleFontColour = { 0, 255, 0 };
	SDL_Colour consoleColour = { 20, 20, 20 };
	SDL_Colour fontTransparencyColour = { 255, 0, 255 };

	result = Console_Init(gameConsole, screen, &consoleColour, &consoleFontColour, &fontTransparencyColour);
	if(result != CONSOLE_RET_SUCCESS)
	{
		cerr << "Failed to init console." << endl;
		return -1;
	}

	// needed for the console
	SDL_EnableUNICODE(1);

	result = V2D_Lua_Init();
	if(result == V2D_ERROR)
	{
		return -1;
	}

	
	RegisterCPPFunctions();
	RegisterConsoleCommands();

	V2D_Lua_ExecScript(luaFile);

	SDL_Surface* bg = SDL_LoadBMP("data\\art\\consolebg.bmp");
	Console_SetBackground(gameConsole, bg);
	V2D_Lua_ExecFunction("Create");

	bool quit = false;
	int f = 1 | 2 | 4 | 8;
	int d = f & (1 | 2 | 4);
	cout << d;

	while(!quit)
	{
		while(SDL_PollEvent(&event))
		{
			
			if(gameConsole.enabled)
			{
				// if you don't call Console_ProcessInput, no input will be 
				// printed to the input buffer when keys are pressed.
				Console_ProcessInput(gameConsole, &event);
			}
			switch(event.type)
			{
				case SDL_KEYDOWN:
					switch(event.key.keysym.sym)
					{
						case SDLK_ESCAPE:
							quit = true;
							break;
						case SDLK_TAB:
							gameConsole.enabled = !gameConsole.enabled;
							break;
						default:
							if(!gameConsole.enabled)
							{
								V2D_Input_HandleKeyPress();
							}
							break;
					}
					break;

				case SDL_MOUSEBUTTONDOWN:
					if(!gameConsole.enabled)
					{
						V2D_Input_HandleMouseButtonPress();
					}
					break;

				case SDL_QUIT:
					quit = true;
					break;
			}
		}

		SDL_GetMouseState(&mouseX, &mouseY);

		V2D_Lua_ExecFunction("Update");

		SDL_FillRect(screen, nullptr, 0);
		V2D_Lua_ExecFunction("Render");
		
		if(gameConsole.enabled)
		{
			Console_Render(gameConsole, screen);
		}

		SDL_Delay(33);
		
		SDL_Flip(screen);
	}

	V2D_Lua_ExecFunction("Shutdown");
	V2D_BmpFont_CleanUp();
	V2D_Lua_CleanUp();

	return 0;
}

void RegisterCPPFunctions()
{
	V2D_Lua_RegisterFunction(GetMouseX, "GetMouseX");
	V2D_Lua_RegisterFunction(GetMouseY, "GetMouseY");
	V2D_Lua_RegisterFunction(DrawQuad, "DrawQuad");
	//V2D_Lua_RegisterFunction(RegisterKey, "RegisterKey");
	V2D_Lua_RegisterFunction(Print, "Console_Print");

	// Bitmap Font functions - v2d_bmpfont.cpp
	V2D_Lua_RegisterFunction(V2D_BmpFont_DrawLine, "BmpFont_PrintLine");
	V2D_Lua_RegisterFunction(V2D_BmpFont_Load, "BmpFont_Load");

	// Input functions - v2d_input.cpp
	V2D_Lua_RegisterFunction(V2D_Input_RegisterKey, "Input_RegisterKey");
	V2D_Lua_RegisterFunction(V2D_Input_RegisterMouseButton, "Input_RegisterMouseButton");
	V2D_Lua_RegisterFunction(V2D_Input_GetMouseXY, "Input_GetMouseXY");

	// Sprite functions - v2d_sprite.cpp
	V2D_Lua_RegisterFunction(V2D_Sprite_Load, "Sprite_Load");
	V2D_Lua_RegisterFunction(V2D_Sprite_Draw, "Sprite_Draw");

	// Video functions - v2d_video.cpp
	V2D_Lua_RegisterFunction(V2D_Video_MapRGB, "Video_MapRGB");

	// Debug functions
	V2D_Lua_RegisterFunction(V2D_Lua_HaltExecution, "Debug_Halt");
}

void ConsoleCMD_Reload(Console& console, vector<string>& args)
{
	V2D_Lua_ExecScript(luaFile);
}

void ConsoleCMD_RunFunction(Console& console, vector<string>& args)
{
	if(args.size() >= 1)
	{
		V2D_Lua_ExecFunction(args[0]);
	}
	else
	{
		Console_Print(gameConsole, "ERROR: function name required.");
	}
}

void ConsoleCMD_DumpLog(Console& console, vector<string>& args)
{
	FILE* file;
	
	fopen_s(&file, "log.txt", "w");
	for(string& s : console.outputBuffer.buffer)
	{
		fprintf(file, "%s\n", s.c_str());
	}

	fflush(file);
	fclose(file);
}

void RegisterConsoleCommands()
{
	Console_RegisterCommand(gameConsole, "reload", ConsoleCMD_Reload);
	Console_RegisterCommand(gameConsole, "runfunc", ConsoleCMD_RunFunction);
	Console_RegisterCommand(gameConsole, "dump", ConsoleCMD_DumpLog);
}