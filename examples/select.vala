using Comedi;
using Posix;

class Select : GLib.Object {

    Device dev;
    int subdevice;
    const int BUFSZ 10;
    ushort[] buf = new ushort[BUFSZ];
    const int N_CHANS = 256;
    uint[] chanlist = new uint[N_CHANS];
    Range[] range_info = new Range[N_CHANS];
    uint[] maxdata = new uint[N_CHANS];
    int ret;
int i;

