
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


library SafeMath {

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


interface ICryptoFoxesSteak {

    function addRewards(address _to, uint256 _amount) external;

    function withdrawRewards(address _to) external;

    function isPaused() external view returns(bool);

    function dateEndRewards() external view returns(uint256);

}// MIT
pragma solidity ^0.8.0;



abstract contract CryptoFoxesAllowed is Ownable {

    mapping (address => bool) public allowedContracts;

    modifier isFoxContract() {
        require(allowedContracts[_msgSender()] == true, "Not allowed");
        _;
    }
    
    modifier isFoxContractOrOwner() {
        require(allowedContracts[_msgSender()] == true || _msgSender() == owner(), "Not allowed");
        _;
    }

    function setAllowedContract(address _contract, bool _allowed) public onlyOwner {
        allowedContracts[_contract] = _allowed;
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


interface ICryptoFoxesSteakBurnable is ICryptoFoxesSteak {

    function burnSteaks(address _to, uint256 _amount) external;

}// MIT
pragma solidity ^0.8.0;



interface ICryptoFoxesSteakBurnableShop is IERC20, ICryptoFoxesSteakBurnable {

    function burn(uint256 _amount) external;

}// MIT
pragma solidity ^0.8.0;


contract CryptoFoxesShopWithdraw is CryptoFoxesAllowed {

    using SafeMath for uint256;

    struct Part {
        address wallet;
        uint256 part;
        uint256 timestamp;
    }
    uint256 startIndexParts = 0;

    Part[] public parts;

    ICryptoFoxesSteakBurnableShop public cryptoFoxesSteak;

    constructor(address _cryptoFoxesSteak) {
        cryptoFoxesSteak = ICryptoFoxesSteakBurnableShop(_cryptoFoxesSteak);

        parts.push(Part(address(0), 90, block.timestamp));
    }

    function changePart(Part[] memory _parts) public isFoxContractOrOwner{

        startIndexParts = parts.length;
        for(uint256 i = 0; i < _parts.length; i++){
            parts.push(Part(_parts[i].wallet, _parts[i].part, block.timestamp));
        }
    }

    function getParts() public view returns(Part[] memory){

        return parts;
    }


    function withdrawAndBurn() public isFoxContractOrOwner {

        uint256 balance = cryptoFoxesSteak.balanceOf(address(this));
        require(balance > 0);

        for (uint256 i = startIndexParts; i < parts.length; i++) {
            if (parts[i].part == 0) {
                continue;
            }
            if (parts[i].wallet == address(0)) {
                cryptoFoxesSteak.burn(balance.mul(parts[i].part).div(100));
            } else {
                cryptoFoxesSteak.transfer(parts[i].wallet, balance.mul(parts[i].part).div(100));
            }
        }

        cryptoFoxesSteak.transfer(owner(), cryptoFoxesSteak.balanceOf(address(this)));
    }
}// MIT
pragma solidity ^0.8.0;


interface ICryptoFoxesShopStruct {


    struct Product {
        uint256 price;
        uint256 start;
        uint256 end;
        uint256 maxPerWallet; // 0 for infinity
        uint256 quantityMax; // 0 for infinity
        bool enable;
        bool isValid;
    }

}// MIT
pragma solidity ^0.8.0;



interface ICryptoFoxesShopProducts is ICryptoFoxesShopStruct {


    function getProducts() external view returns(Product[] memory);

    function getProduct(string calldata _slug) external view returns(Product memory);

}// MIT
pragma solidity ^0.8.0;


contract CryptoFoxesShopProducts is ICryptoFoxesShopProducts, CryptoFoxesAllowed{


    mapping(string => Product) public products;
    string[] public productSlugs;


    function addProduct(string memory _slug, Product memory _product) public isFoxContractOrOwner{

        require(!products[_slug].isValid, "Product slug already exist");
        require(_product.isValid, "Missing isValid param");
        products[_slug] = _product;
        productSlugs.push(_slug);
    }

    function editProduct(string memory _slug, Product memory _product) public isFoxContractOrOwner{

        require(products[_slug].isValid, "Product slug does not exist");
        require(_product.isValid, "Missing isValid param");

        if(products[_slug].maxPerWallet == 0){
            require(_product.maxPerWallet == 0, "maxPerWallet == 0, need to change slug");
        }

        products[_slug] = _product;
    }

    function statusProduct(string memory _slug, bool _enable) public isFoxContractOrOwner {

        require(products[_slug].isValid, "Product slug does not exist");
        products[_slug].enable = _enable;
    }


    function getProduct(string memory _slug) public override view returns(Product memory) {

        return products[_slug];
    }
    function getProducts() public override view returns(Product[] memory) {

        Product[] memory prods = new Product[](productSlugs.length);
        for(uint256 i = 0; i < productSlugs.length; i ++){
            prods[i] = products[productSlugs[i]];
        }
        return prods;
    }
    function getSlugs() public view returns(string[] memory) {

        return productSlugs;
    }

}// MIT
pragma solidity ^0.8.0;


contract CryptoFoxesShop is Ownable, CryptoFoxesShopProducts, CryptoFoxesShopWithdraw, ReentrancyGuard{


    mapping(string => uint256) public purchasedProduct;
    mapping(string => mapping(address => uint256)) public purchasedProductWallet;

    uint256 public purchaseId;

    event Purchase(address indexed _owner, string indexed _slug, uint256 _quantity, uint256 _id);

    constructor(address _cryptoFoxesSteak) CryptoFoxesShopWithdraw(_cryptoFoxesSteak) {}


    function checkPurchase(string memory _slug, uint256 _quantity, address _wallet) private{


        require(products[_slug].enable && _quantity > 0,"Product not available");

        if(products[_slug].start > 0 && products[_slug].end > 0){
            require(products[_slug].start <= block.timestamp && block.timestamp <= products[_slug].end, "Product not available");
        }

        if (products[_slug].quantityMax > 0) {
            require(purchasedProduct[_slug] + _quantity <= products[_slug].quantityMax, "Product sold out");
            purchasedProduct[_slug] += _quantity;
        }

        if(products[_slug].maxPerWallet > 0){
            require(purchasedProductWallet[_slug][_wallet] + _quantity <= products[_slug].maxPerWallet, "Max per wallet limit");
            purchasedProductWallet[_slug][_wallet] += _quantity;
        }
    }

    function _compareStrings(string memory a, string memory b) private pure returns (bool) {

        return keccak256(bytes(a)) == keccak256(bytes(b));
    }


    function purchase(string memory _slug, uint256 _quantity) public nonReentrant {

        _purchase(_msgSender(), _slug, _quantity);
    }

    function purchaseCart(string[] memory _slugs, uint256[] memory _quantities) public nonReentrant {

        _purchaseCart(_msgSender(), _slugs, _quantities);
    }

    function _purchase(address _wallet, string memory _slug, uint256 _quantity) private {


        checkPurchase(_slug, _quantity, _wallet);

        uint256 price = products[_slug].price * _quantity;

        if(price > 0){
            cryptoFoxesSteak.transferFrom(_wallet, address(this), price);
        }

        purchaseId += 1;
        emit Purchase(_msgSender(), _slug, _quantity, purchaseId);
    }

    function _purchaseCart(address _wallet, string[] memory _slugs, uint256[] memory _quantities) private  {

        require(_slugs.length == _quantities.length, "Bad data length");

        uint256 price = 0;
        for (uint256 i = 0; i < _slugs.length; i++) {
            for (uint256 j = 0; j < i; j++) {
                if(_compareStrings(_slugs[j], _slugs[i]) == true) {
                    revert("Duplicate slug");
                }
            }
            checkPurchase(_slugs[i], _quantities[i], _wallet);
            price += products[_slugs[i]].price * _quantities[i];
        }

        if(price > 0){
            cryptoFoxesSteak.transferFrom(_wallet, address(this), price);
        }

        for (uint256 i = 0; i < _slugs.length; i++) {
            purchaseId += 1;
            emit Purchase(_wallet, _slugs[i], _quantities[i], purchaseId);
        }
    }


    function purchaseByContract(address _wallet, string memory _slug, uint256 _quantity) public isFoxContract {

        _purchase(_wallet, _slug, _quantity);
    }

    function purchaseCartByContract(address _wallet, string[] memory _slugs, uint256[] memory _quantities) public isFoxContract {

        _purchaseCart(_wallet, _slugs, _quantities);
    }


    function getProductPrice(string memory _slug, uint256 _quantity) public view returns(uint256){

        return products[_slug].price * _quantity;
    }
    function getProductStock(string memory _slug) public view returns(uint256){

        return products[_slug].quantityMax - getTotalProductPurchased(_slug);
    }
    function getTotalProductPurchased(string memory _slug) public view returns(uint256){

        return purchasedProduct[_slug];
    }
    function getTotalProductPurchasedWallet(string memory _slug, address _wallet) public view returns(uint256){

        return purchasedProductWallet[_slug][_wallet];
    }
}