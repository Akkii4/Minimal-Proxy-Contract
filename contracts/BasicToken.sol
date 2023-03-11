// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

contract BasicToken is Initializable, ERC20Upgradeable {
    function initialize(
        string calldata _name,
        string calldata _symbol
    ) external initializer {
        __ERC20_init(_name, _symbol);
    }

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external {
        _burn(account, amount);
    }
}
