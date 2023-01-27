
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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

interface IComptroller {

    function isMarketListed(address cTokenAddress) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;

interface ICToken {

    function admin() external view returns (address);

    function symbol() external view returns (string memory);

    function underlying() external view returns (address);

    function totalReserves() external view returns (uint);

}// MIT

pragma solidity ^0.8.0;

interface ICTokenAdmin {

    function extractReserves(address cToken, uint reduceAmount) external;

}// MIT

pragma solidity ^0.8.0;

interface IBurner {

    function burn(address coin) external returns (bool);

}// MIT

pragma solidity ^0.8.0;

interface IWeth {

    function deposit() external payable;

}// MIT

pragma solidity ^0.8.0;


contract ReserveManager is Ownable, ReentrancyGuard {

    using SafeERC20 for IERC20;

    uint public constant COOLDOWN_PERIOD = 1 days;
    address public constant ethAddress = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    IComptroller public immutable comptroller;

    address public immutable wethAddress;

    address public immutable usdcAddress;

    uint public ratio = 0.5e18;

    IBurner public usdcBurner;

    mapping(address => address) public cTokenAdmins;

    mapping(address => address) public burners;

    struct ReservesSnapshot {
        uint timestamp;
        uint totalReserves;
    }

    mapping(address => ReservesSnapshot) public reservesSnapshot;

    mapping(address => bool) public isBlocked;

    mapping(address => bool) public manualBurn;

    address public manualBurner;

    event Dispatch(
        address indexed token,
        uint indexed amount,
        address destination
    );

    event CTokenAdminUpdated(
        address cToken,
        address oldAdmin,
        address newAdmin
    );

    event BurnerUpdated(
        address cToken,
        address oldBurner,
        address newBurner
    );

    event UsdcBurnerUpdated(
        address oldBurner,
        address newBurner
    );

    event RatioUpdated(
        uint oldRatio,
        uint newRatio
    );

    event TokenSeized(
        address token,
        uint amount
    );

    event MarketBlocked(
        address cToken,
        bool wasBlocked,
        bool isBlocked
    );

    event MarketManualBurn(
        address cToken,
        bool wasManual,
        bool isManual
    );

    event ManualBurnerUpdated(
        address oldManualBurner,
        address newManualBurner
    );

    constructor(
        address _owner,
        address _manualBurner,
        IComptroller _comptroller,
        IBurner _usdcBurner,
        address _wethAddress,
        address _usdcAddress
    ) {
        transferOwnership(_owner);
        manualBurner = _manualBurner;
        comptroller = _comptroller;
        usdcBurner = _usdcBurner;
        wethAddress = _wethAddress;
        usdcAddress = _usdcAddress;

        ratio = 0.5e18;
    }

    function getBlockTimestamp() public virtual view returns (uint) {

        return block.timestamp;
    }

    function dispatchMultiple(address[] memory cTokens) external nonReentrant {

        for (uint i = 0; i < cTokens.length; i++) {
            dispatch(cTokens[i], true);
        }
        IBurner(usdcBurner).burn(usdcAddress);
    }

    receive() external payable {}


    function seize(address token, uint amount) external onlyOwner {

        if (token == ethAddress) {
            payable(owner()).transfer(amount);
        } else {
            IERC20(token).safeTransfer(owner(), amount);
        }
        emit TokenSeized(token, amount);
    }

    function setBlocked(address[] memory cTokens, bool[] memory blocked) external onlyOwner {

        require(cTokens.length == blocked.length, "invalid data");

        for (uint i = 0; i < cTokens.length; i++) {
            bool wasBlocked = isBlocked[cTokens[i]];
            isBlocked[cTokens[i]] = blocked[i];

            emit MarketBlocked(cTokens[i], wasBlocked, blocked[i]);
        }
    }

    function setUsdcBurner(address newUsdcBurner) external onlyOwner {

        address oldUsdcBurner = address(usdcBurner);
        usdcBurner = IBurner(newUsdcBurner);

        emit UsdcBurnerUpdated(oldUsdcBurner, newUsdcBurner);
    }

    function setCTokenAdmins(address[] memory cTokens, address[] memory newCTokenAdmins) external onlyOwner {

        require(cTokens.length == newCTokenAdmins.length, "invalid data");

        for (uint i = 0; i < cTokens.length; i++) {
            require(comptroller.isMarketListed(cTokens[i]), "market not listed");
            require(ICToken(cTokens[i]).admin() == newCTokenAdmins[i], "mismatch cToken admin");

            address oldAdmin = cTokenAdmins[cTokens[i]];
            cTokenAdmins[cTokens[i]] = newCTokenAdmins[i];

            emit CTokenAdminUpdated(cTokens[i], oldAdmin, newCTokenAdmins[i]);
        }
    }

    function setBurners(address[] memory cTokens, address[] memory newBurners) external onlyOwner {

        require(cTokens.length == newBurners.length, "invalid data");

        for (uint i = 0; i < cTokens.length; i++) {
            address oldBurner = burners[cTokens[i]];
            burners[cTokens[i]] = newBurners[i];

            emit BurnerUpdated(cTokens[i], oldBurner, newBurners[i]);
        }
    }

    function setManualBurn(address[] memory cTokens, bool[] memory manual) external onlyOwner {

        require(cTokens.length == manual.length, "invalid data");

        for (uint i = 0; i < cTokens.length; i++) {
            bool wasManual = manualBurn[cTokens[i]];
            manualBurn[cTokens[i]] = manual[i];

            emit MarketManualBurn(cTokens[i], wasManual, manual[i]);
        }
    }

    function setManualBurner(address newManualBurner) external onlyOwner {

        require(newManualBurner != address(0), "invalid new manual burner");

        address oldManualBurner = manualBurner;
        manualBurner = newManualBurner;

        emit ManualBurnerUpdated(oldManualBurner, newManualBurner);
    }

    function adjustRatio(uint newRatio) external onlyOwner {

        require(newRatio <= 1e18, "invalid ratio");

        uint oldRatio = ratio;
        ratio = newRatio;
        emit RatioUpdated(oldRatio, newRatio);
    }


    function compareStrings(string memory a, string memory b) internal pure returns (bool) {

        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function dispatch(address cToken, bool batchJob) internal {

        require(!isBlocked[cToken], "market is blocked from reserves sharing");
        require(comptroller.isMarketListed(cToken), "market not listed");

        uint totalReserves = ICToken(cToken).totalReserves();
        ReservesSnapshot memory snapshot = reservesSnapshot[cToken];
        if (snapshot.timestamp > 0 && snapshot.totalReserves < totalReserves) {
            address cTokenAdmin = cTokenAdmins[cToken];
            require(cTokenAdmin == ICToken(cToken).admin(), "mismatch cToken admin");
            require(snapshot.timestamp + COOLDOWN_PERIOD <= getBlockTimestamp(), "still in the cooldown period");

            uint reduceAmount = (totalReserves - snapshot.totalReserves) * ratio / 1e18;
            ICTokenAdmin(cTokenAdmin).extractReserves(cToken, reduceAmount);

            totalReserves = totalReserves - reduceAmount;

            address underlying;
            if (compareStrings(ICToken(cToken).symbol(), "crETH")) {
                IWeth(wethAddress).deposit{value: reduceAmount}();
                underlying = wethAddress;
            } else {
                underlying = ICToken(cToken).underlying();
            }

            uint burnAmount = IERC20(underlying).balanceOf(address(this));

            address burner = burners[cToken];
            if (manualBurn[cToken]) {
                burner = manualBurner;
                IERC20(underlying).safeTransfer(manualBurner, burnAmount);
            } else {
                require(burner != address(0), "burner not set");
                IERC20(underlying).safeIncreaseAllowance(burner, burnAmount);
                require(IBurner(burner).burn(underlying), "Burner failed to burn the underlying token");
            }

            emit Dispatch(underlying, burnAmount, burner);
        }

        reservesSnapshot[cToken] = ReservesSnapshot({
            timestamp: getBlockTimestamp(),
            totalReserves: totalReserves
        });

        if (!batchJob){
            IBurner(usdcBurner).burn(usdcAddress);
        }
    }
}