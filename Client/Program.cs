using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Net;
using System.Net.Sockets;
using System.Net.NetworkInformation;

namespace verk1
{
    class Program
    {
        static TcpClient tcpClient;
        static NetworkStream networkStream;
        static void Main(string[] args)
        {
            ConnectToServer();
            while (true) WhileConnected();
        }

        static void WhileConnected()
        {
            string command = Console.ReadLine();
            byte[] writeBuffer = Encoding.UTF8.GetBytes(command);
            networkStream.Write(writeBuffer, 0, writeBuffer.Length);

            if (command == "") return;
            while (true)
            {
                bool state = tcpClient.Client.Connected;
                if (!state)
                {
                    Console.WriteLine("con closed");
                }
                if (networkStream.DataAvailable)
                {

                    try
                    {

                        byte[] bytes = new byte[1024];
                        networkStream.Read(bytes, 0, 1024);
                        
                        string data = Encoding.UTF8.GetString(bytes);
                        Console.WriteLine("Server response:" + System.Environment.NewLine + "{0}", data);
                        return;

                    }
                    catch
                    {
                        Console.WriteLine("No message received");                               
                    }
                }
                
                
            }
        }

        static void ConnectToServer()
        {
            Console.WriteLine("Start of connect function");

            tcpClient = new TcpClient();

            //IPAddress ipAddress = Dns.GetHostEntry("tsuts.tskoli.is/2t/0812003270").AddressList[0];
            IPAddress ipAddress = IPAddress.Parse("10.220.226.70");
            try
            {
                tcpClient.Connect(ipAddress, 1103);
                networkStream = tcpClient.GetStream();
                networkStream.ReadTimeout = 5000; // Mili secs
                Console.WriteLine("Connected to " + ipAddress.ToString());
            }
            catch (Exception ex)
            {
                Console.WriteLine("Failed to connect: {0}", ex.ToString());
            }
            

            //networkStream.Close();
            //tcpClient.Close();
        }

    }

}
