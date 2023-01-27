
pragma solidity ^0.4.19;

contract Wicflight {

  struct Insurance {          // all the infos related to a single insurance
    bytes32 productId;           // ID string of the product linked to this insurance
    uint limitArrivalTime;    // maximum arrival time after which we trigger compensation (timestamp in sec)
    uint32 premium;           // amount of the premium
    uint32 indemnity;         // amount of the indemnity
    uint8 status;             // status of this insurance contract. See comment above for potential values
  }

  event InsuranceCreation(    // event sent when a new insurance contract is added to this smart contract
    bytes32 flightId,         // <carrier_code><flight_number>.<timestamp_in_sec_of_departure_date>
    uint32 premium,           // amount of the premium paid by the user
    uint32 indemnity,         // amount of the potential indemnity
    bytes32 productId            // ID string of the product linked to this insurance
  );

  event InsuranceUpdate(      // event sent when the situation of a particular insurance contract is resolved
    bytes32 productId,           // id string of the user linked to this account
    bytes32 flightId,         // <carrier_code><flight_number>.<timestamp_in_sec_of_departure_date>
    uint32 premium,           // amount of the premium paid by the user
    uint32 indemnity,         // amount of the potential indemnity
    uint8 status              // new status of the insurance contract. See above comment for potential values
  );

  address creator;            // address of the creator of the contract

  mapping (bytes32 => Insurance[]) insuranceList;



  modifier onlyIfCreator {

    if (msg.sender == creator) _;
  }

  function Wicflight() public {

    creator = msg.sender;
  }



  function areStringsEqual (bytes32 a, bytes32 b) private pure returns (bool) {
    return keccak256(a) == keccak256(b);
  }



  function addNewInsurance(
    bytes32 flightId,
    uint limitArrivalTime,
    uint32 premium,
    uint32 indemnity,
    bytes32 productId)
  public
  onlyIfCreator {


    Insurance memory insuranceToAdd;
    insuranceToAdd.limitArrivalTime = limitArrivalTime;
    insuranceToAdd.premium = premium;
    insuranceToAdd.indemnity = indemnity;
    insuranceToAdd.productId = productId;
    insuranceToAdd.status = 0;

    insuranceList[flightId].push(insuranceToAdd);

    InsuranceCreation(flightId, premium, indemnity, productId);
  }

  function updateFlightStatus(
    bytes32 flightId,
    uint actualArrivalTime)
  public
  onlyIfCreator {


    uint8 newStatus = 1;

    for (uint i = 0; i < insuranceList[flightId].length; i++) {

      if (insuranceList[flightId][i].status == 0) {

        newStatus = 1;

        if (actualArrivalTime > insuranceList[flightId][i].limitArrivalTime) {
          newStatus = 2;
        }

        insuranceList[flightId][i].status = newStatus;

        InsuranceUpdate(
          insuranceList[flightId][i].productId,
          flightId,
          insuranceList[flightId][i].premium,
          insuranceList[flightId][i].indemnity,
          newStatus
        );
      }
    }
  }

  function manualInsuranceResolution(
    bytes32 flightId,
    uint8 newStatusId,
    bytes32 productId)
  public
  onlyIfCreator {


    for (uint i = 0; i < insuranceList[flightId].length; i++) {

      if (areStringsEqual(insuranceList[flightId][i].productId, productId)) {

        if (insuranceList[flightId][i].status == 0) {

          insuranceList[flightId][i].status = newStatusId;

          InsuranceUpdate(
            productId,
            flightId,
            insuranceList[flightId][i].premium,
            insuranceList[flightId][i].indemnity,
            newStatusId
          );

          return;
        }
      }
    }
  }

  function getInsurancesCount(bytes32 flightId) public view onlyIfCreator returns (uint) {

    return insuranceList[flightId].length;
  }

  function getInsurance(bytes32 flightId, uint index) public view onlyIfCreator returns (bytes32, uint, uint32, uint32, uint8) {

    Insurance memory ins = insuranceList[flightId][index];
    return (ins.productId, ins.limitArrivalTime, ins.premium, ins.indemnity, ins.status);
  }

}