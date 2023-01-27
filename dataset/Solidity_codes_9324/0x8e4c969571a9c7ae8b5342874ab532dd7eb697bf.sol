



pragma solidity ^0.8.3;

interface IFilter {

    function isValid(address _wallet, address _spender, address _to, bytes calldata _data) external view returns (bool valid);

}// Copyright (C) 2021  Argent Labs Ltd. <https://argent.xyz>




pragma solidity ^0.8.3;
pragma experimental ABIEncoderV2;

interface IDappRegistry {

    function enabledRegistryIds(address _wallet) external view returns (bytes32);

    function authorisations(uint8 _registryId, address _dapp) external view returns (bytes32);

}// Copyright (C) 2020  Argent Labs Ltd. <https://argent.xyz>




pragma solidity >=0.5.4 <0.9.0;

interface ITransferStorage {

    function setWhitelist(address _wallet, address _target, uint256 _value) external;


    function getWhitelist(address _wallet, address _target) external view returns (uint256);

}// Copyright (C) 2020  Argent Labs Ltd. <https://argent.xyz>




pragma solidity ^0.8.3;

library Utils {


    bytes4 private constant ERC20_TRANSFER = bytes4(keccak256("transfer(address,uint256)"));
    bytes4 private constant ERC20_APPROVE = bytes4(keccak256("approve(address,uint256)"));
    bytes4 private constant ERC721_SET_APPROVAL_FOR_ALL = bytes4(keccak256("setApprovalForAll(address,bool)"));
    bytes4 private constant ERC721_TRANSFER_FROM = bytes4(keccak256("transferFrom(address,address,uint256)"));
    bytes4 private constant ERC721_SAFE_TRANSFER_FROM = bytes4(keccak256("safeTransferFrom(address,address,uint256)"));
    bytes4 private constant ERC721_SAFE_TRANSFER_FROM_BYTES = bytes4(keccak256("safeTransferFrom(address,address,uint256,bytes)"));
    bytes4 private constant ERC1155_SAFE_TRANSFER_FROM = bytes4(keccak256("safeTransferFrom(address,address,uint256,uint256,bytes)"));

    bytes4 private constant OWNER_SIG = 0x8da5cb5b;
    function recoverSigner(bytes32 _signedHash, bytes memory _signatures, uint _index) internal pure returns (address) {

        uint8 v;
        bytes32 r;
        bytes32 s;
        assembly {
            r := mload(add(_signatures, add(0x20,mul(0x41,_index))))
            s := mload(add(_signatures, add(0x40,mul(0x41,_index))))
            v := and(mload(add(_signatures, add(0x41,mul(0x41,_index)))), 0xff)
        }
        require(v == 27 || v == 28, "Utils: bad v value in signature");

        address recoveredAddress = ecrecover(_signedHash, v, r, s);
        require(recoveredAddress != address(0), "Utils: ecrecover returned 0");
        return recoveredAddress;
    }

    function recoverSpender(address _to, bytes memory _data) internal pure returns (address spender) {

        if(_data.length >= 68) {
            bytes4 methodId;
            assembly {
                methodId := mload(add(_data, 0x20))
            }
            if(
                methodId == ERC20_TRANSFER ||
                methodId == ERC20_APPROVE ||
                methodId == ERC721_SET_APPROVAL_FOR_ALL) 
            {
                assembly {
                    spender := mload(add(_data, 0x24))
                }
                return spender;
            }
            if(
                methodId == ERC721_TRANSFER_FROM ||
                methodId == ERC721_SAFE_TRANSFER_FROM ||
                methodId == ERC721_SAFE_TRANSFER_FROM_BYTES ||
                methodId == ERC1155_SAFE_TRANSFER_FROM)
            {
                assembly {
                    spender := mload(add(_data, 0x44))
                }
                return spender;
            }
        }

        spender = _to;
    }

    function functionPrefix(bytes memory _data) internal pure returns (bytes4 prefix) {

        require(_data.length >= 4, "Utils: Invalid functionPrefix");
        assembly {
            prefix := mload(add(_data, 0x20))
        }
    }

    function isContract(address _addr) internal view returns (bool) {

        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function isGuardianOrGuardianSigner(address[] memory _guardians, address _guardian) internal view returns (bool, address[] memory) {

        if (_guardians.length == 0 || _guardian == address(0)) {
            return (false, _guardians);
        }
        bool isFound = false;
        address[] memory updatedGuardians = new address[](_guardians.length - 1);
        uint256 index = 0;
        for (uint256 i = 0; i < _guardians.length; i++) {
            if (!isFound) {
                if (_guardian == _guardians[i]) {
                    isFound = true;
                    continue;
                }
                if (isContract(_guardians[i]) && isGuardianOwner(_guardians[i], _guardian)) {
                    isFound = true;
                    continue;
                }
            }
            if (index < updatedGuardians.length) {
                updatedGuardians[index] = _guardians[i];
                index++;
            }
        }
        return isFound ? (true, updatedGuardians) : (false, _guardians);
    }

    function isGuardianOwner(address _guardian, address _owner) internal view returns (bool) {

        address owner = address(0);

        assembly {
            let ptr := mload(0x40)
            mstore(ptr,OWNER_SIG)
            let result := staticcall(25000, _guardian, ptr, 0x20, ptr, 0x20)
            if eq(result, 1) {
                owner := mload(ptr)
            }
        }
        return owner == _owner;
    }

    function ceil(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a / b;
        if (a % b == 0) {
            return c;
        } else {
            return c + 1;
        }
    }
}// Copyright (C) 2021  Argent Labs Ltd. <https://argent.xyz>




pragma solidity ^0.8.3;


contract MultiCallHelper {


    uint256 private constant MAX_UINT = type(uint256).max;

    struct Call {
        address to;
        uint256 value;
        bytes data;
    }

    ITransferStorage internal immutable userWhitelist;
    IDappRegistry internal immutable dappRegistry;

    constructor(ITransferStorage _userWhitelist, IDappRegistry _dappRegistry) {
        userWhitelist = _userWhitelist;
        dappRegistry = _dappRegistry;
    }

    function isMultiCallAuthorised(address _wallet, Call[] calldata _transactions) external view returns (bool) {

        for(uint i = 0; i < _transactions.length; i++) {
            address spender = Utils.recoverSpender(_transactions[i].to, _transactions[i].data);
            if (
                (spender != _transactions[i].to && _transactions[i].value != 0) ||
                (!isWhitelisted(_wallet, spender) && isAuthorised(_wallet, spender, _transactions[i].to, _transactions[i].data) == MAX_UINT)
            ) {
                return false;
            }
        }
        return true;
    }

    function multiCallAuthorisation(address _wallet, Call[] calldata _transactions) external view returns (uint256[] memory registryIds) {

        registryIds = new uint256[](_transactions.length);
        for(uint i = 0; i < _transactions.length; i++) {
            address spender = Utils.recoverSpender(_transactions[i].to, _transactions[i].data);
            if (spender != _transactions[i].to && _transactions[i].value != 0) {
                registryIds[i] = MAX_UINT;
            } else if (isWhitelisted(_wallet, spender)) {
                registryIds[i] = 256;
            } else {
                registryIds[i] = isAuthorised(_wallet, spender, _transactions[i].to, _transactions[i].data);
            }
        }
    }

    function isAuthorised(address _wallet, address _spender, address _to, bytes calldata _data) internal view returns (uint256) {

        uint registries = uint(dappRegistry.enabledRegistryIds(_wallet));
        for(uint registryId = 0; registryId == 0 || (registries >> registryId) > 0; registryId++) {
            bool isEnabled = (((registries >> registryId) & 1) > 0) /* "is bit set for regId?" */ == (registryId > 0) /* "not Argent registry?" */;
            if(isEnabled) { // if registryId is enabled
                uint auth = uint(dappRegistry.authorisations(uint8(registryId), _spender)); 
                uint validAfter = auth & 0xffffffffffffffff;
                if (0 < validAfter && validAfter <= block.timestamp) { // if the current time is greater than the validity time
                    address filter = address(uint160(auth >> 64));
                    if(filter == address(0) || IFilter(filter).isValid(_wallet, _spender, _to, _data)) {
                        return registryId;
                    }
                }
            }
        }
        return MAX_UINT;
    }

    function isAuthorisedInRegistry(address _wallet, Call[] calldata _transactions, uint8 _registryId) external view returns (bool) {

        for(uint i = 0; i < _transactions.length; i++) {
            address spender = Utils.recoverSpender(_transactions[i].to, _transactions[i].data);

            uint auth = uint(dappRegistry.authorisations(_registryId, spender)); 
            uint validAfter = auth & 0xffffffffffffffff;
            if (0 < validAfter && validAfter <= block.timestamp) { // if the current time is greater than the validity time
                address filter = address(uint160(auth >> 64));
                if(filter != address(0) && !IFilter(filter).isValid(_wallet, spender, _transactions[i].to, _transactions[i].data)) {
                    return false;
                }
            } else {
                return false;
            }
        }

        return true;
    }

    function isWhitelisted(address _wallet, address _target) internal view returns (bool _isWhitelisted) {

        uint whitelistAfter = userWhitelist.getWhitelist(_wallet, _target);
        return whitelistAfter > 0 && whitelistAfter < block.timestamp;
    }
}