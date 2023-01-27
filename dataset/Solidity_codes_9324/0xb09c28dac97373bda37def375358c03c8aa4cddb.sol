pragma solidity ^0.8.0;

library SvgElement {

  struct Rect {
    string class;
    string x;
    string y;
    string width;
    string height;
    string opacity;
    string fill;
    string filter;
  }

  function getRect(Rect memory rect) public pure returns (string memory) {

    string memory element = '<rect ';
    element = !equal(rect.class, '') ? string(abi.encodePacked(element, 'class="', rect.class, '" ')) : element;
    element = !equal(rect.x, '') ? string(abi.encodePacked(element, 'x="', rect.x, '" ')) : element;
    element = !equal(rect.y, '') ? string(abi.encodePacked(element, 'y="', rect.y, '" ')) : element;
    element = !equal(rect.width, '') ? string(abi.encodePacked(element, 'width="', rect.width, '" ')) : element;
    element = !equal(rect.height, '') ? string(abi.encodePacked(element, 'height="', rect.height, '" ')) : element;
    element = !equal(rect.opacity, '') ? string(abi.encodePacked(element, 'opacity="', rect.opacity, '" ')) : element;
    element = !equal(rect.fill, '') ? string(abi.encodePacked(element, 'fill="url(#', rect.fill, ')" ')) : element;
    element = !equal(rect.filter, '') ? string(abi.encodePacked(element, 'filter="url(#', rect.filter, ')" ')) : element;
    element = string(abi.encodePacked(element, '/>'));
    return element;
  }

  struct Circle {
    string class;
    string cx;
    string cy;
    string r;
    string opacity;
  }

  function getCircle(Circle memory circle) public pure returns (string memory) {

    string memory element = '<circle ';
    element = !equal(circle.class, '') ? string(abi.encodePacked(element, 'class="', circle.class, '" ')) : element;
    element = !equal(circle.cx, '') ? string(abi.encodePacked(element, 'cx="', circle.cx, '" ')) : element;
    element = !equal(circle.cy, '') ? string(abi.encodePacked(element, 'cy="', circle.cy, '" ')) : element;
    element = !equal(circle.r, '') ? string(abi.encodePacked(element, 'r="', circle.r, '" ')) : element;
    element = !equal(circle.opacity, '') ? string(abi.encodePacked(element, 'opacity="', circle.opacity, '" ')) : element;
    element = string(abi.encodePacked(element, '/>'));
    return element;
  }

  struct Text {
    string class;
    string x;
    string y;
    string dx;
    string dy;
    string display;
    string baseline;
    string anchor;
    string rotate;
    string transform;
    string clipPath;
    string val;
  }

  function getText(Text memory txt) public pure returns (string memory) {

    string memory element = '<text ';
    element = !equal(txt.class, '') ? string(abi.encodePacked(element, 'class="', txt.class, '" ')) : element;
    element = !equal(txt.x, '') ? string(abi.encodePacked(element, 'x="', txt.x, '" ')) : element;
    element = !equal(txt.y, '') ? string(abi.encodePacked(element, 'y="', txt.y, '" ')) : element;
    element = !equal(txt.dx, '') ? string(abi.encodePacked(element, 'dx="', txt.dx, '" ')) : element;
    element = !equal(txt.dy, '') ? string(abi.encodePacked(element, 'dy="', txt.dy, '" ')) : element;
    element = !equal(txt.display, '') ? string(abi.encodePacked(element, 'display="', txt.display, '" ')) : element;
    element = !equal(txt.baseline, '') ? string(abi.encodePacked(element, 'dominant-baseline="', txt.baseline, '" ')) : element;
    element = !equal(txt.anchor, '') ? string(abi.encodePacked(element, 'text-anchor="', txt.anchor, '" ')) : element;
    element = !equal(txt.rotate, '') ? string(abi.encodePacked(element, 'rotate="', txt.rotate, '" ')) : element;
    element = !equal(txt.transform, '') ? string(abi.encodePacked(element, 'transform="', txt.transform, '" ')) : element;
    element = !equal(txt.clipPath, '') ? string(abi.encodePacked(element, 'clip-path="url(#', txt.clipPath, ')" ')) : element;
    element = string(abi.encodePacked(element, '>', txt.val, '</text>'));
    return element;
  }

  struct TextPath {
    string class;
    string href;
    string val;
  }

  function getTextPath(TextPath memory txtPath) public pure returns (string memory) {

    string memory element = '<textPath ';
    element = !equal(txtPath.class, '') ? string(abi.encodePacked(element, 'class="', txtPath.class, '" ')) : element;
    element = !equal(txtPath.class, '') ? string(abi.encodePacked(element, 'href="#', txtPath.href, '" ')) : element;
    element = string(abi.encodePacked(element, '>', txtPath.val, '</textPath>'));
    return element;
  }

  struct Tspan {
    string class;
    string display;
    string dx;
    string dy;
    string val;
  }

  function getTspan(Tspan memory tspan) public pure returns (string memory) {

    string memory element = '<tspan ';
    element = !equal(tspan.class, '') ? string(abi.encodePacked(element, 'class="', tspan.class, '" ')) : element;
    element = !equal(tspan.display, '') ? string(abi.encodePacked(element, 'display="', tspan.display, '" ')) : element;
    element = !equal(tspan.dx, '') ? string(abi.encodePacked(element, 'dx="', tspan.dx, '" ')) : element;
    element = !equal(tspan.dy, '') ? string(abi.encodePacked(element, 'dy="', tspan.dy, '" ')) : element;
    element = string(abi.encodePacked(element, '>', tspan.val, '</tspan>'));
    return element;
  }

  struct Animate {
    string attributeName;
    string to;
    string values;
    string duration;
    string begin;
    string repeatCount;
    string fill;
  }

  function getAnimate(Animate memory animate) public pure returns (string memory) {

    string memory element = '<animate ';
    element = !equal(animate.attributeName, '') ? string(abi.encodePacked(element, 'attributeName="', animate.attributeName, '" ')) : element;
    element = !equal(animate.to, '') ? string(abi.encodePacked(element, 'to="', animate.to, '" ')) : element;
    element = !equal(animate.values, '') ? string(abi.encodePacked(element, 'values="', animate.values, '" ')) : element;
    element = !equal(animate.duration, '') ? string(abi.encodePacked(element, 'dur="', animate.duration, 'ms" ')) : element;
    element = !equal(animate.begin, '') ? string(abi.encodePacked(element, 'begin="', animate.begin, 'ms" ')) : element;
    element = !equal(animate.repeatCount, '') ? string(abi.encodePacked(element, 'repeatCount="', animate.repeatCount, '" ')) : element;
    element = !equal(animate.fill, '') ? string(abi.encodePacked(element, 'fill="', animate.fill, '" ')) : element;
    element = string(abi.encodePacked(element, '/>'));
    return element;
  }

  struct Path {
    string id;
    string pathAttr;
    string val;
  }

  function getPath(Path memory path) public pure returns (string memory) {

    string memory element = '<path ';
    element = !equal(path.id, '') ? string(abi.encodePacked(element, 'id="', path.id, '" ')) : element;
    element = !equal(path.pathAttr, '') ? string(abi.encodePacked(element, 'd="', path.pathAttr, '" ')) : element;
    element = string(abi.encodePacked(element, '>', path.val, '</path>'));
    return element;
  }

  struct Group {
    string transform;
    string val;
  }

  function getGroup(Group memory group) public pure returns (string memory) {

    string memory element = '<g ';
    element = !equal(group.transform, '') ? string(abi.encodePacked(element, 'transform="', group.transform, '" ')) : element;
    element = string(abi.encodePacked(element, '>', group.val, '</g>'));
    return element;
  }

  struct Pattern {
    string id;
    string x;
    string y;
    string width;
    string height;
    string patternUnits;
    string val;
  }

  function getPattern(Pattern memory pattern) public pure returns (string memory) {

    string memory element = '<pattern ';
    element = !equal(pattern.id, '') ? string(abi.encodePacked(element, 'id="', pattern.id, '" ')) : element;
    element = !equal(pattern.x, '') ? string(abi.encodePacked(element, 'x="', pattern.x, '" ')) : element;
    element = !equal(pattern.y, '') ? string(abi.encodePacked(element, 'y="', pattern.y, '" ')) : element;
    element = !equal(pattern.width, '') ? string(abi.encodePacked(element, 'width="', pattern.width, '" ')) : element;
    element = !equal(pattern.height, '') ? string(abi.encodePacked(element, 'height="', pattern.height, '" ')) : element;
    element = !equal(pattern.patternUnits, '') ? string(abi.encodePacked(element, 'patternUnits="', pattern.patternUnits, '" ')) : element;
    element = string(abi.encodePacked(element, '>', pattern.val, '</pattern>'));
    return element;
  }

  struct Filter {
    string id;
    string val;
  }

  function getFilter(Filter memory filter) public pure returns (string memory) {

    string memory element = '<filter ';
    element = !equal(filter.id, '') ? string(abi.encodePacked(element, 'id="', filter.id, '" ')) : element;
    element = string(abi.encodePacked(element, '>', filter.val, '</filter>'));
    return element;
  }

  struct Turbulance {
    string fType;
    string baseFrequency;
    string octaves;
    string result;
    string val;
  }

  function getTurbulance(Turbulance memory turbulance) public pure returns (string memory) {

    string memory element = '<feTurbulence ';
    element = !equal(turbulance.fType, '') ? string(abi.encodePacked(element, 'type="', turbulance.fType, '" ')) : element;
    element = !equal(turbulance.baseFrequency, '') ? string(abi.encodePacked(element, 'baseFrequency="', turbulance.baseFrequency, '" ')) : element;
    element = !equal(turbulance.octaves, '') ? string(abi.encodePacked(element, 'numOctaves="', turbulance.octaves, '" ')) : element;
    element = !equal(turbulance.result, '') ? string(abi.encodePacked(element, 'result="', turbulance.result, '" ')) : element;
    element = string(abi.encodePacked(element, '>', turbulance.val, '</feTurbulence>'));
    return element;
  }

  struct DisplacementMap {
    string mIn;
    string in2;
    string result;
    string scale;
    string xChannelSelector;
    string yChannelSelector;
    string val;
  }

  function getDisplacementMap(DisplacementMap memory displacementMap) public pure returns (string memory) {

    string memory element = '<feDisplacementMap ';
    element = !equal(displacementMap.mIn, '') ? string(abi.encodePacked(element, 'in="', displacementMap.mIn, '" ')) : element;
    element = !equal(displacementMap.in2, '') ? string(abi.encodePacked(element, 'in2="', displacementMap.in2, '" ')) : element;
    element = !equal(displacementMap.result, '') ? string(abi.encodePacked(element, 'result="', displacementMap.result, '" ')) : element;
    element = !equal(displacementMap.scale, '') ? string(abi.encodePacked(element, 'scale="', displacementMap.scale, '" ')) : element;
    element = !equal(displacementMap.xChannelSelector, '') ? string(abi.encodePacked(element, 'xChannelSelector="', displacementMap.xChannelSelector, '" ')) : element;
    element = !equal(displacementMap.yChannelSelector, '') ? string(abi.encodePacked(element, 'yChannelSelector="', displacementMap.yChannelSelector, '" ')) : element;
    element = string(abi.encodePacked(element, '>', displacementMap.val, '</feDisplacementMap>'));
    return element;
  }

  struct ClipPath {
    string id;
    string val;
  }

  function getClipPath(ClipPath memory clipPath) public pure returns (string memory) {

    string memory element = '<clipPath ';
    element = !equal(clipPath.id, '') ? string(abi.encodePacked(element, 'id="', clipPath.id, '" ')) : element;
    element = string(abi.encodePacked(element, ' >', clipPath.val, '</clipPath>'));
    return element;
  }

  struct LinearGradient {
    string id;
    string[] colors;
    bool blockScheme;
    string animate;
  }

  function getLinearGradient(LinearGradient memory linearGradient) public pure returns (string memory) {

    string memory element = '<linearGradient ';
    element = !equal(linearGradient.id, '') ? string(abi.encodePacked(element, 'id="', linearGradient.id, '">')) : element;
    uint baseOffset = 100 / (linearGradient.colors.length - 1);
    for (uint i=0; i<linearGradient.colors.length; i++) {
      uint offset;
      if (i != linearGradient.colors.length - 1) {
        offset = baseOffset * i;
      } else {
        offset = 100;
      }
      if (linearGradient.blockScheme && i != 0) {
        element = string(abi.encodePacked(element, '<stop offset="', toString(offset), '%"  stop-color="', linearGradient.colors[i-1], '" />'));
      }

      if (!linearGradient.blockScheme || (linearGradient.blockScheme && i != linearGradient.colors.length - 1)) {
        element = string(abi.encodePacked(element, '<stop offset="', toString(offset), '%"  stop-color="', linearGradient.colors[i], '" />'));
      }
    }
    element = !equal(linearGradient.animate, '') ? string(abi.encodePacked(element, linearGradient.animate)) : element;
    element =  string(abi.encodePacked(element, '</linearGradient>'));
    return element;
  }

  struct RadialGradient {
    string id;
    string[] colors;
    bool blockScheme;
    string animate;
  }

  function getRadialGradient(RadialGradient memory radialGradient) public pure returns (string memory) {

    string memory element = '<radialGradient ';
    element = !equal(radialGradient.id, '') ? string(abi.encodePacked(element, 'id="', radialGradient.id, '">')) : element;
    uint baseOffset = 100 / (radialGradient.colors.length - 1);
    for (uint i=0; i<radialGradient.colors.length; i++) {
      uint offset;
      if (i != radialGradient.colors.length - 1) {
        offset = baseOffset * i;
      } else {
        offset = 100;
      }
      if (radialGradient.blockScheme && i != 0) {
        element = string(abi.encodePacked(element, '<stop offset="', toString(offset), '%"  stop-color="', radialGradient.colors[i-1], '" />'));
      }

      if (!radialGradient.blockScheme || (radialGradient.blockScheme && i != radialGradient.colors.length - 1)) {
        element = string(abi.encodePacked(element, '<stop offset="', toString(offset), '%"  stop-color="', radialGradient.colors[i], '" />'));
      }
    }
    element = !equal(radialGradient.animate, '') ? string(abi.encodePacked(element, radialGradient.animate)) : element;
    element =  string(abi.encodePacked(element, '</radialGradient>'));
    return element;
  }

  function equal(string memory a, string memory b) private pure returns (bool) {

    return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
  }

  function toString(uint256 value) private pure returns (string memory) {

    if (value == 0) {
        return "0";
    }
    uint256 temp = value;
    uint256 digits;
    while (temp != 0) {
        digits++;
        temp /= 10;
    }
    bytes memory buffer = new bytes(digits);
    while (value != 0) {
        digits -= 1;
        buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
        value /= 10;
    }
    return string(buffer);
  }
}//	MIT
pragma solidity ^0.8.0;


library LogoHelper {

  function getRotate(string memory text) public pure returns (string memory) {

    bytes memory byteString = bytes(text);
    string memory rotate = string(abi.encodePacked('-', toString(random(text) % 10 + 1)));
    for (uint i=1; i < byteString.length; i++) {
      uint nextRotate = random(rotate) % 10 + 1;
      if (i % 2 == 0) {
        rotate = string(abi.encodePacked(rotate, ',-', toString(nextRotate)));
      } else {
        rotate = string(abi.encodePacked(rotate, ',', toString(nextRotate)));
      }
    }
    return rotate;
  }

  function getTurbulance(string memory seed, uint max, uint magnitudeOffset) public pure returns (string memory) {

    string memory turbulance = decimalInRange(seed, max, magnitudeOffset);
    uint rand = randomInRange(turbulance, max, 0);
    return string(abi.encodePacked(turbulance, ', ', getDecimal(rand, magnitudeOffset)));
  }

  function decimalInRange(string memory seed, uint max, uint magnitudeOffset) public pure returns (string memory) {

    uint rand = randomInRange(seed, max, 0);
    return getDecimal(rand, magnitudeOffset);
  }

  function random(string memory input) public pure returns (uint256) {

    return uint256(keccak256(abi.encodePacked(input)));
  }

  function randomFromInt(uint256 seed) internal pure returns (uint256) {

    return uint256(keccak256(abi.encodePacked(seed)));
  }

  function randomInRange(string memory input, uint max, uint offset) public pure returns (uint256) {

    max = max - offset;
    return (random(input) % max) + offset;
  }

  function equal(string memory a, string memory b) public pure returns (bool) {

    return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
  }

  function toString(uint256 value) public pure returns (string memory) {

    if (value == 0) {
        return "0";
    }
    uint256 temp = value;
    uint256 digits;
    while (temp != 0) {
        digits++;
        temp /= 10;
    }
    bytes memory buffer = new bytes(digits);
    while (value != 0) {
        digits -= 1;
        buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
        value /= 10;
    }
    return string(buffer);
  }

  function toString(address x) internal pure returns (string memory) {

    bytes memory s = new bytes(40);
    for (uint i = 0; i < 20; i++) {
      bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
      bytes1 hi = bytes1(uint8(b) / 16);
      bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
      s[2*i] = char(hi);
      s[2*i+1] = char(lo);            
    }
    return string(s);
  }

function char(bytes1 b) internal pure returns (bytes1 c) {

  if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
  else return bytes1(uint8(b) + 0x57);
}
  
  function getDecimal(uint val, uint magnitudeOffset) public pure returns (string memory) {

    string memory decimal;
    if (val != 0) {
      for (uint i = 10; i < magnitudeOffset / val; i=10*i) {
        decimal = string(abi.encodePacked(decimal, '0'));
      }
    }
    decimal = string(abi.encodePacked('0.', decimal, toString(val)));
    return decimal;
  }

  bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

  function encode(bytes memory data) internal pure returns (string memory) {

    uint256 len = data.length;
    if (len == 0) return "";

    uint256 encodedLen = 4 * ((len + 2) / 3);

    bytes memory result = new bytes(encodedLen + 32);

    bytes memory table = TABLE;

    assembly {
      let tablePtr := add(table, 1)
      let resultPtr := add(result, 32)

      for {
        let i := 0
      } lt(i, len) {

      } {
        i := add(i, 3)
        let input := and(mload(add(data, i)), 0xffffff)

        let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
        out := shl(8, out)
        out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
        out := shl(8, out)
        out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
        out := shl(8, out)
        out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
        out := shl(224, out)

        mstore(resultPtr, out)

        resultPtr := add(resultPtr, 4)
      }

      switch mod(len, 3)
      case 1 {
        mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
      }
      case 2 {
        mstore(sub(resultPtr, 1), shl(248, 0x3d))
      }

      mstore(result, encodedLen)
    }
    return string(result);
  }
}//	MIT
pragma solidity ^0.8.0;


library InlineSvgElement {

  function getTspanBytes1(
      string memory class,
      string memory display, 
      string memory dx, 
      string memory dy, 
      bytes1 val)
      public pure 
      returns (string memory) {

    return string(abi.encodePacked('<tspan class="', class, '" display="', display, '" dx="', dx, '" dy="', dy, '" >', val));
  }

  function getAnimate(
      string memory attributeName,
      string memory values,
      string memory duration,
      string memory begin,
      string memory repeatCount,
      string memory fill) 
      public pure 
      returns (string memory) {

    return string(abi.encodePacked('<animate attributeName="', attributeName, '" values="', values, '" dur="', duration, 'ms" begin="', begin, 'ms" repeatCount="', repeatCount, '"  fill="', fill, '" />'));
  }
}//	MIT
pragma solidity ^0.8.0;


library SvgPattern {

  function getADef(string memory seed, string memory backgroundId, string memory fillType, string memory fillZeroClass) public pure returns (string memory) {

    uint patternSize = randomInRange(string(abi.encodePacked(seed, 'a')), 140, 10);
    for (uint i = 0; i < 150; i++) {
      if (300 % (patternSize + i) == 0) {
        patternSize = patternSize + i;
        break;
      } 
    }
    uint squareSize = randomInRange(string(abi.encodePacked(seed, 'b')), LogoHelper.equal(fillType, 'Solid') ? patternSize - (patternSize / 6) : patternSize + (patternSize / 2), patternSize / 6);
    string memory element = SvgElement.getRect(SvgElement.Rect(fillZeroClass, '0', '0', LogoHelper.toString(squareSize), LogoHelper.toString(squareSize), '', '', ''));
    return SvgElement.getPattern(SvgElement.Pattern(backgroundId, '0', '0', LogoHelper.toString(patternSize), LogoHelper.toString(patternSize), 'userSpaceOnUse', element));
  }

  function getBDef(string memory seed, string memory backgroundId, string memory fillZeroClass) public pure returns (string memory) {

    uint patternSize = randomInRange(string(abi.encodePacked(seed, 'a')), 200, 10);
    for (uint i = 0; i < 150; i++) {
      if (300 % (patternSize + i) == 0) {
        patternSize = patternSize + i;
        break;
      }  
    }
    uint circleRadius = randomInRange(string(abi.encodePacked(seed, 'b')), patternSize - (patternSize / 4), patternSize / 12);
    string memory center = LogoHelper.toString(randomInRange(string(abi.encodePacked(seed, 'c')), patternSize, patternSize / 4));
    string memory element = SvgElement.getCircle(SvgElement.Circle(fillZeroClass, center, center, LogoHelper.toString(circleRadius), ''));
    return SvgElement.getPattern(SvgElement.Pattern(backgroundId, '0', '0', LogoHelper.toString(patternSize), LogoHelper.toString(patternSize), 'userSpaceOnUse', element));
  }
  
  function getAX2Def(string memory seed, string memory backgroundId, string memory fillZeroClass, string memory fillType, string memory fillOneClass) public pure returns (string memory) {

    uint patternSize = randomInRange(string(abi.encodePacked(seed, 'a')), 200, 2);
    for (uint i = 0; i < 150; i++) {
      if (300 % (patternSize + i) == 0) {
        patternSize = patternSize + i;
        break;
      } 
    }
    uint squareSize1 = randomInRange(string(abi.encodePacked(seed, 'b')), LogoHelper.equal(fillType, 'Solid') ? patternSize : patternSize + (patternSize / 2), patternSize / 6);
    uint squareSize2 = randomInRange(string(abi.encodePacked(seed, 'c')), LogoHelper.equal(fillType, 'Solid') ? patternSize : patternSize + (patternSize / 2), patternSize / 6);

    uint offset = randomInRange(string(abi.encodePacked(seed, 'd')), patternSize - (squareSize2 / 2) , 0);
    string memory opactiy = LogoHelper.decimalInRange(seed, 8, 10);
    string memory element = SvgElement.getRect(SvgElement.Rect(fillZeroClass, '0', '0', LogoHelper.toString(squareSize1), LogoHelper.toString(squareSize1), '', '', ''));
    element = string(abi.encodePacked(element, SvgElement.getRect(SvgElement.Rect(fillOneClass, LogoHelper.toString(offset), LogoHelper.toString(offset), LogoHelper.toString(squareSize2), LogoHelper.toString(squareSize2), opactiy, '', ''))));
    return SvgElement.getPattern(SvgElement.Pattern(backgroundId, '0', '0', LogoHelper.toString(patternSize), LogoHelper.toString(patternSize), 'userSpaceOnUse', element));
  }

  function getBX2Def(string memory seed, string memory backgroundId, string memory fillZeroClass, string memory fillOneClass) public pure returns (string memory) {

    uint patternSize = randomInRange(string(abi.encodePacked(seed, 'a')), 200, 20);
    for (uint i = 0; i < 150; i++) {
      if (300 % (patternSize + i) == 0) {
        patternSize = patternSize + i;
        break;
      } 
    }
    uint circleRadius = randomInRange(string(abi.encodePacked(seed, 'b')), patternSize - (patternSize / 4), patternSize / 6);

    string memory center = LogoHelper.toString(randomInRange(string(abi.encodePacked(seed, 'c')), patternSize, patternSize / 4));
    string memory element = SvgElement.getCircle(SvgElement.Circle(fillZeroClass, center, center, LogoHelper.toString(circleRadius), ''));

    circleRadius = randomInRange(string(abi.encodePacked(seed, 'e')), patternSize, patternSize / 6);
    center = LogoHelper.toString(randomInRange(string(abi.encodePacked(seed, 'f')), patternSize, patternSize / 4));
    string memory opactiy = LogoHelper.decimalInRange(seed, 8, 10);
    element = string(abi.encodePacked(element, SvgElement.getCircle(SvgElement.Circle(fillOneClass, center, center, LogoHelper.toString(circleRadius), opactiy))));
    return SvgElement.getPattern(SvgElement.Pattern(backgroundId, '0', '0', LogoHelper.toString(patternSize), LogoHelper.toString(patternSize), 'userSpaceOnUse', element));
  }

  function getABDef(string memory seed, string memory backgroundId, string memory fillType, string memory fillZeroClass, string memory fillOneClass) public pure returns (string memory) {

    uint patternSize = randomInRange(string(abi.encodePacked(seed, 'a')), 200, 20);
    for (uint i = 0; i < 150; i++) {
      if ((patternSize + i) % 300 == 0) {
        patternSize = patternSize + i;
        break;
      } 
    }
    uint squareSize1 = randomInRange(string(abi.encodePacked(seed, 'b')), LogoHelper.equal(fillType, 'Solid') ? patternSize : patternSize + (patternSize / 2), patternSize / 6);
    string memory element = SvgElement.getRect(SvgElement.Rect(fillZeroClass, '0', '0', LogoHelper.toString(squareSize1), LogoHelper.toString(squareSize1), '', '', ''));

    uint circleRadius = randomInRange(string(abi.encodePacked(seed, 'b')), patternSize - (patternSize / 4), patternSize / 6);
    string memory center = LogoHelper.toString(randomInRange(string(abi.encodePacked(seed, 'c')), patternSize, patternSize / 4));
    element = string(abi.encodePacked(element, SvgElement.getCircle(SvgElement.Circle(fillOneClass, center, center, LogoHelper.toString(circleRadius), ''))));
    return SvgElement.getPattern(SvgElement.Pattern(backgroundId, '0', '0', LogoHelper.toString(patternSize), LogoHelper.toString(patternSize), 'userSpaceOnUse', element));
  }

  function getGMDef(string memory seed, string memory backgroundId, string memory fillZeroClass, string memory fillOneClass, string memory fillTwoClass, string memory fillThreeClass) public pure returns (string memory) {

    uint patternSizeX = randomInRange(string(abi.encodePacked(seed, 'a')), 300, 6);
    uint patternSizeY = randomInRange(string(abi.encodePacked(seed, 'b')), 300, 6);
    uint squareSize2 = randomInRange(seed, patternSizeX / 2, patternSizeX / 6);

    uint offset = randomInRange(seed, patternSizeX - (squareSize2 / 2) , 0);

    string memory element = SvgElement.getRect(SvgElement.Rect(fillZeroClass, '0', '0', LogoHelper.toString(patternSizeX), LogoHelper.toString(patternSizeX), '', '', ''));
    element = string(abi.encodePacked(element, SvgElement.getRect(SvgElement.Rect(fillOneClass, LogoHelper.toString(offset), LogoHelper.toString(offset), LogoHelper.toString(squareSize2), LogoHelper.toString(squareSize2), '0.8', '', ''))));
    SvgElement.Pattern memory pattern = SvgElement.Pattern(string(abi.encodePacked(backgroundId, '-1')), '0', '0', LogoHelper.toString(patternSizeX), LogoHelper.toString(patternSizeY), 'userSpaceOnUse', element);
    string memory defs = SvgElement.getPattern(pattern);

    patternSizeX = 300;
    patternSizeY = randomInRange(string(abi.encodePacked(seed, 'c')), 30, 0);
    squareSize2 = randomInRange(seed, patternSizeX, patternSizeX / 4);
    offset = 230 - (squareSize2 / 2);
    backgroundId = string(abi.encodePacked(backgroundId, '-2'));

    element = SvgElement.getRect(SvgElement.Rect(fillTwoClass, '0', '0', LogoHelper.toString(patternSizeX), LogoHelper.toString(squareSize2), '', '', ''));
    element = string(abi.encodePacked(element, SvgElement.getRect(SvgElement.Rect(fillThreeClass, LogoHelper.toString(offset), LogoHelper.toString(patternSizeY), LogoHelper.toString(squareSize2), LogoHelper.toString(patternSizeY), '0.8', '', ''))));
    patternSizeY = randomInRange(string(abi.encodePacked(seed, 'd')), 100, 0);
    pattern = SvgElement.Pattern(backgroundId, '0', '0', LogoHelper.toString(patternSizeX), LogoHelper.toString(patternSizeY), 'userSpaceOnUse', element);
    return string(abi.encodePacked(defs, SvgElement.getPattern(pattern)));
  }

  function randomInRange(string memory input, uint max, uint offset) public pure returns (uint256) {

    max = max - offset;
    return (random(input) % max) + offset;
  }

  function random(string memory input) public pure returns (uint256) {

    return uint256(keccak256(abi.encodePacked(input)));
  }
}