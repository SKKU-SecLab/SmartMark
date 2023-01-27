


pragma solidity ^0.6.0;

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


pragma solidity ^0.6.10;


interface IVat {

    function hope(address) external;

    function nope(address) external;

    function live() external view returns (uint);

    function ilks(bytes32) external view returns (uint, uint, uint, uint, uint);

    function urns(bytes32, address) external view returns (uint, uint);

    function gem(bytes32, address) external view returns (uint);

    function frob(bytes32, address, address, address, int, int) external;

    function fork(bytes32, address, address, int, int) external;

    function move(address, address, uint) external;

    function flux(bytes32, address, address, uint) external;

}


pragma solidity ^0.6.10;


interface IPot {

    function chi() external view returns (uint256);

    function pie(address) external view returns (uint256); // Not a function, but a public variable.

    function rho() external returns (uint256);

    function drip() external returns (uint256);

    function join(uint256) external;

    function exit(uint256) external;

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


pragma solidity ^0.6.10;


interface IWeth {

    function deposit() external payable;

    function withdraw(uint) external;

    function approve(address, uint) external returns (bool) ;

    function transfer(address, uint) external returns (bool);

    function transferFrom(address, address, uint) external returns (bool);

}


pragma solidity ^0.6.10;


interface IGemJoin {

    function rely(address usr) external;

    function deny(address usr) external;

    function cage() external;

    function join(address usr, uint WAD) external;

    function exit(address usr, uint WAD) external;

}


pragma solidity ^0.6.10;


interface IDaiJoin {

    function rely(address usr) external;

    function deny(address usr) external;

    function cage() external;

    function join(address usr, uint WAD) external;

    function exit(address usr, uint WAD) external;

}


pragma solidity ^0.6.10;


interface IChai {

    function balanceOf(address account) external view returns (uint256);

    function transfer(address dst, uint wad) external returns (bool);

    function move(address src, address dst, uint wad) external returns (bool);

    function transferFrom(address src, address dst, uint wad) external returns (bool);

    function approve(address usr, uint wad) external returns (bool);

    function dai(address usr) external returns (uint wad);

    function join(address dst, uint wad) external;

    function exit(address src, uint wad) external;

    function draw(address src, uint wad) external;

    function permit(address holder, address spender, uint256 nonce, uint256 expiry, bool allowed, uint8 v, bytes32 r, bytes32 s) external;

    function nonces(address account) external view returns (uint256);

}


pragma solidity ^0.6.10;








interface ITreasury {

    function debt() external view returns(uint256);

    function savings() external view returns(uint256);

    function pushDai(address user, uint256 dai) external;

    function pullDai(address user, uint256 dai) external;

    function pushChai(address user, uint256 chai) external;

    function pullChai(address user, uint256 chai) external;

    function pushWeth(address to, uint256 weth) external;

    function pullWeth(address to, uint256 weth) external;

    function shutdown() external;

    function live() external view returns(bool);


    function vat() external view returns (IVat);

    function weth() external view returns (IWeth);

    function dai() external view returns (IERC20);

    function daiJoin() external view returns (IDaiJoin);

    function wethJoin() external view returns (IGemJoin);

    function pot() external view returns (IPot);

    function chai() external view returns (IChai);

}


pragma solidity ^0.6.10;


interface IDelegable {

    function addDelegate(address) external;

    function addDelegateBySignature(address, address, uint, uint8, bytes32, bytes32) external;

}


pragma solidity ^0.6.0;

interface IERC2612 {

    function permit(address owner, address spender, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;


    function nonces(address owner) external view returns (uint256);

}


pragma solidity ^0.6.10;



interface IFYDai is IERC20, IERC2612 {

    function isMature() external view returns(bool);

    function maturity() external view returns(uint);

    function chi0() external view returns(uint);

    function rate0() external view returns(uint);

    function chiGrowth() external view returns(uint);

    function rateGrowth() external view returns(uint);

    function mature() external;

    function unlocked() external view returns (uint);

    function mint(address, uint) external;

    function burn(address, uint) external;

    function flashMint(uint, bytes calldata) external;

    function redeem(address, address, uint256) external returns (uint256);

}


pragma solidity ^0.6.10;





interface IController is IDelegable {

    function treasury() external view returns (ITreasury);

    function series(uint256) external view returns (IFYDai);

    function seriesIterator(uint256) external view returns (uint256);

    function totalSeries() external view returns (uint256);

    function containsSeries(uint256) external view returns (bool);

    function posted(bytes32, address) external view returns (uint256);

    function debtFYDai(bytes32, uint256, address) external view returns (uint256);

    function debtDai(bytes32, uint256, address) external view returns (uint256);

    function totalDebtDai(bytes32, address) external view returns (uint256);

    function isCollateralized(bytes32, address) external view returns (bool);

    function inDai(bytes32, uint256, uint256) external view returns (uint256);

    function inFYDai(bytes32, uint256, uint256) external view returns (uint256);

    function erase(bytes32, address) external returns (uint256, uint256);

    function shutdown() external;

    function post(bytes32, address, address, uint256) external;

    function withdraw(bytes32, address, address, uint256) external;

    function borrow(bytes32, uint256, address, address, uint256) external;

    function repayFYDai(bytes32, uint256, address, address, uint256) external returns (uint256);

    function repayDai(bytes32, uint256, address, address, uint256) external returns (uint256);

}


pragma solidity ^0.6.10;



contract Delegable is IDelegable {

    event Delegate(address indexed user, address indexed delegate, bool enabled);

    bytes32 public immutable SIGNATURE_TYPEHASH = 0x0d077601844dd17f704bafff948229d27f33b57445915754dfe3d095fda2beb7;
    bytes32 public immutable DELEGABLE_DOMAIN;
    mapping(address => uint) public signatureCount;

    mapping(address => mapping(address => bool)) public delegated;

    constructor () public {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }

        DELEGABLE_DOMAIN = keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
                keccak256(bytes('Yield')),
                keccak256(bytes('1')),
                chainId,
                address(this)
            )
        );
    }

    modifier onlyHolderOrDelegate(address holder, string memory errorMessage) {

        require(
            msg.sender == holder || delegated[holder][msg.sender],
            errorMessage
        );
        _;
    }

    function addDelegate(address delegate) public override {

        _addDelegate(msg.sender, delegate);
    }

    function revokeDelegate(address delegate) public {

        _revokeDelegate(msg.sender, delegate);
    }

    function addDelegateBySignature(address user, address delegate, uint deadline, uint8 v, bytes32 r, bytes32 s) public override {

        require(deadline >= block.timestamp, 'Delegable: Signature expired');

        bytes32 hashStruct = keccak256(
            abi.encode(
                SIGNATURE_TYPEHASH,
                user,
                delegate,
                signatureCount[user]++,
                deadline
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DELEGABLE_DOMAIN,
                hashStruct
            )
        );
        address signer = ecrecover(digest, v, r, s);
        require(
            signer != address(0) && signer == user,
            'Delegable: Invalid signature'
        );

        _addDelegate(user, delegate);
    }

    function _addDelegate(address user, address delegate) internal {

        require(!delegated[user][delegate], "Delegable: Already delegated");
        delegated[user][delegate] = true;
        emit Delegate(user, delegate, true);
    }

    function _revokeDelegate(address user, address delegate) internal {

        require(delegated[user][delegate], "Delegable: Already undelegated");
        delegated[user][delegate] = false;
        emit Delegate(user, delegate, false);
    }
}


pragma solidity ^0.6.10;



contract DecimalMath {

    using SafeMath for uint256;

    uint256 constant public UNIT = 1e27;

    function muld(uint256 x, uint256 y) internal pure returns (uint256) {

        return x.mul(y).div(UNIT);
    }

    function divd(uint256 x, uint256 y) internal pure returns (uint256) {

        return x.mul(UNIT).div(y);
    }

    function muldrup(uint256 x, uint256 y) internal pure returns (uint256)
    {

        uint256 z = x.mul(y);
        return z.mod(UNIT) == 0 ? z.div(UNIT) : z.div(UNIT).add(1);
    }

    function divdrup(uint256 x, uint256 y) internal pure returns (uint256)
    {

        uint256 z = x.mul(UNIT);
        return z.mod(y) == 0 ? z.div(y) : z.div(y).add(1);
    }
}



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



pragma solidity ^0.6.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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

    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity ^0.6.10;




contract Orchestrated is Ownable {

    event GrantedAccess(address access, bytes4 signature);

    mapping(address => mapping (bytes4 => bool)) public orchestration;

    constructor () public Ownable() {}

    modifier onlyOrchestrated(string memory err) {

        require(orchestration[msg.sender][msg.sig], err);
        _;
    }

    function orchestrate(address user, bytes4 signature) public onlyOwner {

        orchestration[user][signature] = true;
        emit GrantedAccess(user, signature);
    }

    function batchOrchestrate(address user, bytes4[] memory signatures) public onlyOwner {

        for (uint256 i = 0; i < signatures.length; i++) {
            orchestrate(user, signatures[i]);
        }
    }
}


pragma solidity ^0.6.10;












contract Controller is IController, Orchestrated(), Delegable(), DecimalMath {

    using SafeMath for uint256;

    event Posted(bytes32 indexed collateral, address indexed user, int256 amount);
    event Borrowed(bytes32 indexed collateral, uint256 indexed maturity, address indexed user, int256 amount);

    bytes32 public constant CHAI = "CHAI";
    bytes32 public constant WETH = "ETH-A";
    uint256 public constant DUST = 50e15; // 0.05 ETH

    IVat public vat;
    IPot public pot;
    ITreasury public override treasury;

    mapping(uint256 => IFYDai) public override series;                 // FYDai series, indexed by maturity
    uint256[] public override seriesIterator;                         // We need to know all the series

    mapping(bytes32 => mapping(address => uint256)) public override posted;                        // Collateral posted by each user
    mapping(bytes32 => mapping(uint256 => mapping(address => uint256))) public override debtFYDai;  // Debt owed by each user, by series

    bool public live = true;

    constructor (
        address treasury_,
        address[] memory fyDais

    ) public {
        treasury = ITreasury(treasury_);
        vat = treasury.vat();
        pot = treasury.pot();
        for (uint256 i = 0; i < fyDais.length; i += 1) {
            addSeries(fyDais[i]);
        }
    }

    modifier onlyLive() {

        require(live == true, "Controller: Not available during unwind");
        _;
    }

    modifier validCollateral(bytes32 collateral) {

        require(
            collateral == WETH || collateral == CHAI,
            "Controller: Unrecognized collateral"
        );
        _;
    }

    modifier validSeries(uint256 maturity) {

        require(
            containsSeries(maturity),
            "Controller: Unrecognized series"
        );
        _;
    }

    function toInt256(uint256 x) internal pure returns(int256) {

        require(
            x <= uint256(type(int256).max),
            "Controller: Cast overflow"
        );
        return int256(x);
    }

    function shutdown() public override {

        require(
            treasury.live() == false,
            "Controller: Treasury is live"
        );
        live = false;
    }

    function isCollateralized(bytes32 collateral, address user) public view override returns (bool) {

        return powerOf(collateral, user) >= totalDebtDai(collateral, user);
    }

    function aboveDustOrZero(bytes32 collateral, address user) public view returns (bool) {

        uint256 postedCollateral = posted[collateral][user];
        return postedCollateral == 0 || DUST < postedCollateral;
    }

    function totalSeries() public view override returns (uint256) {

        return seriesIterator.length;
    }

    function containsSeries(uint256 maturity) public view override returns (bool) {

        return address(series[maturity]) != address(0);
    }

    function addSeries(address fyDaiContract) private {

        uint256 maturity = IFYDai(fyDaiContract).maturity();
        require(
            !containsSeries(maturity),
            "Controller: Series already added"
        );
        series[maturity] = IFYDai(fyDaiContract);
        seriesIterator.push(maturity);
    }

    function inDai(bytes32 collateral, uint256 maturity, uint256 fyDaiAmount)
        public view override
        validCollateral(collateral)
        returns (uint256)
    {

        IFYDai fyDai = series[maturity];
        if (fyDai.isMature()){
            if (collateral == WETH){
                return muld(fyDaiAmount, fyDai.rateGrowth());
            } else if (collateral == CHAI) {
                return muld(fyDaiAmount, fyDai.chiGrowth());
            }
        } else {
            return fyDaiAmount;
        }
    }

    function inFYDai(bytes32 collateral, uint256 maturity, uint256 daiAmount)
        public view override
        validCollateral(collateral)
        returns (uint256)
    {

        IFYDai fyDai = series[maturity];
        if (fyDai.isMature()){
            if (collateral == WETH){
                return divd(daiAmount, fyDai.rateGrowth());
            } else if (collateral == CHAI) {
                return divd(daiAmount, fyDai.chiGrowth());
            }
        } else {
            return daiAmount;
        }
    }

    function debtDai(bytes32 collateral, uint256 maturity, address user) public view override returns (uint256) {

        return inDai(collateral, maturity, debtFYDai[collateral][maturity][user]);
    }

    function totalDebtDai(bytes32 collateral, address user) public view override returns (uint256) {

        uint256 totalDebt;
        uint256[] memory _seriesIterator = seriesIterator;
        for (uint256 i = 0; i < _seriesIterator.length; i += 1) {
            if (debtFYDai[collateral][_seriesIterator[i]][user] > 0) {
                totalDebt = totalDebt.add(debtDai(collateral, _seriesIterator[i], user));
            }
        } // We don't expect hundreds of maturities per controller
        return totalDebt;
    }

    function powerOf(bytes32 collateral, address user) public view returns (uint256) {

        if (collateral == WETH){
            (,, uint256 spot,,) = vat.ilks(WETH);  // Stability fee and collateralization ratio for Weth
            return muld(posted[collateral][user], spot);
        } else if (collateral == CHAI) {
            uint256 chi = pot.chi();
            return muld(posted[collateral][user], chi);
        } else {
            revert("Controller: Invalid collateral type");
        }
    }

    function locked(bytes32 collateral, address user)
        public view
        validCollateral(collateral)
        returns (uint256)
    {

        if (collateral == WETH){
            (,, uint256 spot,,) = vat.ilks(WETH);  // Stability fee and collateralization ratio for Weth
            return divdrup(totalDebtDai(collateral, user), spot);
        } else if (collateral == CHAI) {
            return divdrup(totalDebtDai(collateral, user), pot.chi());
        }
    }

    function post(bytes32 collateral, address from, address to, uint256 amount)
        public override 
        validCollateral(collateral)
        onlyHolderOrDelegate(from, "Controller: Only Holder Or Delegate")
        onlyLive
    {

        posted[collateral][to] = posted[collateral][to].add(amount);

        if (collateral == WETH){
            require(
                aboveDustOrZero(collateral, to),
                "Controller: Below dust"
            );
            treasury.pushWeth(from, amount);
        } else if (collateral == CHAI) {
            treasury.pushChai(from, amount);
        }
        
        emit Posted(collateral, to, toInt256(amount));
    }

    function withdraw(bytes32 collateral, address from, address to, uint256 amount)
        public override
        validCollateral(collateral)
        onlyHolderOrDelegate(from, "Controller: Only Holder Or Delegate")
        onlyLive
    {

        posted[collateral][from] = posted[collateral][from].sub(amount); // Will revert if not enough posted

        require(
            isCollateralized(collateral, from),
            "Controller: Too much debt"
        );

        if (collateral == WETH){
            require(
                aboveDustOrZero(collateral, from),
                "Controller: Below dust"
            );
            treasury.pullWeth(to, amount);
        } else if (collateral == CHAI) {
            treasury.pullChai(to, amount);
        }

        emit Posted(collateral, from, -toInt256(amount));
    }

    function borrow(bytes32 collateral, uint256 maturity, address from, address to, uint256 fyDaiAmount)
        public override
        validCollateral(collateral)
        validSeries(maturity)
        onlyHolderOrDelegate(from, "Controller: Only Holder Or Delegate")
        onlyLive
    {

        IFYDai fyDai = series[maturity];

        debtFYDai[collateral][maturity][from] = debtFYDai[collateral][maturity][from].add(fyDaiAmount);

        require(
            isCollateralized(collateral, from),
            "Controller: Too much debt"
        );

        fyDai.mint(to, fyDaiAmount);
        emit Borrowed(collateral, maturity, from, toInt256(fyDaiAmount));
    }

    function repayFYDai(bytes32 collateral, uint256 maturity, address from, address to, uint256 fyDaiAmount)
        public override
        validCollateral(collateral)
        validSeries(maturity)
        onlyHolderOrDelegate(from, "Controller: Only Holder Or Delegate")
        onlyLive
        returns (uint256)
    {

        uint256 toRepay = Math.min(fyDaiAmount, debtFYDai[collateral][maturity][to]);
        series[maturity].burn(from, toRepay);
        _repay(collateral, maturity, to, toRepay);
        return toRepay;
    }

    function repayDai(bytes32 collateral, uint256 maturity, address from, address to, uint256 daiAmount)
        public override
        validCollateral(collateral)
        validSeries(maturity)
        onlyHolderOrDelegate(from, "Controller: Only Holder Or Delegate")
        onlyLive
        returns (uint256)
    {

        uint256 toRepay = Math.min(daiAmount, debtDai(collateral, maturity, to));
        treasury.pushDai(from, toRepay);                                      // Have Treasury process the dai
        _repay(collateral, maturity, to, inFYDai(collateral, maturity, toRepay));
        return toRepay;
    }


    function _repay(bytes32 collateral, uint256 maturity, address user, uint256 fyDaiAmount) internal {

        debtFYDai[collateral][maturity][user] = debtFYDai[collateral][maturity][user].sub(fyDaiAmount);

        emit Borrowed(collateral, maturity, user, -toInt256(fyDaiAmount));
    }

    function erase(bytes32 collateral, address user)
        public override
        validCollateral(collateral)
        onlyOrchestrated("Controller: Not Authorized")
        returns (uint256, uint256)
    {

        uint256 userCollateral = posted[collateral][user];
        delete posted[collateral][user];

        uint256 userDebt;
        uint256[] memory _seriesIterator = seriesIterator;
        for (uint256 i = 0; i < _seriesIterator.length; i += 1) {
            uint256 maturity = _seriesIterator[i];
            userDebt = userDebt.add(debtDai(collateral, maturity, user)); // SafeMath shouldn't be needed
            delete debtFYDai[collateral][maturity][user];
        } // We don't expect hundreds of maturities per controller

        return (userCollateral, userDebt);
    }
}