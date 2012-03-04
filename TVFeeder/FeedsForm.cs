using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Threading;
using System.Net;

namespace TVFeeder
{
    public partial class FeedsForm : Form
    {
        private static string currentFeedUrl;
        private static List<TVFeederLib.RSSFeedItem> feedItems;
        BackgroundWorker feedLoaderWorker;

        public FeedsForm()
        {
            InitializeComponent();

            feedLoaderWorker = new BackgroundWorker();
            feedLoaderWorker.DoWork += new DoWorkEventHandler(feedLoaderWorker_DoWork);
            feedLoaderWorker.RunWorkerCompleted += new RunWorkerCompletedEventHandler(feedLoaderWorker_RunWorkerCompleted);
            feedLoaderWorker.ProgressChanged += new ProgressChangedEventHandler(feedLoaderWorker_ProgressChanged);
            feedLoaderWorker.WorkerReportsProgress = true;
        }
        void feedLoaderWorker_ProgressChanged(object sender, ProgressChangedEventArgs e)
        {
            statusProgressBar.Value = e.ProgressPercentage;
        }
        void feedLoaderWorker_RunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
        {
            dataGridView1.Rows.Clear();
            int total = FeedsForm.feedItems.Count + 20;
            int current = 20;
            foreach (TVFeederLib.RSSFeedItem item in FeedsForm.feedItems)
            {
                string[] rowData = {
                                           item.ShowName,
                                           item.SeasonNumber.ToString(),
                                           item.EpisodeNumber.ToString(),
                                           item.Format,
                                           item.IsProper.ToString(),
                                           item.IsRePack.ToString(),
                                           item.Title
                                       };
                dataGridView1.Rows.Add(rowData);
                current += 1;
                //feedLoaderWorker.ReportProgress((current * 100) / total);
            }

            button3.Enabled = true;
            Cursor.Current = Cursors.Default;
        }
        void feedLoaderWorker_DoWork(object sender, DoWorkEventArgs e)
        {
            if (FeedsForm.currentFeedUrl != null)
            {
                List<TVFeederLib.RSSFeedItem> rssFeedItems = new List<TVFeederLib.RSSFeedItem>();
                HttpWebRequest rssFeed = (HttpWebRequest)WebRequest.Create(FeedsForm.currentFeedUrl);

                using (DataSet rssData = new DataSet())
                {
                    try
                    {
                        rssData.ReadXml(rssFeed.GetResponse().GetResponseStream());
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show("An error occured reading the RSS feed: ", ex.Message);
                        return;
                    }
                    int total = rssData.Tables["item"].Rows.Count;
                    int current = 0;
                    foreach (DataRow dataRow in rssData.Tables["item"].Rows)
                    {
                        TVFeederLib.RSSFeedItem rssItem = new TVFeederLib.RSSFeedItem(Convert.ToString(dataRow["title"]));
                        rssItem.ChannelId = Convert.ToInt32(dataRow["channel_id"]);
                        rssItem.Description = Convert.ToString(dataRow["description"]);
                        rssItem.ItemId = Convert.ToInt32(dataRow["item_id"]);
                        rssItem.Link = Convert.ToString(dataRow["link"]);
                        rssItem.PublishDate = Convert.ToDateTime(dataRow["pubDate"]);
                        rssItem.Title = Convert.ToString(dataRow["title"]);
                        rssFeedItems.Add(rssItem);
                        current++;
                        feedLoaderWorker.ReportProgress((current * 100) / total);
                    }
                }

                FeedsForm.feedItems = rssFeedItems;
            }
        }

        private void FeedsForm_Load(object sender, EventArgs e)
        {
            IDbConnection conn = TVFeederLib.DatabaseManager.Open();
            IDbCommand cmd = conn.CreateCommand();
            cmd.CommandText = "select name from feeds";
            IDataReader reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                cbCurrentFeeds.Items.Add(reader.GetString(0));
            }
            reader.Close();
            conn.Close();
            cbCurrentFeeds.SelectedIndex = 0;
        }

        private void comboBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
        }

        private void button1_Click(object sender, EventArgs e)
        {
            string FeedName = tbNewFeedName.Text;
            string FeedUrl = tbNewFeedUrl.Text;

            IDbConnection conn = TVFeederLib.DatabaseManager.Open();
            IDbTransaction transaction = conn.BeginTransaction();
            IDbCommand cmd = conn.CreateCommand();
            cmd.Transaction = transaction;
            cmd.CommandText = "select feed_id, name from feeds where name = '" + FeedName + "'";
            IDataReader reader = cmd.ExecuteReader();
            if (reader.Read())
            {
                MessageBox.Show("A feed with this name already exists.");
            }
            else
            {
                reader.Close();
                cmd.CommandText = "insert into feeds (name, url) values ('" +
                                  FeedName + "', '" + FeedUrl + "')";
                cmd.ExecuteNonQuery();
                transaction.Commit();
                MessageBox.Show("Feed Added");
                tbNewFeedName.Text = string.Empty;
                tbNewFeedUrl.Text = string.Empty;
            }
            conn.Close();
        }

        private void button2_Click(object sender, EventArgs e)
        {
            string name = (string)cbCurrentFeeds.SelectedItem;
            IDbConnection conn = TVFeederLib.DatabaseManager.Open();
            IDbTransaction transaction = conn.BeginTransaction();
            IDbCommand cmd = conn.CreateCommand();
            cmd.CommandText = "delete from feeds where name = '" + name + "'";
            int iNumRows = cmd.ExecuteNonQuery();

            if (iNumRows < 1)
            {
                MessageBox.Show("More then 1 record found");
                transaction.Rollback();
            }

            if (iNumRows > 1)
            {
                MessageBox.Show("Failed to remove record");
                transaction.Rollback();
            }

            if (iNumRows == 1)
            {
                transaction.Commit();
                cbCurrentFeeds.Items.Remove(name);
                cbCurrentFeeds.SelectedIndex = 0;
                MessageBox.Show("Feed removed");
            }
            conn.Close();
        }

        private void button3_Click(object sender, EventArgs e)
        {
            Cursor.Current = Cursors.WaitCursor;
            string name = (string)cbCurrentFeeds.SelectedItem;

            IDbConnection conn = TVFeederLib.DatabaseManager.Open();
            IDbCommand cmd = conn.CreateCommand();
            cmd.CommandText = "select url from feeds where name = '" + name + "'";
            IDataReader reader = cmd.ExecuteReader();

            reader.Read();
            FeedsForm.currentFeedUrl = reader.GetString(0);
            reader.Close();
            conn.Close();
            if (FeedsForm.currentFeedUrl != null)
            {
                feedLoaderWorker.RunWorkerAsync();
            }

            button3.Enabled = false;
        }
    }
}