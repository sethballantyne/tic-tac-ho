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

function DrawDrawScreen()
	BmpFont_PrintLine(bmpFont, 20, "IT'S A GAPER!");
	BmpFont_PrintLine(bmpFont, 443, "PRESS SPACE TO PLAY AGAIN! YAS!");
end

function DrawGameScreen()
	Sprite_Draw(boardSprite, boardCoords[1], boardCoords[2]);

	for i = 1, 9 do
		local bit = 1 << (i - 1);
		if playerBoard & bit == bit then
			DrawQuad(cellCoords[i][1], cellCoords[i][2], cellWidth, cellHeight, 255, 0, 0)
		end
	end
end

function DrawLossScreen()
	BmpFont_PrintLine(bmpFont, 20, "YOU LOST. HA.");
	BmpFont_PrintLine(bmpFont, 443, "PRESS SPACE TO PLAY AGAIN! YAS!");
end

function DrawWinScreen()
	BmpFont_PrintLine(bmpFont, 20, "YOU WIN, PIMP!");
	BmpFont_PrintLine(bmpFont, 443, "PRESS SPACE TO PLAY AGAIN! YAS!");
end

function SpaceKeyPressed()
	if gameState == GAME_STATE_TITLE_SCREEN then
		gameState = GAME_STATE_PLAYING
	end
end

function MouseButtonClicked()
	if gameState == GAME_STATE_PLAYING and turn == TURN_PLAYER then
		local x, y = Input_GetMouseXY()
		for i = 1, 9 do
			local xExpr = (x >= cellCoords[i][1]) and (x <= cellCoords[i][3]);
			local yExpr = (y >= cellCoords[i][2]) and (y <= cellCoords[i][4]);

			if xExpr and yExpr then
				local bit = 1 << (i - 1);
				if playerBoard & bit ~= bit then
					playerBoard = (playerBoard | bit);
				end

				return
			end
		end
	end
end

function Create()
	gameColourKey = Video_MapRGB(255, 0, 255);

	bmpFont = BmpFont_Load(bmpFontCharWidth, bmpFontCharHeight, "green_font.bmp", gameColourKey);
	logoSprite = Sprite_Load("logo.png", -1);
	boardSprite = Sprite_Load("blank_grid.png", gameColourKey);

    Input_RegisterKey(KEY_SPACE, SpaceKeyPressed)
    Input_RegisterMouseButton(BUTTON_LEFT, MouseButtonClicked)

    BuildCellCoords()
end

function Update()

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
