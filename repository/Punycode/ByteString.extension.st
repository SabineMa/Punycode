Extension { #name : #ByteString }

{ #category : #'*Punycode' }
ByteString >> decodePunycode [
	^ self isPunycode
		ifTrue: [ PunycodeConverter new decode: self ]
		ifFalse: [ self ]
]
