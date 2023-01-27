
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


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

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


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

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
}// GPL-3.0-only

pragma solidity ^0.8.4;


contract WhitelistAuction is ERC20, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20Metadata;


    uint public constant FIRST_AUCTION_DURATION = 2 days;
    uint public constant SECOND_AUCTION_DURATION = 1 days;

    uint public constant VEST_DURATION = 26 weeks;

    uint public constant vestStartTime = 1679155200;

    uint public firstAuctionStartTime;
    uint public firstAuctionEndTime;
    uint public secondAuctionEndTime;

    address immutable public stargateTreasury;
    uint8 immutable public astgDecimals;

    IERC20Metadata immutable public stableCoin;
    IERC20Metadata immutable public stargateToken;

    uint public constant USD_AUCTION_CAP = 5_000_000;
    uint public constant STARGATE_FOR_AUCTION = 20_000_000;

    mapping(address => bool) public astgWhitelist;
    mapping(address => bool) public bondingWhitelist;

    uint public capStgAuctionAmount;
    uint immutable public astgWhitelistMaxAlloc;
    uint immutable public bondingWhitelistMaxAlloc;
    bool public ownerWithdrawn;

    bool public secondAuctionInit;
    uint public secondAuctionAdditionalAllocCap;

    uint public remainingUsdQuota;
    mapping(address => uint) public redeemedShares;
    uint public countOfMaxAuction;

    event FirstAuctioned(address _sender, uint _astgAmount);
    event SecondAuctioned(address _sender, uint _astgAmount);
    event FinalWithdrawal(address _to, uint _remainingUSD, uint _remainingSTG);
    event Redeemed(address _sender, uint _astgAmount, uint _stgAmount);


    constructor(
        address payable _stargateTreasury,
        IERC20Metadata _stargate,
        IERC20Metadata _stableCoin,
        uint _auctionStartTime,
        uint _astgWhitelistMaxAlloc,
        uint _bondingWhitelistMaxAlloc
    )
        ERC20("aaSTG","aaSTG")
    {
        stargateTreasury = _stargateTreasury;

        stargateToken = _stargate;
        stableCoin = _stableCoin;
        astgDecimals = _stableCoin.decimals();
        remainingUsdQuota = USD_AUCTION_CAP * (10 ** _stableCoin.decimals());

        firstAuctionStartTime = _auctionStartTime;
        firstAuctionEndTime = firstAuctionStartTime + FIRST_AUCTION_DURATION;
        secondAuctionEndTime = firstAuctionEndTime + SECOND_AUCTION_DURATION;

        astgWhitelistMaxAlloc = _astgWhitelistMaxAlloc;
        bondingWhitelistMaxAlloc = _bondingWhitelistMaxAlloc;
    }


    function addAuctionAddresses(address[] calldata addresses) external onlyOwner {
        uint length = addresses.length;
        uint i;
        while(i < length){
            astgWhitelist[addresses[i]] = true;
            i++;
        }
    }

    function addBondAddresses(address[] calldata addresses) external onlyOwner {
        uint length = addresses.length;
        uint i;
        while(i < length){
            bondingWhitelist[addresses[i]] = true;
            i++;
        }
    }

    function withdrawRemainingStargate(address _to) external onlyOwner {
        require(block.timestamp > secondAuctionEndTime, "Stargate: second auction not finished");
        require(!ownerWithdrawn, "Stargate: owner has withdrawn");

        uint startingCap = STARGATE_FOR_AUCTION * (10 ** stargateToken.decimals());

        uint usdAuctionCap = USD_AUCTION_CAP * (10 ** astgDecimals);
        uint remainingSTG = startingCap * remainingUsdQuota / usdAuctionCap;

        capStgAuctionAmount = startingCap - remainingSTG;

        stargateToken.safeTransfer(_to, remainingSTG);

        ownerWithdrawn = true;

        emit FinalWithdrawal(_to, remainingUsdQuota, remainingSTG);
    }


    function _beforeTokenTransfer(address _from, address, uint) internal virtual override {
        require(_from == address(0), "non-transferable");
    }

    function decimals() public view virtual override returns(uint8) {
        return astgDecimals;
    }


    function enterFirstAuction(uint _requestAmount) external nonReentrant {
        require(_requestAmount > 0, "Stargate: request amount must > 0");
        require(block.timestamp >= firstAuctionStartTime && block.timestamp < firstAuctionEndTime, "Stargate: not in the first auction period");
        require(remainingUsdQuota > 0, "Stargate: auction reaches its cap");

        uint maxExecAmount = this.getFirstAuctionCapAmount(msg.sender);

        uint balance = this.balanceOf(msg.sender);
        require(balance < maxExecAmount, "Stargate: already at max");

        if (balance + _requestAmount >= maxExecAmount) {
            _requestAmount = maxExecAmount - balance;
            countOfMaxAuction++;
        }

        uint execAmount = _executeAuction(_requestAmount);
        emit FirstAuctioned(msg.sender, execAmount);
    }

    function enterSecondAuction(uint _requestAmount) external nonReentrant {
        require(block.timestamp >= firstAuctionEndTime && block.timestamp < secondAuctionEndTime, "Stargate: not in the second auction period");
        require(remainingUsdQuota > 0, "Stargate: auction reaches its cap");

        if (!secondAuctionInit) {
            secondAuctionAdditionalAllocCap = remainingUsdQuota / countOfMaxAuction;
            secondAuctionInit = true;
        }

        uint firstAuctionMaxExecAmount = this.getFirstAuctionCapAmount(msg.sender);
        uint balance = this.balanceOf(msg.sender);
        require(balance >= firstAuctionMaxExecAmount, "Stargate: not eligible for the second auction");

        uint maxExecAmount = firstAuctionMaxExecAmount + secondAuctionAdditionalAllocCap;
        if (balance + _requestAmount >= maxExecAmount) {
            _requestAmount = maxExecAmount - balance;
        }

        uint execAmount = _executeAuction(_requestAmount);
        emit SecondAuctioned(msg.sender, execAmount);
    }

    function secondAuctionAllocCap() external view returns(uint) {
        if(!secondAuctionInit){
            return remainingUsdQuota / countOfMaxAuction;
        }else{
            return secondAuctionAdditionalAllocCap;
        }
    }

    function getFirstAuctionCapAmount(address user) public view returns(uint) {
        if (astgWhitelist[user]) return astgWhitelistMaxAlloc;
        if (bondingWhitelist[user]) return bondingWhitelistMaxAlloc;
        revert("Stargate: not a whitelisted address");
    }

    function _executeAuction(uint _execAmount) internal returns(uint finalExecAmount){
        if(_execAmount > remainingUsdQuota) {
            finalExecAmount = remainingUsdQuota;
        } else {
            finalExecAmount = _execAmount;
        }

        remainingUsdQuota -= finalExecAmount;
        stableCoin.safeTransferFrom(msg.sender, stargateTreasury, finalExecAmount);
        _mint(msg.sender, finalExecAmount);
    }

    function redeem() external nonReentrant {
        require(block.timestamp >= vestStartTime, "Stargate: vesting not started");
        require(capStgAuctionAmount != 0, "Stargate: stargate for vesting not set");

        uint vestSinceStart = block.timestamp - vestStartTime;
        if(vestSinceStart > VEST_DURATION){
            vestSinceStart = VEST_DURATION;
        }

        uint totalRedeemableShares = balanceOf(msg.sender) * vestSinceStart / VEST_DURATION;
        uint redeemed = redeemedShares[msg.sender];
        require(totalRedeemableShares > redeemed, "Stargate: nothing to redeem");

        uint newSharesToRedeem = totalRedeemableShares - redeemed;
        redeemedShares[msg.sender] = redeemed + newSharesToRedeem;

        uint stargateAmount = capStgAuctionAmount * newSharesToRedeem / totalSupply();
        stargateToken.safeTransfer(msg.sender, stargateAmount);

        emit Redeemed(msg.sender, newSharesToRedeem, stargateAmount);
    }

    function redeemable(address _redeemer) external view returns(uint){
        require(block.timestamp >= vestStartTime, "Stargate: vesting not started");
        require(capStgAuctionAmount != 0, "Stargate: stargate for vesting not set");

        uint vestSinceStart = block.timestamp - vestStartTime;
        if(vestSinceStart > VEST_DURATION){
            vestSinceStart = VEST_DURATION;
        }

        uint totalRedeemableShares = balanceOf(_redeemer) * vestSinceStart / VEST_DURATION;
        uint redeemed = redeemedShares[_redeemer];
        require(totalRedeemableShares > redeemed, "Stargate: nothing to redeem");

        uint newSharesToRedeem = totalRedeemableShares - redeemed;

        return capStgAuctionAmount * newSharesToRedeem / totalSupply();
    }
}