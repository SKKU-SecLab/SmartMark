
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT
pragma solidity ^0.8.0;


interface Factory {

    function mint(address) external;

}

interface Pass {

    function balanceOf(address) external view returns (uint256);

}

contract BasementDwellersStore is Ownable {

    Pass public constant pass =
        Pass(0x3c17017F5a584628cf8cb579A38455DBBF3f93e7);
    Factory public constant bdFactory =
        Factory(0x9A95eCEe5161b888fFE9Abd3D920c5D38e8539dA);

    address private constant core1Address =
        0x105195bE68a677d80303B9962b309A30DEf24783;
    uint256 private constant core1Shares = 62625;

    address private constant core2Address =
        0x073DfB7bf2A23f13a547FB4898a46d072f6792f8;
    uint256 private constant core2Shares = 26375;

    address private constant core3Address =
        0x32b9d0167BD2ffaf4Fb6Be5B1CA5cc3FB29b7c40;

    address private constant core4Address =
        0x704c7dA8D117Ff5cf3C3268EeCaB6A80188B2AAc;
    uint256 private constant core4Shares = 7000;

    address private constant advisor1Address =
        0xD09659effC0DE1855e9D33A4F80Eb4348CA50aF2;
    uint256 private constant advisor1Shares = 4000;


    uint256 private constant baseMod = 100000;

    uint256 public constant maxDwellers = 10000;

    uint256 public preMintedDwellers = 0;
    uint256 public constant maxPreMintDwellers = 150;

    uint256 public newlyMintedDwellersWithPass = 0;
    uint256 public constant maxDwellersPerPass = 5;
    mapping(address => uint256) public mintedDwellersOf;

    uint256 public mintedDwellersAfterPresale = 0;

    uint256 public openingHours = 1633996800; // Mon Oct 11 2021 17:00:00 PDT
    uint256 public constant operationSecondsForVIP = 3600 * 24; // 24 hours
    uint256 public constant operationSeconds = 3600 * 24; // 24 hours

    uint256 public constant ticketPrice = 0.069 ether;
    uint256 public totalTickets = 0;
    mapping(address => ticket) public ticketsOf;
    struct ticket {
        uint256 index; // Incl
        uint256 amount;
    }

    uint256 public withdrawTotal = 0;

    uint256 public constant maxMintPerTx = 30;

    uint256 public raffleNumber;
    uint256 public offsetInSlot;
    uint256 public slotSize;
    uint256 public lastTargetIndex; // index greater than this is dis-regarded
    mapping(address => result) public resultOf;
    struct result {
        bool executed;
        uint256 validTicketAmount;
    }

    bool public isSoldOut = false;
    uint256 public remainingDwellers = 0;

    event SetOpeningHours(uint256 openingHours);
    event MintWithPass(address account, uint256 amount, uint256 changes);
    event TakingTickets(address account, uint256 amount, uint256 changes);
    event SetRemainingDwellers(uint256 remainingDwellers);
    event RunRaffle(uint256 raffleNumber);
    event SetResult(
        address account,
        uint256 validTicketAmount,
        uint256 changes
    );
    event PurchaseRemainingDwellers(address account, uint256 amount);
    event MintDwellers(address account, uint256 mintRequestAmount);
    event Withdraw(address to);

    constructor() {}

    modifier whenOpened() {

        require(
            block.timestamp >= openingHours + operationSecondsForVIP,
            "Store is not opened"
        );
        require(
            block.timestamp <
                openingHours + operationSecondsForVIP + operationSeconds,
            "Store is closed"
        );
        _;
    }

    modifier whenVIPOpened() {

        require(block.timestamp >= openingHours, "Store is not opened for VIP");
        require(
            block.timestamp < openingHours + operationSecondsForVIP,
            "Store is closed for VIP"
        );
        _;
    }

    modifier onlyOwnerOrTeam() {

        require(
            core1Address == msg.sender || core2Address == msg.sender || core3Address == msg.sender || core4Address == msg.sender || owner() == msg.sender,
            "caller is neither Team Wallet nor Owner"
        );
        _;
    }



    function setOpeningHours(uint256 _openingHours) external onlyOwner {

        openingHours = _openingHours;
        emit SetOpeningHours(_openingHours);
    }

    function preMintDwellers(address[] memory recipients) external onlyOwner {

        require(
            block.timestamp <
                openingHours + operationSecondsForVIP + operationSeconds,
            "Not available after ticketing period"
        );
        uint256 totalRecipients = recipients.length;

        require(
            totalRecipients > 0,
            "Number of recipients must be greater than 0"
        );
        require(
            preMintedDwellers + totalRecipients <= maxPreMintDwellers,
            "Exceeds max pre-mint Dwellers"
        );

        for (uint256 i = 0; i < totalRecipients; i++) {
            address to = recipients[i];
            require(to != address(0), "receiver can not be empty address");
            bdFactory.mint(to);
        }

        preMintedDwellers += totalRecipients;
    }

    function mintWithPass(uint256 _amount) external payable whenVIPOpened {

        require(_amount <= maxMintPerTx, "mint amount exceeds maximum");
        require(_amount > 0, "Need to mint more than 0");

        uint256 mintedDwellers = mintedDwellersOf[msg.sender];

        uint256 passAmount = pass.balanceOf(msg.sender);


        require(
            passAmount * maxDwellersPerPass - mintedDwellers >= _amount,
            "Not enough Pass"
        );

        uint256 totalPrice = ticketPrice * _amount;
        require(totalPrice <= msg.value, "Not enough money");

        for (uint256 i = 0; i < _amount; i += 1) {
            bdFactory.mint(msg.sender);
        }

        mintedDwellersOf[msg.sender] = mintedDwellers + _amount;
        newlyMintedDwellersWithPass += _amount;

        uint256 changes = msg.value - totalPrice;
        emit MintWithPass(msg.sender, _amount, changes);

        if (changes > 0) {
            payable(msg.sender).transfer(changes);
        }
    }

    function takingTickets(uint256 _amount) external payable whenOpened {

        require(_amount > 0, "Need to take ticket more than 0");

        ticket storage myTicket = ticketsOf[msg.sender];
        require(myTicket.amount == 0, "Already registered");

        uint256 totalPrice = ticketPrice * _amount;
        require(totalPrice <= msg.value, "Not enough money");

        myTicket.index = totalTickets;
        myTicket.amount = _amount;

        totalTickets = totalTickets + _amount;

        uint256 changes = msg.value - totalPrice;
        emit TakingTickets(msg.sender, _amount, changes);

        if (changes > 0) {
            payable(msg.sender).transfer(changes);
        }
    }

    function runRaffle(uint256 _raffleNumber) external onlyOwner {

        require(
            block.timestamp >
                openingHours + operationSecondsForVIP + operationSeconds,
            "Store is not closed yet"
        );
        require(raffleNumber == 0, "raffle number is already set");

        raffleNumber = _raffleNumber;

        uint256 _remainingDwellers = maxDwellers -
            preMintedDwellers -
            newlyMintedDwellersWithPass;

        if (totalTickets <= _remainingDwellers) {
            isSoldOut = false;
            remainingDwellers = _remainingDwellers - totalTickets;

            mintedDwellersAfterPresale = totalTickets;
        } else {
            isSoldOut = true;

            slotSize = totalTickets / _remainingDwellers;
            offsetInSlot = _raffleNumber % slotSize;
            lastTargetIndex = slotSize * _remainingDwellers - 1;

            mintedDwellersAfterPresale = _remainingDwellers;
        }

        emit RunRaffle(_raffleNumber);
    }

    function calculateValidTicketAmount(
        uint256 index,
        uint256 amount,
        uint256 _slotSize,
        uint256 _offsetInSlot,
        uint256 _lastTargetIndex
    ) internal pure returns (uint256 validTicketAmount) {

        uint256 lastIndex = index + amount - 1; // incl.
        if (lastIndex > _lastTargetIndex) {
            lastIndex = _lastTargetIndex;
        }

        uint256 firstIndexOffset = index % _slotSize;
        uint256 lastIndexOffset = lastIndex % _slotSize;

        uint256 firstWinIndex;
        if (firstIndexOffset <= _offsetInSlot) {
            firstWinIndex = index + _offsetInSlot - firstIndexOffset;
        } else {
            firstWinIndex =
                index +
                _slotSize +
                _offsetInSlot -
                firstIndexOffset;
        }

        if (firstWinIndex > _lastTargetIndex) {
            validTicketAmount = 0;
        } else {
            uint256 lastWinIndex;
            if (lastIndexOffset >= _offsetInSlot) {
                lastWinIndex = lastIndex + _offsetInSlot - lastIndexOffset;
            } else if (lastIndex < _slotSize) {
                lastWinIndex = 0;
            } else {
                lastWinIndex =
                    lastIndex +
                    _offsetInSlot -
                    lastIndexOffset -
                    _slotSize;
            }

            if (firstWinIndex > lastWinIndex) {
                validTicketAmount = 0;
            } else {
                validTicketAmount =
                    (lastWinIndex - firstWinIndex) /
                    _slotSize +
                    1;
            }
        }
    }

    function calculateMyResult() external {

        require(raffleNumber > 0, "raffle number is not set yet");

        ticket storage myTicket = ticketsOf[msg.sender];
        require(myTicket.amount > 0, "No available ticket");

        result storage myResult = resultOf[msg.sender];
        require(!myResult.executed, "Already checked");

        uint256 validTicketAmount;
        if (!isSoldOut) {
            validTicketAmount = myTicket.amount;
        } else {
            validTicketAmount = calculateValidTicketAmount(
                myTicket.index,
                myTicket.amount,
                slotSize,
                offsetInSlot,
                lastTargetIndex
            );
        }

        myResult.validTicketAmount = validTicketAmount;
        myResult.executed = true;

        uint256 remainingTickets = myTicket.amount - validTicketAmount;
        uint256 changes = remainingTickets * ticketPrice;

        emit SetResult(msg.sender, validTicketAmount, changes);
        if (changes > 0) {
            payable(msg.sender).transfer(changes);
        }
    }

    function purchaseRemainingDwellers(uint256 _amount) external payable {

        require(_amount <= remainingDwellers, "Exceeds dwellers max supply");

        uint256 totalPrice = ticketPrice * _amount;
        require(totalPrice <= msg.value, "Not enough money");

        for (uint256 i = 0; i < _amount; i += 1) {
            bdFactory.mint(msg.sender);
        }

        mintedDwellersAfterPresale += _amount;
        remainingDwellers -= _amount;

        uint256 changes = msg.value - totalPrice;
        if (changes > 0) {
            payable(msg.sender).transfer(changes);
        }

        emit PurchaseRemainingDwellers(msg.sender, _amount);
    }

    function mintDwellers() external {

        result storage myResult = resultOf[msg.sender];

        require(myResult.executed, "result is not calculated yet");
        require(myResult.validTicketAmount > 0, "No valid tickets");

        uint256 mintRequestAmount = 0;

        if (myResult.validTicketAmount > maxMintPerTx) {
            mintRequestAmount = maxMintPerTx;
            myResult.validTicketAmount -= maxMintPerTx;
        } else {
            mintRequestAmount = myResult.validTicketAmount;
            myResult.validTicketAmount = 0;
        }

        for (uint256 i = 0; i < mintRequestAmount; i += 1) {
            bdFactory.mint(msg.sender);
        }

        emit MintDwellers(msg.sender, mintRequestAmount);
    }

    function withdrawAll() external onlyOwnerOrTeam {

        uint256 maxWithdrawalAmount = ticketPrice *
            (newlyMintedDwellersWithPass + mintedDwellersAfterPresale);

        require(
            maxWithdrawalAmount > withdrawTotal,
            "No Funds Currently To Withdraw"
        );

        uint256 withdrawalAmount = maxWithdrawalAmount - withdrawTotal;

        _splitAll(withdrawalAmount);
        withdrawTotal += withdrawalAmount;
    }

    function _splitAll(uint256 _amount) private {

        uint256 singleShare = _amount / baseMod;
        _withdraw(core1Address, singleShare * core1Shares);
        _withdraw(core2Address, singleShare * core2Shares);
        _withdraw(core4Address, singleShare * core4Shares);
        _withdraw(advisor1Address, singleShare * advisor1Shares);
    }

    function _withdraw(address _address, uint256 _amount) private {

        payable(_address).transfer(_amount);
    }
}