
pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {

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

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}// BSD-3-Clause
pragma solidity 0.6.12;

interface CToken {

    function admin() external view returns (address);

    function adminHasRights() external view returns (bool);

    function fuseAdminHasRights() external view returns (bool);

    function symbol() external view returns (string memory);

    function comptroller() external view returns (address);

    function adminFeeMantissa() external view returns (uint256);

    function fuseFeeMantissa() external view returns (uint256);

    function reserveFactorMantissa() external view returns (uint256);

    function totalReserves() external view returns (uint);

    function totalAdminFees() external view returns (uint);

    function totalFuseFees() external view returns (uint);


    function isCToken() external view returns (bool);

    function isCEther() external view returns (bool);


    function balanceOf(address owner) external view returns (uint);

    function balanceOfUnderlying(address owner) external returns (uint);

    function borrowRatePerBlock() external view returns (uint);

    function supplyRatePerBlock() external view returns (uint);

    function totalBorrowsCurrent() external returns (uint);

    function borrowBalanceStored(address account) external view returns (uint);

    function exchangeRateStored() external view returns (uint);

    function getCash() external view returns (uint);


    function redeem(uint redeemTokens) external returns (uint);

    function redeemUnderlying(uint redeemAmount) external returns (uint);

}// BSD-3-Clause
pragma solidity 0.6.12;


interface PriceOracle {

    function getUnderlyingPrice(CToken cToken) external view returns (uint);

}// BSD-3-Clause
pragma solidity 0.6.12;

interface Unitroller {

    function _setPendingImplementation(address newPendingImplementation) external returns (uint);

    function _setPendingAdmin(address newPendingAdmin) external returns (uint);

}// BSD-3-Clause
pragma solidity 0.6.12;


interface RewardsDistributor {

    function rewardToken() external view returns (address);


    function compSupplySpeeds(address) external view returns (uint);


    function compBorrowSpeeds(address) external view returns (uint);


    function compAccrued(address) external view returns (uint);


    function flywheelPreSupplierAction(address cToken, address supplier) external;


    function flywheelPreBorrowerAction(address cToken, address borrower) external;


    function getAllMarkets() external view returns (CToken[] memory);

}// BSD-3-Clause
pragma solidity 0.6.12;


interface Comptroller {

    function admin() external view returns (address);

    function adminHasRights() external view returns (bool);

    function fuseAdminHasRights() external view returns (bool);


    function oracle() external view returns (PriceOracle);

    function closeFactorMantissa() external view returns (uint);

    function liquidationIncentiveMantissa() external view returns (uint);


    function markets(address cToken) external view returns (bool, uint);


    function getAssetsIn(address account) external view returns (CToken[] memory);

    function checkMembership(address account, CToken cToken) external view returns (bool);

    function getAccountLiquidity(address account) external view returns (uint, uint, uint);


    function _setPriceOracle(PriceOracle newOracle) external returns (uint);

    function _setCloseFactor(uint newCloseFactorMantissa) external returns (uint256);

    function _setLiquidationIncentive(uint newLiquidationIncentiveMantissa) external returns (uint);

    function _become(Unitroller unitroller) external;


    function borrowGuardianPaused(address cToken) external view returns (bool);


    function getRewardsDistributors() external view returns (RewardsDistributor[] memory);

    function getAllMarkets() external view returns (CToken[] memory);

    function getAllBorrowers() external view returns (address[] memory);

    function suppliers(address account) external view returns (bool);

    function enforceWhitelist() external view returns (bool);

    function whitelist(address account) external view returns (bool);


    function _setWhitelistEnforcement(bool enforce) external returns (uint);

    function _setWhitelistStatuses(address[] calldata _suppliers, bool[] calldata statuses) external returns (uint);


    function _toggleAutoImplementations(bool enabled) external returns (uint);

}// UNLICENSED
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;



contract FusePoolDirectory is OwnableUpgradeable {

    function initialize(bool _enforceDeployerWhitelist, address[] memory _deployerWhitelist) public initializer {

        __Ownable_init();
        enforceDeployerWhitelist = _enforceDeployerWhitelist;
        for (uint256 i = 0; i < _deployerWhitelist.length; i++) deployerWhitelist[_deployerWhitelist[i]] = true;
    }

    struct FusePool {
        string name;
        address creator;
        address comptroller;
        uint256 blockPosted;
        uint256 timestampPosted;
    }

    FusePool[] public pools;

    mapping(address => uint256[]) private _poolsByAccount;

    mapping(address => bool) public poolExists;

    event PoolRegistered(uint256 index, FusePool pool);

    bool public enforceDeployerWhitelist;

    mapping(address => bool) public deployerWhitelist;

    function _setDeployerWhitelistEnforcement(bool enforce) external onlyOwner {

        enforceDeployerWhitelist = enforce;
    }

    function _editDeployerWhitelist(address[] calldata deployers, bool status) external onlyOwner {

        require(deployers.length > 0, "No deployers supplied.");
        for (uint256 i = 0; i < deployers.length; i++) deployerWhitelist[deployers[i]] = status;
    }

    function _registerPool(string memory name, address comptroller) internal returns (uint256) {

        require(!poolExists[comptroller], "Pool already exists in the directory.");
        require(!enforceDeployerWhitelist || deployerWhitelist[msg.sender], "Sender is not on deployer whitelist.");
        require(bytes(name).length <= 100, "No pool name supplied.");
        FusePool memory pool = FusePool(name, msg.sender, comptroller, block.number, block.timestamp);
        pools.push(pool);
        _poolsByAccount[msg.sender].push(pools.length - 1);
        poolExists[comptroller] = true;
        emit PoolRegistered(pools.length - 1, pool);
        return pools.length - 1;
    }

    function deployPool(string memory name, address implementation, bool enforceWhitelist, uint256 closeFactor, uint256 liquidationIncentive, address priceOracle) external returns (uint256, address) {

        require(implementation != address(0), "No Comptroller implementation contract address specified.");
        require(priceOracle != address(0), "No PriceOracle contract address specified.");

        bytes memory unitrollerCreationCode = hex"60806040526001805460ff60a81b1960ff60a01b19909116600160a01b1716600160a81b17905534801561003257600080fd5b50600080546001600160a01b03191633179055610ae1806100546000396000f3fe6080604052600436106100a75760003560e01c8063bb82aa5e11610064578063bb82aa5e14610437578063c1e803341461044c578063dcfbc0c714610461578063e992a04114610476578063e9c714f2146104a9578063f851a440146104be576100a7565b80630225ab9d1461032b5780630a755ec21461036957806326782247146103925780632f1069ba146103c35780636f63af0b146103d8578063b71d1a0c14610404575b3330146102a85760408051600481526024810182526020810180516001600160e01b0316633757348b60e21b1781529151815160009360609330939092909182918083835b6020831061010b5780518252601f1990920191602091820191016100ec565b6001836020036101000a038019825116818451168082178552505050505050905001915050600060405180830381855afa9150503d806000811461016b576040519150601f19603f3d011682016040523d82523d6000602084013e610170565b606091505b5091509150600082156101975781806020019051602081101561019257600080fd5b505190505b80156102a4576002546040805163bbcdd6d360e01b81526001600160a01b0390921660048301525160009173a731585ab05fc9f83555cf9bff8f58ee94e18f859163bbcdd6d391602480820192602092909190829003018186803b1580156101fe57600080fd5b505afa158015610212573d6000803e3d6000fd5b505050506040513d602081101561022857600080fd5b50516002549091506001600160a01b038083169116146102a257600280546001600160a01b038381166001600160a01b0319831617928390556040805192821680845293909116602083015280517fd604de94d45953f9138079ec1b82d533cb2160c906d1076d1f7ed54befbca97a9281900390910190a1505b505b5050505b6002546040516000916001600160a01b031690829036908083838082843760405192019450600093509091505080830381855af49150503d806000811461030b576040519150601f19603f3d011682016040523d82523d6000602084013e610310565b606091505b505090506040513d6000823e818015610327573d82f35b3d82fd5b34801561033757600080fd5b506103576004803603602081101561034e57600080fd5b503515156104d3565b60408051918252519081900360200190f35b34801561037557600080fd5b5061037e61056f565b604080519115158252519081900360200190f35b34801561039e57600080fd5b506103a761057f565b604080516001600160a01b039092168252519081900360200190f35b3480156103cf57600080fd5b5061037e61058e565b3480156103e457600080fd5b50610357600480360360208110156103fb57600080fd5b5035151561059e565b34801561041057600080fd5b506103576004803603602081101561042757600080fd5b50356001600160a01b031661063a565b34801561044357600080fd5b506103a76106bd565b34801561045857600080fd5b506103576106cc565b34801561046d57600080fd5b506103a76107c7565b34801561048257600080fd5b506103576004803603602081101561049957600080fd5b50356001600160a01b03166107d6565b3480156104b557600080fd5b506103576108f6565b3480156104ca57600080fd5b506103a76109dc565b60006104dd6109eb565b6104f4576104ed60016005610a46565b905061056a565b60015460ff600160a81b90910416151582151514156105145760006104ed565b60018054831515600160a81b810260ff60a81b199092169190911790915560408051918252517f10f9a0a95673b0837d1dce21fd3bffcb6d760435e9b5300b75a271182f75f8229181900360200190a160005b90505b919050565b600154600160a81b900460ff1681565b6001546001600160a01b031681565b600154600160a01b900460ff1681565b60006105a86109eb565b6105b8576104ed60016005610a46565b60015460ff600160a01b90910416151582151514156105d85760006104ed565b60018054831515600160a01b90810260ff60a01b199092169190911791829055604080519190920460ff161515815290517fabb56a15fd39488c914b324690b88f30d7daec63d2131ca0ef47e5739068c86e9181900360200190a16000610567565b60006106446109eb565b610654576104ed60016010610a46565b600180546001600160a01b038481166001600160a01b0319831681179093556040805191909216808252602082019390935281517fca4f2f25d0898edd99413412fb94012f9e54ec8142f9b093e7720646a95b16a9929181900390910190a160005b9392505050565b6002546001600160a01b031681565b6003546000906001600160a01b0316331415806106f257506003546001600160a01b0316155b1561070957610702600180610a46565b90506107c4565b60028054600380546001600160a01b038082166001600160a01b031980861682179687905590921690925560408051938316808552949092166020840152815190927fd604de94d45953f9138079ec1b82d533cb2160c906d1076d1f7ed54befbca97a92908290030190a1600354604080516001600160a01b038085168252909216602083015280517fe945ccee5d701fc83f9b8aa8ca94ea4219ec1fcbd4f4cab4f0ea57c5c3e1d8159281900390910190a160005b925050505b90565b6003546001600160a01b031681565b60006107e06109eb565b6107f0576104ed60016012610a46565b60025460408051639d244f9f60e01b81526001600160a01b03928316600482015291841660248301525173a731585ab05fc9f83555cf9bff8f58ee94e18f8591639d244f9f916044808301926020929190829003018186803b15801561085557600080fd5b505afa158015610869573d6000803e3d6000fd5b505050506040513d602081101561087f57600080fd5b5051610891576104ed60016011610a46565b600380546001600160a01b038481166001600160a01b0319831617928390556040805192821680845293909116602083015280517fe945ccee5d701fc83f9b8aa8ca94ea4219ec1fcbd4f4cab4f0ea57c5c3e1d8159281900390910190a160006106b6565b6001546000906001600160a01b031633141580610911575033155b156109225761070260016000610a46565b60008054600180546001600160a01b038082166001600160a01b031980861682179687905590921690925560408051938316808552949092166020840152815190927ff9ffabca9c8276e99321725bcb43fb076a6c66a54b7f21c4e8146d8519b417dc92908290030190a1600154604080516001600160a01b038085168252909216602083015280517fca4f2f25d0898edd99413412fb94012f9e54ec8142f9b093e7720646a95b16a99281900390910190a160006107bf565b6000546001600160a01b031681565b600080546001600160a01b031633148015610a0f5750600154600160a81b900460ff165b80610a4157503373a731585ab05fc9f83555cf9bff8f58ee94e18f85148015610a415750600154600160a01b900460ff165b905090565b60007f45b96fe442630264581b197e84bbada861235052c5a1aadfff9ea4e40a969aa0836015811115610a7557fe5b83601b811115610a8157fe5b604080519283526020830191909152600082820152519081900360600190a18260158111156106b657fefea265627a7a72315820a5cf9491a370c17ee98b3c08c728cc0ddad83bd43ca76c92dc106835bfccb25664736f6c63430005110032";
        bytes32 salt = keccak256(abi.encodePacked(msg.sender, name, block.number));
        address proxy;

        assembly {
            proxy := create2(0, add(unitrollerCreationCode, 32), mload(unitrollerCreationCode), salt)
            if iszero(extcodesize(proxy)) {
                revert(0, "Failed to deploy Unitroller.")
            }
        }

        Unitroller unitroller = Unitroller(proxy);
        require(unitroller._setPendingImplementation(implementation) == 0, "Failed to set pending implementation on Unitroller."); // Checks Comptroller implementation whitelist
        Comptroller comptrollerImplementation = Comptroller(implementation);
        comptrollerImplementation._become(unitroller);
        Comptroller comptrollerProxy = Comptroller(proxy);

        require(comptrollerProxy._setCloseFactor(closeFactor) == 0, "Failed to set pool close factor.");
        require(comptrollerProxy._setLiquidationIncentive(liquidationIncentive) == 0, "Failed to set pool liquidation incentive.");
        require(comptrollerProxy._setPriceOracle(PriceOracle(priceOracle)) == 0, "Failed to set pool price oracle.");

        if (enforceWhitelist) require(comptrollerProxy._setWhitelistEnforcement(true) == 0, "Failed to enforce supplier/borrower whitelist.");

        require(comptrollerProxy._toggleAutoImplementations(true) == 0, "Failed to enable pool auto implementations.");

        require(unitroller._setPendingAdmin(msg.sender) == 0, "Failed to set pending admin on Unitroller.");

        return (_registerPool(name, proxy), proxy);
    }

    function getAllPools() external view returns (FusePool[] memory) {

        return pools;
    }

    function getPublicPools() external view returns (uint256[] memory, FusePool[] memory) {

        uint256 arrayLength = 0;

        for (uint256 i = 0; i < pools.length; i++) {
            try Comptroller(pools[i].comptroller).enforceWhitelist() returns (bool enforceWhitelist) {
                if (enforceWhitelist) continue;
            } catch { }

            arrayLength++;
        }

        uint256[] memory indexes = new uint256[](arrayLength);
        FusePool[] memory publicPools = new FusePool[](arrayLength);
        uint256 index = 0;

        for (uint256 i = 0; i < pools.length; i++) {
            try Comptroller(pools[i].comptroller).enforceWhitelist() returns (bool enforceWhitelist) {
                if (enforceWhitelist) continue;
            } catch { }

            indexes[index] = i;
            publicPools[index] = pools[i];
            index++;
        }

        return (indexes, publicPools);
    }

    function getPoolsByAccount(address account) external view returns (uint256[] memory, FusePool[] memory) {
        uint256[] memory indexes = new uint256[](_poolsByAccount[account].length);
        FusePool[] memory accountPools = new FusePool[](_poolsByAccount[account].length);

        for (uint256 i = 0; i < _poolsByAccount[account].length; i++) {
            indexes[i] = _poolsByAccount[account][i];
            accountPools[i] = pools[_poolsByAccount[account][i]];
        }

        return (indexes, accountPools);
    }

    mapping(address => address[]) private _bookmarks;

    function getBookmarks(address account) external view returns (address[] memory) {
        return _bookmarks[account];
    }

    function bookmarkPool(address comptroller) external {
        _bookmarks[msg.sender].push(comptroller);
    }

    function setPoolName(uint256 index, string calldata name) external {
        Comptroller _comptroller = Comptroller(pools[index].comptroller);
        require(msg.sender == _comptroller.admin() && _comptroller.adminHasRights() || msg.sender == owner());
        pools[index].name = name;
    }

    mapping(address => bool) public adminWhitelist;

    event AdminWhitelistUpdated(address[] admins, bool status);

    function _editAdminWhitelist(address[] calldata admins, bool status) external onlyOwner {
        require(admins.length > 0, "No admins supplied.");
        for (uint256 i = 0; i < admins.length; i++) adminWhitelist[admins[i]] = status;
        emit AdminWhitelistUpdated(admins, status);
    }

    function getPublicPoolsByVerification(bool whitelistedAdmin) external view returns (uint256[] memory, FusePool[] memory) {
        uint256 arrayLength = 0;

        for (uint256 i = 0; i < pools.length; i++) {
            Comptroller comptroller = Comptroller(pools[i].comptroller);

            try comptroller.enforceWhitelist() returns (bool enforceWhitelist) {
                if (enforceWhitelist) continue;

                try comptroller.admin() returns (address admin) {
                    if (whitelistedAdmin != adminWhitelist[admin]) continue;
                } catch { }
            } catch { }

            arrayLength++;
        }

        uint256[] memory indexes = new uint256[](arrayLength);
        FusePool[] memory publicPools = new FusePool[](arrayLength);
        uint256 index = 0;

        for (uint256 i = 0; i < pools.length; i++) {
            Comptroller comptroller = Comptroller(pools[i].comptroller);

            try comptroller.enforceWhitelist() returns (bool enforceWhitelist) {
                if (enforceWhitelist) continue;

                try comptroller.admin() returns (address admin) {
                    if (whitelistedAdmin != adminWhitelist[admin]) continue;
                } catch { }
            } catch { }

            indexes[index] = i;
            publicPools[index] = pools[i];
            index++;
        }

        return (indexes, publicPools);
    }
}