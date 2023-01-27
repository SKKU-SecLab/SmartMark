

pragma solidity 0.7.6;

library TransferHelper {

    function transferEther(address payable to, uint amount) internal {

        (bool success, ) = to.call{value: amount}("");
        require(success, "TransferHelper: could not transfer Ether");
    }

    function safeTransferToken(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: could not transfer ERC20 tokens"
        );
    }

    function safeTransferTokenFrom(address token, address from, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: could not transferFrom ERC20 tokens"
        );
    }
}// AGPL-3.0-or-later

pragma solidity 0.7.6;


contract ERC20Swap {


    uint8 constant public version = 2;

    mapping (bytes32 => bool) public swaps;


    event Lockup(
        bytes32 indexed preimageHash,
        uint256 amount,
        address tokenAddress,
        address claimAddress,
        address indexed refundAddress,
        uint timelock
    );

    event Claim(bytes32 indexed preimageHash, bytes32 preimage);
    event Refund(bytes32 indexed preimageHash);



    function lockPrepayMinerfee(
        bytes32 preimageHash,
        uint256 amount,
        address tokenAddress,
        address payable claimAddress,
        uint timelock
    ) external payable {

        lock(preimageHash, amount, tokenAddress, claimAddress, timelock);

        TransferHelper.transferEther(claimAddress, msg.value);
    }

    function claim(
        bytes32 preimage,
        uint amount,
        address tokenAddress,
        address refundAddress,
        uint timelock
    ) external {

        bytes32 preimageHash = sha256(abi.encodePacked(preimage));

        bytes32 hash = hashValues(
            preimageHash,
            amount,
            tokenAddress,
            msg.sender,
            refundAddress,
            timelock
        );

        checkSwapIsLocked(hash);

        delete swaps[hash];

        emit Claim(preimageHash, preimage);

        TransferHelper.safeTransferToken(tokenAddress, msg.sender, amount);
    }

    function refund(
        bytes32 preimageHash,
        uint amount,
        address tokenAddress,
        address claimAddress,
        uint timelock
    ) external {

        require(timelock <= block.number, "ERC20Swap: swap has not timed out yet");

        bytes32 hash = hashValues(
            preimageHash,
            amount,
            tokenAddress,
            claimAddress,
            msg.sender,
            timelock
        );

        checkSwapIsLocked(hash);
        delete swaps[hash];

        emit Refund(preimageHash);

        TransferHelper.safeTransferToken(tokenAddress, msg.sender, amount);
    }


    function lock(
        bytes32 preimageHash,
        uint256 amount,
        address tokenAddress,
        address claimAddress,
        uint timelock
    ) public {

        require(amount > 0, "ERC20Swap: locked amount must not be zero");

        TransferHelper.safeTransferTokenFrom(tokenAddress, msg.sender, address(this), amount);

        bytes32 hash = hashValues(
            preimageHash,
            amount,
            tokenAddress,
            claimAddress,
            msg.sender,
            timelock
        );

        require(swaps[hash] == false, "ERC20Swap: swap exists already");

        swaps[hash] = true;

        emit Lockup(preimageHash, amount, tokenAddress, claimAddress, msg.sender, timelock);
    }

    function hashValues(
        bytes32 preimageHash,
        uint256 amount,
        address tokenAddress,
        address claimAddress,
        address refundAddress,
        uint timelock
    ) public pure returns (bytes32) {

        return keccak256(abi.encodePacked(
            preimageHash,
            amount,
            tokenAddress,
            claimAddress,
            refundAddress,
            timelock
        ));
    }


    function checkSwapIsLocked(bytes32 hash) private view {

        require(swaps[hash] == true, "ERC20Swap: swap has no tokens locked in the contract");
    }
}