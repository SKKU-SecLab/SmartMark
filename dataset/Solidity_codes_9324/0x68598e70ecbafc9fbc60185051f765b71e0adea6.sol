
pragma solidity ^0.8.0;

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

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
}// MIT

pragma solidity ^0.8.0;




abstract contract SamotNFT {
    function ownerOf(uint256 tokenId) public view virtual returns (address);

    function balanceOf(address owner)
        public
        view
        virtual
        returns (uint256 balance);
}

contract SamotToken is ERC20, Ownable {
    using SafeMath for uint256;

    address constant WALLET1 = 0xffe5CBCDdF2bd1b4Dc3c00455d4cdCcf20F77587;
    address constant WALLET2 = 0xD9CC8af4E8ac5Cb5e7DdFffD138A58Bac49dAEd5;
    address stakingAddress;
    address[] burnlistAddr;
    address[] claimlistAddr;

    uint256 public maxToMintPerNFT = 100;
    uint256 public maxToMint = 50000;
    uint256 public maxSupply = 5000000;
    uint256 public mintPrice = 200000000000000;
    uint256 multiplier = 2;

    bool public preSaleIsActive = false;
    bool public saleIsActive = false;

    SamotNFT nft;

    mapping(address => bool) public burnlist;
    mapping(address => bool) public claimlist;

    constructor(
        string memory _name,
        string memory _symbol,
        address _nftAddress
    ) ERC20(_name, _symbol) {
        nft = SamotNFT(_nftAddress);
    }

    modifier onlyBurnersOrOwner() {
        require(
            isBurnlisted(msg.sender) || owner() == _msgSender(),
            "Only callable by Burner Contract or Owner"
        );
        _;
    }

    modifier onlyClaimersOrOwner() {
        require(
            isClaimlisted(msg.sender) || owner() == _msgSender(),
            "Only callable by Claimer Contract or Owner"
        );
        _;
    }

    function addAddressToBurnlist(address addr)
        public
        onlyOwner
        returns (bool success)
    {
        require(!isBurnlisted(addr), "Already burnlisted");
        burnlist[addr] = true;
        success = true;
    }

    function addAddressesToBurnlist(address[] memory addrs)
        public
        onlyOwner
        returns (bool success)
    {
        burnlistAddr = addrs;
        for (uint256 i = 0; i < burnlistAddr.length; i++) {
            addAddressToBurnlist(burnlistAddr[i]);
        }
        success = true;
    }

    function isBurnlisted(address addr)
        public
        view
        returns (bool isBurnListed)
    {
        return burnlist[addr];
    }

    function removeAddressFromBurnlist(address addr)
        public
        onlyOwner
        returns (bool success)
    {
        require(isBurnlisted(addr), "Not burnlisted");
        burnlist[addr] = false;
        success = true;
    }

    function addAddressToClaimlist(address addr)
        public
        onlyOwner
        returns (bool success)
    {
        require(!isClaimlisted(addr), "Already claimlisted");
        claimlist[addr] = true;
        success = true;
    }

    function addAddressesToClaimlist(address[] memory addrs)
        public
        onlyOwner
        returns (bool success)
    {
        claimlistAddr = addrs;
        for (uint256 i = 0; i < claimlistAddr.length; i++) {
            addAddressToClaimlist(claimlistAddr[i]);
        }
        success = true;
    }

    function isClaimlisted(address addr)
        public
        view
        returns (bool isClaimListed)
    {
        return claimlist[addr];
    }

    function removeAddressFromClaimlist(address addr)
        public
        onlyOwner
        returns (bool success)
    {
        require(isClaimlisted(addr), "Not claimlisted");
        claimlist[addr] = false;
        success = true;
    }

    function burn(address _from, uint256 _amount) external onlyBurnersOrOwner {
        _burn(_from, _amount);
    }

    function claim(address _claimer, uint256 _reward)
        external
        onlyClaimersOrOwner
    {
        require(
            ((totalSupply().add(_reward)).div(10**18)) <= maxSupply,
            "Exceeds token limit."
        );
        _mint(_claimer, _reward);
    }

    function flipSaleState() public onlyOwner {
        saleIsActive = !saleIsActive;
    }

    function flipPreSaleState() public onlyOwner {
        preSaleIsActive = !preSaleIsActive;
    }

    function setStakingContract(address _stakingAddress) external onlyOwner {
        stakingAddress = _stakingAddress;
    }

    function setNFTContract(address _nftAddress) external onlyOwner {
        nft = SamotNFT(_nftAddress);
    }

    function setMintPrice(uint256 _price) external onlyOwner {
        mintPrice = _price;
    }

    function setMaxSupply(uint256 _maxSupply) external onlyOwner {
        maxSupply = _maxSupply;
    }

    function setMaxToMint(uint256 _maxToMint) external onlyOwner {
        maxToMint = _maxToMint;
    }

    function setMaxToMintPerNFT(uint256 _maxToMint) external onlyOwner {
        maxToMintPerNFT = _maxToMint;
    }

    function setMultiplier(uint256 _multiplier) external onlyOwner {
        multiplier = _multiplier;
    }

    function getPrice() public view returns (uint256) {
        uint256 currentSupply = totalSupply().div(10**18);
        require(currentSupply <= maxSupply, "Sold out.");
        if (currentSupply >= 4000000) {
            return mintPrice.mul(multiplier**3);
        } else if (currentSupply >= 3000000) {
            return mintPrice.mul(multiplier**2);
        } else if (currentSupply >= 2000000) {
            return mintPrice.mul(multiplier);
        } else {
            return mintPrice;
        }
    }

    function mint(uint256 numberOfTokens) public payable {
        uint256 currentSupply = totalSupply().div(10**18);
        require(saleIsActive, "Sale is not active.");
        require(numberOfTokens > 0, "numberOfTokens cannot be 0");
        require(
            currentSupply.add(numberOfTokens) <= maxSupply,
            "Exceeds token limit."
        );
        uint256 balance = balanceOf(msg.sender).div(10**18);
        if (preSaleIsActive) {
            require(
                getPrice().mul(numberOfTokens) <= msg.value,
                "ETH sent is incorrect."
            );
            require(
                nft.balanceOf(msg.sender) > 0,
                "You must own at least one Samot NFT to participate in the pre-sale."
            );
            require(
                numberOfTokens <=
                    maxToMintPerNFT.mul(nft.balanceOf(msg.sender)),
                "Exceeds limit for pre-sale."
            );
            require(
                balance.add(numberOfTokens) <=
                    maxToMintPerNFT.mul(nft.balanceOf(msg.sender)),
                "Exceeds limit for pre-sale."
            );
        } else {
            require(
                getPrice().mul(numberOfTokens) <= msg.value,
                "ETH sent is incorrect."
            );
            require(
                numberOfTokens <= maxToMint,
                "Exceeds limit for public sale."
            );
            require(balance <= maxToMint, "Exceeds limit for public sale.");
        }
        _mint(msg.sender, numberOfTokens.mul(10**18));
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        uint256 wallet1Balance = balance.mul(10).div(100);
        uint256 wallet2Balance = balance.mul(85).div(100);
        payable(WALLET1).transfer(wallet1Balance);
        payable(WALLET2).transfer(wallet2Balance);
        payable(msg.sender).transfer(
            balance.sub(wallet1Balance.add(wallet2Balance))
        );
    }
}