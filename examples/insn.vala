using Comedi;
using Posix;

public class InstructionAcquisition : GLib.Object {
    private Device dev;
    private int subdevice;
    private Instruction[] insn = new Instruction[3];
    private InstructionList il;
    private uint t1[2];
    private uint t2[2];
    private uint data[128];

    public void run () {
        insn[0] = Instruction ();
        insn[1] = Instruction ();
        insn[2] = Instruction ();
        dev = new Device ("/dev/comedi0");
        if (dev != null) {
            perror ("/dev/comedi0");
        }
        /**
         * Instruction to get the time of day.
         **/
        insn[0].insn =  InstructionAttribute.GTOD;
        insn[0].n = 2;
        insn[0].data = t1;
        /* Instruction to do 10 analog input reads. */
        insn[1].insn = InstructionAttribute.READ;
        insn[1].n = 10;
        insn[1].data = data;
        insn[1].subdev = 0;
        insn[1].chanspec = pack (0, 4, AnalogReference.GROUND);
        /* Instruction 2 also gets the time of day. */
        insn[2].insn = InstructionAttribute.GTOD;
        insn[2].n = 2;
        insn[2].data = t2;
//        int ret = dev.do_insn (insn[1]);
//        perror ("/dev/comedi0 do_insn");

        message ("insn.length: %d", insn.length);
        il.n_insns = 3;
        il.insns = insn;

        int ret = dev.do_insnlist (il);
        if (ret < 0) {
            perror ("/dev/comedi0 do_insnlist");
        }
        message ("Initial time: %u.%06u\n", t1[0], t1[1]);
        for (int i = 0; i < 10; i++) {
            message ("%u", data[i]);
        }
        message ("Final time: %u.%06u\n", t2[0], t2[1]);
        message ("Difference time (microseconds): %ld\n", (t2[0] - t1[0]) * 1000000 + (t2[1] -t1[1]));
    }
}

public static int main (string[] args) {

    InstructionAcquisition app = new InstructionAcquisition ();
    app.run ();
    return 0;
}

