// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./Arrangements.sol";
import "./CTERC20.sol";

library ArrayFunctionality {
    function removeArrangement(uint128[] storage array, uint128 index) public {
        array[index] = array[array.length - 1];
        array.pop();
    }
}

contract Teachers is Arrangements {
    enum TeacherStatus { TEACHER_ADDED, TEACHER_REMOVED }
    event TeacherEvent(uint64 indexed teacherId, uint64 indexed userId, TeacherStatus teacherStatus);

    using ArrayFunctionality for uint128[];
    struct _Arrangement {
        uint128 listId;
        bool isArrangement;
    }
    struct Teacher {
        bool bearer;
        uint128[] arrangementIdList;
        mapping(uint128 => _Arrangement) arrangements;
    }

    constructor(uint64 issuer) {
        bearers[issuer].bearer = true;
        emit TeacherEvent(0, issuer, TeacherStatus.TEACHER_ADDED);
    }

    uint256 public constant arrangementLimit = 4;
    mapping(uint64 => Teacher) bearers;

    function _createArrangement(uint64 issuer, uint32 reward) internal override _isTeacher(issuer) {
        require(bearers[issuer].arrangementIdList.length < arrangementLimit, "You exceed the arrangement limit");
        bearers[issuer].arrangements[arrangementIndex].listId = uint128(bearers[issuer].arrangementIdList.length);
        bearers[issuer].arrangements[arrangementIndex].isArrangement = true;
        bearers[issuer].arrangementIdList.push(arrangementIndex);
        Arrangements._createArrangement(issuer, reward);
    }

    function _removeArrangement(uint64 issuer, uint128 arrangementId) internal override _isTeacher(issuer) {
        require(bearers[issuer].arrangements[arrangementId].isArrangement, "You're not allowed!");
        
        uint256 length = bearers[issuer].arrangementIdList.length;  
        uint128 listId = bearers[issuer].arrangements[arrangementId].listId;
        uint128 lastArrangementId = bearers[issuer].arrangementIdList[length - 1];
       
        bearers[issuer].arrangements[lastArrangementId].listId = listId;
        bearers[issuer].arrangementIdList[listId] = lastArrangementId;
        bearers[issuer].arrangementIdList.pop();        

        delete bearers[issuer].arrangements[arrangementId];
        Arrangements._removeArrangement(issuer, arrangementId);
    }

    function _addMember(uint64 issuer, uint64 memberId, uint128 arrangementId) internal {
        require (issuer == memberId || isTeacher(issuer), "You're not allowed!");
        Arrangements._addMember(arrangementId, memberId);
    }

    function _removeMember(uint64 issuer, uint64 memberId, uint128 arrangementId) internal {
        require (issuer == memberId || isTeacher(issuer), "You're not allowed!");
        Arrangements._removeMember(arrangementId, memberId);
    }

    function _addMemberBulk(uint64 issuer, uint128 arrangementId, uint64[] calldata memberIds) internal _isTeacher(issuer) {
        Arrangements._addMemberBulk(arrangementId, memberIds);
    }

    function _removeMemberBulk(uint64 issuer, uint128 arrangementId, uint64[] calldata memberIds) internal _isTeacher(issuer) {
        Arrangements._removeMemberBulk(arrangementId, memberIds);
    }

    function getArrangements(uint64 teacherId) public view returns(uint128[] memory) {
        return bearers[teacherId].arrangementIdList;
    }

    function isTeacher(uint64 id) public view returns(bool) {
        return bearers[id].bearer;
    }

    function _addTeacher(uint64 issuer, uint64 id) internal _isTeacher(issuer) {
        if (!isTeacher(id)) {
            bearers[id].bearer = true;
            emit TeacherEvent(issuer, id, TeacherStatus.TEACHER_ADDED);
        }
    }

    function _removeTeacher(uint64 issuer, uint64 id) internal _isTeacher(issuer) {
        if (isTeacher(id)) {
            bearers[id].bearer = false;
            emit TeacherEvent(issuer, id, TeacherStatus.TEACHER_REMOVED);
        }
    }

    modifier _isTeacher(uint64 userId) {
        require(isTeacher(userId), "You're not allowed!");
        _;
    }
}