(
b = Buffer.alloc(s,44100 * 4, 2);

Ndef(\test, {
    var left, right;
    left = Impulse.ar(0.5);
    right = Impulse.ar(0.5);

    PingPong.ar(b, [left,right], LFNoise0.kr(1, 0.3, 0.2), 0.7, 1.1);
});
)

Ndef(\test).play


m = NetAddr("127.0.0.1", NetAddr.langPort); // loopback


(
f = OSCFunc({|msg| msg.postln; }, '/t', nil, nil, [{|a| a > 3}]);
)

m.sendMsg('/t', 20)