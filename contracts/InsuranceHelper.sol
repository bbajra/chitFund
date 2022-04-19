pragma solidity ^0.6.8;

// This function will pull the chitfunds (previous) associated to the member if any.


contract InsuranceHelper {

    struct ChitFund {
        string name;
    }

    ChitFund[] public chitFunds;

    mapping (uint => address) public chitFundToMember;
    mapping (address => uint) memberChitFundCount;

    function getChitFundsByMember(address _member) external view returns(uint[] memory) {
        uint[] memory result = new uint[](memberChitFundCount[_member]);
        uint counter = 0;
        for (uint i = 0; i < member.length; i++) {
            if (chitFundToMember[i] == _member) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }
}

// Need to intergrate it with insurance smart contract 
// also need to add to checklist before underwriter take decisson on approving or rejecting the member. 
