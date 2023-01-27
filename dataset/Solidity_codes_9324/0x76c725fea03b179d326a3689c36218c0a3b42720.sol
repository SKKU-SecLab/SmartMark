

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


contract EtherSwap {


    uint8 constant public version = 2;

    mapping (bytes32 => bool) public swaps;


    event Lockup(
        bytes32 indexed preimageHash,
        uint amount,
        address claimAddress,
        address indexed refundAddress,
        uint timelock
    );

    event Claim(bytes32 indexed preimageHash, bytes32 preimage);
    event Refund(bytes32 indexed preimageHash);



    function lock(
        bytes32 preimageHash,
        address claimAddress,
        uint timelock
    ) external payable {

        lockEther(preimageHash, msg.value, claimAddress, timelock);
    }

    function lockPrepayMinerfee(
        bytes32 preimageHash,
        address payable claimAddress,
        uint timelock,
        uint prepayAmount
    ) external payable {

        require(msg.value > prepayAmount, "EtherSwap: sent amount must be greater than the prepay amount");

        lockEther(preimageHash, msg.value - prepayAmount, claimAddress, timelock);

        TransferHelper.transferEther(claimAddress, prepayAmount);
    }

    function claim(
        bytes32 preimage,
        uint amount,
        address refundAddress,
        uint timelock
    ) external {

        bytes32 preimageHash = sha256(abi.encodePacked(preimage));

        bytes32 hash = hashValues(
            preimageHash,
            amount,
            msg.sender,
            refundAddress,
            timelock
        );

        checkSwapIsLocked(hash);
        delete swaps[hash];

        emit Claim(preimageHash, preimage);

        TransferHelper.transferEther(payable(msg.sender), amount);
    }

    function refund(
        bytes32 preimageHash,
        uint amount,
        address claimAddress,
        uint timelock
    ) external {

        require(timelock <= block.number, "EtherSwap: swap has not timed out yet");

        bytes32 hash = hashValues(
            preimageHash,
            amount,
            claimAddress,
            msg.sender,
            timelock
        );

        checkSwapIsLocked(hash);
        delete swaps[hash];

        emit Refund(preimageHash);

        TransferHelper.transferEther(payable(msg.sender), amount);
    }


    function hashValues(
        bytes32 preimageHash,
        uint amount,
        address claimAddress,
        address refundAddress,
        uint timelock
    ) public pure returns (bytes32) {

        return keccak256(abi.encodePacked(
            preimageHash,
            amount,
            claimAddress,
            refundAddress,
            timelock
        ));
    }


    function lockEther(bytes32 preimageHash, uint amount, address claimAddress, uint timelock) private {

        require(amount > 0, "EtherSwap: locked amount must not be zero");

        bytes32 hash = hashValues(
            preimageHash,
            amount,
            claimAddress,
            msg.sender,
            timelock
        );

        require(swaps[hash] == false, "EtherSwap: swap exists already");

        swaps[hash] = true;

        emit Lockup(preimageHash, amount, claimAddress, msg.sender, timelock);
    }

    function checkSwapIsLocked(bytes32 hash) private view {

        require(swaps[hash] == true, "EtherSwap: swap has no Ether locked in the contract");
    }
}