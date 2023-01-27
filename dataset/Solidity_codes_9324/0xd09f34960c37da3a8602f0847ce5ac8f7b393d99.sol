

pragma solidity ^0.5.0;

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity ^0.5.0;


contract ILendingPoolAddressesProviderRegistry {


    function getAddressesProvidersList() external view returns (address[] memory);

    function isAddressesProviderRegistered(address _provider) external view returns (uint256);


    function registerAddressesProvider(address _provider, uint256 _id) external;

    function unregisterAddressesProvider(address _provider) external;

}


pragma solidity ^0.5.0;






contract LendingPoolAddressesProviderRegistry is Ownable, ILendingPoolAddressesProviderRegistry {

    event AddressesProviderRegistered(address indexed newAddress);
    event AddressesProviderUnregistered(address indexed newAddress);

    mapping(address => uint256) addressesProviders;
    address[] addressesProvidersList;

    function isAddressesProviderRegistered(address _provider) external view returns(uint256) {

        return addressesProviders[_provider];
    }

    function getAddressesProvidersList() external view returns(address[] memory) {


        uint256 maxLength = addressesProvidersList.length;

        address[] memory activeProviders = new address[](maxLength);

        for(uint256 i = 0; i<addressesProvidersList.length; i++){
            if(addressesProviders[addressesProvidersList[i]] > 0){
                activeProviders[i] = addressesProvidersList[i];
            }
        }

        return activeProviders;
    }

    function registerAddressesProvider(address _provider, uint256 _id) public onlyOwner {

        addressesProviders[_provider] = _id;
        addToAddressesProvidersListInternal(_provider);
        emit AddressesProviderRegistered(_provider);
    }

    function unregisterAddressesProvider(address _provider) public onlyOwner {

        require(addressesProviders[_provider] > 0, "Provider is not registered");
        addressesProviders[_provider] = 0;
        emit AddressesProviderUnregistered(_provider);
    }

    function addToAddressesProvidersListInternal(address _provider) internal {


        for(uint256 i = 0; i < addressesProvidersList.length; i++) {

            if(addressesProvidersList[i] == _provider){
                return;
            }
        }

        addressesProvidersList.push(_provider);
    }
}