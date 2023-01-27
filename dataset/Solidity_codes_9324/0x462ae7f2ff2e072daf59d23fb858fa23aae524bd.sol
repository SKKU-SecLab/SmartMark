
pragma solidity ^0.4.20;







contract Ownable {

  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  function Ownable() public {

    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {

    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}



contract Pausable is Ownable {

  event Pause();
  event Unpause();

  bool public paused = false;


  modifier whenNotPaused() {

    require(!paused);
    _;
  }

  modifier whenPaused() {

    require(paused);
    _;
  }

  function pause() onlyOwner whenNotPaused public {

    paused = true;
    emit Pause();
  }

  function unpause() onlyOwner whenPaused public {

    paused = false;
    emit Unpause();
  }
}



contract ConfigInterface
{

    function isConfig() public pure returns (bool);


    function getCooldownIndexFromGeneration(uint16 _generation) public view returns (uint16);

    
    function getCooldownEndTimeFromIndex(uint16 _cooldownIndex) public view returns (uint40);


    function getCooldownIndexCount() public view returns (uint256);

    
    function getBabyGen(uint16 _momGen, uint16 _dadGen) public pure returns (uint16);


    function getTutorialBabyGen(uint16 _dadGen) public pure returns (uint16);


    function getBreedingFee(uint40 _momId, uint40 _dadId) public view returns (uint256);

}



contract CutieCoreInterface
{

    function isCutieCore() pure public returns (bool);


    function transferFrom(address _from, address _to, uint256 _cutieId) external;

    function transfer(address _to, uint256 _cutieId) external;


    function ownerOf(uint256 _cutieId)
        external
        view
        returns (address owner);


    function getCutie(uint40 _id)
        external
        view
        returns (
        uint256 genes,
        uint40 birthTime,
        uint40 cooldownEndTime,
        uint40 momId,
        uint40 dadId,
        uint16 cooldownIndex,
        uint16 generation
    );


    function getGenes(uint40 _id)
        public
        view
        returns (
        uint256 genes
    );



    function getCooldownEndTime(uint40 _id)
        public
        view
        returns (
        uint40 cooldownEndTime
    );


    function getCooldownIndex(uint40 _id)
        public
        view
        returns (
        uint16 cooldownIndex
    );



    function getGeneration(uint40 _id)
        public
        view
        returns (
        uint16 generation
    );


    function getOptional(uint40 _id)
        public
        view
        returns (
        uint64 optional
    );



    function changeGenes(
        uint40 _cutieId,
        uint256 _genes)
        public;


    function changeCooldownEndTime(
        uint40 _cutieId,
        uint40 _cooldownEndTime)
        public;


    function changeCooldownIndex(
        uint40 _cutieId,
        uint16 _cooldownIndex)
        public;


    function changeOptional(
        uint40 _cutieId,
        uint64 _optional)
        public;


    function changeGeneration(
        uint40 _cutieId,
        uint16 _generation)
        public;

}



contract Config is Ownable, ConfigInterface
{

	function isConfig() public pure returns (bool)
	{

		return true;
	}

    uint32[14] public cooldowns = [
        uint32(1 minutes),
        uint32(2 minutes),
        uint32(5 minutes),
        uint32(10 minutes),
        uint32(30 minutes),
        uint32(1 hours),
        uint32(2 hours),
        uint32(4 hours),
        uint32(8 hours),
        uint32(16 hours),
        uint32(1 days),
        uint32(2 days),
        uint32(4 days),
        uint32(7 days)
    ];


    CutieCoreInterface public coreContract;

    function setup(address _coreAddress) public onlyOwner
    {

        CutieCoreInterface candidateContract = CutieCoreInterface(_coreAddress);
        require(candidateContract.isCutieCore());
        coreContract = candidateContract;
    }

    function getCooldownIndexFromGeneration(uint16 _generation) public view returns (uint16)
    {

        uint16 result = _generation;
        if (result >= getCooldownIndexCount()) {
            result = uint16(getCooldownIndexCount() - 1);
        }
        return result;
    }

    function getCooldownEndTimeFromIndex(uint16 _cooldownIndex) public view returns (uint40)
    {

        return uint40(now + cooldowns[_cooldownIndex]);
    }

    function getCooldownIndexCount() public view returns (uint256)
    {

        return cooldowns.length;
    }

    function getBabyGen(uint16 _momGen, uint16 _dadGen) public pure returns (uint16)
    {

        uint16 babyGen = _momGen;
        if (_dadGen > _momGen) {
            babyGen = _dadGen;
        }
        babyGen = babyGen + 1;
        return babyGen;
    }

    function getTutorialBabyGen(uint16 _dadGen) public pure returns (uint16)
    {

        return getBabyGen(13, _dadGen);
    }

    function getBreedingFee(uint40 _momId, uint40 _dadId)
        public
        view
        returns (uint256)
    {

        uint16 momGen = coreContract.getGeneration(_momId);
        uint16 dadGen = coreContract.getGeneration(_dadId);

        if (momGen == 0 && dadGen == 0)
        {
            uint16 momIndex = coreContract.getCooldownIndex(_momId);
            uint16 dadIndex = coreContract.getCooldownIndex(_dadId);
            uint16 sum = momIndex + dadIndex;
            return 1 finney + 3 szabo*sum*sum;
        }
        else
        {
            return 500 szabo*(momGen + dadGen + 10)/2;
        }
    }
}