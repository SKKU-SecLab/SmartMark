
pragma solidity ^0.5.12;

contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}

contract OpenZeppelinUpgradesOwnable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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
}

interface Erc20 {

    function approve(address, uint256) external returns (bool);

    function transfer(address, uint256) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function balanceOf(address _owner) external view returns (uint256 balance);

}

interface CErc20 {

    function mint(uint256) external returns (uint256);

    function borrow(uint256) external returns (uint256);

    function borrowRatePerBlock() external view returns (uint256);

    function borrowBalanceCurrent(address) external returns (uint256);

    function repayBorrow(uint256) external returns (uint256);

    function redeemUnderlying(uint) external returns (uint);

    function redeem(uint) external returns (uint);

}

interface CEth {

    function mint() external payable;

    function borrow(uint256) external returns (uint256);

    function repayBorrow() external payable;

    function borrowBalanceCurrent(address) external returns (uint256);

}

interface Comptroller {

    function markets(address) external returns (bool, uint256);

    function enterMarkets(address[] calldata)
        external
        returns (uint256[] memory);

    function getAccountLiquidity(address)
        external
        view
        returns (uint256, uint256, uint256);

}

interface PriceOracle {

    function getUnderlyingPrice(address) external view returns (uint256);

}

interface CurveExchange {

    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external;

    function get_dy(int128, int128 j, uint256 dx) external view returns (uint256);

}

interface CurveExchangeAdapter {

    function swapThenBurn(bytes calldata _btcDestination, uint256 _amount, uint256 _minRenbtcAmount) external;

}

interface Gateway {

    function mint(bytes32 _pHash, uint256 _amount, bytes32 _nHash, bytes calldata _sig) external returns (uint256);

    function burn(bytes calldata _to, uint256 _amount) external returns (uint256);

}

interface GatewayRegistry {

    function getGatewayBySymbol(string calldata _tokenSymbol) external view returns (Gateway);

    function getGatewayByToken(address  _tokenAddress) external view returns (Gateway);

    function getTokenBySymbol(string calldata _tokenSymbol) external view returns (Erc20);

}

contract CompoundBorrower is Initializable {

    using SafeMath for uint256;
    address public owner;
    Erc20 public wbtc;
    CurveExchangeAdapter public curveAdapter;
    Erc20 public activeToken;
    CErc20 public activeCToken;
    
    function initialize(
        address _owner,
        address _wbtcToken,
        address _curveAdapter
    ) public {

        owner = _owner;
        wbtc = Erc20(_wbtcToken);
        curveAdapter = CurveExchangeAdapter(_curveAdapter);
        require(wbtc.approve(address(curveAdapter), uint256(-1)));
    }
    
    function borrowWithErc20AndBurn(
        address _tokenAddress,
        address _cTokenAddress,
        uint256 _tokenAmount,
        address _comptrollerAddress,
        address _cWbtcAddress,
        uint256 _wbtcAmount,
        uint256 _minRenbtcAmount,
        bytes calldata _btcDestination
    ) external {

        Erc20 token = Erc20(_tokenAddress);
        token.transferFrom(msg.sender, address(this), _tokenAmount);
        uint256 startWbtcBal = wbtc.balanceOf(address(this));
        
        token.approve(address(_cTokenAddress), uint256(-1));
        token.approve(address(_cWbtcAddress), uint256(-1));
        wbtc.approve(address(_cTokenAddress), uint256(-1));
        wbtc.approve(address(_cWbtcAddress), uint256(-1));
        
        
        borrowWbtcWithErc20(
            _cTokenAddress,
            _tokenAmount,
            _comptrollerAddress,
            _cWbtcAddress,
            _wbtcAmount
        );
        
        uint256 endWbtcBal = startWbtcBal.sub(wbtc.balanceOf(address(this)));
        curveAdapter.swapThenBurn(_btcDestination, endWbtcBal, _minRenbtcAmount);
        
        activeToken = Erc20(_tokenAddress);
        activeCToken = CErc20(_cTokenAddress);
    }
    
    function borrowWithErc20(
        address _tokenAddress,
        address _cTokenAddress,
        uint256 _tokenAmount,
        address _comptrollerAddress,
        address _cWbtcAddress,
        uint256 _wbtcAmount,
        uint256 _minRenbtcAmount,
        bytes calldata _btcDestination
    ) external {

        Erc20 token = Erc20(_tokenAddress);
        token.transferFrom(msg.sender, address(this), _tokenAmount);
        
        token.approve(address(_cTokenAddress), uint256(-1));
        token.approve(address(_cWbtcAddress), uint256(-1));
        wbtc.approve(address(_cTokenAddress), uint256(-1));
        wbtc.approve(address(_cWbtcAddress), uint256(-1));
        
        
        borrowWbtcWithErc20(
            _cTokenAddress,
            _tokenAmount,
            _comptrollerAddress,
            _cWbtcAddress,
            _wbtcAmount
        );
        
        curveAdapter.swapThenBurn(_btcDestination, _wbtcAmount, _minRenbtcAmount);
        
        activeToken = Erc20(_tokenAddress);
        activeCToken = CErc20(_cTokenAddress);
    }
    
    function borrowWbtcWithErc20(
        address _cTokenAddress,
        uint256 _tokenAmount,
        address _comptrollerAddress,
        address _cWbtcAddress,
        uint256 _wbtcAmount
    ) public returns (uint256) {

        CErc20 cToken = CErc20(_cTokenAddress);
        Comptroller comptroller = Comptroller(_comptrollerAddress);
        CErc20 cWbtc = CErc20(_cWbtcAddress);
        
        cToken.mint(_tokenAmount);
        
        address[] memory cTokens = new address[](1);
        cTokens[0] = _cTokenAddress;
        uint256[] memory errors = comptroller.enterMarkets(cTokens);
        if (errors[0] != 0) {
            revert("Comptroller.enterMarkets failed.");
        }
        
        (uint256 error, uint256 liquidity, uint256 shortfall) = comptroller
            .getAccountLiquidity(address(this));
        if (error != 0) {
            revert("Comptroller.getAccountLiquidity failed.");
        }
        require(shortfall == 0, "account underwater");
        require(liquidity > 0, "account has excess collateral");
        
        cWbtc.borrow(_wbtcAmount);
        
        uint256 borrows = cWbtc.borrowBalanceCurrent(address(this));
        return borrows;
    }
    
    function repayBorrow(address _cWbtcAddress, uint _repayAmount) public {

        CErc20 cWbtc = CErc20(_cWbtcAddress);
        wbtc.transferFrom(msg.sender, address(this), _repayAmount);
        cWbtc.repayBorrow(_repayAmount);
    }
    
    function redeemUnderlyingAndWithdraw(address _cTokenAddress, address _tokenAddress, uint _amount) public {

        CErc20(_cTokenAddress).redeemUnderlying(_amount);
        Erc20(_tokenAddress).transfer(owner, _amount);
    }
    
    function withdrawToken(address _tokenAddress, uint _withdrawAmount) public {

        Erc20(_tokenAddress).transfer(owner, _withdrawAmount);
    }
}