
pragma solidity ^0.4.24;

library SafeMath {


    function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

        if (_a == 0) {
            return 0;
        }

        c = _a * _b;
        assert(c / _a == _b);
        return c;
    }

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

        return _a / _b;
    }

    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

        assert(_b <= _a);
        return _a - _b;
    }

    function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

        c = _a + _b;
        assert(c >= _a);
        return c;
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


contract PlayerAffiliate is Ownable {

    using SafeMath for *;

    uint256 public gameCount_;
    mapping (uint256 => uint256) public playerCount_;  //gameId => playerCount
    mapping (address => address) public playerAffiliate_;   //player => player's affiliate
    mapping (address => uint256) public affiliateWithdrew_;    // affAddr => withdrewEth
    mapping (address => uint256) public affiliateProfit_;  // affAddr => totalProfit
    mapping (uint256 => mapping(uint256 => address)) public players_;   //gameId => playerId => playerAddr
    mapping (uint256 => mapping(address => uint256)) public playerIds_;    //gameId => playerAddr => playerId;
    mapping (uint256 => address) public games_;    //gameId => gameAddress
    mapping (address => uint256) public gameIds_;  //gameAddress => gameId

    event RegisteredGame(address _addr, uint256 _gameId);
    event RegisteredAffiliate(uint256 indexed _gameId, address _plyAddr, address _affAddr);

    modifier isRegisteredGame(address _addr) {

        require(gameIds_[_addr] != 0, 'not a registered game.');
        _;
    }

    modifier isNotRegisteredGame(address _addr) {

        require(gameIds_[_addr] == 0, 'can not be a registered game.');
        _;
    }

    modifier isHuman(address _addr) {

        uint256 _codeLength;

        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }

    function determinePID(uint256 _gameId, address _addr)
        private
        returns(bool)
    {

        require(_addr != address(0));

        if (playerIds_[_gameId][_addr] == 0) {
            uint256 newPlayerId = playerCount_[_gameId] + 1;
            playerCount_[_gameId]++;
            players_[_gameId][newPlayerId] = _addr;
            playerIds_[_gameId][_addr] = newPlayerId;
            return true;
        } else {
            return false;
        }
    }

    function getOrCreatePlayerId(address _plyAddr)
        isHuman(_plyAddr)
        isRegisteredGame(msg.sender)
        public
        returns(uint256)
    {

        uint256 gameId = gameIds_[msg.sender];
        determinePID(gameId, _plyAddr);
        return playerIds_[gameId][_plyAddr];
    }

    function getPlayerId(address _gameAddr, address _plyAddr)
        isRegisteredGame(_gameAddr)
        public
        view
        returns(uint256)
    {

        uint256 gameId = gameIds_[_gameAddr];
        return playerIds_[gameId][_plyAddr];
    }

    function getPlayerAddrById(address _gameAddr, uint256 _pid)
        isRegisteredGame(_gameAddr)
        public
        view
        returns(address)
    {

        uint256 gameId = gameIds_[_gameAddr];
        return players_[gameId][_pid];
    }

    function getPlayerAmount(address _gameAddr)
        isRegisteredGame(_gameAddr)
        public
        view
        returns(uint256)
    {

        return playerCount_[gameIds_[_gameAddr]];
    }

    function registerGame(address _addr)
        onlyOwner
        isNotRegisteredGame(_addr)
        public
    {

        gameCount_++;
        games_[gameCount_] = _addr;
        gameIds_[_addr] = gameCount_;

        emit RegisteredGame(_addr, gameCount_);
    }

    function unRegisterGame(address _addr)
        onlyOwner
        isRegisteredGame(_addr)
        public
    {

        uint256 gameId = gameIds_[_addr];
        playerCount_[gameId] = 0;
        games_[gameId] = address(0);
        gameIds_[_addr] = 0;
    }

    function getOrRegisterAffiliate(address _plyAddr, address _affAddr)
        isRegisteredGame(msg.sender)
        isHuman(_plyAddr)
        isHuman(_affAddr)
        public
        returns(address)
    {

        address plyAff_ = playerAffiliate_[_plyAddr];
        uint256 gameId = gameIds_[msg.sender];

        if (plyAff_ == address(0)) {
            registerAffiliate(_plyAddr, _affAddr);
            return _affAddr;
        } else {
            determinePID(gameId, _plyAddr);
            determinePID(gameId, _affAddr);
            return plyAff_;
        }
    }

    function registerAffiliate(address _plyAddr, address _affAddr)
        private
    {

        require(_plyAddr != _affAddr);
        require(_affAddr != address(0));
        require(playerAffiliate_[_plyAddr] == address(0), 'already registered affiliate.');

        uint256 gameId = gameIds_[msg.sender];
        determinePID(gameId, _plyAddr);
        determinePID(gameId, _affAddr);

        playerAffiliate_[_plyAddr] = _affAddr;

        emit RegisteredAffiliate(gameId, _plyAddr, _affAddr);
    }

    function hasAffiliate(address _plyAddr) public view returns(bool) {

        if (playerAffiliate_[_plyAddr] == address(0))
            return false;
        return true;
    }

    function clearAffiliate(address _plyAddr)
        onlyOwner
        public
    {

        require(playerAffiliate_[_plyAddr] != address(0));
        playerAffiliate_[_plyAddr] = address(0);
    }

    function getPlyAffiliateId(address _gameAddr, address _plyAddr)
        isRegisteredGame(_gameAddr)
        public
        view
        returns(uint256)
    {

        uint256 gameId = gameIds_[_gameAddr];
        address affAddr = playerAffiliate_[_plyAddr];
        return playerIds_[gameId][affAddr];
    }

    function depositShare(address _plyAddr)
        isRegisteredGame(msg.sender)
        isHuman(_plyAddr)
        public
        payable
        returns(bool)
    {

        affiliateProfit_[_plyAddr] = (affiliateProfit_[_plyAddr]).add(msg.value);
        return true;
    }

    function getPlayerLeftProfit(address _plyAddr)
        public
        view
        returns(uint256)
    {

        return (affiliateProfit_[_plyAddr]).sub(affiliateWithdrew_[_plyAddr]);
    }

    function withdrawShare()
        isHuman(msg.sender)
        public
    {

        uint256 plyLeftProfit = getPlayerLeftProfit(msg.sender);
        require(plyLeftProfit > 0);

        affiliateWithdrew_[msg.sender] = (affiliateWithdrew_[msg.sender]).add(plyLeftProfit);
        (msg.sender).transfer(plyLeftProfit);
    }
}