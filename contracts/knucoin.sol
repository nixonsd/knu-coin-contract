// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Teachers.sol";
import "./CTERC20.sol";
import "./Arrangements.sol";

contract KNUCOIN is Ownable, Teachers, CTERC20 {
    constructor(
        uint64 issuer, 
        string memory name_, 
        string memory symbol_
        ) CTERC20(name_, symbol_) Teachers(issuer) {}

    function mint(uint64 issuer, uint64 userId, uint32 amount) external onlyOwner _isTeacher(issuer) {
        _mint(userId, amount);
    }

    function addTeacher(uint64 issuer, uint64 userId) external onlyOwner {
        _addTeacher(issuer, userId);
    }

    function removeTeacher(uint64 issuer, uint64 userId) external onlyOwner {
        _removeTeacher(issuer, userId);
    }

    function createArrangement(uint64 issuer, uint32 reward) external onlyOwner {
        _createArrangement(issuer, reward);
    }

    function removeArrangement(uint64 issuer, uint128 arrangementId) external onlyOwner {
        _removeArrangement(issuer, arrangementId);
    }

    function addMember(uint64 issuer, uint64 memberId, uint128 arrangementId) external onlyOwner {
        _addMember(issuer, memberId, arrangementId);
    }

    function removeMember(uint64 issuer, uint64 memberId, uint128 arrangementId) external onlyOwner {
        _removeMember(issuer, memberId, arrangementId);
    }
}
