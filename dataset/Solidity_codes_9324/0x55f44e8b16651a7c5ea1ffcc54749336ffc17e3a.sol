
library SetLibrary
{

    struct ArrayIndexAndExistsFlag
    {
        uint256 index;
        bool exists;
    }
    struct Set
    {
        mapping(uint256 => ArrayIndexAndExistsFlag) valuesMapping;
        uint256[] values;
    }
    function add(Set storage self, uint256 value) public returns (bool added)
    {

        if (self.valuesMapping[value].exists == true) return false;
        
        self.valuesMapping[value] = ArrayIndexAndExistsFlag({index: self.values.length, exists: true});
        
        self.values.push(value);
        
        return true;
    }
    function contains(Set storage self, uint256 value) public view returns (bool contained)
    {

        return self.valuesMapping[value].exists;
    }
    function remove(Set storage self, uint256 value) public returns (bool removed)
    {

        if (self.valuesMapping[value].exists == false) return false;
        
        self.valuesMapping[value].exists = false;
        
        if (self.valuesMapping[value].index < self.values.length-1)
        {
            uint256 valueToMove = self.values[self.values.length-1];
            uint256 indexToMoveItTo = self.valuesMapping[value].index;
            self.values[indexToMoveItTo] = valueToMove;
            self.valuesMapping[valueToMove].index = indexToMoveItTo;
        }
        
        
        self.values.length--;
        
        delete self.valuesMapping[value];
        
        return true;
    }
    function size(Set storage self) public view returns (uint256 amountOfValues)
    {

        return self.values.length;
    }
    
    function add(Set storage self, address value) public returns (bool added) { return add(self, uint256(value)); }

    function add(Set storage self, bytes32 value) public returns (bool added) { return add(self, uint256(value)); }

    function contains(Set storage self, address value) public view returns (bool contained) { return contains(self, uint256(value)); }

    function contains(Set storage self, bytes32 value) public view returns (bool contained) { return contains(self, uint256(value)); }

    function remove(Set storage self, address value) public returns (bool removed) { return remove(self, uint256(value)); }

    function remove(Set storage self, bytes32 value) public returns (bool removed) { return remove(self, uint256(value)); }

}