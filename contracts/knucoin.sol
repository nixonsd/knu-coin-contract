// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract KNUCoin is ERC20 {
    address payable public owner;

    constructor(uint256 initialSupply) ERC20('KNU Coin Token', "KNUCOIN") {
        owner = payable(msg.sender);
        _mint(msg.sender, initialSupply);
    }

    function mint(uint amount) external {
        require(msg.sender == owner, "You aren't the owner");
        _mint(msg.sender, amount);
    }

    function burn(uint amount) external {
        require(msg.sender == owner, "You aren't the owner");
        _burn(msg.sender, amount);
    }
}
