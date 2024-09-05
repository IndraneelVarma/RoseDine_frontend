class Config {
  static const String baseUrl = 'http://localhost:8081';

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

  static String getUrl(String endpointKey, [Map<String, String>? params]) {
    String endpoint = endpoints[endpointKey] ?? '';
    if (params != null) {
      params.forEach((key, value) {
        endpoint = endpoint.replaceAll('{$key}', value);
      });
    }
    return baseUrl + endpoint;
  }
}