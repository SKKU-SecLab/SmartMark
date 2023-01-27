
pragma solidity ^0.8.11;



contract RescueMission {

    address payable public admin;
    bytes32 immutable public root;
    mapping(address => uint256) public claims;
    uint256 constant step = 100000 ether;
    uint256 private immutable interval;
    uint256 private openedAt;
    IERC20 immutable public cig;
    IERC20 immutable public oldCig;
    address immutable public multisig;
    event Rescue(
        address, // called by
        address, // sent claim to
        uint256  // amount CIG claimed and sent
    );
    modifier onlyAdmin {

        require(
            msg.sender == admin,
            "Only admin can call this"
        );
        _;
    }

    constructor (bytes32 _root, uint256 _interval, address _cig, address _oldCig, address _multisig) {
        root = _root;
        admin = payable(msg.sender);
        interval = _interval;
        cig = IERC20(_cig);
        oldCig = IERC20(_oldCig);
        multisig = _multisig;
    }

    function open() external onlyAdmin {

        require (openedAt == 0, "already opened");
        openedAt = block.timestamp;
    }
    function verify(
        address _to,
        uint256 _amount,
        bytes32 _root,
        bytes32[] memory _proof
    ) public pure returns (bool) {

        bytes32 computedHash = keccak256(abi.encodePacked(_to, _amount)); // leaf
        for (uint256 i = 0; i < _proof.length; i++) {
            bytes32 proofElement = _proof[i];
            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash == _root;
    }

    function rescue(
        uint256 _amount,
        address _to,
        uint256 _balance,
        bytes32[] memory _proof
    ) external payable {

        require(openedAt > 0, "not opened");
        require (verify(_to, _balance, root, _proof), "invalid proof");            // verify merkle proof
        uint256 claimed = claims[_to];                                             // read claim amount
        require (claimed < _balance, "already claimed everything");
        uint256 max = _calcMax();                                                 // get max value we can claim
        require (claimed < max, "max amount already claimed");
        uint256 credit = _balance - claimed;                                       // credit is the amount yet to pay
        if (credit > max) {
            credit = max;                                                         // cap to the max
        }
        require(_amount <= credit, "_amount exceeds credit");
        require (oldCig.transferFrom(_to, address(cig), _amount), "need old CIG"); // take old CIG
        if (cig.transfer(_to, _amount)) {
            claims[_to] += _amount;                                                // record the claim
        }
        emit Rescue(msg.sender, _to, _amount);
    }
    function kill() external onlyAdmin {

        require(_calcMax() > 5400000 ether, "cannot kill yet");
        cig.transfer(multisig, cig.balanceOf(address(this)));
        selfdestruct(admin);
    }
    function _calcMax() view private returns (uint256) {

        uint256 diff = block.timestamp - openedAt;
        if (diff < interval) {
            return step;
        }
        return  step + step * (diff / interval);
    }
    function getInfo(address _to, uint256 _amount, bytes32[] memory _proof) view public returns(uint256[] memory) {

        uint[] memory ret = new uint[](11);
        if (verify(_to, _amount, root, _proof)) {
            ret[0] = 1;                                // 1 if proof was valid
        }
        ret[1] = cig.balanceOf(address(this));         // balance of CIG in this contract (donated)
        ret[2] = claims[_to];                          // how much CIG already claimed
        ret[3] = _calcMax();                           // max CIG can claim
        ret[4] = openedAt;                             // timestamp of opening
        ret[5] = block.timestamp;                      // current timestamp
        ret[6] = cig.balanceOf(_to);                   // user's new cig balance
        ret[7] = oldCig.balanceOf(_to);                // user's old cig balance
        ret[8] = oldCig.allowance(_to, address(this)); // did user give approval for old cig?
        if (isContract(address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2))) {       // are we on mainnet?
            IERC20 lp = IERC20(address(0x7c5BbE30B5b1c1ABaA9e1Ee32e04a81a2B20a052));
            ret[9] = lp.balanceOf(_to);                                              // lp balance (not staked)
            IOldCigtoken old = IOldCigtoken(address(0x5A35A6686db167B05E2Eb74e1ede9fb5D9Cdb3E0));
            (ret[10], ) = old.userInfo(_to);                                         // staking deposit balance
        }
        return ret;
    }

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
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

interface IOldCigtoken is IERC20 {

    function userInfo(address) external view returns (uint256, uint256);

}