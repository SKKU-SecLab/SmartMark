
pragma solidity ^0.4.21;

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

contract ERC20Token {

    function mintTokens(address _atAddress, uint256 _amount) public;


}

contract MultipleVesting is Ownable {

    using SafeMath for uint256;

    struct Grant {
        uint256 start;
        uint256 cliff;
        uint256 duration;
        uint256 value;
        uint256 transferred;
        bool revocable;
    }

    mapping (address => Grant) public grants;
    mapping (uint256 => address) public indexedGrants;
    uint256 public index;
    uint256 public totalVesting;
    ERC20Token token;

    event NewGrant(address indexed _address, uint256 _value);
    event UnlockGrant(address indexed _holder, uint256 _value);
    event RevokeGrant(address indexed _holder, uint256 _refund);

    function setToken(address _token) public onlyOwner {

        token = ERC20Token(_token);
    }

    function newGrant(address _address, uint256 _start, uint256 _cliff, uint256 _duration, uint256 _value, bool _revocable) public onlyOwner {

        if(grants[_address].value == 0) {
            indexedGrants[index] = _address;
            index = index.add(1);
        }
        grants[_address] = Grant({
            start: _start,
            cliff: _cliff,
            duration: _duration,
            value: _value,
            transferred: 0,
            revocable: _revocable
            });

        totalVesting = totalVesting.add(_value);
        emit NewGrant(_address, _value);
    }

    function revoke(address _grant) public onlyOwner {

        Grant storage grant = grants[_grant];
        require(grant.revocable);

        uint256 refund = grant.value.sub(grant.transferred);

        delete grants[_grant];
        totalVesting = totalVesting.sub(refund);

        token.mintTokens(msg.sender, refund);
        emit RevokeGrant(_grant, refund);
    }

    function vestedTokens(address _holder, uint256 _time) public constant returns (uint256) {

        Grant storage grant = grants[_holder];
        if (grant.value == 0) {
            return 0;
        }

        return calculateVestedTokens(grant, _time);
    }

    function calculateVestedTokens(Grant _grant, uint256 _time) private pure returns (uint256) {

        if (_time < _grant.cliff) {
            return 0;
        }

        if (_time >= _grant.duration) {
            return _grant.value;
        }

        return _grant.value.mul(_time.sub(_grant.start)).div(_grant.duration.sub(_grant.start));
    }

    function vest() public onlyOwner {

        for(uint16 i = 0; i < index; i++) {
            Grant storage grant = grants[indexedGrants[i]];
            if(grant.value == 0) continue;
            uint256 vested = calculateVestedTokens(grant, now);
            if (vested == 0) {
                continue;
            }

            uint256 transferable = vested.sub(grant.transferred);
            if (transferable == 0) {
                continue;
            }

            grant.transferred = grant.transferred.add(transferable);
            totalVesting = totalVesting.sub(transferable);
            token.mintTokens(indexedGrants[i], transferable);

            emit UnlockGrant(msg.sender, transferable);
        }
    }

    function unlockVestedTokens() public {

        Grant storage grant = grants[msg.sender];
        require(grant.value != 0);

        uint256 vested = calculateVestedTokens(grant, now);
        if (vested == 0) {
            return;
        }

        uint256 transferable = vested.sub(grant.transferred);
        if (transferable == 0) {
            return;
        }

        grant.transferred = grant.transferred.add(transferable);
        totalVesting = totalVesting.sub(transferable);
        token.mintTokens(msg.sender, transferable);

        emit UnlockGrant(msg.sender, transferable);
    }
}