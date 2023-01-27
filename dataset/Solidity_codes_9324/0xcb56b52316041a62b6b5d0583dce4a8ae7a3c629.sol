

pragma solidity ^0.8.11;


contract Cig {

    string public constant name = "Cigarette Token";
    string public constant symbol = "CIG";
    uint8 public constant decimals = 18;
    uint256 public totalSupply = 0;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    struct UserInfo {
        uint256 deposit;    // How many LP tokens the user has deposited.
        uint256 rewardDebt; // keeps track of how much reward was paid out
    }
    mapping(address => UserInfo) public farmers;  // keeps track of UserInfo for each staking address with own pool
    mapping(address => UserInfo) public farmersMasterchef;  // keeps track of UserInfo for each staking address with masterchef pool
    mapping(address => uint256) public wBal;      // keeps tracked of wrapped old cig
    address public admin;                         // admin is used for deployment, burned after
    ILiquidityPoolERC20 public lpToken;           // lpToken is the address of LP token contract that's being staked.
    uint256 public lastRewardBlock;               // Last block number that cigarettes distribution occurs.
    uint256 public accCigPerShare;                // Accumulated cigarettes per share, times 1e12. See below.
    uint256 public masterchefDeposits;            // How much has been deposited onto the masterchef contract
    uint256 public cigPerBlock;                   // CIGs per-block rewarded and split with LPs
    bytes32 public graffiti;                      // a 32 character graffiti set when buying a CEO
    ICryptoPunk public punks;                     // a reference to the CryptoPunks contract
    event Deposit(address indexed user, uint256 amount);           // when depositing LP tokens to stake
    event Harvest(address indexed user, address to, uint256 amount);// when withdrawing LP tokens form staking
    event Withdraw(address indexed user, uint256 amount); // when withdrawing LP tokens, no rewards claimed
    event EmergencyWithdraw(address indexed user, uint256 amount); // when withdrawing LP tokens, no rewards claimed
    event ChefDeposit(address indexed user, uint256 amount);       // when depositing LP tokens to stake
    event ChefWithdraw(address indexed user, uint256 amount);      // when withdrawing LP tokens, no rewards claimed
    event RewardUp(uint256 reward, uint256 upAmount);              // when cigPerBlock is increased
    event RewardDown(uint256 reward, uint256 downAmount);          // when cigPerBlock is decreased
    event Claim(address indexed owner, uint indexed punkIndex, uint256 value); // when a punk is claimed
    mapping(uint => bool) public claims;                           // keep track of claimed punks
    modifier onlyAdmin {

        require(
            msg.sender == admin,
            "Only admin can call this"
        );
        _;
    }
    uint256 constant MIN_PRICE = 1e12;            // 0.000001 CIG
    uint256 constant CLAIM_AMOUNT = 100000 ether; // claim amount for each punk
    uint256 constant MIN_REWARD = 1e14;           // minimum block reward of 0.0001 CIG (1e14 wei)
    uint256 constant MAX_REWARD = 1000 ether;     // maximum block reward of 1000 CIG
    uint256 constant STARTING_REWARDS = 512 ether;// starting rewards at end of migration
    address public The_CEO;                       // address of CEO
    uint public CEO_punk_index;                   // which punk id the CEO is using
    uint256 public CEO_price = 50000 ether;       // price to buy the CEO title
    uint256 public CEO_state;                     // state has 3 states, described above.
    uint256 public CEO_tax_balance;               // deposit to be used to pay the CEO tax
    uint256 public taxBurnBlock;                  // The last block when the tax was burned
    uint256 public rewardsChangedBlock;           // which block was the last reward increase / decrease
    uint256 private immutable CEO_epoch_blocks;   // secs per day divided by 12 (86400 / 12), assuming 12 sec blocks
    uint256 private immutable CEO_auction_blocks; // 3600 blocks
    event NewCEO(address indexed user, uint indexed punk_id, uint256 new_price, bytes32 graffiti); // when a CEO is bought
    event TaxDeposit(address indexed user,  uint256 amount);                               // when tax is deposited
    event RevenueBurned(address indexed user,  uint256 amount);                            // when tax is burned
    event TaxBurned(address indexed user,  uint256 amount);                                // when tax is burned
    event CEODefaulted(address indexed called_by,  uint256 reward);                        // when CEO defaulted on tax
    event CEOPriceChange(uint256 price);                                                   // when CEO changed price
    modifier onlyCEO {

        require(
            msg.sender == The_CEO,
            "only CEO can call this"
        );
        _;
    }
    IRouterV2 private immutable V2ROUTER;    // address of router used to get the price quote
    ICEOERC721 private immutable The_NFT;    // reference to the CEO NFT token
    address private immutable MASTERCHEF_V2; // address pointing to SushiSwap's MasterChefv2 contract
    IOldCigtoken private immutable OC;       // Old Contract
    constructor(
        uint256 _cigPerBlock,
        address _punks,
        uint _CEO_epoch_blocks,
        uint _CEO_auction_blocks,
        uint256 _CEO_price,
        bytes32 _graffiti,
        address _NFT,
        address _V2ROUTER,
        address _OC,
        uint256 _migration_epochs,
        address _MASTERCHEF_V2
    ) {
        cigPerBlock        = _cigPerBlock;
        admin              = msg.sender;             // the admin key will be burned after deployment
        punks              = ICryptoPunk(_punks);
        CEO_epoch_blocks   = _CEO_epoch_blocks;
        CEO_auction_blocks = _CEO_auction_blocks;
        CEO_price          = _CEO_price;
        graffiti           = _graffiti;
        The_NFT            = ICEOERC721(_NFT);
        V2ROUTER           = IRouterV2(_V2ROUTER);
        OC                 = IOldCigtoken(_OC);
        lastRewardBlock =
            block.number + (CEO_epoch_blocks * _migration_epochs); // set the migration window end
        MASTERCHEF_V2 = _MASTERCHEF_V2;
        CEO_state = 3;                               // begin in migration state
    }

    function buyCEO(
        uint256 _max_spend,
        uint256 _new_price,
        uint256 _tax_amount,
        uint256 _punk_index,
        bytes32 _graffiti
    ) external  {

        require (CEO_state != 3); // disabled in in migration state
        if (CEO_state == 1 && (taxBurnBlock != block.number)) {
            _burnTax();                                                    // _burnTax can change CEO_state to 2
        }
        if (CEO_state == 2) {
            CEO_price = _calcDiscount();
        }
        require (CEO_price + _tax_amount <= _max_spend, "overpaid");       // prevent CEO over-payment
        require (_new_price >= MIN_PRICE, "price 2 smol");                 // price cannot be under 0.000001 CIG
        require (_punk_index <= 9999, "invalid punk");                     // validate the punk index
        require (_tax_amount >= _new_price / 1000, "insufficient tax" );   // at least %0.1 fee paid for 1 epoch
        transfer(address(this), CEO_price);                                // pay for the CEO title
        _burn(address(this), CEO_price);                                   // burn the revenue
        emit RevenueBurned(msg.sender, CEO_price);
        _returnDeposit(The_CEO, CEO_tax_balance);                          // return deposited tax back to old CEO
        transfer(address(this), _tax_amount);                              // deposit tax (reverts if not enough)
        CEO_tax_balance = _tax_amount;                                     // store the tax deposit amount
        _transferNFT(The_CEO, msg.sender);                                 // yank the NFT to the new CEO
        CEO_price = _new_price;                                            // set the new price
        CEO_punk_index = _punk_index;                                      // store the punk id
        The_CEO = msg.sender;                                              // store the CEO's address
        taxBurnBlock = block.number;                                       // store the block number
        CEO_state = 1;
        graffiti = _graffiti;
        emit TaxDeposit(msg.sender, _tax_amount);
        emit NewCEO(msg.sender, _punk_index, _new_price, _graffiti);
    }

    function _returnDeposit(
        address _to,
        uint256 _amount
    )
    internal
    {

        if (_amount == 0) {
            return;
        }
        balanceOf[address(this)] = balanceOf[address(this)] - _amount;
        balanceOf[_to] = balanceOf[_to] + _amount;
        emit Transfer(address(this), _to, _amount);
    }

    function _transferNFT(address _oldCEO, address _newCEO) internal {

        The_NFT.transferFrom(_oldCEO, _newCEO, 0);
    }

    function depositTax(uint256 _amount) external onlyCEO {

        require (CEO_state == 1, "no CEO");
        if (_amount > 0) {
            transfer(address(this), _amount);                   // place the tax on deposit
            CEO_tax_balance = CEO_tax_balance + _amount;        // record the balance
            emit TaxDeposit(msg.sender, _amount);
        }
        if (taxBurnBlock != block.number) {
            _burnTax();                                         // settle any tax debt
            taxBurnBlock = block.number;
        }
    }


    function burnTax() external  {

        if (taxBurnBlock == block.number) return;
        if (CEO_state == 1) {
            _burnTax();
            taxBurnBlock = block.number;
        }
    }

    function _burnTax() internal {

        uint256 tpb = CEO_price / 1000 / CEO_epoch_blocks;       // 0.1% per epoch
        uint256 debt = (block.number - taxBurnBlock) * tpb;
        if (CEO_tax_balance !=0 && CEO_tax_balance >= debt) {    // Does CEO have enough deposit to pay debt?
            CEO_tax_balance = CEO_tax_balance - debt;            // deduct tax
            _burn(address(this), debt);                          // burn the tax
            emit TaxBurned(msg.sender, debt);
        } else {
            uint256 default_amount = debt - CEO_tax_balance;     // calculate how much defaulted
            _burn(address(this), CEO_tax_balance);               // burn the tax
            emit TaxBurned(msg.sender, CEO_tax_balance);
            CEO_state = 2;                                       // initiate a Dutch auction.
            CEO_tax_balance = 0;
            _transferNFT(The_CEO, address(this));                // This contract holds the NFT temporarily
            The_CEO = address(this);                             // This contract is the "interim CEO"
            _mint(msg.sender, default_amount);                   // reward the caller for reporting tax default
            emit CEODefaulted(msg.sender, default_amount);
        }
    }

    function setPrice(uint256 _price) external onlyCEO  {

        require(CEO_state == 1, "No CEO in charge");
        require (_price >= MIN_PRICE, "price 2 smol");
        require (CEO_tax_balance >= _price / 1000, "price would default"); // need at least 0.1% for tax
        if (block.number != taxBurnBlock) {
            _burnTax();
            taxBurnBlock = block.number;
        }
        if (CEO_state == 1) {
            CEO_price = _price;                                   // set the new price
            emit CEOPriceChange(_price);
        }
    }

    function rewardUp() external onlyCEO returns (uint256)  {

        require(CEO_state == 1, "No CEO in charge");
        require(block.number > rewardsChangedBlock + (CEO_epoch_blocks*2), "wait more blocks");
        require (cigPerBlock < MAX_REWARD, "reward already max");
        rewardsChangedBlock = block.number;
        uint256 _amount = cigPerBlock / 5;            // %20
        uint256 _new_reward = cigPerBlock + _amount;
        if (_new_reward > MAX_REWARD) {
            _amount = MAX_REWARD - cigPerBlock;
            _new_reward = MAX_REWARD;                 // cap
        }
        cigPerBlock = _new_reward;
        emit RewardUp(_new_reward, _amount);
        return _amount;
    }

    function rewardDown() external onlyCEO returns (uint256) {

        require(CEO_state == 1, "No CEO in charge");
        require(block.number > rewardsChangedBlock + (CEO_epoch_blocks*2), "wait more blocks");
        require(cigPerBlock > MIN_REWARD, "reward already low");
        rewardsChangedBlock = block.number;
        uint256 _amount = cigPerBlock / 5;            // %20
        uint256 _new_reward = cigPerBlock - _amount;
        if (_new_reward < MIN_REWARD) {
            _amount = cigPerBlock - MIN_REWARD;
            _new_reward = MIN_REWARD;                 // limit
        }
        cigPerBlock = _new_reward;
        emit RewardDown(_new_reward, _amount);
        return _amount;
    }

    function _calcDiscount() internal view returns (uint256) {

        unchecked {
            uint256 d = (CEO_price / 10)           // 10% discount
            * ((block.number - taxBurnBlock) / CEO_auction_blocks);
            if (d > CEO_price) {
                return MIN_PRICE;
            }
            uint256 price = CEO_price - d;
            if (price < MIN_PRICE) {
                price = MIN_PRICE;
            }
            return price;
        }
    }


    function getStats(address _user) external view returns(uint256[] memory, address, bytes32, uint112[] memory) {

        uint[] memory ret = new uint[](27);
        uint112[] memory reserves = new uint112[](2);
        uint256 tpb = (CEO_price / 1000) / (CEO_epoch_blocks); // 0.1% per epoch
        uint256 debt = (block.number - taxBurnBlock) * tpb;
        uint256 price = CEO_price;
        UserInfo memory info = farmers[_user];
        if (CEO_state == 2) {
            price = _calcDiscount();
        }
        ret[0] = CEO_state;
        ret[1] = CEO_tax_balance;
        ret[2] = taxBurnBlock;                     // the block number last tax burn
        ret[3] = rewardsChangedBlock;              // the block of the last staking rewards change
        ret[4] = price;                            // price of the CEO title
        ret[5] = CEO_punk_index;                   // punk ID of CEO
        ret[6] = cigPerBlock;                      // staking reward per block
        ret[7] = totalSupply;                      // total supply of CIG
        if (address(lpToken) != address(0)) {
            ret[8] = lpToken.balanceOf(address(this)); // Total LP staking
            ret[16] = lpToken.balanceOf(_user);        // not staked by user
            ret[17] = pendingCig(_user);               // pending harvest
            (reserves[0], reserves[1], ) = lpToken.getReserves();        // uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast
            ret[18] = V2ROUTER.getAmountOut(1 ether, uint(reserves[0]), uint(reserves[1])); // CIG price in ETH
            if (isContract(address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2))) { // are we on mainnet?
                ILiquidityPoolERC20 ethusd = ILiquidityPoolERC20(address(0xC3D03e4F041Fd4cD388c549Ee2A29a9E5075882f));  // sushi DAI-WETH pool
                uint112 r0;
                uint112 r1;
                (r0, r1, ) = ethusd.getReserves();
                ret[19] =  V2ROUTER.getAmountOut(1 ether, uint(r0), uint(r1));      // ETH price in USD
            }
            ret[22] = lpToken.totalSupply();       // total supply
        }
        ret[9] = block.number;                       // current block number
        ret[10] = tpb;                               // "tax per block" (tpb)
        ret[11] = debt;                              // tax debt accrued
        ret[12] = lastRewardBlock;                   // the block of the last staking rewards payout update
        ret[13] = info.deposit;                      // amount of LP tokens staked by user
        ret[14] = info.rewardDebt;                   // amount of rewards paid out
        ret[15] = balanceOf[_user];                  // amount of CIG held by user
        ret[20] = accCigPerShare;                    // Accumulated cigarettes per share
        ret[21] = balanceOf[address(punks)];         // amount of CIG to be claimed
        ret[23] = wBal[_user];                       // wrapped cig balance
        ret[24] = OC.balanceOf(_user);               // balance of old cig in old isContract
        ret[25] = OC.allowance(_user, address(this));// is old contract approved
        (ret[26], ) = OC.userInfo(_user);            // old contract stake bal
        return (ret, The_CEO, graffiti, reserves);
    }

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }


    function isClaimed(uint256 _punkIndex) external view returns (bool) {

        if (claims[_punkIndex]) {
            return true;
        }
        if (OC.claims(_punkIndex)) {
            return true;
        }
        return false;
    }

    function claim(uint256 _punkIndex) external returns(bool) {

        require (CEO_state != 3, "invalid state");                            // disabled in migration state
        require (_punkIndex <= 9999, "invalid punk");
        require(claims[_punkIndex] == false, "punk already claimed");
        require(OC.claims(_punkIndex) == false, "punk already claimed");      // claimed in old contract
        require(msg.sender == punks.punkIndexToAddress(_punkIndex), "punk 404");
        claims[_punkIndex] = true;
        balanceOf[address(punks)] = balanceOf[address(punks)] - CLAIM_AMOUNT; // deduct from the punks contract
        balanceOf[msg.sender] = balanceOf[msg.sender] + CLAIM_AMOUNT;         // deposit to the caller
        emit Transfer(address(punks), msg.sender, CLAIM_AMOUNT);
        emit Claim(msg.sender, _punkIndex, CLAIM_AMOUNT);
        return true;
    }

    function stakedlpSupply() public view returns(uint256)
    {

        return lpToken.balanceOf(address(this)) + masterchefDeposits;
    }
    function update() public {

        if (block.number <= lastRewardBlock) {
            return;
        }
        uint256 supply = stakedlpSupply();
        if (supply == 0) {
            lastRewardBlock = block.number;
            return;
        }
        uint256 cigReward = (block.number - lastRewardBlock) * cigPerBlock;
        _mint(address(this), cigReward);
        accCigPerShare = accCigPerShare + (
        cigReward * 1e12 / supply
        );
        lastRewardBlock = block.number;
    }

    function pendingCig(address _user) view public returns (uint256) {

        uint256 _acps = accCigPerShare;
        UserInfo storage user = farmers[_user];
        uint256 supply = stakedlpSupply();
        if (block.number > lastRewardBlock && supply != 0) {
            uint256 cigReward = (block.number - lastRewardBlock) * cigPerBlock;
            _acps = _acps + (
            cigReward * 1e12 / supply
            );
        }
        return (user.deposit * _acps / 1e12) - user.rewardDebt;
    }


    function userInfo(uint256, address _user) view external returns (uint256, uint256 depositAmount) {

        return (0,farmers[_user].deposit + farmersMasterchef[_user].deposit);
    }
    function deposit(uint256 _amount) external {

        require(_amount != 0, "You cannot deposit only 0 tokens"); // Check how many bytes
        UserInfo storage user = farmers[msg.sender];

        update();
        _deposit(user, _amount);
        require(lpToken.transferFrom(
                address(msg.sender),
                address(this),
                _amount
            ));
        emit Deposit(msg.sender, _amount);
    }
    
    function _deposit(UserInfo storage _user, uint256 _amount) internal {

        _user.deposit += _amount;
        _user.rewardDebt += _amount * accCigPerShare / 1e12;
    }
    function withdraw(uint256 _amount) external {

        UserInfo storage user = farmers[msg.sender];
        update();
        _harvest(user, msg.sender);
        _withdraw(user, _amount);
        require(lpToken.transferFrom(
            address(this),
            address(msg.sender),
            _amount
        ));
        emit Withdraw(msg.sender, _amount);
    }
    
    function _withdraw(UserInfo storage _user, uint256 _amount) internal {

        require(_user.deposit >= _amount, "Balance is too low");
        _user.deposit -= _amount;
        uint256 _rewardAmount = _amount * accCigPerShare / 1e12;
        _user.rewardDebt -= _rewardAmount;
    }

    function harvest() external {

        UserInfo storage user = farmers[msg.sender];
        update();
        _harvest(user, msg.sender);
    }

    function _harvest(UserInfo storage _user, address _to) internal {

        uint256 potentialValue = (_user.deposit * accCigPerShare / 1e12);
        uint256 delta = potentialValue - _user.rewardDebt;
        safeSendPayout(_to, delta);
        _user.rewardDebt = _user.deposit * accCigPerShare / 1e12;
        emit Harvest(msg.sender, _to, delta);
    }

    function safeSendPayout(address _to, uint256 _amount) internal {

        uint256 cigBal = balanceOf[address(this)];
        require(cigBal >= _amount, "insert more tobacco leaves...");
        unchecked {
            balanceOf[address(this)] = balanceOf[address(this)] - _amount;
            balanceOf[_to] = balanceOf[_to] + _amount;
        }
        emit Transfer(address(this), _to, _amount);
    }

    function emergencyWithdraw() external {

        UserInfo storage user = farmers[msg.sender];
        uint256 amount = user.deposit;
        user.deposit = 0;
        user.rewardDebt = 0;
        require(lpToken.transfer(
                address(msg.sender),
                amount
            ));
        emit EmergencyWithdraw(msg.sender, amount);
    }


    function renounceOwnership() external onlyAdmin {

        admin = address(0);
    }

    function setStartingBlock(uint256 _startBlock) external onlyAdmin {

        lastRewardBlock = _startBlock;
    }

    function setPool(ILiquidityPoolERC20 _addr) external onlyAdmin {

        require(address(lpToken) == address(0), "pool already set");
        lpToken = _addr;
    }

    function setReward(uint256 _value) public onlyAdmin {

        cigPerBlock = _value;
    }

    function migrationComplete() external  {

        require (CEO_state == 3);
        require (OC.CEO_state() == 1);
        require (block.number > lastRewardBlock, "cannot end migration yet");
        CEO_state = 1;                         // CEO is in charge state
        OC.burnTax();                          // before copy, burn the old CEO's tax
        _mint(address(punks), OC.balanceOf(address(punks))); // CIG to be set aside for the remaining airdrop
        uint256 taxDeposit = OC.CEO_tax_balance();
        The_CEO = OC.The_CEO();                // copy the CEO
        if (taxDeposit > 0) {                  // copy the CEO's outstanding tax
            _mint(address(this), taxDeposit);  // mint tax that CEO had locked in previous contract (cannot be migrated)
            CEO_tax_balance =  taxDeposit;
        }
        taxBurnBlock = OC.taxBurnBlock();
        CEO_price = OC.CEO_price();
        graffiti = OC.graffiti();
        CEO_punk_index = OC.CEO_punk_index();
        cigPerBlock = STARTING_REWARDS;        // set special rewards
        lastRewardBlock = OC.lastRewardBlock();// start rewards
        rewardsChangedBlock = OC.rewardsChangedBlock();
        _transferNFT(
            address(0),
            address(0x1e32a859d69dde58d03820F8f138C99B688D132F)
        );
        emit NewCEO(
            address(0x1e32a859d69dde58d03820F8f138C99B688D132F),
            0x00000000000000000000000000000000000000000000000000000000000015c9,
            0x000000000000000000000000000000000000000000007618fa42aac317900000,
            0x41732043454f2049206465636c617265204465632032322050756e6b20446179
        );
        _transferNFT(
            address(0x1e32a859d69dde58d03820F8f138C99B688D132F),
            address(0x72014B4EEdee216E47786C4Ab27Cc6344589950d)
        );
        emit NewCEO(
            address(0x72014B4EEdee216E47786C4Ab27Cc6344589950d),
            0x0000000000000000000000000000000000000000000000000000000000000343,
            0x00000000000000000000000000000000000000000001a784379d99db42000000,
            0x40617a756d615f626974636f696e000000000000000000000000000000000000
        );
        _transferNFT(
            address(0x72014B4EEdee216E47786C4Ab27Cc6344589950d),
            address(0x4947DA4bEF9D79bc84bD584E6c12BfFa32D1bEc8)
        );
        emit NewCEO(
            address(0x4947DA4bEF9D79bc84bD584E6c12BfFa32D1bEc8),
            0x00000000000000000000000000000000000000000000000000000000000007fa,
            0x00000000000000000000000000000000000000000014adf4b7320334b9000000,
            0x46697273742070756e6b7320746f6b656e000000000000000000000000000000
        );
    }

    function wrap(uint256 _value) external {

        require (CEO_state == 3);
        OC.transferFrom(msg.sender, address(this), _value); // transfer old cig to here
        _mint(msg.sender, _value);                          // give user new cig
        wBal[msg.sender] = wBal[msg.sender] + _value;       // record increase of wrapped old cig for caller
    }

    function unwrap(uint256 _value) external {

        require (CEO_state == 3);
        _burn(msg.sender, _value);                          // burn new cig
        OC.transfer(msg.sender, _value);                    // give back old cig
        wBal[msg.sender] = wBal[msg.sender] - _value;       // record decrease of wrapped old cig for caller
    }

    function _burn(address _from, uint256 _amount) internal {

        balanceOf[_from] = balanceOf[_from] - _amount;
        totalSupply = totalSupply - _amount;
        emit Transfer(_from, address(0), _amount);
    }

    function _mint(address _to, uint256 _amount) internal {

        require(_to != address(0), "ERC20: mint to the zero address");
        unchecked {
            totalSupply = totalSupply + _amount;
            balanceOf[_to] = balanceOf[_to] + _amount;
        }
        emit Transfer(address(0), _to, _amount);
    }

    function transfer(address _to, uint256 _value) public returns (bool) {

        balanceOf[msg.sender] = balanceOf[msg.sender] - _value;
        balanceOf[_to] = balanceOf[_to] + _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
    public
    returns (bool)
    {

        uint256 a = allowance[_from][msg.sender]; // read allowance
        if (a != type(uint256).max) {             // not infinite approval
            require(_value <= a, "not approved");
            unchecked {
                allowance[_from][msg.sender] = a - _value;
            }
        }
        balanceOf[_from] = balanceOf[_from] - _value;
        balanceOf[_to] = balanceOf[_to] + _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) external returns (bool) {

        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }


    function onSushiReward (
        uint256 /* pid */,
        address _user,
        address _to,
        uint256 _sushiAmount,
        uint256 _newLpAmount)  external onlyMCV2 {
        UserInfo storage user = farmersMasterchef[_user];
        update();
        if(_sushiAmount != 0) _harvest(user, _to); // send outstanding CIG to _to
        uint256 delta;
        if(user.deposit >= _newLpAmount) { // Delta is withdraw
            delta = user.deposit - _newLpAmount;
            masterchefDeposits -= delta;   // subtract from staked total
            _withdraw(user, delta);
            emit ChefWithdraw(_user, delta);
        }
        else if(user.deposit != _newLpAmount) { // Delta is deposit
            delta = _newLpAmount - user.deposit;
            masterchefDeposits += delta;        // add to staked total
            _deposit(user, delta);
            emit ChefDeposit(_user, delta);
        }
    }

    modifier onlyMCV2 {

        require(
            msg.sender == MASTERCHEF_V2,
            "Only MCV2"
        );
        _;
    }
}


interface IRouterV2 {

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external pure returns(uint256 amountOut);

}

interface ICryptoPunk {

    function punkIndexToAddress(uint256 punkIndex) external returns (address);

}

interface ICEOERC721 {

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ILiquidityPoolERC20 is IERC20 {

    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);

    function totalSupply() external view returns(uint);

}

interface IOldCigtoken is IERC20 {

    function claims(uint256) external view returns (bool);

    function graffiti() external view returns (bytes32);

    function cigPerBlock() external view returns (uint256);

    function The_CEO() external view returns (address);

    function CEO_punk_index() external view returns (uint);

    function CEO_price() external view returns (uint256);

    function CEO_state() external view returns (uint256);

    function CEO_tax_balance() external view returns (uint256);

    function taxBurnBlock() external view returns (uint256);

    function lastRewardBlock() external view returns (uint256);

    function rewardsChangedBlock() external view returns (uint256);

    function userInfo(address) external view returns (uint256, uint256);

    function burnTax() external;

}

