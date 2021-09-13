// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Policy {

    enum policy_state {premium_due, active, claim_released, claimed, mature}
    policy_state public state;

    address payable insurer;
    address payable customerId;

    uint256 public start_time;
    uint256 public maturity_period;

    uint256 public premium;
    uint256 public amount;
    uint public maturity_amount;

    constructor (address payable _insurer, address payable _customerId, uint256 _maturity_period, uint256 _premium) payable{
        insurer = _insurer;
        customerId = _customerId;

        maturity_period = _maturity_period;

        premium = _premium;
        amount = 0;
        maturity_amount = msg.value;

        state = policy_state.premium_due;
    }

    function checkStatus() public returns (policy_state){
        if (block.timestamp >= start_time + maturity_period && state == policy_state.active) {
            state = policy_state.mature;
            amount = maturity_amount;
            maturity_amount = 0;
        }
        return state;
    }

    function pay_premium() public payable {
        require(
            state == policy_state.premium_due,
            "NoPremiumDue"
        );
        require(
            msg.value == premium,
            "PremiumValueDifferentThanSentAmount"
        );
        require(
            msg.sender == customerId,
            "PremiumMustBePayedByCustomerIdOnly"
        );
        state = policy_state.active;
        start_time = block.timestamp;
        insurer.transfer(msg.value);
    }

    function release_claim() public payable {
        require(
            state == policy_state.active,
            "PolicyNotActive"
        );
        require(
            msg.sender == insurer,
            "OnlyInsurerCanReleaseClaims"
        );
        state = policy_state.claim_released;
        amount = msg.value;
        insurer.transfer(maturity_amount);
    }

    function claim() public {
        require(
            state == policy_state.mature || state == policy_state.claim_released,
            "NoClaimReleased"
        );
        require(
            address(this).balance >= amount,
            "TechnicalIssue_ContactInsurer"
        );
        require(
            msg.sender == customerId,
            "OnlycustomerIdCanClaim"
        );

        customerId.transfer(amount);
        amount = 0;
        state = policy_state.claimed;
    }

    //getState , getPremium , getAmount not required , use default getters;
}


contract Policies {
    address payable insurer;

    enum genders {M, F, NB}
    struct customer {
        string first_name;
        string last_name;
        uint age;
        genders gender;
        bool valid;
    }

    mapping(address => customer) public customers;
    mapping(address => Policy[]) public policies; // maps customerId addresses to the addresses of policy contracts for that address;

    constructor() {
        insurer = payable(msg.sender);
    }

    function is_customer() public view returns(bool){
        if(customers[msg.sender].valid) return true;
        return false;
    }

    function new_customer(address payable _customerId, string calldata _first_name, string calldata _last_name, uint _age, genders _gender) public {
        require(
            msg.sender == insurer,
            "New Customer can only be instantiated by the Insurer"
        );
        customers[_customerId] = customer(_first_name, _last_name, _age, _gender , true);
    }

    function new_policy(address payable _customerId, uint256 _maturity_period, uint256 _premium) public payable {
        require(
            msg.sender == insurer,
            "New Policy can only be instantiated by the Insurer"
        );

        policies[_customerId].push((new Policy){value : msg.value}(insurer, _customerId, _maturity_period, _premium));
    }

    function get_policies() public view returns (Policy[] memory){
        return policies[msg.sender];
    }

    function get_policies(address _customerId) public view returns (Policy[] memory){
        require(
            msg.sender == insurer,
            "Unauthorized"
        );

        return policies[_customerId];
    }
}


