
pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {

	  address private _owner = 0xe39b8617D571CEe5e75e1EC6B2bb40DdC8CF6Fa3; // Votium multi-sig address

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;


interface Ifarm {

  function getReward() external returns(bool);

  function withdraw(uint256, bool) external returns(bool);

}

interface Locker {

  function deposit(uint256, bool, address) external; // amount, false, address(farm)

}

contract MerkleStash is Ownable {

  using SafeERC20 for IERC20;

  IERC20 public cvxCRV = IERC20(0x62B9c7356A2Dc64a1969e19C23e4f579F9810Aa7);
  IERC20 public CRV = IERC20(0xD533a949740bb3306d119CC777fa900bA034cd52);
  Ifarm public farm = Ifarm(0x3Fe65692bfCD0e6CF84cB1E7d24108E434A7587e);
  Locker public locker = Locker(0x8014595F2AB54cD7c604B00E9fb932176fDc86Ae);

  bytes32 public merkleRoot;
  uint256 public update;
  bool public frozen = true;
  mapping(uint256 => mapping(uint256 => uint256)) private claimedBitMap;

  address[] public farmTokens;
  address[] public team;
  uint256[] public weights;
  uint256 public constant DENOMINATOR = 10000; // denominates weights 10000 = 100%

  constructor() {
    farmTokens.push(address(CRV));                               // CRV
    farmTokens.push(0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490); // 3crv
    farmTokens.push(0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B); // CVX
    team.push(0xC8076F60cbDd2EE93D54FCc0ced88095A72f4a2f);
    team.push(0xAdE9e51C9E23d64E538A7A38656B78aB6Bcc349e);
    weights.push(5000);
    weights.push(5000);
  }

  function isClaimed(uint256 index) public view returns (bool) {

    uint256 claimedWordIndex = index / 256;
    uint256 claimedBitIndex = index % 256;
    uint256 claimedWord = claimedBitMap[update][claimedWordIndex];
    uint256 mask = (1 << claimedBitIndex);
    return claimedWord & mask == mask;
  }

  function _setClaimed(uint256 index) private {

    uint256 claimedWordIndex = index / 256;
    uint256 claimedBitIndex = index % 256;
    claimedBitMap[update][claimedWordIndex] = claimedBitMap[update][claimedWordIndex] | (1 << claimedBitIndex);
  }

  function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external {

    require(!frozen, 'MerkleDistributor: Claiming is frozen.');
    require(!isClaimed(index), 'MerkleDistributor: Drop already claimed.');

    bytes32 node = keccak256(abi.encodePacked(index, account, amount));
    require(MerkleProof.verify(merkleProof, merkleRoot, node), 'MerkleDistributor: Invalid proof.');

    require(farm.withdraw(amount, false), "Could not withdraw from farm");

    _setClaimed(index);
    cvxCRV.safeTransfer(account, amount);

    emit Claimed(index, amount, account, update);
  }


  function freeze() public onlyOwner {

    frozen = true;
  }

  function unfreeze() public onlyOwner {

    frozen = false;
  }

  function updateMerkleRoot(bytes32 _merkleRoot) public onlyOwner {

    require(frozen, 'MerkleDistributor: Contract not frozen.');

    update += 1;
    merkleRoot = _merkleRoot;

    emit MerkleRootUpdated(merkleRoot, update);
  }

  function addFarmToken(address _token) public onlyOwner {

    require(_token != address(cvxCRV), "Cannot add cvxCRV to farmed tokens");
    farmTokens.push(_token);
  }
  function replaceFarmToken(uint256 _index, address _token) public onlyOwner {

    require(_token != address(cvxCRV), "Cannot add cvxCRV to farmed tokens");
    farmTokens[_index] = _token;
  }

  function addTeam(address _team, uint256 _weight) public onlyOwner {

    team.push(_team);
    weights.push(_weight);
  }
  function adjustTeam(uint256 _index, address _team, uint256 _weight) public onlyOwner {

    require(team[_index] != address(0), "unassigned index");
    team[_index] = _team;
    weights[_index] = _weight;
  }

  function execute(address _to, uint256 _value, bytes calldata _data) external onlyOwner returns (bool, bytes memory) {

    (bool success, bytes memory result) = _to.call{value:_value}(_data);
    return (success, result);
  }

  function claimTeam() public {

    farm.getReward();
    uint256 bal;
    uint256 split;
    IERC20 ft;
    for(uint32 i=0;i<farmTokens.length;i++) {
      ft = IERC20(farmTokens[i]);
      bal = ft.balanceOf(address(this));
      for(uint32 n=0;n<team.length;n++) {
        if(weights[n] > 0) {
          split = bal*weights[n]/DENOMINATOR;
          ft.safeTransfer(team[n], split);
        }
      }
    }
  }

  function lockCRV(uint256 _amount) public {

    CRV.safeTransferFrom(msg.sender, address(this), _amount);
    CRV.approve(address(locker), _amount);
    locker.deposit(_amount, false, address(farm));
  }

  event Claimed(uint256 index, uint256 amount, address indexed account, uint256 indexed update);
  event MerkleRootUpdated(bytes32 indexed merkleRoot, uint256 indexed update);
}