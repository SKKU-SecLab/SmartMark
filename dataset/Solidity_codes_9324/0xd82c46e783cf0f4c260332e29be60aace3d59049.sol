


pragma solidity ^0.5.16;

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



contract OwnableUpgradable is Initializable {

    address payable public owner;
    address payable internal newOwnerCandidate;

    modifier onlyOwner {

        require(msg.sender == owner, "Permission denied");
        _;
    }


    function initialize() public initializer {

        owner = msg.sender;
    }

    function initialize(address payable newOwner) public initializer {

        owner = newOwner;
    }

    function changeOwner(address payable newOwner) public onlyOwner {

        newOwnerCandidate = newOwner;
    }

    function acceptOwner() public {

        require(msg.sender == newOwnerCandidate, "Permission denied");
        owner = newOwnerCandidate;
    }

    uint256[50] private ______gap;
}

contract AdminableUpgradable is Initializable, OwnableUpgradable {

    mapping(address => bool) public admins;

    modifier onlyOwnerOrAdmin {

        require(msg.sender == owner ||
        admins[msg.sender], "Permission denied");
        _;
    }

    function initialize() public initializer {

        OwnableUpgradable.initialize();  // Initialize Parent Contract
    }

    function initialize(address payable newOwner) public initializer {

        OwnableUpgradable.initialize(newOwner);  // Initialize Parent Contract
    }

    function setAdminPermission(address _admin, bool _status) public onlyOwner {

        admins[_admin] = _status;
    }

    function setAdminPermission(address[] memory _admins, bool _status) public onlyOwner {

        for (uint i = 0; i < _admins.length; i++) {
            admins[_admins[i]] = _status;
        }
    }

    uint256[50] private ______gap;
}

contract DSMath {

    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x);
    }

    function min(uint x, uint y) internal pure returns (uint z) {

        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {

        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {

        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {

        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y, uint base) internal pure returns (uint z) {

        z = add(mul(x, y), base / 2) / base;
    }

    function wmul(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, RAY), y / 2) / y;
    }

}

interface IController {

    function owner() view external returns (address);

}

interface IDfFinanceDeposits {

    function createStrategyDeposit(uint256 amountDAI, uint256 flashLoanAmount, address dfWallet) external returns (address);

    function createStrategyDepositFlashloan(uint256 amountDAI, uint256 flashLoanAmount, address dfWallet) external returns (address);

    function createStrategyDepositMulti(uint256 amountDAI, uint256 flashLoanAmount, uint32 times) external;


    function closeDepositDAI(address dfWallet, uint256 minDAIForCompound, bytes calldata data) external;

    function closeDepositFlashloan(address dfWallet, uint256 minUsdForComp, bytes calldata data) external;


    function partiallyCloseDepositDAI(address dfWallet, address tokenReceiver, uint256 amountDAI) external;

    function partiallyCloseDepositDAIFlashloan(address dfWallet, address tokenReceiver, uint256 amountDAI) external;


    function claimComps(address dfWallet, uint256 minDAIForCompound, bytes calldata data) external returns(uint256);

    function isClosed(address addrWallet) view external returns(bool);

}

interface IToken {

    function decimals() external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function approve(address spender, uint value) external;

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

    function deposit() external payable;

    function withdraw(uint amount) external;

}

interface IDfDepositToken {


    function mint(address account, uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;


    function balanceOfAt(address account, uint256 snapshotId) external view returns(uint256);

    function totalSupplyAt(uint256 snapshotId) external view returns(uint256);

    function snapshot() external returns(uint256);


}

contract ConstantAddresses {

    address public constant COMPTROLLER = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;
    address public constant COMPOUND_ORACLE = 0x1D8aEdc9E924730DD3f9641CDb4D1B92B848b4bd;




    address public constant DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant CDAI_ADDRESS = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643;

    address public constant COMP_ADDRESS = 0xc00e94Cb662C3520282E6f5717214004A7f26888;

    address public constant USDT_ADDRESS = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
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


library Address {

    function isContract(address account) internal view returns (bool) {


        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library SafeERC20 {


    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IToken token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IToken token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IToken token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IToken token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IToken token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IToken token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

library UniversalERC20 {


    using SafeMath for uint256;
    using SafeERC20 for IToken;

    IToken private constant ZERO_ADDRESS = IToken(0x0000000000000000000000000000000000000000);
    IToken private constant ETH_ADDRESS = IToken(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    function universalTransfer(IToken token, address to, uint256 amount) internal {

        universalTransfer(token, to, amount, false);
    }

    function universalTransfer(IToken token, address to, uint256 amount, bool mayFail) internal returns(bool) {

        if (amount == 0) {
            return true;
        }

        if (token == ZERO_ADDRESS || token == ETH_ADDRESS) {
            if (mayFail) {
                return address(uint160(to)).send(amount);
            } else {
                address(uint160(to)).transfer(amount);
                return true;
            }
        } else {
            token.safeTransfer(to, amount);
            return true;
        }
    }

    function universalApprove(IToken token, address to, uint256 amount) internal {

        if (token != ZERO_ADDRESS && token != ETH_ADDRESS) {
            token.safeApprove(to, amount);
        }
    }

    function universalTransferFrom(IToken token, address from, address to, uint256 amount) internal {

        if (amount == 0) {
            return;
        }

        if (token == ZERO_ADDRESS || token == ETH_ADDRESS) {
            require(from == msg.sender && msg.value >= amount, "msg.value is zero");
            if (to != address(this)) {
                address(uint160(to)).transfer(amount);
            }
            if (msg.value > amount) {
                msg.sender.transfer(uint256(msg.value).sub(amount));
            }
        } else {
            token.safeTransferFrom(from, to, amount);
        }
    }

    function universalBalanceOf(IToken token, address who) internal view returns (uint256) {

        if (token == ZERO_ADDRESS || token == ETH_ADDRESS) {
            return who.balance;
        } else {
            return token.balanceOf(who);
        }
    }
}

contract DfTokenizedDeposit is
Initializable,
AdminableUpgradable,
DSMath,
ConstantAddresses
{

    using UniversalERC20 for IToken;

    struct ProfitData {
        uint64 blockNumber;
        uint64 compProfit; // div 1e12 (6 dec)
        uint64 usdtProfit;
    }

    ProfitData[] public profits;

    IDfDepositToken public token;
    address public dfWallet;

    IDfFinanceDeposits public constant dfFinanceDeposits = IDfFinanceDeposits(0xFff9D7b0B6312ead0a1A993BF32f373449006F2F); // Mainnet

    mapping(address => uint64) public lastProfitDistIndex;

    address usdtExchanger;

    event CompSwap(uint256 timestamp, uint256 compPrice);
    event Profit(address indexed user, uint64 index, uint64 usdtProfit, uint64 compProfit);

    mapping(address => bool) public approvedContracts;
    
    function initialize() public initializer {

        address payable curOwner = 0xdAE0aca4B9B38199408ffaB32562Bf7B3B0495fE;
        AdminableUpgradable.initialize(curOwner);  // Initialize Parent Contract

        IToken(DAI_ADDRESS).approve(address(dfFinanceDeposits), uint256(-1));
    }

    function createStrategyDeposit(
        uint256 amount, uint256 flashLoanAmount, IDfDepositToken attachedToken, bool withFlashloan
    ) public onlyOwner {

        require(token == IDfDepositToken(0x0));
        require(dfWallet == address(0x0));

        token = attachedToken;
        IToken(DAI_ADDRESS).transferFrom(msg.sender, address(this), amount);

        if (withFlashloan) {
            dfWallet = dfFinanceDeposits.createStrategyDepositFlashloan(amount, flashLoanAmount, address(0x0));
        } else {
            dfWallet = dfFinanceDeposits.createStrategyDeposit(amount, flashLoanAmount, address(0x0));
        }

        token.mint(msg.sender, amount);
    }

    function addStrategyDeposit(
        uint256 amount, uint256 flashLoanAmount, bool withFlashloan
    ) public onlyOwner {

        require(token != IDfDepositToken(0x0));
        require(dfWallet != address(0x0));
        IToken(DAI_ADDRESS).transferFrom(msg.sender, address(this), amount);

        if (withFlashloan) {
            dfFinanceDeposits.createStrategyDepositFlashloan(amount, flashLoanAmount, dfWallet);
        } else {
            dfFinanceDeposits.createStrategyDeposit(amount, flashLoanAmount, dfWallet);
        }

        token.mint(msg.sender, amount);
    }

    function addUserStrategyDeposit(uint256 amount) public {

        require(msg.sender == tx.origin  || approvedContracts[msg.sender]);
        require(token != IDfDepositToken(0x0));
        require(dfWallet != address(0x0));
        IToken(DAI_ADDRESS).transferFrom(msg.sender, address(this), amount);
        dfFinanceDeposits.createStrategyDepositFlashloan(amount, amount * 290 / 100, dfWallet);
        token.mint(msg.sender, amount);
    }

    function closeStrategyDeposit(
        uint256 minUsdtForCompound, bytes memory data, bool withFlashloan
    ) public onlyOwner {

        require(dfWallet != address(0x0));
        uint256 compStartAmount = IToken(COMP_ADDRESS).balanceOf(address(this));

        if (withFlashloan) {
            dfFinanceDeposits.closeDepositFlashloan(dfWallet, minUsdtForCompound, data);
        } else {
            dfFinanceDeposits.closeDepositDAI(dfWallet, minUsdtForCompound, data);
        }

        uint256 compProfit = sub(IToken(COMP_ADDRESS).balanceOf(address(this)), compStartAmount);

        ProfitData memory p;
        p.blockNumber = uint64(block.number);
        p.compProfit = p.compProfit + uint64(compProfit / 1e12);
        p.usdtProfit = p.usdtProfit + uint64(minUsdtForCompound);
        token.snapshot();
        profits.push(p);
    }

    function burnTokens(uint256 amount, bool withFlashloan) public {

        require(msg.sender == tx.origin || approvedContracts[msg.sender]);
        token.burnFrom(msg.sender, amount);
        if (dfFinanceDeposits.isClosed(dfWallet)) {
            IToken(DAI_ADDRESS).transfer(msg.sender, amount);
        } else {
            if (withFlashloan) {
                dfFinanceDeposits.partiallyCloseDepositDAIFlashloan(dfWallet, msg.sender, amount);
            } else {
                dfFinanceDeposits.partiallyCloseDepositDAI(dfWallet, msg.sender, amount);
            }
        }
    }

    function calcUserProfit(address userAddress, uint256 max) public view returns(
        uint256 totalCompProfit, uint256 totalUsdtProfit, uint64 index
    ) {

        if (profits.length < max) max = profits.length;

        index = lastProfitDistIndex[userAddress];
        for(; index < max; index++) {
            ProfitData memory p = profits[index];
            uint256 balanceAtBlock = token.balanceOfAt(userAddress, index + 1);
            uint256 totalSupplyAt = token.totalSupplyAt(index + 1);
            uint256 profitUsdt = wdiv(wmul(uint256(p.usdtProfit), balanceAtBlock), totalSupplyAt);
            uint256 profitComp = wdiv(wmul(mul(uint256(p.compProfit), 1e12),balanceAtBlock), totalSupplyAt);
            totalUsdtProfit = add(totalUsdtProfit, profitUsdt);
            totalCompProfit = add(totalCompProfit, profitComp);
        }
    }

    function claimProfitFromMarkets(uint64 lastIndex, uint256 totalUsdtProfit1, uint8 v1, bytes32 r1, bytes32 s1, uint256 totalUsdtProfit2, uint8 v2, bytes32 r2, bytes32 s2) onlyOwner public {

        require(msg.sender == tx.origin);
        userClaimProfitOptimizedInternal(0xc37a700CB7c5c254dD581feF6F5768B1B705a5Bb, owner, lastIndex, totalUsdtProfit1, 0, v1, r1, s1);
        userClaimProfitOptimizedInternal(0x71d88D9A24125b61e580bB73D7C0b20F0E29902f, owner, lastIndex, totalUsdtProfit2, 0, v2, r2, s2);
    }

    function userClaimProfitOptimized(uint64 lastIndex, uint256 totalUsdtProfit, uint256 totalCompProfit, uint8 v, bytes32 r, bytes32 s) public {

        require(msg.sender == tx.origin);
        userClaimProfitOptimizedInternal(msg.sender, msg.sender, lastIndex, totalUsdtProfit, totalCompProfit, v, r, s);
    }

    function userClaimProfitOptimizedInternal(address userAddress, address target, uint64 lastIndex, uint256 totalUsdtProfit, uint256 totalCompProfit, uint8 v, bytes32 r, bytes32 s) internal {

        bytes32 hash = sha256(abi.encodePacked(this, userAddress, lastIndex, totalUsdtProfit, totalCompProfit));
        address src = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)), v, r, s);
        require(admins[src] == true, "Access denied");

        require(lastProfitDistIndex[userAddress] < lastIndex);

        lastProfitDistIndex[userAddress] = lastIndex;

        if (totalUsdtProfit > 0) {
            IToken(USDT_ADDRESS).universalTransfer(target, totalUsdtProfit);
        }

        if (totalCompProfit > 0) {
            IToken(COMP_ADDRESS).transfer(target, totalCompProfit);
        }
    }

    function userClaimProfitAndSendToAddresses(uint64 max, address[] memory targets, uint256[] memory amounts) public {

        require(msg.sender == tx.origin);
        require(targets.length == amounts.length);

        uint64 index;
        uint256 totalCompProfit;
        uint256 totalUsdtProfit;
        (totalCompProfit, totalUsdtProfit, index) = calcUserProfit(msg.sender, max);

        lastProfitDistIndex[msg.sender] = index;

        if (totalCompProfit > 0) {
            IToken(COMP_ADDRESS).transfer(msg.sender, totalCompProfit);
        }

        for(uint16 i = 0; i < targets.length;i++) {
            totalUsdtProfit = sub(totalUsdtProfit, amounts[i]);
            IToken(USDT_ADDRESS).universalTransfer(targets[i], amounts[i]);
        }

        if (totalUsdtProfit > 0) {
            IToken(USDT_ADDRESS).universalTransfer(msg.sender, totalUsdtProfit);
        }
    }

    function userClaimProfit(uint64 max) public {

        require(msg.sender == tx.origin);

        uint64 index;
        uint256 totalCompProfit;
        uint256 totalUsdtProfit;
        (totalCompProfit, totalUsdtProfit, index) = calcUserProfit(msg.sender, max);

        lastProfitDistIndex[msg.sender] = index;

        if (totalUsdtProfit > 0) {
            IToken(USDT_ADDRESS).universalTransfer(msg.sender, totalUsdtProfit);
        }

        if (totalCompProfit > 0) {
            IToken(COMP_ADDRESS).transfer(msg.sender, totalCompProfit);
        }
    }

    function setUSDTExchangeAddress(address _newAddress) public onlyOwnerOrAdmin {

        usdtExchanger = _newAddress;
    }

    function adminClaimProfitAndInternalSwapToUSDT(uint256 _compPriceInUsdt) public onlyOwnerOrAdmin {

        uint256 amountComps = dfFinanceDeposits.claimComps(dfWallet, 0, bytes(""));
        uint256 amountUsdt = mul(amountComps, _compPriceInUsdt) / 10**18; // COMP to USDT

        IToken(USDT_ADDRESS).universalTransferFrom(usdtExchanger, address(this), amountUsdt);
        IToken(COMP_ADDRESS).transfer(usdtExchanger, amountComps);

        ProfitData memory p;
        p.blockNumber = uint64(block.number);
        p.usdtProfit = p.usdtProfit + uint64(amountUsdt);
        profits.push(p);

        token.snapshot();

        emit CompSwap(block.timestamp, _compPriceInUsdt);
    }

    function adminClaimProfit(uint256 minUsdtForCompound, bytes memory data) public onlyOwnerOrAdmin {

        uint256 amount = dfFinanceDeposits.claimComps(dfWallet, minUsdtForCompound, data);
        ProfitData memory p;
        p.blockNumber = uint64(block.number);
        if (minUsdtForCompound == 0) {
            p.compProfit = p.compProfit + uint64(amount / 1e12);
        } else {
            p.usdtProfit = p.usdtProfit + uint64(amount);
        }
        profits.push(p);

        token.snapshot();
    }
    
    function approveContract(address newContract, bool bActive) public onlyOwner {

        approvedContracts[newContract] = bActive;
    }

}