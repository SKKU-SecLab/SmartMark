pragma solidity 0.8.6;

interface IJellyAccessControls {

    function hasAdminRole(address _address) external  view returns (bool);

    function addAdminRole(address _address) external;

    function removeAdminRole(address _address) external;

    function hasMinterRole(address _address) external  view returns (bool);

    function addMinterRole(address _address) external;

    function removeMinterRole(address _address) external;

    function hasOperatorRole(address _address) external  view returns (bool);

    function addOperatorRole(address _address) external;

    function removeOperatorRole(address _address) external;

    function initAccessControls(address _admin) external ;


}pragma solidity 0.8.6;

interface IERC20 {


    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


}pragma solidity 0.8.6;

interface IMerkleList {

    function tokensClaimable(uint256 _index, address _account, uint256 _amount, bytes32[] calldata _merkleProof ) external view returns (bool);

    function tokensClaimable(bytes32 _merkleRoot, uint256 _index, address _account, uint256 _amount, bytes32[] calldata _merkleProof ) external view returns (uint256);

    function currentMerkleURI() external view returns (string memory);


    function initMerkleList(address accessControl) external ;


}pragma solidity 0.8.6;

interface IMasterContract {

    function init(bytes calldata data) external payable;

}pragma solidity 0.8.6;


interface IJellyContract is IMasterContract {


    function TEMPLATE_ID() external view returns(bytes32);

    function TEMPLATE_TYPE() external view returns(uint256);

    function initContract( bytes calldata data ) external;


}pragma solidity ^0.8.0;

interface OZIERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
}pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        OZIERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        OZIERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        OZIERC20 token,
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
        OZIERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        OZIERC20 token,
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

    function _callOptionalReturn(OZIERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}pragma solidity 0.8.6;

library BoringMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {

        require((c = a - b) <= a, "BoringMath: Underflow");
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        require(b == 0 || (c = a * b) / b == a, "BoringMath: Mul Overflow");
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {

        require(b > 0, "BoringMath: Div zero");
        c = a / b;
    }

    function to224(uint256 a) internal pure returns (uint224 c) {

        require(a <= type(uint224).max, "BoringMath: uint224 Overflow");
        c = uint224(a);
    }

    function to128(uint256 a) internal pure returns (uint128 c) {

        require(a <= type(uint128).max, "BoringMath: uint128 Overflow");
        c = uint128(a);
    }

    function to64(uint256 a) internal pure returns (uint64 c) {

        require(a <= type(uint64).max, "BoringMath: uint64 Overflow");
        c = uint64(a);
    }

    function to48(uint256 a) internal pure returns (uint48 c) {

        require(a <= type(uint48).max, "BoringMath: uint48 Overflow");
        c = uint48(a);
    }

    function to32(uint256 a) internal pure returns (uint32 c) {

        require(a <= type(uint32).max, "BoringMath: uint32 Overflow");
        c = uint32(a);
    }

    function to16(uint256 a) internal pure returns (uint16 c) {

        require(a <= type(uint16).max, "BoringMath: uint16 Overflow");
        c = uint16(a);
    }

    function to8(uint256 a) internal pure returns (uint8 c) {

        require(a <= type(uint8).max, "BoringMath: uint8 Overflow");
        c = uint8(a);
    }

}


library BoringMath224 {

    function add(uint224 a, uint224 b) internal pure returns (uint224 c) {

        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint224 a, uint224 b) internal pure returns (uint224 c) {

        require((c = a - b) <= a, "BoringMath: Underflow");
    }
}


library BoringMath128 {

    function add(uint128 a, uint128 b) internal pure returns (uint128 c) {

        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint128 a, uint128 b) internal pure returns (uint128 c) {

        require((c = a - b) <= a, "BoringMath: Underflow");
    }
}

library BoringMath64 {

    function add(uint64 a, uint64 b) internal pure returns (uint64 c) {

        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint64 a, uint64 b) internal pure returns (uint64 c) {

        require((c = a - b) <= a, "BoringMath: Underflow");
    }
}

library BoringMath48 {

    function add(uint48 a, uint48 b) internal pure returns (uint48 c) {

        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint48 a, uint48 b) internal pure returns (uint48 c) {

        require((c = a - b) <= a, "BoringMath: Underflow");
    }
}

library BoringMath32 {

    function add(uint32 a, uint32 b) internal pure returns (uint32 c) {

        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint32 a, uint32 b) internal pure returns (uint32 c) {

        require((c = a - b) <= a, "BoringMath: Underflow");
    }
}

library BoringMath16 {

    function add(uint16 a, uint16 b) internal pure returns (uint16 c) {

        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint16 a, uint16 b) internal pure returns (uint16 c) {

        require((c = a - b) <= a, "BoringMath: Underflow");
    }
}

library BoringMath8 {

    function add(uint8 a, uint8 b) internal pure returns (uint8 c) {

        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint8 a, uint8 b) internal pure returns (uint8 c) {

        require((c = a - b) <= a, "BoringMath: Underflow");
    }
}pragma solidity 0.8.6;
// pragma experimental ABIEncoderV2;


contract Documents {


    struct Document {
        uint32 docIndex;    // Store the document name indexes
        uint64 lastModified; // Timestamp at which document details was last modified
        string data; // data of the document that exist off-chain
    }

    mapping(string => Document) internal _documents;
    mapping(string => uint32) internal _docIndexes;
    string[] _docNames;

    event DocumentRemoved(string indexed _name, string _data);
    event DocumentUpdated(string indexed _name, string _data);

    function _setDocument(string calldata _name, string calldata _data) internal {

        require(bytes(_name).length > 0, "Zero name is not allowed");
        require(bytes(_data).length > 0, "Should not be a empty data");
        if (_documents[_name].lastModified == uint64(0)) {
            _docNames.push(_name);
            _documents[_name].docIndex = uint32(_docNames.length);
        }
        _documents[_name] = Document(_documents[_name].docIndex, uint64(block.timestamp), _data);
        emit DocumentUpdated(_name, _data);
    }


    function _removeDocument(string calldata _name) internal {

        require(_documents[_name].lastModified != uint64(0), "Document should exist");
        uint32 index = _documents[_name].docIndex - 1;
        if (index != _docNames.length - 1) {
            _docNames[index] = _docNames[_docNames.length - 1];
            _documents[_docNames[index]].docIndex = index + 1; 
        }
        _docNames.pop();
        emit DocumentRemoved(_name, _documents[_name].data);
        delete _documents[_name];
    }

    function getDocument(string calldata _name) external view returns (string memory, uint256) {

        return (
            _documents[_name].data,
            uint256(_documents[_name].lastModified)
        );
    }

    function getAllDocuments() external view returns (string[] memory) {

        return _docNames;
    }

    function getDocumentCount() external view returns (uint256) {

        return _docNames.length;
    }

    function getDocumentName(uint256 _index) external view returns (string memory) {

        require(_index < _docNames.length, "Index out of bounds");
        return _docNames[_index];
    }

}pragma solidity 0.8.6;






contract JellyDrop is IJellyContract, Documents {


    using BoringMath128 for uint128;
    using SafeERC20 for OZIERC20;

    uint256 public constant override TEMPLATE_TYPE = 2;
    bytes32 public constant override TEMPLATE_ID = keccak256("JELLY_DROP");
    uint256 private constant MULTIPLIER_PRECISION = 1e18;
    uint256 private constant PERCENTAGE_PRECISION = 10000;
    uint256 private constant TIMESTAMP_PRECISION = 10000000000;

    IJellyAccessControls public accessControls;

    address public list;

    address public rewardsToken;

    uint256 public rewardsPaid;

    uint256 public totalTokens;

    struct UserInfo {
        uint128 totalAmount;
        uint128 rewardsReleased;
    }

    mapping (address => UserInfo) public userRewards;

    struct RewardInfo {
        bool tokensClaimable;
        uint48 startTimestamp;
        uint32 streamDuration;
        uint48 claimExpiry;
        uint128 multiplier;
    }
    RewardInfo public rewardInfo;

    bool private initialised;

    address private jellyVault;

    uint256 private feePercentage;

    event RewardPaid(address indexed user, uint256 reward);

    event ClaimableStatusUpdated(bool status);

    event ClaimExpiryUpdated(uint256 expiry);

    event RewardsTokenUpdated(address indexed oldRewardsToken, address newRewardsToken);

    event RewardsAdded(uint256 amount, uint256 fees);

    event ListUpdated(address indexed oldList, address newList);

    event JellyUpdated(address indexed vault, uint256 fee);

    event JellySet();

    event Recovered(address indexed token, uint256 amount);


    constructor() {
    }
 

    function setList(address _list) external {

        require(accessControls.hasAdminRole(msg.sender));
        require(_list != address(0)); // dev: Address must be non zero
        emit ListUpdated(list, _list);
        list = _list;
    }

    function setTokensClaimable(bool _enabled) external  {

        require(accessControls.hasAdminRole(msg.sender), "setTokensClaimable: Sender must be admin");
        rewardInfo.tokensClaimable = _enabled;
        emit ClaimableStatusUpdated(_enabled);
    }

    function setClaimExpiry(uint256 _expiry) external  {

        require(accessControls.hasAdminRole(msg.sender), "setClaimExpiry: Sender must be admin");
        require(_expiry < TIMESTAMP_PRECISION, "setClaimExpiry: enter claim expiry unix timestamp in seconds, not miliseconds");
        require((rewardInfo.startTimestamp < _expiry && _expiry > block.timestamp )|| _expiry == 0, "setClaimExpiry: claim expiry incorrect");
        rewardInfo.claimExpiry =  BoringMath.to48(_expiry);
        emit ClaimExpiryUpdated(_expiry);
    }

    function addRewards(uint256 _rewardAmount) public {

        require(accessControls.hasAdminRole(msg.sender));
        OZIERC20(rewardsToken).safeTransferFrom(msg.sender, address(this), _rewardAmount);
        uint256 tokensAdded = _rewardAmount * PERCENTAGE_PRECISION  / uint256(feePercentage + PERCENTAGE_PRECISION);
        uint256 jellyFee =  _rewardAmount * uint256(feePercentage)  / uint256(feePercentage + PERCENTAGE_PRECISION);
        totalTokens += tokensAdded ;
        OZIERC20(rewardsToken).safeTransfer(jellyVault, jellyFee);
        emit RewardsAdded(_rewardAmount, jellyFee);
    }

    function updateJelly(address _vault, uint256 _fee) external  {

        require(jellyVault == msg.sender); // dev: updateJelly: Sender must be JellyVault
        require(_vault != address(0)); // dev: Address must be non zero
        require(_fee < PERCENTAGE_PRECISION); // dev: feePercentage greater than 10000 (100.00%)

        jellyVault = _vault;
        feePercentage = _fee;
        emit JellyUpdated(_vault, _fee);
    }

    function setJellyCustom(uint256 _startTimestamp, uint256 _streamDuration,  bool _tokensClaimable) public  {

        require(accessControls.hasAdminRole(msg.sender), "setJelly: Sender must be admin");
        require(_startTimestamp < TIMESTAMP_PRECISION, "setJelly: enter start unix timestamp in seconds, not miliseconds");

        rewardInfo.tokensClaimable = _tokensClaimable;
        rewardInfo.startTimestamp = BoringMath.to48(_startTimestamp);
        rewardInfo.streamDuration = BoringMath.to32(_streamDuration);
        rewardInfo.multiplier = BoringMath.to128(MULTIPLIER_PRECISION);
        emit JellySet();
    }

    function setJellyAirdrop() external  {

        setJellyCustom(block.timestamp, 0, false);
    }

    function setJellyAirdrip(uint256 _streamDuration) external  {

        setJellyCustom(block.timestamp, _streamDuration, false);
    }



    function tokensClaimable() external view returns (bool)  {

        return rewardInfo.tokensClaimable;
    }

    function startTimestamp() external view returns (uint256)  {

        return uint256(rewardInfo.startTimestamp);
    }

    function streamDuration() external view returns (uint256)  {

        return uint256(rewardInfo.streamDuration);
    }

    function claimExpiry() external view returns (uint256)  {

        return uint256(rewardInfo.claimExpiry);
    }

    function calculateRewards(uint256 _newTotalAmount) external view returns (uint256)  {

        if (_newTotalAmount <= totalTokens) return 0;
        uint256 newTokens = _newTotalAmount - totalTokens;
        uint256 fee = newTokens * uint256(feePercentage) / PERCENTAGE_PRECISION;
        return newTokens + fee;
    }


    function claim(bytes32 _merkleRoot, uint256 _index, address _user, uint256 _amount, bytes32[] calldata _data ) public {


        UserInfo storage _userRewards =  userRewards[_user];

        require(_amount > 0, "Token amount must be greater than 0");
        require(_amount > uint256(_userRewards.rewardsReleased), "Amount must exceed tokens already claimed");

        if (_amount > uint256(_userRewards.totalAmount)) {
            uint256 merkleAmount = IMerkleList(list).tokensClaimable(_merkleRoot, _index, _user, _amount, _data );
            require(merkleAmount > 0, "Incorrect merkle proof for amount.");
            _userRewards.totalAmount = BoringMath.to128(_amount);
        }

        _claimTokens(_user);
    }

    function verifiedClaim(address _user) public {

        _claimTokens(_user);
    }

    function _claimTokens(address _user) internal {

        UserInfo storage _userRewards =  userRewards[_user];

        require(
            rewardInfo.tokensClaimable == true,
            "Tokens cannnot be claimed yet"
        );

        uint256 payableAmount = _earnedAmount(
            uint256(_userRewards.totalAmount),
            uint256(_userRewards.rewardsReleased)
        );
        require(payableAmount > 0, "No tokens available to claim");
        uint256 rewardBal =  IERC20(rewardsToken).balanceOf(address(this));
        require(rewardBal > 0, "Airdrop has no tokens remaining");

        if (payableAmount > rewardBal) {
            payableAmount = rewardBal;
        }

        _userRewards.rewardsReleased +=  BoringMath.to128(payableAmount);
        rewardsPaid +=  payableAmount;
        require(rewardsPaid <= totalTokens, "Amount claimed exceeds total tokens");

        OZIERC20(rewardsToken).safeTransfer(_user, payableAmount);

        emit RewardPaid(_user, payableAmount);
    }

    function earnedAmount(address _user) external view returns (uint256) {

        return
            _earnedAmount(
                userRewards[_user].totalAmount,
                userRewards[_user].rewardsReleased
            );
    }

    function _earnedAmount(
        uint256 total,
        uint256 released

    ) internal view returns (uint256) {

        if (total <= released ) {
            return 0;
        }

        RewardInfo memory _rewardInfo = rewardInfo;

        if (block.timestamp <= uint256(_rewardInfo.startTimestamp) || _rewardInfo.tokensClaimable == false) {
            return 0;
        }

        uint256 expiry = uint256(_rewardInfo.claimExpiry);
        if (expiry > 0 && block.timestamp > expiry  ) {
            return 0;
        }

        uint256 elapsedTime = block.timestamp - uint256(_rewardInfo.startTimestamp);
        uint256 earned;
        if (elapsedTime >= uint256(_rewardInfo.streamDuration)) {
            earned = total;
        } else {
            earned = (total * elapsedTime) / uint256(_rewardInfo.streamDuration);
        }
    
        return earned - released;
    }



    function adminReclaimTokens(
        address _tokenAddress,
        address _vault
    )
        external
    {

        require(
            accessControls.hasAdminRole(msg.sender),
            "recoverERC20: Sender must be admin"
        );
        require(_vault != address(0)); // dev: Address must be non zero

        uint256 tokenAmount =  IERC20(_tokenAddress).balanceOf(address(this));
        if (_tokenAddress == rewardsToken) {
            require(
                rewardInfo.claimExpiry > 0 && block.timestamp > rewardInfo.claimExpiry,
                "recoverERC20: Airdrop not yet expired"
            );
            totalTokens = rewardsPaid;
            rewardInfo.tokensClaimable = false;
        }
        OZIERC20(_tokenAddress).safeTransfer(_vault, tokenAmount);
        emit Recovered(_tokenAddress, tokenAmount);
    }



    function setDocument(string calldata _name, string calldata _data) external {

        require(accessControls.hasAdminRole(msg.sender) );
        _setDocument( _name, _data);
    }

    function setDocuments(string[] calldata _name, string[] calldata _data) external {

        require(accessControls.hasAdminRole(msg.sender) );
        uint256 numDocs = _name.length;
        for (uint256 i = 0; i < numDocs; i++) {
            _setDocument( _name[i], _data[i]);
        }
    }

    function removeDocument(string calldata _name) external {

        require(accessControls.hasAdminRole(msg.sender));
        _removeDocument(_name);
    }



    function initJellyAirdrop(
        address _accessControls,
        address _rewardsToken,
        uint256 _rewardAmount,
        address _list,
        address _jellyVault,
        uint256 _jellyFee
    ) public 
    {

        require(!initialised, "Already initialised");
        require(_list != address(0), "List address not set");
        require(_jellyVault != address(0), "jellyVault not set");
        require(_jellyFee < PERCENTAGE_PRECISION , "feePercentage greater than 10000 (100.00%)");
        require(_accessControls != address(0), "Access controls not set");

        rewardsToken = _rewardsToken;
        jellyVault = _jellyVault;
        feePercentage = _jellyFee;
        totalTokens = _rewardAmount;
        if (_rewardAmount > 0) {
            uint256 jellyFee = _rewardAmount * uint256(feePercentage) / PERCENTAGE_PRECISION;
            OZIERC20(_rewardsToken).safeTransferFrom(msg.sender, address(this), _rewardAmount + jellyFee);
            OZIERC20(_rewardsToken).safeTransfer(_jellyVault, jellyFee);
        }
        accessControls = IJellyAccessControls(_accessControls);
        list = _list;
        initialised = true;
    }

    function init(bytes calldata _data) external override payable {}


    function initContract(
        bytes calldata _data
    ) public override {

        (
        address _accessControls,
        address _rewardsToken,
        uint256 _rewardAmount,
        address _list,
        address _jellyVault,
        uint256 _jellyFee
        ) = abi.decode(_data, (address, address,uint256, address,address,uint256));

        initJellyAirdrop(
                        _accessControls,
                        _rewardsToken,
                        _rewardAmount,
                        _list,
                        _jellyVault,
                        _jellyFee
                    );
    }

    function getInitData(
        address _accessControls,
        address _rewardsToken,
        uint256 _rewardAmount,
        address _list,
        address _jellyVault,
        uint256 _jellyFee
    )
        external
        pure
        returns (bytes memory _data)
    {

        return abi.encode(
                        _rewardsToken,
                        _accessControls,
                        _rewardAmount,
                        _list,
                        _jellyVault,
                        _jellyFee
                        );
    }


}