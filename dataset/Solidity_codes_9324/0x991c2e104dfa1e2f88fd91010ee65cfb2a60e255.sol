
pragma solidity ^0.4.24;


contract DBank {

    uint256 dbk_;   // total investment in DBank
    mapping (address => uint256) invested; // address => investment
    mapping (address => uint256) atBlock; // address => user's investment at block
    uint256 public r_ = 4; //profit ratio，every 5900 blocks(1 day) you earn 4%
    uint256 public blocks_ = 5900; //blocks in every cycle

    uint256 public pID_;    // total number of players
    mapping (address => uint256) public pIDxAddr_;  // (addr => pID) returns player id by address
    mapping (uint256 => address) public plyr_;   // (pID => data) player data

    bool public bonusOn_ = true;    // give bonus or not
    uint256 public bonusAmount_ = 1 * 10**16;   // 0.01 ETH

    function ()
        external 
        payable
    {
        buyCore(msg.sender, msg.value);
    }

    function buy(uint256 refID)
        public
        payable
    {

        buyCore(msg.sender, msg.value);

        if (plyr_[refID] != address(0)) {
            invested[plyr_[refID]] += msg.value / 10;
        }

        invested[msg.sender] += msg.value / 10;
    }

    function reinvest()
        public
    {

        if (invested[msg.sender] != 0) {
            uint256 amount = invested[msg.sender] * r_ / 100 * (block.number - atBlock[msg.sender]) / blocks_;
            
            atBlock[msg.sender] = block.number;
            invested[msg.sender] += amount;
        }
    }


    function getMyInvestment()
        public
        view
        returns (uint256, uint256, uint256, uint256)
    {

        uint256 amount = 0;
        if (invested[msg.sender] != 0) {
            amount = invested[msg.sender] * r_ / 100 * (block.number - atBlock[msg.sender]) / blocks_;
        }
        return (invested[msg.sender], amount, pIDxAddr_[msg.sender], pID_);
    }


    function buyCore(address _addr, uint256 _value)
        private
    {

        bool isNewPlayer = determinePID(_addr);

        if (invested[_addr] != 0) {
            uint256 amount = invested[_addr] * r_ / 100 * (block.number - atBlock[_addr]) / blocks_;
            
            if (amount <= dbk_){
                _addr.transfer(amount);
                dbk_ -= amount;
            }
        }

        atBlock[_addr] = block.number;
        invested[_addr] += _value;
        dbk_ += _value;
        
        if (bonusOn_ && isNewPlayer) {
            invested[_addr] += bonusAmount_;
        }
    }

    function determinePID(address _addr)
        private
        returns (bool)
    {

        if (pIDxAddr_[_addr] == 0)
        {
            pID_++;
            pIDxAddr_[_addr] = pID_;
            plyr_[pID_] = _addr;
            
            return (true);  // New Player
        } else {
            return (false);
        }
    }


    address owner;
    constructor() public {
        owner = msg.sender;
        pID_ = 500;
    }

    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }

    function setBonusOn(bool _on)
        public
        onlyOwner()
    {

        bonusOn_ = _on;
    }

    function setBonusAmount(uint256 _amount)
        public
        onlyOwner()
    {

        bonusAmount_ = _amount;
    }

    function setProfitRatio(uint256 _r)
        public
        onlyOwner()
    {

        r_ = _r;
    }

    function setBlocks(uint256 _blocks)
        public
        onlyOwner()
    {

        blocks_ = _blocks;
    }


    mapping (address => uint256) public deposit_; 

    function dbkDeposit()
        public
        payable
    {

        deposit_[msg.sender] += msg.value;
    }

    function dbkWithdraw()
        public
    {

        uint256 _eth = deposit_[msg.sender];
        if (_eth > 0) {
            msg.sender.transfer(_eth);
            deposit_[msg.sender] = 0;
        }
    }
}