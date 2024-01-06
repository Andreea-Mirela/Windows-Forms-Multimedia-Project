using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Oracle.DataAccess.Types;
using Oracle.DataAccess.Client;
using System.IO;

namespace WindowsFormsApp1
{
    public partial class Form1 : Form
    {
        OracleConnection oracleConnection;

        public Form1()
        {
            InitializeComponent();
        }

        //creare conexiune
        private void btnConnection_Click(object sender, EventArgs e)
        {
            string connectionString = "User ID=stud_stanciua; Password=STUDENT; Data Source=(DESCRIPTION=" +
            "(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=37.120.249.41)(PORT=1521)))" +
            "(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=orcls)));";
            oracleConnection = new OracleConnection(connectionString);

           // MessageBox.Show("Conexiune Stabilita!");
        }

        //procedura de inserare
        private void btnInserareInvestitie_Click(object sender, EventArgs e)
        {
            btnConnection_Click(sender, e);
            try
            {
                oracleConnection.Open();
            }
            catch (OracleException ex)
            {
                MessageBox.Show(ex.Message);
            }

            OracleCommand oracleCommand = new OracleCommand("PROCEDURA_INSERARE", oracleConnection);
            oracleCommand.CommandType = CommandType.StoredProcedure;

            oracleCommand.Parameters.Add("v_id", OracleDbType.Int32);
            oracleCommand.Parameters.Add("v_tip", OracleDbType.Varchar2, 255);
            oracleCommand.Parameters.Add("v_data_investitie", OracleDbType.Varchar2, 255);
            oracleCommand.Parameters.Add("nume_fisier", OracleDbType.Varchar2, 255);

            oracleCommand.Parameters[0].Value = Convert.ToInt32(tbIdCaine.Text);
            oracleCommand.Parameters[1].Value = tbRasaCaine.Text;
            oracleCommand.Parameters[2].Value = tbDataNastereCaine.Text;
            oracleCommand.Parameters[3].Value = tbFisier.Text;

            try
            {
                oracleCommand.ExecuteNonQuery();
            }
            catch (OracleException ex)
            {
                MessageBox.Show("Eroare! - " + ex.Message);
            }

            oracleConnection.Close();
        }
        //procedura afisare
        private void btnAfisareInvestitie_Click(object sender, EventArgs e)
        {
            btnConnection_Click(sender, e);
            try
            {
                oracleConnection.Open();
            }
            catch (OracleException ex)
            {
                MessageBox.Show(ex.Message);
            }

            OracleCommand oracleCommand = new OracleCommand("PROCEDURA_AFISARE", oracleConnection);
            oracleCommand.CommandType = CommandType.StoredProcedure;

            oracleCommand.Parameters.Add("v_id",OracleDbType.Int32);
            oracleCommand.Parameters.Add("flux", OracleDbType.Blob);

            oracleCommand.Parameters[0].Direction = ParameterDirection.Input;
            oracleCommand.Parameters[1].Direction = ParameterDirection.Output;

            oracleCommand.Parameters[0].Value = Convert.ToInt32(tbIdAfisareCaine.Text);

            try
            {
                oracleCommand.ExecuteScalar();
            }
            catch (OracleException ex)
            {
                MessageBox.Show(ex.Message);
            }

            OracleBlob temp = (OracleBlob)oracleCommand.Parameters[1].Value;


            pictureBox1.Image = Image.FromStream((System.IO.Stream)temp);

            oracleConnection.Close();
        }
        //procedura export
        private void btnExportInvestitie_Click(object sender, EventArgs e)
        {
            btnConnection_Click(sender, e);
            try
            {
                oracleConnection.Open();
            }
            catch (OracleException ex)
            {
                MessageBox.Show(ex.Message);
            }

            OracleCommand oracleCommand = new OracleCommand("PROCEDURA_EXPORT", oracleConnection);
            oracleCommand.CommandType = CommandType.StoredProcedure;

            oracleCommand.Parameters.Add("v_id", OracleDbType.Int32);
            oracleCommand.Parameters.Add("nume_fisier", OracleDbType.Varchar2, 255);

            oracleCommand.Parameters[0].Value = Convert.ToInt32(tbExportId.Text);
            oracleCommand.Parameters[1].Value = tbExportFisier.Text;

            try
            {
                oracleCommand.ExecuteNonQuery();
            }
            catch (OracleException ex)
            {
                MessageBox.Show("Eroare! - " + ex.Message);
            }

            oracleConnection.Close();
        }

        //generare semnaturi
        private void btnGenerareSemnaturi_Click(object sender, EventArgs e)
        {
            btnConnection_Click(this, null);
            oracleConnection.Open();
            OracleCommand oracleCommand = new OracleCommand("PROCEDURA_GENERARE_SEMNATURI", oracleConnection);
            oracleCommand.CommandType = CommandType.StoredProcedure;
            try
            {
                oracleCommand.ExecuteNonQuery();
            }
            catch (OracleException ex)
            {
                MessageBox.Show(ex.Message);
            }

            oracleConnection.Close();
            MessageBox.Show("Semnatura generata cu succes!");
        }
        //recunoastere semnatica (regasire)
        private void btnRecunoastereSemantica_Click(object sender, EventArgs e)
        {
            btnConnection_Click(this, null);
            try
            {
                oracleConnection.Open();
            }
            catch (OracleException ex)
            {
                MessageBox.Show(ex.Message);
            }
            OracleCommand cmd = new OracleCommand("regasire", oracleConnection);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("nfis", OracleDbType.Varchar2);
            cmd.Parameters.Add("cculoare", OracleDbType.Decimal);
            cmd.Parameters.Add("ctextura", OracleDbType.Decimal);
            cmd.Parameters.Add("cforma", OracleDbType.Decimal);
            cmd.Parameters.Add("clocatie", OracleDbType.Decimal);
            cmd.Parameters.Add("idrez", OracleDbType.Int32);


            for (int i = 0; i < 5; i++)
            {
                cmd.Parameters[i].Direction = ParameterDirection.Input;
            }

            cmd.Parameters[5].Direction = ParameterDirection.Output;
            cmd.Parameters[0].Value = tbFisierCautat.Text;
            cmd.Parameters[1].Value = Convert.ToDecimal(tbCoefCuloare.Text);
            cmd.Parameters[2].Value = Convert.ToDecimal(tbCoefTextura.Text);
            cmd.Parameters[3].Value = Convert.ToDecimal(tbCoefForma.Text);
            cmd.Parameters[4].Value = Convert.ToDecimal(tbCoefLocatie.Text);
            try
            {
                cmd.ExecuteScalar();
            }
            catch (OracleException ex)
            {
                MessageBox.Show(ex.Message);

            }
            tbAfisareRecunoastereSemantica.Text = cmd.Parameters[5].Value.ToString();
            oracleConnection.Close();

        }

        //video
        private void btnVideo_Click(object sender, EventArgs e)
        {
            this.btnConnection_Click(sender, e);

            try
            {
                oracleConnection.Open();
            }
            catch (OracleException ex)
            {
                MessageBox.Show(ex.Message);
            } 

            OracleCommand oracleCommand = new OracleCommand("PROCEDURA_AFISARE_VIDEO", oracleConnection);
            oracleCommand.CommandType = CommandType.StoredProcedure;
            oracleCommand.Parameters.Add("v_id", OracleDbType.Int32);
            oracleCommand.Parameters.Add("flux", OracleDbType.Blob);
            oracleCommand.Parameters[0].Direction = ParameterDirection.Input;
            oracleCommand.Parameters[1].Direction = ParameterDirection.Output;
            oracleCommand.Parameters[0].Value = Convert.ToInt32(tbIdVideo.Text);
            try
            {
                oracleCommand.ExecuteScalar();
            }
            catch (OracleException ex)
            {
                MessageBox.Show(ex.Message);
            }

            Byte[] blob = new Byte[((OracleBlob)oracleCommand.Parameters[1].Value).Length];
            FileStream fileStream = null;
            try
            {
                ((OracleBlob)oracleCommand.Parameters[1].Value).Read(blob, 0, blob.Length);
            }
            catch(InvalidCastException ex)
            {
                MessageBox.Show(ex.Message);
            }
            fileStream = new FileStream("C:\\Users\\Mirela\\Desktop\\PROIECT FINAL BAZE DE DATE MULTIMEDIA\\media\\film1.avi", FileMode.Create, FileAccess.ReadWrite);
            fileStream.Write(blob, 0, blob.Length);
            fileStream.Close();
            oracleConnection.Close();

            axWindowsMediaPlayer1.URL = "C:\\Users\\Mirela\\Desktop\\PROIECT FINAL BAZE DE DATE MULTIMEDIA\\media\\film1.avi";
            axWindowsMediaPlayer1.Ctlcontrols.play();
        }

        private void Form1_Load(object sender, EventArgs e)
        {

        }

        private void tabPage1_Click(object sender, EventArgs e)
        {

        }

        private void button1_Click(object sender, EventArgs e)
        {
            string connectionString = "User ID=stud_stanciua; Password=STUDENT; Data Source=(DESCRIPTION=" +
            "(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=37.120.249.41)(PORT=1521)))" +
            "(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=orcls)));";
            oracleConnection = new OracleConnection(connectionString);

            // MessageBox.Show("Conexiune Stabilita!");

        }
    }
}
