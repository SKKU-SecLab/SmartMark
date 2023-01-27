

pragma solidity 0.5.16;


library SafeMath {


  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

    return _a / _b;
  }

  function divCeil(uint256 _a, uint256 _b) internal pure returns (uint256) {

    if (_a == 0) {
      return 0;
    }

    return ((_a - 1) / _b) + 1;
  }

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

    assert(_b <= _a);
    return _a - _b;
  }

  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

contract Ownable {

  address public owner;


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

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);
  }

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {

  function allowance(address _owner, address _spender)
    public view returns (uint256);


  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);


  function approve(address _spender, uint256 _value) public returns (bool);

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

contract ZeroXConnectorLogic is Ownable {

    using SafeMath for uint256;

    address internal target_;

    address public constant vaultContract = 0x8B3d70d628Ebd30D4A2ea82DB95bA2e906c71633;
    address public constant ZeroXExchange = 0x61935CbDd02287B511119DDb11Aeb42F1593b7Ef;
    address public constant ZeroXProxy = 0x95E6F48254609A6ee006F7D493c8e5fB97094ceF;

    address internal constant feeWallet = 0x13ddAC8d492E463073934E2a101e419481970299;

    constructor() public {}

    function() external {}


    function trade(
        ERC20 sourceToken,
        ERC20 destToken,
        address receiver,
        uint256 sourceTokenAmount,
        uint256 destTokenAmount,
        bytes calldata loanDataBytes)
        external
        payable
        returns (uint256 destTokenAmountReceived, uint256 sourceTokenAmountUsed)
    {

        require(msg.value != 0, "no ether sent");
        require(sourceToken != destToken, "no same-token swap");

        uint256 beforeSourceBalance = sourceToken.balanceOf(address(this));
        uint256 beforeDestBalance = destToken.balanceOf(address(this));
        uint256 beforeEtherBalance = address(this).balance.sub(msg.value);

        require(sourceTokenAmount >= beforeSourceBalance, "not enough token sent");

        address affiliateWallet = _handle0xSwap(
            sourceToken,
            sourceTokenAmount,
            destTokenAmount,
            loanDataBytes
        );

        (destTokenAmountReceived, sourceTokenAmountUsed) = _settleBalances(
            sourceToken,
            destToken,
            sourceTokenAmount,
            destTokenAmount,
            beforeSourceBalance,
            beforeDestBalance,
            affiliateWallet
        );

        uint256 afterEtherBalance = address(this).balance;
        if (afterEtherBalance > beforeEtherBalance) {
            (bool success,) = receiver.call.value(afterEtherBalance - beforeEtherBalance)("");
            require(success, "eth refund failed");
        }
    }

    function _handle0xSwap(
        ERC20 sourceToken,
        uint256 sourceTokenAmount,
        uint256 destTokenAmount,
        bytes memory loanDataBytes)
        internal
        returns (address)
    {

        bool isBuyOrder = destTokenAmount != 0;
        address affiliateWallet;
        uint256 protocolFee;
        (affiliateWallet, protocolFee, loanDataBytes) = _process0xData(
            isBuyOrder,
            loanDataBytes
        );

        uint256 tmpAmount;
        if (!isBuyOrder) {
            uint256 platformFee = _handleFees(
                sourceToken,
                sourceTokenAmount,
                affiliateWallet
            );

            if (platformFee != 0) {
                sourceTokenAmount = sourceTokenAmount
                    .sub(platformFee);
            }
        }

        assembly {
            tmpAmount := mload(add(loanDataBytes, 68))

            switch isBuyOrder
            case 0 { // false
                if gt(tmpAmount, sourceTokenAmount) {
                    mstore(add(loanDataBytes, 68), sourceTokenAmount)
                }
            }
            default { // true
                if gt(tmpAmount, destTokenAmount) {
                    mstore(add(loanDataBytes, 68), destTokenAmount)
                }
            }
        }
        require(
            (isBuyOrder && tmpAmount >= destTokenAmount) ||
            (!isBuyOrder && tmpAmount >= sourceTokenAmount),
            "0x swap too small"
        );


        tmpAmount = sourceToken.allowance(address(this), ZeroXProxy); // reclaim slot
        if (tmpAmount < sourceTokenAmount) {
            if (tmpAmount != 0) {
                sourceToken.approve(ZeroXProxy, 0);
            }

            sourceToken.approve(ZeroXProxy, uint256(-1));
        }

        (bool success,) = address(ZeroXExchange).call.value(protocolFee)(loanDataBytes);
        require(success, "0x swap failed");

        return affiliateWallet;
    }

   function _settleBalances(
        ERC20 sourceToken,
        ERC20 destToken,
        uint256 sourceTokenAmount,
        uint256 destTokenAmount,
        uint256 beforeSourceBalance,
        uint256 beforeDestBalance,
        address affiliateWallet)
        internal
        returns (uint256 destTokenAmountReceived, uint256 sourceTokenAmountUsed)
    {

        bool success;

        uint256 afterSourceBalance = sourceToken.balanceOf(address(this));
        success = afterSourceBalance < beforeSourceBalance;
        if (success) {
            sourceTokenAmountUsed = beforeSourceBalance - afterSourceBalance;
            if (sourceTokenAmount > sourceTokenAmountUsed) {
                uint256 sourceTokenRefund = sourceTokenAmount - sourceTokenAmountUsed;
                success = sourceTokenRefund == 0 || sourceToken.transfer(
                    vaultContract,
                    sourceTokenRefund
                );
            }
        }
        require(success, "0x swap failed for Source");

        uint256 afterDestBalance = destToken.balanceOf(address(this));
        success = afterDestBalance > beforeDestBalance;
        if (success) {
            destTokenAmountReceived = afterDestBalance - beforeDestBalance;

            if (destTokenAmount != 0) { // isBuyOrder == true
                uint256 platformFee = _handleFees(
                    destToken,
                    destTokenAmountReceived,
                    affiliateWallet
                );

                if (platformFee != 0) {
                    destTokenAmountReceived = destTokenAmountReceived
                        .sub(platformFee);
                }
            }

            success = destTokenAmountReceived == 0 || destToken.transfer(
                vaultContract,
                destTokenAmountReceived
            );
        }
        success = success && (destTokenAmount == 0 || destTokenAmountReceived >= destTokenAmountReceived);
        require(success, "0x swap failed for Dest");
    }

    function _process0xData(
        bool isBuyOrder,
        bytes memory loanDataBytes)
        internal
        returns (address, uint256, bytes memory)
    {

        uint256 dataLength = loanDataBytes.length;
        require(dataLength > 96, "0x data invalid");

        bytes4 sig;
        address affiliateWallet;
        uint256 protocolFee;
        assembly {
            sig := mload(add(loanDataBytes, 32))

            affiliateWallet := mload(add(loanDataBytes, dataLength))

            protocolFee := mload(add(loanDataBytes, sub(dataLength, 32)))

            mstore(loanDataBytes, sub(dataLength, 64))
        }

        require(
            (isBuyOrder && (sig == 0x8bc8efb3 || sig == 0x78d29ac1)) ||
            (!isBuyOrder && sig == 0xa6c3bf33),
            "0x sig invalid"
        );

        require(msg.value != 0 && msg.value >= protocolFee, "insufficient ether");

        return (affiliateWallet, protocolFee, loanDataBytes);
    }

    function _handleFees(
        ERC20 feeToken,
        uint256 feeTokenAmount,
        address affiliateWallet)
        internal
        returns (uint256)
    {

        uint256 totalPlatformFee = feeTokenAmount
            .mul(25 * 10**16)
            .div(10**20); // 0.25% fee

        uint256 platformFee = totalPlatformFee;

        bool success = true;
        if (affiliateWallet != address(0) && _checkWhitelist(affiliateWallet)) {
            uint256 affiliateFee = platformFee.mul(30 * 10**18).div(10**20); // 30% fee share
            if (affiliateFee != 0) {
                platformFee = platformFee.sub(affiliateFee);
                success = feeToken.transfer(
                    affiliateWallet,
                    affiliateFee
                );
            }
        }

        if (success && platformFee != 0) {
            success = feeToken.transfer(
                feeWallet,
                platformFee
            );
        }
        require (success, "0x transfer failed");

        return totalPlatformFee;
    }

    function _checkWhitelist(
        address affiliateWallet)
        internal
        view
        returns (bool isWhitelisted)
    {

        bytes32 slot = keccak256(abi.encodePacked(affiliateWallet, uint256(0xcda2fc7eaefa672733be021532baa62a86147ef9434c91b60aa179578a939d72)));
        assembly {
            isWhitelisted := sload(slot)
        }
    }

    function affiliateWhitelist(
        address affiliateWallet,
        bool enabled)
        public
        onlyOwner
    {

        bytes32 slot = keccak256(abi.encodePacked(affiliateWallet, uint256(0xcda2fc7eaefa672733be021532baa62a86147ef9434c91b60aa179578a939d72)));
        assembly {
            sstore(slot, enabled)
        }
    }

    function recoverEther(
        address receiver,
        uint256 amount)
        public
        onlyOwner
    {

        uint256 balance = address(this).balance;
        if (balance < amount)
            amount = balance;

        (bool success,) = receiver.call.value(amount)("");
        require(success,
            "transfer failed"
        );
    }

    function recoverToken(
        address tokenAddress,
        address receiver,
        uint256 amount)
        public
        onlyOwner
    {

        ERC20 token = ERC20(tokenAddress);

        uint256 balance = token.balanceOf(address(this));
        if (balance < amount)
            amount = balance;

        require(token.transfer(
            receiver,
            amount),
            "transfer failed"
        );
    }
}