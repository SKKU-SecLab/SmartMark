

pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
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

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;



contract ERC20 is IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {

        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 value) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}


pragma solidity ^0.5.0;

contract Ownable {

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

        require(isOwner(), "Ownable: caller is not the owner");
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

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity ^0.5.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}


pragma solidity 0.5.11;


interface IWhitelisted {


    function isWhitelisted(address account) external view returns (bool);

}


pragma solidity 0.5.11;



interface IExchange {


    function swap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 fromAmount,
        uint256 toAmount,
        address exchange,
        bytes calldata payload) external payable returns (uint256);


    function buy(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 fromAmount,
        uint256 toAmount,
        address exchange,
        bytes calldata payload) external payable returns (uint256);

}


pragma solidity ^0.5.0;




library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity 0.5.11;


interface ITokenTransferProxy {


    function transferFrom(
        address token,
        address from,
        address to,
        uint256 amount
    )
        external;


    function freeGSTTokens(uint256 tokensToFree) external;

}


pragma solidity 0.5.11;







library Utils {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address constant ETH_ADDRESS = address(
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
    );

    uint256 constant MAX_UINT = 2 ** 256 - 1;

    struct Route {
        address payable exchange;
        address targetExchange;
        uint percent;
        bytes payload;
        uint256 networkFee;
    }

    struct Path {
        address to;
        uint256 totalNetworkFee;
        Route[] routes;
    }

    struct BuyRoute {
        address payable exchange;
        address targetExchange;
        uint256 fromAmount;
        uint256 toAmount;
        bytes payload;
        uint256 networkFee;
    }

    function ethAddress() internal pure returns (address) {return ETH_ADDRESS;}


    function maxUint() internal pure returns (uint256) {return MAX_UINT;}


    function approve(
        address addressToApprove,
        address token
    ) internal {

        if (token != ETH_ADDRESS) {
            IERC20 _token = IERC20(token);

            uint allowance = _token.allowance(address(this), addressToApprove);

            if (allowance < MAX_UINT / 10) {
                _token.safeApprove(addressToApprove, MAX_UINT);
            }
        }
    }

    function transferTokens(
        address token,
        address payable destination,
        uint256 amount
    )
    internal
    {

        if (token == ETH_ADDRESS) {
            destination.transfer(amount);
        }
        else {
            IERC20(token).safeTransfer(destination, amount);
        }
    }

    function tokenBalance(
        address token,
        address account
    )
    internal
    view
    returns (uint256)
    {

        if (token == ETH_ADDRESS) {
            return account.balance;
        } else {
            return IERC20(token).balanceOf(account);
        }
    }

    function refundGas(address tokenProxy, uint256 initialGas, uint256 mintPrice) internal {


        uint256 mintBase = 32254;
        uint256 mintToken = 36543;
        uint256 freeBase = 14154;
        uint256 freeToken = 6870;
        uint256 reimburse = 24000;

        uint256 tokens = initialGas.sub(
            gasleft()).add(freeBase).div(reimburse.mul(2).sub(freeToken)
        );

        uint256 mintCost = mintBase.add(tokens.mul(mintToken));
        uint256 freeCost = freeBase.add(tokens.mul(freeToken));
        uint256 maxreimburse = tokens.mul(reimburse);

        uint256 efficiency = maxreimburse.mul(tx.gasprice).mul(100).div(
            mintCost.mul(mintPrice).add(freeCost.mul(tx.gasprice))
        );

        if (efficiency > 100) {
            freeGasTokens(tokenProxy, tokens);
        }
    }

    function freeGasTokens(address tokenProxy, uint256 tokens) internal {


        uint256 tokensToFree = tokens;
        uint256 safeNumTokens = 0;
        uint256 gas = gasleft();

        if (gas >= 27710) {
            safeNumTokens = gas.sub(27710).div(1148 + 5722 + 150);
        }

        if (tokensToFree > safeNumTokens) {
            tokensToFree = safeNumTokens;
        }

        ITokenTransferProxy(tokenProxy).freeGSTTokens(tokensToFree);

    }
}


pragma solidity 0.5.11;

interface IGST2 {


    function freeUpTo(uint256 value) external returns (uint256 freed);


    function freeFromUpTo(address from, uint256 value) external returns (uint256 freed);


    function balanceOf(address who) external view returns (uint256);


    function mint(uint256 value) external;

}


pragma solidity 0.5.11;






contract TokenTransferProxy is Ownable {

    using SafeERC20 for IERC20;

    IGST2 private _gst2;

    address private _gstHolder;

    constructor(address gst2, address gstHolder) public {
        _gst2 = IGST2(gst2);
        _gstHolder = gstHolder;
    }

    function getGSTHolder() external view returns(address) {

        return _gstHolder;
    }

    function getGST() external view returns(address) {

        return address(_gst2);
    }

    function changeGSTTokenHolder(address gstHolder) external onlyOwner {

        _gstHolder = gstHolder;

    }

    function transferFrom(
        address token,
        address from,
        address to,
        uint256 amount
    )
        external
        onlyOwner
    {

        IERC20(token).safeTransferFrom(from, to, amount);
    }

    function freeGSTTokens(uint256 tokensToFree) external onlyOwner {

        _gst2.freeFromUpTo(_gstHolder, tokensToFree);
    }

}


pragma solidity 0.5.11;


interface IPartnerRegistry {


    function getPartnerContract(string calldata referralId) external view returns(address);


    function addPartner(
        string calldata referralId,
        address feeWallet,
        uint256 fee,
        uint256 paraswapShare,
        uint256 partnerShare,
        address owner
    )
        external;


    function removePartner(string calldata referralId) external;

}


pragma solidity 0.5.11;


interface IPartner {


    function getReferralId() external view returns(string memory);


    function getFeeWallet() external view returns(address payable);


    function getFee() external view returns(uint256);


    function getPartnerShare() external returns(uint256);


    function getParaswapShare() external returns(uint256);


    function changeFeeWallet(address payable feeWallet) external;


    function changeFee(uint256 newFee) external;

}


pragma solidity 0.5.11;
pragma experimental ABIEncoderV2;












contract AugustusSwapper is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    TokenTransferProxy private _tokenTransferProxy;

    bool private _paused;

    IWhitelisted private _whitelisted;

    IPartnerRegistry private _partnerRegistry;
    address payable private _feeWallet;

    event Paused();
    event Unpaused();

    event Swapped(
        address initiator,
        address indexed beneficiary,
        address indexed srcToken,
        address indexed destToken,
        uint256 srcAmount,
        uint256 receivedAmount,
        uint256 expectedAmount,
        string referrer
    );

    event Bought(
        address initiator,
        address indexed beneficiary,
        address indexed srcToken,
        address indexed destToken,
        uint256 srcAmount,
        uint256 receivedAmount,
        uint256 expectedAmount,
        string referrer
    );

    event Donation(address indexed receiver, uint256 donationPercentage);

    event FeeTaken(
        uint256 fee,
        uint256 partnerShare,
        uint256 paraswapShare
    );

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
        _;
    }

    constructor(
        address whitelist,
        address gasToken,
        address partnerRegistry,
        address payable feeWallet,
        address gstHolder
    )
        public
    {

        _partnerRegistry = IPartnerRegistry(partnerRegistry);
        _tokenTransferProxy = new TokenTransferProxy(gasToken, gstHolder);
        _whitelisted = IWhitelisted(whitelist);
        _feeWallet = feeWallet;
    }

    function() external payable whenNotPaused {
        address account = msg.sender;
        require(
            account.isContract(),
            "Sender is not a contract"
        );
    }

    function getPartnerRegistry() external view returns(address) {

        return address(_partnerRegistry);
    }

    function getWhitelistAddress() external view returns(address) {

        return address(_whitelisted);
    }

    function getFeeWallet() external view returns(address) {

        return _feeWallet;
    }

    function setFeeWallet(address payable feeWallet) external onlyOwner {

        require(feeWallet != address(0), "Invalid address");
        _feeWallet = feeWallet;
    }

    function setPartnerRegistry(address partnerRegistry) external onlyOwner {

        require(partnerRegistry != address(0), "Invalid address");
        _partnerRegistry = IPartnerRegistry(partnerRegistry);
    }

    function setWhitelistAddress(address whitelisted) external onlyOwner {

        require(whitelisted != address(0), "Invalid whitelist address");
        _whitelisted = IWhitelisted(whitelisted);
    }

    function getTokenTransferProxy() external view returns (address) {

        return address(_tokenTransferProxy);
    }

    function changeGSTHolder(address gstHolder) external onlyOwner {

        require(gstHolder != address(0), "Invalid address");
        _tokenTransferProxy.changeGSTTokenHolder(gstHolder);
    }

    function paused() external view returns (bool) {

        return _paused;
    }

    function pause() external onlyOwner whenNotPaused {

        _paused = true;
        emit Paused();
    }

    function unpause() external onlyOwner whenPaused {

        _paused = false;
        emit Unpaused();
    }

    function ownerTransferTokens(
        address token,
        address payable destination,
        uint256 amount
    )
    external
    onlyOwner
    {

        Utils.transferTokens(token, destination, amount);
    }

    function multiSwap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 fromAmount,
        uint256 toAmount,
        uint256 expectedAmount,
        Utils.Path[] memory path,
        uint256 mintPrice,
        address payable beneficiary,
        uint256 donationPercentage,
        string memory referrer
    )
        public
        payable
        whenNotPaused
        returns (uint256)
    {

        require(bytes(referrer).length > 0, "Invalid referrer");

        require(donationPercentage <= 10000, "Invalid value");

        require(toAmount > 0, "To amount can not be 0");

        uint256 receivedAmount = performSwap(
            fromToken,
            toToken,
            fromAmount,
            toAmount,
            path,
            mintPrice
        );

        takeFeeAndTransferTokens(
            toToken,
            toAmount,
            receivedAmount,
            beneficiary,
            donationPercentage,
            referrer
        );

        uint256 remEthBalance = Utils.tokenBalance(
            Utils.ethAddress(),
            address(this)
        );
        if ( remEthBalance > 0) {
            msg.sender.transfer(remEthBalance);
        }

        require(
            Utils.tokenBalance(address(toToken), address(this)) == 0,
            "Destination tokens are stuck"
        );

        emit Swapped(
            msg.sender,
            beneficiary == address(0)?msg.sender:beneficiary,
            address(fromToken),
            address(toToken),
            fromAmount,
            receivedAmount,
            expectedAmount,
            referrer
        );

        return receivedAmount;
    }

    function buy(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 fromAmount,
        uint256 toAmount,
        uint256 expectedAmount,
        Utils.BuyRoute[] memory route,
        uint256 mintPrice,
        address payable beneficiary,
        uint256 donationPercentage,
        string memory referrer
    )
        public
        payable
        whenNotPaused
        returns (uint256)
    {

        require(bytes(referrer).length > 0, "Invalid referrer");

        require(donationPercentage <= 10000, "Invalid value");

        require(toAmount > 0, "To amount can not be 0");

        uint256 receivedAmount = performBuy(
            fromToken,
            toToken,
            fromAmount,
            toAmount,
            route,
            mintPrice
        );

        takeFeeAndTransferTokens(
            toToken,
            toAmount,
            receivedAmount,
            beneficiary,
            donationPercentage,
            referrer
        );

        uint256 remainingAmount = Utils.tokenBalance(
            address(fromToken),
            address(this)
        );
        Utils.transferTokens(address(fromToken), msg.sender, remainingAmount);

        remainingAmount = Utils.tokenBalance(
            Utils.ethAddress(),
            address(this)
        );
        if ( remainingAmount > 0) {
            Utils.transferTokens(Utils.ethAddress(), msg.sender, remainingAmount);
        }

        require(
            Utils.tokenBalance(address(toToken), address(this)) == 0,
            "Destination tokens are stuck"
        );

        emit Bought(
            msg.sender,
            beneficiary == address(0)?msg.sender:beneficiary,
            address(fromToken),
            address(toToken),
            fromAmount,
            receivedAmount,
            expectedAmount,
            referrer
        );

        return receivedAmount;
    }



    function takeFeeAndTransferTokens(
        IERC20 toToken,
        uint256 toAmount,
        uint256 receivedAmount,
        address payable beneficiary,
        uint256 donationPercentage,
        string memory referrer

    )
        private
    {

        uint256 remainingAmount = receivedAmount;

        uint256 fee = _takeFee(
            toToken,
            receivedAmount,
            referrer
        );
        remainingAmount = receivedAmount.sub(fee);

        if (beneficiary == address(0)){
            Utils.transferTokens(address(toToken), msg.sender, remainingAmount);
        }
        else {
            if (donationPercentage > 0 && donationPercentage < 10000){

                uint256 donationAmount = remainingAmount.mul(donationPercentage).div(10000);

                Utils.transferTokens(
                    address(toToken),
                    msg.sender,
                    remainingAmount.sub(donationAmount)
                );

                remainingAmount = donationAmount;
            }

            if (donationPercentage > 0) {
                emit Donation(beneficiary, donationPercentage);
            }

            Utils.transferTokens(address(toToken), beneficiary, remainingAmount);
        }

    }

    function performSwap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 fromAmount,
        uint256 toAmount,
        Utils.Path[] memory path,
        uint256 mintPrice
    )
        private
        returns(uint256)
    {

        uint initialGas = gasleft();

        uint _fromAmount = fromAmount;

        require(path.length > 0, "Path not provided for swap");
        require(
            path[path.length - 1].to == address(toToken),
            "Last to token does not match toToken"
        );

        if (address(fromToken) != Utils.ethAddress()) {
            _tokenTransferProxy.transferFrom(
                address(fromToken),
                msg.sender,
                address(this),
                fromAmount
            );
        }

        for (uint i = 0; i < path.length; i++) {
            IERC20 _fromToken = i > 0 ? IERC20(path[i - 1].to) : IERC20(fromToken);
            IERC20 _toToken = IERC20(path[i].to);

            if (i > 0 && address(_fromToken) == Utils.ethAddress()) {
                _fromAmount = _fromAmount.sub(path[i].totalNetworkFee);
            }

            uint256 initialFromBalance = Utils.tokenBalance(
                address(_fromToken),
                address(this)
            ).sub(_fromAmount);

            for (uint j = 0; j < path[i].routes.length; j++) {
                Utils.Route memory route = path[i].routes[j];

                uint fromAmountSlice = _fromAmount.mul(route.percent).div(10000);
                uint256 value = route.networkFee;

                if (j == path[i].routes.length.sub(1)) {
                    uint256 remBal = Utils.tokenBalance(address(_fromToken), address(this));

                    fromAmountSlice = remBal;

                    if (address(_fromToken) == Utils.ethAddress()) {
                        fromAmountSlice = fromAmountSlice.sub(value);
                    }
                }

                require(
                    _whitelisted.isWhitelisted(route.exchange),
                    "Exchange not whitelisted"
                );

                IExchange dex = IExchange(route.exchange);

                Utils.approve(route.exchange, address(_fromToken));

                uint256 initialExchangeFromBalance = Utils.tokenBalance(
                    address(_fromToken),
                    route.exchange
                );
                uint256 initialExchangeToBalance = Utils.tokenBalance(
                    address(_toToken),
                    route.exchange
                );

                if (address(_fromToken) == Utils.ethAddress()) {
                    value = value.add(fromAmountSlice);

                    dex.swap.value(value)(_fromToken, _toToken, fromAmountSlice, 1, route.targetExchange, route.payload);
                }
                else {
                    _fromToken.safeTransfer(route.exchange, fromAmountSlice);

                    dex.swap.value(value)(_fromToken, _toToken, fromAmountSlice, 1, route.targetExchange, route.payload);
                }

                require(
                    Utils.tokenBalance(address(_toToken), route.exchange) <= initialExchangeToBalance,
                    "Destination tokens are stuck in exchange"
                );
                require(
                    Utils.tokenBalance(address(_fromToken), route.exchange) <= initialExchangeFromBalance,
                    "Source tokens are stuck in exchange"
                );
            }

            _fromAmount = Utils.tokenBalance(address(_toToken), address(this));

            require(
                Utils.tokenBalance(address(_fromToken), address(this)) <= initialFromBalance,
                "From tokens are stuck"
            );
        }

        uint256 receivedAmount = Utils.tokenBalance(
            address(toToken),
            address(this)
        );
        require(
            receivedAmount >= toAmount,
            "Received amount of tokens are less then expected"
        );

        if (mintPrice > 0) {
            Utils.refundGas(address(_tokenTransferProxy), initialGas, mintPrice);
        }
        return receivedAmount;
    }

    function performBuy(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 fromAmount,
        uint256 toAmount,
        Utils.BuyRoute[] memory routes,
        uint256 mintPrice
    )
        private
        returns(uint256)
    {

        uint initialGas = gasleft();
        IERC20 _fromToken = fromToken;
        IERC20 _toToken = toToken;

        if (address(_fromToken) != Utils.ethAddress()) {
            _tokenTransferProxy.transferFrom(
                address(_fromToken),
                msg.sender,
                address(this),
                fromAmount
            );
        }

        for (uint j = 0; j < routes.length; j++) {
            Utils.BuyRoute memory route = routes[j];

            require(
                _whitelisted.isWhitelisted(route.exchange),
                "Exchange not whitelisted"
            );
            IExchange dex = IExchange(route.exchange);
            Utils.approve(route.exchange, address(_fromToken));

            uint256 initialExchangeFromBalance = Utils.tokenBalance(
                address(_fromToken),
                route.exchange
            );
            uint256 initialExchangeToBalance = Utils.tokenBalance(
                address(_toToken),
                route.exchange
            );
            if (address(_fromToken) == Utils.ethAddress()) {
                uint256 value = route.networkFee.add(route.fromAmount);
                dex.buy.value(value)(
                    _fromToken,
                    _toToken,
                    route.fromAmount,
                    route.toAmount,
                    route.targetExchange,
                    route.payload
                );
            }
            else {
                _fromToken.safeTransfer(route.exchange, route.fromAmount);
                dex.buy.value(route.networkFee)(
                    _fromToken,
                    _toToken,
                    route.fromAmount,
                    route.toAmount,
                    route.targetExchange,
                    route.payload
                );
            }
            require(
                Utils.tokenBalance(address(_toToken), route.exchange) <= initialExchangeToBalance,
                "Destination tokens are stuck in exchange"
            );
            require(
                Utils.tokenBalance(address(_fromToken), route.exchange) <= initialExchangeFromBalance,
                "Source tokens are stuck in exchange"
            );
        }

        uint256 receivedAmount = Utils.tokenBalance(
            address(_toToken),
            address(this)
        );
        require(
            receivedAmount >= toAmount,
            "Received amount of tokens are less then expected tokens"
        );

        if (mintPrice > 0) {
            Utils.refundGas(address(_tokenTransferProxy), initialGas, mintPrice);
        }
        return receivedAmount;
    }

    function _takeFee(
        IERC20 toToken,
        uint256 receivedAmount,
        string memory referrer
    )
        private
        returns(uint256)
    {

        address partnerContract = _partnerRegistry.getPartnerContract(referrer);

        if (partnerContract == address(0)) {
            return 0;
        }

        uint256 feePercent = IPartner(partnerContract).getFee();
        uint256 partnerSharePercent = IPartner(partnerContract).getPartnerShare();
        address payable partnerFeeWallet = IPartner(partnerContract).getFeeWallet();

        uint256 fee = receivedAmount.mul(feePercent).div(10000);
        uint256 partnerShare = fee.mul(partnerSharePercent).div(10000);
        uint256 paraswapShare = fee.sub(partnerShare);

        Utils.transferTokens(address(toToken), partnerFeeWallet, partnerShare);
        Utils.transferTokens(address(toToken), _feeWallet, paraswapShare);

        emit FeeTaken(fee, partnerShare, paraswapShare);
        return fee;
    }
}