using System;
using System.Collections.Generic;

namespace TVFeederLib
{
    public class Feeder
    {
        private List<RssFeed> feeds;
        public Feeder()
        {
            feeds = new List<RssFeed>();
            LoadFeedList();
        }
        public List<String> FeedNames()
        {
            List<String> feed_names = new List<string>();
            feeds.ForEach(delegate(RssFeed feed)
            {
                feed_names.Add(feed.name);
            });

            return feed_names;
        }
        public List<String> FeedUrls()
        {
            List<String> feed_urls = new List<string>();
            feeds.ForEach(delegate(RssFeed feed)
            {
                feed_urls.Add(feed.url);
            });
            return feed_urls;
        }
        public void LoadFeedList()
        {
            foreach (string feed_info in TVFeederLib.Properties.Settings.Default.feeds)
            {
                string[] feed_parts = feed_info.Split(new Char [] { '|' });
                if (feed_parts.Length == 2)
                {
                    RssFeed newFeed = new RssFeed();
                    newFeed.name = feed_parts[0];
                    newFeed.url = feed_parts[1];
                    feeds.Add(newFeed);
                }
            }
        }
        public void SaveFeedList()
        {
            TVFeederLib.Properties.Settings.Default.feeds.Clear();
            feeds.ForEach(delegate(RssFeed feed)
            {
                TVFeederLib.Properties.Settings.Default.feeds.Add(string.Join("|", new string[] { feed.name, feed.url }));
            });
            TVFeederLib.Properties.Settings.Default.Save();
        }
        public void AddFeed(string name, string url)
        {
            RssFeed newFeed = new RssFeed();
            newFeed.name = name;
            newFeed.url = url;
            feeds.Add(newFeed);
        }
        public void RemoveFeed(string url)
        {
            feeds.ForEach(delegate(RssFeed feed)
            {
                if (feed.url.ToLower().CompareTo(url.ToLower()) == 0)
                {
                    feeds.Remove(feed);
                    return;
                }
            });
        }
        public string UrlFromName(string name)
        {
            for (int i = 0; i < feeds.Count; i++)
            {
                if (feeds[i].name.CompareTo(name) == 0)
                {
                    return feeds[i].url;
                }
            }
            return null;
        }
    }
}
