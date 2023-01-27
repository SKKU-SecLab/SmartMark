
pragma solidity ^0.7.0;    
pragma experimental ABIEncoderV2;


abstract contract IDSProxy {

    function execute(address _target, bytes memory _data) public payable virtual returns (bytes32);

    function setCache(address _cacheAddr) public payable virtual returns (bool);

    function owner() public view virtual returns (address);
}    



contract DSMath {

    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x + y) >= x, "");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x - y) <= x, "");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require(y == 0 || (z = x * y) / y == x, "");
    }

    function div(uint256 x, uint256 y) internal pure returns (uint256 z) {

        return x / y;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {

        return x <= y ? x : y;
    }

    function max(uint256 x, uint256 y) internal pure returns (uint256 z) {

        return x >= y ? x : y;
    }

    function imin(int256 x, int256 y) internal pure returns (int256 z) {

        return x <= y ? x : y;
    }

    function imax(int256 x, int256 y) internal pure returns (int256 z) {

        return x >= y ? x : y;
    }

    uint256 constant WAD = 10**18;
    uint256 constant RAY = 10**27;

    function wmul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, y), WAD / 2) / WAD;
    }

    function rmul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, y), RAY / 2) / RAY;
    }

    function wdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, WAD), y / 2) / y;
    }

    function rdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, RAY), y / 2) / y;
    }

    function rpow(uint256 x, uint256 n) internal pure returns (uint256 z) {

        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}    



interface IERC20 {

    function totalSupply() external view returns (uint256 supply);


    function balanceOf(address _owner) external view returns (uint256 balance);


    function transfer(address _to, uint256 _value) external returns (bool success);


    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);


    function approve(address _spender, uint256 _value) external returns (bool success);


    function allowance(address _owner, address _spender) external view returns (uint256 remaining);


    function decimals() external view returns (uint256 digits);


    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}    





abstract contract IWETH {
    function allowance(address, address) public virtual returns (uint256);

    function balanceOf(address) public virtual returns (uint256);

    function approve(address, uint256) public virtual;

    function transfer(address, uint256) public virtual returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) public virtual returns (bool);

    function deposit() public payable virtual;

    function withdraw(uint256) public virtual;
}    



interface IExchangeV3 {

    function sell(address _srcAddr, address _destAddr, uint _srcAmount, bytes memory _additionalData) external payable returns (uint);


    function buy(address _srcAddr, address _destAddr, uint _destAmount, bytes memory _additionalData) external payable returns(uint);


    function getSellRate(address _srcAddr, address _destAddr, uint _srcAmount, bytes memory _additionalData) external view returns (uint);


    function getBuyRate(address _srcAddr, address _destAddr, uint _srcAmount, bytes memory _additionalData) external view returns (uint);

}    



abstract contract IDFSRegistry {
 
    function getAddr(bytes32 _id) public view virtual returns (address);

    function addNewContract(
        bytes32 _id,
        address _contractAddr,
        uint256 _waitPeriod
    ) public virtual;

    function startContractChange(bytes32 _id, address _newContractAddr) public virtual;

    function approveContractChange(bytes32 _id) public virtual;

    function cancelContractChange(bytes32 _id) public virtual;

    function changeWaitPeriod(bytes32 _id, uint256 _newWaitPeriod) public virtual;
}    



library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return
            functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
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



library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}    







library SafeERC20 {

    using SafeMath for uint256;
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

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}    



contract AdminVault {

    address public owner;
    address public admin;

    constructor() {
        owner = msg.sender;
        admin = 0x25eFA336886C74eA8E282ac466BdCd0199f85BB9;
    }

    function changeOwner(address _owner) public {

        require(admin == msg.sender, "msg.sender not admin");
        owner = _owner;
    }

    function changeAdmin(address _admin) public {

        require(admin == msg.sender, "msg.sender not admin");
        admin = _admin;
    }

}    








contract AdminAuth {

    using SafeERC20 for IERC20;

    AdminVault public adminVault = AdminVault(0xCCf3d848e08b94478Ed8f46fFead3008faF581fD);

    modifier onlyOwner() {

        require(adminVault.owner() == msg.sender, "msg.sender not owner");
        _;
    }

    modifier onlyAdmin() {

        require(adminVault.admin() == msg.sender, "msg.sender not admin");
        _;
    }

    function withdrawStuckFunds(address _token, address _receiver, uint256 _amount) public onlyOwner {

        if (_token == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
            payable(_receiver).transfer(_amount);
        } else {
            IERC20(_token).safeTransfer(_receiver, _amount);
        }
    }

    function kill() public onlyAdmin {

        selfdestruct(payable(msg.sender));
    }

    function changeAdminVault(address _newAdminVault) public onlyAdmin {

        adminVault = AdminVault(_newAdminVault);
    }
}    





contract ZrxAllowlist is AdminAuth {

    mapping(address => bool) public zrxAllowlist;
    mapping(address => bool) private nonPayableAddrs;

    constructor() {
        zrxAllowlist[0x6958F5e95332D93D21af0D7B9Ca85B8212fEE0A5] = true;
        zrxAllowlist[0x61935CbDd02287B511119DDb11Aeb42F1593b7Ef] = true;
        zrxAllowlist[0xDef1C0ded9bec7F1a1670819833240f027b25EfF] = true;
        zrxAllowlist[0x080bf510FCbF18b91105470639e9561022937712] = true;

        nonPayableAddrs[0x080bf510FCbF18b91105470639e9561022937712] = true;
    }

    function setAllowlistAddr(address _zrxAddr, bool _state) public onlyOwner {

        zrxAllowlist[_zrxAddr] = _state;
    }

    function isZrxAddr(address _zrxAddr) public view returns (bool) {

        return zrxAllowlist[_zrxAddr];
    }

    function addNonPayableAddr(address _nonPayableAddr) public onlyOwner {

        nonPayableAddrs[_nonPayableAddr] = true;
    }

    function removeNonPayableAddr(address _nonPayableAddr) public onlyOwner {

        nonPayableAddrs[_nonPayableAddr] = false;
    }

    function isNonPayableAddr(address _addr) public view returns (bool) {

        return nonPayableAddrs[_addr];
    }
}    



contract DFSExchangeData {


    enum ExchangeType { _, OASIS, KYBER, UNISWAP, ZEROX }

    enum ExchangeActionType { SELL, BUY }

    struct OffchainData {
        address wrapper;
        address exchangeAddr;
        address allowanceTarget;
        uint256 price;
        uint256 protocolFee;
        bytes callData;
    }

    struct ExchangeData {
        address srcAddr;
        address destAddr;
        uint256 srcAmount;
        uint256 destAmount;
        uint256 minPrice;
        uint256 dfsFeeDivider; // service fee divider
        address user; // user to check special fee
        address wrapper;
        bytes wrapperData;
        OffchainData offchainData;
    }

    function packExchangeData(ExchangeData memory _exData) public pure returns(bytes memory) {

        return abi.encode(_exData);
    }

    function unpackExchangeData(bytes memory _data) public pure returns(ExchangeData memory _exData) {

        _exData = abi.decode(_data, (ExchangeData));
    }
}    



contract Discount {

    address public owner;
    mapping(address => CustomServiceFee) public serviceFees;

    uint256 constant MAX_SERVICE_FEE = 400;

    struct CustomServiceFee {
        bool active;
        uint256 amount;
    }

    constructor() {
        owner = msg.sender;
    }

    function isCustomFeeSet(address _user) public view returns (bool) {

        return serviceFees[_user].active;
    }

    function getCustomServiceFee(address _user) public view returns (uint256) {

        return serviceFees[_user].amount;
    }

    function setServiceFee(address _user, uint256 _fee) public {

        require(msg.sender == owner, "Only owner");
        require(_fee >= MAX_SERVICE_FEE || _fee == 0, "Wrong fee value");

        serviceFees[_user] = CustomServiceFee({active: true, amount: _fee});
    }

    function disableServiceFee(address _user) public {

        require(msg.sender == owner, "Only owner");

        serviceFees[_user] = CustomServiceFee({active: false, amount: 0});
    }
}    





contract FeeRecipient is AdminAuth {


    address public wallet;

    constructor(address _newWallet) {
        wallet = _newWallet;
    }

    function getFeeAddr() public view returns (address) {

        return wallet;
    }

    function changeWalletAddr(address _newWallet) public onlyOwner {

        wallet = _newWallet;
    }
}    






contract TokenUtils {

    using SafeERC20 for IERC20;

    address public constant WETH_ADDR = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // mainnet
	address public constant ETH_ADDR = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    function approveToken(address _tokenAddr, address _to, uint _amount) internal {

        if (_tokenAddr == ETH_ADDR) return;
        
        if (IERC20(_tokenAddr).allowance(address(this), _to) < _amount) {
            IERC20(_tokenAddr).safeApprove(_to, _amount);
        }
    }

    function pullTokens(address _token, address _from, uint256 _amount) internal returns (uint) {


        if (_amount == uint(-1)) {
            uint allowance = uint (-1);

            if (_token == ETH_ADDR) {
                allowance = IERC20(_token).allowance(address(this), _from);
            }

            uint balance = getBalance(_token, _from);

            _amount = (balance > allowance) ? allowance : balance;
        }

        if (_from != address(0) && _from != address(this) && _token != ETH_ADDR && _amount != 0) {
            IERC20(_token).safeTransferFrom(_from, address(this), _amount);
        }

        return _amount;
    }

    function withdrawTokens(
        address _token,
        address _to,
        uint256 _amount
    ) internal returns (uint) {

        if (_amount == uint(-1)) {
            _amount = getBalance(_token, address(this));
        }

        if (_to != address(0) && _to != address(this) && _amount != 0) {
            if (_token != ETH_ADDR) {
                IERC20(_token).safeTransfer(_to, _amount);
            } else {
                payable(_to).transfer(_amount);
            }
        }

        return _amount;
    }

    function convertAndDepositToWeth(address _tokenAddr, uint _amount) internal returns (address) {

        if (_tokenAddr == ETH_ADDR) {
            IWETH(WETH_ADDR).deposit{value: _amount}();
            return WETH_ADDR;
        } else {
            return _tokenAddr;
        }
    }

    function withdrawWeth(uint _amount) internal {

        IWETH(WETH_ADDR).withdraw(_amount);
    }

    function getBalance(address _tokenAddr, address _acc) internal view returns (uint) {

        if (_tokenAddr == ETH_ADDR) {
            return _acc.balance;
        } else {
            return IERC20(_tokenAddr).balanceOf(_acc);
        }
    }

    function convertToWeth(address _tokenAddr) internal pure returns (address){

        return _tokenAddr == ETH_ADDR ? WETH_ADDR : _tokenAddr;
    }

    function convertToEth(address _tokenAddr) internal pure returns (address){

        return _tokenAddr == WETH_ADDR ? ETH_ADDR : _tokenAddr;
    }

    function getTokenDecimals(address _token) internal view returns (uint256) {

        if (_token == ETH_ADDR) return 18;

        return IERC20(_token).decimals();
    }
}    







contract DFSExchangeHelper is TokenUtils {

    string public constant ERR_OFFCHAIN_DATA_INVALID = "Offchain data invalid";

    using SafeERC20 for IERC20;

    function sendLeftover(
        address _srcAddr,
        address _destAddr,
        address payable _to
    ) internal {

        withdrawTokens(ETH_ADDR, _to, uint256(-1));

        withdrawTokens(_srcAddr, _to, uint256(-1));
        withdrawTokens(_destAddr, _to, uint256(-1));
    }

    function sliceUint(bytes memory bs, uint256 start) internal pure returns (uint256) {

        require(bs.length >= start + 32, "slicing out of range");

        uint256 x;
        assembly {
            x := mload(add(bs, add(0x20, start)))
        }

        return x;
    }

    function writeUint256(
        bytes memory _b,
        uint256 _index,
        uint256 _input
    ) internal pure {

        if (_b.length < _index + 32) {
            revert(ERR_OFFCHAIN_DATA_INVALID);
        }

        bytes32 input = bytes32(_input);

        _index += 32;

        assembly {
            mstore(add(_b, _index), input)
        }
    }
}    





contract SaverExchangeRegistry is AdminAuth {


	mapping(address => bool) private wrappers;

	constructor() {
		wrappers[0x880A845A85F843a5c67DB2061623c6Fc3bB4c511] = true;
		wrappers[0x4c9B55f2083629A1F7aDa257ae984E03096eCD25] = true;
		wrappers[0x42A9237b872368E1bec4Ca8D26A928D7d39d338C] = true;
	}

	function addWrapper(address _wrapper) public onlyOwner {

		wrappers[_wrapper] = true;
	}

	function removeWrapper(address _wrapper) public onlyOwner {

		wrappers[_wrapper] = false;
	}

	function isWrapper(address _wrapper) public view returns(bool) {

		return wrappers[_wrapper];
	}
}    



  



abstract contract IOffchainWrapper is DFSExchangeData {
    function takeOrder(
        ExchangeData memory _exData,
        ExchangeActionType _type
    ) virtual public payable returns (bool success, uint256);
}    


  












contract DFSExchangeCore is DFSExchangeHelper, DSMath, DFSExchangeData {

    using SafeERC20 for IERC20;

    string public constant ERR_SLIPPAGE_HIT = "Slippage hit";
    string public constant ERR_DEST_AMOUNT_MISSING = "Dest amount missing";
    string public constant ERR_WRAPPER_INVALID = "Wrapper invalid";
    string public constant ERR_NOT_ZEROX_EXCHANGE = "Zerox exchange invalid";

    address public constant DISCOUNT_ADDRESS = 0x1b14E8D511c9A4395425314f849bD737BAF8208F;
    address public constant SAVER_EXCHANGE_REGISTRY = 0x25dd3F51e0C3c3Ff164DDC02A8E4D65Bb9cBB12D;
    address public constant ZRX_ALLOWLIST_ADDR = 0x4BA1f38427b33B8ab7Bb0490200dAE1F1C36823F;

    FeeRecipient public constant feeRecipient =
        FeeRecipient(0x39C4a92Dc506300c3Ea4c67ca4CA611102ee6F2A);

    function _sell(ExchangeData memory exData) internal returns (address, uint256) {

        uint256 amountWithoutFee = exData.srcAmount;
        address wrapper = exData.offchainData.wrapper;
        address originalSrcAddr = exData.srcAddr;
        bool offChainSwapSuccess;

        uint256 destBalanceBefore = getBalance(convertToEth(exData.destAddr), address(this));

        exData.srcAmount -= getFee(
            exData.srcAmount,
            exData.user,
            exData.srcAddr,
            exData.dfsFeeDivider
        );

        exData.srcAddr = convertAndDepositToWeth(exData.srcAddr, exData.srcAmount);

        if (exData.offchainData.price > 0) {
            (offChainSwapSuccess, ) = offChainSwap(exData, ExchangeActionType.SELL);
        }

        if (!offChainSwapSuccess) {
            onChainSwap(exData, ExchangeActionType.SELL);
            wrapper = exData.wrapper;
        }

        withdrawAllWeth();

        uint256 destBalanceAfter = getBalance(convertToEth(exData.destAddr), address(this));
        uint256 amountBought = sub(destBalanceAfter, destBalanceBefore);

        require(amountBought >= wmul(exData.minPrice, exData.srcAmount), ERR_SLIPPAGE_HIT);

        exData.srcAddr = originalSrcAddr;
        exData.srcAmount = amountWithoutFee;

        return (wrapper, amountBought);
    }

    function _buy(ExchangeData memory exData) internal returns (address, uint256) {

        require(exData.destAmount != 0, ERR_DEST_AMOUNT_MISSING);

        uint256 amountWithoutFee = exData.srcAmount;
        address wrapper = exData.offchainData.wrapper;
        address originalSrcAddr = exData.srcAddr;
        uint256 amountSold;
        bool offChainSwapSuccess;

        uint256 destBalanceBefore = getBalance(convertToEth(exData.destAddr), address(this));

        exData.srcAmount -= getFee(
            exData.srcAmount,
            exData.user,
            exData.srcAddr,
            exData.dfsFeeDivider
        );

        exData.srcAddr = convertAndDepositToWeth(exData.srcAddr, exData.srcAmount);

        if (exData.offchainData.price > 0) {
            (offChainSwapSuccess, amountSold) = offChainSwap(exData, ExchangeActionType.BUY);
        }

        if (!offChainSwapSuccess) {
            amountSold = onChainSwap(exData, ExchangeActionType.BUY);
            wrapper = exData.wrapper;
        }

        withdrawAllWeth();

        uint256 destBalanceAfter = getBalance(convertToEth(exData.destAddr), address(this));
        uint256 amountBought = sub(destBalanceAfter, destBalanceBefore);

        require(amountBought >= exData.destAmount, ERR_SLIPPAGE_HIT);

        exData.srcAddr = originalSrcAddr;
        exData.srcAmount = amountWithoutFee;

        return (wrapper, amountSold);
    }

    function offChainSwap(ExchangeData memory _exData, ExchangeActionType _type)
        private
        returns (bool success, uint256)
    {

        if (!ZrxAllowlist(ZRX_ALLOWLIST_ADDR).isZrxAddr(_exData.offchainData.exchangeAddr)) {
            return (false, 0);
        }

        if (
            !SaverExchangeRegistry(SAVER_EXCHANGE_REGISTRY).isWrapper(_exData.offchainData.wrapper)
        ) {
            return (false, 0);
        }

        IERC20(_exData.srcAddr).safeTransfer(_exData.offchainData.wrapper, _exData.srcAmount);

        return
            IOffchainWrapper(_exData.offchainData.wrapper).takeOrder{
                value: _exData.offchainData.protocolFee
            }(_exData, _type);
    }

    function onChainSwap(ExchangeData memory _exData, ExchangeActionType _type)
        internal
        returns (uint256 swapedTokens)
    {

        require(
            SaverExchangeRegistry(SAVER_EXCHANGE_REGISTRY).isWrapper(_exData.wrapper),
            ERR_WRAPPER_INVALID
        );

        IERC20(_exData.srcAddr).safeTransfer(_exData.wrapper, _exData.srcAmount);

        if (_type == ExchangeActionType.SELL) {
            swapedTokens = IExchangeV3(_exData.wrapper).sell(
                _exData.srcAddr,
                _exData.destAddr,
                _exData.srcAmount,
                _exData.wrapperData
            );
        } else {
            swapedTokens = IExchangeV3(_exData.wrapper).buy(
                _exData.srcAddr,
                _exData.destAddr,
                _exData.destAmount,
                _exData.wrapperData
            );
        }
    }

    function withdrawAllWeth() internal {

        uint256 wethBalance = getBalance(WETH_ADDR, address(this));

        if (wethBalance > 0) {
            withdrawWeth(wethBalance);
        }
    }

    function getFee(
        uint256 _amount,
        address _user,
        address _token,
        uint256 _dfsFeeDivider
    ) internal returns (uint256 feeAmount) {

        if (_dfsFeeDivider != 0 && Discount(DISCOUNT_ADDRESS).isCustomFeeSet(_user)) {
            _dfsFeeDivider = Discount(DISCOUNT_ADDRESS).getCustomServiceFee(_user);
        }

        if (_dfsFeeDivider == 0) {
            feeAmount = 0;
        } else {
            feeAmount = _amount / _dfsFeeDivider;

            if (feeAmount > (_amount / 10)) {
                feeAmount = _amount / 10;
            }

            address walletAddr = feeRecipient.getFeeAddr();

            withdrawTokens(_token, walletAddr, feeAmount);
        }
    }

    receive() external payable {}
}    





abstract contract IGasToken is IERC20 {
    function free(uint256 value) public virtual returns (bool success);

    function freeUpTo(uint256 value) public virtual returns (uint256 freed);

    function freeFrom(address from, uint256 value) public virtual returns (bool success);

    function freeFromUpTo(address from, uint256 value) public virtual returns (uint256 freed);
}    





contract GasBurner {

    IGasToken public constant gasToken = IGasToken(0x0000000000b3F879cb30FE243b4Dfee438691c04);
    IGasToken public constant chiToken = IGasToken(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);

    modifier burnGas {

        uint gasBefore = gasleft();

        _;

        uint gasSpent = 21000 + gasBefore - gasleft() + 16 * msg.data.length;
        uint gasTokenAmount = (gasSpent + 14154) / 41130;

        if (gasToken.balanceOf(address(this)) >= gasTokenAmount) {
            gasToken.free(gasTokenAmount);
        } else if (chiToken.balanceOf(address(this)) >= gasTokenAmount) {
            chiToken.free(gasTokenAmount);
        }
    }
}    



contract DefisaverLogger {

    event LogEvent(
        address indexed contractAddress,
        address indexed caller,
        string indexed logName,
        bytes data
    );

    function Log(
        address _contract,
        address _caller,
        string memory _logName,
        bytes memory _data
    ) public {

        emit LogEvent(_contract, _caller, _logName, _data);
    }
}    






contract DFSRegistry is AdminAuth {

    DefisaverLogger public constant logger = DefisaverLogger(
        0x5c55B921f590a89C1Ebe84dF170E655a82b62126
    );

    string public constant ERR_ENTRY_ALREADY_EXISTS = "Entry id already exists";
    string public constant ERR_ENTRY_NON_EXISTENT = "Entry id doesn't exists";
    string public constant ERR_ENTRY_NOT_IN_CHANGE = "Entry not in change process";
    string public constant ERR_WAIT_PERIOD_SHORTER = "New wait period must be bigger";
    string public constant ERR_CHANGE_NOT_READY = "Change not ready yet";
    string public constant ERR_EMPTY_PREV_ADDR = "Previous addr is 0";
    string public constant ERR_ALREADY_IN_CONTRACT_CHANGE = "Already in contract change";
    string public constant ERR_ALREADY_IN_WAIT_PERIOD_CHANGE = "Already in wait period change";

    struct Entry {
        address contractAddr;
        uint256 waitPeriod;
        uint256 changeStartTime;
        bool inContractChange;
        bool inWaitPeriodChange;
        bool exists;
    }

    mapping(bytes32 => Entry) public entries;
    mapping(bytes32 => address) public previousAddresses;

    mapping(bytes32 => address) public pendingAddresses;
    mapping(bytes32 => uint256) public pendingWaitTimes;

    function getAddr(bytes32 _id) public view returns (address) {

        return entries[_id].contractAddr;
    }

    function isRegistered(bytes32 _id) public view returns (bool) {

        return entries[_id].exists;
    }


    function addNewContract(
        bytes32 _id,
        address _contractAddr,
        uint256 _waitPeriod
    ) public onlyOwner {

        require(!entries[_id].exists, ERR_ENTRY_ALREADY_EXISTS);

        entries[_id] = Entry({
            contractAddr: _contractAddr,
            waitPeriod: _waitPeriod,
            changeStartTime: 0,
            inContractChange: false,
            inWaitPeriodChange: false,
            exists: true
        });

        previousAddresses[_id] = _contractAddr;

        logger.Log(
            address(this),
            msg.sender,
            "AddNewContract",
            abi.encode(_id, _contractAddr, _waitPeriod)
        );
    }

    function revertToPreviousAddress(bytes32 _id) public onlyOwner {

        require(entries[_id].exists, ERR_ENTRY_NON_EXISTENT);
        require(previousAddresses[_id] != address(0), ERR_EMPTY_PREV_ADDR);

        address currentAddr = entries[_id].contractAddr;
        entries[_id].contractAddr = previousAddresses[_id];

        logger.Log(
            address(this),
            msg.sender,
            "RevertToPreviousAddress",
            abi.encode(_id, currentAddr, previousAddresses[_id])
        );
    }

    function startContractChange(bytes32 _id, address _newContractAddr) public onlyOwner {

        require(entries[_id].exists, ERR_ENTRY_NON_EXISTENT);
        require(!entries[_id].inWaitPeriodChange, ERR_ALREADY_IN_WAIT_PERIOD_CHANGE);

        entries[_id].changeStartTime = block.timestamp; // solhint-disable-line
        entries[_id].inContractChange = true;

        pendingAddresses[_id] = _newContractAddr;

        logger.Log(
            address(this),
            msg.sender,
            "StartContractChange",
            abi.encode(_id, entries[_id].contractAddr, _newContractAddr)
        );
    }

    function approveContractChange(bytes32 _id) public onlyOwner {

        require(entries[_id].exists, ERR_ENTRY_NON_EXISTENT);
        require(entries[_id].inContractChange, ERR_ENTRY_NOT_IN_CHANGE);
        require(
            block.timestamp >= (entries[_id].changeStartTime + entries[_id].waitPeriod), // solhint-disable-line
            ERR_CHANGE_NOT_READY
        );

        address oldContractAddr = entries[_id].contractAddr;
        entries[_id].contractAddr = pendingAddresses[_id];
        entries[_id].inContractChange = false;
        entries[_id].changeStartTime = 0;

        pendingAddresses[_id] = address(0);
        previousAddresses[_id] = oldContractAddr;

        logger.Log(
            address(this),
            msg.sender,
            "ApproveContractChange",
            abi.encode(_id, oldContractAddr, entries[_id].contractAddr)
        );
    }

    function cancelContractChange(bytes32 _id) public onlyOwner {

        require(entries[_id].exists, ERR_ENTRY_NON_EXISTENT);
        require(entries[_id].inContractChange, ERR_ENTRY_NOT_IN_CHANGE);

        address oldContractAddr = pendingAddresses[_id];

        pendingAddresses[_id] = address(0);
        entries[_id].inContractChange = false;
        entries[_id].changeStartTime = 0;

        logger.Log(
            address(this),
            msg.sender,
            "CancelContractChange",
            abi.encode(_id, oldContractAddr, entries[_id].contractAddr)
        );
    }

    function startWaitPeriodChange(bytes32 _id, uint256 _newWaitPeriod) public onlyOwner {

        require(entries[_id].exists, ERR_ENTRY_NON_EXISTENT);
        require(!entries[_id].inContractChange, ERR_ALREADY_IN_CONTRACT_CHANGE);

        pendingWaitTimes[_id] = _newWaitPeriod;

        entries[_id].changeStartTime = block.timestamp; // solhint-disable-line
        entries[_id].inWaitPeriodChange = true;

        logger.Log(
            address(this),
            msg.sender,
            "StartWaitPeriodChange",
            abi.encode(_id, _newWaitPeriod)
        );
    }

    function approveWaitPeriodChange(bytes32 _id) public onlyOwner {

        require(entries[_id].exists, ERR_ENTRY_NON_EXISTENT);
        require(entries[_id].inWaitPeriodChange, ERR_ENTRY_NOT_IN_CHANGE);
        require(
            block.timestamp >= (entries[_id].changeStartTime + entries[_id].waitPeriod), // solhint-disable-line
            ERR_CHANGE_NOT_READY
        );

        uint256 oldWaitTime = entries[_id].waitPeriod;
        entries[_id].waitPeriod = pendingWaitTimes[_id];
        
        entries[_id].inWaitPeriodChange = false;
        entries[_id].changeStartTime = 0;

        pendingWaitTimes[_id] = 0;

        logger.Log(
            address(this),
            msg.sender,
            "ApproveWaitPeriodChange",
            abi.encode(_id, oldWaitTime, entries[_id].waitPeriod)
        );
    }

    function cancelWaitPeriodChange(bytes32 _id) public onlyOwner {

        require(entries[_id].exists, ERR_ENTRY_NON_EXISTENT);
        require(entries[_id].inWaitPeriodChange, ERR_ENTRY_NOT_IN_CHANGE);

        uint256 oldWaitPeriod = pendingWaitTimes[_id];

        pendingWaitTimes[_id] = 0;
        entries[_id].inWaitPeriodChange = false;
        entries[_id].changeStartTime = 0;

        logger.Log(
            address(this),
            msg.sender,
            "CancelWaitPeriodChange",
            abi.encode(_id, oldWaitPeriod, entries[_id].waitPeriod)
        );
    }
}    


  



abstract contract ActionBase {
    address public constant REGISTRY_ADDR = 0xB0e1682D17A96E8551191c089673346dF7e1D467;
    DFSRegistry public constant registry = DFSRegistry(REGISTRY_ADDR);

    DefisaverLogger public constant logger = DefisaverLogger(
        0x5c55B921f590a89C1Ebe84dF170E655a82b62126
    );

    string public constant ERR_SUB_INDEX_VALUE = "Wrong sub index value";
    string public constant ERR_RETURN_INDEX_VALUE = "Wrong return index value";

    uint8 public constant SUB_MIN_INDEX_VALUE = 128;
    uint8 public constant SUB_MAX_INDEX_VALUE = 255;

    uint8 public constant RETURN_MIN_INDEX_VALUE = 1;
    uint8 public constant RETURN_MAX_INDEX_VALUE = 127;

    uint8 public constant NO_PARAM_MAPPING = 0;

    enum ActionType { FL_ACTION, STANDARD_ACTION, CUSTOM_ACTION }

    function executeAction(
        bytes[] memory _callData,
        bytes[] memory _subData,
        uint8[] memory _paramMapping,
        bytes32[] memory _returnValues
    ) public payable virtual returns (bytes32);

    function executeActionDirect(bytes[] memory _callData) public virtual payable;

    function actionType() public pure virtual returns (uint8);



    function _parseParamUint(
        uint _param,
        uint8 _mapType,
        bytes[] memory _subData,
        bytes32[] memory _returnValues
    ) internal pure returns (uint) {
        if (isReplacable(_mapType)) {
            if (isReturnInjection(_mapType)) {
                _param = uint(_returnValues[getReturnIndex(_mapType)]);
            } else {
                _param = abi.decode(_subData[getSubIndex(_mapType)], (uint));
            }
        }

        return _param;
    }


    function _parseParamAddr(
        address _param,
        uint8 _mapType,
        bytes[] memory _subData,
        bytes32[] memory _returnValues
    ) internal pure returns (address) {
        if (isReplacable(_mapType)) {
            if (isReturnInjection(_mapType)) {
                _param = address(bytes20((_returnValues[getReturnIndex(_mapType)])));
            } else {
                _param = abi.decode(_subData[getSubIndex(_mapType)], (address));
            }
        }

        return _param;
    }

    function _parseParamABytes32(
        bytes32 _param,
        uint8 _mapType,
        bytes[] memory _subData,
        bytes32[] memory _returnValues
    ) internal pure returns (bytes32) {
        if (isReplacable(_mapType)) {
            if (isReturnInjection(_mapType)) {
                _param = (_returnValues[getReturnIndex(_mapType)]);
            } else {
                _param = abi.decode(_subData[getSubIndex(_mapType)], (bytes32));
            }
        }

        return _param;
    }

    function isReplacable(uint8 _type) internal pure returns (bool) {
        return _type != NO_PARAM_MAPPING;
    }

    function isReturnInjection(uint8 _type) internal pure returns (bool) {
        return (_type >= RETURN_MIN_INDEX_VALUE) && (_type <= RETURN_MAX_INDEX_VALUE);
    }

    function getReturnIndex(uint8 _type) internal pure returns (uint8) {
        require(isReturnInjection(_type), ERR_SUB_INDEX_VALUE);

        return (_type - RETURN_MIN_INDEX_VALUE);
    }

    function getSubIndex(uint8 _type) internal pure returns (uint8) {
        require(_type >= SUB_MIN_INDEX_VALUE, ERR_RETURN_INDEX_VALUE);

        return (_type - SUB_MIN_INDEX_VALUE);
    }
}    


  






contract DFSSell is ActionBase, DFSExchangeCore, GasBurner {


    uint internal constant RECIPIE_FEE = 400;
    uint internal constant DIRECT_FEE = 800;

    function executeAction(
        bytes[] memory _callData,
        bytes[] memory _subData,
        uint8[] memory _paramMapping,
        bytes32[] memory _returnValues
    ) public override payable returns (bytes32) {

        (ExchangeData memory exchangeData, address from, address to) = parseInputs(_callData);

        exchangeData.srcAddr = _parseParamAddr(
            exchangeData.srcAddr,
            _paramMapping[0],
            _subData,
            _returnValues
        );
        exchangeData.destAddr = _parseParamAddr(
            exchangeData.destAddr,
            _paramMapping[1],
            _subData,
            _returnValues
        );

        exchangeData.srcAmount = _parseParamUint(
            exchangeData.srcAmount,
            _paramMapping[2],
            _subData,
            _returnValues
        );
        from = _parseParamAddr(from, _paramMapping[3], _subData, _returnValues);
        to = _parseParamAddr(to, _paramMapping[4], _subData, _returnValues);

        uint256 exchangedAmount = _dfsSell(exchangeData, from, to, RECIPIE_FEE);

        return bytes32(exchangedAmount);
    }

    function executeActionDirect(bytes[] memory _callData) public override payable burnGas {

        (ExchangeData memory exchangeData, address from, address to) = parseInputs(_callData);

        _dfsSell(exchangeData, from, to, DIRECT_FEE);
    }

    function actionType() public override pure returns (uint8) {

        return uint8(ActionType.STANDARD_ACTION);
    }



    function _dfsSell(
        ExchangeData memory exchangeData,
        address _from,
        address _to,
        uint _fee
    ) internal returns (uint256) {


        pullTokens(exchangeData.srcAddr, _from, exchangeData.srcAmount);

        exchangeData.user = getUserAddress();
        exchangeData.dfsFeeDivider = _fee;

        (address wrapper, uint256 exchangedAmount) = _sell(exchangeData);

        withdrawTokens(exchangeData.destAddr, _to, exchangedAmount);

        logger.Log(
            address(this),
            msg.sender,
            "DfsSell",
            abi.encode(
                wrapper,
                exchangeData.srcAddr,
                exchangeData.destAddr,
                exchangeData.srcAmount,
                exchangedAmount
            )
        );

        return exchangedAmount;
    }

    function parseInputs(bytes[] memory _callData)
        public
        pure
        returns (
            ExchangeData memory exchangeData,
            address from,
            address to
        )
    {

        exchangeData = unpackExchangeData(_callData[0]);

        from = abi.decode(_callData[1], (address));
        to = abi.decode(_callData[2], (address));
    }

    function getUserAddress() internal view returns (address) {

        IDSProxy proxy = IDSProxy(payable(address(this)));

        return proxy.owner();
    }
}