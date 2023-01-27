
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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
pragma solidity 0.8.3;

interface IGovernance {

    event MembersPercentageUpdated(uint256 percentage);

    event MemberUpdated(address member, bool status);

    event MemberAdminUpdated(address member, address admin);

    event AdminUpdated(address indexed previousAdmin, address indexed newAdmin);

    function initGovernance(
        address[] memory _members,
        address[] memory _membersAdmins,
        uint256 _percentage,
        uint256 _precision
    ) external;


    function admin() external view returns (address);


    function membersPercentage() external view returns (uint256);


    function membersPrecision() external view returns (uint256);


    function updateAdmin(address _newAdmin) external;


    function updateMembersPercentage(uint256 _percentage) external;


    function updateMember(
        address _account,
        address _accountAdmin,
        bool _status
    ) external;


    function updateMemberAdmin(address _member, address _newMemberAdmin)
        external;


    function isMember(address _member) external view returns (bool);


    function membersCount() external view returns (uint256);


    function memberAt(uint256 _index) external view returns (address);


    function memberAdmin(address _member) external view returns (address);


    function hasValidSignaturesLength(uint256 _n) external view returns (bool);

}// MIT
pragma solidity 0.8.3;

interface IDiamondCut {

    enum FacetCutAction {
        Add,
        Replace,
        Remove
    }

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external;


    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);
}// MIT
pragma solidity 0.8.3;


library LibDiamond {

    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.diamond.storage");

    struct FacetAddressAndPosition {
        address facetAddress;
        uint16 functionSelectorPosition; // position in facetFunctionSelectors.functionSelectors array
    }

    struct FacetFunctionSelectors {
        bytes4[] functionSelectors;
        uint16 facetAddressPosition; // position of facetAddress in facetAddresses array
    }

    struct DiamondStorage {
        mapping(bytes4 => FacetAddressAndPosition) selectorToFacetAndPosition;
        mapping(address => FacetFunctionSelectors) facetFunctionSelectors;
        address[] facetAddresses;
        mapping(bytes4 => bool) supportedInterfaces;
        address contractOwner;
    }

    function diamondStorage()
        internal
        pure
        returns (DiamondStorage storage ds)
    {

        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function setContractOwner(address _newOwner) internal {

        DiamondStorage storage ds = diamondStorage();
        address previousOwner = ds.contractOwner;
        ds.contractOwner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    function contractOwner() internal view returns (address contractOwner_) {

        contractOwner_ = diamondStorage().contractOwner;
    }

    function enforceIsContractOwner() internal view {

        require(
            msg.sender == diamondStorage().contractOwner,
            "LibDiamond: Must be contract owner"
        );
    }

    event DiamondCut(
        IDiamondCut.FacetCut[] _diamondCut,
        address _init,
        bytes _calldata
    );

    function diamondCut(
        IDiamondCut.FacetCut[] memory _diamondCut,
        address _init,
        bytes memory _calldata
    ) internal {

        for (
            uint256 facetIndex;
            facetIndex < _diamondCut.length;
            facetIndex++
        ) {
            IDiamondCut.FacetCutAction action = _diamondCut[facetIndex].action;
            if (action == IDiamondCut.FacetCutAction.Add) {
                addFunctions(
                    _diamondCut[facetIndex].facetAddress,
                    _diamondCut[facetIndex].functionSelectors
                );
            } else if (action == IDiamondCut.FacetCutAction.Replace) {
                replaceFunctions(
                    _diamondCut[facetIndex].facetAddress,
                    _diamondCut[facetIndex].functionSelectors
                );
            } else if (action == IDiamondCut.FacetCutAction.Remove) {
                removeFunctions(
                    _diamondCut[facetIndex].facetAddress,
                    _diamondCut[facetIndex].functionSelectors
                );
            } else {
                revert("LibDiamondCut: Incorrect FacetCutAction");
            }
        }
        emit DiamondCut(_diamondCut, _init, _calldata);
        initializeDiamondCut(_init, _calldata);
    }

    function addFunctions(
        address _facetAddress,
        bytes4[] memory _functionSelectors
    ) internal {

        require(
            _functionSelectors.length > 0,
            "LibDiamondCut: No selectors in facet to cut"
        );
        DiamondStorage storage ds = diamondStorage();
        require(
            _facetAddress != address(0),
            "LibDiamondCut: Add facet can't be address(0)"
        );
        uint16 selectorPosition = uint16(
            ds.facetFunctionSelectors[_facetAddress].functionSelectors.length
        );
        if (selectorPosition == 0) {
            enforceHasContractCode(
                _facetAddress,
                "LibDiamondCut: New facet has no code"
            );
            ds
                .facetFunctionSelectors[_facetAddress]
                .facetAddressPosition = uint16(ds.facetAddresses.length);
            ds.facetAddresses.push(_facetAddress);
        }
        for (
            uint256 selectorIndex;
            selectorIndex < _functionSelectors.length;
            selectorIndex++
        ) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds
                .selectorToFacetAndPosition[selector]
                .facetAddress;
            require(
                oldFacetAddress == address(0),
                "LibDiamondCut: Can't add function that already exists"
            );
            addFunction(ds, selector, selectorPosition, _facetAddress);
            selectorPosition++;
        }
    }

    function replaceFunctions(
        address _facetAddress,
        bytes4[] memory _functionSelectors
    ) internal {

        require(
            _functionSelectors.length > 0,
            "LibDiamondCut: No selectors in facet to cut"
        );
        DiamondStorage storage ds = diamondStorage();
        require(
            _facetAddress != address(0),
            "LibDiamondCut: Add facet can't be address(0)"
        );
        uint16 selectorPosition = uint16(
            ds.facetFunctionSelectors[_facetAddress].functionSelectors.length
        );
        if (selectorPosition == 0) {
            enforceHasContractCode(
                _facetAddress,
                "LibDiamondCut: New facet has no code"
            );
            ds
                .facetFunctionSelectors[_facetAddress]
                .facetAddressPosition = uint16(ds.facetAddresses.length);
            ds.facetAddresses.push(_facetAddress);
        }
        for (
            uint256 selectorIndex;
            selectorIndex < _functionSelectors.length;
            selectorIndex++
        ) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds
                .selectorToFacetAndPosition[selector]
                .facetAddress;
            require(
                oldFacetAddress != _facetAddress,
                "LibDiamondCut: Can't replace function with same function"
            );
            removeFunction(ds, oldFacetAddress, selector);
            addFunction(ds, selector, selectorPosition, _facetAddress);
            selectorPosition++;
        }
    }

    function removeFunctions(
        address _facetAddress,
        bytes4[] memory _functionSelectors
    ) internal {

        require(
            _functionSelectors.length > 0,
            "LibDiamondCut: No selectors in facet to cut"
        );
        DiamondStorage storage ds = diamondStorage();
        require(
            _facetAddress == address(0),
            "LibDiamondCut: Remove facet address must be address(0)"
        );
        for (
            uint256 selectorIndex;
            selectorIndex < _functionSelectors.length;
            selectorIndex++
        ) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds
                .selectorToFacetAndPosition[selector]
                .facetAddress;
            removeFunction(ds, oldFacetAddress, selector);
        }
    }

    function addFunction(
        DiamondStorage storage ds,
        bytes4 _selector,
        uint16 _selectorPosition,
        address _facetAddress
    ) internal {

        ds
            .selectorToFacetAndPosition[_selector]
            .functionSelectorPosition = _selectorPosition;
        ds.facetFunctionSelectors[_facetAddress].functionSelectors.push(
            _selector
        );
        ds.selectorToFacetAndPosition[_selector].facetAddress = _facetAddress;
    }

    function removeFunction(
        DiamondStorage storage ds,
        address _facetAddress,
        bytes4 _selector
    ) internal {

        require(
            _facetAddress != address(0),
            "LibDiamondCut: Can't remove function that doesn't exist"
        );
        require(
            _facetAddress != address(this),
            "LibDiamondCut: Can't remove immutable function"
        );
        uint256 selectorPosition = ds
            .selectorToFacetAndPosition[_selector]
            .functionSelectorPosition;
        uint256 lastSelectorPosition = ds
            .facetFunctionSelectors[_facetAddress]
            .functionSelectors
            .length - 1;
        if (selectorPosition != lastSelectorPosition) {
            bytes4 lastSelector = ds
                .facetFunctionSelectors[_facetAddress]
                .functionSelectors[lastSelectorPosition];
            ds.facetFunctionSelectors[_facetAddress].functionSelectors[
                    selectorPosition
                ] = lastSelector;
            ds
                .selectorToFacetAndPosition[lastSelector]
                .functionSelectorPosition = uint16(selectorPosition);
        }
        ds.facetFunctionSelectors[_facetAddress].functionSelectors.pop();
        delete ds.selectorToFacetAndPosition[_selector];

        if (lastSelectorPosition == 0) {
            uint256 lastFacetAddressPosition = ds.facetAddresses.length - 1;
            uint256 facetAddressPosition = ds
                .facetFunctionSelectors[_facetAddress]
                .facetAddressPosition;
            if (facetAddressPosition != lastFacetAddressPosition) {
                address lastFacetAddress = ds.facetAddresses[
                    lastFacetAddressPosition
                ];
                ds.facetAddresses[facetAddressPosition] = lastFacetAddress;
                ds
                    .facetFunctionSelectors[lastFacetAddress]
                    .facetAddressPosition = uint16(facetAddressPosition);
            }
            ds.facetAddresses.pop();
            delete ds
                .facetFunctionSelectors[_facetAddress]
                .facetAddressPosition;
        }
    }

    function initializeDiamondCut(address _init, bytes memory _calldata)
        internal
    {

        if (_init == address(0)) {
            require(
                _calldata.length == 0,
                "LibDiamondCut: _init is address(0) but_calldata is not empty"
            );
        } else {
            require(
                _calldata.length > 0,
                "LibDiamondCut: _calldata is empty but _init is not address(0)"
            );
            if (_init != address(this)) {
                enforceHasContractCode(
                    _init,
                    "LibDiamondCut: _init address has no code"
                );
            }
            (bool success, bytes memory error) = _init.delegatecall(_calldata);
            if (!success) {
                if (error.length > 0) {
                    revert(string(error));
                } else {
                    revert("LibDiamondCut: _init function reverted");
                }
            }
        }
    }

    function enforceHasContractCode(
        address _contract,
        string memory _errorMessage
    ) internal view {

        uint256 contractSize;
        assembly {
            contractSize := extcodesize(_contract)
        }
        require(contractSize > 0, _errorMessage);
    }
}// MIT

pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        return set._values[index];
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }


    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}// MIT

pragma solidity ^0.8.0;

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return recover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return recover(hash, r, vs);
        } else {
            revert("ECDSA: invalid signature length");
        }
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return recover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        require(
            uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
            "ECDSA: invalid signature 's' value"
        );
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// MIT
pragma solidity 0.8.3;


library LibGovernance {

    using EnumerableSet for EnumerableSet.AddressSet;
    bytes32 constant STORAGE_POSITION = keccak256("governance.storage");

    struct Storage {
        bool initialized;
        EnumerableSet.AddressSet membersSet;
        mapping(address => address) membersAdmins;
        uint256 precision;
        uint256 percentage;
        address admin;
        bool paused;
    }

    function governanceStorage() internal pure returns (Storage storage gs) {

        bytes32 position = STORAGE_POSITION;
        assembly {
            gs.slot := position
        }
    }

    function admin() internal view returns (address) {

        return governanceStorage().admin;
    }

    function paused() internal view returns (bool) {

        return governanceStorage().paused;
    }

    function percentage() internal view returns (uint256) {

        Storage storage gs = governanceStorage();
        return gs.percentage;
    }

    function precision() internal view returns (uint256) {

        Storage storage gs = governanceStorage();
        return gs.precision;
    }

    function enforceNotPaused() internal view {

        require(!governanceStorage().paused, "LibGovernance: paused");
    }

    function enforcePaused() internal view {

        require(governanceStorage().paused, "LibGovernance: not paused");
    }

    function updateAdmin(address _newAdmin) internal {

        Storage storage ds = governanceStorage();
        ds.admin = _newAdmin;
    }

    function pause() internal {

        enforceNotPaused();
        Storage storage ds = governanceStorage();
        ds.paused = true;
    }

    function unpause() internal {

        enforcePaused();
        Storage storage ds = governanceStorage();
        ds.paused = false;
    }

    function updateMembersPercentage(uint256 _newPercentage) internal {

        Storage storage gs = governanceStorage();
        require(_newPercentage != 0, "LibGovernance: percentage must not be 0");
        require(
            _newPercentage < gs.precision,
            "LibGovernance: percentage must be less than precision"
        );
        gs.percentage = _newPercentage;
    }

    function updateMember(address _account, bool _status) internal {

        Storage storage gs = governanceStorage();
        if (_status) {
            require(
                gs.membersSet.add(_account),
                "LibGovernance: Account already added"
            );
        } else if (!_status) {
            require(
                LibGovernance.membersCount() > 1,
                "LibGovernance: contract would become memberless"
            );
            require(
                gs.membersSet.remove(_account),
                "LibGovernance: Account is not a member"
            );
        }
    }

    function updateMemberAdmin(address _account, address _admin) internal {

        governanceStorage().membersAdmins[_account] = _admin;
    }

    function isMember(address _member) internal view returns (bool) {

        Storage storage gs = governanceStorage();
        return gs.membersSet.contains(_member);
    }

    function membersCount() internal view returns (uint256) {

        Storage storage gs = governanceStorage();
        return gs.membersSet.length();
    }

    function memberAt(uint256 _index) internal view returns (address) {

        Storage storage gs = governanceStorage();
        return gs.membersSet.at(_index);
    }

    function memberAdmin(address _account) internal view returns (address) {

        Storage storage gs = governanceStorage();
        return gs.membersAdmins[_account];
    }

    function hasValidSignaturesLength(uint256 _n) internal view returns (bool) {

        Storage storage gs = governanceStorage();
        uint256 members = gs.membersSet.length();
        if (_n > members) {
            return false;
        }

        uint256 mulMembersPercentage = members * gs.percentage;
        uint256 requiredSignaturesLength = mulMembersPercentage / gs.precision;
        if (mulMembersPercentage % gs.precision != 0) {
            requiredSignaturesLength++;
        }

        return _n >= requiredSignaturesLength;
    }

    function validateSignaturesLength(uint256 _n) internal view {

        require(
            hasValidSignaturesLength(_n),
            "LibGovernance: Invalid number of signatures"
        );
    }

    function validateSignatures(bytes32 _ethHash, bytes[] calldata _signatures)
        internal
        view
    {

        address[] memory signers = new address[](_signatures.length);
        for (uint256 i = 0; i < _signatures.length; i++) {
            address signer = ECDSA.recover(_ethHash, _signatures[i]);
            require(isMember(signer), "LibGovernance: invalid signer");
            for (uint256 j = 0; j < i; j++) {
                require(
                    signer != signers[j],
                    "LibGovernance: duplicate signatures"
                );
            }
            signers[i] = signer;
        }
    }
}// MIT
pragma solidity 0.8.3;


library LibFeeCalculator {

    bytes32 constant STORAGE_POSITION = keccak256("fee.calculator.storage");

    struct FeeCalculator {
        uint256 serviceFeePercentage;
        uint256 feesAccrued;
        uint256 previousAccrued;
        uint256 accumulator;
        mapping(address => uint256) claimedRewardsPerAccount;
    }

    struct Storage {
        bool initialized;
        uint256 precision;
        mapping(address => FeeCalculator) nativeTokenFeeCalculators;
    }

    function feeCalculatorStorage() internal pure returns (Storage storage ds) {

        bytes32 position = STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function precision() internal view returns (uint256) {

        LibFeeCalculator.Storage storage fcs = feeCalculatorStorage();
        return fcs.precision;
    }

    function addNewMember(address _account, address _token) internal {

        LibFeeCalculator.Storage storage fcs = feeCalculatorStorage();
        FeeCalculator storage fc = fcs.nativeTokenFeeCalculators[_token];
        accrue(fc);

        fc.claimedRewardsPerAccount[_account] = fc.accumulator;
    }

    function claimReward(address _claimer, address _token)
        internal
        returns (uint256)
    {

        LibFeeCalculator.Storage storage fcs = feeCalculatorStorage();
        FeeCalculator storage fc = fcs.nativeTokenFeeCalculators[_token];
        accrue(fc);

        uint256 claimableAmount = fc.accumulator -
            fc.claimedRewardsPerAccount[_claimer];

        fc.claimedRewardsPerAccount[_claimer] = fc.accumulator;

        return claimableAmount;
    }

    function distributeRewards(address _token, uint256 _amount)
        internal
        returns (uint256)
    {

        LibFeeCalculator.Storage storage fcs = feeCalculatorStorage();
        FeeCalculator storage fc = fcs.nativeTokenFeeCalculators[_token];
        uint256 serviceFee = (_amount * fc.serviceFeePercentage) /
            fcs.precision;
        fc.feesAccrued = fc.feesAccrued + serviceFee;

        return serviceFee;
    }

    function setServiceFee(address _token, uint256 _serviceFeePercentage)
        internal
    {

        LibFeeCalculator.Storage storage fcs = feeCalculatorStorage();
        require(
            _serviceFeePercentage < fcs.precision,
            "LibFeeCalculator: service fee percentage exceeds or equal to precision"
        );

        FeeCalculator storage ntfc = fcs.nativeTokenFeeCalculators[_token];
        ntfc.serviceFeePercentage = _serviceFeePercentage;
    }

    function accrue(FeeCalculator storage _fc) internal returns (uint256) {

        uint256 members = LibGovernance.membersCount();
        uint256 amount = (_fc.feesAccrued - _fc.previousAccrued) / members;
        _fc.previousAccrued += amount * members;
        _fc.accumulator = _fc.accumulator + amount;

        return _fc.accumulator;
    }
}// MIT
pragma solidity 0.8.3;


library LibRouter {

    using EnumerableSet for EnumerableSet.AddressSet;
    bytes32 constant STORAGE_POSITION = keccak256("router.storage");

    struct Storage {
        bool initialized;
        mapping(bytes32 => bool) hashesUsed;
        EnumerableSet.AddressSet nativeTokens;
    }

    function routerStorage() internal pure returns (Storage storage ds) {

        bytes32 position = STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function updateNativeToken(address _nativeToken, bool _status) internal {

        Storage storage rs = routerStorage();
        if (_status) {
            require(
                rs.nativeTokens.add(_nativeToken),
                "LibRouter: native token already added"
            );
        } else {
            require(
                rs.nativeTokens.remove(_nativeToken),
                "LibRouter: native token not found"
            );
        }
    }

    function nativeTokensCount() internal view returns (uint256) {

        Storage storage rs = routerStorage();
        return rs.nativeTokens.length();
    }

    function nativeTokenAt(uint256 _index) internal view returns (address) {

        Storage storage rs = routerStorage();
        return rs.nativeTokens.at(_index);
    }

    function containsNativeToken(address _nativeToken)
        internal
        view
        returns (bool)
    {

        Storage storage rs = routerStorage();
        return rs.nativeTokens.contains(_nativeToken);
    }
}// MIT
pragma solidity 0.8.3;


contract GovernanceFacet is IGovernance {

    using SafeERC20 for IERC20;

    function initGovernance(
        address[] memory _members,
        address[] memory _membersAdmins,
        uint256 _percentage,
        uint256 _precision
    ) external override {

        LibGovernance.Storage storage gs = LibGovernance.governanceStorage();
        require(!gs.initialized, "GovernanceFacet: already initialized");
        require(
            _members.length > 0,
            "GovernanceFacet: Member list must contain at least 1 element"
        );
        require(
            _members.length == _membersAdmins.length,
            "GovernanceFacet: not matching members length"
        );
        require(_precision != 0, "GovernanceFacet: precision must not be zero");
        require(
            _percentage < _precision,
            "GovernanceFacet: percentage must be less than precision"
        );
        gs.percentage = _percentage;
        gs.precision = _precision;
        gs.initialized = true;

        for (uint256 i = 0; i < _members.length; i++) {
            LibGovernance.updateMember(_members[i], true);
            LibGovernance.updateMemberAdmin(_members[i], _membersAdmins[i]);
            emit MemberUpdated(_members[i], true);
            emit MemberAdminUpdated(_members[i], _membersAdmins[i]);
        }
    }

    function admin() external view override returns (address) {

        return LibGovernance.admin();
    }

    function membersPercentage() external view override returns (uint256) {

        return LibGovernance.percentage();
    }

    function membersPrecision() external view override returns (uint256) {

        return LibGovernance.precision();
    }

    function updateAdmin(address _newAdmin) external override {

        LibDiamond.enforceIsContractOwner();
        address previousAdmin = LibGovernance.admin();
        LibGovernance.updateAdmin(_newAdmin);

        emit AdminUpdated(previousAdmin, _newAdmin);
    }

    function updateMembersPercentage(uint256 _percentage) external override {

        LibDiamond.enforceIsContractOwner();
        LibGovernance.updateMembersPercentage(_percentage);

        emit MembersPercentageUpdated(_percentage);
    }

    function updateMember(
        address _account,
        address _accountAdmin,
        bool _status
    ) external override {

        LibDiamond.enforceIsContractOwner();

        if (_status) {
            for (uint256 i = 0; i < LibRouter.nativeTokensCount(); i++) {
                LibFeeCalculator.addNewMember(
                    _account,
                    LibRouter.nativeTokenAt(i)
                );
            }
        } else {
            for (uint256 i = 0; i < LibRouter.nativeTokensCount(); i++) {
                address accountAdmin = LibGovernance.memberAdmin(_account);
                address token = LibRouter.nativeTokenAt(i);
                uint256 claimableFees = LibFeeCalculator.claimReward(
                    _account,
                    token
                );
                IERC20(token).safeTransfer(accountAdmin, claimableFees);
            }
            _accountAdmin = address(0);
        }

        LibGovernance.updateMember(_account, _status);
        emit MemberUpdated(_account, _status);

        LibGovernance.updateMemberAdmin(_account, _accountAdmin);
        emit MemberAdminUpdated(_account, _accountAdmin);
    }

    function updateMemberAdmin(address _member, address _newMemberAdmin)
        external
        override
    {

        require(
            LibGovernance.isMember(_member),
            "GovernanceFacet: _member is not an actual member"
        );
        require(
            msg.sender == LibGovernance.memberAdmin(_member),
            "GovernanceFacet: caller is not the old admin"
        );

        LibGovernance.updateMemberAdmin(_member, _newMemberAdmin);
        emit MemberAdminUpdated(_member, _newMemberAdmin);
    }

    function isMember(address _member) external view override returns (bool) {

        return LibGovernance.isMember(_member);
    }

    function membersCount() external view override returns (uint256) {

        return LibGovernance.membersCount();
    }

    function memberAt(uint256 _index) external view override returns (address) {

        return LibGovernance.memberAt(_index);
    }

    function memberAdmin(address _member)
        external
        view
        override
        returns (address)
    {

        return LibGovernance.memberAdmin(_member);
    }

    function hasValidSignaturesLength(uint256 _n)
        external
        view
        override
        returns (bool)
    {

        return LibGovernance.hasValidSignaturesLength(_n);
    }
}