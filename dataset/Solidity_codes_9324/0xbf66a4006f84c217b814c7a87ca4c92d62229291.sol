

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


pragma solidity ^0.5.16;


contract OwnableUpgradable is Initializable {

    address payable public owner;
    address payable internal newOwnerCandidate;

    function initialize() initializer public {

        owner = msg.sender;
    }

    modifier onlyOwner {

        require(msg.sender == owner);
        _;
    }

    function changeOwner(address payable newOwner) public onlyOwner {

        newOwnerCandidate = newOwner;
    }

    function acceptOwner() public {

        require(msg.sender == newOwnerCandidate);
        owner = newOwnerCandidate;
    }

    uint256[50] private ______gap;
}


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.5;

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


pragma solidity ^0.5.16;

interface TokenInterface {

    function decimals() external view returns (uint);

    function allowance(address, address) external view returns (uint);

    function balanceOf(address) external view returns (uint);

    function approve(address, uint) external;

    function transfer(address, uint) external returns (bool);

    function transferFrom(address, address, uint) external returns (bool);

    function deposit() external payable;

    function withdraw(uint) external;

}


pragma solidity ^0.5.16;





library SafeERC20 {


    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(TokenInterface token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(TokenInterface token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(TokenInterface token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(TokenInterface token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(TokenInterface token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(TokenInterface token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity ^0.5.16;





library UniversalERC20 {


    using SafeMath for uint256;
    using SafeERC20 for TokenInterface;

    TokenInterface private constant ZERO_ADDRESS = TokenInterface(0x0000000000000000000000000000000000000000);
    TokenInterface private constant ETH_ADDRESS = TokenInterface(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    function universalTransfer(TokenInterface token, address to, uint256 amount) internal {

        universalTransfer(token, to, amount, false);
    }

    function universalTransfer(TokenInterface token, address to, uint256 amount, bool mayFail) internal returns(bool) {

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

    function universalApprove(TokenInterface token, address to, uint256 amount) internal {

        if (token != ZERO_ADDRESS && token != ETH_ADDRESS) {
            token.safeApprove(to, amount);
        }
    }

    function universalTransferFrom(TokenInterface token, address from, address to, uint256 amount) internal {

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

    function universalBalanceOf(TokenInterface token, address who) internal view returns (uint256) {

        if (token == ZERO_ADDRESS || token == ETH_ADDRESS) {
            return who.balance;
        } else {
            return token.balanceOf(who);
        }
    }
}


pragma solidity ^0.5.16;




contract FundsMgrUpgradable is Initializable, OwnableUpgradable {

    using UniversalERC20 for TokenInterface;

    function initialize() initializer public {

        OwnableUpgradable.initialize();  // Initialize Parent Contract
    }

    function withdraw(address token, uint256 amount) onlyOwner public  {

        require(msg.sender == owner);

        if (token == address(0x0)) {
            owner.transfer(amount);
        } else {
            TokenInterface(token).universalTransfer(owner, amount);
        }
    }
    function withdrawAll(address[] memory tokens) onlyOwner public  {

        for(uint256 i = 0; i < tokens.length;i++) {
            withdraw(tokens[i], TokenInterface(tokens[i]).universalBalanceOf(address(this)));
        }
    }

    uint256[50] private ______gap;
}


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.16;

interface DfFinanceMgrInterface {

    function setupCup(address cdpOwner, bytes32 cup, uint256 deposit, uint8 profitPercent, uint256 etherPrice, uint8 feeForBonusEther) external;

}


pragma solidity ^0.5.16;


interface OtcInterface {

    function buyAllAmount(address, uint, address pay_gem, uint) external returns (uint);

    function getSellAmount(TokenInterface dest, TokenInterface src, uint256 srcAmount) external view returns (uint256);

    function getBuyAmount(TokenInterface dest, TokenInterface src, uint256 srcAmount) external view returns (uint256);

}


pragma solidity ^0.5.16;

interface PepInterface {

    function peek() external view returns (bytes32, bool);

    function read() external view returns (bytes32);

}


pragma solidity ^0.5.16;



interface TubInterface {

    function open() external returns (bytes32);

    function join(uint) external;

    function exit(uint) external;

    function lock(bytes32, uint) external;

    function free(bytes32, uint) external;

    function draw(bytes32, uint) external;

    function wipe(bytes32, uint) external;

    function give(bytes32, address) external;

    function shut(bytes32) external;

    function cups(bytes32) external view returns (address, uint, uint, uint);

    function gem() external view returns (TokenInterface);

    function gov() external view returns (TokenInterface);

    function skr() external view returns (TokenInterface);

    function sai() external view returns (TokenInterface);

    function mat() external view returns (uint);

    function ink(bytes32) external view returns (uint);

    function tab(bytes32) external returns (uint);

    function rap(bytes32) external returns (uint);

    function per() external view returns (uint);

    function pep() external view returns (PepInterface);

    function pip() external view returns (PepInterface);

    function ask(uint wad) external view returns (uint);

}


pragma solidity ^0.5.16;

contract AffiliateProgram {

    function addUserUseCode(address user, string memory code) public;

    function getPartnerFromUser(address user) external view returns (address, uint8, uint256, uint256);

    function levels(uint8 level) external view returns (uint16, uint256);

    function addPartnerProfitUseAddress(address partner) external payable;

}


pragma solidity ^0.5.16;


interface ILoanPool {

    function loan(uint _amount) external;

}


pragma solidity ^0.5.16;










interface IDfProxyBet {

    function insure(address beneficiary, bytes32 cup, uint256 amountSai) external;

}

interface IProxyOneInchExchange {

    function exchange(TokenInterface fromToken, uint256 amountFromToken, bytes calldata _data) external;

}

contract DfFinanceMgrOpenCdp is Initializable, DSMath, FundsMgrUpgradable {


    mapping(address => bool) public allowedOtc;

    TubInterface tub;
    AffiliateProgram public aff;

    uint8 public inFee;
    uint8 public currentFeeForBonusEther;

    IDfProxyBet public proxyInsuranceBet;
    uint256 public insuranceCoef;  // in percent

    mapping(address => bool) public admins;
    OtcInterface[] public allOtc;
    DfFinanceMgrInterface public migrateToNewContract;
    uint256 public maxAllowedExtractSaiPercent;
    DfFinanceMgrInterface public dfManagerAddress;


    TokenInterface private constant ETH_ADDRESS = TokenInterface(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);


    function initialize() initializer public {

        FundsMgrUpgradable.initialize();  // Initialize Parent Contract

        tub = TubInterface(0x448a5065aeBB8E423F0896E6c5D525C040f59af3);  // MainNet SaiTub: 0x448a5065aeBB8E423F0896E6c5D525C040f59af3
        inFee = 0;
        currentFeeForBonusEther = 30;
        maxAllowedExtractSaiPercent = 2;

        if (tub.gem().allowance(address(this), address(tub)) != uint256(-1)) {
            tub.gem().approve(address(tub), uint256(-1));
        }

        if (tub.skr().allowance(address(this), address(tub)) != uint256(-1)) {
            tub.skr().approve(address(tub), uint256(-1));
        }
    }

    function setDfManagerAddress(address payable newAddress) onlyOwner public {

        require(newAddress != address(0x0));

        dfManagerAddress = DfFinanceMgrInterface(newAddress);

    }

    function setDfProxyBetAddress(IDfProxyBet proxyBet, uint256 newInsuranceCoef) onlyOwner public {

        require(address(proxyBet) != address(0) && newInsuranceCoef > 0 
            || address(proxyBet) == address(0) && newInsuranceCoef == 0, "Incorrect proxy address or insurance coefficient");

        proxyInsuranceBet = proxyBet;
        insuranceCoef = newInsuranceCoef;  // in percent (5 == 5%)

        tub.sai().approve(address(proxyBet), uint(-1));
    }

    function setLoanPool(address loanAddr) onlyOwner public {

        require(loanAddr != address(0), "Address must not be zero");
        loanPool = ILoanPool(loanAddr);
    }

    function setAffProgram(address newAff) onlyOwner public {

        aff = AffiliateProgram(newAff);
    }

    function changeMaxAllowedExtractSaiPercent(uint256 newPercent) onlyOwner public {

        maxAllowedExtractSaiPercent = newPercent;
    }

    function setAdmin(address newAdmin, bool active) onlyOwner public {

        admins[newAdmin] = active;
    }

    function changeOtc(OtcInterface _newOtc, bool allow) onlyOwner public {

        allowedOtc[address(_newOtc)] = allow;
    }

    function changeFees(uint8 _inFee, uint8 _currentFeeForBonusEther) onlyOwner public {

        require(_inFee <= 5);
        require(_currentFeeForBonusEther < 100);
        inFee = _inFee;
        currentFeeForBonusEther = _currentFeeForBonusEther;
    }

    function priceETH() view public returns (uint256) {

        return uint256(PepInterface(TubInterface(tub).pip()).read());
    }

    function addOtc(OtcInterface newOtc) onlyOwner public {

        allOtc.push(newOtc);
        allowedOtc[address(newOtc)] = true;
    }

    function removeOtc(OtcInterface otcToRemove) onlyOwner public {


        for(uint256 i =0; i < allOtc.length;i++ ) {
            if (allOtc[i] == otcToRemove) {
                allowedOtc[address(otcToRemove)] = false;

                allOtc[i] = allOtc[allOtc.length -1];
                delete allOtc[allOtc.length - 1];
                allOtc.length--;
                break;
            }
        }
    }

    function caluclateAmountSaiFromEth(uint256 wad, uint256 rate) view public returns(uint256) {

        uint256 price = priceETH();

        return wmul(wmul(wdiv(wad, tub.ask(wad)), wad), price) * 100 / rate;
    }

    function exchange(TokenInterface fromToken, uint256 maxFromTokenAmount, TokenInterface toToken, uint256 minToTokenAmount, bytes memory _data) internal returns (uint256)
    {

        IProxyOneInchExchange proxyEx = IProxyOneInchExchange(0x3fF9Cc22ef2bF6de5Fd2E78f511EDdF0813f6B36);

        if (fromToken.allowance(address(this), address(proxyEx)) != uint256(-1)) {
            fromToken.approve(address(proxyEx), uint256(-1));
        }

        uint256 fromTokenBalance = fromToken.universalBalanceOf(address(this));
        uint256 toTokenBalance = toToken.universalBalanceOf(address(this));

        proxyEx.exchange(fromToken, maxFromTokenAmount, _data);

        uint256 newBalanceToToken = toToken.universalBalanceOf(address(this));
        require(fromToken.universalBalanceOf(address(this)) + maxFromTokenAmount >= fromTokenBalance);
        require(newBalanceToToken >= toTokenBalance + minToTokenAmount);

        return sub(newBalanceToToken, toTokenBalance); // how many tokens received
    }

    function openCdpAndDraw(uint256 saiAmount, uint256 ethAmount) internal returns(bytes32 cup)
    {

        cup = tub.open();

        (address lad,,,) = tub.cups(cup);
        require(lad == address(this), "cup-not-owned");

        tub.gem().deposit.value(ethAmount)();

        uint256 ink = rdiv(ethAmount, tub.per());
        ink = rmul(ink, tub.per()) <= ethAmount ? ink : ink - 1;

        tub.join(ink);

        tub.lock(cup, ink);

        tub.draw(cup, saiAmount);
    }


    function findBestOtc(address tokenPay, address tokenNeeded, uint256 amountNeeded) view public returns(OtcInterface bestOtc, uint256 bestAmount) {

        uint256 index = allOtc.length;
        bestOtc = allOtc[index - 1];
        bestAmount = bestOtc.getBuyAmount(TokenInterface(tokenPay), TokenInterface(tokenNeeded), amountNeeded);
        index--;
        while (index > 0) {
            uint256 amount = allOtc[index - 1].getBuyAmount(TokenInterface(tokenPay), TokenInterface(tokenNeeded), amountNeeded);
            if (amount < bestAmount) {
                bestAmount = amount;
                bestOtc = allOtc[index - 1];
            }
            index--;
        }
    }

    function dealWithPromo(address newOwner, uint256 coef, uint8 profitPercent, bytes memory data, string memory code, uint256 saiToBuyEther, uint8 ethType ) public payable returns(bytes32) {

        aff.addUserUseCode(newOwner, code);
        return _deal(newOwner, profitPercent, coef, msg.value, data, saiToBuyEther, ethType);
    }

    function deal(address newOwner, uint256 coef, uint8 profitPercent, bytes memory data, uint256 saiToBuyEther, uint8 ethType) public payable returns(bytes32) {

        return _deal(newOwner, profitPercent, coef, msg.value, data, saiToBuyEther, ethType);
    }

    function dealViaOtc(address newOwner, uint256 coef, uint8 profitPercent, OtcInterface otc, uint256 maxSai) public payable returns(bytes32 cup) {

        cup = _deal_otc(newOwner, coef, msg.value, otc, maxSai);

        tub.give(cup, address(dfManagerAddress));
        dfManagerAddress.setupCup(newOwner, cup, msg.value, profitPercent, priceETH(), currentFeeForBonusEther);
    }

    function _deal(address newOwner, uint8 profitPercent, uint256 coef, uint256 valueEth, bytes memory data, uint256 saiToBuyEther, uint8 ethType) internal returns(bytes32 cup)
    {

        if (newOwner == address(0x0)) newOwner = msg.sender;
        require(coef >= 150 && coef <= 300); // TODO: replace coef >= 125

        uint256 extraEth = valueEth * (coef - 100) / 100;

        uint256 extractSai = saiToBuyEther * (100 + inFee + insuranceCoef) / 100;

        uint256 rate = (caluclateAmountSaiFromEth(valueEth + extraEth, 100) * 100) / extractSai;
        require(rate > 175);

        loanPool.loan(extraEth);

        cup = openCdpAndDraw(extractSai, valueEth + extraEth);

        if (address(proxyInsuranceBet) != address(0)) {
            proxyInsuranceBet.insure(newOwner, cup, saiToBuyEther * insuranceCoef / 100);
        }

        exchange(tub.sai(), saiToBuyEther, ethType == 0 ? tub.gem() : ETH_ADDRESS, extraEth, data);

        if (ethType == 0) tub.gem().withdraw(tub.gem().balanceOf(address(this)));

        transferEthInternal(address(loanPool), extraEth);

        tub.give(cup, address(dfManagerAddress));
        dfManagerAddress.setupCup(newOwner, cup, valueEth, profitPercent, wdiv(saiToBuyEther, extraEth), currentFeeForBonusEther);
    }

    function showmethemoney(uint256 amount) external {

        require(msg.sender == address(dfManagerAddress));
        address(msg.sender).transfer(amount); // send eth to friendly contract, it should return them in the same transaction
    }

    function _deal_otc(address newOwner, uint256 coef, uint256 valueEth, OtcInterface otc, uint256 maxSai) internal returns(bytes32 cup)
    {

        if (newOwner == address(0x0)) newOwner = msg.sender;
        require(coef >= 150 && coef <= 300);

        uint256 extraEth = valueEth * (coef - 100) / 100;

        uint256 fee =  valueEth * inFee / 100; // inFee = 5%

        if (maxSai == 0) {
            maxSai = wmul(priceETH(), extraEth + fee) * (100 + maxAllowedExtractSaiPercent) / 100;
        }

        uint256 saiToBuyEther;
        if (otc == OtcInterface(0x0)) {
            (otc, saiToBuyEther) = findBestOtc(address(tub.sai()), address(tub.gem()), extraEth + fee);
        } else {
            require(allowedOtc[address(otc)]);
            saiToBuyEther = otc.getBuyAmount(tub.sai(), tub.gem(), extraEth + fee);
        }

        if (tub.sai().allowance(address(this), address(otc)) != uint(-1)) {  // TODO: optimize
            tub.sai().approve(address(otc), uint(-1));
        }

        uint256 rate = (caluclateAmountSaiFromEth(valueEth + extraEth, 100) * 100) / saiToBuyEther;
        require(rate > 170);

        require(saiToBuyEther <= maxSai);

        cup = openCdpAndDraw(saiToBuyEther, valueEth + extraEth);

        uint256 balance = tub.gem().balanceOf(address(this));

        otc.buyAllAmount(address(tub.gem()), extraEth, address(tub.sai()), saiToBuyEther);

        uint256 newBalance = tub.gem().balanceOf(address(this));

        require(newBalance >= balance + extraEth); // check that we got ether

        tub.gem().withdraw(newBalance);
    }

    function transferEthInternal(address receiver, uint256 amount) internal {

        address payable receiverPayable = address(uint160(receiver));
        (bool result, ) = receiverPayable.call.value(amount)("");
        require(result, "Transfer of ETH failed");
    }

    function() external payable {

    }

    uint256[50] private ______gap;

    ILoanPool public loanPool;
}