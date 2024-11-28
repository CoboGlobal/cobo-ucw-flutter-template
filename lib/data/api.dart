import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:cobo_flutter_template/data/models/index.dart';

final _logger = Logger((ApiService).toString());

class ApiService {
  final String baseUrl;

  ApiService({this.baseUrl = "https://api.ucw-demo.sandbox.cobo.com/v1"});

  // Login
  // ==========
  Future<LoginToken?> login(String email) async {
    final url = '$baseUrl/users/login';
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'email': email});

    final response = await postRequest(url, headers, body);

    if (response.statusCode == 200) {
      return LoginToken.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Http failed to login: ${response.reasonPhrase}');
    }
  }

  // Get user info
  // ==========
  Future<UserInfo> getUserInfo(String loginToken) async {
    final url = '$baseUrl/users/info';
    final response = await getRequest(url, loginToken);

    if (response.statusCode == 200) {
      return UserInfo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Http failed to get user info: ${response.reasonPhrase}');
    }
  }

  // Initilize vault
  // ==========
  Future<Vault> initializeVault(String loginToken) async {
    final url = '$baseUrl/vaults/init';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $loginToken',
    };
    final response = await postRequest(url, headers, jsonEncode({}));

    if (response.statusCode == 200) {
      return Vault.fromJson(jsonDecode(response.body)["vault"]);
    } else {
      throw Exception(
          'Http failed to initialize vault: ${response.reasonPhrase}');
    }
  }

  // list main key group
  // ==========
  Future<MainGroup?> getMainGroup(
      String loginToken, String vaultId, int groupType) async {
    final url = '$baseUrl/vaults/$vaultId';

    final body = {"group_type": KeyGroupType.mainGroup.value};

    final response = await getRequest(url, loginToken, body);

    if (response.statusCode == 200) {
      List<Map<String, dynamic>> list = jsonDecode(response.body)["groups"];
      return MainGroup.fromJson(list[0]);
    } else {
      throw Exception(
          'Http failed to list main key group: ${response.reasonPhrase}');
    }
  }

  // generate main key group
  // ==========
  Future<String> generateMainKeyGroup(
      String loginToken, String vaultId, String nodeID) async {
    final url = '$baseUrl/vaults/$vaultId/tss/generate_main_group';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $loginToken',
    };

    final body = jsonEncode(
        {"vault_id": vaultId, "node_id": nodeID});

    final response = await postRequest(url, headers, body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["tss_request_id"];
    } else {
      throw Exception(
          'Http failed to generate main key group: ${response.reasonPhrase}');
    }
  }

  // Get tss request info
  // ==========
  Future<TssRequestInfo> getTssRequestInfo(
      String loginToken, String vaultId, String tssRequestId) async {
    final url = '$baseUrl/vaults/$vaultId/tss/requests/$tssRequestId';
    final response = await getRequest(url, loginToken);

    if (response.statusCode == 200) {
      dynamic tssRequest = jsonDecode(response.body)["tss_request"];
      if (tssRequest == null) {
        throw Exception('Http failed to get tss request info: request is null');
      }
      return TssRequestInfo.fromJson(tssRequest);
    } else {
      throw Exception(
          'Http failed to get tss request info: ${response.reasonPhrase}');
    }
  }

  // Create wallet
  // ==========
  Future<Wallet> createWallet(
      String loginToken, String vaultId, String walletName) async {
    final url = '$baseUrl/vaults/$vaultId/wallets';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $loginToken',
    };

    final body = jsonEncode({"name": walletName});

    final response = await postRequest(url, headers, body);

    if (response.statusCode == 200) {
      return Wallet.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Http failed to create wallet: ${response.reasonPhrase}');
    }
  }

  // Get wallet tokens
  // ==========
  Future<List<TokenInfo>> getWalletTokens(
      String loginToken, String walletId) async {
    final url = '$baseUrl/wallets/$walletId/tokens';
    final response = await getRequest(url, loginToken);

    if (response.statusCode == 200) {
      dynamic tokenInfoList = jsonDecode(response.body)["list"];
      return tokenInfoList.map((t) {
        return TokenInfo.fromJson(t);
      });
    } else {
      throw Exception(
          'Http failed to get wallet tokens: ${response.reasonPhrase}');
    }
  }

  // Create wallet address
  // ==========
  Future<WalletAddress> createWalletAddress(
      String loginToken, String walletId, String chainId) async {
    final url = '$baseUrl/wallets/$walletId/address';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $loginToken',
    };

    final body = jsonEncode({"chain_id": chainId});

    final response = await postRequest(url, headers, body);

    if (response.statusCode == 200) {
      return WalletAddress.fromJson(jsonDecode(response.body)["address"]);
    } else {
      throw Exception(
          'Http failed to create wallet address: ${response.reasonPhrase}');
    }
  }

  // list token address
  // ==========
  Future<TokenAddressInfo> getTokenAddressInfo(
      String loginToken, String walletId, String tokenId) async {
    final url = '$baseUrl/wallets/$walletId/tokens/$tokenId';
    final response = await getRequest(url, loginToken);

    if (response.statusCode == 200) {
      return TokenAddressInfo.fromJson(
          jsonDecode(response.body)['token_addresses']);
    } else {
      throw Exception(
          'Http failed to list token address: ${response.reasonPhrase}');
    }
  }

  // Query estimate fee
  // ==========
  Future<EstimateFee> queryEstimateFee(String loginToken, String walletId,
      TransactionParams transactionParams) async {
    final url = '$baseUrl/wallets/$walletId/transactions/estimate_fee';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $loginToken',
    };

    final body = transactionParams;

    final response = await postRequest(url, headers, body);

    if (response.statusCode == 200) {
      return EstimateFee.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          'Http failed to query estimate fee: ${response.reasonPhrase}');
    }
  }

  // Create transaction
  // ==========
  Future<String> createTransaction(
      String loginToken, String walletId, Object transactionParams) async {
    final url = '$baseUrl/wallets/$walletId/transactions';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $loginToken',
    };

    final body = transactionParams;

    final response = await postRequest(url, headers, body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["transaction_id"];
    } else {
      throw Exception(
          'Http failed to create transaction: ${response.reasonPhrase}');
    }
  }

  // Get transaction info
  // ==========
  Future<TransactionInfo> getTransactionInfo(
      String loginToken, String txId) async {
    final url = '$baseUrl/wallets/transactions/$txId';
    final response = await getRequest(url, loginToken);

    if (response.statusCode == 200) {
      return TransactionInfo.fromJson(jsonDecode(response.body)['transaction']);
    } else {
      throw Exception(
          'Http failed to list token address: ${response.reasonPhrase}');
    }
  }
}

Future<http.Response> getRequest(String url, String loginToken,
    [Map<String, dynamic>? queryParams]) async {
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $loginToken',
  };

  if (queryParams != null && queryParams.isNotEmpty) {
    url += '?${Uri(queryParameters: queryParams).query}';
  }

  _logger.info(
      'Http get start. url: $url, loginToken: $loginToken, queryParams: $queryParams');
  final response = await http.get(Uri.parse(url), headers: headers);
  _logger.info(
      'Http get end. code: ${response.statusCode}, response: ${response.body}');
  return response;
}

Future<http.Response> postRequest(
    String url, Map<String, String> headers, Object body) async {
  _logger.info('Http post start. url: $url, body: $body ');
  final response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: body,
  );
  _logger.info(
      'Http post end. $url, code: ${response.statusCode}, response: ${response.body}');
  return response;
}
