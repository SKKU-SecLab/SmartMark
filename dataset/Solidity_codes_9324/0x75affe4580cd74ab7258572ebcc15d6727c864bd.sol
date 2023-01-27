
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
}//Unlicensed
pragma solidity 0.6.12;

interface IFirstDibsMarketSettings {

    function globalBuyerPremium() external view returns (uint32);


    function globalMarketCommission() external view returns (uint32);


    function globalCreatorRoyaltyRate() external view returns (uint32);


    function globalMinimumBidIncrement() external view returns (uint32);


    function globalTimeBuffer() external view returns (uint32);


    function globalAuctionDuration() external view returns (uint32);


    function commissionAddress() external view returns (address);

}//Unlicensed
pragma solidity 0.6.12;


contract FirstDibsMarketSettings is Ownable, IFirstDibsMarketSettings {

    uint32 public override globalBuyerPremium = 0;

    uint32 public override globalMarketCommission = 5;

    uint32 public override globalCreatorRoyaltyRate = 5;

    uint32 public override globalMinimumBidIncrement = 10;

    uint32 public override globalTimeBuffer = 15 * 60;

    uint32 public override globalAuctionDuration = 24 * 60 * 60;

    address public override commissionAddress;

    constructor(address _commissionAddress) public {
        require(
            _commissionAddress != address(0),
            'Cannot have null address for _commissionAddress'
        );

        commissionAddress = _commissionAddress; // receiver address for auction admin (globalMarketplaceCommission gets sent here)
    }

    modifier nonZero(uint256 _value) {

        require(_value > 0, 'Value must be greater than zero');
        _;
    }

    modifier lte100(uint256 _value) {

        require(_value <= 100, 'Value must be <= 100');
        _;
    }

    function setCommissionAddress(address _commissionAddress) external onlyOwner {

        require(
            _commissionAddress != address(0),
            'Cannot have null address for _commissionAddress'
        );
        commissionAddress = _commissionAddress;
    }

    function setGlobalTimeBuffer(uint32 _timeBuffer) external onlyOwner nonZero(_timeBuffer) {

        globalTimeBuffer = _timeBuffer;
    }

    function setGlobalAuctionDuration(uint32 _auctionDuration)
        external
        onlyOwner
        nonZero(_auctionDuration)
    {

        globalAuctionDuration = _auctionDuration;
    }

    function setGlobalBuyerPremium(uint32 _buyerPremium) external onlyOwner {

        globalBuyerPremium = _buyerPremium;
    }

    function setGlobalMarketCommission(uint32 _marketCommission)
        external
        onlyOwner
        lte100(_marketCommission)
    {

        require(_marketCommission >= 3, 'Market commission cannot be lower than 3%');
        globalMarketCommission = _marketCommission;
    }

    function setGlobalCreatorRoyaltyRate(uint32 _royaltyRate)
        external
        onlyOwner
        lte100(_royaltyRate)
    {

        require(_royaltyRate >= 2, 'Creator royalty cannot be lower than 2%');
        globalCreatorRoyaltyRate = _royaltyRate;
    }

    function setGlobalMinimumBidIncrement(uint32 _bidIncrement)
        external
        onlyOwner
        nonZero(_bidIncrement)
    {

        globalMinimumBidIncrement = _bidIncrement;
    }
}