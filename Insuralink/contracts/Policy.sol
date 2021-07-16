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
    uint public amount;

    constructor(address payable _beneficiary, uint256 _maturity_period, uint256 _premium) {
        insurer = payable (msg.sender);
        beneficiary = _beneficiary;
        maturity_period = _maturity_period;
        premium = _premium;
        state = policy_state.premium_due;
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
        state = policy_state.active;
        premium = 0;
        insurer.transfer(msg.value);
    }

    function release_claim() public payable{
        require(
            state == policy_state.active,
            "PolicyNotActive"
        );
        state = policy_state.claim_released;
        premium = 0 ;
        amount = msg.value;
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

        beneficiary.transfer(amount);
        amount = 0;
        state = policy_state.claimed;
    }

    /*
    TODO: set constructor parameters in migrations OR create an init function for the insurer and set contructor vlaues to defaults(0/null).
    TODO: funtion checkSatus() - updates the status of policy according to time and returns the state.
    TODO: function changeBeneficiary() - set beneficiary to a different account.
    TODO: time based premiums - requires checkSatus() to implement. (also add a grace period)
    */
//getState , getPremium , getAmount not required , use default getters;
}
