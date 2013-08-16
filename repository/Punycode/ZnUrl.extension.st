Extension { #name : #ZnUrl }

{ #category : #'*Punycode' }
ZnUrl >> encodeHostNameInPunycode: string [
	^ ((string findTokens: '.')
		collect: [ :token | 
			token hasNonBasicCharacter
				ifTrue: [ PunycodeConverter new encode: token ]
				ifFalse: [ token ] ]) reduce: [ :a :b | a , '.' , b ]
]

{ #category : #'*Punycode' }
ZnUrl >> encodePunycode: string [
	^ ((string findTokens: '.')
		collect: [ :token | 
			token hasNonBasicCharacter
				ifTrue: [ PunycodeConverter new encode: token ]
				ifFalse: [ token ] ]) reduce: [ :a :b | a , '.' , b ]
]

{ #category : #'*Punycode' }
ZnUrl >> parseHostPort: stream [
	| hostString |
	self isFile
		ifTrue: [ 
			(hostString := stream upTo: $/) isEmpty
				ifFalse: [ self host: (self decodePercent: (self encodeHostNameInPunycode: hostString)) ] ]
		ifFalse: [ 
			(hostString := stream upTo: $:) isEmpty
				ifFalse: [ self host: (self decodePercent: (self encodeHostNameInPunycode: hostString)) ].
			stream atEnd
				ifFalse: [ self port: (Integer readFrom: stream ifFail: [ ZnPortNotANumber signal ]) ] ]
]
