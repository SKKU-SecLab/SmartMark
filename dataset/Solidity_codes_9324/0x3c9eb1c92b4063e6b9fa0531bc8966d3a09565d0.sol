

pragma solidity >=0.8.4;

library SafeTransferLib {


    error ETHtransferFailed();

    error TransferFailed();

    error TransferFromFailed();


    function _safeTransferETH(address to, uint256 amount) internal {

        bool callStatus;

        assembly {
            callStatus := call(gas(), to, amount, 0, 0, 0, 0)
        }

        if (!callStatus) revert ETHtransferFailed();
    }


    function _safeTransfer(
        address token,
        address to,
        uint256 amount
    ) internal {

        bool callStatus;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000) // begin with the function selector
            
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // mask and append the "to" argument
            
            mstore(add(freeMemoryPointer, 36), amount) // finally append the "amount" argument - no mask as it's a full 32 byte value

            callStatus := call(gas(), token, 0, freeMemoryPointer, 68, 0, 0)
        }

        if (!_didLastOptionalReturnCallSucceed(callStatus)) revert TransferFailed();
    }

    function _safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 amount
    ) internal {

        bool callStatus;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000) // begin with the function selector
            
            mstore(add(freeMemoryPointer, 4), and(from, 0xffffffffffffffffffffffffffffffffffffffff)) // mask and append the "from" argument
            
            mstore(add(freeMemoryPointer, 36), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // mask and append the "to" argument
            
            mstore(add(freeMemoryPointer, 68), amount) // finally append the "amount" argument - no mask as it's a full 32 byte value

            callStatus := call(gas(), token, 0, freeMemoryPointer, 100, 0, 0)
        }

        if (!_didLastOptionalReturnCallSucceed(callStatus)) revert TransferFromFailed();
    }


    function _didLastOptionalReturnCallSucceed(bool callStatus) internal pure returns (bool success) {

        assembly {
            let returnDataSize := returndatasize()

            if iszero(callStatus) {
                returndatacopy(0, 0, returnDataSize)

                revert(0, returnDataSize)
            }

            switch returnDataSize
            
            case 32 {
                returndatacopy(0, 0, returnDataSize)

                success := iszero(iszero(mload(0)))
            }
            case 0 {
                success := 1
            }
            default {
                success := 0
            }
        }
    }
}

interface IERC20minimal { 

    function balanceOf(address account) external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function burnFrom(address from, uint256 amount) external;

}

abstract contract ReentrancyGuard {
    error Reentrancy();

    uint256 private constant NOT_ENTERED = 1;

    uint256 private constant ENTERED = 2;

    uint256 private status = NOT_ENTERED;

    modifier nonReentrant() {
        if (status == ENTERED) revert Reentrancy();

        status = ENTERED;

        _;

        status = NOT_ENTERED;
    }
}

contract KaliDAOredemption is ReentrancyGuard {

    using SafeTransferLib for address;

    event ExtensionSet(address indexed dao, address[] tokens, uint256 indexed redemptionStart);

    event ExtensionCalled(address indexed dao, address indexed member, uint256 indexed amountBurned);

    event TokensAdded(address indexed dao, address[] tokens);

    event TokensRemoved(address indexed dao, uint256[] tokenIndex);

    error NullTokens();

    error NotStarted();

    mapping(address => address[]) public redeemables;

    mapping(address => uint256) public redemptionStarts;

    function getRedeemables(address dao) public view virtual returns (address[] memory tokens) {

        tokens = redeemables[dao];
    }

    function setExtension(bytes calldata extensionData) public nonReentrant virtual {

        (address[] memory tokens, uint256 redemptionStart) = abi.decode(extensionData, (address[], uint256));

        if (tokens.length == 0) revert NullTokens();

        if (redeemables[msg.sender].length != 0) delete redeemables[msg.sender];
        
        unchecked {
            for (uint256 i; i < tokens.length; i++) {
                redeemables[msg.sender].push(tokens[i]);
            }
        }

        redemptionStarts[msg.sender] = redemptionStart;

        emit ExtensionSet(msg.sender, tokens, redemptionStart);
    }

    function callExtension(
        address account, 
        uint256 amount, 
        bytes calldata
    ) public nonReentrant virtual returns (bool mint, uint256 amountOut) {

        if (block.timestamp < redemptionStarts[msg.sender]) revert NotStarted();

        for (uint256 i; i < redeemables[msg.sender].length;) {
            uint256 amountToRedeem = amount * 
                IERC20minimal(redeemables[msg.sender][i]).balanceOf(msg.sender) / 
                IERC20minimal(msg.sender).totalSupply();
            
            if (amountToRedeem != 0) {
                address(redeemables[msg.sender][i])._safeTransferFrom(
                    msg.sender, 
                    account, 
                    amountToRedeem
                );
            }

            unchecked {
                i++;
            }
        }

        (mint, amountOut) = (false, amount);

        emit ExtensionCalled(msg.sender, account, amount);
    }

    function addTokens(address[] calldata tokens) public nonReentrant virtual {

        unchecked {
            for (uint256 i; i < tokens.length; i++) {
                redeemables[msg.sender].push(tokens[i]);
            }
        }

        emit TokensAdded(msg.sender, tokens);
    }

    function removeTokens(uint256[] calldata tokenIndex) public nonReentrant virtual {

        for (uint256 i; i < tokenIndex.length; i++) {
            redeemables[msg.sender][tokenIndex[i]] = 
                redeemables[msg.sender][redeemables[msg.sender].length - 1];

            redeemables[msg.sender].pop();
        }

        emit TokensRemoved(msg.sender, tokenIndex);
    }
}