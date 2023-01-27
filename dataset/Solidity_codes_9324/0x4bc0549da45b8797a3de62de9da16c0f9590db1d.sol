

pragma solidity ^0.5.0;

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.5.0;

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

        require(b > 0);
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


pragma solidity ^0.5.0;



library SafeERC20 {

    using SafeMath for uint256;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        require(token.transfer(to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        require(token.transferFrom(from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0));
        require(token.approve(spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        require(token.approve(spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        require(token.approve(spender, newAllowance));
    }
}


pragma solidity ^0.5.7;


contract IFeeHolder {


    event TokenWithdrawn(
        address owner,
        address token,
        uint value
    );

    mapping(address => mapping(address => uint)) public feeBalances;

    mapping(address => uint) public nonces;

    function withdrawBurned(
        address token,
        uint value
        )
        external
        returns (bool success);


    function withdrawToken(
        address token,
        uint value
        )
        external
        returns (bool success);


    function withdrawTokenFor(
      address owner,
      address token,
      uint value,
      address recipient,
      uint feeValue,
      address feeRecipient,
      uint nonce,
      bytes calldata signature
      )
      external
      returns (bool success);


    function batchAddFeeBalances(
        bytes32[] calldata batch
        )
        external;

}


pragma solidity ^0.5.7;


contract Ownable {

    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor()
        public
    {
        owner = msg.sender;
    }

    modifier onlyOwner()
    {

        require(msg.sender == owner, "NOT_OWNER");
        _;
    }

    function transferOwnership(
        address newOwner
        )
        public
        onlyOwner
    {

        require(newOwner != address(0x0), "ZERO_ADDRESS");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}



pragma solidity ^0.5.13;




contract FeeHolderProxyOwner is Ownable {


    using SafeERC20 for IERC20;

    event FeeHolderSet(address indexed newFeeHolder, address indexed oldFeeHolder);
    event TokenWithdrawn(address indexed token, address receiver, uint amount);

    IFeeHolder public feeHolder;

    constructor(
        address _feeHolder
    ) public {
        feeHolder = IFeeHolder(_feeHolder);
    }


    function getBalancesByToken(
        address token
    ) public view returns (uint burnBalance, uint feeBalance) {

        burnBalance = feeHolder.feeBalances(token, address(feeHolder));
        feeBalance = feeHolder.feeBalances(token, address(this));
    }


    function executeCode(
        string calldata signature,
        bytes calldata data
    )
    external
    payable
    onlyOwner
    returns (bytes memory) {

        bytes memory callData;
        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }

        (bool success, bytes memory returnData) = (address(feeHolder)).call.value(msg.value)(callData);
        require(success, "EXECUTION_REVERTED");

        return returnData;
    }

    function setFeeHolder(
        address _feeHolder
    )
    external
    onlyOwner {

        address oldFeeHolder = address(feeHolder);
        feeHolder = IFeeHolder(_feeHolder);
        emit FeeHolderSet(_feeHolder, oldFeeHolder);
    }

    function withdrawAllFeesByTokens(
        address[] calldata tokens,
        address receiver
    )
    external
    onlyOwner {

        for (uint i = 0; i < tokens.length; i++) {
            _withdrawAllFeesByToken(tokens[i], receiver);
        }
    }

    function withdrawAllFeesByToken(
        address token,
        address receiver
    )
    external
    onlyOwner {

        _withdrawAllFeesByToken(token, receiver);
    }

    function _withdrawAllFeesByToken(
        address token,
        address receiver
    ) internal {

        (uint burnBalance, uint feeBalance) = getBalancesByToken(token);
        if (burnBalance > 0) {
            feeHolder.withdrawBurned(token, burnBalance);
        }
        if (feeBalance > 0) {
            feeHolder.withdrawToken(token, feeBalance);
        }

        uint balance = IERC20(token).balanceOf(address(this));
        if (balance > 0) {
            IERC20(token).safeTransfer(receiver, balance);
        }

        emit TokenWithdrawn(token, receiver, balance);
    }

}