import 'package:web3dart/credentials.dart';
enum policy_state { premium_due, active, claim_released, claimed, mature }

class Policy {
  Policy(this.state, this.insurer, this.customerId, this.startTime,
      this.maturityPeriod, this.premium, this.amount, this.maturityAmount);

  policy_state? state;
  EthereumAddress? insurer;
  EthereumAddress? customerId;

  int? startTime;
  int? maturityPeriod;

  int? premium;
  int? amount;
  int? maturityAmount;

  factory Policy.fromResponse(List<dynamic> response) {
    List<policy_state> states = policy_state.values;
    return Policy(
        states[response[0]],
        response[1],
        response[2],
        response[3],
        response[4],
        response[5],
        response[6],
        response[7]
    );
  }
}
