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
    public partial class TVFeederMainForm : Form
    {
        FeedsForm feedsForm;
        public TVFeederMainForm()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            InitializeApplication();
        }

        private void notifyIcon1_DoubleClick(object sender, EventArgs e)
        {
            MessageBox.Show("Double clicked the notify icon");
        }

        private void notifyIcon1_Click(object sender, EventArgs e)
        {
            MessageBox.Show("Single clicked the notify icon");
        }

        private void showsToolStripMenuItem_Click(object sender, EventArgs e)
        {

        }

        private void feedsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (feedsForm == null)
                feedsForm = new FeedsForm();

            feedsForm.Show();
        }

        void InitializeApplication()
        {
            TVFeederLib.DatabaseManager.InitializeDatabase();
            TVFeederLib.DatabaseManager.Open();
        }
    }
}
