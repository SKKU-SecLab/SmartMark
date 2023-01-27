

pragma solidity 0.5.16;

interface IContractRegistry {


	event ContractAddressUpdated(string contractName, address addr);

	function set(string calldata contractName, address addr) external /* onlyGovernor */;


	function get(string calldata contractName) external view returns (address);

}


pragma solidity 0.5.16;


interface ICommittee {

	event GuardianCommitteeChange(address addr, uint256 weight, bool certification, bool inCommittee);
	event CommitteeSnapshot(address[] addrs, uint256[] weights, bool[] certification);



	function memberWeightChange(address addr, uint256 weight) external returns (bool committeeChanged) /* onlyElectionContract */;


	function memberCertificationChange(address addr, bool isCertified) external returns (bool committeeChanged) /* onlyElectionsContract */;


	function removeMember(address addr) external returns (bool committeeChanged) /* onlyElectionContract */;


	function addMember(address addr, uint256 weight, bool isCertified) external returns (bool committeeChanged) /* onlyElectionsContract */;


	function getCommittee() external view returns (address[] memory addrs, uint256[] memory weights, bool[] memory certification);



	function setMaxTimeBetweenRewardAssignments(uint32 maxTimeBetweenRewardAssignments) external /* onlyFunctionalOwner onlyWhenActive */;

	function setMaxCommittee(uint8 maxCommitteeSize) external /* onlyFunctionalOwner onlyWhenActive */;


	event MaxTimeBetweenRewardAssignmentsChanged(uint32 newValue, uint32 oldValue);
	event MaxCommitteeSizeChanged(uint8 newValue, uint8 oldValue);

	function setContractRegistry(IContractRegistry _contractRegistry) external /* onlyMigrationOwner */;



	function getCommitteeInfo() external view returns (address[] memory addrs, uint256[] memory weights, address[] memory orbsAddrs, bool[] memory certification, bytes4[] memory ips);


	function getSettings() external view returns (uint32 maxTimeBetweenRewardAssignments, uint8 maxCommitteeSize);

}


pragma solidity 0.5.16;


interface IGuardiansRegistration {

	event GuardianRegistered(address addr);
	event GuardianDataUpdated(address addr, bytes4 ip, address orbsAddr, string name, string website, string contact);
	event GuardianUnregistered(address addr);
	event GuardianMetadataChanged(address addr, string key, string newValue, string oldValue);


	function registerGuardian(bytes4 ip, address orbsAddr, string calldata name, string calldata website, string calldata contact) external;


	function updateGuardian(bytes4 ip, address orbsAddr, string calldata name, string calldata website, string calldata contact) external;


	function updateGuardianIp(bytes4 ip) external /* onlyWhenActive */;


    function setMetadata(string calldata key, string calldata value) external;


    function getMetadata(address addr, string calldata key) external view returns (string memory);


	function unregisterGuardian() external;


	function getGuardianData(address addr) external view returns (bytes4 ip, address orbsAddr, string memory name, string memory website, string memory contact, uint registration_time, uint last_update_time);


	function getGuardiansOrbsAddress(address[] calldata addrs) external view returns (address[] memory orbsAddrs);


	function getGuardianIp(address addr) external view returns (bytes4 ip);


	function getGuardianIps(address[] calldata addr) external view returns (bytes4[] memory ips);



	function isRegistered(address addr) external view returns (bool);



	function getOrbsAddresses(address[] calldata ethereumAddrs) external view returns (address[] memory orbsAddr);


	function getEthereumAddresses(address[] calldata orbsAddrs) external view returns (address[] memory ethereumAddr);


	function resolveGuardianAddress(address ethereumOrOrbsAddress) external view returns (address mainAddress);


}


pragma solidity ^0.5.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


pragma solidity 0.5.16;

interface IProtocol {

    event ProtocolVersionChanged(string deploymentSubset, uint256 currentVersion, uint256 nextVersion, uint256 fromTimestamp);


    function deploymentSubsetExists(string calldata deploymentSubset) external view returns (bool);


    function getProtocolVersion(string calldata deploymentSubset) external view returns (uint256);



    function createDeploymentSubset(string calldata deploymentSubset, uint256 initialProtocolVersion) external /* onlyFunctionalOwner */;


    function setProtocolVersion(string calldata deploymentSubset, uint256 nextVersion, uint256 fromTimestamp) external /* onlyFunctionalOwner */;

}


pragma solidity 0.5.16;

interface IStakeChangeNotifier {

    function stakeChange(address _stakeOwner, uint256 _amount, bool _sign, uint256 _updatedStake) external;


    function stakeChangeBatch(address[] calldata _stakeOwners, uint256[] calldata _amounts, bool[] calldata _signs,
        uint256[] calldata _updatedStakes) external;


    function stakeMigration(address _stakeOwner, uint256 _amount) external;

}


pragma solidity 0.5.16;



interface IElections /* is IStakeChangeNotifier */ {

	event GuardianVotedUnready(address guardian);
	event GuardianVotedOut(address guardian);

	event VoteUnreadyCasted(address voter, address subject);
	event VoteOutCasted(address voter, address subject);
	event StakeChanged(address addr, uint256 selfStake, uint256 delegated_stake, uint256 effective_stake);

	event GuardianStatusUpdated(address addr, bool readyToSync, bool readyForCommittee);

	event VoteUnreadyTimeoutSecondsChanged(uint32 newValue, uint32 oldValue);
	event MinSelfStakePercentMilleChanged(uint32 newValue, uint32 oldValue);
	event VoteOutPercentageThresholdChanged(uint8 newValue, uint8 oldValue);
	event VoteUnreadyPercentageThresholdChanged(uint8 newValue, uint8 oldValue);


	function voteUnready(address subject_addr) external;


	function voteOut(address subjectAddr) external;


	function readyToSync() external;


	function readyForCommittee() external;



	function delegatedStakeChange(address addr, uint256 selfStake, uint256 delegatedStake, uint256 totalDelegatedStake) external /* onlyDelegationContract */;


	function guardianRegistered(address addr) external /* onlyGuardiansRegistrationContract */;


	function guardianUnregistered(address addr) external /* onlyGuardiansRegistrationContract */;


	function guardianCertificationChanged(address addr, bool isCertified) external /* onlyCertificationContract */;



	function setContractRegistry(IContractRegistry _contractRegistry) external /* onlyMigrationOwner */;


	function setVoteUnreadyTimeoutSeconds(uint32 voteUnreadyTimeoutSeconds) external /* onlyFunctionalOwner onlyWhenActive */;

	function setMinSelfStakePercentMille(uint32 minSelfStakePercentMille) external /* onlyFunctionalOwner onlyWhenActive */;

	function setVoteOutPercentageThreshold(uint8 voteUnreadyPercentageThreshold) external /* onlyFunctionalOwner onlyWhenActive */;

	function setVoteUnreadyPercentageThreshold(uint8 voteUnreadyPercentageThreshold) external /* onlyFunctionalOwner onlyWhenActive */;

	function getSettings() external view returns (
		uint32 voteUnreadyTimeoutSeconds,
		uint32 minSelfStakePercentMille,
		uint8 voteUnreadyPercentageThreshold,
		uint8 voteOutPercentageThreshold
	);

}


pragma solidity 0.5.16;



interface ICertification /* is Ownable */ {

	event GuardianCertificationUpdate(address guardian, bool isCertified);


	function isGuardianCertified(address addr) external view returns (bool isCertified);


	function setGuardianCertification(address addr, bool isCertified) external /* Owner only */ ;



	function setContractRegistry(IContractRegistry _contractRegistry) external /* onlyMigrationOwner */;


}


pragma solidity 0.5.16;


interface ISubscriptions {

    event SubscriptionChanged(uint256 vcid, uint256 genRefTime, uint256 expiresAt, string tier, string deploymentSubset);
    event Payment(uint256 vcid, address by, uint256 amount, string tier, uint256 rate);
    event VcConfigRecordChanged(uint256 vcid, string key, string value);
    event SubscriberAdded(address subscriber);
    event VcCreated(uint256 vcid, address owner); // TODO what about isCertified, deploymentSubset?
    event VcOwnerChanged(uint256 vcid, address previousOwner, address newOwner);


    function createVC(string calldata tier, uint256 rate, uint256 amount, address owner, bool isCertified, string calldata deploymentSubset) external returns (uint, uint);


    function extendSubscription(uint256 vcid, uint256 amount, address payer) external;


    function setVcConfigRecord(uint256 vcid, string calldata key, string calldata value) external /* onlyVcOwner */;


    function getVcConfigRecord(uint256 vcid, string calldata key) external view returns (string memory);


    function setVcOwner(uint256 vcid, address owner) external /* onlyVcOwner */;


    function getGenesisRefTimeDelay() external view returns (uint256);



    function addSubscriber(address addr) external /* onlyFunctionalOwner */;


    function setGenesisRefTimeDelay(uint256 newGenesisRefTimeDelay) external /* onlyFunctionalOwner */;


    function setContractRegistry(IContractRegistry _contractRegistry) external /* onlyMigrationOwner */;


}


pragma solidity 0.5.16;


interface IDelegations /* is IStakeChangeNotifier */ {

	event DelegatedStakeChanged(address indexed addr, uint256 selfDelegatedStake, uint256 delegatedStake, address[] delegators, uint256[] delegatorTotalStakes);

	event Delegated(address indexed from, address indexed to);


	function delegate(address to) external /* onlyWhenActive */;


	function refreshStakeNotification(address addr) external /* onlyWhenActive */;



	function setContractRegistry(IContractRegistry _contractRegistry) external /* onlyMigrationOwner */;


	function importDelegations(address[] calldata from, address[] calldata to, bool notifyElections) external /* onlyMigrationOwner onlyDuringDelegationImport */;

	function finalizeDelegationImport() external /* onlyMigrationOwner onlyDuringDelegationImport */;


	event DelegationsImported(address[] from, address[] to, bool notifiedElections);
	event DelegationImportFinalized();


	function getDelegatedStakes(address addr) external view returns (uint256);

	function getSelfDelegatedStake(address addr) external view returns (uint256);

	function getDelegation(address addr) external view returns (address);

	function getTotalDelegatedStake() external view returns (uint256) ;



}


pragma solidity ^0.5.0;

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


pragma solidity 0.5.16;


interface IMigratableStakingContract {

    function getToken() external view returns (IERC20);


    function acceptMigration(address _stakeOwner, uint256 _amount) external;


    event AcceptedMigration(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
}


pragma solidity 0.5.16;


interface IStakingContract {

    function stake(uint256 _amount) external;


    function unstake(uint256 _amount) external;


    function withdraw() external;


    function restake() external;


    function distributeRewards(uint256 _totalAmount, address[] calldata _stakeOwners, uint256[] calldata _amounts) external;


    function getStakeBalanceOf(address _stakeOwner) external view returns (uint256);


    function getTotalStakedTokens() external view returns (uint256);


    function getUnstakeStatus(address _stakeOwner) external view returns (uint256 cooldownAmount,
        uint256 cooldownEndTime);


    function migrateStakedTokens(IMigratableStakingContract _newStakingContract, uint256 _amount) external;


    event Staked(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
    event Unstaked(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
    event Withdrew(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
    event Restaked(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
    event MigratedStake(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
}


pragma solidity 0.5.16;



interface IRewards {


    function assignRewards() external;

    function assignRewardsToCommittee(address[] calldata generalCommittee, uint256[] calldata generalCommitteeWeights, bool[] calldata certification) external /* onlyCommitteeContract */;



    event StakingRewardsDistributed(address indexed distributer, uint256 fromBlock, uint256 toBlock, uint split, uint txIndex, address[] to, uint256[] amounts);
    event StakingRewardsAssigned(address[] assignees, uint256[] amounts); // todo balance?
    event StakingRewardsAddedToPool(uint256 added, uint256 total);
    event MaxDelegatorsStakingRewardsChanged(uint32 maxDelegatorsStakingRewardsPercentMille);

    function getStakingRewardBalance(address addr) external view returns (uint256 balance);


    function distributeOrbsTokenStakingRewards(uint256 totalAmount, uint256 fromBlock, uint256 toBlock, uint split, uint txIndex, address[] calldata to, uint256[] calldata amounts) external;


    function topUpStakingRewardsPool(uint256 amount) external;



    function setAnnualStakingRewardsRate(uint256 annual_rate_in_percent_mille, uint256 annual_cap) external /* onlyFunctionalOwner */;




    event FeesAssigned(uint256 generalGuardianAmount, uint256 certifiedGuardianAmount);
    event FeesWithdrawn(address guardian, uint256 amount);
    event FeesWithdrawnFromBucket(uint256 bucketId, uint256 withdrawn, uint256 total, bool isCertified);
    event FeesAddedToBucket(uint256 bucketId, uint256 added, uint256 total, bool isCertified);


    function getFeeBalance(address addr) external view returns (uint256 balance);


    function withdrawFeeFunds() external;


    function fillCertificationFeeBuckets(uint256 amount, uint256 monthlyRate, uint256 fromTimestamp) external;


    function fillGeneralFeeBuckets(uint256 amount, uint256 monthlyRate, uint256 fromTimestamp) external;


    function getTotalBalances() external view returns (uint256 feesTotalBalance, uint256 stakingRewardsTotalBalance, uint256 bootstrapRewardsTotalBalance);



    event BootstrapRewardsAssigned(uint256 generalGuardianAmount, uint256 certifiedGuardianAmount);
    event BootstrapAddedToPool(uint256 added, uint256 total);
    event BootstrapRewardsWithdrawn(address guardian, uint256 amount);


    function getBootstrapBalance(address addr) external view returns (uint256 balance);


    function withdrawBootstrapFunds() external;


    function getLastRewardAssignmentTime() external view returns (uint256 time);


    function topUpBootstrapPool(uint256 amount) external;



    function setGeneralCommitteeAnnualBootstrap(uint256 annual_amount) external /* onlyFunctionalOwner */;


    function setCertificationCommitteeAnnualBootstrap(uint256 annual_amount) external /* onlyFunctionalOwner */;


    event EmergencyWithdrawal(address addr);

    function emergencyWithdraw() external /* onlyMigrationManager */;



    function setContractRegistry(IContractRegistry _contractRegistry) external /* onlyMigrationOwner */;



}


pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity 0.5.16;


contract WithClaimableMigrationOwnership is Context{

    address private _migrationOwner;
    address pendingMigrationOwner;

    event MigrationOwnershipTransferred(address indexed previousMigrationOwner, address indexed newMigrationOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _migrationOwner = msgSender;
        emit MigrationOwnershipTransferred(address(0), msgSender);
    }

    function migrationOwner() public view returns (address) {

        return _migrationOwner;
    }

    modifier onlyMigrationOwner() {

        require(isMigrationOwner(), "WithClaimableMigrationOwnership: caller is not the migrationOwner");
        _;
    }

    function isMigrationOwner() public view returns (bool) {

        return _msgSender() == _migrationOwner;
    }

    function renounceMigrationOwnership() public onlyMigrationOwner {

        emit MigrationOwnershipTransferred(_migrationOwner, address(0));
        _migrationOwner = address(0);
    }

    function _transferMigrationOwnership(address newMigrationOwner) internal {

        require(newMigrationOwner != address(0), "MigrationOwner: new migrationOwner is the zero address");
        emit MigrationOwnershipTransferred(_migrationOwner, newMigrationOwner);
        _migrationOwner = newMigrationOwner;
    }

    modifier onlyPendingMigrationOwner() {

        require(msg.sender == pendingMigrationOwner, "Caller is not the pending migrationOwner");
        _;
    }
    function transferMigrationOwnership(address newMigrationOwner) public onlyMigrationOwner {

        pendingMigrationOwner = newMigrationOwner;
    }
    function claimMigrationOwnership() external onlyPendingMigrationOwner {

        _transferMigrationOwnership(pendingMigrationOwner);
        pendingMigrationOwner = address(0);
    }
}


pragma solidity 0.5.16;



contract Lockable is WithClaimableMigrationOwnership {


    bool public locked;

    event Locked();
    event Unlocked();

    function lock() external onlyMigrationOwner {

        locked = true;
        emit Locked();
    }

    function unlock() external onlyMigrationOwner {

        locked = false;
        emit Unlocked();
    }

    modifier onlyWhenActive() {

        require(!locked, "contract is locked for this operation");

        _;
    }
}


pragma solidity 0.5.16;



pragma solidity 0.5.16;

interface IProtocolWallet {

    event FundsAddedToPool(uint256 added, uint256 total);
    event ClientSet(address client);
    event MaxAnnualRateSet(uint256 maxAnnualRate);
    event EmergencyWithdrawal(address addr);

    function getToken() external view returns (IERC20);


    function getBalance() external view returns (uint256 balance);


    function topUp(uint256 amount) external;


    function withdraw(uint256 amount) external; /* onlyClient */


    function setMaxAnnualRate(uint256 annual_rate) external; /* onlyMigrationManager */


    function emergencyWithdraw() external; /* onlyMigrationManager */


    function setClient(address client) external; /* onlyFunctionalManager */

}


pragma solidity 0.5.16;













contract ContractRegistryAccessor is WithClaimableMigrationOwnership {


    IContractRegistry contractRegistry;

    event ContractRegistryAddressUpdated(address addr);

    function setContractRegistry(IContractRegistry _contractRegistry) external onlyMigrationOwner {

        contractRegistry = _contractRegistry;
        emit ContractRegistryAddressUpdated(address(_contractRegistry));
    }

    function getProtocolContract() public view returns (IProtocol) {

        return IProtocol(contractRegistry.get("protocol"));
    }

    function getRewardsContract() public view returns (IRewards) {

        return IRewards(contractRegistry.get("rewards"));
    }

    function getCommitteeContract() public view returns (ICommittee) {

        return ICommittee(contractRegistry.get("committee"));
    }

    function getElectionsContract() public view returns (IElections) {

        return IElections(contractRegistry.get("elections"));
    }

    function getDelegationsContract() public view returns (IDelegations) {

        return IDelegations(contractRegistry.get("delegations"));
    }

    function getGuardiansRegistrationContract() public view returns (IGuardiansRegistration) {

        return IGuardiansRegistration(contractRegistry.get("guardiansRegistration"));
    }

    function getCertificationContract() public view returns (ICertification) {

        return ICertification(contractRegistry.get("certification"));
    }

    function getStakingContract() public view returns (IStakingContract) {

        return IStakingContract(contractRegistry.get("staking"));
    }

    function getSubscriptionsContract() public view returns (ISubscriptions) {

        return ISubscriptions(contractRegistry.get("subscriptions"));
    }

    function getStakingRewardsWallet() public view returns (IProtocolWallet) {

        return IProtocolWallet(contractRegistry.get("stakingRewardsWallet"));
    }

    function getBootstrapRewardsWallet() public view returns (IProtocolWallet) {

        return IProtocolWallet(contractRegistry.get("bootstrapRewardsWallet"));
    }

}


pragma solidity 0.5.16;


contract WithClaimableFunctionalOwnership is Context{

    address private _functionalOwner;
    address pendingFunctionalOwner;

    event FunctionalOwnershipTransferred(address indexed previousFunctionalOwner, address indexed newFunctionalOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _functionalOwner = msgSender;
        emit FunctionalOwnershipTransferred(address(0), msgSender);
    }

    function functionalOwner() public view returns (address) {

        return _functionalOwner;
    }

    modifier onlyFunctionalOwner() {

        require(isFunctionalOwner(), "WithClaimableFunctionalOwnership: caller is not the functionalOwner");
        _;
    }

    function isFunctionalOwner() public view returns (bool) {

        return _msgSender() == _functionalOwner;
    }

    function renounceFunctionalOwnership() public onlyFunctionalOwner {

        emit FunctionalOwnershipTransferred(_functionalOwner, address(0));
        _functionalOwner = address(0);
    }

    function _transferFunctionalOwnership(address newFunctionalOwner) internal {

        require(newFunctionalOwner != address(0), "FunctionalOwner: new functionalOwner is the zero address");
        emit FunctionalOwnershipTransferred(_functionalOwner, newFunctionalOwner);
        _functionalOwner = newFunctionalOwner;
    }

    modifier onlyPendingFunctionalOwner() {

        require(msg.sender == pendingFunctionalOwner, "Caller is not the pending functionalOwner");
        _;
    }
    function transferFunctionalOwnership(address newFunctionalOwner) public onlyFunctionalOwner {

        pendingFunctionalOwner = newFunctionalOwner;
    }
    function claimFunctionalOwnership() external onlyPendingFunctionalOwner {

        _transferFunctionalOwnership(pendingFunctionalOwner);
        pendingFunctionalOwner = address(0);
    }
}



pragma solidity ^0.5.0;


library BytesLib {

    function concat(
        bytes memory _preBytes,
        bytes memory _postBytes
    )
        internal
        pure
        returns (bytes memory)
    {

        bytes memory tempBytes;

        assembly {
            tempBytes := mload(0x40)

            let length := mload(_preBytes)
            mstore(tempBytes, length)

            let mc := add(tempBytes, 0x20)
            let end := add(mc, length)

            for {
                let cc := add(_preBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            length := mload(_postBytes)
            mstore(tempBytes, add(length, mload(tempBytes)))

            mc := end
            end := add(mc, length)

            for {
                let cc := add(_postBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            mstore(0x40, and(
              add(add(end, iszero(add(length, mload(_preBytes)))), 31),
              not(31) // Round down to the nearest 32 bytes.
            ))
        }

        return tempBytes;
    }

    function concatStorage(bytes storage _preBytes, bytes memory _postBytes) internal {

        assembly {
            let fslot := sload(_preBytes_slot)
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)
            let newlength := add(slength, mlength)
            switch add(lt(slength, 32), lt(newlength, 32))
            case 2 {
                sstore(
                    _preBytes_slot,
                    add(
                        fslot,
                        add(
                            mul(
                                div(
                                    mload(add(_postBytes, 0x20)),
                                    exp(0x100, sub(32, mlength))
                                ),
                                exp(0x100, sub(32, newlength))
                            ),
                            mul(mlength, 2)
                        )
                    )
                )
            }
            case 1 {
                mstore(0x0, _preBytes_slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                sstore(_preBytes_slot, add(mul(newlength, 2), 1))


                let submod := sub(32, slength)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(
                    sc,
                    add(
                        and(
                            fslot,
                            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00
                        ),
                        and(mload(mc), mask)
                    )
                )

                for {
                    mc := add(mc, 0x20)
                    sc := add(sc, 1)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
            default {
                mstore(0x0, _preBytes_slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                sstore(_preBytes_slot, add(mul(newlength, 2), 1))

                let slengthmod := mod(slength, 32)
                let mlengthmod := mod(mlength, 32)
                let submod := sub(32, slengthmod)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(sc, add(sload(sc), and(mload(mc), mask)))
                
                for { 
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
        }
    }

    function slice(
        bytes memory _bytes,
        uint _start,
        uint _length
    )
        internal
        pure
        returns (bytes memory)
    {

        require(_bytes.length >= (_start + _length));

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                tempBytes := mload(0x40)

                let lengthmod := and(_length, 31)

                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                mstore(0x40, and(add(mc, 31), not(31)))
            }
            default {
                tempBytes := mload(0x40)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function toAddress(bytes memory _bytes, uint _start) internal  pure returns (address) {

        require(_bytes.length >= (_start + 20));
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint8(bytes memory _bytes, uint _start) internal  pure returns (uint8) {

        require(_bytes.length >= (_start + 1));
        uint8 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }

        return tempUint;
    }

    function toUint16(bytes memory _bytes, uint _start) internal  pure returns (uint16) {

        require(_bytes.length >= (_start + 2));
        uint16 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x2), _start))
        }

        return tempUint;
    }

    function toUint32(bytes memory _bytes, uint _start) internal  pure returns (uint32) {

        require(_bytes.length >= (_start + 4));
        uint32 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x4), _start))
        }

        return tempUint;
    }

    function toUint64(bytes memory _bytes, uint _start) internal  pure returns (uint64) {

        require(_bytes.length >= (_start + 8));
        uint64 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x8), _start))
        }

        return tempUint;
    }

    function toUint96(bytes memory _bytes, uint _start) internal  pure returns (uint96) {

        require(_bytes.length >= (_start + 12));
        uint96 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0xc), _start))
        }

        return tempUint;
    }

    function toUint128(bytes memory _bytes, uint _start) internal  pure returns (uint128) {

        require(_bytes.length >= (_start + 16));
        uint128 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x10), _start))
        }

        return tempUint;
    }

    function toUint(bytes memory _bytes, uint _start) internal  pure returns (uint256) {

        require(_bytes.length >= (_start + 32));
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    function toBytes32(bytes memory _bytes, uint _start) internal  pure returns (bytes32) {

        require(_bytes.length >= (_start + 32));
        bytes32 tempBytes32;

        assembly {
            tempBytes32 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes32;
    }

    function equal(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bool) {

        bool success = true;

        assembly {
            let length := mload(_preBytes)

            switch eq(length, mload(_postBytes))
            case 1 {
                let cb := 1

                let mc := add(_preBytes, 0x20)
                let end := add(mc, length)

                for {
                    let cc := add(_postBytes, 0x20)
                } eq(add(lt(mc, end), cb), 2) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    if iszero(eq(mload(mc), mload(cc))) {
                        success := 0
                        cb := 0
                    }
                }
            }
            default {
                success := 0
            }
        }

        return success;
    }

    function equalStorage(
        bytes storage _preBytes,
        bytes memory _postBytes
    )
        internal
        view
        returns (bool)
    {

        bool success = true;

        assembly {
            let fslot := sload(_preBytes_slot)
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)

            switch eq(slength, mlength)
            case 1 {
                if iszero(iszero(slength)) {
                    switch lt(slength, 32)
                    case 1 {
                        fslot := mul(div(fslot, 0x100), 0x100)

                        if iszero(eq(fslot, mload(add(_postBytes, 0x20)))) {
                            success := 0
                        }
                    }
                    default {
                        let cb := 1

                        mstore(0x0, _preBytes_slot)
                        let sc := keccak256(0x0, 0x20)

                        let mc := add(_postBytes, 0x20)
                        let end := add(mc, mlength)

                        for {} eq(add(lt(mc, end), cb), 2) {
                            sc := add(sc, 1)
                            mc := add(mc, 0x20)
                        } {
                            if iszero(eq(sload(sc), mload(mc))) {
                                success := 0
                                cb := 0
                            }
                        }
                    }
                }
            }
            default {
                success := 0
            }
        }

        return success;
    }
}


pragma solidity 0.5.16;







contract Committee is ICommittee, ContractRegistryAccessor, WithClaimableFunctionalOwnership, Lockable {

	using BytesLib for bytes;

	uint constant MAX_COMMITTEE_ARRAY_SIZE = 32; // Cannot be greater than 32 (number of bytes in bytes32)

	struct CommitteeMember {
		address addr;
		uint96 weight;
	}
	CommitteeMember[] public committee;

	struct MemberData {
		uint96 weight;
		uint8 pos;
		bool isMember;
		bool isCertified;

		bool inCommittee;
	}
	mapping (address => MemberData) membersData;

	struct CommitteeInfo {
		uint32 committeeBitmap; // TODO redundant, sort bytes can be used instead
		uint8 minCommitteeMemberPos;
		uint8 committeeSize;
	}
	CommitteeInfo committeeInfo;
	bytes32 committeeSortBytes;

	struct Settings {
		uint32 maxTimeBetweenRewardAssignments;
		uint8 maxCommitteeSize;
	}
	Settings settings;

	modifier onlyElectionsContract() {

		require(msg.sender == address(getElectionsContract()), "caller is not the elections");

		_;
	}

	function findFreePos(CommitteeInfo memory info) private pure returns (uint8 pos) {

		pos = 0;
		uint32 bitmap = info.committeeBitmap;
		while (bitmap & 1 == 1) {
			bitmap >>= 1;
			pos++;
		}
	}

	function qualifiesToEnterCommittee(address addr, MemberData memory data, CommitteeInfo memory info, Settings memory _settings) private view returns (bool qualified, uint8 entryPos) {

		if (!data.isMember || data.weight == 0) {
			return (false, 0);
		}

		if (info.committeeSize < _settings.maxCommitteeSize) {
			return (true, findFreePos(info));
		}

		CommitteeMember memory minMember = committee[info.minCommitteeMemberPos];
		if (data.weight < minMember.weight || data.weight == minMember.weight && addr < minMember.addr) {
			return (false, 0);
		}

		return (true, info.minCommitteeMemberPos);
	}

	function saveMemberData(address addr, MemberData memory data) private {

		if (data.isMember) {
			membersData[addr] = data;
		} else {
			delete membersData[addr];
		}
	}

	function updateOnMemberChange(address addr, MemberData memory data) private returns (bool committeeChanged) {

		CommitteeInfo memory info = committeeInfo;
		Settings memory _settings = settings;
		bytes memory sortBytes = abi.encodePacked(committeeSortBytes);

		if (!data.inCommittee) {
			(bool qualified, uint8 entryPos) = qualifiesToEnterCommittee(addr, data, info, _settings);
			if (!qualified) {
				saveMemberData(addr, data);
				return false;
			}

			(info, sortBytes) = removeMemberAtPos(entryPos, sortBytes, info);
			(info, sortBytes) = addToCommittee(addr, data, entryPos, sortBytes, info);
		}

		(info, sortBytes) = (data.isMember && data.weight > 0) ?
			rankMember(addr, data, sortBytes, info) :
			removeMemberFromCommittee(data, sortBytes, info);

		emit GuardianCommitteeChange(addr, data.weight, data.isCertified, data.inCommittee);

		saveMemberData(addr, data);

		committeeInfo = info;
		committeeSortBytes = sortBytes.toBytes32(0);

		assignRewardsIfNeeded(_settings);

		return true;
	}

	function addToCommittee(address addr, MemberData memory data, uint8 entryPos, bytes memory sortBytes, CommitteeInfo memory info) private returns (CommitteeInfo memory newInfo, bytes memory newSortByes) {

		committee[entryPos] = CommitteeMember({
			addr: addr,
			weight: data.weight
		});
		data.inCommittee = true;
		data.pos = entryPos;
		info.committeeBitmap |= uint32(uint(1) << entryPos);
		info.committeeSize++;

		sortBytes[info.committeeSize - 1] = byte(entryPos);
		return (info, sortBytes);
	}

	function removeMemberFromCommittee(MemberData memory data, bytes memory sortBytes, CommitteeInfo memory info) private returns (CommitteeInfo memory newInfo, bytes memory newSortBytes) {

		uint rank = 0;
		while (uint8(sortBytes[rank]) != data.pos) {
			rank++;
		}

		for (; rank < info.committeeSize - 1; rank++) {
			sortBytes[rank] = sortBytes[rank + 1];
		}
		sortBytes[rank] = 0;

		info.committeeSize--;
		if (info.committeeSize > 0) {
			info.minCommitteeMemberPos = uint8(sortBytes[info.committeeSize - 1]);
		}
		info.committeeBitmap &= ~uint32(uint(1) << data.pos);

		delete committee[data.pos];
		data.inCommittee = false;

		return (info, sortBytes);
	}

	function removeMemberAtPos(uint8 pos, bytes memory sortBytes, CommitteeInfo memory info) private returns (CommitteeInfo memory newInfo, bytes memory newSortBytes) {

		if (info.committeeBitmap & (uint(1) << pos) == 0) {
			return (info, sortBytes);
		}

		address addr = committee[pos].addr;
		MemberData memory data = membersData[addr];

		(newInfo, newSortBytes) = removeMemberFromCommittee(data, sortBytes, info);

		emit GuardianCommitteeChange(addr, data.weight, data.isCertified, false);

		membersData[addr] = data;
	}

	function rankMember(address addr, MemberData memory data, bytes memory sortBytes, CommitteeInfo memory info) private view returns (CommitteeInfo memory newInfo, bytes memory newSortBytes) {

		uint rank = 0;
		while (uint8(sortBytes[rank]) != data.pos) {
			rank++;
		}

		CommitteeMember memory cur = CommitteeMember({addr: addr, weight: data.weight});
		CommitteeMember memory next;

		while (rank < info.committeeSize - 1) {
			next = committee[uint8(sortBytes[rank + 1])];
			if (cur.weight > next.weight || cur.weight == next.weight && cur.addr > next.addr) break;

			(sortBytes[rank], sortBytes[rank + 1]) = (sortBytes[rank + 1], sortBytes[rank]);
			rank++;
		}

		while (rank > 0) {
			next = committee[uint8(sortBytes[rank - 1])];
			if (cur.weight < next.weight || cur.weight == next.weight && cur.addr < next.addr) break;

			(sortBytes[rank], sortBytes[rank - 1]) = (sortBytes[rank - 1], sortBytes[rank]);
			rank--;
		}

		info.minCommitteeMemberPos = uint8(sortBytes[info.committeeSize - 1]);
		return (info, sortBytes);
	}

	function getMinCommitteeMemberWeight() external view returns (uint96) {

		return committee[committeeInfo.minCommitteeMemberPos].weight;
	}

	function assignRewardsIfNeeded(Settings memory _settings) private {

        IRewards rewardsContract = getRewardsContract();
        uint lastAssignment = rewardsContract.getLastRewardAssignmentTime();
        if (now - lastAssignment < _settings.maxTimeBetweenRewardAssignments) {
             return;
        }

		(address[] memory committeeAddrs, uint[] memory committeeWeights, bool[] memory committeeCertification) = _getCommittee();
        rewardsContract.assignRewardsToCommittee(committeeAddrs, committeeWeights, committeeCertification);

		emit CommitteeSnapshot(committeeAddrs, committeeWeights, committeeCertification);
	}

	constructor(uint _maxCommitteeSize, uint32 maxTimeBetweenRewardAssignments) public {
		require(_maxCommitteeSize > 0, "maxCommitteeSize must be larger than 0");
		require(_maxCommitteeSize <= MAX_COMMITTEE_ARRAY_SIZE, "maxCommitteeSize must be 32 at most");
		settings = Settings({
			maxCommitteeSize: uint8(_maxCommitteeSize),
			maxTimeBetweenRewardAssignments: maxTimeBetweenRewardAssignments
		});

		committee.length = MAX_COMMITTEE_ARRAY_SIZE;
	}


	function memberWeightChange(address addr, uint256 weight) external onlyElectionsContract onlyWhenActive returns (bool committeeChanged) {

		require(uint256(uint96(weight)) == weight, "weight is out of range");

		MemberData memory data = membersData[addr];
		if (!data.isMember) {
			return false;
		}
		data.weight = uint96(weight);
		if (data.inCommittee) {
			committee[data.pos].weight = data.weight;
		}
		return updateOnMemberChange(addr, data);
	}

	function memberCertificationChange(address addr, bool isCertified) external onlyElectionsContract onlyWhenActive returns (bool committeeChanged) {

		MemberData memory data = membersData[addr];
		if (!data.isMember) {
			return false;
		}

		data.isCertified = isCertified;
		return updateOnMemberChange(addr, data);
	}

	function addMember(address addr, uint256 weight, bool isCertified) external onlyElectionsContract onlyWhenActive returns (bool committeeChanged) {

		require(uint256(uint96(weight)) == weight, "weight is out of range");

		if (membersData[addr].isMember) {
			return false;
		}

		return updateOnMemberChange(addr, MemberData({
			isMember: true,
			weight: uint96(weight),
			isCertified: isCertified,
			inCommittee: false,
			pos: uint8(-1)
		}));
	}

	function removeMember(address addr) external onlyElectionsContract onlyWhenActive returns (bool committeeChanged) {

		MemberData memory data = membersData[addr];

		if (!membersData[addr].isMember) {
			return false;
		}

		data.isMember = false;
		return updateOnMemberChange(addr, data);
	}

	function getCommittee() external view returns (address[] memory addrs, uint256[] memory weights, bool[] memory certification) {

		return _getCommittee();
	}

	function _getCommittee() public view returns (address[] memory addrs, uint256[] memory weights, bool[] memory certification) {

		CommitteeInfo memory _committeeInfo = committeeInfo;
		uint bitmap = uint(_committeeInfo.committeeBitmap);
		uint committeeSize = _committeeInfo.committeeSize;

		addrs = new address[](committeeSize);
		weights = new uint[](committeeSize);
		certification = new bool[](committeeSize);
		uint aInd = 0;
		uint pInd = 0;
		MemberData memory md;
		bitmap = uint(_committeeInfo.committeeBitmap);
		while (bitmap != 0) {
			if (bitmap & 1 == 1) {
				addrs[aInd] = committee[pInd].addr;
				md = membersData[addrs[aInd]];
				weights[aInd] = md.weight;
				certification[aInd] = md.isCertified;
				aInd++;
			}
			bitmap >>= 1;
			pInd++;
		}
	}


	function setMaxTimeBetweenRewardAssignments(uint32 maxTimeBetweenRewardAssignments) external onlyFunctionalOwner /* todo onlyWhenActive */ {

		emit MaxTimeBetweenRewardAssignmentsChanged(maxTimeBetweenRewardAssignments, settings.maxTimeBetweenRewardAssignments);
		settings.maxTimeBetweenRewardAssignments = maxTimeBetweenRewardAssignments;
	}

	function setMaxCommittee(uint8 maxCommitteeSize) external onlyFunctionalOwner /* todo onlyWhenActive */ {

		require(maxCommitteeSize > 0, "maxCommitteeSize must be larger than 0");
		require(maxCommitteeSize <= MAX_COMMITTEE_ARRAY_SIZE, "maxCommitteeSize must be 32 at most");
		Settings memory _settings = settings;
		emit MaxCommitteeSizeChanged(maxCommitteeSize, _settings.maxCommitteeSize);
		_settings.maxCommitteeSize = maxCommitteeSize;
		settings = _settings;

		CommitteeInfo memory info = committeeInfo;
		if (maxCommitteeSize >= info.committeeSize) {
			return;
		}

		bytes memory sortBytes = abi.encodePacked(committeeSortBytes);
		for (int rank = int(info.committeeSize); rank >= int(maxCommitteeSize); rank--) {
			(info, sortBytes) = removeMemberAtPos(uint8(sortBytes[uint(rank)]), sortBytes, info);
		}
		committeeInfo = info;
		committeeSortBytes = sortBytes.toBytes32(0);
	}


	function getCommitteeInfo() external view returns (address[] memory addrs, uint256[] memory weights, address[] memory orbsAddrs, bool[] memory certification, bytes4[] memory ips) {

		(addrs, weights, certification) = _getCommittee();
		return (addrs, weights, _loadOrbsAddresses(addrs), certification, _loadIps(addrs));
	}

	function getSettings() external view returns (uint32 maxTimeBetweenRewardAssignments, uint8 maxCommitteeSize) {

		Settings memory _settings = settings;
		maxTimeBetweenRewardAssignments = _settings.maxTimeBetweenRewardAssignments;
		maxCommitteeSize = _settings.maxCommitteeSize;
	}


	function _loadOrbsAddresses(address[] memory addrs) private view returns (address[] memory) {

		return getGuardiansRegistrationContract().getGuardiansOrbsAddress(addrs);
	}

	function _loadIps(address[] memory addrs) private view returns (bytes4[] memory) {

		return getGuardiansRegistrationContract().getGuardianIps(addrs);
	}

	function _loadCertification(address[] memory addrs) private view returns (bool[] memory) {

		bool[] memory certification = new bool[](addrs.length);
		for (uint i = 0; i < addrs.length; i++) {
			certification[i] = membersData[addrs[i]].isCertified;
		}
		return certification;
	}

}