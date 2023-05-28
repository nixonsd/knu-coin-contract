// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Teachers.sol";
import "./CTERC20.sol";
import "./Arrangements.sol";

contract KNUCOIN is Ownable, Teachers, CTERC20 {
    constructor(
        uint64 issuer,
        uint128 teacherArrangementLimit, 
        string memory name_, 
        string memory symbol_
        ) CTERC20(name_, symbol_) Teachers(issuer, teacherArrangementLimit) {}

    function mint(uint64 issuer, uint64 memberId, uint32 amount) external 
    onlyOwner _isTeacher(issuer) {
        _mint(memberId, amount);
    }

    function redeem(uint64 issuer, uint64 memberId, uint32 amount) external 
    onlyOwner _isTeacher(issuer) {
        _redeem(memberId, amount);
    }

    function addTeacher(uint64 issuer, uint64 memberId) public override 
    onlyOwner {
        super.addTeacher(issuer, memberId);
    }

    function removeTeacher(uint64 issuer, uint64 memberId) public override 
    onlyOwner {
        super.removeTeacher(issuer, memberId);
    }

    function createArrangement(uint64 issuer, uint32 reward, bytes32 name) public override 
    onlyOwner {
        super.createArrangement(issuer, reward, name);
    }

    function removeArrangement(uint64 issuer, uint128 arrangementId) public override 
    onlyOwner {
        super.removeArrangement(issuer, arrangementId);
    }

    function finishArrangement(uint64 issuer, uint128 arrangementId) external 
    onlyOwner _isTeacher(issuer) {
        uint64[] memory members = getMembers(arrangementId);
        uint32 reward = arrangements[arrangementId].reward;
        super.removeArrangement(issuer, arrangementId);
        
        for (uint64 i = 0; i < members.length; i++) {
            _mint(members[i], reward);
        }
    }

    function addMember(uint64 issuer, uint64 memberId, uint128 arrangementId) public override 
    onlyOwner {
        super.addMember(issuer, memberId, arrangementId);
    }

    function removeMember(uint64 issuer, uint64 memberId, uint128 arrangementId) public override
    onlyOwner {
        super.removeMember(issuer, memberId, arrangementId);
    }
}