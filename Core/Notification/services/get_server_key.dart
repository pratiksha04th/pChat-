import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis_auth/auth_io.dart';
class GetServerKey {

  final privateKey = dotenv.env['PRIVATE_KEY'];
  final privateKeyId = dotenv.env['PRIVATE_KEY_ID'];
  final clientId = dotenv.env['CLIENT_ID'];
  final tokenUri = dotenv.env['TOKEN_URI'];
  final authUri = dotenv.env['AUTH_URI'];
  Future<String> getServerKeyToken() async {
    try {
      final scopes = [
        'https://www.googleapis.com/auth/firebase.messaging',
        'https://www.googleapis.com/auth/firebase.database',

      ];
      final client = await clientViaServiceAccount
        (ServiceAccountCredentials.fromJson(
        {"type": "service_account",
          "project_id": "pchat-cc35c",
          "private_key_id": privateKeyId,
          "private_key": privateKey,
          "client_email": "firebase-adminsdk-fbsvc@pchat-cc35c.iam.gserviceaccount.com",
          "client_id": clientId,
          "auth_uri": authUri,
          "token_uri": tokenUri,
          "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40pchat-cc35c.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"},
      ), scopes,
      );
      final accessServerKey = client.credentials.accessToken.data;
      return accessServerKey;
    }
    catch (e, stack) {
      print(e);
      print(stack);
      return "";
    }
  }
}