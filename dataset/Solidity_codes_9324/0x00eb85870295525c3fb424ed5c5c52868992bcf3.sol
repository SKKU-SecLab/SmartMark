

pragma solidity 0.4.24;

contract IMainToken{

    function transfer(address, uint256) public pure  returns (bool);

    function transferFrom(address, address, uint256) public pure  returns (bool);

 }
 

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b,"Invalid values");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0,"Invalid values");
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a,"Invalid values");
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a,"Invalid values");
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0,"Invalid values");
        return a % b;
    }
}

contract MultiPadLaunchApp {

    
    using SafeMath for uint256;
    
    IMainToken iMainToken;
    
    address private _owner = msg.sender;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    address private tokenContractAddress;
    


    function setTokenAddress(address _ITokenContract) onlyOwner external returns(bool){

        tokenContractAddress = _ITokenContract;
        iMainToken = IMainToken(_ITokenContract);
    }

    

    function getowner() external view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(),"You are not authenticate to make this transfer");
        _;
    }

    function isOwner() internal view returns (bool) {

        return msg.sender == _owner;
    }

    function transferOwnership(address newOwner) external onlyOwner returns (bool){

        require(newOwner != address(0), "Owner address cant be zero");
        _owner = newOwner;
        return true;
    }
    
    
      function airdropByOwner(address[] memory _addresses, uint256[] memory _amount) public onlyOwner returns (bool){

          require(_addresses.length == _amount.length,"Invalid Array");
          uint256 count = _addresses.length;
          uint256 airdropcount = 0;
          for (uint256 i = 0; i < count; i++){
               iMainToken.transfer(_addresses[i],_amount[i]);
               airdropcount = airdropcount + 1;
          }
          return true;
      }
      
    function withdrawPeningTokens(uint256 _amount) external onlyOwner returns(bool){

       iMainToken.transfer(msg.sender, _amount);
       return true;
         
    }
    
    function withdrawCurrency(uint256 _amount) external onlyOwner returns(bool){

        msg.sender.transfer(_amount);
        return true;
    }

}