// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract CTERC20 {
    event Transfer(uint64 indexed from, uint64 indexed to, uint256 amount);
    mapping(uint64 => uint32) private _balances; 
    
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function _mint(uint64 userId, uint32 amount) internal {
        _balances[userId] += amount;
        emit Transfer(0, userId, amount);
    }

    function _redeem(uint64 userId, uint32 amount) internal {
        require(_balances[userId] >= amount, "The user doesn't possess this much!");
        _balances[userId] -= amount;
        emit Transfer(userId, 0, amount);
    }

    function balanceOf(uint64 userId) public view returns(uint32) {
        return _balances[userId];
    }

     function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns(uint8) {
        return 3;
    }
}