
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

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
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call.value(weiValue)(data);
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


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface CTokenInterface {

    function mint(uint mintAmount) external returns (uint);

    function redeem(uint redeemTokens) external returns (uint);

    function repayBorrow(uint repayAmount) external returns (uint);


    function borrowBalanceCurrent(address) external returns (uint);

    function redeemUnderlying(uint) external returns (uint);

    function borrow(uint) external returns (uint);

    function underlying() external view returns (address);

    function borrowBalanceStored(address) external view returns (uint);

}

interface CETHInterface {

    function mint() external payable;

    function repayBorrow() external payable;

}

interface ComptrollerInterface {

    function getAssetsIn(address account) external view returns (address[] memory);

    function enterMarkets(address[] calldata cTokens) external returns (uint[] memory);

    function exitMarket(address cTokenAddress) external returns (uint);

}

interface AccountInterface {	

    function version() external view returns (uint);	

}

interface ListInterface {

    function accountID(address) external view returns (uint64);

}

interface IndexInterface {

    function master() external view returns (address);

    function list() external view returns (address);

    function isClone(uint, address) external view returns (bool);

}

interface CheckInterface {

    function isOk() external view returns (bool);

}

contract DSMath {

    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x, "sub-overflow");
    }
}

contract Helpers is DSMath {

    using SafeERC20 for IERC20;

    address constant internal instaIndex = 0x2971AdFa57b20E5a416aE5a708A8655A9c74f723;
    address constant internal oldInstaPool = 0x1879BEE186BFfBA9A8b1cAD8181bBFb218A5Aa61;
    
    address constant internal comptrollerAddr = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;

    address constant internal ethAddr = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address constant internal cEth = 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5;

    mapping (address => bool) public isTknAllowed;
    mapping (address => address) public tknToCTkn;

    mapping (address => uint) public borrowedToken;
    address[] public tokensAllowed;

    bool public checkOldPool = true;

    IndexInterface indexContract = IndexInterface(instaIndex);
    ListInterface listContract = ListInterface(indexContract.list());
    CheckInterface oldInstaPoolContract = CheckInterface(oldInstaPool);

    modifier isDSA {

        uint64 id = listContract.accountID(msg.sender);
        require(id != 0, "not-dsa-id");
        require(indexContract.isClone(AccountInterface(msg.sender).version(), msg.sender), "not-dsa-clone");
        _;
    }

    function tokenBal(address token) internal view returns (uint _bal) {

        _bal = token == ethAddr ? address(this).balance : IERC20(token).balanceOf(address(this));
    }

    function _transfer(address token, uint _amt) internal {

        token == ethAddr ?
            msg.sender.transfer(_amt) :
            IERC20(token).safeTransfer(msg.sender, _amt);
    }
}


contract CompoundResolver is Helpers {


    function borrowAndSend(address[] memory tokens, uint[] memory tknAmt) internal {

        if (tokens.length > 0) {
            for (uint i = 0; i < tokens.length; i++) {
                address token = tokens[i];
                address cToken = tknToCTkn[token];
                require(isTknAllowed[token], "token-not-listed");
                if (cToken != address(0) && tknAmt[i] > 0) {
                    require(CTokenInterface(cToken).borrow(tknAmt[i]) == 0, "borrow-failed");
                    borrowedToken[token] += tknAmt[i];
                    _transfer(token, tknAmt[i]);
                }
            }
        }
    }

    function payback(address[] memory tokens) internal {

        if (tokens.length > 0) {
            for (uint i = 0; i < tokens.length; i++) {
                address token = tokens[i];
                address cToken = tknToCTkn[token];
                if (cToken != address(0)) {
                    CTokenInterface ctknContract = CTokenInterface(cToken);
                    if(token != ethAddr) {
                        require(ctknContract.repayBorrow(uint(-1)) == 0, "payback-failed");
                    } else {
                        CETHInterface(cToken).repayBorrow.value(ctknContract.borrowBalanceCurrent(address(this)))();
                        require(ctknContract.borrowBalanceCurrent(address(this)) == 0, "ETH-flashloan-not-paid");
                    }
                    delete borrowedToken[token];
                }
            }
        }
    }
}

contract AccessLiquidity is CompoundResolver {

    event LogPoolBorrow(address indexed user, address[] tknAddr, uint[] amt);
    event LogPoolPayback(address indexed user, address[] tknAddr);

    function accessLiquidity(address[] calldata tokens, uint[] calldata amounts) external isDSA {

        require(tokens.length == amounts.length, "length-not-equal");
        borrowAndSend(tokens, amounts);
        emit LogPoolBorrow(
            msg.sender,
            tokens,
            amounts
        );
    }
   
    function returnLiquidity(address[] calldata tokens) external payable isDSA {

        payback(tokens);
        emit LogPoolPayback(msg.sender, tokens);
    }
    
    function isOk() public view returns(bool ok) {

        ok = true;
        for (uint i = 0; i < tokensAllowed.length; i++) {
            uint tknBorrowed = borrowedToken[tokensAllowed[i]];
            if(tknBorrowed > 0){
                ok = false;
                break;
            }
        }
        if(checkOldPool && ok) {
            bool isOldPoolOk = oldInstaPoolContract.isOk();
            ok = isOldPoolOk;
        }
    }
}


contract ProvideLiquidity is  AccessLiquidity {

    event LogDeposit(address indexed user, address indexed token, uint amount, uint cAmount);
    event LogWithdraw(address indexed user, address indexed token, uint amount, uint cAmount);

    mapping (address => mapping (address => uint)) public liquidityBalance;

    function deposit(address token, uint amt) external payable returns (uint _amt) {

        require(isTknAllowed[token], "token-not-listed");
        require(amt > 0 || msg.value > 0, "amt-not-valid");

        if (msg.value > 0) require(token == ethAddr, "not-eth-addr");

        address cErc20 = tknToCTkn[token];
        uint initalBal = tokenBal(cErc20);
        if (token == ethAddr) {
            _amt = msg.value;
            CETHInterface(cErc20).mint.value(_amt)();
        } else {
            _amt = amt == (uint(-1)) ? IERC20(token).balanceOf(msg.sender) : amt;
            IERC20(token).safeTransferFrom(msg.sender, address(this), _amt);
            require(CTokenInterface(cErc20).mint(_amt) == 0, "mint-failed");
        }
        uint finalBal = tokenBal(cErc20);
        uint ctokenAmt = sub(finalBal, initalBal);

        liquidityBalance[token][msg.sender] += ctokenAmt;

        emit LogDeposit(msg.sender, token, _amt, ctokenAmt);
    }

    
    function withdraw(address token, uint amt) external returns (uint _amt) {

        uint _userLiq = liquidityBalance[token][msg.sender];
        require(_userLiq > 0, "nothing-to-withdraw");

        uint _cAmt;

        address ctoken = tknToCTkn[token];
        if (amt == uint(-1)) {
            uint initknBal = tokenBal(token);
            require(CTokenInterface(ctoken).redeem(_userLiq) == 0, "redeem-failed");
            uint finTknBal = tokenBal(token);
            _cAmt = _userLiq;
            delete liquidityBalance[token][msg.sender];
            _amt = sub(finTknBal, initknBal);
        } else {
            uint iniCtknBal = tokenBal(ctoken);
            require(CTokenInterface(ctoken).redeemUnderlying(amt) == 0, "redeemUnderlying-failed");
            uint finCtknBal = tokenBal(ctoken);
            _cAmt = sub(iniCtknBal, finCtknBal);
            require(_cAmt <= _userLiq, "not-enough-to-withdraw");
            liquidityBalance[token][msg.sender] -= _cAmt;
            _amt = amt;
        }
        
        _transfer(token, _amt);
       
        emit LogWithdraw(msg.sender, token, _amt, _cAmt);
    }

}


contract Controllers is ProvideLiquidity {

    event LogEnterMarket(address[] token, address[] ctoken);
    event LogExitMarket(address indexed token, address indexed ctoken);

    event LogWithdrawMaster(address indexed user, address indexed token, uint amount);

    modifier isMaster {

        require(msg.sender == indexContract.master(), "not-master");
        _;
    }

    function switchOldPoolCheck() external isMaster {

        checkOldPool = !checkOldPool;
    }

    function _enterMarket(address[] memory cTknAddrs) internal {

        ComptrollerInterface(comptrollerAddr).enterMarkets(cTknAddrs);
        address[] memory tknAddrs = new address[](cTknAddrs.length);
        for (uint i = 0; i < cTknAddrs.length; i++) {
            if (cTknAddrs[i] != cEth) {
                tknAddrs[i] = CTokenInterface(cTknAddrs[i]).underlying();
                IERC20(tknAddrs[i]).safeApprove(cTknAddrs[i], uint(-1));
            } else {
                tknAddrs[i] = ethAddr;
            }
            tknToCTkn[tknAddrs[i]] = cTknAddrs[i];
            require(!isTknAllowed[tknAddrs[i]], "tkn-already-allowed");
            isTknAllowed[tknAddrs[i]] = true;
            tokensAllowed.push(tknAddrs[i]);
        }
        emit LogEnterMarket(tknAddrs, cTknAddrs);
    }

    function enterMarket(address[] calldata cTknAddrs) external isMaster {

        _enterMarket(cTknAddrs);
    }

    function exitMarket(address cTkn) external isMaster {

        address tkn;
        if (cTkn != cEth) {
            tkn = CTokenInterface(cTkn).underlying();
            IERC20(tkn).safeApprove(cTkn, 0);
        } else {
            tkn = ethAddr;
        }
        require(isTknAllowed[tkn], "tkn-not-allowed");

        ComptrollerInterface(comptrollerAddr).exitMarket(cTkn);

        delete isTknAllowed[tkn];

        bool isFound = false;
        uint _length = tokensAllowed.length;
        uint _id;
        for (uint i = 0; i < _length; i++) {
            if (tkn == tokensAllowed[i]) {
                isFound = true;
                _id = i;
                break;
            }
        }
        if (isFound) {
            address _last = tokensAllowed[_length - 1];
            tokensAllowed[_length - 1] = tokensAllowed[_id];
            tokensAllowed[_id] = _last;
            tokensAllowed.pop();
        }
        emit LogExitMarket(tkn, cTkn);
    }

    function withdrawMaster(address token, uint amt) external isMaster {

        _transfer(token, amt);
        emit LogWithdrawMaster(msg.sender, token, amt);
    }

    function spell(address _target, bytes calldata _data) external isMaster {

        require(_target != address(0), "target-invalid");
        bytes memory _callData = _data;
        assembly {
            let succeeded := delegatecall(gas(), _target, add(_callData, 0x20), mload(_callData), 0, 0)

            switch iszero(succeeded)
                case 1 {
                    let size := returndatasize()
                    returndatacopy(0x00, 0x00, size)
                    revert(0x00, size)
                }
        }
    }

}


contract InstaPool is Controllers {

    constructor (address[] memory ctkns) public {
        _enterMarket(ctkns);
    }

    receive() external payable {}
}