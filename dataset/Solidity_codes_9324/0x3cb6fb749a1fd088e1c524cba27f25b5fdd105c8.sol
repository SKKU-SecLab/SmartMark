
pragma solidity ^0.6.9;






interface IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
}



contract Owned {


    address private mOwner;   
    bool private initialised;    
    address public newOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {

        require(isOwner());
        _;
    }

    function _initOwned(address _owner) internal {

        require(!initialised);
        mOwner = address(uint160(_owner));
        initialised = true;
        emit OwnershipTransferred(address(0), mOwner);
    }

    function owner() public view returns (address) {

        return mOwner;
    }
    function isOwner() public view returns (bool) {

        return msg.sender == mOwner;
    }

    function transferOwnership(address _newOwner) public {

        require(isOwner());
        newOwner = _newOwner;
    }

    function acceptOwnership() public {

        require(msg.sender == newOwner);
        emit OwnershipTransferred(mOwner, newOwner);
        mOwner = address(uint160(newOwner));
        newOwner = address(0);
    }
    function recoverTokens(address token, uint tokens) public {

        require(isOwner());
        if (token == address(0)) {
            payable(mOwner).transfer((tokens == 0 ? address(this).balance : tokens));
        } else {
            IERC20(token).transfer(mOwner, tokens == 0 ? IERC20(token).balanceOf(address(this)) : tokens);
        }
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

    
    function max(uint256 a, uint256 b) internal pure returns (uint256 c) {

        c = a >= b ? a : b;
    }
    function min(uint256 a, uint256 b) internal pure returns (uint256 c) {

        c = a <= b ? a : b;
    }
}



contract CloneFactory {


  function createClone(address target) internal returns (address result) {

    bytes20 targetBytes = bytes20(target);
    assembly {
      let clone := mload(0x40)
      mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
      mstore(add(clone, 0x14), targetBytes)
      mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
      result := create(0, clone, 0x37)
    }
  }

  function isClone(address target, address query) internal view returns (bool result) {

    bytes20 targetBytes = bytes20(target);
    assembly {
      let clone := mload(0x40)
      mstore(clone, 0x363d3d373d3d3d363d7300000000000000000000000000000000000000000000)
      mstore(add(clone, 0xa), targetBytes)
      mstore(add(clone, 0x1e), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)

      let other := add(clone, 0x40)
      extcodecopy(query, other, 0, 0x2d)
      result := and(
        eq(mload(clone), mload(other)),
        eq(mload(add(clone, 0xd)), mload(add(other, 0xd)))
      )
    }
  }
}


interface IOwned {

    function owner() external view returns (address) ;

    function isOwner() external view returns (bool) ;

    function transferOwnership(address _newOwner) external;

}


interface IDutchAuction {


    function initDutchAuction (
            address _funder,
            address _token,
            uint256 _tokenSupply,
            uint256 _startDate,
            uint256 _endDate,
            address _paymentCurrency,
            uint256 _startPrice,
            uint256 _minimumPrice,
            address payable _wallet
        ) external ;
    function auctionEnded() external view returns (bool);

    function tokensClaimed(address user) external view returns (uint256);

    function tokenSupply() external view returns(uint256);

    function auctionToken() external view returns(address);

    function wallet() external view returns(address);


    function paymentCurrency() external view returns(address);


}

contract DutchSwapFactory is  Owned, CloneFactory {

    using SafeMath for uint256;

    address public dutchAuctionTemplate;

    struct Auction {
        bool exists;
        uint256 index;
    }

    address public newAddress;
    uint256 public minimumFee = 0 ether;
    mapping(address => Auction) public isChildAuction;
    address[] public auctions;

    event DutchAuctionDeployed(address indexed owner, address indexed addr, address dutchAuction, uint256 fee);
    event AuctionRemoved(address dutchAuction, uint256 index );
    event FactoryDeprecated(address newAddress);
    event MinimumFeeUpdated(uint oldFee, uint newFee);
    event AuctionTemplateUpdated(address oldDutchAuction, address newDutchAuction );

    function initDutchSwapFactory( address _dutchAuctionTemplate, uint256 _minimumFee) public  {

        _initOwned(msg.sender);
        dutchAuctionTemplate = _dutchAuctionTemplate;
        minimumFee = _minimumFee;
    }

    function numberOfAuctions() public view returns (uint) {

        return auctions.length;
    }
    function removeFinalisedAuction(address _auction) public  {

        require(isChildAuction[_auction].exists);
        bool finalised = IDutchAuction(_auction).auctionEnded();
        require(finalised);
        uint removeIndex = isChildAuction[_auction].index;
        emit AuctionRemoved(_auction, auctions.length - 1);
        uint lastIndex = auctions.length - 1;
        address lastIndexAddress = auctions[lastIndex];
        auctions[removeIndex] = lastIndexAddress;
        isChildAuction[lastIndexAddress].index = removeIndex;
        if (auctions.length > 0) {
            auctions.pop();
        }
    }

    function deprecateFactory(address _newAddress) public  {

        require(isOwner());
        require(newAddress == address(0));
        emit FactoryDeprecated(_newAddress);
        newAddress = _newAddress;
    }
    function setMinimumFee(uint256 _minimumFee) public  {

        require(isOwner());
        emit MinimumFeeUpdated(minimumFee, _minimumFee);
        minimumFee = _minimumFee;
    }

    function setDutchAuctionTemplate( address _dutchAuctionTemplate) public  {

        require(isOwner());
        emit AuctionTemplateUpdated(dutchAuctionTemplate, _dutchAuctionTemplate);
        dutchAuctionTemplate = _dutchAuctionTemplate;
    }

    function deployDutchAuction(
        address _token, 
        uint256 _tokenSupply, 
        uint256 _startDate, 
        uint256 _endDate, 
        address _paymentCurrency,
        uint256 _startPrice, 
        uint256 _minimumPrice, 
        address payable _wallet
    )
        public payable returns (address dutchAuction)
    {

        dutchAuction = createClone(dutchAuctionTemplate);
        isChildAuction[address(dutchAuction)] = Auction(true, auctions.length - 1);
        auctions.push(address(dutchAuction));
        require(IERC20(_token).transferFrom(msg.sender, address(this), _tokenSupply)); 
        require(IERC20(_token).approve(dutchAuction, _tokenSupply));
        IDutchAuction(dutchAuction).initDutchAuction(address(this), _token,_tokenSupply,_startDate,_endDate,_paymentCurrency,_startPrice,_minimumPrice,_wallet);
        emit DutchAuctionDeployed(msg.sender, address(dutchAuction), dutchAuctionTemplate, msg.value);
    }

    function transferAnyERC20Token(address tokenAddress, uint256 tokens) public returns (bool success) {

        require(isOwner());
        return IERC20(tokenAddress).transfer(owner(), tokens);
    }
    receive () external payable {
        revert();
    }
}