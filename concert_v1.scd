// Anton Batagov "The One Thus Gone"
// steps:
// 1. boot SERVER
// 2. init SYNTHS
// 3. start CONTROL
// BlueRig mapping:
// - button [1]: Viola distortion
// - button [2]: Viola long delay
// - button [3]: Viola impro
// - button [4]: Viola normal sound
// - foot pedal [1]: volume
// Korg Nanokontrol:
// - [setup]: NdefMixer


// 1) BOOT SERVER
(
"1. Server init".postln;
SoundCard.mbox;
MIDIIn.connectAll;
"... go to step 2 >>>>>";
)

// 2) TEST SOUND
{SinOsc.ar(1220 ! 2, mul: 0.005)}.scope

// 3) INIT SYNTHS!!!!
(

"2. Init Synths".postln;

Spec.add(\pan, [-1, 1]);
Spec.add(\violaReject1, [220, 260]);
Spec.add(\violaReject1, [220, 260]);
Spec.add(\octaverAmp, [0, 1]);
Spec.add(\dist, [6, 15]);
Spec.add(\moogFreq, [4, 20]);
Spec.add(\moogLevel, [0, 1]);
Spec.add(\gain, [1, 5]);
Spec.add(\detune, [1, 50]);
Spec.add(\cadenceDelayFreq, [1, 10]);

Ndef(\violaNormal, {
    |amp = 1|
    var out, in;
    in = SoundIn.ar(0);
    out = Pan2.ar(in * amp.lag(2), \pan.kr(-0.3));
    out * \gain.kr(2.5);
});


Ndef(\violaPart1, {
    |amp = 0.5, ratio = 1.0001|
    var in, sig, in2, in1, rfreq = 100.midicps, dist, distort = 1, in3, outL, outR;
    in = SPU_ViolaCompress.ar(SPU_ViolaFilter.ar(SPU_ViolaIn.ar(0)));
    in = BRF.ar(in, \violaReject1.kr(250), 0.1);
    // in = BRF.ar(in, 430, 0.4);

    in2 = PitchShift.ar(in, 0.2, 0.5) * \octaverAmp.kr(0.25); /// 2 movement 0.3

    dist = ((in + in2) * \dist.kr(13)).tanh.softclip * distort.lag(0.5);
    in = dist * 0.1 * amp.lag(2);

    in3 = MoogLadder.ar(in, LFTri.ar(\moogFreq.kr(10).reciprocal).range(250, 3000), 0.9);
    in = XFade2.ar(in, in3, \moogLevel.kr(0.5));

    in1 = PitchShift.ar(in, 0.1, pitchRatio: \detune.kr(6) / 10000.0 +  1.0);
    [in, in1] * \gain.kr(3);
});


Ndef(\violaPart2, {
    |amp = 0.5, distort = 1, ratio = 1.002 |
    var in, in1, sig, in2, dist, moog, moogf;
    in = SPU_ViolaCompress.ar(SPU_ViolaFilter.ar(SPU_ViolaIn.ar(0)));
    in1 = PitchShift.ar(in, 0.1, pitchRatio: ratio) * 0.3;
    in2 = PitchShift.ar(in, 0.3, 0.5) * distort.lag(0.1) * 0.11;
    in = Mix.ar([[in, in1], in2]);
    sig = SPU_ViolaReverb.ar(SPU_ViolaFilter.ar(in), 0.7, 0.9, 0.5); // for 3 part 0.7, 0.9, 0.5
    // for begining - default
    moog = Amplitude.kr(in, 1, 1).ampdb;
    dist = (sig * 5).tanh.softclip * distort.lag(0.5);
    sig = HPF.ar(sig, 100);
    sig = sig.softclip;
    sig = sig * amp.lag(2) * 2;
};
);

Ndef(\violaLong).clear;
Ndef(\violaLong, {
    arg amp = 1;
    var outL, outR, sig, sigD;
    sig = Ndef(\violaNormal).ar;
    sig = AllpassL.ar(sig, 1, 0.3, 4);
    sig = Greyhole.ar(sig);
    sig * amp * \gain.kr(1);
});

Ndef(\violaCadence).clear;
Ndef(\violaCadence, {
    arg amp = 1;
    var outL, outR, sig, sigD;
    sig = SPU_ViolaIn.ar(0);
    outL = AllpassL.ar([sig,
        PitchShift.ar(sig, 0.2, 1.4, 0.3),
        PitchShift.ar(sig, 0.2, 1.1, 0.3),
        PitchShift.ar(sig, 0.2, 1.2, 0.3)
    ], 2, [1/7, 1/5, 1/3, 1/2] * 2, 2, [0.4, 0.3, 0.2, 0.35]);
    outL = NumChannels.ar(outL);

    outR = AllpassL.ar(
        PitchShift.ar(sig, 0.3,
            LFNoise1.kr(\cadenceDelayFreq.kr(1), 2.3, 3), 0.1, 0.2), 1, 0.24, 3);

    outR = Greyhole.ar(LPF.ar(outL, 1000)); // 3rd outR
    sig = Mono(outR * 0.01 + outL);
    Pan2.ar(sig, LFNoise1.ar(3).linlin(0,1, -0.3, 0.3)) * amp * \gain.kr(5);
});

"... go to step 3 >>>>>".postln;
)

// 4) CONTROL!
(
"3. Init MIDI and OSC".postln;

MIDIFunc.cc({ |m|
    if(m == 0) {
        Ndef(\violaPart1).stop;
    } {
        Ndef(\violaPart1).set(\ratio, 1.001);
        Ndef(\violaPart1).play;
    };
}, 1);
MIDIFunc.cc({ |m|
    if(m == 0) {
        Ndef(\violaLong).stop;
    } {
        Ndef(\violaLong).play;
    };
}, 2);
MIDIFunc.cc({ |m|
    if(m == 0) {
        Ndef(\violaCadence).stop;
    } {
        Ndef(\violaCadence).play;
    };
}, 3);
MIDIFunc.cc({ |m|
    if(m == 0) {
        Ndef(\violaNormal).stop;
    } {
        Ndef(\violaNormal).play;
    };
}, 4);

MIDIFunc.cc({ |m|
    if(m == 127) {
        {~n = NdefMixer(s)}.defer(0);
    }
}, 60);


// PEDAL
MIDIFunc.cc({ |m|
    var v = m.linlin(10, 127, 0, 1);
    "AMP: %".format(v).postln;
    Ndef(\violaPart1).set(\amp, v);
    Ndef(\violaPart2).set(\amp, v);
    Ndef(\violaPart3).set(\amp, v);
    Ndef(\violaNormal).set(\amp, v);
    Ndef(\violaCadence).set(\amp, v);
    Ndef(\violaLong).set(\amp, v);
}, 7);

"Let's start'";

)













