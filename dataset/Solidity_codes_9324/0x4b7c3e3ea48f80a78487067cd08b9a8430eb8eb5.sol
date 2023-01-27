
pragma solidity 0.6.12;

interface ITokenDistributor {


  function initialize(address[] memory _receivers, uint[] memory _percentages) external;


  function distribute(IERC20[] memory _tokens) external;


  function getDistribution()
    external
    view
    returns (address[] memory receivers, uint256[] memory percentages);

}

interface IProxyWithAdminActions {

  event AdminChanged(address previousAdmin, address newAdmin);

  function upgradeToAndCall(address newImplementation, bytes calldata data) external payable;


  function changeAdmin(address newAdmin) external;

}

interface IProposalExecutor {

    function execute() external;

}

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
}

contract AIP2ProposalPayload is IProposalExecutor {

  event ProposalExecuted();

  address public constant DISTRIBUTOR_IMPL = 0x62C936a16905AfC49B589a41d033eE222A2325Ad;
  address public constant DISTRIBUTOR_PROXY = 0xE3d9988F676457123C5fD01297605efdD0Cba1ae;
  address public constant AAVE_COLLECTOR = 0x464C71f6c2F760DdA6093dCB91C24c39e5d6e18c;
  address public constant REFERRAL_WALLET = 0x2fbB0c60a41cB7Ea5323071624dCEAD3d213D0Fa;

  function execute() external override {

    address[] memory receivers = new address[](2);
    receivers[0] = AAVE_COLLECTOR;
    receivers[1] = REFERRAL_WALLET;

    uint256[] memory percentages = new uint256[](2);
    percentages[0] = uint256(8000);
    percentages[1] = uint256(2000);

    bytes memory params =
      abi.encodeWithSelector(
        ITokenDistributor(DISTRIBUTOR_IMPL).initialize.selector,
        receivers,
        percentages
      );

    IProxyWithAdminActions(DISTRIBUTOR_PROXY).upgradeToAndCall(DISTRIBUTOR_IMPL, params);

    emit ProposalExecuted();
  }
}