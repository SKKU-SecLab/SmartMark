
pragma solidity ^0.8.10;

contract ConnectFour {


	error InvalidMove();

	error Unauthorized();

	error GameFinished();


	event GameProposed(address indexed challenger, address indexed challenged);

	event MovePerformed(address indexed mover, uint256 gameId, uint8 row);

	event GameWon(address indexed winner, uint256 gameId);

	struct Game {
		address player1;
		address player2;
		uint64[7] height;
		uint64[2] board;
		uint8 moves;
		bool finished;
	}

	uint64[7] internal initialHeight;

	uint64 internal constant topColumn = 283691315109952;

	uint256 internal gameId = 1;

	mapping(uint256 => Game) public getGame;

	constructor() payable {
		unchecked {
			for (uint8 i = 0; i < 7; i++) {
				initialHeight[i] = uint64(7 * i);
			}
		}
	}

	function challenge(address opponent) public payable returns (uint256) {

		Game memory game = Game({
			player1: opponent,
			player2: msg.sender,
			height: initialHeight,
			board: [uint64(0), uint64(0)],
			moves: 0,
			finished: false
		});

		emit GameProposed(msg.sender, opponent);

		getGame[gameId] = game;

		return gameId++;
	}

	function makeMove(uint256 gameId, uint8 row) public payable {

		Game storage game = getGame[gameId];
		if (msg.sender != (game.moves & 1 == 0 ? game.player1 : game.player2)) revert Unauthorized();
		if (game.finished) revert GameFinished();

		emit MovePerformed(msg.sender, gameId, row);

		game.board[game.moves & 1] ^= uint64(1) << game.height[row]++;

		if ((game.board[game.moves & 1] & topColumn) != 0) revert InvalidMove();

		if (didPlayerWin(gameId, game.moves++ & 1)) {
			game.finished = true;
			emit GameWon(msg.sender, gameId);
		}
	}

	function didPlayerWin(uint256 gameId, uint8 side) public view returns (bool) {

		uint64 board = getGame[gameId].board[side];
		uint8[4] memory directions = [1, 7, 6, 8];

		uint64 bb;

		unchecked {
			for (uint8 i = 0; i < 4; i++) {
				bb = board & (board >> directions[i]);
				if ((bb & (bb >> (2 * directions[i]))) != 0) return true;
			}
		}

		return false;
	}

	function getBoards(uint256 gameId) public view returns (uint64, uint64) {

		uint64[2] memory boards = getGame[gameId].board;

		return (boards[0], boards[1]);
	}
}