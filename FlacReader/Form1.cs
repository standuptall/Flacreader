using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace it.albe
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void buttonFile_Click(object sender, EventArgs e)
        {
            try
            {
                FileDialog dialog = new OpenFileDialog();
                if (dialog.ShowDialog() == DialogResult.OK)
                    textBoxFile.Text = dialog.FileName;
                caricaFile();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
                textBoxFile.Text = "";
            }
            
        }
        private void caricaFile()
        {
            if (textBoxFile.Text == "")
                return;
            FlacReader flacReader = new FlacReader(textBoxFile.Text);
            DataTable data = new DataTable();
            data.Columns.Add("comment");
            data.Columns.Add("value");
            foreach (KeyValuePair<string, string> entry in flacReader.comments)
            {
                DataRow row = data.NewRow();
                row[0] = entry.Key;
                row[1] = entry.Value;
                data.Rows.Add(row);
            }
            dataGridView1.DataSource = data;
            data = new DataTable();
            data.Columns.Add("Metadata");
            data.Columns.Add("Code");
            foreach (KeyValuePair<string, string> entry in flacReader.metadataDict)
            {
                DataRow row = data.NewRow();
                row[0] = entry.Key;
                row[1] = entry.Value;
                data.Rows.Add(row);
            }
            dataGridView2.DataSource = data;
        }

        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }

        private void button1_Click(object sender, EventArgs e)
        {
            DataTable data = (DataTable)dataGridView1.DataSource;
            FlacReader flacReader = new FlacReader(textBoxFile.Text);
            foreach (DataRow row in data.Rows)
            {
                flacReader.addComment(row[0].ToString(), row[1].ToString());
            }
            flacReader.writeAll();
        }
    }
}
