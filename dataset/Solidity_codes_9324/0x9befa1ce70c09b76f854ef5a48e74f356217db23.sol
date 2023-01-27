
pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;
    bool private _initializing;
    modifier initializer() {
        require(
            _initializing || !_initialized,
            "Initializable: contract is already initialized"
        );

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

    function __Context_init_unchained() internal initializer {}

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}

library SafeMathUpgradeable {

    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
interface METAPACK721 {

    function setServiceValue(uint256 _serviceValue, uint256 sellerfee) external;


    function addTokenType(string[] memory _type, address[] memory tokenAddress)
        external;

}
interface METAPACK1155 {

    function setServiceValue(uint256 _serviceValue, uint256 sellerfee) external;


    function addTokenType(string[] memory _type, address[] memory tokenAddress)
        external;

}
contract METAPACKTrade is Initializable, OwnableUpgradeable {

    event SetPack(string indexed packName, uint256 indexed pPrice);
    using SafeMathUpgradeable for uint256;

    function initialize() public initializer {

        __Ownable_init();
        serviceValue = 2500000000000000000;
        sellervalue = 2500000000000000000;
        tokenhold = 50000000000000000000;
        mccTokenAddress = 0xcf50941a6875E6BCaB3859DB392013C543cdaDe7;
    }
    struct packInfo {
        string packName;
        uint256 packPrice; 
        uint256 multiples;
    }
    mapping(string => address) private tokentype;
    mapping(address => uint256) public aPack;
    uint256 private serviceValue;
    uint256 private sellervalue;
    packInfo[] public _pName;
    premiumpackInfo[] public _premiumpName;
    mapping(address => uint256) public aPremiumPack;
    uint256 private tokenhold;
    struct premiumpackInfo {
        string packName;
        uint256 packPrice;
        uint256 multiples;
    }
    address public mccTokenAddress;
    function getServiceFee() public view returns (uint256, uint256) {

        return (serviceValue, sellervalue);
    }
    function setServiceValue(
        uint256 _serviceValue,
        uint256 sellerfee,
        address[] memory _conAddress
    ) public onlyOwner {

        serviceValue = _serviceValue;
        sellervalue = sellerfee;
        METAPACK721(_conAddress[0]).setServiceValue(_serviceValue, sellerfee);
        METAPACK1155(_conAddress[1]).setServiceValue(_serviceValue, sellerfee);
    }
    function getTokenAddress(string memory _type)
        public
        view
        returns (address)
    {

        return tokentype[_type];
    }

    function addTokenType(
        string[] memory _type,
        address[] memory tokenAddress,
        address[] memory _conAddress
    ) public onlyOwner {

        require(
            _type.length == tokenAddress.length,
            "Not equal for type and tokenAddress"
        );
        for (uint256 i = 0; i < _type.length; i++) {
            tokentype[_type[i]] = tokenAddress[i];
        }
        METAPACK721(_conAddress[0]).addTokenType(_type, tokenAddress);
        METAPACK1155(_conAddress[1]).addTokenType(_type, tokenAddress);
    }
    function addMccToken(address _conAddress) public onlyOwner{

        mccTokenAddress = _conAddress;
    }
    function addNewPreminumPack(string memory _pname, uint256 _pfee, uint _multiples)
        public
        onlyOwner
    {

        premiumpackInfo memory _premiumpackInfo;
        _premiumpackInfo.packName = _pname;
        _premiumpackInfo.packPrice = _pfee;
        _premiumpackInfo.multiples = _multiples;
        _premiumpName.push(_premiumpackInfo);
        emit SetPack(
            _premiumpName[_premiumpName.length - 1].packName,
            _premiumpName[_premiumpName.length - 1].packPrice
        );
    }

    function addNewPack(string memory _pname, uint256 _pfee, uint _multiples) public onlyOwner {

        packInfo memory _packInfo;
        _packInfo.packName = _pname;
        _packInfo.packPrice = _pfee;
        _packInfo.multiples = _multiples;
        _pName.push(_packInfo);
        emit SetPack(
            _pName[_pName.length - 1].packName,
            _pName[_pName.length - 1].packPrice
        );
    }

    function getPacks()
        public
        view
        returns (packInfo[] memory, premiumpackInfo[] memory)
    {

        return (_pName, _premiumpName);
    }

    function editPremiumPackFee(
        string memory _pname,
        uint256 _pfee,
        uint256 _pid,
        uint _multiples
        
    ) public onlyOwner {

        _premiumpName[_pid].packName = _pname;
        _premiumpName[_pid].packPrice = _pfee;
        _premiumpName[_pid].multiples = _multiples;
        emit SetPack(_premiumpName[_pid].packName, _premiumpName[_pid].packPrice);
    }

    function editPackFee(
        string memory _pname,
        uint256 _pfee,
        uint256 _pid,
        uint _multiples
    ) public onlyOwner {

        _pName[_pid].packName = _pname;
        _pName[_pid].packPrice = _pfee;
        _pName[_pid].multiples = _multiples;
        emit SetPack(_pName[_pid].packName, _pName[_pid].packPrice);
    }

    function buyPack(
        uint256 _pid,
        uint256 _nPack,
        string memory _type
    ) public payable {

        if (
            keccak256(abi.encodePacked((_type))) ==
            keccak256(abi.encodePacked(("Premium")))
        ) {
            require(IERC20Upgradeable(mccTokenAddress).balanceOf(msg.sender) >= tokenhold, "Not Eligible to Mint Premium Pack");
            require(
                _premiumpName[_pid].packPrice.mul(_nPack) == msg.value,
                "Invalid Pack Price"
            );
            aPremiumPack[msg.sender] = aPremiumPack[msg.sender].add(_nPack.mul(_premiumpName[_pid].multiples));
            payable(owner()).transfer(msg.value);
        } else {
            require(
                _pName[_pid].packPrice.mul(_nPack) == msg.value,
                "Invalid Pack Price"
            );
            aPack[msg.sender] = aPack[msg.sender].add(_nPack.mul(_pName[_pid].multiples));
            payable(owner()).transfer(msg.value);
        }
    }

    function availablePack(address from) public view returns (uint256, uint256) {

        return (aPack[from],aPremiumPack[from]);
    }
    function getHoldTokenValue() public view returns (uint256) {

        return tokenhold;
    }
    function editHoldTokenValue(uint256 value) public onlyOwner {

        tokenhold = value;   
    }

    function decreasePack(address from,string memory _type) external {

         if (
            keccak256(abi.encodePacked((_type))) ==
            keccak256(abi.encodePacked(("Premium")))
        ){
            aPremiumPack[from] = aPremiumPack[from].sub(1);
        }
        else{
            aPack[from] = aPack[from].sub(1);
        }
    }
}