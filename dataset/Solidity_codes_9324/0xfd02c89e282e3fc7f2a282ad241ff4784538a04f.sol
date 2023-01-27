
pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}// Apache-2.0
pragma solidity ^0.8.2;
pragma experimental ABIEncoderV2;


interface IBridge {

    struct TONEvent {
        uint64 eventTransactionLt;
        uint32 eventTimestamp;
        bytes eventData;
        int8 configurationWid;
        uint256 configurationAddress;
        int8 eventContractWid;
        uint256 eventContractAddress;
        address proxy;
        uint32 round;
    }

    struct Round {
        uint32 end;
        uint32 ttl;
        uint32 relays;
        uint32 requiredSignatures;
    }

    struct TONAddress {
        int8 wid;
        uint256 addr;
    }

    function updateMinimumRequiredSignatures(uint32 _minimumRequiredSignatures) external;

    function updateRoundRelaysConfiguration(TONAddress calldata _roundRelaysConfiguration) external;

    function updateRoundTTL(uint32 _roundTTL) external;


    function isRelay(
        uint32 round,
        address candidate
    ) external view returns(bool);


    function isBanned(
        address candidate
    ) external view returns(bool);


    function isRoundRotten(
        uint32 round
    ) external view returns(bool);


    function verifySignedTonEvent(
        bytes memory payload,
        bytes[] memory signatures
    ) external view returns(uint32);


    function setRoundRelays(
        bytes calldata payload,
        bytes[] calldata signatures
    ) external;


    function forceRoundRelays(
        uint160[] calldata _relays,
        uint32 roundEnd
    ) external;


    function banRelays(
        address[] calldata _relays
    ) external;


    function unbanRelays(
        address[] calldata _relays
    ) external;


    function pause() external;

    function unpause() external;


    function setRoundSubmitter(address _roundSubmitter) external;


    event EmergencyShutdown(bool active);

    event UpdateMinimumRequiredSignatures(uint32 value);
    event UpdateRoundTTL(uint32 value);
    event UpdateRoundRelaysConfiguration(TONAddress configuration);
    event UpdateRoundSubmitter(address _roundSubmitter);

    event NewRound(uint32 indexed round, Round meta);
    event RoundRelay(uint32 indexed round, address indexed relay);
    event BanRelay(address indexed relay, bool status);
}// Apache-2.0
pragma solidity ^0.8.2;


interface IVault {

    struct TONAddress {
        int128 wid;
        uint256 addr;
    }

    struct StrategyParams {
        uint256 performanceFee;
        uint256 activation;
        uint256 debtRatio;
        uint256 minDebtPerHarvest;
        uint256 maxDebtPerHarvest;
        uint256 lastReport;
        uint256 totalDebt;
        uint256 totalGain;
        uint256 totalSkim;
        uint256 totalLoss;
        address rewardsManager;
        TONAddress rewards;
    }


    struct PendingWithdrawalId {
        address recipient;
        uint256 id;
    }

    function saveWithdraw(
        bytes32 payloadId,
        address recipient,
        uint256 amount,
        uint256 timestamp,
        uint256 bounty
    ) external;


    function deposit(
        address sender,
        TONAddress calldata recipient,
        uint256 _amount,
        PendingWithdrawalId calldata pendingWithdrawalId,
        bool sendTransferToTon
    ) external;


    function forceWithdraw(
        address recipient,
        uint256 id
    ) external;


    function setPendingWithdrawApprove(
        address recipient,
        uint256 id,
        uint256 approveStatus
    ) external;


    function configuration() external view returns(TONAddress memory _configuration);

    function bridge() external view returns(address);

    function apiVersion() external view returns(string memory api_version);


    function initialize(
        address _token,
        address _governance,
        address _bridge,
        uint256 _targetDecimals
    ) external;


    function setWrapper(address _wrapper) external;

    function setGuardian(address _guardian) external;

    function setManagement(address _management) external;

    function setGovernance(address _governance) external;


    function debtOutstanding() external view returns (uint256);

    function creditAvailable() external view returns (uint256);

    function report(uint256 profit, uint256 loss, uint256 debtPayment) external returns (uint256);

    function revokeStrategy() external;


    function strategies(address strategy) external view returns (StrategyParams memory);


    function governance() external view returns(address);

    function token() external view returns(address);

    function guardian() external view returns(address);

    function withdrawGuardian() external view returns(address);

    function management() external view returns(address);

    function wrapper() external view returns(address);


    function tokenDecimals() external view returns(uint256);

    function targetDecimals() external view returns(uint256);

}// Apache-2.0
pragma solidity ^0.8.2;


interface IVaultWrapper {

    function initialize(address _vault) external;

    function apiVersion() external view returns(string memory);

}// Apache-2.0
pragma solidity ^0.8.2;


contract ChainId {

    function getChainID() public view returns (uint256) {

        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }
}// Apache-2.0
pragma solidity ^0.8.2;





contract VaultWrapper is ChainId, Initializable, IVaultWrapper {

    address constant ZERO_ADDRESS = 0x0000000000000000000000000000000000000000;
    string constant API_VERSION = "0.1.3";

    address public vault;

    function initialize(
        address _vault
    ) external override initializer {

        vault = _vault;
    }

    function apiVersion()
        external
        override
        pure
    returns (
        string memory api_version
    ) {

        return API_VERSION;
    }

    function deposit(
        IVault.TONAddress memory recipient,
        uint256 amount
    ) external {

        IVault.PendingWithdrawalId memory pendingWithdrawalId = IVault.PendingWithdrawalId(ZERO_ADDRESS, 0);

        IVault(vault).deposit(
            msg.sender,
            recipient,
            amount,
            pendingWithdrawalId,
            true
        );
    }

    event FactoryDeposit(
        uint128 amount,
        int8 wid,
        uint256 user,
        uint256 creditor,
        uint256 recipient,
        uint128 tokenAmount,
        uint128 tonAmount,
        uint8 swapType,
        uint128 slippageNumerator,
        uint128 slippageDenominator,
        bytes1 separator,
        bytes level3
    );

    function _convertToTargetDecimals(uint128 amount) internal view returns(uint128) {

        uint256 targetDecimals = IVault(vault).targetDecimals();
        uint256 tokenDecimals = IVault(vault).tokenDecimals();

        if (targetDecimals == tokenDecimals) {
            return amount;
        } else if (targetDecimals > tokenDecimals) {
            return uint128(amount * 10 ** (targetDecimals - tokenDecimals));
        } else {
            return uint128(amount / 10 ** (tokenDecimals - targetDecimals));
        }
    }

    function depositToFactory(
        uint128 amount,
        int8 wid,
        uint256 user,
        uint256 creditor,
        uint256 recipient,
        uint128 tokenAmount,
        uint128 tonAmount,
        uint8 swapType,
        uint128 slippageNumerator,
        uint128 slippageDenominator,
        bytes memory level3
    ) external {

        require(
            tokenAmount <= amount &&
            swapType < 2 &&
            user != 0 &&
            recipient != 0 &&
            creditor != 0 &&
            slippageNumerator < slippageDenominator,
            "Wrapper: wrong args"
        );

        IVault(vault).deposit(
            msg.sender,
            IVault.TONAddress(0, 0),
            amount,
            IVault.PendingWithdrawalId(ZERO_ADDRESS, 0),
            false
        );

        emit FactoryDeposit(
            _convertToTargetDecimals(amount),
            wid,
            user,
            creditor,
            recipient,
            tokenAmount,
            tonAmount,
            swapType,
            slippageNumerator,
            slippageDenominator,
            0x07,
            level3
        );
    }

    function depositWithFillings(
        IVault.TONAddress calldata recipient,
        uint256 amount,
        IVault.PendingWithdrawalId[] calldata pendingWithdrawalsIdsToFill
    ) external {

        require(
            pendingWithdrawalsIdsToFill.length > 0,
            'Wrapper: no pending withdrawals specified'
        );

        for (uint i = 0; i < pendingWithdrawalsIdsToFill.length; i++) {
            IVault(vault).deposit(
                msg.sender,
                recipient,
                amount,
                pendingWithdrawalsIdsToFill[i],
                true
            );
        }
    }

    function forceWithdraw(
        IVault.PendingWithdrawalId[] calldata pendingWithdrawalsIdsToWithdraw
    ) external {

        require(
            pendingWithdrawalsIdsToWithdraw.length > 0,
            'Wrapper: no pending withdrawals specified'
        );

        for (uint i = 0; i < pendingWithdrawalsIdsToWithdraw.length; i++) {
            IVault(vault).forceWithdraw(
                pendingWithdrawalsIdsToWithdraw[i].recipient,
                pendingWithdrawalsIdsToWithdraw[i].id
            );
        }
    }

    function decodeWithdrawEventData(
        bytes memory payload
    ) public pure returns (
        int8 sender_wid,
        uint256 sender_addr,
        uint128 amount,
        uint160 _recipient,
        uint32 chainId
    ) {

        (IBridge.TONEvent memory tonEvent) = abi.decode(payload, (IBridge.TONEvent));

        return abi.decode(
            tonEvent.eventData,
            (int8, uint256, uint128, uint160, uint32)
        );
    }

    function saveWithdraw(
        bytes calldata payload,
        bytes[] calldata signatures,
        uint256 bounty
    ) external {

        address bridge = IVault(vault).bridge();

        require(
            IBridge(bridge).verifySignedTonEvent(
                payload,
                signatures
            ) == 0,
            "Vault wrapper: signatures verification failed"
        );

        (IBridge.TONEvent memory tonEvent) = abi.decode(payload, (IBridge.TONEvent));

        {
            IVault.TONAddress memory configuration = IVault(vault).configuration();

            require(
                tonEvent.configurationWid == configuration.wid &&
                tonEvent.configurationAddress == configuration.addr,
                "Vault wrapper: wrong event configuration"
            );
        }

        (
            int8 sender_wid,
            uint256 sender_addr,
            uint128 amount,
            uint160 _recipient,
            uint32 chainId
        ) = decodeWithdrawEventData(payload);

        require(chainId == getChainID(), "Vault wrapper: wrong chain id");

        address recipient = address(_recipient);

        IVault(vault).saveWithdraw(
            keccak256(payload),
            recipient,
            amount,
            uint256(tonEvent.eventTimestamp),
            recipient == msg.sender ? bounty : 0
        );
    }

    function setPendingWithdrawApprove(
        IVault.PendingWithdrawalId[] calldata pendingWithdrawalsIdsToApprove,
        uint[] calldata approveStatuses
    ) external {

        require(
            msg.sender == IVault(vault).governance() || msg.sender == IVault(vault).withdrawGuardian(),
            "Vault wrapper: wrong sender"
        );

        require(approveStatuses.length == pendingWithdrawalsIdsToApprove.length);

        for (uint i = 0; i < pendingWithdrawalsIdsToApprove.length; i++) {
            IVault(vault).setPendingWithdrawApprove(
                pendingWithdrawalsIdsToApprove[i].recipient,
                pendingWithdrawalsIdsToApprove[i].id,
                approveStatuses[i]
            );
        }
    }
}