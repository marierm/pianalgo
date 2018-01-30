runInTerminal("~/installers/Pianoteq 5 STAGE/amd64/Pianoteq 5 STAGE".standardizePath.shellQuote);
// runInTerminal("qjackctl".shellQuote);
MIDIClient.init;
~midiOut = MIDIOut.newByName("Pianoteq Midi Input", "Pianoteq Midi Input");
// ~midiOut = MIDIOut.newByName("UA-4FX", "UA-4FX MIDI 1");
// ~midiOut.allNotesOff(0);


~midiOut.noteOn(0, 72);~midiOut.noteOff(0, 72);

(
// Arrays of crescendos/decrescendos of different sizes.  (Not used!)
~fills = Array.fill(17, {|i|
	[0.5,0.8,0.5].resamp1((17..87).choose).squared;
});

// Basic Pbind: sents generic things.
~core = Pbind(
	\type, \midi,
	\midiout, ~midiOut,
	\root, -1, // Song is in B
	\dur, 1/4, // durations are 16th notes.
	\tempo, 2.0 // tempo is 120 bpm
);

// Pbindf adds (or overrides) values to another Event Pattern.
// This is just a two note chord:  B and D#.
~tierce = Pbindf( ~core,
	\degree, Pseq([[0,2]], inf),
);


~osc3ce = Pbindf( ~tierce,
	\ctranspose, Pseq([0,-1], inf), // alternate with one semitone lower. 
	\octave, 5, // higher octave
	\amp, Pseg([0.3, 0.64, 0.3],Pseq([2,4,5,2,4,4,3],inf),\exp,inf)	// cresc/decresc
);

~oscOct = Pbindf( ~osc3ce,
	\octave, Pstutter(8,Prand([4,6,7], inf)),
	\amp, Pseq([0.5,0.7,0.5].resamp1(8).squared, inf),
);

~oscBass = Pbindf( ~core,
	\octave, 2,
	\degree, Pstutter(48, Prand([3,5,6,7,8], inf), inf),
	\amp, Pseg([0.5, 0.8, 0.5],12,\exp,inf)	
);

~bassFinale = Pbindf( ~core,
	\octave, 2,
	\degree, Pstutter(80, 7, inf),
	\amp, Pseg([0.64, 0.5],20,\exp,inf),
	\dur, Pseq((1/4 ! 79) ++ 20)
);


~accordRepet = Pbindf( ~tierce,
	\repTimes, Prand([12,24,32], inf),
	\degree, Pstutter(Pkey(\repTimes),Prand([[0,2],[1,3],[2,4],[3,5]],inf)),
	\amp, Pseg([0.3, 0.71, 0.3],Pkey(\repTimes)/8)
);

~accordRepet = Pbindf( ~core,
	\repTimes, Prand([12,24,32], inf),
	\degree, Pstutter(Pkey(\repTimes),Prand([[0,2],[1,3],[2,4],[3,5]],inf)),
	\amp, Pseg([0.3, 0.73, 0.3],Pkey(\repTimes)/8, \exp, inf)
);

~chromaSec = Pbindf( ~core,
	// \ctranspose, Pseq({
	// 	var a= List[0];
	// 	33.do({a.add(a.last + ([1, -1].choose))});
	// 	a.reverse;
	// }.value, 1),
	\degree, Prand([0,1,2,3,4,5,6,1s,4s], inf),
	\octave, 7,
	\amp, Pseg([0.3,0.8], 200, \exp, 1)
);

~chromaSec2 = Pbindf( ~chromaSec,
	\octave, 6,
);

~chromaSec3 = Pbindf( ~chromaSec,
	\octave, 4,
);

~master = Ptpar([
	0, Pfindur(200, ~osc3ce),
	40, Pfindur(200, ~oscOct),
	80, Pfindur(400, ~oscBass),
	200, Pfindur(240, ~accordRepet),
	280, Pfindur(200, ~chromaSec),
	340, Pfindur(140, ~chromaSec2),
	420, Pfindur(60, ~chromaSec3),	
	480, Pfindur(20, ~osc3ce),
	480, Pfindur(20, ~bassFinale),
],1).play;
)


~master.stop;


x = ~osc3ce.play;
y = ~oscOct.play
z = ~oscBass.play;
~zz = ~accordRepet.play;
~ch = ~chromaSec.play;
~ch = ~bassFinale.play;


x.stop;
y.stop;
z.stop;
~zz.stop;
~ch.stop;





(
y.stop;
~minNote = 21;
~maxNote = 108;
// ~maxNote = 70;
~iv = 12;								// intervalle
~iv = 12;								// intervalle
~notes = [0,1,2,3,4,5,6,7,8,9,10,11];
~octaves = [2,3,4,5,6,7,8];
~scale = [0,1,2,3,4,5,6,7,8,9,10,11];
~numNotes = ~notes.size * ~octaves.size;
x = Pbind(
	\type, \midi,
	\midiout, ~midiOut,
	\degree, Pser(~notes, inf),
	\scale, ~scale,
	\octave, Pseq(
		~octaves.collect({|i| (i ! ~notes.size)}).flatten, inf
	),
	\dur, 1.0,
	\amp, Pseq([0.5,0.8,0.7].resamp1(~numNotes).squared.rotate(0), inf),
	\tempo, 14.0
);
y = Ptpar([(0,~iv..(~numNotes)),x].lace((~numNotes * 2 / ~iv).asInteger), inf).play;

y = Ptpar([(0,~iv..(~numNotes)),x].lace((~numNotes * 2 / ~iv).asInteger), inf).play;
)
y.stop;



(
PR(\abstractProcess).v.clone({
	~event = Event.default;
	~octs = [];
	~octaves_ = { arg val;
		~octs = val;
		~octave = Pseq(
			~octs.collect({|i| (i ! ~notes.size)}).flatten, inf
		);
		~numNotes = ~notes.size * ~octs.size;
		~amp = Pseq([0.2,0.5,0.2].resamp1(~numNotes).squared.rotate(0), inf);
	};
	~notes_ = { arg newNotes;
		~notes = newNotes;
		~degree = Pseq(~notes, inf);
		~octaves_.value(~octs);
	};
	~prep = {
		// ~octave = 5;
		~numNotes = 0;
		~iv = 1;
		~notes = [0,2,5,6];
		~scale = [0,2,3,5,7,8,10];
		// ~midiOut = MIDIOut.newByName("Pianoteq Midi Input", "Pianoteq Midi Input");
		~midiOut = MIDIOut.newByName("UA-4FX", "UA-4FX MIDI 1");
		~degree = Pseq(~notes, inf);
		~octaves_.value([4,5,6]);
		~dur = 1.0;
		~legato = 0.8;
		~amp = Pseq([0.2,0.5,0.1].resamp1(~numNotes).squared.rotate(0), inf);
		~tempo = 4.0;
	};
	~asPattern = {
		~piano = Pbind(
			\type, \midi,
			\midiout, ~midiOut,
			\degree, BPStream(\degree),
			\scale, BPStream(\scale),
			\octave, BPStream(\octave),
			\dur, BPStream(\dur),
			\legato, BPStream(\legato),
			\amp, BPStream(\amp),
			\tempo, BPStream(\tempo)
		);
	};
	~stopCleanup = {
	};
}) => PR(\piano);
)

PR(\piano) => BP(0);

BP.freeAll;
BP(0).play;
BP(0).stop;


BP(0).octave
BP(0).scale_([0,2,3,5,7,8,11]);
BP(0).octaves_([4,5,4]);
BP(0).tempo_(4.0);
BP(0).notes_([0,2,4,6]);
Pseq([0,1,2,3,4,5,6,7],inf) =>.notes BP(0);
Pseq([34,5,6],inf) =>.octave BP(0);
BP(0).iv_(1);

PR(\piano) => BP(1);

BP(1).play;
BP(1).scale_([0,1,2,5,7,8,10]);
BP(1).octaves_([6,7]);
BP(1).notes_([0,2,5,6]);
Pn(Pshuf([0,1,2,3,5,6,7]), 4) =>.notes BP(1);
Pseq([[2,3,6]],inf) =>.degree BP(1);
Pseq(~randBar.value(5, 0.25) ,inf) =>.dur BP(1);
Pseq([1.0] ,inf) =>.dur BP(1);
Pseq([3.0] ,inf) =>.tempo BP(1);



~randBar = { arg maxDur=6.0, minDur = 0.25;
	var list = List[];
	{list.sum < 4.0}.while({
		list.add(minDur * (maxDur.rand + 1));
		(list.sum > 4.0).if({
			list.pop;
			list.add(4.0 - list.sum);
		});
	});
	list;
};
a = ~randBar.value(4)


BP(1).stop;
BP(1).notes.list
BP(1).amp.list

