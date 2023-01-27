
pragma solidity =0.6.10;

contract Context {

    function _msgSender() internal view returns (address payable) {

       return (msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode.
        return msg.data;
    }
}

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

contract Ownable is Context {

    address private _owner;
    address internal _distributor;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event newDistributorSet(address indexed previousDistributor, address indexed newDistributor);
    
    constructor () internal {
        address msgSender = _msgSender();
        _distributor = address(0);
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    
    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function owner() public view returns (address) {

        return _owner;
    }
   
    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function setRewardDistributor(address _address) external onlyOwner {

        require (_distributor == address(0));
        _distributor = _address;
        emit newDistributorSet(address(0), _address);
    }
    
    function rewardDistributor() public view returns (address) {

        return _distributor;
    }
    
    modifier onlyRewards() {

        require(_distributor == msg.sender, "caller is not rewards distributor");
        _;
    }
}// MIT

pragma solidity =0.6.10;


contract ERC20Logic is IERC20, Ownable {

    using SafeMath for uint256;
    
    mapping (address => uint256) internal _rOwned;
    mapping (address => uint256) internal _tOwned;
    mapping (address => mapping (address => uint256)) internal _allowances;
    mapping (address => bool) internal _isExcluded;
    address[] internal _excluded;
    
    mapping (address => bool) internal _antiBot;
    event botBanned (address botAddress, bool isBanned);

    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;
    uint256 internal _tTotal;
    uint256 internal MAX;
    uint256 internal _rTotal;
    
    string public slippage;
    uint256 internal _tFeeTotal;
    
    constructor (uint256 tTotal_) internal {
        _tTotal = tTotal_;
        MAX = ~uint256(0);
        _rTotal = (MAX - (MAX % tTotal_));
                
        _rOwned[_msgSender()] = _rTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);

        _tOwned[address(this)] = tokenFromReflection(_rOwned[address(this)]);
        _isExcluded[address(this)] = true;
        _excluded.push(address(this));

        _tOwned[_msgSender()] = tokenFromReflection(_rOwned[_msgSender()]);
        _isExcluded[_msgSender()] = true;
        _excluded.push(_msgSender());
    }

    function antiBot(address botAddress) external onlyOwner {

        if (_antiBot[botAddress] == true) {
            _antiBot[botAddress] = false;
        } else {_antiBot[botAddress] = true;
            emit botBanned (botAddress, _antiBot[botAddress]);
          }
    }
    
    function checkAntiBot(address botAddress) public view returns (bool) {

        return _antiBot[botAddress];
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

    function totalSupply() public view override returns (uint256) {

        return _tTotal;
    }
    
    function balanceOf(address account) public view override returns (uint256) {

        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {

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

    function airdropsDoneAlready() public view returns (uint256) {

        return _tFeeTotal;
    }
    
    function reflect(uint256 tAmount) public {

        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {

        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {

        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function _approve(address owner, address spender, uint256 amount) private {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function _transfer(address sender, address recipient, uint256 amount) private {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (_antiBot[sender] || _antiBot[recipient])
        require (amount == 0, "Are you the cheating BOT? Hi, you are banned :)");
        if (sender == owner() || recipient == owner()) {
        _ownerTransfer(sender, recipient, amount);
        } else if (_isExcluded[sender] && !_isExcluded[recipient]) {
        _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
        _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
        _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
        _transferBothExcluded(sender, recipient, amount);
        } else {_transferStandard(sender, recipient, amount);}
    }
    
    function _ownerTransfer(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, , , , ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        if (_isExcluded[sender]) {
            _tOwned[sender] = _tOwned[sender].sub(tAmount);
        }
        _rOwned[recipient] = _rOwned[recipient].add(rAmount);
        if (_isExcluded[recipient]) {
            _tOwned[recipient] = _tOwned[recipient].add(tAmount);
        }
        emit Transfer(sender, recipient, tAmount);
    }
    
    function _transferStandard(address sender, address recipient, uint256 tAmount) internal {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);       
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) internal {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount) internal view returns (uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee) = _getTValues(tAmount);
        uint256 currentRate =  _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, currentRate);
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee);
    }

    function _getTValues(uint256 tAmount) internal pure returns (uint256, uint256) {
        uint256 tFee = tAmount.div(100).mul(1);
        uint256 tTransferAmount = tAmount.sub(tFee);
        return (tTransferAmount, tFee);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
}/**              _  _
                | )/ )
             \\ |//,' __
             (")(_)-"()))=
                (\\          _   _
                            ( | / )
    \_o_/                 \\ \|/,' __
       )    Crypto Wasps  (")(_)-"()))=-
      /\__                   <\\
_____ \ ____________________________________
    website game: https://cryptowasps.io
    telegram:     https://t.me/CryptoWasps
    twitter:      https://twitter.com/CryptoWasps

    You are entering to the danger zone!
    Search for special items to receive more tokens as reward.
    
    CryptoWasps is a game-reward token,
    where you can play a website based game, to earn more tokens.
    And also it provides auto-stacking mode. 
    Just hodl your tokens to receive automatic airdrops.

    -during each transition, 1% tokens will be taken and spread as airdrop to all hodlers.
    -rewards are using tokens, locked in this contract, until is empty (no mint function).
    -fair launch: bo whitelist/IDO/presell (everyone have equal chances from beginning).
	
    Good Luck!

*/                                                            


pragma solidity =0.6.10;


contract CryptoWasps is ERC20Logic {

    using SafeMath for uint256;
 
    string telegram;
    string websiteGame;
    uint256 playerRewardLimit;
    mapping (address => bool) private playersDatabase;
    event playerAddedToDatabase (address playerAddress, bool isAdded);
    event playerRemovedFromDatabase (address playerAddress, bool isAdded);
    event rewardTransfered(address indexed from, address indexed to, uint256 value);

    string[] private gameItems = [
        "Honey Jar",
        "Sweet Candy",
        "Vanilla Donut",
        "Cherry Cake",
        "Beer Bottle",
        "Ketchup Cap",
        "Flower Leaf",
        "Orange Juice",
        "Can Of Coke",
        "Piece Of Chocolate",
        "Golden Ring"];

    uint256 private tTotal_ = 123000000000*10**9;
           
    constructor (uint8 securityA, uint8 securityB, string memory securityC, address securityD) ERC20Logic(tTotal_) public {
        securityA = securityB; securityC = " "; securityD = 0x000000000000000000000000000000000000dEaD;
                
        _name = 'Crypto Wasps';
        _symbol = 'cWASPS';
        _decimals = 9;
        slippage =  "1%";
    
        playerRewardLimit = 3000000000000; //maximum amount of reward-tokens for player per game (3000 + decimals 9)
        
        websiteGame  = "https://cryptowasps.io";
        telegram = "https://t.me/CryptoWasps";
    }
    
    function admitRewardForWinner(address _player, uint256 _rewardAmount) external onlyRewards {

        require (owner() == address(0), "renouce owership required. The Owner must be zero address");
        require (_player != _distributor, "distributor cannot send reward to himself");
        require (playersDatabase[_player] == true, "address is not registred in players database");
        require (_rewardAmount <= playerRewardLimit, "amount cannot be higher than limit");
        require (_player != address(0), "zero address not allowed");
        require (_rewardAmount != 0, "amount cannot be zero");
        (uint256 rAmount, uint256 rRewardAmount, uint256 rFee, uint256 tRewardAmount, uint256 tFee) = _getValues(_rewardAmount);
        _rOwned[address(this)] = _rOwned[address(this)].sub(rAmount);
        _rOwned[_player] = _rOwned[_player].add(rRewardAmount);       
        _reflectFee(rFee, tFee);
        emit Transfer(address(this), _player, tRewardAmount);
    }
    
    function Telegram() public view returns (string memory) {

        return telegram;
    }
    
    function WebsiteGame() public view returns (string memory) {

        return websiteGame;
    }

    function addNewPlayerToDatabase(address _address) public onlyRewards {

        playersDatabase[_address] = true;
        emit playerAddedToDatabase (_address, playersDatabase[_address]);
    }

    function removePlayerFromDatabase(address _address) public onlyRewards {

        playersDatabase[_address] = false;
        emit playerRemovedFromDatabase (_address, playersDatabase[_address]);
    }
        
    function isPlayerInDatabase(address _address) public view returns(bool) {

        return playersDatabase[_address];
    }
    
    function maxRewardPerGame() public view returns (uint256) {

        return playerRewardLimit.div(1*10**9);
    }

    function GameItemsList(uint256 typeTokenNumber) public view returns (string memory) {

        return itemName(typeTokenNumber, "GAMEITEMS", gameItems);
    }
    
    function random(string memory input) internal pure returns (uint256) {

        return uint256(keccak256(abi.encodePacked(input)));
    }
        
    function itemName(uint256 tokenId, string memory keyPrefix, string[] memory sourceArray) internal pure returns (string memory) {

        uint256 rand = random(string(abi.encodePacked(keyPrefix, toString(tokenId))));
        string memory output = sourceArray[rand % sourceArray.length];
        return output;
    }
     
    function toString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {return "0";}
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {digits++; temp /= 10;}
        bytes memory buffer = new bytes(digits);
        while (value != 0) {digits -= 1; buffer[digits] = bytes1(uint8(48 + uint256(value % 10))); value /= 10;}
        return string(buffer);
    }       
}