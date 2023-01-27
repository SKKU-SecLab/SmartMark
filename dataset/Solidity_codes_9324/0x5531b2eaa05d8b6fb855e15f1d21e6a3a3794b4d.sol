




pragma solidity ^0.5.0;

contract Context {

    constructor() internal {}


    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.5.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() internal {
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

        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}


pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;


            bytes32 accountHash
         = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account)
        internal
        pure
        returns (address payable)
    {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call.value(amount)("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }
}


pragma solidity ^0.5.0;

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}


pragma solidity ^0.5.7;

contract ZapBaseV1 is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    bool public stopped = false;

    mapping(address => bool) public feeWhitelist;

    uint256 public goodwill;
    uint256 affiliateSplit;
    mapping(address => bool) public affiliates;
    mapping(address => mapping(address => uint256)) public affiliateBalance;
    mapping(address => uint256) public totalAffiliateBalance;

    address
        internal constant ETHAddress = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    constructor(uint256 _goodwill, uint256 _affiliateSplit) public {
        goodwill = _goodwill;
        affiliateSplit = _affiliateSplit;
    }

    modifier stopInEmergency {

        if (stopped) {
            revert("Temporarily Paused");
        } else {
            _;
        }
    }

    function _getBalance(address token)
        internal
        view
        returns (uint256 balance)
    {

        if (token == address(0)) {
            balance = address(this).balance;
        } else {
            balance = IERC20(token).balanceOf(address(this));
        }
    }

    function toggleContractActive() public onlyOwner {

        stopped = !stopped;
    }

    function set_feeWhitelist(address zapAddress, bool status)
        external
        onlyOwner
    {

        feeWhitelist[zapAddress] = status;
    }

    function set_new_goodwill(uint256 _new_goodwill) public onlyOwner {

        require(
            _new_goodwill >= 0 && _new_goodwill <= 100,
            "GoodWill Value not allowed"
        );
        goodwill = _new_goodwill;
    }

    function set_new_affiliateSplit(uint256 _new_affiliateSplit)
        external
        onlyOwner
    {

        require(
            _new_affiliateSplit <= 100,
            "Affiliate Split Value not allowed"
        );
        affiliateSplit = _new_affiliateSplit;
    }

    function set_affiliate(address _affiliate, bool _status)
        external
        onlyOwner
    {

        affiliates[_affiliate] = _status;
    }

    function withdrawTokens(address[] calldata tokens) external onlyOwner {

        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 qty;

            if (tokens[i] == ETHAddress) {
                qty = address(this).balance.sub(
                    totalAffiliateBalance[tokens[i]]
                );
                Address.sendValue(Address.toPayable(owner()), qty);
            } else {
                qty = IERC20(tokens[i]).balanceOf(address(this)).sub(
                    totalAffiliateBalance[tokens[i]]
                );
                IERC20(tokens[i]).safeTransfer(owner(), qty);
            }
        }
    }

    function affilliateWithdraw(address[] calldata tokens) external {

        uint256 tokenBal;
        for (uint256 i = 0; i < tokens.length; i++) {
            tokenBal = affiliateBalance[msg.sender][tokens[i]];
            affiliateBalance[msg.sender][tokens[i]] = 0;
            totalAffiliateBalance[tokens[i]] = totalAffiliateBalance[tokens[i]]
                .sub(tokenBal);

            if (tokens[i] == ETHAddress) {
                Address.sendValue(msg.sender, tokenBal);
            } else {
                IERC20(tokens[i]).safeTransfer(msg.sender, tokenBal);
            }
        }
    }

    function() external payable {
        require(msg.sender != tx.origin, "Do not send ETH directly");
    }
}


pragma solidity ^0.5.7;
pragma experimental ABIEncoderV2;

interface IMooniswap {

    function getTokens() external view returns (address[] memory tokens);


    function tokens(uint256 i) external view returns (IERC20);


    function deposit(
        uint256[2] calldata maxAmounts,
        uint256[2] calldata minAmounts
    )
        external
        payable
        returns (uint256 fairSupply, uint256[2] memory receivedAmounts);


    function depositFor(
        uint256[2] calldata maxAmounts,
        uint256[2] calldata minAmounts,
        address target
    )
        external
        payable
        returns (uint256 fairSupply, uint256[2] memory receivedAmounts);

}

contract Mooniswap_ZapIn_V1 is ZapBaseV1 {

    constructor(uint256 _goodwill, uint256 _affiliateSplit)
        public
        ZapBaseV1(_goodwill, _affiliateSplit)
    {}

    event zapIn(address sender, address pool, uint256 tokensRec);


    function ZapIn(
        address fromToken,
        address toPool,
        uint256 minPoolTokens,
        uint256[] calldata fromTokenAmounts,
        address[] calldata swapTargets,
        bytes[] calldata swapData,
        address affiliate
    ) external payable stopInEmergency returns (uint256 lpReceived) {

        uint256[2] memory toInvest = _pullTokens(
            fromToken,
            fromTokenAmounts,
            affiliate
        );

        uint256[] memory amounts = new uint256[](2);

        address[] memory tokens = IMooniswap(toPool).getTokens();

        if (fromToken == tokens[0]) {
            amounts[0] = toInvest[0];
        } else {
            amounts[0] = _fillQuote(
                fromToken,
                tokens[0],
                toInvest[0],
                swapTargets[0],
                swapData[0]
            );
        }
        if (fromToken == tokens[1]) {
            amounts[1] = toInvest[1];
        } else {
            amounts[1] = _fillQuote(
                fromToken,
                tokens[1],
                toInvest[1],
                swapTargets[1],
                swapData[1]
            );
        }

        lpReceived = _inchDeposit(tokens, amounts, toPool);

        require(lpReceived >= minPoolTokens, "ERR: High Slippage");
    }

    function _inchDeposit(
        address[] memory tokens,
        uint256[] memory amounts,
        address toPool
    ) internal returns (uint256 lpReceived) {

        uint256[2] memory minAmounts = [
            amounts[0].mul(90).div(100),
            amounts[1].mul(90).div(100)
        ];
        uint256[2] memory receivedAmounts;

        IERC20(tokens[1]).safeApprove(toPool, 0);
        IERC20(tokens[1]).safeApprove(toPool, amounts[1]);

        if (tokens[0] == address(0)) {
            (lpReceived, receivedAmounts) = IMooniswap(toPool).depositFor.value(
                amounts[0]
            )([amounts[0], amounts[1]], minAmounts, msg.sender);
        } else {
            IERC20(tokens[0]).safeApprove(toPool, 0);
            IERC20(tokens[0]).safeApprove(toPool, amounts[0]);
            (lpReceived, receivedAmounts) = IMooniswap(toPool).depositFor(
                [amounts[0], amounts[1]],
                minAmounts,
                msg.sender
            );
        }

        emit zapIn(msg.sender, toPool, lpReceived);

        for (uint8 i = 0; i < 2; i++) {
            if (amounts[i] > receivedAmounts[i] + 1) {
                _transferTokens(tokens[i], amounts[i].sub(receivedAmounts[i]));
            }
        }
    }

    function _fillQuote(
        address fromTokenAddress,
        address toToken,
        uint256 amount,
        address swapTarget,
        bytes memory swapCallData
    ) internal returns (uint256 amtBought) {

        uint256 valueToSend;
        if (fromTokenAddress == address(0)) {
            valueToSend = amount;
        } else {
            IERC20 fromToken = IERC20(fromTokenAddress);
            fromToken.safeApprove(address(swapTarget), 0);
            fromToken.safeApprove(address(swapTarget), amount);
        }

        uint256 iniBal = _getBalance(toToken);
        (bool success, ) = swapTarget.call.value(valueToSend)(swapCallData);
        require(success, "Error Swapping Tokens");
        uint256 finalBal = _getBalance(toToken);

        amtBought = finalBal.sub(iniBal);
    }

    function _transferTokens(address token, uint256 amt) internal {

        if (token == address(0)) {
            Address.sendValue(msg.sender, amt);
        } else {
            IERC20(token).safeTransfer(msg.sender, amt);
        }
    }

    function _pullTokens(
        address fromToken,
        uint256[] memory fromTokenAmounts,
        address affiliate
    ) internal returns (uint256[2] memory toInvest) {

        if (fromToken == address(0)) {
            require(msg.value > 0, "No eth sent");
            require(
                fromTokenAmounts[0].add(fromTokenAmounts[1]) == msg.value,
                "msg.value != fromTokenAmounts"
            );
        } else {
            require(msg.value == 0, "Eth sent with token");

            IERC20(fromToken).safeTransferFrom(
                msg.sender,
                address(this),
                fromTokenAmounts[0].add(fromTokenAmounts[1])
            );
        }

        toInvest[0] = fromTokenAmounts[0].sub(
            _subtractGoodwill(fromToken, fromTokenAmounts[0], affiliate)
        );
        toInvest[1] = fromTokenAmounts[1].sub(
            _subtractGoodwill(fromToken, fromTokenAmounts[1], affiliate)
        );
    }

    function _subtractGoodwill(
        address token,
        uint256 amount,
        address affiliate
    ) internal returns (uint256 totalGoodwillPortion) {

        bool whitelisted = feeWhitelist[msg.sender];
        if (!whitelisted && goodwill > 0) {
            totalGoodwillPortion = SafeMath.div(
                SafeMath.mul(amount, goodwill),
                10000
            );

            if (affiliates[affiliate]) {
                if (token == address(0)) {
                    token = ETHAddress;
                }

                uint256 affiliatePortion = totalGoodwillPortion
                    .mul(affiliateSplit)
                    .div(100);
                affiliateBalance[affiliate][token] = affiliateBalance[affiliate][token]
                    .add(affiliatePortion);
                totalAffiliateBalance[token] = totalAffiliateBalance[token].add(
                    affiliatePortion
                );
            }
        }
    }
}