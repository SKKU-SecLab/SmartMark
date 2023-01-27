
pragma solidity >=0.7.0 <0.8.0;

interface IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

}


pragma solidity >=0.7.0 <0.8.0;

contract PreparedPayinV5 {

    address private factory;

    constructor() {
        factory = msg.sender;
    }

    fallback() external {
        require(msg.sender == factory);

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, 0x64)

            let result := call(
                gas(),
                mload(add(ptr, 0x44)),
                0,
                ptr,
                0x44,
                0,
                0
            )

            if iszero(result) { revert(0, 0) }
        }
    }
}

pragma solidity >=0.7.0 <0.8.0;


contract ChangeNowMasterPayinV5 {

    address public owner;
    address public successor = address(0);
    uint256 public payins = 0;

    bytes constant payinBytecode = type(PreparedPayinV5).creationCode;
    bytes32 constant payinBytecodeHash = keccak256(payinBytecode);


    constructor() {
        owner = msg.sender;
    }


    modifier isOwner() {

        require(msg.sender == owner, "Caller is not owner");
        _;
    }


    modifier isSuccessor() {

        require(msg.sender == successor, "Caller is not successor");
        _;
    }


    function setSuccessor(address newSuccessor) external isOwner {

        successor = newSuccessor;
    }


    function takeOwnership() external isSuccessor {

        owner = successor;
        successor = address(0);
    }


    function payinAddress(uint256 index)
        public
        view
        returns (address)
    {

        return address(uint256(keccak256(abi.encodePacked(
            hex'ff',
            address(this),
            bytes32(index),
            payinBytecodeHash
        ))));
    }

    function _payin_withdrawERC20(address token, address payin, address toAddress, uint256 amount)
        internal
    {

        assembly {
            let ptr := mload(0x40)
            mstore(0x40, add(ptr, 0x80))

            mstore(ptr, shl(224, 0xa9059cbb)) // "transfer(address,uint256)" [ERC20 method]
            mstore(add(ptr, 0x4), toAddress)  // 1st arg
            mstore(add(ptr, 0x24), amount)    // 2nd arg
            mstore(add(ptr, 0x44), token)     // (token address)

            let result := call(gas(), payin, 0, ptr, 0x64, 0, 0)

            if iszero(result) { revert(0, 0) }
        }
    }

    function generateNextBatch(uint256 minCount, uint256 maxCount)
        external
        returns (uint256, uint256)
    {

        require(minCount > 0, 'assert: minCount > 0');
        require(maxCount >= minCount, 'assert: maxCount > minCount');

        uint256 fromIndex = payins;
        uint256 calcSinceIndex = fromIndex + minCount;
        uint256 toIndex = fromIndex + maxCount;
        uint256 totalGasUsed = 0;

        uint256 index = fromIndex;

        bytes memory bytecode = payinBytecode;

        while (index < toIndex) {
            if (index >= calcSinceIndex) {
                uint256 avgGas = (totalGasUsed / (index - fromIndex));

                if (gasleft() < (avgGas + 5000)) {
                    break;
                }
            }

            uint256 gasBefore = gasleft();

            bytes32 salt = bytes32(index);
            address payin;
            assembly {
                payin := create2(0, add(bytecode, 32), mload(bytecode), salt)
            }

            totalGasUsed += gasBefore - gasleft();
            index++;
        }

        payins = index;

        return (fromIndex, index - fromIndex);
    }

    function harvestERC20Batch(address token, uint256 fromIndex, uint256 count, address toAddress)
        external
        isOwner
        returns (uint256)
    {

        require(toAddress != address(this), 'toAddress is this');
        require(toAddress != address(0), 'toAddress is zero');

        uint256 toIndex = fromIndex + count;
        uint256 totalAmount = 0;

        require(toIndex <= payins, 'not enough payins');

        while (fromIndex < toIndex) {
            address payin = payinAddress(fromIndex);
            uint256 amount = IERC20(token).balanceOf(payin);

            if (amount > 0) {
                _payin_withdrawERC20(token, payin, toAddress, amount);
                totalAmount += amount;
            }

            fromIndex++;
        }

        return totalAmount;
    }


    function harvestERC20BatchFor(address token, address[] calldata batch, address toAddress)
    external isOwner returns (uint256)
    {

        require(toAddress != address(this), 'toAddress is this');
        require(toAddress != address(0), 'toAddress is zero');

        uint256 totalAmount = 0;

        for (uint256 i = 0; i < batch.length; i++) {
            address payin = batch[i];
            uint256 amount = IERC20(token).balanceOf(payin);

            if (amount > 0) {
                _payin_withdrawERC20(token, payin, toAddress, amount);
                totalAmount += amount;
            }
        }

        return totalAmount;
    }
}
