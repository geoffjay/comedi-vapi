using Comedi;

class BoardInfo : GLib.Object {

    private Device dev;

    public void run () {
        dev = new Device ("/dev/comedi0");
        var n_subdevices = dev.get_n_subdevices ();

        stdout.printf ("Board info:\n");
        stdout.printf ("  version code:    0x%06x\n", dev.get_version_code ());
        //stdout.printf ("  driver name:     %s\n", dev.get_driver_name ());
        stdout.printf ("  board name:      %s\n", dev.get_board_name ());
        stdout.printf ("  subdevice count: %d\n\n", n_subdevices);

        stdout.printf ("  Subdevices:\n");

        for (int i = 0; i < n_subdevices; i++) {
            stdout.printf ("    subdevice %d:\n", i);
            stdout.printf ("    ranges:\n");
        }
    }
}

public static int main (string[] args) {
    BoardInfo app = new BoardInfo ();
    app.run ();
    return 0;
}
