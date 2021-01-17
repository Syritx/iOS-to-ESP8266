using System.Net;
using System.Net.Sockets;
using System.Threading.Tasks;
using System.Text;

using System.Collections.Generic;

namespace iphone_esp_server {

    class Server {
        
        Socket serverSocket;
        List<Socket> clientSockets = new List<Socket>();

        bool[] places = {
            false,
            false
        };

        public Server(IPAddress iP, int port) {
            serverSocket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            IPEndPoint iPEndPoint = new IPEndPoint(iP, port);
            serverSocket.Bind(iPEndPoint);
            serverSocket.Listen(5);

            ReceiveAndAcceptClients();
        }

        void LocalClientThread(Socket client) {
            bool isConnected = true;
            int id = 0;

            for (int i = 0; i < places.Length; i++) {
                if (places[i] == false) {
                    places[i] = true;
                    id = i+1;
                    break;
                }
            }
            if (id == 0) isConnected = false;

            while (isConnected) {

                byte[] bytes = new byte[2048];
                client.Receive(bytes);

                string command = Encoding.UTF8.GetString(bytes);
                System.Console.WriteLine(command);

                if (command.StartsWith("disconnect_ed")) {
                    System.Console.WriteLine("disconnected");
                    isConnected = false;
                    places[id-1] = false;
                    break;
                }

                if (command.StartsWith("[get_data]")) {
                    if (id-1 == 0) SendToDesignatedClient(1, "get-data");
                    else SendToDesignatedClient(0, "get-data");
                }

                if (command.StartsWith("[to_iphone]")) {
                    if (id-1 == 0) SendToDesignatedClient(1, command);
                    else SendToDesignatedClient(0, command);
                }
            }
            client.Close();
        }

        void SendToDesignatedClient(int id, string message) {
            try {
                clientSockets[id].Send(Encoding.UTF8.GetBytes(message));
            }
            catch(System.Exception e) {}
        }

        void ReceiveAndAcceptClients() {
            while (true) {
                Socket client = serverSocket.Accept();
                clientSockets.Add(client);
                System.Console.WriteLine("connected");
                Task.Run(() => LocalClientThread(client));
            }
        }
    }
}