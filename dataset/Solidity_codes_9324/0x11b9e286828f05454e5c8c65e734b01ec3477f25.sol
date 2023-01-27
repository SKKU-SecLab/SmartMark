



pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




pragma solidity >=0.6.2 <0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;


    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

}




pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}




pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}




pragma solidity >=0.6.0 <0.8.0;


interface IERC1155Receiver is IERC165 {


    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);

}




pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}




pragma solidity >=0.6.0 <0.8.0;



abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    constructor() internal {
        _registerInterface(
            ERC1155Receiver(0).onERC1155Received.selector ^
            ERC1155Receiver(0).onERC1155BatchReceived.selector
        );
    }
}


pragma solidity =0.7.6;





interface IFoundry{

    function wrapMultipleTokens(
        uint256[] calldata _tokenIds,
        address _account,
        uint256[] calldata _amounts
    ) external;


    function unWrapMultipleTokens(
        uint256[] memory _tokenIds,
        uint256[] memory _amounts
    ) external;


    function wrappers(uint256 _tokenId) external view returns(address);

}
interface IBPool is IERC20{

    function joinPool(uint poolAmountOut, uint[] calldata maxAmountsIn)
        external;

    function exitPool(uint poolAmountIn, uint[] calldata minAmountsOut) external;

}
interface IShareToken is IERC1155{

     function buyCompleteSets(
        address _market,
        address _account,
        uint256 _amount
    ) external returns (bool);


    function sellCompleteSets(
        address _market,
        address _holder,
        address _recipient,
        uint256 _amount,
        bytes32 _fingerprint
    ) external returns (uint256 _creatorFee, uint256 _reportingFee);


    function lowestBalanceOfMarketOutcomes(address _market, uint256[] memory _outcomes, address _account) external view returns (uint256);

}
interface IERC20Wrapper is IERC20{

    function unWrapTokens(address _account, uint256 _amount) external;

}

contract Helper is ERC1155Receiver{

    IFoundry immutable public foundry;
    IShareToken immutable public shareToken;
    IERC20 immutable public cash;
    address immutable public augur;


    using SafeMath for uint256;

    constructor(address _augur,IFoundry _foundry,IShareToken _shareToken,IERC20 _cash) public{
        augur = _augur;
        foundry = _foundry;
        shareToken = _shareToken;
        cash = _cash;
        _shareToken.setApprovalForAll(address(_foundry),true);
    }

    function mintWrapJoin(
        uint256[] memory _tokenIds,
        uint256[] memory _wrappingAmounts,
        uint256[] memory _getBackTokenIds,
        address _market,
        uint256 _numTicks,
        uint256 _mintAmount,
        uint256 _amountOfDAIToAdd,
        IBPool _pool,
        uint256 _poolAmountOut, 
        uint256[] memory _maxAmountsIn
    ) public {

        require(_tokenIds.length == _wrappingAmounts.length && _tokenIds.length == _maxAmountsIn.length - 1,"Invalid inputs");
        require(
            cash.transferFrom(
                msg.sender,
                address(this),
                (_mintAmount.mul(_numTicks)).add(_amountOfDAIToAdd)
            )
        );
        cash.approve(augur, _mintAmount.mul(_numTicks).add(_amountOfDAIToAdd));
        shareToken.buyCompleteSets(_market, address(this), _mintAmount);     
        for (uint256 i = 0; i < _getBackTokenIds.length; i++) {
                shareToken.safeTransferFrom(
                    address(this),
                    msg.sender,
                    _getBackTokenIds[i],
                    _mintAmount,
                    ''
                );
        }
        foundry.wrapMultipleTokens(_tokenIds,address(this),_wrappingAmounts);
        if(address(_pool) != address(0)){
            for(uint256 i=0 ; i<_tokenIds.length; i++){
                address erc20WrapperAddress = foundry.wrappers(_tokenIds[i]);
                IERC20(erc20WrapperAddress).approve(address(_pool),uint256(-1));
            }
            cash.approve(address(_pool),_amountOfDAIToAdd);

            _pool.joinPool(_poolAmountOut,_maxAmountsIn);
            _pool.transfer(msg.sender,_poolAmountOut);
        }
        for(uint256 i=0;i<_tokenIds.length;i++){
            IERC20 erc20Wrapper = IERC20(foundry.wrappers(_tokenIds[i]));
            uint256 balanceOfERC20Wrapper =erc20Wrapper.balanceOf(address(this));
            if(balanceOfERC20Wrapper != 0){
                erc20Wrapper.transfer(msg.sender,balanceOfERC20Wrapper);
            }
        }
        uint256 balanceOfCash = cash.balanceOf(address(this));
        if(balanceOfCash != 0){
                cash.transfer(msg.sender,balanceOfCash);
        }
    }
    function exitUnWrapRedeem(IBPool _pool,uint256 _poolAmountIn, uint256[] memory _minAmountsOut,uint256[] memory _tokenIds,address _market,uint256[] memory _outcomes,bytes32 _fingerprint) public{

       require(_tokenIds.length == _minAmountsOut.length - 1,"Invalid inputs");
       require(
            _pool.transferFrom(
                msg.sender,
                address(this),
               _poolAmountIn
            )
        );
        _pool.exitPool(_poolAmountIn,_minAmountsOut);


        uint256 balanceOfCash = cash.balanceOf(address(this));
        if(balanceOfCash != 0){
                cash.transfer(msg.sender,balanceOfCash);
        }

        for(uint256 i = 0; i <_tokenIds.length;i++){
            IERC20Wrapper erc20Wrapper = IERC20Wrapper(foundry.wrappers(_tokenIds[i]));
            uint256 balanceOfERC20Wrapper = erc20Wrapper.balanceOf(address(this));
            if(balanceOfERC20Wrapper != 0){
                erc20Wrapper.unWrapTokens(address(this),balanceOfERC20Wrapper);
                shareToken.safeTransferFrom(
                        address(this),
                        msg.sender,
                        _tokenIds[i],
                        balanceOfERC20Wrapper,
                        ''
                );
            }
        }
        uint256 amountOfcompleteShares = shareToken.lowestBalanceOfMarketOutcomes(_market,_outcomes,msg.sender);
        shareToken.sellCompleteSets(_market,msg.sender,msg.sender,amountOfcompleteShares,_fingerprint);

    }
    

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external override pure returns (bytes4) {

        return (
            bytes4(
                keccak256(
                    'onERC1155Received(address,address,uint256,uint256,bytes)'
                )
            )
        );
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external override pure returns (bytes4) {

        return
            bytes4(
                keccak256(
                    'onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)'
                )
            );
    }
}