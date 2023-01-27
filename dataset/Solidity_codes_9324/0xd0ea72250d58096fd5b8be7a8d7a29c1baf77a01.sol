pragma solidity >=0.5.0;


interface IERC1155 {


  event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _amount);
  event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _amounts);
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
  event URI(string _amount, uint256 indexed _id);


  function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes calldata _data) external;

  function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _amounts, bytes calldata _data) external;

  function balanceOf(address _owner, uint256 _id) external view returns (uint256);

  function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory);

  function setApprovalForAll(address _operator, bool _approved) external;

  function isApprovedForAll(address _owner, address _operator) external view returns (bool isOperator);

  
}pragma solidity =0.5.16;


library SafeMath {

    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
    
    function div(uint a, uint b) internal pure returns (uint z) {

        require(b > 0);
        return a / b;
    }
}pragma solidity >=0.5.0;

interface IERC20 {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

}pragma solidity =0.5.16;


contract MonetExchange {

    using SafeMath for uint256;

    address public tokenCard;
    address public tokenMonet;
    
    bytes4 private constant ERC1155_RECEIVED_VALUE = 0xf23a6e61;
    bytes4 private constant ERC1155_BATCH_RECEIVED_VALUE = 0xbc197c81;

    uint256 public fee = 2;  // 2%
    address public feeTo;
    address public feeToSetter;
    
    uint256 private _nextId;
    mapping(uint256 => Order) internal _orders;

    struct Order {
        uint256 id;
        uint256 num;
        uint256 price;
        address owner;
        uint256 status;
        uint256 direction;
    }

    constructor(address card, address monet) public {
        tokenCard = card;
        tokenMonet = monet;
        feeTo = msg.sender;
        feeToSetter = msg.sender;
    }


    function _transferFromCards(address _from, address _to, uint256 _id, uint256 _value) private {

        IERC1155(tokenCard).safeTransferFrom(_from, _to, _id, _value, bytes(''));
    }

    function _transferFromMonet(address _from, address _to, uint256 _value) private {

        require(IERC20(tokenMonet).transferFrom(_from, _to, _value), 'transferFrom fail');
    }

    function _transfer(address _to, uint256 _value) private {

        require(IERC20(tokenMonet).transfer(_to, _value), 'transfer fail');
    }

    function trade(uint256 orderId, uint256 num) external {

        Order storage order = _orders[orderId];
        require(order.id != 0 && order.status == 0, 'order is empty');
        require(order.owner != msg.sender, 'order owner is caller');
        require(order.num >= num, 'order num is less');
        if (order.direction == 0) {
            uint256 feeAmount = num.mul(order.price).mul(fee).div(100);
            if (feeAmount > 0 && feeTo != address(0)) _transfer(feeTo, feeAmount);
            _transfer(msg.sender, num.mul(order.price).sub(feeAmount));
            _transferFromCards(msg.sender, order.owner, order.id, num);
        } else {
            uint256 feeAmount = num.mul(order.price).mul(fee).div(100);
            if (feeAmount > 0 && feeTo != address(0)) _transferFromMonet(msg.sender, feeTo, feeAmount);
            _transferFromCards(address(this), msg.sender, order.id, num);
            _transferFromMonet(msg.sender, order.owner, num.mul(order.price).sub(feeAmount));
        }
        order.num = order.num.sub(num);
        if (order.num == 0) {
            order.status = 1;
        }
        emit Trade(msg.sender, orderId, num);
    }

    function revoke(uint256 orderId) external {

        Order storage order = _orders[orderId];
        require(order.id != 0 && order.status == 0, 'order is empty');
        require(order.owner == msg.sender, 'caller is not the order owner');
        if (order.direction == 0) {
            _transfer(msg.sender, order.num.mul(order.price));
        } else {
            _transferFromCards(address(this), msg.sender, order.id, order.num);
        }
        order.status = 2;
        emit Revoke(msg.sender, orderId);
    }

    function placeOrder(uint256 id, uint256 num, uint256 price, uint256 direction) external generateId {

        require(_nextId > 0, 'order id generate fail');
        require(direction < 2, 'direction is error');
        if (direction == 0) {
            _transferFromMonet(msg.sender, address(this), num.mul(price));
        } else {
            _transferFromCards(msg.sender, address(this), id, num);
        }
        _orders[_nextId] = Order(id, num, price, msg.sender, 0, direction);
        emit PlaceOrder(msg.sender, _nextId, id, num, price, direction);
    }

    function setFeeTo(address _feeTo) external {

        require(msg.sender == feeToSetter, 'FORBIDDEN');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {

        require(msg.sender == feeToSetter, 'FORBIDDEN');
        feeToSetter = _feeToSetter;
    }
    
    function onERC1155Received(address, address, uint256, uint256, bytes calldata) external pure returns(bytes4){

        return ERC1155_RECEIVED_VALUE;
    }

    function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata) external pure returns(bytes4){

        return ERC1155_BATCH_RECEIVED_VALUE;
    }

    modifier generateId() {

        _nextId = _nextId.add(1);

        _;
    }

    event Trade(address indexed sender, uint256 indexed orderId, uint256 num);
    event Revoke(address indexed sender, uint256 indexed orderId);
    event PlaceOrder(address indexed sender, uint256 orderId, uint256 id, uint256 num, uint256 price, uint256 direction);
}