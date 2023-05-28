// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Arrangements {
    enum ArrangementStatus { 
        ARRANGEMENT_CREATED,
        ARRANGEMENT_REMOVED
    }
    enum MembershipStatus {
        USER_ADDED,
        USER_REMOVED
    }
    event ArrangementEvent(uint128 indexed arrangementId, uint64 indexed userId, ArrangementStatus indexed arrangementStatus);
    event MembershipEvent(uint128 indexed arrangementId, uint64 indexed memberId, MembershipStatus indexed membershipStatus);

    struct Arrangement {
        bytes32 name;
        uint32 reward;
        uint64 creatorId;
        bool created;
        uint64[] memberList;
        mapping(uint64 => User) members;
    }

    struct User {
        uint64 sequenceNumber;
        bool isMember;
    }

    modifier _isArrangement(uint128 arrangementId) {
        require(isArrangement(arrangementId), "Arrangement doesn't exist!");
        _;
    }
    
    uint128 internal arrangementCount;
    mapping(uint128 => Arrangement) arrangements;

    function createArrangement(uint64 issuer, uint32 reward, bytes32 name) public virtual {
        arrangements[arrangementCount].name = name;
        arrangements[arrangementCount].reward = reward;
        arrangements[arrangementCount].creatorId = issuer;
        arrangements[arrangementCount].created = true;
        emit ArrangementEvent(arrangementCount, issuer, ArrangementStatus.ARRANGEMENT_CREATED);
        unchecked {
            ++arrangementCount;
        }
    }

    function removeArrangement(uint64 issuer, uint128 arrangementId) public virtual 
    _isArrangement(arrangementId) {
        delete arrangements[arrangementId];
        
        emit ArrangementEvent(arrangementId, issuer, ArrangementStatus.ARRANGEMENT_REMOVED);
    }

    function addMember(uint64 issuer, uint64 memberId, uint128 arrangementId) public virtual 
    _isArrangement(arrangementId) {
        require(issuer == memberId || issuer == arrangements[arrangementId].creatorId, "You're not allowed!");
        require(!arrangements[arrangementId].members[memberId].isMember, "The user is a member!");
        arrangements[arrangementId].memberList.push(memberId);
        arrangements[arrangementId].members[memberId].isMember = true;
        arrangements[arrangementId].members[memberId].sequenceNumber = uint64(arrangements[arrangementId].memberList.length - 1);
        
        emit MembershipEvent(arrangementId, memberId, MembershipStatus.USER_ADDED);
    }

    function removeMember(uint64 issuer, uint64 memberId, uint128 arrangementId) public virtual 
    _isArrangement(arrangementId) {
        require(issuer == memberId || issuer == arrangements[arrangementId].creatorId, "You're not allowed!");
        require(arrangements[arrangementId].members[memberId].isMember, "The user is not a member");
        uint256 length = arrangements[arrangementId].memberList.length;  
        uint64 sequenceNumber = arrangements[arrangementId].members[memberId].sequenceNumber;
        uint64 last = arrangements[arrangementId].memberList[length - 1];
        
        delete arrangements[arrangementId].members[memberId];

        arrangements[arrangementId].members[last].sequenceNumber = sequenceNumber;
        arrangements[arrangementId].memberList[last] = last;
        arrangements[arrangementId].memberList.pop();
        
        emit MembershipEvent(arrangementId, memberId, MembershipStatus.USER_REMOVED);
    }

    function getMembers(uint128 arrangementId) public view 
    _isArrangement(arrangementId) returns(uint64[] memory) {
        return arrangements[arrangementId].memberList;
    }

    function getTotalMembers(uint128 arrangementId) public view 
    _isArrangement(arrangementId) returns(uint256) {
        return arrangements[arrangementId].memberList.length;
    }

    function getArrangement(uint128 arrangementId) public view 
    _isArrangement(arrangementId) returns(bytes32 name, uint32 reward, uint64 creatorId) {
        return (
            arrangements[arrangementId].name,
            arrangements[arrangementId].reward,
            arrangements[arrangementId].creatorId
        );
    }

    function isCreator(uint128 arrangementId, uint64 memberId) public view returns(bool) {
        return arrangements[arrangementId].creatorId == memberId;
    }

    function isMember(uint128 arrangementId, uint64 memberId) public view returns(bool) {
        return arrangements[arrangementId].members[memberId].isMember;
    }

    function isArrangement(uint128 arrangementId) public view returns(bool) {
        return arrangements[arrangementId].created;
    }
}