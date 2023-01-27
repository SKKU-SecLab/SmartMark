
pragma solidity 0.8.10;

interface IDistributor {

    function distribute(address _coin) external returns(bool);


}pragma solidity 0.8.10;

interface ICDSTemplate {

    function compensate(uint256) external returns (uint256 _compensated);


    function defund(address _to, uint256 _amount) external;

}pragma solidity 0.8.10;

interface IUniversalMarket {

    function initialize(
        address _depositor,
        string calldata _metaData,
        uint256[] calldata _conditions,
        address[] calldata _references
    ) external;


    function setPaused(bool state) external;

    function changeMetadata(string calldata _metadata) external;

}// MIT

pragma solidity 0.8.10;


interface IFactory {

    function approveTemplate(
        IUniversalMarket _template,
        bool _approval,
        bool _isOpen,
        bool _duplicate
    ) external;


    function approveReference(
        IUniversalMarket _template,
        uint256 _slot,
        address _target,
        bool _approval
    ) external;


    function setCondition(
        IUniversalMarket _template,
        uint256 _slot,
        uint256 _target
    ) external;


    function createMarket(
        IUniversalMarket _template,
        string memory _metaData,
        uint256[] memory _conditions,
        address[] memory _references
    ) external returns (address);

}pragma solidity 0.8.10;

interface IIndexTemplate {

    function compensate(uint256) external returns (uint256 _compensated);


    function lock() external;


    function resume() external;


    function setLeverage(uint256 _target) external;

    function set(
        uint256 _indexA,
        uint256 _indexB,
        address _pool,
        uint256 _allocPoint
    ) external;

}pragma solidity 0.8.10;


interface IOwnership {

    function owner() external view returns (address);


    function futureOwner() external view returns (address);


    function commitTransferOwnership(address newOwner) external;


    function acceptTransferOwnership() external;

}pragma solidity 0.8.10;

abstract contract IParameters {
    function setVault(address _token, address _vault) external virtual;

    function setLockup(address _address, uint256 _target) external virtual;

    function setGrace(address _address, uint256 _target) external virtual;

    function setMinDate(address _address, uint256 _target) external virtual;

    function setUpperSlack(address _address, uint256 _target) external virtual;

    function setLowerSlack(address _address, uint256 _target) external virtual;

    function setWithdrawable(address _address, uint256 _target)
        external
        virtual;

    function setPremiumModel(address _address, address _target)
        external
        virtual;

    function setFeeRate(address _address, uint256 _target) external virtual;

    function setMaxList(address _address, uint256 _target) external virtual;

    function setCondition(bytes32 _reference, bytes32 _target) external virtual;

    function getOwner() external view virtual returns (address);

    function getVault(address _token) external view virtual returns (address);

    function getPremium(
        uint256 _amount,
        uint256 _term,
        uint256 _totalLiquidity,
        uint256 _lockedAmount,
        address _target
    ) external view virtual returns (uint256);

    function getFeeRate(address _target) external view virtual returns (uint256);

    function getUpperSlack(address _target)
        external
        view
        virtual
        returns (uint256);

    function getLowerSlack(address _target)
        external
        view
        virtual
        returns (uint256);

    function getLockup(address _target) external view virtual returns (uint256);

    function getWithdrawable(address _target)
        external
        view
        virtual
        returns (uint256);

    function getGrace(address _target) external view virtual returns (uint256);

    function getMinDate(address _target) external view virtual returns (uint256);

    function getMaxList(address _target)
        external
        view
        virtual
        returns (uint256);

    function getCondition(bytes32 _reference)
        external
        view
        virtual
        returns (bytes32);
}pragma solidity 0.8.10;

abstract contract IPoolTemplate {

    enum MarketStatus {
        Trading,
        Payingout
    }
    function registerIndex(uint256 _index)external virtual;
    function allocateCredit(uint256 _credit)
        external
        virtual
        returns (uint256 _mintAmount);

    function pairValues(address _index)
        external
        view
        virtual
        returns (uint256, uint256);

    function withdrawCredit(uint256 _credit)
        external
        virtual
        returns (uint256 _retVal);

    function marketStatus() external view virtual returns(MarketStatus);
    function availableBalance() external view virtual returns (uint256 _balance);

    function utilizationRate() external view virtual returns (uint256 _rate);
    function totalLiquidity() public view virtual returns (uint256 _balance);
    function totalCredit() external view virtual returns (uint256);
    function lockedAmount() external view virtual returns (uint256);

    function valueOfUnderlying(address _owner)
        external
        view
        virtual
        returns (uint256);

    function pendingPremium(address _index)
        external
        view
        virtual
        returns (uint256);

    function paused() external view virtual returns (bool);

    function applyCover(
        uint256 _pending,
        uint256 _payoutNumerator,
        uint256 _payoutDenominator,
        uint256 _incidentTimestamp,
        bytes32 _merkleRoot,
        string calldata _rawdata,
        string calldata _memo
    ) external virtual;

    function applyBounty(
        uint256 _amount,
        address _contributor,
        uint256[] calldata _ids
    )external virtual;
}pragma solidity 0.8.10;

interface IPremiumModel {


    function getCurrentPremiumRate(
        uint256 _totalLiquidity,
        uint256 _lockedAmount
    ) external view returns (uint256);


    function getPremiumRate(
        uint256 _amount,
        uint256 _totalLiquidity,
        uint256 _lockedAmount
    ) external view returns (uint256);


    function getPremium(
        uint256 _amount,
        uint256 _term,
        uint256 _totalLiquidity,
        uint256 _lockedAmount
    ) external view returns (uint256);


    function setPremiumParameters(
        uint256,
        uint256,
        uint256,
        uint256
    ) external;

}pragma solidity 0.8.10;

interface IRegistry {

    function isListed(address _market) external view returns (bool);


    function getCDS(address _address) external view returns (address);


    function confirmExistence(address _template, address _target)
        external
        view
        returns (bool);


    function setFactory(address _factory) external;


    function supportMarket(address _market) external;


    function setExistence(address _template, address _target) external;


    function setCDS(address _address, address _cds) external;

}pragma solidity 0.8.10;

interface IVault {

    function addValueBatch(
        uint256 _amount,
        address _from,
        address[2] memory _beneficiaries,
        uint256[2] memory _shares
    ) external returns (uint256[2] memory _allocations);


    function addValue(
        uint256 _amount,
        address _from,
        address _attribution
    ) external returns (uint256 _attributions);


    function withdrawValue(uint256 _amount, address _to)
        external
        returns (uint256 _attributions);


    function transferValue(uint256 _amount, address _destination)
        external
        returns (uint256 _attributions);


    function withdrawAttribution(uint256 _attribution, address _to)
        external
        returns (uint256 _retVal);


    function withdrawAllAttribution(address _to)
        external
        returns (uint256 _retVal);


    function transferAttribution(uint256 _amount, address _destination)
        external;


    function attributionOf(address _target) external view returns (uint256);


    function underlyingValue(address _target) external view returns (uint256);


    function attributionValue(uint256 _attribution)
        external
        view
        returns (uint256);


    function utilize() external returns (uint256 _amount);

    function valueAll() external view returns (uint256);



    function token() external returns (address);


    function borrowValue(uint256 _amount, address _to) external;



    function offsetDebt(uint256 _amount, address _target)
        external
        returns (uint256 _attributions);


    function repayDebt(uint256 _amount, address _target) external;


    function debts(address _debtor) external view returns (uint256);


    function transferDebt(uint256 _amount) external;


    function withdrawRedundant(address _token, address _to) external;


    function setController(address _controller) external;


    function setKeeper(address _keeper) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

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
}// MIT

pragma solidity ^0.8.0;

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
}// MIT

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
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}pragma solidity 0.8.10;





contract PoolProxy is ReentrancyGuard {

    using SafeERC20 for IERC20;

    event CommitAdmins(
        address ownership_admin,
        address parameter_admin,
        address emergency_admin
    );
    event ApplyAdmins(
        address ownership_admin,
        address parameter_admin,
        address emergency_admin
    );
    event CommitDefaultReportingAdmin(address default_reporting_admin);
    event AcceptDefaultReportingAdmin(address default_reporting_admin);
    event SetReportingAdmin(address pool, address reporter);

    event AddDistributor(address distributor);

    address public ownership_admin;
    address public parameter_admin;
    address public emergency_admin;
    address public default_reporting_admin; //default reporting module address when arbitrary reporting module is not set.
    mapping(address => address) public reporting_admin; //Pool => Payout Decision Maker's address. (ex. ReportingDAO)

    address parameters; //pool-contracts Parameters.sol

    address public future_ownership_admin;
    address public future_parameter_admin;
    address public future_emergency_admin;
    address public future_default_reporting_admin;

    struct Distributor {
        string name;
        address addr;
    }


    mapping(address => mapping(uint256 => Distributor)) public distributors; // token distibutor contracts. token => ID => Distributor / (ex. USDC => 1 => FeeDistributorV1)
    mapping(address => uint256) public n_distributors; //token => distrobutor#
    mapping(address => mapping(uint256 => uint256)) public distributor_weight; // token => ID => weight
    mapping(address => mapping(uint256 => uint256)) public distributable; //distributor => allocated amount
    mapping(address => uint256) public total_weights; //token => total allocation point

    bool public distributor_kill;

    constructor(
        address _ownership_admin,
        address _parameter_admin,
        address _emergency_admin
    ) {
        ownership_admin = _ownership_admin;
        parameter_admin = _parameter_admin;
        emergency_admin = _emergency_admin;
    }

    function add_distributor(
        address _token,
        string memory _name,
        address _addr
    ) external returns(bool) {

        require(msg.sender == ownership_admin, "only ownership admin");
        require(_token != address(0), "_token cannot be zero address");

        Distributor memory new_distributor = Distributor({
            name: _name,
            addr: _addr
        });
        uint256 id = n_distributors[_token];
        distributors[_token][id] = new_distributor;
        n_distributors[_token] += 1;

        return true;
    }

    function _set_distributor(
        address _token,
        uint256 _id,
        Distributor memory _distributor
    ) internal {

        require(_id < n_distributors[_token], "distributor not added yet");

        if (_distributor.addr == address(0)) {
            _set_distributor_weight(_token, _id, 0);
        }

        distributors[_token][_id] = _distributor;
    }

    function set_distributor(
        address _token,
        uint256 _id,
        string memory _name,
        address _distributor
    ) external {

        require(msg.sender == ownership_admin, "only ownership admin");

        Distributor memory new_distributor = Distributor(_name, _distributor);

        _set_distributor(_token, _id, new_distributor);
    }

    function _set_distributor_weight(
        address _token,
        uint256 _id,
        uint256 _weight
    ) internal {

        require(_id < n_distributors[_token], "distributor not added yet");
        require(
            distributors[_token][_id].addr != address(0),
            "distributor not set"
        );

        uint256 new_weight = _weight;
        uint256 old_weight = distributor_weight[_token][_id];

        distributor_weight[_token][_id] = new_weight;
        total_weights[_token] = total_weights[_token] + new_weight - old_weight;
    }

    function set_distributor_weight(
        address _token,
        uint256 _id,
        uint256 _weight
    ) external returns(bool) {

        require(msg.sender == parameter_admin, "only parameter admin");

        _set_distributor_weight(_token, _id, _weight);

        return true;
    }

    function set_distributor_weight_many(
        address[20] memory _tokens,
        uint256[20] memory _ids,
        uint256[20] memory _weights
    ) external {

        require(msg.sender == parameter_admin, "only parameter admin");

        for (uint256 i; i < 20;) {
            if (_tokens[i] == address(0)) {
                break;
            }
            _set_distributor_weight(_tokens[i], _ids[i], _weights[i]);
            unchecked {
                ++i;
            }
        }
    }

    function get_distributor_name(address _token, uint256 _id)
    external
    view
    returns(string memory) {

        return distributors[_token][_id].name;
    }

    function get_distributor_address(address _token, uint256 _id)
    external
    view
    returns(address) {

        return distributors[_token][_id].addr;
    }

    function withdraw_admin_fee(address _token) external nonReentrant {

        require(_token != address(0), "_token cannot be zero address");

        address _vault = IParameters(parameters).getVault(_token); //dev: revert when parameters not set
        uint256 amount = IVault(_vault).withdrawAllAttribution(address(this));

        if (amount != 0) {
            uint256 _distributors = n_distributors[_token];
            for (uint256 id; id < _distributors;) {
                uint256 aloc_point = distributor_weight[_token][id];

                uint256 aloc_amount = (amount * aloc_point) /
                    total_weights[_token]; //round towards zero.
                distributable[_token][id] += aloc_amount; //count up the allocated fee
                unchecked {
                    ++id;
                }
            }
        }
    }


    function _distribute(address _token, uint256 _id) internal {

        require(_id < n_distributors[_token], "distributor not added yet");

        address _addr = distributors[_token][_id].addr;
        uint256 amount = distributable[_token][_id];
        distributable[_token][_id] = 0;

        IERC20(_token).safeApprove(_addr, amount);
        require(
            IDistributor(_addr).distribute(_token),
            "dev: should implement distribute()"
        );
    }

    function distribute(address _token, uint256 _id) external nonReentrant {

        require(tx.origin == msg.sender); //only EOA
        require(!distributor_kill, "distributor is killed");

        _distribute(_token, _id);
    }

    function distribute_many(
        address[20] memory _tokens,
        uint256[20] memory _ids
    ) external nonReentrant {

        require(tx.origin == msg.sender);
        require(!distributor_kill, "distribution killed");

        for (uint256 i; i < 20;) {
            if (_tokens[i] == address(0)) {
                break;
            }
            _distribute(_tokens[i], _ids[i]);
            unchecked {
                ++i;
            }
        }
    }

    function set_distributor_kill(bool _is_killed) external {

        require(
            msg.sender == emergency_admin || msg.sender == ownership_admin,
            "Access denied"
        );
        distributor_kill = _is_killed;
    }

    function commit_set_admins(
        address _o_admin,
        address _p_admin,
        address _e_admin
    ) external {

        require(msg.sender == ownership_admin, "Access denied");

        future_ownership_admin = _o_admin;
        future_parameter_admin = _p_admin;
        future_emergency_admin = _e_admin;

        emit CommitAdmins(_o_admin, _p_admin, _e_admin);
    }

    function accept_set_admins() external {

        require(msg.sender == future_ownership_admin, "Access denied");

        ownership_admin = future_ownership_admin;
        parameter_admin = future_parameter_admin;
        emergency_admin = future_emergency_admin;

        emit ApplyAdmins(ownership_admin, parameter_admin, emergency_admin);
    }

    function commit_set_default_reporting_admin(address _r_admin) external {

        require(msg.sender == ownership_admin, "Access denied");

        future_default_reporting_admin = _r_admin;

        emit CommitDefaultReportingAdmin(future_default_reporting_admin);
    }

    function accept_set_default_reporting_admin() external {

        require(msg.sender == future_default_reporting_admin, "Access denied");

        default_reporting_admin = future_default_reporting_admin;

        emit AcceptDefaultReportingAdmin(default_reporting_admin);
    }

    function set_reporting_admin(address _pool, address _reporter)
    external
    returns(bool) {

        require(
            address(msg.sender) == ownership_admin ||
            address(msg.sender) == default_reporting_admin,
            "Access denied"
        );

        reporting_admin[_pool] = _reporter;

        emit SetReportingAdmin(_pool, _reporter);

        return true;
    }

    function get_reporter(address _pool) public view returns(address) {


        address reporter = reporting_admin[_pool] != address(0) ?
            reporting_admin[_pool] :
            default_reporting_admin;

        return reporter;
    }

    function ownership_accept_transfer_ownership(address _ownership_contract)
    external {

        require(msg.sender == ownership_admin, "Access denied");

        IOwnership(_ownership_contract).acceptTransferOwnership();
    }

    function ownership_commit_transfer_ownership(
        address _ownership_contract,
        address newOwner
    ) external {

        require(msg.sender == ownership_admin, "Access denied");

        IOwnership(_ownership_contract).commitTransferOwnership(newOwner);
    }

    function factory_approve_template(
        address _factory,
        address _template_addr,
        bool _approval,
        bool _isOpen,
        bool _duplicate
    ) external {

        require(msg.sender == ownership_admin, "Access denied");
        IUniversalMarket _template = IUniversalMarket(_template_addr);

        IFactory(_factory).approveTemplate(
            _template,
            _approval,
            _isOpen,
            _duplicate
        );
    }

    function factory_approve_reference(
        address _factory,
        address _template_addr,
        uint256 _slot,
        address _target,
        bool _approval
    ) external {

        require(msg.sender == ownership_admin, "Access denied");
        IUniversalMarket _template = IUniversalMarket(_template_addr);

        IFactory(_factory).approveReference(
            _template,
            _slot,
            _target,
            _approval
        );
    }

    function factory_set_condition(
        address _factory,
        address _template_addr,
        uint256 _slot,
        uint256 _target
    ) external {

        require(msg.sender == ownership_admin, "Access denied");
        IUniversalMarket _template = IUniversalMarket(_template_addr);

        IFactory(_factory).setCondition(_template, _slot, _target);
    }

    function factory_create_market(
        address _factory,
        address _template_addr,
        string memory _metaData,
        uint256[] memory _conditions,
        address[] memory _references
    ) external returns(address) {

        require(msg.sender == ownership_admin, "Access denied");
        IUniversalMarket _template = IUniversalMarket(_template_addr);

        address _market = IFactory(_factory).createMarket(
            _template,
            _metaData,
            _conditions,
            _references
        );

        return _market;
    }

    function pm_set_premium(
        address _premium,
        uint256 _multiplierPerYear,
        uint256 _initialBaseRatePerYear,
        uint256 _finalBaseRatePerYear,
        uint256 _goalTVL
    ) external {

        require(msg.sender == parameter_admin, "Access denied");
        IPremiumModel(_premium).setPremiumParameters(
            _multiplierPerYear,
            _initialBaseRatePerYear,
            _finalBaseRatePerYear,
            _goalTVL
        );
    }

    function pm_set_paused(address _pool, bool _state) external nonReentrant {

        require(
            msg.sender == emergency_admin || msg.sender == ownership_admin,
            "Access denied"
        );
        IUniversalMarket(_pool).setPaused(_state);
    }

    function pm_change_metadata(address _pool, string calldata _metadata)
    external {

        require(msg.sender == parameter_admin, "Access denied");
        IUniversalMarket(_pool).changeMetadata(_metadata);
    }

    function pool_apply_cover(
        address _pool,
        uint256 _pending,
        uint256 _payoutNumerator,
        uint256 _payoutDenominator,
        uint256 _incidentTimestamp,
        bytes32 _merkleRoot,
        string calldata _rawdata,
        string calldata _memo
    ) external {

        require(msg.sender == default_reporting_admin || msg.sender == reporting_admin[_pool], "Access denied");

        IPoolTemplate(_pool).applyCover(
            _pending,
            _payoutNumerator,
            _payoutDenominator,
            _incidentTimestamp,
            _merkleRoot,
            _rawdata,
            _memo
        );
    }

    function pool_apply_bounty(
        address _pool,
        uint256 _amount,
        address _contributor,
        uint256[] calldata _ids
    ) external {

        require(msg.sender == default_reporting_admin || msg.sender == reporting_admin[_pool], "Access denied");

        IPoolTemplate(_pool).applyBounty(
            _amount,
            _contributor,
            _ids
        );
    }

    function index_set_leverage(address _index, uint256 _target) external {

        require(msg.sender == parameter_admin, "Access denied");

        IIndexTemplate(_index).setLeverage(_target);
    }

    function index_set(
        address _index_address,
        uint256 _indexA,
        uint256 _indexB,
        address _pool,
        uint256 _allocPoint
    ) external {

        require(msg.sender == parameter_admin, "Access denied");

        IIndexTemplate(_index_address).set(_indexA, _indexB, _pool, _allocPoint);
    }

    function defund(address _cds, address _to, uint256 _amount) external {

        require(msg.sender == ownership_admin, "Access denied");

        ICDSTemplate(_cds).defund(_to, _amount);
    }

    function vault_withdraw_redundant(
        address _vault,
        address _token,
        address _to
    ) external {

        require(msg.sender == ownership_admin, "Access denied");
        IVault(_vault).withdrawRedundant(_token, _to);
    }

    function vault_set_keeper(address _vault, address _keeper) external {

        require(msg.sender == ownership_admin, "Access denied");
        IVault(_vault).setKeeper(_keeper);
    }

    function vault_set_controller(address _vault, address _controller)
    external {

        require(msg.sender == ownership_admin, "Access denied");
        IVault(_vault).setController(_controller);
    }

    function set_parameters(address _parameters) external {


        require(msg.sender == ownership_admin, "Access denied");
        parameters = _parameters;
    }

    function parameters_set_vault(
        address _parameters,
        address _token,
        address _vault
    ) external {

        require(msg.sender == ownership_admin, "Access denied");

        IParameters(_parameters).setVault(_token, _vault);
    }

    function parameters_set_lockup(
        address _parameters,
        address _address,
        uint256 _target
    ) external {

        require(msg.sender == parameter_admin, "Access denied");

        IParameters(_parameters).setLockup(_address, _target);
    }

    function parameters_set_grace(
        address _parameters,
        address _address,
        uint256 _target
    ) external {

        require(msg.sender == parameter_admin, "Access denied");

        IParameters(_parameters).setGrace(_address, _target);
    }

    function parameters_set_mindate(
        address _parameters,
        address _address,
        uint256 _target
    ) external {

        require(msg.sender == parameter_admin, "Access denied");

        IParameters(_parameters).setMinDate(_address, _target);
    }

    function parameters_set_upper_slack(
        address _parameters,
        address _address,
        uint256 _target
    ) external {

        require(msg.sender == parameter_admin, "Access denied");

        IParameters(_parameters).setUpperSlack(_address, _target);
    }

    function parameters_set_lower_slack(
        address _parameters,
        address _address,
        uint256 _target
    ) external {

        require(msg.sender == parameter_admin, "Access denied");

        IParameters(_parameters).setLowerSlack(_address, _target);
    }

    function parameters_set_withdrawable(
        address _parameters,
        address _address,
        uint256 _target
    ) external {

        require(msg.sender == parameter_admin, "Access denied");

        IParameters(_parameters).setWithdrawable(_address, _target);
    }

    function parameters_set_premium_model(
        address _parameters,
        address _address,
        address _target
    ) external {

        require(msg.sender == parameter_admin, "Access denied");

        IParameters(_parameters).setPremiumModel(_address, _target);
    }

    function setFeeRate(
        address _parameters,
        address _address,
        uint256 _target
    ) external {

        require(msg.sender == parameter_admin, "Access denied");

        IParameters(_parameters).setFeeRate(_address, _target);
    }

    function parameters_set_max_list(
        address _parameters,
        address _address,
        uint256 _target
    ) external {

        require(msg.sender == parameter_admin, "Access denied");

        IParameters(_parameters).setMaxList(_address, _target);
    }

    function parameters_set_condition_parameters(
        address _parameters,
        bytes32 _reference,
        bytes32 _target
    ) external {

        require(msg.sender == parameter_admin, "Access denied");

        IParameters(_parameters).setCondition(_reference, _target);
    }

    function registry_set_factory(address _registry, address _factory)
    external {

        require(msg.sender == ownership_admin, "Access denied");

        IRegistry(_registry).setFactory(_factory);
    }

    function registry_support_market(address _registry, address _market)
    external {

        require(msg.sender == ownership_admin, "Access denied");

        IRegistry(_registry).supportMarket(_market);
    }

    function registry_set_existence(
        address _registry,
        address _template,
        address _target
    ) external {

        require(msg.sender == ownership_admin, "Access denied");

        IRegistry(_registry).setExistence(_template, _target);
    }

    function registry_set_cds(
        address _registry,
        address _address,
        address _target
    ) external {

        require(msg.sender == ownership_admin, "Access denied");

        IRegistry(_registry).setCDS(_address, _target);
    }
}