



pragma solidity ^0.8.0;

library ECDSA {

    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {

        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {

        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}



interface IUniswapV2Router {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);


    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}


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
}



abstract contract IERC20Token is IERC20 {
    function upgrade(uint256 value) public virtual;
}



contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == msg.sender || _owner == address(0x0), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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




contract FundsRecovery is Ownable, ReentrancyGuard {

    address payable internal fundsDestination;
    IERC20Token public token;

    event DestinationChanged(address indexed previousDestination, address indexed newDestination);

    function setFundsDestination(address payable _newDestination) public virtual onlyOwner {

        require(_newDestination != address(0));
        emit DestinationChanged(fundsDestination, _newDestination);
        fundsDestination = _newDestination;
    }

    function getFundsDestination() public view returns (address) {

        return fundsDestination;
    }

    function claimEthers() public nonReentrant {

        require(fundsDestination != address(0));
        fundsDestination.transfer(address(this).balance);
    }

    function claimTokens(address _token) public nonReentrant {

        require(fundsDestination != address(0));
        require(_token != address(token), "native token funds can't be recovered");
        uint256 _amount = IERC20Token(_token).balanceOf(address(this));
        IERC20Token(_token).transfer(fundsDestination, _amount);
    }
}


contract Utils {

    function getChainID() internal view returns (uint256) {

        uint256 chainID;
        assembly {
            chainID := chainid()
        }
        return chainID;
    }

    function max(uint a, uint b) internal pure returns (uint) {

        return a > b ? a : b;
    }

    function min(uint a, uint b) internal pure returns (uint) {

        return a < b ? a : b;
    }

    function round(uint a, uint m) internal pure returns (uint ) {

        return ((a + m - 1) / m) * m;
    }
}


interface IdentityRegistry {

    function isRegistered(address _identity) external view returns (bool);

    function minimalHermesStake() external view returns (uint256);

    function getChannelAddress(address _identity, address _hermesId) external view returns (address);

    function getBeneficiary(address _identity) external view returns (address);

    function setBeneficiary(address _identity, address _newBeneficiary, bytes memory _signature) external;

}

contract HermesImplementation is FundsRecovery, Utils {

    using ECDSA for bytes32;

    string constant STAKE_RETURN_PREFIX = "Stake return request";
    uint256 constant DELAY_SECONDS = 259200;   // 3 days
    uint256 constant UNIT_SECONDS = 3600;      // 1 unit = 1 hour = 3600 seconds
    uint16 constant PUNISHMENT_PERCENT = 4;    // 0.04%

    IdentityRegistry internal registry;
    address internal operator;                 // TODO have master operator who could change operator or manage funds

    uint256 internal totalStake;               // total amount staked by providers

    uint256 internal minStake;                 // minimal possible provider's stake (channel opening during promise settlement will use it)
    uint256 internal maxStake;                 // maximal allowed provider's stake
    uint256 internal hermesStake;              // hermes stake is used to prove hermes' sustainability
    uint256 internal closingTimelock;          // blocknumber after which getting stake back will become possible
    IUniswapV2Router internal dex;             // any uniswap v2 compatible dex router address

    enum Status { Active, Paused, Punishment, Closed } // hermes states
    Status internal status;

    struct HermesFee {
        uint16 value;                      // subprocent amount. e.g. 2.5% = 250
        uint64 validFrom;                  // timestamp from which fee is valid
    }
    HermesFee public lastFee;              // default fee to look for
    HermesFee public previousFee;          // previous fee is used if last fee is still not active

    struct Channel {
        uint256 settled;                   // total amount already settled by provider
        uint256 stake;                     // amount staked by identity to guarante channel size, it also serves as channel balance
        uint256 lastUsedNonce;             // last known nonce, is used to protect signature based calls from replay attack
        uint256 timelock;                  // blocknumber after which channel balance can be decreased
    }
    mapping(bytes32 => Channel) public channels;

    struct Punishment {
        uint256 activationBlockTime;       // block timestamp in which punishment was activated
        uint256 amount;                    // total amount of tokens locked because of punishment
    }
    Punishment public punishment;

    function getOperator() public view returns (address) {

        return operator;
    }

    function getChannelId(address _identity) public view returns (bytes32) {

        return keccak256(abi.encodePacked(_identity, address(this)));
    }

    function getChannelId(address _identity, string memory _type) public view returns (bytes32) {

        return keccak256(abi.encodePacked(_identity, address(this), _type));
    }

    function getRegistry() public view returns (address) {

        return address(registry);
    }

    function getActiveFee() public view returns (uint256) {

        HermesFee memory _activeFee = (block.timestamp >= lastFee.validFrom) ? lastFee : previousFee;
        return uint256(_activeFee.value);
    }

    function getHermesStake() public view returns (uint256) {

        return hermesStake;
    }

    function getStakeThresholds() public view returns (uint256, uint256) {

        return (minStake, maxStake);
    }

    function getStatus() public view returns (Status) {

        return status;
    }

    event PromiseSettled(address indexed identity, bytes32 indexed channelId, address indexed beneficiary, uint256 amountSentToBeneficiary, uint256 fees, bytes32 lock);
    event NewStake(bytes32 indexed channelId, uint256 stakeAmount);
    event MinStakeValueUpdated(uint256 newMinStake);
    event MaxStakeValueUpdated(uint256 newMaxStake);
    event HermesFeeUpdated(uint16 newFee, uint64 validFrom);
    event HermesClosed(uint256 blockTimestamp);
    event ChannelOpeningPaused();
    event ChannelOpeningActivated();
    event FundsWithdrawned(uint256 amount, address beneficiary);
    event HermesStakeIncreased(uint256 newStake);
    event HermesPunishmentActivated(uint256 activationBlockTime);
    event HermesPunishmentDeactivated();

    modifier onlyOperator() {

        require(msg.sender == operator, "Hermes: only hermes operator can call this function");
        _;
    }


    function initialize(address _token, address _operator, uint16 _fee, uint256 _minStake, uint256 _maxStake, address payable _dexAddress) public virtual {

        require(!isInitialized(), "Hermes: have to be not initialized");
        require(_token != address(0), "Hermes: token can't be deployd into zero address");
        require(_operator != address(0), "Hermes: operator have to be set");
        require(_fee <= 5000, "Hermes: fee can't be bigger than 50%");
        require(_maxStake > _minStake, "Hermes: maxStake have to be bigger than minStake");

        registry = IdentityRegistry(msg.sender);
        token = IERC20Token(_token);
        operator = _operator;
        lastFee = HermesFee(_fee, uint64(block.timestamp));
        minStake = _minStake;
        maxStake = _maxStake;
        hermesStake = token.balanceOf(address(this));

        token.approve(_dexAddress, type(uint256).max);
        dex = IUniswapV2Router(_dexAddress);
    }

    function isInitialized() public view returns (bool) {

        return operator != address(0);
    }


    function openChannel(address _identity, uint256 _amountToStake) public {

        require(msg.sender == address(registry), "Hermes: only registry can open channels");
        require(getStatus() == Status.Active, "Hermes: have to be in active state");
        require(_amountToStake >= minStake, "Hermes: min stake amount not reached");
        _increaseStake(getChannelId(_identity), _amountToStake, false);
    }

    function _settlePromise(
        bytes32 _channelId,
        uint256 _amount,
        uint256 _transactorFee,
        bytes32 _preimage,
        bytes memory _signature,
        bool _takeFee,
        bool _ignoreStake
    ) private returns (uint256, uint256) {

        require(
            isHermesActive(),
            "Hermes: hermes have to be in active state"
        ); // if hermes is not active, then users can only take stake back
        require(
            validatePromise(_channelId, _amount, _transactorFee, _preimage, _signature),
            "Hermes: have to be properly signed payment promise"
        );

        Channel storage _channel = channels[_channelId];
        require(_channel.settled > 0 || _channel.stake >= minStake || _ignoreStake, "Hermes: not enough stake");

        uint256 _availableBalance = availableBalance();
        if (_availableBalance < _channel.stake) {
            status = Status.Punishment;
            punishment.activationBlockTime = block.timestamp;
            emit HermesPunishmentActivated(block.timestamp);
        }

        uint256 _unpaidAmount = _amount - _channel.settled;
        require(_unpaidAmount > _transactorFee, "Hermes: amount to settle should cover transactor fee");

        uint256 _maxSettlementAmount = max(maxStake, _channel.stake);
        if (_unpaidAmount > _availableBalance || _unpaidAmount > _maxSettlementAmount) {
               _unpaidAmount = min(_availableBalance, _maxSettlementAmount);
        }

        _channel.settled = _channel.settled + _unpaidAmount; // Increase already paid amount.
        uint256 _fees = _transactorFee + (_takeFee ? calculateHermesFee(_unpaidAmount) : 0);

        if (_transactorFee > 0) {
            token.transfer(msg.sender, _transactorFee);
        }

        uint256 _amountToTransfer = _unpaidAmount -_fees;

        return (_amountToTransfer, _fees);
    }

    function settlePromise(address _identity, uint256 _amount, uint256 _transactorFee, bytes32 _preimage, bytes memory _signature) public {

        address _beneficiary = registry.getBeneficiary(_identity);
        require(_beneficiary != address(0), "Hermes: identity have to be registered, beneficiary have to be set");

        bytes32 _channelId = getChannelId(_identity);
        (uint256 _amountToTransfer, uint256 _fees) = _settlePromise(_channelId, _amount, _transactorFee, _preimage, _signature, true, false);
        token.transfer(_beneficiary, _amountToTransfer);

        emit PromiseSettled(_identity, _channelId, _beneficiary, _amountToTransfer, _fees, _preimage);
    }

    function payAndSettle(address _identity, uint256 _amount, uint256 _transactorFee, bytes32 _preimage, bytes memory _signature, address _beneficiary, bytes memory _beneficiarySignature) public {

        bytes32 _channelId = getChannelId(_identity, "withdrawal");

        address _signer = keccak256(abi.encodePacked(getChainID(), _channelId, _amount, _preimage, _beneficiary)).recover(_beneficiarySignature);
        require(_signer == _identity, "Hermes: payAndSettle request should be properly signed");

        (uint256 _amountToTransfer, uint256 _fees) = _settlePromise(_channelId, _amount, _transactorFee, _preimage, _signature, false, true);
        token.transfer(_beneficiary, _amountToTransfer);

        emit PromiseSettled(_identity, _channelId, _beneficiary, _amountToTransfer, _fees, _preimage);
    }

    function settleWithBeneficiary(address _identity, uint256 _amount, uint256 _transactorFee, bytes32 _preimage, bytes memory _promiseSignature, address _newBeneficiary, bytes memory _beneficiarySignature) public {

        registry.setBeneficiary(_identity, _newBeneficiary, _beneficiarySignature);

        bytes32 _channelId = getChannelId(_identity);
        (uint256 _amountToTransfer, uint256 _fees) = _settlePromise(_channelId, _amount, _transactorFee, _preimage, _promiseSignature, true, false);
        token.transfer(_newBeneficiary, _amountToTransfer);

        emit PromiseSettled(_identity, _channelId, _newBeneficiary, _amountToTransfer, _fees, _preimage);
    }

    function settleWithDEX(address _identity, uint256 _amount, uint256 _transactorFee, bytes32 _preimage, bytes memory _signature) public {

        address _beneficiary = registry.getBeneficiary(_identity);
        require(_beneficiary != address(0), "Hermes: identity have to be registered, beneficiary have to be set");

        bytes32 _channelId = getChannelId(_identity);
        (uint256 _amountToTransfer, uint256 _fees) = _settlePromise(_channelId, _amount, _transactorFee, _preimage, _signature, true, false);

        uint amountOutMin = 0;
        address[] memory path = new address[](2);
        path[0] = address(token);
        path[1] = dex.WETH();

        dex.swapExactTokensForETH(_amountToTransfer, amountOutMin, path, _beneficiary, block.timestamp);

        emit PromiseSettled(_identity, _channelId, _beneficiary, _amountToTransfer, _fees, _preimage);
    }


    function _increaseStake(bytes32 _channelId, uint256 _amountToAdd, bool _duringSettlement) internal {

        Channel storage _channel = channels[_channelId];
        uint256 _newStakeAmount = _channel.stake +_amountToAdd;
        require(_newStakeAmount <= maxStake, "Hermes: total amount to stake can't be bigger than maximally allowed");
        require(_newStakeAmount >= minStake, "Hermes: stake can't be less than required min stake");

        if (!_duringSettlement) {
            require(token.transferFrom(msg.sender, address(this), _amountToAdd), "Hermes: token transfer should succeed");
        }

        _channel.stake = _newStakeAmount;
        totalStake = totalStake + _amountToAdd;

        emit NewStake(_channelId, _newStakeAmount);
    }

    function increaseStake(bytes32 _channelId, uint256 _amount) public {

        require(getStatus() != Status.Closed, "hermes should be not closed");
        _increaseStake(_channelId, _amount, false);
    }

    function settleIntoStake(address _identity, uint256 _amount, uint256 _transactorFee, bytes32 _preimage, bytes memory _signature) public {

        bytes32 _channelId = getChannelId(_identity);
        (uint256 _stakeIncreaseAmount, uint256 _paidFees) = _settlePromise(_channelId, _amount, _transactorFee, _preimage, _signature, true, true);
        emit PromiseSettled(_identity, _channelId, address(this), _stakeIncreaseAmount, _paidFees, _preimage);
        _increaseStake(_channelId, _stakeIncreaseAmount, true);
    }

    function decreaseStake(address _identity, uint256 _amount, uint256 _transactorFee, bytes memory _signature) public {

        bytes32 _channelId = getChannelId(_identity);
        require(isChannelOpened(_channelId), "Hermes: channel has to be opened");
        require(_amount >= _transactorFee, "Hermes: amount should be bigger than transactor fee");

        Channel storage _channel = channels[_channelId];
        require(_amount <= _channel.stake, "Hermes: can't withdraw more than the current stake");

        _channel.lastUsedNonce = _channel.lastUsedNonce + 1;
        address _signer = keccak256(abi.encodePacked(STAKE_RETURN_PREFIX, getChainID(), _channelId, _amount, _transactorFee, _channel.lastUsedNonce)).recover(_signature);
        require(getChannelId(_signer) == _channelId, "Hermes: have to be signed by channel party");

        uint256 _newStakeAmount = _channel.stake - _amount;
        require(_newStakeAmount == 0 || _newStakeAmount >= minStake, "Hermes: stake can't be less than required min stake");

        _channel.stake = _newStakeAmount;
        totalStake = totalStake - _amount;

        if (_transactorFee > 0) {
            token.transfer(msg.sender, _transactorFee);
        }

        address _beneficiary = registry.getBeneficiary(_identity);
        token.transfer(_beneficiary, _amount - _transactorFee);

        emit NewStake(_channelId, _newStakeAmount);
    }


    function resolveEmergency() public {

        require(getStatus() == Status.Punishment, "Hermes: should be in punishment status");

        uint256 _punishmentPerUnit = round(totalStake * PUNISHMENT_PERCENT, 100) / 100;

        uint256 _unit = getUnitTime();
        uint256 _timePassed = block.timestamp - punishment.activationBlockTime;
        uint256 _punishmentUnits = round(_timePassed, _unit) / _unit - 1;

        uint256 _punishmentAmount = _punishmentUnits * _punishmentPerUnit;
        punishment.amount = punishment.amount + _punishmentAmount;  // XXX alternativelly we could send tokens into BlackHole (0x0000000...)

        uint256 _shouldHave = minimalExpectedBalance() + maxStake;  // hermes should have funds for at least one maxStake settlement
        uint256 _currentBalance = token.balanceOf(address(this));

        if (_currentBalance < _shouldHave) {
            token.transferFrom(msg.sender, address(this), _shouldHave - _currentBalance);
        }

        status = Status.Active;

        emit HermesPunishmentDeactivated();
    }

    function getUnitTime() internal pure virtual returns (uint256) {

        return UNIT_SECONDS;
    }

    function setMinStake(uint256 _newMinStake) public onlyOwner {

        require(isHermesActive(), "Hermes: has to be active");
        require(_newMinStake < maxStake, "Hermes: minStake has to be smaller than maxStake");
        minStake = _newMinStake;
        emit MinStakeValueUpdated(_newMinStake);
    }

    function setMaxStake(uint256 _newMaxStake) public onlyOwner {

        require(isHermesActive(), "Hermes: has to be active");
        require(_newMaxStake > minStake, "Hermes: maxStake has to be bigger than minStake");
        maxStake = _newMaxStake;
        emit MaxStakeValueUpdated(_newMaxStake);
    }

    function setHermesFee(uint16 _newFee) public onlyOwner {

        require(getStatus() != Status.Closed, "Hermes: should be not closed");
        require(_newFee <= 5000, "Hermes: fee can't be bigger than 50%");
        require(block.timestamp >= lastFee.validFrom, "Hermes: can't update inactive fee");

        uint64 _validFrom = uint64(getTimelock());

        previousFee = lastFee;
        lastFee = HermesFee(_newFee, _validFrom);

        emit HermesFeeUpdated(_newFee, _validFrom);
    }

    function increaseHermesStake(uint256 _additionalStake) public onlyOwner {

        if (availableBalance() < _additionalStake) {
            uint256 _diff = _additionalStake - availableBalance();
            token.transferFrom(msg.sender, address(this), _diff);
        }

        hermesStake = hermesStake + _additionalStake;

        emit HermesStakeIncreased(hermesStake);
    }

    function withdraw(address _beneficiary, uint256 _amount) public onlyOwner {

        require(isHermesActive(), "Hermes: have to be active");
        require(availableBalance() >= _amount, "Hermes: should be enough funds available to withdraw");

        token.transfer(_beneficiary, _amount);

        emit FundsWithdrawned(_amount, _beneficiary);
    }

    function availableBalance() public view returns (uint256) {

        uint256 _totalLockedAmount = minimalExpectedBalance();
        uint256 _currentBalance = token.balanceOf(address(this));
        if (_totalLockedAmount > _currentBalance) {
            return uint256(0);
        }
        return _currentBalance - _totalLockedAmount;
    }

    function isChannelOpened(bytes32 _channelId) public view returns (bool) {

        return channels[_channelId].settled != 0 || channels[_channelId].stake != 0;
    }

    function isHermesActive() public view returns (bool) {

        Status _status = getStatus();
        return _status != Status.Punishment && _status != Status.Closed;
    }

    function pauseChannelOpening() public onlyOperator {

        require(getStatus() == Status.Active, "Hermes: have to be in active state");
        status = Status.Paused;
        emit ChannelOpeningPaused();
    }

    function activateChannelOpening() public onlyOperator {

        require(getStatus() == Status.Paused, "Hermes: have to be in paused state");
        status = Status.Active;
        emit ChannelOpeningActivated();
    }

    function closeHermes() public onlyOwner {

        require(isHermesActive(), "Hermes: should be active");
        status = Status.Closed;
        closingTimelock = getEmergencyTimelock();
        emit HermesClosed(block.timestamp);
    }

    function getStakeBack(address _beneficiary) public onlyOwner {

        require(getStatus() == Status.Closed, "Hermes: have to be closed");
        require(block.timestamp > closingTimelock, "Hermes: timelock period should be already passed");

        uint256 _amount = token.balanceOf(address(this)) - punishment.amount;
        token.transfer(_beneficiary, _amount);
    }

    function getTimelock() internal view virtual returns (uint256) {

        return block.timestamp + DELAY_SECONDS;
    }

    function calculateHermesFee(uint256 _amount) public view returns (uint256) {

        return round((_amount * getActiveFee() / 100), 100) / 100;
    }

    function minimalExpectedBalance() public view returns (uint256) {

        return max(hermesStake, punishment.amount) + totalStake;
    }

    function getEmergencyTimelock() internal view virtual returns (uint256) {

        return block.timestamp + DELAY_SECONDS * 100; // 300 days
    }

    function validatePromise(bytes32 _channelId, uint256 _amount, uint256 _transactorFee, bytes32 _preimage, bytes memory _signature) public view returns (bool) {

        bytes32 _hashlock = keccak256(abi.encodePacked(_preimage));
        address _signer = keccak256(abi.encodePacked(getChainID(), _channelId, _amount, _transactorFee, _hashlock)).recover(_signature);
        return _signer == operator;
    }
}