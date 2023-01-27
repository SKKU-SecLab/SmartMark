

pragma solidity 0.7.6;




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
}


interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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


abstract contract ReentrancyGuard {

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
}


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}


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

}


interface IStarNFT is IERC1155 {

    event PowahUpdated(uint256 indexed id, uint256 indexed oldPoints, uint256 indexed newPoints);


    function isOwnerOf(address, uint256) external view returns (bool);

    function starInfo(uint256) external view returns (uint128 powah, uint128 mintBlock, address originator);

    function quasarInfo(uint256) external view returns (uint128 mintBlock, IERC20 stakeToken, uint256 amount, uint256 campaignID);

    function superInfo(uint256) external view returns (uint128 mintBlock, IERC20[] memory stakeToken, uint256[] memory amount, uint256 campaignID);


    function mint(address account, uint256 powah) external returns (uint256);

    function mintBatch(address account, uint256 amount, uint256[] calldata powahArr) external returns (uint256[] memory);

    function burn(address account, uint256 id) external;

    function burnBatch(address account, uint256[] calldata ids) external;


    function mintQuasar(address account, uint256 powah, uint256 cid, IERC20 stakeToken, uint256 amount) external returns (uint256);

    function burnQuasar(address account, uint256 id) external;


    function mintSuper(address account, uint256 powah, uint256 campaignID, IERC20[] calldata stakeTokens, uint256[] calldata amounts) external returns (uint256);

    function burnSuper(address account, uint256 id) external;

    function updatePowah(address owner, uint256 id, uint256 powah) external;

}


contract SpaceStation is ReentrancyGuard {

    using Address for address;
    using SafeMath for uint256;

    event EventClaim(uint256 _cid, address _sender);
    event EventStakeIn(uint256 _cid, address _sender, uint256 _stakeAmount, address _erc20);
    event EventStakeOut(address _starNFT, uint256 _nftID);
    event EventForgeNoStake(uint256 _cid, address _sender, address _starNFT, uint256[] _nftIDs);
    event EventForgeWithStake(uint256 _cid, address _sender, address _starNFT, uint256[] _nftIDs, uint256 _stakeAmount, address _erc20);

    modifier onlyStarNFT(IStarNFT _starNFTAddress)  {

        require(_starNFTs[_starNFTAddress] == true, "Invalid Star NFT contract address");
        _;
    }
    modifier onlyManager() {

        _validateOnlyManager();
        _;
    }
    modifier onlyTreasuryManager() {

        _validateOnlyTreasuryManager();
        _;
    }
    modifier onlyNoPaused() {

        _validateOnlyNotPaused();
        _;
    }


    enum Operation {
        Default,
        Claim,
        StakeIn,
        StakeOut,
        Forge
    }


    struct CampaignStakeConfig {
        address erc20;                  // Address of token being staked
        uint256 minStakeAmount;         // Minimum amount of token to stake required, included
        uint256 maxStakeAmount;         // Maximum amount of token to stake required, included
        uint256 lockBlockNum;           // To indicate when token lock-up period is met
        bool burnRequired;              // Require NFT burnt if staked out
        bool isEarlyStakeOutAllowed;    // Whether early stake out is allowed or not
        uint256 earlyStakeOutFine;      // If early stake out is allowed, the applied penalty
    }

    struct CampaignFeeConfig {
        address erc20;                 // Address of token asset if required
        uint256 erc20Fee;              // Amount of token if required
        uint256 networkFee;            // Amount of fee per network
        bool isActive;                 // Indicate whether this campaign exists and is active
    }


    address public manager;
    address public treasury_manager;

    mapping(uint256 => CampaignStakeConfig) public campaignStakeConfigs;

    mapping(uint256 => mapping(Operation => CampaignFeeConfig)) public campaignFeeConfigs;

    mapping(IStarNFT => bool) private _starNFTs;

    uint256 public galaxyTreasuryNetwork;
    mapping(address => uint256) public galaxyTreasuryERC20;
    bool public initialized;
    bool public paused;



    constructor() {}

    function initialize(address _manager, address _treasury_manager) external {

        require(!initialized, "Contract already initialized");
        if (_manager != address(0)) {
            manager = _manager;
        } else {
            manager = msg.sender;
        }
        if (_treasury_manager != address(0)) {
            treasury_manager = _treasury_manager;
        } else {
            treasury_manager = msg.sender;
        }
        initialized = true;
    }


    function activateCampaign(
        uint256 _cid,
        Operation[] calldata _op,
        uint256[] calldata _networkFee,
        uint256[] calldata _erc20Fee,
        address[] calldata _erc20
    ) external onlyManager {

        _setFees(_cid, _op, _networkFee, _erc20Fee, _erc20);
    }

    function expireCampaign(uint256 _cid, Operation[] calldata _op) external onlyManager {

        require(_op.length > 0, "Array(_op) should not be empty.");
        for (uint256 i = 0; i < _op.length; i++) {
            delete campaignFeeConfigs[_cid][_op[i]];
        }
    }


    function activateStakeCampaign(
        uint256 _cid,
        address _stakeErc20,
        uint256 _minStakeAmount,
        uint256 _maxStakeAmount,
        uint256 _lockBlockNum,
        bytes1 _params,
        uint256 _earlyStakeOutFine,
        Operation[] calldata _op,
        uint256[] calldata _networkFee,
        uint256[] calldata _erc20Fee,
        address[] calldata _erc20
    ) external onlyManager {

        require(_stakeErc20 != address(0), "Stake Token must not be null address");
        require(_minStakeAmount > 0, "Min stake amount should be greater than 0 for stake campaign");
        require(_minStakeAmount <= _maxStakeAmount, "StakeAmount min should less than or equal to max");

        _setFees(_cid, _op, _networkFee, _erc20Fee, _erc20);

        _setStake(_cid, _stakeErc20, _minStakeAmount, _maxStakeAmount, _lockBlockNum, _params, _earlyStakeOutFine);
    }

    function claim(uint256 _cid) external payable onlyNoPaused {

        _payFees(_cid, Operation.Claim);
        emit EventClaim(_cid, msg.sender);
    }

    function stakeIn(uint256 _cid, uint256 stakeAmount) external payable nonReentrant onlyNoPaused {

        _payFees(_cid, Operation.StakeIn);
        _stakeIn(_cid, stakeAmount);
        emit EventStakeIn(_cid, msg.sender, stakeAmount, campaignStakeConfigs[_cid].erc20);
    }

    function stakeOutQuasar(IStarNFT _starNFT, uint256 _nftID) external payable onlyStarNFT(_starNFT) nonReentrant {

        require(_starNFT.isOwnerOf(msg.sender, _nftID), "Must be owner of this Quasar NFT");
        (uint256 _mintBlock, IERC20 _stakeToken, uint256 _amount, uint256 _cid) = _starNFT.quasarInfo(_nftID);
        require(address(_stakeToken) != address(0), "Backing-asset token must not be null address");
        require(_amount > 0, "Backing-asset amount must be greater than 0");
        _payFine(_cid, _mintBlock);
        _payFees(_cid, Operation.StakeOut);
        require(_stakeToken.transfer(msg.sender, _amount), "Stake out transfer assert back failed");
        if (campaignStakeConfigs[_cid].burnRequired) {
            _starNFT.burn(msg.sender, _nftID);
        } else {
            _starNFT.burnQuasar(msg.sender, _nftID);
        }
        emit EventStakeOut(address(_starNFT), _nftID);
    }

    function stakeOutSuper(IStarNFT _starNFT, uint256 _nftID) external payable onlyStarNFT(_starNFT) nonReentrant {

        require(_starNFT.isOwnerOf(msg.sender, _nftID), "Must be owner of this Super NFT");
        (uint256 _mintBlock, IERC20[] memory _stakeToken, uint256[] memory _amount, uint256 _cid) = IStarNFT(_starNFT).superInfo(_nftID);
        require(_stakeToken.length > 0, "Array(_stakeToken) should not be empty.");
        require(_stakeToken.length == _amount.length, "Array(_amount) length mismatch");
        _payFine(_cid, _mintBlock);
        _payFees(_cid, Operation.StakeOut);
        for (uint256 i = 0; i < _stakeToken.length; i++) {
            require(address(_stakeToken[i]) != address(0), "Backing-asset token must not be null address");
            require(_amount[i] > 0, "Backing-asset amount must be greater than 0");
            require(_stakeToken[i].transfer(msg.sender, _amount[i]), "Stake out transfer assert back failed");
        }
        if (campaignStakeConfigs[_cid].burnRequired) {
            _starNFT.burn(msg.sender, _nftID);
        } else {
            _starNFT.burnSuper(msg.sender, _nftID);
        }
        emit EventStakeOut(address(_starNFT), _nftID);
    }

    function forgeNoStake(uint256 _cid, IStarNFT _starNFT, uint256[] calldata _nftIDs) external payable onlyStarNFT(_starNFT) nonReentrant onlyNoPaused {

        for (uint i = 0; i < _nftIDs.length; i++) {
            require(_starNFT.isOwnerOf(msg.sender, _nftIDs[i]), "Not the owner");
        }
        _payFees(_cid, Operation.Forge);
        _starNFT.burnBatch(msg.sender, _nftIDs);
        emit EventForgeNoStake(_cid, msg.sender, address(_starNFT), _nftIDs);
    }

    function forgeStake(uint256 _cid, IStarNFT _starNFT, uint256[] calldata _nftIDs, uint256 stakeAmount) external payable onlyStarNFT(_starNFT) nonReentrant onlyNoPaused {

        for (uint i = 0; i < _nftIDs.length; i++) {
            require(_starNFT.isOwnerOf(msg.sender, _nftIDs[i]), "Not the owner");
        }
        _payFees(_cid, Operation.Forge);
        _stakeIn(_cid, stakeAmount);
        _starNFT.burnBatch(msg.sender, _nftIDs);
        emit EventForgeWithStake(_cid, msg.sender, address(_starNFT), _nftIDs, stakeAmount, campaignStakeConfigs[_cid].erc20);
    }

    receive() external payable {}

    fallback() external payable {}

    function setPause(bool _paused) external onlyManager {

        paused = _paused;
    }

    function addValidatedStarNFTAddress(IStarNFT _starNFT) external onlyManager {

        require(address(_starNFT) != address(0), "Validate StarNFT contract must not be null address");
        _starNFTs[_starNFT] = true;
    }
    function removeValidatedStarNFTAddress(IStarNFT _starNFT) external onlyManager {

        require(address(_starNFT) != address(0), "Invalidate StarNFT contract must not be null address");
        _starNFTs[_starNFT] = false;
    }

    function networkWithdraw() external onlyTreasuryManager {

        uint256 amount = galaxyTreasuryNetwork;
        require(amount > 0, "Treasury of network should be greater than 0");

        galaxyTreasuryNetwork = 0;
        (bool success,) = manager.call{value : amount}("");
        require(success, "Failed to send Ether/BNB fees to treasury manager");
    }

    function erc20Withdraw(address erc20) external onlyTreasuryManager nonReentrant {

        uint256 amount = galaxyTreasuryERC20[erc20];
        require(amount > 0, "Treasury of ERC20 should be greater than 0");

        galaxyTreasuryERC20[erc20] = 0;
        require(IERC20(erc20).transfer(manager, amount), "Failed to send Erc20 fees to treasury manager");
    }

    function emergencyWithdrawQuasar(IStarNFT _starNFT, uint256 _nftID) external onlyStarNFT(_starNFT) nonReentrant {

        require(paused, "Not paused");
        require(_starNFT.isOwnerOf(msg.sender, _nftID), "Must be owner of this Quasar NFT");
        (uint256 _mintBlock, IERC20 _stakeToken, uint256 _amount, uint256 _cid) = _starNFT.quasarInfo(_nftID);
        require(address(_stakeToken) != address(0), "Backing-asset token must not be null address");
        require(_amount > 0, "Backing-asset amount must be greater than 0");
        require(_stakeToken.transfer(msg.sender, _amount), "Stake out transfer assert back failed");
        if (campaignStakeConfigs[_cid].burnRequired) {
            _starNFT.burn(msg.sender, _nftID);
        } else {
            _starNFT.burnQuasar(msg.sender, _nftID);
        }
        emit EventStakeOut(address(_starNFT), _nftID);
    }

    function emergencyWithdrawSuper(IStarNFT _starNFT, uint256 _nftID) external onlyStarNFT(_starNFT) nonReentrant {

        require(paused, "Not paused");
        require(_starNFT.isOwnerOf(msg.sender, _nftID), "Must be owner of this Super NFT");
        (uint256 _mintBlock, IERC20[] memory _stakeToken, uint256[] memory _amount, uint256 _cid) = IStarNFT(_starNFT).superInfo(_nftID);
        require(_stakeToken.length > 0, "Array(_stakeToken) should not be empty.");
        require(_stakeToken.length == _amount.length, "Array(_amount) length mismatch");
        for (uint256 i = 0; i < _stakeToken.length; i++) {
            require(address(_stakeToken[i]) != address(0), "Backing-asset token must not be null address");
            require(_amount[i] > 0, "Backing-asset amount must be greater than 0");
            require(_stakeToken[i].transfer(msg.sender, _amount[i]), "Stake out transfer assert back failed");
        }
        if (campaignStakeConfigs[_cid].burnRequired) {
            _starNFT.burn(msg.sender, _nftID);
        } else {
            _starNFT.burnSuper(msg.sender, _nftID);
        }
        emit EventStakeOut(address(_starNFT), _nftID);
    }


    function stakeOutInfo(IStarNFT _starNFTAddress, uint256 _nft_id) external onlyStarNFT(_starNFTAddress) view returns (
        bool _allowStakeOut,
        uint256 _allowBlock,
        bool _requireBurn,
        uint256 _earlyStakeOutFine,
        uint256 _noFineBlock
    ) {

        (uint256 _createBlock, IERC20 _stakeToken, uint256 _amount, uint256 _cid) = _starNFTAddress.quasarInfo(_nft_id);
        if (address(_stakeToken) == address(0)) {
            return (false, 0, false, 0, 0);
        }
        _requireBurn = campaignStakeConfigs[_cid].burnRequired;
        if (block.number >= campaignStakeConfigs[_cid].lockBlockNum.add(_createBlock)) {
            return (true, 0, _requireBurn, 0, 0);
        }
        _allowBlock = campaignStakeConfigs[_cid].lockBlockNum + _createBlock;
        if (!campaignStakeConfigs[_cid].isEarlyStakeOutAllowed) {
            return (false, _allowBlock, _requireBurn, 0, 0);
        }
        _allowStakeOut = true;
        _noFineBlock = _createBlock + campaignStakeConfigs[_cid].lockBlockNum;
        _earlyStakeOutFine = _noFineBlock
        .sub(block.number)
        .mul(10000)
        .div(campaignStakeConfigs[_cid].lockBlockNum)
        .mul(campaignStakeConfigs[_cid].earlyStakeOutFine)
        .div(10000);
    }

    function superStakeOutInfo(IStarNFT _starNFTAddress, uint256 _nft_id) external onlyStarNFT(_starNFTAddress) view returns (
        bool _allowStakeOut,
        uint256 _allowBlock,
        bool _requireBurn,
        uint256 _earlyStakeOutFine,
        uint256 _noFineBlock
    ) {

        (uint256 _createBlock, IERC20[] memory _stakeToken, , uint256 _cid) = _starNFTAddress.superInfo(_nft_id);
        if (_stakeToken.length == 0) {
            return (false, 0, false, 0, 0);
        }
        _requireBurn = campaignStakeConfigs[_cid].burnRequired;
        if (block.number >= campaignStakeConfigs[_cid].lockBlockNum.add(_createBlock)) {
            return (true, 0, _requireBurn, 0, 0);
        }
        _allowBlock = campaignStakeConfigs[_cid].lockBlockNum + _createBlock;
        if (!campaignStakeConfigs[_cid].isEarlyStakeOutAllowed) {
            return (false, _allowBlock, _requireBurn, 0, 0);
        }
        _allowStakeOut = true;
        _noFineBlock = _createBlock + campaignStakeConfigs[_cid].lockBlockNum;
        _earlyStakeOutFine = _noFineBlock
        .sub(block.number)
        .mul(10000)
        .div(campaignStakeConfigs[_cid].lockBlockNum)
        .mul(campaignStakeConfigs[_cid].earlyStakeOutFine)
        .div(10000);
    }

    function isValidatedStarNFTAddress(IStarNFT _starNFT) external returns (bool) {

        return _starNFTs[_starNFT];
    }


    function _setFees(
        uint256 _cid,
        Operation[] calldata _op,
        uint256[] calldata _networkFee,
        uint256[] calldata _erc20Fee,
        address[] calldata _erc20
    ) private {

        require(_op.length > 0, "Array(_op) should not be empty.");
        require(_op.length == _networkFee.length, "Array(_networkFee) length mismatch");
        require(_op.length == _erc20Fee.length, "Array(_erc20Fee) length mismatch");
        require(_op.length == _erc20.length, "Array(_erc20) length mismatch");

        for (uint256 i = 0; i < _op.length; i++) {
            require((_erc20[i] == address(0) && _erc20Fee[i] == 0) || (_erc20[i] != address(0) && _erc20Fee[i] != 0), "Invalid erc20 fee requirement arguments");
            campaignFeeConfigs[_cid][_op[i]] = CampaignFeeConfig(_erc20[i], _erc20Fee[i], _networkFee[i], true);
        }
    }

    function _setStake(
        uint256 _cid,
        address _erc20,
        uint256 _minStakeAmount,
        uint256 _maxStakeAmount,
        uint256 _lockBlockNum,
        bytes1 _params,
        uint256 _earlyStakeOutFine
    ) private {

        campaignStakeConfigs[_cid] = CampaignStakeConfig(
            _erc20,
            _minStakeAmount,
            _maxStakeAmount,
            _lockBlockNum,
            _params & bytes1(0x80) != 0,
            _params & bytes1(0x40) != 0,
            _earlyStakeOutFine
        );
    }

    function _payFees(uint256 _cid, Operation _op) private {

        require(campaignFeeConfigs[_cid][Operation.Default].isActive, "Operation(DEFAULT) should be activated");

        Operation op_key = campaignFeeConfigs[_cid][_op].isActive ? _op : Operation.Default;
        CampaignFeeConfig memory feeConf = campaignFeeConfigs[_cid][op_key];
        if (feeConf.networkFee > 0) {
            require(msg.value >= feeConf.networkFee, "Invalid msg.value sent for networkFee");
            galaxyTreasuryNetwork = galaxyTreasuryNetwork.add(msg.value);
        }
        if (feeConf.erc20Fee > 0) {
            require(IERC20(feeConf.erc20).transferFrom(msg.sender, address(this), feeConf.erc20Fee), "Transfer erc20_fee failed");
            galaxyTreasuryERC20[feeConf.erc20] = galaxyTreasuryERC20[feeConf.erc20].add(feeConf.erc20Fee);
        }
    }

    function _payFine(uint256 _cid, uint256 _mintBlock) private {

        uint256 lockBlockNum = campaignStakeConfigs[_cid].lockBlockNum;
        if (block.number < _mintBlock + lockBlockNum) {
            if (campaignStakeConfigs[_cid].isEarlyStakeOutAllowed) {
                uint256 _fine = (_mintBlock + lockBlockNum)
                .sub(block.number)
                .mul(10000)
                .div(lockBlockNum)
                .mul(campaignStakeConfigs[_cid].earlyStakeOutFine)
                .div(10000);
                require(msg.value >= campaignFeeConfigs[_cid][Operation.StakeOut].networkFee.add(_fine), "Insufficient fine");
                galaxyTreasuryNetwork = galaxyTreasuryNetwork.add(_fine);
            } else {
                require(0 == 1, "Early stake out not allowed");
            }
        }
    }

    function _stakeIn(uint256 _cid, uint256 stakeAmount) private {

        require(campaignStakeConfigs[_cid].erc20 != address(0), "Stake campaign should be activated");
        require(stakeAmount >= campaignStakeConfigs[_cid].minStakeAmount, "StakeAmount should >= minStakeAmount");
        require(stakeAmount <= campaignStakeConfigs[_cid].maxStakeAmount, "StakeAmount should <= maxStakeAmount");
        require(IERC20(campaignStakeConfigs[_cid].erc20).transferFrom(msg.sender, address(this), stakeAmount), "Stake in erc20 failed");

    }

    function _validateOnlyManager() internal view {

        require(msg.sender == manager, "Only manager can call");
    }

    function _validateOnlyTreasuryManager() internal view {

        require(msg.sender == treasury_manager, "Only treasury manager can call");
    }

    function _validateOnlyNotPaused() internal view {

        require(!paused, "Contract paused");
    }
}