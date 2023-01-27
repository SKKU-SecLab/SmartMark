
pragma solidity ^0.4.6;



contract TokenController {

    function proxyPayment(address _owner) payable returns(bool);


    function onTransfer(address _from, address _to, uint _amount) returns(bool);


    function onApprove(address _owner, address _spender, uint _amount)
        returns(bool);

}

contract Controlled {

    modifier onlyController { if (msg.sender != controller) throw; _; }


    address public controller;

    function Controlled() { controller = msg.sender;}


    function changeController(address _newController) onlyController {

        controller = _newController;
    }
}

contract MiniMeToken is Controlled {


    string public name;                //The Token's name: e.g. DigixDAO Tokens
    uint8 public decimals;             //Number of decimals of the smallest unit
    string public symbol;              //An identifier: e.g. REP
    string public version = 'MMT_0.1'; //An arbitrary versioning scheme


    struct  Checkpoint {

        uint128 fromBlock;

        uint128 value;
    }

    MiniMeToken public parentToken;

    uint public parentSnapShotBlock;

    uint public creationBlock;

    mapping (address => Checkpoint[]) balances;

    mapping (address => mapping (address => uint256)) allowed;

    Checkpoint[] totalSupplyHistory;

    bool public transfersEnabled;

    MiniMeTokenFactory public tokenFactory;


    function MiniMeToken(
        address _tokenFactory,
        address _parentToken,
        uint _parentSnapShotBlock,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transfersEnabled
    ) {

        tokenFactory = MiniMeTokenFactory(_tokenFactory);
        name = _tokenName;                                 // Set the name
        decimals = _decimalUnits;                          // Set the decimals
        symbol = _tokenSymbol;                             // Set the symbol
        parentToken = MiniMeToken(_parentToken);
        parentSnapShotBlock = _parentSnapShotBlock;
        transfersEnabled = _transfersEnabled;
        creationBlock = block.number;
    }



    function transfer(address _to, uint256 _amount) returns (bool success) {

        if (!transfersEnabled) throw;
        return doTransfer(msg.sender, _to, _amount);
    }

    function transferFrom(address _from, address _to, uint256 _amount
    ) returns (bool success) {


        if (msg.sender != controller) {
            if (!transfersEnabled) throw;

            if (allowed[_from][msg.sender] < _amount) return false;
            allowed[_from][msg.sender] -= _amount;
        }
        return doTransfer(_from, _to, _amount);
    }

    function doTransfer(address _from, address _to, uint _amount
    ) internal returns(bool) {


           if (_amount == 0) {
               return true;
           }

           if ((_to == 0) || (_to == address(this))) throw;

           var previousBalanceFrom = balanceOfAt(_from, block.number);
           if (previousBalanceFrom < _amount) {
               return false;
           }

           if (isContract(controller)) {
               if (!TokenController(controller).onTransfer(_from, _to, _amount))
               throw;
           }

           updateValueAtNow(balances[_from], previousBalanceFrom - _amount);

           var previousBalanceTo = balanceOfAt(_to, block.number);
           updateValueAtNow(balances[_to], previousBalanceTo + _amount);

           Transfer(_from, _to, _amount);

           return true;
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {

        return balanceOfAt(_owner, block.number);
    }

    function approve(address _spender, uint256 _amount) returns (bool success) {

        if (!transfersEnabled) throw;

        if ((_amount!=0) && (allowed[msg.sender][_spender] !=0)) throw;

        if (isContract(controller)) {
            if (!TokenController(controller).onApprove(msg.sender, _spender, _amount))
                throw;
        }

        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender
    ) constant returns (uint256 remaining) {

        return allowed[_owner][_spender];
    }

    function approveAndCall(address _spender, uint256 _amount, bytes _extraData
    ) returns (bool success) {

        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);

        if(!_spender.call(
            bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))),
            msg.sender,
            _amount,
            this,
            _extraData
            )) { throw;
        }
        return true;
    }

    function totalSupply() constant returns (uint) {

        return totalSupplyAt(block.number);
    }



    function balanceOfAt(address _owner, uint _blockNumber) constant
        returns (uint) {


        if (_blockNumber < creationBlock) {
            return 0;

        } else if ((balances[_owner].length == 0)
            || (balances[_owner][0].fromBlock > _blockNumber)) {
            if (address(parentToken) != 0) {
                return parentToken.balanceOfAt(_owner, parentSnapShotBlock);
            } else {
                return 0;
            }

        } else {
            return getValueAt(balances[_owner], _blockNumber);
        }

    }

    function totalSupplyAt(uint _blockNumber) constant returns(uint) {


        if (_blockNumber < creationBlock) {
            return 0;

        } else if ((totalSupplyHistory.length == 0)
            || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
            if (address(parentToken) != 0) {
                return parentToken.totalSupplyAt(parentSnapShotBlock);
            } else {
                return 0;
            }

        } else {
            return getValueAt(totalSupplyHistory, _blockNumber);
        }
    }


    function createCloneToken(
        string _cloneTokenName,
        uint8 _cloneDecimalUnits,
        string _cloneTokenSymbol,
        uint _snapshotBlock,
        bool _transfersEnabled
        ) returns(address) {

        if (_snapshotBlock > block.number) _snapshotBlock = block.number;
        MiniMeToken cloneToken = tokenFactory.createCloneToken(
            this,
            _snapshotBlock,
            _cloneTokenName,
            _cloneDecimalUnits,
            _cloneTokenSymbol,
            _transfersEnabled
            );

        cloneToken.changeController(msg.sender);

        NewCloneToken(address(cloneToken), _snapshotBlock);
        return address(cloneToken);
    }


    function generateTokens(address _owner, uint _amount
    ) onlyController returns (bool) {

        uint curTotalSupply = getValueAt(totalSupplyHistory, block.number);
        updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
        var previousBalanceTo = balanceOf(_owner);
        updateValueAtNow(balances[_owner], previousBalanceTo + _amount);
        Transfer(0, _owner, _amount);
        return true;
    }


    function destroyTokens(address _owner, uint _amount
    ) onlyController returns (bool) {

        uint curTotalSupply = getValueAt(totalSupplyHistory, block.number);
        if (curTotalSupply < _amount) throw;
        updateValueAtNow(totalSupplyHistory, curTotalSupply - _amount);
        var previousBalanceFrom = balanceOf(_owner);
        if (previousBalanceFrom < _amount) throw;
        updateValueAtNow(balances[_owner], previousBalanceFrom - _amount);
        Transfer(_owner, 0, _amount);
        return true;
    }



    function enableTransfers(bool _transfersEnabled) onlyController {

        transfersEnabled = _transfersEnabled;
    }


    function getValueAt(Checkpoint[] storage checkpoints, uint _block
    ) constant internal returns (uint) {

        if (checkpoints.length == 0) return 0;

        if (_block >= checkpoints[checkpoints.length-1].fromBlock)
            return checkpoints[checkpoints.length-1].value;
        if (_block < checkpoints[0].fromBlock) return 0;

        uint min = 0;
        uint max = checkpoints.length-1;
        while (max > min) {
            uint mid = (max + min + 1)/ 2;
            if (checkpoints[mid].fromBlock<=_block) {
                min = mid;
            } else {
                max = mid-1;
            }
        }
        return checkpoints[min].value;
    }

    function updateValueAtNow(Checkpoint[] storage checkpoints, uint _value
    ) internal  {

        if ((checkpoints.length == 0)
        || (checkpoints[checkpoints.length -1].fromBlock < block.number)) {
               Checkpoint newCheckPoint = checkpoints[ checkpoints.length++ ];
               newCheckPoint.fromBlock =  uint128(block.number);
               newCheckPoint.value = uint128(_value);
           } else {
               Checkpoint oldCheckPoint = checkpoints[checkpoints.length-1];
               oldCheckPoint.value = uint128(_value);
           }
    }

    function isContract(address _addr) constant internal returns(bool) {

        uint size;
        if (_addr == 0) return false;
        assembly {
            size := extcodesize(_addr)
        }
        return size>0;
    }

    function ()  payable {
        if (isContract(controller)) {
            if (! TokenController(controller).proxyPayment.value(msg.value)(msg.sender))
                throw;
        } else {
            throw;
        }
    }


    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event NewCloneToken(address indexed _cloneToken, uint _snapshotBlock);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
        );

}



contract MiniMeTokenFactory {


    function createCloneToken(
        address _parentToken,
        uint _snapshotBlock,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transfersEnabled
    ) returns (MiniMeToken) {

        MiniMeToken newToken = new MiniMeToken(
            this,
            _parentToken,
            _snapshotBlock,
            _tokenName,
            _decimalUnits,
            _tokenSymbol,
            _transfersEnabled
            );

        newToken.changeController(msg.sender);
        return newToken;
    }
}


contract Owned {

    modifier onlyOwner { if (msg.sender != owner) throw; _; }


    address public owner;

    function Owned() { owner = msg.sender;}


    function changeOwner(address _newOwner) onlyOwner {

        owner = _newOwner;
    }
}



contract Campaign is TokenController, Owned {


    uint public startFundingTime;       // In UNIX Time Format
    uint public endFundingTime;         // In UNIX Time Format
    uint public maximumFunding;         // In wei
    uint public totalCollected;         // In wei
    MiniMeToken public tokenContract;   // The new token for this Campaign
    address public vaultAddress;        // The address to hold the funds donated


    function Campaign(
        uint _startFundingTime,
        uint _endFundingTime,
        uint _maximumFunding,
        address _vaultAddress,
        address _tokenAddress

    ) {

        if ((_endFundingTime < now) ||                // Cannot end in the past
            (_endFundingTime <= _startFundingTime) ||
            (_maximumFunding > 10000 ether) ||        // The Beta is limited
            (_vaultAddress == 0))                     // To prevent burning ETH
            {
            throw;
            }
        startFundingTime = _startFundingTime;
        endFundingTime = _endFundingTime;
        maximumFunding = _maximumFunding;
        tokenContract = MiniMeToken(_tokenAddress);// The Deployed Token Contract
        vaultAddress = _vaultAddress;
    }


    function ()  payable {
        doPayment(msg.sender);
    }



    function proxyPayment(address _owner) payable returns(bool) {

        doPayment(_owner);
        return true;
    }

    function onTransfer(address _from, address _to, uint _amount) returns(bool) {

        return true;
    }

    function onApprove(address _owner, address _spender, uint _amount)
        returns(bool)
    {

        return true;
    }



    function doPayment(address _owner) internal {


        if ((now<startFundingTime) ||
            (now>endFundingTime) ||
            (tokenContract.controller() == 0) ||           // Extra check
            (msg.value == 0) ||
            (totalCollected + msg.value > maximumFunding))
        {
            throw;
        }

        totalCollected += msg.value;

        if (!vaultAddress.send(msg.value)) {
            throw;
        }

        if (!tokenContract.generateTokens(_owner, msg.value)) {
            throw;
        }

        return;
    }


    function finalizeFunding() {

        if (now < endFundingTime) throw;
        tokenContract.changeController(0);
    }


    function setVault(address _newVaultAddress) onlyOwner {

        vaultAddress = _newVaultAddress;
    }

}