Extension { #name : #String }

{ #category : #'*Punycode' }
String >> encodePunycode [
	^ PunycodeConverter new encode: self
]

{ #category : #'*Punycode' }
String >> hasNonBasicCharacter [
	self
		do: [ :c | 
			c isSafeForHTTP
				ifFalse: [ ^ true ] ].
	^ false
]

{ #category : #'*Punycode' }
String >> isPunycode [
	^ 'xn--*' match: self
]
