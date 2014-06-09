/**
 * This is based on the select.c program in comedilib.
 * valac -X -lm --pkg comedi --pkg posix --pkg gio-2.0 cmd_io.vala --target-glib 2.32 --pkg glib-2.0
 */

using Comedi;
using Posix;
using GLib;

public class ComediIO : Object {
    private const int bufsz = 1024;
    private const int n_chans = 16;
    private const int n_scans = 10;
    private uint[] chanlist = new uint[16];

    private Comedi.Device device;
    private Comedi.Command cmd;
    private uint maxdata;
    private int channel = 0; //start channel
    private int range = 5;
    private Comedi.Range crange;
    private int subdevice = 0;
    private int subdev_flags;
    private uint scan_period_nanosec = (uint) (1e9 / 3000.0);
    private uint raw;
    private bool is_physical = true;
    private static int total = 0;

    public int fd = -1;
    private int col = 0;
    private ulong rx_count = 0;
    private Posix.FILE outfile;

    public ComediIO () {
        outfile = FILE.open("log.out", "w");
        Comedi.loglevel (4);
        device = new Comedi.Device ("/dev/comedi1");
        maxdata = device.get_maxdata (0, 0);
        crange = device.get_range (subdevice, channel, range);

        fd = device.fileno ();
	    fcntl (fd, Posix.F_SETFL, Posix.O_NONBLOCK);
        //GLib.stdout.printf ("board name: %s\n", device.get_board_name ());
        device.set_buffer_size (subdevice, 40000);
        //GLib.stdout.printf ("buffer size: %u\n", device.get_buffer_size (subdevice));
        //GLib.stdout.printf ("max buffer size: %u\n", device.get_max_buffer_size (subdevice));
    }

    public void run () {
        int i;

        for(i = 0; i < n_chans; i++){
            chanlist[i] = Comedi.pack (channel + i, range, AnalogReference.GROUND);
        }

        int ret;
        /* This comedilib function will get us a generic timed
        * command for a particular board.  If it returns -1,
        * that's bad. */
        ret = device.get_cmd_generic_timed (subdevice, out cmd, n_chans, scan_period_nanosec);
        if (ret < 0) {
            message ("comedi_get_cmd_generic_timed failed");
        }

        /* Modify parts of the command */
    	prepare_cmd ();

        /* Launch select thread */

        GLib.Thread<int> thread = new GLib.Thread<int> ("thread1", select_thread_func);

        do_cmd ();
        yield;
    }

    public int select_thread_func () {

        while (true) {
            ushort[] buf = new ushort[bufsz];
            Posix.fd_set rdset;
            int ret;

            Posix.timeval timeout = Posix.timeval ();
            Posix.FD_ZERO (out rdset);
            Posix.FD_SET (fd, ref rdset);
            timeout.tv_sec = 0;
            timeout.tv_usec = 50000;
            //GLib.stdout.printf ("streaming buffer size: %d\n", device.get_buffer_size(cmd.subdev));
            ret = Posix.select (fd + 1, &rdset, null, null, timeout);
            //GLib.stdout.printf ("select returned %d\n", ret);

            if (ret < 0) {
                if (Posix.errno == EAGAIN) {
                    perror("read");
                }
            } else if (ret == 0) {
                ;
            } else if ((Posix.FD_ISSET (fd, rdset)) == 1) {
                //GLib.stdout.printf("comedi file descriptor ready\n");
                ret = (int)Posix.read (fd, buf, bufsz);
                //GLib.stdout.printf ("read returned: %d\n", ret);
                ulong bytes_per_sample;
                total += ret;
                message ("read %d %d", ret, total);

                if ((subdev_flags & SubdeviceFlag.LSAMPL) != 0) {
                    bytes_per_sample = sizeof (uint);
                } else {
                    bytes_per_sample = sizeof (ushort);
                }

                for (int i = 0; i < ret / 2; i++) {
                        raw = (ushort) buf[i];
                    print_datum (raw, col, is_physical);
                    outfile.printf ("%#8.6g ", to_phys (raw, crange, maxdata));
                    col++;
                    if (col == n_chans) {
                        printf("\n");
                        outfile.printf ("\n");
                        col = 0;
                    }
                }
            }
        }

        return 0;
	 }

    private void prepare_cmd () {
        cmd.subdev = subdevice;

        cmd.flags = 0;//TriggerFlag.WAKE_EOS;

        cmd.start_src = TriggerSource.NOW;
        cmd.start_arg = 0;

        cmd.scan_begin_src = TriggerSource.FOLLOW;
        cmd.scan_begin_arg = 0;//scan_period_nanosec; //nanoseconds;

    	cmd.convert_src =  TriggerSource.TIMER;
	    cmd.convert_arg = 10000;//(int)(scan_period_nanosec / (2 * n_chans));

        cmd.scan_end_src = TriggerSource.COUNT;
        cmd.scan_end_arg = n_chans;

        cmd.stop_src = TriggerSource.NONE;//COUNT;
        cmd.stop_arg = 0;//n_scans;

        cmd.chanlist = chanlist;
        cmd.chanlist_len = n_chans;

        if (cmd.stop_src == TriggerSource.COUNT) {
            cmd.stop_arg = n_scans;
        }
    }

    private void do_cmd () {
        int ret;

        ret = device.command_test (cmd);

        GLib.stdout.printf ("test ret = %d\n", ret);
        if (ret < 0) {
		    Comedi.perror("comedi_command_test");
            return;
        }

    	dump_cmd (cmd);

        ret = device.command_test (cmd);

        GLib.stdout.printf ("test ret = %d\n", ret);
        if (ret < 0) {
		    Comedi.perror("comedi_command_test");
		    return;
        }

    	dump_cmd (cmd);

        ret = device.command (cmd);

        GLib.stdout.printf ("test ret = %d\n", ret);
	    if (ret < 0) {
		    Comedi.perror("comedi_command");

		    return;
        }
	}

    private string cmd_src (uint src) {
        string buf = "";

        if ((src & TriggerSource.NONE) != 0) buf = "none|";
        if ((src & TriggerSource.NOW) != 0) buf = "now|";
        if ((src & TriggerSource.FOLLOW) != 0) buf = "follow|";
        if ((src & TriggerSource.TIME) != 0) buf = "time|";
        if ((src & TriggerSource.TIMER) != 0) buf = "timer|";
        if ((src & TriggerSource.COUNT) != 0) buf = "count|";
        if ((src & TriggerSource.EXT) != 0) buf = "ext|";
        if ((src & TriggerSource.INT) != 0) buf = "int|";
        if ((src & TriggerSource.OTHER) != 0) buf = "other|";

        if (strlen (buf) == 0) {
            buf = "unknown src";
        } else {
            //buf[strlen (buf)-1]=0;
        }

        return buf;
    }

    private void dump_cmd (Command cmd) {
        message ("subdevice:      %u", cmd.subdev);
        message ("start:      %-8s %u", cmd_src (cmd.start_src), cmd.start_arg);
        message ("scan_begin: %-8s %u", cmd_src (cmd.scan_begin_src), cmd.scan_begin_arg);
        message ("convert:    %-8s %u", cmd_src (cmd.convert_src), cmd.convert_arg);
        message ("scan_end:   %-8s %u", cmd_src (cmd.scan_end_src), cmd.scan_end_arg);
        message ("stop:       %-8s %u", cmd_src (cmd.stop_src), cmd.stop_arg);
    }

    private void print_datum (uint raw, int channel_index, bool is_physical) {
        double physical_value;
        if (!is_physical) {
            GLib.stdout.printf ("%u ",raw);
        } else {
            physical_value = to_phys (raw, crange, maxdata);
            GLib.stdout.printf ("%#8.6g ", physical_value);
        }
    }
}

int main () {
    GLib.MainLoop loop = new MainLoop ();
    uint? source_id;

    ComediIO io = new ComediIO ();

    io.run ();

    loop.run ();

    return 0;
}

