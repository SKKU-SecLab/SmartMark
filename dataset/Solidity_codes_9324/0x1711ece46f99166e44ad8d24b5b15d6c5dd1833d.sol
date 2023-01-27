
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

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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
}// UNLICENSED

pragma solidity ^0.8.10;
pragma abicoder v2;

interface IMintywayRoyalty {

    function royaltyOf(uint256 _id) external view returns(uint256);

    function creatorOf(uint256 _id) external view returns(address);

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
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

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

}// UNLICENSED
pragma solidity ^0.8.10;


library TokenLibrary {


    enum TypeOfToken {
        ERC721,
        ERC1155
    }

    struct TokenValue {
        address token;
        uint256 tokenId;
        uint256 tokenValue;
    }

    function typeOfToken(uint256 tokenValue) internal pure returns(TypeOfToken) {

        if (tokenValue == 0){
            return TypeOfToken.ERC721;
        }
        else {
            return TypeOfToken.ERC1155;
        }
    }

    function transferFrom(TokenValue storage token, address from, address to) internal {


        if (typeOfToken(token.tokenValue) == TypeOfToken.ERC721) {
            IERC721(token.token).safeTransferFrom(from, to, token.tokenId);
        } 
        else {
            IERC1155(token.token).safeTransferFrom(from, to, token.tokenId, token.tokenValue, "");
        }

    }
}// UNLICENSED
pragma solidity ^0.8.10;



library LotLibrary {


    using TokenLibrary for TokenLibrary.TokenValue;
    
    enum LotStatus {
        FOR_AUCTION,
        CANCELED,
        WITH_BETS,
        WITHDRAWN
    }
    
    struct Lot {
        address owner;
        address buyer;
        uint256 price;
        uint256 startTime;
        uint256 time;
        TokenLibrary.TokenValue token;
        IERC20 paymentContract;
        LotStatus status;
        uint256 royalty;
        address creator;
    }

    function transferToken(Lot storage lot, address from, address to) internal {

        lot.token.transferFrom(from, to);
    }
    
}// UNLICENSED
pragma solidity ^0.8.10;




contract MintywayAuction is Ownable, IERC721Receiver, ERC1155Receiver, ReentrancyGuard {

    using SafeERC20 for IERC20;
    using TokenLibrary for TokenLibrary.TokenValue;
    using LotLibrary for LotLibrary.Lot;

    event LotCreated(uint256 lotId);
    event AuctionCanceled(uint256 lotId);
    event BetPlaced(uint256 lotId, address buyer, uint256 newPrice);
    event AuctionFinished(uint256 lotId);

    modifier onlyLotOwner(uint256 lotId) {

        require(
            msg.sender == lots[lotId].owner,
            "BA: You are not the owner of lot"
        );
        _;
    }

    mapping(uint256 => LotLibrary.Lot) public lots;
    uint256 public nextLotId;
    mapping(IERC20 => uint256) public collectedFees;
    mapping(address => mapping(IERC20 => uint256)) public collectedRoyalties;
    uint32 internal _auctionFeeDenominator = 25; // 4% 
    uint256 internal _stepOfAuctionDenominator = 100;
    uint256 internal _timeOfAuction = 86400; // 24 hours 

    mapping(address => bool) private _supportsRoyalties;

    constructor(uint256 timeOfAuction_, address erc721Contract, address erc1155Contract) {
        _timeOfAuction = timeOfAuction_;
        _supportsRoyalties[erc721Contract] = true;
        _supportsRoyalties[erc1155Contract] = true;
    }

    function setContractWithRoyalties(address ercContract) external onlyOwner {

        _supportsRoyalties[ercContract] = true;
    }

    function isSupportRoyalties(address ercContract) external view returns(bool) {

        return _supportsRoyalties[ercContract];
    }
    
    function deleteContractWithRoyalties(address ercContract) external onlyOwner {

        _supportsRoyalties[ercContract] = false;
    }

    function setTimeOfAuction(uint256 newTimeOfAuction) external onlyOwner {

        _timeOfAuction = newTimeOfAuction;
    }

    function timeOfAuction() external view returns(uint256) {

        return _timeOfAuction;
    }

    function getLot(uint256 lotId) external view returns(LotLibrary.Lot memory) {

        return lots[lotId];
    }

    function setAuctionFeeDenominator(uint32 auctionFeeDenominator_) external onlyOwner {

        _auctionFeeDenominator = auctionFeeDenominator_;
    }
    
    function auctionFeeDenominator() external view returns(uint32) {

        return _auctionFeeDenominator;
    }

    function setStepOfAuctionDenominator(uint256 stepOfAuctionDenominator_) external onlyOwner {

        _stepOfAuctionDenominator = stepOfAuctionDenominator_;
    }

    function stepOfAuctionDenominator() external view returns(uint256) {

        return _stepOfAuctionDenominator;
    }

    function createAuction(
        TokenLibrary.TokenValue calldata token, 
        uint256 price, 
        IERC20 paymentContract
        ) public returns(uint256 lotId){


        address sender = msg.sender;

        require(price != 0, "MintywayAuction: Price of lot can not be zero");
        
        address creator;
        uint256 royalty;

        if (_supportsRoyalties[token.token]) {
            royalty = IMintywayRoyalty(token.token).royaltyOf(token.tokenId);
            creator = IMintywayRoyalty(token.token).creatorOf(token.tokenId);
        } 

        lots[nextLotId] = LotLibrary.Lot ({
            owner: sender,
            buyer: address(0),
            token: token,
            paymentContract: paymentContract,
            startTime: block.timestamp, // 86400 seconds (24 hours)
            time: _timeOfAuction,
            price: price, 
            status: LotLibrary.LotStatus.FOR_AUCTION,
            royalty: royalty,
            creator: creator
        });

        lots[nextLotId].transferToken(sender, address(this));

        emit LotCreated(nextLotId);
        nextLotId++;
        return(nextLotId-1);
    }
    

    function cancelAuction(uint256 lotId) public onlyLotOwner(lotId) nonReentrant {

        LotLibrary.Lot storage lot = lots[lotId];
        address sender = msg.sender;
        require(
            lot.status == LotLibrary.LotStatus.FOR_AUCTION,
            "MintywayAuction: Lot is not on auction"
        );
        
        lot.transferToken(address(this), sender);
        
        lot.status = LotLibrary.LotStatus.CANCELED;
        emit AuctionCanceled(lotId);
    }

    function placeBet(uint256 lotId, uint256 newPrice) external nonReentrant {

        address sender = msg.sender;
        LotLibrary.Lot storage lot = lots[lotId];
        
        require(sender != lot.buyer,
                "MintywayAuction: You have already placed a bet");
        require(
            lot.status == LotLibrary.LotStatus.FOR_AUCTION || lot.status == LotLibrary.LotStatus.WITH_BETS,
            "MintywayAuction: This lot is not on auction" 
        );
        require(
            lot.startTime + lot.time > block.timestamp || lot.buyer == address(0), 
            "MintywayAuction: Time has expired"
        );


        if (lot.buyer != address(0)) {

            require(newPrice >= lot.price + lot.price / _stepOfAuctionDenominator,
                "MintywayAuction: price is too low");

            lot.paymentContract.safeTransfer(
                lot.buyer,
                lot.price
            );

        } else {
            require(newPrice >= lot.price,
                "MintywayAuction: price is too low");
        }

        lot.price = newPrice;

        lot.paymentContract.safeTransferFrom(
            sender,
            address(this),
            lot.price
        );

        lot.buyer = sender;
        lot.status = LotLibrary.LotStatus.WITH_BETS;
        lot.startTime = block.timestamp;

        emit BetPlaced(lotId, lot.buyer, lot.price);
    }

    function finishAuction(uint256 lotId) external nonReentrant {

        address sender = msg.sender;
        LotLibrary.Lot storage lot = lots[lotId];

        require(
            lot.status == LotLibrary.LotStatus.WITH_BETS,
            "MintywayAuction: Auction is not finished or was canceled"
        );

        require(
            lot.startTime + lot.time < block.timestamp, "MintywayAuction: Time has not expired"
        );

        lot.transferToken(address(this), lot.buyer);

        uint256 fee = lot.price / _auctionFeeDenominator;
        uint256 royalty = 0;

        if (lot.royalty != 0) {
            royalty = lot.price * lot.royalty / 100;
            collectedRoyalties[lot.creator][lot.paymentContract] += royalty;

            lot.paymentContract.safeTransfer(
                lot.creator,
                royalty
            );
        }

        lot.paymentContract.safeTransfer(
            lot.owner,
            lot.price - fee - royalty
        );

        collectedFees[lot.paymentContract] += fee;

        lot.status = LotLibrary.LotStatus.WITHDRAWN;
        emit AuctionFinished(lotId);
    }

    function withdrawFees(IERC20 contractAddress) external onlyOwner {

        contractAddress.safeTransfer(owner(), collectedFees[contractAddress]);
        collectedFees[contractAddress] = 0;
    }

    function onERC721Received(address /* operator */, address /* from */, uint256 /* tokenId */, bytes calldata /* data */) override public pure returns (bytes4) {

        return this.onERC721Received.selector;
    }

    function onERC1155Received(address /* operator */, address /* from */, uint256 /* id */, uint256 /* value */, bytes calldata /* data */) override public pure returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address /* operator */, address /* from */, uint256[] calldata /* ids */, uint256[] calldata /* values */, bytes calldata /* data */) override public pure returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
}