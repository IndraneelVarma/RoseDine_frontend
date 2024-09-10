class Config {
  // Base URL from the Environment class or fallback to localhost
  static String baseUrl = Environment.baseUrl;

  // All API endpoints
  static const Map<String, String> endpoints = {
    'login': '/api/users/login',
    'register': '/api/users/register',
    'verifyEmail': '/api/users/verify-email',
    'menuItems': '/api/menu-items',
    'userRating': '/api/reviews/{menuItemId}/user-rating',
    'sendReview': '/api/reviews/{menuItemId}',
    'recommendations': '/api/recommendations',
    'notifications': '/api/get-notifications',
    'userPreferences': '/api/user-preferences/get-preferences',
    'updateDietaryRestriction': '/api/user-preferences/update-dietary-restriction',
    'updateMacro': '/api/user-preferences/update-macro',
  };

  // Generate URL for the API endpoint, replacing parameters if provided
  static String getUrl(String endpointKey, [Map<String, String>? params]) {
    String endpoint = endpoints[endpointKey] ?? '';

    // Replace parameters in the URL path
    if (params != null) {
      params.forEach((key, value) {
        if (endpoint.contains('{$key}')) {
          endpoint = endpoint.replaceAll('{$key}', value);
        }
      });

      // Append remaining params as query parameters
      var queryParams = params.entries
          .where((entry) => !endpoint.contains('{${entry.key}}'))
          .map((entry) => '${entry.key}=${Uri.encodeComponent(entry.value)}')
          .join('&');

      if (queryParams.isNotEmpty) {
        endpoint += (endpoint.contains('?') ? '&' : '?') + queryParams;
      }
    }

    return baseUrl + endpoint;
  }
}

class Environment {
  // Retrieve the BASE_URL from --dart-define, or use a default
  static String get baseUrl => const String.fromEnvironment('BASE_URL', defaultValue: 'http://localhost:8080');
}
