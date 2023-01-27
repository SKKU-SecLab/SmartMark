
pragma solidity 0.8.7;


interface IERC721 {

	function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

}

contract ERC721LimitOrder {

	struct Order {
		uint128 priceInWeiEach;
		uint128 quantity;
	}

	address public coordinator;
	address public profitReceiver;
	uint256 public botFeeBips; // fee paid by bots

	mapping(address => mapping(address => Order)) public orders;
	mapping(address => uint256) balances;

	event Action(address indexed user, address indexed tokenAddress, uint256 priceInWeiEach, uint256 quantity, string action, uint256 optionalTokenId);

	modifier onlyCoordinator() {

		require(msg.sender == coordinator, 'not Coordinator');
		_;
	}

	constructor(address _profitReceiver , uint256 _botFeeBips) {
		coordinator = msg.sender;
		profitReceiver = _profitReceiver;
		require(_botFeeBips <= 500, 'fee too high');
		botFeeBips = _botFeeBips;
	}


	function placeOrder(address _tokenAddress, uint128 _quantity) external payable {

		Order memory order = orders[msg.sender][_tokenAddress];
		require(order.quantity == 0, 'You already have an order for this token. Please cancel the existing order before making a new one.');
		uint128 priceInWeiEach = uint128(msg.value) / _quantity;
		require(priceInWeiEach > 0, 'Zero wei offers not accepted.');

		orders[msg.sender][_tokenAddress].priceInWeiEach = priceInWeiEach;
		orders[msg.sender][_tokenAddress].quantity = _quantity;

		emit Action(msg.sender, _tokenAddress, priceInWeiEach, _quantity, 'order placed', 0);
	}

	function cancelOrder(address _tokenAddress) external {

		Order memory order = orders[msg.sender][_tokenAddress];
		uint256 amountToSendBack = order.priceInWeiEach * order.quantity;
		require(amountToSendBack != 0, 'You do not have an existing order for this token.');

		delete orders[msg.sender][_tokenAddress];

		sendValue(payable(msg.sender), amountToSendBack);

		emit Action(msg.sender, _tokenAddress, 0, 0, 'order cancelled', 0);
	}


	function fillOrder(address _user, address _tokenAddress, uint256 _tokenId, uint256 _expectedPriceInWeiEach, address _profitTo, bool _sendNow) public returns (uint256) {

		Order memory order = orders[_user][_tokenAddress];
		require(order.quantity > 0, 'user order DNE');
		require(order.priceInWeiEach >= _expectedPriceInWeiEach, 'user offer insufficient'); // protects bots from users frontrunning them

		orders[_user][_tokenAddress].quantity = order.quantity - 1; // reverts on underflow
		uint256 botFee = order.priceInWeiEach * botFeeBips / 10_000;
		balances[profitReceiver] += botFee;

		IERC721(_tokenAddress).safeTransferFrom(msg.sender, _user, _tokenId); // ERC721-compliant contracts revert on failure here

		uint256 botPayment = order.priceInWeiEach - botFee;
		if (_sendNow) {
			sendValue(payable(_profitTo), botPayment);
		} else {
			balances[_profitTo] += botPayment;
		}

		emit Action(_user, _tokenAddress, order.priceInWeiEach, order.quantity - 1, 'order filled', _tokenId);

		return botPayment;
	}

	function fillMultipleOrders(address[] memory _users, address _tokenAddress, uint256[] memory _tokenIds, uint256[] memory _expectedPriceInWeiEach, address _profitTo, bool _sendNow) external returns (uint256[] memory) {

		require(_users.length == _tokenIds.length && _tokenIds.length == _expectedPriceInWeiEach.length, 'array length mismatch');
		uint256[] memory output = new uint256[](_users.length);
		for (uint256 i = 0; i < _users.length; i++) {
			output[i] = fillOrder(_users[i], _tokenAddress, _tokenIds[i], _expectedPriceInWeiEach[i], _profitTo, _sendNow);
		}
		return output;
	}


	function changeCoordinator(address _newCoordinator) external onlyCoordinator {

		coordinator = _newCoordinator;
	}

	function changeProfitReceiver(address _newProfitReceiver) external onlyCoordinator {

		profitReceiver = _newProfitReceiver;
	}

	function changeBotFeeBips(uint256 _newBotFeeBips) external onlyCoordinator {

		require(_newBotFeeBips <= 500, 'fee cannot be greater than 5%');
		botFeeBips = _newBotFeeBips;
	}


	function sendValue(address payable recipient, uint256 amount) internal {

		require(address(this).balance >= amount, "Address: insufficient balance");
		(bool success, ) = recipient.call{ value: amount }("");
		require(success, "Address: unable to send value, recipient may have reverted");
	}

	function viewOrder(address _user, address _tokenAddress) external view returns (Order memory) {

		return orders[_user][_tokenAddress];
	}

	function viewOrders(address[] memory _users, address[] memory _tokenAddresses) external view returns (Order[] memory) {

		Order[] memory output = new Order[](_users.length);
		for (uint256 i = 0; i < _users.length; i++) output[i] = orders[_users[i]][_tokenAddresses[i]];
		return output;
	}

}