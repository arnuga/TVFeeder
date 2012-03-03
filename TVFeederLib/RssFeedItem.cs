using System;
using System.Text.RegularExpressions;

namespace TVFeederLib
{
    public class RSSFeedItem
    {
        public string ShowName { get; set; }
        public int SeasonNumber { get; set; }
        public int EpisodeNumber { get; set; }
        public string Format { get; set; }
        public bool IsProper { get; set; }
        public bool IsRePack { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string Link { get; set; }
        public int ItemId { get; set; }
        public DateTime PublishDate { get; set; }
        public int ChannelId { get; set; }

        public RSSFeedItem(string original_title)
        {
            Match match = Regex.Match(original_title, @"(.*)\s*\d+[xe]\d+\.*", RegexOptions.IgnoreCase);

            if (match.Success)
            {
                if (match.Captures.Count > 0)
                {
                    ShowName = match.Groups[1].Value;
                    ShowName = Regex.Replace(ShowName, @"s0", string.Empty, RegexOptions.IgnoreCase);
                    ShowName = Regex.Replace(ShowName, @"\s*$", string.Empty, RegexOptions.IgnoreCase);
                }

                match = Regex.Match(original_title, @"(\d+)[xe](\d+)", RegexOptions.IgnoreCase);
                if (match.Success)
                {
                    int sNumber, eNumber;
                    Int32.TryParse(match.Groups[1].Value, out sNumber);
                    Int32.TryParse(match.Groups[2].Value, out eNumber);
                    SeasonNumber = sNumber;
                    EpisodeNumber = eNumber;
                }
            }
            else
            {
            }

            match = Regex.Match(original_title, @"(.*)\s*\d+[xe]\d+\.*", RegexOptions.IgnoreCase); // will match How I Met Your Mother S07E18 HDTV x264-LOL
            match = Regex.Match(original_title, @"(.*)\s*(\d{4}).(\d{2}).(\d{2})", RegexOptions.IgnoreCase); // will match Attack.of.the.Show.2012.02.27.HDTV XviD-Eclipse
            match = Regex.Match(original_title, @"(.*)\s*(\d{2}).(\d{2}).(\d{2})", RegexOptions.IgnoreCase); // will match HTVOD - America s Got Talent Starts - 02 22 12
        }

        public string zShowName()
        {
            string showName = string.Empty;
            string show_name_pattern = @"(.*)\s*([0-9]+)[xe]([0-9]+)\.*";
            Match match = Regex.Match(Title, show_name_pattern, RegexOptions.IgnoreCase);
            if (match.Success)
            {
                if (match.Captures.Count > 0)
                {
                    showName = match.Groups[1].Value;
                    showName = Regex.Replace(showName, "s0\\s*$", string.Empty);
                    showName = Regex.Replace(showName, "\\.", string.Empty);
                }
            }
            return showName;
        }
        public int zSeasonNumber()
        {
            int sNumber = -1;
            string show_name_pattern = @".*\s*([0-9]+)[xe][0-9]+\.*";
            Match match = Regex.Match(Title, show_name_pattern, RegexOptions.IgnoreCase);
            if (match.Success)
            {
                if (match.Captures.Count > 0)
                {
                    string seasonNumber = match.Groups[1].Value;
                    Int32.TryParse(seasonNumber, out sNumber);
                    return sNumber;
                }
            }
            return sNumber;
        }
        public int zEpisodeNumber()
        {
            int eNumber = -1;
            string show_name_pattern = @".*\s*[0-9]+[xe]([0-9]+)\.*";
            Match match = Regex.Match(Title, show_name_pattern, RegexOptions.IgnoreCase);
            if (match.Success)
            {
                if (match.Captures.Count > 0)
                {
                    string episodeNumber = match.Groups[1].Value;
                    Int32.TryParse(episodeNumber, out eNumber);
                    return eNumber;
                }
            }
            return eNumber;
        }
        public string zFormat()
        {
            string format = string.Empty;
            string format_pattern = @"(\d{3,4}[i|p])";
            Match match = Regex.Match(Title, format_pattern, RegexOptions.IgnoreCase);
            if (match.Success)
            {
                if (match.Captures.Count > 0)
                {
                    format = match.Captures[0].Value;
                }
            }
            return format;
        }
        public bool zIsProper()
        {
            bool is_proper = false;
            Match match = Regex.Match(Title, @"(proper)", RegexOptions.IgnoreCase);
            if (match.Success)
            {
                if (match.Captures.Count > 0)
                {
                    is_proper = true;
                }
            }
            return is_proper;
        }
        public bool zIsRePack()
        {
            bool isRePack = false;
            Match match = Regex.Match(Title, @"repack", RegexOptions.IgnoreCase);
            if (match.Success)
            {
                if (match.Captures.Count > 0)
                {
                    isRePack = true;
                }
            }
            return isRePack;
        }
    }
}
