
pragma solidity 0.8.11;


library JsonWriter {

  using JsonWriter for string;

  struct Json {
    int256 depthBitTracker;
    string value;
  }

  bytes1 constant BACKSLASH = bytes1(uint8(92));
  bytes1 constant BACKSPACE = bytes1(uint8(8));
  bytes1 constant CARRIAGE_RETURN = bytes1(uint8(13));
  bytes1 constant DOUBLE_QUOTE = bytes1(uint8(34));
  bytes1 constant FORM_FEED = bytes1(uint8(12));
  bytes1 constant FRONTSLASH = bytes1(uint8(47));
  bytes1 constant HORIZONTAL_TAB = bytes1(uint8(9));
  bytes1 constant NEWLINE = bytes1(uint8(10));

  string constant TRUE = "true";
  string constant FALSE = "false";
  bytes1 constant OPEN_BRACE = "{";
  bytes1 constant CLOSED_BRACE = "}";
  bytes1 constant OPEN_BRACKET = "[";
  bytes1 constant CLOSED_BRACKET = "]";
  bytes1 constant LIST_SEPARATOR = ",";

  int256 constant MAX_INT256 = type(int256).max;

  function writeStartArray(Json memory json) public pure returns (Json memory) {

    return writeStart(json, OPEN_BRACKET);
  }

  function writeStartArray(Json memory json, string memory propertyName)
    public
    pure
    returns (Json memory)
  {

    return writeStart(json, propertyName, OPEN_BRACKET);
  }

  function writeStartObject(Json memory json)
    public
    pure
    returns (Json memory)
  {

    return writeStart(json, OPEN_BRACE);
  }

  function writeStartObject(Json memory json, string memory propertyName)
    public
    pure
    returns (Json memory)
  {

    return writeStart(json, propertyName, OPEN_BRACE);
  }

  function writeEndArray(Json memory json) public pure returns (Json memory) {

    return writeEnd(json, CLOSED_BRACKET);
  }

  function writeEndObject(Json memory json) public pure returns (Json memory) {

    return writeEnd(json, CLOSED_BRACE);
  }

  function writeAddressProperty(
    Json memory json,
    string memory propertyName,
    address value
  ) public pure returns (Json memory) {

    if (json.depthBitTracker < 0) {
      json.value = string(
        abi.encodePacked(
          json.value,
          LIST_SEPARATOR,
          '"',
          propertyName,
          '": "',
          addressToString(value),
          '"'
        )
      );
    } else {
      json.value = string(
        abi.encodePacked(
          json.value,
          '"',
          propertyName,
          '": "',
          addressToString(value),
          '"'
        )
      );
    }

    json.depthBitTracker = setListSeparatorFlag(json);

    return json;
  }

  function writeAddressValue(Json memory json, address value)
    public
    pure
    returns (Json memory)
  {

    if (json.depthBitTracker < 0) {
      json.value = string(
        abi.encodePacked(
          json.value,
          LIST_SEPARATOR,
          '"',
          addressToString(value),
          '"'
        )
      );
    } else {
      json.value = string(
        abi.encodePacked(json.value, '"', addressToString(value), '"')
      );
    }

    json.depthBitTracker = setListSeparatorFlag(json);

    return json;
  }

  function writeBooleanProperty(
    Json memory json,
    string memory propertyName,
    bool value
  ) public pure returns (Json memory) {

    string memory strValue;
    if (value) {
      strValue = TRUE;
    } else {
      strValue = FALSE;
    }

    if (json.depthBitTracker < 0) {
      json.value = string(
        abi.encodePacked(
          json.value,
          LIST_SEPARATOR,
          '"',
          propertyName,
          '": ',
          strValue
        )
      );
    } else {
      json.value = string(
        abi.encodePacked(json.value, '"', propertyName, '": ', strValue)
      );
    }

    json.depthBitTracker = setListSeparatorFlag(json);

    return json;
  }

  function writeBooleanValue(Json memory json, bool value)
    public
    pure
    returns (Json memory)
  {

    string memory strValue;
    if (value) {
      strValue = TRUE;
    } else {
      strValue = FALSE;
    }

    if (json.depthBitTracker < 0) {
      json.value = string(
        abi.encodePacked(json.value, LIST_SEPARATOR, strValue)
      );
    } else {
      json.value = string(abi.encodePacked(json.value, strValue));
    }

    json.depthBitTracker = setListSeparatorFlag(json);

    return json;
  }

  function writeIntProperty(
    Json memory json,
    string memory propertyName,
    int256 value
  ) public pure returns (Json memory) {

    if (json.depthBitTracker < 0) {
      json.value = string(
        abi.encodePacked(
          json.value,
          LIST_SEPARATOR,
          '"',
          propertyName,
          '": ',
          intToString(value)
        )
      );
    } else {
      json.value = string(
        abi.encodePacked(
          json.value,
          '"',
          propertyName,
          '": ',
          intToString(value)
        )
      );
    }

    json.depthBitTracker = setListSeparatorFlag(json);

    return json;
  }

  function writeIntValue(Json memory json, int256 value)
    public
    pure
    returns (Json memory)
  {

    if (json.depthBitTracker < 0) {
      json.value = string(
        abi.encodePacked(json.value, LIST_SEPARATOR, intToString(value))
      );
    } else {
      json.value = string(abi.encodePacked(json.value, intToString(value)));
    }

    json.depthBitTracker = setListSeparatorFlag(json);

    return json;
  }

  function writeNullProperty(Json memory json, string memory propertyName)
    public
    pure
    returns (Json memory)
  {

    if (json.depthBitTracker < 0) {
      json.value = string(
        abi.encodePacked(
          json.value,
          LIST_SEPARATOR,
          '"',
          propertyName,
          '": null'
        )
      );
    } else {
      json.value = string(
        abi.encodePacked(json.value, '"', propertyName, '": null')
      );
    }

    json.depthBitTracker = setListSeparatorFlag(json);

    return json;
  }

  function writeNullValue(Json memory json) public pure returns (Json memory) {

    if (json.depthBitTracker < 0) {
      json.value = string(abi.encodePacked(json.value, LIST_SEPARATOR, "null"));
    } else {
      json.value = string(abi.encodePacked(json.value, "null"));
    }

    json.depthBitTracker = setListSeparatorFlag(json);

    return json;
  }

  function writeStringProperty(
    Json memory json,
    string memory propertyName,
    string memory value
  ) public pure returns (Json memory) {

    string memory jsonEscapedString = escapeJsonString(value);
    if (json.depthBitTracker < 0) {
      json.value = string(
        abi.encodePacked(
          json.value,
          LIST_SEPARATOR,
          '"',
          propertyName,
          '": "',
          jsonEscapedString,
          '"'
        )
      );
    } else {
      json.value = string(
        abi.encodePacked(
          json.value,
          '"',
          propertyName,
          '": "',
          jsonEscapedString,
          '"'
        )
      );
    }

    json.depthBitTracker = setListSeparatorFlag(json);

    return json;
  }

  function writeStringValue(Json memory json, string memory value)
    public
    pure
    returns (Json memory)
  {

    string memory jsonEscapedString = escapeJsonString(value);
    if (json.depthBitTracker < 0) {
      json.value = string(
        abi.encodePacked(
          json.value,
          LIST_SEPARATOR,
          '"',
          jsonEscapedString,
          '"'
        )
      );
    } else {
      json.value = string(
        abi.encodePacked(json.value, '"', jsonEscapedString, '"')
      );
    }

    json.depthBitTracker = setListSeparatorFlag(json);

    return json;
  }

  function writeUintProperty(
    Json memory json,
    string memory propertyName,
    uint256 value
  ) public pure returns (Json memory) {

    if (json.depthBitTracker < 0) {
      json.value = string(
        abi.encodePacked(
          json.value,
          LIST_SEPARATOR,
          '"',
          propertyName,
          '": ',
          uintToString(value)
        )
      );
    } else {
      json.value = string(
        abi.encodePacked(
          json.value,
          '"',
          propertyName,
          '": ',
          uintToString(value)
        )
      );
    }

    json.depthBitTracker = setListSeparatorFlag(json);

    return json;
  }

  function writeUintValue(Json memory json, uint256 value)
    public
    pure
    returns (Json memory)
  {

    if (json.depthBitTracker < 0) {
      json.value = string(
        abi.encodePacked(json.value, LIST_SEPARATOR, uintToString(value))
      );
    } else {
      json.value = string(abi.encodePacked(json.value, uintToString(value)));
    }

    json.depthBitTracker = setListSeparatorFlag(json);

    return json;
  }

  function writeStart(Json memory json, bytes1 token)
    public
    pure
    returns (Json memory)
  {

    if (json.depthBitTracker < 0) {
      json.value = string(abi.encodePacked(json.value, LIST_SEPARATOR, token));
    } else {
      json.value = string(abi.encodePacked(json.value, token));
    }

    json.depthBitTracker &= MAX_INT256;
    json.depthBitTracker++;

    return json;
  }

  function writeStart(
    Json memory json,
    string memory propertyName,
    bytes1 token
  ) public pure returns (Json memory) {

    if (json.depthBitTracker < 0) {
      json.value = string(
        abi.encodePacked(
          json.value,
          LIST_SEPARATOR,
          '"',
          propertyName,
          '": ',
          token
        )
      );
    } else {
      json.value = string(
        abi.encodePacked(json.value, '"', propertyName, '": ', token)
      );
    }

    json.depthBitTracker &= MAX_INT256;
    json.depthBitTracker++;

    return json;
  }

  function writeEnd(Json memory json, bytes1 token)
    public
    pure
    returns (Json memory)
  {

    json.value = string(abi.encodePacked(json.value, token));
    json.depthBitTracker = setListSeparatorFlag(json);

    if (getCurrentDepth(json) != 0) {
      json.depthBitTracker--;
    }

    return json;
  }

  function escapeJsonString(string memory value)
    public
    pure
    returns (string memory str)
  {

    bytes memory b = bytes(value);
    bool foundEscapeChars;

    for (uint256 i; i < b.length; i++) {
      if (b[i] == BACKSLASH) {
        foundEscapeChars = true;
        break;
      } else if (b[i] == DOUBLE_QUOTE) {
        foundEscapeChars = true;
        break;
      } else if (b[i] == FRONTSLASH) {
        foundEscapeChars = true;
        break;
      } else if (b[i] == HORIZONTAL_TAB) {
        foundEscapeChars = true;
        break;
      } else if (b[i] == FORM_FEED) {
        foundEscapeChars = true;
        break;
      } else if (b[i] == NEWLINE) {
        foundEscapeChars = true;
        break;
      } else if (b[i] == CARRIAGE_RETURN) {
        foundEscapeChars = true;
        break;
      } else if (b[i] == BACKSPACE) {
        foundEscapeChars = true;
        break;
      }
    }

    if (!foundEscapeChars) {
      return value;
    }

    for (uint256 i; i < b.length; i++) {
      if (b[i] == BACKSLASH) {
        str = string(abi.encodePacked(str, "\\\\"));
      } else if (b[i] == DOUBLE_QUOTE) {
        str = string(abi.encodePacked(str, '\\"'));
      } else if (b[i] == FRONTSLASH) {
        str = string(abi.encodePacked(str, "\\/"));
      } else if (b[i] == HORIZONTAL_TAB) {
        str = string(abi.encodePacked(str, "\\t"));
      } else if (b[i] == FORM_FEED) {
        str = string(abi.encodePacked(str, "\\f"));
      } else if (b[i] == NEWLINE) {
        str = string(abi.encodePacked(str, "\\n"));
      } else if (b[i] == CARRIAGE_RETURN) {
        str = string(abi.encodePacked(str, "\\r"));
      } else if (b[i] == BACKSPACE) {
        str = string(abi.encodePacked(str, "\\b"));
      } else {
        str = string(abi.encodePacked(str, b[i]));
      }
    }

    return str;
  }

  function getCurrentDepth(Json memory json) public pure returns (int256) {

    return json.depthBitTracker & MAX_INT256;
  }

  function setListSeparatorFlag(Json memory json)
    private
    pure
    returns (int256)
  {

    return json.depthBitTracker | (int256(1) << 255);
  }

  function addressToString(address _address)
    internal
    pure
    returns (string memory)
  {

    bytes32 value = bytes32(uint256(uint160(_address)));
    bytes16 alphabet = "0123456789abcdef";

    bytes memory str = new bytes(42);
    str[0] = "0";
    str[1] = "x";
    for (uint256 i; i < 20; i++) {
      str[2 + i * 2] = alphabet[uint8(value[i + 12] >> 4)];
      str[3 + i * 2] = alphabet[uint8(value[i + 12] & 0x0f)];
    }

    return string(str);
  }

  function intToString(int256 i) internal pure returns (string memory) {

    if (i == 0) {
      return "0";
    }

    if (i == type(int256).min) {
      return
        "-57896044618658097711785492504343953926634992332820282019728792003956564819968";
    }

    bool negative = i < 0;
    uint256 len;
    uint256 j;
    if (!negative) {
      j = uint256(i);
    } else {
      j = uint256(-i);
      ++len; // make room for '-' sign
    }

    uint256 l = j;
    while (j != 0) {
      len++;
      j /= 10;
    }

    bytes memory bstr = new bytes(len);
    uint256 k = len;
    while (l != 0) {
      bstr[--k] = bytes1((48 + uint8(l - (l / 10) * 10)));
      l /= 10;
    }

    if (negative) {
      bstr[0] = "-"; // prepend '-'
    }

    return string(bstr);
  }

  function uintToString(uint256 _i) internal pure returns (string memory) {

    if (_i == 0) {
      return "0";
    }

    uint256 j = _i;
    uint256 len;
    while (j != 0) {
      len++;
      j /= 10;
    }

    bytes memory bstr = new bytes(len);
    uint256 k = len;
    while (_i != 0) {
      bstr[--k] = bytes1((48 + uint8(_i - (_i / 10) * 10)));
      _i /= 10;
    }

    return string(bstr);
  }
}