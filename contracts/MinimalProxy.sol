// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/** 
    Bytecode of MinimalProxy contract which will be cloned:

        10 bytes             10 bytes                        20 bytes                           15 bytes
    3d602d80600a3d3981f3363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe5af43d82803e903d91602b57fd5bf3
    |----init code-----|---copy calldata---|----implementation contract address----|---------delegatecall---------|
    <---creation code--><--------------------------------runtime bytecode----------------------------------------->

    1. creation or init code : runs at the time of deployment responsible for deploying MinimalProxy contract and saves runtime code to blockchain
    2. copy calldata : it copies the transaction calldata to memory
    3. after the After the transaction calldata is copied to memory, 20 bytes address of the implementation contract is pushed to the top of the stack
    4. MinimalProxy perform a delegatecall to the target Contract that need to be cloned

    After delegate call, the minimal proxy returns the result of the call to determine it's success
*/

contract MinimalProxy {
    function clone(address _targetContract) external returns (address result) {
        // convert address to 20 bytes
        bytes20 targetBytes = bytes20(_targetContract);

        assembly {
            /**
            reads the 32 bytes of memory starting at pointer stored in 0x40

            In solidity, the 0x40 slot in memory is special: it contains the "free memory pointer"
            which points to the end of the currently allocated memory.
            */
            let clone := mload(0x40)

            // store 32 bytes to "clone" (with 20 starting bytes as initcode + calldata)
            mstore(
                clone,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )

            /**
              |              20 bytes                |
            0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
                                                      ^
                                                      pointer
            after moving pointer to 20 bytes in "clone", store implementation target address(20 bytes)
            */
            mstore(add(clone, 0x14), targetBytes)

            /**
              |               20 bytes               |                 20 bytes              |
            0x3d602d80600a3d3981f3363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe
                                                                                              ^
                                                                                              pointer
            after moving pointer to 40 bytes in "clone", store delegatecall code(15 bytes) + remaining 0 to comlplete 32 bytes                                                               
            */
            mstore(
                add(clone, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )

            /**
              |               20 bytes               |                 20 bytes              |           15 bytes          |
            0x3d602d80600a3d3981f3363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe5af43d82803e903d91602b57fd5bf3
            
            create new contract
            send 0 Ether
            code starts from the end of "clone" code size 0x37 (55 bytes)
            */
            result := create(0, clone, 0x37)
        }
    }
}
