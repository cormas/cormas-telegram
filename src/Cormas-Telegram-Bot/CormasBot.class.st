Class {
	#name : #CormasBot,
	#superclass : #Bottlegram,
	#instVars : [
		'cormasModel',
		'agents'
	],
	#category : #'Cormas-Telegram-Bot'
}

{ #category : #'as yet unclassified' }
CormasBot >> controlAgent: aMessage [
	
	| words type id agentCollection agent |
	
	words := aMessage text substrings.
	
	type := words second.
	id := words third asInteger.
	
	agentCollection := cormasModel perform: ('the', type, 's') asSymbol.
	agent := agentCollection detect: [ :each | each id = id ].
	
	agents at: aMessage chat id put: agent.
	
	aMessage send: 'Controlling ', type, ' agent ', id asString
]

{ #category : #accessing }
CormasBot >> cormasModel [

	^ cormasModel
]

{ #category : #accessing }
CormasBot >> cormasModel: anObject [

	cormasModel := anObject
]

{ #category : #action }
CormasBot >> defaultText: aMessage [
	
	| text |
	text := aMessage text asLowercase.

	(text beginsWith: 'control') ifTrue: [ self controlAgent: aMessage ].
	
	(agents keys includes: aMessage chat id) ifFalse: [ 
		aMessage send: 'You must first select the agent that you wish to control'.
		^ self ].
	
	[ self execute: aMessage ] on: Exception do: [ :exception |
		aMessage send: exception description ].
]

{ #category : #execution }
CormasBot >> execute: aMessage [

	| words agent selector |
	words := aMessage text substrings.
	
	agent := agents at: aMessage chat id.
	
	selector := self
		findSelectorIn: agent
		matching: words first
		numberOfArguments: words size - 1.
	
	agent perform: selector.
	cormasModel timeChanged.
	
	aMessage send: 'Performing action #', selector.
]

{ #category : #'as yet unclassified' }
CormasBot >> findSelectorIn: anObject matching: aString numberOfArguments: aNumber [

	| selectors |
	selectors := anObject class allSelectors.
	
	selectors := selectors select: [ :each | each numArgs = aNumber ].
	
	selectors ifEmpty: [
		self error: 'Agent does not understand any messages with this number of arguments' ].
	
	selectors
		detect: [ :selector |
			(self simplifySelector: selector asString) = (self simplifySelector: aString) ]
		ifFound: [ :selector | ^ selector ]
		ifNone: [
			self error: 'Agent does not understand any message similar to ', aString,
				' with ', aNumber asString, ' arguments' ].
]

{ #category : #initialization }
CormasBot >> initialize [

	super initialize.
	agents := Dictionary new.
]

{ #category : #'as yet unclassified' }
CormasBot >> simplifySelector: aString [
	"Simplify the selector to match it to a text received from chat. For example, we want users to write 'Move' or 'move' to match selector #move. They can also write 'Move 4' to match selector #move: with one argument 4.
	
	We do this by converting selector to lowercase and removing all colon characters"

	^ (aString copyWithout: $:) asLowercase
]

{ #category : #action }
CormasBot >> slashHelp: aMessage [

	aMessage send: 'Hello, I''m a Telegram bot for Cormas written in Pharo. Use me to select an agent that you wish to control and then make it move or eat'
]

{ #category : #action }
CormasBot >> slashStart: aMessage [

	aMessage send: 'Hello, I''m a Telegram bot written in Pharo. Send /help for more information'
]
