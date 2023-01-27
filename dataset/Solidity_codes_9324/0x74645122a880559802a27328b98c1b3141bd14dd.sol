
pragma solidity 0.4.24;


interface IRegistry {

  function owner()
    external
    returns(address);


  function updateContractAddress(
    string _name,
    address _address
  )
    external
    returns (address);


  function getContractAddress(
    string _name
  )
    external
    view
    returns (address);

}


interface IPoaManager {

  function getTokenStatus(
    address _tokenAddress
  )
    external
    view
    returns (bool);

}


interface IPoaToken {

  function initializeToken
  (
    bytes32 _name32, // bytes32 of name string
    bytes32 _symbol32, // bytes32 of symbol string
    address _broker,
    address _custodian,
    address _registry,
    uint256 _totalSupply // token total supply
  )
    external
    returns (bool);

  function startPreFunding()
    external
    returns (bool);


  function pause()
    external;


  function unpause()
    external;


  function terminate()
    external
    returns (bool);


  function proofOfCustody()
    external
    view
    returns (string);

}


contract PoaLogger {

  uint8 public constant version = 1;
  IRegistry public registry;

  constructor(
    address _registryAddress
  )
    public
  {
    require(_registryAddress != address(0));
    registry = IRegistry(_registryAddress);
  }

  modifier onlyActivePoaToken() {

    require(
      IPoaManager(
        registry.getContractAddress("PoaManager")
      ).getTokenStatus(msg.sender)
    );
    _;
  }

  event Stage(
    address indexed tokenAddress,
    uint256 stage
  );
  event Buy(
    address indexed tokenAddress,
    address indexed buyer,
    uint256 amount
  );
  event ProofOfCustodyUpdated(
    address indexed tokenAddress,
    string ipfsHash
  );
  event Payout(
    address indexed tokenAddress,
    uint256 amount
  );
  event Claim(
    address indexed tokenAddress,
    address indexed claimer,
    uint256 payout
  );
  event Terminated(
    address indexed tokenAddress
  );
  event CustodianChanged(
    address indexed tokenAddress,
    address oldAddress,
    address newAddress
  );
  event ReClaim(
    address indexed tokenAddress,
    address indexed reclaimer,
    uint256 amount
  );

  event ProxyUpgraded(
    address indexed tokenAddress,
    address upgradedFrom,
    address upgradedTo
  );

  function logStage(
    uint256 stage
  )
    external
    onlyActivePoaToken
  {

    emit Stage(msg.sender, stage);
  }

  function logBuy(
    address buyer,
    uint256 amount
  )
    external
    onlyActivePoaToken
  {

    emit Buy(msg.sender, buyer, amount);
  }

  function logProofOfCustodyUpdated()
    external
    onlyActivePoaToken
  {

    string memory _realIpfsHash = IPoaToken(msg.sender).proofOfCustody();

    emit ProofOfCustodyUpdated(
      msg.sender,
      _realIpfsHash
    );
  }

  function logPayout(
    uint256 _amount
  )
    external
    onlyActivePoaToken
  {

    emit Payout(
      msg.sender,
      _amount
    );
  }

  function logClaim(
    address _claimer,
    uint256 _payout
    )
    external
    onlyActivePoaToken
  {

    emit Claim(
      msg.sender,
      _claimer,
      _payout
    );
  }

  function logTerminated()
    external
    onlyActivePoaToken
  {

    emit Terminated(msg.sender);
  }

  function logCustodianChanged(
    address _oldAddress,
    address _newAddress
  )
    external
    onlyActivePoaToken
  {

    emit CustodianChanged(
      msg.sender,
      _oldAddress,
      _newAddress
    );
  }

  function logReClaim(
    address _reclaimer,
    uint256 _amount
  )
    external
    onlyActivePoaToken
  {

    emit ReClaim(
      msg.sender,
      _reclaimer,
      _amount
    );
  }

  function logProxyUpgraded(
    address _upgradedFrom,
    address _upgradedTo
  )
    external
    onlyActivePoaToken
  {

    emit ProxyUpgraded(
      msg.sender,
      _upgradedFrom,
      _upgradedTo
    );
  }
}