

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


pragma solidity ^0.5.0;

interface IUniswapExchange {

  event TokenPurchase(address indexed buyer, uint256 indexed eth_sold, uint256 indexed tokens_bought);
  event EthPurchase(address indexed buyer, uint256 indexed tokens_sold, uint256 indexed eth_bought);
  event AddLiquidity(address indexed provider, uint256 indexed eth_amount, uint256 indexed token_amount);
  event RemoveLiquidity(address indexed provider, uint256 indexed eth_amount, uint256 indexed token_amount);

  function () external payable;

  function getInputPrice(uint256 input_amount, uint256 input_reserve, uint256 output_reserve) external view returns (uint256);


  function getOutputPrice(uint256 output_amount, uint256 input_reserve, uint256 output_reserve) external view returns (uint256);



  function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) external payable returns (uint256);


  function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns(uint256);



  function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external payable returns(uint256);

  function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns (uint256);


  function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256);


  function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256);


  function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline) external returns (uint256);


  function tokenToEthTransferOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) external returns (uint256);


  function tokenToTokenSwapInput(
    uint256 tokens_sold, 
    uint256 min_tokens_bought, 
    uint256 min_eth_bought, 
    uint256 deadline, 
    address token_addr) 
    external returns (uint256);


  function tokenToTokenTransferInput(
    uint256 tokens_sold, 
    uint256 min_tokens_bought, 
    uint256 min_eth_bought, 
    uint256 deadline, 
    address recipient, 
    address token_addr) 
    external returns (uint256);



  function tokenToTokenSwapOutput(
    uint256 tokens_bought, 
    uint256 max_tokens_sold, 
    uint256 max_eth_sold, 
    uint256 deadline, 
    address token_addr) 
    external returns (uint256);


  function tokenToTokenTransferOutput(
    uint256 tokens_bought, 
    uint256 max_tokens_sold, 
    uint256 max_eth_sold, 
    uint256 deadline, 
    address recipient, 
    address token_addr) 
    external returns (uint256);


  function tokenToExchangeSwapInput(
    uint256 tokens_sold, 
    uint256 min_tokens_bought, 
    uint256 min_eth_bought, 
    uint256 deadline, 
    address exchange_addr) 
    external returns (uint256);


  function tokenToExchangeTransferInput(
    uint256 tokens_sold, 
    uint256 min_tokens_bought, 
    uint256 min_eth_bought, 
    uint256 deadline, 
    address recipient, 
    address exchange_addr) 
    external returns (uint256);


  function tokenToExchangeSwapOutput(
    uint256 tokens_bought, 
    uint256 max_tokens_sold, 
    uint256 max_eth_sold, 
    uint256 deadline, 
    address exchange_addr) 
    external returns (uint256);


  function tokenToExchangeTransferOutput(
    uint256 tokens_bought, 
    uint256 max_tokens_sold, 
    uint256 max_eth_sold, 
    uint256 deadline, 
    address recipient, 
    address exchange_addr) 
    external returns (uint256);




  function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256);


  function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256);


  function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256);


  function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256);


  function tokenAddress() external view returns (address);


  function factoryAddress() external view returns (address);




  function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);


  function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) external returns (uint256, uint256);

}


pragma solidity ^0.5.0;

interface IUniswapFactory {

  event NewExchange(address indexed token, address indexed exchange);

  function initializeFactory(address template) external;

  function createExchange(address token) external returns (address payable);

  function getExchange(address token) external view returns (address payable);

  function getToken(address token) external view returns (address);

  function getTokenWihId(uint256 token_id) external view returns (address);

}


pragma solidity ^0.5.8;










contract CourtPresaleActivate is IsContract, ApproveAndCallFallBack {

    using SafeERC20 for ERC20;

    string private constant ERROR_NOT_GOVERNOR = "CPA_NOT_GOVERNOR";
    string private constant ERROR_TOKEN_NOT_CONTRACT = "CPA_TOKEN_NOT_CONTRACT";
    string private constant ERROR_REGISTRY_NOT_CONTRACT = "CPA_REGISTRY_NOT_CONTRACT";
    string private constant ERROR_PRESALE_NOT_CONTRACT = "CPA_PRESALE_NOT_CONTRACT";
    string private constant ERROR_UNISWAP_FACTORY_NOT_CONTRACT = "CPA_UNISWAP_FACTORY_NOT_CONTRACT";
    string private constant ERROR_ZERO_AMOUNT = "CPA_ZERO_AMOUNT";
    string private constant ERROR_TOKEN_TRANSFER_FAILED = "CPA_TOKEN_TRANSFER_FAILED";
    string private constant ERROR_TOKEN_APPROVAL_FAILED = "CPA_TOKEN_APPROVAL_FAILED";
    string private constant ERROR_WRONG_TOKEN = "CPA_WRONG_TOKEN";
    string private constant ERROR_ETH_REFUND = "CPA_ETH_REFUND";
    string private constant ERROR_TOKEN_REFUND = "CPA_TOKEN_REFUND";
    string private constant ERROR_UNISWAP_UNAVAILABLE = "CPA_UNISWAP_UNAVAILABLE";
    string private constant ERROR_NOT_ENOUGH_BALANCE = "CPA_NOT_ENOUGH_BALANCE";

    bytes32 internal constant ACTIVATE_DATA = keccak256("activate(uint256)");

    address public governor;
    ERC20 public bondedToken;
    ERC900 public registry;
    IPresale public presale;
    IUniswapFactory public uniswapFactory;

    event Bought(address from, address contributionToken, uint256 buyAmount, uint256 stakedAmount, bool activated);

    modifier onlyGovernor() {

        require(msg.sender == governor, ERROR_NOT_GOVERNOR);
        _;
    }

    constructor(address _governor, ERC20 _bondedToken, ERC900 _registry, IPresale _presale, IUniswapFactory _uniswapFactory) public {
        require(isContract(address(_bondedToken)), ERROR_TOKEN_NOT_CONTRACT);
        require(isContract(address(_registry)), ERROR_REGISTRY_NOT_CONTRACT);
        require(isContract(address(_presale)), ERROR_PRESALE_NOT_CONTRACT);
        require(isContract(address(_uniswapFactory)), ERROR_UNISWAP_FACTORY_NOT_CONTRACT);

        governor = _governor;
        bondedToken = _bondedToken;
        registry = _registry;
        presale = _presale;
        uniswapFactory = _uniswapFactory;
    }

    function () external payable {
        _contributeEth(1, block.timestamp, _hasData(msg.data));
    }

    function receiveApproval(address _from, uint256 _amount, address _token, bytes calldata _data) external {

        require(_amount > 0, ERROR_ZERO_AMOUNT);
        require(
            _token == msg.sender && _token == address(presale.contributionToken()),
            ERROR_WRONG_TOKEN
        );

        ERC20 token = ERC20(_token);
        require(token.safeTransferFrom(_from, address(this), _amount), ERROR_TOKEN_TRANSFER_FAILED);

        bool activate = _hasData(_data);

        _buyAndActivateAsJuror(_from, _amount, token, activate);
    }

    function contributeExternalToken(
        address _token,
        uint256 _amount,
        uint256 _minTokens,
        uint256 _minEth,
        uint256 _deadline,
        bool _activate
    )
        external
    {

        ERC20 contributionToken = presale.contributionToken();
        address contributionTokenAddress = address(contributionToken);
        require(_token != contributionTokenAddress, ERROR_WRONG_TOKEN);
        require(_amount > 0, ERROR_ZERO_AMOUNT);

        require(ERC20(_token).safeTransferFrom(msg.sender, address(this), _amount), ERROR_TOKEN_TRANSFER_FAILED);

        address payable uniswapExchangeAddress = uniswapFactory.getExchange(_token);
        require(uniswapExchangeAddress != address(0), ERROR_UNISWAP_UNAVAILABLE);
        IUniswapExchange uniswapExchange = IUniswapExchange(uniswapExchangeAddress);

        ERC20 token = ERC20(_token);
        require(token.safeApprove(address(uniswapExchange), _amount), ERROR_TOKEN_APPROVAL_FAILED);
        uint256 contributionTokenAmount = uniswapExchange.tokenToTokenSwapInput(
            _amount,
            _minTokens,
            _minEth,
            _deadline,
            contributionTokenAddress
        );

        _buyAndActivateAsJuror(msg.sender, contributionTokenAmount, contributionToken, _activate);
    }

    function contributeEth(uint256 _minTokens, uint256 _deadline, bool _activate) external payable {

        _contributeEth(_minTokens, _deadline, _activate);
    }

    function refundEth(address payable _recipient, uint256 _amount) external onlyGovernor {

        require(_amount > 0, ERROR_ZERO_AMOUNT);
        uint256 selfBalance = address(this).balance;
        require(selfBalance >= _amount, ERROR_NOT_ENOUGH_BALANCE);

        (bool result,) = _recipient.call.value(_amount)("");
        require(result, ERROR_ETH_REFUND);
    }

    function refundToken(ERC20 _token, address _recipient, uint256 _amount) external onlyGovernor {

        require(_amount > 0, ERROR_ZERO_AMOUNT);
        uint256 selfBalance = _token.balanceOf(address(this));
        require(selfBalance >= _amount, ERROR_NOT_ENOUGH_BALANCE);

        require(_token.safeTransfer(_recipient, _amount), ERROR_TOKEN_REFUND);
    }

    function _contributeEth(uint256 _minTokens, uint256 _deadline, bool _activate) internal {

        require(msg.value > 0, ERROR_ZERO_AMOUNT);

        ERC20 contributionToken = presale.contributionToken();

        address payable uniswapExchangeAddress = uniswapFactory.getExchange(address(contributionToken));
        require(uniswapExchangeAddress != address(0), ERROR_UNISWAP_UNAVAILABLE);
        IUniswapExchange uniswapExchange = IUniswapExchange(uniswapExchangeAddress);

        uint256 contributionTokenAmount = uniswapExchange.ethToTokenSwapInput.value(msg.value)(_minTokens, _deadline);

        _buyAndActivateAsJuror(msg.sender, contributionTokenAmount, contributionToken, _activate);
    }

    function _buyAndActivateAsJuror(address _from, uint256 _amount, ERC20 _contributionToken, bool _activate) internal {

        require(_contributionToken.safeApprove(address(presale), _amount), ERROR_TOKEN_APPROVAL_FAILED);

        presale.contribute(address(this), _amount);
        uint256 bondedTokensObtained = presale.contributionToTokens(_amount);

        if (_activate) {
            require(bondedToken.safeApprove(address(registry), bondedTokensObtained), ERROR_TOKEN_APPROVAL_FAILED);
            registry.stakeFor(_from, bondedTokensObtained, abi.encodePacked(ACTIVATE_DATA));
        } else {
            require(bondedToken.safeTransfer(_from, bondedTokensObtained), ERROR_TOKEN_TRANSFER_FAILED);
        }

        emit Bought(_from, address(_contributionToken), _amount, bondedTokensObtained, _activate);
    }

    function _hasData(bytes memory _data) internal pure returns (bool) {

        return _data.length > 0;
    }
}