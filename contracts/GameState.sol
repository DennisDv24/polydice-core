//SPDX-License-Identifier: MIT

pragma ^0.8.6;

enum GameState {
	CanStartNewGame,
	StartingNewGame,
	WaitingForPlayers,
	GameIsFull,
	CalculatingWinner,
	GameHasEnded
}
