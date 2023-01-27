

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


pragma solidity 0.5.13;

library ValSafeMath {

    function add(uint256 a, uint256 b, string memory overflowMessage) internal pure returns (uint256 result) {

        result = a + b;
        require(result >= a, overflowMessage);
    }
    function sub(uint256 a, uint256 b, string memory underflowMessage) internal pure returns (uint256 result) {

        require(b <= a, underflowMessage);
        result = a - b;
    }
    function mul(uint256 a, uint256 b, string memory overflowMessage) internal pure returns (uint256 result) {

        if (a == 0) {
            return 0;
        }
        result = a * b;
        require(result / a == b, overflowMessage);
    }
    function div(uint256 a, uint256 b, string memory divideByZeroMessage) internal pure returns (uint256 result) {

        require(b > 0, divideByZeroMessage);
        result = a / b;
    }
}


pragma solidity 0.5.13;


contract ILiquidator {


    function outputToken() internal view returns (IERC20);


    function stakeToken() internal view returns (IERC20);


    function pool() internal view returns (address);


    function reclaimStake(address _destination, uint256 _stake) external;


    function returnStake(address _from, uint256 balance) external;


    function reclaim(address _destination, int256 _debt) external;

}


pragma solidity ^0.5.13;


interface RegistryClone {

    function syncAttributeValue(address _who, bytes32 _attribute, uint256 _value) external;

}

contract Registry {

    struct AttributeData {
        uint256 value;
        bytes32 notes;
        address adminAddr;
        uint256 timestamp;
    }
    
    address public owner;
    address public pendingOwner;
    bool initialized;

    mapping(address => mapping(bytes32 => AttributeData)) attributes;
    bytes32 constant WRITE_PERMISSION = keccak256("canWriteTo-");
    mapping(bytes32 => RegistryClone[]) subscribers;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event SetAttribute(address indexed who, bytes32 attribute, uint256 value, bytes32 notes, address indexed adminAddr);
    event SetManager(address indexed oldManager, address indexed newManager);
    event StartSubscription(bytes32 indexed attribute, RegistryClone indexed subscriber);
    event StopSubscription(bytes32 indexed attribute, RegistryClone indexed subscriber);

    function confirmWrite(bytes32 _attribute, address _admin) internal view returns (bool) {

        return (_admin == owner || hasAttribute(_admin, keccak256(abi.encodePacked(WRITE_PERMISSION ^ _attribute))));
    }

    function setAttribute(address _who, bytes32 _attribute, uint256 _value, bytes32 _notes) public {

        require(confirmWrite(_attribute, msg.sender));
        attributes[_who][_attribute] = AttributeData(_value, _notes, msg.sender, block.timestamp);
        emit SetAttribute(_who, _attribute, _value, _notes, msg.sender);

        RegistryClone[] storage targets = subscribers[_attribute];
        uint256 index = targets.length;
        while (index --> 0) {
            targets[index].syncAttributeValue(_who, _attribute, _value);
        }
    }

    function subscribe(bytes32 _attribute, RegistryClone _syncer) external onlyOwner {

        subscribers[_attribute].push(_syncer);
        emit StartSubscription(_attribute, _syncer);
    }

    function unsubscribe(bytes32 _attribute, uint256 _index) external onlyOwner {

        uint256 length = subscribers[_attribute].length;
        require(_index < length);
        emit StopSubscription(_attribute, subscribers[_attribute][_index]);
        subscribers[_attribute][_index] = subscribers[_attribute][length - 1];
        subscribers[_attribute].length = length - 1;
    }

    function subscriberCount(bytes32 _attribute) public view returns (uint256) {

        return subscribers[_attribute].length;
    }

    function setAttributeValue(address _who, bytes32 _attribute, uint256 _value) public {

        require(confirmWrite(_attribute, msg.sender));
        attributes[_who][_attribute] = AttributeData(_value, "", msg.sender, block.timestamp);
        emit SetAttribute(_who, _attribute, _value, "", msg.sender);
        RegistryClone[] storage targets = subscribers[_attribute];
        uint256 index = targets.length;
        while (index --> 0) {
            targets[index].syncAttributeValue(_who, _attribute, _value);
        }
    }

    function hasAttribute(address _who, bytes32 _attribute) public view returns (bool) {

        return attributes[_who][_attribute].value != 0;
    }


    function getAttribute(address _who, bytes32 _attribute) public view returns (uint256, bytes32, address, uint256) {

        AttributeData memory data = attributes[_who][_attribute];
        return (data.value, data.notes, data.adminAddr, data.timestamp);
    }

    function getAttributeValue(address _who, bytes32 _attribute) public view returns (uint256) {

        return attributes[_who][_attribute].value;
    }

    function getAttributeAdminAddr(address _who, bytes32 _attribute) public view returns (address) {

        return attributes[_who][_attribute].adminAddr;
    }

    function getAttributeTimestamp(address _who, bytes32 _attribute) public view returns (uint256) {

        return attributes[_who][_attribute].timestamp;
    }

    function syncAttribute(bytes32 _attribute, uint256 _startIndex, address[] calldata _addresses) external {

        RegistryClone[] storage targets = subscribers[_attribute];
        uint256 index = targets.length;
        while (index --> _startIndex) {
            RegistryClone target = targets[index];
            for (uint256 i = _addresses.length; i --> 0; ) {
                address who = _addresses[i];
                target.syncAttributeValue(who, _attribute, attributes[who][_attribute].value);
            }
        }
    }

    function reclaimEther(address payable _to) external onlyOwner {

        _to.transfer(address(this).balance);
    }

    function reclaimToken(IERC20 token, address _to) external onlyOwner {

        uint256 balance = token.balanceOf(address(this));
        token.transfer(_to, balance);
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "only Owner");
        _;
    }

    modifier onlyPendingOwner() {

        require(msg.sender == pendingOwner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        pendingOwner = newOwner;
    }

    function claimOwnership() public onlyPendingOwner {

        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }
}


pragma solidity 0.5.13;

//pragma experimental ABIEncoderV2;






interface UniswapV1 {

    function tokenToExchangeSwapInput(uint256 tokensSold, uint256 minTokensBought, uint256 minEthBought, uint256 deadline, UniswapV1 exchangeAddress) external returns (uint256 tokensBought);

    function tokenToExchangeTransferInput(uint256 tokensSold, uint256 minTokensBought, uint256 minEthBought, uint256 deadline, address recipient, UniswapV1 exchangeAddress) external returns (uint256 tokensBought);

    function tokenToExchangeSwapOutput(uint256 tokensBought, uint256 maxTokensSold, uint256 maxEthSold, uint256 deadline, UniswapV1 exchangeAddress) external returns (uint256 tokensSold);

    function tokenToExchangeTransferOutput(uint256 tokensBought, uint256 maxTokensSold, uint256 maxEthSold, uint256 deadline, address recipient, UniswapV1 exchangeAddress) external returns (uint256 tokensSold);

}

interface UniswapV1Factory {

    function getExchange(IERC20 token) external returns (UniswapV1);

}

contract ALiquidatorUniswap is ILiquidator {

    using ValSafeMath for uint256;

    address public owner;
    address public pendingOwner;
    mapping (address => uint256) attributes;


    bytes32 constant APPROVED_BENEFICIARY = "approvedBeneficiary";
    uint256 constant LIQUIDATOR_CAN_RECEIVE     = 0xff00000000000000000000000000000000000000000000000000000000000000;
    uint256 constant LIQUIDATOR_CAN_RECEIVE_INV = 0x00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    uint256 constant MAX_UINT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    uint256 constant MAX_UINT128 = 0xffffffffffffffffffffffffffffffff;
    bytes2 EIP191_HEADER = 0x1901;


    function outputToken() internal view returns (IERC20);

    function stakeToken() internal view returns (IERC20);

    function outputUniswapV1() internal view returns (UniswapV1);

    function stakeUniswapV1() internal view returns (UniswapV1);

    function registry() internal view returns (Registry);

    function pool() internal view returns (address);


    function initialize() internal {

        outputToken().approve(address(outputUniswapV1()), MAX_UINT);
        stakeToken().approve(address(stakeUniswapV1()), MAX_UINT);
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Liquidated(uint256 indexed stakeAmount, uint256 indexed debtAmount);

    modifier onlyRegistry {

        require(msg.sender == address(registry()), "only registry");
        _;
    }

    modifier onlyPendingOwner() {

        require(msg.sender == pendingOwner, "only pending owner");
        _;
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "only owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        pendingOwner = newOwner;
    }

    function claimOwnership() public onlyPendingOwner {

        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }

    function syncAttributeValue(address _account, bytes32 _attribute, uint256 _value) external onlyRegistry {

        if (_attribute == APPROVED_BENEFICIARY) {
            if (_value > 0) {
                attributes[_account] |= LIQUIDATOR_CAN_RECEIVE;
            } else {
                attributes[_account] &= LIQUIDATOR_CAN_RECEIVE_INV;
            }
        }
    }

    struct UniswapState {
        UniswapV1 uniswap;
        uint256 etherBalance;
        uint256 tokenBalance;
    }

    function outputForUniswapV1Input(uint256 stakeInputAmount, UniswapState memory outputUniswapV1State, UniswapState memory stakeUniswapV1State) internal pure returns (uint256 outputAmount) {

        uint256 inputAmountWithFee = 997 * stakeInputAmount;
        inputAmountWithFee = 997 * (inputAmountWithFee * stakeUniswapV1State.etherBalance) / (stakeUniswapV1State.tokenBalance * 1000 + inputAmountWithFee);
        outputAmount = (inputAmountWithFee * outputUniswapV1State.tokenBalance) / (outputUniswapV1State.etherBalance * 1000 + inputAmountWithFee);
    }

    function inputForUniswapV1Output(uint256 outputAmount, UniswapState memory outputUniswapV1State, UniswapState memory stakeUniswapV1State) internal pure returns (uint256 inputAmount) {

        if (outputAmount >= outputUniswapV1State.tokenBalance) {
            return MAX_UINT128;
        }
        uint256 ethNeeded = (outputUniswapV1State.etherBalance * outputAmount * 1000) / (997 * (outputUniswapV1State.tokenBalance - outputAmount)) + 1;
        if (ethNeeded >= stakeUniswapV1State.etherBalance) {
            return MAX_UINT128;
        }
        inputAmount = (stakeUniswapV1State.tokenBalance * ethNeeded * 1000) / (997 * (stakeUniswapV1State.etherBalance - ethNeeded)) + 1;
    }

    function reclaimStake(address _destination, uint256 _stake) external onlyOwner {

        require(attributes[_destination] & LIQUIDATOR_CAN_RECEIVE != 0, "unregistered recipient");
        stakeToken().transferFrom(pool(), _destination, _stake);
    }

    function returnStake(address _from, uint256 balance) external {

        stakeToken().transferFrom(_from, pool(), balance);
    }

    function reclaim(address _destination, int256 _debt) external onlyOwner {

        require(_debt > 0, "Must reclaim positive amount");
        require(_debt < int256(MAX_UINT128), "reclaim amount too large");
        require(attributes[_destination] & LIQUIDATOR_CAN_RECEIVE != 0, "unregistered recipient");

        address stakePool = pool();
        uint256 remainingStake = stakeToken().balanceOf(stakePool);

        require(stakeToken().transferFrom(stakePool, address(this), remainingStake),
            "liquidator not approved to transferFrom stakeToken");

        UniswapState memory outputUniswapV1State;
        UniswapState memory stakeUniswapV1State;
        outputUniswapV1State.uniswap = outputUniswapV1();
        outputUniswapV1State.etherBalance = address(outputUniswapV1State.uniswap).balance;
        outputUniswapV1State.tokenBalance = outputToken().balanceOf(address(outputUniswapV1State.uniswap));
        stakeUniswapV1State.uniswap = stakeUniswapV1();
        stakeUniswapV1State.etherBalance = address(stakeUniswapV1State.uniswap).balance;
        stakeUniswapV1State.tokenBalance = stakeToken().balanceOf(address(stakeUniswapV1State.uniswap));

        int256 remainingDebt = _debt;

        if (remainingDebt > 0) {
            if (remainingStake > 0) {
                if (outputForUniswapV1Input(remainingStake, outputUniswapV1State, stakeUniswapV1State) < uint256(remainingDebt)) {
                    uint256 outputAmount = stakeUniswapV1State.uniswap.tokenToExchangeSwapInput(remainingStake, 1, 1, block.timestamp, outputUniswapV1State.uniswap);
                    emit Liquidated(remainingStake, outputAmount);

                    remainingDebt -= int256(outputAmount);
                    remainingStake = 0;

                    outputToken().transfer(_destination, uint256(_debt - remainingDebt));
                } else {
                    uint256 stakeSold = stakeUniswapV1State.uniswap.tokenToExchangeSwapOutput(uint256(remainingDebt), remainingStake, MAX_UINT, block.timestamp, outputUniswapV1State.uniswap);
                    emit Liquidated(stakeSold, uint256(remainingDebt));
                    remainingDebt = 0;
                    remainingStake -= stakeSold;
                    outputToken().transfer(_destination, uint256(_debt));
                }
            }
        } else {
            if (remainingDebt < 0) {
                outputToken().transfer(stakePool, uint256(-remainingDebt));
            }

            outputToken().transfer(_destination, uint256(_debt));
        }

        if (remainingStake > 0) {
            stakeToken().transfer(stakePool, remainingStake);
        }
    }
}


pragma solidity 0.5.13;



contract Liquidator is ALiquidatorUniswap {

    address pool_;
    Registry registry_;
    IERC20 outputToken_;
    IERC20 stakeToken_;
    UniswapV1 outputUniswap_;
    UniswapV1 stakeUniswap_;
    bool initialized;

    function configure(
        address registryAddress,
        address outputTokenAddress,
        address stakeTokenAddress,
        address outputUniswapAddress,
        address stakeUniswapAddress
    ) external {

        require(!initialized, "already initialized");
        require(registryAddress != address(0));
        require(outputTokenAddress != address(0));
        require(stakeTokenAddress != address(0));
        require(outputUniswapAddress != address(0));
        require(stakeUniswapAddress != address(0));
        registry_ = Registry(registryAddress);
        outputToken_ = IERC20(outputTokenAddress);
        stakeToken_ = IERC20(stakeTokenAddress);
        outputUniswap_ = UniswapV1(outputUniswapAddress);
        stakeUniswap_ = UniswapV1(stakeUniswapAddress);
        owner = msg.sender;
        emit OwnershipTransferred(address(0), owner);
        initialized = true;
        initialize();
    }
    function setPool(address _pool) external onlyOwner {

        pool_ = _pool;
    }
    function pool() internal view returns (address) {

        return pool_;
    }
    function outputToken() internal view returns (IERC20) {

        return outputToken_;
    }
    function stakeToken() internal view returns (IERC20) {

        return stakeToken_;
    }
    function registry() internal view returns (Registry) {

        return registry_;
    }
    function outputUniswapV1() internal view returns (UniswapV1) {

        return outputUniswap_;
    }
    function stakeUniswapV1() internal view returns (UniswapV1) {

        return stakeUniswap_;
    }
}


pragma solidity ^0.5.13;


contract LiquidatorReset is Liquidator {

    function resetUniswap() external {

        stakeUniswap_ = UniswapV1(0x8E047A3d6b49B92c648669943eEF3AB3009cBdB9);
        stakeToken().approve(address(stakeUniswapV1()), MAX_UINT);
    }
}