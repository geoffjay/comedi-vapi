using Comedi;

//class ReadChannel : GLib.Object {
//
//    private Device dev;
//    private Range range_info;
//    private uint data[1];
//    private uint maxdata;
//    private double physical_value;
//
//    public void run () {
//        dev = new Device ("/dev/comedi0");
//        dev.data_read (0, 0, 4,  AnalogReference.GROUND, data);
//        set_global_oor_behavior (OorBehavior.NAN);
//        range_info = dev.get_range (0, 0, 4);
//        maxdata = dev.get_maxdata (0, 0);
//        physical_value = to_phys (data[0], range_info, maxdata);
//        stdout.printf ("%g \n", physical_value);
//    }
//}
//
public static int main (string[] args) {
//    ReadChannel app = new ReadChannel ();
//    app.run ();
    return 0;
}
