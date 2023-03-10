


pragma solidity 0.5.10;


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

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}


pragma solidity ^0.5.0;


contract PauserRole {

    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {

        require(isPauser(msg.sender), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {

        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {

        _addPauser(account);
    }

    function renouncePauser() public {

        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {

        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {

        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}


pragma solidity ^0.5.0;


contract Pausable is PauserRole {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
        _;
    }

    function pause() public onlyPauser whenNotPaused {

        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyPauser whenPaused {

        _paused = false;
        emit Unpaused(msg.sender);
    }
}


pragma solidity 0.5.10;





interface ERC20 {

    function totalSupply() external view returns (uint256);

    function transfer(address to, uint tokens) external returns (bool success);

    function transferFrom(address from, address to, uint256 value) external returns (bool success);

    function totalShares() external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256 balance);

}


contract ShareDispenser is Ownable, Pausable {

    constructor(
        address initialXCHFContractAddress,
        address initialDSHSContractAddress,
        address initialusageFeeAddress,
        address initialBackendAddress
        ) public {

        require(initialXCHFContractAddress != address(0), "XCHF does not reside at address 0!");
        require(initialDSHSContractAddress != address(0), "DSHS does not reside at address 0!");
        require(initialusageFeeAddress != address(0), "Usage fee address cannot be 0!");

        XCHFContractAddress = initialXCHFContractAddress;
        DSHSContractAddress = initialDSHSContractAddress;
        usageFeeAddress = initialusageFeeAddress;
        backendAddress = initialBackendAddress;
    }


    function () external payable {
        revert("This contract does not accept Ether.");
    }

    using SafeMath for uint256;


    address public XCHFContractAddress;     // Address where XCHF is deployed
    address public DSHSContractAddress;     // Address where DSHS is deployed
    address public usageFeeAddress;         // Address where usage fee is collected
    address public backendAddress;          // Address used by backend server (triggers buy/sell)

    uint256 public usageFeeBSP  = 0;       // 0.9% usage fee (10000 basis points = 100%)
    uint256 public minVolume = 1;          // Minimum number of shares to buy/sell

    uint256 public minPriceInXCHF = 200*10**18; // Minimum price
    uint256 public maxPriceInXCHF = 600*10**18; // Maximum price
    uint256 public initialNumberOfShares = 400; //Price slope (TBD)

    bool public buyEnabled = true;
    bool public sellEnabled = true;


    event XCHFContractAddressSet(address newXCHFContractAddress);
    event DSHSContractAddressSet(address newDSHSContractAddress);
    event UsageFeeAddressSet(address newUsageFeeAddress);

    event SharesPurchased(address indexed buyer, uint256 amount, uint256 price, uint256 nextPrice);
    event SharesSold(address indexed seller, uint256 amount, uint256 buyBackPrice, uint256 nextPrice);

    event TokensRetrieved(address contractAddress, address indexed to, uint256 amount);

    event UsageFeeSet(uint256 usageFee);
    event MinVolumeSet(uint256 minVolume);
    event MinPriceSet(uint256 minPrice);
    event MaxPriceSet(uint256 maxPrice);
    event InitialNumberOfSharesSet(uint256 initialNumberOfShares);

    event BuyStatusChanged(bool newStatus);
    event SellStatusChanged(bool newStatus);



    function buyShares(address buyer, uint256 numberOfSharesToBuy) public whenNotPaused() returns (bool) {


        require(buyEnabled, "Buying is currenty disabled");
        require(numberOfSharesToBuy >= minVolume, "Volume too low");

        require(msg.sender == buyer || msg.sender == backendAddress, "You do not have permission to trigger buying shares for someone else.");

        uint256 sharesAvailable = getERC20Balance(DSHSContractAddress);
        uint256 price = getCumulatedPrice(numberOfSharesToBuy, sharesAvailable);

        require(sharesAvailable >= numberOfSharesToBuy, "Not enough shares available");

        uint256 usageFee = price.mul(usageFeeBSP).div(10000);

        require(getERC20Available(XCHFContractAddress, buyer) >= price.add(usageFee), "Payment not authorized or funds insufficient");

        ERC20 DSHS = ERC20(DSHSContractAddress);
        ERC20 XCHF = ERC20(XCHFContractAddress);

        require(XCHF.transferFrom(buyer, usageFeeAddress, usageFee), "Usage fee transfer failed");
        require(XCHF.transferFrom(buyer, address(this), price), "XCHF payment failed");

        require(DSHS.transfer(buyer, numberOfSharesToBuy), "Share transfer failed");
        uint256 nextPrice = getCumulatedPrice(1, sharesAvailable.sub(numberOfSharesToBuy));
        emit SharesPurchased(buyer, numberOfSharesToBuy, price, nextPrice);
        return true;
    }


    function sellShares(address seller, uint256 numberOfSharesToSell, uint256 limitInXCHF) public whenNotPaused() returns (bool) {


        require(sellEnabled, "Selling is currenty disabled");
        require(numberOfSharesToSell >= minVolume, "Volume too low");

        require(msg.sender == seller || msg.sender == backendAddress, "You do not have permission to trigger selling shares for someone else.");

        uint256 XCHFAvailable = getERC20Balance(XCHFContractAddress);
        uint256 sharesAvailable = getERC20Balance(DSHSContractAddress);

        uint256 price = getCumulatedBuyBackPrice(numberOfSharesToSell, sharesAvailable);
        require(limitInXCHF <= price, "Price too low");

        require(XCHFAvailable >= price, "Reserves to small to buy back this amount of shares");

        require(getERC20Available(DSHSContractAddress, seller) >= numberOfSharesToSell, "Seller doesn't have enough shares");

        ERC20 DSHS = ERC20(DSHSContractAddress);
        ERC20 XCHF = ERC20(XCHFContractAddress);

        require(DSHS.transferFrom(seller, address(this), numberOfSharesToSell), "Share transfer failed");

        uint256 usageFee = price.mul(usageFeeBSP).div(10000);

        require(XCHF.transfer(usageFeeAddress, usageFee), "Usage fee transfer failed");
        require(XCHF.transfer(seller, price.sub(usageFee)), "XCHF payment failed");
        uint256 nextPrice = getCumulatedBuyBackPrice(1, sharesAvailable.add(numberOfSharesToSell));
        emit SharesSold(seller, numberOfSharesToSell, price, nextPrice);
        return true;
    }


    function getERC20Balance(address contractAddress) public view returns (uint256) {

        ERC20 contractInstance = ERC20(contractAddress);
        return contractInstance.balanceOf(address(this));
    }

    function getERC20Available(address contractAddress, address owner) public view returns (uint256) {

        ERC20 contractInstance = ERC20(contractAddress);
        uint256 allowed = contractInstance.allowance(owner, address(this));
        uint256 bal = contractInstance.balanceOf(owner);
        return (allowed <= bal) ? allowed : bal;
    }


    function getCumulatedPrice(uint256 amount, uint256 supply) public view returns (uint256) {

        uint256 cumulatedPrice = 0;
        if (supply <= initialNumberOfShares) {
            uint256 first = initialNumberOfShares.add(1).sub(supply);
            uint256 last = first.add(amount).sub(1);
            cumulatedPrice = helper(first, last);
        } else if (supply.sub(amount) >= initialNumberOfShares) {
            cumulatedPrice = minPriceInXCHF.mul(amount);
        } else {
            cumulatedPrice = supply.sub(initialNumberOfShares).mul(minPriceInXCHF);
            uint256 first = 1;
            uint256 last = amount.sub(supply.sub(initialNumberOfShares));
            cumulatedPrice = cumulatedPrice.add(helper(first,last));
        }

        return cumulatedPrice;
    }

    function getCumulatedBuyBackPrice(uint256 amount, uint256 supply) public view returns (uint256) {

        return getCumulatedPrice(amount, supply.add(amount)); // For symmetry reasons
    }


    function retrieveERC20(address contractAddress, address to, uint256 amount) public onlyOwner() returns(bool) {

        ERC20 contractInstance = ERC20(contractAddress);
        require(contractInstance.transfer(to, amount), "Transfer failed");
        emit TokensRetrieved(contractAddress, to, amount);
        return true;
    }


    function setXCHFContractAddress(address newXCHFContractAddress) public onlyOwner() {

        require(newXCHFContractAddress != address(0), "XCHF does not reside at address 0");
        XCHFContractAddress = newXCHFContractAddress;
        emit XCHFContractAddressSet(XCHFContractAddress);
    }

    function setDSHSContractAddress(address newDSHSContractAddress) public onlyOwner() {

        require(newDSHSContractAddress != address(0), "DSHS does not reside at address 0");
        DSHSContractAddress = newDSHSContractAddress;
        emit DSHSContractAddressSet(DSHSContractAddress);
    }

    function setUsageFeeAddress(address newUsageFeeAddress) public onlyOwner() {

        require(newUsageFeeAddress != address(0), "DSHS does not reside at address 0");
        usageFeeAddress = newUsageFeeAddress;
        emit UsageFeeAddressSet(usageFeeAddress);
    }

    function setBackendAddress(address newBackendAddress) public onlyOwner() {

        backendAddress = newBackendAddress;
    }


    function setUsageFee(uint256 newUsageFeeInBSP) public onlyOwner() {

        require(newUsageFeeInBSP <= 10000, "Usage fee must be given in basis points");
        usageFeeBSP = newUsageFeeInBSP;
        emit UsageFeeSet(usageFeeBSP);
    }

    function setMinVolume(uint256 newMinVolume) public onlyOwner() {

        require(newMinVolume > 0, "Minimum volume can't be zero");
        minVolume = newMinVolume;
        emit MinVolumeSet(minVolume);
    }

    function setminPriceInXCHF(uint256 newMinPriceInRappen) public onlyOwner() {

        require(newMinPriceInRappen > 0, "Price must be positive number");
        minPriceInXCHF = newMinPriceInRappen.mul(10**16);
        require(minPriceInXCHF <= maxPriceInXCHF, "Minimum price cannot exceed maximum price");
        emit MinPriceSet(minPriceInXCHF);
    }

    function setmaxPriceInXCHF(uint256 newMaxPriceInRappen) public onlyOwner() {

        require(newMaxPriceInRappen > 0, "Price must be positive number");
        maxPriceInXCHF = newMaxPriceInRappen.mul(10**16);
        require(minPriceInXCHF <= maxPriceInXCHF, "Minimum price cannot exceed maximum price");
        emit MaxPriceSet(maxPriceInXCHF);
    }

    function setInitialNumberOfShares(uint256 newInitialNumberOfShares) public onlyOwner() {

        require(newInitialNumberOfShares > 0, "Initial number of shares must be positive");
        initialNumberOfShares = newInitialNumberOfShares;
        emit InitialNumberOfSharesSet(initialNumberOfShares);
    }


    function buyStatus(bool newStatus) public onlyOwner() {

        buyEnabled = newStatus;
        emit BuyStatusChanged(newStatus);
    }

    function sellStatus(bool newStatus) public onlyOwner() {

        sellEnabled = newStatus;
        emit SellStatusChanged(newStatus);
    }


    function helper(uint256 first, uint256 last) internal view returns (uint256) {

        uint256 tempa = last.sub(first).add(1).mul(minPriceInXCHF);                                   // (l-m+1)*p_min
        uint256 tempb = maxPriceInXCHF.sub(minPriceInXCHF).div(initialNumberOfShares.sub(1)).div(2);  // (p_max-p_min)/(2(N-1))
        uint256 tempc = last.mul(last).add(first.mul(3)).sub(last).sub(first.mul(first)).sub(2);      // l*l+3*m-l-m*m-2)
        return tempb.mul(tempc).add(tempa);
    }

}


pragma solidity 0.5.10;

contract UniswapExchangeInterface {

    function tokenAddress() external view returns (address token);

    function factoryAddress() external view returns (address factory);

    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);

    function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) external returns (uint256, uint256);

    function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);

    function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);

    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);

    function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256 tokens_sold);

    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) external payable returns (uint256  tokens_bought);

    function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns (uint256  tokens_bought);

    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external payable returns (uint256  eth_sold);

    function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns (uint256  eth_sold);

    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256  eth_bought);

    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256  eth_bought);

    function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline) external returns (uint256  tokens_sold);

    function tokenToEthTransferOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) external returns (uint256  tokens_sold);

    function tokenToTokenSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address token_addr) external returns (uint256  tokens_bought);

    function tokenToTokenTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_bought);

    function tokenToTokenSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr) external returns (uint256  tokens_sold);

    function tokenToTokenTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_sold);

    function tokenToExchangeSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address exchange_addr) external returns (uint256  tokens_bought);

    function tokenToExchangeTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_bought);

    function tokenToExchangeSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address exchange_addr) external returns (uint256  tokens_sold);

    function tokenToExchangeTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_sold);

    bytes32 public name;
    bytes32 public symbol;
    uint256 public decimals;
    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(address _from, address _to, uint256 value) external returns (bool);

    function approve(address _spender, uint256 _value) external returns (bool);

    function allowance(address _owner, address _spender) external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function setup(address token_addr) external;

}







pragma solidity 0.5.10;

contract DispenserAdapter {


    IERC20 private currency;
    IERC20 private tradedToken;
    ShareDispenser private dispenser;
    UniswapExchangeInterface private uniswap;

    constructor(address currencyAddress, address tradedTokenAddress, address payable dispenserAddress, address uniswapAddress) public {
        currency = IERC20(currencyAddress);
        tradedToken = IERC20(tradedTokenAddress);
        dispenser = ShareDispenser(dispenserAddress);
        uniswap = UniswapExchangeInterface(uniswapAddress);
    }

    function getBuyPriceInXCHF(uint256 numberToBuy) public view returns (uint256) {

        uint256 supply = tradedToken.balanceOf(address(dispenser));
        uint256 priceInXCHF = dispenser.getCumulatedPrice(numberToBuy, supply);
        return priceInXCHF;
    }

    function getBuyPriceInWei(uint256 numberToBuy) public view returns (uint256) {

        uint256 priceInXCHF = getBuyPriceInXCHF(numberToBuy);
        uint256 priceInEther = uniswap.getEthToTokenOutputPrice(priceInXCHF);
        return priceInEther;
    }

    function buySharesWithEther(uint256 numberToBuy) public payable returns (bool) {

        uint256 priceInXCHF = getBuyPriceInXCHF(numberToBuy);
        uint256 priceInEther = uniswap.getEthToTokenOutputPrice(priceInXCHF);
        require(msg.value >= priceInEther, "Insufficient Ether");
        require(uniswap.ethToTokenSwapOutput.value(priceInEther)(priceInXCHF, block.timestamp) >= priceInEther, "Swap at Uniswap failed");
        require(currency.approve(address(dispenser), priceInXCHF), "Allowance failed");
        require(dispenser.buyShares(address(this), numberToBuy), "Dispenser transaction failed");
        require(tradedToken.transfer(msg.sender, numberToBuy), "Token transfer failed");
        uint256 contractEtherBalance = address(this).balance;
        msg.sender.transfer(contractEtherBalance);
        return true;
    }

}