
pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

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

}// MIT

pragma solidity ^0.8.2;


interface INFTree is IERC721{


    function mintNFTree(address _recipient, string memory _tokenURI, uint256 _carbonOffset, string memory _collection) external;

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

pragma solidity ^0.8.2;




contract NFTreeFactory is Ownable {


    INFTree nftree;
    address treasury;
    uint256[] levels;
    string[] coins;
    bool public isLocked;

    mapping(uint256 => Level) levelMap;
    mapping(string => Coin) coinMap;

    struct Level {
        bool isValid;
        uint256 cost;
        uint256 carbonValue;
        uint256 numMinted;
        string tokenURI;
    }

    struct Coin {
        bool isValid;
        IERC20 coinContract;
        uint256 decimal;
    }

    constructor(address _nftreeAddress, address _treasuryAddress)
    {   
        nftree = INFTree(_nftreeAddress);
        treasury = _treasuryAddress;
        isLocked = false;
    }

    function toggleLock() external onlyOwner {

        isLocked = !isLocked;
    }

    function setNFTreeContract(address _nftreeAddress) external {

        nftree = INFTree(_nftreeAddress);
    }

    function getNFTreeContract() external view returns(INFTree) {

        return nftree;
    }

    function setTreasury(address _address) external onlyOwner {

        treasury = _address;
    }
    
    function getTreasury() external view onlyOwner returns(address) {

        return treasury;
    }

    function addLevel(uint256 _level, uint256 _cost, string memory _tokenURI) external onlyOwner {

        if (!levelMap[_level].isValid) {
            levels.push(_level);
        }
            
        levelMap[_level] = Level(true, _cost, _level, 0, _tokenURI);
    }

    function removeLevel(uint256 _level) external onlyOwner {

        require(levelMap[_level].isValid, 'Not a valid level.');

        uint256 index;

        for (uint256 i = 0; i < levels.length; i++) {
            if (levels[i] == _level){
                index = i;
            }
        }

        levels[index] = levels[levels.length - 1];

        levels.pop();
        delete levelMap[_level];
    }

    function getLevel(uint256 _level) external view returns(uint256, uint256, uint256, string memory) {

        require(levelMap[_level].isValid, 'Not a valid level');
        return (levelMap[_level].carbonValue, levelMap[_level].cost, levelMap[_level].numMinted, levelMap[_level].tokenURI);
    }

    function getValidLevels() external view returns(uint256[] memory) {

        return sort_array(levels);
    }

    function addCoin(string memory _coin, address _address, uint256 _decimal) external onlyOwner {

        require(!coinMap[_coin].isValid, 'Already a valid coin.');

        coins.push(_coin);
        coinMap[_coin] = Coin(true, IERC20(_address), _decimal);
    }

    function removeCoin(string memory _coin) external onlyOwner {

        require(coinMap[_coin].isValid, 'Not a valid coin.');

        uint256 index;

        for (uint256 i = 0; i < coins.length; i++) {
            if (keccak256(abi.encodePacked(coins[i])) == keccak256(abi.encodePacked(_coin))) {
                index = i;
            }
        }

        coins[index] = coins[coins.length - 1];

        coins.pop();
        delete coinMap[_coin];
    }

    function getValidCoins() external view returns(string[] memory) {

        return coins;
    }

    function mintNFTree(uint256 _tonnes, uint256 _amount, string memory _coin) external {

        require(!isLocked, 'Minting is locked.');
        require(msg.sender != address(0) && msg.sender != address(this), 'Sending from zero address.'); 
        require(levelMap[_tonnes].isValid, 'Not a valid level.');
        require(coinMap[_coin].isValid, 'Not a valid coin.');
        require(_amount >= levelMap[_tonnes].cost, 'Not enough value.');
        require(coinMap[_coin].coinContract.balanceOf(msg.sender) >= _amount, 'Not enough balance.');
        require(coinMap[_coin].coinContract.allowance(msg.sender, address(this)) >= _amount, 'Not enough allowance.');
        
        coinMap[_coin].coinContract.transferFrom(msg.sender, treasury, _amount * (10**coinMap[_coin].decimal));
        nftree.mintNFTree(msg.sender, levelMap[_tonnes].tokenURI, _tonnes, "Genesis");
        
        levelMap[_tonnes].numMinted += 1;
    }

    function sort_array(uint256[] memory _arr) private pure returns (uint256[] memory) {

        uint256 l = _arr.length;
        for(uint i = 0; i < l; i++) {
            for(uint j = i+1; j < l ;j++) {
                if(_arr[i] > _arr[j]) {
                    uint256 temp = _arr[i];
                    _arr[i] = _arr[j];
                    _arr[j] = temp;
                }
            }
        }
        return _arr;
    }
}