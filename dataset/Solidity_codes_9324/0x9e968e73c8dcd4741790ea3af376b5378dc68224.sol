
pragma solidity ^0.8.0;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}

contract JHEToken {

    mapping(address => uint256) public balanceOf;

    function transfer(address _to, uint256 _value) public returns (bool success) {}

}

interface IPriceFeed {
    function latestRoundData() external view returns (
        uint80 roundId,
        uint256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
}

contract JHETokenSale {
    using SafeMath for uint;
    address public owner;
    address payable public etherWallet;
    JHEToken public tokenContract;
    uint256 public tokensSold;
    uint256 public totalFeeAmount;

    _Fee[] public feeDistributions;   // array of _Fee struct

    struct _Fee {
        uint256 id;
        string name;
        address payable wallet;
        uint256 percent;
        bool active;
    }

    IPriceFeed public priceFeed;
    uint256 public tokenPrice; // 100000000 = 1 usd


    event Sell(address _buyer, uint256 _amount);

    constructor(JHEToken _tokenContract, address payable _etherWallet, IPriceFeed _priceFeed, uint256 _tokenPrice) {
        owner = msg.sender;
        tokenContract = _tokenContract;
        tokenPrice = _tokenPrice;
        totalFeeAmount = 0;
        etherWallet = _etherWallet;

        priceFeed = _priceFeed;
    }

    function getEthAmount() public view returns(uint256) {
        (,uint256 price, , , ) = priceFeed.latestRoundData();
        return tokenPrice*1e18/price;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "owner only");
        _;
    }
    modifier noBalance() {
        require(address(this).balance == 0, "balance not null, transfer funds first");
        _;
    }

    function buyTokens(uint256 _numberOfTokens) public payable {
        uint256 price = getEthAmount();
        uint256 tokenTotalPrice = _numberOfTokens*price/10**18;
        require(tokenTotalPrice <= msg.value, "Insufficent value");
        uint256 totalFeePercent = getTotalFeePercent ();
        uint256 _totalFeeAmount = tokenTotalPrice.mul(totalFeePercent).div(100000);  // FEE: 100000 = 100%
        totalFeeAmount = totalFeeAmount.add (_totalFeeAmount);

        require(msg.value >= tokenTotalPrice.add(_totalFeeAmount),'incorrect amount');
        require(tokenContract.balanceOf(address(this)) >= _numberOfTokens,'contract has not enough token');
        require(tokenContract.transfer(msg.sender, _numberOfTokens),'transfer error');

        uint256 ethAmount = msg.value;
        _transferPayments(ethAmount);

        tokensSold += _numberOfTokens;

        emit Sell(msg.sender, _numberOfTokens);
    }

    function _transferPayments(uint256 ethAmount) internal {
        require(ethAmount > 0, "no ether recieved");

        uint256 _ownerFunds = ethAmount.sub(totalFeeAmount);
        etherWallet.transfer(_ownerFunds);

        uint256 feesCount = getFeeDistributionsCount();
        _Fee[] storage fees = feeDistributions;

        for (uint i = 0; i < feesCount; i++){
            if (fees[i].active){
                uint feeValue = _ownerFunds.mul(fees[i].percent).div(100000);  // FEE: 100000 = 100%
                fees[i].wallet.transfer(feeValue);
            }
        }

        if (address(this).balance != 0){
            etherWallet.transfer(address(this).balance);
        }
        totalFeeAmount = 0;
    }


    function endSale() public onlyOwner{
        require(tokenContract.transfer(owner, tokenContract.balanceOf(address(this))),'transfer error');
    }

    function transferFunds() public onlyOwner {

        uint256 totalFunds = address(this).balance;

        uint256 _ownerFunds = totalFunds.sub(totalFeeAmount);
        etherWallet.transfer(_ownerFunds);

        uint256 feesCount = getFeeDistributionsCount();
        _Fee[] storage fees = feeDistributions;

        for (uint i = 0; i < feesCount; i++){
            if (fees[i].active){
                uint feeValue = _ownerFunds.mul(fees[i].percent).div(100000);  // FEE: 100000 = 100%
                fees[i].wallet.transfer(feeValue);
            }
        }

        if (address(this).balance != 0){
            etherWallet.transfer(address(this).balance);
        }
        totalFeeAmount = 0;
    }

    function setFeeDistributions(address payable _feeWallet, string memory _name, uint256 _percent) public  onlyOwner noBalance{
        require(_feeWallet != address(0), "address not valid");

        _Fee[] storage fees = feeDistributions;
        uint256 feesCount = getFeeDistributionsCount();

        bool feeExiste = false;

        uint totalFeePercent = getTotalFeePercent ();
        totalFeePercent = totalFeePercent.add(_percent);
        require(totalFeePercent <= 100000, "total fee cannot exceed 100");

        for (uint i = 0; i < feesCount; i++){
            if (fees[i].wallet == _feeWallet){
                fees[i].name    = _name;
                fees[i].percent = _percent;
                fees[i].active  = true;

                feeExiste = true;
                break;
            }
        }

        if (!feeExiste){
            _Fee memory fee;

            fee.id = (feesCount + 1);
            fee.name = _name;
            fee.wallet = _feeWallet;
            fee.percent = _percent;
            fee.active = true;

            fees.push(fee);
        }
    }

    function getFeeDistributionsCount() public view returns(uint) {
        _Fee[] storage fees = feeDistributions;
        return fees.length;
    }

    function getTotalFeePercent () public view returns (uint){
        uint256 totalFeePercent = 0;
        uint256 feesCount = getFeeDistributionsCount();
        _Fee[] storage fees = feeDistributions;

        for (uint i = 0; i < feesCount; i++){
            if (fees[i].active){
                totalFeePercent = totalFeePercent.add(fees[i].percent);
            }
        }

        return totalFeePercent;
    }

    function deActivateFeeWallet(address _feeWallet) public onlyOwner {
        require(_feeWallet != address(0), "address not valid");

        _Fee[] storage fees = feeDistributions;
        uint256 feesCount = getFeeDistributionsCount();
        for (uint i = 0; i < feesCount; i++){
            if (fees[i].wallet == _feeWallet){
                fees[i].active = false;
                break;
            }
        }
    }

    function transferOwnership(address payable _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }
    function _transferOwnership(address payable _newOwner) internal {
        require(_newOwner != address(0), "address not valid");
        owner = _newOwner;
    }

    function transferEtherWallet(address payable _newEtherWallet) public onlyOwner {
        _transferEtherWallet(_newEtherWallet);
    }
    function _transferEtherWallet(address payable _newEtherWallet) internal {
        require(_newEtherWallet != address(0), "address not valid");
        etherWallet = _newEtherWallet;
    }

    function setTokenPrice(uint256 _tokenPrice) public onlyOwner {
        require(_tokenPrice != 0, "token price is null");
        tokenPrice = _tokenPrice;
    }

    function setPriceFeed(IPriceFeed _priceFeed) public onlyOwner {
        priceFeed = _priceFeed;
    }
}