Class {
	#name : #CormasBot,
	#superclass : #Bottlegram,
	#instVars : [
		'cormasModel',
		'agent'
	],
	#category : #'Cormas-Telegram-Bot'
}

{ #category : #'as yet unclassified' }
CormasBot >> controlAgent: aMessage [
	
	| text words type id agentCollection |
	
	text := aMessage text.
	words := text substrings.
	
	type := words second.
	id := words third asInteger.
	
	agentCollection := cormasModel perform: ('the', type, 's') asSymbol.
	agent := agentCollection detect: [ :each | each id = id ].
	
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
	
	text = 'move' ifTrue: [ self move: aMessage ].
	text = 'eat' ifTrue: [ self eat: aMessage ].
]

{ #category : #accessing }
CormasBot >> eat: aMessage [

	agent eat.
	cormasModel timeChanged.
	
	aMessage send: 'Agent is eating'	
]

{ #category : #accessing }
CormasBot >> move: aMessage [

	agent move.
	cormasModel timeChanged.
	
	aMessage send: 'Agent is moving'
]

{ #category : #action }
CormasBot >> slashHelp: aMessage [

	aMessage send: 'Hello, I''m a Telegram bot written in Pharo. Tell me something and I''ll repeat after you'
]

{ #category : #action }
CormasBot >> slashStart: aMessage [

	aMessage send: 'Hello, I''m a Telegram bot written in Pharo. Send /help for more information'
]
