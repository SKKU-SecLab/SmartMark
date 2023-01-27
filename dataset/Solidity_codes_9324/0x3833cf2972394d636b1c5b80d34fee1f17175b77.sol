


contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




interface IKULAPDex {


  function trade(
      uint256   tradingProxyIndex,
      ERC20     src,
      uint256   srcAmount,
      ERC20     dest,
      uint256   minDestAmount,
      uint256   partnerIndex
    )
    external
    payable
    returns(uint256);

  
    function tradeRoutes(
      uint256   srcAmount,
      uint256   minDestAmount,
      uint256[] calldata routes,
      ERC20[]   calldata srcTokens,
      ERC20[]   calldata destTokens,
      uint256   partnerIndex
    )
    external
    payable
    returns(uint256);

  
    function splitTrades(
      uint256[] calldata routes,
      ERC20     src,
      uint256[] calldata srcAmounts,
      ERC20     dest,
      uint256   minDestAmount,
      uint256   partnerIndex
    )
    external
    payable
    returns(uint256);

  
  function getDestinationReturnAmount(
    uint256 tradingProxyIndex,
    ERC20   src,
    ERC20   dest,
    uint256 srcAmount,
    uint256 partnerIndex
  )
    external
    view
    returns(uint256);

  
  function getDestinationReturnAmountForSplitTrades(
    uint256[] calldata routes,
    ERC20     src,
    uint256[] calldata srcAmounts,
    ERC20     dest,
    uint256   partnerIndex
  )
    external
    view
    returns(uint256);

  
  function getDestinationReturnAmountForTradeRoutes(
    ERC20     src,
    uint256   srcAmount,
    ERC20     dest,
    address[] calldata _tradingPaths,
    uint256   partnerIndex
  )
    external
    view
    returns(uint256);

}




interface IKULAPTradingProxy {

    event Trade(ERC20 _src, uint256 _srcAmount, ERC20 _dest, uint256 _destAmount);

    function trade(
        ERC20 _src,
        ERC20 _dest,
        uint256 _srcAmount
    )
        external
        payable
        returns(uint256 _destAmount);


    function getDestinationReturnAmount(
        ERC20 _src,
        ERC20 _dest,
        uint256 _srcAmount
    )
        external
        view
        returns(uint256 _destAmount);


}


interface ERC20 {

    function totalSupply() external view returns (uint supply);

    function balanceOf(address _owner) external view returns (uint balance);

    function transfer(address _to, uint _value) external; // Some ERC20 doesn't have return

    function transferFrom(address _from, address _to, uint _value) external; // Some ERC20 doesn't have return

    function approve(address _spender, uint _value) external; // Some ERC20 doesn't have return

    function allowance(address _owner, address _spender) external view returns (uint remaining);

    function decimals() external view returns(uint digits);

    event Approval(address indexed _owner, address indexed _spender, uint _value);
}


contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
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



contract ReentrancyGuard {

    bool private _notEntered;

    constructor () internal {
        _notEntered = true;
    }

    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }
}

pragma solidity 0.5.17;


contract ProxyManagement is Ownable {

    struct Proxy {
      string name;
      bool enable;
      IKULAPTradingProxy proxy;
    }

    event AddedTradingProxy(
        address indexed addedBy,
        string name,
        IKULAPTradingProxy indexed proxyAddress,
        uint256 indexed index
    );

    event EnabledTradingProxy(
        address indexed enabledBy,
        string name,
        IKULAPTradingProxy proxyAddress,
        uint256 indexed index
    );

    event DisabledTradingProxy(
        address indexed disabledBy,
        string name,
        IKULAPTradingProxy indexed proxyAddress,
        uint256 indexed index
    );

    Proxy[] public tradingProxies; // list of trading proxies

    modifier onlyTradingProxyEnabled(uint _index) {

        require(tradingProxies[_index].enable == true, "This trading proxy is disabled");
        _;
    }

    modifier onlyTradingProxyDisabled(uint _index) {

        require(tradingProxies[_index].enable == false, "This trading proxy is enabled");
        _;
    }

    function addTradingProxy(
        string memory _name,
        IKULAPTradingProxy _proxyAddress
    )
      public
      onlyOwner
    {

        tradingProxies.push(Proxy({
            name: _name,
            enable: true,
            proxy: _proxyAddress
        }));
        emit AddedTradingProxy(msg.sender, _name, _proxyAddress, tradingProxies.length - 1);
    }

    function disableTradingProxy(
        uint256 _index
    )
        public
        onlyOwner
        onlyTradingProxyEnabled(_index)
    {

        tradingProxies[_index].enable = false;
        emit DisabledTradingProxy(msg.sender, tradingProxies[_index].name, tradingProxies[_index].proxy, _index);
    }

    function enableTradingProxy(
        uint256 _index
    )
        public
        onlyOwner
        onlyTradingProxyDisabled(_index)
    {

        tradingProxies[_index].enable = true;
        emit EnabledTradingProxy(msg.sender, tradingProxies[_index].name, tradingProxies[_index].proxy, _index);
    }

    function getProxyCount() public view returns (uint256) {

        return tradingProxies.length;
    }

    function isTradingProxyEnable(uint256 _index) public view returns (bool) {

        return tradingProxies[_index].enable;
    }
}

contract Partnership is ProxyManagement {

    using SafeMath for uint256;

    struct Partner {
      address wallet;       // To receive fee on the KULAP Dex network
      uint16 fee;           // fee in bps
      bytes16 name;         // Partner reference
    }

    mapping(uint256 => Partner) public partners;

    constructor() public {
        Partner memory partner = Partner(msg.sender, 0, "KULAP");
        partners[0] = partner;
    }

    function updatePartner(uint256 index, address wallet, uint16 fee, bytes16 name)
        external
        onlyOwner
    {

        Partner memory partner = Partner(wallet, fee, name);
        partners[index] = partner;
    }

    function amountWithFee(uint256 amount, uint256 partnerIndex)
        internal
        view
        returns(uint256 remainingAmount)
    {

        Partner storage partner = partners[partnerIndex];
        if (partner.fee == 0) {
            return amount;
        }
        uint256 fee = amount.mul(partner.fee).div(10000);
        return amount.sub(fee);
    }

    function collectFee(uint256 partnerIndex, uint256 amount, ERC20 token)
        internal
        returns(uint256 remainingAmount)
    {

        Partner storage partner = partners[partnerIndex];
        if (partner.fee == 0) {
            return amount;
        }
        uint256 fee = amount.mul(partner.fee).div(10000);
        require(fee < amount, "fee exceeds return amount!");
        token.transfer(partner.wallet, fee);
        return amount.sub(fee);
    }
}

contract KULAPDex is IKULAPDex, Partnership, ReentrancyGuard {

    event Trade(
        address indexed srcAsset, // Source
        uint256         srcAmount,
        address indexed destAsset, // Destination
        uint256         destAmount,
        address indexed trader, // User
        uint256         fee // System fee
    );

    using SafeMath for uint256;
    ERC20 public etherERC20 = ERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    function _tradeEtherToToken(
        uint256 tradingProxyIndex,
        uint256 srcAmount,
        ERC20 dest
    )
        private
        returns(uint256)
    {

        IKULAPTradingProxy tradingProxy = tradingProxies[tradingProxyIndex].proxy;
        uint256 destAmount = tradingProxy.trade.value(srcAmount)(
            etherERC20,
            dest,
            srcAmount
        );
        return destAmount;
    }

    function () external payable {}

    function _tradeTokenToEther(
        uint256 tradingProxyIndex,
        ERC20 src,
        uint256 srcAmount
    )
        private
        returns(uint256)
    {

        IKULAPTradingProxy tradingProxy = tradingProxies[tradingProxyIndex].proxy;
        src.approve(address(tradingProxy), srcAmount);
        uint256 destAmount = tradingProxy.trade(
            src,
            etherERC20,
            srcAmount
        );
        return destAmount;
    }

    function _tradeTokenToToken(
        uint256 tradingProxyIndex,
        ERC20 src,
        uint256 srcAmount,
        ERC20 dest
    )
        private
        returns(uint256)
    {

        IKULAPTradingProxy tradingProxy = tradingProxies[tradingProxyIndex].proxy;
        src.approve(address(tradingProxy), srcAmount);
        uint256 destAmount = tradingProxy.trade(
            src,
            dest,
            srcAmount
        );
        return destAmount;
    }

    function _trade(
        uint256             _tradingProxyIndex,
        ERC20               _src,
        uint256             _srcAmount,
        ERC20               _dest
    )
        private
        onlyTradingProxyEnabled(_tradingProxyIndex)
        returns(uint256)
    {

        uint256 destAmount;
        uint256 srcAmountBefore;
        uint256 destAmountBefore;

        if (etherERC20 == _src) { // Source
            srcAmountBefore = address(this).balance;
        } else {
            srcAmountBefore = _src.balanceOf(address(this));
        }
        if (etherERC20 == _dest) { // Dest
            destAmountBefore = address(this).balance;
        } else {
            destAmountBefore = _dest.balanceOf(address(this));
        }
        if (etherERC20 == _src) { // Trade ETH -> Token
            destAmount = _tradeEtherToToken(_tradingProxyIndex, _srcAmount, _dest);
        } else if (etherERC20 == _dest) { // Trade Token -> ETH
            destAmount = _tradeTokenToEther(_tradingProxyIndex, _src, _srcAmount);
        } else { // Trade Token -> Token
            destAmount = _tradeTokenToToken(_tradingProxyIndex, _src, _srcAmount, _dest);
        }

        if (etherERC20 == _src) { // Source
            require(address(this).balance == srcAmountBefore.sub(_srcAmount), "source amount mismatch after trade");
        } else {
            require(_src.balanceOf(address(this)) == srcAmountBefore.sub(_srcAmount), "source amount mismatch after trade");
        }
        if (etherERC20 == _dest) { // Dest
            require(address(this).balance == destAmountBefore.add(destAmount), "destination amount mismatch after trade");
        } else {
            require(_dest.balanceOf(address(this)) == destAmountBefore.add(destAmount), "destination amount mismatch after trade");
        }
        return destAmount;
    }

    function trade(
        uint256   tradingProxyIndex,
        ERC20     src,
        uint256   srcAmount,
        ERC20     dest,
        uint256   minDestAmount,
        uint256   partnerIndex
    )
        external
        payable
        nonReentrant
        returns(uint256)
    {

        uint256 destAmount;
        if (etherERC20 != src) {
            src.transferFrom(msg.sender, address(this), srcAmount); // Transfer token to this address
        }
        destAmount = _trade(tradingProxyIndex, src, srcAmount, dest);
        require(destAmount >= minDestAmount, "destination amount is too low.");
        if (etherERC20 == dest) {
            (bool success, ) = msg.sender.call.value(destAmount)(""); // Send back ether to sender
            require(success, "Transfer ether back to caller failed.");
        } else { // Send back token to sender
            dest.transfer(msg.sender, destAmount);
        }

        uint256 remainingAmount = collectFee(partnerIndex, destAmount, dest);

        emit Trade(address(src), srcAmount, address(dest), remainingAmount, msg.sender, 0);
        return remainingAmount;
    }

    function tradeRoutes(
        uint256   srcAmount,
        uint256   minDestAmount,
        uint256[] calldata routes,
        ERC20[]   calldata srcTokens,
        ERC20[]   calldata destTokens,
        uint256   partnerIndex
    )
        external
        payable
        nonReentrant
        returns(uint256)
    {

        require(routes.length > 0, "routes can not be empty");
        require(routes.length == srcTokens.length && routes.length == destTokens.length, "Parameter value lengths mismatch");

        uint256 remainingAmount;
        {
          uint256 destAmount;
          if (etherERC20 != srcTokens[0]) {
              srcTokens[0].transferFrom(msg.sender, address(this), srcAmount); // Transfer token to This address
          }
          uint256 pathSrcAmount = srcAmount;
          for (uint i = 0; i < routes.length; i++) {
              uint256 tradingProxyIndex = routes[i];
              ERC20 pathSrc = srcTokens[i];
              ERC20 pathDest = destTokens[i];
              destAmount = _trade(tradingProxyIndex, pathSrc, pathSrcAmount, pathDest);
              pathSrcAmount = destAmount;
          }
          require(destAmount >= minDestAmount, "destination amount is too low.");
          if (etherERC20 == destTokens[destTokens.length - 1]) { // Trade Any -> ETH
              (bool success,) = msg.sender.call.value(destAmount)("");
              require(success, "Transfer ether back to caller failed.");
          } else { // Trade Any -> Token
              destTokens[destTokens.length - 1].transfer(msg.sender, destAmount);
          }

          remainingAmount = collectFee(partnerIndex, destAmount, destTokens[destTokens.length - 1]);
        }

        emit Trade(address(srcTokens[0]), srcAmount, address(destTokens[destTokens.length - 1]), remainingAmount, msg.sender, 0);
        return remainingAmount;
    }

    function splitTrades(
        uint256[] calldata routes,
        ERC20     src,
        uint256[] calldata srcAmounts,
        ERC20     dest,
        uint256   minDestAmount,
        uint256   partnerIndex
    )
        external
        payable
        nonReentrant
        returns(uint256)
    {

        require(routes.length > 0, "routes can not be empty");
        require(routes.length == srcAmounts.length, "routes and srcAmounts lengths mismatch");
        uint256 srcAmount = srcAmounts[0];
        uint256 destAmount = 0;
        if (etherERC20 != src) {
            src.transferFrom(msg.sender, address(this), srcAmount); // Transfer token to this address
        }
        for (uint i = 0; i < routes.length; i++) {
            uint256 tradingProxyIndex = routes[i];
            uint256 amount = srcAmounts[i];
            destAmount = destAmount.add(_trade(tradingProxyIndex, src, amount, dest));
        }
        require(destAmount >= minDestAmount, "destination amount is too low.");
        if (etherERC20 == dest) {
            (bool success, ) = msg.sender.call.value(destAmount)(""); // Send back ether to sender
            require(success, "Transfer ether back to caller failed.");
        } else { // Send back token to sender
            dest.transfer(msg.sender, destAmount);
        }

        uint256 remainingAmount = collectFee(partnerIndex, destAmount, dest);

        emit Trade(address(src), srcAmount, address(dest), remainingAmount, msg.sender, 0);
        return remainingAmount;
    }

    function getDestinationReturnAmount(
        uint256 tradingProxyIndex,
        ERC20   src,
        ERC20   dest,
        uint256 srcAmount,
        uint256 partnerIndex
    )
        external
        view
        returns(uint256)
    {

        IKULAPTradingProxy tradingProxy = tradingProxies[tradingProxyIndex].proxy;
        uint256 destAmount = tradingProxy.getDestinationReturnAmount(src, dest, srcAmount);
        return amountWithFee(destAmount, partnerIndex);
    }

    function getDestinationReturnAmountForSplitTrades(
        uint256[] calldata routes,
        ERC20     src,
        uint256[] calldata srcAmounts,
        ERC20     dest,
        uint256   partnerIndex
    )
        external
        view
        returns(uint256)
    {

        require(routes.length > 0, "routes can not be empty");
        require(routes.length == srcAmounts.length, "routes and srcAmounts lengths mismatch");
        uint256 destAmount = 0;
        
        for (uint i = 0; i < routes.length; i++) {
            uint256 tradingProxyIndex = routes[i];
            uint256 amount = srcAmounts[i];
            IKULAPTradingProxy tradingProxy = tradingProxies[tradingProxyIndex].proxy;
            destAmount = destAmount.add(tradingProxy.getDestinationReturnAmount(src, dest, amount));
        }
        return amountWithFee(destAmount, partnerIndex);
    }

    function getDestinationReturnAmountForTradeRoutes(
        ERC20     src,
        uint256   srcAmount,
        ERC20     dest,
        address[] calldata _tradingPaths,
        uint256   partnerIndex
    )
        external
        view
        returns(uint256)
    {

        src;
        dest;
        uint256 destAmount;
        uint256 pathSrcAmount = srcAmount;
        for (uint i = 0; i < _tradingPaths.length; i += 3) {
            uint256 tradingProxyIndex = uint256(_tradingPaths[i]);
            ERC20 pathSrc = ERC20(_tradingPaths[i+1]);
            ERC20 pathDest = ERC20(_tradingPaths[i+2]);

            IKULAPTradingProxy tradingProxy = tradingProxies[tradingProxyIndex].proxy;
            destAmount = tradingProxy.getDestinationReturnAmount(pathSrc, pathDest, pathSrcAmount);
            pathSrcAmount = destAmount;
        }
        return amountWithFee(destAmount, partnerIndex);
    }

    function collectRemainingToken(
        ERC20 token,
        uint256 amount
    )
      public
      onlyOwner
    {

        token.transfer(msg.sender, amount);
    }

    function collectRemainingEther(
        uint256 amount
    )
      public
      onlyOwner
    {

        (bool success, ) = msg.sender.call.value(amount)(""); // Send back ether to sender
        require(success, "Transfer ether back to caller failed.");
    }
}