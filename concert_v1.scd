// Anton Batagov "The One Thus Gone"
// steps:
// 1. boot SERVER
// 2. init SYNTHS
// 3. start CONTROL




// 1) BOOT SERVER
SoundCard.saffire;
// 2) Buffer alloc
~part2_1 = Buffer.read(s, "/Users/serj/concerts/2016.06.09 - Batagov/sounds/batagov_test_2.1_mono.wav");
~part2_2 = Buffer.read(s, "/Users/serj/concerts/2016.06.09 - Batagov/sounds/batagov_test_2.2_mono.wav");
~part2_3 = Buffer.read(s, "/Users/serj/concerts/2016.06.09 - Batagov/sounds/batagov_test_2.3_mono.wav");

// 3) TEST SOUND
{SinOsc.ar(1220, mul: 0.005) ! 2}.scope
{SPU_ViolaInCommon.ar}.scope

// 4) INIT SYNTHS!!!!
(
MIDIIn.connectAll;

(
Ndef(\violaNormal, {
    |amp = 1|
    var out, in;
    in = SoundIn.ar(0);
    // in = SPU_ViolaInCommon.ar();
    // in = SPU_ViolaReverb.ar(in, room: 0.7);
    // in = SPU_ViolaCompress.ar(SPU_ViolaFilter.ar(SPU_ViolaIn.ar(0)));
    // in = PlayBuf.ar(1, ~part2_2, BufRateScale.kr(~part2_2), loop: 1);
    out = Pan2.ar(in * amp.lag(2), 0);
    out;
});


Ndef(\violaPart1, {
    |amp = 0.5, ratio = 1.0001|
    var in, sig, in2, in1, rfreq = 100.midicps, dist, distort = 1, in3, outL, outR;
    in = SPU_ViolaCompress.ar(SPU_ViolaFilter.ar(SPU_ViolaIn.ar(0)));
    in = BRF.ar(in, 250, 0.1);
    // in = BRF.ar(in, 430, 0.4);
    // in = SPU_ViolaInCommon.ar;
    // in = PlayBuf.ar(1, ~part2_1, BufRateScale.kr(~part2_1), loop: 1);
    rfreq = Amplitude.ar(in, 1).linlin(0,1, 100, 1000);
    // in = Ringz.ar(in, 50.midicps);
    // in = Pluck.ar(in, Impulse.kr(10));
    // in =  Ringz.ar(in, 1100);
    // in = in.softclip;

    in2 = PitchShift.ar(in, 0.2, 0.5) * 0.25; /// 2 movement 0.3

    dist = ((in + in2) * 13).tanh.softclip * distort.lag(0.5);
    in = dist * 0.1 * amp.lag(2);

    in3 = MoogLadder.ar(in, LFTri.ar(10.reciprocal).range(250, 3000), 0.9);
    in = XFade2.ar(in, in3, 0.5);

    in1 = PitchShift.ar(in, 0.1, pitchRatio: 1.0006);

    // in2 = PitchShift.ar(in, pitchRatio: {1.0.linrand.linlin(0,1, 0.5, 2)} ! 10);
    [in, in1] * 1.7;
    // in = in.softclip * 0.2;
    // AllpassL.ar(in, 1, 1, 1) ! 2;
});


Ndef(\violaPart2, {
    |amp = 0.5, distort = 1, ratio = 1.002 |
    var in, in1, sig, in2, dist, moog, moogf;
    // in = SoundIn.ar(0, amp.lag(0.5));
    in = SPU_ViolaCompress.ar(SPU_ViolaFilter.ar(SPU_ViolaIn.ar(0)));
    // in = PlayBuf.ar(1, ~part2_1, BufRateScale.kr(~part2_1), loop: 1);
    in1 = PitchShift.ar(in, 0.1, pitchRatio: ratio) * 0.3;
    in2 = PitchShift.ar(in, 0.3, 0.5) * distort.lag(0.1) * 0.11;
    in = Mix.ar([[in, in1], in2]);
    // in = Mix.ar(in2) ! 2;
    sig = SPU_ViolaReverb.ar(SPU_ViolaFilter.ar(in), 0.7, 0.9, 0.5); // for 3 part 0.7, 0.9, 0.5
    // for begining - default
    // sig = BPF.ar(PinkNoise.st)
    moog = Amplitude.kr(in, 1, 1).ampdb;
    // moogf = moog.linlin(-70, 0, 300, 9000);
    // amp.poll;
    // moogf.poll;

    // sig = MoogLadder.ar(sig, moogf, 1);
    // sig = MoogLadder.ar(sig, LFNoise1.kr(0.2, 5000, 100), 0);
    // sig = PitchShift.ar(in, 0.1, LFTri.kr(1).range(0, 0.1) + 1);
    // sig.collapse;


    dist = (sig * 5).tanh.softclip * distort.lag(0.5);

    // sig = MoogLadder.ar(sig, moogf, 0.1);
    // sig = XFade2.ar(sig, dist, distort.linlin(0,1,-1,1));

    sig = HPF.ar(sig, 100);

    // sig = AllpassN.ar(sig, 10, 10, 200);
    // sig = BPF.ar(sig, LFNoise1.kr(40, 5000, 100));
    // sig = LPF.ar(sig, 6000);
    // sig = XFade2.ar(sig, dist, )
    // sig = sig.distort;
    // sig = sig * sig;
    sig = sig.softclip;
    sig = sig * amp.lag(2);
};
);

Ndef(\violaPart3, {
/*    |amp = 0.5, distort = 1, ratio = 1.002 |
    var out, in, chain, v;
    // in = PlayBuf.ar(1, ~part2_3, BufRateScale.kr(~part2_3), loop: 1);
    in = SPU_ViolaCompress.ar(SPU_ViolaFilter.ar(SPU_ViolaIn.ar(0)));
    // default buffer size - 1024
	chain = FFT(LocalBuf(512), in);
    // v = MouseX.kr(0.1, 10);
    v = 4;
	chain = chain.pvcollect(512, {|mag, phase, index|
        mag + DelayN.kr(mag, v, v*1.0.rand);
	}, frombin: 0, tobin: 128, zeroothers: 1); // default bin: 256
	out = IFFT(chain).dup * Line.kr();
    out = Balance.ar(out, in) * amp.lag(2);
    out;*/
});

Ndef(\violaCadence, {
    arg amp = 1;
    var outL, outR, sig, sigD;
    sig = SPU_ViolaIn.ar(0);
    outL = AllpassL.ar(sig, 1, 0.3/*LFNoise0.kr(1, 0.3, 0.2)*/, 4);
    // outR = AllpassL.ar(sig, 8, LFNoise0.kr(1, 0.3, 0.5), 3);
    outR = AllpassL.ar(PitchShift.ar(sig, 0.3, LFNoise1.kr(3, 2.3, 2), 0.1, 0.2), 1, 0.24, 3);
    // b = Buffer.alloc(s,44100 * 4, 2);
    outR = Greyhole.ar(outR);
    // sigD = AllpassL.ar(sig, )
    // outR = Impulse.ar(0.5);
    // PingPong.ar(LocalBuf(44100 * 4, 2), [left,right], LFNoise0.kr(1, 0.3, 0.2), 0.7, 1.1);
    // [outL], outR] * amp.lag(1);
    Pan2.ar(outR, LFNoise1.ar(3).linlin(0,1, -1, 1)) * amp;
});

)
)

// 5) CONTROL!
(
~n = NdefMixer(s);

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
        Ndef(\violaPart2).stop;
    } {
        var r = 1 + 1.0.rand;
        "Random ratio: %".format(r).postln;

        Ndef(\violaPart2).set(\ratio, r);
        Ndef(\violaPart2).play;
        Ndef(\violaPart2).set(\ratio, r);
    };
}, 2);
MIDIFunc.cc({ |m|
    if(m == 0) {
        Ndef(\violaCadence).stop;
    } {
        // Ndef(\violaPart3).set(\ratio, 1.001);
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


// PEDAL
MIDIFunc.cc({ |m|
    var v = m.linlin(10, 127, 0, 1);
    "AMP: %".format(v).postln;
    Ndef(\violaPart1).set(\amp, v);
    Ndef(\violaPart2).set(\amp, v);
    Ndef(\violaPart3).set(\amp, v);
    Ndef(\violaNormal).set(\amp, v);
    Ndef(\violaCadence).set(\amp, v);
}, 7);

)


(
{
    var in = SPU_ViolaInCommon.ar, in2;
    in  = AllpassL.ar(in, 0.1, 0.1, 5);
    in2 = Pan2.ar(in, 0);
    Out.ar(0, in2);
}.play();

)


// GUI
Ndef(\violaPart1).gui;
Ndef(\violaPart1).play;
Ndef(\violaPart2).gui;
Ndef(\violaPart2).play;

// TEST BUFFERS
~part2_1.play;
~part2_2.play;
~part2_3.play;

















