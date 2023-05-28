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
    event TeacherEvent(uint64 indexed teacherId, uint64 indexed userId, TeacherStatus indexed teacherStatus);

    using ArrayFunctionality for uint128[];
    struct _Arrangement {
        uint128 sequenceNumber;
        bool isArrangement;
    }
    struct Teacher {
        bool bearer;
        uint128[] arrangementList;
        mapping(uint128 => _Arrangement) arrangements;
    }

    modifier _isTeacher(uint64 userId) {
        require(isTeacher(userId), "You're not allowed!");
        _;
    }

    constructor(uint64 issuer, uint128 arrangementLimit) {
        bearers[issuer].bearer = true;
        ARRANGEMENT_LIMIT = arrangementLimit;
        emit TeacherEvent(0, issuer, TeacherStatus.TEACHER_ADDED);
    }

    uint128 public immutable ARRANGEMENT_LIMIT;
    mapping(uint64 => Teacher) bearers;

    function addTeacher(uint64 issuer, uint64 memberId) public virtual 
    _isTeacher(issuer) {
        if (!isTeacher(memberId)) {
            bearers[memberId].bearer = true;
            emit TeacherEvent(issuer, memberId, TeacherStatus.TEACHER_ADDED);
        }
    }

    function removeTeacher(uint64 issuer, uint64 memberId) public virtual 
    _isTeacher(issuer) {
        if (isTeacher(memberId)) {
            bearers[memberId].bearer = false;
            emit TeacherEvent(issuer, memberId, TeacherStatus.TEACHER_REMOVED);
        }
    }

    function createArrangement(uint64 issuer, uint32 reward, bytes32 name) public override virtual _isTeacher(issuer) {
        require(bearers[issuer].arrangementList.length < ARRANGEMENT_LIMIT, "You exceed the arrangement limit");
        bearers[issuer].arrangements[arrangementCount].sequenceNumber = uint128(bearers[issuer].arrangementList.length);
        bearers[issuer].arrangements[arrangementCount].isArrangement = true;
        bearers[issuer].arrangementList.push(arrangementCount);
        super.createArrangement(issuer, reward, name);
    }

    function removeArrangement(uint64 issuer, uint128 arrangementId) public override virtual _isTeacher(issuer) {
        require(bearers[issuer].arrangements[arrangementId].isArrangement, "You're not allowed!");
        
        uint256 length = bearers[issuer].arrangementList.length;  
        uint128 sequenceNumber = bearers[issuer].arrangements[arrangementId].sequenceNumber;
        uint128 last = bearers[issuer].arrangementList[length - 1];
       
        delete bearers[issuer].arrangements[arrangementId];

        bearers[issuer].arrangements[last].sequenceNumber = sequenceNumber;
        bearers[issuer].arrangementList[sequenceNumber] = last;
        bearers[issuer].arrangementList.pop();        

        super.removeArrangement(issuer, arrangementId);
    }

    function getArrangementsOf(uint64 teacherId) public view returns(uint128[] memory) {
        return bearers[teacherId].arrangementList;
    }

    function getTotalArrangements(uint64 teacherId) public view returns(uint256) {
        return bearers[teacherId].arrangementList.length;
    }

    function isTeacher(uint64 memberId) public view returns(bool) {
        return bearers[memberId].bearer;
    }
}