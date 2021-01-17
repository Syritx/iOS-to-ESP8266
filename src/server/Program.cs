using System;
using System.Net;

namespace iphone_esp_server
{
    class Program
    {
        static void Main(string[] args)
        {
            new Server(Dns.GetHostEntry(Dns.GetHostName()).AddressList[0], 6060);
        }
    }
}
