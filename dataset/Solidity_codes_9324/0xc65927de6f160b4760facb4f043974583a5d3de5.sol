
pragma solidity ^0.4.21;

library Maths {

  function plus(
    uint256 addendA,
    uint256 addendB
  ) public pure returns (uint256 sum) {

    sum = addendA + addendB;
    assert(sum - addendB == addendA);
    return sum;
  }

  function minus(
    uint256 minuend,
    uint256 subtrahend
  ) public pure returns (uint256 difference) {

    assert(minuend >= subtrahend);
    difference = minuend - subtrahend;
    return difference;
  }

  function mul(
    uint256 factorA,
    uint256 factorB
  ) public pure returns (uint256 product) {

    if (factorA == 0 || factorB == 0) return 0;
    product = factorA * factorB;
    assert(product / factorA == factorB);
    return product;
  }

  function times(
    uint256 factorA,
    uint256 factorB
  ) public pure returns (uint256 product) {

    return mul(factorA, factorB);
  }

  function div(
    uint256 dividend,
    uint256 divisor
  ) public pure returns (uint256 quotient) {

    quotient = dividend / divisor;
    assert(quotient * divisor == dividend);
    return quotient;
  }

  function dividedBy(
    uint256 dividend,
    uint256 divisor
  ) public pure returns (uint256 quotient) {

    return div(dividend, divisor);
  }

  function divideSafely(
    uint256 dividend,
    uint256 divisor
  ) public pure returns (uint256 quotient, uint256 remainder) {

    quotient = div(dividend, divisor);
    remainder = dividend % divisor;
  }

  function min(
    uint256 a,
    uint256 b
  ) public pure returns (uint256 result) {

    result = a <= b ? a : b;
    return result;
  }

  function max(
    uint256 a,
    uint256 b
  ) public pure returns (uint256 result) {

    result = a >= b ? a : b;
    return result;
  }

  function isLessThan(uint256 a, uint256 b) public pure returns (bool isTrue) {

    isTrue = a < b;
    return isTrue;
  }

  function isAtMost(uint256 a, uint256 b) public pure returns (bool isTrue) {

    isTrue = a <= b;
    return isTrue;
  }

  function isGreaterThan(uint256 a, uint256 b) public pure returns (bool isTrue) {

    isTrue = a > b;
    return isTrue;
  }

  function isAtLeast(uint256 a, uint256 b) public pure returns (bool isTrue) {

    isTrue = a >= b;
    return isTrue;
  }
}