


pragma solidity ^0.6.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



pragma solidity ^0.6.2;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;


    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

}



pragma solidity ^0.6.0;


interface IERC1155Receiver is IERC165 {


    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);

}



pragma solidity ^0.6.0;

interface IERC1155Views {


    function totalSupply(uint256 objectId) external view returns (uint256);


    function name(uint256 objectId) external view returns (string memory);


    function symbol(uint256 objectId) external view returns (string memory);


    function decimals(uint256 objectId) external view returns (uint256);


    function uri(uint256 objectId) external view returns (string memory);

}



pragma solidity ^0.6.0;

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



pragma solidity ^0.6.0;


interface IERC20NFTWrapper is IERC20 {

    function init(uint256 objectId) external;


    function mainWrapper() external view returns (address);


    function objectId() external view returns (uint256);


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint256);


    function mint(address owner, uint256 amount) external;


    function burn(address owner, uint256 amount) external;

}



pragma solidity ^0.6.0;

interface IERC1155Data {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);

}



pragma solidity ^0.6.0;






interface ISuperSaiyanToken is IERC1155, IERC1155Receiver, IERC1155Views, IERC1155Data {

    function init(
        address model,
        address source,
        string calldata name,
        string calldata symbol
    ) external;


    function fromDecimals(uint256 objectId, uint256 amount)
        external
        view
        returns (uint256);


    function toDecimals(uint256 objectId, uint256 amount)
        external
        view
        returns (uint256);


    function getMintData(uint256 objectId)
        external
        view
        returns (
            string memory,
            string memory,
            uint256
        );


    function getModel() external view returns (address);


    function source() external view returns (address);


    function asERC20(uint256 objectId) external view returns (IERC20NFTWrapper);


    function emitTransferSingleEvent(address sender, address from, address to, uint256 objectId, uint256 amount) external;


    function mint(uint256 amount, string calldata partialUri)
        external
        returns (uint256, address);


    function burn(
        uint256 objectId,
        uint256 amount,
        bytes calldata data
    ) external;


    function burnBatch(
        uint256[] calldata objectIds,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;


    event Mint(uint256 objectId, address tokenAddress);
}



pragma solidity ^0.6.0;


interface IDFOSuperSaiyanToken is ISuperSaiyanToken {


    function doubleProxy() external view returns(address);

    function setDoubleProxy(address newDoubleProxy) external;

    function setUri(uint256 objectId, string calldata uri) external;


    event UriChanged(uint256 indexed objectId, string oldUri, string newUri);
}

interface IDoubleProxy {

    function proxy() external view returns(address);

}

interface IMVDProxy {

    function getToken() external view returns(address);

    function getStateHolderAddress() external view returns(address);

    function getMVDWalletAddress() external view returns(address);

    function getMVDFunctionalitiesManagerAddress() external view returns(address);

    function getMVDFunctionalityProposalManagerAddress() external view returns(address);

    function submit(string calldata codeName, bytes calldata data) external payable returns(bytes memory returnData);

}

interface IStateHolder {

    function setUint256(string calldata name, uint256 value) external returns(uint256);

    function getUint256(string calldata name) external view returns(uint256);

    function getBool(string calldata varName) external view returns (bool);

    function clear(string calldata varName) external returns(string memory oldDataType, bytes memory oldVal);

}

interface IMVDFunctionalitiesManager {

    function isAuthorizedFunctionality(address functionality) external view returns(bool);

}



pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity ^0.6.0;

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



pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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



pragma solidity ^0.6.0;


contract ERC165 is IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {

        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}



pragma solidity ^0.6.0;








contract SuperSaiyanToken is ISuperSaiyanToken, Context, ERC165 {

    using SafeMath for uint256;
    using Address for address;

    bytes4 internal constant _INTERFACEobjectId_ERC1155 = 0xd9b67a26;

    address private _source;

    string internal _name;
    string internal _symbol;

    mapping(uint256 => string) internal _objectUris;

    bool private _supportsName;
    bool private _supportsSymbol;
    bool private _supportsDecimals;

    mapping(uint256 => address) internal _dest;
    mapping(address => bool) internal _isMine;

    mapping(address => mapping(address => bool)) internal _operatorApprovals;

    address internal _model;

    constructor(
        address model,
        address source,
        string memory name,
        string memory symbol
    ) public {
        if(model != address(0)) {
            init(model, source, name, symbol);
        }
    }

    function init(
        address model,
        address source,
        string memory name,
        string memory symbol
    ) public virtual override {

        require(
            _model == address(0),
            "Init already called!"
        );

        require(
            model != address(0),
            "Model should be a valid ethereum address"
        );
        _model = model;

        _source = source;

        require(
            _source != address(0) || keccak256(bytes(name)) != keccak256(""),
            "At least a source contract or a name must be set"
        );
        require(
            _source != address(0) || keccak256(bytes(symbol)) != keccak256(""),
            "At least a source contract or a symbol must be set"
        );

        _registerInterface(this.onERC1155Received.selector);
        _registerInterface(this.onERC1155BatchReceived.selector);
        bool safeBatchTransferFrom = _checkAndInsertSelector(
            this.safeBatchTransferFrom.selector
        );
        bool cumulativeInterface = _checkAndInsertSelector(
            _INTERFACEobjectId_ERC1155
        );
        require(
            _source == address(0) ||
                safeBatchTransferFrom ||
                cumulativeInterface,
            "Looks like you're not wrapping a correct ERC1155 Token"
        );
        _checkAndInsertSelector(this.balanceOf.selector);
        _checkAndInsertSelector(this.balanceOfBatch.selector);
        _checkAndInsertSelector(this.setApprovalForAll.selector);
        _checkAndInsertSelector(this.isApprovedForAll.selector);
        _checkAndInsertSelector(this.safeTransferFrom.selector);
        _checkAndInsertSelector(this.uri.selector);
        _checkAndInsertSelector(this.totalSupply.selector);
        _supportsName = _checkAndInsertSelector(0x00ad800c); //name(uint256)
        _supportsSymbol = _checkAndInsertSelector(0x4e41a1fb); //symbol(uint256)
        _supportsDecimals = _checkAndInsertSelector(this.decimals.selector);
        _supportsDecimals = _source == address(0) ? false : _supportsDecimals;
        _setAndCheckNameAndSymbol(name, symbol);
    }

    function mint(uint256 amount, string memory objectUri)
        public
        virtual
        override
        returns (uint256 objectId, address tokenAddress)
    {

        require(_source == address(0), "Cannot mint unexisting tokens");
        require(
            keccak256(bytes(objectUri)) != keccak256(""),
            "Uri cannot be empty"
        );
        (objectId, tokenAddress) = _mint(msg.sender, 0, amount, true);
        _objectUris[objectId] = objectUri;
    }

    function burn(
        uint256 objectId,
        uint256 amount,
        bytes memory data
    ) public virtual override {

        asERC20(objectId).burn(msg.sender, toDecimals(objectId, amount));
        if (_source != address(0)) {
            IERC1155(_source).safeTransferFrom(
                address(this),
                msg.sender,
                objectId,
                amount,
                data
            );
        }
    }

    function burnBatch(
        uint256[] memory objectIds,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {

        for (uint256 i = 0; i < objectIds.length; i++) {
            asERC20(objectIds[i]).burn(
                msg.sender,
                toDecimals(objectIds[i], amounts[i])
            );
        }
        if (_source != address(0)) {
            IERC1155(_source).safeBatchTransferFrom(
                address(this),
                msg.sender,
                objectIds,
                amounts,
                data
            );
        }
    }

    function onERC1155Received(
        address,
        address owner,
        uint256 objectId,
        uint256 amount,
        bytes memory
    ) public virtual override returns (bytes4) {

        require(msg.sender == _source, "Unauthorized action!");
        _mint(owner, objectId, amount, false);
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address owner,
        uint256[] memory objectIds,
        uint256[] memory amounts,
        bytes memory
    ) public virtual override returns (bytes4) {

        require(msg.sender == _source, "Unauthorized action!");
        for (uint256 i = 0; i < objectIds.length; i++) {
            _mint(owner, objectIds[i], amounts[i], false);
        }
        return this.onERC1155BatchReceived.selector;
    }

    function getMintData(uint256 objectId)
        public
        virtual
        override
        view
        returns (
            string memory name,
            string memory symbol,
            uint256 decimals
        )
    {

        name = _name;
        symbol = _symbol;
        decimals = 18;
        if (
            _source != address(0) &&
            (_supportsName || _supportsSymbol || _supportsDecimals)
        ) {
            IERC1155Views views = IERC1155Views(_source);
            name = _supportsName ? views.name(objectId) : name;
            symbol = _supportsSymbol ? views.symbol(objectId) : symbol;
            decimals = _supportsDecimals ? views.decimals(objectId) : decimals;
        }
    }

    function getModel() public virtual override view returns (address) {

        return _model;
    }

    function fromDecimals(uint256 objectId, uint256 amount)
        public
        virtual
        override
        view
        returns (uint256)
    {

        return _supportsDecimals ? amount : (amount / (10**decimals(objectId)));
    }

    function toDecimals(uint256 objectId, uint256 amount)
        public
        virtual
        override
        view
        returns (uint256)
    {

        return _supportsDecimals ? amount : (amount * (10**decimals(objectId)));
    }

    function source() public virtual override view returns (address) {

        return _source;
    }

    function asERC20(uint256 objectId)
        public
        virtual
        override
        view
        returns (IERC20NFTWrapper)
    {

        return IERC20NFTWrapper(_dest[objectId]);
    }

    function totalSupply(uint256 objectId)
        public
        virtual
        override
        view
        returns (uint256)
    {

        return fromDecimals(objectId, asERC20(objectId).totalSupply());
    }

    function name(uint256 objectId)
        public
        virtual
        override
        view
        returns (string memory)
    {

        return asERC20(objectId).name();
    }

    function name() public virtual override view returns (string memory) {

        return _name;
    }

    function symbol(uint256 objectId)
        public
        virtual
        override
        view
        returns (string memory)
    {

        return asERC20(objectId).symbol();
    }

    function symbol() public virtual override view returns (string memory) {

        return _symbol;
    }

    function decimals(uint256 objectId)
        public
        virtual
        override
        view
        returns (uint256)
    {

        return asERC20(objectId).decimals();
    }

    function uri(uint256 objectId)
        public
        virtual
        override
        view
        returns (string memory)
    {

        return
            _source == address(0)
                ? _objectUris[objectId]
                : IERC1155Views(_source).uri(objectId);
    }

    function balanceOf(address account, uint256 objectId)
        public
        virtual
        override
        view
        returns (uint256)
    {

        return fromDecimals(objectId, asERC20(objectId).balanceOf(account));
    }

    function balanceOfBatch(
        address[] memory accounts,
        uint256[] memory objectIds
    ) public virtual override view returns (uint256[] memory) {

        uint256[] memory balances = new uint256[](accounts.length);
        for (uint256 i = 0; i < accounts.length; i++) {
            balances[i] = balanceOf(accounts[i], objectIds[i]);
        }
    }

    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {

        address sender = _msgSender();
        require(
            sender != operator,
            "ERC1155: setting approval status for self"
        );

        _operatorApprovals[sender][operator] = approved;
        emit ApprovalForAll(sender, operator, approved);
    }

    function isApprovedForAll(address account, address operator)
        public
        virtual
        override
        view
        returns (bool)
    {

        return _operatorApprovals[account][operator];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 objectId,
        uint256 amount,
        bytes memory data
    ) public virtual override {

        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        address operator = _msgSender();

        asERC20(objectId).transferFrom(from, to, toDecimals(objectId, amount));

        emit TransferSingle(operator, from, to, objectId, amount);

        _doSafeTransferAcceptanceCheck(
            operator,
            from,
            to,
            objectId,
            amount,
            data
        );
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory objectIds,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {

        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        for (uint256 i = 0; i < objectIds.length; i++) {
            asERC20(objectIds[i]).transferFrom(
                from,
                to,
                toDecimals(objectIds[i], amounts[i])
            );
        }

        address operator = _msgSender();

        emit TransferBatch(operator, from, to, objectIds, amounts);

        _doSafeBatchTransferAcceptanceCheck(
            operator,
            from,
            to,
            objectIds,
            amounts,
            data
        );
    }

    function emitTransferSingleEvent(address sender, address from, address to, uint256 objectId, uint256 amount) public override {

        require(_dest[objectId] == msg.sender, "Unauthorized Action!");
        uint256 entireAmount = fromDecimals(objectId, amount);
        if(entireAmount == 0) {
            return;
        }
        emit TransferSingle(sender, from, to, objectId, entireAmount);
    }

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {

        if (to.isContract()) {
            try
                IERC1155Receiver(to).onERC1155Received(
                    operator,
                    from,
                    id,
                    amount,
                    data
                )
            returns (bytes4 response) {
                if (
                    response != IERC1155Receiver(to).onERC1155Received.selector
                ) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {

        if (to.isContract()) {
            try
                IERC1155Receiver(to).onERC1155BatchReceived(
                    operator,
                    from,
                    ids,
                    amounts,
                    data
                )
            returns (bytes4 response) {
                if (
                    response !=
                    IERC1155Receiver(to).onERC1155BatchReceived.selector
                ) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _checkAndInsertSelector(bytes4 selector)
        internal
        virtual
        returns (bool response)
    {

        if (_source == address(0)) {
            _registerInterface(selector);
            return true;
        }
        try ERC165(_source).supportsInterface(selector) returns (bool res) {
            if (response = res) {
                _registerInterface(selector);
            }
        } catch {}
    }

    function _clone(address original) internal returns (address copy) {
        assembly {
            mstore(
                0,
                or(
                    0x5880730000000000000000000000000000000000000000803b80938091923cF3,
                    mul(original, 0x1000000000000000000)
                )
            )
            copy := create(0, 0, 32)
            switch extcodesize(copy)
                case 0 {
                    invalid()
                }
        }
    }

    function _mint(
        address from,
        uint256 oldObjectId,
        uint256 amount,
        bool generateObjectId
    ) internal virtual returns (uint256, address) {
        uint256 objectId = oldObjectId;
        IERC20NFTWrapper wrapper = IERC20NFTWrapper(_dest[objectId]);
        if (_dest[objectId] == address(0) || generateObjectId) {
            require(
                amount > _getTokenUnity(objectId),
                "You need to pass more than a token"
            );
            wrapper = IERC20NFTWrapper(_clone(getModel()));
            if(generateObjectId) {
                objectId = uint256(address(wrapper));
            }
            wrapper.init(objectId);
            _isMine[_dest[objectId] = address(wrapper)] = true;
            emit Mint(objectId, address(wrapper));
        }
        wrapper.mint(from, _convertForMint(objectId, amount));
        emit TransferSingle(address(this), address(0), from, objectId, amount);
        return (objectId, address(wrapper));
    }

    function _getTokenUnity(uint256 objectId)
        internal
        virtual
        view
        returns (uint256)
    {
        if (_source == address(0)) {
            return (10**18);
        }
        if (_supportsDecimals) {
            return (10**IERC1155Views(_source).decimals(objectId));
        }
        return 1;
    }

    function _convertForMint(uint256 objectId, uint256 amount)
        internal
        virtual
        view
        returns (uint256)
    {
        if (_source != address(0) && _supportsDecimals) {
            return amount * (10**IERC1155Views(_source).decimals(objectId));
        }
        return amount;
    }

    function _setAndCheckNameAndSymbol(
        string memory inputName,
        string memory inputSymbol
    ) internal virtual {
        _name = inputName;
        _symbol = inputSymbol;
        if (_source != address(0)) {
            IERC1155Data data = IERC1155Data(_source);
            try data.name() returns (string memory n) {
                _name = n;
            } catch {}
            try data.symbol() returns (string memory s) {
                _symbol = s;
            } catch {}
        }
        require(keccak256(bytes(_name)) != keccak256(""), "Name is mandatory");
        require(
            keccak256(bytes(_symbol)) != keccak256(""),
            "Symbol is mandatory"
        );
    }
}



pragma solidity ^0.6.0;



contract DFOSuperSaiyanToken is IDFOSuperSaiyanToken, SuperSaiyanToken(address(0), address(0), "", "") {

    address private _doubleProxy;

    constructor(
        address model,
        address doubleProxy,
        string memory name,
        string memory symbol
    ) public {
        if(model != address(0)) {
            init(model, doubleProxy, name, symbol);
        }
    }

    function init(
        address model,
        address doubleProxy,
        string memory name,
        string memory symbol
    ) public override(ISuperSaiyanToken, SuperSaiyanToken) {
        super.init(model, address(0), name, symbol);
        _doubleProxy = doubleProxy;
    }

    modifier byDFO {
        if(_doubleProxy != address(0)) {
            require(IMVDFunctionalitiesManager(IMVDProxy(IDoubleProxy(_doubleProxy).proxy()).getMVDFunctionalitiesManagerAddress()).isAuthorizedFunctionality(msg.sender), "Unauthorized Action!");
        }
        _;
    }

    function doubleProxy() public override view returns(address) {
        return _doubleProxy;
    }

    function setDoubleProxy(address newDoubleProxy) public override byDFO {
        _doubleProxy = newDoubleProxy;
    }

    function mint(uint256 amount, string memory objectUri)
        public
        virtual
        override(ISuperSaiyanToken, SuperSaiyanToken)
        byDFO
        returns (uint256 objectId, address tokenAddress)
    {
        (objectId, tokenAddress) = super.mint(amount, objectUri);
        emit UriChanged(objectId, "", objectUri);
    }

    function setUri(uint256 objectId, string memory newUri) public byDFO override {
        emit UriChanged(objectId, _objectUris[objectId], newUri);
        _objectUris[objectId] = newUri;
    }
}