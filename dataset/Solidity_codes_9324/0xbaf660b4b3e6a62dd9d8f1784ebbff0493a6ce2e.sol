
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


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
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


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT
pragma solidity >=0.8.0 <0.9.0;

abstract contract Constants {
    address ADDRESS_ZERO = address(0);
    address THIS_ADDRESS = address(this);
    address NFT_ADDRESS = 0x6FAA985Dc84619C689509a55cEE7Ccc36251b4C0;
    address PURCHASE_TOKEN_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address RECEIVE_TOKEN_ADDRESS = address(0); // TODO: update with correct value.
}// MIT
pragma solidity >=0.8.0 <0.9.0;

abstract contract Errors {
    string ADDRESS_ZERO_ERROR = "Can not use address zero";
    string NOT_POSITIVE_ERROR = "Value should be more bigger than 0";
    string LTN_TIMESTAMP_ERROR = "Time should be bigger than current time";
    string LTS_TIMESTAMP_ERROR = "Time should be bigger than start time";
    string NOT_ON_SALE_ERROR = "Not on the sale period";
    string NOT_ON_BUY_ERROR = "Not on the buy period";
    string BAD_AMOUNT_ERROR = "Bad amount";
    string INSUFFICIENT_BALANCE_ERROR = "Insufficient balance in ICO";
    string NOT_HOLDER_ERROR = "Not a holder";
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT
pragma solidity >=0.8.0 <0.9.0;


interface IDERC20 is IERC20 {

    function decimals() external view returns (uint8);

}// MIT
pragma solidity >=0.8.0 <0.9.0;






contract MonasteryICO is Ownable, Constants, Errors {

    using SafeMath for uint256;

    IERC721Enumerable public NFTToken = IERC721Enumerable(NFT_ADDRESS);
    IDERC20 public purchaseToken = IDERC20(PURCHASE_TOKEN_ADDRESS);
    IDERC20 public receiveToken = IDERC20(RECEIVE_TOKEN_ADDRESS);

    uint256 public purchaseTokenDecimals = 18;
    uint256 public receiveTokenDecimals = 9;

    uint256 public tokenPerNFT = uint256(48).mul(10 ** receiveTokenDecimals);
    uint256 public price = 10;

    mapping(uint256 => uint256) public claimed;

    uint256 public startTime;
    uint256 public endTime;

    constructor() {}


    function setNFTToken(address NFTTokenAddress) public onlyOwner {

        require(NFTTokenAddress != ADDRESS_ZERO, ADDRESS_ZERO_ERROR);
        NFTToken = IERC721Enumerable(NFTTokenAddress);
    }

    function setPurchaseToken(address purchaseTokenAddres) public onlyOwner {

        require(purchaseTokenAddres != ADDRESS_ZERO, ADDRESS_ZERO_ERROR);
        purchaseToken = IDERC20(purchaseTokenAddres);
        purchaseTokenDecimals = purchaseToken.decimals();
    }

    function setReceiveToken(address receiveTokenAddres) public onlyOwner {

        require(receiveTokenAddres != ADDRESS_ZERO, ADDRESS_ZERO_ERROR);
        receiveToken = IDERC20(receiveTokenAddres);
        uint256 prevDecimals = receiveTokenDecimals;
        receiveTokenDecimals = receiveToken.decimals();
        if (receiveTokenDecimals != prevDecimals) {
            tokenPerNFT = tokenPerNFT.div(10 ** prevDecimals).mul(10 ** receiveTokenDecimals);
        }
    }

    function setTokenPerNFT(uint256 _tokenPerNFT) public onlyOwner {

        require(_tokenPerNFT > 0, NOT_POSITIVE_ERROR);
        tokenPerNFT = _tokenPerNFT;
    }

    function setICOTIme(uint256 start, uint256 end) public onlyOwner {

        require(start > block.timestamp, LTN_TIMESTAMP_ERROR);
        require(end > start, LTS_TIMESTAMP_ERROR);
        startTime = start;
        endTime = end;
    }

    function haltICO() public onlyOwner {

        startTime = 0;
        endTime = 0;
    }

    function startBuy() public onlyOwner {

        endTime = block.timestamp;
    }

    function setPrice(uint256 _price) public onlyOwner {

        require(_price > 0, NOT_POSITIVE_ERROR);
        price = _price;
    }


    function deposit(address tokenAddress, uint256 amount) public onlyOwner {

        require(tokenAddress != ADDRESS_ZERO, ADDRESS_ZERO_ERROR);
        require(amount > 0, NOT_POSITIVE_ERROR);
        IDERC20(tokenAddress).transferFrom(_msgSender(), THIS_ADDRESS, amount);
    }

    function withdraw(address tokenAddress, uint256 amount, address to) public onlyOwner {

        require(tokenAddress != ADDRESS_ZERO, ADDRESS_ZERO_ERROR);
        require(amount > 0, NOT_POSITIVE_ERROR);
        require(to != ADDRESS_ZERO, ADDRESS_ZERO_ERROR);
        IDERC20(tokenAddress).transfer(to, amount);
    }

    function balanceOf(address tokenAddress) public view onlyOwner returns (uint256 balance) {

        balance = IDERC20(tokenAddress).balanceOf(THIS_ADDRESS);
    }


    function checkClaimable(address owner, uint256 amount) private returns (uint256 canClaim) {

        uint256 balance = NFTToken.balanceOf(owner);
        canClaim = 0;
        for (uint256 index = 0; index < balance && amount > 0; ++index) {
            uint256 tokenId = NFTToken.tokenOfOwnerByIndex(owner, index);
            uint256 remaining = tokenPerNFT.sub(claimed[tokenId]);
            if (remaining > 0) {
                uint256 available = amount > remaining ? remaining : amount;
                claimed[tokenId] = claimed[tokenId].add(available);
                canClaim = canClaim.add(available);
                amount = amount.sub(available);
            }
        }
    }


    function getClaimable() public view returns (uint256 canClaim) {

        address owner = _msgSender();
        uint256 balance = NFTToken.balanceOf(owner);
        canClaim = 0;
        for (uint256 index = 0; index < balance; ++index) {
            uint256 tokenId = NFTToken.tokenOfOwnerByIndex(owner, index);
            uint256 remaining = tokenPerNFT.sub(claimed[tokenId]);
            canClaim = canClaim.add(remaining);
        }
    }

    function isClaimOn() public view returns (bool) {

        return block.timestamp > startTime && block.timestamp < endTime;
    }

    function isBuyOn() public view returns (bool) {

        return endTime != 0 && block.timestamp > endTime;
    }

    function calculatePriceForAmount(uint256 amount) public view returns (uint256) {

        uint256 decimals = 0;
        if (purchaseTokenDecimals >= receiveTokenDecimals) {
            decimals = purchaseTokenDecimals.sub(receiveTokenDecimals);
            return amount.mul(price).mul(10 ** decimals);
        }
        decimals = receiveTokenDecimals.sub(purchaseTokenDecimals);
        return amount.mul(price).div(10 ** decimals);
    }


    function claim(uint256 amount) public {

        require(isClaimOn(), NOT_ON_SALE_ERROR);
        require(amount > 0, NOT_POSITIVE_ERROR);
        require(amount <= receiveToken.balanceOf(THIS_ADDRESS), INSUFFICIENT_BALANCE_ERROR);

        uint256 canClaimAmount = checkClaimable(_msgSender(), amount);
        require(canClaimAmount == amount, BAD_AMOUNT_ERROR);

        purchaseToken.transferFrom(_msgSender(), THIS_ADDRESS, calculatePriceForAmount(amount));
        receiveToken.transfer(_msgSender(), amount);
    }    

    function buy(uint256 amount) public {

        require(isBuyOn(), NOT_ON_BUY_ERROR);
        require(amount > 0, NOT_POSITIVE_ERROR);
        require(amount <= receiveToken.balanceOf(THIS_ADDRESS), INSUFFICIENT_BALANCE_ERROR);
        require(receiveToken.balanceOf(_msgSender()) > 0, NOT_HOLDER_ERROR);

        purchaseToken.transferFrom(_msgSender(), THIS_ADDRESS, calculatePriceForAmount(amount));
        receiveToken.transfer(_msgSender(), amount);
    }
}