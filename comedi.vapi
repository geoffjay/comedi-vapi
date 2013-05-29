/*
 * comedi.vapi
 * Vala bindings for the control and measurement devices library comedi
 * Copyright (c) 2011 Geoff Johnson <geoff.jay@gmail.com>
 * License: GNU LGPL v3 as published by the Free Software Foundation
 *
 * This binding is a (mostly) strict binding to the function-oriented
 * nature of this C library.
 */

[CCode (cprefix = "comedi_", cheader_filename = "comedi.h")]
namespace Comedi {

    /*
     * Macro utilities
     */
    [CCode (cprefix = "COMEDI_VERSION_CODE")]
    public static int version_code (int a, int b, int c);

    [CCode (cname = "CR_PACK")]
    public static int pack (int chan, int rng, int aref);

    [CCode (cname = "CR_PACK_FLAGS")]
    public static int pack_flags (int chan, int range, int aref, int flags);

    [CCode (cname = "CR_CHAN")]
    public static int chan (int a);

    [CCode (cname = "CR_RANGE")]
    public static int range (int a);

    [CCode (cname = "CR_AREF")]
    public static int aref (int a);

    [CCode (cname = "__RANGE")]
    public static int __range (int a, int b);

    [CCode (cname = "RANGE_OFFSET")]
    public static int range_offset (int a);

    [CCode (cname = "RANGE_LENGTH")]
    public static int range_length (int b);

    [CCode (cname = "RF_UNIT")]
    public static int rf_unit (int flags);

    /*
     * Device configuration
     */
    [CCode(cprefix = "COMEDI_DEVCONF_AUX_", cheader_filename = "comedi.h")]
    public enum DevConfAux {
        DATA3_LENGTH,
        DATA2_LENGTH,
        DATA1_LENGTH,
        DATA0_LENGTH,
        DATA_HI,
        DATA_LO,
        DATA_LENGTH
    }

    /*
     * Analog Reference Options
     */
    [CCode (cprefix = "AREF_", cheader_filename = "comedi.h")]
    public enum AnalogReference {
        GROUND,
        COMMON,
        DIFF,
        OTHER
    }

    /*
     * Counters
     */
    [CCode (cprefix = "GPCT_", cheader_filename = "comedi.h")]
    public enum CounterAttribute {
        RESET,
        SET_SOURCE,
        SET_GATE,
        SET_DIRECTION,
        SET_OPERATION,
        ARM,
        DISARM,
        GET_INT_CLK_FRQ,
        INT_CLOCK,
        EXT_PIN,
        NO_GATE,
        UP,
        DOWN,
        HWUD,
        SIMPLE_EVENT,
        SINGLE_PERIOD,
        SINGLE_PW,
        CONT_PULSE_OUT,
        SINGLE_PULSE_OUT
    }

    /*
     * Instructions
     */
    [CCode (cprefix = "INSN_MASK_", cheader_filename = "comedi.h")]
    public enum InstructionMask {
        WRITE,
        READ,
        SPECIAL
    }

    [CCode (cprefix = "INSN_", cheader_filename = "comedi.h")]
    public enum InstructionAttribute {
        READ,
        WRITE,
        BITS,
        CONFIG,
        GTOD,
        WAIT,
        INTTRIG
    }

    [CCode (cprefix = "INSN_CONFIG_", cheader_filename = "comedi.h")]
    public enum InstructionConfiguration {
        DIO_INPUT,
        DIO_OUTPUT,
        DIO_OPENDRAIN,
        ANALOG_TRIG,
        ALT_SOURCE,
        DIGITAL_TRIG,
        BLOCK_SIZE,
        TIMER_1,
        FILTER,
        CHANGE_NOTIFY,
        SERIAL_CLOCK,
        BIDIRECTIONAL_DATA,
        DIO_QUERY,
        PWM_OUTPUT,
        GET_PWM_OUTPUT,
        ARM,
        DISARM,
        GET_COUNTER_STATUS,
        RESET,
        GPCT_SINGLE_PULSE_GENERATOR,
        GPCT_PULSE_TRAIN_GENERATOR,
        GPCT_QUADRATURE_ENCODER,
        SET_GATE_SRC,
        GET_GATE_SRC,
        SET_CLOCK_SRC,
        GET_CLOCK_SRC,
        SET_OTHER_SRC,
        SET_COUNTER_MODE,
        8254_READ_STATUS,
        SET_ROUTING,
        GET_ROUTING
    }

    [CCode (cprefix = "COMEDI_", cheader_filename = "comedi.h")]
    public enum IODirection {
        INPUT,
        OUTPUT,
        OPENDRAIN
    }

    /*
     * Triggers
     */
    [CCode (cprefix = "TRIG_", cheader_filename = "comedi.h")]
    public enum TriggerFlag {
        BOGUS,
        DITHER,
        DEGLITCH,
        CONFIG,
        RT,
        WAKE_EOS,
        WRITE
    }

    [CCode (cprefix = "TRIG_ROUND_", cheader_filename = "comedi.h")]
    public enum TriggerRounding {
        MASK,
        NEAREST,
        DOWN,
        UP,
        UP_NEXT
    }

    [CCode (cprefix = "TRIG_", cheader_filename = "comedi.h")]
    public enum TriggerSource {
        ANY,
        INVALID,
        NONE,
        NOW,
        FOLLOW,
        TIME,
        TIMER,
        COUNT,
        EXT,
        INT,
        OTHER
    }

    /*
     * Commands
     */
    [CCode (cprefix = "CMDF_", cheader_filename = "comedi.h")]
    public enum CommandFlag {
        PRIORITY,
        WRITE,
        RAWDATA
    }

    [CCode (cprefix = "COMEDI_EV_", cheader_filename = "comedi.h")]
    public enum CommandEvent {
        START,
        SCAN_BEGIN,
        CONVERT,
        SCAN_END,
        STOP
    }

    /*
     * Subdevice
     */
    [CCode (cprefix = "SDF_", cheader_filename = "comedi.h")]
    public enum SubdeviceFlag {
        BUSY,
        BUSY_OWNER,
        LOCKED,
        LOCK_OWNER,
        MAX_DATA,
        FLAGS,
        RANGETYPE,
        MODE0,
        MODE1,
        MODE2,
        MODE3,
        MODE4,
        CMD,
        SOFT_CALIBRATED,
        CMD_WRITE,
        CMD_READ,
        READABLE,
        WRITABLE,
        WRITEABLE,
        INTERNAL,
        RT,
        GROUND,
        COMMON,
        DIFF,
        OTHER,
        DITHER,
        DEGLITCH,
        MMAP,
        RUNNING,
        LSAMPL,
        PACKED
    }

    [CCode (cprefix = "COMEDI_SUBD_", cheader_filename = "comedi.h")]
    public enum SubdeviceType {
        UNUSED,
        AI,
        AO,
        DI,
        DO,
        DIO,
        COUNTER,
        TIMER,
        MEMORY,
        CALIB,
        PROC,
        SERIAL
    }

    [CCode (cprefix = "UNIT_", cheader_filename = "comedi.h")]
    public enum Unit {
        volt,
        mA,
        none
    }

    /*
     * Callback Stuff
     */
    [CCode (cprefix = "COMEDI_CB_", cheader_filename = "comedi.h")]
    public enum Callback {
        EOS,
        EOA,
        BLOCK,
        EOBUF,
        ERROR,
        OVERFLOW
    }

    [CCode (cprefix = "COMEDI_OOR_", cheader_filename = "comedi.h")]
    public enum OorBehavior {
        NUMBER,
        NAN
    }

    [CCode (cname = "comedi_trig", cheader_filename = "comedi.h")]
    public class Trigger {
        uint subdev;
        uint mode;
        uint flags;
        uint n_chan;
        uint[] chanlist;
        uint16[] data;
        uint n;
        uint trigsrc;
        uint trigvar;
        uint trigvar1;
        uint data_len;
        uint unused[3];
    }

    [CCode (cname = "comedi_cmd", cheader_filename = "comedi.h")]
    public class Command {
        uint subdev;
        uint flags;
        uint start_src;
        uint start_arg;
        uint scan_begin_src;
        uint scan_begin_arg;
        uint convert_src;
        uint convert_arg;
        uint scan_end_src;
        uint scan_end_arg;
        uint stop_src;
        uint stop_arg;
        uint[] chanlist;
        uint chanlist_len;
        uint16[] data;
        uint data_len;
    }

    [CCode (cname = "comedi_insn", cheader_filename = "comedi.h")]
    public class Instruction {
        uint insn;
        uint n;
        uint *data;
        uint subdev;
        uint chanspec;
        uint unused[3];
    }

    [CCode (cname = "comedi_insnlist", cheader_filename = "comedi.h")]
    public class InstructionList {
        uint n_insns;
        Instruction[] insns;
    }

    [CCode (cname = "comedi_chaninfo", cheader_filename = "comedi.h")]
    public class ChannelInfo {
        uint subdev;
        uint[] maxdata_list;
        uint[] flaglist;
        uint[] rangelist;
        uint unused[4];
    }

    [CCode (cname = "comedi_subdinfo", cheader_filename = "comedi.h")]
    public class SubdeviceInfo {
        uint type;
        uint n_chan;
        uint subd_flags;
        uint timer_type;
        uint len_chanlist;
        uint maxdata;
        uint flags;
        uint range_type;
        uint settling_time_0;
        uint unused[9];
    }

    [CCode (cname = "comedi_devinfo", cheader_filename = "comedi.h")]
    public class DeviceInfo {
        uint version_code;
        uint n_subdevs;
        char driver_name[COMEDI_NAMELEN];
        char board_name[COMEDI_NAMELEN];
        int read_subdevice;
        int write_subdevice;
        int unused[30];
    }

    [CCode (cname = "comedi_devconfig", cheader_filename = "comedi.h")]
    public class DeviceConfig {
        char board_name[COMEDI_NAMELEN];
        int options[COMEDI_NDEVCONFOPTS];
    }

    [CCode (cname = "comedi_rangeinfo", cheader_filename = "comedi.h")]
    public class RangeInfo {
        uint range_type;
        void *range_ptr;
    }

    [CCode (cname = "comedi_krange", cheader_filename = "comedi.h")]
    public class KRange {
        int min;
        int max;
        uint flags;
    }

    [CCode (cname = "comedi_bufconfig", cheader_filename = "comedi.h")]
    public class BufferConfig {
        uint subdevice;
        uint flags;
        uint maximum_size;
        uint size;
        uint unused[4];
    }

    [CCode (cname = "comedi_bufinfo", cheader_filename = "comedi.h")]
    public class BufferInfo {
        uint subdevice;
        uint bytes_read;
        uint buf_write_ptr;
        uint buf_read_ptr;
        uint buf_write_count;
        uint buf_read_count;
        uint bytes_written;
        uint unused[4];
    }

    [CCode (cname = "comedi_range", cheader_filename = "comedi.h")]
    public class Range {
        public double min;
        public double max;
        public uint unit;
    }

    [CCode (cname = "comedi_sv_t", cprefix = "comedi_sv_", cheader_filename = "comedi.h")]
    public class SlowVarying {
        public Device dev;
        public uint subdevice;
        public uint chan;
        public int range;
        public int aref;
        public int n;
        public uint maxdata;

        public int init (Device dev, uint subd, uint chan);
        public int update ();
        public int measure ([CCode (array_length = false)] double[] data);
    }

    /*
     * Device
     */
    [CCode (cname = "comedi_t", cprefix = "comedi_", unref_function = "", free_function = "comedi_close")]
    public class Device {
        [CCode (cname = "comedi_open")]
        public Device (string fn);

        public int close ();
        public int get_n_subdevices ();
        public int get_version_code ();
        public string get_driver_name ();
        public string get_board_name ();
        public int get_read_subdevice ();
        public int get_write_subdevice ();
        public int fileno ();

        /* subdevice queries */
        public int get_subdevice_type (uint subdevice);
        public int find_subdevice_by_type (int type, uint subd);
        public int get_subdevice_flags (uint subdevice);
        public int get_n_channels (uint subdevice);
        public int range_is_chan_specific (uint subdevice);
        public int maxdata_is_chan_specific (uint subdevice);

        /* channel queries */
        uint get_maxdata (uint subdevice, uint chan);
        int get_n_ranges (uint subdevice, uint chan);
        Range get_range (uint subdevice, uint chan, uint range);
        int find_range (uint subd, uint chan, uint unit, double min, double max);

        /* buffer queries */
        int get_buffer_size (uint subdevice);
        int get_max_buffer_size (uint subdevice);
        int set_buffer_size (uint subdevice, uint len);

        /* low-level */
        int do_insnlist (comedi_insnlist *il);
        int do_insn (comedi_insn *insn);
        int lock (uint subdevice);
        int unlock (uint subdevice);

        /* syncronous */
        int data_read (uint subd, uint chan, uint range, uint aref, [CCode (array_length = false)] uint[] data);
        int data_read_n (uint subd, uint chan, uint range, uint aref, [CCode (array_length = false)] uint[] data, uint n);
        int data_read_hint (uint subd, uint chan, uint range, uint aref);
        int data_read_delayed (uint subd, uint chan, uint range, uint aref, [CCode (array_length = false)] uint[] data, uint nano_sec);
        int data_write (uint subd, uint chan, uint range, uint aref, uint data);
        int dio_config (uint subd, uint chan, uint dir);
        int dio_get_config (uint subd, uint chan, [CCode (array_length = false)] uint[] dir);
        int dio_read (uint subd, uint chan, [CCode (array_length = false)] uint[] bit);
        int dio_write (uint subd, uint chan, uint bit);
        int dio_bitfield2 (uint subd, uint write_mask, [CCode (array_length = false)] uint[] bits, uint base_channel);
        int dio_bitfield (uint subd, uint write_mask, [CCode (array_length = false)] uint[] bits);

        /* streaming I/O (commands) */
        int get_cmd_src_mask (uint subdevice, Command cmd);
        int get_cmd_generic_timed (uint subdevice, Command cmd, unsigned chanlist_len, unsigned scan_period_ns);
        int cancel (uint subdevice);
        int command (Command cmd);
        int command_test (Command cmd);
        int poll (uint subdevice);

        /* buffer control */
        int set_max_buffer_size (uint subdev, uint max_size);
        int get_buffer_contents (uint subdev);
        int mark_buffer_read (uint subdev, uint bytes);
        int mark_buffer_written (uint subdev, uint bytes);
        int get_buffer_offset (uint subdev);
    }

    /*
     * Static utility functions
     */
    public static OorBehavior set_global_oor_behavior (OorBehavior oor);
    public static int loglevel (int loglevel);
    public static void perror (string s);
    public static string strerror (int errnum);
    public static int errno (int loglevel);
    public static double to_phys (uint data, Range rng, uint maxdata);
    public static uint from_phys (double data, Range rng, uint maxdata);
    public static int sampl_to_phys ([CCode (array_length = false)] double[] dest, int dst_stride, [CCode (array_length = false)] uint16[] src, int src_stride, Range rng, uint maxdata, int n);
    public static int sampl_from_phys ([CCode (array_length = false)] uint16[] dest, int dst_stride, [CCode (array_length = false)] double[] src, int src_stride, Range rng, uint maxdata, int n);
}
