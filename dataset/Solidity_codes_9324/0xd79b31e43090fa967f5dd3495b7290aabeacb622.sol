
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;


    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

}// MIT

pragma solidity ^0.8.0;


interface IERC1155Receiver is IERC165 {


    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId
            || super.supportsInterface(interfaceId);
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC1155Holder is ERC1155Receiver {

    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


contract ERC721Holder is IERC721Receiver {


    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
}// GPL-3.0

pragma solidity ^0.8.1;


contract SwapKiwi is Ownable, ERC721Holder, ERC1155Holder {


	uint64 private _swapsCounter;
	uint128 private _etherLocked;
	uint128 public fee;

	mapping (uint64 => Swap) private _swaps;

	struct Swap {
		address payable initiator;
		address[] initiatorNftAddresses;
		uint256[] initiatorNftIds;
		uint256[] initiatorNftAmounts;
		address payable secondUser;
		address[] secondUserNftAddresses;
		uint256[] secondUserNftIds;
		uint256[] secondUserNftAmounts;
		uint128 initiatorEtherValue;
		uint128 secondUserEtherValue;
	}

	event SwapExecuted(address indexed from, address indexed to, uint64 indexed swapId);
	event SwapCanceled(address indexed canceledBy, uint64 indexed swapId);
	event SwapProposed(
		address indexed from,
		address indexed to,
		uint64 indexed swapId,
		uint128 etherValue,
		address[] nftAddresses,
		uint256[] nftIds,
		uint256[] nftAmounts
	);
	event SwapInitiated(
		address indexed from,
		address indexed to,
		uint64 indexed swapId,
		uint128 etherValue,
		address[] nftAddresses,
		uint256[] nftIds,
		uint256[] nftAmounts
	);
	event AppFeeChanged(
		uint128 fee
	);

	modifier onlyInitiator(uint64 swapId) {

		require(msg.sender == _swaps[swapId].initiator,
			"SwapKiwi: caller is not swap initiator");
		_;
	}

	modifier requireSameLength(address[] memory nftAddresses, uint256[] memory nftIds, uint256[] memory nftAmounts) {

		require(nftAddresses.length == nftIds.length, "SwapKiwi: NFT and ID arrays have to be same length");
		require(nftAddresses.length == nftAmounts.length, "SwapKiwi: NFT and AMOUNT arrays have to be same length");
		_;
	}

	modifier chargeAppFee() {

		require(msg.value >= fee, "SwapKiwi: Sent ETH amount needs to be more or equal application fee");
		_;
	}

	constructor(uint128 initalAppFee, address contractOwnerAddress) {
		fee = initalAppFee;
		super.transferOwnership(contractOwnerAddress);
	}

	function setAppFee(uint128 newFee) external onlyOwner {

		fee = newFee;
		emit AppFeeChanged(newFee);
	}

	function proposeSwap(
		address secondUser,
		address[] memory nftAddresses,
		uint256[] memory nftIds,
		uint256[] memory nftAmounts
	) external payable chargeAppFee requireSameLength(nftAddresses, nftIds, nftAmounts) {

		_swapsCounter += 1;

		safeMultipleTransfersFrom(
			msg.sender,
			address(this),
			nftAddresses,
			nftIds,
			nftAmounts
		);

		Swap storage swap = _swaps[_swapsCounter];
		swap.initiator = payable(msg.sender);
		swap.initiatorNftAddresses = nftAddresses;
		swap.initiatorNftIds = nftIds;
		swap.initiatorNftAmounts = nftAmounts;

		uint128 _fee = fee;

		if (msg.value > _fee) {
			swap.initiatorEtherValue = uint128(msg.value) - _fee;
			_etherLocked += swap.initiatorEtherValue;
		}
		swap.secondUser = payable(secondUser);

		emit SwapProposed(
			msg.sender,
			secondUser,
			_swapsCounter,
			swap.initiatorEtherValue,
			nftAddresses,
			nftIds,
			nftAmounts
		);
	}

	function initiateSwap(
		uint64 swapId,
		address[] memory nftAddresses,
		uint256[] memory nftIds,
		uint256[] memory nftAmounts
	) external payable chargeAppFee requireSameLength(nftAddresses, nftIds, nftAmounts) {

		require(_swaps[swapId].secondUser == msg.sender, "SwapKiwi: caller is not swap participator");
		require(
			_swaps[swapId].secondUserEtherValue == 0 &&
			( _swaps[swapId].secondUserNftAddresses.length == 0 &&
			_swaps[swapId].secondUserNftIds.length == 0 &&
			_swaps[swapId].secondUserNftAmounts.length == 0
			), "SwapKiwi: swap already initiated"
		);

		safeMultipleTransfersFrom(
			msg.sender,
			address(this),
			nftAddresses,
			nftIds,
			nftAmounts
		);

		_swaps[swapId].secondUserNftAddresses = nftAddresses;
		_swaps[swapId].secondUserNftIds = nftIds;
		_swaps[swapId].secondUserNftAmounts = nftAmounts;

		uint128 _fee = fee;

		if (msg.value > _fee) {
			_swaps[swapId].secondUserEtherValue = uint128(msg.value) - _fee;
			_etherLocked += _swaps[swapId].secondUserEtherValue;
		}

		emit SwapInitiated(
			msg.sender,
			_swaps[swapId].initiator,
			swapId,
			_swaps[swapId].secondUserEtherValue,
			nftAddresses,
			nftIds,
			nftAmounts
		);
	}

	function acceptSwap(uint64 swapId) external onlyInitiator(swapId) {

		require(
			(_swaps[swapId].secondUserNftAddresses.length != 0 || _swaps[swapId].secondUserEtherValue > 0) &&
			(_swaps[swapId].initiatorNftAddresses.length != 0 || _swaps[swapId].initiatorEtherValue > 0),
			"SwapKiwi: Can't accept swap, both participants didn't add NFTs"
		);

		safeMultipleTransfersFrom(
			address(this),
			_swaps[swapId].initiator,
			_swaps[swapId].secondUserNftAddresses,
			_swaps[swapId].secondUserNftIds,
			_swaps[swapId].secondUserNftAmounts
		);

		safeMultipleTransfersFrom(
			address(this),
			_swaps[swapId].secondUser,
			_swaps[swapId].initiatorNftAddresses,
			_swaps[swapId].initiatorNftIds,
			_swaps[swapId].initiatorNftAmounts
		);

		if (_swaps[swapId].initiatorEtherValue != 0) {
			_etherLocked -= _swaps[swapId].initiatorEtherValue;
			uint128 amountToTransfer = _swaps[swapId].initiatorEtherValue;
			_swaps[swapId].initiatorEtherValue = 0;
			_swaps[swapId].secondUser.transfer(amountToTransfer);
		}
		if (_swaps[swapId].secondUserEtherValue != 0) {
			_etherLocked -= _swaps[swapId].secondUserEtherValue;
			uint128 amountToTransfer = _swaps[swapId].secondUserEtherValue;
			_swaps[swapId].secondUserEtherValue = 0;
			_swaps[swapId].initiator.transfer(amountToTransfer);
		}

		emit SwapExecuted(_swaps[swapId].initiator, _swaps[swapId].secondUser, swapId);

		delete _swaps[swapId];
	}

	function cancelSwap(uint64 swapId) external {

		require(
			_swaps[swapId].initiator == msg.sender || _swaps[swapId].secondUser == msg.sender,
			"SwapKiwi: Can't cancel swap, must be swap participant"
		);
		safeMultipleTransfersFrom(
			address(this),
			_swaps[swapId].initiator,
			_swaps[swapId].initiatorNftAddresses,
			_swaps[swapId].initiatorNftIds,
			_swaps[swapId].initiatorNftAmounts
		);

		if(_swaps[swapId].secondUserNftAddresses.length != 0) {
			safeMultipleTransfersFrom(
				address(this),
				_swaps[swapId].secondUser,
				_swaps[swapId].secondUserNftAddresses,
				_swaps[swapId].secondUserNftIds,
				_swaps[swapId].secondUserNftAmounts
			);
		}

		if (_swaps[swapId].initiatorEtherValue != 0) {
			_etherLocked -= _swaps[swapId].initiatorEtherValue;
			uint128 amountToTransfer = _swaps[swapId].initiatorEtherValue;
			_swaps[swapId].initiatorEtherValue = 0;
			_swaps[swapId].initiator.transfer(amountToTransfer);
		}
		if (_swaps[swapId].secondUserEtherValue != 0) {
			_etherLocked -= _swaps[swapId].secondUserEtherValue;
			uint128 amountToTransfer = _swaps[swapId].secondUserEtherValue;
			_swaps[swapId].secondUserEtherValue = 0;
			_swaps[swapId].secondUser.transfer(amountToTransfer);
		}

		emit SwapCanceled(msg.sender, swapId);

		delete _swaps[swapId];
	}

	function safeMultipleTransfersFrom(
		address from,
		address to,
		address[] memory nftAddresses,
		uint256[] memory nftIds,
		uint256[] memory nftAmounts
	) internal virtual {

		for (uint256 i=0; i < nftIds.length; i++){
			safeTransferFrom(from, to, nftAddresses[i], nftIds[i], nftAmounts[i], "");
		}
	}

	function safeTransferFrom(
		address from,
		address to,
		address tokenAddress,
		uint256 tokenId,
		uint256 tokenAmount,
		bytes memory _data
	) internal virtual {

		if (tokenAmount == 0) {
			IERC721(tokenAddress).safeTransferFrom(from, to, tokenId, _data);
		} else {
			IERC1155(tokenAddress).safeTransferFrom(from, to, tokenId, tokenAmount, _data);
		}
		
	}

	function withdrawEther(address payable recipient) external onlyOwner {

		require(recipient != address(0), "SwapKiwi: transfer to the zero address");

		recipient.transfer((address(this).balance - _etherLocked));
	}
}