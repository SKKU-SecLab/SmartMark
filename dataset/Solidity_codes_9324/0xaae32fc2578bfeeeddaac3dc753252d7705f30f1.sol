


pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface RoyaNFT {

    function balanceOf(address account, uint256 id) external view returns (uint256);

    
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;

}



pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.6.0;

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



pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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



pragma solidity ^0.6.0;





contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    bool private transferrable;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(transferrable, "ERC20: Not transferrable");
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}



pragma solidity ^0.6.0;




library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



pragma solidity ^0.6.0;

contract Ownable is Context {
    address private _owner;
    address private _nominatedOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnershipNominated(address indexed previousOwner, address indexed newOwner);

    constructor (address _multisigWallet) internal {
        _owner = _multisigWallet;
        emit OwnershipTransferred(address(0), _multisigWallet);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     
     
     
     
    
    function nominateNewOwner(address _wallet) external onlyOwner {
        _nominatedOwner = _wallet;
        emit OwnershipNominated(_owner,_wallet);
    }

    function acceptOwnership() external {
        require(msg.sender == _nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnershipTransferred(_owner, _nominatedOwner);
        _owner = _nominatedOwner;
        _nominatedOwner = address(0);
    }

}



pragma solidity 0.6.12;


interface IStakingLot {    
    event Claim(address indexed acount, uint amount);
    event Profit(uint amount);


    function claimProfit() external returns (uint profit);
    function buy(uint amount) external;
    function sell(uint amount) external;
    function profitOf(address account) external view returns (uint);
}


interface IStakingLotERC20 is IStakingLot {
    function sendProfit(uint amount) external;
}

contract CommonConstants {

    bytes4 constant internal ERC1155_ACCEPTED = 0xf23a6e61; // bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))
    bytes4 constant internal ERC1155_BATCH_ACCEPTED = 0xbc197c81; // bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))
}

contract ERC1155Receiver is CommonConstants {

    bool shouldReject;

    bytes public lastData;
    address public lastOperator;
    address public lastFrom;
    uint256 public lastId;
    uint256 public lastValue;

    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) external returns(bytes4) {
        lastOperator = _operator;
        lastFrom = _from;
        lastId = _id;
        lastValue = _value;
        lastData = _data;
        if (shouldReject == true) {
            revert("onERC1155Received: transfer not accepted");
        } else {
            return ERC1155_ACCEPTED;
        }
    }

    function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external returns(bytes4) {
        lastOperator = _operator;
        lastFrom = _from;
        lastId = _ids[0];
        lastValue = _values[0];
        lastData = _data;
        if (shouldReject == true) {
            revert("onERC1155BatchReceived: transfer not accepted");
        } else {
            return ERC1155_BATCH_ACCEPTED;
        }
    }

    function supportsInterface(bytes4 interfaceID) external pure returns (bool) {
        return  interfaceID == 0x01ffc9a7 ||    // ERC165
                interfaceID == 0x4e2312e0;      // ERC1155_ACCEPTED ^ ERC1155_BATCH_ACCEPTED;
    }
}



pragma solidity 0.6.12;


abstract
contract StakingLot is ERC20, IStakingLot, ERC1155Receiver, Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    IERC20 public immutable ROYA;
    uint public constant MAX_SUPPLY = 2000;
    uint public constant LOT_PRICE = 10000 * 10**18;
    uint public constant DISCOUNTED_LOT_PRICE = 7200 * 10**18;
    uint internal constant ACCURACY = 1e30;
    address payable public immutable FALLBACK_RECIPIENT;
    RoyaNFT RNFT;

    uint public totalProfit = 0;
    mapping(address => uint) internal lastProfit;
    mapping(address => uint) internal savedProfit;


    uint256 public lockupPeriod = 691200;
    mapping(address => uint256) public lastBoughtTimestamp;
    mapping(address => bool) public _revertTransfersInLockUpPeriod;
    mapping(address => mapping (uint256 => bool)) public hasLockedNFT;
    mapping(address => uint256) public discountedLots;
    bool public allowNFTDiscounts;


    constructor(ERC20 _token, string memory name, string memory short, RoyaNFT _rnft, address _multisigWallet)
        public
        ERC20(name, short) Ownable(_multisigWallet)
    {
        ROYA = _token;
        _setupDecimals(0);
        FALLBACK_RECIPIENT = msg.sender;
        RNFT = _rnft;
        allowNFTDiscounts = true;
    }

    function claimProfit() external override returns (uint profit) {
        profit = saveProfit(msg.sender);
        require(profit > 0, "Zero profit");
        savedProfit[msg.sender] = 0;
        _transferProfit(profit);
        emit Claim(msg.sender, profit);
    }

    function buy(uint amount) external override {
        lastBoughtTimestamp[msg.sender] = block.timestamp;
        require(amount > 0, "Amount is zero");
        require(totalSupply() + amount <= MAX_SUPPLY);
        _mint(msg.sender, amount);
        ROYA.safeTransferFrom(msg.sender, address(this), amount.mul(LOT_PRICE));
    }
    
    function buyWithNFT(uint256 amount, uint256 id) external{
        lastBoughtTimestamp[msg.sender] = block.timestamp;
        require(allowNFTDiscounts, "NFT discounts disabled");
        require(amount > 0, "Amount is zero");
        require(id >= 1 && id <= 72, "Should be Queen NFT");
        require(RNFT.balanceOf(msg.sender, id) > 0,"No NFT to claim discount");
        require(totalSupply() + amount <= MAX_SUPPLY);
        
        _mint(msg.sender, amount);
        hasLockedNFT[msg.sender][id] = true;

        amount = amount - 1;
        RNFT.safeTransferFrom(msg.sender, address(this), id, 1, '0x');
        ROYA.safeTransferFrom(msg.sender, address(this), amount.mul(LOT_PRICE).add(DISCOUNTED_LOT_PRICE));
        discountedLots[msg.sender] += 1;

    }
    
    
    function sell(uint amount) external override lockupFree {
        require(balanceOf(msg.sender) - discountedLots[msg.sender] >= amount,"NFT locked in contract or Invalid Amount");
        _burn(msg.sender, amount);
        ROYA.safeTransfer(msg.sender, amount.mul(LOT_PRICE));
    }

    function sellWithNFT(uint amount, uint256 id) external lockupFree {
        require(hasLockedNFT[msg.sender][id],"This NFT is not locked");
        require(amount>0,"Invalid amount.");
        require(amount-1<=balanceOf(msg.sender).sub(discountedLots[msg.sender]),"Invalid amount.");
        RNFT.safeTransferFrom(address(this), msg.sender, id, 1, '0x');
        hasLockedNFT[msg.sender][id] = false;

        _burn(msg.sender, amount);
        amount =amount - 1;
        discountedLots[msg.sender] -= 1;
        ROYA.safeTransfer(msg.sender, amount.mul(LOT_PRICE).add(DISCOUNTED_LOT_PRICE));
    }

    function revertTransfersInLockUpPeriod(bool value) external {
        _revertTransfersInLockUpPeriod[msg.sender] = value;
    }
    
    function setAllowNFTDiscounts(bool value) external onlyOwner {
        allowNFTDiscounts = value;
    }

    function profitOf(address account) external view override returns (uint) {
        return savedProfit[account].add(getUnsaved(account));
    }

    function getUnsaved(address account) internal view returns (uint profit) {
        return totalProfit.sub(lastProfit[account]).mul(balanceOf(account)).div(ACCURACY);
    }


    function getLockedNFTs(address account) external view returns (uint[] memory) {
        uint256[] memory s= new uint256[](72);
        uint256 j=0;
        for(uint i = 1; i<=72; i++){
            if(hasLockedNFT[account][i]){
                s[j++]=i;
            }
        }
        return s;
    }



    function saveProfit(address account) internal returns (uint profit) {
        uint unsaved = getUnsaved(account);
        lastProfit[account] = totalProfit;
        profit = savedProfit[account].add(unsaved);
        savedProfit[account] = profit;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
	require(amount>0,"Invalid amount");
        if (from != address(0)) saveProfit(from);
        if (to != address(0)) saveProfit(to);
        if (
            lastBoughtTimestamp[from].add(lockupPeriod) > block.timestamp &&
            lastBoughtTimestamp[from] > lastBoughtTimestamp[to]
        ) {
            require(
                !_revertTransfersInLockUpPeriod[to],
                "the recipient does not accept blocked funds"
            );
            lastBoughtTimestamp[to] = lastBoughtTimestamp[from];
        }
        
    }
    
    function _transferProfit(uint amount) internal virtual;

    modifier lockupFree {
        require(
            lastBoughtTimestamp[msg.sender].add(lockupPeriod) <= block.timestamp,
            "Action suspended due to lockup"
              );
        _;
    }
}


pragma solidity 0.6.12;


contract RoyaleQueenStakingLot is StakingLot, IStakingLotERC20 {
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    IERC20 public immutable USDC;

    constructor(ERC20 _token, ERC20 usdc, RoyaNFT rnft, address _multisigWallet) public
        StakingLot(_token, "QROYA", "qRoya", rnft, _multisigWallet) {
        USDC = usdc;
    }

    function sendProfit(uint amount) external override {
        uint _totalSupply = totalSupply();
        if (_totalSupply > 0) {
            totalProfit += amount.mul(ACCURACY) / _totalSupply;
            USDC.safeTransferFrom(msg.sender, address(this), amount);
            emit Profit(amount);
        } else {
            USDC.safeTransferFrom(msg.sender, FALLBACK_RECIPIENT, amount);
        }
    }

    function _transferProfit(uint amount) internal override {
        USDC.safeTransfer(msg.sender, amount);
    }
}