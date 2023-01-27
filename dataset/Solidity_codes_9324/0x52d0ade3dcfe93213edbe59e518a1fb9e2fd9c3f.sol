
pragma solidity ^0.4.24;


interface IERC20 {

  function totalSupply() external view returns (uint256);


  function balanceOf(address who) external view returns (uint256);


  function allowance(address owner, address spender)
    external view returns (uint256);


  function transfer(address to, uint256 value) external returns (bool);


  function approve(address spender, uint256 value)
    external returns (bool);


  function transferFrom(address from, address to, uint256 value)
    external returns (bool);


  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
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

    require(b > 0); // Solidity only automatically asserts when dividing by 0
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


library ExternalCall {

    function externalCall(address destination, uint value, bytes data, uint dataOffset, uint dataLength) internal returns(bool result) {

        assembly {
            let x := mload(0x40)   // "Allocate" memory for output (0x40 is where "free memory" pointer is stored by convention)
            let d := add(data, 32) // First 32 bytes are the padded length of data, so exclude that
            result := call(
                sub(gas, 34710),   // 34710 is the value that solidity is currently emitting
                destination,
                value,
                add(d, dataOffset),
                dataLength,        // Size of the input (in bytes) - this is what fixes the padding problem
                x,
                0                  // Output is ignored, therefore the output size is zero
            )
        }
    }
}



pragma solidity ^0.4.24;

interface ISetToken {



    function naturalUnit()
        external
        view
        returns (uint256);


    function getComponents()
        external
        view
        returns(address[]);


    function getUnits()
        external
        view
        returns(uint256[]);


    function tokenIsComponent(
        address _tokenAddress
    )
        external
        view
        returns (bool);


    function mint(
        address _issuer,
        uint256 _quantity
    )
        external;


    function burn(
        address _from,
        uint256 _quantity
    )
        external;


    function transfer(
        address to,
        uint256 value
    )
        external;

}


contract IKyberNetworkProxy {

    function trade(
        address src,
        uint srcAmount,
        address dest,
        address destAddress,
        uint maxDestAmount,
        uint minConversionRate,
        address walletId
    )
        public
        payable
        returns(uint);

}


contract SetBuyer {

    using SafeMath for uint256;
    using ExternalCall for address;

    function buy(
        ISetToken set,
        bytes callDatas,
        uint[] starts // including 0 and LENGTH values
    )
        public
        payable
    {

        change(callDatas, starts);

        address[] memory components = set.getComponents();
        uint256[] memory units = set.getUnits();

        uint256 fitAmount = uint(-1);
        for (uint i = 0; i < components.length; i++) {
            IERC20 token = IERC20(components[i]);
            if (token.allowance(this, set) == 0) {
                require(token.approve(set, uint256(-1)), "Approve failed");
            }

            uint256 amount = token.balanceOf(this).div(units[i]);
            if (amount < fitAmount) {
                fitAmount = amount;
            }
        }

        set.mint(msg.sender, fitAmount);

        if (address(this).balance > 0) {
            msg.sender.transfer(address(this).balance);
        }
        for (i = 0; i < components.length; i++) {
            token = IERC20(components[i]);
            if (token.balanceOf(this) > 0) {
                require(token.transfer(msg.sender, token.balanceOf(this)), "transfer failed");
            }
        }
    }

    function() public payable {
        require(tx.origin != msg.sender);
    }

    function sell(
        ISetToken set,
        uint256 amount,
        bytes callDatas,
        uint[] starts // including 0 and LENGTH values
    )
        public
    {

        set.burn(msg.sender, amount);

        change(callDatas, starts);

        address[] memory components = set.getComponents();

        if (address(this).balance > 0) {
            msg.sender.transfer(address(this).balance);
        }
        for (uint i = 0; i < components.length; i++) {
            IERC20 token = IERC20(components[i]);
            if (token.balanceOf(this) > 0) {
                require(token.transfer(msg.sender, token.balanceOf(this)), "transfer failed");
            }
        }
    }

    function change(bytes callDatas, uint[] starts) public payable { // starts should include 0 and callDatas.length

        for (uint i = 0; i < starts.length - 1; i++) {
            require(address(this).externalCall(0, callDatas, starts[i], starts[i + 1] - starts[i]));
        }
    }

    function sendEthValue(address target, bytes data, uint256 value) external {

        require(target.call.value(value)(data));
    }

    function sendEthProportion(address target, bytes data, uint256 mul, uint256 div) external {

        uint256 value = address(this).balance.mul(mul).div(div);
        require(target.call.value(value)(data));
    }

    function approveTokenAmount(address target, bytes data, IERC20 fromToken, uint256 amount) external {

        if (fromToken.allowance(this, target) != 0) {
             fromToken.approve(target, 0);
        }
        fromToken.approve(target, amount);
        require(target.call(data));
    }

    function approveTokenProportion(address target, bytes data, IERC20 fromToken, uint256 mul, uint256 div) external {

        uint256 amount = fromToken.balanceOf(this).mul(mul).div(div);
        if (fromToken.allowance(this, target) != 0) {
            fromToken.approve(target, 0);
        }
        fromToken.approve(target, amount);
        require(target.call(data));
    }

    function transferTokenAmount(address target, bytes data, IERC20 fromToken, uint256 amount) external {

        require(fromToken.transfer(target, amount));
        if (data.length != 0) {
            require(target.call(data));
        }
    }

    function transferTokenProportion(address target, bytes data, IERC20 fromToken, uint256 mul, uint256 div) external {

        uint256 amount = fromToken.balanceOf(this).mul(mul).div(div);
        require(fromToken.transfer(target, amount));
        if (data.length != 0) {
            require(target.call(data));
        }
    }

    function transferTokenProportionToOrigin(IERC20 token, uint256 mul, uint256 div) external {

        uint256 amount = token.balanceOf(this).mul(mul).div(div);
        require(token.transfer(tx.origin, amount));
    }


    function kyberSendEthProportion(IKyberNetworkProxy kyber, IERC20 fromToken, address toToken, uint256 mul, uint256 div) external {

        uint256 value = address(this).balance.mul(mul).div(div);
        kyber.trade.value(value)(
            fromToken,
            value,
            toToken,
            this,
            1 << 255,
            0,
            0
        );
    }

    function kyberApproveTokenAmount(IKyberNetworkProxy kyber, IERC20 fromToken, address toToken, uint256 amount) external {

        if (fromToken.allowance(this, kyber) == 0) {
            fromToken.approve(kyber, uint256(-1));
        }
        kyber.trade(
            fromToken,
            amount,
            toToken,
            this,
            1 << 255,
            0,
            0
        );
    }

    function kyberApproveTokenProportion(IKyberNetworkProxy kyber, IERC20 fromToken, address toToken, uint256 mul, uint256 div) external {

        uint256 amount = fromToken.balanceOf(this).mul(mul).div(div);
        this.kyberApproveTokenAmount(kyber, fromToken, toToken, amount);
    }
}