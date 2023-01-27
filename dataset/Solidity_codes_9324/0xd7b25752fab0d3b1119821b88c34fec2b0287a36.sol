
pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage)
        internal
        pure
        returns (uint256)
    {

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

    function div(uint256 a, uint256 b, string memory errorMessage)
        internal
        pure
        returns (uint256)
    {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage)
        internal
        pure
        returns (uint256)
    {

        require(b != 0, errorMessage);
        return a % b;
    }
}


contract MBDAAsset {

    using SafeMath for uint256;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    event Mint(address indexed _to, uint256 _amount, uint256 _newTotalSupply);
    event Burn(address indexed _from, uint256 _amount, uint256 _newTotalSupply);

    event BlockLockSet(uint256 _value);
    event NewAdmin(address _newAdmin);
    event NewManager(address _newManager);
    event NewInvestor(address _newInvestor);
    event RemovedInvestor(address _investor);
    event FundAssetsChanged(
        string indexed tokenSymbol,
        string assetInfo,
        uint8 amount,
        uint256 totalAssetAmount
    );

    modifier onlyAdmin {

        require(msg.sender == admin, "Only admin can perform this operation");
        _;
    }

    modifier managerOrAdmin {

        require(
            msg.sender == manager || msg.sender == admin,
            "Only manager or admin can perform this operation"
        );
        _;
    }

    modifier boardOrAdmin {

        require(
            msg.sender == board || msg.sender == admin,
            "Only admin or board can perform this operation"
        );
        _;
    }

    modifier blockLock(address _sender) {

        require(
            !isLocked() || _sender == admin,
            "Contract is locked except for the admin"
        );
        _;
    }

    modifier onlyIfMintable() {

      require(mintable, "Token minting is disabled");
      _;
    }

    struct Asset {
        string assetTicker;
        string assetInfo;
        uint8 assetPercentageParticipation;
    }

    struct Investor {
        string info;
        bool exists;
    }

    uint256 public totalSupply;
    string public name;
    uint8 public decimals;
    string public symbol;
    address public admin;
    address public board;
    address public manager;
    uint256 public lockedUntilBlock;
    bool public canChangeAssets;
    bool public mintable;
    bool public hasWhiteList;
    bool public isSyndicate;
    string public urlFinancialDetailsDocument;
    bytes32 public financialDetailsHash;
    string[] public tradingPlatforms;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;
    mapping(address => Investor) public clearedInvestors;
    Asset[] public assets;

    constructor(
        address _fundAdmin,
        address _fundBoard,
        string memory _tokenName,
        uint8 _decimalUnits,
        string memory _tokenSymbol,
        uint256 _lockedUntilBlock,
        uint256 _newTotalSupply,
        bool _canChangeAssets,
        bool _mintable,
        bool _hasWhiteList,
        bool _isSyndicate
    ) public {
        name = _tokenName;
        require(_decimalUnits <= 18, "Decimal units should be 18 or lower");
        decimals = _decimalUnits;
        symbol = _tokenSymbol;
        lockedUntilBlock = _lockedUntilBlock;
        admin = _fundAdmin;
        board = _fundBoard;
        totalSupply = _newTotalSupply;
        canChangeAssets = _canChangeAssets;
        mintable = _mintable;
        hasWhiteList = _hasWhiteList;
        isSyndicate = _isSyndicate;
        balances[address(this)] = totalSupply;
        Investor memory tmp = Investor("Contract", true);
        clearedInvestors[address(this)] = tmp;
        emit NewInvestor(address(this));
    }

    function setFinancialDetails(string memory _url)
        public
        onlyAdmin
        returns (bool)
    {

        urlFinancialDetailsDocument = _url;
        return true;
    }

    function setFinancialDetailsHash(bytes32 _hash)
        public
        onlyAdmin
        returns (bool)
    {

        financialDetailsHash = _hash;
        return true;
    }

    function addTradingPlatform(string memory _details)
        public
        onlyAdmin
        returns (bool)
    {

        tradingPlatforms.push(_details);
        return true;
    }

    function removeTradingPlatform(uint256 _index)
        public
        onlyAdmin
        returns (bool)
    {

        require(_index < tradingPlatforms.length, "Invalid platform index");
        tradingPlatforms[_index] = tradingPlatforms[tradingPlatforms.length -
            1];
        tradingPlatforms.pop();
        return true;
    }

    function addNewInvestor(address _investor, string memory _investorInfo)
        public
        onlyAdmin
        returns (bool)
    {

        require(_investor != address(0), "Invalid investor address");
        Investor memory tmp = Investor(_investorInfo, true);
        clearedInvestors[_investor] = tmp;
        emit NewInvestor(_investor);
        return true;
    }

    function removeInvestor(address _investor) public onlyAdmin returns (bool) {

        require(_investor != address(0), "Invalid investor address");
        delete (clearedInvestors[_investor]);
        emit RemovedInvestor(_investor);
        return true;
    }

    function addNewAsset(
        string memory _assetTicker,
        string memory _assetInfo,
        uint8 _assetPercentageParticipation
    ) public onlyAdmin returns (bool success) {

        uint256 totalPercentageAssets = 0;
        for (uint256 i = 0; i < assets.length; i++) {
            require(
                keccak256(bytes(_assetTicker)) !=
                    keccak256(bytes(assets[i].assetTicker)),
                "An asset cannot be assigned twice"
            );
            totalPercentageAssets = SafeMath.add(
                assets[i].assetPercentageParticipation,
                totalPercentageAssets
            );
        }
        totalPercentageAssets = SafeMath.add(
            totalPercentageAssets,
            _assetPercentageParticipation
        );
        require(
            totalPercentageAssets <= 100,
            "Total assets number cannot be higher than 100"
        );
        emit FundAssetsChanged(
            _assetTicker,
            _assetInfo,
            _assetPercentageParticipation,
            totalPercentageAssets
        );
        Asset memory newAsset = Asset(
            _assetTicker,
            _assetInfo,
            _assetPercentageParticipation
        );
        assets.push(newAsset);
        success = true;
        return success;
    }

    function removeAnAsset(uint8 _assetIndex) public onlyAdmin returns (bool) {

        require(canChangeAssets, "Cannot change asset portfolio");
        require(
            _assetIndex < assets.length,
            "Invalid asset index number. Greater than total assets"
        );
        string memory assetTicker = assets[_assetIndex].assetTicker;
        assets[_assetIndex] = assets[assets.length - 1];
        delete assets[assets.length - 1];
        assets.pop();
        emit FundAssetsChanged(assetTicker, "", 0, 0);
        return true;
    }

    function updateAnAssetQuantity(
        string memory _assetTicker,
        string memory _assetInfo,
        uint8 _newAmount
    ) public onlyAdmin returns (bool) {

        require(canChangeAssets, "Cannot change asset amount");
        require(_newAmount > 0, "Cannot set zero asset amount");
        uint256 totalAssets = 0;
        uint256 assetIndex = 0;
        for (uint256 i = 0; i < assets.length; i++) {
            if (
                keccak256(bytes(_assetTicker)) ==
                keccak256(bytes(assets[i].assetTicker))
            ) {
                assetIndex = i;
                totalAssets = SafeMath.add(totalAssets, _newAmount);
            } else {
                totalAssets = SafeMath.add(
                    totalAssets,
                    assets[i].assetPercentageParticipation
                );
            }
        }
        emit FundAssetsChanged(
            _assetTicker,
            _assetInfo,
            _newAmount,
            totalAssets
        );
        require(
            totalAssets <= 100,
            "Fund assets total percentage must be less than 100"
        );
        assets[assetIndex].assetPercentageParticipation = _newAmount;
        assets[assetIndex].assetInfo = _assetInfo;
        return true;
    }

    function totalAssetsArray() public view returns (uint256) {

        return assets.length;
    }

    function transfer(address _to, uint256 _value)
        public
        blockLock(msg.sender)
        returns (bool)
    {

        address from = (admin == msg.sender) ? address(this) : msg.sender;
        require(
            isTransferValid(from, _to, _value),
            "Invalid Transfer Operation"
        );
        balances[from] = balances[from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value)
        public
        blockLock(msg.sender)
        returns (bool)
    {

        require(_spender != address(0), "ERC20: approve to the zero address");

        address from = (admin == msg.sender) ? address(this) : msg.sender;
        allowed[from][_spender] = _value;
        emit Approval(from, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value)
        public
        blockLock(_from)
        returns (bool)
    {

        require(
            _value <= allowed[_from][msg.sender],
            "Value informed is invalid"
        );
        require(
            isTransferValid(_from, _to, _value),
            "Invalid Transfer Operation"
        );
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(
            _value,
            "Value lower than approval"
        );

        emit Transfer(_from, _to, _value);
        return true;
    }

    function mint(address _to, uint256 _value)
        public
        onlyIfMintable
        managerOrAdmin
        blockLock(msg.sender)
        returns (bool)
    {

        balances[_to] = balances[_to].add(_value);
        totalSupply = totalSupply.add(_value);

        emit Mint(_to, _value, totalSupply);
        emit Transfer(address(0), _to, _value);

        return true;
    }

    function burn(address payable _account, uint256 _value)
        public
        payable
        blockLock(msg.sender)
        managerOrAdmin
        returns (bool)
    {

        require(_account != address(0), "ERC20: burn from the zero address");

        totalSupply = totalSupply.sub(_value);
        balances[_account] = balances[_account].sub(_value);
        emit Transfer(_account, address(0), _value);
        emit Burn(_account, _value, totalSupply);
        if (msg.value > 0) {
            (bool success, ) = _account.call{value: msg.value}("");
            require(success, "Ether transfer failed.");
        }
        return true;
    }

    function setBlockLock(uint256 _lockedUntilBlock)
        public
        boardOrAdmin
        returns (bool)
    {

        lockedUntilBlock = _lockedUntilBlock;
        emit BlockLockSet(_lockedUntilBlock);
        return true;
    }

    function replaceAdmin(address _newAdmin)
        public
        boardOrAdmin
        returns (bool)
    {

        require(_newAdmin != address(0x0), "Null address");
        admin = _newAdmin;
        emit NewAdmin(_newAdmin);
        return true;
    }

    function setManager(address _newManager) public onlyAdmin returns (bool) {

        manager = _newManager;
        emit NewManager(_newManager);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256) {

        return balances[_owner];
    }

    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256)
    {

        return allowed[_owner][_spender];
    }

    function isLocked() public view returns (bool) {

        return lockedUntilBlock > block.number;
    }

    function isTransferValid(address _from, address _to, uint256 _amount)
        public
        view
        returns (bool)
    {

        if (_from == address(0)) {
            return false;
        }

        if (_to == address(0)) {
            return false;
        }

        if (!hasWhiteList) {
            return balances[_from] >= _amount; // sufficient balance
        }

        bool fromOK = clearedInvestors[_from].exists;

        if (!isSyndicate) {
            return
                balances[_from] >= _amount && // sufficient balance
                fromOK; // a seller holder within the whitelist
        }

        bool toOK = clearedInvestors[_to].exists;

        return
            balances[_from] >= _amount && // sufficient balance
            fromOK && // a seller holder within the whitelist
            toOK; // a buyer holder within the whitelist
    }
}


contract MBDAWallet {

    mapping(address => bool) public controllers;
    address[] public controllerList;
    bytes32 public recipientID;
    string public recipient;

    modifier onlyController() {

        require(controllers[msg.sender], "Sender must be a Controller Member");
        _;
    }

    event EtherReceived(address sender, uint256 amount);

    constructor(address _controller, string memory recipientExternalID) public {
        require(_controller != address(0), "Invalid address of controller 1");
        controllers[_controller] = true;
        controllerList.push(_controller);
        recipientID = keccak256(abi.encodePacked(recipientExternalID));
        recipient = recipientExternalID;
    }

    function getTotalControllers() public view returns (uint256) {

        return controllerList.length;
    }

    function newController(address _controller)
        public
        onlyController
        returns (bool)
    {

        require(!controllers[_controller], "Already a controller");
        require(_controller != address(0), "Invalid Controller address");
        require(
            msg.sender != _controller,
            "The sender cannot vote to include himself"
        );
        controllers[_controller] = true;
        controllerList.push(_controller);
        return true;
    }

    function deleteController(address _controller)
        public
        onlyController
        returns (bool)
    {

        require(_controller != address(0), "Invalid Controller address");
        require(
            controllerList.length > 1,
            "Cannot leave the wallet without a controller"
        );
        delete (controllers[_controller]);
        for (uint256 i = 0; i < controllerList.length; i++) {
            if (controllerList[i] == _controller) {
                controllerList[i] = controllerList[controllerList.length - 1];
                delete controllerList[controllerList.length - 1];
                controllerList.pop();
                return true;
            }
        }
        return false;
    }

    function getBalance(address _assetAddress) public view returns (uint256) {

        MBDAAsset mbda2 = MBDAAsset(_assetAddress);
        return mbda2.balanceOf(address(this));
    }

    function transfer(
        address _assetAddress,
        address _recipient,
        uint256 _amount
    ) public onlyController returns (bool) {

        require(_recipient != address(0), "Invalid address");
        MBDAAsset mbda = MBDAAsset(_assetAddress);
        require(
            mbda.balanceOf(address(this)) >= _amount,
            "Insufficient balance"
        );
        return mbda.transfer(_recipient, _amount);
    }

    function getRecipient() public view returns (string memory) {

        return recipient;
    }

    function getRecipientID() external view returns (bytes32) {

        return recipientID;
    }

    function changeRecipient(string memory recipientExternalID)
        public
        onlyController
        returns (bool)
    {

        recipientID = keccak256(abi.encodePacked(recipientExternalID));
        recipient = recipientExternalID;
        return true;
    }

    receive() external payable {
        emit EtherReceived(msg.sender, msg.value);
    }

    function withdrawEther(address payable _beneficiary, uint256 _amount)
        public
        onlyController
        returns (bool)
    {

        require(
            address(this).balance >= _amount,
            "There is not enough balance"
        );
        (bool success, ) = _beneficiary.call{value: _amount}("");
        require(success, "Transfer failed.");
        return success;
    }

    function isController(address _checkAddress) external view returns (bool) {

        return controllers[_checkAddress];
    }
}


contract MBDAWalletFactory {

    struct Wallet {
        string recipientID;
        address walletAddress;
        address controller;
    }

    Wallet[] public wallets;
    mapping(string => Wallet) public walletsIDMap;

    event NewWalletCreated(
        address walletAddress,
        address indexed controller,
        string recipientExternalID
    );

    function CreateWallet(
        address _controller,
        string memory recipientExternalID
    ) public returns (bool) {

        Wallet storage wallet = walletsIDMap[recipientExternalID];
        require(wallet.walletAddress == address(0x0), "WalletFactory: cannot associate same recipientExternalID twice.");

        MBDAWallet newWallet = new MBDAWallet(
            _controller,
            recipientExternalID
        );

        wallet.walletAddress = address(newWallet);
        wallet.controller = _controller;
        wallet.recipientID = recipientExternalID;

        wallets.push(wallet);
        walletsIDMap[recipientExternalID] = wallet;

        emit NewWalletCreated(
            address(newWallet),
            _controller,
            recipientExternalID
        );

        return true;
    }

    function getTotalWalletsCreated() public view returns (uint256) {

        return wallets.length;
    }

    function getWallet(string calldata recipientID)
        external
        view
        returns (Wallet memory)
    {

        require(
            walletsIDMap[recipientID].walletAddress != address(0x0),
            "invalid wallet"
        );
        return walletsIDMap[recipientID];
    }
}


contract MBDAManager {

    struct FundTokenContract {
        address fundManager;
        address fundContractAddress;
        string fundTokenSymbol;
        bool exists;
    }

    FundTokenContract[] public contracts;
    mapping(address => FundTokenContract) public contractsMap;

    event NewFundCreated(
        address indexed fundManager,
        address indexed tokenAddress,
        string indexed tokenSymbol
    );

    function newFund(
        address _fundManager,
        address _fundChairman,
        string memory _tokenName,
        uint8 _decimalUnits,
        string memory _tokenSymbol,
        uint256 _lockedUntilBlock,
        uint256 _newTotalSupply,
        bool _canChangeAssets,    //  ---> Deixar tudo _canChangeAssets
        bool _mintable, //  ---> Usar aqui _canMintNewTokens
        bool _hasWhiteList,
        bool _isSyndicate
    ) public returns (address newFundTokenAddress) {

        MBDAAsset ft = new MBDAAsset(
            _fundManager,
            _fundChairman,
            _tokenName,
            _decimalUnits,
            _tokenSymbol,
            _lockedUntilBlock,
            _newTotalSupply,
            _canChangeAssets,
            _mintable,
            _hasWhiteList,
            _isSyndicate
        );
        newFundTokenAddress = address(ft);
        FundTokenContract memory ftc = FundTokenContract(
            _fundManager,
            newFundTokenAddress,
            _tokenSymbol,
            true
        );
        contracts.push(ftc);
        contractsMap[ftc.fundContractAddress] = ftc;
        emit NewFundCreated(_fundManager, newFundTokenAddress, _tokenSymbol);
        return newFundTokenAddress;
    }

    function totalContractsGenerated() public view returns (uint256) {

        return contracts.length;
    }
}


contract MbdaBoard {

    uint256 public minVotes; //minimum number of votes to execute a proposal

    mapping(address => bool) public boardMembers; //board members
    address[] public boardMembersList; // array with member addresses

    mapping(string => bytes4) public proposalTypes;
    uint256 public totalProposals;

    struct Proposal {
        string proposalType;
        address payable destination;
        uint256 value;
        uint8 votes;
        bool executed;
        bool exists;
        bytes proposal; /// @dev ABI encoded parameters for the function of the proposal type
        bool success;
        bytes returnData;
        mapping(address => bool) voters;
    }

    mapping(uint256 => Proposal) public proposals;

    modifier onlyBoardMember() {

        require(boardMembers[msg.sender], "Sender must be a Board Member");
        _;
    }

    modifier onlyBoard() {

        require(msg.sender == address(this), "Sender must the Board");
        _;
    }

    event NewProposal(
        uint256 proposalID,
        string indexed proposalType,
        bytes proposalPayload
    );
    event Voted(address boardMember, uint256 proposalId);
    event ProposalApprovedAndEnforced(
        uint256 proposalID,
        bytes payload,
        bool success,
        bytes returnData
    );
    event Deposit(uint256 value);

    constructor(
        address[] memory _initialMembers,
        uint256 _minVotes,
        bytes4[] memory _proposalTypes,
        string[] memory _ProposalTypeDescriptions
    ) public {
        require(_minVotes > 0, "Should require at least 1 vote");
        require(
            _initialMembers.length >= _minVotes,
            "Member list length must be equal or higher than minVotes"
        );
        for (uint256 i = 0; i < _initialMembers.length; i++) {
            require(
                !boardMembers[_initialMembers[i]],
                "Duplicate Board Member sent"
            );
            boardMembersList.push(_initialMembers[i]);
            boardMembers[_initialMembers[i]] = true;
        }
        minVotes = _minVotes;

        proposalTypes["addProposalType"] = 0xeaa0dff1;
        proposalTypes["removeProposalType"] = 0x746d26b5;
        proposalTypes["changeMinVotes"] = 0x9bad192a;
        proposalTypes["addBoardMember"] = 0x1eac03ae;
        proposalTypes["removeBoardMember"] = 0x39a169f9;
        proposalTypes["replaceBoardMember"] = 0xbec44b4f;

        if (_proposalTypes.length > 0) {
            require(
                _proposalTypes.length == _ProposalTypeDescriptions.length,
                "Proposal types and descriptions do not match"
            );
            for (uint256 i = 0; i < _proposalTypes.length; i++)
                proposalTypes[_ProposalTypeDescriptions[i]] = _proposalTypes[i];
        }
    }

    function addProposal(
        string memory _type,
        bytes memory _data,
        address payable _destination,
        uint256 _value
    ) public onlyBoardMember returns (uint256 proposalID) {

        require(proposalTypes[_type] != bytes4(0x0), "Invalid proposal type");
        totalProposals++;
        proposalID = totalProposals;

        Proposal memory prop = Proposal(
            _type,
            _destination,
            _value,
            0,
            false,
            true,
            _data,
            false,
            bytes("")
        );
        proposals[proposalID] = prop;
        emit NewProposal(proposalID, _type, _data);

        require(vote(proposalID), "Voting on the new proposal failed");
        return proposalID;
    }

    function vote(uint256 _proposalID) public onlyBoardMember returns (bool) {

        require(proposals[_proposalID].exists, "The proposal is not found");
        require(
            !proposals[_proposalID].voters[msg.sender],
            "This board member has voted already"
        );
        require(
            !proposals[_proposalID].executed,
            "This proposal has been approved and enforced"
        );

        proposals[_proposalID].votes++;
        proposals[_proposalID].voters[msg.sender] = true;
        emit Voted(msg.sender, _proposalID);

        if (proposals[_proposalID].votes >= minVotes)
            executeProposal(_proposalID);

        return true;
    }

    function executeProposal(uint256 _proposalID) internal {

        Proposal memory prop = proposals[_proposalID];
        bytes memory payload = abi.encodePacked(
            proposalTypes[prop.proposalType],
            prop.proposal
        );
        proposals[_proposalID].executed = true;
        (bool success, bytes memory returnData) = prop.destination.call{value: prop.value}(payload);
        proposals[_proposalID].success = success;
        proposals[_proposalID].returnData = returnData;
        emit ProposalApprovedAndEnforced(
            _proposalID,
            payload,
            success,
            returnData
        );
    }

    function addProposalType(string memory _id, bytes4 _signature)
        public
        onlyBoard
        returns (bool)
    {

        proposalTypes[_id] = _signature;
        return true;
    }

    function removeProposalType(string memory _id)
        public
        onlyBoard
        returns (bool)
    {

        proposalTypes[_id] = bytes4("");
        return true;
    }

    function changeMinVotes(uint256 _minVotes) public onlyBoard returns (bool) {

        require(_minVotes > 0, "MinVotes cannot be less than 0");
        require(
            _minVotes <= boardMembersList.length,
            "MinVotes lower than number of members"
        );
        minVotes = _minVotes;
        return true;
    }

    function addBoardMember(address _newMember)
        public
        onlyBoard
        returns (bool)
    {

        require(!boardMembers[_newMember], "Duplicate Board Member sent");
        boardMembersList.push(_newMember);
        boardMembers[_newMember] = true;
        if (boardMembersList.length > 1 && minVotes == 0) {
            minVotes = 1;
        }
        return true;
    }

    function removeBoardMember(address _member)
        public
        onlyBoard
        returns (bool)
    {

        boardMembers[_member] = false;
        for (uint256 i = 0; i < boardMembersList.length; i++) {
            if (boardMembersList[i] == _member) {
                boardMembersList[i] = boardMembersList[boardMembersList.length -
                    1];
                boardMembersList.pop();
            }
        }
        if (boardMembersList.length < minVotes) {
            minVotes = boardMembersList.length;
        }
        return true;
    }

    function replaceBoardMember(address _oldMember, address _newMember)
        public
        onlyBoard
        returns (bool)
    {

        require(removeBoardMember(_oldMember), "Failed to remove old member");
        return addBoardMember(_newMember);
    }

    receive() external payable {
        emit Deposit(msg.value);
    }
}