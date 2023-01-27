

pragma solidity 0.6.7;

abstract contract IMerkleDistributor {
    uint256 public constant timelapseUntilWithdrawWindow = 90 days;

    function token() virtual external view returns (address);
    function merkleRoot() virtual external view returns (bytes32);
    function deploymentTime() virtual external view returns (uint256);
    function owner() virtual external view returns (address);
    function isClaimed(uint256 index) virtual external view returns (bool);
    function sendTokens(address dst, uint256 tokenAmount) virtual external;
    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) virtual external;

    event AddAuthorization(address account);
    event RemoveAuthorization(address account);
    event Claimed(uint256 index, address account, uint256 amount);
    event SendTokens(address dst, uint256 tokenAmount);
}

library MerkleProof {

    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {

        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        return computedHash == root;
    }
}

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

contract MerkleDistributor is IMerkleDistributor {

    mapping (address => uint) public authorizedAccounts;
    function addAuthorization(address account) virtual external isAuthorized {

        authorizedAccounts[account] = 1;
        emit AddAuthorization(account);
    }
    function removeAuthorization(address account) virtual external isAuthorized {

        authorizedAccounts[account] = 0;
        emit RemoveAuthorization(account);
    }
    modifier isAuthorized {

        require(authorizedAccounts[msg.sender] == 1, "MerkleDistributorFactory/account-not-authorized");
        _;
    }
    modifier canSendTokens {

        require(
          either(authorizedAccounts[msg.sender] == 1, both(owner == msg.sender, now >= addition(deploymentTime, timelapseUntilWithdrawWindow))),
          "MerkleDistributorFactory/cannot-send-tokens"
        );
        _;
    }

    address public immutable override token;
    address public immutable override owner;
    bytes32 public immutable override merkleRoot;
    uint256 public immutable override deploymentTime;

    mapping(uint256 => uint256) private claimedBitMap;

    constructor(address token_, bytes32 merkleRoot_) public {
        authorizedAccounts[msg.sender] = 1;
        owner                          = msg.sender;
        token                          = token_;
        merkleRoot                     = merkleRoot_;
        deploymentTime                 = now;

        emit AddAuthorization(msg.sender);
    }

    function addition(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x + y) >= x, "MerkleDistributorFactory/add-uint-uint-overflow");
    }

    function either(bool x, bool y) internal pure returns (bool z) {

        assembly{ z := or(x, y)}
    }
    function both(bool x, bool y) internal pure returns (bool z) {

        assembly{ z := and(x, y)}
    }

    function sendTokens(address dst, uint256 tokenAmount) external override canSendTokens {

        require(dst != address(0), "MerkleDistributorFactory/null-dst");
        IERC20(token).transfer(dst, tokenAmount);
        emit SendTokens(dst, tokenAmount);
    }

    function isClaimed(uint256 index) public view override returns (bool) {

        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }
    function _setClaimed(uint256 index) private {

        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }
    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external override {

        require(!isClaimed(index), 'MerkleDistributor/drop-already-claimed');

        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        require(MerkleProof.verify(merkleProof, merkleRoot, node), 'MerkleDistributor/invalid-proof');

        _setClaimed(index);
        require(IERC20(token).transfer(account, amount), 'MerkleDistributor/transfer-failed');

        emit Claimed(index, account, amount);
    }
}

contract MerkleDistributorFactory {

    mapping (address => uint) public authorizedAccounts;
    function addAuthorization(address account) virtual external isAuthorized {

        authorizedAccounts[account] = 1;
        emit AddAuthorization(account);
    }
    function removeAuthorization(address account) virtual external isAuthorized {

        authorizedAccounts[account] = 0;
        emit RemoveAuthorization(account);
    }
    modifier isAuthorized {

        require(authorizedAccounts[msg.sender] == 1, "MerkleDistributorFactory/account-not-authorized");
        _;
    }

    uint256 public nonce;
    address public distributedToken;
    mapping(uint256 => address) public distributors;
    mapping(uint256 => uint256) public tokensToDistribute;

    event AddAuthorization(address account);
    event RemoveAuthorization(address account);
    event DeployDistributor(uint256 id, address distributor, uint256 tokenAmount);
    event SendTokensToDistributor(uint256 id);

    constructor(address distributedToken_) public {
        require(distributedToken_ != address(0), "MerkleDistributorFactory/null-distributed-token");

        authorizedAccounts[msg.sender] = 1;
        distributedToken               = distributedToken_;

        emit AddAuthorization(msg.sender);
    }

    function addition(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x + y) >= x, "MerkleDistributorFactory/add-uint-uint-overflow");
    }

    function deployDistributor(bytes32 merkleRoot, uint256 tokenAmount) external isAuthorized {

        require(tokenAmount > 0, "MerkleDistributorFactory/null-token-amount");
        nonce                     = addition(nonce, 1);
        address newDistributor    = address(new MerkleDistributor(distributedToken, merkleRoot));
        distributors[nonce]       = newDistributor;
        tokensToDistribute[nonce] = tokenAmount;
        emit DeployDistributor(nonce, newDistributor, tokenAmount);
    }
    function sendTokensToDistributor(uint256 id) external isAuthorized {

        require(tokensToDistribute[id] > 0, "MerkleDistributorFactory/nothing-to-send");
        uint256 tokensToSend = tokensToDistribute[id];
        tokensToDistribute[id] = 0;
        IERC20(distributedToken).transfer(distributors[id], tokensToSend);
        emit SendTokensToDistributor(id);
    }
    function sendTokensToCustom(address dst, uint256 tokenAmount) external isAuthorized {

        require(dst != address(0), "MerkleDistributorFactory/null-dst");
        IERC20(distributedToken).transfer(dst, tokenAmount);
    }
    function dropDistributorAuth(uint256 id) external isAuthorized {

        MerkleDistributor(distributors[id]).removeAuthorization(address(this));
    }
    function getBackTokensFromDistributor(uint256 id, uint256 tokenAmount) external isAuthorized {

        MerkleDistributor(distributors[id]).sendTokens(address(this), tokenAmount);
    }
}