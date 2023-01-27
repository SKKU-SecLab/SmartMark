

pragma solidity ^0.5.0;

 interface ERC20 {

    function transfer(address receiver, uint amount) external;

    function transferFrom(address _from, address _to, uint256 _value)external;

    function balanceOf(address receiver)external returns(uint256);

}
 interface USDT20 {

    function transfer(address receiver, uint amount) external;

    function transferFrom(address _from, address _to, uint256 _value)external;

    function balanceOf(address receiver)external returns(uint256);

}
contract NiranaMeta{

    address public owner;
    address public MNUerc20;
    address public USDTerc20;
    uint256 public pice;
    modifier onlyOwner() {

        require(owner==msg.sender, "Not an administrator");
        _;
    }
     constructor(address _MNUaddress,address _USDTaddress)public{
         owner=msg.sender;
        MNUerc20=_MNUaddress;
        USDTerc20=_USDTaddress;
         pice=70000;
     }
     function buy(uint256 _value)public{

         require(_value>1000000 && _value<=500000000);
         uint256 amount=_value/pice*1 ether;
         USDT20(USDTerc20).transferFrom(msg.sender,address(this),_value);
         ERC20(MNUerc20).transfer(msg.sender,amount);
     }
    function withdrawMNU(uint256 amount) onlyOwner public {

        ERC20(MNUerc20).transfer(msg.sender,amount);
    }
    function withdrawUSDT(uint256 amount) onlyOwner public {

        ERC20(USDTerc20).transfer(msg.sender,amount);
    }
    function setpice(uint256 amount) onlyOwner public {

        pice=amount;
    }
}