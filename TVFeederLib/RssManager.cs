using System;
using System.Collections.Generic;
using System.Xml;
using System.Net;
using System.Data;

namespace TVFeederLib
{
    public static class RssManager
    {
        public static List<RSSFeedItem> ReadFeed(string url)
        {
            List<RSSFeedItem> rssFeedItems = new List<RSSFeedItem>();
            HttpWebRequest rssFeed = (HttpWebRequest)WebRequest.Create(url);

            using (DataSet rssData = new DataSet())
            {
                rssData.ReadXml(rssFeed.GetResponse().GetResponseStream());

                foreach (DataRow dataRow in rssData.Tables["item"].Rows)
                {
                    RSSFeedItem rssItem = new RSSFeedItem(Convert.ToString(dataRow["title"]));
                        rssItem.ChannelId = Convert.ToInt32(dataRow["channel_id"]);
                        rssItem.Description = Convert.ToString(dataRow["description"]);
                        rssItem.ItemId = Convert.ToInt32(dataRow["item_id"]);
                        rssItem.Link = Convert.ToString(dataRow["link"]);
                        rssItem.PublishDate = Convert.ToDateTime(dataRow["pubDate"]);
                        rssItem.Title = Convert.ToString(dataRow["title"]);
                    rssFeedItems.Add(rssItem);
                }
            }

            return rssFeedItems;
        }
    }
}
