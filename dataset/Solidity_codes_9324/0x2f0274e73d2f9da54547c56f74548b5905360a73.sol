


pragma solidity ^0.8.13;

library MerkleProof {

    struct Proof {
        uint16 nodeIndex;
        bytes32[] hashes;
    }

    function isValid(
        Proof memory proof,
        bytes32 node,
        bytes32 merkleRoot
    ) internal pure returns (bool) {

        uint256 length = proof.hashes.length;
        uint16 nodeIndex = proof.nodeIndex;
        for (uint256 i = 0; i < length; i++) {
            if (nodeIndex % 2 == 0) {
                node = keccak256(abi.encodePacked(node, proof.hashes[i]));
            } else {
                node = keccak256(abi.encodePacked(proof.hashes[i], node));
            }
            nodeIndex /= 2;
        }

        return node == merkleRoot;
    }
}



pragma solidity ^0.8.13;

interface IInitialDistribution {

    event DistributonStarted();
    event DistributonEnded();
    event TokenDistributed(address receiver, uint256 receiveAmount, uint256 amountDeposited);

    function getAmountForDeposit(uint256 depositAmount) external view returns (uint256);


    function getDefaultMinOutput(uint256 depositAmount) external view returns (uint256);


    function getLeftInTranche() external view returns (uint256);


    function ape(uint256 minOutputAmount) external payable;


    function ape(uint256 minOutputAmount, MerkleProof.Proof calldata proof) external payable;


    function start() external;


    function end() external;

}




pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.8.13;

interface ICNCToken is IERC20 {

    event MinterAdded(address minter);
    event MinterRemoved(address minter);
    event InitialDistributionMinted(uint256 amount);
    event AirdropMinted(uint256 amount);
    event AMMRewardsMinted(uint256 amount);
    event TreasuryRewardsMinted(uint256 amount);
    event SeedShareMinted(uint256 amount);

    function mintInitialDistribution(address distribution) external;


    function mintAirdrop(address airdropHandler) external;


    function mintAMMRewards(address ammGauge) external;


    function mint(address account, uint256 amount) external returns (uint256);


    function listMinters() external view returns (address[] memory);


    function inflationMintedRatio() external view returns (uint256);

}




pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




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
}




pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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
}




pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



pragma solidity ^0.8.13;

library ScaledMath {

    uint256 internal constant DECIMALS = 18;
    uint256 internal constant ONE = 10**DECIMALS;

    function mulDown(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a * b) / ONE;
    }

    function divDown(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a * ONE) / b;
    }
}



pragma solidity ^0.8.13;





contract InitialDistribution is IInitialDistribution, Ownable {

    using ScaledMath for uint256;
    using SafeERC20 for IERC20;
    using MerkleProof for MerkleProof.Proof;

    uint256 internal constant TOTAL_AMOUNT = 0.3e18 * 10_000_000;
    uint256 internal constant MIN_DURATION = 1 days;

    uint256 public constant ETH_PER_TRANCHE = 14e18;
    uint256 public constant WHITELIST_DURATION = 3 hours;
    uint256 internal constant INFLATION_SCALE = 1e18;
    uint256 internal constant REDUCTION_RATIO = 0.53333e18;
    uint256 internal constant INITIAL_TRANCHE = 0.14e18 * 10_000_000;

    address public immutable token;
    address public immutable treasury;
    uint256 public immutable maxPerUser;
    bytes32 public immutable merkleRoot;
    uint256 public startedAt;
    uint256 public endedAt;

    uint256 public exchangeRate;
    uint256 public currentTrancheSize;
    uint256 public lastReductionAmount;
    uint256 public totalMinted;

    mapping(address => uint256) public apedPerUser;

    constructor(
        address _token,
        address _treasury,
        uint256 _maxPerUser,
        bytes32 _merkleRoot
    ) {
        token = _token;
        treasury = _treasury;
        exchangeRate = INITIAL_TRANCHE.divDown(ETH_PER_TRANCHE) * INFLATION_SCALE;
        currentTrancheSize = INITIAL_TRANCHE;
        maxPerUser = _maxPerUser;
        merkleRoot = _merkleRoot;
    }

    function getAmountForDeposit(uint256 depositAmount) public view returns (uint256) {

        return
            _getAmountForDeposit(
                depositAmount,
                exchangeRate,
                currentTrancheSize,
                getLeftInTranche()
            );
    }

    function getDefaultMinOutput(uint256 depositAmount) external view returns (uint256) {

        uint256 initialExchangeRate = exchangeRate.mulDown(REDUCTION_RATIO);
        uint256 _currentTrancheSize = currentTrancheSize;
        uint256 trancheSize = _currentTrancheSize.mulDown(REDUCTION_RATIO);
        uint256 extraMinted = getAmountForDeposit(ETH_PER_TRANCHE);
        uint256 leftInTranche = (lastReductionAmount + _currentTrancheSize) +
            trancheSize -
            (totalMinted + extraMinted);
        return _getAmountForDeposit(depositAmount, initialExchangeRate, trancheSize, leftInTranche);
    }

    function _getAmountForDeposit(
        uint256 depositAmount,
        uint256 initialExchangeRate,
        uint256 initialTrancheSize,
        uint256 leftInTranche
    ) internal pure returns (uint256) {

        uint256 amountAtRate = depositAmount.mulDown(initialExchangeRate) / INFLATION_SCALE;
        if (amountAtRate <= leftInTranche) {
            return amountAtRate;
        }

        uint256 receiveAmount;
        uint256 amountSatisfied;
        uint256 tempTrancheSize = initialTrancheSize;
        uint256 tempExchangeRate = initialExchangeRate;

        while (amountSatisfied <= depositAmount) {
            if (amountAtRate >= leftInTranche) {
                amountSatisfied += (leftInTranche * INFLATION_SCALE).divDown(tempExchangeRate);
                receiveAmount += leftInTranche;
            } else {
                receiveAmount += amountAtRate;
                break;
            }
            tempExchangeRate = tempExchangeRate.mulDown(REDUCTION_RATIO);
            tempTrancheSize = tempTrancheSize.mulDown(REDUCTION_RATIO);
            amountAtRate =
                (depositAmount - amountSatisfied).mulDown(tempExchangeRate) /
                INFLATION_SCALE;
            leftInTranche = tempTrancheSize;
        }
        return receiveAmount;
    }

    function getLeftInTranche() public view override returns (uint256) {

        return lastReductionAmount + currentTrancheSize - totalMinted;
    }

    function ape(uint256 minOutputAmount, MerkleProof.Proof calldata proof)
        external
        payable
        override
    {

        if (startedAt + WHITELIST_DURATION >= block.timestamp) {
            bytes32 node = keccak256(abi.encodePacked(msg.sender));
            require(proof.isValid(node, merkleRoot), "invalid proof");
        }
        _ape(minOutputAmount);
    }

    function ape(uint256 minOutputAmount) external payable override {

        require(startedAt + WHITELIST_DURATION <= block.timestamp, "whitelist is active");
        _ape(minOutputAmount);
    }

    function _ape(uint256 minOutputAmount) internal {

        require(msg.value > 0, "nothing to ape");
        require(endedAt == 0, "distribution has ended");
        require(startedAt != 0, "distribution has not yet started");
        require(exchangeRate > 1e18, "distribution has exceeded max exchange rate");

        uint256 aped = apedPerUser[msg.sender];
        require(aped + msg.value <= maxPerUser, "cannot ape more than 1 ETH");
        apedPerUser[msg.sender] = aped + msg.value;

        uint256 amountAtRate = (msg.value).mulDown(exchangeRate) / INFLATION_SCALE;
        uint256 leftInTranche = getLeftInTranche();
        if (amountAtRate <= leftInTranche) {
            require(amountAtRate >= minOutputAmount, "too much slippage");
            totalMinted += amountAtRate;
            IERC20(token).safeTransfer(msg.sender, amountAtRate);
            (bool sent, ) = payable(treasury).call{value: msg.value, gas: 20000}("");
            require(sent, "failed to send to treasury");
            emit TokenDistributed(msg.sender, amountAtRate, msg.value);
            return;
        }

        uint256 receiveAmount;
        uint256 amountSatisfied;

        while (amountSatisfied <= msg.value) {
            if (amountAtRate >= leftInTranche) {
                amountSatisfied += (leftInTranche * INFLATION_SCALE).divDown(exchangeRate);
                receiveAmount += leftInTranche;
            } else {
                receiveAmount += amountAtRate;
                break;
            }
            lastReductionAmount = lastReductionAmount + currentTrancheSize;
            exchangeRate = exchangeRate.mulDown(REDUCTION_RATIO);
            currentTrancheSize = currentTrancheSize.mulDown(REDUCTION_RATIO);
            amountAtRate = (msg.value - amountSatisfied).mulDown(exchangeRate) / INFLATION_SCALE;
            leftInTranche = currentTrancheSize;
        }
        totalMinted += receiveAmount;

        require(receiveAmount >= minOutputAmount, "too much slippage");
        (bool sent, ) = payable(treasury).call{value: msg.value, gas: 20000}("");
        require(sent, "failed to send to treasury");
        IERC20(token).safeTransfer(msg.sender, receiveAmount);
        emit TokenDistributed(msg.sender, receiveAmount, msg.value);
    }

    function start() external override onlyOwner {

        require(startedAt == 0, "distribution already started");
        startedAt = block.timestamp;
        emit DistributonStarted();
    }

    function end() external override onlyOwner {

        require(block.timestamp > startedAt + MIN_DURATION);
        require(endedAt == 0, "distribution already ended");
        IERC20 _token = IERC20(token);
        _token.safeTransfer(treasury, _token.balanceOf(address(this)));
        endedAt = block.timestamp;
        emit DistributonEnded();
    }
}