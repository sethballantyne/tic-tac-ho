GAME_STATE_TITLE_SCREEN = 	0
GAME_STATE_PLAYING = 		1
GAME_STATE_WIN = 			2
GAME_STATE_DRAW = 			3
GAME_STATE_LOSS = 			4

BOARD_TOP_LEFT =			1
BOARD_TOP_CENTER =			2
BOARD_TOP_RIGHT =			4
BOARD_MIDDLE_LEFT =			8
BOARD_MIDDLE_CENTER =		16
BOARD_MIDDLE_RIGHT =		32
BOARD_BOTTOM_LEFT =			64
BOARD_BOTTOM_CENTER = 		128
BOARD_BOTTOM_RIGHT =		256
BOARD_NO_FREE_CELLS =       BOARD_TOP_LEFT | BOARD_TOP_CENTER | BOARD_TOP_RIGHT | BOARD_MIDDLE_LEFT | BOARD_MIDDLE_CENTER | BOARD_MIDDLE_RIGHT | BOARD_BOTTOM_LEFT | BOARD_BOTTOM_CENTER | BOARD_BOTTOM_RIGHT

TOP_HORIZ_LINE = 			BOARD_TOP_LEFT | BOARD_TOP_CENTER | BOARD_TOP_RIGHT
MIDDLE_HORIZ_LINE = 		BOARD_MIDDLE_LEFT | BOARD_MIDDLE_CENTER | BOARD_MIDDLE_RIGHT
BOTTOM_HORIZ_LINE = 		BOARD_BOTTOM_LEFT | BOARD_BOTTOM_CENTER | BOARD_BOTTOM_RIGHT
LEFT_VERTICAL_LINE =        BOARD_TOP_LEFT | BOARD_MIDDLE_LEFT | BOARD_BOTTOM_LEFT
MIDDLE_VERTICAL_LINE =      BOARD_TOP_CENTER | BOARD_MIDDLE_CENTER | BOARD_BOTTOM_CENTER
RIGHT_VERTICAL_LINE = 		BOARD_TOP_RIGHT  | BOARD_MIDDLE_RIGHT | BOARD_BOTTOM_RIGHT
TL_TO_BR_LINE =				BOARD_TOP_LEFT | BOARD_MIDDLE_CENTER | BOARD_BOTTOM_RIGHT
TR_TO_BL_LINE = 			BOARD_TOP_RIGHT | BOARD_MIDDLE_CENTER | BOARD_BOTTOM_LEFT

TURN_PLAYER = 0
TURN_AI = 0

PLAYER_AI = 0
PLAYER_MEAT_BAG = 1

KEY_SPACE = 32
BUTTON_LEFT = 1

boardCoords = { 80, 56 }
initialCellCoords = { 83, 59 }
cellWidth = 153
cellHeight = 113
lineWidth = 7

cellCoords = {}

turn = 0;
bmpFont = 0;
gameColourKey = 0
bmpFontCharWidth = 18
bmpFontCharHeight = 18

logoSprite = 0;
boardSprite = 0;

gameState = GAME_STATE_TITLE_SCREEN

playerBoard = 0;
aiBoard = 0;

winningCombinations = { TOP_HORIZ_LINE, MIDDLE_HORIZ_LINE, BOTTOM_HORIZ_LINE, LEFT_VERTICAL_LINE,
						MIDDLE_VERTICAL_LINE, RIGHT_VERTICAL_LINE, TL_TO_BR_LINE, TR_TO_BL_LINE
					}

round = 0;

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
	BmpFont_PrintLine(bmpFont, 110, "v0.1");
	BmpFont_PrintLine(bmpFont, 178, "BY SETH BALLANTYNE");
	BmpFont_PrintLine(bmpFont, 201, "..AND..");
	BmpFont_PrintLine(bmpFont, 224, "VERONICA SHARMA! FUCK YEAH!");
	BmpFont_PrintLine(bmpFont, 315, "PRESS SPACE TO START");

	Sprite_Draw(logoSprite, 0, 420);
end

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

function DrawDrawScreen()
	BmpFont_PrintLine(bmpFont, 20, "IT'S A GAPER!");
	DrawBoard()
	BmpFont_PrintLine(bmpFont, 443, "PRESS SPACE TO PLAY AGAIN! YAS!");
end

function DrawGameScreen()
	if turn == PLAYER_MEAT_BAG then
		BmpFont_PrintLine(bmpFont, 20, string.format("ROUND %d", round));
	end

	DrawBoard()
end

function DrawLossScreen()
	BmpFont_PrintLine(bmpFont, 20, "YOU LOST. HA.");
	DrawBoard()
	BmpFont_PrintLine(bmpFont, 443, "PRESS SPACE TO PLAY AGAIN! YAS!");
end

function DrawWinScreen()
	BmpFont_PrintLine(bmpFont, 20, "YOU WIN, PIMP!");
	DrawBoard()
	BmpFont_PrintLine(bmpFont, 443, "PRESS SPACE TO PLAY AGAIN! YAS!");
end

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
					turn = PLAYER_AI
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

function Create()
	gameColourKey = Video_MapRGB(255, 0, 255);

	bmpFont = BmpFont_Load(bmpFontCharWidth, bmpFontCharHeight, "data//art//green_font.bmp", gameColourKey);
	logoSprite = Sprite_Load("data//art//logo.png", -1);
	boardSprite = Sprite_Load("data//art//blank_grid.png", gameColourKey);

    Input_RegisterKey(KEY_SPACE, SpaceKeyPressed)
    Input_RegisterMouseButton(BUTTON_LEFT, MouseButtonClicked)

    BuildCellCoords()
end

function CellIsEmpty(bit)
	return ((playerBoard | aiBoard) & bit) ~= bit
end

function CheckForPossibleWin(playerType, bit)

	local tempBoard = 0

	if playerType == PLAYER_AI then
		tempBoard = aiBoard | bit
	else
		tempBoard = playerBoard | bit
	end

	for i = 1, 8 do
		if tempBoard & winningCombinations[i] == winningCombinations[i] then
			Console_Print(string.format("CheckForPossibleWin: Winning combination %d hit. Index: %d", winningCombinations[i], i))
			return 1
		end
	end

	return 0
end

function PlacePiece(playerType, bit)
	if playerType == PLAYER_AI then
		Console_Print(string.format("AI putting piece at %d", bit))
		aiBoard = aiBoard | bit;
	else
		Console_Print(string.format("Player putting piece at %d", bit))
		playerBoard = playerBoard | bit;
	end
end

function ProcessAI()
	Console_Print("AI taking it's turn.");
	-- check for any possible moves that will result in the AI winning in this round.
	for i = 1, 9 do
		local bit = 1 << (i - 1)

		if CellIsEmpty(bit) == true then
			local result = CheckForPossibleWin(PLAYER_AI, bit)
			if result == 1 then
				Console_Print(string.format("AI making a winning move at cell index %d", i));
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
			local result = CheckForPossibleWin(PLAYER_MEAT_BAG, bit)
			if result == 1 then
				Console_Print(string.format("AI making a blocking move at cell index %d", i));
				PlacePiece(PLAYER_AI, bit)
				return 1
			end
		end
	end


	-- just find a blank and place a piece ffs
	-- step 1: build a list of available cells
	local availableCells = {}
	local debugStr = "";
	for i = 1, 9 do
		local bit = 1 << (i - 1)

		if (playerBoard | aiBoard) & bit ~= bit then
			-- bit hasn't been set, so the AI can place its piece here
			local tableSize = #availableCells
			availableCells[tableSize + 1] = i
			debugStr = debugStr .. string.format("  %d", i)
		end
	end

	Console_Print("Available cells: " .. debugStr)

	-- got our list, now choose a cell and place the piece there
	local index = math.random(1, #availableCells)
	local bit = 1 << (availableCells[index] - 1)
	PlacePiece(PLAYER_AI, bit)
end

function Update()
	local gameBoard = aiBoard | playerBoard;
	Console_Print(string.format("Update: gameboard: %d BOARD_NO_FREE_CELLS:  %d gameState: %d", gameBoard,BOARD_NO_FREE_CELLS, gameState))

	if gameBoard == BOARD_NO_FREE_CELLS and gameState == GAME_STATE_PLAYING then
		if CheckForPossibleWin(PLAYER_MEAT_BAG, 0) == 1 then
			Console_Print(string.format("Round %d WIN!", round))
			gameState = GAME_STATE_WIN
		else
			Console_Print(string.format("Round %d DRAW!", round))
			gameState = GAME_STATE_DRAW
		end
	elseif gameState == GAME_STATE_PLAYING and turn == PLAYER_AI then
		local result = ProcessAI()

		if result == 2 then -- AI has won
			Console_Print(string.format("Round %d LOSS!", round))
			gameState = GAME_STATE_LOSS;
			return
		end

		turn = PLAYER_MEAT_BAG
	end
end

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

function Shutdown()

end
