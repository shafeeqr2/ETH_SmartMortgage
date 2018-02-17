pragma solidity ^0.4.19;
contract Adoption {

address[16] public adopters;

  function  adopt (uint pedId) public returns (uint) {
    require (pedId >= 0 && pedId <= 15);
    adopters[pedId] = msg.sender;
    return pedId;
  }

  function getAdopters() public view returns (address[16]) {
    return adopters;
  }

}
