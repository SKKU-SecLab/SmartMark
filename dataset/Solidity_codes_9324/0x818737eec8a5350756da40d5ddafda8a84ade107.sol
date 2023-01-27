


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


pragma solidity ^0.6.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


pragma solidity ^0.6.2;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);



    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

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


abstract contract IERC1155 is IERC165 {
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) public view virtual returns (uint256);

    function balanceOfBatch(address[] memory accounts, uint256[] memory ids) public view virtual returns (uint256[] memory);

    function setApprovalForAll(address operator, bool approved) external virtual;

    function isApprovedForAll(address account, address operator) external view virtual returns (bool);

    function safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes calldata data) external virtual;

    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata values, bytes calldata data) external virtual;
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






contract ERC1155 is ERC165, IERC1155
{

    using SafeMath for uint256;
    using Address for address;

    mapping (uint256 => mapping(address => uint256)) private _balances;

    mapping (address => mapping(address => bool)) private _operatorApprovals;

    mapping (uint256 => bool) private _tokenExists;

    bytes4 private constant _INTERFACE_ID_ERC1155 = 0xd9b67a26;

    constructor() public {
        _registerInterface(_INTERFACE_ID_ERC1155);
    }

    function balanceOf(address account, uint256 id) public view override returns (uint256) {

        require(account != address(0), "ERC1155: balance query for the zero address");
        require(_exists(id), "ERC1155: balance query for nonexistent token");
        return _balances[id][account];
    }

    function balanceOfBatch(
        address[] memory accounts,
        uint256[] memory ids
    )
        public
        view
        override
        returns (uint256[] memory)
    {

        require(accounts.length == ids.length, "ERC1155: accounts and IDs must have same lengths");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            require(accounts[i] != address(0), "ERC1155: some address in batch balance query is zero");
            require(_exists(ids[i]), "ERC1155: some token in batch balance query does not exist");
            batchBalances[i] = _balances[ids[i]][accounts[i]];
        }

        return batchBalances;
    }

    function setApprovalForAll(address operator, bool approved) external override virtual {

        require(msg.sender != operator, "ERC1155: cannot set approval status for self");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address account, address operator) public view override returns (bool) {

        return _operatorApprovals[account][operator];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        override
        virtual
    {

        require(to != address(0), "ERC1155: target address must be non-zero");
        require(
            from == msg.sender || isApprovedForAll(from, msg.sender) == true,
            "ERC1155: need operator approval for 3rd party transfers"
        );

        _balances[id][from] = _balances[id][from].sub(value, "ERC1155: insufficient balance for transfer");
        _balances[id][to] = _balances[id][to].add(value);

        emit TransferSingle(msg.sender, from, to, id, value);

        _doSafeTransferAcceptanceCheck(msg.sender, from, to, id, value, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        override
        virtual
    {

        require(ids.length == values.length, "ERC1155: IDs and values must have same lengths");
        require(to != address(0), "ERC1155: target address must be non-zero");
        require(
            from == msg.sender || isApprovedForAll(from, msg.sender) == true,
            "ERC1155: need operator approval for 3rd party transfers"
        );

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 value = values[i];

            _balances[id][from] = _balances[id][from].sub(
                value,
                "ERC1155: insufficient balance of some token type for transfer"
            );
            _balances[id][to] = _balances[id][to].add(value);
        }

        emit TransferBatch(msg.sender, from, to, ids, values);

        _doSafeBatchTransferAcceptanceCheck(msg.sender, from, to, ids, values, data);
    }

    function _registerToken(uint256 id) internal virtual {

        _tokenExists[id] = true;
    }

    function _exists(uint256 id) internal view returns (bool) {

        return _tokenExists[id];
    }

    function _mint(address to, uint256 id, uint256 value, bytes memory data) internal virtual {

        require(to != address(0), "ERC1155: mint to the zero address");

        if (!_exists(id)) {
            _registerToken(id);
        }
        _balances[id][to] = _balances[id][to].add(value);
        emit TransferSingle(msg.sender, address(0), to, id, value);

        _doSafeTransferAcceptanceCheck(msg.sender, address(0), to, id, value, data);
    }

    function _mintBatch(address to, uint256[] memory ids, uint256[] memory values, bytes memory data) internal virtual {

        require(to != address(0), "ERC1155: batch mint to the zero address");
        require(ids.length == values.length, "ERC1155: minted IDs and values must have same lengths");

        for(uint i = 0; i < ids.length; i++) {
            if (!_exists(ids[i])) {
                _registerToken(ids[i]);
            }
            _balances[ids[i]][to] = values[i].add(_balances[ids[i]][to]);
        }

        emit TransferBatch(msg.sender, address(0), to, ids, values);

        _doSafeBatchTransferAcceptanceCheck(msg.sender, address(0), to, ids, values, data);
    }

    function _burn(address account, uint256 id, uint256 value) internal virtual {

        require(account != address(0), "ERC1155: attempting to burn tokens on zero account");

        _balances[id][account] = _balances[id][account].sub(
            value,
            "ERC1155: attempting to burn more than balance"
        );
        emit TransferSingle(msg.sender, account, address(0), id, value);
    }

    function _burnBatch(address account, uint256[] memory ids, uint256[] memory values) internal virtual {

        require(account != address(0), "ERC1155: attempting to burn batch of tokens on zero account");
        require(ids.length == values.length, "ERC1155: burnt IDs and values must have same lengths");

        for(uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][account] = _balances[ids[i]][account].sub(
                values[i],
                "ERC1155: attempting to burn more than balance for some token"
            );
        }

        emit TransferBatch(msg.sender, account, address(0), ids, values);
    }

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    )
        internal
        virtual
    {

        if(to.isContract()) {
            require(
                IERC1155Receiver(to).onERC1155Received(operator, from, id, value, data) ==
                    IERC1155Receiver(to).onERC1155Received.selector,
                "ERC1155: got unknown value from onERC1155Received"
            );
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    )
        internal
        virtual
    {

        if(to.isContract()) {
            require(
                IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, values, data) ==
                    IERC1155Receiver(to).onERC1155BatchReceived.selector,
                "ERC1155: got unknown value from onERC1155BatchReceived"
            );
        }
    }
}


pragma solidity ^0.6.0;


abstract contract IERC1155MetadataURI is IERC1155 {
    function uri(uint256 id) external view virtual returns (string memory);
}


pragma solidity ^0.6.0;




contract ERC1155MetadataURICatchAll is ERC165, ERC1155, IERC1155MetadataURI {

    string private _uri;

    bytes4 private constant _INTERFACE_ID_ERC1155_METADATA_URI = 0x0e89341c;

    constructor (string memory uri) public {
        _setURI(uri);

        _registerInterface(_INTERFACE_ID_ERC1155_METADATA_URI);
    }

    function uri(uint256 id) external view override returns (string memory) {

        require(_exists(id), "ERC1155MetadataURI: URI query for nonexistent token");
        return _uri;
    }

    function _setURI(string memory newuri) internal virtual {

        _uri = newuri;
        emit URI(_uri, 0);
    }
}


pragma solidity ^0.6.0;

interface ENSRegistryOwnerI {

    function owner(bytes32 node) external view returns (address);

}

interface ENSReverseRegistrarI {

    function setName(string calldata name) external returns (bytes32 node);

}


pragma solidity ^0.6.0;


abstract contract OracleRequest {

    uint256 public EUR_WEI; //number of wei per EUR

    uint256 public lastUpdate; //timestamp of when the last update occurred

    function ETH_EUR() public view virtual returns (uint256); //number of EUR per ETH (rounded down!)

    function ETH_EURCENT() public view virtual returns (uint256); //number of EUR cent per ETH (rounded down!)

}


pragma solidity ^0.6.0;

abstract contract CS2PresaleIBuyDP {
    enum AssetType {
        Honeybadger,
        Llama,
        Panda,
        Doge
    }

    function buy(AssetType _type, address payable _recipient) public payable virtual;

}


pragma solidity ^0.6.0;






contract CS2PresaleDirectPay {

    using SafeMath for uint256;

    address public tokenAssignmentControl;

    CS2PresaleIBuyDP public presale;
    CS2PresaleIBuyDP.AssetType public assetType;

    event TokenAssignmentControlTransferred(address indexed previousTokenAssignmentControl, address indexed newTokenAssignmentControl);

    constructor(CS2PresaleIBuyDP _presale,
        CS2PresaleIBuyDP.AssetType _assetType,
        address _tokenAssignmentControl)
    public
    {
        presale = _presale;
        require(address(presale) != address(0x0), "You need to provide an actual presale contract.");
        assetType = _assetType;
        tokenAssignmentControl = _tokenAssignmentControl;
        require(address(tokenAssignmentControl) != address(0x0), "You need to provide an actual tokenAssignmentControl address.");
    }

    modifier onlyTokenAssignmentControl() {

        require(msg.sender == tokenAssignmentControl, "tokenAssignmentControl key required for this function.");
        _;
    }


    function transferTokenAssignmentControl(address _newTokenAssignmentControl)
    public
    onlyTokenAssignmentControl
    {

        require(_newTokenAssignmentControl != address(0), "tokenAssignmentControl cannot be the zero address.");
        emit TokenAssignmentControlTransferred(tokenAssignmentControl, _newTokenAssignmentControl);
        tokenAssignmentControl = _newTokenAssignmentControl;
    }


    receive()
    external payable
    {
        presale.buy{value: msg.value}(assetType, msg.sender);
    }


    function registerReverseENS(address _reverseRegistrarAddress, string calldata _name)
    external
    onlyTokenAssignmentControl
    {

        require(_reverseRegistrarAddress != address(0), "need a valid reverse registrar");
        ENSReverseRegistrarI(_reverseRegistrarAddress).setName(_name);
    }


    function rescueToken(IERC20 _foreignToken, address _to)
    external
    onlyTokenAssignmentControl
    {

        _foreignToken.transfer(_to, _foreignToken.balanceOf(address(this)));
    }

    function approveNFTrescue(IERC721 _foreignNFT, address _to)
    external
    onlyTokenAssignmentControl
    {

        _foreignNFT.setApprovalForAll(_to, true);
    }

}


pragma solidity ^0.6.0;









contract CS2Presale is ERC1155MetadataURICatchAll, CS2PresaleIBuyDP {

    using SafeMath for uint256;

    OracleRequest internal oracle;

    address payable public beneficiary;
    address public tokenAssignmentControl;
    address public redeemer;

    uint256 public priceEurCent;

    uint256 public limitPerType;

    uint256[4] public assetSupply;
    uint256[4] public assetSold;
    CS2PresaleDirectPay[4] public directPay;

    bool internal _isOpen = true;

    event DirectPayDeployed(address directPayContract);
    event PriceChanged(uint256 previousPriceEurCent, uint256 newPriceEurCent);
    event LimitChanged(uint256 previousLimitPerType, uint256 newLimitPerType);
    event OracleChanged(address indexed previousOracle, address indexed newOracle);
    event BeneficiaryTransferred(address indexed previousBeneficiary, address indexed newBeneficiary);
    event TokenAssignmentControlTransferred(address indexed previousTokenAssignmentControl, address indexed newTokenAssignmentControl);
    event RedeemerTransferred(address indexed previousRedeemer, address indexed newRedeemer);
    event ShopOpened();
    event ShopClosed();

    constructor(OracleRequest _oracle,
        uint256 _priceEurCent,
        uint256 _limitPerType,
        address payable _beneficiary,
        address _tokenAssignmentControl)
    ERC1155MetadataURICatchAll("https://test.crypto.post.at/CS2PS/meta/{id}")
    public
    {
        oracle = _oracle;
        require(address(oracle) != address(0x0), "You need to provide an actual Oracle contract.");
        beneficiary = _beneficiary;
        require(address(beneficiary) != address(0x0), "You need to provide an actual beneficiary address.");
        tokenAssignmentControl = _tokenAssignmentControl;
        require(address(tokenAssignmentControl) != address(0x0), "You need to provide an actual tokenAssignmentControl address.");
        redeemer = tokenAssignmentControl;
        priceEurCent = _priceEurCent;
        require(priceEurCent > 0, "You need to provide a non-zero price.");
        limitPerType = _limitPerType;
        uint256 typesNum = assetSupply.length;
        for (uint256 i = 0; i < typesNum; i++) {
            _registerToken(i);
        }
    }

    modifier onlyBeneficiary() {

        require(msg.sender == beneficiary, "Only the current benefinicary can call this function.");
        _;
    }

    modifier onlyTokenAssignmentControl() {

        require(msg.sender == tokenAssignmentControl, "tokenAssignmentControl key required for this function.");
        _;
    }

    modifier onlyRedeemer() {

        require(msg.sender == redeemer, "Only the current redeemer can call this function.");
        _;
    }

    modifier requireOpen() {

        require(isOpen() == true, "This call only works when the presale is open.");
        _;
    }


    function deployDP()
    public
    {

        uint256 typesNum = directPay.length;
        for (uint256 i = 0; i < typesNum; i++) {
            require(address(directPay[i]) == address(0x0), "direct-pay contracts have already been deployed.");
            directPay[i] = new CS2PresaleDirectPay(this, AssetType(i), tokenAssignmentControl);
            emit DirectPayDeployed(address(directPay[i]));
        }
    }


    function setPrice(uint256 _newPriceEurCent)
    public
    onlyBeneficiary
    {

        require(_newPriceEurCent > 0, "You need to provide a non-zero price.");
        emit PriceChanged(priceEurCent, _newPriceEurCent);
        priceEurCent = _newPriceEurCent;
    }

    function setLimit(uint256 _newLimitPerType)
    public
    onlyBeneficiary
    {

        uint256 typesNum = assetSold.length;
        for (uint256 i = 0; i < typesNum; i++) {
            require(assetSold[i] <= _newLimitPerType, "At least one requested asset is already over the requested limit.");
        }
        emit LimitChanged(limitPerType, _newLimitPerType);
        limitPerType = _newLimitPerType;
    }

    function setOracle(OracleRequest _newOracle)
    public
    onlyBeneficiary
    {

        require(address(_newOracle) != address(0x0), "You need to provide an actual Oracle contract.");
        emit OracleChanged(address(oracle), address(_newOracle));
        oracle = _newOracle;
    }

    function setMetadataURI(string memory _newURI)
    public
    onlyBeneficiary
    {

        _setURI(_newURI);
    }

    function transferBeneficiary(address payable _newBeneficiary)
    public
    onlyBeneficiary
    {

        require(_newBeneficiary != address(0), "beneficiary cannot be the zero address.");
        emit BeneficiaryTransferred(beneficiary, _newBeneficiary);
        beneficiary = _newBeneficiary;
    }

    function transferTokenAssignmentControl(address _newTokenAssignmentControl)
    public
    onlyTokenAssignmentControl
    {

        require(_newTokenAssignmentControl != address(0), "tokenAssignmentControl cannot be the zero address.");
        emit TokenAssignmentControlTransferred(tokenAssignmentControl, _newTokenAssignmentControl);
        tokenAssignmentControl = _newTokenAssignmentControl;
    }

    function transferRedeemer(address _newRedeemer)
    public
    onlyRedeemer
    {

        require(_newRedeemer != address(0), "redeemer cannot be the zero address.");
        emit RedeemerTransferred(redeemer, _newRedeemer);
        redeemer = _newRedeemer;
    }

    function openShop()
    public
    onlyBeneficiary
    {

        _isOpen = true;
        emit ShopOpened();
    }

    function closeShop()
    public
    onlyBeneficiary
    {

        _isOpen = false;
        emit ShopClosed();
    }


    function isOpen()
    public view
    returns (bool)
    {

        return _isOpen;
    }

    function priceWei()
    public view
    returns (uint256)
    {

        return priceEurCent.mul(oracle.EUR_WEI()).div(100);
    }

    function totalSupply()
    public view
    returns (uint256)
    {

        uint256 _totalSupply = 0;
        uint256 typesNum = assetSupply.length;
        for (uint256 i = 0; i < typesNum; i++) {
            _totalSupply = _totalSupply.add(assetSupply[i]);
        }
        return _totalSupply;
    }

    function totalSold()
    public view
    returns (uint256)
    {

        uint256 _totalSold = 0;
        uint256 typesNum = assetSold.length;
        for (uint256 i = 0; i < typesNum; i++) {
            _totalSold = _totalSold.add(assetSold[i]);
        }
        return _totalSold;
    }

    function availableForSale(AssetType _type)
    public view
    returns (uint256)
    {

        return limitPerType.sub(assetSold[uint256(_type)]);
    }

    function isSoldOut(AssetType _type)
    public view
    returns (bool)
    {

        return assetSold[uint256(_type)] >= limitPerType;
    }

    function buy(AssetType _type)
    external payable
    requireOpen
    {

        buy(_type, msg.sender);
    }

    function buy(AssetType _type, address payable _recipient)
    public payable override
    requireOpen
    {

        uint256 curPriceWei = priceWei();
        require(msg.value >= curPriceWei, "You need to send enough currency to actually pay at least one item.");
        uint256 maxToSell = limitPerType.sub(assetSold[uint256(_type)]);
        require(maxToSell > 0, "The requested asset is sold out.");
        uint256 assetCount = msg.value.div(curPriceWei);
        if (assetCount > maxToSell) {
            assetCount = maxToSell;
        }
        uint256 payAmount = assetCount.mul(curPriceWei);
        beneficiary.transfer(payAmount);
        _mint(_recipient, uint256(_type), assetCount, bytes(""));
        assetSupply[uint256(_type)] = assetSupply[uint256(_type)].add(assetCount);
        assetSold[uint256(_type)] = assetSold[uint256(_type)].add(assetCount);
        if (msg.value > payAmount) {
            _recipient.transfer(msg.value.sub(payAmount));
        }
    }

    function buyBatch(AssetType[] calldata _type, uint256[] calldata _count)
    external payable
    requireOpen
    {

        uint256 inputlines = _type.length;
        require(inputlines == _count.length, "Both input arrays need to be the same length.");
        uint256 curPriceWei = priceWei();
        require(msg.value >= curPriceWei, "You need to send enough currency to actually pay at least one item.");
        uint256 payAmount = 0;
        uint256[] memory ids = new uint256[](inputlines);
        for (uint256 i = 0; i < inputlines; i++) {
            payAmount = payAmount.add(_count[i].mul(curPriceWei));
            ids[i] = uint256(_type[i]);
            assetSupply[ids[i]] = assetSupply[ids[i]].add(_count[i]);
            assetSold[ids[i]] = assetSold[ids[i]].add(_count[i]);
            require(assetSold[ids[i]] <= limitPerType, "At least one requested asset is sold out.");
        }
        require(msg.value >= payAmount, "You need to send enough currency to actually pay all specified items.");
        beneficiary.transfer(payAmount);
        _mintBatch(msg.sender, ids, _count, bytes(""));
        if (msg.value > payAmount) {
            msg.sender.transfer(msg.value.sub(payAmount));
        }
    }

    function redeemBatch(address owner, AssetType[] calldata _type, uint256[] calldata _count)
    external
    onlyRedeemer
    {

        uint256 inputlines = _type.length;
        require(inputlines == _count.length, "Both input arrays need to be the same length.");
        uint256[] memory ids = new uint256[](inputlines);
        for (uint256 i = 0; i < inputlines; i++) {
            ids[i] = uint256(_type[i]);
            assetSupply[ids[i]] = assetSupply[ids[i]].sub(_count[i]);
        }
        _burnBatch(owner, ids, _count);
    }

    function exists(uint256 id) public view returns (bool) {

        return _exists(id);
    }


    function registerReverseENS(address _reverseRegistrarAddress, string calldata _name)
    external
    onlyTokenAssignmentControl
    {

        require(_reverseRegistrarAddress != address(0), "need a valid reverse registrar");
        ENSReverseRegistrarI(_reverseRegistrarAddress).setName(_name);
    }


    function rescueToken(IERC20 _foreignToken, address _to)
    external
    onlyTokenAssignmentControl
    {

        _foreignToken.transfer(_to, _foreignToken.balanceOf(address(this)));
    }

    function approveNFTrescue(IERC721 _foreignNFT, address _to)
    external
    onlyTokenAssignmentControl
    {

        _foreignNFT.setApprovalForAll(_to, true);
    }

}