Class {
	#name : #CormasBotSession,
	#superclass : #Object,
	#instVars : [
		'id',
		'title',
		'bot',
		'cormasModel',
		'entities',
		'commands'
	],
	#category : #'Cormas-Telegram-Bot'
}

{ #category : #accessing }
CormasBotSession >> bot: aBot [

	bot := aBot
]

{ #category : #'as yet unclassified' }
CormasBotSession >> controlEntity: aMessage [
	"Assign control over certain entity (agent, patch, etc.) to a chat that requested control over it"
	| words type id entityCollection entity |
	
	words := aMessage text substrings.
	
	type := words second.
	id := words third asInteger.
	
	entityCollection := cormasModel perform: ('the', type, 's') asSymbol.
	
	entity := entityCollection detect: [ :each | each id = id ].
	
	entities at: aMessage chat id put: entity.
	
	aMessage send: 'Controlling ', type, ' entity with id ', id asString
]

{ #category : #accessing }
CormasBotSession >> cormasModel [

	^ cormasModel
]

{ #category : #accessing }
CormasBotSession >> cormasModel: aModel [

	cormasModel := aModel
]

{ #category : #execution }
CormasBotSession >> execute: aMessage [

	| words entity informalSelector arguments selector |
	entity := entities at: aMessage chat id.
	
	words := aMessage text substrings.
	
	"Selector typed in a custom way (uppercase, lowercase, with colon or not)
	We will match the most similar selector out of the available ones"
	informalSelector := words first.
	
	arguments := words copyWithoutFirst.
	
	selector := self
		findSelectorIn: entity
		matching: informalSelector
		numberOfArguments: arguments size.
	
	entity perform: selector withArguments: arguments.
	cormasModel timeChanged.
	
	aMessage send: 'Performing action #', selector.
]

{ #category : #'as yet unclassified' }
CormasBotSession >> findSelectorIn: anObject matching: aString numberOfArguments: aNumber [

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

{ #category : #accessing }
CormasBotSession >> id [

	^ id
]

{ #category : #initialization }
CormasBotSession >> initialize [

	super initialize.
	id := self hash.
	
	entities := Dictionary new.
]

{ #category : #private }
CormasBotSession >> interpret: aMessage [

	| text |
	text := aMessage text asLowercase.

	(text beginsWith: 'control') ifTrue: [
		self controlEntity: aMessage.
		^ self ].
	
	(entities keys includes: aMessage chat id) ifFalse: [ 
		aMessage send: 'You must first select the agent that you wish to control'.
		^ self ].
	
	[ self execute: aMessage ] on: Exception do: [ :exception |
		aMessage send: exception description ].
]

{ #category : #'as yet unclassified' }
CormasBotSession >> simplifySelector: aString [
	"Simplify the selector to match it to a text received from chat. For example, we want users to write 'Move' or 'move' to match selector #move. They can also write 'Move 4' to match selector #move: with one argument 4.
	
	We do this by converting selector to lowercase and removing all colon characters"

	^ (aString copyWithout: $:) asLowercase
]

{ #category : #accessing }
CormasBotSession >> title [

	^ title
]

{ #category : #accessing }
CormasBotSession >> title: aString [

	title := aString
]
