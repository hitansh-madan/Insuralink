// create a class that handles all blockchain operations
// homepage wrapped by userBloc
// userBloc uses this class to get data and make object of user model from json response
// user repo in other blocs in not required (not removed yet)

import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class UserService{

  UserService(EthPrivateKey privateKey){
    apiUrl = "http://localhost:7545"; //Replace with your API
    httpClient = new Client();
    ethClient = new Web3Client(apiUrl, httpClient);
    credentials = ethClient.credentialsFromPrivateKey(privateKey);
  }

  var apiUrl;
  var httpClient;
  var ethClient;
  var credentials;
  
}