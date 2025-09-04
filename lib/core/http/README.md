# HTTP Client

A comprehensive HTTP client built on top of Dio with organized method mixins and type-safe responses.

## Structure

```
lib/core/http/
├── base_http_client.dart     # Main HTTP client with all methods
├── http_client.dart          # Original comprehensive client
├── http_response.dart        # Type-safe response wrapper
├── methods/                  # Individual HTTP method mixins
│   ├── get_method.dart       # GET operations
│   ├── post_method.dart      # POST operations
│   ├── put_method.dart       # PUT operations
│   ├── patch_method.dart     # PATCH operations
│   ├── delete_method.dart    # DELETE operations
│   └── utility_methods.dart  # HEAD, OPTIONS, download, etc.
└── http.dart                 # Main exports
```

## Basic Usage

```dart
import 'package:celestia/core/http/http.dart';

// Create client
final client = BaseHttpClient(
  baseUrl: 'https://api.example.com',
  headers: {'User-Agent': 'MyApp/1.0'},
);

// GET request
final response = await client.get<Map<String, dynamic>>('/users/1');

// Handle response
response.when(
  success: (data) => print('User: ${data['name']}'),
  error: (message, statusCode) => print('Error: $message'),
);

// Cleanup
client.dispose();
```

## Specialized Clients

```dart
// API client with authentication
final apiClient = BaseHttpClient.api(
  baseUrl: 'https://api.example.com',
  apiKey: 'your_key',
);

// JSON client
final jsonClient = BaseHttpClient.json(
  baseUrl: 'https://api.example.com',
);

// Form data client
final formClient = BaseHttpClient.formData(
  baseUrl: 'https://upload.example.com',
);
```

## HTTP Methods

### GET
```dart
// Basic GET
await client.get<String>('/data');

// GET with JSON parsing
await client.getJson<User>('/users/1', User.fromJson);

// GET list
await client.getList<User>('/users', User.fromJson);

// GET bytes
await client.getBytes('/image.jpg');
```

### POST
```dart
// POST JSON
await client.postJson<User>('/users', userData);

// POST form data
await client.postForm<Response>('/submit', formData);

// File upload
await client.postFile<Response>('/upload', '/path/to/file.jpg');

// Multiple files
await client.postFiles<Response>('/upload', ['/file1.jpg', '/file2.png']);
```

### PUT & PATCH
```dart
// PUT update
await client.putJson<User>('/users/1', updatedData);

// PATCH partial update
await client.patchPartial<User>('/users/1', {
  'name': 'New Name',
});

// PATCH by ID
await client.patchById<User>('/users', '1', updates);
```

### DELETE
```dart
// DELETE
await client.delete<void>('/users/1');

// DELETE by ID
await client.deleteById<void>('/users', '1');

// DELETE multiple
await client.deleteMultiple<void>('/users', ['1', '2', '3']);
```

### Utilities
```dart
// Check if reachable
final isReachable = await client.ping('/health');

// Check if exists
final exists = await client.exists('/users/1');

// Get content length
final size = await client.getContentLength('/file.zip');

// Download file
await client.download('/file.zip', '/local/path.zip');
```

## Configuration

```dart
// Update base URL
client.updateBaseUrl('https://new-api.example.com');

// Set headers
client.setAuthorizationHeader('your_token');
client.setApiKeyHeader('your_key');
client.setUserAgent('MyApp/2.0');

// Update timeouts
client.setTimeout(
  connectTimeout: Duration(seconds: 30),
  receiveTimeout: Duration(seconds: 60),
);

// Add interceptors
client.addInterceptor(CustomInterceptor());
```

## Response Handling

```dart
final response = await client.get<User>('/users/1');

// Pattern matching
response.when(
  success: (user) => print('Name: ${user.name}'),
  error: (message, code) => print('Error $code: $message'),
);

// Transform data
final nameResponse = response.map((user) => user.name);

// Chain operations
final result = response.chain((user) => 
  client.get<List<Post>>('/users/${user.id}/posts')
);

// Get data with fallback
final user = response.dataOr(User.empty());
```

## Error Handling

```dart
if (response.isError) {
  print('Status: ${response.statusCode}');
  print('Message: ${response.userFriendlyMessage}');
  
  if (response.isNetworkError) {
    // Handle network issues
  } else if (response.isServerError) {
    // Handle server errors
  }
}
```

## Request Cancellation

```dart
final cancelToken = client.createCancelToken();

final response = await client.get('/data', cancelToken: cancelToken);

// Cancel if needed
cancelToken.cancel('User cancelled');

// Cancel all requests
client.cancelRequests('App shutdown');
```
