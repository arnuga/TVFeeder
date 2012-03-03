using System;
using System.Data;
using System.Data.Common;
using System.Data.SQLite;
using System.Data.SqlClient;

namespace TVFeederLib
{
    public static class DatabaseManager
    {
        static string DatabaseFileName
        {
            get { return "TVFeeder.db"; }
        }
        static string FullPathAppDirectory
        {
            get
            {
                return System.IO.Path.Combine(new string[] {
                    Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),
                    TVFeederLib.Properties.Settings.Default.AppFolderName
                });
            }
        }
        static string FullPathDatabaseFile
        {
            get
            {
                return System.IO.Path.Combine(new string[] {
                    FullPathAppDirectory,
                    DatabaseFileName
                });
            }
        }
        static string DatabasePassword
        {
            get { return TVFeederLib.Properties.Settings.Default.DatabasePassword; }
        }
        static string DataSourceName
        {
            get { return "Data Source=" + FullPathDatabaseFile; }
        }

        public static void CreateDatabase()
        {
            SQLiteConnection.CreateFile(FullPathDatabaseFile);
            IDbConnection conn = Open();

            IDbCommand cmd = conn.CreateCommand();
            cmd.CommandText = "CREATE TABLE Feeds (" +
	                          "feed_id INTEGER PRIMARY KEY," +
	                          "name	TEXT," +
	                          "url TEXT," +
	                          "latest_scan DATE)";
            cmd.CommandType = CommandType.Text;
            cmd.ExecuteNonQuery();
            conn.Close();
        }
        public static IDbConnection Open()
        {
            SQLiteConnection conn = new SQLiteConnection(DataSourceName);
            conn.Open();

            return conn;
        }
        public static void InitializeDatabase()
        {
            if (!System.IO.Directory.Exists(FullPathAppDirectory))
                System.IO.Directory.CreateDirectory(FullPathAppDirectory);

            if (!System.IO.File.Exists(FullPathDatabaseFile))
                CreateDatabase(); 
        }
        public static void VacuumDatabase(IDbConnection conn)
        {
            if (conn == null)
                conn = Open();

            IDbCommand cmd = conn.CreateCommand();
            cmd.CommandType = CommandType.Text;
            cmd.CommandText = "vacuum";
            int iRet = cmd.ExecuteNonQuery();
        }
    }
}
