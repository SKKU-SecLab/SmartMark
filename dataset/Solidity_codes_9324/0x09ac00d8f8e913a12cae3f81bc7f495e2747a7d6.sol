
pragma solidity >=0.8.4 <0.9.0;

interface IRegistry {

    function registerNewContract(bytes32 _cid, address _payer, address _payee) external;

    function escrowContracts(address _addr) external returns (bool);

    function insuranceManager() external returns (address);

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
}// MPL-2.0

pragma solidity >=0.8.4 <0.9.0;


interface IAragonCourt {

    function createDispute(uint256 _possibleRulings, bytes calldata _metadata) external returns (uint256);

    function submitEvidence(uint256 _disputeId, address _submitter, bytes calldata _evidence) external;

    function rule(uint256 _disputeId) external returns (address subject, uint256 ruling);

    function getDisputeFees() external view returns (address recipient, IERC20 feeToken, uint256 feeAmount);

    function closeEvidencePeriod(uint256 _disputeId) external;

}// MPL-2.0

pragma solidity >=0.8.4 <0.9.0;

interface IInsurance {

    function getCoverage(bytes32 _cid, address _token, uint256 _feeAmount) external view returns (uint256, uint256);

    function useCoverage(bytes32 _cid, address _token, uint256 _amount) external returns (bool);

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


library AragonCourtMetadataLib {

    bytes2 private constant IPFS_V1_PREFIX = 0x1220;
    bytes32 private constant AC_GREET_PREFIX = 0x4752454554000000000000000000000000000000000000000000000000000000; // GREET
    bytes32 private constant PAYEE_BUTTON_COLOR = 0xffb46d0000000000000000000000000000000000000000000000000000000000; // Orange
    bytes32 private constant PAYER_BUTTON_COLOR = 0xffb46d0000000000000000000000000000000000000000000000000000000000; // Orange
    bytes32 private constant DEFAULT_STATEMENT_PAYER = bytes32(0);
    bytes32 private constant DEFAULT_STATEMENT_PAYEE = bytes32(0);
    string private constant PAYER_BUTTON = "Payer";
    string private constant PAYEE_BUTTON = "Payee";
    string private constant PAYEE_SETTLEMENT = " % released to Payee";
    string private constant PAYER_SETTLEMENT = " % refunded to Payer";
    string private constant SEPARATOR = ", ";
    string private constant NEW_LINE = "\n";
    string private constant DESC_PREFIX = "Should the escrow funds associated with ";
    string private constant DESC_SUFFIX = "the contract be distributed according to the claim of Payer or Payee?";
    string private constant DESC_MILESTONE_PREFIX = "Milestone ";
    string private constant DESC_MILESTONE_SUFFIX = " of ";
    string private constant PAYER_CLAIM_PREFIX = "Payer claim: ";
    string private constant PAYEE_CLAIM_PREFIX = "Payee claim: ";

    struct Claim {
        uint refundedPercent;
        uint releasedPercent;
        bytes32 statement;
    }

    struct EnforceableSettlement {
        address escrowContract;
        Claim payerClaim;
        Claim payeeClaim;
        uint256 fillingStartsAt;
        uint256 did;
        uint256 ruling;
    }

    function generatePayload(
        EnforceableSettlement memory _enforceableSettlement,
        bytes32 _termsCid,
        address _plaintiff,
        uint16 _index,
        bool _multi
    ) internal pure returns (bytes memory) {

        bytes memory _desc = textForDescription(
            _index,
            _multi,
            _enforceableSettlement.payeeClaim,
            _enforceableSettlement.payerClaim
        );
        
        return abi.encode(
            AC_GREET_PREFIX,
            toIpfsCid(_termsCid),
            _plaintiff,
            PAYER_BUTTON,
            PAYER_BUTTON_COLOR,
            PAYEE_BUTTON,
            PAYER_BUTTON_COLOR,
            _desc
        );
    }

    function defaultPayeeClaim() internal pure returns (Claim memory) {

        return Claim({
            refundedPercent: 0,
            releasedPercent: 100,
            statement: DEFAULT_STATEMENT_PAYEE
        });
    }

    function defaultPayerClaim() internal pure returns (Claim memory) {

        return Claim({
            refundedPercent: 100,
            releasedPercent: 0,
            statement: DEFAULT_STATEMENT_PAYER
        });
    }

    function toIpfsCid(bytes32 _chunkedCid) internal pure returns (bytes memory) {

        return abi.encodePacked(IPFS_V1_PREFIX, _chunkedCid);
    }

    function textForDescription(
        uint256 _index,
        bool _multi,
        Claim memory _payeeClaim,
        Claim memory _payerClaim
    ) internal pure returns (bytes memory) {

        bytes memory _claims = abi.encodePacked(
            NEW_LINE,
            NEW_LINE,
            PAYER_CLAIM_PREFIX,
            textForClaim(_payerClaim.refundedPercent, _payerClaim.releasedPercent),
            NEW_LINE,
            NEW_LINE,
            PAYEE_CLAIM_PREFIX,
            textForClaim(_payeeClaim.refundedPercent, _payeeClaim.releasedPercent)
        );

        if (_multi) {
            return abi.encodePacked(
                DESC_PREFIX,
                DESC_MILESTONE_PREFIX,
                uint2str(_index),
                DESC_MILESTONE_SUFFIX,
                DESC_SUFFIX,
                _claims
            );
        } else {
            return abi.encodePacked(
                DESC_PREFIX,
                DESC_SUFFIX,
                _claims
            );
        }
    }

    function textForClaim(uint256 _refundedPercent, uint256 _releasedPercent) internal pure returns (string memory) {

        if (_refundedPercent == 0) {
            return string(abi.encodePacked(uint2str(_releasedPercent), PAYEE_SETTLEMENT));
        } else if (_releasedPercent == 0) {
            return string(abi.encodePacked(uint2str(_refundedPercent), PAYER_SETTLEMENT));
        } else {
            return string(abi.encodePacked(
                uint2str(_releasedPercent),
                PAYEE_SETTLEMENT,
                SEPARATOR,
                uint2str(_refundedPercent),
                PAYER_SETTLEMENT
            ));
        }
    }

    function uint2str(uint _i) internal pure returns (string memory) {

        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        
        unchecked {
            while (_i != 0) {
                bstr[k--] = bytes1(uint8(48 + _i % 10));
                _i /= 10;
            }
        }
        return string(bstr);
    }
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
}// MPL-2.0

pragma solidity >=0.8.4 <0.9.0;


contract AragonCourtDisputerV1 {

    using SafeERC20 for IERC20;

    string private constant ERROR_NOT_VALIDATOR = "Not a validator";
    string private constant ERROR_NOT_DISPUTER = "Not a disputer";
    string private constant ERROR_IN_DISPUTE = "In dispute";
    string private constant ERROR_NOT_IN_DISPUTE = "Not in dispute";
    string private constant ERROR_NOT_READY = "Not ready for dispute";
    string private constant ERROR_ALREADY_RESOLVED = "Resolution applied";
    string private constant ERROR_INVALID_RULING = "Invalid ruling";

    IRegistry public immutable TRUSTED_REGISTRY;
    IAragonCourt public immutable ARBITER;

    uint256 public immutable SETTLEMENT_DELAY;

    uint256 private constant EMPTY_INT = 0;
    uint256 private constant RULE_LEAKED = 1;
    uint256 private constant RULE_IGNORED = 2;
    uint256 private constant RULE_PAYEE_WON = 3;
    uint256 private constant RULE_PAYER_WON = 4;

    string private constant PAYER_STATEMENT_LABEL = "Statement (Payer)";
    string private constant PAYEE_STATEMENT_LABEL = "Statement (Payee)";

    bytes32 private constant EMPTY_BYTES32 = bytes32(0);

    using AragonCourtMetadataLib for AragonCourtMetadataLib.EnforceableSettlement;

    mapping (bytes32 => uint256) public resolutions;
    mapping (bytes32 => AragonCourtMetadataLib.EnforceableSettlement) public enforceableSettlements;

    event UsedInsurance(
        bytes32 indexed cid,
        uint16 indexed index,
        address indexed feeToken,
        uint256 covered,
        uint256 notCovered
    );

    event SettlementProposed(
        bytes32 indexed cid,
        uint16 indexed index,
        address indexed plaintiff,
        uint256 refundedPercent,
        uint256 releasedPercent,
        uint256 fillingStartsAt,
        bytes32 statement
    );

    event DisputeStarted(
        bytes32 indexed cid,
        uint16 indexed index,
        address indexed plaintiff,
        uint256 did,
        bool ignoreCoverage
    );

    event DisputeWitnessed(
        bytes32 indexed cid,
        uint16 indexed index,
        address indexed witness,
        uint256 did,
        bytes evidence
    );

    event DisputeConcluded(
        bytes32 indexed cid,
        uint16 indexed index,
        uint256 indexed rule,
        uint256 did
    );

    modifier isEscrow() {

        require(TRUSTED_REGISTRY.escrowContracts(msg.sender), ERROR_NOT_DISPUTER);
        _;
    }

    constructor(address _registry, address _arbiter, uint256 _settlementDelay) {
        TRUSTED_REGISTRY = IRegistry(_registry);
        ARBITER = IAragonCourt(_arbiter);
        SETTLEMENT_DELAY = _settlementDelay;
    }

    function _requireDisputedEscrow(bytes32 _mid) internal view {

        require(msg.sender == enforceableSettlements[_mid].escrowContract, ERROR_NOT_VALIDATOR);
    }

    function hasSettlementDispute(bytes32 _mid) public view returns (bool) {

        return enforceableSettlements[_mid].fillingStartsAt > 0;
    }

    function getSettlementByRuling(bytes32 _mid, uint256 _ruling) public view returns (uint256, uint256, uint256) {

        if (_ruling == RULE_PAYEE_WON) {
            AragonCourtMetadataLib.Claim memory _claim = enforceableSettlements[_mid].payeeClaim;
            return (_ruling, _claim.refundedPercent, _claim.releasedPercent);
        } else if (_ruling == RULE_PAYER_WON) {
            AragonCourtMetadataLib.Claim memory _claim = enforceableSettlements[_mid].payerClaim;
            return (_ruling, _claim.refundedPercent, _claim.releasedPercent);
        } else {
            return (_ruling, 0, 0);
        }
    }

    function proposeSettlement(
        bytes32 _cid,
        uint16 _index,
        address _plaintiff,
        address _payer,
        address _payee,
        uint _refundedPercent,
        uint _releasedPercent,
        bytes32 _statement
    ) external isEscrow {

        bytes32 _mid = _genMid(_cid, _index);
        require(enforceableSettlements[_mid].did == EMPTY_INT, ERROR_IN_DISPUTE);
        uint256 _resolution = resolutions[_mid];
        require(_resolution != RULE_PAYEE_WON && _resolution != RULE_PAYER_WON, ERROR_ALREADY_RESOLVED);

        AragonCourtMetadataLib.Claim memory _proposal = AragonCourtMetadataLib.Claim({
            refundedPercent: _refundedPercent,
            releasedPercent: _releasedPercent,
            statement: _statement
        });

        uint256 _fillingStartsAt = enforceableSettlements[_mid].fillingStartsAt; 
        if (_plaintiff == _payer) {
            enforceableSettlements[_mid].payerClaim = _proposal;
            if (_fillingStartsAt == 0) {
                _fillingStartsAt = block.timestamp + SETTLEMENT_DELAY;
                enforceableSettlements[_mid].fillingStartsAt = _fillingStartsAt;
                enforceableSettlements[_mid].payeeClaim = AragonCourtMetadataLib.defaultPayeeClaim();
                enforceableSettlements[_mid].escrowContract = msg.sender;
            }
        } else if (_plaintiff == _payee) {
            enforceableSettlements[_mid].payeeClaim = _proposal;
            if (_fillingStartsAt == 0) {
                _fillingStartsAt = block.timestamp + SETTLEMENT_DELAY;
                enforceableSettlements[_mid].fillingStartsAt = _fillingStartsAt;
                enforceableSettlements[_mid].payerClaim = AragonCourtMetadataLib.defaultPayerClaim();
                enforceableSettlements[_mid].escrowContract = msg.sender;
            }
        } else {
            revert();
        }
        emit SettlementProposed(_cid, _index, _plaintiff, _refundedPercent, _releasedPercent, _fillingStartsAt, _statement);
    }

    function acceptSettlement(
        bytes32 _cid,
        uint16 _index,
        uint256 _ruling
    ) external {

        bytes32 _mid = _genMid(_cid, _index);
        _requireDisputedEscrow(_mid);
        require(_ruling == RULE_PAYER_WON || _ruling == RULE_PAYEE_WON, ERROR_INVALID_RULING);
        resolutions[_mid] = _ruling;
        emit DisputeConcluded(_cid, _index, _ruling, 0);
    }

    function disputeSettlement(
        address _feePayer,
        bytes32 _cid,
        uint16 _index,
        bytes32 _termsCid,
        bool _ignoreCoverage,
        bool _multiMilestone
    ) external returns (uint256) {

        bytes32 _mid = _genMid(_cid, _index);
        _requireDisputedEscrow(_mid);
        require(enforceableSettlements[_mid].did == EMPTY_INT, ERROR_IN_DISPUTE);
        uint256 _fillingStartsAt = enforceableSettlements[_mid].fillingStartsAt;
        require(_fillingStartsAt > 0 && _fillingStartsAt < block.timestamp, ERROR_NOT_READY);
        uint256 _resolution = resolutions[_mid];
        require(_resolution != RULE_PAYEE_WON && _resolution != RULE_PAYER_WON, ERROR_ALREADY_RESOLVED);

        _payDisputeFees(_feePayer, _cid, _index, _ignoreCoverage);

        AragonCourtMetadataLib.EnforceableSettlement memory _enforceableSettlement = enforceableSettlements[_mid];
        bytes memory _metadata = _enforceableSettlement.generatePayload(_termsCid, _feePayer, _index, _multiMilestone);
        uint256 _did = ARBITER.createDispute(2, _metadata);
        enforceableSettlements[_mid].did = _did;


        bytes32 __payerStatement = enforceableSettlements[_mid].payerClaim.statement;
        if (__payerStatement != EMPTY_BYTES32) {
            bytes memory _payerStatement = AragonCourtMetadataLib.toIpfsCid(__payerStatement);
            ARBITER.submitEvidence(_did, address(this), abi.encode(_payerStatement, PAYER_STATEMENT_LABEL));
        }

        bytes32 __payeeStatement = enforceableSettlements[_mid].payeeClaim.statement;
        if (__payeeStatement != EMPTY_BYTES32) {
            bytes memory _payeeStatement = AragonCourtMetadataLib.toIpfsCid(__payeeStatement);
            ARBITER.submitEvidence(_did, address(this), abi.encode(_payeeStatement, PAYEE_STATEMENT_LABEL));
        }

        emit DisputeStarted(_cid, _index, _feePayer, _did, _ignoreCoverage);
        return _did;
    }

    function executeSettlement(bytes32 _cid, uint16 _index, bytes32 _mid) public returns(uint256, uint256, uint256) {

        uint256 _ruling = ruleDispute(_cid, _index, _mid);
        return getSettlementByRuling(_mid, _ruling);
    }

    function submitEvidence(address _from, string memory _label, bytes32 _cid, uint16 _index, bytes calldata _evidence) external isEscrow {

        bytes32 _mid = _genMid(_cid, _index);
        uint256 _did = enforceableSettlements[_mid].did;
        require(_did != EMPTY_INT, ERROR_NOT_IN_DISPUTE);
        ARBITER.submitEvidence(_did, _from, abi.encode(_evidence, _label));
        emit DisputeWitnessed(_cid, _index, _from, _did, _evidence);
    }

    function ruleDispute(bytes32 _cid, uint16 _index, bytes32 _mid) public returns(uint256) {

        _requireDisputedEscrow(_mid);
        uint256 _resolved = resolutions[_mid];
        if (_resolved != EMPTY_INT && _resolved != RULE_IGNORED && _resolved != RULE_LEAKED) return _resolved;

        uint256 _did = enforceableSettlements[_mid].did;
        require(_did != EMPTY_INT || enforceableSettlements[_mid].did != EMPTY_INT, ERROR_NOT_IN_DISPUTE);

        (, uint256 _ruling) = ARBITER.rule(_did);
        resolutions[_mid] = _ruling;
        if (_ruling == RULE_IGNORED || _ruling == RULE_LEAKED) {
            enforceableSettlements[_mid].fillingStartsAt = block.timestamp + SETTLEMENT_DELAY;
            delete enforceableSettlements[_mid].did;
        } else {
            if (_ruling != RULE_PAYER_WON && _ruling != RULE_PAYEE_WON) revert();
        }
        
        emit DisputeConcluded(_cid, _index, _ruling, _did);
        return _ruling;
    }

    function _payDisputeFees(address _feePayer, bytes32 _cid, uint16 _index, bool _ignoreCoverage) private {

        (address _recipient, IERC20 _feeToken, uint256 _feeAmount) = ARBITER.getDisputeFees();
        if (!_ignoreCoverage) {
            IInsurance _insuranceManager = IInsurance(TRUSTED_REGISTRY.insuranceManager());
            (uint256 _notCovered, uint256 _covered) = _insuranceManager.getCoverage(_cid, address(_feeToken), _feeAmount);
            if (_notCovered > 0) _feeToken.safeTransferFrom(_feePayer, address(this), _notCovered);
            if (_covered > 0) require(_insuranceManager.useCoverage(_cid, address(_feeToken), _covered));
            emit UsedInsurance(_cid, _index, address(_feeToken), _covered, _notCovered);
        } else {
            _feeToken.safeTransferFrom(_feePayer, address(this), _feeAmount);
        }
        _feeToken.safeApprove(_recipient, _feeAmount);
    }

    function _genMid(bytes32 _cid, uint16 _index) public pure returns(bytes32) {

        return keccak256(abi.encode(_cid, _index));
    }
}