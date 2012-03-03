using System;

namespace TVFeederLib
{
    interface IArchive
    {
        bool ValidateArchive(string filePath);
        bool UncompressArchive(string filePath);
    }
}
