/* Copyright 2015 John Guerreiro
**
* Pantheon-Submarine is free software: you can redistribute it
* and/or modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation, either version 3 of the
* License, or (at your option) any later version.
*
* Pantheon-Submarine is distributed in the hope that it will be
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with Hello Again. If not, see http://www.gnu.org/licenses/.
*/

using Gtk;
using Posix;

// project version=0.1

public class PantheonSubmarine : Window
{

    private const string[] PROVIDER_TABLE = {"-s os ", "-s pn ", "-s bd ", "-s dx ", "-s es ", "-s db " };
    public bool[] provider_bool = { true, true , false, false, false, false};
    private string language_text = "";

    public PantheonSubmarine() {
        this.title = "Pantheon-Submarine";
        this.set_border_width (5);
        this.set_position (Gtk.WindowPosition.CENTER);
        this.set_default_size(200 , 200);
        this.destroy.connect (Gtk.main_quit);
        var grid = new Grid();

        grid.set_row_spacing(4);
        grid.set_column_spacing(2);
        this.add(grid);

        var provider_label = new Gtk.Label ("Providers");
        grid.attach(provider_label, 0, 0, 1, 1);

        var listbox = new ListBox();
        grid.attach(listbox, 0, 1, 1, 3);

        var os_button = new Gtk.CheckButton.with_label ("OpenSubtitles");    
        listbox.insert(os_button, -1);
        os_button.set_active(true);
        os_button.toggled.connect (() => {
            if (os_button.active) {
                provider_bool[0] = true;
            } else {
                provider_bool[0] = false;
            }
        });

        var pn_button = new Gtk.CheckButton.with_label ("Podnapisi");  
        listbox.insert(pn_button, -1);
        pn_button.set_active(true);
        pn_button.toggled.connect (() => {
            if (pn_button.active) {
                provider_bool[1] = true;
            } else {
                provider_bool[1] = false;
            }
        });  

        var bd_button = new Gtk.CheckButton.with_label ("Bierdopje");    
        listbox.insert(bd_button, -1);
        bd_button.toggled.connect (() => {
            if (bd_button.active) {
                provider_bool[2] = true;
            } else {
                provider_bool[2] = false;
            }
        });  

        var dx_button = new Gtk.CheckButton.with_label ("DivXsubs");    
        listbox.insert(dx_button, -1);
        dx_button.toggled.connect (() => {
            if (dx_button.active) {
                provider_bool[3] = true;
            } else {
                provider_bool[3] = false;
            }
        });  

        var es_button = new Gtk.CheckButton.with_label ("Subtitulos.es");    
        listbox.insert(es_button, -1);
        es_button.toggled.connect (() => {
            if (es_button.active) {
                provider_bool[4] = true;
            } else {
                provider_bool[4] = false;
            }
        });  

        var db_button = new Gtk.CheckButton.with_label ("SubDB");    
        listbox.insert(db_button, -1);
        db_button.toggled.connect (() => {
            if (db_button.active) {
                provider_bool[5] = true;
            } else {
                provider_bool[5] = false;
            }
        });  

        var language_label = new Gtk.Label ("Language");
        grid.attach(language_label, 1, 0, 1, 1);
        var langinput = new Entry();
        langinput.set_placeholder_text("Language codes in terminal");
        langinput.changed.connect (() => {
            language_text = langinput.get_text();
        });  
        grid.attach(langinput, 1, 1, 1, 1);

        var save_button = new Button.with_label("Save Settings");
        save_button.clicked.connect(on_button_clicked);
        grid.attach(save_button, 1, 2, 1, 1);

    }
/** Gets list of active providers */
    public string GetProviders(){
        string providers = "";
        int i;

        for(i = 0; i < 6;  i++){
            if(provider_bool[i])
            {
                providers = providers + PROVIDER_TABLE[i];
            }
        }


        return providers;
    }
    
    private void on_button_clicked(Button button) {
        string[] file_data = {"[Contractor Entry]\n", "Name=Download Subtitles\n", "Icon=multimedia-video-player\n", "Description=Downloads subtitles for your video.\n", "MimeType=video;\n", "Exec=submarine -f -q ", "Gettext-Domain=submarine\n"};
        int i;
        string to_append = "";
        string  lang = "";

        var file = File.new_for_path ("/tmp/download-subtitle.contract");
        try {
            file.delete ();
        } catch (Error e) {
            //Posix.stdout.printf ("Error: %s\n", e.message);
        }

        try {
            var file_stream = file.create (FileCreateFlags.NONE);

            to_append = GetProviders();
            lang = "-l " + language_text + " %U\n";
            to_append = to_append + lang;
            file_data[5] = file_data[5] + to_append;
            Posix.stdout.printf("Will write line %s\n", file_data[5]);

            var data_stream = new DataOutputStream (file_stream);

            for(i=0; i <7 ; i++){
                data_stream.put_string (file_data[i]);
            }

            Posix.system("mv -f /tmp/download-subtitle.contract /usr/share/contractor/download-subtitle.contract");
            Posix.stdout.printf ("Configuration updated successfully\n");
        }catch (Error e) {
             Posix.stderr.printf ("Error: %s\n", e.message);
        }
    }

    public static int main(string[] args) {

        if(geteuid() != 0)
        {
            Posix.stdout.printf ("Please run as root.\n");
            return 0;
        }

        Gtk.init (ref args);

        var window = new PantheonSubmarine();
        window.show_all();
        Posix.system("submarine -l help");

        Gtk.main ();

        return 1;
    }
}