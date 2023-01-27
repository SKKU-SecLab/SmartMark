pragma solidity ^0.8.0;

interface IWETH {

  function deposit() external payable;

  function transfer(address to, uint value) external returns (bool);

  function withdraw(uint) external;

  function balanceOf(address who) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function allowance(address owner, address spender) external returns (uint256);

}// MIT

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;


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
}// MIT
pragma solidity ^0.8.0;

abstract contract AbstractOwnable {

  modifier onlyOwner() {
    require(_owner() == msg.sender, "caller is not the owner");
    _;
  }

  function _owner() internal virtual returns(address);

}// MIT
pragma solidity >=0.4.24;


abstract contract Withdrawable is AbstractOwnable {
  using SafeERC20Upgradeable for IERC20Upgradeable;
  address constant ETHER = address(0);

  event LogWithdrawToken(
    address indexed _from,
    address indexed _token,
    uint amount
  );

  function adminWithdraw(address asset) public onlyOwner {
    uint tokenBalance = adminWithdrawAllowed(asset);
    require(tokenBalance > 0, "admin witdraw not allowed");
    _withdraw(asset, tokenBalance);
  }

  function _withdraw(address _tokenAddress, uint _amount) internal {
    if (_tokenAddress == ETHER) {
      payable(msg.sender).transfer(_amount);
    } else {
      IERC20Upgradeable(_tokenAddress).safeTransfer(msg.sender, _amount);
    }
    emit LogWithdrawToken(msg.sender, _tokenAddress, _amount);
  }

  function adminWithdrawAllowed(address asset) internal virtual view returns(uint allowedAmount) {
    allowedAmount = asset == ETHER
      ? address(this).balance
      : IERC20Upgradeable(asset).balanceOf(address(this));
  }
}// MIT

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;

interface IERC777Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function granularity() external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function send(
        address recipient,
        uint256 amount,
        bytes calldata data
    ) external;


    function burn(uint256 amount, bytes calldata data) external;


    function isOperatorFor(address operator, address tokenHolder) external view returns (bool);


    function authorizeOperator(address operator) external;


    function revokeOperator(address operator) external;


    function defaultOperators() external view returns (address[] memory);


    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;


    function operatorBurn(
        address account,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;


    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes data,
        bytes operatorData
    );

    event Minted(address indexed operator, address indexed to, uint256 amount, bytes data, bytes operatorData);

    event Burned(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData);

    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);

    event RevokedOperator(address indexed operator, address indexed tokenHolder);
}// MIT

pragma solidity ^0.8.0;

library EnumerableSetUpgradeable {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }


    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC777RecipientUpgradeable {

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC1820RegistryUpgradeable {

    function setManager(address account, address newManager) external;


    function getManager(address account) external view returns (address);


    function setInterfaceImplementer(
        address account,
        bytes32 _interfaceHash,
        address implementer
    ) external;


    function getInterfaceImplementer(address account, bytes32 _interfaceHash) external view returns (address);


    function interfaceHash(string calldata interfaceName) external pure returns (bytes32);


    function updateERC165Cache(address account, bytes4 interfaceId) external;


    function implementsERC165Interface(address account, bytes4 interfaceId) external view returns (bool);


    function implementsERC165InterfaceNoCache(address account, bytes4 interfaceId) external view returns (bool);


    event InterfaceImplementerSet(address indexed account, bytes32 indexed interfaceHash, address indexed implementer);

    event ManagerChanged(address indexed account, address indexed newManager);
}// MIT
pragma solidity ^0.8.0;


contract Erc20Vault is
    Initializable,
    Withdrawable,
    IERC777RecipientUpgradeable
{

    using SafeERC20Upgradeable for IERC20Upgradeable;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    IERC1820RegistryUpgradeable constant private _erc1820 = IERC1820RegistryUpgradeable(
        0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24
    );
    bytes32 constant private TOKENS_RECIPIENT_INTERFACE_HASH = keccak256("ERC777TokensRecipient");
    bytes32 constant private Erc777Token_INTERFACE_HASH = keccak256("ERC777Token");

    EnumerableSetUpgradeable.AddressSet private supportedTokens;
    address public PNETWORK;
    IWETH public weth;
    bytes4 public ORIGIN_CHAIN_ID;

    event PegIn(
        address _tokenAddress,
        address _tokenSender,
        uint256 _tokenAmount,
        string _destinationAddress,
        bytes _userData,
        bytes4 _originChainId,
        bytes4 _destinationChainId
    );

    function initialize(
        address _weth,
        address[] memory _tokensToSupport,
        bytes4 _originChainId
    )
        public
        initializer
    {

        PNETWORK = msg.sender;
        for (uint256 i = 0; i < _tokensToSupport.length; i++) {
            supportedTokens.add(_tokensToSupport[i]);
        }
        weth = IWETH(_weth);
        _erc1820.setInterfaceImplementer(address(this), TOKENS_RECIPIENT_INTERFACE_HASH, address(this));
        ORIGIN_CHAIN_ID = _originChainId;
    }

    modifier onlyPNetwork() {

        require(msg.sender == PNETWORK, "Caller must be PNETWORK address!");
        _;
    }

    modifier onlySupportedTokens(address _tokenAddress) {

        require(supportedTokens.contains(_tokenAddress), "Token at supplied address is NOT supported!");
        _;
    }

    function setWeth(address _weth) external onlyPNetwork {

        weth = IWETH(_weth);
    }

    function setPNetwork(address _pnetwork) external onlyPNetwork {

        require(_pnetwork != address(0), "Cannot set the zero address as the pNetwork address!");
        PNETWORK = _pnetwork;
    }

    function isTokenSupported(address _token) external view returns(bool) {

        return supportedTokens.contains(_token);
    }

    function _owner() internal view override returns(address) {

        return PNETWORK;
    }

    function adminWithdrawAllowed(address asset) internal override view returns(uint) {

        return supportedTokens.contains(asset) ? 0 : super.adminWithdrawAllowed(asset);
    }

    function addSupportedToken(
        address _tokenAddress
    )
        external
        onlyPNetwork
        returns (bool SUCCESS)
    {

        supportedTokens.add(_tokenAddress);
        return true;
    }

    function removeSupportedToken(
        address _tokenAddress
    )
        external
        onlyPNetwork
        returns (bool SUCCESS)
    {

        return supportedTokens.remove(_tokenAddress);
    }

    function getSupportedTokens() external view returns(address[] memory res) {

        res = new address[](supportedTokens.length());
        for (uint256 i = 0; i < supportedTokens.length(); i++) {
            res[i] = supportedTokens.at(i);
        }
    }

    function pegIn(
        uint256 _tokenAmount,
        address _tokenAddress,
        string calldata _destinationAddress,
        bytes4 _destinationChainId
    )
        external
        returns (bool)
    {

        return pegIn(_tokenAmount, _tokenAddress, _destinationAddress, "", _destinationChainId);
    }

    function pegIn(
        uint256 _tokenAmount,
        address _tokenAddress,
        string memory _destinationAddress,
        bytes memory _userData,
        bytes4 _destinationChainId
    )
        public
        onlySupportedTokens(_tokenAddress)
        returns (bool)
    {

        require(_tokenAmount > 0, "Token amount must be greater than zero!");
        IERC20Upgradeable(_tokenAddress).safeTransferFrom(msg.sender, address(this), _tokenAmount);
        emit PegIn(
            _tokenAddress,
            msg.sender,
            _tokenAmount,
            _destinationAddress,
            _userData,
            ORIGIN_CHAIN_ID,
            _destinationChainId
        );
        return true;
    }

    function tokensReceived(
        address /*operator*/,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata /*operatorData*/
    )
        external
        override
        onlySupportedTokens(msg.sender)
    {

        require(to == address(this), "Token receiver is not this contract");
        if (userData.length > 0) {
            require(amount > 0, "Token amount must be greater than zero!");
            (bytes32 tag, string memory _destinationAddress, bytes4 _destinationChainId) = abi.decode(
                userData,
                (bytes32, string, bytes4)
            );
            require(
                tag == keccak256("ERC777-pegIn"),
                "Invalid tag for automatic pegIn on ERC777 send"
            );
            emit PegIn(
                msg.sender,
                from,
                amount,
                _destinationAddress,
                userData,
                ORIGIN_CHAIN_ID,
                _destinationChainId
            );
        }
    }

    function pegInEth(
        string calldata _destinationAddress,
        bytes4 _destinationChainId
    )
        external
        payable
        returns (bool)
    {

        return pegInEth(_destinationAddress, _destinationChainId, "");
    }

    function pegInEth(
        string memory _destinationAddress,
        bytes4 _destinationChainId,
        bytes memory _userData
    )
        public
        payable
        returns (bool)
    {

        require(supportedTokens.contains(address(weth)), "WETH is NOT supported!");
        require(msg.value > 0, "Ethers amount must be greater than zero!");
        weth.deposit{ value: msg.value }();
        emit PegIn(
            address(weth),
            msg.sender,
            msg.value,
            _destinationAddress,
            _userData,
            ORIGIN_CHAIN_ID,
            _destinationChainId
        );
        return true;
    }

    function pegOutWeth(
        address payable _tokenRecipient,
        uint256 _tokenAmount,
        bytes memory _userData
    )
        internal
        returns (bool)
    {

        weth.withdraw(_tokenAmount);
        (bool success, ) = _tokenRecipient.call{ value: _tokenAmount }(_userData);
        require(success, "ETH transfer failed when pegging out wETH!");
        return success;
    }

    function pegOut(
        address payable _tokenRecipient,
        address _tokenAddress,
        uint256 _tokenAmount
    )
        public
        onlyPNetwork
        returns (bool)
    {

        if (_tokenAddress == address(weth)) {
            pegOutWeth(_tokenRecipient, _tokenAmount, "");
        } else {
            IERC20Upgradeable(_tokenAddress).safeTransfer(_tokenRecipient, _tokenAmount);
        }
        return true;
    }

    function pegOut(
        address payable _tokenRecipient,
        address _tokenAddress,
        uint256 _tokenAmount,
        bytes calldata _userData
    )
        external
        onlyPNetwork
        returns (bool success)
    {

        if (_tokenAddress == address(weth)) {
            pegOutWeth(_tokenRecipient, _tokenAmount, _userData);
        } else {
            address erc777Address = _erc1820.getInterfaceImplementer(_tokenAddress, Erc777Token_INTERFACE_HASH);
            if (erc777Address == address(0)) {
                return pegOut(_tokenRecipient, _tokenAddress, _tokenAmount);
            } else {
                IERC777Upgradeable(erc777Address).send(_tokenRecipient, _tokenAmount, _userData);
                return true;
            }
        }
    }

    receive() external payable {
        require(msg.sender == address(weth));
    }

    function changeOriginChainId(
        bytes4 _newOriginChainId
    )
        public
        onlyPNetwork
        returns (bool success)
    {

        ORIGIN_CHAIN_ID = _newOriginChainId;
        return true;
    }
}