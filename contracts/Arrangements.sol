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
    event ArrangementEvent(uint128 indexed arrangementId, uint64 indexed userId, ArrangementStatus arrangementStatus);
    event MembershipEvent(uint128 indexed arrangementId, uint64 indexed memberId, MembershipStatus membershipStatus);

    struct Arrangement {
        bytes32 name;
        uint32 reward;
        bool created;
        uint64[] memberList;
        mapping(uint64 => User) members;
    }

    struct User {
        uint256 listId;
        bool isMember;
    }

    modifier _isArrangement(uint128 arrangementId) {
        require(arrangements[arrangementId].created, "Arrangement doesn't exist!");
        _;
    }
    
    uint128 internal arrangementIndex;
    mapping(uint128 => Arrangement) arrangements;

    function _createArrangement(uint64 issuer, uint32 reward, bytes32 name) internal virtual {
        arrangements[arrangementIndex].name = name;
        arrangements[arrangementIndex].reward = reward;
        arrangements[arrangementIndex].created = true;
        emit ArrangementEvent(arrangementIndex, issuer, ArrangementStatus.ARRANGEMENT_CREATED);
        unchecked {
            ++arrangementIndex;
        }
    }

    function _removeArrangement(uint64 issuer, uint128 arrangementId) internal virtual _isArrangement(arrangementId) {
        delete arrangements[arrangementId];
        
        emit ArrangementEvent(arrangementId, issuer, ArrangementStatus.ARRANGEMENT_REMOVED);
    }

    function _addMember(uint128 arrangementId, uint64 memberId) internal _isArrangement(arrangementId) {
        if (!arrangements[arrangementId].members[memberId].isMember) {
            arrangements[arrangementId].memberList.push(memberId);
            arrangements[arrangementId].members[memberId].isMember = true;
            arrangements[arrangementId].members[memberId].listId = arrangements[arrangementId].memberList.length - 1;
            
            emit MembershipEvent(arrangementId, memberId, MembershipStatus.USER_ADDED);
        }
    }

    function _removeMember(uint128 arrangementId, uint64 memberId) internal _isArrangement(arrangementId) {
        if (arrangements[arrangementId].members[memberId].isMember) {
            uint256 length = arrangements[arrangementId].memberList.length;  
            uint256 listId = arrangements[arrangementId].members[memberId].listId;
            uint64 lastMemberId = arrangements[arrangementId].memberList[length - 1];
            
            arrangements[arrangementId].members[lastMemberId].listId = listId;
            arrangements[arrangementId].memberList[listId] = lastMemberId;
            arrangements[arrangementId].memberList.pop();
            
            delete arrangements[arrangementId].members[memberId];

            emit MembershipEvent(arrangementId, memberId, MembershipStatus.USER_REMOVED);
        }
    }

    function _addMemberBulk(uint128 arrangementId, uint64[] calldata memberIds) internal {
        uint256 memberIdsLength = memberIds.length;
        for (uint256 i = 0; i < memberIdsLength; ) {
            _addMember(arrangementId, memberIds[i]);
            unchecked {
                ++i;
            }
        }
    }

    function _removeMemberBulk(uint128 arrangementId, uint64[] calldata memberIds) internal {
        uint256 memberIdsLength = memberIds.length;
        for (uint256 i = 0; i < memberIdsLength; ) {
            _removeMember(arrangementId, memberIds[i]);
            unchecked {
                ++i;
            }
        }
    }

    function getMembers(uint128 arrangementId) public view returns(uint64[] memory) {
        return arrangements[arrangementId].memberList;
    }

    function getArrangementData(uint128 arrangementId) public view returns(bytes32 name, uint32 reward) {
        return (arrangements[arrangementId].name, arrangements[arrangementId].reward);
    }

    function getTotalMembers(uint128 arrangementId) public view returns(uint256) {
        return arrangements[arrangementId].memberList.length;
    }

    function arrangementExists(uint128 arrangementId) public view returns(bool) {
        return arrangements[arrangementId].created;
    }

    function isMember(uint128 arrangementId, uint64 memberId) public view returns(bool) {
        return arrangements[arrangementId].members[memberId].isMember;
    }
}