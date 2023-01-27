
pragma solidity 0.8.6;




contract Generator {


    uint[] public backgroundWeights = [
        0.0161e18,
        0.0161e18,
        0.008e18,
        0.0161e18,
        0.0241e18,
        0.0161e18,
        0.0241e18,
        0.008e18,
        0.0161e18,
        0.008e18,
        0.0241e18,
        0.0241e18,
        0.008e18,
        0.0161e18,
        0.0241e18,
        0.0241e18,
        0.0161e18,
        0.0161e18,
        0.008e18,
        0.004e18,
        0.0241e18,
        0.0241e18,
        0.0161e18,
        0.008e18,
        0.0161e18,
        0.0161e18,
        0.0241e18,
        0.008e18,
        0.0161e18,
        0.0161e18,
        0.0241e18,
        0.008e18,
        0.008e18,
        0.0264e18,
        0.0241e18,
        0.008e18,
        0.0161e18,
        0.0241e18,
        0.0161e18,
        0.0161e18,
        0.0161e18,
        0.0161e18,
        0.0161e18,
        0.0161e18,
        0.0241e18,
        0.0241e18,
        0.008e18,
        0.0241e18,
        0.0241e18,
        0.0241e18,
        0.0002e18,
        0.0161e18,
        0.0241e18,
        0.004e18,
        0.0161e18,
        0.0241e18,
        0.0161e18,
        0.0161e18,
        0.0161e18,
        0.0002e18,
        0.0161e18
    ];
    uint public backgroundTotalWeight;

    uint[] public bodiesWeights = [
        0.0074e18,
        0.0222e18,
        0.0074e18,
        0.0222e18,
        0.0074e18,
        0.0222e18,
        0.0074e18,
        0.0074e18,
        0.0222e18,
        0.0222e18,
        0.0222e18,
        0.0074e18,
        0.0222e18,
        0.0074e18,
        0.0148e18,
        0.0222e18,
        0.0222e18,
        0.0222e18,
        0.0148e18,
        0.0222e18,
        0.0222e18,
        0.0148e18,
        0.0148e18,
        0.0222e18,
        0.0222e18,
        0.0037e18,
        0.0037e18,
        0.0222e18,
        0.0222e18,
        0.0222e18,
        0.0222e18,
        0.0222e18,
        0.0037e18,
        0.0222e18,
        0.0037e18,
        0.0074e18,
        0.0222e18,
        0.0222e18,
        0.0222e18,
        0.0148e18,
        0.0222e18,
        0.0148e18,
        0.0222e18,
        0.0222e18,
        0.0037e18,
        0.0222e18,
        0.0148e18,
        0.0148e18,
        0.0074e18,
        0.0037e18,
        0.0074e18,
        0.0222e18,
        0.0148e18,
        0.0222e18,
        0.0074e18,
        0.0222e18,
        0.0074e18,
        0.0222e18,
        0.0148e18,
        0.0074e18,
        0.0222e18,
        0.0222e18
    ];
    uint public bodiesTotalWeight;
    
    uint[] public earsWeights = [
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18,
        0.02e18
    ];
    uint public earsTotalWeight;

    uint[] public visorsWeights = [
        0.0072e18,
        0.0072e18,
        0.0144e18,
        0.0144e18,
        0.0072e18,
        0.0144e18,
        0.0144e18,
        0.0144e18,
        0.0144e18,
        0.0432e18,
        0.0432e18,
        0.0144e18,
        0.0144e18,
        0.0432e18,
        0.0432e18,
        0.0144e18,
        0.0144e18,
        0.0432e18,
        0.0144e18,
        0.0432e18,
        0.0719e18,
        0.0719e18,
        0.0072e18,
        0.0719e18,
        0.0432e18,
        0.0144e18,
        0.0432e18,
        0.0144e18,
        0.0432e18,
        0.0072e18,
        0.0432e18,
        0.0432e18,
        0.0432e18,
        0.0432e18
    ];
    uint public visorsTotalWeight;
    
    uint public constant LAST_NFT = 11111;
    uint public constant ONE_OF_ONE_COUNT = 25;

    uint[] public oneOfOne;
    
    uint public seedBlock;
    uint public seed;
    uint nonce;

    constructor() {
        
        seedBlock = block.number + 10;
        
        uint backgroundBuf;
        for(uint i = 0; i < backgroundWeights.length; i++) {
            backgroundBuf+= backgroundWeights[i];
        }

        backgroundTotalWeight = backgroundBuf;

        uint bodiesBuf;
        for(uint i = 0; i < bodiesWeights.length; i++) {
            bodiesBuf+= bodiesWeights[i];
        }

        bodiesTotalWeight = bodiesBuf;

        uint earsBuf;
        for(uint i = 0; i < earsWeights.length; i++) {
            earsBuf+= earsWeights[i];
        }

        earsTotalWeight = earsBuf;

        uint visorsBuf;
        for(uint i = 0; i < visorsWeights.length; i++) {
            visorsBuf+= visorsWeights[i];
        }

        visorsTotalWeight = visorsBuf;
    }


    function generateOneOfOne() public {

        require(blockhash(seedBlock) != bytes32(0), "too early or expired");
        require(oneOfOne.length == 0, "already generated");
        
        seed = uint(keccak256(abi.encodePacked(blockhash(seedBlock), tx.gasprice, block.timestamp)));

        for(uint i = 0; i < ONE_OF_ONE_COUNT; i++) {
            nonce++;
            uint _random = uint(keccak256(abi.encode(seed, nonce))) % LAST_NFT + 1;
            
            if(_random == 6127) {
                i--; 
                continue;
            }
            
            oneOfOne.push(_random);
        }

        for(uint i = 0; i < ONE_OF_ONE_COUNT; i++) {
            uint item = oneOfOne[i];
            uint count = 0;
            for(uint j = 0; j < ONE_OF_ONE_COUNT; j++) {
                if(oneOfOne[j] == item) {
                    count++;
                }
                if(count > 1) {
                    oneOfOne = new uint[](0);
                    return;
                }
            }
        }
    }

    function getNFTData(uint _tokenId) public view returns(uint[] memory res) {

        res = new uint[](5);
        
        for(uint i = 0; i < oneOfOne.length; i++) {
            if(_tokenId == oneOfOne[i]) {
                res[4] = i + 1;
                return res;
            }
        }
        
        res[0] = getRandomBackground(_tokenId) + 1;
        res[1] = getRandomBody(_tokenId) + 1;
        res[2] = getRandomEar(_tokenId) + 1;
        res[3] = getRandomVisor(_tokenId) + 1;
        res[4] = 0;
    }
    
    function getRandomBackground(uint _tokenId) public view returns(uint) {

        uint rnd = random(_tokenId, backgroundTotalWeight);

        for(uint i = 0; i < backgroundWeights.length; i++) {
          if(rnd < backgroundWeights[i]) {
            return i;
          }

          rnd -= backgroundWeights[i];
        }

        return 0;
    }

    function getRandomBody(uint _tokenId) public view returns(uint) {

        uint rnd = random(_tokenId, bodiesTotalWeight);

        for(uint i = 0; i < bodiesWeights.length; i++) {
          if(rnd < bodiesWeights[i]) {
            return i;
          }

          rnd -= bodiesWeights[i];
        }

        return 0;
    }

    function getRandomEar(uint _tokenId) public view returns(uint) {

        uint rnd = random(_tokenId, earsTotalWeight);

        for(uint i = 0; i < earsWeights.length; i++) {
          if(rnd < earsWeights[i]) {
            return i;
          }

          rnd -= earsWeights[i];
        }

        return 0;
    }

    function getRandomVisor(uint _tokenId) public view returns(uint) {

        uint rnd = random(_tokenId, visorsTotalWeight);

        for(uint i = 0; i < visorsWeights.length; i++) {
          if(rnd < visorsWeights[i]) {
            return i;
          }

          rnd -= visorsWeights[i];
        }

        return 0;
    }
    
    function random(uint _tokenId, uint _maximum) public view returns (uint) {

        return uint(keccak256(abi.encode(seed, _tokenId))) % _maximum;
    }

}