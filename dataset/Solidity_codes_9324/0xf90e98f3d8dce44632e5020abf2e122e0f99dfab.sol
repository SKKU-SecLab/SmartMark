



pragma solidity >=0.6.0 <0.8.0;

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




pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity >=0.6.0 <0.8.0;

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




pragma solidity >=0.6.0 <0.8.0;




contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}




pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
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




pragma solidity >=0.6.2 <0.8.0;

library Address {
    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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


pragma solidity 0.7.5;


interface IWhitelisted {

    function hasRole(
        bytes32 role,
        address account
    )
        external
        view
        returns (bool);

    function WHITELISTED_ROLE() external view returns(bytes32);
}


pragma solidity 0.7.5;



interface IExchange {

    function swap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 fromAmount,
        uint256 toAmount,
        address exchange,
        bytes calldata payload) external payable returns (uint256);

    function buy(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 fromAmount,
        uint256 toAmount,
        address exchange,
        bytes calldata payload) external payable returns (uint256);

    function onChainSwap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 fromAmount,
        uint256 toAmount
    ) external payable returns (uint256);
}




pragma solidity >=0.6.0 <0.8.0;




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


pragma solidity 0.7.5;


interface ITokenTransferProxy {

    function transferFrom(
        address token,
        address from,
        address to,
        uint256 amount
    )
        external;

    function freeGSTTokens(uint256 tokensToFree) external;
}


pragma solidity 0.7.5;







library Utils {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address constant ETH_ADDRESS = address(
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
    );

    uint256 constant MAX_UINT = 2 ** 256 - 1;

    struct SellData {
        IERC20 fromToken;
        IERC20 toToken;
        uint256 fromAmount;
        uint256 toAmount;
        uint256 expectedAmount;
        address payable beneficiary;
        string referrer;
        Utils.Path[] path;

    }

    struct BuyData {
        IERC20 fromToken;
        IERC20 toToken;
        uint256 fromAmount;
        uint256 toAmount;
        address payable beneficiary;
        string referrer;
        Utils.BuyRoute[] route;
    }

    struct Route {
        address payable exchange;
        address targetExchange;
        uint percent;
        bytes payload;
        uint256 networkFee;//Network fee is associated with 0xv3 trades
    }

    struct Path {
        address to;
        uint256 totalNetworkFee;//Network fee is associated with 0xv3 trades
        Route[] routes;
    }

    struct BuyRoute {
        address payable exchange;
        address targetExchange;
        uint256 fromAmount;
        uint256 toAmount;
        bytes payload;
        uint256 networkFee;//Network fee is associated with 0xv3 trades
    }

    function ethAddress() internal pure returns (address) {return ETH_ADDRESS;}

    function maxUint() internal pure returns (uint256) {return MAX_UINT;}

    function approve(
        address addressToApprove,
        address token,
        uint256 amount
    ) internal {
        if (token != ETH_ADDRESS) {
            IERC20 _token = IERC20(token);

            uint allowance = _token.allowance(address(this), addressToApprove);

            if (allowance < amount) {
                _token.safeApprove(addressToApprove, 0);
                _token.safeIncreaseAllowance(addressToApprove, MAX_UINT);
            }
        }
    }

    function transferTokens(
        address token,
        address payable destination,
        uint256 amount
    )
    internal
    {
        if (amount > 0) {
            if (token == ETH_ADDRESS) {
                destination.call{value: amount}("");
            }
            else {
                IERC20(token).safeTransfer(destination, amount);
            }
        }

    }

    function tokenBalance(
        address token,
        address account
    )
    internal
    view
    returns (uint256)
    {
        if (token == ETH_ADDRESS) {
            return account.balance;
        } else {
            return IERC20(token).balanceOf(account);
        }
    }

    function refundGas(
        address tokenProxy,
        uint256 initialGas,
        uint256 mintPrice
    )
        internal
    {

        uint256 mintBase = 32254;
        uint256 mintToken = 36543;
        uint256 freeBase = 14154;
        uint256 freeToken = 6870;
        uint256 reimburse = 24000;

        uint256 tokens = initialGas.sub(
            gasleft()).add(freeBase).div(reimburse.mul(2).sub(freeToken)
        );

        uint256 mintCost = mintBase.add(tokens.mul(mintToken));
        uint256 freeCost = freeBase.add(tokens.mul(freeToken));
        uint256 maxreimburse = tokens.mul(reimburse);

        uint256 efficiency = maxreimburse.mul(tx.gasprice).mul(100).div(
            mintCost.mul(mintPrice).add(freeCost.mul(tx.gasprice))
        );

        if (efficiency > 100) {
            freeGasTokens(tokenProxy, tokens);
        }
    }

    function freeGasTokens(address tokenProxy, uint256 tokens) internal {

        uint256 tokensToFree = tokens;
        uint256 safeNumTokens = 0;
        uint256 gas = gasleft();

        if (gas >= 27710) {
            safeNumTokens = gas.sub(27710).div(1148 + 5722 + 150);
        }

        if (tokensToFree > safeNumTokens) {
            tokensToFree = safeNumTokens;
        }

        ITokenTransferProxy(tokenProxy).freeGSTTokens(tokensToFree);

    }
}


pragma solidity 0.7.5;

interface IGST2 {

    function freeUpTo(uint256 value) external returns (uint256 freed);

    function freeFromUpTo(address from, uint256 value) external returns (uint256 freed);

    function balanceOf(address who) external view returns (uint256);

    function mint(uint256 value) external;
}


pragma solidity 0.7.5;






contract TokenTransferProxy is Ownable {
    using SafeERC20 for IERC20;

    IGST2 private _gst2;

    address private _gstHolder;

    constructor(address gst2, address gstHolder) public {
        _gst2 = IGST2(gst2);
        _gstHolder = gstHolder;
    }

    function getGSTHolder() external view returns(address) {
        return _gstHolder;
    }

    function getGST() external view returns(address) {
        return address(_gst2);
    }

    function changeGSTTokenHolder(address gstHolder) external onlyOwner {
        _gstHolder = gstHolder;

    }

    function transferFrom(
        address token,
        address from,
        address to,
        uint256 amount
    )
        external
        onlyOwner
    {
        IERC20(token).safeTransferFrom(from, to, amount);
    }

    function freeGSTTokens(uint256 tokensToFree) external onlyOwner {
        _gst2.freeFromUpTo(_gstHolder, tokensToFree);
    }

}


pragma solidity 0.7.5;


interface IPartnerRegistry {

    function getPartnerContract(string calldata referralId) external view returns(address);

    function addPartner(
        string calldata referralId,
        address payable feeWallet,
        uint256 fee,
        uint256 paraswapShare,
        uint256 partnerShare,
        address owner,
        uint256 timelock,
        uint256 maxFee,
        bool positiveSlippageToUser
    )
        external;

    function removePartner(string calldata referralId) external;
}


pragma solidity 0.7.5;


interface IPartner {

    function getReferralId() external view returns(string memory);

    function getFeeWallet() external view returns(address payable);

    function getFee() external view returns(uint256);

    function getPartnerShare() external view returns(uint256);

    function getParaswapShare() external view returns(uint256);

    function changeFeeWallet(address payable feeWallet) external;

    function changeFee(uint256 newFee) external;

    function getPositiveSlippageToUser() external view returns(bool);

    function changePositiveSlippageToUser(bool slippageToUser) external;

    function getPartnerInfo() external view returns(
        address payable feeWallet,
        uint256 fee,
        uint256 partnerShare,
        uint256 paraswapShare,
        bool positiveSlippageToUser
    );
}


pragma solidity 0.7.5;




contract TokenFetcher is Ownable {

    function transferTokens(
        address token,
        address payable destination,
        uint256 amount
    )
        external
        onlyOwner
    {
        Utils.transferTokens(token, destination, amount);
    }
}


pragma solidity 0.7.5;



abstract contract IWETH is IERC20 {
    function deposit() external virtual payable;
    function withdraw(uint256 amount) external virtual;
}


pragma solidity 0.7.5;
pragma experimental ABIEncoderV2;













contract AugustusSwapper is Ownable, TokenFetcher {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    TokenTransferProxy private _tokenTransferProxy;

    bool private _paused;

    IWhitelisted private _whitelisted;

    IPartnerRegistry private _partnerRegistry;
    address payable private _feeWallet;

    string private _version = "2.1.0";
    uint256 private _gasMintPrice;

    event Paused();
    event Unpaused();

    event Swapped(
        address initiator,
        address indexed beneficiary,
        address indexed srcToken,
        address indexed destToken,
        uint256 srcAmount,
        uint256 receivedAmount,
        uint256 expectedAmount,
        string referrer
    );

    event Bought(
        address initiator,
        address indexed beneficiary,
        address indexed srcToken,
        address indexed destToken,
        uint256 srcAmount,
        uint256 receivedAmount,
        string referrer
    );

    event FeeTaken(
        uint256 fee,
        uint256 partnerShare,
        uint256 paraswapShare
    );

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    modifier onlySelf() {
      require(
        msg.sender == address(this),
        "AugustusSwapper: Invalid access"
      );
      _;
    }


  constructor(
        address whitelist,
        address gasToken,
        address partnerRegistry,
        address payable feeWallet,
        address gstHolder
    )
        public
    {

        _partnerRegistry = IPartnerRegistry(partnerRegistry);
        _tokenTransferProxy = new TokenTransferProxy(gasToken, gstHolder);
        _whitelisted = IWhitelisted(whitelist);
        _feeWallet = feeWallet;
        _gasMintPrice = 1;
    }

    receive() external payable {
    }

    function getVersion() external view returns(string memory) {
        return _version;
    }

    function getPartnerRegistry() external view returns(address) {
        return address(_partnerRegistry);
    }

    function getWhitelistAddress() external view returns(address) {
        return address(_whitelisted);
    }

    function getFeeWallet() external view returns(address) {
        return _feeWallet;
    }

    function setFeeWallet(address payable feeWallet) external onlyOwner {
        require(feeWallet != address(0), "Invalid address");
        _feeWallet = feeWallet;
    }

    function getGasMintPrice() external view returns(uint) {
        return _gasMintPrice;
    }

    function setGasMintPrice(uint gasMintPrice) external onlyOwner {
        _gasMintPrice = gasMintPrice;
    }

    function setPartnerRegistry(address partnerRegistry) external onlyOwner {
        require(partnerRegistry != address(0), "Invalid address");
        _partnerRegistry = IPartnerRegistry(partnerRegistry);
    }

    function setWhitelistAddress(address whitelisted) external onlyOwner {
        require(whitelisted != address(0), "Invalid whitelist address");
        _whitelisted = IWhitelisted(whitelisted);
    }

    function getTokenTransferProxy() external view returns (address) {
        return address(_tokenTransferProxy);
    }

    function changeGSTHolder(address gstHolder) external onlyOwner {
        require(gstHolder != address(0), "Invalid address");
        _tokenTransferProxy.changeGSTTokenHolder(gstHolder);
    }

    function paused() external view returns (bool) {
        return _paused;
    }

    function pause() external onlyOwner whenNotPaused {
        _paused = true;
        emit Paused();
    }

    function unpause() external onlyOwner whenPaused {
        _paused = false;
        emit Unpaused();
    }

    function simplBuy(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 fromAmount,
        uint256 toAmount,
        address[] memory callees,
        bytes memory exchangeData,
        uint256[] memory startIndexes,
        uint256[] memory values,
        address payable beneficiary,
        string memory referrer
    )
        external
        payable
        whenNotPaused
    {
        uint receivedAmount = performSimpleSwap(
            fromToken,
            toToken,
            fromAmount,
            toAmount,
            toAmount,//expected amount and to amount are same in case of buy
            callees,
            exchangeData,
            startIndexes,
            values,
            beneficiary,
            referrer
        );

        uint256 remainingAmount = Utils.tokenBalance(
            address(fromToken),
            address(this)
        );

        if (remainingAmount > 0) {
            Utils.transferTokens(address(fromToken), msg.sender, remainingAmount);
        }

        emit Bought(
            msg.sender,
            beneficiary == address(0)?msg.sender:beneficiary,
            address(fromToken),
            address(toToken),
            fromAmount,
            receivedAmount,
            referrer
        );
    }

    function approve(
      address token,
      address to,
      uint256 amount
    )
      external
      onlySelf
    {
      Utils.approve(to, token, amount);
    }


    function simpleSwap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 fromAmount,
        uint256 toAmount,
        uint256 expectedAmount,
        address[] memory callees,
        bytes memory exchangeData,
        uint256[] memory startIndexes,
        uint256[] memory values,
        address payable beneficiary,
        string memory referrer
    )
        public
        payable
        whenNotPaused
        returns (uint256)
    {

        uint receivedAmount = performSimpleSwap(
            fromToken,
            toToken,
            fromAmount,
            toAmount,
            expectedAmount,
            callees,
            exchangeData,
            startIndexes,
            values,
            beneficiary,
            referrer
        );

        emit Swapped(
            msg.sender,
            beneficiary == address(0)?msg.sender:beneficiary,
            address(fromToken),
            address(toToken),
            fromAmount,
            receivedAmount,
            expectedAmount,
            referrer
        );

        return receivedAmount;
    }

    function performSimpleSwap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 fromAmount,
        uint256 toAmount,
        uint256 expectedAmount,
        address[] memory callees,
        bytes memory exchangeData,
        uint256[] memory startIndexes,
        uint256[] memory values,
        address payable beneficiary,
        string memory referrer
    )
        private
        returns (uint256)
    {
        require(toAmount > 0, "toAmount is too low");
        require(callees.length > 0, "No callee provided");
        require(exchangeData.length > 0, "No exchangeData provided");
        require(
            callees.length + 1 == startIndexes.length,
            "Start indexes must be 1 greater then number of callees"
        );

        uint initialGas = gasleft();

        if (address(fromToken) != Utils.ethAddress()) {
            _tokenTransferProxy.transferFrom(
                address(fromToken),
                msg.sender,
                address(this),
                fromAmount
            );
        }

        for (uint256 i = 0; i < callees.length; i++) {
            require(
                callees[i] != address(_tokenTransferProxy),
                "Can not call TokenTransferProxy Contract"
            );

            bool result = externalCall(
                callees[i], //destination
                values[i], //value to send
                startIndexes[i], // start index of call data
                startIndexes[i + 1].sub(startIndexes[i]), // length of calldata
                exchangeData// total calldata
            );
            require(result, "External call failed");
        }

        uint256 receivedAmount = Utils.tokenBalance(
            address(toToken),
            address(this)
        );

        require(
            receivedAmount >= toAmount,
            "Received amount of tokens are less then expected"
        );

        takeFeeAndTransferTokens(
            toToken,
            expectedAmount,
            receivedAmount,
            beneficiary,
            referrer
        );

        if(_gasMintPrice > 0) {
          Utils.refundGas(address(_tokenTransferProxy), initialGas, _gasMintPrice);
        }

        return receivedAmount;
    }

    function withdrawAllWETH(IWETH token) external {
        uint256 amount = token.balanceOf(address(this));
        token.withdraw(amount);
    }

    function multiSwap(
        Utils.SellData memory data
    )
        public
        payable
        whenNotPaused
        returns (uint256)
    {
        require(bytes(data.referrer).length > 0, "Invalid referrer");

        require(data.toAmount > 0, "To amount can not be 0");

        uint256 receivedAmount = performSwap(
            data.fromToken,
            data.toToken,
            data.fromAmount,
            data.toAmount,
            data.path
        );

        takeFeeAndTransferTokens(
            data.toToken,
            data.expectedAmount,
            receivedAmount,
            data.beneficiary,
            data.referrer
        );

        emit Swapped(
            msg.sender,
            data.beneficiary == address(0)?msg.sender:data.beneficiary,
            address(data.fromToken),
            address(data.toToken),
            data.fromAmount,
            receivedAmount,
            data.expectedAmount,
            data.referrer
        );

        return receivedAmount;
    }

    function buy(
        Utils.BuyData memory data
    )
        public
        payable
        whenNotPaused
        returns (uint256)
    {
        require(bytes(data.referrer).length > 0, "Invalid referrer");

        require(data.toAmount > 0, "To amount can not be 0");

        uint256 receivedAmount = performBuy(
            data.fromToken,
            data.toToken,
            data.fromAmount,
            data.toAmount,
            data.route
        );

        takeFeeAndTransferTokens(
            data.toToken,
            data.toAmount,
            receivedAmount,
            data.beneficiary,
            data.referrer
        );

        uint256 remainingAmount = Utils.tokenBalance(
            address(data.fromToken),
            address(this)
        );

        if (remainingAmount > 0) {
            Utils.transferTokens(address(data.fromToken), msg.sender, remainingAmount);
        }

        emit Bought(
            msg.sender,
            data.beneficiary == address(0)?msg.sender:data.beneficiary,
            address(data.fromToken),
            address(data.toToken),
            data.fromAmount,
            receivedAmount,
            data.referrer
        );

        return receivedAmount;
    }

    function takeFeeAndTransferTokens(
        IERC20 toToken,
        uint256 expectedAmount,
        uint256 receivedAmount,
        address payable beneficiary,
        string memory referrer

    )
        private
    {
        uint256 remainingAmount = receivedAmount;

        ( uint256 fee ) = _takeFee(
            toToken,
            receivedAmount,
            expectedAmount,
            referrer
        );
        remainingAmount = receivedAmount.sub(fee);

        if ((remainingAmount > expectedAmount) && fee == 0) {
            uint256 positiveSlippageShare = remainingAmount.sub(expectedAmount).div(2);
            remainingAmount = remainingAmount.sub(positiveSlippageShare);
            Utils.transferTokens(address(toToken), _feeWallet, positiveSlippageShare);
        }



        if (beneficiary == address(0)){
            Utils.transferTokens(address(toToken), msg.sender, remainingAmount);
        }
        else {
            Utils.transferTokens(address(toToken), beneficiary, remainingAmount);
        }

    }

    function externalCall(
        address destination,
        uint256 value,
        uint256 dataOffset,
        uint dataLength,
        bytes memory data
    )
    private
    returns (bool)
    {
        bool result = false;

        assembly {
            let x := mload(0x40)   // "Allocate" memory for output (0x40 is where "free memory" pointer is stored by convention)

            let d := add(data, 32) // First 32 bytes are the padded length of data, so exclude that
            result := call(
                sub(gas(), 34710), // 34710 is the value that solidity is currently emitting
                destination,
                value,
                add(d, dataOffset),
                dataLength, // Size of the input (in bytes) - this is what fixes the padding problem
                x,
                0                  // Output is ignored, therefore the output size is zero
            )
        }
        return result;
    }

    function performSwap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 fromAmount,
        uint256 toAmount,
        Utils.Path[] memory path
    )
        private
        returns(uint256)
    {
        uint initialGas = gasleft();

        require(path.length > 0, "Path not provided for swap");
        require(
            path[path.length - 1].to == address(toToken),
            "Last to token does not match toToken"
        );

        if (address(fromToken) != Utils.ethAddress()) {
            _tokenTransferProxy.transferFrom(
                address(fromToken),
                msg.sender,
                address(this),
                fromAmount
            );
        }

        for (uint i = 0; i < path.length; i++) {
            IERC20 _fromToken = i > 0 ? IERC20(path[i - 1].to) : IERC20(fromToken);
            IERC20 _toToken = IERC20(path[i].to);

            uint _fromAmount = Utils.tokenBalance(address(_fromToken), address(this));
            if (i > 0 && address(_fromToken) == Utils.ethAddress()) {
                _fromAmount = _fromAmount.sub(path[i].totalNetworkFee);
            }

            for (uint j = 0; j < path[i].routes.length; j++) {
                Utils.Route memory route = path[i].routes[j];

                require(
                    _whitelisted.hasRole(_whitelisted.WHITELISTED_ROLE(), route.exchange),
                    "Exchange not whitelisted"
                );

                IExchange dex = IExchange(route.exchange);

                uint fromAmountSlice = _fromAmount.mul(route.percent).div(10000);
                uint256 value = route.networkFee;

                if (j == path[i].routes.length.sub(1)) {
                    uint256 remBal = Utils.tokenBalance(address(_fromToken), address(this));

                    fromAmountSlice = remBal;

                    if (address(_fromToken) == Utils.ethAddress()) {
                        fromAmountSlice = fromAmountSlice.sub(value);
                    }
                }

                if (address(_fromToken) == Utils.ethAddress()) {
                    value = value.add(fromAmountSlice);

                    dex.swap{value: value}(_fromToken, _toToken, fromAmountSlice, 1, route.targetExchange, route.payload);
                }
                else {
                    _fromToken.safeTransfer(route.exchange, fromAmountSlice);

                    dex.swap{value: value}(_fromToken, _toToken, fromAmountSlice, 1, route.targetExchange, route.payload);
                }
            }
        }

        uint256 receivedAmount = Utils.tokenBalance(
            address(toToken),
            address(this)
        );
        require(
            receivedAmount >= toAmount,
            "Received amount of tokens are less then expected"
        );

        if (_gasMintPrice > 0) {
            Utils.refundGas(address(_tokenTransferProxy), initialGas, _gasMintPrice);
        }
        return receivedAmount;
    }

    function performBuy(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 fromAmount,
        uint256 toAmount,
        Utils.BuyRoute[] memory routes
    )
        private
        returns(uint256)
    {
        uint initialGas = gasleft();
        IERC20 _fromToken = fromToken;
        IERC20 _toToken = toToken;

        if (address(_fromToken) != Utils.ethAddress()) {
            _tokenTransferProxy.transferFrom(
                address(_fromToken),
                msg.sender,
                address(this),
                fromAmount
            );
        }

        for (uint j = 0; j < routes.length; j++) {
            Utils.BuyRoute memory route = routes[j];

            require(
                _whitelisted.hasRole(_whitelisted.WHITELISTED_ROLE(), route.exchange),
                "Exchange not whitelisted"
            );
            IExchange dex = IExchange(route.exchange);


            if (address(_fromToken) == Utils.ethAddress()) {
                uint256 value = route.networkFee.add(route.fromAmount);
                dex.buy{value: value}(
                    _fromToken,
                    _toToken,
                    route.fromAmount,
                    route.toAmount,
                    route.targetExchange,
                    route.payload
                );
            }
            else {
                _fromToken.safeTransfer(route.exchange, route.fromAmount);
                dex.buy{value: route.networkFee}(
                    _fromToken,
                    _toToken,
                    route.fromAmount,
                    route.toAmount,
                    route.targetExchange,
                    route.payload
                );
            }
        }

        uint256 receivedAmount = Utils.tokenBalance(
            address(_toToken),
            address(this)
        );
        require(
            receivedAmount >= toAmount,
            "Received amount of tokens are less then expected tokens"
        );

        if (_gasMintPrice > 0) {
            Utils.refundGas(address(_tokenTransferProxy), initialGas, _gasMintPrice);
        }
        return receivedAmount;
    }

    function _takeFee(
        IERC20 toToken,
        uint256 receivedAmount,
        uint256 expectedAmount,
        string memory referrer
    )
        private
        returns(uint256 fee)
    {

        address partnerContract = _partnerRegistry.getPartnerContract(referrer);

        if (partnerContract == address(0)) {
            return (0);
        }

        (
            address payable partnerFeeWallet,
            uint256 feePercent,
            uint256 partnerSharePercent,
            ,
            bool positiveSlippageToUser
        ) = IPartner(partnerContract).getPartnerInfo();

        uint256 partnerShare = 0;
        uint256 paraswapShare = 0;

        if (feePercent <= 50 && receivedAmount > expectedAmount) {
            uint256 halfPositiveSlippage = receivedAmount.sub(expectedAmount).div(2);
            fee = expectedAmount.mul(feePercent).div(10000);
            partnerShare = fee.mul(partnerSharePercent).div(10000);
            paraswapShare = fee.sub(partnerShare);
            paraswapShare = paraswapShare.add(halfPositiveSlippage);

            fee = fee.add(halfPositiveSlippage);

            if (!positiveSlippageToUser) {
                partnerShare = partnerShare.add(halfPositiveSlippage);
                fee = fee.add(halfPositiveSlippage);
            }
        }
        else {
            fee = receivedAmount.mul(feePercent).div(10000);
            partnerShare = fee.mul(partnerSharePercent).div(10000);
            paraswapShare = fee.sub(partnerShare);
        }
        Utils.transferTokens(address(toToken), partnerFeeWallet, partnerShare);
        Utils.transferTokens(address(toToken), _feeWallet, paraswapShare);

        emit FeeTaken(fee, partnerShare, paraswapShare);
        return (fee);
    }
}