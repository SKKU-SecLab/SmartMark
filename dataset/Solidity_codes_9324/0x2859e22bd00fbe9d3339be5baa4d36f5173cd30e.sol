
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;


interface IERC1155Receiver is IERC165 {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155MetadataURI is IERC1155 {

    function uri(uint256 id) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {

    using Address for address;

    mapping(uint256 => mapping(address => uint256)) private _balances;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    string private _uri;

    constructor(string memory uri_) {
        _setURI(uri_);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function uri(uint256) public view virtual override returns (string memory) {

        return _uri;
    }

    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {

        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {

        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(_msgSender() != operator, "ERC1155: setting approval status for self");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[account][operator];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {

        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {

        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {

        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {

        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    function _setURI(string memory newuri) internal virtual {

        _uri = newuri;
    }

    function _mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {

        require(account != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), account, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][account] += amount;
        emit TransferSingle(operator, address(0), account, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), account, id, amount, data);
    }

    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {

        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    function _burn(
        address account,
        uint256 id,
        uint256 amount
    ) internal virtual {

        require(account != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        uint256 accountBalance = _balances[id][account];
        require(accountBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][account] = accountBalance - amount;
        }

        emit TransferSingle(operator, account, address(0), id, amount);
    }

    function _burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {

        require(account != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 accountBalance = _balances[id][account];
            require(accountBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][account] = accountBalance - amount;
            }
        }

        emit TransferBatch(operator, account, address(0), ids, amounts);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}


    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {

        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {

        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {

        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}// MIT
pragma solidity >=0.8.7 <0.9.0;


contract Prize is ERC1155, Ownable {

	uint256 public constant CURRENT_FIRST = 1;
	uint256 public constant CURRENT_SECOND = 2;
	uint256 public constant CURRENT_THIRD = 3;
	uint256 public constant HALL_OF_FAME_FIRST = 4;
	uint256 public constant PARTICIPANT = 5;

	string public constant name = "PAY.GAME";
	string public constant symbol = "PAY";

	address public game;
	string private _contractURI;

	constructor(string memory tokenURI, string memory myContractURI) ERC1155(tokenURI) {
		_contractURI = myContractURI;
	}

	function contractURI() public view returns (string memory) {

		return _contractURI;
	}

	function setGame(address _game) public onlyOwner {

		require(game == address(0), "Game is already set");

		game = _game;
	}

	function setTokenURI(string memory tokenURI) public onlyOwner {

		_setURI(tokenURI);
	}

	function setContractURI(string memory myContractURI) public onlyOwner {

		_contractURI = myContractURI;
	}

	function mint(
		address to,
		uint256 id,
		uint256 amount,
		bytes memory data
	)
	public onlyGame
	{

		_mint(to, id, amount, data);
	}

	function mintBatch(
		address to,
		uint256[] memory ids,
		uint256[] memory amounts,
		bytes memory data
	)
	public onlyGame
	{

		_mintBatch(to, ids, amounts, data);
	}

	function isApprovedForAll(
		address account,
		address operator
	)
	public view virtual override returns (bool)
	{

		return _msgSender() == game || super.isApprovedForAll(account, operator);
	}

	function _beforeTokenTransfer(
		address operator,
		address from,
		address to,
		uint256[] memory ids,
		uint256[] memory amounts,
		bytes memory data
	)
	internal override(ERC1155)
	{

		if(_msgSender() != game) {
			for (uint256 i = 0; i < ids.length; ++i) {
				uint256 id = ids[i];
				require(id != CURRENT_FIRST, "Cannot transfer #1 place token");
				require(id != CURRENT_SECOND, "Cannot transfer #2 place token");
				require(id != CURRENT_THIRD, "Cannot transfer #3 place token");
			}
		}

		super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
	}

	modifier onlyGame() {

		require(_msgSender() == game, "Caller is not the game");
		_;
	}
}//MIT

pragma solidity >=0.8.7 <0.9.0;


contract Game is Ownable {

	uint256 private constant CURRENT_FIRST = 1;
	uint256 private constant CURRENT_SECOND = 2;
	uint256 private constant CURRENT_THIRD = 3;
	uint256 private constant HALL_OF_FAME_FIRST = 4;
	uint256 private constant PARTICIPANT = 5;


	struct Player {
		bytes32 name;
		string url;
		uint64 lastPayment;
		uint128 score;
		bool receivedPastFirstPrize;
	}

	struct HighScore {
		uint96 score;
		address addr;
	}

	HighScore[3] public highScores;



	address payable private _owner;
	Prize public immutable prize;
	address[] public playerAddresses;
	mapping(address => Player) public players;



	event NewPayment(address addr, Player player, uint value);



	constructor(
		address prizeAddress
	) Ownable() {
		_owner = payable(_msgSender());
		prize = Prize(prizeAddress);
	}

	function pay(
		string memory name,
		string memory url
	) external payable {

		require(bytes(name).length != 0, "Name can't be blank");
		require(_validAsciiString(name), "Name can't contain special chars");
		require(bytes(name).length <= 32, "Max name length is 32 bytes");
		require(bytes(url).length <= 128, "Max URL length is 128 bytes");

		Player storage player = players[_msgSender()];

		bytes32 nameBytes = stringToBytes32(name);

		if(player.score == 0) {
			playerAddresses.push(_msgSender());
			prize.mint(_msgSender(), PARTICIPANT, 1, "");

			player.name = nameBytes;
			player.url = url;
		} else {
			if (nameBytes != player.name) {
				player.name = nameBytes;
			}
			if (keccak256(abi.encodePacked((url))) != keccak256(abi.encodePacked((player.url)))) {
				player.url = url;
			}
		}

		_createPayment();
	}

	function lifetimeBalance() external view returns (uint256) {

		uint256 total = 0;
		for (uint256 i = 0; i < playerAddresses.length; i++) {
			total += players[playerAddresses[i]].score;
		}
		return total;
	}

	function getPlayers() external view returns (Player[] memory) {

		Player[] memory allPlayers = new Player[](playerAddresses.length);

		for(uint i; i < playerAddresses.length; i++){
			allPlayers[i] = players[playerAddresses[i]];
		}

		return allPlayers;
	}

	function getPlayerAddresses() external view returns (address[] memory) {

		return playerAddresses;
	}

	receive() external payable {
		if(players[_msgSender()].score == 0) {
			prize.mint(_msgSender(), PARTICIPANT, 1, "");
			playerAddresses.push(_msgSender());
			players[_msgSender()] = Player(stringToBytes32("Anonymous"), "", 0, 0, false);
		}

		_createPayment();
	}

	function withdrawAll() public onlyOwner {

		_owner.transfer(address(this).balance);
	}

	function withdraw(uint amount) public onlyOwner {

		require(amount <= address(this).balance, "Amount exceeds balance");
		_owner.transfer(amount);
	}

	function withdrawTo(
		uint amount,
		address payable to
	) public onlyOwner {

		require(amount <= address(this).balance, "Amount exceeds balance");

		to.transfer(amount);
	}


	function _sortHighScores(
		uint96 newScore
	) private {

		if(newScore <= highScores[2].score) return;

		uint i;

		HighScore[3] memory previousHighScores = highScores;

		for(; i < previousHighScores.length; i++) {
			if(newScore > previousHighScores[i].score) {
				if(_msgSender() == previousHighScores[i].addr) {
					highScores[i].score = newScore;
					return;
				}

				highScores[i].score = newScore;
				highScores[i].addr = _msgSender();

				break;
			}
		}


		i++;

		uint j = i;

		for(; i < highScores.length; i++) {
			if(previousHighScores[j - 1].addr == _msgSender()) {
				j++;
			}

			highScores[i].score = previousHighScores[j - 1].score;
			highScores[i].addr = previousHighScores[j - 1].addr;
			j++;
		}
	}

	function _createPayment() private {

		require(msg.value >= 0.01 ether, "Minimum amount is 0.01 ETH");

		Player storage player = players[_msgSender()];

		player.score += uint128(msg.value);
		player.lastPayment = uint64(block.timestamp);

		uint96 newScore = uint96(player.score);

		emit NewPayment(_msgSender(), player, msg.value);

		if(newScore <= highScores[2].score) return;

		HighScore[3] memory previousHighScores = highScores;

		_sortHighScores(newScore);

		if(highScores[0].addr != previousHighScores[0].addr) {

			if(previousHighScores[0].addr == address(0)) {
				prize.mint(highScores[0].addr, CURRENT_FIRST, 1, "");
			} else {
				prize.safeTransferFrom(previousHighScores[0].addr, highScores[0].addr, CURRENT_FIRST, 1, "");

				if(players[previousHighScores[0].addr].receivedPastFirstPrize != true) {
					prize.mint(previousHighScores[0].addr, HALL_OF_FAME_FIRST, 1, "");
					players[previousHighScores[0].addr].receivedPastFirstPrize = true;
				}
			}
		}

		if(highScores[1].addr != previousHighScores[1].addr) {

			if(previousHighScores[1].addr == address(0)) {
				prize.mint(highScores[1].addr, CURRENT_SECOND, 1, "");
			} else {
				prize.safeTransferFrom(previousHighScores[1].addr, highScores[1].addr, CURRENT_SECOND, 1, "");
			}
		}

		if(highScores[2].addr != previousHighScores[2].addr) {

			if(previousHighScores[2].addr == address(0)) {
				prize.mint(highScores[2].addr, CURRENT_THIRD, 1, "");
			} else {
				prize.safeTransferFrom(previousHighScores[2].addr, highScores[2].addr, CURRENT_THIRD, 1, "");
			}
		}
	}

	function stringToBytes32(string memory source) public pure returns (bytes32 result) {

		bytes memory tempEmptyStringTest = bytes(source);
		if (tempEmptyStringTest.length == 0) {
			return 0x0;
		}

		assembly {
			result := mload(add(source, 32))
		}
	}

	function _validAsciiString(string memory text) private pure returns (bool) {

		bytes memory b = bytes(text);

		for(uint i; i < b.length; i++){
			if(!(b[i] >= 0x20 && b[i] <= 0x7E)) return false;
		}

		return true;
	}
}