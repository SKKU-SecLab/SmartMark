
pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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

pragma solidity ^0.8.13;


library LowLevelCallUtils {

    using Address for address;

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bool success)
    {

        require(
            target.isContract(),
            "LowLevelCallUtils: static call to non-contract"
        );
        assembly {
            success := staticcall(
                gas(),
                target,
                add(data, 32),
                mload(data),
                0,
                0
            )
        }
    }

    function returnDataSize() internal pure returns (uint256 len) {

        assembly {
            len := returndatasize()
        }
    }

    function readReturnData(uint256 offset, uint256 length)
        internal
        pure
        returns (bytes memory data)
    {

        data = new bytes(length);
        assembly {
            returndatacopy(add(data, 32), offset, length)
        }
    }

    function propagateRevert() internal pure {

        assembly {
            returndatacopy(0, 0, returndatasize())
            revert(0, returndatasize())
        }
    }
}pragma solidity >=0.8.4;

interface ENS {

    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

    event Transfer(bytes32 indexed node, address owner);

    event NewResolver(bytes32 indexed node, address resolver);

    event NewTTL(bytes32 indexed node, uint64 ttl);

    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function setRecord(
        bytes32 node,
        address owner,
        address resolver,
        uint64 ttl
    ) external;


    function setSubnodeRecord(
        bytes32 node,
        bytes32 label,
        address owner,
        address resolver,
        uint64 ttl
    ) external;


    function setSubnodeOwner(
        bytes32 node,
        bytes32 label,
        address owner
    ) external returns (bytes32);


    function setResolver(bytes32 node, address resolver) external;


    function setOwner(bytes32 node, address owner) external;


    function setTTL(bytes32 node, uint64 ttl) external;


    function setApprovalForAll(address operator, bool approved) external;


    function owner(bytes32 node) external view returns (address);


    function resolver(bytes32 node) external view returns (address);


    function ttl(bytes32 node) external view returns (uint64);


    function recordExists(bytes32 node) external view returns (bool);


    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

}// MIT
pragma solidity ^0.8.4;

interface IExtendedResolver {

    function resolve(bytes memory name, bytes memory data)
        external
        view
        returns (bytes memory, address);

}//MIT
pragma solidity >=0.8.4;

library BytesUtils {

    function keccak(bytes memory self, uint offset, uint len) internal pure returns (bytes32 ret) {

        require(offset + len <= self.length);
        assembly {
            ret := keccak256(add(add(self, 32), offset), len)
        }
    }

    function namehash(bytes memory self, uint offset) internal pure returns(bytes32) {

        (bytes32 labelhash, uint newOffset) = readLabel(self, offset);
        if(labelhash == bytes32(0)) {
            require(offset == self.length - 1, "namehash: Junk at end of name");
            return bytes32(0);
        }
        return keccak256(abi.encodePacked(namehash(self, newOffset), labelhash));
    }
    
    function readLabel(bytes memory self, uint256 idx) internal pure returns (bytes32 labelhash, uint newIdx) {

        require(idx < self.length, "readLabel: Index out of bounds");
        uint len = uint(uint8(self[idx]));
        if(len > 0) {
            labelhash = keccak(self, idx + 1, len);
        } else {
            labelhash = bytes32(0);
        }
        newIdx = idx + len + 1;
    }
}// MIT
pragma solidity ^0.8.13;


library NameEncoder {

    using BytesUtils for bytes;

    function dnsEncodeName(string memory name)
        internal
        pure
        returns (bytes memory dnsName, bytes32 node)
    {

        uint8 labelLength = 0;
        bytes memory bytesName = bytes(name);
        uint256 length = bytesName.length;
        dnsName = new bytes(length + 2);
        node = 0;
        if (length == 0) {
            dnsName[0] = 0;
            return (dnsName, node);
        }

        unchecked {
            for (uint256 i = length - 1; i >= 0; i--) {
                if (bytesName[i] == ".") {
                    dnsName[i + 1] = bytes1(labelLength);
                    node = keccak256(
                        abi.encodePacked(
                            node,
                            bytesName.keccak(i + 1, labelLength)
                        )
                    );
                    labelLength = 0;
                } else {
                    labelLength += 1;
                    dnsName[i + 1] = bytesName[i];
                }
                if (i == 0) {
                    break;
                }
            }
        }

        node = keccak256(
            abi.encodePacked(node, bytesName.keccak(0, labelLength))
        );

        dnsName[0] = bytes1(labelLength);
        return (dnsName, node);
    }
}// MIT
pragma solidity ^0.8.13;


error OffchainLookup(
    address sender,
    string[] urls,
    bytes callData,
    bytes4 callbackFunction,
    bytes extraData
);

contract UniversalResolver is IExtendedResolver, ERC165 {

    using Address for address;
    using NameEncoder for string;
    using BytesUtils for bytes;

    ENS public immutable registry;

    constructor(address _registry) {
        registry = ENS(_registry);
    }

    function resolve(bytes calldata name, bytes memory data)
        external
        view
        override
        returns (bytes memory, address)
    {

        (Resolver resolver, ) = findResolver(name);
        if (address(resolver) == address(0)) {
            return ("", address(0));
        }

        try
            resolver.supportsInterface(type(IExtendedResolver).interfaceId)
        returns (bool supported) {
            if (supported) {
                return (
                    callWithOffchainLookupPropagation(
                        address(resolver),
                        abi.encodeCall(IExtendedResolver.resolve, (name, data)),
                        UniversalResolver.resolveCallback.selector
                    ),
                    address(resolver)
                );
            }
        } catch {}
        return (
            callWithOffchainLookupPropagation(
                address(resolver),
                data,
                UniversalResolver.resolveCallback.selector
            ),
            address(resolver)
        );
    }

    function reverse(bytes calldata reverseName)
        external
        view
        returns (
            string memory,
            address,
            address,
            address
        )
    {
        (
            bytes memory resolvedReverseData,
            address reverseResolverAddress
        ) = this.resolve(
                reverseName,
                abi.encodeCall(INameResolver.name, reverseName.namehash(0))
            );

        string memory resolvedName = abi.decode(resolvedReverseData, (string));

        (bytes memory encodedName, bytes32 namehash) = resolvedName
            .dnsEncodeName();

        (bytes memory resolvedData, address resolverAddress) = this.resolve(
            encodedName,
            abi.encodeCall(IAddrResolver.addr, namehash)
        );

        address resolvedAddress = abi.decode(resolvedData, (address));

        return (
            resolvedName,
            resolvedAddress,
            reverseResolverAddress,
            resolverAddress
        );
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == type(IExtendedResolver).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function callWithOffchainLookupPropagation(
        address target,
        bytes memory data,
        bytes4 callbackFunction
    ) internal view returns (bytes memory ret) {
        bool result = LowLevelCallUtils.functionStaticCall(target, data);
        uint256 size = LowLevelCallUtils.returnDataSize();

        if (result) {
            return LowLevelCallUtils.readReturnData(0, size);
        }

        if (size >= 4) {
            bytes memory errorId = LowLevelCallUtils.readReturnData(0, 4);
            if (bytes4(errorId) == OffchainLookup.selector) {
                bytes memory revertData = LowLevelCallUtils.readReturnData(
                    4,
                    size - 4
                );
                (
                    address sender,
                    string[] memory urls,
                    bytes memory callData,
                    bytes4 innerCallbackFunction,
                    bytes memory extraData
                ) = abi.decode(
                        revertData,
                        (address, string[], bytes, bytes4, bytes)
                    );
                if (sender == target) {
                    revert OffchainLookup(
                        address(this),
                        urls,
                        callData,
                        callbackFunction,
                        abi.encode(sender, innerCallbackFunction, extraData)
                    );
                }
            }
        }

        LowLevelCallUtils.propagateRevert();
    }

    function resolveCallback(bytes calldata response, bytes calldata extraData)
        external
        view
        returns (bytes memory)
    {
        (
            address target,
            bytes4 innerCallbackFunction,
            bytes memory innerExtraData
        ) = abi.decode(extraData, (address, bytes4, bytes));
        return
            abi.decode(
                target.functionStaticCall(
                    abi.encodeWithSelector(
                        innerCallbackFunction,
                        response,
                        innerExtraData
                    )
                ),
                (bytes)
            );
    }

    function findResolver(bytes calldata name)
        public
        view
        returns (Resolver, bytes32)
    {
        (address resolver, bytes32 labelhash) = findResolver(name, 0);
        return (Resolver(resolver), labelhash);
    }

    function findResolver(bytes calldata name, uint256 offset)
        internal
        view
        returns (address, bytes32)
    {
        uint256 labelLength = uint256(uint8(name[offset]));
        if (labelLength == 0) {
            return (address(0), bytes32(0));
        }
        uint256 nextLabel = offset + labelLength + 1;
        bytes32 labelHash = keccak256(name[offset + 1:nextLabel]);
        (address parentresolver, bytes32 parentnode) = findResolver(
            name,
            nextLabel
        );
        bytes32 node = keccak256(abi.encodePacked(parentnode, labelHash));
        address resolver = registry.resolver(node);
        if (resolver != address(0)) {
            return (resolver, node);
        }
        return (parentresolver, node);
    }
}// MIT
pragma solidity >=0.8.4;


abstract contract ResolverBase is ERC165 {
    function isAuthorised(bytes32 node) internal virtual view returns(bool);


    modifier authorised(bytes32 node) {

        require(isAuthorised(node));
        _;
    }
}// MIT
pragma solidity >=0.8.4;


interface IABIResolver {

    event ABIChanged(bytes32 indexed node, uint256 indexed contentType);
    function ABI(bytes32 node, uint256 contentTypes) external view returns (uint256, bytes memory);

}// MIT
pragma solidity >=0.8.4;

interface IAddressResolver {

    event AddressChanged(bytes32 indexed node, uint coinType, bytes newAddress);

    function addr(bytes32 node, uint coinType) external view returns(bytes memory);

}// MIT
pragma solidity >=0.8.4;

interface IAddrResolver {

    event AddrChanged(bytes32 indexed node, address a);

    function addr(bytes32 node) external view returns (address payable);

}// MIT
pragma solidity >=0.8.4;

interface IContentHashResolver {

    event ContenthashChanged(bytes32 indexed node, bytes hash);

    function contenthash(bytes32 node) external view returns (bytes memory);

}// MIT
pragma solidity >=0.8.4;

interface IDNSRecordResolver {

    event DNSRecordChanged(bytes32 indexed node, bytes name, uint16 resource, bytes record);
    event DNSRecordDeleted(bytes32 indexed node, bytes name, uint16 resource);
    event DNSZoneCleared(bytes32 indexed node);

    function dnsRecord(bytes32 node, bytes32 name, uint16 resource) external view returns (bytes memory);

}// MIT
pragma solidity >=0.8.4;

interface IDNSZoneResolver {

    event DNSZonehashChanged(bytes32 indexed node, bytes lastzonehash, bytes zonehash);

    function zonehash(bytes32 node) external view returns (bytes memory);

}// MIT
pragma solidity >=0.8.4;

interface IInterfaceResolver {

    event InterfaceChanged(bytes32 indexed node, bytes4 indexed interfaceID, address implementer);

    function interfaceImplementer(bytes32 node, bytes4 interfaceID) external view returns (address);

}// MIT
pragma solidity >=0.8.4;

interface INameResolver {

    event NameChanged(bytes32 indexed node, string name);

    function name(bytes32 node) external view returns (string memory);

}// MIT
pragma solidity >=0.8.4;

interface IPubkeyResolver {

    event PubkeyChanged(bytes32 indexed node, bytes32 x, bytes32 y);

    function pubkey(bytes32 node) external view returns (bytes32 x, bytes32 y);

}// MIT
pragma solidity >=0.8.4;

interface ITextResolver {

    event TextChanged(bytes32 indexed node, string indexed indexedKey, string key);

    function text(bytes32 node, string calldata key) external view returns (string memory);

}//MIT
pragma solidity >=0.8.4;


interface Resolver is
    IERC165,
    IABIResolver,
    IAddressResolver,
    IAddrResolver,
    IContentHashResolver,
    IDNSRecordResolver,
    IDNSZoneResolver,
    IInterfaceResolver,
    INameResolver,
    IPubkeyResolver,
    ITextResolver,
    IExtendedResolver
{

    event ContentChanged(bytes32 indexed node, bytes32 hash);

    function setABI(
        bytes32 node,
        uint256 contentType,
        bytes calldata data
    ) external;


    function setAddr(bytes32 node, address addr) external;


    function setAddr(
        bytes32 node,
        uint256 coinType,
        bytes calldata a
    ) external;


    function setContenthash(bytes32 node, bytes calldata hash) external;


    function setDnsrr(bytes32 node, bytes calldata data) external;


    function setName(bytes32 node, string calldata _name) external;


    function setPubkey(
        bytes32 node,
        bytes32 x,
        bytes32 y
    ) external;


    function setText(
        bytes32 node,
        string calldata key,
        string calldata value
    ) external;


    function setInterface(
        bytes32 node,
        bytes4 interfaceID,
        address implementer
    ) external;


    function multicall(bytes[] calldata data)
        external
        returns (bytes[] memory results);


    function content(bytes32 node) external view returns (bytes32);


    function multihash(bytes32 node) external view returns (bytes memory);


    function setContent(bytes32 node, bytes32 hash) external;


    function setMultihash(bytes32 node, bytes calldata hash) external;

}