Class {
	#name : 'CormasBotSession',
	#superclass : 'Object',
	#instVars : [
		'id',
		'title',
		'bot',
		'simulation',
		'entities',
		'commands',
		'updateBlock'
	],
	#category : 'Cormas-Telegram',
	#package : 'Cormas-Telegram'
}

{ #category : 'accessing' }
CormasBotSession >> bot: aBot [

	bot := aBot
]

{ #category : 'as yet unclassified' }
CormasBotSession >> controlEntity: aMessage [
	"Assign control over certain entity (agent, patch, etc.) to a chat that requested control over it"
	| words type entityId entityClass getter entityCollection entity |
	
	words := aMessage text substrings.
	
	type := words second.
	entityId := words third asInteger.
	
	entityClass := simulation cormasModel class allEntityClasses detect: [ :aClass | aClass name includesSubstring: type ].
	
	getter := simulation cormasModel getterForEntityClass: entityClass.
	
	entityCollection := simulation cormasModel perform: getter.
	
	entity := entityCollection detect: [ :each | each id = entityId ].
	
	entities at: aMessage chat id put: entity.
	
	aMessage send: 'Controlling ', type, ' entity with id ', entityId asString
]

{ #category : 'execution' }
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
	updateBlock value.
	
	aMessage send: 'Performing action #', selector.
]

{ #category : 'as yet unclassified' }
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

{ #category : 'accessing' }
CormasBotSession >> id [

	^ id
]

{ #category : 'initialization' }
CormasBotSession >> initialize [

	super initialize.
	id := self hash.
	
	entities := Dictionary new
]

{ #category : 'private' }
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

{ #category : 'as yet unclassified' }
CormasBotSession >> simplifySelector: aString [
	"Simplify the selector to match it to a text received from chat. For example, we want users to write 'Move' or 'move' to match selector #move. They can also write 'Move 4' to match selector #move: with one argument 4.
	
	We do this by converting selector to lowercase and removing all colon characters"

	^ (aString copyWithout: $:) asLowercase
]

{ #category : 'accessing' }
CormasBotSession >> simulation [

	^ simulation
]

{ #category : 'accessing' }
CormasBotSession >> simulation: aSimulation [

	simulation := aSimulation 
]

{ #category : 'accessing' }
CormasBotSession >> title [

	^ title
]

{ #category : 'accessing' }
CormasBotSession >> title: aString [

	title := aString
]

{ #category : 'enumerating' }
CormasBotSession >> whenActionPerformedDo: aBlock [

	updateBlock := aBlock
]
