
pragma solidity ^0.8.0;

library ECDSA {

    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {

        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {

        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// MIT
pragma solidity 0.8.9;

interface IAuthorizationUtils {

    function checkAuthorizationStatus(
        address[] calldata authorizers,
        address airnode,
        bytes32 requestId,
        bytes32 endpointId,
        address sponsor,
        address requester
    ) external view returns (bool status);


    function checkAuthorizationStatuses(
        address[] calldata authorizers,
        address airnode,
        bytes32[] calldata requestIds,
        bytes32[] calldata endpointIds,
        address[] calldata sponsors,
        address[] calldata requesters
    ) external view returns (bool[] memory statuses);

}// MIT
pragma solidity 0.8.9;

interface IAuthorizer {

    function isAuthorized(
        bytes32 requestId,
        address airnode,
        bytes32 endpointId,
        address sponsor,
        address requester
    ) external view returns (bool);

}// MIT
pragma solidity 0.8.9;


contract AuthorizationUtils is IAuthorizationUtils {

    function checkAuthorizationStatus(
        address[] calldata authorizers,
        address airnode,
        bytes32 requestId,
        bytes32 endpointId,
        address sponsor,
        address requester
    ) public view override returns (bool status) {

        for (uint256 ind = 0; ind < authorizers.length; ind++) {
            IAuthorizer authorizer = IAuthorizer(authorizers[ind]);
            if (
                authorizer.isAuthorized(
                    requestId,
                    airnode,
                    endpointId,
                    sponsor,
                    requester
                )
            ) {
                return true;
            }
        }
        return false;
    }

    function checkAuthorizationStatuses(
        address[] calldata authorizers,
        address airnode,
        bytes32[] calldata requestIds,
        bytes32[] calldata endpointIds,
        address[] calldata sponsors,
        address[] calldata requesters
    ) external view override returns (bool[] memory statuses) {

        require(
            requestIds.length == endpointIds.length &&
                requestIds.length == sponsors.length &&
                requestIds.length == requesters.length,
            "Unequal parameter lengths"
        );
        statuses = new bool[](requestIds.length);
        for (uint256 ind = 0; ind < requestIds.length; ind++) {
            statuses[ind] = checkAuthorizationStatus(
                authorizers,
                airnode,
                requestIds[ind],
                endpointIds[ind],
                sponsors[ind],
                requesters[ind]
            );
        }
    }
}// MIT
pragma solidity 0.8.9;

interface ITemplateUtils {

    event CreatedTemplate(
        bytes32 indexed templateId,
        address airnode,
        bytes32 endpointId,
        bytes parameters
    );

    function createTemplate(
        address airnode,
        bytes32 endpointId,
        bytes calldata parameters
    ) external returns (bytes32 templateId);


    function getTemplates(bytes32[] calldata templateIds)
        external
        view
        returns (
            address[] memory airnodes,
            bytes32[] memory endpointIds,
            bytes[] memory parameters
        );


    function templates(bytes32 templateId)
        external
        view
        returns (
            address airnode,
            bytes32 endpointId,
            bytes memory parameters
        );

}// MIT
pragma solidity 0.8.9;


contract TemplateUtils is ITemplateUtils {

    struct Template {
        address airnode;
        bytes32 endpointId;
        bytes parameters;
    }

    mapping(bytes32 => Template) public override templates;

    function createTemplate(
        address airnode,
        bytes32 endpointId,
        bytes calldata parameters
    ) external override returns (bytes32 templateId) {

        require(airnode != address(0), "Airnode address zero");
        templateId = keccak256(
            abi.encodePacked(airnode, endpointId, parameters)
        );
        templates[templateId] = Template({
            airnode: airnode,
            endpointId: endpointId,
            parameters: parameters
        });
        emit CreatedTemplate(templateId, airnode, endpointId, parameters);
    }

    function getTemplates(bytes32[] calldata templateIds)
        external
        view
        override
        returns (
            address[] memory airnodes,
            bytes32[] memory endpointIds,
            bytes[] memory parameters
        )
    {

        airnodes = new address[](templateIds.length);
        endpointIds = new bytes32[](templateIds.length);
        parameters = new bytes[](templateIds.length);
        for (uint256 ind = 0; ind < templateIds.length; ind++) {
            Template storage template = templates[templateIds[ind]];
            airnodes[ind] = template.airnode;
            endpointIds[ind] = template.endpointId;
            parameters[ind] = template.parameters;
        }
    }
}// MIT
pragma solidity 0.8.9;

interface IWithdrawalUtils {

    event RequestedWithdrawal(
        address indexed airnode,
        address indexed sponsor,
        bytes32 indexed withdrawalRequestId,
        address sponsorWallet
    );

    event FulfilledWithdrawal(
        address indexed airnode,
        address indexed sponsor,
        bytes32 indexed withdrawalRequestId,
        address sponsorWallet,
        uint256 amount
    );

    function requestWithdrawal(address airnode, address sponsorWallet) external;


    function fulfillWithdrawal(
        bytes32 withdrawalRequestId,
        address airnode,
        address sponsor
    ) external payable;


    function sponsorToWithdrawalRequestCount(address sponsor)
        external
        view
        returns (uint256 withdrawalRequestCount);

}// MIT
pragma solidity 0.8.9;


contract WithdrawalUtils is IWithdrawalUtils {

    mapping(address => uint256) public override sponsorToWithdrawalRequestCount;

    mapping(bytes32 => bytes32) private withdrawalRequestIdToParameters;

    function requestWithdrawal(address airnode, address sponsorWallet)
        external
        override
    {

        bytes32 withdrawalRequestId = keccak256(
            abi.encodePacked(
                block.chainid,
                address(this),
                msg.sender,
                ++sponsorToWithdrawalRequestCount[msg.sender]
            )
        );
        withdrawalRequestIdToParameters[withdrawalRequestId] = keccak256(
            abi.encodePacked(airnode, msg.sender, sponsorWallet)
        );
        emit RequestedWithdrawal(
            airnode,
            msg.sender,
            withdrawalRequestId,
            sponsorWallet
        );
    }

    function fulfillWithdrawal(
        bytes32 withdrawalRequestId,
        address airnode,
        address sponsor
    ) external payable override {

        require(
            withdrawalRequestIdToParameters[withdrawalRequestId] ==
                keccak256(abi.encodePacked(airnode, sponsor, msg.sender)),
            "Invalid withdrawal fulfillment"
        );
        delete withdrawalRequestIdToParameters[withdrawalRequestId];
        emit FulfilledWithdrawal(
            airnode,
            sponsor,
            withdrawalRequestId,
            msg.sender,
            msg.value
        );
        (bool success, ) = sponsor.call{value: msg.value}(""); // solhint-disable-line avoid-low-level-calls
        require(success, "Transfer failed");
    }
}// MIT
pragma solidity 0.8.9;


interface IAirnodeRrp is IAuthorizationUtils, ITemplateUtils, IWithdrawalUtils {

    event SetSponsorshipStatus(
        address indexed sponsor,
        address indexed requester,
        bool sponsorshipStatus
    );

    event MadeTemplateRequest(
        address indexed airnode,
        bytes32 indexed requestId,
        uint256 requesterRequestCount,
        uint256 chainId,
        address requester,
        bytes32 templateId,
        address sponsor,
        address sponsorWallet,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes parameters
    );

    event MadeFullRequest(
        address indexed airnode,
        bytes32 indexed requestId,
        uint256 requesterRequestCount,
        uint256 chainId,
        address requester,
        bytes32 endpointId,
        address sponsor,
        address sponsorWallet,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes parameters
    );

    event FulfilledRequest(
        address indexed airnode,
        bytes32 indexed requestId,
        bytes data
    );

    event FailedRequest(
        address indexed airnode,
        bytes32 indexed requestId,
        string errorMessage
    );

    function setSponsorshipStatus(address requester, bool sponsorshipStatus)
        external;


    function makeTemplateRequest(
        bytes32 templateId,
        address sponsor,
        address sponsorWallet,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes calldata parameters
    ) external returns (bytes32 requestId);


    function makeFullRequest(
        address airnode,
        bytes32 endpointId,
        address sponsor,
        address sponsorWallet,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes calldata parameters
    ) external returns (bytes32 requestId);


    function fulfill(
        bytes32 requestId,
        address airnode,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes calldata data,
        bytes calldata signature
    ) external returns (bool callSuccess, bytes memory callData);


    function fail(
        bytes32 requestId,
        address airnode,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        string calldata errorMessage
    ) external;


    function sponsorToRequesterToSponsorshipStatus(
        address sponsor,
        address requester
    ) external view returns (bool sponsorshipStatus);


    function requesterToRequestCountPlusOne(address requester)
        external
        view
        returns (uint256 requestCountPlusOne);


    function requestIsAwaitingFulfillment(bytes32 requestId)
        external
        view
        returns (bool isAwaitingFulfillment);

}// MIT
pragma solidity 0.8.9;


contract AirnodeRrp is
    AuthorizationUtils,
    TemplateUtils,
    WithdrawalUtils,
    IAirnodeRrp
{

    using ECDSA for bytes32;

    mapping(address => mapping(address => bool))
        public
        override sponsorToRequesterToSponsorshipStatus;

    mapping(address => uint256) public override requesterToRequestCountPlusOne;

    mapping(bytes32 => bytes32) private requestIdToFulfillmentParameters;

    function setSponsorshipStatus(address requester, bool sponsorshipStatus)
        external
        override
    {

        if (requesterToRequestCountPlusOne[requester] == 0) {
            requesterToRequestCountPlusOne[requester] = 1;
        }
        sponsorToRequesterToSponsorshipStatus[msg.sender][
            requester
        ] = sponsorshipStatus;
        emit SetSponsorshipStatus(msg.sender, requester, sponsorshipStatus);
    }

    function makeTemplateRequest(
        bytes32 templateId,
        address sponsor,
        address sponsorWallet,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes calldata parameters
    ) external override returns (bytes32 requestId) {

        address airnode = templates[templateId].airnode;
        require(airnode != address(0), "Template does not exist");
        require(fulfillAddress != address(this), "Fulfill address AirnodeRrp");
        require(
            sponsorToRequesterToSponsorshipStatus[sponsor][msg.sender],
            "Requester not sponsored"
        );
        uint256 requesterRequestCount = requesterToRequestCountPlusOne[
            msg.sender
        ];
        requestId = keccak256(
            abi.encodePacked(
                block.chainid,
                address(this),
                msg.sender,
                requesterRequestCount,
                templateId,
                sponsor,
                sponsorWallet,
                fulfillAddress,
                fulfillFunctionId,
                parameters
            )
        );
        requestIdToFulfillmentParameters[requestId] = keccak256(
            abi.encodePacked(
                airnode,
                sponsorWallet,
                fulfillAddress,
                fulfillFunctionId
            )
        );
        requesterToRequestCountPlusOne[msg.sender]++;
        emit MadeTemplateRequest(
            airnode,
            requestId,
            requesterRequestCount,
            block.chainid,
            msg.sender,
            templateId,
            sponsor,
            sponsorWallet,
            fulfillAddress,
            fulfillFunctionId,
            parameters
        );
    }

    function makeFullRequest(
        address airnode,
        bytes32 endpointId,
        address sponsor,
        address sponsorWallet,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes calldata parameters
    ) external override returns (bytes32 requestId) {

        require(airnode != address(0), "Airnode address zero");
        require(fulfillAddress != address(this), "Fulfill address AirnodeRrp");
        require(
            sponsorToRequesterToSponsorshipStatus[sponsor][msg.sender],
            "Requester not sponsored"
        );
        uint256 requesterRequestCount = requesterToRequestCountPlusOne[
            msg.sender
        ];
        requestId = keccak256(
            abi.encodePacked(
                block.chainid,
                address(this),
                msg.sender,
                requesterRequestCount,
                airnode,
                endpointId,
                sponsor,
                sponsorWallet,
                fulfillAddress,
                fulfillFunctionId,
                parameters
            )
        );
        requestIdToFulfillmentParameters[requestId] = keccak256(
            abi.encodePacked(
                airnode,
                sponsorWallet,
                fulfillAddress,
                fulfillFunctionId
            )
        );
        requesterToRequestCountPlusOne[msg.sender]++;
        emit MadeFullRequest(
            airnode,
            requestId,
            requesterRequestCount,
            block.chainid,
            msg.sender,
            endpointId,
            sponsor,
            sponsorWallet,
            fulfillAddress,
            fulfillFunctionId,
            parameters
        );
    }

    function fulfill(
        bytes32 requestId,
        address airnode,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes calldata data,
        bytes calldata signature
    ) external override returns (bool callSuccess, bytes memory callData) {

        require(
            keccak256(
                abi.encodePacked(
                    airnode,
                    msg.sender,
                    fulfillAddress,
                    fulfillFunctionId
                )
            ) == requestIdToFulfillmentParameters[requestId],
            "Invalid request fulfillment"
        );
        require(
            (
                keccak256(abi.encodePacked(requestId, data))
                    .toEthSignedMessageHash()
            ).recover(signature) == airnode,
            "Invalid signature"
        );
        delete requestIdToFulfillmentParameters[requestId];
        (callSuccess, callData) = fulfillAddress.call( // solhint-disable-line avoid-low-level-calls
            abi.encodeWithSelector(fulfillFunctionId, requestId, data)
        );
        if (callSuccess) {
            emit FulfilledRequest(airnode, requestId, data);
        } else {
            emit FailedRequest(
                airnode,
                requestId,
                "Fulfillment failed unexpectedly"
            );
        }
    }

    function fail(
        bytes32 requestId,
        address airnode,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        string calldata errorMessage
    ) external override {

        require(
            keccak256(
                abi.encodePacked(
                    airnode,
                    msg.sender,
                    fulfillAddress,
                    fulfillFunctionId
                )
            ) == requestIdToFulfillmentParameters[requestId],
            "Invalid request fulfillment"
        );
        delete requestIdToFulfillmentParameters[requestId];
        emit FailedRequest(airnode, requestId, errorMessage);
    }

    function requestIsAwaitingFulfillment(bytes32 requestId)
        external
        view
        override
        returns (bool isAwaitingFulfillment)
    {

        isAwaitingFulfillment =
            requestIdToFulfillmentParameters[requestId] != bytes32(0);
    }
}