
pragma solidity 0.4.24;

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)
    public view returns (uint256);


  function transferFrom(address from, address to, uint256 value)
    public returns (bool);


  function approve(address spender, uint256 value) public returns (bool);

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

pragma solidity 0.4.24;

contract Transfer {


    address constant public ETH = 0x0;

    function transfer(address token, address to, uint256 amount) internal returns (bool) {

        if (token == ETH) {
            to.transfer(amount);
        } else {
            require(ERC20(token).transfer(to, amount));
        }
        return true;
    }

    function transferFrom(
        address token,
        address from,
        address to,
        uint256 amount
    ) 
        internal
        returns (bool)
    {

        require(token == ETH && msg.value == amount || msg.value == 0);

        if (token != ETH) {
            require(ERC20(token).transferFrom(from, to, amount));
        }
        return true;
    }

}

contract Ownable {

  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);
  }

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}


interface IERC20 {

    function balanceOf(address _owner) public view returns (uint balance);

    function transfer(address _to, uint _value) public returns (bool success);

}


contract Withdrawable is Ownable {

    function () public payable {}

    function withdraw() public onlyOwner {

        owner.transfer(address(this).balance);
    }
    
    function withdrawToken(address token) public onlyOwner returns (bool) {

        IERC20 foreignToken = IERC20(token);
        uint256 amount = foreignToken.balanceOf(address(this));
        return foreignToken.transfer(owner, amount);
    }
}

pragma solidity 0.4.24;

contract ExternalCall {

    function external_call(address destination, uint value, uint dataLength, bytes data) internal returns (bool) {

        bool result;
        assembly {
            let x := mload(0x40)   // "Allocate" memory for output (0x40 is where "free memory" pointer is stored by convention)
            let d := add(data, 32) // First 32 bytes are the padded length of data, so exclude that
            result := call(
                sub(gas, 34710),   // 34710 is the value that solidity is currently emitting
                destination,
                value,
                d,
                dataLength,        // Size of the input (in bytes) - this is what fixes the padding problem
                x,
                0                  // Output is ignored, therefore the output size is zero
            )
        }
        return result;
    }
}


pragma solidity 0.4.24;

contract TradeExecutor is Transfer, Withdrawable, ExternalCall {


    function () public payable {}

    function trade(
        address[2] wrappers,
        address token,
        bytes trade1,
        bytes trade2
    )
        external
        payable
    {

        require(execute(wrappers[0], msg.value, trade1));

        uint256 tokenBalance = IERC20(token).balanceOf(this);

        transfer(token, wrappers[1], tokenBalance);

        require(execute(wrappers[1], 0, trade2));
        
        msg.sender.transfer(address(this).balance);
    }

    function tradeForTokens(
        address[2] wrappers,
        address token,
        bytes trade1,
        bytes trade2
    )
        external
    {

        uint256 tokenBalance = IERC20(token).balanceOf(this);
        transfer(token, wrappers[0], tokenBalance);

        require(execute(wrappers[0], 0, trade1));

        uint256 balance = address(this).balance;

        require(execute(wrappers[1], balance, trade2));

        tokenBalance = IERC20(token).balanceOf(this);
        require(IERC20(token).transfer(msg.sender, tokenBalance));
    }

    function execute(address wrapper, uint256 value, bytes data) private returns (bool) {

        return external_call(wrapper, value, data.length, data);
    }

}