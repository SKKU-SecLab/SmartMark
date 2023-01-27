
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
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}// MIT

pragma solidity ^0.8.0;

library Counters {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {

        counter._value = 0;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function setApprovalForAll(address operator, bool _approved) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function isApprovedForAll(address owner, address operator) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


contract ERC721Holder is IERC721Receiver {

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
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


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC1155Holder is ERC1155Receiver {

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
}// UNLICENSED
pragma solidity ^0.8.12;
pragma abicoder v2;

abstract contract ERC721Interface {
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external virtual;
}

abstract contract ERC1155Interface {
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external virtual;
}

abstract contract ERC20Interface {
    function transfer(address recipient, uint256 amount) external virtual returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external virtual returns (bool);
}// UNLICENSED
pragma solidity ^0.8.13;


contract NFTSwap is Ownable, Pausable, ERC721Holder, ERC1155Holder {


    using Counters for Counters.Counter;

    enum SwapStatus  {Open, Completed, Canceled, Expired}
    enum DAppType {Undefined, ERC721, ERC1155, ERC20, NetworkValue}

    struct SwapItem {
        address dApp;
        DAppType dAppType;
        uint256[] tokenIds;
        uint256[] tokenAmounts;
        bytes data;
    }

    struct SwapOrder {
        uint256 id;
        uint256 start;
        uint256 end;
        uint256 expiration;
        uint256 fee;
        uint256 feePaid;
        address addressOne;
        address addressTwo;
        SwapStatus status;
        SwapItem[] addressOneItems;
        SwapItem[] addressTwoItems;
    }

    mapping(uint256 => SwapOrder)swapOrders;
    mapping(address => uint256[])swapAddresses;

    uint256 private _fee;
    Counters.Counter private _orderId;
    uint256 private _swapBalance;

    event SwapOrderEvent(uint256 orderId, SwapStatus status);

    receive() external payable {}

    function supportsInterface(bytes4 interfaceID) public view virtual override returns (bool) {

        return interfaceID == type(IERC721).interfaceId || interfaceID == type(IERC1155).interfaceId;
    }

    function creatSwapOrder(address addressTwo, SwapItem[] memory swapOneItems, SwapItem[] memory swapTwoItems, uint256 expirationSec) public payable whenNotPaused returns (uint256){

        require(swapOneItems.length > 0, "AIe0");
        require(swapTwoItems.length > 0, "BIe0");
        require(msg.sender != addressTwo, "OeT");

        _orderId.increment();

        swapOrders[_orderId.current()].id = _orderId.current();
        swapOrders[_orderId.current()].start = block.timestamp;
        swapOrders[_orderId.current()].end = 0;
        if (expirationSec > 0) {
            swapOrders[_orderId.current()].expiration = block.timestamp + expirationSec;
        } else {
            swapOrders[_orderId.current()].expiration = 0;
        }

        uint256 swapNetworkValue = msg.value;
        swapOrders[_orderId.current()].fee = getFee();
        swapOrders[_orderId.current()].addressOne = msg.sender;
        swapOrders[_orderId.current()].addressTwo = addressTwo;
        swapOrders[_orderId.current()].status = SwapStatus.Open;

        uint256 i = 0;

        for (i = 0; i < swapOneItems.length; i++) {
            require(swapOneItems[i].dAppType != DAppType.Undefined, "DU");
            swapOrders[_orderId.current()].addressOneItems.push(swapOneItems[i]);
            if (swapOneItems[i].dAppType == DAppType.ERC721) {
                ERC721Interface(swapOneItems[i].dApp).safeTransferFrom(msg.sender, address(this), swapOneItems[i].tokenIds[0], swapOneItems[i].data);
            } else if (swapOneItems[i].dAppType == DAppType.ERC1155) {
                ERC1155Interface(swapOneItems[i].dApp).safeBatchTransferFrom(msg.sender, address(this), swapOneItems[i].tokenIds, swapOneItems[i].tokenAmounts, swapOneItems[i].data);
            } else if (swapOneItems[i].dAppType == DAppType.ERC20) {
                ERC20Interface(swapOneItems[i].dApp).transferFrom(msg.sender, address(this), swapOneItems[i].tokenAmounts[0]);
            } else if (swapOneItems[i].dAppType == DAppType.NetworkValue) {
                require(swapNetworkValue >= swapOneItems[i].tokenAmounts[0], "VltS");
                swapNetworkValue -= swapOneItems[i].tokenAmounts[0];
                _swapBalance += swapOneItems[i].tokenAmounts[0];
            }
        }

        if (swapOrders[_orderId.current()].fee > 0) {
            if (swapNetworkValue > 0) {
                if (swapOrders[_orderId.current()].fee > swapNetworkValue) {
                    swapOrders[_orderId.current()].feePaid = swapNetworkValue;
                    swapNetworkValue -= swapOrders[_orderId.current()].feePaid;
                } else {
                    swapOrders[_orderId.current()].feePaid = swapOrders[_orderId.current()].fee;
                    swapNetworkValue -= swapOrders[_orderId.current()].fee;
                }
            } else {
                swapOrders[_orderId.current()].feePaid = 0;
            }
        }

        require(swapNetworkValue == 0, "VN0");

        for (i = 0; i < swapTwoItems.length; i++) {
            require(swapTwoItems[i].dAppType != DAppType.Undefined, "DU");
            swapOrders[_orderId.current()].addressTwoItems.push(swapTwoItems[i]);
        }

        swapAddresses[msg.sender].push(_orderId.current());
        if (addressTwo != address(0)) {
            swapAddresses[addressTwo].push(_orderId.current());
        }

        emit SwapOrderEvent(_orderId.current(), SwapStatus.Open);

        return _orderId.current();
    }

    function completeSwapOrder(uint256 orderId) public payable returns (bool){

        require(swapOrders[orderId].status == SwapStatus.Open, "NO");
        require(swapOrders[orderId].addressTwo == msg.sender || swapOrders[orderId].addressTwo == address(0), "NA");

        if (swapOrders[orderId].expiration >= block.timestamp || swapOrders[orderId].expiration == 0) {

            swapOrders[orderId].end = block.timestamp;

            uint256 swapNetworkValue = msg.value;
            if (swapOrders[orderId].fee > 0 && swapOrders[orderId].fee > swapOrders[orderId].feePaid) {
                uint256 fpv = (swapOrders[orderId].fee - swapOrders[orderId].feePaid);
                require(swapNetworkValue >= fpv, "VFltS");
                swapOrders[orderId].feePaid += fpv;
                swapNetworkValue -= fpv;
            }

            if (swapOrders[orderId].addressTwo == address(0)) {
                swapAddresses[msg.sender].push(swapOrders[orderId].id);
            }

            swapOrders[orderId].addressTwo = msg.sender;
            swapOrders[orderId].status = SwapStatus.Completed;

            uint256 i;

            for (i = 0; i < swapOrders[orderId].addressTwoItems.length; i++) {
                if (swapOrders[orderId].addressTwoItems[i].dAppType == DAppType.ERC721) {
                    ERC721Interface(swapOrders[orderId].addressTwoItems[i].dApp).safeTransferFrom(msg.sender, swapOrders[orderId].addressOne, swapOrders[orderId].addressTwoItems[i].tokenIds[0], swapOrders[orderId].addressTwoItems[i].data);
                } else if (swapOrders[orderId].addressTwoItems[i].dAppType == DAppType.ERC1155) {
                    ERC1155Interface(swapOrders[orderId].addressTwoItems[i].dApp).safeBatchTransferFrom(msg.sender, swapOrders[orderId].addressOne, swapOrders[orderId].addressTwoItems[i].tokenIds, swapOrders[orderId].addressTwoItems[i].tokenAmounts, swapOrders[orderId].addressTwoItems[i].data);
                } else if (swapOrders[orderId].addressTwoItems[i].dAppType == DAppType.ERC20) {
                    ERC20Interface(swapOrders[orderId].addressTwoItems[i].dApp).transferFrom(msg.sender, swapOrders[orderId].addressOne, swapOrders[orderId].addressTwoItems[i].tokenAmounts[0]);
                } else if (swapOrders[orderId].addressTwoItems[i].dAppType == DAppType.NetworkValue) {
                    require(swapNetworkValue >= swapOrders[orderId].addressTwoItems[i].tokenAmounts[0], "VltS");
                    payable(swapOrders[orderId].addressOne).transfer(swapOrders[orderId].addressTwoItems[i].tokenAmounts[0]);
                    swapNetworkValue -= swapOrders[orderId].addressTwoItems[i].tokenAmounts[0];
                }
            }

            require(swapNetworkValue == 0, "VN0");

            for (i = 0; i < swapOrders[orderId].addressOneItems.length; i++) {
                if (swapOrders[orderId].addressOneItems[i].dAppType == DAppType.ERC721) {
                    ERC721Interface(swapOrders[orderId].addressOneItems[i].dApp).safeTransferFrom(address(this), swapOrders[orderId].addressTwo, swapOrders[orderId].addressOneItems[i].tokenIds[0], swapOrders[orderId].addressOneItems[i].data);
                } else if (swapOrders[orderId].addressOneItems[i].dAppType == DAppType.ERC1155) {
                    ERC1155Interface(swapOrders[orderId].addressOneItems[i].dApp).safeBatchTransferFrom(address(this), swapOrders[orderId].addressTwo, swapOrders[orderId].addressOneItems[i].tokenIds, swapOrders[orderId].addressOneItems[i].tokenAmounts, swapOrders[orderId].addressOneItems[i].data);
                } else if (swapOrders[orderId].addressOneItems[i].dAppType == DAppType.ERC20) {
                    ERC20Interface(swapOrders[orderId].addressOneItems[i].dApp).transfer(swapOrders[orderId].addressTwo, swapOrders[orderId].addressOneItems[i].tokenAmounts[0]);
                } else if (swapOrders[orderId].addressOneItems[i].dAppType == DAppType.NetworkValue) {
                    payable(swapOrders[orderId].addressTwo).transfer(swapOrders[orderId].addressOneItems[i].tokenAmounts[0]);
                    _swapBalance -= swapOrders[orderId].addressOneItems[i].tokenAmounts[0];
                }
            }

            emit SwapOrderEvent(orderId, SwapStatus.Completed);

            return true;
        } else {
            swapOrders[orderId].status = SwapStatus.Expired;

            emit SwapOrderEvent(orderId, SwapStatus.Expired);

            return false;
        }
    }

    function cancelSwapOrder(uint256 orderId) public payable returns (bool){

        require(swapOrders[orderId].status == SwapStatus.Open || swapOrders[orderId].status == SwapStatus.Expired, "C");
        require(swapOrders[orderId].addressOne == msg.sender, "NC");

        swapOrders[orderId].status = SwapStatus.Canceled;
        swapOrders[orderId].end = block.timestamp;

        uint256 swapNetworkValue = msg.value;
        if (swapOrders[orderId].fee > 0 && swapOrders[orderId].fee > swapOrders[orderId].feePaid) {
            uint256 fpv = (swapOrders[orderId].fee - swapOrders[orderId].feePaid);
            require(swapNetworkValue >= fpv, "VFltS");
            swapOrders[orderId].feePaid += fpv;
            swapNetworkValue -= fpv;
        }
        require(swapNetworkValue == 0, "VN0");

        uint256 i;

        for (i = 0; i < swapOrders[orderId].addressOneItems.length; i++) {
            if (swapOrders[orderId].addressOneItems[i].dAppType == DAppType.ERC721) {
                ERC721Interface(swapOrders[orderId].addressOneItems[i].dApp).safeTransferFrom(address(this), swapOrders[orderId].addressOne, swapOrders[orderId].addressOneItems[i].tokenIds[0], swapOrders[orderId].addressOneItems[i].data);
            } else if (swapOrders[orderId].addressOneItems[i].dAppType == DAppType.ERC1155) {
                ERC1155Interface(swapOrders[orderId].addressOneItems[i].dApp).safeBatchTransferFrom(address(this), swapOrders[orderId].addressOne, swapOrders[orderId].addressOneItems[i].tokenIds, swapOrders[orderId].addressOneItems[i].tokenAmounts, swapOrders[orderId].addressOneItems[i].data);
            } else if (swapOrders[orderId].addressOneItems[i].dAppType == DAppType.ERC20) {
                ERC20Interface(swapOrders[orderId].addressOneItems[i].dApp).transfer(swapOrders[orderId].addressOne, swapOrders[orderId].addressOneItems[i].tokenAmounts[0]);
            } else if (swapOrders[orderId].addressOneItems[i].dAppType == DAppType.NetworkValue) {
                payable(swapOrders[orderId].addressOne).transfer(swapOrders[orderId].addressOneItems[i].tokenAmounts[0]);
                _swapBalance -= swapOrders[orderId].addressOneItems[i].tokenAmounts[0];
            }
        }

        emit SwapOrderEvent(orderId, SwapStatus.Canceled);

        return true;
    }

    function getOrderById(uint256 orderId) public view returns (SwapOrder memory){

        return swapOrders[orderId];
    }

    function getOrderIdsByAddress(address addressIndex) public view returns (uint256[] memory){

        return swapAddresses[addressIndex];
    }

    function getOrderCount() public view returns (uint256){

        return _orderId.current();
    }

    function getFee() public view returns (uint256){

        return _fee;
    }

    function setFee(uint256 newFee) public onlyOwner {

        _fee = newFee;
    }

    function switchPause() public onlyOwner {

        if (paused()) {
            _unpause();
        } else {
            _pause();
        }
    }

    function _getFeeBalance() internal view returns (uint256) {

        return address(this).balance > _swapBalance ? address(this).balance - _swapBalance : 0;
    }

    function getWithdrawBalance(address payable recipient, uint256 amounts) public onlyOwner {

        require(recipient != address(0), "WB0");
        uint256 maxAmount = _getFeeBalance();
        if (amounts == 0 || maxAmount < amounts) {
            recipient.transfer(maxAmount);
        } else {
            recipient.transfer(amounts);
        }
    }

}