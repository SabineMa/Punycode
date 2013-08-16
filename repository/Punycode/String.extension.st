Extension { #name : #String }

{ #category : #'*Punycode' }
String >> encodePunycode [
	^ PunycodeConverter new encode: self
]

{ #category : #'*Punycode' }
String >> isPunycode [
	^ 'xn--*' match: self
]
