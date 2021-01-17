# iOS-to-ESP8266
using an iOS device, I could make an app that can connect to a server which can get data from the ESP8266

## 1. Start server
- dotnet run Program.cs

## 2. Connect the app with the server
- build the app from Xcode to the iPhone
- press the Connect button

## 3. Connect the ESP8266 to the server
- rshell --port 'port' repl
- import main
- main.connect()
- main.p_button()

## 4. Press the Request Data Button
