




// Adapted to use pragma ^0.5.8 and satisfy our linter rules

pragma solidity ^0.5.8;


contract IsContract {

    function isContract(address _target) internal view returns (bool) {

        if (_target == address(0)) {
            return false;
        }

        uint256 size;
        assembly { size := extcodesize(_target) }
        return size > 0;
    }
}



pragma solidity ^0.5.8;


contract ERC20 {

    function totalSupply() public view returns (uint256);


    function balanceOf(address _who) public view returns (uint256);


    function allowance(address _owner, address _spender) public view returns (uint256);


    function transfer(address _to, uint256 _value) public returns (bool);


    function approve(address _spender, uint256 _value) public returns (bool);


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);


    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}



pragma solidity ^0.5.8;



library SafeERC20 {

    bytes4 private constant TRANSFER_SELECTOR = 0xa9059cbb;

    function safeTransfer(ERC20 _token, address _to, uint256 _amount) internal returns (bool) {

        bytes memory transferCallData = abi.encodeWithSelector(
            TRANSFER_SELECTOR,
            _to,
            _amount
        );
        return invokeAndCheckSuccess(address(_token), transferCallData);
    }

    function safeTransferFrom(ERC20 _token, address _from, address _to, uint256 _amount) internal returns (bool) {

        bytes memory transferFromCallData = abi.encodeWithSelector(
            _token.transferFrom.selector,
            _from,
            _to,
            _amount
        );
        return invokeAndCheckSuccess(address(_token), transferFromCallData);
    }

    function safeApprove(ERC20 _token, address _spender, uint256 _amount) internal returns (bool) {

        bytes memory approveCallData = abi.encodeWithSelector(
            _token.approve.selector,
            _spender,
            _amount
        );
        return invokeAndCheckSuccess(address(_token), approveCallData);
    }

    function invokeAndCheckSuccess(address _addr, bytes memory _calldata) private returns (bool) {

        bool ret;
        assembly {
            let ptr := mload(0x40)    // free memory pointer

            let success := call(
                gas,                  // forward all gas
                _addr,                // address
                0,                    // no value
                add(_calldata, 0x20), // calldata start
                mload(_calldata),     // calldata length
                ptr,                  // write output over free memory
                0x20                  // uint256 return
            )

            if gt(success, 0) {
                switch returndatasize

                case 0 {
                    ret := 1
                }

                case 0x20 {
                    ret := eq(mload(ptr), 1)
                }

                default { }
            }
        }
        return ret;
    }
}


pragma solidity ^0.5.8;


interface ApproveAndCallFallBack {

    function receiveApproval(address _from, uint256 _amount, address _token, bytes calldata _data) external;

}


pragma solidity ^0.5.8;


interface ERC900 {

    event Staked(address indexed user, uint256 amount, uint256 total, bytes data);
    event Unstaked(address indexed user, uint256 amount, uint256 total, bytes data);

    function stake(uint256 _amount, bytes calldata _data) external;


    function stakeFor(address _user, uint256 _amount, bytes calldata _data) external;


    function unstake(uint256 _amount, bytes calldata _data) external;


    function totalStakedFor(address _addr) external view returns (uint256);


    function totalStaked() external view returns (uint256);


    function token() external view returns (address);


    function supportsHistory() external pure returns (bool);

}


pragma solidity ^0.5.8;



interface IPresale {

    function open() external;

    function close() external;

    function contribute(address _contributor, uint256 _value) external payable;

    function refund(address _contributor, uint256 _vestedPurchaseId) external;

    function contributionToTokens(uint256 _value) external view returns (uint256);

    function contributionToken() external view returns (ERC20);

}


pragma solidity ^0.5.8;








contract CourtPresaleActivate is IsContract, ApproveAndCallFallBack {

    using SafeERC20 for ERC20;

    string private constant ERROR_TOKEN_NOT_CONTRACT = "CPA_TOKEN_NOT_CONTRACT";
    string private constant ERROR_REGISTRY_NOT_CONTRACT = "CPA_REGISTRY_NOT_CONTRACT";
    string private constant ERROR_PRESALE_NOT_CONTRACT = "CPA_PRESALE_NOT_CONTRACT";
    string private constant ERROR_ZERO_AMOUNT = "CPA_ZERO_AMOUNT";
    string private constant ERROR_TOKEN_TRANSFER_FAILED = "CPA_TOKEN_TRANSFER_FAILED";
    string private constant ERROR_WRONG_TOKEN = "CPA_WRONG_TOKEN";

    bytes32 internal constant ACTIVATE_DATA = keccak256("activate(uint256)");

    ERC20 public bondedToken;
    ERC900 public registry;
    IPresale public presale;

    event BoughtAndActivated(address from, address collateralToken, uint256 buyAmount, uint256 activatedAmount);

    constructor(ERC20 _bondedToken, ERC900 _registry, IPresale _presale) public {
        require(isContract(address(_bondedToken)), ERROR_TOKEN_NOT_CONTRACT);
        require(isContract(address(_registry)), ERROR_REGISTRY_NOT_CONTRACT);
        require(isContract(address(_presale)), ERROR_PRESALE_NOT_CONTRACT);

        bondedToken = _bondedToken;
        registry = _registry;
        presale = _presale;
    }

    function receiveApproval(address _from, uint256 _amount, address _token, bytes calldata) external {

        require(_amount > 0, ERROR_ZERO_AMOUNT);
        require(_token == address(presale.contributionToken()), ERROR_WRONG_TOKEN);

        require(ERC20(_token).safeTransferFrom(_from, address(this), _amount), ERROR_TOKEN_TRANSFER_FAILED);

        require(ERC20(_token).safeApprove(address(presale), _amount), ERROR_TOKEN_TRANSFER_FAILED);

        presale.contribute(address(this), _amount);
        uint256 bondedTokensObtained = presale.contributionToTokens(_amount);

        require(bondedToken.safeTransfer(_from, bondedTokensObtained), "TRANSFER FAILED");
    }
}