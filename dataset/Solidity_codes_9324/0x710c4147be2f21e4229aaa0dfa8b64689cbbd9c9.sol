


pragma solidity ^0.7.1;

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



pragma solidity ^0.7.1;


contract RedeemRSFI {

  IERC20 public constant SFI = IERC20(address(0xb753428af26E81097e7fD17f40c88aaA3E04902c));
  IERC20 public constant rSFI = IERC20(address(0x5dB451f9913C57dC103c6B9dF46FF9be42C28510));
  address public constant burn_address = address(0x000000000000000000000000000000000000dEaD);
  address public constant multisig = address(0xAA394e08C74e2B2f76fF000AdEB25f20423CFe2A);

  event RedeemSFI(address addr, uint256 amount);
  function redeem_SFI(uint256 amount) external {

    require(amount != 0, "can't redeem 0");
    require(rSFI.balanceOf(msg.sender) >= amount, "insufficient rSFI tokens to redeem SFI");
    rSFI.transferFrom(msg.sender, address(burn_address), amount);
    SFI.transfer(msg.sender, amount);
    emit RedeemSFI(msg.sender, amount);
  }

  event ErcSwept(address who, address to, address token, uint256 amount);
  function erc_sweep(address _token, address _to) public {

    require(msg.sender == multisig, "must be multisig");

    IERC20 tkn = IERC20(_token);
    uint256 tBal = tkn.balanceOf(address(this));
    tkn.transfer(_to, tBal);

    emit ErcSwept(msg.sender, _to, _token, tBal);
  }
}