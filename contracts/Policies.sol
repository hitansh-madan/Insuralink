// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Policy {

    enum policy_state {premium_due, active , claim_released , claimed , mature}
    policy_state public state;

    address payable insurer;
    address payable beneficiary;

    uint256 public start_time;
    uint256 public maturity_period;

    uint256 public premium;
    uint256 public amount;
    uint public maturity_amount;

    constructor (address payable _beneficiary, uint256 _maturity_period, uint256 _premium) payable{
        insurer = payable (msg.sender);
        beneficiary = _beneficiary;

        maturity_period = _maturity_period;

        premium = _premium;
        amount = 0;
        maturity_amount = msg.value;

        state = policy_state.premium_due;
    }

    function checkStatus() public returns(policy_state){
        if(block.timestamp >= start_time + maturity_period && state == policy_state.active){
            state = policy_state.mature;
            amount = maturity_amount;
            maturity_amount = 0;
        }
        return state;
    }

    function pay_premium() public payable{
        require(
            state == policy_state.premium_due,
            "NoPremiumDue"
        );
        require(
            msg.value == premium,
            "PremiumValueDifferentThanSentAmount"
        );
        require(
            msg.sender == beneficiary,
            "PremiumMustBePayedByBeneficiary"
        );
        state = policy_state.active;
        start_time = block.timestamp;
        insurer.transfer(msg.value);
    }

    function release_claim() public payable{
        require(
            state == policy_state.active,
            "PolicyNotActive"
        );
        require(
            msg.sender == insurer,
            "OnlyInsurerCanReleaseClaims"
        );
        state = policy_state.claim_released;
        amount = amount + msg.value;
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
            msg.sender == beneficiary,
            "OnlyBeneficiaryCanClaim"
        );

        beneficiary.transfer(amount);
        amount = 0;
        state = policy_state.claimed;
    }

    /*
    TODO: set constructor parameters in migrations OR create an init function for the insurer and set constructor values to defaults(0/null).
    TODO: function checkStatus() - updates the status of policy according to time and returns the state.
    TODO: function changeBeneficiary() - set beneficiary to a different account.
    TODO: time based premiums - requires checkStatus() to implement. (also add a grace period)
    */
    //getState , getPremium , getAmount not required , use default getters;
}



contract Policies {
    address public insurer;
    mapping (address => Policy[]) public policies; // maps beneficiary addresses to the addresses of policy contracts for that address;

    constructor() {
        insurer = msg.sender;
    }

    function new_policy(address payable _beneficiary, uint256 _maturity_period, uint256 _premium) public{
        require(
            msg.sender == insurer ,
            "New Policy can only be instantiated by the Insurer"
        );

        policies[_beneficiary].push(new Policy(_beneficiary, _maturity_period, _premium));
    }

    function get_policies() public view returns(Policy[] memory){
        return policies[msg.sender];
    }

    function get_policies(address _beneficiary) public view returns(Policy[] memory){
        require(
            msg.sender == insurer,
            "Unauthorized"
        );

        return policies[_beneficiary];
    }
}

