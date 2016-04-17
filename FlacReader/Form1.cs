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
            FileDialog dialog = new OpenFileDialog();
            if (dialog.ShowDialog() == DialogResult.OK)
                textBoxFile.Text = dialog.FileName;
            caricaFile();
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
        }

        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }
    }
}
