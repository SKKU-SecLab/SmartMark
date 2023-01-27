pragma solidity 0.8.4;


contract OurStorage {

    bytes32 public merkleRoot;
    uint256 public currentWindow;

    address internal _pylon;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    uint256[] public balanceForWindow;
    mapping(bytes32 => bool) internal _claimed;
    uint256 internal _depositedInWindow;
}// GPL-3.0-or-later


pragma solidity 0.8.4;


interface IOurFactory {

    function pylon() external returns (address);


    function merkleRoot() external returns (bytes32);

}


contract OurProxy is OurStorage {

    constructor() {
        _pylon = IOurFactory(msg.sender).pylon();
        merkleRoot = IOurFactory(msg.sender).merkleRoot();
    }

    fallback() external payable {
        address impl = pylon();
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 {
                revert(ptr, size)
            }
            default {
                return(ptr, size)
            }
        }
    }

    function pylon() public view returns (address) {

        return _pylon;
    }
}// GPL-3.0-or-later


pragma solidity 0.8.4;



contract OurFactory {

    address public immutable pylon;

    bytes32 public merkleRoot;

    event SplitCreated(
        address ourProxy,
        address proxyCreator,
        string splitRecipients,
        string nickname
    );

    constructor(address pylon_) {
        pylon = pylon_;
    }

    function createSplit(
        bytes32 merkleRoot_,
        bytes memory data,
        string calldata splitRecipients_,
        string calldata nickname_
    ) external returns (address ourProxy) {

        merkleRoot = merkleRoot_;
        ourProxy = address(
            new OurProxy{salt: keccak256(abi.encode(merkleRoot_))}()
        );
        delete merkleRoot;

        emit SplitCreated(ourProxy, msg.sender, splitRecipients_, nickname_);

        assembly {
            if eq(
                call(gas(), ourProxy, 0, add(data, 0x20), mload(data), 0, 0),
                0
            ) {
                revert(0, 0)
            }
        }
    }
}