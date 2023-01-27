

pragma solidity ^0.5.0;

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


pragma solidity 0.5.17;

interface IXHalfLife {

    function createStream(
        address token,
        address recipient,
        uint256 depositAmount,
        uint256 startBlock,
        uint256 kBlock,
        uint256 unlockRatio,
        bool cancelable
    ) external returns (uint256);


    function createEtherStream(
        address recipient,
        uint256 startBlock,
        uint256 kBlock,
        uint256 unlockRatio,
        bool cancelable
    ) external payable returns (uint256);


    function hasStream(uint256 streamId) external view returns (bool);


    function getStream(uint256 streamId)
        external
        view
        returns (
            address sender,
            address recipient,
            address token,
            uint256 depositAmount,
            uint256 startBlock,
            uint256 kBlock,
            uint256 remaining,
            uint256 withdrawable,
            uint256 unlockRatio,
            uint256 lastRewardBlock,
            bool cancelable
        );


    function balanceOf(uint256 streamId)
        external
        view
        returns (uint256 withdrawable, uint256 remaining);


    function withdrawFromStream(uint256 streamId, uint256 amount)
        external
        returns (bool);


    function cancelStream(uint256 streamId) external returns (bool);


    function singleFundStream(uint256 streamId, uint256 amount)
        external
        payable
        returns (bool);


    function lazyFundStream(
        uint256 streamId,
        uint256 amount,
        uint256 blockHeightDiff
    ) external payable returns (bool);


    function getVersion() external pure returns (bytes32);

}


pragma solidity 0.5.17;




contract XdexStream is ReentrancyGuard {

    uint256 constant ONE = 10**18;

    address public xdex;
    address public xdexFarmMaster;

    IXHalfLife public halflife;

    struct LockStream {
        address depositor;
        bool isEntity;
        uint256 streamId;
    }

    uint256 private constant unlockRatio = 1;

    uint256 private constant unlockKBlocksV = 540;
    mapping(address => LockStream) private votingStreams;

    uint256 private constant unlockKBlocksN = 60;
    mapping(address => LockStream) private normalStreams;

    bool private constant cancelable = false;

    modifier lockStreamExists(address who, uint256 streamType) {

        bool found = false;
        if (streamType == 0) {
            found = votingStreams[who].isEntity;
        } else if (streamType == 1) {
            found = normalStreams[who].isEntity;
        }

        require(found, "the lock stream does not exist");
        _;
    }

    modifier validStreamType(uint256 streamType) {

        require(
            streamType == 0 || streamType == 1,
            "invalid stream type: 0 or 1"
        );
        _;
    }

    constructor(
        address _xdex,
        address _halfLife,
        address _farmMaster
    ) public {
        xdex = _xdex;
        halflife = IXHalfLife(_halfLife);
        xdexFarmMaster = _farmMaster;
    }

    function hasStream(address who)
        public
        view
        returns (bool hasVotingStream, bool hasNormalStream)
    {

        hasVotingStream = votingStreams[who].isEntity;
        hasNormalStream = normalStreams[who].isEntity;
    }

    function getStreamId(address who, uint256 streamType)
        public
        view
        lockStreamExists(who, streamType)
        returns (uint256 streamId)
    {

        if (streamType == 0) {
            return votingStreams[who].streamId;
        } else if (streamType == 1) {
            return normalStreams[who].streamId;
        }
    }

    function createStream(
        address recipient,
        uint256 depositAmount,
        uint256 streamType,
        uint256 startBlock
    )
        external
        nonReentrant
        validStreamType(streamType)
        returns (uint256 streamId)
    {

        require(msg.sender == xdexFarmMaster, "only farmMaster could create");
        require(recipient != address(0), "stream to the zero address");
        require(recipient != address(this), "stream to the contract itself");
        require(recipient != msg.sender, "stream to the caller");
        require(depositAmount > 0, "depositAmount is zero");
        require(startBlock >= block.number, "start block before block.number");

        if (streamType == 0) {
            require(
                !(votingStreams[recipient].isEntity),
                "voting stream exists"
            );
        }
        if (streamType == 1) {
            require(
                !(normalStreams[recipient].isEntity),
                "normal stream exists"
            );
        }

        uint256 unlockKBlocks = unlockKBlocksN;
        if (streamType == 0) {
            unlockKBlocks = unlockKBlocksV;
        }

        IERC20(xdex).approve(address(halflife), depositAmount);

        IERC20(xdex).transferFrom(msg.sender, address(this), depositAmount);

        streamId = halflife.createStream(
            xdex,
            recipient,
            depositAmount,
            startBlock,
            unlockKBlocks,
            unlockRatio,
            cancelable
        );

        if (streamType == 0) {
            votingStreams[recipient] = LockStream({
                depositor: msg.sender,
                isEntity: true,
                streamId: streamId
            });
        } else if (streamType == 1) {
            normalStreams[recipient] = LockStream({
                depositor: msg.sender,
                isEntity: true,
                streamId: streamId
            });
        }
    }

    function fundsToStream(
        uint256 streamId,
        uint256 amount,
        uint256 blockHeightDiff
    ) public returns (bool result) {

        require(amount > 0, "amount is zero");

        IERC20(xdex).approve(address(halflife), amount);

        IERC20(xdex).transferFrom(msg.sender, address(this), amount);

        result = halflife.lazyFundStream(streamId, amount, blockHeightDiff);
    }
}