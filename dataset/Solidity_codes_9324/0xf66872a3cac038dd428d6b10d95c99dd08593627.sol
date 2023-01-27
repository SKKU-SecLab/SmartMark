
pragma solidity ^0.4.21;

contract Hourglass {

  function() payable public;
  function buy(address) public payable returns(uint256) {}

  function sell(uint256) public;
  function withdraw() public returns(address);

  function dividendsOf(address,bool) public view returns(uint256);

  function balanceOf(address) public view returns(uint256);

  function transfer(address , uint256) public returns(bool);

  function myTokens() public view returns(uint256);

  function myDividends(bool) public view returns(uint256);

  function exit() public;

}

contract Farm {

  address public eWLTHAddress = 0x5833C959C3532dD5B3B6855D590D70b01D2d9fA6;
  
  mapping (address => address) public crops;
  
  event CropCreated(address indexed owner, address crop);

  function createCrop(address _playerAddress, bool _selfBuy) public payable returns (address) {

      require(crops[msg.sender] == address(0));
      
      address cropAddress = new Crop(msg.sender);
      crops[msg.sender] = cropAddress;
      emit CropCreated(msg.sender, cropAddress);

      if (msg.value != 0){
        if (_selfBuy){
            Crop(cropAddress).buy.value(msg.value)(cropAddress);
        } else {
            Crop(cropAddress).buy.value(msg.value)(_playerAddress);
        }
      }
      
      return cropAddress;
  }
  
  function myCrop() public view returns (address) {

    return crops[msg.sender];
  }
  
  function myCropDividends(bool _includeReferralBonus) external view returns (uint256) {

    return Hourglass(eWLTHAddress).dividendsOf(crops[msg.sender], _includeReferralBonus);
  }
  
  function myCropTokens() external view returns (uint256) {

    return Hourglass(eWLTHAddress).balanceOf(crops[msg.sender]);
  }
  
  function myCropDisabled() external view returns (bool) {

    if (crops[msg.sender] != address(0)){
        return Crop(crops[msg.sender]).disabled();
    } else {
        return true;
    }
  }
}

contract Crop {

  address public owner;
  bool public disabled = false;

  address private eWLTHAddress = 0xDe6FB6a5adbe6415CDaF143F8d90Eb01883e42ac;

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }
  
  function Crop(address newOwner) public {

      owner = newOwner;
  }
  
  function disable(bool _disabled) external onlyOwner() {

    disabled = _disabled;
  }

  function reinvest(address _playerAddress) external {

    require(disabled == false);
    
    Hourglass eWLTH = Hourglass(eWLTHAddress);
    if (eWLTH.dividendsOf(address(this), true) > 0){
        eWLTH.withdraw();
        uint256 bal = address(this).balance;
        eWLTH.buy.value(bal)(_playerAddress);
    }
  }
  
  function() public payable {}

  function buy(address _playerAddress) external payable {

    Hourglass(eWLTHAddress).buy.value(msg.value)(_playerAddress);
  }

  function sell(uint256 _amountOfTokens) external onlyOwner() {

    Hourglass(eWLTHAddress).sell(_amountOfTokens);
    withdraw();
  }

  function withdraw() public onlyOwner() {

    if (Hourglass(eWLTHAddress).myDividends(true) > 0){
        Hourglass(eWLTHAddress).withdraw();

        owner.transfer(address(this).balance);
    }
  }
  
  function exit() external onlyOwner() {

    Hourglass(eWLTHAddress).exit();
    owner.transfer(address(this).balance);
  }
  
  function transfer(address _toAddress, uint256 _amountOfTokens) external onlyOwner() returns (bool) {

    withdraw();
    return Hourglass(eWLTHAddress).transfer(_toAddress, _amountOfTokens);
  }

  function cropDividends(bool _includeReferralBonus) external view returns (uint256) {

    return Hourglass(eWLTHAddress).myDividends(_includeReferralBonus);
  }
  
  function cropTokens() external view returns (uint256) {

    return Hourglass(eWLTHAddress).myTokens();
  }
}