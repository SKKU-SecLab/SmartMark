
pragma solidity >=0.8.4 <0.9.0;

interface IRegistry {

    function registerNewContract(bytes32 _cid, address _payer, address _payee) external;

    function escrowContracts(address _addr) external returns (bool);

    function insuranceManager() external returns (address);

}// MPL-2.0

pragma solidity >=0.8.4 <0.9.0;

library EscrowUtilsLib {

    struct MilestoneParams {
        address paymentToken;
        address treasury;
        address payeeAccount;
        address refundAccount;
        address escrowDisputeManager;
        uint autoReleasedAt;
        uint amount;
        uint16 parentIndex;
    }
    
    struct Contract {
        address payer;
        address payerDelegate;
        address payee;
        address payeeDelegate;
    }

    function genMid(bytes32 _cid, uint16 _index) internal pure returns(bytes32) {

        return keccak256(abi.encode(_cid, _index));
    }

    function genTermsKey(bytes32 _cid, bytes32 _termsCid) internal pure returns(bytes32) {

        return keccak256(abi.encode(_cid, _termsCid));
    }

    function genSettlementKey(bytes32 _cid, uint16 _index, uint8 _revision) internal pure returns(bytes32) {

        return keccak256(abi.encode(_cid, _index, _revision));
    }
}// MPL-2.0

pragma solidity >=0.8.4 <0.9.0;


abstract contract ContractContext {
    mapping (bytes32 => EscrowUtilsLib.Contract) public contracts;

    event ApprovedContractVersion(
        bytes32 indexed cid,
        bytes32 indexed approvedCid,
        bytes32 indexed key
    );
}// MPL-2.0

pragma solidity >=0.8.4 <0.9.0;


abstract contract EscrowContract is ContractContext {
    string private constant ERROR_CONTRACT_EXITS = "Contract exists";
    string private constant ERROR_EMPTY_DELEGATE = "Invalid delegate";

    address private constant EMPTY_ADDRESS = address(0);

    IRegistry public immutable TRUSTED_REGISTRY;

    event NewContractPayer(
        bytes32 indexed cid,
        address indexed payer,
        address indexed delegate
    );

    event NewContractPayee(
        bytes32 indexed cid,
        address indexed payee,
        address indexed delegate
    );

    constructor(address _registry) {
        TRUSTED_REGISTRY = IRegistry(_registry);
    }

    function _registerContract(
        bytes32 _cid,
        address _payer,
        address _payerDelegate,
        address _payee,
        address _payeeDelegate
    ) internal {
        require(contracts[_cid].payer == EMPTY_ADDRESS, ERROR_CONTRACT_EXITS);

        if (_payerDelegate == EMPTY_ADDRESS) _payerDelegate = _payer;
        if (_payerDelegate == EMPTY_ADDRESS) _payeeDelegate = _payee;
        contracts[_cid] = EscrowUtilsLib.Contract({
            payer: _payer,
            payerDelegate: _payerDelegate,
            payee: _payee,
            payeeDelegate: _payeeDelegate
        });
        emit NewContractPayer(_cid, _payer, _payerDelegate);
        emit NewContractPayee(_cid, _payee, _payeeDelegate);

        TRUSTED_REGISTRY.registerNewContract(_cid, _payer, _payee);
    }

    function changeDelegate(bytes32 _cid, address _newDelegate) external {
        require(_newDelegate != EMPTY_ADDRESS, ERROR_EMPTY_DELEGATE);
        if (contracts[_cid].payer == msg.sender) {
            contracts[_cid].payerDelegate = _newDelegate;
        } else if (contracts[_cid].payee == msg.sender) {
            contracts[_cid].payeeDelegate = _newDelegate;
        } else {
            revert();
        }
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

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MPL-2.0

pragma solidity >=0.8.4 <0.9.0;

interface IEscrowDisputeManager {

    function proposeSettlement(
        bytes32 _cid,
        uint16 _index,
        address _plaintiff,
        address _payer,
        address _payee,
        uint _refundedPercent,
        uint _releasedPercent,
        bytes32 _statement
    ) external;


    function acceptSettlement(bytes32 _cid, uint16 _index, uint256 _ruling) external;


    function disputeSettlement(
        address _feePayer,
        bytes32 _cid,
        uint16 _index,
        bytes32 _termsCid,
        bool _ignoreCoverage,
        bool _multiMilestone
    ) external;


    function executeSettlement(bytes32 _cid, uint16 _index, bytes32 _mid) external returns(uint256, uint256, uint256);

    function getSettlementByRuling(bytes32 _mid, uint256 _ruling) external returns(uint256, uint256, uint256); 


    function submitEvidence(address _from, string memory _label, bytes32 _cid, uint16 _index, bytes calldata _evidence) external;

    function ruleDispute(bytes32 _cid, uint16 _index, bytes32 _mid) external returns(uint256);

    
    function resolutions(bytes32 _mid) external view returns(uint256);

    function hasSettlementDispute(bytes32 _mid) external view returns(bool);

    function ARBITER() external view returns(address);

}// MPL-2.0

pragma solidity >=0.8.4 <0.9.0;


abstract contract MilestoneContext {
    struct Milestone {
        IERC20 paymentToken;
        address treasury;
        address payeeAccount;
        address refundAccount;
        IEscrowDisputeManager escrowDisputeManager;
        uint256 autoReleasedAt;
        uint256 amount;
        uint256 fundedAmount;
        uint256 refundedAmount;
        uint256 releasedAmount;
        uint256 claimedAmount;
        uint8 revision;
    }

    mapping (bytes32 => Milestone) public milestones;
    mapping (bytes32 => uint16) public lastMilestoneIndex;

    using EscrowUtilsLib for bytes32;

    event NewMilestone(
        bytes32 indexed cid,
        uint16 indexed index,
        bytes32 mid,
        address indexed paymentToken,
        address escrowDisputeManager,
        uint256 autoReleasedAt,
        uint256 amount
    );

    event ChildMilestone(
        bytes32 indexed cid,
        uint16 indexed index,
        uint16 indexed parentIndex,
        bytes32 mid
    );

    event FundedMilestone(
        bytes32 indexed mid,
        address indexed funder,
        uint256 indexed amount
    );

    event ReleasedMilestone(
        bytes32 indexed mid,
        address indexed releaser,
        uint256 indexed amount
    );

    event CanceledMilestone(
        bytes32 indexed mid,
        address indexed releaser,
        uint256 indexed amount
    );

    event WithdrawnMilestone(
        bytes32 indexed mid,
        address indexed recipient,
        uint256 indexed amount
    );

    event RefundedMilestone(
        bytes32 indexed mid,
        address indexed recipient,
        uint256 indexed amount
    );
}// MPL-2.0

pragma solidity >=0.8.4 <0.9.0;

interface ITreasury {

    function registerClaim(bytes32 _termsCid, address _fromAccount, address _toAccount, address _token, uint _amount) external returns(bool);

    function requestWithdraw(bytes32 _termsCid, address _toAccount, address _token, uint _amount) external returns(bool);

}// MPL-2.0

pragma solidity >=0.8.4 <0.9.0;


abstract contract WithMilestones is ContractContext, MilestoneContext, ReentrancyGuard {
    using SafeERC20 for IERC20;

    string private constant ERROR_MILESTONE_EXITS = "Milestone exists";
    string private constant ERROR_FUNDING = "Funding failed";
    string private constant ERROR_FUNDED = "Funding not needed";
    string private constant ERROR_RELEASED = "Invalid release amount";
    string private constant ERROR_NOT_DISPUTER = "Not a party";
    string private constant ERROR_NOT_VALIDATOR = "Not a validator";
    string private constant ERROR_NO_MONEY = "Nothing to withdraw";

    uint16 internal constant MILESTONE_INDEX_BASE = 100;

    uint256 private constant EMPTY_INT = 0;

    function releaseMilestone(bytes32 _cid, uint16 _index, uint _amountToRelease) public {
        require(msg.sender == contracts[_cid].payerDelegate || msg.sender == contracts[_cid].payer, ERROR_NOT_VALIDATOR);

        bytes32 _mid = EscrowUtilsLib.genMid(_cid, _index);
        Milestone memory _m = milestones[_mid];
        uint _releasedAmount = _m.releasedAmount + _amountToRelease;
        require(_amountToRelease > 0 && _m.amount >= _releasedAmount, ERROR_RELEASED);

        _releaseMilestone(_mid, _releasedAmount, _amountToRelease, msg.sender);
    }

    function cancelMilestone(bytes32 _cid, uint16 _index, uint _amountToRefund) public {
        require(msg.sender == contracts[_cid].payeeDelegate || msg.sender == contracts[_cid].payee, ERROR_NOT_VALIDATOR);

        bytes32 _mid = EscrowUtilsLib.genMid(_cid, _index);
        require(_amountToRefund > 0 && milestones[_mid].fundedAmount >= milestones[_mid].claimedAmount + _amountToRefund, ERROR_RELEASED);

        uint _refundedAmount = milestones[_mid].refundedAmount + _amountToRefund;
        _cancelMilestone(_mid, _refundedAmount, _amountToRefund, msg.sender);
    }

    function withdrawMilestone(bytes32 _cid, uint16 _index) public nonReentrant {
        bytes32 _mid = EscrowUtilsLib.genMid(_cid, _index);
        Milestone memory _m = milestones[_mid];
        milestones[_mid].releasedAmount = 0;

        uint _withdrawn;
        uint _toWithdraw;
        uint _inEscrow = _m.fundedAmount - _m.claimedAmount;
        if (_m.releasedAmount == 0 && _inEscrow > 0 && isAutoReleaseAvailable(_mid, _m.escrowDisputeManager, _m.autoReleasedAt)) {
            _toWithdraw = _inEscrow;
            _releaseMilestone(_mid, _toWithdraw, _toWithdraw, msg.sender);
        } else {
            _toWithdraw = _m.releasedAmount;
        }
        _withdrawn = _withdrawMilestone(_cid, _mid, _m, _m.payeeAccount, _toWithdraw);
        emit WithdrawnMilestone(_mid, _m.payeeAccount, _withdrawn); 
    }

    function refundMilestone(bytes32 _cid, uint16 _index) public nonReentrant {
        bytes32 _mid = EscrowUtilsLib.genMid(_cid, _index);
        Milestone memory _m = milestones[_mid];
        milestones[_mid].refundedAmount = 0;
        uint _withdrawn = _withdrawMilestone(_cid, _mid, _m, _m.refundAccount, _m.refundedAmount);
        emit RefundedMilestone(_mid, _m.refundAccount, _withdrawn); 
    }

    function _registerMilestone(
        bytes32 _cid,
        uint16 _index,
        address _paymentToken,
        address _treasury,
        address _payeeAccount,
        address _refundAccount,
        address _escrowDisputeManager,
        uint256 _autoReleasedAt,
        uint256 _amount
    ) internal {
        bool _isPayer = msg.sender == contracts[_cid].payer;
        require(msg.sender == contracts[_cid].payee || _isPayer, ERROR_NOT_DISPUTER);

        bytes32 _mid = EscrowUtilsLib.genMid(_cid, _index);
        require(milestones[_mid].amount == 0, ERROR_MILESTONE_EXITS);
        _registerMilestoneStorage(
            _mid,
            _paymentToken,
            _treasury,
            _payeeAccount,
            _refundAccount,
            _escrowDisputeManager,
            _autoReleasedAt,
            _amount
        );
        emit NewMilestone(_cid, _index, _mid, _paymentToken, _escrowDisputeManager, _autoReleasedAt, _amount);
        if (_index > MILESTONE_INDEX_BASE) {
            emit ChildMilestone(_cid, _index, _index / MILESTONE_INDEX_BASE, _mid);
        }
    }

    function _registerMilestoneStorage(
        bytes32 _mid,
        address _paymentToken,
        address _treasury,
        address _payeeAccount,
        address _refundAccount,
        address _escrowDisputeManager,
        uint256 _autoReleasedAt,
        uint256 _amount
    ) internal {
        milestones[_mid] = Milestone({
            paymentToken: IERC20(_paymentToken),
            treasury: _treasury,
            payeeAccount: _payeeAccount,
            escrowDisputeManager: IEscrowDisputeManager(_escrowDisputeManager),
            refundAccount: _refundAccount,
            autoReleasedAt: _autoReleasedAt,
            amount: _amount,
            fundedAmount: 0,
            releasedAmount: 0,
            refundedAmount: 0,
            claimedAmount: 0,
            revision: 0
        });
    }

    function _fundMilestone(bytes32 _cid, uint16 _index, uint _amountToFund) internal returns(bool) {
        bytes32 _mid = EscrowUtilsLib.genMid(_cid, _index);
        Milestone memory _m = milestones[_mid];
        uint _fundedAmount = _m.fundedAmount;
        require(_amountToFund > 0 && _m.amount >= (_fundedAmount + _amountToFund), ERROR_FUNDED);
        _m.paymentToken.safeTransferFrom(msg.sender, address(this), _amountToFund);

        if (_m.treasury != address(this)) {
            _m.paymentToken.safeApprove(_m.treasury, _amountToFund);
            require(ITreasury(_m.treasury).registerClaim(
                _cid,
                _m.refundAccount,
                _m.payeeAccount,
                address(_m.paymentToken),
                _amountToFund
            ), ERROR_FUNDING);
        }
        milestones[_mid].fundedAmount += _amountToFund;
        emit FundedMilestone(_mid, msg.sender, _amountToFund);
        return true;
    }

    function _releaseMilestone(bytes32 _mid, uint _totalReleased, uint _amountToRelease, address _releaser) internal {
        milestones[_mid].releasedAmount = _totalReleased;
        emit ReleasedMilestone(_mid, _releaser, _amountToRelease);
    }

    function _cancelMilestone(bytes32 _mid, uint _totalRefunded, uint _amountToRefund, address _refunder) internal {
        milestones[_mid].refundedAmount = _totalRefunded;
        emit CanceledMilestone(_mid, _refunder, _amountToRefund);
    }

    function _withdrawMilestone(bytes32 _cid, bytes32 _mid, Milestone memory _m, address _account, uint _withdrawAmount) internal returns(uint) {
        uint _leftAmount = _m.fundedAmount - _m.claimedAmount;
        if (_leftAmount < _withdrawAmount) _withdrawAmount = _leftAmount;
        require(_withdrawAmount > 0, ERROR_NO_MONEY);

        milestones[_mid].claimedAmount = _m.claimedAmount + _withdrawAmount;
        if (_m.treasury == address(this)) {
            _m.paymentToken.safeTransfer(_account, _withdrawAmount);
        } else {
            require(ITreasury(_m.treasury).requestWithdraw(
                _cid,
                _account,
                address(_m.paymentToken),
                _withdrawAmount
            ), ERROR_FUNDING);
        }
        return _withdrawAmount;
    }

    function isAutoReleaseAvailable(
        bytes32 _mid,
        IEscrowDisputeManager _escrowDisputeManager,
        uint _autoReleasedAt
    ) public view returns (bool) {
        return _autoReleasedAt > 0 && block.timestamp > _autoReleasedAt
            && !_escrowDisputeManager.hasSettlementDispute(_mid)
            && _escrowDisputeManager.resolutions(_mid) == EMPTY_INT;
    }
}// MPL-2.0

pragma solidity >=0.8.4 <0.9.0;

library EIP712 {

    function _isValidEIP712Signature(
        address _validator,
        bytes4 _success,
        bytes memory _encodedChallenge,
        bytes calldata _signature
    ) internal pure returns (bytes4) {

        uint8 _v;
        bytes32 _r;
        bytes32 _s;
        (_v, _r, _s) = abi.decode(_signature, (uint8, bytes32, bytes32));
        bytes32 _hash = keccak256(_encodedChallenge);
        address _signer =
            ecrecover(
                keccak256(
                    abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)
                ),
                _v,
                _r,
                _s
            );

        if (_validator == _signer) {
            return _success;
        } else {
            return bytes4(0);
        }
    }
}// MPL-2.0

pragma solidity >=0.8.4 <0.9.0;


abstract contract WithPreSignedMilestones is WithMilestones {
    using EIP712 for address;

    string private constant ERROR_INVALID_SIGNATURE = "Invalid signature";
    string private constant ERROR_RELEASED = "Invalid release amount";

    bytes4 private constant MAGICVALUE = 0x8a9db909;
    bytes4 private constant SIGNED_CONTRACT_MAGICVALUE = 0xda041b1b;

    bytes32 internal constant MILESTONE_DOMAIN_TYPE_HASH = 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;

    bytes32 internal constant MILESTONE_RELEASE_DOMAIN_NAME = 0xf7a7a250652776e79083ebf7548d7f678c46dd027033d24129ec9e00e571ea9b;
    bytes32 internal constant MILESTONE_REFUND_DOMAIN_NAME = 0x5dac513728b4cea6b6904b8f3b5f9c178f0cf83a3ecf4e94ad498e7cc75192ec;
    bytes32 internal constant SIGNED_CONTRACT_DOMAIN_NAME = 0x288d28d1a9a71cba45c3234f023dd66e1f027ac6e031e2d93e302aea3277fb64;

    bytes32 internal constant DOMAIN_VERSION = 0x0984d5efd47d99151ae1be065a709e56c602102f24c1abc4008eb3f815a8d217;

    bytes32 public immutable MILESTONE_RELEASE_DOMAIN_SEPARATOR;
    bytes32 public immutable MILESTONE_REFUND_DOMAIN_SEPARATOR;
    bytes32 public immutable SIGNED_CONTRACT_DOMAIN_SEPARATOR;

    constructor() {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }

        MILESTONE_RELEASE_DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                MILESTONE_DOMAIN_TYPE_HASH,
                MILESTONE_RELEASE_DOMAIN_NAME,
                DOMAIN_VERSION,
                chainId,
                address(this)
            )
        );

        MILESTONE_REFUND_DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                MILESTONE_DOMAIN_TYPE_HASH,
                MILESTONE_REFUND_DOMAIN_NAME,
                DOMAIN_VERSION,
                chainId,
                address(this)
            )
        );

        SIGNED_CONTRACT_DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                MILESTONE_DOMAIN_TYPE_HASH,
                SIGNED_CONTRACT_DOMAIN_NAME,
                DOMAIN_VERSION,
                chainId,
                address(this)
            )
        );
    }

    function getMilestoneReleaseDomainSeparator() public virtual view returns(bytes32) {
        return MILESTONE_RELEASE_DOMAIN_SEPARATOR;
    }

    function getMilestoneRefundDomainSeparator() public virtual view returns(bytes32) {
        return MILESTONE_REFUND_DOMAIN_SEPARATOR;
    }

    function getSignedContractDomainSeparator() public virtual view returns(bytes32) {
        return SIGNED_CONTRACT_DOMAIN_SEPARATOR;
    }

    function withdrawPreApprovedMilestone(
        bytes32 _cid,
        uint16 _index,
        uint _amount,
        bytes calldata _payerDelegateSignature
    ) public nonReentrant {
        address _payerDelegate = contracts[_cid].payerDelegate;
        bytes32 _mid = EscrowUtilsLib.genMid(_cid, _index);
        Milestone memory _m = milestones[_mid];
        require(_m.amount == _amount, ERROR_RELEASED);
        require(_amount > 0 && _m.fundedAmount >= _m.claimedAmount + _amount, ERROR_RELEASED);
        require(_isPreApprovedMilestoneRelease(
            _cid,
            _index,
            _amount,
            _payerDelegate,
            getMilestoneReleaseDomainSeparator(),
            _payerDelegateSignature
        ) == MAGICVALUE, ERROR_INVALID_SIGNATURE);
        
        _m.releasedAmount += _amount;
        _releaseMilestone(_mid, _m.releasedAmount, _amount, _payerDelegate);

        milestones[_mid].releasedAmount = 0;
        uint _withdrawn = _withdrawMilestone(_cid, _mid, _m, _m.payeeAccount, _m.releasedAmount);
        emit WithdrawnMilestone(_mid, _m.payeeAccount, _withdrawn); 
    }

    function refundPreApprovedMilestone(
        bytes32 _cid,
        uint16 _index,
        uint _amount,
        bytes calldata _payeeDelegateSignature
    ) public nonReentrant {
        address _payeeDelegate = contracts[_cid].payeeDelegate;
        bytes32 _mid = EscrowUtilsLib.genMid(_cid, _index);
        Milestone memory _m = milestones[_mid];
        require(_m.amount == _amount, ERROR_RELEASED);
        require(_amount > 0 && _m.fundedAmount >= _m.claimedAmount + _amount, ERROR_RELEASED);
        require(_isPreApprovedMilestoneRelease(
            _cid,
            _index,
            _amount,
            _payeeDelegate,
            getMilestoneRefundDomainSeparator(),
            _payeeDelegateSignature
        ) == MAGICVALUE, ERROR_INVALID_SIGNATURE);
        
        _m.refundedAmount += _amount;
        _cancelMilestone(_mid, _m.refundedAmount, _amount, _payeeDelegate);

        milestones[_mid].refundedAmount = 0;
        uint _withdrawn = _withdrawMilestone(_cid, _mid, _m, _m.refundAccount, _m.refundedAmount);
        emit RefundedMilestone(_mid, _m.refundAccount, _withdrawn);
    }

    function _signAndFundMilestone(
        bytes32 _cid,
        uint16 _index,
        bytes32 _termsCid,
        uint _amountToFund,
        bytes calldata _payeeSignature,
        bytes calldata _payerSignature
    ) internal {
        address _payer = contracts[_cid].payer;
        require(msg.sender == _payer || _isSignedContractTerms(
            _cid,
            _termsCid,
            _payer,
            getSignedContractDomainSeparator(),
            _payerSignature
        ) == SIGNED_CONTRACT_MAGICVALUE, ERROR_INVALID_SIGNATURE);
        require(_isSignedContractTerms(
            _cid,
            _termsCid,
            contracts[_cid].payee,
            getSignedContractDomainSeparator(),
            _payeeSignature
        ) == SIGNED_CONTRACT_MAGICVALUE, ERROR_INVALID_SIGNATURE);

        _fundMilestone(_cid, _index, _amountToFund);
    }

    function _isPreApprovedMilestoneRelease(
        bytes32 _cid,
        uint16 _index,
        uint256 _amount,
        address _validator,
        bytes32 _domain,
        bytes calldata _callData
    ) internal pure returns (bytes4) {
        return EIP712._isValidEIP712Signature(
            _validator,
            MAGICVALUE,
            abi.encode(_domain, _cid, _index, _amount),
            _callData
        );
    }

    function _isSignedContractTerms(
        bytes32 _cid,
        bytes32 _termsCid,
        address _validator,
        bytes32 _domain,
        bytes calldata _callData
    ) internal pure returns (bytes4) {
        return EIP712._isValidEIP712Signature(
            _validator,
            SIGNED_CONTRACT_MAGICVALUE,
            abi.encode(_domain, _cid, _termsCid),
            _callData
        );
    }
}// MPL-2.0

pragma solidity >=0.8.4 <0.9.0;


abstract contract Amendable is ContractContext, MilestoneContext {
    string private constant ERROR_NOT_PARTY = "Not a payer or payee";
    string private constant ERROR_EMPTY = "Empty amendment";
    string private constant ERROR_AMENDMENT_EXIST = "Amendment exist";
    string private constant ERROR_NOT_VALIDATOR = "Not a validator";
    string private constant ERROR_EARLIER_AMENDMENT = "Not final amendment";
    string private constant ERROR_OVERFUNDED = "Overfunded milestone";

    bytes32 private constant EMPTY_BYTES32 = bytes32(0);
    address private constant EMPTY_ADDRESS = address(0);

    struct Amendment{
        bytes32 cid;
        uint256 timestamp;
    }

    struct AmendmentProposal {
        bytes32 termsCid;
        address validator;
        uint256 timestamp;
    }

    struct SettlementParams {
        bytes32 termsCid;
        address payeeAccount;
        address refundAccount;
        address escrowDisputeManager;
        uint autoReleasedAt;
        uint amount;
        uint refundedAmount;
        uint releasedAmount;
    }

    struct SettlementProposal {
        SettlementParams params;
        address validator;
        uint256 timestamp;
    }

    mapping (bytes32 => Amendment) public contractVersions;
    mapping (bytes32 => bool) public contractVersionApprovals;
    mapping (bytes32 => AmendmentProposal) public contractVersionProposals;
    mapping (bytes32 => SettlementProposal) public settlementProposals;

    event NewContractVersion(
        bytes32 indexed cid,
        bytes32 indexed amendmentCid,
        address indexed validator,
        bytes32 key
    );

    event NewSettlement(
        bytes32 indexed cid,
        uint16 indexed index,
        uint8 revision,
        address indexed validator,
        bytes32 key,
        SettlementParams data
    );

    event ApprovedSettlement(
        bytes32 indexed cid,
        uint16 indexed index,
        uint8 revision,
        bytes32 indexed key,
        address validator
    );

    function getLatestApprovedContractVersion(bytes32 _cid) public view returns (bytes32) {
        return contractVersions[_cid].cid;
    }

    function isApprovedContractVersion(bytes32 _cid, bytes32 _termsCid) public view returns (bool) {
        bytes32 _key = EscrowUtilsLib.genTermsKey(_cid, _termsCid);
        return contractVersionApprovals[_key];
    }

    function signAndProposeContractVersion(bytes32 _cid, bytes32 _termsCid) external {
        address _payer = contracts[_cid].payer;
        address _payee = contracts[_cid].payee;
        require(msg.sender == _payee || msg.sender == _payer, ERROR_NOT_PARTY);
        _proposeAmendment(_cid, _termsCid, _payee, _payer);
    }

    function signAndApproveContractVersion(bytes32 _cid, bytes32 _termsCid) public {
        bytes32 _key = EscrowUtilsLib.genTermsKey(_cid, _termsCid);
        require(_termsCid != EMPTY_BYTES32, ERROR_EMPTY);
        require(!contractVersionApprovals[_key], ERROR_AMENDMENT_EXIST);
        require(contractVersionProposals[_key].validator == msg.sender, ERROR_NOT_VALIDATOR);
        require(contractVersionProposals[_key].timestamp > contractVersions[_cid].timestamp, ERROR_EARLIER_AMENDMENT);

        _approveAmendment(_cid, contractVersionProposals[_key].termsCid, _key);
        
        delete contractVersionProposals[_key];
    }

    function signAndProposeMilestoneSettlement(
        bytes32 _cid,
        uint16 _index,
        bytes32 _termsCid,
        address _payeeAccount,
        address _refundAccount,
        address _escrowDisputeManager,
        uint _autoReleasedAt,
        uint _amount,
        uint _refundedAmount,
        uint _releasedAmount
    ) external returns (bytes32) {
        address _payer = contracts[_cid].payer;
        address _payee = contracts[_cid].payee;
        require(msg.sender == _payee || msg.sender == _payer, ERROR_NOT_PARTY);

        SettlementParams memory _sp = SettlementParams({
            termsCid: _termsCid,
            payeeAccount: _payeeAccount,
            refundAccount: _refundAccount,
            escrowDisputeManager: _escrowDisputeManager,
            autoReleasedAt: _autoReleasedAt,
            amount: _amount,
            refundedAmount: _refundedAmount,
            releasedAmount: _releasedAmount
        });
        
        return _proposeMilestoneSettlement(
            _cid,
            _index,
            _sp,
            _payer,
            _payee
        );
    }

    function signApproveAndExecuteMilestoneSettlement(bytes32 _cid, uint16 _index, uint8 _revision) public {
        bytes32 _key = EscrowUtilsLib.genSettlementKey(_cid, _index, _revision);
        require(settlementProposals[_key].validator == msg.sender, ERROR_NOT_VALIDATOR);
        _approveAndExecuteMilestoneSettlement(_cid, _index, _revision);
        
        delete settlementProposals[_key];
    }

    function _proposeAmendment(
        bytes32 _cid,
        bytes32 _termsCid,
        address _party1,
        address _party2
    ) internal returns (bytes32) {
        bytes32 _key = EscrowUtilsLib.genTermsKey(_cid, _termsCid);
        require(_termsCid != EMPTY_BYTES32, ERROR_EMPTY);

        address _validator = _party1;
        if (msg.sender == _party1) _validator = _party2;
        contractVersionProposals[_key] = AmendmentProposal({
            termsCid: _termsCid,
            validator: _validator,
            timestamp: block.timestamp
        });
        emit NewContractVersion(_cid, _termsCid, _validator, _key);
        return _key;
    }

    function _approveAmendment(bytes32 _cid, bytes32 _termsCid, bytes32 _key) internal {
        contractVersionApprovals[_key] = true;
        contractVersions[_cid] = Amendment({ cid: _termsCid, timestamp: block.timestamp });
        emit ApprovedContractVersion(_cid, _termsCid, _key);
    }

    function _proposeMilestoneSettlement(
        bytes32 _cid,
        uint16 _index,
        SettlementParams memory _settlementParams,
        address _party1,
        address _party2
    ) internal returns (bytes32) {
        uint8 _revision = milestones[EscrowUtilsLib.genMid(_cid, _index)].revision + 1;
        bytes32 _key = EscrowUtilsLib.genSettlementKey(_cid, _index, _revision);

        address _validator = _party1;
        if (msg.sender == _party1) _validator = _party2;
        settlementProposals[_key] = SettlementProposal({
            params: _settlementParams,
            validator: _validator,
            timestamp: block.timestamp
        });
        emit NewSettlement(
            _cid,
            _index,
            _revision,
            _validator,
            _key,
            _settlementParams
        );
        return _key;
    }

    function _approveAndExecuteMilestoneSettlement(bytes32 _cid, uint16 _index, uint8 _revision) internal {
        bytes32 _key = EscrowUtilsLib.genSettlementKey(_cid, _index, _revision);
        SettlementProposal memory _sp = settlementProposals[_key];
        bytes32 _mid = EscrowUtilsLib.genMid(_cid, _index);
        Milestone memory _m = milestones[_mid];
        require(_revision > _m.revision, ERROR_EARLIER_AMENDMENT);

        uint _leftAmount = _m.fundedAmount - _m.claimedAmount;
        if (_sp.params.amount < _leftAmount) {
            uint _overfundedAmount = _leftAmount - _sp.params.amount;
            require(_sp.params.refundedAmount + _sp.params.releasedAmount >= _overfundedAmount, ERROR_OVERFUNDED);
        }

        if (_sp.params.termsCid != EMPTY_BYTES32) {
            require(_sp.timestamp > contractVersions[_cid].timestamp, ERROR_EARLIER_AMENDMENT);
            bytes32 _termsKey = EscrowUtilsLib.genTermsKey(_cid, _sp.params.termsCid);
            _approveAmendment(_cid, _sp.params.termsCid, _termsKey);
        }

        milestones[_mid].revision += 1;
        milestones[_mid].amount = _sp.params.amount;

        if (_sp.params.refundedAmount != _m.refundedAmount) {
            milestones[_mid].refundedAmount = _sp.params.refundedAmount;
        }
        if (_sp.params.releasedAmount != _m.releasedAmount) {
            milestones[_mid].releasedAmount = _sp.params.releasedAmount;
        }

        if (_sp.params.payeeAccount != EMPTY_ADDRESS) milestones[_mid].payeeAccount = _sp.params.payeeAccount;
        if (_sp.params.refundAccount != EMPTY_ADDRESS) milestones[_mid].refundAccount = _sp.params.refundAccount;
        if (_sp.params.escrowDisputeManager != EMPTY_ADDRESS) milestones[_mid].escrowDisputeManager = IEscrowDisputeManager(_sp.params.escrowDisputeManager);
        if (_sp.params.autoReleasedAt != _m.autoReleasedAt) milestones[_mid].autoReleasedAt = _sp.params.autoReleasedAt;

        emit ApprovedSettlement(_cid, _index, _revision, _key, msg.sender);
    }
}// MPL-2.0

pragma solidity >=0.8.4 <0.9.0;


abstract contract AmendablePreSigned is Amendable {
    using EIP712 for address;

    bytes4 private constant MAGICVALUE = 0xe3f756de;

    bytes32 internal constant AMENDMENT_DOMAIN_TYPE_HASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );

    bytes32 internal constant AMENDMENT_DOMAIN_NAME = keccak256("ApprovedAmendment");

    bytes32 internal constant AMENDMENT_DOMAIN_VERSION = keccak256("v1");

    bytes32 public immutable AMENDMENT_DOMAIN_SEPARATOR;

    constructor() {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }

        AMENDMENT_DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                AMENDMENT_DOMAIN_TYPE_HASH,
                AMENDMENT_DOMAIN_NAME,
                AMENDMENT_DOMAIN_VERSION,
                chainId,
                address(this)
            )
        );
    }

    function getAmendmentDomainSeparator() public virtual view returns(bytes32) {
        return AMENDMENT_DOMAIN_SEPARATOR;
    }

    function isPreApprovedAmendment(
        bytes32 _cid,
        bytes32 _amendmentCid,
        address _validator,
        bytes calldata _signature
    ) internal view returns (bool) {
        bytes32 _currentCid = getLatestApprovedContractVersion(_cid);
        return _isPreApprovedAmendment(
            _cid,
            _currentCid,
            _amendmentCid,
            _validator,
            getAmendmentDomainSeparator(),
            _signature
        ) == MAGICVALUE;
    }

    function _isPreApprovedAmendment(
        bytes32 _cid,
        bytes32 _currentCid,
        bytes32 _amendmentCid,
        address _validator,
        bytes32 _domain,
        bytes calldata _callData
    ) internal pure returns (bytes4) {
        return EIP712._isValidEIP712Signature(
            _validator,
            MAGICVALUE,
            abi.encode(_domain, _cid, _currentCid, _amendmentCid),
            _callData
        );
    }
}// MPL-2.0

pragma solidity >=0.8.4 <0.9.0;


contract EscrowV1 is EscrowContract, AmendablePreSigned, WithPreSignedMilestones {

    using Address for address;

    string private constant ERROR_INVALID_PARTIES = "Invalid parties";
    string private constant ERROR_NOT_DISPUTER = "Not a disputer";
    string private constant ERROR_NO_MONEY = "Nothing to withdraw";
    string private constant ERROR_NOT_APPROVED = "Not signed";
    string private constant ERROR_INVALID_SETTLEMENT = "100% required";
    string private constant ERROR_DISPUTE_PARENT = "Dispute parent";

    uint256 private constant RULE_PAYEE_WON = 3;
    uint256 private constant RULE_PAYER_WON = 4;

    string private constant PAYER_EVIDENCE_LABEL = "Evidence (Payer)";
    string private constant PAYEE_EVIDENCE_LABEL = "Evidence (Payee)";

    bytes32 private constant EMPTY_BYTES32 = bytes32(0);

    modifier isDisputer(bytes32 _cid) {

        _isParty(_cid);
        _;
    }

    constructor(address _registry) EscrowContract(_registry) ReentrancyGuard() {
    }

    function _isParty(bytes32 _cid) internal view {

        require(_isPayerParty(_cid) || _isPayeeParty(_cid), ERROR_NOT_DISPUTER);
    }

    function _isPayerParty(bytes32 _cid) internal view returns (bool) {

        return msg.sender == contracts[_cid].payerDelegate || msg.sender == contracts[_cid].payer;
    }

    function _isPayeeParty(bytes32 _cid) internal view returns (bool) {

        return msg.sender == contracts[_cid].payeeDelegate || msg.sender == contracts[_cid].payee;
    }

    function registerContract(
        bytes32 _cid,
        address _payer,
        address _payerDelegate,
        address _payee,
        address _payeeDelegate,
        EscrowUtilsLib.MilestoneParams[] calldata _milestones
    ) external {

        require(_payer != _payee && _payerDelegate != _payeeDelegate, ERROR_INVALID_PARTIES);
        _registerContract(_cid, _payer, _payerDelegate, _payee, _payeeDelegate);

        bytes32 _mid;
        EscrowUtilsLib.MilestoneParams calldata _mp;
        uint16 _index;
        uint16 _oldIndex;
        uint16 _subIndex = 1;
        for (uint16 _i=0; _i<_milestones.length; _i++) {
            _mp = _milestones[_i];
            if (_mp.parentIndex > 0) {
                _oldIndex = _index;
                _index = _mp.parentIndex * MILESTONE_INDEX_BASE + _subIndex;
                _subIndex += 1;
            } else {
                _index += 1;
            }

            _mid = EscrowUtilsLib.genMid(_cid, _index);
            _registerMilestoneStorage(
                _mid,
                _mp.paymentToken,
                _mp.treasury,
                _mp.payeeAccount,
                _mp.refundAccount,
                _mp.escrowDisputeManager,
                _mp.autoReleasedAt,
                _mp.amount
            );
            emit NewMilestone(_cid, _index, _mid, _mp.paymentToken, _mp.escrowDisputeManager, _mp.autoReleasedAt, _mp.amount);
            if (_mp.parentIndex > 0) {
                emit ChildMilestone(_cid, _index, _mp.parentIndex, _mid);
                _index = _oldIndex;
            }
        }
        lastMilestoneIndex[_cid] = _index;
    }

    function registerMilestone(
        bytes32 _cid,
        uint16 _index,
        address _paymentToken,
        address _treasury,
        address _payeeAccount,
        address _refundAccount,
        address _escrowDisputeManager,
        uint _autoReleasedAt,
        uint _amount,
        bytes32 _amendmentCid
    ) external {

        _registerMilestone(
            _cid,
            _index,
            _paymentToken,
            _treasury,
            _payeeAccount,
            _refundAccount,
            _escrowDisputeManager,
            _autoReleasedAt,
            _amount
        );

        if (_cid != _amendmentCid && _amendmentCid != EMPTY_BYTES32 && _amendmentCid != getLatestApprovedContractVersion(_cid)) {
            _proposeAmendment(_cid, _amendmentCid, contracts[_cid].payer, contracts[_cid].payee);
        }

        if (_index < MILESTONE_INDEX_BASE) lastMilestoneIndex[_cid] = _index;
    }

    function stopMilestoneAutoRelease(bytes32 _cid, uint16 _index) external isDisputer(_cid) {

        bytes32 _mid = EscrowUtilsLib.genMid(_cid, _index);
        milestones[_mid].autoReleasedAt = 0;
    }

    function fundMilestone(bytes32 _cid, uint16 _index, uint _amountToFund) external {

        require(getLatestApprovedContractVersion(_cid) != EMPTY_BYTES32, ERROR_NOT_APPROVED);
        _fundMilestone(_cid, _index, _amountToFund);
    }

    function signAndFundMilestone(
        bytes32 _cid,
        uint16 _index,
        bytes32 _termsCid,
        uint _amountToFund,
        bytes calldata _payeeSignature,
        bytes calldata _payerSignature
    ) external {

        _signAndFundMilestone(_cid, _index, _termsCid, _amountToFund, _payeeSignature, _payerSignature);

        if (contractVersions[_cid].cid == EMPTY_BYTES32) {
            bytes32 _key = EscrowUtilsLib.genTermsKey(_cid, _termsCid);
            _approveAmendment(_cid, _termsCid, _key);
        }
    }

    function preApprovedAmendment(
        bytes32 _cid,
        bytes32 _amendmentCid,
        bytes calldata _payeeSignature,
        bytes calldata _payerSignature
    ) external {

        address _payee = contracts[_cid].payee;
        require(msg.sender == _payee || isPreApprovedAmendment(_cid, _amendmentCid, _payee, _payeeSignature), ERROR_NOT_DISPUTER);
        address _payer = contracts[_cid].payer;
        require(msg.sender == _payer || isPreApprovedAmendment(_cid, _amendmentCid, _payer, _payerSignature), ERROR_NOT_DISPUTER);
        
        bytes32 _key = EscrowUtilsLib.genTermsKey(_cid, _amendmentCid);
        _approveAmendment(_cid, _amendmentCid, _key);
    }

    function proposeSettlement(
        bytes32 _cid,
        uint16 _index,
        uint256 _refundedPercent,
        uint256 _releasedPercent,
        bytes32 _statement
    ) external {

        require(_index < MILESTONE_INDEX_BASE, ERROR_DISPUTE_PARENT);
        require(_refundedPercent + _releasedPercent == 100, ERROR_INVALID_SETTLEMENT);

        EscrowUtilsLib.Contract memory _c = contracts[_cid];
        address _plaintiff;
        if (msg.sender == _c.payeeDelegate || msg.sender == _c.payee) {
            _plaintiff = _c.payee;
        } else if (msg.sender == _c.payerDelegate || msg.sender == _c.payer) {
            _plaintiff = _c.payer;
        } else {
            revert(ERROR_NOT_DISPUTER);
        }
        
        bytes32 _mid = EscrowUtilsLib.genMid(_cid, _index);
        milestones[_mid].escrowDisputeManager.proposeSettlement(
            _cid,
            _index,
            _plaintiff,
            _c.payer,
            _c.payee,
            _refundedPercent,
            _releasedPercent,
            _statement
        );
    }

    function acceptSettlement(bytes32 _cid, uint16 _index) external {

        bytes32 _mid = EscrowUtilsLib.genMid(_cid, _index);
        if (_isPayerParty(_cid)) {
            milestones[_mid].escrowDisputeManager.acceptSettlement(_cid, _index, RULE_PAYEE_WON);
        } else if (_isPayeeParty(_cid)) {
            milestones[_mid].escrowDisputeManager.acceptSettlement(_cid, _index, RULE_PAYER_WON);
        } else {
            revert();
        }
    }

    function disputeSettlement(bytes32 _cid, uint16 _index, bool _ignoreCoverage) external isDisputer(_cid) {

        bytes32 _termsCid = getLatestApprovedContractVersion(_cid);
        bytes32 _mid = EscrowUtilsLib.genMid(_cid, _index);
        milestones[_mid].escrowDisputeManager.disputeSettlement(
            msg.sender,
            _cid,
            _index,
            _termsCid,
            _ignoreCoverage,
            lastMilestoneIndex[_cid] > 1
        );
    }

    function executeSettlement(bytes32 _cid, uint16 _index) external nonReentrant {

        bytes32 _mid = EscrowUtilsLib.genMid(_cid, _index);
        uint256 _ruling;
        uint256 _refundedPercent;
        uint256 _releasedPercent;
        IEscrowDisputeManager _disputer;

        if (_index > MILESTONE_INDEX_BASE) {
            uint16 _parentIndex = _index / MILESTONE_INDEX_BASE; // Integer division will floor the result
            bytes32 _parentMid = EscrowUtilsLib.genMid(_cid, _parentIndex);
            _disputer = milestones[_parentMid].escrowDisputeManager;
            _ruling = _disputer.resolutions(_parentMid);
            require(_ruling != 0, ERROR_DISPUTE_PARENT);
            (, uint256 __refundedPercent, uint256 __releasedPercent) = _disputer.getSettlementByRuling(_parentMid, _ruling);
            _refundedPercent = __refundedPercent;
            _releasedPercent = __releasedPercent;
        } else {
            _disputer = milestones[_mid].escrowDisputeManager;
            (uint256 __ruling, uint256 __refundedPercent, uint256 __releasedPercent) = _disputer.executeSettlement(_cid, _index, _mid);
            _ruling = __ruling;
            _refundedPercent = __refundedPercent;
            _releasedPercent = __releasedPercent;
        }

        if (_ruling == RULE_PAYER_WON || _ruling == RULE_PAYEE_WON) {
            require(_refundedPercent + _releasedPercent == 100, ERROR_INVALID_SETTLEMENT);
            Milestone memory _m = milestones[_mid];
            uint _available = _m.fundedAmount - _m.claimedAmount - _m.refundedAmount - _m.releasedAmount;
            require(_available > 0, ERROR_NO_MONEY);

            uint256 _refundedAmount = _available / 100 * _refundedPercent;
            uint256 _releasedAmount = _available / 100 * _releasedPercent;

            address _arbiter = _disputer.ARBITER();
            if (_refundedAmount > 0) _cancelMilestone(_mid, _refundedAmount + _m.refundedAmount, _refundedAmount, _arbiter);
            if (_releasedAmount > 0) _releaseMilestone(_mid, _releasedAmount + _m.releasedAmount, _releasedAmount, _arbiter);
        }
    }

    function submitEvidence(bytes32 _cid, uint16 _index, bytes calldata _evidence) external {

        string memory _label;
        if (_isPayerParty(_cid)) {
            _label = PAYER_EVIDENCE_LABEL;
        } else if (_isPayeeParty(_cid)) {
            _label = PAYEE_EVIDENCE_LABEL;
        } else {
            revert(ERROR_NOT_DISPUTER);
        }

        bytes32 _mid = EscrowUtilsLib.genMid(_cid, _index);
        milestones[_mid].escrowDisputeManager.submitEvidence(msg.sender, _label, _cid, _index, _evidence);
    }

    function multicall(bytes[] calldata data) external returns (bytes[] memory results) {

        results = new bytes[](data.length);
        for (uint i = 0; i < data.length; i++) {
            results[i] = Address.functionDelegateCall(address(this), data[i]);
        }
        return results;
    }
}