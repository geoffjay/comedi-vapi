using Comedi;
using Posix;

class AsynchAcquisition : GLib.Object {

    Device dev;
    int subdevice;
    Command cmd = Command ();
    const int BUFSZ = 10000;
    ushort[] buf = new ushort[BUFSZ];
    const int N_CHANS = 256;
    uint[] chanlist = new uint[N_CHANS];
    Range[] range_info = new Range[N_CHANS];
    uint[] maxdata = new uint[N_CHANS];
    int ret;
    int total=0;
    int i;
    TimeVal start;
    TimeVal end;
    int subdev_flags;
    uint raw;
    int n_chan = 1;
    int n_scan = 10;
    int range = 5;
    int channel = 0; // The start channel.
    int aref = AnalogReference.GROUND;
    string[] cmdtest_messages = {
        "success",
        "invalid source",
        "source conflict",
        "invalid argument",
        "argument conflict",
        "invalid chanlist"
    };
    int scan_period_nanosec = 1000000;
    bool is_physical = false;

    public void run () {
        /* open the device */
        dev = new Device ("/dev/comedi0");
        subdevice = 0;

        // Print numbers for clipped inputs
        set_global_oor_behavior (OorBehavior.NUMBER);

        /* Set up channel list */
        for (i = 0; i < n_chan; i++) {
            chanlist[i] = pack (i, range, aref);
            range_info[i] = dev.get_range (subdevice, channel, range);
            maxdata[i] = dev.get_maxdata (subdevice, channel);
        }

        /* prepare_cmd_lib () uses a Comedilib routine to find a
        * good command for the device.  prepare_cmd () explicitly
        * creates a command, which may not work for your device. */
        prepare_cmd_lib (n_scan, n_chan, scan_period_nanosec, out cmd);
        //prepare_cmd (n_scan, n_chan, scan_period_nanosec, cmd);

        message ("command before testing:");
        dump_cmd (cmd);

        /* comedi_command_test () tests a command to see if the
        * trigger sources and arguments are valid for the subdevice.
        * If a trigger source is invalid, it will be logically ANDed
        * with valid values (trigger sources are actually bitmasks),
        * which may or may not result in a valid trigger source.
        * If an argument is invalid, it will be adjusted to the
        * nearest valid value.  In this way, for many commands, you
        * can test it multiple times until it passes.  Typically,
        * if you can't get a valid command in two tests, the original
        * command wasn't specified very well. */
        ret = dev.command_test (cmd);
        if (ret < 0) {
            perror ("command_test");
            if (Posix.errno == Posix.EIO) {
                critical ("Ummm... this subdevice doesn't support commands");
            }
        }

        message ("first test returned %d (%s)", (int)ret, cmdtest_messages[ret]);
        dump_cmd (cmd);

        ret = dev.command_test (cmd);
        if (ret < 0) {
            perror ("command_test");
        }

        message ("second test returned %d (%s)",(int) ret,
                 cmdtest_messages[ret]);

        if (ret != 0) {
            dump_cmd (cmd);
            critical ("Error preparing command");
        }

        /* this is only for informational purposes */
        start.get_current_time ();
        message ("start time: %ld.%06ld", start.tv_sec, start.tv_usec);

        /* start the command */
        ret = dev.command (cmd);
        if (ret < 0) {
            perror ("command");
        }

        subdev_flags = dev.get_subdevice_flags (subdevice);

        while (true) {
            ret = (int)Posix.read (dev.fileno (), buf, BUFSZ);
            if (ret < 0) {
                /* some error occurred */
                perror ("read");
                break;
            } else if (ret == 0) {
                /* reached stop condition */
                break;
            } else {
                int col;
                ulong bytes_per_sample;

                col = 0;
                total += ret;
                message ("read %d %d", ret, total);
                if ((subdev_flags & SubdeviceFlag.LSAMPL) != 0)
                    bytes_per_sample = sizeof (uint);
                else
                    bytes_per_sample = sizeof (ushort);
                for (i = 0; i < ret / 2; i++) { //i < ret / bytes_per_sample; i++) {
                    //if ((subdev_flags & SubdeviceFlag.LSAMPL) != 0) {
                    //    raw = (uint) buf[i];
                    //}
                    //else {
                        raw = (ushort) buf[i];
                        //printf ("buf[%d]: %d\n", i, buf[i]);
                    //}
                    print_datum (raw, col, is_physical);
                    col++;
                    if (col == n_chan) {
                        printf("\n");
                        col = 0;
                    }
                }
            }
        }

        /* this is only for informational purposes */
        end.get_current_time ();
        message ("end time: %ld.%06ld", end.tv_sec, end.tv_usec);

        end.tv_sec -= start.tv_sec;
        if (end.tv_usec < start.tv_usec) {
            end.tv_sec--;
            end.tv_usec += 1000000;
        }
        end.tv_usec -= start.tv_usec;
        message ("time: %ld.%06ld", end.tv_sec, end.tv_usec);
    }

    /*
    * This prepares a command in a pretty generic way.  We ask the
    * library to create a stock command that supports periodic
    * sampling of data, then modify the parts we want. */
    private int prepare_cmd_lib (int n_scan, int n_chan, uint scan_period_nanosec, out Command cmd) {
        int ret;
        /* This comedilib function will get us a generic timed
        * command for a particular board.  If it returns -1,
        * that's bad. */
        ret = dev.get_cmd_generic_timed (subdevice, out cmd, n_chan, scan_period_nanosec);
        if (ret < 0) {
            message ("comedi_get_cmd_generic_timed failed");
            return ret;
        }

        /* Modify parts of the command */
        cmd.chanlist = chanlist;
        cmd.chanlist_len = n_chan;
        if (cmd.stop_src == TriggerSource.COUNT)
            cmd.stop_arg = n_scan;

        return 0;
    }

    /*
    * Set up a command by hand.  This will not work on some devices.
    * There is no single command that will work on all devices.
    */
    private int prepare_cmd (int n_scan, int n_chan, uint period_nanosec, Command cmd) {
        /* the subdevice that the command is sent to */
        cmd.subdev =	subdevice;

        /* flags */
        cmd.flags = 0;

        /* Wake up at the end of every scan */
        //cmd->flags |= TRIG_WAKE_EOS;

        /* Use a real-time interrupt, if available */
        //cmd->flags |= TRIG_RT;

        /* each event requires a trigger, which is specified
        by a source and an argument.  For example, to specify
        an external digital line 3 as a source, you would use
        src=TRIG_EXT and arg=3. */

        /* The start of acquisition is controlled by start_src.
        * NOW:     The start_src event occurs start_arg nanoseconds
        *               after comedi_command () is called.  Currently,
        *               only start_arg=0 is supported.
        * FOLLOW:  (For an output device.)  The start_src event occurs
        *               when data is written to the buffer.
        * EXT:     start event occurs when an external trigger
        *               signal occurs, e.g., a rising edge of a digital
        *               line.  start_arg chooses the particular digital
        *               line.
        * INT:     start event occurs on a Comedi internal signal,
        *               which is typically caused by an INSN_TRIG
        *               instruction.
        */
        cmd.start_src =	TriggerSource.NOW;
        cmd.start_arg =	0;

        /* The timing of the beginning of each scan is controlled by
        * scan_begin.
        * TIMER:   scan_begin events occur periodically.
        *               The time between scan_begin events is
        *               convert_arg nanoseconds.
        * EXT:     scan_begin events occur when an external trigger
        *               signal occurs, e.g., a rising edge of a digital
        *               line.  scan_begin_arg chooses the particular digital
        *               line.
        * FOLLOW:  scan_begin events occur immediately after a scan_end
        *               event occurs.
        * The scan_begin_arg that we use here may not be supported exactly
        * by the device, but it will be adjusted to the nearest supported
        * value by comedi_command_test (). */
        cmd.scan_begin_src =	TriggerSource.TIMER;
        cmd.scan_begin_arg = period_nanosec;		/* in ns */

        /* The timing between each sample in a scan is controlled by convert.
        * TIMER:   Conversion events occur periodically.
        *               The time between convert events is
        *               convert_arg nanoseconds.
        * EXT:     Conversion events occur when an external trigger
        *               signal occurs, e.g., a rising edge of a digital
        *               line.  convert_arg chooses the particular digital
        *               line.
        * NOW:     All conversion events in a scan occur simultaneously.
        * Even though it is invalid, we specify 1 ns here.  It will be
        * adjusted later to a valid value by comedi_command_test () */
        cmd.convert_src =	TriggerSource.TIMER;
        cmd.convert_arg =	1;		/* in ns */

        /* The end of each scan is almost always specified using
        * COUNT, with the argument being the same as the
        * number of channels in the chanlist.  You could probably
        * find a device that allows something else, but it would
        * be strange. */
        cmd.scan_end_src =	TriggerSource.COUNT;
        cmd.scan_end_arg =	n_chan;		/* number of channels */

        /* The end of acquisition is controlled by stop_src and
        * stop_arg.
        * COUNT:  stop acquisition after stop_arg scans.
        * NONE:   continuous acquisition, until stopped using
        *              comedi_cancel ()
        * */
        cmd.stop_src =		TriggerSource.COUNT;
        cmd.stop_arg =		n_scan;

        /* the channel list determined which channels are sampled.
        In general, chanlist_len is the same as scan_end_arg.  Most
        boards require this.  */
        cmd.chanlist =		chanlist;
        cmd.chanlist_len =	n_chan;

        return 0;
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
            printf ("%u ",raw);
        } else {
            physical_value = to_phys (raw, range_info[channel_index], maxdata[channel_index]);
            printf ("%#8.6g ", physical_value);
        }
    }
}

public static int main (string[] args) {

    AsynchAcquisition app = new AsynchAcquisition ();
    app.run ();
    return 0;
}

