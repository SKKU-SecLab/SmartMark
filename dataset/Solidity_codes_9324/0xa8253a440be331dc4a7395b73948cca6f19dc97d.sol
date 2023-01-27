
pragma solidity >0.4.13 >=0.4.23 >=0.5.0 <0.6.0 >=0.5.6 <0.6.0 >=0.5.12 <0.6.0 >=0.5.15 <0.6.0;


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




/* pragma solidity >0.4.13; */

contract LoihiMath {


    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x, "loihi-math-add-overflow");
    }

    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x, "loihi-math-sub-underflow");
    }

    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, "loihi-math-mul-overflow");
    }

    uint constant OCTOPUS = 10 ** 18;

    function omul(uint x, uint y) internal pure returns (uint z) {

        z = ((x*y) + (OCTOPUS/2)) / OCTOPUS;
    }

    function odiv(uint x, uint y) internal pure returns (uint z) {

        z = ((x*OCTOPUS) + (y/2)) / y;
    }

    function somul(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, y), OCTOPUS / 2) / OCTOPUS;
    }

    function sodiv(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, OCTOPUS), y / 2) / y;
    }

}


interface IAToken {


    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function redirectInterestStream(address _to) external;

    function redirectInterestStreamOf(address _from, address _to) external;

    function allowInterestRedirectionTo(address _to) external;

    function redeem(uint256 _amount) external;

    function balanceOf(address _user) external view returns(uint256);

    function principalBalanceOf(address _user) external view returns(uint256);

    function totalSupply() external view returns(uint256);

    function isTransferAllowed(address _user, uint256 _amount) external view returns (bool);

    function getUserIndex(address _user) external view returns(uint256);

    function getInterestRedirectionAddress(address _user) external view returns(address);

    function getRedirectedBalance(address _user) external view returns(uint256);

    function decimals () external view returns (uint256);
    function deposit(uint256 _amount) external;


}

interface ICToken {

    function mint(uint mintAmount) external returns (uint);

    function redeem(uint redeemTokens) external returns (uint);

    function redeemUnderlying(uint redeemAmount) external returns (uint);

    function borrow(uint borrowAmount) external returns (uint);

    function repayBorrow(uint repayAmount) external returns (uint);

    function repayBorrowBehalf(address borrower, uint repayAmount) external returns (uint);

    function getCash() external view returns (uint);

    function exchangeRateCurrent() external returns (uint);

    function exchangeRateStored() external view returns (uint);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function balanceOfUnderlying(address account) external returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address minter, uint mintAmount, uint mintTokens);
    event AccrueInterest(uint cashPrior, uint interestAccumulated, uint borrowIndex, uint totalBorrows);
    event Borrow(address borrower, uint borrowAmount, uint accountBorrows, uint totalBorrows);
    event Redeem(address redeemer, uint redeemAmount, uint redeemTokens);


}

interface IChai {

    function draw(address src, uint wad) external;

    function exit(address src, uint wad) external;

    function join(address dst, uint wad) external;

    function dai(address usr) external returns (uint wad);

    function permit(address holder, address spender, uint256 nonce, uint256 expiry, bool allowed, uint8 v, bytes32 r, bytes32 s) external;

    function approve(address usr, uint wad) external returns (bool);

    function move(address src, address dst, uint wad) external returns (bool);

    function transfer(address dst, uint wad) external returns (bool);

    function transferFrom(address src, address dst, uint wad) external;

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

}

interface IPot {

    function rho () external returns (uint256);
    function drip () external returns (uint256);
    function chi () external view returns (uint256);
}






contract LoihiRoot is LoihiMath {


    string  public constant name = "Shells";
    string  public constant symbol = "SHL";
    uint8   public constant decimals = 18;

    mapping (address => uint256) internal balances;
    mapping (address => mapping (address => uint256)) internal allowances;
    uint256 public totalSupply;

    struct Flavor { address adapter; address reserve; }
    mapping(address => Flavor) public flavors;

    address[] public reserves;
    address[] public numeraires;
    uint256[] public weights;

    address public owner;
    bool internal notEntered = true;
    bool public frozen = false;

    uint256 public alpha;
    uint256 public beta;
    uint256 public delta;
    uint256 public epsilon;
    uint256 public lambda;
    uint256 internal omega;

    bytes4 constant internal ERC20ID = 0x36372b07;
    bytes4 constant internal ERC165ID = 0x01ffc9a7;

    address constant exchange = 0x57dEC9594D519c4D7eD9Db1Ed8794E7d938A62d3;
    address constant liquidity = 0xA3f4A860eFa4a60279E6E50f2169FDD080aAb655;
    address constant views = 0x81dBd2ec823cB2691f34c7b5391c9439ec5c80E3;
    address constant erc20 = 0x7DB32869056647532f80f482E5bB1fcb311493cD;


    event ShellsMinted(address indexed minter, uint256 amount, address[] indexed coins, uint256[] amounts);
    event ShellsBurned(address indexed burner, uint256 amount, address[] indexed coins, uint256[] amounts);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Trade(address indexed trader, address indexed origin, address indexed target, uint256 originAmount, uint256 targetAmount);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    modifier onlyOwner() {

        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    modifier nonReentrant() {

        require(notEntered, "re-entered");
        notEntered = false;
        _;
        notEntered = true;
    }

    modifier notFrozen () {

        require(!frozen, "swaps, selective deposits and selective withdraws have been frozen.");
        _;
    }

}





contract ERC20Approve {

    function approve (address spender, uint256 amount) public returns (bool);
}

contract Loihi is LoihiRoot {


    address constant dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant cdai = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643;
    address constant chai = 0x06AF07097C9Eeb7fD685c692751D5C66dB49c215;

    address constant usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant cusdc = 0x39AA39c021dfbaE8faC545936693aC917d5E7563;

    address constant usdt = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address constant ausdt = 0x71fc860F7D3A592A4a98740e39dB31d25db65ae8;

    address constant susd = 0x57Ab1ec28D129707052df4dF418D58a2D46d5f51;
    address constant asusd = 0x625aE63000f46200499120B906716420bd059240;

    address constant daiAdapter = 0xaC3DcacaF33626963468c58001414aDf1a4CCF86;
    address constant cdaiAdapter = 0xA5F095e778B30DcE3AD25D5A545e3e9d6092f1Af;
    address constant chaiAdapter = 0x251D87F3d6581ae430a8Df18C2474DA07C569615;

    address constant usdcAdapter = 0x98dD552EaEc607f9804fbd9758Df9C30Ada60B7B;
    address constant cusdcAdapter = 0xA189607D20afFA0b1a578f9D14040822D507978F;

    address constant usdtAdapter = 0xCd0dA368E6e32912DD6633767850751969346d15;
    address constant ausdtAdapter = 0xA4906F20a7806ca28626d3D607F9a594f1B9ed3B;

    address constant susdAdapter = 0x4CB5174C962a40177876799836f353e8E9c4eF75;
    address constant asusdAdapter = 0x68747564d7B4e7b654BE26D09f60f7756Cf54BF8;

    address constant aaveLpCore = 0x3dfd23A6c5E8BbcFc9581d2E864a68feb6a076d3;

    constructor () public {

        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);

        numeraires = [ dai, usdc, usdt, susd ];
        reserves = [ cdaiAdapter, cusdcAdapter, ausdtAdapter, asusdAdapter ];
        weights = [ 300000000000000000, 300000000000000000, 300000000000000000, 100000000000000000 ];
        
        flavors[dai] = Flavor(daiAdapter, cdaiAdapter);
        flavors[chai] = Flavor(chaiAdapter, cdaiAdapter);
        flavors[cdai] = Flavor(cdaiAdapter, cdaiAdapter);
        flavors[usdc] = Flavor(usdcAdapter, cusdcAdapter);
        flavors[cusdc] = Flavor(cusdcAdapter, cusdcAdapter);
        flavors[usdt] = Flavor(usdtAdapter, ausdtAdapter);
        flavors[ausdt] = Flavor(ausdtAdapter, ausdtAdapter);
        flavors[susd] = Flavor(susdAdapter, asusdAdapter);
        flavors[asusd] = Flavor(asusdAdapter, asusdAdapter);

        address[] memory targets = new address[](5);
        address[] memory spenders = new address[](5);
        targets[0] = dai; spenders[0] = chai;
        targets[1] = dai; spenders[1] = cdai;
        targets[2] = susd; spenders[2] = aaveLpCore;
        targets[3] = usdc; spenders[3] = cusdc;
        targets[4] = usdt; spenders[4] = aaveLpCore;

        for (uint i = 0; i < targets.length; i++) {
            (bool success, bytes memory returndata) = targets[i].call(abi.encodeWithSignature("approve(address,uint256)", spenders[i], uint256(0)));
            require(success, "SafeERC20: low-level call failed");
            (success, returndata) = targets[i].call(abi.encodeWithSignature("approve(address,uint256)", spenders[i], uint256(-1)));
            require(success, "SafeERC20: low-level call failed");
        }
        
        alpha = 900000000000000000; // .9
        beta = 400000000000000000; // .4
        delta = 150000000000000000; // .15
        epsilon = 175000000000000; // 1.75 bps * 2 = 3.5 bps
        lambda = 500000000000000000; // .5 

    }

    function supportsInterface (bytes4 interfaceID) external returns (bool) {
        return interfaceID == ERC20ID || interfaceID == ERC165ID;
    }

    function freeze (bool freeze) external onlyOwner {
        frozen = freeze;
    }

    function transferOwnership (address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

    function setParams (uint256 _alpha, uint256 _beta, uint256 _delta, uint256 _epsilon, uint256 _lambda, uint256 _omega) public onlyOwner {
        require(_alpha < OCTOPUS && _alpha > 0, "invalid-alpha");
        require(_beta < _alpha && _beta > 0, "invalid-beta");
        alpha = _alpha;
        beta = _beta;
        delta = _delta;
        epsilon = _epsilon;
        lambda = _lambda;
        omega = _omega;
    }

    function includeNumeraireReserveAndWeight (address numeraire, address reserve, uint256 weight) public onlyOwner {
        numeraires.push(numeraire);
        reserves.push(reserve);
        weights.push(weight);
    }

    function includeAdapter (address flavor, address adapter, address reserve) public onlyOwner {
        flavors[flavor] = Flavor(adapter, reserve);
    }

    function excludeAdapter (address flavor) public onlyOwner {
        delete flavors[flavor];
    }

    function delegateTo (address callee, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returnData) = callee.delegatecall(data);
        assembly {
            if eq(success, 0) { revert(add(returnData, 0x20), returndatasize) }
        }
        return returnData;
    }

    function staticTo (address callee, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returnData) = callee.staticcall(data);
        assembly {
            if eq(success, 0) { revert(add(returnData, 0x20), returndatasize) }
        }
        return returnData;
    }

    function swapByOrigin (address _o, address _t, uint256 _oAmt, uint256 _mTAmt, uint256 _dline) external notFrozen nonReentrant returns (uint256 tAmt_) {
        bytes memory result = delegateTo(exchange, abi.encodeWithSignature("executeOriginTrade(uint256,uint256,address,address,address,uint256)", _dline, _mTAmt, msg.sender, _o, _t, _oAmt));
        return abi.decode(result, (uint256));
    }


    function transferByOrigin (address _o, address _t, uint256 _oAmt, uint256 _mTAmt, uint256 _dline, address _rcpnt) external notFrozen nonReentrant returns (uint256) {
        bytes memory result = delegateTo(exchange, abi.encodeWithSignature("executeOriginTrade(uint256,uint256,address,address,address,uint256)", _dline, _mTAmt, _rcpnt, _o, _t, _oAmt));
        return abi.decode(result, (uint256));
    }

    function viewOriginTrade (address _o, address _t, uint256 _oAmt) external view notFrozen returns (uint256) {

        Flavor memory _oF = flavors[_o];
        Flavor memory _tF = flavors[_t];

        uint256[] memory _globals = new uint256[](6);
        _globals[0] = alpha; _globals[1] = beta; _globals[2] = delta; _globals[3] = epsilon; _globals[4] = lambda; _globals[5] = omega;

        bytes memory result = staticTo(views, abi.encodeWithSignature("viewTargetAmount(uint256,address,address,address,address[],address,address,uint256[],uint256[])", 
            _oAmt, _oF.adapter, _tF.adapter, address(this), reserves, _oF.reserve, _tF.reserve, weights, _globals)); 

        return abi.decode(result, (uint256));

    }

    function swapByTarget (address _o, address _t, uint256 _mOAmt, uint256 _tAmt, uint256 _dline) external notFrozen nonReentrant returns (uint256) {
        bytes memory result = delegateTo(exchange, abi.encodeWithSignature("executeTargetTrade(uint256,address,address,uint256,uint256,address)", _dline, _o, _t, _mOAmt, _tAmt, msg.sender));
        return abi.decode(result, (uint256));
    }

    function transferByTarget (address _o, address _t, uint256 _mOAmt, uint256 _tAmt, uint256 _dline, address _rcpnt) external notFrozen nonReentrant returns (uint256) {
        bytes memory result = delegateTo(exchange, abi.encodeWithSignature("executeTargetTrade(uint256,address,address,uint256,uint256,address)", _dline, _o, _t, _mOAmt, _tAmt, _rcpnt));
        return abi.decode(result, (uint256));
    }

    function viewTargetTrade (address _o, address _t, uint256 _tAmt) external view notFrozen returns (uint256) {

        Flavor memory _oF = flavors[_o];
        Flavor memory _tF = flavors[_t];

        uint256[] memory _globals = new uint256[](6);
        _globals[0] = alpha; _globals[1] = beta; _globals[2] = delta; _globals[3] = epsilon; _globals[4] = lambda; _globals[5] = omega;

        bytes memory result = staticTo(views, abi.encodeWithSignature("viewOriginAmount(uint256,address,address,address,address[],address,address,uint256[],uint256[])", 
            _tAmt, _tF.adapter, _oF.adapter, address(this), reserves, _tF.reserve, _oF.reserve, weights, _globals));

        return abi.decode(result, (uint256));

    }

    function selectiveDeposit (address[] calldata _flvrs, uint256[] calldata _amts, uint256 _minShells, uint256 _dline) external notFrozen nonReentrant returns (uint256) {
        bytes memory result = delegateTo(liquidity, abi.encodeWithSignature("selectiveDeposit(address[],uint256[],uint256,uint256)", _flvrs, _amts, _minShells, _dline));
        return abi.decode(result, (uint256));
    }

    function viewSelectiveDeposit (address[] calldata _flvrs, uint256[] calldata _amts) external notFrozen view returns (uint256) {
        uint256[] memory _globals = new uint256[](7);
        _globals[0] = alpha; _globals[1] = beta; _globals[2] = delta; _globals[3] = epsilon; _globals[4] = lambda; _globals[5] = omega; _globals[6] = totalSupply;
        address[] memory _flavors = new address[](_flvrs.length*2);
        for (uint256 i = 0; i < _flvrs.length; i++){
            Flavor memory _f = flavors[_flvrs[i]];
            _flavors[i*2] = _f.adapter;
            _flavors[i*2+1] = _f.reserve;
        }
        bytes memory result = staticTo(views, abi.encodeWithSignature("viewSelectiveDeposit(address[],address[],uint256[],address,uint256[],uint256[])", reserves, _flavors, _amts, address(this), weights, _globals));
        return abi.decode(result, (uint256));
    }

    function proportionalDeposit (uint256 _deposit) external notFrozen nonReentrant returns (uint256) {
        bytes memory result = delegateTo(liquidity, abi.encodeWithSignature("proportionalDeposit(uint256)", _deposit));
        return abi.decode(result, (uint256));
    }

    function selectiveWithdraw (address[] calldata _flvrs, uint256[] calldata _amts, uint256 _maxShells, uint256 _dline) external notFrozen nonReentrant returns (uint256) {
        bytes memory result = delegateTo(liquidity, abi.encodeWithSignature("selectiveWithdraw(address[],uint256[],uint256,uint256)", _flvrs, _amts, _maxShells, _dline));
        return abi.decode(result, (uint256));
    }

    function viewSelectiveWithdraw (address[] calldata _flvrs, uint256[] calldata _amts) external view notFrozen returns (uint256) {
        uint256[] memory _globals = new uint256[](7);
        _globals[0] = alpha; _globals[1] = beta; _globals[2] = delta; _globals[3] = epsilon; _globals[4] = lambda; _globals[5] = omega; _globals[6] = totalSupply;
        address[] memory _flavors = new address[](_flvrs.length*2);
        for (uint256 i = 0; i < _flvrs.length; i++){
            Flavor memory _f = flavors[_flvrs[i]];
            _flavors[i*2] = _f.adapter;
            _flavors[i*2+1] = _f.reserve;
        }
        bytes memory result = staticTo(views, abi.encodeWithSignature("viewSelectiveWithdraw(address[],address[],uint256[],address,uint256[],uint256[])", reserves, _flavors, _amts, address(this), weights, _globals));
        return abi.decode(result, (uint256));
    }

    function proportionalWithdraw (uint256 _totalShells) external nonReentrant returns (uint256[] memory) {
        bytes memory result = delegateTo(liquidity, abi.encodeWithSignature("proportionalWithdraw(uint256)", _totalShells));
        return abi.decode(result, (uint256[]));
    }

    function transfer (address recipient, uint256 amount) public nonReentrant returns (bool) {
        bytes memory result = delegateTo(erc20, abi.encodeWithSignature("transfer(address,uint256)", recipient, amount));
        return abi.decode(result, (bool));
    }

    function transferFrom (address sender, address recipient, uint256 amount) public nonReentrant returns (bool) {
        bytes memory result = delegateTo(erc20, abi.encodeWithSignature("transferFrom(address,address,uint256)", sender, recipient, amount));
        return abi.decode(result, (bool));
    }

    function approve (address spender, uint256 amount) public nonReentrant returns (bool) {
        bytes memory result = delegateTo(erc20, abi.encodeWithSignature("approve(address,uint256)", spender, amount));
        return abi.decode(result, (bool));
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        bytes memory result = delegateTo(erc20, abi.encodeWithSignature("increaseAllowance(address,uint256)", spender, addedValue));
        return abi.decode(result, (bool));
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        bytes memory result = delegateTo(erc20, abi.encodeWithSignature("decreaseAllowance(address,uint256)", spender, subtractedValue));
        return abi.decode(result, (bool));
    }

    function balanceOf (address account) public view returns (uint256) {
        return balances[account];
    }

    function allowance (address owner, address spender) public view returns (uint256) {
        return allowances[owner][spender];
    }

    function totalReserves () external returns (uint256, uint256[] memory) {
        bytes memory result = staticTo(views, abi.encodeWithSignature("totalReserves(address[],address)", reserves, address(this)));
        return abi.decode(result, (uint256, uint256[]));
    }

    function safeApprove(address _token, address _spender, uint256 _value) public onlyOwner {

        (bool success, bytes memory returndata) = _token.call(abi.encodeWithSignature("approve(address,uint256)", _spender, _value));
        require(success, "SafeERC20: low-level call failed");
    }

}