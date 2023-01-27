
pragma solidity ^0.8.1;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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
}// MIT

pragma solidity ^0.8.0;


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    uint256[49] private __gap;
}//Unlicense
pragma solidity ^0.8.0;

library LibBytes {

    function readBytes4(bytes memory b, uint256 index)
        internal
        pure
        returns (bytes4 result)
    {

        require(b.length >= index + 4, "InvalidByteOperation");

        index += 32;

        assembly {
            result := mload(add(b, index))
            result := and(
                result,
                0xFFFFFFFF00000000000000000000000000000000000000000000000000000000
            )
        }

        return result;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external;


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external;


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external;


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}//Unlicense
pragma solidity ^0.8.0;

interface IHopL1Bridge {

    function sendToL2(
        uint256 chainId,
        address recipient,
        uint256 amount,
        uint256 amountOutMin,
        uint256 deadline,
        address relayer,
        uint256 relayerFee
    ) external payable;

}//Unlicense
pragma solidity ^0.8.0;

interface IHopL2AmmWrapper {

    function swapAndSend(
        uint256 chainId,
        address recipient,
        uint256 amount,
        uint256 bonderFee,
        uint256 amountOutMin,
        uint256 deadline,
        uint256 destinationAmountOutMin,
        uint256 destinationDeadline
    ) external payable;

}//Unlicense
pragma solidity ^0.8.0;

interface IAnySwapBridge {

    function anySwapOut(
        address token,
        address to,
        uint256 amount,
        uint256 toChainID
    ) external payable;


    function anySwapOutUnderlying(
        address token,
        address to,
        uint256 amount,
        uint256 toChainID
    ) external payable;


    function anySwapOutNative(
        address token,
        address to,
        uint256 toChainID
    ) external payable;

}//Unlicense
pragma solidity ^0.8.0;


contract WovenExchange is Initializable, OwnableUpgradeable {

    using LibBytes for bytes;

    address public constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    uint256 public constant MAX_INT_HEX =
        0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    struct CurrencyAmount {
        address target;
        uint256 amount;
    }

    mapping(address => bool) public exchanges;

    function initialize() public initializer {

        __Ownable_init();
    }

    function setExchange(address exchange, bool enabled) external onlyOwner {

        exchanges[exchange] = enabled;
    }

    function swapAndSendToBridge(
        bytes calldata swapData,
        bytes calldata sendToBridgeData
    ) public payable {

        address self = address(this);
        require(
            this.swap.selector == swapData.readBytes4(0) &&
            (
                this.hopSendL1ToL2.selector == sendToBridgeData.readBytes4(0) ||
                this.hopSendL2ToOther.selector == sendToBridgeData.readBytes4(0) ||
                this.anySwap.selector == sendToBridgeData.readBytes4(0)
            ),
            "calldata error"
        );

        {
            (bool success, bytes memory ret) = self.delegatecall(swapData);
            require(success, string(ret));
        }
        {
            (bool success, bytes memory ret) = self.call{value: self.balance}(
                sendToBridgeData
            );
            require(success, string(ret));
        }
    }

    function swap(
        CurrencyAmount calldata input,
        CurrencyAmount calldata output,
        address recipient,
        address allowanceTarget,
        address exchange,
        bytes calldata callData
    ) public payable {

        require(exchanges[exchange], "Woven: exchange not allowed");
        address sender = msg.sender;
        address self = address(this);

        if (input.target != ETH) {
            if (sender != self) {
                IERC20(input.target).transferFrom(sender, self, input.amount);
            }
            IERC20(input.target).approve(allowanceTarget, input.amount);
        }

        (bool success, bytes memory ret) = exchange.call{value: self.balance}(
            callData
        );
        require(success, string(ret));

        if (recipient != self && output.amount > 0) {
            if (self.balance > 0) {
                payable(recipient).transfer(self.balance);
            }
            if (output.target != ETH) {
                uint256 balance = IERC20(output.target).balanceOf(self);
                IERC20(output.target).transfer(recipient, balance);
            }
        }
    }

    function getAmount(CurrencyAmount calldata currency)
        private
        view
        returns (uint256)
    {

        uint256 amount = currency.amount;

        if (currency.target != ETH) {
            if (amount == MAX_INT_HEX) {
                amount = IERC20(currency.target).balanceOf(msg.sender);
            }
        } else {
            if (amount == MAX_INT_HEX) {
                amount = address(this).balance;
            }
        }

        return amount;
    }

    function hopSendL1ToL2(
        address bridge,
        CurrencyAmount calldata currency,
        uint256 destinationChainId,
        address recipient,
        uint256 amountOutMin,
        uint256 deadline,
        address relayer,
        uint256 relayerFee
    ) public payable {

        address sender = msg.sender;
        address self = address(this);
        uint256 amount = getAmount(currency);

        if (currency.target != ETH) {
            if (sender != self) {
                IERC20(currency.target).transferFrom(sender, self, amount);
            }
            IERC20(currency.target).approve(bridge, amount);
        }

        IHopL1Bridge(bridge).sendToL2{value: self.balance}(
            destinationChainId,
            recipient,
            amount,
            amountOutMin,
            deadline,
            relayer,
            relayerFee
        );
    }

    function hopSendL2ToOther(
        address ammWrapper,
        CurrencyAmount calldata currency,
        uint256 destinationChainId,
        address recipient,
        uint256 bonderFee,
        uint256 amountOutMin,
        uint256 deadline,
        uint256 destinationAmountOutMin,
        uint256 destinationDeadline
    ) public payable {

        address sender = msg.sender;
        address self = address(this);
        uint256 amount = getAmount(currency);

        if (currency.target != ETH) {
            if (sender != self) {
                IERC20(currency.target).transferFrom(sender, self, amount);
            }
            IERC20(currency.target).approve(ammWrapper, amount);
        }

        IHopL2AmmWrapper(ammWrapper).swapAndSend{value: self.balance}(
            destinationChainId,
            recipient,
            amount,
            bonderFee,
            amountOutMin,
            deadline,
            destinationAmountOutMin,
            destinationDeadline
        );
    }

    function anySwap(
        address bridge,
        CurrencyAmount calldata currency,
        address inputToken,
        uint256 destinationChainId,
        address recipient
    ) public payable {

        address sender = msg.sender;
        address self = address(this);
        uint256 amount = getAmount(currency);

        if (currency.target != ETH) {
            if (sender != self) {
                IERC20(currency.target).transferFrom(sender, self, amount);
            }
            IERC20(currency.target).approve(bridge, amount);
        }

        if (currency.target == ETH) {
            IAnySwapBridge(bridge).anySwapOutNative{value: self.balance}(
                inputToken,
                recipient,
                destinationChainId
            );
        } else {
            if (inputToken == currency.target) {
                IAnySwapBridge(bridge).anySwapOut(
                    inputToken,
                    recipient,
                    amount,
                    destinationChainId
                );
            } else {
                IAnySwapBridge(bridge).anySwapOutUnderlying(
                    inputToken,
                    recipient,
                    amount,
                    destinationChainId
                );
            }
        }
    }


    receive() external payable virtual {}

}