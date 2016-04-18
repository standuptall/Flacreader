using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

namespace it.albe
{
    /*
     * 
     * TODO: devo implementare la creazione di vorbis_comment per file che non ce l'hanno
     */
    public class FlacReader
    {
        public static string vendor_string;
        public static Int32 user_comment_list_length;
        private string filepath;
        private class _metadata {
            public struct _streaminfo
            {
                public bool presente;
                public const int code = 0x0;
                public bool ultimo;
            }
            public struct _padding
            {
                public bool presente;
                public const int code = 0x1;
                public bool ultimo;
            }
            public struct _application
            {
                public bool presente;
                public const int code = 0x2;
                public bool ultimo;
            }
            public struct _seektable
            {
                public bool presente;
                public const int code = 0x3;
                public bool ultimo;
            }
            public struct _vorbis_comment
            {
                public bool presente;
                public const int code = 0x4;
                public bool ultimo;
            }
            public struct _cuesheet
            {
                public bool presente;
                public const int code = 0x5;
                public bool ultimo;
            }
            public struct _picture
            {
                public bool presente;
                public const int code = 0x6;
                public bool ultimo;
            }

            public _streaminfo streaminfo;
            public _padding padding;
            public _application application;
            public _seektable seektable;
            public _vorbis_comment vorbis_comment;
            public _cuesheet cuesheet;
            public _picture picture;
            public const int ending_metadata_code = 0xF0;
            const int NUM_METADATA = 7;
            public _metadata()
            {
                streaminfo.presente = false;
                streaminfo.ultimo = false;
                padding.presente = false;
                padding.ultimo = false;
                application.presente = false;
                application.ultimo = false;
                seektable.presente = false;
                seektable.ultimo = false;
                vorbis_comment.presente = false;
                vorbis_comment.ultimo = false;
                cuesheet.presente = false;
                cuesheet.ultimo = false;
                picture.presente = false;
                picture.ultimo = false;
            }
            public void setMetadata(int code)
            {
                switch ((code<<1)>>1)  //tolgo il bit più significativo
                {
                    case _streaminfo.code: streaminfo.presente = true; break;
                    case _padding.code: padding.presente = true; break;
                    case _application.code: application.presente = true; break;
                    case _seektable.code: seektable.presente = true; break;
                    case _vorbis_comment.code: vorbis_comment.presente = true; break;
                    case _cuesheet.code: cuesheet.presente = true; break;
                    case _picture.code: picture.presente = true; break;
                }
            }
            public int getFlag(int flag)  //devo controllare se è l'ultimo, così setto il bit più significativo a 1
            {
                flag = ((flag << 1) >> 1); //tolgo il bit più significtivo
                if (picture.presente)
                    picture.ultimo = true;
                else if (cuesheet.presente)
                    cuesheet.ultimo = true;
                else if (vorbis_comment.presente)
                    vorbis_comment.ultimo = true;
                else if (seektable.presente)
                    seektable.ultimo = true;
                else if (application.presente)
                    application.ultimo = true;
                else if (padding.presente)
                    padding.ultimo = true;
                else if (streaminfo.presente)
                    streaminfo.ultimo = true;
                switch (flag)
                {
                    case _streaminfo.code: if (streaminfo.presente) flag += ending_metadata_code; break;
                    case _padding.code: if (streaminfo.presente) flag += ending_metadata_code; break;
                    case _application.code: if (streaminfo.presente) flag += ending_metadata_code; break;
                    case _seektable.code: if (streaminfo.presente) flag += ending_metadata_code; break;
                    case _vorbis_comment.code: if (streaminfo.presente) flag += ending_metadata_code; break;
                    case _cuesheet.code: if (streaminfo.presente) flag += ending_metadata_code; break;
                    case _picture.code: if (streaminfo.presente) flag += ending_metadata_code; break;
                }
                return flag;
            }
        } ;
        _metadata metadata;
        private int metadata_comments_length;
        public Dictionary<string,string> comments;
        public Dictionary<string, string> metadataDict;
        public System.Data.DataTable metadataInfo;
        public FlacReader(string filepath)
        {
            metadata_comments_length = 0;
            metadata = new _metadata();  //oggetto che memorizza se sono presenti o no metadata specifici
            comments = new Dictionary<string, string>();
            metadataDict = new Dictionary<string, string>();
            metadataInfo = new System.Data.DataTable();
            this.filepath = filepath;
            user_comment_list_length = 0;
            FileStream stream;
            stream = File.OpenRead(filepath);
            if (stream == null)
                throw new FileNotFoundException("Il file non esiste");
            byte[] array = {0,0,0,0};
            stream.Read(array,0,4);
            if (!((array[0]==0x66)&&(array[1]==0x4C)&&(array[2]==0x61)&&(array[3]==0x43)))   //fLaC
                throw new Exception("Il file non è un file flac!");
            byte flag;
            do 
            {
                stream.Read(array,0,1);  //mi sposto di 1 byte
                flag = array[0];
                metadata.setMetadata(flag);
                stream.Read(array, 0, 3);  //leggo tre byte per la lunghezza del metadata
                Int32 metadata_length = array[0] * 65536 + array[1] * 256 + array[2];
                string metaName;
                switch (flag)
                {
                    case 0: metaName = "STREAMINFO"; break;
                    case 1: metaName = "PADDING"; break;
                    case 2: metaName = "APPLICATION"; break;
                    case 3: metaName = "SEEKTABLE"; break;
                    case 4: metaName = "VORBIS_COMMENT"; break;
                    case 5: metaName = "CUESHEET"; break;
                    case 6: metaName = "PICTURE"; break;
                    default: metaName = "UNKNOWN"; break;
                }
                metadataDict[metaName] = String.Format("{0,8}", Convert.ToString(flag, 2)).Replace(" ","0");
                if (flag == 4 || flag == 132)   //se è un vorbis comment cioè 00000100 oppure 10000100
                {
                    metadata_comments_length = metadata_length;
                    caricaCommenti(stream);
                }
                else
                    stream.Seek(metadata_length, SeekOrigin.Current); //mi sposto della lunghezza del metadata
            } while (!((flag>>7)==0x1)); //se il bit più significativo è uguale a uno vuol dire ch enon ci sono più metadata
            stream.Close();
        }
        public void setVendor(string vendorName)
        {
            int vendor_string_length_old = vendor_string.Length;  
            metadata_comments_length -= vendor_string_length_old;//tolgo la lunghezza iniziale
            vendor_string = vendorName;
            metadata_comments_length += vendor_string.Length;  //e metto la nuova lunghezza del vendor string
        }
        public string getVendor()
        {
            return vendor_string;
        }
        public void addComment(string field, string value)
        {
            try
            {
                if (comments[field] != null)   //se il commento già esiste
                {
                    string val = comments[field];
                    metadata_comments_length -= (field.Length + val.Length + 1);   //tolgo la lunghezza originaria
                    metadata_comments_length -= 4;
                }
            }
            catch(KeyNotFoundException e)
            {
                comments[field] = value;
                user_comment_list_length++;
                metadata_comments_length += 4; //aggiungo 4 byte per memorizzare la lunghezza del comment sul file
                metadata_comments_length += field.Length + value.Length + 1;  //aggiungo la lunghezza del commento più il simbolo uguale
            }
            
            
        }
        public void writeAll()  //file esistente quindi riverso il contenuto su un file _temp
        {
            FileStream stream,streamWrite;
            stream = File.OpenRead(filepath);
            streamWrite = File.OpenWrite(filepath + "_temp");
            byte[] array = { 0, 0, 0, 0 };
            stream.Read(array, 0, 4);
            streamWrite.Write(array, 0, 4);
            byte flag;
            do
            {
                stream.Read(array, 0, 1);  //mi sposto di 1 byte
                streamWrite.Write(array, 0, 1);  //mi sposto di 1 byte
                flag = array[0];
                stream.Read(array, 0, 3);  //leggo tre byte per la lunghezza del metadata
                Int32 metadata_length = array[0] * 65536 + array[1] * 256 + array[2];
                if (flag == 4 || flag == 132)  //se è un vorbis comment cioè 00000100 oppure 10000100
                {
                    stream.Seek(metadata_length, SeekOrigin.Current); //mi sposto sul lettore della lunghezza del metadata
                    array[0] = (byte) (metadata_comments_length >> 16);
                    array[1] = (byte) (metadata_comments_length >> 8);
                    array[2] = (byte)(metadata_comments_length);
                    streamWrite.Write(array, 0, 3);  //scrivo la nuova lunghezza del metadata
                    scriviCommenti(streamWrite);
                }
                else
                {
                    streamWrite.Write(array, 0, 3);  //scrivo la lunghezza del metadata
                    int i = 0;
                    for (i = 0; (i+4)< metadata_length; i+=4)
                    {
                        stream.Read(array, 0, 4);
                        streamWrite.Write(array, 0, 4);
                    }
                    /* scrivo i byte rimanenti */
                    stream.Read(array, 0, metadata_length-i);
                    streamWrite.Write(array, 0, metadata_length -i);
                }
            } while (!((flag >> 7) == 0x1)); //se il bit più significativo è uguale a uno vuol dire ch enon ci sono più metadata
            /* scrivo tutto il rimanente */
            byte[] chunk = new byte[10240];
            
               
            int num = 0;
            while (true)
            {
                num = stream.Read(chunk, 0, 10240);
                streamWrite.Write(chunk, 0, num);
                if (num < 10240)
                {
                    stream.Close();
                    streamWrite.Close();
                    return;
                }
            }
            
        }
        public void writeAll(String filename)  //nuovo file
        {
        }
        private void caricaCommenti(Stream stream)
        {
            byte[] array = { 0, 0, 0, 0 };
            stream.Read(array, 0, 4);
            uint vendor_length = (uint)((array[0]));  //non capisco perché ma conta solo il primo byte
            byte[] stringa = new byte[1024];
            stream.Read(stringa, 0, (int)vendor_length);
            vendor_string = System.Text.Encoding.UTF8.GetString(stringa,0,(int)vendor_length);
            stream.Read(array, 0, 4); //leggo il numero dei commenti
            uint number_of_comments = (uint)array[0];
            for (uint i = 0; i < number_of_comments; i++)
            {
                stream.Read(array, 0, 4); //leggo il numero di caratteri da leggere
                uint comment_length = (uint)array[0];
                stream.Read(stringa, 0, (int)comment_length);
                String comment = System.Text.Encoding.UTF8.GetString(stringa, 0,(int) comment_length);
                comments[comment.Split('=')[0]] = comment.Split('=')[1];
                Array.Clear(stringa, 0, stringa.Length);
            }
        }
        private void scriviCommenti(Stream stream)
        {
            Int32 length = vendor_string.Length;
            byte[] array = { 0, 0, 0, 0 };
            array[0] = (byte)(length);
            array[1] = 0;
            array[2] = 0;
            array[3] = 0;
            stream.Write(array, 0, 4);
            byte[] arrayName = System.Text.Encoding.UTF8.GetBytes(vendor_string.ToCharArray());
            stream.Write(arrayName, 0, length);
            byte numcommenti = (byte)comments.Count;
            array[0] = (byte)(numcommenti);
            stream.Write(array, 0, 4);
            /* scrivo i commenti */
            foreach (KeyValuePair<string, string> entry in comments)
            {
                string comment = entry.Key + "=" + entry.Value;
                length = comment.Length;
                arrayName = System.Text.Encoding.UTF8.GetBytes(comment.ToCharArray());
                array[0] = (byte)length;
                array[1] = 0;
                array[2] = 0;
                array[3] = 0;
                stream.Write(array, 0, 4);
                stream.Write(arrayName, 0, length);
            }
        }
    }
}
