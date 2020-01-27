Class {
	#name : #BaselineOfPunycode,
	#superclass : #BaselineOf,
	#category : #BaselineOfPunycode
}

{ #category : #baselines }
BaselineOfPunycode >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ spec blessing: #baseline.
			spec package: 'Punycode' ]
]
