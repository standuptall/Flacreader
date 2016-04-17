using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

namespace it.albe
{
    class Program
    {
        static void Main(string[] args)
        {
            FlacReader flacReader = new FlacReader("Hallelujah.flac");
            /*Console.WriteLine(flacReader.getVendor());
            Console.WriteLine(flacReader.comments["TITLE"]);
            Console.WriteLine(flacReader.comments["ALBUM"]);
            Console.ReadLine();
            */
            flacReader.setVendor("ciao mi chiamo alberto sto creando questo programma che e un flacreader");
            flacReader.addComment("ARTIST", "Bruce Springsteen");
            flacReader.addComment("ALBUM", "CIANOBATTERIO");
            flacReader.writeAll();
        }
    }
}
