
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

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
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}// MIT

pragma solidity ^0.8.0;

library Address {
    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
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
}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {
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
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

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
}//Unlicense
pragma solidity ^0.8.6;
pragma experimental ABIEncoderV2;

interface IRouterProxy {

    event FeeSet(address token_, uint256 oldFee_, uint256 newFee_);
    event RouterAddressSet(address oldRouter_, address newRouter_);
    event AlbtAddressSet(address oldAlbt_, address newAlbt_);
    event ProxyLock(address feeToken_, uint8 targetChain_, address nativeToken_, uint256 amount_, bytes receiver_);
    event ProxyBurn(address feeToken_, address wrappedToken_, uint256 amount_, bytes receiver_);
    event ProxyBurnAndTransfer(address feeToken_, uint8 targetChain_, address wrappedToken_, uint256 amount_, bytes receiver_);
    event FeeCollected(address token_, uint256 amount_);
    event TokensClaimed(address token_, uint256 amount_);
    event CurrencyClaimed(uint256 amount);
    event BridgeAirdrop(uint256 amount_);

    function setFee(address tokenAddress_, uint256 fee_) external;

    function setRouterAddress(address routerAddress_) external;

    function setAlbtToken(address albtToken_) external;

    function lock(address feeToken_, uint8 targetChain_, address nativeToken_, uint256 amount_, bytes calldata receiver_) external payable;

    function lockWithPermit(
        address feeToken_,
        uint8 targetChain_,
        address nativeToken_,
        uint256 amount_,
        bytes calldata receiver_,
        uint256 deadline_,
        uint8 v_,
        bytes32 r_,
        bytes32 s_
    ) external payable;

    function burn(address feeToken_, address wrappedToken_, uint256 amount_, bytes calldata receiver_) external payable;

    function burnWithPermit(
        address feeToken_,
        address wrappedToken_,
        uint256 amount_,
        bytes calldata receiver_,
        uint256 deadline_,
        uint8 v_,
        bytes32 r_,
        bytes32 s_
    ) external payable;

    function burnAndTransfer(address feeToken_, uint8 targetChain_, address wrappedToken_, uint256 amount_, bytes calldata receiver_)
        external payable;

    function burnAndTransferWithPermit(
        address feeToken_,
        uint8 targetChain_,
        address wrappedToken_,
        uint256 amount_,
        bytes calldata receiver_,
        uint256 deadline_,
        uint8 v_,
        bytes32 r_,
        bytes32 s_
    ) external payable;

    function claimTokens(address tokenAddress_) external;
    function claimCurrency() external;

    function bridgeAirdrop() external payable;

}// Unlicense
pragma solidity ^0.8.6;

interface IDiamondCut {
    enum FacetCutAction {Add, Replace, Remove}

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata,
        bytes[] memory _signatures
    ) external;

    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);
}// Unlicense
pragma solidity ^0.8.6;

interface IDiamondLoupe {

    struct Facet {
        address facetAddress;
        bytes4[] functionSelectors;
    }

    function facets() external view returns (Facet[] memory facets_);

    function facetFunctionSelectors(address _facet) external view returns (bytes4[] memory facetFunctionSelectors_);

    function facetAddresses() external view returns (address[] memory facetAddresses_);

    function facetAddress(bytes4 _functionSelector) external view returns (address facetAddress_);
}//Unlicense
pragma solidity ^0.8.6;

interface IFeeCalculator {
    event ServiceFeeSet(address account, uint256 newServiceFee);
    event Claim(address member, uint256 amount);

    function initFeeCalculator(uint256 _serviceFee) external;

    function serviceFee() external view returns (uint256);

    function setServiceFee(uint256 _serviceFee, bytes[] calldata _signatures) external;

    function feesAccrued() external view returns (uint256);

    function previousAccrued() external view returns (uint256);

    function accumulator() external view returns (uint256);

    function claimedRewardsPerAccount(address _account) external view returns (uint256);

    function claim() external;
}//Unlicense
pragma solidity ^0.8.6;

interface IFeeExternal {
    event ExternalFeeSet(address account, uint256 newExternalFee);
    event ExternalFeeAddressSet(address account, address newExternalFeeAddress);

    function initFeeExternal(uint256 _externalFee, address _externalFeeAddress) external;
    function externalFee() external view returns (uint256);
    function externalFeeAddress() external view returns (address);
    function setExternalFee(uint256 _externalFee, bytes[] calldata _signatures) external;
    function setExternalFeeAddress(address _externalFeeAddress, bytes[] calldata _signatures) external;

}// Unlicense
pragma solidity ^0.8.6;

library LibRouter {
    bytes32 constant STORAGE_POSITION = keccak256("router.storage");

    struct NativeTokenWithChainId {
        uint8 chainId;
        bytes token;
    }

    struct Storage {
        bool initialized;

        mapping(uint8 => mapping(bytes => address)) nativeToWrappedToken;

        mapping(address => NativeTokenWithChainId) wrappedToNativeToken;

        mapping(uint8 => mapping(bytes32 => bool)) hashesUsed;

        address albtToken;

        uint8 chainId;
    }

    function routerStorage() internal pure returns (Storage storage ds) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}//Unlicense
pragma solidity ^0.8.6;


struct WrappedTokenParams {
    string name;
    string symbol;
    uint8 decimals;
}

interface IRouter {
    event Lock(uint8 targetChain, address token, bytes receiver, uint256 amount, uint256 serviceFee);
    event Burn(address token, uint256 amount, bytes receiver);
    event BurnAndTransfer(uint8 targetChain, address token, uint256 amount, bytes receiver);
    event Unlock(address token, uint256 amount, address receiver);
    event Mint(address token, uint256 amount, address receiver);
    event WrappedTokenDeployed(uint8 sourceChain, bytes nativeToken, address wrappedToken);
    event Fees(uint256 serviceFee, uint256 externalFee);

    function initRouter(uint8 _chainId, address _albtToken) external;
    function nativeToWrappedToken(uint8 _chainId, bytes memory _nativeToken) external view returns (address);
    function wrappedToNativeToken(address _wrappedToken) external view returns (LibRouter.NativeTokenWithChainId memory);
    function hashesUsed(uint8 _chainId, bytes32 _ethHash) external view returns (bool);
    function albtToken() external view returns (address);
    function lock(uint8 _targetChain, address _nativeToken, uint256 _amount, bytes memory _receiver) external;

    function lockWithPermit(
        uint8 _targetChain,
        address _nativeToken,
        uint256 _amount,
        bytes memory _receiver,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;

    function unlock(
        uint8 _sourceChain,
        bytes memory _transactionId,
        address _nativeToken,
        uint256 _amount,
        address _receiver,
        bytes[] calldata _signatures
    ) external;

    function burn(address _wrappedToken, uint256 _amount, bytes memory _receiver) external;

    function burnWithPermit(
        address _wrappedToken,
        uint256 _amount,
        bytes memory _receiver,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;

    function burnAndTransfer(uint8 _targetChain, address _wrappedToken, uint256 _amount, bytes memory _receiver) external;

    function burnAndTransferWithPermit(
        uint8 _targetChain,
        address _wrappedToken,
        uint256 _amount,
        bytes memory _receiver,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;

    function mint(
        uint8 _nativeChain,
        bytes memory _nativeToken,
        bytes memory _transactionId,
        uint256 _amount,
        address _receiver,
        bytes[] calldata _signatures,
        WrappedTokenParams memory _tokenParams
    ) external;
}//Unlicense
pragma solidity ^0.8.6;

interface IGovernance {
    event MemberUpdated(address member, bool status);

    function initGovernance(address[] memory _members) external;

    function updateMember(address _account, bool _status, bytes[] calldata _signatures) external;

    function isMember(address _member) external view returns (bool);

    function membersCount() external view returns (uint256);

    function memberAt(uint256 _index) external view returns (address);

    function administrativeNonce() external view returns (uint256);
}// Unlicense
pragma solidity ^0.8.6;

interface IUtility {
    enum TokenAction {Pause, Unpause}

    function pauseToken(address _tokenAddress, bytes[] calldata _signatures) external;
    function unpauseToken(address _tokenAddress, bytes[] calldata _signatures) external;

    function setWrappedToken(uint8 _nativeChainId, bytes memory _nativeToken, address _wrappedToken, bytes[] calldata _signatures) external;
    function unsetWrappedToken(address _wrappedToken, bytes[] calldata _signatures) external;

    event TokenPause(address _account, address _token);
    event TokenUnpause(address _account, address _token);
    event WrappedTokenSet(uint8 _nativeChainId, bytes _nativeToken, address _wrappedToken);
    event WrappedTokenUnset(address _wrappedToken);
}//Unlicense
pragma solidity ^0.8.6;


interface IRouterDiamond is IGovernance, IDiamondCut, IDiamondLoupe, IFeeCalculator, IFeeExternal, IUtility, IRouter {}//Unlicense
pragma solidity ^0.8.6;

interface IERC2612Permit {
    function permit(
        address _owner,
        address _spender,
        uint256 _amount,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;

    function nonces(address _owner) external view returns (uint256);
}//Unlicense
pragma solidity ^0.8.6;



contract RouterProxy is IRouterProxy, ERC20, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    address public routerAddress;
    address public albtToken;
    mapping(address => uint256) public feeAmountByToken;
    uint8 private immutable _decimals;

    constructor(
        address routerAddress_, address albtToken_, string memory tokenName_, string memory tokenSymbol_, uint8 decimals_
    ) ERC20(tokenName_, tokenSymbol_) {
        require(routerAddress_ != address(0), "Router address must be non-zero");
        require(albtToken_ != address(0), "ALBT address must be non-zero");
        routerAddress = routerAddress_;
        albtToken = albtToken_;
        _decimals = decimals_;
    }

    function setFee(address tokenAddress_, uint256 fee_) external override onlyOwner {
        emit FeeSet(tokenAddress_, feeAmountByToken[tokenAddress_], fee_);
        feeAmountByToken[tokenAddress_] = fee_;
    }

    function _fee(address tokenAddress_) view internal virtual returns (uint256) {
        require(feeAmountByToken[tokenAddress_] > 0, "Unsupported token");
        return feeAmountByToken[tokenAddress_];
    }

    function setRouterAddress(address routerAddress_) external override onlyOwner {
        emit RouterAddressSet(routerAddress, routerAddress_);
        routerAddress = routerAddress_;
    }

    function setAlbtToken(address albtToken_) external override onlyOwner {
        emit AlbtAddressSet(albtToken, albtToken_);
        albtToken = albtToken_;
    }

    function _isNativeCurrency(address tokenAddress_) internal view returns(bool) {
        return tokenAddress_ == address(this);
    }

    function _setupProxyPayment(address feeToken_, address transferToken_, uint256 amount_) internal nonReentrant {
        uint256 currencyLeft = msg.value;
        bool isTransferTokenNativeCurrency = _isNativeCurrency(transferToken_);

        if (isTransferTokenNativeCurrency) {
            require(currencyLeft >= amount_, "Not enough funds sent to transfer");
            currencyLeft -= amount_;
            _mint(address(this), amount_);
        }
        else {
            IERC20(transferToken_).safeTransferFrom(msg.sender, address(this), amount_);
        }

        uint256 feeOwed = _fee(feeToken_);
        if (_isNativeCurrency(feeToken_)) {
            require(currencyLeft >= feeOwed, "Not enough funds sent to pay the fee");
            currencyLeft -= feeOwed;

            (bool success, bytes memory returndata) = owner().call{value: feeOwed}("");
            require(success, string(returndata));
        }
        else {
            IERC20(feeToken_).safeTransferFrom(msg.sender, owner(), feeOwed);
        }
        emit FeeCollected(feeToken_, feeOwed);

        uint256 albtApproveAmount = IRouterDiamond(routerAddress).serviceFee() + IRouterDiamond(routerAddress).externalFee();
        if (transferToken_ == albtToken) {
            albtApproveAmount += amount_;
        }
        else if (isTransferTokenNativeCurrency) {
            _approve(address(this), routerAddress, amount_);
        }
        else {
            IERC20(transferToken_).approve(routerAddress, amount_);
        }
        IERC20(albtToken).approve(routerAddress, albtApproveAmount);

        if (currencyLeft > 0) {
            (bool success, bytes memory returndata) = msg.sender.call{value: currencyLeft}("");
            require(success, string(returndata));
        }
    }

    function lock(
        address feeToken_,
        uint8 targetChain_,
        address nativeToken_,
        uint256 amount_,
        bytes calldata receiver_
    ) public override payable {
        _setupProxyPayment(feeToken_, nativeToken_, amount_);
        IRouterDiamond(routerAddress).lock(targetChain_, nativeToken_, amount_, receiver_);
        emit ProxyLock(feeToken_, targetChain_, nativeToken_, amount_, receiver_);
    }

    function lockWithPermit(
        address feeToken_,
        uint8 targetChain_,
        address nativeToken_,
        uint256 amount_,
        bytes calldata receiver_,
        uint256 deadline_,
        uint8 v_,
        bytes32 r_,
        bytes32 s_
    ) external override payable {
        IERC2612Permit(nativeToken_).permit(msg.sender, address(this), amount_, deadline_, v_, r_, s_);
        lock(feeToken_, targetChain_, nativeToken_, amount_, receiver_);
    }

    function burn(
        address feeToken_, address wrappedToken_, uint256 amount_, bytes memory receiver_
    ) public override payable {
        _setupProxyPayment(feeToken_, wrappedToken_, amount_);
        IRouterDiamond(routerAddress).burn(wrappedToken_, amount_, receiver_);
        emit ProxyBurn(feeToken_, wrappedToken_, amount_, receiver_);
    }

    function burnWithPermit(
        address feeToken_,
        address wrappedToken_,
        uint256 amount_,
        bytes calldata receiver_,
        uint256 deadline_,
        uint8 v_,
        bytes32 r_,
        bytes32 s_
    ) external override payable {
        IERC2612Permit(wrappedToken_).permit(msg.sender, address(this), amount_, deadline_, v_, r_, s_);
        burn(feeToken_, wrappedToken_, amount_, receiver_);
    }

    function burnAndTransfer(
        address feeToken_,
        uint8 targetChain_,
        address wrappedToken_,
        uint256 amount_,
        bytes calldata receiver_
    ) public override payable {
        _setupProxyPayment(feeToken_, wrappedToken_, amount_);
        IRouterDiamond(routerAddress).burnAndTransfer(targetChain_, wrappedToken_, amount_, receiver_);
        emit ProxyBurnAndTransfer(feeToken_, targetChain_, wrappedToken_, amount_, receiver_);
    }

    function burnAndTransferWithPermit(
        address feeToken_,
        uint8 targetChain_,
        address wrappedToken_,
        uint256 amount_,
        bytes calldata receiver_,
        uint256 deadline_,
        uint8 v_,
        bytes32 r_,
        bytes32 s_
    ) external override payable {
        IERC2612Permit(wrappedToken_).permit(msg.sender, address(this), amount_, deadline_, v_, r_, s_);
        burnAndTransfer(feeToken_, targetChain_, wrappedToken_, amount_, receiver_);
    }

    function transfer(address recipient_, uint256 amount_) public override returns (bool) {
        bool success = false;

        if (msg.sender == routerAddress) {
            bytes memory returndata;

            _burn(msg.sender, amount_);
            (success, returndata) = recipient_.call{value: amount_}("");
            require(success, string(returndata));
        }

        return success;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function claimTokens(address tokenAddress_) external override onlyOwner {
        uint256 amount = IERC20(tokenAddress_).balanceOf(address(this));
        IERC20(tokenAddress_).safeTransfer(owner(), amount);
        emit TokensClaimed(tokenAddress_, amount);
    }

    function claimCurrency() external override onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, bytes memory returndata) = owner().call{value: amount}("");
        require(success, string(returndata));

        emit CurrencyClaimed(amount);
    }

    function bridgeAirdrop() external override payable onlyOwner {
        require(msg.value > 0, "Expected funds");
        _mint(routerAddress, msg.value);
        emit BridgeAirdrop(msg.value);
    }

}