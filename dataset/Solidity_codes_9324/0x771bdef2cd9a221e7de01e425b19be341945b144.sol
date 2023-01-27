
pragma solidity ^0.4.24;

library EnumerableSetAddress {


    struct Data {
        address[] elements;
        mapping(address => uint160) elementToIndex;
    }

    function contains(Data storage self, address value) external view returns (bool) {

        uint160 mappingIndex = self.elementToIndex[value];
        return (mappingIndex < self.elements.length) && (self.elements[mappingIndex] == value);
    }

    function add(Data storage self, address value) external {

        uint160 mappingIndex = self.elementToIndex[value];
        require(!((mappingIndex < self.elements.length) && (self.elements[mappingIndex] == value)));

        self.elementToIndex[value] = uint160(self.elements.length);
        self.elements.push(value);
    }

    function remove(Data storage self, address value) external {

        uint160 currentElementIndex = self.elementToIndex[value];
        require((currentElementIndex < self.elements.length) && (self.elements[currentElementIndex] == value));

        uint160 lastElementIndex = uint160(self.elements.length - 1);
        address lastElement = self.elements[lastElementIndex];

        self.elements[currentElementIndex] = lastElement;
        self.elements[lastElementIndex] = 0;
        self.elements.length--;

        self.elementToIndex[lastElement] = currentElementIndex;
        self.elementToIndex[value] = 0;
    }

    function size(Data storage self) external view returns (uint160) {

        return uint160(self.elements.length);
    }

    function get(Data storage self, uint160 index) external view returns (address) {

        return self.elements[index];
    }

    function clear(Data storage self) external {

        self.elements.length = 0;
    }

    function copy(Data storage source, Data storage target) external {

        uint160 numElements = uint160(source.elements.length);

        target.elements.length = numElements;
        for (uint160 index = 0; index < numElements; index++) {
            address element = source.elements[index];
            target.elements[index] = element;
            target.elementToIndex[element] = index;
        }
    }

    function addAll(Data storage self, Data storage other) external {

        uint160 numElements = uint160(other.elements.length);

        for (uint160 index = 0; index < numElements; index++) {
            address value = other.elements[index];

            uint160 mappingIndex = self.elementToIndex[value];
            if (!((mappingIndex < self.elements.length) && (self.elements[mappingIndex] == value))) {
                self.elementToIndex[value] = uint160(self.elements.length);
                self.elements.push(value);
            }
        }
    }

}