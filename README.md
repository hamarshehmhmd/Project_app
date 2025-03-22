# Hape VPN

A Flutter VPN application with SOCKS5 Proxy Chains for enhanced privacy and security.

## Features

- OpenVPN connection support
- Multiple server locations worldwide
- Proxy chains for multi-hop privacy
- Killswitch functionality
- Data usage tracking
- Dark and light theme support

## Setup

### Prerequisites

- Flutter SDK 3.7.2 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / Xcode for mobile development
- Supabase account for backend services

### Installation

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Configure your Supabase credentials in `lib/infrastructure/supabase/supabase_config.dart`
4. Run the app with `flutter run`

## VPN Implementation

This app uses the `flutter_openvpn` package to establish VPN connections. The implementation is located in:

- `lib/infrastructure/vpn/vpn_service.dart` - Core VPN service implementation
- `lib/domain/usecases/vpn_usecases.dart` - Business logic for VPN operations
- `lib/presentation/providers/vpn_provider.dart` - State management for VPN

### Setting up OpenVPN

1. You'll need to obtain or generate OpenVPN configuration files for your servers
2. For iOS, you'll need to set up a Network Extension:
   - Update the `providerBundleIdentifier` in `vpn_service.dart` with your app's bundle ID + ".network-extension"
   - Configure the Network Extension entitlements in Xcode

3. For Android, ensure the required permissions are added to the manifest

## Proxy Chain Implementation

The proxy chain functionality is implemented using the 3proxy open-source proxy server. The implementation is in:

- `lib/infrastructure/proxy/proxy_chain_implementation.dart` - Core proxy chain implementation
- `lib/infrastructure/proxy/proxy_chain_service.dart` - Service layer for proxy chain operations
- `lib/presentation/providers/proxy_provider.dart` - State management for proxy chains
- `lib/presentation/screens/proxy/proxy_chain_screen.dart` - UI for managing proxy chains

### Setting up Proxy Chains

1. You'll need to obtain the 3proxy binary:

   - Download from [https://github.com/3proxy/3proxy/releases](https://github.com/3proxy/3proxy/releases)
   - Place in `assets/binaries/3proxy`
   - Ensure the binary is compiled for the target platforms (iOS/Android)

2. Update the pubspec.yaml to include the binary assets:

   ```yaml
   flutter:
     assets:
       - assets/images/
       - assets/animations/
       - assets/icons/
       - assets/binaries/
   ```

3. For iOS, you'll need to add entitlements for executing binaries:
   - Enable "Allow Arbitrary Loads" in Info.plist
   - Add the necessary entitlements for executing code

4. For Android, ensure the app has the necessary permissions:
   - `INTERNET`
   - `ACCESS_NETWORK_STATE`
   - `FOREGROUND_SERVICE`

## Finding Public Proxies

The app can use the following sources to find public SOCKS5 proxies:

1. ProxyScrape API: [https://api.proxyscrape.com](https://api.proxyscrape.com)
2. Proxy-List API: [https://www.proxy-list.download](https://www.proxy-list.download)
3. GeoNode API: [https://proxylist.geonode.com/api](https://proxylist.geonode.com/api)

Note: Public proxies may be unreliable or insecure. For a production app, it's recommended to use your own private proxy servers.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
