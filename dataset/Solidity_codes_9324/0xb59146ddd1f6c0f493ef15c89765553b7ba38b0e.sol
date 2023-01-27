
pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// GPL-3.0



pragma solidity ^0.6.8;


contract Dingo is ERC20, Ownable {
    constructor() ERC20("Dingo", "Dingo") public {
      
    }

    function mint(address to, uint256 amount) public onlyOwner  {
        _mint(to, amount);
    }

    function burn(uint256 _value) public {
        _burn(msg.sender, _value);
    }
}// MIT
pragma solidity ^0.6.0;

library SafeMathChainlink {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath: subtraction overflow");
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
    require(b > 0, "SafeMath: division by zero");
    uint256 c = a / b;

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0, "SafeMath: modulo by zero");
    return a % b;
  }
}// MIT
pragma solidity ^0.6.0;

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);
  function approve(address spender, uint256 value) external returns (bool success);
  function balanceOf(address owner) external view returns (uint256 balance);
  function decimals() external view returns (uint8 decimalPlaces);
  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);
  function increaseApproval(address spender, uint256 subtractedValue) external;
  function name() external view returns (string memory tokenName);
  function symbol() external view returns (string memory tokenSymbol);
  function totalSupply() external view returns (uint256 totalTokensIssued);
  function transfer(address to, uint256 value) external returns (bool success);
  function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool success);
  function transferFrom(address from, address to, uint256 value) external returns (bool success);
}// MIT
pragma solidity ^0.6.0;

contract VRFRequestIDBase {

  function makeVRFInputSeed(bytes32 _keyHash, uint256 _userSeed,
    address _requester, uint256 _nonce)
    internal pure returns (uint256)
  {
    return  uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

  function makeRequestId(
    bytes32 _keyHash, uint256 _vRFInputSeed) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}// MIT
pragma solidity ^0.6.0;




abstract contract VRFConsumerBase is VRFRequestIDBase {

  using SafeMathChainlink for uint256;

  function fulfillRandomness(bytes32 requestId, uint256 randomness)
    internal virtual;

  uint256 constant private USER_SEED_PLACEHOLDER = 0;

  function requestRandomness(bytes32 _keyHash, uint256 _fee)
    internal returns (bytes32 requestId)
  {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, USER_SEED_PLACEHOLDER));
    uint256 vRFSeed  = makeVRFInputSeed(_keyHash, USER_SEED_PLACEHOLDER, address(this), nonces[_keyHash]);
    nonces[_keyHash] = nonces[_keyHash].add(1);
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface immutable internal LINK;
  address immutable private vrfCoordinator;

  mapping(bytes32 /* keyHash */ => uint256 /* nonce */) private nonces;

  constructor(address _vrfCoordinator, address _link) public {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
  }

  function rawFulfillRandomness(bytes32 requestId, uint256 randomness) external {
    require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
    fulfillRandomness(requestId, randomness);
  }
}// GPL-3.0
pragma experimental ABIEncoderV2;

pragma solidity ^0.6.8;

contract Lotto is VRFConsumerBase {
	address constant ETHER = address(0); // store Ether in tokens mapping with blank address 
  	address constant VFRC_address = 0xf0d54349aDdcf704F77AE15b96510dEA15cb7952; // VRF Coordinator
  	address constant LINK_address = 0x514910771AF9Ca656af840dff83E8264EcF986CA; // LINK token
	bytes32 constant internal keyHash = 0xAA77729D3466CA35AE8D28B3BBAC7CC36A5031EFDC430821C02BC31A238AF445;
	uint256 public constant feeAmountWei = 50000000000000;
	uint256 public constant ticketAmtWei = 5000000000000000;
	uint256 public constant oneDingo = 1000000000000000000;
	uint256 private constant oneHr = 3600;
	uint256 private constant oneWeek = 604800;
	uint256 public randomResult;
	uint256 private bonus;
	uint256 public bonusTarget;
	uint256 public bonusLaunch;
	uint256 public bonusCount;
	uint256 public drawNumber;
	uint256 public ticketCount;
	uint256 public nextDraw;
	uint256 public drawClose;
	uint256 public initDraw; //holds first ever draw
	uint256 public fee;
	uint256 private devCount;
	uint256 public reserveFunds;
	uint256 public rndFlag;
	uint256[3] public prizePoolBreakDown;

	address public devAddr;
	Dingo public dingoToken;
	bool public dingoOn;
	
	mapping(uint256 => uint256) public prizePool;
 	mapping(address => mapping(address => uint256)) public tokens;
	mapping(uint256 => _Tickets) public Tickets;
	mapping(uint256 => mapping(address => uint256)) public lottoEntries;
	mapping(uint256 => mapping(uint256 => address)) public drawUser;
	mapping(uint256 => uint256 ) public totalUsers;
	mapping(uint256 => bool) public claimedTickets;

	mapping(uint => mapping(uint => mapping (uint => mapping(uint => mapping(uint => uint))))) private _fourCombo;
	mapping(uint => mapping(uint => mapping (uint => mapping(uint => mapping(uint => mapping(uint => uint)))))) private _fiveCombo;
	mapping(uint => mapping(uint => mapping (uint => mapping(uint => mapping(uint => mapping(uint => mapping(uint => uint))))))) private _sixCombo;

	mapping(uint256 => _WinningNumbers) public winningNumbers;

	struct _WinningNumbers {
		uint256 draw;
		uint256 drawDate;
		uint256[6] winningNumbers;
		uint256 totalWinnings;
		uint256[3] numWinners;
		uint256[3] winningAmount;
		uint256	timestamp;
	}
	struct _Tickets {
		uint256 id;
		uint256 drawNum;
		address user;
    	uint256[6] lottoNumbers;
    	uint256 timestamp;
    }

	event TicketCreated(
		address indexed owner,
		uint256 indexed ticketNum,
		uint256 indexed drawNum,
		uint256 num_1,
		uint256 num_2,
		uint256 num_3,
		uint256 num_4,
		uint256 num_5,
		uint256 num_6,
		uint256 timestamp
		);
	event Deposit(
			address token,
			address user,
			uint256 amount,
			uint256 balance);

    event Withdraw(
		address token,
		address user,
		uint256 amount,
		uint256 balance
		);
    event Draw(
		uint256 indexed draw,
		uint256 ball_1,
		uint256 ball_2,
		uint256 ball_3,
		uint256 ball_4,
		uint256 ball_5,
		uint256 ball_6
		);

	event ClaimedTicket(
			uint256 indexed draw,
			address indexed owner,
			uint256 indexed ticketnum,
			uint256 amount
			);
	event RandomResult(
			uint256 indexed draw,
			uint256 number,
			string status
			);
	event Received(address indexed sender, uint256 amount);
	
	modifier onlyDev() {
    	require(msg.sender == devAddr, 'only developer can call this function');
    	_;
  	}

	constructor (address _devAddr, uint256 _setDate, Dingo _Dingo_Token, uint256 _bonusTarget)
		VRFConsumerBase(VFRC_address, LINK_address) public {
		devAddr = _devAddr;
		devCount = 0;
		reserveFunds = 0;
		drawNumber = 1;
		bonusLaunch = 5;
		ticketCount = 0;
		dingoToken = _Dingo_Token;
		nextDraw = _setDate;
		initDraw = _setDate;
		drawClose = nextDraw.sub(oneHr);
		bonusTarget = _bonusTarget;
		bonusCount = 0;
		rndFlag = 0;
		prizePoolBreakDown[0] = 50;
		prizePoolBreakDown[1] = 30;
		prizePoolBreakDown[2] = 20;
		dingoOn = false;
		fee = 2 * 10 ** 18; // 0.1 LINK
	} 
	
	receive() external payable {
		emit Received(msg.sender, msg.value);
	}

	function depositEther() public payable {
        tokens[ETHER][msg.sender] = tokens[ETHER][msg.sender].add(msg.value);
        emit Deposit(ETHER, msg.sender, msg.value, tokens[ETHER][msg.sender]);
    }

	function withdrawEther(uint _amount) public {
		require(tokens[ETHER][msg.sender] >= _amount, "No Enough Eth On Account");
		tokens[ETHER][msg.sender] = tokens[ETHER][msg.sender].sub(_amount);
		payable(msg.sender).transfer(_amount);
		emit Withdraw(ETHER, msg.sender, _amount, tokens[ETHER][msg.sender]);
	}

	function depositToken(address _token, uint _amount) public {
		require(_token != ETHER, "Cannot Deposit Eth With Using Deposit Token");
		require(Dingo(_token).transferFrom(msg.sender, address(this), _amount),"Transfer Failed");
		tokens[_token][msg.sender] = tokens[_token][msg.sender].add(_amount);
		emit Deposit(_token, msg.sender, _amount, tokens[_token][msg.sender]);
	}

	function withdrawToken(address _token, uint256 _amount) public {
		require(_token != ETHER, "Cannot Withdraw Eth Using Withdraw Token");
		require(tokens[_token][msg.sender] >= _amount,"Withdraw Amount Greater Than Balance");
		tokens[_token][msg.sender] = tokens[_token][msg.sender].sub(_amount);
		require(Dingo(_token).transfer(msg.sender, _amount), "Transfer failed");
		emit Withdraw(_token, msg.sender, _amount, tokens[_token][msg.sender]);
	}
	function createDingoTicket(uint256[6][] memory _lottoNumbers, uint256  _drawNumber) public {
		uint256 numTickets = _lottoNumbers.length;
		require (dingoOn, "Dingo Token Use Not Active... Yet...");
		require (block.timestamp < drawClose, "Draw Closed");
		require (_drawNumber >= drawNumber, "Ticket Draw Number is Invalid");
		require (Dingo(dingoToken).transferFrom(msg.sender, address(this), numTickets.mul(oneDingo)),"Transfer Failed");
		Dingo(dingoToken).burn(numTickets.mul(oneDingo));
		_storeTickets(_lottoNumbers, _drawNumber);
	}
	function createTicket(uint256[6][] memory _lottoNumbers, uint256  _drawNumber) public payable {
		uint256 numTickets = _lottoNumbers.length;
		uint256 _totalCost = ticketAmtWei.mul(numTickets);

		require (block.timestamp < drawClose, "Draw Closed");
		require (_drawNumber >= drawNumber, "Ticket Draw Number is Invalid");
		require (tokens[ETHER][msg.sender] + msg.value >= _totalCost,"Not enough Eth to buy ticket");

		uint256 _totalFees = feeAmountWei.mul(numTickets);
		
		prizePool[_drawNumber] = prizePool[_drawNumber].add(_totalCost).sub(_totalFees);

		tokens[ETHER][devAddr] = tokens[ETHER][devAddr].add(_totalFees);
		tokens[ETHER][msg.sender] = tokens[ETHER][msg.sender].add(msg.value).sub(_totalCost);

		bonus = 1;
		if (bonusCount<=bonusTarget) {
			bonus = 2;
		}
		bonusCount = bonusCount.add(numTickets);

		dingoToken.mint(msg.sender, oneDingo.mul(numTickets).mul(bonus).mul(bonusLaunch));
		devCount = devCount.add(numTickets.mul(bonus).mul(bonusLaunch));
		if (devCount>=10){
			uint256 allocation = devCount.div(10);
			dingoToken.mint(devAddr, oneDingo.mul(allocation));
			devCount = devCount.sub(allocation.mul(10));
		}

		_storeTickets(_lottoNumbers, _drawNumber);
	}
	function requestRandom() public {
		require(LINK.balanceOf(address(this)) > fee, "Error, not enough LINK - fill contract with faucet");
		require(rndFlag == 0, "Random Number Already Requested");
		require(block.timestamp > nextDraw); //Ensure it's time to draw lottery
		rndFlag = 1;
		dingoToken.mint(msg.sender, oneDingo.mul(100));
		bytes32 requestId = requestRandomness(keyHash, fee);
	}
	function expand(uint256 randomValue, uint256 n) public pure returns (uint256[] memory expandedValues) {
		expandedValues = new uint256[](n);
		for (uint256 i = 0; i < n; i++) {
			expandedValues[i] = uint256(keccak256(abi.encode(randomValue, i)));
		}
		return expandedValues;
	}
	function drawLottery() public {
			require(rndFlag==2,"Waiting on random request");
			uint256[6] memory _balls;
			uint256[] memory _rndSelection;
			_rndSelection = expand(randomResult, 12);
			uint _rndi = 0;
			bool _unique;
			for (uint i = 0; i < 6; i++){
				do {
					_unique = true;
					_balls[i] = (_rndSelection[_rndi] % 49) + 1;
					if (i > 0){
						for (uint ii = 0; ii < i; ii++){
							if (_balls[i] == _balls[ii]) {
								_unique = false;
								_rndi++;
							}
						}
					}
				} while (!_unique);
				_rndi++;
			}
			_balls = ticketSort(_balls);
			checkWinningCombo(_balls, drawNumber);

			for (uint i = 0; i < 3; i++)
			{
				if (winningNumbers[drawNumber].numWinners[i] > 0){
					winningNumbers[drawNumber].totalWinnings += (prizePool[drawNumber] * prizePoolBreakDown[i]) / 100;
					winningNumbers[drawNumber].winningAmount[i] = (prizePool[drawNumber] * prizePoolBreakDown[i]) / winningNumbers[drawNumber].numWinners[i] / 100;
				}
			}
			winningNumbers[drawNumber].drawDate = nextDraw;
			winningNumbers[drawNumber].winningNumbers = _balls;
			winningNumbers[drawNumber].draw = drawNumber;
			winningNumbers[drawNumber].timestamp = block.timestamp;
			
			reserveFunds += winningNumbers[drawNumber].totalWinnings;
			prizePool[drawNumber + 1] += prizePool[drawNumber] - winningNumbers[drawNumber].totalWinnings;
			dingoToken.mint(msg.sender, oneDingo.mul(300));
			bonusCount = 0;
			bonusLaunch = 1;
			emit Draw(
				drawNumber,
				_balls[0],
				_balls[1],
				_balls[2],
				_balls[3],
				_balls[4],
				_balls[5]);
			rndFlag=0;
			drawNumber++;
			nextDraw += oneWeek;
			drawClose = nextDraw - oneHr;
	}

	function claimTickets(uint256[] memory ticketNumbers) public {
		uint tNLength = ticketNumbers.length;
		uint winCount;
		uint256[6] memory numbers;
		uint256[6] memory winning;
		address _owner;
		uint256 _winAmt;
		uint _draw;
		for (uint i = 0; i < tNLength; i++) {
			numbers = Tickets[ticketNumbers[i]].lottoNumbers;
			_draw = Tickets[ticketNumbers[i]].drawNum;
			require(!claimedTickets[i],"Ticket already claimed");
			if (_draw < drawNumber ) {
				_owner = Tickets[ticketNumbers[i]].user;
				winCount = 0;
				winning = winningNumbers[_draw].winningNumbers;
				for (uint wLoop = 0; wLoop < 6; wLoop++) {
					for (uint nLoop = 0; nLoop < 6; nLoop++) {
						if (numbers[nLoop] > winning[wLoop]) {
							nLoop = 6;
						}
						else if (numbers[nLoop] == winning[wLoop]) {
							winCount++;
						}
					}
				}
				_winAmt = 0;
				if (winCount == 4) {
					_winAmt = winningNumbers[_draw].winningAmount[2];
				} else if (winCount == 5) {
					_winAmt = winningNumbers[_draw].winningAmount[1];
				} else if (winCount == 6) {
					_winAmt = winningNumbers[_draw].winningAmount[0];
				}
				reserveFunds = reserveFunds.sub(_winAmt);
				tokens[ETHER][_owner] = tokens[ETHER][_owner].add(_winAmt);
				claimedTickets[ticketNumbers[i]] = true;
				if (winCount > 3) {
					emit ClaimedTicket(
						_draw, 
						_owner, 
						ticketNumbers[i], 
						_winAmt);
				}
			}
		}
	}
	function getDrawData(uint256 _drawNum) public view returns (_WinningNumbers memory) {
		return winningNumbers[_drawNum];
	}
	function balanceOf(address _token, address _user) public view returns (uint256) {
        return tokens[_token][_user];
    }
	function getTicketNumbers(uint256 tickNum) public view returns(uint256, uint256, uint256, uint256, uint256, uint256) {
		return (Tickets[tickNum].lottoNumbers[0],
				Tickets[tickNum].lottoNumbers[1],
				Tickets[tickNum].lottoNumbers[2],
				Tickets[tickNum].lottoNumbers[3],
				Tickets[tickNum].lottoNumbers[4],
				Tickets[tickNum].lottoNumbers[5]);
	}
	function goDingo() public onlyDev {
		dingoOn = true;
	}
	function updateFee(uint256 _fee) public onlyDev {
		fee = _fee;
	}
	function updateDevAddr(address _devAddr) public onlyDev {
		devAddr = _devAddr;
	}
	function updateBonusTarget(uint _bonusTarget) public onlyDev {
		bonusTarget = _bonusTarget;
	}
	function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
		randomResult = randomness;
		rndFlag = 2;
		emit RandomResult(
			drawNumber,
			randomResult, 
			"Draw: Received Number"
			);
	}
	function _storeTickets(uint256[6][] memory _lN, uint256  _dN) private {
		uint lNLength = _lN.length;
		for (uint tick = 0; tick < lNLength; tick++) {
			ticketCount++;
			_lN[tick] = ticketSort(_lN[tick]);
			Tickets[ticketCount] = _Tickets(ticketCount, _dN, msg.sender, _lN[tick], block.timestamp);
			_getFourCombo(_lN[tick], _dN);
			_getFiveCombo(_lN[tick], _dN);
			_getSixCombo(_lN[tick], _dN);
			claimedTickets[ticketCount] = false;
			emit TicketCreated(
				msg.sender,
				ticketCount,
				_dN,
				_lN[tick][0],
				_lN[tick][1],
				_lN[tick][2],
				_lN[tick][3],
				_lN[tick][4],
				_lN[tick][5],
				block.timestamp
				);
		}
	}
	function ticketSort(uint256[6] memory _ticketToSort) private pure returns (uint256[6] memory) {
		uint256 _tempBall;
		for (uint i = 0; i < 5; i++)
		{
			for(uint ii = i+1; ii < 6; ii++)
			{
				if(_ticketToSort[i] > _ticketToSort[ii])
				{
					_tempBall = _ticketToSort[i];
					_ticketToSort[i] = _ticketToSort[ii];
					_ticketToSort[ii] = _tempBall;
				}
			}
		}
		return _ticketToSort;
	}
	function _getFourCombo(uint256[6] memory _cT, uint256 _drawNum) private {
		for (uint _chkOne = 0; _chkOne < 3; _chkOne++)
		{
			for (uint _chkTwo = _chkOne + 1; _chkTwo < 4; _chkTwo++)
			{
				for (uint _chkThree = _chkTwo + 1; _chkThree < 5; _chkThree++)
				{
					for (uint _chkFour = _chkThree + 1; _chkFour < 6; _chkFour++)
					{
						_fourCombo[_drawNum][_cT[_chkOne]][_cT[_chkTwo]][_cT[_chkThree]][_cT[_chkFour]]++;
					}
				}
			}
		}
	}
	function _getFiveCombo(uint256[6] memory _cT, uint256 _drawNum) private {
		for (uint _chkOne = 0; _chkOne < 2; _chkOne++)
		{
			for (uint _chkTwo = _chkOne + 1; _chkTwo < 3; _chkTwo++)
			{
				for (uint _chkThree = _chkTwo + 1; _chkThree < 4; _chkThree++)
				{
					for (uint _chkFour = _chkThree + 1; _chkFour < 5; _chkFour++)
					{
						for (uint _chkFive = _chkFour + 1; _chkFive < 6; _chkFive++)
						{
							_fiveCombo[_drawNum][_cT[_chkOne]][_cT[_chkTwo]][_cT[_chkThree]][_cT[_chkFour]][_cT[_chkFive]]++;
						}
					}
				}
			}
		}
	}
	function _getSixCombo(uint256[6] memory _cT, uint256 _drawNum) private {
			if (_sixCombo[_drawNum][_cT[0]][_cT[1]][_cT[2]][_cT[3]][_cT[4]][_cT[5]] == 0){
				_sixCombo[_drawNum][_cT[0]][_cT[1]][_cT[2]][_cT[3]][_cT[4]][_cT[5]] = 1;
			} else {
			_sixCombo[_drawNum][_cT[0]][_cT[1]][_cT[2]][_cT[3]][_cT[4]][_cT[5]]++;}
	}
	function checkWinningCombo(uint256[6] memory _cT, uint256 _drawNum) private {
		uint256 _comboCount;
		winningNumbers[_drawNum].numWinners[0] = _sixCombo[_drawNum][_cT[0]][_cT[1]][_cT[2]][_cT[3]][_cT[4]][_cT[5]];

		_comboCount = 0;
		for (uint _chkOne = 0; _chkOne < 2; _chkOne++)
		{
			for (uint _chkTwo = _chkOne + 1; _chkTwo < 3; _chkTwo++)
			{
				for (uint _chkThree = _chkTwo + 1; _chkThree < 4; _chkThree++)
				{
					for (uint _chkFour = _chkThree + 1; _chkFour < 5; _chkFour++)
					{
						for (uint _chkFive = _chkFour + 1; _chkFive < 6; _chkFive++)
						{
							_comboCount = _comboCount + _fiveCombo[_drawNum][_cT[_chkOne]][_cT[_chkTwo]][_cT[_chkThree]][_cT[_chkFour]][_cT[_chkFive]];
						}
					}
				}
			}
		}
		winningNumbers[_drawNum].numWinners[1] = _comboCount.sub(winningNumbers[_drawNum].numWinners[0].mul(6));

		_comboCount = 0;
		for (uint _chkOne = 0; _chkOne < 3; _chkOne++)
		{
			for (uint _chkTwo = _chkOne + 1; _chkTwo < 4; _chkTwo++)
			{
				for (uint _chkThree = _chkTwo + 1; _chkThree < 5; _chkThree++)
				{
					for (uint _chkFour = _chkThree + 1; _chkFour < 6; _chkFour++)
					{
						_comboCount += _fourCombo[_drawNum][_cT[_chkOne]][_cT[_chkTwo]][_cT[_chkThree]][_cT[_chkFour]];
					}
				}
			}
		}
		winningNumbers[_drawNum].numWinners[2] = _comboCount.sub(winningNumbers[_drawNum].numWinners[1].mul(5)).sub(winningNumbers[_drawNum].numWinners[0].mul(15));
	}
}