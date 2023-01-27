
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
}// UNLICENSED

pragma solidity 0.8.11;

interface IWETH {

    function deposit() external payable;


    function withdraw(uint256) external;


    function totalSupply() external view returns (uint256);


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
}// GPL-3.0-or-later
pragma solidity 0.8.11;



contract FeeSplitter is Ownable, ReentrancyGuard {


    event PaymentReleased(address to, address token, uint256 amount);

    event PaymentReceived(address from, address token, uint256 amount);

    event RoyaltiesWeightUpdated(uint256 weight);

    event ShareholdersAdded(address account, uint256 weight);

    event ShareholderUpdated(address account, uint256 weight);

    event RoyaltiesReceived(address to, address token, uint256 value);


    struct Shareholder {
        address account;
        uint96 weight;
    }

    struct TokenRecords {
        uint256 totalShares;
        uint256 totalReleased;
        mapping(address => uint256) shares;
        mapping(address => uint256) released;
    }


    mapping(address => TokenRecords) private tokenRecords;

    Shareholder[] private shareholders;

    uint256 public royaltiesWeight;

    uint256 public totalWeights;

    address public immutable weth;


    constructor(
        address[] memory _accounts,
        uint96[] memory _weights,
        uint256 _royaltiesWeight,
        address _weth
    ) {
        require(_weth != address(0), "FS: INVALID_ADDRESS");
        setShareholders(_accounts, _weights);
        setRoyaltiesWeight(_royaltiesWeight);
        weth = _weth;
    }

    receive() external payable {
        require(msg.sender == weth, "FS: ETH_SENDER_NOT_WETH");
    }


    function setRoyaltiesWeight(uint256 _weight) public onlyOwner {

        require(_weight != 0, "FS: WEIGHT_ZERO");
        totalWeights = totalWeights + _weight - royaltiesWeight;
        royaltiesWeight = _weight;
        emit RoyaltiesWeightUpdated(_weight);
    }

    function setShareholders(address[] memory _accounts, uint96[] memory _weights) public onlyOwner {

        delete shareholders;
        uint256 accountsLength = _accounts.length;
        require(accountsLength != 0, "FS: EMPTY_ARRAY");
        require(accountsLength == _weights.length, "FS: INPUTS_LENGTH_MUST_MATCH");
        totalWeights = royaltiesWeight;

        for (uint256 i = 0; i < accountsLength; i++) {
            _addShareholder(_accounts[i], _weights[i]);
        }
    }

    function updateShareholder(uint256 _accountIndex, uint96 _weight) external onlyOwner {

        require(_weight != 0, "FS: INVALID_WEIGHT");
        require(_accountIndex < shareholders.length, "FS: INVALID_ACCOUNT_INDEX");
        Shareholder storage _shareholder = shareholders[_accountIndex];
        totalWeights = totalWeights + _weight - _shareholder.weight;
        require(totalWeights != 0, "FS: TOTAL_WEIGHTS_ZERO");
        _shareholder.weight = _weight;
        emit ShareholderUpdated(_shareholder.account, _weight);
    }


    function releaseTokens(IERC20[] calldata _tokens) external nonReentrant {

        uint256 amount;
        for (uint256 i = 0; i < _tokens.length; i++) {
            amount = _releaseToken(_msgSender(), _tokens[i]);
            if (address(_tokens[i]) == weth) {
                IWETH(weth).withdraw(amount);
                (bool success, ) = _msgSender().call{ value: amount }("");
                require(success, "FS: ETH_TRANFER_ERROR");
            } else {
                SafeERC20.safeTransfer(_tokens[i], _msgSender(), amount);
            }
            emit PaymentReleased(_msgSender(), address(_tokens[i]), amount);
        }
    }

    function releaseTokensNoETH(IERC20[] calldata _tokens) external nonReentrant {

        uint256 amount;
        for (uint256 i = 0; i < _tokens.length; i++) {
            amount = _releaseToken(_msgSender(), _tokens[i]);
            SafeERC20.safeTransfer(_tokens[i], _msgSender(), amount);
            emit PaymentReleased(_msgSender(), address(_tokens[i]), amount);
        }
    }

    function sendFees(IERC20 _token, uint256 _amount) external nonReentrant {

        uint256 weights;
        unchecked {
            weights = totalWeights - royaltiesWeight;
        }

        uint256 balanceBeforeTransfer = _token.balanceOf(address(this));
        SafeERC20.safeTransferFrom(_token, _msgSender(), address(this), _amount);

        _sendFees(_token, _token.balanceOf(address(this)) - balanceBeforeTransfer, weights);
    }

    function sendFeesWithRoyalties(
        address _royaltiesTarget,
        IERC20 _token,
        uint256 _amount
    ) external nonReentrant {

        require(_royaltiesTarget != address(0), "FS: INVALID_ROYALTIES_TARGET");

        uint256 balanceBeforeTransfer = _token.balanceOf(address(this));
        SafeERC20.safeTransferFrom(_token, _msgSender(), address(this), _amount);
        uint256 amountReceived = _token.balanceOf(address(this)) - balanceBeforeTransfer;

        uint256 _totalWeights = totalWeights;
        uint256 royaltiesAmount = (amountReceived * royaltiesWeight) / _totalWeights;

        _sendFees(_token, amountReceived, _totalWeights);
        _addShares(_royaltiesTarget, royaltiesAmount, address(_token));

        emit RoyaltiesReceived(_royaltiesTarget, address(_token), royaltiesAmount);
    }


    function getAmountDue(address _account, IERC20 _token) public view returns (uint256) {

        TokenRecords storage _tokenRecords = tokenRecords[address(_token)];
        uint256 _totalShares = _tokenRecords.totalShares;
        if (_totalShares == 0) return 0;

        uint256 totalReceived = _tokenRecords.totalReleased + _token.balanceOf(address(this));
        return (totalReceived * _tokenRecords.shares[_account]) / _totalShares - _tokenRecords.released[_account];
    }

    function totalShares(address _token) external view returns (uint256) {

        return tokenRecords[_token].totalShares;
    }

    function totalReleased(address _token) external view returns (uint256) {

        return tokenRecords[_token].totalReleased;
    }

    function shares(address _account, address _token) external view returns (uint256) {

        return tokenRecords[_token].shares[_account];
    }

    function released(address _account, address _token) external view returns (uint256) {

        return tokenRecords[_token].released[_account];
    }

    function findShareholder(address _account) external view returns (uint256) {

        for (uint256 i = 0; i < shareholders.length; i++) {
            if (shareholders[i].account == _account) return i;
        }
        revert("FS: SHAREHOLDER_NOT_FOUND");
    }


    function _sendFees(
        IERC20 _token,
        uint256 _amount,
        uint256 _totalWeights
    ) private {

        Shareholder[] memory shareholdersCache = shareholders;
        for (uint256 i = 0; i < shareholdersCache.length; i++) {
            _addShares(
                shareholdersCache[i].account,
                (_amount * shareholdersCache[i].weight) / _totalWeights,
                address(_token)
            );
        }
        emit PaymentReceived(_msgSender(), address(_token), _amount);
    }

    function _addShares(
        address _account,
        uint256 _shares,
        address _token
    ) private {

        TokenRecords storage _tokenRecords = tokenRecords[_token];
        _tokenRecords.shares[_account] += _shares;
        _tokenRecords.totalShares += _shares;
    }

    function _releaseToken(address _account, IERC20 _token) private returns (uint256) {

        uint256 amountToRelease = getAmountDue(_account, _token);
        require(amountToRelease != 0, "FS: NO_PAYMENT_DUE");

        TokenRecords storage _tokenRecords = tokenRecords[address(_token)];
        _tokenRecords.released[_account] += amountToRelease;
        _tokenRecords.totalReleased += amountToRelease;

        return amountToRelease;
    }

    function _addShareholder(address _account, uint96 _weight) private {

        require(_weight != 0, "FS: ZERO_WEIGHT");
        require(_account != address(0), "FS: INVALID_ADDRESS");
        for (uint256 i = 0; i < shareholders.length; i++) {
            require(shareholders[i].account != _account, "FS: ALREADY_SHAREHOLDER");
        }

        shareholders.push(Shareholder(_account, _weight));
        totalWeights += _weight;
        emit ShareholdersAdded(_account, _weight);
    }
}