
pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity ^0.7.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// BUSL-1.1

pragma solidity 0.7.6;


contract LPTokenERC20 {

    using SafeMath for uint256;

    string public name;
    string public symbol;
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    bytes32 public DOMAIN_SEPARATOR;

    uint256 public decimals;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) public nonces;

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    function _mint(address to, uint256 value) internal {

        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint256 value) internal {

        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(
        address owner,
        address spender,
        uint256 value
    ) private {

        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) private {

        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint256 value) external returns (bool) {

        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint256 value) external returns (bool) {

        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool) {

        if (allowance[from][msg.sender] != uint256(-1)) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        }
        _transfer(from, to, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(msg.sender, spender, allowance[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(msg.sender, spender, allowance[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {

        require(deadline >= block.timestamp, "Bridge: EXPIRED");
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, "Bridge: INVALID_SIGNATURE");
        _approve(owner, spender, value);
    }
}// BUSL-1.1

pragma solidity ^0.7.6;
pragma abicoder v2;

interface IStargateFeeLibrary {

    function getFees(
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        uint16 _dstChainId,
        address _from,
        uint256 _amountSD
    ) external returns (Pool.SwapObj memory s);


    function getVersion() external view returns (string memory);

}// BUSL-1.1

pragma solidity 0.7.6;



contract Pool is LPTokenERC20, ReentrancyGuard {

    using SafeMath for uint256;

    bytes4 private constant SELECTOR = bytes4(keccak256(bytes("transfer(address,uint256)")));
    uint256 public constant BP_DENOMINATOR = 10000;

    struct ChainPath {
        bool ready; // indicate if the counter chainPath has been created.
        uint16 dstChainId;
        uint256 dstPoolId;
        uint256 weight;
        uint256 balance;
        uint256 lkb;
        uint256 credits;
        uint256 idealBalance;
    }

    struct SwapObj {
        uint256 amount;
        uint256 eqFee;
        uint256 eqReward;
        uint256 lpFee;
        uint256 protocolFee;
        uint256 lkbRemove;
    }

    struct CreditObj {
        uint256 credits;
        uint256 idealBalance;
    }


    ChainPath[] public chainPaths; // list of connected chains with shared pools
    mapping(uint16 => mapping(uint256 => uint256)) public chainPathIndexLookup; // lookup for chainPath by chainId => poolId =>index

    uint256 public immutable poolId; // shared id between chains to represent same pool
    uint256 public sharedDecimals; // the shared decimals (lowest common decimals between chains)
    uint256 public localDecimals; // the decimals for the token
    uint256 public immutable convertRate; // the decimals for the token
    address public immutable token; // the token for the pool
    address public immutable router; // the token for the pool

    bool public stopSwap; // flag to stop swapping in extreme cases

    uint256 public totalLiquidity; // the total amount of tokens added on this side of the chain (fees + deposits - withdrawals)
    uint256 public totalWeight; // total weight for pool percentages
    uint256 public mintFeeBP; // fee basis points for the mint/deposit
    uint256 public protocolFeeBalance; // fee balance created from dao fee
    uint256 public mintFeeBalance; // fee balance created from mint fee
    uint256 public eqFeePool; // pool rewards in Shared Decimal format. indicate the total budget for reverse swap incentive
    address public feeLibrary; // address for retrieving fee params for swaps

    uint256 public deltaCredit; // credits accumulated from txn
    bool public batched; // flag to indicate if we want batch processing.
    bool public defaultSwapMode; // flag for the default mode for swap
    bool public defaultLPMode; // flag for the default mode for lp
    uint256 public swapDeltaBP; // basis points of poolCredits to activate Delta in swap
    uint256 public lpDeltaBP; // basis points of poolCredits to activate Delta in liquidity events

    event Mint(address to, uint256 amountLP, uint256 amountSD, uint256 mintFeeAmountSD);
    event Burn(address from, uint256 amountLP, uint256 amountSD);
    event RedeemLocalCallback(address _to, uint256 _amountSD, uint256 _amountToMintSD);
    event Swap(
        uint16 chainId,
        uint256 dstPoolId,
        address from,
        uint256 amountSD,
        uint256 eqReward,
        uint256 eqFee,
        uint256 protocolFee,
        uint256 lpFee
    );
    event SendCredits(uint16 dstChainId, uint256 dstPoolId, uint256 credits, uint256 idealBalance);
    event RedeemRemote(uint16 chainId, uint256 dstPoolId, address from, uint256 amountLP, uint256 amountSD);
    event RedeemLocal(address from, uint256 amountLP, uint256 amountSD, uint16 chainId, uint256 dstPoolId, bytes to);
    event InstantRedeemLocal(address from, uint256 amountLP, uint256 amountSD, address to);
    event CreditChainPath(uint16 chainId, uint256 srcPoolId, uint256 amountSD, uint256 idealBalance);
    event SwapRemote(address to, uint256 amountSD, uint256 protocolFee, uint256 dstFee);
    event WithdrawRemote(uint16 srcChainId, uint256 srcPoolId, uint256 swapAmount, uint256 mintAmount);
    event ChainPathUpdate(uint16 dstChainId, uint256 dstPoolId, uint256 weight);
    event FeesUpdated(uint256 mintFeeBP);
    event FeeLibraryUpdated(address feeLibraryAddr);
    event StopSwapUpdated(bool swapStop);
    event WithdrawProtocolFeeBalance(address to, uint256 amountSD);
    event WithdrawMintFeeBalance(address to, uint256 amountSD);
    event DeltaParamUpdated(bool batched, uint256 swapDeltaBP, uint256 lpDeltaBP, bool defaultSwapMode, bool defaultLPMode);

    modifier onlyRouter() {

        require(msg.sender == router, "Stargate: only the router can call this method");
        _;
    }

    constructor(
        uint256 _poolId,
        address _router,
        address _token,
        uint256 _sharedDecimals,
        uint256 _localDecimals,
        address _feeLibrary,
        string memory _name,
        string memory _symbol
    ) LPTokenERC20(_name, _symbol) {
        require(_token != address(0x0), "Stargate: _token cannot be 0x0");
        require(_router != address(0x0), "Stargate: _router cannot be 0x0");
        poolId = _poolId;
        router = _router;
        token = _token;
        sharedDecimals = _sharedDecimals;
        decimals = uint8(_sharedDecimals);
        localDecimals = _localDecimals;
        convertRate = 10**(uint256(localDecimals).sub(sharedDecimals));
        totalWeight = 0;
        feeLibrary = _feeLibrary;

        batched = false;
        defaultSwapMode = true;
        defaultLPMode = true;
    }

    function getChainPathsLength() public view returns (uint256) {

        return chainPaths.length;
    }


    function mint(address _to, uint256 _amountLD) external nonReentrant onlyRouter returns (uint256) {

        return _mintLocal(_to, _amountLD, true, true);
    }

    function swap(
        uint16 _dstChainId,
        uint256 _dstPoolId,
        address _from,
        uint256 _amountLD,
        uint256 _minAmountLD,
        bool newLiquidity
    ) external nonReentrant onlyRouter returns (SwapObj memory) {

        require(!stopSwap, "Stargate: swap func stopped");
        ChainPath storage cp = getAndCheckCP(_dstChainId, _dstPoolId);
        require(cp.ready == true, "Stargate: counter chainPath is not ready");

        uint256 amountSD = amountLDtoSD(_amountLD);
        uint256 minAmountSD = amountLDtoSD(_minAmountLD);

        SwapObj memory s = IStargateFeeLibrary(feeLibrary).getFees(poolId, _dstPoolId, _dstChainId, _from, amountSD);

        eqFeePool = eqFeePool.sub(s.eqReward);
        s.amount = amountSD.sub(s.eqFee).sub(s.protocolFee).sub(s.lpFee);
        require(s.amount.add(s.eqReward) >= minAmountSD, "Stargate: slippage too high");


        s.lkbRemove = amountSD.sub(s.lpFee).add(s.eqReward);
        require(cp.balance >= s.lkbRemove, "Stargate: dst balance too low");
        cp.balance = cp.balance.sub(s.lkbRemove);

        if (newLiquidity) {
            deltaCredit = deltaCredit.add(amountSD).add(s.eqReward);
        } else if (s.eqReward > 0) {
            deltaCredit = deltaCredit.add(s.eqReward);
        }

        if (!batched || deltaCredit >= totalLiquidity.mul(swapDeltaBP).div(BP_DENOMINATOR)) {
            _delta(defaultSwapMode);
        }

        emit Swap(_dstChainId, _dstPoolId, _from, s.amount, s.eqReward, s.eqFee, s.protocolFee, s.lpFee);
        return s;
    }

    function sendCredits(uint16 _dstChainId, uint256 _dstPoolId) external nonReentrant onlyRouter returns (CreditObj memory c) {

        ChainPath storage cp = getAndCheckCP(_dstChainId, _dstPoolId);
        require(cp.ready == true, "Stargate: counter chainPath is not ready");
        cp.lkb = cp.lkb.add(cp.credits);
        c.idealBalance = totalLiquidity.mul(cp.weight).div(totalWeight);
        c.credits = cp.credits;
        cp.credits = 0;
        emit SendCredits(_dstChainId, _dstPoolId, c.credits, c.idealBalance);
    }

    function redeemRemote(
        uint16 _dstChainId,
        uint256 _dstPoolId,
        address _from,
        uint256 _amountLP
    ) external nonReentrant onlyRouter {

        require(_from != address(0x0), "Stargate: _from cannot be 0x0");
        uint256 amountSD = _burnLocal(_from, _amountLP);
        if (!batched || deltaCredit > totalLiquidity.mul(lpDeltaBP).div(BP_DENOMINATOR)) {
            _delta(defaultLPMode);
        }
        uint256 amountLD = amountSDtoLD(amountSD);
        emit RedeemRemote(_dstChainId, _dstPoolId, _from, _amountLP, amountLD);
    }

    function instantRedeemLocal(
        address _from,
        uint256 _amountLP,
        address _to
    ) external nonReentrant onlyRouter returns (uint256 amountSD) {

        require(_from != address(0x0), "Stargate: _from cannot be 0x0");
        uint256 _deltaCredit = deltaCredit; // sload optimization.
        uint256 _capAmountLP = _amountSDtoLP(_deltaCredit);

        if (_amountLP > _capAmountLP) _amountLP = _capAmountLP;

        amountSD = _burnLocal(_from, _amountLP);
        deltaCredit = _deltaCredit.sub(amountSD);
        uint256 amountLD = amountSDtoLD(amountSD);
        _safeTransfer(token, _to, amountLD);
        emit InstantRedeemLocal(_from, _amountLP, amountSD, _to);
    }

    function redeemLocal(
        address _from,
        uint256 _amountLP,
        uint16 _dstChainId,
        uint256 _dstPoolId,
        bytes calldata _to
    ) external nonReentrant onlyRouter returns (uint256 amountSD) {

        require(_from != address(0x0), "Stargate: _from cannot be 0x0");

        require(chainPaths[chainPathIndexLookup[_dstChainId][_dstPoolId]].ready == true, "Stargate: counter chainPath is not ready");
        amountSD = _burnLocal(_from, _amountLP);

        if (!batched || deltaCredit > totalLiquidity.mul(lpDeltaBP).div(BP_DENOMINATOR)) {
            _delta(false);
        }
        emit RedeemLocal(_from, _amountLP, amountSD, _dstChainId, _dstPoolId, _to);
    }


    function creditChainPath(
        uint16 _dstChainId,
        uint256 _dstPoolId,
        CreditObj memory _c
    ) external nonReentrant onlyRouter {

        ChainPath storage cp = chainPaths[chainPathIndexLookup[_dstChainId][_dstPoolId]];
        cp.balance = cp.balance.add(_c.credits);
        if (cp.idealBalance != _c.idealBalance) {
            cp.idealBalance = _c.idealBalance;
        }
        emit CreditChainPath(_dstChainId, _dstPoolId, _c.credits, _c.idealBalance);
    }

    function swapRemote(
        uint16 _srcChainId,
        uint256 _srcPoolId,
        address _to,
        SwapObj memory _s
    ) external nonReentrant onlyRouter returns (uint256 amountLD) {

        totalLiquidity = totalLiquidity.add(_s.lpFee);
        eqFeePool = eqFeePool.add(_s.eqFee);
        protocolFeeBalance = protocolFeeBalance.add(_s.protocolFee);

        uint256 chainPathIndex = chainPathIndexLookup[_srcChainId][_srcPoolId];
        chainPaths[chainPathIndex].lkb = chainPaths[chainPathIndex].lkb.sub(_s.lkbRemove);

        amountLD = amountSDtoLD(_s.amount.add(_s.eqReward));
        _safeTransfer(token, _to, amountLD);
        emit SwapRemote(_to, _s.amount.add(_s.eqReward), _s.protocolFee, _s.eqFee);
    }

    function redeemLocalCallback(
        uint16 _srcChainId,
        uint256 _srcPoolId,
        address _to,
        uint256 _amountSD,
        uint256 _amountToMintSD
    ) external nonReentrant onlyRouter {

        if (_amountToMintSD > 0) {
            _mintLocal(_to, amountSDtoLD(_amountToMintSD), false, false);
        }

        ChainPath storage cp = getAndCheckCP(_srcChainId, _srcPoolId);
        cp.lkb = cp.lkb.sub(_amountSD);

        uint256 amountLD = amountSDtoLD(_amountSD);
        _safeTransfer(token, _to, amountLD);
        emit RedeemLocalCallback(_to, _amountSD, _amountToMintSD);
    }

    function redeemLocalCheckOnRemote(
        uint16 _srcChainId,
        uint256 _srcPoolId,
        uint256 _amountSD
    ) external nonReentrant onlyRouter returns (uint256 swapAmount, uint256 mintAmount) {

        ChainPath storage cp = getAndCheckCP(_srcChainId, _srcPoolId);
        if (_amountSD > cp.balance) {
            mintAmount = _amountSD - cp.balance;
            swapAmount = cp.balance;
            cp.balance = 0;
        } else {
            cp.balance = cp.balance.sub(_amountSD);
            swapAmount = _amountSD;
            mintAmount = 0;
        }
        emit WithdrawRemote(_srcChainId, _srcPoolId, swapAmount, mintAmount);
    }

    function createChainPath(
        uint16 _dstChainId,
        uint256 _dstPoolId,
        uint256 _weight
    ) external onlyRouter {

        for (uint256 i = 0; i < chainPaths.length; ++i) {
            ChainPath memory cp = chainPaths[i];
            bool exists = cp.dstChainId == _dstChainId && cp.dstPoolId == _dstPoolId;
            require(!exists, "Stargate: cant createChainPath of existing dstChainId and _dstPoolId");
        }
        totalWeight = totalWeight.add(_weight);
        chainPathIndexLookup[_dstChainId][_dstPoolId] = chainPaths.length;
        chainPaths.push(ChainPath(false, _dstChainId, _dstPoolId, _weight, 0, 0, 0, 0));
        emit ChainPathUpdate(_dstChainId, _dstPoolId, _weight);
    }

    function setWeightForChainPath(
        uint16 _dstChainId,
        uint256 _dstPoolId,
        uint16 _weight
    ) external onlyRouter {

        ChainPath storage cp = getAndCheckCP(_dstChainId, _dstPoolId);
        totalWeight = totalWeight.sub(cp.weight).add(_weight);
        cp.weight = _weight;
        emit ChainPathUpdate(_dstChainId, _dstPoolId, _weight);
    }

    function setFee(uint256 _mintFeeBP) external onlyRouter {

        require(_mintFeeBP <= BP_DENOMINATOR, "Bridge: cum fees > 100%");
        mintFeeBP = _mintFeeBP;
        emit FeesUpdated(mintFeeBP);
    }

    function setFeeLibrary(address _feeLibraryAddr) external onlyRouter {

        require(_feeLibraryAddr != address(0x0), "Stargate: fee library cant be 0x0");
        feeLibrary = _feeLibraryAddr;
        emit FeeLibraryUpdated(_feeLibraryAddr);
    }

    function setSwapStop(bool _swapStop) external onlyRouter {

        stopSwap = _swapStop;
        emit StopSwapUpdated(_swapStop);
    }

    function setDeltaParam(
        bool _batched,
        uint256 _swapDeltaBP,
        uint256 _lpDeltaBP,
        bool _defaultSwapMode,
        bool _defaultLPMode
    ) external onlyRouter {

        require(_swapDeltaBP <= BP_DENOMINATOR && _lpDeltaBP <= BP_DENOMINATOR, "Stargate: wrong Delta param");
        batched = _batched;
        swapDeltaBP = _swapDeltaBP;
        lpDeltaBP = _lpDeltaBP;
        defaultSwapMode = _defaultSwapMode;
        defaultLPMode = _defaultLPMode;
        emit DeltaParamUpdated(_batched, _swapDeltaBP, _lpDeltaBP, _defaultSwapMode, _defaultLPMode);
    }

    function callDelta(bool _fullMode) external onlyRouter {

        _delta(_fullMode);
    }

    function activateChainPath(uint16 _dstChainId, uint256 _dstPoolId) external onlyRouter {

        ChainPath storage cp = getAndCheckCP(_dstChainId, _dstPoolId);
        require(cp.ready == false, "Stargate: chainPath is already active");
        cp.ready = true;
    }

    function withdrawProtocolFeeBalance(address _to) external onlyRouter {

        if (protocolFeeBalance > 0) {
            uint256 amountOfLD = amountSDtoLD(protocolFeeBalance);
            protocolFeeBalance = 0;
            _safeTransfer(token, _to, amountOfLD);
            emit WithdrawProtocolFeeBalance(_to, amountOfLD);
        }
    }

    function withdrawMintFeeBalance(address _to) external onlyRouter {

        if (mintFeeBalance > 0) {
            uint256 amountOfLD = amountSDtoLD(mintFeeBalance);
            mintFeeBalance = 0;
            _safeTransfer(token, _to, amountOfLD);
            emit WithdrawMintFeeBalance(_to, amountOfLD);
        }
    }

    function amountLPtoLD(uint256 _amountLP) external view returns (uint256) {

        return amountSDtoLD(_amountLPtoSD(_amountLP));
    }

    function _amountLPtoSD(uint256 _amountLP) internal view returns (uint256) {

        require(totalSupply > 0, "Stargate: cant convert LPtoSD when totalSupply == 0");
        return _amountLP.mul(totalLiquidity).div(totalSupply);
    }

    function _amountSDtoLP(uint256 _amountSD) internal view returns (uint256) {

        require(totalLiquidity > 0, "Stargate: cant convert SDtoLP when totalLiq == 0");
        return _amountSD.mul(totalSupply).div(totalLiquidity);
    }

    function amountSDtoLD(uint256 _amount) internal view returns (uint256) {

        return _amount.mul(convertRate);
    }

    function amountLDtoSD(uint256 _amount) internal view returns (uint256) {

        return _amount.div(convertRate);
    }

    function getAndCheckCP(uint16 _dstChainId, uint256 _dstPoolId) internal view returns (ChainPath storage) {

        require(chainPaths.length > 0, "Stargate: no chainpaths exist");
        ChainPath storage cp = chainPaths[chainPathIndexLookup[_dstChainId][_dstPoolId]];
        require(cp.dstChainId == _dstChainId && cp.dstPoolId == _dstPoolId, "Stargate: local chainPath does not exist");
        return cp;
    }

    function getChainPath(uint16 _dstChainId, uint256 _dstPoolId) external view returns (ChainPath memory) {

        ChainPath memory cp = chainPaths[chainPathIndexLookup[_dstChainId][_dstPoolId]];
        require(cp.dstChainId == _dstChainId && cp.dstPoolId == _dstPoolId, "Stargate: local chainPath does not exist");
        return cp;
    }

    function _burnLocal(address _from, uint256 _amountLP) internal returns (uint256) {

        require(totalSupply > 0, "Stargate: cant burn when totalSupply == 0");
        uint256 amountOfLPTokens = balanceOf[_from];
        require(amountOfLPTokens >= _amountLP, "Stargate: not enough LP tokens to burn");

        uint256 amountSD = _amountLP.mul(totalLiquidity).div(totalSupply);
        totalLiquidity = totalLiquidity.sub(amountSD);

        _burn(_from, _amountLP);
        emit Burn(_from, _amountLP, amountSD);
        return amountSD;
    }

    function _delta(bool fullMode) internal {

        if (deltaCredit > 0 && totalWeight > 0) {
            uint256 cpLength = chainPaths.length;
            uint256[] memory deficit = new uint256[](cpLength);
            uint256 totalDeficit = 0;

            for (uint256 i = 0; i < cpLength; ++i) {
                ChainPath storage cp = chainPaths[i];
                uint256 balLiq = totalLiquidity.mul(cp.weight).div(totalWeight);
                uint256 currLiq = cp.lkb.add(cp.credits);
                if (balLiq > currLiq) {
                    deficit[i] = balLiq - currLiq;
                    totalDeficit = totalDeficit.add(deficit[i]);
                }
            }

            uint256 spent;

            if (totalDeficit == 0) {
                if (fullMode && deltaCredit > 0) {
                    for (uint256 i = 0; i < cpLength; ++i) {
                        ChainPath storage cp = chainPaths[i];
                        uint256 amtToCredit = deltaCredit.mul(cp.weight).div(totalWeight);
                        spent = spent.add(amtToCredit);
                        cp.credits = cp.credits.add(amtToCredit);
                    }
                } // else do nth
            } else if (totalDeficit <= deltaCredit) {
                if (fullMode) {
                    uint256 excessCredit = deltaCredit - totalDeficit;
                    for (uint256 i = 0; i < cpLength; ++i) {
                        if (deficit[i] > 0) {
                            ChainPath storage cp = chainPaths[i];
                            uint256 amtToCredit = deficit[i].add(excessCredit.mul(cp.weight).div(totalWeight));
                            spent = spent.add(amtToCredit);
                            cp.credits = cp.credits.add(amtToCredit);
                        }
                    }
                } else {
                    for (uint256 i = 0; i < cpLength; ++i) {
                        if (deficit[i] > 0) {
                            ChainPath storage cp = chainPaths[i];
                            uint256 amtToCredit = deficit[i];
                            spent = spent.add(amtToCredit);
                            cp.credits = cp.credits.add(amtToCredit);
                        }
                    }
                }
            } else {
                for (uint256 i = 0; i < cpLength; ++i) {
                    if (deficit[i] > 0) {
                        ChainPath storage cp = chainPaths[i];
                        uint256 proportionalDeficit = deficit[i].mul(deltaCredit).div(totalDeficit);
                        spent = spent.add(proportionalDeficit);
                        cp.credits = cp.credits.add(proportionalDeficit);
                    }
                }
            }

            deltaCredit = deltaCredit.sub(spent);
        }
    }

    function _mintLocal(
        address _to,
        uint256 _amountLD,
        bool _feesEnabled,
        bool _creditDelta
    ) internal returns (uint256 amountSD) {

        require(totalWeight > 0, "Stargate: No ChainPaths exist");
        amountSD = amountLDtoSD(_amountLD);

        uint256 mintFeeSD = 0;
        if (_feesEnabled) {
            mintFeeSD = amountSD.mul(mintFeeBP).div(BP_DENOMINATOR);
            amountSD = amountSD.sub(mintFeeSD);
            mintFeeBalance = mintFeeBalance.add(mintFeeSD);
        }

        if (_creditDelta) {
            deltaCredit = deltaCredit.add(amountSD);
        }

        uint256 amountLPTokens = amountSD;
        if (totalSupply != 0) {
            amountLPTokens = amountSD.mul(totalSupply).div(totalLiquidity);
        }
        totalLiquidity = totalLiquidity.add(amountSD);

        _mint(_to, amountLPTokens);
        emit Mint(_to, amountLPTokens, amountSD, mintFeeSD);

        if (!batched || deltaCredit > totalLiquidity.mul(lpDeltaBP).div(BP_DENOMINATOR)) {
            _delta(defaultLPMode);
        }
    }

    function _safeTransfer(
        address _token,
        address _to,
        uint256 _value
    ) private {

        (bool success, bytes memory data) = _token.call(abi.encodeWithSelector(SELECTOR, _to, _value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "Stargate: TRANSFER_FAILED");
    }
}// BUSL-1.1

pragma solidity 0.7.6;


contract Factory is Ownable {

    using SafeMath for uint256;

    mapping(uint256 => Pool) public getPool; // poolId -> PoolInfo
    address[] public allPools;
    address public immutable router;
    address public defaultFeeLibrary; // address for retrieving fee params for swaps

    modifier onlyRouter() {

        require(msg.sender == router, "Stargate: caller must be Router.");
        _;
    }

    constructor(address _router) {
        require(_router != address(0x0), "Stargate: _router cant be 0x0"); // 1 time only
        router = _router;
    }

    function setDefaultFeeLibrary(address _defaultFeeLibrary) external onlyOwner {

        require(_defaultFeeLibrary != address(0x0), "Stargate: fee library cant be 0x0");
        defaultFeeLibrary = _defaultFeeLibrary;
    }

    function allPoolsLength() external view returns (uint256) {

        return allPools.length;
    }

    function createPool(
        uint256 _poolId,
        address _token,
        uint8 _sharedDecimals,
        uint8 _localDecimals,
        string memory _name,
        string memory _symbol
    ) public onlyRouter returns (address poolAddress) {

        require(address(getPool[_poolId]) == address(0x0), "Stargate: Pool already created");

        Pool pool = new Pool(_poolId, router, _token, _sharedDecimals, _localDecimals, defaultFeeLibrary, _name, _symbol);
        getPool[_poolId] = pool;
        poolAddress = address(pool);
        allPools.push(poolAddress);
    }

    function renounceOwnership() public override onlyOwner {}

}// MIT

pragma solidity ^0.7.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// BUSL-1.1

pragma solidity 0.7.6;

interface IStargateRouter {
    struct lzTxObj {
        uint256 dstGasForCall;
        uint256 dstNativeAmount;
        bytes dstNativeAddr;
    }

    function addLiquidity(
        uint256 _poolId,
        uint256 _amountLD,
        address _to
    ) external;

    function swap(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress,
        uint256 _amountLD,
        uint256 _minAmountLD,
        lzTxObj memory _lzTxParams,
        bytes calldata _to,
        bytes calldata _payload
    ) external payable;

    function redeemRemote(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress,
        uint256 _amountLP,
        uint256 _minAmountLD,
        bytes calldata _to,
        lzTxObj memory _lzTxParams
    ) external payable;

    function instantRedeemLocal(
        uint16 _srcPoolId,
        uint256 _amountLP,
        address _to
    ) external returns (uint256);

    function redeemLocal(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress,
        uint256 _amountLP,
        bytes calldata _to,
        lzTxObj memory _lzTxParams
    ) external payable;

    function sendCredits(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress
    ) external payable;

    function quoteLayerZeroFee(
        uint16 _dstChainId,
        uint8 _functionType,
        bytes calldata _toAddress,
        bytes calldata _transferAndCallPayload,
        lzTxObj memory _lzTxParams
    ) external view returns (uint256, uint256);
}// BUSL-1.1

pragma solidity 0.7.6;

interface IStargateReceiver {
    function sgReceive(
        uint16 _chainId,
        bytes memory _srcAddress,
        uint256 _nonce,
        address _token,
        uint256 amountLD,
        bytes memory payload
    ) external;
}// BUSL-1.1

pragma solidity 0.7.6;




contract Router is IStargateRouter, Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    uint8 internal constant TYPE_REDEEM_LOCAL_RESPONSE = 1;
    uint8 internal constant TYPE_REDEEM_LOCAL_CALLBACK_RETRY = 2;
    uint8 internal constant TYPE_SWAP_REMOTE_RETRY = 3;

    struct CachedSwap {
        address token;
        uint256 amountLD;
        address to;
        bytes payload;
    }

    Factory public factory; // used for creating pools
    address public protocolFeeOwner; // can call methods to pull Stargate fees collected in pools
    address public mintFeeOwner; // can call methods to pull mint fees collected in pools
    Bridge public bridge;
    mapping(uint16 => mapping(bytes => mapping(uint256 => bytes))) public revertLookup; //[chainId][srcAddress][nonce]
    mapping(uint16 => mapping(bytes => mapping(uint256 => CachedSwap))) public cachedSwapLookup; //[chainId][srcAddress][nonce]

    event Revert(uint8 bridgeFunctionType, uint16 chainId, bytes srcAddress, uint256 nonce);
    event CachedSwapSaved(uint16 chainId, bytes srcAddress, uint256 nonce, address token, uint256 amountLD, address to, bytes payload, bytes reason);
    event RevertRedeemLocal(uint16 srcChainId, uint256 _srcPoolId, uint256 _dstPoolId, bytes to, uint256 redeemAmountSD, uint256 mintAmountSD, uint256 indexed nonce, bytes indexed srcAddress);
    event RedeemLocalCallback(uint16 srcChainId, bytes indexed srcAddress, uint256 indexed nonce, uint256 srcPoolId, uint256 dstPoolId, address to, uint256 amountSD, uint256 mintAmountSD);

    modifier onlyBridge() {
        require(msg.sender == address(bridge), "Bridge: caller must be Bridge.");
        _;
    }

    constructor() {}

    function setBridgeAndFactory(Bridge _bridge, Factory _factory) external onlyOwner {
        require(address(bridge) == address(0x0) && address(factory) == address(0x0), "Stargate: bridge and factory already initialized"); // 1 time only
        require(address(_bridge) != address(0x0), "Stargate: bridge cant be 0x0");
        require(address(_factory) != address(0x0), "Stargate: factory cant be 0x0");

        bridge = _bridge;
        factory = _factory;
    }

    function _getPool(uint256 _poolId) internal view returns (Pool pool) {
        pool = factory.getPool(_poolId);
        require(address(pool) != address(0x0), "Stargate: Pool does not exist");
    }

    function _safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "Stargate: TRANSFER_FROM_FAILED");
    }

    function addLiquidity(
        uint256 _poolId,
        uint256 _amountLD,
        address _to
    ) external override nonReentrant {
        Pool pool = _getPool(_poolId);
        uint256 convertRate = pool.convertRate();
        _amountLD = _amountLD.div(convertRate).mul(convertRate);
        _safeTransferFrom(pool.token(), msg.sender, address(pool), _amountLD);
        pool.mint(_to, _amountLD);
    }

    function swap(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress,
        uint256 _amountLD,
        uint256 _minAmountLD,
        lzTxObj memory _lzTxParams,
        bytes calldata _to,
        bytes calldata _payload
    ) external payable override nonReentrant {
        require(_amountLD > 0, "Stargate: cannot swap 0");
        require(_refundAddress != address(0x0), "Stargate: _refundAddress cannot be 0x0");
        Pool.SwapObj memory s;
        Pool.CreditObj memory c;
        {
            Pool pool = _getPool(_srcPoolId);
            {
                uint256 convertRate = pool.convertRate();
                _amountLD = _amountLD.div(convertRate).mul(convertRate);
            }

            s = pool.swap(_dstChainId, _dstPoolId, msg.sender, _amountLD, _minAmountLD, true);
            _safeTransferFrom(pool.token(), msg.sender, address(pool), _amountLD);
            c = pool.sendCredits(_dstChainId, _dstPoolId);
        }
        bridge.swap{value: msg.value}(_dstChainId, _srcPoolId, _dstPoolId, _refundAddress, c, s, _lzTxParams, _to, _payload);
    }

    function redeemRemote(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress,
        uint256 _amountLP,
        uint256 _minAmountLD,
        bytes calldata _to,
        lzTxObj memory _lzTxParams
    ) external payable override nonReentrant {
        require(_refundAddress != address(0x0), "Stargate: _refundAddress cannot be 0x0");
        require(_amountLP > 0, "Stargate: not enough lp to redeemRemote");
        Pool.SwapObj memory s;
        Pool.CreditObj memory c;
        {
            Pool pool = _getPool(_srcPoolId);
            uint256 amountLD = pool.amountLPtoLD(_amountLP);
            s = pool.swap(_dstChainId, _dstPoolId, msg.sender, amountLD, _minAmountLD, false);
            pool.redeemRemote(_dstChainId, _dstPoolId, msg.sender, _amountLP);
            c = pool.sendCredits(_dstChainId, _dstPoolId);
        }
        bridge.swap{value: msg.value}(_dstChainId, _srcPoolId, _dstPoolId, _refundAddress, c, s, _lzTxParams, _to, "");
    }

    function instantRedeemLocal(
        uint16 _srcPoolId,
        uint256 _amountLP,
        address _to
    ) external override nonReentrant returns (uint256 amountSD) {
        require(_amountLP > 0, "Stargate: not enough lp to redeem");
        Pool pool = _getPool(_srcPoolId);
        amountSD = pool.instantRedeemLocal(msg.sender, _amountLP, _to);
    }

    function redeemLocal(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress,
        uint256 _amountLP,
        bytes calldata _to,
        lzTxObj memory _lzTxParams
    ) external payable override nonReentrant {
        require(_refundAddress != address(0x0), "Stargate: _refundAddress cannot be 0x0");
        Pool pool = _getPool(_srcPoolId);
        require(_amountLP > 0, "Stargate: not enough lp to redeem");
        uint256 amountSD = pool.redeemLocal(msg.sender, _amountLP, _dstChainId, _dstPoolId, _to);
        require(amountSD > 0, "Stargate: not enough lp to redeem with amountSD");

        Pool.CreditObj memory c = pool.sendCredits(_dstChainId, _dstPoolId);
        bridge.redeemLocal{value: msg.value}(_dstChainId, _srcPoolId, _dstPoolId, _refundAddress, c, amountSD, _to, _lzTxParams);
    }

    function sendCredits(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress
    ) external payable override nonReentrant {
        require(_refundAddress != address(0x0), "Stargate: _refundAddress cannot be 0x0");
        Pool pool = _getPool(_srcPoolId);
        Pool.CreditObj memory c = pool.sendCredits(_dstChainId, _dstPoolId);
        bridge.sendCredits{value: msg.value}(_dstChainId, _srcPoolId, _dstPoolId, _refundAddress, c);
    }

    function quoteLayerZeroFee(
        uint16 _dstChainId,
        uint8 _functionType,
        bytes calldata _toAddress,
        bytes calldata _transferAndCallPayload,
        Router.lzTxObj memory _lzTxParams
    ) external view override returns (uint256, uint256) {
        return bridge.quoteLayerZeroFee(_dstChainId, _functionType, _toAddress, _transferAndCallPayload, _lzTxParams);
    }

    function revertRedeemLocal(
        uint16 _dstChainId,
        bytes calldata _srcAddress,
        uint256 _nonce,
        address payable _refundAddress,
        lzTxObj memory _lzTxParams
    ) external payable {
        require(_refundAddress != address(0x0), "Stargate: _refundAddress cannot be 0x0");
        bytes memory payload = revertLookup[_dstChainId][_srcAddress][_nonce];
        require(payload.length > 0, "Stargate: no retry revert");
        {
            uint8 functionType;
            assembly {
                functionType := mload(add(payload, 32))
            }
            require(functionType == TYPE_REDEEM_LOCAL_RESPONSE, "Stargate: invalid function type");
        }

        revertLookup[_dstChainId][_srcAddress][_nonce] = "";

        uint256 srcPoolId;
        uint256 dstPoolId;
        assembly {
            srcPoolId := mload(add(payload, 64))
            dstPoolId := mload(add(payload, 96))
        }

        Pool.CreditObj memory c;
        {
            Pool pool = _getPool(dstPoolId);
            c = pool.sendCredits(_dstChainId, srcPoolId);
        }

        bridge.redeemLocalCallback{value: msg.value}(_dstChainId, _refundAddress, c, _lzTxParams, payload);
    }

    function retryRevert(
        uint16 _srcChainId,
        bytes calldata _srcAddress,
        uint256 _nonce
    ) external payable {
        bytes memory payload = revertLookup[_srcChainId][_srcAddress][_nonce];
        require(payload.length > 0, "Stargate: no retry revert");

        revertLookup[_srcChainId][_srcAddress][_nonce] = "";

        uint8 functionType;
        assembly {
            functionType := mload(add(payload, 32))
        }

        if (functionType == TYPE_REDEEM_LOCAL_CALLBACK_RETRY) {
            (, uint256 srcPoolId, uint256 dstPoolId, address to, uint256 amountSD, uint256 mintAmountSD) = abi.decode(
                payload,
                (uint8, uint256, uint256, address, uint256, uint256)
            );
            _redeemLocalCallback(_srcChainId, _srcAddress, _nonce, srcPoolId, dstPoolId, to, amountSD, mintAmountSD);
        }
        else if (functionType == TYPE_SWAP_REMOTE_RETRY) {
            (, uint256 srcPoolId, uint256 dstPoolId, uint256 dstGasForCall, address to, Pool.SwapObj memory s, bytes memory p) = abi.decode(
                payload,
                (uint8, uint256, uint256, uint256, address, Pool.SwapObj, bytes)
            );
            _swapRemote(_srcChainId, _srcAddress, _nonce, srcPoolId, dstPoolId, dstGasForCall, to, s, p);
        } else {
            revert("Stargate: invalid function type");
        }
    }

    function clearCachedSwap(
        uint16 _srcChainId,
        bytes calldata _srcAddress,
        uint256 _nonce
    ) external {
        CachedSwap memory cs = cachedSwapLookup[_srcChainId][_srcAddress][_nonce];
        require(cs.to != address(0x0), "Stargate: cache already cleared");
        cachedSwapLookup[_srcChainId][_srcAddress][_nonce] = CachedSwap(address(0x0), 0, address(0x0), "");
        IStargateReceiver(cs.to).sgReceive(_srcChainId, _srcAddress, _nonce, cs.token, cs.amountLD, cs.payload);
    }

    function creditChainPath(
        uint16 _dstChainId,
        uint256 _dstPoolId,
        uint256 _srcPoolId,
        Pool.CreditObj memory _c
    ) external onlyBridge {
        Pool pool = _getPool(_srcPoolId);
        pool.creditChainPath(_dstChainId, _dstPoolId, _c);
    }

    function redeemLocalCheckOnRemote(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint256 _nonce,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        uint256 _amountSD,
        bytes calldata _to
    ) external onlyBridge {
        Pool pool = _getPool(_dstPoolId);
        try pool.redeemLocalCheckOnRemote(_srcChainId, _srcPoolId, _amountSD) returns (uint256 redeemAmountSD, uint256 mintAmountSD) {
            revertLookup[_srcChainId][_srcAddress][_nonce] = abi.encode(
                TYPE_REDEEM_LOCAL_RESPONSE,
                _srcPoolId,
                _dstPoolId,
                redeemAmountSD,
                mintAmountSD,
                _to
            );
            emit RevertRedeemLocal(_srcChainId, _srcPoolId, _dstPoolId, _to, redeemAmountSD, mintAmountSD, _nonce, _srcAddress);
        } catch {
            revertLookup[_srcChainId][_srcAddress][_nonce] = abi.encode(TYPE_REDEEM_LOCAL_RESPONSE, _srcPoolId, _dstPoolId, 0, _amountSD, _to);
            emit Revert(TYPE_REDEEM_LOCAL_RESPONSE, _srcChainId, _srcAddress, _nonce);
        }
    }

    function redeemLocalCallback(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint256 _nonce,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address _to,
        uint256 _amountSD,
        uint256 _mintAmountSD
    ) external onlyBridge {
        _redeemLocalCallback(_srcChainId, _srcAddress, _nonce, _srcPoolId, _dstPoolId, _to, _amountSD, _mintAmountSD);
    }

    function _redeemLocalCallback(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint256 _nonce,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address _to,
        uint256 _amountSD,
        uint256 _mintAmountSD
    ) internal {
        Pool pool = _getPool(_dstPoolId);
        try pool.redeemLocalCallback(_srcChainId, _srcPoolId, _to, _amountSD, _mintAmountSD) {} catch {
            revertLookup[_srcChainId][_srcAddress][_nonce] = abi.encode(
                TYPE_REDEEM_LOCAL_CALLBACK_RETRY,
                _srcPoolId,
                _dstPoolId,
                _to,
                _amountSD,
                _mintAmountSD
            );
            emit Revert(TYPE_REDEEM_LOCAL_CALLBACK_RETRY, _srcChainId, _srcAddress, _nonce);
        }
        emit RedeemLocalCallback(_srcChainId, _srcAddress, _nonce, _srcPoolId, _dstPoolId, _to, _amountSD, _mintAmountSD);
    }

    function swapRemote(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint256 _nonce,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        uint256 _dstGasForCall,
        address _to,
        Pool.SwapObj memory _s,
        bytes memory _payload
    ) external onlyBridge {
        _swapRemote(_srcChainId, _srcAddress, _nonce, _srcPoolId, _dstPoolId, _dstGasForCall, _to, _s, _payload);
    }

    function _swapRemote(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint256 _nonce,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        uint256 _dstGasForCall,
        address _to,
        Pool.SwapObj memory _s,
        bytes memory _payload
    ) internal {
        Pool pool = _getPool(_dstPoolId);
        try pool.swapRemote(_srcChainId, _srcPoolId, _to, _s) returns (uint256 amountLD) {
            if (_payload.length > 0) {
                try IStargateReceiver(_to).sgReceive{gas: _dstGasForCall}(_srcChainId, _srcAddress, _nonce, pool.token(), amountLD, _payload) {
                } catch (bytes memory reason) {
                    cachedSwapLookup[_srcChainId][_srcAddress][_nonce] = CachedSwap(pool.token(), amountLD, _to, _payload);
                    emit CachedSwapSaved(_srcChainId, _srcAddress, _nonce, pool.token(), amountLD, _to, _payload, reason);
                }
            }
        } catch {
            revertLookup[_srcChainId][_srcAddress][_nonce] = abi.encode(
                TYPE_SWAP_REMOTE_RETRY,
                _srcPoolId,
                _dstPoolId,
                _dstGasForCall,
                _to,
                _s,
                _payload
            );
            emit Revert(TYPE_SWAP_REMOTE_RETRY, _srcChainId, _srcAddress, _nonce);
        }
    }

    function createPool(
        uint256 _poolId,
        address _token,
        uint8 _sharedDecimals,
        uint8 _localDecimals,
        string memory _name,
        string memory _symbol
    ) external onlyOwner returns (address) {
        require(_token != address(0x0), "Stargate: _token cannot be 0x0");
        return factory.createPool(_poolId, _token, _sharedDecimals, _localDecimals, _name, _symbol);
    }

    function createChainPath(
        uint256 _poolId,
        uint16 _dstChainId,
        uint256 _dstPoolId,
        uint256 _weight
    ) external onlyOwner {
        Pool pool = _getPool(_poolId);
        pool.createChainPath(_dstChainId, _dstPoolId, _weight);
    }

    function activateChainPath(
        uint256 _poolId,
        uint16 _dstChainId,
        uint256 _dstPoolId
    ) external onlyOwner {
        Pool pool = _getPool(_poolId);
        pool.activateChainPath(_dstChainId, _dstPoolId);
    }

    function setWeightForChainPath(
        uint256 _poolId,
        uint16 _dstChainId,
        uint256 _dstPoolId,
        uint16 _weight
    ) external onlyOwner {
        Pool pool = _getPool(_poolId);
        pool.setWeightForChainPath(_dstChainId, _dstPoolId, _weight);
    }

    function setProtocolFeeOwner(address _owner) external onlyOwner {
        require(_owner != address(0x0), "Stargate: _owner cannot be 0x0");
        protocolFeeOwner = _owner;
    }

    function setMintFeeOwner(address _owner) external onlyOwner {
        require(_owner != address(0x0), "Stargate: _owner cannot be 0x0");
        mintFeeOwner = _owner;
    }

    function setFees(uint256 _poolId, uint256 _mintFeeBP) external onlyOwner {
        Pool pool = _getPool(_poolId);
        pool.setFee(_mintFeeBP);
    }

    function setFeeLibrary(uint256 _poolId, address _feeLibraryAddr) external onlyOwner {
        Pool pool = _getPool(_poolId);
        pool.setFeeLibrary(_feeLibraryAddr);
    }

    function setSwapStop(uint256 _poolId, bool _swapStop) external onlyOwner {
        Pool pool = _getPool(_poolId);
        pool.setSwapStop(_swapStop);
    }

    function setDeltaParam(
        uint256 _poolId,
        bool _batched,
        uint256 _swapDeltaBP,
        uint256 _lpDeltaBP,
        bool _defaultSwapMode,
        bool _defaultLPMode
    ) external onlyOwner {
        Pool pool = _getPool(_poolId);
        pool.setDeltaParam(_batched, _swapDeltaBP, _lpDeltaBP, _defaultSwapMode, _defaultLPMode);
    }

    function callDelta(uint256 _poolId, bool _fullMode) external {
        Pool pool = _getPool(_poolId);
        pool.callDelta(_fullMode);
    }

    function withdrawMintFee(uint256 _poolId, address _to) external {
        require(mintFeeOwner == msg.sender, "Stargate: only mintFeeOwner");
        Pool pool = _getPool(_poolId);
        pool.withdrawMintFeeBalance(_to);
    }

    function withdrawProtocolFee(uint256 _poolId, address _to) external {
        require(protocolFeeOwner == msg.sender, "Stargate: only protocolFeeOwner");
        Pool pool = _getPool(_poolId);
        pool.withdrawProtocolFeeBalance(_to);
    }
}// BUSL-1.1

pragma solidity >=0.5.0;

interface ILayerZeroReceiver {
    function lzReceive(uint16 _srcChainId, bytes calldata _srcAddress, uint64 _nonce, bytes calldata _payload) external;
}// BUSL-1.1

pragma solidity >=0.5.0;

interface ILayerZeroUserApplicationConfig {
    function setConfig(uint16 _version, uint16 _chainId, uint _configType, bytes calldata _config) external;

    function setSendVersion(uint16 _version) external;

    function setReceiveVersion(uint16 _version) external;

    function forceResumeReceive(uint16 _srcChainId, bytes calldata _srcAddress) external;
}// BUSL-1.1

pragma solidity >=0.5.0;


interface ILayerZeroEndpoint is ILayerZeroUserApplicationConfig {
    function send(uint16 _dstChainId, bytes calldata _destination, bytes calldata _payload, address payable _refundAddress, address _zroPaymentAddress, bytes calldata _adapterParams) external payable;

    function receivePayload(uint16 _srcChainId, bytes calldata _srcAddress, address _dstAddress, uint64 _nonce, uint _gasLimit, bytes calldata _payload) external;

    function getInboundNonce(uint16 _srcChainId, bytes calldata _srcAddress) external view returns (uint64);

    function getOutboundNonce(uint16 _dstChainId, address _srcAddress) external view returns (uint64);

    function estimateFees(uint16 _dstChainId, address _userApplication, bytes calldata _payload, bool _payInZRO, bytes calldata _adapterParam) external view returns (uint nativeFee, uint zroFee);

    function getChainId() external view returns (uint16);

    function retryPayload(uint16 _srcChainId, bytes calldata _srcAddress, bytes calldata _payload) external;

    function hasStoredPayload(uint16 _srcChainId, bytes calldata _srcAddress) external view returns (bool);

    function getSendLibraryAddress(address _userApplication) external view returns (address);

    function getReceiveLibraryAddress(address _userApplication) external view returns (address);

    function isSendingPayload() external view returns (bool);

    function isReceivingPayload() external view returns (bool);

    function getConfig(uint16 _version, uint16 _chainId, address _userApplication, uint _configType) external view returns (bytes memory);

    function getSendVersion(address _userApplication) external view returns (uint16);

    function getReceiveVersion(address _userApplication) external view returns (uint16);
}// BUSL-1.1

pragma solidity 0.7.6;




contract Bridge is Ownable, ILayerZeroReceiver, ILayerZeroUserApplicationConfig {
    using SafeMath for uint256;

    uint8 internal constant TYPE_SWAP_REMOTE = 1;
    uint8 internal constant TYPE_ADD_LIQUIDITY = 2;
    uint8 internal constant TYPE_REDEEM_LOCAL_CALL_BACK = 3;
    uint8 internal constant TYPE_WITHDRAW_REMOTE = 4;

    ILayerZeroEndpoint public immutable layerZeroEndpoint;
    mapping(uint16 => bytes) public bridgeLookup;
    mapping(uint16 => mapping(uint8 => uint256)) public gasLookup;
    Router public immutable router;
    bool public useLayerZeroToken;

    event SendMsg(uint8 msgType, uint64 nonce);

    modifier onlyRouter() {
        require(msg.sender == address(router), "Stargate: caller must be Router.");
        _;
    }

    constructor(address _layerZeroEndpoint, address _router) {
        require(_layerZeroEndpoint != address(0x0), "Stargate: _layerZeroEndpoint cannot be 0x0");
        require(_router != address(0x0), "Stargate: _router cannot be 0x0");
        layerZeroEndpoint = ILayerZeroEndpoint(_layerZeroEndpoint);
        router = Router(_router);
    }


    function lzReceive(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint64 _nonce,
        bytes memory _payload
    ) external override {
        require(msg.sender == address(layerZeroEndpoint), "Stargate: only LayerZero endpoint can call lzReceive");
        require(
            _srcAddress.length == bridgeLookup[_srcChainId].length && keccak256(_srcAddress) == keccak256(bridgeLookup[_srcChainId]),
            "Stargate: bridge does not match"
        );

        uint8 functionType;
        assembly {
            functionType := mload(add(_payload, 32))
        }

        if (functionType == TYPE_SWAP_REMOTE) {
            (
                ,
                uint256 srcPoolId,
                uint256 dstPoolId,
                uint256 dstGasForCall,
                Pool.CreditObj memory c,
                Pool.SwapObj memory s,
                bytes memory to,
                bytes memory payload
            ) = abi.decode(_payload, (uint8, uint256, uint256, uint256, Pool.CreditObj, Pool.SwapObj, bytes, bytes));
            address toAddress;
            assembly {
                toAddress := mload(add(to, 20))
            }
            router.creditChainPath(_srcChainId, srcPoolId, dstPoolId, c);
            router.swapRemote(_srcChainId, _srcAddress, _nonce, srcPoolId, dstPoolId, dstGasForCall, toAddress, s, payload);
        } else if (functionType == TYPE_ADD_LIQUIDITY) {
            (, uint256 srcPoolId, uint256 dstPoolId, Pool.CreditObj memory c) = abi.decode(_payload, (uint8, uint256, uint256, Pool.CreditObj));
            router.creditChainPath(_srcChainId, srcPoolId, dstPoolId, c);
        } else if (functionType == TYPE_REDEEM_LOCAL_CALL_BACK) {
            (, uint256 srcPoolId, uint256 dstPoolId, Pool.CreditObj memory c, uint256 amountSD, uint256 mintAmountSD, bytes memory to) = abi
                .decode(_payload, (uint8, uint256, uint256, Pool.CreditObj, uint256, uint256, bytes));
            address toAddress;
            assembly {
                toAddress := mload(add(to, 20))
            }
            router.creditChainPath(_srcChainId, srcPoolId, dstPoolId, c);
            router.redeemLocalCallback(_srcChainId, _srcAddress, _nonce, srcPoolId, dstPoolId, toAddress, amountSD, mintAmountSD);
        } else if (functionType == TYPE_WITHDRAW_REMOTE) {
            (, uint256 srcPoolId, uint256 dstPoolId, Pool.CreditObj memory c, uint256 amountSD, bytes memory to) = abi.decode(
                _payload,
                (uint8, uint256, uint256, Pool.CreditObj, uint256, bytes)
            );
            router.creditChainPath(_srcChainId, srcPoolId, dstPoolId, c);
            router.redeemLocalCheckOnRemote(_srcChainId, _srcAddress, _nonce, srcPoolId, dstPoolId, amountSD, to);
        }
    }

    function swap(
        uint16 _chainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress,
        Pool.CreditObj memory _c,
        Pool.SwapObj memory _s,
        IStargateRouter.lzTxObj memory _lzTxParams,
        bytes calldata _to,
        bytes calldata _payload
    ) external payable onlyRouter {
        bytes memory payload = abi.encode(TYPE_SWAP_REMOTE, _srcPoolId, _dstPoolId, _lzTxParams.dstGasForCall, _c, _s, _to, _payload);
        _call(_chainId, TYPE_SWAP_REMOTE, _refundAddress, _lzTxParams, payload);
    }

    function redeemLocalCallback(
        uint16 _chainId,
        address payable _refundAddress,
        Pool.CreditObj memory _c,
        IStargateRouter.lzTxObj memory _lzTxParams,
        bytes memory _payload
    ) external payable onlyRouter {
        bytes memory payload;

        {
            (, uint256 srcPoolId, uint256 dstPoolId, uint256 amountSD, uint256 mintAmountSD, bytes memory to) = abi.decode(
                _payload,
                (uint8, uint256, uint256, uint256, uint256, bytes)
            );

            payload = abi.encode(TYPE_REDEEM_LOCAL_CALL_BACK, dstPoolId, srcPoolId, _c, amountSD, mintAmountSD, to);
        }

        _call(_chainId, TYPE_REDEEM_LOCAL_CALL_BACK, _refundAddress, _lzTxParams, payload);
    }

    function redeemLocal(
        uint16 _chainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress,
        Pool.CreditObj memory _c,
        uint256 _amountSD,
        bytes calldata _to,
        IStargateRouter.lzTxObj memory _lzTxParams
    ) external payable onlyRouter {
        bytes memory payload = abi.encode(TYPE_WITHDRAW_REMOTE, _srcPoolId, _dstPoolId, _c, _amountSD, _to);
        _call(_chainId, TYPE_WITHDRAW_REMOTE, _refundAddress, _lzTxParams, payload);
    }

    function sendCredits(
        uint16 _chainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress,
        Pool.CreditObj memory _c
    ) external payable onlyRouter {
        bytes memory payload = abi.encode(TYPE_ADD_LIQUIDITY, _srcPoolId, _dstPoolId, _c);
        IStargateRouter.lzTxObj memory lzTxObj = IStargateRouter.lzTxObj(0, 0, "0x");
        _call(_chainId, TYPE_ADD_LIQUIDITY, _refundAddress, lzTxObj, payload);
    }

    function quoteLayerZeroFee(
        uint16 _chainId,
        uint8 _functionType,
        bytes calldata _toAddress,
        bytes calldata _transferAndCallPayload,
        IStargateRouter.lzTxObj memory _lzTxParams
    ) external view returns (uint256, uint256) {
        bytes memory payload = "";
        Pool.CreditObj memory c = Pool.CreditObj(1, 1);
        if (_functionType == TYPE_SWAP_REMOTE) {
            Pool.SwapObj memory s = Pool.SwapObj(1, 1, 1, 1, 1, 1);
            payload = abi.encode(TYPE_SWAP_REMOTE, 0, 0, 0, c, s, _toAddress, _transferAndCallPayload);
        } else if (_functionType == TYPE_ADD_LIQUIDITY) {
            payload = abi.encode(TYPE_ADD_LIQUIDITY, 0, 0, c);
        } else if (_functionType == TYPE_REDEEM_LOCAL_CALL_BACK) {
            payload = abi.encode(TYPE_REDEEM_LOCAL_CALL_BACK, 0, 0, c, 0, 0, _toAddress);
        } else if (_functionType == TYPE_WITHDRAW_REMOTE) {
            payload = abi.encode(TYPE_WITHDRAW_REMOTE, 0, 0, c, 0, _toAddress);
        } else {
            revert("Stargate: unsupported function type");
        }

        bytes memory lzTxParamBuilt = _txParamBuilder(_chainId, _functionType, _lzTxParams);
        return layerZeroEndpoint.estimateFees(_chainId, address(this), payload, useLayerZeroToken, lzTxParamBuilt);
    }

    function setBridge(uint16 _chainId, bytes calldata _bridgeAddress) external onlyOwner {
        require(bridgeLookup[_chainId].length == 0, "Stargate: Bridge already set!");
        bridgeLookup[_chainId] = _bridgeAddress;
    }

    function setGasAmount(
        uint16 _chainId,
        uint8 _functionType,
        uint256 _gasAmount
    ) external onlyOwner {
        require(_functionType >= 1 && _functionType <= 4, "Stargate: invalid _functionType");
        gasLookup[_chainId][_functionType] = _gasAmount;
    }

    function approveTokenSpender(
        address token,
        address spender,
        uint256 amount
    ) external onlyOwner {
        IERC20(token).approve(spender, amount);
    }

    function setUseLayerZeroToken(bool enable) external onlyOwner {
        useLayerZeroToken = enable;
    }

    function forceResumeReceive(uint16 _srcChainId, bytes calldata _srcAddress) external override onlyOwner {
        layerZeroEndpoint.forceResumeReceive(_srcChainId, _srcAddress);
    }

    function setConfig(
        uint16 _version,
        uint16 _chainId,
        uint256 _configType,
        bytes calldata _config
    ) external override onlyOwner {
        layerZeroEndpoint.setConfig(_version, _chainId, _configType, _config);
    }

    function setSendVersion(uint16 version) external override onlyOwner {
        layerZeroEndpoint.setSendVersion(version);
    }

    function setReceiveVersion(uint16 version) external override onlyOwner {
        layerZeroEndpoint.setReceiveVersion(version);
    }

    function txParamBuilderType1(uint256 _gasAmount) internal pure returns (bytes memory) {
        uint16 txType = 1;
        return abi.encodePacked(txType, _gasAmount);
    }

    function txParamBuilderType2(
        uint256 _gasAmount,
        uint256 _dstNativeAmount,
        bytes memory _dstNativeAddr
    ) internal pure returns (bytes memory) {
        uint16 txType = 2;
        return abi.encodePacked(txType, _gasAmount, _dstNativeAmount, _dstNativeAddr);
    }

    function _txParamBuilder(
        uint16 _chainId,
        uint8 _type,
        IStargateRouter.lzTxObj memory _lzTxParams
    ) internal view returns (bytes memory) {
        bytes memory lzTxParam;
        address dstNativeAddr;
        {
            bytes memory dstNativeAddrBytes = _lzTxParams.dstNativeAddr;
            assembly {
                dstNativeAddr := mload(add(dstNativeAddrBytes, 20))
            }
        }

        uint256 totalGas = gasLookup[_chainId][_type].add(_lzTxParams.dstGasForCall);
        if (_lzTxParams.dstNativeAmount > 0 && dstNativeAddr != address(0x0)) {
            lzTxParam = txParamBuilderType2(totalGas, _lzTxParams.dstNativeAmount, _lzTxParams.dstNativeAddr);
        } else {
            lzTxParam = txParamBuilderType1(totalGas);
        }

        return lzTxParam;
    }

    function _call(
        uint16 _chainId,
        uint8 _type,
        address payable _refundAddress,
        IStargateRouter.lzTxObj memory _lzTxParams,
        bytes memory _payload
    ) internal {
        bytes memory lzTxParamBuilt = _txParamBuilder(_chainId, _type, _lzTxParams);
        uint64 nextNonce = layerZeroEndpoint.getOutboundNonce(_chainId, address(this)) + 1;
        layerZeroEndpoint.send{value: msg.value}(_chainId, bridgeLookup[_chainId], _payload, _refundAddress, address(this), lzTxParamBuilt);
        emit SendMsg(_type, nextNonce);
    }

    function renounceOwnership() public override onlyOwner {}
}