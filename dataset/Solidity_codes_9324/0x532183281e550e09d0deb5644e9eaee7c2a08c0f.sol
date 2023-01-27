
pragma solidity 0.4.24;


contract Ownable {

    address public owner;


    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipRenounced(owner);
        owner = address(0);
    }

    function transferOwnership(address _newOwner) public onlyOwner {

        _transferOwnership(_newOwner);
    }

    function _transferOwnership(address _newOwner) internal {

        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}


contract ERC721Receiver {

    bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;

    function onERC721Received(
        address _from,
        uint256 _tokenId,
        bytes _data
    )
    public
    returns(bytes4);

}


contract ERC721Basic {

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _tokenId
    );
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 _tokenId
    );
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    function balanceOf(address _owner) public view returns (uint256 _balance);

    function ownerOf(uint256 _tokenId) public view returns (address _owner);

    function exists(uint256 _tokenId) public view returns (bool _exists);


    function approve(address _to, uint256 _tokenId) public;

    function getApproved(uint256 _tokenId)
    public view returns (address _operator);


    function setApprovalForAll(address _operator, bool _approved) public;

    function isApprovedForAll(address _owner, address _operator)
    public view returns (bool);


    function transferFrom(address _from, address _to, uint256 _tokenId) public;

    function safeTransferFrom(address _from, address _to, uint256 _tokenId)
    public;


    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes _data
    )
    public;

}


contract BBMarketplace is Ownable, ERC721Receiver {

    address public owner;
    address public wallet;
    uint public fee_percentage;
    mapping (address => bool) public tokens;
    mapping(address => bool) public managers;

    mapping(address => mapping(uint => uint)) public priceList;
    mapping(address => mapping(uint => address)) public holderList;

    event Stored(uint indexed id, uint price, address seller, address token);
    event Cancelled(uint indexed id, address seller, address token);
    event Sold(uint indexed id, uint price, address seller, address buyer, address token);

    event TokenChanged(address token, bool enabled);
    event WalletChanged(address old_wallet, address new_wallet);
    event FeeChanged(uint old_fee, uint new_fee);

    modifier onlyOwnerOrManager() {

        require(msg.sender == owner || managers[msg.sender]);
        _;
    }

    constructor(address _BBArtefactAddress, address _BBPackAddress, address _wallet, address _manager, uint _fee) public {
        owner = msg.sender;
        tokens[_BBArtefactAddress] = true;
        tokens[_BBPackAddress] = true;
        wallet = _wallet;
        fee_percentage = _fee;
        managers[_manager] = true;
    }

    function setToken(address _token, bool enabled) public onlyOwnerOrManager {

        tokens[_token] = enabled;
        emit TokenChanged(_token, enabled);
    }

    function setWallet(address _wallet) public onlyOwnerOrManager {

        address old = wallet;
        wallet = _wallet;
        emit WalletChanged(old, wallet);
    }

    function changeFeePercentage(uint _percentage) public onlyOwnerOrManager {

        uint old = fee_percentage;
        fee_percentage = _percentage;
        emit FeeChanged(old, fee_percentage);
    }

    function onERC721Received(address _from, uint _tokenId, bytes _data) public returns(bytes4) {

        require(tokens[msg.sender]);

        uint _price = uint(convertBytesToBytes32(_data));

        require(_price > 0);

        priceList[msg.sender][_tokenId] = _price;
        holderList[msg.sender][_tokenId] = _from;

        emit Stored(_tokenId, _price, _from, msg.sender);

        return ERC721Receiver.ERC721_RECEIVED;
    }

    function cancel(uint _id, address _token) public returns (bool) {

        require(holderList[_token][_id] == msg.sender || managers[msg.sender]);

        delete holderList[_token][_id];
        delete priceList[_token][_id];

        ERC721Basic(_token).safeTransferFrom(this, msg.sender, _id);

        emit Cancelled(_id, msg.sender, _token);

        return true;
    }

    function buy(uint _id, address _token) public payable returns (bool) {

        require(priceList[_token][_id] == msg.value);

        address oldHolder = holderList[_token][_id];
        uint price = priceList[_token][_id];

        uint toWallet = price / 100 * fee_percentage;
        uint toHolder = price - toWallet;

        delete holderList[_token][_id];
        delete priceList[_token][_id];

        ERC721Basic(_token).safeTransferFrom(this, msg.sender, _id);
        wallet.transfer(toWallet);
        oldHolder.transfer(toHolder);

        emit Sold(_id, price, oldHolder, msg.sender, _token);

        return true;
    }

    function getPrice(uint _id, address _token) public view returns(uint) {

        return priceList[_token][_id];
    }

    function convertBytesToBytes32(bytes inBytes) internal returns (bytes32 out) {

        if (inBytes.length == 0) {
            return 0x0;
        }

        assembly {
            out := mload(add(inBytes, 32))
        }
    }

    function setManager(address _manager, bool enable) public onlyOwner {

        managers[_manager] = enable;
    }
}