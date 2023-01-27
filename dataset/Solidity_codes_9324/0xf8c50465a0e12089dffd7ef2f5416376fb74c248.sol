
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
library SafeMathUpgradeable {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
}
interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function decimals() external view returns (uint8);


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
interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}
interface IERC721Upgradeable is IERC165Upgradeable {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}
interface IERC1155Upgradeable is IERC165Upgradeable {

    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(
        address indexed account,
        address indexed operator,
        bool approved
    );

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id)
        external
        view
        returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator)
        external
        view
        returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

}
contract Trade is Initializable,OwnableUpgradeable {

    event OrderPlace(
        address indexed from,
        uint256 indexed tokenId,
        uint256 indexed value
    );
    event CancelOrder(address indexed from, uint256 indexed tokenId);
    event ChangePrice(address indexed from, uint256 indexed tokenId, uint256 indexed value);
    using SafeMathUpgradeable for uint256;
    function initialize() public initializer  {

        __Ownable_init();
        serviceValue = 2500000000000000000;
        deci = 18;
    }
    struct Order {
        uint256 tokenId;
        uint256 price;
        address contractAddress;
    }
    mapping(address => mapping(uint256 => Order)) public order_place;
    mapping(string => address) private tokentype;
    mapping(address => mapping(address => bool)) public approveStatus;
    uint256 private serviceValue;
    uint256 deci;
    function getApproveStatus(address owneraddrrss,address contractaddress) public view returns (bool) {

        return approveStatus[owneraddrrss][contractaddress];
    }
    function getServiceFee() public view returns (uint256) {

        return serviceValue;
    }
    function serviceFunction(uint256 _serviceValue) public onlyOwner { 

        serviceValue = _serviceValue;
    }
    function getTokenAddress(string memory _type) public view returns (address) {

        return tokentype[_type];
    }
    function addTokenType(string[] memory _type,address[] memory tokenAddress) public onlyOwner{

        require(_type.length == tokenAddress.length,"Not equal for type and tokenAddress");
        for(uint i = 0; i < _type.length; i++) {
            tokentype[_type[i]] = tokenAddress[i];
        }
    }
    function pERCent(uint256 value1, uint256 value2) internal pure returns (uint256) {

        uint256 result = value1.mul(value2).div(1e20);
        return (result);
    }
    function calc(uint256 amount, uint256 _serviceValue) internal pure returns (uint256, uint256) {

        uint256 fee = pERCent(amount, _serviceValue);
        uint256 netamount = amount.sub(fee);
        fee = fee.add(fee);
        return (fee, netamount);
    }
    function orderPlace(uint256 tokenId, uint256 _price, address _conAddress, uint256 _type) public{

        if(_type == 721){
            require(IERC721Upgradeable(_conAddress).balanceOf(msg.sender) > 0 ,"Not a Owner");
        }
        else{
            require(IERC1155Upgradeable(_conAddress).balanceOf(msg.sender, tokenId) > 0 ,"Not a Owner");
        }
        require( _price > 0, "Price Must be greater than zero");
        approveStatus[msg.sender][_conAddress] = true;
        Order memory order;
        order.tokenId = tokenId;
        order.price = _price;
        order.contractAddress = _conAddress;
        order_place[msg.sender][tokenId] = order;
        emit OrderPlace(msg.sender, tokenId, _price);
    }
    function cancelOrder(uint256 tokenId) public{

        delete order_place[msg.sender][tokenId];
        emit CancelOrder(msg.sender, tokenId);
    }
    function changePrice(uint256 value, uint256 tokenId) public{

        require( value < order_place[msg.sender][tokenId].price);
        order_place[msg.sender][tokenId].price = value;
        emit ChangePrice(msg.sender, tokenId, value);
    }
    function saleToken(address payable from, uint256 tokenId, uint256 amount, uint256 nooftoken, uint nftType, address _conAddr) public payable {

        require(amount == order_place[from][tokenId].price.mul(nooftoken) &&  order_place[from][tokenId].price.mul(nooftoken) > 0, "Invalid Balance");
        _saleToken(from, amount, "BNB");
        if(nftType == 721){
            IERC721Upgradeable(_conAddr).safeTransferFrom(from, msg.sender, tokenId);
        }
        else{
            IERC1155Upgradeable(_conAddr).safeTransferFrom(from, msg.sender, tokenId, nooftoken, "");

        }
    }
    function _saleToken(address payable from, uint256 amount, string memory bidtoken) internal {

        uint256 val = pERCent(amount, serviceValue).add(amount);
        if(keccak256(abi.encodePacked((bidtoken))) == keccak256(abi.encodePacked(("BNB")))){   
            require( msg.value == val, "Insufficient Balance");
            (uint256 _adminfee, uint256 netamount) = calc(amount, serviceValue);
            require( msg.value == _adminfee.add(netamount), "Insufficient Balance");
            if(_adminfee != 0){
                payable(owner()).transfer(_adminfee);
            }
            if(netamount != 0){
                from.transfer(netamount);
            }
        }
        else{
            IERC20Upgradeable t = IERC20Upgradeable(tokentype[bidtoken]);
            uint256 Tokendecimals = deci.sub(t.decimals());
            uint256 approveValue = t.allowance(msg.sender, address(this));
            require( approveValue >= val.div(10**Tokendecimals), "Insufficient Balance");
            (uint256 _adminfee, uint256 netamount) = calc(amount, serviceValue);
            require( approveValue >= _adminfee.add(netamount).div(10**Tokendecimals), "Insufficient Balance");
            if(_adminfee != 0){
                t.transferFrom(msg.sender, owner(), _adminfee.div(10**Tokendecimals));
            }
            if(netamount != 0){
                t.transferFrom(msg.sender,from,netamount.div(10**Tokendecimals));
            }
        }
    }
    function saleWithToken(address payable from, uint256 tokenId, uint256 amount, uint256 nooftoken, string memory bidtoken, uint nftType, address _conAddr) public{

        require(amount == order_place[from][tokenId].price.mul(nooftoken) , "Insufficent Balance");
        _saleToken(from, amount, bidtoken);
        if(nftType == 721){
            IERC721Upgradeable(_conAddr).safeTransferFrom(from, msg.sender, tokenId);
        }
        else{
            IERC1155Upgradeable(_conAddr).safeTransferFrom(from, msg.sender, tokenId, nooftoken, "");
        }     
    }
    function acceptBId(string memory bidtoken,address bidaddr, uint256 amount, uint256 tokenId, uint256 nooftoken, uint256 nftType, address _conAddr) public{

        _acceptBId(bidtoken, bidaddr, owner(), amount);
        if(nftType == 721){
            IERC721Upgradeable(_conAddr).safeTransferFrom(msg.sender, bidaddr, tokenId);
        }
        else{
            IERC1155Upgradeable(_conAddr).safeTransferFrom(msg.sender, bidaddr, tokenId, nooftoken, "");

        }
    }
    function _acceptBId(string memory tokenAss,address from, address admin, uint256 amount) internal{

        uint256 val = pERCent(amount, serviceValue).add(amount);
        IERC20Upgradeable t = IERC20Upgradeable(tokentype[tokenAss]);
        uint256 Tokendecimals = deci.sub(t.decimals());
        uint256 approveValue = t.allowance(from, address(this));
        require( approveValue >= val.div(10**Tokendecimals) && val > 0, "Insufficient Balance");
        (uint256 _adminfee, uint256 netamount) = calc(amount, serviceValue);
        require( approveValue >= _adminfee.add(netamount.div(10**Tokendecimals)), "Insufficient Balance");
        if(_adminfee != 0){
            t.transferFrom(from,admin,_adminfee.div(10**Tokendecimals));
        }
        if(netamount != 0){
            t.transferFrom(from,msg.sender,netamount.div(10**Tokendecimals));
        }
    }
}