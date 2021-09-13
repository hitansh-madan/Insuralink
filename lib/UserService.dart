import 'dart:io';

import 'package:Insuralink/models/Policy.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web3dart/credentials.dart';
import 'package:path/path.dart' show join, dirname;


const String rpcUrl = 'http://localhost:7545';
final File abiFile = File(join(dirname(Platform.script.path), 'abi.json'));
final EthereumAddress policiesAddress = EthereumAddress.fromHex('0x00');


class UserService{

  UserService._init(EthPrivateKey privateKey) {
    web3Client = new Web3Client(rpcUrl, Client());
    credentials = web3Client.credentialsFromPrivateKey(privateKey);
  }

  var web3Client;
  var credentials;
  var abiCode ;
  var contract ;

  var policies = EthereumAddress.fromHex('0x00');


  static Future<UserService> init(EthPrivateKey privateKey) async {
    var component = UserService._init(privateKey);

    component.abiCode = await abiFile.readAsString();
    component.contract = DeployedContract(ContractAbi.fromJson(component.abiCode, 'Policies'), policiesAddress);

    return component;
  }

  Future<bool> isCustomer() async{
    final result = await web3Client.call(
      sender:credentials.extractAddress(),
      contract:contract,
      function: contract.function('is_customer') ,
      params:[]
    );
    return result.first;
  }

  Future<List> getPolicies() async{
    final result = await web3Client.call(
        sender:credentials.extractAddress(),
        contract:contract,
        function: contract.function('get_policies') ,
        params:[]
    );
    return result.first;
  }

  Future<List> getCustomer() async{
    var customer = await web3Client.call(
      sender:credentials.extractAddress() ,
      contract:contract,
      function:contract.function('customers'),
      params : [],
    );
    return customer;
  }

  Future<Policy> getPolicy(EthereumAddress policyAddress) async{
    List<dynamic> response = List.filled(8, '');
    var contract = DeployedContract(ContractAbi.fromJson(await abiFile.readAsString(), 'Policy'), policyAddress);
    response[0] = await web3Client.call(
      sender:credentials.extractAddress() ,
      contract:contract,
      function:contract.function('state'),
      params : [],
    );
    response[1] = await web3Client.call(
      sender:credentials.extractAddress() ,
      contract:contract,
      function:contract.function('insurer'),
      params : [],
    );
    response[2] = await web3Client.call(
      sender:credentials.extractAddress() ,
      contract:contract,
      function:contract.function('customerId'),
      params : [],
    );
    response[3] = await web3Client.call(
      sender:credentials.extractAddress() ,
      contract:contract,
      function:contract.function('start_time'),
      params : [],
    );
    response[4] = await web3Client.call(
      sender:credentials.extractAddress() ,
      contract:contract,
      function:contract.function('maturity_period'),
      params : [],
    );
    response[5] = await web3Client.call(
      sender:credentials.extractAddress() ,
      contract:contract,
      function:contract.function('premium'),
      params : [],
    );
    response[6] = await web3Client.call(
      sender:credentials.extractAddress() ,
      contract:contract,
      function:contract.function('amount'),
      params : [],
    );
    response[7] = await web3Client.call(
      sender:credentials.extractAddress() ,
      contract:contract,
      function:contract.function('maturity_amount'),
      params : [],
    );
    return Policy.fromResponse(response);
  }

  Future<policy_state> checkStatus(EthereumAddress policyAddress) async{
    var contract = DeployedContract(ContractAbi.fromJson(await abiFile.readAsString(), 'Policy'), policyAddress);
    List<policy_state> states = policy_state.values;
    var response = await web3Client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: contract.function('checkStatus'),
        parameters: [],
      ),
    );

    return states[response];
  }

  void claim (EthereumAddress policyAddress) async{
    var contract = DeployedContract(ContractAbi.fromJson(await abiFile.readAsString(), 'Policy'), policyAddress);

    await web3Client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: contract.function('claim'),
        parameters: [],
      ),
    );
  }

  void payPremium (EthereumAddress policyAddress) async{
    var contract = DeployedContract(ContractAbi.fromJson(await abiFile.readAsString(), 'Policy'), policyAddress);

    EtherAmount premium = await web3Client.call(
      sender:credentials.extractAddress() ,
      contract:contract,
      function:contract.function('premium'),
      params : [],
    );

    await web3Client.sendTransaction(
      credentials,
      Transaction.callContract(
        value: premium,
        contract: contract,
        function: contract.function('payPremium'),
        parameters: [],
      ),
    );
  }

}