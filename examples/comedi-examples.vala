using Comedi;

public abstract class ComediExample : Object {
    public abstract void run ();
}

public class Common : Object {

    public string filename { get; set; default = "/dev/comedi0"; }
    public double value { get; set; default = 0.0; }
    public int subdevice { get; set; default = 0; }
    public int channel { get; set; default = 0; }
    public int aref { get; set; default = AnalogReference.GROUND; }
    public int range { get; set; default = 0; }
    public int physical { get; set; default = 0; }
    public int verbose { get; set; default = 0; }
    public int n_chan { get; set; default = 4; }
    public int n_scan { get; set; default = 1000; }
    public double freq { get; set; default = 1000.0; }

    /* Do nothing constructor for now. */
    public Common () { }
}

public class ComediExamples : Object {

    private static ComediExample? example = null;
    private static string? demo = null;

    private static Common common = new Common ();

    private const GLib.OptionEntry[] options = {{
        "demo", 'd', 0, OptionArg.STRING, ref demo,
        "Run the demo program provided.", null
    },{
        "file", 'f', 0, OptionArg.STRING, ref common.filename,
        "", null
    },{
        "subdevice", 's', 0, OptionArg.NONE, ref common.,
        "", null
    },{
        "channel", 'c', 0, OptionArg.NONE, ref common.,
        "", null
    },{
        "aref", 'a', 0, OptionArg.NONE, ref common.,
        "", null
    },{
        "nchan", 'n', 0, OptionArg.NONE, ref common.,
        "", null
    },{
        "nscan", 'N', 0, OptionArg.NONE, ref common.,
        "", null
    },{
        "frequency", 'F', 0, OptionArg.NONE, ref common.,
        "", null
    },{
        "physicial", 'p', 0, OptionArg.NONE, ref common.,
        "", null
    },{
        "verbose", 'v', 0, OptionArg.NONE, ref common.,
        "", null
    },{
        "differential", 'd', 0, OptionArg.NONE, ref common.,
        "", null
    },{
        "ground", 'g', 0, OptionArg.NONE, ref common.,
        "", null
    },{
        "other", 'o', 0, OptionArg.NONE, ref common.,
        "", null
    },{
        "common", 'm', 0, OptionArg.NONE, ref common.,
        "", null
    },{
        null
    }};

    public static int main (string[] args) {

        try {
            var opt_context = new OptionContext ("ComediExamples");
            opt_context.set_help_enabled (true);
            opt_context.add_main_entries (options, null);
            opt_context.parse (ref args);
        } catch (OptionError e) {
            stdout.printf ("error: %s\n", e.message);
            stdout.printf ("Run '%s --help' to see a full list of available command line options.\n", args[0]);
            return 0;
        }

        switch (demo) {
            case "antialias":
                message ("Demo '%s' not implemented.", demo);
                break;
            case "ao_mmap":
                message ("Demo '%s' not implemented.", demo);
                break;
            case "ao_waveform":
                message ("Demo '%s' not implemented.", demo);
                break;
            case "apply_cal":
                message ("Demo '%s' not implemented.", demo);
                break;
            case "board_info":
                message ("Demo '%s' not implemented.", demo);
                break;
            case "choose_clock":
                message ("Demo '%s' not implemented.", demo);
                break;
            case "choose_filter":
                message ("Demo '%s' not implemented.", demo);
                break;
            case "choose_routing":
                message ("Demo '%s' not implemented.", demo);
                break;
            case "cmd":
                message ("Demo '%s' not implemented.", demo);
                break;
            case "dio":
                message ("Demo '%s' not implemented.", demo);
                break;
            case "do_waveform":
                message ("Demo '%s' not implemented.", demo);
                break;
            case "eeprom_dump":
                message ("Demo '%s' not implemented.", demo);
                break;
            case "gpct_buffered_counting":
                message ("Demo '%s' not implemented.", demo);
                break;
            case "gpct_encoder":
                message ("Demo '%s' not implemented.", demo);
                break;
            case "gpct_pulse_generator":
                message ("Demo '%s' not implemented.", demo);
                break;
            case "gpct_simple_counting":
                message ("Demo '%s' not implemented.", demo);
                break;
            case "inp":
                message ("Demo '%s' not implemented.", demo);
                break;
            case "inpn":
                message ("Demo '%s' not implemented.", demo);
                break;
            case "insn":
                message ("Demo '%s' not implemented.", demo);
                break;
            case "ledclock":
                message ("Demo '%s' not implemented.", demo);
                break;
            case "mmap":
                message ("Demo '%s' not implemented.", demo);
                break;
            case "outp":
                message ("Demo '%s' not implemented.", demo);
                break;
            case "poll":
                message ("Demo '%s' not implemented.", demo);
                break;
            case "pwm":
                message ("Demo '%s' not implemented.", demo);
                break;
            case "receiver":
                message ("Demo '%s' not implemented.", demo);
                break;
            case "select":
                message ("Demo '%s' not implemented.", demo);
                break;
            case "sender":
                message ("Demo '%s' not implemented.", demo);
                break;
            case "sigio":
                message ("Demo '%s' not implemented.", demo);
                break;
            case "sv":
                message ("Demo '%s' not implemented.", demo);
                break;
            case "tut1":
                message ("Demo '%s' not implemented.", demo);
                break;
            case "tut2":
                message ("Demo '%s' not implemented.", demo);
                break;
            case "tut3":
                message ("Demo '%s' not implemented.", demo);
                break;
            default:
                message ("Demo '%s' does not exist.", demo);
                break;
        }

        if (example != null)
            example.run ();

        return 0;
    }
}
