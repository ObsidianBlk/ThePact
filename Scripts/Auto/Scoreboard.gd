extends Node

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const MAX_BOARD_ENTRIES : int = 10

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _board_lived : Array = []
var _board_ghost : Array = []


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _PositionOnBoard(board : Array, score : int) -> int:
	for i in range(0, board.size()):
		if board[i][&"score"] < score:
			return i
	return -1

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func record_score(player_name : String, score : int, time : float, defeated_ghosts : bool) -> void:
	var board = _board_ghost if defeated_ghosts else _board_lived
	var idx = _PositionOnBoard(board, score)
	if idx >= 0:
		pass

