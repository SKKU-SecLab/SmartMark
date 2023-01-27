


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;


contract ERC20Detailed is IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }
}


pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.5.0;

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



pragma solidity ^0.5.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}


pragma solidity ^0.5.0;


contract EthChgCoinService {

  
	using SafeMath for uint;
    address payable public owner;

    ERC20 private erc20Instance;  

	struct NodeData {

		bool registered;
		bool authorized;

		int128 latitude;
		int128 longitude;

		string name;
		string phone;
		string location;
		string connector;
		string power;
	}

	struct ServiceData {
		bool allowed; // service allowed on the node
		uint rate;    // service rate in coins gwei per second
		uint maxTime; // max service time in seconds (0==unlimited)
		bool stopable;// return allowed
	}


	struct ServiceAction {
		uint started;
		uint finished;
		bool stopable;
		address node;
		address payer;
		uint serviceRate;
		uint16 serviceId;
		uint8 feedbackRate;
		string feedbackText;
	}

	uint16 public servicesCount = 0; 
	mapping (uint16 => string) public services;  // array of possible services

    mapping (address => mapping (bytes32 => string)) public nodeParameters;  //node => parametrHash => parameterValue

    mapping (address => NodeData) public registeredNodes;

    mapping (address => mapping (uint16 => ServiceData)) public nodeService;  //node => serviceId => ServiceData

	mapping (bytes32 => ServiceAction) public serviceActions; // paymentHash => ServiceAction
	
    uint public minCoinsBalance = 500 * 10 ** 18; // 500 CHG default
	struct Order {
		address user;
		uint amountGive;
		uint amountGet;
		uint expire;
	}
  
	mapping (bytes32 => Order) public sellOrders;
	mapping (bytes32 => Order) public buyOrders;
	
	mapping (address => uint) public ethBalance;
	mapping (address => uint) public coinBalance;


 	event NodeRegistered ( address indexed addr, int128 indexed latitude, int128 indexed longitude, string name, string location, string phone, string connector, string power );

	event DepositEther  ( address sender, uint EthValue, uint EthBalance );
	event WithdrawEther ( address sender, uint EthValue, uint EthBalance );
	
	event DepositCoins  ( address sender, uint CoinValue, uint CoinBalance );
	event WithdrawCoins ( address sender, uint CoinValue, uint CoinBalance );
 
	event SellOrder ( bytes32 indexed orderHash, uint amountGive, uint amountGet, uint expire, address seller );
	event BuyOrder  ( bytes32 indexed orderHash, uint amountGive, uint amountGet, uint expire, address buyer );
	
	event CancelSellOrder ( bytes32 indexed orderHash );
	event CancelBuyOrder  ( bytes32 indexed orderHash );

	event Sell ( bytes32 indexed orderHash, uint amountGive, uint amountGet, address seller );
	event Buy  ( bytes32 indexed orderHash, uint amountGive, uint amountGet, address buyer );
	
	event ServiceOn  ( address indexed nodeAddr, address indexed payer, bytes32 paymentHash, uint16 serviceId, uint chgAmount, uint serviceTime, uint finished);
	event ServiceOff ( address indexed nodeAddr, address indexed payer, bytes32 paymentHash, uint16 serviceId, uint chgAmount, uint serviceTime, uint finished);
	event Feedback   ( address indexed nodeAddr, address indexed payer, bytes32 paymentHash, uint16 serviceId, uint8 feedbackRate);

    uint64 public networkId; // this network id
    uint256 public minBridgeValue = 1 * 10**18; // min. bridge transfer value (1 CHG)
    uint256 public maxBridgeValue = 10000 * 10**18; // max. bridge transfer value (10000 CHG)

	struct Chain {
        bool active;
        string networkName;
	}

	mapping (uint64 => Chain) public chains; // networkId => Chain

    mapping (bytes32 => bool) public swaps;

    mapping (address => bool) public isValidator;

    event Swap(address indexed from, address indexed to, uint256 value, uint64 chainId, bytes32 chainHash);
    event Validated(bytes32 indexed txHash, address indexed account, uint256 value);


    constructor(address _tokenAddress, uint64 _networkId) public {
        owner = msg.sender;
        isValidator[owner] = true;

		erc20Instance = ERC20(_tokenAddress);	 
        networkId = _networkId;
		
		services[servicesCount] = 'Charg';
		servicesCount++;

		services[servicesCount] = 'Parking';
		servicesCount++;

		services[servicesCount] = 'Internet';
		servicesCount++;

        chains[1]       = Chain(true, 'Ethereum Mainnet');
        chains[56]      = Chain(true, 'Binance Smart Chain');
        chains[128]     = Chain(true, 'Heco Chain');
        chains[137]     = Chain(true, 'Polygon Network');
        chains[32659]   = Chain(true, 'Fusion Network');
        chains[42161]   = Chain(true, 'Arbitrum One Chain');
        chains[22177]   = Chain(true, 'Native Charg Network');
    }

	function() external payable {
		depositEther();
	}

    function setOwner(address payable newOwner) public {

        require(msg.sender == owner, "only owner");
        owner = newOwner;
    }
    
	function addService( string memory name ) public {

        require(msg.sender == owner, "only owner");
		services[servicesCount] = name;
		servicesCount++;
	}


    function registerNode( int128 latitude, int128 longitude, string memory name, string memory location, string memory phone, string memory connector, string memory power, uint chargRate, uint parkRate, uint inetRate) public {


        require ( !registeredNodes[msg.sender].registered || registeredNodes[msg.sender].authorized, "already registered" );

        require (erc20Instance.balanceOf(msg.sender) >= minCoinsBalance);

		if (!registeredNodes[msg.sender].registered) {
			registeredNodes[msg.sender].registered = true;
			registeredNodes[msg.sender].authorized = true;
		}

		registeredNodes[msg.sender].latitude = latitude;
		registeredNodes[msg.sender].longitude = longitude;

		registeredNodes[msg.sender].name = name;
		registeredNodes[msg.sender].location = location;
		registeredNodes[msg.sender].phone = phone;
		registeredNodes[msg.sender].connector = connector;
		registeredNodes[msg.sender].power = power;

        if (chargRate > 0) {
			nodeService[msg.sender][0].allowed = true;
			nodeService[msg.sender][0].stopable = true;
			nodeService[msg.sender][0].maxTime = 0;
			nodeService[msg.sender][0].rate = chargRate;
		}

        if (parkRate > 0) {
			nodeService[msg.sender][1].allowed = true;
			nodeService[msg.sender][1].stopable = true;
			nodeService[msg.sender][1].maxTime = 0;
			nodeService[msg.sender][1].rate = parkRate;
		}

        if (inetRate > 0) {
			nodeService[msg.sender][2].allowed = true;
			nodeService[msg.sender][2].stopable = true;
			nodeService[msg.sender][2].maxTime = 0;
			nodeService[msg.sender][2].rate = inetRate;
		}
		emit NodeRegistered( msg.sender, latitude, longitude, name, location, phone, connector, power );
	}


    function setNodeParameter(bytes32 parameterHash, string memory parameterValue) public {

        require (registeredNodes[msg.sender].registered, "not registered");
        nodeParameters[msg.sender][parameterHash] = parameterValue;
    }
	

	function setupNodeService( uint16 serviceId, bool allowed, bool stopable, uint rate, uint maxTime ) public {

        require (registeredNodes[msg.sender].registered, "not registered");
        require (serviceId < servicesCount);

        nodeService[msg.sender][serviceId].allowed = allowed;
        nodeService[msg.sender][serviceId].stopable = stopable;
        nodeService[msg.sender][serviceId].rate = rate;
        nodeService[msg.sender][serviceId].maxTime = maxTime;
	}


    function modifyNodeAuthorization (address addr, bool authorized) public {
        require(msg.sender == owner, "only owner");
        require (registeredNodes[msg.sender].registered, "not registered");
        registeredNodes[addr].authorized = authorized;
    }


    function setMinCoinsBalance(uint _newValue) public {

        require(msg.sender == owner, "only owner");
		minCoinsBalance = _newValue;
	}

	function setMinBridgeValue(uint256 _value) public {

        require(msg.sender == owner, "only owner");
        require (_value > 0, "wrong value");
        minBridgeValue = _value;
	}

	function setMaxBridgeValue(uint256 _value) public {

        require(msg.sender == owner, "only owner");
        require (_value > 0, "wrong value");
        maxBridgeValue = _value;
	}

	function addValidator( address _validator ) public {

        require(msg.sender == owner, "only owner");
        isValidator[_validator] = true;
	}

	function removeValidator( address _validator ) public {

        require(msg.sender == owner, "only owner");
        isValidator[_validator] = false;
	}

	function setChain(bool _active, uint64 _networkId, string memory _networkName) public {

        require(msg.sender == owner, "only owner");
		chains[_networkId].active = _active;
		chains[_networkId].networkName = _networkName;
	}

    function startSwapTo(address _to, uint256 _value, uint64 _networkId, bytes32 _chainHash) public {

        require(_networkId != networkId, "current network");
        require(chains[_networkId].active, "swap not allowed");
        require(_value >= minBridgeValue && _value <= maxBridgeValue, "wrong value");
        require(erc20Instance.transferFrom(msg.sender, address(this), _value), "increase allowance");
        emit Swap(msg.sender, _to, _value, _networkId, _chainHash);
    }

    function startSwap(uint256 _value, uint64 _networkId, bytes32 _chainHash) public {

        startSwapTo(msg.sender, _value, _networkId, _chainHash);
    }

    function validate(bytes32 txHash, address account, uint256 value, uint256 fee) public {

        require (isValidator[msg.sender], "only validators");
        require(!swaps[txHash], "already validated");
        require (erc20Instance.balanceOf(address(this)) >= value, "low bridge balance");
        erc20Instance.transfer(account, value);
        if (fee > 0) {
            coinBalance[msg.sender] = coinBalance[msg.sender].add(fee);
        }
        swaps[txHash] = true;
        emit Validated(txHash, account, value);
    }

	function depositEther() public payable {

		ethBalance[msg.sender] = ethBalance[msg.sender].add(msg.value);
		emit DepositEther(msg.sender, msg.value, ethBalance[msg.sender]);
	}

	function withdrawEther(uint amount) public {

		require(ethBalance[msg.sender] >= amount);
		ethBalance[msg.sender] = ethBalance[msg.sender].sub(amount);
		msg.sender.transfer(amount);
		emit WithdrawEther(msg.sender, amount, ethBalance[msg.sender]);
	}

	function depositCoins(uint amount) public {

		require(amount > 0 && erc20Instance.transferFrom(msg.sender, address(this), amount));
		coinBalance[msg.sender] = coinBalance[msg.sender].add(amount);
		emit DepositCoins(msg.sender, amount, coinBalance[msg.sender]);
	}

	function withdrawCoins(uint amount) public {

		require(amount > 0 && coinBalance[msg.sender] >= amount);
		coinBalance[msg.sender] = coinBalance[msg.sender].sub(amount);
		require(erc20Instance.transfer(msg.sender, amount));
		emit WithdrawCoins(msg.sender, amount, coinBalance[msg.sender]);
	}

	function buyOrder(uint amountGive, uint amountGet, uint expire) public {

		require(amountGive > 0 && amountGet > 0 && amountGive <= ethBalance[msg.sender]);
		bytes32 orderHash = sha256(abi.encodePacked(msg.sender, amountGive, amountGet, block.number));
		buyOrders[orderHash] = Order(msg.sender, amountGive, amountGet, expire);
		emit BuyOrder(orderHash, amountGive, amountGet, expire, msg.sender);
	}

	function sellOrder(uint amountGive, uint amountGet, uint expire) public {

		require(amountGive > 0 && amountGet > 0 && amountGive <= coinBalance[msg.sender]);
		bytes32 orderHash = sha256(abi.encodePacked(msg.sender, amountGive, amountGet, block.number));
		sellOrders[orderHash] = Order(msg.sender, amountGive, amountGet, expire);
		emit SellOrder(orderHash, amountGive, amountGet, expire, msg.sender);
	}

	function cancelBuyOrder(bytes32 orderHash) public {

		require( buyOrders[orderHash].expire > now && buyOrders[orderHash].user == msg.sender);
		buyOrders[orderHash].expire = 0; 
		emit CancelBuyOrder(orderHash);
	}


	function cancelSellOrder(bytes32 orderHash) public {

		require( sellOrders[orderHash].expire > now && sellOrders[orderHash].user == msg.sender);
		sellOrders[orderHash].expire = 0; 
		emit CancelSellOrder(orderHash);
	}

	function buy(bytes32 orderHash) public payable {

		require(msg.value > 0 && now <= sellOrders[orderHash].expire && 0 <= sellOrders[orderHash].amountGet.sub(msg.value));
		uint amountGet; //in CHG
		if (msg.value == sellOrders[orderHash].amountGet) {
			amountGet = sellOrders[orderHash].amountGive;
			require(0 <= coinBalance[sellOrders[orderHash].user].sub(amountGet));
			sellOrders[orderHash].amountGive = 0; 
			sellOrders[orderHash].amountGet = 0; 
			sellOrders[orderHash].expire = 0; 
		} else {
			amountGet = sellOrders[orderHash].amountGive.mul(msg.value).div(sellOrders[orderHash].amountGet);
			require(0 <= coinBalance[sellOrders[orderHash].user].sub(amountGet) && 0 <= sellOrders[orderHash].amountGive.sub(amountGet));
			sellOrders[orderHash].amountGive = sellOrders[orderHash].amountGive.sub(amountGet); 
			sellOrders[orderHash].amountGet = sellOrders[orderHash].amountGet.sub(msg.value); 
		}
		ethBalance[sellOrders[orderHash].user] = ethBalance[sellOrders[orderHash].user].add(msg.value);
		coinBalance[sellOrders[orderHash].user] = coinBalance[sellOrders[orderHash].user].sub(amountGet);
		require(erc20Instance.transfer(msg.sender, amountGet));
		emit Buy(orderHash, sellOrders[orderHash].amountGive, sellOrders[orderHash].amountGet, msg.sender);
	}


	function sell(bytes32 orderHash, uint amountGive) public {

        require(buyOrders[orderHash].user != msg.sender, "order owner");
		require(amountGive > 0 && now <= buyOrders[orderHash].expire && 0 <= buyOrders[orderHash].amountGet.sub(amountGive));
		uint amountGet;
		if (amountGive == buyOrders[orderHash].amountGet) {
			amountGet = buyOrders[orderHash].amountGive;
			require(0 <= ethBalance[buyOrders[orderHash].user].sub(amountGet));
			buyOrders[orderHash].amountGive = 0; 
			buyOrders[orderHash].amountGet = 0; 
			buyOrders[orderHash].expire = 0; 
		} else {
			amountGet = buyOrders[orderHash].amountGive.mul(amountGive).div(buyOrders[orderHash].amountGet);
			require(0 <= ethBalance[buyOrders[orderHash].user].sub(amountGet) && 0 <= buyOrders[orderHash].amountGive.sub(amountGet));
			buyOrders[orderHash].amountGive = buyOrders[orderHash].amountGive.sub(amountGet); 
			buyOrders[orderHash].amountGet = buyOrders[orderHash].amountGet.sub(amountGive); 
		}
		ethBalance[buyOrders[orderHash].user] = ethBalance[buyOrders[orderHash].user].sub(amountGet);
		require(erc20Instance.transferFrom(msg.sender, buyOrders[orderHash].user, amountGive));
		msg.sender.transfer(amountGet);
		emit Sell(orderHash, buyOrders[orderHash].amountGive, buyOrders[orderHash].amountGet, msg.sender);
	}

	function serviceOn(address nodeAddr, uint16 serviceId, uint time, bytes32 paymentHash, bytes32 orderHash) public payable returns (bytes32) {


		require ( registeredNodes[nodeAddr].authorized          // the node is registered and authorized
				&& (erc20Instance.balanceOf(nodeAddr) >= minCoinsBalance) // minimal balance of the node
				&& nodeService[nodeAddr][serviceId].allowed, 'not allowed');  // sevice is allowed on the node

		if (paymentHash == 0)
			paymentHash = keccak256(abi.encodePacked(msg.sender, now, serviceId));

		require (serviceActions[paymentHash].started == 0, 'payment served');

        uint chgAmount;
		if (msg.value > 0) {
			require(now <= sellOrders[orderHash].expire && 0 <= sellOrders[orderHash].amountGet.sub(msg.value), 'low order balance');
			if (msg.value == sellOrders[orderHash].amountGet) {
				chgAmount = sellOrders[orderHash].amountGive;
    			require(0 <= coinBalance[sellOrders[orderHash].user].sub(chgAmount), 'low seller balance');
				sellOrders[orderHash].amountGive = 0; 
				sellOrders[orderHash].amountGet = 0; 
				sellOrders[orderHash].expire = 0; 
			} else {
				chgAmount = sellOrders[orderHash].amountGive.mul(msg.value).div(sellOrders[orderHash].amountGet);
				require(0 <= coinBalance[sellOrders[orderHash].user].sub(chgAmount) && 0 <= sellOrders[orderHash].amountGive.sub(chgAmount), 'low seller/order balance');
				sellOrders[orderHash].amountGive = sellOrders[orderHash].amountGive.sub(chgAmount); 
				sellOrders[orderHash].amountGet = sellOrders[orderHash].amountGet.sub(msg.value); 
			}
			time = chgAmount.div(nodeService[nodeAddr][serviceId].rate);
			require ( time <= nodeService[nodeAddr][serviceId].maxTime || nodeService[nodeAddr][serviceId].maxTime == 0, 'wrong time');

			coinBalance[sellOrders[orderHash].user] = coinBalance[sellOrders[orderHash].user].sub(chgAmount);
			ethBalance[sellOrders[orderHash].user] = ethBalance[sellOrders[orderHash].user].add(msg.value);
            require(erc20Instance.transfer(nodeAddr, chgAmount), 'transfer error');
			
			emit Buy(orderHash, sellOrders[orderHash].amountGive, sellOrders[orderHash].amountGet, msg.sender);
		
		} else {
			require ( time <= nodeService[nodeAddr][serviceId].maxTime || nodeService[nodeAddr][serviceId].maxTime == 0);
			chgAmount = time.mul(nodeService[nodeAddr][serviceId].rate);
			require( chgAmount > 0 );
			require (erc20Instance.transferFrom(msg.sender, nodeAddr, chgAmount), 'transfer error');
		}
        serviceActions[paymentHash].node = nodeAddr; 
        serviceActions[paymentHash].payer = msg.sender; //will allow feedback for the sender
        serviceActions[paymentHash].serviceRate = nodeService[nodeAddr][serviceId].rate;
        serviceActions[paymentHash].serviceId = serviceId;
        serviceActions[paymentHash].started = now;
        serviceActions[paymentHash].finished = now + time;
        serviceActions[paymentHash].stopable = nodeService[nodeAddr][serviceId].stopable;
		emit ServiceOn (nodeAddr, msg.sender, paymentHash, serviceId, chgAmount, time, now + time);
		return paymentHash;
	}

	
	function serviceOff( bytes32 paymentHash ) public {


		require(serviceActions[paymentHash].started > 0 
                    && serviceActions[paymentHash].stopable
					&& now < serviceActions[paymentHash].finished 
					&& serviceActions[paymentHash].payer == msg.sender);

		uint time = serviceActions[paymentHash].finished.sub(now);
		uint chgAmount = time.mul(serviceActions[paymentHash].serviceRate);
        serviceActions[paymentHash].finished = now;

        coinBalance[serviceActions[paymentHash].node] = coinBalance[serviceActions[paymentHash].node].sub(chgAmount);
		require(erc20Instance.transfer(msg.sender, chgAmount));

		emit ServiceOff (serviceActions[paymentHash].node, msg.sender, paymentHash, serviceActions[paymentHash].serviceId, chgAmount, time, now);
	}

	function sendFeedback(bytes32 paymentHash, uint8 feedbackRate, string memory feedbackText) public {


		require(serviceActions[paymentHash].payer == msg.sender && serviceActions[paymentHash].feedbackRate == 0);

		serviceActions[paymentHash].feedbackRate = feedbackRate > 10 ? 10 : (feedbackRate < 1 ? 1 : feedbackRate);
		serviceActions[paymentHash].feedbackText = feedbackText;
		
		emit Feedback (serviceActions[paymentHash].node, msg.sender, paymentHash, serviceActions[paymentHash].serviceId, serviceActions[paymentHash].feedbackRate);
	}
}