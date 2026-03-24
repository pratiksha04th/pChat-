import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis_auth/auth_io.dart';
class GetServerKey {

  final privateKey = dotenv.env['PRIVATE_KEY'];
  final privateKeyId = dotenv.env['PRIVATE_KEY_ID'];
  final clientId = dotenv.env['CLIENT_ID'];
  final tokenUri = dotenv.env['TOKEN_URI'];
  final authUri = dotenv.env['AUTH_URI'];
  final projectId = dotenv.env['PROJECT_ID'];
  final clientEmail = dotenv.env['CLIENT_EMAIL'];
  final authProviderX509CertUrl = dotenv.env['AUTH_PROVIDER_X509_CERT_URL'];
  final clientX509CertUrl = dotenv.env['CLIENT_X509_CERT_URL'];
  final universeDomain = dotenv.env['UNIVERSE_DOMAIN'];

  Future<String> getServerKeyToken() async {
    try {
      final scopes = [
        'https://www.googleapis.com/auth/firebase.messaging',
        'https://www.googleapis.com/auth/firebase.database',

      ];
      final client = await clientViaServiceAccount
        (ServiceAccountCredentials.fromJson(
        {"type": "service_account",
          "project_id": projectId,
          "private_key_id": privateKeyId,
          "private_key": privateKey,
          "client_email": clientEmail,
          "client_id": clientId,
          "auth_uri": authUri,
          "token_uri": tokenUri,
          "auth_provider_x509_cert_url": authProviderX509CertUrl,
          "client_x509_cert_url": clientX509CertUrl,
          "universe_domain": universeDomain},
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