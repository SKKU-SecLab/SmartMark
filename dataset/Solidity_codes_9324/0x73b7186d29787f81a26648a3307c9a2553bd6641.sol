


pragma solidity 0.6.5;


interface Locker{

    function getDepositByTokenAddress(address _tokenAddress,uint256 _index) view external
        returns (uint256, address, address, uint256, uint256, bool);

    function getTotalDepositsByTokenAddress(address _token) external view returns (uint256);

}

pragma solidity 0.6.5;


contract LockerUtils {

    
    function locks(Locker _lock, address _token, uint256 _offset, uint256 _limit) external view returns(
        uint256[] memory lockIds, uint256[] memory amounts
    ) {

        uint256 lockCount = _lock.getTotalDepositsByTokenAddress(_token);

        
        uint256[] memory returnLockIds = new uint256[](lockCount);
        uint256[] memory amountsReturn = new uint256[](lockCount);
        uint256 resultIndex = 0;
        
        uint256 lockId;
        uint256 limit = _limit;
        if (lockCount < limit) {
            limit = lockCount;
        }

        for (lockId = _offset; lockId <= limit; lockId++) {
            (uint256 id,,,uint256 amount,,) = _lock.getDepositByTokenAddress(_token, lockId - 1);
            returnLockIds[resultIndex] = id;
            amountsReturn[resultIndex] = amount;
            resultIndex++;
        }

        return (returnLockIds, amountsReturn);
        
    }
    
    function locksTimes(Locker _lock, address _token, uint256 _offset, uint256 _limit) external view returns(
        uint256[] memory unlockTimes
    ) {

        uint256 lockCount = _lock.getTotalDepositsByTokenAddress(_token);

        
        uint256[] memory unlockTimesRes = new uint256[](lockCount);
        uint256 resultIndex = 0;
        
        uint256 lockId;
        uint256 limit = _limit;
        if (lockCount < limit) {
            limit = lockCount;
        }

        for (lockId = _offset; lockId <= limit; lockId++) {
            (,,,,uint256 unlock,) = _lock.getDepositByTokenAddress(_token, lockId - 1);
            unlockTimesRes[resultIndex] = unlock;
            resultIndex++;
        }

        return (unlockTimesRes);
        
    }
    
    function locksDetails(Locker _lock, address _token, uint256 _offset, uint256 _limit) external view returns(
        address[] memory withdrawalAddresses, bool[] memory withdrawns
    ) {

        uint256 lockCount = _lock.getTotalDepositsByTokenAddress(_token);

        
        address[] memory withdrawalAddressesRes = new address[](lockCount);
        bool[] memory withdrawnsRes = new bool[](lockCount);
        uint256 resultIndex = 0;
        
        uint256 lockId;
        uint256 limit = _limit;
        if (lockCount < limit) {
            limit = lockCount;
        }

        for (lockId = _offset; lockId <= limit; lockId++) {
            (,, address withdrawAddress,,,bool withdrawn) = _lock.getDepositByTokenAddress(_token, lockId - 1);
            withdrawalAddressesRes[resultIndex] = withdrawAddress;
            withdrawnsRes[resultIndex] = withdrawn;
            resultIndex++;
        }

        return (withdrawalAddressesRes, withdrawnsRes);
        
    }
}