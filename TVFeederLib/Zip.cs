using System;
using System.IO.Compression;

namespace TVFeederLib
{
    public class Zip : IArchive
    {
        public bool ValidateArchive(string filePath)
        {
            return false;
        }
        public bool UncompressArchive(string filePath)
        {
            return true;
        }
    }
}
