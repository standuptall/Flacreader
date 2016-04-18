using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.Windows.Forms;
namespace it.albe
{
    class Program
    {
        [STAThread]
        static void Main(string[] args)
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new Form1());
            
            /*Console.WriteLine(flacReader.getVendor());
            Console.WriteLine(flacReader.comments["TITLE"]);
            Console.WriteLine(flacReader.comments["ALBUM"]);
            Console.ReadLine();
            
            flacReader.setVendor("ciao mi chiamo alberto sto creando questo programma che e un flacreader");
            flacReader.addComment("ARTIST", "Bruce Springsteen");
            flacReader.addComment("ALBUM", "CIANOBATTERIO");
            flacReader.writeAll();*/
        }
    }
}
