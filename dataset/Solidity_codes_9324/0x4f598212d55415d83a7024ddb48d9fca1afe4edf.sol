

pragma solidity ^0.5.0;

library Strings {


    function strConcat(string memory _a, string memory _b) internal pure returns (string memory _concatenatedString) {

        return strConcat(_a, _b, "", "", "");
    }

    function strConcat(string memory _a, string memory _b, string memory _c) internal pure returns (string memory _concatenatedString) {

        return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(string memory _a, string memory _b, string memory _c, string memory _d) internal pure returns (string memory _concatenatedString) {

        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(string memory _a, string memory _b, string memory _c, string memory _d, string memory _e) internal pure returns (string memory _concatenatedString) {

        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        uint i = 0;
        for (i = 0; i < _ba.length; i++) {
            babcde[k++] = _ba[i];
        }
        for (i = 0; i < _bb.length; i++) {
            babcde[k++] = _bb[i];
        }
        for (i = 0; i < _bc.length; i++) {
            babcde[k++] = _bc[i];
        }
        for (i = 0; i < _bd.length; i++) {
            babcde[k++] = _bd[i];
        }
        for (i = 0; i < _be.length; i++) {
            babcde[k++] = _be[i];
        }
        return string(babcde);
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {

        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
}


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
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

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}

interface GenArt721CoreV2 {

  function isWhitelisted(address sender) external view returns (bool);

  function projectIdToCurrencySymbol(uint256 _projectId) external view returns (string memory);

  function projectIdToCurrencyAddress(uint256 _projectId) external view returns (address);

  function projectIdToArtistAddress(uint256 _projectId) external view returns (address payable);

  function projectIdToPricePerTokenInWei(uint256 _projectId) external view returns (uint256);

  function projectIdToAdditionalPayee(uint256 _projectId) external view returns (address payable);

  function projectIdToAdditionalPayeePercentage(uint256 _projectId) external view returns (uint256);

  function projectTokenInfo(uint256 _projectId) external view returns (address, uint256, uint256, uint256, bool, address, uint256, string memory, address);

  function renderProviderAddress() external view returns (address payable);

  function renderProviderPercentage() external view returns (uint256);

  function mint(address _to, uint256 _projectId, address _by) external returns (uint256 tokenId);

}

interface ERC20 {

  function balanceOf(address _owner) external view returns (uint balance);

  function transferFrom(address _from, address _to, uint _value) external returns (bool success);

  function allowance(address _owner, address _spender) external view returns (uint remaining);

}

interface BonusContract {

  function triggerBonus(address _to) external returns (bool);

  function bonusIsActive() external view returns (bool);

}

contract GenArt721Minter_DoodleLabs {

  using SafeMath for uint256;

  GenArt721CoreV2 public genArtCoreContract;

  uint256 constant ONE_MILLION = 1_000_000;

  address payable public ownerAddress;
  uint256 public ownerPercentage;

  mapping(uint256 => bool) public projectIdToBonus;
  mapping(uint256 => address) public projectIdToBonusContractAddress;
  mapping(uint256 => bool) public contractFilterProject;
  mapping(address => mapping (uint256 => uint256)) public projectMintCounter;
  mapping(uint256 => uint256) public projectMintLimit;
  mapping(uint256 => bool) public projectMaxHasBeenInvoked;
  mapping(uint256 => uint256) public projectMaxInvocations;

  constructor(address _genArt721Address) public {
    genArtCoreContract=GenArt721CoreV2(_genArt721Address);
  }

  function getYourBalanceOfProjectERC20(uint256 _projectId) public view returns (uint256){

    uint256 balance = ERC20(genArtCoreContract.projectIdToCurrencyAddress(_projectId)).balanceOf(msg.sender);
    return balance;
  }

  function checkYourAllowanceOfProjectERC20(uint256 _projectId) public view returns (uint256){

    uint256 remaining = ERC20(genArtCoreContract.projectIdToCurrencyAddress(_projectId)).allowance(msg.sender, address(this));
    return remaining;
  }

  function setProjectMintLimit(uint256 _projectId,uint8 _limit) public {

    require(genArtCoreContract.isWhitelisted(msg.sender), "can only be set by admin");
    projectMintLimit[_projectId] = _limit;
  }

  function setProjectMaxInvocations(uint256 _projectId) public {

    require(genArtCoreContract.isWhitelisted(msg.sender), "can only be set by admin");
    uint256 maxInvocations;
    uint256 invocations;
    ( , , invocations, maxInvocations, , , , , ) = genArtCoreContract.projectTokenInfo(_projectId);
    projectMaxInvocations[_projectId] = maxInvocations;
    if (invocations < maxInvocations) {
        projectMaxHasBeenInvoked[_projectId] = false;
    }
  }

  function setOwnerAddress(address payable _ownerAddress) public {

    require(genArtCoreContract.isWhitelisted(msg.sender), "can only be set by admin");
    ownerAddress = _ownerAddress;
  }

  function setOwnerPercentage(uint256 _ownerPercentage) public {

    require(genArtCoreContract.isWhitelisted(msg.sender), "can only be set by admin");
    ownerPercentage = _ownerPercentage;
  }

  function toggleContractFilter(uint256 _projectId) public {

    require(genArtCoreContract.isWhitelisted(msg.sender), "can only be set by admin");
    contractFilterProject[_projectId]=!contractFilterProject[_projectId];
  }

  function artistToggleBonus(uint256 _projectId) public {

    require(msg.sender==genArtCoreContract.projectIdToArtistAddress(_projectId), "can only be set by artist");
    projectIdToBonus[_projectId]=!projectIdToBonus[_projectId];
  }

  function artistSetBonusContractAddress(uint256 _projectId, address _bonusContractAddress) public {

    require(msg.sender==genArtCoreContract.projectIdToArtistAddress(_projectId), "can only be set by artist");
    projectIdToBonusContractAddress[_projectId]=_bonusContractAddress;
  }

  function purchase(uint256 _projectId) public payable returns (uint256 _tokenId) {

    return purchaseTo(msg.sender, _projectId);
  }

  function purchaseTo(address _to, uint256 _projectId) public payable returns(uint256 _tokenId){

    require(!projectMaxHasBeenInvoked[_projectId], "Maximum number of invocations reached");
    if (keccak256(abi.encodePacked(genArtCoreContract.projectIdToCurrencySymbol(_projectId))) != keccak256(abi.encodePacked("ETH"))){
      require(msg.value==0, "this project accepts a different currency and cannot accept ETH");
      require(ERC20(genArtCoreContract.projectIdToCurrencyAddress(_projectId)).allowance(msg.sender, address(this)) >= genArtCoreContract.projectIdToPricePerTokenInWei(_projectId), "Insufficient Funds Approved for TX");
      require(ERC20(genArtCoreContract.projectIdToCurrencyAddress(_projectId)).balanceOf(msg.sender) >= genArtCoreContract.projectIdToPricePerTokenInWei(_projectId), "Insufficient balance.");
      _splitFundsERC20(_projectId);
    } else {
      require(msg.value>=genArtCoreContract.projectIdToPricePerTokenInWei(_projectId), "Must send minimum value to mint!");
      _splitFundsETH(_projectId);
    }

    if (contractFilterProject[_projectId]) require(msg.sender == tx.origin, "No Contract Buys");

    if (projectMintLimit[_projectId] > 0) {
        require(projectMintCounter[msg.sender][_projectId] < projectMintLimit[_projectId], "Reached minting limit");
        projectMintCounter[msg.sender][_projectId]++;
    }

    uint256 tokenId = genArtCoreContract.mint(_to, _projectId, msg.sender);

    if (tokenId % ONE_MILLION == projectMaxInvocations[_projectId]-1){
        projectMaxHasBeenInvoked[_projectId] = true;
    }

    if (projectIdToBonus[_projectId]){
      require(BonusContract(projectIdToBonusContractAddress[_projectId]).bonusIsActive(), "bonus must be active");
      BonusContract(projectIdToBonusContractAddress[_projectId]).triggerBonus(msg.sender);
    }

    return tokenId;
  }

  function _splitFundsETH(uint256 _projectId) internal {

    if (msg.value > 0) {
      uint256 pricePerTokenInWei = genArtCoreContract.projectIdToPricePerTokenInWei(_projectId);
      uint256 refund = msg.value.sub(genArtCoreContract.projectIdToPricePerTokenInWei(_projectId));
      if (refund > 0) {
        msg.sender.transfer(refund);
      }
      uint256 renderProviderAmount = pricePerTokenInWei.div(100).mul(genArtCoreContract.renderProviderPercentage());
      if (renderProviderAmount > 0) {
        genArtCoreContract.renderProviderAddress().transfer(renderProviderAmount);
      }

      uint256 remainingFunds = pricePerTokenInWei.sub(renderProviderAmount);

      uint256 ownerFunds = remainingFunds.div(100).mul(ownerPercentage);
      if (ownerFunds > 0) {
        ownerAddress.transfer(ownerFunds);
      }

      uint256 projectFunds = pricePerTokenInWei.sub(renderProviderAmount).sub(ownerFunds);
      uint256 additionalPayeeAmount;
      if (genArtCoreContract.projectIdToAdditionalPayeePercentage(_projectId) > 0) {
        additionalPayeeAmount = projectFunds.div(100).mul(genArtCoreContract.projectIdToAdditionalPayeePercentage(_projectId));
        if (additionalPayeeAmount > 0) {
          genArtCoreContract.projectIdToAdditionalPayee(_projectId).transfer(additionalPayeeAmount);
        }
      }
      uint256 creatorFunds = projectFunds.sub(additionalPayeeAmount);
      if (creatorFunds > 0) {
        genArtCoreContract.projectIdToArtistAddress(_projectId).transfer(creatorFunds);
      }
    }
  }

  function _splitFundsERC20(uint256 _projectId) internal {

      uint256 pricePerTokenInWei = genArtCoreContract.projectIdToPricePerTokenInWei(_projectId);
      uint256 renderProviderAmount = pricePerTokenInWei.div(100).mul(genArtCoreContract.renderProviderPercentage());
      if (renderProviderAmount > 0) {
        ERC20(genArtCoreContract.projectIdToCurrencyAddress(_projectId)).transferFrom(msg.sender, genArtCoreContract.renderProviderAddress(), renderProviderAmount);
      }
      uint256 remainingFunds = pricePerTokenInWei.sub(renderProviderAmount);

      uint256 ownerFunds = remainingFunds.div(100).mul(ownerPercentage);
      if (ownerFunds > 0) {
        ERC20(genArtCoreContract.projectIdToCurrencyAddress(_projectId)).transferFrom(msg.sender, ownerAddress, ownerFunds);
      }

      uint256 projectFunds = pricePerTokenInWei.sub(renderProviderAmount).sub(ownerFunds);
      uint256 additionalPayeeAmount;
      if (genArtCoreContract.projectIdToAdditionalPayeePercentage(_projectId) > 0) {
        additionalPayeeAmount = projectFunds.div(100).mul(genArtCoreContract.projectIdToAdditionalPayeePercentage(_projectId));
        if (additionalPayeeAmount > 0) {
          ERC20(genArtCoreContract.projectIdToCurrencyAddress(_projectId)).transferFrom(msg.sender, genArtCoreContract.projectIdToAdditionalPayee(_projectId), additionalPayeeAmount);
        }
      }
      uint256 creatorFunds = projectFunds.sub(additionalPayeeAmount);
      if (creatorFunds > 0) {
        ERC20(genArtCoreContract.projectIdToCurrencyAddress(_projectId)).transferFrom(msg.sender, genArtCoreContract.projectIdToArtistAddress(_projectId), creatorFunds);
      }
    }
}