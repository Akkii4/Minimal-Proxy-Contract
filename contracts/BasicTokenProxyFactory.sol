// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BasicTokenProxyFactory is Ownable {
    address public implementation;

    address[] public clonesList;

    event CloneCreated(address _clone);

    constructor(address _implementation) {
        implementation = _implementation;
    }

    function createNewToken(
        string calldata _name,
        string calldata _symbol
    ) external onlyOwner returns (address newInstance) {
        newInstance = Clones.clone(implementation);
        (bool success, ) = newInstance.call(
            abi.encodeWithSignature("initialize(string,string)", _name, _symbol)
        );
        require(success, "Creation Failed");
        clonesList.push(newInstance);
        emit CloneCreated(newInstance);
        return newInstance;
    }
}
