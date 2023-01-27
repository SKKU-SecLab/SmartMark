
pragma solidity ^0.4.24;


contract ERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() public view returns (uint256);

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    function allowance(address owner, address spender) public view returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

}


library SafeMath {


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        assert(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


contract StandardToken is ERC20 {

    using SafeMath for uint256;

    uint256 internal _totalSupply;
    mapping(address => uint256) internal _balanceOf;
    mapping (address => mapping (address => uint256)) internal _allowance;

    modifier onlyValidAddress(address addr) {

        require(addr != address(0), "Address cannot be zero");
        _;
    }

    modifier onlySufficientBalance(address from, uint256 value) {

        require(value <= _balanceOf[from], "Insufficient balance");
        _;
    }

    modifier onlySufficientAllowance(address owner, address spender, uint256 value) {

        require(value <= _allowance[owner][spender], "Insufficient allowance");
        _;
    }

    function transfer(address to, uint256 value)
        public
        onlyValidAddress(to)
        onlySufficientBalance(msg.sender, value)
        returns (bool)
    {

        _balanceOf[msg.sender] = _balanceOf[msg.sender].sub(value);
        _balanceOf[to] = _balanceOf[to].add(value);

        emit Transfer(msg.sender, to, value);

        return true;
    }

    function transferFrom(address from, address to, uint256 value)
        public
        onlyValidAddress(to)
        onlySufficientBalance(from, value)
        onlySufficientAllowance(from, msg.sender, value)
        returns (bool)
    {

        _balanceOf[from] = _balanceOf[from].sub(value);
        _balanceOf[to] = _balanceOf[to].add(value);
        _allowance[from][msg.sender] = _allowance[from][msg.sender].sub(value);

        emit Transfer(from, to, value);

        return true;
    }

    function approve(address spender, uint256 value)
        public
        onlyValidAddress(spender)
        returns (bool)
    {

        _allowance[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        onlyValidAddress(spender)
        returns (bool)
    {

        _allowance[msg.sender][spender] = _allowance[msg.sender][spender].add(addedValue);

        emit Approval(msg.sender, spender, _allowance[msg.sender][spender]);

        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        onlyValidAddress(spender)
        onlySufficientAllowance(msg.sender, spender, subtractedValue)
        returns (bool)
    {

        _allowance[msg.sender][spender] = _allowance[msg.sender][spender].sub(subtractedValue);

        emit Approval(msg.sender, spender, _allowance[msg.sender][spender]);

        return true;
    }

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {

        return _balanceOf[owner];
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowance[owner][spender];
    }
}


contract Ownable {

    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {

        require(msg.sender == owner, "Can only be called by the owner");
        _;
    }

    modifier onlyValidAddress(address addr) {

        require(addr != address(0), "Address cannot be zero");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner)
        public
        onlyOwner
        onlyValidAddress(newOwner)
    {

        emit OwnershipTransferred(owner, newOwner);

        owner = newOwner;
    }
}


contract MintableToken is StandardToken, Ownable {

    bool public mintingFinished;
    uint256 public cap;

    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    modifier onlyMinting() {

        require(!mintingFinished, "Minting is already finished");
        _;
    }

    modifier onlyNotExceedingCap(uint256 amount) {

        require(_totalSupply.add(amount) <= cap, "Total supply must not exceed cap");
        _;
    }

    constructor(uint256 _cap) public {
        cap = _cap;
    }

    function mint(address to, uint256 amount)
        public
        onlyOwner
        onlyMinting
        onlyValidAddress(to)
        onlyNotExceedingCap(amount)
        returns (bool)
    {

        mintImpl(to, amount);

        return true;
    }

    function mintMany(address[] addresses, uint256[] amounts)
        public
        onlyOwner
        onlyMinting
        onlyNotExceedingCap(sum(amounts))
        returns (bool)
    {

        require(
            addresses.length == amounts.length,
            "Addresses array must be the same size as amounts array"
        );

        for (uint256 i = 0; i < addresses.length; i++) {
            require(addresses[i] != address(0), "Address cannot be zero");
            mintImpl(addresses[i], amounts[i]);
        }

        return true;
    }

    function finishMinting()
        public
        onlyOwner
        onlyMinting
        returns (bool)
    {

        mintingFinished = true;

        emit MintFinished();

        return true;
    }

    function mintImpl(address to, uint256 amount) private {

        _totalSupply = _totalSupply.add(amount);
        _balanceOf[to] = _balanceOf[to].add(amount);

        emit Mint(to, amount);
        emit Transfer(address(0), to, amount);
    }

    function sum(uint256[] arr) private pure returns (uint256) {

        uint256 aggr = 0;
        for (uint256 i = 0; i < arr.length; i++) {
            aggr = aggr.add(arr[i]);
        }
        return aggr;
    }
}


contract PhotonTestToken is MintableToken {

    string public name = "PhotonTestToken";
    string public symbol = "PHT";
    uint256 public decimals = 18;
    uint256 public cap = 120 * 10**6 * 10**decimals;

    constructor() public MintableToken(cap) {}
}pragma solidity ^0.4.24;



contract PhotochainMarketplace is Ownable {

    event OfferAdded(
        bytes32 indexed id,
        address indexed seller,
        uint8 licenseType,
        bytes32 photoDigest,
        uint256 price
    );

    event OfferAccepted(bytes32 indexed id, address indexed licensee);

    event OfferPriceChanged(bytes32 indexed id, uint256 oldPrice, uint256 newPrice);

    event OfferCancelled(bytes32 indexed id);

    struct Offer {
        address seller;
        uint8 licenseType;
        bool isCancelled;
        bytes32 photoDigest;
        uint256 price;
    }

    ERC20 public token;

    mapping(bytes32 => Offer) public offers;

    mapping(address => bytes32[]) public offersBySeller;

    mapping(address => bytes32[]) public offersByLicensee;

    modifier onlyValidAddress(address _addr) {

        require(_addr != address(0), "Invalid address");
        _;
    }

    modifier onlyActiveOffer(bytes32 _id) {

        require(offers[_id].seller != address(0), "Offer does not exists");
        require(!offers[_id].isCancelled, "Offer is cancelled");
        _;
    }

    constructor(ERC20 _token) public onlyValidAddress(address(_token)) {
        token = _token;
    }

    function setToken(ERC20 _token)
        external
        onlyOwner
        onlyValidAddress(address(_token))
    {

        token = _token;
    }

    function addOffer(
        address _seller,
        uint8 _licenseType,
        bytes32 _photoDigest,
        uint256 _price
    )
        external
        onlyOwner
        onlyValidAddress(_seller)
    {

        bytes32 _id = keccak256(
            abi.encodePacked(
                _seller,
                _licenseType,
                _photoDigest
            )
        );
        require(offers[_id].seller == address(0), "Offer already exists");

        offersBySeller[_seller].push(_id);
        offers[_id] = Offer({
            seller: _seller,
            licenseType: _licenseType,
            isCancelled: false,
            photoDigest: _photoDigest,
            price: _price
        });

        emit OfferAdded(_id, _seller, _licenseType, _photoDigest, _price);
    }

    function acceptOffer(bytes32 _id, address _licensee)
        external
        onlyOwner
        onlyValidAddress(_licensee)
        onlyActiveOffer(_id)
    {

        Offer storage offer = offers[_id];

        if (offer.price > 0) {
            require(
                token.transferFrom(_licensee, address(this), offer.price),
                "Token transfer to contract failed"
            );

            require(
                token.transfer(offer.seller, offer.price),
                "Token transfer to seller failed"
            );
        }

        offersByLicensee[_licensee].push(_id);

        emit OfferAccepted(_id, _licensee);
    }

    function setOfferPrice(bytes32 _id, uint256 _price)
        external
        onlyOwner
        onlyActiveOffer(_id)
    {

        uint256 oldPrice = offers[_id].price;

        offers[_id].price = _price;

        emit OfferPriceChanged(_id, oldPrice, _price);
    }

    function cancelOffer(bytes32 _id)
        external
        onlyOwner
        onlyActiveOffer(_id)
    {

        offers[_id].isCancelled = true;

        emit OfferCancelled(_id);
    }

    function getOffers(address _seller) external view returns (bytes32[] memory) {

        return offersBySeller[_seller];
    }

    function getOfferById(bytes32 _id)
        external
        view
        returns (
            address seller,
            uint8 licenseType,
            bool isCancelled,
            bytes32 photoDigest,
            uint256 price
        )
    {

        Offer storage offer = offers[_id];

        seller = offer.seller;
        licenseType = offer.licenseType;
        isCancelled = offer.isCancelled;
        photoDigest = offer.photoDigest;
        price = offer.price;
    }

    function getLicenses(address _licensee)
        external
        view
        returns (bytes32[] memory)
    {

        return offersByLicensee[_licensee];
    }
}
pragma solidity >=0.4.22 <0.6.0;

contract Migrations {

  address public owner;
  uint256 public last_completed_migration;

  modifier restricted() {

    if (msg.sender == owner) _;
  }

  constructor() public {
    owner = msg.sender;
  }

  function setCompleted(uint completed) public restricted {

    last_completed_migration = completed;
  }

  function upgrade(address new_address) public restricted {

    Migrations upgraded = Migrations(new_address);
    upgraded.setCompleted(last_completed_migration);
  }
}
