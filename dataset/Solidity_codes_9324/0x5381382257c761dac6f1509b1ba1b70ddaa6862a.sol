

pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

interface ICurve {

    function get_dy_underlying(int128 i, int128 j, uint256 dx) external view returns(uint256 dy);


    function get_dy(int128 i, int128 j, uint256 dx) external view returns(uint256 dy);


    function exchange_underlying(int128 i, int128 j, uint256 dx, uint256 minDy) external;


    function exchange(int128 i, int128 j, uint256 dx, uint256 minDy) external;


    function underlying_coins(int128 arg0) external view returns(address out);

    function coins(int128 arg0) external view returns(address out);


}







contract CurveSampler {

   
    function sampleFromCurve(
        address curveAddress,
        int128 fromTokenIdx,
        int128 toTokenIdx,
        uint256[] memory takerTokenAmounts
    )
        public
        view
        returns (uint256[] memory makerTokenAmounts)
    {

        uint256 numSamples = takerTokenAmounts.length;
        makerTokenAmounts = new uint256[](numSamples);
        for (uint256 i = 0; i < numSamples; i++) {
            uint256 buyAmount = ICurve(curveAddress).get_dy_underlying(fromTokenIdx, toTokenIdx, takerTokenAmounts[i]);
            makerTokenAmounts[i] = buyAmount;
            if (makerTokenAmounts[i] == 0) {
                break;
            }
        }

        return makerTokenAmounts;
    }

    
}