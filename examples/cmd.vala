using Comedi;
using Posix;

class AsynchAcquisition : Glib.Object {

    private Device dev;
    private int subdevice;
    private Command cmd;
    const int BUFSZ = 10000;
    char buf[BUFSZ];
    const N_CHANS = 256;
    static unsigned int chanlist[N_CHANS];
    private Range range_info[N_CHANS];
    private uint maxdata[N_CHANS];
    int ret;
    int total=0;
    int i;
    struct TimeVal start,end;
    int subdev_flags;
    uint raw;
    int n_chan = 4;
    int n_scan = 100;
    int range = 4;
    int channel = 0; // The start channel.
    AnalogReference aref = AnalogReference.GROUND;
    string[] cmdtest_messages = {
        "success",
        "invalid source",
        "source conflict",
        "invalid argument",
        "argument conflict",
        "invalid chanlist",
    }
    double freq = 100.0;
    bool is_physical = true;

    int prepare_cmd_lib(uint period_nanosec, Command cmd);
    int prepare_cmd(uint period_nanosec, Command cmd)
    void print_datum(uint raw, int channel_index, short physical);

    public void run () {
        /* open the device */
        dev = new Device ("/dev/comedi0");
        start = new TimeVal ();
        stop = new TimeVal ();
        subdevice = 0;
        // Print numbers for clipped inputs
        set_global_oor_behavior (OorBehavior.NUMBER);
        /* Set up channel list */
        for(i = 0; i < n_chan; i++){
            chanlist[i] = pack (i, range, aref);
            range_info[i] = dev.get_range (subdevice, channel, range);
            maxdata[i] = dev.get_maxdata (subdevice, channel);
        }
        /* prepare_cmd_lib() uses a Comedilib routine to find a
        * good command for the device.  prepare_cmd() explicitly
        * creates a command, which may not work for your device. */
        prepare_cmd_lib (n_scan, n_chan, 1e9 / freq, cmd);
        message ("command before testing:\n");
        dump_cmd(cmd);
        /* comedi_command_test() tests a command to see if the
        * trigger sources and arguments are valid for the subdevice.
        * If a trigger source is invalid, it will be logically ANDed
        * with valid values (trigger sources are actually bitmasks),
        * which may or may not result in a valid trigger source.
        * If an argument is invalid, it will be adjusted to the
        * nearest valid value.  In this way, for many commands, you
        * can test it multiple times until it passes.  Typically,
        * if you can't get a valid command in two tests, the original
        * command wasn't specified very well. */
        ret = dev.command_test(cmd);
        if(ret < 0){
            perror("command_test");
            if(errno == EIO){
                critical ("Ummm... this subdevice doesn't support commands\n");
            }
        }
        message ("first test returned %d (%s)\n", ret, cmdtest_messages[ret]);
        dump_cmd(cmd);
        ret = command_test(dev, cmd);
        if(ret < 0){
            perror("command_test");
        }
        fprintf(stderr,"second test returned %d (%s)\n", ret,
                cmdtest_messages[ret]);
        if(ret!=0){
            dump_cmd(stderr, cmd);
            critical ("Error preparing command\n");
        }

        /* this is only for informational purposes */
        Posix.start.get_current_time();
        message ("start time: %ld.%06ld\n", start.tv_sec, start.tv_usec);

        /* start the command */
        ret = dev.command(cmd);
        if(ret < 0) {
            perror("command");
        }
        subdev_flags = dev.get_subdevice_flags (subdevice);
        while(1){
            ret = Posix.read (dev.fileno(), buf, BUFSZ);
            if(ret < 0) {
                /* some error occurred */
                perror("read");
                break;
            } else if(ret == 0){
                /* reached stop condition */
                break;
            } else {
                static int col = 0;
                int bytes_per_sample;
                total += ret;
                message ("read %d %d\n", ret, total);
                if(subdev_flags & SubdeviceFlag.LSAMPL)
                    bytes_per_sample = sizeof (uint);
                else
                    bytes_per_sample = sizeof (ushort);
                for (i = 0; i < ret / bytes_per_sample; i++) {
                    if (subdev_flags & SubdeviceFlag.LSAMPL) {
                        raw = ((uint)buf)[i];
                    } else {
                        raw = ((ushort)buf)[i];
                    }
                    print_datum (raw, col, is_physical);
                    col++;
                    if(col == n_chan){
                        message ("\n");
                        col=0;
                    }
                }
            }
        }

        /* this is only for informational purposes */
        Posix.end.get_current_time ();
        message ("end time: %ld.%06ld\n", end.tv_sec, end.tv_usec);

        end.tv_sec -= start.tv_sec;
        if(end.tv_usec < start.tv_usec){
            end.tv_sec--;
            end.tv_usec += 1000000;
        }
        end.tv_usec -= start.tv_usec;
        message ("time: %ld.%06ld\n", end.tv_sec, end.tv_usec);

        return 0;
    }

    /*
    * This prepares a command in a pretty generic way.  We ask the
    * library to create a stock command that supports periodic
    * sampling of data, then modify the parts we want. */
    int prepare_cmd_lib(int n_scan, int n_chan, unsigned scan_period_nanosec, Command cmd)
    {
        int ret;
        /* This comedilib function will get us a generic timed
        * command for a particular board.  If it returns -1,
        * that's bad. */
        ret = dev.get_cmd_generic_timed(subdevice, cmd, n_chan, scan_period_nanosec);
        if(ret<0){
            printf("comedi_get_cmd_generic_timed failed\n");
            return ret;
        }

        /* Modify parts of the command */
        cmd.chanlist = chanlist;
        cmd.chanlist_len = n_chan;
        if(cmd.stop_src == TRIG_COUNT) cmd.stop_arg = n_scan;

        return 0;
    }

    /*
    * Set up a command by hand.  This will not work on some devices.
    * There is no single command that will work on all devices.
    */
    int prepare_cmd(comedi_t *dev, int subdevice, int n_scan, int n_chan, unsigned period_nanosec, comedi_cmd *cmd)
    {
        memset(cmd,0,sizeof(*cmd));

        /* the subdevice that the command is sent to */
        cmd->subdev =	subdevice;

        /* flags */
        cmd->flags = 0;

        /* Wake up at the end of every scan */
        //cmd->flags |= TRIG_WAKE_EOS;

        /* Use a real-time interrupt, if available */
        //cmd->flags |= TRIG_RT;

        /* each event requires a trigger, which is specified
        by a source and an argument.  For example, to specify
        an external digital line 3 as a source, you would use
        src=TRIG_EXT and arg=3. */

        /* The start of acquisition is controlled by start_src.
        * TRIG_NOW:     The start_src event occurs start_arg nanoseconds
        *               after comedi_command() is called.  Currently,
        *               only start_arg=0 is supported.
        * TRIG_FOLLOW:  (For an output device.)  The start_src event occurs
        *               when data is written to the buffer.
        * TRIG_EXT:     start event occurs when an external trigger
        *               signal occurs, e.g., a rising edge of a digital
        *               line.  start_arg chooses the particular digital
        *               line.
        * TRIG_INT:     start event occurs on a Comedi internal signal,
        *               which is typically caused by an INSN_TRIG
        *               instruction.
        */
        cmd->start_src =	TRIG_NOW;
        cmd->start_arg =	0;

        /* The timing of the beginning of each scan is controlled by
        * scan_begin.
        * TRIG_TIMER:   scan_begin events occur periodically.
        *               The time between scan_begin events is
        *               convert_arg nanoseconds.
        * TRIG_EXT:     scan_begin events occur when an external trigger
        *               signal occurs, e.g., a rising edge of a digital
        *               line.  scan_begin_arg chooses the particular digital
        *               line.
        * TRIG_FOLLOW:  scan_begin events occur immediately after a scan_end
        *               event occurs.
        * The scan_begin_arg that we use here may not be supported exactly
        * by the device, but it will be adjusted to the nearest supported
        * value by comedi_command_test(). */
        cmd->scan_begin_src =	TRIG_TIMER;
        cmd->scan_begin_arg = period_nanosec;		/* in ns */

        /* The timing between each sample in a scan is controlled by convert.
        * TRIG_TIMER:   Conversion events occur periodically.
        *               The time between convert events is
        *               convert_arg nanoseconds.
        * TRIG_EXT:     Conversion events occur when an external trigger
        *               signal occurs, e.g., a rising edge of a digital
        *               line.  convert_arg chooses the particular digital
        *               line.
        * TRIG_NOW:     All conversion events in a scan occur simultaneously.
        * Even though it is invalid, we specify 1 ns here.  It will be
        * adjusted later to a valid value by comedi_command_test() */
        cmd->convert_src =	TRIG_TIMER;
        cmd->convert_arg =	1;		/* in ns */

        /* The end of each scan is almost always specified using
        * TRIG_COUNT, with the argument being the same as the
        * number of channels in the chanlist.  You could probably
        * find a device that allows something else, but it would
        * be strange. */
        cmd->scan_end_src =	TRIG_COUNT;
        cmd->scan_end_arg =	n_chan;		/* number of channels */

        /* The end of acquisition is controlled by stop_src and
        * stop_arg.
        * TRIG_COUNT:  stop acquisition after stop_arg scans.
        * TRIG_NONE:   continuous acquisition, until stopped using
        *              comedi_cancel()
        * */
        cmd->stop_src =		TRIG_COUNT;
        cmd->stop_arg =		n_scan;

        /* the channel list determined which channels are sampled.
        In general, chanlist_len is the same as scan_end_arg.  Most
        boards require this.  */
        cmd->chanlist =		chanlist;
        cmd->chanlist_len =	n_chan;

        return 0;
    }
    void dump_cmd()
    {
        message ("subdevice:      %d\n", cmd.subdev);
        message ("start:      %-8s %d\n", cmd_src(cmd.start_src,buf), cmd.start_arg);
        message ("scan_begin: %-8s %d\n", cmd_src(cmd.scan_begin_src,buf), cmd.scan_begin_arg);
        message ("convert:    %-8s %d\n", cmd_src(cmd.convert_src,buf), cmd.convert_arg);
        message ("scan_end:   %-8s %d\n", cmd_src(cmd.scan_end_src,buf), cmd.scan_end_arg);
        message ("stop:       %-8s %d\n", cmd_src(cmd.stop_src,buf), cmd.stop_arg);
    }

    void print_datum(uint raw, int channel_index, short is_physical) {
        double physical_value;
        if(!is_physical) {
            message ("%d ",raw);
        } else {
            physical_value = to_phys (raw, range_info[channel_index], maxdata[channel_index]);
            message ("%#8.6g ", physical_value);
        }
    }

}

public static int main (string[] args) {

    AsynchAcquisition app = new AsynchAquisition ();
    app.run();
    return 0;
}

