

pragma solidity ^0.5.11;


interface IERC20 {

    function transfer(address _to, uint _value) external returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    function approve(address _spender, uint256 _value) external returns (bool success);

    function increaseApproval (address _spender, uint _addedValue) external returns (bool success);
    function balanceOf(address _owner) external view returns (uint256 balance);

}


pragma solidity ^0.5.11;


interface Cosigner {

    function url() external view returns (string memory);


    function cost(
        address engine,
        uint256 index,
        bytes calldata data,
        bytes calldata oracleData
    )
        external view returns (uint256);


    function requestCosign(
        address engine,
        uint256 index,
        bytes calldata data,
        bytes calldata oracleData
    )
        external returns (bool);


    function claim(address engine, uint256 index, bytes calldata oracleData) external returns (bool);

}


pragma solidity ^0.5.11;


interface IERC165 {

    function supportsInterface(bytes4 interfaceID) external view returns (bool);

}


pragma solidity ^0.5.11;


interface IDebtStatus {

    enum Status {
        NULL,
        ONGOING,
        PAID,
        DESTROYED, // Deprecated, used in basalt version
        ERROR
    }
}


pragma solidity ^0.5.11;




contract Model is IERC165, IDebtStatus {



    event Created(bytes32 indexed _id);

    event ChangedStatus(bytes32 indexed _id, uint256 _timestamp, Status _status);

    event ChangedObligation(bytes32 indexed _id, uint256 _timestamp, uint256 _debt);

    event ChangedFrequency(bytes32 indexed _id, uint256 _timestamp, uint256 _frequency);

    event ChangedDueTime(bytes32 indexed _id, uint256 _timestamp, Status _status);

    event ChangedFinalTime(bytes32 indexed _id, uint256 _timestamp, uint64 _dueTime);

    event AddedDebt(bytes32 indexed _id, uint256 _amount);

    event AddedPaid(bytes32 indexed _id, uint256 _paid);

    bytes4 internal constant MODEL_INTERFACE = 0xaf498c35;


    function modelId() external view returns (bytes32);


    function descriptor() external view returns (address);


    function isOperator(address operator) external view returns (bool canOperate);


    function validate(bytes calldata data) external view returns (bool isValid);



    function getStatus(bytes32 id) external view returns (Status status);


    function getPaid(bytes32 id) external view returns (uint256 paid);


    function getObligation(bytes32 id, uint64 timestamp) external view returns (uint256 amount, bool defined);


    function getClosingObligation(bytes32 id) external view returns (uint256 amount);


    function getDueTime(bytes32 id) external view returns (uint256 timestamp);



    function getFrequency(bytes32 id) external view returns (uint256 frequency);


    function getInstallments(bytes32 id) external view returns (uint256 installments);


    function getFinalTime(bytes32 id) external view returns (uint256 timestamp);


    function getEstimateObligation(bytes32 id) external view returns (uint256 amount);



    function create(bytes32 id, bytes calldata data) external returns (bool success);


    function addPaid(bytes32 id, uint256 amount) external returns (uint256 real);


    function addDebt(bytes32 id, uint256 amount) external returns (bool added);



    function run(bytes32 id) external returns (bool effect);

}


pragma solidity ^0.5.11;



contract RateOracle is IERC165 {

    uint256 public constant VERSION = 5;
    bytes4 internal constant RATE_ORACLE_INTERFACE = 0xa265d8e0;

    constructor() internal {}

    function symbol() external view returns (string memory);


    function name() external view returns (string memory);


    function decimals() external view returns (uint256);


    function token() external view returns (address);


    function currency() external view returns (bytes32);


    function maintainer() external view returns (string memory);


    function url() external view returns (string memory);


    function readSample(bytes calldata _data) external returns (uint256 _tokens, uint256 _equivalent);

}


pragma solidity ^0.5.11;


library IsContract {

    function isContract(address _addr) internal view returns (bool) {

        uint size;
        assembly { size := extcodesize(_addr) }
        return size > 0;
    }
}


pragma solidity ^0.5.11;


library SafeMath {

    using SafeMath for uint256;

    function add(uint256 x, uint256 y) internal pure returns (uint256) {

        uint256 z = x + y;
        require(z >= x, "Add overflow");
        return z;
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256) {

        require(x >= y, "Sub overflow");
        return x - y;
    }

    function mult(uint256 x, uint256 y) internal pure returns (uint256) {

        if (x == 0) {
            return 0;
        }

        uint256 z = x * y;
        require(z/x == y, "Mult overflow");
        return z;
    }

    function div(uint256 x, uint256 y) internal pure returns (uint256) {

        require(y != 0, "Div by zero");
        return x / y;
    }

    function multdiv(uint256 x, uint256 y, uint256 z) internal pure returns (uint256) {

        require(z != 0, "div by zero");
        return x.mult(y) / z;
    }
}


pragma solidity ^0.5.11;



contract ERC165 is IERC165 {

    bytes4 private constant _InterfaceId_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor()
        internal
    {
        _registerInterface(_InterfaceId_ERC165);
    }

    function supportsInterface(bytes4 interfaceId)
        external
        view
        returns (bool)
    {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId)
        internal
    {

        require(interfaceId != 0xffffffff, "Can't register 0xffffffff");
        _supportedInterfaces[interfaceId] = true;
    }
}


pragma solidity ^0.5.11;





interface URIProvider {

    function tokenURI(uint256 _tokenId) external view returns (string memory);

}


contract ERC721Base is ERC165 {

    using SafeMath for uint256;
    using IsContract for address;

    mapping(uint256 => address) private _holderOf;

    mapping(address => uint256[]) private _assetsOf;
    mapping(uint256 => uint256) private _indexOfAsset;

    mapping(address => mapping(address => bool)) private _operators;
    mapping(uint256 => address) private _approval;

    bytes4 private constant ERC721_RECEIVED = 0x150b7a02;
    bytes4 private constant ERC721_RECEIVED_LEGACY = 0xf0b9e5ba;

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    bytes4 private constant ERC_721_INTERFACE = 0x80ac58cd;
    bytes4 private constant ERC_721_METADATA_INTERFACE = 0x5b5e139f;
    bytes4 private constant ERC_721_ENUMERATION_INTERFACE = 0x780e9d63;

    constructor(
        string memory name,
        string memory symbol
    ) public {
        _name = name;
        _symbol = symbol;

        _registerInterface(ERC_721_INTERFACE);
        _registerInterface(ERC_721_METADATA_INTERFACE);
        _registerInterface(ERC_721_ENUMERATION_INTERFACE);
    }



    event SetURIProvider(address _uriProvider);

    string private _name;
    string private _symbol;

    URIProvider private _uriProvider;

    function name() external view returns (string memory) {

        return _name;
    }

    function symbol() external view returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 _tokenId) external view returns (string memory) {

        require(_holderOf[_tokenId] != address(0), "Asset does not exist");
        URIProvider provider = _uriProvider;
        return address(provider) == address(0) ? "" : provider.tokenURI(_tokenId);
    }

    function _setURIProvider(URIProvider _provider) internal returns (bool) {

        emit SetURIProvider(address(_provider));
        _uriProvider = _provider;
        return true;
    }



    uint256[] private _allTokens;

    function allTokens() external view returns (uint256[] memory) {

        return _allTokens;
    }

    function assetsOf(address _owner) external view returns (uint256[] memory) {

        return _assetsOf[_owner];
    }

    function totalSupply() external view returns (uint256) {

        return _allTokens.length;
    }

    function tokenByIndex(uint256 _index) external view returns (uint256) {

        require(_index < _allTokens.length, "Index out of bounds");
        return _allTokens[_index];
    }

    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256) {

        require(_owner != address(0), "0x0 Is not a valid owner");
        require(_index < _balanceOf(_owner), "Index out of bounds");
        return _assetsOf[_owner][_index];
    }


    function ownerOf(uint256 _assetId) external view returns (address) {

        return _ownerOf(_assetId);
    }

    function _ownerOf(uint256 _assetId) internal view returns (address) {

        return _holderOf[_assetId];
    }

    function balanceOf(address _owner) external view returns (uint256) {

        return _balanceOf(_owner);
    }

    function _balanceOf(address _owner) internal view returns (uint256) {

        return _assetsOf[_owner].length;
    }


    function isApprovedForAll(
        address _operator,
        address _assetHolder
    ) external view returns (bool) {

        return _isApprovedForAll(_operator, _assetHolder);
    }

    function _isApprovedForAll(
        address _operator,
        address _assetHolder
    ) internal view returns (bool) {

        return _operators[_assetHolder][_operator];
    }

    function getApproved(uint256 _assetId) external view returns (address) {

        return _getApproved(_assetId);
    }

    function _getApproved(uint256 _assetId) internal view returns (address) {

        return _approval[_assetId];
    }

    function isAuthorized(address _operator, uint256 _assetId) external view returns (bool) {

        return _isAuthorized(_operator, _assetId);
    }

    function _isAuthorized(address _operator, uint256 _assetId) internal view returns (bool) {

        require(_operator != address(0), "0x0 is an invalid operator");
        address owner = _ownerOf(_assetId);

        return _operator == owner || _isApprovedForAll(_operator, owner) || _getApproved(_assetId) == _operator;
    }


    function setApprovalForAll(address _operator, bool _authorized) external {

        if (_operators[msg.sender][_operator] != _authorized) {
            _operators[msg.sender][_operator] = _authorized;
            emit ApprovalForAll(msg.sender, _operator, _authorized);
        }
    }

    function approve(address _operator, uint256 _assetId) external {

        address holder = _ownerOf(_assetId);
        require(msg.sender == holder || _isApprovedForAll(msg.sender, holder), "msg.sender can't approve");
        if (_getApproved(_assetId) != _operator) {
            _approval[_assetId] = _operator;
            emit Approval(holder, _operator, _assetId);
        }
    }


    function _addAssetTo(address _to, uint256 _assetId) private {

        _holderOf[_assetId] = _to;

        uint256 length = _balanceOf(_to);
        _assetsOf[_to].push(_assetId);
        _indexOfAsset[_assetId] = length;

        _allTokens.push(_assetId);
    }

    function _transferAsset(address _from, address _to, uint256 _assetId) private {

        uint256 assetIndex = _indexOfAsset[_assetId];
        uint256 lastAssetIndex = _balanceOf(_from).sub(1);

        if (assetIndex != lastAssetIndex) {
            uint256 lastAssetId = _assetsOf[_from][lastAssetIndex];
            _assetsOf[_from][assetIndex] = lastAssetId;
            _indexOfAsset[lastAssetId] = assetIndex;
        }

        _assetsOf[_from][lastAssetIndex] = 0;
        _assetsOf[_from].length--;

        _holderOf[_assetId] = _to;

        uint256 length = _balanceOf(_to);
        _assetsOf[_to].push(_assetId);
        _indexOfAsset[_assetId] = length;
    }

    function _clearApproval(address _holder, uint256 _assetId) private {

        if (_approval[_assetId] != address(0)) {
            _approval[_assetId] = address(0);
            emit Approval(_holder, address(0), _assetId);
        }
    }


    function _generate(uint256 _assetId, address _beneficiary) internal {

        require(_holderOf[_assetId] == address(0), "Asset already exists");

        _addAssetTo(_beneficiary, _assetId);

        emit Transfer(address(0), _beneficiary, _assetId);
    }


    modifier onlyAuthorized(uint256 _assetId) {

        require(_isAuthorized(msg.sender, _assetId), "msg.sender Not authorized");
        _;
    }

    modifier isCurrentOwner(address _from, uint256 _assetId) {

        require(_ownerOf(_assetId) == _from, "Not current owner");
        _;
    }

    modifier addressDefined(address _target) {

        require(_target != address(0), "Target can't be 0x0");
        _;
    }

    function safeTransferFrom(address _from, address _to, uint256 _assetId) external {

        return _doTransferFrom(
            _from,
            _to,
            _assetId,
            "",
            true
        );
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _assetId,
        bytes calldata _userData
    ) external {

        return _doTransferFrom(
            _from,
            _to,
            _assetId,
            _userData,
            true
        );
    }

    function transferFrom(address _from, address _to, uint256 _assetId) external {

        return _doTransferFrom(
            _from,
            _to,
            _assetId,
            "",
            false
        );
    }

    function _doTransferFrom(
        address _from,
        address _to,
        uint256 _assetId,
        bytes memory _userData,
        bool _doCheck
    )
        internal
        onlyAuthorized(_assetId)
        addressDefined(_to)
        isCurrentOwner(_from, _assetId)
    {

        address holder = _holderOf[_assetId];
        _clearApproval(holder, _assetId);
        _transferAsset(holder, _to, _assetId);

        if (_doCheck && _to.isContract()) {
            (bool success, bytes4 result) = _noThrowCall(
                _to,
                abi.encodeWithSelector(
                    ERC721_RECEIVED,
                    msg.sender,
                    holder,
                    _assetId,
                    _userData
                )
            );

            if (!success || result != ERC721_RECEIVED) {
                (success, result) = _noThrowCall(
                    _to,
                    abi.encodeWithSelector(
                        ERC721_RECEIVED_LEGACY,
                        holder,
                        _assetId,
                        _userData
                    )
                );

                require(
                    success && result == ERC721_RECEIVED_LEGACY,
                    "Contract rejected the token"
                );
            }
        }

        emit Transfer(holder, _to, _assetId);
    }


    function _noThrowCall(
        address _contract,
        bytes memory _data
    ) internal returns (bool success, bytes4 result) {

        bytes memory returnData;
        (success, returnData) = _contract.call(_data);

        if (returnData.length > 0)
            result = abi.decode(returnData, (bytes4));
    }
}


pragma solidity ^0.5.11;


contract IERC173 {

    event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);


    function transferOwnership(address _newOwner) external;

}


pragma solidity ^0.5.11;



contract Ownable is IERC173 {

    address internal _owner;

    modifier onlyOwner() {

        require(msg.sender == _owner, "The owner should be the sender");
        _;
    }

    constructor() public {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0x0), msg.sender);
    }

    function owner() external view returns (address) {

        return _owner;
    }

    function transferOwnership(address _newOwner) external onlyOwner {

        require(_newOwner != address(0), "0x0 Is not a valid owner");
        emit OwnershipTransferred(_owner, _newOwner);
        _owner = _newOwner;
    }
}


pragma solidity ^0.5.11;









contract DebtEngine is ERC721Base, Ownable, IDebtStatus {

    using IsContract for address;

    event Created(
        bytes32 indexed _id,
        uint256 _nonce,
        bytes _data
    );

    event Created2(
        bytes32 indexed _id,
        uint256 _salt,
        bytes _data
    );

    event Created3(
        bytes32 indexed _id,
        uint256 _salt,
        bytes _data
    );

    event Paid(
        bytes32 indexed _id,
        address _sender,
        address _origin,
        uint256 _requested,
        uint256 _requestedTokens,
        uint256 _paid,
        uint256 _tokens
    );

    event ReadedOracleBatch(
        address _oracle,
        uint256 _count,
        uint256 _tokens,
        uint256 _equivalent
    );

    event ReadedOracle(
        bytes32 indexed _id,
        uint256 _tokens,
        uint256 _equivalent
    );

    event PayBatchError(
        bytes32 indexed _id,
        address _targetOracle
    );

    event Withdrawn(
        bytes32 indexed _id,
        address _sender,
        address _to,
        uint256 _amount
    );

    event Error(
        bytes32 indexed _id,
        address _sender,
        uint256 _value,
        uint256 _gasLeft,
        uint256 _gasLimit,
        bytes _callData
    );

    event ErrorRecover(
        bytes32 indexed _id,
        address _sender,
        uint256 _value,
        uint256 _gasLeft,
        uint256 _gasLimit,
        bytes32 _result,
        bytes _callData
    );

    IERC20 public token;

    mapping(bytes32 => Debt) public debts;
    mapping(address => uint256) public nonces;

    struct Debt {
        bool error;
        uint128 balance;
        Model model;
        address creator;
        address oracle;
    }

    constructor (
        IERC20 _token
    ) public ERC721Base("RCN Debt Record", "RDR") {
        token = _token;

        require(address(_token).isContract(), "Token should be a contract");
    }

    function setURIProvider(URIProvider _provider) external onlyOwner {

        _setURIProvider(_provider);
    }

    function create(
        Model _model,
        address _owner,
        address _oracle,
        bytes calldata _data
    ) external returns (bytes32 id) {

        uint256 nonce = nonces[msg.sender]++;
        id = keccak256(
            abi.encodePacked(
                uint8(1),
                address(this),
                msg.sender,
                nonce
            )
        );

        debts[id] = Debt({
            error: false,
            balance: 0,
            creator: msg.sender,
            model: _model,
            oracle: _oracle
        });

        _generate(uint256(id), _owner);
        require(_model.create(id, _data), "Error creating debt in model");

        emit Created({
            _id: id,
            _nonce: nonce,
            _data: _data
        });
    }

    function create2(
        Model _model,
        address _owner,
        address _oracle,
        uint256 _salt,
        bytes calldata _data
    ) external returns (bytes32 id) {

        id = keccak256(
            abi.encodePacked(
                uint8(2),
                address(this),
                msg.sender,
                _model,
                _oracle,
                _salt,
                _data
            )
        );

        debts[id] = Debt({
            error: false,
            balance: 0,
            creator: msg.sender,
            model: _model,
            oracle: _oracle
        });

        _generate(uint256(id), _owner);
        require(_model.create(id, _data), "Error creating debt in model");

        emit Created2({
            _id: id,
            _salt: _salt,
            _data: _data
        });
    }

    function create3(
        Model _model,
        address _owner,
        address _oracle,
        uint256 _salt,
        bytes calldata _data
    ) external returns (bytes32 id) {

        id = keccak256(
            abi.encodePacked(
                uint8(3),
                address(this),
                msg.sender,
                _salt
            )
        );

        debts[id] = Debt({
            error: false,
            balance: 0,
            creator: msg.sender,
            model: _model,
            oracle: _oracle
        });

        _generate(uint256(id), _owner);
        require(_model.create(id, _data), "Error creating debt in model");

        emit Created3({
            _id: id,
            _salt: _salt,
            _data: _data
        });
    }

    function buildId(
        address _creator,
        uint256 _nonce
    ) external view returns (bytes32) {

        return keccak256(
            abi.encodePacked(
                uint8(1),
                address(this),
                _creator,
                _nonce
            )
        );
    }

    function buildId2(
        address _creator,
        address _model,
        address _oracle,
        uint256 _salt,
        bytes calldata _data
    ) external view returns (bytes32) {

        return keccak256(
            abi.encodePacked(
                uint8(2),
                address(this),
                _creator,
                _model,
                _oracle,
                _salt,
                _data
            )
        );
    }

    function buildId3(
        address _creator,
        uint256 _salt
    ) external view returns (bytes32) {

        return keccak256(
            abi.encodePacked(
                uint8(3),
                address(this),
                _creator,
                _salt
            )
        );
    }

    function pay(
        bytes32 _id,
        uint256 _amount,
        address _origin,
        bytes calldata _oracleData
    ) external returns (uint256 paid, uint256 paidToken) {

        Debt storage debt = debts[_id];
        paid = _safePay(_id, debt.model, _amount);
        require(paid <= _amount, "Paid can't be more than requested");

        RateOracle oracle = RateOracle(debt.oracle);
        if (address(oracle) != address(0)) {
            (uint256 tokens, uint256 equivalent) = oracle.readSample(_oracleData);
            emit ReadedOracle(_id, tokens, equivalent);
            paidToken = _toToken(paid, tokens, equivalent);
        } else {
            paidToken = paid;
        }

        require(token.transferFrom(msg.sender, address(this), paidToken), "Error pulling payment tokens");

        uint256 newBalance = paidToken.add(debt.balance);
        require(newBalance < 340282366920938463463374607431768211456, "uint128 Overflow");
        debt.balance = uint128(newBalance);

        emit Paid({
            _id: _id,
            _sender: msg.sender,
            _origin: _origin,
            _requested: _amount,
            _requestedTokens: 0,
            _paid: paid,
            _tokens: paidToken
        });
    }

    function payToken(
        bytes32 id,
        uint256 amount,
        address origin,
        bytes calldata oracleData
    ) external returns (uint256 paid, uint256 paidToken) {

        Debt storage debt = debts[id];
        RateOracle oracle = RateOracle(debt.oracle);

        uint256 equivalent;
        uint256 tokens;
        uint256 available;

        if (address(oracle) != address(0)) {
            (tokens, equivalent) = oracle.readSample(oracleData);
            emit ReadedOracle(id, tokens, equivalent);
            available = _fromToken(amount, tokens, equivalent);
        } else {
            available = amount;
        }

        paid = _safePay(id, debt.model, available);
        require(paid <= available, "Paid can't exceed available");

        if (address(oracle) != address(0)) {
            paidToken = _toToken(paid, tokens, equivalent);
            require(paidToken <= amount, "Paid can't exceed requested");
        } else {
            paidToken = paid;
        }

        require(token.transferFrom(msg.sender, address(this), paidToken), "Error pulling tokens");

        available = paidToken.add(debt.balance);
        require(available < 340282366920938463463374607431768211456, "uint128 Overflow");
        debt.balance = uint128(available);

        emit Paid({
            _id: id,
            _sender: msg.sender,
            _origin: origin,
            _requested: 0,
            _requestedTokens: amount,
            _paid: paid,
            _tokens: paidToken
        });
    }

    function payBatch(
        bytes32[] calldata _ids,
        uint256[] calldata _amounts,
        address _origin,
        address _oracle,
        bytes calldata _oracleData
    ) external returns (uint256[] memory paid, uint256[] memory paidTokens) {

        uint256 count = _ids.length;
        require(count == _amounts.length, "_ids and _amounts should have the same length");

        uint256 tokens;
        uint256 equivalent;
        if (_oracle != address(0)) {
            (tokens, equivalent) = RateOracle(_oracle).readSample(_oracleData);
            emit ReadedOracleBatch(_oracle, count, tokens, equivalent);
        }

        paid = new uint256[](count);
        paidTokens = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            uint256 amount = _amounts[i];
            (paid[i], paidTokens[i]) = _pay(_ids[i], _oracle, amount, tokens, equivalent);

            emit Paid({
                _id: _ids[i],
                _sender: msg.sender,
                _origin: _origin,
                _requested: amount,
                _requestedTokens: 0,
                _paid: paid[i],
                _tokens: paidTokens[i]
            });
        }
    }

    function payTokenBatch(
        bytes32[] calldata _ids,
        uint256[] calldata _tokenAmounts,
        address _origin,
        address _oracle,
        bytes calldata _oracleData
    ) external returns (uint256[] memory paid, uint256[] memory paidTokens) {

        uint256 count = _ids.length;
        require(count == _tokenAmounts.length, "_ids and _amounts should have the same length");

        uint256 tokens;
        uint256 equivalent;
        if (_oracle != address(0)) {
            (tokens, equivalent) = RateOracle(_oracle).readSample(_oracleData);
            emit ReadedOracleBatch(_oracle, count, tokens, equivalent);
        }

        paid = new uint256[](count);
        paidTokens = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            uint256 tokenAmount = _tokenAmounts[i];
            (paid[i], paidTokens[i]) = _pay(
                _ids[i],
                _oracle,
                _oracle != address(0) ? _fromToken(tokenAmount, tokens, equivalent) : tokenAmount,
                tokens,
                equivalent
            );
            require(paidTokens[i] <= tokenAmount, "Paid can't exceed requested");

            emit Paid({
                _id: _ids[i],
                _sender: msg.sender,
                _origin: _origin,
                _requested: 0,
                _requestedTokens: tokenAmount,
                _paid: paid[i],
                _tokens: paidTokens[i]
            });
        }
    }

    function _pay(
        bytes32 _id,
        address _oracle,
        uint256 _amount,
        uint256 _tokens,
        uint256 _equivalent
    ) internal returns (uint256 paid, uint256 paidToken){

        Debt storage debt = debts[_id];

        if (_oracle != debt.oracle) {
            emit PayBatchError(
                _id,
                _oracle
            );

            return (0,0);
        }

        paid = _safePay(_id, debt.model, _amount);
        require(paid <= _amount, "Paid can't be more than requested");

        paidToken = _oracle != address(0) ? _toToken(paid, _tokens, _equivalent) : paid;

        require(token.transferFrom(msg.sender, address(this), paidToken), "Error pulling payment tokens");

        uint256 newBalance = paidToken.add(debt.balance);
        require(newBalance < 340282366920938463463374607431768211456, "uint128 Overflow");
        debt.balance = uint128(newBalance);
    }

    function _safePay(
        bytes32 _id,
        Model _model,
        uint256 _available
    ) internal returns (uint256) {

        require(_model != Model(0), "Debt does not exist");

        (bool success, bytes32 paid) = _safeGasCall(
            address(_model),
            abi.encodeWithSelector(
                _model.addPaid.selector,
                _id,
                _available
            )
        );

        if (success) {
            if (debts[_id].error) {
                emit ErrorRecover({
                    _id: _id,
                    _sender: msg.sender,
                    _value: 0,
                    _gasLeft: gasleft(),
                    _gasLimit: block.gaslimit,
                    _result: paid,
                    _callData: msg.data
                });

                delete debts[_id].error;
            }

            return uint256(paid);
        } else {
            emit Error({
                _id: _id,
                _sender: msg.sender,
                _value: msg.value,
                _gasLeft: gasleft(),
                _gasLimit: block.gaslimit,
                _callData: msg.data
            });
            debts[_id].error = true;
        }
    }

    function _toToken(
        uint256 _amount,
        uint256 _tokens,
        uint256 _equivalent
    ) internal pure returns (uint256 _result) {

        require(_tokens != 0 && _equivalent != 0, "Oracle provided invalid rate");
        uint256 aux = _tokens.mult(_amount);
        _result = aux / _equivalent;
        if (aux % _equivalent > 0) {
            _result = _result.add(1);
        }
    }

    function _fromToken(
        uint256 _amount,
        uint256 _tokens,
        uint256 _equivalent
    ) internal pure returns (uint256) {

        require(_tokens != 0 && _equivalent != 0, "Oracle provided invalid rate");
        return _amount.mult(_equivalent) / _tokens;
    }

    function run(bytes32 _id) external returns (bool) {

        Debt storage debt = debts[_id];
        require(debt.model != Model(0), "Debt does not exist");

        (bool success, bytes32 result) = _safeGasCall(
            address(debt.model),
            abi.encodeWithSelector(
                debt.model.run.selector,
                _id
            )
        );

        if (success) {
            if (debt.error) {
                emit ErrorRecover({
                    _id: _id,
                    _sender: msg.sender,
                    _value: 0,
                    _gasLeft: gasleft(),
                    _gasLimit: block.gaslimit,
                    _result: result,
                    _callData: msg.data
                });

                delete debt.error;
            }

            return result == bytes32(uint256(1));
        } else {
            emit Error({
                _id: _id,
                _sender: msg.sender,
                _value: 0,
                _gasLeft: gasleft(),
                _gasLimit: block.gaslimit,
                _callData: msg.data
            });
            debt.error = true;
        }
    }

    function withdraw(bytes32 _id, address _to) external returns (uint256 amount) {

        require(_to != address(0x0), "_to should not be 0x0");
        require(_isAuthorized(msg.sender, uint256(_id)), "Sender not authorized");
        Debt storage debt = debts[_id];
        amount = debt.balance;
        debt.balance = 0;
        require(token.transfer(_to, amount), "Error sending tokens");
        emit Withdrawn({
            _id: _id,
            _sender: msg.sender,
            _to: _to,
            _amount: amount
        });
    }

    function withdrawPartial(bytes32 _id, address _to, uint256 _amount) external returns (bool success) {

        require(_to != address(0x0), "_to should not be 0x0");
        require(_isAuthorized(msg.sender, uint256(_id)), "Sender not authorized");
        Debt storage debt = debts[_id];
        require(debt.balance >= _amount, "Debt balance is not enought");
        debt.balance = uint128(uint256(debt.balance).sub(_amount));
        require(token.transfer(_to, _amount), "Error sending tokens");
        emit Withdrawn({
            _id: _id,
            _sender: msg.sender,
            _to: _to,
            _amount: _amount
        });
        success = true;
    }

    function withdrawBatch(bytes32[] calldata _ids, address _to) external returns (uint256 total) {

        require(_to != address(0x0), "_to should not be 0x0");
        bytes32 target;
        uint256 balance;
        for (uint256 i = 0; i < _ids.length; i++) {
            target = _ids[i];
            if (_isAuthorized(msg.sender, uint256(target))) {
                balance = debts[target].balance;
                debts[target].balance = 0;
                total += balance;
                emit Withdrawn({
                    _id: target,
                    _sender: msg.sender,
                    _to: _to,
                    _amount: balance
                });
            }
        }
        require(token.transfer(_to, total), "Error sending tokens");
    }

    function getStatus(bytes32 _id) external view returns (Status) {

        Debt storage debt = debts[_id];
        if (debt.error) {
            return Status.ERROR;
        } else {
            (bool success, uint256 result) = _safeGasStaticCall(
                address(debt.model),
                abi.encodeWithSelector(
                    debt.model.getStatus.selector,
                    _id
                )
            );
            return success ? Status(result) : Status.ERROR;
        }
    }

    function _safeGasStaticCall(
        address _contract,
        bytes memory _data
    ) internal view returns (bool success, uint256 result) {

        bytes memory returnData;
        uint256 _gas = (block.gaslimit * 80) / 100;

        (success, returnData) = _contract.staticcall.gas(gasleft() < _gas ? gasleft() : _gas)(_data);

        if (returnData.length > 0)
            result = abi.decode(returnData, (uint256));
    }

    function _safeGasCall(
        address _contract,
        bytes memory _data
    ) internal returns (bool success, bytes32 result) {

        bytes memory returnData;
        uint256 _gas = (block.gaslimit * 80) / 100;

        (success, returnData) = _contract.call.gas(gasleft() < _gas ? gasleft() : _gas)(_data);

        if (returnData.length > 0)
            result = abi.decode(returnData, (bytes32));
    }
}


pragma solidity ^0.5.11;



contract LoanApprover is IERC165 {

    function approveRequest(bytes32 _futureDebt) external returns (bytes32);


    function settleApproveRequest(
        bytes calldata _requestData,
        bytes calldata _loanData,
        bool _isBorrower,
        uint256 _id
    )
        external returns (bytes32);

}


pragma solidity ^0.5.11;


interface LoanCallback {

    function scheme() external view returns (string memory);


    function onLent(
        bytes32 _id,
        address _lender,
        bytes calldata _data
    ) external returns (bool);


    function acceptsLoan(
        address _engine,
        bytes32 _id,
        address _lender,
        bytes calldata _data
    ) external view returns (bool);

}


pragma solidity ^0.5.11;


library ImplementsInterface {

    bytes4 constant InvalidID = 0xffffffff;
    bytes4 constant ERC165ID = 0x01ffc9a7;

    function implementsMethod(address _contract, bytes4 _interfaceId) internal view returns (bool) {

        (uint256 success, uint256 result) = _noThrowImplements(_contract, ERC165ID);
        if ((success==0)||(result==0)) {
            return false;
        }

        (success, result) = _noThrowImplements(_contract, InvalidID);
        if ((success==0)||(result!=0)) {
            return false;
        }

        (success, result) = _noThrowImplements(_contract, _interfaceId);
        if ((success==1)&&(result==1)) {
            return true;
        }

        return false;
    }

    function _noThrowImplements(
        address _contract,
        bytes4 _interfaceId
    ) private view returns (uint256 success, uint256 result) {

        bytes4 erc165ID = ERC165ID;
        assembly {
            let x := mload(0x40)               // Find empty storage location using "free memory pointer"
            mstore(x, erc165ID)                // Place signature at begining of empty storage
            mstore(add(x, 0x04), _interfaceId) // Place first argument directly next to signature

            success := staticcall(
                                30000,         // 30k gas
                                _contract,     // To addr
                                x,             // Inputs are stored at location x
                                0x24,          // Inputs are 32 bytes long
                                x,             // Store output over input (saves space)
                                0x20)          // Outputs are 32 bytes long

            result := mload(x)                 // Load the result
        }
    }
}


pragma solidity ^0.5.11;


contract BytesUtils {

    function readBytes32(bytes memory data, uint256 index) internal pure returns (bytes32 o) {

        require(data.length / 32 > index, "Reading bytes out of bounds");
        assembly {
            o := mload(add(data, add(32, mul(32, index))))
        }
    }

    function read(bytes memory data, uint256 offset, uint256 length) internal pure returns (bytes32 o) {

        require(data.length >= offset + length, "Reading bytes out of bounds");
        assembly {
            o := mload(add(data, add(32, offset)))
            let lb := sub(32, length)
            if lb { o := div(o, exp(2, mul(lb, 8))) }
        }
    }

    function decode(
        bytes memory _data,
        uint256 _la
    ) internal pure returns (bytes32 _a) {

        require(_data.length >= _la, "Reading bytes out of bounds");
        assembly {
            _a := mload(add(_data, 32))
            let l := sub(32, _la)
            if l { _a := div(_a, exp(2, mul(l, 8))) }
        }
    }

    function decode(
        bytes memory _data,
        uint256 _la,
        uint256 _lb
    ) internal pure returns (bytes32 _a, bytes32 _b) {

        uint256 o;
        assembly {
            let s := add(_data, 32)
            _a := mload(s)
            let l := sub(32, _la)
            if l { _a := div(_a, exp(2, mul(l, 8))) }
            o := add(s, _la)
            _b := mload(o)
            l := sub(32, _lb)
            if l { _b := div(_b, exp(2, mul(l, 8))) }
            o := sub(o, s)
        }
        require(_data.length >= o, "Reading bytes out of bounds");
    }

    function decode(
        bytes memory _data,
        uint256 _la,
        uint256 _lb,
        uint256 _lc
    ) internal pure returns (bytes32 _a, bytes32 _b, bytes32 _c) {

        uint256 o;
        assembly {
            let s := add(_data, 32)
            _a := mload(s)
            let l := sub(32, _la)
            if l { _a := div(_a, exp(2, mul(l, 8))) }
            o := add(s, _la)
            _b := mload(o)
            l := sub(32, _lb)
            if l { _b := div(_b, exp(2, mul(l, 8))) }
            o := add(o, _lb)
            _c := mload(o)
            l := sub(32, _lc)
            if l { _c := div(_c, exp(2, mul(l, 8))) }
            o := sub(o, s)
        }
        require(_data.length >= o, "Reading bytes out of bounds");
    }

    function decode(
        bytes memory _data,
        uint256 _la,
        uint256 _lb,
        uint256 _lc,
        uint256 _ld
    ) internal pure returns (bytes32 _a, bytes32 _b, bytes32 _c, bytes32 _d) {

        uint256 o;
        assembly {
            let s := add(_data, 32)
            _a := mload(s)
            let l := sub(32, _la)
            if l { _a := div(_a, exp(2, mul(l, 8))) }
            o := add(s, _la)
            _b := mload(o)
            l := sub(32, _lb)
            if l { _b := div(_b, exp(2, mul(l, 8))) }
            o := add(o, _lb)
            _c := mload(o)
            l := sub(32, _lc)
            if l { _c := div(_c, exp(2, mul(l, 8))) }
            o := add(o, _lc)
            _d := mload(o)
            l := sub(32, _ld)
            if l { _d := div(_d, exp(2, mul(l, 8))) }
            o := sub(o, s)
        }
        require(_data.length >= o, "Reading bytes out of bounds");
    }

    function decode(
        bytes memory _data,
        uint256 _la,
        uint256 _lb,
        uint256 _lc,
        uint256 _ld,
        uint256 _le
    ) internal pure returns (bytes32 _a, bytes32 _b, bytes32 _c, bytes32 _d, bytes32 _e) {

        uint256 o;
        assembly {
            let s := add(_data, 32)
            _a := mload(s)
            let l := sub(32, _la)
            if l { _a := div(_a, exp(2, mul(l, 8))) }
            o := add(s, _la)
            _b := mload(o)
            l := sub(32, _lb)
            if l { _b := div(_b, exp(2, mul(l, 8))) }
            o := add(o, _lb)
            _c := mload(o)
            l := sub(32, _lc)
            if l { _c := div(_c, exp(2, mul(l, 8))) }
            o := add(o, _lc)
            _d := mload(o)
            l := sub(32, _ld)
            if l { _d := div(_d, exp(2, mul(l, 8))) }
            o := add(o, _ld)
            _e := mload(o)
            l := sub(32, _le)
            if l { _e := div(_e, exp(2, mul(l, 8))) }
            o := sub(o, s)
        }
        require(_data.length >= o, "Reading bytes out of bounds");
    }

    function decode(
        bytes memory _data,
        uint256 _la,
        uint256 _lb,
        uint256 _lc,
        uint256 _ld,
        uint256 _le,
        uint256 _lf
    ) internal pure returns (
        bytes32 _a,
        bytes32 _b,
        bytes32 _c,
        bytes32 _d,
        bytes32 _e,
        bytes32 _f
    ) {

        uint256 o;
        assembly {
            let s := add(_data, 32)
            _a := mload(s)
            let l := sub(32, _la)
            if l { _a := div(_a, exp(2, mul(l, 8))) }
            o := add(s, _la)
            _b := mload(o)
            l := sub(32, _lb)
            if l { _b := div(_b, exp(2, mul(l, 8))) }
            o := add(o, _lb)
            _c := mload(o)
            l := sub(32, _lc)
            if l { _c := div(_c, exp(2, mul(l, 8))) }
            o := add(o, _lc)
            _d := mload(o)
            l := sub(32, _ld)
            if l { _d := div(_d, exp(2, mul(l, 8))) }
            o := add(o, _ld)
            _e := mload(o)
            l := sub(32, _le)
            if l { _e := div(_e, exp(2, mul(l, 8))) }
            o := add(o, _le)
            _f := mload(o)
            l := sub(32, _lf)
            if l { _f := div(_f, exp(2, mul(l, 8))) }
            o := sub(o, s)
        }
        require(_data.length >= o, "Reading bytes out of bounds");
    }

}


pragma solidity ^0.5.11;












contract LoanManager is BytesUtils, IDebtStatus {

    using ImplementsInterface for address;
    using IsContract for address;
    using SafeMath for uint256;

    uint256 public constant GAS_CALLBACK = 300000;

    DebtEngine public debtEngine;
    IERC20 public token;

    mapping(bytes32 => Request) public requests;
    mapping(bytes32 => bool) public canceledSettles;

    event Requested(
        bytes32 indexed _id,
        uint128 _amount,
        address _model,
        address _creator,
        address _oracle,
        address _borrower,
        address _callback,
        uint256 _salt,
        bytes _loanData,
        uint256 _expiration
    );

    event Approved(bytes32 indexed _id);
    event Lent(bytes32 indexed _id, address _lender, uint256 _tokens);
    event Cosigned(bytes32 indexed _id, address _cosigner, uint256 _cost);
    event Canceled(bytes32 indexed _id, address _canceler);
    event ReadedOracle(address _oracle, uint256 _tokens, uint256 _equivalent);

    event ApprovedRejected(bytes32 indexed _id, bytes32 _response);
    event ApprovedError(bytes32 indexed _id, bytes32 _response);

    event ApprovedByCallback(bytes32 indexed _id);
    event ApprovedBySignature(bytes32 indexed _id);

    event CreatorByCallback(bytes32 indexed _id);
    event BorrowerByCallback(bytes32 indexed _id);
    event CreatorBySignature(bytes32 indexed _id);
    event BorrowerBySignature(bytes32 indexed _id);

    event SettledLend(bytes32 indexed _id, address _lender, uint256 _tokens);
    event SettledCancel(bytes32 indexed _id, address _canceler);

    constructor(DebtEngine _debtEngine) public {
        debtEngine = _debtEngine;
        token = debtEngine.token();
        require(address(token) != address(0), "Error loading token");
    }

    function getBorrower(uint256 _id) external view returns (address) { return requests[bytes32(_id)].borrower; }

    function getCreator(uint256 _id) external view returns (address) { return requests[bytes32(_id)].creator; }

    function getOracle(uint256 _id) external view returns (address) { return requests[bytes32(_id)].oracle; }

    function getCosigner(uint256 _id) external view returns (address) { return requests[bytes32(_id)].cosigner; }

    function getCurrency(uint256 _id) external view returns (bytes32) {

        address oracle = requests[bytes32(_id)].oracle;
        return oracle == address(0) ? bytes32(0x0) : RateOracle(oracle).currency();
    }
    function getAmount(uint256 _id) external view returns (uint256) { return requests[bytes32(_id)].amount; }

    function getExpirationRequest(uint256 _id) external view returns (uint256) { return requests[bytes32(_id)].expiration; }

    function getApproved(uint256 _id) external view returns (bool) { return requests[bytes32(_id)].approved; }

    function getDueTime(uint256 _id) external view returns (uint256) { return Model(requests[bytes32(_id)].model).getDueTime(bytes32(_id)); }

    function getClosingObligation(uint256 _id) external view returns (uint256) { return Model(requests[bytes32(_id)].model).getClosingObligation(bytes32(_id)); }

    function getLoanData(uint256 _id) external view returns (bytes memory) { return requests[bytes32(_id)].loanData; }

    function getStatus(uint256 _id) external view returns (Status) {

        Request storage request = requests[bytes32(_id)];
        return request.open ? Status.NULL : debtEngine.getStatus(bytes32(_id));
    }
    function ownerOf(uint256 _id) external view returns (address) {

        return debtEngine.ownerOf(_id);
    }

    function getBorrower(bytes32 _id) external view returns (address) { return requests[_id].borrower; }

    function getCreator(bytes32 _id) external view returns (address) { return requests[_id].creator; }

    function getOracle(bytes32 _id) external view returns (address) { return requests[_id].oracle; }

    function getCosigner(bytes32 _id) external view returns (address) { return requests[_id].cosigner; }

    function getCurrency(bytes32 _id) external view returns (bytes32) {

        address oracle = requests[_id].oracle;
        return oracle == address(0) ? bytes32(0x0) : RateOracle(oracle).currency();
    }
    function getAmount(bytes32 _id) external view returns (uint256) { return requests[_id].amount; }

    function getExpirationRequest(bytes32 _id) external view returns (uint256) { return requests[_id].expiration; }

    function getApproved(bytes32 _id) external view returns (bool) { return requests[_id].approved; }

    function getDueTime(bytes32 _id) external view returns (uint256) { return Model(requests[_id].model).getDueTime(bytes32(_id)); }

    function getClosingObligation(bytes32 _id) external view returns (uint256) { return Model(requests[_id].model).getClosingObligation(bytes32(_id)); }

    function getLoanData(bytes32 _id) external view returns (bytes memory) { return requests[_id].loanData; }

    function getStatus(bytes32 _id) external view returns (Status) {

        Request storage request = requests[_id];
        return request.open ? Status.NULL : debtEngine.getStatus(bytes32(_id));
    }
    function ownerOf(bytes32 _id) external view returns (address) {

        return debtEngine.ownerOf(uint256(_id));
    }

    function getCallback(bytes32 _id) external view returns (address) { return requests[_id].callback; }


    struct Request {
        bool open;
        bool approved;
        uint64 expiration;
        uint128 amount;
        address cosigner;
        address model;
        address creator;
        address oracle;
        address borrower;
        address callback;
        uint256 salt;
        bytes loanData;
    }

    function calcId(
        uint128 _amount,
        address _borrower,
        address _creator,
        address _model,
        address _oracle,
        address _callback,
        uint256 _salt,
        uint64 _expiration,
        bytes memory _data
    ) public view returns (bytes32) {

        uint256 internalSalt = _buildInternalSalt(
            _amount,
            _borrower,
            _creator,
            _callback,
            _salt,
            _expiration
        );

        return keccak256(
            abi.encodePacked(
                uint8(2),
                debtEngine,
                address(this),
                _model,
                _oracle,
                internalSalt,
                _data
            )
        );
    }

    function buildInternalSalt(
        uint128 _amount,
        address _borrower,
        address _creator,
        address _callback,
        uint256 _salt,
        uint64 _expiration
    ) external pure returns (uint256) {

        return _buildInternalSalt(
            _amount,
            _borrower,
            _creator,
            _callback,
            _salt,
            _expiration
        );
    }

    function internalSalt(bytes32 _id) external view returns (uint256) {

        Request storage request = requests[_id];
        require(request.borrower != address(0), "Request does not exist");
        return _internalSalt(request);
    }

    function _internalSalt(Request memory _request) internal pure returns (uint256) {

        return _buildInternalSalt(
            _request.amount,
            _request.borrower,
            _request.creator,
            _request.callback,
            _request.salt,
            _request.expiration
        );
    }

    function requestLoan(
        uint128 _amount,
        address _model,
        address _oracle,
        address _borrower,
        address _callback,
        uint256 _salt,
        uint64 _expiration,
        bytes calldata _loanData
    ) external returns (bytes32 id) {

        require(_borrower != address(0), "The request should have a borrower");
        require(Model(_model).validate(_loanData), "The loan data is not valid");

        id = calcId(
            _amount,
            _borrower,
            msg.sender,
            _model,
            _oracle,
            _callback,
            _salt,
            _expiration,
            _loanData
        );

        require(!canceledSettles[id], "The debt was canceled");

        require(requests[id].borrower == address(0), "Request already exist");

        bool approved = msg.sender == _borrower;

        requests[id] = Request({
            open: true,
            approved: approved,
            cosigner: address(0),
            amount: _amount,
            model: _model,
            creator: msg.sender,
            oracle: _oracle,
            borrower: _borrower,
            callback: _callback,
            salt: _salt,
            loanData: _loanData,
            expiration: _expiration
        });

        emit Requested(
            id,
            _amount,
            _model,
            msg.sender,
            _oracle,
            _borrower,
            _callback,
            _salt,
            _loanData,
            _expiration
        );

        if (!approved) {
            if (_borrower.isContract() && _borrower.implementsMethod(0x76ba6009)) {
                approved = _requestContractApprove(id, _borrower);
                requests[id].approved = approved;
            }
        }

        if (approved) {
            emit Approved(id);
        }
    }

    function _requestContractApprove(
        bytes32 _id,
        address _borrower
    ) internal returns (bool approved) {

        bytes32 expected = _id ^ 0xdfcb15a077f54a681c23131eacdfd6e12b5e099685b492d382c3fd8bfc1e9a2a;
        (bool success, bytes32 result) = _safeCall(
            _borrower,
            abi.encodeWithSelector(
                0x76ba6009,
                _id
            )
        );

        approved = success && result == expected;

        if (approved) {
            emit ApprovedByCallback(_id);
        } else {
            if (!success) {
                emit ApprovedError(_id, result);
            } else {
                emit ApprovedRejected(_id, result);
            }
        }
    }

    function approveRequest(
        bytes32 _id
    ) external returns (bool) {

        Request storage request = requests[_id];
        require(msg.sender == request.borrower, "Only borrower can approve");
        if (!request.approved) {
            request.approved = true;
            emit Approved(_id);
        }
        return true;
    }

    function registerApproveRequest(
        bytes32 _id,
        bytes calldata _signature
    ) external returns (bool approved) {

        Request storage request = requests[_id];
        address borrower = request.borrower;

        if (!request.approved) {
            if (borrower.isContract() && borrower.implementsMethod(0x76ba6009)) {
                approved = _requestContractApprove(_id, borrower);
            } else {
                bytes32 _hash = keccak256(
                    abi.encodePacked(
                        _id,
                        "sign approve request"
                    )
                );

                address signer = ecrecovery(
                    keccak256(
                        abi.encodePacked(
                            "\x19Ethereum Signed Message:\n32",
                            _hash
                        )
                    ),
                    _signature
                );

                if (borrower == signer) {
                    emit ApprovedBySignature(_id);
                    approved = true;
                }
            }
        }

        if (approved && !request.approved) {
            request.approved = true;
            emit Approved(_id);
        }
    }

    function lend(
        bytes32 _id,
        bytes memory _oracleData,
        address _cosigner,
        uint256 _cosignerLimit,
        bytes memory _cosignerData,
        bytes memory _callbackData
    ) public returns (bool) {

        Request storage request = requests[_id];
        require(request.open, "Request is no longer open");
        require(request.approved, "The request is not approved by the borrower");
        require(request.expiration > now, "The request is expired");

        request.open = false;

        uint256 tokens = _currencyToToken(request.oracle, request.amount, _oracleData);
        require(
            token.transferFrom(
                msg.sender,
                request.borrower,
                tokens
            ),
            "Error sending tokens to borrower"
        );

        emit Lent(_id, msg.sender, tokens);

        require(
            debtEngine.create2(
                Model(request.model),
                msg.sender,
                request.oracle,
                _internalSalt(request),
                request.loanData
            ) == _id,
            "Error creating the debt"
        );

        if (_cosigner != address(0)) {
            uint256 auxSalt = request.salt;
            request.cosigner = address(uint256(_cosigner) + 2);
            request.salt = _cosignerLimit; // Risky ?
            require(
                Cosigner(_cosigner).requestCosign(
                    address(this),
                    uint256(_id),
                    _cosignerData,
                    _oracleData
                ),
                "Cosign method returned false"
            );
            require(request.cosigner == _cosigner, "Cosigner didn't callback");
            request.salt = auxSalt;
        }

        address callback = request.callback;
        if (callback != address(0)) {
            require(LoanCallback(callback).onLent.gas(GAS_CALLBACK)(_id, msg.sender, _callbackData), "Rejected by loan callback");
        }

        return true;
    }

    function cancel(bytes32 _id) external returns (bool) {

        Request storage request = requests[_id];

        require(request.open, "Request is no longer open or not requested");
        require(
            request.creator == msg.sender || request.borrower == msg.sender,
            "Only borrower or creator can cancel a request"
        );

        delete request.loanData;
        delete requests[_id];
        canceledSettles[_id] = true;

        emit Canceled(_id, msg.sender);

        return true;
    }

    function cosign(uint256 _id, uint256 _cost) external returns (bool) {

        Request storage request = requests[bytes32(_id)];
        require(request.cosigner != address(0), "Cosigner 0x0 is not valid");
        require(request.expiration > now, "Request is expired");
        require(request.cosigner == address(uint256(msg.sender) + 2), "Cosigner not valid");
        request.cosigner = msg.sender;
        if (_cost != 0){
            require(request.salt >= _cost, "Cosigner cost exceeded");
            require(token.transferFrom(debtEngine.ownerOf(_id), msg.sender, _cost), "Error paying cosigner");
        }
        emit Cosigned(bytes32(_id), msg.sender, _cost);
        return true;
    }


    uint256 private constant L_AMOUNT = 16;
    uint256 private constant O_AMOUNT = 0;
    uint256 private constant O_MODEL = L_AMOUNT;
    uint256 private constant L_MODEL = 20;
    uint256 private constant O_ORACLE = O_MODEL + L_MODEL;
    uint256 private constant L_ORACLE = 20;
    uint256 private constant O_BORROWER = O_ORACLE + L_ORACLE;
    uint256 private constant L_BORROWER = 20;
    uint256 private constant O_SALT = O_BORROWER + L_BORROWER;
    uint256 private constant L_SALT = 32;
    uint256 private constant O_EXPIRATION = O_SALT + L_SALT;
    uint256 private constant L_EXPIRATION = 8;
    uint256 private constant O_CREATOR = O_EXPIRATION + L_EXPIRATION;
    uint256 private constant L_CREATOR = 20;
    uint256 private constant O_CALLBACK = O_CREATOR + L_CREATOR;
    uint256 private constant L_CALLBACK = 20;

    function encodeRequest(
        uint128 _amount,
        address _model,
        address _oracle,
        address _borrower,
        address _callback,
        uint256 _salt,
        uint64 _expiration,
        address _creator,
        bytes calldata _loanData
    ) external view returns (bytes memory requestData, bytes32 id) {

        requestData = abi.encodePacked(
            _amount,
            _model,
            _oracle,
            _borrower,
            _salt,
            _expiration,
            _creator,
            _callback
        );

        uint256 innerSalt = _buildInternalSalt(
            _amount,
            _borrower,
            _creator,
            _callback,
            _salt,
            _expiration
        );

        id = debtEngine.buildId2(
            address(this),
            _model,
            _oracle,
            innerSalt,
            _loanData
        );
    }

    function settleLend(
        bytes memory _requestData,
        bytes memory _loanData,
        address _cosigner,
        uint256 _maxCosignerCost,
        bytes memory _cosignerData,
        bytes memory _oracleData,
        bytes memory _creatorSig,
        bytes memory _borrowerSig,
        bytes memory _callbackData
    ) public returns (bytes32 id) {

        require(uint256(read(_requestData, O_EXPIRATION, L_EXPIRATION)) > now, "Loan request is expired");

        uint256 innerSalt;
        (id, innerSalt) = _buildSettleId(_requestData, _loanData);

        require(requests[id].borrower == address(0), "Request already exist");

        uint256 tokens = _currencyToToken(_requestData, _oracleData);
        require(
            token.transferFrom(
                msg.sender,
                address(uint256(read(_requestData, O_BORROWER, L_BORROWER))),
                tokens
            ),
            "Error sending tokens to borrower"
        );

        require(
            _createDebt(
                _requestData,
                _loanData,
                innerSalt
            ) == id,
            "Error creating debt registry"
        );

        emit SettledLend(id, msg.sender, tokens);

        requests[id] = Request({
            open: false,
            approved: true,
            cosigner: _cosigner,
            amount: uint128(uint256(read(_requestData, O_AMOUNT, L_AMOUNT))),
            model: address(uint256(read(_requestData, O_MODEL, L_MODEL))),
            creator: address(uint256(read(_requestData, O_CREATOR, L_CREATOR))),
            oracle: address(uint256(read(_requestData, O_ORACLE, L_ORACLE))),
            borrower: address(uint256(read(_requestData, O_BORROWER, L_BORROWER))),
            callback: address(uint256(read(_requestData, O_CALLBACK, L_CALLBACK))),
            salt: _cosigner != address(0) ? _maxCosignerCost : uint256(read(_requestData, O_SALT, L_SALT)),
            loanData: _loanData,
            expiration: uint64(uint256(read(_requestData, O_EXPIRATION, L_EXPIRATION)))
        });

        Request storage request = requests[id];

        _validateSettleSignatures(id, _requestData, _loanData, _creatorSig, _borrowerSig);

        if (_cosigner != address(0)) {
            request.cosigner = address(uint256(_cosigner) + 2);
            require(Cosigner(_cosigner).requestCosign(address(this), uint256(id), _cosignerData, _oracleData), "Cosign method returned false");
            require(request.cosigner == _cosigner, "Cosigner didn't callback");
            request.salt = uint256(read(_requestData, O_SALT, L_SALT));
        }

        address callback = address(uint256(read(_requestData, O_CALLBACK, L_CALLBACK)));
        if (callback != address(0)) {
            require(LoanCallback(callback).onLent.gas(GAS_CALLBACK)(id, msg.sender, _callbackData), "Rejected by loan callback");
        }
    }

    function settleCancel(
        bytes calldata _requestData,
        bytes calldata _loanData
    ) external returns (bool) {

        (bytes32 id, ) = _buildSettleId(_requestData, _loanData);
        require(
            msg.sender == address(uint256(read(_requestData, O_BORROWER, L_BORROWER))) ||
            msg.sender == address(uint256(read(_requestData, O_CREATOR, L_CREATOR))),
            "Only borrower or creator can cancel a settle"
        );
        canceledSettles[id] = true;
        emit SettledCancel(id, msg.sender);

        return true;
    }

    function _validateSettleSignatures(
        bytes32 _id,
        bytes memory _requestData,
        bytes memory _loanData,
        bytes memory _creatorSig,
        bytes memory _borrowerSig
    ) internal {

        require(!canceledSettles[_id], "Settle was canceled");

        bytes32 expected = _id ^ 0xdfcb15a077f54a681c23131eacdfd6e12b5e099685b492d382c3fd8bfc1e9a2a;
        address borrower = address(uint256(read(_requestData, O_BORROWER, L_BORROWER)));
        address creator = address(uint256(read(_requestData, O_CREATOR, L_CREATOR)));
        bytes32 _hash;

        if (borrower.isContract()) {
            require(
                LoanApprover(borrower).settleApproveRequest(_requestData, _loanData, true, uint256(_id)) == expected,
                "Borrower contract rejected the loan"
            );

            emit BorrowerByCallback(_id);
        } else {
            _hash = keccak256(
                abi.encodePacked(
                    _id,
                    "sign settle lend as borrower"
                )
            );
            require(
                borrower == ecrecovery(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)), _borrowerSig),
                "Invalid borrower signature"
            );

            emit BorrowerBySignature(_id);
        }

        if (borrower != creator) {
            if (creator.isContract()) {
                require(
                    LoanApprover(creator).settleApproveRequest(_requestData, _loanData, false, uint256(_id)) == expected,
                    "Creator contract rejected the loan"
                );

                emit CreatorByCallback(_id);
            } else {
                _hash = keccak256(
                    abi.encodePacked(
                        _id,
                        "sign settle lend as creator"
                    )
                );
                require(
                    creator == ecrecovery(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)), _creatorSig),
                    "Invalid creator signature"
                );

                emit CreatorBySignature(_id);
            }
        }
    }

    function _currencyToToken(
        bytes memory _requestData,
        bytes memory _oracleData
    ) internal returns (uint256) {

        return _currencyToToken(
            address(uint256(read(_requestData, O_ORACLE, L_ORACLE))),
            uint256(read(_requestData, O_AMOUNT, L_AMOUNT)),
            _oracleData
        );
    }

    function _createDebt(
        bytes memory _requestData,
        bytes memory _loanData,
        uint256 _innerSalt
    ) internal returns (bytes32) {

        return debtEngine.create2(
            Model(address(uint256(read(_requestData, O_MODEL, L_MODEL)))),
            msg.sender,
            address(uint256(read(_requestData, O_ORACLE, L_ORACLE))),
            _innerSalt,
            _loanData
        );
    }

    function _buildSettleId(
        bytes memory _requestData,
        bytes memory _loanData
    ) internal view returns (bytes32 id, uint256 innerSalt) {

        (
            uint128 amount,
            address model,
            address oracle,
            address borrower,
            uint256 salt,
            uint64 expiration,
            address creator
        ) = _decodeSettle(_requestData);

        innerSalt = _buildInternalSalt(
            amount,
            borrower,
            creator,
            address(uint256(read(_requestData, O_CALLBACK, L_CALLBACK))),
            salt,
            expiration
        );

        id = debtEngine.buildId2(
            address(this),
            model,
            oracle,
            innerSalt,
            _loanData
        );
    }

    function _buildInternalSalt(
        uint128 _amount,
        address _borrower,
        address _creator,
        address _callback,
        uint256 _salt,
        uint64 _expiration
    ) internal pure returns (uint256) {

        return uint256(
            keccak256(
                abi.encodePacked(
                    _amount,
                    _borrower,
                    _creator,
                    _callback,
                    _salt,
                    _expiration
                )
            )
        );
    }

    function _decodeSettle(
        bytes memory _data
    ) internal pure returns (
        uint128 amount,
        address model,
        address oracle,
        address borrower,
        uint256 salt,
        uint64 expiration,
        address creator
    ) {

        (
            bytes32 _amount,
            bytes32 _model,
            bytes32 _oracle,
            bytes32 _borrower,
            bytes32 _salt,
            bytes32 _expiration
        ) = decode(_data, L_AMOUNT, L_MODEL, L_ORACLE, L_BORROWER, L_SALT, L_EXPIRATION);

        amount = uint128(uint256(_amount));
        model = address(uint256(_model));
        oracle = address(uint256(_oracle));
        borrower = address(uint256(_borrower));
        salt = uint256(_salt);
        expiration = uint64(uint256(_expiration));
        creator = address(uint256(read(_data, O_CREATOR, L_CREATOR)));
    }

    function ecrecovery(bytes32 _hash, bytes memory _sig) internal pure returns (address) {

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := and(mload(add(_sig, 65)), 255)
        }

        if (v < 27) {
            v += 27;
        }

        return ecrecover(_hash, v, r, s);
    }

    function _currencyToToken(
        address _oracle,
        uint256 _amount,
        bytes memory _oracleData
    ) internal returns (uint256) {

        if (_oracle == address(0)) return _amount;
        (uint256 tokens, uint256 equivalent) = RateOracle(_oracle).readSample(_oracleData);

        emit ReadedOracle(_oracle, tokens, equivalent);

        return tokens.mult(_amount) / equivalent;
    }

    function _safeCall(
        address _contract,
        bytes memory _data
    ) internal returns (bool success, bytes32 result) {

        bytes memory returnData;
        (success, returnData) = _contract.call(_data);

        if (returnData.length > 0)
            result = abi.decode(returnData, (bytes32));
    }
}


pragma solidity ^0.5.11;


interface CollateralAuctionCallback {

    function auctionClosed(
        uint256 _id,
        uint256 _leftover,
        uint256 _received,
        bytes calldata _data
    ) external;

}


pragma solidity ^0.5.11;


interface CollateralHandler {

    function handle(
        uint256 _entryId,
        uint256 _amount,
        bytes calldata _data
    ) external returns (uint256 surplus);

}


pragma solidity ^0.5.11;


contract ReentrancyGuard {

    uint256 private _reentrantFlag;

    uint256 private constant FLAG_LOCKED = 1;
    uint256 private constant FLAG_UNLOCKED = 2;

    constructor() public {
        _reentrantFlag = FLAG_UNLOCKED;
    }

    modifier nonReentrant() {

        require(_reentrantFlag != FLAG_LOCKED, "ReentrancyGuard: reentrant call");

        _reentrantFlag = FLAG_LOCKED;
        _;
        _reentrantFlag = FLAG_UNLOCKED;
    }
}


pragma solidity ^0.5.11;



library Fixed224x32 {

    uint256 private constant BASE = 4294967296; // 2 ** 32
    uint256 private constant DEC_BITS = 32;
    uint256 private constant INT_BITS = 224;

    using Fixed224x32 for bytes32;
    using SafeMath for uint256;

    function from(
        uint256 _num
    ) internal pure returns (bytes32) {

        return bytes32(_num.mult(BASE));
    }

    function raw(
        uint256 _raw
    ) internal pure returns (bytes32) {

        return bytes32(_raw);
    }

    function toUint256(
        bytes32 _a
    ) internal pure returns (uint256) {

        return uint256(_a) >> DEC_BITS;
    }

    function add(
        bytes32 _a,
        bytes32 _b
    ) internal pure returns (bytes32) {

        return bytes32(uint256(_a).add(uint256(_b)));
    }

    function sub(
        bytes32 _a,
        bytes32 _b
    ) internal pure returns (bytes32) {

        return bytes32(uint256(_a).sub(uint256(_b)));
    }

    function mul(
        bytes32 _a,
        bytes32 _b
    ) internal pure returns (bytes32) {

        uint256 a = uint256(_a);
        uint256 b = uint256(_b);

        return bytes32((a.mult(b) >> DEC_BITS));
    }

    function floor(
        bytes32 _a
    ) internal pure returns (bytes32) {

        return (_a >> DEC_BITS) << DEC_BITS;
    }

    function ceil(
        bytes32 _a
    ) internal pure returns (bytes32) {

        uint256 rawDec = uint256(_a << INT_BITS);
        if (rawDec != 0) {
            uint256 diff = BASE.sub(rawDec >> INT_BITS);
            return bytes32(uint256(_a).add(diff));
        }

        return _a;
    }

    function div(
        bytes32 _a,
        bytes32 _b
    ) internal pure returns (bytes32) {

        uint256 a = uint256(_a);
        uint256 b = uint256(_b);

        return bytes32((a.mult(BASE)) / b);
    }

    function gt(
        bytes32 _a,
        bytes32 _b
    ) internal pure returns (bool) {

        return uint256(_a) > uint256(_b);
    }

    function gte(
        bytes32 _a,
        bytes32 _b
    ) internal pure returns (bool) {

        return uint256(_a) >= uint256(_b);
    }

    function lt(
        bytes32 _a,
        bytes32 _b
    ) internal pure returns (bool) {

        return uint256(_a) < uint256(_b);
    }

    function lte(
        bytes32 _a,
        bytes32 _b
    ) internal pure returns (bool) {

        return uint256(_a) <= uint256(_b);
    }

    function eq(
        bytes32 _a,
        bytes32 _b
    ) internal pure returns (bool) {

        return _a == _b;
    }
}


pragma solidity ^0.5.11;



library SafeERC20 {

    function safeTransfer(IERC20 _token, address _to, uint256 _value) internal returns (bool) {

        uint256 prevBalance = _token.balanceOf(address(this));

        if (prevBalance < _value) {
            return false;
        }

        address(_token).call(
            abi.encodeWithSignature("transfer(address,uint256)", _to, _value)
        );

        return prevBalance - _value == _token.balanceOf(address(this));
    }

    function safeTransferFrom(
        IERC20 _token,
        address _from,
        address _to,
        uint256 _value
    ) internal returns (bool)
    {

        uint256 prevBalance = _token.balanceOf(_from);

        if (
          prevBalance < _value || // Insufficient funds
          _token.allowance(_from, address(this)) < _value // Insufficient allowance
        ) {
            return false;
        }

        address(_token).call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", _from, _to, _value)
        );

        return prevBalance - _value == _token.balanceOf(_from);
    }

    function safeApprove(IERC20 _token, address _spender, uint256 _value) internal returns (bool) {

        address(_token).call(
            abi.encodeWithSignature("approve(address,uint256)",_spender, _value)
        );

        return _token.allowance(address(this), _spender) == _value;
    }

    function clearApprove(IERC20 _token, address _spender) internal returns (bool) {

        bool success = safeApprove(_token, _spender, 0);

        if (!success) {
            success = safeApprove(_token, _spender, 1);
        }

        return success;
    }
}


pragma solidity ^0.5.11;









library DiasporeUtils {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    function oracle(
        LoanManager _manager,
        bytes32 _id
    ) internal view returns (RateOracle) {

        return RateOracle(_manager.getOracle(_id));
    }

    function safePayToken(
        LoanManager _manager,
        bytes32 _id,
        uint256 _amount,
        address _sender,
        bytes memory _oracleData
    ) internal returns (uint256 paid, uint256 tokens) {

        IERC20 token = IERC20(_manager.token());
        DebtEngine engine = DebtEngine(_manager.debtEngine());
        require(token.safeApprove(address(engine), _amount), "Error approve debt engine");

        uint256 prevBalance = token.balanceOf(address(this));

        (paid, tokens) = engine.payToken(
            _id,
            _amount,
            _sender,
            _oracleData
        );

        require(token.clearApprove(address(engine)), "Error clear approve");
        require(prevBalance.sub(token.balanceOf(address(this))) <= tokens, "Debt engine pulled too many tokens");
    }
}


pragma solidity ^0.5.11;




library OracleUtils {

    using OracleUtils for OracleUtils.Sample;
    using OracleUtils for RateOracle;
    using SafeMath for uint256;

    struct Sample {
        uint256 tokens;
        uint256 equivalent;
    }

    function read(
        RateOracle _oracle,
        bytes memory data
    ) internal returns (Sample memory s) {

        if (address(_oracle) == address(0)) {
            s.tokens = 1;
            s.equivalent = 1;
        } else {
            (
                s.tokens,
                s.equivalent
            ) = _oracle.readSample(data);
        }
    }

    function read(
        RateOracle _oracle
    ) internal returns (Sample memory s) {

        s = _oracle.read("");
    }

    function readStatic(
        RateOracle _oracle,
        bytes memory data
    ) internal view returns (Sample memory s) {

        if (address(_oracle) == address(0)) {
            s.tokens = 1;
            s.equivalent = 1;
        } else {
            (
                bool success,
                bytes memory returnData
            ) = address(_oracle).staticcall(
                abi.encodeWithSelector(
                    _oracle.readSample.selector,
                    data
                )
            );

            require(success, "oracle-utils: error static reading oracle");

            (
                s.tokens,
                s.equivalent
            ) = abi.decode(returnData, (uint256, uint256));
        }
    }

    function readStatic(
        RateOracle _oracle
    ) internal view returns (Sample memory s) {

        s = _oracle.readStatic("");
    }

    function encode(
        uint256 _tokens,
        uint256 _equivalent
    ) internal pure returns (Sample memory s) {

        s.tokens = _tokens;
        s.equivalent = _equivalent;
    }

    function toTokens(
        Sample memory _sample,
        uint256 _base
    ) internal pure returns (
        uint256 tokens
    ) {

        tokens = _sample.toTokens(_base, false);
    }

    function toTokens(
        Sample memory _sample,
        uint256 _base,
        bool ceil
    ) internal pure returns (
        uint256 tokens
    ) {

        if (_sample.tokens == 1 && _sample.equivalent == 1) {
            tokens = _base;
        } else {
            uint256 mul = _base.mult(_sample.tokens);
            tokens = mul.div(_sample.equivalent);
            if (ceil && mul % tokens != 0) {
                tokens = tokens.add(1);
            }
        }
    }

    function toBase(
        Sample memory _sample,
        uint256 _tokens
    ) internal pure returns (
        uint256 base
    ) {

        base = _sample.toBase(_tokens, false);
    }

    function toBase(
        Sample memory _sample,
        uint256 _tokens,
        bool ceil
    ) internal pure returns (
        uint256 base
    ) {

        if (_sample.tokens == 1 && _sample.equivalent == 1) {
            base = _tokens;
        } else {
            uint256 mul = _tokens.mult(_sample.equivalent);
            base = mul.div(_sample.tokens);
            if (ceil && mul % base != 0) {
                base = base.add(1);
            }
        }
    }
}


pragma solidity ^0.5.11;


library SafeCast {

    function toUint128(uint256 _a) internal pure returns (uint128) {

        require(_a < 2 ** 128, "cast overflow");
        return uint128(_a);
    }

    function toUint256(int256 _i) internal pure returns (uint256) {

        require(_i >= 0, "cast to unsigned must be positive");
        return uint256(_i);
    }

    function toInt256(uint256 _i) internal pure returns (int256) {

        require(_i < 2 ** 255, "cast overflow");
        return int256(_i);
    }

    function toUint32(uint256 _i) internal pure returns (uint32) {

        require(_i < 2 ** 32, "cast overdlow");
        return uint32(_i);
    }
}


pragma solidity ^0.5.11;


library Math {

    function min(int256 _a, int256 _b) internal pure returns (int256) {

        if (_a < _b) {
            return _a;
        } else {
            return _b;
        }
    }

    function max(int256 _a, int256 _b) internal pure returns (int256) {

        if (_a > _b) {
            return _a;
        } else {
            return _b;
        }
    }

    function min(uint256 _a, uint256 _b) internal pure returns (uint256) {

        if (_a < _b) {
            return _a;
        } else {
            return _b;
        }
    }

    function max(uint256 _a, uint256 _b) internal pure returns (uint256) {

        if (_a > _b) {
            return _a;
        } else {
            return _b;
        }
    }
}


pragma solidity ^0.5.11;











contract CollateralAuction is ReentrancyGuard, Ownable {

    using IsContract for address payable;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using SafeCast for uint256;

    uint256 private constant DELTA_TO_MARKET = 10 minutes;
    uint256 private constant DELTA_FINISH = 1 days;

    IERC20 public baseToken;
    Auction[] public auctions;

    struct Auction {
        IERC20 fromToken;    // Token that we are intending to sell
        uint64 startTime;    // Start time of the auction
        uint32 limitDelta;   // Limit time until all collateral is offered
        uint256 startOffer;  // Start offer of `fromToken` for the requested `amount`
        uint256 amount;      // Amount that we need to receive of `baseToken`
        uint256 limit;       // Limit of how much are willing to spend of `fromToken`
    }

    event CreatedAuction(
        uint256 indexed _id,
        IERC20 _fromToken,
        uint256 _startOffer,
        uint256 _refOffer,
        uint256 _amount,
        uint256 _limit
    );

    event Take(
        uint256 indexed _id,
        address _taker,
        uint256 _selling,
        uint256 _requesting
    );

    constructor(IERC20 _baseToken) public {
        baseToken = _baseToken;
        auctions.length++;
    }

    function getAuctionsLength() external view returns (uint256) {

        return auctions.length;
    }

    function create(
        IERC20 _fromToken,
        uint256 _start,
        uint256 _ref,
        uint256 _limit,
        uint256 _amount
    ) external nonReentrant() returns (uint256 id) {

        require(_start < _ref, "auction: offer should be below refence offer");
        require(_ref <= _limit, "auction: reference offer should be below or equal to limit");

        uint32 limitDelta = ((_limit - _start).mult(DELTA_TO_MARKET) / (_ref - _start)).toUint32();

        require(_fromToken.safeTransferFrom(msg.sender, address(this), _limit), "auction: error pulling _fromToken");

        id = auctions.push(Auction({
            fromToken: _fromToken,
            startTime: uint64(_now()),
            limitDelta: limitDelta,
            startOffer: _start,
            amount: _amount,
            limit: _limit
        })) - 1;

        emit CreatedAuction(
            id,
            _fromToken,
            _start,
            _ref,
            _amount,
            _limit
        );
    }

    function take(
        uint256 _id,
        bytes calldata _data,
        bool _callback
    ) external nonReentrant() {

        Auction memory auction = auctions[_id];
        require(auction.amount != 0, "auction: does not exists");
        IERC20 fromToken = auction.fromToken;

        (uint256 selling, uint256 requesting) = _offer(auction);
        address owner = _owner;

        uint256 leftOver = auction.limit - selling;

        delete auctions[_id];

        require(fromToken.safeTransfer(msg.sender, selling), "auction: error sending tokens");

        if (_callback) {
            (bool success, ) = msg.sender.call(abi.encodeWithSignature("onTake(address,uint256,uint256)", fromToken, selling, requesting));
            require(success, "auction: error during callback onTake()");
        }

        require(baseToken.transferFrom(msg.sender, owner, requesting), "auction: error pulling tokens");

        require(fromToken.safeTransfer(owner, leftOver), "auction: error sending leftover tokens");

        CollateralAuctionCallback(owner).auctionClosed(
            _id,
            leftOver,
            requesting,
            _data
        );

        emit Take(
            _id,
            msg.sender,
            selling,
            requesting
        );
    }

    function offer(
        uint256 _id
    ) external view returns (uint256 selling, uint256 requesting) {

        return _offer(auctions[_id]);
    }

    function _now() internal view returns (uint256) {

        return now;
    }

    function _offer(
        Auction memory _auction
    ) private view returns (uint256, uint256) {

        if (_auction.fromToken == baseToken) {
            uint256 min = Math.min(_auction.limit, _auction.amount);
            return (min, min);
        } else {
            return (_selling(_auction), _requesting(_auction));
        }
    }

    function _selling(
        Auction memory _auction
    ) private view returns (uint256 _amount) {

        uint256 deltaTime = _now() - _auction.startTime;

        if (deltaTime < _auction.limitDelta) {
            uint256 deltaAmount = _auction.limit - _auction.startOffer;
            _amount = _auction.startOffer.add(deltaAmount.mult(deltaTime) / _auction.limitDelta);
        } else {
            _amount = _auction.limit;
        }
    }

    function _requesting(
        Auction memory _auction
    ) private view returns (uint256 _amount) {

        uint256 ogDeltaTime = _now() - _auction.startTime;

        if (ogDeltaTime > _auction.limitDelta) {
            uint256 deltaTime = ogDeltaTime - _auction.limitDelta;
            return _auction.amount.sub(_auction.amount.mult(deltaTime % DELTA_FINISH) / DELTA_FINISH);
        } else {
            return _auction.amount;
        }
    }
}


pragma solidity ^0.5.11;






library CollateralLib {

    using CollateralLib for CollateralLib.Entry;
    using OracleUtils for OracleUtils.Sample;
    using OracleUtils for RateOracle;
    using Fixed224x32 for bytes32;

    struct Entry {
        bytes32 debtId;
        uint256 amount;
        RateOracle oracle;
        IERC20 token;
        uint96 liquidationRatio;
        uint96 balanceRatio;
    }

    function create(
        RateOracle _oracle,
        IERC20 _token,
        bytes32 _debtId,
        uint256 _amount,
        uint96 _liquidationRatio,
        uint96 _balanceRatio
    ) internal pure returns (Entry memory _col) {

        require(_liquidationRatio < _balanceRatio, "collateral-lib: _liquidationRatio should be below _balanceRatio");
        require(_liquidationRatio > 2 ** 32, "collateral-lib: _liquidationRatio should be above one");
        require(address(_token) != address(0), "collateral-lib: _token can't be address zero");

        _col.oracle = _oracle;
        _col.token = _token;
        _col.debtId = _debtId;
        _col.amount = _amount;
        _col.liquidationRatio = _liquidationRatio;
        _col.balanceRatio = _balanceRatio;
    }

    function toBase(
        Entry memory _col
    ) internal view returns (uint256) {

        return _col.oracle
            .readStatic()
            .toTokens(_col.amount);
    }

    function ratio(
        Entry memory _col,
        uint256 _debt
    ) internal view returns (bytes32) {

        bytes32 dividend = Fixed224x32.from(_col.toBase());
        bytes32 divisor = Fixed224x32.from(_debt);

        return dividend.div(divisor);
    }

    function balance(
        Entry memory _col,
        uint256 _debt
    ) internal view returns (uint256 _sell, uint256 _buy) {

        OracleUtils.Sample memory sample = _col.oracle.readStatic();

        bytes32 liquidationRatio = Fixed224x32.raw(_col.liquidationRatio);
        uint256 base = sample.toTokens(_col.amount);
        bytes32 baseRaw = Fixed224x32.from(base);
        bytes32 debt = Fixed224x32.from(_debt);

        bytes32 limit = debt.mul(liquidationRatio);

        if (limit.lt(baseRaw)) {
            return (0, 0);
        }

        bytes32 balanceRatio = Fixed224x32.raw(_col.balanceRatio);

        bytes32 diff = debt.mul(balanceRatio).sub(baseRaw);
        _buy = diff.div(balanceRatio.sub(Fixed224x32.from(1))).toUint256();

        _sell = sample.toBase(_buy);

        if (_sell > _col.amount) {
            return (_col.amount, base);
        }

        return (_sell, _buy);
    }

    function canWithdraw(
        Entry memory _col,
        uint256 _debt
    ) internal view returns (uint256) {

        if (_debt == 0) {
            return _col.amount;
        }
        OracleUtils.Sample memory sample = _col.oracle.readStatic();

        bytes32 base = Fixed224x32.from(sample.toTokens(_col.amount));
        bytes32 liquidationRatio = Fixed224x32.raw(_col.liquidationRatio);

        bytes32 limit = Fixed224x32.from(_debt).mul(liquidationRatio);

        if (base.lte(limit)) {
            return 0;
        }

        return sample.toBase(base.sub(limit.ceil()).toUint256());
    }

    function inLiquidation(
        Entry memory _col,
        uint256 _debt
    ) internal view returns (bool) {

        if (_debt == 0) {
            return false;
        }

        return _col.ratio(_debt).lt(Fixed224x32.raw(_col.liquidationRatio));
    }
}


pragma solidity ^0.5.11;




















contract Collateral is ReentrancyGuard, Ownable, Cosigner, ERC721Base, CollateralAuctionCallback, IDebtStatus {

    using CollateralLib for CollateralLib.Entry;
    using OracleUtils for OracleUtils.Sample;
    using OracleUtils for RateOracle;
    using DiasporeUtils for LoanManager;
    using Fixed224x32 for bytes32;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using SafeMath for uint32;

    event Created(
        uint256 indexed _entryId,
        bytes32 indexed _debtId,
        RateOracle _oracle,
        IERC20 _token,
        uint256 _amount,
        uint96 _liquidationRatio,
        uint96 _balanceRatio
    );

    event Deposited(
        uint256 indexed _entryId,
        uint256 _amount
    );

    event Withdraw(
        uint256 indexed _entryId,
        address _to,
        uint256 _amount
    );

    event Started(
        uint256 indexed _entryId
    );

    event ClaimedLiquidation(
        uint256 indexed _entryId,
        uint256 indexed _auctionId,
        uint256 _marketValue,
        uint256 _debt,
        uint256 _required
    );

    event ClaimedExpired(
        uint256 indexed _entryId,
        uint256 indexed _auctionId,
        uint256 _marketValue,
        uint256 _obligation,
        uint256 _obligationTokens,
        uint256 _dueTime
    );

    event ClosedAuction(
        uint256 indexed _entryId,
        uint256 _received,
        uint256 _leftover
    );

    event Redeemed(
        uint256 indexed _entryId,
        address _to
    );

    event BorrowCollateral(
        uint256 indexed _entryId,
        CollateralHandler _handler,
        uint256 _newAmount
    );

    event SetUrl(
        string _url
    );

    CollateralLib.Entry[] public entries;

    mapping(bytes32 => uint256) public debtToEntry;

    string private iurl;

    LoanManager public loanManager;
    IERC20 public loanManagerToken;

    CollateralAuction public auction;
    mapping(uint256 => uint256) public entryToAuction;
    mapping(uint256 => uint256) public auctionToEntry;

    constructor(
        LoanManager _loanManager,
        CollateralAuction _auction
    ) public ERC721Base("RCN Collateral Cosigner", "RCC") {
        loanManager = _loanManager;
        loanManagerToken = loanManager.token();
        entries.length ++;
        auction = _auction;
    }

    function getEntriesLength() external view returns (uint256) {

        return entries.length;
    }

    function create(
        address _owner,
        bytes32 _debtId,
        RateOracle _oracle,
        uint256 _amount,
        uint96 _liquidationRatio,
        uint96 _balanceRatio
    ) external nonReentrant() returns (uint256 entryId) {

        require(_owner != address(0x0), "collateral: _owner should not be address 0");
        require(loanManager.getStatus(_debtId) == Status.NULL, "collateral: loan request should be open");

        IERC20 token = _oracle == RateOracle(0) ? loanManagerToken : IERC20(_oracle.token());

        entryId = entries.push(
            CollateralLib.create(
                _oracle,
                token,
                _debtId,
                _amount,
                _liquidationRatio,
                _balanceRatio
            )
        ) - 1;

        require(token.safeTransferFrom(_owner, address(this), _amount), "collateral: error pulling tokens from owner");

        _generate(entryId, _owner);

        emit Created(
            entryId,
            _debtId,
            _oracle,
            token,
            _amount,
            _liquidationRatio,
            _balanceRatio
        );
    }

    function deposit(
        uint256 _entryId,
        uint256 _amount
    ) external nonReentrant() {

        require(_amount != 0, "collateral: The amount of deposit should not be 0");

        require(!inAuction(_entryId), "collateral: can't deposit during auction");

        CollateralLib.Entry storage entry = entries[_entryId];

        require(entry.token.safeTransferFrom(msg.sender, address(this), _amount), "collateral: error pulling tokens");

        entry.amount = entry.amount.add(_amount);

        emit Deposited(_entryId, _amount);
    }

    function withdraw(
        uint256 _entryId,
        address _to,
        uint256 _amount,
        bytes calldata _oracleData
    ) external nonReentrant() onlyAuthorized(_entryId) {

        require(_amount != 0, "collateral: The amount of withdraw not be 0");

        require(!inAuction(_entryId), "collateral: can't withdraw during auction");

        CollateralLib.Entry storage entry = entries[_entryId];
        bytes32 debtId = entry.debtId;
        uint256 entryAmount = entry.amount;

        if (debtToEntry[debtId] != 0) {
            require(
                _amount <= entry.canWithdraw(_debtInTokens(debtId, _oracleData)),
                "collateral: withdrawable collateral is not enough"
            );
        }

        require(entryAmount >= _amount, "collateral: withdrawable collateral is not enough");
        entry.amount = entryAmount.sub(_amount);

        require(entry.token.safeTransfer(_to, _amount), "collateral: error sending tokens");

        emit Withdraw(_entryId, _to, _amount);
    }

    function redeem(
        uint256 _entryId,
        address _to
    ) external nonReentrant() onlyOwner {

        CollateralLib.Entry storage entry = entries[_entryId];

        require(loanManager.getStatus(entry.debtId) == Status.ERROR, "collateral: the debt should be in status error");
        emit Redeemed(_entryId, _to);

        uint256 amount = entry.amount;
        IERC20 token = entry.token;

        delete debtToEntry[entry.debtId];
        delete entries[_entryId];

        require(token.safeTransfer(_to, amount), "collateral: error sending tokens");
    }

    function borrowCollateral(
        uint256 _entryId,
        CollateralHandler _handler,
        bytes calldata _data,
        bytes calldata _oracleData
    ) external nonReentrant() onlyAuthorized(_entryId) {

        CollateralLib.Entry storage entry = entries[_entryId];
        bytes32 debtId = entry.debtId;

        bytes32 ogRatio = entry.ratio(_debtInTokens(debtId, _oracleData));

        uint256 lent = entry.amount;
        entry.amount = 0;
        require(entry.token.safeTransfer(address(_handler), lent), "collateral: error sending tokens");

        uint256 surplus = _handler.handle(_entryId, lent, _data);

        require(entry.token.safeTransferFrom(address(_handler), address(this), surplus), "collateral: error pulling tokens");
        entry.amount = surplus;

        if (loanManager.getStatus(entry.debtId) != Status.PAID) {
            bytes32 afRatio = entry.ratio(_debtInTokens(debtId, _oracleData));
            require(afRatio.gt(ogRatio), "collateral: ratio should increase");
        }

        emit BorrowCollateral(_entryId, _handler, surplus);
    }

    function auctionClosed(
        uint256 _id,
        uint256 _leftover,
        uint256 _received,
        bytes calldata _data
    ) external nonReentrant() {

        require(msg.sender == address(auction), "collateral: caller should be the auctioner");

        uint256 entryId = auctionToEntry[_id];

        require(entryId != 0, "collateral: entry does not exists");

        CollateralLib.Entry storage entry = entries[entryId];

        delete entryToAuction[entryId];
        delete auctionToEntry[_id];

        (, uint256 paidTokens) = loanManager.safePayToken(
            entry.debtId,
            _received,
            address(this),
            _data
        );

        if (paidTokens < _received) {
            require(
                loanManagerToken.safeTransfer(
                    _ownerOf(entryId),
                    _received - paidTokens
                ),
                "collateral: error sending tokens"
            );
        }

        entry.amount = _leftover;

        emit ClosedAuction(
            entryId,
            _received,
            _leftover
        );
    }


    function setUrl(string calldata _url) external nonReentrant() onlyOwner {

        iurl = _url;
        emit SetUrl(_url);
    }

    function cost(
        address,
        uint256,
        bytes calldata,
        bytes calldata
    ) external view returns (uint256) {

        return 0;
    }

    function url() external view returns (string memory) {

        return iurl;
    }

    function requestCosign(
        address,
        uint256 _debtId,
        bytes calldata _data,
        bytes calldata _oracleData
    ) external nonReentrant() returns (bool) {

        bytes32 debtId = bytes32(_debtId);

        require(_debtId != 0, "collateral: invalid debtId");

        LoanManager _loanManager = loanManager;
        require(address(_loanManager) == msg.sender, "collateral: only the loanManager can request cosign");

        uint256 entryId = abi.decode(_data, (uint256));

        CollateralLib.Entry storage entry = entries[entryId];
        require(entry.debtId == debtId, "collateral: incorrect debtId or the entry does not exists");

        require(
            !entry.inLiquidation(_debtInTokens(debtId, _oracleData)),
            "collateral: entry not collateralized"
        );

        debtToEntry[debtId] = entryId;

        require(_loanManager.cosign(_debtId, 0), "collateral: error during cosign");

        emit Started(entryId);

        return true;
    }

    function claim(
        address,
        uint256 _debtId,
        bytes calldata _oracleData
    ) external nonReentrant() returns (bool) {

        bytes32 debtId = bytes32(_debtId);
        uint256 entryId = debtToEntry[debtId];
        require(entryId != 0, "collateral: collateral not found for debtId");

        return _claimLiquidation(entryId, debtId, _oracleData) ||
            _claimExpired(entryId, debtId, _oracleData);
    }

    function canClaim(uint256 _debtId, bytes calldata _oracleData) external view returns (bool) {

        bytes32 debtId = bytes32(_debtId);
        uint256 entryId = debtToEntry[debtId];
        require(entryId != 0, "collateral: collateral not found for debtId");

        if (inAuction(entryId))
            return false;

        CollateralLib.Entry memory entry = entries[entryId];

        LoanManager _loanManager = loanManager;
        uint256 debt = _loanManager.getClosingObligation(debtId);

        if (debt != 0)
            debt = _loanManager
                .oracle(debtId)
                .readStatic(_oracleData)
                .toTokens(debt);

        return entry.inLiquidation(debt) || now > _getModel(debtId).getDueTime(debtId);
    }

    function inAuction(uint256 _entryId) public view returns (bool) {

        return entryToAuction[_entryId] != 0;
    }

    function _claimLiquidation(
        uint256 _entryId,
        bytes32 _debtId,
        bytes memory _oracleData
    ) internal returns (bool) {

        CollateralLib.Entry memory entry = entries[_entryId];

        uint256 debt = _debtInTokens(_debtId, _oracleData);
        if (entry.inLiquidation(debt)) {
            (uint256 marketValue, uint256 required) = entry.balance(debt);

            uint256 auctionId = _triggerAuction(
                _entryId,
                required,
                marketValue
            );

            emit ClaimedLiquidation(
                _entryId,
                auctionId,
                marketValue,
                debt,
                required
            );

            return true;
        }
    }

    function _claimExpired(
        uint256 _entryId,
        bytes32 _debtId,
        bytes memory _oracleData
    ) internal returns (bool) {

        Model model = _getModel(_debtId);
        uint256 dueTime = model.getDueTime(_debtId);
        uint256 _now = block.timestamp;

        if (_now > dueTime) {
            (uint256 obligation,) = model.getObligation(_debtId, uint64(_now));

            obligation = obligation.mult(105).div(100);

            uint256 obligationTokens = _toToken(_debtId, obligation, _oracleData);

            uint256 marketValue = entries[_entryId].oracle.read().toBase(obligationTokens);

            uint256 auctionId = _triggerAuction(
                _entryId,
                obligationTokens,
                marketValue
            );

            emit ClaimedExpired(
                _entryId,
                auctionId,
                marketValue,
                obligation,
                obligationTokens,
                dueTime
            );

            return true;
        }
    }

    function _toToken(
        bytes32 _debtId,
        uint256 _amount,
        bytes memory _data
    ) internal returns (uint256) {

        if (_amount == 0)
            return 0;

        return loanManager
            .oracle(_debtId)
            .read(_data)
            .toTokens(_amount, true);
    }

    function _debtInTokens(
        bytes32 debtId,
        bytes memory _data
    ) internal returns (uint256 debtInTokens) {

        LoanManager _loanManager = loanManager;
        debtInTokens = _loanManager.getClosingObligation(debtId);

        if (debtInTokens != 0)
            debtInTokens = _loanManager
                .oracle(debtId)
                .read(_data)
                .toTokens(debtInTokens);
    }

    function _triggerAuction(
        uint256 _entryId,
        uint256 _targetAmount,
        uint256 _marketValue
    ) internal returns (uint256 _auctionId) {

        require(!inAuction(_entryId), "collateral: auction already exists");

        CollateralLib.Entry storage entry = entries[_entryId];

        uint256 initialOffer = _marketValue.mult(95).div(100);

        CollateralAuction _auction = auction;
        uint256 _amount = entry.amount;
        IERC20 _token = entry.token;

        delete entry.amount;

        require(_token.safeApprove(address(_auction), _amount), "collateral: error approving auctioneer");

        _auctionId = _auction.create(
            _token,          // Token we are selling
            initialOffer,    // Initial offer of tokens
            _marketValue,    // Market reference offer provided by the Oracle
            _amount,         // The maximun amount of token that we can sell
            _targetAmount    // How much base tokens are needed
        );

        require(_token.clearApprove(address(_auction)), "collateral: error clearing approve");

        entryToAuction[_entryId] = _auctionId;
        auctionToEntry[_auctionId] = _entryId;
    }

    function _getModel(bytes32 _debtId) internal view returns (Model) {

        (,,,,, address model,,,,,,) = loanManager.requests(_debtId);
        return Model(model);
    }
}