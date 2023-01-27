


pragma solidity 0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function decimals() external view returns (uint8);


    function symbol() external view returns (string memory);


    function name() external view returns (string memory);


    function getOwner() external view returns (address);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address _owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {

    constructor ()  {}

    function _msgSender() internal view returns (address payable) {

        return payable (msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {

        this;
        return msg.data;
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash =
        0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success,) = recipient.call{value : amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
    internal
    returns (bytes memory)
    {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return
        functionCallWithValue(
            target,
            data,
            value,
            "Address: low-level call with value failed"
        );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) =
        target.call{value : weiValue}(data);
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

contract WYVERNSBREATH is Context, IERC20, Ownable {

    using Address for address;
    using SafeMath for uint256;

    mapping(uint => uint) public lastUpdate;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(uint => uint) public wyvernTypeToEarningsPerDay;
    mapping(uint => uint) public wyvernTokenToWyvernType;
    uint deployedTime = 1637427600; //epoch time deployed at 20th Nov 2021 ETC
    uint public timeInSecsInADay = 24*60*60; 
    event mintOverflown (uint amountGiven, uint notgiven, string message);

    uint private maxSupply = 10000000 * (10 ** 18); // 10 million Breath tokens
    uint256 private _totalSupply;
    uint8 public _decimals;
    string public _symbol;
    string public _name;
    IERC721 private nft;
    

    constructor()  {
        _name = "Wyverns Breath";
        _symbol = "$BREATH";
        _decimals = 18;
        _totalSupply = 0;

        nft = IERC721(0x01fE2358CC2CA3379cb5eD11442e85881997F22C);

        wyvernTypeToEarningsPerDay[1] = 5;
        wyvernTypeToEarningsPerDay[2] = 25;
    }


    function getOwner() external override view returns (address) {

        return owner();
    }

    function decimals() external override view returns (uint8) {

        return _decimals;
    }

    function symbol() external override view returns (string memory) {

        return _symbol;
    }

    function name() external override view returns (string memory) {

        return _name;
    }

    function totalSupply() public override view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) external override view returns (uint256) {

        return _balances[account];
    }

    function setWyvernTypeCodeAndEarnings(uint wyvernTypeCode, uint _amount) external onlyOwner {

        wyvernTypeToEarningsPerDay[wyvernTypeCode] = _amount;
    }
    function addTokenWyvernType(uint[] memory tokenIds, uint[] memory wyvernTypeCodes) external onlyOwner {

        require(tokenIds.length == wyvernTypeCodes.length, "Inputs provided with different no of values, should be EQUAL.");
        for (uint i = 0; i < tokenIds.length; i++) {
            wyvernTokenToWyvernType[tokenIds[i]] = wyvernTypeCodes[i];
        }
    }

    function setMaxSupply(uint newMaxSupply) external onlyOwner{

        maxSupply = newMaxSupply;
    }
    function showWyvernTypeEarningsPerDay(uint wyvernTypeCode) external view returns (uint) {

        return wyvernTypeToEarningsPerDay[wyvernTypeCode];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external override view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function burn(uint256 amount) public returns (bool) {

        _burn(_msgSender(), amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "ERC20: approve fromm the zero address");
        require(spender != address(0), "ERC20: approvee to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }

    function modifytimeInSec(uint _timeInSec) external onlyOwner {

        timeInSecsInADay = _timeInSec;
    }

    function getTypeOfToken(uint tokenId) internal view returns(uint) {

        if (tokenId >= 1 && tokenId <= 3500) {
            return 1;
        }
        else {
            return wyvernTokenToWyvernType[tokenId];
            }
    }

    function claimToken(uint[] memory tokenIds) external {

        uint amount = 0;
        uint today_count = block.timestamp / timeInSecsInADay;
        for (uint i = 0; i < tokenIds.length; i++) {
            if (nft.ownerOf(tokenIds[i]) == msg.sender) {
                uint tokenAccumulation = getPendingReward(tokenIds[i], today_count, getTypeOfToken(tokenIds[i]));
                if (tokenAccumulation > 0) {
                    if (maxSupply < _totalSupply + amount + tokenAccumulation) {
                        emit mintOverflown(amount, tokenAccumulation, "Minting Limit Reached");
                        break;
                    }
                    amount += tokenAccumulation;
                    lastUpdate[tokenIds[i]] = today_count;
                }
            }
        }
        require (amount > 0,"NO positive number of $BREATH tokens are available to mint");
        _mint(msg.sender, amount);
    }

    function getPendingReward(uint tokenId, uint todayCount, uint wyvernTypeCode) internal view  returns (uint){

        uint wyvernEarningsPerDay;
        if (lastUpdate[tokenId] == 0) {
            if (wyvernTypeCode == 1) {// 1 means Genesis
                wyvernEarningsPerDay = wyvernTypeToEarningsPerDay[wyvernTypeCode];
                uint daysPassedSinceNFTMinted = block.timestamp - deployedTime;
                daysPassedSinceNFTMinted = (daysPassedSinceNFTMinted / timeInSecsInADay);
                return (daysPassedSinceNFTMinted * wyvernEarningsPerDay * (10 ** _decimals));
            } else if(wyvernTypeCode == 2){  // 2 means Ascension
                return 25 * (10 ** _decimals);
            }else{
                return 0;
            }
        } else {
            if (todayCount - lastUpdate[tokenId] >= 1) {
                uint daysElapsedSinceLastUpdate = todayCount - lastUpdate[tokenId];
                wyvernEarningsPerDay = wyvernTypeToEarningsPerDay[wyvernTypeCode];
                return daysElapsedSinceLastUpdate * (wyvernEarningsPerDay * (10 ** _decimals));
            } else {
                return 0;
            }
        }
    }
}