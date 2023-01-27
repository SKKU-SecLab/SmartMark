
pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.6.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

pragma solidity ^0.6.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.6.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity ^0.6.0;

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

pragma solidity ^0.6.2;

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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

pragma solidity ^0.6.0;


library SafeERC20 {

    using SafeMath for uint256;
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

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.6.2;


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

pragma solidity ^0.6.0;

contract ReentrancyGuard {


    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}pragma solidity 0.6.12;

library SafeMath96 {


    function add(uint96 a, uint96 b, string memory errorMessage) internal pure returns (uint96) {

        uint96 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function add(uint96 a, uint96 b) internal pure returns (uint96) {

        return add(a, b, "SafeMath96: addition overflow");
    }

    function sub(uint96 a, uint96 b, string memory errorMessage) internal pure returns (uint96) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function sub(uint96 a, uint96 b) internal pure returns (uint96) {

        return sub(a, b, "SafeMath96: subtraction overflow");
    }

    function fromUint(uint n, string memory errorMessage) internal pure returns (uint96) {

        require(n < 2**96, errorMessage);
        return uint96(n);
    }

    function fromUint(uint n) internal pure returns (uint96) {

        return fromUint(n, "SafeMath96: exceeds 96 bits");
    }
}pragma solidity 0.6.12;

library SafeMath32 {


    function add(uint32 a, uint32 b, string memory errorMessage) internal pure returns (uint32) {

        uint32 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function add(uint32 a, uint32 b) internal pure returns (uint32) {

        return add(a, b, "SafeMath32: addition overflow");
    }

    function sub(uint32 a, uint32 b, string memory errorMessage) internal pure returns (uint32) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function sub(uint32 a, uint32 b) internal pure returns (uint32) {

        return sub(a, b, "SafeMath32: subtraction overflow");
    }

    function fromUint(uint n, string memory errorMessage) internal pure returns (uint32) {

        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function fromUint(uint n) internal pure returns (uint32) {

        return fromUint(n, "SafeMath32: exceeds 32 bits");
    }
}pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;


contract RoyalDecks is Ownable, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeMath96 for uint96;
    using SafeMath32 for uint32;

    using SafeERC20 for IERC20;



    struct Stake {
        uint96 amountStaked;   // $KING amount staked on `startTime`
        uint96 amountDue;      // $KING amount due on `unlockTime`
        uint32 startTime;      // UNIX-time the tokens get staked on
        uint32 unlockTime;     // UNIX-time the tokens get locked until
    }

    struct TermSheet {
        bool enabled;          // If staking is enabled
        address nft;           // ERC-721 contract of the NFT to stake
        uint96 minAmount;      // Min $KING amount to stake (with the NFT)
        uint96 kingFactor;     // Multiplier, scaled by 1e+6 (see (1) above)
        uint16 lockHours;      // Staking period in hours
    }

    struct UserStakes {
        uint256[] ids;
        mapping(uint256 => Stake) data;
    }

    bool public emergencyWithdrawEnabled = false;

    uint32 lastAirBlock;

    uint96 public kingDue;
    uint96 public kingReserves;

    address public king;

    TermSheet[] internal termSheets;

    uint256[] internal airPools;
    uint256 constant internal MAX_AIR_POOLS_QTY = 12; // to limit gas

    mapping(address => UserStakes) internal stakes;

    mapping(address => uint256) internal accAirKingPerNft;

    mapping(uint256 => uint256) internal accAirKingBias;

    event Deposit(
        address indexed user,
        uint256 stakeId,       // ID of the NFT
        uint256 amountStaked,  // $KING amount staked
        uint256 amountDue,     // $KING amount to be returned
        uint256 unlockTime     // UNIX-time when the stake is unlocked
    );

    event Withdraw(
        address indexed user,
        uint256 stakeId        // ID of the NFT
    );

    event Emergency(bool enabled);
    event EmergencyWithdraw(
        address indexed user,
        uint256 stakeId        // ID of the NFT
    );

    event NewTermSheet(
        uint256 indexed termsId,
        address indexed nft,   // Address of the ERC-721 contract
        uint256 minAmount,     // Min $KING amount to stake
        uint256 lockHours,     // Staking period in hours
        uint256 kingFactor     // See (1) above
    );

    event TermsEnabled(uint256 indexed termsId);
    event TermsDisabled(uint256 indexed termsId);

    event Reserved(uint256 amount);
    event Removed(uint256 amount);

    event Airdrop(uint256 amount);

    constructor(address _king) public {
        king = _king;
    }

    function encodeStakeId(
        address nft,           // NFT contract address
        uint256 nftId,         // Token ID (limited to 48 bits)
        uint256 startTime,     // UNIX time (limited to 32 bits)
        uint256 stakeHours     // Stake duration (limited to 16 bits)
    ) public pure returns (uint256) {

        require(nftId < 2**48, "RDeck::nftId_EXCEEDS_48_BITS");
        require(startTime < 2**32, "RDeck::nftId_EXCEEDS_32_BITS");
        require(stakeHours < 2**16, "RDeck::stakeHours_EXCEEDS_16_BITS");
        return _encodeStakeId(nft, nftId, startTime, stakeHours);
    }

    function decodeStakeId(uint256 stakeId)
        public
        pure
        returns (
            address nft,
            uint256 nftId,
            uint256 startTime,
            uint256 stakeHours
        )
    {

        nft = address(stakeId >> 96);
        nftId = (stakeId >> 48) & (2**48 - 1);
        startTime = (stakeId >> 16) & (2**32 - 1);
        stakeHours = stakeId & (2**16 - 1);
    }

    function stakeIds(address user) external view returns (uint256[] memory) {

        _revertZeroAddress(user);
        UserStakes storage userStakes = stakes[user];
        return userStakes.ids;
    }

    function stakeData(
        address user,
        uint256 stakeId
    ) external view returns (Stake memory)
    {

        return stakes[_nonZeroAddr(user)].data[stakeId];
    }

    function pendedAirdrop(
        uint256 stakeId
    ) external view returns (uint256 kingAmount) {

        kingAmount = 0;
        (address nft, , , ) = decodeStakeId(stakeId);
        if (nft != address(0)) {
            uint256 accAir = accAirKingPerNft[nft];
            if (accAir > 1) {
                uint256 bias = accAirKingBias[stakeId];
                if (accAir > bias) kingAmount = accAir.sub(bias);
            }
        }
    }

    function termSheet(uint256 termsId) external view returns (TermSheet memory) {

        return termSheets[_validTermsID(termsId)];
    }

    function termsLength() external view returns (uint256) {

        return termSheets.length;
    }

    function deposit(
        uint256 termsId,       // term sheet ID
        uint256 nftId,         // ID of NFT to stake
        uint256 kingAmount     // $KING amount to stake
    ) public nonReentrant {

        TermSheet memory terms = termSheets[_validTermsID(termsId)];
        require(terms.enabled, "deposit: terms disabled");

        uint96 amountStaked = SafeMath96.fromUint(kingAmount);
        require(amountStaked >= terms.minAmount, "deposit: too small amount");

        uint96 amountDue = SafeMath96.fromUint(
            kingAmount.mul(uint256(terms.kingFactor)).div(1e6)
        );
        uint96 _totalDue = kingDue.add(amountDue);
        uint96 _newReserves = kingReserves.add(amountStaked);
        require(_newReserves >= _totalDue, "deposit: too low reserves");

        uint256 stakeId = _encodeStakeId(
            terms.nft,
            nftId,
            now,
            terms.lockHours
        );

        IERC20(king).safeTransferFrom(msg.sender, address(this), amountStaked);
        IERC721(terms.nft).safeTransferFrom(
            msg.sender,
            address(this),
            nftId,
            _NFT_PASS
        );

        kingDue = _totalDue;
        kingReserves = _newReserves;

        uint32 startTime = SafeMath32.fromUint(now);
        uint32 unlockTime = startTime.add(uint32(terms.lockHours) * 3600);
        _addUserStake(
            stakes[msg.sender],
            stakeId,
            Stake(
                amountStaked,
                amountDue,
                startTime,
                SafeMath32.fromUint(unlockTime)
            )
        );

        uint256 accAir = accAirKingPerNft[terms.nft];
        if (accAir > 1) accAirKingBias[stakeId] = accAir;

        emit Deposit(msg.sender, stakeId, kingAmount, amountDue, unlockTime);
    }

    function withdraw(uint256 stakeId) public nonReentrant {

        _withdraw(stakeId, false);
        emit Withdraw(msg.sender, stakeId);
    }

    function emergencyWithdraw(uint256 stakeId) public nonReentrant {

        _withdraw(stakeId, true);
        emit EmergencyWithdraw(msg.sender, stakeId);
    }

    function collectAirdrops() external nonReentrant {

        if (block.number <= lastAirBlock) return;
        lastAirBlock = SafeMath32.fromUint(block.number);

        uint256 reward;
        {
            uint256 _kingReserves = kingReserves;
            uint256 kingBalance = IERC20(king).balanceOf(address(this));
            if (kingBalance <= _kingReserves) return;
            reward = kingBalance.sub(_kingReserves);
            kingReserves = SafeMath96.fromUint(_kingReserves.add(reward));
            kingDue = kingDue.add(uint96(reward));
        }

        address[MAX_AIR_POOLS_QTY] memory nfts;
        uint256[MAX_AIR_POOLS_QTY] memory weights;
        uint256 totalWeight;
        uint256 qty = airPools.length;
        uint256 k = 0;
        for (uint256 i = 0; i < qty; i++) {
            (address nft, uint256 weight) = _unpackAirPoolData(airPools[i]);
            uint256 nftQty = IERC721(nft).balanceOf(address(this));
            if (nftQty == 0 || weight == 0) continue;
            nfts[k] = nft;
            weights[k] = weight;
            k++;
            totalWeight = totalWeight.add(nftQty.mul(weight));
        }

        for (uint i = 0; i <= k; i++) {
            address nft = nfts[i];
            accAirKingPerNft[nft] = accAirKingPerNft[nft].add(
                reward.mul(weights[i]).div(totalWeight) // can't be zero
            );
        }
        emit Airdrop(reward);
    }

    function addTerms(TermSheet[] memory _termSheets) public onlyOwner {

        for (uint256 i = 0; i < _termSheets.length; i++) {
            _addTermSheet(_termSheets[i]);
        }
    }

    function enableTerms(uint256 termsId) external onlyOwner {

        termSheets[_validTermsID(termsId)].enabled = true;
        emit TermsEnabled(termsId);
    }

    function disableTerms(uint256 termsId) external onlyOwner {

        termSheets[_validTermsID(termsId)].enabled = false;
        emit TermsDisabled(termsId);
    }

    function enableEmergencyWithdraw() external onlyOwner {

        emergencyWithdrawEnabled = true;
        emit Emergency(true);
    }

    function disableEmergencyWithdraw() external onlyOwner {

        emergencyWithdrawEnabled = false;
        emit Emergency(false);
    }

    function addAirdropPools(
        address[] memory nftAddresses,
        uint8[] memory nftWeights
    ) public onlyOwner {

        uint length = nftAddresses.length;
        require(length == nftWeights.length, "RDeck:INVALID_ARRAY_LENGTH");
        for (uint256 i = 0; i < length; i++) {
            require(
                airPools.length < MAX_AIR_POOLS_QTY,
                "RDeck:MAX_AIR_POOLS_QTY"
            );
            uint8 w = nftWeights[i];
            require(w != 0, "RDeck:INVALID_AIR_WEIGHT");
            address a = nftAddresses[i];
            _revertZeroAddress(a);
            require(accAirKingPerNft[a] == 0, "RDeck:AIR_POOL_EXISTS");
            accAirKingPerNft[a] == 1;
            airPools.push(_packAirPoolData(a, w));
        }
    }

    function removeAirdropPool(
        address nft,
        uint8 weight
    ) external onlyOwner {

        require(accAirKingPerNft[nft] != 0, "RDeck:UNKNOWN_AIR_POOL");
        accAirKingPerNft[nft] = 0;
        _removeArrayElement(airPools, _packAirPoolData(nft, weight));
    }

    function addKingReserves(address from, uint256 amount) external onlyOwner {

        IERC20(king).safeTransferFrom(from, address(this), amount);
        kingReserves = kingReserves.add(SafeMath96.fromUint(amount));
        emit Reserved(amount);
    }

    function removeKingReserves(uint256 amount) external onlyOwner {

        uint96 _newReserves = kingReserves.sub(SafeMath96.fromUint(amount));
        require(_newReserves >= kingDue, "RDeck:TOO_LOW_RESERVES");

        kingReserves = _newReserves;
        IERC20(king).safeTransfer(owner(), amount);
        emit Removed(amount);
    }

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;
    bytes private constant _NFT_PASS = abi.encodePacked(bytes4(0x8adbe135));

    function onERC721Received(address, address, uint256, bytes calldata data)
        external
        returns (bytes4)
    {

        return (data.length == 4 && data[0] == 0x8a && data[3] == 0x35)
            ? _ERC721_RECEIVED
            : bytes4(0);
    }

    function _withdraw(uint256 stakeId, bool isEmergency) internal {

        require(
            !isEmergency || emergencyWithdrawEnabled,
            "withdraw: emergency disabled"
        );

        (address nft, uint256 nftId, , ) = decodeStakeId(stakeId);

        UserStakes storage userStakes = stakes[msg.sender];
        Stake memory stake = userStakes.data[stakeId];
        require(
            isEmergency || now >= stake.unlockTime,
            "withdraw: stake is locked"
        );

        uint96 amountDue = stake.amountDue;
        require(amountDue != 0, "withdraw: unknown or returned stake");

        { // Pended airdrop rewards
            uint256 accAir = accAirKingPerNft[nft];
            if (accAir > 1) {
                uint256 bias = accAirKingBias[stakeId];
                if (accAir > bias) amountDue = amountDue.add(
                    SafeMath96.fromUint(accAir.sub(bias))
                );
            }
        }

        uint96 amountToUser = isEmergency ? stake.amountStaked : amountDue;

        _removeUserStake(userStakes, stakeId);
        kingDue = kingDue.sub(amountDue);
        kingReserves = kingReserves.sub(amountDue);

        IERC20(king).safeTransfer(msg.sender, uint256(amountToUser));
        IERC721(nft).safeTransferFrom(address(this), msg.sender, nftId);
    }

    function _addTermSheet(TermSheet memory tS) internal {

        _revertZeroAddress(tS.nft);
        require(
            (tS.minAmount != 0) && (tS.lockHours != 0) && (tS.kingFactor != 0),
            "RDeck::add:INVALID_ZERO_PARAM"
        );
        require(_isMissingTerms(tS), "RDeck::add:TERMS_DUPLICATED");
        termSheets.push(tS);

        emit NewTermSheet(
            termSheets.length - 1,
            tS.nft,
            tS.minAmount,
            tS.lockHours,
            tS.kingFactor
        );
        if (tS.enabled) emit TermsEnabled(termSheets.length);
    }

    function _safeKingTransfer(address _to, uint256 _amount) internal {

        uint256 kingBal = IERC20(king).balanceOf(address(this));
        IERC20(king).safeTransfer(_to, _amount > kingBal ? kingBal : _amount);
    }

    function _isMissingTerms(TermSheet memory newSheet)
        internal
        view
        returns (bool)
    {

        for (uint256 i = 0; i < termSheets.length; i++) {
            TermSheet memory sheet = termSheets[i];
            if (
                sheet.nft == newSheet.nft &&
                sheet.minAmount == newSheet.minAmount &&
                sheet.lockHours == newSheet.lockHours &&
                sheet.kingFactor == newSheet.kingFactor
            ) {
                return false;
            }
        }
        return true;
    }

    function _addUserStake(
        UserStakes storage userStakes,
        uint256 stakeId,
        Stake memory stake
    ) internal {

        require(
            userStakes.data[stakeId].amountDue == 0,
            "RDeck:DUPLICATED_STAKE_ID"
        );
        userStakes.data[stakeId] = stake;
        userStakes.ids.push(stakeId);
    }

    function _removeUserStake(UserStakes storage userStakes, uint256 stakeId)
        internal
    {

        require(
            userStakes.data[stakeId].amountDue != 0,
            "RDeck:INVALID_STAKE_ID"
        );
        userStakes.data[stakeId].amountDue = 0;
        _removeArrayElement(userStakes.ids, stakeId);
    }

    function _removeArrayElement(uint256[] storage arr, uint256 el) internal {

        uint256 lastIndex = arr.length - 1;
        if (lastIndex != 0) {
            uint256 replaced = arr[lastIndex];
            if (replaced != el) {
                do {
                    uint256 replacing = replaced;
                    replaced = arr[lastIndex - 1];
                    lastIndex--;
                    arr[lastIndex] = replacing;
                } while (replaced != el && lastIndex != 0);
            }
        }
        arr.pop();
    }

    function _encodeStakeId(
        address nft,
        uint256 nftId,
        uint256 startTime,
        uint256 stakeHours
    ) internal pure returns (uint256) {

        require(nftId < 2**48, "RDeck::nftId_EXCEEDS_48_BITS");
        return uint256(nft) << 96 | nftId << 48 | startTime << 16 | stakeHours;
    }

    function _packAirPoolData(
        address nft,
        uint8 weight
    ) internal pure returns(uint256) {

        return (uint256(nft) << 8) | uint256(weight);
    }

    function _unpackAirPoolData(
        uint256 packed
    ) internal pure returns(address nft, uint8 weight)
    {

        return (address(packed >> 8), uint8(packed & 7));
    }

    function _revertZeroAddress(address _address) internal pure {

        require(_address != address(0), "RDeck::ZERO_ADDRESS");
    }

    function _nonZeroAddr(address _address) private pure returns (address) {

        _revertZeroAddress(_address);
        return _address;
    }

    function _validTermsID(uint256 termsId) private view returns (uint256) {

        require(termsId < termSheets.length, "RDeck::INVALID_TERMS_ID");
        return termsId;
    }
}