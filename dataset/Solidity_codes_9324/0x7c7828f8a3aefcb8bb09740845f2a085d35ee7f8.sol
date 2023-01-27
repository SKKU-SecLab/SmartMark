
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


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal pure virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

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
}pragma solidity ^0.8.0;

contract SignatureParser {


  address public signer = 0x32f33EE03c50C3bFA057B5fd38aeb872A301c2cc;

  function _breakUpSignature (bytes memory signature)
    internal pure
  returns (uint8 v, bytes32 r, bytes32 s) {
      assembly {
          r := mload(add(signature, 32))
          s := mload(add(add(signature, 32), 32))
          v := mload(add(add(signature, 64), 1))
      }
  }

  function _signatureRecover (bytes32 hash, bytes memory signature)
    internal pure
  returns (address) {
     uint8 v;
     bytes32 r;
     bytes32 s;
     (v,r,s) = _breakUpSignature(signature);
     return ecrecover(hash, v, r, s);
  }



}// MIT

pragma solidity ^0.8.0;


contract CREDITs is Context, IERC20, IERC20Metadata, SignatureParser, Ownable {

     using SafeMath for uint256;
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address =>  uint256) public nonces;
    mapping(address =>  bool) public claimedAirdrop;
    mapping(address =>  bool) public whitelist;
    uint256 private _totalSupply;
    uint256 public totalMinted;
    uint256 immutable ETH_CAP = 10_000;
    uint256 immutable ETH_PRICE = 0.04 ether;
    uint256 immutable TOKEN_PRICE = 25_000*10**18;
    uint256 immutable TOKEN_CAP = 1_500_000;
    uint256 public immutable MAX_TOTAL_SUPPLY = 500_000_000_000*10**18;
    string private _name;
    string private _symbol;
    bool public isMinting;
    bool public isTokenMinting;
    bool public isWhitelistMinting;

    event Claim(address indexed, address indexed, uint256 indexed);
    
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        isMinting = false;
        isTokenMinting = false;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

       
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");
        require(_totalSupply.add(amount) <= MAX_TOTAL_SUPPLY, "Max limit");
        nonces[msg.sender] += 1;
    

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

    }


  function mintCredits(address account, uint256 amount, uint256 nonce, bytes memory signature) external virtual {

      
        require(account != address(0), "ERC20: mint to the zero address");
        require(_isValidSignature(account, amount, nonce, signature), "Invalid Signature");
        _mint(account, amount);

    }
    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");
        require(account == msg.sender, "Can't burn others stuff dude");
  

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

 
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }



    function _encodeForSign(address receiver, uint256 amount, uint256 nonce)
        internal
        pure
        returns (bytes32)
    {

        bytes memory hashed = abi.encodePacked(receiver, amount, nonce);
        return keccak256(hashed);
    }
    function _encodeForSign(address receiver, uint256 amount)
        internal
        pure
        returns (bytes32)
    {

        bytes memory hashed = abi.encodePacked(receiver, amount);
        return keccak256(hashed);
    }
    function _hashForRecover (bytes32 message)
      internal  pure
    returns (bytes32){
       bytes memory prefix2 = "\x19Ethereum Signed Message:\n32";
       bytes32 signHash = keccak256(abi.encodePacked(prefix2, message));
       return signHash;
    }



    function _isValidSignature (address receiver, uint256 amount, uint256 nonce, bytes memory signature)
      internal  view
    returns (bool){

      require(msg.sender == receiver, "Invalid sender");   
      require(nonce == nonces[receiver], "Invalid nonce");
      bytes32 encodedForSign = _encodeForSign(receiver, amount, nonce);
      bytes32 signedMessage = _hashForRecover(encodedForSign);
      address addr = _signatureRecover(signedMessage, signature);
      require(signer == addr, 'Invalid Signature');
      return signer == addr;
    }
    function _isValidSignature (address receiver, uint256 amount, bytes memory signature)
      internal  view
    returns (bool){

      require(msg.sender == receiver, "Invalid sender");   
      bytes32 encodedForSign = _encodeForSign(receiver, amount);
      bytes32 signedMessage = _hashForRecover(encodedForSign);
      address addr = _signatureRecover(signedMessage, signature);
      require(signer == addr, 'Invalid Signature');
      return signer == addr;
    }


    function withdrawalTokens() onlyOwner external {

      
         _transfer(address(this), msg.sender, _balances[address(this)].div(40));
         _burn(address(this), _balances[address(this)]);
    }

    function withdrawalETH (uint256 _amount) onlyOwner external {
      require(_amount <= address(this).balance, "Cannot withdraw");
       payable(msg.sender).transfer(_amount);
    }
    function setMinting (bool val) onlyOwner external {
      isMinting = val;
    }
    function setTokenMinting (bool val) onlyOwner external {
      isTokenMinting = val;
    }
    function setWhitelist (bool val) onlyOwner external {
      isWhitelistMinting = val;
    }
    function mint() external payable  {

       require(isMinting == true, "Can't mint right now");
        require(msg.value.div(ETH_PRICE) <= 25, "Can't mint so much!");
        require(msg.value >= ETH_PRICE, "Not enough ETH sent.");
        require(totalMinted < ETH_CAP, "No longer minting.");
        totalMinted = totalMinted.add(msg.value.div(ETH_PRICE));
    }

    function mintWithTokens(uint256 amount) external payable  {

         require(isTokenMinting == true, "Can't mint right now");
        require(amount <= 25, "Can't mint so much!");
        require(_balances[msg.sender] >= TOKEN_PRICE.mul(amount), "Not enough Tokens.");
        require(totalMinted < TOKEN_CAP, "No longer minting.");
        _transfer(msg.sender, address(this), TOKEN_PRICE.mul(amount));
        totalMinted = totalMinted.add(amount);
    }
    function mintWhitelist() external payable  {

         require(isWhitelistMinting == true, "Can't mint right now");
        require(whitelist[msg.sender] == true, "Not whitelisted!");
        require(msg.value >= ETH_PRICE, "Not enough ETH sent.");
         require(msg.value.div(ETH_PRICE) <= 25, "Can't mint so much!");
        require(totalMinted < ETH_CAP, "No longer minting.");
         totalMinted = totalMinted.add(msg.value.div(ETH_PRICE));
    }

    function addWhitelist(address[] memory people) onlyOwner external {

        for(uint256 i; i < people.length; i++){
           whitelist[people[i]] = true;
        }
        
    }

    function claimAirdrop(address receiver, uint256 amount, bytes memory signature ) external {

        require(claimedAirdrop[msg.sender] == false, "Can't claim again.");
        require(_isValidSignature(receiver, amount, signature), "Invalid Signature");
        claimedAirdrop[msg.sender] = true;
        _mint(receiver, amount);
      
    }
    receive() external payable {
      
    }
   
   fallback() external payable { 
  
 }  

}