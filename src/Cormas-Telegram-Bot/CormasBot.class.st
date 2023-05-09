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
CormasBot >> controlAgent: id [

	agent := cormasModel theUnrestraineds detect: [ :each | each id = id ].
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
	
	| text id |
	text := aMessage text asLowercase.

	(text beginsWith: 'control') ifTrue: [ 
		id := text substrings second asInteger.
		self controlAgent: id.
		aMessage send: 'Controlling agent ', id asString ].
	
	text = 'move' ifTrue: [ self move ].
	text = 'eat' ifTrue: [ self eat ].
]

{ #category : #accessing }
CormasBot >> eat [

	agent eat.
	cormasModel timeChanged.
]

{ #category : #accessing }
CormasBot >> move [

	agent move.
	cormasModel timeChanged.
]

{ #category : #action }
CormasBot >> slashHelp: aMessage [

	aMessage send: 'Hello, I''m a Telegram bot written in Pharo. Tell me something and I''ll repeat after you'
]

{ #category : #action }
CormasBot >> slashStart: aMessage [

	aMessage send: 'Hello, I''m a Telegram bot written in Pharo. Send /help for more information'
]
