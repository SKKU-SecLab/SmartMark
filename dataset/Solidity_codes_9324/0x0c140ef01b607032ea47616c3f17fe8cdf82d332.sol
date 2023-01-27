
pragma solidity ^0.4.24;

library EnumerableSet256 {


    struct Data {
        uint256[] elements;
        mapping(uint256 => uint256) elementToIndex;
    }

    function contains(Data storage self, uint256 value) external view returns (bool) {

        uint256 mappingIndex = self.elementToIndex[value];
        return (mappingIndex < self.elements.length) && (self.elements[mappingIndex] == value);
    }

    function add(Data storage self, uint256 value) external {

        uint256 mappingIndex = self.elementToIndex[value];
        require(!((mappingIndex < self.elements.length) && (self.elements[mappingIndex] == value)));

        self.elementToIndex[value] = uint256(self.elements.length);
        self.elements.push(value);
    }

    function remove(Data storage self, uint256 value) external {

        uint256 currentElementIndex = self.elementToIndex[value];
        require((currentElementIndex < self.elements.length) && (self.elements[currentElementIndex] == value));

        uint256 lastElementIndex = uint256(self.elements.length - 1);
        uint256 lastElement = self.elements[lastElementIndex];

        self.elements[currentElementIndex] = lastElement;
        self.elements[lastElementIndex] = 0;
        self.elements.length--;

        self.elementToIndex[lastElement] = currentElementIndex;
        self.elementToIndex[value] = 0;
    }

    function size(Data storage self) external view returns (uint256) {

        return uint256(self.elements.length);
    }

    function get(Data storage self, uint256 index) external view returns (uint256) {

        return self.elements[index];
    }

    function clear(Data storage self) external {

        self.elements.length = 0;
    }
}