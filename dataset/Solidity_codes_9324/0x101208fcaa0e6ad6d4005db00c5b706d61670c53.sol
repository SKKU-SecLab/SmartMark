


pragma solidity ^0.6.0;

interface IArtBlocksMinter {

    function artblocksContract() external view returns (address);


    function artistSetBonusContractAddress(
        uint256 _projectId,
        address _bonusContractAddress
    ) external;


    function artistToggleBonus(uint256 _projectId) external;


    function checkYourAllowanceOfProjectERC20(uint256 _projectId)
        external
        view
        returns (uint256);


    function getYourBalanceOfProjectERC20(uint256 _projectId)
        external
        view
        returns (uint256);


    function projectIdToBonus(uint256) external view returns (bool);


    function projectIdToBonusContractAddress(uint256)
        external
        view
        returns (address);


    function purchase(uint256 _projectId)
        external
        payable
        returns (uint256 _tokenId);


    function purchaseTo(address _to, uint256 _projectId)
        external
        payable
        returns (uint256 _tokenId);

}


pragma solidity ^0.6.0;

interface IArtBlocksMain {

    function projectIdToCurrencyAddress(uint256)
        external
        view
        returns (address);


    function projectIdToCurrencySymbol(uint256)
        external
        view
        returns (string memory);


    function projectIdToPricePerTokenInWei(uint256)
        external
        view
        returns (uint256);

}



pragma solidity >=0.6.2 <0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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
}


pragma solidity ^0.6.0;




contract BulkMinter {

    IArtBlocksMinter _artBlocksMinter;
    IArtBlocksMain _artBlocksMain;

    constructor() public {
        _artBlocksMinter = IArtBlocksMinter(
            address(0x091dcd914fCEB1d47423e532955d1E62d1b2dAEf)
        );
        _artBlocksMain = IArtBlocksMain(
            address(0xa7d8d9ef8D8Ce8992Df33D8b8CF4Aebabd5bD270)
        );
    }

    function getPrice(uint256 projectId, uint256 numItems)
        public
        view
        returns (uint256)
    {

        require(
            _artBlocksMain.projectIdToCurrencyAddress(projectId) ==
                address(0x0000000000000000000000000000000000000000),
            "project not in ETH"
        );
        return
            _artBlocksMain.projectIdToPricePerTokenInWei(projectId) * numItems;
    }

    function bulkMint(
        uint256 projectId,
        uint256 numItems,
        uint256 tipAmount
    ) public payable {

        uint256 expectedAmount = getPrice(projectId, numItems) + tipAmount;
        require(msg.value == expectedAmount, "incorrect amount");
        uint256 pricePerMint =
            _artBlocksMain.projectIdToPricePerTokenInWei(projectId);
        for (uint256 x = 0; x < numItems; x++) {
            _artBlocksMinter.purchaseTo{value: pricePerMint}(
                msg.sender,
                projectId
            );
        }
    }

    function moveDonations() public {

        Address.sendValue(
            payable(address(0x8a333a18B924554D6e83EF9E9944DE6260f61D3B)),
            address(this).balance
        );
    }
}