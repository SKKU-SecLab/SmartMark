pragma solidity 0.8.9;

interface ICurveSlave {

  function valueAt(int256 x_value) external view returns (int256);

}// MIT
pragma solidity 0.8.9;


contract ThreeLines0_100 is ICurveSlave {

  int256 public _r0;
  int256 public _r1;
  int256 public _r2;
  int256 public _s1;
  int256 public _s2;

  constructor(
    int256 r0,
    int256 r1,
    int256 r2,
    int256 s1,
    int256 s2
  ) {

    require((0 < r2) && (r2 < r1) && ( r1 < r0), "Invalid curve");
    require((0 < s1) && (s1 < s2) && (s2 < 1e18), "Invalid breakpoint values");

    _r0 = r0;
    _r1 = r1;
    _r2 = r2;
    _s1 = s1;
    _s2 = s2;
  }

  function valueAt(int256 x_value) external view override returns (int256) {

    require(x_value >= 0, "too small");
    if (x_value > 1e18) {
      x_value = 1e18;
    }
    if (x_value < _s1) {
      int256 rise = _r1 - _r0;
      int256 run = _s1;
      return linearInterpolation(rise, run, x_value, _r0);
    }
    if (x_value < _s2) {
      int256 rise = _r2 - _r1;
      int256 run = _s2 - _s1;
      return linearInterpolation(rise, run, x_value - _s1, _r1);
    }
    return _r2;
  }

  function linearInterpolation(
    int256 rise,
    int256 run,
    int256 distance,
    int256 b
  ) private pure returns (int256) {

    int256 mE6 = (rise * 1e6) / run;
    int256 result = (mE6 * distance) / 1e6 + b;
    return result;
  }
}
