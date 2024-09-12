Class {
	#name : 'CormasBotCommand',
	#superclass : 'Object',
	#instVars : [
		'name',
		'action'
	],
	#category : 'Cormas-Telegram',
	#package : 'Cormas-Telegram'
}

{ #category : 'accessing' }
CormasBotCommand >> action: aBlock [
	"An action to be executed"
	action := aBlock
]

{ #category : 'as yet unclassified' }
CormasBotCommand >> exectuteFor: anEntity [

	action value: anEntity
]

{ #category : 'accessing' }
CormasBotCommand >> name [

	^ name
]

{ #category : 'accessing' }
CormasBotCommand >> name: aString [
	"Name must be lowercase. We will match it with what user types ('move', 'Move' and 'MOVE' should all match the command named 'move')"
	name := aString
]
