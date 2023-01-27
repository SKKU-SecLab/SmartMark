
pragma solidity ^0.5.12;

contract IBasePool {

    function totalBalanceOf(address _addr) external view returns (uint256);

    function sponsorshipAndFeeBalanceOf(address _sender) external view returns (uint256);

    function withdrawSponsorshipAndFee(uint256 _amount) external;

    function openBalanceOf(address _addr) external view returns (uint256);

    function withdrawOpenDeposit(uint256 _amount) external;

    function withdrawCommittedDeposit(uint256 _amount) external returns (bool);

}

contract PoolTogetherWithdrawer {

    function withdraw(IBasePool _pool, uint256 _amount) external {

        require(_amount > 0 && _amount <= _pool.totalBalanceOf(msg.sender), "Bad amount");
        uint256 toWithdraw = _amount;

        uint256 sponsorshipAndFeeBalance = _pool.sponsorshipAndFeeBalanceOf(msg.sender);
        if(sponsorshipAndFeeBalance > 0) {
            uint256 withdrawnFromSponsorshipAndFeeBalance = toWithdraw >= sponsorshipAndFeeBalance ? sponsorshipAndFeeBalance : toWithdraw;
            _pool.withdrawSponsorshipAndFee(withdrawnFromSponsorshipAndFeeBalance);
            toWithdraw -= withdrawnFromSponsorshipAndFeeBalance;
            if(toWithdraw == 0) return;
        }

        uint256 openBalance = _pool.openBalanceOf(msg.sender);
        if(openBalance > 0) {
            uint256 withdrawnFromOpenBalance = toWithdraw >= openBalance ? openBalance : toWithdraw;
            _pool.withdrawOpenDeposit(withdrawnFromOpenBalance);
            toWithdraw -= withdrawnFromOpenBalance;
        }

        if(toWithdraw > 0) _pool.withdrawCommittedDeposit(toWithdraw);
    }
}