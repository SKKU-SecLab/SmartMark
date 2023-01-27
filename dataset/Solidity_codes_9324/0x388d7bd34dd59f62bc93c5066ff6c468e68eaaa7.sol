pragma solidity >=0.8.0 <0.9.0;

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
pragma solidity >=0.8.0 <0.9.0;


contract GoldenTicket is Context, IERC20, Ownable {


    uint256 public constant MAX_SUPPLY = 1000;
    uint256 constant a_times_sig = 1000;
    uint256 constant SIG_DIGITS = 4;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string public name;
    string public symbol;
    uint8 public decimals;
    address private _owner;

    address public nftrAddress;

    uint256 public reserve = 0;
    uint256 public accumulatedFees = 0;
    uint256 private numberTicketsFundsClaimedFor = 0;

    event GoldenTicketsMinted(
        address indexed to,
        uint256 numTickets,
        uint256 pricePaid,
        uint256 nextMintPrice,
        uint256 nextBurnPrice,
        uint256 ticketSupply,
        uint256 mintFee,
        uint256 newReserve
    );

    event GoldenTicketsBurned(
        address indexed to,
        uint256 numTickets,
        uint256 burnProceeds,
        uint256 nextMintPrice,
        uint256 nextBurnPrice,
        uint256 ticketSupply,
        uint256 newReserve
    );


    constructor (address ownerin, string memory namein, string memory symbolin) {
        name = namein;
        symbol = symbolin;
        _setupDecimals(0);
        _owner = ownerin;
    }

    function owner() public view override returns (address) {

        return _owner;
    }

    function _setupDecimals(uint8 decimals_) internal {

        decimals = decimals_;
    }    

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }


    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address ownerin, address spender) public view virtual override returns (uint256) {

        return _allowances[ownerin][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        if (_msgSender() != nftrAddress) {
            require(_allowances[sender][_msgSender()] >= amount,"ERC20: transfer amount exceeds allowance");
            _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        }
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        require(_allowances[_msgSender()][spender] >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
    }

    function setNFTRegistryAddress(address _nftrAddress) public onlyOwner {

        require(nftrAddress == address(0), "Already set");
        
        nftrAddress = _nftrAddress;
    }

    function getReserve() public view returns (uint256) {

        return reserve;
    }    

    function getAccumulatedFees() public view returns (uint256) {

        return accumulatedFees;
    }   

    function numberUsedTickets() public view returns (uint256 nftrTicketBalance) {

        if(nftrAddress == address(0)) {
            nftrTicketBalance = 0;
        }
        else {
            nftrTicketBalance = balanceOf(nftrAddress);
        }
    }

    function getOrphanedTicketFunds() public view returns (uint256) {

        uint256 unclaimedOrphanFunds = 0;
        if (nftrAddress != address(0)) { // NFTR contract has already been set and could have GTKs in its balance
            uint256 nftrTicketBalance = balanceOf(nftrAddress);
            uint256 orphanFundsWithdrawn = getOrphanFundsForUsedTicketNumber(numberTicketsFundsClaimedFor);
            uint256 totalOrphanFunds = getOrphanFundsForUsedTicketNumber(nftrTicketBalance);
            unclaimedOrphanFunds = totalOrphanFunds - orphanFundsWithdrawn;
        }
        return unclaimedOrphanFunds;
    }

    function getSingleMintPrice(uint256 mintNumber) public pure returns (uint256 price) {

        require(mintNumber <= MAX_SUPPLY, "Maximum supply exceeded");
        require(mintNumber > 0, "Minting a supply of 0 tickets isn't valid");

        uint256 dec = 10 ** SIG_DIGITS;
        price = a_times_sig + (mintNumber * (mintNumber));

        price = price * (1 ether) / (dec);
    }

    function currentMintPrice(uint256 quantity) public view returns (uint256 price) {

        uint256 dec = 10 ** SIG_DIGITS;
        price = 0;
        uint256 mintNumber;
        for (uint i = 0; i < quantity; i++) {
            mintNumber = totalSupply() + (i + 1);
            price += a_times_sig + (mintNumber * (mintNumber));
        }
        price = price * (1 ether) / (dec);
    }
 
    function getSingleBurnPrice(uint256 supply) public pure returns (uint256 price) {

        if (supply == 0) return 0;
        uint256 mintPrice = getSingleMintPrice(supply);
        price = mintPrice * (90) / (100);  // 90 % of mint price of last minted ticket (i.e. current supply)
    }    

    function currentBurnPrice(uint256 quantity) public view returns (uint256 price) {

        if (totalSupply() == 0) return 0;
        if (quantity > totalSupply()) return 0;
        uint256 mintPrice;
        for (uint i = 0; i < quantity; i++) {
            mintPrice += getSingleMintPrice(totalSupply() - i);
        }
        price = mintPrice * (90) / (100);  // 90 % of mint price of last minted ticket (i.e. current supply)
    }  

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply + (amount);
        _balances[account] = _balances[account] + (amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        require(_balances[account] >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = _balances[account] - amount;
        _totalSupply = _totalSupply - (amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address ownerin, address spender, uint256 amount) internal virtual {

        require(ownerin != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[ownerin][spender] = amount;
        emit Approval(ownerin, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function mintTickets(uint256 quantity)
        public
        payable
        returns (uint256)
    {

        require(quantity > 0, "Can't mint 0 Golden Tickets");
        require(_totalSupply + quantity <= MAX_SUPPLY, "That quantity of tickets takes supply over max supply");
        uint256 oldSupply = _totalSupply;
        uint256 mintPrice = 0;
        for (uint i = 0; i < quantity; i++) {
            mintPrice += getSingleMintPrice(oldSupply + (i + 1));
        }
        
        require(msg.value >= mintPrice, "Insufficient funds");

        uint256 newSupply = _totalSupply + (quantity);

        uint256 reserveCut = 0;
        for (uint i = 0; i < quantity; i++) {
            reserveCut += getSingleBurnPrice(newSupply - i);
        }
        reserve = reserve + (reserveCut);
        accumulatedFees = accumulatedFees + (mintPrice) - (reserveCut);

        _mint(msg.sender,  quantity);

        _refundSender(mintPrice, msg.value);

        emit GoldenTicketsMinted(msg.sender, quantity, mintPrice, getSingleMintPrice(newSupply + (1)), getSingleBurnPrice(newSupply), newSupply, mintPrice - (reserveCut), reserve);
        
        return newSupply;
    }    

    function _refundSender(uint256 mintPrice, uint256 msgValue) internal {

        if (msgValue - (mintPrice) > 0) {
            (bool success, ) =
                msg.sender.call{value: msgValue - (mintPrice)}("");
            require(success, "Refund failed");
        }
    }

    function burnTickets(uint256 minimumSupply, uint256 quantity) public returns (uint256) {

        uint256 oldSupply = _totalSupply;
        require(oldSupply >= minimumSupply, 'Min supply not met');
        require(quantity > 0, "Can't burn 0 Golden Tickets");
        require(quantity <= _totalSupply, "Can't burn more tickets than total supply");

        uint256 burnPrice = 0;
        for (uint i = 0; i < quantity; i++) {
            burnPrice += getSingleBurnPrice(oldSupply - i);
        }
        uint256 newSupply = _totalSupply - (quantity);

        reserve = reserve - (burnPrice);

        _burn(msg.sender, quantity);

        (bool success, ) = msg.sender.call{value: burnPrice}("");
        require(success, "Burn payment failed");

        emit GoldenTicketsBurned(msg.sender, quantity, burnPrice, getSingleMintPrice(oldSupply - quantity + 1), getSingleBurnPrice(newSupply), newSupply, reserve);

        return newSupply;
    }     

    function getOrphanFundsForUsedTicketNumber(uint256 ticketNumber) internal pure returns (uint256 _orphanFunds) { 

        _orphanFunds = 9 * ticketNumber * 10 ** 16 + ticketNumber * (ticketNumber + 1) * (2 * ticketNumber + 1) * 9 / 6 * 10 ** 13;
    } 

    function withdraw() public onlyOwner {

        uint256 unclaimedOrphanFunds = 0;
        if (nftrAddress != address(0)) { // NFTR contract has already been set and could have GTs in its balance
            uint256 nftrTicketBalance = balanceOf(nftrAddress);
            uint256 orphanFundsWithdrawn = getOrphanFundsForUsedTicketNumber(numberTicketsFundsClaimedFor);
            uint256 totalOrphanFunds = getOrphanFundsForUsedTicketNumber(nftrTicketBalance);
            unclaimedOrphanFunds = totalOrphanFunds - orphanFundsWithdrawn;
            numberTicketsFundsClaimedFor = nftrTicketBalance;
        }
        uint256 withdrawableFunds = accumulatedFees + (unclaimedOrphanFunds);
        accumulatedFees = 0;
        (bool success, ) = msg.sender.call{value: withdrawableFunds}("");
        require(success, "Withdraw failed");
    } 

}