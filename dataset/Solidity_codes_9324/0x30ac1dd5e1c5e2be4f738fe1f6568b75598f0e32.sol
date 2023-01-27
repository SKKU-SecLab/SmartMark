
pragma solidity ^0.6.2;





abstract contract ERC721 {
    function totalSupply() virtual public view returns (uint256 total);
    function balanceOf(address _owner) virtual public view returns (uint256 balance);
    function ownerOf(uint256 _tokenId) virtual external view returns (address owner);
    function approve(address _to, uint256 _tokenId) virtual external;
    function transfer(address _to, uint256 _tokenId) virtual external;
    function transferFrom(address _from, address _to, uint256 _tokenId) virtual external;

    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);


    function supportsInterface(bytes4 _interfaceID) virtual external view returns (bool);
}



abstract contract KittyCoreInterface is ERC721  {
    uint256 public autoBirthFee;
    address public saleAuction;
    address public siringAuction;

    function breedWithAuto(uint256 _matronId, uint256 _sireId) virtual public payable;
    function createSaleAuction(uint256 _kittyId, uint256 _startingPrice, uint256 _endingPrice, uint256 _duration) virtual external;
    function createSiringAuction(uint256 _kittyId, uint256 _startingPrice, uint256 _endingPrice, uint256 _duration) virtual external;
    function supportsInterface(bytes4 _interfaceID) virtual override external view returns (bool);
    function approve(address _to, uint256 _tokenId) virtual override external;
}



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





contract AccessControl {

  address payable public owner;
  mapping(address => bool) public operators;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  event OperatorAdded(
    address indexed operator
  );

  event OperatorRemoved(
    address indexed operator
  );

  constructor(address payable _owner) public {
    if(_owner == address(0)) {
      owner = msg.sender;
    } else {
      owner = _owner;
    }
  }

  modifier onlyOwner() {

    require(msg.sender == owner, 'Invalid sender');
    _;
  }

  modifier onlyOwnerOrOperator() {

    require(msg.sender == owner || operators[msg.sender] == true, 'Invalid sender');
    _;
  }

  function transferOwnership(address payable _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);
  }

  function _transferOwnership(address payable _newOwner) internal {

    require(_newOwner != address(0), 'Invalid address');
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }

  function addOperator(address payable _operator) public onlyOwner {

    require(operators[_operator] != true, 'Operator already exists');
    operators[_operator] = true;

    emit OperatorAdded(_operator);
  }

  function removeOperator(address payable _operator) public onlyOwner {

    require(operators[_operator] == true, 'Operator already exists');
    delete operators[_operator];

    emit OperatorRemoved(_operator);
  }

  function destroy() public virtual onlyOwner {

    selfdestruct(owner);
  }

  function destroyAndSend(address payable _recipient) public virtual onlyOwner {

    selfdestruct(_recipient);
  }
}



contract Pausable is AccessControl {

    event Pause();
    event Unpause();

    bool public paused = false;

    constructor(address payable _owner) AccessControl(_owner) public {}

    modifier whenNotPaused() {

        require(!paused, "Contract paused");
        _;
    }

    modifier whenPaused() {

        require(paused, "Contract should be paused");
        _;
    }

    function pause() public onlyOwner whenNotPaused {

        paused = true;
        emit Pause();
    }

    function unpause() public onlyOwner whenPaused {

        paused = false;
        emit Unpause();
    }
}











abstract contract AuctionInterface {
    function cancelAuction(uint256 _tokenId) virtual external;
}




contract CKProxy is Pausable {

  KittyCoreInterface public kittyCore;
  AuctionInterface public saleAuction;
  AuctionInterface public siringAuction;

constructor(address payable _owner, address _kittyCoreAddress) Pausable(_owner) public {
    require(_kittyCoreAddress != address(0), 'Invalid Kitty Core contract address');
    kittyCore = KittyCoreInterface(_kittyCoreAddress);
    require(kittyCore.supportsInterface(0x9a20483d), 'Invalid Kitty Core contract');

    saleAuction = AuctionInterface(kittyCore.saleAuction());
    siringAuction = AuctionInterface(kittyCore.siringAuction());
  }

  function transferKitty(address _to, uint256 _kittyId) external onlyOwnerOrOperator {

    kittyCore.transfer(_to, _kittyId);
  }

  function transferKittyBulk(address _to, uint256[] calldata _kittyIds) external onlyOwnerOrOperator {

    for(uint256 i = 0; i < _kittyIds.length; i++) {
      kittyCore.transfer(_to, _kittyIds[i]);
    }
  }

  function transferKittyFrom(address _from, address _to, uint256 _kittyId) external onlyOwnerOrOperator {

    kittyCore.transferFrom(_from, _to, _kittyId);
  }

  function approveKitty(address _to, uint256 _kittyId) external  onlyOwnerOrOperator {

    kittyCore.approve(_to, _kittyId);
  }

  function createSaleAuction(uint256 _kittyId, uint256 _startingPrice, uint256 _endingPrice, uint256 _duration) external onlyOwnerOrOperator {

    kittyCore.createSaleAuction(_kittyId, _startingPrice, _endingPrice, _duration);
  }

  function cancelSaleAuction(uint256 _kittyId) external onlyOwnerOrOperator {

    saleAuction.cancelAuction(_kittyId);
  }

  function createSiringAuction(uint256 _kittyId, uint256 _startingPrice, uint256 _endingPrice, uint256 _duration) external onlyOwnerOrOperator {

    kittyCore.createSiringAuction(_kittyId, _startingPrice, _endingPrice, _duration);
  }

  function cancelSiringAuction(uint256 _kittyId) external onlyOwnerOrOperator {

    siringAuction.cancelAuction(_kittyId);
  }
}





contract SimpleSiring is CKProxy {

    address payable public breeder;
    uint256 public breederReward;
    uint256 public originalBreederReward;
    uint256 public breederCut;
    uint256 public breederSharesWithdrawn;
    uint256 public ownerSharesWithdrawn;
    uint256 public ownerVaultBalance;
    bool public allowUnverifiedAuctions;

    struct Auction {
      uint128 startingPrice;
      uint128 endingPrice;
      uint64 duration;
    }
    mapping(uint256 => Auction) public auctions;
    Auction public defaultAuction;

    event BreederRewardChange(
        uint256 oldBreederReward,
        uint256 newBreederReward
    );
    event AuctionSet(uint256 tokenId, uint256 startingPrice, uint256 endingPrice, uint256 duration, bool isDefault);
    event AuctionReset(uint256 tokenId, bool isDefault);
    event AuctionStarted(address breeder, uint256 tokenId, uint256 startingPrice, uint256 endingPrice, uint256 duration, uint256 reward);
    event FundsWithdrawn(address receiver, uint256 amount);

    constructor(
        address payable _owner,
        address payable _breeder,
        address _kittyCoreAddress,
        uint256 _breederReward,
        uint256 _breederCut
    ) public CKProxy(_owner, _kittyCoreAddress) {
        require(_breeder != address(0), "Invalid breeder address");
        require(_breederCut < 10000, "Invalid breeder cut");
        breeder = _breeder;
        breederReward = _breederReward;
        originalBreederReward = _breederReward;
        breederCut = _breederCut;
    }

    function setBreederReward(uint256 _breederReward) external {

        require(msg.sender == breeder || msg.sender == owner, "Invalid sender");

        if (msg.sender == owner) {
            require(
                _breederReward >= originalBreederReward ||
                    _breederReward > breederReward,
                "Reward value is less than required"
            );
        } else if (msg.sender == breeder) {
            require(
                _breederReward <= originalBreederReward,
                "Reward value is more than original"
            );
        }

        emit BreederRewardChange(breederReward, _breederReward);
        breederReward = _breederReward;
    }

    function _totalSharedBalance() private view returns(uint256) {

        uint256 currentBalance = address(this).balance;
        require(currentBalance >= ownerVaultBalance, "Invalid vault balance");
        return (currentBalance - ownerVaultBalance) + breederSharesWithdrawn + ownerSharesWithdrawn;
    }

    function getOwnerShares() public view returns (uint256) {

        uint256 totalBalance = _totalSharedBalance();
        uint256 ownerShare = totalBalance * (10000 - breederCut) / 10000;
        uint256 remainingBalance = ownerShare - ownerSharesWithdrawn;
        return remainingBalance;
    }

    function getBreederShares() public view returns (uint256) {

        uint256 totalBalance = _totalSharedBalance();
        uint256 breederShare = totalBalance * breederCut / 10000;
        uint256 remainingBalance = breederShare - breederSharesWithdrawn;
        return remainingBalance;
    }

    function withdraw(uint256 amount) external onlyOwner {

        require(amount <= (getOwnerShares() + ownerVaultBalance), "Insufficient funds");
        if(ownerVaultBalance >= amount) {
            ownerVaultBalance -= amount;
        } else if(ownerVaultBalance > 0) {
            ownerSharesWithdrawn += (amount - ownerVaultBalance);
            ownerVaultBalance = 0;
        } else {
            ownerSharesWithdrawn += amount;
        }
        emit FundsWithdrawn(owner, amount);
        owner.transfer(amount);
    }

    function withdrawBreeder(uint256 amount) external {

        require(msg.sender == breeder, "Invalid sender");
        require(amount <= getBreederShares(), "Insufficient funds");
        breederSharesWithdrawn += amount;
        emit FundsWithdrawn(breeder, amount);
        breeder.transfer(amount);
    }

    function transferToOwnerVault() payable external {

        ownerVaultBalance += msg.value;
    }

    receive() payable external {
    }

    function setAllowUnverifiedAuctions(bool _allow) external onlyOwner {

        allowUnverifiedAuctions = _allow;
    }
    
    function setDefaultAuction(uint128 startingPrice, uint128 endingPrice, uint64 duration) external onlyOwner {

      require(duration > 1 minutes, "Invalid duration");
      defaultAuction.startingPrice = startingPrice;
      defaultAuction.endingPrice = endingPrice;
      defaultAuction.duration = duration;
      emit AuctionSet(0, startingPrice, endingPrice, duration, true);
    }

    function resetDefaultAuction() external onlyOwner {

      defaultAuction.startingPrice = 0;
      defaultAuction.endingPrice = 0;
      defaultAuction.duration = 0;
      emit AuctionReset(0, true);
    }

    function setAuction(uint256 kittyId, uint128 startingPrice, uint128 endingPrice, uint64 duration) external onlyOwner {

      require(duration > 1 minutes, "Invalid duration");
      require(kittyCore.ownerOf(kittyId) == address(this), 'Kitty not owned by contract');
      Auction memory auction = Auction(
        uint128(startingPrice),
        uint128(endingPrice),
        uint64(duration)
      );

      auctions[kittyId] = auction;
      emit AuctionSet(
        uint256(kittyId),
        uint256(startingPrice),
        uint256(endingPrice),
        uint256(duration),
        false
      );
    }

    function resetAuction(uint256 kittyId) external onlyOwner {

      require(auctions[kittyId].duration > 0, "Non-existing auction");
      delete auctions[kittyId];
      emit AuctionReset(
        kittyId,
        false
      );
    }

    function _getAuctionForKitty(uint256 _kittyId) private view returns(Auction storage) {

        Auction storage auction = auctions[_kittyId];
        if(auction.duration == 0 && defaultAuction.duration > 0) {
            auction = defaultAuction;
        }
        return auction;
    }

    function _ownerPays(uint256 amount) private returns(bool) {

        bool paid = true;
        if(ownerVaultBalance >= amount) {
            ownerVaultBalance -= amount;
        } else if(getOwnerShares() >= amount) {
            ownerSharesWithdrawn += amount;
        } else {
            paid = false;
        }
        return paid;
    }

    function createSireAuction(uint256 _kittyId)
        external
        whenNotPaused
    {

        require(msg.sender == breeder || msg.sender == owner, "Invalid sender");

        Auction storage auction = _getAuctionForKitty(_kittyId);
        require(auction.duration > 0, "No auction for kitty");

        kittyCore.createSiringAuction(
            _kittyId,
            auction.startingPrice,
            auction.endingPrice,
            auction.duration);

        uint256 reward = 0;
        if (msg.sender == breeder) {
            reward = breederReward;
            require(_ownerPays(reward), "No funds to pay reward");
            breeder.transfer(reward);
        }

        emit AuctionStarted(
            msg.sender,
            _kittyId,
            auction.startingPrice,
            auction.endingPrice,
            auction.duration,
            reward
        );
    }

    function createUnverifiedSireAuction(
        uint256 _kittyId,
        uint256 startingPrice,
        uint256 endingPrice,
        uint256 duration)
        external
        whenNotPaused
    {

        require((msg.sender == breeder && allowUnverifiedAuctions) ||
            msg.sender == owner, "Cannot create unverified auction");

       kittyCore.createSiringAuction(_kittyId, startingPrice, endingPrice, duration);

        uint256 reward = 0;
        if (msg.sender == breeder) {
            reward = breederReward;
            require(_ownerPays(reward), "No funds to pay reward");
            breeder.transfer(reward);
        }

        emit AuctionStarted(
            msg.sender,
            _kittyId,
            startingPrice,
            endingPrice,
            duration,
            reward
        );
    }

    function destroy() public override virtual onlyOwner {

        require(getBreederShares() == 0, "Breeder should withdraw first");
        require(kittyCore.balanceOf(address(this)) == 0, "Contract has tokens");
        selfdestruct(owner);
    }

    function destroyAndSend(address payable _recipient) public override virtual onlyOwner {

        require(getBreederShares() == 0, "Breeder should withdraw first");
        require(kittyCore.balanceOf(address(this)) == 0, "Contract has tokens");
        selfdestruct(_recipient);
    }
}



contract SimpleSiringFactory is Pausable {

    using SafeMath for uint256;

    KittyCoreInterface public kittyCore;
    uint256 public breederReward = 0.001 ether;
    uint256 public breederCut = 625;
    uint256 public commission = 0 wei;
    uint256 public provisionFee;
    mapping (bytes32 => address) public breederToContract;

    event ContractCreated(address contractAddress, address breeder, address owner);
    event ContractRemoved(address contractAddress);

    constructor(address _kittyCoreAddress) Pausable(address(0)) public {
        provisionFee = commission + breederReward;
        kittyCore = KittyCoreInterface(_kittyCoreAddress);
        require(kittyCore.supportsInterface(0x9a20483d), "Invalid contract");
    }

    function setBreederReward(uint256 _breederReward) external onlyOwner {

        require(_breederReward > 0, "Breeder reward must be greater than 0");
        breederReward = _breederReward;
        provisionFee = uint256(commission).add(breederReward);
    }

    function setBreederCut(uint256 _breederCut) external onlyOwner {

        require(_breederCut < 10000, "Breeder reward must be less than 10000");
        breederCut = _breederCut;
    }

    function setCommission(uint256 _commission) external onlyOwner {

        commission = _commission;
        provisionFee = uint256(commission).add(breederReward);
    }

    function setKittyCore(address _kittyCore) external onlyOwner {

        kittyCore = KittyCoreInterface(_kittyCore);
        require(kittyCore.supportsInterface(0x9a20483d), "Invalid contract");
    }

    receive() payable external {
    }

    function withdraw(uint256 amount) external onlyOwner {

        owner.transfer(amount);
    }

    function createContract(address payable _breederAddress) external payable whenNotPaused {

        require(msg.value >= provisionFee, "Invalid value");

        bytes32 key = keccak256(abi.encodePacked(_breederAddress, msg.sender));
        require(breederToContract[key] == address(0), "Breeder already enrolled");

        uint256 excess = uint256(msg.value).sub(provisionFee);
        SimpleSiring newContract = new SimpleSiring(msg.sender, _breederAddress, address(kittyCore), breederReward, breederCut);

        breederToContract[key] = address(newContract);
        if(excess > 0) {
            newContract.transferToOwnerVault.value(excess)();
        }

        _breederAddress.transfer(breederReward);

        emit ContractCreated(address(newContract), _breederAddress, msg.sender);
    }

    function removeContract(address _breederAddress, address _ownerAddress) external onlyOwner {

        bytes32 key = keccak256(abi.encodePacked(_breederAddress, _ownerAddress));
        address contractAddress = breederToContract[key];
        require(contractAddress != address(0), "Breeder not enrolled");
        delete breederToContract[key];

        emit ContractRemoved(contractAddress);
    }
}