


pragma solidity >=0.5.0;

interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;


    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

}




pragma solidity >=0.5.0;

library AddressStringUtil {

    function toAsciiString(address addr, uint len) pure internal returns (string memory) {

        require(len % 2 == 0 && len > 0 && len <= 40, "AddressStringUtil: INVALID_LEN");

        bytes memory s = new bytes(len);
        uint addrNum = uint(addr);
        for (uint i = 0; i < len / 2; i++) {
            uint8 b = uint8(addrNum >> (8 * (19 - i)));
            uint8 hi = b >> 4;
            uint8 lo = b - (hi << 4);
            s[2 * i] = char(hi);
            s[2 * i + 1] = char(lo);
        }
        return string(s);
    }

    function char(uint8 b) pure private returns (byte c) {

        if (b < 10) {
            return byte(b + 0x30);
        } else {
            return byte(b + 0x37);
        }
    }
}




pragma solidity >=0.5.0;

library SafeERC20Namer {

    function bytes32ToString(bytes32 x) pure private returns (string memory) {

        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = x[j];
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (uint j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }

    function parseStringData(bytes memory b) pure private returns (string memory) {

        uint charCount = 0;
        for (uint i = 32; i < 64; i++) {
            charCount <<= 8;
            charCount += uint8(b[i]);
        }

        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (uint i = 0; i < charCount; i++) {
            bytesStringTrimmed[i] = b[i + 64];
        }

        return string(bytesStringTrimmed);
    }

    function addressToName(address token) pure private returns (string memory) {

        return AddressStringUtil.toAsciiString(token, 40);
    }

    function addressToSymbol(address token) pure private returns (string memory) {

        return AddressStringUtil.toAsciiString(token, 6);
    }

    function callAndParseStringReturn(address token, bytes4 selector) view private returns (string memory) {

        (bool success, bytes memory data) = token.staticcall(abi.encodeWithSelector(selector));
        if (!success || data.length == 0) {
            return "";
        }
        if (data.length == 32) {
            bytes32 decoded = abi.decode(data, (bytes32));
            return bytes32ToString(decoded);
        } else if (data.length > 64) {
            return abi.decode(data, (string));
        }
        return "";
    }

    function tokenSymbol(address token) internal view returns (string memory) {

        string memory symbol = callAndParseStringReturn(token, 0x95d89b41);
        if (bytes(symbol).length == 0) {
            return addressToSymbol(token);
        }
        return symbol;
    }

    function tokenName(address token) internal view returns (string memory) {

        string memory name = callAndParseStringReturn(token, 0x06fdde03);
        if (bytes(name).length == 0) {
            return addressToName(token);
        }
        return name;
    }
}



pragma solidity >=0.5.0;

interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);


    function createPair(address tokenA, address tokenB) external returns (address pair);


    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

}





interface ICOREGlobals {

    function CORETokenAddress() external view returns (address);

    function COREGlobalsAddress() external view returns (address);

    function COREDelegatorAddress() external view returns (address);

    function COREVaultAddress() external returns (address);

    function COREWETHUniPair() external view returns (address);

    function UniswapFactory() external view returns (address);

    function TransferHandler() external view returns (address);

    function addDelegatorStateChangePermission(address that, bool status) external;

    function isStateChangeApprovedContract(address that)  external view returns (bool);

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



pragma solidity >=0.4.24 <0.7.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}



pragma solidity ^0.6.0;

contract ContextUpgradeSafe is Initializable {


    function __Context_init() internal initializer {

        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {



    }


    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}



pragma solidity ^0.6.0;


contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    function __Ownable_init() internal initializer {

        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {



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

    uint256[49] private __gap;
}



pragma solidity 0.6.12;








interface ICOREVault {

    function addPendingRewards(uint256 _) external; 

}

interface IUNICORE {

    function viewGovernanceLevel(address) external returns (uint8);

    function setVault(address) external;

    function burnFromUni(uint256) external;

    function viewUNIv2() external returns (address);

    function viewUniBurnRatio() external returns (uint256);

    function setGovernanceLevel(address, uint8) external;

    function balanceOf(address) external returns (uint256);

    function setUniBurnRatio(uint256) external;

    function viewwWrappedUNIv2() external returns (address);

    function burnToken(uint256) external;

    function totalSupply() external returns (uint256);

}

interface IUNICOREVault {

    function userInfo(uint,address) external view returns (uint256, uint256);

}

interface IProxyAdmin {

    function owner() external returns (address);

    function transferOwnership(address) external;

    function upgrade(address, address) external;

}


interface IWETH {

    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;

}
interface ILGE {

    function claimLP() external;

}

interface ITransferContract {

    function run(address) external;

}

interface ICORE {

    function setShouldTransferChecker(address) external;

}

interface ITimelockVault {

    function LPContributed(address) external view returns (uint256);

}

contract TENSFeeApproverPermanent {

    address public tokenETHPair;
    constructor() public {
            tokenETHPair = 0xB1b537B7272BA1EDa0086e2f480AdCA72c0B511C;
    }

    function calculateAmountsAfterFee(
        address sender,
        address recipient,
        uint256 amount
        ) public  returns (uint256 transferToAmount, uint256 transferToFeeDistributorAmount, uint256 burn)
        {


            if(sender == tokenETHPair || recipient == tokenETHPair) {
                require(false, "TENS is deprecated.");
            }

            transferToAmount = amount;
        
        }
}


contract COREForkMigrator is OwnableUpgradeSafe {

    using SafeMath for uint256;
    event ETHSendToLGE(uint256);

    bool public LPClaimedFromLGE;
    bool private locked;
    IERC20 public  CORE;
    ICOREVault public  coreVault;
    IUniswapV2Factory public  uniswapFactory;
    IWETH wETH;
    address public  CORExWETHPair;
    address payable public CORE_MULTISIG;
    address public postLGELPTokenAddress;
    address public Fee_Approver_Permanent;
    address public Vault_Permanent;
    uint256 public totalLPClaimed;
    uint256 public totalETHSent;
    uint256 contractStartTimestamp;

    mapping (address => bool) LPClaimed;

    bool public UNICORE_Migrated;
    bool public UNICORE_Liquidity_Transfered;
    address public UNICORE_Vault;
    address public UNICORE_Token;
    address public UNICORE_Reactor_Token; // Slit token for liquidity
    uint256 public UNICORE_Snapshot_Block;
    uint256 public Ether_Total_For_UNICORE_LP;
    uint256 public UNICORE_Total_LP_Supply;

    mapping (address => uint256) balanceUNICOREReactor;
    mapping (address => uint256) balanceUNICOREReactorInVaultOnSnapshot;


    bool public ENCORE_Liquidity_Transfered;
    bool public ENCORE_Transfers_Closed;
    address public ENCORE_Vault;
    address public ENCORE_Vault_Timelock;
    address public ENCORE_Fee_Approver;
    address public ENCORE_Token;
    address public ENCORE_Timelock_Vault;
    address public ENCORE_Proxy_Admin;
    address public ENCORE_LP_Token;
    address public ENCORE_Migrator;
    uint256 public Ether_Credit_Per_ENCORE_LP;
    uint256 public Ether_Total_For_Encore_LP;
    uint256 public ENCORE_Total_LP_Supply;

    mapping (address => uint256) balanceENCORELP;


    bool public TENS_Liquidity_Transfered;
    address public TENS_Vault;
    address public TENS_Token;
    address public TENS_Proxy_Admin;
    address public TENS_LP_Token;
    address public TENS_Fee_Approver_Permanent;
    uint256 public Ether_Total_For_TENS_LP;
    uint256 public TENS_Total_LP_Supply;

    mapping (address => uint256) balanceTENSLP;

    modifier lock() {

        require(locked == false, 'CORE Migrator: Execution Locked');
        locked = true;
        _;
        locked = false;
    }


    function initialize() initializer public{

        require(tx.origin == 0x5A16552f59ea34E44ec81E58b3817833E9fD5436);
        require(msg.sender == 0x5A16552f59ea34E44ec81E58b3817833E9fD5436);

        OwnableUpgradeSafe.__Ownable_init();
        CORE_MULTISIG = 0x5A16552f59ea34E44ec81E58b3817833E9fD5436;
        contractStartTimestamp = block.timestamp;

        Vault_Permanent = 0xfeD4Ec1348a4068d4934E09492428FD92E399e5c;
        Fee_Approver_Permanent = 0x43Dd7026284Ac8f95Eb02bB1bd68D0699B0Ae9cA;

        UNICORE_Vault = 0x6F31ECD8110bcBc679AEfb74c7608241D1B78949;
        UNICORE_Token = 0x5506861bbb104Baa8d8575e88E22084627B192D8;

        TENS_Vault = 0xf983EcF91195bD63DE8445997082680E688749BC;
        TENS_Token = 0x776CA7dEd9474829ea20AD4a5Ab7a6fFdB64C796;
        TENS_Proxy_Admin = 0x2d0C48C5BF930A09F8CD6fae5aC5A16b24e1723a;
        TENS_LP_Token = 0xB1b537B7272BA1EDa0086e2f480AdCA72c0B511C;
        TENS_Fee_Approver_Permanent = 0x22C91cDd1E00cD4d7D029f0dB94020Fce3C486e3;
        
        ENCORE_Proxy_Admin = 0x1964784ba40c9fD5EED1070c1C38cd5D1d5F9f55;
        ENCORE_Token = 0xe0E4839E0c7b2773c58764F9Ec3B9622d01A0428;
        ENCORE_LP_Token = 0x2e0721E6C951710725997928DcAAa05DaaFa031B;
        ENCORE_Fee_Approver = 0xF3c3ff0ea59d15e82b9620Ed7406fa3f6A261f98;
        ENCORE_Vault = 0xdeF7BdF8eCb450c1D93C5dB7C8DBcE5894CCDaa9;
        ENCORE_Vault_Timelock = 0xC2Cb86437355f36d42Fb8D979ab28b9816ac0545;
        Ether_Credit_Per_ENCORE_LP = uint256(1 ether).div(2).mul(10724).div(10000); // Account for 7.24% fee on LGE

        ICOREGlobals globals = ICOREGlobals(0x255CA4596A963883Afe0eF9c85EA071Cc050128B);
        CORE = IERC20(globals.CORETokenAddress());
        uniswapFactory = IUniswapV2Factory(globals.UniswapFactory());
        coreVault = ICOREVault(globals.COREVaultAddress());
        CORExWETHPair = globals.COREWETHUniPair();
        wETH = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }
    
    receive() external payable{}

    function setLPTokenAddress(address _token) onlyOwner public {

        postLGELPTokenAddress = _token;
    }

    function claimLP() lock public {

        require(LPClaimedFromLGE == true, "Nothing to claim yet");
        require(getOwedLP(msg.sender) > 0, "nothing to claim");
        require(IERC20(postLGELPTokenAddress).transfer(msg.sender, getOwedLP(msg.sender)));
        LPClaimed[msg.sender] = true;
    }

    function getOwedLP(address user) public view returns (uint256 LPDebtForUser) {

        if(postLGELPTokenAddress == address (0)) return 0;
        if(LPClaimedFromLGE == false) return 0;
        if(LPClaimed[msg.sender] == true) return 0;

        uint256 balanceUNICORE = viewCreditedUNICOREReactors(user);
        uint256 balanceENCORE = viewCreditedENCORETokens(user);
        uint256 balanceTENS = viewCreditedTENSTokens(user);

        if(balanceUNICORE == 0 && balanceENCORE == 0 && balanceTENS == 0) return 0;

        uint256 totalETH = Ether_Total_For_TENS_LP.add(Ether_Total_For_UNICORE_LP).add(Ether_Total_For_Encore_LP);
        uint256 totalETHEquivalent;

        if(balanceUNICORE > 0){
            totalETHEquivalent = Ether_Total_For_UNICORE_LP.div(UNICORE_Total_LP_Supply).mul(balanceUNICORE);
        }

        if(balanceENCORE > 0){
            totalETHEquivalent = totalETHEquivalent.add(Ether_Total_For_Encore_LP).div(ENCORE_Total_LP_Supply).mul(balanceENCORE);

        }

        if(balanceTENS > 0){
            totalETHEquivalent = totalETHEquivalent.add(Ether_Total_For_TENS_LP).div(TENS_Total_LP_Supply).mul(balanceTENS);
        }

        LPDebtForUser = totalETHEquivalent.mul(totalLPClaimed).div(totalETH).div(1e18);
    }


    function snapshotUNICORE(address[] memory _addresses, uint256[] memory balances) onlyOwner public {

        require(UNICORE_Migrated == true, "UNICORE Deposits are still not closed");

        uint256 length = _addresses.length;
        require(length == balances.length, "Wrong input");

        for (uint256 i = 0; i < length; i++) {
            balanceUNICOREReactorInVaultOnSnapshot[_addresses[i]] = balances[i];
        }
    }

    function setUnicoreReactorToken ( address _token ) onlyOwner public {
        UNICORE_Reactor_Token = _token;
    }

    function viewCreditedUNICOREReactors(address person) public view returns (uint256) {


        if(UNICORE_Migrated) {
            return balanceUNICOREReactorInVaultOnSnapshot[person].add(balanceUNICOREReactor[person]);
        }

        else {
            (uint256 userAmount, ) = IUNICOREVault(UNICORE_Vault).userInfo(0, person);
            return balanceUNICOREReactor[person].add(userAmount);

        }

    }

    function addUNICOREReactors() lock public {

        require(UNICORE_Migrated == false, "UNICORE Deposits closed");
        uint256 amtAdded = transferTokenHereSupportingFeeOnTransferTokens(UNICORE_Reactor_Token, IERC20(UNICORE_Reactor_Token).balanceOf(msg.sender));
        balanceUNICOREReactor[msg.sender] = balanceUNICOREReactor[msg.sender].add(amtAdded);
    }



    function transferUNICORELiquidity() onlyOwner public {

        require(ENCORE_Liquidity_Transfered == true, "ENCORE has to go first");
        require(UNICORE_Liquidity_Transfered == false, "UNICORE already transfered");

        require(IUNICORE(UNICORE_Token).viewGovernanceLevel(address(this)) == 2, "Incorrectly set governance level, can't proceed");
        require(IUNICORE(UNICORE_Token).viewGovernanceLevel(0x5A16552f59ea34E44ec81E58b3817833E9fD5436) == 2, "Incorrectly set governance level, can't proceed");
        require(IUNICORE(UNICORE_Token).viewGovernanceLevel(0x05957F3344255fDC9fE172E30016ee148D684313) == 0, "Incorrectly set governance level, can't proceed");
        require(IUNICORE(UNICORE_Token).viewGovernanceLevel(0xE6f32f17BE3Bf031B4B6150689C1f17cEcA375C8) == 0, "Incorrectly set governance level, can't proceed");
        require(IUNICORE(UNICORE_Token).viewGovernanceLevel(0xF4D7a0E8a68345442172F45cAbD272c25320AA96) == 0, "Incorrectly set governance level, can't proceed");
        require(address(this).balance >= 1e18, " Feed me eth");

        IUNICORE unicore = IUNICORE(UNICORE_Token);

        wETH.deposit{value: 1e18}();
        IUniswapV2Pair pair = IUniswapV2Pair(unicore.viewUNIv2());
        
        bool token0IsWETH = pair.token0() == address(wETH);
        (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
        wETH.transfer(address(pair), 1e18);
        uint256 amtUnicore;

        if(token0IsWETH){
            amtUnicore = getAmountOut(1e18, reserve0, reserve1);
            pair.swap(0, amtUnicore, address(this), "");
        }
        else{
            amtUnicore = getAmountOut(1e18, reserve1, reserve0);

            pair.swap(amtUnicore, 0, address(this), "");
        }

        unicore.setVault(address(this));
        unicore.setUniBurnRatio(100);
    
        uint256 balUnicoreOfUniPair = unicore.balanceOf(unicore.viewUNIv2());
        uint256 totalSupplywraps = IERC20(unicore.viewwWrappedUNIv2()).totalSupply();
        UNICORE_Total_LP_Supply = totalSupplywraps;

        uint256 input = (balUnicoreOfUniPair-1).mul(totalSupplywraps).div(balUnicoreOfUniPair);

        unicore.burnFromUni(input);

        {

        (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
        uint256 amtWETH;
        uint256 previousPairBalance = unicore.balanceOf(address(pair));
        IERC20(address(unicore)).transfer(address(pair),  unicore.balanceOf(address(this)));
        uint256 nowPairBalance = unicore.balanceOf(address(pair));

        if(token0IsWETH){
            amtWETH = getAmountOut(nowPairBalance- previousPairBalance, reserve1, reserve0);

            pair.swap(amtWETH, 0, address(this), "");
            ( reserve0,  reserve1, ) = pair.getReserves();
            require(reserve0 < 1e18, " Burn not sufficient");
        }
        else{
            amtWETH = getAmountOut(nowPairBalance- previousPairBalance, reserve0, reserve1);

            pair.swap(0, amtWETH, address(this), "");
            ( reserve0,  reserve1, ) = pair.getReserves();
            require(reserve1 < 1e18, " Burn not sufficient");
        }

        uint256 UNICORETotalSupply = unicore.totalSupply();
        require(amtWETH > UNICORETotalSupply.mul(60).div(100), " Didn't get enough ETH ");
        require(amtWETH > 500 ether, " Didn't get enough ETH"); // sanity
        
        Ether_Total_For_UNICORE_LP = amtWETH
                .mul(Ether_Credit_Per_ENCORE_LP)
                .div(1e18);

        wETH.withdraw(amtWETH);

        unicore.setGovernanceLevel(address(this), 1);
        UNICORE_Liquidity_Transfered = true;

        }

    }

    function viewCreditedENCORETokens(address person) public view returns (uint256) {

            (uint256 userAmount, ) = IUNICOREVault(ENCORE_Vault).userInfo(0, person);
            uint256 userAmountTimelock = ITimelockVault(ENCORE_Vault_Timelock).LPContributed(person);
            return balanceENCORELP[person].add(userAmount).add(userAmountTimelock);
    }

    function addENCORELPTokens() lock public {

        require(ENCORE_Transfers_Closed == false, "ENCORE LP transfers closed");
        uint256 amtAdded = transferTokenHereSupportingFeeOnTransferTokens(ENCORE_LP_Token, IERC20(ENCORE_LP_Token).balanceOf(msg.sender));
        balanceENCORELP[msg.sender] = balanceENCORELP[msg.sender].add(amtAdded);
    }

    function closeENCORETransfers() onlyOwner public  {

        require(block.timestamp >= contractStartTimestamp.add(2 days), "2 day grace ongoing");
        ENCORE_Transfers_Closed = true;
    }

    function transferENCORELiquidity(address privateTransferContract) onlyOwner public {


        require(ENCORE_Transfers_Closed == true, "ENCORE LP transfers still ongoing");
        require(ENCORE_Liquidity_Transfered == false, "Already transfered liquidity");
        require(IProxyAdmin(ENCORE_Proxy_Admin).owner() == address(this), "Set me as the proxy owner for ENCORE");

        require(privateTransferContract != address(0));
        IProxyAdmin(ENCORE_Proxy_Admin).transferOwnership(privateTransferContract);

        uint256 burnedLPTokens = IERC20(ENCORE_LP_Token).balanceOf(ENCORE_Token)
                .add(IERC20(ENCORE_LP_Token).balanceOf(0x2a997EaD7478885a66e6961ac0837800A07492Fc));

        ENCORE_Total_LP_Supply = IERC20(ENCORE_LP_Token).totalSupply() - burnedLPTokens;
    
        Ether_Total_For_Encore_LP = ENCORE_Total_LP_Supply // burned ~100
                .mul(Ether_Credit_Per_ENCORE_LP)
                .div(1e18);

        IERC20(ENCORE_LP_Token)
            .transfer(ENCORE_LP_Token, IERC20(ENCORE_LP_Token).balanceOf(address(this)));

        uint256 ethBalBefore = address(this).balance;
        ITransferContract(privateTransferContract).run(ENCORE_LP_Token);
        uint256 newETH = address(this).balance.sub(ethBalBefore);

        require(newETH > 9200 ether, "Did not recieve enough ether");
                
        require(newETH.mul(60).div(100) > Ether_Total_For_Encore_LP, "Too much for encore LP"); 
                
        require(ENCORE_Proxy_Admin != address(0) 
                &&  Fee_Approver_Permanent != address(0) 
                && Vault_Permanent != address(0), "Sanity check failue");

        IProxyAdmin(ENCORE_Proxy_Admin).upgrade(ENCORE_Fee_Approver, Fee_Approver_Permanent);
        IProxyAdmin(ENCORE_Proxy_Admin).upgrade(ENCORE_Vault, Vault_Permanent);
        _sendENCOREProxyAdminBackToMultisig();
        ENCORE_Liquidity_Transfered = true;
    }

    function sendENCOREProxyAdminBackToMultisig() onlyOwner public {

        return _sendENCOREProxyAdminBackToMultisig();
    }

    function _sendENCOREProxyAdminBackToMultisig() internal {

        IProxyAdmin(ENCORE_Proxy_Admin).transferOwnership(CORE_MULTISIG);
        require(IProxyAdmin(ENCORE_Proxy_Admin).owner() == CORE_MULTISIG, "Proxy Ownership Transfer Not Successfull");
    }


    function addTENSLPTokens() lock public {

        require(ENCORE_Transfers_Closed == false, "TENS LP transfers still ongoing");
        uint256 amtAdded = transferTokenHereSupportingFeeOnTransferTokens(TENS_LP_Token, IERC20(TENS_LP_Token).balanceOf(msg.sender));
        balanceTENSLP[msg.sender] = balanceTENSLP[msg.sender].add(amtAdded);
    }

    function viewCreditedTENSTokens(address person) public view returns (uint256) {


        (uint256 userAmount, ) = IUNICOREVault(TENS_Vault).userInfo(0, person);
        return balanceTENSLP[person].add(userAmount);
    }

    function transferTENSLiquidity(address privateTransferContract) onlyOwner public {


        require(TENS_Liquidity_Transfered == false, "Already transfered");
        require(ENCORE_Liquidity_Transfered == true, "ENCORE has to go first");

        require(IProxyAdmin(TENS_Proxy_Admin).owner() == address(this), "Set me as the proxy owner for TENS");
        require(IProxyAdmin(TENS_Token).owner() == address(this), "Set me as the owner for TENS"); // same interface
        require(privateTransferContract != address(0));

        IProxyAdmin(TENS_Proxy_Admin).transferOwnership(privateTransferContract);
        IProxyAdmin(TENS_Token).transferOwnership(privateTransferContract);
        TENS_Total_LP_Supply = IERC20(TENS_LP_Token).totalSupply();

        IERC20(TENS_LP_Token)
            .transfer(TENS_LP_Token, IERC20(TENS_LP_Token).balanceOf(address(this)));

        uint256 ethBalBefore = address(this).balance;
        ITransferContract(privateTransferContract).run(TENS_LP_Token);
        uint256 newETH = address(this).balance.sub(ethBalBefore);
        require(newETH > 130 ether, "Did not recieve enough ether");

        require(TENS_Fee_Approver_Permanent != address(0) &&
            Vault_Permanent != address(0), "Sanity check failue");

        IProxyAdmin(TENS_Proxy_Admin).upgrade(TENS_Vault, Vault_Permanent);
        TENS_Fee_Approver_Permanent = address ( new TENSFeeApproverPermanent() );
        ICORE(TENS_Token).setShouldTransferChecker(TENS_Fee_Approver_Permanent);
        Ether_Total_For_TENS_LP = newETH
                .mul(Ether_Credit_Per_ENCORE_LP)
                .div(1e18);

        _sendOwnershipOfTENSBackToMultisig();

        TENS_Liquidity_Transfered = true;
  
    }

    function sendOwnershipOfTENSBackToMultisig() onlyOwner public {

        return _sendOwnershipOfTENSBackToMultisig();
    }

    function _sendOwnershipOfTENSBackToMultisig() internal {

        IProxyAdmin(TENS_Token).transferOwnership(CORE_MULTISIG);
        require(IProxyAdmin(TENS_Token).owner() == CORE_MULTISIG, "Multisig not owner of token"); // same interface
        IProxyAdmin(TENS_Proxy_Admin).transferOwnership(CORE_MULTISIG);
        require(IProxyAdmin(TENS_Proxy_Admin).owner() == CORE_MULTISIG, "Multisig not owner of proxyadmin");
    }

  
    function sendETH(address payable to, uint256 amt) internal {

        to.transfer(amt);
    }

    function safeTransfer(address token, address to, uint256 value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'FA Controller: TRANSFER_FAILED');
    }


    function transferTokenHereSupportingFeeOnTransferTokens(address token,uint256 amountTransfer) internal returns (uint256 amtAdded) {

        uint256 balBefore = IERC20(token).balanceOf(address(this));
        require(IERC20(token).transferFrom(msg.sender, address(this), amountTransfer));
        amtAdded = IERC20(token).balanceOf(address(this)).sub(balBefore);
    }

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) internal  pure returns (uint256 amountOut) {

        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }



    function rescueUnsupportedTokens(address token, uint256 amt) public onlyOwner {

        IERC20(token).transfer(CORE_MULTISIG, amt);
    }

    function sendETHToLGE(uint256 amt, address payable lgeContract) onlyOwner public {

        uint256 totalETH = Ether_Total_For_TENS_LP.add(Ether_Total_For_UNICORE_LP).add(Ether_Total_For_Encore_LP);
        totalETHSent = totalETHSent.add(amt);
        require(totalETHSent <= totalETH, "Too much sent");
        require(lgeContract != address(0)," no ");
        sendETH(lgeContract, amt);
        emit ETHSendToLGE(amt);
    }

    function sendETHToTreasury(uint256 amt, address payable to) onlyOwner public {

        uint256 totalETH = Ether_Total_For_TENS_LP.add(Ether_Total_For_UNICORE_LP).add(Ether_Total_For_Encore_LP);
        require(totalETHSent == totalETH, "Still money to send to LGE");
        require(to != address(0)," no ");
        sendETH(to, amt);
    }

    function getETHLeftToDepositToLGE() public view returns (uint256) {

        uint256 totalETH = Ether_Total_For_TENS_LP.add(Ether_Total_For_UNICORE_LP).add(Ether_Total_For_Encore_LP);
        return totalETH - totalETHSent;
    }

    function claimLPFromLGE(address lgeContract) onlyOwner public {

        require(postLGELPTokenAddress != address(0), "LP token address not set.");
        ILGE(lgeContract).claimLP();
        
        LPClaimedFromLGE = true;
        totalLPClaimed = IERC20(postLGELPTokenAddress).balanceOf(address(this));
    }

}