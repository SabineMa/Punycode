Class {
	#name : #PunycodeConverter,
	#superclass : #Object,
	#instVars : [
		'base',
		'tmin',
		'tmax',
		'skew',
		'damp',
		'bias',
		'n',
		'caseSensitive'
	],
	#category : #Punycode
}

{ #category : #helper }
PunycodeConverter >> adaptDelta: deltaValue numpoints: numpoints firsttime: firsttime [
	| k |
	firsttime
		ifTrue: [ delta := deltaValue // damp ]
		ifFalse: [ delta := deltaValue // 2 ].
	delta := delta + (delta // numpoints).
	k := 0.
	[ delta > ((base - tmin) * tmax // 2) ]
		whileTrue: [ 
			delta := delta // (base - tmin).
			k := k + base ].
	^ k + ((base - tmin + 1) * delta // (delta + skew))
]

{ #category : #constants }
PunycodeConverter >> base [
	^ 36
]

{ #category : #'initialize-release' }
PunycodeConverter >> caseSensitive [
	caseSensitive := true
]

{ #category : #converting }
PunycodeConverter >> decode: aURLString [
	| t i oldi w k output input |
	self reset.
	input := aURLString readStream.
	output := WriteStream on: String new.
	output nextPutAll: (input upToAll: 'xn--').
	output nextPutAll: (input upTo: $-).
	output := output contents asOrderedCollection.
	i := 0.
	[ input atEnd ]
		whileFalse: [ 
			| digit flag |
			oldi := i.
			w := 1.
			flag := true.
			k := base.
			[ flag ]
				whileTrue: [ 
					digit := self decodeDigit: input next codePoint.
					i := i + (digit * w).
					k <= (bias + tmin)
						ifTrue: [ t := tmin ]
						ifFalse: [ 
							k >= (bias + tmax)
								ifTrue: [ t := tmax ]
								ifFalse: [ t := k - bias ] ].
					digit < t
						ifTrue: [ flag := false ].
					w := w * (base - t).
					k := k + base ].
			bias := self adaptDelta: i - oldi numpoints: output size + 1 firsttime: oldi = 0.
			n := n + (i // (output size + 1)).
			i := i \\ (output size + 1).
			output add: (Character value: n) afterIndex: i.
			i := i + 1 ].
	^ String withAll: output
]

{ #category : #helper }
PunycodeConverter >> decodeDigit: codePoint [
	codePoint - 48 < 10
		ifTrue: [ ^ codePoint - 22 ]
		ifFalse: [ 
			codePoint - 65 < 26
				ifTrue: [ ^ codePoint - 65 ]
				ifFalse: [ 
					codePoint - 97 < 26
						ifTrue: [ ^ codePoint - 97 ]
						ifFalse: [ ^ base ] ] ]
]

{ #category : #constants }
PunycodeConverter >> delimiter [
	^ $-
]

{ #category : #converting }
PunycodeConverter >> encode: aURLString [
	| t h b basicCodePoints nonBasicCodePoints input output delta q k m flag |
	self reset.
	basicCodePoints := aURLString select: [ :c | c isOctetCharacter ].
	nonBasicCodePoints := (aURLString reject: [ :c | c isOctetCharacter ]) asSortedCollection.
	output := WriteStream on: String new.
	output nextPutAll: 'xn--'.
	basicCodePoints do: [ :c | output nextPut: c ].
	basicCodePoints isEmpty not
		ifTrue: [ output nextPut: $- ].
	input := aURLString.
	delta := 0.
	h := b := basicCodePoints size.
	[ h < input size ]
		whileTrue: [ 
			m := nonBasicCodePoints removeFirst codePoint.
			delta := delta + ((m - n) * (h + 1)).
			n := m.
			input
				do: [ :char | 
					| cp |
					cp := char codePoint.
					cp < n
						ifTrue: [ delta := delta + 1 ].
					cp = n
						ifTrue: [ 
							q := delta.
							k := base.
							flag := true.
							[ flag ]
								whileTrue: [ 
									t := k <= (bias + tmin)
										ifTrue: [ tmin ]
										ifFalse: [ 
											k >= (bias + tmax)
												ifTrue: [ tmax ]
												ifFalse: [ k - bias ] ].
									q < t
										ifTrue: [ flag := false ]
										ifFalse: [ 
											output nextPut: (Character value: (self encodeDigit: t + ((q - t) \\ (base - t)) flag: 0)).
											q := (q - t) // (base - t) ].
									k := k + base ].
							output nextPut: (Character value: (self encodeDigit: q flag: 0)).
							bias := self adaptDelta: delta numpoints: h + 1 firsttime: h = b.
							delta := 0.
							h := h + 1 ] ].
			delta := delta + 1.
			n := n + 1 ].
	^ output contents
]

{ #category : #helper }
PunycodeConverter >> encodeBasic: bcp flag: num [
	| codePoint |
	codePoint := bcp.
	bcp - 97 < 26
		ifTrue: [ codePoint := codePoint - (1 bitShift: 5) ].
	num == 0 & (bcp - 65 < 26)
		ifTrue: [ codePoint := codePoint + (1 bitShift: 5) ].
	^ codePoint
]

{ #category : #helper }
PunycodeConverter >> encodeDigit: d flag: num [
	| codePoint |
	codePoint := d + 22.
	d < 26
		ifTrue: [ codePoint := codePoint + 75 ].
	num ~= 0
		ifTrue: [ codePoint := codePoint - (1 bitShift: 5) ].
	^ codePoint
]

{ #category : #constants }
PunycodeConverter >> initialBias [
	^ 72
]

{ #category : #'initialize-release' }
PunycodeConverter >> initialize [
	base := 36.
	tmin := 1.
	tmax := 26.
	skew := 38.
	damp := 700.
	bias := 72.
	n := 16r80.
	caseSensitive := false
]

{ #category : #'initialize-release' }
PunycodeConverter >> nonCaseSensitive [
	caseSensitive := false
]

{ #category : #constants }
PunycodeConverter >> prefix [
	^ 'xn--' copy
]

{ #category : #helper }
PunycodeConverter >> reset [
	self initialize
]
