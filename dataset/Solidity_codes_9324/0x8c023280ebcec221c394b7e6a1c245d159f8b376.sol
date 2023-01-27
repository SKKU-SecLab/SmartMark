
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;

library MerkleProof {

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {

        return processProof(proof, leaf) == root;
    }

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {

        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash;
    }
}// BUSL-1.1

pragma solidity ^0.8.14;




library ChainAddressExt {


  function toChainId(bytes24 chAddr) internal pure returns (uint32 chainId) {

    return uint32(bytes4(chAddr)); // Slices off the first 4 bytes
  }

  function toAddress(bytes24 chAddr) internal pure returns (address addr) {

    return address(bytes20(bytes24(uint192(chAddr) << 32)));
  }

  function toChainAddress(uint256 chainId, address addr) internal pure returns (bytes24) {

    uint192 a = uint192(chainId);
    a = a << 160;
    a = a | uint160(addr);
    return bytes24(a);
  }

  function getNativeTokenChainAddress() internal view returns (bytes24) {

    uint192 rewardToken = uint192(block.chainid);
    rewardToken = rewardToken << 160;
    rewardToken = rewardToken | uint160(block.chainid);
    return bytes24(rewardToken);
  }
}// MIT

pragma solidity ^0.8.14;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// BUSL-1.1
pragma solidity ^0.8.14;

interface ConfirmationsResolver {

  function getHead() external view returns(bytes32);

  function getConfirmation(bytes32 confirmationHash) external view returns (uint128 number, uint64 timestamp);

}// BUSL-1.1
pragma solidity ^0.8.14;



contract ReferralFarmsV1 is Ownable {


  ConfirmationsResolver confirmationsAddr;

  mapping(bytes32 => uint256) private farmDeposits;

  mapping(address => mapping(address => uint256)) private accountTokenConfirmationOffsets;

  mapping(bytes32 => uint256) private farmConfirmationOffsets;

  mapping(bytes32 => uint256) private farmConfirmationRewardMax;

  mapping(bytes32 => mapping(uint256 => FarmConfirmationRewardRemaining)) private farmConfirmationRewardRemaining;

  event FarmExists(address indexed sponsor, bytes24 indexed rewardTokenDefn, bytes24 indexed referredTokenDefn, bytes32 farmHash);

  event FarmDepositIncreased(bytes32 indexed farmHash, uint128 delta);

  event FarmDepositDecreaseRequested(bytes32 indexed farmHash, uint128 value, uint128 confirmation);

  event FarmDepositDecreaseClaimed(bytes32 indexed farmHash, uint128 delta);

  event FarmMetastate(bytes32 indexed farmHash, bytes32 indexed key, bytes value);

  event RewardsHarvested(address indexed caller, bytes24 indexed rewardTokenDefn, bytes32 indexed farmHash, uint128 value, bytes32 leafHash);

  bytes32 constant CONFIRMATION_REWARD = "confirmationReward";

  function configure(address confirmationsAddr_) external onlyOwner {

    confirmationsAddr = ConfirmationsResolver(confirmationsAddr_);
  }

  function getFarmDepositRemaining(bytes32 farmHash) external view returns (uint256) {

    return farmDeposits[farmHash];
  }

  function getAccountTokenConfirmationOffset(address account, address token) external view returns (uint256) {

    return accountTokenConfirmationOffsets[account][token];
  }

  function getFarmConfirmationRewardMax(bytes32 farmHash) external view returns (uint256) {

    return farmConfirmationRewardMax[farmHash];
  }

  function increaseReferralFarm(bytes24 rewardTokenDefn, bytes24 referredTokenDefn, uint128 rewardDeposit, KeyVal[] calldata metastate) external {

    require(
      rewardDeposit > 0 && rewardTokenDefn != ChainAddressExt.getNativeTokenChainAddress(), 
      "400: invalid"
    );

    IERC20(ChainAddressExt.toAddress(rewardTokenDefn)).transferFrom(msg.sender, address(this), uint256(rewardDeposit));

    bytes32 farmHash = toFarmHash(msg.sender, rewardTokenDefn, referredTokenDefn);
    farmDeposits[farmHash] += rewardDeposit;
    
    emit FarmExists(msg.sender, rewardTokenDefn, referredTokenDefn, farmHash);

    emit FarmDepositIncreased(farmHash, rewardDeposit);

    handleMetastateChange(farmHash, metastate);
  }

  function configureMetastate(bytes24 rewardTokenDefn, bytes24 referredTokenDefn, KeyVal[] calldata metastate) external {

    bytes32 farmHash = toFarmHash(msg.sender, rewardTokenDefn, referredTokenDefn);
    handleMetastateChange(farmHash, metastate);
  }

  function handleMetastateChange(bytes32 farmHash, KeyVal[] calldata metastate) private {

    for(uint256 i = 0; i < metastate.length; i++) {
      if(metastate[i].key == CONFIRMATION_REWARD) {
        processConfirmationRewardChangeRequest(farmHash, metastate[i].value);
      }

      emit FarmMetastate(farmHash, metastate[i].key, metastate[i].value);
    }

    require(farmConfirmationRewardMax[farmHash] > 0, "400: confirmationReward");
  }

  function processConfirmationRewardChangeRequest(bytes32 farmHash, bytes calldata value) private {

    (uint128 reward, ) = abi.decode(value, (uint128, uint128));
    if(reward > farmConfirmationRewardMax[farmHash]) {
      farmConfirmationRewardMax[farmHash] = reward;
    }
  }


  function validateEntitlementsSetOffsetOrRevert(address rewardToken, TokenEntitlement[] calldata entitlements) private {

    require(entitlements.length > 0, "400: entitlements");
    uint128 min = entitlements[0].confirmation;
    uint128 max;
    
    for(uint256 i = 0; i < entitlements.length; i++) {
      if(entitlements[i].confirmation < min) {
        min = entitlements[i].confirmation;
      }
      if(entitlements[i].confirmation > max) {
        max = entitlements[i].confirmation;
      }
    }
    
    require(accountTokenConfirmationOffsets[msg.sender][rewardToken] < min, "401: double spend");

    accountTokenConfirmationOffsets[msg.sender][rewardToken] = max;
  }

  function adjustFarmConfirmationRewardRemainingOrRevert(bytes32 farmHash, uint128 confirmation, uint128 value) private {

    uint128 rewardRemaining;
    if(farmConfirmationRewardRemaining[farmHash][confirmation].initialized == false) {
      rewardRemaining = uint128(farmConfirmationRewardMax[farmHash]); 
    } else {
      rewardRemaining = farmConfirmationRewardRemaining[farmHash][confirmation].valueRemaining;
    }

    rewardRemaining -= value; // Underflow will throw here on insufficient confirmation balance.
    farmConfirmationRewardRemaining[farmHash][confirmation] = FarmConfirmationRewardRemaining(true, rewardRemaining);

    farmDeposits[farmHash] -= value; // Underflow will throw here on insufficient balance.
  }

  function harvestRewardsNoGapcheck(HarvestTokenRequest[] calldata reqs, bytes32[][][] calldata proofs) external {

    require(reqs.length > 0 && proofs.length == reqs.length, "400: request");

    for(uint256 i = 0; i < reqs.length; i++) {
      HarvestTokenRequest calldata req = reqs[i];
      require(uint32(block.chainid) == ChainAddressExt.toChainId(req.rewardTokenDefn), "400: chain");
      address rewardTokenAddr = ChainAddressExt.toAddress(req.rewardTokenDefn);

      validateEntitlementsSetOffsetOrRevert(rewardTokenAddr, reqs[i].entitlements);

      uint128 rewardValueSum = 0;
      for(uint256 j = 0; j < req.entitlements.length; j++) {
        TokenEntitlement calldata entitlement = req.entitlements[j];

        bytes32 leafHash = makeLeafHash(req.rewardTokenDefn, entitlement);
        bytes32 computedHash = MerkleProof.processProof(proofs[i][j], leafHash);
        (uint128 confirmation, ) = confirmationsAddr.getConfirmation(computedHash);
        require(confirmation > 0, "401: not finalized proof");  

        adjustFarmConfirmationRewardRemainingOrRevert(entitlement.farmHash, entitlement.confirmation, entitlement.value);

        emit RewardsHarvested(msg.sender, req.rewardTokenDefn, entitlement.farmHash, entitlement.value, leafHash);

        rewardValueSum += entitlement.value;
      }

      if(rewardValueSum > 0) {
        IERC20(rewardTokenAddr).transfer(msg.sender, rewardValueSum);
      }
    }
  }


  function requestDecreaseReferralFarm(bytes24 rewardTokenDefn, bytes24 referredTokenDefn, uint128 value) external {

    bytes32 farmHash = toFarmHash(msg.sender, rewardTokenDefn, referredTokenDefn);
    require(farmDeposits[farmHash] > 0, "400: deposit");

    if(value > farmDeposits[farmHash]) {
      value = uint128(farmDeposits[farmHash]);
    }
    
    (uint128 headConfirmation, ) = confirmationsAddr.getConfirmation(confirmationsAddr.getHead());
    emit FarmDepositDecreaseRequested(farmHash, value, headConfirmation);
  }

  function claimReferralFarmDecrease(bytes24 rewardTokenDefn, bytes24 referredTokenDefn, uint128 confirmation, uint128 value, bytes32[] calldata proof) external {

    bytes32 farmHash = toFarmHash(msg.sender, rewardTokenDefn, referredTokenDefn);

    require(confirmation > farmConfirmationOffsets[farmHash], "400: invalid or burned");

    farmConfirmationOffsets[farmHash] = confirmation;

    bytes32 leafHash = makeDecreaseLeafHash(farmHash, confirmation, value);
    
    bytes32 computedHash = MerkleProof.processProof(proof, leafHash);
    (uint128 searchConfirmation, ) = confirmationsAddr.getConfirmation(computedHash);
    require(searchConfirmation > 0, "401: not finalized proof");

    if(farmDeposits[farmHash] < value) {
      value = uint128(farmDeposits[farmHash]);
    }

    farmDeposits[farmHash] -= value;

    address rewardTokenAddr = ChainAddressExt.toAddress(rewardTokenDefn);
    IERC20(rewardTokenAddr).transfer(msg.sender, value);

    emit FarmDepositDecreaseClaimed(farmHash, value);
  }

  function makeLeafHash(bytes24 rewardTokenDefn, TokenEntitlement calldata entitlement) private view returns (bytes32) {

    return keccak256(abi.encode(
      ChainAddressExt.toChainAddress(block.chainid, address(confirmationsAddr)), 
      ChainAddressExt.toChainAddress(block.chainid, address(this)),
      msg.sender, 
      rewardTokenDefn,
      entitlement
    ));
  }

  function makeDecreaseLeafHash(bytes32 farmHash, uint128 confirmation, uint128 value) private view returns (bytes32) {

    return keccak256(abi.encode(
      ChainAddressExt.toChainAddress(block.chainid, address(confirmationsAddr)), 
      ChainAddressExt.toChainAddress(block.chainid, address(this)),
      farmHash,
      confirmation,
      value
    ));
  }

  receive() external payable {
    revert('unsupported');
  }

  fallback() external payable {
    revert('unsupported');
  }
}

struct KeyVal {
  bytes32 key;
  bytes value;
}

struct FarmConfirmationRewardRemaining {
  bool initialized;
  uint128 valueRemaining;
}

struct HarvestTokenRequest {
  bytes24 rewardTokenDefn;

  TokenEntitlement[] entitlements;
}

struct TokenEntitlement {
  bytes32 farmHash;

  uint128 value;

  uint128 confirmation;
}

function toFarmHash(address sponsor, bytes24 rewardTokenDefn, bytes24 referredTokenDefn) view returns (bytes32 farmHash) {
  return keccak256(abi.encode(block.chainid, sponsor, rewardTokenDefn, referredTokenDefn));
}