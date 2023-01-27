
pragma solidity ^0.4.23;

interface P3D {

  function() payable external;
  function buy(address _playerAddress) payable external returns(uint256);

  function sell(uint256 _amountOfTokens) external;

  function reinvest() external;

  function withdraw() external;

  function exit() external;

  function dividendsOf(address _playerAddress) external view returns(uint256);

  function balanceOf(address _playerAddress) external view returns(uint256);

  function transfer(address _toAddress, uint256 _amountOfTokens) external returns(bool);

  function stakingRequirement() external view returns(uint256);

  function myDividends(bool _includeReferralBonus) external view returns(uint256);

}

contract Crop {

  address public owner;
  bool public disabled;

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function() public payable {}
  
  function disable(bool _disabled) external onlyOwner() {

    disabled = _disabled;
  }

  function reinvest() external {

    require(disabled == false);
    
    P3D p3d = P3D(0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe);

    p3d.withdraw();

    p3d.buy.value(address(this).balance)(msg.sender);
  }

  function buy(address _playerAddress) external payable onlyOwner() {

    P3D(0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe).buy.value(msg.value)(_playerAddress);
  }

  function sell(uint256 _amountOfTokens) external onlyOwner() {

    P3D(0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe).sell(_amountOfTokens);

    owner.transfer(address(this).balance);
  }

  function withdraw() external onlyOwner() {

    P3D(0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe).withdraw();

    owner.transfer(address(this).balance);
  }

  function exit() external onlyOwner() {

    P3D(0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe).exit();

    owner.transfer(address(this).balance);
  }
  
  function transfer(address _toAddress, uint256 _amountOfTokens) external onlyOwner() returns (bool) {

    return P3D(0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe).transfer(_toAddress, _amountOfTokens);
  }

  function dividends(bool _includeReferralBonus) external view returns (uint256) {

    return P3D(0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe).myDividends(_includeReferralBonus);
  }
}