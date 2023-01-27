



pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




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

}




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
}




pragma solidity ^0.8.1;

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




pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

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

}




pragma solidity ^0.8.0;





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
}



pragma solidity ^0.8.13;






abstract contract Owned {
    address public owner;
    address public nominatedOwner;

    constructor(address _owner) {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {
        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external {
        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner {
        _onlyOwner();
        _;
    }

    function _onlyOwner() private view {
        require(msg.sender == owner, "Only the contract owner may perform this action");
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}

abstract contract Pausable is Owned {
    uint public lastPauseTime;
    bool public paused;

    constructor() {
        require(owner != address(0), "Owner must be set");
    }

    function setPaused(bool _paused) external onlyOwner {
        if (_paused == paused) {
            return;
        }

        paused = _paused;

        if (paused) {
            lastPauseTime = block.timestamp;
        }

        emit PauseChanged(paused);
    }

    event PauseChanged(bool isPaused);

    modifier notPaused {
        require(!paused, "This action cannot be performed while the contract is paused");
        _;
    }
}




interface IERC4626 is IERC20 {

    function asset() external view returns(address assetTokenAddress);


    function totalAssets() external view returns(uint256 totalManagedAssets);


    function convertToShares(uint256 assets) external view returns(uint256 shares); 


    function convertToAssets(uint256 shares) external view returns(uint256 assets);

 
    function maxDeposit(address receiver) external view returns(uint256 maxAssets);


    function previewDeposit(uint256 assets) external view returns(uint256 shares);


    function deposit(uint256 assets, address receiver) external returns(uint256 shares);


    function maxMint(address receiver) external view returns(uint256 maxShares); 


    function previewMint(uint256 shares) external view returns(uint256 assets);


    function mint(uint256 shares, address receiver) external returns(uint256 assets);


    function maxWithdraw(address owner) external view returns(uint256 maxAssets);


    function previewWithdraw(uint256 assets) external view returns(uint256 shares);


    function withdraw(uint256 assets, address receiver, address owner) external returns(uint256 shares);


    function maxRedeem(address owner) external view returns(uint256 maxShares);


    function previewRedeem(uint256 shares) external view returns(uint256 assets);


    function redeem(uint256 shares, address receiver, address owner) external returns(uint256 assets);


    event Deposit(address indexed caller, address indexed owner, uint256 assets, uint256 shares);
    event Withdraw(address indexed caller, address indexed receiver, address indexed owner, uint256 assets, uint256 shares);
}

error Unauthorized();
error InsufficientBalance(uint256 available, uint256 required);
error NotWhitelisted();
error FundsInGracePeriod();
error FundsNotUnlocked();
error InvalidSetting();
error LockTimeOutOfBounds(uint256 lockTime, uint256 lockMin, uint256 lockMax);
error LockTimeLessThanCurrent(uint256 currentUnlockDate, uint256 newUnlockDate);

abstract contract VeVault is ReentrancyGuard, Pausable, IERC4626 {
    using SafeERC20 for IERC20;

    struct Penalty {
        uint256 gracePeriod;
        uint256 maxPerc;
        uint256 minPerc;
        uint256 stepPerc;
    }
    
    struct LockTimer {
        uint256 min;
        uint256 max;
        uint256 epoch;
        bool    enforce;
    }


    address public _assetTokenAddress;
    uint256 public _totalManagedAssets;
    mapping(address => uint256) public _assetBalances;

    uint256 private _totalSupply;
    mapping(address => uint256) public _shareBalances;
    mapping(address => uint256) private _unlockDate;

    string public _name;
    string public _symbol;

    LockTimer internal _lockTimer;
    Penalty internal _penalty;
    
    mapping(address => bool) public whitelistRecoverERC20;

    uint256 private constant SEC_IN_DAY = 86400;
    uint256 private constant PRECISION = 1e2;
    uint256 private constant CONVERT_PRECISION  = 1e17 / PRECISION;
    uint256 private constant K_3 = 154143856;
    uint256 private constant K_2 = 74861590400;
    uint256 private constant K_1 = 116304927000000;
    uint256 private constant K = 90026564600000000;


    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    
    
    function asset() external view override returns (address assetTokenAddress) {
        return _assetTokenAddress;
    }

    function totalAssets() external view override returns (uint256 totalManagedAssets) {
        return _totalManagedAssets;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _shareBalances[account];
    }

    function convertToShares(uint256 assets, uint256 lockTime) public pure returns (uint256 shares) {
        return assets * veMult(lockTime) / PRECISION;
    }

    function convertToShares(uint256 assets) override external view returns (uint256 shares) {
        return convertToShares(assets, _lockTimer.min);
    }
    
    function convertToAssets(uint256 shares, uint256 lockTime) public pure returns (uint256 assets) {
        return shares * PRECISION / veMult(lockTime);
    }

    function convertToAssets(uint256 shares) override external view returns (uint256 assets) {
        return convertToAssets(shares, _lockTimer.min);
    }
    
    function maxDeposit(address) override external pure returns (uint256 maxAssets) {
        return 2 ** 256 - 1;
    }

    function previewDeposit(uint256 assets, uint256 lockTime) public pure returns (uint256 shares) {
        return convertToShares(assets, lockTime);
    }

    function previewDeposit(uint256 assets) override external view returns (uint256 shares) {
        return previewDeposit(assets, _lockTimer.min);
    }
    
    function maxMint(address) override external pure returns (uint256 maxShares) {
        return 2 ** 256 - 1;
    }

    function previewMint(uint256 shares, uint256 lockTime) public pure returns (uint256 assets) {
        return convertToAssets(shares, lockTime);
    }

    function previewMint(uint256 shares) override external view returns (uint256 assets) {
        return previewMint(shares, _lockTimer.min);
    }
    
    function maxWithdraw(address owner) override external view returns (uint256 maxAssets) {
        if (paused) {
            return 0;
        }
        return _assetBalances[owner];
    }

    function previewWithdraw(uint256 assets, uint256 lockTime) public pure returns (uint256 shares) {
        return convertToShares(assets, lockTime);
    }

    function previewWithdraw(uint256 assets) override external view returns (uint256 shares) {
        return previewWithdraw(assets, _lockTimer.min);
    }
    
    function maxRedeem(address owner) override external view returns (uint256 maxShares) {
        if (paused) {
            return 0;
        }
        return _shareBalances[owner];
    }

    function previewRedeem(uint256 shares, uint256 lockTime) public pure returns (uint256 assets) {
        return convertToAssets(shares, lockTime);
    }

    function previewRedeem(uint256 shares) override external view returns (uint256 assets) {
        return previewRedeem(shares, _lockTimer.min);
    }
    
    function allowance(address, address) override external pure returns (uint256) {
        return 0;
    }

    function assetBalanceOf(address account) external view returns (uint256) {
        return _assetBalances[account];
    }

    function unlockDate(address account) external view returns (uint256) {
        return _unlockDate[account];
    }

    function gracePeriod() external view returns (uint256) {
        return _penalty.gracePeriod;
    }

    function penaltyPercentage() external view returns (uint256) {
        return _penalty.stepPerc;
    }

     function minLockTime() external view returns (uint256) {
         return _lockTimer.min;
     }
    
     function maxLockTime() external view returns (uint256) {
         return _lockTimer.max;
     }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }
    

    function transfer(address, uint256) external pure override returns (bool) {
        revert Unauthorized();
    }

    function approve(address, uint256) external pure override returns (bool) {
        revert Unauthorized();
    }

    function transferFrom(address, address, uint256) external pure override returns (bool) {
        revert Unauthorized();
    }


    function veMult(uint256 lockTime) internal pure returns (uint256) {
        return (
            (((lockTime / SEC_IN_DAY) ** 3) * K_3)
            + ((lockTime / SEC_IN_DAY) * K_1) + K
            - (((lockTime / SEC_IN_DAY) ** 2) * K_2)
            ) / CONVERT_PRECISION;
    }

    function veMult(address owner) external view returns (uint256) {
        if (_assetBalances[owner] == 0) return 0;
        return _shareBalances[owner] * PRECISION / _assetBalances[owner];
    }
    

    function deposit(uint256 assets, address receiver, uint256 lockTime)
            external 
            nonReentrant
            notPaused 
            returns (uint256 shares) {
        return _deposit(assets, receiver, lockTime);
    }
    
    function deposit(uint256 assets, address receiver)
            override
            external
            nonReentrant
            notPaused 
            returns (uint256 shares) {
        return _deposit(assets, receiver, _lockTimer.min);
    }
    
    function mint(uint256 shares, address receiver, uint256 lockTime)
            external 
            nonReentrant
            notPaused
            returns (uint256 assets) {
        uint256 updatedShares = convertToShares(_assetBalances[receiver], lockTime);
        if (updatedShares > _shareBalances[receiver]) {
            uint256 diff = updatedShares - _shareBalances[receiver];
            if (shares <= diff)
                revert Unauthorized();
            assets = convertToAssets(shares - diff, lockTime);
        } else {
            uint256 diff = _shareBalances[receiver] - updatedShares;
            assets = convertToAssets(shares + diff, lockTime);
        }
        _deposit(assets, receiver, lockTime);
        return assets;
    }

    function mint(uint256 shares, address receiver)
            override
            external
            nonReentrant
            notPaused
            returns (uint256 assets) {
        uint256 updatedShares = convertToShares(_assetBalances[receiver], _lockTimer.min);
        if (updatedShares > _shareBalances[receiver]) {
            uint256 diff = updatedShares - _shareBalances[receiver];
            assets = convertToAssets(shares - diff, _lockTimer.min);
        } else {
            uint256 diff = _shareBalances[receiver] - updatedShares;
            assets = convertToAssets(shares + diff, _lockTimer.min);
        }
        _deposit(assets, receiver, _lockTimer.min);
        return assets;
    }
    
    function withdraw(uint256 assets, address receiver, address owner)
            override
            external 
            nonReentrant 
            notPaused
            returns (uint256 shares) {
        return _withdraw(assets, receiver, owner);
    }

    function redeem(uint256 shares, address receiver, address owner)
            override
            external 
            nonReentrant 
            notPaused
            returns (uint256 assets) {
        uint256 diff = _shareBalances[owner] - _assetBalances[owner];
        if (shares < diff)
            revert Unauthorized();
        assets = shares - diff;
        _withdraw(assets, receiver, owner);
        return assets;
    }

    function exit()
            external 
            nonReentrant 
            notPaused
            returns (uint256 shares) {
        return _withdraw(_assetBalances[msg.sender], msg.sender, msg.sender);
    }

    function changeUnlockRule(bool flag) external onlyOwner {
        _lockTimer.enforce = flag;
    }

    function changeGracePeriod(uint256 newGracePeriod) external onlyOwner {
        _penalty.gracePeriod = newGracePeriod;
    }
    
    function changeEpoch(uint256 newEpoch) external onlyOwner {
        if (newEpoch == 0)
            revert InvalidSetting();
        _lockTimer.epoch = newEpoch;
    }
    
    function changeMinPenalty(uint256 newMinPenalty) external onlyOwner {
        if (newMinPenalty >= _penalty.maxPerc)
            revert InvalidSetting();
        _penalty.minPerc = newMinPenalty;
    }
    
    function changeMaxPenalty(uint256 newMaxPenalty) external onlyOwner {
        if (newMaxPenalty <= _penalty.minPerc)
            revert InvalidSetting();
        _penalty.maxPerc = newMaxPenalty;
    }
    
    function changeWhitelistRecoverERC20(address tokenAddress, bool flag) external onlyOwner {
        whitelistRecoverERC20[tokenAddress] = flag;
        emit ChangeWhitelistERC20(tokenAddress, flag);
    }

    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        if (whitelistRecoverERC20[tokenAddress] == false) revert NotWhitelisted();
        
        uint balance = IERC20(tokenAddress).balanceOf(address(this));
        if (balance < tokenAmount) revert InsufficientBalance({
                available: balance,
                required: tokenAmount
        });
        
        IERC20(tokenAddress).safeTransfer(owner, tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }

    function recoverERC721(address tokenAddress, uint256 tokenId) external onlyOwner {
        IERC721(tokenAddress).safeTransferFrom(address(this), owner, tokenId);
        emit RecoveredNFT(tokenAddress, tokenId);
    }

    
    function _deposit(
        uint256 assets,
        address receiver,
        uint256 lockTime
        ) internal 
        updateShares(receiver, lockTime)
        returns (uint256 shares) {
        if (msg.sender != receiver)
            revert Unauthorized();
        if (lockTime < _lockTimer.min || lockTime > _lockTimer.max)
            revert LockTimeOutOfBounds(lockTime, _lockTimer.min, _lockTimer.max);

        uint256 unlockTime = block.timestamp + lockTime;
        if (unlockTime < _unlockDate[receiver])
            revert LockTimeLessThanCurrent(_unlockDate[receiver], unlockTime);
        _unlockDate[receiver] = unlockTime;

        shares = convertToShares(assets, lockTime);
        if (assets == 0) {
            emit Relock(msg.sender, receiver, assets, _unlockDate[receiver]);
        } else {
            _totalManagedAssets += assets;
            _assetBalances[receiver] += assets;
            IERC20(_assetTokenAddress).safeTransferFrom(receiver, address(this), assets);
            emit Deposit(msg.sender, receiver, assets, shares);
        }
        return shares;
    }
    
    function _withdraw(
        uint256 assets,
        address receiver,
        address owner
        ) internal
        updateShares(receiver, _lockTimer.min)
        returns (uint256 shares) {
        if (owner == address(0)) revert Unauthorized();
        if (_assetBalances[owner] < assets)
            revert InsufficientBalance({
                available: _assetBalances[owner],
                required: assets
            });

        if (msg.sender != owner) {
            if (receiver != owner)
                revert Unauthorized();
            if (_lockTimer.enforce && (block.timestamp < _unlockDate[owner] + _penalty.gracePeriod))
                revert FundsNotUnlocked();
            assets -= _payPenalty(owner, assets);
        }
        else if (_lockTimer.enforce && block.timestamp < _unlockDate[owner])
            revert FundsNotUnlocked();

        _totalManagedAssets -= assets;
        _assetBalances[owner] -= assets;
        IERC20(_assetTokenAddress).safeTransfer(receiver, assets);
        shares = assets;
        emit Withdraw(msg.sender, receiver, owner, assets, shares);
        return shares;
    }

    function _payPenalty(address owner, uint256 assets) internal returns (uint256 amountPenalty) {
        uint256 penaltyAmount = _penalty.minPerc 
                        + (((block.timestamp - (_unlockDate[owner] + _penalty.gracePeriod))
                            / _lockTimer.epoch)
                        * _penalty.stepPerc);

        if (penaltyAmount > _penalty.maxPerc) {
            penaltyAmount = _penalty.maxPerc;
        }
        amountPenalty = (assets * penaltyAmount) / 100;

        if (_assetBalances[owner] < amountPenalty)
            revert InsufficientBalance({
                available: _assetBalances[owner],
                required: amountPenalty
            });

        _totalManagedAssets -= amountPenalty;
        _assetBalances[owner] -= amountPenalty;

        IERC20(_assetTokenAddress).safeTransfer(msg.sender, amountPenalty);
        emit PayPenalty(msg.sender, owner, amountPenalty);
        return amountPenalty;
    }
    
    modifier updateShares(address receiver, uint256 lockTime) {
        _;
        uint256 shares = convertToShares(_assetBalances[receiver], lockTime);
        uint256 oldShares = _shareBalances[receiver];
        if (oldShares < shares) {
            uint256 diff = shares - oldShares;
            _totalSupply += diff;
            emit Mint(receiver, diff);
        } else if (oldShares > shares) {
            uint256 diff = oldShares - shares;
            _totalSupply -= diff;
            emit Burn(receiver, diff);
        }
        _shareBalances[receiver] = shares;
    }
    

    event Relock(address indexed caller, address indexed receiver, uint256 assets, uint256 newUnlockDate);
    event PayPenalty(address indexed caller, address indexed owner, uint256 assets);
    event Burn(address indexed user, uint256 shares);
    event Mint(address indexed user, uint256 shares);
    event Recovered(address token, uint256 amount);
    event RecoveredNFT(address tokenAddress, uint256 tokenId);
    event ChangeWhitelistERC20(address indexed tokenAddress, bool whitelistState);
}

contract VeNewO is VeVault("veNewO", "veNWO") {

    constructor(
        address owner_,
        address stakingToken_,
        uint256 gracePeriod_,
        uint256 minLockTime_,
        uint256 maxLockTime_,
        uint256 penaltyPerc_,
        uint256 maxPenalty_,
        uint256 minPenalty_,
        uint256 epoch_
    ) Owned(owner_) {
        _assetTokenAddress = stakingToken_;

        _lockTimer.min = minLockTime_;
        _lockTimer.max = maxLockTime_;
        _lockTimer.epoch = epoch_;
        _lockTimer.enforce = true;
        
        _penalty.gracePeriod = gracePeriod_;
        _penalty.maxPerc = maxPenalty_;
        _penalty.minPerc = minPenalty_;
        _penalty.stepPerc = penaltyPerc_;

        paused = false;
    }
}