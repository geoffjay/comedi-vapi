using Comedi;

public class InstructionAcquisition : GLib.Object {
    Device dev;
    int subdevice;
    Instruction insn ;

    public void run () {
        message ("gotta run!");
    }
}

public static int main (string[] args) {

    InstructionAcquisition app = new InstructionAcquisition ();
    app.run ();
    return 0;
}

