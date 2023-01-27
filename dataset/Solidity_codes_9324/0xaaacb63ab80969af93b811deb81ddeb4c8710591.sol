
pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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
}/*
    Copyright 2021 Babylon Finance.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

    Apache License, Version 2.0
*/

pragma solidity 0.7.6;
pragma abicoder v2;


contract VTableBeacon is Ownable {

    struct ModuleDefinition {
        address implementation;
        bytes4[] selectors;
    }

    bytes4 private constant _FALLBACK_SIGN = 0xffffffff;

    mapping(bytes4 => address) public delegates;

    event VTableUpdate(bytes4 indexed selector, address oldImplementation, address newImplementation);

    function implementation(bytes4 _selector) external view virtual returns (address module) {

        module = delegates[_selector];
        if (module != address(0)) return module;

        module = delegates[_FALLBACK_SIGN];
        if (module != address(0)) return module;

        revert('VTableBeacon: No implementation found');
    }

    function updateVTable(ModuleDefinition[] calldata modules) external onlyOwner {

        for (uint256 i = 0; i < modules.length; ++i) {
            ModuleDefinition memory module = modules[i];
            for (uint256 j = 0; j < module.selectors.length; ++j) {
                bytes4 selector = module.selectors[j];
                emit VTableUpdate(selector, delegates[selector], module.implementation);
                delegates[selector] = module.implementation;
            }
        }
    }
}