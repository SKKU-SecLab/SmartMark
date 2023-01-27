

pragma solidity ^0.6.0;

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


pragma solidity >=0.6.0;


interface IConverterAnchor {


}

interface ILiquidityProtection {

    function addLiquidity(
        IConverterAnchor _poolAnchor,
        IERC20 _reserveToken,
        uint256 _amount
    ) external payable returns(uint);


    function removeLiquidity(uint256 _id, uint32 _portion) external;


    function removeLiquidityReturn(
        uint256 _id,
        uint32 _portion,
        uint256 _removeTimestamp
    ) external view returns (uint256, uint256, uint256);


    function claimBalance(uint256 _startIndex, uint256 _endIndex) external;

}


pragma solidity >=0.6.0;

interface IDSToken {


}

interface IStakingRewards {

    function claimRewards() external returns (uint256);

    function pendingRewards(address provider) external view returns (uint256);

    function stakeRewards(uint256 maxAmount, IDSToken poolToken) external returns (uint256, uint256);

}


pragma solidity >=0.6.0;

interface IContractRegistry {

    function addressOf(bytes32 contractName) external view returns(address);

}


pragma solidity 0.6.2;

interface IxBNT {

    function getProxyAddressDepositIds(address proxyAddress) external view returns(uint256[] memory);

}


pragma solidity 0.6.2;





contract LiquidityProvider {

    bool private initialized;

    IContractRegistry private contractRegistry;
    IERC20 private bnt;
    IERC20 private vbnt;

    address private xbnt;
    uint256 public nextDepositIndexToClaimBalance;

    function initializeAndAddLiquidity(
        IContractRegistry _contractRegistry,
        address _xbnt,
        IERC20 _bnt,
        IERC20 _vbnt,
        address _poolToken,
        uint256 _amount
    ) external returns(uint256) {

        require(msg.sender == _xbnt, "Invalid caller");
        require(!initialized, "Already initialized");
        initialized = true;

        contractRegistry = _contractRegistry;
        xbnt = _xbnt;
        bnt = _bnt;
        vbnt = _vbnt;

        return _addLiquidity(_poolToken, _amount);
    }

    function _addLiquidity(
        address _poolToken,
        uint256 _amount
    ) private returns(uint256 id) {

        ILiquidityProtection lp = getLiquidityProtectionContract();
        bnt.approve(address(lp), uint(-1));

        id = lp.addLiquidity(IConverterAnchor(_poolToken), bnt, _amount);

        _retrieveVbntBalance();
    }

    function claimAndRestake(address _poolToken) external onlyXbntContract returns(uint256 newDepositId, uint256 restakedBal){

        (, newDepositId) = getStakingRewardsContract().stakeRewards(uint(-1), IDSToken(_poolToken));
        restakedBal = _retrieveVbntBalance();
    }

    function claimRewards() external onlyXbntContract returns(uint256 rewardsAmount){

        rewardsAmount = _claimRewards();
    }

    function _claimRewards() private returns(uint256 rewards){

        rewards = getStakingRewardsContract().claimRewards();
        _retrieveBntBalance();
    }

    function _removeLiquidity(ILiquidityProtection _lp, uint256 _id) private {

        _lp.removeLiquidity(_id, 1000000); // full PPM resolution
    }

    function claimRewardsAndRemoveLiquidity() external onlyXbntContract returns(uint256 rewards) {

        rewards = _claimRewards();
        uint256[] memory depositIds = getDepositIds();

        ILiquidityProtection lp = getLiquidityProtectionContract();
        vbnt.approve(address(lp), uint(-1));

        for(uint256 i = 0; i < depositIds.length; i++){
            _removeLiquidity(lp, depositIds[i]);
        }
    }

    function claimBalance() external onlyXbntContract {

        getLiquidityProtectionContract().claimBalance(0, getDepositIds().length);
        _retrieveBntBalance();
    }

    function _retrieveBntBalance() private {

        bnt.transfer(xbnt, bnt.balanceOf(address(this)));
    }

    function _retrieveVbntBalance() private returns(uint256 vbntBal) {

        vbntBal = vbnt.balanceOf(address(this));
        vbnt.transfer(xbnt, vbntBal);
    }

    function pendingRewards() external view returns(uint){

        return getStakingRewardsContract().pendingRewards(address(this));
    }

    function getStakingRewardsContract() private view returns(IStakingRewards){

        return IStakingRewards(contractRegistry.addressOf("StakingRewards"));
    }

    function getLiquidityProtectionContract() private view returns(ILiquidityProtection){

        return ILiquidityProtection(contractRegistry.addressOf("LiquidityProtection"));
    }

    function getDepositIds() private view returns(uint256[] memory){

        return IxBNT(xbnt).getProxyAddressDepositIds(address(this));
    }

    modifier onlyXbntContract {

        require(msg.sender == xbnt, "Invalid caller");
        _;
    }
}