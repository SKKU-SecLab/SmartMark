

pragma solidity 0.8.10;


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}


interface IERC20Upgradeable {

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
}


library AddressUpgradeable {

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
}


library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


interface ICLOUDPresale {

    function PRE_SALE_END() external view returns (uint256);


    function purchased(address _user) external view returns (uint256);

}

contract CloudVesting is OwnableUpgradeable {

    using SafeERC20Upgradeable for IERC20Upgradeable;

    event CLOUDClaimed(address indexed user, uint256 cloudAmount);


    uint256 private constant STAGES = 4;

    uint256[STAGES] public unlockDates;
    uint256[STAGES] public unlockPercents;

    mapping(address => bool) public whitelist;


    address public CLOUDToken;
    ICLOUDPresale public presale;

    mapping(address => uint256[STAGES]) internal _claimed;

    function initialize(
        address _presale,
        address _cloud,
        uint256[STAGES] memory _dates,
        uint256[STAGES] memory _percents
    ) public virtual initializer {

        __Ownable_init();

        _validateVestingParams(_dates, _percents);

        unlockDates = _dates;
        unlockPercents = _percents;

        CLOUDToken = _cloud;
        presale = ICLOUDPresale(_presale);
    }

    receive() external payable {}

    function adminResetVestingParams(uint256[STAGES] memory _dates, uint256[STAGES] memory _percents)
        external
        onlyOwner
    {

        require(block.timestamp < unlockDates[0], "Vesting has already been started");
        _validateVestingParams(_dates, _percents);
        unlockDates = _dates;
        unlockPercents = _percents;
    }

    function adminAddToWhitelist(address[] memory _participants) external onlyOwner {

        for (uint256 i = 0; i < _participants.length; i++) {
            whitelist[_participants[i]] = true;
        }
    }

    function adminRemoveFromWhitelist(address[] memory _participants) external onlyOwner {

        for (uint256 i = 0; i < _participants.length; i++) {
            whitelist[_participants[i]] = false;
        }
    }

    function adminWithdraw(address _token) external onlyOwner {

        uint256 balance;
        if (_token == address(0)) {
            balance = address(this).balance;
            if (balance > 0) {
                (bool sent, bytes memory data) = payable(_msgSender()).call{value: balance}("");
                require(sent, "ETH transfer failed");
            }
        } else {
            balance = IERC20Upgradeable(_token).balanceOf(address(this));
            if (balance > 0) {
                IERC20Upgradeable(_token).safeTransfer(_msgSender(), balance);
            }
        }
    }


    function claim() external {

        require(whitelist[_msgSender()], "Caller is not whitelisted");
        require(block.timestamp > unlockDates[0], "Vesting has not been started");

        uint256 summary;
        uint256 purchased = presale.purchased(_msgSender());
        for (uint256 i = 0; i < STAGES; i++) {
            if (unlockDates[i] < block.timestamp) {
                if (_claimed[_msgSender()][i] == 0) {
                    uint256 payout = (purchased * unlockPercents[i]) / 100;

                    _claimed[_msgSender()][i] += payout;
                    summary += payout;
                }
            }
        }
        if (summary > 0) {
            IERC20Upgradeable(CLOUDToken).safeTransfer(_msgSender(), summary);
        }
        emit CLOUDClaimed(_msgSender(), summary);
    }

    function claimed(address _user) public view returns (uint256 _totalClaimed) {

        if (!whitelist[_user]) return 0;
        for (uint256 i = 0; i < STAGES; i++) {
            _totalClaimed += _claimed[_user][i];
        }
    }

    function claimable(address _user) external view returns (uint256) {

        if (!whitelist[_user]) return 0;
        if (block.timestamp < unlockDates[0]) return 0;

        uint256 summary;
        uint256 purchased = presale.purchased(_user);
        for (uint256 i = 0; i < STAGES; i++) {
            if (unlockDates[i] < block.timestamp) {
                if (_claimed[_user][i] == 0) {
                    uint256 payout = (purchased * unlockPercents[i]) / 100;
                    summary += payout;
                }
            }
        }
        return summary;
    }

    function totalClaimable(address _user) external view returns (uint256) {

        if (whitelist[_user]) {
            return presale.purchased(_user) - claimed(_user);
        }
        return 0;
    }

    function _validateVestingParams(uint256[STAGES] memory _dates, uint256[STAGES] memory _percents) private view {

        require(block.timestamp < _dates[0], "Vesting must start in future");

        for (uint256 i = 1; i < STAGES; i++) {
            require(_dates[i - 1] < _dates[i], "Wrong dates set");
        }

        uint256 sum;

        for (uint256 i = 0; i < STAGES; i++) {
            sum += _percents[i];
        }

        require(sum == 100, "Wrong percentage set");
    }
}