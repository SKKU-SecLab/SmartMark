
pragma solidity ^0.4.24;


pragma solidity ^0.4.23;


contract Genetic {


    uint8 public constant R = 5;

    function breed(uint256[2] mother, uint256[2] father, uint256 seed) internal view returns (uint256[2] memOffset) {




        assembly {
            memOffset := mload(0x40)
            mstore(0x40, add(memOffset, 64))


            mstore(0x0, seed)
            mstore(0x20, timestamp)

            let hash := keccak256(0, 64)

            function shiftR(value, offset) -> result {
                result := div(value, exp(2, offset))
            }


            function processSide(fatherSrc, motherSrc, rngSrc) -> result {

                {




                    {
                        if eq(and(rngSrc, 0x1), 0) {
                            let temp := fatherSrc
                            fatherSrc := motherSrc
                            motherSrc := temp
                        }

                        rngSrc := shiftR(rngSrc, 1)
                    }

                    let mask := 0

                    let cap := 0
                    let crossoverLen := and(rngSrc, 0x7f) // bin: 1111111 (7 bits ON)
                    rngSrc := shiftR(rngSrc, 7)
                    let crossoverPos := crossoverLen

                    let crossoverPosLeading1 := 1

                    for { } and(lt(crossoverPos, 256), lt(cap, 4)) {

                        crossoverLen := and(rngSrc, 0x7f) // bin: 1111111 (7 bits ON)
                        rngSrc := shiftR(rngSrc, 7)

                        crossoverPos := add(crossoverPos, crossoverLen)

                        cap := add(cap, 1)
                    } {




                        mask := sub(crossoverPosLeading1, 1)

                        crossoverPosLeading1 := mul(1, exp(2, crossoverPos))
                        mask := xor(mask,
                                    sub(crossoverPosLeading1, 1)
                        )


                        result := or(result, and(mask, fatherSrc))

                        let temp := fatherSrc
                        fatherSrc := motherSrc
                        motherSrc := temp
                    }


                    mask := not(sub(crossoverPosLeading1, 1))
                    result := or(result, and(mask, fatherSrc))


                    mstore(0x0, rngSrc)
                    mstore(0x20, 0x434f4c4c454354205045504553204f4e2043525950544f50455045532e494f21)
                    let mutations := and(
                            and(
                                and(keccak256(0, 32), keccak256(1, 33)),
                                and(keccak256(2, 34), keccak256(3, 35))
                            ),
                            keccak256(0, 36)
                    )

                    result := xor(result, mutations)

                }
            }


            {

                let relativeFatherSideLoc := mul(and(hash, 0x1), 0x20) // shift by 5 bits = mul by 2^5=32 (0x20)
                let relativeMotherSideLoc := mul(and(hash, 0x2), 0x10) // already shifted by 1, mul by 2^4=16 (0x10)

                hash := div(hash, 4)

                mstore(memOffset, processSide(
                    mload(add(father, relativeFatherSideLoc)),
                    mload(add(mother, relativeMotherSideLoc)),
                    hash
                ))

                relativeFatherSideLoc := xor(relativeFatherSideLoc, 0x20)
                relativeMotherSideLoc := xor(relativeMotherSideLoc, 0x20)

                mstore(0x0, seed)
                mstore(0x20, not(timestamp))

                hash := keccak256(0, 64)

                mstore(add(memOffset, 0x20), processSide(
                    mload(add(father, relativeFatherSideLoc)),
                    mload(add(mother, relativeMotherSideLoc)),
                    hash
                ))

            }

        }






    }

    function randomDNA(uint256 seed) internal pure returns (uint256[2] memOffset) {

        assembly {
            memOffset := mload(0x40)
            mstore(0x40, add(memOffset, 64))

            mstore(0x0, seed)

            mstore(0x20, 0x434f4c4c454354205045504553204f4e2043525950544f50455045532e494f21)



            {

                let hash := keccak256(0, 64)

                mstore(memOffset, hash)

                hash := keccak256(0, 32)
                mstore(add(memOffset, 32), hash)

            }

        }
    }

}


contract Ownable {

  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);
  }

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}


pragma solidity ^0.4.19;


contract Usernames {


    mapping(address => bytes32) public addressToUser;
    mapping(bytes32 => address) public userToAddress;

    event UserNamed(address indexed user, bytes32 indexed username);

    function claimUsername(bytes32 _username) external {

        require(userToAddress[_username] == address(0));// Username must be free

        if (addressToUser[msg.sender] != bytes32(0)) { // If user already has username free it up
            userToAddress[addressToUser[msg.sender]] = address(0);
        }

        addressToUser[msg.sender] = _username;
        userToAddress[_username] = msg.sender;

        emit UserNamed(msg.sender, _username);

    }

}


pragma solidity ^0.4.24;



contract Beneficiary is Ownable {

    address public beneficiary;

    constructor() public {
        beneficiary = msg.sender;
    }

    function setBeneficiary(address _beneficiary) public onlyOwner {

        beneficiary = _beneficiary;
    }
}


pragma solidity ^0.4.25;



contract Affiliate is Ownable {

    mapping(address => bool) public canSetAffiliate;
    mapping(address => address) public userToAffiliate;

    function setAffiliateSetter(address _setter) public onlyOwner {

        canSetAffiliate[_setter] = true;
    }

    function setAffiliate(address _user, address _affiliate) public {

        require(canSetAffiliate[msg.sender]);
        if (userToAffiliate[_user] == address(0)) {
            userToAffiliate[_user] = _affiliate;
        }
    }

}


contract ERC721 {

    function implementsERC721() public pure returns (bool);

    function totalSupply() public view returns (uint256 total);

    function balanceOf(address _owner) public view returns (uint256 balance);

    function ownerOf(uint256 _tokenId) public view returns (address owner);

    function approve(address _to, uint256 _tokenId) public;

    function transferFrom(address _from, address _to, uint256 _tokenId) public returns (bool) ;

    function transfer(address _to, uint256 _tokenId) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

}


contract PepeInterface is ERC721{

    function cozyTime(uint256 _mother, uint256 _father, address _pepeReceiver) public returns (bool);

    function getCozyAgain(uint256 _pepeId) public view returns(uint64);

}


pragma solidity ^0.4.24;





contract AuctionBase is Beneficiary {

    mapping(uint256 => PepeAuction) public auctions;//maps pepes to auctions
    PepeInterface public pepeContract;
    Affiliate public affiliateContract;
    uint256 public fee = 37500; //in 1 10000th of a percent so 3.75% at the start
    uint256 public constant FEE_DIVIDER = 1000000; //Perhaps needs better name?

    struct PepeAuction {
        address seller;
        uint256 pepeId;
        uint64 auctionBegin;
        uint64 auctionEnd;
        uint256 beginPrice;
        uint256 endPrice;
    }

    event AuctionWon(uint256 indexed pepe, address indexed winner, address indexed seller);
    event AuctionStarted(uint256 indexed pepe, address indexed seller);
    event AuctionFinalized(uint256 indexed pepe, address indexed seller);

    constructor(address _pepeContract, address _affiliateContract) public {
        pepeContract = PepeInterface(_pepeContract);
        affiliateContract = Affiliate(_affiliateContract);
    }

    function savePepe(uint256 _pepeId) external {

        require(auctions[_pepeId].auctionEnd < now);//auction must have ended
        require(pepeContract.transfer(auctions[_pepeId].seller, _pepeId));//transfer pepe back to seller

        emit AuctionFinalized(_pepeId, auctions[_pepeId].seller);

        delete auctions[_pepeId];//delete auction
    }

    function changeFee(uint256 _fee) external onlyOwner {

        require(_fee < fee);//fee can not be raised
        fee = _fee;
    }

    function startAuction(uint256 _pepeId, uint256 _beginPrice, uint256 _endPrice, uint64 _duration) public {

        require(pepeContract.transferFrom(msg.sender, address(this), _pepeId));
        require(now > auctions[_pepeId].auctionEnd);//can only start new auction if no other is active

        PepeAuction memory auction;

        auction.seller = msg.sender;
        auction.pepeId = _pepeId;
        auction.auctionBegin = uint64(now);
        auction.auctionEnd = uint64(now) + _duration;
        require(auction.auctionEnd > auction.auctionBegin);
        auction.beginPrice = _beginPrice;
        auction.endPrice = _endPrice;

        auctions[_pepeId] = auction;

        emit AuctionStarted(_pepeId, msg.sender);
    }

    function startAuctionDirect(uint256 _pepeId, uint256 _beginPrice, uint256 _endPrice, uint64 _duration, address _seller) public {

        require(msg.sender == address(pepeContract)); //can only be called by pepeContract
        require(now > auctions[_pepeId].auctionEnd);//can only start new auction if no other is active

        PepeAuction memory auction;

        auction.seller = _seller;
        auction.pepeId = _pepeId;
        auction.auctionBegin = uint64(now);
        auction.auctionEnd = uint64(now) + _duration;
        require(auction.auctionEnd > auction.auctionBegin);
        auction.beginPrice = _beginPrice;
        auction.endPrice = _endPrice;

        auctions[_pepeId] = auction;

        emit AuctionStarted(_pepeId, _seller);
    }

    function calculateBid(uint256 _pepeId) public view returns(uint256 currentBid) {

        PepeAuction storage auction = auctions[_pepeId];
        uint256 timePassed = now - auctions[_pepeId].auctionBegin;

        if (now >= auction.auctionEnd) {
            return auction.endPrice;
        } else {
            int256 priceDifference = int256(auction.endPrice) - int256(auction.beginPrice);
            int256 duration = int256(auction.auctionEnd) - int256(auction.auctionBegin);

            int256 priceChange = priceDifference * int256(timePassed) / duration;

            int256 price = int256(auction.beginPrice) + priceChange;

            return uint256(price);
        }
    }

    function getFees() public {

        beneficiary.transfer(address(this).balance);
    }


}


pragma solidity ^0.4.24;



contract CozyTimeAuction is AuctionBase {

    constructor (address _pepeContract, address _affiliateContract) AuctionBase(_pepeContract, _affiliateContract) public {

    }

    function startAuction(uint256 _pepeId, uint256 _beginPrice, uint256 _endPrice, uint64 _duration) public {

        require(pepeContract.getCozyAgain(_pepeId) <= now);//need to have this extra check
        super.startAuction(_pepeId, _beginPrice, _endPrice, _duration);
    }

    function startAuctionDirect(uint256 _pepeId, uint256 _beginPrice, uint256 _endPrice, uint64 _duration, address _seller) public {

        require(pepeContract.getCozyAgain(_pepeId) <= now);//need to have this extra check
        super.startAuctionDirect(_pepeId, _beginPrice, _endPrice, _duration, _seller);
    }

    function buyCozy(uint256 _pepeId, uint256 _cozyCandidate, bool _candidateAsFather, address _pepeReceiver) public payable {

        require(address(pepeContract) == msg.sender); //caller needs to be the PepeBase contract

        PepeAuction storage auction = auctions[_pepeId];
        require(now < auction.auctionEnd);// auction must be still going

        uint256 price = calculateBid(_pepeId);
        require(msg.value >= price);//must send enough ether
        uint256 totalFee = price * fee / FEE_DIVIDER; //safe math needed?

        auction.seller.transfer(price - totalFee);

        address affiliate = affiliateContract.userToAffiliate(_pepeReceiver);

        if (affiliate != address(0) && affiliate.send(totalFee / 2)) { //if user has affiliate
        }

        if (_candidateAsFather) {
            if (!pepeContract.cozyTime(auction.pepeId, _cozyCandidate, _pepeReceiver)) {
                revert();
            }
        } else {
            if (!pepeContract.cozyTime(_cozyCandidate, auction.pepeId, _pepeReceiver)) {
                revert();
            }
        }

        if (!pepeContract.transfer(auction.seller, _pepeId)) {
            revert(); //can't complete transfer if this fails
        }

        if (msg.value > price) { //return ether send to much
            _pepeReceiver.transfer(msg.value - price);
        }

        emit AuctionWon(_pepeId, _pepeReceiver, auction.seller);//emit event

        delete auctions[_pepeId];//deletes auction
    }

    function buyCozyAffiliated(uint256 _pepeId, uint256 _cozyCandidate, bool _candidateAsFather, address _pepeReceiver, address _affiliate) public payable {

        affiliateContract.setAffiliate(_pepeReceiver, _affiliate);
        buyCozy(_pepeId, _cozyCandidate, _candidateAsFather, _pepeReceiver);
    }
}


pragma solidity ^0.4.24;



contract Haltable is Ownable {

    uint256 public haltTime; //when the contract was halted
    bool public halted;//is the contract halted?
    uint256 public haltDuration;
    uint256 public maxHaltDuration = 8 weeks;//how long the contract can be halted

    modifier stopWhenHalted {

        require(!halted);
        _;
    }

    modifier onlyWhenHalted {

        require(halted);
        _;
    }

    function halt(uint256 _duration) public onlyOwner {

        require(haltTime == 0); //cannot halt if it was halted before
        require(_duration <= maxHaltDuration);//cannot halt for longer than maxHaltDuration
        haltDuration = _duration;
        halted = true;
        haltTime = now;
    }

    function unhalt() public {

        require(now > haltTime + haltDuration || msg.sender == owner);//unhalting is only possible when haltTime has passed or the owner unhalts
        halted = false;
    }

}


library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;
    assert(c >= a);
    return c;
  }
}


interface ERC721TokenReceiver {

	function onERC721Received(address _from, uint256 _tokenId, bytes data) external returns(bytes4);

}


pragma solidity ^0.4.24;











contract PepeBase is Genetic, Ownable, Usernames, Haltable {


    uint32[15] public cozyCoolDowns = [ //determined by generation / 2
        uint32(1 minutes),
        uint32(2 minutes),
        uint32(5 minutes),
        uint32(15 minutes),
        uint32(30 minutes),
        uint32(45 minutes),
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

    struct Pepe {
        address master; //The master of the pepe
        uint256[2] genotype; //all genes stored here
        uint64 canCozyAgain; //time when pepe can have nice time again
        uint64 generation; //what generation?
        uint64 father; //father of this pepe
        uint64 mother; //mommy of this pepe
        uint8 coolDownIndex;
    }

    mapping(uint256 => bytes32) public pepeNames;

    Pepe[] public pepes;

    bool public implementsERC721 = true; //signal erc721 support

    string public constant name = "Crypto Pepe";
    string public constant symbol = "CPEP";

    mapping(address => uint256[]) private wallets;
    mapping(address => uint256) public balances; //amounts of pepes per address
    mapping(uint256 => address) public approved; //pepe index to address approved to transfer
    mapping(address => mapping(address => bool)) public approvedForAll;

    uint256 public zeroGenPepes; //how many zero gen pepes are mined
    uint256 public constant MAX_PREMINE = 100;//how many pepes can be premined
    uint256 public constant MAX_ZERO_GEN_PEPES = 1100; //max number of zero gen pepes
    address public miner; //address of the miner contract

    modifier onlyPepeMaster(uint256 _pepeId) {

        require(pepes[_pepeId].master == msg.sender);
        _;
    }

    modifier onlyAllowed(uint256 _tokenId) {

        require(msg.sender == pepes[_tokenId].master || msg.sender == approved[_tokenId] || approvedForAll[pepes[_tokenId].master][msg.sender]); //check if msg.sender is allowed
        _;
    }

    event PepeBorn(uint256 indexed mother, uint256 indexed father, uint256 indexed pepeId);
    event PepeNamed(uint256 indexed pepeId);

    constructor() public {

        Pepe memory pepe0 = Pepe({
            master: 0x0,
            genotype: [uint256(0), uint256(0)],
            canCozyAgain: 0,
            father: 0,
            mother: 0,
            generation: 0,
            coolDownIndex: 0
        });

        pepes.push(pepe0);
    }

    function _newPepe(uint256[2] _genoType, uint64 _mother, uint64 _father, uint64 _generation, address _master) internal returns (uint256 pepeId) {

        uint8 tempCoolDownIndex;

        tempCoolDownIndex = uint8(_generation / 2);

        if (_generation > 28) {
            tempCoolDownIndex = 14;
        }

        Pepe memory _pepe = Pepe({
            master: _master, //The master of the pepe
            genotype: _genoType, //all genes stored here
            canCozyAgain: 0, //time when pepe can have nice time again
            father: _father, //father of this pepe
            mother: _mother, //mommy of this pepe
            generation: _generation, //what generation?
            coolDownIndex: tempCoolDownIndex
        });

        if (_generation == 0) {
            zeroGenPepes += 1; //count zero gen pepes
        }

        pepeId = pepes.push(_pepe) - 1;

        addToWallet(_master, pepeId);

        emit PepeBorn(_mother, _father, pepeId);
        emit Transfer(address(0), _master, pepeId);

        return pepeId;
    }

    function setMiner(address _miner) public onlyOwner {

        require(miner == address(0));//can only be set once
        miner = _miner;
    }

    function minePepe(uint256 _seed, address _receiver) public stopWhenHalted returns(uint256) {

        require(msg.sender == miner);//only miner contract can call
        require(zeroGenPepes < MAX_ZERO_GEN_PEPES);

        return _newPepe(randomDNA(_seed), 0, 0, 0, _receiver);
    }

    function pepePremine(uint256 _amount) public onlyOwner stopWhenHalted {

        for (uint i = 0; i < _amount; i++) {
            require(zeroGenPepes <= MAX_PREMINE);//can only generate set amount during premine

            _newPepe(randomDNA(uint256(keccak256(abi.encodePacked(block.timestamp, pepes.length)))), 0, 0, 0, owner);

        }
    }

    function cozyTime(uint256 _mother, uint256 _father, address _pepeReceiver) external stopWhenHalted returns (bool) {

        require(_mother != _father);
        require(pepes[_mother].master == msg.sender || approved[_mother] == msg.sender || approvedForAll[pepes[_mother].master][msg.sender]);
        require(pepes[_father].master == msg.sender || approved[_father] == msg.sender || approvedForAll[pepes[_father].master][msg.sender]);
        require(now > pepes[_mother].canCozyAgain && now > pepes[_father].canCozyAgain);
        require(pepes[_mother].mother != _father && pepes[_mother].father != _father);
        require(pepes[_father].mother != _mother && pepes[_father].father != _mother);

        Pepe storage father = pepes[_father];
        Pepe storage mother = pepes[_mother];


        approved[_father] = address(0);
        approved[_mother] = address(0);

        uint256[2] memory newGenotype = breed(father.genotype, mother.genotype, pepes.length);

        uint64 newGeneration;

        newGeneration = mother.generation + 1;
        if (newGeneration < father.generation + 1) { //if father generation is bigger
            newGeneration = father.generation + 1;
        }

        _handleCoolDown(_mother);
        _handleCoolDown(_father);

        pepes[_newPepe(newGenotype, uint64(_mother), uint64(_father), newGeneration, _pepeReceiver)].canCozyAgain = mother.canCozyAgain; //_pepeReceiver becomes the master of the pepe

        return true;
    }

    function _handleCoolDown(uint256 _pepeId) internal {

        Pepe storage tempPep = pepes[_pepeId];

        tempPep.canCozyAgain = uint64(now + cozyCoolDowns[tempPep.coolDownIndex]);

        if (tempPep.coolDownIndex < 14) {// after every cozy time pepe gets slower
            tempPep.coolDownIndex++;
        }

    }

    function setPepeName(uint256 _pepeId, bytes32 _name) public stopWhenHalted onlyPepeMaster(_pepeId) returns(bool) {

        require(pepeNames[_pepeId] == 0x0000000000000000000000000000000000000000000000000000000000000000);
        pepeNames[_pepeId] = _name;
        emit PepeNamed(_pepeId);
        return true;
    }

    function transferAndAuction(uint256 _pepeId, address _auction, uint256 _beginPrice, uint256 _endPrice, uint64 _duration) public stopWhenHalted onlyPepeMaster(_pepeId) {

        _transfer(msg.sender, _auction, _pepeId);//transfer pepe to auction
        AuctionBase auction = AuctionBase(_auction);

        auction.startAuctionDirect(_pepeId, _beginPrice, _endPrice, _duration, msg.sender);
    }

    function approveAndBuy(uint256 _pepeId, address _auction, uint256 _cozyCandidate, bool _candidateAsFather) public stopWhenHalted payable onlyPepeMaster(_cozyCandidate) {

        approved[_cozyCandidate] = _auction;
        CozyTimeAuction(_auction).buyCozy.value(msg.value)(_pepeId, _cozyCandidate, _candidateAsFather, msg.sender); //breeding resets approval
    }

    function approveAndBuyAffiliated(uint256 _pepeId, address _auction, uint256 _cozyCandidate, bool _candidateAsFather, address _affiliate) public stopWhenHalted payable onlyPepeMaster(_cozyCandidate) {

        approved[_cozyCandidate] = _auction;
        CozyTimeAuction(_auction).buyCozyAffiliated.value(msg.value)(_pepeId, _cozyCandidate, _candidateAsFather, msg.sender, _affiliate); //breeding resets approval
    }

    function getPepe(uint256 _pepeId) public view returns(address master, uint256[2] genotype, uint64 canCozyAgain, uint64 generation, uint256 father, uint256 mother, bytes32 pepeName, uint8 coolDownIndex) {

        Pepe storage tempPep = pepes[_pepeId];

        master = tempPep.master;
        genotype = tempPep.genotype;
        canCozyAgain = tempPep.canCozyAgain;
        generation = tempPep.generation;
        father = tempPep.father;
        mother = tempPep.mother;
        pepeName = pepeNames[_pepeId];
        coolDownIndex = tempPep.coolDownIndex;
    }

    function getCozyAgain(uint256 _pepeId) public view returns(uint64) {

        return pepes[_pepeId].canCozyAgain;
    }

    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function totalSupply() public view returns(uint256 total) {

        total = pepes.length - balances[address(0)];
        return total;
    }

    function balanceOf(address _owner) external view returns (uint256 balance) {

        balance = balances[_owner];
    }

    function ownerOf(uint256 _tokenId) external view returns (address _owner) {

        _owner = pepes[_tokenId].master;
    }

    function tokenOfOwnerByIndex(address _owner, uint256 _index) public constant returns (uint256 tokenId) {

        require(_index < balances[_owner]);

        return wallets[_owner][_index];
    }

    function addToWallet(address _owner, uint256 _tokenId) private {

        uint256[] storage wallet = wallets[_owner];
        uint256 balance = balances[_owner];
        if (balance < wallet.length) {
            wallet[balance] = _tokenId;
        } else {
            wallet.push(_tokenId);
        }
        balances[_owner] += 1;
    }

    function removeFromWallet(address _owner, uint256 _tokenId) private {

        uint256[] storage wallet = wallets[_owner];
        uint256 i = 0;
        for (; wallet[i] != _tokenId; i++) {
        }
        if (wallet[i] == _tokenId) {
            uint256 last = balances[_owner] - 1;
            if (last > 0) {
                wallet[i] = wallet[last];
            }

            balances[_owner] -= 1;
        }
    }

    function _transfer(address _from, address _to, uint256 _tokenId) internal {

        pepes[_tokenId].master = _to;
        approved[_tokenId] = address(0);//reset approved of pepe on every transfer

        removeFromWallet(_from, _tokenId);

        addToWallet(_to, _tokenId);

        emit Transfer(_from, _to, _tokenId);
    }

    function transfer(address _to, uint256 _tokenId) public stopWhenHalted
        onlyPepeMaster(_tokenId) //check if msg.sender is the master of this pepe
        returns(bool)
    {

        _transfer(msg.sender, _to, _tokenId);//after master modifier invoke internal transfer
        return true;
    }

    function approve(address _to, uint256 _tokenId) external stopWhenHalted
        onlyPepeMaster(_tokenId)
    {

        approved[_tokenId] = _to;
        emit Approval(msg.sender, _to, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) external stopWhenHalted {

        if (_approved) {
            approvedForAll[msg.sender][_operator] = true;
        } else {
            approvedForAll[msg.sender][_operator] = false;
        }
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(uint256 _tokenId) external view returns (address) {

        return approved[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {

        return approvedForAll[_owner][_operator];
    }

    function supportsInterface(bytes4 interfaceID) external pure returns (bool) {

        if (interfaceID == 0x80ac58cd || interfaceID == 0x01ffc9a7) { //TODO: add more interfaces the contract supports
            return true;
        }
        return false;
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external stopWhenHalted {

        _safeTransferFromInternal(_from, _to, _tokenId, "");
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) external stopWhenHalted {

        _safeTransferFromInternal(_from, _to, _tokenId, _data);
    }

    function _safeTransferFromInternal(address _from, address _to, uint256 _tokenId, bytes _data) internal onlyAllowed(_tokenId) {

        require(pepes[_tokenId].master == _from);//check if from is current owner
        require(_to != address(0));//throw on zero address

        _transfer(_from, _to, _tokenId); //transfer token

        if (isContract(_to)) { //check if is contract
            require(ERC721TokenReceiver(_to).onERC721Received(_from, _tokenId, _data) == bytes4(keccak256("onERC721Received(address,uint256,bytes)")));
        }
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public stopWhenHalted onlyAllowed(_tokenId) returns(bool) {

        require(pepes[_tokenId].master == _from);//check if _from is really the master.
        require(_to != address(0));
        _transfer(_from, _to, _tokenId);//handles event, balances and approval reset;
        return true;
    }

    function isContract(address _address) internal view returns (bool) {

        uint size;
        assembly { size := extcodesize(_address) }
        return size > 0;
    }

}