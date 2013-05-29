using Comedi;

class BoardInfo : GLib.Object {

    private Device dev;

    public void run () {
        dev = new Device ("/dev/comedi0");
        var info = "Board info:\n";
        var n_subdevices = dev.get_n_subdevices ();

        info += "  version code:    0x%06x\n".printf (dev.get_version_code ());
        info += "  driver name:     %s\n".printf (dev.get_driver_name ());
        info += "  board name:      %s\n".printf (dev.get_board_name ());
        info += "  subdevice count: %d\n".printf (n_subdevices);

        stdout.printf ("%s\n", info);

        var subd_info = "  Subdevices:\n";

        for (int i = 0; i < n_subdevices; i++) {
            subd_info += "    subdevice %d:\n".printf (i);
            subd_info += "    ranges:\n";
        }

        stdout.printf ("%s\n", subd_info);
    }
}

public static int main (string[] args) {
    BoardInfo app = new BoardInfo ();
    app.run ();
    return 0;
}
