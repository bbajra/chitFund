pragma solidity ^0.6.8;

contract Insurance {
    enum Originator {
        Member,
        Underwriter
    }
    enum MemberState {
        Insured,
        RequestInsurance,
        NotInsured

    }
    enum UnderwriterDecision {
        Approved,
        Rejected
    }

    MemberState public currentState;

    uint256 public createDate;
    uint256 public modifiedDate;

    address public memberAddress;
    address public underwriterAddress;
    address public ownerAddress;

    mapping (address => UnderwriterDecision) underwriterDecision;
    mapping (uint16 => address) public underwriters;

    uint16 public totalUnderwriters;
    uint16 public neededApprovals;

    event StateTransitionNotAllowed(MemberState oldState, MemberState newState, address originary);
    event StateDidTransition(MemberState oldState, MemberState newState, address originary);
    event ActionNotAllowed(MemberState state, address originary, string reason);

    modifier onlyAddress(Originator _originary) {
        if (!isOriginatorType(_originary)) {
            ActionNotAllowed(currentState, msg.sender, 'address');
            return;
        }
        _;
    }

    modifier onlyState(MemberState _state) {
        if (currentState != _state) {
            ActionNotAllowed(currentState, msg.sender, 'state');
            return;
        }
        _;
    }

    function ChitFundInsurance(address _manager, address _member) private {
        createDate = now;
        modifiedDate = now;

        ownerAddress = msg.sender;
        underwriterAddress = _manager;

        memberAddress = _member;

        currentState = MemberState.RequestInsurance;
    }
    function assignUnderwriters(address[] memory _underwriters, uint16 _needInsurance)
    onlyAddress(Originator.Member)
    onlyState(MemberState.RequestInsurance) public {

        for (uint16 i = 0; i < _underwriters.length; i++) {
            _underwriters[i] = _underwriters[i];
            totalUnderwriters += 1;
        }

        _needInsurance = _needInsurance;
    }

    function addUnderwriterDecision(UnderwriterDecision decision)
    onlyAddress(Originator.Underwriter)
    onlyState(MemberState.RequestInsurance) public returns (bool) {

        underwriterDecision[msg.sender] = decision;
        return checkUnderwriterDecision();
    }

    function transitionState(MemberState newState) public returns (bool) {
        if (!isTransitionAllowed(uint(currentState), uint(newState))) {
            StateTransitionNotAllowed(currentState, newState, msg.sender);
            return false;
        }

        StateDidTransition(currentState, newState, msg.sender);
        currentState = newState;
        return true;
    }

    function isOriginatorType(Originator originator) private pure returns (bool) {
        if (originator == Originator.Member) { return msg.sender == memberAddress; }
        if (originator == Originator.Underwriter) { return isUnderwriter(msg.sender); }
        return false;
    }

    function isUnderwriter(address ad) private pure returns (bool) {
        for (uint16 i = 0; i < totalUnderwriters; i++) {
            if (underwriters[i] == ad) {
                return true;
            }
        }
        return false;
    }

    function checkUnderwriterDecision() private returns (bool) {
        if (hasBeenApproved()) {
            return transitionState(MemberState.Insured);
        }

        if (hasBeenRejected()) {
            return transitionState(MemberState.NotInsured);
        }

        return true;
    }

    function hasBeenApproved() private returns (bool) {
        uint16 total; uint16 approves; uint16 rejects;
        (total, approves, rejects) = getUnderwriterDecision();

        return approves >= neededApprovals;
    }

    function hasBeenRejected() private returns (bool) {
        uint16 total; uint16 approves; uint16 rejects;
        (total, approves, rejects) = getUnderwriterDecision();

        return total - rejects < neededApprovals;
    }

    function getUnderwriterDecision() private pure returns (uint16 _totalUnderwriters, uint16 _approvals, uint16 _rejections) {
        _totalUnderwriters = totalUnderwriters;
        for (uint16 i = 0; i < totalUnderwriters; i++) {
            UnderwriterDecision decision = underwriterDecision[i];
            if (decision == UnderwriterDecision.Approved) {
                _approvals += 1;
            }
            if (decision == UnderwriterDecision.Rejected) {
                _rejections += 1;
            }
        }
        return;
    }

    function isTransitionAllowed(uint state, uint newState) private pure returns (bool) {
        if (isOriginatorType(Originator.Member)) {
            if (state == uint(MemberState.RequestInsurance) && newState == uint(MemberState.Insured)) { return true; }
            if (state == uint(MemberState.Insured) && newState == uint(MemberState.Insured)) { return true; }
        }
        if (isOriginatorType(Originator.Underwriter)) {
            if (state == uint(MemberState.RequestInsurance) && newState == uint(MemberState.Insured)) {
                return hasBeenApproved();
            }
            if (state == uint(MemberState.RequestInsurance) && newState == uint(MemberState.Insured)) {
                return hasBeenRejected();
            }
        }

        return false;
    }

}
