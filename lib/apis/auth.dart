import 'package:http/http.dart' as http;

Future<http.Response?> getDataWithPost(String urlStr, dynamic body) async {
  final url = Uri.parse(urlStr);
  try {
    final response = await http.post(
      url,
      headers: {
        'accesstoken': 'miheer',  // Access token header
      },
      body: body,
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      return null;
    }
  } catch (error) {
    return null;
  }
}
