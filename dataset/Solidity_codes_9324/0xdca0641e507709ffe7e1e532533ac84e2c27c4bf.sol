
pragma solidity >=0.5.0;

interface RigoTokenFace {


    function minter() external view returns (address);


    function transfer(address _to, uint256 _value)
        external
        returns (bool);


    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        external
        returns (bool);


    function approve(address _spender, uint256 _value)
        external
        returns (bool);


    function totalSupply()
        external
        view
        returns (uint256);


    function balanceOf(address _owner)
        external
        view
        returns (uint256);


    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256);


    function mintToken(address _recipient, uint256 _amount) external;

    function changeMintingAddress(address _newAddress) external;

    function changeRigoblockAddress(address _newAddress) external;

}/*

 Copyright 2017-2019 RigoBlock, Rigo Investment Sagl, 2020 Rigo Intl.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

*/

pragma solidity >=0.5.0 <0.8.0;

interface IDragoRegistry {


    function register(address _drago, string calldata _name, string calldata _symbol, uint256 _dragoId, address _owner) external payable returns (bool);

    function unregister(uint256 _id) external;

    function setMeta(uint256 _id, bytes32 _key, bytes32 _value) external;

    function addGroup(address _group) external;

    function setFee(uint256 _fee) external;

    function updateOwner(uint256 _id) external;

    function updateOwners(uint256[] calldata _id) external;

    function upgrade(address _newAddress) external payable; //payable as there is a transfer of value, otherwise opcode might throw an error

    function setUpgraded(uint256 _version) external;

    function drain() external;


    function dragoCount() external view returns (uint256);

    function fromId(uint256 _id) external view returns (address drago, string memory name, string memory symbol, uint256 dragoId, address owner, address group);

    function fromAddress(address _drago) external view returns (uint256 id, string memory name, string memory symbol, uint256 dragoId, address owner, address group);

    function fromName(string calldata _name) external view returns (uint256 id, address drago, string memory symbol, uint256 dragoId, address owner, address group);

    function getNameFromAddress(address _pool) external view returns (string memory);

    function getSymbolFromAddress(address _pool) external view returns (string memory);

    function meta(uint256 _id, bytes32 _key) external view returns (bytes32);

    function getGroups() external view returns (address[] memory);

    function getFee() external view returns (uint256);

}/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.5.9 <0.8.0;


interface IStructs {


    struct PoolStats {
        uint256 feesCollected;
        uint256 weightedStake;
        uint256 membersStake;
    }

    struct AggregatedStats {
        uint256 rewardsAvailable;
        uint256 numPoolsToFinalize;
        uint256 totalFeesCollected;
        uint256 totalWeightedStake;
        uint256 totalRewardsFinalized;
    }

    struct StoredBalance {
        uint64 currentEpoch;
        uint96 currentEpochBalance;
        uint96 nextEpochBalance;
    }

    enum StakeStatus {
        UNDELEGATED,
        DELEGATED
    }

    struct StakeInfo {
        StakeStatus status;
        bytes32 poolId;
    }

    struct Fraction {
        uint256 numerator;
        uint256 denominator;
    }

    struct Pool {
        address operator;
        address stakingPal;
        uint32 operatorShare;
        uint32 stakingPalShare;
    }
}/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.5.9 <0.8.0;


interface IGrgVault {


    event StakingProxySet(address stakingProxyAddress);

    event InCatastrophicFailureMode(address sender);

    event Deposit(
        address indexed staker,
        uint256 amount
    );

    event Withdraw(
        address indexed staker,
        uint256 amount
    );

    event GrgProxySet(address grgProxyAddress);

    function setStakingProxy(address _stakingProxyAddress)
        external;


    function enterCatastrophicFailure()
        external;


    function setGrgProxy(address grgProxyAddress)
        external;


    function depositFrom(address staker, uint256 amount)
        external;


    function withdrawFrom(address staker, uint256 amount)
        external;


    function withdrawAllFrom(address staker)
        external
        returns (uint256);


    function balanceOf(address staker)
        external
        view
        returns (uint256);


    function balanceOfGrgVault()
        external
        view
        returns (uint256);

}/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.5.9 <0.8.0;
pragma experimental ABIEncoderV2;



interface IStaking {


    function addPopAddress(address addr)
        external;

        
    function createStakingPool(address rigoblockPoolAddress)
        external
        returns (bytes32 poolId);

    
    function setStakingPalAddress(bytes32 poolId, address newStakingPalAddress)
        external;


    function decreaseStakingPoolOperatorShare(bytes32 poolId, uint32 newOperatorShare)
        external;


    function endEpoch()
        external
        returns (uint256);


    function finalizePool(bytes32 poolId)
        external;


    function init()
        external;


    function joinStakingPoolAsRbPoolAccount(
        bytes32 stakingPoolId,
        address rigoblockPoolAccount)
        external;


    function moveStake(
        IStructs.StakeInfo calldata from,
        IStructs.StakeInfo calldata to,
        uint256 amount
    )
        external;

        
    function creditPopReward(
        address poolAccount,
        uint256 popReward
    )
        external
        payable;


    function removePopAddress(address addr)
        external;


    function setParams(
        uint256 _epochDurationInSeconds,
        uint32 _rewardDelegatedStakeWeight,
        uint256 _minimumPoolStake,
        uint32 _cobbDouglasAlphaNumerator,
        uint32 _cobbDouglasAlphaDenominator
    )
        external;


    function stake(uint256 amount)
        external;


    function unstake(uint256 amount)
        external;


    function withdrawDelegatorRewards(bytes32 poolId)
        external;


    function computeRewardBalanceOfDelegator(bytes32 poolId, address member)
        external
        view
        returns (uint256 reward);


    function computeRewardBalanceOfOperator(bytes32 poolId)
        external
        view
        returns (uint256 reward);


    function getCurrentEpochEarliestEndTimeInSeconds()
        external
        view
        returns (uint256);


    function getGlobalStakeByStatus(IStructs.StakeStatus stakeStatus)
        external
        view
        returns (IStructs.StoredBalance memory balance);


    function getOwnerStakeByStatus(
        address staker,
        IStructs.StakeStatus stakeStatus
    )
        external
        view
        returns (IStructs.StoredBalance memory balance);


    function getTotalStake(address staker)
        external
        view
        returns (uint256);


    function getParams()
        external
        view
        returns (
            uint256 _epochDurationInSeconds,
            uint32 _rewardDelegatedStakeWeight,
            uint256 _minimumPoolStake,
            uint32 _cobbDouglasAlphaNumerator,
            uint32 _cobbDouglasAlphaDenominator
        );


    function getStakeDelegatedToPoolByOwner(address staker, bytes32 poolId)
        external
        view
        returns (IStructs.StoredBalance memory balance);


    function getStakingPool(bytes32 poolId)
        external
        view
        returns (IStructs.Pool memory);


    function getStakingPoolStatsThisEpoch(bytes32 poolId)
        external
        view
        returns (IStructs.PoolStats memory);


    function getTotalStakeDelegatedToPool(bytes32 poolId)
        external
        view
        returns (IStructs.StoredBalance memory balance);


    function getGrgContract()
        external
        view
        returns (RigoTokenFace grgContract);


    function getDragoRegistry()
        external
        view
        returns (IDragoRegistry dragoRegistry);


    function getGrgVault()
        external
        view
        returns (IGrgVault grgVault);

}/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.5.9 <0.8.0;


library LibRichErrors {


    bytes4 internal constant STANDARD_ERROR_SELECTOR =
        0x08c379a0;

    function StandardError(
        string memory message
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            STANDARD_ERROR_SELECTOR,
            bytes(message)
        );
    }

    function rrevert(bytes memory errorData)
        internal
        pure
    {

        assembly {
            revert(add(errorData, 0x20), mload(errorData))
        }
    }
}/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.5.9 <0.8.0;


abstract contract MixinConstants {

    uint32 constant internal PPM_DENOMINATOR = 10**6;

    bytes32 constant internal NIL_POOL_ID = 0x0000000000000000000000000000000000000000000000000000000000000000;

    address constant internal NIL_ADDRESS = 0x0000000000000000000000000000000000000000;

    uint256 constant internal MIN_TOKEN_VALUE = 10**18;
}/*
  Copyright 2019 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity >=0.5.9 <0.8.0;


abstract contract IAuthorizable {

    event AuthorizedAddressAdded(
        address indexed target,
        address indexed caller
    );

    event AuthorizedAddressRemoved(
        address indexed target,
        address indexed caller
    );

    function addAuthorizedAddress(address target)
        external
        virtual;

    function removeAuthorizedAddress(address target)
        external
        virtual;

    function removeAuthorizedAddressAtIndex(
        address target,
        uint256 index
    )
        external
        virtual;

    function getAuthorizedAddresses()
        external
        view
        virtual
        returns (address[] memory);
}/*
  Copyright 2019 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity >=0.5.9 <0.8.0;


library LibAuthorizableRichErrors {


    bytes4 internal constant AUTHORIZED_ADDRESS_MISMATCH_ERROR_SELECTOR =
        0x140a84db;

    bytes4 internal constant INDEX_OUT_OF_BOUNDS_ERROR_SELECTOR =
        0xe9f83771;

    bytes4 internal constant SENDER_NOT_AUTHORIZED_ERROR_SELECTOR =
        0xb65a25b9;

    bytes4 internal constant TARGET_ALREADY_AUTHORIZED_ERROR_SELECTOR =
        0xde16f1a0;

    bytes4 internal constant TARGET_NOT_AUTHORIZED_ERROR_SELECTOR =
        0xeb5108a2;

    bytes internal constant ZERO_CANT_BE_AUTHORIZED_ERROR_BYTES =
        hex"57654fe4";

    function AuthorizedAddressMismatchError(
        address authorized,
        address target
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            AUTHORIZED_ADDRESS_MISMATCH_ERROR_SELECTOR,
            authorized,
            target
        );
    }

    function IndexOutOfBoundsError(
        uint256 index,
        uint256 length
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            INDEX_OUT_OF_BOUNDS_ERROR_SELECTOR,
            index,
            length
        );
    }

    function SenderNotAuthorizedError(address sender)
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            SENDER_NOT_AUTHORIZED_ERROR_SELECTOR,
            sender
        );
    }

    function TargetAlreadyAuthorizedError(address target)
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            TARGET_ALREADY_AUTHORIZED_ERROR_SELECTOR,
            target
        );
    }

    function TargetNotAuthorizedError(address target)
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            TARGET_NOT_AUTHORIZED_ERROR_SELECTOR,
            target
        );
    }

    function ZeroCantBeAuthorizedError()
        internal
        pure
        returns (bytes memory)
    {

        return ZERO_CANT_BE_AUTHORIZED_ERROR_BYTES;
    }
}/*
  Copyright 2019 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity >=0.5.9 <0.8.0;


abstract contract IOwnable {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function transferOwnership(address newOwner)
        public
        virtual;
}pragma solidity >=0.5.9 <0.8.0;


library LibOwnableRichErrors {


    bytes4 internal constant ONLY_OWNER_ERROR_SELECTOR =
        0x1de45ad1;

    bytes internal constant TRANSFER_OWNER_TO_ZERO_ERROR_BYTES =
        hex"e69edc3e";

    function OnlyOwnerError(
        address sender,
        address owner
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            ONLY_OWNER_ERROR_SELECTOR,
            sender,
            owner
        );
    }

    function TransferOwnerToZeroError()
        internal
        pure
        returns (bytes memory)
    {

        return TRANSFER_OWNER_TO_ZERO_ERROR_BYTES;
    }
}/*
  Copyright 2019 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity >=0.5.9 <0.8.0;



contract Ownable is
    IOwnable
{

    address public owner;

    constructor ()
    {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        _assertSenderIsOwner();
        _;
    }

    function transferOwnership(address newOwner)
        public
        override
        onlyOwner
    {

        if (newOwner == address(0)) {
            LibRichErrors.rrevert(LibOwnableRichErrors.TransferOwnerToZeroError());
        } else {
            owner = newOwner;
            emit OwnershipTransferred(msg.sender, newOwner);
        }
    }

    function _assertSenderIsOwner()
        internal
        view
    {

        if (msg.sender != owner) {
            LibRichErrors.rrevert(LibOwnableRichErrors.OnlyOwnerError(
                msg.sender,
                owner
            ));
        }
    }
}/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.5.9 <0.8.0;



contract Authorizable is
    Ownable,
    IAuthorizable
{

    modifier onlyAuthorized {

        _assertSenderIsAuthorized();
        _;
    }

    mapping (address => bool) public authorized;
    address[] public authorities;

    constructor()
        Ownable()
    {}

    function addAuthorizedAddress(address target)
        external
        override
        onlyOwner
    {

        _addAuthorizedAddress(target);
    }

    function removeAuthorizedAddress(address target)
        external
        override
        onlyOwner
    {

        if (!authorized[target]) {
            LibRichErrors.rrevert(LibAuthorizableRichErrors.TargetNotAuthorizedError(target));
        }
        for (uint256 i = 0; i < authorities.length; i++) {
            if (authorities[i] == target) {
                _removeAuthorizedAddressAtIndex(target, i);
                break;
            }
        }
    }

    function removeAuthorizedAddressAtIndex(
        address target,
        uint256 index
    )
        external
        override
        onlyOwner
    {

        _removeAuthorizedAddressAtIndex(target, index);
    }

    function getAuthorizedAddresses()
        external
        view
        override
        returns (address[] memory)
    {

        return authorities;
    }

    function _assertSenderIsAuthorized()
        internal
        view
    {

        if (!authorized[msg.sender]) {
            LibRichErrors.rrevert(LibAuthorizableRichErrors.SenderNotAuthorizedError(msg.sender));
        }
    }

    function _addAuthorizedAddress(address target)
        internal
    {

        if (target == address(0)) {
            LibRichErrors.rrevert(LibAuthorizableRichErrors.ZeroCantBeAuthorizedError());
        }

        if (authorized[target]) {
            LibRichErrors.rrevert(LibAuthorizableRichErrors.TargetAlreadyAuthorizedError(target));
        }

        authorized[target] = true;
        authorities.push(target);
        emit AuthorizedAddressAdded(target, msg.sender);
    }

    function _removeAuthorizedAddressAtIndex(
        address target,
        uint256 index
    )
        internal
    {

        if (!authorized[target]) {
            LibRichErrors.rrevert(LibAuthorizableRichErrors.TargetNotAuthorizedError(target));
        }
        if (index >= authorities.length) {
            LibRichErrors.rrevert(LibAuthorizableRichErrors.IndexOutOfBoundsError(
                index,
                authorities.length
            ));
        }
        if (authorities[index] != target) {
            LibRichErrors.rrevert(LibAuthorizableRichErrors.AuthorizedAddressMismatchError(
                authorities[index],
                target
            ));
        }

        delete authorized[target];
        authorities[index] = authorities[authorities.length - 1];
        authorities.pop();
        emit AuthorizedAddressRemoved(target, msg.sender);
    }
}/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.5.9 <0.8.0;



library LibStakingRichErrors {


    enum OperatorShareErrorCodes {
        OperatorShareTooLarge,
        CanOnlyDecreaseOperatorShare
    }

    enum InitializationErrorCodes {
        MixinSchedulerAlreadyInitialized,
        MixinParamsAlreadyInitialized
    }

    enum InvalidParamValueErrorCodes {
        InvalidCobbDouglasAlpha,
        InvalidRewardDelegatedStakeWeight,
        InvalidMaximumMakersInPool,
        InvalidMinimumPoolStake,
        InvalidEpochDuration
    }

    enum PopManagerErrorCodes {
        PopAlreadyRegistered,
        PopNotRegistered
    }

    bytes4 internal constant ONLY_CALLABLE_BY_POP_ERROR_SELECTOR =
        0x61ecb802;

    bytes4 internal constant POP_MANAGER_ERROR_SELECTOR =
        0xb9588e43;

    bytes4 internal constant INSUFFICIENT_BALANCE_ERROR_SELECTOR =
        0x84c8b7c9;

    bytes4 internal constant ONLY_CALLABLE_BY_POOL_OPERATOR_ERROR_SELECTOR =
        0x82ded785;

    bytes4 internal constant BLOCK_TIMESTAMP_TOO_LOW_ERROR_SELECTOR =
        0xa6bcde47;

    bytes4 internal constant ONLY_CALLABLE_BY_STAKING_CONTRACT_ERROR_SELECTOR =
        0xca1d07a2;

    bytes internal constant ONLY_CALLABLE_IF_IN_CATASTROPHIC_FAILURE_ERROR =
        hex"3ef081cc";

    bytes internal constant ONLY_CALLABLE_IF_NOT_IN_CATASTROPHIC_FAILURE_ERROR =
        hex"7dd020ce";

    bytes4 internal constant OPERATOR_SHARE_ERROR_SELECTOR =
        0x22df9597;

    bytes4 internal constant POOL_EXISTENCE_ERROR_SELECTOR =
        0x9ae94f01;

    bytes internal constant PROXY_DESTINATION_CANNOT_BE_NIL_ERROR =
        hex"6eff8285";

    bytes4 internal constant INITIALIZATION_ERROR_SELECTOR =
        0x0b02d773;

    bytes4 internal constant INVALID_PARAM_VALUE_ERROR_SELECTOR =
        0xfc45bd11;

    bytes4 internal constant INVALID_PROTOCOL_FEE_PAYMENT_ERROR_SELECTOR =
        0x31d7a505;

    bytes4 internal constant PREVIOUS_EPOCH_NOT_FINALIZED_ERROR_SELECTOR =
        0x614b800a;

    bytes4 internal constant POOL_NOT_FINALIZED_ERROR_SELECTOR =
        0x5caa0b05;

    function OnlyCallableByPopError(
        address senderAddress
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            ONLY_CALLABLE_BY_POP_ERROR_SELECTOR,
            senderAddress
        );
    }

    function PopManagerError(
        PopManagerErrorCodes errorCodes,
        address popAddress
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            POP_MANAGER_ERROR_SELECTOR,
            errorCodes,
            popAddress
        );
    }

    function InsufficientBalanceError(
        uint256 amount,
        uint256 balance
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            INSUFFICIENT_BALANCE_ERROR_SELECTOR,
            amount,
            balance
        );
    }

    function OnlyCallableByPoolOperatorError(
        address senderAddress,
        bytes32 poolId
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            ONLY_CALLABLE_BY_POOL_OPERATOR_ERROR_SELECTOR,
            senderAddress,
            poolId
        );
    }

    function BlockTimestampTooLowError(
        uint256 epochEndTime,
        uint256 currentBlockTimestamp
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            BLOCK_TIMESTAMP_TOO_LOW_ERROR_SELECTOR,
            epochEndTime,
            currentBlockTimestamp
        );
    }

    function OnlyCallableByStakingContractError(
        address senderAddress
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            ONLY_CALLABLE_BY_STAKING_CONTRACT_ERROR_SELECTOR,
            senderAddress
        );
    }

    function OnlyCallableIfInCatastrophicFailureError()
        internal
        pure
        returns (bytes memory)
    {

        return ONLY_CALLABLE_IF_IN_CATASTROPHIC_FAILURE_ERROR;
    }

    function OnlyCallableIfNotInCatastrophicFailureError()
        internal
        pure
        returns (bytes memory)
    {

        return ONLY_CALLABLE_IF_NOT_IN_CATASTROPHIC_FAILURE_ERROR;
    }

    function OperatorShareError(
        OperatorShareErrorCodes errorCodes,
        bytes32 poolId,
        uint32 operatorShare
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            OPERATOR_SHARE_ERROR_SELECTOR,
            errorCodes,
            poolId,
            operatorShare
        );
    }

    function PoolExistenceError(
        bytes32 poolId,
        bool alreadyExists
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            POOL_EXISTENCE_ERROR_SELECTOR,
            poolId,
            alreadyExists
        );
    }

    function InvalidProtocolFeePaymentError(
        uint256 expectedProtocolFeePaid,
        uint256 actualProtocolFeePaid
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            INVALID_PROTOCOL_FEE_PAYMENT_ERROR_SELECTOR,
            expectedProtocolFeePaid,
            actualProtocolFeePaid
        );
    }

    function InitializationError(InitializationErrorCodes code)
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            INITIALIZATION_ERROR_SELECTOR,
            uint8(code)
        );
    }

    function InvalidParamValueError(InvalidParamValueErrorCodes code)
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            INVALID_PARAM_VALUE_ERROR_SELECTOR,
            uint8(code)
        );
    }

    function ProxyDestinationCannotBeNilError()
        internal
        pure
        returns (bytes memory)
    {

        return PROXY_DESTINATION_CANNOT_BE_NIL_ERROR;
    }

    function PreviousEpochNotFinalizedError(
        uint256 unfinalizedEpoch,
        uint256 unfinalizedPoolsRemaining
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            PREVIOUS_EPOCH_NOT_FINALIZED_ERROR_SELECTOR,
            unfinalizedEpoch,
            unfinalizedPoolsRemaining
        );
    }

    function PoolNotFinalizedError(
        bytes32 poolId,
        uint256 epoch
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            POOL_NOT_FINALIZED_ERROR_SELECTOR,
            poolId,
            epoch
        );
    }
}/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.5.9 <0.8.0;



abstract contract MixinStorage is
    Authorizable
{
    address public stakingContract;

    mapping (uint8 => IStructs.StoredBalance) internal _globalStakeByStatus;

    mapping (uint8 => mapping (address => IStructs.StoredBalance)) internal _ownerStakeByStatus;

    mapping (address => mapping (bytes32 => IStructs.StoredBalance)) internal _delegatedStakeToPoolByOwner;

    mapping (bytes32 => IStructs.StoredBalance) internal _delegatedStakeByPoolId;

    mapping (address => bytes32) public poolIdByRbPoolAccount;

    mapping (bytes32 => IStructs.Pool) internal _poolById;

    mapping (bytes32 => uint256) public rewardsByPoolId;

    uint256 public currentEpoch;

    uint256 public currentEpochStartTimeInSeconds;

    mapping (bytes32 => mapping (uint256 => IStructs.Fraction)) internal _cumulativeRewardsByPool;

    mapping (bytes32 => uint256) internal _cumulativeRewardsByPoolLastStored;

    mapping (address => bool) public validPops;


    uint256 public epochDurationInSeconds;

    uint32 public rewardDelegatedStakeWeight;

    uint256 public minimumPoolStake;

    uint32 public cobbDouglasAlphaNumerator;

    uint32 public cobbDouglasAlphaDenominator;


    mapping (bytes32 => mapping (uint256 => IStructs.PoolStats)) public poolStatsByEpoch;

    mapping (uint256 => IStructs.AggregatedStats) public aggregatedStatsByEpoch;

    uint256 public grgReservedForPoolRewards;
}/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.5.9 <0.8.0;


interface IStakingEvents {


    event Stake(
        address indexed staker,
        uint256 amount
    );

    event Unstake(
        address indexed staker,
        uint256 amount
    );

    event MoveStake(
        address indexed staker,
        uint256 amount,
        uint8 fromStatus,
        bytes32 indexed fromPool,
        uint8 toStatus,
        bytes32 indexed toPool
    );

    event PopAdded(
        address exchangeAddress
    );

    event PopRemoved(
        address exchangeAddress
    );

    event StakingPoolEarnedRewardsInEpoch(
        uint256 indexed epoch,
        bytes32 indexed poolId
    );

    event EpochEnded(
        uint256 indexed epoch,
        uint256 numPoolsToFinalize,
        uint256 rewardsAvailable,
        uint256 totalFeesCollected,
        uint256 totalWeightedStake
    );

    event EpochFinalized(
        uint256 indexed epoch,
        uint256 rewardsPaid,
        uint256 rewardsRemaining
    );

    event RewardsPaid(
        uint256 indexed epoch,
        bytes32 indexed poolId,
        uint256 operatorReward,
        uint256 membersReward
    );

    event ParamsSet(
        uint256 epochDurationInSeconds,
        uint32 rewardDelegatedStakeWeight,
        uint256 minimumPoolStake,
        uint256 cobbDouglasAlphaNumerator,
        uint256 cobbDouglasAlphaDenominator
    );

    event StakingPoolCreated(
        bytes32 poolId,
        address operator,
        uint32 operatorShare
    );

    event RbPoolStakingPoolSet(
        address indexed rbPoolAddress,
        bytes32 indexed poolId
    );

    event OperatorShareDecreased(
        bytes32 indexed poolId,
        uint32 oldOperatorShare,
        uint32 newOperatorShare
    );
    
    event GrgMintEvent(uint256 grgAmount);
    
    event CatchStringEvent(string reason);
    
    event ReturnDataEvent(bytes reason);
}/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.5.9 <0.8.0;



abstract contract IStakingProxy {

    event StakingContractAttachedToProxy(
        address newStakingContractAddress
    );

    event StakingContractDetachedFromProxy();

    function attachStakingContract(address _stakingContract)
        external
        virtual;

    function detachStakingContract()
        external
        virtual;

    function assertValidStorageParams()
        external
        view
        virtual;
}/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.5.9 <0.8.0;



abstract contract MixinParams is
    IStaking,
    IStakingEvents,
    MixinStorage,
    MixinConstants
{
    function setParams(
        uint256 _epochDurationInSeconds,
        uint32 _rewardDelegatedStakeWeight,
        uint256 _minimumPoolStake,
        uint32 _cobbDouglasAlphaNumerator,
        uint32 _cobbDouglasAlphaDenominator
    )
        external
        override
        onlyAuthorized
    {
        _setParams(
            _epochDurationInSeconds,
            _rewardDelegatedStakeWeight,
            _minimumPoolStake,
            _cobbDouglasAlphaNumerator,
            _cobbDouglasAlphaDenominator
        );

        IStakingProxy(address(this)).assertValidStorageParams();
    }

    function getParams()
        external
        view
        override
        returns (
            uint256 _epochDurationInSeconds,
            uint32 _rewardDelegatedStakeWeight,
            uint256 _minimumPoolStake,
            uint32 _cobbDouglasAlphaNumerator,
            uint32 _cobbDouglasAlphaDenominator
        )
    {
        _epochDurationInSeconds = epochDurationInSeconds;
        _rewardDelegatedStakeWeight = rewardDelegatedStakeWeight;
        _minimumPoolStake = minimumPoolStake;
        _cobbDouglasAlphaNumerator = cobbDouglasAlphaNumerator;
        _cobbDouglasAlphaDenominator = cobbDouglasAlphaDenominator;
    }

    function _initMixinParams()
        internal
    {
        _assertParamsNotInitialized();

        uint256 _epochDurationInSeconds = 14 days;
        uint32 _rewardDelegatedStakeWeight = (90 * PPM_DENOMINATOR) / 100;
        uint256 _minimumPoolStake = 100 * MIN_TOKEN_VALUE;
        uint32 _cobbDouglasAlphaNumerator = 2;
        uint32 _cobbDouglasAlphaDenominator = 3;

        _setParams(
            _epochDurationInSeconds,
            _rewardDelegatedStakeWeight,
            _minimumPoolStake,
            _cobbDouglasAlphaNumerator,
            _cobbDouglasAlphaDenominator
        );
    }

    function _assertParamsNotInitialized()
        internal
        view
    {
        if (epochDurationInSeconds != 0 &&
            rewardDelegatedStakeWeight != 0 &&
            minimumPoolStake != 0 &&
            cobbDouglasAlphaNumerator != 0 &&
            cobbDouglasAlphaDenominator != 0
        ) {
            LibRichErrors.rrevert(
                LibStakingRichErrors.InitializationError(
                    LibStakingRichErrors.InitializationErrorCodes.MixinParamsAlreadyInitialized
                )
            );
        }
    }

    function _setParams(
        uint256 _epochDurationInSeconds,
        uint32 _rewardDelegatedStakeWeight,
        uint256 _minimumPoolStake,
        uint32 _cobbDouglasAlphaNumerator,
        uint32 _cobbDouglasAlphaDenominator
    )
        private
    {
        epochDurationInSeconds = _epochDurationInSeconds;
        rewardDelegatedStakeWeight = _rewardDelegatedStakeWeight;
        minimumPoolStake = _minimumPoolStake;
        cobbDouglasAlphaNumerator = _cobbDouglasAlphaNumerator;
        cobbDouglasAlphaDenominator = _cobbDouglasAlphaDenominator;

        emit ParamsSet(
            _epochDurationInSeconds,
            _rewardDelegatedStakeWeight,
            _minimumPoolStake,
            _cobbDouglasAlphaNumerator,
            _cobbDouglasAlphaDenominator
        );
    }
}pragma solidity >=0.5.4 <0.8.0;


library LibSafeMathRichErrors {


    bytes4 internal constant UINT256_BINOP_ERROR_SELECTOR =
        0xe946c1bb;

    bytes4 internal constant UINT256_DOWNCAST_ERROR_SELECTOR =
        0xc996af7b;

    enum BinOpErrorCodes {
        ADDITION_OVERFLOW,
        MULTIPLICATION_OVERFLOW,
        SUBTRACTION_UNDERFLOW,
        DIVISION_BY_ZERO
    }

    enum DowncastErrorCodes {
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT32,
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT64,
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT96
    }

    function Uint256BinOpError(
        BinOpErrorCodes errorCode,
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            UINT256_BINOP_ERROR_SELECTOR,
            errorCode,
            a,
            b
        );
    }

    function Uint256DowncastError(
        DowncastErrorCodes errorCode,
        uint256 a
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            UINT256_DOWNCAST_ERROR_SELECTOR,
            errorCode,
            a
        );
    }
}pragma solidity >=0.5.9 <0.8.0;



library LibSafeMath {


    function safeMul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        if (c / a != b) {
            LibRichErrors.rrevert(LibSafeMathRichErrors.Uint256BinOpError(
                LibSafeMathRichErrors.BinOpErrorCodes.MULTIPLICATION_OVERFLOW,
                a,
                b
            ));
        }
        return c;
    }

    function safeDiv(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        if (b == 0) {
            LibRichErrors.rrevert(LibSafeMathRichErrors.Uint256BinOpError(
                LibSafeMathRichErrors.BinOpErrorCodes.DIVISION_BY_ZERO,
                a,
                b
            ));
        }
        uint256 c = a / b;
        return c;
    }

    function safeSub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        if (b > a) {
            LibRichErrors.rrevert(LibSafeMathRichErrors.Uint256BinOpError(
                LibSafeMathRichErrors.BinOpErrorCodes.SUBTRACTION_UNDERFLOW,
                a,
                b
            ));
        }
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        uint256 c = a + b;
        if (c < a) {
            LibRichErrors.rrevert(LibSafeMathRichErrors.Uint256BinOpError(
                LibSafeMathRichErrors.BinOpErrorCodes.ADDITION_OVERFLOW,
                a,
                b
            ));
        }
        return c;
    }

    function max256(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        return a < b ? a : b;
    }
}/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.5.9 <0.8.0;


abstract contract MixinAbstract {

    function _getUnfinalizedPoolRewards(bytes32 poolId)
        internal
        view
        virtual
        returns (
            uint256 totalReward,
            uint256 membersStake
        );

    function _assertPoolFinalizedLastEpoch(bytes32 poolId)
        internal
        view
        virtual;
}pragma solidity >=0.5.9 <0.8.0;


library LibMathRichErrors {


    bytes internal constant DIVISION_BY_ZERO_ERROR =
        hex"a791837c";

    bytes4 internal constant ROUNDING_ERROR_SELECTOR =
        0x339f3de2;

    function DivisionByZeroError()
        internal
        pure
        returns (bytes memory)
    {

        return DIVISION_BY_ZERO_ERROR;
    }

    function RoundingError(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            ROUNDING_ERROR_SELECTOR,
            numerator,
            denominator,
            target
        );
    }
}/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.5.9 <0.8.0;



library LibMath {


    using LibSafeMath for uint256;

    function safeGetPartialAmountFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256 partialAmount)
    {

        if (isRoundingErrorFloor(
                numerator,
                denominator,
                target
        )) {
            LibRichErrors.rrevert(LibMathRichErrors.RoundingError(
                numerator,
                denominator,
                target
            ));
        }

        partialAmount = numerator.safeMul(target).safeDiv(denominator);
        return partialAmount;
    }

    function safeGetPartialAmountCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256 partialAmount)
    {

        if (isRoundingErrorCeil(
                numerator,
                denominator,
                target
        )) {
            LibRichErrors.rrevert(LibMathRichErrors.RoundingError(
                numerator,
                denominator,
                target
            ));
        }

        partialAmount = numerator.safeMul(target)
            .safeAdd(denominator.safeSub(1))
            .safeDiv(denominator);

        return partialAmount;
    }

    function getPartialAmountFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256 partialAmount)
    {

        partialAmount = numerator.safeMul(target).safeDiv(denominator);
        return partialAmount;
    }

    function getPartialAmountCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256 partialAmount)
    {

        partialAmount = numerator.safeMul(target)
            .safeAdd(denominator.safeSub(1))
            .safeDiv(denominator);

        return partialAmount;
    }

    function isRoundingErrorFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (bool isError)
    {

        if (denominator == 0) {
            LibRichErrors.rrevert(LibMathRichErrors.DivisionByZeroError());
        }

        if (target == 0 || numerator == 0) {
            return false;
        }

        uint256 remainder = mulmod(
            target,
            numerator,
            denominator
        );
        isError = remainder.safeMul(1000) >= numerator.safeMul(target);
        return isError;
    }

    function isRoundingErrorCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (bool isError)
    {

        if (denominator == 0) {
            LibRichErrors.rrevert(LibMathRichErrors.DivisionByZeroError());
        }

        if (target == 0 || numerator == 0) {
            return false;
        }
        uint256 remainder = mulmod(
            target,
            numerator,
            denominator
        );
        remainder = denominator.safeSub(remainder) % denominator;
        isError = remainder.safeMul(1000) >= numerator.safeMul(target);
        return isError;
    }
}pragma solidity >=0.5.4 <0.8.0;



library LibFractions {


    using LibSafeMath for uint256;

    function add(
        uint256 n1,
        uint256 d1,
        uint256 n2,
        uint256 d2
    )
        internal
        pure
        returns (
            uint256 numerator,
            uint256 denominator
        )
    {

        if (n1 == 0) {
            return (numerator = n2, denominator = d2);
        }
        if (n2 == 0) {
            return (numerator = n1, denominator = d1);
        }
        numerator = n1
            .safeMul(d2)
            .safeAdd(n2.safeMul(d1));
        denominator = d1.safeMul(d2);
        return (numerator, denominator);
    }

    function normalize(
        uint256 numerator,
        uint256 denominator,
        uint256 maxValue
    )
        internal
        pure
        returns (
            uint256 scaledNumerator,
            uint256 scaledDenominator
        )
    {

        if (numerator > maxValue || denominator > maxValue) {
            uint256 rescaleBase = numerator >= denominator ? numerator : denominator;
            rescaleBase = rescaleBase.safeDiv(maxValue);
            scaledNumerator = numerator.safeDiv(rescaleBase);
            scaledDenominator = denominator.safeDiv(rescaleBase);
        } else {
            scaledNumerator = numerator;
            scaledDenominator = denominator;
        }
        return (scaledNumerator, scaledDenominator);
    }

    function normalize(
        uint256 numerator,
        uint256 denominator
    )
        internal
        pure
        returns (
            uint256 scaledNumerator,
            uint256 scaledDenominator
        )
    {

        return normalize(numerator, denominator, 2 ** 127);
    }

    function scaleDifference(
        uint256 n1,
        uint256 d1,
        uint256 n2,
        uint256 d2,
        uint256 s
    )
        internal
        pure
        returns (uint256 result)
    {

        if (s == 0) {
            return 0;
        }
        if (n2 == 0) {
            return result = s
                .safeMul(n1)
                .safeDiv(d1);
        }
        uint256 numerator = n1
            .safeMul(d2)
            .safeSub(n2.safeMul(d1));
        uint256 tmp = numerator.safeDiv(d2);
        return s
            .safeMul(tmp)
            .safeDiv(d1);
    }
}/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.5.9 <0.8.0;



library LibSafeDowncast {


    function downcastToUint96(uint256 a)
        internal
        pure
        returns (uint96 b)
    {

        b = uint96(a);
        if (uint256(b) != a) {
            LibRichErrors.rrevert(LibSafeMathRichErrors.Uint256DowncastError(
                LibSafeMathRichErrors.DowncastErrorCodes.VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT96,
                a
            ));
        }
        return b;
    }

    function downcastToUint64(uint256 a)
        internal
        pure
        returns (uint64 b)
    {

        b = uint64(a);
        if (uint256(b) != a) {
            LibRichErrors.rrevert(LibSafeMathRichErrors.Uint256DowncastError(
                LibSafeMathRichErrors.DowncastErrorCodes.VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT64,
                a
            ));
        }
        return b;
    }

    function downcastToUint32(uint256 a)
        internal
        pure
        returns (uint32 b)
    {

        b = uint32(a);
        if (uint256(b) != a) {
            LibRichErrors.rrevert(LibSafeMathRichErrors.Uint256DowncastError(
                LibSafeMathRichErrors.DowncastErrorCodes.VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT32,
                a
            ));
        }
        return b;
    }
}/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.5.9 <0.8.0;


abstract contract IERC20Token {

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    function transfer(address _to, uint256 _value)
        external
        virtual
        returns (bool);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        external
        virtual
        returns (bool);

    function approve(address _spender, uint256 _value)
        external
        virtual
        returns (bool);

    function totalSupply()
        external
        view
        virtual
        returns (uint256);

    function balanceOf(address _owner)
        external
        view
        virtual
        returns (uint256);

    function allowance(address _owner, address _spender)
        external
        view
        virtual
        returns (uint256);
}/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >= 0.5.9;



abstract contract IEtherToken is
    IERC20Token
{
    function deposit()
        public
        virtual
        payable;

    function withdraw(uint256 amount)
        public
        virtual;
}/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.5.9 <0.8.0;



abstract contract MixinDeploymentConstants is IStaking {

    address constant private GRG_VAULT_ADDRESS = address(0xfbd2588b170Ff776eBb1aBbB58C0fbE3ffFe1931);

    
    address constant private DRAGO_REGISTRY_ADDRESS = address(0xdE6445484a8dcD9bf35fC95eb4E3990Cc358822e);
    
    
    address constant private GRG_ADDRESS = address(0x4FbB350052Bca5417566f188eB2EBCE5b19BC964);


    function getGrgVault()
        public
        view
        virtual
        override
        returns (IGrgVault grgVault)
    {
        grgVault = IGrgVault(GRG_VAULT_ADDRESS);
        return grgVault;
    }
    
    function getDragoRegistry()
        public
        view
        virtual
        override
        returns (IDragoRegistry dragoRegistry)
    {
        dragoRegistry = IDragoRegistry(DRAGO_REGISTRY_ADDRESS);
        return dragoRegistry;
    }
    
    function getGrgContract()
        public
        view
        virtual
        override
        returns (RigoTokenFace grgContract)
    {
        grgContract = RigoTokenFace(GRG_ADDRESS);
        return grgContract;
    }
}/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.5.9 <0.8.0;



abstract contract MixinScheduler is
    IStaking,
    IStakingEvents,
    MixinStorage
{
    using LibSafeMath for uint256;

    function getCurrentEpochEarliestEndTimeInSeconds()
        public
        view
        override
        returns (uint256)
    {
        return currentEpochStartTimeInSeconds.safeAdd(epochDurationInSeconds);
    }

    function _initMixinScheduler()
        internal
    {
        _assertSchedulerNotInitialized();

        currentEpochStartTimeInSeconds = block.timestamp;
        currentEpoch = 1;
    }

    function _goToNextEpoch()
        internal
    {
        uint256 currentBlockTimestamp = block.timestamp;

        uint256 epochEndTime = getCurrentEpochEarliestEndTimeInSeconds();
        if (epochEndTime > currentBlockTimestamp) {
            LibRichErrors.rrevert(LibStakingRichErrors.BlockTimestampTooLowError(
                epochEndTime,
                currentBlockTimestamp
            ));
        }

        uint256 nextEpoch = currentEpoch.safeAdd(1);
        currentEpoch = nextEpoch;
        currentEpochStartTimeInSeconds = currentBlockTimestamp;
    }

    function _assertSchedulerNotInitialized()
        internal
        view
    {
        if (currentEpochStartTimeInSeconds != 0) {
            LibRichErrors.rrevert(
                LibStakingRichErrors.InitializationError(
                    LibStakingRichErrors.InitializationErrorCodes.MixinSchedulerAlreadyInitialized
                )
            );
        }
    }
}/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.5.9 <0.8.0;



abstract contract MixinStakeStorage is
    MixinScheduler
{
    using LibSafeMath for uint256;
    using LibSafeDowncast for uint256;

    function _moveStake(
        IStructs.StoredBalance storage fromPtr,
        IStructs.StoredBalance storage toPtr,
        uint256 amount
    )
        internal
    {
        if (_arePointersEqual(fromPtr, toPtr)) {
            return;
        }

        IStructs.StoredBalance memory from = _loadCurrentBalance(fromPtr);
        IStructs.StoredBalance memory to = _loadCurrentBalance(toPtr);

        if (amount > from.nextEpochBalance) {
            LibRichErrors.rrevert(
                LibStakingRichErrors.InsufficientBalanceError(
                    amount,
                    from.nextEpochBalance
                )
            );
        }

        from.nextEpochBalance = uint256(from.nextEpochBalance).safeSub(amount).downcastToUint96();
        to.nextEpochBalance = uint256(to.nextEpochBalance).safeAdd(amount).downcastToUint96();

        _storeBalance(fromPtr, from);
        _storeBalance(toPtr, to);
    }

    function _loadCurrentBalance(IStructs.StoredBalance storage balancePtr)
        internal
        view
        returns (IStructs.StoredBalance memory balance)
    {
        balance = balancePtr;
        uint256 currentEpoch_ = currentEpoch;
        if (currentEpoch_ > balance.currentEpoch) {
            balance.currentEpoch = currentEpoch_.downcastToUint64();
            balance.currentEpochBalance = balance.nextEpochBalance;
        }
        return balance;
    }

    function _increaseCurrentAndNextBalance(IStructs.StoredBalance storage balancePtr, uint256 amount)
        internal
    {
        IStructs.StoredBalance memory balance = _loadCurrentBalance(balancePtr);
        balance.nextEpochBalance = uint256(balance.nextEpochBalance).safeAdd(amount).downcastToUint96();
        balance.currentEpochBalance = uint256(balance.currentEpochBalance).safeAdd(amount).downcastToUint96();

        _storeBalance(balancePtr, balance);
    }

    function _decreaseCurrentAndNextBalance(IStructs.StoredBalance storage balancePtr, uint256 amount)
        internal
    {
        IStructs.StoredBalance memory balance = _loadCurrentBalance(balancePtr);
        balance.nextEpochBalance = uint256(balance.nextEpochBalance).safeSub(amount).downcastToUint96();
        balance.currentEpochBalance = uint256(balance.currentEpochBalance).safeSub(amount).downcastToUint96();

        _storeBalance(balancePtr, balance);
    }

    function _increaseNextBalance(IStructs.StoredBalance storage balancePtr, uint256 amount)
        internal
    {
        IStructs.StoredBalance memory balance = _loadCurrentBalance(balancePtr);
        balance.nextEpochBalance = uint256(balance.nextEpochBalance).safeAdd(amount).downcastToUint96();

        _storeBalance(balancePtr, balance);
    }

    function _decreaseNextBalance(IStructs.StoredBalance storage balancePtr, uint256 amount)
        internal
    {
        IStructs.StoredBalance memory balance = _loadCurrentBalance(balancePtr);
        balance.nextEpochBalance = uint256(balance.nextEpochBalance).safeSub(amount).downcastToUint96();

        _storeBalance(balancePtr, balance);
    }

    function _storeBalance(
        IStructs.StoredBalance storage balancePtr,
        IStructs.StoredBalance memory balance
    )
        private
    {
        balancePtr.currentEpoch = balance.currentEpoch;
        balancePtr.nextEpochBalance = balance.nextEpochBalance;
        balancePtr.currentEpochBalance = balance.currentEpochBalance;
    }

    function _arePointersEqual(
        IStructs.StoredBalance storage balancePtrA,
        IStructs.StoredBalance storage balancePtrB
    )
        private
        pure
        returns (bool areEqual)
    {
        assembly {
            areEqual := and(
                eq(balancePtrA.slot, balancePtrB.slot),
                eq(balancePtrA.offset, balancePtrB.offset)
            )
        }
        return areEqual;
    }
}/*

 Copyright 2017-2019 RigoBlock, Rigo Investment Sagl, 2020 Rigo Intl.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

*/

pragma solidity >=0.4.22 <0.8.0;

interface InflationFace {


    function RIGO_TOKEN_ADDRESS()
        external
        view
        returns (address);


    function STAKING_PROXY_ADDRESS()
        external
        view
        returns (address);


    function slot()
        external
        view
        returns (uint256);


    function epochLength()
        external
        view
        returns (uint256);


    function mintInflation()
        external
        returns (uint256 mintedInflation);


    function epochEnded()
        external
        view
        returns (bool);


    function timeUntilNextClaim()
        external
        view
        returns (uint256);


    function getEpochInflation()
        external
        view
        returns (uint256);

}/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.5.9 <0.8.0;



abstract contract MixinStakeBalances is
    MixinStakeStorage,
    MixinDeploymentConstants
{
    using LibSafeMath for uint256;
    using LibSafeDowncast for uint256;

    function getGlobalStakeByStatus(IStructs.StakeStatus stakeStatus)
        external
        view
        override
        returns (IStructs.StoredBalance memory balance)
    {
        balance = _loadCurrentBalance(
            _globalStakeByStatus[uint8(IStructs.StakeStatus.DELEGATED)]
        );
        if (stakeStatus == IStructs.StakeStatus.UNDELEGATED) {
            uint256 totalStake = getGrgVault().balanceOfGrgVault();
            balance.currentEpochBalance = totalStake.safeSub(balance.currentEpochBalance).downcastToUint96();
            balance.nextEpochBalance = totalStake.safeSub(balance.nextEpochBalance).downcastToUint96();
        }
        return balance;
    }

    function getOwnerStakeByStatus(
        address staker,
        IStructs.StakeStatus stakeStatus
    )
        external
        view
        override
        returns (IStructs.StoredBalance memory balance)
    {
        balance = _loadCurrentBalance(
            _ownerStakeByStatus[uint8(stakeStatus)][staker]
        );
        return balance;
    }

    function getTotalStake(address staker)
        public
        view
        override
        returns (uint256)
    {
        return getGrgVault().balanceOf(staker);
    }

    function getStakeDelegatedToPoolByOwner(address staker, bytes32 poolId)
        public
        view
        override
        returns (IStructs.StoredBalance memory balance)
    {
        balance = _loadCurrentBalance(_delegatedStakeToPoolByOwner[staker][poolId]);
        return balance;
    }

    function getTotalStakeDelegatedToPool(bytes32 poolId)
        public
        view
        override
        returns (IStructs.StoredBalance memory balance)
    {
        balance = _loadCurrentBalance(_delegatedStakeByPoolId[poolId]);
        return balance;
    }
}/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.5.9 <0.8.0;



abstract contract MixinCumulativeRewards is
    MixinStakeBalances,
    MixinConstants
{
    using LibSafeMath for uint256;

    function _isCumulativeRewardSet(IStructs.Fraction memory cumulativeReward)
        internal
        pure
        returns (bool)
    {
        return cumulativeReward.denominator != 0;
    }

    function _addCumulativeReward(
        bytes32 poolId,
        uint256 reward,
        uint256 stake
    )
        internal
    {
        uint256 lastStoredEpoch = _cumulativeRewardsByPoolLastStored[poolId];
        uint256 currentEpoch_ = currentEpoch;

        if (lastStoredEpoch == currentEpoch_) {
            return;
        }

        IStructs.Fraction memory mostRecentCumulativeReward =
            _cumulativeRewardsByPool[poolId][lastStoredEpoch];

        IStructs.Fraction memory cumulativeReward;
        if (_isCumulativeRewardSet(mostRecentCumulativeReward)) {
            (cumulativeReward.numerator, cumulativeReward.denominator) = LibFractions.add(
                mostRecentCumulativeReward.numerator,
                mostRecentCumulativeReward.denominator,
                reward,
                stake
            );
            (cumulativeReward.numerator, cumulativeReward.denominator) = LibFractions.normalize(
                cumulativeReward.numerator,
                cumulativeReward.denominator
            );
        } else {
            (cumulativeReward.numerator, cumulativeReward.denominator) = (reward, stake);
        }

        _cumulativeRewardsByPool[poolId][currentEpoch_] = cumulativeReward;
        _cumulativeRewardsByPoolLastStored[poolId] = currentEpoch_;
    }

    function _updateCumulativeReward(bytes32 poolId)
        internal
    {
        _addCumulativeReward(poolId, 0, 1);
    }

    function _computeMemberRewardOverInterval(
        bytes32 poolId,
        uint256 memberStakeOverInterval,
        uint256 beginEpoch,
        uint256 endEpoch
    )
        internal
        view
        returns (uint256 reward)
    {
        if (memberStakeOverInterval == 0 || beginEpoch == endEpoch) {
            return 0;
        }

        require(beginEpoch < endEpoch, "CR_INTERVAL_INVALID");

        IStructs.Fraction memory beginReward = _getCumulativeRewardAtEpoch(poolId, beginEpoch);
        IStructs.Fraction memory endReward = _getCumulativeRewardAtEpoch(poolId, endEpoch);

        reward = LibFractions.scaleDifference(
            endReward.numerator,
            endReward.denominator,
            beginReward.numerator,
            beginReward.denominator,
            memberStakeOverInterval
        );
    }

    function _getMostRecentCumulativeReward(bytes32 poolId)
        private
        view
        returns (IStructs.Fraction memory cumulativeReward)
    {
        uint256 lastStoredEpoch = _cumulativeRewardsByPoolLastStored[poolId];
        return _cumulativeRewardsByPool[poolId][lastStoredEpoch];
    }

    function _getCumulativeRewardAtEpoch(bytes32 poolId, uint256 epoch)
        private
        view
        returns (IStructs.Fraction memory cumulativeReward)
    {
        cumulativeReward = _cumulativeRewardsByPool[poolId][epoch];
        if (_isCumulativeRewardSet(cumulativeReward)) {
            return cumulativeReward;
        }

        uint256 lastEpoch = epoch.safeSub(1);
        cumulativeReward = _cumulativeRewardsByPool[poolId][lastEpoch];
        if (_isCumulativeRewardSet(cumulativeReward)) {
            return cumulativeReward;
        }

        uint256 mostRecentEpoch = _cumulativeRewardsByPoolLastStored[poolId];
        if (mostRecentEpoch < epoch) {
            cumulativeReward = _cumulativeRewardsByPool[poolId][mostRecentEpoch];
            if (_isCumulativeRewardSet(cumulativeReward)) {
                return cumulativeReward;
            }
        }

        return IStructs.Fraction(0, 1);
    }
}/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.5.9 <0.8.0;



abstract contract MixinStakingPoolRewards is
    IStaking,
    MixinAbstract,
    MixinCumulativeRewards
{
    using LibSafeMath for uint256;

    function withdrawDelegatorRewards(bytes32 poolId)
        external
        override
    {
        _withdrawAndSyncDelegatorRewards(poolId, msg.sender);
    }

    function computeRewardBalanceOfOperator(bytes32 poolId)
        external
        view
        override
        returns (uint256 reward)
    {
        IStructs.Pool memory pool = _poolById[poolId];
        (uint256 unfinalizedTotalRewards, uint256 unfinalizedMembersStake) =
            _getUnfinalizedPoolRewards(poolId);

        (reward,) = _computePoolRewardsSplit(
            pool.operatorShare,
            unfinalizedTotalRewards,
            unfinalizedMembersStake
        );
        return reward;
    }

    function computeRewardBalanceOfDelegator(bytes32 poolId, address member)
        external
        view
        override
        returns (uint256 reward)
    {
        IStructs.Pool memory pool = _poolById[poolId];
        (uint256 unfinalizedTotalRewards, uint256 unfinalizedMembersStake) =
            _getUnfinalizedPoolRewards(poolId);

        (, uint256 unfinalizedMembersReward) = _computePoolRewardsSplit(
            pool.operatorShare,
            unfinalizedTotalRewards,
            unfinalizedMembersStake
        );
        return _computeDelegatorReward(
            poolId,
            member,
            unfinalizedMembersReward,
            unfinalizedMembersStake
        );
    }

    function _withdrawAndSyncDelegatorRewards(
        bytes32 poolId,
        address member
    )
        internal
    {
        _assertPoolFinalizedLastEpoch(poolId);

        uint256 balance = _computeDelegatorReward(
            poolId,
            member,
            0,
            0
        );

        _delegatedStakeToPoolByOwner[member][poolId] =
            _loadCurrentBalance(_delegatedStakeToPoolByOwner[member][poolId]);

        if (balance != 0) {
            _decreasePoolRewards(poolId, balance);

            getGrgContract().transfer(member, balance);
        }

        _updateCumulativeReward(poolId);
    }

    function _syncPoolRewards(
        bytes32 poolId,
        uint256 reward,
        uint256 membersStake
    )
        internal
        returns (uint256 operatorReward, uint256 membersReward)
    {
        IStructs.Pool memory pool = _poolById[poolId];

        (operatorReward, membersReward) = _computePoolRewardsSplit(
            pool.operatorShare,
            reward,
            membersStake
        );

        if (operatorReward > 0) {
            if (pool.operator == pool.stakingPal) {
                getGrgContract().transfer(pool.operator, operatorReward);
            } else {
                uint256 stakingPalReward = operatorReward.safeMul(pool.stakingPalShare).safeDiv(PPM_DENOMINATOR);
                getGrgContract().transfer(pool.stakingPal, stakingPalReward);
                getGrgContract().transfer(pool.operator, operatorReward.safeSub(stakingPalReward));
            }
        }

        if (membersReward > 0) {
            _increasePoolRewards(poolId, membersReward);
            _addCumulativeReward(poolId, membersReward, membersStake);
        }

        return (operatorReward, membersReward);
    }

    function _computePoolRewardsSplit(
        uint32 operatorShare,
        uint256 totalReward,
        uint256 membersStake
    )
        internal
        pure
        returns (uint256 operatorReward, uint256 membersReward)
    {
        if (membersStake == 0) {
            operatorReward = totalReward;
        } else {
            operatorReward = LibMath.getPartialAmountCeil(
                uint256(operatorShare),
                PPM_DENOMINATOR,
                totalReward
            );
            membersReward = totalReward.safeSub(operatorReward);
        }
        return (operatorReward, membersReward);
    }

    function _computeDelegatorReward(
        bytes32 poolId,
        address member,
        uint256 unfinalizedMembersReward,
        uint256 unfinalizedMembersStake
    )
        private
        view
        returns (uint256 reward)
    {
        uint256 currentEpoch_ = currentEpoch;
        IStructs.StoredBalance memory delegatedStake = _delegatedStakeToPoolByOwner[member][poolId];

        if (delegatedStake.currentEpoch == currentEpoch_) {
            return 0;
        }


        reward = _computeUnfinalizedDelegatorReward(
            delegatedStake,
            currentEpoch_,
            unfinalizedMembersReward,
            unfinalizedMembersStake
        );

        uint256 delegatedStakeNextEpoch = uint256(delegatedStake.currentEpoch).safeAdd(1);
        reward = reward.safeAdd(
            _computeMemberRewardOverInterval(
                poolId,
                delegatedStake.currentEpochBalance,
                delegatedStake.currentEpoch,
                delegatedStakeNextEpoch
            )
        );

        reward = reward.safeAdd(
            _computeMemberRewardOverInterval(
                poolId,
                delegatedStake.nextEpochBalance,
                delegatedStakeNextEpoch,
                currentEpoch_
            )
        );

        return reward;
    }

    function _computeUnfinalizedDelegatorReward(
        IStructs.StoredBalance memory delegatedStake,
        uint256 currentEpoch_,
        uint256 unfinalizedMembersReward,
        uint256 unfinalizedMembersStake
    )
        private
        pure
        returns (uint256)
    {
        if (unfinalizedMembersReward == 0 || unfinalizedMembersStake == 0) {
            return 0;
        }

        uint256 unfinalizedStakeBalance = delegatedStake.currentEpoch >= currentEpoch_.safeSub(1) ?
            delegatedStake.currentEpochBalance :
            delegatedStake.nextEpochBalance;

        if (unfinalizedStakeBalance == 0) {
            return 0;
        }

        return LibMath.getPartialAmountFloor(
            unfinalizedMembersReward,
            unfinalizedMembersStake,
            unfinalizedStakeBalance
        );
    }

    function _increasePoolRewards(bytes32 poolId, uint256 amount)
        private
    {
        rewardsByPoolId[poolId] = rewardsByPoolId[poolId].safeAdd(amount);
        grgReservedForPoolRewards = grgReservedForPoolRewards.safeAdd(amount);
    }

    function _decreasePoolRewards(bytes32 poolId, uint256 amount)
        private
    {
        rewardsByPoolId[poolId] = rewardsByPoolId[poolId].safeSub(amount);
        grgReservedForPoolRewards = grgReservedForPoolRewards.safeSub(amount);
    }
}/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.5.9 <0.8.0;



abstract contract MixinStakingPool is
    MixinAbstract,
    MixinStakingPoolRewards
{
    using LibSafeMath for uint256;
    using LibSafeDowncast for uint256;

    modifier onlyStakingPoolOperator(bytes32 poolId) {
        _assertSenderIsPoolOperator(poolId);
        _;
    }

    function createStakingPool(address rigoblockPoolAddress)
        external
        override
        returns (bytes32 poolId)
    {
        (uint256 rbPoolId, , , , address rbPoolOwner, ) = getDragoRegistry().fromAddress(rigoblockPoolAddress);
        require(
            rbPoolId != uint256(0),
            "NON_REGISTERED_RB_POOL_ERROR"
        );
        address operator = rbPoolOwner;

        address stakingPal = msg.sender;

        uint32 operatorShare = uint32(700000);

        uint32 stakingPalShare = uint32(100000);

        _assertStakingPoolDoesNotExist(bytes32(rbPoolId));
        poolId = bytes32(rbPoolId);


        IStructs.Pool memory pool = IStructs.Pool({
            operator: operator,
            stakingPal: stakingPal,
            operatorShare: operatorShare,
            stakingPalShare : stakingPalShare
        });
        _poolById[poolId] = pool;

        emit StakingPoolCreated(poolId, operator, operatorShare);

        joinStakingPoolAsRbPoolAccount(poolId, rigoblockPoolAddress);

        return poolId;
    }

    function setStakingPalAddress(bytes32 poolId, address newStakingPalAddress)
        external
        override
        onlyStakingPoolOperator(poolId)
    {
        IStructs.Pool storage pool = _poolById[poolId];

        if (newStakingPalAddress == address(0) || pool.stakingPal == newStakingPalAddress) {
            return;
        }

        pool.stakingPal = newStakingPalAddress;
    }

    function decreaseStakingPoolOperatorShare(bytes32 poolId, uint32 newOperatorShare)
        external
        override
        onlyStakingPoolOperator(poolId)
    {
        uint32 currentOperatorShare = _poolById[poolId].operatorShare;
        _assertNewOperatorShare(
            poolId,
            currentOperatorShare,
            newOperatorShare
        );

        _poolById[poolId].operatorShare = newOperatorShare;
        emit OperatorShareDecreased(
            poolId,
            currentOperatorShare,
            newOperatorShare
        );
    }

    function joinStakingPoolAsRbPoolAccount(
        bytes32 poolId,
        address rigoblockPoolAccount)
        public
        override
    {
        (address poolAddress, , , uint256 rbPoolId, , ) = getDragoRegistry().fromId(uint256(poolId));

        if (rbPoolId == uint256(0)) {
            revert("NON_REGISTERED_POOL_ID_ERROR");
        }

        if (poolAddress != rigoblockPoolAccount) {
            revert("POOL_TO_JOIN_NOT_SELF_ERROR");
        }

        poolIdByRbPoolAccount[poolAddress] = poolId;
        emit RbPoolStakingPoolSet(
            rigoblockPoolAccount,
            poolId
        );
    }

    function getStakingPool(bytes32 poolId)
        public
        view
        override
        returns (IStructs.Pool memory)
    {
        return _poolById[poolId];
    }

    function _assertStakingPoolExists(bytes32 poolId)
        internal
        view
    {
        if (_poolById[poolId].operator == NIL_ADDRESS) {
            LibRichErrors.rrevert(
                LibStakingRichErrors.PoolExistenceError(
                    poolId,
                    false
                )
            );
        }
    }

    function _assertStakingPoolDoesNotExist(bytes32 poolId)
        internal
        view
    {
        if (_poolById[poolId].operator != NIL_ADDRESS) {
            LibRichErrors.rrevert(
                LibStakingRichErrors.PoolExistenceError(
                    poolId,
                    false
                )
            );
        }
    }

    function _assertNewOperatorShare(
        bytes32 poolId,
        uint32 currentOperatorShare,
        uint32 newOperatorShare
    )
        private
        pure
    {
        if (newOperatorShare > PPM_DENOMINATOR) {
            LibRichErrors.rrevert(LibStakingRichErrors.OperatorShareError(
                LibStakingRichErrors.OperatorShareErrorCodes.OperatorShareTooLarge,
                poolId,
                newOperatorShare
            ));
        } else if (newOperatorShare > currentOperatorShare) {
            LibRichErrors.rrevert(LibStakingRichErrors.OperatorShareError(
                LibStakingRichErrors.OperatorShareErrorCodes.CanOnlyDecreaseOperatorShare,
                poolId,
                newOperatorShare
            ));
        }
    }

    function _assertSenderIsPoolOperator(bytes32 poolId)
        private
        view
    {
        address operator = _poolById[poolId].operator;
        if (msg.sender != operator) {
            LibRichErrors.rrevert(
                LibStakingRichErrors.OnlyCallableByPoolOperatorError(
                    msg.sender,
                    poolId
                )
            );
        }
    }
}/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.5.9 <0.8.0;



abstract contract MixinStake is
    MixinStakingPool
{
    using LibSafeMath for uint256;

    function stake(uint256 amount)
        external
        override
    {
        address staker = msg.sender;

        getGrgVault().depositFrom(staker, amount);

        _increaseCurrentAndNextBalance(
            _ownerStakeByStatus[uint8(IStructs.StakeStatus.UNDELEGATED)][staker],
            amount
        );

        emit Stake(
            staker,
            amount
        );
    }

    function unstake(uint256 amount)
        external
        override
    {
        address staker = msg.sender;

        IStructs.StoredBalance memory undelegatedBalance =
            _loadCurrentBalance(_ownerStakeByStatus[uint8(IStructs.StakeStatus.UNDELEGATED)][staker]);

        uint256 currentWithdrawableStake = LibSafeMath.min256(
            undelegatedBalance.currentEpochBalance,
            undelegatedBalance.nextEpochBalance
        );

        if (amount > currentWithdrawableStake) {
            LibRichErrors.rrevert(
                LibStakingRichErrors.InsufficientBalanceError(
                    amount,
                    currentWithdrawableStake
                )
            );
        }

        _decreaseCurrentAndNextBalance(
            _ownerStakeByStatus[uint8(IStructs.StakeStatus.UNDELEGATED)][staker],
            amount
        );

        getGrgVault().withdrawFrom(staker, amount);

        emit Unstake(
            staker,
            amount
        );
    }

    function moveStake(
        IStructs.StakeInfo calldata from,
        IStructs.StakeInfo calldata to,
        uint256 amount
    )
        external
        override
    {
        address staker = msg.sender;

        if (amount == 0) {
            return;
        }

        if (from.status == IStructs.StakeStatus.UNDELEGATED &&
            to.status == IStructs.StakeStatus.UNDELEGATED) {
            return;
        }

        if (from.status == IStructs.StakeStatus.DELEGATED) {
            _undelegateStake(
                from.poolId,
                staker,
                amount
            );
        }

        if (to.status == IStructs.StakeStatus.DELEGATED) {
            _delegateStake(
                to.poolId,
                staker,
                amount
            );
        }

        IStructs.StoredBalance storage fromPtr = _ownerStakeByStatus[uint8(from.status)][staker];
        IStructs.StoredBalance storage toPtr = _ownerStakeByStatus[uint8(to.status)][staker];
        _moveStake(
            fromPtr,
            toPtr,
            amount
        );

        emit MoveStake(
            staker,
            amount,
            uint8(from.status),
            from.poolId,
            uint8(to.status),
            to.poolId
        );
    }

    function _delegateStake(
        bytes32 poolId,
        address staker,
        uint256 amount
    )
        private
    {
        _assertStakingPoolExists(poolId);

        _withdrawAndSyncDelegatorRewards(
            poolId,
            staker
        );

        _increaseNextBalance(
            _delegatedStakeToPoolByOwner[staker][poolId],
            amount
        );

        _increaseNextBalance(
            _delegatedStakeByPoolId[poolId],
            amount
        );

        _increaseNextBalance(
            _globalStakeByStatus[uint8(IStructs.StakeStatus.DELEGATED)],
            amount
        );
    }

    function _undelegateStake(
        bytes32 poolId,
        address staker,
        uint256 amount
    )
        private
    {
        _assertStakingPoolExists(poolId);

        _withdrawAndSyncDelegatorRewards(
            poolId,
            staker
        );

        _decreaseNextBalance(
            _delegatedStakeToPoolByOwner[staker][poolId],
            amount
        );

        _decreaseNextBalance(
            _delegatedStakeByPoolId[poolId],
            amount
        );

        _decreaseNextBalance(
            _globalStakeByStatus[uint8(IStructs.StakeStatus.DELEGATED)],
            amount
        );
    }
}/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.5.9 <0.8.0;



library LibFixedMathRichErrors {


    enum ValueErrorCodes {
        TOO_SMALL,
        TOO_LARGE
    }

    enum BinOpErrorCodes {
        ADDITION_OVERFLOW,
        MULTIPLICATION_OVERFLOW,
        DIVISION_BY_ZERO,
        DIVISION_OVERFLOW
    }

    bytes4 internal constant SIGNED_VALUE_ERROR_SELECTOR =
        0xed2f26a1;

    bytes4 internal constant UNSIGNED_VALUE_ERROR_SELECTOR =
        0xbd79545f;

    bytes4 internal constant BIN_OP_ERROR_SELECTOR =
        0x8c12dfe7;

    function SignedValueError(
        ValueErrorCodes error,
        int256 n
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            SIGNED_VALUE_ERROR_SELECTOR,
            uint8(error),
            n
        );
    }

    function UnsignedValueError(
        ValueErrorCodes error,
        uint256 n
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            UNSIGNED_VALUE_ERROR_SELECTOR,
            uint8(error),
            n
        );
    }

    function BinOpError(
        BinOpErrorCodes error,
        int256 a,
        int256 b
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            BIN_OP_ERROR_SELECTOR,
            uint8(error),
            a,
            b
        );
    }
}/*

  Copyright 2017 Bprotocol Foundation, 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.5.9 <0.8.0;



library LibFixedMath {


    int256 private constant FIXED_1 = int256(0x0000000000000000000000000000000080000000000000000000000000000000);
    int256 private constant MIN_FIXED_VAL = int256(0x8000000000000000000000000000000000000000000000000000000000000000);
    int256 private constant FIXED_1_SQUARED = int256(0x4000000000000000000000000000000000000000000000000000000000000000);
    int256 private constant LN_MAX_VAL = FIXED_1;
    int256 private constant LN_MIN_VAL = int256(0x0000000000000000000000000000000000000000000000000000000733048c5a);
    int256 private constant EXP_MAX_VAL = 0;
    int256 private constant EXP_MIN_VAL = -int256(0x0000000000000000000000000000001ff0000000000000000000000000000000);

    function one() internal pure returns (int256 f) {

        f = FIXED_1;
    }

    function add(int256 a, int256 b) internal pure returns (int256 c) {

        c = _add(a, b);
    }

    function sub(int256 a, int256 b) internal pure returns (int256 c) {

        if (b == MIN_FIXED_VAL) {
            LibRichErrors.rrevert(LibFixedMathRichErrors.SignedValueError(
                LibFixedMathRichErrors.ValueErrorCodes.TOO_SMALL,
                b
            ));
        }
        c = _add(a, -b);
    }

    function mul(int256 a, int256 b) internal pure returns (int256 c) {

        c = _mul(a, b) / FIXED_1;
    }

    function div(int256 a, int256 b) internal pure returns (int256 c) {

        c = _div(_mul(a, FIXED_1), b);
    }

    function mulDiv(int256 a, int256 n, int256 d) internal pure returns (int256 c) {

        c = _div(_mul(a, n), d);
    }

    function uintMul(int256 f, uint256 u) internal pure returns (uint256) {

        if (int256(u) < int256(0)) {
            LibRichErrors.rrevert(LibFixedMathRichErrors.UnsignedValueError(
                LibFixedMathRichErrors.ValueErrorCodes.TOO_LARGE,
                u
            ));
        }
        int256 c = _mul(f, int256(u));
        if (c <= 0) {
            return 0;
        }
        return uint256(uint256(c) >> 127);
    }

    function abs(int256 f) internal pure returns (int256 c) {

        if (f == MIN_FIXED_VAL) {
            LibRichErrors.rrevert(LibFixedMathRichErrors.SignedValueError(
                LibFixedMathRichErrors.ValueErrorCodes.TOO_SMALL,
                f
            ));
        }
        if (f >= 0) {
            c = f;
        } else {
            c = -f;
        }
    }

    function invert(int256 f) internal pure returns (int256 c) {

        c = _div(FIXED_1_SQUARED, f);
    }

    function toFixed(int256 n) internal pure returns (int256 f) {

        f = _mul(n, FIXED_1);
    }

    function toFixed(int256 n, int256 d) internal pure returns (int256 f) {

        f = _div(_mul(n, FIXED_1), d);
    }

    function toFixed(uint256 n) internal pure returns (int256 f) {

        if (int256(n) < int256(0)) {
            LibRichErrors.rrevert(LibFixedMathRichErrors.UnsignedValueError(
                LibFixedMathRichErrors.ValueErrorCodes.TOO_LARGE,
                n
            ));
        }
        f = _mul(int256(n), FIXED_1);
    }

    function toFixed(uint256 n, uint256 d) internal pure returns (int256 f) {

        if (int256(n) < int256(0)) {
            LibRichErrors.rrevert(LibFixedMathRichErrors.UnsignedValueError(
                LibFixedMathRichErrors.ValueErrorCodes.TOO_LARGE,
                n
            ));
        }
        if (int256(d) < int256(0)) {
            LibRichErrors.rrevert(LibFixedMathRichErrors.UnsignedValueError(
                LibFixedMathRichErrors.ValueErrorCodes.TOO_LARGE,
                d
            ));
        }
        f = _div(_mul(int256(n), FIXED_1), int256(d));
    }

    function toInteger(int256 f) internal pure returns (int256 n) {

        return f / FIXED_1;
    }

    function ln(int256 x) internal pure returns (int256 r) {

        if (x > LN_MAX_VAL) {
            LibRichErrors.rrevert(LibFixedMathRichErrors.SignedValueError(
                LibFixedMathRichErrors.ValueErrorCodes.TOO_LARGE,
                x
            ));
        }
        if (x <= 0) {
            LibRichErrors.rrevert(LibFixedMathRichErrors.SignedValueError(
                LibFixedMathRichErrors.ValueErrorCodes.TOO_SMALL,
                x
            ));
        }
        if (x == FIXED_1) {
            return 0;
        }
        if (x <= LN_MIN_VAL) {
            return EXP_MIN_VAL;
        }

        int256 y;
        int256 z;
        int256 w;

        if (x <= int256(0x00000000000000000000000000000000000000000001c8464f76164760000000)) {
            r -= int256(0x0000000000000000000000000000001000000000000000000000000000000000); // - 32
            x = x * FIXED_1 / int256(0x00000000000000000000000000000000000000000001c8464f76164760000000); // / e ^ -32
        }
        if (x <= int256(0x00000000000000000000000000000000000000f1aaddd7742e90000000000000)) {
            r -= int256(0x0000000000000000000000000000000800000000000000000000000000000000); // - 16
            x = x * FIXED_1 / int256(0x00000000000000000000000000000000000000f1aaddd7742e90000000000000); // / e ^ -16
        }
        if (x <= int256(0x00000000000000000000000000000000000afe10820813d78000000000000000)) {
            r -= int256(0x0000000000000000000000000000000400000000000000000000000000000000); // - 8
            x = x * FIXED_1 / int256(0x00000000000000000000000000000000000afe10820813d78000000000000000); // / e ^ -8
        }
        if (x <= int256(0x0000000000000000000000000000000002582ab704279ec00000000000000000)) {
            r -= int256(0x0000000000000000000000000000000200000000000000000000000000000000); // - 4
            x = x * FIXED_1 / int256(0x0000000000000000000000000000000002582ab704279ec00000000000000000); // / e ^ -4
        }
        if (x <= int256(0x000000000000000000000000000000001152aaa3bf81cc000000000000000000)) {
            r -= int256(0x0000000000000000000000000000000100000000000000000000000000000000); // - 2
            x = x * FIXED_1 / int256(0x000000000000000000000000000000001152aaa3bf81cc000000000000000000); // / e ^ -2
        }
        if (x <= int256(0x000000000000000000000000000000002f16ac6c59de70000000000000000000)) {
            r -= int256(0x0000000000000000000000000000000080000000000000000000000000000000); // - 1
            x = x * FIXED_1 / int256(0x000000000000000000000000000000002f16ac6c59de70000000000000000000); // / e ^ -1
        }
        if (x <= int256(0x000000000000000000000000000000004da2cbf1be5828000000000000000000)) {
            r -= int256(0x0000000000000000000000000000000040000000000000000000000000000000); // - 0.5
            x = x * FIXED_1 / int256(0x000000000000000000000000000000004da2cbf1be5828000000000000000000); // / e ^ -0.5
        }
        if (x <= int256(0x0000000000000000000000000000000063afbe7ab2082c000000000000000000)) {
            r -= int256(0x0000000000000000000000000000000020000000000000000000000000000000); // - 0.25
            x = x * FIXED_1 / int256(0x0000000000000000000000000000000063afbe7ab2082c000000000000000000); // / e ^ -0.25
        }
        if (x <= int256(0x0000000000000000000000000000000070f5a893b608861e1f58934f97aea57d)) {
            r -= int256(0x0000000000000000000000000000000010000000000000000000000000000000); // - 0.125
            x = x * FIXED_1 / int256(0x0000000000000000000000000000000070f5a893b608861e1f58934f97aea57d); // / e ^ -0.125
        }

        z = y = x - FIXED_1;
        w = y * y / FIXED_1;
        r += z * (0x100000000000000000000000000000000 - y) / 0x100000000000000000000000000000000; z = z * w / FIXED_1; // add y^01 / 01 - y^02 / 02
        r += z * (0x0aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa - y) / 0x200000000000000000000000000000000; z = z * w / FIXED_1; // add y^03 / 03 - y^04 / 04
        r += z * (0x099999999999999999999999999999999 - y) / 0x300000000000000000000000000000000; z = z * w / FIXED_1; // add y^05 / 05 - y^06 / 06
        r += z * (0x092492492492492492492492492492492 - y) / 0x400000000000000000000000000000000; z = z * w / FIXED_1; // add y^07 / 07 - y^08 / 08
        r += z * (0x08e38e38e38e38e38e38e38e38e38e38e - y) / 0x500000000000000000000000000000000; z = z * w / FIXED_1; // add y^09 / 09 - y^10 / 10
        r += z * (0x08ba2e8ba2e8ba2e8ba2e8ba2e8ba2e8b - y) / 0x600000000000000000000000000000000; z = z * w / FIXED_1; // add y^11 / 11 - y^12 / 12
        r += z * (0x089d89d89d89d89d89d89d89d89d89d89 - y) / 0x700000000000000000000000000000000; z = z * w / FIXED_1; // add y^13 / 13 - y^14 / 14
        r += z * (0x088888888888888888888888888888888 - y) / 0x800000000000000000000000000000000;                      // add y^15 / 15 - y^16 / 16
    }

    function exp(int256 x) internal pure returns (int256 r) {

        if (x < EXP_MIN_VAL) {
            return 0;
        }
        if (x == 0) {
            return FIXED_1;
        }
        if (x > EXP_MAX_VAL) {
            LibRichErrors.rrevert(LibFixedMathRichErrors.SignedValueError(
                LibFixedMathRichErrors.ValueErrorCodes.TOO_LARGE,
                x
            ));
        }


        int256 y;
        int256 z;
        z = y = x % 0x0000000000000000000000000000000010000000000000000000000000000000;
        z = z * y / FIXED_1; r += z * 0x10e1b3be415a0000; // add y^02 * (20! / 02!)
        z = z * y / FIXED_1; r += z * 0x05a0913f6b1e0000; // add y^03 * (20! / 03!)
        z = z * y / FIXED_1; r += z * 0x0168244fdac78000; // add y^04 * (20! / 04!)
        z = z * y / FIXED_1; r += z * 0x004807432bc18000; // add y^05 * (20! / 05!)
        z = z * y / FIXED_1; r += z * 0x000c0135dca04000; // add y^06 * (20! / 06!)
        z = z * y / FIXED_1; r += z * 0x0001b707b1cdc000; // add y^07 * (20! / 07!)
        z = z * y / FIXED_1; r += z * 0x000036e0f639b800; // add y^08 * (20! / 08!)
        z = z * y / FIXED_1; r += z * 0x00000618fee9f800; // add y^09 * (20! / 09!)
        z = z * y / FIXED_1; r += z * 0x0000009c197dcc00; // add y^10 * (20! / 10!)
        z = z * y / FIXED_1; r += z * 0x0000000e30dce400; // add y^11 * (20! / 11!)
        z = z * y / FIXED_1; r += z * 0x000000012ebd1300; // add y^12 * (20! / 12!)
        z = z * y / FIXED_1; r += z * 0x0000000017499f00; // add y^13 * (20! / 13!)
        z = z * y / FIXED_1; r += z * 0x0000000001a9d480; // add y^14 * (20! / 14!)
        z = z * y / FIXED_1; r += z * 0x00000000001c6380; // add y^15 * (20! / 15!)
        z = z * y / FIXED_1; r += z * 0x000000000001c638; // add y^16 * (20! / 16!)
        z = z * y / FIXED_1; r += z * 0x0000000000001ab8; // add y^17 * (20! / 17!)
        z = z * y / FIXED_1; r += z * 0x000000000000017c; // add y^18 * (20! / 18!)
        z = z * y / FIXED_1; r += z * 0x0000000000000014; // add y^19 * (20! / 19!)
        z = z * y / FIXED_1; r += z * 0x0000000000000001; // add y^20 * (20! / 20!)
        r = r / 0x21c3677c82b40000 + y + FIXED_1; // divide by 20! and then add y^1 / 1! + y^0 / 0!

        x = -x;
        if ((x & int256(0x0000000000000000000000000000001000000000000000000000000000000000)) != 0) {
            r = r * int256(0x00000000000000000000000000000000000000f1aaddd7742e56d32fb9f99744)
                / int256(0x0000000000000000000000000043cbaf42a000812488fc5c220ad7b97bf6e99e); // * e ^ -32
        }
        if ((x & int256(0x0000000000000000000000000000000800000000000000000000000000000000)) != 0) {
            r = r * int256(0x00000000000000000000000000000000000afe10820813d65dfe6a33c07f738f)
                / int256(0x000000000000000000000000000005d27a9f51c31b7c2f8038212a0574779991); // * e ^ -16
        }
        if ((x & int256(0x0000000000000000000000000000000400000000000000000000000000000000)) != 0) {
            r = r * int256(0x0000000000000000000000000000000002582ab704279e8efd15e0265855c47a)
                / int256(0x0000000000000000000000000000001b4c902e273a58678d6d3bfdb93db96d02); // * e ^ -8
        }
        if ((x & int256(0x0000000000000000000000000000000200000000000000000000000000000000)) != 0) {
            r = r * int256(0x000000000000000000000000000000001152aaa3bf81cb9fdb76eae12d029571)
                / int256(0x00000000000000000000000000000003b1cc971a9bb5b9867477440d6d157750); // * e ^ -4
        }
        if ((x & int256(0x0000000000000000000000000000000100000000000000000000000000000000)) != 0) {
            r = r * int256(0x000000000000000000000000000000002f16ac6c59de6f8d5d6f63c1482a7c86)
                / int256(0x000000000000000000000000000000015bf0a8b1457695355fb8ac404e7a79e3); // * e ^ -2
        }
        if ((x & int256(0x0000000000000000000000000000000080000000000000000000000000000000)) != 0) {
            r = r * int256(0x000000000000000000000000000000004da2cbf1be5827f9eb3ad1aa9866ebb3)
                / int256(0x00000000000000000000000000000000d3094c70f034de4b96ff7d5b6f99fcd8); // * e ^ -1
        }
        if ((x & int256(0x0000000000000000000000000000000040000000000000000000000000000000)) != 0) {
            r = r * int256(0x0000000000000000000000000000000063afbe7ab2082ba1a0ae5e4eb1b479dc)
                / int256(0x00000000000000000000000000000000a45af1e1f40c333b3de1db4dd55f29a7); // * e ^ -0.5
        }
        if ((x & int256(0x0000000000000000000000000000000020000000000000000000000000000000)) != 0) {
            r = r * int256(0x0000000000000000000000000000000070f5a893b608861e1f58934f97aea57d)
                / int256(0x00000000000000000000000000000000910b022db7ae67ce76b441c27035c6a1); // * e ^ -0.25
        }
        if ((x & int256(0x0000000000000000000000000000000010000000000000000000000000000000)) != 0) {
            r = r * int256(0x00000000000000000000000000000000783eafef1c0a8f3978c7f81824d62ebf)
                / int256(0x0000000000000000000000000000000088415abbe9a76bead8d00cf112e4d4a8); // * e ^ -0.125
        }
    }

    function _mul(int256 a, int256 b) private pure returns (int256 c) {

        if (a == 0 || b == 0) {
            return 0;
        }
        c = a * b;
        if (c / a != b || c / b != a) {
            LibRichErrors.rrevert(LibFixedMathRichErrors.BinOpError(
                LibFixedMathRichErrors.BinOpErrorCodes.MULTIPLICATION_OVERFLOW,
                a,
                b
            ));
        }
    }

    function _div(int256 a, int256 b) private pure returns (int256 c) {

        if (b == 0) {
            LibRichErrors.rrevert(LibFixedMathRichErrors.BinOpError(
                LibFixedMathRichErrors.BinOpErrorCodes.DIVISION_BY_ZERO,
                a,
                b
            ));
        }
        if (a == MIN_FIXED_VAL && b == -1) {
            LibRichErrors.rrevert(LibFixedMathRichErrors.BinOpError(
                LibFixedMathRichErrors.BinOpErrorCodes.DIVISION_OVERFLOW,
                a,
                b
            ));
        }
        c = a / b;
    }

    function _add(int256 a, int256 b) private pure returns (int256 c) {

        c = a + b;
        if ((a < 0 && b < 0 && c > a) || (a > 0 && b > 0 && c < a)) {
            LibRichErrors.rrevert(LibFixedMathRichErrors.BinOpError(
                LibFixedMathRichErrors.BinOpErrorCodes.ADDITION_OVERFLOW,
                a,
                b
            ));
        }
    }
}/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.5.9 <0.8.0;



library LibCobbDouglas {


    function cobbDouglas(
        uint256 totalRewards,
        uint256 fees,
        uint256 totalFees,
        uint256 stake,
        uint256 totalStake,
        uint32 alphaNumerator,
        uint32 alphaDenominator
    )
        internal
        pure
        returns (uint256 rewards)
    {

        int256 feeRatio = LibFixedMath.toFixed(fees, totalFees);
        int256 stakeRatio = LibFixedMath.toFixed(stake, totalStake);
        if (feeRatio == 0 || stakeRatio == 0) {
            return rewards = 0;
        }

        int256 n = feeRatio <= stakeRatio ?
            LibFixedMath.div(feeRatio, stakeRatio) :
            LibFixedMath.div(stakeRatio, feeRatio);
        n = LibFixedMath.exp(
            LibFixedMath.mulDiv(
                LibFixedMath.ln(n),
                int256(alphaNumerator),
                int256(alphaDenominator)
            )
        );
        n = feeRatio <= stakeRatio ?
            LibFixedMath.mul(stakeRatio, n) :
            LibFixedMath.div(stakeRatio, n);
        rewards = LibFixedMath.uintMul(n, totalRewards);
    }
}/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.5.9 <0.8.0;



abstract contract MixinFinalizer is
    MixinStakingPoolRewards
{
    using LibSafeMath for uint256;

    function endEpoch()
        external
        override
        returns (uint256)
    {
        uint256 currentEpoch_ = currentEpoch;
        uint256 prevEpoch = currentEpoch_.safeSub(1);

        uint256 numPoolsToFinalizeFromPrevEpoch = aggregatedStatsByEpoch[prevEpoch].numPoolsToFinalize;
        if (numPoolsToFinalizeFromPrevEpoch != 0) {
            LibRichErrors.rrevert(
                LibStakingRichErrors.PreviousEpochNotFinalizedError(
                    prevEpoch,
                    numPoolsToFinalizeFromPrevEpoch
                )
            );
        }

        if (currentEpoch_ > uint256(1)) {
            try InflationFace(getGrgContract().minter()).mintInflation() returns (uint256 mintedInflation) {
                emit GrgMintEvent(mintedInflation);
            } catch Error(string memory revertReason) {
                emit CatchStringEvent(revertReason);
            } catch (bytes memory returnData) {
                emit ReturnDataEvent(returnData);
            }
        }

        aggregatedStatsByEpoch[currentEpoch_].rewardsAvailable = _getAvailableGrgBalance();
        IStructs.AggregatedStats memory aggregatedStats = aggregatedStatsByEpoch[currentEpoch_];

        emit EpochEnded(
            currentEpoch_,
            aggregatedStats.numPoolsToFinalize,
            aggregatedStats.rewardsAvailable,
            aggregatedStats.totalFeesCollected,
            aggregatedStats.totalWeightedStake
        );

        _goToNextEpoch();

        if (aggregatedStats.numPoolsToFinalize == 0) {
            emit EpochFinalized(currentEpoch_, 0, aggregatedStats.rewardsAvailable);
        }

        return aggregatedStats.numPoolsToFinalize;
    }

    function finalizePool(bytes32 poolId)
        external
        override
    {
        uint256 currentEpoch_ = currentEpoch;
        uint256 prevEpoch = currentEpoch_.safeSub(1);

        IStructs.AggregatedStats memory aggregatedStats = aggregatedStatsByEpoch[prevEpoch];
        if (aggregatedStats.numPoolsToFinalize == 0) {
            return;
        }

        IStructs.PoolStats memory poolStats = poolStatsByEpoch[poolId][prevEpoch];
        if (poolStats.feesCollected == 0) {
            return;
        }

        delete poolStatsByEpoch[poolId][prevEpoch];

        uint256 rewards = _getUnfinalizedPoolRewardsFromPoolStats(poolStats, aggregatedStats);

        (uint256 operatorReward, uint256 membersReward) = _syncPoolRewards(
            poolId,
            rewards,
            poolStats.membersStake
        );

        emit RewardsPaid(
            currentEpoch_,
            poolId,
            operatorReward,
            membersReward
        );

        uint256 totalReward = operatorReward.safeAdd(membersReward);

        aggregatedStatsByEpoch[prevEpoch].totalRewardsFinalized =
            aggregatedStats.totalRewardsFinalized =
            aggregatedStats.totalRewardsFinalized.safeAdd(totalReward);

        aggregatedStatsByEpoch[prevEpoch].numPoolsToFinalize =
            aggregatedStats.numPoolsToFinalize =
            aggregatedStats.numPoolsToFinalize.safeSub(1);

        if (aggregatedStats.numPoolsToFinalize == 0) {
            emit EpochFinalized(
                prevEpoch,
                aggregatedStats.totalRewardsFinalized,
                aggregatedStats.rewardsAvailable.safeSub(aggregatedStats.totalRewardsFinalized)
            );
        }
    }

    function _getUnfinalizedPoolRewards(bytes32 poolId)
        internal
        view
        virtual
        override
        returns (
            uint256 reward,
            uint256 membersStake
        )
    {
        uint256 prevEpoch = currentEpoch.safeSub(1);
        IStructs.PoolStats memory poolStats = poolStatsByEpoch[poolId][prevEpoch];
        reward = _getUnfinalizedPoolRewardsFromPoolStats(poolStats, aggregatedStatsByEpoch[prevEpoch]);
        membersStake = poolStats.membersStake;
    }

    function _getAvailableGrgBalance()
        internal
        view
        returns (uint256 grgBalance)
    {
        grgBalance = getGrgContract().balanceOf(address(this))
            .safeSub(grgReservedForPoolRewards);

        return grgBalance;
    }

    function _assertPoolFinalizedLastEpoch(bytes32 poolId)
        internal
        view
        virtual
        override
    {
        uint256 prevEpoch = currentEpoch.safeSub(1);
        IStructs.PoolStats memory poolStats = poolStatsByEpoch[poolId][prevEpoch];

        if (poolStats.feesCollected != 0) {
            LibRichErrors.rrevert(
                LibStakingRichErrors.PoolNotFinalizedError(
                    poolId,
                    prevEpoch
                )
            );
        }
    }

    function _getUnfinalizedPoolRewardsFromPoolStats(
        IStructs.PoolStats memory poolStats,
        IStructs.AggregatedStats memory aggregatedStats
    )
        private
        view
        returns (uint256 rewards)
    {
        if (poolStats.feesCollected == 0) {
            return rewards;
        }

        rewards = LibCobbDouglas.cobbDouglas(
            aggregatedStats.rewardsAvailable,
            poolStats.feesCollected,
            aggregatedStats.totalFeesCollected,
            poolStats.weightedStake,
            aggregatedStats.totalWeightedStake,
            cobbDouglasAlphaNumerator,
            cobbDouglasAlphaDenominator
        );

        uint256 rewardsRemaining = aggregatedStats.rewardsAvailable.safeSub(aggregatedStats.totalRewardsFinalized);
        if (rewardsRemaining < rewards) {
            rewards = rewardsRemaining;
        }
    }
}/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.5.9 <0.8.0;



abstract contract MixinPopManager is
    IStaking,
    IStakingEvents,
    MixinStorage
{
    modifier onlyPop() {
        if (!validPops[msg.sender]) {
            LibRichErrors.rrevert(LibStakingRichErrors.OnlyCallableByPopError(
                msg.sender
            ));
        }
        _;
    }

    function addPopAddress(address addr)
        external
        override
        onlyAuthorized
    {
        if (validPops[addr]) {
            LibRichErrors.rrevert(LibStakingRichErrors.PopManagerError(
                LibStakingRichErrors.PopManagerErrorCodes.PopAlreadyRegistered,
                addr
            ));
        }
        validPops[addr] = true;
        emit PopAdded(addr);
    }

    function removePopAddress(address addr)
        external
        override
        onlyAuthorized
    {
        if (!validPops[addr]) {
            LibRichErrors.rrevert(LibStakingRichErrors.PopManagerError(
                LibStakingRichErrors.PopManagerErrorCodes.PopNotRegistered,
                addr
            ));
        }
        validPops[addr] = false;
        emit PopRemoved(addr);
    }
}/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.5.9 <0.8.0;



abstract contract MixinPopRewards is
    MixinPopManager,
    MixinStakingPool,
    MixinFinalizer
{
    using LibSafeMath for uint256;

    function creditPopReward(
        address poolAccount,
        uint256 popReward
    )
        external
        payable
        override
        onlyPop
    {
        bytes32 poolId = poolIdByRbPoolAccount[poolAccount];

        if (poolId == NIL_POOL_ID) {
            return;
        }

        uint256 poolStake = getTotalStakeDelegatedToPool(poolId).currentEpochBalance;
        if (poolStake < minimumPoolStake) {
            return;
        }

        uint256 currentEpoch_ = currentEpoch;
        IStructs.PoolStats storage poolStatsPtr = poolStatsByEpoch[poolId][currentEpoch_];
        IStructs.AggregatedStats storage aggregatedStatsPtr = aggregatedStatsByEpoch[currentEpoch_];

        uint256 feesCollectedByPool = poolStatsPtr.feesCollected;
        if (feesCollectedByPool == 0) {
            (uint256 membersStakeInPool, uint256 weightedStakeInPool) = _computeMembersAndWeightedStake(poolId, poolStake);
            poolStatsPtr.membersStake = membersStakeInPool;
            poolStatsPtr.weightedStake = weightedStakeInPool;

            aggregatedStatsPtr.totalWeightedStake = aggregatedStatsPtr.totalWeightedStake.safeAdd(weightedStakeInPool);

            aggregatedStatsPtr.numPoolsToFinalize = aggregatedStatsPtr.numPoolsToFinalize.safeAdd(1);

            emit StakingPoolEarnedRewardsInEpoch(currentEpoch_, poolId);
        }

        if (popReward > feesCollectedByPool) {
            poolStatsPtr.feesCollected = popReward;

            aggregatedStatsPtr.totalFeesCollected = aggregatedStatsPtr
                .totalFeesCollected
                .safeAdd(popReward)
                .safeSub(feesCollectedByPool);
        }
    }

    function getStakingPoolStatsThisEpoch(bytes32 poolId)
        external
        view
        override
        returns (IStructs.PoolStats memory)
    {
        return poolStatsByEpoch[poolId][currentEpoch];
    }

    function _computeMembersAndWeightedStake(
        bytes32 poolId,
        uint256 totalStake
    )
        private
        view
        returns (uint256 membersStake, uint256 weightedStake)
    {
        uint256 operatorStake = getStakeDelegatedToPoolByOwner(
            _poolById[poolId].operator,
            poolId
        ).currentEpochBalance;

        membersStake = totalStake.safeSub(operatorStake);
        weightedStake = operatorStake.safeAdd(
            LibMath.getPartialAmountFloor(
                rewardDelegatedStakeWeight,
                PPM_DENOMINATOR,
                membersStake
            )
        );
        return (membersStake, weightedStake);
    }
}// Apache 2.0


pragma solidity 0.7.4;



contract Staking is
    IStaking,
    MixinParams,
    MixinStake,
    MixinPopRewards
{

    function init()
        public
        override
        onlyAuthorized
    {

        _initMixinScheduler();
        _initMixinParams();
    }
}