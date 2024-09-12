Class {
	#name : 'CormasBot',
	#superclass : 'Bottlegram',
	#instVars : [
		'sessions',
		'connectedChats',
		'updateBlock',
		'simulation'
	],
	#category : 'Cormas-Telegram',
	#package : 'Cormas-Telegram'
}

{ #category : 'as yet unclassified' }
CormasBot >> createSessionFor: aSimulation titled: aString [

	| session |
	
	session := CormasBotSession new
		bot: self;
		simulation: aSimulation;
		title: aString;
		whenActionPerformedDo: updateBlock;
		yourself.
		
	sessions add: session.
]

{ #category : 'action' }
CormasBot >> defaultText: aMessage [
	
	| session |
	
	(connectedChats keys includes: aMessage chat id) ifFalse: [ 
		aMessage send: 'You are not connected to any session yet'.
		^ self ].
	
	session := connectedChats at: aMessage chat id.
	session interpret: aMessage.
]

{ #category : 'initialization' }
CormasBot >> initialize [

	super initialize.
	sessions := OrderedCollection new.
	connectedChats := Dictionary new.
	
	self registerCommand: #slashMySession: to: '/mysession'.
	self registerCommand: #slashConnect: to: '/connect'.
	
	updateBlock := [ "do nothing" ]
]

{ #category : 'accessing' }
CormasBot >> simulation: aSimulation [

	simulation := aSimulation
]

{ #category : 'action' }
CormasBot >> slashConnect: aMessage [
	"TODO: Implement a way to choose session"
	
	| session |
	session := sessions first.
	connectedChats at: aMessage chat id put: session.
	
	aMessage send: 'You have joined the session ''', session title, ''''.
]

{ #category : 'action' }
CormasBot >> slashHelp: aMessage [

	aMessage send: 'Hello, I''m a Telegram bot for Cormas written in Pharo. Use me to select an agent that you wish to control and then make it move or eat'
]

{ #category : 'action' }
CormasBot >> slashMySession: aMessage [

	connectedChats at: aMessage chat id
		ifPresent: [ :session |
			aMessage send:
				'You are connected to session ', session id asString,
				' titled ''', session title, '''' ]
		ifAbsent: [ aMessage send: 'You are not connected to any session yet' ].
]

{ #category : 'action' }
CormasBot >> slashStart: aMessage [

	aMessage send: 'Hello, I''m a Telegram bot written in Pharo. Send /help for more information'
]

{ #category : 'enumerating' }
CormasBot >> whenActionPerformedDo: aBlock [

	updateBlock := aBlock
]
