
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
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {


    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT
pragma solidity >=0.5.0;

interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);


    function symbol() external pure returns (string memory);


    function decimals() external pure returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 value) external returns (bool);


    function transfer(address to, uint256 value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);


    function PERMIT_TYPEHASH() external pure returns (bytes32);


    function nonces(address owner) external view returns (uint256);


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);


    function factory() external view returns (address);


    function token0() external view returns (address);


    function token1() external view returns (address);


    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );


    function price0CumulativeLast() external view returns (uint256);


    function price1CumulativeLast() external view returns (uint256);


    function kLast() external view returns (uint256);


    function mint(address to) external returns (uint256 liquidity);


    function burn(address to) external returns (uint256 amount0, uint256 amount1);


    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;


    function skim(address to) external;


    function sync() external;


    function initialize(address, address) external;

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
pragma solidity >=0.6.12;
pragma experimental ABIEncoderV2;

interface IMasterChef {

    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. SUSHI to distribute per block.
        uint256 lastRewardBlock; // Last block number that SUSHI distribution occurs.
        uint256 accSushiPerShare; // Accumulated SUSHI per share, times 1e12. See below.
    }

    function poolInfo(uint256 pid) external view returns (IMasterChef.PoolInfo memory);


    function userInfo(uint256 pid, address user) external view returns (IMasterChef.UserInfo memory);


    function pendingSushi(uint256 _pid, address _user) external view returns (uint256);


    function deposit(uint256 _pid, uint256 _amount) external;


    function withdraw(uint256 _pid, uint256 _amount) external;

}// MIT
pragma solidity >=0.5.0;


interface IMasterChefModule {

    function lpToken() external view returns (IUniswapV2Pair);


    function sushi() external view returns (IERC20);


    function sushiMasterChef() external view returns (IMasterChef);


    function masterChefPid() external view returns (uint256);


    function sushiLastRewardBlock() external view returns (uint256);


    function accSushiPerShare() external view returns (uint256);

}// MIT
pragma solidity >=0.5.0;


interface IMaids is IERC721, IERC721Metadata, IERC721Enumerable, IMasterChefModule {

    event Support(uint256 indexed id, uint256 lpTokenAmount);
    event Desupport(uint256 indexed id, uint256 lpTokenAmount);

    function DOMAIN_SEPARATOR() external view returns (bytes32);


    function PERMIT_TYPEHASH() external view returns (bytes32);


    function PERMIT_ALL_TYPEHASH() external view returns (bytes32);


    function MAX_MAID_COUNT() external view returns (uint256);


    function nonces(uint256 id) external view returns (uint256);


    function noncesForAll(address owner) external view returns (uint256);


    function maids(uint256 id)
        external
        view
        returns (
            uint256 originPower,
            uint256 supportedLPTokenAmount,
            uint256 sushiRewardDebt
        );


    function powerAndLP(uint256 id) external view returns (uint256, uint256);


    function support(uint256 id, uint256 lpTokenAmount) external;


    function supportWithPermit(
        uint256 id,
        uint256 lpTokenAmount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function desupport(uint256 id, uint256 lpTokenAmount) external;


    function claimSushiReward(uint256 id) external;


    function pendingSushiReward(uint256 id) external view returns (uint256);


    function permit(
        address spender,
        uint256 id,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function permitAll(
        address owner,
        address spender,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

}// MIT
pragma solidity >=0.5.0;

interface IMaidCoin {

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);


    function symbol() external pure returns (string memory);


    function decimals() external pure returns (uint8);


    function totalSupply() external view returns (uint256);


    function INITIAL_SUPPLY() external pure returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 value) external returns (bool);


    function transfer(address to, uint256 value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);


    function PERMIT_TYPEHASH() external pure returns (bytes32);


    function nonces(address owner) external view returns (uint256);


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function mint(address to, uint256 amount) external;


    function burn(uint256 amount) external;

}// MIT
pragma solidity >=0.5.0;

interface IMaidCafe {

    event Enter(address indexed user, uint256 amount);
    event Leave(address indexed user, uint256 share);

    function maidCoin() external view returns (IMaidCoin);


    function enter(uint256 _amount) external;


    function enterWithPermit(
        uint256 _amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function leave(uint256 _share) external;

}// MIT

pragma solidity ^0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;


    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

}// MIT
pragma solidity >=0.5.0;


interface INursePart is IERC1155 {

    function DOMAIN_SEPARATOR() external view returns (bytes32);


    function PERMIT_TYPEHASH() external view returns (bytes32);


    function nonces(address owner) external view returns (uint256);


    function mint(
        address to,
        uint256 id,
        uint256 amount
    ) external;


    function burn(uint256 id, uint256 amount) external;


    function permit(
        address owner,
        address spender,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

}// MIT

pragma solidity ^0.8.0;


interface ICloneNurseEnumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

}// MIT
pragma solidity >=0.5.0;

interface ISupportable {

    event SupportTo(address indexed supporter, uint256 indexed to);
    event ChangeSupportingRoute(uint256 indexed from, uint256 indexed to);
    event ChangeSupportedPower(uint256 indexed id, int256 power);
    event TransferSupportingRewards(address indexed supporter, uint256 indexed id, uint256 amounts);

    function supportingRoute(uint256 id) external view returns (uint256);


    function supportingTo(address supporter) external view returns (uint256);


    function supportedPower(uint256 id) external view returns (uint256);


    function totalRewardsFromSupporters(uint256 id) external view returns (uint256);


    function setSupportingTo(
        address supporter,
        uint256 to,
        uint256 amounts
    ) external;


    function checkSupportingRoute(address supporter) external returns (address, uint256);


    function changeSupportedPower(address supporter, int256 power) external;


    function shareRewards(
        uint256 pending,
        address supporter,
        uint8 supportingRatio
    ) external returns (address nurseOwner, uint256 amountToNurseOwner);

}// MIT
pragma solidity >=0.5.0;

interface IRewardCalculator {

    function rewardPerBlock() external view returns (uint256);

}// MIT
pragma solidity >=0.5.0;


interface ITheMaster is IMasterChefModule {

    event ChangeRewardCalculator(address addr);

    event Add(
        uint256 indexed pid,
        address addr,
        bool indexed delegate,
        bool indexed mintable,
        address supportable,
        uint8 supportingRatio,
        uint256 allocPoint
    );

    event Set(uint256 indexed pid, uint256 allocPoint);
    event Deposit(uint256 indexed userId, uint256 indexed pid, uint256 amount);
    event Withdraw(uint256 indexed userId, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    event Support(address indexed supporter, uint256 indexed pid, uint256 amount);
    event Desupport(address indexed supporter, uint256 indexed pid, uint256 amount);
    event EmergencyDesupport(address indexed user, uint256 indexed pid, uint256 amount);

    event SetIsSupporterPool(uint256 indexed pid, bool indexed status);

    function initialRewardPerBlock() external view returns (uint256);


    function decreasingInterval() external view returns (uint256);


    function startBlock() external view returns (uint256);


    function maidCoin() external view returns (IMaidCoin);


    function rewardCalculator() external view returns (IRewardCalculator);


    function poolInfo(uint256 pid)
        external
        view
        returns (
            address addr,
            bool delegate,
            ISupportable supportable,
            uint8 supportingRatio,
            uint256 allocPoint,
            uint256 lastRewardBlock,
            uint256 accRewardPerShare,
            uint256 supply
        );


    function poolCount() external view returns (uint256);


    function userInfo(uint256 pid, uint256 user) external view returns (uint256 amount, uint256 rewardDebt);


    function mintableByAddr(address addr) external view returns (bool);


    function totalAllocPoint() external view returns (uint256);


    function pendingReward(uint256 pid, uint256 userId) external view returns (uint256);


    function rewardPerBlock() external view returns (uint256);


    function changeRewardCalculator(address addr) external;


    function add(
        address addr,
        bool delegate,
        bool mintable,
        address supportable,
        uint8 supportingRatio,
        uint256 allocPoint
    ) external;


    function set(uint256[] calldata pid, uint256[] calldata allocPoint) external;


    function deposit(
        uint256 pid,
        uint256 amount,
        uint256 userId
    ) external;


    function depositWithPermit(
        uint256 pid,
        uint256 amount,
        uint256 userId,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function depositWithPermitMax(
        uint256 pid,
        uint256 amount,
        uint256 userId,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function withdraw(
        uint256 pid,
        uint256 amount,
        uint256 userId
    ) external;


    function emergencyWithdraw(uint256 pid) external;


    function support(
        uint256 pid,
        uint256 amount,
        uint256 supportTo
    ) external;


    function supportWithPermit(
        uint256 pid,
        uint256 amount,
        uint256 supportTo,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function supportWithPermitMax(
        uint256 pid,
        uint256 amount,
        uint256 supportTo,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function desupport(uint256 pid, uint256 amount) external;


    function emergencyDesupport(uint256 pid) external;


    function mint(address to, uint256 amount) external;


    function claimSushiReward(uint256 id) external;


    function pendingSushiReward(uint256 id) external view returns (uint256);

}// MIT
pragma solidity >=0.5.0;


interface ICloneNurses is IERC721, IERC721Metadata, ICloneNurseEnumerable, ISupportable {

    event Claim(uint256 indexed id, address indexed claimer, uint256 reward);
    event ElongateLifetime(uint256 indexed id, uint256 rechargedLifetime, uint256 lastEndBlock, uint256 newEndBlock);

    function nursePart() external view returns (INursePart);


    function maidCoin() external view returns (IMaidCoin);


    function theMaster() external view returns (ITheMaster);


    function nurseTypes(uint256 typeId)
        external
        view
        returns (
            uint256 partCount,
            uint256 destroyReturn,
            uint256 power,
            uint256 lifetime
        );


    function nurseTypeCount() external view returns (uint256);


    function nurses(uint256 id)
        external
        view
        returns (
            uint256 nurseType,
            uint256 endBlock,
            uint256 lastClaimedBlock
        );


    function assemble(uint256 nurseType, uint256 parts) external;


    function assembleWithPermit(
        uint256 nurseType,
        uint256 parts,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function elongateLifetime(uint256[] calldata ids, uint256[] calldata parts) external;


    function destroy(uint256[] calldata ids, uint256[] calldata toIds) external;


    function claim(uint256[] calldata ids) external;


    function pendingReward(uint256 id) external view returns (uint256);


    function findSupportingTo(address supporter) external view returns (address, uint256);


    function exists(uint256 id) external view returns (bool);

}// MIT
pragma solidity >=0.5.0;

interface IRNG {

    function generateRandomNumber(uint256 seed, address sender) external returns (uint256);

}// MIT
pragma solidity >=0.5.0;


interface INurseRaid {

    event Create(
        uint256 indexed id,
        uint256 entranceFee,
        uint256 indexed nursePart,
        uint256 maxRewardCount,
        uint256 duration,
        uint256 endBlock
    );
    event Enter(address indexed challenger, uint256 indexed id, IMaids indexed maids, uint256 maidId);
    event Exit(address indexed challenger, uint256 indexed id);
    event ChangeMaidEfficacy(uint256 numerator, uint256 denominator);

    function isMaidsApproved(IMaids maids) external view returns (bool);


    function maidCoin() external view returns (IMaidCoin);


    function maidCafe() external view returns (IMaidCafe);


    function nursePart() external view returns (INursePart);


    function rng() external view returns (IRNG);


    function cloneNurses() external view returns (ICloneNurses);


    function maidEfficacy() external view returns (uint256, uint256);


    function raidCount() external view returns (uint256);


    function create(
        uint256[] calldata entranceFee,
        uint256[] calldata nursePart,
        uint256[] calldata maxRewardCount,
        uint256[] calldata duration,
        uint256[] calldata endBlock
    ) external returns (uint256 id);


    function enter(
        uint256 id,
        IMaids maids,
        uint256 maidId
    ) external;


    function enterWithPermit(
        uint256 id,
        IMaids maids,
        uint256 maidId,
        uint256 deadline,
        uint8 v1,
        bytes32 r1,
        bytes32 s1,
        uint8 v2,
        bytes32 r2,
        bytes32 s2
    ) external;


    function enterWithPermitAll(
        uint256 id,
        IMaids maids,
        uint256 maidId,
        uint256 deadline,
        uint8 v1,
        bytes32 r1,
        bytes32 s1,
        uint8 v2,
        bytes32 r2,
        bytes32 s2
    ) external;


    function checkDone(uint256 id) external view returns (bool);


    function exit(uint256[] calldata ids) external;

}// MIT
pragma solidity >=0.5.0;

interface ISushiGirls {

    function sushiGirls(uint256 id)
        external
        view
        returns (
            uint256 originPower,
            uint256 supportedLPTokenAmount,
            uint256 sushiRewardDebt
        );

}

interface ILingerieGirls {

    function lingerieGirls(uint256 id)
        external
        view
        returns (
            uint256 originPower,
            uint256 supportedLPTokenAmount,
            uint256 sushiRewardDebt
        );

}// MIT
pragma solidity ^0.8.5;


abstract contract MaidPower is Ownable {
    uint256 public lpTokenToMaidPower = 1000;   //1000 : 1LP(1e18 as wei) => 1Power
    address public immutable sushiGirls;
    address public immutable lingerieGirls;

    event ChangeLPTokenToMaidPower(uint256 value);

    constructor(address _sushiGirls, address _lingerieGirls) {
        sushiGirls = _sushiGirls;
        lingerieGirls = _lingerieGirls;
    }

    function changeLPTokenToMaidPower(uint256 value) external onlyOwner {
        lpTokenToMaidPower = value;
        emit ChangeLPTokenToMaidPower(value);
    }

    function powerOfMaids(IMaids maids, uint256 id) public view returns (uint256) {
        uint256 originPower;
        uint256 supportedLPAmount;

        if (address(maids) == sushiGirls) {
            (originPower, supportedLPAmount,) = ISushiGirls(sushiGirls).sushiGirls(id);
        } else if (address(maids) == lingerieGirls) {
            (originPower, supportedLPAmount,) = ILingerieGirls(lingerieGirls).lingerieGirls(id);
        } else {
            (originPower, supportedLPAmount) = maids.powerAndLP(id);
        }

        return originPower + (supportedLPAmount * lpTokenToMaidPower) / 1e21;
    }
}// MIT
pragma solidity ^0.8.5;


contract NurseRaid is Ownable, MaidPower, INurseRaid {

    struct Raid {
        uint256 entranceFee;
        uint256 nursePart;
        uint256 maxRewardCount;
        uint256 duration;
        uint256 endBlock;
    }

    struct Challenger {
        uint256 enterBlock;
        IMaids maids;
        uint256 maidId;
    }

    struct MaidEfficacy {
        uint256 numerator;
        uint256 denominator;
    }

    Raid[] public raids;
    mapping(uint256 => mapping(address => Challenger)) public challengers;

    mapping(IMaids => bool) public override isMaidsApproved;

    IMaidCoin public immutable override maidCoin;
    IMaidCafe public override maidCafe;
    INursePart public immutable override nursePart;
    ICloneNurses public immutable override cloneNurses;
    IRNG public override rng;

    MaidEfficacy public override maidEfficacy = MaidEfficacy({numerator: 1, denominator: 1000});

    constructor(
        IMaidCoin _maidCoin,
        IMaidCafe _maidCafe,
        INursePart _nursePart,
        ICloneNurses _cloneNurses,
        IRNG _rng,
        address _sushiGirls,
        address _lingerieGirls
    ) MaidPower(_sushiGirls, _lingerieGirls) {
        maidCoin = _maidCoin;
        maidCafe = _maidCafe;
        nursePart = _nursePart;
        cloneNurses = _cloneNurses;
        rng = _rng;
    }

    function changeMaidEfficacy(uint256 _numerator, uint256 _denominator) external onlyOwner {

        maidEfficacy = MaidEfficacy({numerator: _numerator, denominator: _denominator});
        emit ChangeMaidEfficacy(_numerator, _denominator);
    }

    function setMaidCafe(IMaidCafe _maidCafe) external onlyOwner {

        maidCafe = _maidCafe;
    }

    function approveMaids(IMaids[] calldata maids) public onlyOwner {

        for (uint256 i = 0; i < maids.length; i += 1) {
            isMaidsApproved[maids[i]] = true;
        }
    }

    function disapproveMaids(IMaids[] calldata maids) public onlyOwner {

        for (uint256 i = 0; i < maids.length; i += 1) {
            isMaidsApproved[maids[i]] = false;
        }
    }

    modifier onlyApprovedMaids(IMaids maids) {

        require(address(maids) == address(0) || isMaidsApproved[maids], "NurseRaid: The maids is not approved");
        _;
    }

    function changeRNG(address addr) external onlyOwner {

        rng = IRNG(addr);
    }

    function raidCount() external view override returns (uint256) {

        return raids.length;
    }

    function create(
        uint256[] calldata entranceFees,
        uint256[] calldata _nurseParts,
        uint256[] calldata maxRewardCounts,
        uint256[] calldata durations,
        uint256[] calldata endBlocks
    ) external override onlyOwner returns (uint256 id) {

        uint256 length = entranceFees.length;
        for (uint256 i = 0; i < length; i++) {
            require(maxRewardCounts[i] < 255, "NurseRaid: Invalid number");
            {   // scope to avoid stack too deep errors
                (uint256 nursePartCount, uint256 nurseDestroyReturn, , ) = cloneNurses.nurseTypes(_nurseParts[i]);

                require(
                    entranceFees[i] >= (nurseDestroyReturn * maxRewardCounts[i]) / nursePartCount,
                    "NurseRaid: Fee should be higher"
                );
            }
            id = raids.length;
            raids.push(
                Raid({
                    entranceFee: entranceFees[i],
                    nursePart: _nurseParts[i],
                    maxRewardCount: maxRewardCounts[i],
                    duration: durations[i],
                    endBlock: endBlocks[i]
                })
            );
            emit Create(id, entranceFees[i], _nurseParts[i], maxRewardCounts[i], durations[i], endBlocks[i]);
        }
    }

    function enter(
        uint256 id,
        IMaids maids,
        uint256 maidId
    ) public override onlyApprovedMaids(maids) {

        Raid storage raid = raids[id];
        require(block.number < raid.endBlock, "NurseRaid: Raid has ended");
        require(challengers[id][msg.sender].enterBlock == 0, "NurseRaid: Raid is in progress");
        challengers[id][msg.sender] = Challenger({enterBlock: block.number, maids: maids, maidId: maidId});
        if (address(maids) != address(0)) {
            maids.transferFrom(msg.sender, address(this), maidId);
        }
        uint256 _entranceFee = raid.entranceFee;
        maidCoin.transferFrom(msg.sender, address(this), _entranceFee);
        uint256 feeToCafe = (_entranceFee * 3) / 1000;
        _feeTransfer(feeToCafe);
        maidCoin.burn(_entranceFee - feeToCafe);
        emit Enter(msg.sender, id, maids, maidId);
    }

    function enterWithPermit(
        uint256 id,
        IMaids maids,
        uint256 maidId,
        uint256 deadline,
        uint8 v1,
        bytes32 r1,
        bytes32 s1,
        uint8 v2,
        bytes32 r2,
        bytes32 s2
    ) external override {

        maidCoin.permit(msg.sender, address(this), raids[id].entranceFee, deadline, v1, r1, s1);
        if (address(maids) != address(0)) {
            maids.permit(msg.sender, maidId, deadline, v2, r2, s2);
        }
        enter(id, maids, maidId);
    }

    function enterWithPermitAll(
        uint256 id,
        IMaids maids,
        uint256 maidId,
        uint256 deadline,
        uint8 v1,
        bytes32 r1,
        bytes32 s1,
        uint8 v2,
        bytes32 r2,
        bytes32 s2
    ) external override {

        maidCoin.permit(msg.sender, address(this), type(uint256).max, deadline, v1, r1, s1);
        if (address(maids) != address(0)) {
            maids.permitAll(msg.sender, address(this), deadline, v2, r2, s2);
        }
        enter(id, maids, maidId);
    }

    function checkDone(uint256 id) public view override returns (bool) {

        Raid memory raid = raids[id];
        Challenger memory challenger = challengers[id][msg.sender];

        return _checkDone(raid.duration, challenger);
    }

    function _checkDone(uint256 duration, Challenger memory challenger) internal view returns (bool) {

        if (address(challenger.maids) == address(0)) {
            return block.number - challenger.enterBlock >= duration;
        } else {
            return
                block.number - challenger.enterBlock >=
                duration -
                    ((duration * powerOfMaids(challenger.maids, challenger.maidId) * maidEfficacy.numerator) /
                        maidEfficacy.denominator);
        }
    }

    function exit(uint256[] calldata ids) external override {

        for (uint256 i = 0; i < ids.length; i++) {
            Challenger memory challenger = challengers[ids[i]][msg.sender];
            require(challenger.enterBlock != 0, "NurseRaid: Not participating in the raid");

            Raid storage raid = raids[ids[i]];

            if (_checkDone(raid.duration, challenger)) {
                uint256 rewardCount = _randomReward(ids[i], raid.maxRewardCount, msg.sender);
                nursePart.mint(msg.sender, raid.nursePart, rewardCount);
            }

            if (address(challenger.maids) != address(0)) {
                challenger.maids.transferFrom(address(this), msg.sender, challenger.maidId);
            }

            delete challengers[ids[i]][msg.sender];
            emit Exit(msg.sender, ids[i]);
        }
    }

    function _randomReward(
        uint256 _id,
        uint256 _maxRewardCount,
        address sender
    ) internal returns (uint256 rewardCount) {

        uint256 totalNumber = 2 * (2**_maxRewardCount - 1);
        uint256 randomNumber = (rng.generateRandomNumber(_id, sender) % totalNumber) + 1;

        uint256 ceil;
        uint256 i = 0;

        while (randomNumber > ceil) {
            i += 1;
            ceil = (2**(_maxRewardCount + 1)) - (2**(_maxRewardCount + 1 - i));
        }

        rewardCount = i;
    }

    function _feeTransfer(uint256 feeToCafe) internal {

        maidCoin.transfer(address(maidCafe), feeToCafe);
    }
}