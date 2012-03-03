using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace TVFeeder
{
    public partial class FeedsForm : Form
    {
        public FeedsForm()
        {
            InitializeComponent();
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

        private void LoadCurrentFeed()
        {
            string name = (string)cbCurrentFeeds.SelectedItem;

            IDbConnection conn = TVFeederLib.DatabaseManager.Open();
            IDbCommand cmd = conn.CreateCommand();
            cmd.CommandText = "select url from feeds where name = '" + name + "'";
            IDataReader reader = cmd.ExecuteReader();

            reader.Read();
            string url = reader.GetString(0);
            reader.Close();
            conn.Close();

            if (url != null)
            {
                List<TVFeederLib.RSSFeedItem> feedItems = TVFeederLib.RssManager.ReadFeed(url);

                dataGridView1.Rows.Clear();
                foreach (TVFeederLib.RSSFeedItem item in feedItems)
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
                }
            }
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
            LoadCurrentFeed();
        }
    }
}
