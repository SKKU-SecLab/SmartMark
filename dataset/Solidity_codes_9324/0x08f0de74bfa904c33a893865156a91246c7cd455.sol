

pragma solidity 0.6.12;




interface IERC20 {

    function decimals() external view returns (uint);

}



interface IKeep3rV1Oracle {

  function sample(address tokenIn, uint amountIn, address tokenOut, uint points, uint window) external view returns (uint[] memory);

}


contract Keep3rV1OracleMetrics {


  uint private constant FIXED_1 = 0x080000000000000000000000000000000;
  uint private constant FIXED_2 = 0x100000000000000000000000000000000;
  uint private constant SQRT_1 = 13043817825332782212;
  uint private constant LNX = 3988425491;
  uint private constant LOG_10_2 = 3010299957;
  uint private constant LOG_E_2 = 6931471806;
  uint private constant BASE = 1e10;

  uint public constant periodSize = 1800;

  IKeep3rV1Oracle public constant KV1O = IKeep3rV1Oracle(0xf67Ab1c914deE06Ba0F264031885Ea7B276a7cDa); // SushiswapV1Oracle

  function floorLog2(uint256 _n) public pure returns (uint8) {

      uint8 res = 0;

      if (_n < 256) {
          while (_n > 1) {
              _n >>= 1;
              res += 1;
          }
      } else {
          for (uint8 s = 128; s > 0; s >>= 1) {
              if (_n >= (uint(1) << s)) {
                  _n >>= s;
                  res |= s;
              }
          }
      }

      return res;
  }

  function ln(uint256 x) public pure returns (uint) {

      uint res = 0;

      if (x >= FIXED_2) {
          uint8 count = floorLog2(x / FIXED_1);
          x >>= count; // now x < 2
          res = count * FIXED_1;
      }

      if (x > FIXED_1) {
          for (uint8 i = 127; i > 0; --i) {
              x = (x * x) / FIXED_1; // now 1 < x < 4
              if (x >= FIXED_2) {
                  x >>= 1; // now 1 < x < 2
                  res += uint(1) << (i - 1);
              }
          }
      }

      return res * LOG_E_2 / BASE;
  }

  function optimalExp(uint256 x) public pure returns (uint256) {

      uint256 res = 0;

      uint256 y;
      uint256 z;

      z = y = x % 0x10000000000000000000000000000000; // get the input modulo 2^(-3)
      z = (z * y) / FIXED_1;
      res += z * 0x10e1b3be415a0000; // add y^02 * (20! / 02!)
      z = (z * y) / FIXED_1;
      res += z * 0x05a0913f6b1e0000; // add y^03 * (20! / 03!)
      z = (z * y) / FIXED_1;
      res += z * 0x0168244fdac78000; // add y^04 * (20! / 04!)
      z = (z * y) / FIXED_1;
      res += z * 0x004807432bc18000; // add y^05 * (20! / 05!)
      z = (z * y) / FIXED_1;
      res += z * 0x000c0135dca04000; // add y^06 * (20! / 06!)
      z = (z * y) / FIXED_1;
      res += z * 0x0001b707b1cdc000; // add y^07 * (20! / 07!)
      z = (z * y) / FIXED_1;
      res += z * 0x000036e0f639b800; // add y^08 * (20! / 08!)
      z = (z * y) / FIXED_1;
      res += z * 0x00000618fee9f800; // add y^09 * (20! / 09!)
      z = (z * y) / FIXED_1;
      res += z * 0x0000009c197dcc00; // add y^10 * (20! / 10!)
      z = (z * y) / FIXED_1;
      res += z * 0x0000000e30dce400; // add y^11 * (20! / 11!)
      z = (z * y) / FIXED_1;
      res += z * 0x000000012ebd1300; // add y^12 * (20! / 12!)
      z = (z * y) / FIXED_1;
      res += z * 0x0000000017499f00; // add y^13 * (20! / 13!)
      z = (z * y) / FIXED_1;
      res += z * 0x0000000001a9d480; // add y^14 * (20! / 14!)
      z = (z * y) / FIXED_1;
      res += z * 0x00000000001c6380; // add y^15 * (20! / 15!)
      z = (z * y) / FIXED_1;
      res += z * 0x000000000001c638; // add y^16 * (20! / 16!)
      z = (z * y) / FIXED_1;
      res += z * 0x0000000000001ab8; // add y^17 * (20! / 17!)
      z = (z * y) / FIXED_1;
      res += z * 0x000000000000017c; // add y^18 * (20! / 18!)
      z = (z * y) / FIXED_1;
      res += z * 0x0000000000000014; // add y^19 * (20! / 19!)
      z = (z * y) / FIXED_1;
      res += z * 0x0000000000000001; // add y^20 * (20! / 20!)
      res = res / 0x21c3677c82b40000 + y + FIXED_1; // divide by 20! and then add y^1 / 1! + y^0 / 0!

      if ((x & 0x010000000000000000000000000000000) != 0)
          res = (res * 0x1c3d6a24ed82218787d624d3e5eba95f9) / 0x18ebef9eac820ae8682b9793ac6d1e776; // multiply by e^2^(-3)
      if ((x & 0x020000000000000000000000000000000) != 0)
          res = (res * 0x18ebef9eac820ae8682b9793ac6d1e778) / 0x1368b2fc6f9609fe7aceb46aa619baed4; // multiply by e^2^(-2)
      if ((x & 0x040000000000000000000000000000000) != 0)
          res = (res * 0x1368b2fc6f9609fe7aceb46aa619baed5) / 0x0bc5ab1b16779be3575bd8f0520a9f21f; // multiply by e^2^(-1)
      if ((x & 0x080000000000000000000000000000000) != 0)
          res = (res * 0x0bc5ab1b16779be3575bd8f0520a9f21e) / 0x0454aaa8efe072e7f6ddbab84b40a55c9; // multiply by e^2^(+0)
      if ((x & 0x100000000000000000000000000000000) != 0)
          res = (res * 0x0454aaa8efe072e7f6ddbab84b40a55c5) / 0x00960aadc109e7a3bf4578099615711ea; // multiply by e^2^(+1)
      if ((x & 0x200000000000000000000000000000000) != 0)
          res = (res * 0x00960aadc109e7a3bf4578099615711d7) / 0x0002bf84208204f5977f9a8cf01fdce3d; // multiply by e^2^(+2)
      if ((x & 0x400000000000000000000000000000000) != 0)
          res = (res * 0x0002bf84208204f5977f9a8cf01fdc307) / 0x0000003c6ab775dd0b95b4cbee7e65d11; // multiply by e^2^(+3)

      return res;
  }

  function sqrt(uint x) public pure returns (uint y) {

      uint z = (x + 1) / 2;
      y = x;
      while (z < y) {
          y = z;
          z = (x / z + z) / 2;
      }
  }

  function mu(address tokenIn, address tokenOut, uint points, uint window) public view returns (uint m) {

    uint[] memory p = KV1O.sample(tokenIn, uint(10)**IERC20(tokenIn).decimals(), tokenOut, points, window);
    for (uint8 i = 1; i <= (p.length - 1); i++) {
      m += (ln(p[i] * FIXED_1) - ln(p[i-1] * FIXED_1));
    }
    return m / (periodSize * (p.length - 1));
  }

  function sigSqrd(address tokenIn, address tokenOut, uint points, uint window) public view returns (uint ss) {

    uint[] memory p = KV1O.sample(tokenIn, uint(10)**IERC20(tokenIn).decimals(), tokenOut, points, window);

    uint m = mu(tokenIn, tokenOut, points, window);
    m = m * periodSize;
    for (uint8 i = 1; i <= (p.length - 1); i++) {
      ss += ((ln(p[i] * FIXED_1) - ln(p[i-1] * FIXED_1)) - m)**2; // FIXED_1 needed?
    }
    return ss / (periodSize * (p.length - 1));
  }

  function sig(address tokenIn, address tokenOut, uint points, uint window) external view returns (uint) {

    return sqrt(sigSqrd(tokenIn, tokenOut, points, window));
  }

  function rMu(address tokenIn, address tokenOut, uint points, uint window, uint8 r) public view returns (uint[] memory) {

    uint[] memory _mus = new uint[](r);

    uint allPoints = points * uint(r);
    uint[] memory p = KV1O.sample(tokenIn, uint(10)**IERC20(tokenIn).decimals(), tokenOut, allPoints, window);

    uint m = 0;
    uint index = 0;
    for (uint8 i = 1; i <= (p.length - 1); i++) {
      m += (ln(p[i] * FIXED_1) - ln(p[i-1] * FIXED_1));
      if (i % (points * window) == 0) {
        _mus[index] = (m / (periodSize * (p.length - 1)));
        m = 0;
        index += 1;
      }
    }
    return _mus;
  }

  function rSigSqrd(address tokenIn, address tokenOut, uint points, uint window, uint8 r) external view returns (uint[] memory) {

    uint[] memory _mus = rMu(tokenIn, tokenOut, points, window, r);
    uint[] memory _sigs = new uint[](r);

    uint allPoints = points * uint(r);
    uint[] memory p = KV1O.sample(tokenIn, uint(10)**IERC20(tokenIn).decimals(), tokenOut, allPoints, window);

    uint ss = 0;
    uint index = 0;
    for (uint8 i = 1; i <= (p.length - 1); i++) {
      ss += ((ln(p[i] * FIXED_1) - ln(p[i-1] * FIXED_1)) - _mus[index]*periodSize)**2;
      if (i % (points * window) == 0) {
        _sigs[index] = (ss / (periodSize * (p.length - 1)));
        ss = 0;
        index += 1;
      }
    }

    return _sigs;
  }
}