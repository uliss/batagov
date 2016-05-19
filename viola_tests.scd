(
{BPF.ar(PinkNoise.ar(), 440, MouseX.kr(0, 2)) * 1}.play
)

{1.0.rand}!4 + 1

(
{
    var sig1, sig2;
    var sig = SoundIn.ar(0) ! 2;
    var amp =  Amplitude.kr(sig);
    amp.linlin(0, 1, 100, 400).poll;
    // sig = HPF.ar(sig, 500);
    // sig = BRF.ar(sig, 50, 1.25);
    // sig = (sig * 100).softclip;
    sig1 = Ringz.ar(sig, amp.linlin(0, 1, 100, 400), MouseX.kr(0.1, 2));
    sig1 = sig1 * 0.1;
    sig1 = Mix.ar([sig * 0.2, sig1]);
    sig1.softclip;
}.play
)

c = ~part2_3
b = Buffer.alloc(s,2048,1);

( // yet another spectral delay where the each bin gets a random delay time
{ // SPECTRAL RANDOM
	var in, chain, v;
    // in = PlayBuf.ar(1, c, BufRateScale.kr(c), loop: 0);
    in = SPU_ViolaInCommon.ar;
    // default buffer size - 1024
	chain = FFT(LocalBuf(256), in);
    // v = MouseX.kr(0.1, 10);
    v = 4;
	chain = chain.pvcollect(b.numFrames, {|mag, phase, index|
        mag + DelayN.kr(mag, v, v*1.0.rand);
	}, frombin: 0, tobin: 128, zeroothers: 0); // default bin: 256
	Out.ar(0, 0.9 * IFFT(chain).dup * Line.kr());
}.play(s);
)

( // SPECTRAL 2
{
    // the high frequencies get longer delay times
    // this is the trick: 250.do({|i|(i*(250.reciprocal)).postln;})
	var in, chain, v;
    // in = PlayBuf.ar(1, c, BufRateScale.kr(c), loop: 1);
    in = SPU_ViolaInCommon.ar;
	chain = FFT(LocalBuf(1024), in);
    // v = MouseX.kr(0.1, 2);
    v = 2;
	chain = chain.pvcollect(b.numFrames, {|mag, phase, index|
		mag + DelayN.kr(mag, 2, v*(index*256.reciprocal));
	}, frombin: 0, tobin: 256, zeroothers: 0);

	Out.ar(0, 0.5 * IFFT(chain).dup * Line.kr());
}.play(s);
)

// square the magnitude and put a random phase (from 0 to pi (3.14))
( // SPECTRAL SQUARE
{
	var in, chain, v;
    // in = PlayBuf.ar(1, c, BufRateScale.kr(c), loop: 1);
    // in = PlayBuf.ar(1, c, BufRateScale.kr(c), loop: 1);
    in = SPU_ViolaInCommon.ar;
	chain = FFT(LocalBuf(1024), in);
	chain = chain.pvcollect(b.numFrames, {|mag, phase, index|
		[mag.sqrt, pi.rand];
	}, frombin: 0, tobin: 256, zeroothers: 1);
	Out.ar(0, 0.5 * IFFT(chain).dup * Line.kr());
}.play(s);
)

// here we use the index and we subtract it with a LFPar on a slow sweep
(
{
	var in, chain, v;
	in = PlayBuf.ar(1, c, BufRateScale.kr(c), loop: 1);
	chain = FFT(LocalBuf(1024), in);
	chain = chain.pvcollect(b.numFrames, {|mag, phase, index|
		if((index-LFPar.kr(0.15).range(2, b.numFrames/20)).abs < 10, mag, 0); // swept bandpass
	}, frombin: 0, tobin: 250, zeroothers: 0);
	Out.ar(0, 0.5 * IFFT(chain).dup);
}.play(s);
)

(
// SPECTRAL 4
SynthDef(\pvmagfreeze, { arg out=0, soundBufnum1;
	var in, chain;
	in = PlayBuf.ar(1, soundBufnum1, BufRateScale.kr(soundBufnum1), loop: 1);
	//in = WhiteNoise.ar(0.2);
	chain = FFT(LocalBuf(2048), in);
	chain = PV_MagFreeze(chain, MIDI ); // on the right side it freezes
	Out.ar(out, 0.5 * IFFT(chain)!2);
}).play(s,[\out,0, \soundBufnum1, c.bufnum]);
)

(
{
    var sig, sig1, sig2, sig3;
    sig = PlayBuf.ar(1, ~part2_1, BufRateScale.kr(~part2_1), loop: 1);
    // sig = SoundIn.ar(0) ! 2 * 4;
    // sig = SPU_ViolaInCommon.ar ! 2 * 4;
    sig = sig.tanh;

    // sig = GlitchBPF.ar(sig, MouseX.kr(10, 100));
    // sig1 = Ringz.ar(sig, 55.midicps) * Amplitude.kr(sig);
    // sig = XFade2.ar(sig1, sig, 0.5);
    // sig = MoogLadder.ar(sig * 4, LFNoise1.kr(MouseX.kr(1, 200)).linlin(0, 1, 1000, 5000));
    // sig1 = Balance.ar(sig1, sig);
    sig = FreeVerb.ar(sig);
    sig = GrainIn.ar(2, Impulse.kr(10), MouseX.kr(0.05, 0.1), sig, LFNoise1.kr(2));

    // sig = Mix.ar([sig1]);
    sig = sig.softclip * 2.4;
    sig = AllpassN.ar(sig);
}.play;
)
