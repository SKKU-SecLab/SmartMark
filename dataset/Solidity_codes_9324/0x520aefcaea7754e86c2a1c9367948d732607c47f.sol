



pragma solidity ^0.5.12;


interface OracleFactory {

    function symbolToOracle(string calldata _symbol) external view returns (address);

    function oracleToSymbol(address _oracle) external view returns (string memory);

}



pragma solidity ^0.5.12;


interface IERC20 {

    function transfer(address _to, uint _value) external returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    function approve(address _spender, uint256 _value) external returns (bool success);

    function increaseApproval (address _spender, uint _addedValue) external returns (bool success);
    function balanceOf(address _owner) external view returns (uint256 balance);

}


pragma solidity ^0.5.12;


interface IERC165 {

    function supportsInterface(bytes4 interfaceID) external view returns (bool);

}


pragma solidity ^0.5.12;



contract Model is IERC165 {


    event Created(bytes32 indexed _id);

    event ChangedStatus(bytes32 indexed _id, uint256 _timestamp, uint256 _status);

    event ChangedObligation(bytes32 indexed _id, uint256 _timestamp, uint256 _debt);

    event ChangedFrequency(bytes32 indexed _id, uint256 _timestamp, uint256 _frequency);

    event ChangedDueTime(bytes32 indexed _id, uint256 _timestamp, uint256 _status);

    event ChangedFinalTime(bytes32 indexed _id, uint256 _timestamp, uint64 _dueTime);

    event AddedDebt(bytes32 indexed _id, uint256 _amount);

    event AddedPaid(bytes32 indexed _id, uint256 _paid);

    bytes4 internal constant MODEL_INTERFACE = 0xaf498c35;

    uint256 public constant STATUS_ONGOING = 1;
    uint256 public constant STATUS_PAID = 2;
    uint256 public constant STATUS_ERROR = 4;


    function modelId() external view returns (bytes32);


    function descriptor() external view returns (address);


    function isOperator(address operator) external view returns (bool canOperate);


    function validate(bytes calldata data) external view returns (bool isValid);



    function getStatus(bytes32 id) external view returns (uint256 status);


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


pragma solidity ^0.5.12;



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


pragma solidity ^0.5.12;


library IsContract {

    function isContract(address _addr) internal view returns (bool) {

        uint size;
        assembly { size := extcodesize(_addr) }
        return size > 0;
    }
}


pragma solidity ^0.5.12;


library SafeMath {

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
}


pragma solidity ^0.5.12;



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


pragma solidity ^0.5.12;





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


pragma solidity ^0.5.12;


contract IERC173 {

    event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);


    function transferOwnership(address _newOwner) external;

}


pragma solidity ^0.5.12;



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


pragma solidity ^0.5.12;








contract DebtEngine is ERC721Base, Ownable {

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

    function getError(bytes32 _id) external view returns (bool) {

        return debts[_id].error;
    }

    function getBalance(bytes32 _id) external view returns (uint128) {

        return debts[_id].balance;
    }

    function getModel(bytes32 _id) external view returns (address) {

        return address(debts[_id].model);
    }

    function getCreator(bytes32 _id) external view returns (address) {

        return debts[_id].creator;
    }

    function getOracle(bytes32 _id) external view returns (address) {

        return debts[_id].oracle;
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

    function getStatus(bytes32 _id) external view returns (uint256) {

        Debt storage debt = debts[_id];
        if (debt.error) {
            return 4;
        } else {
            (bool success, uint256 result) = _safeGasStaticCall(
                address(debt.model),
                abi.encodeWithSelector(
                    debt.model.getStatus.selector,
                    _id
                )
            );
            return success ? result : 4;
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


pragma solidity ^0.5.12;



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


pragma solidity ^0.5.12;


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


pragma solidity ^0.5.12;


contract Cosigner {

    uint256 public constant VERSION = 2;

    function url() public view returns (string memory);


    function cost(
        address engine,
        uint256 index,
        bytes memory data,
        bytes memory oracleData
    )
        public view returns (uint256);


    function requestCosign(
        address engine,
        uint256 index,
        bytes memory data,
        bytes memory oracleData
    )
        public returns (bool);


    function claim(address engine, uint256 index, bytes memory oracleData) public returns (bool);

}


pragma solidity ^0.5.12;


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


pragma solidity ^0.5.12;


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


pragma solidity ^0.5.12;











contract LoanManager is BytesUtils {

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

    function getModel(uint256 _id) external view returns (address) { return requests[bytes32(_id)].model; }

    function getStatus(uint256 _id) external view returns (uint256) {

        Request storage request = requests[bytes32(_id)];
        return request.open ? 0 : debtEngine.getStatus(bytes32(_id));
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

    function getModel(bytes32 _id) external view returns (address) { return requests[_id].model; }

    function getStatus(bytes32 _id) external view returns (uint256) {

        Request storage request = requests[_id];
        return request.open ? 0 : debtEngine.getStatus(bytes32(_id));
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

    function _internalSalt(Request memory _request) internal view returns (uint256) {

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


pragma solidity ^0.5.12;


contract ModelDescriptor {

    bytes4 internal constant MODEL_DESCRIPTOR_INTERFACE = 0x02735375;

    function simFirstObligation(bytes calldata data) external view returns (uint256 amount, uint256 time);

    function simTotalObligation(bytes calldata data) external view returns (uint256 amount);

    function simDuration(bytes calldata data) external view returns (uint256 duration);

    function simPunitiveInterestRate(bytes calldata data) external view returns (uint256 punitiveInterestRate);

    function simFrequency(bytes calldata data) external view returns (uint256 frequency);

    function simInstallments(bytes calldata data) external view returns (uint256 installments);

}


pragma solidity ^0.5.12;







contract InstallmentsModel is ERC165, BytesUtils, Ownable, Model, ModelDescriptor {


    mapping(bytes4 => bool) private _supportedInterface;

    constructor() public {
        _registerInterface(MODEL_INTERFACE);
        _registerInterface(MODEL_DESCRIPTOR_INTERFACE);
    }

    address public engine;
    address private altDescriptor;

    mapping(bytes32 => Config) public configs;
    mapping(bytes32 => State) public states;

    uint256 public constant L_DATA = 16 + 32 + 3 + 5 + 4;

    uint256 private constant U_128_OVERFLOW = 2 ** 128;
    uint256 private constant U_64_OVERFLOW = 2 ** 64;
    uint256 private constant U_40_OVERFLOW = 2 ** 40;
    uint256 private constant U_24_OVERFLOW = 2 ** 24;

    event _setEngine(address _engine);
    event _setDescriptor(address _descriptor);

    event _setClock(bytes32 _id, uint64 _to);
    event _setPaidBase(bytes32 _id, uint128 _paidBase);
    event _setInterest(bytes32 _id, uint128 _interest);

    struct Config {
        uint24 installments;
        uint32 timeUnit;
        uint40 duration;
        uint64 lentTime;
        uint128 cuota;
        uint256 interestRate;
    }

    struct State {
        uint8 status;
        uint64 clock;
        uint64 lastPayment;
        uint128 paid;
        uint128 paidBase;
        uint128 interest;
    }

    modifier onlyEngine {

        require(msg.sender == engine, "Only engine allowed");
        _;
    }

    function modelId() external view returns (bytes32) {

        return bytes32(0x00000000000000496e7374616c6c6d656e74734d6f64656c204120302e302e32);
    }

    function descriptor() external view returns (address) {

        address _descriptor = altDescriptor;
        return _descriptor == address(0) ? address(this) : _descriptor;
    }

    function setEngine(address _engine) external onlyOwner returns (bool) {

        engine = _engine;
        emit _setEngine(_engine);
        return true;
    }

    function setDescriptor(address _descriptor) external onlyOwner returns (bool) {

        altDescriptor = _descriptor;
        emit _setDescriptor(_descriptor);
        return true;
    }

    function encodeData(
        uint128 _cuota,
        uint256 _interestRate,
        uint24 _installments,
        uint40 _duration,
        uint32 _timeUnit
    ) external pure returns (bytes memory) {

        return abi.encodePacked(_cuota, _interestRate, _installments, _duration, _timeUnit);
    }

    function create(bytes32 id, bytes calldata data) external onlyEngine returns (bool) {

        require(configs[id].cuota == 0, "Entry already exist");

        (uint128 cuota, uint256 interestRate, uint24 installments, uint40 duration, uint32 timeUnit) = _validate(data);

        configs[id] = Config({
            installments: installments,
            duration: duration,
            lentTime: uint64(now),
            cuota: cuota,
            interestRate: interestRate,
            timeUnit: timeUnit
        });

        states[id].clock = duration;

        emit Created(id);
        emit _setClock(id, duration);

        return true;
    }

    function addPaid(bytes32 id, uint256 amount) external onlyEngine returns (uint256 real) {

        Config storage config = configs[id];
        State storage state = states[id];

        _advanceClock(id, uint64(now) - config.lentTime);

        if (state.status != STATUS_PAID) {
            uint256 paid = state.paid;
            uint256 duration = config.duration;
            uint256 interest = state.interest;

            uint256 available = amount;
            require(available < U_128_OVERFLOW, "Amount overflow");

            uint256 unpaidInterest;
            uint256 pending;
            uint256 target;
            uint256 baseDebt;
            uint256 clock;

            do {
                clock = state.clock;

                baseDebt = _baseDebt(clock, duration, config.installments, config.cuota);
                pending = baseDebt + interest - paid;

                target = pending < available ? pending : available;

                unpaidInterest = interest - (paid - state.paidBase);

                state.paidBase += uint128(target > unpaidInterest ? target - unpaidInterest : 0);
                emit _setPaidBase(id, state.paidBase);

                paid += target;
                available -= target;

                if (clock / duration >= config.installments && baseDebt + interest <= paid) {
                    state.status = uint8(STATUS_PAID);
                    emit ChangedStatus(id, now, STATUS_PAID);
                    break;
                }

                if (pending == target) {
                    _advanceClock(id, clock + duration - (clock % duration));
                }
            } while (available != 0);

            require(paid < U_128_OVERFLOW, "Paid overflow");
            state.paid = uint128(paid);
            state.lastPayment = state.clock;

            real = amount - available;
            emit AddedPaid(id, real);
        }
    }

    function addDebt(bytes32 id, uint256 amount) external onlyEngine returns (bool) {

        revert("Not implemented!");
    }

    function fixClock(bytes32 id, uint64 target) external returns (bool) {

        require(target <= now, "Forbidden advance clock into the future");
        Config storage config = configs[id];
        State storage state = states[id];
        uint64 lentTime = config.lentTime;
        require(lentTime < target, "Clock can't go negative");
        uint64 targetClock = target - lentTime;
        require(targetClock > state.clock, "Clock is ahead of target");
        return _advanceClock(id, targetClock);
    }

    function isOperator(address _target) external view returns (bool) {

        return engine == _target;
    }

    function getStatus(bytes32 id) external view returns (uint256) {

        Config storage config = configs[id];
        State storage state = states[id];
        require(config.lentTime != 0, "The registry does not exist");
        return state.status == STATUS_PAID ? STATUS_PAID : STATUS_ONGOING;
    }

    function getPaid(bytes32 id) external view returns (uint256) {

        return states[id].paid;
    }

    function getObligation(bytes32 id, uint64 timestamp) external view returns (uint256, bool) {

        State storage state = states[id];
        Config storage config = configs[id];

        if (timestamp < config.lentTime) {
            return (0, true);
        }

        uint256 currentClock = timestamp - config.lentTime;

        uint256 base = _baseDebt(
            currentClock,
            config.duration,
            config.installments,
            config.cuota
        );

        uint256 interest;
        uint256 prevInterest = state.interest;
        uint256 clock = state.clock;
        bool defined;

        if (clock >= currentClock) {
            interest = prevInterest;
            defined = true;
        } else {
            (interest, currentClock) = _simRunClock(
                clock,
                currentClock,
                prevInterest,
                config,
                state
            );

            defined = prevInterest == interest;
        }

        uint256 debt = base + interest;
        uint256 paid = state.paid;
        return (debt > paid ? debt - paid : 0, defined);
    }

    function _simRunClock(
        uint256 _clock,
        uint256 _targetClock,
        uint256 _prevInterest,
        Config memory _config,
        State memory _state
    ) internal pure returns (uint256 interest, uint256 clock) {

        (interest, clock) = _runAdvanceClock({
            _clock: _clock,
            _timeUnit: _config.timeUnit,
            _interest: _prevInterest,
            _duration: _config.duration,
            _cuota: _config.cuota,
            _installments: _config.installments,
            _paidBase: _state.paidBase,
            _interestRate: _config.interestRate,
            _targetClock: _targetClock
        });
    }

    function run(bytes32 id) external returns (bool) {

        Config storage config = configs[id];
        return _advanceClock(id, uint64(now) - config.lentTime);
    }

    function validate(bytes calldata data) external view returns (bool) {

        _validate(data);
        return true;
    }

    function getClosingObligation(bytes32 id) external view returns (uint256) {

        return _getClosingObligation(id);
    }

    function getDueTime(bytes32 id) external view returns (uint256) {

        Config storage config = configs[id];
        if (config.cuota == 0)
            return 0;
        uint256 last = states[id].lastPayment;
        uint256 duration = config.duration;
        last = last != 0 ? last : duration;
        return last - (last % duration) + config.lentTime;
    }

    function getFinalTime(bytes32 id) external view returns (uint256) {

        Config storage config = configs[id];
        return config.lentTime + (uint256(config.duration) * (uint256(config.installments)));
    }

    function getFrequency(bytes32 id) external view returns (uint256) {

        return configs[id].duration;
    }

    function getInstallments(bytes32 id) external view returns (uint256) {

        return configs[id].installments;
    }

    function getEstimateObligation(bytes32 id) external view returns (uint256) {

        return _getClosingObligation(id);
    }

    function simFirstObligation(bytes calldata _data) external view returns (uint256 amount, uint256 time) {

        (amount,,, time,) = _decodeData(_data);
    }

    function simTotalObligation(bytes calldata _data) external view returns (uint256 amount) {

        (uint256 cuota,, uint256 installments,,) = _decodeData(_data);
        amount = cuota * installments;
    }

    function simDuration(bytes calldata _data) external view returns (uint256 duration) {

        (,,uint256 installments, uint256 installmentDuration,) = _decodeData(_data);
        duration = installmentDuration * installments;
    }

    function simPunitiveInterestRate(bytes calldata _data) external view returns (uint256 punitiveInterestRate) {

        (,punitiveInterestRate,,,) = _decodeData(_data);
    }

    function simFrequency(bytes calldata _data) external view returns (uint256 frequency) {

        (,,, frequency,) = _decodeData(_data);
    }

    function simInstallments(bytes calldata _data) external view returns (uint256 installments) {

        (,, installments,,) = _decodeData(_data);
    }

    function _advanceClock(bytes32 id, uint256 _target) internal returns (bool) {

        Config storage config = configs[id];
        State storage state = states[id];

        uint256 clock = state.clock;
        if (clock < _target) {
            (uint256 newInterest, uint256 newClock) = _runAdvanceClock({
                _clock: clock,
                _timeUnit: config.timeUnit,
                _interest: state.interest,
                _duration: config.duration,
                _cuota: config.cuota,
                _installments: config.installments,
                _paidBase: state.paidBase,
                _interestRate: config.interestRate,
                _targetClock: _target
            });

            require(newClock < U_64_OVERFLOW, "Clock overflow");
            require(newInterest < U_128_OVERFLOW, "Interest overflow");

            emit _setClock(id, uint64(newClock));

            if (newInterest != 0) {
                emit _setInterest(id, uint128(newInterest));
            }

            state.clock = uint64(newClock);
            state.interest = uint128(newInterest);

            return true;
        }
    }

    function _getClosingObligation(bytes32 id) internal view returns (uint256) {

        State storage state = states[id];
        Config storage config = configs[id];

        uint256 installments = config.installments;
        uint256 cuota = config.cuota;
        uint256 currentClock = uint64(now) - config.lentTime;

        uint256 interest;
        uint256 clock = state.clock;

        if (clock >= currentClock) {
            interest = state.interest;
        } else {
            (interest,) = _runAdvanceClock({
                _clock: clock,
                _timeUnit: config.timeUnit,
                _interest: state.interest,
                _duration: config.duration,
                _cuota: cuota,
                _installments: installments,
                _paidBase: state.paidBase,
                _interestRate: config.interestRate,
                _targetClock: currentClock
            });
        }

        uint256 debt = cuota * installments + interest;
        uint256 paid = state.paid;
        return debt > paid ? debt - paid : 0;
    }

    function _runAdvanceClock(
        uint256 _clock,
        uint256 _timeUnit,
        uint256 _interest,
        uint256 _duration,
        uint256 _cuota,
        uint256 _installments,
        uint256 _paidBase,
        uint256 _interestRate,
        uint256 _targetClock
    ) internal pure returns (uint256 interest, uint256 clock) {

        clock = _clock;
        interest = _interest;

        uint256 delta;
        bool installmentCompleted;

        do {
            (delta, installmentCompleted) = _calcDelta({
                _targetDelta: _targetClock - clock,
                _clock: clock,
                _duration: _duration,
                _installments: _installments
            });

            uint256 newInterest = _newInterest({
                _clock: clock,
                _timeUnit: _timeUnit,
                _duration: _duration,
                _installments: _installments,
                _cuota: _cuota,
                _paidBase: _paidBase,
                _delta: delta,
                _interestRate: _interestRate
            });

            if (installmentCompleted || newInterest > 0) {
                clock += delta;
                interest += newInterest;
            } else {
                break;
            }
        } while (clock < _targetClock);
    }

    function _calcDelta(
        uint256 _targetDelta,
        uint256 _clock,
        uint256 _duration,
        uint256 _installments
    ) internal pure returns (uint256 delta, bool installmentCompleted) {

        uint256 nextInstallmentDelta = _duration - _clock % _duration;
        if (nextInstallmentDelta <= _targetDelta && _clock / _duration < _installments) {
            delta = nextInstallmentDelta;
            installmentCompleted = true;
        } else {
            delta = _targetDelta;
            installmentCompleted = false;
        }
    }

    function _newInterest(
        uint256 _clock,
        uint256 _timeUnit,
        uint256 _duration,
        uint256 _installments,
        uint256 _cuota,
        uint256 _paidBase,
        uint256 _delta,
        uint256 _interestRate
    ) internal pure returns (uint256) {

        uint256 runningDebt = _baseDebt(_clock, _duration, _installments, _cuota) - _paidBase;
        uint256 newInterest = (100000 * (_delta / _timeUnit) * runningDebt) / (_interestRate / _timeUnit);
        require(newInterest < U_128_OVERFLOW, "New interest overflow");
        return newInterest;
    }

    function _baseDebt(
        uint256 clock,
        uint256 duration,
        uint256 installments,
        uint256 cuota
    ) internal pure returns (uint256 base) {

        uint256 installment = clock / duration;
        return uint128(installment < installments ? installment * cuota : installments * cuota);
    }

    function _validate(
        bytes memory _data
    ) internal pure returns (uint128 cuota, uint256 interestRate, uint24 installments, uint40 duration, uint32 timeUnit) {

        (cuota, interestRate, installments, duration, timeUnit) = _decodeData(_data);

        require(cuota > 0, "Cuota can't be 0");
        require(installments > 0, "Installments can't be 0");
        require(timeUnit > 0, "Time unit can't be 0");

        require(timeUnit <= duration, "Time unit must be lower or equal than installment duration");
        require(timeUnit < interestRate, "Interest rate by time unit is too low");
    }

    function _decodeData(
        bytes memory _data
    ) internal pure returns (uint128, uint256, uint24, uint40, uint32) {

        require(_data.length == L_DATA, "Invalid data length");
        (
            bytes32 cuota,
            bytes32 interestRate,
            bytes32 installments,
            bytes32 duration,
            bytes32 timeUnit
        ) = decode(_data, 16, 32, 3, 5, 4);
        return (uint128(uint256(cuota)), uint256(interestRate), uint24(uint256(installments)), uint40(uint256(duration)), uint32(uint256(timeUnit)));
    }
}


pragma solidity ^0.5.12;




library Math {

    function divRound(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

        require(_b != 0, "div by zero");

        c = _a / _b;
        if (_a % _b != 0) {
            c = c + 1;
        }
    }
}

library SafeCast {

    function toUint128(uint256 a) internal pure returns (uint128) {

        require(a < 340282366920938463463374607431768211456, "uint128 Overflow");
        return uint128(a);
    }

    function toUint64(uint256 a) internal pure returns (uint64) {

        require(a < 18446744073709551615, "uint64 Overflow");
        return uint64(a);
    }

    function toUint40(uint256 a) internal pure returns (uint40) {

        require(a < 1099511627775, "uint40 Overflow");
        return uint40(a);
    }

    function toUint24(uint256 a) internal pure returns (uint24) {

        require(a < 16777215, "uint24 Overflow");
        return uint24(a);
    }
}


contract LoanCreator is Ownable {

    using SafeMath for uint256;
    using SafeCast for uint256;
    using Math for uint256;

    mapping(address => bool) public operators;
    mapping(string => uint256) public limitByCurrency;
    mapping(string => uint256) public requestedByCurrency;
    mapping(string => uint256) public maxInterestByCurrency;

    event SetLimit(string currency, uint256 limit);
    event SetMaxInterest(string currency, uint256 maxInterest);
    event SetMaxDuration(uint256 duration);
    event SetOperator(address operator, bool enabled);
    event Requested(bytes32 _id);
    event NotCanceled(bytes32 _id);
    event Canceled(bytes32 _id);
    event CancelationNote(bytes32 _note);

    uint256 maxDuration;

    LoanManager public manager;
    InstallmentsModel public model;
    OracleFactory public oracleFactory;

    uint32 private constant TIME_UNIT = 86400;
    uint256 private constant INTEREST_BASE = 100;
    uint256 private constant INTEREST_BASE_100 = INTEREST_BASE * 100;
    uint256 private constant ONE_DAY = 86400;
    uint256 private constant ONE_YEAR = ONE_DAY * 360;
    uint256 private constant MODEL_INTEREST_BASE = 3110400000000;
    uint256 private constant END_SALT_FLAG = 65535;

    constructor(
        LoanManager _manager,
        InstallmentsModel _model,
        OracleFactory _oracleFactory
    ) public {
        manager = _manager;
        model = _model;
        oracleFactory = _oracleFactory;
    }

    modifier onlyOperator() {

        require(
            operators[msg.sender] || _owner == msg.sender,
            "Not authorized"
        );

        _;
    }

    function setOperator(
        address _operator,
        bool _enabled
    ) external onlyOwner {

        emit SetOperator(_operator, _enabled);
        operators[_operator] = _enabled;
    }

    function setLimitByCurrency(
        string calldata _currency,
        uint256 _limit
    ) external onlyOwner {

        emit SetLimit(_currency, _limit);
        limitByCurrency[_currency] = _limit;
    }

    function setMaxInterest(
        string calldata _currency,
        uint256 _limit
    ) external onlyOwner {

        emit SetMaxInterest(_currency, _limit);
        maxInterestByCurrency[_currency] = _limit;
    }

    function setMaxDuration(
        uint256 _duration
    ) external onlyOwner {

        emit SetMaxDuration(_duration);
        maxDuration = _duration;
    }

    function requestLoan(
        uint256 _loans,
        string memory _currency,
        uint256 _amount,
        uint256 _cuota,
        uint256 _penaltyInterestRate,
        uint256 _installments,
        uint256 _installmentDurationInDays,
        uint256 _expiresInDays
    ) public onlyOperator {

        require(_amount != 0, "amount can't be zero");
        uint256 maxInterestRate = maxInterestByCurrency[_currency];
        require(_penaltyInterestRate <= maxInterestRate, "penalty interest rate too high");
        require(_calcAproxInterest(_cuota, _amount, _installments, _installmentDurationInDays) <= maxInterestRate, "interest rate too high");
        require(_penaltyInterestRate != 0, "interest rate can't be zero");
        require(_expiresInDays != 0, "expires in can't be zero");

        uint256 totalRequested = _amount.mult(_loans).add(requestedByCurrency[_currency]);
        requestedByCurrency[_currency] = totalRequested;
        require(totalRequested <= limitByCurrency[_currency], "exceeded total requested");

        InstallmentsModel _model = model;

        uint256 saltBase = (END_SALT_FLAG << 240) | (totalRequested << 64) | (block.timestamp);
        uint256 expirationTime = block.timestamp.add(_expiresInDays.mult(ONE_DAY));

        bytes memory modelData = _encodeModelData(
            _model,
            _cuota,
            _penaltyInterestRate,
            _installments,
            _installmentDurationInDays
        );

        _createLoans(
            _loans,
            _currency,
            _amount.toUint128(),
            address(_model),
            saltBase,
            expirationTime.toUint64(),
            modelData
        );
    }

    function cancelLoan(
        bytes32 _id
    ) external onlyOperator {

        LoanManager _manager = manager;
        string memory currency = oracleFactory.oracleToSymbol(_manager.getOracle(_id));
        require(bytes(currency).length > 0, "currency is not valid");
        uint256 amount = _manager.getAmount(_id);
        require(_manager.cancel(_id), "error canceling loan");
        requestedByCurrency[currency] = requestedByCurrency[currency].sub(amount);
    }

    function cancelLoans(
        string calldata _currency,
        bytes32[] calldata _ids
    ) external onlyOperator {

        address expectedOracle = oracleFactory.symbolToOracle(_currency);
        require(expectedOracle != address(0), "currency does not exists");

        uint256 total = _ids.length;
        LoanManager _manager = manager;
        uint256 totalAmount = 0;

        for (uint256 i = 0; i < total; i++) {
            bytes32 id = _ids[i];
            uint256 status = _manager.getStatus(id);
            address oracle = _manager.getOracle(id);

            if (status != 0 || expectedOracle != oracle) {
                emit NotCanceled(id);
            } else {
                totalAmount = totalAmount.add(_manager.getAmount(id));
                require(_manager.cancel(id), "error canceling loan");
            }
        }

        requestedByCurrency[_currency] = requestedByCurrency[_currency].sub(totalAmount);
    }


    function cancelWithNote(
        bytes32 _id
    ) external onlyOperator {

        LoanManager _manager = manager;
        address oracle = _manager.getOracle(_id);
        string memory currency = oracleFactory.oracleToSymbol(oracle);

        bytes32 next = _id;
        uint256 totalAmount = 0;
        do {
            bytes32 afterNext = _readSalt(_manager, next);
            if (_manager.getStatus(next) == 0 && oracle == _manager.getOracle(next)) {
                totalAmount = totalAmount.add(_manager.getAmount(next));
                require(_manager.cancel(next), "error canceling loan");
            } else {
                emit NotCanceled(next);
            }
            next = afterNext;
        } while (uint256(next) != 0 && uint256(next >> 240) != END_SALT_FLAG);

        requestedByCurrency[currency] = requestedByCurrency[currency].sub(totalAmount);
    }

    function withdraw(
        IERC20 _token,
        address _to,
        uint256 _amount
    ) external onlyOwner {

        _token.transfer(_to, _amount);
    }

    function _readSalt(
        LoanManager _manager,
        bytes32 _id
    ) private view returns (bytes32) {

        (,,,,,,,,,,uint256 salt,) = _manager.requests(_id);
        return bytes32(salt);
    }

    function _loadOracle(
        string memory _currency
    ) private view returns (address) {

        return oracleFactory.symbolToOracle(_currency);
    }

    function _calcAproxInterest(
        uint256 _cuota,
        uint256 _amount,
        uint256 _installments,
        uint256 _installmentDurationInDays
    ) private pure returns (uint256) {

        return ((_cuota.mult(_installments).mult(INTEREST_BASE_100) / _amount).sub(INTEREST_BASE_100).mult(_installmentDurationInDays)) / 360;
    }

    function _createLoans(
        uint256 _loans,
        string memory _currency,
        uint128 _amount,
        address _model,
        uint256 _saltBase,
        uint64 _expirationTime,
        bytes memory _modelData
    ) private {

        address oracle = _loadOracle(_currency);
        require(oracle != address(0), "oracle for symbol not found");
        LoanManager _manager = manager;
        uint256 nextSalt = _saltBase;

        for (uint256 i; i < _loans; i++) {
            bytes32 id = _manager.requestLoan(
                _amount,
                address(_model),
                oracle,
                address(this),
                address(0),
                nextSalt,
                _expirationTime,
                _modelData
            );

            nextSalt = uint256(id);

            emit Requested(id);
        }

        emit CancelationNote(bytes32(nextSalt));
    }

    function _encodeModelData(
        InstallmentsModel _model,
        uint256 _cuota,
        uint256 _penaltyInterestRate,
        uint256 _installments,
        uint256 _installmentDurationInDays
    ) private view returns (bytes memory) {

        uint256 installmentDuration = _installmentDurationInDays.mult(ONE_DAY);
        uint256 totalDuration = installmentDuration.mult(_installments);
        require(totalDuration <= maxDuration, "total duration exceeds allowed");
        require(totalDuration != 0, "total duration can't be zero");

        return _model.encodeData(
            _cuota.toUint128(),
            MODEL_INTEREST_BASE.mult(INTEREST_BASE) / _penaltyInterestRate,
            _installments.toUint24(),
            installmentDuration.toUint40(),
            TIME_UNIT
        );
    }
}