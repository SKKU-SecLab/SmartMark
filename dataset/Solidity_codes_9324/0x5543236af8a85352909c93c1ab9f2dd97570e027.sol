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
pragma solidity ^0.6.0;

contract OSnap {

    using SafeMath for uint256;

    struct Multihash {
        bytes32 digest;
        uint8 hashFunction;
        uint8 size;
    }

    event Post(
        uint256 indexed postID,
        address indexed postedBy,
        uint256 tipAPostID,
        uint256 tipAAmt,
        uint256 tipBPostID,
        uint256 tipBAmt,
        bytes32 digest,
        uint8 hashFunction,
        uint8 size
    );

    mapping(uint256 => Multihash) private posts;
    mapping(uint256 => address payable) private payableByPostID;
    mapping(address => uint256[]) private postsByAddress;

    uint256 private postID = 0;

    address payable private _bootstapAddr;

    constructor() public {
        _bootstapAddr = msg.sender;
    }

    function getPostID() public view returns (uint256 id) {

        return postID;
    }

    function getPostById(uint256 _id)
        public
        view
        returns (
            bytes32 digest,
            uint8 hashFunction,
            uint8 size
        )
    {

        require(_id < postID, "Post not found.");

        Multihash storage post = posts[_id];
        return (post.digest, post.hashFunction, post.size);
    }

    function getPostByAddressIdx(address _addr, uint256 _idx)
        public
        view
        returns (
            bytes32 digest,
            uint8 hashFunction,
            uint8 size
        )
    {

        require(postsByAddress[_addr].length > 0, "Address not found.");
        require(_idx < postsByAddress[_addr].length, "Post not found.");

        Multihash storage post = posts[postsByAddress[_addr][_idx]];
        return (post.digest, post.hashFunction, post.size);
    }

    function getTotalPostsByAddress(address _addr)
        public
        view
        returns (uint256 length)
    {

        return postsByAddress[_addr].length;
    }

    function getOPByID(uint256 _postID)
        public
        view
        returns (address payable poster)
    {

        return payableByPostID[_postID];
    }

    function _addTip(uint256 _postID, uint256 _tip) private {

        require(_tip > 0, "Missing tip value.");
        require(
            msg.sender == _bootstapAddr || (_postID < postID),
            "Post not found."
        );
        require(
            msg.sender == _bootstapAddr ||
                (payableByPostID[_postID] != msg.sender),
            "Self-tipping is discouraged."
        );

        payableByPostID[_postID].transfer(_tip);
    }

    function addTip(uint256 _postID) public payable {

        _addTip(_postID, msg.value);
    }

    function addPost(
        uint256 _tipAPostId,
        uint256 _tipAAmt,
        uint256 _tipBPostId,
        uint256 _tipBAmt,
        bytes32 _digest,
        uint8 _hashFunction,
        uint8 _size
    ) public payable returns (uint256 id) {

        require(
            _tipAAmt + _tipBAmt == msg.value,
            "Tips should equal message value."
        );

        _addTip(_tipAPostId, _tipAAmt);
        _addTip(_tipBPostId, _tipBAmt);

        Multihash memory post = Multihash(_digest, _hashFunction, _size);

        posts[postID] = post;
        postsByAddress[msg.sender].push(postID);
        payableByPostID[postID] = msg.sender;

        emit Post(
            postID,
            msg.sender,
            _tipAPostId,
            _tipAAmt,
            _tipBPostId,
            _tipBAmt,
            _digest,
            _hashFunction,
            _size
        );

        return postID++;
    }
}
