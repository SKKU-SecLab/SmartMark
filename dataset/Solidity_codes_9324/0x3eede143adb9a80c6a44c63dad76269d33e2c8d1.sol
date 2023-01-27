


pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}




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
}




pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




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
}




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
}




pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}




pragma solidity ^0.8.0;




contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
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

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}



pragma solidity ^0.8.0;

interface ILeedoNft {
    
    function balanceOf(address owner) external view returns (uint balance);
    function ownerOf(uint tokenId) external view returns (address owner);
    function getConsonants(uint tokenId) external view returns(string[3] memory);
    function getGenes(uint tokenId) external view returns (uint8[8] memory);
    function getConsonantsIndex(uint tokenId) external view returns (uint8[3] memory);
}

interface ILeedoNftVault {
    
    function ownerOf(uint tokenId) external view returns (address owner);
    function lastBlocks(address addr) external view returns (uint black);
}

contract LeedoERC20 is ERC20, Ownable, ReentrancyGuard {
    using SafeMath for uint;

    bool public daoInitialized = false;
    address private _daoAddr;
    address private _nftAddr;
    address private _nftVaultAddr;
    address private _raffleAddr;
    uint public claimBlocksRequired = 200000; //about 31 days
    uint private _decimal = 10**uint(decimals());    
    uint public rafflePrize = 100000 * 20;
    uint public nftMintableWeiAmount = (138000000 - 21000000) * _decimal; //117,000,000 * decimal
    uint public daoMintableAmount = 175000000 + 70000000 + 70000000 + 210000000; //525,000,000
    uint public marketingMintableAmount = 35000000;
    uint public daoTimelock;
    uint public timeLockDuration = 24 hours;
    uint public season = 0;

    mapping(uint => mapping(uint => bool)) public claims; //season => (tokendId => bool)
    mapping(uint => uint) public claimCount; //season => count

    modifier onlyDao() {
        require(_daoAddr == _msgSender(), "ERC20: caller is not the DAO address!");
        _;
    } 
    
    modifier onlyNftVault() {
        require(_nftVaultAddr == _msgSender(), "ERC20: caller is not the NftVault address!");
        _;
    }         
    
    constructor(address _nftAddress, address _raffleAddress) ERC20('LEEDO Project ERC20', 'LEEDO') {
        _nftAddr = _nftAddress;
        _raffleAddr = _raffleAddress;
    }    

    function mintRafflePrize() external onlyOwner returns (bool) {
        require(_safeMint(_raffleAddr, rafflePrize.mul(_decimal)), 'ERC20: Minting failed');
        rafflePrize = 0;
        return true;
    }
    
    function setNftVaultAddr(address _vault) external onlyOwner {
        _nftVaultAddr = _vault;
    }
    
    function mintNftVaultRewards(address _to, uint _amount) external onlyNftVault returns (bool) {
        require(_amount <= nftMintableWeiAmount, 'ERC20: Amount is more than allowed');
        nftMintableWeiAmount = nftMintableWeiAmount.sub(_amount);
        require(_safeMint(_to, _amount), 'ERC20: Minting failed');
        return true;
    }
    
    function mintDev(address _devAddr, uint _amount) external onlyOwner returns (bool) {
        require(_amount <= marketingMintableAmount, 'ERC20: Amount is more than allowed');
        marketingMintableAmount = marketingMintableAmount.sub(_amount);
        require(_safeMint(_devAddr, _amount.mul(_decimal)), 'ERC20: Minting failed');
        return true;
    }

    function initializeDao(address _daoAddress) public onlyOwner {
        require(!daoInitialized, 'ERC20: DAO is already initialized');
        _daoAddr = _daoAddress;
        daoInitialized = true;
    }
    
    function setDaoAddr(address _daoAddress) public onlyDao {
        require(daoInitialized, 'ERC20: DAO is not initialized');
        _daoAddr = _daoAddress;
    }    

    function unlockDaoMint() public onlyDao {
        daoTimelock = block.timestamp + timeLockDuration;
    }

    function daoMint(uint _amount) public onlyDao returns (bool) {
        require(daoTimelock != 0 && daoTimelock <= block.timestamp, 'ERC20: Wait _daoTimelock passes');
        require(_amount <= daoMintableAmount, 'ERC20:  Amount is more than allowed');
        daoMintableAmount = daoMintableAmount.sub(_amount); 
        require(_safeMint(_daoAddr, _amount.mul(_decimal)), 'ERC20: Minting failed');
        daoTimelock = 0;
        return true;
    }
    
    function daoSetSeason(uint _season) external onlyDao {
        season = _season;
    }    
    
    function setDaoMintable(uint _amount) external onlyDao {
        daoMintableAmount = _amount;
    }

    function setNftAddress(address _newAddress) external onlyDao {
        _nftAddr = _newAddress;
    }

    function setNftVaultAddrByDao(address _vault) external onlyDao {
        _nftVaultAddr = _vault;
    }    
    
    function _safeMint(address _to, uint _amount) private nonReentrant returns (bool) {
        _mint(_to, _amount); //in wei
        return true;
    }
    
    function claim(uint[] calldata _tokenIds) external returns (uint) {
        require(_tokenIds.length <= 20, 'ERC20: maximum bulk claims is 20 cards per tx');
        ILeedoNftVault sNFT = ILeedoNftVault(_nftVaultAddr); //only Staked NFT can claim  
        require(sNFT.lastBlocks(_msgSender()) + claimBlocksRequired < block.number, 'ERC20: does not meet claimBlockRequired');
        uint total;
        for (uint i=0; i<_tokenIds.length; i++) {
            uint tokenId = _tokenIds[i];
            require(tokenId > 0 && tokenId < 9577, 'ERC20: tokenId is invalid'); 
            require(claims[season][tokenId] == false, 'ERC20: tokenId is already claimed');
            require(_msgSender() == sNFT.ownerOf(tokenId), 'ERC20: Only Staked NFT owner can claim');
            
            uint amount = calcRewards(tokenId); 
            claims[season][tokenId] = true;        
            claimCount[season] += 1;
            total = total.add(amount);
        }
        require(_safeMint(_msgSender(), total.mul(_decimal)), 'SquidERC20: Minting failed');      
        return total;
    }    
    
    function calcRewards(uint _tokenId) public view returns (uint) {        
        ILeedoNft NFT = ILeedoNft(_nftAddr);        
        uint8[3] memory consonants = NFT.getConsonantsIndex(_tokenId);
        uint8[8] memory genes = NFT.getGenes(_tokenId);        
        
        uint geneSSum;
        uint left = consonants[0];
        uint center = consonants[1];
        uint right = consonants[2];
        uint consFactor;
        uint timeFactor = 141 * (16000 - claimCount[season]) / 9000; //1 -> 250  9576 -> 100 
        uint tokenIdFactor;
        if (_tokenId <= 100) {
            tokenIdFactor = 200;
        } else if (_tokenId <= 1000) {
            tokenIdFactor = 150;
        } else {
            tokenIdFactor = 100;
        }
        
        for (uint i=0; i<8; i++) {
            geneSSum += uint(genes[i]).mul(uint(genes[i]));
        }
        if (geneSSum < 100) {
            geneSSum = 100;
        } else if (geneSSum > 648) {
            geneSSum = 648;
        }
        if (timeFactor < 100) {
            timeFactor = 100;
        }

        if (left == 7 && center == 14 && right == 4) { 
            consFactor = 2;
        } else if (left == center && left == center && center == right) {
            consFactor = 10;
        } else if (left == 7 && left == 4 && center == 14) {            
            consFactor = 5;
        } else if (left == 4 && left == 7 && center == 14) {                        
            consFactor = 5;
        } else if (left == 4 && left == 14 && center == 7) {                        
            consFactor = 5;
        } else if (left == 14 && left == 7 && center == 4) {                                
            consFactor = 5;
        } else if (left == 14 && left == 4 && center == 7) {                                                
            consFactor = 5;
        } else if ((left == 4 && left == center) || (left == 4 && left == right)) {            
            consFactor = 3;
        } else if ((left == 14 && left == center) || (left == 14 && left == right)) {
            consFactor = 3;
        } else if ((left == 7 && left == center) || (left == 7 && left == right)) {
            consFactor = 3;
        } else if (center == 4 && center == right )  {            
            consFactor = 3;
        } else if (center == 14 && center == right ) {                    
            consFactor = 3;
        } else if (center == 7 && center == right ) {                                
            consFactor = 3;            
        } else {
            consFactor = 1;
        }
        return  (geneSSum * tokenIdFactor * consFactor * timeFactor) / 2000;  
    }
    
    function daoAddr() external view returns (address) {
        return _daoAddr;
    }
    
    function nftAddr() external view returns (address) {
        return _nftAddr;
    }
    
    function nftVaultAddr() external view returns (address) {
        return _nftVaultAddr;
    }
    
    function raffleAddr() external view returns (address) {
        return _raffleAddr;
    }
}