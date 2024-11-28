# Cobo UCW SDK Flutter App

This project shows how to use Cobo's WaaS 2 APIs/SDKs to create a basic User-Controlled Wallets (UCW) Flutter App.

## How to Run the App Locally
1. Set Up Flutter: Make sure you have Flutter installed on your machine. If not, follow [the Flutter official documentation](https://flutter.dev/docs/get-started/install)

2. Run the App: Use the following commands in your terminal to fetch dependencies, and run the app:

```sh
fvm flutter pub get
fvm flutter run  
```

## Key Features of the App
1. Initial Setup:
   - User login
   - Install and initialize the UCW SDK
   - Create a vault and a Main Group
2. Wallet Management:
   - Create a wallet and generate an address
   - Perform transactions
   - Backup your secrets data

For detailed instructions, refer to the Cobo developer documentation [Get started with MPC Wallets](https://www.cobo.com/developers/v2/guides/mpc-wallets/get-started-ucw)

## Technical Details
1. WaaS API Usage: The app integrates with the [Cobo WaaS 2 Demo Server](https://github.com/CoboGlobal/cobo-fastapi-template) to leverage the WaaS API for various UCW wallet functionalities.
2. UCW SDK Integration: It uses the [Cobo UCW Flutter SDK](https://github.com/CoboGlobal/cobo-ucw-sdk-flutter) to manage the creation of the MPC Main Key group and execute web3 transaction signing seamlessly.
