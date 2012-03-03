using System;
using System.Collections.Generic;
using NUnrar.Archive;

namespace TVFeederLib
{
    class Rar : IArchive
    {
        public bool ValidateArchive(string filePath)
        {
            if (filePath.Length > 0)
            {
                if (System.IO.File.Exists(filePath))
                {
                    return RarArchive.IsRarFile(filePath) ? true : false;
                }
            }

            return false;
        }
        public bool UncompressArchive(string filePath)
        {
            if (ValidateArchive(filePath))
            {
                RarArchive archive = FirstArchiveForFile(filePath);
                foreach (RarArchiveEntry entry in archive.Entries)
                {
                    entry.WriteToDirectory(System.IO.Path.GetDirectoryName(filePath));
                }
            }

            return true;
        }
        RarArchive FirstArchiveForFile(string filePath)
        {
            if (ValidateArchive(filePath))
            {
                RarArchive archive = RarArchive.Open(filePath);
                return FirstArchiveForArchive(archive);
            }
            return null;
        }
        RarArchive FirstArchiveForArchive(RarArchive archive)
        {
            if (!archive.IsFirstVolume())
            {
                return archive;
            }

            if (!archive.IsFirstVolume())
            {
                return FirstArchiveForVolumes(archive.Volumes);
            }
            return null;
        }
        RarArchive FirstArchiveForVolumes(ICollection<RarArchiveVolume> volumes)
        {
            foreach (RarArchiveVolume vol in volumes)
            {
                if (vol.IsFirstVolume)
                {
                    return RarArchive.Open(vol.VolumeFile.FullName);
                }
            }
            return null;
        }
        bool ValidateAllVolumes(string filePath)
        {
            if (System.IO.File.Exists(filePath))
            {
                if (!RarArchive.IsRarFile(filePath))
                {
                    RarArchive archive = RarArchive.Open(filePath);
                    foreach (RarArchiveVolume vol in archive.Volumes)
                    {
                        if (!ValidateArchive(vol.VolumeFile.FullName))
                            return false;
                    }
                }
            }
            return true;
        }
    }
}
