Extension { #name : #String }

{ #category : #'*Punycode' }
String >> encodePunycode [
	^ PunycodeConverter new encode: self
]

{ #category : #'*Punycode' }
String >> hasNonBasicCharacter [
	| basicCharacters |
	basicCharacters := 'abcdefghijklmnopqrstuvwxyz0123456789-'.
	self
		do: [ :char | 
			(basicCharacters includes: char lowercase)
				ifFalse: [ ^ true ] ].
	^ false
]

{ #category : #'*Punycode' }
String >> isPunycode [
	^ 'xn--*' match: self
]
