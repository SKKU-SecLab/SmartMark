

pragma solidity ^0.5.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


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

library SafeMath {

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
}


pragma solidity ^0.5.0;


contract ERC20 is IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 9;
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
    
    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {

        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 value) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }


    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}


pragma solidity ^0.5.0;


contract MultOwnable {

  address[] private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor() internal {
    _owner.push(msg.sender);
    emit OwnershipTransferred(address(0), _owner[0]);
  }

  function checkOwner() private view returns (bool) {

    for (uint8 i = 0; i < _owner.length; i++) {
      if (_owner[i] == msg.sender) {
        return true;
      }
    }
    return false;
  }

  function checkNewOwner(address _address) private view returns (bool) {

    for (uint8 i = 0; i < _owner.length; i++) {
      if (_owner[i] == _address) {
        return false;
      }
    }
    return true;
  }

  modifier isAnOwner() {

    require(checkOwner(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public isAnOwner {

    for (uint8 i = 0; i < _owner.length; i++) {
      if (_owner[i] == msg.sender) {
        _owner[i] = address(0);
        emit OwnershipTransferred(_owner[i], msg.sender);
      }
    }
  }

  function getOwners() public view returns (address[] memory) {

    return _owner;
  }

  function addOwnerShip(address newOwner) public isAnOwner {

    _addOwnerShip(newOwner);
  }

  function _addOwnerShip(address newOwner) internal {

    require(newOwner != address(0), "Ownable: new owner is the zero address");
    require(checkNewOwner(newOwner), "Owner already exists");
    _owner.push(newOwner);
    emit OwnershipTransferred(_owner[_owner.length - 1], newOwner);
  }
}


pragma solidity ^0.5.16;



contract TulipToken is MultOwnable, ERC20{

    constructor (string memory name, string memory symbol) public ERC20(name, symbol) MultOwnable(){
    }

    function contractMint(address account, uint256 amount) external isAnOwner{

        _mint(account, amount);
    }

    function contractBurn(address account, uint256 amount) external isAnOwner{

        _burn(account, amount);
    }


    function addOwner(address _newOwner) external isAnOwner {

        addOwnerShip(_newOwner);
    }

    function getOwner() external view isAnOwner{

        getOwners();
    }

    function renounceOwner() external isAnOwner {

        renounceOwnership();
    }
}


pragma solidity ^0.5.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}


pragma solidity ^0.5.0;




library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity ^0.5.0;

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity ^0.5.16;






contract GardenContractV2 is Ownable {

  using SafeMath for uint256;
  using SafeERC20 for TulipToken;
  using SafeERC20 for IERC20;

  address internal _benefitiaryAddress = 0x8b531Fa80E34228FAD330bA1eCc6B94864AFA63C; //Founder Address

  uint256 internal _epochBlockStart = 1600610400;

  uint256 internal _timeScale = (1 days);


  uint256 private _decimalConverter = 10**9;

  uint256[3] internal _totalGrowing;

  uint256[3] internal _totalGrown; /* REMEMBER THE DIFFERENCE */

  uint256[3] internal _totalBurnt;

  uint256[2] internal _totalDecomposed;

  TulipToken[3] private _token;

  uint256[3] private _totalSupply;

  struct  tulipToken{
      mapping(address => bool)      forSeeds;
      mapping(address => uint256)   planted;
      mapping(address => uint256)   periodFinish; //combine with decomposing
      mapping(address => bool)      isDecomposing;
  }

  tulipToken[10][3] private _tulipToken;



  constructor(address _seedToken, address _basicTulipToken, address _advTulipToken) public Ownable() {
    _token[0] = TulipToken(_seedToken);
    _token[1] = TulipToken(_basicTulipToken);
    _token[2] = TulipToken(_advTulipToken);
  }



  function totalGardenSupply(string calldata name) external view returns (uint256) {

    uint8 i = tulipType(name);

    return _totalSupply[i] ;
  }

  function totalBedSupply(string calldata name, uint8 garden) external view returns (uint256) {

    uint8 i = tulipType(name);  

    return _tulipToken[i][garden].planted[msg.sender];
  }


  function totalTLPGrowing(string calldata name) external view returns (uint256) {

    uint8 i = tulipType(name);  

    return _totalGrowing[i];
  }

  function totalTLPDecomposed(string calldata name) external view returns (uint256) {

    uint8 i = tulipType(name) - 1;  
    return _totalDecomposed[i];
  }

  function totalTLPGrown(string calldata name) external view returns (uint256) {

    uint8 i = tulipType(name);  

    return _totalGrown[i];
  }

  function totalTLPBurnt(string calldata name) external view returns (uint256) {

    uint8 i = tulipType(name);  

    return _totalBurnt[i];
  }

  function growthRemaining(address account, string calldata name, uint8 garden) external view returns (uint256) {

    uint8 i = tulipType(name);
    return _tulipToken[i][garden].periodFinish[account].sub(now);
  }

  function timeUntilNextTLP(string calldata name, uint8 garden) external view returns (uint256) {

    uint256 plantTimeSeconds = _tulipToken[tulipType(name)][garden].periodFinish[msg.sender].sub(7 * _timeScale);
    uint256 secondsDifference = now - plantTimeSeconds;
    uint256 weeksSincePlanting = (secondsDifference).div(60).div(60).div(24).div(7);

    if((((secondsDifference).div(60).div(60).div(24)) % 7) > 0){
      weeksSincePlanting = weeksSincePlanting.add(1);
      
      return plantTimeSeconds.add(weeksSincePlanting.mul(7 * _timeScale)).sub(secondsDifference);
    }
    else{
      return 0;
    }
  }

  function balanceOf(address account, string calldata name) external view returns (uint256)
  {

    uint8 i = tulipType(name);
    uint256 total;

    for(uint8 k; k < _tulipToken[0].length; k++){
      total = total + _tulipToken[i][k].planted[account];
    }

    return total;
  }


  function getTotalrTLPHarvest(uint8 garden) external view returns (uint256){

    uint256 total;
    if(garden > 10){
      for(uint8 k; k < _tulipToken[0].length; k++){
        total = total + redTulipRewardAmount(k);
      }
    }
    else{
      total = redTulipRewardAmount(garden);
    }
    
    return total;
  }

  function getTotalpTLPHarvest(uint8 garden) external view returns (uint256[2] memory){

    uint256[2] memory total;

    if(garden > 10){
      for(uint8 k; k < _tulipToken[0].length; k++){
        if(_tulipToken[1][k].forSeeds[msg.sender]){
          total[1] = total[1] + pinkTulipRewardAmount(k);
        }
        else{
          total[0] = total[0] + _tulipToken[1][k].planted[msg.sender];
        }
      }
    }
    else{
        if(_tulipToken[1][garden].forSeeds[msg.sender]){
          total[1] = pinkTulipRewardAmount(garden);
        }
        else{
          total[0] = _tulipToken[1][garden].planted[msg.sender];
        }
    }
   
    return total;
  }

  function getTotalsTLPHarvest(uint8 garden) external view returns (uint256){

    uint256 total;
    if(garden > 10){
      for(uint8 k; k < _tulipToken[0].length; k++){
        total = total + _tulipToken[0][k].planted[msg.sender];
      }
    }
    else{
      total = _tulipToken[0][garden].planted[msg.sender];
    }

    return total;
  } 



  function plant(uint256 amount, string calldata name, uint8 garden, bool forSeeds) external { 

    uint8 i = tulipType(name);
    require(_tulipToken[i][garden].planted[msg.sender] == 0 && now > _tulipToken[i][garden].periodFinish[msg.sender], 
    "201");//You must withdraw or harvest the previous crop
    if(i == 1 && !forSeeds){
      require((amount % 100) == 0, "203");//Has to be multiple of 100
    }
    
    _token[i].safeTransferFrom(msg.sender, address(this), amount.mul(_decimalConverter));
    _totalSupply[i] = _totalSupply[i].add(amount);
    _tulipToken[i][garden].planted[msg.sender] = _tulipToken[i][garden].planted[msg.sender].add(amount);

    _totalGrowing[i] = _totalGrowing[i] + amount;

    if(forSeeds && i != 0){
      _tulipToken[i][garden].periodFinish[msg.sender] = now.add(7 * _timeScale);
      _tulipToken[i][garden].forSeeds[msg.sender] = true;
    }
    else{
      setTimeStamp(i, garden);
    }

    emit Staked(msg.sender, amount);
  }


  function withdraw(string memory name, uint8 garden) public {

    uint8 i = tulipType(name);
    require(!_tulipToken[i][garden].isDecomposing[msg.sender], "226");//Cannot withdraw a decomposing bed
    
    if(now > _tulipToken[i][garden].periodFinish[msg.sender] && _tulipToken[i][garden].periodFinish[msg.sender] > 0 && _tulipToken[i][garden].forSeeds[msg.sender]){
        harvestHelper(name, garden, true);
    }
    else{
        _totalGrowing[i] = _totalGrowing[i].sub(_tulipToken[i][garden].planted[msg.sender]);
    }

    _token[i].safeTransfer(msg.sender, _tulipToken[i][garden].planted[msg.sender].mul(_decimalConverter));

    emit Withdrawn(msg.sender, _tulipToken[i][garden].planted[msg.sender]);

    zeroHoldings(i, garden);
  }

  function harvest(string memory name, uint8 garden) public {

    require(!_tulipToken[tulipType(name)][garden].isDecomposing[msg.sender], "245");//Cannot withdraw a decomposing bed

    harvestHelper(name, garden, false);
  }


  function harvestAllBeds(string memory name) public {

    uint8 i;
    uint256[6] memory amount;

    i = tulipType(name);      
    amount = utilityBedHarvest(i);
    for(i = 0; i < 3; i++){
      if(amount[i] > 0){
          _token[i].contractMint(msg.sender, amount[i].mul(_decimalConverter));
          
          _totalGrown[i] = _totalGrown[i].add(amount[i]);
          
          emit RewardPaid(msg.sender, amount[i]);
      }
      if(amount[i + 3] > 0){
          _token[i].contractBurn(address(this), amount[i + 3].mul(_decimalConverter));
          _totalGrowing[i] = _totalGrowing[i].sub(amount[i + 3]);
          _totalBurnt[i] = _totalBurnt[i].add(amount[i + 3]);
      }
    }
  }


 function decompose(string memory name, uint8 garden, uint256 amount) public {

    uint8 i = tulipType(name);
    require(_tulipToken[i][garden].planted[msg.sender] == 0 && (_tulipToken[i][garden].periodFinish[msg.sender] == 0 || now > _tulipToken[i][garden].periodFinish[msg.sender]), 
    "293");//Claim your last decomposing reward!
    require(i > 0, "310");//Cannot decompose a seed!

    _token[i].safeTransferFrom(msg.sender, address(this), amount.mul(_decimalConverter));
    _totalSupply[i] = _totalSupply[i].add(amount);
    _tulipToken[i][garden].planted[msg.sender] = amount;
    _tulipToken[i][garden].periodFinish[msg.sender] = now.add(1 * _timeScale);
  
    _tulipToken[i][garden].isDecomposing[msg.sender] = true;

    emit Decomposing(msg.sender, amount);
  }


  function claimDecompose(string memory name, uint8 garden) public {

    uint8 i = tulipType(name);
    require(_tulipToken[i][garden].isDecomposing[msg.sender], "308");//This token is not decomposing
    require(i > 0, "310");//Cannot decompose a seed! //redundant
    require(now > _tulipToken[i][garden].periodFinish[msg.sender], "312");//Cannot claim decomposition!

    uint256 amount = _tulipToken[i][garden].planted[msg.sender].mul(_decimalConverter);
    uint256 subAmount;
    uint8 scalingCoef;
    if(i == 1){
      subAmount = (amount * 4).div(5);
      scalingCoef = 1;
    }
    else{
      subAmount = (amount * 9).div(10);
      scalingCoef = 100;
    }

    _token[i].contractBurn(address(this), subAmount + (amount - subAmount).div(2));
    _totalDecomposed[i - 1] = _totalDecomposed[i - 1].add(amount.div(_decimalConverter));

    _token[0].contractMint(msg.sender, subAmount.mul(scalingCoef));
    _totalGrown[0] = _totalGrown[0].add(amount.div(_decimalConverter).mul(scalingCoef));

    _token[i].safeTransfer(_benefitiaryAddress, (amount - subAmount).div(2));
    

    _tulipToken[i][garden].planted[msg.sender] = 0;
    _totalSupply[i] = _totalSupply[i].sub(amount.div(_decimalConverter));

    _tulipToken[i][garden].isDecomposing[msg.sender] = false;

    emit ClaimedDecomposing(msg.sender, subAmount);
  }



  function addTokenOwner(address _tokenAddress, address _newOwner) external onlyOwner
  {


    TulipToken tempToken = TulipToken(_tokenAddress);
    tempToken.addOwner(_newOwner);
  }

  function renounceTokenOwner(address _tokenAddress) external onlyOwner
  {


    TulipToken tempToken = TulipToken(_tokenAddress);
    tempToken.renounceOwner();
  }

  function changeOwner(address _newOwner) external onlyOwner {

    transferOwnership(_newOwner);
  }

  function changeBenefitiary(address _newOwner) external onlyOwner
  {


    _benefitiaryAddress = _newOwner;
  }



  function tulipType(string memory name) internal pure returns (uint8) {

    if (keccak256(abi.encodePacked(name)) == keccak256(abi.encodePacked("sTLP"))) {
      return 0;
    }
    if (keccak256(abi.encodePacked(name)) == keccak256(abi.encodePacked("pTLP"))) {
      return 1;
    }
    if (keccak256(abi.encodePacked(name)) == keccak256(abi.encodePacked("rTLP"))) {
      return 2;
    } else {
      return 99;
    }
  }


  function setTimeStamp(uint8 i, uint8 garden) internal{

    if (i == 0) {
      setRewardDurationSeeds(garden);
    }
    if (i == 1) {
      _tulipToken[1][garden].periodFinish[msg.sender] = now.add(30 * _timeScale);
    }
    if (i == 2) {
      _tulipToken[2][garden].periodFinish[msg.sender] = now.add(7 * _timeScale);
    }
  }


  function zeroHoldings(uint8 i, uint8 garden) internal{

    _totalSupply[i] = _totalSupply[i] - _tulipToken[i][garden].planted[msg.sender];
    _tulipToken[i][garden].planted[msg.sender] = 0;
    _tulipToken[i][garden].periodFinish[msg.sender] = 0;
  }


  function operationBurnMint(uint8 token, uint8 garden, uint256 amount) internal{

      _token[token].contractBurn(address(this), _tulipToken[token][garden].planted[msg.sender].mul(_decimalConverter));
      _totalBurnt[token] = _totalBurnt[token].add(_tulipToken[token][garden].planted[msg.sender]);
      _totalGrowing[token] = _totalGrowing[token].sub(_tulipToken[token][garden].planted[msg.sender]);

      _token[token + 1].contractMint(msg.sender, amount.mul(_decimalConverter));
      _totalGrown[token + 1] = _totalGrown[token + 1].add(amount);
  }


  function utilityBedHarvest(uint8 token) internal returns(uint256[6] memory){

    uint256[6] memory amount;

     for(uint8 k; k < _tulipToken[0].length; k++){   
       if(!_tulipToken[token][k].isDecomposing[msg.sender]) {
        if (_tulipToken[token][k].planted[msg.sender] > 0 && now > _tulipToken[token][k].periodFinish[msg.sender]){
            if (token == 2) {
              amount[0] = amount[0] + redTulipRewardAmount(k).div(_decimalConverter);
              _tulipToken[token][k].periodFinish[msg.sender] = now.add(7 * _timeScale);
            } 
            else {
              if(token == 1){
                if(_tulipToken[token][k].forSeeds[msg.sender]){
                  amount[0] = amount[0] + pinkTulipRewardAmount(k).div(_decimalConverter);
                  _tulipToken[token][k].periodFinish[msg.sender] = now.add(7 * _timeScale);
                }
                else{
                  amount[token + 1] = amount[token + 1] + _tulipToken[token][k].planted[msg.sender].div(100);
                  amount[token + 3] = amount[token + 3] + _tulipToken[token][k].planted[msg.sender];
                  zeroHoldings(token, k);
                }
              }
              else{
                amount[token + 1] = amount[token + 1] + _tulipToken[token][k].planted[msg.sender];
                amount[token + 3] = amount[token + 3] + _tulipToken[token][k].planted[msg.sender];
                zeroHoldings(token, k);
              }   
            }
        }
          }     
        }
        return(amount);
  }


  function harvestHelper(string memory name, uint8 garden, bool withdrawing) internal {

    uint8 i = tulipType(name);
    if(!withdrawing){
      require(_tulipToken[i][garden].planted[msg.sender] > 0, "464"); //Cannot harvest 0
      require(now > _tulipToken[i][garden].periodFinish[msg.sender], "465");//Cannot harvest until bloomed!
    }

    uint256 tempAmount;

    if (i == 2) {
      tempAmount = redTulipRewardAmount(garden);
      _token[0].contractMint(msg.sender, tempAmount);
      _tulipToken[i][garden].periodFinish[msg.sender] = now.add(7 * _timeScale);
    } 
    else {
      if(i == 1){
        if(_tulipToken[i][garden].forSeeds[msg.sender]){
          tempAmount = pinkTulipRewardAmount(garden);
          _token[0].contractMint(msg.sender, tempAmount);
          _tulipToken[i][garden].periodFinish[msg.sender] = now.add(7 * _timeScale);
        }
        else{
          tempAmount = _tulipToken[i][garden].planted[msg.sender].div(100);
          operationBurnMint(i, garden, tempAmount);
          zeroHoldings(i, garden);
        }
      }
      else{
        tempAmount = _tulipToken[i][garden].planted[msg.sender];
        operationBurnMint(i, garden, tempAmount);
        zeroHoldings(i, garden);
      }   
    }
 
    _totalGrowing[i] = _totalGrowing[i].sub(_tulipToken[i][garden].planted[msg.sender]);

    emit RewardPaid(msg.sender, tempAmount);
  }
  
  function setRewardDurationSeeds(uint8 garden) internal returns (bool) {

    uint256 timeSinceEpoch = ((now - _epochBlockStart) / 60 / 60 / 24 / 30) + 1;

    if (timeSinceEpoch >= 7) {
      _tulipToken[0][garden].periodFinish[msg.sender] = now.add(7 * _timeScale);
      return true;
    } else {
      _tulipToken[0][garden].periodFinish[msg.sender] = now.add(
        timeSinceEpoch.mul(1 * _timeScale)
      );
      return true;
    }
  }


  function redTulipRewardAmount(uint8 garden) internal view returns (uint256) {

    uint256 timeSinceEpoch = (now - _tulipToken[garden][2].periodFinish[msg.sender].sub(7 * _timeScale)).div(60).div(60).div(24);
    uint256 amountWeeks = timeSinceEpoch.div(7);
    uint256 value;

    for (uint256 i = amountWeeks; i != 0; i--) {
      uint256 tokens = 10;
      value = value.add(tokens.mul(_decimalConverter));
    }
    
    return value * _tulipToken[2][garden].planted[msg.sender];
  }

  function pinkTulipRewardAmount(uint8 garden) internal view returns (uint256) {

    uint256 timeSinceEpoch = (now - _tulipToken[1][garden].periodFinish[msg.sender].sub(7 * _timeScale)).div(60).div(60).div(24);
    uint256 amountWeeks = timeSinceEpoch.div(7);
    uint256 value;

    for (uint256 i = amountWeeks; i != 0; i--) {
      uint256 tokens = 10;

      value = value.add(tokens.mul(_decimalConverter).div(500));
    }
    
    return value * _tulipToken[1][garden].planted[msg.sender];
  }

  event Staked(address indexed user, uint256 amount); //add timestamps
  event Withdrawn(address indexed user, uint256 amount);
  event RewardPaid(address indexed user, uint256 reward);
  event Decomposing(address indexed user, uint256 amount);
  event ClaimedDecomposing(address indexed user, uint256 reward);
}