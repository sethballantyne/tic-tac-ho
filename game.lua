--  _   _  ___  _____ _   __  _____ _   _ _____  ______ _      ___  _   _ _____ _____
-- | | | |/ _ \/  __ \ | / / |_   _| | | |  ___| | ___ \ |    / _ \| \ | |  ___|_   _|
-- | |_| / /_\ \ /  \/ |/ /    | | | |_| | |__   | |_/ / |   / /_\ \  \| | |__   | |
-- |  _  |  _  | |   |    \    | | |  _  |  __|  |  __/| |   |  _  | . ` |  __|  | |
-- | | | | | | | \__/\ |\  \   | | | | | | |___  | |   | |___| | | | |\  | |___  | |
-- \_| |_|_| |_/\____|_| \_/   \_/ \_| |_|____/  \_|   \_____|_| |_|_| \_|____/  \_/


-- TIC-TAC-HO!
-- Copyright(c) 2021 Seth Ballantyne <seth.ballantyne@gmail.com>
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this
-- software and associated documentation files(the "Software"), to deal in the Software
-- without restriction, including without limitation the rights to use, copy, modify, merge,
-- publish, distribute, sublicense, and / or sell copies of the Software, and to permit persons
-- to whom the Software is furnished to do so, subject to the following conditions :
--
-- The above copyright notice and this permission notice shall be included in all copies or
-- substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.

GAME_STATE_TITLE_SCREEN =   0
GAME_STATE_PLAYING =        1
GAME_STATE_WIN =            2
GAME_STATE_DRAW =           3
GAME_STATE_LOSS =           4

-- bit flags that are used to toggle the appropriate bit when the player/AI
-- selects the relevant cell.
BOARD_TOP_LEFT =            1
BOARD_TOP_CENTER =          2
BOARD_TOP_RIGHT =           4
BOARD_MIDDLE_LEFT =         8
BOARD_MIDDLE_CENTER =       16
BOARD_MIDDLE_RIGHT =        32
BOARD_BOTTOM_LEFT =         64
BOARD_BOTTOM_CENTER =       128
BOARD_BOTTOM_RIGHT =        256
BOARD_NO_FREE_CELLS =       BOARD_TOP_LEFT | BOARD_TOP_CENTER | BOARD_TOP_RIGHT | BOARD_MIDDLE_LEFT | BOARD_MIDDLE_CENTER | BOARD_MIDDLE_RIGHT | BOARD_BOTTOM_LEFT | BOARD_BOTTOM_CENTER | BOARD_BOTTOM_RIGHT

-- winning lines
TOP_HORIZ_LINE =            BOARD_TOP_LEFT | BOARD_TOP_CENTER | BOARD_TOP_RIGHT
MIDDLE_HORIZ_LINE =         BOARD_MIDDLE_LEFT | BOARD_MIDDLE_CENTER | BOARD_MIDDLE_RIGHT
BOTTOM_HORIZ_LINE =         BOARD_BOTTOM_LEFT | BOARD_BOTTOM_CENTER | BOARD_BOTTOM_RIGHT
LEFT_VERTICAL_LINE =        BOARD_TOP_LEFT | BOARD_MIDDLE_LEFT | BOARD_BOTTOM_LEFT
MIDDLE_VERTICAL_LINE =      BOARD_TOP_CENTER | BOARD_MIDDLE_CENTER | BOARD_BOTTOM_CENTER
RIGHT_VERTICAL_LINE =       BOARD_TOP_RIGHT  | BOARD_MIDDLE_RIGHT | BOARD_BOTTOM_RIGHT
TL_TO_BR_LINE =             BOARD_TOP_LEFT | BOARD_MIDDLE_CENTER | BOARD_BOTTOM_RIGHT
TR_TO_BL_LINE =             BOARD_TOP_RIGHT | BOARD_MIDDLE_CENTER | BOARD_BOTTOM_LEFT

PLAYER_AI = 0
PLAYER_MEAT_BAG = 1

KEY_SPACE = 32
BUTTON_LEFT = 1 -- mouse button

------------------------------------------------------------------------------------------------------
--
-- GRAPHICS PROPERTIES
--
-- IF YOU CHANGE THE SIZES/LOCATIONS OF THE ART, UPDATE THESE DAYS!
--
-- hard coding this shit was painful, but time's a factor.
------------------------------------------------------------------------------------------------------
-- pixel coordianates for the top left of the board.
-- used for drawing and mouse calculations
boardCoords = { 80, 56 }

-- top left coordinate of the first cell on the board, refered to as BOARD_TOP_LEFT above.
-- These coords are needed for drawing mouse calculations; all 9 cells are tiled bitmaps,
-- so their location is tied to these coords.
initialCellCoords = { 83, 59 }

-- width and height of each cell in pixels.
cellWidth = 153
cellHeight = 113

-- width of the each grid line in pixels.
lineWidth = 7

------------------------------------------------------------------------------------------------------
--
-- END GRAPHICS PROPERTIES
--
------------------------------------------------------------------------------------------------------
-- the coordinates of each cell; this is calculated at start up and depends on the graphics
-- properties above. It's needed for determining which cell was clicked on, drawing etc.
cellCoords = {}

-- whose turn it is. It's value will be either PLAYER_AI or PLAYER_MEAT_BAG
turn = 0;

-- holds the font used to draw the text.
bmpFont = 0;

-- colour used for transparency when drawing bitmaps.
-- the game uses magenta, atm. RGB = 255, 0, 255.
gameColourKey = 0

-- width and height of the bitmap font in pixels.
-- Required for drawing.
bmpFontCharWidth = 18
bmpFontCharHeight = 18

logoSprite = 0;
boardSprite = 0;

gameState = GAME_STATE_TITLE_SCREEN

-- ints that'll have the relevant bits set each time the AI/player places a piece on the board.
-- see the BOARD_* globals above to see which cells set which bits. Essentially, we're not
-- using an array to keep track of the board like most people do; we're using individual bits.
-- It makes more sense to me. :-P
playerBoard = 0;
aiBoard = 0;

-- all the possible winning lines. Add/remove more combinations to customize the game! YAS!
winningCombinations = { TOP_HORIZ_LINE, MIDDLE_HORIZ_LINE, BOTTOM_HORIZ_LINE, LEFT_VERTICAL_LINE,
						MIDDLE_VERTICAL_LINE, RIGHT_VERTICAL_LINE, TL_TO_BR_LINE, TR_TO_BL_LINE
					}

-- counter to keep track of how many turns have been made in the current game.
round = 0;


-- .----------------. .----------------. .----------------. .----------------.
--| .--------------. | .--------------. | .--------------. | .--------------. |
--| | _____  _____ | | |      __      | | |     _____    | | |  _________   | |
--| ||_   _||_   _|| | |     /  \     | | |    |_   _|   | | | |  _   _  |  | |
--| |  | | /\ | |  | | |    / /\ \    | | |      | |     | | | |_/ | | \_|  | |
--| |  | |/  \| |  | | |   / ____ \   | | |      | |     | | |     | |      | |
--| |  |   /\   |  | | | _/ /    \ \_ | | |     _| |_    | | |    _| |_     | |
--| |  |__/  \__|  | | ||____|  |____|| | |    |_____|   | | |   |_____|    | |
--| |              | | |              | | |              | | |              | |
--| '--------------' | '--------------' | '--------------' | '--------------' |
-- '----------------' '----------------' '----------------' '----------------'

-- READ THIS FIRST BEFORE MODIFYING ANY CODE BELOW!!!!!11111oneone
--
-- V2D uses particular hooks to interact with the lua script. The functions Create(),
-- Update() and Render() implemented below are *required* functions consumed by V2D.
-- *DO NOT RENAME THESE FUNCTIONS OR CHANGE THE *NATURE* OF THEIR IMPLEMENTATION*.
-- Create() handles initialization and is called *once* -- at startup. Update() and Render()
-- are called during the each iteration of the game loop. Update() is used *only* for handling
-- game logic, Render() *only* for drawing. Mmkay? mmkay. There's also Shutdown() if you want
-- to do anything when the application terminates, but that isn't used in this script.
-- In hindsight, I probably should have given these functions a V2D_* prefix or something.
-- V2D has an internal game loop, so don't try to create one in lua; you'll just be dissapointed.

-- Also, Seattle r0x0rz j0r b0x0rz.

-- Okay, you may continue.

-- HERE ENDS THE PSA!



-- calculates the left and right pixel coordinates of each cell.
-- this is needed for drawing and determining which cell the mouse has clicked on.
-- Duh.
-- :-D
function BuildCellCoords(startingRow)
	for y = 1, 3 do
		yCellHeightStep = cellHeight * (y - 1);
		yLineStep = lineWidth * (y - 1);
		yPos = initialCellCoords[2] + yCellHeightStep + yLineStep;

		for x = 1, 3 do
			index = (y - 1) * 3 + x

			xCellWidthStep = cellWidth * (x - 1);
			xLineStep = lineWidth * (x - 1);
			xPos = initialCellCoords[1] + xCellWidthStep + xLineStep;

			cellCoords[index] = { xPos, yPos, xPos + cellWidth, yPos + cellHeight }
		end
	end
end

function ChangeState()
	gameState = gameState + 1
	Console_Print(gameState);
end

function DrawTitleScreen()
	BmpFont_PrintLine(bmpFont, 87, "TIC-TAC-HO!");
	BmpFont_PrintLine(bmpFont, 110, "v1.0");
	BmpFont_PrintLine(bmpFont, 178, "BY SETH BALLANTYNE");
	BmpFont_PrintLine(bmpFont, 201, "..AND..");
	BmpFont_PrintLine(bmpFont, 224, "VERONICA SHARMA! FUCK YEAH!");
	BmpFont_PrintLine(bmpFont, 315, "PRESS SPACE TO START");

	Sprite_Draw(logoSprite, 0, 420);
end

-- Renders the board and any pieces placed by both players
function DrawBoard()
	Sprite_Draw(boardSprite, boardCoords[1], boardCoords[2]);

	for i = 1, 9 do
		local bit = 1 << (i - 1);
		if playerBoard & bit == bit then
			DrawQuad(cellCoords[i][1], cellCoords[i][2], cellWidth, cellHeight, 255, 0, 0)
		elseif aiBoard & bit == bit then
			DrawQuad(cellCoords[i][1], cellCoords[i][2], cellWidth, cellHeight, 255, 255, 0)
		end
	end
end

-- Renders the screen that's displayed when the game ends in a draw
function DrawDrawScreen()
	BmpFont_PrintLine(bmpFont, 20, "IT'S A DRAW! YAY MEDIOCRITY!");
	DrawBoard()
	BmpFont_PrintLine(bmpFont, 443, "PRESS SPACE TO PLAY AGAIN! YAS!");
end

-- Renders the screen that's displayed when the game is being played
function DrawGameScreen()
	if turn == PLAYER_MEAT_BAG then
		BmpFont_PrintLine(bmpFont, 20, string.format("ROUND %d", round));
	end

	DrawBoard()
end

-- Renders the screen that's displayed when the game results in a loss
function DrawLossScreen()
	BmpFont_PrintLine(bmpFont, 20, "YOU LOST. HA.");
	DrawBoard()
	BmpFont_PrintLine(bmpFont, 443, "PRESS SPACE TO PLAY AGAIN! YAS!");
end

-- Renders the screen that's displayed when the game ends in a win for either player
function DrawWinScreen()
	BmpFont_PrintLine(bmpFont, 20, "YOU WIN, PIMP!");
	DrawBoard()
	BmpFont_PrintLine(bmpFont, 443, "PRESS SPACE TO PLAY AGAIN! YAS!");
end

-- The space key is used to start a game and leave the screens that are displayed
-- when the game results in a win, loss or draw. Calling this when the key is pressed
-- resets the game state.
-- This is passed to V2D during initialization; see the Create() function.
function SpaceKeyPressed()
	if gameState == GAME_STATE_TITLE_SCREEN or
	   gameState == GAME_STATE_LOSS or
	   gameState == GAME_STATE_WIN or
	   gameState == GAME_STATE_DRAW then
			aiBoard = 0
			playerBoard = 0
			gameState = GAME_STATE_PLAYING
			turn = math.random(0, 1)
			round = round + 1
	end
end

-- Handles the placing of game pieces when the mouse is clicked within a cell.
-- This is passed to V2D during initialization so it knows to call it whenever the
-- mouse is clicked: see the Create() function.
function MouseButtonClicked()
	if gameState == GAME_STATE_PLAYING and turn == PLAYER_MEAT_BAG then
		local x, y = Input_GetMouseXY()
		for i = 1, 9 do
			local xExpr = (x >= cellCoords[i][1]) and (x <= cellCoords[i][3]);
			local yExpr = (y >= cellCoords[i][2]) and (y <= cellCoords[i][4]);

			if xExpr and yExpr then
				local bit = 1 << (i - 1);
				if CellIsEmpty(bit) then
					PlacePiece(PLAYER_MEAT_BAG, bit)

					if CheckForPossibleWin(PLAYER_MEAT_BAG, 0) then
						gameState = GAME_STATE_WIN
					elseif (aiBoard | playerBoard) == BOARD_NO_FREE_CELLS then
						gameState = GAME_STATE_DRAW
					else
						turn = PLAYER_AI
					end
				end
			--	local bit = 1 << (i - 1);
			--	if playerBoard & bit ~= bit and aiBoard & bit ~= bit then
			--		Console_Print("Placing players piece");
			--		playerBoard = (playerBoard | bit);
			--		turn = PLAYER_AI
			--	end

			--	return
			end
		end
	end
end

-- called by V2D during initilization; put all the init code here.
-- DON'T RENAME THIS FUNCTION.
function Create()
    gameColourKey = Video_MapRGB(255, 0, 255);

    bmpFont = BmpFont_Load(bmpFontCharWidth, bmpFontCharHeight, "data//art//green_font.bmp", gameColourKey);
    logoSprite = Sprite_Load("data//art//logo.png", -1);
    boardSprite = Sprite_Load("data//art//blank_grid.png", gameColourKey);

    Input_RegisterKey(KEY_SPACE, SpaceKeyPressed)
    Input_RegisterMouseButton(BUTTON_LEFT, MouseButtonClicked)

    BuildCellCoords()
end

-- returns 1 if the specified bit hasn't been set, else returns 0.
-- bit: the integer being used to keep track of the pieces placed by each player (playerBoard and aiBoard)
function CellIsEmpty(bit)
	return ((playerBoard | aiBoard) & bit) ~= bit
end

-- scans the board for winning lines.
-- returns true if one is found, otherwise false.
function CheckForPossibleWin(playerType, bit)

	local tempBoard = 0

	if playerType == PLAYER_AI then
		tempBoard = aiBoard | bit
	else
		tempBoard = playerBoard | bit
	end

	for i = 1, 8 do
		if tempBoard & winningCombinations[i] == winningCombinations[i] then
			return true
		end
	end

	return false
end

function PlacePiece(playerType, bit)
	if playerType == PLAYER_AI then
		aiBoard = aiBoard | bit;
	else
		playerBoard = playerBoard | bit;
	end
end

function ProcessAI()

	-- check for any possible moves that will result in the AI winning in this round.
	for i = 1, 9 do
		local bit = 1 << (i - 1)

		if CellIsEmpty(bit) == true then
			--local result = CheckForPossibleWin(PLAYER_AI, bit)
			if CheckForPossibleWin(PLAYER_AI, bit) then
				PlacePiece(PLAYER_AI, bit)
				return 2
			end
		end
	end

	-- no possible wins during this turn, so check to see if there's a possible win
	-- for the player and block it.
	for i = 1, 9 do
		local bit = 1 << (i - 1)

		if CellIsEmpty(bit) == true then
			--local result = CheckForPossibleWin(PLAYER_MEAT_BAG, bit)
			if CheckForPossibleWin(PLAYER_MEAT_BAG, bit) then
				PlacePiece(PLAYER_AI, bit)
				return 1
			end
		end
	end


	-- just find a blank and place a piece ffs
	-- step 1: build a list of available cells
	local availableCells = {}

	for i = 1, 9 do
		local bit = 1 << (i - 1)

		if (playerBoard | aiBoard) & bit ~= bit then
			-- bit hasn't been set, so the AI can place its piece here
			local tableSize = #availableCells
			availableCells[tableSize + 1] = i
		end
	end

	-- got our list, now choose a cell and place the piece there
	local index = math.random(1, #availableCells)
	local bit = 1 << (availableCells[index] - 1)
	PlacePiece(PLAYER_AI, bit)
end

-- Called by V2D within the game loop; handle game processing here.
function Update()
	if gameState == GAME_STATE_PLAYING and turn == PLAYER_AI then
		local result = ProcessAI()

		if result == 2 then -- AI has won
			gameState = GAME_STATE_LOSS;
			return
		elseif aiBoard | playerBoard == BOARD_NO_FREE_CELLS then
			gameState = GAME_STATE_DRAW
		else
			turn = PLAYER_MEAT_BAG
		end
	end
end

-- Called by V2D each frame; handle graphics rendering here, obviously.
function Render()
	if gameState == GAME_STATE_PLAYING then
		DrawGameScreen()
	elseif gameState == GAME_STATE_WIN then
	    DrawWinScreen()
	elseif gameState == GAME_STATE_LOSS then
	    DrawLossScreen()
	elseif gameState == GAME_STATE_DRAW then
	    DrawDrawScreen()
	elseif gameState == GAME_STATE_TITLE_SCREEN then
		DrawTitleScreen()
	end
end

-- called by V2D; don't rename.
-- this is called when the program terminates, so dump clean up code here.
function Shutdown()

end
